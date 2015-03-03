--[[
	Indicators options
--]]

local Grid2Options = Grid2Options
local L = Grid2Options.L

-- Direct link to AceConfigTable indicators list
Grid2Options.indicatorOptions = Grid2Options.options.args.indicators.args
-- Path to indicator icons
Grid2Options.indicatorIconPath = "Interface\\Addons\\Grid2Options\\media\\indicator-"
-- Creatable indicators list
Grid2Options.indicatorTypes = {}
-- Indicators sort order
Grid2Options.indicatorTypesOrder= {	alpha = 1, border = 2, multibar =3, bar = 4, text = 5, square = 6, icon = 7, icons = 8 }


-- Register indicator options
function Grid2Options:RegisterIndicatorOptions(type, isCreatable, funcMakeOptions, optionParams)
	self.typeMakeOptions[type] = funcMakeOptions
	self.optionParams[type] = optionParams
	if isCreatable then
		self.indicatorTypes[type] = L[type]
	end
end

-- Insert options of a indicator in AceConfigTable
function Grid2Options:AddIndicatorOptions(indicator, statusOptions, layoutOptions, colorOptions)
	local options = self.indicatorOptions[indicator.name].args;	wipe(options)
	if statusOptions then options["statuses"] = { type = "group", order = 10, name = L["statuses"], args = statusOptions } end	
	if colorOptions  then options["colors"]   = { type = "group", order = 20, name = L["Colors"],	args = colorOptions  } end
	if layoutOptions then options["layout"]   = { type = "group", order = 30, name = L["Layout"],	args = layoutOptions } end	
end

-- Don't remove options param (openmanager hooks this function and needs this parameter)
function Grid2Options:MakeIndicatorChildOptions(indicator, options)
	local funcMakeOptions = self.typeMakeOptions[ indicator.dbx.type ]
	if funcMakeOptions then
		funcMakeOptions(self, indicator)
	end
end

-- Insert indicator group option in AceConfigTable
function Grid2Options:MakeIndicatorOptions(indicator)
	local type, options = indicator.dbx.type, {}
	self.indicatorOptions[indicator.name] = {
		type = "group",
		childGroups = "tab",
		icon  = self.indicatorIconPath .. (self.indicatorTypesOrder[type] and type or "default"),
		order = self.indicatorTypesOrder[type] or nil,
		name  = self.LI[indicator.name] or L[indicator.name],
		desc  = L["Options for %s."]:format(indicator.name),
		args  = options,
	}
	self:MakeIndicatorChildOptions(indicator, options)
end

-- Remove indicator options from AceConfigTable
function Grid2Options:DeleteIndicatorOptions(indicator)
	self.indicatorOptions[indicator.name] = nil
end

-- Create all indicators options (dont remove options param, is used by openmanager)
function Grid2Options:MakeIndicatorsOptions(options)
	-- remove old options
	options = options or self.indicatorOptions;	wipe(options)
	-- make new indicator options
	if self.MakeNewIndicatorOptions then self:MakeNewIndicatorOptions() end	
	-- make indicators options
    local indicators = Grid2.db.profile.indicators
 	for baseKey,dbx in pairs(indicators) do
		if self.typeMakeOptions[dbx.type] then -- filter bar-color&text-color indicators
			local indicator = Grid2.indicators[baseKey]
			if indicator then
				self:MakeIndicatorOptions(indicator)
			end
		end	
	end
end
