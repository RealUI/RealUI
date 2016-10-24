local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("square", true, function(self, indicator)
	local layout, statuses = {}, {}
	self:MakeIndicatorTextureOptions(indicator, layout)
	self:MakeIndicatorSquareSizeOptions(indicator, layout)
	self:MakeIndicatorTypeOptions(indicator, layout)
	self:MakeIndicatorLocationOptions(indicator, layout)
	self:MakeIndicatorBorderOptions(indicator, layout)
	self:MakeIndicatorDeleteOptions(indicator, layout)
	self:MakeIndicatorStatusOptions(indicator, statuses)	
	self:AddIndicatorOptions(indicator, statuses, layout )
end)

function Grid2Options:MakeIndicatorSquareSizeOptions(indicator, options)
	self:MakeHeaderOptions( options, "Appearance" )
	options.size = {
		type = "range",
		order = 12,
		name = L["Size"],
		desc = L["Adjust the size of the indicator."],
		min = 0,
		softMax = 50,
		step = 1,
		get = function () return indicator.dbx.size	end,
		set = function (_, v)
			indicator.dbx.size = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return not indicator.dbx.size end
	}
	options.width = {
		type = "range",
		order = 13,
		name = L["Width"],
		desc = L["Adjust the width of the indicator."],
		min = 0,
		softMax = 50,		
		step = 1,
		get = function () return indicator.dbx.width end,
		set = function (_, v)
			indicator.dbx.width = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.size end
	}
	options.height = {
		type = "range",
		order = 14,
		name = L["Height"],
		desc = L["Adjust the height of the indicator."],
		min = 0,
		softMax = 50,
		step = 1,
		get = function () return indicator.dbx.height end,
		set = function (_, v)
			indicator.dbx.height = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		hidden = function() return indicator.dbx.size end
	}
	options.sizeToggle = {
		type = "toggle",
		name = L["Rectangle"],
		desc = L["Allows to independently adjust width and height."],
		order = 15,
		tristate = false,
		get = function () return not indicator.dbx.size end,
		set = function (_, v)
			if v then
				indicator.dbx.width = indicator.dbx.size or 5
				indicator.dbx.height = indicator.dbx.size or 5
				indicator.dbx.size = nil
			else
				indicator.dbx.size = indicator.dbx.width
				indicator.dbx.width = nil
				indicator.dbx.height = nil
			end
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
end
