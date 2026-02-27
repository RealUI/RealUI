local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Cast bar interruptible color
-- Feature: hud-rewrite, Property 8: Cast bar interruptible color
-- Validates: Requirements 12.7, 18.1, 18.3, 18.6
--
-- For any notInterruptible in {true, false, nil}, cast bar color is
-- uninterruptible (0.5, 0.0, 0.0) when true, interruptible (0.5, 1.0, 1.0)
-- when false or nil.

local RealUI = _G.RealUI

local TOLERANCE = 0.01

local function approxEqual(a, b)
    if _G.issecretvalue and _G.issecretvalue(a) then return false end
    if _G.issecretvalue and _G.issecretvalue(b) then return false end
    return _G.math.abs(a - b) < TOLERANCE
end

local function colorMatch(r, g, b, er, eg, eb)
    return approxEqual(r, er) and approxEqual(g, eg) and approxEqual(b, eb)
end

local function RunCastBarInterruptibleColorTest()
    local CastBars = RealUI:GetModule("CastBars")
    if not CastBars then
        _G.print("|cffff0000[ERROR]|r CastBars module not available.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Cast bar interruptible color — testing notInterruptible in {true, false, nil}")

    local testCases = {
        {value = true,  label = "true",  expectR = 0.5, expectG = 0.0, expectB = 0.0},
        {value = false, label = "false", expectR = 0.5, expectG = 1.0, expectB = 1.0},
        {value = nil,   label = "nil",   expectR = 0.5, expectG = 1.0, expectB = 1.0},
    }

    local units = {"player", "target", "focus"}
    local failures = 0
    local checkedCount = 0

    for _, unit in _G.ipairs(units) do
        local castbar = CastBars[unit]
        if not castbar then
            _G.print(("  %s castbar = nil, skipping"):format(unit))
        else
            -- Verify castbar has the required methods
            if not castbar.SetStatusBarColor or not castbar.GetStatusBarColor then
                _G.print(("|cffff0000[ERROR]|r %s castbar missing StatusBar color methods"):format(unit))
                return false
            end
            if not castbar.PostCastStart then
                _G.print(("|cffff0000[ERROR]|r %s castbar missing PostCastStart callback"):format(unit))
                return false
            end

            for _, tc in _G.ipairs(testCases) do
                -- Set the notInterruptible flag
                castbar.notInterruptible = tc.value

                -- Ensure flashAnim won't interfere
                if castbar.flashAnim and castbar.flashAnim.IsPlaying then
                    local wasPlaying = castbar.flashAnim:IsPlaying()
                    if wasPlaying then
                        castbar.flashAnim:Stop()
                    end
                end

                -- Call PostCastStart (the callback stored on the castbar)
                castbar.PostCastStart(castbar, unit)

                -- Read back the color
                local r, g, b = castbar:GetStatusBarColor()

                if not colorMatch(r, g, b, tc.expectR, tc.expectG, tc.expectB) then
                    failures = failures + 1
                    _G.print(
                        ("|cffff0000[FAIL]|r unit=%s notInterruptible=%s expected=(%.1f,%.1f,%.1f) got=(%.2f,%.2f,%.2f)"):format(
                            unit, tc.label,
                            tc.expectR, tc.expectG, tc.expectB,
                            r or 0, g or 0, b or 0
                        )
                    )
                end
                checkedCount = checkedCount + 1
            end
        end
    end

    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No cast bars found — test inconclusive")
        return false
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 8: Cast bar interruptible color — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Property 8: Cast bar interruptible color — %d failures out of %d checks"):format(failures, checkedCount))
    end

    return failures == 0
end

function ns.commands:castbarcolor()
    return RunCastBarInterruptibleColorTest()
end
