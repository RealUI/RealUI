local L,SN,ST,EJSN,EJST = DXE.L,DXE.SN,DXE.ST,DXE.EJSN,DXE.EJST
--TODO:
do
	local data = {
		version = 7,
		key = "Megaera",
		zone = L.zone["Throne of Thunder"],
		category = L.zone["Throne of Thunder"],
		name = L.npc_ThroneOfThunder["Megaera"],
		icon = "INTERFACE\\ENCOUNTERJOURNAL\\UI-EJ-BOSS-MEGAERA.BLP:35:35",
		triggers = {
			scan = { 70235,70247 }, -- Frozen Head, Venomous Head
		},
		onactivate = {
			tracing = { 70235,70247 },
			tracerstart = true,
			combatstop = true,
			defeat = { 68065 },
			unittracing = {	"boss1","boss2","boss3","boss4","boss5",},
		},
		enrage = {
			time10n = 600,
			time25n = 600,
			time10h = 600,
			time25h = 600,
		},
		windows = {
			proxwindow = true,
		},
		arrows = {
			Torrentarrow = {
				varname = SN[139857],
				unit = "#1#",
				persist = 5,
				action = "AWAY",
				msg = L.alert["MOVE AWAY!"],
				spell = SN[139857],
				range1 = 5,
				range2 = 9,
				range3 = 10,
			},
		},
		raidicons = {
			Cindericon = {
				varname = SN[139822],
				type = "FRIENDLY",
				persist = 30,
				unit = "#5#",
				icon = 1,
			},
			Torrenticon = {
				varname = SN[139857],
				type = "FRIENDLY",
				persist = 12,
				unit = "#1#",
				icon = 2,
			},
		},
		userdata = {
			fireInFront = 0,
			venomInFront = 0,
			iceInFront = 0,
			arcaneInFront = 0,
			fireBehind = 1,
			venomBehind = 0,
			iceBehind = 0,
			arcaneBehind = 1,
			rampageCast = 0,
			Rampage = 0,
			expires = 0,
			activetorrent = {type="container"},
		},
		onstart = {
			{
			--	"alert",{"Cindercd", time = 2},
				"alert",{"Breathcd", time = 2},
				"tracing",{70235,70247,"boss1"}, -- Frozen and Venomous
			},
			{
				"expect",{"&difficulty&",">=","3"}, --10h&25h
				"alert","Nethercd",
				"alert",{"Cindercd", time = 3},
			},
			{
				"expect",{"&difficulty&","==","0"}, --10h&25h
				"alert",{"Cindercd", time = 4},
			},
		},
		timers = {
			timerTorrent = {
				{
					"set",{expires = 0},
					--tabupdate",{"activetorrent","#1#","false"},
				},
			},
			timerCheckHeads = {
				{
					"expect",{"&unitexist|boss2& &unitexist|boss3&","==","0 0"},
					"scheduletimer",{"timerCheckHeads",1},
				},
				{
					"expect",{"&unitexist|boss2& &unitexist|boss3&","==","1 0"},
					"scheduletimer",{"timerCheckHeads",1},
				},
				{
					"expect",{"&unitexist|boss2& &unitexist|boss3&","==","0 1"},
					"scheduletimer",{"timerCheckHeads",1},
				},
				{
					"expect",{"&unitexist|boss2&","==","1"},
					"expect",{"&unitexist|boss3&","==","1"},
					"invoke",{
						{
							"expect",{"&bossid|boss2&","==","70212"},  -- Flaming
							"set",{fireInFront = "INCR|1"},
							"invoke",{
								"expect",{"<fireBehind>",">","0"},
								"set",{fireBehind = "DECR|1"},
							},
						},
						{
							"expect",{"&bossid|boss3&","==","70212"},  -- Flaming
							"set",{fireInFront = "INCR|1"},
							"invoke",{
								"expect",{"<fireBehind>",">","0"},
								"set",{fireBehind = "DECR|1"},
							},
						},
						{
							"expect",{"&bossid|boss2&","==","70235"},  -- Frozen
							"set",{iceInFront = "INCR|1"},
							"invoke",{
								"expect",{"<iceBehind>",">","0"},
								"set",{iceBehind = "DECR|1"},
							},
						},
						{
							"expect",{"&bossid|boss3&","==","70235"},  -- Frozen
							"set",{iceInFront = "INCR|1"},
							"invoke",{
								"expect",{"<iceBehind>",">","0"},
								"set",{iceBehind = "DECR|1"},
							},
						},
						{
							"expect",{"&bossid|boss2&","==","70247"},  -- Venomous
							"set",{venomInFront = "INCR|1"},
							"invoke",{
								"expect",{"<venomBehind>",">","0"},
								"set",{venomBehind = "DECR|1"},
							},
						},
						{
							"expect",{"&bossid|boss3&","==","70247"},  -- Venomous
							"set",{venomInFront = "INCR|1"},
							"invoke",{
								"expect",{"<venomBehind>",">","0"},
								"set",{venomBehind = "DECR|1"},
							},
						},
						{
							"expect",{"&bossid|boss2&","==","70248"},  -- Arcane
							"set",{arcaneInFront = "INCR|1"},
							"invoke",{
								"expect",{"<arcaneBehind>",">","0"},
								"set",{arcaneBehind = "DECR|1"},
							},
						},
						{
							"expect",{"&bossid|boss3&","==","70248"},  -- Arcane
							"set",{arcaneInFront = "INCR|1"},
							"invoke",{
								"expect",{"<arcaneBehind>",">","0"},
								"set",{arcaneBehind = "DECR|1"},
							},
						},
						{ 
							"expect",{"<iceInFront> <fireInFront>","==","1 1"},
							"tracing",{70235,70212,"boss1"}, --68065
						},
						{ 
							"expect",{"<iceInFront> <venomInFront>","==","1 1"},
							"tracing",{70235,70247,"boss1"},
						},
						{ 
							"expect",{"<iceInFront> <arcaneInFront>","==","1 1"},
							"tracing",{70235,70248,"boss1"},
						},
						{ 
							"expect",{"<venomInFront> <fireInFront>","==","1 1"},
							"tracing",{70247,70212,"boss1"},
						},
						{ 
							"expect",{"<venomInFront> <arcaneInFront>","==","1 1"},
							"tracing",{70247,70248,"boss1"},
						},
						{ 
							"expect",{"<arcaneInFront> <fireInFront>","==","1 1"},
							"tracing",{70248,70212,"boss1"},
						},
					},
				},
			},
		},
		announces = {
			Cindersay = {
				varname = format(L.alert["%s %s %s!"],SN[139822],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s!"],SN[139822],L.alert["on"],L.alert["Me"]),
				--enabled = false,
			},
			Torrentsay = {
				varname = format(L.alert["%s %s %s!"],SN[139866],L.alert["on"],L.alert["Me"]),
				type = "SAY",
				msg = format(L.alert["%s %s %s!"],SN[139866],L.alert["on"],L.alert["Me"]),
			},
		},
		messages = { 
			msgArcticFreeze = {
				varname = format(L.alert["%s (1)"],SN[139843],L.alert["on"]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[139843],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[139843],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[139843],
				sound = "ALERT13",
				exdps = true,
			},
			msgIgniteFlesh = {
				varname = format(L.alert["%s (1)"],SN[137731],L.alert["on"]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[137731],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[137731],L.alert["on"]),
				color1 = "RED",
				icon = ST[137731],
				sound = "ALERT13",
				exdps = true,
			},
			msgRotArmor = {
				varname = format(L.alert["%s (1)"],SN[139840],L.alert["on"]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[139840],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[139840],L.alert["on"]),
				color1 = "GREEN",
				icon = ST[139840],
				sound = "ALERT13",
				exdps = true,
			},
			msgCinder = {
				varname = format(L.alert["%s"],SN[139822],L.alert["on"]),
				type = "message",
				text = format(L.alert["%s %s #5#"],SN[139822],L.alert["on"]),
				color1 = "DCYAN",
				icon = ST[139822],
				sound = "ALERT13",
				--exdps = true,
			},
			msgTorrentofIce = {
				varname = format(L.alert["%s %s %s"],SN[139866],L.alert["on"],L.alert["player"]),
				type = "message",
				text = format(L.alert["%s %s &targetname|#1#&"],SN[139866],L.alert["on"]),
				color1 = "INDIGO",
				icon = ST[139866],
				sound = "ALERT13",
			},
			msgRampage = {
				varname = format(L.alert["%s! (2)"],SN[139458]),
				type = "message",
				text = format(L.alert["%s! (<Rampage>)"],SN[139458]),
				color1 = "RED",
				icon = ST[139458],
				sound = "ALERT13",
			},
			msgRampageSoon = {
				varname = format(L.alert["%s %s (2) %s!"],SN[139458],L.alert["soon"],L.alert["Stack"]),
				type = "message",
				text = format(L.alert["%s %s (<Rampage>) %s!"],SN[139458],L.alert["soon"],L.alert["Stack"]),
				color1 = "ORANGE",
				icon = ST[139458],
				sound = "ALERT13",
			},
			msgRampageOver = {
				varname = format(L.alert["%s (2) %s"],SN[139458],L.alert["over"]),
				type = "message",
				text = format(L.alert["%s (<Rampage>) %s"],SN[139458],L.alert["over"]),
				color1 = "GREEN",
				icon = ST[139458],
				sound = "ALERT13",
			},	
			msgNetherTear = {
				varname = format(L.chat_ThroneOfThunder["Arcane Adds Spawnning!"]),
				type = "message",
				text = format(L.chat_ThroneOfThunder["Arcane Adds Spawnning!"]),
				color1 = "VIOLET",
				icon = ST[140138],
				sound = "ALERT13",
			},
			msgArcaneDiffusion = {
				varname = format(L.alert["%s (1)"],SN[139993],L.alert["on"]),
				type = "message",
				text = format(L.alert["%s %s #5# (1)"],SN[139993],L.alert["on"]),
				text2 = format(L.alert["%s %s #5# (#11#)"],SN[139993],L.alert["on"]),
				color1 = "PURPLE",
				icon = ST[139993],
				sound = "ALERT13",
				exdps = true,
			},
		},
		alerts = {
			Breathcd = {
				varname = format(L.alert["%s Cooldown"],L.chat_ThroneOfThunder["Breath"]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],L.chat_ThroneOfThunder["Breath"]),
				time = 17,
				time2 = 5,
				time3 = 13,
				color1 = "NEWBLUE",
				icon = ST[105050],
				throttle = 6,
			},
			ArcticFreezeDebuff = {
				varname = format(L.alert["%s Debuff"],SN[139843]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[139843]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[139843]),
				text3 = format(L.alert["#5#: %s (1)"],SN[139843]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[139843]),
				time = 45,
				color1 = "NEWBLUE",
				icon = ST[139843],
				tag = "#5#",
				exdps = true,
			},
			iArcticFreeze = {
				varname = format(L.alert["%s %s 2 %s"],SN[139843],L.alert["already at"],L.alert["Stacks"]),
				type = "inform",
				text = format(L.alert["%s %s #11# %s"],SN[139843],L.alert["already at"],L.alert["Stacks"]),
				time = 2,
				color1 = "NEWBLUE",
				sound = "ALERT10",
				icon = ST[139843],
			},
			ArcticFreezecd = {
				varname = format(L.alert["%s Cooldown"],SN[139843]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[139843]),
				time = 17,
				time2 = 10,
				color1 = "NEWBLUE",
				icon = ST[139843],
				exdps = true,
			},
			IgniteFleshDebuff = {
				varname = format(L.alert["%s Debuff"],SN[137731]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[137731]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[137731]),
				text3 = format(L.alert["#5#: %s (1)"],SN[137731]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[137731]),
				time = 45,
				color1 = "RED",
				icon = ST[137731],
				tag = "#5#",
				exdps = true,
			},
			iIgniteFlesh = {
				varname = format(L.alert["%s %s 2 %s"],SN[137731],L.alert["already at"],L.alert["Stacks"]),
				type = "simple",
				text = format(L.alert["%s %s #11# %s"],SN[137731],L.alert["already at"],L.alert["Stacks"]),
				--text2 = format(L.alert["%s %s %s!"],SN[137731],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT2",
				icon = ST[137731],
			},
			IgniteFleshcd = {
				varname = format(L.alert["%s Cooldown"],SN[137731]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[137731]),
				time = 17,
				time2 = 10,
				color1 = "RED",
				icon = ST[137731],
				exdps = true,
			},
			RotArmorDebuff = {
				varname = format(L.alert["%s Debuff"],SN[139840]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[139840]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[139840]),
				text3 = format(L.alert["#5#: %s (1)"],SN[139840]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[139840]),
				time = 45,
				color1 = "GREEN",
				icon = ST[139840],
				tag = "#5#",
				exdps = true,
			},
			iRotArmor = {
				varname = format(L.alert["%s %s 2 %s"],SN[139840],L.alert["already at"],L.alert["Stacks"]),
				type = "simple",
				text = format(L.alert["%s %s 2 %s"],SN[139840],L.alert["already at"],L.alert["Stacks"]),
				time = 2,
				color1 = "GREEN",
				sound = "ALERT2",
				icon = ST[139840],
			},
			RotArmorcd = {
				varname = format(L.alert["%s Cooldown"],SN[139840]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[139840]),
				time = 17,
				time2 = 10,
				color1 = "GREEN",
				icon = ST[139840],
				exdps = true,
			},
			Cindercd = {
				varname = format(L.alert["%s Cooldown"],SN[139822]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[139822]),
				time = 25,
				time2 = 42,
				time3 = 12,
				time4 = 58,
				time5 = 5,
				color1 = "RED",
				icon = ST[139822],
				exdps = true,
			},
			iCinder = {
				varname = format(L.alert["%s %s %s!"],SN[139822],L.alert["on"],L.alert["YOU"]),
				type = "inform",
				text = format(L.alert["%s %s %s!"],SN[139822],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "DCYAN",
				sound = "ALERT1",
				icon = ST[139822],
				flashscreen = true,
			},
			iDispellCinder = {
				varname = format(L.alert["%s %s!"],SN[139822],L.alert["Dispell"]),
				type = "inform",
				text = format(L.alert["%s #5#!"],L.alert["Dispell"]),
				time = 2,
				color1 = "VIOLET",
				--sound = "ALERT10",
				icon = ST[139822],
			},
			iCinderOut = {
				varname = format(L.alert["%s %s, %s!"],SN[139822],L.alert["under you"],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s %s, %s!"],SN[139822],L.alert["under you"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[139822],
				throttle = 2,
				flashscreen = true,
			},
			--[[wCinder = {
				varname = format("%s %s %s!",SN[139822],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format("%s %s %s!",SN[139822],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT10",
				icon = ST[139822],
				flashscreen = true,
			},---]]
			iBreathOut = {
				varname = format(L.alert["%s: %s!"],SN[105050],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s: %s!"],SN[105050],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "PURPLE",
				sound = "ALERT10",
				icon = ST[105050],
				flashscreen = true,
			},
			wBreath = {
				varname = format(L.alert["%s %s %s!"],SN[105050],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[105050],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "RED",
				sound = "ALERT12",
				icon = ST[105050],
				flashscreen = true,
			},
			TorrentofIcecd = {
				varname = format(L.alert["%s Cooldown"],SN[139866]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[139866]),
				time = 12,
				time2 = 8,
				color1 = "INDIGO",
				icon = ST[139866],
			},
			wTorrentofIce = {
				varname = format(L.alert["%s %s %s!"],SN[139866],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[139866],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT12",
				icon = ST[139866],
				flashscreen = true,
			},
			iTorrentofIceOut = {
				varname = format(L.alert["%s: %s!"],SN[139866],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s: %s!"],SN[139866],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT10",
				icon = ST[139866],
				throttle = 2,
				flashscreen = true,
			},
			iIcyGroundOut = {
				varname = format(L.alert["%s %s, %s!"],SN[139909],L.alert["under you"],L.alert["MOVE AWAY"]),
				type = "inform",
				text = format(L.alert["%s %s, %s!"],SN[139909],L.alert["under you"],L.alert["MOVE AWAY"]),
				time = 2,
				color1 = "INDIGO",
				sound = "ALERT10",
				icon = ST[139909],
				throttle = 2,
				flashscreen = true,
			},
			Rampageactive = {
				varname = format(L.alert["%s (2) %s"],SN[139458],L.alert["Duration"]),
				type = "dropdown",
				text = format(L.alert["%s (<Rampage>) %s"],SN[139458],L.alert["Duration"]),
				time = 20,
				color1 = "TAN",
				color2 = "RED",
				flashtime = 20,
				icon = ST[139458],
			},
			AcidRaincd = {
				varname = format(L.alert["%s Cooldown"],SN[139850]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[139850]),
				time = 13.5,
				color1 = "GREEN",
				icon = ST[139850],
			},
			SuppressionDebuff = {
				varname = format(L.alert["%s Debuff"],SN[140179]),
				type = "debuff",
				text = format(L.alert["%s: %s"],L.alert["YOU"],SN[140179]),
				text2 = format(L.alert["#5#: %s"],SN[140179]),
				time = 15,
				color1 = "VIOLET",
				icon = ST[140179],
				tag = "#5#",
			},
			iSuppression = {
				varname = format(L.alert["%s %s!"],SN[140179],L.alert["Dispell"]),
				type = "inform",
				text = format(L.alert["%s #5#!"],L.alert["Dispell"]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT10",
				icon = ST[140179],
			},
			NetherTearcast = {
				varname = format(L.alert["%s (%s)"],SN[140138],L.chat_ThroneOfThunder["Arcane Adds"]),
				type = "centerpopup",
				text = format(L.alert["%s (%s)"],SN[140138],L.chat_ThroneOfThunder["Arcane Adds"]),
				time = 6,
				color1 = "INDIGO",
				icon = ST[140138],
			},
			Nethercd = {
				varname = format(L.alert["%s Cooldown"],SN[140138]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[140138]),
				time = 30,
				time2 = 15,
				flashtime = 5,
				color1 = "INDIGO",
				icon = ST[140138],
			},
			ArcaneDiffusionDebuff = {
				varname = format(L.alert["%s Debuff"],SN[139993]),
				type = "debuff",
				text = format(L.alert["%s: %s (1)"],L.alert["YOU"],SN[139993]),
				text2 = format(L.alert["%s: %s (#11#)"],L.alert["YOU"],SN[139993]),
				text3 = format(L.alert["#5#: %s (1)"],SN[139993]),
				text4 = format(L.alert["#5#: %s (#11#)"],SN[139993]),
				time = 45,
				color1 = "PURPLE",
				icon = ST[139993],
				tag = "#5#",
				exdps = true,
			},
			iArcaneDiffusion = {
				varname = format(L.alert["%s %s %s!"],SN[139993],L.alert["on"],L.alert["YOU"]),
				type = "simple",
				text = format(L.alert["%s %s %s!"],SN[139993],L.alert["on"],L.alert["YOU"]),
				time = 2,
				color1 = "VIOLET",
				sound = "ALERT10",
				icon = ST[139993],
			},
			ArcaneDiffusioncd = {
				varname = format(L.alert["%s Cooldown"],SN[139993]),
				type = "dropdown",
				text = format(L.alert["%s Cooldown"],SN[139993]),
				time = 17,
				color1 = "PURPLE",
				icon = ST[139993],
			},
		},
		events = {
			-- ArcticFreeze 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 139843,
				execute = {
					{
						"expect",{"&istargettank|#5#&","==","true"},
						"invoke",{
							{
								"message","msgArcticFreeze",
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"quash","ArcticFreezeDebuff",
								"alert","ArcticFreezeDebuff",
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"quash","ArcticFreezeDebuff",
								"alert",{"ArcticFreezeDebuff", text = 3},
							},
						},
					},
					{
						"alert","ArcticFreezecd",
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 139843,
				execute = {
					{
						"expect",{"&istargettank|#5#&","==","true"},
						"invoke",{
							{
								"message",{"msgArcticFreeze", text = 2},
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"quash","ArcticFreezeDebuff",
								"alert",{"ArcticFreezeDebuff", text = 2},
								"invoke",{
									{
										"expect",{"#11#",">=","2"},
										"alert","iArcticFreeze",
									},
								},
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"quash","ArcticFreezeDebuff",
								"alert",{"ArcticFreezeDebuff", text = 4},
							},
						},
					},
					{
						"alert","ArcticFreezecd",
					},
				},     
			},
			-- IgniteFlesh
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 137731,
				execute = {
					{
						"expect",{"&istargettank|#5#&","==","true"},
						"invoke",{
							{
								"message","msgIgniteFlesh",
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"quash","IgniteFleshDebuff",
								"alert","IgniteFleshDebuff",
								--"alert","iIgniteFlesh",
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"quash","IgniteFleshDebuff",
								"alert",{"IgniteFleshDebuff", text = 3},
							},
						},
					},
					{
						"alert","IgniteFleshcd",
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 137731,
				execute = {
					{
						"expect",{"&istargettank|#5#&","==","true"},
						"invoke",{
							{
								"message",{"msgIgniteFlesh", text = 2},
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"quash","IgniteFleshDebuff",
								"alert",{"IgniteFleshDebuff", text = 2},
								"invoke",{
									{
										"expect",{"#11#",">=","2"},
										"alert","iIgniteFlesh",
									},
								},
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"quash","IgniteFleshDebuff",
								"alert",{"IgniteFleshDebuff", text = 4},
							},
						},
					},
					{
						"alert","IgniteFleshcd",
					},
				},     
			},
			-- RotArmor
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 139840,
				execute = {
					{
						"expect",{"&istargettank|#5#&","==","true"},
						"invoke",{
							{
								"message","msgRotArmor",
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"quash","RotArmorDebuff",
								"alert","RotArmorDebuff",
								--"alert","iRotArmor",
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"quash","RotArmorDebuff",
								"alert",{"RotArmorDebuff", text = 3},
							},
						},
					},
					{
						"alert","RotArmorcd",
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 139840,
				execute = {
					{
						"expect",{"&istargettank|#5#&","==","true"},
						"invoke",{
							{
								"message",{"msgRotArmor", text = 2},
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"quash","RotArmorDebuff",
								"alert",{"RotArmorDebuff", text = 2},
								"invoke",{
									{
										"expect",{"#11#",">=","2"},
										"alert","iRotArmor",
									},
								},
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"quash","RotArmorDebuff",
								"alert",{"RotArmorDebuff", text = 4},
							},
						},
					},
					{
						"alert","RotArmorcd",
					},
				},     
			},
			-- ArcaneDiffusion
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 139993,
				execute = {
					{
						"expect",{"&istargettank|#5#&","==","true"},
						"invoke",{
							{
								"message","msgArcaneDiffusion",
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"quash","ArcaneDiffusionDebuff",
								"alert","ArcaneDiffusionDebuff",
								"alert","iArcaneDiffusion",
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"quash","ArcaneDiffusionDebuff",
								"alert",{"ArcaneDiffusionDebuff", text = 3},
							},
						},
					},
					{
						"alert","ArcaneDiffusioncd",
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED_DOSE",
				spellname = 139993,
				execute = {
					{
						"expect",{"&istargettank|#5#&","==","true"},
						"invoke",{
							{
								"message",{"msgArcaneDiffusion", text = 2},
							},
							{
								"expect",{"#4#","==","&playerguid&"},
								"quash","ArcaneDiffusionDebuff",
								"alert",{"ArcaneDiffusionDebuff", text = 2},
								"invoke",{
									{
										"expect",{"#11#",">=","2"},
										"alert","iArcaneDiffusion",
									},
								},
							},
							{
								"expect",{"#4#","~=","&playerguid&"},
								"quash","ArcaneDiffusionDebuff",
								"alert",{"ArcaneDiffusionDebuff", text = 4},
							},
						},
					},
					{
						"alert","ArcaneDiffusioncd",
					},
				},     
			},
			-- Cinder
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 139822,
				execute = {
					{
						--"alert","Cindercd",
						"message","msgCinder",
						"raidicon","Cindericon",
					},
					{
						"expect",{"&dispell|magic&","==","true"},
						"alert","iDispellCinder",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"alert","iCinder",
						"announce","Cindersay",
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 139822,
				execute = {
					{
						"removeraidicon","#5#",
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 139836,
				dstisplayerunit = true,
				execute = {
					{
						"alert","iCinderOut",
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_MISSED",
				spellname = 139836,
				dstisplayerunit = true,
				execute = {
					{
						"alert","iCinderOut",
					},
				},
			},
		    -- TorrentofIce
			{
				type = "event",
				event = "WHISPER",
				execute = {
					--blue
					{
						"expect",{"#1#","find","spell:139866"},
						"announce","Torrentsay",
						"alert","wTorrentofIce",
						--"sync",{"msgTorrentofIce","2"},
						--"batchalert",{"TorrentofIcecd","wTorrentofIce"},
					},

				},
			},
			{
                type = "event",
                event = "UNIT_AURA",
                execute = {
                    {
						"expect",{"#1#","~=","player"},
						"expect",{"<expires>","~=","1"}, --&targetdebuffdur|#1#|"..SN[139857].."&
						"invoke", {
							{
								--"expect",{"<expires>","~=","1"}, --&targetdebuffdur|#1#|"..SN[139857].."&
								--"expect",{"&tabread|activetorrent|#1#&","~=","true"},
								--"invoke",{
								--	{
										"expect",{"&targetdebuff|#1#|"..SN[139857].."&","==","true"},
										"message","msgTorrentofIce",
										"raidicon","Torrenticon",
										"set",{expires = "1"},
										"scheduletimer",{"timerTorrent",12},
										"invoke",{
											{
												"expect",{"&inrange|#1#&","<","10"},
												"arrow","Torrentarrow",
											},
										},
										--"tabinsert",{"activetorrent","#1#","true"},
										--"tabupdate",{"activetorrent","#1#","false"},
								--	},
									--{
									--	"expect",{"#1#","==","player"},
									--	"announce","Torrentsay",
									--	"alert","wTorrentofIce",
								--	},
								--},
							},
						},
                    },
					{
						"expect",{"#1#","==","player"},
						"expect",{"&playerdebuff|"..SN[139857].."&","==","true"},
						"raidicon","Torrenticon",
					},
                },
            },	
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = 139889, 
				dstisplayerunit = true,
				execute = {
					{
						"alert","iTorrentofIceOut",
					},
				},
			},
			-- Icy Ground
			{
				type = "combatevent",
				eventtype = "SPELL_PERIODIC_DAMAGE",
				spellname = 139909, 
				dstisplayerunit = true,
				execute = {
					{
						"alert","iIcyGroundOut",
					},
				},
			},	
			{
				type = "combatevent",
				eventtype = "SPELL_PERIODIC_MISSED",
				spellname = 139909, 
				dstisplayerunit = true,
				execute = {
					{
						"alert","iIcyGroundOut",
					},
				},
			},	
			-- Emotes
			{
				type = "event",
				event = "EMOTE", 
				execute = {
					--Rampage
					{
					--"expect",{"#1#","find","spell:139458"}, 
						--"set",{Rampage = "INCR|1"},
					--	"message","msgRampage",
					--	"quashall",
					---	"alert","Rampageactive",
					--	"closewindow",
						--"batchquash",{"ArcticFreezecd","IgniteFleshcd","RotArmorcd"},
						--"scheduletimer",{"timerRampageOver",20},
						--"batchquash",{"ArcticFreezecd","IgniteFleshcd","RotArmorcd","Cindercd","TorrentofIcecd","AcidRaincd","Nethercd"},
					},
					-- Rampage Over
					{
						"expect",{"#1#","find",L.chat_ThroneOfThunder["(Megaera's rage subsides)"]},
						"message","msgRampageOver",
						"openwindow",{"5"},
						"quash","Rampageactive",
						"alert",{"Breathcd", time = 3},
						"invoke",{
							{ 
								"expect",{"<iceBehind>",">","0"},
								"invoke",{
									{
										"expect",{"&difficulty&",">=","3"}, --10h&25h
										"alert","TorrentofIcecd",
									},
									{
										"expect",{"&difficulty&","<=","2"}, --10h&25h
										"alert",{"TorrentofIcecd", time = 2},
									},
								},
							},
							{ 
								"expect",{"<fireBehind>",">","0"},
								"invoke",{
									{
										"expect",{"&difficulty&","==","0"},
										"alert",{"Cindercd", time = 3},
									},
									{
										"expect",{"&difficulty&","~=","0"},
										"alert",{"Cindercd", time = 5},
									},
								},
							},
							{ 
								"expect",{"<arcaneBehind>",">","0"},
								"alert",{"Nethercd", time = 2},
							},
							{ 
								"expect",{"<iceInFront>",">","0"},
								"alert",{"ArcticFreezecd", time = 2},
							},
							{ 
								"expect",{"<fireInFront>",">","0"},
								"alert",{"IgniteFleshcd", time = 2},
							},
							{ 
								"expect",{"<venomInFront>",">","0"},
								"alert",{"RotArmorcd", time = 2},
							},
							{ 
								"expect",{"<venomInFront>",">","0"},
								"alert",{"RotArmorcd", time = 2},
							},
						},
					},
				},
			},
			-- UNIT_SPELLCAST_SUCCEEDED
			{
				type = "event",
				event = "UNIT_SPELLCAST_SUCCEEDED",
				execute = {
					{
						"expect",{"#5#","==","139458"}, -- Rampage
						--"set",{Rampage = "INCR|1"},
						"message","msgRampage",
						"alert","Rampageactive",
						"closewindow",
						"batchquash",{"ArcticFreezecd","IgniteFleshcd","RotArmorcd","Cindercd","TorrentofIcecd","AcidRaincd","Nethercd"},
						--"scheduletimer",{"timerRampageOver",20},
					},
					{
						"expect",{"#2#","==",SN[70628]}, -- Deaths
						--"set",{Rampage = "INCR|1"},
						--"message","msgRampageSoon",
						"invoke",{ -- 70248, 70212, 70235, 70247, 68065) -- Arcane Head, Flaming Head, Frozen Head, Venomous Head, Megaera
							{
								"expect",{"&npcid|#4#&","==","70212"},  -- Flaming
								"set",{fireInFront = "DECR|1"},
								"set",{fireBehind = "INCR|2"},							
							},
							{
								"expect",{"&npcid|#4#&","==","70235"},  -- Frozen
								"set",{iceInFront = "DECR|1"},
								"set",{iceBehind = "INCR|2"},
							},
							{
								"expect",{"&npcid|#4#&","==","70247"},  -- Venomous
								"set",{venomInFront = "DECR|1"},
								"set",{venomBehind = "INCR|2"},
							},
							{
								"expect",{"&npcid|#4#&","==","70248"},  -- Arcane
								"set",{arcaneInFront = "DECR|1"},
								"set",{arcaneBehind = "INCR|2"},
							},
							--"scheduletimer",{"timerCheckHeads",1},
						},
					},
				},
			},		
			{
				type = "combatevent",
				eventtype = "UNIT_DIED",
				execute = {
					{
						"expect",{"&npcid|#4#&","==","70212"},  -- Flaming
						"set",{Rampage = "INCR|1"},
						"scheduletimer",{"timerCheckHeads",5},
						"invoke", {
							{
								"expect",{"<Rampage>","<","7"},
								"message","msgRampageSoon",
							},
						},
					},
					{
						"expect",{"&npcid|#4#&","==","70235"},  -- Frozen
						"set",{Rampage = "INCR|1"},
						"scheduletimer",{"timerCheckHeads",5},
						"invoke", {
							{
								"expect",{"<Rampage>","<","7"},
								"message","msgRampageSoon",
							},
						},
					},
					{
						"expect",{"&npcid|#4#&","==","70247"},  -- Venomous
						"set",{Rampage = "INCR|1"},
						"scheduletimer",{"timerCheckHeads",5},
						"invoke", {
							{
								"expect",{"<Rampage>","<","7"},
								"message","msgRampageSoon",
							},
						},
					},
					{
						"expect",{"&npcid|#4#&","==","70248"},  -- Arcane
						"set",{Rampage = "INCR|1"},
						"scheduletimer",{"timerCheckHeads",5},
						"invoke", {
							{
								"expect",{"<Rampage>","<","7"},
								"message","msgRampageSoon",
							},
						},
					},
				},
			},
			-- Suppression
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_APPLIED",
				spellname = 140179,
				execute = {
					{
						"message","msgSuppression",
					},
					{
						"expect",{"#4#","==","&playerguid&"},
						"quash","SuppressionDebuff",
						"alert","SuppressionDebuff",
					},
					{
						"expect",{"#4#","~=","&playerguid&"},
						"quash","SuppressionDebuff",
						"alert",{"SuppressionDebuff", text = 2},
					},
					{
						"expect",{"&dispell|magic&","==","true"},
						"alert","iSuppression",
					},
				},
			}, 
			{
				type = "combatevent",
				eventtype = "SPELL_AURA_REMOVED",
				spellname = 140179,
				execute = {
					{
						"quash","SuppressionDebuff",
					},
				},
			}, 
			-- NetherTear (arcane adds)
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_SUCCESS",
				spellname = 140138,
				execute = {
					{
						"message","msgNetherTear",
						"batchalert",{"NetherTearcast","Nethercd"},
					},
				},
			},
			-- Breath 
			{
				type = "combatevent",
				eventtype = "SPELL_DAMAGE",
				spellname = {139992,139839,139842,137730},
				dstisplayerunit = true,
				execute = {
					{
						"expect",{"&istank&","==","false"},
						"batchalert",{"wBreath","iBreathOut"},
					},
				},
			},
			{
				type = "combatevent",
				eventtype = "SPELL_CAST_START",
				spellname = {137729, 139841, 139838, 139991},
				execute = {
					{
						"alert","Breathcd",
					},
				},
			},
		},
	}

	DXE:RegisterEncounter(data)
end
