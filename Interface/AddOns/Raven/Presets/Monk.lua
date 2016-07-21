-- Monk

Raven.classConditions.MONK = {
	["Detox (Poison)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 115450, }, -- "Detox"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Poison", },
		},	
		associatedSpell = 115450, -- "Detox"
	},
	["Detox (Disease)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 115450, }, -- "Detox"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Disease", },
		},	
		associatedSpell = 115450, -- "Detox"
	},
	["Detox (Magic)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 115450, }, -- "Detox"
			["All Cooldowns"] = { enable = true, spells = { 115451 }, notUsable = false,  timeLeft = 10, toggle = true }, -- "Internal Medicine"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Magic", },
		},	
		associatedSpell = 115450, -- "Detox"
	},
}
