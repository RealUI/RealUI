local _, private = ...
if private.RealUI.isBeta then return end

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

local ClassResourceBar = RealUI:GetModule("ClassResourceBar")
local Resolve = RealUI:GetModule("ClassResource_Resolve")

local MODNAME = "ClassResource_Stagger"
local Stagger = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local MinLevel = 10
local maxHealth

-----------------
---- Updates ----
-----------------
function Stagger:UpdateAuras(units)
    --print("UpdateAuras", units)
    -- if units then
    --  for k, v in pairs(units) do
    --      --print(k, v)
    --  end
    -- end
    if units and not(units.player) then return end

    -- Stagger
    self.curStagger = _G.UnitStagger("player")
    self.percent = self.curStagger / maxHealth
    self.staggerLevel = 1

    local staggerPer = RealUI.Clamp(self.percent, 0, 1/5) * 5
    self.sBar:SetValue("left", staggerPer)
    self.sBar:SetText("left", RealUI:ReadableNumber(self.curStagger, 0))

    if (self.percent > _G.STAGGER_YELLOW_TRANSITION and self.percent < _G.STAGGER_RED_TRANSITION) then
        --Moderate
        self.sBar:SetBoxColor("left", RealUI.media.colors.yellow)
        self.sBar:SetBarColor("left", RealUI.media.colors.yellow)
    elseif (self.percent > _G.STAGGER_RED_TRANSITION) then
        --Heavy
        self.sBar:SetBoxColor("left", RealUI.media.colors.red)
        self.sBar:SetBarColor("left", RealUI.media.colors.red)
    else
        --Light
        self.sBar:SetBoxColor("left", RealUI.media.colors.green)
        self.sBar:SetBarColor("left", RealUI.media.colors.green)
    end

    -- Resolve
    Resolve:UpdateCurrent()
    
    self.sBar:SetValue("right", Resolve.percent)
    self.sBar:SetText("right", RealUI:ReadableNumber(Resolve.current, 0))

    if Resolve.percent > 0 then
        self.sBar:SetBoxColor("right", RealUI.media.colors.orange)
    else
        self.sBar:SetBoxColor("right", RealUI.media.background)
    end

    -- Update visibility
    if (((self.curStagger > 0) or (Resolve.current > _G.floor(Resolve.base))) and not(self.sBar:IsShown())) or
        (((self.curStagger <= 0) or (Resolve.current <= _G.floor(Resolve.base))) and self.sBar:IsShown()) then
            self:UpdateShown()
    end
end

function Stagger:UpdateMax(event, unit)
    --print("UpdateMax", event, unit)
    if (unit and (unit ~= "player")) then
        return
    end
    
    maxHealth = _G.UnitHealthMax("player")
    self:UpdateAuras()
end

function Stagger:UpdateShown(event, unit)
    --print("UpdateShown")
    if unit and unit ~= "player" then return end

    if self.configMode then
        self.sBar:Show()
        return
    end

    if ( (_G.GetSpecialization() == 1) and ((Resolve.current and (Resolve.current > _G.floor(Resolve.base))) or (self.curStagger and (self.curStagger > 0))) and not(_G.UnitIsDeadOrGhost("player")) and (_G.UnitLevel("player") >= MinLevel) ) then
        self.sBar:Show()
    else
        self.sBar:Hide()
    end
end

function Stagger:PLAYER_ENTERING_WORLD()
    self.guid = _G.UnitGUID("player")
    self:UpdateAuras()
    self:UpdateShown()
end

function Stagger:UpdateGlobalColors()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    self.sBar:SetBarColor("right", RealUI.media.colors.orange)
    self:UpdateAuras()
end

------------
function Stagger:ToggleConfigMode(val)
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    if self.configMode == val then return end

    self.configMode = val
    self:UpdateShown()
end

function Stagger:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {},
    })
    
    self:SetEnabledState(RealUI:GetModuleEnabled("PointTracking") and RealUI:GetModuleEnabled(MODNAME) and RealUI.class == "MONK")
    RealUI:RegisterConfigModeModule(self)
end

function Stagger:OnEnable()
    self.configMode = false

    if not self.sBar then 
        self.sBar = ClassResourceBar:New("long", L["Resource_Stagger"])
        self.sBar:SetBoxColor("middle", RealUI.classColor)
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
    self:RegisterBucketEvent({"UNIT_DISPLAYPOWER", "UNIT_AURA", "UNIT_ABSORB_AMOUNT_CHANGED"}, updateSpeed, "UpdateAuras")
end

function Stagger:OnDisable()
    self:UnregisterAllEvents()
    self:UnregisterAllBuckets()
end
