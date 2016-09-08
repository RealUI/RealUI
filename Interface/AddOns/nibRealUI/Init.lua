local ADDON_NAME, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
private.RealUI = _G.LibStub("AceAddon-3.0"):NewAddon(_G.RealUI, ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local RealUI = private.RealUI

RealUI.TOC = _G.select(4, _G.GetBuildInfo())
RealUI.isDev = _G.IsAddOnLoaded("nibRealUI_Dev")

RealUI.name = _G.UnitName("player")
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

do
    local WorldMapFrame = _G.WorldMapFrame
    local InCombatLockdown = _G.InCombatLockdown
    
    local WorldMapBountyBoardMixin = _G.WorldMapBountyBoardMixin
    function WorldMapFrame.UIElementsFrame.BountyBoard.GetDisplayLocation(self)
        if InCombatLockdown() then
            return
        end
     
        return WorldMapBountyBoardMixin.GetDisplayLocation(self)
    end
     
    local WorldMapActionButtonMixin = _G.WorldMapActionButtonMixin
    function WorldMapFrame.UIElementsFrame.ActionButton.GetDisplayLocation(self, useAlternateLocation)
        if InCombatLockdown() then
            return
        end
     
        return WorldMapActionButtonMixin.GetDisplayLocation(self, useAlternateLocation)
    end
     
    function WorldMapFrame.UIElementsFrame.ActionButton.Refresh(self)
        if InCombatLockdown() then
            return
        end
     
        WorldMapActionButtonMixin.Refresh(self)
    end
end
