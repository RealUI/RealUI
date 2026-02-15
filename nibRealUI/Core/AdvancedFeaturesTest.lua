local ADDON_NAME, private = ...

-- Test for Advanced Features (Task 9)
-- Tests ResolutionOptimizer, CompatibilityManager, and ProfileManager

local RealUI = private.RealUI
local debug = RealUI.GetDebug("AdvancedFeaturesTest")

-- Test Resolution Optimizer
local function TestResolutionOptimizer()
    local optimizer = RealUI.ResolutionOptimizer
    if not optimizer then
        debug("ResolutionOptimizer not available")
        return false
    end

    debug("Testing ResolutionOptimizer...")

    -- Test resolution detection
    local width, height = optimizer:GetScreenDimensions()
    debug("Screen dimensions:", width, "x", height)

    -- Test resolution category
    local category = optimizer:GetResolutionCategory()
    debug("Resolution category:", category)

    -- Test resolution checks
    debug("Is low resolution:", optimizer:IsLowResolution())
    debug("Is high resolution:", optimizer:IsHighResolution())
    debug("Is ultra high resolution:", optimizer:IsUltraHighResolution())

    -- Test optimization profile
    local profile, cat = optimizer:GetOptimizationProfile()
    if profile then
        debug("Optimization profile:", profile.description)
        debug("HuD size:", profile.hudSize)
        debug("Scale multiplier:", profile.scaleMultiplier)
    end

    -- Test status
    local status = optimizer:GetStatus()
    debug("Optimization applied:", status.optimizationApplied)

    debug("ResolutionOptimizer tests completed")
    return true
end

-- Test Compatibility Manager
local function TestCompatibilityManager()
    local compat = RealUI.CompatibilityManager
    if not compat then
        debug("CompatibilityManager not available")
        return false
    end

    debug("Testing CompatibilityManager...")

    -- Test addon detection
    local results = compat:CheckCompatibility()
    debug("Compatible addons:", #results.compatible)
    debug("Conflicts:", #results.conflicts)
    debug("Integrations:", #results.integrations)

    -- Test status
    local status = compat:GetStatus()
    debug("Compatibility checked:", status.compatibilityChecked)
    debug("Safe mode:", status.safeMode)
    debug("High severity conflicts:", #status.highSeverityConflicts)

    debug("CompatibilityManager tests completed")
    return true
end

-- Test Profile Manager
local function TestProfileManager()
    local profMgr = RealUI.ProfileManager
    if not profMgr then
        debug("ProfileManager not available")
        return false
    end

    debug("Testing ProfileManager...")

    -- Test status
    local status = profMgr:GetStatus()
    debug("Current profile:", status.currentProfile)
    debug("Backup count:", status.backupCount)
    debug("Max backups:", status.maxBackups)

    -- Test backup creation
    local success, backup = profMgr:CreateBackup("test")
    if success then
        debug("Backup created successfully:", backup.label)
    else
        debug("Backup creation failed:", backup)
    end

    -- Test backup list
    local backups = profMgr:GetBackups()
    debug("Available backups:", #backups)

    debug("ProfileManager tests completed")
    return true
end

-- Run all tests
local function RunAllTests()
    debug("=== Running Advanced Features Tests ===")

    local results = {
        resolutionOptimizer = TestResolutionOptimizer(),
        compatibilityManager = TestCompatibilityManager(),
        profileManager = TestProfileManager()
    }

    debug("=== Test Results ===")
    debug("ResolutionOptimizer:", results.resolutionOptimizer and "PASS" or "FAIL")
    debug("CompatibilityManager:", results.compatibilityManager and "PASS" or "FAIL")
    debug("ProfileManager:", results.profileManager and "PASS" or "FAIL")

    local allPassed = results.resolutionOptimizer and results.compatibilityManager and results.profileManager
    debug("Overall:", allPassed and "ALL TESTS PASSED" or "SOME TESTS FAILED")

    return allPassed
end

-- Register test command
if RealUI.RegisterChatCommand then
    RealUI:RegisterChatCommand(
        "testadvanced",
        function()
            RunAllTests()
        end
    )
end

-- Auto-run tests on initialization (optional, can be disabled)
-- Uncomment the line below to auto-run tests
-- RealUI:ScheduleTimer(RunAllTests, 5)
