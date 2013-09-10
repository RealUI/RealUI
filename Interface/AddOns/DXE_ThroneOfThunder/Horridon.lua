local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST
--TODO

do
	local Farraki	= EJ_GetSectionInfo(7081)
	local Gurubashi	= EJ_GetSectionInfo(7082)
	local Drakkari	= EJ_GetSectionInfo(7083)
	local Amani		= EJ_GetSectionInfo(7084)

	local data = {
		version = 12,
		key = "Horridon",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Horridon"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-HORRIDON.BLP:35:35",
		triggers = {
			scan = {68476}, 
		},
		onactivate = {
			tracing = {	68476 },
			tracerstart = true,
			combatstop = true,
			defeat = {	68476 },
			unittracing = {	"boss1","boss2"},
		},
		windows = {
			proxwindow = true,
		},
		enrage = {
			time10n = 720,
			time25n = 720,
			time10h = 720,
			time25h = 720,
		},
		timers = {
			life = {
				{
					--"expect",{"&difficulty&","<=","2"}, --10n&25n
					"expect",{"&gethp|boss1&","<","35"},
					"expect",{"&unitexist|boss2&","==","0"},
					--"expect",{"<jalak>","==","0"},
					"set",{phane2warned = "yes"},
					"alert","phasesoon",
					--"scheduletimer",{"life",2},
				},
				{
					"expect",{"<phase2warned>","==","no"},
					"scheduletimer",{"life",1},
				},
			},
			timerJalak = {
				{
					"expect",{"&unitexist|boss2&","==","1"},
					"expect",{"&bossid|boss2&","==","69374"},
					--"set",{jalak = "1"},
					"quash","Jalakcd",
					"tracing",{	68476, 69374},
					"alert",{"warnJalak","iJalak"},
					"alert",{"BestialCrycd", time = 2},
				},
				{
					"expect",{"&unitexist|boss2&","==","0"},
					"scheduletimer",{"timerJalak",1},
				},
			},
			timerAdds = {
				{
					"expect",{"<door>","==","1"},
					--"batchalert",{"addscd","msgaddssoon"},
					"alert","addscd",
					"message","msgaddssoon",
				},
				{
					"expect",{"<door>","==","2"},
					"alert",{"warnadds", text = 2},
				},
				{
					"expect",{"<door>","==","3"},
					"alert",{"warnadds", text = 3},
				},
				{
					"expect",{"<door>","==","4"},
					"alert",{"warnadds", text = 4},
				},
			},
			timerFixated = {
				{
					"expect",{"&unitexist|focus&","==","1"},
					"expect",{"&inrange|focus&","<","17"},
					"alert","wDireFixateNear",
					"scheduletimer",{"timerFixated",1},
				},
				{
					"expect",{"&unitexist|focus&","==","0"},
					"scheduletimer",{"timerFixated",10},
				},
			},			
		},
		raidicons = {
			Priest = {
				varname = L.npc_ThroneOfThunder["Gurubashi Venom Priest"],
				type = "MULTIENEMY",
				persist = 60,
				unit = "<Priest>",
				id = 69164,
				reset = 3,
				icon = 1,
				total = 3,
			},
			Wastewalker = {
				varname = L.npc_ThroneOfThunder["Farraki Wastewalker"],
				type = "MULTIENEMY",
				persist = 60,
				unit = "<Wastewalker>",
				id = 69175,
				reset = 3,
				icon = 1,
				total = 3,
			},
			Warlord = {
				varname = L.npc_ThroneOfThunder["Drakkari Frozen Warlord"],
				type = "MULTIENEMY",
				persist = 60,
				unit = "<Warlord>",
				id = 69178,
				reset = 3,
				icon = 1,
				total = 3,
			},
			Warbear = {
				varname = L.npc_ThroneOfThunder["Amani Warbear"],
				type = "MULTIENEMY",
				persist = 60,
				unit = "<Warbear>",
				id = 69177,
				reset = 3,
				icon = 1,
				total = 3,
			},
			Shaman = {
				varname = L.npc_ThroneOfThunder["Amani'shi Beast Shaman"],
				type = "MULTIENEMY",
				persist = 30,
				unit = "<Shaman>",
				id = 69176,
				reset = 3,
				icon = 1,
				total = 3,
			},	
			Dinomancer = {
				varname = L.npc_ThroneOfThunder["Zandalari Dinomancer"],
				type = "MULTIENEMY",
				persist = 30,
				unit = "<Dinomancer>",
				id = 69221,
				reset = 3,
				icon = 1,
				total = 3,
			},					
		},
		onstart = {
			{
				"batchalert",{"doorcd","chargecd","doubleSwipecd"},
				"alert",{"puncturecd", time = 2},
				"scheduletimer",{"timerJalak",1},
			},
			{
				"expect",{"&difficulty&",">=","3"}, --10h&25h
				"alert","direcallcd",
			},
		},
		userdata = {
			chargetime = {32,50,loop = false, type = "series"},
			doortime = {16,113.5,loop = false, type = "series"},
			warnpuncturestext = "",
			puncturestext = "",
			msgpuncturetext = "",
			--bestialcry = 10,
			phane2warned = "no",
			--bestialcrytext = "",
			bestialtext = "",
			--doubleSwipetime = {16,11.5,loop = false, type = "series"},
			jalak = 0,
			door = 0,
			Priest = "",
			Shaman = "",
			Wastewalker = "",
			Warbear = "",
			Warlord = "",
			Dinomancer = "",
		},
		announces = {
			chargesay = {
				varname = format(L.alert["%s %s %s"],SN[136769],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s"],SN[136769],L.alert["on"],L.alert["Me"]),
				--enabled = false,
			},
		},
		messages = {
			msgcrackedshell = {
				varname = format(L.alert["%s"],SN[137240]),
				type = "message",
				text = format(L.alert["%s (1)"],SN[137240]),
				text2 = format(L.alert["%s (#11#)"],SN[137240]),
				color1 = "GREEN",
				icon = ST[137240],
				sound = "ALERT13",
			},
			msgcharge = {
				varname = format(L.alert["%s"],SN[136769]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136769],L.alert["on"]),
				color1 = "BROWN",
				icon = ST[136769],
				sound = "ALERT13",
			},
			msgpuncture = {
				varname = format(L.alert["%s"],SN[136767]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[136767],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[136767],L.alert["on"]),
				text3 = format(L.alert["%s %s %s #11# %s #5#"],SN[136767],L.alert["Stacks"],L.alert["already"],L.alert["on"]),
				color1 = "RED",
				icon = ST[136767],
				sound = "ALERT13",
				exhealer = true,
				exdps = true,
			},
			msgMending = {
				varname = format(L.alert["%s!"],SN[136797]),
				type = "message",
				text = format(L.alert["%s!"],SN[136797]),
				color1 = "GREEN",
				icon = ST[136797],
				sound = "ALERT13",
				exhealer = true,
				exdps = true,
			},
			msgbestialcry = {
				varname = format(L.alert["%s"],SN[136817]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[136817],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[136817],L.alert["on"]),
				color1 = "RED",
				icon = ST[136817],
				sound = "ALERT13",
			},
			msgstrike = {
				varname = format(L.alert["%s"],SN[136670]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136670],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[136670],
				sound = "ALERT13",
				exdps = true,
			},
			msgaddssoon = {
				varname = format(L.alert["%s %s"],Farraki,L.alert["soon"]),
				type = "message",
				text = format(L.alert["%s %s"],Farraki,L.alert["soon"]),
				text2 = format(L.alert["%s %s"],Gurubashi,L.alert["soon"]),
				text3 = format(L.alert["%s %s"],Drakkari,L.alert["soon"]),
				text4 = format(L.alert["%s %s"],Amani,L.alert["soon"]),
				time = 3,
				color1 = "ORANGE",
				icon = ST[136821],
				sound = "ALERT13",
			},
			msgdirecall = {
				varname = format("%s!",SN[137458]),
				type = "message",
				text = format(L.alert["%s!"],SN[137458]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT13",
				icon = ST[137458],
			},
			msgDireFixate  = {
				varname = format("%s!",SN[140946]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[140946],L.alert["on"]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT13",
				icon = ST[140946],
			},
		},
		alerts = {
			-- Cooldowns
			doorcd = {
				varname = format(L.alert["%s Cooldown"],L.chat_ThroneOfThunder["Next Door"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.chat_ThroneOfThunder["Next Door"]),
				time = "<doortime>",
				flashtime = 5,
				color1 = "NEWBLUE",
				icon = ST[2457],
			},
			addscd = {
				varname = format(L.alert["Next Adds: %s"],Farraki),
				type = "dropdown",
				text = format(L.alert["Next Adds: %s"],Farraki),
				text2 = format(L.alert["Next Adds: %s"],Gurubashi),
				text3 = format(L.alert["Next Adds: %s"],Drakkari),
				text4 = format(L.alert["Next Adds: %s"],Amani),
				time = 18.91,
				flashtime = 5,
				color1 = "NEWBLUE",
				icon = ST[43712],
			},
			chargecd = {
				varname = format(L.alert["%s Cooldown"],SN[136769]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136769]),
				time = "<chargetime>",
				color1 = "RED", 
				icon = ST[136769],
			},
			doubleSwipecd = {
				varname = format(L.alert["%s Cooldown"],SN[136741]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136741]),
				--time = "<doubleSwipetime>",
				time = 17,
				time2 = 11.5,
				color1 = "NEWBLUE",
				icon = ST[136741],
			},
			puncturecd = {
				varname = format(L.alert["%s Cooldown"],SN[136767]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136767]),
				time = 11,
				time2 = 10,
				color1 = "NEWBLUE",
				icon = ST[136767],
				exdps = true,
			},
			bestialcrycd = {
				varname = format(L.alert["%s Cooldown"],SN[136817]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136817]),
				time = 10,
				time2 = 5,
				color1 = "NEWBLUE",
				icon = ST[136817],
			},
			direcallcd = {
				varname = format(L.alert["%s Cooldown"],SN[137458]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137458]),
				time = 62,
				color1 = "BROWN",
				icon = ST[137458],
			},
			dinocd = {
				varname = format(L.alert["%s Cooldown"],SN["ej7086"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN["ej7086"]),
				time = 56,
				color1 = "NEWBLUE",
				icon = ST[137237],
			},
			Jalakcd = {
				varname = format(L.alert["%s Cooldown"],SN["ej7087"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN["ej7087"]),
				time = 59.5,
				time2 = 143,
				color1 = "NEWBLUE",
				icon = ST[2457],
				flashtime = 10,
				audiocd = true,
			},
			-- Warnings
			wDireFixateNear = {
				varname = format("%s %s %s!",SN[140946],L.alert["Near"],L.alert["YOU"]),
				type = "simple",
				text = format("%s %s %s!",SN[140946],L.alert["Near"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				flashscreen = true,
				sound = "ALERT11",
				icon = ST[140946],
				throttle = 6,
			},			
			phasesoon = {
				varname = format(L.alert["%s %s"],SN["ej7087"],L.alert["soon"]),
				type = "simple",
				text = format(L.alert["%s %s"],SN["ej7087"],L.alert["soon"]),
				time = 3,
				color1 = "ORANGE",
				icon = ST[136821],
				sound = "ALERT15",
				--flashscreen = true,
			},
			warnadds = {
				varname = format(L.alert["%s: %s"],L.alert["Incoming"],Farraki),
				type = "simple",
				text = format(L.alert["%s: %s"],L.alert["Incoming"],Farraki),
				text2 = format(L.alert["%s: %s"],L.alert["Incoming"],Gurubashi),
				text3 = format(L.alert["%s: %s"],L.alert["Incoming"],Drakkari),
				text4 = format(L.alert["%s: %s"],L.alert["Incoming"],Amani),
				time = 3,
				color1 = "RED",
				sound = "ALERT9",
				icon = ST[136769],
			},
			warncharge = {
				varname = format(L.alert["%s %s %s, %s!"],SN[136769],L.alert["on"],L.alert["YOU"],L.alert["MOVE AWAY"]),
				type = "simple",
				text = format(L.alert["%s %s %s, %s!"],SN[136769],L.alert["on"],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 3,
				color1 = "RED",
				sound = "ALERT12",
				icon = ST[136769],
			},
			warndoubleSwipe = {
				varname = format(L.alert["%s: %s!"],SN[136741],L.alert["Watch Out"]),
				type = "simple",
				text = format(L.alert["%s: %s!"],SN[136741],L.alert["Watch Out"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[136741],
			},
			warnFrozenBolt = {
				varname = format(L.alert["%s: %s!"],SN[136573],L.alert["Watch Out"]),
				type = "simple",
				text = format(L.alert["%s: %s!"],SN[136573],L.alert["Watch Out"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT10",
				icon = ST[136573],
				throttle = 2,
			},
			warnLightningNova = {
				varname = format(L.alert["%s %s!"],SN[136490],L.alert["MOVE AWAY"]),
				type = "simple",
				text = format(L.alert["%s %s!"],SN[136490],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[136490],
				flashscreen = true,
				throttle = 2,
			},
			warnSandTrap = {
				varname = format(L.alert["%s %s, %s!"],SN[136723],L.alert["under you"],L.alert["MOVE AWAY"]),
				type = "simple",
				text = format(L.alert["%s %s, %s!"],SN[136723],L.alert["under you"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[136723],
				flashscreen = true,
				throttle = 2,
			},
			warnrampage = {
				varname = format(L.alert["%s!"],SN[136821]),
				type = "simple",
				text = format(L.alert["%s!"],SN[136821]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[136821],
				exdps = true,
			},
			warndinoform = {
				varname = format(L.alert["%s!"],L.chat_ThroneOfThunder["Orb of Control dropped"]),
				type = "simple",
				text = format(L.alert["%s!"],L.chat_ThroneOfThunder["Orb of Control dropped"]),
				time = 2,
				color1 = "GREEN",
				sound = "ALERT14",
				icon = ST[137237],
			},
			warnLightningNova = {
				varname = format(L.alert["%s %s!"],SN[136490],L.alert["MOVE AWAY"]),
				type = "simple",
				text = format(L.alert["%s %s!"],SN[136490],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[136490],
				flashscreen = true,
				throttle = 1,
			},
			warnLivingPoison = {
				varname = format(L.alert["%s %s!"],SN[136646],L.alert["MOVE AWAY"]),
				type = "simple",
				text = format(L.alert["%s %s!"],SN[136646],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[136646],
				flashscreen = true,
				throttle = 2,
			},
			warnJalak = {
				varname = format(L.alert["%s %s!"],SN["ej7087"],L.chat_ThroneOfThunder["Jumping down"]),
				type = "simple",
				text = format(L.alert["%s %s!"],SN["ej7087"],L.chat_ThroneOfThunder["Jumping down"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = ST[137458],
			},
			--[[warnAdds = {
				varname = format(L.alert["%s!"],L.alert["INCOMING ADDS"]),
				type = "simple",
				text = format(L.alert["%s!"],L.alert["INCOMING ADDS"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = ST[43712],
			},--]]
			warnDireFixate = { -- Heroic
				varname = format(L.alert["%s %s %s %s!"],SN[140946],L.alert["on"],L.alert["YOU"],L.alert["RUN AWAY"]),
				type = "simple",
				text = format(L.alert["%s %s %s %s!"],SN[140946],L.alert["on"],L.alert["YOU"],L.alert["RUN AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT12",
				icon = ST[140946],
			},
			-- Informs		
			warnpuncture = {
				varname = format(L.alert["%s: %s 10 %s!"],SN[136767],L.alert["already at"],L.alert["Stacks"]),
				type = "inform",
				text = format(L.alert["%s: %s 10 %s!"],SN[136767],L.alert["already at"],L.alert["Stacks"]),
				text2 = "<warnpuncturestext>",
				time = 2,
				color1 = "RED",
				sound = "ALERT14",
				icon = ST[136521],
				flashscreen = true,
			},
			warnMending = {
				varname = format(L.alert["%s - %s!!!"],SN[136797],L.alert["INTERRUPT"]),
				type = "inform",
				text = format(L.alert["%s - %s!!!"],SN[136797],L.alert["INTERRUPT"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[136797],
				exhealer = true,
				extank = true,
			},
			ipunctures = {
				varname =  format(L.alert["%s - %s!"],SN[136767],L.alert["Taunt"]),
				type = "inform",
				text = format(L.alert["%s - %s!"],SN[136767],L.alert["Taunt"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT10",
				icon = ST[136767],
				exdps = true,
				exhealer = true,
			},
			iDeadlyPlague = {
				varname = format(L.alert["%s %s %s!"],SN[136710],L.alert["Dispell"],L.alert["player"]),
				type = "inform",
				text = format(L.alert["%s #5#"],L.alert["Dispell"]),
				time = 2,
				color1 = "MIDGREY",
				--sound = "ALERT10",
				icon = ST[136710],
				throttle = 3,
			},
			iVenomBoltVolley = {
				varname = format(L.alert["%s %s %s!"],SN[136587],L.alert["Dispell"],L.alert["player"]),
				type = "inform",
				text = format(L.alert["%s #5#"],L.alert["Dispell"]),
				time = 2,
				color1 = "GREEN",
				--sound = "ALERT10",
				icon = ST[136587],
				throttle = 3,
			},
			iHex = {
				varname = format(L.alert["%s %s %s!"],SN[136512],L.alert["Dispell"],L.alert["player"]),
				type = "inform",
				text = format(L.alert["%s #5#"],L.alert["Dispell"]),
				time = 2,
				color1 = "PEACH",
				--sound = "ALERT10",
				icon = ST[136512],
				throttle = 3,
			},
			iblazingsunlight = {
				varname = format(L.alert["%s %s %s!"],SN[136719],L.alert["Dispell"],L.alert["player"]),
				type = "inform",
				text = format(L.alert["%s #5#"],L.alert["Dispell"]),
				time = 2,
				color1 = "ORANGE",
				--sound = "ALERT10",
				icon = ST[136719],
				throttle = 3,
			},
			iHeadache = {
				varname = L.alert["Boss is Stunned!"],
				type = "inform",
				text = format(L.alert["&bossname|boss1& %s!"],L.alert["is Stunned"]),
				time = 4,
				color1 = "ORANGE",
				sound = "ALERT10",
				icon = ST[137294],
			},
			iJalak = {
				varname = format(L.alert["%s %s!"],SN["ej7087"],L.alert["SWITCH TARGET"]),
				type = "inform",
				text = format(L.alert["%s %s!"],SN["ej7087"],L.alert["SWITCH TARGET"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[137294],
				exdps = true,
				exhealer = true,
			},
			-- Debuff
			puncturestacks = {
				varname = format(L.alert["%s Debuff"],SN[136767]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[136767]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[136767]),
				text3 = format(L.alert["#5#: %s (1)"],SN[136767]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[136767]),
				time = 60,
				color1 = "NEWBLUE",
				icon = ST[136767],
				tag = "#5#",
				enabled = true,
			},
			strikedebuff = {
				varname = format(L.alert["%s Debuff"],SN[136670]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[136670]),
				text2 = format(L.alert["#5#: %s"],SN[136670]),
				time = 8,
				color1 = "NEWBLUE",
				icon = ST[136670],
				tag = "#5#",
				enabled = true,
			},
			-- Centerpopup
			chargecast = {
				varname = format(L.alert["Boss %s %s!"],L.alert["casting"],SN[136769]),
				type = "centerpopup",
				text = format(L.alert["&bossname|boss1& %s %s!"],L.alert["casting"],SN[136769]),
				time = 3.4,
				flashtime = 3.4,
				color1 = "RED",
				icon = ST[136769],
				sound = "ALERT11",
			},
			Headache = {
				varname = format(L.alert["%s!"],SN[137294]),
				type = "centerpopup",
				text = format(L.alert["%s!"],SN[137294]),
				time = 10,
				color1 = "GREEN",
				sound = "ALERT1",
				icon = ST[137294],
				biggerbar = true,
			},
		},
		events = {
			--[[{
				type = "event",
				event = "PLAYER_TARGET_CHANGED",
				execute = {
					{
						"expect",{"&bossid|target&","==","69164"}, -- Priest
						"set",{Priest = "&bossid|target|true&"},
						"raidicon","Priest",
						--"debug",{"<Priest> priest"},
					},
					{
						"expect",{"&bossid|target&","==","69176"}, -- Shaman
						"set",{Shaman = "&bossid|target|true&"},
						"raidicon","Shaman",
						--"debug",{"<Shaman> Shaman"},
					},
					{
						"expect",{"&bossid|target&","==","69175"}, -- Wastewalker
						"set",{Wastewalker = "&bossid|target|true&"},
						"raidicon","Wastewalker",
						--"debug",{"<Wastewalker> Wastewalker"},
					},
					{
						"expect",{"&npcid|target&","==","69177"}, -- Warbear
						"set",{Warbear = "&bossid|target|true&"},
						"raidicon","Warbear",						
						--"debug",{"<Warbear> Warbear"},
					},
					{
						"expect",{"&bossid|target&","==","69178"}, -- Warlord
						"set",{Warlord = "&bossid|target|true&"},
						"raidicon","Warlord",						
						--"debug",{"<Warlord> Warlord"},
					},	
					{
						"expect",{"&bossid|target&","==","69221"}, -- Zandalari Dinomancer
						"set",{Dinomancer = "&bossid|target|true&"},
						"raidicon","Dinomancer",						
						--"debug",{"<Dinomancer> Dinomancer"},
					},						
				},
			},--]]
			{
				type = "event",
				event = "UPDATE_MOUSEOVER_UNIT",
				execute = {
					{
						"expect",{"&bossid|mouseover&","==","69164"}, -- Priest
						"set",{Priest = "&bossid|mouseover|true&"},
						"raidicon","Priest",
						--"debug",{"<Priest> priest"},
					},
					{
						"expect",{"&bossid|mouseover&","==","69176"}, -- Shaman
						"set",{Shaman = "&bossid|mouseover|true&"},
						"raidicon","Shaman",
						--"debug",{"<Shaman> Shaman"},
					},
					{
						"expect",{"&bossid|mouseover&","==","69175"}, -- Wastewalker
						"set",{Wastewalker = "&bossid|mouseover|true&"},
						"raidicon","Wastewalker",
						--"debug",{"<Wastewalker> Wastewalker"},
					},
					{
						"expect",{"&npcid|mouseover&","==","69177"}, -- Warbear
						"set",{Warbear = "&bossid|mouseover|true&"},
						"raidicon","Warbear",						
						--"debug",{"<Warbear> Warbear"},
					},
					{
						"expect",{"&bossid|mouseover&","==","69178"}, -- Warlord
						"set",{Warlord = "&bossid|mouseover|true&"},
						"raidicon","Warlord",						
						--"debug",{"<Warlord> Warlord"},
					},	
					{
						"expect",{"&bossid|mouseover&","==","69221"}, -- Zandalari Dinomancer
						"set",{Dinomancer = "&bossid|mouseover|true&"},
						"raidicon","Dinomancer",						
						--"debug",{"<Dinomancer> Dinomancer"},
					},						
				},
			},
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","69374"}, -- Jalak
						"set",{jalak = "1"},
					},		
				},
			},
			--- VenomBoltVolley
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136587,
				--srcnpcid = 69164,
				execute = {
					{
						"set",{Priest = "#1#"},
						"raidicon","Priest",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136587,
				execute = {
					{
						"expect",{"&dispell|poison&","==","true"},
						"alert","iVenomBoltVolley",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 136587,
				execute = {
					{
						"expect",{"&dispell|poison&","==","true"},
						"alert","iVenomBoltVolley",
					},
				},
			},
			-- LivingPoison
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 136646,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnLivingPoison",
					},
				},
			},
			--- DeadlyPlague
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136710,
				execute = {
					{
						"expect",{"&dispell|disease&","==","true"},
						"alert","iDeadlyPlague",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 136710,
				execute = {
					{
						"expect",{"&dispell|disease&","==","true"},
						"alert","iDeadlyPlague",
					},
				},
			},
			-- strike
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136670,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"message","msgstrike",
						"quash","strikedebuff",
						"alert","strikedebuff",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"message","msgstrike",
						"quash","strikedebuff",
						"alert",{"strikedebuff", text = 2},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136670,
				execute = {
					{
						"quash","strikedebuff",
					},
				},
			},
			-- chainlightning
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136480,
				srcnpcid = 69176,
				execute = {
					{
						"set",{Shaman = "#1#"},
						"raidicon","Shaman",
						--"message","msgchainlightning",
					},
				},
			},
			-- Hex
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136512,
				execute = {
					{
						--"alert","HexCast",
						"expect",{"&dispell|curse&","==","true"},
						"alert","iHex",
					},
				},
			},
			-- LightningNova
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 137668,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnLightningNova",
					},
				},
			},
			-- BlazingSunlight
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136719,
				--srcnpcid = 69175,
				execute = {
					{
						"set",{Wastewalker = "#1#"},
						"raidicon","Wastewalker",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136725,
				--srcnpcid = 69175,
				execute = {
					{
						"set",{Wastewalker = "#1#"},
						"raidicon","Wastewalker",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136719,
				execute = {
					{
						"expect",{"&dispell|magic&","==","true"},
						"alert","iblazingsunlight",
					},
				},
			},
			-- DinoForm (use Orb  of control)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137237,
				execute = {
					{
						"alert","warndinoform",
					},
				},
			},
			-- Headache
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137294,
				execute = {
					{
						"batchalert",{"Headache","iHeadache"},
						"scheduletimer",{"life",1},
					},
				},
			},
			-- Rampage
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136821, -- for some reason its get spammed on the entire fight, Blizzard bug?
				execute = {
					{
						"expect",{"<jalak>","==","1"},
						"alert","warnrampage",
					},
				},
			},
			-- bestialcry
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136817,
				execute = {
					{
						"message","msgbestialcry",
						"alert","bestialcrycd",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 136817,
				execute = {
					{
						"message",{"msgbestialcry", text = 2},
						"alert","bestialcrycd"
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","69374"},
						"quash","bestialcrycd",
					},
				},
			},
			-- Mending
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136797,
				execute = {
					{
						"batchalert",{"warnMending","msgMending"},
					},
				},
			},
		    -- DoubleSwipe
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136741,
				execute = {
					{
						"alert","warndoubleSwipe",
					},
					{
						"expect",{"&timeleft|chargecd|0&","<","32"},
						"alert","doubleSwipecd",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136770,
				execute = {
					{
						"alert","warndoubleSwipe",
						"alert",{"doubleSwipecd", time = 2},
					},
				},
			},
			-- Puncture
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136767,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"set",{warnpuncturestext = format("%s: %s %s!",SN[136767],L.alert["on"],L.alert["YOU"])},
						"quash","puncturestacks",
						"batchalert",{"puncturestacks","puncturecd"},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","puncturestacks",
						"alert",{"puncturestacks", text = 3},
						"alert","puncturecd",
						"message","msgpuncture",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 136767,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","puncturestacks",
						"alert",{"puncturestacks", text = 2},
						"alert","puncturecd",
						"invoke",{
							{
								"expect",{"#11#",">=","9"},
								"set",{warnpuncturestext = format("%s: %s %s #11#!",SN[136767],L.alert["already at"],L.alert["Stacks"])},
								"alert",{"warnpuncture", text = 2},
							},
						},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","puncturestacks",
						"alert",{"puncturestacks", text = 4},
						"alert","puncturecd",
						"invoke",{
							{
								"expect",{"#11#","<","9"},
								"message",{"msgpuncture", text = 2},
							},
							{
								"expect",{"#11#",">=","9"},
								"message",{"msgpuncture", text = 3},
							},
						},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"expect",{"&playerdebuff|"..SN[136767].."&","==","false"},
						"alert","ipunctures",
					},
				},     
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136767,
				execute = {
					{
						"quash","puncturestacks",
					},
				},
			},
			-- Cracked Shell
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137240,
				execute = {
					{
						"message","msgcrackedshell",
					},
				},     
			},
			-- Cracked Shell (Phase 4)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 137240,
				execute = {
					{
						"expect",{"#11#","==","4"},
						"expect",{"<jalak>","==","0"},
						"alert","Jalakcd",
						"canceltimer",{"life"},
					},
					{
						"message",{"msgcrackedshell", text = 2},
					},
				},     
			},
			-- FrozenBolt
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 136573,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnFrozenBolt",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_MISS",
				spellname = 136573,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnFrozenBolt",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136564,
				--srcnpcid = 69178,
				execute = {
					{
						"set",{Warlord = "#1#"},
						"raidicon","Warlord",
					},
				},
			},
			-- LightningNova
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 136490,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnLightningNova",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_MISS",
				spellname = 136490,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnLightningNova",
					},
				},
			},
			-- SandTrap
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 136723,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnSandTrap",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_MISS", 
				spellname = 136723,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnSandTrap",
					},
				},
			},
			-- direcall (heroic)
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 137458,
				execute = {
					{
						"alert","direcallcd",
						"message","msgdirecall",
					},
				},
			},
			-- DireFixate
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 140946,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","warnDireFixate",
						"scheduletimer",{"timerFixated",1},
					},
					{
						"message","msgDireFixate",
					},
				},
			},
			-- Swipe
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 136463,
				--srcnpcid = 69177,
				execute = {
					{
						"set",{Warbear = "#1#"},
						"raidicon","Warbear",
					},
				},
			},
			-- Emotes
			{
				type = "event",
				event = "EMOTE", 
				execute = {
					-- Charge
					{
						"expect",{"#1#","find",L.chat_ThroneOfThunder["(stamps his tail!)"]},
						"invoke",{
							{
								"batchalert",{"chargecd","chargecast"},
								"message","msgcharge",
							},
							{
								"expect",{"#5#","==","&playername&"},
								"announce","chargesay",
								"alert","warncharge",
							},
						},
					},
					-- newForces	
					{
						"expect",{"#1#","find",L.chat_ThroneOfThunder["(forces pour from the)"]},
						--"batchalert",{"doorcd","Dinocd"}
						"alert","Dinocd",
						"set",{door = "INCR|1"},
						"invoke",{
							{
								"expect",{"<door>","==","1"},
								--"batchalert",{"addscd","doorcd"},
								"alert","addscd",
								"message","msgaddssoon",
								"scheduletimer",{"timerAdds",18.9},
								"tracing",{68476,69175}, --Wastewalker
							},
							{
								"expect",{"<door>","==","2"},
								"alert",{"addscd", text = 2},
								"message",{"msgaddssoon", text = 2},
								"scheduletimer",{"timerAdds",18.9},
								"tracing",{68476,69164}, -- priest
							},
							{
								"expect",{"<door>","==","3"},
								"alert",{"addscd", text = 3},
								"message",{"msgaddssoon", text = 3},
								"scheduletimer",{"timerAdds",18.9},
								"tracing",{68476,69178}, --warlord
							},
							{
								"expect",{"<door>","==","4"},
								"alert",{"addscd", text = 4},
								"alert",{"Jalakcd", text = 2},
								"message",{"msgaddssoon", text = 4},
								"scheduletimer",{"timerAdds",18.9},
								"tracing",{68476,69177,69176}, -- warbear&shaman
							},
							{
								"expect",{"<door>","~=","4"},
								"alert","doorcd",
							},
						},
					},
				},
			},
		},
		
	}
	--newForces		= "forces pour from the",--Farraki forces pour from the Farraki Tribal Door!
	--chargeTarget	= "stamps his tail!"--Horridon sets his eyes on Eraeshio and stamps his tail!
	DXE:RegisterEncounter(data)
end
