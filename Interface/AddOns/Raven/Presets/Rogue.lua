-- Rogue

Raven.classConditions.ROGUE = {
	["Lethal Poison Missing"] = {
		name = "Lethal Poison Missing", enabled = true, notify = true,
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 2823 }, -- "Deadly Poison"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player", auras = { 2823, 8679, 200802 }, }, -- "Deadly", "Wound", "Agonizing"
		},	
	},
	["Non-Lethal Poison Missing"] = {
		name = "Non-Lethal Poison Missing", enabled = true, notify = true,
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 3408 }, -- "Crippling Poison"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player", auras = { 3408, 108211 }, }, -- "Crippling", "Leeching"
		},	
	},
}
