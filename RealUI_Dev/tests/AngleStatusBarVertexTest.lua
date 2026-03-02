local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: AngleStatusBar vertex configuration
-- Feature: hud-rewrite, Property 1: AngleStatusBar vertex configuration
-- Validates: Requirements 2.2
--
-- For any pair of vertex positions (leftVertex, rightVertex) from {1,2,3,4},
-- SetAngleVertex then reading metadata returns same values; isTrapezoid is
-- "TOP" when both odd, "BOTTOM" when both even, nil otherwise.

local RealUI = _G.RealUI

local NUM_ITERATIONS = 100
local vertexPositions = {1, 2, 3, 4}

-- Simple RNG (xorshift32)
local rngState = 73
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local function expectedTrapezoid(leftVertex, rightVertex)
    local leftOdd = (leftVertex % 2 == 1)
    local rightOdd = (rightVertex % 2 == 1)
    if leftOdd and rightOdd then
        return "TOP"
    elseif not leftOdd and not rightOdd then
        return "BOTTOM"
    else
        return nil
    end
end

local function RunAngleStatusBarVertexTest()
    local AngleStatusBar = RealUI:GetModule("AngleStatusBar")
    if not AngleStatusBar then
        _G.print("|cffff0000[ERROR]|r AngleStatusBar module not available.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r AngleStatusBar vertex configuration — running", NUM_ITERATIONS, "iterations")

    local parentFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    parentFrame:SetSize(260, 28)

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local leftVertex = vertexPositions[nextRandom(#vertexPositions)]
        local rightVertex = vertexPositions[nextRandom(#vertexPositions)]

        local bar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
        bar:SetAngleVertex(leftVertex, rightVertex)

        -- Read back metadata directly via test accessor
        local meta = AngleStatusBar:GetBarMeta(bar)

        -- Verify leftVertex round-trip
        if meta.leftVertex ~= leftVertex then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: leftVertex expected=%d got=%s"):format(
                    i, leftVertex, tostring(meta.leftVertex)
                )
            )
        end

        -- Verify rightVertex round-trip
        if meta.rightVertex ~= rightVertex then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: rightVertex expected=%d got=%s"):format(
                    i, rightVertex, tostring(meta.rightVertex)
                )
            )
        end

        -- Verify isTrapezoid
        local expected = expectedTrapezoid(leftVertex, rightVertex)
        if meta.isTrapezoid ~= expected then
            failures = failures + 1
            _G.print(
                ("|cffff0000[FAIL]|r iteration %d: left=%d right=%d isTrapezoid expected=%s got=%s"):format(
                    i, leftVertex, rightVertex, tostring(expected), tostring(meta.isTrapezoid)
                )
            )
        end

        bar:Hide()
    end

    -- Exhaustive 16-combination check
    _G.print("|cff00ccff[PBT]|r Running exhaustive 16-combination check...")
    for _, lv in _G.ipairs(vertexPositions) do
        for _, rv in _G.ipairs(vertexPositions) do
            local bar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
            bar:SetAngleVertex(lv, rv)

            local meta = AngleStatusBar:GetBarMeta(bar)
            local expected = expectedTrapezoid(lv, rv)

            if meta.leftVertex ~= lv or meta.rightVertex ~= rv then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r exhaustive left=%d right=%d — vertex mismatch (got %s, %s)"):format(
                        lv, rv, tostring(meta.leftVertex), tostring(meta.rightVertex)
                    )
                )
            end

            if meta.isTrapezoid ~= expected then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r exhaustive left=%d right=%d — isTrapezoid expected=%s got=%s"):format(
                        lv, rv, tostring(expected), tostring(meta.isTrapezoid)
                    )
                )
            end

            bar:Hide()
        end
    end

    parentFrame:Hide()

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 1: AngleStatusBar vertex configuration — %d iterations + 16 exhaustive combos passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Property 1: AngleStatusBar vertex configuration — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:anglevertex()
    return RunAngleStatusBarVertexTest()
end
