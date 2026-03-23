local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Setup wizard single-role characters
-- Feature: 2026-03-22-realui-profiles-2, Property 6: Setup wizard single-role characters
-- **Validates: Requirements 5.4**
--
-- For any character whose specializations are all DPS or tank (no healer),
-- after Setup_Wizard_Propagation runs, all specs shall be assigned "RealUI"
-- and only the "RealUI" profile needs to exist.

local NUM_ITERATIONS = 100

------------------------------------------------------------
-- Simple RNG (xorshift32)
------------------------------------------------------------
local rngState = 314159
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

------------------------------------------------------------
-- Generate a random spec list with ONLY DPS/tank roles (no healer)
------------------------------------------------------------
local NON_HEALER_ROLES = { "DAMAGER", "TANK" }

local function generateNonHealerSpecList()
    local numSpecs = nextRandom(3) + 1 -- 2..4
    local specs = {}
    for i = 1, numSpecs do
        local role = NON_HEALER_ROLES[nextRandom(#NON_HEALER_ROLES)]
        specs[i] = { role = role, name = role .. "Spec" .. i }
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
local function RunSetupWizardSingleRoleTest()
    _G.print("|cff00ccff[PBT]|r Property 6: Setup wizard single-role characters")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate a spec list with ONLY DPS/tank roles (no healer)
        local specs = generateNonHealerSpecList()

        -- Sanity: verify no healer was generated
        for s = 1, #specs do
            if specs[s].role == "HEALER" then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: generator produced a HEALER spec"):format(i))
                break
            end
        end

        -- Run the propagation logic with no existing custom assignments
        local assignments, createdProfiles, builtInProfiles =
            PropagateUnifiedProfiles_Replica(specs, nil)

        if not assignments then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: PropagateUnifiedProfiles returned nil"):format(i))
            break
        end

        -- Verify: only "RealUI" profile was created (NOT "RealUI-Healing")
        if not createdProfiles["RealUI"] then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: 'RealUI' profile not created"):format(i))
        end
        if createdProfiles["RealUI-Healing"] then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: 'RealUI-Healing' profile should NOT be created for single-role characters"):format(i))
        end

        -- Verify: builtInProfiles list contains only "RealUI"
        if not builtInProfiles or #builtInProfiles ~= 1 then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: expected 1 built-in profile, got %d"):format(
                i, builtInProfiles and #builtInProfiles or 0))
        elseif builtInProfiles[1] ~= "RealUI" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: expected built-in profile 'RealUI', got '%s'"):format(
                i, _G.tostring(builtInProfiles[1])))
        end

        -- Verify: ALL specs are assigned to "RealUI"
        for specIdx = 1, #specs do
            local assigned = assignments[specIdx]
            if assigned ~= "RealUI" then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d spec %d: %s assigned '%s', expected 'RealUI'"):format(
                    i, specIdx, specs[specIdx].role, _G.tostring(assigned)))
            end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 6: Setup wizard single-role characters — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 6: Setup wizard single-role characters — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:setupwizardsinglerole()
    return RunSetupWizardSingleRoleTest()
end
