-- Priest

local BUFF = true
local DEBUFF = false
local p = Raven.ColorPalette

Raven.classSpells.PRIEST = {
	{ "Angelic Bulwark", BUFF, p.Yellow2, id = 108945 },
	{ "Angelic Feather", BUFF, p.Orange3, cooldown = true, school = "Holy", id = 121536 },
	{ "Archangel", BUFF, p.Yellow1, cooldown = true, school = "Holy", id = 81700 },
	{ "Blessed Healing", BUFF, p.Yellow3, school = "Holy", id = 70772 },
	{ "Body and Soul", BUFF, p.Green3, id = 64129 },
	{ "Borrowed Time", BUFF, p.Yellow3, id = 52798 },
	{ "Cascade", nil, p.Yellow3, cooldown = true, school = "Holy", id = 121135 },
	{ "Chakra: Serenity", BUFF, p.Purple3, cooldown = true, school = "Holy", id = 81208 },
	{ "Chakra: Sanctuary", BUFF, p.Yellow2, cooldown = true, school = "Holy", id = 81206 },
	{ "Chakra: Chastise", BUFF, p.Yellow3, cooldown = true, school = "Holy", id = 81209 },
	{ "Circle of Healing", nil, p.Yellow1, cooldown = true, school = "Holy", id = 34861 },
	{ "Confession", nil, p.Green2, cooldown = true, id = 126123 },
	{ "Desperate Prayer", nil, p.Orange1, cooldown = true, school = "Holy", id = 19236 },
	{ "Devouring Plague", DEBUFF, p.Purple3, school = "Shadow", id = 2944 },
	{ "Dispersion", BUFF, p.Purple1, cooldown = true, school = "Shadow", id = 47585 },
	{ "Divine Aegis", BUFF, p.Brown2, id = 47515 },
	{ "Divine Hymn", BUFF, p.Yellow2, cooldown = true, school = "Holy", id = 64843 },
	{ "Divine Insight", BUFF, p.Orange3, school = "Holy", id = 109175 },
	{ "Divine Star", BUFF, p.Yellow1, cooldown = true, school = "Holy", id = 110744 },
	{ "Dominate Mind", DEBUFF, p.Purple3, cooldown = true, school = "Shadow", id = 605 },
	{ "Evangelism", BUFF, p.Brown3, id = 81662 },
	{ "Fade", BUFF, p.Cyan, cooldown = true, school = "Shadow", id = 586 },
	{ "Fear Ward", BUFF, p.Orange2, cooldown = true, school = "Holy", id = 6346 },
	{ "Flash Heal", nil, p.Green1, school = "Holy", lockout = true, id = 2061 },
	{ "Grace", BUFF, p.Blue3, id = 47517 },
	{ "Guardian Spirit", BUFF, p.Blue2, cooldown = true, school = "Holy", id = 47788 },
	{ "Glyph of Mind Blast", DEBUFF, p.Orange3, id = 87195 },
	{ "Glyph of Mind Spike", BUFF, p.Purple3, school = "Shadow", id = 33371 },
	{ "Halo", BUFF, p.Yellow3, cooldown = true, school = "Holy", id = 120517 },
	{ "Holy Fire", DEBUFF, p.Yellow2, cooldown = true, school = "Holy", id = 14914 },
	{ "Holy Word: Chastise", DEBUFF, p.Brown2, cooldown = true, school = "Holy", id = 88625 },
	{ "Holy Word: Sanctuary", BUFF, p.Brown2, cooldown = true, school = "Holy", id = 88686, refer = 88625 },
	{ "Holy Word: Serenity", BUFF, p.Brown2, cooldown = true, school = "Holy", id = 88684, refer = 88625 },
	{ "Hymn of Hope", BUFF, p.Gray, cooldown = true, school = "Holy", id = 64901 },
	{ "Inner Fire", BUFF, p.Orange1, school = "Holy", id = 588 },
	{ "Inner Focus", BUFF, p.Gray, cooldown = true, id = 89485 },
	{ "Inner Will", BUFF, p.Cyan, school = "Holy", id = 73413 }, -- Cataclysm level 83
	{ "Leap of Faith", nil, p.Blue3, cooldown = true, school = "Holy", id = 73325 }, -- Cataclysm level 85
	{ "Levitate", BUFF, p.Gray, school = "Holy", id = 1706 },
	{ "Lightwell", nil, p.Yellow3, cooldown = true, school = "Holy", id = 724 },
	{ "Mass Dispel", nil, p.Purple3, cooldown = true, school = "Holy", id = 32375 },
	{ "Mastery: Echo of Light", BUFF, p.Yellow1, id = 77485 },
	{ "Mastery: Shadowy Recall", BUFF, p.Yellow1, id = 77486 },
	{ "Mastery: Shield Discipline", BUFF, p.Yellow1, id = 77484 },
	{ "Mind Blast", nil, p.Yellow2, cooldown = true, school = "Shadow", id = 8092 },
	{ "Mind Flay", DEBUFF, p.Orange2, school = "Shadow", id = 15407 },
	{ "Mind Sear", DEBUFF, p.Purple3, school = "Shadow", id = 48045 },
	{ "Mind Spike", DEBUFF, p.Purple1, school = "Shadow", id = 73510 }, -- Cataclysm level 81
	{ "Mind Vision", BUFF, p.Yellow3, id = 2096 },
	{ "Mindbender", BUFF, p.Purple3, cooldown = true, school = "Shadow", id = 123040 },
	{ "Pain Suppression", BUFF, p.Gray, cooldown = true, school = "Holy", id = 33206 },
	{ "Penance", BUFF, p.Green3, cooldown = true, school = "Holy", id = 47540 },
	{ "Phantasm", BUFF, p.Brown2, id = 108942},
	{ "Power Infusion", BUFF, p.Yellow1, cooldown = true, school = "Holy", id = 10060 },
	{ "Power Word: Barrier", BUFF, p.Yellow3, cooldown = true, school = "Holy", id = 62618 },
	{ "Power Word: Shield", BUFF, p.Yellow3, cooldown = true, school = "Holy", id = 17 },
	{ "Power Word: Solace", DEBUFF, p.Yellow2, cooldown = true, school = "Holy", id = 129250 },
	{ "Power Word: Fortitude", BUFF, p.Cyan, id = 21562 },
	{ "Prayer of Mending", BUFF, p.Yellow2, cooldown = true, school = "Holy", id = 33076 },
	{ "Psychic Horror", DEBUFF, p.Purple3, cooldown = true, school = "Shadow", id = 64044 },
	{ "Psychic Scream", DEBUFF, p.Blue3, cooldown = true, school = "Shadow", id = 8122 },
	{ "Psyfiend", BUFF, p.Purple2, cooldown = true, school = "Shadow", id = 108921 },
	{ "Purify", nil, p.Purple3, cooldown = true, school = "Holy", id = 527 },
	{ "Renew", BUFF, p.Green2, id = 139 },
	{ "Serendipity", BUFF, p.Blue1, id = 63733 },
	{ "Shackle Undead", DEBUFF, p.Orange2, id = 9484 },
	{ "Shadowform", BUFF, p.Purple3, cooldown = true, school = "Shadow", id = 15473 },
	{ "Shadow Orbs", BUFF, p.Purple1, school = "Shadow", id = 95740 },
	{ "Shadow Word: Death", nil, p.Red2, cooldown = true, school = "Shadow", id = 32379 },
	{ "Shadow Word: Pain", DEBUFF, p.Red3, school = "Shadow", lockout = true, id = 589 },
	{ "Shadowy Apparition", BUFF, p.Purple3, id = 87426 },
	{ "Shadowfiend", BUFF, p.Purple2, cooldown = true, school = "Shadow", id = 34433 },
	{ "Silence", DEBUFF, p.Purple1, cooldown = true, school = "Shadow", id = 15487 },
--	{ "Smite", nil, p.Green1, school = "Holy", lockout = true, id = 585 }, -- replace with Flash Heal
	{ "Spectral Guise", BUFF, p.Cyan, cooldown = true, id = 112833 },
	{ "Spirit of Redemption", BUFF, p.Gray, id = 20711 },
	{ "Spirit Shell", BUFF, p.Yellow2, cooldown = true, school = "Holy", id = 109964 },
	{ "Strength of Soul", BUFF, p.Orange2, id = 89488 },
	{ "Surge of Darkness", BUFF, p.Purple3, id = 126083 },
	{ "Surge of Light", BUFF, p.Orange3, id = 128654 },
	{ "Twist of Fate", BUFF, p.Purple3, id = 109142 },
	{ "Vampiric Embrace", BUFF, p.Blue2, cooldown = true, school = "Shadow", id = 15286 },
	{ "Vampiric Touch", DEBUFF, p.Purple3, id = 34914 },
	{ "Void Tendrils", BUFF, p.Purple1, cooldown = true, school = "Shadow", id = 108920 },
	{ "Void Shift", nil, p.Purple1, cooldown = true, school = "Shadow", id = 108968 },
	{ "Weakened Soul", DEBUFF, p.Orange3, id = 6788 },
}

Raven.classConditions.PRIEST = {
	["Fortitude Missing"] = { -- "Commanding Shout", "Power Word: Fortitude", "Blood Pact", "Qiraji Fortitude"
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Spell Ready"] = { enable = true, spell = 21562, }, -- "Power Word: Fortitude"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player",
				auras = { 469, 21562, 109773, 90364 }, }, -- replace blood pact with dark intent in 5.2
		},
		associatedSpell = 21562, -- "Power Word: Fortitude"
	},
	["Vampiric Embrace!"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["All Buffs"] = { enable = true, unit = "player", auras = { 15473 }, }, -- "Shadowform"
			["Any Buffs"] = { enable = true, toggle = true, unit = "player", auras = { 15286 }, }, -- "Vampiric Embrace"
			["Spell Ready"] = { enable = true, spell = 15286, }, -- "Vampiric Embrace"
		},	
		associatedSpell = 15286, -- "Vampiric Embrace"
	},
	["Inner Fire!"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Any Buffs"] = { enable = true, toggle = true, unit = "player", auras = { 588, 73413 }, }, -- "Inner Fire" or "Inner Will"
			["Spell Ready"] = { enable = true, spell = 588, }, -- "Inner Fire"
		},	
		associatedSpell = 588, -- "Inner Fire"
	},
	["Chakra!"] = {
		tests = {
			["Player Status"] = { enable = true, isResting = false, isMounted = false },
			["Any Buffs"] = { enable = true, toggle = true, unit = "player", auras = { 81206, 81208, 81209 }, }, -- "Sanctuary" or "Serenity" or "Chastise"
			["Spell Ready"] = { enable = true, spell = 81206, }, -- "Chakra: Sanctuary"
		},	
		associatedSpell = 81206, -- "Chakra"
	},
	["Purify (Disease)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 527, }, -- "Purify"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Disease", },
		},	
		associatedSpell = 527, -- "Purify"
	},
	["Purify (Magic)"] = {	
		tests = {
			["Spell Ready"] = { enable = true, spell = 527, }, -- "Nature's Cure"
			["Debuff Type"] = { enable = true, unit = "player", hasDebuff = "Magic", },
		},	
		associatedSpell = 527, -- "Purify"
	},
}
