-- Status: Aoe-Heals

local AOEM = Grid2:NewModule( "Grid2AoeHeals", "AceEvent-3.0")

local Grid2 = Grid2
local next = next
local pairs = pairs
local select = select
local GetTime = GetTime

local playerGUID
local timer
local timerDelay = 2
local spells = {}
local icons = {}
local statuses_enabled = {}

local function TimerEvent()
	local count = 0
	local time  = GetTime()
	for status in pairs(statuses_enabled) do
		local heal_cache = status.heal_cache
		local time_cache = status.time_cache
		for unit,expire in pairs(time_cache) do
			if time>=expire then
				heal_cache[unit] = nil
				time_cache[unit] = nil
				status:UpdateIndicators(unit)
			end
		end
		if next(status.time_cache) then
			count = count + 1
		end
	end	
	if count == 0 then
		Grid2:CancelTimer(timer)
		timer = nil
	end
end

local function CombatLogEvent(...)
	local spellName = select(14,...)
	local statuses = spells[spellName]
	if statuses then
		local subEvent = select(3,...)
		if subEvent=="SPELL_HEAL" or subEvent=="SPELL_PERIODIC_HEAL" then
			for status in pairs(statuses) do
				local mine = status.mine
				if mine == nil or status.mine == (select(5,...)==playerGUID) then
					local unit = Grid2:GetUnitidByGUID( select(9,...) )
					if unit then
						local prev = status.heal_cache[unit]
						status.heal_cache[unit] = spellName
						status.time_cache[unit] = GetTime() + status.activeTime
						if prev~=spellName then
							status:UpdateIndicators(unit)
							if not timer then
								timer = Grid2:ScheduleRepeatingTimer(TimerEvent, timerDelay)
							end	
						end	
					end
				end
			end	
		end	
	end
end

local function OnEnable(self)
	if not next(statuses_enabled) then
		AOEM:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CombatLogEvent)
	end
	statuses_enabled[self] = true
	if self.dbx.spellList then
		for _,spell in next, self.dbx.spellList do
			local name,_,icon = GetSpellInfo(spell)
			if name then
				if not spells[name] then 
					spells[name] = {} 
				end
				spells[name][self] = true
				icons[name] = icon
			end
		end
	end	
end

local function OnDisable(self)
	wipe(self.heal_cache)
	wipe(self.time_cache)
	statuses_enabled[self] = nil
	for key,statuses in pairs(spells) do
		if statuses[self] then
			statuses[self] = nil
			if not next(statuses) then
				spells[key] = nil
			end
		end
	end
	if not next(statuses_enabled) then
		AOEM:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end	
end

local function IsActive(self, unit)
	if self.heal_cache[unit] then return true end
end

local function GetColor(self, unit)
	local c = self.dbx.color1
	return c.r, c.g, c.b, c.a
end

local function GetIcon(self, unit)
	local spell = self.heal_cache[unit]
	if spell then return icons[ spell ] end	
end

local function GetText(self, unit)
	return self.heal_cache[unit]
end

local function UpdateDB(self)
	if self.enabled then self:OnDisable() end
	self.activeTime = self.dbx.activeTime or 2
	self.mine = self.dbx.mine -- mine => true (only mine spells) / false (not mine spells) / nil (any spell)
	timerDelay = math.max(0.1, math.min(timerDelay, self.activeTime / 4) )
	if self.enabled then self:OnEnable() end
end

Grid2.setupFunc["aoe-heals"] = function(baseKey, dbx)
	playerGUID = UnitGUID("player")
	local status = Grid2.statusPrototype:new(baseKey)
	status.heal_cache = {}
	status.time_cache = {}
	status.OnEnable = OnEnable
	status.OnDisable = OnDisable
	status.IsActive = IsActive
	status.GetColor = GetColor
	status.GetIcon = GetIcon
	status.GetText = GetText
	status.UpdateDB = UpdateDB
	Grid2:RegisterStatus(status, {"color", "icon", "text"}, baseKey, dbx)
	status:UpdateDB()	
	return status
end

