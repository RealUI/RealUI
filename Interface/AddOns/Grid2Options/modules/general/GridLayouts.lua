--[[ 
	General > Layouts Tab > General & Advanced Tabs
--]]	

local L = Grid2Options.L

-- MakeLayoutsOptions()
local MakeLayoutsOptions
do
	local function GetValues(info) 
		return Grid2Options:GetLayouts(info.arg) 
	end
	local function GetLayout(info)
		return Grid2Layout.db.profile.layouts[info.arg]
	end
	local function SetLayout(info,v)
		Grid2Layout.db.profile.layouts[info.arg] = v
		if Grid2Layout.partyType == info.arg then
			Grid2Layout:LoadLayout(v)
		end
	end
	local function TestMode(info)
		if Grid2Options.LayoutTestEnable then
			Grid2Options:LayoutTestEnable( GetLayout(info), info.arg )
		end	
	end
	function MakeLayoutsOptions()
		local options = {}
		local order = 10
		local function MakeLayoutOptions(raidType, name, desc)
			options[raidType]= {
				type   = "select",
				name   = name and L[name] or L["Raid %s Layout"]:format( strsub(raidType,-2) ),
				desc   = desc and L[desc] or L["Select which layout to use for %s person raids."]:format( strsub(raidType,-2) ),
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
		MakeLayoutOptions( "solo"  , "Solo Layout" , "Select which layout to use for solo." )
		MakeLayoutOptions( "party" , "Party Layout", "Select which layout to use for party." )
		MakeLayoutOptions( "arena" , "Arena Layout", "Select which layout to use for arenas." )
		MakeLayoutOptions( "raid10" )
		MakeLayoutOptions( "raid15" )
		MakeLayoutOptions( "raid25" )
		MakeLayoutOptions( "raid40" )	
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
			args = MakeLayoutsOptions(),
		},
		advanced = {
			type = "group",
			order= 201,
			name = L["Advanced"],
			args = Grid2Options.MakeLayoutsEditorOptions and Grid2Options:MakeLayoutsEditorOptions() or {},
		},
	},	
})

--}}
