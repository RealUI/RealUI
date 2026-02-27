local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: AngleStatusBar StatusBar interface round-trip
-- Feature: hud-rewrite, Property 2: AngleStatusBar StatusBar interface round-trip
-- Validates: Requirements 2.3
--
-- For any AngleStatusBar instance:
-- - SetMinMaxValues(min, max) then GetMinMaxValues() returns (min, max)
-- - SetValue(v) (where min <= v <= max) then GetValue() returns v
-- - SetStatusBarColor(r, g, b, a) then GetStatusBarColor() returns (r, g, b, a)

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100

-- Simple RNG for property-based iteration (xorshift32)
local rngState = 137
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

-- Generate a random float in [0, 1] with 2 decimal precision
local function randomFloat01()
    return nextRandom(101) / 100  -- 0.01 to 1.01, clamped below
end

-- Generate a random float clamped to [0, 1]
local function randomColor()
    local v = (nextRandom(100) - 1) / 99  -- 0.0 to 1.0
    return v
end

local function RunAngleStatusBarRoundTripTest()
    local AngleStatusBar = RealUI:GetModule("AngleStatusBar")
    if not AngleStatusBar then
        _G.print("|cffff0000[ERROR]|r AngleStatusBar module not available.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r AngleStatusBar StatusBar interface round-trip — running", NUM_ITERATIONS, "iterations")

    local parentFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    parentFrame:SetSize(260, 28)

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local bar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
        bar:SetSize(200, 14)
        bar:SetSmooth(false)

        -- Generate random min/max values (min < max, both non-negative integers)
        local minVal = nextRandom(100) - 1  -- 0 to 99
        local maxVal = minVal + nextRandom(1000)  -- minVal+1 to minVal+1000

        -- 1. Test SetMinMaxValues / GetMinMaxValues round-trip
        bar:SetMinMaxValues(minVal, maxVal)
        local gotMin, gotMax = bar:GetMinMaxValues()
        if gotMin ~= minVal or gotMax ~= maxVal then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: SetMinMaxValues(%d, %d) -> GetMinMaxValues() = (%s, %s)"):format(
                    i, minVal, maxVal, tostring(gotMin), tostring(gotMax)
                )
            )
        end

        -- 2. Test SetValue / GetValue round-trip (value in [min, max])
        local value = minVal + nextRandom(maxVal - minVal + 1) - 1  -- minVal to maxVal
        bar:SetValue(value)
        local gotValue = bar:GetValue()
        if gotValue ~= value then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: SetValue(%d) -> GetValue() = %s (min=%d, max=%d)"):format(
                    i, value, tostring(gotValue), minVal, maxVal
                )
            )
        end

        -- 3. Test SetStatusBarColor / GetStatusBarColor round-trip
        local r = randomColor()
        local g = randomColor()
        local b = randomColor()
        local a = randomColor()
        bar:SetStatusBarColor(r, g, b, a)
        local gotR, gotG, gotB, gotA = bar:GetStatusBarColor()
        if gotR ~= r or gotG ~= g or gotB ~= b or gotA ~= a then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: SetStatusBarColor(%.2f, %.2f, %.2f, %.2f) -> GetStatusBarColor() = (%.2f, %.2f, %.2f, %.2f)"):format(
                    i, r, g, b, a,
                    gotR or -1, gotG or -1, gotB or -1, gotA or -1
                )
            )
        end

        bar:Hide()
    end

    -- Also test edge cases: min=0, max=0 and value at boundaries
    _G.print("|cff00ccff[PBT]|r Running edge case checks...")

    -- Edge: min=max (zero range)
    do
        local bar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
        bar:SetSize(200, 14)
        bar:SetSmooth(false)
        bar:SetMinMaxValues(50, 50)
        local gotMin, gotMax = bar:GetMinMaxValues()
        if gotMin ~= 50 or gotMax ~= 50 then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r edge: SetMinMaxValues(50, 50) round-trip failed")
        end
        bar:Hide()
    end

    -- Edge: value exactly at min
    do
        local bar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
        bar:SetSize(200, 14)
        bar:SetSmooth(false)
        bar:SetMinMaxValues(10, 100)
        bar:SetValue(10)
        local gotValue = bar:GetValue()
        if gotValue ~= 10 then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r edge: SetValue(10) at min -> GetValue() = %s"):format(tostring(gotValue))
            )
        end
        bar:Hide()
    end

    -- Edge: value exactly at max
    do
        local bar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
        bar:SetSize(200, 14)
        bar:SetSmooth(false)
        bar:SetMinMaxValues(0, 100)
        bar:SetValue(100)
        local gotValue = bar:GetValue()
        if gotValue ~= 100 then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r edge: SetValue(100) at max -> GetValue() = %s"):format(tostring(gotValue))
            )
        end
        bar:Hide()
    end

    -- Edge: color with alpha=0 and alpha=1
    do
        local bar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
        bar:SetSize(200, 14)
        bar:SetSmooth(false)
        bar:SetStatusBarColor(1, 0, 0, 0)
        local gotR, gotG, gotB, gotA = bar:GetStatusBarColor()
        if gotR ~= 1 or gotG ~= 0 or gotB ~= 0 or gotA ~= 0 then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r edge: SetStatusBarColor(1,0,0,0) round-trip failed")
        end
        bar:SetStatusBarColor(0, 1, 0.5, 1)
        gotR, gotG, gotB, gotA = bar:GetStatusBarColor()
        if gotR ~= 0 or gotG ~= 1 or gotB ~= 0.5 or gotA ~= 1 then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r edge: SetStatusBarColor(0,1,0.5,1) round-trip failed")
        end
        bar:Hide()
    end

    parentFrame:Hide()

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 2: AngleStatusBar StatusBar interface round-trip — %d iterations + edge cases passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 2: AngleStatusBar StatusBar interface round-trip — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register slash command
function ns.commands:angleroundtrip()
    return RunAngleStatusBarRoundTripTest()
end
