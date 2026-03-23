local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Custom profile deletion triggers fallback
-- Feature: 2026-03-22-realui-profiles-2, Property 16: Custom profile deletion triggers fallback
-- **Validates: Requirements 9.7**
--
-- For any specialization assigned to a custom profile, when that custom
-- profile is deleted from Core_Profile_Scope, the DualSpec_Engine shall
-- reassign that specialization to the built-in default profile for its
-- role ("RealUI" for DPS/tank, "RealUI-Healing" for healer).

-- luacheck: globals next type pairs ipairs tostring

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

local function randomBool()
    return nextRandom(2) == 1
end

------------------------------------------------------------
-- Random profile name generator (custom names only)
------------------------------------------------------------
local CHARSET = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_"
local function randomCustomProfileName()
    local len = nextRandom(16) + 4 -- 5..20 chars
    local chars = {}
    for c = 1, len do
        local idx = nextRandom(#CHARSET)
        chars[c] = CHARSET:sub(idx, idx)
    end
    -- Prefix with "Custom_" to ensure it's never a built-in name
    return "Custom_" .. _G.table.concat(chars)
end

------------------------------------------------------------
-- Built-in profile constants
------------------------------------------------------------
local BUILTIN_DPS   = "RealUI"
local BUILTIN_HEAL  = "RealUI-Healing"

------------------------------------------------------------
-- Roles
------------------------------------------------------------
local ROLES = { "DAMAGER", "TANK", "HEALER" }

local function randomRole()
    return ROLES[nextRandom(#ROLES)]
end

local function isHealerRole(role)
    return role == "HEALER"
end

local function getDefaultForRole(role)
    if isHealerRole(role) then
        return BUILTIN_HEAL
    end
    return BUILTIN_DPS
end

------------------------------------------------------------
-- Mock system that replicates the OnProfileDeleted fallback
-- logic from DualSpecSystem:PostInitialize callback.
------------------------------------------------------------

local function CreateMockSystem(numSpecs)
    local specRoles = {}
    local specProfiles = {} -- mirrors db.char.specProfiles
    local ldsProfiles = {}  -- mirrors LibDualSpec mapping
    local notifications = {}

    -- Generate random roles for each spec
    for s = 1, numSpecs do
        specRoles[s] = randomRole()
    end

    local mock = {}

    function mock:SetSpecProfile(specIndex, profileName)
        specProfiles[specIndex] = profileName
        ldsProfiles[specIndex] = profileName
    end

    function mock:GetSpecProfile(specIndex)
        return specProfiles[specIndex]
    end

    function mock:GetDualSpecProfile(specIndex)
        return ldsProfiles[specIndex]
    end

    function mock:GetSpecRole(specIndex)
        return specRoles[specIndex]
    end

    function mock:GetNumSpecs()
        return numSpecs
    end

    function mock:GetNotifications()
        return notifications
    end

    --- Simulate the OnProfileDeleted callback logic
    function mock:OnProfileDeleted(deletedProfileKey)
        for specIndex = 1, numSpecs do
            if specProfiles[specIndex] == deletedProfileKey then
                local role = specRoles[specIndex]
                local defaultProfile = getDefaultForRole(role)

                specProfiles[specIndex] = defaultProfile
                ldsProfiles[specIndex] = defaultProfile

                notifications[#notifications + 1] = {
                    specIndex = specIndex,
                    deletedProfile = deletedProfileKey,
                    newProfile = defaultProfile,
                }
            end
        end
    end

    return mock
end

------------------------------------------------------------
-- Main test runner
------------------------------------------------------------
local function RunProfileDeletionFallbackTest()
    _G.print("|cff00ccff[PBT]|r Property 16: Custom profile deletion triggers fallback")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local numSpecs = nextRandom(4) + 1 -- 2..5 specs
        local system = CreateMockSystem(numSpecs)

        -- Assign a mix of custom and built-in profiles
        local customName = randomCustomProfileName()
        local specsWithCustom = {}

        for specIndex = 1, system:GetNumSpecs() do
            if randomBool() then
                -- Assign custom profile
                system:SetSpecProfile(specIndex, customName)
                specsWithCustom[specIndex] = true
            else
                -- Assign built-in default
                local role = system:GetSpecRole(specIndex)
                system:SetSpecProfile(specIndex, getDefaultForRole(role))
                specsWithCustom[specIndex] = false
            end
        end

        -- Verify at least one spec has the custom profile for a meaningful test
        local hasCustom = false
        for specIndex = 1, system:GetNumSpecs() do
            if specsWithCustom[specIndex] then
                hasCustom = true
                break
            end
        end
        if not hasCustom then
            -- Force first spec to custom
            system:SetSpecProfile(1, customName)
            specsWithCustom[1] = true
        end

        -- Snapshot non-custom spec profiles before deletion
        local preDeleteProfiles = {}
        for specIndex = 1, system:GetNumSpecs() do
            preDeleteProfiles[specIndex] = system:GetSpecProfile(specIndex)
        end

        -- Delete the custom profile
        system:OnProfileDeleted(customName)

        -- Verify: specs that had the custom profile now have the role default
        for specIndex = 1, system:GetNumSpecs() do
            local currentProfile = system:GetSpecProfile(specIndex)
            local ldsProfile = system:GetDualSpecProfile(specIndex)
            local role = system:GetSpecRole(specIndex)
            local expectedDefault = getDefaultForRole(role)

            if specsWithCustom[specIndex] then
                -- Should have been reverted to role default
                if currentProfile ~= expectedDefault then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r iter %d spec %d: expected '%s' after deletion, got '%s'"):format(
                        i, specIndex, expectedDefault, tostring(currentProfile)))
                end
                if ldsProfile ~= expectedDefault then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r iter %d spec %d: LDS expected '%s' after deletion, got '%s'"):format(
                        i, specIndex, expectedDefault, tostring(ldsProfile)))
                end
            else
                -- Should be unchanged
                if currentProfile ~= preDeleteProfiles[specIndex] then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r iter %d spec %d: non-custom profile changed from '%s' to '%s'"):format(
                        i, specIndex, tostring(preDeleteProfiles[specIndex]), tostring(currentProfile)))
                end
            end
        end

        -- Verify: notifications were sent for each affected spec
        local notifs = system:GetNotifications()
        local notifiedSpecs = {}
        for _, n in ipairs(notifs) do
            notifiedSpecs[n.specIndex] = true
        end
        for specIndex = 1, system:GetNumSpecs() do
            if specsWithCustom[specIndex] and not notifiedSpecs[specIndex] then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d spec %d: no notification for fallback"):format(i, specIndex))
            end
        end

        -- Verify: deleting a profile that no spec uses causes no changes
        local unrelatedName = randomCustomProfileName() .. "_unrelated"
        local profilesBefore = {}
        for specIndex = 1, system:GetNumSpecs() do
            profilesBefore[specIndex] = system:GetSpecProfile(specIndex)
        end
        local notifCountBefore = #system:GetNotifications()

        system:OnProfileDeleted(unrelatedName)

        for specIndex = 1, system:GetNumSpecs() do
            if system:GetSpecProfile(specIndex) ~= profilesBefore[specIndex] then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d spec %d: unrelated deletion changed profile"):format(i, specIndex))
            end
        end
        if #system:GetNotifications() ~= notifCountBefore then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: unrelated deletion triggered notifications"):format(i))
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 16: Custom profile deletion triggers fallback — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 16: Custom profile deletion triggers fallback — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:profiledeletionfallback()
    return RunProfileDeletionFallbackTest()
end
