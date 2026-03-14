local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Miss type text
-- Feature: combattext-wow12-update, Property 2: Miss type text
-- Validates: Requirements 3.4, 3.5

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 317
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

-- All 19 miss types
local MISS_TYPES = {
    "MISS", "DODGE", "PARRY", "EVADE", "IMMUNE", "DEFLECT", "BLOCK", "ABSORB", "RESIST",
    "SPELL_MISS", "SPELL_DODGE", "SPELL_PARRY", "SPELL_EVADE", "SPELL_IMMUNE",
    "SPELL_DEFLECT", "SPELL_REFLECT", "SPELL_BLOCK", "SPELL_ABSORB", "SPELL_RESIST",
}

-- Compute expected resultStr for a miss type
-- Non-SPELL_ types: _G[messageType]
-- SPELL_ types: _G[messageType] first, falling back to _G[stripped] (strip "SPELL_" prefix)
local function expectedResultStr(messageType)
    local globalVal = _G[messageType]
    if globalVal then
        return globalVal
    end
    -- Fallback: strip SPELL_ prefix and look up the base global
    local base = messageType:gsub("SPELL_", "")
    return _G[base]
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

    _G.print("|cff00ccff[PBT]|r Property 2: Miss type text — running", NUM_ITERATIONS, "iterations")

    local failures = 0

    -- Mock AddEvent to capture eventInfo
    local originalAddEvent = private.AddEvent
    local capturedEventInfo -- luacheck: ignore 311
    private.AddEvent = function(eventInfo)
        capturedEventInfo = eventInfo
    end

    for i = 1, NUM_ITERATIONS do
        local idx = nextRandom(#MISS_TYPES)
        local messageType = MISS_TYPES[idx]

        capturedEventInfo = nil
        -- WoW 12: HandleMessageType(messageType, desc1, desc2) — miss types have nil desc1/desc2
        private.HandleMessageType(messageType, nil, nil)

        if not capturedEventInfo then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": HandleMessageType('" .. messageType .. "') produced no eventInfo")
        else
            -- WoW 12: miss types store display text in eventInfo.string (not resultStr)
            local expected = expectedResultStr(messageType)
            if capturedEventInfo.string == nil then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": string for '" .. messageType .. "' is nil")
            elseif _G.type(capturedEventInfo.string) ~= "string" then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": string for '" .. messageType
                    .. "' is not a string, got " .. _G.type(capturedEventInfo.string))
            elseif capturedEventInfo.string ~= expected then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": string for '" .. messageType
                    .. "' = '" .. _G.tostring(capturedEventInfo.string)
                    .. "', expected '" .. _G.tostring(expected) .. "'")
            end

            -- Verify no amount or secretAmount field for miss types
            if capturedEventInfo.amount ~= nil then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": amount for miss type '" .. messageType
                    .. "' should be nil, got " .. _G.tostring(capturedEventInfo.amount))
            end
            if capturedEventInfo.secretAmount ~= nil then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": secretAmount for miss type '" .. messageType
                    .. "' should be nil, got " .. _G.tostring(capturedEventInfo.secretAmount))
            end

            -- Verify canMerge == false
            if capturedEventInfo.canMerge ~= false then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": canMerge for miss type '" .. messageType
                    .. "' = " .. _G.tostring(capturedEventInfo.canMerge) .. ", expected false")
            end
        end
    end

    -- Restore original AddEvent
    private.AddEvent = originalAddEvent

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r Property 2: Miss type text — passed")
    else
        _G.print("|cffff0000[FAIL]|r Property 2: Miss type text — " .. failures .. " failures")
    end

    return failures == 0
end

function ns.commands:ctmisstext()
    return RunTest()
end
