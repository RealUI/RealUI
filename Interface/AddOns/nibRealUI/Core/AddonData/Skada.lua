local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

nibRealUI.LoadAddOnData_Skada = function()
	SkadaDB = {
		["namespaces"] = {
			["LibDualSpec-1.0"] = {
			},
		},
		["profileKeys"] = {
			["Real - Zul'jin"] = "RealUI",
		},
		["profiles"] = {
			["RealUI"] = {
				["modules"] = {
					["notankwarnings"] = true,
				},
				["windows"] = {
					{
						["classicons"] = false,
						["barslocked"] = true,
						["y"] = 22.5,
						["x"] = -32,
						["title"] = {
							["color"] = {
								["a"] = 0,
								["b"] = 0.3019607843137255,
								["g"] = 0.1058823529411765,
								["r"] = 0.1058823529411765,
							},
							["font"] = "pixel_small",
							["fontsize"] = 8,
							["height"] = 17,
							["fontflags"] = "OUTLINEMONOCHROME",
							["texture"] = "Flat",
						},
						["barfontflags"] = "OUTLINEMONOCHROME",
						["barbgcolor"] = {
							["a"] = 0,
							["r"] = 0.3019607843137255,
							["g"] = 0.3019607843137255,
							["b"] = 0.3019607843137255,
						},
						["barcolor"] = {
							["r"] = 0.05098039215686274,
							["g"] = 0.05098039215686274,
							["b"] = 0.05098039215686274,
						},
						["barorientation"] = 3,
						["mode"] = "Buff uptimes",
						["spark"] = false,
						["bartexture"] = "Plain80",
						["barwidth"] = 190,
						["point"] = "BOTTOMRIGHT",
						["barfontsize"] = 8,
						["background"] = {
							["color"] = {
								["a"] = 0,
								["b"] = 0.5019607843137255,
							},
							["height"] = 150,
						},
						["barfont"] = "pixel_small",
					}, -- [1]
				},
				["icon"] = {
					["hide"] = true,
				},
				["report"] = {
					["channel"] = "Guild",
				},
				["columns"] = {
					["Healing_Healing"] = false,
					["Damage_Damage"] = false,
				},
				["hidesolo"] = true,
				["hidedisables"] = false,
				["onlykeepbosses"] = true,
			},
			["Default"] = {
				["modules"] = {
					["notankwarnings"] = true,
				},
				["windows"] = {
					{
						["y"] = 175.5,
						["x"] = 0,
						["barslocked"] = true,
						["bartexture"] = "Flat",
						["point"] = "BOTTOMRIGHT",
						["set"] = "total",
					}, -- [1]
				},
				["icon"] = {
					["hide"] = true,
				},
				["onlykeepbosses"] = true,
			},
		},
	}
end