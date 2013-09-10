local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
nibRealUI.LoadAddOnData_BugSack = function()
	BugSackDB = {
		["fontSize"] = "GameFontHighlight",
		["auto"] = false,
		["soundMedia"] = "BugSack: Fatality",
		["mute"] = true,
		["chatframe"] = false,
	}
	BugSackLDBIconDB = {
		["hide"] = true,
	}
end