local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST
--TODO
do
	local data = {
		version = 9,
		key = "Ji-Kun",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Ji-Kun"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-JI KUN.BLP:35:35",
		triggers = {
			scan = { 69712}, 
		},
		onactivate = {
			tracing = {	69712},
			tracerstart = true,
			combatstop = true,
			defeat = {	69712	},
			unittracing = {	"boss1" },
		},
		windows = {
			proxwindow = true,
			proxrange = 8,
		},
		enrage = {
			time10n = 600,
			time25n = 600,
			time10h = 600,
			time25h = 600,
		},
		timers = {	
			--timerFlock = {
			--	{
			--		"set",{Nesttemp = "0"},
			--	},
			--},
			timerPrimal = {
				{
					"message","msgPrimalNutriment",
				},
			},
			timerResetPrimal = {
				{
					"tabupdate",{"activeprimal","#1#","false"},
				},
			},
			timerBigAdd = {
				{
					"alert",{"wBigAdd", text = 2},
				},
			},
		},
		userdata = {
			Nestcount = 0,
			Nesttemp = 0,
			DaedalianWings = 0,
			DaedalianWingsText = "",
			dwings = 1,
			quills = 0,
			PrimalUnits = {type = "container", wipein = 3},
			activeprimal = {type="container"},
			bigaddtext = "",
		},
		onstart = {
			{
				"alert",{"Downdraftcd", time = 3},
				"expect",{"&ismelee&","==","false"},
				"openwindow",{"8"},
			},
			{
				"expect",{"&difficulty&","==","2"},
				"alert",{"Quillscd", time = 2},
			},
			{
				"expect",{"&difficulty&","==","4"},
				"alert",{"Quillscd", time = 2},
			},
			{
				"expect",{"&difficulty& &difficulty&","~=","2 4"},
				"alert",{"Quillscd", time = 3},
			},
		},
		messages = {
			warnWarnTalonRake = {
				varname = format(L.alert["%s"],SN[134366]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[134366],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[134366],L.alert["on"]),
				color1 = "ORANGE",
				icon = ST[134366],
				sound = "ALERT13",
				exdps = true,
				--exhealer = true,
			},
			warnInfectedTalons = {
				varname = format(L.alert["%s"],SN[140092]),
				type = "message",
				text = format(L.alert["%s %s #5# (#11#)"],SN[140092],L.alert["on"]),
				color1 = "ORANGE",
				icon = ST[140092],
				sound = "ALERT13",
				exdps = true,
			},
			msgCaws = {
				varname = format(L.alert["%s!"],SN[138923]),
				type = "message",
				text = format(L.alert["%s!"],SN[138923]),
				text2 = format(L.alert["%s %s!"],L.alert["Incoming"],SN[138923]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT13",
				icon = ST[138923],
			},
			msgQuills = {
				varname = format(L.alert["%s! (2)"],SN[134380]),
				type = "message",
				text = format(L.alert["%s! (<quills>)"],SN[134380]),
				time = 3,
				color1 = "INDIGO",
				sound = "ALERT13",
				icon = ST[134380],
			},
			msgDowndraft = {
				varname = format(L.alert["%s!"],SN[134370]),
				type = "message",
				text = format(L.alert["%s!"],SN[134370]),
				time = 3,
				color1 = "BROWN",
				sound = "ALERT13",
				icon = ST[134370],
			},
			msgPrimalNutriment = {
				varname = format(L.alert["%s"],SN[140741]),
				type = "message",
				text = format(L.alert["%s %s &list|PrimalUnits&"],SN[140741],L.alert["on"]),
				color1 = "ORANGE",
				icon = ST[140741],
				sound = "ALERT13",
				extank = true,
			},
		},
		alerts = {
			-- Cooldowns
			Downdraftcd = {
				varname = format(L.alert["%s Cooldown"],SN[134370]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[134370]),
				time = 97,
				time2 = 93,
				time3 = 91,
				flashtime = 5,	
				color1 = "NEWBLUE",
				icon = ST[134370],
			},
			Quillscd = {
				varname = format(L.alert["%s Cooldown"],SN[134380]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[134380]),
				time = 63,
				time2 = 43, -- start
				time3 = 60, -- lfr
				time4 = 81,
				time5 = 91,
				--time6 = 44, -- finished
				color1 = "NEWBLUE",
				audiocd = true,	
				flashtime = 10,
				icon = ST[134380],
			},
			--[[Nestcd = {
				varname = format(L.alert["%s Cooldown"],SN["ej7348"]),
				type = "dropdown",
				text = format(L.alert["%s: %s"],L.alert["Next Nest"],L.alert["Up & Lower"]),
				text2 = format(L.alert["%s: %s"],L.alert["Next Nest"],L.alert["Lower"]),
				text3 = format(L.alert["%s: %s"],L.alert["Next Nest"],L.alert["Up"]),
				time = 30,
				time2 = 40,
				flashtime = 15,
				color1 = "NEWBLUE",
				icon = ST[15746],
				--icon = ST["misc_arrowlup"],
			},--]]
			TalonRakecd = {
				varname = format(L.alert["%s Cooldown"],SN[134366]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[134366]),
				time = 20,
				color1 = "NEWBLUE",
				icon = ST[134366],
				exdps = true,
			},
			FeedYoungcd = {
				varname = format(L.alert["%s Cooldown"],SN[137528]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137528]),
				time25lfr = 40,
				time10n = 40,
				time25n = 30,
				time10h = 40,
				time25h = 30,
				--time = 30,
				--time2 = 40,
				color1 = "NEWBLUE",
				icon = ST[137528],
			},
			-- Warnings
			wFlock = {
				varname = format(L.alert["%s!"],SN["ej7348"]),
				type = "simple",
				text = format(L.alert["%s!"],SN["ej7348"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT11",
				icon = ST[15746],
			},			
			wLayEgg = {
				varname = format(L.alert["%s!"],SN[134367]),
				type = "simple",
				text = format(L.alert["%s!"],SN[134367]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT14",
				icon = ST[134367],
			},
			wDowndraft = {
				varname = format(L.alert["%s %s!"],L.alert["Incoming"],SN[134370]),
				type = "simple",
				text = format(L.alert["%s %s!"],L.alert["Incoming"],SN[134370]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT11",
				icon = ST[134370],
			},
			wFeedYoung = {
				varname = format(L.alert["%s!"],SN[137528]),
				type = "simple",
				text = format(L.alert["%s!"],SN[137528]),
				time = 2,
				color1 = "GREEN",
				sound = "ALERT1",
				icon = ST[137528],
			},
			wFlightAOver = {
				varname = format(L.alert["%s %s!"],SN[133755],L.alert["Ending"]),
				type = "simple",
				text = format(L.alert["%s %s!"],SN[133755],L.alert["Ending"]),
				time = 3,
				flashscreen = true,
				color1 = "RED",
				sound = "ALERT4",
				icon = ST[133755],
			},
			wBigAdd = {
				varname = format(L.alert["%s %s %s %s (<Nestcount>)"],L.chat_ThroneOfThunder["Nest Guardian"],L.alert["on"],L.chat_ThroneOfThunder["Lower"],L.chat_ThroneOfThunder["Nest"]),
				type = "simple",
				text = format(L.alert["%s %s %s %s %s (<Nestcount>) %s"],"|TInterface\\Icons\\misc_arrowdown:20:20:-5|t",L.chat_ThroneOfThunder["Nest Guardian"],L.alert["on"],L.chat_ThroneOfThunder["Lower"],L.chat_ThroneOfThunder["Nest"],"|TInterface\\Icons\\misc_arrowdown:20:20:-5|t"),
				text2 = format(L.alert["%s %s %s %s %s (<Nestcount>) %s"],"|TInterface\\Icons\\misc_arrowlup:20:20:-5|t",L.chat_ThroneOfThunder["Nest Guardian"],L.alert["on"],L.chat_ThroneOfThunder["Upper"],L.chat_ThroneOfThunder["Nest"],"|TInterface\\Icons\\misc_arrowlup:20:20:-5|t"),
				time = 2,
				color1 = "RED",
				sound = "ALERT14",
				--icon = ST[140741],
			},	
			-- Inform
			iQuills = {
				varname = format(L.alert["%s %s!"],L.alert["Incoming"],SN[134380]),
				type = "inform",
				text = format(L.alert["%s %s!"],L.alert["Incoming"],SN[134380]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = ST[134380],
				flashscreen = true,
				exdps = true,
				extank = true,
			},
			iDaedalianWings = {
				varname = format(L.alert["%s %s"],SN[134339],L.alert["Stacks"]),
				type = "inform",
				text = format(L.alert["%s (2)"],SN[134339]),
				text2 = format(L.alert["%s (<DaedalianWings>)"],SN[134339]),
				time = 2,
				color1 = "GREEN",
				icon = ST[134339],
			},
			iNest = {
				varname = L.chat_ThroneOfThunder["Upper & Lower"],
				type = "inform",
				text = format(L.alert["%s %s  %s (<Nestcount>)"],"|TInterface\\Icons\\misc_arrowlup:20:20:-5|t",L.chat_ThroneOfThunder["Upper & Lower"],"|TInterface\\Icons\\misc_arrowdown:20:20:-5|t"),
				text2 = format(L.alert["%s %s (<Nestcount>)"],"|TInterface\\Icons\\misc_arrowdown:20:20:-5|t",L.chat_ThroneOfThunder["Lower"]),	
				text3 = format(L.alert["%s %s (<Nestcount>)"],"|TInterface\\Icons\\misc_arrowlup:20:20:-5|t",L.chat_ThroneOfThunder["Upper"]),				
				time = 4,
				color1 = "INDIGO",
				sound = "ALERT1",
			},
			iTalonRake = {
				varname = format(L.alert["%s: (1)"],SN[134366]),
				type = "inform",
				text = format(L.alert["%s: (1)"],SN[134366]),
				text2 = format(L.alert["%s: (#11#)"],SN[134366]),
				time = 4,
				color1 = "INDIGO",
				sound = "ALERT13",
				icon = ST[134366],
				exdps = true,
				exhealer = true,
			},
			iPrimalNutriment = {
				varname = format(L.alert["%s %s %s"],SN[140741],L.alert["on"],L.alert["YOU"]),
				type = "inform",
				text = format(L.alert["%s %s %s"],SN[140741],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "GREEN",
				sound = "ALERT9",
				icon = ST[140741],
			},			
			-- Debuff
			TalonRakeDebuff = {
				varname = format(L.alert["%s Debuff"],SN[134366]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[134366]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[134366]),
				text3 = format(L.alert["#5#: %s (1)"],SN[134366]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[134366]),
				time = 60,
				color1 = "NEWBLUE",
				icon = ST[134366],
				tag = "#5#",
				exdps = true,
			},
			InfectedTalonsDebuff = {
				varname = format(L.alert["%s Debuff"],SN[140092]),
				type = "debuff",
				text = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[140092]),
				text2 = format(L.alert["#5#: %s (#11#)"],SN[140092]),
				time = 10,
				color1 = "NEWBLUE",
				icon = ST[140092],
				tag = "#5#",
				exdps = true,
			},			
			PrimalNutrimentBuff = {
				varname = format(L.alert["%s Buff"],SN[140741]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[140741]),
				text2 = format(L.alert["#5#: %s"],SN[140741]),
				time = 30,
				color1 = "GREEN",
				icon = ST[140741],
				tag = "#5#",
				ex25 = true,
			},
			-- Casts
			wCawscast = {
				varname = format(L.alert["%s %s"],L.alert["Incoming"],SN[138923]),
				type = "centerpopup",
				text = format(L.alert["%s %s"],L.alert["Incoming"],SN[138923]),
				time = 2.5,
				color1 = "VIOLET",
				--sound = "ALERT11",
				icon = ST[138923],
			},			
			wDowndraftcast = {
				varname = format(L.alert["%s Active"],SN[134370]),
				type = "centerpopup",
				text = format(L.alert["%s Active"],SN[134370]),
				time = 8,
				color1 = "RED",
				--sound = "ALERT11",
				icon = ST[134370],
			},
			wQuillstcast = {
				varname = format(L.alert["%s Active"],SN[134380]),
				type = "centerpopup",
				text = format(L.alert["%s Active"],SN[134380]),
				time = 10,
				color1 = "RED",
				--sound = "ALERT11",
				icon = ST[134380],
			},
			PrimalNutriment = {
				varname = format(L.alert["%s Active"],SN[140741]),
				type = "centerpopup",
				text = format(L.alert["%s Active"],SN[140741]),
				time = 30,
				color1 = "GREEN",
				--sound = "ALERT11",
				icon = ST[140741],
			},
			Flight = {
				varname = format(L.alert["%s Active"],SN[133755]),
				type = "centerpopup",
				text = format(L.alert["%s Active"],SN[133755]),
				time = 10,
				color1 = "BROWN",
				--sound = "ALERT11",
				icon = ST[133755],
			},
		},
		events = {
			-- TalonRake
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 134366,
				execute = {
					{
						"message","warnWarnTalonRake",
						"alert","TalonRakecd",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","TalonRakeDebuff",
						"alert","TalonRakeDebuff",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","TalonRakeDebuff",
						"alert",{"TalonRakeDebuff", text = 3},
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 134366,
				execute = {
					{
						"message",{"warnWarnTalonRake", text = 2},
						"alert","TalonRakecd",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","TalonRakeDebuff",
						"alert",{"TalonRakeDebuff", text = 2},
						"invoke", {
							{						
								"expect",{"#11#",">=","3"},
								"alert","iTalonRake",
							},
						},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","TalonRakeDebuff",
						"alert",{"TalonRakeDebuff", text = 4},
						"invoke", {
							{
								"expect",{"#11#",">=","2"},
								"expect",{"&playerdebuff|"..SN[134366].."&","==","false"},
								"alert",{"iTalonRake", text = 2},
							},
						},
					},
				},     
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 134366,
				execute = {
					{
						"quash","TalonRakeDebuff",
					},
				},
			},
			-- InfectedTalons
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 140092,
				execute = {
					{
						"expect",{"#11#",">","2"},
						"message","warnInfectedTalons",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","InfectedTalonsDebuff",
						"alert","InfectedTalonsDebuff",
						--"expect",{"#11#",">=","3"},
						--"alert","iTalonRake",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","InfectedTalonsDebuff",
						"alert",{"InfectedTalonsDebuff", text = 2},
					},
				},     
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 140092,
				execute = {
					{
						"quash","InfectedTalonsDebuff",
					},
				},
			},
			-- Caws
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 138923,
				execute = {
					{
						"message",{"msgCaws", text = 2},
						"alert","wCawscast",
					},
				},
			},			
			-- Emotes
			{
				type = "event",
				event = "EMOTE", 
				execute = {
					-- caws
					{
						"expect",{"#1#","find","spell:138923"}, 
						"message","msgCaws",
					},
				},
			},
			-- Flock Emotes
			{
				type = "event",
				event = "MONSTER_EMOTE", 
				execute = {
					{
						"expect",{"#1#","find",L.chat_ThroneOfThunder["(lower nests begin to hatch)"]},
						"set",{Nestcount = "INCR|1"},
						"invoke", {
							{
								"expect",{"&difficulty&","==","0"}, --lfr
								"alert",{"iNest", text = 2},
							},
							{
								"expect",{"&difficulty&","==","1"}, --10n
								"invoke", {
									{
										"expect",{"<Nestcount> <Nestcount>","~=","9 15"},
										"alert",{"iNest", text = 2},
									},
								},
							},
							{
								"expect",{"&difficulty&","==","3"}, --10h
								"invoke",{
									{
										"expect",{"<Nestcount>","~=","15"},
										"alert",{"iNest", text = 2},
									},
									{
										"expect",{"<Nestcount>","==","2"},
										"schedulealert",{"wBigAdd",2},
									},
									{
										"expect",{"<Nestcount>","==","8"},
										"schedulealert",{"wBigAdd",2},
									},
								},
							},
							{
								"expect",{"&difficulty&","==","2"}, --25n
								"invoke",{
									--{ -- nah, too cpu intensive
									--	"expect",{"<Nestcount> <Nestcount> <Nestcount> <Nestcount> <Nestcount> <Nestcount> <Nestcount> <Nestcount> <Nestcount>","~=","5 9 11 15 18 20 22 25 27"},
									--	"alert",{"iNest", text = 2},
									--},
									{ -- just do the alert for now
										"alert",{"iNest", text = 2},
									},
								},
							},
							{
								"expect",{"&difficulty&","==","4"}, --25h
								"invoke",{
									{ -- just do the alert for now
										"alert",{"iNest", text = 2},
									},
									{
										"expect",{"<Nestcount>","==","2"},
										"schedulealert",{"wBigAdd",1.2},
									},
									{
										"expect",{"<Nestcount>","==","5"},
										"schedulealert",{"wBigAdd",1.2},
									},
									{
										"expect",{"<Nestcount>","==","14"},
										"schedulealert",{"wBigAdd",1.2},
									},
								},
							},
						},
					},
					{
						"expect",{"#1#","find",L.chat_ThroneOfThunder["(upper nests begin to hatch)"]},
						"set",{Nestcount = "INCR|1"},
						"invoke", {
							{
								"expect",{"&difficulty&","==","0"}, --lfr
								"alert",{"iNest", text = 3},
							},
							{
								"expect",{"&difficulty&","==","1"}, --10n
								"alert",{"iNest", text = 3},
								--"invoke", {
								--	{
								--		"expect",{"<Nestcount>","~=","15"},
								--		"alert",{"iNest", text = 3},
								--	},
								--},
							},
							{
								"expect",{"&difficulty&","==","3"}, --10h
								"invoke",{
									{
									--	"expect",{"<Nestcount>","~=","15"},
										"alert",{"iNest", text = 3},
									},
									{
										"expect",{"<Nestcount>","==","4"},
										"scheduletimer",{"timerBigAdd",2},
									},
									{
										"expect",{"<Nestcount>","==","11"},
										"scheduletimer",{"timerBigAdd",2},
									},
								},
							},
							{
								"expect",{"&difficulty&","==","2"}, --25n
								"invoke",{
									--{ -- nah, too cpu intensive
									--	"expect",{"<Nestcount> <Nestcount> <Nestcount> <Nestcount> <Nestcount> <Nestcount> <Nestcount> <Nestcount> <Nestcount>","~=","5 9 11 15 18 20 22 25 27"},
									--	"alert",{"iNest", text = 2},
									--},
									{ -- just do the alert for now
										"alert",{"iNest", text = 3},
									},
								},
							},
							{
								"expect",{"&difficulty&","==","4"}, --25h
								"invoke",{
									{ -- just do the alert for now
										"alert",{"iNest", text = 3},
									},
									{
										"expect",{"<Nestcount>","==","8"},
										"scheduletimer",{"timerBigAdd",1.2},
									},
									{
										"expect",{"<Nestcount>","==","11"},
										"scheduletimer",{"timerBigAdd",1.2},
									},
								},
							},
						},
					},
				},
			},
			--[[{
				type = "event",
				event = "MONSTER_EMOTE", 
				execute = {
					{
						"expect",{"#1#","find",L.chat_ThroneOfThunder["(lower nests begin to hatch)"]},
						"set",{Nestcount = "INCR|1"},
						--"set",{Nesttemp = "INCR|1"},
						"alert",{"iNest", text = 2},
					},
					{
						"expect",{"#1#","find",L.chat_ThroneOfThunder["(upper nests begin to hatch)"]},
						"set",{Nestcount = "INCR|1"},
						--"set",{Nesttemp = "INCR|1"},
						"alert",{"iNest", text = 3},
					},
				},
			},	--]]
			{
                type = "event",
                event = "UNIT_SPELLCAST_START",
                execute = {
					{
						"expect",{"#1#","==","boss1"},
						"invoke",{
							{
								--"expect",{"#2#","find",SN[134380]},
								"expect",{"#5#","==","134380"}, -- Quills
								"invoke", {
									{
										"set",{quills = "INCR|1"},
										"message","msgQuills",
										"alert","wQuillstcast",
									},
									{
										"expect",{"&difficulty& &difficulty&","~=","2 4"},
										"invoke",{
											{
												"expect",{"<quills>","==","4"},
												"alert",{"Quillscd", time = 5},
											},
											{
												"expect",{"<quills>","~=","4"},
												"alert",{"Quillscd", time = 4},
											},
										},
									},
									{
										"expect",{"&difficulty&","==","2"}, --25n
										"alert","Quillscd",
									},
									{
										"expect",{"&difficulty&","==","4"}, --25h
										"alert","Quillscd",
									},
								},
							},
							{
								--"expect",{"#2#","find",SN[134370]}, -- Downcraft
								"expect",{"#5#","==","134370"},
								"invoke",{				
									{
										"alert","wDowndraft",
									},
									{
										"expect",{"&difficulty&","<=","2"}, --10n&25n
										"alert","Downdraftcd",
									},
									{
										"expect",{"&difficulty&",">=","3"}, --10h&25h
										"alert",{"Downdraftcd", time = 2},
									},
								},
							},
						},
					},
				},
            },
		--[[	{
                type = "event",
                event = "UNIT_SPELLCAST_SUCCEEDED",
                execute = {
                    {
						--"expect",{"#2#","find",SN[134380]},
						"expect",{"#5#","==","134380"},
						"invoke", {
							{
								"set",{quills = "INCR|1"},
								"message","msgQuills",
								"alert","wQuillstcast",
							},
							{
								"expect",{"&difficulty& &difficulty&","~=","2 4"},
								"invoke",{
									{
										"expect",{"<quills>","==","4"},
										"alert",{"Quillscd", time = 5},
									},
									{
										"expect",{"<quills>","~=","4"},
										"alert",{"Quillscd", time = 4},
									},
								},
							},
							{
								"expect",{"&difficulty&","==","2"}, --25n
								"alert","Quillscd",
							},
							{
								"expect",{"&difficulty&","==","4"}, --25h
								"alert","Quillscd",
							},
						},
                    },
				},
            },--]]
			
			-- Quills
		--[[	{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 134380,
				execute = {
					{
						"alert","iQuills",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 134380,
				execute = {
					{
						"set",{quills = "INCR|1"},
						"message","msgQuills",
						--"batchalert",{"wQuillstcast","Quillscd"},
						"alert","wQuillstcast",
					},
					{
						"expect",{"&difficulty& &difficulty&","~=","2 4"},
						"invoke",{
							{
								"expect",{"<quills>","==","4"},
								"alert",{"Quillscd", time = 5},
							},
							{
								"expect",{"<quills>","==","7"},
								"alert",{"Quillscd", time = 6},
							},
							{
								"expect",{"<quills> <quills>","~=","4 7"},
								"alert",{"Quillscd", time = 4},
							},
						},
					},
					{
						"expect",{"&difficulty&","==","2"}, --25n
						"alert","Quillscd",
					},
					{
						"expect",{"&difficulty&","==","4"}, --25h
						"alert","Quillscd",
					},
				},
			},--]]
			-- Lay Egg
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 134367,
				execute = {
					{
						"alert","wLayEgg",
					},
				},
			},	
			-- Downdraft
			--[[{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 134370,
				execute = {	
					{
						"alert","wDowndraft",
					},
					{
						"expect",{"&difficulty&","<=","2"}, --10n&25n
						"alert","Downdraftcd",
					},
					{
						"expect",{"&difficulty&",">=","3"}, --10h&25h
						"alert",{"Downdraftcd", time = 2},
					},
				},
			},--]]

			{
				--type = "combatevent",
				--eventtype = "SPELL_CAST_SUCCESS",
				--spellname = 134370,
				type = "event",
				event = "UNIT_SPELLCAST_SUCCESS",
				execute = {
					{
						--"expect",{"#2#","find",SN[134370]},
						"expect",{"#1#","==","boss1"},
						"expect",{"#5#","==","134370"},
						"message","msgDowndraft",
						"alert","wDowndraftcast",
					},
				},
			},
			-- FeedYoung
			{
                type = "event",
                event = "UNIT_SPELLCAST_CHANNEL_START",
                execute = {
                    {
						--"expect",{"#2#","find",SN[137528]},
						"expect",{"#1#","==","boss1"},
						"expect",{"#5#","==","137528"},
						"invoke",{
							{
								"batchalert",{"wFeedYoung","FeedYoungcd"},
							},
						},
                    },
				},
            },
			--[[{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137528,
				execute = {
					{
						"alert","wFeedYoung",
					},
					{
						"expect",{"&difficulty&","<=","1"}, --lfr&10n
						"alert",{"FeedYoungcd", time = 2},
					},
					{
						"expect",{"&difficulty&","==","3"}, --10h
						"alert",{"FeedYoungcd", time = 2},
					},
					{
						"expect",{"&difficulty& &difficulty& &difficulty&","~=","0 1 3"}, --25n&25h
						"alert","FeedYoungcd",
					},
				},
			}, --]]
			-- PrimalNutriment
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 140741,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"batchalert",{"PrimalNutriment","iPrimalNutriment","PrimalNutrimentBuff"},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						--"expect",{"&lfr&","==","false"},
						"alert",{"PrimalNutrimentBuff", text = 2},
					},
					{
						--"message","msgPrimalNutriment",
						"expect",{"&unitisplayer|#5#&","==","true"},
						"insert",{"PrimalUnits","#5#"},
						"canceltimer","timerPrimal",
						"scheduletimer",{"timerPrimal",2},
					},
				},
			},
			--[[{
				type = "event",
				event = "UNIT_AURA",
				execute = {
					{
						"expect",{"&targetbuff|#1#|"..SN[140741].."&","==","true"},
						"expect",{"&tabread|activeprimal|#1#&","~=","true"},
						"invoke",{
							{
								"tabinsert",{"activeprimal","#1#","true"},
								"scheduletimer",{"timerResetPrimal",33},
							},
							{
								"expect",{"#1#","==","player"},
								"batchalert",{"PrimalNutriment","iPrimalNutriment","PrimalNutrimentBuff"},
							},
							{
								"expect",{"#1#","~=","player"},
								"alert",{"PrimalNutrimentBuff", text = 2},
							},
							{
								"insert",{"PrimalUnits","&targetname|#1#&"},
								"canceltimer","timerPrimal",
								"scheduletimer",{"timerPrimal",2},
							},
						},
					},
				},
			},--]]
			-- Flight
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 133755,
				dstisplayerunit = true,
				execute = {
					{
						"alert","Flight",
						"schedulealert",{"wFlightAOver",7},
					},
				},
			}, 
			-- Daedalian Wings
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 134339,
				dstisplayerunit = true,
				execute = {
					{
						"set",{DaedalianWings = "&buffstacks|player|"..SN[134339].."&"},
						"alert",{"iDaedalianWings", text = 2},
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 134339,
				dstisplayerunit = true,
				execute = {
					{
						"set",{DaedalianWings = "&buffstacks|player|"..SN[134339].."&"},
						"alert",{"iDaedalianWings", text = 2},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED_DOSE",
				spellname = 134339,
				dstisplayerunit = true,
				execute = {
					{
						"set",{DaedalianWings = "&buffstacks|player|"..SN[134339].."&"},
						"alert",{"iDaedalianWings", text = 2},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 134339,
				dstisplayerunit = true,
				execute = {
					{
						"set",{DaedalianWings = "0"},
						"alert",{"iDaedalianWings", text = 2},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
