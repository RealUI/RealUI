-- Auras management

local Grid2 = Grid2
local type = type
local next = next
local GetTime = GetTime

-- Local variables
local StatusList = {}
local BuffHandlers = {}
local DebuffHandlers = {}
local DebuffsHandlers = {}
local DebuffTypeHandlers = {}
local Handlers = { buff = BuffHandlers, debuff = DebuffHandlers }

-- UNIT_AURA event management
local AuraFrame_OnEvent
do
	local next = next
	local indicators = {}
	local values = { 0, 0, 0 }
	local myUnits = { player = true, pet = true, vehicle = true }
	AuraFrame_OnEvent = function(_, _, unit)
		local frames = Grid2:GetUnitFrames(unit)
		if not next(frames) then return end
		-- Scan Debuffs, Debuff Types, Debuff Groups
		local i = 1
		while true do
			local name, texture, count, debuffType, duration, expiration, caster, spellId, isBossDebuff, _
			name, _, texture, count, debuffType, duration, expiration, caster, _, _, spellId, _, isBossDebuff, _, values[1], values[2], values[3] = UnitDebuff(unit, i)
			if not name then break end
			local statuses = DebuffHandlers[name] or DebuffHandlers[spellId]
			if statuses then
				local isMine = myUnits[caster]
				for status in next, statuses do
					status:UpdateState(unit, texture, count, duration, expiration, values[status.valueIndex], isMine )
				end
			end
			if debuffType then
				status = DebuffTypeHandlers[debuffType]
				if status and (not status.seen) then
					status:UpdateState(unit, texture, count, duration, expiration, name)
				end
			end
			for status in next, DebuffsHandlers do
				if not status.seen then	
					status:UpdateState(unit, name, texture, count, duration, expiration, caster, isBossDebuff, debuffType)
				end	
			end
			i = i + 1
		end
		-- Scan Buffs
		i = 1
		while true do
			local name, texture, count, duration, expiration, caster, spellId, _
			name, _, texture, count, _, duration, expiration, caster, _, _, spellId, _, _, _, values[1], values[2], values[3] = UnitBuff(unit, i)
			if not name then break end
			local statuses = BuffHandlers[name] or BuffHandlers[spellId]
			if statuses then
				local isMine = myUnits[caster]
				for status in next, statuses do
					status:UpdateState(unit, texture, count, duration, expiration, values[status.valueIndex], isMine)
				end
			end
			i = i + 1
		end
		-- Mark indicators that need updating
		for status in next, StatusList do
			local seen = status.seen
			if (seen==1) or ((not seen) and status.states[unit] and status:Reset(unit)) then
				for indicator in next, status.indicators do
					indicators[indicator] = true
				end
			end	
			status.seen = false
		end
		-- Update indicators that needs updating only once.
		for indicator in next, indicators do
			for frame in next, frames do
				indicator:Update(frame, unit)
			end
		end
		wipe(indicators)
	end
end

-- Passing StatusList instead of nil, because i dont know if nil is valid for RegisterMessage
Grid2.RegisterMessage( StatusList, "Grid_UnitUpdated", function(_, unit) 
	AuraFrame_OnEvent(nil,nil,unit)
end)

-- EnableAuraEvents() DisableAuraEvents()
local EnableAuraEvents, DisableAuraEvents
do
	local frame
	EnableAuraEvents = function()
		if not next(StatusList) then
			if not frame then frame = CreateFrame("Frame", nil, Grid2LayoutFrame) end
			frame:SetScript("OnEvent", AuraFrame_OnEvent)
			frame:RegisterEvent("UNIT_AURA")
		end
	end	
	DisableAuraEvents = function()
		if not next(StatusList) then
			frame:SetScript("OnEvent", nil)
			frame:UnregisterEvent("UNIT_AURA")
		end
	end
end

-- Grid2:RegisterTimeTrackerStatus() Grid2:UnregisterTimeTrackerStatus()
do
	local timetracker
	local tracked = {}
	function Grid2:RegisterTimeTrackerStatus(status, elapsed)
		timetracker = CreateFrame("Frame", nil, Grid2LayoutFrame):CreateAnimationGroup()
		timetracker:SetScript("OnFinished", function (self)
			local time = GetTime()
			for status,elapsed in next, tracked do
				local tracker    = status.tracker
				local thresholds = status.thresholds
				for unit, expiration in next, status.expirations do
					local threshold = thresholds[tracker[unit]]
					if threshold and time >= expiration - (elapsed and status.durations[unit]-threshold or threshold) then
						tracker[unit] = tracker[unit] + 1
						status:UpdateIndicators(unit)
					end
				end
			end
			self:Play()
		end)
		local timer = timetracker:CreateAnimation()
		timer:SetOrder(1); timer:SetDuration(0.10) 
		Grid2.AddTimeTracker = function (self, status, elapsed)
			if not next(tracked) then timetracker:Play() end
			tracked[status] = elapsed or false
		end
		return Grid2:AddTimeTracker(status, elapsed)
	end
	function Grid2:UnregisterTimeTrackerStatus(status)
		tracked[status] = nil
		if (not next(tracked)) and timetracker then timetracker:Stop() end
	end
end

function Grid2:RegisterStatusAura(status, auraType, spell)
	EnableAuraEvents()
	if spell then
		local handler = Handlers[auraType]
		if handler then
			local statuses = handler[spell]
			if not statuses then
				statuses = {}
				handler[spell] = statuses
			end
			statuses[status] = true
		elseif auraType=="debuffType" then
			DebuffTypeHandlers[spell] = status
		end	
	else
		DebuffsHandlers[status] = true
	end	
	StatusList[status] = true
end

function Grid2:UnregisterStatusAura(status, auraType, subType)
	local handler = Handlers[auraType]
	if handler then
		for key,statuses in pairs(handler) do
			if statuses[self] then
				statuses[self] = nil
				if not next(statuses) then handler[key] = nil end
			end
		end
		DebuffsHandlers[status] = nil
	else	
		DebuffTypeHandlers[subType] = nil
	end	
	StatusList[status] = nil
	DisableAuraEvents()
end

function Grid2:RefreshAuras() 
	for unit in Grid2:IterateRosterUnits() do
		AuraFrame_OnEvent(nil,nil,unit) 
	end
end	

-- Grid2:MakeStatusColorHandler()
do
	local handlerArray = {}
	function Grid2:MakeStatusColorHandler(status)
		local dbx = status.dbx
		local colorCount = dbx.colorCount or 1
		handlerArray[1] = "return function (self, unit)"
		if colorCount > 1 then
			handlerArray[#handlerArray+1] = " local count = self:GetCount(unit)"
			for i = 1, colorCount - 1 do
				local color = dbx["color" .. i]
				handlerArray[#handlerArray+1] = (" if count == %d then return %s, %s, %s, %s end"):format(i, color.r, color.g, color.b, color.a)
			end
		end
		color = dbx["color" .. colorCount]
		handlerArray[#handlerArray+1] = (" return %s, %s, %s, %s end"):format(color.r, color.g, color.b, color.a)
		status.GetColor = assert(loadstring(table.concat(handlerArray)))()
		wipe(handlerArray)
	end
end

-- Grid2:SetStatusAuraDebuffTypeColor( debuffType, color )
-- Grid2:GetStatusAuraDebuffTypeColors()
do
	local debuffTypeColor = {}
	function Grid2:SetStatusAuraDebuffTypeColor( debuffType, color )
		debuffTypeColor[ debuffType ] = color
	end
	function Grid2:GetStatusAuraDebuffTypeColors()
		return debuffTypeColor
	end
end

-- Grid2:SetupStatusAura()
do
	local fmt = string.format
	local UnitHealthMax = UnitHealthMax
	local function Reset(self, unit)
		self.states[unit] = nil
		self.counts[unit] = nil
		self.expirations[unit] = nil
		self.values[unit] = nil
		return true
	end
	local function IsActive(self, unit) 
		return self.states[unit] 
	end
	local function IsActiveBlink(self, unit) 
		if not self.states[unit] then return end
		return self.tracker[unit]==1 or "blink" 
	end
	local function IsInactive(self, unit) 
		return not (self.states[unit] or Grid2:UnitIsPet(unit)) 
	end
	local function IsInactiveBlink(self, unit) 
		return not self.states[unit] and "blink" 
	end
	local function GetIcon(self, unit) return 
		self.textures[unit] 
	end
	local function GetIconMissing(self) 
		return self.missingTexture 
	end
	local function GetCount(self, unit) 
		return self.counts[unit] 
	end
	local function GetCountMissing() 
		return 1 
	end
	local function GetExpirationTime(self, unit) 
		return self.expirations[unit] 
	end
	local function GetExpirationTimeMissing() 
		return GetTime() + 9999 
	end
	local function GetCountMax(self) 
		return self.dbx.colorCount or 1 
	end	
	local function GetDuration(self, unit) 
		return self.durations[unit] 
	end
	local function GetPercentHealth(self, unit)
		return (self.values[unit] or 0) / UnitHealthMax(unit)
	end
	local function GetPercentMax(self, unit)
		return (self.values[unit] or 0) / self.valueMax
	end
	local function GetText(self, unit)
		return fmt( "%.1fk", (self.values[unit] or 0) / 1000 )
	end
	local function GetTimeColor(self, unit) -- Colorize by time remaining or time elapsed
		local colors = self.colors
		local i = self.tracker[unit]
		local c = colors[i] or colors[1]
		return c.r, c.g, c.b, c.a
	end
	local function GetValueColor(self, unit) -- Colorize by value
		local i = 1
		local value = self.values[unit] or 0
		local thresholds = self.thresholds
		while i<=#thresholds and value<thresholds[i] do
			i = i + 1
		end
		local c = self.colors[i]
		return c.r, c.g, c.b, c.a
	end
	function Grid2:SetupStatusAura(status)
		local dbx = status.dbx
		status.states      = status.states      or {}
		status.textures    = status.textures    or {}
		status.counts      = status.counts      or {}
		status.expirations = status.expirations or {}
		status.durations   = status.durations   or {}
		status.tracker     = status.tracker     or {}
		status.values      = status.values      or {}
		status.valueIndex  = dbx.valueIndex or 0
		status.valueMax    = dbx.valueMax
		status.Reset       = Reset
		status.GetDuration = GetDuration
		status.GetCountMax = GetCountMax
		status.GetText     = GetText		
		status.GetPercent  = dbx.valueMax and GetPercentMax or GetPercentHealth
		if dbx.missing then
			local spell = dbx.auras and dbx.auras[1] or dbx.spellName
			status.missingTexture = spell and select(3,GetSpellInfo(spell)) or "Interface\\ICONS\\Achievement_General"
			status.GetIcon  = GetIconMissing
			status.GetCount = GetCountMissing
			status.GetExpirationTime = GetExpirationTimeMissing
			status.thresholds = nil
			status.IsActive = dbx.blinkThreshold and IsInactiveBlink or IsInactive
		else
			status.GetIcon  = GetIcon
			status.GetCount = GetCount
			status.GetExpirationTime = GetExpirationTime
			if dbx.blinkThreshold then
				status.thresholds = { dbx.blinkThreshold }
				status.IsActive = IsActiveBlink
			else
				status.thresholds = dbx.colorThreshold
				status.IsActive = IsActive
			end
		end
		local colorCount = dbx.colorCount or 1
		if status.thresholds and colorCount>1 then
			status.colors = status.colors or {}
			for i=1,colorCount do
				status.colors[i] = dbx["color"..i]
			end
			status.GetColor = dbx.colorThresholdValue and GetValueColor or GetTimeColor
		else
			Grid2:MakeStatusColorHandler(status)
		end
	end
end

--[[ Published methods
Grid2:SetupStatusAura(status)
Grid2:RegisterStatusAura(status, auraType, [spell|subType] )
Grid2:UnregisterStatusAura(status, auraType, subType )
Grid2:SetStatusAuraDebuffTypeColor( debuffType, color )
Grid2:GetStatusAuraDebuffTypeColors()
Grid2:RegisterTimeTrackerStatus(status, elapsed)
Grid2:UnregisterTimeTrackerStatus(status)
Grid2:MakeStatusColorHandler(status)
Grid2:RefreshAuras() 
--]]
