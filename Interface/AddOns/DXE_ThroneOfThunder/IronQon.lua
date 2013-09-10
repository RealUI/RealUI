local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST
--TODO
--local ArcingDebuff = GetSpellInfo(136193)
do
	local data = {
		version = 12,
		key = "Iron Qon",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Iron Qon"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-IRON QON.BLP:35:35",
		triggers = {
			scan = { 68079 }, --Ro'shak 68079, Quet'zal 68080, Dam'ren 68081, Iron Qon 68078
		},
		onactivate = {
			tracing = { 
				68079,
				powers={true},
			},
			tracerstart = true,
			combatstop = true,
			defeat = { 68078 },
			unittracing = {
				"boss1","boss2","boss3","boss4",
			},
		},
		enrage = {
			time10n = 720,
			time25n = 720,
			time10h = 720,
			time25h = 720,
			time25lfr = 720,
		},
		windows = {
			proxwindow = true,
		},
		onstart = {
			{
				"alert","throwspearcd",
				--"set",{bossid = 68079},
				--"scheduletimer",{"timerThrowSpear",1},
				"scheduletimer",{"timerCheckSpear",25},
			},
			{
				"expect",{"&difficulty&","<","3"}, --normal			
				"openwindow",{"10"},
			},
			{
				"expect",{"&difficulty&",">=","3"}, --10h&25h
				"tracing",{	68078,68079,68080,68081 },
				"alert",{"whirlingwindscd", time = 2},
				"alert","lightningstormcd",
				"openwindow",{"12"},
			},
		},
		userdata = {
			phase = 1,
			bossid = 68079,
			arcingUnits = {type = "container", wipein = 1.5},
		},
		raidicons = {
			--[[arcingicon = {
				varname = SN[136193],
				type = "FRIENDLY",
				persist = 15,
				unit = "#5#",
				icon = 1,
			},--]]
			lightningicon = {
				varname = SN[136192],
				type = "FRIENDLY",
				persist = 15,
				unit = "#5#",
				icon = 2,
			},
		},
		arrows = {
			lightningarrow = {
				varname = SN[136192],
				unit = "#5#",
				persist = 15,
				action = "TOWARD",
				msg = L.alert["Free him!"],
				spell = SN[136192],
				sound = "ALERT5",
				range1 = 2,
				range2 = 8,
				range3 = 14,
			},
			Speararrow = {
				varname = SN[134926],
				unit = "&upvalue&", --speartarget
				persist = 6,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = SN[134926],
				range1 = 15,
				range2 = 17,
				range3 = 20,
			},
		},
		announces = {
			throwspearsay = {
				varname = format(L.alert["%s %s %s!"],SN[134926],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s!"],SN[134926],L.alert["on"],L.alert["Me"]),
			},
		},
		timers = {
			timerArcing = {
				{
					"message","msgarcing",
				},
			},
			timerCheckArcing = {
				{
					"expect",{"&playerdebuff|"..SN[136193].."&","==","true"},
				--	"alert","iarcingstayaway",
					"scheduletimer",{"timerCheckArcing",2},					
				},
				{
					"expect",{"&playerdebuff|"..SN[136193].."&","==","false"},
					"alert","iarcinggonear",
					"closewindow",
				},
			},
			--[[timerThrowSpear = {
				{
					"expect",{"&timeleft|throwspearcd|0&","<","3"},
					"alert","throwspearsoon",
					--"scheduletimer",{"timerThrowSpear",5},
				},
				{
					"expect",{"&timeleft|throwspearcd|0&",">","3"},
					--"scheduletimer",{"timerThrowSpear",1},
				},
			},--]]
			timerCheckSpear = {
				{
					"target",{
						--source = "#1#",
						npcid = "<bossid>",
						wait = 0.2,
						schedule = 700,
						exclude = "MONK",
						excludeyards = 15,
						--raidicon = "Focusedmark",
						arrow = "Speararrow",
						--arrowdef = "<",
						--arrowrange = 40,
						announce = "throwspearsay",
						message = "msgThrowSpear",
						--alerts = {
							--self = "warnthrowspearself",
							--other = 
						--	unknown = "Phase4",
							--unknownmsg = {"msgThrowSpear", text = 2},
							--unknownmsg = "msgThrowSpear2",
						--},
					},
				},
			},
			--[[timerCheckSpear2 = {
				{
					-- tft_unitexists, tft_unitname
					"expect",{"&unitexist|boss1target&","==","1"}, 
					"invoke",{
						{
							"set",{tank = "&istargettank|boss1target&"},
							"set",{speartarget = "&targetname|boss1target&"},
						},
						{
							"expect",{"<tank>","==","false"},
							"invoke",{
								{
									"message",{"msgThrowSpear", text = 2},
								},
								{
									"expect",{"<speartarget>","==","&playername&"},
									"announce","throwspearsay",
								},
								{
									"expect",{"&inrange|<speartarget>&","<","11"},
									"alert","ithrowspearnear",
									"arrow","Speararrow",
								},
							}
						},
						{
							"expect",{"<tank>","==","true"},
							--"scheduletimer",{"timerCheckSpear",0.02},
						},
					},
				},
				{
					"expect",{"&unitexist|boss1target&","==","0"},
					--"scheduletimer",{"timerCheckSpear",0.02},
				},
			},--]]
		},
		messages = {
			msgThrowSpear = {
				varname = format(L.alert["%s!"],SN[134926]),
				type = "message",
				text = format(L.alert["%s %s &upvalue&"],SN[134926],L.alert["on"]),
				text2 = format(L.alert["%s"],SN[134926]),
				color1 = "RED",
				icon = ST[134926],
				sound = "ALERT13",
			},
			msgmoltenOverload = {
				varname = format(L.alert["%s!"],SN[137221]),
				type = "message",
				text = format(L.alert["%s!"],SN[137221]),
				color1 = "RED",
				icon = ST[137221],
				sound = "ALERT13",
			},
			msglightningstorm = {
				varname = format(L.alert["%s %s %s"],SN[136192],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136192],L.alert["on"]),
				color1 = "RED",
				icon = ST[136192],
				sound = "ALERT13",
			},
			msgarcing = {
				varname = format(L.alert["%s %s %s"],SN[136193],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s &list|arcingUnits&"],SN[136193],L.alert["on"]),
				color1 = "BROWN",
				sound = "ALERT13",
				icon = ST[136193],
				throttle = 2,
				ex25 = true,
			},
			msgfreeze = {
				varname = format(L.alert["%s %s %s"],SN[135145],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[135145],L.alert["on"]),
				color1 = "RED",
				sound = "ALERT13",
				icon = ST[135145],
				enabled = false,
			},
			msgrising = {
				varname = format(L.alert["%s %s %s"],SN[136323],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[136323],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[136323],L.alert["on"]),
				color1 = "VIOLET",
				sound = "ALERT13",
				icon = ST[136323],
			},
			msgImpale = {
				varname = format(L.alert["%s %s %s (2)"],SN[134691],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[134691],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[134691],L.alert["on"]),
				color1 = "ORANGE",
				sound = "ALERT13",
				icon = ST[134691],
			},
		},
		alerts = {
			-- Cooldowns
			throwspearcd = {
				varname = format(L.alert["%s Cooldown"],SN[134926]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[134926]),
				time = 33,
				color1 = "NEWBLUE",
				icon = ST[134926],
			},
			lightningstormcd = {
				varname = format(L.alert["%s Cooldown"],SN[136192]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136192]),
				time = 20,
				time2 = 17,
				color1 = "NEWBLUE",
				icon = ST[136192],
			},
			windstormcd = {
				varname = format(L.alert["%s Cooldown"],SN[136577]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136577]),
				time = 70,
				time2 = 52,
				time3 = 50,
				audiocd = true,
				audiotime = 5,	
				color1 = "NEWBLUE",
				icon = ST[136577],
			},
			deadzonecd = {
				varname = format(L.alert["%s Cooldown"],SN[137229]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137229]),
				time = 15,
				time2 = 6,
				time3 = 8.5,
				color1 = "NEWBLUE",
				icon = ST[137229],
			},
			risingangercd = {
				varname = format(L.alert["%s Cooldown"],SN[136323]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136323]),
				time = 20,
				time2 = 15,
				time3 = 27,
				color1 = "NEWBLUE",
				icon = ST[136323],
				enabled = false,
			},
			fistsmashcd = {
				varname = format(L.alert["%s Cooldown"],SN[136146]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136146]),
				time = 20,
				time2 = 25,
				time3 = 62,
				color1 = "NEWBLUE",
				icon = ST[136146],
			},
			unleashedflamecd = {
				varname = format(L.alert["%s Cooldown"],SN[134611]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[134611]),
				time = 6,
				time2 = 30,
				color1 = "NEWBLUE",
				icon = ST[134611],
			},
			whirlingwindscd = { -- Heroic
				varname = format(L.alert["%s Cooldown"],SN[139167]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[139167]),
				time = 30,
				time2 = 17,
				color1 = "NEWBLUE",
				icon = ST[139167],
			},
			frostspikecd = { -- Heroic
				varname = format(L.alert["%s Cooldown"],SN[139180]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[139180]),
				time = 13,
				time2 = 15,
				color1 = "NEWBLUE",
				icon = ST[139180],
			},
			freezecd = { -- heroic
				varname = format(L.alert["%s Cooldown"],SN[135145]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[135145]),
				time = 7,
				time2 = 36,
				time3 = 13,
				color1 = "NEWBLUE",
				icon = ST[135145],
				enabled = false,
			},
			-- Warnings
			Phase2 = {
				varname = format(L.alert["Phase 2"]),
				type = "simple",
				text = format(L.alert["Phase 2"]),
				time = 2,
				color1 = "ORANGE",
				icon = ST[136577],
				sound = "ALERT14",
			},
			Phase3 = {
				varname = format(L.alert["Phase 3"]),
				type = "simple",
				text = format(L.alert["Phase 3"]),
				time = 2,
				color1 = "GOLD",
				icon = ST[137229],
				sound = "ALERT14",
			},
			Phase4 = {
				varname = format(L.alert["Phase 4"]),
				type = "simple",
				text = format(L.alert["Phase 4"]),
				time = 2,
				color1 = "GREEN",
				icon = ST[136146],
				sound = "ALERT14",
			},
			warnfishsmash = {
				varname = format(L.alert["%s!"],SN[136147]),
				type = "simple",
				text = format(L.alert["%s!"],SN[136147]),
				color1 = "TAN",
				sound = "ALERT13",
				icon = ST[136147],
				throttle = 5,
			},
			warnunleashedflame = {
				varname = format(L.alert["%s!"],SN[134611]),
				type = "simple",
				text = format(L.alert["%s!"],SN[134611]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT13",
				icon = ST[134611],
				enabled = false,
			},
			warnwhirlingwinds = { -- Heroic
				varname = format(L.alert["%s!"],SN[139167]),
				type = "simple",
				text = format(L.alert["%s!"],SN[139167]),
				time = 2,
				color1 = "TAN",
				sound = "ALERT13",
				icon = ST[139167],
			},
			warnfrostspike = { -- heroic
				varname = format(L.alert["%s!"],SN[139180]),
				type = "simple",
				text = format(L.alert["%s!"],SN[139180]),
				time = 2,
				color1 = "TAN",
				sound = "ALERT13",
				icon = ST[139180],
			},
			warnwindstorm = {
				varname = format(L.alert["%s!"],SN[136577]),
				type = "simple",
				text = format(L.alert["%s!"],SN[136577]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[136577],
				--throttle = 2,
			},
			warnwindstormover = {
				varname = format(L.alert["%s %s!"],SN[136577],L.alert["Over"]),
				type = "simple",
				text = format(L.alert["%s %s!"],SN[136577],L.alert["Over"]),
				time = 2,
				color1 = "GREEN",
				sound = "ALERT10",
				icon = ST[136577],
				--throttle = 2,
			},
			arcingself = {
				varname = format(L.alert["%s %s %s!"],SN[136193],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[136193],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "ORANGE",
				icon = ST[136193],
				sound = "ALERT2",
			},
			--[[throwspearsoon = {
				varname = format("%s %s! (2-6s)",SN[134926],L.alert["Soon"]),
				type = "simple",
				text = format("%s %s! (2-6s)",SN[134926],L.alert["Soon"]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT10",
				icon = ST[134926],
			},--]]
			-- Inform
			iarcingstayaway = {
				varname = format(L.alert["%s %s!"],SN[136193],L.alert["Stay away"]),
				type = "inform",
				text = format(L.alert["%s %s!"],SN[136193],L.alert["Stay away"]),
				time = 2,
				color1 = "RED",
				--sound = "ALERT11",
				icon = ST[136193],
			},	
			iarcinggonear = {
				varname = format(L.alert["%s %s!"],SN[136193],L.alert["Go near other players"]),
				type = "inform",
				text = format(L.alert["%s %s!"],SN[136193],L.alert["Go near other players"]),
				time = 2,
				color1 = "GREEN",
				sound = "ALERT14",
				icon = ST[136193],
			},	
			ithrowspearnear = {
				varname = format(L.alert["%s %s %s!"],SN[134926],L.alert["near"],L.alert["YOU"]),
				type = "inform",
				text = format(L.alert["%s %s %s!"],SN[134926],L.alert["near"],L.alert["YOU"]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT10",
				icon = ST[134926],
				throttle = 2,
			},
			iStormMoveAway = {
				varname = format(L.alert["%s %s, %s!"],SN[137669],L.alert["under you"],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s %s, %s!"],SN[137669],L.alert["under you"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[137669],
				throttle = 2,
			},
			iBurningMoveAway = {
				varname = format(L.alert["%s %s, %s!"],SN[137668],L.alert["under you"],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s %s, %s!"],SN[137668],L.alert["under you"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[137668],
				throttle = 2,
			},
			iFrozenMoveAway = {
				varname = format(L.alert["%s %s, %s!"],SN[136520],L.alert["under you"],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s %s, %s!"],SN[136520],L.alert["under you"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT10",
				icon = ST[136520],
				throttle = 2,
			},
			iImpale = {
				varname = format(L.alert["%s %s %s 2!"],SN[134691],L.alert["Stacks"],L.alert["already at"]),
				type = "inform",
				text = format(L.alert["%s %s %s #11#!"],SN[134691],L.alert["Stacks"],L.alert["already at"]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT10",
				icon = ST[134691],
			},
			iScorched = {
				varname = format(L.alert["%s %s %s 2!"],SN[134647],L.alert["Stacks"],L.alert["already at"]),
				type = "inform",
				text = format(L.alert["%s %s %s #11#!"],SN[134647],L.alert["Stacks"],L.alert["already at"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[134647],
			},
			warndeadzone = {
				varname = format(L.alert["%s %s - %s"],SN[137226],L.alert["Back"],L.alert["Front"]),
				type = "inform",
				text = format(L.alert["%s %s - %s"],SN[137226],L.alert["Front"],L.alert["Right"]),
				text2 = format(L.alert["%s %s - %s"],SN[137226],L.alert["Left"],L.alert["Right"]),
				text3 = format(L.alert["%s %s - %s"],SN[137226],L.alert["Left"],L.alert["Front"]),
				text4 = format(L.alert["%s %s - %s"],SN[137226],L.alert["Back"],L.alert["Front"]),
				text5 = format(L.alert["%s %s - %s"],SN[137226],L.alert["Back"],L.alert["Left"]),
				text6 = format(L.alert["%s %s - %s"],SN[137226],L.alert["Back"],L.alert["Right"]),
				time = 2,
				color1 = "ORANGE",
				icon = ST[137226],
				throttle = 3,
				--sound = "ALERT2",
			},
			-- Debuff
			ScorchedDebuff = {
				varname = format(L.alert["%s Debuff"],SN[134647]),
				type = "debuff",
				text = format(L.alert["#5#: %s (1)"],SN[134647]),
				text2 = format(L.alert["#5#: %s (#11#)"],SN[134647]),
				text3 = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[134647]),
				text4 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[134647]),
				time = 30,
				color1 = "NEWBLUE",
				icon = ST[134647],
				tag = "#5#",
				exdps = true,
				ex25 = true,
			},
			ImpaleDebuff = {
				varname = format(L.alert["%s Debuff"],SN[134691]),
				type = "debuff",
				text = format(L.alert["#5#: %s (1)"],SN[134691]),
				text2 = format(L.alert["#5#: %s (#11#)"],SN[134691]),
				text3 = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[134691]),
				text4 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[134691]),
				time = 40,
				color1 = "ORANGE",
				icon = ST[134691],
				tag = "#5#",
				exdps = true,
				--ex25 = true,
			},
			Arcingdebuff = {
				varname = format(L.alert["%s Debuff"],SN[136193]),
				type = "debuff",
				text = format("%s: %s",L.alert["YOU"],SN[136193]),
				text2 = format("#5#: %s",SN[136193]),
				time = 30,
				color1 = "RED",
				icon = ST[136193],
				tag = "#5#",
				ex25 = true,
				enabled = false,
			},
			-- Center
			moltenOverload = {
				varname = format(L.alert["%s Active"],SN[137221]),
				type = "centerpopup",
				text = format(L.alert["%s Active"],SN[137221]),
				time = 10,
				color1 = "RED",
				icon = ST[137221],
			},		
			fistsmashact = {
				varname = format(L.alert["%s Active"],SN[136147]),
				type = "dropdown",
				text = format(L.alert["%s Active"],SN[136147]),
				time = 8,
				color1 = "RED",
				icon = ST[136147],
			},
			--[[freeze = {
				varname = format(L.alert["%s %s"],SN[135145],L.alert["Active"]),
				type = "centerpopup",
				text = format(L.alert["%s %s"],SN[135145],L.alert["Active"]),
				time = 30,
				color1 = "RED",
				icon = ST[135145],
			},--]]	
		},
		events = {
			-- storm cloud
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 137669,
				dstisplayerunit = true,
				execute = {
					{
						"alert","iStormMoveAway",
					},
				},
			},
			-- burning cinders
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 137668,
				dstisplayerunit = true,
				execute = {
					{
						"alert","iBurningMoveAway",
					},
				},
			},
			-- Frozen Blood
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 136520,
				dstisplayerunit = true,
				execute = {
					{
						"alert","iFrozenMoveAway",
					},
				},
			},
			-- wind storm
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136577,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnwindstorm",
						"quash","lightningstormcd",
					},
				},
			},
			-- lightningstorm
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136192,
				execute = {
					{
						"alert","lightningstormcd",
						"raidicon","lightningicon",
						"arrow","lightningarrow",
						"message","msglightningstorm",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136192,
				execute = {
					{
						"removeraidicon","#5#",
						"removearrow","#5#",
					},
				},
			},
			-- Arcing
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136193, 
				execute = {
					{
					--	"raidicon","arcingicon",
						"expect",{"&unitisplayer|#5#&","==","true"},
						"invoke", {
							{
								"expect",{"&lfr&","==","false"},
								"insert",{"arcingUnits","#5#"},
								"canceltimer","timerArcing",
								"scheduletimer",{"timerArcing",0.5},
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								--"set",{arcingunit = "#5#"},
							--	"arrow","Arcingarrow",
							--	"message","msgarcing",
								"alert",{"Arcingdebuff", text = 2},
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								--"announce","arcingsay",
								"openwindow",{"12"},
								"batchalert",{"arcingself","Arcingdebuff"},
							},
							{
								"expect",{"<phase>","==","4"},
								"scheduletimer",{"timerCheckArcing",5},
							},
						},
					},
				},
			},
			--[[{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136193,
				execute = {
					{
						"removeraidicon","#5#",
					--	"removearrow","#5#",
					},
				},
			},--]]
			-- throw spear
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = {134926,},
				--srcnpcid = 68078, -- Iron Qon
				execute = {
					{
						"expect",{"<phase>","~=","4"},
						--"canceltimer","timerThrowSpear",
						"canceltimer","timerCheckSpear",
						--"message",{"msgThrowSpear", text = 2}, -- to be disabled
						"alert","throwspearcd",
						--"scheduletimer",{"timerThrowSpear",15},
						"scheduletimer",{"timerCheckSpear",25},
					},
				},
			},
			-- Scorched
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 134647,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert",{"ScorchedDebuff",text = 3},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"expect",{"&unitisplayer|#5#&","==","true"},
						"alert","ScorchedDebuff",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 134647,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert",{"ScorchedDebuff",text = 4},
						"expect",{"#11#",">=","2"},
						"alert","iScorched",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"expect",{"&unitisplayer|#5#&","==","true"},
						"alert",{"ScorchedDebuff",text = 2},
					},
				},     
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 134647,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","ScorchedDebuff",
					},
				},
			},
			-- Impale
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 134691,
				execute = {
					{
						"expect",{"&unitisplayer|#5#&","==","true"},
						"invoke",{
							{
								"message","msgImpale",
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"alert",{"ImpaleDebuff",text = 3},
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"alert","ImpaleDebuff",
							},
						},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 134691,
				execute = {
					{
						"expect",{"&unitisplayer|#5#&","==","true"},
						"invoke",{					
							{
								"message",{"msgImpale", text = 2},
							},				
							{
								"expect",{"#4#","==","&playerguid&"},
								"alert",{"ImpaleDebuff",text = 4},
								"invoke",{
									"expect",{"#11#",">=","3"},
									"alert","iImpale",
								},
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"alert",{"ImpaleDebuff",text = 2},
							},
						},
					},
				},     
			},
			-- Molten Core
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137221,
				execute = {
					{
						"message","msgmoltenOverload",
						"alert","moltenOverload",
					},
				},
			},
			------
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","68079"},  --Ro'shak
						--"tracing",{	68080 },
						"set",{bossid = 68080},
						"batchquash",{"moltenOverload","unleashedflamecd"},
						"invoke",{
							{
								"expect",{"&difficulty&","<","3"}, --normal
								"set",{phase = 2},
								"tracing",{	68080 },
								"alert",{"windstormcd", time = 3},
								"alert",{"lightningstormcd", time = 2},
								"alert","throwspearcd",
								"alert","Phase2",
								"openwindow",{"10"},
								--"cancelalert",{"warnwindstorm"},
								--"schedulealert",{"warnwindstorm",50},					
								"canceltimer","timerCheckSpear",
								"scheduletimer",{"timerCheckSpear",25},
							},
						},
					},
					{
						"expect",{"&npcid|#4#&","==","68080"},  -- Quet'zal----
						--"tracing",{	68081 },
						"set",{bossid = 68081},
						"batchquash",{"lightningstormcd","windstormcd"},
						"closewindow",
						"invoke",{
							{
								"expect",{"&difficulty&","<","3"}, --normal
								"tracing",{	68081 },
								"set",{phase = 3},
								"alert","Phase3",
								"alert","throwspearcd",
								"alert",{"deadzonecd", time = 2},	
								"canceltimer","timerCheckSpear",
								"scheduletimer",{"timerCheckSpear",25},								
							},
						},
					},
					{
						"expect",{"&npcid|#4#&","==","68081"},  -- Dam'ren---
						"batchquash",{"deadzonecd","freezecd"},
						"invoke",{
							{
								"expect",{"&difficulty&","<","3"}, --normal
								"tracing",{	68078 },
								"set",{phase = 4},
								"batchalert",{"Phase4","risingangercd"},
								"canceltimer","timerCheckSpear",
								"quash","throwspearcd",
								"alert",{"fistsmashcd", time = 2},
							},
							{
								"expect",{"&playerdebuff|"..SN[136193].."&","==","true"},
								"alert","iarcingstayaway",
								"openwindow",{"12"},
								"scheduletimer",{"timerCheckArcing",7},
							},
						},
					},
				},
			},
			-- dead zone
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				--spellname = 137226,
				spellid = {137226,},
				execute = {
					{
						"batchalert",{"warndeadzone","deadzonecd"},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				--spellname = 137227,
				spellid = {137227,},
				execute = {
					{
						"alert",{"warndeadzone", text = 2},
						"alert","deadzonecd",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				--spellname = 137228,
				spellid = {137228,},
				execute = {
					{
						"alert",{"warndeadzone", text = 3},
						"alert","deadzonecd",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				--spellname = 137229,
				spellid = {137229,},
				execute = {
					{
						"alert",{"warndeadzone", text = 4},
						"alert","deadzonecd",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				--spellname = 137230,
				spellid = {137230,},
				execute = {
					{
						"alert",{"warndeadzone", text = 5},
						"alert","deadzonecd",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				--spellname = 137231,
				spellid = {137231,},
				execute = {
					{
						"alert",{"warndeadzone", text = 6},
						"alert","deadzonecd",
					},
				},
			},
			-- Freeze
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 135145,
				execute = {
					{
						"message","msgfreeze",
					},
					{
						--"alert","freeze",
						"expect",{"<phase>","==","2"},
						"alert",{"freezecd", time = 2},
					},
					{
						"expect",{"<phase>","~=","2"},
						"alert","freezecd",
					},
				},
			},
			-- Rising Anger
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136323,
				execute = {
					{
						"message","msgrising",
						"alert","risingangercd",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 136323,
				execute = {
					{
						"message",{"msgrising",text = 2},
						"alert","risingangercd",
					},
				},     
			},
			----------------------------- 
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					{
						"expect",{"#5#","==","136146"}, -- FistSmash
						"batchalert",{"fistsmashact","warnfishsmash"},
						"invoke",{
							{
								"expect",{"&difficulty&",">=","3"}, --10h&25h
								"alert",{"fistsmashcd", time = 3},
							},
							{
								"expect",{"&difficulty&","<=","2"}, --normal
								"alert","fistsmashcd",
							},
						},
					},
					{
						"expect",{"#5#","==","137656"}, -- Rushing Winds (Wind storm ends)
						"invoke",{
							{
								"expect",{"<phase>","==","2"},
								"batchalert",{"windstormcd","warnwindstormover"},
								--"cancelalert",{"warnwindstorm"},
								--"schedulealert",{"warnwindstorm",70},
								--"alert","windstormcd",
							},
						},
					},
					{
						"expect",{"#5#","==","139172"}, -- Whirling Wind (heroic)
						"batchalert",{"warnwhirlingwinds","whirlingwindscd"},
					},
					{
						"expect",{"#5#","==","139181"}, -- Frost Spike (Phase 2 Heroic)
						"batchalert",{"warnfrostspike","frostspikecd"},
					},
					{
						"expect",{"#5#","==","134611"}, -- UnleashedFlame
						"alert","warnunleashedflame",
						"invoke", {
							{
								"expect",{"<phase>","==","1"},
								"alert","unleashedflamecd",
							},
							{
								"expect",{"<phase>","~=","1"},
								"alert",{"unleashedflamecd", time = 2},
							},
						},
					},
					{
						"expect",{"#5#","==","50630"}, -- Heroic trigger
						"canceltimer","timerCheckSpear",
						"alert","throwspearcd",
						"invoke",{
							{
								"expect",{"#1#","==","boss2"},  --Ro'shak
								"set",{phase = 2},
								"set",{bossid = 68080},
								"openwindow",{"10"},
								"batchquash",{"unleashedflamecd","moltenOverload","whirlingwindscd"},
								"batchalert",{"Phase2","lightningstormcd"},
								"alert",{"windstormcd", time = 2},
								"scheduletimer",{"timerCheckSpear",25},
								"invoke",{
									{
										"expect",{"&difficulty&",">=","3"}, --10h&25h
										"alert",{"frostspikecd", time = 2},
										"alert",{"freezecd", time = 3},
									},
								},
							},
							{
								"expect",{"#1#","==","boss3"},  --Quet'zal
								"openwindow",{"10"},
								"batchquash",{"lightningstormcd","windstormcd","frostspikecd"},
								"set",{phase = 3},
								"set",{bossid = 68081},
								"alert","Phase3",
								"alert",{"deadzonecd", time = 3},
								"scheduletimer",{"timerCheckSpear",25},
							},
							{
								"expect",{"#1#","==","boss4"},  --Dam'ren
								"batchquash",{"deadzonecd","unleashedflamecd"},
								"set",{phase = 4},
								"alert","Phase4",
								"alert",{"fistsmashcd", time = 3},
								"alert",{"risingangercd", time = 2},
								"invoke",{
									{
										"expect",{"&playerdebuff|"..SN[136193].."&","==","true"},
										"alert","iarcingstayaway",
										"openwindow",{"12"},
										"scheduletimer",{"timerCheckArcing",3},
									},
								},
							},
						},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
