local ADDON_NAME, ns = ... -- luacheck: ignore
local RealUI = _G.RealUI

-- Feature: realui-config-overhaul, Property 1: AuroraConfig round-trip consistency
-- Validates: Requirements 1.2, 21.2, 22.1, 22.2, 22.3
--
-- For any Skin Features/Style toggle, setting a value via `set` and reading
-- via `get` returns the same value, and `_G.AuroraConfig[key]` matches.

local ITERATIONS = 100

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------
local function deepCopy(t)
    if type(t) ~= "table" then return t end
    local copy = {}
    for k, v in pairs(t) do
        copy[k] = deepCopy(v)
    end
    return copy
end

local function restoreTable(dst, src)
    -- wipe dst then repopulate from src
    for k in pairs(dst) do dst[k] = nil end
    if src then
        for k, v in pairs(src) do
            if type(v) == "table" then
                dst[k] = deepCopy(v)
            else
                dst[k] = v
            end
        end
    end
end

-- Minimal PRNG (linear congruential) so we don't depend on math.random seed state
local rngState = (_G.GetTime and math.floor(_G.GetTime() * 1000) or 12345) + 67890
local function nextRandom()
    -- LCG parameters from Numerical Recipes
    rngState = (rngState * 1103515245 + 12345) % 0x7FFFFFFF
    return rngState
end

local function randomBool()
    return nextRandom() % 2 == 1
end

local function randomFloat01()
    return (nextRandom() % 10001) / 10000  -- 0.0000 .. 1.0000
end


---------------------------------------------------------------------------
-- Skin Features: boolean toggles that read/write _G.AuroraConfig[key]
---------------------------------------------------------------------------
local FEATURE_KEYS = {
    "bags", "banks", "chat", "loot", "mainmenubar",
    "fonts", "tooltips", "chatBubbles", "chatBubbleNames",
    "characterSheet", "objectiveTracker",
}

---------------------------------------------------------------------------
-- Build simulated get/set callbacks matching Advanced.lua patterns
---------------------------------------------------------------------------

local function getRuntimeAuroraConfig()
    _G.AuroraConfig = _G.AuroraConfig or {}
    return _G.AuroraConfig
end

local function getAuroraValue(key, fallbackValue)
    if RealUI and RealUI.GetAuroraConfigValue then
        return RealUI.GetAuroraConfigValue(key, fallbackValue)
    end

    local auroraConfig = getRuntimeAuroraConfig()
    if auroraConfig[key] == nil then
        auroraConfig[key] = fallbackValue
    end
    return auroraConfig[key]
end

local function setAuroraValue(key, value)
    if RealUI and RealUI.SetAuroraConfigValue then
        RealUI.SetAuroraConfigValue(key, value)
        return
    end

    getRuntimeAuroraConfig()[key] = value
end

local function getAuroraTable(key)
    if RealUI and RealUI.GetAuroraConfigTable then
        local profileTable, runtimeTable = RealUI.GetAuroraConfigTable(key)
        return profileTable or runtimeTable
    end

    local auroraConfig = getRuntimeAuroraConfig()
    auroraConfig[key] = auroraConfig[key] or {}
    return auroraConfig[key]
end

local function setAuroraTable(key, value)
    if RealUI and RealUI.SetAuroraConfigTable then
        RealUI.SetAuroraConfigTable(key, value)
        return
    end

    getRuntimeAuroraConfig()[key] = deepCopy(value)
end

-- Skin Features get/set (mirrors Advanced.lua skinFeatures group)
local function featureGet(key)
    return getAuroraValue(key, true)
end

local function featureSet(key, value)
    setAuroraValue(key, value)
end

-- Skin Style: buttonsHaveGradient
local function gradientGet()
    return getAuroraValue("buttonsHaveGradient", true)
end

local function gradientSet(value)
    setAuroraValue("buttonsHaveGradient", value)
end

-- Skin Style: talentArtBackground
local function talentArtBackgroundGet()
    return getAuroraValue("talentArtBackground", true)
end

local function talentArtBackgroundSet(value)
    setAuroraValue("talentArtBackground", value)
end

-- Skin Style: customHighlight.enabled
local function highlightEnabledGet()
    return getAuroraTable("customHighlight").enabled
end

local function highlightEnabledSet(value)
    local customHighlight = getAuroraTable("customHighlight")
    customHighlight.enabled = value
    setAuroraTable("customHighlight", customHighlight)
end

-- Skin Style: customHighlight color (r, g, b)
local function highlightColorGet()
    local ch = getAuroraTable("customHighlight")
    return ch.r or 0, ch.g or 0, ch.b or 0
end

local function highlightColorSet(r, g, b)
    local customHighlight = getAuroraTable("customHighlight")
    customHighlight.r = r
    customHighlight.g = g
    customHighlight.b = b
    setAuroraTable("customHighlight", customHighlight)
end

-- Skin Style: alpha (range 0-1)
local function alphaGet()
    return getAuroraValue("alpha", 1)
end

local function alphaSet(value)
    setAuroraValue("alpha", value)
end


---------------------------------------------------------------------------
-- Property test runner
---------------------------------------------------------------------------
local function RunRoundTripTest()
    local passed, failed = 0, 0
    local firstFailure = nil

    -- Snapshot original state
    local originalConfig = deepCopy(getRuntimeAuroraConfig())

    for i = 1, ITERATIONS do
        -- Seed varies per iteration
        rngState = rngState + i

        ---------------------------------------------------------------
        -- 1) Skin Features: boolean round-trip
        ---------------------------------------------------------------
        for _, key in ipairs(FEATURE_KEYS) do
            local testVal = randomBool()
            featureSet(key, testVal)

            -- Read back via get callback
            local readBack = featureGet(key)
            -- Also verify raw saved variable
            local rawVal = _G.AuroraConfig[key]

            if readBack ~= testVal then
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Iter %d: Feature '%s' get returned %s, expected %s"):format(
                        i, key, tostring(readBack), tostring(testVal))
                end
            elseif rawVal ~= testVal then
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Iter %d: Feature '%s' AuroraConfig[%s] = %s, expected %s"):format(
                        i, key, key, tostring(rawVal), tostring(testVal))
                end
            else
                passed = passed + 1
            end
        end

        ---------------------------------------------------------------
        -- 1b) Skin Style: talentArtBackground (boolean)
        ---------------------------------------------------------------
        do
            local testVal = randomBool()
            talentArtBackgroundSet(testVal)
            local readBack = talentArtBackgroundGet()
            local rawVal = _G.AuroraConfig.talentArtBackground

            if readBack ~= testVal or rawVal ~= testVal then
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Iter %d: talentArtBackground get=%s raw=%s expected=%s"):format(
                        i, tostring(readBack), tostring(rawVal), tostring(testVal))
                end
            else
                passed = passed + 1
            end
        end

        ---------------------------------------------------------------
        -- 2) Skin Style: buttonsHaveGradient (boolean)
        ---------------------------------------------------------------
        do
            local testVal = randomBool()
            gradientSet(testVal)
            local readBack = gradientGet()
            local rawVal = _G.AuroraConfig.buttonsHaveGradient

            if readBack ~= testVal or rawVal ~= testVal then
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Iter %d: buttonsHaveGradient get=%s raw=%s expected=%s"):format(
                        i, tostring(readBack), tostring(rawVal), tostring(testVal))
                end
            else
                passed = passed + 1
            end
        end

        ---------------------------------------------------------------
        -- 3) Skin Style: customHighlight.enabled (boolean)
        ---------------------------------------------------------------
        do
            local testVal = randomBool()
            highlightEnabledSet(testVal)
            local readBack = highlightEnabledGet()
            local rawVal = _G.AuroraConfig.customHighlight and _G.AuroraConfig.customHighlight.enabled

            if readBack ~= testVal or rawVal ~= testVal then
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Iter %d: customHighlight.enabled get=%s raw=%s expected=%s"):format(
                        i, tostring(readBack), tostring(rawVal), tostring(testVal))
                end
            else
                passed = passed + 1
            end
        end

        ---------------------------------------------------------------
        -- 4) Skin Style: customHighlight color (r, g, b)
        ---------------------------------------------------------------
        do
            local tr = randomFloat01()
            local tg = randomFloat01()
            local tb = randomFloat01()
            highlightColorSet(tr, tg, tb)

            local rr, rg, rb = highlightColorGet()
            local ch = _G.AuroraConfig.customHighlight or {}

            if rr ~= tr or rg ~= tg or rb ~= tb then
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Iter %d: highlightColor get=(%s,%s,%s) expected=(%s,%s,%s)"):format(
                        i, tostring(rr), tostring(rg), tostring(rb),
                        tostring(tr), tostring(tg), tostring(tb))
                end
            elseif ch.r ~= tr or ch.g ~= tg or ch.b ~= tb then
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Iter %d: highlightColor raw=(%s,%s,%s) expected=(%s,%s,%s)"):format(
                        i, tostring(ch.r), tostring(ch.g), tostring(ch.b),
                        tostring(tr), tostring(tg), tostring(tb))
                end
            else
                passed = passed + 1
            end
        end

        ---------------------------------------------------------------
        -- 5) Skin Style: alpha (number 0-1)
        ---------------------------------------------------------------
        do
            local testVal = randomFloat01()
            alphaSet(testVal)
            local readBack = alphaGet()
            local rawVal = _G.AuroraConfig.alpha

            if readBack ~= testVal or rawVal ~= testVal then
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Iter %d: alpha get=%s raw=%s expected=%s"):format(
                        i, tostring(readBack), tostring(rawVal), tostring(testVal))
                end
            else
                passed = passed + 1
            end
        end
    end

    -- Restore original AuroraConfig state
    restoreTable(getRuntimeAuroraConfig(), originalConfig)

    return passed, failed, firstFailure
end


---------------------------------------------------------------------------
-- Slash command entry point: /realdev auroraconfigrt
---------------------------------------------------------------------------
function ns.commands:auroraconfigrt()
    _G.print("|cff00ccff[AuroraConfig Round-Trip]|r Running property test (" .. ITERATIONS .. " iterations)...")

    local ok, passed, failed, firstFailure = pcall(RunRoundTripTest)
    if not ok then
        _G.print("|cffff0000[ERROR]|r Test threw an error: " .. tostring(passed))
        return false
    end

    local total = passed + failed
    _G.print(("  Checks: %d total, %d passed, %d failed"):format(total, passed, failed))

    if failed > 0 then
        _G.print("|cffff0000[FAIL]|r First failure: " .. (firstFailure or "unknown"))
        return false
    else
        _G.print("|cff00ff00[PASS]|r AuroraConfig round-trip consistency verified")
        return true
    end
end
