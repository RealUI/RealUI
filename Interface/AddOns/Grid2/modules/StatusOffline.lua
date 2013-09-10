local Offline = Grid2.statusPrototype:new("offline")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local GetTime = GetTime
local UnitIsConnected = UnitIsConnected

local timer
local offline = {}

-- Using a timer because UNIT_CONNECTION is not always fired when a unit reconnects :(
-- UnitIsConnected() returns wrong result for the first 20-25 seconds 
-- after the player disconnects so the code ignores the result in this case.
local function TimerEvent()
	local ct = GetTime()
	for unit, dt in next,offline do
		if UnitIsConnected(unit) and (ct-dt)>=25 then
			offline[unit] = nil
			Offline:UpdateIndicators(unit)
		end
	end
	if not next(offline) then
		Grid2:CancelTimer(timer); timer = nil
	end
end

function Offline:UNIT_CONNECTION(_, unit, hasConnected)
	if Grid2:IsUnitNoPetInRaid(unit) then
		self:SetConnected(unit, hasConnected)
		self:UpdateIndicators(unit)
	end	
end

function Offline:Grid_UnitUpdated(_, unit)
	if Grid2:IsUnitNoPetInRaid(unit) then
		self:SetConnected( unit, UnitIsConnected(unit) )
	end	
end

function Offline:Grid_UnitLeft(_, unit)
	offline[unit] = nil
end

function Offline:SetConnected(unit, connected)
	if connected then
		offline[unit] = nil
	else
		offline[unit] = GetTime()
		if not timer then 
			timer = Grid2:ScheduleRepeatingTimer(TimerEvent, 2)
		end
	end
end

function Offline:OnEnable()
	self:RegisterEvent("UNIT_CONNECTION")
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
end

function Offline:OnDisable()
	self:UnregisterEvent("UNIT_CONNECTION")
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	wipe(offline)	
end

function Offline:IsActive(unit)
	if offline[unit] then return true end
end

local text = L["Offline"]
function Offline:GetText(unit)
	return text
end

function Offline:GetPercent(unit)
	return self.dbx.color1.a, text
end

function Offline:GetTexCoord()
 return 0.2, 0.8, 0.2, 0.8
end

function Offline:GetIcon()
	return "Interface\\CharacterFrame\\Disconnect-Icon"
end 

Offline.GetColor = Grid2.statusLibrary.GetColor

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Offline, {"color", "icon", "percent", "text"}, baseKey, dbx)

	return Offline
end

Grid2.setupFunc["offline"] = Create

Grid2:DbSetStatusDefaultValue( "offline", {type = "offline", color1 = {r=1,g=1,b=1,a=1}})
