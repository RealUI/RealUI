local ADDON_NAME, ns = ... -- luacheck: ignore

-- Unit Tests: Test mode
-- Feature: combattext-wow12-update
-- Validates: Requirements 11.1, 11.4

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

    _G.print("|cff00ccff[PBT]|r Unit Tests: Test mode — running")

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

    -- 1. CombatText:ToggleTest is a function
    check("CombatText:ToggleTest is a function",
        type(CombatText.ToggleTest) == "function")

    -- 2. private.FilterEvent is nil (old combat log code removed)
    check("private.FilterEvent is nil (old code removed)",
        private.FilterEvent == nil)

    -- 3. private.HandleMessageType is a function (new WoW 12 dispatch exists)
    check("private.HandleMessageType is a function",
        type(private.HandleMessageType) == "function")

    -- 4. Toggle test mode on, capture HandleMessageType calls, verify WoW 12 message types
    do
        local capturedCalls = {}
        local origHandleMessageType = private.HandleMessageType
        private.HandleMessageType = function(messageType, desc1, desc2)
            capturedCalls[#capturedCalls + 1] = {
                messageType = messageType,
                desc1 = desc1,
                desc2 = desc2,
            }
        end

        -- Toggle on
        CombatText:ToggleTest()

        -- Access the test frame directly via private._testFrame
        -- (TestMode.lua stores it there for testability)
        local testFrame = private._testFrame

        if testFrame and testFrame:IsShown() then
            local onUpdate = testFrame:GetScript("OnUpdate")
            if onUpdate then
                -- Fire OnUpdate a few times to generate events
                for i = 1, 5 do
                    onUpdate(testFrame, 1.0)
                end
            end
        end

        -- Toggle off
        CombatText:ToggleTest()

        check("ToggleTest toggles on and off without error", true)

        check("Test frame found and OnUpdate generated events",
            testFrame ~= nil and #capturedCalls > 0)

        -- Verify captured events use WoW 12 message types (have messageType string, not raw combat log events)
        local WOW12_MESSAGE_TYPES = {
            DAMAGE = true, DAMAGE_CRIT = true, SPELL_DAMAGE = true, SPELL_DAMAGE_CRIT = true,
            DAMAGE_SHIELD = true, SPLIT_DAMAGE = true,
            HEAL = true, HEAL_CRIT = true, PERIODIC_HEAL = true, PERIODIC_HEAL_CRIT = true,
            HEAL_ABSORB = true, PERIODIC_HEAL_ABSORB = true, HEAL_CRIT_ABSORB = true, ABSORB_ADDED = true,
            MISS = true, DODGE = true, PARRY = true, EVADE = true, IMMUNE = true,
            DEFLECT = true, BLOCK = true, ABSORB = true, RESIST = true,
            SPELL_MISS = true, SPELL_DODGE = true, SPELL_PARRY = true,
            SPELL_BLOCK = true, SPELL_ABSORB = true, SPELL_RESIST = true,
            ENERGIZE = true, PERIODIC_ENERGIZE = true,
        }

        local RAW_COMBAT_LOG_EVENTS = {
            SWING_DAMAGE = true, SPELL_DAMAGE_SUFFIX = true, RANGE_DAMAGE = true,
            SPELL_HEAL = true, SPELL_PERIODIC_HEAL = true,
            SPELL_MISSED = true, SWING_MISSED = true,
            SPELL_ENERGIZE = true, SPELL_PERIODIC_ENERGIZE = true,
        }

        local allValid = true
        local hasRawEvent = false
        for _, call in _G.ipairs(capturedCalls) do
            if not WOW12_MESSAGE_TYPES[call.messageType] then
                allValid = false
            end
            if RAW_COMBAT_LOG_EVENTS[call.messageType] then
                hasRawEvent = true
            end
        end

        check("All test events use valid WoW 12 message types",
            #capturedCalls > 0 and allValid)

        check("No raw combat log event types (SWING_DAMAGE etc.) present",
            not hasRawEvent)

        -- Restore original
        private.HandleMessageType = origHandleMessageType
    end

    -- Summary
    _G.print("|cff00ccff[PBT]|r Unit Tests: Test mode — " .. totalTests .. " tests, " .. failures .. " failures")
    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r All test mode tests passed")
    else
        _G.print("|cffff0000[FAIL]|r " .. failures .. " test(s) failed")
    end

    return failures == 0
end

function ns.commands:cttestmode()
    return RunTest()
end
