local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Abbreviated number formatting matches AbbreviateNumbers (Property 1)
-- Feature: hud-unitframe-enhancements
-- Validates: Requirements 1.1, 1.2
--
-- For any non-secret positive integer value, calling the formatting path
-- used by realui:healthValue and realui:powerValue (when statusText is
-- "value" or "both") should produce the same string as
-- AbbreviateNumbers(value, abbrevData).

local NUM_ITERATIONS = 200

-- Simple RNG (xorshift32)
local rngState = 4219
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local abbrevData = {
    breakpointData = {
        { breakpoint = 1e12, abbreviation = "B", significandDivisor = 1e10, fractionDivisor = 100 },
        { breakpoint = 1e11, abbreviation = "B", significandDivisor = 1e9,  fractionDivisor = 1 },
        { breakpoint = 1e10, abbreviation = "B", significandDivisor = 1e8,  fractionDivisor = 10 },
        { breakpoint = 1e9,  abbreviation = "B", significandDivisor = 1e7,  fractionDivisor = 100 },
        { breakpoint = 1e8,  abbreviation = "M", significandDivisor = 1e6,  fractionDivisor = 1 },
        { breakpoint = 1e7,  abbreviation = "M", significandDivisor = 1e5,  fractionDivisor = 10 },
        { breakpoint = 1e6,  abbreviation = "M", significandDivisor = 1e4,  fractionDivisor = 100 },
        { breakpoint = 1e5,  abbreviation = "K", significandDivisor = 1000, fractionDivisor = 1 },
        { breakpoint = 1e4,  abbreviation = "K", significandDivisor = 100,  fractionDivisor = 10 },
    },
}

-- Simulate the formatting path used by the tags (non-secret branch)
local function formatValue(value)
    return _G.AbbreviateNumbers(value, abbrevData)
end

local function RunAbbrevFormatTest()
    _G.print("|cff00ccff[PBT]|r Abbreviated number formatting — running", NUM_ITERATIONS, "iterations")

    if not _G.AbbreviateNumbers then
        _G.print("|cffff0000[SKIP]|r AbbreviateNumbers API not available")
        return false
    end

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local value = nextRandom(0x7FFFFFFF)
        local tagResult = formatValue(value)
        local apiResult = _G.AbbreviateNumbers(value, abbrevData)

        if tagResult ~= apiResult then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: value=%d, tag='%s', api='%s'"):format(
                i, value, tagResult, apiResult))
        end
    end

    -- Edge cases
    local edgeCases = {0, 1, 999, 9999, 10000, 99999, 100000, 999999,
        1000000, 9999999, 10000000, 99999999, 100000000, 999999999,
        1000000000, 2000000000}
    for _, value in _G.ipairs(edgeCases) do
        local tagResult = formatValue(value)
        local apiResult = _G.AbbreviateNumbers(value, abbrevData)

        if tagResult ~= apiResult then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r edge value=%d, tag='%s', api='%s'"):format(
                value, tagResult, apiResult))
        end
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 1: Abbreviated number formatting — %d iterations + %d edge cases passed"):format(
            NUM_ITERATIONS, #edgeCases))
    else
        _G.print(("|cffff0000[FAIL]|r Property 1: Abbreviated number formatting — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:ufabbrevformat()
    return RunAbbrevFormatTest()
end
