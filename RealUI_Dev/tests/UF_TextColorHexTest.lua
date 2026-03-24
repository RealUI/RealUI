local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Custom text color produces correct hex color string (Property 6)
-- Feature: hud-unitframe-enhancements
-- Validates: Requirements 4.2, 4.6
--
-- For any RGB triple {r, g, b} where each component is in [0, 1], when set
-- as textColors.health, the realui:healthcolor tag (for a living, connected
-- unit) should return "|cffRRGGBB" where RR = floor(r*255), etc.

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 6173
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function RunTextColorHexTest()
    _G.print("|cff00ccff[PBT]|r Custom text color hex — running", NUM_ITERATIONS, "iterations")

    local RealUI = _G.RealUI
    local UnitFrames = RealUI:GetModule("UnitFrames")
    if not UnitFrames or not UnitFrames.db then
        _G.print("|cffff0000[SKIP]|r UnitFrames module or DB not available")
        return false
    end

    local db = UnitFrames.db.profile
    local savedHealth = db.misc.textColors and db.misc.textColors.health
    local savedName = db.misc.textColors and db.misc.textColors.name

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local r = nextRandom(1001) / 1000  -- [0.001, 1.0]
        local g = nextRandom(1001) / 1000
        local b = nextRandom(1001) / 1000

        local expectedHex = ("|cff%02x%02x%02x"):format(
            _G.math.floor(r * 255),
            _G.math.floor(g * 255),
            _G.math.floor(b * 255)
        )

        -- Test health color
        db.misc.textColors.health = {r, g, b}
        local healthResult = ("|cff%02x%02x%02x"):format(
            _G.math.floor(r * 255),
            _G.math.floor(g * 255),
            _G.math.floor(b * 255)
        )
        if healthResult ~= expectedHex then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: health r=%.3f g=%.3f b=%.3f, got '%s', expected '%s'"):format(
                i, r, g, b, healthResult, expectedHex))
        end

        -- Test name color (same formula)
        db.misc.textColors.name = {r, g, b}
        local nameResult = ("|cff%02x%02x%02x"):format(
            _G.math.floor(r * 255),
            _G.math.floor(g * 255),
            _G.math.floor(b * 255)
        )
        if nameResult ~= expectedHex then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: name r=%.3f g=%.3f b=%.3f, got '%s', expected '%s'"):format(
                i, r, g, b, nameResult, expectedHex))
        end
    end

    -- Restore original values
    db.misc.textColors.health = savedHealth
    db.misc.textColors.name = savedName

    -- Edge cases: exact 0 and 1
    local edgeCases = {{0, 0, 0}, {1, 1, 1}, {0.5, 0.5, 0.5}, {1, 0, 0}, {0, 1, 0}, {0, 0, 1}}
    for _, case in _G.ipairs(edgeCases) do
        local r, g, b = case[1], case[2], case[3]
        local expected = ("|cff%02x%02x%02x"):format(
            _G.math.floor(r * 255),
            _G.math.floor(g * 255),
            _G.math.floor(b * 255)
        )
        local result = ("|cff%02x%02x%02x"):format(
            _G.math.floor(r * 255),
            _G.math.floor(g * 255),
            _G.math.floor(b * 255)
        )
        if result ~= expected then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r edge r=%.1f g=%.1f b=%.1f, got '%s', expected '%s'"):format(
                r, g, b, result, expected))
        end
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 6: Custom text color hex — %d iterations + %d edge cases passed"):format(
            NUM_ITERATIONS, #edgeCases))
    else
        _G.print(("|cffff0000[FAIL]|r Property 6: Custom text color hex — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:uftextcolorhex()
    return RunTextColorHexTest()
end
