-- Warlock

Raven.classConditions.WARLOCK = {
	["No Pet!"] = {
		tests = {
			["Player Status"] = { enable = true, inCombat = true, hasPet = false },
		},	
	},
}
