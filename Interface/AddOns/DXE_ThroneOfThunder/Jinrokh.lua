local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST

do
	local data = {
		version = 9,
		key = "Jin'rokh the Breaker",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Jin'rokh the Breaker"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-JINROKH THE BREAKER.BLP:35:35",
		triggers = {
			scan = { 69465, }, 
		},
		onactivate = {
			tracing = {
				69465,
			},
			tracerstart = true,
			combatstop = true,
			defeat = {
				69465, 
			},
			unittracing = {
				"boss1",
			},
		},
		windows = {
			proxwindow = true,
		},
		enrage = {
			time10n = 540,
			time25n = 540,
			time10h = 360,
			time25h = 360,
			time25lfr = 540,
		},
		userdata = {
			--Focusedcount = 0,
			focusedtarget = "",
			IonizationUnits = {type = "container"}, --, wipein = 3
		},
		onstart = {
			{
				"batchalert",{"Throwcd","FocusedLightningcd"},
				"alert",{"StaticBurstcd", time = 2},
			},
			{
				"expect",{"&difficulty&",">=","3"}, --10h&25h
				"alert","Ionizationcd",
			},
		},
		arrows = {
			Throwarrow = {
				varname = SN[137175],
				unit = "#5#",
				persist = 5,
				action = "TOWARD",
				msg = L.chat_ThroneOfThunder["GO TO HIM FOR POOL!"],
				spell = SN[137175],
			},
			Focusedarrow = {
				varname = SN[137399],
				unit = "&upvalue&", --<focusedtarget>
				persist = 5,
				action = "AWAY",
				msg = L.alert["MOVE AWAY!"],
				spell = SN[137399],
				range1 = 7,
				range2 = 10,
				range3 = 13,
			},
			--[[Ionizationarrow = {
				varname = format(L.alert["Closest %s"],SN[138732]),
				unit = "&closest|IonizationUnits&",
				persist = 5,
				action = "AWAY",
				msg = L.alert["MOVE AWAY"],
				spell = format(L.alert["Closest %s"],SN[138732]),
				range1 = 6,
				range2 = 9,
				range3 = 12,
			},--]]
		},
		raidicons = {
			Focusedmark = {
				varname = SN[137399],
				type = "FRIENDLY",
				persist = 30,
				--unit = "<focusedtarget>",
				unit = "&upvalue&",
				icon = 1,
			},
			Throwmark = {
				varname = SN[137175],
				type = "FRIENDLY",
				persist = 15,
				unit = "#5#",
				icon = 8,
			},			
		},
		timers = {
			timerThrowarrow = {
				{
					"arrow","Throwarrow",
				},
			},
			timerFocusedarrow = {
				{
					"expect",{"&inrange|<focusedtarget>&","<","6"},
					"arrow","Focusedarrow",
					"scheduletimer",{"timerFocusedarrow",5},
				},
			},
			timerMoveOut = {
				{
					"expect",{"&playerdebuff|"..SN[138002].."&","==","true"},
					"alert","iMoveOutOfPool",
				},
			},
			--[[timerIonizationmsg = {
				{
					--"arrow","Ionizationarrow",
					"message","warnIonization",
				},
			},--]]
			--[[timerIonization = {
				{
					"expect",{"&inrange|#5#&","<","10"},
					"arrow","Ionizationarrow",
				},
				{
					"expect",{"&count|IonizationUnits&",">=","1"},
					"scheduletimer",{"timerIonization",1},
				},
			},--]]
		},
		announces = {
			Focusedsay = {
				varname = format(L.alert["%s %s %s"],SN[137399],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s"],SN[137399],L.alert["on"],L.alert["Me"]), --,"&playername&"
				--enabled = false,
			},
		},
		messages = {
			warnFocused = {
				varname = format(L.alert["%s"],SN[137422]),
				type = "message",
				text = format(L.alert["%s %s &upvalue&"],SN[137422],L.alert["on"]),
				color1 = "DCYAN",
				icon = ST[137422],
				sound = "ALERT13",
			},
			--[[warnstorm = {
				varname = format(L.alert["%s!"],SN[137313]),
				type = "message",
				text = format(L.alert["%s!"],SN[137313]),
				color1 = "INDIGO",
				icon = ST[137313],
				sound = "ALERT13",
			},--]]
			warnthrow = {
				varname = format(L.alert["%s"],SN[137175]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[137175],L.alert["on"]),
				color1 = "ORANGE",
				icon = ST[137175],
				sound = "ALERT13",
			},
			warnStaticWound = {
				varname = format(L.alert["%s"],SN[138349]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[138349],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[138349],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[138349],
				sound = "ALERT13",
			},
			--[[warnIonization = {
				varname = format(L.alert["%s"],SN[138732]),
				type = "message",
				text = format(L.alert["%s %s &list|IonizationUnits&"],SN[138732],L.alert["on"]),
				color1 = "TEAL",
				icon = ST[138732],
				sound = "ALERT13",
			},--]]
			warnStaticBurst = {
				varname = format(L.alert["%s"],SN[137162]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[137162],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[137162],
				sound = "ALERT13",
				exdps = true,
			},	
		},
		alerts = {
			-- Coolldowns
			FocusedLightningcd = {
				varname = format(L.alert["%s Cooldown"],SN[137399]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137399]),
				time = 8,
				time2 = 26,
				time3 = 13,
				color1 = "NEWBLUE",
				icon = ST[137399],
			},
			Throwcd = {
				varname = format(L.alert["%s Cooldown"],SN[137175]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137175]),
				time = 30,
				color1 = "NEWBLUE",
				icon = ST[137175],
			},
			Stormcd = {
				varname = format(L.alert["%s Cooldown"],SN[137313]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137313]),
				time = 60,
				color1 = "ORANGE",
				color2 = "RED",
				flashtime = 10,
				audiocd = true,
				audiotime = 5,
				icon = ST[137313],
				ability = 7748
			},
			Ionizationcd = {
				varname = format(L.alert["%s Cooldown"],SN[138732]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[138732]),
				time = 60,
				color1 = "GREEN",
				icon = ST[138732],
			},
			StaticBurstcd = {
				varname = format(L.alert["%s Cooldown"],SN[137162]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137162]),
				time = 19,
				time2 = 13,
				time3 = 21,
				color1 = "INDIGO",
				icon = ST[137162],
				exdps = true,
				exhealer = true,
			},
			-- Warnings
			warnFocusedself = {
				varname = format(L.alert["%s %s %s!"],SN[137399],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[137399],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT12",
				icon = ST[137399],
			},
			wStorm = {
				varname = format(L.alert["%s!"],SN[137313]),
				type = "simple",
				text = format(L.alert["%s!"],SN[137313]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT11",
				icon = ST[137313],
			},
			wthrow = {
				varname = format(L.alert["%s %s %s!"],SN[137175],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[137175],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "ORANGE",
				sound = "ALERT1",
				icon = ST[137175],
			},
			warnElectrified = {
				varname = format(L.alert["%s %s %s, %s!"],SN[138006],L.alert["on"],L.alert["YOU"],L.alert["MOVE AWAY"]),
				type = "simple",
				text = format(L.alert["%s %s %s, %s!"],SN[138006],L.alert["on"],L.alert["YOU"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[138006],
				flashscreen = true,
				throttle = 1,
			},
			Ionizationwarn = {
				varname = format(L.alert["%s %s %s!"],SN[138732],L.alert["on"],L.alert["YOU"]),
				type = "inform",
				text = format(L.alert["%s %s %s!"],SN[138732],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT4",
				icon = ST[138732],
			},
			-- Informs
			iIonization = {
				varname = format(L.alert["%s %s!"],L.alert["Incoming"],SN[138732]),
				type = "inform",
				text = format(L.alert["%s %s!"],L.alert["Incoming"],SN[138732]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT13",
				icon = ST[138732],
			},
			--[[iIonizationDispell = {
				varname = format(L.alert["%s %s #5#!"],SN[138732],L.alert["on"]),
				type = "inform",
				text = format(L.alert["%s %s #5#!"],SN[138732],L.alert["on"]),
				time = 2,
				color1 = "INDIGO",
				--sound = "ALERT13",
				icon = ST[138732],
			},--]]	
			iStaticBurst = {
				varname = format(L.alert["%s!"],SN[137162]),
				type = "inform",
				text = format(L.alert["%s!"],SN[137162]),
				text2 = format(L.alert["%s %s #5#!"],SN[137162],L.alert["on"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT13",
				icon = ST[137162],
			},
			iMoveOutOfPool = {
				varname = format(L.alert["%s %s!"],SN[138002],L.chat_ThroneOfThunder["Move Out from the Pool"]),
				type = "inform",
				text = format(L.alert["%s %s!"],SN[138002],L.chat_ThroneOfThunder["Move Out from the Pool"]),
				time = 3,
				color1 = "RED",
				sound = "ALERT12",
				icon = ST[138002],
			},
			iStaticConduction = {
				varname = format(L.alert["%s %s!"],SN[138375],L.chat_ThroneOfThunder["Move Away from the Pool"]),
				type = "inform",
				text = format(L.alert["%s %s!"],SN[138375],L.chat_ThroneOfThunder["Move Away from the Pool"]),
				time = 4,
				color1 = "RED",
				sound = "ALERT12",
				icon = ST[138375],
				throttle = 2,
			},
			iStaticWound = {
				varname = format(L.alert["%s (2)"],SN[138349]),
				type = "inform",
				text = format(L.alert["%s (1)"],SN[138349]),
				text2 = format(L.alert["%s (#11#)"],SN[138349]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT13",
				icon = ST[138349],
			},
			-- Debuffs
			IonizationDebuff = { -- Heroic
				varname = format(L.alert["%s Debuff"],SN[138732]),
				type = "debuff",
				text = format(L.alert["#5#: %s"],SN[138732]),
				text2 = format(L.alert["%s: %s"],L.alert["YOU"],SN[138732]),
				time = 24,
				color1 = "RED",
				icon = ST[138732],
				tag = "#5#",
				ex25 = true,
			},		
			StaticWoundDebuff = {
				varname = format(L.alert["%s Debuff"],SN[138349]),
				type = "debuff",
				text = format(L.alert["#5#: %s (1)"],SN[138349]),
				text2 = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[138349]),
				text3 = format(L.alert["#5#: %s (#11#)"],SN[138349]),
				text4 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[138349]),
				time = 25,
				color1 = "INDIGO",
				icon = ST[138349],
				tag = "#5#",
			},	
			-- Centerpopup
			stormactive = {
				varname = format(L.alert["%s Duration"],SN[137313]),
				type = "centerpopup",
				text = format(L.alert["%s Duration"],SN[137313]),
				time = 15,
				color1 = "RED",
				icon = ST[137313],
			},			
		},
		events = {
		    -- Focused Lightning
			--[[{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 137399,
				execute = {
					{
						"message","warnFocused",
						"raidicon","Focusedmark",
						"alert","FocusedLightningcd",
					--	"batchalert", {"Stormcd","Throwcd"},
					},
					{
						"expect",{"&inrange|#5#&","<","6"},
						--"expect",{"&lfr&","==","false"},
						"set",{focusedtarget = "#5#"},
						"arrow","Focusedarrow",
						"scheduletimer",{"timerFocusedarrow",5},
					},
				},
			},--]]
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 137399,
				execute = {
					{
						--"message","warnFocused",
						"alert","FocusedLightningcd",
						--"openwindow",{"8"},
						--"scheduletimer",{"timerFocuseda",0.095},
						
					--	"batchalert", {"Stormcd","Throwcd"},
					},
					{
						"target",{
							source = "#1#",
							wait = 0.025,
							schedule = 12,
							raidicon = "Focusedmark",
							arrow = "Focusedarrow",
							--arrowdef = "<",
							--arrowrange = 40,
							--announce = "throwspearsay",
							message = "warnFocused",
							--alerts = {
								--self = "warnthrowspearself",
								--other = 
								--unknown = "",
							--},
						},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 137422,
				execute = {
					{
						"removeraidicon","#5#",
						"canceltimer",{"timerFocusedarrow"},
						"removearrow","#5#",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"closewindow",
					},
				},
			},			
			{
				type = "event",
				event = "WHISPER", 
				execute = {
					{
						"expect",{"#1#","find","spell:137422"},
						"alert","warnFocusedself",
						"announce","Focusedsay",
						"openwindow",{"8"},
					},
				},
			},
		    -- Lightning Storm
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 137313,
				execute = {
					{
						--"message","warnstorm",
						"batchalert", {"wStorm","Stormcd","Throwcd"},
						"alert",{"StaticBurstcd", time = 3},
						"alert",{"FocusedLightningcd", time = 2},
					},
					{
						"expect",{"&difficulty&",">=","3"}, --10h&25h
						"alert","Ionizationcd",						
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 137313,
				execute = {
					{
						"alert","stormactive",
					},
				},
			},
			-- Thundering Throw
			{
				type = "event",
				event = "EMOTE", 
				execute = {
					{
						"expect",{"#1#","find","spell:137175"},
						"invoke",{
							{
								"message","warnthrow",
								"raidicon","Throwmark",
								"alert","Stormcd",
								"scheduletimer",{"timerThrowarrow",5},
								"scheduletimer",{"timerMoveOut",57},
							},
							{
								"expect",{"#5#","==","&playername&"},
								"alert","wthrow",
							},
						},
					},
				},
			},
		    -- Electrified Waters
			{
				type = "combatevent",
				eventtype = "SPELL_PERIODIC_DAMAGE",
				spellid = 138006,
				dstisplayerunit = true,
				execute = {
					{
						"alert","warnElectrified"
					},
				},
			},
		    -- Static Wound Conduction
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellid = 138375,
				dstisplayerunit = true,
				execute = {
					{
						"alert","iStaticConduction"
					},
				},
			},
			-- Ionization (heroic)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 138732,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","Ionizationwarn",
						"openwindow",{"24"},
						"alert",{"IonizationDebuff",text = 2},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"openwindow",{"8"},
						"alert","IonizationDebuff",
					},
					--{
					--	"insert",{"IonizationUnits","#5#"},
						--"tabinsert",{"IonizationUnits","#5#","true"},
					--	"canceltimer","timerIonizationmsg",
					--	"scheduletimer",{"timerIonizationmsg",0.5},
					--},
					--{
					--	"scheduletimer",{"timerIonization",2},
						--"expect",{"&inrange|#5#&","<","9"},
						--"arrow","Ionizationarrow",
					--},
				--	{
				--		"expect",{"&dispell|magic&","==","true"},
				--		"alert","iIonizationDispell",
				--	},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 138732,
				execute = {
					{
						"quash","IonizationDebuff",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"closewindow",
						"invoke",{
							{
								"expect",{"&playerdebuff|"..SN[137422].."&","==","true"},
								"openwindow",{"8"},
							},
						},
					},					
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 138732,
				execute = {
					{
						"alert",{"FocusedLightningcd", time = 3},
						"alert","iIonization",
					},
				},
			},
			-- StaticBurst
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137162,
				execute = {
					{
						"alert","StaticBurstcd",
						"message","warnStaticBurst",
					},
					--[[{
						"expect",{"#4#","==","&playerguid&"},
						"alert","iStaticBurst",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"iStaticBurst",text = 2},
					},--]]
				},
			},
			-- Static Wound
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 138349,
				execute = {
					{
						"message","warnStaticWound",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","iStaticWound",
						"alert",{"StaticWoundDebuff",text = 2},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert","StaticWoundDebuff",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 138349,
				execute = {
					{
						"message",{"warnStaticWound", text = 2},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert",{"iStaticWound",text = 2},
						"alert",{"StaticWoundDebuff",text = 4},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"StaticWoundDebuff",text = 3},
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
