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
local interfaceVersion = select(4, _G.GetBuildInfo())
-- WoW Forever (1.60.x, Blizzard codename Camelot) reports a 1.x interface
-- number (16000-19999) but runs the Mainline UI architecture: WOW_PROJECT_ID
-- is WOW_PROJECT_MAINLINE there, so isRetail is true on Forever and is never
-- a sufficient gate on its own. Gate Forever-specific behaviour on isForever.
RealUI.isForever = interfaceVersion >= 16000 and interfaceVersion < 20000
RealUI.isRetail = _G.WOW_PROJECT_ID == _G.WOW_PROJECT_MAINLINE or RealUI.isForever
RealUI.isMidnight = RealUI.isRetail and interfaceVersion >= 120000
RealUI.isBetaBuild = RealUI.isRetail and interfaceVersion == 130000
-- Forever's UI is 12.1-derived but reports interface 16001, so isMidnight is
-- false there. Gate "the 12.x code path exists" on isTwelveAPI; keep
-- isMidnight for Midnight content that Forever does not have.
RealUI.isTwelveAPI = RealUI.isMidnight or RealUI.isForever

-- WoW Forever builds on which no secure handler snippet compiles: the
-- Blizzard_EnvironmentCleanup TOC's dependency on
-- Blizzard_RestrictedAddOnEnvironment lacks `camelot`, so the LoadFirst
-- cleanup nils `loadstring_untainted` before RestrictedExecution.lua captures
-- it (reported upstream; a one-word fix on Blizzard's side). Everything
-- snippet-driven stands in or stands down on these builds: RealUI_ActionBars'
-- SnippetShim, the oUF party/raid headers. Addon code has no quiet way to
-- probe this at runtime (see the realui-forever tasks file), hence a list.
-- Add a build when LibActionButton still logs RestrictedExecution.lua:79 on
-- it; a fixed build drops out by itself.
RealUI.BROKEN_SECURE_SNIPPET_BUILDS = {
    ["69913"] = true, -- 1.60.1, 2026-09-22
}
function RealUI.SecureSnippetsBroken()
    local _, build = _G.GetBuildInfo()
    return RealUI.isForever and RealUI.BROKEN_SECURE_SNIPPET_BUILDS[build] == true
end
RealUI.isDragonflight = interfaceVersion >= 100002 or interfaceVersion <= 110000

-- Realm Information Management
-- Forever has no realms: GetRealmName() returns nothing and
-- GetNormalizedRealmName() never arrives. AceDB-3.0 substitutes the active
-- ruleset ("Hardcore", "RP", "PvP", "PvE") for the realm in its character
-- key there, and RealUI.key is used to index AceDB's own profileKeys/char
-- tables in the sibling addon DBs, so the realm used here must be
-- byte-identical to AceDB's. Keep this in step with the
-- `version > 16000 and version < 20000` block in AceDB-3.0.lua.
local function GetRealmKey()
    if not RealUI.isForever then
        return _G.GetRealmName()
    end

    local rules = _G.Enum.GameRule
    local IsGameRuleActive = _G.C_GameRules.IsGameRuleActive
    if IsGameRuleActive(rules.HardcoreRuleset) then
        return "Hardcore"
    elseif IsGameRuleActive(rules.RPRuleset) then
        return "RP"
    elseif IsGameRuleActive(rules.PvPRuleset) then
        return "PvP"
    end
    return "PvE"
end

RealUI.realmInfo = {
    realm = GetRealmKey(),
    connectedRealms = _G.GetAutoCompleteRealms() or {},
    id = _G.GetRealmID(),
}

if RealUI.realmInfo.connectedRealms[1] then
    RealUI.realmInfo.isConnected = true
end

-- Realm Normalization Handler
local function CheckforRealm()
    if RealUI.isForever then
        -- The ruleset word has no spaces or punctuation, so it is already
        -- normalized; the poll below would otherwise never end.
        RealUI.realmInfo.realmNormalized = RealUI.realmInfo.realm
    else
        RealUI.realmInfo.realmNormalized = _G.GetNormalizedRealmName()
    end
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

-- Character key. This is the only place it is built: it must match the
-- charKey AceDB-3.0 derives for this character (see GetRealmKey above)
-- because ProfileCoordinator, ProfileExporter, AddonControl and the reset
-- path all use it to index AceDB's profileKeys/char tables directly.
RealUI.key = ("%s - %s"):format(RealUI.charInfo.name, RealUI.charInfo.realm)

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

