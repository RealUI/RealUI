local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Positioner resize for valid anchor widths
-- Feature: hud-rewrite, Property 7: Positioner resize for valid anchor widths
-- Validates: Requirements 10.3
--
-- For any anchor width w in [0, floor(uiWidth * 0.5)], setting UFHorizontal
-- to w and calling UpdatePositioners results in positioner frame width equal
-- to 80 + w (plus any HuDSizeOffset for the current hudSize setting).

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100
local BASE_WIDTH = 80

-- Simple RNG (xorshift32)
local rngState = 773
local function nextRandom(maxVal)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return rngState % (maxVal + 1)
end

local function RunPositionerResizeTest()
    local ndb = RealUI.db.profile
    local ndbc = RealUI.db.char
    if not ndb or not ndbc then
        _G.print("|cffff0000[ERROR]|r RealUI db not available.")
        return false
    end

    local layout = ndbc.layout.current
    if not layout then
        _G.print("|cffff0000[ERROR]|r Could not determine current layout.")
        return false
    end

    local posFrame = _G["RealUIPositionersUnitFrames"]
    if not posFrame then
        _G.print("|cffff0000[ERROR]|r RealUIPositionersUnitFrames frame not found.")
        return false
    end

    -- Read the HuDSizeOffset for UFHorizontal
    local hudSize = ndb.settings.hudSize
    local hudOffset = 0
    if RealUI.hudSizeOffsets and RealUI.hudSizeOffsets[hudSize] then
        hudOffset = RealUI.hudSizeOffsets[hudSize]["UFHorizontal"] or 0
    end

    local uiWidth = _G.math.floor(_G.UIParent:GetWidth())
    local maxAnchor = _G.math.floor(uiWidth * 0.5)

    _G.print("|cff00ccff[PBT]|r Positioner resize — running", NUM_ITERATIONS,
        "iterations (uiWidth=" .. uiWidth .. ", maxAnchor=" .. maxAnchor ..
        ", hudOffset=" .. hudOffset .. ")")

    -- Save original value
    local origValue = ndb.positions[layout]["UFHorizontal"]

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local w = nextRandom(maxAnchor)

        ndb.positions[layout]["UFHorizontal"] = w
        RealUI:UpdatePositioners()

        local expectedWidth = _G.math.floor(BASE_WIDTH + w + hudOffset)
        local actualWidth = posFrame:GetWidth()

        if _G.math.abs(actualWidth - expectedWidth) > 0.01 then
            failures = failures + 1
            if failures <= 5 then
                _G.print(("|cffff0000[FAIL]|r iteration %d: w=%d — expected width=%d, got=%.2f"):format(
                    i, w, expectedWidth, actualWidth))
            end
        end
    end

    -- Restore original value and update
    ndb.positions[layout]["UFHorizontal"] = origValue
    RealUI:UpdatePositioners()

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 7: Positioner resize — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 7: Positioner resize — %d failures out of %d"):format(failures, NUM_ITERATIONS))
    end

    return failures == 0
end

function ns.commands:posresize()
    return RunPositionerResizeTest()
end
