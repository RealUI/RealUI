local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST
--TODO:
local CrimsonWake = GetSpellInfo(138485)
do
	local data = {
		version = 12,
		key = "Dark Animus",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Dark Animus"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-DARK ANIMUS.BLP:35:35",
		triggers = {
			scan = {69427},
			emote = L.chat_ThroneOfThunder["(The orb explodes!)"],
		},
		onactivate = {
			tracing = {	
				69427,
				powers={true,},
				--markers1 = {60, 25},
			},
			tracerstart = true,
			combatstop = true,
			defeat = {	69427 },
			unittracing = {	"boss1",},
		},
		windows = {
			proxwindow = true,
		},
		enrage = {
			time10n = 600,
			time25n = 600,
			time10h = 600,
			time25h = 600,
			time25lfr = 600,
		},
		userdata = {
			furthest = "",
			siphonanima = 0,
			power = 0,
		},
		onstart = {
			{
				"scheduletimer",{"timerstartfight",1},
			},
		},		
		timers = {	
			timerSiphonAnima = {
				{
					"set",{power = "&getup|boss1&"},
					"expect",{"<power>",">=","70"},
					"expect",{"<power>","<=","75"},
					"alert",{"InterruptingJoltcd", time = 3},
				},
			},
			timerstartfight = {
				{
					"expect",{"&unitexist|boss1&","==","1"},
					"expect",{"&bossid|boss1&","==","69427"},
					"invoke",{
						{
							"expect",{"&difficulty&",">=","3"}, --10h&25h
							"set",{siphonanima = "INCR|1"},
							"alert",{"SiphonAnimacd", text = 2},
						},
						{
							"expect",{"&difficulty&","<=","2"},
							"alert",{"SiphonAnimacd", time = 4},
						},
					},
				},
				{
					"expect",{"&unitexist|boss1&","==","0"},
					"scheduletimer",{"timerstartfight",0.4},
				},
			},
			timerMatterSwap = {
				{
					--"message","warnFurthestPlayer",
					"set",{furthest = "&HighestDistance|#5#&"},
					"alert","MatterSwapFurthestDebuff",
					"raidicon","MatterSwappedFurthesticon",
					"scheduletimer",{"timerMatterSwap",0.5},
				},
			--	{
					--"expect",{"&dispell|magic&","==","true"},
			--		"scheduletimer",{"timerMatterSwap",0.7},
			--	},
			},
		},
		raidicons = {
			MatterSwappedicon = {
				varname = SN[138609],
				type = "FRIENDLY",
				persist = 12,
				unit = "#5#",
				icon = 5,
			},
			MatterSwappedFurthesticon = {
				varname = L.alert["Furthest"].." "..SN[138609],
				type = "FRIENDLY",
				persist = 12,
				unit = "<furthest>",
				icon = 6,
			},
		},
		announces = { 
			CrimsonWakesay = {
				varname = format(L.alert["%s %s %s!"],SN[138485],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s!"],SN[138485],L.alert["on"],L.alert["Me"]),
				--enabled = false,
			},
			animaringsay = {
				varname = format(L.alert["%s %s %s!"],SN[136954],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s!"],SN[136954],L.alert["on"],L.alert["Me"]),
			},
		},
		messages = {
			MatterSwapped = {
				varname = format(L.alert["%s %s %s"],SN[138609],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[138609],L.alert["on"]),
				color1 = "PURPLE",
				icon = ST[138609],
				sound = "ALERT13",
			},
			warnswaped = {
				varname = format(L.alert["%s: %s %s %s"],SN[138618],L.alert["player"],L.alert["swapped with"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s: #2# %s #5#"],SN[138618],L.alert["swapped with"]),
				color1 = "PURPLE",
				icon = ST[138618],
				sound = "ALERT13",
			},
			--[[warnFurthestPlayer = {
				varname = format(L.alert["%s %s %s"],SN[138618],L.alert["Furthest"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s %s: &HighestDistance|#5#&"],SN[138618],L.alert["Furthest"],L.alert["player"]),
				color1 = "ORANGE",
				icon = ST[138618],
				sound = "ALERT13",
			},--]]
			warnCrimsonWake = {
				varname = format(L.alert["%s"],SN[138480]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[138480],L.alert["on"]),
				color1 = "RED",
				icon = ST[138480],
				sound = "ALERT13",
			},
			warnanimaring = {
				varname = format(L.alert["%s %s %s"],SN[136954],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s &upvalue&"],SN[136954],L.alert["on"]),
				color1 = "GOLD",
				icon = ST[136954],
				sound = "ALERT13",
			},
			warnExplosiveSlam = {
				varname = format(L.alert["%s %s %s (2)"],SN[138569],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[138569],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[138569],L.alert["on"]),
				color1 = "BROWN",
				icon = ST[138569],
				sound = "ALERT13",
				exdps = true,
			},
			warnEmpowerGolem = {
				varname = format(L.alert["%s %s %s"],SN[138780],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[138780],L.alert["on"]),
				color1 = "NEWBLUE",
				icon = ST[138780],
				sound = "ALERT13",
			},
			warnAnimaFont = {
				varname = format(L.alert["%s %s %s"],SN[138691],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[138691],L.alert["on"]),
				color1 = "RED",
				icon = ST[138691],
				sound = "ALERT13",
			},
		},
		alerts = {
			MatterSwapDebuff = {
				varname = format(L.alert["%s Debuff"],SN[138609]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[138609]),
				text2 = format(L.alert["#5#: %s"],SN[138609]),
				time = 12,
				color1 = "NEWBLUE",
				icon = ST[137399],
				tag = "#5#",
			},
			MatterSwapself = {
				varname = format(L.alert["%s %s %s"],SN[138609],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s"],SN[138609],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				icon = ST[138609],
				sound = "ALERT10",
			},
			MatterSwapDispell = {
				varname = format(L.alert["%s %s %s!"],SN[138609],L.alert["Dispell"],L.alert["player"]),
				type = "inform",
				text = format(L.alert["%s #5#"],L.alert["Dispell"]),
				time = 2,
				color1 = "GOLD",
				--sound = "ALERT10",
				icon = ST[138609],
			},
			CrimsonWakeself = {
				varname = format(L.alert["%s %s %s %s!"],SN[138485],L.alert["on"],L.alert["YOU"],L.alert["MOVE AWAY"]),
				type = "simple",
				text = format(L.alert["%s %s %s %s!"],SN[138485],L.alert["on"],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT12",
				icon = ST[138485],
				throttle = 2,
			},
			CrimsonWakeDebuff = {
				varname = format(L.alert["%s Debuff"],SN[138485]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[138485]),
				time = 30,
				color1 = "ORANGE",
				icon = ST[138485],
				tag = "#5#",
			},			
			AnimaRing = {
				varname = format(L.alert["%s!"],SN[136954]),
				type = "simple",
				text = format(L.alert["%s!"],SN[136954]),
				time = 2,
				color1 = "GOLD",
				icon = ST[136954],
				sound = "ALERT13",
			},
			AnimaRingself = {
				varname = format(L.alert["%s %s %s!"],SN[136954],L.alert["on"],L.alert["YOU"]),
				type = "inform",
				text = format(L.alert["%s %s %s!"],SN[136954],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "GOLD",
				icon = ST[136954],
				sound = "ALERT14",
			},
			AnimaRingcd = {
				varname = format(L.alert["%s Cooldown"],SN[136954]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136954]),
				time = 22,
				color1 = "NEWBLUE",
				icon = ST[136954],
			},
			SiphonAnimacd = {
				varname = format(L.alert["%s Cooldown"],SN[138644]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[138644]),
				text2 = format(L.alert["(<siphonanima>) %s"],format(L.alert["%s Cooldown"],SN[138644])),
				time = 120,
				time2 = 6,
				time3 = 20,
				time4 = 30,
				color1 = "NEWBLUE",
				icon = ST[138644],
			},
			EmpowerGolemcd = {
				varname = format(L.alert["%s Cooldown"],SN[138780]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[138780]),
				time = 16,
				color1 = "NEWBLUE",
				icon = ST[138780],
			},
			InterruptingJoltcd = {
				varname = format(L.alert["%s Cooldown"],SN[138763]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[138763]),
				time = 23,
				time2 = 21.5,
				time3 = 18,
				audiocd = true,
				audiotime = 5,
				flashtime = 10,
				color1 = "RED",
				icon = ST[138763],
			},
			iInterruptingJolt = {
				varname = format(L.alert["%s, %s!"],SN[138763],L.alert["stop casting"]),
				type = "inform",
				text = format(L.alert["%s, %s!"],SN[138763],L.alert["stop casting"]),
				time = 2,
				color1 = "RED",
				icon = ST[138763],
				sound = "ALERT11",
				flashscreen = true,
			},
			InterruptingJoltCast = {
				varname = format(L.alert["%s Casting"],SN[138763]),
				type = "centerpopup",
				text = format(L.alert["%s Casting"],SN[138763]),
				time10n = 2.2,
				time25n = 2.2,
				time10h = 1.4,
				time25h = 1.4,
				time25lfr = 3.8,
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[138763],
			},
			MatterSwapFurthestDebuff = {
				varname = format(L.alert["%s %s %s"],L.alert["player"],L.alert["Furthest"],SN[138618]),
				type = "centerpopup",
				text = format(L.alert["&colorplayer|<furthest>& %s %s"],L.alert["Furthest"],SN[138618]),
				time = 20,
				color1 = "VIOLET",
				icon = ST[138691],
				tag = "#5#",
				static = true,
			},
			ExplosiveSlamDebuff = {
				varname = format(L.alert["%s Debuff"],SN[138569]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[138569]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[138569]),
				text3 = format(L.alert["#5#: %s (1)"],SN[138569]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[138569]),
				time = 20,
				color1 = "BROWN",
				icon = ST[138569],
				tag = "#5#",
				exdps = true,
			},
			iFullPower = {
				varname = format(L.alert["%s!"],SN[138729]),
				type = "inform",
				text = format(L.alert["%s!"],SN[138729]),
				time = 2,
				color1 = "RED",
				icon = ST[138729],
				sound = "ALERT16",
				flashscreen = true,
			},
			iAnimaFont = {
				varname = format(L.alert["%s!"],SN[138691]),
				type = "inform",
				text = format(L.alert["%s!"],SN[138691]),
				time = 2,
				color1 = "RED",
				icon = ST[138691],
				sound = "ALERT11",
			},
			AnimaFontDebuff = {
				varname = format(L.alert["%s Debuff"],SN[138691]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[138691]),
				text2 = format(L.alert["#5#: %s"],SN[138691]),
				time = 20,
				color1 = "RED",
				icon = ST[138691],
				tag = "#5#",
			},
			iExplosiveSlam = {
				varname =  format("%s - %s!",SN[138569],L.alert["Taunt"]),
				type = "inform",
				text = format("%s - %s!",SN[138569],L.alert["Taunt"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT10",
				icon = ST[138569],
				exdps = true,
				exhealer = true,
			},
			iCrimsonWake = {
				varname = format(L.alert["%s %s %s %s!"],SN[138485],L.alert["on"],L.alert["YOU"],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s %s %s %s!"],SN[138485],L.alert["on"],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[138485],
				throttle = 2,
			},
		},
		events = {
			-- MatterSwap
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 138609,
				execute = {
					{
						"message","MatterSwapped",
						"raidicon","MatterSwappedicon",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","MatterSwapDebuff",
						"alert","MatterSwapself",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"MatterSwapDebuff", text = 2},
					},
					{
						"expect",{"&dispell|magic&","==","true"},
						"alert","MatterSwapDispell",					
					},
					{
						"canceltimer","timerMatterSwap",
						"scheduletimer",{"timerMatterSwap",0.5},	
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 138609,
				execute = {
					{
						"quash","MatterSwapDebuff",
						"canceltimer","timerMatterSwap",
						"quash","MatterSwapFurthestDebuff",
						"removeraidicon","#5#",
						"removeraidicon","<furthest>",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 138618,
				execute = {
					{
						"expect",{"#2#","~=","#5#"},
						"message","warnswaped",
					},
				},
			},
			-- Crimson Wake
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 138485,
				dstisplayerunit = true,
				execute = {
					{
						--"alert","CrimsonWakeself",
						"alert","iCrimsonWake",
					},
				},
			},
			{
				type = "event",
				event = "RAID_BOSS_WHISPER", 
				execute = {
					{
						--"expect",{"#1#","find","spell:138485"},
						"expect",{"#2#","==",CrimsonWake},
						"announce","CrimsonWakesay",
						"batchalert",{"CrimsonWakeself","CrimsonWakeDebuff"},
						--"sync",{"warnCrimsonWake","2"},
					},
				},
			},
		    -- Anima Ring
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136954,
				execute = {
					{
						"batchalert",{"AnimaRingcd","AnimaRing"},
					},
					{
						"target",{
							source = "#1#",
							wait = 0.02,
							schedule = 12,
							announce = "animaringsay",
							message = "warnanimaring",
							alerts = {
								self = "AnimaRingself",
								--other = "",
								--unknown = {"",text = 2},
							},
						},
					},
				},
			},
		    -- Interrupting Jolt
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellid = { 138763, 139867, 139869},
				execute = {
					{
						"expect",{"&iscaster&","==","true"},
						"batchalert",{"iInterruptingJolt","InterruptingJoltCast"},
					},
					{
						"expect",{"&difficulty&","<=","2"}, --normal
						"alert","InterruptingJoltcd",
					},
					{
						"expect",{"&difficulty&",">=","3"}, --10h&25h
						"alert",{"InterruptingJoltcd", time = 2},
					},
				},
			},
			-- ExplosiveSlam
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 138569,
				execute = {
					{
						"expect",{"&istargettank|#5#&","==","true"},
						"invoke",{
							{
								"message","warnExplosiveSlam",
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"quash","ExplosiveSlamDebuff",
								"alert","ExplosiveSlamDebuff",
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"quash","ExplosiveSlamDebuff",
								"alert",{"ExplosiveSlamDebuff", text = 3},
							},
						}
					},				
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 138569,
				execute = {
					{
						"expect",{"&istargettank|#5#&","==","true"},
						"invoke",{
							{
								"message",{"warnExplosiveSlam", text = 2},
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"quash","ExplosiveSlamDebuff",
								"alert",{"ExplosiveSlamDebuff", text = 2},
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"quash","ExplosiveSlamDebuff",
								"alert",{"ExplosiveSlamDebuff", text = 4},
							},
							{
								"expect",{"#11#",">=","4"},
								"expect",{"&playerdebuff|"..SN[138569].."&","==","false"},
								"alert","iExplosiveSlam",
							},	
						}
					},	
				},     
			},
			-- EmpowerGolem
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 138780,
				execute = {
					{
						"alert","EmpowerGolemcd",
						"message","warnEmpowerGolem",
					},
				},
			},
		    -- FullPower
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 138729,
				execute = {
					{
						"alert","iFullPower",
					},
				},
			},
			-- Anima Font
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 138691,
				execute = {
					{
						"message","warnAnimaFont",
						"openwindow",{"6"},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"batchalert",{"iAnimaFont","AnimaFontDebuff"},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"AnimaFontDebuff", text = 2},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 138691,
				execute = {
					{
						"closewindow",
					},
				},
			},
			-- SiphonAnima
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 138644,
				execute = {
					{
						"scheduletimer",{"timerSiphonAnima",0.1},
					},
					{
						"expect",{"&difficulty&",">=","3"}, --10h&25h
						"set",{siphonanima = "INCR|1"},
						"alert",{"SiphonAnimacd", time = 3, text = 2},
					},
					{
						"expect",{"&difficulty&","<=","2"},
						"alert",{"SiphonAnimacd", time = 2},
					},
				},
			},
			
		},
	}

	DXE:RegisterEncounter(data)
end
