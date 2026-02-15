-- RealUI Diagnostic and Troubleshooting Tools
-- Provides taint logging, performance monitoring, and system health checks

local _, private = ...

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

local DiagnosticTools = {}
private.DiagnosticTools = DiagnosticTools

-- Diagnostic state
local diagnosticState = {
    taintLoggingEnabled = false,
    performanceMonitoringActive = false,
    lastHealthCheck = 0,
    diagnosticHistory = {}
}

-- Initialize diagnostic tools
function DiagnosticTools:Initialize()
    self.initialized = true

    -- Check initial taint logging state
    diagnosticState.taintLoggingEnabled = (_G.GetCVar("taintLog") ~= "0")

    RealUI.Debug("DiagnosticTools", "Initialized")
end

-- Taint Logging Toggle
function DiagnosticTools:ToggleTaintLogging()
    local taintLog = _G.GetCVar("taintLog")
    local newValue = (taintLog ~= "0") and "0" or "2"
    _G.SetCVar("taintLog", newValue)

    diagnosticState.taintLoggingEnabled = (newValue ~= "0")

    local message = diagnosticState.taintLoggingEnabled
        and "Taint logging enabled. UI will reload."
        or "Taint logging disabled. UI will reload."

    if RealUI.FeedbackSystem then
        RealUI.FeedbackSystem:ShowFeedback("info", "Taint Logging", message)
    else
        print(message)
    end

    _G.ReloadUI()
end

function DiagnosticTools:IsTaintLoggingEnabled()
    return diagnosticState.taintLoggingEnabled
end

-- Performance Monitoring Commands
function DiagnosticTools:StartPerformanceMonitoring()
    if RealUI.PerformanceMonitor then
        local success = RealUI.PerformanceMonitor:StartMonitoring()
        diagnosticState.performanceMonitoringActive = success
        return success
    end
    return false
end

function DiagnosticTools:StopPerformanceMonitoring()
    if RealUI.PerformanceMonitor then
        local success = RealUI.PerformanceMonitor:StopMonitoring()
        if success then
            diagnosticState.performanceMonitoringActive = false
        end
        return success
    end
    return false
end

function DiagnosticTools:GetPerformanceStatus()
    if RealUI.PerformanceMonitor then
        return RealUI.PerformanceMonitor:GetMonitoringState()
    end
    return nil
end

-- System Health Check
function DiagnosticTools:PerformHealthCheck()
    local healthReport = {
        timestamp = time(),
        checks = {},
        overallStatus = "healthy",
        warnings = {},
        errors = {}
    }

    -- Check 1: Memory Usage
    local memoryUsage = _G.collectgarbage("count")
    healthReport.checks.memory = {
        name = "Memory Usage",
        value = memoryUsage,
        unit = "KB",
        status = memoryUsage < 50000 and "good" or (memoryUsage < 100000 and "warning" or "critical")
    }
    if healthReport.checks.memory.status ~= "good" then
        table.insert(healthReport.warnings, "High memory usage detected")
    end

    -- Check 2: Frame Rate
    local fps = _G.GetFramerate()
    healthReport.checks.framerate = {
        name = "Frame Rate",
        value = fps,
        unit = "FPS",
        status = fps > 30 and "good" or (fps > 15 and "warning" or "critical")
    }
    if healthReport.checks.framerate.status ~= "good" then
        table.insert(healthReport.warnings, "Low frame rate detected")
    end

    -- Check 3: Addon Count
    local addonCount = _G.C_AddOns.GetNumAddOns()
    local enabledCount = 0
    for i = 1, addonCount do
        if _G.C_AddOns.GetAddOnEnableState(i) > 0 then
            enabledCount = enabledCount + 1
        end
    end
    healthReport.checks.addons = {
        name = "Enabled Addons",
        value = enabledCount,
        total = addonCount,
        status = enabledCount < 50 and "good" or (enabledCount < 100 and "warning" or "critical")
    }

    -- Check 4: Database Integrity
    if RealUI.db then
        local hasProfile = RealUI.db.profile ~= nil
        local hasChar = RealUI.db.char ~= nil
        local hasGlobal = RealUI.db.global ~= nil

        healthReport.checks.database = {
            name = "Database Integrity",
            hasProfile = hasProfile,
            hasChar = hasChar,
            hasGlobal = hasGlobal,
            status = (hasProfile and hasChar and hasGlobal) and "good" or "critical"
        }

        if healthReport.checks.database.status ~= "good" then
            table.insert(healthReport.errors, "Database corruption detected")
        end
    end

    -- Check 5: Module Status
    if RealUI.ModuleFramework then
        local frameworkStatus = RealUI.ModuleFramework:GetFrameworkStatus()
        healthReport.checks.modules = {
            name = "Module Framework",
            initialized = frameworkStatus.initialized,
            totalModules = frameworkStatus.totalModules,
            enabledModules = frameworkStatus.enabledModules,
            status = frameworkStatus.initialized and "good" or "critical"
        }
    end

    -- Check 6: Taint Status
    healthReport.checks.taint = {
        name = "Taint Logging",
        enabled = diagnosticState.taintLoggingEnabled,
        status = "info"
    }

    -- Determine overall status
    for _, check in pairs(healthReport.checks) do
        if check.status == "critical" then
            healthReport.overallStatus = "critical"
            break
        elseif check.status == "warning" and healthReport.overallStatus ~= "critical" then
            healthReport.overallStatus = "warning"
        end
    end

    -- Store in history
    diagnosticState.lastHealthCheck = time()
    table.insert(diagnosticState.diagnosticHistory, 1, healthReport)

    -- Trim history
    while #diagnosticState.diagnosticHistory > 10 do
        table.remove(diagnosticState.diagnosticHistory)
    end

    return healthReport
end

-- Print health check results
function DiagnosticTools:PrintHealthCheck()
    local report = self:PerformHealthCheck()

    print("=== RealUI System Health Check ===")
    print(("Overall Status: %s"):format(report.overallStatus:upper()))
    print("")

    for key, check in pairs(report.checks) do
        if check.value then
            print(("%s: %s %s [%s]"):format(
                check.name,
                tostring(check.value),
                check.unit or "",
                check.status:upper()
            ))
        else
            print(("%s: [%s]"):format(check.name, check.status:upper()))
        end
    end

    if #report.warnings > 0 then
        print("")
        print("Warnings:")
        for _, warning in ipairs(report.warnings) do
            print("  - " .. warning)
        end
    end

    if #report.errors > 0 then
        print("")
        print("Errors:")
        for _, error in ipairs(report.errors) do
            print("  - " .. error)
        end
    end
end

-- System Status Reporting
function DiagnosticTools:GetSystemStatus()
    local status = {
        version = RealUI.verinfo.string,
        build = RealUI.verinfo.build,
        gameVersion = RealUI.verinfo.gameVersion,
        isRetail = RealUI.isRetail,
        initialized = RealUI.isInitialized,
        enabled = RealUI.isEnabled,
        layout = RealUI.cLayout,
        installStage = RealUI.db and RealUI.db.char.init.installStage or "unknown"
    }

    -- Add performance data if available
    if RealUI.PerformanceMonitor then
        local perfState = RealUI.PerformanceMonitor:GetMonitoringState()
        status.performance = {
            monitoring = perfState.monitoring,
            memoryUsage = perfState.memoryUsage,
            cpuUsage = perfState.cpuUsage
        }
    end

    -- Add module data if available
    if RealUI.ModuleFramework then
        local frameworkStatus = RealUI.ModuleFramework:GetFrameworkStatus()
        status.modules = {
            initialized = frameworkStatus.initialized,
            total = frameworkStatus.totalModules,
            enabled = frameworkStatus.enabledModules
        }
    end

    return status
end

function DiagnosticTools:PrintSystemStatus()
    local status = self:GetSystemStatus()

    print("=== RealUI System Status ===")
    print(("Version: %s (Build: %s)"):format(status.version, status.build))
    print(("Game Version: %s"):format(status.gameVersion))
    print(("Retail: %s"):format(tostring(status.isRetail)))
    print(("Initialized: %s"):format(tostring(status.initialized)))
    print(("Enabled: %s"):format(tostring(status.enabled)))
    print(("Current Layout: %d"):format(status.layout))
    print(("Install Stage: %s"):format(tostring(status.installStage)))

    if status.performance then
        print("")
        print("Performance:")
        print(("  Monitoring: %s"):format(tostring(status.performance.monitoring)))
        if status.performance.memoryUsage then
            print(("  Memory: %s"):format(status.performance.memoryUsage))
        end
        if status.performance.cpuUsage then
            print(("  CPU: %s"):format(status.performance.cpuUsage))
        end
    end

    if status.modules then
        print("")
        print("Modules:")
        print(("  Initialized: %s"):format(tostring(status.modules.initialized)))
        print(("  Total: %d"):format(status.modules.total))
        print(("  Enabled: %d"):format(status.modules.enabled))
    end
end

-- Diagnostic Commands
function DiagnosticTools:RunDiagnostic(diagnosticType)
    if diagnosticType == "health" then
        self:PrintHealthCheck()
    elseif diagnosticType == "status" then
        self:PrintSystemStatus()
    elseif diagnosticType == "performance" then
        if RealUI.PerformanceMonitor then
            RealUI.PerformanceMonitor:PrintStatus()
        else
            print("Performance Monitor not available")
        end
    elseif diagnosticType == "modules" then
        if RealUI.ModuleFramework then
            local modules = RealUI.ModuleFramework:GetRegisteredModules()
            print("=== Module Status ===")
            for name, info in pairs(modules) do
                print(("%s: %s [%s]"):format(name, info.state, info.type))
            end
        else
            print("Module Framework not available")
        end
    elseif diagnosticType == "all" then
        self:PrintSystemStatus()
        print("")
        self:PrintHealthCheck()
    else
        print("Unknown diagnostic type. Available: health, status, performance, modules, all")
    end
end

-- Get diagnostic history
function DiagnosticTools:GetDiagnosticHistory(count)
    count = count or 5
    local history = {}
    for i = 1, math.min(count, #diagnosticState.diagnosticHistory) do
        table.insert(history, diagnosticState.diagnosticHistory[i])
    end
    return history
end

-- Clear diagnostic history
function DiagnosticTools:ClearDiagnosticHistory()
    diagnosticState.diagnosticHistory = {}
end

-- Export diagnostic report
function DiagnosticTools:ExportDiagnosticReport()
    local report = {
        timestamp = date("%Y-%m-%d %H:%M:%S", time()),
        systemStatus = self:GetSystemStatus(),
        healthCheck = self:PerformHealthCheck(),
        history = self:GetDiagnosticHistory(5)
    }

    -- Convert to string for easy copying
    local reportStr = "=== RealUI Diagnostic Report ===\n"
    reportStr = reportStr .. "Generated: " .. report.timestamp .. "\n\n"
    reportStr = reportStr .. "System Status:\n"
    reportStr = reportStr .. "  Version: " .. report.systemStatus.version .. "\n"
    reportStr = reportStr .. "  Build: " .. report.systemStatus.build .. "\n"
    reportStr = reportStr .. "  Layout: " .. report.systemStatus.layout .. "\n\n"
    reportStr = reportStr .. "Health Check:\n"
    reportStr = reportStr .. "  Overall: " .. report.healthCheck.overallStatus .. "\n"

    for key, check in pairs(report.healthCheck.checks) do
        if check.value then
            reportStr = reportStr .. ("  %s: %s %s [%s]\n"):format(
                check.name,
                tostring(check.value),
                check.unit or "",
                check.status
            )
        end
    end

    print(reportStr)
    return report
end

-- Register with RealUI
RealUI.DiagnosticTools = DiagnosticTools
