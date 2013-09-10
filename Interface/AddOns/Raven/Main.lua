-- Raven is an addon to monitor auras and cooldowns, providing timer bars, action bar highlights, and helpful notifications.

-- Main.lua contains initialization and update routines supporting Raven's core capability of tracking active auras and cooldowns.
-- It includes special cases for weapon buffs, stances, and trinkets.

-- Exported functions:
-- Raven:CheckAura(unit, name, isBuff) checks if an aura is active on a unit, returning detailed info if found
-- Raven:IterateAuras(unit, func, isBuff, p1, p2, p3) calls func for each active aura, parameters include a table with detailed aura info 
-- Raven:CheckCooldown(name) checks if cooldown with the specified name is active, returning detailed info if found
-- Raven:IterateCooldowns(func, p1, p2, p3) calls func for each active cooldown, parameters include a table with detailed cooldown info
-- Raven:UnitHasBuff(unit, type) returns true and table with detailed info if unit has an active buff of the specified type (e.g., "Mainhand")
-- Raven:UnitHasDebuff(unit, type) returns true and table with detailed info if unit has an active debuff of the specified type (e.g., "Poison")

-- Mists of Pandaria (WoW 5.0) changes
-- (done) Talent changes: rewrite talent tracking, change talent condition checking
-- (done) Special cases: revisit old special cases such as serpent sting spreading
-- (done) Dispel changes: change to test for spell availability instead of talents
-- (done) Party/raid changes: rewrite code that tests if in party or raid, change party/raid-related condition checking
-- (done) Presets: update all class presets with new spell ids and cooldown info
-- (done) UI: change UIPanelButtonTemplate2 to UIPanelButtonTemplate
-- (done) Ranged slot: remove from buff and cooldown tracking, no ranged slot-related conditions
-- (done) Vehicle/possess: change action bar slots

Raven = LibStub("AceAddon-3.0"):NewAddon("Raven", "AceConsole-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local MOD = Raven
local MOD_Options = "Raven_Options"
local optionsLoaded = false -- set when the load-on-demand options panel module has been loaded
local optionsFailed = false -- set if loading the option panel module failed
MOD.updateOptions = false -- set this to cause the options panel to update (checked every half second)
MOD.LocalSpellNames = {} -- must be defined in first module loaded
local LSPELL = MOD.LocalSpellNames
MOD.frame = nil
MOD.db = nil
MOD.ldb = nil
MOD.ldbi = nil -- set when using DBIcon library
MOD.myClass = nil; MOD.localClass = nil
MOD.myRace = nil; MOD.localRace = nil
MOD.lockSpells = {} -- spells for testing lock out of each school of magic for current player
MOD.classSpells = {} -- stores info about pre-defined spells for each class
MOD.petSpells = {} -- stores info about pre-defined spells for pets
MOD.classConditions = {} -- stores info about pre-defined conditions for each class
MOD.talents = {} -- table containing names and talent table location for each talent
MOD.talentList = {} -- table with list of talent names
MOD.talentSpec = nil -- currently active talent spec
MOD.runeSlots = {} -- cache information about each rune slot for DKs
MOD.runeTypes = {} -- cache types of runes
MOD.runeIcons = {} -- cache icons for Death Knight runes
MOD.updateActions = true -- action bar changed
MOD.updateDispels = true -- need to update dispel types
MOD.knownGlyphs = {} -- cache of known glyphs
MOD.activeGlyphs = {} -- cache of active glyphs

local doUpdate = true -- set by any event that can change bars (used to throttle major updates)
local forceUpdate = false -- set to cause immediate update (reserved for critical changes like to player's target or focus)
local updateCooldowns = false -- set when actionbar or inventory slot cooldown starts or stops
local updateGlyphs = true -- set when need to update cache of glyph info
local units = { "player", "pet", "target", "focus", "targettarget", "focustarget", "pettarget", "mouseover" } -- ordered list of units
local eventUnits = { "targettarget", "focustarget", "pettarget", "mouseover" } -- can't count on events for these units
local unitUpdate = {} -- boolean for each unit that indicates need to update auras
local unitStatus = {} -- status of each unit set on every update (0 = no unit, 1 = unit exists, "unit" = unit is other unit)
local unitBuffs = {} -- indexed by GUID for tracking buffs cast by player
local unitDebuffs = {} -- indexed by GUID for tracking debuffs cast by player
local activeBuffs = {} -- active buffs for each unit
local activeDebuffs = {} -- active debuffs for each unit
local cacheBuffs = {} -- cache of active buff names
local cacheDebuffs = {} -- cache of active debuff names
local cacheUnits = {} -- cache of unit IDs, indexed by GUID
local refreshUnits = {} -- unit id cache used to optimize refresh
local tablePool = {} -- pool of available tables
local activeCooldowns = {} -- spells/items that are currently on cooldown
local internalCooldowns = {} -- tracking entries for internal cooldowns
local spellEffects = {} -- tracking entries for spell effects
local elapsedTime = 0 -- time in seconds since last update
local refreshTime = 0 -- time since last animation refresh
local refreshThrottle = 0.04 -- max of around 25 times per second
local throttleTime = 0.2 -- minimum time in seconds between updates
local throttleCount = 0 -- secondary throttle incremented at each update, resets at 5
local bufftooltip = nil -- used to store tooltip for scanning weapon buffs
local mhLastBuff = nil -- saves name of most recent main hand weapon buff
local ohLastBuff = nil -- saves name of most recent off hand weapon buff
local iconGCD = nil -- icon for global cooldown
local iconPotion = nil -- icon for shared potions cooldown
local iconElixir = nil -- icon for shared elixirs cooldown
local lastTotems = {} -- cache last totems in each slot to see if changed
local lockouts = {} -- schools of magic that we are currently locked out of
local lockstarts = {} -- start times for current school lockouts
local talentsInitialized = false -- set once talents have been initialized
local matchTable = {} -- passed from MOD:CheckAura with list of active auras
local startGCD, durationGCD = nil -- detect global cooldowns
local raidTargets = {} -- raid target to GUID
local shamanEnchants = nil -- table of shaman weapon enchants
local fireSpells = nil -- special case support for mage Impact procs
local petGUID = nil -- cache pet GUID so can properly remove trackers for them when dismissed
local enteredWorld = nil -- set by PLAYER_ENTERING_WORLD event
local trackerTag = 0 -- used for mark/sweep in AddTrackers
local professions = {} -- temporary table for profession indices

-- This table is used to fix the "not cast by player" bug for Jade Spirit, River's Song, and Dancing Steel introduced in 5.1
-- and the legendary meta gem procs Tempus Repit, Fortitude, Capacitance, and Lucidity added in 5.2
local fixEnchants = { [104993] = true, [120032] = true, [118334] = true, [118335] = true, [116660] = true,
	[137590] = true, [137593] = true, [137331] = true, [137323] = true, [137247] = true, [137596] = true }

-- Initialization called when addon is loaded
function MOD:OnInitialize()
	local _
	MOD.localClass, MOD.myClass = UnitClass("player") -- cache the player's class
	MOD.localRace, MOD.myRace = UnitRace("player") -- cache the player's race
	LoadAddOn("LibDataBroker-1.1")
	LoadAddOn("LibDBIcon-1.0")
	LoadAddOn("LibBossIDs-1.0", true)
	MOD.MSQ = LibStub("Masque", true)
end

-- Functions called to trigger updates
local function TriggerPlayerUpdate() unitUpdate.player = true; doUpdate = true end
local function TriggerCooldownUpdate() updateCooldowns = true; doUpdate = true end
local function TriggerActionsUpdate() MOD.updateActions = true; doUpdate = true end
local function TriggerGlyphUpdate() updateGlyphs = true; doUpdate = true end
function MOD:ForceUpdate() doUpdate = true; forceUpdate = true end

-- Function called to detect global cooldowns
local function CheckGCD(event, unit, spell)
	if unit == "player" then
		local start, duration = GetSpellCooldown(spell)
		if start and duration and (duration > 0) and (duration <= 1.5) then startGCD = start; durationGCD = duration; TriggerCooldownUpdate() end
	end
end

-- Function called for successful spell cast
local function CheckSpellCasts(event, unit, spell)
	CheckGCD(event, unit, spell)
	if MOD.db.global.DetectSpellEffects then MOD:DetectSpellEffect(spell, unit) end -- check if spell triggers a spell effect
end

-- Create and delete routines for managing tables, using a recycling pool to minimize garbage collection
local function AllocateTable() local b = next(tablePool); if b then tablePool[b] = nil else b = {} end return b end
local function ReleaseTable(b) table.wipe(b); tablePool[b] = true; return nil end

-- Compare unit and global ids, updating cache with latest info
local function CheckUnitIDs(uid, guid)
	local id = UnitGUID(uid)
	if id == guid then return uid end
	if id then cacheUnits[id] = uid end
	return nil
end

-- Add or update a tracker entry, including an option tag useful for mark/sweep type garbage collection
local function AddTracker(dstGUID, dstName, isBuff, name, rank, icon, count, btype, duration, expire, caster, isStealable, spellID, boss, apply, tag)
	doUpdate = true
	local tracker = isBuff and unitBuffs[dstGUID] or unitDebuffs[dstGUID] -- get or create the aura tracking table
	if not tracker then tracker = AllocateTable() if isBuff then unitBuffs[dstGUID] = tracker else unitDebuffs[dstGUID] = tracker end end
	local t = tracker[name] -- get or create a tracker entry for the spell
	if not t then t = AllocateTable(); tracker[name] = t end -- create the tracker if necessary
	local vehicle = UnitHasVehicleUI("player")
	t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9], t[10], t[11], t[12], t[13], t[14], t[15], t[16], t[17], t[18], t[19], t[20], t[21], t[22] =
		true, 0, count, btype, duration, caster, isStealable, icon, rank, expire, "spell id", spellID, name, spellID, boss, UnitName("player"), apply, nil, vehicle, dstGUID, dstName, tag
end

-- Remove tracker entries for a unit, if tag is specified then only remove if tracker tag not equal
function MOD:RemoveTrackers(dstGUID, tag)
	doUpdate = true
	local tracker = unitBuffs[dstGUID] -- table of buffs currently applied to this GUID
	if tracker then
		for id, t in pairs(tracker) do if not tag or t[22] ~= tag then tracker[id] = ReleaseTable(t) end end
		if not next(tracker) then unitBuffs[dstGUID] = ReleaseTable(tracker) end -- release the debuffs associated with the GUID
	end
	local tracker = unitDebuffs[dstGUID] -- table of auras currently applied to this GUID
	if tracker then
		for id, t in pairs(tracker) do if not tag or t[22] ~= tag then tracker[id] = ReleaseTable(t) end end
		if not next(tracker) then unitDebuffs[dstGUID] = ReleaseTable(tracker) end -- release the table associated with the GUID
	end
end

-- Add trackers for a unit
function MOD:AddTrackers(unit)
	local dstGUID, dstName = UnitGUID(unit), UnitName(unit)
	if dstGUID and dstName and not refreshUnits[dstGUID] then
		refreshUnits[dstGUID] = true
		local name, rank, icon, count, btype, duration, expire, caster, isStealable, _, spellID, boss, apply
		trackerTag = trackerTag + 1 -- unique tag for this pass
		local i = 1
		repeat
			name, rank, icon, count, btype, duration, expire, caster, isStealable, _, spellID, apply = UnitAura(unit, i, "HELPFUL|PLAYER")
			if name and caster == "player" then
				AddTracker(dstGUID, dstName, true, name, rank, icon, count, btype, duration, expire, caster, isStealable, spellID, nil, apply, trackerTag)
				MOD:SetDuration(name, duration)
			end
			i = i + 1
		until not name
		if dstGUID ~= UnitGUID("player") then
			i = 1
			repeat
				name, rank, icon, count, btype, duration, expire, caster, isStealable, _, spellID, apply, boss = UnitAura(unit, i, "HARMFUL|PLAYER")
				if name and caster == "player" then
					AddTracker(dstGUID, dstName, false, name, rank, icon, count, btype, duration, expire, caster, isStealable, spellID, boss, apply, trackerTag)
					MOD:SetDuration(name, duration)
				end
				i = i + 1
			until not name
		end
		MOD:RemoveTrackers(dstGUID, trackerTag) -- takes advantage of side-effect of saving current trackerTag with each tracker
	end
end

-- Check if currently tracking a unit
local function IsBeingTracked(dstGUID) return unitBuffs[dstGUID] and unitDebuffs[dstGUID] end

-- Validate cached ids, garbage collect any that are out-of-date
local function ValidateUnitIDs()
	for guid, uid in pairs(cacheUnits) do if UnitGUID(uid) ~= guid then cacheUnits[guid] = nil end end
end

-- Refresh trackers for common units
local function RefreshTrackers()
	ValidateUnitIDs()
	table.wipe(refreshUnits) -- table of guids to prevent refreshing multiple times
	MOD:AddTrackers("player"); MOD:AddTrackers("target");  MOD:AddTrackers("focus")
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do MOD:AddTrackers("raid"..i); MOD:AddTrackers("raidpet"..i); MOD:AddTrackers("raid"..i.."target") end
	else
		for i = 1, GetNumGroupMembers() do MOD:AddTrackers("party"..i); MOD:AddTrackers("partypet"..i); MOD:AddTrackers("party"..i.."target") end
	end
	local pgid = UnitGUID("pet")
	if petGUID and (petGUID ~= pgid) then MOD:RemoveTrackers(petGUID) end
	petGUID = pgid; if pgid then MOD:AddTrackers("pet") end
end

-- Get a unit id suitable for calling UnitAura from a GUID
local function GetUnitIDFromGUID(guid)
	local uid = cacheUnits[guid] -- look up the guid in the cache and if it is there make sure it is still valid and then return it
	if uid then if guid == UnitGUID(uid) then return uid else uid = nil end end
	for _, unit in pairs(units) do uid = CheckUnitIDs(unit, guid); if uid then break end end -- first check primary units
	local inRaid = IsInRaid()
	if not uid and not inRaid then -- check party, party pet, and party target units
		for i = 1, GetNumGroupMembers() do
			uid = CheckUnitIDs("party"..i, guid); if uid then break end
			uid = CheckUnitIDs("partypet"..i, guid); if uid then break end
			uid = CheckUnitIDs("party"..i.."target", guid); if uid then break end
		end
	end
	if not uid and inRaid then -- check raid, raid pet, and raid target units
		for i = 1, GetNumGroupMembers() do
			uid = CheckUnitIDs("raid"..i, guid); if uid then break end
			uid = CheckUnitIDs("raidpet"..i, guid); if uid then break end
			uid = CheckUnitIDs("raid"..i.."target", guid); if uid then break end
		end
	end
	cacheUnits[guid] = uid
	return uid
end

-- Function called for combat log events to track hots and dots (updated for 4.2)
local function CombatLogTracker(event, timeStamp, e, hc, srcGUID, srcName, sf1, sf2, dstGUID, dstName, df1, df2, spellID, spellName, spellSchool)
	if srcGUID == UnitGUID("player") then -- make sure event is from a player action
		doUpdate = true
		local now = GetTime()
		if e == "SPELL_CAST_SUCCESS" then -- check for special cases
			if spellID == 33763 then e = "SPELL_AURA_APPLIED" end -- Lifebloom refreshes don't always generate aura applied events
		end
		if e == "SPELL_AURA_APPLIED" or e == "SPELL_AURA_APPLIED_DOSE" or e == "SPELL_AURA_REFRESH" then
			local name, rank, icon, count, bType, duration, expire, caster, isStealable, boss, apply, _
			local isBuff, dst = true, GetUnitIDFromGUID(dstGUID)
			if dst and UnitExists(dst) then
				name, rank, icon, count, bType, duration, expire, caster, isStealable, _, _, apply = UnitAura(dst, spellName, nil, "HELPFUL|PLAYER")
				if not name and (srcGUID ~= dstGUID) then -- don't get debuffs cast by player on self (e.g., Sated)
					isBuff = false
					name, rank, icon, count, bType, duration, expire, caster, isStealable, _, _, apply, boss = UnitAura(dst, spellName, nil, "HARMFUL|PLAYER")
				end
				if name then MOD:SetDuration(name, duration) end
			end
			if not spellID then spellID = MOD:GetSpellID(spellName) end
			if spellID and not icon then icon = MOD:GetIcon(spellName, spellID) end
			if not name then
				name = spellName; rank = ""; count = 1; bType = nil; duration = MOD:GetDuration(name)
				if duration > 0 then expire = now + duration else duration = 0; expire = 0 end
				caster = "player"; isStealable = nil; boss = nil; apply = nil; isBuff = false
				if MOD.BuffTable[name] ~= nil then
					isBuff = true
				elseif MOD.DebuffTable[name] == nil then
					isBuff = (bit.band(df1, COMBATLOG_OBJECT_REACTION_MASK) ~= COMBATLOG_OBJECT_REACTION_HOSTILE)
				end
			end
			if name and caster == "player" and (isBuff or (srcGUID ~= dstGUID)) then
				AddTracker(dstGUID, dstName, isBuff, name, rank, icon, count, btype, duration, expire, caster, isStealable, spellID, boss, apply, nil)
			end
			if dstGUID == UnitGUID("target") and not IsBeingTracked(dstGUID) then ValidateUnitIDs() end -- refresh all auras when target changes
			if MOD.db.global.DetectInternalCooldowns then MOD:DetectInternalCooldown(spellName, false) end -- check internal cooldowns
		elseif e == "SPELL_ENERGIZE" or e == "SPELL_HEAL" then
			if MOD.db.global.DetectInternalCooldowns then MOD:DetectInternalCooldown(spellName, false) end -- check internal cooldowns
		elseif e == "SPELL_AURA_REMOVED" then
			local tracker = unitBuffs[dstGUID] -- table of buffs currently applied to this GUID
			if tracker then
				local t = tracker[spellName] -- get tracker entry for the spell, if one exists
				if t then tracker[spellName] = ReleaseTable(t) end -- release the tracker entry
				if not next(tracker) then unitBuffs[dstGUID] = ReleaseTable(tracker) end -- release table when no more entries for this GUID
			end
			tracker = unitDebuffs[dstGUID] -- table of debuffs currently applied to this GUID
			if tracker then
				local t = tracker[spellName] -- get tracker entry for the spell, if one exists
				if t then tracker[spellName] = ReleaseTable(t) end -- release the tracker entry
				if not next(tracker) then unitDebuffs[dstGUID] = ReleaseTable(tracker) end -- release table when no more entries for this GUID
			end
		elseif e == "SPELL_SUMMON" and MOD.myClass == "MAGE" and spellID == 99063 then -- special case for mage T12 2-piece
			local name = GetSpellInfo(99061) -- T12 bonus spell name
			if name then
				if MOD.db.global.DetectInternalCooldowns then MOD:DetectInternalCooldown(name, false) end
				if MOD.db.global.DetectSpellEffects then MOD:DetectSpellEffect(name, "player") end
			end
		end
	elseif dstGUID == UnitGUID("player") then
		if e == "SPELL_AURA_APPLIED" or e == "SPELL_AURA_APPLIED_DOSE" or e == "SPELL_AURA_REFRESH" or e == "SPELL_ENERGIZE" or e == "SPELL_HEAL" then
			if MOD.db.global.DetectInternalCooldowns then MOD:DetectInternalCooldown(spellName, true) end -- check aura triggers or cancels an internal cooldown
		end
	end
	if e == "UNIT_DIED" or e == "UNIT_DESTROYED" then
		MOD:RemoveTrackers(dstGUID) -- remove the trackers currently associated with this GUID
		cacheUnits[dstGUID] = nil -- release the unit cache entry for this GUID too
	end
end

-- Check if there is a raid target on a unit
local function CheckRaidTarget(unit)
	local id = UnitGUID(unit)
	if id then
		local index = GetRaidTargetIndex(unit)
		for k, v in pairs(raidTargets) do if (v == id) and (k ~= index) then raidTargets[k] = nil end end 
		if index then raidTargets[index] = id end
	end
end

-- Check raid targets on all addressable units
local function CheckRaidTargets()
	doUpdate = true
	for _, unit in pairs(units) do CheckRaidTarget(unit) end -- first check primary units
	if IsInRaid() then
		for i = 1, GetNumGroupMembers() do CheckRaidTarget("raid"..i); CheckRaidTarget("raidpet"..i); CheckRaidTarget("raid"..i.."target") end
	else
		for i = 1, GetNumGroupMembers() do CheckRaidTarget("party"..i); CheckRaidTarget("partypet"..i); CheckRaidTarget("party"..i.."target") end
	end
end

-- Check raid target on mouseover unit
local function CheckMouseoverRaidTarget() CheckRaidTarget("mouseover"); CheckRaidTarget("mouseovertarget"); doUpdate = true end

-- Return the raid target index for a GUID
function MOD:GetRaidTarget(id) for k, v in pairs(raidTargets) do if v == id then return k end end return nil end

-- Event called when addon is enabled
function MOD:OnEnable()
	MOD:InitializeProfile() -- initialize the profile database
	MOD:InitializeLDB() -- initialize the data broker
	MOD:RegisterChatCommand("raven", function() MOD:OptionsPanel() end)
	Nest_Initialize() -- initialize the graphics module

	-- Create a frame so that updates can be registered
	MOD.frame = CreateFrame('Frame')
	-- Set frame level high so visible above other addons
	MOD.frame:SetFrameLevel(MOD.frame:GetFrameLevel() + 8)
	-- Register the update method
	MOD.frame:SetScript('OnUpdate', function(self, elapsed) MOD:Update(elapsed) end)
	-- Register events called prior to starting play
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UNIT_AURA")
	self:RegisterEvent("UNIT_POWER")
	self:RegisterEvent("UNIT_PET")
	self:RegisterEvent("UNIT_TARGET")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_TALENT_UPDATE")
	self:RegisterEvent("SPELLS_CHANGED")
	self:RegisterEvent("VEHICLE_UPDATE")
	self:RegisterEvent("RAID_TARGET_UPDATE", CheckRaidTargets)
	self:RegisterEvent("UPDATE_MOUSEOVER_UNIT", CheckMouseoverRaidTarget)
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", TriggerPlayerUpdate)
	self:RegisterEvent("MINIMAP_UPDATE_TRACKING", TriggerPlayerUpdate)	
	self:RegisterEvent("SPELL_UPDATE_COOLDOWN", TriggerCooldownUpdate)
	self:RegisterEvent("UNIT_INVENTORY_CHANGED", TriggerCooldownUpdate)
	self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN", TriggerCooldownUpdate)
	self:RegisterEvent("BAG_UPDATE_COOLDOWN", TriggerCooldownUpdate)
	self:RegisterEvent("PET_BAR_UPDATE_COOLDOWN", TriggerCooldownUpdate)
	self:RegisterEvent("ACTIONBAR_SLOT_CHANGED", TriggerActionsUpdate)
	self:RegisterEvent("ACTIONBAR_PAGE_CHANGED", TriggerActionsUpdate)
	self:RegisterEvent("RUNE_POWER_UPDATE", TriggerCooldownUpdate)
	self:RegisterEvent("RUNE_TYPE_UPDATE", TriggerCooldownUpdate)
	self:RegisterEvent("PLAYER_TOTEM_UPDATE", TriggerPlayerUpdate)
	self:RegisterEvent("UNIT_SPELLCAST_START", CheckGCD)
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", CheckSpellCasts)
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", CombatLogTracker)
	self:RegisterEvent("GLYPH_ADDED", TriggerGlyphUpdate)
	self:RegisterEvent("GLYPH_UPDATED", TriggerGlyphUpdate)
	MOD:InitializeBars() -- initialize routine that manages the bar library
	MOD:InitializeSounds() -- add sounds to LibSharedMedia
	MOD.LibBossIDs = LibStub("LibBossIDs-1.0", true)
	MOD.db.global.Version = "6" -- version number for database validation
end

-- Event called when addon is disabled but this is probably never called
function MOD:OnDisable() end

-- Initialize rune information for Death Knights
local function InitializeRunes()
	local r, t = MOD.runeIcons, MOD.runeTypes
	r[1] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Blood" -- add DK rune info to cache
	r[2] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Unholy"
	r[3] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Frost"
	r[4] = "Interface\\PlayerFrame\\UI-PlayerFrame-Deathknight-Death"
	t[1] = L["Blood Rune"]; t[2] = L["Unholy Rune"]; t[3] = L["Frost Rune"]; t[4] = L["Death Rune"]
	for i = 1, 4 do MOD:SetIcon(t[i], r[i]) end
end

-- Cache icons for special purposes such as shared cooldowns
local function InitializeIcons()
	local _
	_, _, iconGCD = GetSpellInfo(28730) -- cached for global cooldown (using same icon as Arcane Torrent)
	iconPotion = GetItemIcon(31677) -- icon for shared potions cooldown
	iconElixir = GetItemIcon(28104) -- icon for shared elixirs cooldown
end

-- Set up table of shaman weapon enchants
local function InitializeShamanEnchants()
	if MOD.myClass == "SHAMAN" then
		shamanEnchants = { LSPELL["Earthliving Weapon"], LSPELL["Flametongue Weapon"], LSPELL["Frostbrand Weapon"],
			LSPELL["Rockbiter Weapon"], LSPELL["Windfury Weapon"] }
	end
end

-- Set up table of mage fire spells that can be spread by Impact procs
local function InitialzeFireSpells()
	if MOD.myClass == "MAGE" then
		fireSpells = { LSPELL["Combustion"], LSPELL["Ignite"], LSPELL["Pyroblast"], LSPELL["Living Bomb"] }
	end
end

-- Initialize when play starts, deferred to allow system initialization to complete
function MOD:PLAYER_ENTERING_WORLD()
	if not enteredWorld then
		for _, k in pairs(units) do unitUpdate[k] = true; activeBuffs[k] = {}; activeDebuffs[k] = {}; cacheBuffs[k] = {}; cacheDebuffs[k] = {}  end -- track auras
		updateCooldowns = true -- start tracking cooldowns
		MOD:InitializeHighlights() -- initialize routine that does action bar highlighting
		MOD:InitializeBuffTooltip() -- initialize tooltip used to monitor weapon buffs
		MOD:InitializeConditions() -- initialize routine that shows cooldown overlays and cooldown bars	
		InitializeRunes() -- death knight specific initialization
		InitializeIcons() -- cache special purpose icons
		InitializeShamanEnchants() -- cache names of shaman weapon enchants
		InitialzeFireSpells() -- cache names of mage fire spells
		MOD:InitializeOverlays() -- initialize overlays used to cancel player buffs
		MOD:InitializeInCombatBar() -- initialize special bar for cancelling buffs in combat
		MOD:UpdateAllBarGroups() -- final update before starting event-based updates
		enteredWorld = true; doUpdate = true
	end
	collectgarbage("collect") -- recover deleted preset data
end

-- Event called when an aura changes on a unit, returns the unit name
function MOD:UNIT_AURA(e, unit) if unit and (unitUpdate[unit] ~= nil) then unitUpdate[unit] = true; doUpdate = true end end

-- Event called when a unit's power changes
function MOD:UNIT_POWER(e, unit) if unit == "player" then unitUpdate[unit] = true; doUpdate = true end end

-- Event for when vehicle info changes
function MOD:VEHICLE_UPDATE() TriggerCooldownUpdate(); TriggerPlayerUpdate() end

-- Event called with a unit's target changes
function MOD:UNIT_TARGET(e, unit)
	if unit == "player" then
		unitUpdate.target = true; doUpdate = true
	elseif unit == "target" then
		unitUpdate.targettarget = true; doUpdate = true
	elseif unit == "focus" then
		unitUpdate.focustarget = true; doUpdate = true
	elseif unit == "pet" then
		unitUpdate.pettarget = true; doUpdate = true
	end
end

-- Event called when the player changes talents
function MOD:PLAYER_TALENT_UPDATE() talentsInitialized = false; unitUpdate.player = true; doUpdate = true end

-- Event called when a pet changes
function MOD:UNIT_PET() unitUpdate.pet = true; unitUpdate.pettarget = true; doUpdate = true end

-- Event called when the focus is changed
function MOD:PLAYER_FOCUS_CHANGED() unitUpdate.focus = true; unitUpdate.focustarget = true; doUpdate = true; forceUpdate = true end

-- Event called when the player's target is changed
function MOD:PLAYER_TARGET_CHANGED() unitUpdate.target = true; unitUpdate.targettarget = true; doUpdate = true; forceUpdate = true end

-- Event called when spells in spell book change
function MOD:SPELLS_CHANGED() MOD:SetIconDefaults(); MOD:SetCooldownDefaults(); updateCooldowns = true; doUpdate = true end

-- Create cache of talent info
local function InitializeTalents()	
	local tabs = GetNumSpecializations(false, false)
	if tabs == 0 then return end

	local currentSpec = GetSpecialization()
	MOD.talentSpec = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "None"
	
	talentsInitialized = true; doUpdate = true
	table.wipe(MOD.talents); table.wipe(MOD.talentList)
	
	local ts = GetNumTalents(currentSpec)
	local select = 1
	for i = 1, ts do
		local name, texture, tier, _, selected = GetTalentInfo(i) -- player's active talents
		if name then
			MOD.talents[name] = { tab = currentSpec, index = i, tier = tier, icon = texture, active = selected }
			MOD.talentList[select] = name
			select = select + 1
		end
	end

	table.sort(MOD.talentList)
	for i, t in pairs(MOD.talentList) do
		MOD.talents[t].select = i
	end
	MOD.updateDispels = true
end

-- Initialize cache of glyph info
local function InitializeGlyphs()
	table.wipe(MOD.knownGlyphs)
	table.wipe(MOD.activeGlyphs)
	local count = GetNumGlyphs()
	for index = 1, count do
		local name, _, isKnown, _, castSpell = GetGlyphInfo(index)
		if isKnown then MOD.knownGlyphs[name] = castSpell end
	end
	for slot = 1, NUM_GLYPH_SLOTS do
		local enabled, _, _, spell, _, glyphSpell = GetGlyphSocketInfo(slot)
		if enabled and spell then
			for name, castSpell in pairs(MOD.knownGlyphs) do if glyphSpell == castSpell then MOD.activeGlyphs[name] = slot break end end
		end
	end
end

-- Check if the options panel is loaded, if not then get it loaded and ask it to toggle open/close status
function MOD:OptionsPanel()
    if not optionsLoaded then
        optionsLoaded = true
        local loaded, reason = LoadAddOn(MOD_Options)
        if not loaded then
            print(L["Failed to load "] .. tostring(MOD_Options) .. ": " .. tostring(reason))
			optionsFailed = true
        end
	end
	if not optionsFailed then MOD:ToggleOptions() end
end

-- If the options panel is loaded then update it so it reflects any changes made thru anchors, etc.
function MOD:UpdateOptionsPanel()
	if optionsLoaded and not optionsFailed and not IsMouseButtonDown("LeftButton") then MOD:UpdateOptions(); MOD.updateOptions = false end
	doUpdate = true
end

-- Tie into LibDataBroker
function MOD:InitializeLDB()
	local LDB = LibStub("LibDataBroker-1.1", true)
	if not LDB then return end
	MOD.ldb = LDB:NewDataObject("Raven", {
		type = "launcher",
		text = "Raven",
		icon = "Interface\\Icons\\Spell_Nature_RavenForm",
		-- icon = [[Interface\AddOns\Raven\Raven]],
		OnClick = function(_, msg)
			if msg == "RightButton" then
				if IsShiftKeyDown() then
					MOD.db.profile.hideBlizz = not MOD.db.profile.hideBlizz
					MOD.db.profile.hideConsolidated = MOD.db.profile.hideBlizz
				else
					MOD:ToggleBarGroupLocks()
				end
			elseif msg == "LeftButton" then
				if IsShiftKeyDown() then
					MOD.db.profile.enabled = not MOD.db.profile.enabled
				else
					MOD:OptionsPanel()
				end
			end
			doUpdate = true
		end,
		OnTooltipShow = function(tooltip)
			if not tooltip or not tooltip.AddLine then return end
			tooltip:AddLine(L["Raven"])
			tooltip:AddLine(L["Raven left click"])
			tooltip:AddLine(L["Raven right click"])
			tooltip:AddLine(L["Raven shift left click"])
			tooltip:AddLine(L["Raven shift right click"])
		end,
	})
	MOD.ldbi = LibStub("LibDBIcon-1.0", true)
	if MOD.ldbi then MOD.ldbi:Register("Raven", MOD.ldb, MOD.db.global.Minimap) end
end

-- Show or hide the blizzard buff frames, called during update so synched with other changes
local function CheckBlizzFrames()
	local visible = BuffFrame:IsShown()
	if MOD.db.profile.hideBlizz then
		if visible then BuffFrame:Hide(); TemporaryEnchantFrame:Hide(); BuffFrame:UnregisterAllEvents() end
	else
		if not visible then BuffFrame:Show(); TemporaryEnchantFrame:Show(); BuffFrame:RegisterEvent("UNIT_AURA") end
	end
	visible = ConsolidatedBuffs:IsShown()
	if MOD.db.profile.hideConsolidated or (GetNumGroupMembers() == 0) then -- make sure hide when solo
		if visible then ConsolidatedBuffs:Hide() end
--	else
--		if not visible then if GetCVarBool("consolidateBuffs") then ConsolidatedBuffs:Show() end end
	elseif GetCVarBool("consolidateBuffs") then
		if not visible then ConsolidatedBuffs:Show() end
		RaidBuffTray_Update()
	end
	visible = RuneFrame:IsShown()
	if MOD.db.profile.hideRunes then
		if visible then RuneFrame:UnregisterAllEvents(); RuneFrame:Hide() end
	else
		if not visible then 
			if MOD.myClass == "DEATHKNIGHT" then RuneFrame:Show() end
			RuneFrame:GetScript("OnLoad")(RuneFrame); RuneFrame:GetScript("OnEvent")(RuneFrame, "PLAYER_ENTERING_WORLD")
		end
	end
end

-- Check for update requirements that are not triggered by events
local function CheckMiscellaneousUpdates()
	if MOD:ChangedTotems() then updateCooldowns = true; unitUpdate.player = true; doUpdate = true; forceUpdate = true end
	if IsPossessBarVisible() or UnitHasVehicleUI("player") then updateCooldowns = true; unitUpdate.player = true; doUpdate = true end
end

-- Update routine called before each frame is displayed, throttled to minimize CPU usage
function MOD:Update(elapsed)
	CheckBlizzFrames() -- make sure blizzard frames are visible or not
	if MOD.db.profile.enabled then
		elapsedTime = elapsedTime + elapsed; refreshTime = refreshTime + elapsed
		if updateGlyphs then InitializeGlyphs(); updateGlyphs = false end
		if forceUpdate or (elapsedTime >= throttleTime) then
			forceUpdate = false; throttleCount = throttleCount + 1; if throttleCount == 5 then throttleCount = 0 end
			if not talentsInitialized then InitializeTalents() end -- retry until talents initialized
			CheckMiscellaneousUpdates() -- check for update requirements that don't have events
			MOD:UpdateInternalCooldowns() -- check for expiring internal cooldowns
			MOD:UpdateCooldownTimes() -- check for expiring normal cooldowns
			if doUpdate or throttleCount == 0 or MOD:CheckTimeEvents() then -- only do major updates when events warrant it (or about once a second)
				MOD:UpdateSpellEffects() -- update spell effect timers
				MOD:UpdateAuras() -- update table containing current auras (actual processing is deferred until needed)
				MOD:UpdateTrackers() -- update aura trackers for multiple targets
				MOD:UpdateCooldowns() -- update table containing current cooldowns on action bar buttons and trinkets
				MOD:UpdateConditions() -- update table containing currently triggered conditions
				MOD:UpdateHighlights() -- update action bar buttons with highlights and cooldown text
				Nest_CheckDisplayDimensions() -- check display dimensions and update anchors if they have changed
				MOD:UpdateBars() -- update timer bars for auras and cooldowns
				MOD:UpdateInCombatBar() -- update the in-combat bar if necessary
				Nest_Update() -- update the display using the Nest graphics package
			else
				MOD:RefreshInCombatBar() -- update in-combat bar animations only
				Nest_Refresh() -- refresh bars in the Nest graphics package (helps smooth animations)
			end
			elapsedTime = 0; refreshTime = 0; doUpdate = false
			if (throttleCount == 0) and MOD.updateOptions then MOD:UpdateOptionsPanel() end -- update option panel once per second, if requested	
		elseif refreshTime >= refreshThrottle then -- limit animation refesh to about 30 times per second
			MOD:RefreshInCombatBar() -- update in-combat bar animations only
			Nest_Refresh() -- refresh bars in the Nest graphics package (helps smooth animations)
			refreshTime = 0
		end
	else
		MOD:HideHighlights()
		MOD:HideBars()
		MOD:HideInCombatBar()
	end
end

-- Aura tables have this structure:
-- b[1] = isBuff, b[2] = timeLeft, b[3] = stackCount, b[4] = auraType, b[5] = duration, b[6] = caster, b[7] = isStealable/effectCaster, b[8] = icon,
-- b[9] = rank, b[10] = expireTime, b[11] = tooltipType, b[12] = tooltipArgument, b[13] = name, b[14] = spellID, b[15] = isBoss, b[16] = casterName,
-- b[17] = castable, b[18] = casterIsNPC, b[19] = casterVehicle

-- Calculate aura time left from expiration time and current time, this is always done before returning aura descriptors
-- If no duration or has expired then set to 0 (Blizzard may not yet have sent aura update event so could sit at 0 for a moment)
local function SetAuraTimeLeft(b) if b[5] > 0 then b[2] = b[10] - GetTime() if b[2] < 0 then b[2] = 0 end else b[2] = 0 end end
	
-- Add an active aura to the table for the specified unit
local function AddAura(unit, name, isBuff, spellID, count, btype, duration, caster, steal, boss, apply, icon, rank, expire, tt_type, tt_arg)
	local auraTable = isBuff and activeBuffs[unit] or activeDebuffs[unit]
	local auraCache = isBuff and cacheBuffs[unit] or cacheDebuffs[unit]
	if auraTable then
		local b = AllocateTable() -- get an empty aura descriptor
		local cname, isNPC, vehicle = nil, nil, nil
		if caster then
			local guid = UnitGUID(caster); cname = UnitName(caster); vehicle = UnitHasVehicleUI(caster)
			if guid then
				local first3 = tonumber("0x" .. strsub(guid, 3,5)); local unitType = bit.band(first3,0x00f)
				isNPC = (unitType == 0x003); vehicle = vehicle or (unitType == 0x005)
				if MOD.LibBossIDs and MOD.LibBossIDs.BossIDs[tonumber(guid:sub(-13, -9), 16)] then boss = 1 end
			end
		end
		b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9], b[10], b[11], b[12], b[13], b[14], b[15], b[16], b[17], b[18], b[19] =
			isBuff, 0, count, btype, duration, caster, steal, icon, rank, expire, tt_type, tt_arg, name, spellID, boss, cname, apply, isNPC, vehicle
		auraTable[#auraTable + 1] = b
		if auraCache then auraCache[name] = true end
		MOD:SetIcon(name, icon) --  cache icon for this aura
	end
end

-- Empty the aura tables for a unit by releasing all entries (except weapon buffs)
local function ReleaseAuras(unit)
	local buffTable, debuffTable, buffCache, debuffCache = activeBuffs[unit], activeDebuffs[unit], cacheBuffs[unit], cacheDebuffs[unit]
	table.wipe(buffCache); table.wipe(debuffCache)
	if buffTable then for index, b in pairs(buffTable) do if b[11] ~= "weapon" then buffTable[index] = ReleaseTable(b) else buffCache[b[13]] = true end end end
	if debuffTable then for index, b in pairs(debuffTable) do debuffTable[index] = ReleaseTable(b) end end
end

-- Check if aura(s) with given name are active on the unit (if isBuff is true only check buffs, otherwise only debuff)
-- Return a table with matching aura descriptors, potentially empty if none are found
-- The returned table is only valid until the next call to MOD:CheckAura since it is reused each time
function MOD:CheckAura(unit, name, isBuff)
	table.wipe(matchTable)
	unit = MOD:UnitStatusUpdate(unit)
	if unit then
		local auraTable = isBuff and activeBuffs[unit] or activeDebuffs[unit]
		local auraCache = isBuff and cacheBuffs[unit] or cacheDebuffs[unit]
		if auraTable then
			if auraCache and auraCache[name] then
				for _, b in pairs(auraTable) do if b[13] == name then SetAuraTimeLeft(b); matchTable[#matchTable + 1] = b end end
			elseif string.find(name, "^#%d+") then -- check if name is in special format for specific spell id (i.e., #12345)
				local id = tonumber(string.sub(name, 2)) -- extract the spell id
				if id then for _, b in pairs(auraTable) do if b[14] == id then SetAuraTimeLeft(b); matchTable[#matchTable + 1] = b end end end			
			end
		end
	end
	return matchTable
end

-- For all active auras on a given unit (if isBuff is true only buffs, otherwise only debuff), call the function that
-- is passed in with the unit, aura name, aura descriptor table, isBuff, and two optional parameters passed in
function MOD:IterateAuras(unit, func, isBuff, p1, p2, p3)
	local auraTable
	if unit == "all" then -- special case to get auras cast by player on multiple targets
		auraTable = isBuff and unitBuffs or unitDebuffs
		for id, tracker in pairs(auraTable) do
			for k, t in pairs(tracker) do
				SetAuraTimeLeft(t) -- update timeLeft from current time
				func(unit, t[13], t, isBuff, p1, p2, p3)
			end
		end
	else
		unit = MOD:UnitStatusUpdate(unit)
		if unit then
			auraTable = isBuff and activeBuffs[unit] or activeDebuffs[unit]
			if auraTable then
				for _, b in pairs(auraTable) do
					SetAuraTimeLeft(b) -- update timeLeft from current time
					func(unit, b[13], b, isBuff, p1, p2, p3)
				end
			end
		end
	end
end

-- Release a particular player buff, including multiple copies, used for weapon buffs and tracking due to non-standard detection
local function ReleasePlayerBuff(name)
	local auraTable = activeBuffs.player
	if auraTable then
		for index, b in pairs(auraTable) do if b[13] == name then auraTable[index] = ReleaseTable(b) end end
	end
end

-- Check all buffs on the unit to see if the specified buff type is currently active, return true and the first found
function MOD:UnitHasBuff(unit, btype)
	unit = MOD:UnitStatusUpdate(unit)
	if unit then
		local auraTable = activeBuffs[unit]
		if auraTable then
			for _, b in pairs(auraTable) do if (btype == "Steal") and (b[7] == 1) or (b[4] == btype) then SetAuraTimeLeft(b); return true, b end end
		end
	end
	return false, nil
end

-- Check all debuffs on the unit to see if the specified debuff type is currently active, return true and the first found
function MOD:UnitHasDebuff(unit, btype)
	unit = MOD:UnitStatusUpdate(unit)
	if unit then
		local auraTable = activeDebuffs[unit]
		if auraTable then
			for _, b in pairs(activeDebuffs[unit]) do if (b[4] == btype) then SetAuraTimeLeft(b); return true, b end end
		end
	end
	return false, nil
end

-- Initialize tooltip to be used for determining weapon buffs
-- This code is based on the Pitbull implementation
function MOD:InitializeBuffTooltip()
	bufftooltip = CreateFrame("GameTooltip", nil, UIParent)
	bufftooltip:SetOwner(UIParent, "ANCHOR_NONE")
	local fs = bufftooltip:CreateFontString()
	fs:SetFontObject(_G.GameFontNormal)
	bufftooltip.tooltiplines = {} -- cache of font strings for each line in the tooltip
	for i = 1, 30 do
		local ls = bufftooltip:CreateFontString()
		ls:SetFontObject(_G.GameFontNormal)
		bufftooltip:AddFontStrings(ls, fs)
		bufftooltip.tooltiplines[i] = ls
	end
end

-- Return the temporary table for storing buff tooltips
function MOD:GetBuffTooltip()
	bufftooltip:ClearLines()
	if not bufftooltip:IsOwned(UIParent) then bufftooltip:SetOwner(UIParent, "ANCHOR_NONE") end
	return bufftooltip
end

-- No easy way to get this info, so scan item slot info for mainhand and offhand weapons using a tooltip
-- Weapon buffs are usually formatted in tooltips as name strings followed by remaining time in parentheses
-- This routine scans the tooltip for the first line that is in this format and extracts the weapon buff name without rank or time
local function GetWeaponBuffName(weaponSlot)
	local tt = MOD:GetBuffTooltip()
	tt:SetInventoryItem("player", weaponSlot)
	for i = 1, 30 do
		local text = tt.tooltiplines[i]:GetText()
		if text then
			local name = text:match("^(.+) %(%d+ [^$)]+%)$") -- extract up to left paren if match weapon buff format
			if name then
				name = (name:match("^(.*) %d+$")) or name -- remove any trailing numbers
				if shamanEnchants then -- special case for localing shaman weapon enhancements
					for _, enchant in pairs(shamanEnchants) do if string.find(enchant, name) then name = enchant; break end end
				end
				return name
			end
		else
			break
		end
	end
	return nil
end

-- Get weapon buff duration, since this is not supplied by Blizzard look at current detected duration
-- and compare it to longest previous duration for the given weapon buff in order to find maximum ever detected
local function GetWeaponBuffDuration(buff, duration)
	local maxd = MOD.db.profile.WeaponBuffDurations[buff]
	if not maxd then maxd = MOD.db.global.BuffDurations[buff] end -- backward compatibility
	if not maxd or (duration > maxd) then
		MOD.db.profile.WeaponBuffDurations[buff] = math.floor(duration + 0.5) -- round up
	else
		if maxd > duration then duration = maxd end
	end
	return duration
end

-- Reset the weapon buff duration cache since it will be restored when buff is cast again
local function ResetWeaponBuffDuration(buff) MOD.db.profile.WeaponBuffDurations[buff] = nil; MOD.db.global.BuffDurations[buff] = nil end

-- Add player weapon buffs for mainhand and offhand to the aura table 
local function GetWeaponBuffs()
	-- old weapons buffs are now out-of-date so release them before regenerating		
	if mhLastBuff then ReleasePlayerBuff(mhLastBuff) end
	if ohLastBuff then ReleasePlayerBuff(ohLastBuff) end 
	
	-- first check if there are weapon auras then, only if necessary, use tooltip to scan for the buff names
	local mh, mhms, mhc, oh, ohms, ohc = GetWeaponEnchantInfo()
	if mh then -- add the mainhand buff, if any, to the table
		local islot = GetInventorySlotInfo("MainHandSlot")
		local mhbuff = GetWeaponBuffName(islot)
		if not mhbuff then -- if tooltip scan fails then use fallback of weapon name or slot name
			local weaponLink = GetInventoryItemLink("player", islot)
			if weaponLink then mhbuff = GetItemInfo(weaponLink) end
			if not mhbuff then mhbuff = L["Mainhand Weapon"] end
		end
		local icon = GetInventoryItemTexture("player", islot)					
		local timeLeft = mhms / 1000
		local expire = GetTime() + timeLeft
		local duration = GetWeaponBuffDuration(mhbuff, timeLeft)
		AddAura("player", mhbuff, true, nil, mhc, "Mainhand", duration, "player", nil, nil, 1, icon, nil, expire, "weapon", "MainHandSlot")
		mhLastBuff = mhbuff -- caches the name of the weapon buff so can clear it later
	elseif mhLastBuff then ResetWeaponBuffDuration(mhLastBuff); mhLastBuff = nil end
	
	if oh then -- add the offhand buff, if any, to the table
		local islot = GetInventorySlotInfo("SecondaryHandSlot")
		local ohbuff = GetWeaponBuffName(islot)
		if not ohbuff then -- if tooltip scan fails then use fallback of weapon name or slot name
			local weaponLink = GetInventoryItemLink("player", islot)
			if weaponLink then ohbuff = GetItemInfo(weaponLink) end
			if not ohbuff then ohbuff = L["Offhand Weapon"] end
		end
		local icon = GetInventoryItemTexture("player", islot)
		local timeLeft = ohms / 1000
		local expire = GetTime() + timeLeft
		local duration = GetWeaponBuffDuration(ohbuff, timeLeft)
		AddAura("player", ohbuff, true, nil, ohc, "Offhand", duration, "player", nil, nil, 1, icon, nil, expire, "weapon", "SecondaryHandSlot")
		ohLastBuff = ohbuff -- caches the name of the weapon buff so can clear it later
	elseif ohLastBuff then ResetWeaponBuffDuration(ohLastBuff); ohLastBuff = nil end
end

-- See if totems have changed since last update, can't count on events, and save for future checks
function MOD:ChangedTotems()
	local changed = false
	if MOD.myClass == "SHAMAN" then
		for i = 1, 4 do local _, name = GetTotemInfo(i); if lastTotems[i] ~= name then lastTotems[i] = name; changed = true end end
	end
	return changed
end

-- Add buffs for the specified unit to the active buffs table
local function GetBuffs(unit)
	local name, rank, icon, count, btype, duration, expire, caster, isStealable, _, spellID, apply, boss
	local i = 1
	repeat
		name, rank, icon, count, btype, duration, expire, caster, isStealable, _, spellID, apply, boss = UnitAura(unit, i, "HELPFUL")
		if name then
			if not caster then if spellID and fixEnchants[spellID] then caster = "player" else caster = "unknown" end -- fix Jade Spirit, Dancing Steel, River's Song
			elseif caster == "vehicle" then caster = "player" end -- vehicle buffs treated like player buffs
			if caster == "player" then MOD:SetDuration(name, duration) end
			AddAura(unit, name, true, spellID, count, btype, duration, caster, isStealable, boss, apply, icon, rank, expire, "buff", i)
		end
		i = i + 1
	until not name
	if unit ~= "player" then return end -- done for all but player, players also need to add vehicle buffs
	i = 1
	repeat
		name, rank, icon, count, btype, duration, expire, caster, isStealable, _, spellID, apply, boss = UnitAura("vehicle", i, "HELPFUL")
		if name then
			if not caster then caster = "unknown" elseif caster == "vehicle" then caster = "player" end -- vehicle buffs treated like player buffs
			if caster == "player" then MOD:SetDuration(name, duration) end
			AddAura(unit, name, true, spellID, count, btype, duration, caster, isStealable, boss, apply, icon, rank, expire, "vehicle buff", i)
		end
		i = i + 1
	until not name
end

-- Add debuffs for the specified unit to the active debuffs table
local function GetDebuffs(unit)
	local name, rank, icon, count, btype, duration, expire, caster, isStealable, _, spellID, apply, boss
	local i = 1
	repeat
		name, rank, icon, count, btype, duration, expire, caster, isStealable, _, spellID, apply, boss = UnitAura(unit, i, "HARMFUL")
		if name then
			if not caster then caster = "unknown" elseif caster == "vehicle" then caster = "player" end -- vehicle debuffs treated like player debuffs
			if caster == "player" then MOD:SetDuration(name, duration) end
			AddAura(unit, name, false, spellID, count, btype, duration, caster, isStealable, boss, apply, icon, rank, expire, "debuff", i)
		end
		i = i + 1
	until not name
	if unit ~= "player" then return end -- done for all but player, players also need to add vehicle debuffs
	i = 1
	repeat
		name, rank, icon, count, btype, duration, expire, caster, isStealable, _, spellID, apply, boss = UnitAura("vehicle", i, "HARMFUL")
		if name then
			if not caster then caster = "unknown" elseif caster == "vehicle" then caster = "player" end -- vehicle debuffs treated like player debuffs
			if caster == "player" then MOD:SetDuration(name, duration) end
			AddAura(unit, name, false, spellID, count, btype, duration, caster, isStealable, boss, apply, icon, rank, expire, "vehicle debuff", i)
		end
		i = i + 1
	until not name
end

-- Add tracking auras (updated for Cataclysm which allows multiple active tracking types)
local function GetTracking()
	local notTracking, notTrackingIcon, found = L["Not Tracking"], "Interface\\Minimap\\Tracking\\None", false
	for i = 1, GetNumTrackingTypes() do
		local tracking, trackingIcon, active = GetTrackingInfo(i)
		if active == 1 then
			found = true
			AddAura("player", tracking, true, nil, 1, "Tracking", 0, "player", nil, nil, nil, trackingIcon, nil, 0, "tracking", tracking)
		end
	end
	if not found then
		AddAura("player", notTracking, true, nil, 1, "Tracking", 0, "player", nil, nil, nil, notTrackingIcon, nil, 0, "tracking", notTracking)
	end
end

-- Check if the spell triggers a spell effect
function MOD:DetectSpellEffect(name, caster)
	local ect = MOD.db.global.SpellEffects[name] -- check for new spell effect triggered by this spell	
	if ect and not ect.disable and MOD:CheckCastBy(caster, ect.caster or "player") then
		local duration = ect.duration
		if ect.talent and not RavenCheckTalent(ect.talent) then return end -- check required talent
		if ect.buff then local auraList = MOD:CheckAura("player", ect.buff, true); if #auraList == 0 then return end end -- check required buff
		if ect.optbuff then local auraList = MOD:CheckAura("player", ect.optbuff, true); if #auraList > 0 then duration = ect.optduration end end -- check optional buff
		if ect.condition and not MOD:CheckCondition(ect.condition) then return end -- check required condition
		local ec = spellEffects[name]
		if ec and ect.renew then spellEffects[name] = ReleaseTable(ec); ec = nil end -- check if already active spell effect and optionally renew
		if not ec then ec = AllocateTable(); ec.start = GetTime(); ec.expire = ec.start + duration; ec.caster = caster;
			spellEffects[name] = ec; TriggerPlayerUpdate() end
	end
end

-- Remove any spell effect entries that have expired
function MOD:UpdateSpellEffects()
	local now = GetTime()
	for id, ec in pairs(spellEffects) do if now >= ec.expire then spellEffects[id] = ReleaseTable(ec); TriggerPlayerUpdate(); TriggerCooldownUpdate() end end
end

-- Check if any spell effects are active and add them to the player auras
local function GetSpellEffectAuras()
	for name, ec in pairs(spellEffects) do
		local ect = MOD.db.global.SpellEffects[name]
		if ect and not ect.disable and ect.kind ~= "cooldown" then
			local spell = ect.spell or name
			AddAura("player", spell, not ect.kind, ect.id, 1, nil, ect.duration, ec.caster, UnitName(ec.caster), nil, nil, ect.icon, nil, ec.expire, "effect", name)
		end
	end
end

-- Create an aura for current stance for warriors and paladins
local function GetStanceAura()
	if MOD.myClass == "WARRIOR" or MOD.myClass == "PALADIN" or MOD.myClass == "MONK" then
		local stance = GetShapeshiftForm()
		if stance and stance > 0 then
			local _, name = GetShapeshiftFormInfo(stance)
			if name then
				local icon = GetSpellTexture(name)
				local link = GetSpellLink(name)
				AddAura("player", name, true, nil, 1, "Stance", 0, "player", nil, nil, nil, icon, nil, 0, "spell link", link)
			end
		end
	end
end

-- Create an aura for class-specific power buffs: soul shards, holy power, shadow orbs
local function GetPowerBuffs()
	local power, id = nil, nil
	if MOD.myClass == "PALADIN" then power = UnitPower("player", SPELL_POWER_HOLY_POWER); id = 85247
	elseif MOD.myClass == "PRIEST" then power = UnitPower("player", SPELL_POWER_SHADOW_ORBS); id = 95740
	elseif MOD.myClass == "MONK" then power = UnitPower("player", SPELL_POWER_CHI); id = 97272
	elseif MOD.myClass == "WARLOCK" then
		if IsSpellKnown(108647) then
			power = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true); id = 108647
		elseif IsSpellKnown(1120) then
			power = UnitPower("player", SPELL_POWER_SOUL_SHARDS); id = 117198
		elseif IsSpellKnown(104315) then
			power = UnitPower("player", SPELL_POWER_DEMONIC_FURY); id = 104315
		end
	end
	if power and power > 0 then
		local name, _, icon = GetSpellInfo(id)
		local link = GetSpellLink(id)
		if name then
			AddAura("player", name, true, id, power, "Power", 0, "player", nil, nil, nil, icon, nil, 0, "spell link", link)
		end
	end
end

-- Update unit auras if necessary (deferred until requested)
function MOD:UnitStatusUpdate(unit)
	local status = unitStatus[unit]
	if status ~= 0 then
		if status ~= 1 then unit = status end
		if unitUpdate[unit] then -- need to do an update for this unit
			ReleaseAuras(unit); GetBuffs(unit); GetDebuffs(unit)
			if unit == "player" then GetTracking(); GetSpellEffectAuras(); GetStanceAura(); GetPowerBuffs() end
			unitUpdate[unit] = false
		end
		return unit
	end
	return nil
end

-- Check unit status, return 0 if doesn't exist, 1 if valid unit, "unit" if mirroring another unit
function MOD:ValidateUnit(unit)
	if UnitExists(unit) then
		for _, k in pairs(units) do
			if unit == k then return 1 end -- found unique unit
			if UnitIsUnit(unit, k) then return k end -- found match to higher priority unit
		end
	end
	return 0 -- not a valid unit
end

-- Check all the tracker entries and remove any that have expired
function MOD:UpdateTrackers()
	for id, tracker in pairs(unitBuffs) do
		for k, t in pairs(tracker) do SetAuraTimeLeft(t); if (t[5] > 0) and (t[2] == 0) then tracker[k] = ReleaseTable(t) end end
	end
	for id, tracker in pairs(unitDebuffs) do
		for k, t in pairs(tracker) do SetAuraTimeLeft(t); if (t[5] > 0) and (t[2] == 0) then tracker[k] = ReleaseTable(t) end end
	end
end

-- Update aura table with current player, target and focus auras and debuffs, include player weapon buffs
function MOD:UpdateAuras()
	for _, k in pairs(units) do unitStatus[k] = MOD:ValidateUnit(k)	end	 -- set current unit status, defer actual update until referenced
	for _, k in pairs(eventUnits) do unitUpdate[k] = (unitStatus[k] == 1) end -- can't count on events for these units
	if throttleCount == 0 then -- things to do every second...
		GetWeaponBuffs() -- get current weapon buffs, if any
		RefreshTrackers() -- validate the unit id cache for the trackers
	end
end

-- Cooldown tables have this structure (name of the cooldown is the index into the activeCooldowns table):
-- b[1] = timeLeft, b[2] = icon, b[3] = startTime, b[4] = duration, b[5] = tooltipType, b[6] = tooltipArgument, b[7] = unit, b[8] = id, b[9] = count

-- Check if valid cooldown table, if so then calculate time left from start time and duration and invalidate if cooldown has expired
-- Returns either the updated cooldown table or nil if not valid
local function ValidateCooldown(b) 
	if b[1] ~= nil then
		b[1] = b[3] + b[4] - GetTime() -- calculate timeLeft from start time and duration
		if b[1] > 0 then return b end -- check if the cooldown has expired 
		b[1] = nil -- this cooldown is no longer valid
		updateCooldowns = true; doUpdate = true
	end
	return nil
end

-- Add a cooldown to the current list of active cooldowns, cached info includes icon, start time, duration, tt_type, tt_arg, unit
local function AddCooldown(name, id, icon, start, duration, tt_type, tt_arg, unit, count)
	local t = activeCooldowns -- shared for player and pet cooldowns
	if not t[name] then
		MOD:SetIcon(name, icon) --  cache icon for this spell or item name
		t[name] = { 0, icon, start, duration, tt_type, tt_arg, unit, id, count }
	else
		local b = t[name]
		b[1], b[2], b[3], b[4], b[5], b[6], b[7], b[8], b[9] = 0, icon, start, duration, tt_type, tt_arg, unit, id, count
	end
end

-- Check if the named spell or item is on cooldown, return a cooldown table
function MOD:CheckCooldown(name)
	local b = activeCooldowns[name]
	if b then return ValidateCooldown(b) end
	return nil
end

-- Iterate over current cooldowns, calling the function with cooldown name, cooldown table, and optional parameters
function MOD:IterateCooldowns(func, p1, p2, p3)
	for n, cd in pairs(activeCooldowns) do if ValidateCooldown(cd) then func(n, cd, p1, p2, p3) end end
end

-- Release all spell cooldowns from active cooldowns table by setting first field to nil to indicate not active
local function ReleaseCooldowns() for _, cd in pairs(activeCooldowns) do cd[1] = nil end end

-- Update the expiration time for cooldowns, releasing any that have lapsed
function MOD:UpdateCooldownTimes() for _, b in pairs(activeCooldowns) do ValidateCooldown(b) end end

-- Get cooldown info for an inventory slot
local function CheckInventoryCooldown(slot)
	local id = GetInventorySlotInfo(slot)
	if id then
		local start, duration, enable = GetInventoryItemCooldown("player", id)
		if start and (start > 0) and (enable == 1) and (duration > 1.5) then
			local link = GetInventoryItemLink("player", id)
			if link then
				local spell = GetItemSpell(link)
				local name, _, _, _, _, _, _, _, equipSlot, icon = GetItemInfo(link)
				if spell and equipSlot ~= "INVTYPE_TRINKET" then name = spell end
				if name and icon then AddCooldown(name, id, icon, start, duration, "inventory", slot, "player") end
			end
		end
	end
end

-- Update info about the rune slots and add rune cooldowns
local function CheckRunes()
	local blood, frost, unholy, death = 0, 0, 0, 0
	for i = 1, 6 do
		local rune, rtype = MOD.runeSlots[i], GetRuneType(i)
		local start, duration, ready = GetRuneCooldown(i)
		if not rune then
			rune = { rtype = rtype, start = start, duration = duration, ready = ready }
			MOD.runeSlots[i] = rune
		else
			rune.rtype = rtype; rune.start = start; rune.duration = duration; rune.ready = ready
		end
	end
end

-- Return true only if the specified runes are available, with death runes serving as wildcards
function MOD:IsRuneSpellReady(blood, frost, unholy, any, exdeath)
	local b, f, u, d = 0, 0, 0, 0
	for i = 1, 6 do
		if MOD.runeSlots[i].ready then
			local t = MOD.runeSlots[i].rtype
			if t == 1 then b = b + 1 elseif t == 2 then u = u + 1 elseif t == 3 then f = f + 1 elseif t == 4 then d = d + 1 end
		end
	end
	if exdeath == true then d = 0 end -- option to completely ignore death runes
	if any == true then if (b + f + u + d) == 0 then return false end end -- optional test to see if any runes are available at all
	if blood and (b < 1) then if d < 1 then return false else d = d - 1 end end
	if frost and (f < 1) then if d < 1 then return false else d = d - 1 end end
	if unholy then if u < 1 and d < 1 then return false end end
	return true
end

-- Check each rune type and see if either rune is recharging
function MOD:IsRuneRecharging(checkBlood, chargeBlood, checkFrost, chargeFrost, checkUnholy, chargeUnholy)
	local b = not MOD.runeSlots[1].ready or not MOD.runeSlots[2].ready -- true if blood recharging
	local f = not MOD.runeSlots[5].ready or not MOD.runeSlots[6].ready -- true if frost recharging
	local u = not MOD.runeSlots[3].ready or not MOD.runeSlots[4].ready -- true if unholy recharging
	if checkBlood and (not chargeBlood == b) then return false end
	if checkFrost and (not chargeFrost == f) then return false end
	if checkUnholy and (not chargeUnholy == u) then return false end
	return true
end

-- Check if the spell is on cooldown because a rune is not available, return true only if on real cooldown
local function CheckRuneCooldown(name, duration)
	local runes = MOD.runeSpells[name]
	if runes then
		if MOD:IsRuneSpellReady(runes.blood, runes.frost, runes.unholy, nil, nil) then return true end -- runes are available so real cooldown
		if (duration >= 9) and (duration <= 10) then return false end -- right duration to be a rune cooldown
	end
	return true
end

-- Check if an item is on cooldown
local function CheckItemCooldown(itemID)
	local start, duration = GetItemCooldown(itemID)
	if (start > 0) and (duration > 1.5) then -- don't include global cooldowns or really short cooldowns
		local name, link, _, _, _, itemType, itemSubType, _, _, icon = GetItemInfo(itemID)
		if name then
			local found = false
			if itemType == "Consumable" and (itemID ~= 86569) then -- check for shared cooldowns for potions/elixirs/flasks (special case Crystal of Insanity)
				if itemSubType == "Potion" then
					found = true
					if not MOD:CheckCooldown(L["Potions"]) then
						AddCooldown(L["Potions"], nil, iconPotion, start, duration, "text", L["Shared Potion Cooldown"], "player")
					end
				elseif (itemSubType == "Elixir") or (itemSubType == "Flask") then
					found = true
					if not MOD:CheckCooldown(L["Elixirs"]) then
						AddCooldown(L["Elixirs"], nil, iconElixir, start, duration, "text", L["Shared Elixir Cooldown"], "player")
					end
				end
			end
			if not found then
				AddCooldown(name, itemID, icon, start, duration, "item link", link, "player")
			end
		end
	end
end

-- Check if the aura either triggers or cancels an internal cooldown
-- Internal cooldown table indexed by aura that triggers the cooldown
function MOD:DetectInternalCooldown(name, caster)
	local up = false
	for id, cd in pairs(internalCooldowns) do -- check if cancels any active internal cooldowns
		if cd.cancel then
			for _, aura in pairs(cd.cancel) do if name == aura then internalCooldowns[id] = ReleaseTable(cd); up = true; break end end
		end
	end
	local ict = MOD.db.global.InternalCooldowns[name] -- check for new internal cooldown triggered by this aura
	if ict and not ict.disable and ((ict.caster == true) == caster) and (not ict.class or ict.class == MOD.myClass) and not internalCooldowns[name] then
		local cd = AllocateTable() -- get an empty tracker table
		cd.start = GetTime(); cd.expire = cd.start + ict.duration; cd.cancel = ict.cancel
		internalCooldowns[name] = cd
		up = true
	end
	if up then TriggerCooldownUpdate() end
end

-- Remove any internal cooldown entries that have expired
function MOD:UpdateInternalCooldowns()
	local now = GetTime()
	for name, cd in pairs(internalCooldowns) do if now >= cd.expire then internalCooldowns[name] = ReleaseTable(cd); TriggerCooldownUpdate() end end
end

-- Check for any internal cooldowns that are active
local function CheckInternalCooldowns()
	for name, cd in pairs(internalCooldowns) do
		local ict = MOD.db.global.InternalCooldowns[name]
		if ict and not ict.disable then AddCooldown(name, ict.id, ict.icon, cd.start, ict.duration, "internal", ict.id, "player") end
	end
end

-- Check for any internal cooldowns that are active
local function CheckSpellEffectCooldowns()
	for name, ec in pairs(spellEffects) do
		local ect = MOD.db.global.SpellEffects[name]
		if ect and not ect.disable and ect.kind == "cooldown" then
			local spell = ect.spell or name
			AddCooldown(spell, ect.id, ect.icon, ec.start, ec.expire - ec.start, "effect", name, "player")
		end
	end
end

-- Check for new and expiring cooldowns associated with all action bar slots plus trinkets (might want to add inventory slots someday)
function MOD:UpdateCooldowns()
	if updateCooldowns then
		ReleaseCooldowns() -- mark all cooldowns as not active
		if MOD.myClass == "DEATHKNIGHT" then CheckRunes() end
		local lockedOut = false -- flag set if any lockout spells are found
		for school in pairs(lockouts) do lockouts[school] = 0 end -- clear any previous settings in lockout table
		if UnitLevel("player") >= 10 then -- don't detect lockouts for low-level characters, this allows more options for lockout detection spells
			for name, ls in pairs(MOD.lockSpells) do
				if not lockouts[ls.school] then lockouts[ls.school] = 0 end -- initialize when school seen for first time
				if ls.index and (lockouts[ls.school] == 0) then
					local start, duration = GetSpellCooldown(ls.index, "spell")
					if start and (start > 0) and (duration > 1.5) then -- locked out!
						lockouts[ls.school] = duration; lockstarts[ls.school] = start; lockedOut = true
						AddCooldown(ls.label, nil, iconGCD, start, duration, "spell", ls.text, "player")
					end
				end
			end
		end

		for tab = 1, 2 do -- scan first two tabs of player spell book (general and current spec) for player spells on cooldown
			local _, _, offset, numSpells = GetSpellTabInfo(tab)
			for i = 1, numSpells do
				local index = i + offset
				local stype, id = GetSpellBookItemInfo(index, "spell")
				if stype == "SPELL" then -- use spellbook index to check for cooldown
					local start, duration, enable, count, charges
					count, charges, start, duration = GetSpellCharges(index, "spell")
					if count and charges and count < charges then enable = 1 else start, duration, enable = GetSpellCooldown(index, "spell") end
					if start and (start > 0) and (enable == 1) and (duration > 1.5) then -- don't include global cooldowns
						local name, _, icon = GetSpellInfo(index, "spell")
						if name then -- make sure we have a valid spell name
							if (MOD.myClass ~= "DEATHKNIGHT") or CheckRuneCooldown(name, duration) then -- if death knight check rune cooldown
								local locked = false
								if lockedOut then -- check if this spell is on same cooldown as any lockout spell
									for ls, ld in pairs(lockouts) do if ld == duration and lockstarts[ls] == start then locked = true end end
								end
								if not locked then
									local link = GetSpellLink(index, "spell")
									AddCooldown(name, id, icon, start, duration, "spell link", link, "player", count)
								end
							end
						end
					end
				elseif stype == "FLYOUT" then -- use spell id to check for cooldown
					local _, _, numSlots = GetFlyoutInfo(id)
					for slot = 1, numSlots do
						local spellID = GetFlyoutSlotInfo(id, slot)
						if spellID then
							local start, duration, enable = GetSpellCooldown(spellID)
							if start and (start > 0) and (enable == 1) and (duration > 1.5) then -- don't include global cooldowns
								local name, _, icon = GetSpellInfo(spellID)
								if name then -- make sure we have a valid spell name
									if (MOD.myClass ~= "DEATHKNIGHT") or CheckRuneCooldown(name, duration) then -- if death knight check rune cooldown
										local locked = false
										if lockedOut then -- check if this spell is on same cooldown as any lockout spell
											for ls, ld in pairs(lockouts) do if ld == duration and lockstarts[ls] == start then locked = true end end
										end
										if not locked then
											local link = GetSpellLink(spellID)
											AddCooldown(name, spellID, icon, start, duration, "spell link", link, "player")
										end
									end
								end
							end
						end
					end
				end
			end
		end
		
		local p = professions -- scan professions for spells on cooldown
		p[1], p[2], p[3], p[4], p[5], p[6] = GetProfessions()
		for index = 1, 6 do
			if p[index] then
				local prof, _, _, _, numSpells, offset = GetProfessionInfo(p[index])
				for i = 1, numSpells do
					local index = i + offset
					local stype, id = GetSpellBookItemInfo(index, "spell")
					if stype == "SPELL" then -- use spellbook index to check for cooldown
						local start, duration, enable = GetSpellCooldown(index, "spell")
						if start and (start > 0) and (enable == 1) and (duration > 1.5) then -- don't include global cooldowns
							local name, _, icon = GetSpellInfo(index, "spell")
							if name then -- make sure we have a valid spell name
								local link = GetSpellLink(index, "spell")
								AddCooldown(name, id, icon, start, duration, "spell link", link, "player")
							end
						end
					end
				end
			end
		end

		local numSpells = HasPetSpells() -- returns the number of pet spells
		if numSpells and UnitExists("pet") then
			for i = 1, numSpells do
				local start, duration, enable = GetSpellCooldown(i, "pet")
				if start and (start > 0) and (enable == 1) and (duration > 1.5) then -- don't include global cooldowns
					local name, _, icon = GetSpellInfo(i, "pet")
					if name then
						local hyperlink = GetSpellLink(i, "pet")
						local _, spellID = GetSpellBookItemInfo(i, "pet")
						AddCooldown(name, spellID, icon, start, duration, "spell link", hyperlink, "pet")
					end
				end
			end
		end
		
		local offset = nil -- check for override/vehicle bar actions on cooldown
		if HasVehicleActionBar() then offset = 132 elseif HasOverrideActionBar() then offset = 156 end
		if offset then
			for slot = 1, 6 do
				local actionType, spellID = GetActionInfo(slot + offset)
				if actionType == "spell" then
					local start, duration, enable = GetSpellCooldown(spellID)
					if start and (start > 0) and (enable == 1) and (duration > 1.5) then -- don't include global cooldowns
						local name, _, icon = GetSpellInfo(spellID)
						if name then AddCooldown(name, spellID, icon, start, duration, "spell id", spellID, "player") end
					end
				end
			end
		end
		
		for bag = 0, NUM_BAG_SLOTS do
			local numSlots = GetContainerNumSlots(bag)
			for i = 1, numSlots do
				local itemID = GetContainerItemID(bag, i)
				if itemID then CheckItemCooldown(itemID) end
			end
		end
		
		CheckInventoryCooldown("HeadSlot")
		CheckInventoryCooldown("NeckSlot")
		CheckInventoryCooldown("BackSlot")
		CheckInventoryCooldown("ShoulderSlot")
		CheckInventoryCooldown("ChestSlot")
		CheckInventoryCooldown("ShirtSlot")
		CheckInventoryCooldown("TabardSlot")
		CheckInventoryCooldown("WristSlot")
		CheckInventoryCooldown("HandsSlot")
		CheckInventoryCooldown("WaistSlot")
		CheckInventoryCooldown("LegsSlot")
		CheckInventoryCooldown("FeetSlot")
		CheckInventoryCooldown("Finger0Slot")
		CheckInventoryCooldown("Finger1Slot")
		CheckInventoryCooldown("Trinket0Slot")
		CheckInventoryCooldown("Trinket1Slot")
		CheckInventoryCooldown("MainHandSlot")
		CheckInventoryCooldown("SecondaryHandSlot")

		if startGCD and durationGCD then -- detect global cooldowns
			local timeLeft = startGCD + durationGCD - GetTime() -- calculate timeLeft from start and duration
			if timeLeft > 0 then
				AddCooldown(L["GCD"], nil, iconGCD, startGCD, durationGCD, "text", L["Global Cooldown"], "player")
			else
				startGCD = nil; durationGCD = nil -- this cooldown is no longer valid
			end
		end
		
		CheckInternalCooldowns()
		CheckSpellEffectCooldowns()
		updateCooldowns = false
	end
end
