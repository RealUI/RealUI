local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs table pcall print string _G

-- RealUI HuD Positioning and Sizing System
-- This module handles HuD position calculation, size scaling, and resolution-specific optimization

local RealUI = private.RealUI
local debug = RealUI.GetDebug("HuDPositioning")

local HuDPositioning = {}
RealUI.HuDPositioning = HuDPositioning

-- HuD Positioning Constants
local HUD_SIZES = {
    [1] = { name = "Small", scale = 0.8, description = "Compact HuD for smaller screens" },
    [2] = { name = "Large", scale = 1.0, description = "Standard HuD size" },
    [3] = { name = "Extra Large", scale = 1.2, description = "Larger HuD for high resolution displays" }
}

local RESOLUTION_THRESHOLDS = {
    LOW_RES = 1080,      -- Below this height is considered low resolution
    HIGH_RES = 1440,     -- Above this height is considered high resolution
    ULTRA_HIGH_RES = 2160 -- 4K and above
}

-- HuD positioning state
local hudState = {
    currentSize = 2,
    currentScale = 1.0,
    basePositions = {},
    calculatedPositions = {},
    resolutionOptimized = false,
    screenWidth = 0,
    screenHeight = 0,
    aspectRatio = 0,
    initialized = false
}

-- HuD Position Calculation Functions

function HuDPositioning:Initialize()
    debug("Initializing HuDPositioning system")

    if hudState.initialized then
        debug("HuDPositioning already initialized")
        return true
    end

    -- Get current screen resolution
    self:UpdateScreenResolution()

    -- Load HuD size from database
    self:LoadHuDSize()

    -- Initialize base positions from RealUI defaults
    self:InitializeBasePositions()

    -- Calculate initial positions
    self:CalculatePositions()

    -- Apply resolution-specific optimizations
    self:ApplyResolutionOptimizations()

    -- Register for resolution change events
    self:RegisterEvents()

    hudState.initialized = true
    debug("HuDPositioning initialized successfully")
    return true
end

function HuDPositioning:UpdateScreenResolution()
    local width, height = _G.GetPhysicalScreenSize()

    hudState.screenWidth = width
    hudState.screenHeight = height
    hudState.aspectRatio = width / height

    debug("Screen resolution updated:", width, "x", height, "Aspect ratio:", hudState.aspectRatio)

    -- Trigger position recalculation if initialized
    if hudState.initialized then
        self:CalculatePositions()
        self:ApplyResolutionOptimizations()
    end
end

function HuDPositioning:InitializeBasePositions()
    debug("Initializing base positions from RealUI defaults")

    if not RealUI.defaultPositions then
        debug("RealUI.defaultPositions not available")
        return false
    end

    -- Deep copy default positions to avoid modifying originals
    hudState.basePositions = {}
    for layoutId, positions in pairs(RealUI.defaultPositions) do
        hudState.basePositions[layoutId] = {}
        for key, value in pairs(positions) do
            hudState.basePositions[layoutId][key] = value
        end
    end

    debug("Base positions initialized for", #hudState.basePositions, "layouts")
    return true
end

function HuDPositioning:LoadHuDSize()
    debug("Loading HuD size from database")

    local db = RealUI.db
    if db and db.profile and db.profile.settings then
        local savedSize = db.profile.settings.hudSize
        if savedSize and HUD_SIZES[savedSize] then
            hudState.currentSize = savedSize
            hudState.currentScale = HUD_SIZES[savedSize].scale
            debug("Loaded HuD size:", savedSize, "Scale:", hudState.currentScale)
        else
            debug("Invalid or missing HuD size, using default")
            hudState.currentSize = 2
            hudState.currentScale = 1.0
        end
    else
        debug("Database not available, using default HuD size")
        hudState.currentSize = 2
        hudState.currentScale = 1.0
    end
end

function HuDPositioning:SaveHuDSize()
    debug("Saving HuD size to database")

    local db = RealUI.db
    if db and db.profile and db.profile.settings then
        db.profile.settings.hudSize = hudState.currentSize
        debug("HuD size saved:", hudState.currentSize)
        return true
    end

    debug("Database not available for saving")
    return false
end

-- HuD Size Management

function HuDPositioning:SetHuDSize(sizeId)
    if not HUD_SIZES[sizeId] then
        debug("Invalid HuD size ID:", sizeId)
        return false
    end

    debug("Setting HuD size to:", sizeId, HUD_SIZES[sizeId].name)

    hudState.currentSize = sizeId
    hudState.currentScale = HUD_SIZES[sizeId].scale

    -- Recalculate positions with new size
    self:CalculatePositions()

    -- Save to database
    self:SaveHuDSize()

    -- Notify other systems of the change
    self:NotifyHuDSizeChange(sizeId)

    return true
end

function HuDPositioning:GetHuDSize()
    return hudState.currentSize
end

function HuDPositioning:GetHuDScale()
    return hudState.currentScale
end

function HuDPositioning:GetHuDSizeInfo(sizeId)
    sizeId = sizeId or hudState.currentSize
    return HUD_SIZES[sizeId]
end

function HuDPositioning:GetAvailableHuDSizes()
    local sizes = {}
    for id, info in pairs(HUD_SIZES) do
        sizes[id] = {
            id = id,
            name = info.name,
            scale = info.scale,
            description = info.description
        }
    end
    return sizes
end

-- Position Calculation System

function HuDPositioning:CalculatePositions()
    debug("Calculating HuD positions for size:", hudState.currentSize, "scale:", hudState.currentScale)

    if not hudState.basePositions then
        debug("Base positions not initialized")
        return false
    end

    hudState.calculatedPositions = {}

    -- Calculate positions for each layout
    for layoutId, basePositions in pairs(hudState.basePositions) do
        hudState.calculatedPositions[layoutId] = {}

        for positionKey, baseValue in pairs(basePositions) do
            local calculatedValue = self:CalculatePositionValue(positionKey, baseValue, layoutId)
            hudState.calculatedPositions[layoutId][positionKey] = calculatedValue
        end

        debug("Calculated positions for layout", layoutId, "with", #hudState.calculatedPositions[layoutId], "elements")
    end

    -- Update RealUI position data
    self:UpdateRealUIPositions()

    return true
end

function HuDPositioning:CalculatePositionValue(positionKey, baseValue, layoutId)
    local calculatedValue = baseValue

    -- Apply size-based scaling for specific position types
    if self:IsScalablePosition(positionKey) then
        calculatedValue = baseValue * hudState.currentScale
    end

    -- Apply HuD size offsets if available
    if RealUI.hudSizeOffsets and RealUI.hudSizeOffsets[hudState.currentSize] then
        local offset = RealUI.hudSizeOffsets[hudState.currentSize][positionKey]
        if offset then
            calculatedValue = calculatedValue + offset
            debug("Applied offset", offset, "to", positionKey, "Result:", calculatedValue)
        end
    end

    -- Apply resolution-specific adjustments
    calculatedValue = self:ApplyResolutionAdjustment(positionKey, calculatedValue, layoutId)

    return calculatedValue
end

function HuDPositioning:IsScalablePosition(positionKey)
    -- Define which position types should be scaled with HuD size
    local scalablePositions = {
        ["UFHorizontal"] = true,
        ["SpellAlertWidth"] = true,
        ["ActionBarsY"] = true,
        ["ActionBarsBotY"] = true,
        ["CastBarPlayerY"] = true,
        ["CastBarTargetY"] = true
    }

    return scalablePositions[positionKey] == true
end

function HuDPositioning:ApplyResolutionAdjustment(positionKey, value, layoutId)
    local adjustedValue = value

    -- Apply aspect ratio corrections
    if hudState.aspectRatio > 0 then
        if positionKey:find("X") and hudState.aspectRatio > 1.8 then
            -- Ultra-wide screen adjustments
            adjustedValue = adjustedValue * 1.1
        elseif positionKey:find("Y") and hudState.aspectRatio < 1.5 then
            -- Tall screen adjustments
            adjustedValue = adjustedValue * 0.9
        end
    end

    -- Apply resolution-based scaling
    if hudState.screenHeight > 0 then
        local resolutionScale = self:GetResolutionScale()
        if resolutionScale ~= 1.0 and self:IsResolutionScalablePosition(positionKey) then
            adjustedValue = adjustedValue * resolutionScale
        end
    end

    return adjustedValue
end

function HuDPositioning:IsResolutionScalablePosition(positionKey)
    -- Define which positions should be adjusted for resolution
    local resolutionScalablePositions = {
        ["HuDY"] = true,
        ["ActionBarsY"] = true,
        ["ActionBarsBotY"] = true,
        ["BossY"] = true
    }

    return resolutionScalablePositions[positionKey] == true
end

function HuDPositioning:GetResolutionScale()
    if hudState.screenHeight <= RESOLUTION_THRESHOLDS.LOW_RES then
        return 0.85  -- Scale down for low resolution
    elseif hudState.screenHeight >= RESOLUTION_THRESHOLDS.HIGH_RES then
        return 1.15  -- Scale up for high resolution
    else
        return 1.0   -- Standard scaling
    end
end

function HuDPositioning:UpdateRealUIPositions()
    debug("Updating RealUI position data with calculated positions")

    if not RealUI.defaultPositions then
        debug("RealUI.defaultPositions not available")
        return false
    end

    -- Update RealUI's position data with calculated values
    for layoutId, positions in pairs(hudState.calculatedPositions) do
        if not RealUI.defaultPositions[layoutId] then
            RealUI.defaultPositions[layoutId] = {}
        end

        for positionKey, value in pairs(positions) do
            RealUI.defaultPositions[layoutId][positionKey] = value
        end
    end

    -- Update database positions if available
    local db = RealUI.db
    if db and db.profile and db.profile.positions then
        for layoutId, positions in pairs(hudState.calculatedPositions) do
            if not db.profile.positions[layoutId] then
                db.profile.positions[layoutId] = {}
            end

            for positionKey, value in pairs(positions) do
                db.profile.positions[layoutId][positionKey] = value
            end
        end
    end

    debug("RealUI positions updated successfully")
    return true
end

-- Resolution-Specific Optimization

function HuDPositioning:ApplyResolutionOptimizations()
    debug("Applying resolution-specific optimizations")

    local optimizationsApplied = false

    -- Low resolution optimizations
    if self:IsLowResolution() and not hudState.resolutionOptimized then
        optimizationsApplied = self:ApplyLowResolutionOptimizations()
    end

    -- High resolution optimizations
    if self:IsHighResolution() then
        optimizationsApplied = self:ApplyHighResolutionOptimizations() or optimizationsApplied
    end

    -- Ultra-wide screen optimizations
    if self:IsUltraWideScreen() then
        optimizationsApplied = self:ApplyUltraWideOptimizations() or optimizationsApplied
    end

    if optimizationsApplied then
        hudState.resolutionOptimized = true
        self:UpdateRealUIPositions()
        debug("Resolution optimizations applied")
    else
        debug("No resolution optimizations needed")
    end

    return optimizationsApplied
end

function HuDPositioning:ApplyLowResolutionOptimizations()
    debug("Applying low resolution optimizations")

    local optimized = false

    -- Move HuD up to provide more space
    for layoutId, positions in pairs(hudState.calculatedPositions) do
        if positions["HuDY"] and positions["HuDY"] <= -30 then
            positions["HuDY"] = -5
            optimized = true
            debug("Adjusted HuDY for low resolution in layout", layoutId)
        end
    end

    -- Reduce HuD size if not already small
    if hudState.currentSize > 1 then
        self:SetHuDSize(1)
        optimized = true
        debug("Reduced HuD size for low resolution")
    end

    -- Adjust action bar positioning
    for layoutId, positions in pairs(hudState.calculatedPositions) do
        if positions["ActionBarsY"] then
            positions["ActionBarsY"] = positions["ActionBarsY"] + 20
            optimized = true
            debug("Adjusted ActionBarsY for low resolution in layout", layoutId)
        end
    end

    return optimized
end

function HuDPositioning:ApplyHighResolutionOptimizations()
    debug("Applying high resolution optimizations")

    local optimized = false

    -- Increase HuD size for better visibility on high resolution displays
    if hudState.currentSize < 3 and hudState.screenHeight >= RESOLUTION_THRESHOLDS.ULTRA_HIGH_RES then
        self:SetHuDSize(3)
        optimized = true
        debug("Increased HuD size for ultra-high resolution")
    elseif hudState.currentSize < 2 and hudState.screenHeight >= RESOLUTION_THRESHOLDS.HIGH_RES then
        self:SetHuDSize(2)
        optimized = true
        debug("Increased HuD size for high resolution")
    end

    -- Adjust spacing for better proportions
    for layoutId, positions in pairs(hudState.calculatedPositions) do
        if positions["UFHorizontal"] then
            positions["UFHorizontal"] = positions["UFHorizontal"] * 1.1
            optimized = true
        end
        if positions["SpellAlertWidth"] then
            positions["SpellAlertWidth"] = positions["SpellAlertWidth"] * 1.1
            optimized = true
        end
    end

    return optimized
end

function HuDPositioning:ApplyUltraWideOptimizations()
    debug("Applying ultra-wide screen optimizations")

    local optimized = false

    -- Adjust horizontal positioning for ultra-wide screens
    if hudState.aspectRatio > 2.0 then
        for layoutId, positions in pairs(hudState.calculatedPositions) do
            if positions["BossX"] then
                positions["BossX"] = positions["BossX"] * 1.2
                optimized = true
            end
        end
        debug("Applied ultra-wide optimizations")
    end

    return optimized
end

-- Resolution Detection Functions

function HuDPositioning:IsLowResolution()
    return hudState.screenHeight > 0 and hudState.screenHeight < RESOLUTION_THRESHOLDS.LOW_RES
end

function HuDPositioning:IsHighResolution()
    return hudState.screenHeight >= RESOLUTION_THRESHOLDS.HIGH_RES
end

function HuDPositioning:IsUltraHighResolution()
    return hudState.screenHeight >= RESOLUTION_THRESHOLDS.ULTRA_HIGH_RES
end

function HuDPositioning:IsUltraWideScreen()
    return hudState.aspectRatio > 2.0
end

function HuDPositioning:GetResolutionCategory()
    if self:IsUltraHighResolution() then
        return "ultra_high"
    elseif self:IsHighResolution() then
        return "high"
    elseif self:IsLowResolution() then
        return "low"
    else
        return "standard"
    end
end

-- Position Access Functions

function HuDPositioning:GetPosition(layoutId, positionKey)
    if not hudState.calculatedPositions[layoutId] then
        debug("Layout not found:", layoutId)
        return nil
    end

    return hudState.calculatedPositions[layoutId][positionKey]
end

function HuDPositioning:GetAllPositions(layoutId)
    return hudState.calculatedPositions[layoutId]
end

function HuDPositioning:SetPosition(layoutId, positionKey, value)
    if not hudState.calculatedPositions[layoutId] then
        debug("Layout not found:", layoutId)
        return false
    end

    debug("Setting position", positionKey, "to", value, "for layout", layoutId)

    hudState.calculatedPositions[layoutId][positionKey] = value
    self:UpdateRealUIPositions()

    -- Notify position change
    self:NotifyPositionChange(layoutId, positionKey, value)

    return true
end

function HuDPositioning:ResetPositions(layoutId)
    debug("Resetting positions for layout:", layoutId)

    if not hudState.basePositions[layoutId] then
        debug("Base positions not found for layout:", layoutId)
        return false
    end

    -- Reset to base positions and recalculate
    hudState.calculatedPositions[layoutId] = {}
    for positionKey, baseValue in pairs(hudState.basePositions[layoutId]) do
        local calculatedValue = self:CalculatePositionValue(positionKey, baseValue, layoutId)
        hudState.calculatedPositions[layoutId][positionKey] = calculatedValue
    end

    self:UpdateRealUIPositions()
    debug("Positions reset for layout", layoutId)
    return true
end

-- Event System

function HuDPositioning:RegisterEvents()
    debug("Registering HuDPositioning events")

    -- Register for UI scale changes
    if RealUI.RegisterEvent then
        RealUI:RegisterEvent("UI_SCALE_CHANGED", function()
            debug("UI scale changed, updating positions")
            self:UpdateScreenResolution()
        end)

        -- Register for display size changes
        RealUI:RegisterEvent("DISPLAY_SIZE_CHANGED", function()
            debug("Display size changed, updating positions")
            self:UpdateScreenResolution()
        end)
    end
end

function HuDPositioning:NotifyHuDSizeChange(newSize)
    debug("Notifying HuD size change:", newSize)

    -- Fire custom event for other modules
    if RealUI.FireEvent then
        RealUI:FireEvent("REALUI_HUD_SIZE_CHANGED", newSize, hudState.currentScale)
    end

    -- Update any registered callbacks
    if self.hudSizeChangeCallbacks then
        for _, callback in ipairs(self.hudSizeChangeCallbacks) do
            if type(callback) == "function" then
                local success, err = pcall(callback, newSize, hudState.currentScale)
                if not success then
                    debug("HuD size change callback failed:", err)
                end
            end
        end
    end
end

function HuDPositioning:NotifyPositionChange(layoutId, positionKey, value)
    debug("Notifying position change:", layoutId, positionKey, value)

    -- Fire custom event for other modules
    if RealUI.FireEvent then
        RealUI:FireEvent("REALUI_POSITION_CHANGED", layoutId, positionKey, value)
    end
end

function HuDPositioning:RegisterHuDSizeChangeCallback(callback)
    if type(callback) ~= "function" then
        debug("Invalid callback type")
        return false
    end

    if not self.hudSizeChangeCallbacks then
        self.hudSizeChangeCallbacks = {}
    end

    table.insert(self.hudSizeChangeCallbacks, callback)
    debug("HuD size change callback registered")
    return true
end

-- Utility and Debug Functions

function HuDPositioning:GetHuDState()
    return {
        currentSize = hudState.currentSize,
        currentScale = hudState.currentScale,
        screenWidth = hudState.screenWidth,
        screenHeight = hudState.screenHeight,
        aspectRatio = hudState.aspectRatio,
        resolutionOptimized = hudState.resolutionOptimized,
        resolutionCategory = self:GetResolutionCategory(),
        initialized = hudState.initialized
    }
end

function HuDPositioning:GetDebugInfo()
    return {
        hudState = hudState,
        hudSizes = HUD_SIZES,
        resolutionThresholds = RESOLUTION_THRESHOLDS,
        basePositions = hudState.basePositions,
        calculatedPositions = hudState.calculatedPositions
    }
end

function HuDPositioning:PrintStatus()
    local state = self:GetHuDState()

    print("=== RealUI HuD Positioning Status ===")
    print("Current Size:", state.currentSize, "-", HUD_SIZES[state.currentSize].name)
    print("Current Scale:", state.currentScale)
    print("Screen Resolution:", state.screenWidth, "x", state.screenHeight)
    print("Aspect Ratio:", string.format("%.2f", state.aspectRatio))
    print("Resolution Category:", state.resolutionCategory)
    print("Resolution Optimized:", state.resolutionOptimized)
    print("Initialized:", state.initialized)

    -- Print current positions for active layout
    if RealUI.cLayout and hudState.calculatedPositions[RealUI.cLayout] then
        print("Current Layout Positions:")
        for key, value in pairs(hudState.calculatedPositions[RealUI.cLayout]) do
            print("  " .. key .. ":", value)
        end
    end
end

-- Register with RealUI namespace
RealUI:RegisterNamespace("HuDPositioning", HuDPositioning)
