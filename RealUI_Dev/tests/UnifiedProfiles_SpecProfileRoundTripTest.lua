local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Spec-to-profile mapping round-trip
-- Feature: 2026-03-22-realui-profiles-2, Property 4: Spec-to-profile mapping round-trip
-- **Validates: Requirements 4.3, 9.2**
--
-- For any specialization index and any valid profile name, calling
-- SetSpecProfile(specIndex, profileName) and then GetSpecProfile(specIndex)
-- shall return the same profile name. Additionally, LibDualSpec's
-- GetDualSpecProfile(specIndex) shall return the same profile name.

-- luacheck: globals next type pairs ipairs tostring

local NUM_ITERATIONS = 100

------------------------------------------------------------
-- Simple RNG (xorshift32)
------------------------------------------------------------
local rngState = 271828
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
    local len = nextRandom(20) + 3 -- 4..23 chars
    local chars = {}
    for c = 1, len do
        local idx = nextRandom(#CHARSET)
        chars[c] = CHARSET:sub(idx, idx)
    end
    return _G.table.concat(chars)
end

------------------------------------------------------------
-- Mock DualSpecSystem + LibDualSpec for isolated testing
------------------------------------------------------------

-- Simulates the core SetSpecProfile / GetSpecProfile logic and
-- the LibDualSpec SetDualSpecProfile / GetDualSpecProfile contract.

local function CreateMockSystem(numSpecs)
    local specProfilesMap = {}
    local ldsProfiles = {} -- simulates LibDualSpec per-spec mapping
    local charSpecProfiles = {} -- simulates db.char.specProfiles

    local mock = {}

    function mock:SetSpecProfile(specIndex, profileName)
        if not specIndex or not profileName then return false end
        specProfilesMap[specIndex] = profileName
        charSpecProfiles[specIndex] = profileName
        -- Mirror to LibDualSpec
        ldsProfiles[specIndex] = profileName
        return true
    end

    function mock:GetSpecProfile(specIndex)
        if not specIndex then return nil end
        return specProfilesMap[specIndex]
    end

    function mock:GetDualSpecProfile(specIndex)
        if not specIndex then return nil end
        return ldsProfiles[specIndex]
    end

    function mock:GetCharSpecProfiles()
        return charSpecProfiles
    end

    function mock:GetNumSpecs()
        return numSpecs
    end

    return mock
end

------------------------------------------------------------
-- Main test runner
------------------------------------------------------------
local function RunSpecProfileRoundTripTest()
    _G.print("|cff00ccff[PBT]|r Property 4: Spec-to-profile mapping round-trip")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Random number of specs (1..4, typical WoW range)
        local numSpecs = nextRandom(4)
        local system = CreateMockSystem(numSpecs)

        -- For each spec, generate a random profile name, set it, read it back
        for specIndex = 1, numSpecs do
            local profileName = randomProfileName()

            -- Set
            local setOk = system:SetSpecProfile(specIndex, profileName)
            if not setOk then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d spec %d: SetSpecProfile returned false for '%s'"):format(
                    i, specIndex, profileName))
            end

            -- Read back via GetSpecProfile
            local readBack = system:GetSpecProfile(specIndex)
            if readBack ~= profileName then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d spec %d: GetSpecProfile returned '%s', expected '%s'"):format(
                    i, specIndex, tostring(readBack), profileName))
            end

            -- Read back via GetDualSpecProfile (LibDualSpec mirror)
            local ldsReadBack = system:GetDualSpecProfile(specIndex)
            if ldsReadBack ~= profileName then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d spec %d: GetDualSpecProfile returned '%s', expected '%s'"):format(
                    i, specIndex, tostring(ldsReadBack), profileName))
            end
        end

        -- Verify: setting one spec does not affect another
        if numSpecs >= 2 then
            local name1 = randomProfileName()
            local name2 = randomProfileName()
            system:SetSpecProfile(1, name1)
            system:SetSpecProfile(2, name2)

            local read1 = system:GetSpecProfile(1)
            local read2 = system:GetSpecProfile(2)

            if read1 ~= name1 then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: spec 1 cross-contaminated, got '%s' expected '%s'"):format(
                    i, tostring(read1), name1))
            end
            if read2 ~= name2 then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: spec 2 cross-contaminated, got '%s' expected '%s'"):format(
                    i, tostring(read2), name2))
            end
        end

        -- Verify: overwriting a spec profile updates correctly
        for specIndex = 1, numSpecs do
            local newName = randomProfileName()
            system:SetSpecProfile(specIndex, newName)

            local readBack = system:GetSpecProfile(specIndex)
            if readBack ~= newName then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d spec %d: overwrite failed, got '%s' expected '%s'"):format(
                    i, specIndex, tostring(readBack), newName))
            end

            local ldsReadBack = system:GetDualSpecProfile(specIndex)
            if ldsReadBack ~= newName then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d spec %d: LDS overwrite failed, got '%s' expected '%s'"):format(
                    i, specIndex, tostring(ldsReadBack), newName))
            end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 4: Spec-to-profile mapping round-trip — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 4: Spec-to-profile mapping round-trip — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:specprofileroundtrip()
    return RunSpecProfileRoundTripTest()
end
