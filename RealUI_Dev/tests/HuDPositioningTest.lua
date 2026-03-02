local ADDON_NAME, private = ... -- luacheck: ignore

-- Lua Globals --
-- luacheck: globals print ipairs string

-- HuD Positioning System Test
-- Simple test to verify HuD positioning functionality

local RealUI = private.RealUI

local HuDPositioningTest = {}

function HuDPositioningTest:RunTests()
    print("=== Running HuD Positioning Tests ===")

    if not RealUI.HuDPositioning then
        print("ERROR: HuDPositioning system not available")
        return false
    end

    local success = true

    -- Test 1: System initialization
    success = self:TestInitialization() and success

    -- Test 2: HuD size management
    success = self:TestHuDSizeManagement() and success

    -- Test 3: Position calculation
    success = self:TestPositionCalculation() and success

    -- Test 4: Resolution detection
    success = self:TestResolutionDetection() and success

    print("=== HuD Positioning Tests", success and "PASSED" or "FAILED", "===")
    return success
end

function HuDPositioningTest:TestInitialization()
    print("Testing HuD Positioning initialization...")

    local hudPos = RealUI.HuDPositioning
    local state = hudPos:GetHuDState()

    if not state.initialized then
        print("ERROR: HuD Positioning not initialized")
        return false
    end

    if state.currentSize < 1 or state.currentSize > 3 then
        print("ERROR: Invalid HuD size:", state.currentSize)
        return false
    end

    if state.currentScale <= 0 then
        print("ERROR: Invalid HuD scale:", state.currentScale)
        return false
    end

    print("✓ Initialization test passed")
    return true
end

function HuDPositioningTest:TestHuDSizeManagement()
    print("Testing HuD size management...")

    local hudPos = RealUI.HuDPositioning
    local originalSize = hudPos:GetHuDSize()

    -- Test setting different sizes
    for sizeId = 1, 3 do
        local success = hudPos:SetHuDSize(sizeId)
        if not success then
            print("ERROR: Failed to set HuD size to", sizeId)
            return false
        end

        local currentSize = hudPos:GetHuDSize()
        if currentSize ~= sizeId then
            print("ERROR: HuD size mismatch. Expected:", sizeId, "Got:", currentSize)
            return false
        end
    end

    -- Test invalid size
    local success = hudPos:SetHuDSize(99)
    if success then
        print("ERROR: Should not accept invalid HuD size")
        return false
    end

    -- Restore original size
    hudPos:SetHuDSize(originalSize)

    print("✓ HuD size management test passed")
    return true
end

function HuDPositioningTest:TestPositionCalculation()
    print("Testing position calculation...")

    local hudPos = RealUI.HuDPositioning

    -- Test getting positions for both layouts
    for layoutId = 1, 2 do
        local positions = hudPos:GetAllPositions(layoutId)
        if not positions then
            print("ERROR: No positions found for layout", layoutId)
            return false
        end

        -- Check for required position keys
        local requiredKeys = {"HuDX", "HuDY", "UFHorizontal", "ActionBarsY"}
        for _, key in ipairs(requiredKeys) do
            if positions[key] == nil then
                print("ERROR: Missing position key", key, "in layout", layoutId)
                return false
            end
        end
    end

    -- Test position setting and getting
    local testLayout = 1
    local testKey = "HuDX"
    local originalValue = hudPos:GetPosition(testLayout, testKey)
    local testValue = 100

    local success = hudPos:SetPosition(testLayout, testKey, testValue)
    if not success then
        print("ERROR: Failed to set position")
        return false
    end

    local newValue = hudPos:GetPosition(testLayout, testKey)
    if newValue ~= testValue then
        print("ERROR: Position value mismatch. Expected:", testValue, "Got:", newValue)
        return false
    end

    -- Restore original value
    hudPos:SetPosition(testLayout, testKey, originalValue)

    print("✓ Position calculation test passed")
    return true
end

function HuDPositioningTest:TestResolutionDetection()
    print("Testing resolution detection...")

    local hudPos = RealUI.HuDPositioning
    local state = hudPos:GetHuDState()

    -- Check that screen resolution was detected
    if state.screenWidth <= 0 or state.screenHeight <= 0 then
        print("ERROR: Invalid screen resolution detected:", state.screenWidth, "x", state.screenHeight)
        return false
    end

    if state.aspectRatio <= 0 then
        print("ERROR: Invalid aspect ratio:", state.aspectRatio)
        return false
    end

    -- Check resolution category
    local category = hudPos:GetResolutionCategory()
    local validCategories = {low = true, standard = true, high = true, ultra_high = true}
    if not validCategories[category] then
        print("ERROR: Invalid resolution category:", category)
        return false
    end

    print("✓ Resolution detection test passed")
    print("  Screen:", state.screenWidth, "x", state.screenHeight)
    print("  Aspect ratio:", string.format("%.2f", state.aspectRatio))
    print("  Category:", category)
    return true
end

-- Register test command
if RealUI and RealUI.RegisterChatCommand then
    RealUI:RegisterChatCommand("hudtest", function()
        HuDPositioningTest:RunTests()
    end)
end

-- Auto-run tests in development mode
if RealUI and RealUI.isDev then
    RealUI:ScheduleTimer(function()
        HuDPositioningTest:RunTests()
    end, 2)
end
