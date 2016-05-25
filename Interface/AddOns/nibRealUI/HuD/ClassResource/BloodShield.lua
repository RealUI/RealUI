local _, private = ...
if private.RealUI.isBeta then return end

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

local MODNAME = "ClassResource_BloodShield"
local BloodShield = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local ClassResourceBar = RealUI:GetModule("ClassResourceBar")
local Resolve = RealUI:GetModule("ClassResource_Resolve")

local BloodShieldID = 77535
local BloodShieldName
local MinLevel = 10

-----------------
---- Updates ----
-----------------
function BloodShield:UpdateAuras(event, units)
    if units and not(units.player) then return end

    -- Blood Shield
    local _,_,_,_,_,_,_,_,_,_,spellID,_,_,_, absorb = _G.UnitAura("player", BloodShieldName)
    if ( spellID == BloodShieldID ) then 
        self.curBloodAbsorb = absorb
    else
        self.curBloodAbsorb = 0
    end

    local bloodPer = RealUI.Clamp(self.curBloodAbsorb / self.maxBlood, 0, 1)
    self.bsBar:SetValue("left", bloodPer)
    self.bsBar:SetText("left", RealUI:ReadableNumber(self.curBloodAbsorb, 0))

    if bloodPer > 0 then
        self.bsBar:SetBoxColor("left", RealUI.media.colors.red)
    else
        self.bsBar:SetBoxColor("left", RealUI.media.background)
    end

    -- Resolve
    if event ~= "CLEU" then
        Resolve:UpdateCurrent()

        self.bsBar:SetValue("right", Resolve.percent)
        self.bsBar:SetText("right", RealUI:ReadableNumber(Resolve.current, 0))
        if Resolve.percent > 0 then
            self.bsBar:SetBoxColor("right", RealUI.media.colors.orange)
        else
            self.bsBar:SetBoxColor("right", RealUI.media.background)
        end
    end

    -- Update visibility
    if (((self.curBloodAbsorb > 0) or (Resolve.current > Resolve.base)) and not(self.bsBar:IsShown())) or
        (((self.curBloodAbsorb <= 0) or (Resolve.current <= Resolve.base)) and self.bsBar:IsShown()) then
            self:UpdateShown()
    end
end

function BloodShield:CLEU(event, ...)
    local _, cEvent, _,_,_,_,_, destGUID, _,_,_, spellID = ...

    if ( (destGUID == self.guid) and (cEvent == "SPELL_AURA_REMOVED") and (spellID == BloodShieldID) ) then
        self:UpdateAuras("CLEU")
    end
end

function BloodShield:UpdateMax(event, unit)
    if (unit and (unit ~= "player")) then
        return
    end
    
    self.maxBlood = _G.UnitHealthMax("player")
    self:UpdateAuras()
end

function BloodShield:UpdateShown(event, unit)
    if unit and unit ~= "player" then return end

    if self.configMode then
        self.bsBar:Show()
        return
    end

    if ( (_G.GetSpecialization() == 1) and ((Resolve.current and (Resolve.current > Resolve.base)) or 
      (self.curBloodAbsorb and (self.curBloodAbsorb > 0))) and not(_G.UnitIsDeadOrGhost("player")) and (_G.UnitLevel("player") >= MinLevel) ) then
        self.bsBar:Show()
    else
        self.bsBar:Hide()
    end
end

function BloodShield:PLAYER_ENTERING_WORLD()
    self.guid = _G.UnitGUID("player")
    self:UpdateAuras()
    self:UpdateShown()
end

-----------------------
---- Frame Updates ----
-----------------------
function BloodShield:UpdateGlobalColors()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    self.bsBar:SetBarColor("left", RealUI.media.colors.red)
    self.bsBar:SetBarColor("right", RealUI.media.colors.orange)
    self:UpdateAuras()
end

------------
function BloodShield:ToggleConfigMode(val)
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    if self.configMode == val then return end

    self.configMode = val
    self:UpdateShown()
end

function BloodShield:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {},
    })
    
    self:SetEnabledState(RealUI:GetModuleEnabled("PointTracking") and RealUI:GetModuleEnabled(MODNAME) and RealUI.class == "DEATHKNIGHT")
    RealUI:RegisterConfigModeModule(self)
end

function BloodShield:OnEnable()
    self.configMode = false

    BloodShieldName = _G.GetSpellInfo(BloodShieldID)

    if not self.bsBar then 
        self.bsBar = ClassResourceBar:New("long", L["Resource_BloodShield"])
        self.bsBar:SetBoxColor("middle", RealUI.classColor)
    end
    self:UpdateMax()
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
    self:RegisterEvent("PLAYER_UNGHOST", "UpdateShown")
    self:RegisterEvent("PLAYER_ALIVE", "UpdateShown")
    self:RegisterEvent("PLAYER_DEAD", "UpdateShown")
    self:RegisterEvent("PLAYER_LEVEL_UP", "UpdateShown")
    self:RegisterEvent("UNIT_MAXHEALTH", "UpdateMax")
    self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CLEU")
    self:RegisterBucketEvent({"UNIT_AURA", "UNIT_ABSORB_AMOUNT_CHANGED"}, updateSpeed, "UpdateAuras")
end

function BloodShield:OnDisable()
    self:UnregisterAllEvents()
    self:UnregisterAllBuckets()
end
