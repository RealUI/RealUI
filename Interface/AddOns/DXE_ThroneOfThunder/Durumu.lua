local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST
--TODO:

do
	local crimsonFog = EJ_GetSectionInfo(6892)
	local amberFog = EJ_GetSectionInfo(6895)
	local azureFog = EJ_GetSectionInfo(6898)

	local data = {
		version = 13,
		key = "Durumu the Forgotten",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Durumu the Forgotten"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-DURUMU.BLP:35:35",
		triggers = {
			scan = { 68036,	}, 
		},
		onactivate = {
			tracing = {	68036,	},
			tracerstart = true,
			combatstop = true,
			defeat = {	68036, 	},
			unittracing = {	"boss1", },
		},
		enrage = {
			time10n = 600,
			time25n = 600,
			time10h = 600,
			time25h = 600,
		},
		userdata = {
			redaddsleft = 3,
			lifedranjumps = 0,
			Lingeringunits = {type = "container", wipein = 3},
			Beamunits = {type = "container", wipein = 3},
			DarkParasiteunits = {type = "container", wipein = 3},
			redtarget = "no",
			bluetarget = "no",
			darkplaguedur = 0,
		},
		arrows = {
			ForceofWillarrow = {
				varname = SN[136413],
				unit = "#5#",
				persist = 5,
				action = "AWAY",
				msg = L.alert["MOVE AWAY!"],
				spell = SN[136413],
				range1 = 6,
				range2 = 13,
				range3 = 20,
			},
		},
		raidicons = {
			LifeDrainicon = {
				varname = SN[133798],
				type = "FRIENDLY",
				unit = "#5#",
				persist = 70,
				icon = 4,
			},
			Redicon = {
				varname = SN[139204],
				type = "FRIENDLY",
				unit = "<redtarget>",
				persist = 70,
				icon = 2,
			},
			Blueicon = {
				varname = SN[139202],
				type = "FRIENDLY",
				unit = "<bluetarget>",
				persist = 70,
				icon = 3,
			},
			Yellowicon = {
				varname = SN[133738],
				type = "FRIENDLY",
				unit = "#5#",
				persist = 10,
				icon = 8,
			},
			DarkParasiteicon = {
				varname = SN[133597],
				type = "MULTIFRIENDLY",
				persist = 30,
				unit = "#5#",
				reset = 3,
				icon = 5,
				total = 7,
			},
		},
		onstart = {
			{
				"alert",{"seriouswoundcd", time = 2},
				"alert",{"forceOfwillcd", time = 2},
				"alert",{"lightspectrumcd", time = 2},
				"alert",{"LingeringGazecd", time = 2},
			},
			{
				"expect",{"&difficulty&","==","0"}, --25lfr
				"alert",{"lifedraincd", time = 2},
				"alert",{"DisintegrationBeamcd", time = 3},
			},
			{
				"expect",{"&difficulty&",">","0"},
				"alert",{"DisintegrationBeamcd", time = 4},
			},
			{
				"expect",{"&difficulty&",">=","3"}, --10h&25h
				"alert",{"icewallcd", text = 3},
				"alert","darkparasitecd",
			},
		},
		timers = {	
			timerLingering = {
				{
					"message","msglingeringgaze",
				},
			},
			timerDarkParasite = {
				{
					"message","msgdarkparasite",
				},
			},
			timerBeanEndeds = {
				{
					"alert","forceOfwillcd",
					"alert",{"LingeringGazecd", time = 3},
				},
				{
					"expect",{"&difficulty&","==","0"}, --25lfr
					"alert",{"lightspectrumcd", time = 4},
					"alert",{"DisintegrationBeamcd", time = 2},
				},
				{
					"expect",{"&difficulty&",">","0"},
					"alert",{"lightspectrumcd", time = 3},
					"alert","DisintegrationBeamcd",
				},
				{
					"expect",{"&difficulty&",">=","3"}, --10h&25h
					"alert",{"icewallcd", text = 2},
					"alert","darkparasitecd",
				},
			},
			timerTargets = {
				{
					"expect",{"&difficulty&","<=","2"}, --normal
					"message",{"msgBeamTargets", text = 2},
				},
				{
					"expect",{"&difficulty&",">=","3"}, --10h&25h
					"message",{"msgBeamTargets", text = 3},
				},
			},
			timerBeam = {
				{
					"set",{beams = "&checkRaidDebuff|"..SN[139202].."|139202|<bluetarget>&"},
					"invoke",{
						{
							"expect",{"<bluetarget>","~=","<beams>"},
							"expect",{"<beams>","~=","0"},
							"set",{bluetarget = "<beams>"},
							"message",{"msgBlueBeam", text = 2},
							"raidicon","Blueicon",
							"invoke",{
								{
									"expect",{"<beams>","==","&playername&"},
									"alert","wbluebeam",
								},
							},
						},
					},
				},
				{
					"set",{beams = "&checkRaidDebuff|"..SN[139204].."|139204|<redtarget>&"},
					"invoke",{
						{
							"expect",{"<redtarget>","~=","<beams>"},
							"expect",{"<beams>","~=","0"},
							"set",{redtarget = "<beams>"},
							"message",{"msgRedBeam", text = 2},
							"raidicon","Redicon",
							"invoke",{
								{
									"expect",{"<beams>","==","&playername&"},
									"alert","wredbeam",
								},
							},
						},
					},
				},
			},
		},
		announces = { 
			forceofwillsay = {
				varname = format(L.alert["%s %s %s!"],SN[136413],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s!"],SN[136413],L.alert["on"],L.alert["Me"]),
				--enabled = false,
			},
			Lingeringsay = {
				varname = format(L.alert["%s %s %s!"],SN[134626],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s!"],SN[134626],L.alert["on"],L.alert["Me"]),
				--enabled = false,
			},
			lifedrainsay = {
				varname = format(L.alert["%s (2) %s %s!"],SN[133798],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s (#11#) %s %s!"],SN[133798],L.alert["on"],L.alert["Me"]),
				--enabled = false,
			},
		},
		messages = {
			msglingeringgaze = {
				varname = format(L.alert["%s"],SN[134626]),
				type = "message",
				text = format(L.alert["%s %s &list|Lingeringunits&"],SN[134626],L.alert["on"]),
				color1 = "NEWBLUE",
				icon = ST[134626],
				sound = "ALERT13",
			},
			msgBeamTargets = {
				varname = format(L.alert["%s"],L.chat_ThroneOfThunder["Beam targets:"]),
				type = "message",
				text = format(L.alert["%s |T%s:20:20:-5|t<player>  |T%s:20:20:-5|t<player>"],L.chat_ThroneOfThunder["Beam targets:"],ST[139202],ST[139204]),
				text2 = format(L.alert["%s |T%s:20:20:-5|t<bluetarget>  |T%s:20:20:-5|t<redtarget>"],L.chat_ThroneOfThunder["Beam targets:"],ST[139202],ST[139204]),
				text3 = format(L.alert["%s |T%s:20:20:-5|t<bluetarget>  |T%s:20:20:-5|t<redtarget>  |T%s:20:20:-5|t<yellowtarget>"],L.chat_ThroneOfThunder["Beam targets:"],ST[139202],ST[139204],ST[133738]),
				color1 = "TAN",
				icon = EJST[6891],
				sound = "ALERT13",
			},			
			msgBlueBeam = {
				varname = format(L.alert["%s"],SN[139202]),
				type = "message",
				text =  format(L.alert["%s %s #5#"],SN[139202],L.alert["on"]),
				text2 =  format(L.alert["%s %s <bluetarget>"],SN[139202],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[139202],
				sound = "ALERT13",
			},
			msgRedBeam = {
				varname = format(L.alert["%s"],SN[139204]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[139204],L.alert["on"]),
				text2 = format(L.alert["%s %s <redtarget>"],SN[139204],L.alert["on"]),
				color1 = "RED",
				icon = ST[139204],
				sound = "ALERT13",
			},
			--[[msgYellowBeam = {
				varname = format(L.alert["%s"],SN[133738]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[133738],L.alert["on"]),
				color1 = "GOLD",
				icon = ST[133738],
				sound = "ALERT13",
			},--]]
			msgLifeDrain = {
				varname = format(L.alert["%s"],SN[133798]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[133798],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (<lifedranjumps>)"],SN[133798],L.alert["on"]),
				color1 = "GREEN",
				icon = ST[133798],
				sound = "ALERT13",
				throttle = 2,
				exhealer = true,
			},
			msgseriouswound = {
				varname = format(L.alert["%s"],SN[133767]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[133767],L.alert["on"]),
				text2 = format(L.alert["%s %s #11# %s #5#"],SN[133767],L.alert["already at"],L.alert["on"]),
				color1 = "GREEN",
				icon = ST[133767],
				sound = "ALERT13",
				exdps = true,
			},
			msgforceofwill = {
				varname = format(L.alert["%s"],SN[136413]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[136413],L.alert["on"]),
				color1 = "RED",
				icon = ST[136413],
				sound = "ALERT13",
			},
			msgArterialCut = {
				varname = format(L.alert["%s"],SN[133768]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[133768],L.alert["on"]),
				color1 = "CYAN",
				icon = ST[133768],
				sound = "ALERT13",
				exhealer = true,
			},
			msgdarkparasite = {
				varname = format(L.alert["%s"],SN[133597]),
				type = "message",
				text = format(L.alert["%s %s &list|DarkParasiteunits&"],SN[133597],L.alert["on"]),
				color1 = "TEAL",
				icon = ST[133597],
				sound = "ALERT13",
				exdps = true,
				extank = true,
			},
			msgRedAddsLeft = {
				varname = format("2 %s %s",crimsonFog,L.alert["remaining"]),
				type = "message",
				text = format("<redaddsleft> %s %s",crimsonFog,L.alert["remaining"]),
				color1 = "RED",
				icon = ST[136154],
				sound = "ALERT13",
			},
		},
		alerts = {
			darkparasitecd = {
				varname = format(L.alert["%s Cooldown"],SN[133597]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[133597]),
				time = 60.5,
				color1 = "NEWBLUE",
				icon = ST[133597],
			},		
			obliteratecd = {
				varname = format(L.alert["%s Cooldown"],SN[137747]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137747]),
				time = 80,
				color1 = "NEWBLUE",
				icon = ST[137747],
			},
			icewallcd = {
				varname = format(L.alert["%s Cooldown"],SN[134587]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[134587]),
				time = 120,
				time2 = 35,
				time3 = 128,
				time4 = 87,
				color1 = "NEWBLUE",
				icon = ST[134587],
			},
			lifedraincd = {
				varname = format(L.alert["%s Cooldown"],SN[133795]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[133795]),
				time = 40,
				time2 = 151,
				time3 = 50,
				color1 = "NEWBLUE",
				icon = ST[133795],
			},
			seriouswoundcd = {
				varname = format(L.alert["%s Cooldown"],SN[133767]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[133767]),
				time = 12,
				time2 = 5, 
				color1 = "NEWBLUE",
				icon = ST[133767],
				--exdps= true,
			},
			forceOfwillcd = {
				varname = format(L.alert["%s Cooldown"],SN[136413]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[136413]),
				time = 20,
				time2 = 33.5,
				time3 = 15,
				color1 = "NEWBLUE",
				icon = ST[136413],
			},
			lightspectrumcd = {
				varname = format(L.alert["%s Cooldown"],SN["ej6891"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN["ej6891"]),
				time = 60,
				time2 = 40,
				time3 = 39,
				time4 = 56,
				color1 = "NEWBLUE",
				icon = EJST[6891],
			},
			DisintegrationBeamcd = {
				varname = format(L.alert["%s Cooldown"],SN["ej6882"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN["ej6882"]),
				time = 136,
				time2 = 177,
				time3 = 161,
				time4 = 135,
				color1 = "NEWBLUE",
				icon = EJST[6882],
			},	
			DisintegrationBeamdur = {
				varname = format(L.alert["%s %s"],SN["ej6882"],L.alert["Active"]),
				type = "centerpopup",
				text = format(L.alert["%s %s"],SN["ej6882"],L.alert["Active"]),
				time = 55,
				color1 = "NEWBLUE",
				icon = EJST[6882],
			},
			DisintegrationBeamwarn = {
				varname = format(L.alert["%s!"],SN["ej6882"]),
				type = "simple",
				text = format(L.alert["%s!"],SN["ej6882"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = EJST[6882],
			},	
			LingeringGazecd = {
				varname = format(L.alert["%s Cooldown"],SN[138467]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[138467]),
				time = 46,
				time2 = 15,
				time3 = 17,
				color1 = "NEWBLUE",
				icon = ST[138467],
			},	
			seriouswoundDebuff = {
				varname = format(L.alert["%s"],SN[133767]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[133767]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[133767]),
				text3 = format(L.alert["#5#: %s (1)"],SN[133767]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[133767]),
				time = 60,
				color1 = "NEWBLUE",
				icon = ST[133767],
				tag = "#5#",
			},	
			informseriouswound = {
				varname = format("%s: 2 %s!",SN[133767],L.alert["Stacks"]),
				type = "inform",
				text = format("%s: #11# %s!",SN[133767],L.alert["Stacks"]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT10",
				icon = ST[133767],
			},
			ArterialCutDebuff = {
				varname = format(L.alert["%s"],SN[133768]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[133768]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[133768]),
				text3 = format(L.alert["#5#: %s (1)"],SN[133768]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[133768]),
				time = 600,
				color1 = "RED",
				icon = ST[133768],
				tag = "#5#",
			},	
			iArterialCut = {
				varname = format("%s %s %s!",SN[133768],L.alert["on"],L.alert["player"]),
				type = "inform",
				text = format("%s %s #5#!",SN[133768],L.alert["on"]),
				time = 2,
				color1 = "RED",
				--sound = "ALERT14",
				icon = ST[133767],
				extank = true,
				exdps = true,
			},
			ilingeringgaze = {
				varname = format(L.alert["%s %s, %s!"],SN[138467],L.alert["under you"],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s %s, %s!"],SN[138467],L.alert["under you"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT10",
				icon = ST[138467],
				throttle = 2,
				flashscreen = true,
			},
			Lingeringwarn = {
				varname = format(L.alert["%s %s %s!"],SN[138467],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[138467],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT11",
				icon = ST[139204],
			},			
			wforceofwill = {
				varname = format(L.alert["%s!"],SN[136413]),
				type = "simple",
				text = format(L.alert["%s!"],SN[136413]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT11",
				icon = ST[136413],
			},
			wforceofwillnear = {
				varname = format("%s %s %s!",SN[136413],L.alert["Near"],L.alert["YOU"]),
				type = "simple",
				text = format("%s %s %s!",SN[136413],L.alert["Near"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				flashscreen = true,
				sound = "ALERT12",
				icon = ST[136413],
			},
			informlifedrain = {
				varname = format("%s %s %s!",SN[133795],L.alert["on"],L.alert["player"]),
				type = "inform",
				text = format("%s %s #5#!",SN[133795],L.alert["on"]),
				time = 2,
				color1 = "GREEN",
				sound = "ALERT10",
				icon = ST[133795],
				extank = true,
				exdps = true,
			},
			lifedrainDebuff = {
				varname = format(L.alert["%s"],SN[133795]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[133795]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[133795]),
				text3 = format(L.alert["#5#: %s (1)"],SN[133795]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[133795]),
				time = 15,
				color1 = "GREEN",
				icon = ST[133795],
				ex25 = true,
			},	
			wbluebeam = {
				varname = format(L.alert["%s %s %s!"],SN[139202],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[139202],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT11",
				icon = ST[139202],
			},
			wredbeam = {
				varname = format(L.alert["%s %s %s!"],SN[139204],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[139204],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = ST[139204],
			},
			wyellowbeam = {
				varname = format(L.alert["%s %s %s!"],SN[133738],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[133738],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "YELLOW",
				sound = "ALERT11",
				icon = ST[133738],
			},
			weyesore = {
				varname = format(L.alert["%s %s, %s!"],SN[140502],L.alert["under you"],L.alert["MOVE AWAY"]),
				type = "simple",
				text = format(L.alert["%s %s, %s!"],SN[140502],L.alert["under you"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT11",
				icon = ST[140502],
				throttle = 2,
			},
			DarkParasiteDebuff = {
				varname = format(L.alert["%s Debuff"],SN[133597]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[133597]),
				text2 = format(L.alert["#5#: %s"],SN[133597]),
				time = 30,
				color1 = "NEWBLUE",
				icon = ST[133597],
				tag = "#5#",
				exdps = true,
				extank = true,
			},
			wDarkParasite = {
				varname = format("%s %s %s!",SN[133597],L.alert["Dispell"],L.alert["player"]),
				type = "inform",
				text = format(L.alert["%s #5#"],L.alert["Dispell"]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT10",
				icon = ST[133597],
			},
			DarkPlagueCenter = {
				varname = format(L.alert["%s %s"],SN[133598],L.alert["Active"]),
				type = "centerpopup",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[133598]),
				text2 = format(L.alert["#5#: %s"],SN[133598]),
				time = 30,
				time2 = "<darkplaguedur>",
				color1 = "RED",
				icon = ST[133598],
			},
			wDarkPlague = {
				varname = format(L.alert["%s %s! %s %s!"],SN[133597],L.alert["Dispelled"],L.alert["Incoming"],L.alert["adds"]),
				type = "simple",
				text = format(L.alert["%s %s! %s %s!"],SN[133597],L.alert["Dispelled"],L.alert["Incoming"],L.alert["adds"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT16",
				icon = ST[133597],
			},
			wIceWall = {
				varname = format(L.alert["%s!"],SN[134587]),
				type = "simple",
				text = format(L.alert["%s!"],SN[134587]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT11",
				icon = ST[134587],
				throttle = 2,
			},
			iredaddspawn = {
				varname = format("%s %s!",crimsonFog,L.alert["Found"]),
				type = "inform",
				text =  format("%s %s!",crimsonFog,L.alert["Found"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT14",
				icon = ST[136154],
			},
			iblueaddspawn = {
				varname =  format("%s %s!",azureFog,L.alert["Found"]),
				type = "inform",
				text =  format("%s %s!",azureFog,L.alert["Found"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT11",
				icon = ST[136177],
			},
			iyellowaddspawn = {
				varname =  format("%s %s!",amberFog,L.alert["Found"]),
				type = "inform",
				text =  format("%s %s!",amberFog,L.alert["Found"]),
				time = 2,
				color1 = "YELLOW",
				sound = "ALERT10",
				icon = ST[136175],
			},
			iredaddsleft = {
				varname = format("2 %s %s",crimsonFog,L.alert["remaining"]),
				type = "inform",
				text = format("<redaddsleft> %s %s",crimsonFog,L.alert["remaining"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT15",
				icon = ST[136154],
			},
		},
		events = {
			-- ArterialCut
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 133768,
				execute = {
					{
						"message","msgArterialCut",
						"alert","iArterialCut",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","ArterialCutDebuff",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"ArterialCutDebuff", text = 3},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 133768,
				execute = {
					{
						"message",{"msgArterialCut", text = 2},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert",{"ArterialCutDebuff", text = 2},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"ArterialCutDebuff", text = 4},
					},
				},
			},		
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 133768,
				execute = {
					{
						"quash","ArterialCutDebuff",
					},
				},
			},
			-- seriouswound
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 133767,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						--"quash","seriouswoundDebuff",
						"alert","seriouswoundDebuff",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						--"quash","seriouswoundDebuff",
						"alert",{"seriouswoundDebuff", text = 3},
						"message","msgseriouswound",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 133767,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						--"quash","seriouswoundDebuff",
						"alert",{"seriouswoundDebuff", text = 2},
						"expect",{"#11#",">=","4"},
						"alert","informseriouswound",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						--"quash","seriouswoundDebuff",
						"alert",{"seriouswoundDebuff", text = 4},
						"expect",{"#11#",">=","5"},
						"message",{"msgseriouswound", text = 2},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 133767,
				execute = {
					{
						"quash","seriouswoundDebuff",
					},
				},
			},
			-- serious wound
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 133765,
				execute = {
					{
						"alert","seriouswoundcd",
					},
				},
			},
			-- Lingering Gaze
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 138467,
				execute = {
					{
						"alert","LingeringGazecd",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 134044,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","ilingeringgaze",
					},
				},
			},
			--[[{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				execute = {
					{
						"expect",{"#5#","==",amberFog},
						"alert","iyellowaddspawn",
					},
				},
			},--]]			
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 134626,
				execute = {
					{
						"insert",{"Lingeringunits","#5#"},
						"canceltimer","timerLingering",
						"scheduletimer",{"timerLingering",1},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","Lingeringwarn",
						"announce","Lingeringsay",
					},
				},
			},
			-- IceWall
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = 134587,
				execute = {
					{
						"alert","wIceWall",
					},
				},
			},
			-- Life Drain
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {133795,},
				execute = {
					{
						"set",{lifedranjumps = "INCR|1"},
					},
					{
						"expect",{"<lifedranjumps>","==","1"},
						"alert",{"lifedraincd", time = 3},
					},
					{
						"expect",{"<lifedranjumps>","~=","1"},
						"alert","lifedraincd",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","lifedrainDebuff",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"lifedrainDebuff", text = 3},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 133798,
				execute = {
					{	
						"message",{"msgLifeDrain", text = 2},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"announce","lifedrainsay",
						"alert",{"lifedrainDebuff", text = 2},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"alert",{"lifedrainDebuff", text = 4},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137727,
				execute = {
					{
						"raidicon","LifeDrainicon",
						"message","msgLifeDrain",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 137727,
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			},
			-- blue
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {134122,},
				execute = {
					{
						"set",{bluetarget = "#5#"},
						--"message","msgBlueBeam",
						"raidicon","Blueicon",
						"alert","LingeringGazecd",
						"canceltimer","timerTargets",
						"scheduletimer",{"timerTargets",0.6},	
						"quash","forceOfwillcd",						
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","wbluebeam",
					},
				},
			},
			-- red
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {134123,},
				execute = {
					{
						"set",{redtarget = "#5#"},	
						--"set",{redaddsleft = 3},
						--"message","msgRedBeam",
						"raidicon","Redicon",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","wredbeam",
					},
				},
			},
			-- yellow
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {134124,},
				execute = {
					{
						"quash","forceOfwillcd",
						"set",{yellowtarget = "#5#"},
						"set",{redaddsleft = 3},
						"raidicon","Yellowicon",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","wyellowbeam",
					},
					{
						"expect",{"&difficulty&",">=","3"}, --10h&25h
						"alert","obliteratecd",
					},
				},
			},
			-- force of will
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {136932,},
				execute = {
					{
						"message","msgforceofwill",	
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","wforceofwill",
						"announce","forceofwillsay",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"expect",{"&inrange|#5#&","<","26"},
						"alert","wforceofwillnear",
						"arrow","ForceofWillarrow",
					},
					{
						"expect",{"&timeleft|lightspectrumcd|0&",">","22"},
						"alert","forceOfwillcd",
					},
					{
						"expect",{"&timeleft|DisintegrationBeamcd|0&",">","108"},
						"alert","forceOfwillcd",
					},
				},
			},
			-- Emotes
		--[[	{
				type = "event",
				event = "MONSTER_EMOTE", 
				execute = {
				    --red	
					{
						"expect",{"#1#","find","spell:134123"}, 
						"set",{redaddsleft = 3},
						"message","msgRedBeam",
						"raidicon","Redicon",
						"set",{redtarget = "#5#"},	
						"invoke",{
							{
								"expect",{"#5#","==","&playername&"},
								--"announce","chargesay",
								"alert","wredbeam",
							},
						},
					},
				},
			},--]]
			--[[{
				type = "event",
				event = "MONSTER_EMOTE", 
				execute = {
					--blue
					{
						"expect",{"#1#","find","spell:134122"}, 
						"message","msgBlueBeam",
						"quash","forceOfwillcd",
						"raidicon","Blueicon",
						"alert","LingeringGazecd",
						"set",{bluetarget = "#5#"},
						"invoke",{
							{
								"expect",{"#5#","==","&playername&"},
								--"announce","chargesay",
								"alert","wbluebeam",
							},
						},
					},
				    --red	
					{
						"expect",{"#1#","find","spell:134123"}, 
						"set",{redaddsleft = 3},
						"message","msgRedBeam",
						"raidicon","Redicon",
						"set",{redtarget = "#5#"},	
						"invoke",{
							{
								"expect",{"#5#","==","&playername&"},
								--"announce","chargesay",
								"alert","wredbeam",
							},
						},
					},
				    --yellow
					{
						"expect",{"#1#","find","spell:134124"},
						"quash","forceOfwillcd",
						"set",{redaddsleft = 3},
						"invoke",{
							{
								"expect",{"&difficulty&",">=","3"}, --10h&25h
								"invoke",{
									{
										"message","msgYellowBeam",
										"raidicon","Yellowicon",
										"alert","obliteratecd",
									},
									{
										"expect",{"#5#","==","&playername&"},
										"alert", "wyellowbeam",
									},
								},
							},
							{
								"expect",{"&difficulty&","==","0"}, --LFR
								"invoke",{
									{
										"message","msgYellowBeam",
										"raidicon","Yellowicon",
										"alert","obliteratecd",
									},
									{
										"expect",{"#5#","==","&playername&"},
										"alert", "wyellowbeam",
									},
								},
							},
						},
					},
				},
			},--]]
			{
				type = "event",
				event = "MONSTER_EMOTE", 
				execute = {
					-- Disintegration Beam Precast
					{
						"expect",{"#1#","find","spell:134169"}, 
						"batchquash",{"LingeringGazecd","lifedraincd","forceOfwillcd","darkparasitecd"},
						"batchalert",{"DisintegrationBeamcd","DisintegrationBeamdur","DisintegrationBeamwarn"},
						"scheduletimer",{"timerBeanEndeds",55},
					},
				    -- Life Drain
					{
						"expect",{"#1#","find","spell:133795"}, 
						"message","msgLifeDrain",
						"raidicon","LifeDrainicon",
						"alert","informlifedrain",
					},
					-- Red Spawn
					{
						--"expect",{"#1#","find",L.chat_ThroneOfThunder["(The Infrared Light reveals a Crimson Fog!)"]},
						--"debug",{"#1#"},
						"expect",{"#2#","==",crimsonFog},
						"alert","iredaddspawn",
					},
					-- Blue Spawn
					{
						--"expect",{"#1#","find",L.chat_ThroneOfThunder["(The Blue Rays reveal an Azure Eye!)"]},
						--"expect",{"#1#","find","("..azureFog..")"},
						"expect",{"#2#","==",azureFog},
						"alert","iblueaddspawn",
					},
					-- Yellow Spawn
					{
						--"expect",{"#1#","find","("..amberFog..")"},
						"expect",{"#2#","==",amberFog},
						"alert","iyellowaddspawn",
					},
				},
			},
	--[[		{
				type = "event",
				event = "MONSTER_EMOTE", 
				execute = {
					-- Force of Will
					{
						"expect",{"#1#","find","spell:136932"}, 
						"message","msgforceofwill",
						"invoke",{
							{
								"expect",{"#5#","==","&playername&"},
								"alert","wforceofwill",
								"announce","forceofwillsay",
							},
							{
								"expect",{"#5#","~=","&playername&"},
								"expect",{"&inrange|#5#&","<","20"},
								"alert","wforceofwillnear",
								"arrow","ForceofWillarrow",
							},
							{
								"expect",{"&timeleft|lightspectrumcd|0&",">","22"},
								"alert","forceOfwillcd",
							},
							{
								"expect",{"&timeleft|DisintegrationBeamcd|0&",">","108"},
								"alert","forceOfwillcd",
							},
						},
					},
				},
			},--]]
			-- 
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					-- Crimson Fogs
					{
						"expect",{"&npcid|#4#&","==","69050"},
						"set",{redaddsleft = "DECR|1"},
						"invoke", {
							{
								"expect",{"<redaddsleft>",">=","1"},
								"alert","iredaddsleft",
								"message","msgRedAddsLeft",
							},
							{
								"expect",{"<redaddsleft>","==","0"},
								"quash","obliteratecd",
								"alert","iredaddsdead",
								"alert",{"forceOfwillcd", time = 3},
								"invoke", {
									{
										"expect",{"<redtarget>","~=","no"},
										"removeraidicon","<redtarget>",
										"set",{redtarget = "no"},
										"set",{bluetarget = "no"},
									},
								},
							},
						},
					},
					-- AmberFog &  Azure Fog
					{
						"expect",{"&difficulty&","==","0"}, --25lfr
						"invoke", {
							{
								"expect",{"&npcid|#4#&","==","69051"},
								"set",{redaddsleft = "DECR|1"},
								"invoke", {
									{
										"expect",{"<redaddsleft>",">=","1"},
										"alert","iredaddsleft",
										"message","msgRedAddsLeft",
									},
									{
										"expect",{"<redaddsleft>","==","0"},
										"quash","obliteratecd",
										"alert","iredaddsdead",
										"alert",{"forceOfwillcd", time = 3},
										"invoke", {
											{
												"expect",{"<redtarget>","~=","no"},
												"removeraidicon","<redtarget>",
												"set",{redtarget = "no"},
												"set",{bluetarget = "no"},
											},
										},
									},
								},
							},
							{
								"expect",{"&npcid|#4#&","==","69052"},
								"set",{redaddsleft = "DECR|1"},
								"invoke", {
									{
										"expect",{"<redaddsleft>",">=","1"},
										"alert","iredaddsleft",
										"message","msgRedAddsLeft",
									},
									{
										"expect",{"<redaddsleft>","==","0"},
										"quash","obliteratecd",
										"alert","iredaddsdead",
										"alert",{"forceOfwillcd", time = 3},
										"invoke", {
											{
												"expect",{"<redtarget>","~=","no"},
												"removeraidicon","<redtarget>",
												"set",{redtarget = "no"},
												"set",{bluetarget = "no"},
											},
										},
									},
								},
							},
						},
					},
				},
			},
		    -- Eye Sore
			{
				type = "combatevent",
				eventtype = "SPELL_PERIODIC_DAMAGE",
				spellid = 134755,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","weyesore"
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_PERIODIC_MISSED",
				spellid = 134755,
				execute = {
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","weyesore"
					},
				},
			},			
			-- Dark Parasite (Heroic)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 133597,
				execute = {
					{
						"expect",{"&unitisplayer|#5#&","==","true"},
						"invoke",{
							{	
								"insert",{"DarkParasiteunits","#5#"},
								"canceltimer","timerDarkParasite",
								"scheduletimer",{"timerDarkParasite",0.5},
								"raidicon","DarkParasiteicon",
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"quash","DarkParasiteDebuff",
								"alert","DarkParasiteDebuff",
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"quash","DarkParasiteDebuff",
								"alert",{"DarkParasiteDebuff", text = 2},
							},
							{
								"expect",{"&dispell|magic&","==","true"},
								"alert","wDarkParasite",
							},
						},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 133597,
				execute = {
					{	
						"removeraidicon","#5#",
					},
				},
			},
			-- Dark Plague (Heroic)
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 133598,
				execute = {
					{	
						"alert","wDarkPlague",
						"set",{darkplaguedur = "&timeleft|DarkParasiteDebuff|0&"},
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","DarkParasiteDebuff",
						"alert",{"DarkPlagueCenter", time = 2},
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","DarkParasiteDebuff",
						"alert",{"DarkPlagueCenter", text = 2, time = 2},
					},
				},
			},
			-- Beam jumps
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellid = {139202, 139204},
				execute = {
					{
						"scheduletimer",{"timerBeam",0.1},
					},
				},
			},			
			-------------------------------- 
			--[[{
                type = "event",
                event = "UNIT_AURA",
                execute = {
                    {
						"expect",{"&targetdebuff|#1#|"..SN[139202].."&","==","true"},
						"expect",{"<bluetarget>","~=","#1#"},
						"invoke",{
							{
								--"expect",{"<bluetarget>","~=","&targetname|#1#&"},
								"set",{bluetarget = "#1#"},
								"message",{"msgBlueBeam", text = 2},
								"raidicon","Blueicon",
							},
							{
								"expect",{"#1#","==","player"},
								"alert","wbluebeam",
							},
						},
                    },
                    {
						"expect",{"&targetdebuff|#1#|"..SN[139204].."&","==","true"},
						"expect",{"<redtarget>","~=","#1#"},
						"invoke",{
							{
								--"expect",{"<redtarget>","~=","&targetname|#1#&"},
								"set",{redtarget = "#1#"},
								"message",{"msgRedBeam", text = 2},
								"raidicon","Redicon",
							},
							{
								"expect",{"#1#","==","player"},
								"alert","wredbeam",
							},
						},
                    },
                },
            },--]]
		},
	}

	DXE:RegisterEncounter(data)
end
