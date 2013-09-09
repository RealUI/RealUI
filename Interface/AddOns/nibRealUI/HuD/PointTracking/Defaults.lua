local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

function nibRealUI:GetPointTrackingDefaults()
	local defaults = {
	
		profile = {
			updatespeed = 8,
			combatfader = {
				enabled = true,
				opacity = {
					incombat = 1,
					hurt = .8,
					target = .8,
					outofcombat = .3,
				},
			},
		-- CLASS
			["**"] = {
				types = {
				-- Point Display type
					["**"] = {
						enabled = true,
						configmode = {
							enabled = false,
							count = 2,
						},
						general = {
							hideui = false,
							hideempty = true,
							smarthide = false,
							hidein = {
								vehicle = true,
								spec = 1,	-- 1 = Disabled, 2 = Primary, 3 = Secondary
							},
							direction = {
								reverse = false,
							},
						},
						position = {
							x = 0,
							y = 0,
							side = "LEFT",
							framelevel = {
								strata = "MEDIUM",
								level = 2,
							},
						},
						bars = {
							custom = false,
							position = {
								gap = -2,
							},
							size = {
								width = 16,
								height = 16,
							},
							bg = {
								empty = {
									texture = "Round_Large_BG",
									color = {r = 1, g = 1, b = 1, a = 0.2},
								},
								full = {
									texture = "Round_Large_BG",
									color = {r = 1, g = 1, b = 1, a = 0.8},
									maxcolor = {r = 1, g = 1, b = 1, a = 1},
								},
							},
							surround = {
								texture = "Round_Large_Surround",
								color = {r = 0, g = 0, b = 0, a = 1},
							},
						},
					},
				},
			},
			----------
			["GENERAL"] = {
				["types"] = {
					["cp"] = {
						["bars"] = {
							["bg"] = {
								["full"] = {
									["color"] = {
										["a"] = 0.8,
									},
								},
							},
						},
						["general"] = {
							["hidein"] = {
								["vehicle"] = false,
							},
							["direction"] = {
								["reverse"] = true,
							},
						},
						["position"] = {
							["side"] = "RIGHT",
						},
					},
				},
			},
			--------
			["MONK"] = {
				["types"] = {
					["chi"] = {
						["bars"] = {
							["bg"] = {
								["full"] = {
									["color"] = {
										["a"] = 0.8,
										["b"] = 0.6,
										["r"] = 0,
									},
									["maxcolor"] = {
										["b"] = 0.6,
										["r"] = 0,
									},
								},
							},
						},
						["position"] = {
							["y"] = 0,
							["x"] = 0,
						},
					},
				},
			},
			--------
			["PALADIN"] = {
				["types"] = {
					["hp"] = {
						["bars"] = {
							["size"] = {
								["height"] = 64,
								["width"] = 64,
							},
							["bg"] = {
								["full"] = {
									["color"] = {
										["a"] = 0.9,
										["b"] = 0.5,
									},
									["maxcolor"] = {
										["b"] = 0.2,
									},
								},
							},
							["custom"] = true,
							["position"] = {
								["gap"] = -64,
							},
						},
						["position"] = {
							["y"] = -18,
							["side"] = "BOTTOM",
						},
					},
				},
			},
			--------
			["PRIEST"] = {
				["types"] = {
					["so"] = {
						["bars"] = {
							["bg"] = {
								["full"] = {
									["color"] = {
										["b"] = 0.7215686274509804,
										["g"] = 0.3254901960784314,
										["r"] = 0.4156862745098039,
									},
									["maxcolor"] = {
										["b"] = 0.9215686274509803,
										["g"] = 0.4156862745098039,
										["r"] = 0.5333333333333333,
									},
								},
							},
						},
						["position"] = {
							["y"] = 0,
							["x"] = 0,
						},
					},
				},
			},
			--------
			["ROGUE"] = {
				["types"] = {
					["ap"] = {
						["bars"] = {
							["bg"] = {
								["full"] = {
									["color"] = {
										["a"] = 1,
										["r"] = 0.5,
										["g"] = 0,
										["b"] = 0,
									},
									["maxcolor"] = {
										["r"] = 1,
										["g"] = 0,
										["b"] = 0,
									},
								},
							},
						},
						["general"] = {
							["direction"] = {
								["reverse"] = true,
							},
						},
						["position"] = {
							["y"] = 0,
							["x"] = 0,
							["side"] = "RIGHT",
							["framelevel"] = {
								["level"] = 4,
							},
						},
					},
				},
			},
			--------
			["WARLOCK"] = {
				["types"] = {
					["be"] = {
						["bars"] = {
							["surround"] = {
								["color"] = {
									["r"] = 1,
									["g"] = 1,
									["b"] = 1,
								},
								["texture"] = "Soul_Shard_Surround",
							},
							["size"] = {
								["width"] = 32,
							},
							["bg"] = {
								["full"] = {
									["color"] = {
										["a"] = 1,
										["r"] = 0.9137254901960784,
										["g"] = 0.1686274509803922,
										["b"] = 0.04705882352941176,
									},
									["maxcolor"] = {
										["r"] = 0.9137254901960784,
										["g"] = 0.1686274509803922,
										["b"] = 0.04705882352941176,
									},
									["texture"] = "Soul_Shard_BG",
								},
								["empty"] = {
									["texture"] = "Soul_Shard_BG",
								},
							},
							["position"] = {
								["gap"] = -14,
							},
						},
						["general"] = {
							["smarthide"] = true,
						},
						["position"] = {
							["y"] = 0,
							["x"] = 0,
						},
					},
					["ss"] = {
						["combatfader"] = {
							["enabled"] = true,
							["opacity"] = {
								["outofcombat"] = 0,
							},
						},
						["bars"] = {
							["surround"] = {
								["color"] = {
									["r"] = 1,
									["g"] = 1,
									["b"] = 1,
								},
								["texture"] = "Soul_Shard_Surround",
							},
							["size"] = {
								["width"] = 32,
							},
							["bg"] = {
								["full"] = {
									["color"] = {
										["a"] = 1,
										["r"] = 0.5294117647058824,
										["g"] = 0.3803921568627451,
										["b"] = 0.8274509803921568,
									},
									["maxcolor"] = {
										["g"] = 0.4509803921568628,
										["r"] = 0.6352941176470588,
									},
									["texture"] = "Soul_Shard_BG",
								},
								["empty"] = {
									["texture"] = "Soul_Shard_BG",
								},
							},
							["position"] = {
								["gap"] = -14,
							},
						},
						["general"] = {
							["smarthide"] = true,
						},
						["position"] = {
							["y"] = 0,
							["x"] = 0,
						},
					},
				},
			},
		},
	}
	
	return defaults
end