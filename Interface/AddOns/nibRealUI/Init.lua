local ADDON_NAME, private = ...

-- RealUI --
private.RealUI = _G.LibStub("AceAddon-3.0"):NewAddon(_G.RealUI, ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local RealUI = private.RealUI

local xpac, major, minor = _G.strsplit(".", _G.GetBuildInfo())
RealUI.isPatch = _G.tonumber(xpac) == 8 and (_G.tonumber(major) >= 0 and _G.tonumber(minor) >= 1)
RealUI.isDev = _G.IsAddOnLoaded("nibRealUI_Dev")

RealUI.charName = _G.UnitName("player")
RealUI.realm = _G.GetRealmName()
RealUI.faction = _G.UnitFactionGroup("player")
RealUI.classLocale, RealUI.class, RealUI.classID = _G.UnitClass("player")
RealUI.numSpecs = _G.GetNumSpecializationsForClassID(RealUI.classID)

RealUI.globals = {
    anchorPoints = {
        "TOPLEFT",    "TOP",    "TOPRIGHT",
        "LEFT",       "CENTER", "RIGHT",
        "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT",
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
