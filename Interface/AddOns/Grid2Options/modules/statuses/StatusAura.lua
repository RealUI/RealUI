local L = Grid2Options.L

local ColorCountValues = {1,2,3,4,5,6,7,8,9}
local ColorizeByValues1= { L["Number of stacks"] , L["Remaining time"], L["Elapsed time"] }
local ColorizeByValues2= { L["Number of stacks"] , L["Remaining time"], L["Elapsed time"], L["Value"] }
local MonitorizeValues = { [0]= L["NONE"], [1] = L["Value1"], [2] = L["Value2"], [3] = L["Value3"] }

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
				status.dbx.valueIndex = nil
			end
			status:UpdateDB()
			Grid2:RefreshAuras() 
			self:MakeStatusOptions(status)
		end,
	}
end

-- Grid2Options:MakeStatusBlinkThresholdOptions()
function Grid2Options:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	if Grid2Frame.db.profile.blinkType ~= "None" and (not status.dbx.colorThreshold) then
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
		width = "double",
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
				status.dbx.debuffTypeColorize = nil
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
						return  (status.dbx.colorThresholdValue and 4)   or
								(status.dbx.colorThresholdElapsed and 3) or 2
					else
						return 1
					end
				end,
				set = function( _, v) 
						status.dbx.colorThreshold = nil
						status.dbx.colorThresholdElapsed = (v==3) and true or nil
						status.dbx.colorThresholdValue   = (v==4) and true or nil
						if v ~= 1 then StatusAuraGenerateColorThreshold(status) end
						status:UpdateDB()
						self:MakeStatusOptions(status)
				end,
				values = status.dbx.valueIndex and ColorizeByValues2 or ColorizeByValues1, 
			}
		elseif status.dbx.type == "debuffs" then
			options.debuffTypeColor = {
				type = "toggle",
				name = L["Use debuff Type color"],
				desc = L["Use the debuff Type color first. The specified color will be applied only if the debuff has no type."],
				order = 6,
				get = function () return status.dbx.debuffTypeColorize end,
				set = function (_, v)
					status.dbx.debuffTypeColorize = v or nil
					status:UpdateDB()
					status:UpdateAllIndicators()
				end,
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
		local maxValue = status.dbx.colorThresholdValue and 200000 or 30
		local step     = status.dbx.colorThresholdValue and 50 or 0.1
		for i=1,#thresholds do
			options[ "colorThreshold" .. i ] = {
				type = "range",
				order = 50+i,
				name = colorKey .. (i+1),
				desc = L["Threshold to activate Color"] .. (i+1),
				min = 0,
				max = maxValue * 10,
				softMin = 0,
				softMax = maxValue,
				step = step,
				bigStep = step*10,
				get = function () return status.dbx.colorThreshold[i] end,
				set = function (_, v)
					local min,max
					if status.dbx.colorThresholdElapsed then
						min = status.dbx.colorThreshold[i-1] or 0
						max = status.dbx.colorThreshold[i+1] or maxValue
					else
						min = status.dbx.colorThreshold[i+1] or 0
						max = status.dbx.colorThreshold[i-1] or maxValue
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

function Grid2Options:MakeStatusAuraValueOptions(status, options, optionParams)
	if status.dbx.auras or status.dbx.missing then return end
	self:MakeHeaderOptions( options, "Value" )
	options.trackValue = {
		type = "select",
		order = 91,
		width ="half",
		name = L["Value"],
		desc = L["AURAVALUE_DESC"],
		get = function() return status.dbx.valueIndex or 0 end,
		set = function( _, v)
				if v==0 then
					status.dbx.valueIndex = nil
					status.dbx.colorThresholdValue = nil
				else	
					status.dbx.valueIndex = v
				end	
				status:UpdateDB()
				self:MakeStatusOptions(status)
		end,
		values = MonitorizeValues,
	}
	options.valueMax = {
		type = "range",
		order = 92,
		name = L["Maximum Value"],
		desc = L["Value used by bar indicators. Select zero to use players Maximum Health."],
		min = 0,
		softMax = 200000,
		bigStep = 1000,
		step = 1,
		get = function () return status.dbx.valueMax or 0 end,
		set = function (_, v) 
			status.dbx.valueMax = v>0 and v or nil
			status:UpdateDB()
			status:UpdateAllIndicators()
		end,
		disabled = function() return not status.dbx.valueIndex end
	}
end

function Grid2Options:MakeStatusAuraListOptions(status, options, optionParams)
	self:MakeHeaderOptions( options, "Display" )
	options.aurasList = {
		type = "input",
		order = 155,
		width = "full",
		name = "",
		multiline = math.min( math.max(status.dbx.auras and #status.dbx.auras or 0,5),10),
		get = function()
			local auras = {}
			for _,aura in pairs(status.dbx.auras) do
				auras[#auras+1]= (type(aura)=="number") and GetSpellInfo(aura) or aura
			end
			return table.concat( auras, "\n" )
		end,
		set = function(_, v)
			wipe(status.dbx.auras)
			local auras = { strsplit("\n,", strtrim(v)) }
			for _,name in pairs(auras) do
				local aura = strtrim(name)
				if #aura>0 then
					table.insert(status.dbx.auras, tonumber(aura) or aura )
				end
			end	
			status:UpdateDB()
			Grid2:RefreshAuras() 			
		end,
		hidden = function() return status.dbx.auras==nil end
	}
end

function Grid2Options:MakeStatusDebuffsFilterOptions(status, options, optionParams)
	options.showBossDebuffs = {
		type = "toggle",
		name = L["Boss Debuffs"],
		desc = L["Display debuffs direct casted by Bosses"],
		order = 151.5,
		get = function () return status.dbx.filterBossDebuffs~=true end,
		set = function (_, v)
			status.dbx.filterBossDebuffs = (not v) and true or nil
			status:UpdateDB()
			Grid2:RefreshAuras()
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.showNonBossDebuffs = {
		type = "toggle",
		name = L["Non Boss Debuffs"],
		desc = L["Display debuffs not casted by Bosses"],
		order = 151,
		get = function () return status.dbx.filterBossDebuffs~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterBossDebuffs = nil
			else
				status.dbx.filterBossDebuffs = false
			end	
			status:UpdateDB()
			Grid2:RefreshAuras() 
		end,
		hidden = function() return status.dbx.useWhiteList end
	}
	options.filterSep1 = { type = "description", name = "", order = 151.9 }
	options.showLongDebuffs = {
		type = "toggle",
		name = L["Long Duration"],
		desc = L["Display debuffs with duration above 5 minutes."],
		order = 152.5,
		get = function () return status.dbx.filterLongDebuffs~=true end,
		set = function (_, v)
			status.dbx.filterLongDebuffs = (not v) and true or nil
			status:UpdateDB()
			Grid2:RefreshAuras()
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterBossDebuffs==false end
	}
	options.showShortDebuffs = {
		type = "toggle",
		name = L["Short Duration"],
		desc = L["Display debuffs with duration below 5 minutes."],
		order = 152,
		get = function () return status.dbx.filterLongDebuffs~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterLongDebuffs = nil
			else
				status.dbx.filterLongDebuffs = false
			end
			status:UpdateDB()
			Grid2:RefreshAuras()
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterBossDebuffs==false end
	}
	options.filterSep2 = { type = "description", name = "", order = 152.9 }	
	options.showSelfDebuffs = {
		type = "toggle",
		name = L["Self Casted"],
		desc = L["Display self debuffs"],
		order = 153.5,
		get = function () return status.dbx.filterCaster~=true end,
		set = function (_, v)
			status.dbx.filterCaster = (not v) and true or nil
			status:UpdateDB()
			Grid2:RefreshAuras()
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterBossDebuffs==false end
	}
	options.showNonSelfDebuffs = {
		type = "toggle",
		name = L["Non Self Casted"],
		desc = L["Display non self debuffs"],
		order = 153,
		get = function () return status.dbx.filterCaster~=false end,
		set = function (_, v)
			if v then
				status.dbx.filterCaster = nil
			else
				status.dbx.filterCaster = false
			end
			status:UpdateDB()
			Grid2:RefreshAuras()
		end,
		hidden = function() return status.dbx.useWhiteList or status.dbx.filterBossDebuffs==false end
	}
	options.filterSep3 = { type = "description", name = "", order = 153.9 }	
	options.useWhiteList = {
		type = "toggle",
		name = L["Whitelist"],
		desc = L["Display only debuffs configured in the list below."],
		order = 154,
		get = function () return status.dbx.useWhiteList and status.dbx.auras~=nil end,
		set = function (_, v)
			if v then
				status.dbx.auras = status.dbx.auras or status.dbx.aurasBak or {}
				status.dbx.aurasBak = nil
				status.dbx.useWhiteList = true
			else
				status.dbx.aurasBak = status.dbx.auras
				status.dbx.auras = nil
				status.dbx.useWhiteList = nil
			end	
			status:UpdateDB()
			Grid2:RefreshAuras()
			status:UpdateAllIndicators()			
		end,
	}
	options.useBlackList = {
		type = "toggle",
		name = L["Blacklist"],
		desc = L["Ignore debuffs configured in the list below."],
		order = 154.5,
		get = function () return (not status.dbx.useWhiteList) and status.dbx.auras~=nil end,
		set = function (_, v)
			if v then
				status.dbx.auras = status.dbx.auras or status.dbx.aurasBak or {}
				status.dbx.aurasBak = nil
			else
				status.dbx.aurasBak = status.dbx.auras
				status.dbx.auras = nil
			end	
			status.dbx.useWhiteList = nil
			status:UpdateDB()
			Grid2:RefreshAuras()
			status:UpdateAllIndicators()			
		end,
	}
end

-- {{ Register
Grid2Options:RegisterStatusOptions("buff", "buff", function(self, status, options, optionParams)
	self:MakeStatusAuraDescriptionOptions(status, options)
	self:MakeStatusAuraCommonOptions(status, options, optionParams)	
	self:MakeStatusAuraMissingOptions(status, options, optionParams)
	self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusAuraValueOptions(status, options, optionParams)
	self:MakeStatusDeleteOptions(status, options, optionParams)
end,{
	groupOrder = 10
})

Grid2Options:RegisterStatusOptions("buffs", "buff", function(self, status, options, optionParams)
	self:MakeStatusAuraDescriptionOptions(status, options)
	self:MakeStatusAuraListOptions(status, options, optionParams)
	self:MakeStatusAuraCommonOptions(status, options, optionParams)	
	self:MakeStatusAuraMissingOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusDeleteOptions(status, options, optionParams)
end,{
	groupOrder = 20
})

Grid2Options:RegisterStatusOptions("debuffType", "debuff", function(self, status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusDebuffTypeFilterOptions(status, options, optionParams)
end,{
	groupOrder = 10
} )

Grid2Options:RegisterStatusOptions("debuffs", "debuff", function(self, status, options, optionParams)
	self:MakeStatusAuraDescriptionOptions(status, options, optionParams)
	self:MakeStatusDebuffsFilterOptions(status, options, optionParams)
	self:MakeStatusAuraListOptions(status, options, optionParams)
	self:MakeStatusAuraCommonOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusDeleteOptions(status, options, optionParams)	
end,{
	groupOrder = 20
})

Grid2Options:RegisterStatusOptions("debuff", "debuff", function(self, status, options, optionParams)
	self:MakeStatusAuraDescriptionOptions(status, options, optionParams)	
	self:MakeStatusAuraCommonOptions(status, options, optionParams)
	self:MakeStatusAuraUseSpellIdOptions(status, options, optionParams)
	self:MakeStatusColorOptions(status, options, optionParams)
	self:MakeStatusAuraColorThresholdOptions(status, options, optionParams)
	self:MakeStatusBlinkThresholdOptions(status, options, optionParams)
	self:MakeStatusAuraValueOptions(status, options, optionParams)
	self:MakeStatusDeleteOptions(status, options, optionParams)	
end,{
	groupOrder = 30
})

-- }}
