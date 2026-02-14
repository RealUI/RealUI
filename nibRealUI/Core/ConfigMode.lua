local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs table pcall print string _G math

-- RealUI Configuration Mode System
-- This module provides visual positioning feedback and configuration interface
-- Works in conjunction with FrameMover to provide comprehensive UI customization

local RealUI = private.RealUI
local debug = RealUI.GetDebug("ConfigMode")

local ConfigMode = {}
RealUI.ConfigMode = ConfigMode

-- Configuration Mode Constants
local CONFIG_OVERLAY_ALPHA = 0.3
local GRID_LINE_ALPHA = 0.2
local SNAP_INDICATOR_SIZE = 8
local POSITION_TEXT_UPDATE_INTERVAL = 0.1

-- Configuration Mode State
local configModeState = {
    active = false,
    overlayFrame = nil,
    gridFrame = nil,
    positionDisplay = nil,
    snapIndicators = {},
    frameHighlights = {},
    updateTimer = nil,
    showGrid = true,
    showSnapPoints = true,
    showPositionText = true,
    initialized = false
}

-- Configuration Mode Functions

function ConfigMode:Initialize()
    debug("Initializing ConfigMode system")

    if configModeState.initialized then
        debug("ConfigMode already initialized")
        return true
    end

    -- Create overlay frame
    self:CreateOverlayFrame()

    -- Create grid system
    self:CreateGridSystem()

    -- Create position display
    self:CreatePositionDisplay()

    -- Register for FrameMover events
    self:RegisterFrameMoverEvents()

    configModeState.initialized = true
    debug("ConfigMode initialized successfully")
    return true
end

function ConfigMode:CreateOverlayFrame()
    debug("Creating configuration overlay frame")

    local overlay = _G.CreateFrame("Frame", "RealUIConfigModeOverlay", _G.UIParent)
    overlay:SetAllPoints(_G.UIParent)
    overlay:SetFrameLevel(1000)
    overlay:Hide()

    -- Create background
    local bg = overlay:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(overlay)
    bg:SetTexture(0, 0, 0, CONFIG_OVERLAY_ALPHA)

    -- Create title text
    local title = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormalLarge")
    title:SetPoint("TOP", overlay, "TOP", 0, -20)
    title:SetText("RealUI Configuration Mode")
    title:SetTextColor(1, 1, 1, 1)

    -- Create instruction text
    local instructions = overlay:CreateFontString(nil, "OVERLAY", "GameFontNormal")
    instructions:SetPoint("TOP", title, "BOTTOM", 0, -10)
    instructions:SetText("Drag frames to reposition them. Press ESC or type /realui config to exit.")
    instructions:SetTextColor(0.8, 0.8, 0.8, 1)

    configModeState.overlayFrame = overlay
    debug("Configuration overlay created")
end

function ConfigMode:CreateGridSystem()
    debug("Creating grid system")

    local gridFrame = _G.CreateFrame("Frame", "RealUIConfigModeGrid", configModeState.overlayFrame)
    gridFrame:SetAllPoints(configModeState.overlayFrame)
    gridFrame:SetFrameLevel(configModeState.overlayFrame:GetFrameLevel() + 1)

    configModeState.gridFrame = gridFrame
    self:UpdateGridDisplay()
    debug("Grid system created")
end

function ConfigMode:UpdateGridDisplay()
    if not configModeState.gridFrame then
        return
    end

    debug("Updating grid display")

    -- Clear existing grid lines
    for _, line in ipairs(configModeState.gridFrame.gridLines or {}) do
        line:Hide()
    end
    configModeState.gridFrame.gridLines = {}

    if not configModeState.showGrid then
        return
    end

    local gridSize = 20  -- Grid spacing in pixels
    local screenWidth = _G.UIParent:GetWidth()
    local screenHeight = _G.UIParent:GetHeight()

    -- Create vertical grid lines
    for x = 0, screenWidth, gridSize do
        local line = configModeState.gridFrame:CreateTexture(nil, "ARTWORK")
        line:SetTexture(1, 1, 1, GRID_LINE_ALPHA)
        line:SetSize(1, screenHeight)
        line:SetPoint("TOPLEFT", configModeState.gridFrame, "TOPLEFT", x, 0)
        table.insert(configModeState.gridFrame.gridLines, line)
    end

    -- Create horizontal grid lines
    for y = 0, screenHeight, gridSize do
        local line = configModeState.gridFrame:CreateTexture(nil, "ARTWORK")
        line:SetTexture(1, 1, 1, GRID_LINE_ALPHA)
        line:SetSize(screenWidth, 1)
        line:SetPoint("TOPLEFT", configModeState.gridFrame, "TOPLEFT", 0, -y)
        table.insert(configModeState.gridFrame.gridLines, line)
    end

    debug("Grid display updated with", #configModeState.gridFrame.gridLines, "lines")
end

function ConfigMode:CreatePositionDisplay()
    debug("Creating position display")

    local posDisplay = _G.CreateFrame("Frame", "RealUIConfigModePositionDisplay", configModeState.overlayFrame)
    posDisplay:SetSize(200, 60)
    posDisplay:SetPoint("BOTTOMRIGHT", configModeState.overlayFrame, "BOTTOMRIGHT", -20, 20)
    posDisplay:SetFrameLevel(configModeState.overlayFrame:GetFrameLevel() + 5)

    -- Create background
    local bg = posDisplay:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints(posDisplay)
    bg:SetTexture(0, 0, 0, 0.8)

    -- Create border
    local border = posDisplay:CreateTexture(nil, "BORDER")
    border:SetAllPoints(posDisplay)
    border:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    border:SetTexCoord(0, 1, 0, 1)
    border:SetVertexColor(1, 1, 1, 0.5)

    -- Create frame name text
    local frameNameText = posDisplay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    frameNameText:SetPoint("TOPLEFT", posDisplay, "TOPLEFT", 5, -5)
    frameNameText:SetText("No frame selected")
    frameNameText:SetTextColor(1, 1, 1, 1)
    posDisplay.frameNameText = frameNameText

    -- Create position text
    local positionText = posDisplay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    positionText:SetPoint("TOPLEFT", frameNameText, "BOTTOMLEFT", 0, -2)
    positionText:SetText("Position: 0, 0")
    positionText:SetTextColor(0.8, 0.8, 0.8, 1)
    posDisplay.positionText = positionText

    -- Create anchor text
    local anchorText = posDisplay:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    anchorText:SetPoint("TOPLEFT", positionText, "BOTTOMLEFT", 0, -2)
    anchorText:SetText("Anchor: CENTER")
    anchorText:SetTextColor(0.8, 0.8, 0.8, 1)
    posDisplay.anchorText = anchorText

    configModeState.positionDisplay = posDisplay
    debug("Position display created")
end

-- Configuration Mode Control

function ConfigMode:EnableConfigMode()
    debug("Enabling configuration mode")

    if configModeState.active then
        debug("Config mode already active")
        return true
    end

    -- Initialize if needed
    if not configModeState.initialized then
        self:Initialize()
    end

    configModeState.active = true

    -- Show overlay
    if configModeState.overlayFrame then
        configModeState.overlayFrame:Show()
    end

    -- Enable FrameMover config mode
    if RealUI.FrameMover then
        RealUI.FrameMover:EnableConfigMode()
    end

    -- Create frame highlights
    self:CreateFrameHighlights()

    -- Start position update timer
    self:StartPositionUpdateTimer()

    -- Register escape key handler
    self:RegisterEscapeHandler()

    debug("Configuration mode enabled")
    return true
end

function ConfigMode:DisableConfigMode()
    debug("Disabling configuration mode")

    if not configModeState.active then
        debug("Config mode not active")
        return true
    end

    configModeState.active = false

    -- Hide overlay
    if configModeState.overlayFrame then
        configModeState.overlayFrame:Hide()
    end

    -- Disable FrameMover config mode
    if RealUI.FrameMover then
        RealUI.FrameMover:DisableConfigMode()
    end

    -- Remove frame highlights
    self:RemoveFrameHighlights()

    -- Stop position update timer
    self:StopPositionUpdateTimer()

    -- Unregister escape key handler
    self:UnregisterEscapeHandler()

    debug("Configuration mode disabled")
    return true
end

function ConfigMode:ToggleConfigMode()
    if configModeState.active then
        return self:DisableConfigMode()
    else
        return self:EnableConfigMode()
    end
end

function ConfigMode:IsConfigModeActive()
    return configModeState.active
end

-- Frame Highlighting System

function ConfigMode:CreateFrameHighlights()
    debug("Creating frame highlights")

    if not RealUI.FrameMover then
        debug("FrameMover not available")
        return
    end

    local moveableFrames = RealUI.FrameMover:GetMoveableFrames()

    for frameId, frameInfo in pairs(moveableFrames) do
        self:CreateFrameHighlight(frameId)
    end

    debug("Created highlights for", #configModeState.frameHighlights, "frames")
end

function ConfigMode:CreateFrameHighlight(frameId)
    if not RealUI.FrameMover or not RealUI.FrameMover.frameMovementState then
        return
    end

    local frameData = RealUI.FrameMover.frameMovementState.moveableFrames[frameId]
    if not frameData then
        return
    end

    local frame = frameData.frame
    local highlightName = "RealUIConfigModeHighlight_" .. frameId

    -- Remove existing highlight
    if _G[highlightName] then
        _G[highlightName]:Hide()
        _G[highlightName] = nil
    end

    -- Create highlight frame
    local highlight = _G.CreateFrame("Frame", highlightName, frame)
    highlight:SetAllPoints(frame)
    highlight:SetFrameLevel(frame:GetFrameLevel() + 20)

    -- Create highlight border
    local border = highlight:CreateTexture(nil, "OVERLAY")
    border:SetAllPoints(highlight)
    border:SetTexture("Interface\\Tooltips\\UI-Tooltip-Border")
    border:SetTexCoord(0, 1, 0, 1)
    border:SetVertexColor(0, 0.8, 1, 0.8)  -- Blue highlight

    -- Create corner indicators
    self:CreateCornerIndicators(highlight)

    -- Create frame label
    local label = highlight:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    label:SetPoint("BOTTOM", highlight, "TOP", 0, 2)
    label:SetText(frameData.info.name or frameId)
    label:SetTextColor(1, 1, 1, 1)

    highlight:Show()
    configModeState.frameHighlights[frameId] = highlight

    debug("Created highlight for", frameId)
end

function ConfigMode:CreateCornerIndicators(parent)
    local corners = {"TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT"}

    for _, corner in ipairs(corners) do
        local indicator = parent:CreateTexture(nil, "OVERLAY")
        indicator:SetSize(SNAP_INDICATOR_SIZE, SNAP_INDICATOR_SIZE)
        indicator:SetPoint(corner, parent, corner, 0, 0)
        indicator:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
        indicator:SetVertexColor(1, 1, 0, 0.8)  -- Yellow corners
    end
end

function ConfigMode:RemoveFrameHighlights()
    debug("Removing frame highlights")

    for frameId, highlight in pairs(configModeState.frameHighlights) do
        if highlight then
            highlight:Hide()
        end
    end

    configModeState.frameHighlights = {}
    debug("Frame highlights removed")
end

-- Position Update System

function ConfigMode:StartPositionUpdateTimer()
    debug("Starting position update timer")

    if configModeState.updateTimer then
        self:StopPositionUpdateTimer()
    end

    configModeState.updateTimer = _G.C_Timer.NewTicker(POSITION_TEXT_UPDATE_INTERVAL, function()
        self:UpdatePositionDisplay()
    end)
end

function ConfigMode:StopPositionUpdateTimer()
    debug("Stopping position update timer")

    if configModeState.updateTimer then
        configModeState.updateTimer:Cancel()
        configModeState.updateTimer = nil
    end
end

function ConfigMode:UpdatePositionDisplay()
    if not configModeState.positionDisplay or not configModeState.showPositionText then
        return
    end

    local movingFrame = nil
    if RealUI.FrameMover and RealUI.FrameMover.frameMovementState then
        movingFrame = RealUI.FrameMover.frameMovementState.movingFrame
    end

    if movingFrame then
        local position = RealUI.FrameMover:GetFramePosition(movingFrame)
        if position then
            local frameInfo = RealUI.FrameMover.frameMovementState.moveableFrames[movingFrame]
            local frameName = frameInfo and frameInfo.info.name or movingFrame

            configModeState.positionDisplay.frameNameText:SetText(frameName)
            configModeState.positionDisplay.positionText:SetText(
                string.format("Position: %.1f, %.1f", position.x, position.y)
            )
            configModeState.positionDisplay.anchorText:SetText(
                string.format("Anchor: %s", position.point or "CENTER")
            )
        end
    else
        configModeState.positionDisplay.frameNameText:SetText("No frame selected")
        configModeState.positionDisplay.positionText:SetText("Position: --")
        configModeState.positionDisplay.anchorText:SetText("Anchor: --")
    end
end

-- Event Handling

function ConfigMode:RegisterFrameMoverEvents()
    debug("Registering FrameMover events")

    if RealUI.FrameMover then
        RealUI.FrameMover:RegisterConfigModeChangeCallback(function(enabled)
            if enabled and not configModeState.active then
                self:EnableConfigMode()
            elseif not enabled and configModeState.active then
                self:DisableConfigMode()
            end
        end)
    end
end

function ConfigMode:RegisterEscapeHandler()
    debug("Registering escape key handler")

    -- Create invisible frame to capture escape key
    if not configModeState.escapeFrame then
        local escapeFrame = _G.CreateFrame("Frame", "RealUIConfigModeEscapeHandler", _G.UIParent)
        escapeFrame:SetScript("OnKeyDown", function(self, key)
            if key == "ESCAPE" then
                ConfigMode:DisableConfigMode()
            end
        end)
        escapeFrame:EnableKeyboard(true)
        configModeState.escapeFrame = escapeFrame
    end

    configModeState.escapeFrame:Show()
    configModeState.escapeFrame:SetPropagateKeyboardInput(false)
end

function ConfigMode:UnregisterEscapeHandler()
    debug("Unregistering escape key handler")

    if configModeState.escapeFrame then
        configModeState.escapeFrame:Hide()
        configModeState.escapeFrame:SetPropagateKeyboardInput(true)
    end
end

-- Configuration Options

function ConfigMode:SetShowGrid(show)
    debug("Setting show grid:", show)
    configModeState.showGrid = show
    self:UpdateGridDisplay()
end

function ConfigMode:SetShowSnapPoints(show)
    debug("Setting show snap points:", show)
    configModeState.showSnapPoints = show
    -- Update snap point visibility if needed
end

function ConfigMode:SetShowPositionText(show)
    debug("Setting show position text:", show)
    configModeState.showPositionText = show

    if configModeState.positionDisplay then
        if show then
            configModeState.positionDisplay:Show()
        else
            configModeState.positionDisplay:Hide()
        end
    end
end

function ConfigMode:GetConfigModeSettings()
    return {
        showGrid = configModeState.showGrid,
        showSnapPoints = configModeState.showSnapPoints,
        showPositionText = configModeState.showPositionText
    }
end

-- Snap Point System

function ConfigMode:CreateSnapIndicators()
    debug("Creating snap indicators")

    -- Clear existing indicators
    for _, indicator in pairs(configModeState.snapIndicators) do
        indicator:Hide()
    end
    configModeState.snapIndicators = {}

    if not configModeState.showSnapPoints then
        return
    end

    -- Create snap points at common positions
    local snapPoints = {
        {point = "CENTER", x = 0, y = 0, color = {1, 0, 0}},
        {point = "TOP", x = 0, y = -50, color = {0, 1, 0}},
        {point = "BOTTOM", x = 0, y = 50, color = {0, 1, 0}},
        {point = "LEFT", x = 50, y = 0, color = {0, 0, 1}},
        {point = "RIGHT", x = -50, y = 0, color = {0, 0, 1}},
    }

    for i, snapPoint in ipairs(snapPoints) do
        local indicator = configModeState.overlayFrame:CreateTexture(nil, "OVERLAY")
        indicator:SetSize(SNAP_INDICATOR_SIZE, SNAP_INDICATOR_SIZE)
        indicator:SetPoint(snapPoint.point, configModeState.overlayFrame, snapPoint.point, snapPoint.x, snapPoint.y)
        indicator:SetTexture("Interface\\Minimap\\UI-Minimap-ZoomButton-Highlight")
        indicator:SetVertexColor(snapPoint.color[1], snapPoint.color[2], snapPoint.color[3], 0.8)

        configModeState.snapIndicators[i] = indicator
    end

    debug("Created", #configModeState.snapIndicators, "snap indicators")
end

-- Utility Functions

function ConfigMode:GetConfigModeState()
    return {
        active = configModeState.active,
        showGrid = configModeState.showGrid,
        showSnapPoints = configModeState.showSnapPoints,
        showPositionText = configModeState.showPositionText,
        initialized = configModeState.initialized,
        highlightCount = #configModeState.frameHighlights
    }
end

function ConfigMode:GetDebugInfo()
    return {
        configModeState = configModeState,
        overlayFrame = configModeState.overlayFrame and configModeState.overlayFrame:GetName(),
        gridFrame = configModeState.gridFrame and configModeState.gridFrame:GetName(),
        positionDisplay = configModeState.positionDisplay and configModeState.positionDisplay:GetName()
    }
end

function ConfigMode:PrintStatus()
    local state = self:GetConfigModeState()

    print("=== RealUI Config Mode Status ===")
    print("Active:", state.active)
    print("Show Grid:", state.showGrid)
    print("Show Snap Points:", state.showSnapPoints)
    print("Show Position Text:", state.showPositionText)
    print("Frame Highlights:", state.highlightCount)
    print("Initialized:", state.initialized)
end

-- Register with RealUI namespace
RealUI:RegisterNamespace("ConfigMode", ConfigMode)
