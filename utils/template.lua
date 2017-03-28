local ADDON_NAME, private = ...

-- Lua Globals --
local next = _G.next

-- Libs --
local LCS = LibStub("LibCoolStuff")

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, ndb, ndbc

local MODNAME = "TemplateMod"
local TemplateMod = RealUI:NewModule(MODNAME)
