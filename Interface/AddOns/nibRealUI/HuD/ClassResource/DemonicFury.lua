local _, private = ...
if private.RealUI.isBeta then return end

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

local MODNAME = "ClassResource_DemonicFury"
local DemonicFury = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

local ClassResourceBar = RealUI:GetModule("ClassResourceBar")

local MetamorphosisSpellID = 103958
local MetamorphosisSpellName

------------------------------
---- Demonic Fury Updates ----
------------------------------
function DemonicFury:OnUpdate()
    -- Power Text
    local power = _G.UnitPower("player", _G.SPELL_POWER_DEMONIC_FURY)
    local maxPower = _G.UnitPowerMax("player", _G.SPELL_POWER_DEMONIC_FURY)
    
    if maxPower <= 0 or power > maxPower then
        return
    end

    local powerPer = power / maxPower
    
    if powerPer < 0.5 then
        self.dfBar:SetValue("left", powerPer * 2)
        self.dfBar:SetValue("right", 0)
    else
        self.dfBar:SetValue("right", (powerPer - 0.5) * 2)
        self.dfBar:SetValue("left", 1)
    end

    self.dfBar:SetText("middle", _G.abs(power))
end

function DemonicFury:UpdateShown(event, unit)
    if unit and unit ~= "player" then return end

    if self.configMode then
        self.dfBar:Show()
        return
    end

    if ( (_G.GetSpecialization() == 2) and _G.UnitExists("target") and _G.UnitCanAttack("player", "target") and not(_G.UnitIsDeadOrGhost("player")) and not(_G.UnitIsDeadOrGhost("target")) and not(_G.UnitInVehicle("player")) ) then
        self.dfBar:Show()
    else
        self.dfBar:Hide()
    end
end

function DemonicFury:UpdateAuras(units)
    if units and not(units.player) then return end

    -- Middle Arrow colors
    if _G.UnitBuff("player", MetamorphosisSpellName) then
        self.dfBar:SetBoxColor("middle", RealUI.media.colors.orange)
    else
        self.dfBar:SetBoxColor("middle", RealUI.classColor)
    end
end

function DemonicFury:PLAYER_ENTERING_WORLD()
    self:UpdateShown()
    self:UpdateAuras()
end

-----------------------
---- Frame Updates ----
-----------------------
function DemonicFury:UpdateGlobalColors()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    self.dfBar:SetBarColor("left", RealUI.media.colors.purple)
    self.dfBar:SetBarColor("right", RealUI.media.colors.purple)
    self:UpdateAuras()
end

------------
function DemonicFury:ToggleConfigMode(val)
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    if self.configMode == val then return end

    self.configMode = val
    self:UpdateShown()
end

function DemonicFury:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {},
    })
    
    self:SetEnabledState(RealUI:GetModuleEnabled("PointTracking") and RealUI:GetModuleEnabled(MODNAME) and RealUI.class == "WARLOCK")
    RealUI:RegisterConfigModeModule(self)
end

function DemonicFury:OnEnable()
    self.configMode = false

    MetamorphosisSpellName = _G.GetSpellInfo(MetamorphosisSpellID)

    if not self.dfBar then 
        self.dfBar = ClassResourceBar:New("short", L["Resource_DemonicFury"])
        self.dfBar:ReverseBar("left", true)
        self.dfBar:SetEndBoxShown("left", false)
        self.dfBar:SetEndBoxShown("right", false)
        self.dfBar:SetBoxColor("middle", RealUI.classColor)
    end
    self:UpdateGlobalColors()

    local updateSpeed
    if RealUI.db.profile.settings.powerMode == 1 then
        updateSpeed = 1/6
    elseif RealUI.db.profile.settings.powerMode == 2 then
        updateSpeed = 1/4
    else
        updateSpeed = 1/8
    end

    -- Events
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateShown")
    self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateShown")
    self:RegisterEvent("PLAYER_UNGHOST", "UpdateShown")
    self:RegisterEvent("PLAYER_ALIVE", "UpdateShown")
    self:RegisterEvent("PLAYER_DEAD", "UpdateShown")
    self:RegisterBucketEvent("UNIT_AURA", updateSpeed, "UpdateAuras")

    self.updateTimer = self:ScheduleRepeatingTimer("OnUpdate", updateSpeed)
end

function DemonicFury:OnDisable()
    self:UnregisterAllEvents()
    self:UnregisterAllBuckets()
    if self.updateTimer then self:CancelTimer(self.updateTimer) end
end
