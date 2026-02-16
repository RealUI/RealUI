local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("CompatibilityManager")

-- Compatibility and Integration System
-- Handles external addon compatibility detection
-- Provides graceful handling of conflicting addons
-- Implements safe mode operation for problematic environments

local CompatibilityManager = RealUI:NewModule("CompatibilityManager", "AceEvent-3.0", "AceTimer-3.0")

-- Known addon compatibility database
local ADDON_COMPATIBILITY = {
    -- Compatible addons (no conflicts)
    compatible = {
        "DBM-Core",
        "BigWigs",
        "WeakAuras",
        "Details",
        "Plater",
        "OmniCC",
        "Prat-3.0",
        "Bartender4",
        "Masque",
        "SharedMedia"
    },

    -- Conflicting addons (may cause issues)
    conflicts = {
        {
            name = "ElvUI",
            severity = "high",
            reason = "Complete UI replacement that conflicts with RealUI",
            recommendation = "Disable ElvUI to use RealUI"
        },
        {
            name = "TukUI",
            severity = "high",
            reason = "Complete UI replacement that conflicts with RealUI",
            recommendation = "Disable TukUI to use RealUI"
        },
        {
            name = "LUI",
            severity = "high",
            reason = "Complete UI replacement that conflicts with RealUI",
            recommendation = "Disable LUI to use RealUI"
        },
        {
            name = "Dominos",
            severity = "medium",
            reason = "Action bar addon that may conflict with RealUI action bars",
            recommendation = "Consider disabling if experiencing action bar issues"
        },
        {
            name = "MoveAnything",
            severity = "medium",
            reason = "Frame positioning addon that may conflict with RealUI positioning",
            recommendation = "Use RealUI's built-in frame mover instead"
        },
        {
            name = "Aurora",
            severity = "low",
            reason = "UI skin addon that may override RealUI styling",
            recommendation = "Can be used together but may cause visual inconsistencies"
        }
    },

    -- Addons that require special integration
    integration = {
        {
            name = "Grid2",
            handler = "IntegrateGrid2",
            description = "Raid frame addon with RealUI integration"
        },
        {
            name = "Clique",
            handler = "IntegrateClique",
            description = "Click-casting addon"
        },
        {
            name = "Skada",
            handler = "IntegrateSkada",
            description = "Damage meter with positioning integration"
        }
    }
}

-- Safe mode configuration
local SAFE_MODE_CONFIG = {
    disableModules = {
        "ActionBars",
        "CooldownCount",
        "EventNotifier"
    },
    minimalMode = true,
    skipOptimizations = true,
    description = "Safe mode disables potentially problematic modules"
}

function CompatibilityManager:OnInitialize()
    debug("CompatibilityManager:OnInitialize")

    self.db = RealUI.db
    self.detectedAddons = {}
    self.conflicts = {}
    self.integrations = {}
    self.safeMode = false
    self.compatibilityChecked = false

    -- Check compatibility on initialization
    self:ScheduleTimer(function()
        self:CheckCompatibility()
    end, 2.0)
end

-- Detect if an addon is loaded
function CompatibilityManager:IsAddonLoaded(addonName)
    return _G.C_AddOns.IsAddOnLoaded(addonName)
end

-- Get addon version
function CompatibilityManager:GetAddonVersion(addonName)
    return _G.C_AddOns.GetAddOnMetadata(addonName, "Version")
end

-- Check for compatible addons
function CompatibilityManager:DetectCompatibleAddons()
    local compatible = {}

    for _, addonName in ipairs(ADDON_COMPATIBILITY.compatible) do
        if self:IsAddonLoaded(addonName) then
            local version = self:GetAddonVersion(addonName)
            table.insert(compatible, {
                name = addonName,
                version = version,
                status = "compatible"
            })
            debug("Compatible addon detected:", addonName, version)
        end
    end

    return compatible
end

-- Check for conflicting addons
function CompatibilityManager:DetectConflicts()
    local conflicts = {}

    for _, conflict in ipairs(ADDON_COMPATIBILITY.conflicts) do
        if self:IsAddonLoaded(conflict.name) then
            local version = self:GetAddonVersion(conflict.name)
            table.insert(conflicts, {
                name = conflict.name,
                version = version,
                severity = conflict.severity,
                reason = conflict.reason,
                recommendation = conflict.recommendation
            })
            debug("Conflict detected:", conflict.name, "Severity:", conflict.severity)
        end
    end

    return conflicts
end

-- Check for addons requiring integration
function CompatibilityManager:DetectIntegrations()
    local integrations = {}

    for _, integration in ipairs(ADDON_COMPATIBILITY.integration) do
        if self:IsAddonLoaded(integration.name) then
            local version = self:GetAddonVersion(integration.name)
            table.insert(integrations, {
                name = integration.name,
                version = version,
                handler = integration.handler,
                description = integration.description,
                integrated = false
            })
            debug("Integration candidate detected:", integration.name)
        end
    end

    return integrations
end

-- Perform full compatibility check
function CompatibilityManager:CheckCompatibility()
    debug("Performing compatibility check")

    self.detectedAddons = self:DetectCompatibleAddons()
    self.conflicts = self:DetectConflicts()
    self.integrations = self:DetectIntegrations()
    self.compatibilityChecked = true

    -- Handle conflicts
    if #self.conflicts > 0 then
        self:HandleConflicts()
    end

    -- Perform integrations
    if #self.integrations > 0 then
        self:PerformIntegrations()
    end

    -- Log results
    debug("Compatibility check complete:")
    debug("- Compatible addons:", #self.detectedAddons)
    debug("- Conflicts:", #self.conflicts)
    debug("- Integrations:", #self.integrations)

    return {
        compatible = self.detectedAddons,
        conflicts = self.conflicts,
        integrations = self.integrations
    }
end

-- Handle detected conflicts
function CompatibilityManager:HandleConflicts()
    local highSeverityConflicts = {}

    for _, conflict in ipairs(self.conflicts) do
        if conflict.severity == "high" then
            table.insert(highSeverityConflicts, conflict)
        end
    end

    -- If high severity conflicts detected, consider safe mode
    if #highSeverityConflicts > 0 then
        debug("High severity conflicts detected, recommending safe mode")

        if RealUI.FeedbackSystem then
            local message = "Conflicting addons detected:\n"
            for _, conflict in ipairs(highSeverityConflicts) do
                message = message .. ("- %s: %s\n"):format(conflict.name, conflict.reason)
            end
            message = message .. "\nConsider enabling Safe Mode or disabling conflicting addons."

            RealUI.FeedbackSystem:ShowNotification(
                "Addon Conflicts Detected",
                message,
                "warning"
            )
        end
    end

    -- Log all conflicts
    for _, conflict in ipairs(self.conflicts) do
        debug(("Conflict: %s [%s] - %s"):format(
            conflict.name,
            conflict.severity,
            conflict.reason
        ))
    end
end

-- Perform addon integrations
function CompatibilityManager:PerformIntegrations()
    for _, integration in ipairs(self.integrations) do
        local handler = self[integration.handler]
        if handler then
            local success = handler(self, integration)
            integration.integrated = success
            debug(("Integration %s: %s"):format(
                integration.name,
                success and "success" or "failed"
            ))
        else
            debug("Integration handler not found:", integration.handler)
        end
    end
end

-- Integration handlers
function CompatibilityManager:IntegrateGrid2(integration)
    debug("Integrating Grid2")

    -- Grid2 integration logic
    if _G.Grid2 and RealUI.LayoutManager then
        -- Position Grid2 frames according to RealUI layout
        self:ScheduleTimer(function()
            if RealUI.FrameMover then
                -- Note: RegisterMoveableFrame requires frameInfo structure, not just a frame
                -- Skipping Grid2 frame registration for now
                debug("Grid2 frame registration skipped - requires proper frameInfo structure")
            end
        end, 1.0)

        return true
    end

    return false
end

function CompatibilityManager:IntegrateClique(integration)
    debug("Integrating Clique")

    -- Clique integration logic
    if _G.Clique then
        -- Clique is compatible, no special handling needed
        return true
    end

    return false
end

function CompatibilityManager:IntegrateSkada(integration)
    debug("Integrating Skada")

    -- Skada integration logic
    if _G.Skada and RealUI.FrameMover then
        self:ScheduleTimer(function()
            -- Register Skada windows with frame mover
            for _, window in ipairs(_G.Skada:GetWindows()) do
                if window.bargroup and window.bargroup.frame then
                    RealUI.FrameMover:RegisterFrame("Skada_" .. window.db.name, window.bargroup.frame)
                end
            end
        end, 2.0)

        return true
    end

    return false
end

-- Enable safe mode
function CompatibilityManager:EnableSafeMode()
    if self.safeMode then
        debug("Safe mode already enabled")
        return false
    end

    debug("Enabling safe mode")

    -- Disable problematic modules
    if RealUI.ModuleFramework then
        for _, moduleName in ipairs(SAFE_MODE_CONFIG.disableModules) do
            RealUI.ModuleFramework:DisableModule(moduleName)
            debug("Disabled module in safe mode:", moduleName)
        end
    end

    -- Set safe mode flag
    self.safeMode = true

    if self.db and self.db.global then
        self.db.global.safeMode = true
    end

    -- Notify user
    if RealUI.FeedbackSystem then
        RealUI.FeedbackSystem:ShowNotification(
            "Safe Mode Enabled",
            SAFE_MODE_CONFIG.description,
            "info"
        )
    end

    debug("Safe mode enabled")
    return true
end

-- Disable safe mode
function CompatibilityManager:DisableSafeMode()
    if not self.safeMode then
        debug("Safe mode not enabled")
        return false
    end

    debug("Disabling safe mode")

    -- Re-enable modules
    if RealUI.ModuleFramework then
        for _, moduleName in ipairs(SAFE_MODE_CONFIG.disableModules) do
            RealUI.ModuleFramework:EnableModule(moduleName)
            debug("Re-enabled module:", moduleName)
        end
    end

    -- Clear safe mode flag
    self.safeMode = false

    if self.db and self.db.global then
        self.db.global.safeMode = false
    end

    -- Notify user
    if RealUI.FeedbackSystem then
        RealUI.FeedbackSystem:ShowNotification(
            "Safe Mode Disabled",
            "All modules re-enabled",
            "info"
        )
    end

    debug("Safe mode disabled")
    return true
end

-- Check if safe mode is active
function CompatibilityManager:IsSafeModeActive()
    return self.safeMode
end

-- Get compatibility status
function CompatibilityManager:GetStatus()
    return {
        compatibilityChecked = self.compatibilityChecked,
        safeMode = self.safeMode,
        detectedAddons = #self.detectedAddons,
        conflicts = #self.conflicts,
        integrations = #self.integrations,
        highSeverityConflicts = self:GetHighSeverityConflicts()
    }
end

-- Get high severity conflicts
function CompatibilityManager:GetHighSeverityConflicts()
    local high = {}
    for _, conflict in ipairs(self.conflicts) do
        if conflict.severity == "high" then
            table.insert(high, conflict)
        end
    end
    return high
end

-- Print status to chat
function CompatibilityManager:PrintStatus()
    local status = self:GetStatus()

    print("=== Compatibility Manager Status ===")
    print(("Compatibility Checked: %s"):format(status.compatibilityChecked and "Yes" or "No"))
    print(("Safe Mode: %s"):format(status.safeMode and "Active" or "Inactive"))
    print(("Compatible Addons: %d"):format(status.detectedAddons))
    print(("Conflicts: %d"):format(status.conflicts))
    print(("Integrations: %d"):format(status.integrations))

    if #self.conflicts > 0 then
        print("\nDetected Conflicts:")
        for _, conflict in ipairs(self.conflicts) do
            print(("- %s [%s]: %s"):format(conflict.name, conflict.severity, conflict.reason))
        end
    end

    if #self.integrations > 0 then
        print("\nIntegrations:")
        for _, integration in ipairs(self.integrations) do
            print(("- %s: %s"):format(
                integration.name,
                integration.integrated and "Integrated" or "Pending"
            ))
        end
    end
end

-- Export for integration with other systems
RealUI.CompatibilityManager = CompatibilityManager
