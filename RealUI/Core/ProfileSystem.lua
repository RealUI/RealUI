local ADDON_NAME, private = ...

-- RealUI Profile System
-- This module handles profile management, AceDB integration, and configuration persistence

local RealUI = private.RealUI
local debug = RealUI.GetDebug("ProfileSystem")

local ProfileSystem = {}
RealUI.ProfileSystem = ProfileSystem

-- Profile System Constants
local PROFILE_VERSION = 1
local DEFAULT_PROFILE_NAME = "RealUI"
local HEALING_PROFILE_NAME = "RealUI-Healing"

-- Database Structure and Defaults
local function GetDefaultCharInit()
    return {
        installStage = 0,
        initialized = false,
        needchatmoved = true
    }
end

local function GetDefaultSpec()
    local spec = {}
    for specIndex = 1, #RealUI.charInfo.specs do
        local role = RealUI.charInfo.specs[specIndex].role
        debug("Setting default spec layout", specIndex, role)
        spec[specIndex] = role == "HEALER" and 2 or 1
    end
    return spec
end

function ProfileSystem:GetDatabaseDefaults()
    return {
        global = {
            tutorial = {
                stage = -1
            },
            tags = {
                firsttime = true,
                lowResOptimized = false,
                slashRealUITyped = false
            },
            messages = {},
            verinfo = {},
            patchedTOC = 0,
            currency = {},
            profileVersion = PROFILE_VERSION
        },
        char = {
            init = GetDefaultCharInit(),
            layout = {
                current = 1, -- 1 = DPS/Tank, 2 = Healing
                spec = GetDefaultSpec()
            }
        },
        profile = {
            modules = {
                ["*"] = true -- Default all modules to enabled
            },
            registeredChars = {},
            -- HuD positions
            positionsLink = true,
            positions = RealUI.defaultPositions,
            -- Action Bar settings
            abSettingsLink = false,
            -- Dynamic UI settings
            settings = {
                hudSize = 2,
                reverseUnitFrameBars = false
            },
            profileVersion = PROFILE_VERSION
        }
    }
end

-- Profile Management Functions
function ProfileSystem:CreateProfile(profileName, copyFrom)
    if not self.db then
        debug("Database not initialized")
        return false
    end

    debug("Creating profile:", profileName, "copyFrom:", copyFrom)

    if copyFrom then
        self.db:SetProfile(profileName)
        self.db:CopyProfile(copyFrom)
    else
        self.db:SetProfile(profileName)
    end

    -- Initialize profile-specific data
    local profile = self.db.profile
    if not profile.profileVersion then
        profile.profileVersion = PROFILE_VERSION
    end

    debug("Profile created successfully:", profileName)
    return true
end

function ProfileSystem:DeleteProfile(profileName)
    if not self.db then
        debug("Database not initialized")
        return false
    end

    if profileName == DEFAULT_PROFILE_NAME then
        debug("Cannot delete default profile")
        return false
    end

    debug("Deleting profile:", profileName)
    self.db:DeleteProfile(profileName)
    return true
end

function ProfileSystem:SwitchProfile(profileName)
    if not self.db then
        debug("Database not initialized")
        return false
    end

    debug("Switching to profile:", profileName)
    self.db:SetProfile(profileName)

    -- NOTE: Do NOT call RealUI:OnProfileUpdate here.
    -- AceDB:SetProfile already fires the "OnProfileChanged" callback
    -- which is registered in Core.lua to call OnProfileUpdate automatically.
    -- Calling it again would cause double module updates and positioning conflicts.

    return true
end

function ProfileSystem:GetCurrentProfile()
    if not self.db then
        return nil
    end
    return self.db:GetCurrentProfile()
end

function ProfileSystem:GetProfileList()
    if not self.db then
        return {}
    end
    return self.db:GetProfiles()
end

function ProfileSystem:CopyProfile(sourceProfile, targetProfile)
    if not self.db then
        debug("Database not initialized")
        return false
    end

    debug("Copying profile:", sourceProfile, "->", targetProfile)

    local currentProfile = self:GetCurrentProfile()
    self.db:SetProfile(targetProfile or currentProfile)
    self.db:CopyProfile(sourceProfile)

    return true
end

function ProfileSystem:ResetProfile(profileName)
    if not self.db then
        debug("Database not initialized")
        return false
    end

    profileName = profileName or self:GetCurrentProfile()
    debug("Resetting profile:", profileName)

    self.db:ResetProfile()

    -- NOTE: Do NOT call RealUI:OnProfileUpdate here.
    -- AceDB:ResetProfile already fires the "OnProfileReset" callback
    -- which is registered in Core.lua to call OnProfileUpdate automatically.

    return true
end

-- Configuration Validation
function ProfileSystem:ValidateConfiguration(config)
    if not config then
        debug("Configuration is nil")
        return false, "Configuration is nil"
    end

    -- Validate required sections
    local requiredSections = {"global", "char", "profile"}
    for _, section in ipairs(requiredSections) do
        if not config[section] then
            debug("Missing required section:", section)
            return false, "Missing required section: " .. section
        end
    end

    -- Validate profile version
    if config.profile.profileVersion and config.profile.profileVersion > PROFILE_VERSION then
        debug("Profile version too new:", config.profile.profileVersion)
        return false, "Profile version too new: " .. config.profile.profileVersion
    end

    -- Validate character init data
    if not config.char.init then
        debug("Missing character init data")
        return false, "Missing character init data"
    end

    -- Validate layout data
    if not config.char.layout or not config.char.layout.current then
        debug("Missing layout data")
        return false, "Missing layout data"
    end

    -- Validate module data
    if config.profile.modules and type(config.profile.modules) ~= "table" then
        debug("Invalid modules data type")
        return false, "Invalid modules data type"
    end

    debug("Configuration validation passed")
    return true
end

function ProfileSystem:RepairConfiguration(config)
    debug("Repairing configuration")

    local defaults = self:GetDatabaseDefaults()
    local repaired = false

    -- Repair missing sections
    for section, defaultData in pairs(defaults) do
        if not config[section] then
            config[section] = self:DeepCopyTable(defaultData)
            repaired = true
            debug("Repaired missing section:", section)
        end
    end

    -- Repair character init data
    if not config.char.init then
        config.char.init = GetDefaultCharInit()
        repaired = true
        debug("Repaired character init data")
    end

    -- Repair layout data
    if not config.char.layout then
        config.char.layout = {
            current = 1,
            spec = GetDefaultSpec()
        }
        repaired = true
        debug("Repaired layout data")
    end

    -- Update profile version
    if not config.profile.profileVersion then
        config.profile.profileVersion = PROFILE_VERSION
        repaired = true
        debug("Updated profile version")
    end

    if repaired then
        debug("Configuration repaired successfully")
    else
        debug("No repairs needed")
    end

    return config, repaired
end

-- Utility function for deep copying tables
function ProfileSystem:DeepCopyTable(original)
    local copy
    if type(original) == 'table' then
        copy = {}
        for key, value in next, original, nil do
            copy[self:DeepCopyTable(key)] = self:DeepCopyTable(value)
        end
        setmetatable(copy, self:DeepCopyTable(getmetatable(original)))
    else
        copy = original
    end
    return copy
end

-- Character Registration
function ProfileSystem:RegisterCharacter(charKey, profileName)
    if not self.db then
        debug("Database not initialized")
        return false
    end

    charKey = charKey or RealUI.key
    profileName = profileName or self:GetCurrentProfile()

    -- Ensure charKey is available
    if not charKey then
        debug("Character key not yet available, deferring registration")
        return false
    end

    debug("Registering character:", charKey, "with profile:", profileName)

    -- Ensure charInfo is available
    if not RealUI.charInfo or not RealUI.charInfo.class or not RealUI.charInfo.class.token or not RealUI.charInfo.realm then
        debug("Character info not yet available, deferring registration")
        return false
    end

    local profile = self.db.profile
    if not profile then
        debug("Profile not available")
        return false
    end

    if not profile.registeredChars then
        profile.registeredChars = {}
    end

    profile.registeredChars[charKey] = {
        profile = profileName,
        registered = time(),
        class = RealUI.charInfo.class.token,
        realm = RealUI.charInfo.realm
    }

    debug("Character registered successfully")
    return true
end

function ProfileSystem:UnregisterCharacter(charKey)
    if not self.db then
        debug("Database not initialized")
        return false
    end

    charKey = charKey or RealUI.key

    debug("Unregistering character:", charKey)

    local profile = self.db.profile
    if profile.registeredChars and profile.registeredChars[charKey] then
        profile.registeredChars[charKey] = nil
        debug("Character unregistered successfully")
        return true
    end

    debug("Character not found in registry")
    return false
end

function ProfileSystem:GetRegisteredCharacters()
    if not self.db then
        return {}
    end

    local profile = self.db.profile
    return profile.registeredChars or {}
end

-- Database Access Functions
function ProfileSystem:GetDatabase()
    return self.db
end

function ProfileSystem:GetGlobalData()
    return self.db and self.db.global
end

function ProfileSystem:GetCharacterData()
    return self.db and self.db.char
end

function ProfileSystem:GetProfileData()
    return self.db and self.db.profile
end

-- Initialization
function ProfileSystem:Initialize(database)
    debug("Initializing ProfileSystem")

    if database then
        self.db = database
        debug("Using provided database")
    else
        debug("Database not provided - will be set later")
    end

    -- Register character if database is available
    if self.db then
        self:RegisterCharacter()
    end

    debug("ProfileSystem initialized")
    return true
end

-- Register with RealUI namespace
RealUI:RegisterNamespace("ProfileSystem", ProfileSystem)
