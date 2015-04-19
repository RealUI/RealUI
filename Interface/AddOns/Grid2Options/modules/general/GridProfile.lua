--[[
	General -> Profiles Tab -> General & Advanced Tabs
--]]

local L = Grid2Options.L

local profileOptions = LibStub('AceDBOptions-3.0'):GetOptionsTable(Grid2.db, true)
local name = profileOptions.name
profileOptions.name = L["General"]
local LibDualSpec = LibStub('LibDualSpec-1.0')
if LibDualSpec then
	LibDualSpec:EnhanceOptions(profileOptions, Grid2.db)
else
	print("ERROR NOT DUALSPEC LIBRARY")
end

Grid2Options:AddGeneralOptions("Profiles", nil, {
	type = "group",
	childGroups = "tab",
	order = 100,
	name = name,
	desc = L["Options for %s."]:format(name),
	args = {
		general  = profileOptions or {},
		advanced = Grid2Options.AdvancedProfileOptions or {},
	},	
} )
