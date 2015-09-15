--[[
	General > Layouts Tab > General & Advanced Tabs
--]]

local L = Grid2Options.L
local LG = Grid2Options.LG

-- MakeLayoutsOptions()
local MakeLayoutsOptions
do
	local function GetValues(info)
		local layouts = Grid2Options:GetLayouts(info.arg)
		if strfind(info.arg,"raid@") then
			local raid = Grid2Layout.db.profile.layouts["raid"] or "undefined"
			layouts["default"] = "*" .. L["Use Raid layout"] .. " ("..LG[raid]..")*"
		end
		return layouts
	end
	local function GetLayout(info)
		return Grid2Layout.db.profile.layouts[info.arg] or "default"
	end
	local function SetLayout(info,v)
		Grid2Layout.db.profile.layouts[info.arg] = (v~="default") and v or nil
		Grid2Layout:ReloadLayout()
	end
	local function TestMode(info)
		if Grid2Options.LayoutTestEnable then
			Grid2Options:LayoutTestEnable( Grid2Layout.db.profile.layouts[info.arg] or
										   Grid2Layout.db.profile.layouts["raid"] )
		end
	end
	function MakeLayoutsOptions(advanced)
		local options = {}
		local order = 10
		local function MakeSeparatorOption(description)
			options["sep"..order] = { type = "header",  name = L[description],  order = order }
			order = order + 100
		end
		local function MakeLayoutOptions(raidType, name)
			options[raidType]= {
				type   = "select",
				name   = L[name],
				desc   = L["Select which layout to use for: "] .. L[name],
				order  = order + 5,
				width  = "double",
				get    = GetLayout,
				set    = SetLayout,
				values = GetValues,
				arg    = raidType,
			}
			options[raidType.."Test"] = {
				type     = "execute",
				name     = L["Test"],
				width    = "half",
				desc     = L["Test the layout."],
				order    = order + 10,
				func     = TestMode,
				disabled = InCombatLockdown,
				arg      = raidType,
			}
			options[raidType.."sep"] = { type = "description",  name = "",  order = order + 99 }
			order = order + 100
		end
		-- partyTypes = solo party arena raid
		-- instTypes  = none pvp lfr flex mythic other
		if advanced then
			MakeLayoutOptions( "raid@pvp"   , "PvP Instances (BGs)" )
			MakeLayoutOptions( "raid@lfr"   , "LFR Instances" )
			MakeLayoutOptions( "raid@flex"  , "Flexible raid Instances (normal/heroic)" )
			MakeLayoutOptions( "raid@mythic", "Mythic raids Instances" )
			MakeLayoutOptions( "raid@other" , "Other raids Instances" )
			MakeLayoutOptions( "raid@none"  , "In World" )
		else
			MakeLayoutOptions( "solo"       , "Solo"  )
			MakeLayoutOptions( "party"      , "Party" )
			MakeLayoutOptions( "raid"       , "Raid"  )
			MakeLayoutOptions( "arena"      , "Arena" )
		end
		return options
	end
end

-- MakeFrameSizesOptions()
local MakeFrameSizesOptions
do
	local function GetRaidType(m)
		return (m==1 and "solo") or (m==5 and "party") or "raid"
	end
	local function GetValues(info)
		local layouts = Grid2Options:GetLayouts( GetRaidType(info.arg) )
		layouts["default"] = "*" .. L["Default"] .. "*"
		return layouts
	end
	local function GetLayout(info)
		return Grid2Layout.db.profile.layoutBySize[info.arg] or "default"
	end
	local function SetLayout(info,v)
		Grid2Layout.db.profile.layoutBySize[info.arg] = (v~="default") and v or nil
		Grid2Layout:ReloadLayout()
	end
	local function TestMode(info)
		if Grid2Options.LayoutTestEnable then
			Grid2Options:LayoutTestEnable(
				Grid2Layout.db.profile.layoutBySize[info.arg] or Grid2Layout.db.profile.layouts[ GetRaidType(info.arg) ],
				Grid2Frame.db.profile.frameWidths[info.arg],
				Grid2Frame.db.profile.frameHeights[info.arg],
				info.arg
			)
		end
	end
	function MakeFrameSizesOptions(exclude)
		local options = {}
		local sizevalues = {1,5,10,20,25,30,40}
		local function MakeOptions(m)
			options["instance"..m] = {
				type  = "group",
				inline = true,
				order = m,
				name  = m>1 and string.format(L["%d man instances"],m) or L["Solo"],
				args  = {
					layoutName = {
						type   = "select",
						name   = L["Layout"],
						desc   = L["Layout"],
						order  = 1,
						width  = "normal",
						get    = GetLayout,
						set    = SetLayout,
						values = GetValues,
						arg    = m,
					},
					frameWidth = {
						type = "range",
						name = L["Frame Width"],
						desc = L["Select zero to use default Frame Width"],
						order = 2,
						softMin = 0,
						softMax = 100,
						step = 1,
						get = function() return Grid2Frame.db.profile.frameWidths[m] or 0 end,
						set = function(_, v)
								Grid2Frame.db.profile.frameWidths[m] = (v~=0) and v or nil
								if m == Grid2Layout.instMaxPlayers then
									Grid2Layout:UpdateDisplay()
								end
							  end,
					},
					frameHeight = {
						type = "range",
						name = L["Frame Height"],
						desc = L["Select zero to use default Frame Height"],
						order = 3,
						softMin = 0,
						softMax = 100,
						step = 1,
						get = function () return Grid2Frame.db.profile.frameHeights[m] or 0 end,
						set = function (_, v)
								Grid2Frame.db.profile.frameHeights[m] = (v~=0) and v or nil
								if m == Grid2Layout.instMaxPlayers then
									Grid2Layout:UpdateDisplay()
								end
							  end,
					},
					test = {
						type = "execute",
						width = "half",
						order = 1.25,
						name = L["Test"],
						desc = L["Test"],
						disabled = InCombatLockdown,
						func = TestMode,
						arg = m,
					},
					delete = {
						type = "execute",
						width = "half",
						order = 1.5,
						name = L["Delete"],
						desc = L["Delete"],
						func = function (info)
							options["instance"..m] = nil
							Grid2Frame.db.profile.frameWidths[m] = nil
							Grid2Frame.db.profile.frameHeights[m] = nil
							Grid2Layout.db.profile.layoutBySize[m] = nil
							if m == Grid2Layout.instMaxPlayers then
								Grid2Layout:UpdateDisplay()
								Grid2Layout:ReloadLayout()
							end
						end,
						confirm = function() return L["Are you sure?"] end,
					},
				}
			}
		end
		options["add"] ={
			type   = 'select',
			order  = 500,
			width = "half",
			name   = L["Add"],
			desc   = L["Add instance size"],
			get    = function() end,
			set    = function(_,v) MakeOptions( sizevalues[v] ) end,
			values = sizevalues,
		}
		local p = Grid2Frame.db.profile
		local l = Grid2Layout.db.profile
		for _,value in pairs(sizevalues) do
			if l.layoutBySize[value] or p.frameWidths[value] or p.frameHeights[value] then
				MakeOptions(value)
			end
		end
		return options
	end
end

Grid2Options:AddGeneralOptions( "Layouts", nil, {
	type = "group",
	childGroups= "tab",
	name = L["Layouts"],
	args = {
		general = {
			type = "group",
			order= 200,
			name = L["General"],
			args = MakeLayoutsOptions(false),
		},
		advanced = {
			type = "group",
			order= 201,
			name = L["By Instance Type"],
			args = MakeLayoutsOptions(true),
		},
		frameSizes = {
			type = "group",
			order= 202,
			name = L["By Raid Size"],
			args = MakeFrameSizesOptions(),
		},
		editor = {
			type = "group",
			order= 203,
			name = L["Layout editor"],
			args = Grid2Options.MakeLayoutsEditorOptions and Grid2Options:MakeLayoutsEditorOptions() or {},
		},
	},
})

--}}
