local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local ndb

local _
local MODNAME = "HuDConfig_ActionBars"
local HuDConfig_ActionBars = nibRealUI:CreateModule(MODNAME)

local Bar4
local buttonSizes = {
	bars = 26,
	petBar = 22,
	stanceBar = 22,
}

local function IsOdd(val)
	return val % 2 == 1 and true or false
end

function HuDConfig_ActionBars:ApplySettings(tag)
end

----------
function HuDConfig_ActionBars:OnInitialize()
	ndb = nibRealUI.db.profile

	Bar4 = LibStub("AceAddon-3.0"):GetAddon("Bartender4", true)
end
