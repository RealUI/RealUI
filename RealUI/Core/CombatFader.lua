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

-- Frames whose alpha CombatFader leaves alone (CombatFader:SetFrameHidden).
-- Weak keys, so nothing is ever written onto a frame.
local hiddenFrames = _G.setmetatable({}, {__mode = "k"})

--[[ tracker-widget-taint-rewrite 5.3: CombatFader runs its own alpha tween.
     Blizzard's UIFrameFadeIn/Out write `fadeInfo` onto the frame and call
     frame:Show() (Blizzard_SharedXMLBase/FrameUtil.lua:331-333). On a Blizzard
     frame (RealUI_Tracker registers ObjectiveTrackerFrame) that is a plant,
     and the Show() runs the frame's OnShow inside RealUI's execution, which
     for the tracker is Blizzard's layout. This tween only ever calls SetAlpha,
     and it never shows a hidden frame (the old fade-in did, which is why
     ClassResource needed its `realUIHidden` flag). ]]
local fades = _G.setmetatable({}, {__mode = "k"}) -- frame -> {from, to, elapsed}
local fadeDriver = _G.CreateFrame("Frame")
local function FadeDriver_OnUpdate(driver, elapsed)
    local active = false
    for frame, fade in next, fades do
        fade.elapsed = fade.elapsed + elapsed
        if fade.elapsed >= FADE_TIME then
            frame:SetAlpha(fade.to)
            fades[frame] = nil
        else
            frame:SetAlpha(fade.from + (fade.to - fade.from) * (fade.elapsed / FADE_TIME))
            active = true
        end
    end
    if not active then
        driver:SetScript("OnUpdate", nil)
    end
end

-- Fade frame
local function FadeIt(self, newOpacity, instant)
    CombatFader:debug("FadeIt", newOpacity, instant)
    -- realUIHidden is still honoured on RealUI's own frames (ClassResource).
    if hiddenFrames[self] or self.realUIHidden then return end

    local currentOpacity = 1
    local alpha = self:GetAlpha()
    if not RealUI.isSecret(alpha) then
        currentOpacity = alpha
    end
    if newOpacity == currentOpacity then
        fades[self] = nil
        return
    end
    -- As before: a hidden frame is not faded out (it will be faded when shown).
    if newOpacity < currentOpacity and not self:IsShown() then return end

    if instant then
        fades[self] = nil
        self:SetAlpha(newOpacity)
        return
    end
    fades[self] = { from = currentOpacity, to = newOpacity, elapsed = 0 }
    fadeDriver:SetScript("OnUpdate", FadeDriver_OnUpdate)
end
CombatFader.FadeIt = FadeIt

--- Stop (hidden = true) or resume (false) fading one frame. While a frame is
--- hidden, CombatFader leaves its alpha alone, so its owner can hold it at 0
--- (RealUI_Tracker's per-instance fade). Replaces writing `realUIHidden` onto
--- Blizzard frames, which was a plant (tracker taint doctrine R1).
function CombatFader:SetFrameHidden(frame, hidden)
    if hidden then
        hiddenFrames[frame] = true
        fades[frame] = nil
    else
        hiddenFrames[frame] = nil
        self:RefreshMod()
    end
end

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
    elseif not RealUI.isSecret(_G.UnitHealthPercent("player", true, _G.CurveConstants.ScaleTo100)) then
        if (_G.UnitHealthPercent("player", true, _G.CurveConstants.ScaleTo100) < 100) or not isPowerRested(powerToken) then
            status = "hurt"                     -- Hurt - Priority 4
        else
            status = "outofcombat"          -- OutOfCombat - Priority 5
        end
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
    if not modules[mod] then return end

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
                desc = "These settings are disabled when the parent module is off or Combat Fading is not enabled.",
                type = "group",
                inline = true,
                disabled = function() return not RealUI:GetModuleEnabled(mod) or not RealUI.GetOptions(mod, modules[mod].path).enabled end,
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
