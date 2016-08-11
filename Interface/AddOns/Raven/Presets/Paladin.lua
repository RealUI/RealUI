-- Paladin

Raven.classConditions.PALADIN = {
	["Cleanse (Poison)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 4987, }, -- "Cleanse"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Poison", },
		},	
		associatedSpell = 4987, -- "Cleanse"
	},
	["Cleanse (Disease)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 4987, }, -- "Cleanse"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Disease", },
		},	
		associatedSpell = 4987, -- "Cleanse"
	},
	["Cleanse (Magic)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 4987, }, -- "Cleanse"
			["All Cooldowns"] = { enable = true, spells = { 53551 }, notUsable = false,  timeLeft = 10, toggle = true }, -- "Sacred Cleansing"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Magic", },
		},	
		associatedSpell = 4987, -- "Cleanse"
	},
}
