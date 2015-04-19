local L = Grid2Options.L

Grid2Options:RegisterStatusOptions( "direction", "target", function(self, status, options)
	local mask = L["%d yards"]
	self:MakeStatusColorOptions( status, options, status.dbx.colorCount and { 
		color1 = string.format( mask, 10), 
		color2 = string.format( mask, 20), 
		color3 = string.format( mask, 30), 
		color4 = string.format( mask, 40), 
		color5 = string.format( "+"..mask, 40), 
	} or nil )
	options.colorCount = {
		type = "toggle",
		order = 80,
		name = "Color by distance",
		get = function () return status.dbx.colorCount~=nil end,
		set = function (_, v)
			if v then
				status.dbx.colorCount = 5
				status.dbx.color2 = { r=0,g=1  ,b=0.6,a=1 }
				status.dbx.color3 = { r=1,g=0.9,b=0  ,a=1 }
				status.dbx.color4 = { r=1,g=0.5,b=0  ,a=1 }
				status.dbx.color5 = { r=1,g=0  ,b=0  ,a=1 }
			else
				status.dbx.colorCount = nil
			end
			self:MakeStatusOptions(status)
			status:UpdateDB()
		end,
	}
	options.colorSpacer = {
		type = "header",
		order = 50,
		name = "",
	}
	options.updateRate = {
		type = "range",
		order = 90,
		width = "normal",
		name = L["Update rate"],
		desc = L["Rate at which the status gets updated"],
		min = 0.05,
		max = 2,
		step = 0.01,
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
		hidden = function ()	return status.dbx.showOnlyStickyUnits end,
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
		hidden = function ()	return status.dbx.showOnlyStickyUnits end,
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
		hidden = function ()	return status.dbx.showOnlyStickyUnits end,
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
		hidden = function ()	return status.dbx.showOnlyStickyUnits end,
	}
	options.spacer2 = {
		type = "header",
		order = 125,
		name = L["Sticky Units"],
	}
	options.stickyTarget = {
		type = "toggle",
		order = 130,
		name = L["Target"],
		desc = L["Always display direction for target"],
		tristate = false,
		get = function ()	return status.dbx.StickyTarget end,
		set = function (_, v)
			status.dbx.StickyTarget = v or nil
			status:UpdateDB()
		end,
	}
	options.stickyMouseover = {
		type = "toggle",
		order = 140,
		name = L["Mouseover"],
		desc = L["Always display direction for mouseover"],
		tristate = false,
		get = function ()	return status.dbx.StickyMouseover end,
		set = function (_, v)
			status.dbx.StickyMouseover = v or nil
			status:UpdateDB()
		end,
	}
	options.stickyFocus = {
		type = "toggle",
		order = 150,
		name = L["Focus"],
		desc = L["Always display direction for focus"],
		tristate = false,
		get = function ()	return status.dbx.StickyFocus end,
		set = function (_, v)
			status.dbx.StickyFocus = v or nil
			status:UpdateDB()
		end,
	}
	options.stickyTanks = {
		type = "toggle",
		order = 160,
		name = L["Tanks"],
		desc = L["Always display direction for tanks"],
		tristate = false,
		get = function ()	return status.dbx.StickyTanks end,
		set = function (_, v)
			status.dbx.StickyTanks = v or nil
			status:UpdateDB()
		end,
	}
	options.spacer3 = {
		type = "header",
		order = 165,
		name = "",
	}
	options.showOnlyStickyUnits = {
		type = "toggle",
		order = 170,
		width = "full",
		name = L["Show only selected sticky units"],
		tristate = false,
		get = function ()	return status.dbx.showOnlyStickyUnits end,
		set = function (_, v)
			status.dbx.showOnlyStickyUnits = v or nil
			status:UpdateDB()
		end,
	}
end, {
	title = L["arrows pointing to each raid member"],
	titleIcon = "Interface\\Vehicles\\Arrow",
	titleIconCoords = {0.1,1,0,1},
})