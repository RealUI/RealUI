local _, private = ...

-- RealUI --
local RealUI = private.RealUI

RealUI.AddOns.BugSack = function()
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
