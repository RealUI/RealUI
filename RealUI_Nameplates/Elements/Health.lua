local _, private = ...
local NP = private.NP
local Safe = private.Safe

--[[ Shared element helpers (this file loads first of the elements) ]]--

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

local function ThreatColor(unit, colors)
    if not colors.threat.enabled then return end
    if not _G.UnitAffectingCombat(unit) then return end

    local status = _G.UnitThreatSituation("player", unit)
    if GetRoleIsTank() then
        if status and status >= 2 then return colors.threat.safe end
        if status == 1 then return colors.threat.transition end
        local targetUnit = unit .. "target"
        if _G.UnitExists(targetUnit) and not _G.UnitIsUnit(targetUnit, "player") then
            if _G.UnitGroupRolesAssigned(targetUnit) == "TANK"
                or _G.GetPartyAssignment("MAINTANK", targetUnit)
                or _G.GetPartyAssignment("MAINASSIST", targetUnit) then
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
        local inExecute = private.SafeTest(function()
            local max = _G.UnitHealthMax(unit)
            return max > 0 and (_G.UnitHealth(unit) / max) <= db.execute.threshold
        end)
        if inExecute then
            return private.SafeTest(_G.UnitAffectingCombat, unit) and colors.executeCombat or colors.execute
        end
    end
    if plate.state.casting then return colors.cast end
    if _G.UnitIsPlayer(unit) then
        local _, class = _G.UnitClass(unit)
        local color = class and _G.RAID_CLASS_COLORS[class]
        if color then return color end
    end
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

    local absorbBar = _G.CreateFrame("StatusBar", nil, plate)
    absorbBar:SetAllPoints(plate)
    absorbBar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
    absorbBar:SetStatusBarColor(1, 1, 1, 0.45)
    absorbBar:SetFrameLevel(plate:GetFrameLevel() + 1)

    local bar = _G.CreateFrame("StatusBar", nil, plate)
    bar:SetAllPoints(plate)
    bar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
    bar:SetFrameLevel(plate:GetFrameLevel() + 2)

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
    -- Absorb needs arithmetic, so it degrades independently: when health is secret,
    -- the overlay just stops updating while the health bar keeps working.
    if NP.db.profile.enemy.health.absorb then
        Safe(function()
            local max = _G.UnitHealthMax(unit)
            local absorb = _G.UnitGetTotalAbsorbs(unit) or 0
            health.absorbBar:SetMinMaxValues(0, max)
            health.absorbBar:SetValue(_G.math.min(_G.UnitHealth(unit) + absorb, max))
        end)
    else
        Safe(health.absorbBar.SetValue, health.absorbBar, 0)
    end
end

function private.UpdateHealthColor(plate)
    if plate.design ~= "enemy" or not plate.unit then return end
    local color = ResolveColor(plate, plate.unit)
    plate.Health.bar:SetStatusBarColor(color.r, color.g, color.b)
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

private.RegisterUnitEvent("UNIT_HEALTH", "OnHealthEvent")
private.RegisterUnitEvent("UNIT_MAXHEALTH", "OnHealthEvent")
private.RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", "OnHealthEvent")
private.RegisterUnitEvent("UNIT_THREAT_SITUATION_UPDATE", "OnColorEvent")
private.RegisterUnitEvent("UNIT_THREAT_LIST_UPDATE", "OnColorEvent")
private.RegisterUnitEvent("UNIT_FACTION", "OnColorEvent")

private.AddElement("Health", Health)
