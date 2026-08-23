local ADDON_NAME, private = ... -- luacheck: ignore

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
            -- (B13: SpellAlertWidth retired — key no longer read anywhere)
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

    -- Register EditMode layout activation on layout switch
    self:RegisterLayoutChangeCallback(function(newLayout, oldLayout)
        if RealUI.EditModeManager and RealUI.EditModeManager:IsInitialized() then
            local role = (newLayout == LAYOUT_HEALING) and "healing" or "dpstank"
            RealUI.EditModeManager:ActivateLayout(role)
        end
    end)

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

    if RealUI.RegisterEvent then
        -- NOTE: ACTIVE_TALENT_GROUP_CHANGED is NOT registered here.
        -- DualSpecSystem is the single coordinator for spec-change-driven
        -- layout switches, preventing race conditions with double-switching.

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

--- The positions table a layout actually READS, in the profile it runs under.
--
-- The two layouts do not share a profile (see `layoutConfigurations`: layout 1
-- runs on "RealUI", layout 2 on "RealUI-Healing") while `positions` lives on
-- the profile. So `db.profile.positions[otherLayout]` — the obvious place to
-- mirror a linked setting into — is a table the other layout never reads: when
-- you are on layout 2 you are also on the Healing profile, and it is THAT
-- profile's positions[2] in play. Reported twice by the same tester (B79, then
-- again in beta 8: "linked is checked but the vertical number differs between
-- the two specs").
--
-- Returns the live table for the current layout, or the raw AceDB store for
-- the other one (`db.profiles[name]`; defaults are applied when that profile is
-- next loaded, so writing raw keys into it is safe). Created if absent —
-- a character that has never used the other layout has no table yet, and that
-- is exactly the case where linking matters most.
function LayoutManager:GetLayoutPositionsStore(layoutId)
    local db = RealUI.db
    if not (db and self:IsValidLayout(layoutId)) then return end

    local config = self:GetLayoutConfiguration(layoutId)
    local profileName = config and config.profile
    if not profileName then return end

    if profileName == db:GetCurrentProfile() then
        db.profile.positions = db.profile.positions or {}
        db.profile.positions[layoutId] = db.profile.positions[layoutId] or {}
        return db.profile.positions[layoutId]
    end

    if not db.profiles then return end
    local profile = db.profiles[profileName]
    if not profile then
        profile = {}
        db.profiles[profileName] = profile
    end
    profile.positions = profile.positions or {}
    profile.positions[layoutId] = profile.positions[layoutId] or {}
    return profile.positions[layoutId]
end

--- Turn "Link Layouts" on or off.
--
-- Account-wide by design (B79: stored per-profile it could read ON in Healing
-- and OFF in DPS/Tank at once). Turning it ON seeds the other layout from the
-- current one, so the promise holds from the moment the box is ticked rather
-- than only for values changed afterwards. Shared by the HuD config toggle and
-- the install wizard.
function LayoutManager:SetPositionsLink(enabled)
    local db = RealUI.db
    if not db then return end

    db.global.positionsLink = enabled and true or false
    if not enabled then return end

    local current = RealUI.cLayout or db.char.layout.current or LAYOUT_DPS_TANK
    local other = (current == LAYOUT_DPS_TANK) and LAYOUT_HEALING or LAYOUT_DPS_TANK

    local source = self:GetLayoutPositionsStore(current)
    if not source then return end

    -- Both the in-profile copy and the other profile's own copy: the first is
    -- what a manual layout switch inside one profile reads, the second is what
    -- the other spec reads.
    db.profile.positions[other] = RealUI.DeepCopy(source)

    local dest = self:GetLayoutPositionsStore(other)
    if dest then
        for key, value in pairs(source) do
            dest[key] = value
        end
    end
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
        if not db.profile.positions[layoutState.currentLayout] then
            db.profile.positions[layoutState.currentLayout] = {}
        end

        -- Merge in place — never wipe the stored table. Runtime writers
        -- (HuDPositioning, Infobar) and user config (HuD Vertical slider,
        -- Anchor Width) own keys in here; a wipe-and-restore replaces their
        -- values with raw layout defaults (the same settings-loss class as
        -- the 2026-05-09 bar-drift post-mortem).
        local dest = db.profile.positions[layoutState.currentLayout]
        for key, value in pairs(currentConfig.positions) do
            dest[key] = value
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

    -- Switch to the appropriate profile if not already on it.
    -- When called from OnProfileUpdate (via spec change), the profile is
    -- already correct so AceDB:SetProfile is a no-op. When called directly
    -- (manual switch, CharacterInit, etc.), this ensures the profile matches.
    if RealUI.ProfileSystem and config.profile then
        local currentProfile = RealUI.ProfileSystem:GetCurrentProfile()
        if currentProfile ~= config.profile then
            local success = RealUI.ProfileSystem:SwitchProfile(config.profile)
            if not success then
                debug("Failed to switch profile to", config.profile)
                return false
            end
        end
    end

    -- Update HuD positioning for the new layout
    if RealUI.HuDPositioning then
        RealUI.HuDPositioning:CalculatePositions()
    end

    -- Update character database
    local dbc = RealUI.db and RealUI.db.char
    if dbc then
        dbc.layout.current = layoutId
    end

    -- Update layout positions in the database
    self:UpdateDatabasePositions(layoutId)

    -- Update positioners directly (do NOT call RealUI:UpdateLayout which
    -- would re-enter LayoutManager:SwitchToLayout causing infinite recursion)
    if RealUI.UpdatePositioners then
        RealUI:UpdatePositioners()
    end

    -- Ensure ActionBars are updated for the new layout
    local ActionBars = RealUI:GetModule("ActionBars", true)
    if ActionBars and ActionBars:IsEnabled() then
        ActionBars:ApplyABSettings()
    end

    -- Refresh UnitFrames to ensure they reposition correctly for the new layout
    local UnitFrames = RealUI:GetModule("UnitFrames", true)
    if UnitFrames and UnitFrames:IsEnabled() then
        debug("Refreshing UnitFrames for layout", layoutId)
        UnitFrames:RefreshMod()
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
    if not db.profile.positions[layoutId] then
        db.profile.positions[layoutId] = {}
    end

    -- Fill in ONLY missing keys with layout defaults. Do NOT wipe the
    -- existing table — HuDPositioning:UpdateRealUIPositions has already
    -- written scaled/offset values, and the Infobar owns ActionBarsBotY
    -- (sets it to Scale.Value(BAR_HEIGHT) so bars stack above the infobar).
    -- Wiping here replaced correct runtime values with raw defaults,
    -- causing action bars to drift 29px downward on every spec swap.
    local dest = db.profile.positions[layoutId]
    for key, value in pairs(config.positions) do
        if dest[key] == nil then
            dest[key] = value
        end
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

function LayoutManager:IsSwitchInProgress()
    return layoutState.switchInProgress
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
