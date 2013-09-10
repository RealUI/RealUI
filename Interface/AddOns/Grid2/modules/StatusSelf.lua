local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local Status = Grid2.statusPrototype:new("self")

local UnitIsUnit = UnitIsUnit

function Status:IsActive(unit)
	return UnitIsUnit(unit, "player")
end

local text = L["Me"]
function Status:GetText()
	return text
end

Status.GetColor = Grid2.statusLibrary.GetColor

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Status, {"color", "text"}, baseKey, dbx)

	return Status
end

Grid2.setupFunc["self"] = Create

Grid2:DbSetStatusDefaultValue( "self", {type = "self", color1 = { r = 0.25, g = 1.0, b = 0.25, a = 1 } })
