local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("DeploymentValidator")

-- Deployment Validator
-- Validates RealUI is ready for deployment and handles final compatibility checks
local DeploymentValidator = {}
private.DeploymentValidator = DeploymentValidator

-- Validation state
local validationState = {
    validated = false,
    passed = false,
    warnings = {},
    errors = {}
}

-- Validation checks
local validationChecks = {
    {
        name = "Core Systems",
        check = function()
            local systems = {
                "ProfileSystem",
                "LayoutManager",
                "ModuleFramework",
                "HuDPositioning"
            }

            for _, system in ipairs(systems) do
                if not RealUI[system] then
                    return false, system .. " not initialized"
                end
            end

            return true
        end
    },
    {
        name = "Database Integrity",
        check = function()
            if not RealUI.db then
                return false, "Database not initialized"
            end

            if not RealUI.db.profile then
                return false, "Profile data missing"
            end

            if not RealUI.db.char then
                return false, "Character data missing"
            end

            if not RealUI.db.global then
                return false, "Global data missing"
            end

            return true
        end
    },
    {
        name = "Module Registration",
        check = function()
            if not RealUI.ModuleFramework then
                return false, "ModuleFramework not available"
            end

            -- Module registration is optional - just check if framework exists
            local modules = RealUI.ModuleFramework:GetRegisteredModules()
            debug("Registered modules count:", modules and #modules or 0)

            return true
        end
    },
    {
        name = "Library Dependencies",
        check = function()
            local libraries = {
                "AceAddon-3.0",
                "AceConsole-3.0",
                "AceEvent-3.0",
                "AceTimer-3.0",
                "AceDB-3.0",
                "LibDualSpec-1.0"
            }

            for _, lib in ipairs(libraries) do
                if not _G.LibStub:GetLibrary(lib, true) then
                    return false, lib .. " not found"
                end
            end

            return true
        end
    },
    {
        name = "Required Addons",
        check = function()
            local requiredAddons = {
                "RealUI_Skins",
                "RealUI_Bugs"
            }

            for _, addon in ipairs(requiredAddons) do
                if not _G.C_AddOns.IsAddOnLoaded(addon) then
                    return false, addon .. " not loaded"
                end
            end

            return true
        end
    },
    {
        name = "Version Information",
        check = function()
            if not RealUI.verinfo then
                return false, "Version info missing"
            end

            if not RealUI.verinfo.string then
                return false, "Version string missing"
            end

            if not RealUI.verinfo.build then
                return false, "Build info missing"
            end

            return true
        end
    }
}

-- Run validation checks
function DeploymentValidator:RunValidation()
    debug("Running deployment validation...")

    validationState.warnings = {}
    validationState.errors = {}
    validationState.passed = true

    for _, check in ipairs(validationChecks) do
        local success, result = check.check()

        if not success then
            table.insert(validationState.errors, {
                check = check.name,
                message = result
            })
            validationState.passed = false
            debug("Validation failed:", check.name, "-", result)
        else
            debug("Validation passed:", check.name)
        end
    end

    validationState.validated = true

    return validationState.passed, validationState.errors
end

-- Check addon compatibility
function DeploymentValidator:CheckAddonCompatibility()
    debug("Checking addon compatibility...")

    local compatibilityIssues = {}

    -- Check for known conflicting addons
    local knownConflicts = {
        {
            addon = "ElvUI",
            severity = "critical",
            message = "ElvUI conflicts with RealUI. Only one UI replacement should be active."
        },
        {
            addon = "TukUI",
            severity = "critical",
            message = "TukUI conflicts with RealUI. Only one UI replacement should be active."
        },
        {
            addon = "LUI",
            severity = "warning",
            message = "LUI may conflict with some RealUI features."
        }
    }

    for _, conflict in ipairs(knownConflicts) do
        if _G.C_AddOns.IsAddOnLoaded(conflict.addon) then
            table.insert(compatibilityIssues, conflict)
            debug("Compatibility issue detected:", conflict.addon)
        end
    end

    -- Use CompatibilityManager if available
    if RealUI.CompatibilityManager then
        local managerIssues = RealUI.CompatibilityManager:CheckCompatibility()
        for _, issue in ipairs(managerIssues) do
            table.insert(compatibilityIssues, issue)
        end
    end

    return compatibilityIssues
end

-- Validate version compatibility
function DeploymentValidator:ValidateVersionCompatibility()
    debug("Validating version compatibility...")

    local issues = {}

    -- Check game version
    local gameVersion = select(4, _G.GetBuildInfo())
    local minVersion = 120000 -- Minimum supported version

    if gameVersion < minVersion then
        table.insert(issues, {
            type = "game_version",
            severity = "critical",
            message = ("Game version %d is below minimum supported version %d"):format(gameVersion, minVersion)
        })
    end

    -- Check for TOC version mismatch
    if RealUI.db and RealUI.db.global then
        local savedTOC = RealUI.db.global.patchedTOC or 0
        local currentTOC = select(4, _G.GetBuildInfo())

        if savedTOC > 0 and savedTOC ~= currentTOC then
            table.insert(issues, {
                type = "toc_mismatch",
                severity = "warning",
                message = ("TOC version changed from %d to %d. Some features may need reconfiguration."):format(savedTOC, currentTOC)
            })
        end
    end

    return issues
end

-- Prepare for deployment
function DeploymentValidator:PrepareDeployment()
    debug("Preparing for deployment...")

    -- Update TOC version
    if RealUI.db and RealUI.db.global then
        RealUI.db.global.patchedTOC = select(4, _G.GetBuildInfo())
    end

    -- Create initial backup
    if RealUI.ProfileManager and not RealUI.ProfileManager:HasBackups() then
        RealUI.ProfileManager:CreateBackup("initial")
        debug("Created initial profile backup")
    end

    -- Validate all systems are ready
    local passed, errors = self:RunValidation()
    if not passed then
        debug("Deployment validation failed")
        return false, errors
    end

    -- Check compatibility
    local compatIssues = self:CheckAddonCompatibility()
    if #compatIssues > 0 then
        for _, issue in ipairs(compatIssues) do
            if issue.severity == "critical" then
                debug("Critical compatibility issue:", issue.message)
                return false, {issue}
            end
        end
    end

    -- Check version compatibility
    local versionIssues = self:ValidateVersionCompatibility()
    if #versionIssues > 0 then
        for _, issue in ipairs(versionIssues) do
            if issue.severity == "critical" then
                debug("Critical version issue:", issue.message)
                return false, {issue}
            end
        end
    end

    debug("Deployment preparation complete")
    return true
end

-- Generate deployment report
function DeploymentValidator:GenerateDeploymentReport()
    local report = {
        timestamp = _G.date("%Y-%m-%d %H:%M:%S"),
        version = RealUI.verinfo.string,
        build = RealUI.verinfo.build,
        gameVersion = RealUI.verinfo.gameVersion,
        validated = validationState.validated,
        passed = validationState.passed,
        errors = validationState.errors,
        warnings = validationState.warnings,
        compatibility = self:CheckAddonCompatibility(),
        versionIssues = self:ValidateVersionCompatibility()
    }

    return report
end

-- Print deployment report
function DeploymentValidator:PrintDeploymentReport()
    local report = self:GenerateDeploymentReport()

    _G.print("|cFF00A0FF=== RealUI Deployment Report ===|r")
    _G.print(("Version: %s (Build: %s)"):format(report.version, report.build))
    _G.print(("Game Version: %s"):format(report.gameVersion))
    _G.print(("Validation: %s"):format(report.passed and "|cFF00FF00PASSED|r" or "|cFFFF0000FAILED|r"))

    if #report.errors > 0 then
        _G.print("|cFFFF0000Errors:|r")
        for _, error in ipairs(report.errors) do
            _G.print(("  - %s: %s"):format(error.check, error.message))
        end
    end

    if #report.warnings > 0 then
        _G.print("|cFFFFFF00Warnings:|r")
        for _, warning in ipairs(report.warnings) do
            _G.print(("  - %s"):format(warning.message or warning))
        end
    end

    if #report.compatibility > 0 then
        _G.print("|cFFFFFF00Compatibility Issues:|r")
        for _, issue in ipairs(report.compatibility) do
            _G.print(("  - %s: %s"):format(issue.addon, issue.message))
        end
    end

    _G.print("|cFF00A0FF================================|r")
end

-- Initialize deployment validator
function DeploymentValidator:Initialize()
    debug("Initializing deployment validator...")

    -- Run initial validation
    local passed, errors = self:RunValidation()

    if not passed then
        debug("Validation failed with errors:")
        for _, error in ipairs(errors) do
            debug("  -", error.check, ":", error.message)
            _G.print("|cFFFF0000RealUI Validation Error:|r", error.check, "-", error.message)
        end
    end

    -- Prepare for deployment
    local success, prepErrors = self:PrepareDeployment()

    if not success then
        debug("Deployment preparation failed")
        if RealUI.FeedbackSystem then
            RealUI.FeedbackSystem:ShowError("Deployment Error", "RealUI failed deployment validation. Check chat for details.")
        end
    else
        debug("Deployment validator initialized successfully")
    end

    return success
end

-- Get validation state
function DeploymentValidator:GetValidationState()
    return validationState
end

-- Expose DeploymentValidator to RealUI
RealUI.DeploymentValidator = DeploymentValidator
