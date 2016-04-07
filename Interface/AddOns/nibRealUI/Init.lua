local ADDON_NAME, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
private.RealUI = _G.LibStub("AceAddon-3.0"):NewAddon(_G.RealUI, ADDON_NAME, "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local RealUI = private.RealUI

RealUI.TOC = _G.select(4, _G.GetBuildInfo())
RealUI.isBeta = RealUI.TOC >= 70000
RealUI.isDev = _G.IsAddOnLoaded("nibRealUI_Dev")

RealUI.name = _G.UnitName("player")
RealUI.realm = _G.GetRealmName()
RealUI.faction = _G.UnitFactionGroup("player")
RealUI.classLocale, RealUI.class, RealUI.classID = _G.UnitClass("player")
