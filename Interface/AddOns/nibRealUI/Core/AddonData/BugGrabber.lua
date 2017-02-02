local _, private = ...

-- RealUI --
local RealUI = private.RealUI

RealUI.AddOns.BugGrabber = function()
	_G.BugGrabberDB = {
		["stopnag"] = 50001,
		["throttle"] = true,
		["limit"] = 50,
		["errors"] = {},
		["save"] = false,
		["session"] = 1,
	}
end
