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
			MakeLayoutOptions( "arena"      , "Arena" )
			MakeLayoutOptions( "raid"       , "Raid"  )
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
			name = L["Advanced"],
			args = MakeLayoutsOptions(true),		
		},
		editor = {
			type = "group",
			order= 202,
			name = L["Layout editor"],
			args = Grid2Options.MakeLayoutsEditorOptions and Grid2Options:MakeLayoutsEditorOptions() or {},
		},
	},	
})

--}}
