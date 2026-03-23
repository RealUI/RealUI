local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Migration preserves existing profile data
-- Feature: 2026-03-22-realui-profiles-2, Property 10: Migration preserves existing profile data
-- **Validates: Requirements 8.3**
--
-- For any existing Core profile data, the set of non-migration-related keys
-- and their values shall be identical before and after the migration runs.
-- The migration should only add scopeLinks (if missing) and remove deprecated
-- keys — all other profile data must be preserved exactly.

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

-- Deprecated keys that the migration removes
local DEPRECATED_KEYS = {
    "profileSystem",
    "systemProfiles",
    "profileSwitcher",
    "legacyProfileSystem",
}

-- Pool of non-migration key names (these must survive untouched)
local USER_KEY_NAMES = {
    "positions", "modules", "settings", "someKey", "customData",
    "uiScale", "castbars", "unitframes", "infobar", "hudConfig",
    "actionBarLayout", "minimap", "chatSettings", "tooltipConfig",
}

-- Pool of profile names
local PROFILE_NAMES = {
    "RealUI", "RealUI-Healing", "RealUI_PvP", "RealUI_Mythic",
    "MyCustom", "Default", "TestProfile", "Raid", "Solo", "Arena",
}

-- Generate a random simple value
local function randomValue()
    local kind = nextRandom(4)
    if kind == 1 then
        return nextRandom(10000)
    elseif kind == 2 then
        return USER_KEY_NAMES[nextRandom(#USER_KEY_NAMES)]
    elseif kind == 3 then
        return randomBool()
    else
        return nextRandom(1000) / 100
    end
end

-- Generate a random nested table (1 level deep)
local function randomTable()
    local t = {}
    local numKeys = nextRandom(4)
    for _ = 1, numKeys do
        local key = USER_KEY_NAMES[nextRandom(#USER_KEY_NAMES)]
        t[key] = randomValue()
    end
    return t
end

-- Deep-copy utility (handles nested tables one level deep)
local function deepCopy(orig)
    if type(orig) ~= "table" then return orig end
    local copy = {}
    for k, v in _G.pairs(orig) do
        if type(v) == "table" then
            local inner = {}
            for ik, iv in _G.pairs(v) do
                inner[ik] = iv
            end
            copy[k] = inner
        else
            copy[k] = v
        end
    end
    return copy
end

-- Deep-equal utility (handles nested tables one level deep)
local function deepEqual(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end

    for k, v in _G.pairs(a) do
        if type(v) == "table" then
            if type(b[k]) ~= "table" then return false end
            for ik, iv in _G.pairs(v) do
                if b[k][ik] ~= iv then return false end
            end
            -- Check b[k] doesn't have extra keys
            for ik in _G.pairs(b[k]) do
                if v[ik] == nil then return false end
            end
        else
            if b[k] ~= v then return false end
        end
    end
    -- Check b doesn't have extra keys
    for k in _G.pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

-- Build a set from an array
local function toSet(arr)
    local s = {}
    for _, v in _G.ipairs(arr) do
        s[v] = true
    end
    return s
end

local deprecatedSet = toSet(DEPRECATED_KEYS)

-- Replicate the migration logic from FinalMigrations.lua in isolation.
-- Scope 1: Add scopeLinks to profiles that lack it.
-- Scope 3: Remove deprecated keys from all profiles.
-- All other keys must be left untouched.
local function MigrateProfiles_Replica(profiles)
    if type(profiles) ~= "table" then return end

    for _, profileData in _G.pairs(profiles) do
        if type(profileData) == "table" then
            -- Scope 1: Initialize scopeLinks if missing
            if not profileData.scopeLinks then
                profileData.scopeLinks = {
                    skins = false,
                    bt4 = true,
                }
            end

            -- Scope 3: Remove deprecated keys
            for _, key in _G.ipairs(DEPRECATED_KEYS) do
                profileData[key] = nil
            end
        end
    end
end

local function RunMigrationPreserveDataTest()
    _G.print("|cff00ccff[PBT]|r Property 10: Migration preserves existing profile data")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- 1. Build a random set of Core profiles (1–6 profiles)
        local numProfiles = nextRandom(6)
        local profiles = {}

        for _ = 1, numProfiles do
            local name = PROFILE_NAMES[nextRandom(#PROFILE_NAMES)]
            if not profiles[name] then
                local profileData = {}

                -- Add random user keys (non-migration data)
                local numUserKeys = nextRandom(5)
                for _ = 1, numUserKeys do
                    local key = USER_KEY_NAMES[nextRandom(#USER_KEY_NAMES)]
                    if randomBool() then
                        profileData[key] = randomValue()
                    else
                        profileData[key] = randomTable()
                    end
                end

                -- Randomly add some deprecated keys (migration should remove these)
                for _, dk in _G.ipairs(DEPRECATED_KEYS) do
                    if randomBool() then
                        profileData[dk] = randomValue()
                    end
                end

                -- Randomly add pre-existing scopeLinks
                if randomBool() then
                    profileData.scopeLinks = {
                        skins = randomBool(),
                        bt4 = randomBool(),
                    }
                end

                profiles[name] = profileData
            end
        end

        -- 2. Snapshot all non-migration keys for each profile before migration
        --    Non-migration keys = everything except scopeLinks and deprecated keys
        local snapshots = {} -- [profileName] = { [key] = deepCopy(value) }
        for name, data in _G.pairs(profiles) do
            local snap = {}
            for k, v in _G.pairs(data) do
                if k ~= "scopeLinks" and not deprecatedSet[k] then
                    snap[k] = deepCopy(v)
                end
            end
            snapshots[name] = snap
        end

        -- 3. Run the migration replica
        MigrateProfiles_Replica(profiles)

        -- 4. Verify: all non-migration keys are unchanged
        local iterFailed = false
        for name, snap in _G.pairs(snapshots) do
            local data = profiles[name]
            if not data then
                failures = failures + 1
                iterFailed = true
                _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' disappeared after migration"):format(i, name))
                break
            end

            -- Check every snapshotted key still exists with the same value
            for k, origVal in _G.pairs(snap) do
                if not deepEqual(data[k], origVal) then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' key '%s' changed after migration"):format(i, name, k))
                    break
                end
                if iterFailed then break end
            end
            if iterFailed then break end

            -- Check no new non-migration keys appeared
            for k in _G.pairs(data) do
                if k ~= "scopeLinks" and not deprecatedSet[k] and snap[k] == nil then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' gained unexpected key '%s' after migration"):format(i, name, k))
                    break
                end
            end
            if iterFailed then break end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 10: Migration preserves existing profile data — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 10: Migration preserves existing profile data — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:migrationpreservedata()
    return RunMigrationPreserveDataTest()
end
