local RDDB= Grid2Options:GetRaidDebuffsTable()

RDDB["The Lich King"] = {
	["Naxxramas"] = {
		["Trash"]= {
		55314, --Strangulate
		},
		["Anub'Rekhan"]= {
		28786, --Locust Swarm (N, H)
		},
		["Grand Widow Faerlina"]= {
		28796, --Poison Bolt Volley (N, H)
		28794, --Rain of Fire (N, H)
		},
		["Maexxna"]= {
		28622,--Web Wrap (NH)
		54121, --Necrotic Poison (N, H)
		},
		["Noth the Plaguebringer"]= {
		29213, --Curse of the Plaguebringer (N, H)
		29214, --Wrath of the Plaguebringer (N, H)
		29212,--Cripple (NH)
		},
		["Heigan the Unclean"]= {
		29998, --Decrepit Fever (N, H)
		29310,--Spell Disruption (NH)
		},
		["Grobbulus"]= {
		28169,--Mutating Injection (NH)
		},
		["Gluth"]= {
		54378,--Mortal Wound (NH)
		29306,--Infected Wound (NH)
		},
		["Thaddius"]= {
		28084, --Negative Charge (N, H)
		28059, --Positive Charge (N, H)
		},
		["Instructor Razuvious"]= {
		55550, --Jagged Knife (NH)
		},
		["Sapphiron"]= {
		28522, --Icebolt (NH)
		28542, --Life Drain (N, H)
		},
		["Kel'Thuzad"]= {
		28410,--Chains of Kel'Thuzad (H)
		27819,--Detonate Mana (NH)
		27808,--Frost Blast (NH)
		},		
	},
	["The Eye of Eternity"] = {
		["Malygos"]= {
		56272, --Arcane Breath (N, H)
		57407, --Surge of Power (N, H)
		}
	},
	["The Obsidian Sanctum"] = {
		["Trash"]= {
		39647,--Curse of Mending
		58936,--Rain of Fire
		},
		["Sartharion"]= {
		60708,--Fade Armor (N, H)
		57491,--Flame Tsunami (N, H)
		},		
	},
	["The Ruby Sanctum"] = {
		["Baltharus the Warborn"]= {
		74502,--Enervating Brand
		},
		["General Zarithrian"]= {
		74367,--Cleave Armor
		},
		["Saviana Ragefire"]= {
		74452,--Conflagration
		},
		["Halion"]= {
		74562,--Fiery Combustion
		74567,--Mark of Combustion
		74792,--Soul Consumption
		74795,--Mark of Consumption
		},		
	},
	["Trial of the Crusader"] = {
		--Gormok the Impaler
		["Gormok the Impaler"]= {
		66331, --Impale(10, 25, 10H, 25H)
		66406, --Snobolled!
		},
		["Acidmaw"]= {
		66819, --Acidic Spew (10, 25, 10H, 25H)
		66821, --Molten Spew (10, 25, 10H, 25H)
		66823, --Paralytic Toxin (10, 25, 10H, 25H)
		66869,--Burning Bile
		},
		["Icehowl"]= {
		66770, --Ferocious Butt(10, 25, 10H, 25H)
		66689, --Arctic Breathe(10, 25, 10H, 25H)
		66683, --Massive Crash
		},
		["Lord Jaraxxus"]= {
		66532, --Fel Fireball (10, 25, 10H, 25H)
		66237, --Incinerate Flesh (10, 25, 10H, 25H)
		66242, --Burning Inferno (10, 25, 10H, 25H)
		66197, --Legion Flame (10, 25, 10H, 25H)
		66283, --Spinning Pain Spike
		66209, --Touch of Jaraxxus(H)
		66211, --Curse of the Nether(H)
		66333, --Mistress' Kiss (10H, 25H)
		},
		["Faction Champions"]= {
		65812, --Unstable Affliction (10, 25, 10H, 25H)
		--65960,--Blind
		--65801,--Polymorph
		--65543,--Psychic Scream
		--66054,--Hex
		--65809,--Fear
		},
		["The Twin Val'kyr"]= {
		67176,--Dark Essence
		67223,--Light Essence
		67282, --Dark Touch
		67297, --Light Touch
		67309, --Twin Spike (10, 25, 10H, 25H)
		},
		["Anub'arak"]= {
		67574,--Pursued by Anub'arak
		--66240, 67630, 68646, 68647,--Leeching Swarm (10, 25, 10H, 25H)
		66013, --Penetrating Cold (10, 25, 10H, 25H)
		67847, --Expose Weakness
		66012,--Freezing Slash
		67863,--Acid-Drenched Mandibles(25H)
		},		
	},
	["Ulduar"] = {
		["Trash"]= {
		62310, --Impale (N, H)
		63612, --Lightning Brand (N, H)
		63615, --Ravage Armor (NH)
		62283, --Iron Roots (N, H)
		63169, --Petrify Joints (N, H)
		},
		["Razorscale"]= {
		64771,--Fuse Armor (NH)
		},
		["Ignis the Furnace Master"]= {
		62548, --Scorch (N, H)
		62680, --Flame Jet (N, H)
		62717, --Slag Pot (N, H)
		},
		["XT-002"]= {
		63024, --Gravity Bomb (N, H)
		63018, --Light Bomb (N, H)
		},
		["The Assembly of Iron"]= {
		61888, --Overwhelming Power (N, H)
		62269, --Rune of Death (N, H)
		61903, --Fusion Punch (N, H)
		61912, --Static Disruption(N, H)
		},
		["Kologarn"]= {
		64290, --Stone Grip (N, H)
		63355, --Crunch Armor (N, H)
		62055, --Brittle Skin (NH)
		},
		["Hodir"]= {
		62469, --Freeze (NH)
		61969, --Flash Freeze (N, H)
		62188, --Biting Cold (NH)
		},
		["Thorim"]= {
		62042, --Stormhammer (NH)
		62130, --Unbalancing Strike (NH)
		62526, --Rune Detonation (NH)
		62470, --Deafening Thunder (NH)
		62331, --Impale (N, H)
		},
		["Freya"]= {
		62532, --Conservator's Grip (NH)
		62589, --Nature's Fury (N, H)
		62861, --Iron Roots (N, H)
		},
		["Mimiron"]= {
		63666,--Napalm Shell (N)
		62997,--Plasma Blast (N)
		64668,--Magnetic Field (NH)
		},
		["General Vezax"]= {
		63276,--Mark of the Faceless (NH)
		63322,--Saronite Vapors (NH)
		},
		["Yogg-Saron"]= {
		63147,--Sara's Anger(NH)
		63134,--Sara's Blessing(NH)
		63138,--Sara's Fervor(NH)
		63830,--Malady of the Mind (H)
		63802,--Brain Link(H)
		63042,--Dominate Mind (H)
		64152,--Draining Poison (H)
		64153,--Black Plague (H)
		64125,--Squeeze (N, H)
		64156,--Apathy (H)
		64157,--Curse of Doom (H)
		--63050,--Sanity(NH)
		},
		["Algalon"]= {
		64412,--Phase Punch
		},		
	},
	["Vault of Archavon"] = {
		["Koralon"]= {
		67332,--Flaming Cinder (10, 25)
		},
		["Toravon the Ice Watcher"]= {
		72004,--Frostbite
		},
	},
	["Icecrown Citadel"] = {
		["Trash"]= {
		70980,--Web Wrap
		70450,--Blood Mirror
		71089,--Bubbling Pus
		69483,--Dark Reckoning
		71163,--Devour Humanoid
		71127,--Mortal Wound
		70435,--Rend Flesh
		70671,--Leeching Rot
		70432,--Blood Sap
		71257,--Barbaric Strike
		--71298,--Banish
		},
		["Lord Marrowgar"]= {
		70823,--Coldflame
		69065,--Impaled
		70835,--Bone Storm
		},
		["Lady Deathwhisper"]= {
		72109,--Death and Decay
		71289,--Dominate Mind
		71204,--Touch of Insignificance
		67934,--Frost Fever
		71237,--Curse of Torpor
		72491,--Necrotic Strike
		},
		["Gunship Battle"]= {
		69651,--Wounding Strike
		},
		["Deathbringer Saurfang"]= {
		72293,--Mark of the Fallen Champion
		72442,--Boiling Blood
		72449,--Rune of Blood
		72769,--Scent of Blood (heroic)
		},
		["Festergut"]= {
		69290,--Blighted Spore
		69248,--Vile Gas?
		71218,--Vile Gas?
		72219,--Gastric Bloat
		69278,-- Gas Spore
		},
		["Rotface"]= {
		69674,--Mutated Infection
		71215,--Ooze Flood
		69508,--Slime Spray
		30494,--Sticky Ooze
		},
		["Professor Putricide"]= {
		70215,--Gaseous Bloat
		72549,--Malleable Goo
		72454,--Mutated Plague
		70341,--Slime Puddle (Spray)
		70342,--Slime Puddle (Pool)
		70911,--Unbound Plague
		69774,--Volatile Ooze Adhesive
		},
		["Blood Prince Council"]= {
		72999,--Shadow Prison
		71807,--Glittering Sparks
		71911,--Shadow Resonance
		},
		["Blood-Queen Lana'thel"]= {
		70838,--Blood Mirror
		71623,--Delirious Slash
		70949,--Essence of the Blood Queen (hand icon)
		72151,--Frenzied Bloodthirst (bite icon)
		71340,--Pact of the Darkfallen
		72985,--Swarming Shadows (pink icon)
		70923,--Uncontrollable Frenzy
		},
		["Valithria Dreamwalker"]= {
		70873,--Emerald Vigor
		70744,--Acid Burst
		70751,--Corrosion
		70633,--Gut Spray
		71941,--Twisted Nightmares
		70766,--Dream State
		},
		["Sindragosa"]= {
		70107,--Permeating Chill
		70106,--Chilled to the Bone
		69766,--Instability
		71665,--Asphyxiation
		70126,--Frost Beacon
		70157,--Ice Tomb
		},
		["Lich King"]= {
		72133,--Pain and Suffering
		68981,--Remorseless Winter
		69242,--Soul Shriek
		69409,--Soul Reaper
		70541,--Infest
		27177,--Defile
		68980,--Harvest Soul
		},
	},
}	