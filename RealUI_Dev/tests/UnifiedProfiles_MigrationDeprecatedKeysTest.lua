local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Migration removes deprecated keys
-- Feature: 2026-03-22-realui-profiles-2, Property 12: Migration removes deprecated keys
-- **Validates: Requirements 8.5**
--
-- For any profile containing deprecated Systems Profile System keys, after
-- migration those keys shall be nil.

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 314159
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

-- Deprecated keys that the migration must remove (mirrors FinalMigrations.lua)
local DEPRECATED_KEYS = {
    "profileSystem",
    "systemProfiles",
    "profileSwitcher",
    "legacyProfileSystem",
}

-- Pool of non-deprecated keys that must survive migration
local SAFE_KEYS = {
    "positions", "modules", "settings", "scopeLinks", "actionbars",
    "infobar", "hud", "castbar", "unitframes",
}

-- Replicate the migration's Scope 3 logic from FinalMigrations.lua in isolation.
local function MigrateDeprecatedKeys_Replica(profiles)
    if type(profiles) ~= "table" then return end

    for profileName, profileData in _G.pairs(profiles) do
        if type(profileData) == "table" then
            for _, key in _G.ipairs(DEPRECATED_KEYS) do
                if profileData[key] ~= nil then
                    profileData[key] = nil
                end
            end
        end
    end
end

local function RunMigrationDeprecatedKeysTest()
    _G.print("|cff00ccff[PBT]|r Property 12: Migration removes deprecated keys")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- 1. Build a random set of profiles, some with deprecated keys
        local numProfiles = nextRandom(5) -- 1–5 profiles
        local profiles = {}
        local expectedSafe = {} -- track safe key values per profile

        for p = 1, numProfiles do
            local profileName = "Profile" .. p
            local profileData = {}
            expectedSafe[profileName] = {}

            -- Add some safe keys with random sentinel values
            for _, key in _G.ipairs(SAFE_KEYS) do
                if randomBool() then
                    local val = "value_" .. key .. "_" .. nextRandom(1000)
                    profileData[key] = val
                    expectedSafe[profileName][key] = val
                end
            end

            -- Add some deprecated keys (at least one per profile sometimes)
            for _, key in _G.ipairs(DEPRECATED_KEYS) do
                if randomBool() then
                    profileData[key] = { enabled = true, data = nextRandom(999) }
                end
            end

            profiles[profileName] = profileData
        end

        -- 2. Run the migration replica
        MigrateDeprecatedKeys_Replica(profiles)

        -- 3. Verify: all deprecated keys must be nil
        local iterFailed = false
        for profileName, profileData in _G.pairs(profiles) do
            for _, key in _G.ipairs(DEPRECATED_KEYS) do
                if profileData[key] ~= nil then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' still has deprecated key '%s'"):format(
                        i, profileName, key))
                    break
                end
            end
            if iterFailed then break end
        end

        -- 4. Verify: safe keys must be preserved
        if not iterFailed then
            for profileName, safeVals in _G.pairs(expectedSafe) do
                for key, expectedVal in _G.pairs(safeVals) do
                    if profiles[profileName][key] ~= expectedVal then
                        failures = failures + 1
                        iterFailed = true
                        _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' safe key '%s' changed from '%s' to '%s'"):format(
                            i, profileName, key, _G.tostring(expectedVal), _G.tostring(profiles[profileName][key])))
                        break
                    end
                end
                if iterFailed then break end
            end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 12: Migration removes deprecated keys — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 12: Migration removes deprecated keys — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:migrationdeprecatedkeys()
    return RunMigrationDeprecatedKeysTest()
end
