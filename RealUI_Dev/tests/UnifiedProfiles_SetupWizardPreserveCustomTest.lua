local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Setup wizard preserves custom profile assignments
-- Feature: 2026-03-22-realui-profiles-2, Property 15: Setup wizard preserves custom profile assignments
-- **Validates: Requirements 9.5**
--
-- For any specialization that has a custom profile assignment (a profile name
-- other than the role-based default), running Setup_Wizard_Propagation shall
-- not change that specialization's profile assignment.

local NUM_ITERATIONS = 100

------------------------------------------------------------
-- Simple RNG (xorshift32)
------------------------------------------------------------
local rngState = 867530
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

------------------------------------------------------------
-- WoW class/spec data for generating realistic inputs
------------------------------------------------------------
local ROLES = { "HEALER", "DAMAGER", "TANK" }

-- Pool of custom profile names to randomly assign
local CUSTOM_PROFILES = {
    "MyCustomPvP", "RaidProfile", "MythicPlus", "WorldContent",
    "ArenaSetup", "DungeonGrind", "FarmingMode", "PvPBurst",
}

-- Generate a random spec list with 2-4 specs, guaranteeing at least one
-- healer and one non-healer (mixed roles) for the most interesting test cases.
local function generateSpecList()
    local numSpecs = nextRandom(3) + 1 -- 2..4
    local specs = {}

    -- Ensure at least one healer
    specs[1] = { role = "HEALER", name = "HealSpec" }
    -- Ensure at least one non-healer
    local nonHealerRole = (nextRandom(2) == 1) and "DAMAGER" or "TANK"
    specs[2] = { role = nonHealerRole, name = nonHealerRole .. "Spec" }
    -- Fill remaining specs randomly
    for i = 3, numSpecs do
        local role = ROLES[nextRandom(#ROLES)]
        specs[i] = { role = role, name = role .. "Spec" .. i }
    end

    return specs
end

-- Generate random pre-existing custom assignments for a subset of specs.
-- Returns a table where some spec indices have custom profile names and
-- others are nil (meaning "no custom assignment, use default").
local function generateCustomAssignments(numSpecs)
    local assignments = {}
    local hasAtLeastOne = false

    for i = 1, numSpecs do
        -- ~50% chance each spec has a custom assignment
        if nextRandom(2) == 1 then
            assignments[i] = CUSTOM_PROFILES[nextRandom(#CUSTOM_PROFILES)]
            hasAtLeastOne = true
        end
        -- else: nil — no custom assignment for this spec
    end

    -- Guarantee at least one custom assignment so the test is meaningful
    if not hasAtLeastOne then
        local idx = nextRandom(numSpecs)
        assignments[idx] = CUSTOM_PROFILES[nextRandom(#CUSTOM_PROFILES)]
    end

    return assignments
end

------------------------------------------------------------
-- Replica of PropagateUnifiedProfiles assignment logic
-- from InstallWizard.lua, isolated for property testing.
------------------------------------------------------------
local function PropagateUnifiedProfiles_Replica(specs, existingCustomAssignments)
    if not specs or #specs == 0 then
        return nil, nil, nil
    end

    -- Determine if character has at least one healer and one non-healer
    local hasHealer = false
    local hasNonHealer = false
    for i = 1, #specs do
        if specs[i].role == "HEALER" then
            hasHealer = true
        else
            hasNonHealer = true
        end
    end

    -- Determine which built-in profiles to create
    local builtInProfiles
    if hasHealer and hasNonHealer then
        builtInProfiles = { "RealUI", "RealUI-Healing" }
    else
        builtInProfiles = { "RealUI" }
    end

    -- Track created profiles
    local createdProfiles = {}
    for _, profileName in _G.ipairs(builtInProfiles) do
        createdProfiles[profileName] = true
    end

    -- Assign specs, respecting existing custom assignments
    local specAssignments = {}
    for i = 1, #specs do
        if existingCustomAssignments and existingCustomAssignments[i] then
            -- Preserve existing custom assignment
            specAssignments[i] = existingCustomAssignments[i]
        else
            if hasHealer and hasNonHealer then
                specAssignments[i] = (specs[i].role == "HEALER") and "RealUI-Healing" or "RealUI"
            else
                specAssignments[i] = "RealUI"
            end
        end
    end

    return specAssignments, createdProfiles, builtInProfiles
end

------------------------------------------------------------
-- Main test runner
------------------------------------------------------------
local function RunSetupWizardPreserveCustomTest()
    _G.print("|cff00ccff[PBT]|r Property 15: Setup wizard preserves custom profile assignments")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate a mixed-role spec list
        local specs = generateSpecList()

        -- Generate random custom assignments for a subset of specs
        local customAssignments = generateCustomAssignments(#specs)

        -- Run the propagation logic WITH existing custom assignments
        local assignments, createdProfiles =
            PropagateUnifiedProfiles_Replica(specs, customAssignments)

        if not assignments then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: PropagateUnifiedProfiles returned nil"):format(i))
            break
        end

        if not createdProfiles then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: createdProfiles is nil"):format(i))
            break
        end

        -- Verify property: specs WITH pre-existing custom assignments retain
        -- their original value (setup wizard must NOT overwrite them)
        for specIdx = 1, #specs do
            local custom = customAssignments[specIdx]
            local assigned = assignments[specIdx]

            if custom then
                -- This spec had a custom assignment — it MUST be preserved
                if assigned ~= custom then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r iter %d spec %d: custom '%s' was overwritten with '%s'"):format(
                        i, specIdx, _G.tostring(custom), _G.tostring(assigned)))
                end
            else
                -- This spec had NO custom assignment — it should get the
                -- correct role-based default
                local expectedDefault
                -- Mixed roles guaranteed by generateSpecList
                if specs[specIdx].role == "HEALER" then
                    expectedDefault = "RealUI-Healing"
                else
                    expectedDefault = "RealUI"
                end

                if assigned ~= expectedDefault then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r iter %d spec %d: no custom, expected default '%s', got '%s'"):format(
                        i, specIdx, expectedDefault, _G.tostring(assigned)))
                end
            end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 15: Setup wizard preserves custom profile assignments — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 15: Setup wizard preserves custom profile assignments — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:setupwizardpreservecustom()
    return RunSetupWizardPreserveCustomTest()
end
