local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Bar fill visible at max value
-- Feature: hud-rewrite, Property 6: Bar fill visible at max value
-- Validates: Requirements 5.1, 5.2, 5.3, 6.5
--
-- For any AngleStatusBar with SetMinMaxValues(0, max) where max > 0,
-- SetValue(max) results in fill texture visible with width equal to maxWidth.
--
-- NOTE: OnSizeChanged fires asynchronously in WoW's layout engine, so we
-- manually set maxWidth/minWidth on the bar metadata after creation to
-- simulate the layout pass. This tests the fill logic itself, not the
-- frame sizing pipeline (which is a WoW engine concern).

local RealUI = _G.RealUI

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

local function RunAngleStatusBarFillMaxTest()
    local AngleStatusBar = RealUI:GetModule("AngleStatusBar")
    if not AngleStatusBar then
        _G.print("|cffff0000[ERROR]|r AngleStatusBar module not available.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Bar fill visible at max value — running", NUM_ITERATIONS, "iterations")

    local parentFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    parentFrame:SetSize(260, 28)

    local failures = 0
    local barWidth = 200
    local barHeight = 14
    -- The angle mixin SetSize calls Frame_SetSize(self, height+width, height)
    -- OnSizeChanged would set maxWidth = height+width, minWidth = height
    local expectedMaxWidth = barHeight + barWidth

    for i = 1, NUM_ITERATIONS do
        local maxVal = nextRandom(10000)

        local bar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
        bar:SetSize(barWidth, barHeight)
        bar:SetSmooth(false)

        -- OnSizeChanged fires asynchronously, so manually set the metadata
        -- to simulate what the layout engine would do
        local meta = AngleStatusBar:GetBarMeta(bar)
        meta.maxWidth = expectedMaxWidth
        meta.minWidth = barHeight

        bar:SetMinMaxValues(0, maxVal)
        bar:SetValue(maxVal)

        -- Verify fill texture is visible
        local isShown = bar.fill:IsShown()
        if not isShown then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: max=%d — fill not shown"):format(i, maxVal)
            )
        end

        -- Verify fill width equals maxWidth
        local fillWidth = bar.fill:GetWidth()
        if _G.math.abs(fillWidth - expectedMaxWidth) > 0.01 then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: max=%d — fill width=%.2f, expected=%d"):format(
                    i, maxVal, fillWidth, expectedMaxWidth
                )
            )
        end

        bar:Hide()
    end

    parentFrame:Hide()

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 6: Bar fill visible at max value — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 6: Bar fill visible at max value — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:anglefillmax()
    return RunAngleStatusBarFillMaxTest()
end
