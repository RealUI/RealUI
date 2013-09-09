-- Hunter

local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local BUFF = true
local DEBUFF = false
local p = Raven.ColorPalette

Raven.classSpells.HUNTER = {
	{ "A Murder of Crows", BUFF, p.Blue3, cooldown = true, id = 131894 },
	{ "Aspect of the Beast", BUFF, p.Pink, id = 61648 },
	{ "Aspect of the Cheetah", BUFF, p.Yellow1, id = 5118 },
	{ "Aspect of the Fox", BUFF, p.Orange1, id = 82661 }, 
	{ "Aspect of the Hawk", BUFF, p.Blue2, id = 13165 },
	{ "Aspect of the Iron Hawk", BUFF, p.Blue2, id = 109260 },
	{ "Aspect of the Pack", BUFF, p.Gray, id = 13159 },
	{ "Arcane Shot", nil, p.Blue3, lockout = true, school = "Arcane", id = 3044 },
	{ "Auto Shot", BUFF, p.Blue2, id = 75 },
	{ "Barrage", nil, p.Blue2, cooldown = true, id = 120360 },
	{ "Beast Cleave", BUFF, p.Red1, id = 115939 },
	{ "Beast Lore", BUFF, p.Red1, school = "Nature", id = 1462 },
	{ "Bestial Wrath", BUFF, p.Red1, cooldown = true, id = 19574 },
	{ "Binding Shot", DEBUFF, p.Pink, cooldown = true, school = "Nature", id = 109248 },
	{ "Black Arrow", DEBUFF, p.Purple3, cooldown = true, shared = L["Fire Traps"], school = "Shadow", id = 3674 },
	{ "Blink Strike", nil, p.Purple1, cooldown = true, id = 130392 },
	{ "Bombardment", BUFF, p.Red2, id = 35110 },
	{ "Camouflage", BUFF, p.Gray, cooldown = true, school = "Nature", id = 51753 }, 
	{ "Chimera Shot", BUFF, p.Purple2, cooldown = true, school = "Nature", id = 53209 },
	{ "Cobra Strikes", BUFF, p.Pink, id = 53260 },
	{ "Concussive Barrage", DEBUFF, p.Cyan, id = 35102 },
	{ "Concussive Shot", DEBUFF, p.Cyan, cooldown = true, id = 5116 },
	{ "Deterrence", BUFF, p.Cyan, cooldown = true, id = 19263 },
	{ "Dire Beast", BUFF, p.Gray, cooldown = true, school = "Nature", id = 120679 },
	{ "Disengage", nil, p.Purple3, cooldown = true, id = 781 },
	{ "Distracting Shot", DEBUFF, p.Purple2, cooldown = true, school = "Arcane", id = 20736 },
	{ "Eagle Eye", BUFF, p.Cyan, school = "Arcane", id = 6197 },
	{ "Entrapment", DEBUFF, p.Yellow2, id = 19387 },
	{ "Exhilaration", nil, p.Purple3, cooldown = true, id = 109304 },
	{ "Explosive Shot", DEBUFF, p.Yellow1, cooldown = true, school = "Fire", id = 53301 },
	{ "Explosive Trap", nil, p.Orange2, cooldown = true, shared = L["Fire Traps"], school = "Fire", id = 13813 },
	{ "Feed Pet", nil, p.Brown1, cooldown = true, id = 6991 },
	{ "Feign Death", BUFF, p.Green3, cooldown = true, id = 5384 },
	{ "Fervor", BUFF, p.Blue3, cooldown = true, id = 82726 },
	{ "Fireworks", nil, p.Red2, id = 127933 },
	{ "Flare", DEBUFF, p.Orange2, cooldown = true, school = "Arcane", id = 1543 },
	{ "Focus Fire", BUFF, p.Orange3, id = 82692 },
	{ "Freezing Trap", nil, p.Purple3, cooldown = true, shared = L["Frost Traps"], school = "Frost", id = 1499 },
	{ "Frenzy", BUFF, p.Orange3, id = 19623 },
	{ "Glaive Toss", DEBUFF, p.Blue3, cooldown = true, school = "Nature", id = 117050 },
	{ "Go for the Throat", BUFF, p.Orange3, id = 34954 },
	{ "Hunter's Mark", DEBUFF, p.Red1, school = "Arcane", id = 1130 },
	{ "Ice Trap", nil, p.Cyan, cooldown = true, shared = L["Frost Traps"], school = "Frost", id = 13809 },
	{ "Intimidation", DEBUFF, p.Brown3, cooldown = true, school = "Nature", id = 19577 },
	{ "Kill Command", nil, p.Orange3, cooldown = true, id = 34026 },
	{ "Kill Shot", nil, p.Red1, cooldown = true, id = 53351 },
	{ "Lock and Load", BUFF, p.Red3, id = 56453 },
	{ "Lynx Rush", nil, p.Yellow2, cooldown = true, id = 120697 },
	{ "Master Marksman", BUFF, p.Purple3, id = 34487 },
	{ "Master's Call", BUFF, p.Yellow2, cooldown = true, id = 53271 },
	{ "Mend Pet", BUFF, p.Orange2, school = "Nature", id = 136 },
	{ "Misdirection", BUFF, p.Cyan, cooldown = true, id = 34477 },
	{ "Narrow Escape", DEBUFF, p.Red2, id = 109298},
	{ "Piercing Shots", DEBUFF, p.Red2, id = 53238 },
	{ "Posthaste", BUFF, p.Brown3, id = 109215},
	{ "Powershot", nil, p.Yellow1, cooldown = true, id = 109259 },
	{ "Rapid Fire", BUFF, p.Red2, cooldown = true, id = 3045 },
	{ "Rapid Recuperation", BUFF, p.Red2, id = 53232 },
	{ "Readiness", nil, p.Blue1, cooldown = true, id = 23989 },
	{ "Scare Beast", DEBUFF, p.Blue2, school = "Nature", id = 1513},
	{ "Scatter Shot", DEBUFF, p.Gray, cooldown = true, id = 19503 },
	{ "Serpent Sting", DEBUFF, p.Brown3, school = "Nature", lockout = true, id = 1978 },
	{ "Silencing Shot", DEBUFF, p.Purple3, cooldown = true, id = 34490 },
	{ "Snake Trap", nil, p.Brown1, cooldown = true, school = "Nature", id = 34600 },
	{ "Spirit Bond", BUFF, p.Brown1, school = "Nature", id = 109212},
	{ "Stampede", BUFF, p.Yellow3, cooldown = true, school = "Nature", id = 121818 },
	{ "Steady Focus", BUFF, p.Blue3, id = 53224 },
	{ "Tame Beast", BUFF, p.Green1, school = "Nature", id = 1515 },
	{ "The Beast Within", BUFF, p.Red1, id = 34692 },
	{ "Thrill of the Hunt", BUFF, p.Red1, id = 109306 },
	{ "Track Beasts", BUFF, p.Brown3, id = 1494 },
	{ "Track Demons", BUFF, p.Brown2, id = 19878 },
	{ "Track Dragonkin", BUFF, p.Orange1, id = 19879 },
	{ "Track Elementals", BUFF, p.Blue2, id = 19880 },
	{ "Track Giants", BUFF, p.Blue3, id = 19882 },
	{ "Track Hidden", BUFF, p.Brown3, id = 19885 },
	{ "Track Humanoids", BUFF, p.Blue1, id = 19883 },
	{ "Track Undead", BUFF, p.Green3, id = 19884 },
	{ "Trap Launcher", BUFF, p.Red3, cooldown = true, id = 77769 },
	{ "Trueshot Aura", BUFF, p.Brown3, school = "Arcane", id = 19506 },
	{ "Widow Venom", DEBUFF, p.Brown1, school = "Nature", id = 82654 },
	{ "Wyvern Sting", DEBUFF, p.Green2, cooldown = true, school = "Nature", id = 19386 },
}

Raven.classConditions.HUNTER = {
	["Check Aspect!"] = {
		tests = {
			["Player Status"] = { enable = true, inCombat = true },
			["Any Buffs"] = { enable = true, toggle = false, unit = "player", isMine = true,
				auras = { 13159, 5118 }, }, -- "Aspect of the Pack", "Aspect of the Cheetah"
		},	
		associatedSpell = 13159, -- "Aspect of the Pack"
	},
	["Aspect Missing"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false, },
			["Spell Ready"] = { enable = true, spell = 13165 }, -- "Aspect of the Hawk"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player", isMine = true,
				auras = { 5118, 82661, 13165, 13159, 20043 }, }, -- "Aspect of the Cheetah", "Fox", "Hawk", "Pack", "Wild"
		},	
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
