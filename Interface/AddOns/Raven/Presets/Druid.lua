-- Druid

local BUFF = true
local DEBUFF = false
local p = Raven.ColorPalette

Raven.classSpells.DRUID = {
	{ "Aquatic Form", BUFF, p.Cyan, id = 1066 },
	{ "Astral Communion", BUFF, p.Purple3, school = "Arcane", id = 127663 },
	{ "Astral Storm", DEBUFF, p.Purple3, school = "Arcane", id = 106996 },
	{ "Barkskin", BUFF, p.Brown1, cooldown = true, school = "Nature", id = 22812 },
	{ "Bear Form", BUFF, p.Cyan, school = "Physical", id = 5487 },
	{ "Bear Hug", DEBUFF, p.Red2, cooldown = true, id = 102795 },
	{ "Berserk", BUFF, p.Orange3, cooldown = true, id = 106952 },
	{ "Cat Form", BUFF, p.Cyan, id = 768 },
	{ "Celestial Alignment", BUFF, p.Blue3, cooldown = true, id = 112071 },
	{ "Cenarion Ward", BUFF, p.Green3, cooldown = true, school = "Nature", id = 102351 },
	{ "Charm Woodland Creature", BUFF, p.Pink, id = 127757 },
	{ "Clearcasting", BUFF, p.Blue2, id = 16870 },
	{ "Cyclone", DEBUFF, p.Gray, cooldown = true, school = "Nature", id = 33786 },
	{ "Dash", BUFF, p.Green2, cooldown = true, id = 1850 },
	{ "Disorienting Roar", DEBUFF, p.Brown3, cooldown = true, id = 99 },
	{ "Displacer Beast", BUFF, p.Blue2, cooldown = true, id = 102280 },
	{ "Eclipse (Lunar)", BUFF, p.Blue2, id = 48518 },
	{ "Eclipse (Solar)", BUFF, p.Brown2, id = 48517 },
	{ "Enrage", BUFF, p.Red2, cooldown = true, id = 5229 },
	{ "Entangling Roots", DEBUFF, p.Brown3, school = "Nature", id = 339 },
	{ "Faerie Fire", DEBUFF, p.Pink, cooldown = true, school = "Nature", id = 770 },
	{ "Faerie Swarm", DEBUFF, p.Pink, school = "Nature", id = 102355 },
	{ "Ferocious Bite", nil, p.Orange3, id = 22568 },
	{ "Flight Form", BUFF, p.Cyan, id = 33943 },
	{ "Force of Nature", BUFF, p.Green1, cooldown = true, school = "Nature", id = 106737 },
	{ "Frenzied Regeneration", BUFF, p.Green3, cooldown = true, id = 22842 },
	{ "Fungal Growth", DEBUFF, p.Blue3, id = 81283 },
	{ "Glyph of Rejuvenation", BUFF, p.Green3, school = "Nature", id = 96206 },
	{ "Growl", DEBUFF, p.Orange2, cooldown = true, id = 6795 },
	{ "Healing Touch", nil, p.Green1, school = "Nature", id = 5185 },
	{ "Heart of the Wild", BUFF, p.Orange3, school = "Nature", id = 108288 },
	{ "Hibernate", DEBUFF, p.Purple2, school = "Nature", id = 2637 },
	{ "Hurricane", DEBUFF, p.Purple2, school = "Nature", id = 16914 },
	{ "Incarnation", BUFF, p.Cyan, cooldown = true, id = 106731 },
	{ "Incarnation: Chosen of Elune", BUFF, p.Cyan, id = 102560 },
	{ "Incarnation: King of the Jungle", BUFF, p.Cyan, id = 102543 },
	{ "Incarnation: Son of Ursoc", BUFF, p.Cyan, id = 102558 },
	{ "Incarnation: Tree of Life", BUFF, p.Cyan, id = 33891 },
	{ "Infected Wounds", DEBUFF, p.Red3, id = 48484 },
	{ "Innervate", BUFF, p.Blue1, cooldown = true, school = "Nature", id = 29166 },
	{ "Ironbark", BUFF, p.Brown2, cooldown = true, school = "Nature", id = 102342 },
	{ "Lacerate", DEBUFF, p.Purple3, cooldown = true, id = 33745 },
	{ "Leader of the Pack", BUFF, p.Orange2, id = 17007 },
	{ "Lifebloom", BUFF, p.Green2, school = "Nature", id = 33778 },
	{ "Living Seed", BUFF, p.Yellow3, school = "Nature", id = 48503 },
	{ "Lunar Shower", BUFF, p.Cyan, id = 33605 },
	{ "Maim", DEBUFF, p.Brown2, cooldown = true, id = 22570 },
	{ "Mangle", DEBUFF, p.Red3, cooldown = true, id = 33917 },
	{ "Mark of the Wild", BUFF, p.Pink, school = "Nature", id = 1126 },
	{ "Mass Entanglement", DEBUFF, p.Brown3, cooldown = true, school = "Nature", id = 102359 },
	{ "Mastery: Harmony", BUFF, p.Yellow1, id = 77495 },
	{ "Mastery: Nature's Guardian", BUFF, p.Cyan, id = 77494 },
	{ "Mastery: Razor Claws", BUFF, p.Brown3, id = 77493 },
	{ "Mastery: Total Eclipse", BUFF, p.Blue2, id = 77492 },
	{ "Maul", nil, p.Brown2, cooldown = true, id = 6807 },
	{ "Might of Ursoc", BUFF, p.Green1, cooldown = true, id = 106922 },
	{ "Mighty Bash", DEBUFF, p.Cyan, cooldown = true, id = 5211 },
	{ "Moonfire", DEBUFF, p.Cyan, school = "Arcane", id = 8921 },
	{ "Moonkin Aura", BUFF, p.Purple1, id = 24907 },
	{ "Moonkin Form", BUFF, p.Cyan, id = 24858 },
	{ "Nature's Cure", nil, p.Grey, cooldown = true, id = 88423 },
	{ "Nature's Grace", BUFF, p.Brown1, id = 16886 },
	{ "Nature's Grasp", BUFF, p.Brown3, cooldown = true, school = "Nature", id = 16689 },
	{ "Nature's Swiftness", BUFF, p.Blue3, cooldown = true, id = 132158 },
	{ "Nature's Vigil", BUFF, p.Green2, cooldown = true, school = "Nature", id = 124974 },
	{ "Omen of Clarity", BUFF, p.Green2, school = "Nature", id = 16864 },
	{ "Owlkin Frenzy", BUFF, p.Yellow3, id = 48393 },
	{ "Pounce", DEBUFF, p.Grey, id = 9005 },
	{ "Pounce Bleed", DEBUFF, p.Brown1, id = 9007 },
	{ "Predatory Swiftness", BUFF, p.Yellow3, id = 16974 },
	{ "Prowl", BUFF, p.Purple2, cooldown = true, id = 5215 },
	{ "Rake", DEBUFF, p.Purple3, id = 1822 },
	{ "Rebirth", nil, p.Purple3, cooldown = true, school = "Nature", id = 20484 },
	{ "Regrowth", BUFF, p.Green3, school = "Nature", id = 8936 },
	{ "Rejuvenation", BUFF, p.Green1, school = "Nature", lockout = true, id = 774 },
	{ "Remove Corruption", nil, p.Purple2, cooldown = true, school = "Arcane", id = 2782 },
	{ "Renewal", nil, p.Cyan, cooldown = true, school = "Nature", id = 108238 },
	{ "Rip", DEBUFF, p.Blue3, id = 1079 },
	{ "Savage Defense", BUFF, p.Orange2, cooldown = true, id = 62606 },
	{ "Savage Roar", BUFF, p.Green3, id = 52610 },
	{ "Shooting Stars", BUFF, p.Blue2, id = 93399 },
	{ "Shred", nil, p.Yellow2, id = 5221 },
	{ "Skull Bash", DEBUFF, p.Gray, cooldown = true, id = 106839 },
	{ "Solar Beam", DEBUFF, p.Yellow2, cooldown = true, school = "Nature", id = 78675 },
	{ "Soothe", DEBUFF, p.Brown3, id = 2908 },
	{ "Soul of the Forest", BUFF, p.Green1, id = 114107 },
	{ "Stampeding Roar", BUFF, p.Orange1, cooldown = true, id = 106898 },
	{ "Starfall", BUFF, p.Purple3, cooldown = true, school = "Arcane", id = 48505 },
	{ "Starsurge", BUFF, p.Purple2, cooldown = true, school = "Arcane", id = 78674 },
	{ "Sunfire", DEBUFF, p.Orange2, id = 93402 },
	{ "Survival Instincts", BUFF, p.Orange3, cooldown = true, id = 61336 },
	{ "Swift Flight Form", BUFF, p.Cyan, id = 40120 },
	{ "Swiftmend", BUFF, p.Blue3, cooldown = true, school = "Nature", id = 18562 },
	{ "Swipe", nil, p.Yellow3, cooldown = true, school = "Nature", id = 779 },
	{ "Symbiosis", BUFF, p.Green3, id = 110309 },
	{ "Thick Hide", BUFF, p.Brown2, id = 16931 },
	{ "Thrash", DEBUFF, p.Gray, cooldown = true, id = 77758 }, -- Cataclysm level 81
	{ "Tiger's Fury", BUFF, p.Yellow3, cooldown = true, id = 5217 },
	{ "Tranquility", BUFF, p.Purple2, cooldown = true, school = "Nature", id = 740 },
	{ "Travel Form", BUFF, p.Cyan, id = 783 },
	{ "Treant Form", BUFF, p.Cyan, id = 114282 },
	{ "Typhoon", DEBUFF, p.Purple1, cooldown = true, school = "Nature", id = 132469 },
	{ "Ursol's Vortex", DEBUFF, p.Blue3, cooldown = true, school = "Nature", id = 102793 },
	{ "Vengeance", BUFF, p.Orange3, id = 84840 },
	{ "Wild Charge", nil, p.Purple3, cooldown = true, id = 102401 },
	{ "Wild Growth", BUFF, p.Blue2, cooldown = true, school = "Nature", id = 48438 },
	{ "Wild Mushroom: Bloom", nil, p.Orange2, cooldown = true, school = "Nature", id = 102791 },
	{ "Wild Mushroom: Detonate", nil, p.Orange2, cooldown = true, school = "Nature", id = 88751 },
}

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
