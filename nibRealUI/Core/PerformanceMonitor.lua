local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs time table pcall collectgarbage GetTime GetFramerate

-- RealUI Performance Monitoring and Resource Management System
-- This system provides memory usage tracking, CPU monitoring, and resource cleanup
-- Implements performance alerts and garbage collection management

local RealUI = private.RealUI
local debug = RealUI.GetDebug("PerformanceMonitor")

local PerformanceMonitor = {}
RealUI.PerformanceMonitor = PerformanceMonitor

-- Performance Monitoring Configuration
local PERFORMANCE_CONFIG = {
    -- Monitoring intervals (in seconds)
    MEMORY_CHECK_INTERVAL = 30,
    CPU_CHECK_INTERVAL = 5,
    PERFORMANCE_ALERT_INTERVAL = 60,

    -- Thresholds for alerts
    MEMORY_WARNING_THRESHOLD = 50 * 1024 * 1024, -- 50MB in bytes
    MEMORY_CRITICAL_THRESHOLD = 100 * 1024 * 1024, -- 100MB in bytes
    CPU_WARNING_THRESHOLD = 10, -- 10ms per frame
    CPU_CRITICAL_THRESHOLD = 20, -- 20ms per frame
    FRAMERATE_WARNING_THRESHOLD = 30, -- FPS
    FRAMERATE_CRITICAL_THRESHOLD = 15, -- FPS

    -- Garbage collection settings
    GC_AUTOMATIC_THRESHOLD = 75 * 1024 * 1024, -- 75MB
    GC_FORCED_INTERVAL = 300, -- 5 minutes
    GC_STEP_SIZE = 200, -- Incremental GC step size

    -- History retention
    MAX_HISTORY_ENTRIES = 100,
    HISTORY_CLEANUP_INTERVAL = 600 -- 10 minutes
}

-- Performance Data Storage
local performanceData = {
    memory = {
        current = 0,
        peak = 0,
        history = {},
        lastCheck = 0,
        alerts = {}
    },
    cpu = {
        current = 0,
        average = 0,
        history = {},
        lastCheck = 0,
        frameTime = 0,
        alerts = {}
    },
    framerate = {
        current = 0,
        average = 0,
        history = {},
        lastCheck = 0,
        alerts = {}
    },
    modules = {},
    system = {
        initialized = false,
        monitoring = false,
        lastGC = 0,
        gcCount = 0,
        alertsEnabled = true
    }
}

-- Module-specific performance tracking
local modulePerformance = {}
local moduleResourceUsage = {}

-- Alert system
local alertCallbacks = {}
local alertHistory = {}

-- Timers and monitoring state
local monitoringTimers = {}
local isMonitoring = false

-- Performance Monitoring Core Functions

function PerformanceMonitor:Initialize()
    debug("Initializing PerformanceMonitor")

    if performanceData.system.initialized then
        debug("PerformanceMonitor already initialized")
        return true
    end

    -- Reset performance data
    self:ResetPerformanceData()

    -- Initialize module tracking
    self:InitializeModuleTracking()

    -- Mark as initialized
    performanceData.system.initialized = true
    performanceData.system.lastGC = GetTime()

    debug("PerformanceMonitor initialized successfully")
    return true
end

function PerformanceMonitor:ResetPerformanceData()
    performanceData.memory.current = 0
    performanceData.memory.peak = 0
    performanceData.memory.history = {}
    performanceData.memory.alerts = {}

    performanceData.cpu.current = 0
    performanceData.cpu.average = 0
    performanceData.cpu.history = {}
    performanceData.cpu.alerts = {}

    performanceData.framerate.current = 0
    performanceData.framerate.average = 0
    performanceData.framerate.history = {}
    performanceData.framerate.alerts = {}

    performanceData.modules = {}
end

function PerformanceMonitor:InitializeModuleTracking()
    modulePerformance = {}
    moduleResourceUsage = {}
end

-- Memory Usage Tracking

function PerformanceMonitor:GetMemoryUsage()
    -- Get addon memory usage in bytes
    _G.UpdateAddOnMemoryUsage()
    local memory = 0

    -- Sum up all RealUI addon memory
    for i = 1, _G.C_AddOns.GetNumAddOns() do
        local name = _G.C_AddOns.GetAddOnInfo(i)
        if name and (name:match("^RealUI") or name:match("^nibRealUI")) then
            memory = memory + (_G.GetAddOnMemoryUsage(i) * 1024) -- Convert KB to bytes
        end
    end

    return memory
end

function PerformanceMonitor:TrackMemoryUsage()
    local currentTime = GetTime()

    -- Check if enough time has passed since last check
    if currentTime - performanceData.memory.lastCheck < PERFORMANCE_CONFIG.MEMORY_CHECK_INTERVAL then
        return performanceData.memory.current
    end

    -- Get current memory usage
    local memory = self:GetMemoryUsage()
    performanceData.memory.current = memory
    performanceData.memory.lastCheck = currentTime

    -- Update peak memory
    if memory > performanceData.memory.peak then
        performanceData.memory.peak = memory
    end

    -- Add to history
    table.insert(performanceData.memory.history, {
        time = currentTime,
        value = memory
    })

    -- Trim history if needed
    self:TrimHistory(performanceData.memory.history)

    -- Check thresholds and trigger alerts
    self:CheckMemoryThresholds(memory)

    -- Trigger automatic garbage collection if needed
    self:CheckAutomaticGarbageCollection(memory)

    return memory
end

function PerformanceMonitor:CheckMemoryThresholds(memory)
    if not performanceData.system.alertsEnabled then
        return
    end

    local currentTime = GetTime()
    local lastAlert = performanceData.memory.alerts.lastAlert or 0

    -- Don't spam alerts
    if currentTime - lastAlert < PERFORMANCE_CONFIG.PERFORMANCE_ALERT_INTERVAL then
        return
    end

    if memory >= PERFORMANCE_CONFIG.MEMORY_CRITICAL_THRESHOLD then
        self:TriggerAlert("memory", "critical", memory)
        performanceData.memory.alerts.lastAlert = currentTime
    elseif memory >= PERFORMANCE_CONFIG.MEMORY_WARNING_THRESHOLD then
        self:TriggerAlert("memory", "warning", memory)
        performanceData.memory.alerts.lastAlert = currentTime
    end
end

-- CPU Usage Monitoring

function PerformanceMonitor:GetCPUUsage()
    -- Get addon CPU usage in milliseconds
    _G.UpdateAddOnCPUUsage()
    local cpu = 0

    -- Sum up all RealUI addon CPU time
    for i = 1, _G.C_AddOns.GetNumAddOns() do
        local name = _G.C_AddOns.GetAddOnInfo(i)
        if name and (name:match("^RealUI") or name:match("^nibRealUI")) then
            cpu = cpu + _G.GetAddOnCPUUsage(i)
        end
    end

    return cpu
end

function PerformanceMonitor:TrackCPUUsage()
    local currentTime = GetTime()

    -- Check if enough time has passed since last check
    if currentTime - performanceData.cpu.lastCheck < PERFORMANCE_CONFIG.CPU_CHECK_INTERVAL then
        return performanceData.cpu.current
    end

    -- Get current CPU usage
    local cpu = self:GetCPUUsage()
    performanceData.cpu.current = cpu
    performanceData.cpu.lastCheck = currentTime

    -- Calculate average
    local history = performanceData.cpu.history
    if #history > 0 then
        local sum = cpu
        for _, entry in ipairs(history) do
            sum = sum + entry.value
        end
        performanceData.cpu.average = sum / (#history + 1)
    else
        performanceData.cpu.average = cpu
    end

    -- Add to history
    table.insert(history, {
        time = currentTime,
        value = cpu
    })

    -- Trim history if needed
    self:TrimHistory(history)

    -- Check thresholds and trigger alerts
    self:CheckCPUThresholds(cpu)

    return cpu
end

function PerformanceMonitor:CheckCPUThresholds(cpu)
    if not performanceData.system.alertsEnabled then
        return
    end

    local currentTime = GetTime()
    local lastAlert = performanceData.cpu.alerts.lastAlert or 0

    -- Don't spam alerts
    if currentTime - lastAlert < PERFORMANCE_CONFIG.PERFORMANCE_ALERT_INTERVAL then
        return
    end

    if cpu >= PERFORMANCE_CONFIG.CPU_CRITICAL_THRESHOLD then
        self:TriggerAlert("cpu", "critical", cpu)
        performanceData.cpu.alerts.lastAlert = currentTime
    elseif cpu >= PERFORMANCE_CONFIG.CPU_WARNING_THRESHOLD then
        self:TriggerAlert("cpu", "warning", cpu)
        performanceData.cpu.alerts.lastAlert = currentTime
    end
end

-- Framerate Monitoring

function PerformanceMonitor:TrackFramerate()
    local currentTime = GetTime()
    local fps = GetFramerate()

    performanceData.framerate.current = fps
    performanceData.framerate.lastCheck = currentTime

    -- Calculate average
    local history = performanceData.framerate.history
    if #history > 0 then
        local sum = fps
        for _, entry in ipairs(history) do
            sum = sum + entry.value
        end
        performanceData.framerate.average = sum / (#history + 1)
    else
        performanceData.framerate.average = fps
    end

    -- Add to history
    table.insert(history, {
        time = currentTime,
        value = fps
    })

    -- Trim history if needed
    self:TrimHistory(history)

    -- Check thresholds and trigger alerts
    self:CheckFramerateThresholds(fps)

    return fps
end

function PerformanceMonitor:CheckFramerateThresholds(fps)
    if not performanceData.system.alertsEnabled then
        return
    end

    local currentTime = GetTime()
    local lastAlert = performanceData.framerate.alerts.lastAlert or 0

    -- Don't spam alerts
    if currentTime - lastAlert < PERFORMANCE_CONFIG.PERFORMANCE_ALERT_INTERVAL then
        return
    end

    if fps <= PERFORMANCE_CONFIG.FRAMERATE_CRITICAL_THRESHOLD then
        self:TriggerAlert("framerate", "critical", fps)
        performanceData.framerate.alerts.lastAlert = currentTime
    elseif fps <= PERFORMANCE_CONFIG.FRAMERATE_WARNING_THRESHOLD then
        self:TriggerAlert("framerate", "warning", fps)
        performanceData.framerate.alerts.lastAlert = currentTime
    end
end

-- Garbage Collection Management

function PerformanceMonitor:CheckAutomaticGarbageCollection(memory)
    if memory >= PERFORMANCE_CONFIG.GC_AUTOMATIC_THRESHOLD then
        debug("Memory threshold reached, triggering garbage collection")
        self:PerformGarbageCollection()
    end
end

function PerformanceMonitor:PerformGarbageCollection()
    local beforeMemory = self:GetMemoryUsage()
    local beforeTime = GetTime()

    -- Perform garbage collection
    collectgarbage("collect")

    local afterTime = GetTime()
    local afterMemory = self:GetMemoryUsage()
    local gcTime = (afterTime - beforeTime) * 1000 -- Convert to milliseconds
    local memoryFreed = beforeMemory - afterMemory

    performanceData.system.lastGC = afterTime
    performanceData.system.gcCount = performanceData.system.gcCount + 1

    debug(("Garbage collection completed: freed %.2f KB in %.2f ms"):format(
        memoryFreed / 1024,
        gcTime
    ))

    return memoryFreed, gcTime
end

function PerformanceMonitor:PerformIncrementalGarbageCollection()
    -- Perform incremental garbage collection step
    collectgarbage("step", PERFORMANCE_CONFIG.GC_STEP_SIZE)
end

function PerformanceMonitor:CheckForcedGarbageCollection()
    local currentTime = GetTime()
    local timeSinceLastGC = currentTime - performanceData.system.lastGC

    if timeSinceLastGC >= PERFORMANCE_CONFIG.GC_FORCED_INTERVAL then
        debug("Forced garbage collection interval reached")
        self:PerformGarbageCollection()
    end
end

-- Module Performance Tracking

function PerformanceMonitor:TrackModulePerformance(moduleName, startTime, endTime)
    if not modulePerformance[moduleName] then
        modulePerformance[moduleName] = {
            calls = 0,
            totalTime = 0,
            averageTime = 0,
            maxTime = 0,
            minTime = math.huge
        }
    end

    local execTime = (endTime - startTime) * 1000 -- Convert to milliseconds
    local stats = modulePerformance[moduleName]

    stats.calls = stats.calls + 1
    stats.totalTime = stats.totalTime + execTime
    stats.averageTime = stats.totalTime / stats.calls

    if execTime > stats.maxTime then
        stats.maxTime = execTime
    end
    if execTime < stats.minTime then
        stats.minTime = execTime
    end
end

function PerformanceMonitor:GetModulePerformance(moduleName)
    return modulePerformance[moduleName]
end

function PerformanceMonitor:GetAllModulePerformance()
    return modulePerformance
end

function PerformanceMonitor:TrackModuleResourceUsage(moduleName)
    _G.UpdateAddOnMemoryUsage()
    _G.UpdateAddOnCPUUsage()

    -- Find the addon index for this module
    for i = 1, _G.C_AddOns.GetNumAddOns() do
        local name = _G.C_AddOns.GetAddOnInfo(i)
        if name and name:match(moduleName) then
            local memory = _G.GetAddOnMemoryUsage(i) * 1024 -- Convert KB to bytes
            local cpu = _G.GetAddOnCPUUsage(i)

            if not moduleResourceUsage[moduleName] then
                moduleResourceUsage[moduleName] = {
                    memory = 0,
                    cpu = 0,
                    lastUpdate = 0
                }
            end

            moduleResourceUsage[moduleName].memory = memory
            moduleResourceUsage[moduleName].cpu = cpu
            moduleResourceUsage[moduleName].lastUpdate = GetTime()

            return memory, cpu
        end
    end

    return 0, 0
end

function PerformanceMonitor:GetModuleResourceUsage(moduleName)
    return moduleResourceUsage[moduleName]
end

-- Alert System

function PerformanceMonitor:RegisterAlertCallback(callback)
    table.insert(alertCallbacks, callback)
end

function PerformanceMonitor:TriggerAlert(alertType, severity, value)
    local alert = {
        type = alertType,
        severity = severity,
        value = value,
        time = GetTime()
    }

    -- Add to alert history
    table.insert(alertHistory, alert)

    -- Trim alert history
    if #alertHistory > PERFORMANCE_CONFIG.MAX_HISTORY_ENTRIES then
        table.remove(alertHistory, 1)
    end

    -- Call registered callbacks
    for _, callback in ipairs(alertCallbacks) do
        pcall(callback, alert)
    end

    -- Log the alert
    self:LogAlert(alert)
end

function PerformanceMonitor:LogAlert(alert)
    local message

    if alert.type == "memory" then
        message = ("Memory usage %s: %.2f MB"):format(
            alert.severity,
            alert.value / (1024 * 1024)
        )
    elseif alert.type == "cpu" then
        message = ("CPU usage %s: %.2f ms"):format(
            alert.severity,
            alert.value
        )
    elseif alert.type == "framerate" then
        message = ("Framerate %s: %.1f FPS"):format(
            alert.severity,
            alert.value
        )
    end

    if message then
        debug(message)
    end
end

function PerformanceMonitor:GetAlertHistory()
    return alertHistory
end

function PerformanceMonitor:ClearAlertHistory()
    alertHistory = {}
end

-- Monitoring Control

function PerformanceMonitor:StartMonitoring()
    if isMonitoring then
        debug("Monitoring already active")
        return false
    end

    debug("Starting performance monitoring")
    isMonitoring = true
    performanceData.system.monitoring = true

    -- Create monitoring timers
    monitoringTimers.memory = RealUI:ScheduleRepeatingTimer(
        function() self:TrackMemoryUsage() end,
        PERFORMANCE_CONFIG.MEMORY_CHECK_INTERVAL
    )

    monitoringTimers.cpu = RealUI:ScheduleRepeatingTimer(
        function() self:TrackCPUUsage() end,
        PERFORMANCE_CONFIG.CPU_CHECK_INTERVAL
    )

    monitoringTimers.framerate = RealUI:ScheduleRepeatingTimer(
        function() self:TrackFramerate() end,
        PERFORMANCE_CONFIG.CPU_CHECK_INTERVAL
    )

    monitoringTimers.gc = RealUI:ScheduleRepeatingTimer(
        function() self:CheckForcedGarbageCollection() end,
        60 -- Check every minute
    )

    monitoringTimers.cleanup = RealUI:ScheduleRepeatingTimer(
        function() self:CleanupHistory() end,
        PERFORMANCE_CONFIG.HISTORY_CLEANUP_INTERVAL
    )

    -- Perform initial tracking
    self:TrackMemoryUsage()
    self:TrackCPUUsage()
    self:TrackFramerate()

    return true
end

function PerformanceMonitor:StopMonitoring()
    if not isMonitoring then
        debug("Monitoring not active")
        return false
    end

    debug("Stopping performance monitoring")
    isMonitoring = false
    performanceData.system.monitoring = false

    -- Cancel all timers
    for name, timer in pairs(monitoringTimers) do
        RealUI:CancelTimer(timer)
    end
    monitoringTimers = {}

    return true
end

function PerformanceMonitor:IsMonitoring()
    return isMonitoring
end

function PerformanceMonitor:ToggleMonitoring()
    if isMonitoring then
        return self:StopMonitoring()
    else
        return self:StartMonitoring()
    end
end

-- Resource Cleanup

function PerformanceMonitor:CleanupHistory()
    self:TrimHistory(performanceData.memory.history)
    self:TrimHistory(performanceData.cpu.history)
    self:TrimHistory(performanceData.framerate.history)

    -- Cleanup old module performance data
    local currentTime = GetTime()
    for moduleName, usage in pairs(moduleResourceUsage) do
        if currentTime - usage.lastUpdate > PERFORMANCE_CONFIG.HISTORY_CLEANUP_INTERVAL then
            moduleResourceUsage[moduleName] = nil
        end
    end
end

function PerformanceMonitor:TrimHistory(history)
    while #history > PERFORMANCE_CONFIG.MAX_HISTORY_ENTRIES do
        table.remove(history, 1)
    end
end

function PerformanceMonitor:CleanupResources()
    debug("Cleaning up performance monitor resources")

    -- Stop monitoring
    self:StopMonitoring()

    -- Clear all data
    self:ResetPerformanceData()
    self:ClearAlertHistory()

    -- Clear module tracking
    modulePerformance = {}
    moduleResourceUsage = {}

    -- Perform garbage collection
    self:PerformGarbageCollection()
end

-- Data Retrieval

function PerformanceMonitor:GetPerformanceData()
    return {
        memory = {
            current = performanceData.memory.current,
            peak = performanceData.memory.peak,
            historyCount = #performanceData.memory.history
        },
        cpu = {
            current = performanceData.cpu.current,
            average = performanceData.cpu.average,
            historyCount = #performanceData.cpu.history
        },
        framerate = {
            current = performanceData.framerate.current,
            average = performanceData.framerate.average,
            historyCount = #performanceData.framerate.history
        },
        system = {
            monitoring = performanceData.system.monitoring,
            gcCount = performanceData.system.gcCount,
            lastGC = performanceData.system.lastGC
        }
    }
end

function PerformanceMonitor:GetMemoryData()
    return {
        current = performanceData.memory.current,
        peak = performanceData.memory.peak,
        history = performanceData.memory.history
    }
end

function PerformanceMonitor:GetCPUData()
    return {
        current = performanceData.cpu.current,
        average = performanceData.cpu.average,
        history = performanceData.cpu.history
    }
end

function PerformanceMonitor:GetFramerateData()
    return {
        current = performanceData.framerate.current,
        average = performanceData.framerate.average,
        history = performanceData.framerate.history
    }
end

-- Configuration

function PerformanceMonitor:SetAlertsEnabled(enabled)
    performanceData.system.alertsEnabled = enabled
    debug("Performance alerts", enabled and "enabled" or "disabled")
end

function PerformanceMonitor:AreAlertsEnabled()
    return performanceData.system.alertsEnabled
end

function PerformanceMonitor:SetMemoryThreshold(warning, critical)
    if warning then
        PERFORMANCE_CONFIG.MEMORY_WARNING_THRESHOLD = warning
    end
    if critical then
        PERFORMANCE_CONFIG.MEMORY_CRITICAL_THRESHOLD = critical
    end
end

function PerformanceMonitor:SetCPUThreshold(warning, critical)
    if warning then
        PERFORMANCE_CONFIG.CPU_WARNING_THRESHOLD = warning
    end
    if critical then
        PERFORMANCE_CONFIG.CPU_CRITICAL_THRESHOLD = critical
    end
end

function PerformanceMonitor:SetFramerateThreshold(warning, critical)
    if warning then
        PERFORMANCE_CONFIG.FRAMERATE_WARNING_THRESHOLD = warning
    end
    if critical then
        PERFORMANCE_CONFIG.FRAMERATE_CRITICAL_THRESHOLD = critical
    end
end

function PerformanceMonitor:GetConfiguration()
    return PERFORMANCE_CONFIG
end

-- Status and Diagnostics

function PerformanceMonitor:PrintStatus()
    local data = self:GetPerformanceData()

    print("=== RealUI Performance Monitor Status ===")
    print(("Monitoring: %s"):format(data.system.monitoring and "Active" or "Inactive"))
    print(("Memory: %.2f MB (Peak: %.2f MB)"):format(
        data.memory.current / (1024 * 1024),
        data.memory.peak / (1024 * 1024)
    ))
    print(("CPU: %.2f ms (Avg: %.2f ms)"):format(
        data.cpu.current,
        data.cpu.average
    ))
    print(("Framerate: %.1f FPS (Avg: %.1f FPS)"):format(
        data.framerate.current,
        data.framerate.average
    ))
    print(("Garbage Collections: %d (Last: %.1f seconds ago)"):format(
        data.system.gcCount,
        GetTime() - data.system.lastGC
    ))
    print(("Alert History: %d entries"):format(#alertHistory))
end

function PerformanceMonitor:IsInitialized()
    return performanceData.system.initialized
end

-- Utility Functions

function PerformanceMonitor:FormatBytes(bytes)
    if bytes >= 1024 * 1024 * 1024 then
        return ("%.2f GB"):format(bytes / (1024 * 1024 * 1024))
    elseif bytes >= 1024 * 1024 then
        return ("%.2f MB"):format(bytes / (1024 * 1024))
    elseif bytes >= 1024 then
        return ("%.2f KB"):format(bytes / 1024)
    else
        return ("%d B"):format(bytes)
    end
end

function PerformanceMonitor:FormatTime(milliseconds)
    if milliseconds >= 1000 then
        return ("%.2f s"):format(milliseconds / 1000)
    else
        return ("%.2f ms"):format(milliseconds)
    end
end
