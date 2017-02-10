local _, private = ...

-- RealUI --
local RealUI = private.RealUI

RealUI.AddOns.Kui_Nameplates = function()
	_G.KuiNameplatesGDB = {
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
