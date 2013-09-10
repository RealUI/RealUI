--[[
Created by Grid2 original authors, modified by Michael
--]]

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local HealthCurrent = Grid2.statusPrototype:new("health-current", false)
local HealthLow = Grid2.statusPrototype:new("health-low",false)
local FeignDeath = Grid2.statusPrototype:new("feign-death", false)
local HealthDeficit = Grid2.statusPrototype:new("health-deficit", false)
local Heals = Grid2.statusPrototype:new("heals-incoming", false)
local Death = Grid2.statusPrototype:new("death", true)

local Grid2 = Grid2
local GetTime = GetTime
local UnitHealth = UnitHealth
local UnitHealthMax = UnitHealthMax
local UnitIsDead = UnitIsDead
local UnitIsGhost = UnitIsGhost
local UnitIsDeadOrGhost = UnitIsDeadOrGhost
local UnitIsFeignDeath = UnitIsFeignDeath
local UnitGetIncomingHeals = UnitGetIncomingHeals
local fmt = string.format
local select = select
local next = next

-- Health statuses update function
local statuses = {} 

local function UpdateIndicators(unit)
	for status in next, statuses do
		status:UpdateIndicators(unit)
	end
end

-- Events management
local RegisterEvent, UnregisterEvent
do
	local frame
	local Events = {}
	function RegisterEvent(event, func)
		if not frame then
			frame = CreateFrame("Frame", nil, Grid2LayoutFrame)
			frame:SetScript( "OnEvent",  function(_, event, ...) Events[event](...) end )
		end
		if not Events[event] then frame:RegisterEvent(event) end	
		Events[event] = func
	end	
	function UnregisterEvent(...)
		if frame then 
			for i=select("#",...),1,-1 do
				local event = select(i,...)
				if Events[event] then
					frame:UnregisterEvent( event )
					Events[event] = nil
				end	
			end
		end
	end
end

-- Quick/Instant Health management
local EnableQuickHealth, DisableQuickHealth
do
	local roster_units = Grid2.roster_units
	local UnitHealthOriginal = UnitHealth
	local min = math.min
	local max = math.max
	local strlen = strlen
	local health_cache = {}
	local HealthEvents = { SPELL_DAMAGE = -15, RANGE_DAMAGE = -15, SPELL_PERIODIC_DAMAGE = -15, 
						   DAMAGE_SHIELD = -15, DAMAGE_SPLIT = -15, ENVIRONMENTAL_DAMAGE = -13, 
						   SWING_DAMAGE = -12, SPELL_PERIODIC_HEAL = 15, SPELL_HEAL = 15 }
	local function UnitQuickHealth(unit)
		return health_cache[unit] or UnitHealthOriginal(unit)
	end
	local function RosterUpdateEvent()
		wipe(health_cache)
	end
	local function HealthChangedEvent(unit)
		if strlen(unit)<8 then  -- Ignore Pets
			local h = UnitHealthOriginal(unit)
			if h==health_cache[unit] then return end
			health_cache[unit] = h
		end	
		UpdateIndicators(unit)
	end 
	local function CombatLogEvent(...)
		local sign = HealthEvents[select(2,...)] 
		if sign then
			local unit = roster_units[select(8,...)]
			if unit and strlen(unit)<8 then  
				local health
				if sign>0 then
					health = min( (health_cache[unit] or UnitHealthOriginal(unit)) + select(sign,...), UnitHealthMax(unit) )
				elseif sign<0 then
					health = max( (health_cache[unit] or UnitHealthOriginal(unit)) - select(-sign,...), 0 )
				end	
				if health~=health_cache[unit] then
					health_cache[unit] = health
					UpdateIndicators(unit)
				end
			end	
		end	
	end
	
	
	
	function EnableQuickHealth()
		if HealthCurrent.dbx.quickHealth then
			RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CombatLogEvent)
			RegisterEvent("GROUP_ROSTER_UPDATE", RosterUpdateEvent)
			RegisterEvent("PARTY_MEMBER_CHANGED", RosterUpdateEvent)
			RegisterEvent("UNIT_HEALTH_FREQUENT", HealthChangedEvent)
			RegisterEvent("UNIT_MAXHEALTH"      , HealthChangedEvent)
			UnitHealth = UnitQuickHealth
		end	
	end
	function DisableQuickHealth()
		UnitHealth = UnitHealthOriginal
		UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "GROUP_ROSTER_UPDATE", "PARTY_MEMBER_CHANGED", "UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH")
	end
end

-- Functions shared by several Health statuses
local function Health_RegisterEvents()
	RegisterEvent("UNIT_HEALTH_FREQUENT", UpdateIndicators )
	RegisterEvent("UNIT_MAXHEALTH", UpdateIndicators )
	EnableQuickHealth()
end

local function Health_UnregisterEvents()
	UnregisterEvent( "UNIT_HEALTH_FREQUENT", "UNIT_MAXHEALTH" )
	DisableQuickHealth() 
end

local function Health_UpdateStatuses()
	if next(statuses) then
		local new = (HealthCurrent.dbx.quickHealth or false)
		local cur = (UnitHealth == UnitQuickHealth)
		if new~=cur then
			Health_UnregisterEvents()
			Health_RegisterEvents()
		end	
	end	
end

local function Health_Enable(status)
	if not next(statuses) then Health_RegisterEvents() end
	statuses[status] = true
end	

local function Health_Disable(status)
	statuses[status] = nil
	if not next(statuses) then Health_UnregisterEvents() end	
end

-- health-current status
HealthCurrent.OnEnable  = Health_Enable
HealthCurrent.OnDisable = Health_Disable
HealthCurrent.IsActive  = Grid2.statusLibrary.IsActive

function HealthCurrent_GetPercent(self,unit)
	local m = UnitHealthMax(unit)
	return m == 0 and 0 or UnitHealth(unit) / m 
end

local function HealthCurrent_GetPercentDFH(self, unit)
	if UnitIsDeadOrGhost(unit) then return 1 end
	local m = UnitHealthMax(unit)
	return m == 0 and 0 or UnitHealth(unit) / m 
end

function HealthCurrent:GetText(unit)
	return fmt("%.1fk", UnitHealth(unit) / 1000)
end

function HealthCurrent:GetColor(unit)
	local f,t
	local p = self:GetPercent(unit)
	if p>=0.5 then
		f,t,p = self.color2, self.color1, (p-0.5)*2
	else
		f,t,p = self.color3, self.color2, p*2
	end
	return (t.r-f.r)*p+f.r , (t.g-f.g)*p+f.g , (t.b-f.b)*p+f.b, (t.a-f.a)*p+f.a
end

function HealthCurrent:UpdateDB()
	self.GetPercent = self.dbx.deadAsFullHealth and HealthCurrent_GetPercentDFH or HealthCurrent_GetPercent
	self.color1 = Grid2:MakeColor(self.dbx.color1)
	self.color2 = Grid2:MakeColor(self.dbx.color2)
	self.color3 = Grid2:MakeColor(self.dbx.color3)
	Health_UpdateStatuses()
end

local function CreateHealthCurrent(baseKey, dbx)
	Grid2:RegisterStatus(HealthCurrent, {"percent", "text", "color"}, baseKey, dbx)
	HealthCurrent:UpdateDB()
	return HealthCurrent
end

Grid2.setupFunc["health-current"] = CreateHealthCurrent

Grid2:DbSetStatusDefaultValue( "health-current", {type = "health-current", colorCount=3, color1 = {r=0,g=1,b=0,a=1}, color2 = {r=1,g=1,b=0,a=1}, color3 = {r=1,g=0,b=0,a=1}  })

-- health-low status
HealthLow.OnEnable  = Health_Enable
HealthLow.OnDisable = Health_Disable
HealthLow.GetColor  = Grid2.statusLibrary.GetColor

function HealthLow:IsActive1(unit)
	return HealthCurrent:GetPercent(unit) < self.dbx.threshold
end

function HealthLow:IsActive2(unit)
	return UnitHealth(unit) < self.dbx.threshold
end

function HealthLow:UpdateDB()
	self.IsActive = self.dbx.threshold<=1 and self.IsActive1 or self.IsActive2
end

local function CreateHealthLow(baseKey, dbx)
	Grid2:RegisterStatus(HealthLow, {"color"}, baseKey, dbx)
	HealthLow:UpdateDB()
	return HealthLow
end

Grid2.setupFunc["health-low"] = CreateHealthLow

Grid2:DbSetStatusDefaultValue( "health-low", {type = "health-low", threshold = 0.4, color1 = {r=1,g=0,b=0,a=1}})

-- feign-death status
local feign_cache = {}

FeignDeath.GetColor = Grid2.statusLibrary.GetColor

local function FeignDeathUpdateEvent(unit)
	local feign = UnitIsFeignDeath(unit)
	if feign~=feign_cache[unit] then
		feign_cache[unit] = feign
		FeignDeath:UpdateIndicators(unit)
	end
end

function FeignDeath:OnEnable()
	RegisterEvent( "UNIT_AURA", FeignDeathUpdateEvent )
end

function FeignDeath:OnDisable()
	UnregisterEvent( "UNIT_AURA" )
	wipe(feign_cache)
end

function FeignDeath:IsActive(unit)
	return UnitIsFeignDeath(unit)
end

local feignText = L["FD"]
function FeignDeath:GetText(unit)
	return feignText
end

function Death:GetPercent(unit)
	return self.dbx.color1.a, feignText
end

local function CreateFeignDeath(baseKey, dbx)
	Grid2:RegisterStatus(FeignDeath, {"color", "percent", "text"}, baseKey, dbx)
	return FeignDeath
end

Grid2.setupFunc["feign-death"] = CreateFeignDeath

Grid2:DbSetStatusDefaultValue( "feign-death", {type = "feign-death", color1 = {r=1,g=.5,b=1,a=1}})

-- health-deficit status
HealthDeficit.OnEnable  = Health_Enable
HealthDeficit.OnDisable = Health_Disable
HealthDeficit.GetColor  = Grid2.statusLibrary.GetColor

function HealthDeficit:IsActive(unit)
	return self:GetPercent(unit) >= self.dbx.threshold
end

function HealthDeficit:GetText(unit)
	return fmt("%.1fk", (UnitHealth(unit) - UnitHealthMax(unit)) / 1000)
end

function HealthDeficit:GetPercent(unit)
	local m = UnitHealthMax(unit)
	return m == 0 and 1 or ( m - UnitHealth(unit) ) / m
end

function HealthDeficit:GetPercentText(unit)
	return fmt( "%.0f%%", -self:GetPercent(unit)*100 )
end

local function CreateHealthDeficit(baseKey, dbx)
	Grid2:RegisterStatus(HealthDeficit, { "percent", "color", "text"}, baseKey, dbx)
	return HealthDeficit
end

Grid2.setupFunc["health-deficit"] = CreateHealthDeficit

Grid2:DbSetStatusDefaultValue( "health-deficit", {type = "health-deficit", color1 = {r=1,g=1,b=1,a=1}, threshold = 0.05})

-- heals-incoming status
local heals_cache= setmetatable( {}, {__index = function() return 0 end} )

Heals.GetColor = Grid2.statusLibrary.GetColor

local function Heals_get_with_user(unit)
	return UnitGetIncomingHeals(unit) or 0
end
local function Heals_get_without_user(unit)
	return (UnitGetIncomingHeals(unit) or 0)  - (UnitGetIncomingHeals(unit, "player") or 0)
end
local Heals_GetHealAmount = Heals_get_without_user

local function HealsUpdateEvent(unit)
	if unit then
		local cache = heals_cache[unit]
		local heal = Heals_GetHealAmount(unit)
		if heal<Heals.minimum then heal = 0 end
		if cache ~= heal then
			heals_cache[unit] = heal
			Heals:UpdateIndicators(unit)
		end
	end
end

function Heals:UpdateDB()
	local m = self.dbx.flags
	self.minimum = (m and m>1 and m ) or 1
	Heals_GetHealAmount = self.dbx.includePlayerHeals and Heals_get_with_user or Heals_get_without_user
end

function Heals:OnEnable()
	Health_Enable(self)
	RegisterEvent("UNIT_HEAL_PREDICTION", HealsUpdateEvent)
	self:UpdateDB()
end

function Heals:OnDisable()
	wipe(heals_cache)
	UnregisterEvent("UNIT_HEAL_PREDICTION")
	Health_Disable(self)
end

function Heals:IsActive(unit)
	return heals_cache[unit] > 1
end

function Heals:GetText(unit)
	return fmt("+%.1fk", heals_cache[unit] / 1000)
end

function Heals:GetPercent(unit)
	local m = UnitHealthMax(unit)
	if m ~= 0 then
		local h = UnitHealth(unit)
		local v = heals_cache[unit] 
		local d = m - h
		return v < d and v / m or d / m
	end
	return 0
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Heals, {"color", "text", "percent"}, baseKey, dbx)
	return Heals
end

Grid2.setupFunc["heals-incoming"] = Create

Grid2:DbSetStatusDefaultValue( "heals-incoming", {type = "heals-incoming", includePlayerHeals = false, flags = 0, color1 = {r=0,g=1,b=0,a=1}})

-- death status
local textDeath = L["DEAD"]
local textGhost = L["GHOST"]
local dead_cache = {}

Death.GetColor = Grid2.statusLibrary.GetColor

local function DeathUpdateUnit(unit, noUpdate)
	local new = UnitIsDeadOrGhost(unit) and (UnitIsGhost(unit) and textGhost or textDeath) or false
	if new ~= dead_cache[unit] then
		dead_cache[unit] = new
		if not noUpdate then 
			if new then
				if heals_cache[unit]~=0 then
					heals_cache[unit] = 0
					Heals:UpdateIndicators(unit)
				end	
				if HealthCurrent.enabled then
					HealthCurrent:UpdateIndicators(unit)
				end
			end
			Death:UpdateIndicators(unit) 
		end
	end
end

function Death:Grid_UnitUpdated(_, unit)
	DeathUpdateUnit(unit, true)	
end
	
function Death:Grid_UnitLeft(_, unit)
	dead_cache[unit] = nil
end

function Death:OnEnable()
	RegisterEvent( "UNIT_HEALTH", DeathUpdateUnit )
	self:RegisterMessage("Grid_UnitUpdated")
	self:RegisterMessage("Grid_UnitLeft")
end

function Death:OnDisable()
	UnregisterEvent( "UNIT_HEALTH" )
	self:UnregisterMessage("Grid_UnitUpdated")
	self:UnregisterMessage("Grid_UnitLeft")
	wipe(dead_cache)
end

function Death:IsActive(unit)
	if dead_cache[unit] then return true end
end

function Death:GetIcon()
	return [[Interface\TargetingFrame\UI-TargetingFrame-Skull]]
end

function Death:GetPercent(unit)
	return self.dbx.color1.a, dead_cache[unit]
end

function Death:GetText(unit)
	return dead_cache[unit]
end

local function CreateDeath(baseKey, dbx)
	Grid2:RegisterStatus(Death, {"color", "icon", "percent", "text"}, baseKey, dbx)
	return Death
end

Grid2.setupFunc["death"] = CreateDeath

Grid2:DbSetStatusDefaultValue( "death", {type = "death", color1 = {r=1,g=1,b=1,a=1}})
