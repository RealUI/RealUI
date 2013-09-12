-- Direction status, shows arrows pointing to the players, created by Michael
local Direction = Grid2.statusPrototype:new("direction")

local Grid2= Grid2
local PI= math.pi
local PI2 = PI*2
local floor = math.floor
local atan2 = math.atan2
local GetPlayerFacing = GetPlayerFacing
local GetPlayerMapPosition = GetPlayerMapPosition
local SetMapToCurrentZone= SetMapToCurrentZone
local UnitIsUnit= UnitIsUnit
-- local UnitInRange= UnitInRange
-- local UnitIsVisible= UnitIsVisible
-- local UnitIsDead= UnitIsDead -- this is useless, loadstring functions dont reach this scope

local timer
-- local ValidMap
local directions= {}
local UnitCheck
local mouseover = ""

local function UpdateDirections()
	local x1,y1 = GetPlayerMapPosition("player")
	if x1 == 0 then Direction:ClearDirections() return end
	local facing = GetPlayerFacing()
	for unit,_ in Grid2:IterateRosterUnits() do
		local direction
		if not UnitIsUnit(unit, "player") and UnitCheck(unit, mouseover) then
			local x2,y2 = GetPlayerMapPosition(unit)
			if x2~=0 then
				direction = floor( (PI-atan2(x1 - x2, y2 - y1)-facing) / PI2 * 32 + 0.5) % 32
			end
		end	
		if direction ~= directions[unit] then
			directions[unit]= direction
			Direction:UpdateIndicators(unit)
		end
	end
end

local function ZoneChanged()
	if not WorldMapFrame:IsVisible() then 
		SetMapToCurrentZone()
		-- local x,y = GetPlayerMapPosition("player")
		-- local ValidMap=  (x~=0 or y~=0)
		-- Direction:SetTimer(ValidMap)
		-- if not ValidMap then
			-- Direction:ClearDirections()
		-- end
	end
end

function Direction:SetTimer(enable)
	if enable then
		if not timer then
			timer= Grid2:ScheduleRepeatingTimer(UpdateDirections, self.dbx.updateRate or 0.2)
		end
	else
		if timer then
			Grid2:CancelTimer(timer)
			timer= nil
		end
	end
end

function Direction:RestartTimer()
	if timer then
		self:SetTimer(false)
		self:SetTimer(true)
	end
end

function Direction:ClearDirections()
	for unit,_ in pairs(directions) do
		directions[unit]= nil
		self:UpdateIndicators(unit)
	end
end

local SetMouseoverHooks -- UnitIsUnit(unit, "mouseover") does not work for units that are not Visible
do
	local prev_OnEnter
	local function OnMouseEnter(self, frame)
		mouseover = frame.unit
		prev_OnEnter(self, frame)
	end

	local prev_OnLeave
	local function OnMouseLeave(self, frame)
		mouseover = ""
		prev_OnLeave(self, frame)
	end

	SetMouseoverHooks = function(enable)
		if not prev_OnEnter and enable then
			prev_OnEnter = Grid2Frame.OnFrameEnter
			prev_OnLeave = Grid2Frame.OnFrameLeave
			Grid2Frame.OnFrameEnter = OnMouseEnter
			Grid2Frame.OnFrameLeave = OnMouseLeave
		elseif prev_OnEnter and not enable then
			Grid2Frame.OnFrameEnter = prev_OnEnter
			Grid2Frame.OnFrameLeave = prev_OnLeave
			prev_OnEnter = nil
			prev_OnLeave = nil
			mouseover = ""
		end
	end
end

function Direction:UpdateDB()	
	local isRestr
	t= {}
	t[1] = "return function(unit) return "
	if not self.dbx.showOnlyStickyUnits then
		if self.dbx.ShowOutOfRange 	then t[#t+1]= "and (not UnitInRange(unit)) "; isRestr=true 	end
		if self.dbx.ShowVisible 	then t[#t+1]= "and UnitIsVisible(unit) "; isRestr=true		end
		if self.dbx.ShowDead 		then t[#t+1]= "and UnitIsDead(unit) "; isRestr=true			end
	end
	if isRestr or self.dbx.showOnlyStickyUnits then
		if self.dbx.StickyTarget	then t[#t+1]= "or  UnitIsUnit(unit, 'target') "		end
		if self.dbx.StickyMouseover	then t[#t+1]= "or  UnitIsUnit(unit, mouseover) "
										 t[1]	= "return function(unit, mouseover) return " end
		if self.dbx.StickyFocus		then t[#t+1]= "or  UnitIsUnit(unit, 'focus') "	end
		if self.dbx.StickyTanks		then t[#t+1]= "or  UnitGroupRolesAssigned(unit)=='TANK' " end
	end
	if t[2] then
		t[2] = t[2]:sub(5)
	else
		t[2] = "true " 
	end
	t[#t+1]= "end"
	SetMouseoverHooks((isRestr or self.dbx.showOnlyStickyUnits) and self.dbx.StickyMouseover)
	UnitCheck = assert(loadstring(table.concat(t)))()
end

function Direction:OnEnable()
	self:UpdateDB()
	self:RegisterEvent("PLAYER_ENTERING_WORLD", ZoneChanged)
	self:RegisterEvent("ZONE_CHANGED", ZoneChanged)
	self:RegisterEvent("ZONE_CHANGED_NEW_AREA", ZoneChanged)
	self:RegisterEvent("ZONE_CHANGED_INDOORS", ZoneChanged)
	self:SetTimer(true)
end

function Direction:OnDisable()
	self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	self:UnregisterEvent("ZONE_CHANGED")
	self:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
	self:UnregisterEvent("ZONE_CHANGED_INDOORS")
	self:SetTimer(false)
end

function Direction:IsActive(unit)
	return directions[unit] and true
end

function Direction:GetIcon(unit)
	return "Interface\\Addons\\Grid2\\media\\Arrows32-32x32"
end

function Direction:GetTexCoord(unit)
	local y= directions[unit] / 32
	return 0.05, 0.95, y+0.0015625, y+0.028125
end

Direction.GetVertexColor = Grid2.statusLibrary.GetColor

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Direction, {"icon"}, baseKey, dbx)

	return Direction
end

Grid2.setupFunc["direction"] = Create

Grid2:DbSetStatusDefaultValue( "direction", { type = "direction", color1 = { r= 0, g= 1, b= 0, a=1 } })
