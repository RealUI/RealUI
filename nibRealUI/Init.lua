local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals select

local loaded = _G.LoadAddOn("RealUI_Skins")
local tries = 1
while not loaded do
    loaded = _G.LoadAddOn("RealUI_Skins")
    tries = tries + 1
    if tries > 3 then
        _G.StaticPopupDialogs["REALUI_SKINS_NOT_FOUND"] = {
            text = "Module \"Skins\" was not found. RealUI will now be disabled.",
            button1 = _G.OKAY,
            OnShow = function(self)
                self:SetScale(2)
                self:ClearAllPoints()
                self:SetPoint("CENTER")
            end,
            OnAccept = function(self, data)
                _G.DisableAddOn("nibRealUI")
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

-- RealUI --
private.RealUI = _G.LibStub("AceAddon-3.0"):NewAddon(_G.RealUI, ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local RealUI = private.RealUI

RealUI.isPatch = select(4, _G.GetBuildInfo()) >= 90001

RealUI.realmInfo = {
    realm = _G.GetRealmName(),
    connectedRealms = _G.GetAutoCompleteRealms(),
    id = _G.GetRealmID(),
}

if RealUI.realmInfo.connectedRealms[1] then
    RealUI.realmInfo.isConnected = true
end

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

if not CheckforRealm() then
    local frame = _G.CreateFrame("Frame")
    frame:SetScript("OnUpdate", function(self)
        self:SetShown(not CheckforRealm())
    end)
end

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

for specIndex = 1, _G.GetNumSpecializationsForClassID(classID) do
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

-- Disable cargBags
local enabled = _G.GetAddOnEnableState(RealUI.charInfo.name, "RealUI_Inventory")
if enabled > 0 then
    _G.DisableAddOn("cargBags_Nivaya", true)
end

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

