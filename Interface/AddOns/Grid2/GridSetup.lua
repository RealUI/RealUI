--[[
Created by Grid2 original authors, modified by Michael
--]]

local Grid2 = Grid2

function Grid2:SetupShutdown()
	-- remove indicators 
	for _, indicator in Grid2:IterateIndicators() do
		Grid2:UnregisterIndicator(indicator)
	end
  	-- remove statuses
	for _, status in Grid2:IterateStatuses() do
		Grid2:UnregisterStatus(status)
	end
end

function Grid2:SetupIndicators(setup)
	local loaded = {}
	-- Parent indicators are loaded before child indicators
	local function SetupIndicator(baseKey, dbx)
		if loaded[baseKey] then return true end
		local anchorTo = dbx.anchorTo
		if (not anchorTo) or SetupIndicator(anchorTo, setup[anchorTo]) then
			local setupFunc = self.setupFunc[dbx.type]
			if (setupFunc) then
				setupFunc(baseKey, dbx)
				loaded[baseKey] = true
				return true
			else
				Grid2:Debug("SetupIndicators setupFunc not found for indicator: ", dbx.type)
			end
		else
			Grid2:Debug("SetupIndicators child indicator not loaded due to failed dependencies: ", parent, dbx.type)
		end	
	end
	-- add new indicator types
	for baseKey, dbx in pairs(setup) do
		SetupIndicator(baseKey, dbx)
	end
end

function Grid2:SetupStatuses(setup)
	-- add new statuses
	for baseKey, dbx in pairs(setup) do
		local setupFunc = self.setupFunc[dbx.type]
		if (setupFunc) then
			setupFunc(baseKey, dbx)
        else
			 Grid2:Debug("SetupStatuses setupFunc not found for status: ", dbx.type)
		end
	end
end

function Grid2:SetupStatusMap(setup)
	for baseKey, map in pairs(setup) do
		local indicator = self.indicators[baseKey]
		if indicator then
			for statusKey, priority in pairs(map) do
				local status = self.statuses[statusKey]
				if status and tonumber(priority) then
					indicator:RegisterStatus(status, priority)
				else
					Grid2:Debug("Grid2:SetupStatusMap failed mapping:", statusKey, "status:", status, "priority:", priority, "indicator:", baseKey)
				end
			end
		else
			Grid2:Debug("Grid2:SetupStatusMap Could not find mapped indicator baseKey:", baseKey)
		end
	end
end

function Grid2:Setup()
   local db = Grid2.db.profile
   Grid2:SetupIndicators(db.indicators)
   Grid2:SetupStatuses(db.statuses)
   Grid2:SetupStatusMap(db.statusMap)
end
