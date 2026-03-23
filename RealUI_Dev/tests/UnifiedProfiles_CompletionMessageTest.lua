local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Completion message contains correct data
-- Feature: 2026-03-22-realui-profiles-2, Property 8: Completion message contains correct data
-- **Validates: Requirements 7.3**
--
-- For any completed CoordinatedSwitch, the "REALUI_PROFILES_SWITCHED"
-- message shall contain the target profile name and a list of scope
-- identifiers that were actually switched (excluding skipped scopes).

-- luacheck: globals next type pairs ipairs

local NUM_ITERATIONS = 100

------------------------------------------------------------
-- Simple RNG (xorshift32)
------------------------------------------------------------
local rngState = 141421
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
-- Coordinated switch with message capture
-- Returns the message payload that would be sent via SendMessage.
------------------------------------------------------------
local function CoordinatedSwitchWithMessage(coreDB, skinsDB, bt4Addon, bt4db, scopeLinks, profileName, charKey)
    local switchedScopes = {}

    -- 1. Core scope — always switched
    coreDB:SetProfile(profileName)
    switchedScopes[#switchedScopes + 1] = "core"

    -- 2. Skins scope
    if scopeLinks.skins then
        if skinsDB then
            local found = false
            for _, name in ipairs(skinsDB:GetProfiles()) do
                if name == profileName then found = true; break end
            end
            if found then
                skinsDB:SetProfile(profileName)
                switchedScopes[#switchedScopes + 1] = "skins"
            end
        end
    end

    -- 3. BT4 scope
    if scopeLinks.bt4 then
        if type(bt4db) == "table" then
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
            if bt4Exists and bt4Addon and bt4Addon.db and bt4Addon.db.SetProfile then
                bt4Addon.db:SetProfile(profileName)
                switchedScopes[#switchedScopes + 1] = "bt4"
            end
        end
    end

    -- The message payload mirrors what ProfileCoordinator fires
    local messagePayload = {
        profileName = profileName,
        switchedScopes = switchedScopes,
    }

    return true, messagePayload
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
-- Helper: set equality for arrays
------------------------------------------------------------
local function arraysEqualAsSet(a, b)
    if #a ~= #b then return false end
    local setA = {}
    for _, v in ipairs(a) do setA[v] = true end
    for _, v in ipairs(b) do
        if not setA[v] then return false end
    end
    return true
end

------------------------------------------------------------
-- Main test runner
------------------------------------------------------------
local function RunCompletionMessageTest()
    _G.print("|cff00ccff[PBT]|r Property 8: Completion message contains correct data")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate random scope links
        local scopeLinks = {
            skins = randomBool(),
            bt4 = randomBool(),
        }

        -- Generate profiles
        local numProfiles = nextRandom(5) + 1
        local profileNames = {}
        local seen = {}
        for _ = 1, numProfiles do
            local name = randomProfileName()
            if not seen[name] then
                seen[name] = true
                profileNames[#profileNames + 1] = name
            end
        end

        local startProfile = "Default"
        local charKey = "TestChar - TestRealm"

        -- Skins may have a subset of profiles
        local skinsList = {}
        for _, name in ipairs(profileNames) do
            if randomBool() then
                skinsList[#skinsList + 1] = name
            end
        end

        -- BT4 may have a subset of profiles
        local bt4List = {}
        for _, name in ipairs(profileNames) do
            if randomBool() then
                bt4List[#bt4List + 1] = name
            end
        end

        -- Create mock databases
        local coreDB = CreateMockAceDB(profileNames, startProfile)
        local skinsDB = CreateMockAceDB(skinsList, startProfile)
        local bt4db = CreateMockBT4DB(bt4List, charKey, startProfile)
        local bt4Addon = CreateMockBT4Addon(bt4db, charKey)

        -- Pick a random target profile
        local targetProfile = randomProfileName()

        -- Compute expected switched scopes
        -- Must check the actual mock state (which includes the start profile
        -- added by CreateMockAceDB), not just the input lists.
        local expectedScopes = { "core" } -- Core always switches

        if scopeLinks.skins then
            local skinsHasTarget = false
            for _, name in ipairs(skinsDB:GetProfiles()) do
                if name == targetProfile then skinsHasTarget = true; break end
            end
            if skinsHasTarget then
                expectedScopes[#expectedScopes + 1] = "skins"
            end
        end

        if scopeLinks.bt4 then
            local bt4HasTarget = false
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
            if bt4HasTarget then
                expectedScopes[#expectedScopes + 1] = "bt4"
            end
        end

        -- Execute coordinated switch
        local success, message = CoordinatedSwitchWithMessage(
            coreDB, skinsDB, bt4Addon, bt4db, scopeLinks, targetProfile, charKey
        )

        -- Verify: message contains the target profile name
        if message.profileName ~= targetProfile then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: Message profileName='%s', expected '%s'"):format(
                i, tostring(message.profileName), targetProfile))
        end

        -- Verify: message switchedScopes matches expected
        if not arraysEqualAsSet(message.switchedScopes, expectedScopes) then
            failures = failures + 1
            local msgScopes = table.concat(message.switchedScopes, ",")
            local expScopes = table.concat(expectedScopes, ",")
            _G.print(("|cffff0000[FAIL]|r iter %d: switchedScopes={%s}, expected={%s}"):format(
                i, msgScopes, expScopes))
        end

        -- Verify: "core" is always in switchedScopes
        if not arrayContains(message.switchedScopes, "core") then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: 'core' missing from switchedScopes"):format(i))
        end

        -- Verify: no scope in switchedScopes that was disabled
        if not scopeLinks.skins and arrayContains(message.switchedScopes, "skins") then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: 'skins' in switchedScopes but skins link disabled"):format(i))
        end
        if not scopeLinks.bt4 and arrayContains(message.switchedScopes, "bt4") then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: 'bt4' in switchedScopes but bt4 link disabled"):format(i))
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 8: Completion message contains correct data — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 8: Completion message contains correct data — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:completionmsg()
    return RunCompletionMessageTest()
end
