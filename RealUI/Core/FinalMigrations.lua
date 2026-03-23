local ADDON_NAME, private = ... -- luacheck: ignore

-- Lua Globals --
-- luacheck: globals next type pairs

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("FinalMigrations")

-- Final Migrations System
-- Handles final version migrations and ensures smooth upgrades
local FinalMigrations = {}
private.FinalMigrations = FinalMigrations

-- Migration registry
local migrations = {}

-- Register a migration
function FinalMigrations:RegisterMigration(fromVersion, toVersion, migrationFunc, description)
    table.insert(migrations, {
        from = fromVersion,
        to = toVersion,
        func = migrationFunc,
        description = description
    })

    debug("Registered migration:", fromVersion, "->", toVersion)
end

-- Run pending migrations
function FinalMigrations:RunPendingMigrations(currentVersion, targetVersion)
    debug("Running pending migrations from", currentVersion, "to", targetVersion)

    local executed = {}
    local failed = {}

    for _, migration in ipairs(migrations) do
        -- Check if this migration should run
        if self:ShouldRunMigration(migration, currentVersion, targetVersion) then
            debug("Running migration:", migration.description)

            local success, err = pcall(migration.func)

            if success then
                table.insert(executed, migration)
                debug("Migration successful:", migration.description)
            else
                table.insert(failed, {
                    migration = migration,
                    error = err
                })
                debug("Migration failed:", migration.description, "-", err)
            end
        end
    end

    return executed, failed
end

-- Check if a migration should run
function FinalMigrations:ShouldRunMigration(migration, currentVersion, targetVersion)
    -- Simple version comparison
    -- In a real implementation, this would use proper version comparison
    return true
end

-- Register standard migrations
function FinalMigrations:RegisterStandardMigrations()
    -- Migration: Update layout positions for new HuD system
    self:RegisterMigration("2.6.0", "2.6.1", function()
        if RealUI.db and RealUI.db.profile.positions then
            -- Ensure all layouts have required position keys
            for layoutId = 1, 2 do
                local layout = RealUI.db.profile.positions[layoutId]
                if layout then
                    -- Add missing position keys with defaults
                    local defaults = RealUI.defaultPositions[layoutId]
                    for key, value in pairs(defaults) do
                        if layout[key] == nil then
                            layout[key] = value
                        end
                    end
                end
            end
        end
    end, "Update layout positions for new HuD system")

    -- Migration: Convert old module settings to new format
    self:RegisterMigration("2.6.0", "2.6.1", function()
        if RealUI.db and RealUI.db.profile.modules then
            -- Ensure all modules have boolean values
            for moduleName, enabled in pairs(RealUI.db.profile.modules) do
                if type(enabled) ~= "boolean" then
                    RealUI.db.profile.modules[moduleName] = true
                end
            end
        end
    end, "Convert old module settings to new format")

    -- Migration: Initialize new global settings
    self:RegisterMigration("2.6.0", "2.6.1", function()
        if RealUI.db and RealUI.db.global then
            -- Initialize hints_shown table
            if not RealUI.db.global.hints_shown then
                RealUI.db.global.hints_shown = {}
            end

            -- Initialize messages table
            if not RealUI.db.global.messages then
                RealUI.db.global.messages = {}
            end
        end
    end, "Initialize new global settings")

    -- Migration: Update character initialization data
    self:RegisterMigration("2.6.0", "2.6.1", function()
        if RealUI.db and RealUI.db.char and RealUI.db.char.init then
            -- Ensure all init fields exist
            if RealUI.db.char.init.installStage == nil then
                RealUI.db.char.init.installStage = -1
            end
            if RealUI.db.char.init.initialized == nil then
                RealUI.db.char.init.initialized = true
            end
            if RealUI.db.char.init.needchatmoved == nil then
                RealUI.db.char.init.needchatmoved = false
            end
        end
    end, "Update character initialization data")

    -- Migration: Unified Profile System (Req 8.1–8.8)
    -- Initializes scope link defaults, populates spec-to-profile mapping from
    -- legacy layout.spec data, and removes deprecated Systems Profile System keys.
    self:RegisterMigration("3.0.0", "3.1.0", function()
        local db = RealUI.db
        if not db then
            debug("Unified profiles migration: database not available")
            return
        end

        -- Idempotence check (Req 8.7, 8.8)
        if db.global.unifiedProfilesMigrated then
            debug("Unified profiles migration: already migrated, skipping")
            return
        end

        -- Layout index → profile name mapping
        local layoutToProfile = {
            [1] = "RealUI",
            [2] = "RealUI-Healing",
        }

        -- Deprecated keys from the old Systems Profile System (Req 8.5)
        local deprecatedProfileKeys = {
            "profileSystem",
            "systemProfiles",
            "profileSwitcher",
            "legacyProfileSystem",
        }

        local allSuccess = true

        -- Scope 1: Initialize scopeLinks on db.char (per-character, not per-profile)
        local ok1, err1 = pcall(function()
            local dbc = db.char
            if type(dbc) ~= "table" then return end

            if not dbc.scopeLinks then
                dbc.scopeLinks = {
                    skins = false,
                    bt4 = true,
                }
                debug("Initialized scopeLinks on db.char")
            end

            -- Clean up legacy per-profile scopeLinks if present
            local profiles = db.profiles
            if type(profiles) == "table" then
                for profileName, profileData in pairs(profiles) do
                    if type(profileData) == "table" and profileData.scopeLinks then
                        -- Migrate: if user had customized scopeLinks on the active profile,
                        -- carry those values to db.char
                        if profileName == db:GetCurrentProfile() then
                            dbc.scopeLinks.skins = profileData.scopeLinks.skins or false
                            dbc.scopeLinks.bt4 = (profileData.scopeLinks.bt4 ~= false) -- default true
                            debug("Migrated scopeLinks from active profile to db.char")
                        end
                        profileData.scopeLinks = nil
                        debug("Removed legacy scopeLinks from profile:", profileName)
                    end
                end
            end
        end)
        if not ok1 then
            debug("Unified profiles migration: scopeLinks migration failed -", err1)
            allSuccess = false
            -- Safe default: ensure db.char has scopeLinks
            if db.char and not db.char.scopeLinks then
                db.char.scopeLinks = { skins = false, bt4 = true }
            end
        end

        -- Scope 2: Populate db.char.specProfiles from db.char.layout.spec (Req 8.4)
        local ok2, err2 = pcall(function()
            local dbc = db.char
            if type(dbc) ~= "table" then return end

            if not dbc.specProfiles then
                dbc.specProfiles = {}
            end

            if dbc.layout and type(dbc.layout.spec) == "table" then
                for specIndex, layoutIndex in pairs(dbc.layout.spec) do
                    -- Only populate if not already set (preserve existing assignments)
                    if not dbc.specProfiles[specIndex] then
                        local profileName = layoutToProfile[layoutIndex]
                        if profileName then
                            dbc.specProfiles[specIndex] = profileName
                            debug("Mapped spec", specIndex, "-> layout", layoutIndex, "-> profile", profileName)
                        else
                            -- Unknown layout index, default to "RealUI"
                            dbc.specProfiles[specIndex] = layoutToProfile[1]
                            debug("Mapped spec", specIndex, "-> unknown layout", layoutIndex, "-> default RealUI")
                        end
                    end
                end
            end
        end)
        if not ok2 then
            debug("Unified profiles migration: char specProfiles scope failed -", err2)
            allSuccess = false
            -- Safe default: ensure specProfiles exists
            if db.char and not db.char.specProfiles then
                db.char.specProfiles = {}
            end
        end

        -- Scope 3: Remove deprecated Systems Profile System keys from all profiles (Req 8.5)
        local ok3, err3 = pcall(function()
            local profiles = db.profiles
            if type(profiles) ~= "table" then return end

            for profileName, profileData in pairs(profiles) do
                if type(profileData) == "table" then
                    for _, key in ipairs(deprecatedProfileKeys) do
                        if profileData[key] ~= nil then
                            profileData[key] = nil
                            debug("Removed deprecated key", key, "from profile:", profileName)
                        end
                    end
                end
            end
        end)
        if not ok3 then
            debug("Unified profiles migration: deprecated keys cleanup failed -", err3)
            allSuccess = false
        end

        -- Mark migration complete (Req 8.8)
        if allSuccess then
            db.global.unifiedProfilesMigrated = true
            debug("Unified profiles migration completed successfully")
        else
            -- Still mark as migrated to avoid re-running on every login;
            -- partial failures were handled with safe defaults above.
            db.global.unifiedProfilesMigrated = true
            debug("Unified profiles migration completed with errors (safe defaults applied)")
        end
    end, "Migrate to unified profile system")
end

-- Clean up deprecated settings
function FinalMigrations:CleanupDeprecatedSettings()
    debug("Cleaning up deprecated settings...")

    if not RealUI.db then
        return
    end

    -- Remove deprecated profile settings
    local deprecatedProfileKeys = {
        "oldLayoutSystem",
        "legacyPositions",
        "deprecatedModules"
    }

    if RealUI.db.profile then
        for _, key in ipairs(deprecatedProfileKeys) do
            if RealUI.db.profile[key] ~= nil then
                RealUI.db.profile[key] = nil
                debug("Removed deprecated profile key:", key)
            end
        end
    end

    -- Remove deprecated global settings
    local deprecatedGlobalKeys = {
        "oldVersionInfo",
        "legacyTutorial"
    }

    if RealUI.db.global then
        for _, key in ipairs(deprecatedGlobalKeys) do
            if RealUI.db.global[key] ~= nil then
                RealUI.db.global[key] = nil
                debug("Removed deprecated global key:", key)
            end
        end
    end

    debug("Cleanup complete")
end

-- Validate migrated data
function FinalMigrations:ValidateMigratedData()
    debug("Validating migrated data...")

    local issues = {}

    -- Validate profile data
    if RealUI.db and RealUI.db.profile then
        -- Check positions
        if not RealUI.db.profile.positions then
            table.insert(issues, "Missing positions data")
        else
            for layoutId = 1, 2 do
                if not RealUI.db.profile.positions[layoutId] then
                    table.insert(issues, "Missing layout " .. layoutId .. " positions")
                end
            end
        end

        -- Check modules
        if not RealUI.db.profile.modules then
            table.insert(issues, "Missing modules data")
        end

        -- Check settings
        if not RealUI.db.profile.settings then
            table.insert(issues, "Missing settings data")
        end
    end

    -- Validate character data
    if RealUI.db and RealUI.db.char then
        if not RealUI.db.char.init then
            table.insert(issues, "Missing character init data")
        end

        if not RealUI.db.char.layout then
            table.insert(issues, "Missing character layout data")
        end
    end

    -- Validate global data
    if RealUI.db and RealUI.db.global then
        if not RealUI.db.global.verinfo then
            table.insert(issues, "Missing version info")
        end
    end

    if #issues > 0 then
        debug("Validation found issues:")
        for _, issue in ipairs(issues) do
            debug("  -", issue)
        end
    else
        debug("Validation passed")
    end

    return #issues == 0, issues
end

-- Initialize final migrations
function FinalMigrations:Initialize()
    debug("Initializing final migrations...")

    -- Register standard migrations
    self:RegisterStandardMigrations()

    -- Run pending migrations if needed
    if RealUI.db and RealUI.db.global and RealUI.db.global.verinfo then
        local currentVersion = RealUI.db.global.verinfo.string
        local targetVersion = RealUI.verinfo.string

        if currentVersion ~= targetVersion then
            local _, failed = self:RunPendingMigrations(currentVersion, targetVersion)

            if #failed > 0 then
                debug("Some migrations failed")
                if RealUI.FeedbackSystem then
                    RealUI.FeedbackSystem:ShowWarning("Migration Warning", "Some data migrations failed. Check /exportdiag for details.")
                end
            end
        end
    end

    -- Fallback: run unified-profiles migration even if version strings match
    -- (e.g. dev environment where saved version already equals running version).
    -- The migration's own idempotence guard (unifiedProfilesMigrated) prevents re-runs.
    if RealUI.db and RealUI.db.global and not RealUI.db.global.unifiedProfilesMigrated then
        debug("Running unified-profiles migration (fallback: version match but not yet migrated)")
        local _, fallbackFailed = self:RunPendingMigrations("3.0.0", "3.1.0")
        if fallbackFailed and #fallbackFailed > 0 then
            debug("Fallback migration had failures")
        end
    end

    -- Clean up deprecated settings
    self:CleanupDeprecatedSettings()

    -- Validate migrated data
    local valid = self:ValidateMigratedData()
    if not valid then
        debug("Data validation failed")
        if RealUI.FeedbackSystem then
            RealUI.FeedbackSystem:ShowWarning("Data Validation", "Some data validation checks failed. Settings may need reconfiguration.")
        end
    end

    debug("Final migrations initialized")
end

-- Expose FinalMigrations to RealUI
RealUI.FinalMigrations = FinalMigrations
