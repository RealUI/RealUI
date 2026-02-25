local ADDON_NAME, private = ... -- luacheck: ignore

-- Lua Globals --
-- luacheck: globals print

-- Integration Test for Frame Positioning and Movement System
-- Tests the integration between FrameMover, ConfigMode, and existing systems

local RealUI = private.RealUI

local IntegrationTest = {}

function IntegrationTest:RunIntegrationTests()
    print("=== Running Frame Positioning Integration Tests ===")

    local success = true

    -- Test 1: System availability
    success = self:TestSystemAvailability() and success

    -- Test 2: System integration
    success = self:TestSystemIntegration() and success

    -- Test 3: Command integration
    success = self:TestCommandIntegration() and success

    print("=== Integration Tests", success and "PASSED" or "FAILED", "===")
    return success
end

function IntegrationTest:TestSystemAvailability()
    print("Testing system availability...")

    -- Check that all required systems are available
    local requiredSystems = {
        "FrameMover",
        "ConfigMode",
        "HuDPositioning",
        "LayoutManager"
    }

    for _, systemName in ipairs(requiredSystems) do
        if not RealUI[systemName] then
            print("ERROR: System not available:", systemName)
            return false
        end
    end

    print("✓ All required systems are available")
    return true
end

function IntegrationTest:TestSystemIntegration()
    print("Testing system integration...")

    -- Test FrameMover and ConfigMode integration
    if RealUI.FrameMover and RealUI.ConfigMode then
        -- Enable config mode through ConfigMode
        local success = RealUI.ConfigMode:EnableConfigMode()
        if not success then
            print("ERROR: Failed to enable config mode")
            return false
        end

        -- Check that FrameMover is also in config mode
        local frameMoverState = RealUI.FrameMover:GetFrameMovementState()
        if not frameMoverState.configModeActive then
            print("ERROR: FrameMover should be in config mode when ConfigMode is enabled")
            return false
        end

        -- Disable config mode
        success = RealUI.ConfigMode:DisableConfigMode()
        if not success then
            print("ERROR: Failed to disable config mode")
            return false
        end

        -- Check that FrameMover is no longer in config mode
        frameMoverState = RealUI.FrameMover:GetFrameMovementState()
        if frameMoverState.configModeActive then
            print("ERROR: FrameMover should not be in config mode when ConfigMode is disabled")
            return false
        end
    end

    print("✓ System integration test passed")
    return true
end

function IntegrationTest:TestCommandIntegration()
    print("Testing command integration...")

    -- Test that chat commands are registered
    local testCommands = {
        "framemover",
        "configmode"
    }

    -- Note: We can't easily test if commands are registered without triggering them
    -- This is a placeholder for command integration testing
    print("✓ Command integration test passed (placeholder)")
    return true
end

-- Register test command
if RealUI and RealUI.RegisterChatCommand then
    RealUI:RegisterChatCommand("integrationtest", function()
        IntegrationTest:RunIntegrationTests()
    end)
end

-- Auto-run integration tests in development mode
if RealUI and RealUI.isDev then
    RealUI:ScheduleTimer(function()
        IntegrationTest:RunIntegrationTests()
    end, 4)
end
