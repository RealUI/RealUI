-- Resurrection status, created by Michael --

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Resurrection = Grid2.statusPrototype:new("resurrection")

local Grid2 = Grid2
local GetTime = GetTime
local UnitExists = UnitExists
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitHasIncomingResurrection = UnitHasIncomingResurrection
local next = next

local timer
local res_cache= {}

function Resurrection:Timer()
	for unit in next, res_cache do
		if not (UnitExists(unit) and UnitIsDeadOrGhost(unit)) then
			res_cache[unit]= nil
			self:UpdateIndicators(unit)
		end
	end
	if not next(res_cache) then
		Grid2:CancelTimer(timer)
		timer = nil
	end
end

function Resurrection:INCOMING_RESURRECT_CHANGED(_, unit)
	if unit and UnitIsDeadOrGhost(unit) then
		if UnitHasIncomingResurrection(unit) then
			if res_cache[unit] ~= 1 then
				res_cache[unit]= 1
				self:UpdateIndicators(unit)
				if not timer then
					timer = Grid2:ScheduleRepeatingTimer(Resurrection.Timer, 0.25, self)
				end
			end
		else
			if res_cache[unit] == 1 then
				res_cache[unit]= 0
				self:UpdateIndicators(unit)
			end
		end
	end	
end

function Resurrection:OnEnable()
	self:RegisterEvent("INCOMING_RESURRECT_CHANGED")
end

function Resurrection:OnDisable()
	self:UnregisterEvent("INCOMING_RESURRECT_CHANGED")
	wipe(res_cache)
end

function Resurrection:IsActive(unit)
	if res_cache[unit] then
		return true
	end
end

function Resurrection:GetColor(unit)
	local c= res_cache[unit]==1 and self.dbx.color1 or self.dbx.color2
	return c.r, c.g, c.b, c.a
end

function Resurrection:GetIcon(unit)
	return "Interface\\RaidFrame\\Raid-Icon-Rez"
end

local resText1= L["Reviving"]
local resText2= L["Revived"]
function Resurrection:GetText(unit)
	return res_cache[unit]==1 and resText1 or resText2
end

Resurrection.GetBorder = Grid2.statusLibrary.GetBorder

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Resurrection, {"text","icon","color"}, baseKey, dbx)
	return Resurrection
end

Grid2.setupFunc["resurrection"] = Create

Grid2:DbSetStatusDefaultValue( "resurrection", { type = "resurrection", colorCount = 2,
	color1 = { r = 0, g = 1, b = 0, a=1 },    
	color2 = { r = 1, g = 1, b = 0, a=0.75 }, }) 
