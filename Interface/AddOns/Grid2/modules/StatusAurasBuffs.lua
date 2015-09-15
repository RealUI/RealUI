-- buffs status

local Grid2 = Grid2
local UnitBuff = UnitBuff
local statusTypes = { "color", "icon", "icons", "percent", "text" }
local myUnits = { player = true, pet = true, vehicle = true }

-- Called from StatusAuras.lua
local function status_UpdateState(self, unit, texture, count, duration, expiration)
	if count==0 then count = 1 end
	if self.states[unit]==nil or count ~= self.counts[unit] or expiration ~= self.expirations[unit] then 
		self.states[unit] = true
		self.textures[unit] = texture
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.counts[unit] = count
		self.tracker[unit] = 1
		self.seen = 1
	else
		self.seen = -1
	end	
end

local function status_UpdateStateMine(self, unit, texture, count, duration, expiration, _, isMine)
	if isMine then
		status_UpdateState(self, unit, texture, count, duration, expiration)
	end
end

local function status_UpdateStateNotMine(self, unit, texture, count, duration, expiration, _, isMine)
	if not isMine then
		status_UpdateState(self, unit, texture, count, duration, expiration)
	end
end

local function status_OnEnable(self)
	for spell in pairs(self.auraNames) do
		Grid2:RegisterStatusAura( self, "buff", spell )
	end	
	if self.thresholds then 
		Grid2:RegisterTimeTrackerStatus(self, self.dbx.colorThresholdElapsed)
	end
end

local function status_OnDisable(self)
	Grid2:UnregisterStatusAura(self, "buff")
	Grid2:UnregisterTimeTrackerStatus(self)
end

local status_GetIcons
do
	local textures = {}
	local counts = {}
	local expirations = {}
	local durations = {}
	local colors = {}
	local color = {}
	status_GetIcons = function(self, unit)
		color.r, color.g, color.b, color.a = self:GetColor(unit)
		local i, j, spells, filter, name, caster = 1, 1, self.auraNames, self.filterMine
		while true do
			name, _, textures[j], counts[j], _, durations[j], expirations[j], caster = UnitBuff(unit, i)
			if not name then return j-1, textures, counts, expirations, durations, colors end
			if spells[name] and (filter==false or filter==myUnits[caster]) then 
				colors[j] = color
				j = j + 1 
			end	
			i = i + 1
		end
	end
end

local function status_UpdateDB(self)
	if self.enabled then self:OnDisable() end
	Grid2:SetupStatusAura(self)
	wipe(self.auraNames)
	for _,spell in ipairs(self.dbx.auras) do
		self.auraNames[spell] = true
	end
	if self.dbx.mine == 2 then 
		self.filterMine = nil -- not mine buffs
		self.UpdateState = status_UpdateStateNotMine
	elseif self.dbx.mine then 
		self.filterMine = true -- mine buffs
		self.UpdateState = status_UpdateStateMine
	else 
		self.filterMine = false -- mine and not mine buffs 
		self.UpdateState = status_UpdateState
	end
	if self.enabled then self:OnEnable() end
end

local function CreateAura(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	status.auraNames = {}
	status.OnEnable  = status_OnEnable
	status.OnDisable = status_OnDisable
	status.GetIcons = status_GetIcons
	status.UpdateDB  = status_UpdateDB
	Grid2:RegisterStatus(status, statusTypes, baseKey, dbx)	
	status:UpdateDB()
	return status
end

-- Registration
Grid2.setupFunc["buffs"] = CreateAura
