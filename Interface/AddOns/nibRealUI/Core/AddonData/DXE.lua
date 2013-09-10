local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

nibRealUI.LoadAddOnData_DXE = function()
	DXEIconDB = {
		["hide"] = true,
	}
	DXEDB = {
		["namespaces"] = {
			["Arrows"] = {
			},
			["AutoResponder"] = {
			},
			["RDB"] = {
			},
			["LibDualSpec-1.0"] = {
			},
			["Distributor"] = {
			},
			["RaidIcons"] = {
			},
			["Alerts"] = {
				["profiles"] = {
					["RealUI"] = {
						["BarFontSize"] = 8,
						["DebuffBars"] = false,
						["CenterTextWidth"] = 150,
						["TopScale"] = 1,
						["TopGrowth"] = "UP",
						["DebuffTextWidth"] = 150,
						["CenterBarWidth"] = 220,
						["TopAlpha"] = 0.5,
						["TimerXOffset"] = 3,
						["ShowIconBorder"] = false,
						["DebuffBarWidth"] = 220,
						["CenterScale"] = 1,
						["BarHeight"] = 25,
						["TopTextWidth"] = 155,
						["TopBarWidth"] = 220,
					},
				},
			},
		},
		["profileKeys"] = {
			["Real - Zul'jin"] = "RealUI",
		},
		["profiles"] = {
			["RealUI"] = {
				["Globals"] = {
					["BackgroundTexture"] = "Plain",
					["BarTexture"] = "Plain",
					["Border"] = "Seerah Solid",
					["Font"] = "pixel_small",
					["BorderEdgeSize"] = 1,
					["BorderColor"] = {
						0, -- [1]
						0, -- [2]
						0, -- [3]
					},
					["BackgroundColor"] = {
						0.085, -- [1]
						0.085, -- [2]
						0.085, -- [3]
						0.9, -- [4]
					},
					["BackgroundInset"] = 1,
				},
				["TopMessageAnchor"] = {
					["TopMessageFont"] = "Standard",
					["TopMessageSize"] = 30,
				},
				["InformMessageAnchor"] = {
					["InformMessageFont"] = "Standard",
				},
				["MessageAnchor"] = {
					["MessageFont"] = "Standard",
				},
				["AlternatePower"] = {
					["AutoPopup"] = false,
					["AutoHide"] = false,
				},
				["Pane"] = {
					["Show"] = false,
				},
				["Scales"] = {
					["DXEWindowRadarFrame"] = 0.9333340525627136,
				},
				["Dimensions"] = {
					["DXEWindowRadar"] = {
						["height"] = 140.0000305175781,
						["width"] = 140.0001068115234,
					},
				},
				["Positions"] = {
					["DXEArrowsAnchor3"] = {
						["yOfs"] = -80,
						["xOfs"] = 0.5,
					},
					["DXEArrowsAnchor2"] = {
						["yOfs"] = -40,
						["xOfs"] = 0.5,
					},
					["DXEArrowsAnchor1"] = {
						["yOfs"] = 0,
						["xOfs"] = 0.5,
					},
					["DXEAlertsTopStackAnchor"] = {
						["point"] = "CENTER",
						["relativePoint"] = "CENTER",
						["yOfs"] = 248,
						["xOfs"] = 330.5,
					},
					["DXEAlertsCenterStackAnchor"] = {
						["point"] = "CENTER",
						["relativePoint"] = "CENTER",
						["yOfs"] = 248,
						["xOfs"] = -305.5,
					},
					["DXEAlertsDebuffStackAnchor"] = {
						["point"] = "TOPLEFT",
						["relativePoint"] = "TOPLEFT",
						["yOfs"] = -135.0002593994141,
						["xOfs"] = 286.5000305175781,
					},
					["DXEAlertsInformStackAnchor"] = {
						["yOfs"] = 36,
						["xOfs"] = -284.0000915527344,
					},
					["DXEAlertsMessageStackAnchor"] = {
						["yOfs"] = 43,
						["xOfs"] = -12.5,
					},
					["DXEAlertsWarningStackAnchor"] = {
						["yOfs"] = 134,
						["xOfs"] = 0,
					},
					["DXEWindowRadar"] = {
						["point"] = "BOTTOM",
						["relativePoint"] = "BOTTOM",
						["yOfs"] = 4,
						["xOfs"] = -234.5,
					},
				},
			},
		},
	}
end