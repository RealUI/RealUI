local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI

local MODNAME = "CombatFader"
local CombatFader = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local LoggedIn = false
local FirstLog = true

local FADE_TIME = 0.20
local status = "incombat"
local modules = {}

local function isPowerRested(token)
    if RealUI.ReversePowers[token] then
        return _G.UnitPower("player") == 0
    else
        return _G.UnitPower("player") == _G.UnitPowerMax("player")
    end
end

-- Fade frame
local function FadeIt(self, newOpacity, instant)
    CombatFader:debug("FadeIt", newOpacity, instant)
    if self.realUIHidden then return end
    local currentOpacity = self:GetAlpha()
    local fadeTime = instant and 0 or FADE_TIME
    if newOpacity > currentOpacity then
        _G.UIFrameFadeIn(self, fadeTime, currentOpacity, newOpacity)
    elseif newOpacity < currentOpacity and self:IsShown() then
        _G.UIFrameFadeOut(self, fadeTime, currentOpacity, newOpacity)
    end
end
CombatFader.FadeIt = FadeIt

-- Determine new opacity values for frames
function CombatFader:FadeFrames()
    self:debug("FadeFrames")
    for modName, module in next, modules do
        local options = module.options
        if options.enabled then
            -- Retrieve opacity for current status
            local newOpacity = options.opacity[status]

            -- do fade
            for i = 1, #module.frames do
                local frame = module.frames[i]
                self:debug("do fade", modName, status, newOpacity, frame.special)
                if frame.special and (status ~= "target" and status ~= "harmtarget" and status ~= "incombat" or not newOpacity) then
                    -- frame.special is equal to "harm", but allows for just that frame to change
                    newOpacity = frame.special
                end
                FadeIt(frame, newOpacity or options.opacity.outofcombat)
            end
        end
    end
end

-- Update current status
function CombatFader:UpdateStatus(force)
    self:debug("UpdateStatus", force)
    local OldStatus = status
    local _, powerToken = _G.UnitPowerType("player")
    if _G.UnitAffectingCombat("player") then
        status = "incombat"                 -- InCombat - Priority 1
    elseif _G.UnitExists("target") then
        if _G.UnitCanAttack("player", "target") then
            status = "harmtarget"           -- HarmTarget - Priority 2
        else
            status = "target"               -- Target - Priority 3
        end
    elseif (_G.UnitHealth("player") < _G.UnitHealthMax("player")) or not isPowerRested(powerToken) then
        status = "hurt"                     -- Hurt - Priority 4
    else
        status = "outofcombat"          -- OutOfCombat - Priority 5
    end
    if force or status ~= OldStatus then self:FadeFrames() end  
end

function CombatFader:HurtEvent(units)
    if units and units.player then self:UpdateStatus() end
end

-- On combat state change
function CombatFader:UpdateCombatState(event)
    -- If in combat, then don't worry about health/power events
    if _G.UnitAffectingCombat("player") and not FirstLog then
        self:UnregisterAllBuckets()
    else
        self:RegisterBucketEvent({"UNIT_HEALTH", "UNIT_POWER", "UNIT_DISPLAYPOWER"}, 0.1, "HurtEvent")
        if event == "PLAYER_REGEN_DISABLED" or event == "PLAYER_REGEN_ENABLED" then
            FirstLog = false
        end
    end
    self:UpdateStatus(true)
end

----
function CombatFader:RefreshMod()
    status = nil
    self:UpdateStatus(true)
end

function CombatFader:PLAYER_TARGET_CHANGED()
    self:UpdateStatus()
end

function CombatFader:PLAYER_ENTERING_WORLD()
    LoggedIn = true

    self:UpdateCombatState()
end

--- Register a module to fade based on combat state.
-- @param mod The name of the mod registering
-- @param options A table detailing what level of opacity for each state.
function CombatFader:RegisterModForFade(mod, options)
    modules[mod] = {
        options = options,
        frames = {},
    }
end
--- Register a frame to fade based on combat state.
-- @param mod The name of the mod it belongs to
-- @param frame The frame to be registered
function CombatFader:RegisterFrameForFade(mod, frame)
    _G.assert(modules[mod], mod.." has not yet been registered.")
    _G.tinsert(modules[mod].frames, frame)
    CombatFader:RefreshMod()
end

function CombatFader:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
        },
    })
end

function CombatFader:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("PLAYER_TARGET_CHANGED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateCombatState")
    self:RegisterEvent("PLAYER_REGEN_DISABLED", "UpdateCombatState")
    self:UpdateCombatState()
    
    if LoggedIn then self:RefreshMod() end
end

function CombatFader:OnDisable()
    self:UnregisterAllEvents()
    self:UnregisterAllBuckets()
end
