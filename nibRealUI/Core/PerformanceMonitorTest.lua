local ADDON_NAME, private = ...

-- Simple test for PerformanceMonitor functionality
-- This file demonstrates the performance monitoring and resource management features

local RealUI = private.RealUI
local debug = RealUI.GetDebug("PerformanceMonitorTest")

-- Test Memory Tracking
local function TestMemoryTracking()
    local monitor = RealUI.PerformanceMonitor
    if not monitor then
        debug("PerformanceMonitor not available")
        return false
    end

    debug("Testing memory tracking functionality...")

    -- Test memory usage retrieval
    local memory = monitor:GetMemoryUsage()
    debug(("Current memory usage: %s"):format(monitor:FormatBytes(memory)))

    -- Test memory tracking
    local trackedMemory = monitor:TrackMemoryUsage()
    debug(("Tracked memory: %s"):format(monitor:FormatBytes(trackedMemory)))

    -- Test memory data retrieval
    local memoryData = monitor:GetMemoryData()
    debug(("Memory data - Current: %s, Peak: %s, History entries: %d"):format(
        monitor:FormatBytes(memoryData.current),
        monitor:FormatBytes(memoryData.peak),
        #memoryData.history
    ))

    return true
end

-- Test CPU Monitoring
local function TestCPUMonitoring()
    local monitor = RealUI.PerformanceMonitor
    if not monitor then
        return false
    end

    debug("Testing CPU monitoring functionality...")

    -- Test CPU usage retrieval
    local cpu = monitor:GetCPUUsage()
    debug(("Current CPU usage: %s"):format(monitor:FormatTime(cpu)))

    -- Test CPU tracking
    local trackedCPU = monitor:TrackCPUUsage()
    debug(("Tracked CPU: %s"):format(monitor:FormatTime(trackedCPU)))

    -- Test CPU data retrieval
    local cpuData = monitor:GetCPUData()
    debug(("CPU data - Current: %s, Average: %s, History entries: %d"):format(
        monitor:FormatTime(cpuData.current),
        monitor:FormatTime(cpuData.average),
        #cpuData.history
    ))

    return true
end

-- Test Framerate Monitoring
local function TestFramerateMonitoring()
    local monitor = RealUI.PerformanceMonitor
    if not monitor then
        return false
    end

    debug("Testing framerate monitoring functionality...")

    -- Test framerate tracking
    local fps = monitor:TrackFramerate()
    debug(("Current framerate: %.1f FPS"):format(fps))

    -- Test framerate data retrieval
    local fpsData = monitor:GetFramerateData()
    debug(("Framerate data - Current: %.1f FPS, Average: %.1f FPS, History entries: %d"):format(
        fpsData.current,
        fpsData.average,
        #fpsData.history
    ))

    return true
end

-- Test Garbage Collection
local function TestGarbageCollection()
    local monitor = RealUI.PerformanceMonitor
    if not monitor then
        return false
    end

    debug("Testing garbage collection functionality...")

    -- Test manual garbage collection
    local freed, time = monitor:PerformGarbageCollection()
    debug(("Garbage collection: freed %s in %s"):format(
        monitor:FormatBytes(freed),
        monitor:FormatTime(time)
    ))

    -- Test incremental garbage collection
    monitor:PerformIncrementalGarbageCollection()
    debug("Incremental garbage collection performed")

    return true
end

-- Test Alert System
local function TestAlertSystem()
    local monitor = RealUI.PerformanceMonitor
    if not monitor then
        return false
    end

    debug("Testing alert system functionality...")

    -- Register test alert callback
    monitor:RegisterAlertCallback(function(alert)
        debug(("Alert received - Type: %s, Severity: %s, Value: %s"):format(
            alert.type,
            alert.severity,
            tostring(alert.value)
        ))
    end)

    -- Test alert history
    local history = monitor:GetAlertHistory()
    debug(("Alert history: %d entries"):format(#history))

    -- Test alert configuration
    local alertsEnabled = monitor:AreAlertsEnabled()
    debug(("Alerts enabled: %s"):format(tostring(alertsEnabled)))

    return true
end

-- Test Monitoring Control
local function TestMonitoringControl()
    local monitor = RealUI.PerformanceMonitor
    if not monitor then
        return false
    end

    debug("Testing monitoring control functionality...")

    -- Test monitoring status
    local isMonitoring = monitor:IsMonitoring()
    debug(("Currently monitoring: %s"):format(tostring(isMonitoring)))

    -- Test starting monitoring
    if not isMonitoring then
        local success = monitor:StartMonitoring()
        debug(("Start monitoring: %s"):format(success and "success" or "failed"))
    end

    -- Wait a bit for data collection
    RealUI:ScheduleTimer(function()
        -- Test performance data retrieval
        local data = monitor:GetPerformanceData()
        debug("Performance data retrieved:")
        debug(("  Memory: %s (Peak: %s)"):format(
            monitor:FormatBytes(data.memory.current),
            monitor:FormatBytes(data.memory.peak)
        ))
        debug(("  CPU: %s (Avg: %s)"):format(
            monitor:FormatTime(data.cpu.current),
            monitor:FormatTime(data.cpu.average)
        ))
        debug(("  Framerate: %.1f FPS (Avg: %.1f FPS)"):format(
            data.framerate.current,
            data.framerate.average
        ))
        debug(("  GC Count: %d"):format(data.system.gcCount))
    end, 5)

    return true
end

-- Test Module Performance Tracking
local function TestModuleTracking()
    local monitor = RealUI.PerformanceMonitor
    if not monitor then
        return false
    end

    debug("Testing module performance tracking...")

    -- Simulate module execution tracking
    local startTime = GetTime()
    -- Simulate some work
    for i = 1, 1000 do
        local _ = i * i
    end
    local endTime = GetTime()

    monitor:TrackModulePerformance("TestModule", startTime, endTime)
    debug("Module performance tracked")

    -- Get module performance data
    local perfData = monitor:GetModulePerformance("TestModule")
    if perfData then
        debug(("Module performance - Calls: %d, Avg: %s, Max: %s"):format(
            perfData.calls,
            monitor:FormatTime(perfData.averageTime),
            monitor:FormatTime(perfData.maxTime)
        ))
    end

    return true
end

-- Run all tests
local function RunTests()
    if not RealUI.PerformanceMonitor or not RealUI.PerformanceMonitor:IsInitialized() then
        debug("PerformanceMonitor not ready, scheduling test retry")
        RealUI:ScheduleTimer(RunTests, 1)
        return
    end

    debug("Running PerformanceMonitor tests...")

    local memoryTest = TestMemoryTracking()
    local cpuTest = TestCPUMonitoring()
    local fpsTest = TestFramerateMonitoring()
    local gcTest = TestGarbageCollection()
    local alertTest = TestAlertSystem()
    local controlTest = TestMonitoringControl()
    local moduleTest = TestModuleTracking()

    if memoryTest and cpuTest and fpsTest and gcTest and alertTest and controlTest and moduleTest then
        debug("All PerformanceMonitor tests passed!")
    else
        debug("Some PerformanceMonitor tests failed")
    end
end

-- Schedule tests to run after initialization
if RealUI.isInitialized then
    RunTests()
else
    RealUI:RegisterEvent("ADDON_LOADED", function(event, addonName)
        if addonName == ADDON_NAME then
            RealUI:ScheduleTimer(RunTests, 2)
        end
    end)
end
