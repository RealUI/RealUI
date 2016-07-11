local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI

RealUI.LoadAddOnData_Bartender4 = function()
	_G.Bartender4DB = {
		["namespaces"] = {
			["ActionBars"] = {
				["profiles"] = {
					["RealUI"] = {
						["actionbars"] = {
							{
								["flyoutDirection"] = false,
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Backdrop"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											0, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["buttons"] = 12,
								["version"] = 3,
								["fadeoutalpha"] = 0,
								["position"] = {
									["y"] = -199.5,
									["x"] = -144.5,
									["point"] = "CENTER",
								},
								["padding"] = -9,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui]][overridebar][cursor]show;hide",
								},
							}, -- [1]
							{
								["flyoutDirection"] = false,
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Backdrop"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											0, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["padding"] = -9,
								["version"] = 3,
								["position"] = {
									["y"] = 64,
									["x"] = -171.5,
									["point"] = "BOTTOM",
								},
								["fadeoutalpha"] = 0,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
									["vehicleui"] = false,
								},
								["states"] = {
									["default"] = 2,
									["actionbar"] = true,
									["stance"] = {
										["DRUID"] = {
											["prowl"] = 3,
											["cat"] = 3,
											["bear"] = 4,
											["moonkin"] = 2,
											["treeoflife"] = 2,
										},
										["ROGUE"] = {
											["stealth"] = 8,
										},
									},
								},
							}, -- [2]
							{
								["flyoutDirection"] = false,
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Backdrop"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											0, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["padding"] = -9,
								["version"] = 3,
								["position"] = {
									["y"] = 37,
									["x"] = -171.5,
									["point"] = "BOTTOM",
								},
								["fadeoutalpha"] = 0,
								["hidemacrotext"] = true,
								["visibility"] = {
									["always"] = false,
									["custom"] = true,
									["possess"] = false,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
									["nocombat"] = false,
									["vehicleui"] = false,
								},
							}, -- [3]
							{
								["flyoutDirection"] = "LEFT",
								["showgrid"] = true,
								["rows"] = 12,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Backdrop"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											0, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["buttons"] = 12,
								["padding"] = -9,
								["version"] = 3,
								["position"] = {
									["y"] = 280.5,
									["x"] = -36,
									["point"] = "RIGHT",
								},
								["fadeoutalpha"] = 0,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["possess"] = false,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
									["nocombat"] = false,
									["vehicleui"] = false,
								},
							}, -- [4]
							{
								["flyoutDirection"] = "LEFT",
								["showgrid"] = true,
								["rows"] = 12,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Backdrop"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											0, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["buttons"] = 12,
								["padding"] = -9,
								["version"] = 3,
								["position"] = {
									["y"] = 10.5,
									["x"] = -36,
									["point"] = "RIGHT",
								},
								["fadeoutalpha"] = 0,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
									["vehicleui"] = false,
								},
							}, -- [5]
							{
								["flyoutDirection"] = "RIGHT",
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["enabled"] = false,
								["padding"] = -9,
								["fadeoutalpha"] = 0,
								["position"] = {
									["y"] = 0,
									["x"] = -171.5,
									["point"] = "TOP",
								},
								["version"] = 3,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "",
									["vehicleui"] = false,
								},
							}, -- [6]
							{
								["showgrid"] = true,
								["skin"] = {
									["Gloss"] = 0.5,
									["Backdrop"] = false,
									["ID"] = "PixelSkin",
								},
								["version"] = 3,
								["position"] = {
									["y"] = 260.5,
									["x"] = -177.5,
									["point"] = "CENTER",
								},
								["padding"] = -8,
								["visibility"] = {
									["vehicleui"] = false,
								},
							}, -- [7]
							{
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["fadeoutalpha"] = 0,
								["version"] = 3,
								["position"] = {
									["y"] = 290.5,
									["x"] = -177.5,
									["point"] = "CENTER",
								},
								["padding"] = -8,
								["visibility"] = {
									["vehicleui"] = false,
								},
							}, -- [8]
							{
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["fadeoutalpha"] = 0,
								["version"] = 3,
								["position"] = {
									["y"] = 320.5,
									["x"] = -177.5,
									["point"] = "CENTER",
								},
								["padding"] = -8,
								["visibility"] = {
									["custom"] = false,
									["customdata"] = "",
									["vehicleui"] = false,
								},
							}, -- [9]
							{
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["fadeoutalpha"] = 0,
								["version"] = 3,
								["position"] = {
									["y"] = 350.5,
									["x"] = -177.5,
									["point"] = "CENTER",
								},
								["padding"] = -8,
								["visibility"] = {
									["custom"] = false,
									["customdata"] = "",
									["vehicleui"] = false,
								},
							}, -- [10]
						},
					},
					["RealUI-Healing"] = {
						["actionbars"] = {
							{
								["flyoutDirection"] = false,
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Backdrop"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											0, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["buttons"] = 12,
								["version"] = 3,
								["fadeoutalpha"] = 0,
								["position"] = {
									["y"] = -199.5,
									["x"] = -144.5,
									["point"] = "CENTER",
								},
								["hidemacrotext"] = true,
								["padding"] = -9,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][overridebar][cursor]show;hide",
								},
							}, -- [1]
							{
								["flyoutDirection"] = false,
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Backdrop"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											0, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["fadeoutalpha"] = 0.25,
								["version"] = 3,
								["position"] = {
									["y"] = 64,
									["x"] = -171.5,
									["point"] = "BOTTOM",
								},
								["hidemacrotext"] = true,
								["padding"] = -9,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
									["vehicleui"] = false,
								},
								["states"] = {
									["default"] = 2,
									["actionbar"] = true,
									["stance"] = {
										["ROGUE"] = {
											["stealth"] = 8,
										},
										["DRUID"] = {
											["prowl"] = 3,
											["cat"] = 3,
											["bear"] = 4,
											["moonkin"] = 2,
											["treeoflife"] = 2,
										},
									},
								},
							}, -- [2]
							{
								["flyoutDirection"] = false,
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Backdrop"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											0, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["hidemacrotext"] = true,
								["fadeoutalpha"] = 0.25,
								["position"] = {
									["y"] = 37,
									["x"] = -171.5,
									["point"] = "BOTTOM",
								},
								["version"] = 3,
								["padding"] = -9,
								["visibility"] = {
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui][cursor]show;hide",
									["custom"] = true,
									["possess"] = false,
									["always"] = false,
									["nocombat"] = false,
									["vehicleui"] = false,
								},
							}, -- [3]
							{
								["flyoutDirection"] = "LEFT",
								["showgrid"] = true,
								["rows"] = 12,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Backdrop"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											0, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["buttons"] = 12,
								["hidemacrotext"] = true,
								["version"] = 3,
								["position"] = {
									["y"] = 280.5,
									["x"] = -36,
									["point"] = "RIGHT",
								},
								["fadeoutalpha"] = 0,
								["padding"] = -9,
								["visibility"] = {
									["custom"] = true,
									["possess"] = false,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
									["nocombat"] = false,
									["vehicleui"] = false,
								},
							}, -- [4]
							{
								["flyoutDirection"] = "LEFT",
								["showgrid"] = true,
								["rows"] = 12,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
										["Backdrop"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											0, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["buttons"] = 12,
								["hidemacrotext"] = true,
								["fadeoutalpha"] = 0,
								["position"] = {
									["y"] = 10.5,
									["x"] = -36,
									["point"] = "RIGHT",
								},
								["version"] = 3,
								["padding"] = -9,
								["visibility"] = {
									["custom"] = true,
									["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl][cursor]show;fade",
									["vehicleui"] = false,
								},
							}, -- [5]
							{
								["flyoutDirection"] = "RIGHT",
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["enabled"] = false,
								["padding"] = -9,
								["version"] = 3,
								["position"] = {
									["y"] = 0,
									["x"] = -171.5,
									["point"] = "TOP",
								},
								["fadeoutalpha"] = 0,
								["hidemacrotext"] = true,
								["visibility"] = {
									["custom"] = false,
									["customdata"] = "[mod:ctrl][cursor]show;fade",
									["vehicleui"] = false,
								},
							}, -- [6]
							{
								["showgrid"] = true,
								["skin"] = {
									["Gloss"] = 0.5,
									["Backdrop"] = false,
									["ID"] = "PixelSkin",
								},
								["version"] = 3,
								["position"] = {
									["y"] = 260.5,
									["x"] = -177.5,
									["point"] = "CENTER",
								},
								["padding"] = -8,
								["visibility"] = {
									["vehicleui"] = false,
								},
							}, -- [7]
							{
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["fadeoutalpha"] = 0,
								["version"] = 3,
								["position"] = {
									["y"] = 290.5,
									["x"] = -177.5,
									["point"] = "CENTER",
								},
								["padding"] = -8,
								["visibility"] = {
									["vehicleui"] = false,
								},
							}, -- [8]
							{
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["fadeoutalpha"] = 0,
								["version"] = 3,
								["position"] = {
									["y"] = 320.5,
									["x"] = -177.5,
									["point"] = "CENTER",
								},
								["padding"] = -8,
								["visibility"] = {
									["custom"] = false,
									["customdata"] = "",
									["vehicleui"] = false,
								},
							}, -- [9]
							{
								["showgrid"] = true,
								["skin"] = {
									["Colors"] = {
										["Normal"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Pushed"] = {
											0, -- [1]
											0, -- [2]
											0, -- [3]
											0.4900000095367432, -- [4]
										},
										["Highlight"] = {
											0.3529411764705882, -- [1]
											0.3529411764705882, -- [2]
											0.3529411764705882, -- [3]
											1, -- [4]
										},
										["Gloss"] = {
											1, -- [1]
											1, -- [2]
											1, -- [3]
											1, -- [4]
										},
										["Border"] = {
											0, -- [1]
											0.5607843137254902, -- [2]
											0, -- [3]
											1, -- [4]
										},
									},
									["ID"] = "PixelSkin",
									["Backdrop"] = false,
								},
								["fadeoutalpha"] = 0,
								["version"] = 3,
								["position"] = {
									["y"] = 350.5,
									["x"] = -177.5,
									["point"] = "CENTER",
								},
								["padding"] = -8,
								["visibility"] = {
									["custom"] = false,
									["customdata"] = "",
									["vehicleui"] = false,
								},
							}, -- [10]
						},
					},
				},
			},
			["LibDualSpec-1.0"] = {
			},
			["ExtraActionBar"] = {
				["profiles"] = {
					["RealUI"] = {
						["position"] = {
							["y"] = 61,
							["x"] = 157.5,
							["point"] = "BOTTOM",
							["scale"] = 0.985,
						},
						["version"] = 3,
					},
					["RealUI-Healing"] = {
						["position"] = {
							["y"] = 61,
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
						["position"] = {
							["y"] = 5.500012616809954,
							["x"] = -130.9999864342934,
							["point"] = "TOP",
							["scale"] = 1,
						},
						["version"] = 3,
						["skin"] = {
							["ID"] = "Entropy: Silver",
							["Backdrop"] = false,
							["Gloss"] = 0.25,
						},
						["fadeoutalpha"] = 0,
					},
					["RealUI-Healing"] = {
						["enabled"] = false,
						["position"] = {
							["y"] = 5.500012616809954,
							["x"] = -130.9999864342934,
							["point"] = "TOP",
							["scale"] = 1,
						},
						["fadeoutalpha"] = 0,
						["skin"] = {
							["Gloss"] = 0.25,
							["Backdrop"] = false,
							["ID"] = "Entropy: Silver",
						},
						["version"] = 3,
					},
				},
			},
			["XPBar"] = {
				["profiles"] = {
					["RealUI"] = {
						["version"] = 3,
						["position"] = {
							["y"] = 3.999969916464124,
							["x"] = 374.4348705856189,
							["point"] = "TOPLEFT",
						},
						["fadeoutalpha"] = 0,
					},
					["RealUI-Healing"] = {
						["fadeoutalpha"] = 0,
						["position"] = {
							["y"] = 3.999969916464124,
							["x"] = 374.4348705856189,
							["point"] = "TOPLEFT",
						},
						["version"] = 3,
					},
				},
			},
			["MultiCast"] = {
				["profiles"] = {
					["RealUI"] = {
						["visibility"] = {
							["customdata"] = "[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui]show;hide",
							["custom"] = true,
						},
						["version"] = 3,
						["position"] = {
							["y"] = -162.5,
							["x"] = -88.5,
							["point"] = "CENTER",
							["scale"] = 0.9,
						},
					},
					["RealUI-Healing"] = {
						["visibility"] = {
							["customdata"] = "[mod:ctrl][target=focus,exists][harm,nodead][combat][group:party][group:raid][vehicleui]show;hide",
							["custom"] = true,
						},
						["version"] = 3,
						["position"] = {
							["y"] = 89,
							["x"] = -88.5,
							["point"] = "BOTTOM",
							["scale"] = 0.9000000357627869,
						},
					},
				},
			},
			["BlizzardArt"] = {
				["profiles"] = {
				},
			},
			["BagBar"] = {
				["profiles"] = {
					["RealUI"] = {
						["enabled"] = false,
						["skin"] = {
							["ID"] = "Entropy: Adamantite",
						},
						["position"] = {
							["y"] = 1.500006712564641,
							["x"] = 58.50000987555336,
							["point"] = "CENTER",
						},
						["version"] = 3,
					},
					["RealUI-Healing"] = {
						["enabled"] = false,
						["position"] = {
							["y"] = 1.500006712564641,
							["x"] = 58.50000987555336,
							["point"] = "CENTER",
						},
						["skin"] = {
							["ID"] = "Entropy: Adamantite",
						},
						["version"] = 3,
					},
				},
			},
			["StanceBar"] = {
				["profiles"] = {
					["RealUI"] = {
						["version"] = 3,
						["skin"] = {
							["Colors"] = {
								["Normal"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Pushed"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									0.4900000095367432, -- [4]
								},
								["Highlight"] = {
									0.3529411764705882, -- [1]
									0.3529411764705882, -- [2]
									0.3529411764705882, -- [3]
									1, -- [4]
								},
								["Gloss"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									1, -- [4]
								},
								["Border"] = {
									0, -- [1]
									0.5607843137254902, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Backdrop"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									0, -- [4]
								},
							},
							["ID"] = "PixelSkin",
							["Backdrop"] = false,
						},
						["fadeoutalpha"] = 0,
						["padding"] = -7,
						["visibility"] = {
							["custom"] = true,
							["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
						},
						["position"] = {
							["y"] = 27,
							["x"] = -264,
							["point"] = "BOTTOMRIGHT",
							["scale"] = 1,
							["growHorizontal"] = "LEFT",
						},
					},
					["RealUI-Healing"] = {
						["fadeoutalpha"] = 0,
						["position"] = {
							["y"] = 27,
							["x"] = -264,
							["point"] = "BOTTOMRIGHT",
							["scale"] = 1,
							["growHorizontal"] = "LEFT",
						},
						["version"] = 3,
						["padding"] = -7,
						["visibility"] = {
							["custom"] = true,
							["customdata"] = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
						},
						["skin"] = {
							["Colors"] = {
								["Normal"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Pushed"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									0.4900000095367432, -- [4]
								},
								["Highlight"] = {
									0.3529411764705882, -- [1]
									0.3529411764705882, -- [2]
									0.3529411764705882, -- [3]
									1, -- [4]
								},
								["Gloss"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									1, -- [4]
								},
								["Border"] = {
									0, -- [1]
									0.5607843137254902, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Backdrop"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									0, -- [4]
								},
							},
							["ID"] = "PixelSkin",
							["Backdrop"] = false,
						},
					},
				},
			},
			["Vehicle"] = {
				["profiles"] = {
					["RealUI"] = {
						["version"] = 3,
						["skin"] = {
							["Colors"] = {
								["Normal"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Pushed"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									0.4900000095367432, -- [4]
								},
								["Highlight"] = {
									0.3529411764705882, -- [1]
									0.3529411764705882, -- [2]
									0.3529411764705882, -- [3]
									1, -- [4]
								},
								["Gloss"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									1, -- [4]
								},
								["Border"] = {
									0, -- [1]
									0.5607843137254902, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Backdrop"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									0, -- [4]
								},
							},
							["ID"] = "PixelSkin",
							["Backdrop"] = false,
						},
						["padding"] = 1,
						["position"] = {
							["y"] = -54.5,
							["x"] = -31,
							["point"] = "TOPRIGHT",
							["scale"] = 0.84,
						},
					},
					["RealUI-Healing"] = {
						["version"] = 3,
						["position"] = {
							["y"] = -54.5,
							["x"] = -31,
							["point"] = "TOPRIGHT",
							["scale"] = 0.84,
						},
						["skin"] = {
							["Colors"] = {
								["Normal"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Pushed"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									0.4900000095367432, -- [4]
								},
								["Highlight"] = {
									0.3529411764705882, -- [1]
									0.3529411764705882, -- [2]
									0.3529411764705882, -- [3]
									1, -- [4]
								},
								["Gloss"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									1, -- [4]
								},
								["Border"] = {
									0, -- [1]
									0.5607843137254902, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Backdrop"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									0, -- [4]
								},
							},
							["ID"] = "PixelSkin",
							["Backdrop"] = false,
						},
					},
				},
			},
			["PetBar"] = {
				["profiles"] = {
					["RealUI"] = {
						["rows"] = 10,
						["fadeoutalpha"] = 0,
						["skin"] = {
							["Colors"] = {
								["Normal"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Pushed"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									0.4900000095367432, -- [4]
								},
								["Highlight"] = {
									0.3529411764705882, -- [1]
									0.3529411764705882, -- [2]
									0.3529411764705882, -- [3]
									1, -- [4]
								},
								["Gloss"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									1, -- [4]
								},
								["Border"] = {
									0, -- [1]
									0.5607843137254902, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Backdrop"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									0, -- [4]
								},
							},
							["ID"] = "PixelSkin",
							["Backdrop"] = false,
						},
						["version"] = 3,
						["padding"] = -7,
						["visibility"] = {
							["custom"] = true,
							["customdata"] = "[nopet][petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
							["stance"] = {
								[0] = false,
							},
						},
						["position"] = {
							["y"] = 124.5,
							["x"] = -8,
							["point"] = "LEFT",
						},
					},
					["RealUI-Healing"] = {
						["rows"] = 10,
						["fadeoutalpha"] = 0,
						["skin"] = {
							["Colors"] = {
								["Normal"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Pushed"] = {
									0, -- [1]
									0, -- [2]
									0, -- [3]
									0.4900000095367432, -- [4]
								},
								["Highlight"] = {
									0.3529411764705882, -- [1]
									0.3529411764705882, -- [2]
									0.3529411764705882, -- [3]
									1, -- [4]
								},
								["Gloss"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									1, -- [4]
								},
								["Border"] = {
									0, -- [1]
									0.5607843137254902, -- [2]
									0, -- [3]
									1, -- [4]
								},
								["Backdrop"] = {
									1, -- [1]
									1, -- [2]
									1, -- [3]
									0, -- [4]
								},
							},
							["ID"] = "PixelSkin",
							["Backdrop"] = false,
						},
						["version"] = 3,
						["padding"] = -7,
						["visibility"] = {
							["custom"] = true,
							["customdata"] = "[nopet][petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;[mod:ctrl]show;fade",
							["stance"] = {
								[0] = false,
							},
						},
						["position"] = {
							["y"] = 124.5,
							["x"] = -8,
							["point"] = "LEFT",
						},
					},
				},
			},
			["RepBar"] = {
				["profiles"] = {
					["RealUI"] = {
						["position"] = {
							["y"] = 10.00008673617606,
							["x"] = 374.4348705856189,
							["point"] = "LEFT",
						},
						["version"] = 3,
					},
					["RealUI-Healing"] = {
						["position"] = {
							["y"] = 10.00008673617606,
							["x"] = 374.4348705856189,
							["point"] = "LEFT",
						},
						["version"] = 3,
					},
				},
			},
		},
		["profileKeys"] = {
			["Real - Zul'jin"] = "RealUI-Healing",
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
