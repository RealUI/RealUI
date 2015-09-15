-- Lua Globals --
local _G = _G
local min, max, abs, floor = _G.math.min, _G.math.max, _G.math.abs, _G.math.floor
local next, type = _G.next, _G.type

-- WoW Globals --
local CreateFrame = _G.CreateFrame

-- RealUI --
local ADDON_NAME, private = ...
local RealUI =  _G.RealUI
local L = RealUI.L
local db, ndb, ndbc

local MODNAME = "TemplateMod"
local TemplateMod = RealUI:CreateModule(MODNAME)

-- Libs --
local ACR = LibStub("AceConfigRegistry-3.0")
