-- Mage

Raven.classConditions.MAGE = {
	["Brilliance Buff Missing"] = {	
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 1459 }, -- "Arcane Brilliance"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 1459, 61316 }, }, -- "Arcane Brilliance", "Dalaran Brilliance",
		},	
		associatedSpell = 1459, -- "Arcane Brilliance"
	},
	["Remove Curse"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 475 }, -- "Remove Curse"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Curse", },
		},	
		associatedSpell = 475, -- "Remove Curse"
	},
}
