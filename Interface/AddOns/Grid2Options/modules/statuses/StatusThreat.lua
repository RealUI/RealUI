local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("threat", "combat", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeSpacerOptions(options, 30)
	options.disableBlink = {
		type = "toggle",
		name = L["Disable Blink"],
		desc = L["Disable Blink"],
		width = "full",
		order = 35,
		get = function () return status.dbx.disableBlink end,
		set = function (_, v) 
			status.dbx.disableBlink = v or nil 
			status:UpdateDB()
		end,
	}
end, {
		color1 = L["Not Tanking"],
		colorDesc1 = L["Higher threat than tank."],
		color2 = L["Insecurely Tanking"],
		colorDesc2 = L["Tanking without having highest threat."],
		color3 = L["Securely Tanking"],
		colorDesc3 = L["Tanking with highest threat."],
		width= "full",
		titleIcon = "Interface\\Icons\\Ability_physical_taunt"
})
