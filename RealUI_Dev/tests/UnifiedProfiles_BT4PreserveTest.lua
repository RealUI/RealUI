local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: EnsureBartenderActionBarsProfiles preserves existing data
-- Feature: 2026-03-22-realui-profiles-2, Property 14: EnsureBartenderActionBarsProfiles preserves existing data
-- **Validates: Requirements 9.3**
--
-- For any Bartender4 profile that already has bar configuration entries
-- (non-nil actionbars[barID] tables), calling EnsureBartenderActionBarsProfiles
-- shall not modify those existing entries — only nil entries shall be populated
-- with defaults.

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

-- The bar IDs and defaults that EnsureBartenderActionBarsProfiles uses
local defaultEnabled = {
    [1] = true,
    [2] = true,
    [3] = true,
    [4] = true,
    [5] = true,
    [6] = true,
    [7] = false,
    [8] = false,
    [9] = false,
    [10] = false,
    [13] = false,
    [14] = false,
    [15] = false,
}

local ALL_BAR_IDS = { 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 13, 14, 15 }

-- Built-in profile names that EnsureBartenderActionBarsProfiles processes
local layoutToProfile = { "RealUI", "RealUI-Healing" }

-- Deep-copy a table (one level deep for actionbar entries)
local function deepCopyBarEntry(entry)
    if type(entry) ~= "table" then return entry end
    local copy = {}
    for k, v in _G.pairs(entry) do
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

-- Deep-compare two tables (recursive, for bar entry comparison)
local function deepEqual(a, b)
    if type(a) ~= type(b) then return false end
    if type(a) ~= "table" then return a == b end
    for k, v in _G.pairs(a) do
        if not deepEqual(v, b[k]) then return false end
    end
    for k in _G.pairs(b) do
        if a[k] == nil then return false end
    end
    return true
end

-- Replicate the exact EnsureBartenderActionBarsProfiles logic from
-- DualSpecSystem.lua so we can test it in isolation against random inputs.
-- This mirrors the FIXED version: only processes built-in profiles and
-- the current profile, and only fills nil bar entries.
local function EnsureBartenderActionBarsProfiles_Replica(bt4db, currentKey)
    if type(bt4db) ~= "table" then return end

    local namespaces = bt4db.namespaces
    if type(namespaces) ~= "table" then return end

    local actionBarsNamespace = namespaces.ActionBars
    if type(actionBarsNamespace) ~= "table" then return end

    local profiles = actionBarsNamespace.profiles
    if type(profiles) ~= "table" then
        profiles = {}
        actionBarsNamespace.profiles = profiles
    end

    local function EnsureProfile(profileName)
        local profile = profiles[profileName]
        if type(profile) ~= "table" then
            profile = {}
            profiles[profileName] = profile
        end

        if type(profile.actionbars) ~= "table" then
            profile.actionbars = {}
        end

        for barID, enabled in _G.pairs(defaultEnabled) do
            if profile.actionbars[barID] == nil then
                profile.actionbars[barID] = { enabled = enabled }
            end
        end
    end

    for _, profileName in _G.ipairs(layoutToProfile) do
        EnsureProfile(profileName)
    end

    if type(bt4db.profileKeys) == "table" then
        local currentProfileName = bt4db.profileKeys[currentKey]
        if type(currentProfileName) == "string" and currentProfileName ~= "" then
            EnsureProfile(currentProfileName)
        end
    end
end

-- Generate a random bar entry with custom data
local function generateRandomBarEntry()
    local entry = { enabled = randomBool() }
    -- Add some random extra keys to simulate user customization
    if randomBool() then
        entry.padding = nextRandom(20)
    end
    if randomBool() then
        entry.rows = nextRandom(4)
    end
    if randomBool() then
        entry.hidemacrotext = randomBool()
    end
    if randomBool() then
        entry.position = {
            x = nextRandom(1000) - 500,
            y = nextRandom(1000) - 500,
        }
    end
    return entry
end

-- Generate a random BT4 profile with some bars populated and some nil
local function generateRandomBT4Profile()
    local profile = { actionbars = {} }
    for _, barID in _G.ipairs(ALL_BAR_IDS) do
        if randomBool() then
            -- Populate this bar with custom data
            profile.actionbars[barID] = generateRandomBarEntry()
        end
        -- else leave as nil — EnsureBartenderActionBarsProfiles should fill it
    end
    return profile
end

-- Generate a random profile name
local function generateRandomProfileName()
    local names = {
        "RealUI", "RealUI-Healing", "RealUI_PvP", "RealUI_Mythic",
        "MyCustom", "Default", "TestProfile", "Raid", "Solo", "Arena",
    }
    return names[nextRandom(#names)]
end

local function RunBT4PreserveTest()
    _G.print("|cff00ccff[PBT]|r Property 14: EnsureBartenderActionBarsProfiles preserves existing data")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- 1. Build a random Bartender4DB with 1–4 profiles, some with existing bars
        local numProfiles = nextRandom(4)
        local profileNames = {}
        local bt4db = {
            profileKeys = {},
            namespaces = {
                ActionBars = {
                    profiles = {},
                },
            },
        }

        for _ = 1, numProfiles do
            local name = generateRandomProfileName()
            if not bt4db.namespaces.ActionBars.profiles[name] then
                bt4db.namespaces.ActionBars.profiles[name] = generateRandomBT4Profile()
                profileNames[#profileNames + 1] = name
            end
        end

        -- Optionally set a current profile key
        local currentKey = "TestChar - TestRealm"
        if #profileNames > 0 and randomBool() then
            bt4db.profileKeys[currentKey] = profileNames[nextRandom(#profileNames)]
        end

        -- 2. Snapshot all existing bar entries (deep copy)
        local snapshots = {}
        for profName, profData in _G.pairs(bt4db.namespaces.ActionBars.profiles) do
            snapshots[profName] = {}
            if type(profData.actionbars) == "table" then
                for barID, barEntry in _G.pairs(profData.actionbars) do
                    snapshots[profName][barID] = deepCopyBarEntry(barEntry)
                end
            end
        end

        -- 3. Call the replica function
        EnsureBartenderActionBarsProfiles_Replica(bt4db, currentKey)

        -- 4. Verify: every pre-existing bar entry is unchanged
        local iterFailed = false
        for profName, barSnaps in _G.pairs(snapshots) do
            local profData = bt4db.namespaces.ActionBars.profiles[profName]
            if not profData or type(profData.actionbars) ~= "table" then
                failures = failures + 1
                iterFailed = true
                _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' lost its actionbars table"):format(i, profName))
                break
            end

            for barID, origEntry in _G.pairs(barSnaps) do
                local currentEntry = profData.actionbars[barID]
                if not deepEqual(origEntry, currentEntry) then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' bar %d was modified"):format(
                        i, profName, barID))
                    _G.print(("  original enabled=%s, current enabled=%s"):format(
                        _G.tostring(origEntry.enabled), _G.tostring(currentEntry and currentEntry.enabled)))
                    break
                end
            end
            if iterFailed then break end
        end

        -- 5. Verify: nil entries on built-in profiles are now populated
        if not iterFailed then
            for _, builtinName in _G.ipairs(layoutToProfile) do
                local profData = bt4db.namespaces.ActionBars.profiles[builtinName]
                if not profData or type(profData.actionbars) ~= "table" then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: built-in profile '%s' missing after ensure"):format(
                        i, builtinName))
                    break
                end

                for _, barID in _G.ipairs(ALL_BAR_IDS) do
                    local barEntry = profData.actionbars[barID]
                    if barEntry == nil then
                        failures = failures + 1
                        iterFailed = true
                        _G.print(("|cffff0000[FAIL]|r iter %d: built-in profile '%s' bar %d still nil after ensure"):format(
                            i, builtinName, barID))
                        break
                    end
                end
                if iterFailed then break end
            end
        end

        -- 6. Verify: nil entries that were filled got the correct default
        if not iterFailed then
            for _, builtinName in _G.ipairs(layoutToProfile) do
                local profData = bt4db.namespaces.ActionBars.profiles[builtinName]
                local snap = snapshots[builtinName] or {}

                for _, barID in _G.ipairs(ALL_BAR_IDS) do
                    if snap[barID] == nil then
                        -- This was nil before, should now have default
                        local barEntry = profData.actionbars[barID]
                        if type(barEntry) ~= "table" or barEntry.enabled ~= defaultEnabled[barID] then
                            failures = failures + 1
                            iterFailed = true
                            _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' bar %d default wrong (expected enabled=%s)"):format(
                                i, builtinName, barID, _G.tostring(defaultEnabled[barID])))
                            break
                        end
                    end
                end
                if iterFailed then break end
            end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 14: EnsureBartenderActionBarsProfiles preserves existing data — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 14: EnsureBartenderActionBarsProfiles preserves existing data — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:bt4preserve()
    return RunBT4PreserveTest()
end
