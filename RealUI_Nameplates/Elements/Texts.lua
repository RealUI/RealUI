local _, private = ...
local NP = private.NP
local Safe = private.Safe

--[[ Name (above the bar; the whole plate for friendlies) and health percent.
     UnitName and health values can be secret in rated PvP — all guarded. ]]--

local Texts = {}

function Texts.Create(plate)
    local name = plate:CreateFontString(nil, "OVERLAY")
    name:SetWordWrap(false)
    name:SetPoint("BOTTOM", plate, "TOP", 0, 3)

    local healthPercent = plate:CreateFontString(nil, "OVERLAY")
    healthPercent:SetPoint("LEFT", plate, "RIGHT", 4, 0)

    -- Fonts at CREATION, not just in Attach: Detach calls SetText on a plate
    -- that may never have been attached (rapid plate churn in a battleground
    -- releases pooled plates before the attach pass), and SetText on a
    -- font-less FontString throws "FontString:SetText(): Font not set"
    -- (x7, 2026-08-22). Attach re-applies the configured sizes afterwards.
    private.ApplyFont(name, NP.db.profile.enemy.texts.name.size)
    private.ApplyFont(healthPercent, 9)

    plate.Texts = { name = name, healthPercent = healthPercent }
end

local function FriendlyNameColor(unit)
    local db = NP.db.profile.friendly.name
    -- Role and class are both secret-capable in a battleground; indexing a
    -- plain table with either throws (see private.ClassColor in Health.lua).
    local role = _G.UnitGroupRolesAssigned(unit)
    if private.Accessible(role) and db.roleColors[role] then
        return db.roleColors[role]
    end
    local classColor = private.ClassColor(unit)
    if classColor then return classColor end
    return NP.db.profile.enemy.colors.reaction.friendly
end

local function UpdateName(plate)
    local unit = plate.unit
    local texts = plate.Texts
    local enemyDB = NP.db.profile.enemy.texts.name

    if plate.design == "enemy" and not enemyDB.enabled then
        texts.name:Hide()
        return
    end

    local shown = Safe(function()
        texts.name:SetText(_G.UnitName(unit))
        return true
    end)
    if not shown then
        texts.name:Hide()
        return
    end

    if plate.design == "friendly" then
        -- Role/class lookups can hit secret strings in odd instance states.
        local color = Safe(FriendlyNameColor, unit)
            or NP.db.profile.enemy.colors.reaction.friendly
        texts.name:SetTextColor(color.r, color.g, color.b)
        texts.name:SetWidth(0)
    else
        texts.name:SetTextColor(1, 1, 1)
        -- Fixed width, no GetStringWidth comparison: string width of a secret name
        -- is itself secret. Short names center inside the fixed box.
        texts.name:SetWidth(enemyDB.maxWidth)
    end
    texts.name:Show()
end

local function UpdateHealthPercent(plate)
    local texts = plate.Texts
    if plate.design ~= "enemy" or not NP.db.profile.enemy.texts.healthPercent then
        texts.healthPercent:Hide()
        return
    end
    -- B58: pre-check with Accessible instead of computing inside a pcall —
    -- the caught throw still logged (623 taint.log entries in 8 minutes).
    -- Same degradation: the percentage text hides while health is secret;
    -- the health bar itself keeps updating (secret-capable SetValue).
    local shown = false
    local max, cur = _G.UnitHealthMax(plate.unit), _G.UnitHealth(plate.unit)
    if private.Accessible(max) and private.Accessible(cur) and max > 0 then
        local percent = _G.math.floor(cur / max * 100 + 0.5)
        texts.healthPercent:SetFormattedText("%d%%", percent)
        shown = true
    end
    texts.healthPercent:SetShown(shown)
end

function Texts.Attach(plate, unit)
    local texts = plate.Texts
    private.ApplyFont(texts.name, plate.design == "friendly"
        and NP.db.profile.friendly.name.size or NP.db.profile.enemy.texts.name.size)
    private.ApplyFont(texts.healthPercent, 9)

    -- Friendly plates are name-only: name sits where the bar would be.
    texts.name:ClearAllPoints()
    if plate.design == "friendly" then
        texts.name:SetPoint("CENTER", plate, "CENTER", 0, 0)
    else
        texts.name:SetPoint("BOTTOM", plate, "TOP", 0, 3)
    end

    UpdateName(plate)
    UpdateHealthPercent(plate)
end

function Texts.Detach(plate)
    plate.Texts.name:SetText("")
    plate.Texts.healthPercent:Hide()
end

function Texts.OnNameEvent(plate)
    UpdateName(plate)
end

function Texts.OnHealthEvent(plate)
    UpdateHealthPercent(plate)
end

-- No UNIT_HEALTH event fires when values stop being secret, so the % text needs an
-- explicit re-check or it stays blank until something unrelated updates health.
--
-- B58: this used to hang off the combat edge alone, on the assumption that secrecy ends
-- when combat ends. Measured 2026-08-30, it does not — secrecy lagged a combat-end edge
-- by 29 seconds in one dungeon and by 0.6s in another, so the refresh ran while values
-- were still secret and nothing looked again. OnSecrecyChanged is driven by the real
-- C_Secrets.ShouldAurasBeSecret transition (RealUI_Nameplates.lua). The combat hook stays
-- because it is free and still a valid moment to re-check.
-- (WoW 12 gives tainted code no secret-capable numeric text API at all —
-- NumericFormatter is AllowedWhenUntainted — so % text during secrecy cannot exist.)
function Texts.OnCombatChanged(plate)
    UpdateHealthPercent(plate)
end
Texts.OnSecrecyChanged = Texts.OnCombatChanged

private.RegisterUnitEvent("UNIT_NAME_UPDATE", "OnNameEvent")
-- UNIT_HEALTH / UNIT_MAXHEALTH are registered by Health.lua; the router calls every
-- element that implements the mapped method, so we share the mapping name.

private.AddElement("Texts", Texts)
