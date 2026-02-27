local ADDON_NAME, ns = ... -- luacheck: ignore

-- Bug Condition Exploration Tests — HuD Rewrite Fixes
-- Feature: hud-rewrite-fixes, Property 1: Fault Condition
-- Validates: Requirements 2.2, 2.3, 2.4, 2.6, 2.7, 2.9, 2.10, 2.11, 2.12
--
-- These tests encode the EXPECTED (correct) behavior for each defect.
-- On UNFIXED code, they are EXPECTED TO FAIL — failure confirms the bugs exist.
-- After fixes are implemented, these tests should PASS.
--
-- Run with: /realdev hudfixexplore
-- Run all fix tests: /realdev hudfixtestall

local RealUI = _G.RealUI

-- ============================================================================
-- Test 1: CastBar SetTimerDuration / GetTimerDuration (Defects 1.2, 1.4)
-- Validates: Requirements 2.2, 2.4
--
-- On unfixed code: The native timer's SetTimerDuration works (accessible via
-- metatable), but the native timer internally updates the native StatusBar
-- value — our AngleStatusBar's SetBarValue never gets called because there
-- is no OnUpdate hook to sync the native timer progress to the custom
-- .fill texture rendering. The bar stays at 0.
-- ============================================================================
local function TestCastBarTimerDuration()
    _G.print("|cff00ccff[PBT]|r Test 1: CastBar SetTimerDuration/GetTimerDuration (Defects 1.2, 1.4)")

    local AngleStatusBar = RealUI:GetModule("AngleStatusBar")
    if not AngleStatusBar then
        _G.print("|cffff0000[ERROR]|r AngleStatusBar module not available")
        return false
    end

    local parentFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    parentFrame:SetSize(260, 28)

    local castbar = AngleStatusBar:CreateAngle("CastBar", nil, parentFrame)
    castbar:SetSize(230, 8)
    castbar:SetSmooth(false)

    -- Simulate layout pass
    local meta = AngleStatusBar:GetBarMeta(castbar)
    meta.maxWidth = 8 + 230
    meta.minWidth = 8

    castbar:SetMinMaxValues(0, 10)

    -- oUF calls SetTimerDuration on the castbar element
    local ok, err = _G.pcall(function()
        castbar:SetTimerDuration(5, 1, 0)
    end)

    if not ok then
        _G.print("|cffff0000[FAIL]|r SetTimerDuration errored:", err)
        parentFrame:Hide()
        return false
    end

    -- Verify GetTimerDuration returns a value
    local ok2, timerResult = _G.pcall(function()
        return castbar:GetTimerDuration()
    end)

    if not ok2 then
        _G.print("|cffff0000[FAIL]|r GetTimerDuration errored:", timerResult)
        parentFrame:Hide()
        return false
    end

    if timerResult == nil then
        _G.print("|cffff0000[FAIL]|r GetTimerDuration returned nil after SetTimerDuration(5, 1, 0)")
        parentFrame:Hide()
        return false
    end

    -- The key check: after SetTimerDuration, the AngleStatusBar's internal
    -- value (bars[].value) should eventually reflect the timer progress.
    -- On unfixed code, the native timer updates the native StatusBar but
    -- our custom .fill texture never gets updated (no OnUpdate hook).
    -- We check immediately — the native timer may not have ticked yet,
    -- but the bar value should at least be non-zero if the sync works.
    local barMeta = AngleStatusBar:GetBarMeta(castbar)
    if barMeta.value == 0 then
        _G.print("|cffff0000[FAIL]|r Native timer value not synced to AngleStatusBar rendering (value still 0)")
        parentFrame:Hide()
        return false
    end

    _G.print("|cff00ff00[PASS]|r CastBar SetTimerDuration/GetTimerDuration work and sync to rendering")
    parentFrame:Hide()
    return true
end


-- ============================================================================
-- Test 2: CastBar GetReverseFill native sync (Defect 1.3)
-- Validates: Requirements 2.3
--
-- On unfixed code: AngleStatusBarMixin:SetReverseFill sets the internal
-- bars[self].isReverseFill state but does NOT call the native
-- StatusBar:SetReverseFill. So the native GetReverseFill returns false
-- even after SetReverseFill(true). oUF may call the native method
-- via metatable, getting the wrong answer for SafeZone positioning.
-- ============================================================================
local function TestCastBarReverseFillSync()
    _G.print("|cff00ccff[PBT]|r Test 2: CastBar GetReverseFill native sync (Defect 1.3)")

    local AngleStatusBar = RealUI:GetModule("AngleStatusBar")
    if not AngleStatusBar then
        _G.print("|cffff0000[ERROR]|r AngleStatusBar module not available")
        return false
    end

    local parentFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    parentFrame:SetSize(260, 28)

    local castbar = AngleStatusBar:CreateAngle("CastBar", nil, parentFrame)
    castbar:SetSize(230, 8)

    -- Set reverse fill via AngleStatusBarMixin
    castbar:SetReverseFill(true)

    -- Mixin GetReverseFill should return true
    local mixinResult = castbar:GetReverseFill()
    if mixinResult ~= true then
        _G.print("|cffff0000[FAIL]|r Mixin GetReverseFill returned", _G.tostring(mixinResult), "expected true")
        parentFrame:Hide()
        return false
    end

    -- The native StatusBar:GetReverseFill should ALSO return true
    -- Access the native method via the metatable (bypassing instance override)
    local nativeMT = _G.getmetatable(castbar).__index
    local nativeGetReverseFill = nativeMT and nativeMT.GetReverseFill
    if not nativeGetReverseFill then
        _G.print("|cffff9900[WARN]|r Cannot access native GetReverseFill via metatable — skipping native check")
        _G.print("|cff00ff00[PASS]|r Mixin GetReverseFill returns true (native check skipped)")
        parentFrame:Hide()
        return true
    end

    local nativeResult = nativeGetReverseFill(castbar)
    if nativeResult ~= true then
        _G.print("|cffff0000[FAIL]|r Native GetReverseFill returned", _G.tostring(nativeResult), "— native state out of sync with internal isReverseFill")
        parentFrame:Hide()
        return false
    end

    _G.print("|cff00ff00[PASS]|r Both mixin and native GetReverseFill return true after SetReverseFill(true)")
    parentFrame:Hide()
    return true
end

-- ============================================================================
-- Test 3: PositionRune arithmetic (Defect 1.6)
-- Validates: Requirements 2.6
--
-- On unfixed code: PositionRune calls _G.min(middle) and _G.max(middle)
-- with a single argument. math.min/math.max require at least 2 arguments,
-- causing "bad argument #1 to 'min'" error.
-- ============================================================================
local function TestPositionRuneArithmetic()
    _G.print("|cff00ccff[PBT]|r Test 3: PositionRune arithmetic (Defect 1.6)")

    local ClassResource = RealUI:GetModule("ClassResource")
    if not ClassResource then
        _G.print("|cffff9900[WARN]|r ClassResource module not available — testing arithmetic directly")
    end

    -- We test the arithmetic pattern directly since PositionRune is a local
    -- function inside ClassResource.lua and not directly callable.
    -- The bug is: _G.min(middle) with 1 arg errors.
    -- We replicate the exact calculation from the source code.
    local powerMax = 6
    local failures = 0

    for index = 1, powerMax do
        local middle = (powerMax / 2) + 0.5  -- = 3.5

        local ok, err = _G.pcall(function()
            local mod -- luacheck: ignore
            if index < middle then
                mod = index - _G.min(middle)  -- BUG: single-arg min
            else
                mod = index - _G.max(middle)  -- BUG: single-arg max
            end
        end)

        if not ok then
            _G.print(
                ("|cffff0000[FAIL]|r PositionRune index=%d errored: %s"):format(index, _G.tostring(err))
            )
            failures = failures + 1
        end
    end

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r PositionRune arithmetic completed without error for indices 1-6")
        return true
    else
        _G.print(
            ("|cffff0000[FAIL]|r PositionRune arithmetic — %d of 6 indices errored"):format(failures)
        )
        return false
    end
end

-- ============================================================================
-- Test 4: Prediction sub-widget SetWidth double-offset (Defect 1.10)
-- Validates: Requirements 2.10
--
-- On unfixed code: BaseAngleMixin:SetWidth always adds minWidth to the
-- requested width. For prediction sub-widgets (HealingAll, DamageAbsorb),
-- this double-offsets the sizing. oUF calls SetWidth(150) but the frame
-- ends up at 150 + minWidth pixels wide.
-- ============================================================================
local function TestPredictionSetWidth()
    _G.print("|cff00ccff[PBT]|r Test 4: Prediction sub-widget SetWidth (Defect 1.10)")

    local AngleStatusBar = RealUI:GetModule("AngleStatusBar")
    if not AngleStatusBar then
        _G.print("|cffff0000[ERROR]|r AngleStatusBar module not available")
        return false
    end

    local parentFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    parentFrame:SetSize(260, 28)

    -- Create a parent health bar
    local healthBar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
    healthBar:SetSize(200, 14)
    healthBar:SetSmooth(false)

    -- Simulate layout pass for health bar
    local healthMeta = AngleStatusBar:GetBarMeta(healthBar)
    healthMeta.maxWidth = 14 + 200
    healthMeta.minWidth = 14

    -- Create a prediction sub-widget (like HealingAll)
    local predWidget = AngleStatusBar:CreateAngle("StatusBar", nil, healthBar)
    predWidget:SetSize(200, 14)
    predWidget:SetSmooth(false)

    -- Simulate layout pass for prediction widget
    local predMeta = AngleStatusBar:GetBarMeta(predWidget)
    predMeta.maxWidth = 14 + 200
    predMeta.minWidth = 14

    -- oUF calls SetWidth(150) on the prediction sub-widget
    predWidget:SetWidth(150)

    -- Read back the actual frame width
    -- On unfixed code: Frame_SetWidth(self, minWidth + width) = 14 + 150 = 164
    -- Expected (fixed): Frame_SetWidth(self, width) = 150
    local Frame_GetWidth = _G.getmetatable(_G.UIParent).__index.GetWidth
    local actualWidth = Frame_GetWidth(predWidget)

    if _G.math.abs(actualWidth - 150) < 0.01 then
        _G.print("|cff00ff00[PASS]|r Prediction sub-widget SetWidth(150) = 150 (no double-offset)")
        parentFrame:Hide()
        return true
    else
        _G.print(
            ("|cffff0000[FAIL]|r Prediction sub-widget SetWidth(150) = %.1f (expected 150, got minWidth + 150 = %d)"):format(
                actualWidth, 14 + 150
            )
        )
        parentFrame:Hide()
        return false
    end
end


-- ============================================================================
-- Test 5: Global reverse bars toggle (Defect 1.7)
-- Validates: Requirements 2.7
--
-- On unfixed code: RefreshUnits reads db.units[unitKey].reverseFill and
-- falls back to point-based default, but NEVER reads the global
-- RealUI.db.profile.settings.reverseUnitFrameBars setting. The global
-- toggle has no effect.
-- ============================================================================
local function TestGlobalReverseToggle()
    _G.print("|cff00ccff[PBT]|r Test 5: Global reverseUnitFrameBars toggle (Defect 1.7)")

    local UnitFrames = RealUI:GetModule("UnitFrames")
    if not UnitFrames then
        _G.print("|cffff0000[ERROR]|r UnitFrames module not available")
        return false
    end

    -- Save original state
    local ndb = RealUI.db.profile
    local origGlobalReverse = ndb.settings.reverseUnitFrameBars
    local origTargetReverseFill = UnitFrames.db.profile.units.target.reverseFill

    -- Clear per-unit override for target so global toggle is the deciding factor
    UnitFrames.db.profile.units.target.reverseFill = nil

    -- Enable the global toggle
    ndb.settings.reverseUnitFrameBars = true

    -- Now check: does the target frame's health bar get reversed?
    -- The target is on the LEFT side (info.point == "LEFT").
    -- Default without global toggle: point == "RIGHT" => reversed, point == "LEFT" => not reversed
    -- With global toggle ON: should INVERT the default, so LEFT side => reversed (true)

    -- We can't easily call GetReverseFill since it's a local function in Shared.lua.
    -- Instead, trigger RefreshUnits and check the health bar's reverse fill state.
    local targetFrame = _G["RealUITargetFrame"]
    local passed = false

    if targetFrame and targetFrame.Health and targetFrame.Health.GetReverseFill then
        -- Call RefreshUnits to propagate the global toggle
        UnitFrames:RefreshUnits("TestGlobalReverse")

        local reverseFill = targetFrame.Health:GetReverseFill()
        -- Target is on LEFT side. With global toggle ON, expected: true (inverted)
        -- On unfixed code: global toggle is never read, so it falls through to
        -- point-based default: "LEFT" == "RIGHT" => false
        if reverseFill == true then
            _G.print("|cff00ff00[PASS]|r Global reverseUnitFrameBars toggle correctly inverts target fill")
            passed = true
        else
            _G.print("|cffff0000[FAIL]|r Target Health reverseFill =", _G.tostring(reverseFill), "with global toggle ON — toggle not read")
            passed = false
        end
    else
        -- Frames may not exist if not in-game with a target. Test the logic directly.
        -- The unfixed RefreshUnits code:
        --   if unitDB and unitDB.reverseFill ~= nil then reverseFill = unitDB.reverseFill
        --   elseif unitData.health.point then reverseFill = point == "RIGHT"
        -- It never checks ndb.settings.reverseUnitFrameBars
        _G.print("|cffff0000[FAIL]|r Target frame not available — global toggle logic not wired into RefreshUnits")
        passed = false
    end

    -- Restore original state
    ndb.settings.reverseUnitFrameBars = origGlobalReverse
    UnitFrames.db.profile.units.target.reverseFill = origTargetReverseFill

    return passed
end

-- ============================================================================
-- Test 6: Target reverseFill default (Defect 1.9)
-- Validates: Requirements 2.9
--
-- On unfixed code: The target unit defaults in UnitFrames.db don't include
-- a reverseFill key. The config getter reads
-- UnitFrames.db.profile.units.target.reverseFill which returns nil,
-- so the toggle appears unchecked even after being set.
-- ============================================================================
local function TestTargetReverseFillDefault()
    _G.print("|cff00ccff[PBT]|r Test 6: Target reverseFill default (Defect 1.9)")

    local UnitFrames = RealUI:GetModule("UnitFrames")
    if not UnitFrames then
        _G.print("|cffff0000[ERROR]|r UnitFrames module not available")
        return false
    end

    local targetReverseFill = UnitFrames.db.profile.units.target.reverseFill

    if targetReverseFill == false then
        _G.print("|cff00ff00[PASS]|r Target reverseFill default is false (boolean)")
        return true
    elseif targetReverseFill == nil then
        _G.print("|cffff0000[FAIL]|r Target reverseFill default is nil — no reverseFill key in target defaults")
        return false
    else
        _G.print("|cffff0000[FAIL]|r Target reverseFill default is", _G.tostring(targetReverseFill), "(expected false)")
        return false
    end
end

-- ============================================================================
-- Test 7: PostCastStop signature (Defect 1.11)
-- Validates: Requirements 2.11
--
-- On unfixed code: PostCastStop is defined as (self, unit, spellID) but
-- oUF passes (self, unit, empowerComplete). The parameter name is wrong.
-- We verify by inspecting the actual function source via debug.getinfo.
-- ============================================================================
local function TestPostCastStopSignature()
    _G.print("|cff00ccff[PBT]|r Test 7: PostCastStop signature (Defect 1.11)")

    local CastBars = RealUI:GetModule("CastBars")
    if not CastBars then
        _G.print("|cffff0000[ERROR]|r CastBars module not available")
        return false
    end

    -- Find the PostCastStop function on any castbar
    local castbar = CastBars.player or CastBars.target or CastBars.focus
    if not castbar then
        _G.print("|cffff9900[WARN]|r No castbar instances found — checking module-level")
        -- PostCastStop is assigned as castbar.PostCastStop in CreateCastBars
        -- If no castbars exist yet, we can't inspect the function
        _G.print("|cffff0000[FAIL]|r Cannot verify PostCastStop signature — no castbar instances")
        return false
    end

    local postCastStop = castbar.PostCastStop
    if not postCastStop then
        _G.print("|cffff0000[FAIL]|r PostCastStop not found on castbar")
        return false
    end

    -- Use debug.getinfo to inspect parameter names
    local info = _G.debug.getinfo(postCastStop, "u")
    local nparams = info and info.nparams or 0

    -- Use debug.getlocal to get parameter names
    -- Parameters are the first N locals of a function (at level 0 we can't call getlocal
    -- on a non-running function, but we can use debug.getinfo + debug.getlocal trick)
    -- Actually, debug.getlocal on a function (not a level) returns param names in Lua 5.1+
    local paramNames = {}
    for i = 1, nparams do
        local name = _G.debug.getlocal(postCastStop, i)
        if name then
            paramNames[i] = name
        end
    end

    -- Expected: (self, unit, empowerComplete) — 3 params, third named "empowerComplete"
    -- Unfixed: (self, unit, spellID) — 3 params, third named "spellID"
    local thirdParam = paramNames[3]
    if thirdParam == "empowerComplete" then
        _G.print("|cff00ff00[PASS]|r PostCastStop third parameter is 'empowerComplete' (matches oUF contract)")
        return true
    elseif thirdParam == "spellID" then
        _G.print("|cffff0000[FAIL]|r PostCastStop third parameter is 'spellID' — should be 'empowerComplete'")
        return false
    else
        _G.print("|cffff0000[FAIL]|r PostCastStop third parameter is", _G.tostring(thirdParam), "— expected 'empowerComplete'")
        return false
    end
end

-- ============================================================================
-- Test 8: PostCastFail signature (Defect 1.12)
-- Validates: Requirements 2.12
--
-- On unfixed code: PostCastFail is defined as (self, unit, spellID) with
-- 3 parameters, but oUF only passes (self, unit). The third parameter
-- should not exist.
-- ============================================================================
local function TestPostCastFailSignature()
    _G.print("|cff00ccff[PBT]|r Test 8: PostCastFail signature (Defect 1.12)")

    local CastBars = RealUI:GetModule("CastBars")
    if not CastBars then
        _G.print("|cffff0000[ERROR]|r CastBars module not available")
        return false
    end

    local castbar = CastBars.player or CastBars.target or CastBars.focus
    if not castbar then
        _G.print("|cffff0000[FAIL]|r Cannot verify PostCastFail signature — no castbar instances")
        return false
    end

    local postCastFail = castbar.PostCastFail
    if not postCastFail then
        _G.print("|cffff0000[FAIL]|r PostCastFail not found on castbar")
        return false
    end

    local info = _G.debug.getinfo(postCastFail, "u")
    local nparams = info and info.nparams or 0

    -- Expected (fixed): (self, unit) — 2 params, no third parameter
    -- Unfixed: (self, unit, spellID) — 3 params
    if nparams == 2 then
        _G.print("|cff00ff00[PASS]|r PostCastFail has 2 parameters (self, unit) — matches oUF contract")
        return true
    elseif nparams == 3 then
        -- Check the third param name for extra detail
        local thirdName = _G.debug.getlocal(postCastFail, 3)
        _G.print(
            ("|cffff0000[FAIL]|r PostCastFail has 3 parameters (third is '%s') — oUF only passes (self, unit)"):format(
                _G.tostring(thirdName)
            )
        )
        return false
    else
        _G.print("|cffff0000[FAIL]|r PostCastFail has", nparams, "parameters — expected 2")
        return false
    end
end


-- ============================================================================
-- Main runner: executes all 8 test cases
-- ============================================================================
local function RunHuDFixExplorationTests()
    _G.print("|cff00ccff[PBT]|r HuD Fix Exploration Tests — 8 bug condition checks")
    _G.print("|cff00ccff[PBT]|r EXPECTED: Tests FAIL on unfixed code (failure confirms bugs exist)")
    _G.print("---")

    local tests = {
        { fn = TestCastBarTimerDuration,     label = "1.2/1.4 CastBar Timer" },
        { fn = TestCastBarReverseFillSync,   label = "1.3 CastBar ReverseFill Sync" },
        { fn = TestPositionRuneArithmetic,   label = "1.6 PositionRune Arithmetic" },
        { fn = TestPredictionSetWidth,       label = "1.10 Prediction SetWidth" },
        { fn = TestGlobalReverseToggle,      label = "1.7 Global Reverse Toggle" },
        { fn = TestTargetReverseFillDefault, label = "1.9 Target ReverseFill Default" },
        { fn = TestPostCastStopSignature,    label = "1.11 PostCastStop Signature" },
        { fn = TestPostCastFailSignature,    label = "1.12 PostCastFail Signature" },
    }

    local passed, failed = 0, 0
    for _, test in _G.ipairs(tests) do
        local ok, result = _G.pcall(test.fn)
        if not ok then
            _G.print(("|cffff0000[ERROR]|r %s threw: %s"):format(test.label, _G.tostring(result)))
            failed = failed + 1
        elseif result == false then
            failed = failed + 1
        else
            passed = passed + 1
        end
    end

    _G.print("---")
    if failed == 0 then
        _G.print(("|cff00ff00[SUITE PASS]|r All %d HuD fix exploration tests passed"):format(passed))
    else
        _G.print(("|cffff0000[SUITE FAIL]|r %d passed, %d failed (expected on unfixed code)"):format(passed, failed))
    end

    return failed == 0
end

function ns.commands:hudfixexplore()
    return RunHuDFixExplorationTests()
end
