-- banzai & banzai-threat statuses ( created by Michael )

local Banzai = Grid2.statusPrototype:new("banzai", false)
local BanzaiThreat = Grid2.statusPrototype:new("banzai-threat", false)

local Grid2 = Grid2
local GetTime = GetTime
local UnitName = UnitName
local UnitGUID = UnitGUID
local UnitExists = UnitExists
local UnitCanAttack = UnitCanAttack
local UnitCastingInfo = UnitCastingInfo
local UnitChannelInfo = UnitChannelInfo
local next = next

local statuses = {}
local sguids   = {}
local tguids   = {}
local target   = setmetatable({}, {__index = function(t,k) local v=k.."target" t[k]=v return v end})

-- events management
local RegisterEvent, UnregisterEvent, EnableTimer, DisableTimer
do
	local Events = {}
	local frame
	function RegisterEvent(event, func)
		if not frame then
			frame = CreateFrame("Frame", nil, Grid2LayoutFrame)
			frame:SetScript( "OnEvent",  function(_, event, ...) Events[event](...) end )
		end
		frame:RegisterEvent(event) 
		Events[event] = func
	end	
	function UnregisterEvent(event)
		frame:UnregisterEvent( event )
		Events[event] = nil
	end
	function EnableTimer(func, delay)
		local t = delay
		frame:SetScript( "OnUpdate", function(_,e) t = t - e; if t<=0 then t = delay; func() end end )
	end
	function DisableTimer()
		frame:SetScript( "OnUpdate", nil)
	end
end

-- methods and events shared by all statuses
local function CheckEnemyUnit( sunit )
	if UnitCanAttack(sunit, "player") then
		local sg = UnitGUID(sunit)
		if sg and (not sguids[sg]) then
			local tg = UnitGUID( target[sunit] )
			if tg then
				tguids[sg] = Grid2:GetUnitidByGUID( tg )
			end
			sguids[sg] = sunit
		end	
	end	
end

local extra_units = { "focus", "boss1", "boss2", "boss3", "boss4" }
local function SearchEnemyUnits()
	for unit in Grid2:IterateRosterUnits() do
		CheckEnemyUnit( target[unit] )
	end
	for _,unit in next, extra_units do
		CheckEnemyUnit( unit )
	end
end

local function TimerEvent()
	SearchEnemyUnits()
	for status in next,statuses do
		status:Update()
	end	
	wipe(sguids)
	wipe(tguids)
end

local function CombatEnterEvent()
	if Banzai.enabled then RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", Banzai.CombatLogEvent) end	
	EnableTimer( TimerEvent, Banzai.dbx.updateRate or 0.2 )
end

local function CombatExitEvent()
	if Banzai.enabled then UnregisterEvent("COMBAT_LOG_EVENT_UNFILTERED") end	
	DisableTimer()
	for status in next,statuses do
		status:ClearIndicators()
	end	
end

local function status_OnEnable(self)
	if not next(statuses) then
		RegisterEvent("PLAYER_REGEN_ENABLED" , CombatExitEvent)
		RegisterEvent("PLAYER_REGEN_DISABLED", CombatEnterEvent)
	end
	statuses[self] = true
end

local function status_OnDisable(self)
	statuses[self] = nil
	if not next(statuses) then
		UnregisterEvent("PLAYER_REGEN_ENABLED")
		UnregisterEvent("PLAYER_REGEN_DISABLED")
	end	
end

local function status_SetUpdateRate(self, delay)
	Banzai.dbx.updateRate       = delay
	BanzaiThreat.dbx.updateRate = delay
end

-- banzai status
local bsrc, buni, bgid, bdur, bexp, bico = {}, {}, {}, {}, {}, {}

do 
	local e = {}
	e.SPELL_CAST_START       = function(g) bsrc[g]= UnitCastingInfo end
	e.SPELL_CAST_SUCCESS     = function(g) bsrc[g]= UnitChannelInfo end
	e.SPELL_CAST_INTERRUPTED = function(g) bsrc[g]= nil; local unit = bgid[g]; if unit then bexp[unit]= 0 end end
	e.SPELL_MISSED           = e.SPELL_CAST_INTERRUPTED
	e.UNIT_DIED              = e.SPELL_CAST_INTERRUPTED
	function Banzai.CombatLogEvent(_, event,_,sourceGUID)
		local action = e[event]
		if action then 
			local unit = Grid2:GetUnitidByGUID(sourceGUID)
			if not unit then action(sourceGUID) end	
		end	
	end
end	

function Banzai:Update()
	local ct = GetTime()
	for unit,guid in next,buni do -- Delete expired banzais
		if ct>=bexp[unit] then
			buni[unit], bdur[unit], bico[unit], bexp[unit], bgid[guid] = nil, nil, nil, nil, nil
			self:UpdateIndicators(unit)
		end
	end
	for g,func in next, bsrc do	-- Search new banzais
		local unit = tguids[g]
		if unit then
			local name, _,_, ico,_,et = func(sguids[g])
			if name then
				et         = et and et/1000 or ct+0.25 
				bgid[g]    = unit
				buni[unit] = g
				bdur[unit] = et - ct
				bexp[unit] = et
				bico[unit] = ico or "Interface\\ICONS\\Ability_Creature_Cursed_02"
				self:UpdateIndicators(unit)
			end	
		end
	end	
	wipe(bsrc)
end

function Banzai:ClearIndicators()
	wipe(bgid)
	wipe(bico)
	wipe(bsrc)
	wipe(bdur)
	wipe(bexp)
	for unit in next,buni do
		buni[unit] = nil
		self:UpdateIndicators(unit)
	end
end

function Banzai:IsActive(unit)
	if buni[unit] then return true end
end

function Banzai:GetDuration(unit)
	return bdur[unit]
end

function Banzai:GetExpirationTime(unit)
	return bexp[unit]
end

function Banzai:GetPercent(unit)
	local t = GetTime()
	return ((bexp[unit] or t) - t) / (bdur[unit] or 1)
end

function Banzai:GetIcon(unit)
	return bico[unit]
end

Banzai.OnEnable      = status_OnEnable
Banzai.OnDisable     = status_OnDisable
Banzai.SetUpdateRate = status_SetUpdateRate
Banzai.GetColor      = Grid2.statusLibrary.GetColor

Grid2.setupFunc["banzai"] = function(baseKey, dbx)
	Grid2:RegisterStatus(Banzai, {"color", "percent", "icon" }, baseKey, dbx)
	return Banzai
end

Grid2:DbSetStatusDefaultValue( "banzai", { type = "banzai", color1 = {r=1,g=0,b=1,a=1} })

-- banzai-threat status
local units, units_prev = {}, {}

function BanzaiThreat:Update(reset)
	units, units_prev = units_prev, units
	if not reset then
		for g,unit in next, tguids do
			local name = UnitName( sguids[g] )
			units[unit] = name
			units_prev[unit] = units_prev[unit]~=name and name or nil
		end	
	end	
	for unit in next, units_prev do
		self:UpdateIndicators(unit)
	end
	wipe(units_prev)
end

function BanzaiThreat:ClearIndicators()
	self:Update(true)
end

function BanzaiThreat:IsActive(unit)
	if units[unit] then	return true end	
end

function BanzaiThreat:GetText(unit)
	return units[unit]
end

BanzaiThreat.OnEnable  = status_OnEnable
BanzaiThreat.OnDisable = status_OnDisable
BanzaiThreat.SetUpdateRate = status_SetUpdateRate
BanzaiThreat.GetColor  = Grid2.statusLibrary.GetColor

Grid2.setupFunc["banzai-threat"] = function(baseKey, dbx)
	Grid2:RegisterStatus(BanzaiThreat, {"color", "text" }, baseKey, dbx)
	return BanzaiThreat
end

Grid2:DbSetStatusDefaultValue( "banzai-threat", { type = "banzai-threat", color1 = {r=1,g=0,b=0,a=1} })
