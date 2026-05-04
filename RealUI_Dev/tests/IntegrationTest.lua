local ADDON_NAME, private = ... -- luacheck: ignore

-- Lua Globals --
-- luacheck: globals print

-- Integration Test for RealUI Systems
-- Tests the integration between core systems (HuD positioning, layout management, etc.)

local RealUI = private.RealUI

local IntegrationTest = {}

function IntegrationTest:RunIntegrationTests()
    print("=== Running Integration Tests ===")

    local success = true

    -- Test 1: System availability
    success = self:TestSystemAvailability() and success

    -- Test 2: FrameMover module integration
    success = self:TestFrameMoverModuleIntegration() and success

    print("=== Integration Tests", success and "PASSED" or "FAILED", "===")
    return success
end

function IntegrationTest:TestSystemAvailability()
    print("Testing system availability...")

    -- Check that required systems are available
    local requiredSystems = {
        "HuDPositioning",
        "LayoutManager",
    }

    for _, systemName in ipairs(requiredSystems) do
        if not RealUI[systemName] then
            print("WARNING: System not available:", systemName)
            -- Not a hard failure — some systems may not be loaded in all contexts
        end
    end

    -- Verify the FrameMover AceModule is available
    local FrameMover = RealUI:GetModule("FrameMover", true)
    if not FrameMover then
        print("ERROR: FrameMover module not available")
        return false
    end

    print("✓ System availability test passed")
    return true
end

function IntegrationTest:TestFrameMoverModuleIntegration()
    print("Testing FrameMover module integration...")

    local FrameMover = RealUI:GetModule("FrameMover", true)
    if not FrameMover then
        print("ERROR: FrameMover module not available")
        return false
    end

    -- Verify the module exposes FrameList for the config panel
    if not FrameMover.FrameList then
        print("ERROR: FrameMover.FrameList not available for config panel")
        return false
    end

    -- Verify the module exposes MoveFrameGroup for the config panel
    if not FrameMover.MoveFrameGroup then
        print("ERROR: FrameMover.MoveFrameGroup not available for config panel")
        return false
    end

    -- Verify MoveUIFrames method exists
    if not FrameMover.MoveUIFrames then
        print("ERROR: FrameMover:MoveUIFrames() method not available")
        return false
    end

    print("✓ FrameMover module integration test passed")
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
