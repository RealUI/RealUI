local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

nibRealUI.LoadAddOnData_Kui_Nameplates = function()
	KuiNameplatesGDB = {
		["namespaces"] = {
			["CastBar"] = {
			},
			["ComboPoints"] = {
			},
			["CastWarnings"] = {
			},
			["Auras"] = {
				["profiles"] = {
					["RealUI"] = {
						["enabled"] = true,
					},
				},
			},
		},
		["profileKeys"] = {
			["Real - Zul'jin"] = "RealUI",
		},
		["profiles"] = {
			["RealUI"] = {
				["fonts"] = {
					["options"] = {
						["font"] = "pixel_small",
						["onesize"] = true,
						["monochrome"] = true,
						["fontscale"] = 0.6243767738342285,
					},
				},
				["fade"] = {
					["smooth"] = false,
				},
			},
		},
	}
end