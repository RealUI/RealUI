local AbsorbBelowMaxHP = Grid2.statusPrototype:new("absorb-below-maxHP", false) -- color, percent
local AbsorbAboveMaxHP = Grid2.statusPrototype:new("absorb-above-maxHP", false) -- color, percent
local AbsorbValue = Grid2.statusPrototype:new("absorb-total") -- color, text

local UnitGetTotalAbsorbs = UnitGetTotalAbsorbs
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local fmt = string.format

local eventFrame = CreateFrame("frame")
local AbsorbAboveMaxHP_enabled
local AbsorbBelowMaxHP_enabled

local absorbAboveMaxHP_cache = setmetatable( {}, {__index = function() return 0 end} )
local absorbBelowMaxHP_cache = setmetatable( {}, {__index = function() return 0 end} )

eventFrame:SetScript("OnEvent", function(self, event, unit)
	local hp = UnitHealth(unit)
	local maxHP = UnitHealthMax(unit)
	local shield = UnitGetTotalAbsorbs(unit)

	absorbBelowMaxHP_cache[unit] = (hp+shield)/maxHP > 1 and (maxHP-hp)/maxHP or shield/maxHP
	AbsorbBelowMaxHP:UpdateIndicators(unit)
	
	absorbAboveMaxHP_cache[unit] = (hp+shield-maxHP)/maxHP
	AbsorbAboveMaxHP:UpdateIndicators(unit)
end)

-- AbsorbBelowMaxHP
function AbsorbBelowMaxHP:OnEnable()
	eventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	eventFrame:RegisterEvent("UNIT_MAXHEALTH")
	eventFrame:RegisterEvent("UNIT_HEALTH")
	eventFrame:RegisterEvent("UNIT_HEALTH_FREQUENT")
	AbsorbBelowMaxHP_enabled = true
end

function AbsorbBelowMaxHP:OnDisable()
	AbsorbBelowMaxHP_enabled = false
	if not (AbsorbAboveMaxHP_enabled or AbsorbBelowMaxHP_enabled) then
		eventFrame:UnregisterAllEvents()
	end
end

function AbsorbBelowMaxHP:IsActive(unit)
	return absorbBelowMaxHP_cache[unit] > 0
end

function AbsorbBelowMaxHP:GetPercent(unit)
	return absorbBelowMaxHP_cache[unit]
end

AbsorbBelowMaxHP.GetColor = Grid2.statusLibrary.GetColor

Grid2.setupFunc["absorb-below-maxHP"] = function(baseKey, dbx)
	Grid2:RegisterStatus(AbsorbBelowMaxHP, {"color", "percent"}, baseKey, dbx)

	return AbsorbBelowMaxHP
end
Grid2:DbSetStatusDefaultValue("absorb-below-maxHP", {type = "absorb-below-maxHP", color1 = {r=0,g=.6,b=1,a=.6}})


-- AbsorbAboveMaxHP
function AbsorbAboveMaxHP:OnEnable()
	eventFrame:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
	eventFrame:RegisterEvent("UNIT_MAXHEALTH")
	eventFrame:RegisterEvent("UNIT_HEALTH")
	eventFrame:RegisterEvent("UNIT_HEALTH_FREQUENT")
	AbsorbAboveMaxHP_enabled = true
end

function AbsorbAboveMaxHP:OnDisable()
	AbsorbAboveMaxHP_enabled = false
	if not (AbsorbAboveMaxHP_enabled or AbsorbBelowMaxHP_enabled) then
		eventFrame:UnregisterAllEvents()
	end
end

function AbsorbAboveMaxHP:IsActive(unit)
	return absorbAboveMaxHP_cache[unit] > 0
end

function AbsorbAboveMaxHP:GetPercent(unit)
	return absorbAboveMaxHP_cache[unit]
end

AbsorbAboveMaxHP.GetColor = Grid2.statusLibrary.GetColor

Grid2.setupFunc["absorb-above-maxHP"] = function(baseKey, dbx)
	Grid2:RegisterStatus(AbsorbAboveMaxHP, {"color", "percent"}, baseKey, dbx)

	return AbsorbAboveMaxHP
end
Grid2:DbSetStatusDefaultValue("absorb-above-maxHP", {type = "absorb-above-maxHP", color1 = {r=0,g=.2,b=1,a=.8}})

-- AbsorbValue
function AbsorbValue:OnEnable()
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
end

function AbsorbValue:UNIT_ABSORB_AMOUNT_CHANGED(_, unit)
	self:UpdateIndicators(unit)
end

function AbsorbValue:OnDisable()
	self:UnregisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")
end

function AbsorbValue:IsActive(unit)
	return UnitGetTotalAbsorbs(unit) > 0
end

function AbsorbValue:GetText(unit)
	return fmt("%.1fk", UnitGetTotalAbsorbs(unit) / 1000)
end

AbsorbValue.GetColor = Grid2.statusLibrary.GetColor

Grid2.setupFunc["absorb-total"] = function(baseKey, dbx)
	Grid2:RegisterStatus(AbsorbValue, {"color", "text"}, baseKey, dbx)

	return AbsorbValue
end
Grid2:DbSetStatusDefaultValue("absorb-total", {type = "absorb-total", color1 = {r=1,g=1,b=1,a=1}})