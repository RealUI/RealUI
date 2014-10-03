-- Rogue

Raven.classConditions.ROGUE = {
	["Lethal Poison Missing"] = {
		name = "Lethal Poison Missing", enabled = true, notify = true,
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 2823 }, -- "Deadly Poison"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player", auras = { 2823, 8679 }, }, -- "Deadly Poison", "Wound Poison"
		},	
	},
	["Non-Lethal Poison Missing"] = {
		name = "Non-Lethal Poison Missing", enabled = true, notify = true,
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 3408 }, -- "Crippling Poison"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 3408, 5761, 108215, 108211 }, }, -- "Crippling Poison", "Mind-numbing Poison", "Paralytic Poison", "Leeching Poison"
		},	
	},
}
