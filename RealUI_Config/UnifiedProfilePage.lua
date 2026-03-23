local _, private = ...

-- Lua Globals --
-- luacheck: globals next pairs ipairs type tostring

-- Libs --
local ACD = _G.LibStub("AceConfigDialog-3.0")
local ADBO = _G.LibStub("AceDBOptions-3.0")

-- RealUI --
local RealUI = _G.RealUI

local ProfileCoordinator = RealUI.ProfileCoordinator
local ProfileExporter = RealUI.ProfileExporter

-- Cached state for coordinated switch dropdown
local selectedProfile

-- Helpers ----------------------------------------------------------------

--- Build a values table of all Core profile names keyed by name.
local function GetCoreProfileValues()
    local values = {}
    local profiles = RealUI.db:GetProfiles()
    if profiles then
        for _, name in ipairs(profiles) do
            values[name] = name
        end
    end
    return values
end

--- Return the current spec index (1-based) or nil.
local function GetCurrentSpecIndex()
    local specInfo = RealUI.charInfo.specs.current
    return specInfo and specInfo.index or nil
end

--- Color a spec name if it is the active spec.
local function FormatSpecName(specIndex, specData)
    local currentIndex = GetCurrentSpecIndex()
    local label = specData.name .. " (" .. specData.role .. ")"
    if specIndex == currentIndex then
        label = "|cff00ff00" .. label .. " \226\151\128|r"
    end
    return label
end

-- Export/Import popup state
local importString = ""
local lastExportString = ""


-- ========================================================================
-- Build the Unified Profile Page options table
-- All sections live under tabs — no inline groups at the top level.
-- ========================================================================

local order = 0
local function nextOrder()
    order = order + 1
    return order
end

local unifiedProfilePage = {
    name = "Profiles",
    type = "group",
    childGroups = "tab",
    order = nextOrder(),
    args = {},
}

local args = unifiedProfilePage.args

-- ========================================================================
-- Tab 1: General (Coordinated Switch + Scope Links + DualSpec Mapping)
-- ========================================================================

do
    local DualSpecSystem = RealUI.DualSpecSystem

    local generalArgs = {
        coordinatedSwitch = {
            name = "Coordinated Profile Switch",
            type = "group",
            inline = true,
            order = 1,
            args = {
                desc = {
                    name = "|cffffcc00Switch All Linked Scopes|r\n"
                        .. "Select a profile and click Switch All to change Core, Skins, and Bartender4 "
                        .. "profiles in one action. Only scopes with their link toggle enabled will participate.",
                    type = "description",
                    fontSize = "medium",
                    order = 1,
                },
                profileSelect = {
                    name = "Profile",
                    desc = "Select the target profile for all linked scopes.",
                    type = "select",
                    values = GetCoreProfileValues,
                    get = function()
                        if not selectedProfile then
                            selectedProfile = RealUI.db:GetCurrentProfile()
                        end
                        return selectedProfile
                    end,
                    set = function(_, value)
                        selectedProfile = value
                    end,
                    order = 2,
                },
                switchAll = {
                    name = "Switch All",
                    desc = "Switch all linked scopes to the selected profile.",
                    type = "execute",
                    func = function()
                        if selectedProfile then
                            ProfileCoordinator:CoordinatedSwitch(selectedProfile)
                        end
                    end,
                    order = 3,
                },
                newProfileSpacer = {
                    name = "",
                    type = "description",
                    width = "full",
                    order = 4,
                },
                newProfileName = {
                    name = "Create New Profile",
                    desc = "Type a name and press Enter to create a new profile across all linked scopes.",
                    type = "input",
                    width = 1.2,
                    get = function() return "" end,
                    set = function(_, value)
                        if not value or value == "" then return end
                        -- forceCreate = true so CoordinatedSwitch creates profiles in all linked scopes
                        ProfileCoordinator:CoordinatedSwitch(value, true)
                        selectedProfile = value
                    end,
                    order = 5,
                },
                deleteProfile = {
                    name = "Delete Profile",
                    desc = "Select a profile to delete. Built-in RealUI and RealUI-Healing profiles cannot be deleted, nor can the active profile.",
                    type = "select",
                    width = 1.2,
                    get = false,
                    hidden = function()
                        local current = RealUI.db:GetCurrentProfile()
                        local profiles = RealUI.db:GetProfiles()
                        if profiles then
                            for _, name in ipairs(profiles) do
                                if name ~= current and name ~= "RealUI" and name ~= "RealUI-Healing" then
                                    return false
                                end
                            end
                        end
                        return true
                    end,
                    set = function(_, value)
                        if value == "RealUI" or value == "RealUI-Healing" then
                            _G.print("|cffff4444RealUI Profiles:|r Cannot delete built-in profile '" .. value .. "'.")
                            return
                        end
                        if value == RealUI.db:GetCurrentProfile() then
                            _G.print("|cffff4444RealUI Profiles:|r Cannot delete the currently active profile.")
                            return
                        end
                        RealUI.db:DeleteProfile(value)
                        _G.print("|cff00ff00RealUI Profiles:|r Deleted profile '" .. value .. "'.")
                    end,
                    values = function()
                        local values = {}
                        local current = RealUI.db:GetCurrentProfile()
                        local profiles = RealUI.db:GetProfiles()
                        if profiles then
                            for _, name in ipairs(profiles) do
                                if name ~= current and name ~= "RealUI" and name ~= "RealUI-Healing" then
                                    values[name] = name
                                end
                            end
                        end
                        return values
                    end,
                    confirm = true,
                    confirmText = "Are you sure you want to delete this profile?",
                    order = 6,
                },
            },
        },
        scopeLinks = {
            name = "Scope Link Toggles",
            type = "group",
            inline = true,
            order = 2,
            args = {
                desc = {
                    name = "Control which profile scopes participate in Coordinated Switch and DualSpec-triggered switches.",
                    type = "description",
                    fontSize = "medium",
                    order = 0,
                },
                skinsLink = {
                    name = "Link Skins Scope",
                    desc = "When enabled, Skins profiles will switch alongside Core profiles during coordinated switches.\n\nDefault: disabled (appearance is typically shared across specs).",
                    type = "toggle",
                    get = function()
                        return ProfileCoordinator:IsScopeLinked(ProfileCoordinator.SCOPE_SKINS)
                    end,
                    set = function(_, value)
                        ProfileCoordinator:SetScopeLinked(ProfileCoordinator.SCOPE_SKINS, value)
                    end,
                    order = 1,
                },
                bt4Link = {
                    name = "Link Bartender4 Scope",
                    desc = "When enabled, Bartender4 profiles will switch alongside Core profiles during coordinated switches.\n\nDefault: enabled (action bars typically change with spec).",
                    type = "toggle",
                    get = function()
                        return ProfileCoordinator:IsScopeLinked(ProfileCoordinator.SCOPE_BT4)
                    end,
                    set = function(_, value)
                        ProfileCoordinator:SetScopeLinked(ProfileCoordinator.SCOPE_BT4, value)
                    end,
                    order = 2,
                },
            },
        },
        dualSpecMapping = {
            name = "DualSpec Mapping",
            type = "group",
            inline = true,
            order = 3,
            args = {
                desc = {
                    name = "|cffffcc00Specialization \226\134\146 Profile Mapping|r\n\n"
                        .. "Assign a Core profile to each of your specializations. When you change specs, "
                        .. "LibDualSpec will automatically switch to the assigned profile.",
                    type = "description",
                    fontSize = "medium",
                    order = 0,
                },
                dualSpecToggle = {
                    name = "Enable LibDualSpec Automatic Switching",
                    desc = "When enabled, LibDualSpec will automatically switch your Core profile when you change specializations.",
                    type = "toggle",
                    width = "full",
                    get = function()
                        if RealUI.db and RealUI.db.IsDualSpecEnabled then
                            return RealUI.db:IsDualSpecEnabled()
                        end
                        return false
                    end,
                    set = function(_, value)
                        if RealUI.db and RealUI.db.SetDualSpecEnabled then
                            RealUI.db:SetDualSpecEnabled(value)
                        end
                    end,
                    order = 1,
                },
            },
        },
    }

    -- Add per-spec dropdowns
    local specs = RealUI.charInfo.specs
    for specIndex = 1, #specs do
        local specData = specs[specIndex]
        local sIdx = specIndex

        generalArgs.dualSpecMapping.args["spec" .. specIndex] = {
            name = function()
                return FormatSpecName(sIdx, specData)
            end,
            desc = "Assign a Core profile to " .. specData.name .. " (" .. specData.role .. ").",
            type = "select",
            values = GetCoreProfileValues,
            get = function()
                if DualSpecSystem then
                    local profile = DualSpecSystem:GetSpecProfile(sIdx)
                    if profile then return profile end
                    return DualSpecSystem:GetDefaultProfileForSpec(sIdx)
                end
                return nil
            end,
            set = function(_, value)
                if DualSpecSystem then
                    DualSpecSystem:SetSpecProfile(sIdx, value)
                end
            end,
            order = 10 + specIndex,
        }
    end

    args.general = {
        name = "General",
        type = "group",
        order = nextOrder(),
        args = generalArgs,
    }
end


-- ========================================================================
-- Tab 2: Core Profile Scope
-- ========================================================================

local coreProfileOptions = ADBO:GetOptionsTable(RealUI.db)
-- Don't call LDS:EnhanceOptions here — DualSpec is handled on the General tab

-- AceDBOptions uses a shared args table — whitelist only the keys we want
-- so we don't mutate the shared table and break other consumers.
local keysToKeep = {desc = true, current = true, choose = true}

--- Shallow-copy a single AceConfig option entry so we can override fields
--- without mutating the shared AceDBOptions table.
local function ShallowCopyOption(src)
    local copy = {}
    for k, v in pairs(src) do
        copy[k] = v
    end
    return copy
end

do
    local filteredArgs = {}
    for k, v in pairs(coreProfileOptions.args) do
        if keysToKeep[k] then
            filteredArgs[k] = v
        end
    end
    -- Override choose.set to route through CoordinatedSwitch instead of
    -- the default handler.db:SetProfile(value) which only switches Core.
    if filteredArgs.choose then
        filteredArgs.choose = ShallowCopyOption(filteredArgs.choose)
        filteredArgs.choose.set = function(_, value)
            ProfileCoordinator:CoordinatedSwitch(value)
        end
    end
    coreProfileOptions.args = filteredArgs
end

args.coreScope = {
    name = "Core Profile Scope",
    type = "group",
    order = nextOrder(),
    args = {
        desc = {
            name = "|cff88ccffCore Profile Scope|r\n\n"
                .. "Controls the main RealUI AceDB profile (RealUI_ConfigDB). This includes Infobar settings, "
                .. "FrameMover positions, module toggles, HuD configuration, and all other core settings.\n\n"
                .. "LibDualSpec integration allows automatic profile switching when you change specializations.",
            type = "description",
            fontSize = "medium",
            order = 0,
        },
        coreProfiles = coreProfileOptions,
    },
}
args.coreScope.args.coreProfiles.order = 1

-- ========================================================================
-- Tab 3: Skins Profile Scope
-- ========================================================================

do
    local skinsModule = RealUI:GetModule("Skins", true)
    local skinsDB = skinsModule and skinsModule.db

    if skinsDB then
        local skinsProfileOptions = ADBO:GetOptionsTable(skinsDB)

        -- Whitelist only the keys we want (same filter as Core)
        do
            local filteredArgs = {}
            for k, v in pairs(skinsProfileOptions.args) do
                if keysToKeep[k] then
                    filteredArgs[k] = v
                end
            end
            -- Override choose.set to route through CoordinatedSwitch
            if filteredArgs.choose then
                filteredArgs.choose = ShallowCopyOption(filteredArgs.choose)
                filteredArgs.choose.set = function(_, value)
                    ProfileCoordinator:CoordinatedSwitch(value)
                end
            end
            skinsProfileOptions.args = filteredArgs
        end

        args.skinsScope = {
            name = "Skins Profile Scope",
            type = "group",
            order = nextOrder(),
            args = {
                desc = {
                    name = "|cff88ccffSkins Profile Scope|r\n\n"
                        .. "Controls appearance settings stored in RealUI_SkinsDB: frame color, button color, "
                        .. "fonts, UI scale, and addon skin toggles.\n\n"
                        .. "Skins profiles are typically shared across specializations since appearance "
                        .. "preferences rarely change between specs.",
                    type = "description",
                    fontSize = "medium",
                    order = 0,
                },
                skinsProfiles = skinsProfileOptions,
            },
        }
        args.skinsScope.args.skinsProfiles.order = 1
    else
        args.skinsScope = {
            name = "Skins Profile Scope",
            type = "group",
            order = nextOrder(),
            args = {
                desc = {
                    name = "|cff88ccffSkins Profile Scope|r\n\n"
                        .. "RealUI_Skins is not currently loaded. Skins profile management is unavailable.",
                    type = "description",
                    fontSize = "medium",
                    order = 0,
                },
            },
        }
    end
end

-- ========================================================================
-- Tab 4: BT4 Profile Scope
-- ========================================================================

args.bt4Scope = {
    name = "Bartender4 Profile Scope",
    type = "group",
    order = nextOrder(),
    args = {
        profileWarning = {
            name = "|cffff8800Profile management is handled by RealUI's Unified Profile Page. "
                .. "Do not create or switch profiles from here \226\128\148 use the Unified Profile Page "
                .. "in Advanced \226\134\146 Profiles instead.|r",
            type = "description",
            fontSize = "medium",
            order = 0,
        },
        desc = {
            name = "|cff88ccffBartender4 Profile Scope|r\n\n"
                .. "Bartender4 manages its own action bar profiles in Bartender4DB. "
                .. "RealUI ensures matching profile entries exist and can coordinate "
                .. "BT4 profile switches alongside Core and Skins scopes.\n\n"
                .. "Click the button below to open Bartender4's native configuration dialog "
                .. "for detailed action bar profile management.",
            type = "description",
            fontSize = "medium",
            order = 1,
        },
        openBT4 = {
            name = "Open Bartender4 Config",
            desc = "Opens the Bartender4 configuration dialog.",
            type = "execute",
            func = function()
                ACD:Open("Bartender4")
            end,
            order = 2,
        },
    },
}

-- ========================================================================
-- Tab 5: Export / Import
-- ========================================================================

args.exportImport = {
    name = "Export / Import",
    type = "group",
    order = nextOrder(),
    args = {
        desc = {
            name = "|cffffcc00Profile Export & Import|r\n\n"
                .. "Export your profile data as a shareable text string, or import a profile from another user. "
                .. "Export strings use AceSerializer-3.0 with base64 encoding and are safe to paste in chat, forums, or Discord.",
            type = "description",
            fontSize = "medium",
            order = 0,
        },
        exportCore = {
            name = "Export Core",
            desc = "Export the active Core profile to a copyable text string.",
            type = "execute",
            func = function()
                local str, err = ProfileExporter:ExportScope(ProfileCoordinator.SCOPE_CORE)
                if str then
                    lastExportString = str
                else
                    lastExportString = "Export failed: " .. tostring(err)
                end
            end,
            order = 1,
        },
        exportSkins = {
            name = "Export Skins",
            desc = "Export the active Skins profile to a copyable text string.",
            type = "execute",
            func = function()
                local str, err = ProfileExporter:ExportScope(ProfileCoordinator.SCOPE_SKINS)
                if str then
                    lastExportString = str
                else
                    lastExportString = "Export failed: " .. tostring(err)
                end
            end,
            order = 2,
        },
        exportBT4 = {
            name = "Export BT4",
            desc = "Export the active Bartender4 profile to a copyable text string.",
            type = "execute",
            func = function()
                local str, err = ProfileExporter:ExportScope(ProfileCoordinator.SCOPE_BT4)
                if str then
                    lastExportString = str
                else
                    lastExportString = "Export failed: " .. tostring(err)
                end
            end,
            order = 3,
        },
        exportAll = {
            name = "Export All Linked",
            desc = "Export all linked scope profiles into a single combined text string.",
            type = "execute",
            func = function()
                local str, err = ProfileExporter:ExportAllLinked()
                if str then
                    lastExportString = str
                else
                    lastExportString = "Export failed: " .. tostring(err)
                end
            end,
            order = 4,
        },
        exportOutput = {
            name = "Export String",
            desc = "Copy this string to share your profile. Click an Export button above to generate.",
            type = "input",
            multiline = 8,
            width = "full",
            get = function() return lastExportString end,
            set = function() end,
            order = 5,
        },
        importSpacer = {
            name = "\n",
            type = "description",
            order = 6,
        },
        importInput = {
            name = "Import String",
            desc = "Paste a RealUI export string here, then click Import to apply it.",
            type = "input",
            multiline = 8,
            width = "full",
            get = function() return importString end,
            set = function(_, value)
                importString = value
            end,
            order = 7,
        },
        importButton = {
            name = "Import",
            desc = "Validate and import the pasted export string into the current profile.\nPaste the string and click away from the text box first, then click Import.",
            type = "execute",
            func = function()
                if not importString or importString == "" then
                    _G.print("|cffff4444RealUI Profiles:|r No import string provided. Paste a string, click away from the text box, then click Import.")
                    return
                end
                local ok, err = _G.pcall(function()
                    local success, result = ProfileExporter:Import(importString)
                    if success then
                        local scopes = type(result) == "table" and _G.table.concat(result, ", ") or tostring(result)
                        _G.print("|cff00ff00RealUI Profiles:|r Import successful. Scopes imported: " .. scopes)
                        importString = ""
                        RealUI:ReloadUIDialog()
                    else
                        _G.print("|cffff4444RealUI Profiles:|r Import failed: " .. tostring(result))
                    end
                end)
                if not ok then
                    _G.print("|cffff4444RealUI Profiles:|r Import error: " .. tostring(err))
                end
            end,
            order = 8,
        },
    },
}

-- ========================================================================
-- Register the Unified Profile Page in private for Advanced.lua wiring
-- ========================================================================

private.unifiedProfilePage = unifiedProfilePage
