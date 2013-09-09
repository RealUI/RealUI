-- Mage

local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local BUFF = true
local DEBUFF = false
local p = Raven.ColorPalette

Raven.classSpells.MAGE = {
	{ "Alter Time", BUFF, p.Blue2, cooldown = true, school = "Arcane", id = 108978 }, 
	{ "Ancient Portal: Dalaran", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 120146 }, 
	{ "Arcane Barrage", nil, p.Purple3, cooldown = true, school = "Arcane", id = 44425 }, 
	{ "Arcane Blast", DEBUFF, p.Purple3, school = "Arcane", id = 30451 }, 
	{ "Arcane Brilliance", BUFF, p.Cyan, school = "Arcane", id = 1459 }, 
	{ "Arcane Charge", DEBUFF, p.Purple3, school = "Arcane", id = 36032 }, 
	{ "Arcane Explosion", nil, p.Purple3, lockout = true, school = "Arcane", id = 1449 }, 
	{ "Arcane Missiles", nil, p.Blue1, school = "Arcane", id = 5143 }, 
	{ "Arcane Missiles!", BUFF, p.Blue1, id = 79683 }, -- procs when Arcane Missiles is available 
	{ "Arcane Power", BUFF, p.Blue2, cooldown = true, school = "Arcane", id = 12042 }, 
	{ "Blazing Speed", BUFF, p.Orange2, cooldown = true, school = "Fire", id = 108843 }, 
	{ "Blink", BUFF, p.Purple3, cooldown = true, school = "Arcane", id = 1953 }, 
	{ "Blizzard", DEBUFF, p.Blue2, school = "Frost", id = 10 }, 
	{ "Brain Freeze", BUFF, p.Gray, id = 44549 }, 
	{ "Cauterize", BUFF, p.Orange3, id = 86949 }, 
	{ "Cold Snap", nil, p.Blue2, cooldown = true, school = "Frost", id = 11958 }, 
	{ "Combustion", DEBUFF, p.Yellow3, cooldown = true, school = "Fire", id = 11129 }, 
	{ "Cone of Cold", DEBUFF, p.Cyan, cooldown = true, school = "Frost", id = 120 }, 
	{ "Conjure Familiar", nil, p.Green3, cooldown = true, id = 126578 }, 
	{ "Conjure Refreshment Table", nil, p.Purple3, cooldown = true, school = "Arcane", id = 43987 }, 
	{ "Counterspell", nil, p.Purple1, cooldown = true, school = "Arcane", id = 2139 }, 
	{ "Dalaran Brilliance", BUFF, p.Purple2, school = "Arcane", id = 61316 }, 
	{ "Deep Freeze", DEBUFF, p.Cyan, cooldown = true, school = "Frost", id = 44572 }, 
	{ "Dragon's Breath", DEBUFF, p.Orange1, cooldown = true, school = "Fire", id = 31661 }, 
	{ "Evocation", BUFF, p.Purple2, cooldown = true, school = "Arcane", id = 12051 }, 
	{ "Fingers of Frost", BUFF, p.Blue3, id = 112965 }, 
	{ "Fire Blast", nil, p.Red3, cooldown = true, school = "Fire", id = 2136 }, 
	{ "Fireball", nil, p.Orange2, school = "Fire", lockout = true, id = 133 }, 
	{ "Flameglow", BUFF, p.Orange3, school = "Fire", id = 140468 }, 
	{ "Flamestrike", DEBUFF, p.Orange1, cooldown = true, school = "Fire", id = 2120 }, 
	{ "Frost Armor", BUFF, p.Blue1, school = "Frost", id = 7302 }, 
	{ "Frost Bomb", DEBUFF, p.Blue2, cooldown = true, school = "Frost", id = 112948, refer = 125430 }, 
	{ "Frost Jaw", DEBUFF, p.Cyan, cooldown = true, school = "Frost", id = 102051 }, 
	{ "Frost Nova", DEBUFF, p.Blue2, cooldown = true, school = "Frost", id = 122 }, 
	{ "Frostbolt", DEBUFF, p.Purple3, school = "Frost", lockout = true, id = 116 }, 
	{ "Frostfire Bolt", DEBUFF, p.Yellow3, school = "Frost", id = 44614 }, 
	{ "Frozen Orb", nil, p.Blue3, cooldown = true, school = "Frost", id = 84714 }, 
	{ "Greater Invisibility", BUFF, p.Blue3, cooldown = true, school = "Arcane", id = 110959 }, 
	{ "Ice Barrier", BUFF, p.Green3, cooldown = true, school = "Frost", id = 11426 }, 
	{ "Ice Block", BUFF, p.Blue2, cooldown = true, school = "Frost", id = 45438 }, 
	{ "Ice Floes", BUFF, p.Blue3, cooldown = true, school = "Frost", id = 108839 }, 
	{ "Ice Lance", nil, p.Blue2, lockout = true, school = "Frost", id = 30455 }, 
	{ "Ice Ward", BUFF, p.Purple3, cooldown = true, school = "Frost", id = 111264 }, 
	{ "Icy Veins", BUFF, p.Blue1, cooldown = true, school = "Frost", id = 12472 }, 
	{ "Ignite", DEBUFF, p.Red2, id = 12654 }, 
	{ "Illusion", BUFF, p.Gray, cooldown = true, id = 131784 }, 
	{ "Incanter's Ward", BUFF, p.Green3, cooldown = true, school = "Frost", id = 1463 }, 
	{ "Inferno Blast", nil, p.Red3, cooldown = true, school = "Fire", id = 108853 }, 
	{ "Invisibility", BUFF, p.Blue3, cooldown = true, school = "Arcane", id = 66 }, 
	{ "Invocation", BUFF, p.Purple3, id = 114003 }, 
	{ "Invoker's Energy", BUFF, p.Purple2, school = "Physical", id = 116257 }, 
	{ "Living Bomb", DEBUFF, p.Red3, school = "Fire", id = 44457 }, 
	{ "Mage Armor", BUFF, p.Blue1, school = "Arcane", id = 6117 }, 
	{ "Mana Attunement", BUFF, p.Blue2, id = 121039 }, 
	{ "Mastery: Frostburn", BUFF, p.Cyan, id = 76613 }, 
	{ "Mastery: Ignite", BUFF, p.Orange3, id = 12846 }, 
	{ "Mastery: Mana Adept", BUFF, p.Blue1, id = 76547 }, 
	{ "Mirror Image", BUFF, p.Blue1, cooldown = true, school = "Arcane", id = 55342 }, 
	{ "Molten Armor", BUFF, p.Orange2, school = "Fire", lockout = true, id = 30482 }, 
	{ "Mote of Flame", BUFF, p.Red1, school = "Fire", id = 67713 }, 
	{ "Nether Attunement", BUFF, p.Blue2, id = 117957 }, 
	{ "Nether Tempest", DEBUFF, p.Purple3, school = "Arcane", id = 114954 }, 
	{ "Polymorph", DEBUFF, p.Gray, school = "Arcane", id = 118 }, 
	{ "Portal: Dalaran", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 53142 }, 
	{ "Portal: Darnassus", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 11419 }, 
	{ "Portal: Exodar", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 32266 }, 
	{ "Portal: Ironforge", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 11416 }, 
	{ "Portal: Orgrimmar", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 11417 }, 
	{ "Portal: Shattrath", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 35717 }, 
	{ "Portal: Silvermoon", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 32267 }, 
	{ "Portal: Stonard", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 49361 }, 
	{ "Portal: Stormwind", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 10059 }, 
	{ "Portal: Theramore", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 49360 }, 
	{ "Portal: Thunder Bluff", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 11420 }, 
	{ "Portal: Tol Barad", nil, p.Blue1, cooldown = true, school = "Arcane", id = 88345 }, 
	{ "Portal: Undercity", nil, p.Blue1, cooldown = true, shared = L["Portals"], school = "Arcane", id = 11418 }, 
	{ "Presence of Mind", BUFF, p.Gray, cooldown = true, school = "Arcane", id = 12043 }, 
	{ "Pyroblast", DEBUFF, p.Orange2, school = "Fire", id = 11366 }, 
	{ "Pyromaniac", DEBUFF, p.Orange3, school = "Fire", id = 132209 }, 
	{ "Remove Curse", nil, p.Purple2, cooldown = true, school = "Arcane", id = 475 }, 
	{ "Ring of Frost", DEBUFF, p.Blue2, cooldown = true, school = "Frost", id = 113724 }, 
	{ "Rune of Power", BUFF, p.Blue2, cooldown = true, school = "Arcane", id = 116011 }, 
	{ "Silenced - Improved Counterspell", DEBUFF, p.Purple2, id = 55021 }, 
	{ "Slow", DEBUFF, p.Orange3, school = "Arcane", id = 31589 }, 
	{ "Slow Fall", BUFF, p.Pink, id = 130 }, 
	{ "Summon Water Elemental", nil, p.Green2, cooldown = true, school = "Frost", id = 31687 }, 
	{ "Temporal Shield", BUFF, p.Purple2, cooldown = true, school = "Arcane", id = 115610 }, 
	{ "Time Warp", BUFF, p.Purple1, cooldown = true, school = "Arcane", id = 80353 }, 
}

Raven.classConditions.MAGE = {
	["Armor Missing"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 30482 }, -- "Molten Armor"
			["Any Buffs"] = { enable = true, toggle = true, isMine = true, unit = "player",
				auras = { 7302, 6117, 30482 }, }, -- "Frost Armor", "Mage Armor", "Molten Armor"
		},	
		associatedSpell = 7302, -- "Frost Armor"
	},
	["Brilliance Buff Missing"] = {	
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 1459 }, -- "Arcane Brilliance"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 1459, 61316 }, }, -- "Arcane Brilliance", "Dalaran Brilliance",
		},	
		associatedSpell = 1459, -- "Arcane Brilliance"
	},
	["Remove Curse"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 475 }, -- "Remove Curse"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Curse", },
		},	
		associatedSpell = 475, -- "Remove Curse"
	},
}
