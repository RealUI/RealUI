-- Shaman

Raven.classConditions.SHAMAN = {
	["Lightning Shield Missing"] = { -- valid for Enhancement specialization only
		tests = {
			["Player Status"] = { enable = true, inCombat = true },
			["Spell Ready"] = { enable = true, spell = 192106, }, -- "Lightning Shield"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player", auras = { 192106 }, },
		},	
	},
}
