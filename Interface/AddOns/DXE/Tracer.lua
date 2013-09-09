-- Based off RDX's HOT

local addon = DXE
local NID = addon.NID
local unit_to_unittarget = addon.Roster.unit_to_unittarget
local AceTimer = LibStub("AceTimer-3.0")

local pairs = pairs
local UnitExists,UnitGUID = UnitExists,UnitGUID

local DELAY = 0.2

local ACQUIRED = 0
local LOST = 1

----------------------------------
-- INITIALIZATION
----------------------------------
local Tracer,prototype = {},{}
addon.Tracer = Tracer

local trackInfos = {
	npcid = { func = "Execute", goalType = "number", attribute = function(unit) return NID[UnitGUID(unit)] end },
	name = { func = "Execute", goalType = "string", attribute = UnitName },
	unit = { func = "Execute2", goalType = "string", attribute = UnitExists },
}

function Tracer:New()
	local tracer = AceTimer:Embed({})
	for k,v in pairs(prototype) do tracer[k] = v end
	tracer.s = LOST 			-- Status
	tracer.callbacks = {} 	-- Events

	return tracer
end

----------------------------------
-- PROTOTYPE
----------------------------------

function prototype:Test(unit)
	if not UnitExists(unit) then return end
	--print("aasdasd",unit,self.attribute(unit),self.goal)
	if self.attribute(unit) == self.goal then
		return true
	end
end

function prototype:TestFocus()
	if not UnitExists("focus") then return end
	if self.attribute("focus") == self.goal then
		return true
	end
end

function prototype:SetCallback(obj,event)
	self.callbacks[event] = function() obj[event](obj) end
end

function prototype:Fire(event)
	if self.callbacks[event] then
		self.callbacks[event]()
	end
end

function prototype:Execute()
	local flag
	self.first = nil

	-- Raid unit tests
	for _,unit in pairs(unit_to_unittarget) do
		if self:Test(unit) then
			self.first,flag = unit,true
			break
		end
	end

	-- Focus test
	if not self.first then
		if self:TestFocus() then 
			self.first,flag = "focus",true
		end
	end

	if flag then
		if self.s == LOST then
			self.s = ACQUIRED
			self:Fire("TRACER_ACQUIRED")
		end
		self:Fire("TRACER_UPDATE")
	elseif self.s == ACQUIRED then
		self.s = LOST
		self:Fire("TRACER_LOST")
	end
	--print("tracer execute",self.first,flag,self.s)
end

function prototype:Execute2()
	self.first = nil
	local flag = self.attribute(self.goal)
	if flag then
		self.first = self.goal
		if self.s == LOST then
			self.s = ACQUIRED
			self:Fire("TRACER_ACQUIRED")
		end
		self:Fire("TRACER_UPDATE")
	elseif self.s == ACQUIRED then
		self.s = LOST
		self:Fire("TRACER_LOST")
	end
end

----------------------------------
-- API
----------------------------------

function prototype:Track(trackType, goal)
	local info = trackInfos[trackType]
	--print("track",trackType, goal,info.attribute)
	--[===[@debug@
	assert(info)
	assert(type(goal) == info.goalType)
	--@end-debug@]===]
	self.attribute = info.attribute
	self.func = info.func
	self.goal = goal
end

function prototype:IsOpen()
	return self.handle
end

function prototype:Open()
	if self.handle then return end
	--[===[@debug@
	assert(self.goal)
	assert(self.attribute)
	--@end-debug@]===]
	self.handle = self:ScheduleRepeatingTimer(self.func, DELAY)
end

function prototype:Close()
	if not self.handle then return end
	self.goal = nil; self.attribute = nil
	self:CancelTimer(self.handle,true)
	self.handle = nil
	self.first = nil
	self.func = nil
	self.s = LOST
end

function prototype:First() 
	return self.first
end
