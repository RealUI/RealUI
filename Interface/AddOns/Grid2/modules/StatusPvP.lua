local PvP = Grid2.statusPrototype:new("pvp")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local IsInInstance = IsInInstance
local UnitIsPVP = UnitIsPVP
local UnitIsPVPFreeForAll = UnitIsPVPFreeForAll

local pvpText = L["PvP"]
local ffaText = L["FFA"]
local ffaTexture = [[Interface\TargetingFrame\UI-PVP-FFA]]
local pvpTexture = UnitFactionGroup("player") == "Horde" and 
				   [[Interface\PVPFrame\PVP-Currency-Horde]] or 
				   [[Interface\PVPFrame\PVP-Currency-Alliance]]

PvP.GetColor = Grid2.statusLibrary.GetColor
PvP.UpdateAllUnits = Grid2.statusLibrary.UpdateAllUnits

function PvP:UNIT_FACTION(_, unit)
	self:UpdateIndicators(unit)
end

function PvP:OnEnable()
	self:RegisterEvent("UNIT_FACTION")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateAllUnits")
end

function PvP:OnDisable()
	self:UnregisterEvent("UNIT_FACTION")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
end

function PvP:IsActive(unit)
	if not IsInInstance() then
		return UnitIsPVP(unit) or UnitIsPVPFreeForAll(unit)
	end
end

function PvP:GetTexCoord(unit)
	if UnitIsPVP(unit) then
		return 0.05, 0.95, 0.05, 0.95
	else
		return 0.05, 0.605, 0.015, 0.57
	end
end

function PvP:GetIcon(unit)
	return UnitIsPVP(unit) and pvpTexture or ffaTexture
end

function PvP:GetText(unit)
	return UnitIsPVP(unit) and pvpText or ffaText
end

function PvP:GetPercent(unit)
	return self.dbx.color1.a, self:GetText(unit)
end

Grid2.setupFunc["pvp"] = function(baseKey, dbx)
	Grid2:RegisterStatus(PvP, {"color", "icon", "percent", "text"}, baseKey, dbx)
	return PvP
end

Grid2:DbSetStatusDefaultValue( "pvp", {type = "pvp", color1 = {r=0,g=1,b=1,a=.75}})
