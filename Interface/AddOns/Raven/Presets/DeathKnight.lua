-- Death Knight

Raven.runeSpells = {
	["Army of the Dead"] = { blood = true, frost = true, unholy = true, id = 42650 },
	["Chains of Ice"] = { frost = true, id = 45524 },
	["Control Undead"] = { unholy = true, id = 111673 },
	["Dark Transformation"] = { unholy = true, id = 63560 },
	["Death and Decay"] = { unholy = true, id = 43265 },
	["Death Gate"] = { unholy = true, id = 50977 },
	["Death Strike"] = { frost = true, unholy = true, id = 49998 },
	["Festering Strike"] = { blood = true, frost = true, id = 85948 },
	["Heart Strike"] = { blood = true, id = 55050 },
	["Howling Blast"] = { frost = true, id = 49184 },
	["Icy Touch"] = { frost = true, id = 45477 },
	["Obliterate"] = { frost = true, unholy = true, id = 49020 },
	["Path of Frost"] = { frost = true, id = 3714 },
	["Pestilence"] = { blood = true, id = 50842 },
	["Pillar of Frost"] = { frost = true, id = 51271 },
	["Plague Strike"] = { unholy = true, id = 45462 },
	["Rune Tap"] = { blood = true, id = 48982 },
	["Scourge Strike"] = { unholy = true, id = 55090 },
	["Soul Reaper"] = { frost = true, id = 130735 },
	["Strangulate"] = { blood = true, id = 47476 },
}

Raven.classConditions.DEATHKNIGHT = {
	["Presence Missing"] = {
		tests = {
			["Spell Ready"] = { enable = true, spell = 48266, }, -- "Frost Presence"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 48266, 48263, 48265 }, }, --  "Frost Presence", "Blood Presence", "Unholy Presence"
		},	
	},
}
