local media = LibStub("LibSharedMedia-3.0", true)
local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("icon", true, function(self, indicator)
	local statuses, options =  {}, {}
	self:MakeIndicatorTypeOptions(indicator, options)
	self:MakeIndicatorLocationOptions(indicator, options)
	self:MakeIndicatorSizeOptions(indicator, options)
	self:MakeIndicatorBorderOptions(indicator, options)
	self:MakeIndicatorIconCustomOptions(indicator, options)
	self:MakeIndicatorDeleteOptions(indicator, options)
	self:MakeIndicatorStatusOptions(indicator, statuses)
	self:AddIndicatorOptions(indicator, statuses, options )
end)

function Grid2Options:MakeIndicatorIconCustomOptions(indicator, options)
	self:MakeHeaderOptions( options, "Appearance"  )
	options.useStatusColor = {
		type = "toggle",
		name = L["Use Status Color"],
		desc = L["Always use the status color for the border"],
		order = 25,
		tristate = false,
		get = function () return indicator.dbx.useStatusColor end,
		set = function (_, v)
			indicator.dbx.useStatusColor = v or nil
			self:RefreshIndicator(indicator, "Update")
		end,
	}
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
			local old = dbx.disableStack
			if v ~= "0" then
				local justify =  self.pointMapText[v]
				dbx.fontJustifyH = justify[1] 
				dbx.fontJustifyV = justify[2]
				dbx.disableStack = nil				
			else	
				dbx.disableStack = true
			end	
			self:RefreshIndicator( indicator, dbx.disableStack==old and "Layout" or "Create" )
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
			self:RefreshIndicator(indicator, "Create")
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
			self:RefreshIndicator(indicator, "Create")
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
		get = function () return indicator.dbx.fontSize	end,
		set = function (_, v)
			indicator.dbx.fontSize = v
			self:RefreshIndicator(indicator, "Create")
		end,
		hidden= function() return indicator.dbx.disableStack end,
	}
	options.fontColor = {
		type = "color",
		order = 110,
		name = L["Color"],
		desc = L["Color"],
		get = function()
			local c = indicator.dbx.stackColor
			if c then 	return c.r, c.g, c.b, c.a
			else		return 1,1,1,1
			end
		end,
		set = function( info, r,g,b,a )
			local c = indicator.dbx.stackColor
			if c then c.r, c.g, c.b, c.a = r, g, b, a
			else	  indicator.dbx.stackColor= { r=r, g=g, b=b, a=a}
			end
			local indicatorKey = indicator.name
			self:RefreshIndicator(indicator, "Create")
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
			self:RefreshIndicator(indicator, "Create")
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
			self:RefreshIndicator(indicator, "Create")
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
			self:RefreshIndicator(indicator, "Create")
		end,
		hidden= function() return indicator.dbx.disableCooldown end,
	}
	self:MakeHeaderOptions( options, "Animation" )
	options.animEnabled = {
		type = "toggle",
		order = 155,
		name = L["Enable animation"],
		desc = L["Turn on/off zoom animation of icons."],
		tristate = false,
		get = function () return indicator.dbx.animEnabled end,
		set = function (_, v)
			indicator.dbx.animEnabled = v or nil
			if not v then
				indicator.dbx.animScale = nil
				indicator.dbx.animDuration = nil
			end
			indicator:UpdateDB()
		end,
	}
	options.animDuration = {
		type = "range",
		order = 160,
		name = L["Duration"],
		desc = L["Sets the duration in seconds."],
		min  = 0.1,
		max  = 2,
		step = 0.1,
		get = function () return indicator.dbx.animDuration or 0.7 end,
		set = function (_, v)
			indicator.dbx.animDuration = v
			indicator:UpdateDB()
		end,
		hidden= function() return not indicator.dbx.animEnabled end,		
	}
	options.animScale = {
		type = "range",
		order = 165,
		name = L["Scale"],
		desc = L["Sets the zoom factor."],
		min  = 1.1,
		max  = 3,
		step = 0.1,
		get = function () return indicator.dbx.animScale or 1.5	end,
		set = function (_, v)
			indicator.dbx.animScale = v
			indicator:UpdateDB()
		end,
		hidden= function() return not indicator.dbx.animEnabled end,
	}

end
