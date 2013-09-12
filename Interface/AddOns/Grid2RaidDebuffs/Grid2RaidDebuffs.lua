-- Raid Debuffs module, implements raid-debuffs statuses

local GSRD = Grid2:NewModule("Grid2RaidDebuffs")
-- local BZ = LibStub("LibBabble-Zone-3.0"):GetReverseLookupTable()
local frame = CreateFrame("Frame")

local Grid2 = Grid2
local next = next
local ipairs = ipairs
local UnitDebuff = UnitDebuff
local GetSpellInfo = GetSpellInfo

local curzone
local statuses = {}
local spells_order = {}
local spells_status = {}

GSRD.engMapName_to_mapID = { 
	--this is for updating old saved settings after removing LibBabble-Zone, the names wont be used anymore
	--users should not have to update all old settings
	
	--Mists of Pandaria
	["Heart of Fear"] = 897,
	["Mogu'shan Vaults"] = 896,
	["Kun-Lai Summit"] = 809,
	["Terrace of Endless Spring"] = 886,
	["Throne of Thunder"] = 930,
	--Cataclysm
	["Blackwing Descent"] = 754,
	["The Bastion of Twilight"] = 758,
	["Throne of the Four Winds"] = 773,
   	["Baradin Hold"] = 752,
	["Firelands"] = 800,
	["Dragon Soul"] = 824,
	--Wrath of the Lich King
	["Naxxramas"] = 535,
	["The Eye of Eternity"] = 527,
	["The Obsidian Sanctum"] = 531,
	["The Ruby Sanctum"] = 609,
	["Trial of the Crusader"] = 543,
	["Ulduar"] = 529,
	["Vault of Archavon"] = 532,
	["Icecrown Citadel"] = 604,
	--The Burning Crusade
	["Karazhan"] = 799,
	["Zul'Aman"] = 781,
	["Serpentshrine Cavern"] = 780,
	["Hyjal Summit"] = 775,
	["Black Temple"] = 796,
	["Sunwell Plateau"] = 789,
}

frame:SetScript("OnEvent", function (self, event, unit)
	local index = 1
	while true do
		local name, _, te, co, ty, du, ex, _, _, _, id = UnitDebuff(unit, index)
		if not name then break end
		local order = spells_order[name]
		if not order then
			order, name = spells_order[id], id
		end
		if order then
			spells_status[name]:AddDebuff(order, te, co, ty, du, ex)
		end	
		index = index + 1
	end
	for status in next, statuses do
		status:UpdateState(unit)
	end
end)

function GSRD:OnModuleEnable()
	self:UpdateZoneSpells(true)
end

function GSRD:OnModuleDisable()
	self:ResetZoneSpells()
end

function GSRD:UpdateZoneSpells(event)
	local zone = self:GetCurrentZone()
	if zone==curzone and event then return end
	
	self:ResetZoneSpells(zone)
	for status in next,statuses do
		status:LoadZoneSpells()
	end
	self:UpdateEvents()
	self:ClearAllIndicators()
end

function GSRD:GetCurrentZone()
	local current_zone_on_worldmap = GetCurrentMapAreaID()
	SetMapToCurrentZone()
	local zone = GetCurrentMapAreaID()
	if zone ~= current_zone_on_worldmap then 
		SetMapByID(current_zone_on_worldmap) 
	end
	return zone
end

function GSRD:ClearAllIndicators()
	for status in next, statuses do
		status:ClearAllIndicators()
	end	
end

function GSRD:ResetZoneSpells(newzone)
	curzone = newzone
	wipe(spells_order)
	wipe(spells_status)
end

function GSRD:UpdateEvents()
	local new = not next(spells_order)
	local old = not frame:IsEventRegistered("UNIT_AURA")
	if new ~= old then
		if new then
			frame:UnregisterEvent("UNIT_AURA")					
		else
			frame:RegisterEvent("UNIT_AURA")
		end
	end
end

function GSRD:Grid_UnitLeft(_, unit)
	for status in next, statuses do
		status:ResetState(unit)
	end	
end

local class = {
	GetColor          = Grid2.statusLibrary.GetColor,
	IsActive          = function(self, unit) return self.states[unit]      end,
	GetIcon           = function(self, unit) return self.textures[unit]    end,
	GetCount          = function(self, unit) return self.counts[unit]      end,
	GetDuration       = function(self, unit) return self.durations[unit]   end,
	GetExpirationTime = function(self, unit) return self.expirations[unit] end,
}	

function class:ClearAllIndicators()
	local states = self.states
	for unit in pairs(states) do
		states[unit] = nil
		self:UpdateIndicators(unit)
	end
end

function class:LoadZoneSpells()
	if curzone then		
		local debuffs = self.dbx.debuffs
		if debuffs then --updating variables after LibBabble-Zone removal
			for k,v in pairs(debuffs) do
				if type(k) == "string" and GSRD.engMapName_to_mapID[k] then
					debuffs[GSRD.engMapName_to_mapID[k]]=v
					debuffs[k]=nil
				end
			end
		end
		local count = 0
		local db = self.dbx.debuffs[curzone]
		if db then
			for index, spell in ipairs(db) do
				local name = spell<0 and -spell or GetSpellInfo(spell)
				if name and (not spells_order[name]) then
					spells_order[name]  = index
					spells_status[name] = self
					count = count + 1
				end
			end
		end
		if GSRD.debugging then
			GSRD:Debug("Zone [%s] Status [%s]: %d raid debuffs loaded", curzone or "", self.name, count)
		end
	end
end

function class:OnEnable()
	if not next(statuses) then
		GSRD:RegisterEvent("ZONE_CHANGED_NEW_AREA", "UpdateZoneSpells")
		GSRD:RegisterMessage("Grid_UnitLeft")
	end
	statuses[self] = true
	self:LoadZoneSpells()
	GSRD:UpdateEvents()
end

function class:OnDisable()
	statuses[self] = nil
	if not next(statuses) then
		GSRD:UnregisterEvent("ZONE_CHANGED_NEW_AREA")
		GSRD:UnregisterMessage("Grid_UnitLeft")
		GSRD:ResetZoneSpells()
		GSRD:UpdateEvents()
	end	
end

function class:AddDebuff(order, te, co, ty, du, ex, id)
	if order < self.order or ( order == self.order and co > self.count ) then
		self.order      = order
		self.count      = co
		self.texture    = te
		self.type       = ty
		self.duration   = du
		self.expiration = ex
	end
end

function class:UpdateState(unit)
	if self.order<10000 then
		if self.count==0 then self.count = 1 end
		if	true            ~= self.states[unit]    or 
			self.count      ~= self.counts[unit]    or 
			self.type       ~= self.types[unit]     or
			self.texture    ~= self.textures[unit]  or
			self.duration   ~= self.durations[unit] or	
			self.expiration ~= self.expirations[unit]
		then
			self.states[unit]      = true
			self.counts[unit]      = self.count
			self.textures[unit]    = self.texture
			self.types[unit]       = self.type
			self.durations[unit]   = self.duration
			self.expirations[unit] = self.expiration
			self:UpdateIndicators(unit)
		end
		self.order, self.count = 10000, 0
	elseif self.states[unit] then
		self.states[unit] = nil
		self:UpdateIndicators(unit)
	end
end

function class:ResetState(unit)
	self.states[unit]      = nil
	self.counts[unit]      = nil
	self.textures[unit]    = nil
	self.types[unit]       = nil
	self.durations[unit]   = nil
	self.expirations[unit] = nil
end

local function Create(baseKey, dbx)
	local status = Grid2.statusPrototype:new(baseKey, false)
	status.states      = {}
	status.textures    = {}
	status.counts      = {}
	status.types       = {}
	status.durations   = {}
	status.expirations = {}
	status.count       = 0
	status.order       = 10000
	status:Inject(class)
	Grid2:RegisterStatus(status, { "icon", "color" }, baseKey, dbx)
	return status
end

Grid2.setupFunc["raid-debuffs"] = Create

Grid2:DbSetStatusDefaultValue( "raid-debuffs", {type = "raid-debuffs", debuffs={}, color1 = {r=1,g=.5,b=1,a=1}} )

-- Hook to load Grid2RaidDebuffOptions module
local prev_LoadOptions = Grid2.LoadOptions
function Grid2:LoadOptions()
	LoadAddOn("Grid2RaidDebuffsOptions")
	prev_LoadOptions(self)
end

-- Hook to update database config
local prev_UpdateDefaults = Grid2.UpdateDefaults
function Grid2:UpdateDefaults()
	prev_UpdateDefaults(self)
	if not Grid2:DbGetValue("versions", "Grid2RaidDebuffs") then 
		Grid2:DbSetMap( "icon-center", "raid-debuffs", 155)
		Grid2:DbSetValue("versions","Grid2RaidDebuffs",1)
	end	
end
