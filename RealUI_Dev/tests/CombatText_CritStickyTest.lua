local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Crit sticky and non-merge
-- Feature: combattext-wow12-update, Property 3: Crit sticky/non-merge
-- Validates: Requirements 3.8, 7.3

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 433  -- unique seed
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

-- The 4 crit types
local CRIT_TYPES = {
    "DAMAGE_CRIT",
    "SPELL_DAMAGE_CRIT",
    "HEAL_CRIT",
    "PERIODIC_HEAL_CRIT",
}

-- Damage crits vs heal crits have different call signatures
local DAMAGE_CRITS = {
    DAMAGE_CRIT = true,
    SPELL_DAMAGE_CRIT = true,
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

    _G.print("|cff00ccff[PBT]|r Property 3: Crit sticky/non-merge — running", NUM_ITERATIONS, "iterations")

    local failures = 0

    -- Mock AddEvent to capture eventInfo
    local originalAddEvent = private.AddEvent
    local capturedEventInfo = nil
    private.AddEvent = function(eventInfo)
        capturedEventInfo = eventInfo
    end

    for i = 1, NUM_ITERATIONS do
        local idx = nextRandom(#CRIT_TYPES)
        local messageType = CRIT_TYPES[idx]
        local amount = nextRandom(999999)

        -- Build appropriate args based on crit category
        -- WoW 12 signature: HandleMessageType(messageType, desc1, desc2)
        local desc1, desc2
        if DAMAGE_CRITS[messageType] then
            desc1 = amount  -- secret amount
            desc2 = nil
        else
            -- Heal crits: desc1 = healer name, desc2 = secret amount
            desc1 = "TestHealer"
            desc2 = amount
        end

        capturedEventInfo = nil
        private.HandleMessageType(messageType, desc1, desc2)

        if not capturedEventInfo then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": HandleMessageType('" .. messageType .. "') produced no eventInfo")
        else
            -- Verify isSticky == true
            if capturedEventInfo.isSticky ~= true then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": isSticky for '" .. messageType
                    .. "' = " .. _G.tostring(capturedEventInfo.isSticky) .. ", expected true")
            end

            -- Verify canMerge == false
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
        _G.print("|cff00ff00[PASS]|r Property 3: Crit sticky/non-merge — passed")
    else
        _G.print("|cffff0000[FAIL]|r Property 3: Crit sticky/non-merge — " .. failures .. " failures")
    end

    return failures == 0
end

function ns.commands:ctcritsticky()
    return RunTest()
end
