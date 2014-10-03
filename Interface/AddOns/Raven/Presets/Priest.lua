-- Priest

Raven.classConditions.PRIEST = {
	["Fortitude Missing"] = { -- "Commanding Shout", "Power Word: Fortitude", "Blood Pact", "Qiraji Fortitude"
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 21562, }, -- "Power Word: Fortitude"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 469, 21562, 109773, 90364 }, }, -- replace blood pact with dark intent in 5.2
		},
		associatedSpell = 21562, -- "Power Word: Fortitude"
	},
	["Vampiric Embrace!"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["All Buffs"] = { enable = true, unit = "player", auras = { 15473 }, }, -- "Shadowform"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player", auras = { 15286 }, }, -- "Vampiric Embrace"
			["Spell Ready"] = { enable = true, spell = 15286, }, -- "Vampiric Embrace"
		},	
		associatedSpell = 15286, -- "Vampiric Embrace"
	},
	["Chakra!"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Any Buffs"] = { enable = true, toggle = true, unit = "player", auras = { 81206, 81208, 81209 }, }, -- "Sanctuary" or "Serenity" or "Chastise"
			["Spell Ready"] = { enable = true, spell = 81206, }, -- "Chakra: Sanctuary"
		},	
		associatedSpell = 81206, -- "Chakra"
	},
	["Purify (Disease)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 527, }, -- "Purify"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Disease", },
		},	
		associatedSpell = 527, -- "Purify"
	},
	["Purify (Magic)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 527, }, -- "Nature's Cure"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Magic", },
		},	
		associatedSpell = 527, -- "Purify"
	},
}
