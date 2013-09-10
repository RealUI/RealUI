-- General purpose spells and items, including internal cooldowns

local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local BUFF = true
local DEBUFF = false
local p = Raven.ColorPalette

Raven.generalSpells = {
	{ "Replenishment", BUFF, p.Blue1, id = 57669 },
	{ "Sated", DEBUFF, p.Brown3, id = 57724 },
	{ "Chilled", DEBUFF, p.Blue3, id = 7321 },
	{ "Enraged", BUFF, p.Red1, id = 71216 },
	{ "Dazed", DEBUFF, p.Cyan, id = 15571 },
	{ "Disoriented", DEBUFF, p.Gray, id = 115226 },
	{ "Thunderclap", DEBUFF, p.Blue3, id = 8147 },
	{ "Weakened Blows", DEBUFF, p.Gray, id = 115798 },
	{ "Ghost", DEBUFF, p.Gray, id = 9036 },
	{ "Basic Campfire", nil, p.Orange2, cooldown = true, id = 818, profession = "Cooking" },
	{ "Survey", nil, p.Grey, cooldown = true, id = 80451, profession = "Archaeology" },
	{ "Lifeblood", BUFF, p.Green2, cooldown = true, profession = "Herbalism", id = 74497 },
	-- the following cooldowns are internally generated and should not have spell ids
	{ L["GCD"], nil, p.Gray, cooldown = true },
	{ L["Potions"], nil, p.Green1, cooldown = true },
	{ L["Elixirs"], nil, p.Pink, cooldown = true },
	{ L["Frost School"], nil, p.Blue1, cooldown = true },
	{ L["Fire School"], nil, p.Red1, cooldown = true },
	{ L["Nature School"], nil, p.Green1, cooldown = true },
	{ L["Shadow School"], nil, p.Purple1, cooldown = true },
	{ L["Arcane School"], nil, p.Orange1, cooldown = true },
	{ L["Holy School"], nil, p.Yellow1, cooldown = true },
	{ L["Physical School"], nil, p.Brown1, cooldown = true },
}

Raven.spellEffects = {
--	{ id = 18562, duration = 7, spell = 81275, talent = 81275 }, -- Swiftmend causes Efflorescence
--	{ id = 33831, duration = 30, talent = 33831 }, -- Force of Nature
--	{ id = 88685, duration = 18, talent = 88627 }, -- Holy Word: Sanctuary
	{ id = 73920, duration = 10 }, -- Healing Rain
	{ id = 99061, duration = 15 }, -- Mage 2-piece T12 bonus
}

Raven.internalCooldowns = {
	-- Spell internal cooldowns
	{ id = 81164, duration = 45, class = "DEATHKNIGHT" }, -- Will of the Necropolis
	{ id = 122464, duration = 10, class = "MONK" }, -- Dematerialize
	{ id = 47536, duration = 12, class = "PRIEST" }, -- Rapture

	-- Enchant internal cooldowns
	{ id = 74245, duration = 45, }, -- Landslide
	{ id = 74241, duration = 45, }, -- Power Torrent
	{ id = 74221, duration = 45, }, -- Hurricane
	{ id = 74224, duration = 20, }, -- Heartsong
	{ id = 55637, duration = 45, }, -- Lightweave Embroidery (Rank 1)
	{ id = 75170, duration = 45, }, -- Lightweave Embroidery (Rank 2)
	{ id = 55775, duration = 45, }, -- Swordguard Embroidery (Rank 1)
	{ id = 75176, duration = 45, }, -- Swordguard Embroidery (Rank 2)
	{ id = 55767, duration = 45, }, -- Darkglow Embroidery (Rank 1)
	{ id = 75173, duration = 45, }, -- Darkglow Embroidery (Rank 2)
	{ id = 95712, duration = 45, }, -- Gnomish X-Ray Scope
	{ id = 59626, duration = 35, }, -- Black Magic
	
	-- Item internal cooldowns
	{ id = 128985, duration = 50, item = 79331 }, -- [MOP] Relic of Yu'lon [Int DPS DMC]
	{ id = 128987, duration = 45, item = 79330 }, -- [MOP] Relic of Chi'ji [Int HPS DMC]
	{ id = 128984, duration = 55, item = 79328 }, -- [MOP] Relic of Xuen [Agi DMC]
	{ id = 128986, duration = 45, item = 79327 }, -- [MOP] Relic of Xuen [Str DMC]
	{ id = 60234, duration = 55, item = 75274 }, -- [MOP] Zen Alchemist Stone
	{ id = 89091, duration = 45, item = 62047, }, -- Darkmoon Card: Volcano
	{ id = 91192, duration = 50, item = 62467, }, -- Mandala of Stirring Patterns
	{ id = 91047, duration = 75, item = 62465, }, -- Stump of Time
	{ id = 92233, duration = 30, item = 58182, }, -- Bedrock Talisman
	{ id = 91024, duration = 50, item = 59519, }, -- Theralion's Mirror
	{ id = 92235, duration = 30, item = 59332, }, -- Symbiotic Worm
	{ id = 92124, duration = 75, item = 59441, }, -- Prestor's Talisman of Machination
	{ id = 91816, duration = 100, item = 59224, }, -- Heart of Rage
	{ id = 91184, duration = 75, item = 59500, }, -- Fall of Mortality
	{ id = 92126, duration = 50, item = 59473, }, -- Essence of the Cyclone
	{ id = 91821, duration = 75, item = 59506, }, -- Crushing Weight
	{ id = 91007, duration = 100, item = 59326, }, -- Bell of Enraging Resonance
	{ id = 92108, duration = 50, item = 59520, }, -- Unheeded Warning
	{ id = 90992, duration = 50, item = 56407, }, -- Anhuur's Hymnal
	{ id = 91149, duration = 100, item = 56414, }, -- Blood of Isiset
	{ id = 91364, duration = 100, item = 56393, }, -- Heart of Solace
	{ id = 92091, duration = 75, item = 56328, }, -- Key to the Endless Chamber
	{ id = 92184, duration = 30, item = 56347, }, -- Leaden Despair
	{ id = 91368, duration = 50, item = 56431, }, -- Right Eye of Rajh
	{ id = 92094, duration = 50, item = 56427, }, -- Left Eye of Rajh
	{ id = 91143, duration = 75, item = 56377, }, -- Rainsong
	{ id = 91002, duration = 20, item = 56400, }, -- Sorrowsong
	{ id = 91139, duration = 75, item = 56351, }, -- Tear of Blood
	{ id = 90898, duration = 75, item = 56339, }, -- Tendrils of Burrowing Dark
	{ id = 92205, duration = 60, item = 56449, }, -- Throngus's Finger
	{ id = 90887, duration = 75, item = 56320, }, -- Witching Hourglass
	{ id = 61671, duration = 45, item = 43829, }, -- Crusader's Locket
	{ id = 92052, duration = 50, }, -- Herald of Doom (Grace of the Herald, Heart of the Vile)
	{ id = 92166, duration = 80, }, -- Hardened Shell (Quest reward and Porcelain Crab)
	{ id = 85027, duration = 50, }, -- PvP Insignia of Dominance
	{ id = 85032, duration = 50, }, -- PvP Insignia of Victory
	{ id = 85022, duration = 50, }, -- PvP Insignia of Conquest
	{ id = 99061, duration = 45, class = "MAGE" }, -- Mage 2-piece T12 bonus
}