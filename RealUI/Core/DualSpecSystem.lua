local ADDON_NAME, private = ...

-- RealUI Dual-Specialization Support System
-- This module handles automatic profile switching based on specialization changes
-- Integrates LibDualSpec for automatic profile switching
-- Implements specialization detection and change handling
-- Creates per-spec configuration storage and retrieval

local RealUI = private.RealUI
local debug = RealUI.GetDebug("DualSpecSystem")

local DualSpecSystem = {}
RealUI.DualSpecSystem = DualSpecSystem

-- LibDualSpec integration
local LDS = _G.LibStub("LibDualSpec-1.0")

-- Specialization tracking
local currentSpec = nil
local specProfiles = {}
local specConfigurations = {}
local isInitialized = false
local isLibDualSpecSetup = false

-- Profile to Layout Mapping (from Core.lua)
local profileToLayout = {
    ["RealUI"] = 1,
    ["RealUI-Healing"] = 2
}

local layoutToProfile = {
    "RealUI",
    "RealUI-Healing"
}

local function EnsureBartenderActionBarsProfiles()
    local bt4db = _G.Bartender4DB
    if type(bt4db) ~= "table" then return end

    local namespaces = bt4db.namespaces
    if type(namespaces) ~= "table" then return end

    local actionBarsNamespace = namespaces.ActionBars
    if type(actionBarsNamespace) ~= "table" then return end

    local profiles = actionBarsNamespace.profiles
    if type(profiles) ~= "table" then
        profiles = {}
        actionBarsNamespace.profiles = profiles
    end

    local defaultEnabled = {
        [1] = true,
        [2] = true,
        [3] = true,
        [4] = true,
        [5] = true,
        [6] = true,
        [7] = false,
        [8] = false,
        [9] = false,
        [10] = false,
        [13] = false,
        [14] = false,
        [15] = false,
    }

    local function EnsureProfile(profileName)
        local profile = profiles[profileName]
        if type(profile) ~= "table" then
            profile = {}
            profiles[profileName] = profile
        end

        if type(profile.actionbars) ~= "table" then
            profile.actionbars = {}
        end

        for barID, enabled in pairs(defaultEnabled) do
            if type(profile.actionbars[barID]) ~= "table" then
                profile.actionbars[barID] = { enabled = enabled }
            end
        end
    end

    for profileName in pairs(profiles) do
        EnsureProfile(profileName)
    end

    for _, profileName in ipairs(layoutToProfile) do
        EnsureProfile(profileName)
    end

    if type(bt4db.profileKeys) == "table" then
        local currentProfileName = bt4db.profileKeys[RealUI.key]
        if type(currentProfileName) == "string" and currentProfileName ~= "" then
            EnsureProfile(currentProfileName)
        end
    end
end

-- Enhanced Specialization Detection Functions
function DualSpecSystem:GetCurrentSpecialization()
    if _G.IsPlayerInitialSpec() then
        debug("Player is in initial spec state")
        return nil
    end

    local specIndex = _G.C_SpecializationInfo.GetSpecialization()
    if not specIndex then
        debug("No specialization index available")
        return nil
    end

    local specInfo = RealUI.charInfo.specs[specIndex]
    if not specInfo then
        debug("No spec info found for index:", specIndex)
        return nil
    end

    debug("Current specialization:", specIndex, specInfo.name, specInfo.role)
    return specInfo
end

function DualSpecSystem:GetSpecializationRole(specIndex)
    if not specIndex or not RealUI.charInfo.specs[specIndex] then
        debug("Invalid spec index or no spec info:", specIndex)
        return nil
    end

    local role = RealUI.charInfo.specs[specIndex].role
    debug("Spec role for", specIndex, ":", role)
    return role
end

function DualSpecSystem:IsHealingSpec(specIndex)
    local role = self:GetSpecializationRole(specIndex)
    local isHealer = role == "HEALER"
    debug("Is healing spec", specIndex, ":", isHealer)
    return isHealer
end

function DualSpecSystem:GetAllSpecializations()
    local specs = {}
    for i = 1, #RealUI.charInfo.specs do
        specs[i] = {
            index = i,
            info = RealUI.charInfo.specs[i],
            profile = self:GetSpecProfile(i),
            role = self:GetSpecializationRole(i)
        }
    end
    debug("Retrieved all specializations:", #specs)
    return specs
end

-- Enhanced Profile Assignment Functions
function DualSpecSystem:SetSpecProfile(specIndex, profileName)
    if not specIndex or not profileName then
        debug("Invalid parameters for SetSpecProfile:", specIndex, profileName)
        return false
    end

    debug("Setting spec profile:", specIndex, "->", profileName)
    specProfiles[specIndex] = profileName

    -- Update character database
    local dbc = RealUI.db and RealUI.db.char
    if dbc and dbc.layout and dbc.layout.spec then
        local layoutIndex = profileToLayout[profileName] or 1
        dbc.layout.spec[specIndex] = layoutIndex
        debug("Updated layout spec mapping:", specIndex, "->", layoutIndex)
    end

    -- Update LibDualSpec mapping if initialized
    if isLibDualSpecSetup and RealUI.db then
        debug("Updating LibDualSpec profile mapping for spec:", specIndex)
        RealUI.db:SetDualSpecProfile(profileName, specIndex)
    end

    debug("Spec profile set successfully:", specIndex, "->", profileName)
    return true
end

function DualSpecSystem:GetSpecProfile(specIndex)
    if not specIndex then
        debug("No spec index provided for GetSpecProfile")
        return nil
    end

    local profile = specProfiles[specIndex]
    debug("Retrieved spec profile:", specIndex, "->", profile)
    return profile
end

function DualSpecSystem:GetDefaultProfileForSpec(specIndex)
    local defaultProfile
    if self:IsHealingSpec(specIndex) then
        defaultProfile = layoutToProfile[2] -- Healing profile
    else
        defaultProfile = layoutToProfile[1] -- DPS/Tank profile
    end

    debug("Default profile for spec", specIndex, ":", defaultProfile)
    return defaultProfile
end

function DualSpecSystem:GetAllSpecProfiles()
    local profiles = {}
    for specIndex, profileName in pairs(specProfiles) do
        profiles[specIndex] = {
            specIndex = specIndex,
            profileName = profileName,
            specInfo = RealUI.charInfo.specs[specIndex],
            isDefault = profileName == self:GetDefaultProfileForSpec(specIndex)
        }
    end
    debug("Retrieved all spec profiles:", #profiles)
    return profiles
end

-- Enhanced Automatic Profile Switching
function DualSpecSystem:SwitchToSpecProfile(specIndex)
    if not specIndex then
        debug("No spec index provided for profile switching")
        return false
    end

    if not isInitialized then
        debug("DualSpecSystem not initialized, cannot switch profiles")
        return false
    end

    local targetProfile = self:GetSpecProfile(specIndex)
    if not targetProfile then
        targetProfile = self:GetDefaultProfileForSpec(specIndex)
        debug("Using default profile for spec:", specIndex, "->", targetProfile)

        -- Set the default profile for future use
        self:SetSpecProfile(specIndex, targetProfile)
    end

    if not targetProfile then
        debug("No profile found for spec:", specIndex)
        return false
    end

    local currentProfile = RealUI.ProfileSystem:GetCurrentProfile()
    if currentProfile == targetProfile then
        debug("Already using correct profile:", targetProfile)
        return true
    end

    debug("Switching profile for spec change:", currentProfile, "->", targetProfile)

    -- Save current spec configuration before switching
    if currentSpec and currentSpec ~= specIndex then
        self:SaveCurrentSpecConfiguration()
    end

    local success = RealUI.ProfileSystem:SwitchProfile(targetProfile)
    if success then
        debug("Profile switched successfully")

        -- Load spec-specific configuration
        self:LoadSpecConfiguration(specIndex)

        -- Update current spec tracking
        currentSpec = specIndex
    else
        debug("Failed to switch profile")
    end

    return success
end

function DualSpecSystem:CanSwitchProfiles()
    if _G.InCombatLockdown() then
        debug("Cannot switch profiles during combat")
        return false, "Cannot switch profiles during combat"
    end

    if not isInitialized then
        debug("DualSpecSystem not initialized")
        return false, "DualSpecSystem not initialized"
    end

    if not RealUI.ProfileSystem then
        debug("ProfileSystem not available")
        return false, "ProfileSystem not available"
    end

    return true
end

-- Enhanced Specialization Change Handling
function DualSpecSystem:OnSpecializationChanged(specIndex)
    debug("Specialization changed to:", specIndex)

    if not specIndex then
        debug("Invalid specialization index")
        return
    end

    -- Check if we can switch profiles
    local canSwitch, reason = self:CanSwitchProfiles()
    if not canSwitch then
        debug("Cannot switch profiles:", reason)

        -- Schedule the switch for when combat ends if in combat
        if _G.InCombatLockdown() then
            debug("Scheduling profile switch for after combat")
            RealUI:RegisterEvent("PLAYER_REGEN_ENABLED", function()
                RealUI:UnregisterEvent("PLAYER_REGEN_ENABLED")
                self:OnSpecializationChanged(specIndex)
            end)
        end
        return
    end

    -- Update RealUI character info
    if RealUI.charInfo.specs[specIndex] then
        RealUI.charInfo.specs.current = RealUI.charInfo.specs[specIndex]
        debug("Updated current spec info:", RealUI.charInfo.specs.current.name, RealUI.charInfo.specs.current.role)
    end

    -- Switch profile if needed
    if self:SwitchToSpecProfile(specIndex) then
        debug("Profile switched successfully for spec:", specIndex)

        -- Update layout if needed
        local dbc = RealUI.db and RealUI.db.char
        if dbc and dbc.layout and dbc.layout.spec[specIndex] then
            local targetLayout = dbc.layout.spec[specIndex]
            if dbc.layout.current ~= targetLayout then
                debug("Updating layout:", dbc.layout.current, "->", targetLayout)
                RealUI:UpdateLayout(targetLayout)
            end
        end

        -- Notify other systems of the spec change
        RealUI:SendMessage("REALUI_SPEC_CHANGED", specIndex, RealUI.charInfo.specs[specIndex])

    else
        debug("Failed to switch profile for spec:", specIndex)
    end
end

function DualSpecSystem:ForceSpecializationUpdate()
    debug("Forcing specialization update")

    local currentSpecInfo = self:GetCurrentSpecialization()
    if currentSpecInfo then
        self:OnSpecializationChanged(currentSpecInfo.index)
    else
        debug("No current specialization available for forced update")
    end
end

-- Enhanced LibDualSpec Integration
function DualSpecSystem:SetupLibDualSpec()
    if not RealUI.db then
        debug("Database not available for LibDualSpec setup")
        return false
    end

    if isLibDualSpecSetup then
        debug("LibDualSpec already set up")
        return true
    end

    debug("Setting up LibDualSpec integration")

    EnsureBartenderActionBarsProfiles()

    -- Enhance database with LibDualSpec support
    LDS:EnhanceDatabase(RealUI.db, "RealUI")

    -- Create healing profile if it doesn't exist
    local profiles = RealUI.db:GetProfiles()
    local hasHealingProfile = false
    for _, profile in ipairs(profiles) do
        if profile == layoutToProfile[2] then
            hasHealingProfile = true
            break
        end
    end

    if not hasHealingProfile then
        debug("Creating healing profile")
        RealUI.db:SetProfile(layoutToProfile[2])
        RealUI.db:SetProfile(layoutToProfile[1]) -- Switch back to default
    end

    -- Set up dual-spec profiles for all specs
    for specIndex = 1, #RealUI.charInfo.specs do
        local spec = RealUI.charInfo.specs[specIndex]
        local profileName = self:GetDefaultProfileForSpec(specIndex)

        debug("Setting up spec profile:", specIndex, spec.name, spec.role, "->", profileName)

        -- Set the dual-spec profile in LibDualSpec
        RealUI.db:SetDualSpecProfile(profileName, specIndex)

        -- Update our internal mapping
        self:SetSpecProfile(specIndex, profileName)
    end

    isLibDualSpecSetup = true
    debug("LibDualSpec setup cocessfully")
    return true
end

function DualSpecSystem:IsLibDualSpecReady()
    return isLibDualSpecSetup and RealUI.db ~= nil
end

function DualSpecSystem:RefreshLibDualSpecProfiles()
    if not self:IsLibDualSpecReady() then
        debug("LibDualSpec not ready for refresh")
        return false
    end

    debug("Refreshing LibDualSpec profiles")

    -- Re-setup all spec profiles
    for specIndex = 1, #RealUI.charInfo.specs do
        local profileName = self:GetSpecProfile(specIndex)
        if profileName then
            RealUI.db:SetDualSpecProfile(profileName, specIndex)
            debug("Refreshed spec profile:", specIndex, "->", profileName)
        end
    end

    return true
end

-- Enhanced Per-Spec Configuration Storage and Retrieval
function DualSpecSystem:SaveSpecConfiguration(specIndex, configData)
    if not specIndex then
        debug("No spec index provided for SaveSpecConfiguration")
        return false
    end

    -- Use current spec if no specific data provided
    if not configData then
        configData = self:GetCurrentConfiguration()
    end

    if not configData then
        debug("No configuration data available to save")
        return false
    end

    debug("Saving configuration for spec:", specIndex)

    -- Store in memory
    specConfigurations[specIndex] = {
        data = configData,
        timestamp = time(),
        specInfo = RealUI.charInfo.specs[specIndex]
    }

    -- Store in profile database for persistence
    local profile = RealUI.ProfileSystem:GetProfileData()
    if profile then
        if not profile.specConfigs then
            profile.specConfigs = {}
        end
        profile.specConfigs[specIndex] = specConfigurations[specIndex]
        debug("Saved configuration to profile database for spec:", specIndex)
    end

    debug("Configuration saved successfully for spec:", specIndex)
    return true
end

function DualSpecSystem:LoadSpecConfiguration(specIndex)
    if not specIndex then
        debug("No spec index provided for LoadSpecConfiguration")
        return nil
    end

    debug("Loading configuration for spec:", specIndex)

    -- Try memory first
    local config = specConfigurations[specIndex]

    -- Fall back to profile database
    if not config then
        local profile = RealUI.ProfileSystem:GetProfileData()
        if profile and profile.specConfigs then
            config = profile.specConfigs[specIndex]
            if config then
                -- Cache in memory
                specConfigurations[specIndex] = config
                debug("Loaded configuration from profile database for spec:", specIndex)
            end
        end
    end

    if config then
        debug("Configuration loaded for spec:", specIndex, "timestamp:", config.timestamp)

        -- Apply the configuration
        if config.data then
            self:ApplyConfiguration(config.data)
        end

        return config.data
    else
        debug("No configuration found for spec:", specIndex)
        return nil
    end
end

function DualSpecSystem:ClearSpecConfiguration(specIndex)
    if not specIndex then
        debug("No spec index provided for ClearSpecConfiguration")
        return false
    end

    debug("Clearing configuration for spec:", specIndex)

    -- Clear from memory
    specConfigurations[specIndex] = nil

    -- Clear from profile database
    local profile = RealUI.ProfileSystem:GetProfileData()
    if profile and profile.specConfigs then
        profile.specConfigs[specIndex] = nil
        debug("Cleared configuration from profile database for spec:", specIndex)
    end

    debug("Configuration cleared successfully for spec:", specIndex)
    return true
end

function DualSpecSystem:GetAllSpecConfigurations()
    local configs = {}

    -- Get from memory first
    for specIndex, config in pairs(specConfigurations) do
        configs[specIndex] = config
    end

    -- Fill in any missing from profile database
    local profile = RealUI.ProfileSystem:GetProfileData()
    if profile and profile.specConfigs then
        for specIndex, config in pairs(profile.specConfigs) do
            if not configs[specIndex] then
                configs[specIndex] = config
                -- Cache in memory
                specConfigurations[specIndex] = config
            end
        end
    end

    debug("Retrieved all spec configurations:", #configs)
    return configs
end

function DualSpecSystem:SaveCurrentSpecConfiguration()
    if not currentSpec then
        debug("No current spec to save configuration for")
        return false
    end

    debug("Saving current spec configuration:", currentSpec)
    return self:SaveSpecConfiguration(currentSpec)
end

function DualSpecSystem:GetCurrentConfiguration()
    -- This would collect current UI state - for now return a placeholder
    -- In a full implementation, this would gather positions, settings, etc.
    return {
        timestamp = time(),
        hudSize = RealUI.db and RealUI.db.profile.settings.hudSize,
        positions = RealUI.db and RealUI.db.profile.positions,
        modules = RealUI.db and RealUI.db.profile.modules
    }
end

function DualSpecSystem:ApplyConfiguration(configData)
    if not configData then
        debug("No configuration data to apply")
        return false
    end

    debug("Applying configuration data")

    -- Apply settings if available
    if configData.hudSize and RealUI.db and RealUI.db.profile.settings then
        RealUI.db.profile.settings.hudSize = configData.hudSize
    end

    -- Apply positions if available
    if configData.positions and RealUI.db and RealUI.db.profile then
        RealUI.db.profile.positions = configData.positions
    end

    -- Apply module states if available
    if configData.modules and RealUI.db and RealUI.db.profile then
        RealUI.db.profile.modules = configData.modules
    end

    debug("Configuration applied successfully")
    return true
end

-- Enhanced Event Handlers
local function UpdateSpec()
    debug("UpdateSpec called")

    if _G.IsPlayerInitialSpec() then
        debug("Player is in initial spec state, seeding LDS currentSpec only")
        -- Only seed LDS.currentSpec here. Do NOT call CheckDualSpecState on
        -- all databases — Bartender4's ActionBars namespace may not be fully
        -- initialized yet, causing .actionbars to be nil on profile switch.
        -- Bartender4 manages its own LibDualSpec state; RealUI's DB will be
        -- handled when spec actually fires later.
        EnsureBartenderActionBarsProfiles()
        LDS.currentSpec = RealUI.charInfo.specs.current.index
        return
    end

    local specInfo = RealUI.charInfo.specs
    local newSpecIndex = _G.C_SpecializationInfo.GetSpecialization()

    if not newSpecIndex then
        debug("No specialization index available")
        return
    end

    if not specInfo.current or specInfo.current.index ~= newSpecIndex then
        debug("Spec change detected:", specInfo.current and specInfo.current.index or "nil", "->", newSpecIndex)

        -- Update spec info
        if RealUI.charInfo.specs[newSpecIndex] then
            specInfo.current = RealUI.charInfo.specs[newSpecIndex]
            debug("Updated current spec info:", specInfo.current.name, specInfo.current.role)
        end

        -- Handle the specialization change
        RealUI.DualSpecSystem:OnSpecializationChanged(newSpecIndex)
    else
        debug("No spec change detected, current:", specInfo.current.index)
    end
end

local function OnPlayerLogin()
    debug("Player login detected, initializing spec tracking")

    -- Small delay to ensure all systems are ready
    RealUI:ScheduleTimer(function()
        if RealUI.DualSpecSystem:IsInitialized() then
            RealUI.DualSpecSystem:ForceSpecializationUpdate()
        end
    end, 1)
end

local function OnPlayerEnterWorld()
    debug("Player entered world, checking spec state")

    -- Update spec information when entering world
    UpdateSpec()
end

-- Enhanced Initialization
function DualSpecSystem:Initialize()
    debug("Initializing DualSpecSystem")

    if isInitialized then
        debug("DualSpecSystem already initialized")
        return true
    end

    -- Initialize spec profiles mapping
    for specIndex = 1, #RealUI.charInfo.specs do
        local defaultProfile = self:GetDefaultProfileForSpec(specIndex)
        self:SetSpecProfile(specIndex, defaultProfile)
        debug("Initialized spec profile mapping:", specIndex, "->", defaultProfile)
    end

    -- Set up current spec tracking
    local currentSpecInfo = self:GetCurrentSpecialization()
    if currentSpecInfo then
        currentSpec = currentSpecInfo.index
        debug("Current spec:", currentSpec, currentSpecInfo.name, currentSpecInfo.role)
    else
        debug("No current spec available during initialization")
    end

    -- Register event handlers for specialization changes
    RealUI:RegisterEvent("UNIT_LEVEL", UpdateSpec)
    RealUI:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED", UpdateSpec)
    RealUI:RegisterEvent("PLAYER_TALENT_UPDATE", UpdateSpec)
    RealUI:RegisterEvent("TRAIT_CONFIG_UPDATED", UpdateSpec)
    RealUI:RegisterEvent("PLAYER_LOGIN", OnPlayerLogin)
    RealUI:RegisterEvent("PLAYER_ENTERING_WORLD", OnPlayerEnterWorld)

    isInitialized = true
    debug("DualSpecSystem initialized successfully")
    return true
end

function DualSpecSystem:PostInitialize()
    debug("Post-initializing DualSpecSystem")

    if not isInitialized then
        debug("Cannot post-initialize: DualSpecSystem not initialized")
        return false
    end

    -- Set up LibDualSpec integration after database is ready
    if RealUI.db then
        local success = self:SetupLibDualSpec()
        if not success then
            debug("Failed to set up LibDualSpec integration")
            return false
        end
    else
        debug("Database not ready for LibDualSpec setup")
        return false
    end

    -- Load existing spec configurations
    self:GetAllSpecConfigurations()

    debug("DualSpecSystem post-initialization completed successfully")
    return true
end

function DualSpecSystem:Shutdown()
    debug("Shutting down DualSpecSystem")

    -- Save current spec configuration before shutdown
    if currentSpec then
        self:SaveCurrentSpecConfiguration()
    end

    -- Unregister events
    RealUI:UnregisterEvent("UNIT_LEVEL")
    RealUI:UnregisterEvent("PLAYER_SPECIALIZATION_CHANGED")
    RealUI:UnregisterEvent("PLAYER_TALENT_UPDATE")
    RealUI:UnregisterEvent("TRAIT_CONFIG_UPDATED")
    RealUI:UnregisterEvent("PLAYER_LOGIN")
    RealUI:UnregisterEvent("PLAYER_ENTERING_WORLD")

    isInitialized = false
    isLibDualSpecSetup = false

    debug("DualSpecSystem shutdown completed")
end

-- Enhanced Utility Functions
function DualSpecSystem:GetCurrentSpec()
    return currentSpec
end

function DualSpecSystem:GetSpecProfiles()
    return specProfiles
end

function DualSpecSystem:GetSpecConfigurations()
    return specConfigurations
end

function DualSpecSystem:IsInitialized()
    return isInitialized
end

function DualSpecSystem:GetSystemStatus()
    return {
        initialized = isInitialized,
        libDualSpecSetup = isLibDualSpecSetup,
        currentSpec = currentSpec,
        specProfilesCount = #specProfiles,
        specConfigurationsCount = #specConfigurations,
        hasDatabase = RealUI.db ~= nil
    }
end

function DualSpecSystem:ValidateSpecIndex(specIndex)
    if not specIndex or type(specIndex) ~= "number" then
        debug("Invalid spec index type:", type(specIndex))
        return false
    end

    if specIndex < 1 or specIndex > #RealUI.charInfo.specs then
        debug("Spec index out of range:", specIndex, "max:", #RealUI.charInfo.specs)
        return false
    end

    return true
end

function DualSpecSystem:GetDebugInfo()
    local info = {
        system = self:GetSystemStatus(),
        currentSpecInfo = currentSpec and RealUI.charInfo.specs[currentSpec] or nil,
        allSpecs = self:GetAllSpecializations(),
        allProfiles = self:GetAllSpecProfiles(),
        profileToLayout = profileToLayout,
        layoutToProfile = layoutToProfile
    }

    debug("Debug info generated")
    return info
end

-- Register with RealUI namespace
RealUI:RegisterNamespace("DualSpecSystem", DualSpecSystem)
