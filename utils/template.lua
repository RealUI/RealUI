--[[
local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals

-- Libs --
local LCS = LibStub("LibCoolStuff")

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L

local MODNAME = "Template"
local Template = RealUI:NewModule(MODNAME)




function Template:OnInitialize()
    self.db = _G.LibStub("AceDB-3.0"):New("RealUI_TemplateDB", defaults, true)
end
]]
