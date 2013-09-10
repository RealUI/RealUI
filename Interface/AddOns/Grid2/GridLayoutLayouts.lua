--[[
Created by Grid2 original authors, modified by Michael
--]]

--{{{ Libraries

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local DEFAULT_GROUP_ORDER = "WARRIOR,DEATHKNIGHT,ROGUE,PALADIN,DRUID,SHAMAN,PRIEST,MAGE,WARLOCK,HUNTER"
local DEFAULT_PET_ORDER = "HUNTER,WARLOCK,DEATHKNIGHT,PRIEST,MAGE,DRUID,SHAMAN,WARRIOR,ROGUE,PALADIN"

local groupFilters =  { { groupFilter = "1" }, { groupFilter = "2" }, { groupFilter = "3" }, {	groupFilter = "4" }, {	groupFilter = "5" } }

Grid2Layout:AddLayout("None", {
	meta = {
		raid40 = true,
		raid25 = true,
		raid15 = true,
		raid10 = true,
		party = true,
		arena = true,
		solo = true,
	},
})

Grid2Layout:AddLayout("Solo", {
	meta = {
		solo = true,
		party = true,
		arena = true,
	},
	[1] = {
		type = "party",
		groupingOrder = DEFAULT_GROUP_ORDER,
		showPlayer = true,
		showSolo = true,
		allowVehicleTarget = true,
		toggleForVehicle = true,
	},
})

Grid2Layout:AddLayout("Solo w/Pet", {
	meta = {
		solo = true,
		party = true,
		arena = true,
	},
	[1] = {
		type = "party",
		groupingOrder = DEFAULT_GROUP_ORDER,
		showPlayer = true,
		showSolo = true,
		allowVehicleTarget = true,
	},
	[2] = {
		type = "partypet",
		groupingOrder = DEFAULT_PET_ORDER,
		showPlayer = true,
		showSolo = true,
		allowVehicleTarget = true,
	}
})

Grid2Layout:AddLayout("By Group 5", {
	meta = {
		solo = true,
		party = true,
		arena = true,
	},
	[1] = {
		showPlayer = true,
		showParty = true,
		showRaid = true,
		showSolo = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
		toggleForVehicle = true,
	},
})

Grid2Layout:AddLayout("By Group 5 w/Pets", {
	meta = {
		party = true,
		arena = true,
	},
	defaults = {
		showPlayer = true,
		showParty = true,
        allowVehicleTarget = true,
	},
	[1] = {
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		type = "partypet",
		groupingOrder = DEFAULT_PET_ORDER,
		unitsPerColumn = 5,
		maxColumns = 1,
	},
})

Grid2Layout:AddLayout("By Group 10", {
	meta = {
		raid10 = true,
		solo = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
		showPlayer = true,
		showParty = true,
		showRaid = true,
		showSolo = true,
	},
	[1] = groupFilters[1],
	[2] = groupFilters[2],
})

Grid2Layout:AddLayout("By Group 10 w/Pets", {
	meta = {
		raid10 = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		showPlayer = true,
		showParty = true,
		showRaid = true,
	},
	[1] = groupFilters[1],
	[2] = groupFilters[2],
	[3] = {
		type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
		unitsPerColumn = 5,
		maxColumns = 2,
	},
})

Grid2Layout:AddLayout("By Group 10 Tanks First", {
	meta = {
		raid10 = true,
		solo = true,
	},
	defaults = {
        allowVehicleTarget = true,
		toggleForVehicle = true,
		showPlayer = true,
		showParty = true,
		showRaid = true,
		showSolo = true,
		groupBy = "ROLE",
		groupingOrder = "MAINTANK,MAINASSIST", 

	},
	[1] = groupFilters[1],
	[2] = groupFilters[2],
})

Grid2Layout:AddLayout("By Group 15", {
	meta = {
		raid15 = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
	},
	[1] = groupFilters[1],
	[2] = groupFilters[2],
	[3] = groupFilters[3],
})

Grid2Layout:AddLayout("By Group 15 w/Pets", {
	meta = {
		raid15 = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
	},
	[1] = groupFilters[1],
	[2] = groupFilters[2],
	[3] = groupFilters[3],
	[4] = {
		type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
		showPlayer = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 5,
		maxColumns = 3,
	},
 })

Grid2Layout:AddLayout("By Group 25", {
	meta = {
		raid40 = true,
		raid25 = true,
		raid10 = true,
		solo = true,
	},
	defaults = {
		showPlayer = true,
		showParty = true,
		showRaid = true,
		showSolo = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
	},
	[1] = groupFilters[1],
	[2] = groupFilters[2],
	[3] = groupFilters[3],
	[4] = groupFilters[4],
	[5] = groupFilters[5],
})

Grid2Layout:AddLayout("By Group 25 w/Pets", {
	meta = {
		raid25 = true,
	},
	defaults = {
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
	},
	[1] = groupFilters[1],
	[2] = groupFilters[2],
	[3] = groupFilters[3],
	[4] = groupFilters[4],
	[5] = groupFilters[5],
	[6] = {
		type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
		showPlayer = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 5,
		maxColumns = 5,
	},
})

Grid2Layout:AddLayout("By Group 25 Tanks First", {
	meta = {
		raid25 = true,
		solo = true,
	},
	defaults = {
        allowVehicleTarget = true,
		toggleForVehicle = true,
		showPlayer = true,
		showParty = true,
		showRaid = true,
		showSolo = true,
		groupBy = "ROLE",
		groupingOrder = "MAINTANK,MAINASSIST", 
	},
	[1] = groupFilters[1],
	[2] = groupFilters[2],
	[3] = groupFilters[3],
	[4] = groupFilters[4],
	[5] = groupFilters[5],
})

Grid2Layout:AddLayout("By Class 25", {
	meta = {
		raid25 = true,
		raid15 = true,
		raid10 = true,
		party = true,
		arena = true,
		solo = true,
	},
	defaults= {
		showPlayer = true,
		showParty = true,
		showRaid = true,
		showSolo = true,
		unitsPerColumn = 5,
		maxColumns = 5,
		allowVehicleTarget = true,
	},
	[1] = {
		groupFilter = "1,2,3,4,5",
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
	},
})

Grid2Layout:AddLayout("By Role 25", {
	meta = {
		raid25 = true,
		raid15 = true,
		raid10 = true,
		party = true,
		solo = true,
	},
	defaults = {
		showSolo = true,
		showParty = true,
		showRaid = true,
		showPlayer = true,
        allowVehicleTarget = true,
		unitsPerColumn = 5,
	},
	[1] = {
		groupBy = "ROLE",
		groupFilter = "MAINTANK,MAINASSIST", 
		groupingOrder = "MAINTANK,MAINASSIST", 
		maxColumns = 1,
	},
	[2] = {
		groupFilter = "1,2,3,4,5",
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER, 
		maxColumns = 5,
	},
	[3] = {
		type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
		maxColumns = 5,
	},
})

Grid2Layout:AddLayout("By Class 1 x 25 Wide", {
	meta = {
		raid25 = true,
		raid15 = true,
		raid10 = true,
		arena = true,
		solo = true,
	},
	defaults = {
		showSolo = true,
		showParty = true,
		showRaid = true,
		showPlayer = true,
        allowVehicleTarget = true,
		unitsPerColumn = 25,
		maxColumns = 1,
	},
	[1] = {
		groupingOrder = DEFAULT_GROUP_ORDER,
		groupFilter = "1,2,3,4,5",
		groupBy = "CLASS",
	},
	[2] = {
		type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
	},
})

Grid2Layout:AddLayout("By Class 2 x 15 Wide", {
	meta = {
		raid25 = true,
		raid15 = true,
		raid10 = true,
		arena = true,
		solo = true,
	},
	defaults = {
		showSolo = true,
		showParty = true,
		showRaid = true,
		showPlayer = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		unitsPerColumn = 15,
		maxColumns = 2,
	},
	[1] = {
		groupFilter = "1,2,3,4,5,6",
		groupBy = "CLASS",
	},
	[2] = {
		type = "raidpet",
	},
})

Grid2Layout:AddLayout("By Group 4 x 10 Wide", {
    meta = {
		raid40 = true,
		raid25 = true,
		raid15 = true,
		raid10 = true,
		solo = true,
    },
 	defaults = {
		showSolo = true,
		showPlayer = true,
		showParty = true,
		showRaid = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
        groupBy = "GROUP",
        unitsPerColumn = 10,
        maxColumns = 1,
	},
    [1] = { groupFilter = "1,2" },
    [2] = { groupFilter = "3,4" },
    [3] = { groupFilter = "5,6" },
    [4] = { groupFilter = "7,8" },
    [5] = {
        type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
    },

})

Grid2Layout:AddLayout("By Class", {
	meta = {
		raid40 = true,
		raid25 = true,
		raid15 = true,
		raid10 = true,
		solo = true,
	},
	defaults = {
        allowVehicleTarget = true,
		toggleForVehicle = true,
		showParty = true,
		showRaid = true,
		showSolo = true,
		showPlayer= true,
	},
	[1]= {
		groupFilter = "1,2,3,4,5,6,7,8",
		groupBy = "CLASS",
		groupingOrder = DEFAULT_GROUP_ORDER,
		unitsPerColumn = 5,
		maxColumns = 5,	
	}
})

Grid2Layout:AddLayout("By Class w/Pets", {
	meta = {
		raid40 = true,
		raid25 = true,
		raid15 = true,
		raid10 = true,
	},
	defaults = {
        allowVehicleTarget = true,
		showParty = true,
		showRaid = true,
		unitsPerColumn = 5,
		maxColumns = 5,
		groupBy = "CLASS",
		groupFilter = "1,2,3,4,5,6,7,8",
	},
	[1]= {
		groupingOrder = DEFAULT_GROUP_ORDER,
	},
	[2] = {
		type = "raidpet",
		groupingOrder = DEFAULT_PET_ORDER,
		showPlayer = true,
	},
})

Grid2Layout:AddLayout("By Group 25 w/tanks", {
	meta = {
		raid25 = true,
		raid10 = true,
		solo = true,
	},
	defaults = {
		showSolo = true,
		showPlayer = true,	
		showParty = true,
		showRaid = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
	},
	[1] = {
		groupFilter = "MAINTANK,MAINASSIST",
		groupingOrder = "MAINTANK,MAINASSIST",
	},
	[2] = groupFilters[1],
	[3] = groupFilters[2],
	[4] = groupFilters[3],
	[5] = groupFilters[4],
	[6] = groupFilters[5],
})

Grid2Layout:AddLayout("By Group 40", {
	meta = {
		raid40 = true,
	},
	defaults = {
		showParty = true,
		showRaid = true,
		groupingOrder = DEFAULT_GROUP_ORDER,
        allowVehicleTarget = true,
		toggleForVehicle = true,
	},
	[1] = groupFilters[1],
	[2] = groupFilters[2],
	[3] = groupFilters[3],
	[4] = groupFilters[4],
	[5] = groupFilters[5],
	[6] = {	groupFilter = "6" },
	[7] = {	groupFilter = "7" },
	[8] = {	groupFilter = "8" },
})
