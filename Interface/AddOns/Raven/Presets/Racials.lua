-- Racial abilities

local BUFF = true
local DEBUFF = false
local p = Raven.ColorPalette

Raven.racialSpells = {
	Scourge = {
		{ "Cannibalize", BUFF, p.Orange1, cooldown = true, id = 20577 },
		{ "Will of the Forsaken", nil, p.Purple1, cooldown = true, id = 7744 },
	},
	Orc = {
		{ "Blood Fury", BUFF, p.Red1, cooldown = true, id = 33697 },
	},
	Tauren = {
		{ "War Stomp", DEBUFF, p.Orange1, cooldown = true, id = 20549 },
	},
	Pandaren = {
		{ "Quaking Palm", DEBUFF, p.Orange1, cooldown = true, id = 107079 },
	},
	Troll = {
		{ "Berserking", BUFF, p.Red1, cooldown = true, id = 26297 },
	},
	BloodElf = {
		{ "Arcane Torrent", DEBUFF, p.Blue3, cooldown = true, school = "Arcane", id = 28730 },
	},
	NightElf = {
		{ "Shadowmeld", BUFF, p.Purple3, cooldown = true, id = 58984 },
	},
	Human = {
		{ "Every Man for Himself", nil, p.Yellow1, cooldown = true, id = 59752 },
	},
	Worgen = {
		{ "Darkflight", BUFF, p.Green1, cooldown = true, id = 68992 },
		{ "Running Wild", BUFF, p.Gray, id = 87840 },
		{ "Transform: Worgen", BUFF, p.Gray, id = 69001 },
	},
	Goblin = {
		{ "Pack Hobgoblin", nil, p.Yellow1, cooldown = true, id = 69046 },
		{ "Rocket Barrage", nil, p.Red1, cooldown = true, school = "Fire", id = 69041 },
		{ "Rocket Jump", nil, p.Orange1, cooldown = true, id = 69070 },
	},
	Gnome = {
		{ "Escape Artist", nil, p.Yellow1, cooldown = true, id = 20589 },
	},
	Dwarf = {
		{ "Stoneform", BUFF, p.Orange1, cooldown = true, id = 20594 },
	},
	Draenei = {
		{ "Gift of the Naaru", BUFF, p.Blue3, cooldown = true, school = "Holy", id = 59545 }, -- special case code included in profile.lua
	},
}
