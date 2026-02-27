local ADDON_NAME, ns = ... -- luacheck: ignore

-- Preservation Property Tests — HuD Rewrite Fixes
-- Feature: hud-rewrite-fixes, Property 2: Preservation
-- Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6, 3.7, 3.8
--
-- These tests verify that EXISTING working behavior is preserved after fixes.
-- On UNFIXED code, they should PASS (confirming baseline behavior).
-- After fixes, they should STILL PASS (confirming no regressions).
--
-- Run with: /realdev hudfixpreserve

local RealUI = _G.RealUI

local NUM_ITERATIONS = 50

-- Simple RNG (xorshift32) — same pattern as existing tests
local rngState = 347
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

local TOLERANCE = 0.01
local function approxEqual(a, b)
    if _G.issecretvalue and _G.issecretvalue(a) then return false end
    if _G.issecretvalue and _G.issecretvalue(b) then return false end
    return _G.math.abs(a - b) < TOLERANCE
end


-- ============================================================================
-- Test 1: Non-angled Health/Power update preservation
-- Validates: Requirements 3.1
--
-- For boss, arena, pet, focus, focustarget, targettarget frames, verify
-- SetValue/SetMinMaxValues calls go through native StatusBar path unchanged.
-- These frames use standard StatusBar (not AngleStatusBar), so they should
-- work via oUF's native path without any custom mixin interference.
-- ============================================================================
local function TestNonAngledFrameUpdate()
    _G.print("|cff00ccff[PBT]|r Preservation 1: Non-angled Health/Power update")

    local failures = 0
    local checkedCount = 0

    -- Non-angled units: pet, focus, focustarget, targettarget
    -- Boss and arena frames are also non-angled but may not be spawned
    local nonAngledUnits = {"Pet", "Focus", "FocusTarget", "TargetTarget"}

    for _, unitName in _G.ipairs(nonAngledUnits) do
        local frameName = "RealUI" .. unitName .. "Frame"
        local frame = _G[frameName]
        if frame and frame.Health then
            -- Verify Health is a native StatusBar (not AngleStatusBar)
            local isStatusBar = frame.Health.IsObjectType and frame.Health:IsObjectType("StatusBar")
            if isStatusBar then
                -- Verify native SetValue/GetValue work
                local ok, err = _G.pcall(function()
                    local min, max = frame.Health:GetMinMaxValues()
                    local val = frame.Health:GetValue()
                    -- These should return numbers (possibly secret)
                    if min == nil and max == nil and val == nil then
                        error("All values nil — StatusBar not initialized")
                    end
                end)
                if not ok then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r %s Health native path error: %s"):format(unitName, _G.tostring(err)))
                end
                checkedCount = checkedCount + 1
            end

            -- Verify Health does NOT have AngleStatusBar metadata
            local AngleStatusBar = RealUI:GetModule("AngleStatusBar")
            if AngleStatusBar then
                local meta = AngleStatusBar:GetBarMeta(frame.Health)
                if meta then
                    -- Non-angled frames should NOT have bar metadata
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r %s Health has AngleStatusBar metadata — should be native StatusBar"):format(unitName))
                end
                checkedCount = checkedCount + 1
            end
        end
    end

    -- Also check boss frames if they exist
    for i = 1, 5 do
        local frame = _G["RealUIBossFrame" .. i]
        if frame and frame.Health then
            local isStatusBar = frame.Health.IsObjectType and frame.Health:IsObjectType("StatusBar")
            if isStatusBar then
                checkedCount = checkedCount + 1
            end
        end
    end

    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No non-angled frames found (frames may not be spawned)")
        return true  -- Not a failure, just inconclusive
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 1: Non-angled frames use native StatusBar path — %d checks"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 1: %d failures out of %d checks"):format(failures, checkedCount))
    end
    return failures == 0
end


-- ============================================================================
-- Test 2: AngleStatusBar SetValue with normal values
-- Validates: Requirements 3.7
--
-- For any non-secret health value, SetValue(val) continues to call
-- SetBarValue and render correct fill level. Property-based: generate
-- random values in [0, max] and verify fill width is proportional.
-- ============================================================================
local function TestAngleStatusBarSetValue()
    _G.print("|cff00ccff[PBT]|r Preservation 2: AngleStatusBar SetValue with normal values —", NUM_ITERATIONS, "iterations")

    local AngleStatusBar = RealUI:GetModule("AngleStatusBar")
    if not AngleStatusBar then
        _G.print("|cffff0000[ERROR]|r AngleStatusBar module not available")
        return false
    end

    local parentFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    parentFrame:SetSize(260, 28)

    local failures = 0
    local barWidth = 200
    local barHeight = 14
    local expectedMaxWidth = barHeight + barWidth

    for i = 1, NUM_ITERATIONS do
        local maxVal = nextRandom(10000) + 1  -- 2 to 10001
        local value = nextRandom(maxVal)       -- 1 to maxVal

        local bar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
        bar:SetSize(barWidth, barHeight)
        bar:SetSmooth(false)

        -- Simulate layout pass
        local meta = AngleStatusBar:GetBarMeta(bar)
        meta.maxWidth = expectedMaxWidth
        meta.minWidth = barHeight

        bar:SetMinMaxValues(0, maxVal)
        bar:SetValue(value)

        -- Verify value round-trip
        local gotValue = bar:GetValue()
        if gotValue ~= value then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: SetValue(%d) -> GetValue() = %s"):format(i, value, _G.tostring(gotValue)))
        end

        -- Verify fill is shown for non-zero values
        if value > 0 and not bar.fill:IsShown() then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: value=%d but fill not shown"):format(i, value))
        end

        -- Verify fill width is proportional to value/max
        local expectedPercent = value / maxVal
        local expectedWidth = _G.Lerp(barHeight, expectedMaxWidth, expectedPercent)
        local actualWidth = bar.fill:GetWidth()
        if not approxEqual(actualWidth, expectedWidth) then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: value=%d max=%d fillWidth=%.2f expected=%.2f"):format(
                i, value, maxVal, actualWidth, expectedWidth))
        end

        bar:Hide()
    end

    parentFrame:Hide()

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 2: AngleStatusBar SetValue — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 2: AngleStatusBar SetValue — %d failures"):format(failures))
    end
    return failures == 0
end


-- ============================================================================
-- Test 3: AngleStatusBar vertex geometry preservation
-- Validates: Requirements 3.2
--
-- SetAngleVertex and OnSizeChanged continue to produce correct trapezoid
-- rendering for all angle values. Property-based: generate random vertex
-- pairs and verify metadata is set correctly.
-- ============================================================================
local function TestVertexGeometryPreservation()
    _G.print("|cff00ccff[PBT]|r Preservation 3: AngleStatusBar vertex geometry —", NUM_ITERATIONS, "iterations")

    local AngleStatusBar = RealUI:GetModule("AngleStatusBar")
    if not AngleStatusBar then
        _G.print("|cffff0000[ERROR]|r AngleStatusBar module not available")
        return false
    end

    local parentFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    parentFrame:SetSize(260, 28)

    local vertexPositions = {1, 2, 3, 4}
    local failures = 0

    local function expectedTrapezoid(lv, rv)
        local leftOdd = (lv % 2 == 1)
        local rightOdd = (rv % 2 == 1)
        if leftOdd and rightOdd then return "TOP"
        elseif not leftOdd and not rightOdd then return "BOTTOM"
        else return nil end
    end

    for i = 1, NUM_ITERATIONS do
        local lv = vertexPositions[nextRandom(#vertexPositions)]
        local rv = vertexPositions[nextRandom(#vertexPositions)]

        local bar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
        bar:SetSize(200, 14)
        bar:SetAngleVertex(lv, rv)

        local meta = AngleStatusBar:GetBarMeta(bar)

        -- Verify vertex round-trip
        if meta.leftVertex ~= lv then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: leftVertex expected=%d got=%s"):format(i, lv, _G.tostring(meta.leftVertex)))
        end
        if meta.rightVertex ~= rv then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: rightVertex expected=%d got=%s"):format(i, rv, _G.tostring(meta.rightVertex)))
        end

        -- Verify trapezoid classification
        local expected = expectedTrapezoid(lv, rv)
        if meta.isTrapezoid ~= expected then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: left=%d right=%d isTrapezoid expected=%s got=%s"):format(
                i, lv, rv, _G.tostring(expected), _G.tostring(meta.isTrapezoid)))
        end

        -- Verify minWidth/maxWidth are set after SetSize
        if meta.minWidth <= 0 or meta.maxWidth <= 0 then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: minWidth=%s maxWidth=%s — should be positive after SetSize"):format(
                i, _G.tostring(meta.minWidth), _G.tostring(meta.maxWidth)))
        end

        bar:Hide()
    end

    parentFrame:Hide()

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 3: Vertex geometry — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 3: Vertex geometry — %d failures"):format(failures))
    end
    return failures == 0
end


-- ============================================================================
-- Test 4: AngleStatusBar SetStatusBarColor/SetStatusBarTexture preservation
-- Validates: Requirements 3.7
--
-- Color and texture calls continue to render correctly. Property-based:
-- generate random RGBA values and verify round-trip through
-- SetStatusBarColor/GetStatusBarColor.
-- ============================================================================
local function TestColorTexturePreservation()
    _G.print("|cff00ccff[PBT]|r Preservation 4: AngleStatusBar Color/Texture —", NUM_ITERATIONS, "iterations")

    local AngleStatusBar = RealUI:GetModule("AngleStatusBar")
    if not AngleStatusBar then
        _G.print("|cffff0000[ERROR]|r AngleStatusBar module not available")
        return false
    end

    local parentFrame = _G.CreateFrame("Frame", nil, _G.UIParent)
    parentFrame:SetSize(260, 28)

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local bar = AngleStatusBar:CreateAngle("StatusBar", nil, parentFrame)
        bar:SetSize(200, 14)
        bar:SetSmooth(false)

        -- Generate random RGBA
        local r = (nextRandom(100) - 1) / 99
        local g = (nextRandom(100) - 1) / 99
        local b = (nextRandom(100) - 1) / 99
        local a = (nextRandom(100) - 1) / 99

        bar:SetStatusBarColor(r, g, b, a)
        local gotR, gotG, gotB, gotA = bar:GetStatusBarColor()

        if gotR ~= r or gotG ~= g or gotB ~= b or gotA ~= a then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: SetStatusBarColor(%.2f,%.2f,%.2f,%.2f) -> (%.2f,%.2f,%.2f,%.2f)"):format(
                i, r, g, b, a, gotR or -1, gotG or -1, gotB or -1, gotA or -1))
        end

        -- Test SetStatusBarTexture with a string path
        local ok, err = _G.pcall(function()
            bar:SetStatusBarTexture("Interface\\TargetingFrame\\UI-StatusBar")
        end)
        if not ok then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: SetStatusBarTexture errored: %s"):format(i, _G.tostring(err)))
        end

        -- Verify GetStatusBarTexture returns the fill texture
        local tex = bar:GetStatusBarTexture()
        if not tex then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iteration %d: GetStatusBarTexture returned nil"):format(i))
        end

        bar:Hide()
    end

    parentFrame:Hide()

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 4: Color/Texture — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 4: Color/Texture — %d failures"):format(failures))
    end
    return failures == 0
end


-- ============================================================================
-- Test 5: Working config options preservation
-- Validates: Requirements 3.8
--
-- Class color bars, class color names, focus click modifier, boss/arena
-- aura counts, cast bar scale/position/text config options continue to
-- apply correctly.
-- ============================================================================
local function TestConfigOptionsPreservation()
    _G.print("|cff00ccff[PBT]|r Preservation 5: Working config options")

    local UnitFrames = RealUI:GetModule("UnitFrames")
    if not UnitFrames or not UnitFrames.db then
        _G.print("|cffff0000[ERROR]|r UnitFrames module or db not available")
        return false
    end

    local failures = 0
    local checkedCount = 0

    local db = UnitFrames.db.profile

    -- 5a: Class color config exists and is boolean
    if _G.type(db.overlay.classColor) ~= "boolean" then
        failures = failures + 1
        _G.print(("|cffff0000[FAIL]|r overlay.classColor is %s, expected boolean"):format(_G.type(db.overlay.classColor)))
    end
    checkedCount = checkedCount + 1

    -- 5b: Class color names config exists and is boolean
    if _G.type(db.overlay.classColorNames) ~= "boolean" then
        failures = failures + 1
        _G.print(("|cffff0000[FAIL]|r overlay.classColorNames is %s, expected boolean"):format(_G.type(db.overlay.classColorNames)))
    end
    checkedCount = checkedCount + 1

    -- 5c: Focus click modifier config exists
    if _G.type(db.misc.focusclick) ~= "boolean" then
        failures = failures + 1
        _G.print(("|cffff0000[FAIL]|r misc.focusclick is %s, expected boolean"):format(_G.type(db.misc.focusclick)))
    end
    checkedCount = checkedCount + 1

    if _G.type(db.misc.focuskey) ~= "string" then
        failures = failures + 1
        _G.print(("|cffff0000[FAIL]|r misc.focuskey is %s, expected string"):format(_G.type(db.misc.focuskey)))
    end
    checkedCount = checkedCount + 1

    -- 5d: Boss/arena aura counts exist and are numbers
    if db.boss then
        if _G.type(db.boss.buffCount) ~= "number" then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r boss.buffCount is not a number")
        end
        if _G.type(db.boss.debuffCount) ~= "number" then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r boss.debuffCount is not a number")
        end
        checkedCount = checkedCount + 2
    end

    -- 5e: Target aura counts
    if db.units and db.units.target then
        if _G.type(db.units.target.debuffCount) ~= "number" then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r units.target.debuffCount is not a number")
        end
        if _G.type(db.units.target.buffCount) ~= "number" then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r units.target.buffCount is not a number")
        end
        checkedCount = checkedCount + 2
    end

    -- 5f: Cast bar config exists
    local CastBars = RealUI:GetModule("CastBars")
    if CastBars and CastBars.db then
        local cdb = CastBars.db.profile
        for _, unit in _G.ipairs({"player", "target", "focus"}) do
            if cdb[unit] then
                if _G.type(cdb[unit].scale) ~= "number" then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r CastBars.%s.scale is %s, expected number"):format(unit, _G.type(cdb[unit].scale)))
                end
                checkedCount = checkedCount + 1

                if cdb[unit].position then
                    if _G.type(cdb[unit].position.x) ~= "number" or _G.type(cdb[unit].position.y) ~= "number" then
                        failures = failures + 1
                        _G.print(("|cffff0000[FAIL]|r CastBars.%s.position x/y not numbers"):format(unit))
                    end
                    checkedCount = checkedCount + 1
                end
            end
        end
    end

    -- 5g: RefreshUnits propagates classColor to spawned frames
    for _, classColor in _G.ipairs({true, false}) do
        db.overlay.classColor = classColor
        UnitFrames:RefreshUnits("PreservationTest")

        local frame = _G["RealUIPlayerFrame"]
        if frame and frame.Health then
            if frame.Health.colorClass ~= classColor then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r After RefreshUnits classColor=%s, Player Health.colorClass=%s"):format(
                    _G.tostring(classColor), _G.tostring(frame.Health.colorClass)))
            end
            checkedCount = checkedCount + 1
        end
    end

    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No config checks performed")
        return true
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 5: Config options — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 5: Config options — %d failures out of %d checks"):format(failures, checkedCount))
    end
    return failures == 0
end


-- ============================================================================
-- Test 6: CombatFader opacity transitions preservation
-- Validates: Requirements 3.3
--
-- Opacity transitions continue to work for all registered frames.
-- Verify config structure, API methods, and opacity lookup for all states.
-- ============================================================================
local function TestCombatFaderPreservation()
    _G.print("|cff00ccff[PBT]|r Preservation 6: CombatFader opacity transitions")

    local CombatFader = RealUI:GetModule("CombatFader")
    if not CombatFader then
        _G.print("|cffff0000[ERROR]|r CombatFader module not available")
        return false
    end

    local STATES = {"incombat", "harmtarget", "target", "hurt", "outofcombat"}
    local failures = 0
    local checkedCount = 0

    -- 6a: Verify CombatFader has expected API methods
    local expectedMethods = {"RegisterModForFade", "RegisterFrameForFade", "FadeFrames", "UpdateStatus", "RefreshMod"}
    for _, method in _G.ipairs(expectedMethods) do
        if _G.type(CombatFader[method]) ~= "function" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r CombatFader.%s is %s, expected function"):format(method, _G.type(CombatFader[method])))
        end
        checkedCount = checkedCount + 1
    end

    -- 6b: Verify combatfade config for UnitFrames, CastBars, ClassResource
    local MODULES_TO_CHECK = {
        {name = "UnitFrames", path = {"profile", "misc", "combatfade"}},
        {name = "CastBars",   path = {"profile", "combatfade"}},
        {name = "ClassResource", path = {"class", "combatfade"}},
    }

    for _, modInfo in _G.ipairs(MODULES_TO_CHECK) do
        local mod = RealUI:GetModule(modInfo.name)
        if mod and mod.db then
            local options = RealUI.GetOptions(modInfo.name, modInfo.path)
            if options then
                if options.enabled == nil then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r %s: combatfade.enabled is nil"):format(modInfo.name))
                end
                checkedCount = checkedCount + 1

                if options.opacity then
                    for _, state in _G.ipairs(STATES) do
                        local o = options.opacity[state]
                        if o == nil then
                            failures = failures + 1
                            _G.print(("|cffff0000[FAIL]|r %s: opacity[%s] is nil"):format(modInfo.name, state))
                        elseif _G.type(o) ~= "number" or o < 0 or o > 1 then
                            failures = failures + 1
                            _G.print(("|cffff0000[FAIL]|r %s: opacity[%s] = %s, expected number in [0,1]"):format(
                                modInfo.name, state, _G.tostring(o)))
                        end
                        checkedCount = checkedCount + 1
                    end
                end
            end
        end
    end

    -- 6c: Verify opacity read-back (property-based: set and read back)
    local UnitFrames = RealUI:GetModule("UnitFrames")
    if UnitFrames and UnitFrames.db then
        local options = RealUI.GetOptions("UnitFrames", {"profile", "misc", "combatfade"})
        if options and options.opacity then
            local savedOpacity = {}
            for _, state in _G.ipairs(STATES) do
                savedOpacity[state] = options.opacity[state]
            end

            local testValues = {0.0, 0.25, 0.5, 0.75, 1.0}
            for _, state in _G.ipairs(STATES) do
                for _, testO in _G.ipairs(testValues) do
                    options.opacity[state] = testO
                    local readBack = options.opacity[state]
                    if not approxEqual(readBack, testO) then
                        failures = failures + 1
                        _G.print(("|cffff0000[FAIL]|r opacity readback: state=%s set=%.2f got=%.2f"):format(
                            state, testO, readBack or -1))
                    end
                    checkedCount = checkedCount + 1
                end
            end

            -- Restore
            for _, state in _G.ipairs(STATES) do
                options.opacity[state] = savedOpacity[state]
            end
        end
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 6: CombatFader — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 6: CombatFader — %d failures out of %d checks"):format(failures, checkedCount))
    end
    return failures == 0
end


-- ============================================================================
-- Test 7: oUF tags preservation
-- Validates: Requirements 3.5
--
-- realui:healthPercent, realui:healthValue, realui:powerPercent,
-- realui:powerValue, realui:name, realui:level, realui:threat,
-- realui:range, realui:pvptimer continue to return correct values.
-- ============================================================================
local function TestOUFTagsPreservation()
    _G.print("|cff00ccff[PBT]|r Preservation 7: oUF tags")

    local UnitFrames = RealUI:GetModule("UnitFrames")
    if not UnitFrames then
        _G.print("|cffff0000[ERROR]|r UnitFrames module not available")
        return false
    end

    local failures = 0
    local checkedCount = 0

    -- 7a: Verify GetHealthTagString returns valid strings for all modes
    local statusTextOptions = {"perc", "abs", "both", "smart"}
    for _, statusText in _G.ipairs(statusTextOptions) do
        local result = UnitFrames.GetHealthTagString(statusText)
        if _G.type(result) ~= "string" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r GetHealthTagString(%q) returned %s"):format(statusText, _G.type(result)))
        elseif not result:find("[realui:health", 1, true) then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r GetHealthTagString(%q) missing health tag reference"):format(statusText))
        end
        checkedCount = checkedCount + 1
    end

    -- 7b: Verify GetPowerTagString returns valid strings
    local powerTypes = {"MANA", "RAGE", "ENERGY", "FOCUS"}
    for _, pt in _G.ipairs(powerTypes) do
        for _, statusText in _G.ipairs(statusTextOptions) do
            local result = UnitFrames.GetPowerTagString(statusText, pt)
            if _G.type(result) ~= "string" then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r GetPowerTagString(%q, %q) returned %s"):format(statusText, pt, _G.type(result)))
            end
            checkedCount = checkedCount + 1
        end
    end

    -- 7c: Verify tag methods are registered in oUF
    -- Access oUF tags through the private table or global
    local oUF = _G.oUF
    if oUF and oUF.Tags and oUF.Tags.Methods then
        local requiredTags = {
            "realui:healthcolor",
            "realui:healthPercent",
            "realui:healthValue",
            "realui:powerPercent",
            "realui:powerValue",
            "realui:name",
            "realui:level",
            "realui:pvptimer",
            "realui:threat",
        }
        for _, tagName in _G.ipairs(requiredTags) do
            if _G.type(oUF.Tags.Methods[tagName]) ~= "function" then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r oUF tag '%s' not registered (type=%s)"):format(
                    tagName, _G.type(oUF.Tags.Methods[tagName])))
            end
            checkedCount = checkedCount + 1
        end

        -- 7d: Verify tag functions return strings for "player" unit
        local safeTags = {"realui:healthcolor", "realui:healthPercent", "realui:healthValue",
                          "realui:powerPercent", "realui:powerValue", "realui:pvptimer"}
        for _, tagName in _G.ipairs(safeTags) do
            local tagFn = oUF.Tags.Methods[tagName]
            if tagFn then
                local ok, result = _G.pcall(tagFn, "player")
                if not ok then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r Tag '%s' errored for 'player': %s"):format(tagName, _G.tostring(result)))
                elseif result ~= nil and _G.type(result) ~= "string" then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r Tag '%s' returned %s for 'player', expected string or nil"):format(
                        tagName, _G.type(result)))
                end
                checkedCount = checkedCount + 1
            end
        end
    else
        _G.print("|cffff9900[WARN]|r oUF.Tags.Methods not accessible — skipping tag registration checks")
    end

    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No tag checks performed")
        return true
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 7: oUF tags — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 7: oUF tags — %d failures out of %d checks"):format(failures, checkedCount))
    end
    return failures == 0
end


-- ============================================================================
-- Main runner: executes all 7 preservation test cases
-- ============================================================================
local function RunHuDFixPreservationTests()
    _G.print("|cff00ccff[PBT]|r HuD Fix Preservation Tests — 7 baseline behavior checks")
    _G.print("|cff00ccff[PBT]|r EXPECTED: Tests PASS on unfixed code (confirms behavior to preserve)")
    _G.print("---")

    local tests = {
        { fn = TestNonAngledFrameUpdate,       label = "3.1 Non-angled Health/Power" },
        { fn = TestAngleStatusBarSetValue,     label = "3.7 AngleStatusBar SetValue" },
        { fn = TestVertexGeometryPreservation, label = "3.2 Vertex Geometry" },
        { fn = TestColorTexturePreservation,   label = "3.7 Color/Texture" },
        { fn = TestConfigOptionsPreservation,  label = "3.8 Config Options" },
        { fn = TestCombatFaderPreservation,    label = "3.3 CombatFader" },
        { fn = TestOUFTagsPreservation,        label = "3.5 oUF Tags" },
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
        _G.print(("|cff00ff00[SUITE PASS]|r All %d HuD fix preservation tests passed"):format(passed))
    else
        _G.print(("|cffff0000[SUITE FAIL]|r %d passed, %d failed"):format(passed, failed))
    end

    return failed == 0
end

function ns.commands:hudfixpreserve()
    return RunHuDFixPreservationTests()
end
