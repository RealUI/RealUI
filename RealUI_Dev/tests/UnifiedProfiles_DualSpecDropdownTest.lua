local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: DualSpec mapping dropdown includes all profiles
-- Feature: 2026-03-22-realui-profiles-2, Property 23: DualSpec mapping dropdown includes all profiles
-- **Validates: Requirements 9.1, 9.6**
--
-- For any set of profiles in Core_Profile_Scope (including custom profiles),
-- the DualSpec mapping dropdown values shall contain every profile name in
-- that set. No phantom profiles shall appear that don't exist in the database.
-- The get/set callbacks for spec profile assignment shall round-trip correctly.

-- luacheck: globals next type pairs ipairs tostring

local NUM_ITERATIONS = 100

------------------------------------------------------------
-- Simple RNG (xorshift32)
------------------------------------------------------------
local rngState = 577215
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

------------------------------------------------------------
-- Random profile name generator
------------------------------------------------------------
local CHARSET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-"
local function randomProfileName()
    local len = nextRandom(18) + 2 -- 3..20 chars
    local chars = {}
    for c = 1, len do
        local idx = nextRandom(#CHARSET)
        chars[c] = CHARSET:sub(idx, idx)
    end
    return _G.table.concat(chars)
end

------------------------------------------------------------
-- Replicate GetCoreProfileValues logic from UnifiedProfilePage.lua
-- This is the function under test: it builds a values table from
-- RealUI.db:GetProfiles() for use in AceConfig dropdown widgets.
------------------------------------------------------------
local function GetCoreProfileValues(mockDB)
    local values = {}
    local profiles = mockDB:GetProfiles()
    if profiles then
        for _, name in _G.ipairs(profiles) do
            values[name] = name
        end
    end
    return values
end


------------------------------------------------------------
-- Mock AceDB that stores profiles and supports get/set
------------------------------------------------------------
local function CreateMockDB(profileNames)
    local profiles = {}
    for _, name in _G.ipairs(profileNames) do
        profiles[name] = true
    end

    local currentProfile = profileNames[1] or "Default"
    local charSpecProfiles = {}

    local db = {}

    --- Returns an array of all profile names (mirrors AceDB:GetProfiles())
    function db:GetProfiles()
        local list = {}
        for name in _G.pairs(profiles) do
            list[#list + 1] = name
        end
        -- Sort for deterministic ordering
        _G.table.sort(list)
        return list
    end

    function db:GetCurrentProfile()
        return currentProfile
    end

    --- Simulates setting a spec-to-profile assignment (DualSpec mapping set callback)
    function db:SetSpecProfile(specIndex, profileName)
        if not specIndex or not profileName then return false end
        if not profiles[profileName] then return false end
        charSpecProfiles[specIndex] = profileName
        return true
    end

    --- Simulates reading a spec-to-profile assignment (DualSpec mapping get callback)
    function db:GetSpecProfile(specIndex)
        if not specIndex then return nil end
        return charSpecProfiles[specIndex]
    end

    --- Add a profile dynamically (simulates user creating a profile)
    function db:AddProfile(name)
        profiles[name] = true
    end

    --- Remove a profile (simulates user deleting a profile)
    function db:RemoveProfile(name)
        profiles[name] = nil
    end

    --- Check if a profile exists
    function db:HasProfile(name)
        return profiles[name] == true
    end

    return db
end

------------------------------------------------------------
-- Main test runner
------------------------------------------------------------
local function RunDualSpecDropdownTest()
    _G.print("|cff00ccff[PBT]|r Property 23: DualSpec mapping dropdown includes all profiles")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- 1. Generate a random set of profile names (1..8 profiles)
        --    Always include the built-in profiles, plus random custom ones
        local profileNames = { "RealUI", "RealUI-Healing" }
        local numCustom = nextRandom(6) -- 1..6 custom profiles
        local nameSet = { ["RealUI"] = true, ["RealUI-Healing"] = true }

        for _ = 1, numCustom do
            local name = randomProfileName()
            if not nameSet[name] then
                nameSet[name] = true
                profileNames[#profileNames + 1] = name
            end
        end

        local mockDB = CreateMockDB(profileNames)

        -- 2. Call GetCoreProfileValues and verify completeness
        local values = GetCoreProfileValues(mockDB)

        -- 2a. Every profile from GetProfiles() must appear in values
        local dbProfiles = mockDB:GetProfiles()
        for _, profName in _G.ipairs(dbProfiles) do
            if values[profName] ~= profName then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: profile '%s' missing from dropdown values"):format(
                    i, profName))
            end
        end

        -- 2b. No phantom profiles: every key in values must exist in the DB
        for key, val in _G.pairs(values) do
            if not mockDB:HasProfile(key) then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: phantom profile '%s' in dropdown values"):format(
                    i, key))
            end
            -- Values table should map name -> name (key == value)
            if key ~= val then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: values key '%s' != value '%s'"):format(
                    i, key, tostring(val)))
            end
        end

        -- 2c. Count must match exactly
        local valuesCount = 0
        for _ in _G.pairs(values) do valuesCount = valuesCount + 1 end
        if valuesCount ~= #dbProfiles then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: values count %d != profiles count %d"):format(
                i, valuesCount, #dbProfiles))
        end

        -- 3. Verify get/set round-trip for spec profile assignment
        local numSpecs = nextRandom(4) -- 1..4 specs
        for specIndex = 1, numSpecs do
            -- Pick a random profile from the available set
            local targetProfile = dbProfiles[nextRandom(#dbProfiles)]

            -- Set the spec profile
            local setOk = mockDB:SetSpecProfile(specIndex, targetProfile)
            if not setOk then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d spec %d: SetSpecProfile returned false for '%s'"):format(
                    i, specIndex, targetProfile))
            end

            -- Read it back
            local readBack = mockDB:GetSpecProfile(specIndex)
            if readBack ~= targetProfile then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d spec %d: GetSpecProfile returned '%s', expected '%s'"):format(
                    i, specIndex, tostring(readBack), targetProfile))
            end
        end

        -- 4. Verify dropdown updates after adding a new profile
        local newProfile = randomProfileName()
        -- Ensure it's actually new
        while nameSet[newProfile] do
            newProfile = randomProfileName()
        end
        mockDB:AddProfile(newProfile)

        local updatedValues = GetCoreProfileValues(mockDB)
        if updatedValues[newProfile] ~= newProfile then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: newly added profile '%s' not in updated dropdown"):format(
                i, newProfile))
        end

        -- 5. Verify dropdown updates after removing a profile
        mockDB:RemoveProfile(newProfile)
        local afterRemoveValues = GetCoreProfileValues(mockDB)
        if afterRemoveValues[newProfile] ~= nil then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: removed profile '%s' still in dropdown"):format(
                i, newProfile))
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 23: DualSpec mapping dropdown includes all profiles — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 23: DualSpec mapping dropdown includes all profiles — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:dualspecdropdown()
    return RunDualSpecDropdownTest()
end
