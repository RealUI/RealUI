local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("ErrorRecovery")

-- Error Recovery System
-- Handles error detection, recovery, and graceful degradation
local ErrorRecovery = {}
private.ErrorRecovery = ErrorRecovery

-- Error tracking
local errorLog = {}
local recoveryAttempts = {}
local maxRecoveryAttempts = 3

-- Error types
local ERROR_TYPES = {
    MODULE_LOAD = "module_load",
    PROFILE_CORRUPTION = "profile_corruption",
    LAYOUT_SWITCH = "layout_switch",
    DATABASE_ERROR = "database_error",
    ADDON_CONFLICT = "addon_conflict",
    RESOURCE_EXHAUSTION = "resource_exhaustion"
}

-- Log an error
function ErrorRecovery:LogError(errorType, moduleName, errorMessage, stackTrace)
    local errorEntry = {
        type = errorType,
        module = moduleName,
        message = errorMessage,
        stack = stackTrace,
        timestamp = _G.time(),
        recovered = false
    }

    table.insert(errorLog, errorEntry)
    debug("Error logged:", errorType, moduleName, errorMessage)

    -- Keep only last 100 errors
    if #errorLog > 100 then
        table.remove(errorLog, 1)
    end

    return errorEntry
end

-- Attempt to recover from an error
function ErrorRecovery:AttemptRecovery(errorType, moduleName, recoveryFunc)
    local attemptKey = errorType .. ":" .. (moduleName or "system")

    -- Check if we've exceeded max attempts
    if not recoveryAttempts[attemptKey] then
        recoveryAttempts[attemptKey] = 0
    end

    if recoveryAttempts[attemptKey] >= maxRecoveryAttempts then
        debug("Max recovery attempts exceeded for", attemptKey)
        return false, "max_attempts_exceeded"
    end

    recoveryAttempts[attemptKey] = recoveryAttempts[attemptKey] + 1

    -- Attempt recovery
    local success, result = pcall(recoveryFunc)

    if success then
        debug("Recovery successful for", attemptKey)
        recoveryAttempts[attemptKey] = 0 -- Reset on success
        return true, result
    else
        debug("Recovery failed for", attemptKey, ":", result)
        return false, result
    end
end

-- Recover from module load failure
function ErrorRecovery:RecoverModuleLoad(moduleName)
    return self:AttemptRecovery(ERROR_TYPES.MODULE_LOAD, moduleName, function()
        -- Try to disable and re-enable the module
        if RealUI.ModuleFramework then
            RealUI.ModuleFramework:DisableModule(moduleName)
            RealUI:ScheduleTimer(function()
                RealUI.ModuleFramework:EnableModule(moduleName)
            end, 1)
            return true
        end
        return false
    end)
end

-- Recover from profile corruption
function ErrorRecovery:RecoverProfileCorruption()
    return self:AttemptRecovery(ERROR_TYPES.PROFILE_CORRUPTION, nil, function()
        -- Try to restore from backup
        if RealUI.ProfileManager and RealUI.ProfileManager:HasBackups() then
            local success = RealUI.ProfileManager:RestoreBackup(1)
            if success then
                return true
            end
        end

        -- Fall back to default profile
        if RealUI.db then
            RealUI.db:ResetProfile()
            return true
        end

        return false
    end)
end

-- Recover from layout switch failure
function ErrorRecovery:RecoverLayoutSwitch(layoutId)
    return self:AttemptRecovery(ERROR_TYPES.LAYOUT_SWITCH, nil, function()
        -- Try to switch to the other layout
        local alternateLayout = layoutId == 1 and 2 or 1
        if RealUI.LayoutManager then
            return RealUI.LayoutManager:SwitchToLayout(alternateLayout)
        end
        return false
    end)
end

-- Recover from database errors
function ErrorRecovery:RecoverDatabaseError()
    return self:AttemptRecovery(ERROR_TYPES.DATABASE_ERROR, nil, function()
        -- Try to reinitialize the database
        if RealUI.db then
            local defaults = RealUI.ProfileSystem and RealUI.ProfileSystem:GetDatabaseDefaults()
            if defaults then
                -- Restore critical defaults
                for key, value in pairs(defaults.global) do
                    if RealUI.db.global[key] == nil then
                        RealUI.db.global[key] = value
                    end
                end
                return true
            end
        end
        return false
    end)
end

-- Handle addon conflicts
function ErrorRecovery:HandleAddonConflict(conflictingAddon)
    debug("Handling addon conflict with", conflictingAddon)

    if RealUI.CompatibilityManager then
        return RealUI.CompatibilityManager:ResolveConflict(conflictingAddon)
    end

    return false
end

-- Handle resource exhaustion
function ErrorRecovery:HandleResourceExhaustion(resourceType)
    debug("Handling resource exhaustion:", resourceType)

    if resourceType == "memory" and RealUI.PerformanceMonitor then
        -- Force garbage collection
        RealUI.PerformanceMonitor:PerformGarbageCollection()

        -- Disable non-essential modules
        if RealUI.ModuleFramework then
            local modules = RealUI.ModuleFramework:GetRegisteredModules()
            for name, info in pairs(modules) do
                if info.type == "enhancement" and info.enabled then
                    RealUI.ModuleFramework:DisableModule(name)
                    debug("Disabled non-essential module:", name)
                end
            end
        end

        return true
    end

    return false
end

-- Graceful degradation
function ErrorRecovery:EnableSafeMode()
    debug("Enabling safe mode...")

    -- Disable all non-essential modules
    if RealUI.ModuleFramework then
        local modules = RealUI.ModuleFramework:GetRegisteredModules()
        for name, info in pairs(modules) do
            if info.type ~= "core" and info.enabled then
                RealUI.ModuleFramework:DisableModule(name)
            end
        end
    end

    -- Use minimal layout
    if RealUI.LayoutManager then
        RealUI.LayoutManager:SwitchToLayout(1)
    end

    -- Disable performance monitoring
    if RealUI.PerformanceMonitor then
        RealUI.PerformanceMonitor:StopMonitoring()
    end

    debug("Safe mode enabled")
    return true
end

-- Get error log
function ErrorRecovery:GetErrorLog()
    return errorLog
end

-- Get recent errors
function ErrorRecovery:GetRecentErrors(count)
    count = count or 10
    local recent = {}
    local startIndex = math.max(1, #errorLog - count + 1)

    for i = startIndex, #errorLog do
        table.insert(recent, errorLog[i])
    end

    return recent
end

-- Clear error log
function ErrorRecovery:ClearErrorLog()
    errorLog = {}
    recoveryAttempts = {}
    debug("Error log cleared")
end

-- Get recovery statistics
function ErrorRecovery:GetRecoveryStats()
    local stats = {
        totalErrors = #errorLog,
        recoveredErrors = 0,
        failedRecoveries = 0,
        errorsByType = {}
    }

    for _, error in ipairs(errorLog) do
        if error.recovered then
            stats.recoveredErrors = stats.recoveredErrors + 1
        else
            stats.failedRecoveries = stats.failedRecoveries + 1
        end

        if not stats.errorsByType[error.type] then
            stats.errorsByType[error.type] = 0
        end
        stats.errorsByType[error.type] = stats.errorsByType[error.type] + 1
    end

    return stats
end

-- Initialize error recovery system
function ErrorRecovery:Initialize()
    debug("Initializing error recovery system...")

    -- Set up global error handler
    local originalErrorHandler = _G.geterrorhandler()
    _G.seterrorhandler(function(err)
        -- Log the error
        self:LogError("lua_error", "global", tostring(err), debugstack())

        -- Call original handler
        if originalErrorHandler then
            originalErrorHandler(err)
        end
    end)

    debug("Error recovery system initialized")
end

-- Expose ErrorRecovery to RealUI
RealUI.ErrorRecovery = ErrorRecovery
