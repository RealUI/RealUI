local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("range", "target", function(self, status, options, optionParams)
	local rangeList = {}
	for range in pairs(status.GetRanges()) do
		rangeList[range] = tonumber(range) and L["%d yards"]:format(tonumber(range)) or L['Heal Range']
	end
	options.default = {
		type = "range",
		order = 55,
		name = L["Out of range alpha"],
		desc = L["Alpha value when units are way out of range."],
		min = 0,
		max = 1,
		step = 0.01,
		get = function () return status.dbx.default	end,
		set = function (_, v) status.dbx.default = v; status:UpdateDB()	end,
	}
	options.update = {
		type = "range",
		order = 56,
		name = L["Update rate"],
		desc = L["Rate at which the status gets updated"],
		min = 0,
		max = 5,
		step = 0.05,
		bigStep = 0.1,
		get = function () return status.dbx.elapsed	end,
		set = function (_, v) status.dbx.elapsed = v; status:UpdateDB()	end,
	}
	options.range = {
		type = "select",
		order = 57,
		name = L["Range"],
		desc = L["Range in yards beyond which the status will be lost."],
		get = function () return status.dbx.range and tostring(status.dbx.range) or "38" end,
		set = function (_, v) status.dbx.range = v; status:UpdateDB() end,
		values = rangeList,
	}
	options.separation = {
		type = "header",
		order = 20,
		name = "",
	}
	self:MakeStatusColorOptions(status, options, { 
		width = "full",
		color1 = L["Out of range"] 
	} )
end )
