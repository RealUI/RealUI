-- Mage

Raven.classConditions.MAGE = {
	["Remove Curse"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 475 }, -- "Remove Curse"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Curse", },
		},	
		associatedSpell = 475, -- "Remove Curse"
	},
}
