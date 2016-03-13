local _, private = ...
if private.RealUI.isBeta then return end

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db

local MODNAME = "ClassResource_EclipseBar"
local EclipseBar = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

local ClassResourceBar = RealUI:GetModule("ClassResourceBar")

-------------------------
---- Eclipse Updates ----
-------------------------
function EclipseBar:OnUpdate(event, unit, powerType)
    --print("EclipseBar:OnUpdate", unit, powerType)
    if unit ~= "player" or powerType ~= "ECLIPSE" then return end
    -- Power Text
    local power = _G.UnitPower("player", _G.SPELL_POWER_ECLIPSE)
    local maxPower = _G.UnitPowerMax("player", _G.SPELL_POWER_ECLIPSE)
    --print("EclipseBar:Power", power, maxPower)
    
    if maxPower <= 0 or power > maxPower then
        return
    end

    --local status = GetEclipseDirection()
    if self.direction == "sun" then
        --print("EclipseBar:Sun", power)

        if power > 0 then
            self.eBar:SetValue("left", 0)
            self.eBar:SetValue("right", power / 100)
        else
            self.eBar:SetValue("right", 0)
            self.eBar:SetValue("left", 0)
            self:ECLIPSE_DIRECTION_CHANGE(event, _G.GetEclipseDirection())
        end

    elseif self.direction == "moon" then
        --print("EclipseBar:Moon", power)

        if power < 0 then
            self.eBar:SetValue("left", _G.abs(power / 100))
            self.eBar:SetValue("right", 0)
        else
            self.eBar:SetValue("right", 0)
            self.eBar:SetValue("left", 0)
            self:ECLIPSE_DIRECTION_CHANGE(event, _G.GetEclipseDirection())
        end

    else
        --print("EclipseBar:None", power)

        self.eBar:SetValue("left", 0)
        self.eBar:SetValue("right", 0)
        self:ECLIPSE_DIRECTION_CHANGE(event, _G.GetEclipseDirection())
    end

    self.eBar:SetText("middle", _G.abs(power))
end

function EclipseBar:UpdateAuras(units)
    if units and not(units.player) then return end

    -- Middle Arrow colors
    if self.direction == "sun" then
        self.eBar:SetBoxColor("middle", RealUI.media.colors.orange)

    elseif self.direction == "moon" then
        self.eBar:SetBoxColor("middle", RealUI.media.colors.blue)

    else
        self.eBar:SetBoxColor("middle", {0.2, 0.2, 0.2, 1})
    end
end

function EclipseBar:ECLIPSE_DIRECTION_CHANGE(event, ...)
    --print("EclipseBar", event, ...)
    self.direction = ...

    -- End Box colors and Bar colors
    if self.direction == "sun" then
        self.eBar:SetBoxColor("right", RealUI.media.colors.orange)
        self.eBar:SetBoxColor("left", RealUI.media.background)
    elseif self.direction == "moon" then
        self.eBar:SetBoxColor("right", RealUI.media.background)
        self.eBar:SetBoxColor("left", RealUI.media.colors.blue)
    else
        self.eBar:SetBoxColor("right", RealUI.media.colors.orange)
        self.eBar:SetBoxColor("left", RealUI.media.colors.blue)
        self.eBar:ReverseBar("left", false)
        self.eBar:ReverseBar("right", false)
    end
end

--------------------
---- Visibility ----
--------------------
function EclipseBar:UpdateVisibility(event, unit)
    if unit and unit ~= "player" then return end

    if self.configMode then
        self.eBar:Show()
        return
    end

    local targetCondition = (_G.UnitExists("target") and not(_G.UnitIsDeadOrGhost("target"))) and (db.visibility.showHostile and (_G.UnitIsEnemy("player", "target") or _G.UnitCanAttack("player", "target")))
    local pvpCondition = db.visibility.showPvP and self.inPvP
    local pveCondition = db.visibility.showPvE and self.inPvE
    local combatCondition = (db.visibility.showCombat and self.inCombat) or not(db.visibility.showCombat)

    local form = _G.GetShapeshiftFormID()
    if ((not(form) or (form and (form == _G.MOONKIN_FORM))) and (_G.GetSpecialization() == 1) and not(_G.UnitInVehicle("player")) and not(_G.UnitIsDeadOrGhost("player"))) and 
        (targetCondition or combatCondition or pvpCondition or pveCondition) then
            self.eBar:Show()
    else
        self.eBar:Hide()
    end
end

function EclipseBar:PLAYER_REGEN_DISABLED(event, ...)
    --print("EclipseBar", event, ...)
    self.inCombat = true
    self:UpdateVisibility()
end

function EclipseBar:PLAYER_REGEN_ENABLED(event, ...)
    --print("EclipseBar", event, ...)
    self.inCombat = false
    self:UpdateVisibility()
end

function EclipseBar:UpdatePlayerLocation()
    local Inst, InstType = _G.IsInInstance()
    if not(Inst and InstType) then
        self.inPvP = false
        self.inPvE = false
    elseif (InstType == "pvp") or (InstType == "arena") then
        self.inPvP = true
        self.inPvE = false
    elseif (InstType == "party") or (InstType == "raid") then
        self.inPvE = true
        self.inPvP = false
    end
end

function EclipseBar:PLAYER_ENTERING_WORLD(event, ...)
    --print("EclipseBar", event, ...)
    self:UpdatePlayerLocation()
    self:UpdateVisibility()
    self:UpdateAuras()
    self:OnUpdate(event, "player", "ECLIPSE")
end

-----------------------
---- Frame Updates ----
-----------------------
function EclipseBar:UpdateGlobalColors()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    self:ECLIPSE_DIRECTION_CHANGE()
end

------------
function EclipseBar:ToggleConfigMode(val)
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    if self.configMode == val then return end

    self.configMode = val
    self:UpdateVisibility()
end

function EclipseBar:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            visibility = {
                showCombat = true,
                showHostile = true,
                showPvP = true,
                showPvE = false,
            },
        },
    })
    db = self.db.profile
    
    self:SetEnabledState(RealUI:GetModuleEnabled("PointTracking") and RealUI:GetModuleEnabled(MODNAME) and RealUI.class == "DRUID")
    RealUI:RegisterConfigModeModule(self)
end

function EclipseBar:OnEnable()
    self.configMode = false

    if not self.eBar then 
        self.eBar = ClassResourceBar:New("short", L["Resource_Eclipse"])
    end

    local updateSpeed
    if RealUI.db.profile.settings.powerMode == 1 then
        updateSpeed = 1/8
    elseif RealUI.db.profile.settings.powerMode == 2 then
        updateSpeed = 1/5
    else
        updateSpeed = 1/10
    end

    -- Events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "UpdateVisibility")
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateVisibility")
    self:RegisterEvent("MASTERY_UPDATE", "UpdateVisibility")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateVisibility")
    self:RegisterEvent("PLAYER_UNGHOST", "UpdateVisibility")
    self:RegisterEvent("PLAYER_ALIVE", "UpdateVisibility")
    self:RegisterEvent("PLAYER_DEAD", "UpdateVisibility")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:RegisterBucketEvent("UNIT_AURA", updateSpeed, "UpdateAuras")
    self:RegisterEvent("UNIT_POWER_FREQUENT", "OnUpdate")
    --self:RegisterEvent("ECLIPSE_DIRECTION_CHANGE")
end

function EclipseBar:OnDisable()
    self:UnregisterAllEvents()
    self:UnregisterAllBuckets()
end
