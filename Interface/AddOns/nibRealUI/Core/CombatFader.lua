local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndbc

local MODNAME = "CombatFader"
local CombatFader = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local LoggedIn = false
local FirstLog = true

local FadeTime = 0.20
local status = "incombat"
local modules = {}

local function isFullPower(token)
    if nibRealUI.ReversePowers[token] then
        return UnitPower("player") > 0
    else
        return UnitPower("player") < UnitPowerMax("player")
    end
end

-- Fade frame
local function FadeIt(self, newOpacity, instant)
    CombatFader:debug("FadeIt", newOpacity, instant)
    if self.realUIHidden then return end
    local currentOpacity = self:GetAlpha()
    local FadeTime = instant and 0 or FadeTime
    if newOpacity > currentOpacity then
        UIFrameFadeIn(self, FadeTime, currentOpacity, newOpacity)
    elseif newOpacity < currentOpacity and self:IsShown() then
        UIFrameFadeOut(self, FadeTime, currentOpacity, newOpacity)
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
    if UnitAffectingCombat("player") then
        status = "incombat"                 -- InCombat - Priority 1
    elseif UnitExists("target") then
        if UnitCanAttack("player", "target") then
            status = "harmtarget"           -- HarmTarget - Priority 2
        else
            status = "target"               -- Target - Priority 3
        end
    elseif UnitHealth("player") < UnitHealthMax("player") then
        status = "hurt"                     -- Hurt - Priority 4
    else
        local _, powerToken = UnitPowerType("player")
        if isFullPower(powerToken) then
            status = "hurt"
        else
            status = "outofcombat"          -- OutOfCombat - Priority 5
        end
    end
    if force or status ~= OldStatus then self:FadeFrames() end  
end

function CombatFader:HurtEvent(units)
    if units and units.player then self:UpdateStatus() end
end

-- On combat state change
function CombatFader:UpdateCombatState(event)
    -- If in combat, then don't worry about health/power events
    if UnitAffectingCombat("player") and not FirstLog then
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
    assert(modules[mod], mod.." has not yet been registered.")
    tinsert(modules[mod].frames, frame)
    CombatFader:RefreshMod()
end

function CombatFader:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            elements = {
                ["**"] = {
                    enabled = true,
                    opacity = {
                        incombat = 1,
                        hurt = 0.85,
                        target = 0.85,
                        harmtarget = 0.75,
                        outofcombat = 0.25,
                    },
                },
                unitframes = {
                    name = "Unit Frames",
                    frames = {
                        ["RealUIPlayerFrame"] = true,
                        ["RealUITargetFrame"] = true,
                        ["RealUIFocusFrame"] = true,
                        ["RealUIFocusTargetFrame"] = true,
                        ["RealUITargetTargetFrame"] = true,
                        ["RealUIPetFrame"] = true,
                    },
                },
                objectives = {
                    name = "Objective Tracker",
                    inverse = true,
                    frames = {
                        ["ObjectiveTrackerFrame"] = true,
                    },
                },
            },
        },
    })
    db = self.db.profile
    ndbc = nibRealUI.db.char

    nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
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
