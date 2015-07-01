local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "AuraTracking"
local AuraTracking = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0", "AceTimer-3.0")

--[[
Auras
{
    type = "Aura",                          (default)
    spell = spellID or spell name
    minLevel = level
    checkKnown = true or false              (default = false for Free, true for Static)
    auraType = "buff" or "debuff"           (default = "buff")
    unit = unitID                           (default = "player")
    specs = {spec1, spec2, spec3, spec4}    (default = true for all specs)
    order = #                               (if not specified indicator will be Free, otherwise Static)
    side = "LEFT" or "RIGHT"                (default = "LEFT" for "buff" and "RIGHT" for "debuff")
    hideStacks = true or false              (default = false - hide stack count [useful for buffs with a passive 1 stack])
    hideOOC = true or false                 (default = false - hide out-of-combat even if active)
    ignoreRaven = true or false             (default = false - don't add this aura to Raven's filter lists)
}

Sort static buffs/debuffs by order whenever possible

]]--

AuraTracking.Defaults = {

["DEATHKNIGHT"] = { ------------------

-- Static Buffs
    {   -- Scent of Blood (Blood)
        spell = 50421,
        minLevel = 62,
        order = 1,
        specs = {true, false, false}
    },
    {   -- Blood Shield (Blood)
        spell = 77535,
        minLevel = 80,
        order = 2,
        specs = {true, false, false}
    },
    {   -- Shadow Infusion, Dark Transformation (Unholy)
        spell = {91342,63560},
        minLevel = 60,
        unit = "pet",
        order = 1,
        specs = {false, false, true},
    },
-- Static Debuffs
    {   -- Necrotic Plague (Talent)
        spell = 155159,
        auraType = "debuff",
        order = 1,
    },
    {   -- Blood Plague
        spell = 55078,
        minLevel = 55,
        auraType = "debuff",
        replace = 155159,
        order = 1,
    },
    {   -- Frost Fever
        spell = 55095,
        minLevel = 55,
        auraType = "debuff",
        replace = 155159,
        order = 2,
    },
-- Free Buffs
    {   -- Crimson Scourge (Blood)
        spell = 81141,
        specs = {true, false, false},
    },
    {   -- Vampiric Blood (Blood)
        spell = 55233,
        specs = {true, false, false},
    },
    {   -- Dancing Rune Weapon (Blood)
        spell = 81256,
        specs = {true, false, false},
    },
    {   -- Bone Shield (Blood)
        spell = 49222,
        specs = {true, false, false},
    },
    {   -- Killing Machine (Frost)
        spell = 51124,
        specs = {false, true, false},
    },
    {   -- Pillar of Frost (Frost)
        spell = 51271,
        specs = {false, true, false},
    },
    {   -- Freezing Fog (Frost, from Rime)
        spell = 59052,
        specs = {false, true, false},
    },
    {   -- Sudden Doom (Unholy)
        spell = 81340,
        specs = {false, false, true},
    },
    {spell = 48792},    -- Icebound Fortitude
    {spell = 22744},    -- Chains of Ice
    {spell = 48707},    -- Anti-Magic Shell
    {spell = 49039},    -- Lichborne (Talent)
    {spell = 50461},    -- Anti-Magic Zone (Talent)
    {spell = 96268},    -- Death's Advance (Talent)
    {spell = 114851},   -- Blood Charge (used for Blood Tap, Talent)
-- Free Debuffs

},  -- DEATHKNIGHT ------------------


["DRUID"] = { ------------------

-- Static Buffs
    {   -- Savage Roar (Feral)
        type = "SavageRoar",
        order = 1,
    },
    {   -- Savage Defense (Guardian)
        spell = 62606,
        minLevel = 10,
        order = 1,
        specs = {false, false, true, false}
    },
    {   -- Harmony (Resto Mastery) gained by casting direct heals
        spell = 100977,
        minLevel = 80,
        order = 1,
        specs = {false, false, false, true},
    },
    {   -- Wild Mushrooms (Resto)
        type = "WildMushrooms",
        order = 2,
    },
-- Static Debuffs
    {   -- Sunfire (Balance)
        spell = 164815,
        auraType = "debuff",
        minLevel = 10,
        order = 1,
        specs = {true, false, false, false}
    },
    {   -- Moonfire (Balance)
        spell = 164812,
        auraType = "debuff",
        minLevel = 10,
        order = 2,
        specs = {true, false, false, false}
    },
    {   -- Rake (Feral)
        spell = 155722,
        auraType = "debuff",
        minLevel = 10,
        order = 1,
        specs = {false, true, false, false}
    },
    {   -- Rip (Feral)
        spell = 1079,
        auraType = "debuff",
        order = 2,
        specs = {false, true, false, false}
    },
    {   -- Thrash (Guardian)
        spell = 77758,
        auraType = "debuff",
        minLevel = 14,
        order = 1,
        specs = {false, false, true, false}
    },
    {   -- Lacerate (Guardian)
        spell = 33745,
        auraType = "debuff",
        order = 2,
        specs = {false, false, true, false}
    },
-- Free Buffs
    {   -- Lunar/Solar Empowerment (Balance)
        spell = {164547,164545},
        specs = {true, false, false, false}
    },
    {   -- Lunar/Solar Peak (Balance)
        spell = {171743,171744},
        specs = {true, false, false, false}
    },
    {   -- Celestial Alignment (Balance)
        spell = 112071,
        specs = {true, false, false, false}
    },
    {   -- Incarnation: Chosen of Elune (Talent, Balance)
        spell = 102560,
        specs = {true, false, false, false}
    },
    {   -- Predatory Swiftness (Feral)
        spell = 69369,
        specs = {false, true, false, false}
    },
    {   -- Tiger's Fury (Feral)
        spell = 5217,
        specs = {false, true, false, false}
    },
    {   -- Barkskin (Guardian)
        spell = 22812,
        specs = {false, false, true, false}
    },
    {   -- Tooth and Claw (Guardian)
        spell = 135286,
        specs = {false, false, true, false}
    },
    {   -- Survival Instincts (Guardian)
        spell = 50322,
        specs = {false, false, true, false}
    },
    {   -- Pulverize (Talent, Guardian)
        spell = 158792,
        specs = {false, false, true, false}
    },
    {   -- Clearcasting (Resto)
        spell = 16870,
        specs = {false, false, false, true}
    },
    {spell = 5211},     -- Dash
    {spell = 33831},    -- Force of Nature (Talent)
-- Free Debuffs
    {   -- Lacerate (Feral)
        spell = 33745,
        auraType = "debuff",
        specs = {false, true, false, false}
    },
    {   -- Thrash (Feral)
        spell = 106830,
        auraType = "debuff",
        specs = {false, true, false, false}
    },
    {   -- Maim (Feral)
        spell = 22570,
        auraType = "debuff",
        specs = {false, true, false, false}
    },
    {   -- Faerie Fire (Feral, Guardian)
        spell = 770,
        auraType = "debuff",
        specs = {false, true, true, false}
    },
    {   -- Infected Wounds (Feral, Guardian)
        spell = 58180,
        auraType = "debuff",
        specs = {false, true, true, false}
    },
    {   -- Berserk (Feral, Guardian)
        spell = 50334,
        auraType = "debuff",
        specs = {false, true, true, false}
    },

},  -- DRUID -------------------


["HUNTER"] = { ------------------
-- Static Buffs
    {   -- Frenzy (BM)
        spell = 19615,
        minLevel = 30,
        unit = "pet",
        order = 1,
        specs = {true, false, false}
    },
    {   -- Focus Fire (BM)
        spell = 82692,
        minLevel = 30,
        order = 1,
        specs = {true, false, false}
    },
    {   -- Sniper Training (MM)
        spell = 168811,
        minLevel = 80,
        order = 1,
        hideOOC = true,
        specs = {false, true, false}
    },
    {   -- Lock and Load (SV)
        spell = 168980,
        minLevel = 43,
        order = 1,
        specs = {false, false, true}
    },
    {   -- Steady Focus (Talent)
        spell = 177668,
        order = 2,
    },
-- Static Debuffs
    {   -- Serpent Sting (SV)
        spell = 118253,
        auraType = "debuff",
        minLevel = 68,
        order = 1,
        specs = {false, false, true}
    },
-- Free Buffs
    {   -- Beast Cleave (BM)
        spell = 118455,
        unit = "pet",
        specs = {true, false, false}
    },
    {   -- Bestial Wrath (BM)
        spell = 19574,
        specs = {true, false, false}
    },
    {   -- Rapid Fire (MM)
        spell = 3045,
        specs = {false, true, false}
    },
    {spell = 19263},    -- Deterrence
    {spell = 51755},    -- Camouflage
    {spell = 54216},    -- Master's Call
    {spell = 53480},    -- Roar of Sacrifice (Cunning)
    {spell = 34720},    -- Thrill of the Hunt (Talent)
-- Free Debuffs
    {   -- Black Arrow (SV)
        spell = 3674,
        auraType = "debuff",
        specs = {false, false, true}
    },
    {   -- Explosive Shot (SV)
        spell = 53301,
        auraType = "debuff",
        specs = {false, false, true}
    },
    {spell = 13812, auraType = "debuff"},   -- Explosive Trap
    {spell = 3355, auraType = "debuff"},    -- Freezing Trap
    {spell = 13810, auraType = "debuff"},   -- Ice Trap
    {spell = 131894, auraType = "debuff"},  -- A Murder of Crows (Talent)

},  -- HUNTER -------------------


["MAGE"] = { ------------------

-- Static Buffs
    {   -- Arcane Missiles! (Arcane)
        spell = 79683,
        minLevel = 24,
        order = 1,
        specs = {true, false, false},
    },
    {   -- Fingers of Frost (Frost)
        spell = 44544,
        minLevel = 12,
        order = 1,
        specs = {false, false, true},
    },
-- Static Debuff
    {   -- Arcane Charge (Arcane)
        spell = 36032,
        auraType = "debuff",
        minLevel = 10,
        unit = "player",
        order = 1,
        specs = {true, false, false},
    },
    {   -- Ignite (Fire)
        spell = 12654,
        auraType = "debuff",
        minLevel = 12,
        order = 1,
        specs = {false, true, false},
    },
    {   -- Pyroblast (Fire)
        spell = 11366,
        auraType = "debuff",
        order = 2,
        specs = {false, true, false},
    },
-- Free Buffs
    {   -- Arcane Power (Arcane)
        spell = 12042,
        specs = {true, false, false},
    },
    {   -- Presence of Mind (Arcane)
        spell = 12043,
        specs = {true, false, false},
    },
    {   -- Evocation (Arcane)
        spell = 12051,
        specs = {true, false, false},
    },
    {   -- Pyroblast!, Heating Up (Fire)
        spell = {48108,48107},
        specs = {false, true, false},
    },
    {   -- Icy Veins (Frost)
        spell = 12472,
        specs = {false, false, true},
    },
    {   -- Brain Freeze (Frost)
        spell = 57761,
        specs = {false, false, true},
    },
    {spell = 55342},    -- Mirror Image
    {spell = 108843},   -- Blazing Speed (Talent)
    {spell = 108839},   -- Ice Floes (Talent)
    {spell = 110909},   -- Alter Time (Talent)
    {spell = 111264},   -- Ice Ward (Talent)
    {spell = 116014},   -- Rune of Power (Talent)
    {spell = 116267},   -- Incanter's Flow (Talent)
    {spell = {32612,113862}},   -- Invisibility, Greater Invisibility (Talent)
-- Free Debuffs
    {spell = 31589, auraType = "debuff"},   -- Slow
    {spell = 116, auraType = "debuff"},     -- Frostbolt
    {spell = 44614, auraType = "debuff"},   -- Frostfire Bolt
    {spell = 44457, auraType = "debuff"},   -- Living Bomb

},  -- MAGE -------------------


["MONK"] = { ------------------

-- Static Buffs
    {   -- Shuffle (Brewmaster)
        spell = 115307,
        minLevel = 10,
        order = 1,
        specs = {true, false, false},
    },
    {   -- Elusive Brew (Brewmaster)
        spell = {115308,128939}, -- Effect buff, Stacking buff
        minLevel = 10,
        order = 2,
        specs = {true, false, false},
    },
    {   -- Vital Mists (Mistweaver)
        spell = 118674,
        minLevel = 10,
        order = 1,
        specs = {false, true, false},
    },
    {   -- Crane's Zeal (Mistweaver)
        spell = 127722,
        minLevel = 10,
        order = 2,
        specs = {false, true, false},
    },
    {   -- Tigereye Brew (Windwalker)
        spell = {116740,125195}, -- Effect buff, Stacking buff
        minLevel = 56,
        order = 1,
        specs = {false, false, true},
    },
-- Static Debuff
    {   -- Rising Sun Kick (Windwalker)
        spell = 130320,
        auraType = "debuff",
        minLevel = 56,
        order = 1,
        specs = {false, true, true},
    },
-- Free Buffs
    {   -- Guard (Brewmaster)
        spell = 115295,
        specs = {true, false, false},
    },
    {   -- Touch of Karma (Windwalker)
        spell = 125174,
        specs = {false, false, true},
    },
    {   -- Energizing Brew (Windwalker)
        spell = 115288,
        specs = {false, false, true},
    },
    {   -- Mana Tea (Mistweaver)
        spell = 115294,
        specs = {false, true, false},
    },
    {spell = 125359},   -- Tiger Power
    {spell = 120954},   -- Fortifying Brew
    {spell = 122783},   -- Diffuse Magic (Talent)
    {spell = 122278},   -- Dampen Harm (Talent)
    {spell = 116841},   -- Tiger's Lust (Talent)
    {spell = 152173},   -- Serenity (Talent)
-- Free Debuffs
    {spell = 115804, auraType = "debuff"}, -- Mortal Wounds

},  -- MONK -------------------


["PALADIN"] = { ------------------

-- Static Buffs
    {   -- Avenging Wrath (Ret)
        spell = 31884,
        order = 1,
        specs = {false, false, true},
    },
-- Static Debuff
-- Free Buffs
    {   -- Avenging Wrath (Holy, Prot)
        spell = 31884,
        specs = {true, true, false},
    },
    {spell = 498},      -- Divine Protection
    {spell = 105809},   -- Holy Avenger
    {spell = 86659},    -- Guardian
    {spell = 1044},     -- Hand of Freedom
    {spell = 1022},     -- Hand of Protection
    {spell = 6940},     -- Hand of Sacrifice
    {spell = 1038},     -- Hand of Salvation
    {spell = 642},      -- Divine Shield
    {spell = 20925},    -- Holy Shield
    {spell = 31842},    -- Divine Favor
    {spell = 114039},   -- Hand of Purity
    {spell = 31821},    -- Devotion Aura
    {spell = 53563},    -- Beacon of Light
    {spell = 85499},    -- Speed of Light
    {spell = 31850},    -- Ardent Defender
-- Free Debuffs
    {spell = 31935, auraType = "debuff"}, -- Avenger's Shield
    {spell = 26573, auraType = "debuff"}, -- Concecration
    {spell = 31803, auraType = "debuff"}, -- Censure

},  -- PALADIN -------------------


["PRIEST"] = { ------------------

-- Static Buffs
    {   -- Evangelism (Disc)
        spell = 81661,
        minLevel = 44,
        order = 1,
        specs = {true, false, false},
    },
    {   -- Borrowed Time (Disc)
        spell = 59889,
        minLevel = 62,
        order = 2,
        specs = {true, false, false},
    },
    {   -- Serendipity (Holy)
        spell = 63735,
        minLevel = 34,
        order = 1,
        specs = {false, true, false},
    },
-- Static Debuff
    {   -- Vampiric Touch (Shadow)
        spell = 34914,
        auraType = "debuff",
        order = 1,
        specs = {false, false, true},
    },
    {   -- SW:P (Shadow)
        spell = 589,
        auraType = "debuff",
        order = 2,
        specs = {false, false, true},
    },
    {   -- Devouring Plague (Shadow)
        spell = 158831,
        auraType = "debuff",
        minLevel = 21,
        order = 3,
        specs = {false, false, true},
    },
-- Free Buffs
    {spell = 109964},   -- Spirit Shell
    {spell = 47585},    -- Dispersion
    {spell = 15286},    -- Vampiric Embrace
    {spell = 33206},    -- Pain Suppression
    {spell = 10060},    -- Power Infusion
    {spell = 47788},    -- Guardian Spirit
    {spell = 62618},    -- Power Word: Barrier
    {spell = 6346},     -- Fear Ward
    {spell = 114239},   -- Phantasm
    {spell = 119032},   -- Spectral Guise
    {spell = 27827},    -- Spirit of Redemption
-- Free Debuffs
    {spell = 14914, auraType = "debuff"}, -- Holy Fire
    {spell = 64044, auraType = "debuff"}, -- Psychic Horror

},  -- PRIEST -------------------


["ROGUE"] = { ------------------

-- Static Buffs
    {   -- Slice and Dice
        type = "SliceAndDice",
        order = 1,
    },
    {   -- Bandit's Guile (Combat)
        type = "BanditsGuile",
        order = 2,
    },
    {   -- Shadow Dance (Sub)
        spell = 51713,
        order = 2,
        specs = {false, false, true},
    },
    {   -- Envenom (Ass)
        spell = 32645,
        specs = {true, false, false},
        order = 2,
    },
-- Static Debuffs
    {   -- Rupture
        type = "Rupture",
        order = 1,
    },
    {   -- Revealing Strike (Comb)
        spell = 84617,
        auraType = "debuff",
        specs = {false, true, false},
        order = 2,
    },
    {   -- Find Weakness (Sub)
        auraType = "debuff",
        spell = 91021,
        minLevel = 10,
        order = 2,
        specs = {false, false, true},
    },
-- Free Buffs
    {spell = 73651},    -- Recuperate
    {spell = 108212},   -- Burst of Speed
    {spell = 13750},    -- Adrenaline Rush
    {spell = 13877},    -- Blade Flurry
    {spell = 2983},     -- Sprint
    {spell = 5277},     -- Evasion
    {spell = 108208},   -- Subterfuge
    {spell = 121153},   -- Blindside
    {spell = 57933},    -- TotT
    {spell = 31223},    -- Master of Subtlety
    {spell = 31224},    -- Cloak of Shadows
    {spell = 45182},    -- Cheating Death
    {spell = 114018},   -- Shroud of Concealment
    {spell = 11327},    -- Vanish
    {spell = 137619},   -- Marked for Death
    {spell = 1966},     -- Feint
    {spell = 74002},    -- Combat Insight
-- Free Debuffs
    {spell = 16511, auraType = "debuff"},   -- Hemorrhage
    {spell = 79140, auraType = "debuff"},   -- Vendetta
    {spell = 703, auraType = "debuff"},     -- Garrote
    {spell = 108210, auraType = "debuff"},  -- Nerve Strike

},  -- ROGUE ------------------


["SHAMAN"] = { ------------------

-- Static Buffs
    {   -- Maelstrom Weapon (Enh)
        spell = 65986,
        minLevel = 83,
        order = 1,
        specs = {false, true, false}
    },
    {   -- Tidal Waves (Resto)
        spell = 53390,
        minLevel = 50,
        order = 1,
        specs = {false, false, true}
    },
-- Static Debuffs
    {   -- Flame Shock (Enh, Ele)
        spell = 8050,
        auraType = "debuff",
        order = 1,
        specs = {true, true, false}
    },
    {   -- Frost Shock (Enh, Ele)
        spell = 8056,
        auraType = "debuff",
        order = 2,
        specs = {true, true, false}
    },
-- Free Buffs
    {   -- Lightning Shield (Ele) (Fulmination)
        spell = 324,
        minLevel = 20,
        hideOOC = true,
        specs = {true, false, false}
    },
    {spell = 30823},    -- Shamanistic Rage
    {spell = 73683},    -- Unleash Flame
    {spell = 73681},    -- Unleash Wind
    {spell = 79206},    -- Spiritwalker's Grace
    {spell = 61295},    -- Riptide
    {spell = 98007},    -- Spirit Link Totem
    {spell = 108271},   -- Astral Shift
    {spell = 16188},    -- Ancestral Swiftness
    {spell = 2825},     -- Bloodlust
    {spell = 8178},     -- Grounding Totem Effect
    {spell = 58875},    -- Spirit Walk
    {spell = 108281},   -- Ancestral Guidance
    {spell = 16166},    -- Elemental Mastery (talent)
    {spell = 114896},   -- Windwalk Totem
    {spell = 114049},   -- Ascendance
-- Free Debuffs
    {spell = 8050, auraType = "debuff", specs = {false, false, true}},  -- Flame Shock (Resto)
    {spell = 8056, auraType = "debuff", specs = {false, false, true}},  -- Frost Shock (Resto)
    {spell = 17364, auraType = "debuff"},   -- Stormstrike
    
},  -- SHAMAN ------------------


["WARLOCK"] = { ------------------

-- Static Buffs
    {   -- Molten Core (Demo)
        spell = {140074, 122355}, -- Green Fire, Normal
        minLevel = 69,
        order = 1,
        specs = {false, true, false}
    },
    {   -- Burning Embers (Dest)
        type = "BurningEmbers",
        order = 1,
    },
-- Static Debuffs
    {   -- Corruption (Aff, Demo)
        spell = 146739,
        auraType = "debuff",
        minLevel = 3,
        order = 1,
        specs = {true, true, false}
    },
    {   -- Doom (Demo)
        spell = 603,
        auraType = "debuff",
        minLevel = 36,
        order = 2,
        specs = {false, true, false}
    },
    {   -- Unstable Affliction (Aff)
        spell = 30108,
        auraType = "debuff",
        minLevel = 10,
        order = 2,
        specs = {true, false, false}
    },
    {   -- Agony, Doom (Aff)
        spell = {980,603},
        auraType = "debuff",
        minLevel = 36,
        order = 3,
        specs = {true, false, false}
    },
    {   -- Immolate (Dest)
        spell = 157736,
        auraType = "debuff",
        minLevel = 12,
        order = 1,
        specs = {false, false, true}
    },

-- Free Buffs
    {spell = 110913},   -- Dark Bargain
    {spell = 108359},   -- Dark Regeneration
    {spell = 113860},   -- Dark Soul: Misery
    {spell = 113861},   -- Dark Soul: Knowledge
    {spell = 113858},   -- Dark Soul: Instability
    {spell = 88448},    -- Demonic Rebirth
    {spell = 104773},   -- Unending Resolve

-- Free Debuffs
    {spell = 27243, auraType = "debuff"},   -- Seed of Corruption
    {spell = 48181, auraType = "debuff"},   -- Haunt
    {spell = 80270, auraType = "debuff"},   -- Shadowflame
    {spell = 17962, auraType = "debuff"},   -- Conflagrate
    {spell = 80240, auraType = "debuff"},   -- Havoc
    {spell = 17877, auraType = "debuff"},   -- Shadowburn
    {spell = 108505, auraType = "debuff"},  -- Archimonde's Vengeance

},  -- WARLOCK ------------------


["WARRIOR"] = { ------------------

-- Static Buffs
    {   -- Enrage (Arms, Fury)
        spell = 12880,
        minLevel = 14,
        order = 1,
        specs = {true, true, false},
    },
    {   -- Raging Blow! (Fury)
        spell = 131116,
        minLevel = 30,
        order = 2,
        specs = {false, true, false},
    },
-- Static Debuffs
    --[[{   -- Weakened Armor
        spell = 113746,
        auraType = "debuff",
        minLevel = 16,
        order = 1,
        anyone = true,
    },]]
-- Free Buffs
    {spell = 169686},   -- Unyielding Strikes
    {spell = 118038},   -- Die by the Sword
    {spell = 55694},    -- Enraged Regeneration
    {spell = 97463},    -- Rallying Cry
    {spell = 12975},    -- Last Stand
    {spell = 114029},   -- Safeguard
    {spell = 871},      -- Shield Wall
    {spell = 114030},   -- Vigilance
    {spell = 18499},    -- Berserker Rage
    {spell = 1719},     -- Recklessness
    {spell = 23920},    -- Spell Reflection
    {spell = 114028},   -- Mass Spell Reflection
    {spell = 46924},    -- Bladestorm
    {spell = 3411},     -- Intervene
    {spell = 107574},   -- Avatar
    {spell = 12292},    -- Bloodbath
    {spell = 12950},    -- Meat Cleaver
-- Free Debuffs
    {spell = 86346, auraType = "debuff"},   -- Colossus Smash
    {spell = 1160, auraType = "debuff"},    -- Demoralizing Shout
    {spell = 1715, auraType = "debuff"},    -- Hamstring
    {spell = 12294, auraType = "debuff"},   -- Mortal Strike
    {spell = 64382, auraType = "debuff"},   -- Shattering Throw
    {spell = 6552, auraType = "debuff"},    -- Pummel
    
},  -- WARRIOR ------------------



}   -- defaults

-- function nibRealUI:GetAuraTrackingDefaults()
--  return {
--      profile = {
--          slotSize = 32,
--          padding = 1,
--          tracking = defaults,
--      },
--  }
-- end
