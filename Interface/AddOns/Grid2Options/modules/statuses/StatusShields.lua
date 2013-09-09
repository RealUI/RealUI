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
		order = 31,
		name = L["Maximum shield amount"],
		desc = L["Maximum shield amount value. Only used by bar indicators."],
		min = 0,
		softMax = 100000,
		bigStep = 100,
		step = 1,
		get = function () return status.dbx.maxShieldAmount or 30000 end,
		set = function (_, v) 
			status.dbx.maxShieldAmount = v  
			status:UpdateDB() 
		end,
	}
	options.thresholdMedium = {
		type = "range",
		order = 32,
		name = L["Medium shield threshold"],
		desc = L["The value below which a shield is considered medium."],
		min = 0,
		softMax = 100000,
		bigStep = 100,
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
		order = 34,
		name = L["Low shield threshold"],
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
	options.filter = {
		type = "group",
		order = 40,
		inline= true,
		name = L["shields"],
		args = {},
	}
	local dbx = status.dbx
	local shields = status:GetAvailableShields()
	for _,spellId in pairs(shields) do
		options.filter.args["shield"..spellId] = {
			type = "toggle",
			width = "normal",
			name = GetSpellInfo(spellId) or tostring(spellId),
			get = function () return not (dbx.filtered and dbx.filtered[spellId]) end,
			set = function (_, value)
				if value then
					if dbx.filtered then
						dbx.filtered[spellId] = nil
						if not next(dbx.filtered) then dbx.filtered = nil end
					end	
				else
					if not dbx.filtered then dbx.filtered = {} end
					dbx.filtered[spellId] = true
				end
				status:UpdateDB()
			end,
		}
	end
	options.customShields = {
		type = "input",
		order = 120,
		width = "full",
		name = L["Custom Shields"], 
		desc = L["Type shield spell IDs separated by commas."],
		get = function () return status.dbx.customShields end,
		set = function (_, v)
			local shields = { strsplit( ",", strtrim(v, ", ")  ) }
			for i=1,#shields do
				local spellId = tonumber(strtrim(shields[i]))
				shields[i] = GetSpellInfo(spellId) and tostring(spellId) or nil
			end
			status.dbx.customShields = table.concat(shields,",")
			status:UpdateDB()
		end,
	}
end, {
	titleIcon = "Interface\\ICONS\\Spell_Holy_PowerWordShield"
} )
