-- Library of common/shared methods

local L = Grid2Options.L

-- Default values for new or morphed indicators
Grid2Options.indicatorDefaultValues = {
	icon   = { size = 16, fontSize = 8 },
	square = { size = 5 },
	text   = { duration = true, stack= false, textlength = 12, fontSize = 8, font = "Friz Quadrata TT" },
}

-- Grid2Options:MakeIndicatorDeleteOptions()
do
	local function DeleteIndicator(info)
		local indicator = info.arg
		Grid2Options.LI[indicator.name] = nil		
		Grid2Frame:WithAllFrames(indicator, "Disable")
		Grid2:DbSetIndicator(indicator.name,nil)
		if indicator.dbx.sideKick then
			Grid2:DbSetIndicator(indicator.dbx.sideKick.name, nil)
		end
		Grid2:UnregisterIndicator(indicator) 
		Grid2Frame:UpdateIndicators()
		Grid2Options:DeleteIndicatorOptions(indicator)
	end
	local function Disabled(info)
		local indicator = info.arg
		return #indicator.statuses>0 or (indicator.sideKick and #indicator.sideKick.statuses>0) or indicator.barParent or indicator.barChild
	end	
	function Grid2Options:MakeIndicatorDeleteOptions(indicator, options)
		self:MakeHeaderOptions( options, "Delete" )
		options.delete = {
			type  = "execute",
			order = 255,
			width  = "half",
			name  = L["Delete"],
			desc  = L["Delete this element"],
			func  = DeleteIndicator,
			arg   = indicator,
			disabled = Disabled,
		}
		options.renameIndicator = {
			type = "input",
			order = 350,
			width = "normal",
			name = L["Rename indicator"],
			desc = L["Type new name for the indicator"],
			usage = L["<CharacterOnlyString>"],
			get = function() return end,
			set = function(_,v)	
				if strlen(v)>3 then
					self.LI[indicator.name] = v
					Grid2Options:MakeIndicatorOptions(indicator)
				end
			end,
		}
	end
end

-- Grid2Options:MakeIndicatorSizeOptions()
function Grid2Options:MakeIndicatorSizeOptions(indicator, options, optionParams)
	options.size = {
		type = "range",
		order = 10,
		name = L["Size"],
		desc = L["Adjust the size of the indicator."],
		min = 5,
		max = 50,
		step = 1,
		get = function ()
			return indicator.dbx.size
		end,
		set = function (_, v)
			indicator.dbx.size = v
			self:RefreshIndicator(indicator, "Layout")
		end,
	}
end

-- Grid2Options:MakeIndicatorBorderSizeOptions()
function Grid2Options:MakeIndicatorBorderSizeOptions(indicator, options, optionParams)
	options.borderSize = {
		type = "range",
		order = 20,
		name = L["Border Size"],
		desc = L["Adjust the border size of the indicator."],
		min = 0,
		max = 20,
		step = 1,
		get = function () return indicator.dbx.borderSize or 0 end,
		set = function (_, v)
			if v == 0 then v = nil end
			indicator.dbx.borderSize = v
			self:RefreshIndicator(indicator, "Layout", "Update")
		end,
	}
end

-- Grid2Options:MakeIndicatorTextureOptions()
function Grid2Options:MakeIndicatorTextureOptions(indicator, options, optionParams)
	options.texture = {
		type = "select", dialogControl = "LSM30_Statusbar",
		order = 11,
		name = L["Frame Texture"],
		desc = L["Adjust the texture of the indicator."],
		get = function (info) return indicator.dbx.texture or "Grid2 Flat" end,
		set = function (info, v)
			indicator.dbx.texture = v
			self:RefreshIndicator(indicator, "Layout")
		end,
		values = AceGUIWidgetLSMlists.statusbar,
	}
end

-- Grid2Options:MakeIndicatorBorderOptions()
function Grid2Options:MakeIndicatorBorderOptions(indicator, options, optionParams)
	optionParams = optionParams or {}
	optionParams.color1 = L["Border Color"]
	optionParams.colorDesc1 = L["Adjust border color and alpha."]
	self:MakeHeaderOptions( options, "Border" )
	self:MakeIndicatorColorOptions(indicator, options, optionParams)
	self:MakeIndicatorBorderSizeOptions(indicator, options, optionParams)
end

-- Grid2Options:MakeIndicatorColorOptions()
do
	local function GetIndicatorColor(info)
		local indicator = info.arg.indicator
		local colorKey  = "color" .. info.arg.colorIndex 
		local c = indicator.dbx[ colorKey ]
		if c then return c.r, c.g, c.b, c.a end
		return 0, 0, 0, 0
	end
	local function SetIndicatorColor(info, r, g, b, a)
		local colorKey   = "color" .. info.arg.colorIndex
		local indicator  = info.arg.indicator
		local dbx = indicator.dbx
		local c = dbx[colorKey]
		if not c then c = {}; dbx[colorKey] = c end
		c.r, c.g, c.b, c.a = r, g, b, a
		Grid2Options:RefreshIndicator(indicator, "Layout", "Update")
		-- if indicator.UpdateDB then indicator:UpdateDB() end
		-- Grid2Frame:UpdateIndicators()
	end
	function Grid2Options:MakeIndicatorColorOptions(indicator, options, optionParams)
		local colorCount = indicator.dbx.colorCount or 1
		local name = L["Color"]
		local desc = L["Color for %s."]:format(indicator.name)
		for i = 1, colorCount, 1 do
			local colorKey = "color" .. i
			if (optionParams and optionParams[colorKey]) then
				name = optionParams[colorKey]
			elseif (colorCount > 1) then
				name = L["Color %d"]:format(i)
			end
			local colorDescKey = "colorDesc" .. i
			if (optionParams and optionParams[colorDescKey]) then
				desc = optionParams[colorDescKey]
			elseif (colorCount > 1) then
				desc = name
			end
			options[colorKey] = {
				type = "color",
				order = (20 + i),
				name = name,
				desc = desc,
				get = GetIndicatorColor,
				set = SetIndicatorColor,
				hasAlpha = true,
				arg = {indicator = indicator, colorIndex = i},
			}
		end
	end
end
	
-- Grid2Options:MakeIndicatorLocationOptions()
do
	local levelValues = { 1,2,3,4,5,6,7,8,9 }
	function Grid2Options:MakeIndicatorLocationOptions(indicator, options)
		local location  = indicator.dbx.location
		self:MakeHeaderOptions( options, "Location" )
		options.relPoint = {
			type = 'select',
			order = 4,
			name = L["Location"],
			desc = L["Align my align point relative to"],
			values = self.pointValueList,
			get = function() return self.pointMap[location.relPoint] end,
			set = function(_, v)
				location.relPoint = self.pointMap[v]
				location.point = location.relPoint
				self:RefreshIndicator(indicator, "Layout", "Update" )
			end,
		}
		options.point = {
			type = 'select',
			order = 5,
			name = L["Align Point"],
			desc = L["Align this point on the indicator"],
			values = self.pointValueList,
			get = function() return self.pointMap[location.point] end,
			set = function(_, v)
				location.point = self.pointMap[v] 
				self:RefreshIndicator(indicator, "Layout", "Update" )
			end,
		}
		options.x = {
			type = "range",
			order = 7,
			name = L["X Offset"],
			desc = L["X - Horizontal Offset"],
			min = -50, max = 50, step = 1, bigStep = 1,
			get = function() return location.x end,
			set = function(_, v)
				location.x = v 
				self:RefreshIndicator(indicator, "Layout", "Update" )
			end,
		}
		options.y = {
			type = "range",
			order = 8,
			name = L["Y Offset"],
			desc = L["Y - Vertical Offset"],
			min = -50, max = 50, step = 1, bigStep = 1,
			get = function() return location.y end,
			set = function(_, v)
				location.y = v
				self:RefreshIndicator(indicator, "Layout", "Update" )
			end,
		}
		options.frameLevel = {
			type = "select",
			order = 6,
			name = L["Frame Level"],
			desc = L["Bars with higher numbers always show up on top of lower numbers."],
			get = function ()
				return indicator.dbx.level or 1
			end,
			set = function (_, v)
				indicator.dbx.level = v
				self:RefreshIndicator(indicator, "Layout", "Update" )
			end,
			values = levelValues,
		}
	end
end
