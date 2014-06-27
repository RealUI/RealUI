-- Created by Michael

local Grid2 = Grid2
local UnitExists = UnitExists
local GetRaidTargetIndex = GetRaidTargetIndex
local rawget = rawget

-- Star, Circle, Diamond, Triangle, Moon, Square, Cross, Skull
local iconColors = {
	{r = 1.0, g = 0.92, b = 0, a = 1},
	{r = 0.98, g = 0.57, b = 0, a = 1},
	{r = 0.83, g = 0.22, b = 0.9, a = 1},
	{r = 0.04, g = 0.95, b = 0, a = 1},  
	{r = 0.7, g = 0.82, b = 0.875, a = 1},
	{r = 0, g = 0.71, b = 1, a = 1},
	{r = 1.0, g = 0.24, b = 0.168, a = 1},
	{r = 0.98, g = 0.98, b = 0.98, a = 1},
}
local iconText = {}
local iconTexture = {}
for i = 1,8 do
	iconText[i] = _G[ "RAID_TARGET_"..i ]
	iconTexture[i] = "Interface\\TargetingFrame\\UI-RaidTargetingIcon_" .. i
end

local caches = {
	["raid-icon-player"] = setmetatable({}, {__index = function(t,unit) 
		local v = GetRaidTargetIndex(unit) or false
		t[unit] = v 
		return v
	end}),
	["raid-icon-target"] = setmetatable({}, {__index = function(t,unit)
		local target = unit .. "target"
		local v = UnitExists(target) and GetRaidTargetIndex(target) or false
		t[unit] = v 
		return v
	end})
}

local RaidIcon = {}

function RaidIcon:Grid_UnitUpdated(_, unit)
	self.cache[unit] = nil
end

function RaidIcon:UpdateAllUnits()
	local cache, new, old = self.cache
	for unit, _ in Grid2:IterateRosterUnits() do
		old = rawget( cache, unit )
		cache[unit] = nil
		new = cache[unit]
		if new ~= old then
			self:UpdateIndicators(unit)
		end
	end
end

function RaidIcon:UpdateUnit(_, unit)
	self.cache[unit] = nil
	self:UpdateIndicators(unit)
end

function RaidIcon:IsActive(unit)
	local index = self.cache[unit]
	return index and index < 9
end

function RaidIcon:GetColor(unit)
	local c = self.dbx[ "color" .. self.cache[unit] ]
	return c.r, c.g, c.b, c.a --self.dbx.opacity or 1
end

function RaidIcon:GetIcon(unit)
	return iconTexture[ self.cache[unit] ]
end

function RaidIcon:GetText(unit)
	return iconText[ self.cache[unit] ]
end

function RaidIcon:SetGlobalOpacity(opacity)
	local dbx = self.dbx
	for i=1, 8 do
		dbx["color"..i].a = opacity
	end
end

function RaidIcon:OnEnable()
	self:RegisterEvent( "RAID_TARGET_UPDATE", "UpdateAllUnits" )
	self:RegisterMessage( "Grid_UnitUpdated" )
	self:RegisterMessage( "Grid_UnitLeft", "Grid_UnitUpdated" )
	if self.dbx.type=="raid-icon-target" then self:RegisterEvent("UNIT_TARGET", "UpdateUnit") end
end

function RaidIcon:OnDisable()
	wipe(self.cache)
	self:UnregisterEvent( "RAID_TARGET_UPDATE" )
	self:UnregisterMessage( "Grid_UnitUpdated" )
	self:UnregisterMessage( "Grid_UnitLeft" )
	if self.dbx.type=="raid-icon-target" then self:UnregisterEvent("UNIT_TARGET") end
end

local statuses = {}
for index,baseKey in pairs({"raid-icon-player","raid-icon-target"}) do
	local status = Grid2.statusPrototype:new(baseKey)
	status.cache = caches[baseKey]
	status:Inject(RaidIcon)
	statuses[baseKey] = status
end

local function Create(baseKey, dbx)
	local status = statuses[baseKey]
	Grid2:RegisterStatus(status, {"color", "icon", "text"}, baseKey, dbx)
	return status
end

Grid2.setupFunc["raid-icon-player"] = Create
Grid2.setupFunc["raid-icon-target"] = Create

Grid2:DbSetStatusDefaultValue( "raid-icon-player", {type = "raid-icon-player", opacity = 1, colorCount = 8,
	color1 = iconColors[1], color2 = iconColors[2], color3 = iconColors[3], color4 = iconColors[4], color5= iconColors[5], color6 = iconColors[6], color7 = iconColors[7], color8 = iconColors[8]
})
Grid2:DbSetStatusDefaultValue( "raid-icon-target", {type = "raid-icon-target", opacity = 0.5, colorCount = 8,
	color1 = iconColors[1], color2 = iconColors[2], color3 = iconColors[3], color4 = iconColors[4], color5= iconColors[5], color6 = iconColors[6], color7 = iconColors[7], color8 = iconColors[8]
})
