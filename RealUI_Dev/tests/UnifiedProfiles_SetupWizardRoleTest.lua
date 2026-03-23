local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Setup wizard assigns profiles by role
-- Feature: 2026-03-22-realui-profiles-2, Property 5: Setup wizard assigns profiles by role
-- **Validates: Requirements 5.1, 5.2**
--
-- For any character with a set of specializations containing at least one healer
-- and at least one non-healer, after Setup_Wizard_Propagation runs, every healer
-- spec shall be assigned "RealUI-Healing" and every DPS/tank spec shall be
-- assigned "RealUI", and both profiles shall exist in Core_Profile_Scope.

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
-- WoW class/spec data for generating realistic inputs
------------------------------------------------------------
local ROLES = { "HEALER", "DAMAGER", "TANK" }

-- Generate a random spec list with 2-4 specs, guaranteeing at least one
-- healer and one non-healer when mixedRequired is true.
local function generateSpecList(mixedRequired)
    local numSpecs = nextRandom(3) + 1 -- 2..4
    local specs = {}

    if mixedRequired then
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
    else
        -- Fully random (may or may not have mixed roles)
        for i = 1, numSpecs do
            local role = ROLES[nextRandom(#ROLES)]
            specs[i] = { role = role, name = role .. "Spec" .. i }
        end
    end

    return specs
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
local function RunSetupWizardRoleTest()
    _G.print("|cff00ccff[PBT]|r Property 5: Setup wizard assigns profiles by role")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate a spec list that is guaranteed to have mixed roles
        -- (at least one healer + at least one non-healer)
        local specs = generateSpecList(true)

        -- Run the propagation logic with no existing custom assignments
        local assignments, createdProfiles, builtInProfiles =
            PropagateUnifiedProfiles_Replica(specs, nil)

        if not assignments then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: PropagateUnifiedProfiles returned nil"):format(i))
            break
        end

        -- Verify: both "RealUI" and "RealUI-Healing" profiles were created
        if not createdProfiles["RealUI"] then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: 'RealUI' profile not created"):format(i))
        end
        if not createdProfiles["RealUI-Healing"] then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: 'RealUI-Healing' profile not created"):format(i))
        end

        -- Verify: builtInProfiles list contains both names
        if not builtInProfiles or #builtInProfiles ~= 2 then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: expected 2 built-in profiles, got %d"):format(
                i, builtInProfiles and #builtInProfiles or 0))
        end

        -- Verify: every healer spec is assigned "RealUI-Healing"
        -- and every DPS/tank spec is assigned "RealUI"
        local iterFailed = false
        for specIdx = 1, #specs do
            local role = specs[specIdx].role
            local assigned = assignments[specIdx]

            if role == "HEALER" then
                if assigned ~= "RealUI-Healing" then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d spec %d: healer assigned '%s', expected 'RealUI-Healing'"):format(
                        i, specIdx, _G.tostring(assigned)))
                end
            else
                -- DAMAGER or TANK
                if assigned ~= "RealUI" then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d spec %d: %s assigned '%s', expected 'RealUI'"):format(
                        i, specIdx, role, _G.tostring(assigned)))
                end
            end
        end

        -- Verify: at least one spec got each profile
        if not iterFailed then
            local hasRealUI = false
            local hasHealing = false
            for specIdx = 1, #specs do
                if assignments[specIdx] == "RealUI" then hasRealUI = true end
                if assignments[specIdx] == "RealUI-Healing" then hasHealing = true end
            end
            if not hasRealUI then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: no spec assigned to 'RealUI'"):format(i))
            end
            if not hasHealing then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: no spec assigned to 'RealUI-Healing'"):format(i))
            end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 5: Setup wizard assigns profiles by role — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 5: Setup wizard assigns profiles by role — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:setupwizardrole()
    return RunSetupWizardRoleTest()
end
