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
		},
		["profiles"] = {
			["RealUI"] = {
				["fonts"] = {
					["options"] = {
						["font"] = "pixel_small",
						["onesize"] = true,
						["monochrome"] = true,
						["fontscale"] = 1,
					},
				},
				["general"] = {
					["bartexture"] = "Flat",
				},
				["fade"] = {
					["smooth"] = false,
				},
			},
		},
	}
end
