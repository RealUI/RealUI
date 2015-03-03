-- buff and debuff statuses

local Grid2 = Grid2
local statusTypes = { "color", "icon", "icons", "percent", "text" }

-- Called from StatusAuras.lua
local function status_UpdateState(self, unit, texture, count, duration, expiration, value)
	if count==0 then count = 1 end
	if self.states[unit]==nil or self.counts[unit] ~= count or expiration~=self.expirations[unit] or value~=self.values[unit] then 
		self.states[unit] = true
		self.textures[unit] = texture
		self.counts[unit] = count~=0 and count or 1
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.values[unit] = value
		self.tracker[unit] = 1
		self.seen = 1  -- inactive status becomes active or some value has changed -> indicators must be updated
	else
		self.seen = -1 -- status was already active, remains active and no values changed -> no indicators updates 
	end
end

local function status_UpdateStateMine(self, unit, iconTexture, count, duration, expiration, value, isMine)
	if isMine then
		status_UpdateState(self, unit, iconTexture, count, duration, expiration, value)
	end
end

local function status_UpdateStateNotMine(self, unit, iconTexture, count, duration, expiration, value, isMine)
	if not isMine then
		status_UpdateState(self, unit, iconTexture, count, duration, expiration, value)
	end
end

local function status_GetSpellKey(self, spell)
	return type(spell)=="number" and (not self.dbx.useSpellId) and GetSpellInfo(spell) or spell or "UNDEFINED"
end

local function status_OnEnable(self)
	Grid2:RegisterStatusAura( self, self.auraType, status_GetSpellKey(self,self.dbx.spellName) )
	if self.thresholds and (not self.dbx.trackValue) then 
		Grid2:RegisterTimeTrackerStatus(self, self.dbx.colorThresholdElapsed)
	end
end

local function status_OnDisable(self)
	Grid2:UnregisterStatusAura(self, self.auraType)
	Grid2:UnregisterTimeTrackerStatus(self)
end

local function status_UpdateDB(self)
	if self.enabled then self:OnDisable() end
	Grid2:SetupStatusAura(self)
	self.auraType = self.dbx.type
	self.UpdateState = (self.dbx.mine==2 and status_UpdateStateNotMine) or (self.dbx.mine and status_UpdateStateMine) or status_UpdateState
	if self.enabled then self:OnEnable() end
end

local function CreateAura(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	Grid2:RegisterStatus(status, statusTypes, baseKey, dbx)
	status.OnEnable  = status_OnEnable
	status.OnDisable = status_OnDisable
	status.UpdateDB  = status_UpdateDB
	status:UpdateDB()
	return status
end

-- Registration
Grid2.setupFunc["buff"]   = CreateAura
Grid2.setupFunc["debuff"] = CreateAura
