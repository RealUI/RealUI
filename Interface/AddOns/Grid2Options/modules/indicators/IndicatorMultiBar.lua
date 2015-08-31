-- bar indicator options

local Grid2Options = Grid2Options
local L = Grid2Options.L

Grid2Options:RegisterIndicatorOptions("multibar", true, function(self, indicator)
	local layout, bars  = {}, {}
	self:MakeIndicatorLocationOptions(indicator,layout)
	self:MakeIndicatorMultiBarAppearanceOptions(indicator,layout)
	self:MakeIndicatorMultiBarMiscOptions(indicator,layout)
	self:MakeIndicatorDeleteOptions(indicator, layout)
	self:MakeIndicatorMultiBarTexturesOptions(indicator,bars)	
	local options = Grid2Options.indicatorOptions[indicator.name].args;	wipe(options)	
	options["bars"]   = { type = "group", order = 10, name = L["Bars"], args = bars }
	options["layout"] = { type = "group", order = 30, name = L["Layout"], args = layout }
	if indicator.dbx.textureColor==nil then
		local colors = {}
		self:MakeIndicatorStatusOptions(indicator.sideKick, colors)
		options["colors"] = { type = "group", order = 20, name = L["Main Bar Color"], args = colors  }
	end	
end)

-- Grid2Options:MakeIndicatorBarDisplayOptions()
function Grid2Options:MakeIndicatorMultiBarAppearanceOptions(indicator,options)
	self:MakeHeaderOptions( options, "Appearance" )
	options.orientation = {
		type = "select",
		order = 15,
		name = L["Orientation of the Bar"],
		desc = L["Set status bar orientation."],
		get = function ()
			return indicator.dbx.orientation or "DEFAULT"
		end,
		set = function (_, v)
			if v=="DEFAULT" then v= nil	end
			indicator:SetOrientation(v)
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
		values={ ["DEFAULT"]= L["DEFAULT"], ["VERTICAL"] = L["VERTICAL"], ["HORIZONTAL"] = L["HORIZONTAL"]}
	}
	options.barWidth= {
		type = "range",
		order = 30,
		name = L["Bar Width"],
		desc = L["Choose zero to set the bar to the same width as parent frame"],
		min = 0,
		max = 75,
		step = 1,
		get = function ()
			return indicator.dbx.width
		end,
		set = function (_, v)
			if v==0 then v= nil end
			indicator.dbx.width = v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,	
	}
	options.barHeight= {
		type = "range",
		order = 40,
		name = L["Bar Height"],
		desc = L["Choose zero to set the bar to the same height as parent frame"],
		min = 0,
		max = 75,
		step = 1,
		get = function ()
			return indicator.dbx.height
		end,
		set = function (_, v)
			if v==0 then v= nil end
			indicator.dbx.height = v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,	
	}
	options.reverseFill= {
		type = "toggle",
		name = L["Reverse Fill"],
		desc = L["Fill the bar in reverse."],
		order = 55,
		tristate = false,
		get = function () return indicator.dbx.reverseFill end,
		set = function (_, v)
			indicator.dbx.reverseFill = v or nil
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
	}
end

-- Grid2Options:MakeIndicatorBarMiscOptions()
function Grid2Options:MakeIndicatorMultiBarMiscOptions(indicator, options)
	options.barOpacity = {
		type = "range",
		order = 43,
		name = L["Opacity"],
		desc = L["Set the opacity."],
		min = 0,
		max = 1,
		step = 0.01,
		bigStep = 0.05,
		get = function () return indicator.dbx.opacity or 1	end,
		set = function (_, v)
			indicator.dbx.opacity = v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
	}
	options.inverColor= {
		type = "toggle",
		name = L["Invert Bar Color"],
		desc = L["Swap foreground/background colors on bars."],
		order = 49,
		tristate = false,
		get = function () return indicator.dbx.invertColor	end,
		set = function (_, v)
			indicator.dbx.invertColor = v or nil
			self:RefreshIndicator(indicator.sideKick, "Update")
		end,
	}
end

-- Grid2Options:MakeIndicatorMultiBarTextures()
do
	local function GetBarValue(indicator, index, key)
		local bar = indicator.dbx["bar"..index]
		if bar then return bar[key] end
	end
	local function SetBarValue(indicator, index, key, value)
		local bar = indicator.dbx["bar"..index]
		if value then
			if not bar then
				bar = {}
				indicator.dbx["bar"..index] = bar
			end
			bar[key] = value
		else
			bar[key] = nil
			if not next(bar) then
				indicator.dbx["bar"..index] = nil
			end
		end	
	end
	local function RegisterIndicatorStatus(indicator, status, index)
		if status then
			Grid2:DbSetMap(indicator.name, status.name, index)
			indicator:RegisterStatus(status, index)
		end	
	end
	local function UnregisterIndicatorStatus(indicator, status)
		if status then
			Grid2:DbSetMap(indicator.name, status.name, nil)
			indicator:UnregisterStatus(status)
		end	
	end
	local function SetIndicatorStatusPriority(indicator, status, priority)
		Grid2:DbSetMap( indicator.name, status.name, priority)
		indicator:SetStatusPriority(status, priority)
	end	
	local function UnregisterAllStatuses(indicator)
		local statuses = indicator.statuses
		while #statuses>0 do
			UnregisterIndicatorStatus(indicator,statuses[#statuses])
		end
	end
	local function SetIndicatorStatus(info, statusKey)
		local indicator = info.arg.indicator
		local index     = info.arg.index
		local newStatus = Grid2:GetStatusByName(statusKey)
		local oldStatus = indicator.statuses[index]
		local oldIndex  = indicator.priorities[newStatus]
		if oldStatus and oldIndex then
			SetIndicatorStatusPriority(indicator, oldStatus, oldIndex)
			SetIndicatorStatusPriority(indicator, newStatus, index)
		else
			UnregisterIndicatorStatus(indicator, oldStatus)
			RegisterIndicatorStatus(indicator, newStatus , index)
		end
		Grid2Options:RefreshIndicator(indicator, "Layout", "Update")
	end
	local function GetAvailableStatusValues(info)
		local indicator = info.arg.indicator
		local index     = info.arg.index
		local list      = {}
		for statusKey, status in Grid2:IterateStatuses() do
			if Grid2Options:IsCompatiblePair(indicator, status) and status.name~="test" and 
			  ( (not indicator.priorities[status]) or indicator.statuses[index] ) then
				list[statusKey] = Grid2Options.LocalizeStatus(status)
			end
		end
		return list
	end
	function Grid2Options:MakeIndicatorMultiBarTexturesOptions(indicator, options)
		options.barSep = { type = "header", order = 50,  name = L["Main Bar"] }
		options.barMainStatus = {
			type = "select",
			order = 50.5,
			name = L["Status"],
			desc = function()
				local status = indicator.statuses[1] 
				return status and self.LocalizeStatus(status)
			end,
			get = function () 
				local status = indicator.statuses[1] 
				return status and status.name or nil
			end,
			set = SetIndicatorStatus,
			values = GetAvailableStatusValues,
			arg = { indicator = indicator, index = 1}
		}
		options.barMainTexture = {
			type = "select", dialogControl = "LSM30_Statusbar",
			order = 51,
			width = "half",
			name = L["Texture"],
			desc = L["Select bar texture."],
			get = function (info) return indicator.dbx.texture or "Gradient" end,
			set = function (info, v)
				indicator.dbx.texture = v or nil
				self:RefreshIndicator(indicator, "Layout")
			end,
			values = AceGUIWidgetLSMlists.statusbar,
			hidden = function() return indicator.dbx.reverseMainBar end
		}
		options.barMainTextureColor = {
			type = "color",
			order = 52,
			width = "half",
			name = L["Color"],
			desc = L["Bar Color"],
			hasAlpha = true,
			get = function() 
				local c = indicator.dbx.textureColor
				if c then
					return c.r, c.g, c.b, c.a
				else
					return 0,0,0,1
				end	
			end,
			set = function(info,r,g,b,a) 
				local c = indicator.dbx.textureColor
				if not c then c = {}; indicator.dbx.textureColor = c end
				c.r, c.g, c.b, c.a = r, g, b, a
				self:RefreshIndicator(indicator, "Layout")
			end,		
			hasAlpha = true,
			hidden = function() return (indicator.dbx.textureColor == nil) or indicator.dbx.reverseMainBar end
		}
		options.barMainReverse = {
			type = "toggle",
			name = L["Reverse"],
			desc = L["Fill bar in reverse"],
			width = "half",
			order = 53,
			tristate = false,
			get = function () return indicator.dbx.reverseMainBar end,
			set = function (_, v) 
				indicator.dbx.reverseMainBar = v or nil
				self:RefreshIndicator(indicator, "Layout", "Update" )
			end,
			hidden = function() return indicator.dbx.textureColor == nil end,
		}		
		options.barStatusesColorize = {
			type = "toggle",
			name = L["Status Color"],
			desc = L["Specify a list of statuses to Colorize the bar"],
			width = "normal",
			order = 54,
			tristate = false,
			get = function () return indicator.dbx.textureColor == nil  end,
			set = function (_, v)
				if v then
					indicator.dbx.textureColor = nil
					indicator.dbx.reverseMainBar = nil
				else
					UnregisterAllStatuses(indicator.sideKick)
					indicator.dbx.textureColor = { r=0,g=0,b=0,a=1 }
				end
				self:RefreshIndicator(indicator, "Layout", "Update" )
				self:MakeIndicatorOptions(indicator)
			end,
			hidden = function() return indicator.dbx.reverseMainBar end
		}
		for i=1,(indicator.dbx.barCount or 0) do
			options["barSep"..i] = { type = "header", order = 50+i*5,  name = L["Extra Bar"] .. " "..i }
			options["Status"..i] = {
				type = "select",
				order = 50+i*5+0.5,
				name = L["Status"],
				desc = function()
					local status = indicator.statuses[i+1] 
					return status and self.LocalizeStatus(status)
				end,
				get = function () 
					local status = indicator.statuses[i+1] 
					return status and status.name or nil
				end,
				set = SetIndicatorStatus,
				values = GetAvailableStatusValues,
				disabled = function() return not indicator.statuses[i] end,
				arg = { indicator = indicator, index = i+1},				
			}
			options["barTexture"..i] = {
				type = "select", dialogControl = "LSM30_Statusbar",
				order = 50+i*5+1,
				width = "half",
				name = L["Texture"],
				desc = L["Select bar texture."],
				get = function (info) return GetBarValue(indicator, i, "texture") or indicator.dbx.texture or "Gradient" end,
				set = function (info, v)
					SetBarValue(indicator, i, "texture", v~=indicator.dbx.texture and v or nil)
					self:RefreshIndicator(indicator, "Layout")
				end,
				values = AceGUIWidgetLSMlists.statusbar,
			}
			options["barTextureColor"..i] = {
				type = "color",
				order = 50+i*5+2,
				name = L["Color"],
				desc = L["Select bar color"],
				width = "half",
				get = function()
					local c = GetBarValue(indicator, i, "color")
					if c then return c.r, c.g, c.b, c.a end
				end,
				set = function( info, r,g,b,a )
					local c = GetBarValue(indicator, i, "color")
					if c then
						c.r, c.g, c.b, c.a = r, g, b, a	
					else	
						SetBarValue(indicator, i, "color", {r=r, g=g, b=b, a=a} )
					end
					self:RefreshIndicator(indicator, "Layout")
				 end, 
				hasAlpha = true,
			}			
			options["barReverseFill"..i] = {
				type = "toggle",
				name = L["Reverse"],
				desc = L["Fill bar in reverse"],
				width = "half",
				order = 50+i*5+3,
				tristate = false,
				get = function () return GetBarValue(indicator, i, "reverse") end,
				set = function (_, v)
					SetBarValue(indicator,i,"reverse", v)
					self:RefreshIndicator(indicator, "Layout", "Update")
				end,
			}
			options["barOverlapMode"..i] = {
				type = "toggle",
				name = L["Overlap"],
				desc = L["Allow overlapping of non reverse bars"],
				order = 50+i*5+4,
				tristate = false,
				get = function () return not GetBarValue(indicator, i, "noOverlap") end,
				set = function (_, v)
					SetBarValue(indicator,i,"noOverlap", (not v) or nil )
					self:RefreshIndicator(indicator, "Layout", "Update")
				end,
				hidden = function() return GetBarValue(indicator,i, "reverse") end
			}
		end	
		
		if indicator.dbx.backColor then
			options.barSepBack = { type = "header", order = 100,  name = L["Background"] }
			options.backTexture = {
				type = "select", dialogControl = "LSM30_Statusbar",
				order = 101,
				width = "half",
				name = L["Texture"],
				desc = L["Adjust the background texture."],
				get = function (info) return indicator.dbx.backTexture or indicator.dbx.texture or "Gradient" end,
				set = function (info, v)
					indicator.dbx.backTexture = v
					self:RefreshIndicator(indicator, "Layout")
				end,
				values = AceGUIWidgetLSMlists.statusbar,
				hidden = function() return not indicator.dbx.backColor end
			}
			options.backColor = {
				type = "color",
				order = 102,
				width = "half",
				name = L["Color"],
				desc = L["Background Color"],
				hasAlpha = true,
				get = function() 
					local c = indicator.dbx.backColor
					if c then
						return c.r, c.g, c.b, c.a
					else
						return 0,0,0,1
					end	
				end,
				set = function(info,r,g,b,a) 
					local c = indicator.dbx.backColor
					if not c then c = {}; indicator.dbx.backColor = c end
					c.r, c.g, c.b, c.a = r, g, b, a
					self:RefreshIndicator(indicator, "Layout", "Update")
				end,
				hidden = function() return not indicator.dbx.backColor end
			}
			options.backMainAnchor= {
				type = "toggle",
				name = L["Anchor to MainBar"],
				desc = L["Anchor the background bar to the Main Bar instead of the last bar."],
				width = "double",
				order = 103,
				tristate = false,
				get = function () return indicator.dbx.backMainAnchor end,
				set = function (_, v)
					indicator.dbx.backMainAnchor = v or nil
					self:RefreshIndicator(indicator, "Layout")
				end,
			}
		end	
		
		options.changeBarSep = { type = "header", order = 150, name = "" }
		options.addBar = {
			type = "execute",
			order = 151,
			name = L["Add"],
			width = "half",
			desc = L["Add a new bar"],
			func = function(info)
				indicator.dbx.barCount = (indicator.dbx.barCount or 0) + 1 
				self:RefreshIndicator(indicator, "Layout")
				self:MakeIndicatorOptions(indicator)
			end,
			disabled = function() return (indicator.dbx.barCount or 0)>=5 end
		}		
		options.delBar = {
			type = "execute",
			order = 152,
			name = L["Delete"],
			width = "half",
			desc = L["Delete last bar"],
			func = function(info)
				local index = indicator.dbx.barCount or 0
				UnregisterIndicatorStatus(indicator, indicator.statuses[index+1])
				if index>0 then
					indicator.dbx["bar"..index] = nil
					indicator.dbx.barCount = index>1 and index - 1 or nil
				end	
				self:RefreshIndicator(indicator, "Layout")
				self:MakeIndicatorOptions(indicator)
			end,
			disabled = function() return (not indicator.dbx.barCount) and indicator.statuses[1]==nil end
		}
		options.enableBack = {
			type = "toggle",
			name = L["Enable Background"],
			desc = L["Enable Background"],
			order = 153,
			get = function () return indicator.dbx.backColor~=nil end,
			set = function (_, v)
				if v then
					indicator.dbx.backColor = { r=0,g=0,b=0,a=1 }
				else
					indicator.dbx.backColor = nil
				end
				self:RefreshIndicator(indicator, "Layout")
				self:MakeIndicatorOptions(indicator)
			end,
		}		
	end
	
end
