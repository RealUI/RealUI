local _, private = ...
local NP = private.NP
local Safe = private.Safe

-- B58: one shared engine-side heal-prediction calculator. Each UpdateValue
-- refills it via UnitGetDetailedHealPrediction and reads synchronously, so
-- sharing across plates is safe. Its getters are secret-capable inputs to
-- StatusBar SetValue/SetMinMaxValues (see oUF 14 health element).
local calculator = _G.CreateUnitHealPredictionCalculator
    and _G.CreateUnitHealPredictionCalculator() or nil
if calculator then
    -- Absorbs clamp to missing health, ignoring incoming heals — keeps the
    -- overlay from shrinking whenever a heal is in flight.
    calculator:SetDamageAbsorbClampMode(_G.Enum.UnitDamageAbsorbClampMode.MissingHealthWithoutIncomingHeals)
end

--[[ Shared element helpers (this file loads first of the elements) ]]--

--- Class colour for a unit, secret-safe. BOTH reads bite on enemy players:
--- UnitIsPlayer returns a secret boolean (a bare truth test throws) and
--- UnitClass returns a secret class token — indexing RAID_CLASS_COLORS with it
--- throws "attempted to index a table that cannot be indexed with secret keys"
--- (x54 in one battleground, 2026-08-22: every enemy player plate, and the
--- friendly-name path had the same defect). C_ClassColor.GetClassColor accepts
--- secret tokens natively — the route the HuD unit frames already take
--- (`HuD/UnitFrames/Shared.lua` GetClassColor).
function private.ClassColor(unit)
    if not private.SafeTest(_G.UnitIsPlayer, unit) then return nil end

    local _, class = _G.UnitClass(unit)
    if class == nil then return nil end

    if private.Accessible(class) then
        return _G.RAID_CLASS_COLORS[class]
    end
    if _G.C_ClassColor and _G.C_ClassColor.GetClassColor then
        return _G.C_ClassColor.GetClassColor(class)
    end
    return nil
end

function private.ApplyFont(fontString, size)
    local db = NP.db.profile.font
    local path = [[Fonts\FRIZQT__.TTF]]
    local lsm = _G.LibStub("LibSharedMedia-3.0", true)
    if lsm then
        path = lsm:Fetch("font", db.name, true) or path
    end
    fontString:SetFont(path, size, db.outline)
    if db.shadow then
        fontString:SetShadowColor(0, 0, 0, 1)
        fontString:SetShadowOffset(1, -1)
    end
end

-- 1px border drawn as four textures just outside the frame edge. No BackdropMixin —
-- writing backdrop functions onto plate-adjacent frames is the taint path Aurora
-- disabled bar skinning over.
function private.CreateBorder(frame)
    local border = {}
    for i = 1, 4 do
        border[i] = frame:CreateTexture(nil, "BACKGROUND", nil, -8)
        border[i]:SetColorTexture(0, 0, 0, 1)
    end
    border[1]:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 1)      -- top
    border[1]:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", 1, 0)
    border[2]:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -1, 0)   -- bottom
    border[2]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, -1)
    border[3]:SetPoint("TOPLEFT", frame, "TOPLEFT", -1, 0)      -- left
    border[3]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMLEFT", 0, 0)
    border[4]:SetPoint("TOPLEFT", frame, "TOPRIGHT", 0, 0)      -- right
    border[4]:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 1, 0)

    function border:SetColor(r, g, b)
        for i = 1, 4 do border[i]:SetColorTexture(r, g, b, 1) end
    end
    return border
end

--[[ Health bar: absorb bar layered under the health bar (its value runs ahead by the
     absorb amount), class/threat/reaction color chain on top. ]]--

local function GetRoleIsTank()
    local spec = _G.GetSpecialization()
    return spec and _G.GetSpecializationRole(spec) == "TANK"
end

-- Matchmade raids with no role requirements auto-flag arbitrarily many main
-- tanks, so MT/MA assignments carry no signal there. Blizzard hit this in its
-- own raid frames and suppressed the MT/MA display outright
-- (12.1.0.69587, CompactRaidFrameContainerMixin:ShouldDisplayMainTankAndAssist);
-- this mirrors that scope. The assigned-role check keeps applying either way --
-- a role the player chose stays meaningful where an auto-flag does not.
-- Guarded for existence: the API landed mid-12.1.0, so older 12.1 clients
-- return the pre-fix behaviour rather than erroring.
local function MainTankFlagsAreMeaningful()
    local LFGInfo = _G.C_LFGInfo
    if LFGInfo and LFGInfo.IsInMatchmadeRaidWithoutRoleRequirements then
        return not LFGInfo.IsInMatchmadeRaidWithoutRoleRequirements()
    end
    return true
end

local function ThreatColor(unit, colors)
    if not colors.threat.enabled then return end
    if not _G.UnitAffectingCombat(unit) then return end

    local status = _G.UnitThreatSituation("player", unit)
    if GetRoleIsTank() then
        if status and status >= 2 then return colors.threat.safe end
        if status == 1 then return colors.threat.transition end
        local targetUnit = unit .. "target"
        if _G.UnitExists(targetUnit) and not _G.UnitIsUnit(targetUnit, "player") then
            local heldByTank = _G.UnitGroupRolesAssigned(targetUnit) == "TANK"
            if not heldByTank and MainTankFlagsAreMeaningful() then
                heldByTank = _G.GetPartyAssignment("MAINTANK", targetUnit)
                    or _G.GetPartyAssignment("MAINASSIST", targetUnit)
            end
            if heldByTank then
                return colors.threat.offtank
            end
        end
        return colors.threat.warning
    else
        if status and status >= 2 then return colors.threat.warning end
        if status == 1 then return colors.threat.transition end
    end
end

local function ReactionColor(unit, colors)
    local reaction = _G.UnitReaction(unit, "player") or 4
    if reaction <= 2 then return colors.reaction.hostile end
    if reaction == 3 then return colors.reaction.unfriendly end
    if reaction == 4 then return colors.reaction.neutral end
    return colors.reaction.friendly
end

-- Priority: execute → casting → class → tapped → threat → reaction (spec req 3.2).
-- Threat status, reaction, combat and tapped state can all be secret in combat;
-- every tier degrades to the next one when its data is inaccessible.
local function ResolveColor(plate, unit)
    local db = NP.db.profile.enemy
    local colors = db.colors

    if db.execute.enabled then
        -- B58: pre-check with Accessible instead of computing inside a pcall —
        -- the caught throw still logged (765 taint.log entries in 8 minutes).
        -- Same degradation: no execute colouring while health is secret.
        local max, cur = _G.UnitHealthMax(unit), _G.UnitHealth(unit)
        if private.Accessible(max) and private.Accessible(cur)
            and max > 0 and (cur / max) <= db.execute.threshold then
            return private.SafeTest(_G.UnitAffectingCombat, unit) and colors.executeCombat or colors.execute
        end
    end
    if plate.state.casting then return colors.cast end
    local classColor = private.ClassColor(unit)
    if classColor then return classColor end
    if private.SafeTest(_G.UnitIsTapDenied, unit) then return colors.tapped end
    return Safe(ThreatColor, unit, colors) or Safe(ReactionColor, unit, colors)
        or colors.reaction.neutral
end

local Health = {}

function Health.Create(plate)
    local db = NP.db.profile.enemy.health

    local bg = plate:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(plate)
    bg:SetColorTexture(db.background.r, db.background.g, db.background.b, db.background.a)

    local bar = _G.CreateFrame("StatusBar", nil, plate)
    bar:SetAllPoints(plate)
    bar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
    bar:SetFrameLevel(plate:GetFrameLevel() + 2)

    -- B58: the absorb overlay spans the missing-health region — anchored from
    -- the health fill's edge to the plate's right edge. With min/max set to
    -- (0, missing health), a fill of absorb/missing over that region is
    -- geometrically identical to absorb/max over the full bar, so no Lua
    -- arithmetic is needed anywhere: anchors track the fill edge and the
    -- values come secret-capable from the heal-prediction calculator.
    local absorbBar = _G.CreateFrame("StatusBar", nil, plate)
    absorbBar:SetPoint("TOPLEFT", bar:GetStatusBarTexture(), "TOPRIGHT")
    absorbBar:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT")
    absorbBar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
    absorbBar:SetStatusBarColor(1, 1, 1, 0.45)
    absorbBar:SetFrameLevel(plate:GetFrameLevel() + 1)

    plate.Health = {
        bg = bg,
        absorbBar = absorbBar,
        bar = bar,
        border = private.CreateBorder(plate),
    }
end

local function UpdateValue(plate)
    local unit = plate.unit
    local health = plate.Health
    -- No arithmetic here: secret health values pass straight into the StatusBar
    -- (SetValue is secret-capable, per oUF 14's health element).
    Safe(function()
        health.bar:SetMinMaxValues(0, _G.UnitHealthMax(unit))
        health.bar:SetValue(_G.UnitHealth(unit))
    end)
    -- B58: absorb via the engine's heal-prediction calculator — the old
    -- min(health + absorb, max) arithmetic threw on secret health in combat
    -- (599 silent no-ops in one 8-minute taint log), so the overlay never
    -- tracked when it mattered. Calculator getters feed SetMinMaxValues/
    -- SetValue secret-capably, same as oUF 14's health element.
    if NP.db.profile.enemy.health.absorb and calculator then
        Safe(function()
            _G.UnitGetDetailedHealPrediction(unit, nil, calculator)
            health.absorbBar:SetMinMaxValues(0, calculator:GetMissingHealth())
            health.absorbBar:SetValue((calculator:GetDamageAbsorbs()))
        end)
    else
        Safe(health.absorbBar.SetValue, health.absorbBar, 0)
    end
end

function private.UpdateHealthColor(plate)
    if plate.design ~= "enemy" or not plate.unit then return end
    local color = ResolveColor(plate, plate.unit)
    -- A class colour resolved from a SECRET class token carries secret
    -- components; SetStatusBarColor takes those, but keep the whole apply in
    -- Safe so a future secret-tier change degrades to "bar keeps its colour"
    -- instead of erroring once per plate per update (B58 doctrine).
    Safe(plate.Health.bar.SetStatusBarColor, plate.Health.bar, color.r, color.g, color.b)
end

function Health.Attach(plate, unit)
    local health = plate.Health
    if plate.design ~= "enemy" then
        health.bar:Hide()
        health.absorbBar:Hide()
        health.bg:Hide()
        health.border:SetColor(0, 0, 0)
        for i = 1, 4 do health.border[i]:Hide() end
        return
    end
    health.bar:Show()
    health.absorbBar:Show()
    health.bg:Show()
    for i = 1, 4 do health.border[i]:Show() end
    UpdateValue(plate)
    private.UpdateHealthColor(plate)
end

function Health.Detach(plate)
    plate.Health.bar:SetValue(0)
    plate.Health.absorbBar:SetValue(0)
end

function Health.OnHealthEvent(plate)
    UpdateValue(plate)
    private.UpdateHealthColor(plate)
end

function Health.OnColorEvent(plate)
    private.UpdateHealthColor(plate)
end

Health.OnCombatChanged = Health.OnColorEvent
-- B58: execute-range colouring reads health values, so it recovers on the secrecy
-- transition rather than only on a combat edge (see Texts.lua / RefreshSecrecy).
Health.OnSecrecyChanged = Health.OnColorEvent

private.RegisterUnitEvent("UNIT_HEALTH", "OnHealthEvent")
private.RegisterUnitEvent("UNIT_MAXHEALTH", "OnHealthEvent")
private.RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "OnHealthEvent")
private.RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", "OnColorEvent")
private.RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", "OnColorEvent")
private.RegisterUnitEvent("UNIT_FACTION", "OnColorEvent")

private.AddElement("Health", Health)
