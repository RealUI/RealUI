-- Status: Aoe-OutgoingHeals

local AOEM = Grid2:GetModule("Grid2AoeHeals")
local playerClass = AOEM.playerClass
local defaultSpells = { ["SHAMAN"] = {1064, 73921}, -- {Chain Heal, Healing Rain}
						["PRIEST"] = {34861, 23455, 88686}, -- {Circle of Healing, Holy Nova, Holy Word: Sanctuary}
						["PALADIN"] = {85222, 114871, 119952}, -- {Light of Dawn, Holy Prism, Arcing Light(Light Hammer's effect)}
						["DRUID"] = {81269}, -- {Swiftmend}
						["MONK"] = {124040, 130654, 124101, 132463}, -- {Chi Torpedo, Chi Burst, Zen Sphere: Detonate, Chi Wave}
						}
if not defaultSpells[playerClass] then return end

local Grid2 = Grid2
local next = next
local select = select
local GetTime = GetTime

local OutgoingHeal = Grid2.statusPrototype:new("aoe-OutgoingHeals")
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
	local subEvent = select(3,...)
	if (subEvent=="SPELL_HEAL" or subEvent=="SPELL_PERIODIC_HEAL") and spells[spellName] and select(5,...)==playerGUID then
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

local function ResetClassSpells(self)
	wipe(self.dbx.spells[playerClass])
	for _, spell in next, defaultSpells[playerClass] do
		table.insert(self.dbx.spells[playerClass], spell)
	end
end

local function GetSpellID(self, name)
	local id = 0
	if tonumber(name) then
		return tonumber(name)
	end
	for _,spell in next, defaultSpells[playerClass] do
		local spellName = GetSpellInfo(spell)
		if spellName == name then
			return spell
		end
	end
	local texture = select(3, GetSpellInfo(name))
	for i=150000, 1, -1  do
		if GetSpellInfo(i) == name then
			id = i
			if select(3, GetSpellInfo(i)) == texture then
				return i
			end
		end
	end
	return id
end

local function UpdateDB(self)
	wipe(icons)
	wipe(spells)
	if not self.dbx.spells[playerClass] then self:ResetClassSpells() end
	for _,spell in next, self.dbx.spells[playerClass] do
		local name,_,icon = GetSpellInfo(spell)
		if name then
			spells[name] = true
			icons[name]  = icon
		end	
	end
	for i=1, #defaultSpells[playerClass] do
		if self.dbx.spells[playerClass][i] == nil then
			self.dbx.spells[playerClass][i] = "" --without this it seems to be impossible to actualy delete some spells from the default list
		end
	end
	activeTime = self.dbx.activeTime or 2
	timerDelay = math.min(0.1, activeTime / 2 )
end

Grid2.setupFunc["aoe-OutgoingHeals"] = function(baseKey, dbx)
	playerGUID             = UnitGUID("player")
	OutgoingHeal           = OutgoingHeal
	OutgoingHeal.OnEnable  = OnEnable
	OutgoingHeal.OnDisable = OnDisable
	OutgoingHeal.IsActive  = IsActive
	OutgoingHeal.GetColor  = GetColor
	OutgoingHeal.GetIcon   = GetIcon
	OutgoingHeal.GetText   = GetText
	OutgoingHeal.UpdateDB  = UpdateDB
	OutgoingHeal.GetSpellID= GetSpellID
	OutgoingHeal.ResetClassSpells  = ResetClassSpells
	Grid2:RegisterStatus(OutgoingHeal, {"color", "icon", "text"}, baseKey, dbx)
	return OutgoingHeal
end

Grid2:DbSetStatusDefaultValue( "aoe-OutgoingHeals", { type = "aoe-OutgoingHeals", 
	spells = Grid2.CopyTable(defaultSpells), activeTime= 2, color1 = {r=0,g=0.8,b=1,a=1} 
})
