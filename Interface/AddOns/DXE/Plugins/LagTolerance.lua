-- Lag Tolerance
--------------------------------------------

local addon = DXE
local L = addon.L

--local ipairs, pairs = ipairs, pairs
--local remove,wipe = table.remove,table.wipe
--local match,len,format,split,find = string.match,string.len,string.format,string.split,string.find
--local GetTime = GetTime

local defaults = {
	profile = {
		enabled = true,
		Offset = 0,
		Interval = 30,
	},
}
----------------------------------
-- INITIALIZATION
----------------------------------

local module = addon:NewModule("LagTolerance","AceEvent-3.0", "AceTimer-3.0")
addon.LagTolerance = module

local db,pfl

function module:RefreshProfile() pfl = db.profile end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("LagTolerance", defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")
	
	--addon.RegisterCallback(self,"SetActiveEncounter","Set")
	if pfl.enabled then
		SetCVar("reducedLagTolerance", 1);
		self:ScheduleRepeatingTimer("LagTolerance", self.db.profile.Interval)
		self:ScheduleTimer("LagTolerance", 2)
	end
end

function module:LagTolerance()
	local currentPing = select(4, GetNetStats())
	--print("lagto",currentPing)
	if currentPing ~= 0 then
		local lagvalue = math.ceil(math.min(currentPing, 400)) + self.db.profile.Offset
		SetCVar("maxSpellStartRecoveryOffset", tostring(lagvalue))
	end
end
--[[
---------------------------------------------
-- Encounter Load/Start/Stop
---------------------------------------------
function module:Set(_,data)
	if pfl.enabled then
		addon.RegisterCallback(self,"StartEncounter","Start")
		addon.RegisterCallback(self,"StopEncounter","Stop")
	end
end

function module:Start(_,...)
	self:ScheduleRepeatingTimer("LagTolerance", self.db.profile.Interval)
	self:ScheduleTimer("LagTolerance", 2)
end

function module:Stop()
	self:CancelAllTimers()
end--]]