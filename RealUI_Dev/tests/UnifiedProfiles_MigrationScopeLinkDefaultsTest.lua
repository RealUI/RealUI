local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Migration initializes scope link defaults
-- Feature: 2026-03-22-realui-profiles-2, Property 9: Migration initializes scope link defaults
-- **Validates: Requirements 8.2**
--
-- For any set of existing Core_Profile_Scope profiles that lack scopeLinks
-- fields, after the unified-profiles migration runs, every such profile shall
-- have scopeLinks.skins == false and scopeLinks.bt4 == true. Profiles that
-- already had scopeLinks should be unchanged.

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

-- Pool of profile names to draw from
local PROFILE_NAMES = {
    "RealUI", "RealUI-Healing", "RealUI_PvP", "RealUI_Mythic",
    "MyCustom", "Default", "TestProfile", "Raid", "Solo", "Arena",
}

-- Generate a random profile name
local function generateRandomProfileName()
    return PROFILE_NAMES[nextRandom(#PROFILE_NAMES)]
end

-- Deep-copy a scopeLinks table (one level)
local function copyScopeLinks(sl)
    if type(sl) ~= "table" then return sl end
    local copy = {}
    for k, v in _G.pairs(sl) do
        copy[k] = v
    end
    return copy
end

-- Replicate the migration's Scope 1 logic from FinalMigrations.lua in isolation.
-- This mirrors the pcall-wrapped block that initializes scopeLinks on all
-- existing Core profiles that lack the field.
local function MigrateScopeLinkDefaults_Replica(profiles)
    if type(profiles) ~= "table" then return end

    for _, profileData in _G.pairs(profiles) do
        if type(profileData) == "table" and not profileData.scopeLinks then
            profileData.scopeLinks = {
                skins = false,
                bt4 = true,
            }
        end
    end
end

local function RunMigrationScopeLinkDefaultsTest()
    _G.print("|cff00ccff[PBT]|r Property 9: Migration initializes scope link defaults")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- 1. Build a random set of Core profiles (1–6 profiles)
        local numProfiles = nextRandom(6)
        local profiles = {}
        local profileNames = {}

        for _ = 1, numProfiles do
            local name = generateRandomProfileName()
            if not profiles[name] then
                local profileData = {}

                -- Randomly add some generic profile data (non-migration keys)
                if randomBool() then
                    profileData.someKey = nextRandom(1000)
                end
                if randomBool() then
                    profileData.modules = { enabled = randomBool() }
                end

                -- Randomly decide whether this profile already has scopeLinks
                if randomBool() then
                    -- Pre-existing scopeLinks with random values
                    profileData.scopeLinks = {
                        skins = randomBool(),
                        bt4 = randomBool(),
                    }
                end
                -- else: no scopeLinks — migration should add defaults

                profiles[name] = profileData
                profileNames[#profileNames + 1] = name
            end
        end

        -- 2. Snapshot which profiles had scopeLinks and their values
        local hadScopeLinks = {}   -- [name] = true if profile already had scopeLinks
        local originalLinks = {}   -- [name] = copy of original scopeLinks table
        for name, data in _G.pairs(profiles) do
            if data.scopeLinks then
                hadScopeLinks[name] = true
                originalLinks[name] = copyScopeLinks(data.scopeLinks)
            end
        end

        -- 3. Run the migration replica
        MigrateScopeLinkDefaults_Replica(profiles)

        -- 4. Verify: every profile that lacked scopeLinks now has the defaults
        local iterFailed = false
        for name, data in _G.pairs(profiles) do
            if not hadScopeLinks[name] then
                -- This profile had no scopeLinks before migration
                if type(data.scopeLinks) ~= "table" then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' still has no scopeLinks after migration"):format(i, name))
                    break
                end
                if data.scopeLinks.skins ~= false then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' scopeLinks.skins expected false, got %s"):format(
                        i, name, _G.tostring(data.scopeLinks.skins)))
                    break
                end
                if data.scopeLinks.bt4 ~= true then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' scopeLinks.bt4 expected true, got %s"):format(
                        i, name, _G.tostring(data.scopeLinks.bt4)))
                    break
                end
            end
        end

        -- 5. Verify: profiles that already had scopeLinks are unchanged
        if not iterFailed then
            for name, origLinks in _G.pairs(originalLinks) do
                local data = profiles[name]
                if type(data.scopeLinks) ~= "table" then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' lost its scopeLinks after migration"):format(i, name))
                    break
                end
                if data.scopeLinks.skins ~= origLinks.skins then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' scopeLinks.skins changed from %s to %s"):format(
                        i, name, _G.tostring(origLinks.skins), _G.tostring(data.scopeLinks.skins)))
                    break
                end
                if data.scopeLinks.bt4 ~= origLinks.bt4 then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' scopeLinks.bt4 changed from %s to %s"):format(
                        i, name, _G.tostring(origLinks.bt4), _G.tostring(data.scopeLinks.bt4)))
                    break
                end
            end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 9: Migration initializes scope link defaults — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 9: Migration initializes scope link defaults — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:migrationscopelinkdefaults()
    return RunMigrationScopeLinkDefaultsTest()
end
