local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST
--TODO:
do
	local data = {
		version = 11,
		key = "Twin Consorts",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Twin Consorts"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-EMPYREAL QUEENS.BLP:35:35",
		triggers = {
			scan = {68905, 68904}, 
		},
		onactivate = {
			tracing = {68905, 68904},
			tracerstart = true,
			combatstop = true,
			defeat = {68905, 68904},
			unittracing = {"boss1", "boss2"},
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
			delayed = "no",
			phase = 1,
		},
		onstart = {
			{
				"openwindow",{"8"},
				"scheduletimer",{"timerDelayed",7},
			},
		},
		timers = {	
			timerDelayed = {
				{
					"set",{delayed = "yes"},
				},
			},
		},
		--announces = {

		--},
		messages = {
			msgNuclearInferno = {
				varname = format(L.alert["%s!"],SN[137491]),
				type = "message",
				text = format(L.alert["%s"],SN[137491]),
				color1 = "ORANGE",
				icon = ST[137491],
				sound = "ALERT13",
			},
			msgFanOfFlames = {
				varname = format(L.alert["%s %s %s (1)"],SN[137408],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[137408],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[137408],L.alert["on"]),
				color1 = "RED",
				icon = ST[137408],
				sound = "ALERT13",
			},
			msgCorruptedHealing = {
				varname = format(L.alert["%s %s %s (1)"],SN[137360],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[137360],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[137360],L.alert["on"]),
				color1 = "VIOLET",
				icon = ST[137360],
				sound = "ALERT13",
				exdps = true,
			},
			msgBeastOfNightmares = {
				varname = format(L.alert["%s %s %s"],SN[137375],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[137375],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[137375],
				sound = "ALERT13",
				throttle = 10,
			},
			msgFlamesofPassion = {
				varname = format(L.alert["%s!"],SN[137417]),
				type = "message",
				text = format(L.alert["%s"],SN[137417]),
				color1 = "ORANGE",
				icon = ST[137417],
				sound = "ALERT13",
			},
			msgXuenAid = {
				varname = format(L.alert["%s!"],SN[138855]),
				type = "message",
				text = format(L.alert["%s"],SN[138855]),
				color1 = "GREEN",
				icon = ST[138855],
				sound = "ALERT13",
				throttle = 4,
			},
			msgSerpentVitality = {
				varname = format(L.alert["%s!"],SN[138306]),
				type = "message",
				text = format(L.alert["%s"],SN[138306]),
				color1 = "GREEN",
				icon = ST[138306],
				sound = "ALERT13",
				throttle = 4,
			},
			msgFortitudeoftheOx = {
				varname = format(L.alert["%s!"],SN[138300]),
				type = "message",
				text = format(L.alert["%s"],SN[138300]),
				color1 = "GREEN",
				icon = ST[138300],
				sound = "ALERT13",
				throttle = 4,
			},			
		},
		alerts = {
			-- Cds
			Daycd = {
				varname = format(L.alert["%s Cooldown"],SN["ej7645"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN["ej7645"]),
				time = 183,
				color1 = "NEWBLUE",
				icon = ST[122789],
			},
			CosmicBarragecd = {
				varname = format(L.alert["%s Cooldown"],SN[136752]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136752]),
				time = 20,
				time2 = 17,
				color1 = "NEWBLUE",
				icon = ST[136752],
			},
			TearsOfTheSuncd = {
				varname = format(L.alert["%s Cooldown"],SN[137404]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137404]),
				time = 40,
				time2 = 23,
				color1 = "NEWBLUE",
				icon = ST[137404],
			},
			BeastOfNightmarescd = {
				varname = format(L.alert["%s Cooldown"],SN[137375]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137375]),
				time = 51,
				color1 = "NEWBLUE",
				icon = ST[137375],
			},
			Duskcd = {
				varname = format(L.alert["%s Cooldown"],SN["ej7633"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN["ej7633"]),
				time = 360,
				color1 = "NEWBLUE",
				icon = ST[7633],
			},
			LightOfDaycd = {
				varname = format(L.alert["%s Cooldown"],SN[138823]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[138823]),
				time = 6,
				color1 = "NEWBLUE",
				icon = ST[138823],
				enabled = false,
			},
			FanOfFlamescd = {
				varname = format(L.alert["%s Cooldown"],SN[137408]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137408]),
				time = 12,
				time2 = 17,
				color1 = "NEWBLUE",
				icon = ST[137408],
				exdps = true,
			},
			FlamesOfPassioncd = {
				varname = format(L.alert["%s Cooldown"],SN[137414]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137414]),
				time = 30,
				time2 = 12.5,
				color1 = "NEWBLUE",
				icon = ST[137414],
			},
			IceCommetcd = {
				varname = format(L.alert["%s Cooldown"],SN[137419]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137419]),
				time = 20,
				time2 = 17,
				time3 = 30,
				color1 = "NEWBLUE",
				icon = ST[137419],
			},
			NuclearInfernocd = {
				varname = format(L.alert["%s Cooldown"],SN[137491]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137491]),
				time = 50,
				time2 = 52,
				time3 = 60,
				color1 = "NEWBLUE",
				icon = ST[137491],
			},
			TidalForcecd = {
				varname = format(L.alert["%s Cooldown"],SN[137531]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137531]),
				time = 73,
				time2 = 20,
				time3 = 26,
				color1 = "NEWBLUE",
				icon = ST[137531],
			},
			-- Informs
			iFanofFlames = {
				varname = format("%s on self",SN[137408]),
				type = "inform",
				text = format("%s (1)",SN[137408]),
				text2 = format("%s (#11#)",SN[137408]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT15",
				icon = ST[137408],
				exdps = true,
				exhealer = true,
			},
			iFanofFlamesother = {
				varname = format("%s on others",SN[137408]),
				type = "inform",
				text = format("%s on #5#!",SN[137408]),
				text2 = format("%s on #5# (#11#)!",SN[137408]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT10",
				icon = ST[137408],
				exdps = true,
				exhealer = true,
			},
			iBeastOfNightmares = {
				varname = format("%s!",SN[137375]),
				type = "inform",
				text = format("%s!",SN[137375]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT11",
				icon = ST[137375],
				exdps = true,
				exhealer = true,
				throttle = 10,
			},
			iFlamesOfPassionAway = {
				varname = format(L.alert["%s %s, %s!"],SN[137414],L.alert["under you"],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s %s, %s!"],SN[137414],L.alert["under you"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[137414],
				throttle = 2,
			},
			iIcyShadows = {
				varname = format("%s !",SN[137440]),
				type = "inform",
				text = format("%s !",SN[137440]),
				time = 2,
				color1 = "GREEN",
				sound = "ALERT4",
				icon = ST[137440],
			},	
			iSerpentVitality = {
				varname = format("%s!",SN[138306]),
				type = "inform",
				text = format("%s!",SN[138306]),
				time = 2,
				color1 = "GREEN",
				sound = "ALERT4",
				icon = ST[138306],
				extank = true,
				exdps = true,
			},				
			-- Warnings
			Phase2 = {
				varname = format(L.alert["Phase 2"]),
				type = "simple",
				text = format(L.alert["Phase 2"]),
				time = 2,
				color1 = "ORANGE",
				icon = ST[137491],
				sound = "ALERT13",
			},
			Phase3 = {
				varname = format(L.alert["Phase 3"]),
				type = "simple",
				text = format(L.alert["Phase 3"]),
				time = 2,
				color1 = "GREEN",
				icon = ST[137408],
				sound = "ALERT13",
			},
			wNuclearInferno = {
				varname = format("%s!",SN[137491]),
				type = "simple",
				text = format("%s!",SN[137491]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT13",
				icon = ST[137491],
			},
			wIceCommet = {
				varname = format("%s!",SN[137419]),
				type = "simple",
				text = format("%s!",SN[137419]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT1",
				icon = ST[137419],
			},
			wCosmicBarrage = {
				varname = format("%s %s!",SN[136752],L.alert["Incoming"]),
				type = "simple",
				text = format("%s %s!",SN[136752],L.alert["Incoming"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = ST[136752],
			},
			wTearsOfSun = {
				varname = format("%s!",SN[137404]),
				type = "simple",
				text = format("%s!",SN[137404]),
				time = 2,
				color1 = "YELLOW",
				sound = "ALERT14",
				icon = ST[137404],
			},
			wTidalForce = {
				varname = format("%s!",SN[137531]),
				type = "simple",
				text = format("%s!",SN[137531]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT11",
				icon = ST[137531],
			},
			-- Casts
			TidalForceCast = {
				varname = format(L.alert["%s %s"],SN[137531],L.alert["Active"]),
				type = "centerpopup",
				text = format(L.alert["%s %s"],SN[137531],L.alert["Active"]),
				time = 18,
				flashtime = 18,
				color1 = "RED",
				icon = ST[137531],
			},
			TearsOfTheSunCast = {
				varname = format(L.alert["%s %s"],SN[137404],L.alert["Active"]),
				type = "centerpopup",
				text = format(L.alert["%s %s"],SN[137404],L.alert["Active"]),
				time = 10,
				flashtime = 10,
				color1 = "RED",
				icon = ST[137404],
			},
			CosmicBarrageCast = {
				varname = format(L.alert["%s %s"],L.alert["Incoming"],SN[136752]),
				type = "centerpopup",
				text = format(L.alert["%s %s"],L.alert["Incoming"],SN[136752]),
				time = 4.5,
				color1 = "RED",
				icon = ST[136752],
			},
			-- Debuffs
			FanOfFlamesDebuff = {
				varname = format(L.alert["%s Debuff"],SN[137408]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[137408]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[137408]),
				text3 = format(L.alert["#5#: %s (1)"],SN[137408]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[137408]),
				time = 30,
				color1 = "NEWBLUE",
				icon = ST[137408],
				tag = "#5#",
				exdps = true,
			},
			CorruptedHealingDebuff = {
				varname = format(L.alert["%s Debuff"],SN[137360]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[137360]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[137360]),
				text3 = format(L.alert["#5#: %s (1)"],SN[137360]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[137360]),
				time = 30,
				color1 = "VIOLET",
				icon = ST[137360],
				tag = "#5#",
				exdps = true,
			},
		},
		events = {
			-- NuclearInferno
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 137491,
				execute = {
					{
						"message","msgNuclearInferno",
						"batchalert",{"wNuclearInferno","NuclearInfernocd"},
					},
				},
			},
			-- TidalForce
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 137531,
				execute = {
					{
						"batchalert",{"wTidalForce","TidalForceCast","TidalForcecd"},
					},
				},
			},
			-- FlamesOfPassion
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {137414},
				execute = {
					{
						"alert","FlamesOfPassioncd",
						"message","msgFlamesofPassion",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_PERIODIC_DAMAGE",
				spellname = 137417,
				dstisplayerunit = true,
				execute = {
					{
						"alert","iFlamesOfPassionAway",
					},
				},
			},
			--IceCommet
			{
				type = "combatevent",
				eventtype = "SPELL_SUMMON",
				spellid = {137419},
				execute = {
					{
						"expect",{"<phase>","~=","3"},
						"batchalert",{"IceCommetcd","wIceCommet"},
					},
					{
						"expect",{"<phase>","==","3"},
						"alert","wIceCommet",
						"alert",{"IceCommetcd", time = 3},
					},
				},
			},
			-- UNIT_SPELLCAST_SUCCEEDED
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					{
						"expect",{"#2#","==",SN[138823]}, -- LightOfDay
						"alert","LightOfDaycd",
					},
					{
						"expect",{"#2#","==",SN[137105]}, -- Night
						"batchquash",{"LightOfDaycd","FanOfFlamescd","FlamesOfPassioncd"},
						"alert",{"CosmicBarragecd", time = 2},
						"alert",{"TearsOfTheSuncd", time = 2},
						"batchalert",{"Daycd","BeastOfNightmarescd","Duskcd"},
					},
					{
						"expect",{"#2#","==",SN[137187]}, -- Day
						"invoke", {
							{
								"expect",{"<delayed>","==","yes"},
								"batchquash",{"CosmicBarragecd","TearsOfTheSuncd","BeastOfNightmarescd"},
								--"alert",{"FlamesOfPassioncd", time = 2},
								"alert",{"IceCommetcd", time = 2},
								"batchalert",{"Phase2","LightOfDaycd","FanOfFlamescd"},
								"invoke",{
									{
										"expect",{"&difficulty&",">=","3"}, --10h&25h
										"alert",{"NuclearInfernocd", time = 2},
									},
								},
							},
						},
					},
				},
			},
			{
				type = "event",
				event = "YELL", 
				execute = {
					-- Phase 3
					{
						"expect",{"#1#","find",L.chat_ThroneOfThunder["(Just this once...)"]},
						"batchquash",{"IceCommetcd","FanOfFlamescd"},
						"alert","Phase3",
						"alert",{"IceCommetcd", time = 2},
						"alert",{"TidalForcecd", time = 3},
						"set",{phase = "3"},
						"invoke", {
							{
								"expect",{"&difficulty&",">=","3"}, --10h&25h
								"alert",{"NuclearInfernocd", time = 3},
							},
							--{
							--	"expect",{"&difficulty&","<=","2"}, --normal
							--	"alert",{"TidalForcecd", time = 3},
							--},							
						},
					},
				},
			},
			-- Icy Shadows
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137440,
				execute = {
					{
						"expect",{"&unitisplayer|#5#&","==","true"},
						"invoke",{
							{
								"expect",{"#4#","==","&playerguid&"},
								"alert","iIcyShadows",
							},
						},
					},
				},
			}, 			
			-- Fan of Flames
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137408,
				execute = {
					{
						"expect",{"&unitisplayer|#5#&","==","true"},
						"invoke",{
							{
								"message","msgFanOfFlames",
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"alert","FanOfFlamesDebuff",
								"alert","iFanofFlames",
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"alert",{"FanOfFlamesDebuff", text = 3},
								"invoke",{
									{
										"expect",{"&playerdebuff|"..SN[137408].."&","==","false"},
										"alert","iFanofFlamesother",
									},
								},
							},
						},
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 137408,
				execute = {
					{
						"expect",{"&unitisplayer|#5#&","==","true"},
						"invoke",{
							{
								"message",{"msgFanOfFlames", text = 2},
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"alert",{"FanOfFlamesDebuff", text = 2},
								"invoke",{
									{
										"expect",{"#11#",">=","2"},
										"alert",{"iFanofFlames", text = 2},
									},
								},
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"alert",{"FanOfFlamesDebuff", text = 4},
								"invoke",{
									{
										"expect",{"&playerdebuff|"..SN[137408].."&","==","false"},
										"alert","iFanofFlamesother",
									},
								},
							},
						},
					},
				},     
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 137408,
				execute = {
					{
						"quash","FanOfFlamesDebuff",
					},
				},
			},	
			-- CosmicBarrage
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136752,
				execute = {
					{
						"batchalert",{"wCosmicBarrage","CosmicBarrageCast"},
					},
					{
						"expect",{"&timeleft|Daycd|0&","<","165"},
						"alert","CosmicBarragecd",
					},
				},
			}, 
			-- TearsOfSun
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137404,
				execute = {
					{
						"batchalert",{"wTearsOfSun","TearsOfTheSunCast"},
					},
					{
						"expect",{"&timeleft|Daycd|0&","<","145"},
						"alert","TearsOfTheSuncd",
					},
				},
			}, 
			-- BeastOfNightmares
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137375,
				execute = {
					{
						"expect",{"&unitisplayer|#5#&","==","true"},
						"alert","iBeastOfNightmares",
						"message","msgBeastOfNightmares",
					},
					{
						"expect",{"&timeleft|Daycd|0&","<","135"},
						"alert","BeastOfNightmarescd",
					},
				},
			},
			--
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","68904"}, --Suen
						"quash","TidalForcecd",
					},
					{
						"expect",{"&npcid|#4#&","==","68905"}, --Lu'lin
						"batchquash",{"TidalForcecd","Daycd","Duskcd","NuclearInfernocd"},
						"alert","LightOfDaycd",
						"alert",{"FanOfFlamescd", time = 2},
					},	
				},
			},
			-- Corrupted Healing
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {137360,},
				execute = {
					{
						"message","msgCorruptedHealing",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","CorruptedHealingDebuff",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"CorruptedHealingDebuff", text = 3},
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {137360,},
				execute = {
					{
						"message",{"msgCorruptedHealing", text = 2},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert",{"CorruptedHealingDebuff", text = 2},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"CorruptedHealingDebuff", text = 4},
					},
				},
			},
			-- Celestial Aid Xuen's Blessed Alacrity
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {138855},
				execute = {
					{
						"message","msgXuenAid",
					},
				},
			}, 
			-- Celestial Aid SerpentVitality
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {138306},
				execute = {
					{
						"message","msgSerpentVitality",
						"alert","iSerpentVitality",
					},
				},
			}, 
			-- Celestial Aid FortitudeoftheOx
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {138300},
				execute = {
					{
						"message","msgFortitudeoftheOx",
					},
				},
			}, 
		},
	}

	DXE:RegisterEncounter(data)
end
