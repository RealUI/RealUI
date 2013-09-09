local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

nibRealUI.LoadAddOnData_Grid2 = function()
	Grid2DB = {
		["namespaces"] = {
			["Grid2Layout"] = {
				["profiles"] = {
					["RealUI-Healing"] = {
						["BorderB"] = 0,
						["layouts"] = {
							["solo"] = "None",
						},
						["BackgroundB"] = 0,
						["FrameLock"] = true,
						["BorderA"] = 0,
						["BorderR"] = 0,
						["BorderTexture"] = "None",
						["anchor"] = "TOP",
						["BackgroundG"] = 0,
						["PosY"] = 0,
						["BackgroundA"] = 0,
						["ClickThrough"] = true,
						["BorderG"] = 0,
						["BackgroundR"] = 0,
						["horizontal"] = false,
						["Spacing"] = 0,
						["PosX"] = 0,
					},
					["RealUI"] = {
						["BorderB"] = 0,
						["layouts"] = {
							["solo"] = "None",
						},
						["BackgroundB"] = 0,
						["FrameLock"] = true,
						["BorderA"] = 0,
						["BorderR"] = 0,
						["ClickThrough"] = true,
						["anchor"] = "BOTTOM",
						["BackgroundG"] = 0,
						["groupAnchor"] = "BOTTOMLEFT",
						["PosY"] = 0,
						["BackgroundR"] = 0,
						["BackgroundA"] = 0,
						["BorderG"] = 0,
						["BorderTexture"] = "None",
						["Spacing"] = 0,
						["PosX"] = 0,
					},
				},
			},
			["LibDualSpec-1.0"] = {
			},
			["Grid2AoeHeals"] = {
			},
			["Grid2Frame"] = {
				["profiles"] = {
					["RealUI"] = {
						["frameColor"] = {
							["a"] = 0,
						},
						["frameBorder"] = 1,
						["frameHeight"] = 25,
						["font"] = "pixel_small",
						["frameTexture"] = "Plain",
						["frameContentColor"] = {
							["a"] = 0,
						},
						["frameWidth"] = 65,
						["orientation"] = "HORIZONTAL",
					},
					["RealUI-Healing"] = {
						["frameColor"] = {
							["a"] = 0,
						},
						["font"] = "pixel_small",
						["frameHeight"] = 30,
						["frameContentColor"] = {
							["a"] = 0,
						},
						["frameBorder"] = 1,
						["frameTexture"] = "Plain",
						["frameWidth"] = 65,
						["orientation"] = "HORIZONTAL",
					},
				},
			},
			["Grid2RaidDebuffs"] = {
				["profiles"] = {
					["RealUI"] = {
						["enabledModules"] = {
							["Mists of Pandaria"] = true,
						},
					},
					["RealUI-Healing"] = {
						["enabledModules"] = {
							["Mists of Pandaria"] = true,
						},
					},
				},
			},
		},
		["profileKeys"] = {
			["Real - Zul'jin"] = "RealUI",
		},
		["profiles"] = {
			["Real - Zul'jin"] = {
				["statusMap"] = {
					["heals"] = {
						["heals-incoming"] = 99,
					},
					["side-bottom"] = {
						["buff-Evasion-mine"] = 99,
					},
					["icon-right"] = {
						["raid-icon-target"] = 90,
					},
					["heals-color"] = {
						["classcolor"] = 99,
					},
					["icon-left"] = {
						["raid-icon-player"] = 155,
					},
					["alpha"] = {
						["offline"] = 97,
						["range"] = 99,
						["death"] = 98,
					},
					["text-down"] = {
						["name"] = 99,
					},
					["text-down-color"] = {
						["classcolor"] = 99,
					},
					["text-up"] = {
						["charmed"] = 65,
						["feign-death"] = 96,
						["health-deficit"] = 50,
						["offline"] = 93,
						["vehicle"] = 70,
						["death"] = 95,
					},
					["health"] = {
						["health-current"] = 99,
					},
					["border"] = {
						["target"] = 50,
						["health-low"] = 55,
					},
					["corner-bottom-left"] = {
						["threat"] = 99,
					},
					["text-up-color"] = {
						["charmed"] = 65,
						["feign-death"] = 96,
						["health-deficit"] = 50,
						["offline"] = 93,
						["vehicle"] = 70,
						["death"] = 95,
					},
					["health-color"] = {
						["classcolor"] = 99,
					},
					["icon-center"] = {
						["ready-check"] = 150,
						["raid-debuffs"] = 155,
						["death"] = 155,
					},
				},
				["versions"] = {
					["Grid2"] = 3,
					["Grid2RaidDebuffs"] = 1,
				},
				["indicators"] = {
					["heals"] = {
						["type"] = "bar",
						["parentBar"] = "health",
						["color1"] = {
							["a"] = 0,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["location"] = {
							["y"] = 0,
							["relPoint"] = "CENTER",
							["point"] = "CENTER",
							["x"] = 0,
						},
						["level"] = 1,
						["opacity"] = 0.25,
						["texture"] = "Gradient",
					},
					["icon-right"] = {
						["type"] = "icon",
						["location"] = {
							["y"] = 0,
							["relPoint"] = "RIGHT",
							["point"] = "RIGHT",
							["x"] = 2,
						},
						["level"] = 8,
						["fontSize"] = 8,
						["size"] = 12,
					},
					["heals-color"] = {
						["type"] = "bar-color",
					},
					["icon-left"] = {
						["type"] = "icon",
						["location"] = {
							["y"] = 0,
							["relPoint"] = "LEFT",
							["point"] = "LEFT",
							["x"] = -2,
						},
						["level"] = 8,
						["fontSize"] = 8,
						["size"] = 12,
					},
					["alpha"] = {
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["type"] = "alpha",
					},
					["text-down"] = {
						["type"] = "text",
						["font"] = "Friz Quadrata TT",
						["location"] = {
							["y"] = 4,
							["relPoint"] = "BOTTOM",
							["point"] = "BOTTOM",
							["x"] = 0,
						},
						["level"] = 6,
						["textlength"] = 6,
						["fontSize"] = 8,
					},
					["border"] = {
						["color1"] = {
							["a"] = 0,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["type"] = "border",
					},
					["text-down-color"] = {
						["type"] = "text-color",
					},
					["health"] = {
						["type"] = "bar",
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["childBar"] = "heals",
						["level"] = 2,
						["location"] = {
							["y"] = 0,
							["relPoint"] = "CENTER",
							["point"] = "CENTER",
							["x"] = 0,
						},
						["texture"] = "Gradient",
					},
					["text-up"] = {
						["type"] = "text",
						["font"] = "Friz Quadrata TT",
						["location"] = {
							["y"] = -8,
							["relPoint"] = "TOP",
							["point"] = "TOP",
							["x"] = 0,
						},
						["level"] = 7,
						["textlength"] = 6,
						["fontSize"] = 8,
					},
					["corner-bottom-left"] = {
						["type"] = "square",
						["location"] = {
							["y"] = 0,
							["relPoint"] = "BOTTOMLEFT",
							["point"] = "BOTTOMLEFT",
							["x"] = 0,
						},
						["level"] = 5,
						["color1"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["size"] = 5,
					},
					["text-up-color"] = {
						["type"] = "text-color",
					},
					["health-color"] = {
						["type"] = "bar-color",
					},
					["icon-center"] = {
						["type"] = "icon",
						["size"] = 14,
						["location"] = {
							["y"] = 0,
							["relPoint"] = "CENTER",
							["point"] = "CENTER",
							["x"] = 0,
						},
						["level"] = 8,
						["fontSize"] = 8,
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
					},
				},
				["statuses"] = {
					["buff-Evasion-mine"] = {
						["color1"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 0.1,
							["r"] = 0.1,
						},
						["type"] = "buff",
						["mine"] = true,
						["spellName"] = 5277,
					},
				},
			},
			["RealUI-Healing"] = {
				["statuses"] = {
					["health-deficit"] = {
						["threshold"] = 0,
						["color1"] = {
							["a"] = 0.9000000059604645,
							["r"] = 0.03137254901960784,
							["g"] = 0.03137254901960784,
							["b"] = 0.03137254901960784,
						},
					},
					["afk"] = {
						["color1"] = {
							["r"] = 0.5019607843137255,
							["g"] = 0.5019607843137255,
							["b"] = 0.5019607843137255,
						},
					},
					["buff-DivineAegis"] = {
						["type"] = "buff",
						["spellName"] = 47509,
						["color1"] = {
							["a"] = 1,
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
					},
					["buff-PowerWordShield"] = {
						["type"] = "buff",
						["spellName"] = 17,
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 1,
							["b"] = 1,
						},
					},
					["dungeon-role"] = {
						["color2"] = {
							["a"] = 1,
						},
						["hideDamagers"] = true,
						["color1"] = {
							["a"] = 1,
							["r"] = 0.7490196078431373,
						},
					},
					["raid-debuffs"] = {
						["debuffs"] = {
							["Mogu'shan Vaults"] = {
								122151, -- [1]
								117723, -- [2]
								116260, -- [3]
								118562, -- [4]
								116596, -- [5]
								116525, -- [6]
								116778, -- [7]
								117485, -- [8]
								116550, -- [9]
								116829, -- [10]
								118303, -- [11]
								118048, -- [12]
								118135, -- [13]
								118047, -- [14]
								118163, -- [15]
								131788, -- [16]
								116040, -- [17]
								116942, -- [18]
								116784, -- [19]
								131790, -- [20]
								102464, -- [21]
								116417, -- [22]
								116364, -- [23]
								116374, -- [24]
								131792, -- [25]
								117878, -- [26]
								117949, -- [27]
								117945, -- [28]
								130395, -- [29]
								130404, -- [30]
								130774, -- [31]
								116038, -- [32]
								115861, -- [33]
								116060, -- [34]
								116281, -- [35]
								125206, -- [36]
								116008, -- [37]
							},
							["Heart of Fear"] = {
								122949, -- [1]
								123474, -- [2]
								124783, -- [3]
								123600, -- [4]
								121949, -- [5]
								122784, -- [6]
								122064, -- [7]
								122504, -- [8]
								125390, -- [9]
								123707, -- [10]
								123788, -- [11]
								124097, -- [12]
								125824, -- [13]
								124777, -- [14]
								124821, -- [15]
								124827, -- [16]
								124849, -- [17]
								124863, -- [18]
								124862, -- [19]
								123845, -- [20]
								123846, -- [21]
								29212, -- [22]
								121881, -- [23]
								122055, -- [24]
								122064, -- [25]
								122760, -- [26]
								123812, -- [27]
								122740, -- [28]
								122706, -- [29]
								122835, -- [30]
								123081, -- [31]
								123120, -- [32]
							},
							["Terrace of Endless Spring"] = {
								119414, -- [1]
								129147, -- [2]
								119983, -- [3]
								120669, -- [4]
								75683, -- [5]
								120629, -- [6]
								120394, -- [7]
								129189, -- [8]
								119086, -- [9]
								119775, -- [10]
								122768, -- [11]
								122777, -- [12]
								122752, -- [13]
								122789, -- [14]
								123012, -- [15]
								123011, -- [16]
								123036, -- [17]
								122858, -- [18]
								117519, -- [19]
								111850, -- [20]
								117436, -- [21]
								118191, -- [22]
								117986, -- [23]
								123121, -- [24]
								123705, -- [25]
							},
							["Throne of Thunder"] = {
								137341, -- [1]
								137360, -- [2]
								137408, -- [3]
								137440, -- [4]
								138349, -- [5]
								137399, -- [6]
								138733, -- [7]
								140092, -- [8]
								134256, -- [9]
								138319, -- [10]
								134366, -- [11]
								140014, -- [12]
								136050, -- [13]
								140546, -- [14]
								137000, -- [15]
								138609, -- [16]
								138569, -- [17]
								138659, -- [18]
								136954, -- [19]
								134691, -- [20]
								134647, -- [21]
								136193, -- [22]
								135145, -- [23]
								139822, -- [24]
								137731, -- [25]
								139866, -- [26]
								139841, -- [27]
								134378, -- [28]
								139839, -- [29]
								140179, -- [30]
								139994, -- [31]
								137552, -- [32]
								134916, -- [33]
								135150, -- [34]
								139011, -- [35]
								136478, -- [36]
								136853, -- [37]
								136767, -- [38]
								136708, -- [39]
								136719, -- [40]
								136654, -- [41]
								136587, -- [42]
								136512, -- [43]
								140946, -- [44]
								133767, -- [45]
								133768, -- [46]
								134755, -- [47]
								136413, -- [48]
								133795, -- [49]
								133597, -- [50]
								133598, -- [51]
								134007, -- [52]
								137650, -- [53]
								137085, -- [54]
								136922, -- [55]
								136917, -- [56]
								136903, -- [57]
								136857, -- [58]
								137359, -- [59]
								137891, -- [60]
							},
							["Kun-Lai Summit"] = {
								119626, -- [1]
								119488, -- [2]
								119610, -- [3]
								119601, -- [4]
							},
						},
					},
					["health-current"] = {
						["color2"] = {
							["a"] = 0.7000000178813934,
							["g"] = 0,
							["r"] = 0,
						},
						["color3"] = {
							["a"] = 0.7000000178813934,
							["r"] = 0,
						},
						["color1"] = {
							["a"] = 0.5,
							["g"] = 0,
						},
					},
					["buff-SpiritOfRedemption"] = {
						["spellName"] = 27827,
						["type"] = "buff",
						["blinkThreshold"] = 3,
						["color1"] = {
							["a"] = 1,
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
					},
					["threat"] = {
						["color2"] = {
							["b"] = 0,
							["g"] = 0,
							["r"] = 1,
						},
						["color3"] = {
							["g"] = 0,
							["b"] = 0,
						},
						["color1"] = {
							["g"] = 0.4156862745098039,
						},
					},
					["debuff-WeakenedSoul"] = {
						["type"] = "debuff",
						["spellName"] = 6788,
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 0.2,
							["b"] = 0.9,
						},
					},
					["buff-Lifebloom-mine"] = {
						["color1"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["type"] = "buff",
						["mine"] = 1,
						["spellName"] = 33763,
					},
					["buff-Grace-mine"] = {
						["color2"] = {
							["a"] = 1,
							["r"] = 0.8,
							["g"] = 0.8,
							["b"] = 0.8,
						},
						["type"] = "buff",
						["color3"] = {
							["a"] = 1,
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
						["spellName"] = 77613,
						["colorCount"] = 3,
						["mine"] = true,
						["color1"] = {
							["a"] = 1,
							["r"] = 0.6,
							["g"] = 0.6,
							["b"] = 0.6,
						},
					},
					["buff-RenewingMist-mine"] = {
						["spellName"] = 119611,
						["type"] = "buff",
						["mine"] = 1,
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 1,
							["b"] = 0,
						},
					},
					["buff-Riptide-mine"] = {
						["spellName"] = 61295,
						["type"] = "buff",
						["mine"] = 1,
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 1,
							["b"] = 0,
						},
					},
					["buff-PrayerOfMending-mine"] = {
						["type"] = "buff",
						["mine"] = true,
						["color1"] = {
							["a"] = 1,
							["r"] = 1,
							["g"] = 0.2,
							["b"] = 0.2,
						},
						["color2"] = {
							["a"] = 0.4,
							["r"] = 1,
							["g"] = 1,
							["b"] = 0.4,
						},
						["color4"] = {
							["a"] = 1,
							["r"] = 1,
							["g"] = 0.8,
							["b"] = 0.8,
						},
						["spellName"] = 33076,
						["color3"] = {
							["a"] = 1,
							["r"] = 1,
							["g"] = 0.6,
							["b"] = 0.6,
						},
						["color5"] = {
							["a"] = 1,
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
						["colorCount"] = 5,
					},
					["buff-EternalFlame-mine"] = {
						["spellName"] = 114163,
						["type"] = "buff",
						["mine"] = 1,
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 1,
							["b"] = 0,
						},
					},
					["buff-Rejuvenation-mine"] = {
						["spellName"] = 774,
						["type"] = "buff",
						["mine"] = 1,
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 1,
							["b"] = 0,
						},
					},
					["buff-InnerFire"] = {
						["missing"] = true,
						["type"] = "buff",
						["spellName"] = 588,
						["color1"] = {
							["a"] = 1,
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
					},
					["friendcolor"] = {
						["colorHostile"] = true,
					},
					["buff-SpiritShell-mine"] = {
						["type"] = "buff",
						["spellName"] = 114908,
						["useSpellId"] = true,
						["mine"] = 1,
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 1,
							["b"] = 0,
						},
					},
					["raid-icon-player"] = {
						["color1"] = {
							["g"] = 0.9607843137254902,
							["b"] = 0.1647058823529412,
						},
					},
					["buff-Renew-mine"] = {
						["spellName"] = 139,
						["type"] = "buff",
						["mine"] = true,
						["color1"] = {
							["a"] = 1,
							["r"] = 1,
							["g"] = 1,
							["b"] = 1,
						},
					},
				},
				["versions"] = {
					["Grid2"] = 3,
					["Grid2RaidDebuffs"] = 1,
				},
				["indicators"] = {
					["corner-top-left"] = {
						["texture"] = "Plain",
						["type"] = "square",
						["width"] = 6,
						["location"] = {
							["y"] = -1,
							["relPoint"] = "TOPLEFT",
							["point"] = "TOPLEFT",
							["x"] = 1,
						},
						["height"] = 3,
						["level"] = 9,
						["borderSize"] = 1,
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
					},
					["text-down"] = {
						["fontSize"] = 8,
						["font"] = "pixel_small",
						["type"] = "text",
						["location"] = {
							["y"] = 0,
							["relPoint"] = "CENTER",
							["point"] = "CENTER",
							["x"] = 2,
						},
						["level"] = 3,
						["textlength"] = 4,
						["fontFlags"] = "MONOCHROME, OUTLINE",
					},
					["icon-left"] = {
						["disableStack"] = true,
						["type"] = "icon",
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["size"] = 12,
						["disableOmniCC"] = true,
						["location"] = {
							["y"] = 0,
							["relPoint"] = "LEFT",
							["point"] = "LEFT",
							["x"] = 1,
						},
						["level"] = 8,
						["fontSize"] = 8,
						["texture"] = "Plain",
					},
					["border"] = {
						["type"] = "border",
						["color1"] = {
							["a"] = 0,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
					},
					["text-down-color"] = {
						["type"] = "text-color",
					},
					["icon-center"] = {
						["fontSize"] = 8,
						["fontFlags"] = "MONOCHROME, OUTLINE",
						["font"] = "pixel_small",
						["location"] = {
							["y"] = 0,
							["relPoint"] = "CENTER",
							["point"] = "CENTER",
							["x"] = 0,
						},
						["level"] = 8,
						["type"] = "icon",
						["size"] = 14,
					},
					["health-deficit-color"] = {
						["type"] = "bar-color",
					},
					["health-color"] = {
						["type"] = "bar-color",
					},
					["corner-top-right"] = {
						["width"] = 6,
						["borderSize"] = 1,
						["type"] = "square",
						["height"] = 3,
						["location"] = {
							["y"] = 1,
							["relPoint"] = "BOTTOMRIGHT",
							["point"] = "BOTTOMRIGHT",
							["x"] = -1,
						},
						["level"] = 9,
						["texture"] = "Plain",
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
					},
					["heals-color"] = {
						["type"] = "bar-color",
					},
					["alpha"] = {
						["type"] = "alpha",
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
					},
					["icon-right"] = {
						["fontSize"] = 8,
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["borderSize"] = 1,
						["type"] = "square",
						["height"] = 8,
						["location"] = {
							["y"] = 0,
							["relPoint"] = "RIGHT",
							["point"] = "RIGHT",
							["x"] = -1,
						},
						["level"] = 8,
						["width"] = 8,
						["texture"] = "Plain",
					},
					["heals"] = {
						["type"] = "bar",
						["parentBar"] = "health",
						["texture"] = "Plain",
						["location"] = {
							["y"] = 0,
							["relPoint"] = "CENTER",
							["point"] = "CENTER",
							["x"] = 0,
						},
						["level"] = 1,
						["opacity"] = 0.25,
						["color1"] = {
							["a"] = 0,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
					},
					["health"] = {
						["type"] = "bar",
						["texture"] = "Plain90",
						["childBar"] = "heals",
						["location"] = {
							["y"] = 0,
							["relPoint"] = "LEFT",
							["point"] = "LEFT",
							["x"] = 0,
						},
						["level"] = 3,
						["orientation"] = "HORIZONTAL",
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
					},
					["corner-bottom-left"] = {
						["type"] = "icon",
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["size"] = 10,
						["borderSize"] = 1,
						["fontSize"] = 8,
						["location"] = {
							["y"] = 1,
							["relPoint"] = "BOTTOMLEFT",
							["point"] = "BOTTOMLEFT",
							["x"] = 1,
						},
						["height"] = 6,
						["level"] = 5,
						["width"] = 6,
						["texture"] = "Plain",
					},
					["text-up"] = {
						["fontSize"] = 8,
						["font"] = "pixel_small",
						["type"] = "text",
						["location"] = {
							["y"] = -8,
							["relPoint"] = "TOP",
							["point"] = "TOP",
							["x"] = 0,
						},
						["level"] = 6,
						["textlength"] = 4,
						["fontFlags"] = "MONOCHROME, OUTLINE",
					},
					["text-up-color"] = {
						["type"] = "text-color",
					},
					["health-deficit"] = {
						["type"] = "bar",
						["location"] = {
							["y"] = 0,
							["relPoint"] = "RIGHT",
							["point"] = "RIGHT",
							["x"] = 0,
						},
						["level"] = 2,
						["orientation"] = "HORIZONTAL",
						["texture"] = "Plain90",
					},
					["side-bottom"] = {
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["type"] = "square",
						["texture"] = "Plain",
						["location"] = {
							["y"] = 1,
							["relPoint"] = "BOTTOM",
							["point"] = "BOTTOM",
							["x"] = 0,
						},
						["height"] = 3,
						["level"] = 9,
						["borderSize"] = 1,
						["width"] = 6,
					},
				},
				["statusMap"] = {
					["corner-top-left"] = {
						["debuff-Disease"] = 53,
						["debuff-Magic"] = 52,
						["debuff-Poison"] = 51,
						["debuff-Curse"] = 50,
					},
					["health-deficit"] = {
						["health-deficit"] = 50,
					},
					["icon-left"] = {
						["buff-EternalFlame-mine"] = 51,
						["buff-Rejuvenation-mine"] = 55,
						["buff-Lifebloom-mine"] = 56,
						["buff-SpiritShell-mine"] = 53,
						["buff-Riptide-mine"] = 52,
						["buff-Renew-mine"] = 54,
						["buff-RenewingMist-mine"] = 50,
					},
					["border"] = {
						["afk"] = 51,
						["threat"] = 50,
					},
					["text-down-color"] = {
						["classcolor"] = 99,
					},
					["icon-center"] = {
						["raid-debuffs"] = 50,
					},
					["health-deficit-color"] = {
						["health-deficit"] = 50,
					},
					["health-color"] = {
						["classcolor"] = 50,
					},
					["corner-top-right"] = {
						["raid-assistant"] = 50,
						["leader"] = 51,
					},
					["heals-color"] = {
						["classcolor"] = 99,
					},
					["alpha"] = {
						["offline"] = 97,
						["range"] = 99,
						["death"] = 98,
					},
					["icon-right"] = {
						["raid-icon-player"] = 50,
					},
					["text-down"] = {
						["offline"] = 102,
						["charmed"] = 101,
						["name"] = 99,
						["death"] = 103,
					},
					["health"] = {
						["health-current"] = 99,
					},
					["corner-bottom-left"] = {
						["ready-check"] = 50,
					},
					["text-up"] = {
					},
					["text-up-color"] = {
						["charmed"] = 65,
						["feign-death"] = 96,
						["health-deficit"] = 50,
						["offline"] = 93,
						["death"] = 95,
						["vehicle"] = 70,
					},
					["heals"] = {
						["heals-incoming"] = 50,
					},
					["side-bottom"] = {
						["dungeon-role"] = 50,
					},
				},
			},
			["RealUI"] = {
				["indicators"] = {
					["corner-top-left"] = {
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
						["borderSize"] = 1,
						["type"] = "square",
						["height"] = 3,
						["location"] = {
							["y"] = -1,
							["relPoint"] = "TOPLEFT",
							["point"] = "TOPLEFT",
							["x"] = 1,
						},
						["level"] = 9,
						["width"] = 6,
						["texture"] = "Plain",
					},
					["health-deficit"] = {
						["type"] = "bar",
						["orientation"] = "HORIZONTAL",
						["level"] = 2,
						["location"] = {
							["y"] = 0,
							["relPoint"] = "RIGHT",
							["point"] = "RIGHT",
							["x"] = 0,
						},
						["texture"] = "Plain90",
					},
					["icon-left"] = {
						["type"] = "icon",
						["location"] = {
							["y"] = 0,
							["relPoint"] = "LEFT",
							["point"] = "LEFT",
							["x"] = 1,
						},
						["level"] = 8,
						["fontSize"] = 8,
						["size"] = 12,
					},
					["border"] = {
						["color1"] = {
							["a"] = 0,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["type"] = "border",
					},
					["text-down-color"] = {
						["type"] = "text-color",
					},
					["icon-center"] = {
						["size"] = 14,
						["type"] = "icon",
						["fontSize"] = 8,
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["location"] = {
							["y"] = 0,
							["relPoint"] = "CENTER",
							["point"] = "CENTER",
							["x"] = 0,
						},
						["level"] = 8,
						["font"] = "pixel_small",
						["fontFlags"] = "MONOCHROME, OUTLINE",
					},
					["health-deficit-color"] = {
						["type"] = "bar-color",
					},
					["health-color"] = {
						["type"] = "bar-color",
					},
					["icon-right"] = {
						["fontSize"] = 8,
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
						["borderSize"] = 1,
						["width"] = 8,
						["type"] = "square",
						["location"] = {
							["y"] = 0,
							["relPoint"] = "RIGHT",
							["point"] = "RIGHT",
							["x"] = -1,
						},
						["level"] = 8,
						["height"] = 8,
						["texture"] = "Plain",
					},
					["heals-color"] = {
						["type"] = "bar-color",
					},
					["alpha"] = {
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["type"] = "alpha",
					},
					["text-down"] = {
						["type"] = "text",
						["fontSize"] = 8,
						["font"] = "pixel_small",
						["location"] = {
							["y"] = 0,
							["relPoint"] = "CENTER",
							["point"] = "CENTER",
							["x"] = 2,
						},
						["level"] = 3,
						["textlength"] = 4,
						["fontFlags"] = "MONOCHROME, OUTLINE",
					},
					["corner-top-right"] = {
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
						["borderSize"] = 1,
						["type"] = "square",
						["height"] = 3,
						["location"] = {
							["y"] = 1,
							["relPoint"] = "BOTTOMRIGHT",
							["point"] = "BOTTOMRIGHT",
							["x"] = -1,
						},
						["level"] = 9,
						["width"] = 6,
						["texture"] = "Plain",
					},
					["health"] = {
						["type"] = "bar",
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["childBar"] = "heals",
						["orientation"] = "HORIZONTAL",
						["level"] = 3,
						["location"] = {
							["y"] = 0,
							["relPoint"] = "LEFT",
							["point"] = "LEFT",
							["x"] = 0,
						},
						["texture"] = "Plain",
					},
					["text-up"] = {
						["type"] = "text",
						["fontSize"] = 8,
						["font"] = "pixel_small",
						["location"] = {
							["y"] = -8,
							["relPoint"] = "TOP",
							["point"] = "TOP",
							["x"] = 0,
						},
						["level"] = 6,
						["textlength"] = 4,
						["fontFlags"] = "MONOCHROME, OUTLINE",
					},
					["corner-bottom-left"] = {
						["type"] = "icon",
						["color1"] = {
							["a"] = 1,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["size"] = 10,
						["borderSize"] = 1,
						["fontSize"] = 8,
						["location"] = {
							["y"] = 1,
							["relPoint"] = "BOTTOMLEFT",
							["point"] = "BOTTOMLEFT",
							["x"] = 1,
						},
						["height"] = 6,
						["level"] = 5,
						["width"] = 6,
						["texture"] = "Plain",
					},
					["text-up-color"] = {
						["type"] = "text-color",
					},
					["heals"] = {
						["type"] = "bar",
						["parentBar"] = "health",
						["color1"] = {
							["a"] = 0,
							["b"] = 0,
							["g"] = 0,
							["r"] = 0,
						},
						["location"] = {
							["y"] = 0,
							["relPoint"] = "CENTER",
							["point"] = "CENTER",
							["x"] = 0,
						},
						["level"] = 1,
						["opacity"] = 0.25,
						["texture"] = "Plain",
					},
					["side-bottom"] = {
						["width"] = 6,
						["borderSize"] = 1,
						["type"] = "square",
						["height"] = 3,
						["location"] = {
							["y"] = 1,
							["relPoint"] = "BOTTOM",
							["point"] = "BOTTOM",
							["x"] = 0,
						},
						["level"] = 9,
						["texture"] = "Plain",
						["color1"] = {
							["a"] = 1,
							["r"] = 0,
							["g"] = 0,
							["b"] = 0,
						},
					},
				},
				["statusMap"] = {
					["corner-top-left"] = {
						["debuff-Curse"] = 50,
						["debuff-Magic"] = 52,
						["debuff-Poison"] = 51,
						["debuff-Disease"] = 53,
					},
					["health-deficit"] = {
						["health-deficit"] = 50,
					},
					["icon-left"] = {
					},
					["border"] = {
						["afk"] = 51,
						["threat"] = 50,
					},
					["text-down-color"] = {
						["classcolor"] = 99,
					},
					["icon-center"] = {
						["raid-debuffs"] = 50,
					},
					["health-deficit-color"] = {
						["classcolor"] = 50,
					},
					["heals"] = {
						["heals-incoming"] = 50,
					},
					["icon-right"] = {
						["raid-icon-player"] = 50,
					},
					["heals-color"] = {
						["classcolor"] = 99,
					},
					["alpha"] = {
						["offline"] = 97,
						["range"] = 99,
						["death"] = 98,
					},
					["corner-top-right"] = {
						["raid-assistant"] = 50,
						["leader"] = 51,
					},
					["health-color"] = {
						["health-current"] = 50,
					},
					["health"] = {
						["health-current"] = 99,
					},
					["corner-bottom-left"] = {
						["ready-check"] = 50,
					},
					["text-up"] = {
					},
					["text-up-color"] = {
						["charmed"] = 65,
						["feign-death"] = 96,
						["health-deficit"] = 50,
						["offline"] = 93,
						["vehicle"] = 70,
						["death"] = 95,
					},
					["text-down"] = {
						["charmed"] = 101,
						["offline"] = 102,
						["name"] = 99,
						["death"] = 103,
					},
					["side-bottom"] = {
						["dungeon-role"] = 50,
					},
				},
				["versions"] = {
					["Grid2"] = 3,
					["Grid2RaidDebuffs"] = 1,
				},
				["statuses"] = {
					["buff-PowerWordShield"] = {
						["type"] = "buff",
						["color1"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 1,
							["r"] = 0,
						},
						["spellName"] = 17,
					},
					["dungeon-role"] = {
						["color2"] = {
							["a"] = 1,
						},
						["hideDamagers"] = true,
						["color1"] = {
							["a"] = 1,
							["r"] = 0.7490196078431373,
						},
					},
					["raid-debuffs"] = {
						["debuffs"] = {
							["Mogu'shan Vaults"] = {
								122151, -- [1]
								117723, -- [2]
								116260, -- [3]
								118562, -- [4]
								116596, -- [5]
								116525, -- [6]
								116778, -- [7]
								117485, -- [8]
								116550, -- [9]
								116829, -- [10]
								118303, -- [11]
								118048, -- [12]
								118135, -- [13]
								118047, -- [14]
								118163, -- [15]
								131788, -- [16]
								116040, -- [17]
								116942, -- [18]
								116784, -- [19]
								131790, -- [20]
								102464, -- [21]
								116417, -- [22]
								116364, -- [23]
								116374, -- [24]
								131792, -- [25]
								117878, -- [26]
								117949, -- [27]
								117945, -- [28]
								130395, -- [29]
								130404, -- [30]
								130774, -- [31]
								116038, -- [32]
								115861, -- [33]
								116060, -- [34]
								116281, -- [35]
								125206, -- [36]
								116008, -- [37]
							},
							["Heart of Fear"] = {
								122949, -- [1]
								123474, -- [2]
								124783, -- [3]
								123600, -- [4]
								121949, -- [5]
								122784, -- [6]
								122064, -- [7]
								122504, -- [8]
								125390, -- [9]
								123707, -- [10]
								123788, -- [11]
								124097, -- [12]
								125824, -- [13]
								124777, -- [14]
								124821, -- [15]
								124827, -- [16]
								124849, -- [17]
								124863, -- [18]
								124862, -- [19]
								123845, -- [20]
								123846, -- [21]
								29212, -- [22]
								121881, -- [23]
								122055, -- [24]
								122064, -- [25]
								122760, -- [26]
								123812, -- [27]
								122740, -- [28]
								122706, -- [29]
								122835, -- [30]
								123081, -- [31]
								123120, -- [32]
							},
							["Terrace of Endless Spring"] = {
								119414, -- [1]
								129147, -- [2]
								119983, -- [3]
								120669, -- [4]
								75683, -- [5]
								120629, -- [6]
								120394, -- [7]
								129189, -- [8]
								119086, -- [9]
								119775, -- [10]
								122768, -- [11]
								122777, -- [12]
								122752, -- [13]
								122789, -- [14]
								123012, -- [15]
								123011, -- [16]
								123036, -- [17]
								122858, -- [18]
								117519, -- [19]
								111850, -- [20]
								117436, -- [21]
								118191, -- [22]
								117986, -- [23]
								123121, -- [24]
								123705, -- [25]
							},
							["Throne of Thunder"] = {
								137341, -- [1]
								137360, -- [2]
								137408, -- [3]
								137440, -- [4]
								138349, -- [5]
								137399, -- [6]
								138733, -- [7]
								140092, -- [8]
								134256, -- [9]
								138319, -- [10]
								134366, -- [11]
								140014, -- [12]
								136050, -- [13]
								140546, -- [14]
								137000, -- [15]
								138609, -- [16]
								138569, -- [17]
								138659, -- [18]
								136954, -- [19]
								134691, -- [20]
								134647, -- [21]
								136193, -- [22]
								135145, -- [23]
								139822, -- [24]
								137731, -- [25]
								139866, -- [26]
								139841, -- [27]
								134378, -- [28]
								139839, -- [29]
								140179, -- [30]
								139994, -- [31]
								137552, -- [32]
								134916, -- [33]
								135150, -- [34]
								139011, -- [35]
								136478, -- [36]
								136853, -- [37]
								136767, -- [38]
								136708, -- [39]
								136719, -- [40]
								136654, -- [41]
								136587, -- [42]
								136512, -- [43]
								140946, -- [44]
								133767, -- [45]
								133768, -- [46]
								134755, -- [47]
								136413, -- [48]
								133795, -- [49]
								133597, -- [50]
								133598, -- [51]
								134007, -- [52]
								137650, -- [53]
								137085, -- [54]
								136922, -- [55]
								136917, -- [56]
								136903, -- [57]
								136857, -- [58]
								137359, -- [59]
								137891, -- [60]
							},
							["Kun-Lai Summit"] = {
								119626, -- [1]
								119488, -- [2]
								119610, -- [3]
								119601, -- [4]
							},
						},
					},
					["buff-SpiritOfRedemption"] = {
						["color1"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["type"] = "buff",
						["blinkThreshold"] = 3,
						["spellName"] = 27827,
					},
					["threat"] = {
						["color2"] = {
							["b"] = 0,
							["g"] = 0,
							["r"] = 1,
						},
						["color3"] = {
							["g"] = 0,
							["b"] = 0,
						},
						["color1"] = {
							["g"] = 0.3882352941176471,
						},
					},
					["debuff-WeakenedSoul"] = {
						["type"] = "debuff",
						["color1"] = {
							["a"] = 1,
							["b"] = 0.9,
							["g"] = 0.2,
							["r"] = 0,
						},
						["spellName"] = 6788,
					},
					["buff-Grace-mine"] = {
						["color2"] = {
							["a"] = 1,
							["b"] = 0.8,
							["g"] = 0.8,
							["r"] = 0.8,
						},
						["type"] = "buff",
						["color3"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["color1"] = {
							["a"] = 1,
							["b"] = 0.6,
							["g"] = 0.6,
							["r"] = 0.6,
						},
						["colorCount"] = 3,
						["mine"] = true,
						["spellName"] = 77613,
					},
					["buff-InnerFire"] = {
						["missing"] = true,
						["type"] = "buff",
						["color1"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["spellName"] = 588,
					},
					["buff-DivineAegis"] = {
						["type"] = "buff",
						["color1"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["spellName"] = 47509,
					},
					["afk"] = {
						["color1"] = {
							["r"] = 0.5019607843137255,
							["g"] = 0.5019607843137255,
							["b"] = 0.5019607843137255,
						},
					},
					["buff-PrayerOfMending-mine"] = {
						["type"] = "buff",
						["mine"] = true,
						["color1"] = {
							["a"] = 1,
							["b"] = 0.2,
							["g"] = 0.2,
							["r"] = 1,
						},
						["color2"] = {
							["a"] = 0.4,
							["b"] = 0.4,
							["g"] = 1,
							["r"] = 1,
						},
						["color3"] = {
							["a"] = 1,
							["b"] = 0.6,
							["g"] = 0.6,
							["r"] = 1,
						},
						["colorCount"] = 5,
						["color4"] = {
							["a"] = 1,
							["b"] = 0.8,
							["g"] = 0.8,
							["r"] = 1,
						},
						["color5"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["spellName"] = 33076,
					},
					["health-current"] = {
						["color2"] = {
							["a"] = 0.7000000178813934,
							["g"] = 0,
							["r"] = 0,
						},
						["color3"] = {
							["a"] = 0.7000000178813934,
							["r"] = 0,
						},
						["color1"] = {
							["a"] = 0.5,
							["g"] = 0,
						},
					},
					["raid-icon-player"] = {
						["color1"] = {
							["g"] = 0.9607843137254902,
							["b"] = 0.1647058823529412,
						},
					},
					["friendcolor"] = {
						["colorHostile"] = true,
					},
					["health-deficit"] = {
						["threshold"] = 0,
					},
					["buff-Renew-mine"] = {
						["color1"] = {
							["a"] = 1,
							["b"] = 1,
							["g"] = 1,
							["r"] = 1,
						},
						["type"] = "buff",
						["mine"] = true,
						["spellName"] = 139,
					},
				},
			},
		},
	}
end