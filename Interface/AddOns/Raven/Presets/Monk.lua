-- Monk

Raven.classConditions.MONK = {
	["Legacy of the Emperor Missing"] = { -- "Mark of the Wild", "Blessing of Kings", "Legacy of the Emperor", "Embrace of the Shale Spider"
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 115921 }, -- "Legacy of the Emperor"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 1126, 20217, 115921, 90363 }, },
		},
		associatedSpell = 115921, -- "Legacy of the Emperor"
	},
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
