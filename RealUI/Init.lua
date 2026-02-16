local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals select

-- Core RealUI Framework Initialization
-- This file handles the initial setup of the RealUI namespace and core dependencies

-- Ensure RealUI_Skins is loaded before proceeding
local loaded = _G.C_AddOns.LoadAddOn("RealUI_Skins")
local tries = 1
while not loaded do
    loaded = _G.C_AddOns.LoadAddOn("RealUI_Skins")
    tries = tries + 1
    if tries > 3 then
        _G.StaticPopupDialogs["REALUI_SKINS_NOT_FOUND"] = {
            text = "Module \"Skins\" was not found. RealUI will now be disabled.",
            button1 = _G.OKAY,
            OnShow = function(dialog)
                dialog:SetScale(2)
                dialog:ClearAllPoints()
                dialog:SetPoint("CENTER")
            end,
            OnAccept = function(dialog, data)
                _G.C_AddOns.DisableAddOn(ADDON_NAME)
                _G.ReloadUI()
            end,
            timeout = 0,
            exclusive = 1,
            whileDead = 1,
        }
        _G.StaticPopup_Show("REALUI_SKINS_NOT_FOUND")
        break
    end
end

-- Initialize RealUI Core Object with AceAddon-3.0 framework
private.RealUI = _G.LibStub("AceAddon-3.0"):NewAddon(_G.RealUI, ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local RealUI = private.RealUI

-- Version and Build Detection
RealUI.isRetail = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE
RealUI.isMidnight = RealUI.isRetail and select(4, _G.GetBuildInfo()) >= 120000
RealUI.isBetaBuild = RealUI.isRetail and select(4, _G.GetBuildInfo()) == 120001
RealUI.isDragonflight = select(4, _G.GetBuildInfo()) >= 100002 or select(4, _G.GetBuildInfo()) <= 110000

-- Realm Information Management
RealUI.realmInfo = {
    realm = _G.GetRealmName(),
    connectedRealms = _G.GetAutoCompleteRealms(),
    id = _G.GetRealmID(),
}

if RealUI.realmInfo.connectedRealms[1] then
    RealUI.realmInfo.isConnected = true
end

-- Realm Normalization Handler
local function CheckforRealm()
    RealUI.realmInfo.realmNormalized = _G.GetNormalizedRealmName()
    if RealUI.realmInfo.realmNormalized then
        if not RealUI.realmInfo.isConnected then
            RealUI.realmInfo.connectedRealms[1] = RealUI.realmInfo.realmNormalized
        end

        RealUI:SendMessage("NormalizedRealmReceived")
        return true
    end

    return false
end

-- Ensure realm information is available
if not CheckforRealm() then
    local frame = _G.CreateFrame("Frame")
    frame:SetScript("OnUpdate", function(dialog)
        dialog:SetShown(not CheckforRealm())
    end)
end

-- Character Information Management
local classLocale, classToken, classID = _G.UnitClass("player")
RealUI.charInfo = {
    name = _G.UnitName("player"),
    realm = RealUI.realmInfo.realm,
    faction = _G.UnitFactionGroup("player"),
    class = {
        locale = classLocale,
        token = classToken,
        id = classID,
        color = _G.CUSTOM_CLASS_COLORS[classToken] or _G.CUSTOM_CLASS_COLORS.PRIEST
    },
    specs = {
        current = {}
    }
}

-- Specialization Information Setup
for specIndex = 1, _G.C_SpecializationInfo.GetNumSpecializationsForClassID(classID) do
    local id, name, _, iconID, role, isRecommended = _G.GetSpecializationInfoForClassID(classID, specIndex)
    RealUI.charInfo.specs[specIndex] = {
        index = specIndex,
        id = id,
        name = name,
        icon = iconID,
        role = role,
        isRecommended = isRecommended,
    }

    if isRecommended then
        RealUI.charInfo.specs.current = RealUI.charInfo.specs[specIndex]
    end
end

-- Addon Compatibility Management
-- Disable cargBags if RealUI_Inventory is enabled
local enabled = _G.C_AddOns.GetAddOnEnableState("RealUI_Inventory", RealUI.charInfo.name) == _G.Enum.AddOnEnableState.All;
if enabled == true then
    _G.C_AddOns.DisableAddOn("cargBags_Nivaya")
end

-- Global Constants and Utilities
RealUI.globals = {
    anchorPoints = {
        "TOPLEFT",    "TOP",    "TOPRIGHT",
        "LEFT",       "CENTER", "RIGHT",
        "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT",
    },
    cornerPoints = {
        "TOPLEFT",
        "TOPRIGHT",
        "BOTTOMLEFT",
        "BOTTOMRIGHT",
    },
    stratas = {
        "BACKGROUND",
        "LOW",
        "MEDIUM",
        "HIGH",
        "DIALOG",
        "TOOLTIP"
    }
}

-- Framework Status
RealUI.isInitialized = false
RealUI.isEnabled = false

