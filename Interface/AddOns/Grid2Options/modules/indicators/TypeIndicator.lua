--[[
	Grid2Options:MakeIndicatorTypeOptions()
	Option to change indicator type
--]]

local L = Grid2Options.L

local typeMorphValues = {
	icon   = { icon   = L["icon"], square = L["square"], text = L["text"]},
	square = { square = L["square"], text = L["text"],icon = L["icon"]},
	text   = { square = L["square"], text = L["text"],icon = L["icon"]},
}

local function RegisterIndicatorStatusesFromDatabase(indicator)
	if indicator then
		local map= Grid2:DbGetValue("statusMap", indicator.name)
		if map then
			for statusKey, priority in pairs(map) do
				local status = Grid2.statuses[statusKey]
				if (status and tonumber(priority)) then
					indicator:RegisterStatus(status, priority)
				end
			end	
		end	
	end
end	

local function GetIndicatorTypeValues(info)
	local indicator = info.arg
	local typeKey = indicator.dbx.type
	local typeMorphValues = typeMorphValues
	
	if (not typeMorphValues[typeKey]) then
		typeMorphValues[typeKey] = {}
		typeMorphValues[typeKey][typeKey] = L[typeKey]
	end
	
	return typeMorphValues[typeKey]
end

local function GetIndicatorType(info)
	local indicator = info.arg
	return indicator.dbx.type
end

local function SetIndicatorType(info, value)
	local indicator = info.arg
	local baseKey = indicator.name
	local dbx = indicator.dbx
	local colorKey = baseKey.."-color"
	local oldType = dbx.type

	if  dbx.type == value then return end
	
	-- Set new fields width defaults values
	dbx.type = value
	for k, v in pairs(Grid2Options.indicatorDefaultValues[value]) do
		if (not dbx[k]) then
			indicator.dbx[k] = v
			dbx[k] = v
		end
	end
	-- Remove old indicator
	Grid2Frame:WithAllFrames(function (f) indicator:Disable(f) end)
	Grid2:UnregisterIndicator(indicator)
	-- Create new indicator
	local setupFunc = Grid2.setupFunc[dbx.type]
	local newIndicator = setupFunc(baseKey, dbx)
	-- Remove incompatible statuses from database
	local map = Grid2:DbGetValue("statusMap", baseKey)
	if map then
		for statusKey, priority in pairs(map) do
			local status = Grid2.statuses[statusKey]
			if (not status) or (not Grid2Options:IsCompatiblePair(newIndicator, status)) then
				map[statusKey]= nil
			end
		end
	end	
	-- Register indicator statuses from database
	RegisterIndicatorStatusesFromDatabase(newIndicator)
	RegisterIndicatorStatusesFromDatabase(newIndicator.sideKick)
	-- Recreate indicators in frame units 
	Grid2Frame:WithAllFrames(function (f)
		newIndicator:Create(f)
		newIndicator:Layout(f)
	end)
	-- Delete or Create associated text-color indicator in database
	if oldType=="text" then
		Grid2:DbSetIndicator(colorKey, nil)
	elseif value=="text" then
		Grid2:DbSetIndicator( colorKey , { type="text-color" })
	end
	-- Update unit frames
	Grid2Frame:UpdateIndicators()
	-- Create new indicator options
	Grid2Options:MakeIndicatorOptions(newIndicator)
end

-- {{ Published method
function Grid2Options:MakeIndicatorTypeOptions(indicator, options, optionParams)
	local baseKey = indicator.name
	options.type = {
	    type = 'select',
		order = 260,
		width = "half",
		name = L["Change type"],
		desc = L["Change the indicator type"],
	    values = GetIndicatorTypeValues,
	    get = GetIndicatorType,
	    set = SetIndicatorType,
		arg = indicator,
	}
end
-- }}