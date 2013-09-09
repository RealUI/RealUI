-- Boss Shields absorb status, created by Michael

local Shields = Grid2.statusPrototype:new("boss-shields")

local Grid2    = Grid2
local select   = select
local next     = next
local max      = math.max
local fmt      = string.format
local UnitIsDeadOrGhost = UnitIsDeadOrGhost

Shields.ShieldsDB  = {
	["DragonSoul"] = {
		[105479] = 200000, -- Searing Plasma (Spine of Deathwing 10N)
		[109363] = 280000, -- Searing Plasma (Spine of Deathwing 10H)
		[109362] = 300000, -- Searing Plasma (Spine of Deathwing 25N)
		[109364] = 420000, -- Searing Plasma (Spine of Deathwing 25H)	
		[110214] = 100000, -- Consuming Shroud (Warmaster 10H)
		[110598] = 150000, -- Consuming Shroud (Warmaster 25H)
	},
	-- ["Elwynn"] = { [61295] = 100000, }  -- (Riptide buff debug)
}

local timer
local shields
local shields_max  
local shields_values = {}
local shields_updates = {}

function Shields_Timer()
	for unit in next,shields_values do
		if UnitIsDeadOrGhost(unit) then
			Shields:RemoveShield(unit)
		elseif shields_updates[unit] then
			shields_updates[unit] = nil
			Shields:UpdateIndicators(unit)
		end
	end
end

function Shields:EnableTimer()
	if not timer then
		timer = Grid2:ScheduleRepeatingTimer(Shields_Timer, 0.5) 
	end
end

function Shields:DisableTimer()
	if timer then
		Grid2:CancelTimer(timer)
		timer = nil
	end	
end

function Shields:ApplyShield(unit, ... )
	shields_max = shields[ select(13,...) ]
	shields_values[unit] = shields_max
	self:UpdateIndicators(unit)
	self:EnableTimer()
end

function Shields:RemoveShield(unit)
	if shields_values[unit] then
		shields_values[unit]  = nil
		shields_updates[unit] = nil
		self:UpdateIndicators(unit)
		if not next(shields_values) then 
			self:DisableTimer()
		end
	end	
end

function Shields:UpdateShield(unit, ... )
	local absorb = select(18,...) or 0 -- arg18=heal absorb arg16=heal amount, 
	local value  = max ( shields_values[unit] - absorb , 0 )
	if value>0 then
		shields_values[unit]  = value
		shields_updates[unit] = true
	else	
		self:RemoveShield(unit)
	end	
end

local Actions = {
	SPELL_AURA_APPLIED      = { true,  Shields.ApplyShield  },
	SPELL_AURA_REFRESH      = { true,  Shields.ApplyShield  },
	SPELL_AURA_REMOVED      = { true,  Shields.RemoveShield },
	SPELL_AURA_BROKEN       = { true,  Shields.RemoveShield },
	SPELL_AURA_BROKEN_SPELL = { true,  Shields.RemoveShield },
	SPELL_HEAL              = { false, Shields.UpdateShield },
	SPELL_PERIODIC_HEAL		= { false, Shields.UpdateShield },
	UNIT_DIED               = { false, Shields.RemoveShield },
}

function Shields:COMBAT_LOG_EVENT_UNFILTERED(...)
	local action = Actions[select(3,...)]
	if action then 
		if action[1] then
			if shields[ select(13,...) ] then
				local unit = Grid2:GetUnitidByGUID( select(9,...) )
				if unit then action[2]( self, unit, ... ) end
			end
		elseif timer then 
			local unit = Grid2:GetUnitidByGUID( select(9,...) )
			if unit and shields_values[unit] then 
				action[2]( self, unit, ... ) 
			end
		end	
	end
end

function Shields:PLAYER_REGEN_DISABLED()
	shields = self.ShieldsDB[ GetMapInfo() or "unknow" ] 
	if shields then
		self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end
end

function Shields:PLAYER_REGEN_ENABLED()
	if shields then
		self:DisableShields()
		self:UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	end	
end

function Shields:DisableShields()
	shields = nil
	self:DisableTimer()
	wipe(shields_updates)
	for unit in next,shields_values do
		shields_values[unit] = nil
		self:UpdateIndicators(unit)
	end
end

function Shields:OnEnable()
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
end

function Shields:OnDisable()
	self:DisableShields()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
end

function Shields:GetPercent(unit)
	return min( shields_values[unit] / shields_max, 1)
end

function Shields:GetColor(unit)
	local c
	local amount = shields_values[unit]
	if amount > shields_max * 0.65  then
		c = self.dbx.color1
	elseif amount > shields_max * 0.25 then
		c = self.dbx.color2
	else
		c = self.dbx.color3
	end
	return c.r, c.g, c.b, c.a
end

function Shields:GetText(unit)
	return fmt("%.1fk", shields_values[unit] / 1000 )
end

function Shields:IsActive(unit)
	if shields_values[unit] then return true end	
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Shields, { "color", "percent", "text" }, baseKey, dbx)
	return Shields
end

Grid2.setupFunc["boss-shields"] = Create

Grid2:DbSetStatusDefaultValue( "boss-shields", {type = "boss-shields", colorCount = 3, 
	color1 = {r=1,g=0  ,b=0,a=1},
	color2 = {r=1,g=0.5,b=0,a=1},
	color3 = {r=1,g=1  ,b=0,a=1},
})
