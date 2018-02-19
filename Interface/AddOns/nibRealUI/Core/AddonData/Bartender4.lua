local _, private = ...

-- RealUI --
local RealUI = private.RealUI

RealUI.AddOns.Bartender4 = function()
	_G.Bartender4DB = {
		["namespaces"] = {
			["ActionBars"] = {
				["profiles"] = {
					["RealUI"] = {
						["actionbars"] = {
							{
								["flyoutDirection"] = "DOWN",
								["version"] = 3,
								["position"] = {
									["y"] = -199.5,
									["x"] = -171.5,
									["point"] = "CENTER",
								},
								["padding"] = -9,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui]][overridebar][cursor]show;hide",
								},
							}, -- [1]
							{
								["padding"] = -9,
								["version"] = 3,
								["position"] = {
									["y"] = 89,
									["x"] = -171.5,
									["point"] = "BOTTOM",
								},
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
								},
							}, -- [2]
							{
								["hidemacrotext"] = true,
								["version"] = 3,
								["position"] = {
									["y"] = 62,
									["x"] = -171.5,
									["point"] = "BOTTOM",
								},
								["padding"] = -9,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
								},
							}, -- [3]
							{
								["flyoutDirection"] = "LEFT",
								["rows"] = 12,
								["version"] = 3,
								["fadeoutalpha"] = 0,
								["position"] = {
									["y"] = 334.5,
									["x"] = -36,
									["point"] = "RIGHT",
								},
								["padding"] = -9,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
								},
							}, -- [4]
							{
								["flyoutDirection"] = "LEFT",
								["rows"] = 12,
								["version"] = 3,
								["fadeoutalpha"] = 0,
								["position"] = {
									["y"] = 10.5,
									["x"] = -36,
									["point"] = "RIGHT",
								},
								["padding"] = -9,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
								},
							}, -- [5]
							{
								["enabled"] = false,
							}, -- [6]
							{
							}, -- [7]
							{
							}, -- [8]
							{
							}, -- [9]
							{
							}, -- [10]
						},
					},
					["RealUI-Healing"] = {
						["actionbars"] = {
							{
								["flyoutDirection"] = "DOWN",
								["version"] = 3,
								["position"] = {
									["y"] = -199.5,
									["x"] = -171.5,
									["point"] = "CENTER",
								},
								["padding"] = -9,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui]][overridebar][cursor]show;hide",
								},
							}, -- [1]
							{
								["padding"] = -9,
								["version"] = 3,
								["position"] = {
									["y"] = 89,
									["x"] = -171.5,
									["point"] = "BOTTOM",
								},
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
								},
							}, -- [2]
							{
								["hidemacrotext"] = true,
								["version"] = 3,
								["position"] = {
									["y"] = 62,
									["x"] = -171.5,
									["point"] = "BOTTOM",
								},
								["padding"] = -9,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][@focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
								},
							}, -- [3]
							{
								["flyoutDirection"] = "LEFT",
								["rows"] = 12,
								["version"] = 3,
								["fadeoutalpha"] = 0,
								["position"] = {
									["y"] = 334.5,
									["x"] = -36,
									["point"] = "RIGHT",
								},
								["padding"] = -9,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
								},
							}, -- [4]
							{
								["flyoutDirection"] = "LEFT",
								["rows"] = 12,
								["version"] = 3,
								["fadeoutalpha"] = 0,
								["position"] = {
									["y"] = 10.5,
									["x"] = -36,
									["point"] = "RIGHT",
								},
								["padding"] = -9,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
								},
							}, -- [5]
							{
								["enabled"] = false,
							}, -- [6]
							{
							}, -- [7]
							{
							}, -- [8]
							{
							}, -- [9]
							{
							}, -- [10]
						},
					},
				},
			},
			["ExtraActionBar"] = {
				["profiles"] = {
					["RealUI"] = {
						["position"] = {
							["y"] = 86,
							["x"] = 157.5,
							["point"] = "BOTTOM",
							["scale"] = 0.985,
						},
						["version"] = 3,
					},
					["RealUI-Healing"] = {
						["position"] = {
							["y"] = 86,
							["x"] = 157.5,
							["point"] = "BOTTOM",
							["scale"] = 0.985,
						},
						["version"] = 3,
					},
				},
			},
			["MicroMenu"] = {
				["profiles"] = {
					["RealUI"] = {
						["enabled"] = false,
					},
					["RealUI-Healing"] = {
						["enabled"] = false,
					},
				},
			},
			["ZoneAbilityBar"] = {
				["profiles"] = {
					["RealUI"] = {
						["position"] = {
							["y"] = 86,
							["x"] = -157.5,
							["point"] = "BOTTOM",
							["scale"] = 0.985,
						},
						["version"] = 3,
					},
				},
			},
			["BagBar"] = {
				["profiles"] = {
					["RealUI"] = {
						["enabled"] = false,
					},
					["RealUI-Healing"] = {
						["enabled"] = false,
					},
				},
			},
			["StanceBar"] = {
				["profiles"] = {
					["RealUI"] = {
						["version"] = 3,
						["position"] = {
							["y"] = 49,
							["x"] = -157.5,
							["point"] = "BOTTOM",
							["scale"] = 1,
							["growHorizontal"] = "LEFT",
						},
						["fadeoutalpha"] = 0,
						["padding"] = -7,
						["visibility"] = {
							["custom"] = true,
							["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
						},
					},
					["RealUI-Healing"] = {
						["version"] = 3,
						["position"] = {
							["y"] = 49,
							["x"] = -157.5,
							["point"] = "BOTTOM",
							["scale"] = 1,
							["growHorizontal"] = "LEFT",
						},
						["fadeoutalpha"] = 0,
						["padding"] = -7,
						["visibility"] = {
							["custom"] = true,
							["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
						},
					},
				},
			},
			["Vehicle"] = {
				["profiles"] = {
					["RealUI"] = {
						["version"] = 3,
						["position"] = {
							["y"] = -59.5,
							["x"] = -36,
							["point"] = "TOPRIGHT",
							["scale"] = 0.84,
						},
					},
					["RealUI-Healing"] = {
						["version"] = 3,
						["position"] = {
							["y"] = -59.5,
							["x"] = -36,
							["point"] = "TOPRIGHT",
							["scale"] = 0.84,
						},
					},
				},
			},
			["PetBar"] = {
				["profiles"] = {
					["RealUI"] = {
						["rows"] = 10,
						["version"] = 3,
						["position"] = {
							["y"] = 124.5,
							["x"] = -8,
							["point"] = "LEFT",
						},
						["padding"] = -7,
						["visibility"] = {
							["custom"] = true,
							["customdata"] = "[nopet][petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
						},
						["fadeoutalpha"] = 0,
					},
					["RealUI-Healing"] = {
						["rows"] = 10,
						["version"] = 3,
						["position"] = {
							["y"] = 124.5,
							["x"] = -8,
							["point"] = "LEFT",
						},
						["padding"] = -7,
						["visibility"] = {
							["custom"] = true,
							["customdata"] = "[nopet][petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
						},
						["fadeoutalpha"] = 0,
					},
				},
			},
		},
		["profileKeys"] = {
		},
		["profiles"] = {
			["RealUI"] = {
				["minimapIcon"] = {
					["hide"] = true,
				},
			},
			["RealUI-Healing"] = {
				["minimapIcon"] = {
					["hide"] = true,
				},
			},
		},
	}
end
