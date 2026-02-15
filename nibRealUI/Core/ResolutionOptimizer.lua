local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("ResolutionOptimizer")

-- Resolution and Display Optimization System
-- Handles automatic layout adjustments for different screen sizes
-- Provides low-resolution and high-resolution display enhancements

local ResolutionOptimizer = RealUI:NewModule("ResolutionOptimizer", "AceEvent-3.0", "AceTimer-3.0")

-- Resolution thresholds
local RESOLUTION_THRESHOLDS = {
    LOW_RES_HEIGHT = 1080,      -- Below this is considered low resolution
    HIGH_RES_HEIGHT = 1440,     -- At or above this is considered high resolution
    ULTRA_HIGH_RES_HEIGHT = 2160, -- 4K and above
    LOW_RES_WIDTH = 1920,
    HIGH_RES_WIDTH = 2560,
    ULTRA_HIGH_RES_WIDTH = 3840
}

-- Resolution categories
local RESOLUTION_CATEGORY = {
    LOW = "low",
    STANDARD = "standard",
    HIGH = "high",
    ULTRA_HIGH = "ultra_high"
}

-- Optimization profiles for different resolutions
local OPTIMIZATION_PROFILES = {
    [RESOLUTION_CATEGORY.LOW] = {
        hudSize = 1,
        hudYOffset = -5,
        actionBarsYOffset = 10,
        scaleMultiplier = 0.9,
        compactMode = true,
        description = "Low Resolution (< 1080p)"
    },
    [RESOLUTION_CATEGORY.STANDARD] = {
        hudSize = 2,
        hudYOffset = -38,
        actionBarsYOffset = 0,
        scaleMultiplier = 1.0,
        compactMode = false,
        description = "Standard Resolution (1080p)"
    },
    [RESOLUTION_CATEGORY.HIGH] = {
        hudSize = 2,
        hudYOffset = -38,
        actionBarsYOffset = 0,
        scaleMultiplier = 1.0,
        compactMode = false,
        description = "High Resolution (1440p+)"
    },
    [RESOLUTION_CATEGORY.ULTRA_HIGH] = {
        hudSize = 2,
        hudYOffset = -38,
        actionBarsYOffset = 0,
        scaleMultiplier = 1.1,
        compactMode = false,
        description = "Ultra High Resolution (4K+)"
    }
}

function ResolutionOptimizer:OnInitialize()
    debug("ResolutionOptimizer:OnInitialize")

    self.db = RealUI.db
    self.currentCategory = nil
    self.lastOptimizationTime = 0
    self.optimizationApplied = false

    -- Register for resolution change events
    self:RegisterEvent("DISPLAY_SIZE_CHANGED", "OnDisplaySizeChanged")
    self:RegisterEvent("UI_SCALE_CHANGED", "OnUIScaleChanged")

    -- Detect and apply initial optimizations
    self:DetectAndOptimize()
end

-- Get current physical screen dimensions
function ResolutionOptimizer:GetScreenDimensions()
    local width, height = _G.GetPhysicalScreenSize()
    debug("Screen dimensions:", width, "x", height)
    return width, height
end

-- Determine resolution category based on screen dimensions
function ResolutionOptimizer:GetResolutionCategory()
    local width, height = self:GetScreenDimensions()

    if height < RESOLUTION_THRESHOLDS.LOW_RES_HEIGHT then
        return RESOLUTION_CATEGORY.LOW
    elseif height >= RESOLUTION_THRESHOLDS.ULTRA_HIGH_RES_HEIGHT then
        return RESOLUTION_CATEGORY.ULTRA_HIGH
    elseif height >= RESOLUTION_THRESHOLDS.HIGH_RES_HEIGHT then
        return RESOLUTION_CATEGORY.HIGH
    else
        return RESOLUTION_CATEGORY.STANDARD
    end
end

-- Check if using low resolution display
function ResolutionOptimizer:IsLowResolution()
    local _, height = self:GetScreenDimensions()
    return height < RESOLUTION_THRESHOLDS.LOW_RES_HEIGHT
end

-- Check if using high resolution display
function ResolutionOptimizer:IsHighResolution()
    local _, height = self:GetScreenDimensions()
    return height >= RESOLUTION_THRESHOLDS.HIGH_RES_HEIGHT
end

-- Check if using ultra high resolution display
function ResolutionOptimizer:IsUltraHighResolution()
    local _, height = self:GetScreenDimensions()
    return height >= RESOLUTION_THRESHOLDS.ULTRA_HIGH_RES_HEIGHT
end

-- Get optimization profile for current resolution
function ResolutionOptimizer:GetOptimizationProfile()
    local category = self:GetResolutionCategory()
    return OPTIMIZATION_PROFILES[category], category
end

-- Apply resolution-specific optimizations
function ResolutionOptimizer:ApplyOptimizations(force)
    if not self.db then
        debug("Database not available, skipping optimizations")
        return false
    end

    local profile, category = self:GetOptimizationProfile()
    if not profile then
        debug("No optimization profile found")
        return false
    end

    -- Check if already optimized for this category
    if not force and self.currentCategory == category and self.optimizationApplied then
        debug("Already optimized for", category)
        return false
    end

    -- Check if this is the same category as last time (stored in DB)
    local dbg = self.db.global
    local previousCategory = dbg.tags and dbg.tags.resolutionCategory
    local categoryChanged = (previousCategory ~= category)

    debug("Applying optimizations for", category, "-", profile.description, "Changed:", categoryChanged)

    local dbc = self.db.char
    local db = self.db.profile

    -- Apply HuD size optimization
    if db.settings then
        db.settings.hudSize = profile.hudSize
        debug("Set HuD size to", profile.hudSize)
    end

    -- Apply position optimizations
    if db.positions then
        for layoutId = 1, 2 do
            if db.positions[layoutId] then
                -- Apply HuD Y offset for low resolution
                if category == RESOLUTION_CATEGORY.LOW then
                    db.positions[layoutId].HuDY = profile.hudYOffset
                    db.positions[layoutId].ActionBarsY = db.positions[layoutId].ActionBarsY + profile.actionBarsYOffset
                    debug("Applied low-res position adjustments for layout", layoutId)
                end
            end
        end
    end

    -- Mark as optimized
    if dbg.tags then
        dbg.tags.lowResOptimized = (category == RESOLUTION_CATEGORY.LOW)
        dbg.tags.resolutionCategory = category
    end

    self.currentCategory = category
    self.optimizationApplied = true
    self.lastOptimizationTime = _G.GetTime()

    -- Notify other systems
    -- Note: RefreshLayout method does not exist in LayoutManager

    if RealUI.HuDPositioning then
        RealUI.HuDPositioning:CalculatePositions()
    end

    -- Notify user only if category actually changed
    if categoryChanged and RealUI.FeedbackSystem then
        RealUI.FeedbackSystem:ShowFeedback(
            "info",
            "Resolution Optimizations Applied",
            ("Display optimized for %s"):format(profile.description)
        )
    end

    debug("Optimizations applied successfully")
    return true
end

-- Detect resolution and apply optimizations
function ResolutionOptimizer:DetectAndOptimize()
    debug("Detecting resolution and applying optimizations")
    return self:ApplyOptimizations(false)
end

-- Force re-optimization
function ResolutionOptimizer:ReOptimize()
    debug("Forcing re-optimization")
    self.optimizationApplied = false
    return self:ApplyOptimizations(true)
end

-- Event handler for display size changes
function ResolutionOptimizer:OnDisplaySizeChanged()
    debug("Display size changed, re-optimizing")
    self:ScheduleTimer(function()
        self:ReOptimize()
    end, 1.0)
end

-- Event handler for UI scale changes
function ResolutionOptimizer:OnUIScaleChanged()
    debug("UI scale changed, recalculating")
    self:ScheduleTimer(function()
        if RealUI.HuDPositioning then
            RealUI.HuDPositioning:CalculatePositions()
        end
    end, 0.5)
end

-- Get current optimization status
function ResolutionOptimizer:GetStatus()
    local width, height = self:GetScreenDimensions()
    local profile, category = self:GetOptimizationProfile()

    return {
        width = width,
        height = height,
        category = category,
        profile = profile,
        optimizationApplied = self.optimizationApplied,
        lastOptimizationTime = self.lastOptimizationTime,
        isLowRes = self:IsLowResolution(),
        isHighRes = self:IsHighResolution(),
        isUltraHighRes = self:IsUltraHighResolution()
    }
end

-- Print status to chat
function ResolutionOptimizer:PrintStatus()
    local status = self:GetStatus()
    print("=== Resolution Optimizer Status ===")
    print(("Screen: %dx%d"):format(status.width, status.height))
    print(("Category: %s"):format(status.category))
    print(("Profile: %s"):format(status.profile.description))
    print(("Optimized: %s"):format(status.optimizationApplied and "Yes" or "No"))
    print(("Low Res: %s"):format(status.isLowRes and "Yes" or "No"))
    print(("High Res: %s"):format(status.isHighRes and "Yes" or "No"))
    print(("Ultra High Res: %s"):format(status.isUltraHighRes and "Yes" or "No"))
end

-- Reset optimizations to defaults
function ResolutionOptimizer:ResetOptimizations()
    debug("Resetting optimizations to defaults")

    if not self.db then
        return false
    end

    local db = self.db.profile
    local dbg = self.db.global

    -- Reset to default positions
    if db.positions and RealUI.defaultPositions then
        for layoutId = 1, 2 do
            if RealUI.defaultPositions[layoutId] then
                db.positions[layoutId] = _G.CopyTable(RealUI.defaultPositions[layoutId])
            end
        end
    end

    -- Reset HuD size to default
    if db.settings then
        db.settings.hudSize = 2
    end

    -- Clear optimization flags
    if dbg.tags then
        dbg.tags.lowResOptimized = false
        dbg.tags.resolutionCategory = nil
    end

    self.currentCategory = nil
    self.optimizationApplied = false

    debug("Optimizations reset")
    return true
end

-- Export for integration with other systems
RealUI.ResolutionOptimizer = ResolutionOptimizer

-- Integrate with HuDPositioning system
function RealUI:IsUsingLowResDisplay()
    if self.ResolutionOptimizer then
        return self.ResolutionOptimizer:IsLowResolution()
    end
    -- Fallback
    local _, height = _G.GetPhysicalScreenSize()
    return height < 1080
end

function RealUI:IsUsingHighResDisplay()
    if self.ResolutionOptimizer then
        return self.ResolutionOptimizer:IsHighResolution()
    end
    -- Fallback
    local _, height = _G.GetPhysicalScreenSize()
    return height >= 1440
end

function RealUI:SetLowResOptimizations()
    if self.ResolutionOptimizer then
        return self.ResolutionOptimizer:ApplyOptimizations(true)
    end
    -- Fallback to legacy implementation
    local dbg = self.db.global
    local db = self.db.profile
    local dbp, dp = db.positions, self.defaultPositions

    if dbp[self.cLayout]["HuDY"] == dp[self.cLayout]["HuDY"] then
        dbp[self.cLayout]["HuDY"] = -5
    end
    if dbp[self.ncLayout]["HuDY"] == dp[self.ncLayout]["HuDY"] then
        dbp[self.ncLayout]["HuDY"] = -5
    end
    db.settings.hudSize = 1

    self:UpdateLayout()
    dbg.tags.lowResOptimized = true
end
