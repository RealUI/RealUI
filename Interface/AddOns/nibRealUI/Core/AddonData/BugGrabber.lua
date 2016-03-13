local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI

RealUI.LoadAddOnData_BugGrabber = function()
	_G.BugGrabberDB = {
		["stopnag"] = 50001,
		["throttle"] = true,
		["limit"] = 50,
		["errors"] = {},
		["save"] = false,
		["session"] = 1,
	}
end
