-- Warrior

Raven.classConditions.WARRIOR = {
	["Battle Shout!"] = {
		tests = {
			["Player Status"] = { enable = true, inCombat = true },
			["Spell Ready"] = { enable = true, spell = 6673, }, -- "Battle Shout"
			["All Buffs"] = { enable = true, toggle = true, unit = "player", isMine = true, auras = { 469 }, }, -- "Commanding Shout"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 57330, 8076, 6673, 93435 }, }, -- "Horn of Winter", "Strength of Earth", "Battle Shout", "Roar of Courage"
		},
		dependencies = { ["Commanding Shout!"] = false },
		associatedSpell = 6673, -- "Battle Shout"
	},
	["Commanding Shout!"] = {
		tests = {
			["Player Status"] = { enable = true, inCombat = true, checkStance = true, stance = 71 }, -- "Defensive Stance"
			["Spell Ready"] = { enable = true, spell = 469 }, -- "Commanding Shout"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 469, 21562, 109773 }, }, -- "Commanding Shout", "Power Word: Fortitude", "Dark Intent" (replaces blood pact in 5.2)
		},	
		associatedSpell = 469, -- "Commanding Shout"
	},
}
