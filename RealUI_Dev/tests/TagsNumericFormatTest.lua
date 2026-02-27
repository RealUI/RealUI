local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Tag numeric format round-trip
-- Feature: hud-rewrite, Property 14: Tag numeric format round-trip
-- Validates: Requirements 20.12
--
-- For any numeric value n in [0, 100], string.format('%d', n) parsed back
-- to number equals floor(n). Pure Lua property test, no WoW API needed.

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

local function RunTagsNumericFormatTest()
    _G.print("|cff00ccff[PBT]|r Tag numeric format round-trip — running", NUM_ITERATIONS, "iterations")

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        -- Generate a random value in [0, 100] with decimal precision
        -- integer part 0-100, decimal part 0-99 -> e.g. 55.73
        local intPart = nextRandom(101) - 1  -- 0 to 100
        local decPart = nextRandom(100) - 1  -- 0 to 99
        local n = intPart + decPart / 100

        local formatted = _G.string.format('%d', n)
        local parsed = _G.tonumber(formatted)
        local expected = _G.math.floor(n)

        if parsed ~= expected then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: n=%.2f, format='%s', parsed=%s, expected=%d"):format(
                i, n, formatted, tostring(parsed), expected))
        end
    end

    -- Edge cases: exact integers and boundary values
    local edgeCases = {0, 1, 50, 99, 100, 0.0, 0.5, 99.9, 100.0, 33.33, 66.67}
    for _, n in _G.ipairs(edgeCases) do
        local formatted = _G.string.format('%d', n)
        local parsed = _G.tonumber(formatted)
        local expected = _G.math.floor(n)

        if parsed ~= expected then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r edge n=%.2f, format='%s', parsed=%s, expected=%d"):format(
                n, formatted, tostring(parsed), expected))
        end
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 14: Tag numeric format round-trip — %d iterations + %d edge cases passed"):format(
            NUM_ITERATIONS, #edgeCases))
    else
        _G.print(("|cffff0000[FAIL]|r Property 14: Tag numeric format round-trip — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:tagnumformat()
    return RunTagsNumericFormatTest()
end
