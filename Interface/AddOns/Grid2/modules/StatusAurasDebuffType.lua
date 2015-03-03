-- debuffType status

local Grid2 = Grid2
local statusTypesDebuffType = { "color", "icon", "icons", "text" }

-- Called from StatusAuras.lua
local function status_UpdateState(self, unit, texture, count, duration, expiration, name)
	if self.debuffFilter and self.debuffFilter[name] then return end
	self.states[unit] = true
	self.textures[unit] = texture
	self.durations[unit] = duration
	self.expirations[unit] = expiration
	self.counts[unit] = count~=0 and count or 1
	self.seen = 1
end

-- Standard status methods
local function status_OnEnable(self)
	Grid2:RegisterStatusAura(self, "debuffType", self.subType)
end

local function status_OnDisable(self)
	Grid2:UnregisterStatusAura(self, "debuffType", self.subType)
end

local function status_UpdateDB(self)
	self.subType = self.dbx.subType
	self.debuffFilter = self.dbx.debuffFilter
	Grid2:SetupStatusAura(self)
	Grid2:SetStatusAuraDebuffTypeColor( self.dbx.subType, self.dbx.color1 )
end

Grid2.setupFunc["debuffType"] = function(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	status.Reset = status_Reset
	status.UpdateState  = status_UpdateState
	status.GetBorder = Grid2.statusLibrary.GetBorder	
	status.OnEnable = status_OnEnable
	status.OnDisable = status_OnDisable
	status.UpdateDB = status_UpdateDB	
	Grid2:RegisterStatus(status, statusTypesDebuffType, baseKey, dbx)		
	status:UpdateDB()
	return status
end

Grid2:DbSetStatusDefaultValue( "debuff-Magic",   {type = "debuffType", subType = "Magic",   color1 = {r=.2,g=.6,b=1,a=1}} )
Grid2:DbSetStatusDefaultValue( "debuff-Poison",  {type = "debuffType", subType = "Poison",  color1 = {r=0,g=.6,b=0,a=1 }} )
Grid2:DbSetStatusDefaultValue( "debuff-Curse",   {type = "debuffType", subType = "Curse",   color1 = {r=.6,g=0,b=1,a=1 }} )
Grid2:DbSetStatusDefaultValue( "debuff-Disease", {type = "debuffType", subType = "Disease", color1 = {r=.6,g=.4,b=0,a=1}} )
