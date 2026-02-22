local ADDON_NAME, private = ...

-- RealUI Version Management System
-- This module handles version tracking, migration, and compatibility checks

local RealUI = private.RealUI
local debug = RealUI.GetDebug("VersionManager")

local VersionManager = {}
RealUI.VersionManager = VersionManager

-- Version comparison constants
local VERSION_MAJOR = 1
local VERSION_MINOR = 2
local VERSION_PATCH = 3

-- Migration handlers registry
local migrationHandlers = {}

-- Version Utilities
function VersionManager:ParseVersion(versionString)
    if not versionString then return nil end

    local parts = {strsplit(".", versionString)}
    local version = {}

    for i = 1, 3 do
        version[i] = tonumber(parts[i]) or 0
    end

    version.string = versionString
    return version
end

function VersionManager:CompareVersions(ver1, ver2)
    if not ver1 or not ver2 then return 0 end

    for i = 1, 3 do
        local v1 = ver1[i] or 0
        local v2 = ver2[i] or 0
        if v1 > v2 then
            return 1
        elseif v1 < v2 then
            return -1
        end
    end
    return 0
end

function VersionManager:IsNewerVersion(newVer, oldVer)
    return self:CompareVersions(newVer, oldVer) > 0
end

function VersionManager:GetVersionType(oldVer, newVer)
    if not oldVer or not newVer then return "unknown" end

    if newVer[VERSION_MAJOR] > oldVer[VERSION_MAJOR] then
        return "major"
    elseif newVer[VERSION_MINOR] > oldVer[VERSION_MINOR] then
        return "minor"
    elseif newVer[VERSION_PATCH] > oldVer[VERSION_PATCH] then
        return "patch"
    end

    return "none"
end

-- Migration System
function VersionManager:RegisterMigration(fromVersion, toVersion, handler)
    if not migrationHandlers[fromVersion] then
        migrationHandlers[fromVersion] = {}
    end

    migrationHandlers[fromVersion][toVersion] = handler
    debug("Registered migration:", fromVersion, "->", toVersion)
end

function VersionManager:RunMigrations(fromVersion, toVersion)
    debug("Running migrations from", fromVersion.string, "to", toVersion.string)

    local fromKey = fromVersion.string
    if migrationHandlers[fromKey] then
        for targetVersion, handler in pairs(migrationHandlers[fromKey]) do
            if targetVersion == toVersion.string then
                debug("Executing migration:", fromKey, "->", targetVersion)
                local success, err = pcall(handler, fromVersion, toVersion)
                if not success then
                    debug("Migration failed:", err)
                    return false, err
                end
            end
        end
    end

    return true
end

-- Compatibility Checks
function VersionManager:CheckGameCompatibility()
    local gameVersion = select(4, _G.GetBuildInfo())
    local supportedVersions = {
        [120000] = true, -- Midnight Prepatch
        [120001] = true, -- Midnight Release
    }

    if not supportedVersions[gameVersion] then
        debug("Unsupported game version:", gameVersion)
        return false, "Unsupported game version: " .. gameVersion
    end

    return true
end

function VersionManager:CheckAddonCompatibility()
    local requiredAddons = {
        "RealUI_Skins",
        "RealUI_Bugs"
    }

    local missing = {}
    for _, addon in ipairs(requiredAddons) do
        if not _G.C_AddOns.IsAddOnLoaded(addon) then
            table.insert(missing, addon)
        end
    end

    if #missing > 0 then
        debug("Missing required addons:", table.concat(missing, ", "))
        return false, missing
    end

    return true, {}
end

-- Version Information
function VersionManager:GetCurrentVersion()
    return RealUI.verinfo
end

function VersionManager:GetSavedVersion()
    local db = RealUI.db
    return db and db.global.verinfo
end

function VersionManager:UpdateSavedVersion()
    local db = RealUI.db
    if db then
        db.global.verinfo = RealUI.verinfo
        debug("Updated saved version to:", RealUI.verinfo.string)
    end
end

-- Initialize version manager
function VersionManager:Initialize()
    debug("Initializing VersionManager")

    -- Check game compatibility
    local gameCompatible, gameError = self:CheckGameCompatibility()
    if not gameCompatible then
        _G.print("RealUI: " .. gameError)
    end

    -- Check addon compatibility
    local addonCompatible, missingAddons = self:CheckAddonCompatibility()
    if not addonCompatible then
        _G.print("RealUI: Missing required addons: " .. table.concat(missingAddons, ", "))
    end

    debug("VersionManager initialized")
end

-- Register with RealUI namespace
RealUI:RegisterNamespace("VersionManager", VersionManager)
