local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs collectgarbage

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("ResourceManager")

-- Resource Manager
-- Handles system-wide resource management and optimization
local ResourceManager = {}
private.ResourceManager = ResourceManager

-- Resource tracking
local resourceState = {
    memoryUsage = 0,
    cpuUsage = 0,
    frameCount = 0,
    lastGC = 0,
    lastOptimization = 0,
    memoryBackoffUntil = 0,
    cpuBackoffUntil = 0
}

-- Resource thresholds
local THRESHOLDS = {
    MEMORY_WARNING = 50 * 1024, -- 50 MB
    MEMORY_CRITICAL = 100 * 1024, -- 100 MB
    CPU_WARNING = 50, -- 50ms per frame
    CPU_CRITICAL = 100, -- 100ms per frame
    MEMORY_CHECK_INTERVAL = 120, -- 2 minutes
    CPU_CHECK_INTERVAL = 120, -- 2 minutes
    GC_INTERVAL = 300, -- 5 minutes
    OPTIMIZATION_INTERVAL = 600, -- 10 minutes
    FAILURE_BACKOFF_INTERVAL = 600 -- 10 minutes after expensive API failures
}

local RELATED_ADDONS = {
    "RealUI_Config",
    "RealUI_Bugs",
    "RealUI_Chat",
    "RealUI_CombatText",
    "RealUI_Inventory",
    "RealUI_Skins",
    "RealUI_Tooltips"
}

-- Get current memory usage
function ResourceManager:GetMemoryUsage()
    local now = _G.GetTime()

    if now < (resourceState.memoryBackoffUntil or 0) then
        return resourceState.memoryUsage
    end

    if now - (resourceState.lastMemoryCheck or 0) < THRESHOLDS.MEMORY_CHECK_INTERVAL then
        return resourceState.memoryUsage
    end

    local okUpdate = pcall(_G.UpdateAddOnMemoryUsage)
    if not okUpdate then
        debug("UpdateAddOnMemoryUsage failed; enabling temporary backoff")
        resourceState.memoryUsage = resourceState.memoryUsage > 0 and resourceState.memoryUsage or collectgarbage("count")
        resourceState.lastMemoryCheck = now
        resourceState.memoryBackoffUntil = now + THRESHOLDS.FAILURE_BACKOFF_INTERVAL
        return resourceState.memoryUsage
    end

    local okMain, memory = pcall(_G.GetAddOnMemoryUsage, ADDON_NAME)
    if not okMain then
        memory = collectgarbage("count")
    else
        for _, addon in ipairs(RELATED_ADDONS) do
            local okLoaded, loaded = pcall(_G.C_AddOns.IsAddOnLoaded, addon)
            if okLoaded and loaded then
                local okAddon, addonUsage = pcall(_G.GetAddOnMemoryUsage, addon)
                if okAddon and type(addonUsage) == "number" then
                    memory = memory + addonUsage
                end
            end
        end
    end

    resourceState.memoryUsage = memory
    resourceState.lastMemoryCheck = now
    return memory
end

-- Get current CPU usage
function ResourceManager:GetCPUUsage()
    if not resourceState.cpuMonitoringAvailable then
        local scriptProfile = _G.GetCVar and _G.GetCVar("scriptProfile")
        resourceState.cpuMonitoringAvailable = scriptProfile == "1"
    end

    if not resourceState.cpuMonitoringAvailable then
        resourceState.cpuUsage = 0
        return 0
    end

    local now = _G.GetTime()

    if now < (resourceState.cpuBackoffUntil or 0) then
        return resourceState.cpuUsage
    end

    if now - (resourceState.lastCPUCheck or 0) < THRESHOLDS.CPU_CHECK_INTERVAL then
        return resourceState.cpuUsage
    end

    local okUpdate = pcall(_G.UpdateAddOnCPUUsage)
    if not okUpdate then
        debug("UpdateAddOnCPUUsage failed; enabling temporary backoff")
        resourceState.cpuUsage = 0
        resourceState.lastCPUCheck = now
        resourceState.cpuBackoffUntil = now + THRESHOLDS.FAILURE_BACKOFF_INTERVAL
        return 0
    end

    local okMain, cpu = pcall(_G.GetAddOnCPUUsage, ADDON_NAME)
    if not okMain then
        cpu = 0
    else
        for _, addon in ipairs(RELATED_ADDONS) do
            local okLoaded, loaded = pcall(_G.C_AddOns.IsAddOnLoaded, addon)
            if okLoaded and loaded then
                local okAddon, addonUsage = pcall(_G.GetAddOnCPUUsage, addon)
                if okAddon and type(addonUsage) == "number" then
                    cpu = cpu + addonUsage
                end
            end
        end
    end

    resourceState.cpuUsage = cpu
    resourceState.lastCPUCheck = now
    return cpu
end

-- Perform garbage collection
function ResourceManager:PerformGarbageCollection()
    local beforeMemory = collectgarbage("count")
    local startTime = _G.debugprofilestop()

    collectgarbage("collect")

    local afterMemory = collectgarbage("count")
    local endTime = _G.debugprofilestop()

    local freed = beforeMemory - afterMemory
    local time = endTime - startTime

    resourceState.lastGC = _G.time()

    debug(("Garbage collection: freed %.2f KB in %.2f ms"):format(freed, time))

    return freed, time
end

-- Optimize resource usage
function ResourceManager:OptimizeResources()
    debug("Optimizing resource usage...")

    local currentTime = _G.time()

    -- Perform garbage collection if needed (skip during combat to respect Aurora's GC mode)
    if not RealUI.inCombat and currentTime - resourceState.lastGC >= THRESHOLDS.GC_INTERVAL then
        self:PerformGarbageCollection()
    end

    -- Note: OptimizeModuleLoading and OptimizeFrameUpdates methods
    -- are not implemented in ModuleFramework or HuDPositioning

    -- Clean up unused data
    self:CleanupUnusedData()

    resourceState.lastOptimization = currentTime
    debug("Resource optimization complete")
end

-- Clean up unused data
function ResourceManager:CleanupUnusedData()
    debug("Cleaning up unused data...")

    -- Clean up old error logs
    if RealUI.ErrorRecovery then
        local errorLog = RealUI.ErrorRecovery:GetErrorLog()
        if #errorLog > 100 then
            RealUI.ErrorRecovery:ClearErrorLog()
        end
    end

    -- Clean up old performance data
    if RealUI.PerformanceMonitor then -- luacheck: ignore
        -- Performance monitor handles its own cleanup
    end

    debug("Cleanup complete")
end

-- Check resource thresholds
function ResourceManager:CheckThresholds()
    local memory = self:GetMemoryUsage()
    local cpu = self:GetCPUUsage()

    local warnings = {}

    -- Check memory thresholds
    if memory >= THRESHOLDS.MEMORY_CRITICAL then
        table.insert(warnings, {
            type = "memory",
            level = "critical",
            value = memory,
            threshold = THRESHOLDS.MEMORY_CRITICAL
        })
    elseif memory >= THRESHOLDS.MEMORY_WARNING then
        table.insert(warnings, {
            type = "memory",
            level = "warning",
            value = memory,
            threshold = THRESHOLDS.MEMORY_WARNING
        })
    end

    -- Check CPU thresholds
    if cpu >= THRESHOLDS.CPU_CRITICAL then
        table.insert(warnings, {
            type = "cpu",
            level = "critical",
            value = cpu,
            threshold = THRESHOLDS.CPU_CRITICAL
        })
    elseif cpu >= THRESHOLDS.CPU_WARNING then
        table.insert(warnings, {
            type = "cpu",
            level = "warning",
            value = cpu,
            threshold = THRESHOLDS.CPU_WARNING
        })
    end

    -- Handle warnings
    for _, warning in ipairs(warnings) do
        self:HandleResourceWarning(warning)
    end

    return warnings
end

-- Handle resource warnings
function ResourceManager:HandleResourceWarning(warning)
    debug(("Resource %s: %s level (%.2f / %.2f)"):format(
        warning.type,
        warning.level,
        warning.value,
        warning.threshold
    ))

    -- Notify user if critical
    if warning.level == "critical" then
        if RealUI.FeedbackSystem and RealUI.FeedbackSystem.ShowWarning then
            local message = ("High %s usage detected: %.2f %s"):format(
                warning.type,
                warning.value,
                warning.type == "memory" and "KB" or "ms"
            )
            RealUI.FeedbackSystem:ShowWarning("Resource Warning", message)
        end

        -- Attempt automatic recovery (skip GC during combat to respect Aurora's GC mode)
        if warning.type == "memory" and not RealUI.inCombat then
            self:PerformGarbageCollection()

            -- If still critical, enable safe mode
            local newMemory = self:GetMemoryUsage()
            if newMemory >= THRESHOLDS.MEMORY_CRITICAL then
                if RealUI.ErrorRecovery then
                    RealUI.ErrorRecovery:EnableSafeMode()
                end
            end
        end
    end
end

-- Get resource statistics
function ResourceManager:GetResourceStats()
    return {
        memory = {
            current = self:GetMemoryUsage(),
            warning = THRESHOLDS.MEMORY_WARNING,
            critical = THRESHOLDS.MEMORY_CRITICAL
        },
        cpu = {
            current = self:GetCPUUsage(),
            warning = THRESHOLDS.CPU_WARNING,
            critical = THRESHOLDS.CPU_CRITICAL
        },
        gc = {
            lastRun = resourceState.lastGC,
            interval = THRESHOLDS.GC_INTERVAL
        },
        optimization = {
            lastRun = resourceState.lastOptimization,
            interval = THRESHOLDS.OPTIMIZATION_INTERVAL
        }
    }
end

-- Format bytes for display
function ResourceManager:FormatBytes(bytes)
    if bytes >= 1024 * 1024 then
        return ("%.2f MB"):format(bytes / 1024 / 1024)
    elseif bytes >= 1024 then
        return ("%.2f KB"):format(bytes / 1024)
    else
        return ("%d B"):format(bytes)
    end
end

-- Format time for display
function ResourceManager:FormatTime(ms)
    if ms >= 1000 then
        return ("%.2f s"):format(ms / 1000)
    else
        return ("%.2f ms"):format(ms)
    end
end

-- Start resource monitoring
function ResourceManager:StartMonitoring()
    debug("Starting resource monitoring...")

    -- Monitor resources at the same interval as the data refresh (2 minutes)
    -- The underlying GetMemoryUsage/GetCPUUsage calls are throttled to this
    -- interval anyway, so checking more often just wastes timer callbacks.
    RealUI:ScheduleRepeatingTimer(function()
        self:CheckThresholds()
    end, THRESHOLDS.MEMORY_CHECK_INTERVAL)

    -- Optimize resources periodically
    RealUI:ScheduleRepeatingTimer(function()
        if not RealUI.inCombat then
            self:OptimizeResources()
        end
    end, THRESHOLDS.OPTIMIZATION_INTERVAL)

    debug("Resource monitoring started")
end

-- Initialize resource manager
function ResourceManager:Initialize()
    debug("Initializing resource manager...")

    -- ResourceManager is gated behind the performanceMonitorEnabled setting
    -- (default: off).  Only start the repeating timers when the user has
    -- explicitly opted in via the Systems config panel.
    local settings = RealUI.db and RealUI.db.profile and RealUI.db.profile.settings
    if not (settings and settings.performanceMonitorEnabled == true) then
        debug("Resource monitoring disabled by settings.performanceMonitorEnabled")
        return
    end

    -- Start monitoring
    self:StartMonitoring()

    -- Perform initial optimization
    self:OptimizeResources()

    debug("Resource manager initialized")
end

-- Expose ResourceManager to RealUI
RealUI.ResourceManager = ResourceManager
