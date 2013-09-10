local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST

do
	local data = {
		version = 5,
		key = "Ra-den",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Ra-den"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-RA DEN.BLP:35:35",
		triggers = {
			scan = {69473}, 
		},
		onactivate = {
			tracing = {69473},
			tracerstart = true,
			combatstop = true,
			defeat = {"(Wait!)"},
			unittracing = {"boss1"},
		},
		enrage = {
			time10n = 600,
			time25n = 600,
			time10h = 600,
			time25h = 600,
		},
		windows = {
			proxwindow = true,
			proxrange = 8,
		},
		userdata = {
			count = 0,
			stalker = 0,
			creation = 0,
			power = 0,
		},
		onstart = {
			{
				"alert",{"Creationcd", time = 2},
				"scheduletimer",{"timerPhase2Soon",2}, -- Better CPU than UNIT_HEALTH
			},
		},
		raidicons = {
			UnstableVita = {
				varname = SN[138297],
				type = "FRIENDLY",
				persist = 60,
				unit = "#5#",
				reset = 3,
				icon = 1,
			},
		},
		timers = {	
			timerUnstableVita = {
				{
					"alert","UnstableVitaFurthestCast",
					"scheduletimer",{"timerUnstableVita",0.5},
				},
			},
			timerPhase2Soon = {
				{
					"expect",{"&gethp|boss1&","<","43"},
					"alert","Phase2Soon",
					--"canceltimer",{"timerPhase2Soon"},
				},
				{
					"expect",{"&gethp|boss1&",">","43"},
					"scheduletimer",{"timerPhase2Soon",2},
				},
			},
		},		
		announces = {
			UnstableAnimasay = {
				varname = format(L.alert["%s %s %s"],SN[138288],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s"],SN[138288],L.alert["on"],L.alert["Me"]),
			},
		},		
		messages = {
			mHorror = {
				varname = format(L.alert["%s (2)"],SN[138338]),
				type = "message",
				text = format(L.alert["%s (<count>)"],SN[138338]),
				color1 = "RED",
				icon = ST[138338],
				sound = "ALERT13",
				exdps = true,
			},	
			mStalker = {
				varname = format(L.alert["%s (2)"],SN[138339]),
				type = "message",
				text = format(L.alert["%s (<stalker>)"],SN[138339]),
				color1 = "RED",
				icon = ST[138339],
				sound = "ALERT13",
				exdps = true,
			},
			mCreation = {
				varname = format(L.alert["%s (2)"],SN[138321]),
				type = "message",
				text = format(L.alert["%s (<creation>)"],SN[138321]),
				color1 = "ORANGE",
				icon = ST[138321],
				sound = "ALERT13",
				exdps = true,
			},				
			mMurderousStrike = {
				varname = format(L.alert["%s"],SN[138333]),
				type = "message",
				text = format(L.alert["%s"],SN[138333]),
				color1 = "RED",
				icon = ST[138333],
				sound = "ALERT13",
				exdps = true,
			},
			mFatalStrike = {
				varname = format(L.alert["%s %s %s"],SN[138334],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[138334],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[138334],
				sound = "ALERT13",
				exdps = true,
			},	
			mUnstableVita = {
				varname = format(L.alert["%s %s %s"],SN[138297],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[138297],L.alert["on"]),
				color1 = "GREEN",
				icon = ST[138297],
				sound = "ALERT13",
			},				
		},
		alerts = {
			Creationcd = {
				varname = format(L.alert["%s Cooldown"],SN[138321]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[138321]),
				time = 32.5,
				time2 = 11,
				color1 = "GREEN",
				icon = ST[138321],
			},
			CallEssencecd = {
				varname = format(L.alert["%s Cooldown"],SN[139071]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[139071]),
				time = 15,
				color1 = "NEWBLUE",
				icon = ST[139071],
			},
			MurderousStrikecd = {
				varname = format(L.alert["%s Cooldown"],SN[138333]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[138333]),
				time = 35,
				time2 = 25,
				time3 = 15,
				time4 = 5,
				color1 = "RED",
				icon = ST[138333],
				exhealer = true,
				exdps = true,
			},
			FatalStrikecd = {
				varname = format(L.alert["%s Cooldown"],SN[138334]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[138334]),
				time = 10,
				time2 = 8,
				time3 = 6,
				time4 = 5,				
				color1 = "INDIGO",
				icon = ST[138334],
				exdps = true,
			},
			CracklingStalkercd = {
				varname = format(L.alert["%s Cooldown"],SN[138339]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[138339]),
				time = 40,
				color1 = "NEWBLUE",
				icon = ST[138339],
			},
			AddsHorrorcd = {
				varname = format(L.alert["%s Cooldown"],SN[138338]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[138338]),
				time = 8,
				color1 = "NEWBLUE",
				icon = ST[138338],
			},		
			-- Alert
			Phase2 = {
				varname = format(L.alert["Phase 2"]),
				type = "simple",
				text = format(L.alert["Phase 2"]),
				time = 2,
				color1 = "ORANGE",
				icon = ST[138333],
				sound = "ALERT13",
			},
			Phase2Soon = {
				varname = format(L.alert["%s %s"],L.alert["Phase 2"],L.alert["Soon"]),
				type = "simple",
				text = format(L.alert["%s %s"],L.alert["Phase 2"],L.alert["Soon"]),
				time = 2,
				color1 = "ORANGE",
				icon = ST[138333],
				sound = "ALERT13",
			},				
			wHorror = {
				varname = format(L.alert["%s %s"],SN[138338],L.alert["Incoming"]),
				type = "simple",
				text = format(L.alert["%s %s"],SN[138338],L.alert["Incoming"]),
				time = 2,
				color1 = "BROWN",
				icon = ST[138338],
				sound = "ALERT11",
			},	
			wStalker = {
				varname = format(L.alert["%s %s"],SN[138339],L.alert["Incoming"]),
				type = "simple",
				text = format(L.alert["%s %s"],SN[138339],L.alert["Incoming"]),
				time = 2,
				color1 = "PURPLE",
				icon = ST[138339],
				sound = "ALERT11",
			},		
			wCreation = {
				varname = format(L.alert["%s %s"],SN[138321],L.alert["Incoming"]),
				type = "simple",
				text = format(L.alert["%s %s"],SN[138321],L.alert["Incoming"]),
				time = 2,
				color1 = "ORANGE",
				icon = ST[138321],
				sound = "ALERT11",
			},			
			wCorruptedAnima = {
				varname = format(L.alert["%s"],SN[139071]),
				type = "simple",
				text = format(L.alert["%s"],SN[139071]),
				time = 2,
				color1 = "RED",
				icon = ST[139071],
				sound = "ALERT11",
			},
			AnimaSensitivityself = {
				varname = format(L.alert["%s %s %s!"],SN[139318],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[139318],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[139318],
			},	
			VitaSensitivityself = {
				varname = format(L.alert["%s %s %s!"],SN[138372],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[138372],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[138372],
			},	
			UnstableAnimaself = {
				varname = format(L.alert["%s %s %s!"],SN[138288],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[138288],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[138288],
			},
			UnstableVitaself = {
				varname = format(L.alert["%s %s %s!"],SN[138297],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[138297],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = ST[138297],
			},			
			-- Cast
			UnstableVitaCast = {
				varname = format(L.alert["%s Active"],SN[138297]),
				type = "centerpopup",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[138297]),
				text2 = format(L.alert["#5#: %s"],SN[138297]),
				time = 5,
				color1 = "NEWBLUE",
				icon = ST[138297],
				tag = "#5#",
				exdps = true,
			},
			SummonCracklingStalkercd = {
				varname = format(L.alert["%s Active"],SN[138339]),
				type = "dropdown",
				text = format(L.alert["%s Active"],SN[138339]),
				time = 8,
				color1 = "NEWBLUE",
				icon = ST[138339],
			},		
			UnstableVitaFurthestCast = {
				varname = format(L.alert["%s %s %s"],L.alert["player"],L.alert["furthest"],SN[138297]),
				type = "centerpopup",
				text = format(L.alert["&HighestDistance|#5#& %s %s"],L.alert["furthest"],SN[138297]),
				time = 12,
				color1 = "INDIGO",
				icon = ST[138297],
				tag = "#5#",
				static = true,
			},			
			-- Debuff
			AnimaDebuff = {
				varname = format(L.alert["%s Debuff"],SN[138288]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[138288]),
				text2 = format(L.alert["#5#: %s"],SN[138288]),
				time = 5,
				color1 = "NEWBLUE",
				icon = ST[138288],
				tag = "#5#",
				exdps = true,
			},
		},
		events = {
			-- Anima
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 138331,
				execute = {
					{
						"batchquash",{"FatalStrikecd","CracklingStalkercd","AnimaDebuff"},
						"batchalert",{"MurderousStrikecd","AddsHorrorcd"},
					},
				},
			}, 
			-- Vita
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 138332,
				execute = {
					{
						"batchquash",{"MurderousStrikecd","AddsHorrorcd"},
						"batchalert",{"FatalStrikecd","SummonCracklingStalkercd"},
					},
				},
			}, 
			-- Anima Sensitivity
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 139318,
				dstisplayerunit = true,
				execute = {
					{
						"alert","AnimaSensitivityself",
					},
				},
			},
			-- Vita Sensitivity
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 138372,
				dstisplayerunit = true,
				execute = {
					{
						"alert","VitaSensitivityself",
					},
				},
			},
			-- Unstable Anima
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 138288,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"batchalert",{"UnstableAnimaself","AnimaDebuff"},
						"announce","UnstableAnimasay",
					},				
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"AnimaDebuff", text = 2},
					},
				},
			},
			-- Unstable Vita
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {138297, 138308},
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"batchalert",{"UnstableVitaself","UnstableVitaCast"},
					},				
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"UnstableVitaCast", text = 2},
					},
					{
						"message","mUnstableVita",
						"raidicon","UnstableVita",
						"canceltimer","timerUnstableVita",
						"scheduletimer",{"timerUnstableVita",0.5},						
					},				
				},
			},		
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {138297, 138308},
				execute = {
					{
						"canceltimer","timerUnstableVita",
						"quash","UnstableVitaFurthestCast",
						"removeraidicon","#5#",
					},
				},
			},	
			-- Horror Adds
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 138338,
				execute = {
					{
						"set",{count = "INCR|1"},
						"alert","wHorror",
						"message","mHorror",
					},
				},
			},	
			-- Stalker
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 138339,
				execute = {
					{
						"set",{stalker = "INCR|1"},
						"batchalert",{"wStalker","CracklingStalkercd"},
						"message","mStalker",
					},
				},
			},
			-- Creation
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 138321,
				execute = {
					{
						"set",{creation = "INCR|1"},
						"batchalert",{"wCreation","Creationcd"},
						"message","mCreation",
					},
				},
			},					
			-- MurderousStrike
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {138333},
				execute = {
					{
						"message","mMurderousStrike",
						"alert","MurderousStrikecd",
					},
				},
			},
			-- FatalStrike
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {138334},
				execute = {
					{
						"message","mFatalStrike",
					},
				},
			},			
			{
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
					{
						"expect",{"#1#","==","boss1"},
						"invoke",{
							{
								"expect",{"#5#","==","139040"}, -- Call Essence
								"batchalert",{"CallEssencecd","wCorruptedAnima"},
							},
							{
								"expect",{"#5#","==","139073"}, -- Phase2
								"batchquash",{"CracklingStalkercd","MurderousStrikecd","FatalStrikcd","Creationcd"},
								"batchalert",{"CallEssencecd","Phase2"},
							},
						},
					},
				},
			},
			{
                type = "event",
                event = "UNIT_POWER_FREQUENT",
                execute = {
					{
						"expect",{"#1#","==","boss1"},
						"set",{power = "&getup|boss1&"},
						"invoke",{
							{
								"expect",{"&targetbuff|#1#|"..SN[138331].."&","==","true"}, --Anima
								"invoke",{
									{
										"expect",{"<power>","==","30"},
										"alert",{"MurderousStrikecd", time = 2},
									},
									{
										"expect",{"<power>","==","60"},
										"alert",{"MurderousStrikecd", time = 3},
									},
									{
										"expect",{"<power>","==","90"},
										"alert",{"MurderousStrikecd", time = 4},
									},									
								},
							},
							{
								"expect",{"&targetbuff|#1#|"..SN[138332].."&","==","true"}, --Vita
								"invoke",{
									{
										"expect",{"<power>","==","20"},
										"alert",{"FatalStrikecd", time = 2},
									},
									{
										"expect",{"<power>","==","40"},
										"alert",{"FatalStrikecd", time = 3},
									},
									{
										"expect",{"<power>","==","50"},
										"alert",{"FatalStrikecd", time = 4},
									},									
								},
							},							
						},
					},
				},
			},
			--[[{
                type = "event",
                event = "UNIT_HEALTH",
                execute = {
					{
						"expect",{"#1#","==","boss1"},
						"invoke",{
							{
								"expect",{"&gethp|boss1&","<","43"},
								"alert","Phase2Soon",
							},
						},
					},
				},				
			},		--]]	
		},
	}

	DXE:RegisterEncounter(data)
end
