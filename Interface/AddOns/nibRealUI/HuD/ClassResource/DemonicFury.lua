local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "ClassResource_DemonicFury"
local DemonicFury = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

local ClassResourceBar = nibRealUI:GetModule("ClassResourceBar")

local MetamorphosisSpellID = 103958
local MetamorphosisSpellName

-- Options
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Demonic Fury",
        desc = "Warlock Demonic Fury tracker.",
        arg = MODNAME,
        childGroups = "tab",
        args = {
            header = {
                type = "header",
                name = "Demonic Fury",
                order = 10,
            },
            desc = {
                type = "description",
                name = "Warlock Demonic Fury tracker.",
                fontSize = "medium",
                order = 20,
            },
            enabled = {
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the Demonic Fury module.",
                get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value) 
                    nibRealUI:SetModuleEnabled(MODNAME, value)
                end,
                order = 30,
            },
        },
    }
    end
    return options
end

------------------------------
---- Demonic Fury Updates ----
------------------------------
function DemonicFury:OnUpdate()
    -- Power Text
    local power = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
    local maxPower = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)
    
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

    self.dfBar:SetText("middle", abs(power))
end

function DemonicFury:UpdateShown(event, unit)
    if unit and unit ~= "player" then return end

    if self.configMode then
        self.dfBar:Show()
        return
    end

    if ( (GetSpecialization() == 2) and UnitExists("target") and UnitCanAttack("player", "target") and not(UnitIsDeadOrGhost("player")) and not(UnitIsDeadOrGhost("target")) and not(UnitInVehicle("player")) ) then
        self.dfBar:Show()
    else
        self.dfBar:Hide()
    end
end

function DemonicFury:UpdateAuras(units)
    if units and not(units.player) then return end

    -- Middle Arrow colors
    if UnitBuff("player", MetamorphosisSpellName) then
        self.dfBar:SetBoxColor("middle", nibRealUI.media.colors.orange)
    else
        self.dfBar:SetBoxColor("middle", nibRealUI.classColor)
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
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end
    if nibRealUI.class ~= "WARLOCK" then return end

    self.dfBar:SetBarColor("left", nibRealUI.media.colors.purple)
    self.dfBar:SetBarColor("right", nibRealUI.media.colors.purple)
    self:UpdateAuras()
end

------------
function DemonicFury:ToggleConfigMode(val)
    if not nibRealUI:GetModuleEnabled(MODNAME) then return end
    if nibRealUI.class ~= "WARLOCK" then return end
    if self.configMode == val then return end

    self.configMode = val
    self:UpdateShown()
end

function DemonicFury:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {},
    })
    db = self.db.profile
    ndb = nibRealUI.db.profile
    
    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterHuDOptions(MODNAME, GetOptions, "ClassResource")
    nibRealUI:RegisterConfigModeModule(self)
end

function DemonicFury:OnEnable()
    if nibRealUI.class ~= "WARLOCK" then return end

    self.configMode = false

    MetamorphosisSpellName = GetSpellInfo(MetamorphosisSpellID)

    if not self.dfBar then 
        self.dfBar = ClassResourceBar:New("short")
        self.dfBar:SetEndBoxShown("left", false)
        self.dfBar:SetEndBoxShown("right", false)
        self.dfBar:SetBoxColor("middle", nibRealUI.classColor)
    end
    self:UpdateGlobalColors()

    local updateSpeed
    if nibRealUI.db.profile.settings.powerMode == 1 then
        updateSpeed = 1/6
    elseif nibRealUI.db.profile.settings.powerMode == 2 then
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
