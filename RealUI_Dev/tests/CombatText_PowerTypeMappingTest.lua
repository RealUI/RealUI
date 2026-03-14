local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Energize event handling (WoW 12 secret values)
-- Feature: combattext-wow12-update, Property 5: Energize handling
-- Validates: Requirements 3.6, 6.4
--
-- WoW 12 secret values: desc2 (power type string) is secret/tainted and
-- cannot be used as a table key. The code uses MESSAGE_TYPE_COLORS[messageType]
-- instead of POWER_TYPE_MAP[powerType]. The amount (desc1) is stored as
-- secretAmount (not amount) since arithmetic is forbidden on secret values.

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 659  -- unique seed
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

-- Power type strings (used as desc2 in HandleMessageType)
local POWER_TYPES = {
    "MANA", "RAGE", "FOCUS", "ENERGY", "COMBO_POINTS", "RUNES",
    "RUNIC_POWER", "SOUL_SHARDS", "LUNAR_POWER", "HOLY_POWER",
    "MAELSTROM", "CHI", "INSANITY", "ARCANE_CHARGES", "FURY", "PAIN",
}

-- Energize message types
local ENERGIZE_MSG_TYPES = { "ENERGIZE", "PERIODIC_ENERGIZE" }

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

    _G.print("|cff00ccff[PBT]|r Property 5: Energize handling — running", NUM_ITERATIONS, "iterations")

    local failures = 0

    -- Mock AddEvent to capture eventInfo
    local originalAddEvent = private.AddEvent
    local capturedEventInfo -- luacheck: ignore 311
    private.AddEvent = function(eventInfo)
        capturedEventInfo = eventInfo
    end

    for i = 1, NUM_ITERATIONS do
        local ptIdx = nextRandom(#POWER_TYPES)
        local powerType = POWER_TYPES[ptIdx]
        local amount = nextRandom(999999)
        local msgIdx = nextRandom(#ENERGIZE_MSG_TYPES)
        local messageType = ENERGIZE_MSG_TYPES[msgIdx]

        capturedEventInfo = nil
        -- WoW 12 signature: HandleMessageType(messageType, desc1, desc2)
        -- desc1 = amount (secret), desc2 = power type string (secret)
        private.HandleMessageType(messageType, amount, powerType)

        if not capturedEventInfo then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": HandleMessageType('" .. messageType .. "', " .. amount .. ", '" .. powerType .. "') produced no eventInfo")
        else
            -- Verify secretAmount == desc1 (the amount passed in)
            if capturedEventInfo.secretAmount ~= amount then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": secretAmount = "
                    .. _G.tostring(capturedEventInfo.secretAmount) .. ", expected " .. amount
                    .. " (messageType='" .. messageType .. "', powerType='" .. powerType .. "')")
            end

            -- Verify no 'amount' field (secret values can't be used for arithmetic)
            if capturedEventInfo.amount ~= nil then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": eventInfo.amount should be nil, got "
                    .. _G.tostring(capturedEventInfo.amount))
            end

            -- Verify no 'text' field (can't use secret desc2 as table key for POWER_TYPE_MAP)
            if capturedEventInfo.text ~= nil then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": eventInfo.text should be nil, got '"
                    .. _G.tostring(capturedEventInfo.text) .. "'")
            end

            -- Verify color: ENERGIZE/PERIODIC_ENERGIZE are NOT in MESSAGE_TYPE_COLORS,
            -- so eventInfo.color will be nil (no color override for energize in WoW 12)
            local expectedColor = private.MESSAGE_TYPE_COLORS[messageType]
            if expectedColor then
                -- If there IS a color entry, verify it matches
                if not capturedEventInfo.color then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": eventInfo.color is nil for '" .. messageType .. "'")
                elseif not approxEqual(capturedEventInfo.color.r, expectedColor.r)
                    or not approxEqual(capturedEventInfo.color.g, expectedColor.g)
                    or not approxEqual(capturedEventInfo.color.b, expectedColor.b)
                then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": Color mismatch for '" .. messageType
                        .. "' got (" .. _G.tostring(capturedEventInfo.color.r) .. "," .. _G.tostring(capturedEventInfo.color.g) .. "," .. _G.tostring(capturedEventInfo.color.b)
                        .. ") expected (" .. _G.tostring(expectedColor.r) .. "," .. _G.tostring(expectedColor.g) .. "," .. _G.tostring(expectedColor.b) .. ")")
                end
            end
            -- If no entry in MESSAGE_TYPE_COLORS, color may be nil — that's expected

            -- Verify canMerge == false (can't merge secret values)
            if capturedEventInfo.canMerge ~= false then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": canMerge = "
                    .. _G.tostring(capturedEventInfo.canMerge) .. ", expected false")
            end

            -- Verify isSticky == false (energize is never sticky)
            if capturedEventInfo.isSticky ~= false then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": isSticky = "
                    .. _G.tostring(capturedEventInfo.isSticky) .. ", expected false")
            end

            -- Verify scrollType == "notification"
            if capturedEventInfo.scrollType ~= "notification" then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Iteration " .. i .. ": scrollType = '"
                    .. _G.tostring(capturedEventInfo.scrollType) .. "', expected 'notification'")
            end
        end
    end

    -- Restore original AddEvent
    private.AddEvent = originalAddEvent

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r Property 5: Energize handling — passed")
    else
        _G.print("|cffff0000[FAIL]|r Property 5: Energize handling — " .. failures .. " failures")
    end

    return failures == 0
end

function ns.commands:ctpowertype()
    return RunTest()
end
