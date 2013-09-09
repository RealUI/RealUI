local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST
--TODO:
--local shellc = GetSpellInfo(136431)
do
	local data = {
		version = 13,
		key = "Tortos",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Tortos"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-TORTOS.BLP:35:35",
		triggers = {
			scan = {67977}, 
		},
		onactivate = {
			tracing = {	
				67977,
				powers={true},
			},
			tracerstart = true,
			combatstop = true,
			defeat = { 67977 },
			unittracing = {"boss1"},
		},
		enrage = {
			time10n = 780,
			time25n = 780,
			time10h = 600,
			time25h = 600,
			time25lfr = 780,
		},
		userdata = {
			shells = 0,
			concusion = 0,
			shellconcussion = 1,
			stomp = 0,
			stompactive = 0,
			CrystalShellUnits = {type = "container", wipein = 3},
			activemobs = {type="container"},
			turtle = "",
			breath = 0,
			expires = 0,
		},
		onstart = {
			{
				"alert","Breathcd",
				"alert",{"Rockfallcd", time = 2},
				"alert",{"CallTortoscd", time = 2},
				"alert",{"Stompcd", time = 2},
			},
			{
				"expect",{"&difficulty&",">=","3"}, --10h&25h
				"alert","iCrystalShellGet",
				"scheduletimer",{"timercrystallshell",7},
			},
		},
		raidicons = {
			turtles = {
				varname = L.npc_ThroneOfThunder["Whirl Turtle"],
				type = "MULTIENEMY",
				persist = 60,
				unit = "#1#", -- #4#
				reset = 8,
				icon = 1,
				total = 8,
			},
		},
		timers = {
			timercrystallshell = {
				{
					"expect",{"&unitisdead|player&","==","0"},
					"expect",{"&playerdebuff|"..SN[137633].."&","==","false"},
					"alert","iCrystalShellGet",
					"scheduletimer",{"timercrystallshell",3},
				},
			},
			timerRockfall = {
				{
					"set",{stompactive = "0"},
					"set",{stomp = "0"},
				},
			},
			timerCrystalShellmsg = {
				{
					"message","warnCrystalShellRemoved",
				},
			},
			timerturtlemark = {
				{
					"raidicon","turtles",
				},
			},
			timerconcusion = {
				"set",{expires = "0"},
			},			
		},
		messages = {
			--[[warnCrystalShell = {
				varname = format(L.alert["%s %s #5#"],SN[137552],L.alert["on"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[137552],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[137552],
				sound = "ALERT13",
			},--]]
			warnCrystalShellRemoved = {
				varname = format(L.alert["%s %s %s"],SN[137552],L.alert["removed from"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s &list|CrystalShellUnits&"],SN[137552],L.alert["removed from"]),
				color1 = "INDIGO",
				icon = ST[137552],
				sound = "ALERT13",
			},
			--[[warnSnappingBite = {
				varname = format(L.alert["%s %s #5#"],SN[135251],L.alert["removed from"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[135251],L.alert["removed from"]),
				color1 = "INDIGO",
				icon = ST[135251],
				sound = "ALERT13",
				exdps = true,
				exhealer = true,
			},--]]
			warnRockfall = {
				varname = format(L.alert["%s!"],SN[134476]),
				type = "message",
				text = format(L.alert["%s!"],SN[134476]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT13",
				icon = ST[134476],
				throttle = 10,
			},
			warnCallofTortos = {
				varname = format(L.alert["%s!"],SN[136294]),
				type = "message",
				text = format(L.alert["%s!"],SN[136294]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT13",
				icon = ST[136294],
			},
			warnGlowingFury = {
				varname = format(L.alert["%s!"],SN[136010]),
				type = "message",
				text = format(L.alert["%s!"],SN[136010]),
				time = 2,
				color1 = "RED",
				sound = "ALERT13",
				icon = ST[136010],
			},			
		},
		alerts = {
			-- Cooldowns
			Rockfallcd = {
				varname = format(L.alert["%s Cooldown"],SN[134476]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[134476]),
				time = 10,
				time2 = 15,
				time3 = 7.5,
				color1 = "NEWBLUE",
				icon = ST[134476],
			},
			CallTortoscd = {
				varname = format(L.alert["%s Cooldown"],SN[136294]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136294]),
				time = 60,
				time2 = 21,
				color1 = "NEWBLUE",
				icon = ST[136294],
			},
			Stompcd = {
				varname = format(L.alert["%s Cooldown"],SN[134920]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[134920]),
				time = 49,
				time2 = 29,
				flashtime = 10,
				audiocd = true,
				audiotime = 5,				
				color1 = "NEWBLUE",
				icon = ST[134920],
			},
			Breathcd = {
				varname = format(L.alert["%s Cooldown"],SN[133939]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[133939]),
				time = 46,
				time2 = "<breath>",
				color1 = "TAN",
				color2 = "RED",
				audiocd = true,
				audiotime = 5,
				flashtime = 15,
				icon = ST[133939],
			},
			Bitecd = {
				varname = format(L.alert["%s Cooldown"],SN[135251]),
				type = "centerpopup",
				text = format(L.alert["%s Cooldown"],SN[135251]),
				time = 8,
				color1 = "TAN",
				icon = ST[135251],
				exdps = true,
			},
			Batscd = {
				varname = format(L.alert["%s Cooldown"],SN[136686]),
				type = "centerpopup",
				text = format(L.alert["%s Cooldown"],SN[136686]),
				time = 46,
				color1 = "BROWN",
				icon = ST[136686],
				exdps = true,
			},
			-- warning	
			wQuakeStomp = {
				varname = format(L.alert["%s!"],SN[134920]),
				type = "simple",
				text = format(L.alert["%s!"],SN[134920]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT9",
				icon = ST[134920],
			},
			wStoneBreath = {
				varname = format(L.alert["%s!"],SN[133939]),
				type = "simple",
				text = format(L.alert["%s!"],SN[133939]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT1",
				icon = ST[133939],
			},
			wBats = {
				varname = L.chat_ThroneOfThunder["Incoming Bats!"],
				type = "simple",
				text = L.chat_ThroneOfThunder["Incoming Bats!"],
				time = 2,
				color1 = "BROWN",
				sound = "ALERT19",
				icon = ST[24733],
			},			
			-- Inform
			iRockfall = {
				varname = format(L.alert["%s %s %s - %s!"],SN[134539],L.alert["on"],L.alert["YOU"],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s %s %s - %s!"],SN[134539],L.alert["on"],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[134539],
				flashscreen = true,
				throttle = 1,
			},
			iStoneBreath = {
				varname = format(L.alert["%s - %s!"],SN[133939],L.chat_ThroneOfThunder["Kick Turtle"]),
				type = "inform",
				text = format(L.alert["%s - %s!"],SN[133939],L.chat_ThroneOfThunder["Kick Turtle"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT15",
				icon = ST[133939],
			},
			iCrystalShellRemoved = {
				varname = format(L.alert["%s %s!"],SN[137633],L.alert["REMOVED"]),
				type = "inform",
				text = format(L.alert["%s %s!"],SN[137633],L.alert["REMOVED"]),
				text2 = format(L.alert["%s %s!"],L.alert["Get"],SN[137633]),
				time = 2,
				color1 = "RED",
				sound = "ALERT14",
				icon = ST[137633],
				flashscreen = true,
			},
			iCrystalShellGet = {
				varname = format(L.alert["%s %s!"],L.alert["Get"],SN[137633]),
				type = "inform",
				text = format(L.alert["%s %s!"],L.alert["Get"],SN[137633]),
				time = 2,
				color1 = "RED",
				sound = "ALERT14",
				icon = ST[137633],
				extank = true,
				flashscreen = true,
			},
			-- CenterPopup
			QuakeStompCast = {
				varname = format("Boss %s %s!",L.alert["casting"],SN[134920]),
				type = "centerpopup",
				text = format("&bossname|boss1& %s %s!",L.alert["casting"],SN[134920]),
				time = 2.2,
				color1 = "RED",
				icon = ST[134920],
			},
			KickShellAvail = {
				varname = format(L.alert["%s %s"],L.chat_ThroneOfThunder["Kickable Turtles:"],"2"),
				type = "centerpopup",
				text = format(L.chat_ThroneOfThunder["%s |cff00FF96%s"],L.chat_ThroneOfThunder["Kickable Turtles:"],"<shells>"),
				time = 60,
				color1 = "NONE",
				sound = "ALERT13",
				icon = ST[134031],
				static = true,
			},
			ShellConcussionCast = {
				varname = format(L.alert["%s %s"],SN[134092],L.alert["Active"]),
				type = "centerpopup",
				text = format(L.alert["%s %s"],SN[134092],L.alert["Active"]),
				time = "<concusion>",
				color1 = "GREEN",
				icon = ST[134092],
				--throttle = 5,
			},
			-- Inform
			 
			-- Debuffs
			CrystalShelldebuffb = {
				varname = format(L.alert["%s Debuff"],SN[137633]),
				type = "debuff",
				text = format("%s: %s",L.alert["YOU"],format(L.alert["Missing %s"],SN[137633])),
				text2 = format("#5#: %s",format(L.alert["Missing %s"],SN[137633])),
				time = 60,
				color1 = "RED",
				icon = ST[137633],
				tag = "#5#",
				ex25 = true,
				static = true,
			},
			--[[CrystalShelldebuff = {
				varname = format(L.alert["%s Debuff"],SN[137633]),
				type = "debuff",
				text = format("%s: %s",L.alert["YOU"],SN[137633]),
				text2 = format("#5#: %s",SN[137633]),
				time = 60,
				color1 = "NEWBLUE",
				icon = ST[137633],
				tag = "#5#",
				ex25 = true,
				enabled = false,
			},--]]
		},
		events = {
			-- CrystalShell 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137633,
				execute = {
					{
						--"message","warnCrystalShell",
						"quash","CrystalShelldebuffb",
					},
				--[[	{
						"expect",{"#4#","==","&playerguid&"},
						"canceltimer","timercrystallshell",
						"alert","CrystalShelldebuff",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"expect",{"&unitisplayer|#5#&","==","true"},
						"alert",{"CrystalShelldebuff", text = 2},
					},
				},--]]
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 137633,
				execute = {
					{
						--"message","warnCrystalShellRemoved",
						"expect",{"&unitisplayer|#5#&","==","true"},
						--"quash","CrystalShelldebuff",
						"alert",{"CrystalShelldebuffb", text = 2},
						"insert",{"CrystalShellUnits","#5#"},
						"canceltimer","timerCrystalShellmsg",
						"scheduletimer",{"timerCrystalShellmsg",0.3},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","iCrystalShellRemoved",
						"alert","CrystalShelldebuffb",
						"scheduletimer",{"timercrystallshell",3},
					},
				},
			},
			-- Shell Block 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 133971,
				execute = {
					{
						"set",{shells = "INCR|1"},
						"alert","KickShellAvail",
					},
				},
			},
			--[[-- Shell Concussion
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 134092,
				execute = {
					{
						"set",{shells = "DECR|1"},
						"batchalert",{"KickShellAvail","ShellConcussionCast"},
						"expect",{"<shells>","==","0"},
						"quash","KickShellAvail",
					},
				},
			},--]]
			{
				type = "event",
				event = "UNIT_AURA", --Shell Concussion
				execute = {
                    {
						"expect",{"#1#","==","boss1"},
						"expect",{"<expires>","~=","1"},
						"invoke", {
							{
								"expect",{"&targetdebuff|#1#|"..SN[136431].."&","==","true"},
								"set",{expires = "1"},
								"set",{shellconcussion = "&targetdebuffdur|#1#|"..SN[136431].."&"},
								"set",{concusion = "<shellconcussion>"},
								"alert","ShellConcussionCast",
								"scheduletimer",{"timerconcusion",6},
							},
						},
                    },
					--[[{
						"expect",{"#1#","==","boss1"},
						"expect",{"<shellconcussion>",">","<concusion>"},
						"invoke",{
							{
								"set",{shellconcussion = "&targetdebuffdur|#1#|"..shellc.."&"}, --SN[136431]
								"set",{concusion = "<shellconcussion>"},
								"alert","ShellConcussionCast",
							},
						},
					},--]]
				},
			},
			-- Glowing Fury
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 136010,
				execute = {
					{
						"expect",{"&difficulty&","==","0"}, --lfr
						"set",{breath = "&minustimeleft|Breathcd|5&"},
					},
					{
						"expect",{"&difficulty&",">","0"},
						"set",{breath = "&minustimeleft|Breathcd|10&"},
					},
					{
						"message","warnGlowingFury",
						"alert",{"Breathcd", time = 2},
					},
				},
			},	
			-- Kick Shell
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 134031,
				execute = {
					{
						"set",{shells = "DECR|1"},
						"alert","KickShellAvail",
						"expect",{"<shells>","==","0"},
						"quash","KickShellAvail",
					},
				},
			},
			-- Rockfall
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 134476,
				execute = {
					{
						"alert","Rockfallcd",
					},
					{
						"expect",{"<stompactive> <stomp>","==","0 0"},
						"set",{stomp = "1"},
						"message","warnRockfall",
						"scheduletimer",{"timerRockfall",10},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = 134539,
				dstisplayerunit = true,
				execute = {
					{
						"alert","iRockfall"
					},
				},
			},	
		    -- StoneBreath
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 133939,
				execute = {
					{
						"batchalert",{"wStoneBreath","Breathcd"},
					},
					{
						"expect",{"<shells>",">","0"},
						"alert","iStoneBreath",
					},
				},
			},
		    -- CallofTortos
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136294,
				execute = {
					{
						"message","warnCallofTortos",
						"alert","CallTortoscd",
					},
				},
			},
		    -- QuakeStomp
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 134920,
				execute = {
					{
						"set",{stompactive = "1"},
						"batchalert",{"wQuakeStomp","Stompcd","QuakeStompCast"},
						"alert",{"Rockfallcd", time = 3},
						--"scheduletimer",{"timerrocketfall",11},
					},
				},
			},
			-- Bats summon
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					{
						"expect",{"#2#","==",SN[136685]},
						"expect",{"#1#","==","boss1"},
						"batchalert",{"wBats","Batscd"},
					},
				},
			},	
		    -- SnappingBite
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 135251,
				execute = {
					{
						--"message","warnSnappingBite",
						"alert","Bitecd",
					},
				},
			},
			-- Turtle mark
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 133974,
				execute = {
					{
						--"debug",{"turtle mark #1#"},
						"expect",{"&tabread|activemobs|#1#&","~=","true"},
						--"debug",{"turtle mark2 #1#"},
						"tabinsert",{"activemobs","#1#","true"},
						--"debug",{"turtle mark3"},
						--"set",{turtle = "&targetid|#1#&"},
						"scheduletimer",{"timerturtlemark",0.3},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
