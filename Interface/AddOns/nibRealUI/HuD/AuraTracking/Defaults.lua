local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

--[[
Auras
{
	.type = "Aura",							(default)
	.spell = spellID or spell name
	minLevel = level
	checkKnown = true or false				(default = false for Free, true for Static)
	.auraType = "buff" or "debuff"			(default = "buff")
	.unit = unitID							(default = "player")
	specs = {spec1, spec2, spec3, spec4}	(default = true for all specs)
	forms = {cat, bear, moonkin}			(default = nil)
	order = #								(if not specified indicator will be Free, otherwise Static)
	side = "LEFT" or "RIGHT"				(default = "LEFT" for "buff" and "RIGHT" for "debuff")
	hideStacks = true or false				(default = false - hide stack count [useful for buffs with a passive 1 stack])
	hideOOC = true or false					(default = false - hide out-of-combat even if active)
	ignoreRaven = true or false				(default = false - don't add this aura to Raven's filter lists)
}

Sort static buffs/debuffs by order whenever possible

]]--

nibRealUI.auraTrackingDefaults = {

["DEATHKNIGHT"] = { ------------------

-- Static Buffs
	{	-- Shadow Infusion (Unholy)
		spell = 91342,
		minLevel = 60,
		order = 1,
		specs = {false, false, true}
	},
	{	-- Scent of Blood (Blood)
		spell = 50421,
		minLevel = 62,
		order = 1,
		specs = {true, false, false}
	},
	{	-- Blood Shield (Blood)
		spell = 77535,
		minLevel = 80,
		order = 2,
		specs = {true, false, false}
	},
-- Static Debuffs
	{	-- Blood Plague
		spell = 59879,
		auraType = "debuff",
		order = 1,
	},
	{	-- Frost Fever
		spell = 59921,
		auraType = "debuff",
		order = 2,
	},
-- Free Buffs
	{spell = 114851},	-- Blood Charge
	{spell = 51124},	-- Killing Machine
	{spell = 51271},	-- Pillar of Frost
	{spell = 49039},	-- Lichborne
	{spell = 48792},	-- Icebound Fortitude
	{spell = 22744},	-- Chains of Ice
	{spell = 59052},	-- Freezing Fog
	{spell = 55233},	-- Vampiric Blood
	{spell = 48707},	-- Anti-Magic Shell
	{spell = 87256},	-- Dancing Rune Weapon
	{spell = 49222},	-- Bone Shield
	{spell = 50461},	-- Anti-Magic Zone
	{spell = 49016},	-- Unholy Frenzy
	{spell = 96268},	-- Death's Advance
	{spell = 81340},	-- Sudden Doom
	{spell = 63560, unit = "pet"},	-- Dark Transformation
-- Free Debuffs

},	-- DEATHKNIGHT ------------------


["DRUID"] = { ------------------

-- Static Buffs
	{	-- Harmony (Resto)
		spell = 100977,
		minLevel = 80,
		order = 1,
		specs = {false, false, false, true},
		forms = {false, false, false, true}	-- Show in Human form
	},
	{	-- Nature's Grace (Balance)
		spell = 16886,
		minLevel = 10,
		order = 1,
		ignoreSpec = true,
		forms = {false, false, true, false}	-- Show in Moonkin form
	},
	{	-- Lunar Shower (Balance)
		spell = 81192,
		minLevel = 82,
		order = 2,
		ignoreSpec = true,
		forms = {false, false, true, false}	-- Show in Moonkin form
	},
	{	-- Savage Roar (Feral)
		type = "SavageRoar",
		order = 1,
	},
	{	-- Savage Defense (Guardian)
		spell = 62606,
		minLevel = 10,
		order = 1,
		ignoreSpec = true,
		forms = {false, true, false, false}	-- Show in Bear form
	},
-- Static Debuffs
	{	-- Rake (Feral)
		spell = 1822,
		auraType = "debuff",
		order = 1,
		ignoreSpec = true,
		forms = {true, false, false, false}	-- Show in Cat form
	},
	{	-- Rip (Feral)
		spell = 1079,
		auraType = "debuff",
		order = 2,
		ignoreSpec = true,
		forms = {true, false, false, false}	-- Show in Cat form
	},
	{	-- Thrash (Feral)
		spell = 106832,
		auraType = "debuff",
		order = 3,
		ignoreSpec = true,
		forms = {true, false, false, false}	-- Show in Cat form
	},
	{	-- Lacerate (Guardian)
		spell = 33745,
		auraType = "debuff",
		order = 1,
		ignoreSpec = true,
		forms = {false, true, false, false}	-- Show in Bear form
	},
	{	-- Thrash (Guardian)
		spell = 106832,
		auraType = "debuff",
		order = 2,
		ignoreSpec = true,
		forms = {false, true, false, false}	-- Show in Bear form
	},
	{	-- Sunfire (Balance)
		spell = 93402,
		auraType = "debuff",
		order = 1,
		ignoreSpec = true,
		forms = {false, false, true, false}	-- Show in Moonkin form
	},
	{	-- Moonfire (Balance)
		spell = 8921,
		auraType = "debuff",
		order = 2,
		ignoreSpec = true,
		forms = {false, false, true, false}	-- Show in Moonkin form
	},
-- Free Buffs
	{spell = 22812},	-- Barkskin
	{spell = 29166},	-- Innervate
	{spell = 50322},	-- Survival Instincts
	{spell = 5211},		-- Dash
	{spell = 5229},		-- Enrage
	{spell = 69369},	-- Predator's Swiftness
	{spell = 33831},	-- Force of Nature
	{spell = 135700},	-- Clearcasting
	{spell = 5217},		-- Tiger's Fury
	{spell = 135286},	-- Tooth and Claw
-- Free Debuffs
	{spell = 50334, auraType = "debuff"},	-- Berserk
	{spell = 115798, auraType = "debuff"},	-- Weakened Blows
	{spell = 22570, auraType = "debuff"},	-- Maim
	{spell = 9007, auraType = "debuff"},	-- Pounce Bleed
	{spell = 770, auraType = "debuff"},		-- Faerie Fire
	{spell = 58180, auraType = "debuff"},	-- Infected Wounds
	{	-- Lacerate (Feral)
		spell = 33745,
		auraType = "debuff",
		ignoreSpec = true,
		forms = {true, false, false, false}
	},
-- Static Buffs
	{	-- Wild Mushrooms (Resto)
		type = "WildMushrooms",
		order = 2,
	},

},	-- DRUID -------------------


["HUNTER"] = { ------------------
-- Static Buffs
	{	-- Ready Set Aim (Marks)
		spell = 82925,
		minLevel = 58,
		order = 1,
		specs = {false, true, false}
	},
	{	-- Lock and Load (Surv)
		spell = 56453,
		minLevel = 43,
		order = 1,
		specs = {false, false, true}
	},
	{	-- Thrill of the Hunt (Talent)
		spell = 34720,
		order = 2,
	},
-- Static Debuffs
	{	-- Serpent Sting
		spell = 1978,
		auraType = "debuff",
		order = 1,
	},
-- Free Buffs
	{spell = 82692},	-- Focus Fire
	{spell = 34471},	-- Beast Within
	{spell = 53301},	-- Explosive Shot (buff or debuff?)
	{spell = 53302},	-- Sniper Training
	{spell = 19263},	-- Deterrence
	{spell = 53480},	-- Roar of Sacrifice (Cunning)
	{spell = 51755},	-- Camouflage
	{spell = 54216},	-- Master's Call
	{spell = 3045},		-- Rapid Fire
	{spell = 90355},	-- Ancient Hysteria
	{spell = 90361},	-- Spirit Mend
	{spell = 53224},	-- Steady Focus
-- Free Debuffs
	{spell = 3674, auraType = "debuff"},	-- Black Arrow
	{spell = 19386, auraType = "debuff"},	-- Wyvern Sting
	{spell = 53301, auraType = "debuff"},	-- Explosive Shot
	{spell = 63468, auraType = "debuff"},	-- Piercing Shots
	{spell = 13812, auraType = "debuff"},	-- Explosive Trap
	{spell = 3355, auraType = "debuff"},	-- Freezing Trap
	{spell = 13810, auraType = "debuff"},	-- Ice Trap
	{spell = 13797, auraType = "debuff"},	-- Immolation Trap
	{spell = 131894, auraType = "debuff"},	-- A Murder of Crows

},	-- HUNTER -------------------


["MAGE"] = { ------------------

-- Static Buffs
	{	-- Arcane Missiles! (Arcane)
		spell = 79683,
		minLevel = 24,
		order = 1,
		specs = {true, false, false},
	},
	{	-- Fingers of Frost (Frost)
		spell = 44544,
		minLevel = 12,
		order = 1,
		specs = {false, false, true},
	},
-- Static Debuff
	{	-- Arcane Charge (Arcane)
		spell = 36032,
		auraType = "debuff",
		minLevel = 10,
		unit = "player",
		order = 1,
		specs = {true, false, false},
	},
	{	-- Ignite (Fire)
		spell = 12654,
		auraType = "debuff",
		minLevel = 12,
		order = 1,
		specs = {false, true, false},
	},
	{	-- Pyroblast (Fire)
		spell = 11366,
		auraType = "debuff",
		order = 2,
		specs = {false, true, false},
	},
-- Free Buffs
	{spell = 12043},	-- Presence of Mind
	{spell = 116257},	-- Invoker's Energy
	{spell = 1463},		-- Incanter's Ward
	{spell = 116267},	-- Incanter's Absorption
	{spell = 12472},	-- Icy Veins
	{spell = 12042},	-- Arcane Power
	{spell = 48108},	-- Hot Streak
	{spell = 55342},	-- Mirror Image
	{spell = 115610},	-- Temporal Shield
	{spell = 110909},	-- Alter Time
	{spell = 12051},	-- Evocation
	{spell = 80353},	-- Time Warp
	{spell = 32612},	-- Invisibility
	{spell = 110960},	-- Greater Invisibility
	{spell = 108839},	-- Ice Flows
	{spell = 111264},	-- Ice Ward
	{spell = 108843},	-- Blazing Speed
-- Free Debuffs
	{spell = 31589, auraType = "debuff"},	-- Slow
	{spell = 116, auraType = "debuff"},		-- Frostbolt
	{spell = 44614, auraType = "debuff"},	-- Frostfire Bolt
	{spell = 44457, auraType = "debuff"},	-- Living Bomb

},	-- MAGE -------------------


["MONK"] = { ------------------

-- Static Buffs
	{	-- Shuffle (Brewmaster)
		spell = 115307,
		minLevel = 10,
		order = 1,
		specs = {true, false, false},
	},
	{	-- Elusive Brew (Brewmaster)
		spell = 128939,
		minLevel = 10,
		order = 2,
		specs = {true, false, false},
	},
	{	-- Vital Mists (Mistweaver)
		spell = 118674,
		minLevel = 10,
		order = 1,
		specs = {false, true, false},
	},
	{	-- Serpent's Zeal (Mistweaver)
		spell = 127722,
		minLevel = 10,
		order = 2,
		specs = {false, true, false},
	},
	{	-- Tiger Power (Windwalker)
		spell = 125359,
		minLevel = 10,
		order = 1,
		specs = {false, false, true},
	},
	{	-- Tigereye Brew (Windwalker)
		spell = 116740,
		minLevel = 56,
		order = 2,
		specs = {false, false, true},
	},
-- Static Debuff
	{	-- Dizzying Haze (Brewmaster)
		spell = 115180,
		auraType = "debuff",
		order = 1,
		specs = {true, false, false},
	},
	{	-- Rising Sun Kick (Windwalker)
		spell = 107428,
		auraType = "debuff",
		order = 1,
		specs = {false, false, true},
	},
-- Free Buffs
	{spell = 120954},	-- Fortifying Brew
	{spell = 131523},	-- Zen Meditation
	{spell = 122783},	-- Diffuse Magic
	{spell = 122278},	-- Dampen Harm
	{spell = 115213},	-- Avert Harm
	{spell = 116849},	-- Life Cocoon
	{spell = 125174},	-- Touch of Karma
	{spell = 116841},	-- Tiger's Lust
	{spell = 115294},	-- Mana Tea
	{spell = 115295},	-- Guard
-- Free Debuffs
	{spell = 115798, auraType = "debuff"}, -- Weakened Blows 
	{spell = 115804, auraType = "debuff"}, -- Mortal Wounds

},	-- MONK -------------------


["PALADIN"] = { ------------------

-- Static Buffs
	{	-- Avenging Wrath (Ret)
		spell = 31884,
		order = 1,
		specs = {false, false, true},
	},
	{	-- Inquisition (Ret)
		spell = 84963,
		order = 2,
		specs = {false, false, true},
	},
-- Static Debuff
-- Free Buffs
	{	-- Avenging Wrath (Holy, Prot)
		spell = 31884,
		specs = {true, true, false},
	},
    {spell = 498}, 		-- Divine Protection
    {spell = 105809},	-- Holy Avenger
    {spell = {86659,86669,86698}},	-- Guardian
    {spell = 1044}, 	-- Hand of Freedom
	{spell = 1022}, 	-- Hand of Protection
	{spell = 6940}, 	-- Hand of Sacrifice
	{spell = 1038}, 	-- Hand of Salvation
	{spell = 642},		-- Divine Shield
	{spell = 54428}, 	-- Divine Plea
	{spell = 20925}, 	-- Holy Shield
	{spell = 31842},	-- Divine Favor
	{spell = 114039},	-- Hand of Purity
	{spell = 31821},	-- Devotion Aura
	{spell = 53563},	-- Beacon of Light
	{spell = 85499},	-- Speed of Light
	{spell = 31850},	-- Ardent Defender
-- Free Debuffs
	{spell = 31935, auraType = "debuff"}, -- Avenger's Shield
	{spell = 26573, auraType = "debuff"}, -- Concecration
	{spell = 115798, auraType = "debuff"}, -- Weakened Blows
	{spell = 31803, auraType = "debuff"}, -- Censure

},	-- PALADIN -------------------


["PRIEST"] = { ------------------

-- Static Buffs
	{	-- Evangelism (Disc)
		spell = 81661,
		minLevel = 44,
		order = 1,
		specs = {true, false, false},
	},
	{	-- Borrowed Time (Disc)
		spell = 59889,
		minLevel = 62,
		order = 2,
		specs = {true, false, false},
	},
	{	-- Serendipity (Holy)
		spell = 63735,
		minLevel = 34,
		order = 1,
		specs = {false, true, false},
	},
-- Static Debuff
	{	-- Vampiric Touch (Shadow)
		spell = 34914,
		auraType = "debuff",
		order = 1,
		specs = {false, false, true},
	},
	{	-- SW:P (Shadow)
		spell = 589,
		auraType = "debuff",
		order = 2,
		specs = {false, false, true},
	},
	{	-- Devouring Plague (Shadow)
		spell = 2944,
		auraType = "debuff",
		order = 3,
		specs = {false, false, true},
	},
-- Free Buffs
    {spell = 109964},	-- Spirit Shell
    {spell = 47585},	-- Dispersion
    {spell = 15286},	-- Vampiric Embrace
	{spell = 33206},	-- Pain Suppression
	{spell = 10060},	-- Power Infusion
	{spell = 47788},	-- Guardian Spirit
	{spell = 62618},	-- Power Word: Barrier
	{spell = 6346},		-- Fear Ward
	{spell = 114239},	-- Phantasm
	{spell = 119032},	-- Spectral Guise
	{spell = 27827},	-- Spirit of Redemption
-- Free Debuffs
	{spell = 14914, auraType = "debuff"}, -- Holy Fire
	{spell = 64044, auraType = "debuff"}, -- Psychic Horror

},	-- PRIEST -------------------


["ROGUE"] = { ------------------

-- Static Buffs
	{	-- Slice and Dice
		type = "SliceAndDice",
		order = 1,
	},
	{	-- Bandit's Guile (Combat)
		type = "BanditsGuile",
		order = 2,
	},
	{	-- Shadow Dance (Sub)
		spell = 51713,
		order = 2,
		specs = {false, false, true},
	},
	{	-- Envenom (Ass)
		spell = 32645,
		specs = {true, false, false},
		order = 2,
	},
-- Static Debuffs
	{	-- Rupture
		type = "Rupture",
		order = 1,
	},
	{	-- Revealing Strike (Comb)
		spell = 84617,
		auraType = "debuff",
		specs = {false, true, false},
		order = 2,
	},
	{	-- Find Weakness (Sub)
		auraType = "debuff",
		spell = 91023,
		order = 2,
		specs = {false, false, true},
	},
-- Free Buffs
	{spell = 73651},	-- Recuperate
	{spell = 108212},	-- Burst of Speed
	{spell = 13750},	-- Adrenaline Rush
	{spell = 13877},	-- Blade Flurry
	{spell = 2983},		-- Sprint
	{spell = 5277},		-- Evasion
	{spell = 108208},	-- Subterfuge
	{spell = 121153},	-- Blindside
	{spell = 121471},	-- Shadow Blades
	{spell = 57933},	-- TotT
	{spell = 31223},	-- Master of Subtlety
	{spell = 31224},	-- Cloak of Shadows
	{spell = 45182},	-- Cheating Death
	{spell = 114018},	-- Shroud of Concealment
	{spell = 11327},	-- Vanish
	{spell = 137619},	-- Marked for Death
	{spell = 122289},	-- Feint
	{spell = 74002},	-- Combat Insight
-- Free Debuffs
	{spell = 16511, auraType = "debuff"},	-- Hemorrhage
	{spell = 108215, auraType = "debuff"},	-- Paralytic Poison
	{spell = 79140, auraType = "debuff"},	-- Vendetta
	{spell = 703, auraType = "debuff"},		-- Garrote
	{spell = 108210, auraType = "debuff"},	-- Nerve Strike

},	-- ROGUE ------------------


["SHAMAN"] = { ------------------

-- Static Buffs
	{	-- Maelstrom Weapon (Enh)
		spell = 65986,
		minLevel = 83,
		order = 1,
		specs = {false, true, false}
	},
	{	-- Tidal Waves (Resto)
		spell = 53390,
		minLevel = 50,
		order = 1,
		specs = {false, false, true}
	},
-- Static Debuffs
	{	-- Flame Shock (Enh, Ele)
		spell = 8050,
		auraType = "debuff",
		order = 1,
		specs = {true, true, false}
	},
	{	-- Frost Shock (Enh, Ele)
		spell = 8056,
		auraType = "debuff",
		order = 2,
		specs = {true, true, false}
	},
-- Free Buffs
	{	-- Lightning Shield (Ele) (Fulmination)
		spell = 324,
		minLevel = 20,
		hideOOC = true,
		specs = {true, false, false}
	},
	{spell = 30823},	-- Shamanistic Rage
	{spell = 16246},	-- Clearcasting
	{spell = 73683},	-- Unleash Flame
	{spell = 73681},	-- Unleash Wind
	{spell = 79206},	-- Spiritwalker's Grace
	{spell = 61295},	-- Riptide
	{spell = 98007},	-- Spirit Link Totem
	{spell = 108271},	-- Astral Shift
	{spell = 16188},	-- Ancestral Swiftness
	{spell = 2825},		-- Bloodlust
	{spell = 16191},	-- Mana Tide
	{spell = 8178},		-- Grounding Totem Effect
	{spell = 58875},	-- Spirit Walk
	{spell = 108281},	-- Ancestral Guidance
	{spell = 16166},	-- Elemental Mastery
	{spell = 114896},	-- Windwalk Totem
	{spell = 114049},	-- Ascendance
-- Free Debuffs
	{spell = 8050, auraType = "debuff", specs = {false, false, true}},	-- Flame Shock (Resto)
	{spell = 8056, auraType = "debuff", specs = {false, false, true}},	-- Frost Shock (Resto)
	{spell = 115798, auraType = "debuff"},	-- Weakened Blows
	{spell = 17364, auraType = "debuff"},	-- Stormstrike
	
},	-- SHAMAN ------------------


["WARLOCK"] = { ------------------

-- Static Buffs
	{spell = 104773},	-- Unending Resolve
	{	-- Molten Core (Demo)
		spell = 122351,
		minLevel = 69,
		order = 1,
		specs = {false, true, false}
	},
	{	-- Burning Embers (Dest)
		type = "BurningEmbers",
		order = 1,
	},
-- Static Debuffs
	{	-- Corruption (Aff, Demo)
		spell = 172,
		auraType = "debuff",
		order = 1,
		specs = {true, true, false}
	},
	{	-- Doom (Demo)
		spell = 603,
		auraType = "debuff",
		minLevel = 36,
		order = 2,
		specs = {false, true, false}
	},
	{	-- Unstable Affliction (Aff)
		spell = 30108,
		auraType = "debuff",
		minLevel = 10,
		order = 2,
		specs = {true, false, false}
	},
	{	-- Agony, Doom (Aff)
		spell = {980,603},
		auraType = "debuff",
		minLevel = 36,
		order = 3,
		specs = {true, false, false}
	},
	{	-- Immolate (Dest)
		spell = 348,
		auraType = "debuff",
		order = 1,
		specs = {false, false, true}
	},

-- Free Buffs
	{spell = 110913},	-- Dark Bargain
	{spell = 108359},	-- Dark Regeneration
	{spell = 113860},	-- Dark Soul: Misery
	{spell = 113861},	-- Dark Soul: Knowledge
	{spell = 113858},	-- Dark Soul: Instability
	{spell = 88448},	-- Demonic Rebirth

-- Free Debuffs
	{spell = 27243, auraType = "debuff"},	-- Seed of Corruption
	{spell = 48181, auraType = "debuff"},	-- Haunt
	{spell = 80270, auraType = "debuff"},	-- Shadowflame
	{spell = 17962, auraType = "debuff"},	-- Conflagrate
	{spell = 80240, auraType = "debuff"},	-- Havoc
	{spell = 17877, auraType = "debuff"},	-- Shadowburn
	{spell = 108505, auraType = "debuff"},	-- Archimonde's Vengeance

},	-- WARLOCK ------------------


["WARRIOR"] = { ------------------

-- Static Buffs
	{	-- Enrage (Arms, Fury)
		spell = 12880,
		minLevel = 14,
		order = 1,
		specs = {true, true, false},
	},
	{	-- Taste for Blood (Arms)
		spell = 56636,
		minLevel = 30,
		order = 2,
		specs = {true, false, false},
	},
	{	-- Raging Blow! (Fury)
		spell = 131116,
		minLevel = 30,
		order = 2,
		specs = {false, true, false},
	},
-- Static Debuffs
	{	-- Weakened Armor
		spell = 113746,
		auraType = "debuff",
		minLevel = 16,
		order = 1,
		anyone = true,
	},
-- Free Buffs
	{spell = 118038},	-- Die by the Sword
	{spell = 55694},	-- Enraged Regeneration
	{spell = 97463},	-- Rallying Cry
	{spell = 12975},	-- Last Stand
	{spell = 114029},	-- Safeguard
	{spell = 871},		-- Shield Wall
	{spell = 114030},	-- Vigilance
	{spell = 18499},	-- Berserker Rage
	{spell = 1719},		-- Recklessness
	{spell = 23920},	-- Spell Reflection
	{spell = 114028},	-- Mass Spell Reflection
	{spell = 46924},	-- Bladestorm
	{spell = 3411},		-- Intervene
	{spell = 107574},	-- Avatar
	{spell = 12292},	-- Bloodbath
	{spell = 12950},	-- Meat Cleaver
-- Free Debuffs
	{spell = 86346, auraType = "debuff"},	-- Colossus Smash
	{spell = 1160, auraType = "debuff"},	-- Demoralizing Shout
	{spell = 1715, auraType = "debuff"},	-- Hamstring
	{spell = 12294, auraType = "debuff"},	-- Mortal Strike
	{spell = 64382, auraType = "debuff"},	-- Shattering Throw
	{spell = 6552, auraType = "debuff"},	-- Pummel
	{spell = 115798, auraType = "debuff"},	-- Weakened Blows
	{spell = 1715, auraType = "debuff"},	-- Hamstring
	
},	-- WARRIOR ------------------



}	-- defaults

-- function nibRealUI:GetAuraTrackingDefaults()
-- 	return {
-- 		profile = {
-- 			slotSize = 32,
-- 			padding = 1,
-- 			tracking = defaults,
-- 		},
-- 	}
-- end