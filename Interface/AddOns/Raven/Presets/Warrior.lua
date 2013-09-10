-- Warrior

local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local BUFF = true
local DEBUFF = false
local p = Raven.ColorPalette

Raven.classSpells.WARRIOR = {
	{ "Avatar", BUFF, p.Green3, cooldown = true, id = 107574 },
	{ "Battle Shout", BUFF, p.Yellow3, cooldown = true, shared = L["Shouts"], id = 6673 },
	{ "Battle Stance", BUFF, p.Red3, cooldown = true, shared = L["Stances"], id = 2457 },
	{ "Berserker Rage", BUFF, p.Orange2, cooldown = true, id = 18499 },
	{ "Berserker Stance", BUFF, p.Cyan, cooldown = true, shared = L["Stances"], id = 2458 },
	{ "Bladestorm", BUFF, p.Orange3, cooldown = true, id = 46924 },
	{ "Bloodbath", BUFF, p.Red3, cooldown = true, id = 12292 },
	{ "Bloodsurge", BUFF, p.Green3, id = 46915 },
	{ "Bloodthirst", nil, p.Red2, cooldown = true, id = 23881 },
	{ "Charge", nil, p.Red1, cooldown = true, id = 100 },
	{ "Charge Stun", DEBUFF, p.Cyan, id = 7922 },
	{ "Cleave", DEBUFF, p.Green2, cooldown = true, id = 845 },
	{ "Colossus Smash", DEBUFF, p.Brown3, cooldown = true, id = 86346 },
	{ "Commanding Shout", BUFF, p.Orange3, cooldown = true, shared = L["Shouts"], id = 469 },
--	{ "Deadly Calm", BUFF, p.Brown1, cooldown = true, id = 85730 }, -- removed in 5.2
	{ "Deep Wounds", DEBUFF, p.Red1, id = 115768 },
	{ "Defensive Stance", BUFF, p.Gray, cooldown = true, shared = L["Stances"], id = 71 },
	{ "Demoralizing Banner", DEBUFF, p.Green1, cooldown = true, id = 114203 },
	{ "Demoralizing Shout", DEBUFF, p.Green3, cooldown = true, id = 1160 },
	{ "Devastate", DEBUFF, p.Orange3, id = 20243 },
	{ "Die by the Sword", BUFF, p.Orange2, cooldown = true, id = 118038 },
	{ "Disarm", DEBUFF, p.Brown2, cooldown = true, id = 676 },
	{ "Disrupting Shout", DEBUFF, p.Yellow3, cooldown = true, id = 102060 },
	{ "Double Time", BUFF, p.Orange2, id = 103827 },
	{ "Dragon Roar", DEBUFF, p.Orange3, cooldown = true, id = 118000 },
	{ "Enrage", BUFF, p.Purple3, id = 13046 },
	{ "Enraged Regeneration", BUFF, p.Red3, cooldown = true, id = 55694 },
	{ "Flurry", BUFF, p.Red2, id = 12972 },
	{ "Hamstring", DEBUFF, p.Yellow2, id = 1715 },
	{ "Heroic Leap", nil, p.Red3, cooldown = true, id = 6544 },
	{ "Heroic Strike", nil, p.Orange2, cooldown = true, id = 78 },
	{ "Heroic Throw", nil, p.Purple3, cooldown = true, id = 57755 },
	{ "Impending Victory", nil, p.Purple3, cooldown = true, id = 103840 },
	{ "Incite", BUFF, p.Brown2, id = 122016 },
	{ "Intervene", BUFF, p.Yellow1, cooldown = true, id = 3411 },
	{ "Intimidating Shout", DEBUFF, p.Purple2, cooldown = true, id = 5246 },
	{ "Juggernaut", BUFF, p.Brown3, id = 103826 },
	{ "Last Stand", BUFF, p.Brown1, cooldown = true, id = 12975 },
	{ "Mass Spell Reflection", BUFF, p.Gray, cooldown = true, id = 114028 },
	{ "Mastery: Critical Block", BUFF, p.Yellow1, id = 76857 },
	{ "Mastery: Strikes of Opportunity", BUFF, p.Red3, id = 76838 },
	{ "Mastery: Unshackled Fury", BUFF, p.Red2, id = 76856 },
	{ "Meat Cleaver", BUFF, p.Brown3, id = 12950 },
	{ "Mocking Banner", BUFF, p.Purple1, cooldown = true, id = 114192 },
	{ "Mortal Strike", BUFF, p.Blue3, cooldown = true, id = 12294 },
	{ "Mortal Wounds", DEBUFF, p.Red3, id = 115804 },
	{ "Overpower", nil, p.Yellow3, id = 7384 },
	{ "Piercing Howl", DEBUFF, p.Brown3, id = 12323 },
	{ "Pummel", DEBUFF, p.Brown2, cooldown = true, id = 6552 },
	{ "Raging Blow", nil, p.Red1, id = 85288 },
	{ "Raging Blow!", BUFF, p.Red2, id = 131116 },
	{ "Rallying Cry", BUFF, p.Blue3, cooldown = true, id = 97462 },
	{ "Recklessness", BUFF, p.Red2, cooldown = true, id = 1719 },
	{ "Revenge", nil, p.Brown3, cooldown = true, id = 6572 },
	{ "Rude Interruption", BUFF, p.Red2, id = 86662 },
	{ "Safeguard", BUFF, p.Yellow2, id = 114029 },
	{ "Second Wind", BUFF, p.Pink, id = 29838 },
	{ "Shattering Throw", DEBUFF, p.Green2, cooldown = true, id = 64382 },
	{ "Shield Barrier", BUFF, p.Purple1, cooldown = true, id = 112048 },
	{ "Shield Block", BUFF, p.Blue3, cooldown = true, id = 2565 },
	{ "Shield Slam", nil, p.Yellow3, cooldown = true, id = 23922 },
	{ "Shield Wall", BUFF, p.Purple3, cooldown = true, id = 871 },
	{ "Shockwave", DEBUFF, p.Cyan, cooldown = true, id = 46968 },
	{ "Silenced - Gag Order", DEBUFF, p.Brown2, id = 18498 },
	{ "Skull Banner", BUFF, p.Red2, cooldown = true, id = 114207 },
	{ "Spell Reflection", BUFF, p.Gray, cooldown = true, id = 23920 },
	{ "Staggering Shout", DEBUFF, p.Brown1, cooldown = true, id = 107566 },
	{ "Storm Bolt", DEBUFF, p.Green2, cooldown = true, id = 107570 },
	{ "Sudden Execute", BUFF, p.Yellow3, id = 139958 },
	{ "Sunder Armor", DEBUFF, p.Brown1, id = 7386 },
	{ "Sweeping Strikes", BUFF, p.Orange3, cooldown = true, id = 12328 },
	{ "Sword and Board", BUFF, p.Yellow3, id = 46953 },
	{ "Taste for Blood", BUFF, p.Orange3, id = 56638 },
	{ "Taunt", DEBUFF, p.Orange1, cooldown = true, id = 355 },
	{ "Thunder Clap", DEBUFF, p.Green3, cooldown = true, id = 6343 },
	{ "Ultimatum", BUFF, p.Blue1, id = 122509 },
	{ "Vengeance", BUFF, p.Purple2, id = 93098 },
	{ "Victorious", BUFF, p.Orange2, id = 32216 },
	{ "Vigilance", BUFF, p.Purple3, cooldown = true, id = 114030 },
	{ "Warbringer", DEBUFF, p.Orange1, id = 103828 },
	{ "Weakened Armor", DEBUFF, p.Brown1, id = 113746 },
	{ "Whirlwind", nil, p.Blue2, id = 1680 },
	{ "Wild Strike", DEBUFF, p.Red3, id = 100130 },
}

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
