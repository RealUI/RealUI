-- Autodetection Raid Debuffs support&register module

local L = LibStub("AceLocale-3.0"):GetLocale("Grid2Options")
local GSRD = Grid2:GetModule("Grid2RaidDebuffs")
local RDO = Grid2Options.RDO
local RDDB = RDO.RDDB

-- bosses_creatures[instanceID][creatureName] = { encounterID, encounterNameLocalized, encounterIndex }
local bosses_creatures = {}
-- known_debuffs[spellID] = true
local known_debuffs = {}
-- blacklisted debuffs
local black_debuffs = { 160029, 36032, 6788, 95223, 114216 }

local DbGetValue      = RDO.DbGetValue
local DbSetValue      = RDO.DbSetValue
local DbAddTableValue = RDO.DbAddTableValue
local DbDelTableValue = RDO.DbDelTableValue

-- Generates a table of already known raid debuffs of a zone
local function GetKnownDebuffs(curZoneId)
	local function GetZoneDebuffs(zone)
		if zone then
			for _,boss in pairs(zone) do
				for _,spell in ipairs(boss) do
					known_debuffs[spell] = true
				end
			end
		end	
	end
	wipe(known_debuffs)
	for moduleName in pairs(GSRD.db.profile.enabledModules) do
		GetZoneDebuffs( RDDB[moduleName][curZoneId] )
	end
	GetZoneDebuffs( GSRD.db.profile.debuffs[curZoneId] )
	for _,spellId in ipairs(black_debuffs) do
		known_debuffs[spellId] = true
	end	
	return known_debuffs
end

-- Collects all localized bosses names of an instance using the Encounter Journal info.
local function GetKnownBosses(instanceID)
	local creatures = bosses_creatures[instanceID]
	if not creatures then
		creatures = {}; bosses_creatures[instanceID] = creatures
		if instanceID>0 then
			-- if not IsAddOnLoaded("Blizzard_EncounterJournal") then LoadAddOn("Blizzard_EncounterJournal") end
			EJ_SelectInstance(instanceID)
			local encounterIndex = 1
			while true do
				local encounterName, _, encounterID = EJ_GetEncounterInfoByIndex(encounterIndex, instanceID)
				if not encounterID then break end
				local creatureIndex = 1
				while true do
					 local _, creatureName = EJ_GetCreatureInfo( creatureIndex, encounterID ) 
					 if not creatureName then break end
					 creatures[creatureName] = { encounterID, encounterName, encounterIndex }
					 creatureIndex = creatureIndex + 1
				end    
				encounterIndex = encounterIndex + 1
			end
		end	
	end
	return creatures
end

function RDO:SetAutodetect(value)
	if value then
		local status = self.statuses[GSRD.db.profile.autodetect.status or 1] or statuses[1]
		GSRD:EnableAutodetect( status, GetKnownDebuffs, GetKnownBosses )
	else
		GSRD:DisableAutodetect()
	end
	self.auto_enabled = value
end

function RDO:RefreshAutodetect()
	if self.auto_enabled then
		self:SetAutodetect(false)
		self:SetAutodetect(true)
	end
end

function RDO:AutodetectAddDebuff(spellId)
	known_debuffs[spellId] = true
end

function RDO:AutodetectDelDebuff(spellId)
	known_debuffs[spellId] = nil
end

-- function RDO:RegisterAutodetectedDebuffs()
do
	-- bosses_localized[localized_encounter_name] = encounter_key = RDDB[module][mapId][encounter_key] = usually english encounter name  
	local bosses_localized
	-- bosses_encounters[encounterID] = encounter_key
	local bosses_encounters
	-- When a debuff is autodetected, we have a localized boss name and maybe the encounter ID, and we want to know the encounter
	-- key in the RDDB database (to avoid duplicating bosses), the encounter key usually is the english encounter name, but this info is 
	-- not available in non-english clients. Using two aproaches, first trying to identify the bossKey using the encounter journal ID,
	-- and if not available, using a boss_localized>boss_english table, here we generate two hash tables for fast search the info.
	local function GenerateBossesLocalizationTable()
		if bosses_localized then return end
		bosses_localized, bosses_encounters = {}, {}
		for moduleName,module in pairs(RDDB) do
			if moduleName ~= "[Custom Debuffs]" then
				for _,zone in pairs(module) do
					for bossKey,boss in pairs(zone) do
						if boss.ejid and boss.ejid>0 then
							 local name_localized = EJ_GetEncounterInfo(boss.ejid)
							 if name_localized then 
								bosses_localized[name_localized] = bossKey 
								bosses_encounters[boss.ejid] = bossKey
							 end
						end
					end
				end
			end	
		end
	end
	-- instanceID = Encounter Journal instance ID / bossName = Localized boss name
	local function GetJournalEncounterInfo(instanceID, bossName)
		if instanceID and instanceID>0 and bossName then
			local encounter = GetKnownBosses(instanceID)[bossName]
			if encounter then
				return encounter[1], encounter[2], encounter[3]
			end
		end	
	end
	function RDO:RegisterAutodetectedDebuffs()
		local result
		-- Register new zones
		local new_zones = GSRD.db.profile.autodetect.zones
		if next(new_zones) then
			for zone in pairs(new_zones) do
				if not GSRD.db.profile.debuffs[zone] then
					GSRD.db.profile.debuffs[zone] = {}
					result = true
				end	
			end
			wipe(new_zones)
		end
		-- Register new debuffs
		local new_debuffs = GSRD.db.profile.autodetect.debuffs
		if next(new_debuffs) then 
			GenerateBossesLocalizationTable()
			for spellId,zoneboss in pairs(new_debuffs) do
				local zoneName, instanceID, bossName = strsplit("@", zoneboss)
				zoneName, instanceID = tonumber(zoneName), tonumber(instanceID)
				bossName = bossName~="" and bossName or nil
				if zoneName>0 then
					local encounterID, encounterName, encounterIndex = GetJournalEncounterInfo(instanceID, bossName)
					local bossKey = (encounterID and bosses_encounters[encounterID]) or (bossName and bosses_localized[bossName]) or encounterName or bossName or "Unknown"
					DbAddTableValue( spellId, GSRD.db.profile.debuffs, zoneName, bossKey)
					if not DbGetValue(GSRD.db.profile.debuffs, zoneName, bossKey, "order") then
						DbSetValue( encounterIndex or (bossKey ~= "Unknown" and 50 or 100), GSRD.db.profile.debuffs, zoneName, bossKey, "order" )
					end	
					if encounterID and (not DbGetValue(GSRD.db.profile.debuffs, zoneName, bossKey, "ejid")) then
						DbSetValue( encounterID, GSRD.db.profile.debuffs, zoneName, bossKey, "ejid" )
					end
				end	
			end
			wipe(new_debuffs)
			result = true
		end	
		return result
	end
	function RDO:InitAutodetect()
		bosses_localized = nil
		bosses_encounters = nil
		self:RegisterAutodetectedDebuffs()
	end
end
