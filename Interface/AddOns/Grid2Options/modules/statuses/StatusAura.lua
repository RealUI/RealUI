local L = Grid2Options.L

local ColorCountValues = {1,2,3,4,5,6,7,8,9}

local ColorizeByValues= { L["Number of stacks"] , L["Remaining time"], L["Elapsed time"] }

local function StatusAuraGenerateColors(status, newCount)
	local oldCount = status.dbx.colorCount or 1
	for i=oldCount+1,newCount do
		status.dbx["color"..i] = { r=1, g=1, b=1, a=1 } 
	end
	for i=newCount+1,oldCount do
		status.dbx["color"..i] = nil
	end
	status.dbx.colorCount = newCount>1 and newCount or nil
end

local function StatusAuraGenerateColorThreshold(status)
	if status.dbx.colorCount then
		local newCount   = status.dbx.colorCount - 1
		local thresholds = status.dbx.colorThreshold or {}
		local oldCount   = #thresholds
		for i=oldCount+1,newCount do 
			thresholds[i] = 0
		end	
		for i=oldCount,newCount+1,-1 do
			table.remove(thresholds)
		end
		status.dbx.colorThreshold = thresholds
		status.dbx.blinkThreshold = nil
	else
		status.dbx.colorThreshold = nil
	end	
end

function Grid2Options:MakeStatusAuraListOptions(status, options, optionParams)
	if not status.dbx.auras then return end
	self:MakeHeaderOptions( options, "Auras" )
	options.auras = {
		type = "input",
		order = 155,
		width = "full",
		name = "",
		multiline= math.min(8,#status.dbx.auras),
		get = function()
				local auras= {}
				for _,aura in pairs(status.dbx.auras) do
					auras[#auras+1]= (type(aura)=="number") and GetSpellInfo(aura) or aura
				end
				return table.concat( auras, "\n" )
		end,
		set = function(_, v)
			wipe(status.dbx.auras)
			local auras= { strsplit("\n,", v) }
			for _,v in pairs(auras) do
				local aura= strtrim(v)
				if #aura>0 then
					table.insert(status.dbx.auras, tonumber(aura) or aura )
				end
			end	
			status:UpdateDB()
			status:UpdateAllIndicators()
		end,
	}
end

function Grid2Options:MakeStatusAuraMissingOptions(status, options, optionParams)
	options.threshold = {
		type = "toggle",
		name = L["Show if missing"],
		desc = L["Display status only if the buff is not active."],
		order = 8,
		get = function () return status.dbx.missing end,
		set = function (_, v)
			status.dbx.missing = v or nil
			if v then
				StatusAuraGenerateColors(status,1)
				status.dbx.colorThreshold = nil
			end
			status:UpdateDB()
			status:UpdateAllIndicators()
			self:MakeStatusOptions(status)
		end,
	}
end

-- Grid2Options:MakeStatusBlinkThresholdOptions()
function Grid2Options:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	if Grid2Frame.db.profile.blinkType ~= "None" and (not status.dbx.colorThreshold) then
		-- self:MakeSpacerOptions( options, 30 )
		self:MakeHeaderOptions(options, "Thresholds")
		options.blinkThreshold = {
			type = "range",
			order = 51,
			name = L["Blink"],
			desc = L["Blink Threshold at which to start blinking the status."],
			min = 0,
			max = 30,
			step = 0.1,
			bigStep  = 1,
			get = function ()
				return status.dbx.blinkThreshold or 0
			end,
			set = function (_, v)
				if v == 0 then v = nil end
				status.dbx.blinkThreshold = v
				status:UpdateDB()
			end,
		}
	end
end

function Grid2Options:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	if not tonumber(status.dbx.spellName) then return end
	self:MakeHeaderOptions(options, "Misc")
	options.useSpellId = {
		type = "toggle",
		name = L["Track by SpellId"], 
		desc = string.format( "%s (%d) ", L["Track by spellId instead of aura name"], status.dbx.spellName ),
		order = 110,
		get = function () return status.dbx.useSpellId end,
		set = function (_, v)
			status.dbx.useSpellId = v or nil
			status:UpdateDB()
		end,
	}
end

function Grid2Options:MakeStatusAuraCommonOptions(status, options, optionParams)
	if not status.dbx.missing then
		options.colorCount = {
			type = "select",
			order = 5,
			width ="half",
			name = L["Color count"],
			desc = L["Select how many colors the status must provide."],
			get = function() return status.dbx.colorCount or 1 end,
			set = function(_,v) 
				StatusAuraGenerateColors(status, v)
				if status.dbx.colorThreshold then
					StatusAuraGenerateColorThreshold(status)
				end	
				status:UpdateDB()
				self:MakeStatusOptions(status)
			end,
			values = ColorCountValues,
		}
		if status.dbx.colorCount then
			options.colorizeBy = {
				type = "select",
				order = 6,
				width ="normal",
				name = L["Coloring based on"],
				desc = L["Coloring based on"],
				get = function() 
					if status.dbx.colorThreshold then
						return status.dbx.colorThresholdElapsed and 3 or 2
					else
						return 1
					end
				end,
				set = function( _, v) 
						status.dbx.colorThreshold = nil
						status.dbx.colorThresholdElapsed = (v==3) and true or nil
						if v ~= 1 then StatusAuraGenerateColorThreshold(status) end
						status:UpdateDB()
						self:MakeStatusOptions(status)
				end,
				values = ColorizeByValues, 
			}
		end	
	end
	self:MakeHeaderOptions(options, "Colors")
end

function Grid2Options:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	local thresholds = status.dbx.colorThreshold
	if thresholds then 
		self:MakeHeaderOptions(options, "Thresholds")
		local colorKey = L["Color"]
		for i=1,#thresholds do
			options[ "colorThreshold" .. i ] = {
				type = "range",
				order = 50+i,
				name = colorKey .. (i+1),
				desc = L["Threshold to activate Color"] .. (i+1),
				min = 0,
				max = 300,
				softMin = 0,
				softMax = 30,
				step = 0.1,
				bigStep = 1,
				get = function () return status.dbx.colorThreshold[i] end,
				set = function (_, v)
					local min,max
					if status.dbx.colorThresholdElapsed then
						min = status.dbx.colorThreshold[i-1] or 0
						max = status.dbx.colorThreshold[i+1] or 30
					else
						min = status.dbx.colorThreshold[i+1] or 0
						max = status.dbx.colorThreshold[i-1] or 30
					end
					if v>=min and v<=max then
						status.dbx.colorThreshold[i] = v
						status:UpdateDB()
					end	
				end,
			}
		end
	end
end

function Grid2Options:MakeStatusDebuffTypeFilterOptions(status, options, optionParams)
	self:MakeHeaderOptions( options, "DebuffFilter" )
	options.debuffFilter = {
		type = "input",
		order = 180,
		width = "full",
		name = "", 
		multiline = status.dbx.debuffFilter and math.max(#status.dbx.debuffFilter,3) or 3,
		get = function()
				if status.dbx.debuffFilter then
					local debuffs= {}
					for name in next,status.dbx.debuffFilter do
						debuffs[#debuffs+1] = name
					end
					return table.concat( debuffs, "\n" )
				end
		end,
		set = function(_, v) 
			local debuffs= { strsplit("\n,", v) }
			if next(debuffs) then
				if status.dbx.debuffFilter then
					wipe(status.dbx.debuffFilter)
				else
					status.dbx.debuffFilter = {}
				end
				for _,debuff in pairs(debuffs) do
					debuff = strtrim(debuff)
					if #debuff>0 then
						debuff = tonumber(debuff) and GetSpellInfo(debuff) or debuff
						status.dbx.debuffFilter[debuff] = true
					end
				end
			end
			if not next(status.dbx.debuffFilter) then
				status.dbx.debuffFilter = nil
			end			
			status:UpdateDB()
			status:UpdateAllIndicators()
		end,
	}
end

function Grid2Options:MakeStatusAuraDescriptionOptions(status, options, optionParams)
	if status.dbx.auras then return end
	local spellID = tonumber(status.dbx.spellName)
	if not spellID then return end
	local tip = Grid2Options.Tooltip
	tip:ClearLines()
	tip:SetHyperlink("spell:"..spellID)
	if tip:NumLines() > 1 then
		options.titleDesc = {
			type        = "description",
			order       = 1.2,
			fontSize    = "small",
			name        = tip[tip:NumLines()]:GetText(),
		}
	end
end

-- {{ Register
Grid2Options:RegisterStatusOptions("buff", "buff", function(self, status, options, optionParams)
	self:MakeStatusAuraDescriptionOptions(status, options, optionParams)
	self:MakeStatusAuraListOptions(status, options, optionParams)
    self:MakeStatusAuraCommonOptions(status, options, optionParams)	
	self:MakeStatusAuraMissingOptions(status, options, optionParams)
	self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusDeleteOptions(status, options, optionParams)
end )

Grid2Options:RegisterStatusOptions("debuff", "debuff", function(self, status, options, optionParams)
	self:MakeStatusAuraDescriptionOptions(status, options, optionParams)
	self:MakeStatusAuraListOptions(status, options, optionParams)
	self:MakeStatusAuraCommonOptions(status, options, optionParams)
	self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusDeleteOptions(status, options, optionParams)
end )

Grid2Options:RegisterStatusOptions("debuffType", "debuff", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusDebuffTypeFilterOptions(status, options, optionParams)
end,{
	groupOrder = 10
} )
-- }}
