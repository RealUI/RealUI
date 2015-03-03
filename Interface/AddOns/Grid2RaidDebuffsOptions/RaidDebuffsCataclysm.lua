local RDDB= Grid2Options:GetRaidDebuffsTable()

RDDB["Cataclysm"] = {
	[754] = {
		["Magmaw"]= {
		order = 2, ejid = 170,
		89773, -- Mangle
		88287, -- Massive Crash
        78199, -- Sweltering Armor		
		},
		["Omnitron Defense System"]= {
		order = 1, ejid = 169,
		79889, -- Lightning Conductor
		80161, -- Chemical Cloud
		80011, -- Soaked in Poison
		91829, -- Fixate
        92053, -- Shadow Conductor
        92048, -- Shadow Infusion
        92023, -- Encasing Shadows		
		},
		["Maloriak"]= {
		order = 5, ejid = 173,
		78225, -- Acid Nova
		92910, -- Debilitating Slime
		77786, -- Consuming Flames
		91829, -- Fixate
		77760, -- Biting Chill
		77699, -- Flash Freeze
		},
		["Atremedes"]= {
		order = 3, ejid = 171,
		78092, -- Tracking
		77840, -- Searing
		78353, -- Roaring Flame
		78897, -- Noisy
		},
		["Chimaeron"]= {
		order = 4, ejid = 172,
		89084, -- Low Health
		82934, -- Mortality
		82881, -- Break
        91307, -- Mocking Shadows		
		},
		["Nefarian"]={
		order = 6, ejid = 174,
		77827, -- Tail Lash
        79339, -- Explosive Cinders
        79318, -- Dominion		
		},
	},
	[758] = {
		["Halfus Wyrmbreaker"]= {
		order = 1, ejid = 156,
		83710, -- Furious Roar		
		83908, -- Malevolent Strike
		83603, -- Stone Touch
		},
		["Valiona & Theralion"]= {
		order = 2, ejid = 157,
		86788, -- Blackout
		86360, -- Twilight Shift
        86014, -- Twilight Meteorite
		},
		["Ascendant Council"]= {
		order = 3, ejid = 158,
		82762, -- Waterlogged
		83099, -- Lightning Rod
		82285, -- Elemental Stasis
		82660, -- Burning Blood
		82665, -- Heart of Ice
        82772, -- Frozen
        84948, -- Gravity Crush
        83500, -- Swirling Winds
        83581, -- Grounded
        92307, -- Frost Beacon
		},
		["Cho'gall"]= {
		order = 4, ejid = 167,
        81836, -- Corruption: Accelerated
        82125, -- Corruption: Malformation
        82170, -- Corruption: Absolute		
		82523, -- Gall's Blast
		82518, -- Cho's Blast
		},
		["Sinestra"]= {
		order = 5, ejid = 168,
		89299, -- Twilight Spit
		},
	},
	[773] = {
		["Conclave of Wind"]= {
		order = 1, ejid = 154,
		84645, -- Wind Chill
		86107, -- Ice Patch
		86082, -- Permafrost
		84643, -- Hurricane
		86281, -- Toxic Spores
		85573, -- Deafening Winds
		85576, -- Withering Winds
		93057, -- Slicing Gale		
		},
		["Al'Akir"]= {
		order = 2, ejid = 155,
		88290, -- Acid Rain
		87873, -- Static Shock
		88427, -- Electrocute
		89668, -- Lightning Rod
        87856, -- Squall Line		
		},
	},
    [752] = {
        ["Argaloth"]= {
		order = 1, ejid = 139,
        88942, -- Meteor Slash
        88954, -- Consuming Darkness
        },
		["Occu'thar"] = {
		order = 2, ejid = 140,
		96913, -- Searing Shadows
		},
		["Alizabal"] = {
		order = 3, ejid = 339,
		104936, -- Skewer
		105067, -- Seething Hate
		},		
    },	
	[800] = {
		["Beth'tilac"]= {
		order = 1, ejid = 192,
		49026, -- Fixate
		97079, -- Seeping Venom
		97202, -- Fiery Web Spin
		99506, -- Widow Kiss
		},
		["Lord Rhyolith"]= {
		order = 2, ejid = 193,
		98492, -- Eruption
		},
		["Alysrazor"]= {
		order = 3, ejid = 194,
		100094, -- Fireblast
		99389,  -- Imprinted
		99308,  -- Gushing Wound
		100640, -- Harsh Winds
		100555, -- Souldering Roots
		},
		["Shannox"]= {
		order = 4, ejid = 195,
		99936,	-- Jagged Tear
		99837,  -- Crustal Prison
		99840,  -- Magma Rupture
		},
		["Baleroc"]= {
		order = 5, ejid = 196,
		99252,  -- Blaze of Glory
		99256,  -- Torment
		99516,  -- Count Down
		},
		["Majordomo Staghelm"]= {
		order = 6, ejid = 197,
		98443,  -- Fiery Cylcone
		98450,	-- Searing Seeds
		98535,  -- Leaping flames
		96993,  -- Stay Withdrawn
		},
		["Ragnaros"]= {
		order = 7, ejid = 198,
		99399,  -- Burning Wound
		100238, -- Magma Trap vulnerability
		98313,  -- Magma blast
		100460, -- Blazing Heat
		98981,  -- Lava Bolt
		99613,  -- Molten Blast
		},
		["Trash"]= {
		76622, -- Sunder Armor
		97151, -- Magma
		99610, -- Shockwave
		99693,  -- Dinner Time
		99695, -- Flaming Spear
		99800, -- Ensnare
		99993,  -- Fiery Blood
		100767, -- Melt Armor
		},		
	},
	[824] = {
		["Morchok"] = {
		order = 1, ejid = 311,
		103687, -- Crush Armor
		},
		["Hagara the Stormbinder"] = {
		order = 4, ejid = 317,
		104451,  -- Ice Tomb
		105285,  -- Target (next Ice Lance)
		105316,  -- Ice Lance
		105289,  -- Shattered Ice
		105259,  -- Watery Entrenchment	
		105465,  -- Lightning Storm
		105369,  -- Lightning Conduit
		},
		["Warmaster Blackhorn"] = {
		order = 6, ejid = 332,
		108046, -- Shockwave
		108043, -- Devastate
		107567, -- Brutal strike
		107558, -- Degeneration
		110214, -- Consuming Shroud
		},
		["Ultraxion"] = {
		order = 5, ejid = 331,
		106108, -- Heroic will
		106415, -- Twilight burst
		105927, -- Faded Into Twilight
		106369, -- Twilight shift
		},
		["Yor'sahj the Unsleeping"] = {
		order = 3, ejid = 325,
		104849, -- Void bolt
		109389, -- Deep Corruption
		105695, -- Fixate 
		},
		["Warlord Zon'ozz"] = {
		order = 2, ejid = 324,
		103434, -- Disrupting shadows
		},
		["Spine of Deathwing"] = {
		order = 7, ejid = 318,
		105563, -- Grasping Tendrils
		105490, -- Fiery Grip
		105479, -- Searing Plasma
		106199, -- Blood corruption: death
		106200, -- Blood corruption: earth
		106005, -- Degradation
		},
		["Madness of Deathwing"] = {
		order = 8, ejid = 333,
		106794, -- Shrapnel
		106385, -- Crush
		105841, -- Degenerative bite
		105445, -- Blistering heat
		},		
	}
}
