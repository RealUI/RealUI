local _, private = ...
local NP = private.NP
local Safe = private.Safe

--[[ Small power bar under the health bar. Default off (spec req 5.1); when enabled it
     shows only for units that use mana, mirroring the shipped profile's intent. ]]--

local PowerBar = {}

function PowerBar.Create(plate)
    local db = NP.db.profile.enemy.power

    local bar = _G.CreateFrame("StatusBar", nil, plate)
    bar:SetPoint("TOPLEFT", plate, "BOTTOMLEFT", 30, -1)
    bar:SetPoint("TOPRIGHT", plate, "BOTTOMRIGHT", -30, -1)
    bar:SetHeight(db.height)
    bar:SetStatusBarTexture([[Interface\Buttons\WHITE8x8]])
    bar:Hide()

    local bg = bar:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(bar)
    bg:SetColorTexture(0.086, 0.086, 0.086, 0.9)

    plate.PowerBar = { bar = bar }
end

local function ShouldShow(unit)
    if not NP.db.profile.enemy.power.enabled then return false end
    -- Power type and max can both be secret in combat; comparisons stay in the pcall.
    return private.SafeTest(function()
        return _G.UnitPowerType(unit) == _G.Enum.PowerType.Mana
            and _G.UnitPowerMax(unit) > 0
    end)
end

local function UpdatePower(plate)
    local unit = plate.unit
    local bar = plate.PowerBar.bar
    Safe(function()
        bar:SetMinMaxValues(0, _G.UnitPowerMax(unit))
        bar:SetValue(_G.UnitPower(unit))
    end)
end

function PowerBar.Attach(plate, unit)
    local bar = plate.PowerBar.bar
    if plate.design ~= "enemy" or not ShouldShow(unit) then
        bar:Hide()
        return
    end
    -- Indexing PowerBarColor with a secret token would throw; fall back to mana.
    local color = Safe(function()
        local _, token = _G.UnitPowerType(unit)
        return token and _G.PowerBarColor[token]
    end) or _G.PowerBarColor["MANA"]
    bar:SetStatusBarColor(color.r, color.g, color.b)
    UpdatePower(plate)
    bar:Show()
end

function PowerBar.Detach(plate)
    plate.PowerBar.bar:Hide()
end

function PowerBar.OnPowerEvent(plate)
    if plate.PowerBar.bar:IsShown() then
        UpdatePower(plate)
    end
end

function PowerBar.OnDimensionsChanged(plate)
    plate.PowerBar.bar:SetHeight(NP.db.profile.enemy.power.height)
end

private.RegisterUnitEvent("UNIT_POWER_UPDATE", "OnPowerEvent")
private.RegisterUnitEvent("UNIT_MAXPOWER", "OnPowerEvent")

private.AddElement("PowerBar", PowerBar)
