local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: All events have canMerge=false (WoW 12 secret values)
-- Feature: combattext-wow12-update, Property 6: No merge (secret values)
-- Validates: Requirements 7.1, 7.2
--
-- WoW 12 secret values cannot be used for arithmetic, so merge grouping
-- is disabled. All events produced by HandleMessageType must have canMerge=false,
-- meaning they go directly to the event queue and never enter the merge queue.

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 773
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

-- All message types that previously could merge (non-crit damage, heals, energize)
local ALL_MESSAGE_TYPES = {
    "DAMAGE", "SPELL_DAMAGE", "DAMAGE_SHIELD", "SPLIT_DAMAGE",
    "HEAL", "PERIODIC_HEAL",
    "HEAL_ABSORB", "PERIODIC_HEAL_ABSORB", "ABSORB_ADDED",
    "ENERGIZE", "PERIODIC_ENERGIZE",
    -- Also include crit and miss types for completeness
    "DAMAGE_CRIT", "SPELL_DAMAGE_CRIT", "HEAL_CRIT", "PERIODIC_HEAL_CRIT",
    "HEAL_CRIT_ABSORB",
    "MISS", "DODGE", "PARRY", "BLOCK", "ABSORB", "RESIST",
}

-- Categorize for building correct call args
local DAMAGE_TYPES = {
    DAMAGE = true, DAMAGE_CRIT = true,
    SPELL_DAMAGE = true, SPELL_DAMAGE_CRIT = true,
    DAMAGE_SHIELD = true, SPLIT_DAMAGE = true,
}
local HEAL_TYPES = {
    HEAL = true, HEAL_CRIT = true,
    PERIODIC_HEAL = true, PERIODIC_HEAL_CRIT = true,
    HEAL_ABSORB = true, PERIODIC_HEAL_ABSORB = true,
    HEAL_CRIT_ABSORB = true, ABSORB_ADDED = true,
}
local ENERGIZE_TYPES = {
    ENERGIZE = true, PERIODIC_ENERGIZE = true,
}

local function RunTest()
    local CombatText = _G.RealUI:GetModule("CombatText")
    if not CombatText then
        _G.print("|cffff0000[ERROR]|r CombatText module not available")
        return false
    end

    local private = CombatText._testPrivate
    if not private then
        _G.print("|cffff0000[ERROR]|r CombatText._testPrivate not exposed")
        return false
    end

    if not private.HandleMessageType then
        _G.print("|cffff0000[ERROR]|r private.HandleMessageType not found")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Property 6: No merge (secret values) — running", NUM_ITERATIONS, "iterations")

    local failures = 0

    -- Mock AddEvent to capture eventInfo
    local originalAddEvent = private.AddEvent
    local capturedEventInfo -- luacheck: ignore 311
    private.AddEvent = function(eventInfo)
        capturedEventInfo = eventInfo
    end

    for i = 1, NUM_ITERATIONS do
        local idx = nextRandom(#ALL_MESSAGE_TYPES)
        local messageType = ALL_MESSAGE_TYPES[idx]
        local amount = nextRandom(999999)

        -- Build appropriate args: HandleMessageType(messageType, desc1, desc2)
        local desc1, desc2
        if DAMAGE_TYPES[messageType] then
            desc1 = amount
        elseif HEAL_TYPES[messageType] then
            desc1 = "TestHealer"
            desc2 = amount
        elseif ENERGIZE_TYPES[messageType] then
            desc1 = amount
            desc2 = "MANA"
        end
        -- Miss types: desc1=nil, desc2=nil

        capturedEventInfo = nil
        private.HandleMessageType(messageType, desc1, desc2)

        if not capturedEventInfo then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": HandleMessageType('" .. messageType .. "') produced no eventInfo")
        else
            -- Core property: canMerge must always be false
            if capturedEventInfo.canMerge ~= false then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": canMerge for '" .. messageType
                    .. "' = " .. _G.tostring(capturedEventInfo.canMerge) .. ", expected false")
            end
        end
    end

    -- Restore original AddEvent
    private.AddEvent = originalAddEvent

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r Property 6: No merge (secret values) — passed")
    else
        _G.print("|cffff0000[FAIL]|r Property 6: No merge (secret values) — " .. failures .. " failures")
    end

    return failures == 0
end

function ns.commands:ctmergequeue()
    return RunTest()
end
