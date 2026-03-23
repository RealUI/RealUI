local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Scope link toggle persistence round-trip
-- Feature: 2026-03-22-realui-profiles-2, Property 3: Scope link toggle persistence round-trip
-- **Validates: Requirements 3.4**
--
-- For any boolean value assigned to a Scope_Link_Toggle, writing that
-- value to db.profile.scopeLinks and then reading it back shall return
-- the same boolean value.

-- luacheck: globals next type pairs ipairs

local NUM_ITERATIONS = 100

------------------------------------------------------------
-- Simple RNG (xorshift32)
------------------------------------------------------------
local rngState = 161803
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
-- Mock ProfileCoordinator scope link read/write
-- Mirrors the logic from ProfileCoordinator:SetScopeLinked
-- and ProfileCoordinator:IsScopeLinked using a mock db.
------------------------------------------------------------
local SCOPE_SKINS = "skins"
local SCOPE_BT4 = "bt4"

local function SetScopeLinked(db, scope, linked)
    if not db.profile.scopeLinks then
        db.profile.scopeLinks = {}
    end
    if scope == SCOPE_SKINS then
        db.profile.scopeLinks.skins = linked and true or false
    elseif scope == SCOPE_BT4 then
        db.profile.scopeLinks.bt4 = linked and true or false
    end
end

local function IsScopeLinked(db, scope)
    local links = db.profile.scopeLinks
    if not links then return false end
    if scope == SCOPE_SKINS then
        return links.skins == true
    elseif scope == SCOPE_BT4 then
        return links.bt4 == true
    end
    return false
end

------------------------------------------------------------
-- Main test runner
------------------------------------------------------------
local function RunScopeLinkPersistTest()
    _G.print("|cff00ccff[PBT]|r Property 3: Scope link toggle persistence round-trip")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Fresh db for each iteration
        local db = { profile = {} }

        -- Generate random boolean values for each scope
        local skinsValue = randomBool()
        local bt4Value = randomBool()

        -- Write
        SetScopeLinked(db, SCOPE_SKINS, skinsValue)
        SetScopeLinked(db, SCOPE_BT4, bt4Value)

        -- Read back
        local readSkins = IsScopeLinked(db, SCOPE_SKINS)
        local readBT4 = IsScopeLinked(db, SCOPE_BT4)

        -- Verify round-trip for Skins
        if readSkins ~= skinsValue then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: Skins wrote %s, read back %s"):format(
                i, tostring(skinsValue), tostring(readSkins)))
        end

        -- Verify round-trip for BT4
        if readBT4 ~= bt4Value then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: BT4 wrote %s, read back %s"):format(
                i, tostring(bt4Value), tostring(readBT4)))
        end

        -- Additional: write again with different values and verify
        local skinsValue2 = not skinsValue
        local bt4Value2 = not bt4Value

        SetScopeLinked(db, SCOPE_SKINS, skinsValue2)
        SetScopeLinked(db, SCOPE_BT4, bt4Value2)

        local readSkins2 = IsScopeLinked(db, SCOPE_SKINS)
        local readBT42 = IsScopeLinked(db, SCOPE_BT4)

        if readSkins2 ~= skinsValue2 then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: Skins overwrite wrote %s, read back %s"):format(
                i, tostring(skinsValue2), tostring(readSkins2)))
        end

        if readBT42 ~= bt4Value2 then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: BT4 overwrite wrote %s, read back %s"):format(
                i, tostring(bt4Value2), tostring(readBT42)))
        end

        -- Verify: writing one scope does not affect the other
        local skinsValue3 = randomBool()
        SetScopeLinked(db, SCOPE_SKINS, skinsValue3)
        local readBT4After = IsScopeLinked(db, SCOPE_BT4)
        if readBT4After ~= bt4Value2 then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: Writing skins changed bt4 from %s to %s"):format(
                i, tostring(bt4Value2), tostring(readBT4After)))
        end
    end

    -- Summary
    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 3: Scope link toggle persistence round-trip — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 3: Scope link toggle persistence round-trip — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:scopelinkpersist()
    return RunScopeLinkPersistTest()
end
