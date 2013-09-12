local RDDB= Grid2Options:GetRaidDebuffsTable()

RDDB["Cataclysm"] = {
	[754] = {
		["[170-2]Magmaw"]= {
		89773, -- Mangle
		94679, -- Parasitic Infection
		88287, -- Massive Crash
        78199, -- Sweltering Armor		
		},
		["[169-1]Omnitron Defense System"]= {
		79889, -- Lightning Conductor
		80161, -- Chemical Cloud
		80011, -- Soaked in Poison
		91535, -- Flamethrower
		91829, -- Fixate
		92035, -- Acquiring Target
        92053, -- Shadow Conductor
        92048, -- Shadow Infusion
        92023, -- Encasing Shadows		
		},
		["[173-5]Maloriak"]= {
		92991, -- Rend
		78225, -- Acid Nova
		92910, -- Debilitating Slime
		77786, -- Consuming Flames
		91829, -- Fixate
		77760, -- Biting Chill
		77699, -- Flash Freeze
        92987, -- Dark Sludge
        92982, -- Engulfing Darkness		
		},
		["[171-3]Atremedes"]= {
		78092, -- Tracking
		77840, -- Searing
		78353, -- Roaring Flame
		78897, -- Noisy
		},
		["[172-4]Chimaeron"]= {
		89084, -- Low Health
		82934, -- Mortality
		88916, -- Caustic Slime
		82881, -- Break
        91307, -- Mocking Shadows		
		},
		["[174-6]Nefarian"]={
		94075, -- Magma
		77827, -- Tail Lash
        79339, -- Explosive Cinders
        79318, -- Dominion		
		},
	},
	[758] = {
		["[156-1]Halfus Wyrmbreaker"]= {
		83710, -- Furious Roar		
		83908, -- Malevolent Strike
		83603, -- Stone Touch
		},
		["[157-2]Valiona & Theralion"]= {
		86788, -- Blackout
		95639, -- Engulfing Magic
		86360, -- Twilight Shift
        86014, -- Twilight Meteorite
        92886, -- Twilight Zone		
		},
		["[158-3]Ascendant Council"]= {
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
        92467, -- Static Overload
        92538, -- Gravity Core		
		},
		["[167-4]Cho'gall"]= {
        81836, -- Corruption: Accelerated
        82125, -- Corruption: Malformation
        82170, -- Corruption: Absolute		
		93187, -- Corrupted Blood
		82523, -- Gall's Blast
		82518, -- Cho's Blast
		93134, -- Debilitating Beam
		},
		["[168-5]Sinestra"]= {
		89299, -- Twilight Spit
		92955, -- Wrack
		},
	},
	[773] = {
		["[154-1]Conclave of Wind"]= {
		84645, -- Wind Chill
		86107, -- Ice Patch
		86082, -- Permafrost
		84643, -- Hurricane
		86281, -- Toxic Spores
		85573, -- Deafening Winds
		85576, -- Withering Winds
		93057, -- Slicing Gale		
		},
		["[155-2]Al'Akir"]= {
		88290, -- Acid Rain
		87873, -- Static Shock
		88427, -- Electrocute
		89668, -- Lightning Rod
        87856, -- Squall Line		
		},
	},
    [752] = {
        ["[139-1]Argaloth"]= {
        88942, -- Meteor Slash
        88954, -- Consuming Darkness
        },
		["[140-2]Occu'thar"] = {
		96913, -- Searing Shadows
		},
		["[339-3]Alizabal"] = {
		104936, -- Skewer
		105067, -- Seething Hate
		},		
    },	
	[800] = {
		["[192-1]Beth'tilac"]= {
		49026, -- Fixate
		97079, -- Seeping Venom
		97202, -- Fiery Web Spin
		99506, -- Widow Kiss
		},
		["[193-2]Lord Rhyolith"]= {
		98492, -- Eruption
		},
		["[194-3]Alysrazor"]= {
		101729, -- Blazing Claw
		100094, -- Fireblast
		99389,  -- Imprinted
		99308,  -- Gushing Wound
		100640, -- Harsh Winds
		100555, -- Souldering Roots
		},
		["[195-4]Shannox"]= {
		99936,	-- Jagged Tear
		99837,  -- Crustal Prison
		99840,  -- Magma Rupture
		101208, -- Inmolation Trap
		},
		["[196-5]Baleroc"]= {
		99252,  -- Blaze of Glory
		99256,  -- Torment
		99403,  -- Tormented
		99516,  -- Count Down
		100908, -- Fiery Torment
		},
		["[197-6]Majordomo Staghelm"]= {
		98443,  -- Fiery Cylcone
		98450,	-- Searing Seeds
		98535,  -- Leaping flames
		96993,  -- Stay Withdrawn
		100210, -- Burning Orb
		},
		["[198-7]Ragnaros"]= {
		99399,  -- Burning Wound
		100293, -- Lava Wave
		100238, -- Magma Trap vulnerability
		98313,  -- Magma blast
		100460, -- Blazing Heat
		98981,  -- Lava Bolt
		100249, -- Combustion
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
		["[311-1]Morchok"] = {
		103687, -- Crush Armor
		},
		["[317-4]Hagara the Stormbinder"] = {
		104451,  -- Ice Tomb
		105285,  -- Target (next Ice Lance)
		105316,  -- Ice Lance
		105289,  -- Shattered Ice
		105259,  -- Watery Entrenchment	
		105465,  -- Lightning Storm
		105369,  -- Lightning Conduit
		},
		["[332-6]Warmaster Blackhorn"] = {
		109204, -- Twilight Barrage
		108046, -- Shockwave
		108043, -- Devastate
		107567, -- Brutal strike
		107558, -- Degeneration
		110214, -- Consuming Shroud
		},
		["[331-5]Ultraxion"] = {
		110068, -- Fading light 
		106108, -- Heroic will
		106415, -- Twilight burst
		105927, -- Faded Into Twilight
		106369, -- Twilight shift
		},
		["[325-3]Yor'sahj the Unsleeping"] = {
		104849, -- Void bolt
		109389, -- Deep Corruption
		105695, -- Fixate 
		},
		["[324-2]Warlord Zon'ozz"] = {
		103434, -- Disrupting shadows
		110306, -- Black Blood of Go'rath
		},
		["[318-7]Spine of Deathwing"] = {
		105563, -- Grasping Tendrils
		105490, -- Fiery Grip
		105479, -- Searing Plasma
		106199, -- Blood corruption: death
		106200, -- Blood corruption: earth
		106005, -- Degradation
		},
		["[333-8]Madness of Deathwing"] = {
		109603, -- Tetanus
		109632, -- Impale
		106794, -- Shrapnel
		106385, -- Crush
		105841, -- Degenerative bite
		105445, -- Blistering heat
		},		
	}
}
