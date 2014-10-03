-- Shaman

Raven.classConditions.SHAMAN = {
	["Shield Missing"] = {
		tests = {
			["Player Status"] = { enable = true, inCombat = true },
			["Spell Ready"] = { enable = true, spell = 324, }, -- "Lightning Shield"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 52127, 324, 974 }, }, -- "Water Shield", "Lightning Shield", "Earth Shield"
		},	
	},
}
