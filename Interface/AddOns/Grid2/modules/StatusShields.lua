-- Shields absorb status, created by Michael

local Shields = Grid2.statusPrototype:new("shields")

local Grid2 = Grid2
local min   = math.min
local fmt   = string.format
local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitHealthMax = Grid2.Globals.UnitHealthMax

function Shields:UpdateHealthMax(_, func)
	UnitHealthMax = func
	self:UpdateAllIndicators()
end

function Shields:OnEnable()
	self:UpdateDB()
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:RegisterMessage("Grid2_Update_UnitHealthMax", "UpdateHealthMax")
end

function Shields:OnDisable()
	self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	self:UnregisterMessage("Grid2_Update_UnitHealthMax")
end

function Shields:UNIT_ABSORB_AMOUNT_CHANGED(_,unit)
	self:UpdateIndicators(unit)
end

function Shields:GetColor(unit)
	local c
	local amount = UnitGetTotalAbsorbs(unit) or 0
	local dbx = self.dbx
	if amount > dbx.thresholdMedium then
		c = dbx.color1
	elseif amount > dbx.thresholdLow then
		c = dbx.color2
	else
		c = dbx.color3
	end
	return c.r, c.g, c.b, c.a
end

function Shields:GetText(unit)
	return fmt("%.1fk", (UnitGetTotalAbsorbs(unit) or 0) / 1000 )
end

-- Using a user defined max shield value (used by bar indicators)
local function GetPercentCustomMax(self, unit)
	return (UnitGetTotalAbsorbs(unit) or 0) / self.maxShieldValue
end
-- Use unit maximum health as max shield value (used by bar indicators)
local function GetPercentHealthMax(_, unit)
	return (UnitGetTotalAbsorbs(unit) or 0) / UnitHealthMax(unit)
end

local function IsActiveNormal(_, unit)
	return (UnitGetTotalAbsorbs(unit) or 0)>0
end

local function IsActiveBLink(self, unit)
	local value = UnitGetTotalAbsorbs(unit) or 0
	if value>0 then
		if value>self.blinkThreshold then
			return true
		else	
			return "blink"
		end	
	end
end

function Shields:UpdateDB()
	self.maxShieldValue = self.dbx.maxShieldValue
	self.blinkThreshold = self.dbx.blinkThreshold
	self.GetPercent     = self.maxShieldValue and GetPercentCustomMax or GetPercentHealthMax
	self.IsActive       = self.blinkThreshold and IsActiveBLink or IsActiveNormal
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Shields, { "color", "percent", "text" }, baseKey, dbx)
	return Shields
end

Grid2.setupFunc["shields"] = Create

Grid2:DbSetStatusDefaultValue( "shields", { type = "shields", thresholdMedium = 50000, thresholdLow = 25000,  colorCount = 3,
	color1 = { r = 0, g = 1,   b = 0, a=1 },
	color2 = { r = 1, g = 0.5, b = 0, a=1 },
	color3 = { r = 1, g = 1,   b = 0, a=1 },
} ) 
