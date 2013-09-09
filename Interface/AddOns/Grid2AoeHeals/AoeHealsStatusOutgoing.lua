-- Status: Aoe-OutgoingHeals

local AOEM = Grid2:GetModule("Grid2AoeHeals")
local classSpells = ({ SHAMAN = {1064, 73921}, PRIEST = {34861, 64844, 15237}, PALADIN = {85222} })[AOEM.playerClass]
if not classSpells then return end

local Grid2 = Grid2
local next = next
local select = select
local GetTime = GetTime

local OutgoingHeal
local timer
local playerGUID
local activeTime
local timerDelay
local spells = {}
local icons = {}
local heal_cache = {}
local time_cache = {}

local function TimerEvent()
	local ct = GetTime()
	for unit,ut in next, time_cache do
		if ct-ut>activeTime then
			heal_cache[unit] = nil
			time_cache[unit] = nil
			OutgoingHeal:UpdateIndicators(unit)
		end
	end
	if not next(time_cache) then
		Grid2:CancelTimer(timer)
		timer = nil
	end
end

local function CombatLogEvent(...)
	local spellName = select(14,...)
	if select(3,...)=="SPELL_HEAL" and spells[spellName] and select(5,...)==playerGUID then
		local unit = Grid2:GetUnitidByGUID( select(9,...) )
		if unit then
			local prev = heal_cache[unit]
			heal_cache[unit] = spellName
			time_cache[unit] = GetTime()
			if prev~=spellName then
				OutgoingHeal:UpdateIndicators(unit)
				if not timer then
					timer = Grid2:ScheduleRepeatingTimer(TimerEvent, timerDelay)
				end	
			end	
		end
	end
end

local function OnEnable(self)
	self:UpdateDB()
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CombatLogEvent)
end

local function OnDisable(self)
	wipe(heal_cache)
	wipe(time_cache)
	self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
end

local function IsActive(self, unit)
	if heal_cache[unit] then return true end
end

local function GetColor(self, unit)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

local function GetIcon(self, unit)
	local spell = heal_cache[unit]
	if spell then return icons[ spell ] end	
end

local function GetText(self, unit)
	return heal_cache[unit]
end

local function UpdateDB(self)
	wipe(icons)
	wipe(spells)
	for _,spell in next, self.dbx.spells do
		local name,_,icon = GetSpellInfo(spell)
		if name then
			spells[name] = true
			icons[name]  = icon
		end	
	end
	activeTime = self.dbx.activeTime or 2
	timerDelay = math.min(0.1, activeTime / 2 )
end

Grid2.setupFunc["aoe-OutgoingHeals"] = function(baseKey, dbx)
	playerGUID             = UnitGUID("player")
	OutgoingHeal           = OutgoingHeal or Grid2.statusPrototype:new("aoe-OutgoingHeals")
	OutgoingHeal.OnEnable  = OnEnable
	OutgoingHeal.OnDisable = OnDisable
	OutgoingHeal.IsActive  = IsActive
	OutgoingHeal.GetColor  = GetColor
	OutgoingHeal.GetIcon   = GetIcon
	OutgoingHeal.GetText   = GetText
	OutgoingHeal.UpdateDB  = UpdateDB
	Grid2:RegisterStatus(OutgoingHeal, {"color", "icon", "text"}, baseKey, dbx)
	return OutgoingHeal
end

Grid2:DbSetStatusDefaultValue( "aoe-OutgoingHeals", { type = "aoe-OutgoingHeals", 
	spells = classSpells, activeTime= 2, color1 = {r=0,g=0.8,b=1,a=1} 
})
