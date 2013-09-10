local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

nibRealUI.LoadAddOnData_BugGrabber = function()
	BugGrabberDB = {
		["stopnag"] = 50001,
		["throttle"] = true,
		["limit"] = 50,
		["errors"] = {},
		["save"] = false,
		["session"] = 1,
	}
end