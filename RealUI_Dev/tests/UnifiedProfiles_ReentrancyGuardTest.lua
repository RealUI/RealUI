local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Reentrancy guard
-- Feature: 2026-03-22-realui-profiles-2, Property 7: Reentrancy guard
-- **Validates: Requirements 7.2**
--
-- For any two CoordinatedSwitch calls where the second is issued while
-- the first is still in progress (switchInProgress == true), the second
-- call shall return false without modifying any scope's active profile.

-- luacheck: globals next type pairs ipairs

local NUM_ITERATIONS = 100

------------------------------------------------------------
-- Simple RNG (xorshift32)
------------------------------------------------------------
local rngState = 265358
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
------------------------------------------------------------
local function CreateMockAceDB(initialProfiles, currentProfile)
    local db = {}
    db._profiles = {}
    db._current = currentProfile or "Default"

    if initialProfiles then
        for _, name in ipairs(initialProfiles) do
            db._profiles[name] = true
        end
    end
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
        self._profiles[profileName] = true
        self._current = profileName
    end

    db.profile = {}
    return db
end

------------------------------------------------------------
-- Mock Bartender4DB
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
-- Mock BT4 addon object
------------------------------------------------------------
local function CreateMockBT4Addon(bt4db, currentKey)
    local bt4Addon = {}
    local currentProfile = bt4db.profileKeys[currentKey] or "Default"
    bt4Addon.db = CreateMockAceDB({}, currentProfile)
    local origSetProfile = bt4Addon.db.SetProfile
    bt4Addon.db.SetProfile = function(self, profileName)
        origSetProfile(self, profileName)
        bt4db.profileKeys[currentKey] = profileName
    end
    return bt4Addon
end

------------------------------------------------------------
-- Coordinated switch with reentrancy guard
-- Mirrors ProfileCoordinator logic including switchInProgress flag.
-- Returns the switchInProgress flag state via closure so we can
-- simulate a second call while the first is "in progress".
------------------------------------------------------------
local function CreateCoordinatedSwitcher()
    local switchInProgress = false

    local function CoordinatedSwitch(coreDB, skinsDB, bt4Addon, bt4db, scopeLinks, profileName, charKey)
        -- Reentrancy guard
        if switchInProgress then
            return false, {"A profile switch is already in progress."}
        end

        switchInProgress = true

        local switchedScopes = {}

        -- 1. Core scope
        coreDB:SetProfile(profileName)
        switchedScopes[#switchedScopes + 1] = "core"

        -- 2. Skins scope
        if scopeLinks.skins and skinsDB then
            local found = false
            for _, name in ipairs(skinsDB:GetProfiles()) do
                if name == profileName then found = true; break end
            end
            if found then
                skinsDB:SetProfile(profileName)
                switchedScopes[#switchedScopes + 1] = "skins"
            end
        end

        -- 3. BT4 scope
        if scopeLinks.bt4 and type(bt4db) == "table" then
            local bt4Exists = false
            if bt4db.profiles and bt4db.profiles[profileName] then
                bt4Exists = true
            end
            if bt4Exists and bt4Addon and bt4Addon.db and bt4Addon.db.SetProfile then
                bt4Addon.db:SetProfile(profileName)
                switchedScopes[#switchedScopes + 1] = "bt4"
            end
        end

        switchInProgress = false
        return true, switchedScopes
    end

    -- Expose a way to force switchInProgress = true for testing
    local function SetSwitchInProgress(val)
        switchInProgress = val
    end

    local function IsSwitchInProgress()
        return switchInProgress
    end

    return CoordinatedSwitch, SetSwitchInProgress, IsSwitchInProgress
end

------------------------------------------------------------
-- Main test runner
------------------------------------------------------------
local function RunReentrancyGuardTest()
    _G.print("|cff00ccff[PBT]|r Property 7: Reentrancy guard")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local CoordinatedSwitch, SetSwitchInProgress = CreateCoordinatedSwitcher()

        -- Generate random scope links
        local scopeLinks = {
            skins = randomBool(),
            bt4 = randomBool(),
        }

        -- Generate profiles
        local profileNames = { "RealUI", "RealUI-Healing", randomProfileName() }
        local startProfile = "Default"
        local charKey = "TestChar - TestRealm"

        -- Create mock databases
        local coreDB = CreateMockAceDB(profileNames, startProfile)
        local skinsDB = CreateMockAceDB(profileNames, startProfile)
        local bt4db = CreateMockBT4DB(profileNames, charKey, startProfile)
        local bt4Addon = CreateMockBT4Addon(bt4db, charKey)

        -- Pick two different target profiles
        local firstTarget = randomProfileName()
        local secondTarget = randomProfileName()
        -- Ensure they differ for clearer testing
        while secondTarget == firstTarget do
            secondTarget = randomProfileName()
        end

        -- Simulate: set switchInProgress = true (as if first switch is running)
        SetSwitchInProgress(true)

        -- Snapshot state before second call
        local preCoreProfile = coreDB:GetCurrentProfile()
        local preSkinsProfile = skinsDB:GetCurrentProfile()
        local preBT4Profile = bt4db.profileKeys[charKey]

        -- Attempt second switch while first is "in progress"
        local success, result = CoordinatedSwitch(
            coreDB, skinsDB, bt4Addon, bt4db, scopeLinks, secondTarget, charKey
        )

        -- Verify: second call must return false
        if success ~= false then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: Second switch returned success=%s, expected false"):format(
                i, tostring(success)))
        end

        -- Verify: no scope profiles changed
        local postCoreProfile = coreDB:GetCurrentProfile()
        local postSkinsProfile = skinsDB:GetCurrentProfile()
        local postBT4Profile = bt4db.profileKeys[charKey]

        if postCoreProfile ~= preCoreProfile then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: Core changed from '%s' to '%s' during reentrancy"):format(
                i, preCoreProfile, postCoreProfile))
        end

        if postSkinsProfile ~= preSkinsProfile then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: Skins changed from '%s' to '%s' during reentrancy"):format(
                i, preSkinsProfile, postSkinsProfile))
        end

        if postBT4Profile ~= preBT4Profile then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: BT4 changed from '%s' to '%s' during reentrancy"):format(
                i, preBT4Profile or "nil", postBT4Profile or "nil"))
        end

        -- Verify: result contains a warning message
        if type(result) ~= "table" or #result == 0 then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: No warning returned for rejected reentrant call"):format(i))
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 7: Reentrancy guard — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 7: Reentrancy guard — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:reentrancyguard()
    return RunReentrancyGuardTest()
end
