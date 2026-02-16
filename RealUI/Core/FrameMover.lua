local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs table pcall print string _G math

-- RealUI Frame Positioning and Movement System
-- This module provides comprehensive frame positioning, movement, and configuration capabilities
-- Implements Frame_Mover for repositioning UI elements and Config_Mode for visual feedback

local RealUI = private.RealUI
local debug = RealUI.GetDebug("FrameMover")

local FrameMover = {}
RealUI.FrameMover = FrameMover

-- Frame Movement Constants
local MOVEMENT_STEP = 1
local BOUNDARY_PADDING = 10
local SNAP_THRESHOLD = 5

-- Frame Movement State
local frameMovementState = {
    configModeActive = false,
    movingFrame = nil,
    originalPositions = {},
    moveableFrames = {},
    boundaryChecking = true,
    snapToGrid = false,
    gridSize = 10,
    initialized = false
}

-- Moveable Frame Registry
local moveableFrameRegistry = {
    -- Core UI Frames
    ["PlayerFrame"] = {
        name = "Player Frame",
        frame = "PlayerFrame",
        defaultParent = "UIParent",
        minBounds = {x = -200, y = -200},
        maxBounds = {x = 200, y = 200},
        snapPoints = {"CENTER", "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"}
    },
    ["TargetFrame"] = {
        name = "Target Frame",
        frame = "TargetFrame",
        defaultParent = "UIParent",
        minBounds = {x = -200, y = -200},
        maxBounds = {x = 200, y = 200},
        snapPoints = {"CENTER", "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"}
    },
    ["Minimap"] = {
        name = "Minimap",
        frame = "Minimap",
        defaultParent = "UIParent",
        minBounds = {x = -400, y = -300},
        maxBounds = {x = 400, y = 300},
        snapPoints = {"TOPRIGHT", "TOPLEFT", "BOTTOMRIGHT", "BOTTOMLEFT"}
    },
    -- Action Bars
    ["MainMenuBar"] = {
        name = "Main Action Bar",
        frame = "MainMenuBar",
        defaultParent = "UIParent",
        minBounds = {x = -300, y = -400},
        maxBounds = {x = 300, y = 100},
        snapPoints = {"BOTTOM", "CENTER"}
    },
    -- Chat Frame
    ["ChatFrame1"] = {
        name = "Chat Frame",
        frame = "ChatFrame1",
        defaultParent = "UIParent",
        minBounds = {x = -500, y = -400},
        maxBounds = {x = 500, y = 400},
        snapPoints = {"BOTTOMLEFT", "BOTTOMRIGHT", "TOPLEFT", "TOPRIGHT"}
    }
}

-- Frame Movement System Functions

function FrameMover:Initialize()
    debug("Initializing FrameMover system")

    if frameMovementState.initialized then
        debug("FrameMover already initialized")
        return true
    end

    -- Initialize moveable frame registry
    self:InitializeMoveableFrames()

    -- Set up event handlers
    self:RegisterEvents()

    -- Load saved positions
    self:LoadSavedPositions()

    frameMovementState.initialized = true
    debug("FrameMover initialized successfully")
    return true
end

function FrameMover:InitializeMoveableFrames()
    debug("Initializing moveable frames registry")

    frameMovementState.moveableFrames = {}

    for frameId, frameInfo in pairs(moveableFrameRegistry) do
        local frame = _G[frameInfo.frame]
        if frame then
            frameMovementState.moveableFrames[frameId] = {
                frame = frame,
                info = frameInfo,
                isMoveable = false,
                originalPoint = nil,
                originalParent = nil,
                originalX = nil,
                originalY = nil
            }
            debug("Registered moveable frame:", frameId)
        else
            debug("Frame not found:", frameInfo.frame)
        end
    end

    debug("Initialized", #frameMovementState.moveableFrames, "moveable frames")
end

function FrameMover:RegisterEvents()
    debug("Registering FrameMover events")

    -- Register for UI events that might affect frame positioning
    if RealUI.RegisterEvent then
        RealUI:RegisterEvent("UI_SCALE_CHANGED", function()
            debug("UI scale changed, validating positions")
            self:ValidateAllPositions()
        end)

        RealUI:RegisterEvent("DISPLAY_SIZE_CHANGED", function()
            debug("Display size changed, validating positions")
            self:ValidateAllPositions()
        end)
    end
end

-- Frame Movement Functions

function FrameMover:MakeFrameMoveable(frameId)
    if not frameMovementState.moveableFrames[frameId] then
        debug("Frame not registered:", frameId)
        return false
    end

    local frameData = frameMovementState.moveableFrames[frameId]
    if frameData.isMoveable then
        debug("Frame already moveable:", frameId)
        return true
    end

    debug("Making frame moveable:", frameId)

    local frame = frameData.frame

    -- Store original position
    local point, parent, relativePoint, x, y = frame:GetPoint()
    frameData.originalPoint = point
    frameData.originalParent = parent
    frameData.originalRelativePoint = relativePoint
    frameData.originalX = x
    frameData.originalY = y

    -- Make frame moveable
    frame:SetMovable(true)
    frame:EnableMouse(true)
    frame:RegisterForDrag("LeftButton")

    -- Set up drag handlers
    frame:SetScript("OnDragStart", function(f)
        self:OnFrameDragStart(f, frameId)
    end)

    frame:SetScript("OnDragStop", function(f)
        self:OnFrameDragStop(f, frameId)
    end)

    frameData.isMoveable = true
    debug("Frame made moveable:", frameId)
    return true
end

function FrameMover:MakeFrameUnmoveable(frameId)
    if not frameMovementState.moveableFrames[frameId] then
        debug("Frame not registered:", frameId)
        return false
    end

    local frameData = frameMovementState.moveableFrames[frameId]
    if not frameData.isMoveable then
        debug("Frame not moveable:", frameId)
        return true
    end

    debug("Making frame unmoveable:", frameId)

    local frame = frameData.frame

    -- Remove drag handlers
    frame:SetScript("OnDragStart", nil)
    frame:SetScript("OnDragStop", nil)

    -- Disable movement
    frame:SetMovable(false)
    frame:EnableMouse(false)
    frame:RegisterForDrag()

    frameData.isMoveable = false
    debug("Frame made unmoveable:", frameId)
    return true
end

function FrameMover:OnFrameDragStart(frame, frameId)
    debug("Frame drag started:", frameId)

    frameMovementState.movingFrame = frameId
    frame:StartMoving()

    -- Show visual feedback if in config mode
    if frameMovementState.configModeActive then
        self:ShowMovementFeedback(frameId)
    end
end

function FrameMover:OnFrameDragStop(frame, frameId)
    debug("Frame drag stopped:", frameId)

    frame:StopMovingOrSizing()
    frameMovementState.movingFrame = nil

    -- Validate new position
    local newX, newY = self:ValidateFramePosition(frameId)
    if newX and newY then
        self:SetFramePosition(frameId, "CENTER", "UIParent", "CENTER", newX, newY)
    end

    -- Save new position
    self:SaveFramePosition(frameId)

    -- Hide visual feedback
    if frameMovementState.configModeActive then
        self:HideMovementFeedback(frameId)
    end

    -- Notify position change
    self:NotifyPositionChange(frameId)
end

-- Position Management Functions

function FrameMover:SetFramePosition(frameId, point, parent, relativePoint, x, y)
    if not frameMovementState.moveableFrames[frameId] then
        debug("Frame not registered:", frameId)
        return false
    end

    local frameData = frameMovementState.moveableFrames[frameId]
    local frame = frameData.frame

    debug("Setting frame position:", frameId, point, parent, relativePoint, x, y)

    -- Validate position
    local validX, validY = self:ValidatePosition(frameId, x, y)

    -- Clear existing points and set new position
    frame:ClearAllPoints()
    frame:SetPoint(point, _G[parent] or parent, relativePoint, validX, validY)

    return true
end

function FrameMover:GetFramePosition(frameId)
    if not frameMovementState.moveableFrames[frameId] then
        debug("Frame not registered:", frameId)
        return nil
    end

    local frame = frameMovementState.moveableFrames[frameId].frame
    local point, parent, relativePoint, x, y = frame:GetPoint()

    return {
        point = point,
        parent = parent and parent:GetName() or "UIParent",
        relativePoint = relativePoint,
        x = x,
        y = y
    }
end

function FrameMover:ResetFramePosition(frameId)
    if not frameMovementState.moveableFrames[frameId] then
        debug("Frame not registered:", frameId)
        return false
    end

    local frameData = frameMovementState.moveableFrames[frameId]

    debug("Resetting frame position:", frameId)

    -- Restore original position if available
    if frameData.originalPoint then
        self:SetFramePosition(
            frameId,
            frameData.originalPoint,
            frameData.originalParent and frameData.originalParent:GetName() or "UIParent",
            frameData.originalRelativePoint,
            frameData.originalX,
            frameData.originalY
        )
    else
        -- Use default position from registry
        local info = frameData.info
        if info.defaultPosition then
            self:SetFramePosition(
                frameId,
                info.defaultPosition.point,
                info.defaultPosition.parent,
                info.defaultPosition.relativePoint,
                info.defaultPosition.x,
                info.defaultPosition.y
            )
        end
    end

    -- Save reset position
    self:SaveFramePosition(frameId)
    return true
end

-- Position Validation and Boundary Checking

function FrameMover:ValidatePosition(frameId, x, y)
    if not frameMovementState.boundaryChecking then
        return x, y
    end

    -- Return nil if position is not provided
    if not x or not y then
        return x, y
    end

    local frameInfo = moveableFrameRegistry[frameId]
    if not frameInfo then
        return x, y
    end

    local validX = x
    local validY = y

    -- Apply boundary constraints
    if frameInfo.minBounds then
        validX = math.max(validX, frameInfo.minBounds.x or validX)
        validY = math.max(validY, frameInfo.minBounds.y or validY)
    end

    if frameInfo.maxBounds then
        validX = math.min(validX, frameInfo.maxBounds.x or validX)
        validY = math.min(validY, frameInfo.maxBounds.y or validY)
    end

    -- Apply screen boundary checking
    local screenWidth, screenHeight = _G.GetPhysicalScreenSize()
    local uiScale = _G.UIParent:GetEffectiveScale()

    local maxX = (screenWidth / uiScale) / 2 - BOUNDARY_PADDING
    local maxY = (screenHeight / uiScale) / 2 - BOUNDARY_PADDING

    validX = math.max(-maxX, math.min(maxX, validX))
    validY = math.max(-maxY, math.min(maxY, validY))

    -- Apply grid snapping if enabled
    if frameMovementState.snapToGrid then
        validX = math.floor(validX / frameMovementState.gridSize + 0.5) * frameMovementState.gridSize
        validY = math.floor(validY / frameMovementState.gridSize + 0.5) * frameMovementState.gridSize
    end

    if validX ~= x or validY ~= y then
        debug("Position adjusted for", frameId, "from", x, y, "to", validX, validY)
    end

    return validX, validY
end

function FrameMover:ValidateFramePosition(frameId)
    local position = self:GetFramePosition(frameId)
    if not position then
        return nil, nil
    end

    return self:ValidatePosition(frameId, position.x, position.y)
end

function FrameMover:ValidateAllPositions()
    debug("Validating all frame positions")

    for frameId, frameData in pairs(frameMovementState.moveableFrames) do
        local validX, validY = self:ValidateFramePosition(frameId)
        if validX and validY then
            local currentPos = self:GetFramePosition(frameId)
            if currentPos and (math.abs(currentPos.x - validX) > 1 or math.abs(currentPos.y - validY) > 1) then
                debug("Adjusting position for", frameId)
                self:SetFramePosition(frameId, currentPos.point, currentPos.parent, currentPos.relativePoint, validX, validY)
            end
        end
    end
end

function FrameMover:IsPositionValid(frameId, x, y)
    local validX, validY = self:ValidatePosition(frameId, x, y)
    return validX == x and validY == y
end

-- Configuration Mode System

function FrameMover:EnableConfigMode()
    debug("Enabling configuration mode")

    if frameMovementState.configModeActive then
        debug("Config mode already active")
        return true
    end

    frameMovementState.configModeActive = true

    -- Make all registered frames moveable
    for frameId, _ in pairs(frameMovementState.moveableFrames) do
        self:MakeFrameMoveable(frameId)
    end

    -- Show visual indicators
    self:ShowConfigModeIndicators()

    -- Notify config mode change
    self:NotifyConfigModeChange(true)

    debug("Configuration mode enabled")
    return true
end

function FrameMover:DisableConfigMode()
    debug("Disabling configuration mode")

    if not frameMovementState.configModeActive then
        debug("Config mode not active")
        return true
    end

    frameMovementState.configModeActive = false

    -- Make all frames unmoveable
    for frameId, _ in pairs(frameMovementState.moveableFrames) do
        self:MakeFrameUnmoveable(frameId)
    end

    -- Hide visual indicators
    self:HideConfigModeIndicators()

    -- Notify config mode change
    self:NotifyConfigModeChange(false)

    debug("Configuration mode disabled")
    return true
end

function FrameMover:ToggleConfigMode()
    if frameMovementState.configModeActive then
        return self:DisableConfigMode()
    else
        return self:EnableConfigMode()
    end
end

function FrameMover:IsConfigModeActive()
    return frameMovementState.configModeActive
end

-- Visual Feedback System

function FrameMover:ShowConfigModeIndicators()
    debug("Showing config mode indicators")

    for frameId, frameData in pairs(frameMovementState.moveableFrames) do
        self:CreateFrameIndicator(frameId)
    end
end

function FrameMover:HideConfigModeIndicators()
    debug("Hiding config mode indicators")

    for frameId, frameData in pairs(frameMovementState.moveableFrames) do
        self:RemoveFrameIndicator(frameId)
    end
end

function FrameMover:CreateFrameIndicator(frameId)
    local frameData = frameMovementState.moveableFrames[frameId]
    if not frameData then
        return
    end

    local frame = frameData.frame
    local indicatorName = "RealUIFrameMoverIndicator_" .. frameId

    -- Remove existing indicator
    if _G[indicatorName] then
        _G[indicatorName]:Hide()
        _G[indicatorName] = nil
    end

    -- Create new indicator
    local indicator = _G.CreateFrame("Frame", indicatorName, frame)
    indicator:SetAllPoints(frame)
    indicator:SetFrameLevel(frame:GetFrameLevel() + 10)

    -- Create border texture
    local border = indicator:CreateTexture(nil, "OVERLAY")
    border:SetAllPoints(indicator)
    border:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    border:SetTexCoord(0, 1, 0, 1)
    border:SetVertexColor(0, 1, 0, 0.8)

    -- Create title text
    local title = indicator:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("TOP", indicator, "TOP", 0, 15)
    title:SetText(frameData.info.name or frameId)
    title:SetTextColor(1, 1, 1, 1)

    indicator:Show()
    frameData.indicator = indicator

    debug("Created indicator for", frameId)
end

function FrameMover:RemoveFrameIndicator(frameId)
    local frameData = frameMovementState.moveableFrames[frameId]
    if frameData and frameData.indicator then
        frameData.indicator:Hide()
        frameData.indicator = nil
        debug("Removed indicator for", frameId)
    end
end

function FrameMover:ShowMovementFeedback(frameId)
    debug("Showing movement feedback for", frameId)

    local frameData = frameMovementState.moveableFrames[frameId]
    if not frameData or not frameData.indicator then
        return
    end

    -- Change indicator color to show movement
    local border = frameData.indicator:GetRegions()
    if border then
        border:SetVertexColor(1, 1, 0, 1.0)  -- Yellow for moving
    end
end

function FrameMover:HideMovementFeedback(frameId)
    debug("Hiding movement feedback for", frameId)

    local frameData = frameMovementState.moveableFrames[frameId]
    if not frameData or not frameData.indicator then
        return
    end

    -- Restore normal indicator color
    local border = frameData.indicator:GetRegions()
    if border then
        border:SetVertexColor(0, 1, 0, 0.8)  -- Green for normal
    end
end

-- Position Persistence

function FrameMover:SaveFramePosition(frameId)
    debug("Saving position for frame:", frameId)

    local position = self:GetFramePosition(frameId)
    if not position then
        debug("Could not get position for", frameId)
        return false
    end

    local db = RealUI.db
    if not db then
        debug("Database not available")
        return false
    end

    if not db.profile.framePositions then
        db.profile.framePositions = {}
    end

    db.profile.framePositions[frameId] = {
        point = position.point,
        parent = position.parent,
        relativePoint = position.relativePoint,
        x = position.x,
        y = position.y
    }

    debug("Position saved for", frameId)
    return true
end

function FrameMover:LoadSavedPositions()
    debug("Loading saved frame positions")

    local db = RealUI.db
    if not db or not db.profile.framePositions then
        debug("No saved positions found")
        return
    end

    for frameId, position in pairs(db.profile.framePositions) do
        if frameMovementState.moveableFrames[frameId] then
            self:SetFramePosition(
                frameId,
                position.point,
                position.parent,
                position.relativePoint,
                position.x,
                position.y
            )
            debug("Loaded position for", frameId)
        end
    end
end

function FrameMover:ResetAllPositions()
    debug("Resetting all frame positions")

    for frameId, _ in pairs(frameMovementState.moveableFrames) do
        self:ResetFramePosition(frameId)
    end

    -- Clear saved positions
    local db = RealUI.db
    if db and db.profile.framePositions then
        db.profile.framePositions = {}
    end

    debug("All positions reset")
end

-- Event Notification System

function FrameMover:NotifyPositionChange(frameId)
    debug("Notifying position change for", frameId)

    local position = self:GetFramePosition(frameId)
    if not position then
        return
    end

    -- Fire custom event
    if RealUI.FireEvent then
        RealUI:FireEvent("REALUI_FRAME_POSITION_CHANGED", frameId, position)
    end

    -- Call registered callbacks
    if self.positionChangeCallbacks then
        for _, callback in ipairs(self.positionChangeCallbacks) do
            if type(callback) == "function" then
                local success, err = pcall(callback, frameId, position)
                if not success then
                    debug("Position change callback failed:", err)
                end
            end
        end
    end
end

function FrameMover:NotifyConfigModeChange(enabled)
    debug("Notifying config mode change:", enabled)

    -- Fire custom event
    if RealUI.FireEvent then
        RealUI:FireEvent("REALUI_CONFIG_MODE_CHANGED", enabled)
    end

    -- Call registered callbacks
    if self.configModeChangeCallbacks then
        for _, callback in ipairs(self.configModeChangeCallbacks) do
            if type(callback) == "function" then
                local success, err = pcall(callback, enabled)
                if not success then
                    debug("Config mode change callback failed:", err)
                end
            end
        end
    end
end

function FrameMover:RegisterPositionChangeCallback(callback)
    if type(callback) ~= "function" then
        debug("Invalid callback type")
        return false
    end

    if not self.positionChangeCallbacks then
        self.positionChangeCallbacks = {}
    end

    table.insert(self.positionChangeCallbacks, callback)
    debug("Position change callback registered")
    return true
end

function FrameMover:RegisterConfigModeChangeCallback(callback)
    if type(callback) ~= "function" then
        debug("Invalid callback type")
        return false
    end

    if not self.configModeChangeCallbacks then
        self.configModeChangeCallbacks = {}
    end

    table.insert(self.configModeChangeCallbacks, callback)
    debug("Config mode change callback registered")
    return true
end

-- Utility and Management Functions

function FrameMover:GetMoveableFrames()
    local frames = {}
    for frameId, frameData in pairs(frameMovementState.moveableFrames) do
        frames[frameId] = {
            name = frameData.info.name,
            isMoveable = frameData.isMoveable,
            position = self:GetFramePosition(frameId)
        }
    end
    return frames
end

function FrameMover:GetFrameMovementState()
    return {
        configModeActive = frameMovementState.configModeActive,
        movingFrame = frameMovementState.movingFrame,
        boundaryChecking = frameMovementState.boundaryChecking,
        snapToGrid = frameMovementState.snapToGrid,
        gridSize = frameMovementState.gridSize,
        initialized = frameMovementState.initialized,
        frameCount = #frameMovementState.moveableFrames
    }
end

function FrameMover:SetBoundaryChecking(enabled)
    debug("Setting boundary checking:", enabled)
    frameMovementState.boundaryChecking = enabled
end

function FrameMover:SetSnapToGrid(enabled, gridSize)
    debug("Setting snap to grid:", enabled, "size:", gridSize)
    frameMovementState.snapToGrid = enabled
    if gridSize then
        frameMovementState.gridSize = gridSize
    end
end

function FrameMover:RegisterMoveableFrame(frameId, frameInfo)
    debug("Registering moveable frame:", frameId)

    if moveableFrameRegistry[frameId] then
        debug("Frame already registered:", frameId)
        return false
    end

    moveableFrameRegistry[frameId] = frameInfo

    -- Initialize if system is already initialized
    if frameMovementState.initialized then
        local frame = _G[frameInfo.frame]
        if frame then
            frameMovementState.moveableFrames[frameId] = {
                frame = frame,
                info = frameInfo,
                isMoveable = false,
                originalPoint = nil,
                originalParent = nil,
                originalX = nil,
                originalY = nil
            }
            debug("Frame registered and initialized:", frameId)
        end
    end

    return true
end

-- Debug and Information Functions

function FrameMover:GetDebugInfo()
    return {
        frameMovementState = frameMovementState,
        moveableFrameRegistry = moveableFrameRegistry,
        registeredFrameCount = #frameMovementState.moveableFrames
    }
end

function FrameMover:PrintStatus()
    local state = self:GetFrameMovementState()

    print("=== RealUI Frame Mover Status ===")
    print("Config Mode Active:", state.configModeActive)
    print("Currently Moving:", state.movingFrame or "None")
    print("Boundary Checking:", state.boundaryChecking)
    print("Snap to Grid:", state.snapToGrid, "Size:", state.gridSize)
    print("Registered Frames:", state.frameCount)
    print("Initialized:", state.initialized)

    print("Moveable Frames:")
    for frameId, frameData in pairs(frameMovementState.moveableFrames) do
        local position = self:GetFramePosition(frameId)
        print("  " .. frameId .. ":", frameData.info.name)
        print("    Moveable:", frameData.isMoveable)
        if position then
            print("    Position:", string.format("%.1f, %.1f", position.x, position.y))
        end
    end
end

-- Register with RealUI namespace
RealUI:RegisterNamespace("FrameMover", FrameMover)
