local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI

RealUI.LoadAddOnData_BugSack = function()
	_G.BugSackDB = {
		["fontSize"] = "GameFontHighlight",
		["auto"] = false,
		["soundMedia"] = "BugSack: Fatality",
		["mute"] = true,
		["chatframe"] = false,
	}
	_G.BugSackLDBIconDB = {
		["hide"] = false,
	}
end
