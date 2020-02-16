local _, private = ...

-- Lua Globals --
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

local MODNAME = "CombatFader"
local CombatFader = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

-- TODO: refactor this to use SecureHandlerStateTemplate
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
        local options = RealUI.GetOptions(modName, module.path)
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
        self:RegisterBucketEvent({"UNIT_HEALTH", "UNIT_POWER_UPDATE", "UNIT_DISPLAYPOWER"}, 0.1, "HurtEvent")
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
function CombatFader:RegisterModForFade(mod, ...)
    modules[mod] = {
        path = {...},
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

local keyOrder = {
    "incombat",
    "harmtarget",
    "target",
    "hurt",
    "outofcombat",
}
local keyList = {
    incombat = L["CombatFade_InCombat"],
    hurt = L["CombatFade_Hurt"],
    harmtarget = L["CombatFade_HarmTarget"],
    target = L["CombatFade_Target"],
    outofcombat = L["CombatFade_NoCombat"],
}
function CombatFader:AddFadeConfig(mod, configDB, startOrder, inline)
    if not RealUI:GetModuleEnabled(mod) then return end
    _G.assert(modules[mod], mod.." has not yet been registered.")

    local args = {}
    for order, key in next, keyOrder do
        args[key] = {
            name = keyList[key],
            type = "range",
            isPercent = true,
            min = 0, max = 1, step = 0.05,
            get = function(info) return RealUI.GetOptions(mod, modules[mod].path).opacity[key] end,
            set = function(info, value)
                RealUI.GetOptions(mod, modules[mod].path).opacity[key] = value
                CombatFader:RefreshMod()
            end,
            order = order,
        }
    end

    configDB.args.fadeConfig = {
        name = L["CombatFade"],
        type = "group",
        inline = inline,
        order = startOrder,
        args = {
            enable = {
                name = L["General_Enabled"],
                desc = L["General_EnabledDesc"]:format(L["CombatFade"]),
                type = "toggle",
                get = function(info) return RealUI.GetOptions(mod, modules[mod].path).enabled end,
                set = function(info, value)
                    RealUI.GetOptions(mod, modules[mod].path).enabled = value
                    CombatFader:RefreshMod()
                end,
                order = 1,
            },
            config = {
                name = "",
                type = "group",
                inline = true,
                disabled = function() return not RealUI.GetOptions(mod, modules[mod].path).enabled end,
                order = 30,
                args = args,
            }
        }
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
