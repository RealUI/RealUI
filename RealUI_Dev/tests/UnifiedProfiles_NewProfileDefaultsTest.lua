local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: New profile contains all defaults
-- Feature: 2026-03-22-realui-profiles-2, Property 19: New profile contains all defaults
-- **Validates: Requirements 10.6**
--
-- For any newly created profile (OnNewProfile event), after OnProfileUpdate
-- completes, the profile shall contain all keys defined in
-- ProfileSystem:GetDatabaseDefaults().profile with non-nil values.

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

-- Profile names to pick from
local PROFILE_NAMES = {
    "RealUI", "RealUI-Healing", "RealUI_PvP", "RealUI_Mythic",
    "MyCustom", "Default", "TestProfile", "Raid", "Solo", "Arena",
}

-- Collect all top-level keys from a table
local function getKeys(tbl)
    local keys = {}
    for k in _G.pairs(tbl) do
        keys[#keys + 1] = k
    end
    return keys
end

-- Generate a random "new" profile: either completely empty or with a random
-- subset of keys present (simulating what AceDB gives for a brand-new profile).
local function generateRandomNewProfile(defaultKeys)
    local profile = {}
    -- Randomly include some keys to simulate partial AceDB population
    for _, key in _G.ipairs(defaultKeys) do
        if nextRandom(4) == 1 then
            -- 25% chance a key is already present with some value
            -- (AceDB may pre-populate some keys via its own defaults mechanism)
            profile[key] = true  -- placeholder non-nil value
        end
        -- else leave as nil — OnNewProfile merge should fill it
    end
    return profile
end

-- Generate random char data with layout info
local function generateRandomCharData()
    local layout = nextRandom(2)
    return {
        init = {
            installStage = 0,  -- Use 0 so OnProfileUpdate skips addon profile cascade
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

local function RunNewProfileDefaultsTest()
    _G.print("|cff00ccff[PBT]|r Property 19: New profile contains all defaults")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local RealUI = _G.RealUI

    if not RealUI or not RealUI.OnProfileUpdate then
        _G.print("|cffff0000[FAIL]|r RealUI or RealUI.OnProfileUpdate not available")
        return false
    end

    if not RealUI.ProfileSystem or not RealUI.ProfileSystem.GetDatabaseDefaults then
        _G.print("|cffff0000[FAIL]|r RealUI.ProfileSystem or GetDatabaseDefaults not available")
        return false
    end

    -- Get the canonical profile defaults
    local profileDefaults = RealUI.ProfileSystem:GetDatabaseDefaults().profile
    if not profileDefaults then
        _G.print("|cffff0000[FAIL]|r ProfileSystem:GetDatabaseDefaults().profile is nil")
        return false
    end

    local defaultKeys = getKeys(profileDefaults)
    _G.print("|cff00ccff[PBT]|r Default profile keys:", #defaultKeys)

    -- Save original state
    local origDB = RealUI.db
    local origCLayout = RealUI.cLayout
    local origNCLayout = RealUI.ncLayout
    local origIterateModules = RealUI.IterateModules
    local origLayoutManager = RealUI.LayoutManager
    local origInCombatLockdown = _G.InCombatLockdown
    local origSetAddOnProfileToRealUI = RealUI.SetAddOnProfileToRealUI
    local origUpdatePositioners = RealUI.UpdatePositioners
    local origGetModule = RealUI.GetModule
    local origReloadUIDialog = RealUI.ReloadUIDialog
    local origUpdateLayout = RealUI.UpdateLayout

    -- Install stubs — keep ProfileSystem active so OnNewProfile merge runs
    RealUI.IterateModules = function()
        return function() return nil end
    end
    RealUI.LayoutManager = nil
    _G.InCombatLockdown = function() return false end
    RealUI.SetAddOnProfileToRealUI = function() end
    RealUI.UpdatePositioners = function() end
    RealUI.UpdateLayout = function() end
    RealUI.GetModule = function() return nil end
    RealUI.ReloadUIDialog = function() end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local profileName = PROFILE_NAMES[nextRandom(#PROFILE_NAMES)]

        -- Generate a random new (mostly empty) profile
        local profileData = generateRandomNewProfile(defaultKeys)
        local charData = generateRandomCharData()
        local globalData = generateRandomGlobalData()

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

        -- Call OnProfileUpdate with OnNewProfile event
        RealUI:OnProfileUpdate("OnNewProfile", mockDatabase, profileName)

        -- Verify: every key from profileDefaults is present and non-nil
        local iterFailed = false
        for _, key in _G.ipairs(defaultKeys) do
            if profileData[key] == nil then
                failures = failures + 1
                iterFailed = true
                _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' missing default key '%s'"):format(
                    i, profileName, _G.tostring(key)))
                break
            end
        end

        -- Also verify that pre-existing keys were not clobbered
        -- (OnNewProfile only fills nil keys, never overwrites existing ones)
        if not iterFailed then
            -- We can't easily check value preservation since we used placeholder
            -- `true` values, but we can verify the key is still present
            for _, key in _G.ipairs(defaultKeys) do
                if profileData[key] == nil then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r iter %d: key '%s' became nil after merge"):format(
                        i, _G.tostring(key)))
                    break
                end
            end
        end

        if failures >= 5 then break end
    end

    -- Restore original state
    RealUI.IterateModules = origIterateModules
    RealUI.LayoutManager = origLayoutManager
    _G.InCombatLockdown = origInCombatLockdown
    RealUI.SetAddOnProfileToRealUI = origSetAddOnProfileToRealUI
    RealUI.UpdatePositioners = origUpdatePositioners
    RealUI.GetModule = origGetModule
    RealUI.ReloadUIDialog = origReloadUIDialog
    RealUI.UpdateLayout = origUpdateLayout
    RealUI.db = origDB
    RealUI.cLayout = origCLayout
    RealUI.ncLayout = origNCLayout

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 19: New profile contains all defaults — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 19: New profile contains all defaults — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:newprofiledefaults()
    return RunNewProfileDefaultsTest()
end
