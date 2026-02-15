local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs time table pcall

-- RealUI Module Framework System
-- This system provides standardized module architecture and lifecycle management
-- Implements module enable/disable functionality with dependency handling
-- Creates module registration and coordination system

local RealUI = private.RealUI
local debug = RealUI.GetDebug("ModuleFramework")

local ModuleFramework = {}
RealUI.ModuleFramework = ModuleFramework

-- Module Registry and State Management
local registeredModules = {}
local moduleStates = {}
local moduleDependencies = {}
local moduleLoadOrder = {}
local isInitialized = false

-- Module Types
local MODULE_TYPES = {
    CORE = "core",           -- Essential system components
    ENHANCEMENT = "enhancement", -- Optional improvements
    UTILITY = "utility"      -- Helper systems
}

-- Module States
local MODULE_STATES = {
    UNREGISTERED = "unregistered",
    REGISTERED = "registered",
    INITIALIZING = "initializing",
    INITIALIZED = "initialized",
    ENABLING = "enabling",
    ENABLED = "enabled",
    DISABLING = "disabling",
    DISABLED = "disabled",
    ERROR = "error"
}

-- Enhanced Module Prototype with Common Functionality
local modulePrototype = {
    -- Version compatibility
    isRetail = RealUI.isRetail,
    isDragonflight = RealUI.isDragonflight,
    isMidnight = RealUI.isMidnight,

    -- Debug functionality
    debug = function(self, ...)
        return RealUI.Debug(self.moduleName, ...)
    end,

    -- Profile update handling
    OnProfileUpdate = function(self, event, profile)
        self.debug(self, "OnProfileUpdate", event, profile)

        -- Update enabled state based on profile
        local shouldBeEnabled = self.db and self.db.profile.modules[self.moduleName]
        if shouldBeEnabled ~= nil then
            self:SetEnabledState(shouldBeEnabled)
        end

        -- Call module-specific refresh if available
        if self.RefreshMod then
            self:RefreshMod(event, profile)
        end
    end,

    -- Enhanced enabled state management
    SetEnabledState = function(self, enabled)
        self.debug(self, "SetEnabledState", enabled)

        if enabled and not self:IsEnabled() then
            return ModuleFramework:EnableModule(self.moduleName)
        elseif not enabled and self:IsEnabled() then
            return ModuleFramework:DisableModule(self.moduleName)
        end

        return true
    end,

    -- Module information access
    GetModuleInfo = function(self)
        return ModuleFramework:GetModuleInfo(self.moduleName)
    end,

    -- Dependency management
    GetDependencies = function(self)
        return ModuleFramework:GetModuleDependencies(self.moduleName)
    end,

    -- State checking
    GetState = function(self)
        return ModuleFramework:GetModuleState(self.moduleName)
    end,

    -- Resource cleanup helper
    CleanupResources = function(self)
        self.debug(self, "CleanupResources")

        -- Unregister all events
        if self.UnregisterAllEvents then
            self:UnregisterAllEvents()
        end

        -- Cancel all timers
        if self.CancelAllTimers then
            self:CancelAllTimers()
        end

        -- Call module-specific cleanup if available
        if self.OnCleanup then
            self:OnCleanup()
        end
    end
}

-- Module Registration Functions
function ModuleFramework:RegisterModule(moduleName, moduleType, dependencies, options)
    if not moduleName or type(moduleName) ~= "string" then
        debug("Invalid module name:", moduleName)
        return false
    end

    if registeredModules[moduleName] then
        debug("Module already registered:", moduleName)
        return false
    end

    debug("Registering module:", moduleName, "type:", moduleType)

    -- Validate module type
    moduleType = moduleType or MODULE_TYPES.ENHANCEMENT
    local validType = false
    for _, validModuleType in pairs(MODULE_TYPES) do
        if moduleType == validModuleType then
            validType = true
            break
        end
    end

    if not validType then
        debug("Invalid module type:", moduleType, "for module:", moduleName)
        return false
    end

    -- Process dependencies
    dependencies = dependencies or {}
    if type(dependencies) == "string" then
        dependencies = {dependencies}
    end

    -- Validate dependencies
    for _, dep in ipairs(dependencies) do
        if type(dep) ~= "string" then
            debug("Invalid dependency type for module:", moduleName, "dependency:", dep)
            return false
        end
    end

    -- Process options
    options = options or {}

    -- Register the module
    registeredModules[moduleName] = {
        name = moduleName,
        type = moduleType,
        dependencies = dependencies,
        options = options,
        registrationTime = time()
    }

    -- Initialize module state
    moduleStates[moduleName] = MODULE_STATES.REGISTERED
    moduleDependencies[moduleName] = dependencies

    debug("Module registered successfully:", moduleName)
    return true
end

function ModuleFramework:UnregisterModule(moduleName)
    if not moduleName or not registeredModules[moduleName] then
        debug("Cannot unregister unknown module:", moduleName)
        return false
    end

    debug("Unregistering module:", moduleName)

    -- Disable module if enabled
    if self:IsModuleEnabled(moduleName) then
        self:DisableModule(moduleName)
    end

    -- Clean up registration data
    registeredModules[moduleName] = nil
    moduleStates[moduleName] = nil
    moduleDependencies[moduleName] = nil

    -- Remove from load order
    for i, name in ipairs(moduleLoadOrder) do
        if name == moduleName then
            table.remove(moduleLoadOrder, i)
            break
        end
    end

    debug("Module unregistered successfully:", moduleName)
    return true
end

function ModuleFramework:IsModuleRegistered(moduleName)
    return registeredModules[moduleName] ~= nil
end

function ModuleFramework:GetRegisteredModules()
    local modules = {}
    for name, info in pairs(registeredModules) do
        modules[name] = {
            name = info.name,
            type = info.type,
            dependencies = info.dependencies,
            state = moduleStates[name],
            registrationTime = info.registrationTime
        }
    end
    return modules
end

-- Module State Management
function ModuleFramework:GetModuleState(moduleName)
    return moduleStates[moduleName] or MODULE_STATES.UNREGISTERED
end

function ModuleFramework:SetModuleState(moduleName, state)
    if not registeredModules[moduleName] then
        debug("Cannot set state for unregistered module:", moduleName)
        return false
    end

    local validState = false
    for _, validModuleState in pairs(MODULE_STATES) do
        if state == validModuleState then
            validState = true
            break
        end
    end

    if not validState then
        debug("Invalid module state:", state, "for module:", moduleName)
        return false
    end

    local oldState = moduleStates[moduleName]
    moduleStates[moduleName] = state

    debug("Module state changed:", moduleName, oldState, "->", state)

    -- Notify other systems of state change
    RealUI:SendMessage("REALUI_MODULE_STATE_CHANGED", moduleName, state, oldState)

    return true
end

function ModuleFramework:IsModuleEnabled(moduleName)
    return self:GetModuleState(moduleName) == MODULE_STATES.ENABLED
end

function ModuleFramework:IsModuleDisabled(moduleName)
    local state = self:GetModuleState(moduleName)
    return state == MODULE_STATES.DISABLED or state == MODULE_STATES.REGISTERED
end

-- Enhanced Module Enable/Disable with Dependency Handling

-- Enhanced Module Loading and Unloading Mechanisms
function ModuleFramework:LoadModule(moduleName)
    if not registeredModules[moduleName] then
        debug("Cannot load unregistered module:", moduleName)
        return false
    end

    local currentState = self:GetModuleState(moduleName)
    if currentState == MODULE_STATES.ENABLED then
        debug("Module already loaded and enabled:", moduleName)
        return true
    end

    debug("Loading module:", moduleName)
    self:SetModuleState(moduleName, MODULE_STATES.INITIALIZING)

    -- Load dependencies first
    local dependencies = moduleDependencies[moduleName] or {}
    for _, depName in ipairs(dependencies) do
        if not self:IsModuleEnabled(depName) then
            debug("Loading dependency:", depName, "for module:", moduleName)
            local success = self:LoadModule(depName)
            if not success then
                debug("Failed to load dependency:", depName, "for module:", moduleName)
                self:SetModuleState(moduleName, MODULE_STATES.ERROR)
                return false
            end
        end
    end

    -- Get or create the module object
    local moduleObj = RealUI:GetModule(moduleName, true)
    if not moduleObj then
        debug("Module object not found:", moduleName)
        self:SetModuleState(moduleName, MODULE_STATES.ERROR)
        return false
    end

    -- Initialize module if needed
    local success, err = pcall(function()
        if not moduleObj:IsEnabled() then
            -- Call module-specific initialization if available
            if moduleObj.OnModuleLoad then
                moduleObj:OnModuleLoad()
            end

            -- Enable the module
            moduleObj:Enable()
        end
    end)

    if success then
        self:SetModuleState(moduleName, MODULE_STATES.ENABLED)
        debug("Module loaded successfully:", moduleName)

        -- Update profile setting
        if RealUI.db and RealUI.db.profile.modules then
            RealUI.db.profile.modules[moduleName] = true
        end

        -- Notify other modules of successful load
        self:BroadcastModuleMessage("ModuleFramework", "MODULE_LOADED", moduleName)

        return true
    else
        debug("Failed to load module:", moduleName, "error:", err)
        self:SetModuleState(moduleName, MODULE_STATES.ERROR)
        return false
    end
end

function ModuleFramework:UnloadModule(moduleName)
    if not registeredModules[moduleName] then
        debug("Cannot unload unregistered module:", moduleName)
        return false
    end

    local currentState = self:GetModuleState(moduleName)
    if currentState == MODULE_STATES.DISABLED or currentState == MODULE_STATES.REGISTERED then
        debug("Module already unloaded:", moduleName)
        return true
    end

    debug("Unloading module:", moduleName)
    self:SetModuleState(moduleName, MODULE_STATES.DISABLING)

    -- Unload dependent modules first
    for name, deps in pairs(moduleDependencies) do
        for _, depName in ipairs(deps) do
            if depName == moduleName and self:IsModuleEnabled(name) then
                debug("Unloading dependent module:", name, "for module:", moduleName)
                local success = self:UnloadModule(name)
                if not success then
                    debug("Failed to unload dependent module:", name, "for module:", moduleName)
                end
            end
        end
    end

    -- Get the module object
    local moduleObj = RealUI:GetModule(moduleName, true)
    if not moduleObj then
        debug("Module object not found:", moduleName)
        self:SetModuleState(moduleName, MODULE_STATES.ERROR)
        return false
    end

    -- Unload the module with proper cleanup
    local success, err = pcall(function()
        if moduleObj:IsEnabled() then
            -- Call module-specific cleanup before unloading
            if moduleObj.OnModuleUnload then
                moduleObj:OnModuleUnload()
            end

            -- Perform resource cleanup
            if moduleObj.CleanupResources then
                moduleObj:CleanupResources()
            end

            -- Disable the module
            moduleObj:Disable()
        end
    end)

    if success then
        self:SetModuleState(moduleName, MODULE_STATES.DISABLED)
        debug("Module unloaded successfully:", moduleName)

        -- Update profile setting
        if RealUI.db and RealUI.db.profile.modules then
            RealUI.db.profile.modules[moduleName] = false
        end

        -- Notify other modules of successful unload
        self:BroadcastModuleMessage("ModuleFramework", "MODULE_UNLOADED", moduleName)

        return true
    else
        debug("Failed to unload module:", moduleName, "error:", err)
        self:SetModuleState(moduleName, MODULE_STATES.ERROR)
        return false
    end
end

function ModuleFramework:EnableModule(moduleName)
    if not registeredModules[moduleName] then
        debug("Cannot enable unregistered module:", moduleName)
        return false
    end

    local currentState = self:GetModuleState(moduleName)
    if currentState == MODULE_STATES.ENABLED then
        debug("Module already enabled:", moduleName)
        return true
    end

    if currentState == MODULE_STATES.ENABLING then
        debug("Module already being enabled:", moduleName)
        return true
    end

    debug("Enabling module:", moduleName)
    self:SetModuleState(moduleName, MODULE_STATES.ENABLING)

    -- Check and enable dependencies first
    local dependencies = moduleDependencies[moduleName] or {}
    for _, depName in ipairs(dependencies) do
        if not self:IsModuleEnabled(depName) then
            debug("Enabling dependency:", depName, "for module:", moduleName)
            local success = self:EnableModule(depName)
            if not success then
                debug("Failed to enable dependency:", depName, "for module:", moduleName)
                self:SetModuleState(moduleName, MODULE_STATES.ERROR)
                return false
            end
        end
    end

    -- Get the actual module object
    local moduleObj = RealUI:GetModule(moduleName, true)
    if not moduleObj then
        debug("Module object not found:", moduleName)
        self:SetModuleState(moduleName, MODULE_STATES.ERROR)
        return false
    end

    -- Enable the module
    local success, err = pcall(function()
        if not moduleObj:IsEnabled() then
            moduleObj:Enable()
        end
    end)

    if success then
        self:SetModuleState(moduleName, MODULE_STATES.ENABLED)
        debug("Module enabled successfully:", moduleName)

        -- Update profile setting
        if RealUI.db and RealUI.db.profile.modules then
            RealUI.db.profile.modules[moduleName] = true
        end

        return true
    else
        debug("Failed to enable module:", moduleName, "error:", err)
        self:SetModuleState(moduleName, MODULE_STATES.ERROR)
        return false
    end
end

function ModuleFramework:DisableModule(moduleName)
    if not registeredModules[moduleName] then
        debug("Cannot disable unregistered module:", moduleName)
        return false
    end

    local currentState = self:GetModuleState(moduleName)
    if currentState == MODULE_STATES.DISABLED then
        debug("Module already disabled:", moduleName)
        return true
    end

    if currentState == MODULE_STATES.DISABLING then
        debug("Module already being disabled:", moduleName)
        return true
    end

    debug("Disabling module:", moduleName)
    self:SetModuleState(moduleName, MODULE_STATES.DISABLING)

    -- Check for dependent modules and disable them first
    for name, deps in pairs(moduleDependencies) do
        for _, depName in ipairs(deps) do
            if depName == moduleName and self:IsModuleEnabled(name) then
                debug("Disabling dependent module:", name, "for module:", moduleName)
                local success = self:DisableModule(name)
                if not success then
                    debug("Failed to disable dependent module:", name, "for module:", moduleName)
                end
            end
        end
    end

    -- Get the actual module object
    local moduleObj = RealUI:GetModule(moduleName, true)
    if not moduleObj then
        debug("Module object not found:", moduleName)
        self:SetModuleState(moduleName, MODULE_STATES.ERROR)
        return false
    end

    -- Disable the module
    local success, err = pcall(function()
        if moduleObj:IsEnabled() then
            moduleObj:Disable()
        end
    end)

    if success then
        self:SetModuleState(moduleName, MODULE_STATES.DISABLED)
        debug("Module disabled successfully:", moduleName)

        -- Update profile setting
        if RealUI.db and RealUI.db.profile.modules then
            RealUI.db.profile.modules[moduleName] = false
        end

        return true
    else
        debug("Failed to disable module:", moduleName, "error:", err)
        self:SetModuleState(moduleName, MODULE_STATES.ERROR)
        return false
    end
end

-- Dependency Management Functions
function ModuleFramework:GetModuleDependencies(moduleName)
    return moduleDependencies[moduleName] or {}
end

function ModuleFramework:AddModuleDependency(moduleName, dependencyName)
    if not registeredModules[moduleName] then
        debug("Cannot add dependency to unregistered module:", moduleName)
        return false
    end

    if not registeredModules[dependencyName] then
        debug("Cannot add unregistered dependency:", dependencyName, "to module:", moduleName)
        return false
    end

    if not moduleDependencies[moduleName] then
        moduleDependencies[moduleName] = {}
    end

    -- Check if dependency already exists
    for _, dep in ipairs(moduleDependencies[moduleName]) do
        if dep == dependencyName then
            debug("Dependency already exists:", dependencyName, "for module:", moduleName)
            return true
        end
    end

    -- Check for circular dependencies
    if self:HasCircularDependency(moduleName, dependencyName) then
        debug("Circular dependency detected:", moduleName, "<->", dependencyName)
        return false
    end

    table.insert(moduleDependencies[moduleName], dependencyName)
    debug("Added dependency:", dependencyName, "to module:", moduleName)
    return true
end

function ModuleFramework:RemoveModuleDependency(moduleName, dependencyName)
    if not moduleDependencies[moduleName] then
        return true
    end

    for i, dep in ipairs(moduleDependencies[moduleName]) do
        if dep == dependencyName then
            table.remove(moduleDependencies[moduleName], i)
            debug("Removed dependency:", dependencyName, "from module:", moduleName)
            return true
        end
    end

    return false
end

function ModuleFramework:HasCircularDependency(moduleName, dependencyName, visited)
    visited = visited or {}

    if visited[moduleName] then
        return true -- Circular dependency found
    end

    visited[moduleName] = true

    local deps = moduleDependencies[dependencyName] or {}
    for _, dep in ipairs(deps) do
        if dep == moduleName or self:HasCircularDependency(moduleName, dep, visited) then
            return true
        end
    end

    visited[moduleName] = nil
    return false
end

function ModuleFramework:ValidateDependencies()
    local issues = {}

    for moduleName, deps in pairs(moduleDependencies) do
        for _, depName in ipairs(deps) do
            -- Check if dependency is registered
            if not registeredModules[depName] then
                table.insert(issues, {
                    type = "missing_dependency",
                    module = moduleName,
                    dependency = depName
                })
            end

            -- Check for circular dependencies
            if self:HasCircularDependency(moduleName, depName) then
                table.insert(issues, {
                    type = "circular_dependency",
                    module = moduleName,
                    dependency = depName
                })
            end
        end
    end

    if #issues > 0 then
        debug("Dependency validation issues found:", #issues)
        for _, issue in ipairs(issues) do
            debug("Issue:", issue.type, "module:", issue.module, "dependency:", issue.dependency)
        end
    end

    return #issues == 0, issues
end

-- Module Load Order Calculation
function ModuleFramework:CalculateLoadOrder()
    local loadOrder = {}
    local visited = {}
    local visiting = {}

    local function visit(moduleName)
        if visiting[moduleName] then
            debug("Circular dependency detected during load order calculation:", moduleName)
            return false
        end

        if visited[moduleName] then
            return true
        end

        visiting[moduleName] = true

        local deps = moduleDependencies[moduleName] or {}
        for _, depName in ipairs(deps) do
            if not visit(depName) then
                return false
            end
        end

        visiting[moduleName] = nil
        visited[moduleName] = true
        table.insert(loadOrder, moduleName)

        return true
    end

    -- Visit all registered modules
    for moduleName in pairs(registeredModules) do
        if not visited[moduleName] then
            if not visit(moduleName) then
                debug("Failed to calculate load order due to circular dependencies")
                return nil
            end
        end
    end

    moduleLoadOrder = loadOrder
    debug("Calculated load order:", table.concat(loadOrder, ", "))
    return loadOrder
end

function ModuleFramework:GetLoadOrder()
    return moduleLoadOrder
end

-- Module Information Functions
function ModuleFramework:GetModuleInfo(moduleName)
    local regInfo = registeredModules[moduleName]
    if not regInfo then
        return nil
    end

    return {
        name = regInfo.name,
        type = regInfo.type,
        dependencies = regInfo.dependencies,
        options = regInfo.options,
        state = moduleStates[moduleName],
        registrationTime = regInfo.registrationTime,
        enabled = self:IsModuleEnabled(moduleName)
    }
end

function ModuleFramework:GetModulesByType(moduleType)
    local modules = {}
    for name, info in pairs(registeredModules) do
        if info.type == moduleType then
            modules[name] = self:GetModuleInfo(name)
        end
    end
    return modules
end

function ModuleFramework:GetEnabledModules()
    local enabled = {}
    for name in pairs(registeredModules) do
        if self:IsModuleEnabled(name) then
            enabled[name] = self:GetModuleInfo(name)
        end
    end
    return enabled
end

function ModuleFramework:GetDisabledModules()
    local disabled = {}
    for name in pairs(registeredModules) do
        if self:IsModuleDisabled(name) then
            disabled[name] = self:GetModuleInfo(name)
        end
    end
    return disabled
end

-- Performance Monitoring and Resource Management
function ModuleFramework:GetModulePerformanceStats(moduleName)
    -- Placeholder for performance monitoring
    -- In a full implementation, this would track CPU usage, memory usage, etc.
    return {
        cpuUsage = 0,
        memoryUsage = 0,
        eventCount = 0,
        lastUpdate = time()
    }
end

function ModuleFramework:GetSystemPerformanceStats()
    local stats = {
        totalModules = 0,
        enabledModules = 0,
        disabledModules = 0,
        errorModules = 0,
        totalCpuUsage = 0,
        totalMemoryUsage = 0
    }

    for name in pairs(registeredModules) do
        stats.totalModules = stats.totalModules + 1

        local state = self:GetModuleState(name)
        if state == MODULE_STATES.ENABLED then
            stats.enabledModules = stats.enabledModules + 1
        elseif state == MODULE_STATES.DISABLED then
            stats.disabledModules = stats.disabledModules + 1
        elseif state == MODULE_STATES.ERROR then
            stats.errorModules = stats.errorModules + 1
        end
    end

    return stats
end

-- Enhanced Inter-Module Communication and Event Coordination
local messageHandlers = {}
local eventCoordinator = {}
local messageQueue = {}
local isProcessingMessages = false

function ModuleFramework:RegisterMessageHandler(moduleName, messageType, handler)
    if not registeredModules[moduleName] then
        debug("Cannot register message handler for unregistered module:", moduleName)
        return false
    end

    if not messageHandlers[moduleName] then
        messageHandlers[moduleName] = {}
    end

    messageHandlers[moduleName][messageType] = handler
    debug("Registered message handler:", moduleName, "->", messageType)
    return true
end

function ModuleFramework:UnregisterMessageHandler(moduleName, messageType)
    if messageHandlers[moduleName] then
        messageHandlers[moduleName][messageType] = nil
        debug("Unregistered message handler:", moduleName, "->", messageType)
        return true
    end
    return false
end

function ModuleFramework:SendModuleMessage(fromModule, toModule, message, ...)
    debug("Module message:", fromModule, "->", toModule, ":", message)

    if not registeredModules[fromModule] or not registeredModules[toModule] then
        debug("Invalid module in message:", fromModule, toModule)
        return false
    end

    -- Check if target module is enabled
    if not self:IsModuleEnabled(toModule) then
        debug("Target module not enabled:", toModule)
        return false
    end

    -- Queue message for processing
    table.insert(messageQueue, {
        from = fromModule,
        to = toModule,
        message = message,
        args = {...},
        timestamp = time()
    })

    -- Process messages if not already processing
    if not isProcessingMessages then
        self:ProcessMessageQueue()
    end

    return true
end

function ModuleFramework:BroadcastModuleMessage(fromModule, message, ...)
    debug("Module broadcast:", fromModule, ":", message)

    if not registeredModules[fromModule] then
        debug("Invalid module in broadcast:", fromModule)
        return false
    end

    local sentCount = 0
    -- Broadcast to all enabled modules
    for name in pairs(registeredModules) do
        if name ~= fromModule and self:IsModuleEnabled(name) then
            if self:SendModuleMessage(fromModule, name, message, ...) then
                sentCount = sentCount + 1
            end
        end
    end

    debug("Broadcast sent to", sentCount, "modules")
    return sentCount > 0
end

function ModuleFramework:ProcessMessageQueue()
    if isProcessingMessages then
        return
    end

    isProcessingMessages = true

    while #messageQueue > 0 do
        local msg = table.remove(messageQueue, 1)

        -- Check if message handler exists
        if messageHandlers[msg.to] and messageHandlers[msg.to][msg.message] then
            local success, err = pcall(messageHandlers[msg.to][msg.message], msg.from, msg.message, unpack(msg.args))
            if not success then
                debug("Message handler error:", msg.to, msg.message, err)
            end
        else
            -- Fallback to RealUI's message system
            RealUI:SendMessage("REALUI_MODULE_MESSAGE", msg.from, msg.to, msg.message, unpack(msg.args))
        end
    end

    isProcessingMessages = false
end

-- Event Coordination System
function ModuleFramework:RegisterEventCoordinator(eventName, coordinatorFunc)
    eventCoordinator[eventName] = coordinatorFunc
    debug("Registered event coordinator for:", eventName)
    return true
end

function ModuleFramework:UnregisterEventCoordinator(eventName)
    eventCoordinator[eventName] = nil
    debug("Unregistered event coordinator for:", eventName)
    return true
end

function ModuleFramework:CoordinateEvent(eventName, ...)
    debug("Coordinating event:", eventName)

    if eventCoordinator[eventName] then
        local success, err = pcall(eventCoordinator[eventName], eventName, ...)
        if not success then
            debug("Event coordinator error:", eventName, err)
            return false
        end
    end

    -- Broadcast event to all enabled modules
    return self:BroadcastModuleMessage("ModuleFramework", "EVENT_COORDINATED", eventName, ...)
end

-- Module State Persistence and Restoration
local moduleStateHistory = {}
local maxHistoryEntries = 10

function ModuleFramework:SaveModuleState(moduleName, stateData)
    if not registeredModules[moduleName] then
        debug("Cannot save state for unregistered module:", moduleName)
        return false
    end

    if not moduleStateHistory[moduleName] then
        moduleStateHistory[moduleName] = {}
    end

    -- Add new state entry
    table.insert(moduleStateHistory[moduleName], {
        timestamp = time(),
        state = self:GetModuleState(moduleName),
        data = stateData or {},
        enabled = self:IsModuleEnabled(moduleName)
    })

    -- Limit history size
    while #moduleStateHistory[moduleName] > maxHistoryEntries do
        table.remove(moduleStateHistory[moduleName], 1)
    end

    debug("Saved state for module:", moduleName)
    return true
end

function ModuleFramework:RestoreModuleState(moduleName, historyIndex)
    if not moduleStateHistory[moduleName] then
        debug("No state history for module:", moduleName)
        return false
    end

    historyIndex = historyIndex or #moduleStateHistory[moduleName]
    local stateEntry = moduleStateHistory[moduleName][historyIndex]

    if not stateEntry then
        debug("Invalid history index for module:", moduleName, historyIndex)
        return false
    end

    debug("Restoring state for module:", moduleName, "from index:", historyIndex)

    -- Restore enabled state
    if stateEntry.enabled and not self:IsModuleEnabled(moduleName) then
        self:EnableModule(moduleName)
    elseif not stateEntry.enabled and self:IsModuleEnabled(moduleName) then
        self:DisableModule(moduleName)
    end

    -- Call module-specific state restoration if available
    local moduleObj = RealUI:GetModule(moduleName, true)
    if moduleObj and moduleObj.RestoreState then
        local success, err = pcall(moduleObj.RestoreState, moduleObj, stateEntry.data)
        if not success then
            debug("Module state restoration error:", moduleName, err)
            return false
        end
    end

    return true
end

function ModuleFramework:GetModuleStateHistory(moduleName)
    return moduleStateHistory[moduleName] or {}
end

function ModuleFramework:ClearModuleStateHistory(moduleName)
    if moduleName then
        moduleStateHistory[moduleName] = nil
        debug("Cleared state history for module:", moduleName)
    else
        moduleStateHistory = {}
        debug("Cleared all module state history")
    end
    return true
end

-- Persistent Module Configuration
function ModuleFramework:SaveModuleConfiguration()
    if not RealUI.db or not RealUI.db.profile then
        debug("Database not available for configuration save")
        return false
    end

    local config = {
        moduleStates = {},
        dependencies = moduleDependencies,
        loadOrder = moduleLoadOrder,
        timestamp = time()
    }

    -- Save current module states
    for name in pairs(registeredModules) do
        config.moduleStates[name] = {
            state = self:GetModuleState(name),
            enabled = self:IsModuleEnabled(name)
        }
    end

    RealUI.db.profile.moduleFrameworkConfig = config
    debug("Module configuration saved")
    return true
end

function ModuleFramework:LoadModuleConfiguration()
    if not RealUI.db or not RealUI.db.profile or not RealUI.db.profile.moduleFrameworkConfig then
        debug("No saved module configuration found")
        return false
    end

    local config = RealUI.db.profile.moduleFrameworkConfig
    debug("Loading module configuration from:", config.timestamp)

    -- Restore module states
    for name, stateInfo in pairs(config.moduleStates) do
        if registeredModules[name] then
            if stateInfo.enabled and not self:IsModuleEnabled(name) then
                self:EnableModule(name)
            elseif not stateInfo.enabled and self:IsModuleEnabled(name) then
                self:DisableModule(name)
            end
        end
    end

    -- Restore load order if available
    if config.loadOrder then
        moduleLoadOrder = config.loadOrder
    end

    debug("Module configuration loaded successfully")
    return true
end

-- Initialization and Lifecycle Management
function ModuleFramework:Initialize()
    debug("Initializing ModuleFramework")

    if isInitialized then
        debug("ModuleFramework already initialized")
        return true
    end

    -- Set up the enhanced module prototype
    RealUI:SetDefaultModulePrototype(modulePrototype)

    -- Register for profile updates
    if RealUI.db then
        RealUI.db.RegisterCallback(self, "OnProfileChanged", "OnProfileUpdate")
        RealUI.db.RegisterCallback(self, "OnProfileCopied", "OnProfileUpdate")
        RealUI.db.RegisterCallback(self, "OnProfileReset", "OnProfileUpdate")
    end

    -- Calculate initial load order
    self:CalculateLoadOrder()

    -- Validate dependencies
    local valid, issues = self:ValidateDependencies()
    if not valid then
        debug("Dependency validation failed, issues:", #issues)
    end

    -- Load saved module configuration if available
    self:LoadModuleConfiguration()

    -- Initialize message processing system
    messageQueue = {}
    isProcessingMessages = false

    -- Initialize state history system
    moduleStateHistory = {}

    isInitialized = true
    debug("ModuleFramework initialized successfully")
    return true
end

function ModuleFramework:Shutdown()
    debug("Shutting down ModuleFramework")

    -- Save current module configuration before shutdown
    self:SaveModuleConfiguration()

    -- Unload all modules in reverse load order
    local loadOrder = self:GetLoadOrder()
    for i = #loadOrder, 1, -1 do
        local moduleName = loadOrder[i]
        if self:IsModuleEnabled(moduleName) then
            self:UnloadModule(moduleName)
        end
    end

    -- Clean up message system
    messageQueue = {}
    messageHandlers = {}
    eventCoordinator = {}
    singMessages = false

    -- Clean up state history
    moduleStateHistory = {}

    -- Clean up registration data
    registeredModules = {}
    moduleStates = {}
    moduleDependencies = {}
    moduleLoadOrder = {}

    isInitialized = false
    debug("ModuleFramework shutdown completed")
end

function ModuleFramework:OnProfileUpdate(event, profile)
    debug("OnProfileUpdate", event, profile)

    -- Save current state before profile change
    for moduleName in pairs(registeredModules) do
        self:SaveModuleState(moduleName)
    end

    -- Update all modules with the profile change
    for moduleName in pairs(registeredModules) do
        local moduleObj = RealUI:GetModule(moduleName, true)
        if moduleObj and moduleObj.OnProfileUpdate then
            moduleObj:OnProfileUpdate(event, profile)
        end
    end

    -- Save configuration after profile update
    self:SaveModuleConfiguration()
end

-- Enhanced Utility Functions
function ModuleFramework:IsInitialized()
    return isInitialized
end

function ModuleFramework:GetFrameworkStatus()
    return {
        initialized = isInitialized,
        totalModules = self:GetSystemPerformanceStats().totalModules,
        enabledModules = self:GetSystemPerformanceStats().enabledModules,
        loadOrder = moduleLoadOrder,
        hasValidDependencies = self:ValidateDependencies(),
        messageQueueSize = #messageQueue,
        stateHistoryEntries = self:GetStateHistoryCount()
    }
end

function ModuleFramework:GetDebugInfo()
    return {
        framework = self:GetFrameworkStatus(),
        modules = self:GetRegisteredModules(),
        performance = self:GetSystemPerformanceStats(),
        loadOrder = moduleLoadOrder,
        dependencies = moduleDependencies,
        messageHandlers = messageHandlers,
        eventCoordinators = eventCoordinator,
        stateHistory = moduleStateHistory
    }
end

function ModuleFramework:GetStateHistoryCount()
    local count = 0
    for _, history in pairs(moduleStateHistory) do
        count = count + #history
    end
    return count
end

-- Module Loading Batch Operations
function ModuleFramework:LoadAllModules()
    debug("Loading all registered modules")
    local loadOrder = self:GetLoadOrder()
    local successCount = 0
    local failureCount = 0

    for _, moduleName in ipairs(loadOrder) do
        if self:LoadModule(moduleName) then
            successCount = successCount + 1
        else
            failureCount = failureCount + 1
        end
    end

    debug("Batch load completed:", successCount, "success,", failureCount, "failures")
    return successCount, failureCount
end

function ModuleFramework:UnloadAllModules()
    debug("Unloading all modules")
    local loadOrder = self:GetLoadOrder()
    local successCount = 0
    local failureCount = 0

    -- Unload in reverse order
    for i = #loadOrder, 1, -1 do
        local moduleName = loadOrder[i]
        if self:UnloadModule(moduleName) then
            successCount = successCount + 1
        else
            failureCount = failureCount + 1
        end
    end

    debug("Batch unload completed:", successCount, "success,", failureCount, "failures")
    return successCount, failureCount
end

-- Resource Management and Cleanup
function ModuleFramework:PerformResourceCleanup()
    debug("Performing resource cleanup")

    -- Clean up message queue
    local oldQueueSize = #messageQueue
    messageQueue = {}

    -- Clean up old state history entries
    local cleanedEntries = 0
    for moduleName, history in pairs(moduleStateHistory) do
        while #history > maxHistoryEntries do
            table.remove(history, 1)
            cleanedEntries = cleanedEntries + 1
        end
    end

    -- Force garbage collection for modules
    for moduleName in pairs(registeredModules) do
        local moduleObj = RealUI:GetModule(moduleName, true)
        if moduleObj and moduleObj.CleanupResources then
            moduleObj:CleanupResources()
        end
    end

    debug("Resource cleanup completed:", oldQueueSize, "messages cleared,", cleanedEntries, "history entries cleaned")
    return true
end

-- Constants Export
ModuleFramework.MODULE_TYPES = MODULE_TYPES
ModuleFramework.MODULE_STATES = MODULE_STATES

-- Register with RealUI namespace
RealUI:RegisterNamespace("ModuleFramework", ModuleFramework)
