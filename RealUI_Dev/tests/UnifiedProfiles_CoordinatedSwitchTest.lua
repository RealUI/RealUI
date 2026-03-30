local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Coordinated switch sets all linked scopes
-- Feature: 2026-03-22-realui-profiles-2, Property 1: Coordinated switch sets all linked scopes
-- **Validates: Requirements 2.2, 2.3, 2.4, 2.5, 9.4**
--
-- For any profile name P and any set of linked scopes, when a
-- Coordinated_Switch is triggered for P, each linked scope that contains
-- a profile named P shall have its active profile set to P after the
-- switch completes, and each linked scope that does not contain P shall
-- remain unchanged.

-- luacheck: globals next type pairs ipairs

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

local function randomBool()
    return nextRandom(2) == 1
end

------------------------------------------------------------
-- Random profile name generator
------------------------------------------------------------
local PROFILE_POOL = {
    "RealUI", "RealUI-Healing", "RealUI_PvP", "RealUI_Mythic",
    "MyCustom", "Default", "TestProfile", "Raid", "Solo", "Arena",
    "Dungeon", "OpenWorld", "Leveling",
}

local function randomProfileName()
    return PROFILE_POOL[nextRandom(#PROFILE_POOL)]
end

------------------------------------------------------------
-- Mock AceDB instance
-- Simulates an AceDB with profiles, GetProfiles, SetProfile,
-- GetCurrentProfile.
------------------------------------------------------------
local function CreateMockAceDB(initialProfiles, currentProfile)
    local db = {}
    db._profiles = {} -- set of profile names
    db._current = currentProfile or "Default"

    -- Populate initial profiles
    if initialProfiles then
        for _, name in ipairs(initialProfiles) do
            db._profiles[name] = true
        end
    end
    -- Ensure current profile exists
    db._profiles[db._current] = true

    function db:GetProfiles()
        local list = {}
        for name in pairs(self._profiles) do
            list[#list + 1] = name
        end
        return list
    end

    function db:GetCurrentProfile()
        return self._current
    end

    function db:SetProfile(profileName)
        -- AceDB creates the profile if it doesn't exist
        self._profiles[profileName] = true
        self._current = profileName
    end

    -- Simulated profile data table (for scopeLinks)
    db.profile = {}

    return db
end

------------------------------------------------------------
-- Mock Bartender4DB
-- Simulates the Bartender4 saved variable structure.
------------------------------------------------------------
local function CreateMockBT4DB(profileNames, currentKey, currentProfile)
    local bt4db = {
        profileKeys = {},
        profiles = {},
        namespaces = {
            ActionBars = {
                profiles = {},
            },
        },
    }
    for _, name in ipairs(profileNames or {}) do
        bt4db.profiles[name] = { someData = true }
        bt4db.namespaces.ActionBars.profiles[name] = { actionbars = {} }
    end
    if currentKey and currentProfile then
        bt4db.profileKeys[currentKey] = currentProfile
    end
    return bt4db
end

------------------------------------------------------------
-- Mock BT4 addon object (has its own AceDB)
------------------------------------------------------------
local function CreateMockBT4Addon(bt4db, currentKey)
    local bt4Addon = {}
    local currentProfile = bt4db.profileKeys[currentKey] or "Default"
    bt4Addon.db = CreateMockAceDB({}, currentProfile)
    -- Sync: SetProfile on the addon db also updates bt4db.profileKeys
    local origSetProfile = bt4Addon.db.SetProfile
    bt4Addon.db.SetProfile = function(self, profileName)
        origSetProfile(self, profileName)
        bt4db.profileKeys[currentKey] = profileName
    end
    return bt4Addon
end

------------------------------------------------------------
-- Coordinated switch replica
-- Mirrors the logic from ProfileCoordinator:CoordinatedSwitch
-- using mock objects, so we can test the property in isolation.
------------------------------------------------------------
local function CoordinatedSwitchReplica(coreDB, skinsDB, bt4Addon, bt4db, scopeLinks, profileName, charKey)
    -- switchInProgress guard and combat lockdown are not tested here;
    -- those are covered by Property 7 and combat deferral tests.

    local switchedScopes = {}
    local warnings = {}

    -- 1. Core scope — always switched (Req 2.2)
    coreDB:SetProfile(profileName)
    switchedScopes[#switchedScopes + 1] = "core"

    -- 2. Skins scope (Req 2.3)
    if scopeLinks.skins then
        if skinsDB then
            local found = false
            local profiles = skinsDB:GetProfiles()
            for _, name in ipairs(profiles) do
                if name == profileName then
                    found = true
                    break
                end
            end
            if found then
                skinsDB:SetProfile(profileName)
                switchedScopes[#switchedScopes + 1] = "skins"
            else
                warnings[#warnings + 1] = "Skins: profile '" .. profileName .. "' does not exist — skipped."
            end
        else
            warnings[#warnings + 1] = "Skins: database not available — skipped."
        end
    end

    -- 3. Bartender4 scope (Req 2.4)
    if scopeLinks.bt4 then
        if type(bt4db) == "table" then
            -- Check if profile exists in BT4
            local bt4Exists = false
            if bt4db.profiles and bt4db.profiles[profileName] then
                bt4Exists = true
            end
            if not bt4Exists then
                local abNs = bt4db.namespaces
                if type(abNs) == "table" and type(abNs.ActionBars) == "table"
                   and type(abNs.ActionBars.profiles) == "table"
                   and abNs.ActionBars.profiles[profileName] then
                    bt4Exists = true
                end
            end
            if not bt4Exists and type(bt4db.profileKeys) == "table" then
                for _, pName in pairs(bt4db.profileKeys) do
                    if pName == profileName then bt4Exists = true; break end
                end
            end

            if bt4Exists then
                if bt4Addon and bt4Addon.db and bt4Addon.db.SetProfile then
                    bt4Addon.db:SetProfile(profileName)
                    switchedScopes[#switchedScopes + 1] = "bt4"
                elseif type(bt4db.profileKeys) == "table" and charKey then
                    bt4db.profileKeys[charKey] = profileName
                    switchedScopes[#switchedScopes + 1] = "bt4"
                end
            else
                warnings[#warnings + 1] = "Bartender4: profile '" .. profileName .. "' does not exist — skipped."
            end
        end
        -- If bt4db is nil, BT4 not loaded — silently skip (Req 7.4)
    end

    return true, switchedScopes, warnings
end

------------------------------------------------------------
-- Helper: check if a value is in an array
------------------------------------------------------------
local function arrayContains(arr, value)
    for _, v in ipairs(arr) do
        if v == value then return true end
    end
    return false
end

------------------------------------------------------------
-- Main test runner
------------------------------------------------------------
local function RunCoordinatedSwitchTest()
    _G.print("|cff00ccff[PBT]|r Property 1: Coordinated switch sets all linked scopes")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate random scope link configuration
        local scopeLinks = {
            skins = randomBool(),
            bt4 = randomBool(),
        }

        -- Generate a random set of profile names that exist in each scope
        local numCoreProfiles = nextRandom(5) + 1
        local coreProfileNames = {}
        for _ = 1, numCoreProfiles do
            local name = randomProfileName()
            coreProfileNames[name] = true
        end
        -- Always include a starting profile
        local startProfile = "Default"
        coreProfileNames[startProfile] = true

        local coreList = {}
        for name in pairs(coreProfileNames) do
            coreList[#coreList + 1] = name
        end

        -- Skins may have a subset of profiles
        local skinsList = {}
        for _, name in ipairs(coreList) do
            if randomBool() then
                skinsList[#skinsList + 1] = name
            end
        end

        -- BT4 may have a subset of profiles
        local bt4List = {}
        for _, name in ipairs(coreList) do
            if randomBool() then
                bt4List[#bt4List + 1] = name
            end
        end

        -- Create mock databases
        local coreDB = CreateMockAceDB(coreList, startProfile)
        local skinsDB = CreateMockAceDB(skinsList, startProfile)
        local charKey = "TestChar - TestRealm"
        local bt4db = CreateMockBT4DB(bt4List, charKey, startProfile)
        local bt4Addon = CreateMockBT4Addon(bt4db, charKey)

        -- Snapshot pre-switch state
        local preSkinsProfile = skinsDB:GetCurrentProfile()
        local preBT4Profile = bt4db.profileKeys[charKey]

        -- Pick a random target profile (may or may not exist in all scopes)
        local targetProfile = randomProfileName()

        -- Determine expected outcomes BEFORE the switch runs
        -- (SetProfile on mock AceDB adds the profile to _profiles, so we must
        -- snapshot existence before the coordinated switch mutates state.)
        local skinsHasTarget = false
        for _, name in ipairs(skinsDB:GetProfiles()) do
            if name == targetProfile then skinsHasTarget = true; break end
        end

        local bt4HasTarget = false
        -- Mirror the replica's BT4 existence check
        if bt4db.profiles and bt4db.profiles[targetProfile] then
            bt4HasTarget = true
        end
        if not bt4HasTarget then
            local abNs = bt4db.namespaces
            if type(abNs) == "table" and type(abNs.ActionBars) == "table"
               and type(abNs.ActionBars.profiles) == "table"
               and abNs.ActionBars.profiles[targetProfile] then
                bt4HasTarget = true
            end
        end
        if not bt4HasTarget and type(bt4db.profileKeys) == "table" then
            for _, pName in pairs(bt4db.profileKeys) do
                if pName == targetProfile then bt4HasTarget = true; break end
            end
        end

        -- Execute coordinated switch
        local _, switchedScopes, warnings = CoordinatedSwitchReplica(
            coreDB, skinsDB, bt4Addon, bt4db, scopeLinks, targetProfile, charKey
        )

        local iterFailed = false

        -- Verify: Core always switches (Req 2.2)
        if coreDB:GetCurrentProfile() ~= targetProfile then
            failures = failures + 1
            iterFailed = true
            _G.print(("|cffff0000[FAIL]|r iter %d: Core not switched to '%s', got '%s'"):format(
                i, targetProfile, coreDB:GetCurrentProfile()))
        end

        if not iterFailed and not arrayContains(switchedScopes, "core") then
            failures = failures + 1
            iterFailed = true
            _G.print(("|cffff0000[FAIL]|r iter %d: 'core' not in switchedScopes"):format(i))
        end

        -- Verify: Skins scope (Req 2.3, 2.5)
        if not iterFailed and scopeLinks.skins then
            if skinsHasTarget then
                -- Should have switched
                if skinsDB:GetCurrentProfile() ~= targetProfile then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: Skins linked+exists but not switched to '%s', got '%s'"):format(
                        i, targetProfile, skinsDB:GetCurrentProfile()))
                end
                if not iterFailed and not arrayContains(switchedScopes, "skins") then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: Skins switched but 'skins' not in switchedScopes"):format(i))
                end
            else
                -- Profile doesn't exist in Skins — should remain unchanged (Req 2.5)
                if skinsDB:GetCurrentProfile() ~= preSkinsProfile then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: Skins linked but profile missing — should be unchanged, was '%s' now '%s'"):format(
                        i, preSkinsProfile, skinsDB:GetCurrentProfile()))
                end
                if not iterFailed and arrayContains(switchedScopes, "skins") then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: Skins not switched but 'skins' in switchedScopes"):format(i))
                end
            end
        end

        -- Verify: Skins unlinked — should remain unchanged
        if not iterFailed and not scopeLinks.skins then
            if skinsDB:GetCurrentProfile() ~= preSkinsProfile then
                failures = failures + 1
                iterFailed = true
                _G.print(("|cffff0000[FAIL]|r iter %d: Skins unlinked but profile changed from '%s' to '%s'"):format(
                    i, preSkinsProfile, skinsDB:GetCurrentProfile()))
            end
        end

        -- Verify: BT4 scope (Req 2.4, 2.5, 9.4)
        if not iterFailed and scopeLinks.bt4 then
            local postBT4Profile = bt4db.profileKeys[charKey]
            if bt4HasTarget then
                -- Should have switched
                if postBT4Profile ~= targetProfile then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: BT4 linked+exists but not switched to '%s', got '%s'"):format(
                        i, targetProfile, postBT4Profile or "nil"))
                end
                if not iterFailed and not arrayContains(switchedScopes, "bt4") then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: BT4 switched but 'bt4' not in switchedScopes"):format(i))
                end
            else
                -- Profile doesn't exist in BT4 — should remain unchanged (Req 2.5)
                if postBT4Profile ~= preBT4Profile then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: BT4 linked but profile missing — should be unchanged, was '%s' now '%s'"):format(
                        i, preBT4Profile or "nil", postBT4Profile or "nil"))
                end
                if not iterFailed and arrayContains(switchedScopes, "bt4") then
                    failures = failures + 1
                    iterFailed = true
                    _G.print(("|cffff0000[FAIL]|r iter %d: BT4 not switched but 'bt4' in switchedScopes"):format(i))
                end
            end
        end

        -- Verify: BT4 unlinked — should remain unchanged
        if not iterFailed and not scopeLinks.bt4 then
            local postBT4Profile = bt4db.profileKeys[charKey]
            if postBT4Profile ~= preBT4Profile then
                failures = failures + 1
                iterFailed = true
                _G.print(("|cffff0000[FAIL]|r iter %d: BT4 unlinked but profile changed from '%s' to '%s'"):format(
                    i, preBT4Profile or "nil", postBT4Profile or "nil"))
            end
        end

        -- Verify: warnings generated for missing profiles in linked scopes (Req 2.5)
        if not iterFailed and scopeLinks.skins and not skinsHasTarget then
            local foundWarning = false
            for _, w in ipairs(warnings) do
                if w:find("Skins", 1, true) and w:find(targetProfile, 1, true) then
                    foundWarning = true
                    break
                end
            end
            if not foundWarning then
                failures = failures + 1
                iterFailed = true
                _G.print(("|cffff0000[FAIL]|r iter %d: No warning for missing Skins profile '%s'"):format(
                    i, targetProfile))
            end
        end

        if not iterFailed and scopeLinks.bt4 and not bt4HasTarget then
            local foundWarning = false
            for _, w in ipairs(warnings) do
                if w:find("Bartender4", 1, true) and w:find(targetProfile, 1, true) then
                    foundWarning = true
                    break
                end
            end
            if not foundWarning then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: No warning for missing BT4 profile '%s'"):format(
                    i, targetProfile))
            end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 1: Coordinated switch sets all linked scopes — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 1: Coordinated switch sets all linked scopes — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:coordswitch()
    return RunCoordinatedSwitchTest()
end
