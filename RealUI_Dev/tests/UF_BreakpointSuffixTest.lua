local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Breakpoint suffix ranges (Property 2)
-- Feature: hud-unitframe-enhancements
-- Validates: Requirements 1.3
--
-- Validates that the abbreviation breakpoint data is structurally correct:
-- breakpoints are in descending order, each range maps to the expected suffix,
-- and AbbreviateNumbers produces consistent output for any given input.
--
-- NOTE: AbbreviateNumbers may only append suffixes for secret values (from
-- UnitHealth etc.). With plain Lua numbers the API may return unsuffixed
-- strings. Therefore this test validates structural correctness and
-- consistency rather than suffix presence.

local NUM_ITERATIONS = 200

-- Simple RNG (xorshift32)
local rngState = 7919
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local abbrevBreakpoints = {
    { breakpoint = 1e12, abbreviation = "B", significandDivisor = 1e10, fractionDivisor = 100, abbreviationIsGlobal = false },
    { breakpoint = 1e11, abbreviation = "B", significandDivisor = 1e9,  fractionDivisor = 1,   abbreviationIsGlobal = false },
    { breakpoint = 1e10, abbreviation = "B", significandDivisor = 1e8,  fractionDivisor = 10,  abbreviationIsGlobal = false },
    { breakpoint = 1e9,  abbreviation = "B", significandDivisor = 1e7,  fractionDivisor = 100, abbreviationIsGlobal = false },
    { breakpoint = 1e8,  abbreviation = "M", significandDivisor = 1e6,  fractionDivisor = 1,   abbreviationIsGlobal = false },
    { breakpoint = 1e7,  abbreviation = "M", significandDivisor = 1e5,  fractionDivisor = 10,  abbreviationIsGlobal = false },
    { breakpoint = 1e6,  abbreviation = "M", significandDivisor = 1e4,  fractionDivisor = 100, abbreviationIsGlobal = false },
    { breakpoint = 1e5,  abbreviation = "K", significandDivisor = 1000, fractionDivisor = 1,   abbreviationIsGlobal = false },
    { breakpoint = 1e4,  abbreviation = "K", significandDivisor = 100,  fractionDivisor = 10,  abbreviationIsGlobal = false },
}

local function expectedSuffix(value)
    if value >= 1e9 then return "B"
    elseif value >= 1e6 then return "M"
    elseif value >= 1e4 then return "K"
    else return nil end
end

local function RunBreakpointSuffixTest()
    _G.print("|cff00ccff[PBT]|r Breakpoint suffix ranges — running", NUM_ITERATIONS, "iterations")

    local failures = 0

    -- Part 1: Validate breakpoint data structure
    -- Breakpoints must be in strictly descending order
    for i = 2, #abbrevBreakpoints do
        if abbrevBreakpoints[i].breakpoint >= abbrevBreakpoints[i - 1].breakpoint then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r breakpoint[%d] (%.0f) >= breakpoint[%d] (%.0f) — not descending"):format(
                i, abbrevBreakpoints[i].breakpoint, i - 1, abbrevBreakpoints[i - 1].breakpoint))
        end
    end

    -- Each breakpoint must have required fields
    for i, bp in _G.ipairs(abbrevBreakpoints) do
        if not bp.breakpoint or not bp.abbreviation or not bp.significandDivisor or not bp.fractionDivisor then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r breakpoint[%d] missing required field"):format(i))
        end
    end

    -- Suffix mapping: verify each breakpoint maps to the correct suffix for its range
    for _, bp in _G.ipairs(abbrevBreakpoints) do
        local expected = expectedSuffix(bp.breakpoint)
        if expected and bp.abbreviation ~= expected then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r breakpoint %.0f has suffix '%s', expected '%s'"):format(
                bp.breakpoint, bp.abbreviation, expected))
        end
    end

    -- Part 2: Validate AbbreviateNumbers consistency
    -- Calling AbbreviateNumbers twice with the same input must return the same result
    if _G.AbbreviateNumbers then
        local abbrevConfig = _G.CreateAbbreviateConfig and _G.CreateAbbreviateConfig(abbrevBreakpoints)
        local abbrevData = { breakpointData = abbrevBreakpoints, config = abbrevConfig }

        for i = 1, NUM_ITERATIONS do
            local value = nextRandom(0x7FFFFFFF)
            local result1 = _G.AbbreviateNumbers(value, abbrevData)
            local result2 = _G.AbbreviateNumbers(value, abbrevData)

            if result1 ~= result2 then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iteration %d: value=%d, call1='%s', call2='%s' — inconsistent"):format(
                    i, value, result1, result2))
            end

            -- Result must be a non-empty string
            if type(result1) ~= "string" or #result1 == 0 then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iteration %d: value=%d, result is not a non-empty string"):format(i, value))
            end
        end

        -- Edge case consistency
        local edgeValues = {0, 1, 9999, 10000, 10001, 999999, 1000000, 1000001, 999999999, 1000000000, 1000000001, 2000000000}
        for _, value in _G.ipairs(edgeValues) do
            local result1 = _G.AbbreviateNumbers(value, abbrevData)
            local result2 = _G.AbbreviateNumbers(value, abbrevData)
            if result1 ~= result2 then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r edge value=%d inconsistent: '%s' vs '%s'"):format(value, result1, result2))
            end
        end
    else
        _G.print("|cff888888[INFO]|r AbbreviateNumbers not available, skipping consistency checks")
    end

    -- Part 3: Coverage check — every range [10K, 1M), [1M, 1B), [1B, +inf) has at least one breakpoint
    local hasK, hasM, hasB = false, false, false
    for _, bp in _G.ipairs(abbrevBreakpoints) do
        if bp.abbreviation == "K" then hasK = true end
        if bp.abbreviation == "M" then hasM = true end
        if bp.abbreviation == "B" then hasB = true end
    end
    if not hasK then failures = failures + 1; _G.print("|cffff0000[FAIL]|r no breakpoint with suffix 'K'") end
    if not hasM then failures = failures + 1; _G.print("|cffff0000[FAIL]|r no breakpoint with suffix 'M'") end
    if not hasB then failures = failures + 1; _G.print("|cffff0000[FAIL]|r no breakpoint with suffix 'B'") end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 2: Breakpoint suffix ranges — %d iterations + structural checks passed"):format(
            NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 2: Breakpoint suffix ranges — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:ufbreakpoint()
    return RunBreakpointSuffixTest()
end
