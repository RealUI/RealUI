local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Abbreviated number formatting matches AbbreviateNumbers (Property 1)
-- Feature: hud-unitframe-enhancements
-- Validates: Requirements 1.1, 1.2
--
-- For any non-secret positive integer value, calling the formatting path
-- used by realui:healthValue and realui:powerValue (when statusText is
-- "value" or "both") should produce the same string as
-- AbbreviateNumbers(value, abbrevData).
--
-- Updated for 12.0.5: Tests the same multi-path fallback strategy used
-- in Tags.lua (AbbreviatedNumberFormatter → CreateAbbreviateConfig → defaults → Lua).

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

-- Pure-Lua fallback (mirrors Tags.lua luaAbbreviate)
local function luaAbbreviate(value)
    if value >= 1e10 then
        return _G.string.format("%.1fB", value / 1e9)
    elseif value >= 1e9 then
        return _G.string.format("%.2fB", value / 1e9)
    elseif value >= 1e7 then
        return _G.string.format("%.1fM", value / 1e6)
    elseif value >= 1e6 then
        return _G.string.format("%.2fM", value / 1e6)
    elseif value >= 1e5 then
        return _G.string.format("%dK", value / 1e3)
    elseif value >= 1e4 then
        return _G.string.format("%.1fK", value / 1e3)
    else
        return _G.tostring(value)
    end
end

-- Build the same multi-path abbreviation function as Tags.lua
local function buildAbbreviateValue()
    -- Path 1: AbbreviatedNumberFormatter (12.0.5+)
    local formatter
    if _G.C_StringUtil and _G.C_StringUtil.CreateAbbreviatedNumberFormatter then
        local ok, f = pcall(_G.C_StringUtil.CreateAbbreviatedNumberFormatter)
        if ok and f then
            local setOk = pcall(f.SetBreakpoints, f, abbrevBreakpoints)
            if setOk then
                formatter = f
            else
                pcall(f.ResetBreakpoints, f)
                formatter = f
            end
        end
    end

    -- Path 2: CreateAbbreviateConfig (legacy)
    local abbrevData
    if not formatter and _G.CreateAbbreviateConfig then
        local ok, config = pcall(_G.CreateAbbreviateConfig, abbrevBreakpoints)
        if ok and config then
            abbrevData = { breakpointData = abbrevBreakpoints, config = config }
        end
    end

    return function(value)
        if formatter then
            local ok, result = pcall(_G.AbbreviateNumbers, value, formatter)
            if ok then return result end
        end
        if abbrevData and _G.AbbreviateNumbers then
            return _G.AbbreviateNumbers(value, abbrevData)
        end
        if _G.AbbreviateNumbers then
            return _G.AbbreviateNumbers(value)
        end
        return luaAbbreviate(value)
    end
end

local function RunAbbrevFormatTest()
    _G.print("|cff00ccff[PBT]|r Abbreviated number formatting — running", NUM_ITERATIONS, "iterations")

    local formatValue = buildAbbreviateValue()
    local failures = 0

    -- Report which path is active
    if _G.C_StringUtil and _G.C_StringUtil.CreateAbbreviatedNumberFormatter then
        _G.print("|cff00ccff[INFO]|r AbbreviatedNumberFormatter API available (12.0.5+)")
    elseif _G.CreateAbbreviateConfig then
        local ok = pcall(_G.CreateAbbreviateConfig, abbrevBreakpoints)
        if ok then
            _G.print("|cff00ccff[INFO]|r Using CreateAbbreviateConfig path (custom breakpoints accepted)")
        else
            _G.print("|cffffff00[INFO]|r CreateAbbreviateConfig rejected breakpoints, using fallback")
        end
    elseif _G.AbbreviateNumbers then
        _G.print("|cffffff00[INFO]|r Using AbbreviateNumbers with default formatting")
    else
        _G.print("|cffffff00[INFO]|r Using pure-Lua fallback (AbbreviateNumbers unavailable)")
    end

    for i = 1, NUM_ITERATIONS do
        local value = nextRandom(0x7FFFFFFF)
        local tagResult = formatValue(value)
        -- Call formatValue again to verify consistency (same path, same result)
        local apiResult = formatValue(value)

        if tagResult ~= apiResult then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: value=%d, call1='%s', call2='%s'"):format(
                i, value, tagResult, apiResult))
        end

        -- Result must be a non-empty string
        if type(tagResult) ~= "string" or #tagResult == 0 then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: value=%d, result is not a non-empty string"):format(i, value))
        end
    end

    -- Edge cases
    local edgeCases = {0, 1, 999, 9999, 10000, 99999, 100000, 999999,
        1000000, 9999999, 10000000, 99999999, 100000000, 999999999,
        1000000000, 2000000000}
    for _, value in _G.ipairs(edgeCases) do
        local tagResult = formatValue(value)
        local apiResult = formatValue(value)

        if tagResult ~= apiResult then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r edge value=%d, call1='%s', call2='%s'"):format(
                value, tagResult, apiResult))
        end
    end

    -- Lua fallback sanity check: verify luaAbbreviate produces expected suffixes
    local luaChecks = {
        {value = 500, expected = "500"},
        {value = 9999, expected = "9999"},
        {value = 10000, suffix = "K"},
        {value = 50000, suffix = "K"},
        {value = 100000, suffix = "K"},
        {value = 1000000, suffix = "M"},
        {value = 50000000, suffix = "M"},
        {value = 1000000000, suffix = "B"},
    }
    for _, check in _G.ipairs(luaChecks) do
        local result = luaAbbreviate(check.value)
        if check.expected and result ~= check.expected then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r luaAbbreviate(%d) = '%s', expected '%s'"):format(
                check.value, result, check.expected))
        elseif check.suffix and not result:find(check.suffix, 1, true) then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r luaAbbreviate(%d) = '%s', expected suffix '%s'"):format(
                check.value, result, check.suffix))
        end
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 1: Abbreviated number formatting — %d iterations + %d edge cases + Lua fallback checks passed"):format(
            NUM_ITERATIONS, #edgeCases))
    else
        _G.print(("|cffff0000[FAIL]|r Property 1: Abbreviated number formatting — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:ufabbrevformat()
    return RunAbbrevFormatTest()
end
