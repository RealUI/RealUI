local Threat = Grid2.statusPrototype:new("threat")

local Grid2 = Grid2
local UnitExists = UnitExists
local UnitThreatSituation = UnitThreatSituation

Threat.UpdateAllUnits = Grid2.statusLibrary.UpdateAllUnits

function Threat:UpdateUnit(_, unit)
	if unit then -- unit can be nil which is so wtf
		self:UpdateIndicators(unit)
	end
end

function Threat:OnEnable()
	self:UpdateDB()
	self:RegisterEvent("UNIT_THREAT_SITUATION_UPDATE", "UpdateUnit")
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateAllUnits")
end

function Threat:OnDisable()
	self:UnregisterEvent("UNIT_THREAT_SITUATION_UPDATE")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
end

function Threat:UpdateDB()
	self.colors      = { self.dbx.color1, self.dbx.color2, self.dbx.color3 }
	self.activeValue = self.dbx.disableBlink or "blink"
end

-- 1 = not tanking, higher threat than tank
-- 2 = insecurely tanking.
-- 3 = securely tanking something
function Threat:IsActive(unit)
	local threat = UnitExists(unit) and UnitThreatSituation(unit) -- hack thanks Potje
	if threat and threat > 0 then
		return self.activeValue
	end
end

function Threat:GetColor(unit)
	local threat= UnitThreatSituation(unit)
	local color = self.colors[threat]
	return color.r, color.g, color.b, color.a
end

function Threat:GetIcon(unit)
	return [[Interface\RaidFrame\UI-RaidFrame-Threat]]
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Threat, {"color", "icon"}, baseKey, dbx)

	return Threat
end

Grid2.setupFunc["threat"] = Create

Grid2:DbSetStatusDefaultValue( "threat", {type = "threat", colorCount = 3, color1 = {r=1,g=0,b=0,a=1}, color2 = {r=.5,g=1,b=1,a=1}, color3 = {r=1,g=1,b=1,a=1}} )
