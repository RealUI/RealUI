-- Paladin

local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local BUFF = true
local DEBUFF = false
local p = Raven.ColorPalette

Raven.classSpells.PALADIN = {
	{ "Ancient Crusader", BUFF, p.Purple3, id = 86701 }, -- Guardian of Ancient Kings 
	{ "Ancient Guardian", BUFF, p.Brown3, id = 86657 }, -- Guardian of Ancient Kings 
	{ "Ancient Healer", BUFF, p.Orange3, id = 86674 }, -- Guardian of Ancient Kings 
	{ "Ancient Power", BUFF, p.Brown3, id = 86700 }, -- Guardian of Ancient Kings 
	{ "Arcing Light", BUFF, p.Brown3, id = 119952 }, 
	{ "Ardent Defender", BUFF, p.Brown2, cooldown = true, id = 31850 },
	{ "Avenger's Shield", DEBUFF, p.Orange2, cooldown = true, school = "Holy", id = 31935 },
	{ "Avenging Wrath", BUFF, p.Yellow1, cooldown = true, school = "Holy", id = 31884 },
	{ "Bastion of Glory", BUFF, p.Purple3, id = 114637 },
	{ "Beacon of Light", BUFF, p.Yellow1, cooldown = true, school = "Holy", id = 53563 },
	{ "Blessing of Kings", BUFF, p.Blue1, school = "Holy", id = 20217 },
	{ "Blessing of Might", BUFF, p.Blue1, school = "Holy", id = 19740 },
	{ "Blinding Light", DEBUFF, p.Yellow1, cooldown = true, school = "Holy", id = 115750 },
	{ "Burden of Guilt", BUFF, p.Blue3, id = 110301 },
	{ "Cleanse", nil, p.Yellow1, cooldown = true, school = "Holy", id = 4987 },
	{ "Censure", DEBUFF, p.Yellow3, school = "Holy", id = 31803 },
	{ "Consecration", DEBUFF, p.Yellow1, cooldown = true, school = "Holy", id = 26573 },
	{ "Contemplation", BUFF, p.Green3, cooldown = true, school = "Holy", id = 121183 },
	{ "Crusader Strike", nil, p.Yellow2, cooldown = true, shared = L["Crusader/Hammer"], id = 35395 },
	{ "Daybreak", BUFF, p.Orange3, id = 88821 },
	{ "Denounce", DEBUFF, p.Orange2, id = 2812 },
	{ "Devotion Aura", BUFF, p.Blue1, cooldown = true, school = "Holy", id = 31821 },
	{ "Divine Favor", BUFF, p.Yellow2, cooldown = true, school = "Holy", id = 31842 },
	{ "Divine Guardian", BUFF, p.Yellow3, cooldown = true, school = "Holy", id = 70940 },
	{ "Divine Plea", BUFF, p.Yellow3, cooldown = true, school = "Holy", id = 54428 },
	{ "Divine Protection", BUFF, p.Yellow1, cooldown = true, school = "Holy", id = 498 },
	{ "Divine Purpose", BUFF, p.Orange3, id = 86172 },
	{ "Divine Shield", BUFF, p.Yellow1, cooldown = true, school = "Holy", id = 642 },
	{ "Divine Storm", nil, p.Yellow3, id = 53385 },
	{ "Eternal Flame", BUFF, p.Yellow3, school = "Holy", id = 114163 },
	{ "Execution Sentence", BUFF, p.Yellow2, cooldown = true, school = "Holy", id = 114916 },
	{ "Exorcism", nil, p.Orange2, cooldown = true, school = "Holy", id = 879 },
	{ "Fist of Justice", DEBUFF, p.Cyan, cooldown = true, school = "Holy", id = 105593 },
	{ "Flash of Light", nil, p.Yellow1, school = "Holy", lockout = true, id = 19750 },
	{ "Forbearance", DEBUFF, p.Brown3, id = 25771 }, 
	{ "Glyph of Flash of Light", BUFF, p.Gray, school = "Holy", id = 54957 },
	{ "Glyph of Word of Glory", BUFF, p.Gray, id = 54936 },
	{ "Grand Crusader", BUFF, p.Orange3, school = "Holy", id = 85043 },
	{ "Guarded by the Light", BUFF, p.Orange1, school = "Holy", id = 53592 },
	{ "Guardian of Ancient Kings", BUFF, p.Yellow2, cooldown = true, school = "Holy", id = 86698 },
	{ "Hammer of Justice", DEBUFF, p.Cyan, cooldown = true, school = "Holy", id = 853 },
	{ "Hammer of the Righteous", nil, p.Yellow1, cooldown = true, shared = L["Crusader/Hammer"], school = "Holy", id = 53595 },
	{ "Hammer of Wrath", nil, p.Green3, cooldown = true, school = "Holy", id = 24275 },
	{ "Hand of Freedom", BUFF, p.Green1, cooldown = true, school = "Holy", id = 1044 },
	{ "Hand of Light", BUFF, p.Yellow1, id = 96172 },
	{ "Hand of Protection", BUFF, p.Green1, cooldown = true, school = "Holy", id = 1022 },
	{ "Hand of Purity", BUFF, p.Brown3, cooldown = true, school = "Holy", id = 114039 },
	{ "Hand of Sacrifice", BUFF, p.Green1, cooldown = true, school = "Holy", id = 6940 },
	{ "Hand of Salvation", BUFF, p.Green1, cooldown = true, school = "Holy", id = 1038 },
	{ "Heart of the Crusader", BUFF, p.Yellow1, school = "Holy", id = 32223 },
	{ "Holy Avenger", BUFF, p.Yellow1, cooldown = true, school = "Holy", id = 105809 },
	{ "Holy Power", BUFF, p.Green3, school = "Holy", id = 85247 },
	{ "Holy Prism", nil, p.Yellow1, cooldown = true, school = "Holy", id = 114165 },
	{ "Holy Radiance", BUFF, p.Yellow3, school = "Holy", id = 82327 },
	{ "Holy Shield", BUFF, p.Yellow2, cooldown = true, school = "Holy", id = 20925 },
	{ "Holy Shock", nil, p.Yellow1, cooldown = true, school = "Holy", id = 20473 },
	{ "Holy Wrath", DEBUFF, p.Orange3, cooldown = true, school = "Holy", id = 119072 },
	{ "Illuminated Healing", BUFF, p.Blue3, id = 76669 },
	{ "Infusion of Light", BUFF, p.Yellow3, id = 53576 },
	{ "Inquisition", BUFF, p.Yellow1, school = "Holy", id = 84963 },
	{ "Judgement", nil, p.Orange3, cooldown = true, school = "Holy", id = 20271 },
	{ "Judgements of the Bold", BUFF, p.Cyan, id = 111529 },
	{ "Judgements of the Wise", BUFF, p.Cyan, id = 105424 },
	{ "Lay on Hands", nil, p.Gray, cooldown = true, school = "Holy", id = 633 },
	{ "Light of Dawn", nil, p.Yellow1, school = "Holy", id = 85222 },
	{ "Light of the Ancient Kings", BUFF, p.Yellow1, school = "Holy", id = 86678 },
	{ "Light's Beacon", BUFF, p.Yellow1, school = "Holy", id = 53651 },
	{ "Light's Hammer", nil, p.Yellow1, cooldown = true, id = 114158 },
	{ "Long Arm of the Law", BUFF, p.Orange3, id = 87172 },
	{ "Mastery: Divine Bulwark", BUFF, p.Yellow1, id = 76671 },
	{ "Mastery: Hand of Light", BUFF, p.Yellow3, id = 76672 },
	{ "Mastery: Illuminated Healing", BUFF, p.Yellow3, id = 76669 },
	{ "Pursuit of Justice", BUFF, p.Yellow1, school = "Holy", id = 26023 }, 
	{ "Rebuke", DEBUFF, p.Brown3, cooldown = true, id = 96231 },
	{ "Reckoning", DEBUFF, p.Orange3, cooldown = true, school = "Holy", id = 62124 },
	{ "Repentance", DEBUFF, p.Brown2, cooldown = true, school = "Holy", id = 20066 },
	{ "Righteous Fury", BUFF, p.Red3, cooldown = true, id = 25780 },
	{ "Sacred Shield", BUFF, p.Yellow2, cooldown = true, school = "Holy", id = 20925 },
	{ "Seal of Command", BUFF, p.Red3, school = "Holy", id = 105361 },
	{ "Seal of Insight", BUFF, p.Orange1, school = "Holy", id = 20165 },
	{ "Seal of Justice", BUFF, p.Orange2, school = "Holy", id = 20164 },
	{ "Seal of Righteousness", BUFF, p.Blue3, school = "Holy", id = 20154 },
	{ "Seal of Truth", BUFF, p.Yellow3, school = "Holy", id = 31801 },
	{ "Selfless Healer", BUFF, p.Yellow1, id = 85804 },
	{ "Shield of the Righteous", BUFF, p.Purple3, cooldown = true, school = "Holy", id = 53600 },
	{ "Speed of Light", BUFF, p.Orange1, id = 85499 },
	{ "Stay of Execution", BUFF, p.Yellow2, school = "Holy", id = 114917 },
	{ "Supplication", BUFF, p.Orange2, id = 31868 },
	{ "The Art of War", BUFF, p.Orange3, id = 87138 },
	{ "Turn Evil", DEBUFF, p.Brown3, school = "Holy", id = 10326 },
	{ "Unbreakable Spirit", BUFF, p.Brown3, id = 114154 },
	{ "Vengeance", BUFF, p.Brown2, id = 84839 },
	{ "Word of Glory", nil, p.Yellow3, cooldown = true, school = "Holy", id = 85673 },
}

Raven.classConditions.PALADIN = {
	["Cleanse (Poison)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 4987, }, -- "Cleanse"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Poison", },
		},	
		associatedSpell = 4987, -- "Cleanse"
	},
	["Cleanse (Disease)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 4987, }, -- "Cleanse"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Disease", },
		},	
		associatedSpell = 4987, -- "Cleanse"
	},
	["Cleanse (Magic)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 4987, }, -- "Cleanse"
			["All Cooldowns"] = { enable = true, spells = { 53551 }, notUsable = false,  timeLeft = 10, toggle = true }, -- "Sacred Cleansing"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Magic", },
		},	
		associatedSpell = 4987, -- "Cleanse"
	},
	["Blessing Missing"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false, },
			["Spell Ready"] = { enable = true, spell = 19740 }, -- "Blessing of Might"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 19740, 20217 }, }, -- "Blessing of Might", "Blessing of Kings"
		},	
	},
	["Seal Missing"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false, checkLevel = true, level = 3 },
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 105361, 20165, 20164, 20154, 31801 }, }, -- "Seal of Command", "Seal of Insight", "Seal of Righteousness", "Seal of Truth"
		},	
	},
}
