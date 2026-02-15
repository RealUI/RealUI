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
    lastOptimization = 0
}

-- Resource thresholds
local THRESHOLDS = {
    MEMORY_WARNING = 50 * 1024, -- 50 MB
    MEMORY_CRITICAL = 100 * 1024, -- 100 MB
    CPU_WARNING = 50, -- 50ms per frame
    CPU_CRITICAL = 100, -- 100ms per frame
    GC_INTERVAL = 300, -- 5 minutes
    OPTIMIZATION_INTERVAL = 600 -- 10 minutes
}

-- Get current memory usage
function ResourceManager:GetMemoryUsage()
    _G.UpdateAddOnMemoryUsage()
    local memory = _G.GetAddOnMemoryUsage(ADDON_NAME)

    -- Add memory from related addons
    local relatedAddons = {
        "nibRealUI_Config",
        "RealUI_Bugs",
        "RealUI_Chat",
        "RealUI_CombatText",
        "RealUI_Inventory",
        "RealUI_Skins",
        "RealUI_Tooltips"
    }

    for _, addon in ipairs(relatedAddons) do
        if _G.C_AddOns.IsAddOnLoaded(addon) then
            memory = memory + _G.GetAddOnMemoryUsage(addon)
        end
    end

    resourceState.memoryUsage = memory
    return memory
end

-- Get current CPU usage
function ResourceManager:GetCPUUsage()
    _G.UpdateAddOnCPUUsage()
    local cpu = _G.GetAddOnCPUUsage(ADDON_NAME)

    -- Add CPU from related addons
    local relatedAddons = {
        "nibRealUI_Config",
        "RealUI_Bugs",
        "RealUI_Chat",
        "RealUI_CombatText",
        "RealUI_Inventory",
        "RealUI_Skins",
        "RealUI_Tooltips"
    }

    for _, addon in ipairs(relatedAddons) do
        if _G.C_AddOns.IsAddOnLoaded(addon) then
            cpu = cpu + _G.GetAddOnCPUUsage(addon)
        end
    end

    resourceState.cpuUsage = cpu
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

    -- Perform garbage collection if needed
    if currentTime - resourceState.lastGC >= THRESHOLDS.GC_INTERVAL then
        self:PerformGarbageCollection()
    end

    -- Optimize module loading
    if RealUI.ModuleFramework then
        RealUI.ModuleFramework:OptimizeModuleLoading()
    end

    -- Optimize frame updates
    if RealUI.HuDPositioning then
        RealUI.HuDPositioning:OptimizeFrameUpdates()
    end

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
    if RealUI.PerformanceMonitor then
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
        if RealUI.FeedbackSystem then
            local message = ("High %s usage detected: %.2f %s"):format(
                warning.type,
                warning.value,
                warning.type == "memory" and "KB" or "ms"
            )
            RealUI.FeedbackSystem:ShowWarning("Resource Warning", message)
        end

        -- Attempt automatic recovery
        if warning.type == "memory" then
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

    -- Monitor resources every 30 seconds
    RealUI:ScheduleRepeatingTimer(function()
        self:CheckThresholds()
    end, 30)

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

    -- Start monitoring
    self:StartMonitoring()

    -- Perform initial optimization
    self:OptimizeResources()

    debug("Resource manager initialized")
end

-- Expose ResourceManager to RealUI
RealUI.ResourceManager = ResourceManager
