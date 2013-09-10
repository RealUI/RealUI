--[[
Created by Grid2 original authors, modified by Michael
--]]

local Grid2Frame = Grid2Frame

Grid2.indicators = {}
Grid2.indicatorTypes = {}
Grid2.indicatorPrototype = {}

local indicator = Grid2.indicatorPrototype 
indicator.__index = indicator

function indicator:new(name)
	local e = setmetatable({}, self)
	local p = {}
	e.sortStatuses = function (a,b) return p[a] > p[b]	end
	e.priorities = p
	e.name = name
	e.statuses = {}
	return e
end

function indicator:CreateFrame(type, parent)
	local f = parent[self.name]
	if not (f and f:GetObjectType()==type) then
		f = CreateFrame(type, nil, parent)
		parent[self.name] = f
	end
	return f
end

function indicator:RegisterStatus(status, priority)
	if self.priorities[status] then return end
	self.priorities[status] = priority
	self.statuses[#self.statuses + 1] = status
	table.sort(self.statuses, self.sortStatuses)
	status:RegisterIndicator(self)
end

function indicator:UnregisterStatus(status)
	if not self.priorities[status] then return end
	self.priorities[status] = nil
	for i, s in ipairs(self.statuses) do
		if s == status then
			table.remove(self.statuses, i)
			break
		end
	end
	status:UnregisterIndicator(self)
end

function indicator:SetStatusPriority(status, priority)
	if not self.priorities[status] then return end
	self.priorities[status] = priority
	table.sort(self.statuses, self.sortStatuses)
end

function indicator:GetStatusPriority(status)
	return self.priorities[status]
end

function indicator:GetStatusIndex(status)
	local statuses= self.statuses
	for i=1,#statuses do
		if status == statuses[i] then
			return i
		end	
	end
end

function indicator:GetCurrentStatus(unit)
	if unit then
		local statuses= self.statuses
		for i=1,#statuses do
			local status= statuses[i]
			local state = status:IsActive(unit)
			if state then
				return status, state
			end
		end
	end
end

--{{ Update functions
function indicator:UpdateBlink(parent, unit)
	local status, state = self:GetCurrentStatus(unit)
	local func = self.GetBlinkFrame
	if func then Grid2Frame:SetBlinkEffect( func(self,parent) , state=="blink" ) end
	self:OnUpdate(parent, unit, status)
end

function indicator:UpdateNoBlink(parent, unit)
	self:OnUpdate(parent, unit, self:GetCurrentStatus(unit) )
end

indicator.Update = indicator.UpdateBlink
--}}

function Grid2:RegisterIndicator(indicator, types)
	local name = indicator.name
	self.indicators[name] = indicator
	for _, type in ipairs(types) do
		local t = self.indicatorTypes[type]
		if not t then
			t = {}
			self.indicatorTypes[type] = t
		end
		t[name] = indicator
	end
end

function Grid2:UnregisterIndicator(indicator)
	local statuses= indicator.statuses
	while #statuses>0 do
		indicator:UnregisterStatus(statuses[#statuses])
	end
	if indicator.Disable then
		Grid2Frame:WithAllFrames(indicator, "Disable")
	end
	local name = indicator.name
	self.indicators[name] = nil
	for type, t in pairs(self.indicatorTypes) do
		t[name] = nil
	end
	if indicator.sideKick then
		Grid2:UnregisterIndicator(indicator.sideKick)
		indicator.sideKick = nil
	end
end

function Grid2:IterateIndicators(type)
	return next, type and self.indicatorTypes[type] or self.indicators
end
