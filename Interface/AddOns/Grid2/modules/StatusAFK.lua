--[[ afk status, created by Potje, modified by Michael ]]--

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")

local AFK = Grid2.statusPrototype:new("afk")

local Grid2 = Grid2
local UnitIsAFK = UnitIsAFK

AFK.GetColor = Grid2.statusLibrary.GetColor
AFK.UpdateAllUnits = Grid2.statusLibrary.UpdateAllUnits

function AFK:UpdateUnit(_, unit)
	if unit then
		self:UpdateIndicators(unit)
	end
end

function AFK:OnEnable()
	self:RegisterEvent("PLAYER_FLAGS_CHANGED", "UpdateUnit")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateAllUnits")
	self:RegisterEvent("READY_CHECK", "UpdateAllUnits")
	self:RegisterEvent("READY_CHECK_FINISHED", "UpdateAllUnits")
end

function AFK:OnDisable()
	self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterEvent("READY_CHECK")
	self:UnregisterEvent("READY_CHECK_FINISHED")
end

function AFK:IsActive(unit)
	return UnitIsAFK(unit)
end

function AFK:GetText(unit)
	return L["AFK"]
end

local function CreateStatusAFK(baseKey, dbx)
	Grid2:RegisterStatus(AFK, {"color", "text"}, baseKey, dbx)
	return AFK
end

Grid2.setupFunc["afk"] = CreateStatusAFK

Grid2:DbSetStatusDefaultValue( "afk", {type = "afk",  color1= {r=1,g=0,b=0,a=1} } )
