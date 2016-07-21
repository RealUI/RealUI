-- Druid

Raven.classConditions.DRUID = {
	["Remove Corruption (Poison)"] = {
		tests = {
			["Spell Ready"] = { enable = true, spell = 2782, }, -- "Remove Corruption"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Poison", },
		},	
		associatedSpell = 2782, -- "Remove Corruption"
	},
	["Remove Corruption (Curse)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 2782, }, -- "Remove Corruption"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Curse", },
		},	
		associatedSpell = 2782, -- "Remove Corruption"
	},
	["Nature's Cure (Poison)"] = {
		tests = {
			["Spell Ready"] = { enable = true, spell = 88423, }, -- "Nature's Cure"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Poison", },
		},	
		associatedSpell = 88423, -- "Nature's Cure"
	},
	["Nature's Cure (Curse)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 88423, }, -- "Nature's Cure"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Curse", },
		},	
		associatedSpell = 88423, -- "Nature's Cure"
	},
	["Nature's Cure (Magic)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 88423, }, -- "Nature's Cure"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Magic", },
		},	
		associatedSpell = 88423, -- "Nature's Cure"
	},
}
