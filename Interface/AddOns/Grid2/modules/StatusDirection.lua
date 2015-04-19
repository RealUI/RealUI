-- Direction status, shows arrows pointing to the players, created by Michael
local Direction = Grid2.statusPrototype:new("direction")

local Grid2= Grid2
local PI= math.pi
local PI2 = PI*2
local floor = math.floor
local atan2 = math.atan2
local sqrt  = math.sqrt
local GetPlayerFacing = GetPlayerFacing
local UnitPosition = UnitPosition
local UnitIsUnit= UnitIsUnit

local f_env = {
	UnitIsUnit= UnitIsUnit,
	UnitGroupRolesAssigned = UnitGroupRolesAssigned,
	UnitInRange = UnitInRange,
	UnitIsVisible = UnitIsVisible,
	UnitIsDead = UnitIsDead,
}

local timer
local distances
local directions = {}
local UnitCheck
local mouseover = ""

local function UpdateDirections()
	local x1,y1, _, map1 = UnitPosition("player")
	if not x1 then Direction:ClearDirections() return end
	local facing = GetPlayerFacing()
	for unit in Grid2:IterateRosterUnits() do
		local update, direction, distance
		if not UnitIsUnit(unit, "player") and UnitCheck(unit, mouseover) then
			local x2,y2, _, map2 = UnitPosition(unit)
			if (map1 == map2) then
				local dx, dy = x2 - x1, y2 - y1
				direction = floor((atan2(dy,dx)-facing) / PI2 * 32 + 0.5) % 32
				if distances then distance = floor( ((dx*dx+dy*dy)^0.5)/10 ) + 1 end	
			end
		end	
		if distances and distances[unit] ~= distance then
			distances[unit], update = distance, true
		end
		if direction ~= directions[unit] then
			directions[unit], update = direction, true
		end	
		if update then	
			Direction:UpdateIndicators(unit)
		end
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
	setfenv(UnitCheck, f_env)
	--
	local count = self.dbx.colorCount or 1
	if count>1 then
		distances = distances or {}
		self.GetVertexColor = Direction.GetDistanceColor
		self.colors = self.colors or {}
		for i=1,count do
			self.colors[i] = self.dbx["color"..i]
		end
	else
		distances = nil
		self.GetVertexColor = Grid2.statusLibrary.GetColor
	end
end

function Direction:OnEnable()
	self:UpdateDB()
	self:SetTimer(true)
end

function Direction:OnDisable()
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

function Direction:GetDistanceColor(unit)
	local distance = distances[unit]
	local color = distance and self.colors[distance] or self.colors[5]
	return color.r, color.g, color.b, color.a
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(Direction, {"icon"}, baseKey, dbx)

	return Direction
end

Grid2.setupFunc["direction"] = Create

Grid2:DbSetStatusDefaultValue( "direction", { type = "direction", color1 = { r= 0, g= 1, b= 0, a=1 } })
