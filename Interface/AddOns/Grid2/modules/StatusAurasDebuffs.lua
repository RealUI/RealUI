-- debuffs status

local Grid2 = Grid2
local UnitDebuff = UnitDebuff
local emptyTable = {}
local myUnits = { player = true, pet = true, vehicle = true }
local statusTypes = { "color", "icon", "icons", "percent", "text" }

-- Called from StatusAuras.lua
local function status_UpdateState(self, unit, texture, count, duration, expiration, _, _, debuffType)
	if count==0 then count = 1 end
	if self.states[unit]==nil or self.counts[unit] ~= count or expiration~=self.expirations[unit] then 
		self.states[unit] = true
		self.textures[unit] = texture
		self.durations[unit] = duration
		self.expirations[unit] = expiration
		self.counts[unit] = count
		self.types[unit] = debuffType
		self.tracker[unit] = 1
		self.seen = 1
	else	
		self.seen = -1
	end	
end

local function status_UpdateStateFilter(self, unit, name, texture, count, duration, expiration, caster, isBossDebuff, debuffType)
	local filtered = self.auraNames[name] or (self.filterLong~=nil and (duration>300)==self.filterLong) or (self.filterBoss~=nil and self.filterBoss == isBossDebuff) or (self.filterCaster and (caster==unit or myUnits[caster]) )
	if filtered then return end
	self.states[unit] = true
	self.textures[unit] = texture
	self.durations[unit] = duration
	self.expirations[unit] = expiration
	self.counts[unit] = count
	self.types[unit] = debuffType
	self.tracker[unit] = 1
	self.seen = 1
end

local status_GetIconsWhiteList, status_GetIconsFilter
do
	local textures = {}
	local counts = {}
	local expirations = {}
	local durations = {}
	local colors = {}
	status_GetIconsWhiteList = function(self, unit)
		local i, j, spells, typeColors = 1, 1, self.auraNames, self.typeColors
		local name, _
		while true do
			name, _, textures[j], counts[j], debuffType, durations[j], expirations[j] = UnitDebuff(unit, i)
			if not name then return j-1, textures, counts, expirations, durations, colors end
			colors[j] = debuffType and typeColors[debuffType] or self.color
			if spells[name] then j = j + 1 end
			i = i + 1
		end
	end
	status_GetIconsFilter = function(self, unit)
		local i, j, typeColors = 1, 1, self.typeColors
		local filterLong, filterBoss, filterCaster, spells = self.filterLong, self.filterBoss, self.filterCaster, self.auraNames
		local name, caster, isBossDebuff, _
		while true do
			name, _, textures[j], counts[j], debuffType, durations[j], expirations[j], caster, _, _, _, _, isBossDebuff = UnitDebuff(unit, i)
			if not name then return j-1, textures, counts, expirations, durations, colors end
			colors[j] = debuffType and typeColors[debuffType] or self.color
			local filtered = spells[name] or (filterLong and (durations[j]>=300)==filterLong) or (filterBoss~=nil and filterBoss==isBossDebuff) or (filterCaster and (caster==unit or myUnits[caster]))
			if not filtered then j = j + 1 end	
			i = i + 1			
		end
	end
end

local function status_OnEnable(self)
	if self.dbx.useWhiteList then
		for spell in pairs(self.auraNames) do
			Grid2:RegisterStatusAura( self, "debuff", spell )
		end	
	else
		Grid2:RegisterStatusAura( self, "debuff" )
	end	
	if self.thresholds then
		Grid2:RegisterTimeTrackerStatus(self, self.dbx.colorThresholdElapsed)
	end
end

local function status_OnDisable(self)
	Grid2:UnregisterStatusAura(self, "debuff")
	Grid2:UnregisterTimeTrackerStatus(self)
end

local function status_GetDebuffTypeColor(self, unit)
	local type = self.types[unit]
	local color = type and self.typeColors[type] or self.color
	return color.r, color.g, color.b, color.a
end

local function status_UpdateDB(self)
	if self.enabled then self:OnDisable() end
	Grid2:SetupStatusAura(self)
	self.types = self.types or {}
	self.auraNames = self.auraNames or {}
	wipe(self.auraNames)
	if self.dbx.auras then
		for _,spell in ipairs(self.dbx.auras) do
			self.auraNames[spell] = true
		end
	end	
	if self.dbx.useWhiteList then
		self.GetIcons = status_GetIconsWhiteList
		self.UpdateState  = status_UpdateState
	else
		self.filterLong   = self.dbx.filterLongDebuffs
		self.filterBoss   = self.dbx.filterBossDebuffs
		self.filterCaster = self.dbx.filterCaster
		self.GetIcons     = status_GetIconsFilter
		self.UpdateState  = status_UpdateStateFilter		
	end
	self.color = self.dbx.color1	
	if self.dbx.debuffTypeColorize then
		self.GetColor   = status_GetDebuffTypeColor
		self.typeColors = Grid2:GetStatusAuraDebuffTypeColors()
	else
		self.typeColors = emptyTable
	end
	if self.enabled then self:OnEnable() end
end

local function CreateAura(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	status.OnEnable  = status_OnEnable
	status.OnDisable = status_OnDisable
	status.UpdateDB  = status_UpdateDB
	Grid2:RegisterStatus(status, statusTypes, baseKey, dbx)	
	status:UpdateDB()
	return status
end

-- Registration
Grid2.setupFunc["debuffs"] = CreateAura
