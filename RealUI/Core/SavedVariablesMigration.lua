local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs

-- RealUI SavedVariables Migration System
-- This system handles migration from the old nibRealUI addon naming to the new RealUI naming.
-- It automatically migrates nibRealUIDB to RealUIDB and nibRealUICharacter to RealUICharacter
-- on first load after the addon rename, preserving all user settings and profiles.

local RealUI = private.RealUI
local debug = RealUI.GetDebug("SavedVariablesMigration")

-- Migration System
local SavedVariablesMigration = {}
RealUI.SavedVariablesMigration = SavedVariablesMigration

-- Migration status tracking
local MIGRATION_STATUS_KEY = "savedVariablesMigrated"

-- Deep copy function to preserve all data structures
local function DeepCopy(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original do
            copy[DeepCopy(key)] = DeepCopy(value)
        end
        setmetatable(copy, DeepCopy(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

-- Check if migration has already been completed
function SavedVariablesMigration:IsMigrationComplete()
    if _G.RealUIDB and _G.RealUIDB.global then
        return _G.RealUIDB.global[MIGRATION_STATUS_KEY] == true
    end
    return false
end

-- Mark migration as complete
function SavedVariablesMigration:MarkMigrationComplete()
    if _G.RealUIDB and _G.RealUIDB.global then
        _G.RealUIDB.global[MIGRATION_STATUS_KEY] = true
        -- Also mark setup as complete for 3.0.0 since we migrated the config
        _G.RealUIDB.global["setupVersion"] = "3.0.0"

        -- Ensure character is marked as initialized if we migrated data
        if _G.RealUIDB.char then
            local charKey = RealUI.key
            if charKey and _G.RealUIDB.char[charKey] then
                if not _G.RealUIDB.char[charKey].init then
                    _G.RealUIDB.char[charKey].init = {}
                end
                _G.RealUIDB.char[charKey].init.initialized = true
                _G.RealUIDB.char[charKey].init.installStage = -1
            end
        end

        debug("Migration marked as complete, setup version set to 3.0.0, character initialized")
    end
end

-- Create backup of old database
function SavedVariablesMigration:CreateBackup()
    if not _G.nibRealUIDB then
        debug("No old database to backup")
        return false
    end

    debug("Creating backup of nibRealUIDB")
    _G.nibRealUIDB_Backup = DeepCopy(_G.nibRealUIDB)

    -- Also backup character-specific data if it exists
    if _G.nibRealUICharacter then
        debug("Creating backup of nibRealUICharacter")
        _G.nibRealUICharacter_Backup = DeepCopy(_G.nibRealUICharacter)
    end

    debug("Backup created successfully")
    return true
end

-- Migrate global settings
function SavedVariablesMigration:MigrateGlobalSettings(oldGlobal, newGlobal)
    if not oldGlobal then
        return true
    end

    debug("Migrating global settings")

    -- Copy all global settings
    for key, value in pairs(oldGlobal) do
        if key ~= MIGRATION_STATUS_KEY then
            newGlobal[key] = DeepCopy(value)
            debug("Migrated global setting:", key)
        end
    end

    return true
end

-- Migrate profile settings
function SavedVariablesMigration:MigrateProfileSettings(oldProfiles, newProfiles)
    if not oldProfiles then
        return true
    end

    debug("Migrating profile settings")

    -- Copy all profiles
    for profileName, profileData in pairs(oldProfiles) do
        newProfiles[profileName] = DeepCopy(profileData)
        debug("Migrated profile:", profileName)
    end

    return true
end

-- Migrate character settings
function SavedVariablesMigration:MigrateCharacterSettings(oldChar, newChar)
    if not oldChar then
        return true
    end

    debug("Migrating character settings")

    -- Copy all character settings
    for charKey, charData in pairs(oldChar) do
        newChar[charKey] = DeepCopy(charData)
        debug("Migrated character:", charKey)
    end

    return true
end

-- Migrate profile keys (character to profile mappings)
function SavedVariablesMigration:MigrateProfileKeys(oldDB, newDB)
    if not oldDB.profileKeys then
        return true
    end

    debug("Migrating profile keys")

    newDB.profileKeys = DeepCopy(oldDB.profileKeys)
    debug("Profile keys migrated")

    return true
end

-- Migrate namespaced module data
function SavedVariablesMigration:MigrateNamespaces(oldDB, newDB)
    if not oldDB.namespaces then
        return true
    end

    debug("Migrating namespaced module data")

    newDB.namespaces = DeepCopy(oldDB.namespaces)
    debug("Namespaces migrated")

    return true
end

-- Migrate character-specific SavedVariables
function SavedVariablesMigration:MigrateCharacterSavedVariables()
    if not _G.nibRealUICharacter then
        return true
    end

    debug("Migrating character-specific SavedVariables")

    -- Copy character-specific data
    _G.RealUICharacter = DeepCopy(_G.nibRealUICharacter)
    debug("Character SavedVariables migrated")

    return true
end

-- Main migration function
function SavedVariablesMigration:PerformMigration()
    debug("Starting SavedVariables migration")

    -- Check if old database exists
    if not _G.nibRealUIDB then
        debug("No old database found (nibRealUIDB does not exist)")
        return false, "no_old_database"
    end

    -- Check if migration already completed
    if self:IsMigrationComplete() then
        debug("Migration already completed, skipping")
        return false, "already_migrated"
    end

    -- Check if new database exists
    if not _G.RealUIDB then
        debug("New database not initialized yet")
        return false, "new_database_not_ready"
    end

    -- Create backup before migration
    local backupSuccess = self:CreateBackup()
    if not backupSuccess then
        debug("Failed to create backup")
        return false, "backup_failed"
    end

    debug("Beginning data migration from nibRealUIDB to RealUIDB")

    -- Migrate global settings
    if _G.nibRealUIDB.global then
        self:MigrateGlobalSettings(_G.nibRealUIDB.global, _G.RealUIDB.global)
    end

    -- Migrate profiles
    if _G.nibRealUIDB.profiles then
        self:MigrateProfileSettings(_G.nibRealUIDB.profiles, _G.RealUIDB.profiles)
    end

    -- Migrate character settings
    if _G.nibRealUIDB.char then
        self:MigrateCharacterSettings(_G.nibRealUIDB.char, _G.RealUIDB.char)
    end

    -- Migrate profile keys
    self:MigrateProfileKeys(_G.nibRealUIDB, _G.RealUIDB)

    -- Migrate namespaces
    self:MigrateNamespaces(_G.nibRealUIDB, _G.RealUIDB)

    -- Migrate character-specific SavedVariables
    self:MigrateCharacterSavedVariables()

    -- Mark migration as complete
    self:MarkMigrationComplete()

    debug("Migration completed successfully")
    return true, "success"
end

-- Show migration notification to user
function SavedVariablesMigration:ShowMigrationNotification(success, reason)
    if not success then
        if reason == "already_migrated" then
            debug("Migration already completed previously")
            return
        elseif reason == "no_old_database" then
            debug("No old database to migrate")
            return
        elseif reason == "new_database_not_ready" then
            debug("New database not ready for migration")
            return
        else
            -- Show error notification
            if RealUI.Notification then
                RealUI:Notification(
                    "RealUI Migration Failed",
                    true,
                    "Failed to migrate settings from nibRealUI. Reason: " .. (reason or "unknown"),
                    nil,
                    [[Interface\AddOns\RealUI\Media\Notification_Alert]]
                )
            end
        end
        return
    end

    -- Show success notification
    if RealUI.Notification then
        RealUI:Notification(
            "RealUI Settings Migrated",
            false,
            "Your settings have been successfully migrated from nibRealUI to RealUI.",
            nil,
            [[Interface\AddOns\RealUI\Media\Icon]]
        )
    end

    debug("Migration notification shown to user")
end

--[[ Initialize function no longer needed - migration is called directly before database init
-- Initialize migration system
function SavedVariablesMigration:Initialize()
    debug("SavedVariablesMigration system initialized")

    -- Register for PLAYER_LOGIN to perform migration after database is ready
    RealUI:RegisterEvent("PLAYER_LOGIN", function()
        debug("PLAYER_LOGIN - Checking for migration")

        -- Perform migration
        local success, reason = self:PerformMigration()

        -- Show notification to user
        self:ShowMigrationNotification(success, reason)
    end)
end
--]]
