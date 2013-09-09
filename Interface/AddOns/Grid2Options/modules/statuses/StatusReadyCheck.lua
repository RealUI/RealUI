local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("ready-check", "misc", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusThresholdOptions(status, options, optionParams, 1, 20, 1)
end, {
	color1 = L["Waiting color"],
	colorDesc1 = L["Color for Waiting."],
	color2 = L["Ready color"],
	colorDesc2 = L["Color for Ready."],
	color3 = L["Not Ready color"],
	colorDesc3 = L["Color for Not Ready."],
	color4 = L["AFK color"],
	colorDesc4 = L["Color for AFK."],
	threshold = L["Delay"],
	thresholdDesc = L["Set the delay until ready check results are cleared."],
	width = "full",
	titleIcon = "Interface\\RAIDFRAME\\ReadyCheck-Ready",
})