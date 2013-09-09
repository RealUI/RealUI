--[[
Created by Grid2 original authors, modified by Michael
--]]

local AuraFrame_OnEvent
local Grid2 = Grid2
local GetTime = GetTime
local UnitBuff = UnitBuff
local UnitDebuff = UnitDebuff
local abs = math.abs

--{{ Local variables
local StatusList = {}
local DebuffHandlers = {}
local BuffHandlers = {}
local statusTypesBuffs = { "color", "icon", "percent", "text" }
local statusTypesDebuffs = { "color", "icon", "text" }
--}}

--{{  Misc functions
local handlerArray = {}
local function MakeStatusColorHandler(status)
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

local function GetStatusKey(self, spellName)
	return type(spellName)=="number" and (not self.dbx.useSpellId) and GetSpellInfo(spellName) or spellName
end

local function IterateStatusSpells(status)
	local auras = status.dbx.auras
	if auras then
		local i = 0
		return function() i=i+1; return auras[i] end
	else
		local spell, value = status.dbx.spellName
		return function() value, spell = spell, nil; return value end
	end
end
--}}

--{{ Timer to refresh auras remaining time 
local AddTimeTracker, RemoveTimeTracker
do
	local next = next
	local timetracker
	local tracked 
	AddTimeTracker = function (status)
		tracked = {}
		timetracker = CreateFrame("Frame", nil, Grid2LayoutFrame):CreateAnimationGroup()
		timetracker:SetScript("OnFinished", function (self)
			local time = GetTime()
			for status in next, tracked do
				local tracker    = status.tracker
				local thresholds = status.thresholds
				if status.trackElapsed then
					local durations = status.durations
					for unit, expiration in next, status.expirations do
						local timeElapsed = time - (expiration - durations[unit])
						local threshold = thresholds[ tracker[unit] ]
						if threshold and timeElapsed >= threshold then
							tracker[unit] = tracker[unit] + 1
							status:UpdateIndicators(unit)
						end
					end
				else
					for unit, expiration in next, status.expirations do
						local timeLeft  = expiration - time
						local threshold = thresholds[ tracker[unit] ]
						if threshold and timeLeft <= threshold then
							tracker[unit] = tracker[unit] + 1
							status:UpdateIndicators(unit)
						end
					end
				end	
			end
			self:Play()
		end)
		local timer = timetracker:CreateAnimation()
		timer:SetOrder(1); timer:SetDuration(0.10) 
		AddTimeTracker = function (status)
			if not next(tracked) then timetracker:Play() end
			tracked[status] = true
		end
		RemoveTimeTracker = function (status)
			tracked[status] = nil
			if not next(tracked) then timetracker:Stop() end
		end
		return AddTimeTracker(status)
	end
end
--}}

--{{ Auras Event 
local EnableAuraFrame, DisableAuraFrame
do
	local frame
	local count = 0
	function EnableAuraFrame()
		if count == 0 then
			if not frame then 
				frame = CreateFrame("Frame", nil, Grid2LayoutFrame) 
			end
			frame:SetScript("OnEvent", AuraFrame_OnEvent)
			frame:RegisterEvent("UNIT_AURA")
		end
		count = count + 1
	end	
	function DisableAuraFrame()
		count = count - 1
		if count == 0 then
			frame:SetScript("OnEvent", nil)
			frame:UnregisterEvent("UNIT_AURA")
		end
	end
end
--}}

--{{ Methods shared by different status types
local function status_Reset(self, unit)
	self.states[unit] = nil
	self.counts[unit] = nil
	self.expirations[unit] = nil
	return true
end

local function status_IsInactive(self, unit) -- used for "missing" status
	return not self.states[unit]
end

local function status_IsActive(self, unit)
	return self.states[unit]
end

local function status_IsActiveBlink(self, unit)
	if not self.states[unit] then return end
	if self.tracker[unit]==1 then
		return true
	else
		return "blink"
	end
end

local function status_IsInactiveBlink(self, unit) -- A missing active status has no expiration, always returns blink
	return not self.states[unit] and "blink"
end

local function status_GetIcon(self, unit)
	return self.textures[unit]
end

local function status_GetIconMissing(self)
	return self.missingTexture
end

local function status_GetCount(self, unit)
	return self.counts[unit]
end

local function status_GetCountMissing()
	return 1
end

local function status_GetCountMax(self)
	return self.dbx.colorCount or 1
end	

local function status_GetDuration(self, unit)
	return self.durations[unit]
end

local function status_GetExpirationTime(self, unit)
	return self.expirations[unit]
end

local function status_GetExpirationTimeMissing() -- Expiration time is unknow, return some hours in future to allow 
	return GetTime() + 9999						 -- blinking work and to avoid a crash of IndicatorText status
end

local function status_GetPercent(self, unit)
	local t = GetTime()
	local expiration = (self.expirations[unit] or t) - t
	return expiration / (self.durations[unit] or 1)
end

local function status_GetThresholdColor(self, unit)    
	local colors = self.colors
	local index  = self.tracker[unit]
	local color  = colors[index] or colors[1]
	return color.r, color.g, color.b, color.a
end

-- This function includes a workaround to expiration variations of Druid WildGrowth HoT (little differences in expirations are ignored)
local function status_UpdateState(self, unit, iconTexture, count, duration, expiration)
	local prevexp = self.expirations[unit]
	if count==0 then count = 1 end
	if self.states[unit]==nil or self.counts[unit] ~= count or prevexp==nil or abs(prevexp-expiration)>0.15 then 
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.counts[unit] = count
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.tracker[unit] = 1
		self.seen= 1
	else
		self.seen= -1
	end
end

local function status_UpdateStateMine(self, unit, iconTexture, count, duration, expiration, isMine)
	if isMine then
		status_UpdateState(self, unit, iconTexture, count, duration, expiration)
	end
end

local function status_UpdateStateNotMine(self, unit, iconTexture, count, duration, expiration, isMine)
	if not isMine then
		status_UpdateState(self, unit, iconTexture, count, duration, expiration)
	end
end

local function status_UpdateStateGroup(self, unit, iconTexture, count, duration, expiration)
	if self.states[unit]==nil or self.expirations[unit] ~= expiration then
		self.states[unit] = true
		self.textures[unit] = iconTexture
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.counts[unit] = 1
		self.tracker[unit] = 1
		self.seen = 1
	else
		self.seen = -1
	end
end

local function status_UpdateStateGroupMine(self, unit, iconTexture, count, duration, expiration, isMine)
	if isMine then
		status_UpdateStateGroup(self, unit,iconTexture, count,duration,expiration)
	end
end

local function status_UpdateStateGroupNotMine(self, unit, iconTexture, count, duration, expiration, isMine)
	if not IsMine then
		status_UpdateStateGroup(self, unit,iconTexture, count, duration, expiration)
	end
end
-- }}

-- {{ Buff & BuffGroup
local function status_OnBuffEnable(self)
	EnableAuraFrame()
	if self.thresholds then AddTimeTracker(self) end
	for spellName in IterateStatusSpells(self) do
		local key      = GetStatusKey(self,spellName)
		local statuses = BuffHandlers[key]
		if not statuses then statuses = {};	BuffHandlers[key] = statuses end
		statuses[self] = true
	end
	StatusList[self] = true
end

local function status_OnBuffDisable(self)
	DisableAuraFrame()
	if RemoveTimeTracker then RemoveTimeTracker(self) end
	for key,statuses in pairs(BuffHandlers) do
		if statuses[self] then 	
			statuses[self] = nil
			if not next(statuses) then BuffHandlers[key] = nil end
		end
	end
	StatusList[self] = nil
end
-- }}

-- {{ Debuff & DebuffGroup
local function status_OnDebuffEnable(self)
	EnableAuraFrame()
	if self.thresholds then AddTimeTracker(self) end
	for spellName in IterateStatusSpells(self) do
		DebuffHandlers[ GetStatusKey(self, spellName) ] = self
	end
	StatusList[self] = true
end

local function status_OnDebuffDisable(self)
	DisableAuraFrame()
	if RemoveTimeTracker then RemoveTimeTracker(self) end
	for key,status in pairs(DebuffHandlers) do
		if self == status then DebuffHandlers[key] = nil end
	end	
	StatusList[self] = nil
end
-- }}

-- {{ DebuffType
local function status_OnDebuffTypeEnable(self)
	EnableAuraFrame()
	DebuffHandlers[ self.subType ] = self
	StatusList[self] = true
end

local function status_OnDebuffTypeDisable(self)
	DisableAuraFrame()
	DebuffHandlers[ self.subType ] = nil
	StatusList[self] = nil
end

local function status_UpdateStateDebuffType(self, unit, iconTexture, count, duration, expiration, name)
	if self.debuffFilter and self.debuffFilter[name] then return end
	self.states[unit] = true
	self.textures[unit] = iconTexture
	self.durations[unit] = duration
	self.expirations[unit] = expiration
	self.counts[unit] = count~=0 and count or 1
	self.seen = 1
end
-- }}

-- {{ UpdateDB shared by all statuses
local function status_UpdateDB(self)
	if self.enabled then self:OnDisable() end
	local dbx = self.dbx
	if dbx.missing then
		local _, _, texture    = GetSpellInfo(auras and auras[1] or dbx.spellName )
		self.thresholds        = nil
		self.missingTexture    = texture or "Interface\\ICONS\\Achievement_General"
		self.GetIcon           = status_GetIconMissing
		self.GetExpirationTime = status_GetExpirationTimeMissing
		self.GetCount          = status_GetCountMissing
		self.IsActive          = dbx.blinkThreshold and status_IsInactiveBlink or status_IsInactive
		MakeStatusColorHandler(self)		
	else
		self.GetIcon           = status_GetIcon
		self.GetExpirationTime = status_GetExpirationTime
		self.GetCount          = status_GetCount
		if dbx.blinkThreshold then
			self.thresholds = { dbx.blinkThreshold }
			self.IsActive   = status_IsActiveBlink
			MakeStatusColorHandler(self)
		elseif dbx.colorThreshold then
			self.colors       = {}
			self.thresholds   = dbx.colorThreshold
			self.trackElapsed = dbx.colorThresholdElapsed
			self.GetColor     = status_GetThresholdColor
			self.IsActive     = status_IsActive
			for i=1,dbx.colorCount do
				self.colors[i] = dbx["color"..i]
			end
		else
			self.thresholds = nil
			self.IsActive   = status_IsActive
			MakeStatusColorHandler(self)
		end
	end
	if dbx.type=="debuffType" then
		self.subType      = self.dbx.subType
		self.debuffFilter = self.dbx.debuffFilter
		self.GetBorder    = Grid2.statusLibrary.GetBorder
		self.UpdateState  = status_UpdateStateDebuffType
	else
		if dbx.auras then  
			self.UpdateState =  (dbx.mine==2 and status_UpdateStateGroupNotMine) or
								(dbx.mine    and status_UpdateStateGroupMine) or
								 status_UpdateStateGroup
		else
			self.UpdateState =  (dbx.mine==2 and status_UpdateStateNotMine) or
								(dbx.mine    and status_UpdateStateMine) or
								 status_UpdateState
		end
	end	
	if self.enabled then self:OnEnable() end
end
--}}

--{{ Aura creation functions
local function CreateAuraCommon(baseKey, dbx, types)
	local status = Grid2.statusPrototype:new(baseKey, false)

	status.states = {}
	status.textures = {}
	status.counts = {}
	status.expirations = {}
	status.durations = {}
	
	status.UpdateDB    = status_UpdateDB
	status.Reset       = status_Reset
	status.GetCountMax = status_GetCountMax
	status.GetDuration = status_GetDuration
	status.GetPercent  = status_GetPercent
	
	if dbx.type == "debuffType" then
		status.OnEnable  = status_OnDebuffTypeEnable
		status.OnDisable = status_OnDebuffTypeDisable
	else
		status.tracker = {}
		status.OnEnable  = dbx.type=="buff" and status_OnBuffEnable  or status_OnDebuffEnable
		status.OnDisable = dbx.type=="buff" and status_OnBuffDisable or status_OnDebuffDisable
	end

	Grid2:RegisterStatus(status, types, baseKey, dbx)
	
	status:UpdateDB()
	
	return status
end

function Grid2.CreateBuff(baseKey, dbx, statusTypesOverride)
	return CreateAuraCommon(baseKey, dbx, statusTypesOverride or statusTypesBuffs)
end

function Grid2.CreateDebuff(baseKey, dbx, statusTypesOverride)
	return CreateAuraCommon( baseKey, dbx, statusTypesOverride or statusTypesDebuffs)
end
--}}

--{{ Aura Refresh 
-- Passing StatusList instead of nil, because i dont know if nil is valid for RegisterMessage
Grid2.RegisterMessage( StatusList, "Grid_UnitUpdated", function(_, unit) 
	AuraFrame_OnEvent(nil,nil,unit)
end)
-- Called by Grid2Options when an aura status is enabled
function Grid2:RefreshAuras() 
	for unit in Grid2:IterateRosterUnits() do
		AuraFrame_OnEvent(nil,nil,unit) 
	end
end	
-- }}

--{{ Aura events management
do
	local next = next
	local indicators = {}
	local myUnits = { player = true, pet = true, vehicle = true }
	function AuraFrame_OnEvent(_, _, unit)
		local frames = Grid2:GetUnitFrames(unit)
		if not next(frames) then return end
		-- scan Debuffs and debuff Types
		local i = 1
		while true do
			local name, _, iconTexture, count, debuffType, duration, expirationTime, caster, _, _, spellId = UnitDebuff(unit, i)
			if not name then break end
			local status = DebuffHandlers[name] or DebuffHandlers[spellId]
			if status then
				status:UpdateState(unit, iconTexture, count, duration, expirationTime, myUnits[caster])
			end
			if debuffType then
				status = DebuffHandlers[debuffType]
				if status and (not status.seen) then
					status:UpdateState(unit, iconTexture, count, duration, expirationTime, name)
				end
			end
			i = i + 1
		end
		-- scan Buffs
		i = 1
		while true do
			local name, _, iconTexture, count, _, duration, expirationTime, caster, _, _, spellId = UnitBuff(unit, i)
			if not name then break end
			local statuses = BuffHandlers[name] or BuffHandlers[spellId]
			if statuses then
				local isMine = myUnits[caster]
				for status in next, statuses do
					status:UpdateState(unit, iconTexture, count, duration, expirationTime, isMine)
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
--}}

--{{ 
Grid2.setupFunc["buff"]       = Grid2.CreateBuff
Grid2.setupFunc["debuff"]     = Grid2.CreateDebuff
Grid2.setupFunc["debuffType"] = Grid2.CreateDebuff
--}}

--{{ 
Grid2:DbSetStatusDefaultValue( "debuff-Magic", {type = "debuffType", subType = "Magic", color1 = {r=.2,g=.6,b=1,a=1}})
Grid2:DbSetStatusDefaultValue( "debuff-Poison", {type = "debuffType", subType = "Poison", color1 = {r=0,g=.6,b=0,a=1}})
Grid2:DbSetStatusDefaultValue( "debuff-Curse", {type = "debuffType", subType = "Curse", color1 = {r=.6,g=0,b=1,a=1}})
Grid2:DbSetStatusDefaultValue( "debuff-Disease", {type = "debuffType", subType = "Disease", color1 = {r=.6,g=.4,b=0,a=1}})
--}}
