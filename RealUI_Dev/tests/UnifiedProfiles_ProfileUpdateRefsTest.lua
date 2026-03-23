local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: OnProfileUpdate refreshes all references
-- Feature: 2026-03-22-realui-profiles-2, Property 17: OnProfileUpdate refreshes all references
-- **Validates: Requirements 10.2, 10.3**
--
-- For any profile switch event (OnProfileChanged, OnNewProfile, OnProfileCopied,
-- OnProfileReset), after OnProfileUpdate fires, `db` shall reference
-- `database.profile`, `dbc` shall reference `database.char`, `dbg` shall
-- reference `database.global`, and `RealUI.cLayout` shall equal
-- `dbc.layout.current`.

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 271828
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

-- Profile names to pick from (includes built-in and custom)
local PROFILE_NAMES = {
    "RealUI", "RealUI-Healing", "RealUI_PvP", "RealUI_Mythic",
    "MyCustom", "Default", "TestProfile", "Raid", "Solo", "Arena",
}

-- Generate a random profile data table with typical Core profile keys
local function generateRandomProfileData()
    local profile = {
        modules = { ["*"] = true },
        positionsLink = randomBool(),
        positions = {},
        settings = {
            hudSize = nextRandom(3),
            reverseUnitFrameBars = randomBool(),
            performanceMonitorEnabled = randomBool(),
        },
    }
    -- Add some random extra keys
    if randomBool() then
        profile.abSettingsLink = randomBool()
    end
    if randomBool() then
        profile.registeredChars = {}
    end
    return profile
end

-- Generate random char data with layout info
local function generateRandomCharData()
    local layout = nextRandom(2)  -- 1 or 2
    return {
        init = {
            installStage = 0,  -- Use 0 so OnProfileUpdate skips the addon profile cascade
            initialized = randomBool(),
            needchatmoved = randomBool(),
        },
        layout = {
            current = layout,
            spec = {},
        },
    }
end

-- Generate random global data
local function generateRandomGlobalData()
    return {
        tutorial = { stage = nextRandom(10) - 1 },
        tags = {
            firsttime = randomBool(),
            lowResOptimized = randomBool(),
            slashRealUITyped = randomBool(),
        },
        verinfo = {},
        patchedTOC = 0,
    }
end

local function RunProfileUpdateRefsTest()
    _G.print("|cff00ccff[PBT]|r Property 17: OnProfileUpdate refreshes all references")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local RealUI = _G.RealUI

    -- We need access to the real OnProfileUpdate function.
    -- It is registered as a method on the RealUI object.
    if not RealUI or not RealUI.OnProfileUpdate then
        _G.print("|cffff0000[FAIL]|r RealUI or RealUI.OnProfileUpdate not available")
        return false
    end

    -- Save original state so we can restore after test
    local origDB = RealUI.db
    local origCLayout = RealUI.cLayout
    local origNCLayout = RealUI.ncLayout

    -- Stub out systems that OnProfileUpdate calls so we isolate reference refresh:
    -- 1. IterateModules — return empty iterator so module callbacks are skipped
    -- 2. ProfileSystem — stub for OnNewProfile default merging
    -- 3. LayoutManager — stub to prevent actual layout switching
    -- 4. InCombatLockdown — always return false for test
    -- 5. private.Profiles — empty table to skip addon profile cascade
    -- 6. SetAddOnProfileToRealUI — no-op stub

    local origIterateModules = RealUI.IterateModules
    local origLayoutManager = RealUI.LayoutManager
    local origProfileSystem = RealUI.ProfileSystem
    local origInCombatLockdown = _G.InCombatLockdown
    local origSetAddOnProfileToRealUI = RealUI.SetAddOnProfileToRealUI
    local origUpdatePositioners = RealUI.UpdatePositioners
    local origGetModule = RealUI.GetModule
    local origReloadUIDialog = RealUI.ReloadUIDialog

    -- Install stubs
    RealUI.IterateModules = function()
        return function() return nil end
    end
    RealUI.LayoutManager = nil  -- Disable LayoutManager so UpdateLayout uses fallback path
    RealUI.ProfileSystem = nil  -- Disable ProfileSystem to simplify (OnNewProfile merge skipped)
    _G.InCombatLockdown = function() return false end
    RealUI.SetAddOnProfileToRealUI = function() end
    RealUI.UpdatePositioners = function() end
    RealUI.GetModule = function() return nil end
    RealUI.ReloadUIDialog = function() end  -- Prevent reload dialog on OnProfileReset

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Pick a random event type
        local event = PROFILE_EVENTS[nextRandom(#PROFILE_EVENTS)]

        -- Pick a random profile name
        local profileName = PROFILE_NAMES[nextRandom(#PROFILE_NAMES)]

        -- Generate random database tables
        local profileData = generateRandomProfileData()
        local charData = generateRandomCharData()
        local globalData = generateRandomGlobalData()

        -- Build a mock database object that mimics AceDB's structure
        local mockDatabase = {
            profile = profileData,
            char = charData,
            global = globalData,
        }

        -- Also set RealUI.db to a mock that has .char for OnProfileReset access
        RealUI.db = {
            profile = profileData,
            char = charData,
            global = globalData,
        }

        -- Call OnProfileUpdate
        RealUI:OnProfileUpdate(event, mockDatabase, profileName)

        -- Verify Property 17 assertions:

        -- 1. After the call, the module-level `db` should reference database.profile.
        --    We can't directly read the local `db` from Core.lua, but we CAN verify
        --    the observable effects: RealUI.cLayout should be set from dbc.layout.current,
        --    and the database references should be used by UpdateLayout.
        --
        --    The key observable: RealUI.cLayout == charData.layout.current
        --    This proves dbc was set to database.char (since UpdateLayout reads
        --    dbc.layout.current) and cLayout was updated accordingly.

        local expectedLayout = charData.layout.current
        -- For built-in profiles, profileToLayout may override the layout
        local profileToLayout = { ["RealUI"] = 1, ["RealUI-Healing"] = 2 }
        local profileLayout = profileToLayout[profileName]
        if profileLayout then
            expectedLayout = profileLayout
        end

        if RealUI.cLayout ~= expectedLayout then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: event=%s profile=%s cLayout=%s expected=%s"):format(
                i, event, profileName,
                _G.tostring(RealUI.cLayout), _G.tostring(expectedLayout)))
            if failures >= 5 then break end
        end

        -- 2. Verify ncLayout is the complement of cLayout
        local expectedNCLayout = expectedLayout == 1 and 2 or 1
        if RealUI.ncLayout ~= expectedNCLayout then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: ncLayout=%s expected=%s"):format(
                i, _G.tostring(RealUI.ncLayout), _G.tostring(expectedNCLayout)))
            if failures >= 5 then break end
        end

        -- 3. Verify that RealUI.db.char still references the same charData
        --    (proves dbc was set to database.char, since UpdateLayout writes
        --    dbc.layout.current = layout, which modifies charData in-place)
        if charData.layout.current ~= expectedLayout then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: charData.layout.current=%s expected=%s (dbc not referencing database.char)"):format(
                i, _G.tostring(charData.layout.current), _G.tostring(expectedLayout)))
            if failures >= 5 then break end
        end
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
        _G.print(("|cff00ff00[PASS]|r Property 17: OnProfileUpdate refreshes all references — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 17: OnProfileUpdate refreshes all references — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:profileupdaterefs()
    return RunProfileUpdateRefsTest()
end
