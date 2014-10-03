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
	["Blessing Missing"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false, },
			["Spell Ready"] = { enable = true, spell = 19740 }, -- "Blessing of Might"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 19740, 20217 }, }, -- "Blessing of Might", "Blessing of Kings"
		},	
	},
	["Seal Missing"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false, checkLevel = true, level = 3 },
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 105361, 20165, 20164, 20154, 31801 }, }, -- "Seal of Command", "Seal of Insight", "Seal of Righteousness", "Seal of Truth"
		},	
	},
}
