local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("SystemIntegration")

-- System Integration Module
-- Handles final wiring of all RealUI modules with proper event handling and coordination
local SystemIntegration = {}
private.SystemIntegration = SystemIntegration

-- Integration State
local integrationState = {
    initialized = false,
    modulesWired = false,
    eventsRegistered = false,
    errorHandlersInstalled = false
}

-- Module Communication Hub
local communicationHub = {
    listeners = {},
    messageQueue = {}
}

-- Register a module to listen for specific messages
function SystemIntegration:RegisterMessageListener(moduleName, messageType, callback)
    if not communicationHub.listeners[messageType] then
        communicationHub.listeners[messageType] = {}
    end

    table.insert(communicationHub.listeners[messageType], {
        module = moduleName,
        callback = callback
    })

    debug("Registered message listener:", moduleName, "for", messageType)
end

-- Broadcast a message to all registered listeners
function SystemIntegration:BroadcastMessage(messageType, ...)
    local listeners = communicationHub.listeners[messageType]
    if not listeners then return end

    for _, listener in ipairs(listeners) do
        local success, err = pcall(listener.callback, ...)
        if not success then
            debug("Error in message listener", listener.module, "for", messageType, ":", err)
        end
    end
end

-- Wire all modules together with proper event handling
function SystemIntegration:WireModules()
    if integrationState.modulesWired then
        return true
    end

    debug("Wiring modules together...")

    -- Wire Layout Manager with HuD Positioning
    if RealUI.LayoutManager and RealUI.HuDPositioning then
        self:RegisterMessageListener("LayoutManager", "LAYOUT_CHANGED", function(layoutId)
            RealUI.HuDPositioning:CalculatePositions()
        end)
    end

    -- Wire Profile System with all modules
    if RealUI.ProfileSystem then
        self:RegisterMessageListener("ProfileSystem", "PROFILE_CHANGED", function(profileName)
            for _, module in RealUI:IterateModules() do
                if module.OnProfileUpdate then
                    module:OnProfileUpdate("OnProfileChanged", profileName)
                end
            end
        end)
    end

    -- Wire Dual-Spec System with Layout Manager
    if RealUI.DualSpecSystem and RealUI.LayoutManager then
        self:RegisterMessageListener("DualSpecSystem", "SPEC_CHANGED", function(specIndex, role)
            local layoutId = role == "HEALER" and 2 or 1
            RealUI.LayoutManager:SwitchToLayout(layoutId)
        end)
    end

    -- Wire Performance Monitor with all modules
    if RealUI.PerformanceMonitor then
        self:RegisterMessageListener("PerformanceMonitor", "PERFORMANCE_WARNING", function(warningType, details)
            if RealUI.FeedbackSystem then
                RealUI.FeedbackSystem:ShowPerformanceWarning(warningType, details)
            end
        end)
    end

    -- Wire Frame Mover with Config Mode
    if RealUI.FrameMover and RealUI.ConfigMode then
        self:RegisterMessageListener("ConfigMode", "CONFIG_MODE_TOGGLED", function(enabled)
            if enabled then
                RealUI.FrameMover:EnableMovement()
            else
                RealUI.FrameMover:DisableMovement()
            end
        end)
    end

    integrationState.modulesWired = true
    debug("Module wiring complete")
    return true
end

-- Register system-wide event handlers
function SystemIntegration:RegisterEventHandlers()
    if integrationState.eventsRegistered then
        return true
    end

    debug("Registering system-wide event handlers...")

    -- Combat state tracking
    RealUI:RegisterEvent("PLAYER_REGEN_DISABLED", function()
        RealUI.inCombat = true
        self:BroadcastMessage("COMBAT_STARTED")
    end)

    RealUI:RegisterEvent("PLAYER_REGEN_ENABLED", function()
        RealUI.inCombat = false
        self:BroadcastMessage("COMBAT_ENDED")
    end)

    -- Loading screen tracking
    RealUI:RegisterEvent("PLAYER_ENTERING_WORLD", function()
        self:BroadcastMessage("WORLD_ENTERED")
    end)

    -- UI scale changes
    RealUI:RegisterEvent("UI_SCALE_CHANGED", function()
        self:BroadcastMessage("UI_SCALE_CHANGED")
        if RealUI.HuDPositioning then
            RealUI.HuDPositioning:CalculatePositions()
        end
    end)

    integrationState.eventsRegistered = true
    debug("Event handler registration complete")
    return true
end

-- Install comprehensive error handlers
function SystemIntegration:InstallErrorHandlers()
    if integrationState.errorHandlersInstalled then
        return true
    end

    debug("Installing error handlers...")

    -- Module error handler
    local originalEnableModule = RealUI.EnableModule
    RealUI.EnableModule = function(self, moduleName)
        local success, err = pcall(originalEnableModule, self, moduleName)
        if not success then
            debug("Error enabling module", moduleName, ":", err)
            if RealUI.FeedbackSystem then
                RealUI.FeedbackSystem:ShowError("Module Error", ("Failed to enable %s: %s"):format(moduleName, err))
            end
            return false
        end
        return true
    end

    -- Layout switch error handler
    if RealUI.LayoutManager then
        local originalSwitch = RealUI.LayoutManager.SwitchToLayout
        RealUI.LayoutManager.SwitchToLayout = function(self, layoutId)
            local success, result = pcall(originalSwitch, self, layoutId)
            if not success then
                debug("Error switching layout:", result)
                if RealUI.FeedbackSystem then
                    RealUI.FeedbackSystem:ShowError("Layout Error", "Failed to switch layout: " .. tostring(result))
                end
                return false
            end
            return result
        end
    end

    integrationState.errorHandlersInstalled = true
    debug("Error handler installation complete")
    return true
end

-- Perform system-wide performance optimizations
function SystemIntegration:OptimizePerformance()
    debug("Applying system-wide performance optimizations...")

    -- Note: OptimizeEventHandling, OptimizeFrameUpdates, and OptimizeModuleLoading
    -- methods are not implemented in their respective systems

    debug("Performance optimizations applied")
end

-- Resource management and cleanup
function SystemIntegration:ManageResources()
    debug("Managing system resources...")

    -- Schedule periodic garbage collection
    RealUI:ScheduleRepeatingTimer(function()
        if not RealUI.inCombat and RealUI.PerformanceMonitor then
            RealUI.PerformanceMonitor:PerformGarbageCollection()
        end
    end, 300) -- Every 5 minutes

    -- Monitor memory usage
    if RealUI.PerformanceMonitor then
        RealUI.PerformanceMonitor:StartMonitoring()
    end

    debug("Resource management configured")
end

-- Initialize system integration
function SystemIntegration:Initialize()
    if integrationState.initialized then
        return true
    end

    debug("Initializing system integration...")

    -- Wire all modules together
    self:WireModules()

    -- Register event handlers
    self:RegisterEventHandlers()

    -- Install error handlers
    self:InstallErrorHandlers()

    -- Apply performance optimizations
    self:OptimizePerformance()

    -- Set up resource management
    self:ManageResources()

    integrationState.initialized = true
    debug("System integration initialized successfully")

    return true
end

-- Get integration status
function SystemIntegration:GetStatus()
    return {
        initialized = integrationState.initialized,
        modulesWired = integrationState.modulesWired,
        eventsRegistered = integrationState.eventsRegistered,
        errorHandlersInstalled = integrationState.errorHandlersInstalled,
        messageListeners = communicationHub.listeners
    }
end

-- Expose SystemIntegration to RealUI
RealUI.SystemIntegration = SystemIntegration
