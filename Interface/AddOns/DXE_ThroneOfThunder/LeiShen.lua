local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST

do
	local data = {
		version = 11,
		key = "Lei Shen",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Lei Shen"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-LEI SHEN.BLP:35:35",
		--Diffusion Chain Conduit 68696, Static Shock Conduit 68398, Bouncing Bolt conduit 68698, Overcharge conduit 68697
		triggers = {
			scan = {68397}, 
		},
		onactivate = {
			tracing = {	
				68397,"boss2","boss3","boss4",
				powers={false,true,true,true},
				markers1 = {68,33},
			},
			tracerstart = true,
			combatstop = true,
			defeat = {	68397 },
			unittracing = {	"boss1","boss2","boss3","boss4"},
		},
		windows = {
			proxwindow = true,
			proxrange = 8,
		},
		enrage = {
			time10n = 720,
			time25n = 720,
			time10h = 720,
			time25h = 720,
			time25lfr = 900,
		},
		userdata = {
			supercharge = 0,
			north = 0, east = 0, south = 0, west = 0,
			phase = 1,
			warned = 0,
			staticicon = 8,
			transition = "no",
			staticshockunits = {type = "container", wipein = 3},
			overchargeunits = {type = "container", wipein = 3},
			helmofcommandunits = {type = "container", wipein = 3},
			overchargen = 0,
			range = 0,
			staticsay = 6,
			overchargesay = 5,
		},
		raidicons = {
			StaticShockicon = {
				varname = SN[135695],
				type = "MULTIFRIENDLY",
				persist = 12,
				reset = 3,
				unit = "#5#",
				icon = 1,
				total = 4,
			},
			Overchargeicon = {
				varname = SN[136295],
				type = "MULTIFRIENDLY",
				persist = 12,
				unit = "#5#",
				reset = 3,
				icon = 5,
				total = 4,
			},
		},
		arrows = {
			overchargearrow = {
				varname = SN[136295].." - "..L.alert["GO TO HIM!"],
				unit = "#5#",
				persist = 15,
				action = "TOWARD",
				msg = L.alert["GO TO HIM!"],
				spell = SN[136295],
				range1 = 5,
			},
			overchargearrowaway = {
				varname = SN[136295].." - "..L.alert["MOVE AWAY!"],
				unit = "#5#",
				persist = 15,
				action = "AWAY",
				msg = L.alert["MOVE AWAY!"],
				spell = SN[136295],
				range1 = 40,
				range2 = 41,
				range3 = 42,
			},
			staticarrow = {
				varname = SN[135695],
				unit = "#5#",
				persist = 15,
				action = "TOWARD",
				msg = L.alert["GO TO HIM!"],
				spell = SN[135695],
				range1 = 5,
			},
		},
		onstart = {
			{
				"alert",{"Thunderstruckcd", time = 2},
				"alert",{"Decapitatecd", time = 2},
				"scheduletimer",{"timerIntermission",1},
			},
		},
		timers = {	
			closewindows = {
				{
					"closewindow",
				},
			},
			liststaticshocks = {
				{
					"message","warnStaticShock",
				},
			},
			listovercharge = {
				{
					"message","warnOvercharged",
				},
			},
			listHelmofcommand = {
				{
					"message","warnHelmofcommand",
				},
			},
			overchargereset = {
				{
					"set",{overchargen = "0"},
				},
			},			
			timerIntermission = {
				{
					"expect",{"&gethp|boss1&","<","68"},
					"expect",{"<warned>","==","0"},
					"alert","IntermissionSoon",
					"set",{warned = 1},
				},
				{
					"expect",{"&gethp|boss1&","<","33"},
					"expect",{"<warned>","==","1"},
					"alert","IntermissionSoon",
					"set",{warned = 2},
				},
				{
					"expect",{"&gethp|boss1&",">","35"},
					"scheduletimer",{"timerIntermission",1},
				},
			},
			timerStaticShock = {
				{
					"set",{staticsay = "DECR|1"},
				},
				{
					"expect",{"<staticsay>",">","0"},
					"announce","staticshocksaycountdown",
					"scheduletimer",{"timerStaticShock",1},
				},
			},
			timerOvercharged = {
				{
					"set",{overchargesay = "DECR|1"},
				},
				{
					"expect",{"<overchargesay>",">","0"},
					"announce","overchargesaycountdown",
					"scheduletimer",{"timerOvercharged",1},
				},
			},			
		},
		announces = { 
			overchargesay = {
				varname = format(L.alert["%s %s %s!"],SN[136295],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s!"],SN[136295],L.alert["on"],L.alert["Me"]),
			},
			overchargesaycountdown = {
				varname = format(L.alert["%s %s 2"],SN[136295],L.alert["in"]),
				type = "SAY",
				msg = format(L.alert["%s %s <overchargesay>"],SN[136295],L.alert["in"]),
			},
			staticshocksay = {
				varname = format(L.alert["%s %s %s!"],SN[135695],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s!"],SN[135695],L.alert["on"],L.alert["Me"]),
			},
			staticshocksaycountdown = {
				varname = format(L.alert["%s %s 2"],SN[135695],L.alert["in"]),
				type = "SAY",
				msg = format(L.alert["%s %s <staticsay>"],SN[135695],L.alert["in"]),
			},			
		},
		messages = {
			warnHelmofcommand = {
				varname = format(L.alert["%s %s %s"],SN[139011],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s %s"],SN[139011],L.alert["on"],"&list|helmofcommandunits&"),
				color1 = "BROWN",
				icon = ST[139011],
				sound = "ALERT13",
			},
			warnStaticShock = {
				varname = format(L.alert["%s %s %s"],SN[135695],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s %s"],SN[135695],L.alert["on"],"&list|staticshockunits&"),
				color1 = "RED",
				icon = ST[135695],
				sound = "ALERT13",
			},
			warnDiffusionChain = {
				varname = format(L.alert["%s %s %s"],SN[135991],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[135991],L.alert["on"]),
				color1 = "MIDGREY",
				icon = ST[135991],
				sound = "ALERT13",
			},
			warnOvercharged = {
				varname = format(L.alert["%s %s %s"],SN[136295],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s %s"],SN[136295],L.alert["on"],"&list|overchargeunits&"),
				color1 = "TAN",
				icon = ST[136295],
				sound = "ALERT13",
			},
			warnDecapitate = {
				varname = format(L.alert["%s %s %s"],SN[135000],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[135000],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[135000],
				sound = "ALERT13",
				exdps = true,
			},
			warnElectricalShock = {
				varname = format(L.alert["%s %s %s"],SN[136914],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5# (#11#)"],SN[136914],L.alert["on"]),
				color1 = "BROWN",
				icon = ST[136914],
				sound = "ALERT13",
				exdps = true,
				throttle = 3,
			},
			warnBallLightningSoon = {
				varname = format(L.alert["%s"],SN[136543]),
				type = "message",
				text = format(L.alert["%s %s"],SN[136543],L.alert["soon"]),
				color1 = "ORANGE",
				icon = ST[136543],
				sound = "ALERT13",
			},			
		},
		alerts = {
			HelmOfCommandcd = {
				varname = format(L.alert["%s Cooldown"],SN[139011]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[139011]),
				time = 14,
				time2 = 24,
				color1 = "BROWN",
				icon = ST[139011],
			},
			StaticShockcd = {
				varname = format(L.alert["%s Cooldown"],SN[135695]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[135695]),
				time = 40,
				time2 = 19,
				time3 = 18,
				time4 = 14,
				time5 = 28,
				color1 = "NEWBLUE",
				icon = ST[135695],
			},
			DiffusionChaincd = {
				varname = format(L.alert["%s Cooldown"],SN[135991]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[135991]),
				time = 40,
				time2 = 6,
				time3 = 7,
				time4 = 25,
				time5 = 14,
				time6 = 28,
				color1 = "NEWBLUE",
				icon = ST[135991],
			},
			Overchargecd = {
				varname = format(L.alert["%s Cooldown"],SN[136295]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136295]),
				time = 40,
				time2 = 6,
				time3 = 14,
				time4 = 28,
				color1 = "NEWBLUE",
				icon = ST[136295],
			},
			BouncingBoltcd = {
				varname = format(L.alert["%s Cooldown"],SN[136366]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136366]),
				time = 39,
				time2 = 14,
				time3 = 20,
				time4 = 28,
				time5 = 24,
				color1 = "NEWBLUE",
				icon = ST[136366],
			},
			Phase2 = {
				varname = format(L.alert["Phase 2"]),
				type = "simple",
				text = format(L.alert["Phase 2"]),
				time = 2,
				color1 = "ORANGE",
				icon = ST[136850],
				sound = "ALERT13",
			},
			Phase3 = {
				varname = format(L.alert["Phase 3"]),
				type = "simple",
				text = format(L.alert["Phase 3"]),
				time = 2,
				color1 = "GREEN",
				icon = ST[136889],
				sound = "ALERT13",
			},
			iCrashingThunder = {
				varname = format(L.alert["%s %s, %s!"],SN[135150],L.alert["under you"],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s %s, %s!"],SN[135150],L.alert["under you"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[135150],
				throttle = 1,
			},	
			IntermissionSoon = { --Supercharge Conduits
				varname = format(L.alert["%s %s"],SN[137045],L.alert["Soon"]),
				type = "simple",
				text = format(L.alert["%s %s"],SN[137045],L.alert["Soon"]),
				time = 2,
				color1 = "GREEN",
				icon = ST[137045],
				sound = "ALERT13",
			},
			DiffusionSoon = {
				varname = format(L.alert["%s %s"],SN[135681],L.alert["Soon"]),
				type = "simple",
				text = format(L.alert["%s %s"],SN[135681],L.alert["Soon"]),
				time = 2,
				color1 = "RED",
				icon = ST[135681],
				sound = "ALERT13",
			},
			iElectricalShock = {
				varname = format(L.alert["%s %s %s 12"],SN[136914],L.alert["Stacks"],L.alert["already at"]),
				type = "inform",
				text = format(L.alert["%s %s %s #11#"],SN[136914],L.alert["Stacks"],L.alert["already at"]),
				time = 2,
				color1 = "RED",
				icon = ST[136914],
				sound = "ALERT13",
				throttle = 3,
				exdps = true,
				exhealer = true,
			},
			iElectricalShocktaunt = {
				varname = format(L.alert["%s - %s"],SN[136914],L.alert["Taunt"]),
				type = "inform",
				text = format(L.alert["%s - %s"],SN[136914],L.alert["Taunt"]),
				time = 2,
				color1 = "RED",
				icon = ST[136914],
				sound = "ALERT14",
				throttle = 3,
				exdps = true,
				exhealer = true,
			},
			-- Phase 1
			Decapitatecd = {
				varname = format(L.alert["%s Cooldown"],SN[135000]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[135000]),
				time = 50,
				time2 = 40,
				color1 = "NEWBLUE",
				icon = ST[135000],
			},
			Thunderstruckcd = {
				varname = format(L.alert["%s Cooldown"],SN[135095]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[135095]),
				time = 46,
				time2 = 25,
				time3 = 30,
				time4 = 36,
				color1 = "NEWBLUE",			
				icon = ST[135095],
				audiotime = 5,
			},
			-- Phase 2
			FussionSlashcd = {
				varname = format(L.alert["%s Cooldown"],SN[136478]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136478]),
				time = 50,
				time2 = 44,
				color1 = "NEWBLUE",
				icon = ST[136478],
			},
			LightningWhipcd = {
				varname = format(L.alert["%s Cooldown"],SN[136850]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136850]),
				time = 45,
				time2 = 30,
				time3 = 21.5,
				color1 = "NEWBLUE",
				icon = ST[136850],
			},
			SummonBallLightningcd = {
				varname = format(L.alert["%s Cooldown"],SN[136543]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136543]),
				time = 45,
				time2 = 15,
				time3 = 41,
				time4 = 30,
				color1 = "NEWBLUE",
				icon = ST[136543],
			},
			warnBouncingBolt = {
				varname = format(L.alert["%s!"],SN[136366]),
				type = "simple",
				text = format(L.alert["%s!"],SN[136366]),
				time = 2,
				color1 = "RED",
				icon = ST[136366],
				sound = "ALERT10",
			},
			warnThunderstruck = {
				varname = format(L.alert["%s!"],SN[135095]),
				type = "simple",
				text = format(L.alert["%s!"],SN[135095]),
				time = 2,
				color1 = "RED",
				icon = ST[135095],
				sound = "ALERT11",
			},
			ThunderstruckCast = {
				varname = format(L.alert["%s Casting"],SN[135095]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[135095]),
				time = 4.8,
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[135095],
			},
			warnFusionSlash = {
				varname = format(L.alert["%s!"],SN[136478]),
				type = "simple",
				text = format(L.alert["%s!"],SN[136478]),
				time = 2,
				color1 = "RED",
				icon = ST[136478],
				sound = "ALERT12",
			},
			FusionSlashCast = {
				varname = format(L.alert["%s Casting"],SN[136478]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[136478]),
				time = 1.9,
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[136478],
			},
			warnLightningWhip = {
				varname = format(L.alert["%s!"],SN[136850]),
				type = "simple",
				text = format(L.alert["%s!"],SN[136850]),
				time = 2,
				color1 = "RED",
				icon = ST[136850],
				sound = "ALERT11",
			},
			LightningWhipCast = {
				varname = format(L.alert["%s Casting"],SN[136850]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[136850]),
				time = 4,
				flashtime = 4,
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[136850],
			},
			warnSummonBall = {
				varname = format(L.alert["%s!"],SN[136543]),
				type = "simple",
				text = format(L.alert["%s!"],SN[136543]),
				time = 2,
				color1 = "RED",
				icon = ST[136543],
				sound = "ALERT1",
				throttle = 2,
			},
			wHelmOfCommandself = {
				varname = format(L.alert["%s %s %s!"],SN[139011],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[139011],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = ST[139011],
			},
			StaticShockself = {
				varname = format(L.alert["%s %s %s!"],SN[135695],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[135695],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[135695],
			},
			Decapitateself = {
				varname = format(L.alert["%s %s %s!"],SN[134912],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[134912],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[134912],
				exdps = true,
			},
			DecapitateCast = {
				varname = format(L.alert["%s Active"],SN[134912]),
				type = "centerpopup",
				text = format(L.alert["%s Active"],SN[134912]),
				time = 6,
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[134912],
			},
			OverchargeCast = {
				varname = format(L.alert["%s Active"],SN[136295]),
				type = "centerpopup",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[136295]),
				text2 = format(L.alert["#5#: %s"],SN[136295]),
				time = 6,
				color1 = "NEWBLUE",
				icon = ST[136295],
			},				
			HelmOfCommandCast = {
				varname = format(L.alert["%s Active"],SN[139011]),
				type = "centerpopup",
				text = format(L.alert["%s Active"],SN[139011]),
				time = 8,
				color1 = "BROWN",
				sound = "ALERT2",
				icon = ST[139011],
			},
			OverchargeDebuff = {
				varname = format(L.alert["%s Debuff"],SN[136295]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[136295]),
				text2 = format(L.alert["#5#: %s"],SN[136295]),
				time = 6,
				color1 = "NEWBLUE",
				icon = ST[136295],
			},
			StaticShockDebuff = {
				varname = format(L.alert["%s Debuff"],SN[135695]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[135695]),
				text2 = format(L.alert["#5#: %s"],SN[135695]),
				time = 8,
				color1 = "NEWBLUE",
				icon = ST[135695],
			},
			HelmOfCommandDebuff = {
				varname = format(L.alert["%s Debuff"],SN[139011]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[139011]),
				text2 = format(L.alert["#5#: %s"],SN[139011]),
				time = 8,
				color1 = "BROWN",
				icon = ST[139011],
			},
			Supercharge = {
				varname = format(L.alert["%s Active"],SN[137045]),
				type = "debuff",
				text = format(L.alert["%s Active"],SN[137045]),
				time = 45,
				color1 = "NEWBLUE",
				icon = ST[137045],
			},		
			-- Phase3
			ViolentGaleWindscd = {
				varname = format(L.alert["%s Cooldown"],SN[136889]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136889]),
				time = 20,
				color1 = "NEWBLUE",
				icon = ST[136889],
			},
			warnViolentGaleWinds = {
				varname = format(L.alert["%s!"],SN[136889]),
				type = "simple",
				text = format(L.alert["%s!"],SN[136889]),
				time = 2,
				color1 = "RED",
				icon = ST[136889],
				sound = "ALERT1",
				throttle = 4,
			},
		},
		events = {
		    -- Thunderstruck
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 135095,
				execute = {
					{
						"batchalert",{"warnThunderstruck","ThunderstruckCast"},
					},
					{
						"expect",{"<phase>","<","3"},
						"alert","Thunderstruckcd",
					},
					{
						"expect",{"<phase>","==","3"},
						"alert",{"Thunderstruckcd", time = 3},
					},
				},
			},
		    -- LightningWhip
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136850,
				execute = {
					{
						"batchalert",{"warnLightningWhip","LightningWhipCast","LightningWhipcd"},
					},
					{
						"expect",{"<phase>","<","3"},
						"alert","LightningWhipcd",
					},
					{
						"expect",{"<phase>","==","3"},
						"alert",{"LightningWhipcd", time = 2},
					},
				},
			},
		    -- FusionSlash
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136478,
				execute = {
					{
						"batchalert",{"warnFusionSlash","FusionSlashCast","FussionSlashcd"},
					},
				},
			},
		    -- Supercharge Conduits
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 137045,
				execute = {
					{
						"set",{transition = "yes"},
						--"quashall",
						"canceltimer",{"timerIntermission"},
						"alert","Supercharge",
						"batchquash",{"FussionSlashcd","LightningWhipcd","SummonBallLightningcd","Decapitatecd","Thunderstruckcd"},
						"invoke", {
							{
								"expect",{"&difficulty&",">=","3"}, --10h&25h
								"alert","HelmOfCommandcd",
							},
							{
								"expect",{"&bossexist|68398&","==","true"},
								"invoke", {
									{
										"expect",{"&difficulty& &difficulty&","~=","2 4"},
										"alert", {"StaticShockcd", time = 3},
									},
									{
										"expect",{"&difficulty&","==","2"},
										"alert", {"StaticShockcd", time = 2},
									},
									{
										"expect",{"&difficulty&","==","4"},
										"alert", {"StaticShockcd", time = 2},
									},
								},
							},
							{
								"expect",{"&bossexist|68696&","==","true"},
								"openwindow",{"8"},
								"invoke", {
									{
										"expect",{"&difficulty& &difficulty&","~=","2 4"},
										"alert", {"DiffusionChaincd", time = 3},
										"schedulealert",{"DiffusionSoon",2},
									},
									{
										"expect",{"&difficulty&","==","2"},
										"alert", {"DiffusionChaincd", time = 2},
										"schedulealert",{"DiffusionSoon",1},
									},
									{
										"expect",{"&difficulty&","==","4"},
										"alert", {"DiffusionChaincd", time = 2},
										"schedulealert",{"DiffusionSoon",1},
									},
								},
							},
							{
								"expect",{"&bossexist|68697&","==","true"},
								"alert", {"Overchargecd", time = 2},
							},
							{
								"expect",{"&bossexist|68698&","==","true"},
								"invoke", {
									{
										"expect",{"&difficulty& &difficulty&","~=","2 4"},
										"alert", {"BouncingBoltcd", time = 3},
									},
									{
										"expect",{"&difficulty&","==","2"},
										"alert", {"BouncingBoltcd", time = 2},
									},
									{
										"expect",{"&difficulty&","==","4"},
										"alert", {"BouncingBoltcd", time = 2},
									},
								},
							},
						},
					},
				},
			},
			-- DiffusionChain
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {135991},
				execute = {
					{
						"message","warnDiffusionChain",
					},
					{
						"expect",{"<transition>","==","no"},
						"alert","DiffusionChaincd",
						"schedulealert",{"DiffusionSoon",20},
						"openwindow",{"8"},
					},
					{
						"expect",{"<transition>","==","yes"},
						"alert",{"DiffusionChaincd", time = 4},
						"schedulealert",{"DiffusionSoon",30},
					},
				},
			},
			-- Diffusion Chain (East)
			--[[{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				--spellid = {135681,},
				spellname = 135681,
				--dstnpcid = 68397,
				--dstnpcid = 68397,
				execute = {
					{
						--"expect",{"&npcid|#4#&","==","68397"}, --68696
						--"invoke",{
							--{
							--	"alert","DiffusionSoon",
							--},
							{
								--"expect",{"&isranged&","==","true"},
								"debug",{"Diffusion Chain (East)"},
								"openwindow",{"8"},
							},
						--},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				--spellid = {135681,},
				spellname = 135681,
				--dstnpcid = 68397,
				--dstnpcid = {68397},
				execute = {
					{
						"expect",{"<transition>","==","no"},
						"invoke",{
							{
								"quash","DiffusionChaincd",
							},
							{
								"expect",{"&isranged&","==","true"},
								"invoke",{
									{
										"expect",{"<phase>","~=","1"},
										"openwindow",{"6"},
									},
									{
										"expect",{"<phase>","==","1"},
										"closewindow",
									},							
								},
							},
						},
					},
				},
			},--]]
			-- SummonBallLightning
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 136543,
				--throttle = 2,
				execute = {
					{
						"alert","warnSummonBall",
						"schedulemessage",{"warnBallLightningSoon",41},
					},
					{
						"expect",{"<phase>","<","3"},
						"alert","SummonBallLightningcd",
					},
					{
						"expect",{"<phase>","==","3"},
						"alert",{"SummonBallLightningcd", time = 4},
					},
				},
			},
			-- Supercharge Conduits
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					--[[{
						"expect",{"#5#","==","137146"},
						"set",{transition = "yes"},
						--"quashall",
						"canceltimer",{"timerIntermission"},
						"alert","Supercharge",
						"batchquash",{"FussionSlashcd","LightningWhipcd","SummonBallLightningcd","Decapitatecd","Thunderstruckcd"},
						"invoke", {
							{
								"expect",{"&difficulty&",">=","3"}, --10h&25h
								"alert","HelmOfCommandcd",
							},
							{
								"expect",{"&bossexist|68398&","==","1"},
								"invoke", {
									{
										"expect",{"&difficulty& &difficulty&","~=","2 4"},
										"alert", {"StaticShockcd", time = 3},
									},
									{
										"expect",{"&difficulty&","==","2"},
										"alert", {"StaticShockcd", time = 2},
									},
									{
										"expect",{"&difficulty&","==","4"},
										"alert", {"StaticShockcd", time = 2},
									},
								},
							},
							{
								"expect",{"&bossexist|68696&","==","1"},
								"openwindow",{"8"},
								"invoke", {
									{
										"expect",{"&difficulty& &difficulty&","~=","2 4"},
										"alert", {"DiffusionChaincd", time = 3},
										"schedulealert",{"DiffusionSoon",2},
									},
									{
										"expect",{"&difficulty&","==","2"},
										"alert", {"DiffusionChaincd", time = 2},
										"schedulealert",{"DiffusionSoon",1},
									},
									{
										"expect",{"&difficulty&","==","4"},
										"alert", {"DiffusionChaincd", time = 2},
										"schedulealert",{"DiffusionSoon",1},
									},
								},
							},
							{
								"expect",{"&bossexist|68697&","==","1"},
								"alert", {"Overchargecd", time = 2},
							},
							{
								"expect",{"&bossexist|68698&","==","1"},
								"invoke", {
									{
										"expect",{"&difficulty& &difficulty&","~=","2 4"},
										"alert", {"BouncingBoltcd", time = 3},
									},
									{
										"expect",{"&difficulty&","==","2"},
										"alert", {"BouncingBoltcd", time = 2},
									},
									{
										"expect",{"&difficulty&","==","4"},
										"alert", {"BouncingBoltcd", time = 2},
									},
								},
							},
						},
					},--]]
					-- BouncingBolt 
					{
						"expect",{"#5#","==","136395"},
						--"expect",{"#1#","==","boss1"},
						"alert","warnBouncingBolt",
						"invoke",{
							{
								"expect",{"<transition>","==","yes"},
								"alert","BouncingBoltcd",
							},
							{
								"expect",{"<transition>","==","no"},
								"alert",{"BouncingBoltcd", time = 5},
							},
						},
					},
					-- ViolentGaleWinds
					{
						"expect",{"#5#","==","136869"},
						--"expect",{"#1#","==","boss1"},
						"batchalert",{"ViolentGaleWindscd","warnViolentGaleWinds"},
					},
				},
			},
			-- Emotes
			{
				type = "event",
				event = "EMOTE", 
				execute = {
					-- Overloaded Circuits
					{
						"expect",{"#1#","find","spell:137176"},
						"set",{phase = "INCR|1"},
						"set",{transition = "no"},
						--"quashall",
						"closewindows",
						"scheduletimer",{"timerIntermission",1},
						"invoke", {
							--[[{
								"expect",{"#1#","find","spell:135680"},
								"set",{north = 1},
							},
							{
								"expect",{"#1#","find","spell:135681"},
								"set",{east = 1},
							},
							{
								"expect",{"#1#","find","spell:135682"},
								"set",{south = 1},
							},
							{
								"expect",{"#1#","find","spell:135683"},
								"set",{west = 1},
							},--]]
							{
								--"expect",{"&isranged&","==","true"},
								"openwindow",{"6"},
							},
							{
								"expect",{"<phase>","==","2"},
								"alert","Phase2",
								"invoke", {
									{
										"expect",{"&difficulty&","<=","2"}, --normal
										"alert",{"SummonBallLightningcd", time = 2},
										"alert",{"FussionSlashcd", time = 2},
										"alert",{"LightningWhipcd", time = 2},
									},
									{
										"expect",{"&difficulty&",">=","3"}, --10h&25h
										"invoke", {
											{
												--"expect",{"<north>","==","1"},
												"expect",{"#1#","find","spell:135680"},
												"alert",{"StaticShockcd", time = 4},
											},
											{
											--	"expect",{"<east>","==","1"},
												"expect",{"#1#","find","spell:135681"},
												"alert",{"DiffusionChaincd", time = 5},
												"invoke",{
													{										
													--	"expect",{"&isranged&","==","true"},
														"openwindow",{"8"},
													},
												},
											},
											{
												--"expect",{"<south>","==","1"},
												"expect",{"#1#","find","spell:135682"},
												"alert",{"Overchargecd", time = 3},
											},
											{
												--"expect",{"<west>","==","1"},
												"expect",{"#1#","find","spell:135683"},
												"alert",{"BouncingBoltcd", time = 2},
											},
										},
									},
								},
							},
							{
								"expect",{"<phase>","==","3"},
								"alert","Phase3",
								"invoke", {
									{
										"expect",{"&difficulty&","<=","2"}, --normal
										"alert",{"LightningWhipcd", time = 3},
										"alert",{"Thunderstruckcd", time = 4},
										"alert",{"SummonBallLightningcd", time = 3},
										"alert","ViolentGaleWindscd",
									},
									{
										"expect",{"&difficulty&",">=","3"}, --10h&25h
										"invoke", {
											{
												--"expect",{"<north>","==","1"},
												"expect",{"#1#","find","spell:135680"},
												"alert",{"StaticShockcd", time = 5},
											},
											{
												--"expect",{"<east>","==","1"},
												"expect",{"#1#","find","spell:135681"},
												"alert",{"DiffusionChaincd", time = 6},
											},
											{
												--"expect",{"<south>","==","1"},
												"expect",{"#1#","find","spell:135682"},
												"alert",{"Overchargecd", time = 4},
											},
											{
												--"expect",{"<west>","==","1"},
												"expect",{"#1#","find","spell:135683"},
												"alert",{"BouncingBoltcd", time = 4},
											},
										},
									},
								},
							},
						},
					},
				},
			},
			-- Decapitate
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {135000, 134912},
				execute = {
					{
						"batchalert",{"Decapitatecd","DecapitateCast"},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","Decapitateself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"message","warnDecapitate",
					},
				},
			},
			-- Static Shock
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 135695,
				execute = {
					{
						"expect",{"&unitisplayer|#5#&","==","true"},
						"invoke",{
							{
								"raidicon","StaticShockicon",
								"insert",{"staticshockunits","#5#"},
								"canceltimer","liststaticshocks",
								"scheduletimer",{"liststaticshocks",0.3},
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"alert","StaticShockself",
								"announce","staticshocksay",
								"set",{staticsay = 6},
								"scheduletimer",{"timerStaticShock",3},
								"alert","StaticShockDebuff",
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"alert",{"StaticShockDebuff", text = 2},
								"invoke",{
									{
										"expect",{"&inrange|#5#&","<","31"},
										"arrow","staticarrow",
									},
								},
							},
							{
								"expect",{"<transition>","==","no"},
								"alert","StaticShockcd",
							},
						},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 135695,
				execute = {
					{
						"removeraidicon","#5#",
						"removearrow","#5#",
					},
				},
			},		
			-- overcharge
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {136295,},
				execute = {
					{
						"expect",{"&unitisplayer|#5#&","==","true"},
						"invoke",{
							{
								"raidicon","Overchargeicon",
								"alert","Overchargecd",
								"insert",{"overchargeunits","#5#"},
								"canceltimer","listovercharge",
								"scheduletimer",{"listovercharge",0.5},
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"announce","overchargesay",
								"set",{overchargesay = 5},
								"scheduletimer",{"timerOvercharged",2},								
								"batchalert",{"OverchargeCast","OverchargeDebuff"},
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"alert",{"OverchargeDebuff", text = 2},
								"alert",{"OverchargeCast", text = 2},
								"set",{range = "&inrange|#5#&"},
								"invoke",{
									{
										"expect",{"<range>","<","31"},
										"arrow","overchargearrow",
									},
									{
										
										"expect",{"<range>",">","30"},
										"expect",{"<range>","<","51"},
										"arrow","overchargearrowaway",
									},
								},
							},
						},
					},
				},
			},
			--[[{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136295,
				execute = {
					{
						"set",{overchargen = "INCR|1"},
					},
					{
						"expect",{"<transition>","==","no"},
						"expect",{"<overchargen>","==","1"},
						"invoke",{
							{
								"raidicon","Overchargeicon",
								"alert","Overchargecd",
								"insert",{"overchargeunits","#5#"},
								"canceltimer","listovercharge",
								"scheduletimer",{"listovercharge",0.3},
								"scheduletimer",{"overchargereset",13},
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"announce","overchargesay",
								"alert","OverchargeDebuff",
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"alert",{"OverchargeDebuff", text = 2},
								"expect",{"&inrange|#5#&","<","31"},
								"arrow","overchargearrow",
							},
						},
					},
					{
						"expect",{"<transition>","==","yes"},
						"expect",{"<overchargen>","<","4"},
						"invoke",{
							{
								"raidicon","Overchargeicon",
								"insert",{"overchargeunits","#5#"},
								"canceltimer","listovercharge",
								"scheduletimer",{"listovercharge",0.3},
								"scheduletimer",{"overchargereset",13},
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"announce","overchargesay",
								"alert","OverchargeDebuff",
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"alert",{"OverchargeDebuff", text = 2},
								"expect",{"&inrange|#5#&","<","31"},
								"arrow","overchargearrow",
							},
						},
					},
				},
			},--]]
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136295,
				execute = {
					{
						"removeraidicon","#5#",
						"removearrow","#5#",
					},
				},
			},		
			-- ElectricalShock
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 136914,
				execute = {
					{
						"expect",{"#11#",">","5"},
						"message","warnElectricalShock"
					},
					{
						"expect",{"#11#",">=","12"},
						"invoke", {
							{
								"expect",{"#4#","==","&playerguid&"},
								"alert","iElectricalShock",
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"expect",{"&playerdebuff|"..SN[136914].."&","==","false"},
								"alert","iElectricalShocktaunt",
							},
						},
					},
				},
			},
			-- Crashing Thunder
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 135150,
				dstisplayerunit = true,
				execute = {
					{
						"alert","iCrashingThunder",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_PERIODIC_DAMAGE",
				spellname = 135153,
				dstisplayerunit = true,
				execute = {
					{
						"alert","iCrashingThunder",
					},
				},
			},	
			-- Helm of Command (heroic)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {139011},
				execute = {
					{
						"expect",{"&unitisplayer|#5#&","==","true"},
						"invoke",{
							{
								"insert",{"helmofcommandunits","#5#"},
								"canceltimer","listHelmofcommand",
								"scheduletimer",{"listHelmofcommand",0.3},
								"alert","HelmOfCommandcd",
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"alert",{"wHelmOfCommandself","HelmOfCommandDebuff","HelmOfCommandCast"},
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"alert",{"HelmOfCommandDebuff", text = 2},
							},
						},
					},
				},
			},			
		},
	}

	DXE:RegisterEncounter(data)
end
