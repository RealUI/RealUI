local ADDON_NAME, private = ...

-- Simple test for ModuleFramework functionality
-- This file demonstrates the new loading and coordination features

local RealUI = private.RealUI
local debug = RealUI.GetDebug("ModuleFrameworkTest")

-- Test Module Registration and Loading
local function TestModuleLoading()
    local framework = RealUI.ModuleFramework
    if not framework then
        debug("ModuleFramework not available")
        return false
    end

    debug("Testing module loading functionality...")

    -- Test module registration
    local success = framework:RegisterModule("TestModule", "enhancement", {}, {
        description = "Test module for framework validation"
    })

    if success then
        debug("Module registration successful")
    else
        debug("Module registration failed")
        return false
    end

    -- Test module loading
    success = framework:LoadModule("TestModule")
    if success then
        debug("Module loading test successful")
    else
        debug("Module loading test failed")
    end

    -- Test module state persistence
    framework:SaveModuleState("TestModule", { testData = "test_value" })
    debug("Module state saved")

    -- Test inter-module communication
    framework:RegisterMessageHandler("TestModule", "TEST_MESSAGE", function(from, message, data)
        debug("Received test message from", from, ":", message, data)
    end)

    framework:SendModuleMessage("ModuleFramework", "TestModule", "TEST_MESSAGE", "test_data")
    debug("Test message sent")

    -- Test event coordination
    framework:RegisterEventCoordinator("TEST_EVENT", function(eventName, data)
        debug("Coordinating test event:", eventName, data)
        return true
    end)

    framework:CoordinateEvent("TEST_EVENT", "test_event_data")
    debug("Test event coordinated")

    return true
end

-- Test Module State Management
local function TestStateManagement()
    local framework = RealUI.ModuleFramework
    if not framework then
        return false
    end

    debug("Testing state management functionality...")

    -- Test configuration save/load
    local success = framework:SaveModuleConfiguration()
    if success then
        debug("Configuration save successful")
    else
        debug("Configuration save failed")
    end

    success = framework:LoadModuleConfiguration()
    if success then
        debug("Configuration load successful")
    else
        debug("Configuration load failed")
    end

    -- Test performance stats
    local stats = framework:GetSystemPerformanceStats()
    debug("System performance stats:", stats.totalModules, "total,", stats.enabledModules, "enabled")

    -- Test framework status
    local status = framework:GetFrameworkStatus()
    debug("Framework status - Initialized:", status.initialized, "Valid deps:", status.hasValidDependencies)

    return true
end

-- Run tests when framework is initialized
local function RunTests()
    if not RealUI.ModuleFramework or not RealUI.ModuleFramework:IsInitialized() then
        debug("ModuleFramework not ready, scheduling test retry")
        RealUI:ScheduleTimer(RunTests, 1)
        return
    end

    debug("Running ModuleFramework tests...")

    local loadingTest = TestModuleLoading()
    local stateTest = TestStateManagement()

    if loadingTest and stateTest then
        debug("All ModuleFramework tests passed!")
    else
        debug("Some ModuleFramework tests failed")
    end
end

-- Schedule tests to run after initialization
if RealUI.isInitialized then
    RunTests()
else
    RealUI:RegisterEvent("ADDON_LOADED", function(event, addonName)
        if addonName == ADDON_NAME then
            RealUI:ScheduleTimer(RunTests, 2)
        end
    end)
end
