local L = Grid2Options.L

Grid2Options:AddGeneralOptions( "Misc", "blink", {
	effect = {
		type = "select",
		name = L["Blink effect"],
		desc = L["Select the type of Blink effect used by Grid2."],
		order = 10,
		get = function () return Grid2Frame.db.profile.blinkType end,
		set = function (_, v)
			Grid2Frame.db.profile.blinkType = v
			Grid2Frame:UpdateBlink()
			Grid2Options:MakeStatusesOptions(Grid2Options.statusOptions)
		end,
		values= {["None"] = L["None"], ["Flash"] = L["Flash"]},
	},
	frequency = {
		type = "range",
		name = L["Blink Frequency"],
		desc = L["Adjust the frequency of the Blink effect."],
		disabled = function () return Grid2Frame.db.profile.blinkType == "None" end,
		min = 1,
		max = 10,
		step = .5,
		get = function ()
			return Grid2Frame.db.profile.blinkFrequency 
		end,
		set = function (_, v)
			Grid2Frame.db.profile.blinkFrequency = v
			Grid2Frame:UpdateBlink()
		end,
	},
})
