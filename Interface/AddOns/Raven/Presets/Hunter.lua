-- Hunter

Raven.classConditions.HUNTER = {
	["Check Aspect!"] = {
		tests = {
			["Player Status"] = { enable = true, inCombat = true },
			["Any Buffs"] = { enable = true, toggle = false, unit = "player", isMine = true,
				auras = { 13159, 5118 }, }, -- "Aspect of the Pack", "Aspect of the Cheetah"
		},	
		associatedSpell = 13159, -- "Aspect of the Pack"
	},
	["No Pet!"] = {
		tests = {
			["Player Status"] = { enable = true, inCombat = true, hasPet = false },
		},	
	},
	["Trueshot Aura Missing"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 19506 }, -- "Trueshot Aura"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player", auras = { 19506 }, }, -- "Trueshot Aura"
		},	
		associatedSpell = 19506, -- "Trueshot Aura"
	},
}
