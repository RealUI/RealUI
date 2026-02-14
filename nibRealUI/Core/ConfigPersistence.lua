local ADDON_NAME, private = ...

-- RealUI Configuration Persistence and Migration System
-- This module handles settings save/load, version migration, and corruption recovery

local RealUI = private.RealUI
local debug = RealUI.GetDebug("ConfigPersistence")

local ConfigPersistence = {}
RealUI.ConfigPersistence = ConfigPersistence

-- Migration System Constants
local CURRENT_CONFIG_VERSION = 1
local MIGRATION_HANDLERS = {}

-- Configuration Backup System
local configBackups = {}
local MAX_BACKUPS = 5

-- Session tracking
local sessionData = {
    startTime = time(),
    saveCount = 0,
    loadCount = 0,
    migrationCount = 0
}

-- Settings Persistence Functions
function ConfigPersistence:SaveConfiguration()
    if not RealUI.db then
        debug("Database not available for saving")
        return false
    end

    debug("Saving configuration")

    -- Create backup before saving
    self:CreateBackup("auto_save")

    -- Update version info and metadata
    local dbg = RealUI.db.global
    if dbg then
        dbg.verinfo = RealUI.verinfo
        dbg.configVersion = CURRENT_CONFIG_VERSION
        dbg.lastSaved = time()
        dbg.saveCount = (dbg.saveCount or 0) + 1
        dbg.gameVersion = select(4, GetBuildInfo())
        dbg.sessionId = sessionData.startTime
    end

    -- Validate configuration before saving
    local isValid, error = self:ValidateConfiguration(RealUI.db.sv)
    if not isValid then
        debug("Configuration validation failed:", error)
        return false, error
    end

    -- Persist module states
    self:PersistModuleStates()

    -- Save position data
    self:SavePositionData()

    -- Save character-specific settings
    self:SaveCharacterSettings()

    -- Update session tracking
    sessionData.saveCount = sessionData.saveCount + 1

    debug("Configuration saved successfully")
    return true
end

function ConfigPersistence:LoadConfiguration()
    if not RealUI.db then
        debug("Database not available for loading")
        return false
    end

    debug("Loading configuration")

    -- Validate loaded configuration
    local isValid, error = self:ValidateConfiguration(RealUI.db.sv)
    if not isValid then
        debug("Configuration validation failed, attempting repair:", error)

        local repaired, wasRepaired = self:RepairConfiguration(RealUI.db.sv)
        if wasRepaired then
            debug("Configuration repaired successfully")
            self:CreateBackup("auto_repair")
        else
            debug("Configuration repair failed")
            return false, "Configuration corrupt and unrepairable"
        end
    end

    -- Load module states
    self:LoadModuleStates()

    -- Load position data
    self:LoadPositionData()

    -- Load character-specific settings
    self:LoadCharacterSettings()

    -- Update last loaded timestamp
    local dbg = RealUI.db.global
    if dbg then
        dbg.lastLoaded = time()
        dbg.loadCount = (dbg.loadCount or 0) + 1
    end

    -- Update session tracking
    sessionData.loadCount = sessionData.loadCount + 1

    debug("Configuration loaded successfully")
    return true
end

-- Enhanced persistence functions for specific data types
function ConfigPersistence:PersistModuleStates()
    if not RealUI.db or not RealUI.db.profile then
        return false
    end

    debug("Persisting module states")

    local profile = RealUI.db.profile
    if not profile.modules then
        profile.modules = {}
    end

    -- Save current module enabled states
    for moduleName, module in RealUI:IterateModules() do
        if module.GetEnabledState then
            profile.modules[moduleName] = module:GetEnabledState()
        end
    end

    return true
end

function ConfigPersistence:LoadModuleStates()
    if not RealUI.db or not RealUI.db.profile then
        return false
    end

    debug("Loading module states")

    local profile = RealUI.db.profile
    if not profile.modules then
        return true -- No module states to load
    end

    -- Apply saved module states
    for moduleName, enabled in pairs(profile.modules) do
        if RealUI:GetModule(moduleName, true) then
            RealUI:SetModuleEnabled(moduleName, enabled)
        end
    end

    return true
end

function ConfigPersistence:SavePositionData()
    if not RealUI.db or not RealUI.db.profile then
        return false
    end

    debug("Saving position data")

    local profile = RealUI.db.profile
    if not profile.positions then
        profile.positions = {}
    end

    -- Save current layout positions
    if RealUI.cLayout and RealUI.defaultPositions then
        profile.positions[RealUI.cLayout] = self:DeepCopy(RealUI.defaultPositions[RealUI.cLayout])
    end

    return true
end

function ConfigPersistence:LoadPositionData()
    if not RealUI.db or not RealUI.db.profile then
        return false
    end

    debug("Loading position data")

    local profile = RealUI.db.profile
    if not profile.positions then
        return true -- No position data to load
    end

    -- Apply saved positions
    if RealUI.cLayout and profile.positions[RealUI.cLayout] then
        for key, value in pairs(profile.positions[RealUI.cLayout]) do
            if RealUI.defaultPositions and RealUI.defaultPositions[RealUI.cLayout] then
                RealUI.defaultPositions[RealUI.cLayout][key] = value
            end
        end
    end

    return true
end

function ConfigPersistence:SaveCharacterSettings()
    if not RealUI.db or not RealUI.db.char then
        return false
    end

    debug("Saving character-specific settings")

    local char = RealUI.db.char

    -- Save layout preferences
    if RealUI.cLayout then
        char.layout.current = RealUI.cLayout
    end

    -- Save specialization-specific layouts
    if RealUI.charInfo and RealUI.charInfo.specs then
        for specIndex, spec in ipairs(RealUI.charInfo.specs) do
            if char.layout.spec then
                char.layout.spec[specIndex] = spec.role == "HEALER" and 2 or 1
            end
        end
    end

    return true
end

function ConfigPersistence:LoadCharacterSettings()
    if not RealUI.db or not RealUI.db.char then
        return false
    end

    debug("Loading character-specific settings")

    local char = RealUI.db.char

    -- Load layout preferences
    if char.layout and char.layout.current then
        RealUI:UpdateLayout(char.layout.current)
    end

    return true
end

-- Backup System
function ConfigPersistence:CreateBackup(backupType, name)
    if not RealUI.db then
        debug("Database not available for backup")
        return false
    end

    backupType = backupType or "manual"
    name = name or ("backup_" .. date("%Y%m%d_%H%M%S"))

    debug("Creating backup:", name, "type:", backupType)

    -- Deep copy current configuration
    local backup = {
        timestamp = time(),
        type = backupType,
        version = RealUI.verinfo.string,
        configVersion = CURRENT_CONFIG_VERSION,
        gameVersion = select(4, GetBuildInfo()),
        characterKey = RealUI.key,
        data = self:DeepCopy(RealUI.db.sv)
    }

    configBackups[name] = backup

    -- Maintain backup limit
    self:CleanupOldBackups()

    debug("Backup created successfully:", name)
    return true, name
end

function ConfigPersistence:RestoreBackup(backupName)
    if not backupName or not configBackups[backupName] then
        debug("Backup not found:", backupName)
        return false, "Backup not found"
    end

    if not RealUI.db then
        debug("Database not available for restore")
        return false, "Database not available"
    end

    debug("Restoring backup:", backupName)

    local backup = configBackups[backupName]

    -- Create backup of current state before restore
    self:CreateBackup("pre_restore", "before_restore_" .. backupName)

    -- Restore the backup data
    RealUI.db.sv = self:DeepCopy(backup.data)

    -- Trigger profile update
    RealUI:OnProfileUpdate("OnProfileReset", RealUI.db, RealUI.db:GetCurrentProfile())

    debug("Backup restored successfully:", backupName)
    return true
end

function ConfigPersistence:GetBackupList()
    local backups = {}
    for name, backup in pairs(configBackups) do
        table.insert(backups, {
            name = name,
            timestamp = backup.timestamp,
            type = backup.type,
            version = backup.version,
            gameVersion = backup.gameVersion,
            characterKey = backup.characterKey,
            date = date("%Y-%m-%d %H:%M:%S", backup.timestamp)
        })
    end

    -- Sort by timestamp (newest first)
    table.sort(backups, function(a, b) return a.timestamp > b.timestamp end)

    return backups
end

function ConfigPersistence:DeleteBackup(backupName)
    if not backupName or not configBackups[backupName] then
        debug("Backup not found for deletion:", backupName)
        return false
    end

    debug("Deleting backup:", backupName)
    configBackups[backupName] = nil
    return true
end

function ConfigPersistence:CleanupOldBackups()
    local backupList = self:GetBackupList()

    -- Keep only the most recent backups
    if #backupList > MAX_BACKUPS then
        local toDelete = #backupList - MAX_BACKUPS
        for i = #backupList - toDelete + 1, #backupList do
            local backup = backupList[i]
            if backup.type == "auto_save" or backup.type == "auto_repair" then
                debug("Cleaning up old backup:", backup.name)
                configBackups[backup.name] = nil
            end
        end
    end
end

-- Enhanced Migration System
function ConfigPersistence:RegisterMigration(fromVersion, toVersion, handler)
    local key = fromVersion .. "_to_" .. toVersion
    MIGRATION_HANDLERS[key] = handler
    debug("Registered migration:", key)
end

function ConfigPersistence:RunMigrations(fromVersion, toVersion)
    debug("Running migrations from version", fromVersion, "to", toVersion)

    if fromVersion == toVersion then
        debug("No migration needed - versions match")
        return true
    end

    -- Create backup before migration
    local backupSuccess, backupName = self:CreateBackup("pre_migration", "before_migration_" .. fromVersion .. "_to_" .. toVersion)
    if not backupSuccess then
        debug("Failed to create pre-migration backup")
        return false, "Failed to create backup"
    end

    -- Run version-specific migrations
    local migrationKey = fromVersion .. "_to_" .. toVersion
    local handler = MIGRATION_HANDLERS[migrationKey]

    if handler then
        debug("Running migration handler:", migrationKey)
        local success, error = pcall(handler, RealUI.db.sv)
        if not success then
            debug("Migration failed:", error)
            -- Restore backup on failure
            self:RestoreBackup(backupName)
            return false, error
        end
    else
        debug("No specific migration handler found, running generic migration")
        local success, error = self:RunGenericMigration(fromVersion, toVersion)
        if not success then
            debug("Generic migration failed:", error)
            self:RestoreBackup(backupName)
            return false, error
        end
    end

    -- Update configuration version
    if RealUI.db.global then
        RealUI.db.global.configVersion = toVersion
        RealUI.db.global.lastMigration = {
            from = fromVersion,
            to = toVersion,
            timestamp = time(),
            success = true
        }
    end

    -- Update session tracking
    sessionData.migrationCount = sessionData.migrationCount + 1

    debug("Migration completed successfully")
    return true
end

function ConfigPersistence:RunGenericMigration(fromVersion, toVersion)
    debug("Running generic migration:", fromVersion, "->", toVersion)

    -- Generic migration logic
    local config = RealUI.db.sv

    -- Ensure all required sections exist
    if not config.global then config.global = {} end
    if not config.char then config.char = {} end
    if not config.profile then config.profile = {} end

    -- Update version tracking
    config.global.configVersion = toVersion
    config.global.migrationHistory = config.global.migrationHistory or {}
    table.insert(config.global.migrationHistory, {
        from = fromVersion,
        to = toVersion,
        timestamp = time(),
        type = "generic"
    })

    debug("Generic migration completed")
    return true
end

-- Enhanced Configuration Validation
function ConfigPersistence:ValidateConfiguration(config)
    if not config then
        debug("Configuration is nil")
        return false, "Configuration is nil"
    end

    local issues = {}

    -- Validate required sections
    local requiredSections = {"global", "char", "profile"}
    for _, section in ipairs(requiredSections) do
        if not config[section] then
            table.insert(issues, "Missing required section: " .. section)
        end
    end

    -- Validate global section
    if config.global then
        if config.global.configVersion and type(config.global.configVersion) ~= "number" then
            table.insert(issues, "Invalid configVersion type")
        end
        if config.global.verinfo and type(config.global.verinfo) ~= "table" then
            table.insert(issues, "Invalid verinfo type")
        end
    end

    -- Validate character section
    if config.char then
        if config.char.init then
            local init = config.char.init
            if type(init.installStage) ~= "number" then
                table.insert(issues, "Invalid installStage type")
            end
            if type(init.initialized) ~= "boolean" then
                table.insert(issues, "Invalid initialized type")
            end
        end
        if config.char.layout then
            local layout = config.char.layout
            if layout.current and type(layout.current) ~= "number" then
                table.insert(issues, "Invalid layout.current type")
            end
            if layout.spec and type(layout.spec) ~= "table" then
                table.insert(issues, "Invalid layout.spec type")
            end
        end
    end

    -- Validate profile section
    if config.profile then
        local profile = config.profile
        if profile.modules and type(profile.modules) ~= "table" then
            table.insert(issues, "Invalid modules data type")
        end
        if profile.positions and type(profile.positions) ~= "table" then
            table.insert(issues, "Invalid positions data type")
        end
        if profile.settings and type(profile.settings) ~= "table" then
            table.insert(issues, "Invalid settings data type")
        end
    end

    if #issues > 0 then
        debug("Configuration validation failed:", table.concat(issues, ", "))
        return false, table.concat(issues, ", ")
    end

    debug("Configuration validation passed")
    return true
end

function ConfigPersistence:RepairConfiguration(config)
    debug("Repairing configuration")

    if not RealUI.ProfileSystem then
        debug("ProfileSystem not available for repair")
        return config, false
    end

    local defaults = RealUI.ProfileSystem:GetDatabaseDefaults()
    if not defaults then
        debug("Failed to get default configuration for repair")
        return config, false
    end

    local repaired = false

    -- Repair missing sections
    for section, defaultData in pairs(defaults) do
        if not config[section] then
            config[section] = self:DeepCopy(defaultData)
            repaired = true
            debug("Repaired missing section:", section)
        end
    end

    -- Repair character init data
    if not config.char or not config.char.init then
        config.char = config.char or {}
        config.char.init = self:DeepCopy(defaults.char.init)
        repaired = true
        debug("Repaired character init data")
    end

    -- Repair layout data
    if not config.char.layout then
        config.char.layout = self:DeepCopy(defaults.char.layout)
        repaired = true
        debug("Repaired layout data")
    end

    -- Repair profile data
    if not config.profile.modules then
        config.profile.modules = self:DeepCopy(defaults.profile.modules)
        repaired = true
        debug("Repaired profile modules")
    end

    -- Update configuration version
    if not config.global.configVersion then
        config.global.configVersion = CURRENT_CONFIG_VERSION
        repaired = true
        debug("Updated configuration version")
    end

    if repaired then
        debug("Configuration repaired successfully")
    else
        debug("No repairs needed")
    end

    return config, repaired
end

-- Enhanced Corruption Recovery
function ConfigPersistence:DetectCorruption()
    if not RealUI.db then
        return false, "Database not available"
    end

    debug("Detecting configuration corruption")

    local issues = {}

    -- Check for missing required sections
    local requiredSections = {"global", "char", "profile"}
    for _, section in ipairs(requiredSections) do
        if not RealUI.db.sv[section] then
            table.insert(issues, "Missing section: " .. section)
        end
    end

    -- Check for invalid data types
    if RealUI.db.sv.char and RealUI.db.sv.char.init then
        local init = RealUI.db.sv.char.init
        if type(init.installStage) ~= "number" then
            table.insert(issues, "Invalid installStage type")
        end
        if type(init.initialized) ~= "boolean" then
            table.insert(issues, "Invalid initialized type")
        end
    end

    -- Check profile data integrity
    if RealUI.db.sv.profile then
        local profile = RealUI.db.sv.profile
        if profile.modules and type(profile.modules) ~= "table" then
            table.insert(issues, "Invalid modules data type")
        end
        if profile.positions and type(profile.positions) ~= "table" then
            table.insert(issues, "Invalid positions data type")
        end
    end

    -- Check for circular references
    local function checkCircularRefs(tbl, visited)
        visited = visited or {}
        if visited[tbl] then
            return true
        end
        visited[tbl] = true

        if type(tbl) == "table" then
            for _, value in pairs(tbl) do
                if type(value) == "table" and checkCircularRefs(value, visited) then
                    return true
                end
            end
        end

        visited[tbl] = nil
        return false
    end

    if checkCircularRefs(RealUI.db.sv) then
        table.insert(issues, "Circular reference detected")
    end

    if #issues > 0 then
        debug("Corruption detected:", table.concat(issues, ", "))
        return true, issues
    end

    debug("No corruption detected")
    return false, {}
end

function ConfigPersistence:RecoverFromCorruption()
    debug("Attempting corruption recovery")

    -- Try to restore from most recent backup
    local backups = self:GetBackupList()
    for _, backup in ipairs(backups) do
        if backup.type ~= "pre_restore" then
            debug("Attempting recovery from backup:", backup.name)
            local success, error = self:RestoreBackup(backup.name)
            if success then
                debug("Recovery successful from backup:", backup.name)
                return true, "Recovered from backup: " .. backup.name
            else
                debug("Recovery failed from backup:", backup.name, error)
            end
        end
    end

    -- If no backups work, reset to defaults
    debug("No valid backups found, resetting to defaults")
    local success = self:ResetToDefaults()
    if success then
        return true, "Reset to default configuration"
    end

    debug("All recovery attempts failed")
    return false, "All recovery attempts failed"
end

function ConfigPersistence:ResetToDefaults()
    debug("Resetting configuration to defaults")

    if not RealUI.ProfileSystem then
        debug("ProfileSystem not available")
        return false
    end

    -- Get default configuration
    local defaults = RealUI.ProfileSystem:GetDatabaseDefaults()
    if not defaults then
        debug("Failed to get default configuration")
        return false
    end

    -- Create backup of current state
    self:CreateBackup("pre_reset", "before_default_reset")

    -- Reset database to defaults
    RealUI.db.sv = self:DeepCopy(defaults)

    -- Trigger profile reset
    RealUI:OnProfileUpdate("OnProfileReset", RealUI.db, RealUI.db:GetCurrentProfile())

    debug("Configuration reset to defaults successfully")
    return true
end

-- Utility Functions
function ConfigPersistence:DeepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original, nil do
            copy[self:DeepCopy(key)] = self:DeepCopy(value)
        end
        setmetatable(copy, self:DeepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

function ConfigPersistence:GetConfigurationInfo()
    if not RealUI.db then
        return nil
    end

    local dbg = RealUI.db.global
    local profileSystem = RealUI.ProfileSystem

    return {
        version = RealUI.verinfo.string,
        configVersion = dbg and dbg.configVersion or 0,
        lastSaved = dbg and dbg.lastSaved,
        lastLoaded = dbg and dbg.lastLoaded,
        saveCount = dbg and dbg.saveCount or 0,
        loadCount = dbg and dbg.loadCount or 0,
        profileCount = profileSystem and #profileSystem:GetProfileList() or 0,
        backupCount = #self:GetBackupList(),
        currentProfile = profileSystem and profileSystem:GetCurrentProfile() or "Unknown",
        sessionInfo = {
            startTime = sessionData.startTime,
            saveCount = sessionData.saveCount,
            loadCount = sessionData.loadCount,
            migrationCount = sessionData.migrationCount
        }
    }
end

function ConfigPersistence:GetSessionStatistics()
    return {
        startTime = sessionData.startTime,
        uptime = time() - sessionData.startTime,
        saveCount = sessionData.saveCount,
        loadCount = sessionData.loadCount,
        migrationCount = sessionData.migrationCount,
        backupCount = #self:GetBackupList()
    }
end

-- Initialization
function ConfigPersistence:Initialize()
    debug("Initializing ConfigPersistence")

    -- Initialize session data
    sessionData.startTime = time()

    -- Register default migrations
    self:RegisterDefaultMigrations()

    -- Check for corruption on startup
    local isCorrupt, issues = self:DetectCorruption()
    if isCorrupt then
        debug("Corruption detected on startup:", table.concat(issues, ", "))
        local recovered, message = self:RecoverFromCorruption()
        if recovered then
            debug("Automatic recovery successful:", message)
        else
            debug("Automatic recovery failed:", message)
        end
    end

    -- Register for automatic saving on certain events
    self:RegisterAutoSaveEvents()

    debug("ConfigPersistence initialized")
    return true
end

function ConfigPersistence:RegisterAutoSaveEvents()
    debug("Registering auto-save events")

    -- Save configuration when player logs out
    RealUI:RegisterEvent("PLAYER_LOGOUT", function()
        debug("Player logout detected, saving configuration")
        self:SaveConfiguration()
    end)

    -- Save configuration periodically during play
    RealUI:ScheduleRepeatingTimer(function()
        debug("Periodic auto-save triggered")
        self:SaveConfiguration()
    end, 300) -- Save every 5 minutes
end

function ConfigPersistence:RegisterDefaultMigrations()
    debug("Registering default migrations")

    -- Migration from version 0 to 1
    self:RegisterMigration("0", "1", function(config)
        debug("Running migration 0 -> 1")

        -- Add new fields introduced in version 1
        if config.global then
            config.global.configVersion = 1
            config.global.migrationHistory = config.global.migrationHistory or {}
        end

        if config.profile then
            config.profile.profileVersion = 1
        end

        -- Ensure character layout data exists
        if config.char and not config.char.layout then
            config.char.layout = {
                current = 1,
                spec = {}
            }
        end

        return true
    end)

    debug("Default migrations registered")
end

-- Register with RealUI namespace
RealUI:RegisterNamespace("ConfigPersistence", ConfigPersistence)
