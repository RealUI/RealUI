local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs table pcall GetSpecialization print _G

-- RealUI Layout Manager
-- This module handles layout switching between DPS/Tank and Healing configurations
-- Implements automatic and manual layout switching with state management

local RealUI = private.RealUI
local debug = RealUI.GetDebug("LayoutManager")

local LayoutManager = {}
RealUI.LayoutManager = LayoutManager

-- Layout Manager Constants
local LAYOUT_DPS_TANK = 1
local LAYOUT_HEALING = 2

-- Layout Data Structures
local layoutConfigurations = {
    [LAYOUT_DPS_TANK] = {
        name = "DPS/Tank",
        profile = "RealUI",
        description = "Optimized layout for DPS and Tank roles",
        positions = {
            ["HuDX"] = 0,
            ["HuDY"] = -38,
            ["UFHorizontal"] = 200,
            ["ActionBarsY"] = -161.5,
            ["ActionBarsBotY"] = 16,
            ["CastBarPlayerX"] = 0,
            ["CastBarPlayerY"] = 0,
            ["CastBarTargetX"] = 0,
            ["CastBarTargetY"] = 0,
            ["SpellAlertWidth"] = 150,
            ["BossX"] = -32,
            ["BossY"] = 314
        }
    },
    [LAYOUT_HEALING] = {
        name = "Healing",
        profile = "RealUI-Healing",
        description = "Optimized layout for Healing role",
        positions = {
            ["HuDX"] = 0,
            ["HuDY"] = -38,
            ["UFHorizontal"] = 200,
            ["ActionBarsY"] = -115.5,
            ["ActionBarsBotY"] = 16,
            ["CastBarPlayerX"] = 0,
            ["CastBarPlayerY"] = -20,
            ["CastBarTargetX"] = 0,
            ["CastBarTargetY"] = -20,
            ["SpellAlertWidth"] = 150,
            ["BossX"] = -32,
            ["BossY"] = 314
        }
    }
}

-- Layout State Management
local layoutState = {
    currentLayout = LAYOUT_DPS_TANK,
    previousLayout = nil,
    autoSwitchEnabled = true,
    switchInProgress = false,
    specToLayoutMapping = {},
    initialized = false
}

-- Layout Manager Functions

function LayoutManager:Initialize()
    debug("Initializing LayoutManager")

    if layoutState.initialized then
        debug("LayoutManager already initialized")
        return true
    end

    -- Initialize spec to layout mapping
    self:InitializeSpecMapping()

    -- Set up event handlers for specialization changes
    self:RegisterEvents()

    -- Load current layout from character data
    self:LoadCurrentLayout()

    layoutState.initialized = true
    debug("LayoutManager initialized successfully")
    return true
end

function LayoutManager:InitializeSpecMapping()
    debug("Initializing specialization to layout mapping")

    -- Clear existing mapping
    layoutState.specToLayoutMapping = {}

    -- Map each specialization to appropriate layout based on role
    if RealUI.charInfo and RealUI.charInfo.specs then
        for specIndex = 1, #RealUI.charInfo.specs do
            local spec = RealUI.charInfo.specs[specIndex]
            if spec and spec.role then
                local layout = (spec.role == "HEALER") and LAYOUT_HEALING or LAYOUT_DPS_TANK
                layoutState.specToLayoutMapping[specIndex] = layout
                debug("Mapped spec", specIndex, "role", spec.role, "to layout", layout)
            end
        end
    end
end

function LayoutManager:RegisterEvents()
    debug("Registering layout manager events")

    -- Register for specialization change events through RealUI
    if RealUI.RegisterEvent then
        RealUI:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", function()
            if layoutState.autoSwitchEnabled then
                self:HandleSpecializationChange()
            end
        end)

        -- Register for player entering world to ensure layout is set correctly
        RealUI:RegisterEvent("PLAYER_ENTERING_WORLD", function()
            self:ValidateCurrentLayout()
        end)
    else
        debug("RealUI event system not available")
    end
end

function LayoutManager:LoadCurrentLayout()
    debug("Loading current layout from character data")

    local dbc = RealUI.db and RealUI.db.char
    if dbc and dbc.layout and dbc.layout.current then
        layoutState.currentLayout = dbc.layout.current
        debug("Loaded layout from character data:", layoutState.currentLayout)
    else
        debug("No saved layout found, using default DPS/Tank layout")
        layoutState.currentLayout = LAYOUT_DPS_TANK
    end

    -- Validate the loaded layout
    if not self:IsValidLayout(layoutState.currentLayout) then
        debug("Invalid layout detected, resetting to DPS/Tank")
        layoutState.currentLayout = LAYOUT_DPS_TANK
    end
end

-- Layout Configuration Management

function LayoutManager:GetLayoutConfiguration(layoutId)
    layoutId = layoutId or layoutState.currentLayout
    return layoutConfigurations[layoutId]
end

function LayoutManager:GetAllLayoutConfigurations()
    return layoutConfigurations
end

function LayoutManager:GetLayoutPositions(layoutId)
    local config = self:GetLayoutConfiguration(layoutId)
    return config and config.positions
end

function LayoutManager:UpdateLayoutPositions(layoutId, positions)
    if not self:IsValidLayout(layoutId) then
        debug("Invalid layout ID:", layoutId)
        return false
    end

    if not positions or type(positions) ~= "table" then
        debug("Invalid positions data")
        return false
    end

    debug("Updating positions for layout", layoutId)

    -- Update the layout configuration
    for key, value in pairs(positions) do
        layoutConfigurations[layoutId].positions[key] = value
    end

    -- Update database if this is the current layout
    if layoutId == layoutState.currentLayout then
        self:SaveCurrentLayoutPositions()
    end

    return true
end

function LayoutManager:SaveCurrentLayoutPositions()
    debug("Saving current layout positions to database")

    local db = RealUI.db
    if not db then
        debug("Database not available")
        return false
    end

    local currentConfig = self:GetLayoutConfiguration()
    if currentConfig and currentConfig.positions then
        if not db.profile.positions then
            db.profile.positions = {}
        end

        db.profile.positions[layoutState.currentLayout] = {}
        for key, value in pairs(currentConfig.positions) do
            db.profile.positions[layoutState.currentLayout][key] = value
        end

        debug("Layout positions saved successfully")
        return true
    end

    return false
end

-- Layout Switching Logic

function LayoutManager:SwitchToLayout(layoutId, force)
    if not self:IsValidLayout(layoutId) then
        debug("Invalid layout ID:", layoutId)
        return false
    end

    if layoutState.switchInProgress and not force then
        debug("Layout switch already in progress")
        return false
    end

    if layoutState.currentLayout == layoutId and not force then
        debug("Already using layout", layoutId)
        return true
    end

    debug("Switching to layout", layoutId, "from", layoutState.currentLayout)

    layoutState.switchInProgress = true
    layoutState.previousLayout = layoutState.currentLayout

    -- Perform the layout switch
    local success = self:PerformLayoutSwitch(layoutId)

    if success then
        layoutState.currentLayout = layoutId
        self:SaveLayoutState()
        self:NotifyLayoutChange(layoutId, layoutState.previousLayout)
        debug("Layout switch completed successfully")
    else
        debug("Layout switch failed")
    end

    layoutState.switchInProgress = false
    return success
end

function LayoutManager:PerformLayoutSwitch(layoutId)
    debug("Performing layout switch to", layoutId)

    local config = self:GetLayoutConfiguration(layoutId)
    if not config then
        debug("Layout configuration not found")
        return false
    end

    -- Update RealUI core layout variables
    RealUI.cLayout = layoutId
    RealUI.ncLayout = (layoutId == LAYOUT_DPS_TANK) and LAYOUT_HEALING or LAYOUT_DPS_TANK

    -- Update HuD positioning for the new layout
    if RealUI.HuDPositioning then
        RealUI.HuDPositioning:CalculatePositions()
    end

    -- Switch to the appropriate profile if profile system is available
    if RealUI.ProfileSystem and config.profile then
        local success = RealUI.ProfileSystem:SwitchProfile(config.profile)
        if not success then
            debug("Failed to switch profile to", config.profile)
            return false
        end
    end

    -- Update layout positions in the database
    self:UpdateDatabasePositions(layoutId)

    -- Trigger layout update in core system
    if RealUI.UpdateLayout then
        RealUI:UpdateLayout(layoutId)
    end

    return true
end

function LayoutManager:UpdateDatabasePositions(layoutId)
    debug("Updating database positions for layout", layoutId)

    local db = RealUI.db
    if not db then
        debug("Database not available")
        return false
    end

    local config = self:GetLayoutConfiguration(layoutId)
    if not config or not config.positions then
        debug("No positions found for layout", layoutId)
        return false
    end

    -- Ensure positions table exists
    if not db.profile.positions then
        db.profile.positions = {}
    end

    -- Update positions for the layout
    db.profile.positions[layoutId] = {}
    for key, value in pairs(config.positions) do
        db.profile.positions[layoutId][key] = value
    end

    debug("Database positions updated successfully")
    return true
end

-- Automatic Layout Switching

function LayoutManager:HandleSpecializationChange()
    debug("Handling specialization change")

    if not layoutState.autoSwitchEnabled then
        debug("Auto-switch disabled")
        return
    end

    local currentSpec = self:GetCurrentSpecialization()
    if not currentSpec then
        debug("Could not determine current specialization")
        return
    end

    local targetLayout = layoutState.specToLayoutMapping[currentSpec]
    if not targetLayout then
        debug("No layout mapping found for spec", currentSpec)
        return
    end

    debug("Specialization", currentSpec, "requires layout", targetLayout)

    if targetLayout ~= layoutState.currentLayout then
        self:SwitchToLayout(targetLayout)
    end
end

function LayoutManager:GetCurrentSpecialization()
    -- Get current specialization index
    local currentSpec = _G.GetSpecialization()
    if currentSpec and currentSpec > 0 then
        return currentSpec
    end

    debug("Could not get current specialization")
    return nil
end

function LayoutManager:SetAutoSwitchEnabled(enabled)
    debug("Setting auto-switch enabled:", enabled)
    layoutState.autoSwitchEnabled = enabled

    -- Save to character data
    local dbc = RealUI.db and RealUI.db.char
    if dbc and dbc.layout then
        dbc.layout.autoSwitch = enabled
    end
end

function LayoutManager:IsAutoSwitchEnabled()
    return layoutState.autoSwitchEnabled
end

-- Manual Layout Switching

function LayoutManager:SwitchToDPSTankLayout()
    debug("Manual switch to DPS/Tank layout requested")
    return self:SwitchToLayout(LAYOUT_DPS_TANK)
end

function LayoutManager:SwitchToHealingLayout()
    debug("Manual switch to Healing layout requested")
    return self:SwitchToLayout(LAYOUT_HEALING)
end

function LayoutManager:ToggleLayout()
    debug("Toggle layout requested")
    local targetLayout = (layoutState.currentLayout == LAYOUT_DPS_TANK) and LAYOUT_HEALING or LAYOUT_DPS_TANK
    return self:SwitchToLayout(targetLayout)
end

-- State Management and Persistence

function LayoutManager:SaveLayoutState()
    debug("Saving layout state to character data")

    local dbc = RealUI.db and RealUI.db.char
    if not dbc then
        debug("Character database not available")
        return false
    end

    if not dbc.layout then
        dbc.layout = {}
    end

    dbc.layout.current = layoutState.currentLayout
    dbc.layout.autoSwitch = layoutState.autoSwitchEnabled
    dbc.layout.spec = layoutState.specToLayoutMapping

    debug("Layout state saved successfully")
    return true
end

function LayoutManager:LoadLayoutState()
    debug("Loading layout state from character data")

    local dbc = RealUI.db and RealUI.db.char
    if not dbc or not dbc.layout then
        debug("No saved layout state found")
        return false
    end

    if dbc.layout.current then
        layoutState.currentLayout = dbc.layout.current
    end

    if dbc.layout.autoSwitch ~= nil then
        layoutState.autoSwitchEnabled = dbc.layout.autoSwitch
    end

    if dbc.layout.spec then
        layoutState.specToLayoutMapping = dbc.layout.spec
    end

    debug("Layout state loaded successfully")
    return true
end

-- Validation and Utility Functions

function LayoutManager:IsValidLayout(layoutId)
    return layoutId and layoutConfigurations[layoutId] ~= nil
end

function LayoutManager:GetCurrentLayout()
    return layoutState.currentLayout
end

function LayoutManager:GetCurrentLayoutName()
    local config = self:GetLayoutConfiguration()
    return config and config.name or "Unknown"
end

function LayoutManager:GetLayoutState()
    return {
        currentLayout = layoutState.currentLayout,
        previousLayout = layoutState.previousLayout,
        autoSwitchEnabled = layoutState.autoSwitchEnabled,
        switchInProgress = layoutState.switchInProgress,
        initialized = layoutState.initialized
    }
end

function LayoutManager:ValidateCurrentLayout()
    debug("Validating current layout")

    if not self:IsValidLayout(layoutState.currentLayout) then
        debug("Current layout is invalid, resetting to DPS/Tank")
        layoutState.currentLayout = LAYOUT_DPS_TANK
        self:SaveLayoutState()
    end

    -- Ensure layout matches current specialization if auto-switch is enabled
    if layoutState.autoSwitchEnabled then
        local currentSpec = self:GetCurrentSpecialization()
        if currentSpec then
            local expectedLayout = layoutState.specToLayoutMapping[currentSpec]
            if expectedLayout and expectedLayout ~= layoutState.currentLayout then
                debug("Layout mismatch detected, switching to expected layout", expectedLayout)
                self:SwitchToLayout(expectedLayout)
            end
        end
    end
end

-- Event Notification System

function LayoutManager:NotifyLayoutChange(newLayout, oldLayout)
    debug("Notifying layout change:", oldLayout, "->", newLayout)

    -- Fire custom event for other modules to listen to
    if RealUI.FireEvent then
        RealUI:FireEvent("REALUI_LAYOUT_CHANGED", newLayout, oldLayout)
    end

    -- Update any registered callbacks
    if self.layoutChangeCallbacks then
        for _, callback in ipairs(self.layoutChangeCallbacks) do
            if type(callback) == "function" then
                local success, err = pcall(callback, newLayout, oldLayout)
                if not success then
                    debug("Layout change callback failed:", err)
                end
            end
        end
    end
end

function LayoutManager:RegisterLayoutChangeCallback(callback)
    if type(callback) ~= "function" then
        debug("Invalid callback type")
        return false
    end

    if not self.layoutChangeCallbacks then
        self.layoutChangeCallbacks = {}
    end

    table.insert(self.layoutChangeCallbacks, callback)
    debug("Layout change callback registered")
    return true
end

-- Debug and Information Functions

function LayoutManager:GetDebugInfo()
    return {
        layoutState = layoutState,
        layoutConfigurations = layoutConfigurations,
        currentSpec = self:GetCurrentSpecialization(),
        isInitialized = layoutState.initialized
    }
end

function LayoutManager:PrintStatus()
    local currentConfig = self:GetLayoutConfiguration()
    local currentSpec = self:GetCurrentSpecialization()

    print("=== RealUI Layout Manager Status ===")
    print("Current Layout:", layoutState.currentLayout, "-", (currentConfig and currentConfig.name or "Unknown"))
    print("Auto-Switch Enabled:", layoutState.autoSwitchEnabled)
    print("Current Specialization:", currentSpec or "Unknown")
    print("Switch In Progress:", layoutState.switchInProgress)
    print("Initialized:", layoutState.initialized)

    if layoutState.specToLayoutMapping then
        print("Spec to Layout Mapping:")
        for spec, layout in pairs(layoutState.specToLayoutMapping) do
            local config = self:GetLayoutConfiguration(layout)
            print("  Spec", spec, "->", layout, "-", (config and config.name or "Unknown"))
        end
    end
end

-- Register with RealUI namespace
RealUI:RegisterNamespace("LayoutManager", LayoutManager)
