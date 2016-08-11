-- Priest

Raven.classConditions.PRIEST = {
	["Purify (Disease)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 527, }, -- "Purify"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Disease", },
		},	
		associatedSpell = 527, -- "Purify"
	},
	["Purify (Magic)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 527, }, -- "Purify"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Magic", },
		},	
		associatedSpell = 527, -- "Purify"
	},
}
