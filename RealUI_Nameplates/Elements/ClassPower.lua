local _, private = ...
local NP = private.NP

--[[ B81: the player's combo points / class resource on the current target's plate.

     One row of pips, re-anchored to whichever plate is the target, rather than a row
     per plate: combo points conventionally belong to the target only, and one row
     means one set of events. It sits inside the bottom edge of the health bar, the
     one spot that never collides with the name and auras above, the castbar below,
     or the percent text and markers beside it.

     The data is the player's own power, which is readable in combat (the HuD class
     points use it too), but every read still goes through Accessible. Player power
     events carry unit "player", which the plate event router drops (no plate), so
     this element has its own event frame. ]]--

local MAX_PIPS = 10
local PIP_GAP = 1
local CAT_FORM = 1  -- GetShapeshiftFormID()

local PowerType = _G.Enum.PowerType
-- class -> { power type, PowerBarColor token, spec that has it (nil = all) }
local RESOURCES = {
    ROGUE   = { PowerType.ComboPoints,   "COMBO_POINTS" },
    DRUID   = { PowerType.ComboPoints,   "COMBO_POINTS" },
    PALADIN = { PowerType.HolyPower,     "HOLY_POWER" },
    MONK    = { PowerType.Chi,           "CHI", 3 },            -- Windwalker
    MAGE    = { PowerType.ArcaneCharges, "ARCANE_CHARGES", 1 }, -- Arcane
    WARLOCK = { PowerType.SoulShards,    "SOUL_SHARDS" },
    EVOKER  = { PowerType.Essence,       "ESSENCE" },
}
local FALLBACK_COLOR = { r = 1, g = 0.96, b = 0.41 }

local ClassPower = {}
local row, resource, playerClass

local function ResolveResource()
    local _, class = _G.UnitClass("player")
    playerClass = class
    resource = RESOURCES[class]
    if resource and resource[3] then
        local spec = _G.C_SpecializationInfo and _G.C_SpecializationInfo.GetSpecialization
            and _G.C_SpecializationInfo.GetSpecialization()
        if spec ~= resource[3] then resource = nil end
    end
end

local function CreateRow()
    row = _G.CreateFrame("Frame", nil, _G.UIParent)
    row:Hide()
    row.pips = {}
    for i = 1, MAX_PIPS do
        local pip = row:CreateTexture(nil, "OVERLAY", nil, 3)
        pip:SetColorTexture(1, 1, 1)
        row.pips[i] = pip
    end
end

local function FindTargetPlate()
    if not _G.UnitExists("target") then return end
    for unit, plate in _G.next, private.activeByUnit do
        if plate.design == "enemy" and _G.UnitIsUnit(unit, "target") then
            return plate
        end
    end
end

local function ReadPower()
    if not resource then return end
    if playerClass == "DRUID" and _G.GetShapeshiftFormID() ~= CAT_FORM then return end
    local cur = _G.UnitPower("player", resource[1])
    local max = _G.UnitPowerMax("player", resource[1])
    if not (private.Accessible(cur) and private.Accessible(max)) or max <= 0 then return end
    return cur, _G.math.min(max, MAX_PIPS)
end

local function Layout(plate, max)
    local db = NP.db.profile.enemy.classPower
    row:SetParent(plate)
    row:SetFrameLevel(plate:GetFrameLevel() + 10)
    row:ClearAllPoints()
    row:SetPoint("BOTTOMLEFT", plate, "BOTTOMLEFT", 1, 1)
    row:SetPoint("BOTTOMRIGHT", plate, "BOTTOMRIGHT", -1, 1)
    row:SetHeight(db.height)

    local width = (plate:GetWidth() - 2 - PIP_GAP * (max - 1)) / max
    for i = 1, MAX_PIPS do
        local pip = row.pips[i]
        pip:ClearAllPoints()
        if i <= max then
            pip:SetSize(width, db.height)
            pip:SetPoint("LEFT", row, "LEFT", (i - 1) * (width + PIP_GAP), 0)
        end
    end
    row.anchoredTo, row.max = plate, max
end

local function Update()
    if not row then return end
    local db = NP.db.profile.enemy.classPower
    local plate = db.enabled and FindTargetPlate()
    local cur, max = ReadPower()
    if not (plate and cur) then
        row:Hide()
        return
    end

    if row.anchoredTo ~= plate or row.max ~= max then
        Layout(plate, max)
    end

    local color = _G.PowerBarColor[resource[2]] or FALLBACK_COLOR
    for i = 1, MAX_PIPS do
        local pip = row.pips[i]
        if i > max then
            pip:Hide()
        else
            if i <= cur then
                pip:SetVertexColor(color.r, color.g, color.b, 1)
            else
                pip:SetVertexColor(0.086, 0.086, 0.086, 0.9)  -- empty: the bar background
            end
            pip:Show()
        end
    end
    row:Show()
end

-- Attach and OnTargetChanged run once PER PLATE, and Update scans every plate:
-- queue one Update for the next frame instead (40 plates would be 1,600
-- UnitIsUnit calls per target change otherwise).
local queued
local function QueueUpdate()
    if queued then return end
    queued = true
    _G.C_Timer.After(0, function()
        queued = false
        Update()
    end)
end

function ClassPower.Attach()
    QueueUpdate()
end

function ClassPower.Detach(plate)
    if row and row.anchoredTo == plate then
        row.anchoredTo = nil
        row:Hide()
        -- The detached plate may have been the target; re-evaluate once the
        -- plate bookkeeping has settled.
        QueueUpdate()
    end
end

function ClassPower.OnTargetChanged()
    QueueUpdate()
end

function ClassPower.OnDimensionsChanged()
    if row then row.anchoredTo = nil end
    Update()
end

function ClassPower.OnEnable()
    ResolveResource()
    CreateRow()

    local events = _G.CreateFrame("Frame")
    events:RegisterUnitEvent("UNIT_POWER_UPDATE", "player")
    events:RegisterUnitEvent("UNIT_MAXPOWER", "player")
    events:RegisterEvent("UPDATE_SHAPESHIFT_FORM")
    events:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    events:RegisterEvent("PLAYER_ENTERING_WORLD")
    events:SetScript("OnEvent", function(_, event)
        if event == "PLAYER_SPECIALIZATION_CHANGED" or event == "PLAYER_ENTERING_WORLD" then
            ResolveResource()
            row.max = nil
        elseif event == "UNIT_MAXPOWER" then
            row.max = nil
        end
        Update()
    end)
end

private.ClassPowerRefresh = Update
private.AddElement("ClassPower", ClassPower)
