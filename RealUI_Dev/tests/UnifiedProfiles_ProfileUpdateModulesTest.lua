local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: OnProfileUpdate propagates to all modules
-- Feature: 2026-03-22-realui-profiles-2, Property 18: OnProfileUpdate propagates to all modules
-- **Validates: Requirements 10.4, 10.5**
--
-- For any profile switch event, OnProfileUpdate shall call
-- module:OnProfileUpdate(event, profile) on every module returned by
-- RealUI:IterateModules(), and shall trigger a layout recalculation
-- via RealUI:UpdateLayout().

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 161803
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function randomBool()
    return nextRandom(2) == 1
end

-- Profile event types that OnProfileUpdate handles
local PROFILE_EVENTS = { "OnProfileChanged", "OnNewProfile", "OnProfileCopied", "OnProfileReset" }

-- Pool of module names to randomly pick from
local MODULE_NAME_POOL = {
    "ActionBars", "CastBars", "UnitFrames", "Infobar", "FrameMover",
    "CombatFader", "MiniMap", "Tooltips", "Chat", "Skins",
    "WorldMarker", "GridLayout", "AuraTracker", "ThreatMeter",
    "Cooldowns", "Nameplates", "QuestTracker", "BagManager",
    "PvPHelper", "RaidTools", "DungeonHelper", "MythicPlus",
}

-- Profile names to pick from
local PROFILE_NAMES = {
    "RealUI", "RealUI-Healing", "RealUI_PvP", "RealUI_Mythic",
    "MyCustom", "Default", "TestProfile", "Raid", "Solo", "Arena",
}

-- Build a random set of mock modules, each tracking whether it received
-- the OnProfileUpdate callback and with which arguments.
local function generateRandomModules()
    local count = nextRandom(#MODULE_NAME_POOL)
    local modules = {}
    local used = {}
    for _ = 1, count do
        local idx = nextRandom(#MODULE_NAME_POOL)
        local name = MODULE_NAME_POOL[idx]
        if not used[name] then
            used[name] = true
            local mod = {
                name = name,
                callCount = 0,
                receivedEvent = nil,
                receivedProfile = nil,
            }
            -- Each mock module has an OnProfileUpdate method that records the call
            mod.OnProfileUpdate = function(self, event, profile)
                self.callCount = self.callCount + 1
                self.receivedEvent = event
                self.receivedProfile = profile
            end
            modules[#modules + 1] = mod
        end
    end
    return modules
end

local function RunProfileUpdateModulesTest()
    _G.print("|cff00ccff[PBT]|r Property 18: OnProfileUpdate propagates to all modules")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local RealUI = _G.RealUI

    if not RealUI or not RealUI.OnProfileUpdate then
        _G.print("|cffff0000[FAIL]|r RealUI or RealUI.OnProfileUpdate not available")
        return false
    end

    -- Save original state
    local origDB = RealUI.db
    local origCLayout = RealUI.cLayout
    local origNCLayout = RealUI.ncLayout
    local origIterateModules = RealUI.IterateModules
    local origLayoutManager = RealUI.LayoutManager
    local origProfileSystem = RealUI.ProfileSystem
    local origInCombatLockdown = _G.InCombatLockdown
    local origSetAddOnProfileToRealUI = RealUI.SetAddOnProfileToRealUI
    local origUpdatePositioners = RealUI.UpdatePositioners
    local origGetModule = RealUI.GetModule
    local origReloadUIDialog = RealUI.ReloadUIDialog

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate random modules for this iteration
        local mockModules = generateRandomModules()

        -- Track whether UpdateLayout was called
        local updateLayoutCalled = false

        -- Pick random event and profile
        local event = PROFILE_EVENTS[nextRandom(#PROFILE_EVENTS)]
        local profileName = PROFILE_NAMES[nextRandom(#PROFILE_NAMES)]

        -- Build mock database
        local layout = nextRandom(2)
        local charData = {
            init = { installStage = 0, initialized = true, needchatmoved = false },
            layout = { current = layout, spec = {} },
        }
        local profileData = {
            modules = { ["*"] = true },
            positionsLink = randomBool(),
            positions = {},
            settings = { hudSize = nextRandom(3), reverseUnitFrameBars = false, performanceMonitorEnabled = false },
        }
        local globalData = {
            tutorial = { stage = 0 },
            tags = { firsttime = false, lowResOptimized = false, slashRealUITyped = false },
            verinfo = {},
            patchedTOC = 0,
        }

        local mockDatabase = {
            profile = profileData,
            char = charData,
            global = globalData,
        }

        RealUI.db = {
            profile = profileData,
            char = charData,
            global = globalData,
        }

        -- Install stubs
        -- IterateModules returns an iterator over our mock modules
        RealUI.IterateModules = function()
            local idx = 0
            return function()
                idx = idx + 1
                if idx <= #mockModules then
                    return mockModules[idx].name, mockModules[idx]
                end
                return nil
            end
        end

        RealUI.LayoutManager = nil
        RealUI.ProfileSystem = nil
        _G.InCombatLockdown = function() return false end
        RealUI.SetAddOnProfileToRealUI = function() end
        RealUI.GetModule = function() return nil end
        RealUI.ReloadUIDialog = function() end

        -- Stub UpdatePositioners to track layout recalculation
        RealUI.UpdatePositioners = function()
            updateLayoutCalled = true
        end

        -- Call OnProfileUpdate
        RealUI:OnProfileUpdate(event, mockDatabase, profileName)

        -- The fallback UpdateLayout path calls UpdatePositioners, which we
        -- track above.  For built-in profiles, profileToLayout maps the name
        -- to a layout id and UpdateLayout is called with that value.
        -- For non-built-in profiles, UpdateLayout is called with nil which
        -- defaults to dbc.layout.current.  Either way UpdatePositioners fires.

        -- Verify: every mock module received exactly one OnProfileUpdate call
        -- with the correct event and profile name
        for _, mod in _G.ipairs(mockModules) do
            if mod.callCount ~= 1 then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: module '%s' callCount=%d (expected 1)"):format(
                    i, mod.name, mod.callCount))
                break
            end
            if mod.receivedEvent ~= event then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: module '%s' receivedEvent='%s' (expected '%s')"):format(
                    i, mod.name, _G.tostring(mod.receivedEvent), event))
                break
            end
            if mod.receivedProfile ~= profileName then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: module '%s' receivedProfile='%s' (expected '%s')"):format(
                    i, mod.name, _G.tostring(mod.receivedProfile), profileName))
                break
            end
        end

        -- Verify: layout recalculation was triggered (UpdatePositioners called)
        if not updateLayoutCalled then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: UpdateLayout/UpdatePositioners was not called (event=%s profile=%s)"):format(
                i, event, profileName))
        end

        if failures >= 5 then break end
    end

    -- Restore original state
    RealUI.IterateModules = origIterateModules
    RealUI.LayoutManager = origLayoutManager
    RealUI.ProfileSystem = origProfileSystem
    _G.InCombatLockdown = origInCombatLockdown
    RealUI.SetAddOnProfileToRealUI = origSetAddOnProfileToRealUI
    RealUI.UpdatePositioners = origUpdatePositioners
    RealUI.GetModule = origGetModule
    RealUI.ReloadUIDialog = origReloadUIDialog
    RealUI.db = origDB
    RealUI.cLayout = origCLayout
    RealUI.ncLayout = origNCLayout

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 18: OnProfileUpdate propagates to all modules — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 18: OnProfileUpdate propagates to all modules — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:profileupdatemodules()
    return RunProfileUpdateModulesTest()
end
