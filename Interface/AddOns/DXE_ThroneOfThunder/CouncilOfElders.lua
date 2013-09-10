local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST
--TODO:
do
	local data = {
		version = 16,
		key = "Council of Elders",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Council of Elders"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-COUNCIL OF ELDERS.BLP:35:35",
		triggers = {
			scan = { 69078, 69132, 69134, 69131 }, 
		},
		onactivate = {
			tracing = {	69078, 69132, 69134, 69131	},
			tracerstart = true,
			combatstop = true,
			defeat = {	69078, 69132, 69134, 69131 },
			unittracing = {	"boss1","boss2","boss3","boss4" },
		},
		windows = {
			proxwindow = true,
			proxrange = 7,
		},
		enrage = {
			time10n = 600,
			time25n = 600,
			time10h = 600,
			time25h = 600,
			time25lfr = 600,
		},
		arrows = {
			BittingColdarrow = {
				varname = SN[136992],
				unit = "#5#", --<BitingColdTarget>
				persist = 5,
				action = "AWAY",
				msg = L.alert["STAY AWAY!"],
				spell = SN[136992],
				range1 = 7,
				range2 = 8,
				range3 = 9,
			},
		},
		raidicons = {
			BitingColdmark = {
				varname = SN[136992],
				type = "FRIENDLY",
				persist = 30,
				unit = "#5#",
				icon = 7,
			},
			MarkedSoulicon = {
				varname = SN[137203],
				type = "FRIENDLY",
				persist = 30,
				--reset = 1,
				unit = "#5#",
				icon = 5,
				--total = 1,
			},
			Possessedicon = {
				varname = SN[136442],
				type = "ENEMY",
				persist = 90,
				--reset = 1,
				unit = "#5#",
				icon = 1,
				--total = 1,
			},		
			Frostbiteicon = {
				varname = SN[136922],
				type = "FRIENDLY",
				persist = 90,
				--reset = 1,
				unit = "#5#",
				icon = 6,
				--total = 1,
			},				
		},
		userdata = {
			--recklesscharge = {10,6,loop = false, type = "series"},
			--recklesscharge = 6,
			--bittingcold = {15,45,loop = false, type = "series"},
			bittingcold = 15,
			frostbite = 0,
			--quicksand = {8,33,loop = false, type = "series"},
			--blessedloaSpirit = {25,35,loop = false, type = "series"},
			quicksand = 8,
			blessedloaSpirit = 25,
			shadowedLoaSpirit = 0,
			KazraPossessed = 0,
			SulPossessed = 0,
			FrostPossessed = 0,
			PrestessPossessed = 0,
			--frigidtext = "",
			SandBoltcount = 0,
			warnfrigidtext = "",
			twistedfatetime = 0,
			chilledWarned = "no",
			--BitingColdTarget = "no",
			HPtoGo = 0,
			percHP = 0,
			Priest = "",
		},
		timers = {
			--[[timerBlessedLoaSpirit = {
				"alert","warnBlessedLoaSpirit",
			},
			timerShadowedLoaSpirit = {
				"alert","warnShadowedLoaSpirit",
			},--]]
			timerResetChilled = {
				{
					"set",{chilledWarned = "no"},
				},
			},
			--[[timerBittingCold = {
				{
					"expect",{"<BitingColdTarget>","~=","no"},
					"invoke",{
						{
							"expect",{"&inrange|<BitingColdTarget>&","<","10"},
							"arrow","BittingColdarrow",
						},
						{
							"scheduletimer",{"timerBittingCold",1},
						},
					},
				},
			},--]]
			--[[timerpowerpossed = {
				{
					"expect",{"<KazraPossessed>","==","1"},
					"set",{HP = "&percHPToGo|69134|25&"},
					"alert","ipercHPToGo",
				},
				{
					"expect",{"<SulPossessed>","==","1"},
					"set",{HP = "&percHPToGo|69078|25&"},
				},
				{
					"expect",{"<FrostPossessed>","==","1"},
					"set",{HP = "&percHPToGo|69131|25&"},
				},
				{
					"expect",{"<PrestessPossessed>","==","1"},
					"set",{HP = "&percHPToGo|69132|25&"},
				},				
				{
					"alert","Possessed",
				--	"expect",{"&timeleft|Possessed|0&",">=","1"},
				--	"scheduletimer",{"timerpowerpossed",1},
				},
			},--]]
		},
		onstart = {
			{
				"alert","recklesschargecd",
				"alert",{"blessedloaSpiritcd", time = 2},
				"alert",{"bittingcoldcd", time = 2},
				"alert",{"quicksandcd", time = 2},
			},
			{
				"expect",{"&lfr&","==","false"},
				"openwindow",{"7"},
			},
		},
		announces = {
			bitingColdsay = {
				varname = format(L.alert["%s %s %s"],SN[136992],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s"],SN[136992],L.alert["on"],L.alert["Me"]),
				--enabled = false,
			},
			markedsoulsay = {
				varname = format(L.alert["%s %s %s"],SN[137359],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s"],SN[137359],L.alert["on"],L.alert["Me"]),
			},
		},
		messages = {
			warnPossessed = {
				varname = format(L.alert["%s"],SN[136442]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136442],L.alert["on"]),
				color1 = "RED",
				icon = ST[136442],
				sound = "ALERT13",
			},
			--[[warnrecklesscharge = {
				varname = format(L.alert["%s"],SN[137122]),
				type = "message",
				text = format(L.alert["%s in 2 seconds!"],SN[137122]),
				color1 = "ORANGE",
				icon = ST[137122],
				sound = "ALERT13",
				throttle = 3,
			},--]]
			warnbitingCold = {
				varname = format(L.alert["%s"],SN[136992]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136992],L.alert["on"]),
				color1 = "NEWBLUE",
				icon = ST[136992],
				sound = "ALERT13",
			},
			warnfrostbite = {
				varname = format(L.alert["%s"],SN[136922]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136922],L.alert["on"]),
				color1 = "TEAL",
				icon = ST[136922],
				sound = "ALERT13",
			},
			warnBlessedLoa = {
				varname = format(L.alert["%s %s! (2s)"],SN[137203],L.alert["is about to SPAWN"]),
				type = "message",
				text = format(L.alert["%s %s! (2s)"],SN[137203],L.alert["is about to SPAWN"]),
				color1 = "GOLD",
				icon = ST[137203],
				sound = "ALERT13",
			},
			warnshadowedLoa = {
				varname = format(L.alert["%s %s! (2s)"],SN[137350],L.alert["is about to SPAWN"]),
				type = "message",
				text = format(L.alert["%s %s! (2s)"],SN[137350],L.alert["is about to SPAWN"]),
				color1 = "VIOLET",
				icon = ST[137350],
				sound = "ALERT13",
			},
			warnmarkedsoul = {
				varname = format(L.alert["%s"],SN[137359]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[137359],L.alert["on"]),
				color1 = "VIOLET",
				icon = ST[137359],
				sound = "ALERT13",
			},
			msgQuickSand = {
				varname = format(L.alert["%s"],SN[136521]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136521],L.alert["on"]),
				color1 = "NEWBLUE",
				icon = ST[136521],
				sound = "ALERT13",
			},
			--[[warnsandbolt = {
				varname = format(L.alert["%s"],SN[136189]),
				type = "message",
				text = format(L.alert["%s %s %s"],SN[136189],L.alert["on"],"&upvalue&"),
				color1 = "ORANGE",
				icon = ST[136189],
				sound = "ALERT13",
			},--]]
			--[[warnsoulfragment = {
				varname = format(L.alert["%s"],SN[137359]), -- <<< change this
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[137359],L.alert["on"]),
				color1 = "VIOLET",
				icon = ST[137359],
				sound = "ALERT13",
			},--]]
		},
		alerts = {	
			quicksandcd = {
				varname = format(L.alert["%s Cooldown"],SN[136521]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136521]),
				time = "<quicksand>",
				time2 = 8,
				time3 = 33,
				color1 = "NEWBLUE",
				icon = ST[136521],
			},
			recklesschargecd = {
				varname = format(L.alert["%s Cooldown"],SN[137122]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137122]),
				time = 6,
				time2 = 21,
				color1 = "NEWBLUE",
				icon = ST[137122],
			},
			bittingcoldcd = {
				varname = format(L.alert["%s Cooldown"],SN[136917]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136917]),
				time = "<bittingcold>",
				time2 = 15,
				time3 = 45,
				color1 = "NEWBLUE",
				icon = ST[136917],
				--ability = EJSN[136917],
			},
			frostbitecd = {
				varname = format(L.alert["%s Cooldown"],SN[136990]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136990]),
				time = "<frostbite>",
				time2 = 45,
				color1 = "NEWBLUE",
				icon = ST[136990],
			},
			meleewarnPossessed = {
				varname = format(L.alert["%s"],SN[136442]),
				type = "simple",
				text = format(L.alert["%s -> #5#!"],SN[136442]),
				time = 2,
				color1 = "RED",
				sound = "ALERT1",
				icon = ST[136442],
				--exhealer = true,
				extank = true,
			},
			blessedloaSpiritcd = {
				varname = format(L.alert["%s Cooldown"],SN[137203]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137203]),
				time = "<blessedloaSpirit>",
				time2 = 25,
				time3 = 33,
				color1 = "NEWBLUE",
				icon = ST[137203],
			},
			shadowedLoaSpiritcd = {
				varname = format(L.alert["%s Cooldown"],SN[137350]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137350]),
				time = "<shadowedLoaSpirit>",
				color1 = "NEWBLUE",
				icon = ST[137350],
			},
			twistedfatecd = {
				varname = format(L.alert["%s Cooldown"],SN[137891]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137891]),
				time = "<twistedfatetime>",
				color1 = "NEWBLUE",
				icon = ST[137891],
			},
			frigidAssaultcd = {
				varname = format(L.alert["%s Cooldown"],SN[136904]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136904]),
				time = 30,
				color1 = "NEWBLUE",
				icon = ST[136904],
			},
			warnfrigidAssault = {
				varname = format("%s %s 8 %s!",SN[136903],L.alert["already at"],L.alert["Stacks"]),
				type = "inform",
				text = format("%s %s 8 %s!",SN[136903],L.alert["already at"],L.alert["Stacks"]),
				text2 = "<warnfrigidtext>",
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[136903],
			},
			frigidAssault = {
				varname = format(L.alert["%s Debuff"],SN[136903]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[136903]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[136903]),
				text3 = format(L.alert["#5#: %s (1)"],SN[136903]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[136903]),
				time = 14.5,
				color1 = "NEWBLUE",
				icon = ST[136903],
				tag = "#5#",
			},
			bitingColdDebuff = {
				varname = format(L.alert["%s Debuff"],SN[136992]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[136992]),
				text2 = format(L.alert["#5#: %s"],SN[136992]),
				time = 30,
				color1 = "NEWBLUE",
				icon = ST[136992],
				tag = "#5#",
			},
			warnbiting = {
				varname = format(L.alert["%s %s %s"],SN[136992],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s"],SN[136992],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[136992],
				flashscreen = true,
			},
			iBiting = {
				varname = format(L.alert["%s %s %s"],SN[136992],L.alert["on"],L.alert["player"]),
				type = "inform",
				text = format(L.alert["%s %s #5#"],SN[136992],L.alert["on"]),
				text2 = format(L.alert["#5# %s %s"],SN[136992],L.alert["Removed"]),
				time = 2,
				color1 = "RED",
				--sound = "ALERT10",
				icon = ST[136992],
				extank = true,
				exdps = true,
			},
			warnfrostb = {
				varname = format(L.alert["%s %s %s"],SN[136990],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s"],SN[136990],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "NEWBLUE",
				sound = "ALERT10",
				icon = ST[136990],
				flashscreen = true,
			},
			ifrostb = {
				varname = format(L.alert["%s: %s"],SN[136990],L.alert["Go near other players"]),
				type = "inform",
				text = format(L.alert["%s: %s"],SN[136990],L.alert["Go near other players"]),
				time = 2,
				color1 = "RED",
				--sound = "ALERT10",
				icon = ST[136990],
			},
			ifrostbremoved = {
				varname = format(L.alert["%s %s: %s"],SN[136990],L.alert["Removed"],L.alert["Stay away"]),
				type = "inform",
				text = format(L.alert["%s %s: %s"],SN[136990],L.alert["Removed"],L.alert["Stay away"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[136990],
			},			
			frostbiteDebuff = {
				varname = format(L.alert["%s Debuff"],SN[136990]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[136990]),
				text2 = format(L.alert["#5#: %s"],SN[136990]),
				time = 30,
				color1 = "NEWBLUE",
				icon = ST[136990],
				tag = "#5#",
			},
			ShadowedSoulDebuff = {
				varname = format(L.alert["%s Debuff"],SN[137650]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[137650]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[137650]),
				text3 = format(L.alert["#5#: %s (1)"],SN[137650]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[137650]),
				time = 600,
				color1 = "RED",
				icon = ST[137650],
				tag = "#5#",
				static = true,
				ex25 = true,
			},
			iShadowedSoul = {
				varname = format(L.alert["%s: 2 %s"],SN[137650],L.alert["Stacks"]),
				type = "inform",
				text = format(L.alert["%s: #11# %s"],SN[137650],L.alert["Stacks"]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT13",
				icon = ST[136990],
			},	
			warnQuickSand = {
				varname = format(L.alert["%s %s, %s!"],SN[136521],L.alert["under you"],L.alert["MOVE AWAY"]),
				type = "simple",
				text = format(L.alert["%s %s, %s!"],SN[136521],L.alert["under you"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[136521],
				flashscreen = true,
			},
			warnEnsnared = {
				varname = format(L.alert["%s %s, %s!"],SN[136860],L.alert["near"],L.alert["MOVE AWAY"]),
				type = "simple",
				text = format(L.alert["%s %s, %s!"],SN[136860],L.alert["near"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = ST[136857],
				--flashscreen = true,
			},
			warnBlessedLoaSpirit = {
				varname = format(L.alert["%s %s, %s"],SN[137203],L.alert["Spawns"],L.alert["KILL IT!"]),
				type = "simple",
				text = format(L.alert["%s %s, %s"],SN[137203],L.alert["Spawns"],L.alert["KILL IT!"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[137203],
				--rangedonly = true, 
			},
			warnShadowedLoaSpirit = {
				varname = format(L.alert["%s %s, %s"],SN[137350],L.alert["Spawns"],L.alert["KILL IT!"]),
				type = "simple",
				text = format(L.alert["%s %s, %s"],SN[137350],L.alert["Spawns"],L.alert["KILL IT!"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[137350],
				--rangedonly = true, 
			},
			sandStormcd = {
				varname = format(L.alert["%s Cooldown"],SN[136894]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136894]),
				time = 35, -- ?
				color1 = "BROWN",
				icon = ST[136894],
			},
			warnSandStorm = {
				varname = format(L.alert["%s!"],SN[136894]),
				type = "simple",
				text = format(L.alert["%s!"],SN[136894]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT10",
				icon = ST[136894],
			},
			MarkedSoul = {
				varname = format(L.alert["%s %s %s"],SN[137359],L.alert["on"],L.alert["player"]),
				type = "centerpopup",
				text = format("%s %s #5#",SN[137359],L.alert["on"]),
				time = 20,
				flashtime = 5,
				color1 = "VIOLET",
				icon = ST[137359],
				tag = "#5#",
			},
			wMarkedSoul = {
				varname =  format(L.alert["%s %s %s %s!!"],SN[137359],L.alert["on"],L.alert["YOU"],L.alert["RUN"]),
				type = "simple",
				text =  format(L.alert["%s %s %s %s!!"],SN[137359],L.alert["on"],L.alert["YOU"],L.alert["RUN"]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT12",
				icon = ST[137359],
				flashscreen = true,
			},
			wSandBolt = {
				varname = format(L.alert["%s: %s!!"],SN[136189],L.alert["INTERRUPT"]),
				type = "inform",
				text = format(L.alert["%s: %s!!"],SN[136189],L.alert["INTERRUPT"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT1",
				icon = ST[136189],
				flashscreen = true,
				enabled = false,
			},
			SandBoltCast = {
				varname = format(L.alert["%s Casting"],SN[136189]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[136189]),
				time = 2,
				flashtime = 2,
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[136189],
				enabled = false,
			},
			warnchilled = { -- Heroic
				varname = format(L.alert["%s %s %s"],SN[137085],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s"],SN[137085],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "137085",
				icon = ST[137350],
				flashscreen = true,
			},
			Possessed = {
				varname = format(L.alert["%s %s"],L.chat_ThroneOfThunder["Possessed"],L.alert["Duration"]),
				type = "centerpopup",
				text = format(L.alert["%s %s"],L.chat_ThroneOfThunder["Possessed"],L.alert["Duration"]),
				time = 66,
				flashtime = 20,
				color1 = "RED",
				--sound = "ALERT2",
				icon = ST[136442],
			},
			iEntrapped = {
				varname = format(L.alert["%s %s %s!"],SN[136857],L.alert["Dispell"],L.alert["player"]),
				type = "inform",
				text = format(L.alert["%s #5#!"],L.alert["Dispell"]),
				time = 2,
				color1 = "ORANGE",
				--sound = "ALERT10",
				icon = ST[136857],
			},
			--[[ipercHPToGo = {
				varname = format(L.alert["%s: <percHP> -> <HPtoGo>"],SN[136442]),
				type = "inform",
				text = format(L.alert["%s: <percHP> -> <HPtoGo>"],SN[136442]),
				time = 2,
				color1 = "ORANGE",
				--sound = "ALERT10",
				icon = ST[136442],
			},--]]
		},
		events = {
		    -- Sand Bolt (spammy, off by default)
			--[[{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136189,
				execute = {
					{
						"alert","SandBoltCast",
						"set",{SandBoltcount = 0},
						"expect",{"&interrupt&","==","true"},
						"alert","wSandBolt",
					},
					{
						"target",{
							source = "#1#",
							wait = 0.2,
							--announce = "throwspearsay",
							message = "warnsandbolt",
							--schedule = "timerSandBolt",
							--alerts = {
								--self = "warnthrowspearself",
								--other = 
								--unknown = {"trapwarn",text = 2},
							--},
						},
					},
				},
			},--]]
			-- MarkedSoul
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137359,
				execute = {
					{
						"alert","MarkedSoul",
						"message","warnmarkedsoul",
						"raidicon","MarkedSoulicon",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"announce","markedsoulsay",
						"alert","wMarkedSoul",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 137359,
				execute = {
					{
						"quash","MarkedSoul",
						"removeraidicon","#5#",
					},
				},
			},
		    -- SandStorm
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136894,
				execute = {
					{
						"batchalert",{"warnSandStorm","sandStormcd"},
					},
				},
			},
			-- ShadowedLoaSpirit
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 137350,
				execute = {
					{
						--"alert","warnShadowedLoaSpirit",
						"alert","shadowedLoaSpiritcd",
						"message","warnshadowedLoa",
						"schedulealert",{"warnShadowedLoaSpirit",2.2},
					},
				},
			},
			--[[-- Summon ShadowedLoaSpirit
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = {69548, 137351, 137352, 137353, 137395, 137520 },
				execute = {
					{
						"alert","warnShadowedLoaSpirit",
						"arrow","ragingspiritarrow",
						"raidicon","spirits",
					},
				},
			},--]]
			-- BlessedLoaSpirit
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 137203,
				execute = {
					{
						--"alert","warnBlessedLoaSpirit",
						"alert",{"blessedloaSpiritcd", time = 3},
						"message","warnBlessedLoa",
						"schedulealert",{"warnBlessedLoaSpirit",2.2},
					},
				},
			},
			-- Possessed
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136442,
				execute = { -- Swap Timers on Possessed
					{
						"alert","meleewarnPossessed",
						"message","warnPossessed",
						"alert","Possessed",
						"raidicon","Possessedicon",
					},
					{
						"expect",{"&npcid|#4#&","==","69078"}, -- Sul the Sandcrawler
						--"set",{HPtoGo = "&percHPToGo|69078|25&"},
						--"set",{percHP = "&percHP|69078&"},
						--"alert","ipercHPToGo",
						"set",{SulPossessed = 1},
						--"scheduletimer",{"timerpowerpossed",1},
					},
					{
						"expect",{"&npcid|#4#&","==","69131"}, -- Frost King Malakk
						--"set",{HPtoGo = "&percHPToGo|69131|25&"},
						--"set",{percHP = "&percHP|69131&"},
						--"alert","ipercHPToGo",
						"set",{frostbite = "&timeleft|bittingcoldcd|0&"},
						"quash","bittingcoldcd",
						"alert","frostbitecd",
						"set",{FrostPossessed = 1},
						--"scheduletimer",{"timerpowerpossed",1},
					},
					{
						"expect",{"&npcid|#4#&","==","69132"}, -- High Prestess Mar'li
						--"set",{HPtoGo = "&percHPToGo|69132|25&"},
						--"set",{percHP = "&percHP|69132&"},
						--"alert","ipercHPToGo",
						"set",{PrestessPossessed = 1},
						--"scheduletimer",{"timerpowerpossed",1},
						--"expect",{"&timeleft|blessedloaSpiritcd&",">","0"}, 
						"invoke", {
							{
								"expect",{"&difficulty&","<=","2"}, --10n&25n
								"set",{shadowedLoaSpirit = "&timeleft|blessedloaSpiritcd|0&"},
								"quash","blessedloaSpiritcd",
								"alert","shadowedLoaSpiritcd",
							},
							{
								"expect",{"&difficulty&",">=","3"}, --10h&25h
								"set",{twistedfatetime = "&timeleft|blessedloaSpiritcd|0&"},
								"quash","blessedloaSpiritcd",
								"alert","twistedfatecd",
							},
						},
					},
					{
						"expect",{"&npcid|#4#&","==","69134"}, -- Kazra'jin
						--"set",{HPtoGo = "&percHPToGo|69134|25&"},
					--	"set",{percHP = "&percHP|69134&"},
					--	"alert","ipercHPToGo",
						"set",{KazraPossessed = 1},
						--"scheduletimer",{"timerpowerpossed",1},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136442,
				execute = {
					{
						--"canceltimer",{"timerpowerpossed"},
						"removeraidicon","#5#",
					},
					{
						"expect",{"&npcid|#4#&","==","69078"}, -- Sul the Sandcrawler
						"set",{SulPossessed = 0},
					},
					{
						"expect",{"&npcid|#4#&","==","69131"}, -- Frost King Malakk
						"set",{bittingcold = "&timeleft|frostbitecd|0&"},
						"quash","frostbitecd",
						"alert","bittingcoldcd",
						"set",{FrostPossessed = 0},
					},
					{
						"expect",{"&npcid|#4#&","==","69132"}, -- High Prestess Mar'li
						"set",{PrestessPossessed = 0},
						"invoke", {
							{
								"expect",{"&difficulty&","<=","2"}, --10n&25n
								"set",{blessedloaSpirit = "&timeleft|shadowedLoaSpiritcd|0&"},
								"quash","shadowedLoaSpiritcd",
								"alert","blessedloaSpiritcd",
							},
							{
								"expect",{"&difficulty&",">=","3"}, --10h&25h
								"set",{twistedfatetime = "&timeleft|twistedfatecd|0&"},
								"quash","twistedfatecd",
								"alert","blessedloaSpiritcd",
							},
						},
					},
					{
						"expect",{"&npcid|#4#&","==","69134"}, -- Kazra'jin
						"set",{KazraPossessed = 0},
					},
				},
			},
			-- Recklesscharge
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					--{
						--"expect",{"#2#","==",SN[137107]},
						--"message","warnrecklesscharge",
					--},
					{
						"expect",{"#2#","==",SN[137107]},
						"invoke",{
						--[[	{
								"expect",{"<KazraPossessed>","==","0"},
								"alert","recklesschargecd",
								--"set",{recklesscharge = 6},
								--"alert","recklesschargecd",
								--"scheduletimer",{"updatereckless",4},
							},--]]
							{
								"expect",{"<KazraPossessed>","==","1"},
								"alert",{"recklesschargecd",time = 2},
								--"set",{recklesscharge = 25},
								--"alert","recklesschargecd",
								--"scheduletimer",{"updatereckless",4},
							},							
						},
					},
				},
			},
			-- frigidAssault
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136903,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						--"quash","frigidAssault",
						"alert","frigidAssault",
						"set",{warnfrigidtext = format("%s: %s %s!",SN[136903],L.alert["on"],L.alert["YOU"])},
						"alert",{"warnfrigidAssault", text = 2},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						--"quash","frigidAssault",
						"alert",{"frigidAssault",text = 3},
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 136903,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						--"set",{frigidtext = format("%s: %s x %s",L.alert["YOU"],SN[103687],"#11#")},
						--"quash","frigidAssault",
						"alert",{"frigidAssault",text = 2},
						--"alert","frigidAssault",
						"invoke",{
							{
								"expect",{"#11#",">=","8"},
								"set",{warnfrigidtext = format("%s: %s %s %s!",SN[136903],L.alert["already at"],L.alert["Stacks"],"#11#")},
								"alert",{"warnfrigidAssault", text = 2},
							},
						},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						--"quash","frigidAssault",
						"alert",{"frigidAssault",text = 4},
						--"set",{frigidtext = format("%s: %s x %s","#5#",SN[103687],"#11#")},
						--"alert","frigidAssault",
					},
				},     
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136903,
				execute = {
					{
						"quash","frigidAssault",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136904,
				execute = {
					{
						"alert","frigidAssaultcd",
					},
				},
			},
			-- BitingCold
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136992,
				execute = {
					{
						"alert",{"bittingcoldcd", time = 3},
						"message","warnbitingCold",
						"raidicon","BitingColdmark",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"announce","bitingColdsay",
						"batchalert",{"warnbiting","bitingColdDebuff"},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"bitingColdDebuff", text = 2},
						"alert","iBiting",
						--"set",{BitingColdTarget = "#5#"},
						"invoke", {
							{
								"expect",{"&inrange|#5#&","<","10"},
								"arrow","BittingColdarrow",
							},
						--	{
						--		"scheduletimer",{"timerBittingCold",1},
						--	},
						},
					},
				},
			},	
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136992,
				execute = {
					{
						"removeraidicon","#5#",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"iBiting", text = 2},
						--"set",{BitingColdTarget = "no"},
						--"canceltimer",{"timerBittingCold"},
					},
				},
			},
			-- frostbite
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {136990, 136922},
				execute = {
					{
						"alert",{"frostbitecd", time = 2},
						"message","warnfrostbite",
						"raidicon","Frostbiteicon",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						--"announce","frostbitesay",
						"batchalert",{"warnfrostb","ifrostb","frostbiteDebuff"},
						"closewindow",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"frostbiteDebuff", text = 2},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {136990, 136922},
				execute = {
					{
						"removeraidicon","#5#",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","ifrostbremoved",
						"openwindow",{"7"},
					},
				},
			},			
			-- QuickSand
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136860,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnQuickSand",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 136521,
				srcnpcid = 69078,
				execute = {
					{
						"alert","msgQuickSand",
						"alert",{"quicksandcd", time = 3},
					},
				},
			},
			-- Entrapped
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136857,
				dstisplayerunit = true,
				execute = {
					{
						"expect",{"&dispell|magic&","==","true"},
						"alert","iEntrapped",
					},
				},
			},
			-- Ensnared
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136878,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnEnsnared",
					},
				},
			},
			-- 	twistedfateTargets (heroic)
			--[[{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137972,
				execute = {
					{
						"insert",{"twistedfateunits","#5#"},
						"canceltimer","timertwistedfate",
						"scheduletimer",{"timertwistedfate",0.3},
						"raidicon","twistedfateTargets",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","itwistedfate",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 137972,
				execute = {
					{
						"removeraidicon","#5#",
					--	"expect",{"#4#","==","&playerguid&"},
					--	"alert","itwistedfate",
					},
				},
			},--]]
			-- Chilled to the Bone (heroic)
			{
				type = "event",
				event = "UNIT_AURA",
				execute = {
					{
						"expect",{"#1#","==","player"},
						"invoke",{
							{
								"expect",{"<chilledWarned>","==","no"},
								"expect",{"&playerdebuff|"..SN[137085].."&","==","true"},
								"set",{chilledWarned = "yes"},
								"alert","warnchilled",
								"scheduletimer",{"timerResetChilled",15},
							},
						--	{
						--		"expect",{"&playerdebuff|"..SN[137085].."&","==","false"},
						--		"set",{chilledWarned = "no"},
						--	},
						},
					},
				},
			},
			-- ShadowedSoul (Heroic)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137650,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","ShadowedSoulDebuff",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"ShadowedSoulDebuff", text = 3},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 137650,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert",{"ShadowedSoulDebuff", text = 2},
						"invoke",{
							{
								"expect",{"#11#",">","9"},
								"expect",{"&playerdebuff|"..SN[137641].."&","==","true"},
								"alert","iShadowedSoul",
							},
						},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"ShadowedSoulDebuff", text = 4},
					},
				},
			},
			--
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","69078"}, --Sul the Sandcrawler
						"quash","sandStormcd",
					},
					{
						"expect",{"&npcid|#4#&","==","69132"}, --High Prestess Mar'li
						"batchquash",{"twistedfatecd","blessedloaSpiritcd","shadowedLoaSpiritcd"},
					},
					{
						"expect",{"&npcid|#4#&","==","69131"}, --Frost King Malakk
						"batchquash",{"frostbitecd","bittingcoldcd","frigidAssaultcd"},
					},
					{
						"expect",{"&npcid|#4#&","==","69134"}, --Kazra'jin
						"quash","recklesschargecd",
					},			
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
