local L = Grid2Options.L

local optionParams = {
	color1 = RAID_TARGET_1,
	color2 = RAID_TARGET_2,
	color3 = RAID_TARGET_3,
	color4 = RAID_TARGET_4,
	color5 = RAID_TARGET_5,
	color6 = RAID_TARGET_6,
	color7 = RAID_TARGET_7,
	color8 = RAID_TARGET_8,
	titleIcon = "Interface\\TARGETINGFRAME\\UI-RaidTargetingIcons",
	titleIconCoords = { 0.5, 1, 0, 0.5},
}

local function MakeOptions(self, status, options, optionParams)
	self:MakeStatusStandardOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 30)
	options.opacity = {
		type = "range",
		order = 150,
		name = L["Opacity"],
		desc = L["Set the opacity."],
		min = 0,
		max = 1,
		step = 0.01,
		get = function(info) return status.dbx.opacity or false end,
		set = function(info, v) 
			status.dbx.opacity = v
			status:SetGlobalOpacity(v)
			status:UpdateAllIndicators()
		end,
	}
end

Grid2Options:RegisterStatusOptions("raid-icon-player", "target", MakeOptions, optionParams)
Grid2Options:RegisterStatusOptions("raid-icon-target", "target", MakeOptions, optionParams)
