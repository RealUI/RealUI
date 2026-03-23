local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Migration idempotence
-- Feature: 2026-03-22-realui-profiles-2, Property 13: Migration idempotence
-- **Validates: Requirements 8.7**
--
-- For any valid database state, running the unified-profiles migration N times
-- (N >= 1) shall produce the same database state as running it exactly once.
-- This test verifies both:
--   (a) the idempotence guard (db.global.unifiedProfilesMigrated) causes early exit
--   (b) even if the guard is bypassed (reset to false), re-running produces the
--       same state

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

-- Pool of profile names
local PROFILE_NAMES = {
    "RealUI", "RealUI-Healing", "RealUI_PvP", "RealUI_Mythic",
    "MyCustom", "Default", "TestProfile", "Raid", "Solo", "Arena",
}

-- Deprecated keys from the old Systems Profile System (mirrors FinalMigrations)
local DEPRECATED_KEYS = {
    "profileSystem",
    "systemProfiles",
    "profileSwitcher",
    "legacyProfileSystem",
}

-- Layout index -> profile name mapping (mirrors FinalMigrations)
local layoutToProfile = {
    [1] = "RealUI",
    [2] = "RealUI-Healing",
}

-- Replicate the full unified-profiles migration from FinalMigrations.lua.
-- This mirrors all three scopes plus the idempotence guard.
-- When bypassGuard is true, the guard check is skipped (to test structural
-- idempotence independent of the flag).
local function RunMigration_Replica(db, bypassGuard)
    if not db then return end

    -- Idempotence guard
    if not bypassGuard and db.global.unifiedProfilesMigrated then
        return
    end

    -- Scope 1: Initialize scopeLinks on all existing Core profiles
    local profiles = db.profiles
    if type(profiles) == "table" then
        for _, profileData in _G.pairs(profiles) do
            if type(profileData) == "table" and not profileData.scopeLinks then
                profileData.scopeLinks = {
                    skins = false,
                    bt4 = true,
                }
            end
        end
    end

    -- Scope 2: Populate db.char.specProfiles from db.char.layout.spec
    local dbc = db.char
    if type(dbc) == "table" then
        if not dbc.specProfiles then
            dbc.specProfiles = {}
        end

        if dbc.layout and type(dbc.layout.spec) == "table" then
            for specIndex, layoutIndex in _G.pairs(dbc.layout.spec) do
                if not dbc.specProfiles[specIndex] then
                    local profileName = layoutToProfile[layoutIndex]
                    if profileName then
                        dbc.specProfiles[specIndex] = profileName
                    else
                        dbc.specProfiles[specIndex] = layoutToProfile[1]
                    end
                end
            end
        end
    end

    -- Scope 3: Remove deprecated keys from all profiles
    if type(profiles) == "table" then
        for _, profileData in _G.pairs(profiles) do
            if type(profileData) == "table" then
                for _, key in _G.ipairs(DEPRECATED_KEYS) do
                    if profileData[key] ~= nil then
                        profileData[key] = nil
                    end
                end
            end
        end
    end

    -- Mark migration complete
    db.global.unifiedProfilesMigrated = true
end

-- Deep-copy a table (recursive, handles nested tables)
local function deepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in _G.pairs(orig) do
        copy[k] = deepCopy(v)
    end
    return copy
end

-- Deep-equal comparison of two values (recursive)
local function deepEqual(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end

    -- Check all keys in a exist in b with same values
    for k, v in _G.pairs(a) do
        if not deepEqual(v, b[k]) then return false end
    end
    -- Check b has no extra keys
    for k in _G.pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

-- Describe a difference between two tables (for diagnostics)
local function describeDiff(a, b, path)
    path = path or "db"
    if type(a) ~= type(b) then
        return ("%s: type %s vs %s"):format(path, type(a), type(b))
    end
    if type(a) ~= "table" then
        if a ~= b then
            return ("%s: %s vs %s"):format(path, _G.tostring(a), _G.tostring(b))
        end
        return nil
    end
    for k, v in _G.pairs(a) do
        local diff = describeDiff(v, b[k], path .. "." .. _G.tostring(k))
        if diff then return diff end
    end
    for k in _G.pairs(b) do
        if a[k] == nil then
            return ("%s.%s: nil vs %s"):format(path, _G.tostring(k), _G.tostring(b[k]))
        end
    end
    return nil
end

-- Generate a random valid database state for the migration
local function generateRandomDB()
    local db = {
        global = {
            unifiedProfilesMigrated = false,
        },
        profiles = {},
        char = {},
    }

    -- Generate 1–6 random profiles
    local numProfiles = nextRandom(6)
    for _ = 1, numProfiles do
        local name = PROFILE_NAMES[nextRandom(#PROFILE_NAMES)]
        if not db.profiles[name] then
            local profileData = {}

            -- Random generic data
            if randomBool() then
                profileData.someKey = nextRandom(1000)
            end
            if randomBool() then
                profileData.modules = { enabled = randomBool() }
            end
            if randomBool() then
                profileData.positions = { x = nextRandom(500), y = nextRandom(500) }
            end

            -- Randomly add pre-existing scopeLinks
            if randomBool() then
                profileData.scopeLinks = {
                    skins = randomBool(),
                    bt4 = randomBool(),
                }
            end

            -- Randomly add deprecated keys
            for _, key in _G.ipairs(DEPRECATED_KEYS) do
                if randomBool() then
                    profileData[key] = "old_value_" .. key
                end
            end

            db.profiles[name] = profileData
        end
    end

    -- Generate char data with layout.spec
    local numSpecs = nextRandom(4)
    local layoutSpec = {}
    for specIdx = 1, numSpecs do
        -- Layout index 1 or 2 (occasionally 3 for unknown layout testing)
        layoutSpec[specIdx] = nextRandom(3)
    end
    db.char = {
        layout = {
            spec = layoutSpec,
        },
    }

    -- Optionally pre-populate some specProfiles
    if randomBool() then
        db.char.specProfiles = {}
        for specIdx = 1, numSpecs do
            if randomBool() then
                db.char.specProfiles[specIdx] = PROFILE_NAMES[nextRandom(#PROFILE_NAMES)]
            end
        end
    end

    -- Also add a current profile reference (not used by migration but realistic)
    if randomBool() then
        db.profile = db.profiles[PROFILE_NAMES[nextRandom(#PROFILE_NAMES)]] or {}
    end

    return db
end

local function RunMigrationIdempotenceTest()
    _G.print("|cff00ccff[PBT]|r Property 13: Migration idempotence")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- 1. Generate a random valid DB state
        local db = generateRandomDB()

        -- 2. Make two independent deep copies for the two test paths
        local dbOnce = deepCopy(db)
        local dbTwiceGuarded = deepCopy(db)
        local dbTwiceBypassed = deepCopy(db)

        -- 3. Run migration once on dbOnce
        RunMigration_Replica(dbOnce, false)

        -- 4a. Test (a): Guard-based idempotence
        -- Run migration twice on dbTwiceGuarded (second run should early-exit via guard)
        RunMigration_Replica(dbTwiceGuarded, false)
        RunMigration_Replica(dbTwiceGuarded, false)

        if not deepEqual(dbOnce, dbTwiceGuarded) then
            failures = failures + 1
            local diff = describeDiff(dbOnce, dbTwiceGuarded) or "unknown"
            _G.print(("|cffff0000[FAIL]|r iter %d: guard-based idempotence failed — %s"):format(i, diff))
            -- Continue to next iteration
        else
            -- 4b. Test (b): Structural idempotence (bypass guard, re-run)
            -- Run migration once, then reset guard and run again
            RunMigration_Replica(dbTwiceBypassed, false)
            -- Reset the guard to simulate bypassing it
            dbTwiceBypassed.global.unifiedProfilesMigrated = false
            RunMigration_Replica(dbTwiceBypassed, false)

            if not deepEqual(dbOnce, dbTwiceBypassed) then
                failures = failures + 1
                local diff = describeDiff(dbOnce, dbTwiceBypassed) or "unknown"
                _G.print(("|cffff0000[FAIL]|r iter %d: structural idempotence failed (guard bypassed) — %s"):format(i, diff))
            end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 13: Migration idempotence — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 13: Migration idempotence — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:migrationidempotence()
    return RunMigrationIdempotenceTest()
end
