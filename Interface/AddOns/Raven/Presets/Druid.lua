-- Druid

Raven.classConditions.DRUID = {
	["Mark of the Wild Missing"] = { -- "Mark of the Wild", "Blessing of Kings", "Legacy of the Emperor", "Embrace of the Shale Spider"
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 1126 }, -- "Mark of the Wild"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 1126, 20217, 115921, 90363 }, },
		},
		associatedSpell = 1126, -- "Mark of the Wild"
	},
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
