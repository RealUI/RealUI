local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("ProfileManager")

-- Advanced Configuration Features
-- Implements profile sharing and export/import functionality
-- Provides configuration backup and restoration systems
-- Adds advanced user customization options

local ProfileManager = RealUI:NewModule("ProfileManager", "AceEvent-3.0", "AceSerializer-3.0")

-- Profile export format version
local EXPORT_FORMAT_VERSION = 1

-- Compression library
local LibDeflate = _G.LibStub:GetLibrary("LibDeflate", true)

function ProfileManager:OnInitialize()
    debug("ProfileManager:OnInitialize")

    self.db = RealUI.db
    self.exportCache = {}
    self.backupHistory = {}
    self.maxBackups = 5
end

-- Serialize profile data
function ProfileManager:SerializeProfile(profileName)
    if not self.db then
        debug("Database not available")
        return nil, "Database not available"
    end

    -- Get profile data
    local profileKey = self.db:GetCurrentProfile()
    if profileName then
        -- Switch to specified profile temporarily
        self.db:SetProfile(profileName)
    end

    local profileData = {
        version = EXPORT_FORMAT_VERSION,
        profileName = self.db:GetCurrentProfile(),
        timestamp = _G.time(),
        gameVersion = RealUI.verinfo.string,
        data = {
            profile = _G.CopyTable(self.db.profile),
            char = _G.CopyTable(self.db.char),
            global = _G.CopyTable(self.db.global)
        }
    }

    -- Restore original profile if we switched
    if profileName then
        self.db:SetProfile(profileKey)
    end

    -- Serialize
    local serialized = self:Serialize(profileData)
    if not serialized then
        return nil, "Serialization failed"
    end

    debug("Profile serialized:", profileData.profileName, "Size:", #serialized)
    return serialized, nil
end

-- Deserialize profile data
function ProfileManager:DeserializeProfile(serialized)
    if not serialized or serialized == "" then
        return nil, "Empty data"
    end

    local success, profileData = self:Deserialize(serialized)
    if not success then
        return nil, "Deserialization failed"
    end

    -- Validate format version
    if not profileData.version or profileData.version > EXPORT_FORMAT_VERSION then
        return nil, "Incompatible format version"
    end

    debug("Profile deserialized:", profileData.profileName)
    return profileData, nil
end

-- Encode profile data for export
function ProfileManager:EncodeProfile(serialized)
    if not serialized then
        return nil, "No data to encode"
    end

    -- Compress if LibDeflate is available
    local compressed = serialized
    if LibDeflate then
        compressed = LibDeflate:CompressDeflate(serialized)
        debug("Compressed:", #serialized, "->", #compressed)
    end

    -- Encode to base64
    local encoded
    if LibDeflate then
        encoded = LibDeflate:EncodeForPrint(compressed)
    else
        -- Fallback to simple encoding
        encoded = _G.EncodeBase64(compressed)
    end

    debug("Encoded profile, size:", #encoded)
    return encoded, nil
end

-- Decode profile data from import
function ProfileManager:DecodeProfile(encoded)
    if not encoded or encoded == "" then
        return nil, "Empty encoded data"
    end

    -- Decode from base64
    local compressed
    if LibDeflate then
        compressed = LibDeflate:DecodeForPrint(encoded)
    else
        -- Fallback to simple decoding
        compressed = _G.DecodeBase64(encoded)
    end

    if not compressed then
        return nil, "Decoding failed"
    end

    -- Decompress if LibDeflate is available
    local serialized = compressed
    if LibDeflate then
        serialized = LibDeflate:DecompressDeflate(compressed)
        if not serialized then
            return nil, "Decompression failed"
        end
        debug("Decompressed:", #compressed, "->", #serialized)
    end

    return serialized, nil
end

-- Export profile to string
function ProfileManager:ExportProfile(profileName)
    debug("Exporting profile:", profileName or "current")

    -- Serialize profile
    local serialized, err = self:SerializeProfile(profileName)
    if not serialized then
        return nil, err
    end

    -- Encode for export
    local encoded, err = self:EncodeProfile(serialized)
    if not encoded then
        return nil, err
    end

    -- Cache export
    self.exportCache[profileName or "current"] = {
        data = encoded,
        timestamp = _G.time()
    }

    debug("Profile exported successfully")
    return encoded, nil
end

-- Import profile from string
function ProfileManager:ImportProfile(encoded, targetProfileName)
    debug("Importing profile to:", targetProfileName or "new profile")

    -- Decode import data
    local serialized, err = self:DecodeProfile(encoded)
    if not serialized then
        return false, err
    end

    -- Deserialize profile
    local profileData, err = self:DeserializeProfile(serialized)
    if not profileData then
        return false, err
    end

    -- Validate profile data
    if not profileData.data or not profileData.data.profile then
        return false, "Invalid profile data structure"
    end

    -- Determine target profile name
    local newProfileName = targetProfileName or (profileData.profileName .. " (Imported)")

    -- Create backup of current profile before importing
    self:CreateBackup("pre-import")

    -- Create or switch to target profile
    self.db:SetProfile(newProfileName)

    -- Import profile data
    for key, value in pairs(profileData.data.profile) do
        self.db.profile[key] = _G.CopyTable(value)
    end

    -- Import character data if available
    if profileData.data.char then
        for key, value in pairs(profileData.data.char) do
            self.db.char[key] = _G.CopyTable(value)
        end
    end

    -- Notify other systems of profile change
    if RealUI.OnProfileUpdate then
        RealUI:OnProfileUpdate("OnProfileImported", self.db, newProfileName)
    end

    debug("Profile imported successfully:", newProfileName)
    return true, newProfileName
end

-- Create backup of current configuration
function ProfileManager:CreateBackup(label)
    if not self.db then
        return false, "Database not available"
    end

    label = label or "manual"
    debug("Creating backup:", label)

    -- Serialize current state
    local serialized, err = self:SerializeProfile()
    if not serialized then
        return false, err
    end

    -- Create backup entry
    local backup = {
        label = label,
        timestamp = _G.time(),
        profileName = self.db:GetCurrentProfile(),
        data = serialized
    }

    -- Add to backup history
    table.insert(self.backupHistory, 1, backup)

    -- Limit backup history
    while #self.backupHistory > self.maxBackups do
        table.remove(self.backupHistory)
    end

    debug("Backup created:", label, "Total backups:", #self.backupHistory)
    return true, backup
end

-- Restore configuration from backup
function ProfileManager:RestoreBackup(index)
    if not self.backupHistory or #self.backupHistory == 0 then
        return false, "No backups available"
    end

    index = index or 1
    if index < 1 or index > #self.backupHistory then
        return false, "Invalid backup index"
    end

    local backup = self.backupHistory[index]
    debug("Restoring backup:", backup.label, "from", _G.date("%Y-%m-%d %H:%M:%S", backup.timestamp))

    -- Deserialize backup data
    local profileData, err = self:DeserializeProfile(backup.data)
    if not profileData then
        return false, err
    end

    -- Create a backup before restoring
    self:CreateBackup("pre-restore")

    -- Restore profile data
    for key, value in pairs(profileData.data.profile) do
        self.db.profile[key] = _G.CopyTable(value)
    end

    -- Restore character data
    if profileData.data.char then
        for key, value in pairs(profileData.data.char) do
            self.db.char[key] = _G.CopyTable(value)
        end
    end

    -- Notify other systems
    if RealUI.OnProfileUpdate then
        RealUI:OnProfileUpdate("OnProfileRestored", self.db, backup.profileName)
    end

    debug("Backup restored successfully")
    return true, backup
end

-- Get list of available backups
function ProfileManager:GetBackups()
    local backups = {}

    for i, backup in ipairs(self.backupHistory) do
        table.insert(backups, {
            index = i,
            label = backup.label,
            timestamp = backup.timestamp,
            profileName = backup.profileName,
            date = _G.date("%Y-%m-%d %H:%M:%S", backup.timestamp)
        })
    end

    return backups
end

-- Clear backup history
function ProfileManager:ClearBackups()
    debug("Clearing backup history")
    self.backupHistory = {}
    return true
end

-- Share profile with another character
function ProfileManager:ShareProfile(sourceProfile, targetCharacter)
    debug("Sharing profile:", sourceProfile, "to", targetCharacter)

    if not self.db then
        return false, "Database not available"
    end

    -- Export source profile
    local exported, err = self:ExportProfile(sourceProfile)
    if not exported then
        return false, err
    end

    -- Store in global database for cross-character access
    if not self.db.global.sharedProfiles then
        self.db.global.sharedProfiles = {}
    end

    self.db.global.sharedProfiles[targetCharacter] = {
        data = exported,
        sourceProfile = sourceProfile,
        timestamp = _G.time()
    }

    debug("Profile shared successfully")
    return true, exported
end

-- Retrieve shared profile
function ProfileManager:RetrieveSharedProfile(sourceCharacter)
    debug("Retrieving shared profile from:", sourceCharacter)

    if not self.db or not self.db.global.sharedProfiles then
        return nil, "No shared profiles available"
    end

    local shared = self.db.global.sharedProfiles[sourceCharacter]
    if not shared then
        return nil, "No profile shared from this character"
    end

    -- Import the shared profile
    local success, profileName = self:ImportProfile(shared.data, shared.sourceProfile .. " (Shared)")
    if not success then
        return nil, profileName
    end

    debug("Shared profile retrieved successfully")
    return profileName, nil
end

-- Copy profile settings
function ProfileManager:CopyProfile(sourceProfile, targetProfile)
    debug("Copying profile:", sourceProfile, "to", targetProfile)

    if not self.db then
        return false, "Database not available"
    end

    -- Get current profile
    local currentProfile = self.db:GetCurrentProfile()

    -- Switch to source profile
    self.db:SetProfile(sourceProfile)
    local sourceData = _G.CopyTable(self.db.profile)

    -- Switch to target profile
    self.db:SetProfile(targetProfile)

    -- Copy data
    for key, value in pairs(sourceData) do
        self.db.profile[key] = _G.CopyTable(value)
    end

    -- Restore original profile
    self.db:SetProfile(currentProfile)

    debug("Profile copied successfully")
    return true, nil
end

-- Reset profile to defaults
function ProfileManager:ResetProfile(profileName)
    debug("Resetting profile:", profileName or "current")

    if not self.db then
        return false, "Database not available"
    end

    -- Create backup before reset
    self:CreateBackup("pre-reset")

    -- Reset profile
    if profileName then
        self.db:SetProfile(profileName)
    end

    self.db:ResetProfile()

    -- Notify other systems
    if RealUI.OnProfileUpdate then
        RealUI:OnProfileUpdate("OnProfileReset", self.db, profileName or self.db:GetCurrentProfile())
    end

    debug("Profile reset successfully")
    return true, nil
end

-- Get profile manager status
function ProfileManager:GetStatus()
    return {
        currentProfile = self.db and self.db:GetCurrentProfile() or "Unknown",
        backupCount = #self.backupHistory,
        maxBackups = self.maxBackups,
        exportCacheSize = self:GetTableSize(self.exportCache),
        sharedProfiles = self.db and self.db.global.sharedProfiles and self:GetTableSize(self.db.global.sharedProfiles) or 0
    }
end

-- Helper function to get table size
function ProfileManager:GetTableSize(tbl)
    local count = 0
    for _ in pairs(tbl) do
        count = count + 1
    end
    return count
end

-- Print status to chat
function ProfileManager:PrintStatus()
    local status = self:GetStatus()

    print("=== Profile Manager Status ===")
    print(("Current Profile: %s"):format(status.currentProfile))
    print(("Backups: %d/%d"):format(status.backupCount, status.maxBackups))
    print(("Export Cache: %d"):format(status.exportCacheSize))
    print(("Shared Profiles: %d"):format(status.sharedProfiles))

    if #self.backupHistory > 0 then
        print("\nRecent Backups:")
        for i, backup in ipairs(self:GetBackups()) do
            if i <= 3 then
                print(("%d. %s - %s (%s)"):format(i, backup.label, backup.date, backup.profileName))
            end
        end
    end
end

-- Export for integration with other systems
RealUI.ProfileManager = ProfileManager
