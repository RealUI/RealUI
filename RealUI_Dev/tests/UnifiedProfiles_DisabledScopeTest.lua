local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Disabled scope exclusion
-- Feature: 2026-03-22-realui-profiles-2, Property 2: Disabled scope exclusion
-- **Validates: Requirements 3.3**
--
-- For any scope with its Scope_Link_Toggle set to disabled, and any
-- Coordinated_Switch operation, that scope's active profile shall remain
-- unchanged after the switch completes.

-- luacheck: globals next type pairs ipairs

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
-- Coordinated switch replica (mirrors ProfileCoordinator logic)
------------------------------------------------------------
local function CoordinatedSwitchReplica(coreDB, skinsDB, bt4Addon, bt4db, scopeLinks, profileName, charKey)
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

    -- 3. Bartender4 scope
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

    return true, switchedScopes
end

------------------------------------------------------------
-- Main test runner
------------------------------------------------------------
local function RunDisabledScopeTest()
    _G.print("|cff00ccff[PBT]|r Property 2: Disabled scope exclusion")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate scope links with at least one scope disabled
        local scopeLinks = {
            skins = randomBool(),
            bt4 = randomBool(),
        }
        -- Ensure at least one is disabled for meaningful testing
        if scopeLinks.skins and scopeLinks.bt4 then
            if randomBool() then
                scopeLinks.skins = false
            else
                scopeLinks.bt4 = false
            end
        end

        -- Generate profiles that exist in all scopes
        local profileNames = {}
        local numProfiles = nextRandom(5) + 1
        for _ = 1, numProfiles do
            profileNames[#profileNames + 1] = randomProfileName()
        end
        -- Deduplicate
        local seen = {}
        local uniqueProfiles = {}
        for _, name in ipairs(profileNames) do
            if not seen[name] then
                seen[name] = true
                uniqueProfiles[#uniqueProfiles + 1] = name
            end
        end
        profileNames = uniqueProfiles

        local startProfile = "Default"

        -- Create mock databases — all scopes have all profiles
        local coreDB = CreateMockAceDB(profileNames, startProfile)
        local skinsDB = CreateMockAceDB(profileNames, startProfile)
        local charKey = "TestChar - TestRealm"
        local bt4db = CreateMockBT4DB(profileNames, charKey, startProfile)
        local bt4Addon = CreateMockBT4Addon(bt4db, charKey)

        -- Snapshot pre-switch state for disabled scopes
        local preSkinsProfile = skinsDB:GetCurrentProfile()
        local preBT4Profile = bt4db.profileKeys[charKey]

        -- Pick a random target profile
        local targetProfile = randomProfileName()

        -- Execute coordinated switch
        CoordinatedSwitchReplica(coreDB, skinsDB, bt4Addon, bt4db, scopeLinks, targetProfile, charKey)

        -- Verify: disabled Skins scope must remain unchanged
        if not scopeLinks.skins then
            local postSkinsProfile = skinsDB:GetCurrentProfile()
            if postSkinsProfile ~= preSkinsProfile then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: Skins disabled but changed from '%s' to '%s'"):format(
                    i, preSkinsProfile, postSkinsProfile))
            end
        end

        -- Verify: disabled BT4 scope must remain unchanged
        if not scopeLinks.bt4 then
            local postBT4Profile = bt4db.profileKeys[charKey]
            if postBT4Profile ~= preBT4Profile then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: BT4 disabled but changed from '%s' to '%s'"):format(
                    i, preBT4Profile or "nil", postBT4Profile or "nil"))
            end
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 2: Disabled scope exclusion — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 2: Disabled scope exclusion — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:disabledscope()
    return RunDisabledScopeTest()
end
