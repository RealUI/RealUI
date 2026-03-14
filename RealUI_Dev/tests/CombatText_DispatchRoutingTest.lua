local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Message type dispatch routing
-- Feature: combattext-wow12-update, Property 1: Message type dispatch
-- Validates: Requirements 3.1-3.6, 4.1-4.3

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 251
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

-- Expected scroll area routing for every known message type
local EXPECTED_ROUTING = {
    -- Damage types → "outgoing"
    DAMAGE            = "outgoing",
    DAMAGE_CRIT       = "outgoing",
    SPELL_DAMAGE      = "outgoing",
    SPELL_DAMAGE_CRIT = "outgoing",
    DAMAGE_SHIELD     = "outgoing",
    SPLIT_DAMAGE      = "outgoing",

    -- Healing types → "incoming"
    HEAL               = "incoming",
    HEAL_CRIT          = "incoming",
    PERIODIC_HEAL      = "incoming",
    PERIODIC_HEAL_CRIT = "incoming",
    HEAL_ABSORB           = "incoming",
    PERIODIC_HEAL_ABSORB  = "incoming",
    HEAL_CRIT_ABSORB      = "incoming",
    ABSORB_ADDED          = "incoming",

    -- Miss types → "notification"
    MISS    = "notification",  DODGE   = "notification",  PARRY    = "notification",
    EVADE   = "notification",  IMMUNE  = "notification",  DEFLECT  = "notification",
    BLOCK   = "notification",  ABSORB  = "notification",  RESIST   = "notification",
    SPELL_MISS    = "notification",  SPELL_DODGE   = "notification",
    SPELL_PARRY   = "notification",  SPELL_EVADE   = "notification",
    SPELL_IMMUNE  = "notification",  SPELL_DEFLECT = "notification",
    SPELL_REFLECT = "notification",  SPELL_BLOCK   = "notification",
    SPELL_ABSORB  = "notification",  SPELL_RESIST  = "notification",

    -- Energize types → "notification"
    ENERGIZE          = "notification",
    PERIODIC_ENERGIZE = "notification",
}

-- Categorize message types for amount extraction logic
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

local MISS_TYPES = {
    MISS = true, DODGE = true, PARRY = true, EVADE = true,
    IMMUNE = true, DEFLECT = true, BLOCK = true, ABSORB = true, RESIST = true,
    SPELL_MISS = true, SPELL_DODGE = true, SPELL_PARRY = true,
    SPELL_EVADE = true, SPELL_IMMUNE = true, SPELL_DEFLECT = true,
    SPELL_REFLECT = true, SPELL_BLOCK = true, SPELL_ABSORB = true,
    SPELL_RESIST = true,
}

local ENERGIZE_TYPES = {
    ENERGIZE = true,
    PERIODIC_ENERGIZE = true,
}

-- Build flat list of all message types for random selection
local ALL_MESSAGE_TYPES = {}
for msgType in _G.next, EXPECTED_ROUTING do
    ALL_MESSAGE_TYPES[#ALL_MESSAGE_TYPES + 1] = msgType
end

-- Known power type strings for energize tests
local POWER_TYPE_STRINGS = {"MANA", "RAGE", "FOCUS", "ENERGY", "RUNIC_POWER", "COMBO_POINTS"}

local function RunTest()
    local CombatText = _G.RealUI:GetModule("CombatText")
    if not CombatText then
        _G.print("|cffff0000[ERROR]|r CombatText module not available")
        return false
    end

    local private = CombatText._testPrivate
    if not private then
        _G.print("|cffff0000[ERROR]|r CombatText._testPrivate not exposed — add CombatText._testPrivate = private in RealUI_CombatText.lua")
        return false
    end

    if not private.HandleMessageType then
        _G.print("|cffff0000[ERROR]|r private.HandleMessageType not found")
        return false
    end

    if not private.SCROLL_AREA_ROUTING then
        _G.print("|cffff0000[ERROR]|r private.SCROLL_AREA_ROUTING not found")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Property 1: Message type dispatch routing — running", NUM_ITERATIONS, "iterations")

    local failures = 0

    -- Save original AddEvent and replace with capture mock
    local originalAddEvent = private.AddEvent
    local capturedEventInfo = nil
    private.AddEvent = function(eventInfo)
        capturedEventInfo = eventInfo
    end

    for i = 1, NUM_ITERATIONS do
        local idx = nextRandom(#ALL_MESSAGE_TYPES)
        local messageType = ALL_MESSAGE_TYPES[idx]
        local amount = nextRandom(999999)

        -- Build appropriate args based on message type category
        -- WoW 12 signature: HandleMessageType(messageType, desc1, desc2)
        local desc1, desc2
        if DAMAGE_TYPES[messageType] then
            desc1 = amount  -- secret amount
            desc2 = nil
        elseif HEAL_TYPES[messageType] then
            desc1 = "TestHealer"  -- source name
            desc2 = amount        -- secret amount
        elseif MISS_TYPES[messageType] then
            desc1 = nil
            desc2 = nil
        elseif ENERGIZE_TYPES[messageType] then
            desc1 = amount  -- secret amount
            local ptIdx = nextRandom(#POWER_TYPE_STRINGS)
            desc2 = POWER_TYPE_STRINGS[ptIdx]  -- secret power type string
        end

        capturedEventInfo = nil
        private.HandleMessageType(messageType, desc1, desc2)

        if not capturedEventInfo then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": HandleMessageType('" .. messageType .. "') produced no eventInfo")
        else
            -- Verify scrollType matches expected routing
            local expectedScroll = EXPECTED_ROUTING[messageType]
            if capturedEventInfo.scrollType ~= expectedScroll then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": scrollType for '" .. messageType
                    .. "' = '" .. _G.tostring(capturedEventInfo.scrollType)
                    .. "', expected '" .. expectedScroll .. "'")
            end

            -- WoW 12: damage/heal/energize use secretAmount, miss types use string
            if DAMAGE_TYPES[messageType] then
                if capturedEventInfo.secretAmount ~= amount then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": secretAmount for '" .. messageType
                        .. "' = " .. _G.tostring(capturedEventInfo.secretAmount)
                        .. ", expected " .. amount)
                end
            elseif HEAL_TYPES[messageType] then
                if capturedEventInfo.secretAmount ~= amount then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": secretAmount for '" .. messageType
                        .. "' = " .. _G.tostring(capturedEventInfo.secretAmount)
                        .. ", expected " .. amount)
                end
            elseif MISS_TYPES[messageType] then
                -- Miss types have string field, no amount/secretAmount
                if capturedEventInfo.string == nil then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": string for miss type '" .. messageType
                        .. "' is nil")
                end
            elseif ENERGIZE_TYPES[messageType] then
                if capturedEventInfo.secretAmount ~= amount then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": secretAmount for '" .. messageType
                        .. "' = " .. _G.tostring(capturedEventInfo.secretAmount)
                        .. ", expected " .. amount)
                end
            end

            -- All events must have canMerge == false (WoW 12 secret values)
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
        _G.print("|cff00ff00[PASS]|r Property 1: Message type dispatch routing — passed")
    else
        _G.print("|cffff0000[FAIL]|r Property 1: Message type dispatch routing — " .. failures .. " failures")
    end

    return failures == 0
end

function ns.commands:ctdispatch()
    return RunTest()
end
