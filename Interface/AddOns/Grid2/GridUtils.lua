-- Misc functions

local Grid2Utils = Grid2:NewModule("Grid2Utils")

local Grid2 = Grid2

function Grid2.Dummy()
end

function Grid2:HideBlizzardRaidFrames()
	CompactRaidFrameManager:UnregisterAllEvents()
	CompactRaidFrameManager:Hide()
	CompactRaidFrameContainer:UnregisterAllEvents()
	CompactRaidFrameContainer:Hide()
end

local defaultColors = {
	TRANSPARENT = {r=0,g=0,b=0,a=0},
	BLACK       = {r=0,g=0,b=0,a=1},
	WHITE       = {r=1,g=1,b=1,a=1},
}
function Grid2:MakeColor(color, default)
	return color or defaultColors[default or "TRANSPARENT"]
end

local media = LibStub("LibSharedMedia-3.0", true)
function Grid2:MediaFetch(mediatype, key, def)
	return (key and media:Fetch(mediatype, key)) or (def and media:Fetch(mediatype, def))
end

-- UTF8 string truncate
do 
	local strbyte = string.byte
	function Grid2.strcututf8(s, c)
		local l, i = #s, 1
		while c>0 and i<=l do
			local b = strbyte(s, i)
			if     b < 192 then	i = i + 1
			elseif b < 224 then i = i + 2
			elseif b < 240 then	i = i + 3
			else				i = i + 4
			end
			c = c - 1
		end
		return s:sub(1, i-1)
	end
end

-- Table Deep Copy used by GridDefaults.lua
function Grid2.CopyTable(src, dst)
	if type(dst)~="table" then dst = {} end
	for k,v in pairs(src) do
		if type(v)=="table" then
			dst[k] = Grid2.CopyTable(v,dst[k])
		elseif not dst[k] then
			dst[k] = v
		end
	end
	return dst
end

-- Creates a location table, used by GridDefaults.lua
function Grid2.CreateLocation(a,b,c,d)
    local p = a or "TOPLEFT"
	if type(b)=="string" then
		return { relPoint = p, point = b, x = c or 0, y = d or 0 }
	else
		return { relPoint = p, point = p, x = b or 0, y = c or 0 }
	end
end

-- Common methods repository for statuses
Grid2.statusLibrary = {
	IsActive = function() 
		return true 
	end,
	GetBorder = function()
		return 1
	end,
	GetColor = function(self)
		local c = self.dbx.color1
		return c.r, c.g, c.b, c.a
	end,
	GetPercent = function(self)
		return self.dbx.color1.a
	end,
	UpdateAllUnits = function(self)
		for unit in Grid2:IterateRosterUnits() do
			self:UpdateIndicators(unit)
		end
	end,
}

--  Used by bar indicators
Grid2.AlignPoints= {
	HORIZONTAL = { 
		[true]  = { "TOPLEFT", "TOPRIGHT", "BOTTOMLEFT", "BOTTOMRIGHT" },    -- normal Fill
		[false] = { "BOTTOMRIGHT",  "BOTTOMLEFT", "TOPRIGHT", "TOPLEFT"  },  -- reverse Fill
	},	
	VERTICAL   = {
		[true]  = { "BOTTOMLEFT","TOPLEFT","BOTTOMRIGHT","TOPRIGHT" }, -- normal Fill
		[false] = { "TOPRIGHT", "BOTTOMRIGHT","TOPLEFT","BOTTOMLEFT" }, -- reverse Fill
	}	
}

-- Cheap method to hook/change on the fly some globals
-- Used by health/shields statuses to retrieve global UnitHealthMax function (see StatusShields.lua)
-- Needed to change the behavior of UnitHealthMax function in HFC Velhari encounter.
do
	local _g = {}
	Grid2.Globals = setmetatable( {}, { 
		__index    = function (t,k) return _g[k] or _G[k] end,
		__newindex = function (t,k,v) _g[k] = v; Grid2:SendMessage("Grid2_Update_"..k, v or _G[k]) end,
	} )
end

-- Hellfire Citadel Velhari Encounter Health Fix
-- Grid2Utils:FixVelhariEncounterHealth(true | false)
do
	local CONTEMPT_AURA = GetSpellInfo(179986)
	local velhari_fix = false
	local velhari_percent = -1
	local floor = math.floor
	local select = select
	local UnitAura = UnitAura
	local UnitHealthMax = UnitHealthMax
	local function VelhariHealthMax(unit)
		return floor( UnitHealthMax(unit) * velhari_percent )
	end
	local function VelhariUpdate()
		if velhari_percent~=-1 then
			local p = select(15, UnitAura("boss1", CONTEMPT_AURA))
			p = p and p/100 or 1
			if velhari_percent ~= p then
				velhari_percent = p
				Grid2.Globals.UnitHealthMax = VelhariHealthMax
			end
			C_Timer.After(1, VelhariUpdate)
		end	
	end
	function Grid2Utils:FixVelhariEncounterHealth(v)
		if v ~= velhari_fix then
			if v then
				self:RegisterEvent( "ENCOUNTER_START", function(_,ID) if ID == 1784 then velhari_percent = 1; VelhariUpdate() end end )
				self:RegisterEvent( "ENCOUNTER_END",   function() velhari_percent = -1; Grid2.Globals.UnitHealthMax = nil end )
				self:Debug("HFC Tyrant Velhari Encounter Max Health Fix: ENABLED")
			else
				self:UnregisterEvent( "ENCOUNTER_START" )
				self:UnregisterEvent( "ENCOUNTER_END" )
				self:Debug("HFC Tyrant Velhari Encounter Max Health Fix: DISABLED")				
			end 	
			velhari_fix = v
		end
	end
end

function Grid2Utils:OnModuleEnable()
	self:FixVelhariEncounterHealth( Grid2.db.profile.HfcVelhariHealthFix )
end

_G.Grid2Utils = Grid2Utils