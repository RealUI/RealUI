local Vehicle = Grid2.statusPrototype:new("vehicle")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Grid2 = Grid2
local UnitHasVehicleUI = UnitHasVehicleUI

Vehicle.UpdateAllUnits = Grid2.statusLibrary.UpdateAllUnits

function Vehicle:UpdateUnit(_, unit)
	self:UpdateIndicators(unit)
end

function Vehicle:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateAllUnits")
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "UpdateUnit")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "UpdateUnit")
end

function Vehicle:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("UNIT_ENTERED_VEHICLE")
	self:UnregisterEvent("UNIT_EXITED_VEHICLE")
end

function Vehicle:IsActive(unit)
	local owner = Grid2:GetOwnerUnitByUnit(unit)
	if owner and UnitHasVehicleUI(owner) then
		return true
	else
		return UnitHasVehicleUI(unit)
	end
end

function Vehicle:GetIcon(unit)
	return [[Interface\Vehicles\UI-Vehicles-Raid-Icon]]
end

local text = L["vehicle"]
function Vehicle:GetText(unit)
	local owner = Grid2:GetOwnerUnitByUnit(unit)
	if owner and UnitHasVehicleUI(owner) then
		return UnitName(owner)
	else
		return text
	end
end

function Vehicle:GetPercent(unit)
	return self.dbx.color1.a, text
end

Vehicle.GetColor = Grid2.statusLibrary.GetColor

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Vehicle, {"color", "icon", "percent", "text"}, baseKey, dbx)

	return Vehicle
end

Grid2.setupFunc["vehicle"] = Create

Grid2:DbSetStatusDefaultValue( "vehicle", {type = "vehicle", color1 = {r=0,g=1,b=1,a=.75}})
