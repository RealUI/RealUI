local ADDON_NAME, private = ...

-- Clean-room nameplate addon. Safety rules (Aurora Blizzard_NamePlates + oUF-14 findings):
-- hooksecurefunc only, IsForbidden before touching Blizzard frames, no SetAttribute,
-- pcall around any plate/aura read that feeds arithmetic (secret values in BGs / rated PvP).

local NP = _G.LibStub("AceAddon-3.0"):NewAddon("RealUI_Nameplates", "AceEvent-3.0")
private.NP = NP

--[[ Safety helpers ]]--

-- pcall-guarded forbidden check: secure-env frames can throw on IsForbidden itself
-- (LibStrataFix incident).
function private.IsAccessible(frame)
    if not frame then return false end
    local ok, forbidden = _G.pcall(frame.IsForbidden, frame)
    return ok and not forbidden
end

-- Run fn in pcall; returns its results on success, nil on error (secret value hit).
function private.Safe(fn, ...)
    local ok, a, b, c, d = _G.pcall(fn, ...)
    if ok then return a, b, c, d end
end

-- Like Safe, but returns whether the call succeeded (for APIs that return nothing).
function private.Try(fn, ...)
    return (_G.pcall(fn, ...))
end

-- Truth-test fn's result inside pcall; false when the test throws (secret value).
-- Secret BOOLEANS throw on truth tests (unlike secret strings/numbers), so any
-- condition built on combat-API booleans goes through here.
function private.SafeTest(fn, ...)
    local ok, result = _G.pcall(fn, ...)
    if ok and result then return true end
    return false
end

-- Resolve a possibly-secret boolean to plain true/false, or nil if inaccessible.
function private.SafeBool(value)
    if value == nil then return nil end
    if _G.canaccessvalue then
        if _G.canaccessvalue(value) then
            return value and true or false
        end
        return nil
    end
    local ok, result = _G.pcall(function() return value and true or false end)
    if ok then return result end
end

--[[ Element registry ]]--

local elements = {}
private.elements = elements

-- Element contract: { Create(plate), Attach(plate, unit), Detach(plate) [, OnTick(plate, elapsed)] }
function private.AddElement(name, element)
    elements[name] = element
end

local function ForEachElement(method, plate, ...)
    for _, element in _G.next, elements do
        if element[method] then element[method](plate, ...) end
    end
end

--[[ Plate pool ]]--

local platePool = {}
local activeByUnit = {}   -- unit token -> plate
local activeByBase = {}   -- Blizzard base frame -> plate, or FILTERED marker
local filteredUnits = {}  -- unit token -> base frame (visibility-filtered, no plate)
local FILTERED = "filtered"
private.activeByUnit = activeByUnit

local plateCount = 0
local function CreatePlate()
    plateCount = plateCount + 1
    local plate = _G.CreateFrame("Frame", "RealUI_NP_Plate"..plateCount, _G.UIParent)
    plate:Hide()
    plate.elements = {}
    plate.state = {}
    ForEachElement("Create", plate)
    return plate
end

local function AcquirePlate()
    local plate = _G.next(platePool)
    if plate then
        platePool[plate] = nil
    else
        plate = CreatePlate()
    end
    return plate
end

--[[ Blizzard UnitFrame suppression ]]--

local suppressedUnitFrames = {}
local function OnUnitFrameShow(unitFrame)
    if not private.IsAccessible(unitFrame) then return end
    local parent = private.Safe(unitFrame.GetParent, unitFrame)
    if parent and activeByBase[parent] then
        unitFrame:Hide()
    end
end

local function SuppressUnitFrame(base)
    local unitFrame = base.UnitFrame
    if not private.IsAccessible(unitFrame) then return end
    unitFrame:Hide()
    if not suppressedUnitFrames[unitFrame] then
        suppressedUnitFrames[unitFrame] = true
        _G.hooksecurefunc(unitFrame, "Show", OnUnitFrameShow)
    end
end

--[[ Design selection and visibility filter ]]--

local function SelectDesign(unit)
    if _G.UnitCanAttack("player", unit) then
        return "enemy"
    end
    return "friendly"
end

local function PassesVisibility(unit, design)
    if design == "enemy" then return true end
    local db = NP.db.profile.friendly
    if not db.showInInstances then
        local inInstance = _G.IsInInstance()
        if inInstance then return false end
    end
    return true
end

--[[ Attach / detach ]]--

local function AttachPlate(unit)
    if activeByUnit[unit] then return end
    if _G.UnitIsUnit(unit, "player") then return end  -- personal resource display: out of scope

    local base = _G.C_NamePlate.GetNamePlateForUnit(unit)
    if not private.IsAccessible(base) then return end

    SuppressUnitFrame(base)

    local design = SelectDesign(unit)
    if not PassesVisibility(unit, design) then
        -- Blizzard art stays suppressed; we render nothing for filtered units.
        activeByBase[base] = FILTERED
        filteredUnits[unit] = base
        return
    end

    local plate = AcquirePlate()
    plate.unit = unit
    plate.base = base
    plate.design = design
    _G.wipe(plate.state)

    plate:SetParent(base)  -- inherits Blizzard's occlusion alpha (nameplateOccludedAlphaMult)
    plate:ClearAllPoints()
    plate:SetPoint("CENTER", base, "CENTER", 0, 0)
    local health = NP.db.profile.enemy.health
    plate:SetSize(health.width, health.height)

    activeByUnit[unit] = plate
    activeByBase[base] = plate

    ForEachElement("Attach", plate, unit)
    NP:UpdatePlateAlpha(plate)
    plate:Show()
    NP:StartTicker()
end

local function DetachPlate(unit)
    local filteredBase = filteredUnits[unit]
    if filteredBase then
        filteredUnits[unit] = nil
        activeByBase[filteredBase] = nil
    end

    local plate = activeByUnit[unit]
    activeByUnit[unit] = nil
    if not plate then return end

    activeByBase[plate.base] = nil
    ForEachElement("Detach", plate)
    plate:Hide()
    plate:ClearAllPoints()
    plate:SetParent(_G.UIParent)
    plate.unit, plate.base, plate.design = nil, nil, nil
    platePool[plate] = true

    if not _G.next(activeByUnit) then NP:StopTicker() end
end

--[[ Alpha state machine ]]--
-- Occlusion comes free from the parent chain; we multiply our own states on top.

local rangeChecker
local function UpdateRangeChecker()
    local lrc = _G.LibStub and _G.LibStub("LibRangeCheck-3.0", true)
    if lrc then
        rangeChecker = lrc:GetHarmMaxChecker(40)
    end
end

function NP:UpdatePlateAlpha(plate)
    local unit = plate.unit
    if not unit then return end
    local db = self.db.profile.alpha

    -- The current target is always full alpha — no combat/range/target dimming
    -- (beta feedback: target plates stayed dimmed until combat started).
    if _G.UnitExists("target") and _G.UnitIsUnit(unit, "target") then
        plate:SetAlpha(1)
        return
    end

    local alpha = 1

    if plate.design == "enemy" then
        -- Combat/range results can be secret booleans; failed tests leave alpha as-is.
        if private.SafeTest(function() return not _G.UnitAffectingCombat(unit) end) then
            alpha = alpha * db.noCombat
        end
        if rangeChecker and private.SafeTest(function() return not rangeChecker(unit) end) then
            alpha = alpha * db.outOfRange
        end
    end
    if _G.UnitExists("target") and not _G.UnitIsUnit(unit, "target") then
        alpha = alpha * db.notTarget
    end
    if plate.state.casting then
        alpha = _G.math.max(alpha, db.casting * (_G.UnitExists("target") and _G.UnitIsUnit(unit, "target") and 1 or db.notTarget))
    end

    plate:SetAlpha(alpha)
end

local function UpdateAllAlphas()
    for _, plate in _G.next, activeByUnit do
        NP:UpdatePlateAlpha(plate)
    end
end

--[[ Shared ticker: 0.1s for aura countdowns, every 3rd tick for range/alpha ]]--

local tickCounter = 0
function NP:StartTicker()
    if self.ticker then return end
    self.ticker = _G.C_Timer.NewTicker(0.1, function()
        tickCounter = tickCounter + 1
        local doSlow = (tickCounter % 3 == 0)
        for _, plate in _G.next, activeByUnit do
            ForEachElement("OnTick", plate, doSlow)
        end
        if doSlow then UpdateAllAlphas() end
    end)
end

function NP:StopTicker()
    if self.ticker then
        self.ticker:Cancel()
        self.ticker = nil
    end
end

--[[ Event routing ]]--

local unitEvents = {}   -- event -> element method name
function private.RegisterUnitEvent(event, method)
    unitEvents[event] = method
    NP:RegisterEvent(event, "OnUnitEvent")
end

function NP:OnUnitEvent(event, unit, ...)
    local plate = unit and activeByUnit[unit]
    if not plate then return end
    local method = unitEvents[event]
    for _, element in _G.next, elements do
        if element[method] then element[method](plate, event, ...) end
    end
    self:UpdatePlateAlpha(plate)
end

function NP:NAME_PLATE_UNIT_ADDED(_, unit)
    AttachPlate(unit)
end

function NP:NAME_PLATE_UNIT_REMOVED(_, unit)
    DetachPlate(unit)
end

function NP:PLAYER_TARGET_CHANGED()
    UpdateAllAlphas()
    for _, plate in _G.next, activeByUnit do
        ForEachElement("OnTargetChanged", plate)
    end
end

function NP:RAID_TARGET_UPDATE()
    for _, plate in _G.next, activeByUnit do
        ForEachElement("OnRaidTargetUpdate", plate)
    end
end

local function CombatChanged()
    UpdateAllAlphas()
    for _, plate in _G.next, activeByUnit do
        ForEachElement("OnCombatChanged", plate)
    end
end

--[[ Lifecycle ]]--

function NP:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_NameplatesDB", private.defaults, true)
end

function NP:OnEnable()
    -- Platynator coexistence: never fight another nameplate addon over the plates.
    if _G.C_AddOns.IsAddOnLoaded("Platynator") then
        _G.print("|cff30d0ffRealUI Nameplates|r: disabled — Platynator is handling nameplates.")
        self:Disable()
        return
    end

    UpdateRangeChecker()

    self:RegisterEvent("NAME_PLATE_UNIT_ADDED")
    self:RegisterEvent("NAME_PLATE_UNIT_REMOVED")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("RAID_TARGET_UPDATE")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", CombatChanged)
    self:RegisterEvent("PLAYER_REGEN_DISABLED", CombatChanged)
    self:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", UpdateRangeChecker)

    for _, element in _G.next, elements do
        if element.OnEnable then element.OnEnable() end
    end

    -- Late-load catch-up for plates that already exist.
    for _, base in _G.next, _G.C_NamePlate.GetNamePlates() do
        local unit = private.IsAccessible(base) and base.namePlateUnitToken
        if unit then AttachPlate(unit) end
    end
end

function NP:OnDisable()
    self:StopTicker()
    for unit in _G.next, activeByUnit do
        DetachPlate(unit)
    end
end

--[[ Slash ]]--

_G.SLASH_REALUINAMEPLATES1 = "/rnp"
_G.SLASH_REALUINAMEPLATES2 = "/realuinameplates"
_G.SlashCmdList.REALUINAMEPLATES = function()
    if private.OpenConfig then
        private.OpenConfig()
    else
        _G.print("|cff30d0ffRealUI Nameplates|r: config requires AceConfig (load RealUI_Config or any Ace3 config addon).")
    end
end
