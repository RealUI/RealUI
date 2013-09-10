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
local UnitInRange= UnitInRange
local UnitIsVisible= UnitIsVisible
local UnitIsDead= UnitIsDead

local timer
local ValidMap
local directions= {}
local UnitCheck

local function UpdateDirections()
	local x1,y1 = GetPlayerMapPosition("player")
	local facing = GetPlayerFacing()
	for unit,_ in Grid2:IterateRosterUnits() do
		local direction
		if UnitCheck(unit) then
			local x2,y2 = GetPlayerMapPosition(unit)
			direction= floor( (PI-atan2(x1 - x2, y2 - y1)-facing) / PI2 * 32 + 0.5) % 32
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
		local x,y = GetPlayerMapPosition("player")
		local ValidMap=  (x~=0 or y~=0)
		Direction:SetTimer(ValidMap)
		if not ValidMap then
			Direction:ClearDirections()
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

function Direction:UpdateDB()	
	t= {}
	t[1] = "return function(unit) return (not UnitIsUnit(unit, 'player')) "
	if self.dbx.ShowOutOfRange 	then t[#t+1]= "and (not UnitInRange(unit)) "	end
	if self.dbx.ShowVisible 	then t[#t+1]= "and UnitIsVisible(unit) "		end
	if self.dbx.ShowDead 		then t[#t+1]= "and UnitIsDead(unit) "			end
	t[#t+1]= "end"
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
