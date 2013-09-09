-- Monk

local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local BUFF = true
local DEBUFF = false
local p = Raven.ColorPalette

Raven.classSpells.MONK = {
	{ "Adaptation", BUFF, p.Green3, id = 126046 }, 
	{ "Avert Harm", BUFF, p.Yellow1, cooldown = true, id = 115213 }, 
	{ "Blackout Kick", DEBUFF, p.Purple1, id = 100784 }, 
	{ "Breath of Fire", DEBUFF, p.Red1, school = "Fire", id = 115181 }, 
	{ "Charging Ox Wave", DEBUFF, p.Yellow2, cooldown = true, id = 119392 },
	{ "Chi Brew", nil, p.Gray, cooldown = true, id = 115399 }, 
	{ "Chi Burst", BUFF, p.Pink, cooldown = true, school = "Nature", id = 123986 }, 
	{ "Chi Sphere", BUFF, p.Green2, id = 121286 }, 
	{ "Chi Wave", BUFF, p.Green1, cooldown = true, school = "Nature", id = 115098 }, 
	{ "Clash", DEBUFF, p.Orange2, cooldown = true, id = 122057 },
	{ "Combo Breaker", BUFF, p.Green3, id = 137384 }, 
	{ "Crackling Jade Lightning", DEBUFF, p.Green3, school = "Nature", id = 117952 }, 
	{ "Dampen Harm", BUFF, p.Orange3, cooldown = true, id = 122278 }, 
	{ "Dematerialize", BUFF, p.Purple3, id = 122464 }, 
	{ "Detox", nil, p.Purple2, cooldown = true, id = 115450 },
	{ "Diffuse Magic", BUFF, p.Purple2, cooldown = true, school = "Nature", id = 122783 }, 
	{ "Disable", DEBUFF, p.Orange2, id = 116095 }, 
	{ "Dizzying Haze", DEBUFF, p.Orange3, id = 115180 }, 
	{ "Elusive Brew", BUFF, p.Yellow3, cooldown = true, id = 115308 },
	{ "Eminence", BUFF, p.Green3, school = "Nature", id = 126890 }, 
	{ "Energizing Brew", BUFF, p.Green1, cooldown = true, id = 115288 },
	{ "Enveloping Mist", BUFF, p.Green3, school = "Nature", id = 132120 },
	{ "Expel Harm", nil, p.Green1, cooldown = true, school = "Nature", id = 115072 }, 
	{ "Fists of Fury", DEBUFF, p.Blue1, cooldown = true, id = 113656 },
	{ "Flying Serpent Kick", DEBUFF, p.Blue1, cooldown = true, id = 101545 },
	{ "Fortifying Brew", BUFF, p.Yellow3, cooldown = true, id = 115203 },
	{ "Grapple Weapon", DEBUFF, p.Brown2, cooldown = true, id = 117368 },
	{ "Guard", BUFF, p.Yellow2, cooldown = true, id = 115295 }, 
	{ "Healing Sphere", BUFF, p.Green2, school = "Nature", id = 115464 }, 
	{ "Invoke Xuen, the White Tiger", nil, p.Gray, cooldown = true, school = "Nature", id = 123904 }, 
	{ "Jab", nil, p.Green3, id = 100780 }, 
	{ "Keg Smash", nil, p.Brown2, cooldown = true, id = 121253 }, 
	{ "Leer of the Ox", DEBUFF, p.Gray, cooldown = true, id = 115543 }, 
	{ "Leg Sweep", DEBUFF, p.Yellow1, cooldown = true, id = 119381 },
	{ "Legacy of the Emperor", BUFF, p.Green1, school = "Holy", id = 115921 }, 
	{ "Legacy of the White Tiger", BUFF, p.Yellow3, school = "Holy", id = 116781 }, 
	{ "Life Cocoon", BUFF, p.Green1, cooldown = true, school = "Nature", id = 116849 }, 
	{ "Mana Tea", BUFF, p.Blue2, cooldown = true, id = 115294 }, 
	{ "Mastery: Combo Breaker", BUFF, p.Green3, id = 115636 },
	{ "Mastery: Elusive Brawler", BUFF, p.Brown1, id = 117906 },
	{ "Mastery: Gift of the Serpent", BUFF, p.Green3, id = 117907 },
	{ "Momentum", BUFF, p.Orange2, id = 115174 }, 
	{ "Mortal Wounds", DEBUFF, p.Red2, id = 115804 }, 
	{ "Muscle Memory", BUFF, p.Brown3, id = 139598 }, 
	{ "Nimble Brew", BUFF, p.Blue3, cooldown = true, id = 137562 }, 
	{ "Paralysis", DEBUFF, p.Purple1, cooldown = true, school = "Nature", id = 115078 },
--	{ "Path of Blossoms", BUFF, p.Red2, school = "Nature", id = 124336 }, -- removed in 5.2
	{ "Power Guard", BUFF, p.Brown2, id = 118636 }, 
	{ "Provoke", DEBUFF, p.Red1, cooldown = true, id = 115546 },
	{ "Purifying Brew", nil, p.Green1, cooldown = true, id = 119582 }, 
	{ "Renewing Mist", BUFF, p.Green3, cooldown = true, school = "Nature", id = 115151 }, 
	{ "Resuscitate", nil, p.Gray, school = "Nature", lockout = true, id = 115178 }, 
	{ "Retreat", BUFF, p.Blue3, id = 124968 }, 
	{ "Revival", nil, p.Green3, cooldown = true, school = "Nature", id = 115310 }, 
	{ "Ring of Peace", BUFF, p.Blue3, cooldown = true, school = "Physical", id = 116844 }, 
	{ "Rising Sun Kick", nil, p.Orange1, cooldown = true, id = 107428 }, 
	{ "Roll", nil, p.Green1, cooldown = true, id = 109132 }, 
	{ "Rushing Jade Wind", DEBUFF, p.Green2, cooldown = true, id = 116847 }, 
	{ "Sanctuary of the Ox", BUFF, p.Yellow3, school = "Nature", id = 126119 }, 
	{ "Serpent's Zeal", BUFF, p.Green2, id = 127722 }, 
	{ "Shuffle", BUFF, p.Green1, id = 115307 }, 
	{ "Soothing Mist", BUFF, p.Green3, school = "Nature", lockout = true, id = 115175 },
	{ "Sparring", BUFF, p.Yellow3, id = 116023 }, 
	{ "Spear Hand Strike", DEBUFF, p.Yellow3, cooldown = true, id = 116705 }, 
	{ "Spinning Crane Kick", BUFF, p.Green2, id = 107270 }, 
	{ "Stagger", BUFF, p.Green3, id = 124255 }, 
	{ "Stance of the Fierce Tiger", BUFF, p.Blue3, id = 103985 }, 
	{ "Stance of the Sturdy Ox", BUFF, p.Yellow3, id = 115069 }, 
	{ "Stance of the Wise Serpent", BUFF, p.Green3, id = 115070 }, 
	{ "Storm, Earth, and Fire", BUFF, p.Yellow3, id = 137639 }, 
	{ "Summon Black Ox Statue", nil, p.Yellow1, cooldown = true, id = 115315 }, 
	{ "Summon Jade Serpent Statue", nil, p.Green3, cooldown = true, id = 115313 }, 
	{ "Swift Reflexes", BUFF, p.Purple3, id = 124334 }, 
	{ "Thunder Focus Tea", BUFF, p.Blue3, cooldown = true, id = 116680 }, 
	{ "Tiger Power", BUFF, p.Green2, id = 125359 }, 
	{ "Tiger Strikes", BUFF, p.Gray, id = 120278 }, 
	{ "Tiger's Lust", BUFF, p.Yellow3, cooldown = true, id = 116841 }, 
	{ "Tigereye Brew", BUFF, p.Blue2, cooldown = true, id = 116740 }, 
	{ "Touch of Death", nil, p.Red1, cooldown = true, id = 115080 }, 
	{ "Touch of Karma", DEBUFF, p.Gray, cooldown = true, id = 122470 }, 
	{ "Transcendence", BUFF, p.Green3, cooldown = true, id = 101643 }, 
	{ "Transcendence: Transfer", nil, p.Pink, cooldown = true, id = 119996 }, 
	{ "Vengeance", BUFF, p.Purple2, id = 120267 },
	{ "Vital Mists", BUFF, p.Blue3, id = 118674 }, 
	{ "Zen Flight", BUFF, p.Blue3, school = "Nature", id = 125883 }, 
	{ "Zen Meditation", BUFF, p.Cyan, cooldown = true, school = "Nature", id = 115176 }, 
	{ "Zen Pilgramage", nil, p.Blue1, school = "Nature", id = 126892 }, 
	{ "Zen Sphere", BUFF, p.Cyan, cooldown = true, school = "Nature", id = 124081 }, 
}

Raven.classConditions.MONK = {
	["Legacy Buff Missing"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 115921 }, -- "Legacy of the Emperor"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 115921, 116781 }, }, -- "Legacy of the Emperor", "Legacy of the White Tiger"
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
