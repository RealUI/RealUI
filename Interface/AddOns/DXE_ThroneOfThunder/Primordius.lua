local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST
--TODO:

do
	local data = {
		version = 9,
		key = "Primordius",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Primordius"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-PRIMORDIUS.BLP:35:35",
		triggers = {
			scan = {69017}, 
		},
		onactivate = {
			tracing = {69017},
			tracerstart = true,
			combatstop = true,
			defeat = {69017},
			unittracing = {"boss1"},
		},
		enrage = {
			time10n = 480,
			time25n = 480,
			time10h = 480,
			time25h = 480,
		},
		windows = {
			proxwindow = true,
		},
		userdata = {
			postules = 0,
			acidSpines = 0,
			metabolicBoost = 0,
			ThickBonesP = "0", -- Stats
			ThickBonesN = "0",
			ThickBonesT = 0,
			ThickBonesTN = 0,
			ClearMindP = "0", -- Mastery
			ClearMindN = "0",
			ClearMindT = 0,
			ClearMindTN = 0,
			ImprovedSynampesP = "0", -- Haste
			ImprovedSynampesN = "0",
			ImprovedSynampesT = 0,
			ImprovedSynampesTN = 0,
			KeenEyesightP = "0", -- Critical
			KeenEyesightN = "0",
			KeenEyesightT = 0,
			KeenEyesightTN = 0,
			Mutationtext = "",
			ViscousHorror = 0,
			TotalP = 0,
			marker = "",
		},
		onstart = {
			{
				"alert",{"PrimordialStrikecd", time = 2},
			},
			{
				"expect",{"&difficulty&",">=","3"}, --10h&25h
				"alert",{"ViscousHorrorcd", time = 2},
				"scheduletimer",{"timerViscousHorror",11.5},
			},
		},
		timers = {	
			timerViscousHorror = {
				{
					"set",{ViscousHorror = "INCR|1"},
					"message","msgViscousHorror",
					"batchalert",{"iViscousHorror","ViscousHorrorcd"},
					"scheduletimer",{"timerViscousHorror",30},
				},
			},
			timerMutationsP = {
				{
					"set",{KeenEyesightP = "0"},
					"set",{ImprovedSynampesP = "0"},
					"set",{ThickBonesP = "0"},
					"set",{ClearMindP = "0"},
					"set",{TotalP = "INCR|1"},
				},
				{
					"expect",{"&playerdebuff|"..SN[136180].."&","==","true"}, -- Critical
					"set",{KeenEyesightP = "1"},
					"set",{KeenEyesightT = "&debuffstacks|player|"..SN[136180].."&"},
				},	
				{
					"expect",{"&playerdebuff|"..SN[136182].."&","==","true"}, -- Haste
					"set",{ImprovedSynampesP = "1"},
					"set",{ImprovedSynampesT = "&debuffstacks|player|"..SN[136182].."&"},
				},
				{
					"expect",{"&playerdebuff|"..SN[136184].."&","==","true"}, -- Stats
					"set",{ThickBonesP = "1"},
					"set",{ThickBonesT = "&debuffstacks|player|"..SN[136184].."&"},
				},
				{
					"expect",{"&playerdebuff|"..SN[136186].."&","==","true"}, -- Mastery
					"set",{ClearMindP = "1"},
					"set",{ClearMindT = "&debuffstacks|player|"..SN[136186].."&"},
				},
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","1 0 0 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightT>)"],ST[136180])},
				},
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","1 1 0 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightT>) |T%s:24:24:-5|t(<ImprovedSynampesT>)"],ST[136180],ST[136182])},
				},
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","1 1 1 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightT>) |T%s:24:24:-5|t(<ImprovedSynampesT>) |T%s:24:24:-5|t(<ThickBonesT>)"],ST[136180],ST[136182],ST[136184])},
				},
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","1 1 1 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightT>) |T%s:24:24:-5|t(<ImprovedSynampesT>) |T%s:24:24:-5|t(<ThickBonesT>) |T%s:24:24:-5|t(<ClearMindT>)"],ST[136180],ST[136182],ST[136184],ST[136186])},
				},
				
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","0 1 0 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ImprovedSynampesT>)"],ST[136182])},
				},
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","0 1 1 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ImprovedSynampesT>) |T%s:24:24:-5|t(<ThickBonesT>)"],ST[136182],ST[136184])},
				},
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","0 1 0 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ImprovedSynampesT>) |T%s:24:24:-5|t(<ClearMindT>)"],ST[136182],ST[136186])},
				},
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","0 1 1 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ImprovedSynampesT>) |T%s:24:24:-5|t(<ThickBonesT>) |T%s:24:24:-5|t(<ClearMindT>)"],ST[136182],ST[136184],ST[136186])},
				},

				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","0 0 1 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ThickBonesT>)"],ST[136184])},
				},
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","0 0 1 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ThickBonesT>) |T%s:24:24:-5|t(<ClearMindT>)"],ST[136184],ST[136186])},
				},
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","1 0 1 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightT>) |T%s:24:24:-5|t(<ThickBonesT>)"],ST[136180],ST[136184])},
				},

				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","0 0 0 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ClearMindT>)"],ST[136186])},
				},
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","1 0 0 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightT>) |T%s:24:24:-5|t(<ClearMindT>)"],ST[136180],ST[136186])},
				},
				{
					"expect",{"<KeenEyesightP> <ImprovedSynampesP> <ThickBonesP> <ClearMindP>","==","1 1 0 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightT>) |T%s:24:24:-5|t(<ImprovedSynampesT>) |T%s:24:24:-5|t(<ClearMindT>)"],ST[136180],ST[136182],ST[136186])},
				},
				{
					"alert",{"iPositiveMutation", text = 2},
					"message","msgMutations",
				},
			},
			timerMutationsN = {
				{
					"set",{KeenEyesightN = "0"},
					"set",{ImprovedSynampesN = "0"},
					"set",{ThickBonesN = "0"},
					"set",{ClearMindN = "0"},
				},
				{
					"expect",{"&playerdebuff|"..SN[136181].."&","==","true"}, -- Critical
					"set",{KeenEyesightN = "1"},
					"set",{KeenEyesightTN = "&debuffstacks|player|"..SN[136181].."&"},
				},	
				{
					"expect",{"&playerdebuff|"..SN[136183].."&","==","true"}, -- Haste
					"set",{ImprovedSynampesN = "1"},
					"set",{ImprovedSynampesTN = "&debuffstacks|player|"..SN[136183].."&"},
				},
				{
					"expect",{"&playerdebuff|"..SN[136185].."&","==","true"}, -- Stats
					"set",{ThickBonesN = "1"},
					"set",{ThickBonesTN = "&debuffstacks|player|"..SN[136185].."&"},
				},
				{
					"expect",{"&playerdebuff|"..SN[136187].."&","==","true"}, -- Mastery
					"set",{ClearMindN = "1"},
					"set",{ClearMindTN = "&debuffstacks|player|"..SN[136187].."&"},
				},
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","1 0 0 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightTN>)"],ST[136181])},
				},
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","1 1 0 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightTN>) |T%s:24:24:-5|t(<ImprovedSynampesTN>)"],ST[136181],ST[136183])},
				},
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","1 1 1 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightTN>) |T%s:24:24:-5|t(<ImprovedSynampesTN>) |T%s:24:24:-5|t(<ThickBonesTN>)"],ST[136181],ST[136183],ST[136185])},
				},
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","1 1 1 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightTN>) |T%s:24:24:-5|t(<ImprovedSynampesTN>) |T%s:24:24:-5|t(<ThickBonesTN>) |T%s:24:24:-5|t(<ClearMindTN>)"],ST[136181],ST[136183],ST[136185],ST[136187])},
				},
				
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","0 1 0 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ImprovedSynampesTN>)"],ST[136183])},
				},
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","0 1 1 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ImprovedSynampesTN>) |T%s:24:24:-5|t(<ThickBonesTN>)"],ST[136183],ST[136185])},
				},
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","0 1 0 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ImprovedSynampesTN>) |T%s:24:24:-5|t(<ClearMindTN>)"],ST[136183],ST[136187])},
				},
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","0 1 1 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ImprovedSynampesTN>) |T%s:24:24:-5|t(<ThickBonesTN>) |T%s:24:24:-5|t(<ClearMindTN>)"],ST[136183],ST[136185],ST[136187])},
				},

				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","0 0 1 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ThickBonesTN>)"],ST[136185])},
				},
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","0 0 1 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ThickBonesTN>) |T%s:24:24:-5|t(<ClearMindTN>)"],ST[136185],ST[136187])},
				},
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","1 0 1 0"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightTN>) |T%s:24:24:-5|t(<ThickBonesTN>)"],ST[136181],ST[136185])},
				},

				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","0 0 0 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<ClearMindTN>)"],ST[136187])},
				},
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","1 0 0 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightTN>) |T%s:24:24:-5|t(<ClearMindTN>)"],ST[136181],ST[136187])},
				},
				{
					"expect",{"<KeenEyesightN> <ImprovedSynampesN> <ThickBonesN> <ClearMindN>","==","1 1 0 1"},
					"set",{Mutationtext = format(L.alert["|T%s:24:24:-5|t(<KeenEyesightTN>) |T%s:24:24:-5|t(<ImprovedSynampesTN>) |T%s:24:24:-5|t(<ClearMindTN>)"],ST[136181],ST[136183],ST[136187])},
				},
				{
					"alert",{"iNegativeMutation", text = 2},
				},			
			},
		},
		--announces = {		},
		raidicons = {
			bigoozeicon = {
				varname = L.npc_ThroneOfThunder["Viscous Horror"],
				type = "ENEMY",
				persist = 400,
				unit = "<marker>",
				icon = 1,
				id = 69070,
			},
		},
		messages = {
			msgMutations = {
				varname = format(L.alert["%s"],SN[140546]),
				type = "message",
				text = format(L.alert["%s (<TotalP>/5)"],SN[140546],L.alert["on"]),
				color1 = "ORANGE",
				icon = ST[140546],
				sound = "ALERT13",
			},
			msgCausticGas = {
				varname = format(L.alert["%s!"],SN[136216]),
				type = "message",
				text = format(L.alert["%s"],SN[136216]),
				color1 = "GREEN",
				icon = ST[136216],
				sound = "ALERT13",
			},
			msgPrimordialStrike = {
				varname = format(L.alert["%s!"],SN[136037]),
				type = "message",
				text = format(L.alert["%s"],SN[136037]),
				color1 = "PEACH",
				icon = ST[136037],
				sound = "ALERT13",
			},
			msgMalformed = {
				varname = format(L.alert["%s"],SN[136050]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[136050],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[136050],L.alert["on"]),
				color1 = "RED",
				icon = ST[136050],
				sound = "ALERT13",
			},
			--[[msgGasBladder = {
				varname = format(L.alert["%s"],SN[136215]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136215],L.alert["on"]),
				color1 = "TEAL",
				icon = ST[136215],
				sound = "ALERT13",
			},--]]
			msgEruptingPustules = {
				varname = format(L.alert["%s"],SN[136246],L.alert["on"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136246],L.alert["on"]),
				color1 = "BROWN",
				icon = ST[136246],
				sound = "ALERT13",
			},
			msgPathogenGlands = {
				varname = format(L.alert["%s"],SN[136225]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136225],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[136225],
				sound = "ALERT13",
			},
			msgVolatilePathogen = {
				varname = format(L.alert["%s"],SN[136228]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136228],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[136228],
				sound = "ALERT13",
			},
			msgMetabolicBoost = {
				varname = format(L.alert["%s"],SN[136245]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136245],L.alert["on"]),
				color1 = "TAN",
				icon = ST[136245],
				sound = "ALERT13",
			},
			msgVentralSacs = {
				varname = format(L.alert["%s"],SN[136210]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136210],L.alert["on"]),
				color1 = "GOLD",
				icon = ST[136210],
				sound = "ALERT13",
			},
			msgBlackBlood = {
				varname = format(L.alert["%s"],SN[137000]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[137000],L.alert["on"]),
				color1 = "MIDGREY",
				icon = ST[137000],
				sound = "ALERT13",
			},
			msgViscousHorror = {
				varname = format(L.alert["%s (2)"],SN["ej6969"]),
				type = "message",
				text = format(L.alert["%s (<ViscousHorror>)"],SN["ej6969"]),
				color1 = "MIDGREY",
				icon = EJST[6969],
				sound = "ALERT13",
			},
		},
		alerts = {
			-- Cds
			PrimordialStrikecd = {
				varname = format(L.alert["%s Cooldown"],SN[136037]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136037]),
				time = 24,
				time2 = 19,
				color1 = "NEWBLUE",
				icon = ST[136037],
			},
			CausticGascd = {
				varname = format(L.alert["%s Cooldown"],SN[136216]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136216]),
				time = 14,
				color1 = "NEWBLUE",
				icon = ST[136216],
			},
			PustuleEruptioncd = {
				varname = format(L.alert["%s Cooldown"],SN[136247]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136247]),
				time = 5,
				color1 = "NEWBLUE",
				icon = ST[136247],
				enabled = false,
			},
			VolatilePathogencd = {
				varname = format(L.alert["%s Cooldown"],SN[136228]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136228]),
				time = 27,
				color1 = "NEWBLUE",
				icon = ST[136228],
			},
			ViscousHorrorcd = {
				varname = format(L.alert["%s Cooldown"],SN["ej6969"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN["ej6969"]),
				time = 30,
				time2 = 11.5,
				color1 = "NEWBLUE",
				icon = EJST[6969],
			},
			-- Informs
			iViscousHorror = {
				varname = format(L.alert["%s (2)"],SN["ej6969"]),
				type = "inform",
				text = format(L.alert["%s (<ViscousHorror>)"],SN["ej6969"]),
				time = 2,
				color1 = "VIOLET",
				--sound = "ALERT11",
				icon = EJST[6969],
				exdps = true,
				exhealer = true,
			},		
			iCausticGas = {
				varname = format(L.alert["%s %s!"],L.alert["Incoming"],SN[136216]),
				type = "inform",
				text = format(L.alert["%s %s!"],L.alert["Incoming"],SN[136216]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT11",
				icon = ST[136216],
			},
			iPrimordialStrike = {
				varname = format(L.alert["%s, %s!"],SN[136037],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s, %s!"],SN[136037],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT14",
				icon = ST[136037],
				exdps = true,
			},
			iVolatilePathogen = {
				varname = format(L.alert["%s %s %s"],SN[136228],L.alert["on"],L.alert["YOU"]),
				type = "inform",
				text = format(L.alert["%s %s %s"],SN[136228],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT13",
				icon = ST[136228],
			},
			iWarnFullyMutated = {
				varname = format(L.alert["%s!"],SN[140546]),
				type = "inform",
				text = format(L.alert["%s!"],SN[140546]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = ST[140546],
			},
			iMutatedEnded = {
				varname = format(L.alert["%s %s!"],SN[140546],L.alert["Ended"]),
				type = "inform",
				text = format(L.alert["%s %s!"],SN[140546],L.alert["Ended"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = ST[140546],
			},
			iPositiveMutation = {
				varname = L.chat_ThroneOfThunder["Mutation Buffs"],
				type = "inform",
				text = format(L.alert["|T%s:24:24:-5|t(2) |T%s:24:24:-5|t(1)"],ST[136180],ST[136182]),
				text2 = "<Mutationtext>",		
				time = 2,
				color1 = "GREEN",
				sound = "ALERT9",
				--icon = ST[140546],
			},
			iNegativeMutation = {
				varname = L.chat_ThroneOfThunder["Mutation Debuffs"],
				type = "inform",
				text = format(L.alert["|T%s:24:24:-5|t(2) |T%s:24:24:-5|t(1)"],ST[136181],ST[136183]),
				text2 = "<Mutationtext>",		
				time = 2,
				color1 = "RED",
				sound = "ALERT8",
				--icon = ST[140546],
			},
			-- Warnings
	
			-- Casts
			CausticGascast = {
				varname = format(L.alert["%s %s!"],SN[136216],L.alert["Cast"]),
				type = "centerpopup",
				text = format(L.alert["%s %s!"],SN[136216],L.alert["Cast"]),
				time = 3,
				color1 = "RED",
				icon = ST[136216],
			},
			-- Debuffs
			MalformedDebuff = {
				varname = format(L.alert["%s Debuff"],SN[136050]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[136050]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[136050]),
				text3 = format(L.alert["#5#: %s (1)"],SN[136050]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[136050]),
				time = 20,
				color1 = "RED",
				icon = ST[136050],
				tag = "#5#",
				exdps = true,
			},
			FullyMutatedDebuff = {
				varname = format(L.alert["%s Debuff"],SN[140546]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[140546]),
				text2 = format(L.alert["#5#: %s"],SN[140546]),
				time = 120,
				color1 = "NEWBLUE",
				icon = ST[140546],
				tag = "#5#",
				ex25 = true,
			},
			BlackBloodDebuff = {
				varname = format(L.alert["%s Debuff"],SN[137000]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[137000]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[137000]),
				text3 = format(L.alert["#5#: %s (1)"],SN[137000]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[137000]),
				time = 60,
				color1 = "MIDGREY",
				icon = ST[137000],
				tag = "#5#",
				exdps = true,
			},
		},
		events = {
			{
				type = "event",
				event = "PLAYER_TARGET_CHANGED",
				execute = {
					{
						"expect",{"&bossid|target&","==","69070"}, -- big Ooze
						"set",{marker = "&bossid|target|true&"},
						"raidicon","bigoozeicon",
						--"debug",{"Ooze #2#"},
					},
				
				},
			},	
			{
			-- CausticGas
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 136216,
				execute = {
					{
						"message","msgCausticGas",
						"batchalert",{"CausticGascast","iCausticGas","CausticGascd"},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136215,
				execute = {
					{
						"quash","CausticGascd",
					},
				},
			},
			-- PrimordialStrike
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 136037,
				execute = { -- Need to check if PrimordialStrike timer is right or has modifications
					{
						"message","msgPrimordialStrike",
						"expect",{"&ismelee&","==","true"},
						"alert","iPrimordialStrike",
					},
					{
						"expect",{"<metabolicBoost>","==","1"},
						"alert",{"PrimordialStrikecd", time = 2},
					},
					{
						"expect",{"<metabolicBoost>","==","0"},
						"alert","PrimordialStrikecd",
					},
				},
			},
			---------------------
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					{
						"expect",{"#1#","==","boss1"},
						"expect",{"#2#","==",SN[136248]}, -- Pustule Eruption
						"alert","PustuleEruptioncd",
						-- Warnings ... too spammy
					},
				},
			},
			-- Malformed Blood
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136050,
				execute = {
					{
						"message","msgMalformed",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						--"quash","MalformedDebuff",
						"alert","MalformedDebuff",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						--"quash","MalformedDebuff",
						"alert",{"MalformedDebuff", text = 3},
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 136050,
				execute = {
					{
						"message",{"msgMalformed", text = 2},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						--"quash","MalformedDebuff",
						"alert",{"MalformedDebuff", text = 2},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						--"quash","MalformedDebuff",
						"alert",{"MalformedDebuff", text = 4},
					},
				},     
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136050,
				execute = {
					{
						"quash","MalformedDebuff",
					},
				},
			},
			-- EruptingPustules
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136246,
				execute = {
					{
						"message","msgEruptingPustules",
						"alert","PustuleEruptioncd",
						"set",{postules = 1},
					},
					{
						"expect",{"<acidSpines>","==","0"},
						"openwindow",{"5"},
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136246,
				execute = {
					{
						"quash","PustuleEruptioncd",
						"set",{postules = 0},
						--"closewindow",
					},
				},
			},
			-- PathogenGlands
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136225,
				execute = {
					{
						"message","msgPathogenGlands",
					},
				},
			}, 
			-- VolatilePathogen
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136228,
				execute = {
					{
						"message","msgVolatilePathogen",
						"alert","VolatilePathogencd",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","iVolatilePathogen",
						--"announce","VolatilePathogensay",
					},
				},
			}, 
			-- VolatilePathoge
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136225,
				execute = {
					{
						"quash","VolatilePathogencd",
					},
				},
			},	
			-- MetabolicBoost
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136245,
				execute = {
					{
						"message","msgMetabolicBoost",
						"set",{metabolicBoost = 1},
					},
				},
			}, 
			-- VentralSacs
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136210,
				execute = {
					{
						"message","msgVentralSacs",
					},
				},
			},
			-- acidSpiness
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 136218,
				execute = {
					{
						"set",{acidSpines = 1},
						"openwindow",{"5"},
					},
				},
			},
			-- Fully Mutated
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 140546,
				--dstisplayerunit = true,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","FullyMutatedDebuff",
						"schedulealert",{"iWarnFullyMutated",0.2},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						--"expect",{"&lfr&","==","false"}, --not lfr
						"alert",{"FullyMutatedDebuff", text = 2},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 140546,
				dstisplayerunit = true,
				execute = {
					{
						"quash","FullyMutatedDebuff",
						"alert","iMutatedEnded",
						"set",{TotalP = "0"},
					},
				},
			},	
			-- Metabolic Boost
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136245,
				execute = {
					{
						"set",{metabolicBoost = 0},
					},
				},
			},	
			-- acidSpines
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 136218,
				execute = {
					{
						"set",{acidSpines = 0},
					},
					{
						"expect",{"<postules>","==","1"},
						"openwindow",{"2"},
					},
					{
						"expect",{"<postules>","==","0"},
						"closewindow",
					},
				},
			},	
			-- BlackBlood
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137000,
				execute = {
					{
						"message","msgBlackBlood",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						--"quash","BlackBloodDebuff",
						"alert","BlackBloodDebuff",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						--"quash","BlackBloodDebuff",
						"alert",{"BlackBloodDebuff", text = 3},
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 137000,
				execute = {
					{
						"message",{"msgBlackBlood", text = 2},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						--"quash","BlackBloodDebuff",
						"alert",{"BlackBloodDebuff", text = 2},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						--"quash","BlackBloodDebuff",
						"alert",{"BlackBloodDebuff", text = 4},
					},
				},     
			},
			-- Mutations
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {136180, 136182, 136184, 136186},
				dstisplayerunit = true,
				execute = {
					{
						-- has to be schedule because the possibility of 2 in same time
						"scheduletimer",{"timerMutationsP",0.1},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {136180, 136182, 136184, 136186},
				dstisplayerunit = true,
				execute = {
					{
						"scheduletimer",{"timerMutationsP",0.1},
					},
				},     
			},
			--[[{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {136180, 136182, 136184, 136186},
				dstisplayerunit = true,
				execute = {
					{
						"scheduletimer",{"timerMutationsP",0.1},
					},
				},
			},--]]
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellid = {136181, 136183, 136185, 136187},
				dstisplayerunit = true,
				execute = {
					{
						"scheduletimer",{"timerMutationsN",0.1},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellid = {136181, 136183, 136185, 136187},
				dstisplayerunit = true,
				execute = {
					{
						"scheduletimer",{"timerMutationsN",0.1},
					},
				},     
			},
			--[[{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellid = {136181, 136183, 136185, 136187},
				dstisplayerunit = true,
				execute = {
					{
						"scheduletimer",{"timerMutationsN",0.1},
					},
				},
			},--]]
		},
	}

	DXE:RegisterEncounter(data)
end
