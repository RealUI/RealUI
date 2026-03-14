local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Color assignment
-- Feature: combattext-wow12-update, Property 4: Color assignment
-- Validates: Requirements 6.1-6.3

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 547  -- unique seed
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

-- Non-energize message types (ENERGIZE and PERIODIC_ENERGIZE excluded — not in MESSAGE_TYPE_COLORS table)
local DAMAGE_TYPES_LIST = {
    "DAMAGE", "DAMAGE_CRIT", "SPELL_DAMAGE", "SPELL_DAMAGE_CRIT", "DAMAGE_SHIELD", "SPLIT_DAMAGE",
}

local HEAL_TYPES_LIST = {
    "HEAL", "HEAL_CRIT", "PERIODIC_HEAL", "PERIODIC_HEAL_CRIT",
    "HEAL_ABSORB", "PERIODIC_HEAL_ABSORB", "HEAL_CRIT_ABSORB", "ABSORB_ADDED",
}

local MISS_TYPES_LIST = {
    "MISS", "DODGE", "PARRY", "EVADE", "IMMUNE", "DEFLECT", "BLOCK", "ABSORB", "RESIST",
    "SPELL_MISS", "SPELL_DODGE", "SPELL_PARRY", "SPELL_EVADE", "SPELL_IMMUNE",
    "SPELL_DEFLECT", "SPELL_REFLECT", "SPELL_BLOCK", "SPELL_ABSORB", "SPELL_RESIST",
}

-- Build flat list of all non-energize message types
local ALL_NON_ENERGIZE = {}
for _, t in _G.ipairs(DAMAGE_TYPES_LIST) do ALL_NON_ENERGIZE[#ALL_NON_ENERGIZE + 1] = t end
for _, t in _G.ipairs(HEAL_TYPES_LIST) do ALL_NON_ENERGIZE[#ALL_NON_ENERGIZE + 1] = t end
for _, t in _G.ipairs(MISS_TYPES_LIST) do ALL_NON_ENERGIZE[#ALL_NON_ENERGIZE + 1] = t end

-- Categorize for building correct call args
local DAMAGE_SET = {}
for _, t in _G.ipairs(DAMAGE_TYPES_LIST) do DAMAGE_SET[t] = true end
local HEAL_SET = {}
for _, t in _G.ipairs(HEAL_TYPES_LIST) do HEAL_SET[t] = true end

local EPSILON = 0.001

local function approxEqual(a, b)
    return _G.math.abs(a - b) < EPSILON
end

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

    if not private.MESSAGE_TYPE_COLORS then
        _G.print("|cffff0000[ERROR]|r private.MESSAGE_TYPE_COLORS not found")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Property 4: Color assignment — running", NUM_ITERATIONS, "iterations")

    local failures = 0

    -- Mock AddEvent to capture eventInfo
    local originalAddEvent = private.AddEvent
    local capturedEventInfo -- luacheck: ignore 311
    private.AddEvent = function(eventInfo)
        capturedEventInfo = eventInfo
    end

    for i = 1, NUM_ITERATIONS do
        local idx = nextRandom(#ALL_NON_ENERGIZE)
        local messageType = ALL_NON_ENERGIZE[idx]
        local amount = nextRandom(999999)

        -- Build appropriate args based on message type category
        -- WoW 12 signature: HandleMessageType(messageType, desc1, desc2)
        local desc1, desc2
        if DAMAGE_SET[messageType] then
            desc1 = amount
        elseif HEAL_SET[messageType] then
            desc1 = "TestHealer"
            desc2 = amount
        end
        -- Miss types: no desc1/desc2 needed

        capturedEventInfo = nil
        private.HandleMessageType(messageType, desc1, desc2)

        if not capturedEventInfo then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": HandleMessageType('" .. messageType .. "') produced no eventInfo")
        else
            local expectedColor = private.MESSAGE_TYPE_COLORS[messageType]
            if not expectedColor then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": No expected color in MESSAGE_TYPE_COLORS for '" .. messageType .. "'")
            elseif not capturedEventInfo.color then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": eventInfo.color is nil for '" .. messageType .. "'")
            else
                local cr, cg, cb = capturedEventInfo.color.r, capturedEventInfo.color.g, capturedEventInfo.color.b
                local er, eg, eb = expectedColor.r, expectedColor.g, expectedColor.b

                if not approxEqual(cr, er) or not approxEqual(cg, eg) or not approxEqual(cb, eb) then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": Color mismatch for '" .. messageType
                        .. "' got (" .. _G.tostring(cr) .. "," .. _G.tostring(cg) .. "," .. _G.tostring(cb)
                        .. ") expected (" .. _G.tostring(er) .. "," .. _G.tostring(eg) .. "," .. _G.tostring(eb) .. ")")
                end
            end
        end
    end

    -- Restore original AddEvent
    private.AddEvent = originalAddEvent

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r Property 4: Color assignment — passed")
    else
        _G.print("|cffff0000[FAIL]|r Property 4: Color assignment — " .. failures .. " failures")
    end

    return failures == 0
end

function ns.commands:ctcolorassign()
    return RunTest()
end
