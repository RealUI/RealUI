-- Color, CreatureColor, FriendColor, Charmed, ClassColor

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2")
local Grid2 = Grid2
local UnitClass = UnitClass
local UnitIsEnemy= UnitIsEnemy
local UnitIsCharmed= UnitIsCharmed
local UnitCreatureType= UnitCreatureType
local UnitHasVehicleUI= UnitHasVehicleUI

-- Simple static color status
local Color = {
	IsActive = Grid2.statusLibrary.IsActive,
	GetColor = Grid2.statusLibrary.GetColor,
	GetPercent = Grid2.statusLibrary.GetPercent,
}

Grid2.setupFunc["color"] = function(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	status:Inject(Color)
	Grid2:RegisterStatus(status, {"color","percent"}, baseKey, dbx)
	return status
end

-- Shared methods
local Shared = {}

Shared.IsActive = Color.IsActive

function Shared:UpdateUnit(_, unit)
	if unit then 
		self:UpdateIndicators(unit) 
	end	
end

function Shared:OnEnable()
	self:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", "UpdateUnit")
	self:RegisterEvent("UNIT_PORTRAIT_UPDATE", "UpdateUnit")
	self:RegisterEvent("UNIT_FLAGS", "UpdateUnit")
	self:RegisterEvent("UNIT_FACTION", "UpdateUnit")
end

function Shared:OnDisable()
	self:UnregisterEvent("UNIT_CLASSIFICATION_CHANGED")
	self:UnregisterEvent("UNIT_PORTRAIT_UPDATE")
	self:UnregisterEvent("UNIT_FLAGS")
	self:UnregisterEvent("UNIT_FACTION")
end

function Shared:GetColor(unit)
	local c = self:UnitColor(unit)
	return c.r, c.g, c.b, c.a
end

-- CreatureColor status
local CreatureColor = Grid2.statusPrototype:new("creaturecolor")

CreatureColor:Inject(Shared)

function CreatureColor:UnitColor(unit)
	local p = self.dbx
	if p.colorHostile and UnitIsCharmed(unit) and UnitIsEnemy("player", unit) then
		return p.colors.HOSTILE
	else
		local colors, color = p.colors, UnitCreatureType(unit)
		return colors[color or "UNKNOWN_UNIT"] or colors.UNKNOWN_UNIT
	end
end

Grid2.setupFunc["creaturecolor"] = function(baseKey, dbx)
	Grid2:RegisterStatus(CreatureColor, {"color"}, baseKey, dbx)
	return CreatureColor
end

Grid2:DbSetStatusDefaultValue( "creaturecolor", { type = "creaturecolor", colorHostile = true, colors= {
	HOSTILE = { r = 1, g = 0.1, b = 0.1, a = 1 },
	UNKNOWN_UNIT = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
	[L["Beast"]] = { r = 0.94, g = 0.75, b = 0.28, a = 1 },
	[L["Demon"]] = { r = 0.5, g = 0.25, b = 0.69, a = 1 },
	[L["Humanoid"]] = { r = 0.92, g = 0.67, b = 0.85, a = 1 },
	[L["Elemental"]] = { r = 0.1, g = 0.3, b = 0.9, a = 1 }, }
})

-- FriendColor status
local FriendColor = Grid2.statusPrototype:new("friendcolor")

FriendColor:Inject(Shared)

function FriendColor:UnitColor(unit)
	local dbx = self.dbx
	if dbx.colorHostile and UnitIsCharmed(unit) and UnitIsEnemy("player", unit) then
		return dbx.color3
	else
		return Grid2:UnitIsPet(unit) and dbx.color2 or dbx.color1
	end
end

Grid2.setupFunc["friendcolor"] = function(baseKey, dbx)
	Grid2:RegisterStatus(FriendColor, {"color"}, baseKey, dbx)
	return FriendColor
end 

Grid2:DbSetStatusDefaultValue( "friendcolor", { type = "friendcolor",	
	colorCount = 3,	
	color1 = { r = 0, g = 1, b = 0, a=1 },    --player 
	color2 = { r = 0, g = 1, b = 0, a=0.75 }, --pet 
	color3 = { r = 1, g = 0, b = 0, a=1 },    --hostile
})

-- Charmed status
local Charmed = Grid2.statusPrototype:new("charmed")

Charmed:Inject(Shared)
Charmed.GetColor = Color.GetColor

function Charmed:IsActive(unit)
	local owner = Grid2:GetOwnerUnitByUnit(unit)
	if not (owner and UnitHasVehicleUI(owner)) then
		return UnitIsCharmed(unit)
	end
end

local charmedText = L["Charmed"]
function Charmed:GetText(unit)
	return charmedText
end

function Charmed:GetPercent(unit)
	return self.dbx.color1.a, charmedText
end

Grid2.setupFunc["charmed"] =  function(baseKey, dbx)
	Grid2:RegisterStatus(Charmed, { "color", "text", "percent" }, baseKey, dbx)
	return Charmed
end

Grid2:DbSetStatusDefaultValue( "charmed", {type = "charmed", color1 = {r=1,g=.1,b=.1,a=1}})

-- ClassColor status
local ClassColor = Grid2.statusPrototype:new("classcolor")

ClassColor:Inject(Shared)

function ClassColor:UnitColor(unit)
	local p = self.dbx 
	local colors = p.colors
	if p.colorHostile and UnitCanAttack(unit,"player") then
		return colors.HOSTILE
	elseif Grid2:UnitIsPet(unit) then
		local c = UnitCreatureType(unit)
		return colors[c or "UNKNOWN_PET"] or colors.UNKNOWN_PET
	else
		local _, c = UnitClass(unit)
		return colors[c or "UNKNOWN_UNIT"] or colors.UNKNOWN_UNIT
	end
end

Grid2.setupFunc["classcolor"] = function(baseKey, dbx)
	Grid2:RegisterStatus(ClassColor, {"color"}, baseKey, dbx)
	return ClassColor
end

local colors = {
	HOSTILE = { r = 1, g = 0.1, b = 0.1, a = 1 },
	UNKNOWN_UNIT = { r = 0.5, g = 0.5, b = 0.5, a = 1 },
	UNKNOWN_PET = { r = 0, g = 1, b = 0, a = 1 },
	[L["Beast"]] = { r = 0.94, g = 0.76, b = 0.28, a = 1 },
	[L["Demon"]] = { r = 0.54, g = 0.25, b = 0.69, a = 1 },
	[L["Humanoid"]] = { r = 0.92, g = 0.67, b = 0.85, a = 1 },
	[L["Elemental"]] = { r = 0.1, g = 0.3, b = 0.9, a = 1 },
}
for class, color in pairs(RAID_CLASS_COLORS) do
	if not colors[class] then
		colors[class] = { r = color.r, g = color.g, b = color.b, a = 1 }
	end
end
Grid2:DbSetStatusDefaultValue( "classcolor", {type = "classcolor", colorHostile = true, colors = colors})
