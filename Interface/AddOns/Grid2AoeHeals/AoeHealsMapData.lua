local AOEM = Grid2:GetModule("Grid2AoeHeals")

local GetMapInfo = GetMapInfo
local SetMapToCurrentZone = SetMapToCurrentZone
local GetPlayerMapPosition = GetPlayerMapPosition
local GetCurrentMapDungeonLevel = GetCurrentMapDungeonLevel
local GetCurrentMapZone = GetCurrentMapZone
local strfind,strsub = strfind, strsub

local frame, curMap, curFloor, curMapWidth, curMapHeight

local function ZoneChanged()
	if not WorldMapFrame:IsVisible() then 
		SetMapToCurrentZone()
		local x,y = GetPlayerMapPosition("player")
		if x ~= 0 or y ~= 0 then
			local newMap = GetMapInfo()
			if newMap then
				local newFloor, x1, y1, x2, y2 = GetCurrentMapDungeonLevel()
				if newMap ~= curMap or newFloor ~= curFloor then
					curMap, curFloor = newMap, newFloor
					if not x1 then
						x1, y1, x2, y2 = select(2, GetCurrentMapZone())
					end
					curMapWidth, curMapHeight = abs(x1-x2), abs(y1-y2)
					AOEM:Debug("Zone changed:", curMap, curFloor, curMapWidth, curMapHeight)
				end
				return
			end	
		end	
		curMapWidth, curMapHeight = nil, nil	
	end
end

--{{ Public methods

-- Enable zone change tracking
function AOEM:MapEnable()
	if not frame then
		frame = CreateFrame("Frame") 
		frame:SetScript("OnEvent", ZoneChanged )
	end
	frame:RegisterEvent("PLAYER_ENTERING_WORLD")
	frame:RegisterEvent("ZONE_CHANGED")
	frame:RegisterEvent("ZONE_CHANGED_NEW_AREA")
	frame:RegisterEvent("ZONE_CHANGED_INDOORS")
	ZoneChanged()
end

-- Disable zone change tracking
function AOEM:MapDisable()
	if frame then frame:UnregisterAllEvents() end
end

-- Returns current zone width and height
function AOEM:MapGetSize()
	if curFloor ~= GetCurrentMapDungeonLevel() then 
		ZoneChanged()  -- Seems WOW does not call ZoneChanged when floor changes
	end
	return curMapWidth, curMapHeight
end
--}}