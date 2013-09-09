
local L = Grid2Options.L

Grid2Options:AddGeneralOptions( "Misc", "Options management", {
	loadOnDemand = {
		type = "toggle",
		name = L["Load options on demand (requires UI reload)"],
		desc = L["OPTIONS_ONDEMAND_DESC"],
		width = "full",
		order = 150,
		get = function () return not Grid2.db.global.LoadOnDemandDisabled end,
		set = function (_, v)
			Grid2.db.global.LoadOnDemandDisabled = (not v) or nil
		end,
	},
})