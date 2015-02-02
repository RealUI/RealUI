local L = Grid2Options.L

Grid2Options:RegisterStatusOptions("shields", "health", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, {
		color1 = L["Normal"], colorDesc1 = L["Normal shield color"],
		color2 = L["Medium"], colorDesc2 = L["Medium shield color"],
		color3 = L["Low"],    colorDesc3 = L["Low shield color"],
	})
	self:MakeSpacerOptions(options, 30)
	options.maxShieldAmount = {
		type = "range",
		order = 34,
		name = L["Maximum shield amount"],
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
		name = L["Medium shield threshold"],
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
		name = L["Low shield threshold"],
		desc = L["The value below which a shield is considered low."],
		min = 0,
		softMax = 200000,
		bigStep = 1000,
		step = 1,
		get = function () return status.dbx.thresholdLow end,
		set = function (_, v)
			   if status.dbx.thresholdMedium < v then v = status.dbx.thresholdMedium end
			   status.dbx.thresholdLow = v  
			   status:UpdateDB()
		end,
	}	
	local Grid2Frame = Grid2:GetModule("Grid2Frame")
	if Grid2Frame.db.profile.blinkType ~= "None" then
		options.blinkThreshold = {
			type = "range",
			order = 35,
			name = L["Blink Threshold"],
			desc = L["Blink Threshold at which to start blinking the status."],
			min = 0,
			softMax = 100000,
			bigStep = 100,
			step = 1,
			get = function () return status.dbx.blinkThreshold or 0	end,
			set = function (_, v)
				if v == 0 then v = nil end
				status.dbx.blinkThreshold = v
				status:UpdateDB()
			end,
		}
	end
end, {
	title = L["display remaining amount of damage absorb shields"],
	titleIcon = "Interface\\ICONS\\Spell_Holy_PowerWordShield"
} )
