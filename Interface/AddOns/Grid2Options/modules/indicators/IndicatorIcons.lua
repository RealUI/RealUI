local media = LibStub("LibSharedMedia-3.0", true)
local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("icons", true, function(self, indicator)
	local statuses, options =  {}, {}
	self:MakeIndicatorAuraIconsLocationOptions(indicator, options)
	self:MakeIndicatorAuraIconsSizeOptions(indicator, options)
	self:MakeIndicatorAuraIconsBorderOptions(indicator, options)
	self:MakeIndicatorAuraIconsCustomOptions(indicator, options)
	self:MakeIndicatorDeleteOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options )
end)


function Grid2Options:MakeIndicatorAuraIconsBorderOptions(indicator, options, optionParams)
	self:MakeIndicatorBorderOptions(indicator, options)
	options.color1.hidden = function() return indicator.dbx.useStatusColor end
	options.borderOpacity = {
		type = "range",
		order = 20.5,
		name = L["Opacity"],
		desc = L["Set the opacity."],
		min = 0,
		max = 1,
		step = 0.01,
		bigStep = 0.05,
		get = function () return indicator.dbx.borderOpacity or 1 end,
		set = function (_, v)
			indicator.dbx.borderOpacity = v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
	}
	options.useStatusColor = {
		type = "toggle",
		name = L["Use Status Color"],
		desc = L["Always use the status color for the border"],
		order = 25,
		tristate = false,
		get = function () return indicator.dbx.useStatusColor end,
		set = function (_, v)
			indicator.dbx.useStatusColor = v or nil
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
	}
end


function Grid2Options:MakeIndicatorAuraIconsSizeOptions(indicator, options, optionParams)
	options.orientation = {
		type = "select",
		order = 10,
		name = L["Orientation"],
		desc = L["Set the icons orientation."],
		get = function () return indicator.dbx.orientation or "HORIZONTAL" end,
		set = function (_, v)
			indicator.dbx.orientation = v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
		values={ VERTICAL = L["VERTICAL"], HORIZONTAL = L["HORIZONTAL"] }
	}
	options.maxIcons = {
		type = "range",
		order = 11,
		name = L["Max Icons"],
		desc = L["Select maximum number of icons to display."],
		min = 1,
		max = 20,
		step = 1,
		get = function () return indicator.dbx.maxIcons or 6 end,
		set = function (_, v)
			indicator.dbx.maxIcons= v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
	}
	options.maxIconsPerRow = {
		type = "range",
		order = 12,
		name = L["Icons per row"],
		desc = L["Select the number of icons per row."],
		min = 1,
		max = 20,
		step = 1,
		get = function () return indicator.dbx.maxIconsPerRow or 3 end,
		set = function (_, v)
			indicator.dbx.maxIconsPerRow= v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
	}
	options.iconsize = {
		type = "range",
		order = 13,
		name = L["Icon Size"],
		desc = L["Adjust the size of the icons."],
		min = 5,
		max = 50,
		step = 1,
		get = function () return indicator.dbx.iconSize	or 12 end,
		set = function (_, v)
			indicator.dbx.iconSize = v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
	}
	options.iconSpacing = {
		type = "range",
		order = 14,
		name = L["Icon Spacing"],
		desc = L["Adjust the space between icons."],
		min = 0,
		max = 50,
		step = 1,
		get = function () return indicator.dbx.iconSpacing or 1 end,
		set = function (_, v)
			indicator.dbx.iconSpacing = v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
	}
end

function Grid2Options:MakeIndicatorAuraIconsLocationOptions(indicator, options)
	self:MakeIndicatorLocationOptions(indicator, options)
	options.point = nil
end

function Grid2Options:MakeIndicatorAuraIconsCustomOptions(indicator, options)
	self:MakeHeaderOptions( options, "Appearance"  )
	self:MakeHeaderOptions( options, "StackText" )
	options.fontJustify = {
		type = 'select',
		order = 100,
		name = L["Text Location"],
		desc = L["Text Location"],
		values = Grid2Options.pointValueListExtra,
		get = function()
			if not indicator.dbx.disableStack then
				local JustifyH = indicator.dbx.fontJustifyH or "CENTER"
				local JustifyV = indicator.dbx.fontJustifyV or "MIDDLE"
				return self.pointMapText[ JustifyH..JustifyV ]
			end	
			return "0"
		end,
		set = function(_, v)
			local dbx = indicator.dbx
			if v ~= "0" then
				local justify =  self.pointMapText[v]
				dbx.fontJustifyH = justify[1] 
				dbx.fontJustifyV = justify[2]
				dbx.disableStack = nil				
			else	
				dbx.disableStack = true
			end	
			self:RefreshIndicator( indicator, "Layout", "Update")
		end,
	}
	options.font = {
		type = "select", dialogControl = "LSM30_Font",
		order = 105,
		name = L["Font"],
		desc = L["Adjust the font settings"],
		get = function (info) return indicator.dbx.font end,
		set = function (info, v)
			indicator.dbx.font = v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
		values = AceGUIWidgetLSMlists.font,
		hidden= function() return indicator.dbx.disableStack end,
	}
	options.fontFlags = {
		type = "select",
		order = 106,
		name = L["Font Border"],
		desc = L["Set the font border type."],
		get = function () 
			local flags = indicator.dbx.fontFlags
			return (flags == nil and "OUTLINE") or (flags == "" and "NONE") or flags
		end,
		set = function (_, v)
			indicator.dbx.fontFlags =  v ~= "NONE" and v or ""
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
		values = Grid2Options.fontFlagsValues,
		hidden = function() return indicator.dbx.disableStack end,		
	}
	options.fontsize = {
		type = "range",
		order = 109,
		name = L["Font Size"],
		desc = L["Adjust the font size."],
		min = 6,
		max = 24,
		step = 1,
		get = function () return indicator.dbx.fontSize	or 9 end,
		set = function (_, v)
			indicator.dbx.fontSize = v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
		hidden= function() return indicator.dbx.disableStack end,
	}
	options.fontColor = {
		type = "color",
		order = 110,
		name = L["Color"],
		desc = L["Color"],
		get = function()
			local c = indicator.dbx.colorStack
			if c then 	return c.r, c.g, c.b, c.a
			else		return 1,1,1,1
			end
		end,
		set = function( info, r,g,b,a )
			local c = indicator.dbx.colorStack
			if c then c.r, c.g, c.b, c.a = r, g, b, a
			else	  indicator.dbx.colorStack= { r=r, g=g, b=b, a=a}
			end
			local indicatorKey = indicator.name
			self:RefreshIndicator(indicator, "Layout", "Update" )
		 end, 
		hasAlpha = true,
		hidden= function() return indicator.dbx.disableStack end,
	}
	self:MakeHeaderOptions( options, "Cooldown" )	
	options.disableCooldown = {
		type = "toggle",
		order = 130,
		name = L["Disable Cooldown"],
		desc = L["Disable the Cooldown Frame"],
		tristate = false,
		get = function () return indicator.dbx.disableCooldown end,
		set = function (_, v)
			indicator.dbx.disableCooldown = v or nil
			self:RefreshIndicator(indicator, "Layout", "Update" )
		end,
	}		
	options.reverseCooldown = {
		type = "toggle",
		order = 135,
		name = L["Reverse Cooldown"],
		desc = L["Set cooldown to become darker over time instead of lighter."],
		tristate = false,
		get = function () return indicator.dbx.reverseCooldown end,
		set = function (_, v)
			indicator.dbx.reverseCooldown = v or nil
			self:RefreshIndicator(indicator, "Layout", "Update" )
		end,
		hidden= function() return indicator.dbx.disableCooldown end,
	}		
	options.disableOmniCC = {
		type = "toggle",
		order = 140,
		name = L["Disable OmniCC"],
		desc = L["Disable OmniCC"],
		tristate = false,
		get = function () return indicator.dbx.disableOmniCC end,
		set = function (_, v)
			indicator.dbx.disableOmniCC = v or nil
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
		hidden= function() return indicator.dbx.disableCooldown end,
	}
end
