local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("heal-absorbs", "health", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams )
	self:MakeSpacerOptions(options, 30)
	options.maxShieldAmount = {
		type = "range",
		order = 34,
		name = L["Maximum absorb amount"],
		desc = L["Value used by bar indicators. Select zero to use players Maximum Health."],
		min = 0,
		softMax = 200000,
		bigStep = 1000,
		step = 1,
		get = function () return status.dbx.maxShieldValue or 0 end,
		set = function (_, v) 
			status.dbx.maxShieldValue = v>0 and v or nil  
			status:UpdateDB() 
		end,
	}
	options.thresholdMedium = {
		type = "range",
		order = 32,
		name = L["Medium absorb threshold"],
		desc = L["The value below which a shield is considered medium."],
		min = 0,
		softMax = 200000,
		bigStep = 1000,
		step = 1,
		get = function () return status.dbx.thresholdMedium end,
		set = function (_, v)
			   if status.dbx.thresholdLow > v then v = status.dbx.thresholdLow end
			   status.dbx.thresholdMedium = v  
			   status:UpdateDB()
		end,
	}
	options.thresholdLow = {
		type = "range",
		order = 31,
		name = L["Low absorb threshold"],
		desc = L["The value below which a shield is considered low."],
		min = 0,
		softMax = 100000,
		bigStep = 100,
		step = 1,
		get = function () return status.dbx.thresholdLow end,
		set = function (_, v)
			   if status.dbx.thresholdMedium < v then v = status.dbx.thresholdMedium end
			   status.dbx.thresholdLow = v  
			   status:UpdateDB()
		end,
	}
end, {
	color1 = L["Normal"], 
	colorDesc1 = L["Normal heal absorbs color"],
	color2 = L["Medium"], 
	colorDesc2 = L["Medium heal absorbs color"],
	color3 = L["Low"],    
	colorDesc3 = L["Low heal absorbs color"],
	title = L["display remaining amount of heal absorb shields"],
	titleIcon = "Interface\\Icons\\spell_fire_ragnaros_lavabolt",
})