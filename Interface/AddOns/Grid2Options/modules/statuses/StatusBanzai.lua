local L = Grid2Options.L
	
local function MakeOptions(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	options.update = {
		type = "range",
		order = 20,
		name = L["Update rate"],
		desc = L["Rate at which the status gets updated"],
		min = 0,
		max = 5,
		step = 0.05,
		bigStep = 0.1,
		get = function () return status.dbx.updateRate or 0.2 end,
		set = function (_, v) status:SetUpdateRate(v) end,
	}
end

Grid2Options:RegisterStatusOptions("banzai", "combat", MakeOptions, {
	title = L["hostile casts against raid members"],
	titleIcon = "Interface\\Icons\\Spell_shadow_deathscream"
})

Grid2Options:RegisterStatusOptions("banzai-threat", "combat", MakeOptions, {
	title = L["advanced threat detection"],
	titleIcon = "Interface\\Icons\\Spell_shadow_deathscream"
})