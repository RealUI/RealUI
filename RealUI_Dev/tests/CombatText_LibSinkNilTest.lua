local ADDON_NAME, ns = ... -- luacheck: ignore

-- Unit Test: LibSink nil location fallback
-- Feature: combattext-wow12-update
-- Validates: Requirements 10.2

local function RunTest()
    local CombatText = _G.RealUI:GetModule("CombatText")
    if not CombatText then
        _G.print("|cffff0000[ERROR]|r CombatText module not available")
        return false
    end

    local private = CombatText._testPrivate
    if not private then
        _G.print("|cffff0000[ERROR]|r CombatText._testPrivate not exposed")
        return false
    end

    local LibSink = _G.LibStub and _G.LibStub("LibSink-2.0", true)
    if not LibSink then
        _G.print("|cffff9900[SKIP]|r LibSink-2.0 not available via LibStub")
        return nil -- nil = skip (not a failure)
    end

    local sinkHandler
    if LibSink.registeredSinks and LibSink.registeredSinks["CombatText"] then
        sinkHandler = LibSink.registeredSinks["CombatText"].handler
    end

    if not sinkHandler then
        _G.print("|cffff0000[ERROR]|r Could not find registered CombatText sink handler")
        return false
    end

    _G.print("|cff00ccff[TEST]|r Unit Test: LibSink nil location fallback — running")

    local failures = 0
    local totalTests = 0

    local function check(name, condition)
        totalTests = totalTests + 1
        if not condition then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r " .. name)
        else
            _G.print("|cff00ff00[PASS]|r " .. name)
        end
    end

    -- Mock AddEvent to capture eventInfo
    local capturedEventInfo = nil
    local originalAddEvent = private.AddEvent
    private.AddEvent = function(eventInfo)
        capturedEventInfo = eventInfo
    end

    -- Call sink with nil location: sink(addon, text, r, g, b, font, size, outline, sticky, location, icon)
    capturedEventInfo = nil
    sinkHandler(nil, "Test", 1, 1, 1, nil, nil, nil, false, nil, nil)

    check("Sink with nil location produces eventInfo",
        capturedEventInfo ~= nil)
    check("Sink with nil location defaults scrollType to 'notification'",
        capturedEventInfo and capturedEventInfo.scrollType == "notification")

    -- Restore original AddEvent
    private.AddEvent = originalAddEvent

    -- Summary
    _G.print("|cff00ccff[TEST]|r Unit Test: LibSink nil location fallback — " .. totalTests .. " tests, " .. failures .. " failures")
    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r LibSink nil location fallback test passed")
    else
        _G.print("|cffff0000[FAIL]|r " .. failures .. " test(s) failed")
    end

    return failures == 0
end

function ns.commands:ctlibsinkniltest()
    return RunTest()
end
