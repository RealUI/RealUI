local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals print ipairs string pairs

-- Frame Movement System Test
-- Comprehensive test suite for the frame positioning and movement system

local RealUI = private.RealUI

local FrameMovementTest = {}

function FrameMovementTest:RunTests()
    print("=== Running Frame Movement System Tests ===")

    if not RealUI.FrameMover then
        print("ERROR: FrameMover system not available")
        return false
    end

    if not RealUI.ConfigMode then
        print("ERROR: ConfigMode system not available")
        return false
    end

    local success = true

    -- Test 1: System initialization
    success = self:TestInitialization() and success

    -- Test 2: Frame registration and management
    success = self:TestFrameRegistration() and success

    -- Test 3: Position validation and boundary checking
    success = self:TestPositionValidation() and success

    -- Test 4: Configuration mode functionality
    success = self:TestConfigurationMode() and success

    -- Test 5: Position persistence
    success = self:TestPositionPersistence() and success

    print("=== Frame Movement System Tests", success and "PASSED" or "FAILED", "===")
    return success
end

function FrameMovementTest:TestInitialization()
    print("Testing Frame Movement system initialization...")

    local frameMover = RealUI.FrameMover
    local configMode = RealUI.ConfigMode

    -- Test FrameMover initialization
    local frameMoverState = frameMover:GetFrameMovementState()
    if not frameMoverState.initialized then
        print("ERROR: FrameMover not initialized")
        return false
    end

    -- Test ConfigMode initialization
    local configModeState = configMode:GetConfigModeState()
    if not configModeState.initialized then
        print("ERROR: ConfigMode not initialized")
        return false
    end

    -- Test that systems are not in config mode by default
    if frameMoverState.configModeActive then
        print("ERROR: FrameMover should not be in config mode by default")
        return false
    end

    if configModeState.active then
        print("ERROR: ConfigMode should not be active by default")
        return false
    end

    print("✓ Initialization test passed")
    return true
end

function FrameMovementTest:TestFrameRegistration()
    print("Testing frame registration and management...")

    local frameMover = RealUI.FrameMover

    -- Get list of moveable frames
    local moveableFrames = frameMover:GetMoveableFrames()
    if not moveableFrames or not next(moveableFrames) then
        print("ERROR: No moveable frames registered")
        return false
    end

    -- Test frame registration
    local testFrameInfo = {
        name = "Test Frame",
        frame = "UIParent",  -- Use UIParent as a test frame that always exists
        defaultParent = "UIParent",
        minBounds = {x = -100, y = -100},
        maxBounds = {x = 100, y = 100},
        snapPoints = {"CENTER"}
    }

    local success = frameMover:RegisterMoveableFrame("TestFrame", testFrameInfo)
    if not success then
        print("ERROR: Failed to register test frame")
        return false
    end

    -- Test that frame appears in moveable frames list
    moveableFrames = frameMover:GetMoveableFrames()
    if not moveableFrames["TestFrame"] then
        print("ERROR: Test frame not found in moveable frames list")
        return false
    end

    print("✓ Frame registration test passed")
    print("  Registered frames:", #moveableFrames)
    return true
end

function FrameMovementTest:TestPositionValidation()
    print("Testing position validation and boundary checking...")

    local frameMover = RealUI.FrameMover

    -- Test position validation with boundary checking enabled
    frameMover:SetBoundaryChecking(true)

    -- Test valid position
    local validX, validY = frameMover:ValidatePosition("PlayerFrame", 0, 0)
    if validX ~= 0 or validY ~= 0 then
        print("ERROR: Valid position should not be modified")
        return false
    end

    -- Test position outside bounds (should be clamped)
    local clampedX, clampedY = frameMover:ValidatePosition("PlayerFrame", 1000, 1000)
    if clampedX == 1000 or clampedY == 1000 then
        print("ERROR: Position outside bounds should be clamped")
        return false
    end

    -- Test boundary checking disabled
    frameMover:SetBoundaryChecking(false)
    local unclampedX, unclampedY = frameMover:ValidatePosition("PlayerFrame", 1000, 1000)
    if unclampedX ~= 1000 or unclampedY ~= 1000 then
        print("ERROR: Position should not be clamped when boundary checking is disabled")
        return false
    end

    -- Re-enable boundary checking
    frameMover:SetBoundaryChecking(true)

    -- Test grid snapping
    frameMover:SetSnapToGrid(true, 10)
    local snappedX, snappedY = frameMover:ValidatePosition("PlayerFrame", 7, 13)
    if snappedX ~= 10 or snappedY ~= 10 then
        print("ERROR: Grid snapping not working correctly. Expected: 10, 10 Got:", snappedX, snappedY)
        return false
    end

    -- Disable grid snapping
    frameMover:SetSnapToGrid(false)

    print("✓ Position validation test passed")
    return true
end

function FrameMovementTest:TestConfigurationMode()
    print("Testing configuration mode functionality...")

    local frameMover = RealUI.FrameMover
    local configMode = RealUI.ConfigMode

    -- Test enabling config mode
    local success = configMode:EnableConfigMode()
    if not success then
        print("ERROR: Failed to enable config mode")
        return false
    end

    -- Verify config mode is active
    if not configMode:IsConfigModeActive() then
        print("ERROR: Config mode should be active")
        return false
    end

    -- Verify FrameMover is also in config mode
    local frameMoverState = frameMover:GetFrameMovementState()
    if not frameMoverState.configModeActive then
        print("ERROR: FrameMover should be in config mode")
        return false
    end

    -- Test configuration options
    configMode:SetShowGrid(false)
    configMode:SetShowSnapPoints(false)
    configMode:SetShowPositionText(false)

    local settings = configMode:GetConfigModeSettings()
    if settings.showGrid or settings.showSnapPoints or settings.showPositionText then
        print("ERROR: Config mode settings not applied correctly")
        return false
    end

    -- Reset settings
    configMode:SetShowGrid(true)
    configMode:SetShowSnapPoints(true)
    configMode:SetShowPositionText(true)

    -- Test disabling config mode
    success = configMode:DisableConfigMode()
    if not success then
        print("ERROR: Failed to disable config mode")
        return false
    end

    -- Verify config mode is inactive
    if configMode:IsConfigModeActive() then
        print("ERROR: Config mode should be inactive")
        return false
    end

    print("✓ Configuration mode test passed")
    return true
end

function FrameMovementTest:TestPositionPersistence()
    print("Testing position persistence...")

    local frameMover = RealUI.FrameMover

    -- Test setting and getting frame position
    local testFrameId = "PlayerFrame"
    local originalPosition = frameMover:GetFramePosition(testFrameId)

    if not originalPosition then
        print("ERROR: Could not get original position for", testFrameId)
        return false
    end

    -- Set a new position
    local testX, testY = 100, -50
    local success = frameMover:SetFramePosition(testFrameId, "CENTER", "UIParent", "CENTER", testX, testY)
    if not success then
        print("ERROR: Failed to set frame position")
        return false
    end

    -- Verify position was set
    local newPosition = frameMover:GetFramePosition(testFrameId)
    if not newPosition then
        print("ERROR: Could not get new position")
        return false
    end

    -- Note: Position might be adjusted by validation, so check if it's close
    if math.abs(newPosition.x - testX) > 5 or math.abs(newPosition.y - testY) > 5 then
        print("ERROR: Position not set correctly. Expected:", testX, testY, "Got:", newPosition.x, newPosition.y)
        return false
    end

    -- Test position saving
    success = frameMover:SaveFramePosition(testFrameId)
    if not success then
        print("ERROR: Failed to save frame position")
        return false
    end

    -- Test position reset
    success = frameMover:ResetFramePosition(testFrameId)
    if not success then
        print("ERROR: Failed to reset frame position")
        return false
    end

    print("✓ Position persistence test passed")
    return true
end

-- Register test command
if RealUI and RealUI.RegisterChatCommand then
    RealUI:RegisterChatCommand("framemovementtest", function()
        FrameMovementTest:RunTests()
    end)
end

-- Auto-run tests in development mode
if RealUI and RealUI.isDev then
    RealUI:ScheduleTimer(function()
        FrameMovementTest:RunTests()
    end, 3)
end
