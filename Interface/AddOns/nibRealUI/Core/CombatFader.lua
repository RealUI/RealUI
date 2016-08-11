local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

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

function CombatFader:AddFadeConfig(mod, configDB, startOrder)
    if not modules[mod] then return end
    local modDB = modules[mod].options
    configDB.args.fadeHeader = {
        name = L["CombatFade"],
        type = "header",
        order = startOrder,
    }
    configDB.args.fadeEnable = {
        name = L["General_Enabled"],
        desc = L["General_EnabledDesc"]:format(L["CombatFade"]),
        type = "toggle",
        get = function(info) return modDB.enabled end,
        set = function(info, value)
            modDB.enabled = value
            CombatFader:RefreshMod()
        end,
        order = startOrder + 1,
    }
    configDB.args.fadeConfig = {
        name = "",
        type = "group",
        inline = true,
        disabled = function() return not modDB.enabled end,
        order = startOrder + 5,
        args = {
            incombat = {
                name = L["CombatFade_InCombat"],
                type = "range",
                isPercent = true,
                min = 0, max = 1, step = 0.05,
                get = function(info) return modDB.opacity.incombat end,
                set = function(info, value)
                    modDB.opacity.incombat = value
                    CombatFader:RefreshMod()
                end,
                order = 10,
            },
            hurt = {
                name = L["CombatFade_Hurt"],
                type = "range",
                isPercent = true,
                min = 0, max = 1, step = 0.05,
                get = function(info) return modDB.opacity.hurt end,
                set = function(info, value)
                    modDB.opacity.hurt = value
                    CombatFader:RefreshMod()
                end,
                order = 20,
            },
            target = {
                name = L["CombatFade_Target"],
                type = "range",
                isPercent = true,
                min = 0, max = 1, step = 0.05,
                get = function(info) return modDB.opacity.target end,
                set = function(info, value)
                    modDB.opacity.target = value
                    modDB.opacity.harmtarget = value
                    CombatFader:RefreshMod()
                end,
                order = 30,
            },
            outofcombat = {
                name = L["CombatFade_NoCombat"],
                type = "range",
                isPercent = true,
                min = 0, max = 1, step = 0.05,
                get = function(info) return modDB.opacity.outofcombat end,
                set = function(info, value)
                    modDB.opacity.outofcombat = value
                    CombatFader:RefreshMod()
                end,
                order = 40,
            },
        },
    }
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
