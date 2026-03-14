local ADDON_NAME, ns = ... -- luacheck: ignore

-- Unit Tests: Initialization and event handling
-- Feature: combattext-wow12-update
-- Validates: Requirements 1.1-1.3, 2.1-2.5, 4.4-4.5

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

    _G.print("|cff00ccff[PBT]|r Unit Tests: Initialization and event handling — running")

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

    -- 1. Test that OnInitialize created AceDB (CombatText.db exists and is a table)
    check("OnInitialize created AceDB (CombatText.db is a table)",
        type(CombatText.db) == "table")

    -- 2. Test that COMBAT_TEXT_UPDATE is registered (handler method exists)
    check("COMBAT_TEXT_UPDATE handler method exists",
        type(CombatText.COMBAT_TEXT_UPDATE) == "function")

    -- 3. Test that SetActiveUnit handler exists (verifies init path)
    check("UNIT_ENTERED_VEHICLE handler method exists",
        type(CombatText.UNIT_ENTERED_VEHICLE) == "function")
    check("UNIT_EXITING_VEHICLE handler method exists",
        type(CombatText.UNIT_EXITING_VEHICLE) == "function")

    -- 4. Test that the module does NOT have a disabled message (no isMidnight guard)
    -- If the midnight guard were active, CombatText.db would be nil
    check("No isMidnight guard (db initialized successfully)",
        CombatText.db ~= nil)

    -- 5. Test vehicle switching via mock of C_CombatText.SetActiveUnit
    do
        local calls = {}
        local origSetActiveUnit = _G.C_CombatText.SetActiveUnit
        _G.C_CombatText.SetActiveUnit = function(unit)
            calls[#calls + 1] = unit
        end

        -- Fire UNIT_ENTERED_VEHICLE with showVehicle=true
        calls = {}
        CombatText:UNIT_ENTERED_VEHICLE("UNIT_ENTERED_VEHICLE", "player", true)
        check("UNIT_ENTERED_VEHICLE with showVehicle=true calls SetActiveUnit('vehicle')",
            #calls == 1 and calls[1] == "vehicle")

        -- Fire UNIT_EXITING_VEHICLE
        calls = {}
        CombatText:UNIT_EXITING_VEHICLE("UNIT_EXITING_VEHICLE", "player")
        check("UNIT_EXITING_VEHICLE calls SetActiveUnit('player')",
            #calls == 1 and calls[1] == "player")

        -- Restore original
        _G.C_CombatText.SetActiveUnit = origSetActiveUnit
    end

    -- 6. Test combat state notifications
    do
        local capturedEventInfo
        local origAddEvent = private.AddEvent
        private.AddEvent = function(eventInfo)
            capturedEventInfo = eventInfo
        end

        -- PLAYER_REGEN_DISABLED → ENTERING_COMBAT
        CombatText:PLAYER_REGEN_DISABLED()
        check("PLAYER_REGEN_DISABLED produces eventInfo",
            capturedEventInfo ~= nil)
        check("PLAYER_REGEN_DISABLED eventInfo.string == ENTERING_COMBAT",
            capturedEventInfo and capturedEventInfo.string == _G.ENTERING_COMBAT)
        check("PLAYER_REGEN_DISABLED scrollType == 'notification'",
            capturedEventInfo and capturedEventInfo.scrollType == "notification")

        -- PLAYER_REGEN_ENABLED → LEAVING_COMBAT
        capturedEventInfo = nil -- luacheck: ignore 311
        CombatText:PLAYER_REGEN_ENABLED()
        check("PLAYER_REGEN_ENABLED produces eventInfo",
            capturedEventInfo ~= nil)
        check("PLAYER_REGEN_ENABLED eventInfo.string == LEAVING_COMBAT",
            capturedEventInfo and capturedEventInfo.string == _G.LEAVING_COMBAT)
        check("PLAYER_REGEN_ENABLED scrollType == 'notification'",
            capturedEventInfo and capturedEventInfo.scrollType == "notification")

        -- Restore original
        private.AddEvent = origAddEvent
    end

    -- 7. Test unknown message type produces no eventInfo
    do
        local capturedEventInfo
        local origAddEvent = private.AddEvent
        private.AddEvent = function(eventInfo)
            capturedEventInfo = eventInfo
        end

        private.HandleMessageType("FUTURE_NEW_TYPE")
        check("Unknown message type 'FUTURE_NEW_TYPE' produces no eventInfo",
            capturedEventInfo == nil)

        -- Restore original
        private.AddEvent = origAddEvent
    end

    -- 8. Test zero-amount damage (WoW 12: stored as secretAmount)
    do
        local capturedEventInfo
        local origAddEvent = private.AddEvent
        private.AddEvent = function(eventInfo)
            capturedEventInfo = eventInfo
        end

        private.HandleMessageType("DAMAGE", 0)
        check("Zero-amount DAMAGE produces eventInfo",
            capturedEventInfo ~= nil)
        check("Zero-amount DAMAGE eventInfo.secretAmount == 0",
            capturedEventInfo and capturedEventInfo.secretAmount == 0)

        -- Restore original
        private.AddEvent = origAddEvent
    end

    -- 9. Test energize with unknown power type (WoW 12: desc2 is secret, can't use as table key)
    do
        local capturedEventInfo
        local origAddEvent = private.AddEvent
        private.AddEvent = function(eventInfo)
            capturedEventInfo = eventInfo
        end

        -- desc2 = "NEW_POWER_TYPE" (secret in real WoW, but untainted in test)
        private.HandleMessageType("ENERGIZE", 50, "NEW_POWER_TYPE")
        check("Unknown power type 'NEW_POWER_TYPE' produces eventInfo",
            capturedEventInfo ~= nil)
        -- WoW 12: no text field (can't use secret desc2 as table key)
        check("Unknown power type has no text field (secret values)",
            capturedEventInfo and capturedEventInfo.text == nil)
        -- WoW 12: secretAmount stores desc1
        check("Unknown power type secretAmount == 50",
            capturedEventInfo and capturedEventInfo.secretAmount == 50)

        -- Verify color: ENERGIZE is not in MESSAGE_TYPE_COLORS, so color is nil
        check("Unknown power type color is nil (ENERGIZE not in MESSAGE_TYPE_COLORS)",
            capturedEventInfo and capturedEventInfo.color == nil)

        -- Restore original
        private.AddEvent = origAddEvent
    end

    -- Summary
    _G.print("|cff00ccff[PBT]|r Unit Tests: Initialization and event handling — " .. totalTests .. " tests, " .. failures .. " failures")
    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r All initialization and event handling tests passed")
    else
        _G.print("|cffff0000[FAIL]|r " .. failures .. " test(s) failed")
    end

    return failures == 0
end

function ns.commands:ctinitevent()
    return RunTest()
end
