local RDDB = Grid2Options:GetRaidDebuffsTable()
RDDB["Mists of Pandaria"] = {
	[897] = { --Heart of Fear
		["Trash"] = { 
		},
		["Imperial Vizier Zor'lok"] = {
		order = 1, ejid = 745,
		122760, --Exhale
		123812, --Pheromones of Zeal
		122740, --Convert
		122706, --Noise Cancelling
		},
		["Blade Lord Ta'yak"] = {
		order = 2, ejid = 744,
		122949, --Unseen Strike
		123474, --Overwhelming Assault
		124783, --Storm Unleashed
		123600, --Storm Unleashed?        
		},
		["Garalon"] = {
		order = 3, ejid = 713,
		122835, --Pheromones
		123081, --Pungency
		123120, --Pheromone Trail        
		},
		["Wind Lord Mel'jarak"] = {
		order = 4, ejid = 741,
		29212,--Cripple (NH)
		121881, --Amber Prison
		122055, --Residue
		122064, --Corrosive Resin        
		},
		["Amber-Shaper Un'sok"] = {
		order = 5, ejid = 737,
		121949, --Parasitic Growth
		122784, --Reshape Life
		122064, --Corrosive Resin
		122504, --Burning Amber        
		},
		["Grand Empress Shek'zeer"] = {
		order = 6, ejid = 743,
		125390, --Fixate
		123707, --Eyes of the Empress
		123788, --Cry of Terror
		124097, --Sticky Resin
		125824, --Trapped!
		124777, --Poison Bomb
		124821, --Poison-Drenched Armor
		124827, --Poison Fumes
		124849, --Consuming Terror
		124863, --Visions of Demise
		124862, --Visions of Demise: Target
		123845, --Heart of Fear: Chosen
		123846, --Heart of Fear: Lure        
		},
	},
	[896] = { --Mogu'shan Vaults
		["Trash"] = {
		118562, --Petrified
		116596, --Smoke Bomb
		},
		["The Stone Guard"] = {
		order = 1, ejid = 679,
		130395, --Jasper Chains: Stacks
		130404, --Jasper Chains
		130774, --Amethyst Pool
		116038, --Jasper Petrification
		115861, --Cobalt Petrification
		116060, --Amethyst Petrification
		116281, --Cobalt Mine Blast (dispellable)
		125206, --Rend Flesh: Tank only
		116008, --Jade Petrification
		},
		["Feng The Accursed"] = {
		order = 2, ejid = 689,
		131788, --Lightning Lash: Tank Only: Stacks
		116040, --Epicenter
		116942, --Flaming Spear: Tank Only
		116784, --Wildfire Spark
		131790, --Arcane Shock: Stack : Tank Only
		102464, --Arcane Shock: AOE
		116417, --Arcane Resonance
		116364, --Arcane Velocity
		116374, --Lightning Charge: Stun effect
		131792, --Shadowburn: Tank only: Stacks: HEROIC ONLY
		},
		["Gara'jal the Spiritbinder"] = {
		order = 3, ejid = 682,
		122151, --Voodoo doll: Super Super Important! Like Holy jesus important!
		117723, --Frail Soul: HEROIC ONLY
		116260, --Crossed Over
		},
		["The Spirit Kings"] = {
		order = 4, ejid = 687,
		118303, --Undying Shadow: Fixate
		118048, --Pillaged
		118135, --Pinned Down
		118047, --Pillage: Target
		118163, --Robbed Blind
		},
		["Elegon"] = {
		order = 5, ejid = 726,
		117878, --Overcharged
		117949, --Closed circuit (dispellable)
		117945, --Arcing Energy
		},
		["Will of the Emperor"] = {
		order = 6, ejid = 677,
		116525, --Focused Assault
		116778, --Focused Defense
		117485, --Impeding Thrust
		116550, --Energizing Smash
		116829, --Focused Energy
		},
	},
	[809] = { --Kun-Lai Summit
		["Sha of Anger"] = {
		ejid = 691,
		119626, --Aggressive Behavior [NOTE: this is the MC]
		119488, --Unleashed Wrath [NOTE: Must heal these people. Lots of shadow dmg]
		119610, --Bitter Thoughts (Silence)
		119601, --Bitter Thoughts (Silence)
		},        
	},
	[886] = { --Terrace of Endless Spring
		["Trash"] = {
		},
		["Protector Kaolan"] = {
		order = 1, ejid = 683,
		117519, --Touch of Sha
		111850, --Lightning Prison: Targeted
		117436, --Lightning Prison: Stunned
		118191, --Corrupted Essence
		117986, --Defiled Ground: Stacks
		},
		["Tsulong"] = {
		order = 2, ejid = 742,
		122768, --Dread Shadows
		122777, --Nightmares (dispellable)
		122752, --Shadow Breath
		122789, --Sunbeam
		123012, --Terrorize: 5% (dispellable)
		123011, --Terrorize: 10% (dispellable)
		123036, --Fright (dispellable)
		122858, --Bathed in Light
		},
		["Lei Shi"] = {
		order = 3, ejid = 729,
		123121, --Spray
		123705, --Scary Fog
		},
		["Sha of Fear"] = {
		order = 4, ejid = 709,
		119414, --Breath of Fear
		129147, --Onimous Cackle
		119983, --Dread Spray
		120669, --Naked and Afraid
		75683, --Waterspout
		120629, --Huddle in Terror
		120394, --Eternal Darkness
		129189, --Sha Globe
		119086, --Penetrating Bolt
		119775, --Reaching Attack
		},        
	},
	[930] = { --Throne of Thunder
		["Trash"] = {
		},
		["Jin'rokh the Breaker"] = {
		order = 1, ejid = 827,
		138349, --Static Wound
		137399, --Focused Lightning
		138733, --Ionization
		138002, --Fluidity
		},
		["Horridon"] = {
		order = 2, ejid = 819,
		136767, --Triple Puncture
		136708, --Stone Gaze
		136719, --Blazing Sunlight
		136654, --Rending Charge
		136587, --Venom Bolt Volley
		136512, --Hex of Confusion
		140946, --Dire Fixation
		136710, --Deadly Plague
		},
		["Council of Elders"] = {
		order = 3, ejid = 816,
		137650, --Shadowed Soul
		137085, --Chilled to the Bone
		136922, --Frostbite
		136917, --Biting Cold
		136903, --Frigid Assault
		136857, --Entrapped
		137359, --Marked Soul
		137891, --Twisted Fate
		},
		["Tortos"] = {
		order = 4, ejid = 825,
		137552, --Crystal Shell
		},
		["Megaera"] = {
		order = 5, ejid = 821,
		139822, --Cinders
		137731, --Ignite Flesh
		139866, --Torrent of Ice
		139841, --Arctic Freeze
		134378, --Acid Rain
		139839, --Rot Armor
		140179, --Suppression
		139994, --Diffusion
		},
		["Ji-Kun"] = {
		order = 6, ejid = 828,
		140092, --Infected Talons
		134256, --Slimed
		138319, --Feed Pool
		134366, --Talon Rake
		140014, --Daedelian Wings
		},
		["Durumu the Forgotten"] = {
		order = 7, ejid = 818,
		133767, --Serious Wound
		133768, --Arterial Cut
		134755, --Eye Sore
		136413, --Force of Will
		133795, --Life Drain
		133597, --Dark Parasite
		133598, --Dark Plague
		134007, --Devour
		},
		["Primordius"] = {
		order = 8, ejid = 820,
		136050, --Malformed Blood
		140546, --Fully Mutated
		137000, --Black Blood
		136228, --Volatile Pathogen
		},
		["Dark Animus"] = {
		order = 9, ejid = 824,
		138609, --Matter Swap
		138569, --Explosive Slam
		138659, --Touch of the Animus
		136954, --Anima Ring
		},
		["Iron Qon"] = {
		order = 10, ejid = 817,
		134691, --Impale
		134647, --Scorched
		136193, --Arcing Lightning
		135145, --Freeze
		},
		["Twin Consorts"] = {
		order = 11, ejid = 829,
		137341, --Beast of Nightmares
		137360, --Corrupted Healing
		137408, --Fan of Flames
		137440, --Icy Shadows
		},
		["Lei Shen"] = {
		order = 12, ejid = 832,
		134916, --Decapitate
		135150, --Crashing Thunder
		139011, --Helm of Command
		136478, --Fusion Slash
		136853, --Lightning Bolt
		136295, --Overcharged
		135703, --Static Shock
		},
		["Ra-den"] = {
		order = 13, ejid = 831,
		138308, --Unstable Vita
		138372, --Vita Sensitivity
		}
	},
	[929] = { --Isle of Giants
		["Oondasta"] = {
		ejid = 826,
		137504, --Crush
		},
	},
	[953] = { --Siege of Orgrimmar
		["Immerseus"] = {
		order = 1, ejid = 852,
		143436, --Corrosive Blast
		143574, --Swelling Corruption
		143459, --Sha Residue
		143524, --Purified Residue
		},
		["The Fallen Protectors"] = {
		order = 2, ejid = 849,
		143434, --Shadow Word: Bane
		143959, --Defiled Ground
		144007, --Residual Burn
		143019, --Corrupted Brew
		143010, --Corruption Kick
		144396, --Vengeful Strikes
		144176, --Shadow Weakness
		147383, --Debilitation
		143198, --Garrote
		143301, --Gouge
		143423, --Sha Sear
		143840, --Mark of Anguish
		},
		["Norushen"] = {
		order = 3, ejid = 866,
		146703, --Bottomless Pit
		146124, --Self Doubt
		146707, --Disheartening Laugh
		144514, --Lingering Corruption (Healer realm only)
		144452, --Purified
		144849, --Test of Serenity
		144850, --Test of Reliance
		144851, --Test of Confidence
		--145725, --Despair (LFR Only?)
		},
		["Sha of Pride"] = {
		order = 4, ejid = 867,
		144359, --Gift of the Titans
		144364, --Power of the Titans
		146817, --Aura of Pride
		144843, --Overcome
		144351, --Mark of Arrogance
		144358, --Wounded Pride
		144574, --Corrupted Prison
		145215, --Banishment
		145345, --Orb of Light
		119775, --Reaching Attack
		},
		["Galakras"] = {
		order = 5, ejid = 868,
		147705, --Poison Cloud
		146765, --Flame Arrows
		146902, --Poison-Tipped Blades
		147068, --Flames of Galakrond (on random focused player)
		147029, --Flames of Galakrond (aoe sphew)
		},
		["Iron Juggernaut"] = {
		order = 6, ejid = 864,
		144467, --Ignite Armor
		144459, --Laser Burn
		144498, --Explosive Tar
		146325, --Cutter Laser Target
		144918, --Cutter Laser
		},
		["Kor'kron Dark Shaman"] = {
		order = 7, ejid = 856,
		17153,  --Rend
		144215, --Froststorm Strike
		144089, --Toxic Mist
		144107, --Toxicity
		143990, --Foul Geyser
		144330, --Iron Prison
		},
		["General Nazgrim"] = {
		order = 8, ejid = 850,
		143431, --Magistrike
		143480, --Assassin's Mark
		1130,   --Hunter's Mark
		143638, --Bonecracker
		143494, --Sundering Blowt
		},
		["Malkorok"] = {
		order = 9, ejid = 846,
		142863, --Weak Ancient Barrier
		142864, --Ancient Barrier
		142865, --Strong Ancient Barrier
		142990, --Fatal Strike
		143919, --Languish
		142913, --Displaced Energy
		},
		["Spoils of Pandaria"] = {
		order = 10, ejid = 870,
		142944, --Return to Stone
		145993, --Set to Blow
		148760, --Pheromone Cloud
		145288, --Matter Scramble
		142947, --Crimson Reconstitution
		136885, --Torment
		145230, --Forbidden Magic
		144922, --Harden Flesh
		144853, --Carnivorous Bite
		145712, --Gusting Bomb
		142524, --Encapsulated Pheromones
		148510, --Shattered Armor
		},
		["Thok the Bloodthirsty"] = {
		order = 11, ejid = 851,
		23364,  --Tail Lash
		143452, --Bloodied
		133042, --Fixate
		143780, --Acid Breath
		143791, --Corrosive Blood
		143773, --Freezing Breath
		143800, --Icy Blood
		143767, --Scorching Breath
		82660,  --Burning Blood
		},
		["Siegecrafter Blackfuse"] = {
		order = 12, ejid = 865,
		143385, --Electrostatic Charge
		144236, --Pattern Recognition
		143856, --Superheated
		144466, --Magnetic Crush
		143828, --Locked On
		},
		["Paragons of the Klaxxi"] = {
		order = 13, ejid = 853,
			--Kil'ruk the Wind-Reaver
		142931, --Exposed Veins
		143939, --Gouge
			--Xaril the Poisoned Mind
		142532, --Toxin: Blue
		142533, --Toxin: Red
		142534, --Toxin: Yellow
		142315, --Caustic Blood
		142929, --Tenderizing Strikes
			--Kaz'tik the Manipulator
		142649, --Devour (Hungry Kunchongs)
		142671, --Mesmerize
			--Korven the Prime
		143974, --Shield Bash
			--Iyyokuk the Lucid
		142416, --Insane Calculation: Fiery Edge
			--Ka'roz the Locust
		143701, --Whirling
			--Skeer the Bloodseeker
		143275, --Hewn
			--Rik'kal the Dissector
		143339, --Injection
		143362, --Feed (Amber Parasite)
			--Hisek the Swarmkeeper
		142948, --Aim
		},
		["Garrosh Hellscream"] = {
		order = 14, ejid = 869,
		87704,  --Hamstring
		147324, --Crushing Fear
		149347, --Embodied Doubt
		147342, --Ultimate Despair
		145065, --Touch of Y'Shaarj
		145171, --Empowered Touch of Y'Shaarj
		145183, --Gripping Despair
		145195, --Empowered Gripping Despair
		145199, --Explosive Despair
		},
		["Trash"] = {
		147200, --Fracture
		},
	},
	[951] = { --Timeless Isle
		["Ordos, Fire-God of the Yaungol"] = {
		ejid = 861,
		144689, --Burning Soul
		},
		["Chi-Ji, The Red Crane"] = {
		ejid = 857,
		},
		["Yu'lon, The Jade Serpent"] = {
		ejid = 858,
		144630, --Jadeflame Buffet
		},
		["Niuzao, The Black Ox"] = {
		ejid = 859,
		144607, --Oxen Fortitude
		},
		["Xuen, The White Tiger"] = {
		ejid = 860,
		144638, --Spectral Swipe
		},
	},
}
