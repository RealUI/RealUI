local L = Grid2Options.L

Grid2Options:RegisterStatusOptions( "direction", "target", function(self, status, options)
	self:MakeStatusStandardOptions(status, options)
	options.updateRate = {
		type = "range",
		order = 90,
		name = L["Update rate"],
		desc = L["Rate at which the status gets updated"],
		min = 0,
		max = 5,
		step = 0.1,
		get = function ()
			return status.dbx.updateRate or 0.2
		end,
		set = function (_, v)
			status.dbx.updateRate = v
			status:RestartTimer()
		end,
	}
	options.spacer = {
		type = "header",
		order = 99,
		name = L["Display"],
	}
	options.showOutOfRange = {
		type = "toggle",
		order = 100,
		name = L["Out of Range"],
		desc = L["Display status for units out of range."],
		tristate = false,
		get = function ()	return status.dbx.ShowOutOfRange end,
		set = function (_, v)
			status.dbx.ShowOutOfRange = v or nil
			status:UpdateDB()
		end,
	}
	options.showVisible = {
		type = "toggle",
		order = 110,
		name = L["Visible Units"],
		desc = L["Display status for units less than 100 yards away"],
		tristate = false,
		get = function () return status.dbx.ShowVisible end,
		set = function (_, v)
			status.dbx.ShowVisible = v or nil
			status:UpdateDB()
		end,
	}
	options.showDead = {
		type = "toggle",
		order = 120,
		name = L["Dead Units"],
		desc = L["Display status only for dead units"],
		tristate = false,
		get = function ()	return status.dbx.ShowDead end,
		set = function (_, v)
			status.dbx.ShowDead = v or nil
			status:UpdateDB()
		end,
	}
end, {
	title = L["arrows pointing to each raid member"],
	titleIcon = "Interface\\Vehicles\\Arrow",
	titleIconCoords = {0.1,1,0,1},
})