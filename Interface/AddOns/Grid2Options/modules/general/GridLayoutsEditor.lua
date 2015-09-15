--[[ 
	Layouts Editor
	General > Layouts Tab > Advanced Tab
--]]	

local L  = Grid2Options.L
local LG = Grid2Options.LG

local Grid2Layout = Grid2:GetModule("Grid2Layout")

local DEFAULT_GROUP_ORDER = "WARRIOR,DEATHKNIGHT,ROGUE,MONK,PALADIN,DRUID,SHAMAN,PRIEST,MAGE,WARLOCK,HUNTER"
local DEFAULT_PET_ORDER = "HUNTER,WARLOCK,DEATHKNIGHT,PRIEST,MAGE,DRUID,SHAMAN,WARRIOR,ROGUE,PALADIN"

local TYPE_VALUES = {	
	party = L["party"], raid = L["raid"], partypet = L["partypet"], raidpet  = L["raidpet"], 
}
local COLUMN_VALUES = { 
	["1"]="1", ["2"]="2", ["3"]="3", ["4"]="4", ["5"]="5", ["6"]="6", ["7"]="7", ["8"]="8" 
}
local UPC_VALUES = { 
	["all"]= L["all"], ["01"]="01", ["02"]="02", ["03"]="03", ["04"]="04", ["05"]="05", 
	["10"]="10", ["15"]="15", ["20"]="20", ["25"]="25",   
}
local GROUP_VALUES = {
	["1"] = "1",
	["2"] = "2",
	["3"] = "3",
	["4"] = "4",
	["5"] = "5",
	["6"] = "6",
	["7"] = "7",
	["8"] = "8",
	["all"] = L["all"],
}
local GROUPBY_VALUES ={
	["CLASS"] = L["Class"],
	["GROUP"] = L["Group"],
	["ASSIGNEDROLE"]  = L["Role"],
	["NONE"]  = L["None"],
}
local SORTBY_VALUES= {
	["NAME"]  = L["Name"],
	["INDEX"] = L["Index"],
}					

-- local SORTDIR_VALUES= {
	-- ["ASC"]  = "Asc",
	-- ["DESC"] = "Desc",
-- }					

local ACTION1_VALUES= { 
	add = string.format("|T%s:0|t%s", READY_CHECK_READY_TEXTURE, L["Insert"]),
	copy= string.format("|T%s:0|t%s", READY_CHECK_READY_TEXTURE, L["Copy"] ),
	del = string.format("|T%s:0|t%s", READY_CHECK_NOT_READY_TEXTURE, L["Delete"]),
}
local ACTION2_VALUES= { 
	add = string.format("|T%s:0|t%s", READY_CHECK_READY_TEXTURE, L["Insert"]),
	copy= string.format("|T%s:0|t%s", READY_CHECK_READY_TEXTURE, L["Copy"]),
}

local options
local layoutName
local LoadLayout

local function GetAvailableLayouts(info)
	local result  = {}
	local layouts = Grid2Layout.layoutSettings
	local custom  = Grid2Layout.db.global.customLayouts or {}
	for name in pairs(layouts) do
		result[ name ] = custom[name] and LG[name].." *"  or LG[name]
	end
	return result
end

local function GetCustomLayout(name)
	if name then
		local layouts= Grid2Layout.db.global.customLayouts
		return layouts and layouts[name]
	end	
end

local function GetHeaderOption(layout, header, option, default)
	return header[option] or (layout.defaults and layout.defaults[option]) or default
end

local function CreateNewGroupHeader(copyFrom)
	if copyFrom then
		local header= {}
		for k,v in pairs(copyFrom) do
			header[k] = v
		end
		return header
	else
		return { type="raid", sortMethod="INDEX", unitsPerColumn = 5, maxColumns = 1 }
	end	
end 

local function LoadLayoutHeader( layoutName, layout, index, header )
	local order    = index*20
	local args     = options.groups.args
	local disabled = not GetCustomLayout(layoutName)
	
	args["header"..index] = {
		type = "header",
		order = order,
		name = string.format( "%s %d", L["Header"], index ),
	}	
	args["type"..index] ={
		type   = 'select',
		order  = order + 5,
		width = "half",
		name   = L["Type"],
		desc   = L["Type of units to display"],
		get    = function()  return header.type or "raid" end,
		set    = function(_,v)	header.type = v end,
		values = TYPE_VALUES,
		disabled = disabled,
	}
	args["columns"..index] =  {
		type   = 'select',
		order  = order + 6,
		width = "half",
		name   = L["Columns"],
		desc   = L["Maximum number of columns to display"],
		get    = function()  return tostring(GetHeaderOption(layout,header, "maxColumns", 1)) end,
		set    = function(_,v)	header.maxColumns = tonumber(v) end,
		values = COLUMN_VALUES,
		disabled = disabled,
	}
	args["upc"..index] =  {
		type   = 'select',
		order  = order + 7,
		width = "half",
		name   = L["Units/Column"],
		desc   = L["Maximum number of units per column to display"],
		get    = function()  
			local v= tostring( GetHeaderOption(layout,header,"unitsPerColumn","all") )
			return strlen(v)>1 and v or "0"..v
		end,
		set    = function(_,v)	header.unitsPerColumn= tonumber(v) end,
		values = UPC_VALUES,
		disabled = disabled,
	}
	args["group1"..index] =  {
		type   = 'select',
		order  = order + 8,
		width = "half",
		name   = L["First group"],
		desc   = L["First group to display"],
		get    = function() return header.groupFilter and strsub( header.groupFilter, 1,1) or "all" end,
		set    = function(_,v)	
					v = tonumber(v)
					if v then
						local w= tonumber(header.groupFilter and strsub( header.groupFilter, -1)) or v
						local t= {}
						for i=v,math.max(v,w) do t[#t+1] = tostring(i) end
						header.groupFilter= table.concat(t,",")
					else
						header.groupFilter = nil
					end
		
		end,
		values = GROUP_VALUES,
		disabled = disabled,
	}
	args["group2"..index] =  {
		type   = 'select',
		order  = order + 9,
		width = "half",
		name   = L["Last Group"],
		desc   = L["Last group to display"],
		get    = function() return header.groupFilter and strsub( header.groupFilter, -1) or "all" end,
		set    = function(_,v)	
					v = tonumber(v)
					if v then
						local w= tonumber(header.groupFilter and strsub( header.groupFilter, 1,1) ) or v
						local t= {}
						for i=w,math.max(v,w) do t[#t+1] = tostring(i) end
						header.groupFilter= table.concat(t,",")
					else
						header.groupFilter = nil
					end
		end,
		values = GROUP_VALUES,
		disabled = disabled,
	}
	args["groupby"..index] =  {
		type   = 'select',
		order  = order + 10,
		width  = "half",
		name   = L["Group by"],
		desc   = L["Group by"],
		get    = function() return GetHeaderOption(layout,header,"groupBy","NONE") end,
		set    = function(_,v)	
					if v=="CLASS" then
						header.groupBy = v
						header.groupingOrder = (header.type=="raid" or header.type=="party") and DEFAULT_GROUP_ORDER or DEFAULT_PET_ORDER
					elseif v=="GROUP" then
						header.groupBy = v
						header.groupingOrder = header.groupFilter or "1,2,3,4,5,6,7,8"
					elseif v=="ASSIGNEDROLE" then
						header.groupBy = "ASSIGNEDROLE"
						header.groupingOrder = "TANK,HEALER,DAMAGER,NONE"
					else
						header.groupingOrder, header.groupBy, v = nil, nil, nil
					end
		end,
		values = GROUPBY_VALUES,
		disabled = disabled,
	}
	args["sortby"..index] =  {
		type   = 'select',
		order  = order + 10,
		width  = "half",
		name   = L["Sort by"],
		desc   = L["Sort by"],
		get    = function() return GetHeaderOption(layout, header, "sortMethod", "INDEX") end,
		set    = function(_,v) 	header.sortMethod = v end,
		values = SORTBY_VALUES,
		disabled = disabled,
	}
	-- args["sortdir"..index] =  {
		-- type   = 'select',
		-- order  = order + 11,
		-- width  = "half",
		-- name   = L["Sort Dir"],
		-- desc   = L["Sort Direction"],
		-- get    = function() return header.sortDir or "ASC" end,
		-- set    = function(_,v) header.sortDir = v end,
		-- values = SORTDIR_VALUES,
	-- }
	if not disabled then
		args["action"..index] =  {
			type   = 'select',
			order  = order + 12,
			width  = "half",
			name   = string.format( "|cFF00ff00%s|r", L["Action"] ),
			get    = function() end,
			set    = function(_,v) 	
				if v=="del" then
					if #layout>1 then
						table.remove( layout, index )
						LoadLayout( layoutName )
					end
				else
					table.insert( layout, index+1, CreateNewGroupHeader(v=="copy" and layout[index]) )
					LoadLayout( layoutName )
				end			
			end,
			values = #layout>1 and ACTION1_VALUES or ACTION2_VALUES,
		}
	end	
end

local function LoadLayoutGeneralOptions(name)
	local args = options.groups.args
	local layout = Grid2Layout.layoutSettings[name]
	local isCustom = GetCustomLayout(name)
	args.separator1 = {
		type = "header",
		order = 1,
		name = L["General"],
	}
	args.scale = {
		type = "range",
		name = L["Scale"],
		desc = L["Adjust Grid scale."],
		order = 2.2,
		softMin = 0.5,
		softMax = 2.0,
		step = 0.05,
		isPercent = true,
		get = function ()
				  return Grid2Layout.db.profile.layoutScales[name] or 1
			  end,
		set = function (_, v)
				Grid2Layout.db.profile.layoutScales[name]= (v~=1) and v or nil
			    Grid2Layout:Scale()
			  end,
	}
	args.frameWidth = {
		type = "range",
		name = L["Frame Width"],
		desc = L["Select zero to use default Frame Width"],
		order = 2,
		softMin = 0,
		softMax = 100,
		step = 1,
		get = function ()
				  return Grid2Frame.db.profile.frameWidths[name] or 0
			  end,
		set = function (_, v)
				Grid2Frame.db.profile.frameWidths[name]= (v~=0) and v or nil
				if name==Grid2Layout.layoutName then 
					Grid2Layout:UpdateDisplay()
				end
			  end,
	}
	args.frameHeight = {
		type = "range",
		name = L["Frame Height"],
		desc = L["Select zero to use default Frame Height"],
		order = 2.1,
		softMin = 0,
		softMax = 100,
		step = 1,
		get = function ()
				  return Grid2Frame.db.profile.frameHeights[name] or 0
			  end,
		set = function (_, v)
				Grid2Frame.db.profile.frameHeights[name]= (v~=0) and v or nil
				if name==Grid2Layout.layoutName then 
					Grid2Layout:UpdateDisplay()
				end
			  end,
	}
	if isCustom then
		args.vehicle = {
			type = "toggle",
			name = L["Toggle for vehicle"],
			desc = L["When the player is in a vehicle replace the player frame with the vehicle frame."],
			order = 3,
			get = function() return layout.defaults.toggleForVehicle end,
			set = function() layout.defaults.toggleForVehicle= not layout.defaults.toggleForVehicle end,
		}
		-- Upgrade old format custom layouts
		if not layout.meta["raid"] then
			layout.meta["raid"] = true
		end
	end	
end

LoadLayout = function(name)
	wipe(options.groups.args)
	local layout = name and Grid2Layout.layoutSettings[name]
	if layout then
		LoadLayoutGeneralOptions(name)
		for i, h in ipairs(layout) do
			LoadLayoutHeader( name, layout, i, h)
		end
		return name
	end	
end

local function CreateLayout(name)
	if Grid2Layout.layoutSettings[name] then return end
	local layouts = Grid2Layout.db.global.customLayouts
	if not layouts then 
		layouts= {}
		Grid2Layout.db.global.customLayouts= layouts
	end
	layouts[name]= {
		meta     = { raid = true, party = true, arena = true, solo = true },
		defaults = { toggleForVehicle = true, showPlayer = true, showParty = true, showRaid = true, showSolo = true },
		[1]      = CreateNewGroupHeader(),
	}
	Grid2Layout:AddLayout(name, layouts[name])
	options.selectLayout.values = GetAvailableLayouts()
	return LoadLayout(name)
end

function Grid2Options:RefreshCustomLayoutsOptions()
	layoutName = nil
	options.selectLayout.values = GetAvailableLayouts()
	LoadLayout(nil)
end

function Grid2Options:MakeLayoutsEditorOptions()
	layoutName = nil
	options= {
		selectLayout = {
			type = 'select',
			order = 1,
			name = L["Select Layout"],
			desc = L["Select Layout"],
			values = GetAvailableLayouts,
			get = function() return layoutName end,
			set = function(_,v)	layoutName= LoadLayout(v) end,
		},
		newLayout = {
			type = "input",
			order = 2,
			name = L["New Layout Name"],
			desc = L["New Layout Name"],
			get = function()  end,
			set = function(_,v)	
				layoutName= CreateLayout(v) 
			end,
		},
		delete = {
			type = "execute",
			width = "half",
			order = 3,
			name = L["Delete"],
			desc = L["Delete selected layout"],
			func = function (info)
				Grid2Layout.db.global.customLayouts[layoutName] = nil
				Grid2Layout.layoutSettings[layoutName] = nil
				LoadLayout(nil)
				options.selectLayout.values = GetAvailableLayouts()
			end,
			hidden= function() return not GetCustomLayout(layoutName) end,
			confirm = function() return L["Are you sure?"] end,
		},
		refresh = {
			type = "execute",
			width = "half",
			order = 4,
			name = L["Refresh"],
			desc = L["Refresh the Layout"],
			func = function (info)
				if Grid2Layout.layoutName==layoutName then
					Grid2Layout:LoadLayout(layoutName)
				end	
			end,
			hidden= function() 
				return Grid2Layout.layoutName~=layoutName or InCombatLockdown()  
			end,
		},
		groups = {
			type   = "group", 
			inline = true, 
			name   = "",
			order  = 5,
			args = {}
		},
	}
	return options
end
