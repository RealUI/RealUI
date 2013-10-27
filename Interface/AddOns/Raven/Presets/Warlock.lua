-- Warlock

local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local BUFF = true
local DEBUFF = false
local p = Raven.ColorPalette

Raven.classSpells.WARLOCK = {
	{ "Aftermath", DEBUFF, p.Orange1, id = 109784 },
	{ "Agony", DEBUFF, p.Orange1, school = "Shadow", id = 980 },
	{ "Archimonde's Darkness", DEBUFF, p.Orange1, cooldown = true, school = "Shadow", id = 108505 }, -- renamed in 5.4
	{ "Aura of Enfeeblement", BUFF, p.Orange1, school = "Shadow", id = 116198 },
	{ "Aura of the Elements", BUFF, p.Orange1, school = "Shadow", id = 116202 },
	{ "Backdraft", BUFF, p.Yellow1, id = 117896 },
	{ "Backlash", BUFF, p.Orange3, school = "Fire", id = 108563  },
	{ "Banish", DEBUFF, p.Blue2, school = "Shadow", id = 710 },
	{ "Blood Horror", BUFF, p.Red1, cooldown = true, id = 111397 },
	{ "Burning Embers", BUFF, p.Red2, id = 108647 },
	{ "Burning Rush", BUFF, p.Red2, id = 111400 },
	{ "Carrion Swarm", nil, p.Green3, cooldown = true, school = "Shadow", id = 103967 },
	{ "Chaos Wave", DEBUFF, p.Blue3, school = "Shadow", id = 124916 },
	{ "Conflagrate", DEBUFF, p.Yellow2, cooldown = true, school = "Fire", id = 17962 }, -- recharge
	{ "Corruption", DEBUFF, p.Red3, school = "Shadow", id = 131740 },
	{ "Create Soulwell", nil, p.Purple1, cooldown = true, school = "Shadow", id = 29893 },
	{ "Curse of Enfeeblement", DEBUFF, p.Green3, school = "Shadow", id = 109466 },
	{ "Curse of Exhaustion", DEBUFF, p.Gray, school = "Shadow", id = 18223 },
	{ "Curse of the Elements", DEBUFF, p.Purple1, school = "Shadow", id = 1490 },
	{ "Dark Apotheosis", BUFF, p.Purple3, cooldown = true, id = 114168 },
	{ "Dark Bargain", BUFF, p.Purple3, cooldown = true, id = 110913 },
	{ "Dark Intent", BUFF, p.Purple3, school = "Shadow", id = 109773 }, 
	{ "Dark Regeneration", BUFF, p.Green3, cooldown = true, school = "Shadow", id = 108359 },
	{ "Dark Soul", nil, p.Orange3, cooldown = true, school = "Shadow", id = 77801 },
	{ "Dark Soul: Instability", BUFF, p.Orange3, cooldown = true, school = "Fire", refer = 77801, id = 113858  },
	{ "Dark Soul: Knowledge", BUFF, p.Orange3, cooldown = true, school = "Shadow", refer = 77801, id = 113861  },
	{ "Dark Soul: Misery", BUFF, p.Orange3, cooldown = true, school = "Shadow", refer = 77801, id = 113860  },
	{ "Demonic Breath", DEBUFF, p.Pink, cooldown = true, school = "Shadow", id = 47897 }, -- new in 5.4
	{ "Demonic Calling", BUFF, p.Green3, school = "Shadow", id = 114925 },
	{ "Demonic Circle: Summon", BUFF, p.Green3, school = "Shadow", id = 48018 },
	{ "Demonic Circle: Teleport", nil, p.Green3, cooldown = true, school = "Shadow", id = 48020 },
	{ "Demonic Fury", BUFF, p.Purple2, id = 104315 },
	{ "Demonic Gateway", DEBUFF, p.Green1, cooldown = true, school = "Shadow", id = 111771 },
	{ "Demonic Leap", nil, p.Green3, cooldown = true, school = "Shadow", id = 109151 },
	{ "Demonic Rebirth", BUFF, p.Red3, id = 108559 },
	{ "Disrupted Nether", DEBUFF, p.Purple1, school = "Shadow", id = 114736 },
	{ "Doom", DEBUFF, p.Green3, school = "Shadow", id = 603 },
	{ "Drain Life", DEBUFF, p.Green1, school = "Shadow", id = 689 },
	{ "Drain Soul", DEBUFF, p.Blue3, school = "Shadow", id = 1120 },
	{ "Dreadsteed", BUFF, p.Brown2, id = 23161 },
	{ "Enslave Demon", DEBUFF, p.Cyan, school = "Shadow", id = 1098 },
	{ "Eye of Kilrogg", BUFF, p.Brown1, school = "Shadow", id = 126 },
	{ "Fear", DEBUFF, p.Gray, school = "Shadow", id = 5782 }, -- glyph no longer causes a cooldown in 5.4
	{ "Fel Armor", BUFF, p.Green1, id = 104938 },
	{ "Felsteed", BUFF, p.Brown2, id = 5784 },
	{ "Fire and Brimstone", BUFF, p.Orange1, cooldown = true, school = "Fire", id = 108683 },
	{ "Flames of Xoroth", BUFF, p.Pink, cooldown = true, school = "Fire", id = 120451 },
	{ "Grimoire of Sacrifice", BUFF, p.Red1, cooldown = true, school = "Shadow", id = 108503 },
	{ "Grimoire of Service", nil, p.Orange1, cooldown = true, id = 108501 },
	{ "Hand of Gul'dan", nil, p.Purple1, cooldown = true, school = "Shadow", id = 105174 }, -- recharge
	{ "Harvest Life", DEBUFF, p.Purple3, school = "Shadow", id = 108371 },
	{ "Haunt", DEBUFF, p.Purple3, school = "Shadow", id = 48181 },
	{ "Havoc", DEBUFF, p.Purple1, cooldown = true, school = "Shadow", id = 80240 },
	{ "Health Funnel", BUFF, p.Red2, school = "Shadow", id = 755 },
	{ "Hellfire", DEBUFF, p.Orange1, school = "Fire", id = 1949 },
	{ "Howl of Terror", DEBUFF, p.Purple1, cooldown = true, school = "Shadow", id = 5484 }, -- becomes baseline in 5.4
	{ "Immolate", DEBUFF, p.Orange2, school = "Fire", id = 348 },
	{ "Imp Swarm", nil, p.Orange3, id = 104316 },
	{ "Incinerate", nil, p.Orange3, lockout = true, school = "Fire", id = 29722 },
	{ "Kil'jaeden's Cunning", BUFF, p.Purple1, cooldown = true, school = "Shadow", id = 119049 },
	{ "Life Tap", DEBUFF, p.Green1, school = "Shadow", id = 1454 },
	{ "Malefic Grasp", DEBUFF, p.Orange1, school = "Shadow", id = 103103 }, 
	{ "Mannoroth's Fury", BUFF, p.Green3, cooldown = true, school = "Physical", id = 108508 }, -- new in 5.4
	{ "Master Demonologist", BUFF, p.Purple3, id = 115556 },
	{ "Metamorphosis", BUFF, p.Purple1, cooldown = true, id = 103958 },
	{ "Molten Core", BUFF, p.Orange1, school = "Fire", id = 122351 },
	{ "Mortal Coil", DEBUFF, p.Green1, cooldown = true, school = "Shadow", id = 6789 },
	{ "Nightmare", DEBUFF, p.Purple1, school = "Shadow", id = 60947 }, -- from Improved Fear talent
	{ "Rain of Fire", DEBUFF, p.Red2, school = "Fire", id = 5740},
	{ "Ritual of Summoning", nil, p.Purple3, cooldown = true, school = "Shadow", id = 698 },
	{ "Sacrificial Pact", BUFF, p.Brown2, cooldown = true, id = 108416 },
	{ "Seed of Corruption", DEBUFF, p.Purple2, school = "Shadow", id = 27243 },
	{ "Shadow Bolt", nil, p.Purple3, school = "Shadow", lockout = true, id = 686 },
	{ "Shadowburn", DEBUFF, p.Gray, cooldown = true, school = "Shadow", id = 17877 },
	{ "Shadowflame", DEBUFF, p.Purple3, school = "Shadow", id = 47960 },
	{ "Shadowfury", DEBUFF, p.Purple2, cooldown = true, school = "Shadow", id = 30283 },
	{ "Soul Fire", nil, p.Red2, school = "Fire", lockout = true, id = 6353 },
	{ "Soul Harvest", BUFF, p.Purple3, school = "Shadow", id = 101976 },
	{ "Soul Link", BUFF, p.Gray, cooldown = true, school = "Shadow", id = 108415 },
	{ "Soul Shards", BUFF, p.Purple1, id = 117198 },
	{ "Soul Swap", BUFF, p.Pink, cooldown = true, school = "Shadow", id = 86121 },
	{ "Soulburn", nil, p.Purple1, cooldown = true, school = "Shadow", id = 74434 },
	{ "Soulshatter", nil, p.Cyan, cooldown = true, school = "Shadow", id = 29858 },
	{ "Soulstone", BUFF, p.Red3, cooldown = true, id = 20707 },
	{ "Summon Infernal", nil, p.Green3, cooldown = true, shared = L["Summon Infernal/Doomguard"], school = "Shadow", id = 1122 },
	{ "Summon Doomguard", nil, p.Red3, cooldown = true, shared = L["Summon Infernal/Doomguard"], school = "Shadow", id = 18540 },
	{ "Twilight Ward", BUFF, p.Brown2, cooldown = true, school = "Shadow", id = 6229 },
	{ "Unbound Will", nil, p.Brown2, cooldown = true, id = 108482 },
	{ "Unending Breath", BUFF, p.Blue1, school = "Shadow", id = 5697 },
	{ "Unending Resolve", BUFF, p.Red3, cooldown = true, school = "Shadow", id = 104773 },
	{ "Unstable Affliction", DEBUFF, p.Orange2, school = "Shadow", id = 131736 },
}

Raven.classConditions.WARLOCK = {
	["No Pet!"] = {
		tests = {
			["Player Status"] = { enable = true, inCombat = true, hasPet = false },
		},	
	},
}
