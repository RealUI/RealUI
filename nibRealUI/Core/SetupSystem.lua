local _, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs _G strsplit tonumber

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("SetupSystem")

-- Setup System for RealUI 3.0.0
-- Detects old configurations from previous versions and runs setup wizard

local SetupSystem = {}
RealUI.SetupSystem = SetupSystem

-- Version constants
SetupSystem.CURRENT_VERSION = "3.0.0"
SetupSystem.SETUP_VERSION_KEY = "setupVersion"

-- Setup state
local setupState = {
    needsSetup = false,
    isUpgrade = false,
    oldVersion = nil,
    detectedOldConfig = false,
    migrationRequired = false
}

-- Detect old RealUI configuration
function SetupSystem:DetectOldConfiguration()
    debug("Detecting old RealUI configuration...")

    local detectedVersion = nil
    local hasOldData = false

    -- Check for saved variables from previous versions
    if _G.nibRealUIDB then
        debug("Found nibRealUIDB")

        -- Check for version info in global settings
        if _G.nibRealUIDB.global and _G.nibRealUIDB.global.verinfo then
            local oldVerInfo = _G.nibRealUIDB.global.verinfo
            if oldVerInfo.string then
                detectedVersion = oldVerInfo.string
                debug("Detected version from verinfo:", detectedVersion)
            end
        end

        -- Check for profile data
        if _G.nibRealUIDB.profiles then
            hasOldData = true
            debug("Found profile data from previous version")
        end

        -- Check for character data
        if _G.nibRealUIDB.char then
            hasOldData = true
            debug("Found character data from previous version")
        end
    end

    -- Check for legacy character data
    if _G.nibRealUICharacter then
        hasOldData = true
        debug("Found legacy character data")
    end

    -- Check for old tutorial system
    if _G.nibRealUIDB and _G.nibRealUIDB.global and _G.nibRealUIDB.global.tutorial then
        local tutorialStage = _G.nibRealUIDB.global.tutorial.stage
        if tutorialStage and tutorialStage ~= -1 then
            hasOldData = true
            debug("Found incomplete tutorial from previous version")
        end
    end

    setupState.detectedOldConfig = hasOldData
    setupState.oldVersion = detectedVersion

    return hasOldData, detectedVersion
end

-- Check if setup is needed
function SetupSystem:NeedsSetup()
    if not RealUI.db or not RealUI.db.global then
        debug("No database found, setup needed")
        return true
    end

    local dbg = RealUI.db.global

    -- Check if setup has been run for current version
    local setupVersion = dbg[SetupSystem.SETUP_VERSION_KEY]
    if not setupVersion or setupVersion ~= SetupSystem.CURRENT_VERSION then
        debug("Setup version mismatch:", setupVersion, "vs", SetupSystem.CURRENT_VERSION)
        return true
    end

    -- Check character initialization
    if RealUI.db.char and RealUI.db.char.init then
        local charInit = RealUI.db.char.init
        if not charInit.initialized or charInit.installStage ~= -1 then
            debug("Character not fully initialized")
            return true
        end
    else
        debug("No character init data found")
        return true
    end

    return false
end

-- Determine if this is an upgrade from old version
function SetupSystem:IsUpgrade()
    local hasOldConfig, oldVersion = self:DetectOldConfiguration()

    if not hasOldConfig then
        return false, nil
    end

    -- Parse old version
    if oldVersion then
        local oldVer = self:ParseVersion(oldVersion)
        local currentVer = self:ParseVersion(SetupSystem.CURRENT_VERSION)

        if oldVer and currentVer then
            -- Check if upgrading from 2.x to 3.x (major version change)
            if oldVer[1] < currentVer[1] then
                debug("Detected major version upgrade:", oldVersion, "->", SetupSystem.CURRENT_VERSION)
                return true, oldVersion
            end
        end
    end

    -- If we have old config but no version, assume it's an upgrade
    if hasOldConfig then
        debug("Detected old configuration without version info, assuming upgrade")
        return true, "unknown"
    end

    return false, nil
end

-- Parse version string
function SetupSystem:ParseVersion(versionString)
    if not versionString or versionString == "unknown" then
        return nil
    end

    local parts = {strsplit(".", versionString)}
    local version = {}

    for i = 1, 3 do
        version[i] = tonumber(parts[i]) or 0
    end

    return version
end

-- Initialize setup system
function SetupSystem:Initialize()
    debug("Initializing Setup System for version", SetupSystem.CURRENT_VERSION)

    -- Detect old configuration
    local hasOldConfig, oldVersion = self:DetectOldConfiguration()
    setupState.detectedOldConfig = hasOldConfig
    setupState.oldVersion = oldVersion

    -- Check if this is an upgrade
    local isUpgrade, upgradeFromVersion = self:IsUpgrade()
    setupState.isUpgrade = isUpgrade

    if isUpgrade then
        debug("Upgrade detected from version:", upgradeFromVersion or "unknown")
        setupState.migrationRequired = true
    end

    -- Check if setup is needed
    setupState.needsSetup = self:NeedsSetup()

    debug("Setup state:", "needsSetup=" .. tostring(setupState.needsSetup),
          "isUpgrade=" .. tostring(setupState.isUpgrade),
          "oldVersion=" .. tostring(setupState.oldVersion))

    return setupState
end

-- Migrate settings from old version
function SetupSystem:MigrateOldSettings()
    if not setupState.detectedOldConfig then
        debug("No old configuration to migrate")
        return true
    end

    debug("Migrating settings from previous version...")

    local success = true
    local errors = {}

    -- Migrate global settings
    if _G.nibRealUIDB and _G.nibRealUIDB.global then
        success, errors = self:MigrateGlobalSettings(_G.nibRealUIDB.global)
        if not success then
            debug("Failed to migrate global settings:", table.concat(errors, ", "))
        end
    end

    -- Migrate profile settings
    if _G.nibRealUIDB and _G.nibRealUIDB.profiles then
        local profileSuccess, profileErrors = self:MigrateProfileSettings(_G.nibRealUIDB.profiles)
        if not profileSuccess then
            debug("Failed to migrate profile settings:", table.concat(profileErrors, ", "))
            success = false
            for _, err in ipairs(profileErrors) do
                table.insert(errors, err)
            end
        end
    end

    -- Migrate character settings
    if _G.nibRealUIDB and _G.nibRealUIDB.char then
        local charSuccess, charErrors = self:MigrateCharacterSettings(_G.nibRealUIDB.char)
        if not charSuccess then
            debug("Failed to migrate character settings:", table.concat(charErrors, ", "))
            success = false
            for _, err in ipairs(charErrors) do
                table.insert(errors, err)
            end
        end
    end

    if success then
        debug("Settings migration completed successfully")
    else
        debug("Settings migration completed with errors:", table.concat(errors, ", "))
    end

    return success, errors
end

-- Migrate global settings
function SetupSystem:MigrateGlobalSettings(oldGlobal)
    debug("Migrating global settings...")

    if not RealUI.db or not RealUI.db.global then
        return false, {"Database not initialized"}
    end

    local dbg = RealUI.db.global
    local errors = {}

    -- Migrate currency data
    if oldGlobal.currency then
        dbg.currency = oldGlobal.currency
        debug("Migrated currency data")
    end

    -- Migrate tags
    if oldGlobal.tags then
        dbg.tags = dbg.tags or {}
        for key, value in pairs(oldGlobal.tags) do
            dbg.tags[key] = value
        end
        debug("Migrated tags")
    end

    -- Mark old tutorial as complete
    if oldGlobal.tutorial then
        dbg.tutorial = dbg.tutorial or {}
        dbg.tutorial.stage = -1
        debug("Marked old tutorial as complete")
    end

    return true, errors
end

-- Migrate profile settings
function SetupSystem:MigrateProfileSettings(oldProfiles)
    debug("Migrating profile settings...")

    if not RealUI.db then
        return false, {"Database not initialized"}
    end

    local errors = {}

    -- Migrate RealUI and RealUI-Healing profiles
    for profileName, profileData in pairs(oldProfiles) do
        if profileName == "RealUI" or profileName == "RealUI-Healing" then
            debug("Migrating profile:", profileName)

            -- Set to this profile temporarily
            RealUI.db:SetProfile(profileName)

            -- Migrate media settings
            if profileData.media then
                RealUI.db.profile.media = RealUI.db.profile.media or {}
                for key, value in pairs(profileData.media) do
                    RealUI.db.profile.media[key] = value
                end
                debug("Migrated media settings for", profileName)
            end

            -- Migrate registered characters
            if profileData.registeredChars then
                RealUI.db.profile.registeredChars = profileData.registeredChars
                debug("Migrated registered characters for", profileName)
            end

            -- Migrate module settings (selective migration)
            if profileData.modules then
                RealUI.db.profile.modules = RealUI.db.profile.modules or {}
                for moduleName, moduleData in pairs(profileData.modules) do
                    -- Only migrate if module still exists
                    if RealUI:GetModule(moduleName, true) then
                        RealUI.db.profile.modules[moduleName] = moduleData
                        debug("Migrated module settings:", moduleName)
                    else
                        debug("Skipped obsolete module:", moduleName)
                    end
                end
            end
        end
    end

    -- Restore default profile
    RealUI.db:SetProfile("RealUI")

    return true, errors
end

-- Migrate character settings
function SetupSystem:MigrateCharacterSettings(oldChar)
    debug("Migrating character settings...")

    if not RealUI.db or not RealUI.db.char then
        return false, {"Character database not initialized"}
    end

    local dbc = RealUI.db.char
    local errors = {}

    -- Migrate layout settings
    if oldChar.layout then
        dbc.layout = dbc.layout or {}
        dbc.layout.current = oldChar.layout.current or 1
        dbc.layout.spec = oldChar.layout.spec or {}
        debug("Migrated layout settings")
    end

    -- Don't migrate old init data - we want fresh setup for 3.0.0
    -- But preserve that they had RealUI before
    dbc.init = dbc.init or {}
    dbc.init.hadPreviousVersion = true
    dbc.init.previousVersion = setupState.oldVersion
    debug("Marked as upgrade from previous version")

    return true, errors
end

-- Start setup wizard
function SetupSystem:StartSetup()
    debug("Starting setup wizard...")

    -- Initialize InstallWizard if available
    if not RealUI.InstallWizard then
        debug("InstallWizard not available")
        return false
    end

    -- Initialize the wizard
    RealUI.InstallWizard:Initialize()

    -- If this is an upgrade, show special message
    if setupState.isUpgrade then
        debug("Showing upgrade setup")
        -- The InstallWizard will handle the UI
    end

    -- Start the wizard
    local started = RealUI.InstallWizard:Start()

    if started then
        debug("Setup wizard started successfully")
    else
        debug("Setup wizard failed to start")
    end

    return started
end

-- Complete setup for 3.0.0
function SetupSystem:CompleteSetup()
    debug("Completing setup for version", SetupSystem.CURRENT_VERSION)

    if not RealUI.db or not RealUI.db.global then
        debug("Database not available")
        return false
    end

    -- Mark setup as complete for this version
    RealUI.db.global[SetupSystem.SETUP_VERSION_KEY] = SetupSystem.CURRENT_VERSION

    -- Mark character as initialized
    if RealUI.db.char and RealUI.db.char.init then
        RealUI.db.char.init.initialized = true
        RealUI.db.char.init.installStage = -1
    end

    -- Clear migration flag
    setupState.migrationRequired = false
    setupState.needsSetup = false

    debug("Setup completed for version", SetupSystem.CURRENT_VERSION)

    return true
end

-- Get setup state
function SetupSystem:GetState()
    return setupState
end

-- Check and run setup if needed
function SetupSystem:CheckAndRun()
    debug("Checking if setup is needed...")

    -- Initialize setup system
    self:Initialize()

    -- If setup is needed, run it
    if setupState.needsSetup then
        debug("Setup is needed")

        -- Migrate old settings if this is an upgrade
        if setupState.isUpgrade and setupState.detectedOldConfig then
            debug("Migrating old settings before setup...")
            local success, errors = self:MigrateOldSettings()
            if not success then
                debug("Migration had errors:", table.concat(errors or {}, ", "))
            end
        end

        -- Start setup wizard
        return self:StartSetup()
    else
        debug("Setup not needed")
        return false
    end
end

-- Show upgrade notification
function SetupSystem:ShowUpgradeNotification()
    if not setupState.isUpgrade then
        return
    end

    local oldVer = setupState.oldVersion or "previous version"
    local message = ("Welcome to RealUI %s! You've been upgraded from %s.\n\nPlease run the setup wizard to configure your new installation."):format(
        SetupSystem.CURRENT_VERSION,
        oldVer
    )

    debug("Showing upgrade notification")

    -- Use RealUI notification system if available
    if RealUI.Notifications then
        RealUI.Notifications:Show({
            title = "RealUI Upgrade Detected",
            message = message,
            icon = [[Interface\AddOns\nibRealUI\Media\Logo]],
            buttons = {
                {
                    text = "Run Setup",
                    callback = function()
                        SetupSystem:StartSetup()
                    end
                },
                {
                    text = "Later",
                    callback = function()
                        debug("User postponed setup")
                    end
                }
            }
        })
    else
        -- Fallback to simple print
        print("|cff00ff00RealUI:|r " .. message)
        print("|cff00ff00Type /realui setup to run the setup wizard.|r")
    end
end

