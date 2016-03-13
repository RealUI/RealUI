local _, private = ...
if private.RealUI.isBeta then return end

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

local ClassResourceBar = RealUI:GetModule("ClassResourceBar")
local Resolve = RealUI:GetModule("ClassResource_Resolve")

local MODNAME = "ClassResource_ResolveBar"
local ResolveBar = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local classes = {
    ["DRUID"] = true,
    ["PALADIN"] = true,
    ["WARRIOR"] = true,
}

local MinLevel = 10

---------------------------
---- Resolve Updates ----
---------------------------
function ResolveBar:UpdateAuras(units)
    --print("UpdateAuras", units)
    -- if units then
    --     for k, v in pairs(units) do
    --         --print(k, v)
    --     end
    -- end
    if units and not(units.player) then return end

    Resolve:UpdateCurrent()

    self.rBar:SetText("middle", RealUI:ReadableNumber(Resolve.current, 0))
    if Resolve.percent < 0.5 then
        self.rBar:SetValue("left", Resolve.percent * 2)
        self.rBar:SetValue("right", 0)
    else
        self.rBar:SetValue("right", (Resolve.percent - 0.5) * 2)
        self.rBar:SetValue("left", 1)
    end

    if ((Resolve.current > _G.floor(Resolve.base)) and not(self.rBar:IsShown())) or
        ((Resolve.current <= _G.floor(Resolve.base)) and self.rBar:IsShown()) then
            self:UpdateShown()
    end
end

function ResolveBar:UpdateShown()
    ResolveBar:debug("UpdateShown")

    if self.configMode then
        self.rBar:Show()
        return
    end

    if ( (Resolve.current and (Resolve.current > _G.floor(Resolve.base))) and not(_G.UnitIsDeadOrGhost("player")) and (_G.UnitLevel("player") >= MinLevel) ) then
        self.rBar:Show()
    else
        self.rBar:Hide()
    end
end

function ResolveBar:PLAYER_ENTERING_WORLD()
    self.guid = _G.UnitGUID("player")
    self:UpdateAuras()
    self:UpdateShown()
end

function ResolveBar:UpdateGlobalColors()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    self.rBar:SetBarColor("left", RealUI.media.colors.orange)
    self.rBar:SetBarColor("right", RealUI.media.colors.orange)
end

------------
function ResolveBar:ToggleConfigMode(val)
    ResolveBar:debug("ToggleConfigMode", val)
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    if self.configMode == val then return end

    self.configMode = val
    self:UpdateShown()
end

function ResolveBar:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {},
    })

    self:SetEnabledState(RealUI:GetModuleEnabled("PointTracking") and RealUI:GetModuleEnabled(MODNAME) and classes[RealUI.class] ~= nil)
    RealUI:RegisterConfigModeModule(self)
end

function ResolveBar:OnEnable()
    self.configMode = false

    if not self.rBar then 
        self.rBar = ClassResourceBar:New("short", L["Resource_Resolve"])
        self.rBar:SetEndBoxShown("left", false)
        self.rBar:SetEndBoxShown("right", false)
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
    self:RegisterEvent("PLAYER_UNGHOST", "UpdateShown")
    self:RegisterEvent("PLAYER_ALIVE", "UpdateShown")
    self:RegisterEvent("PLAYER_DEAD", "UpdateShown")
    self:RegisterEvent("PLAYER_LEVEL_UP", "UpdateShown")
    self:RegisterBucketEvent("UNIT_AURA", updateSpeed, "UpdateAuras")
end

function ResolveBar:OnDisable()
    self:UnregisterAllEvents()
    self:UnregisterAllBuckets()
end
