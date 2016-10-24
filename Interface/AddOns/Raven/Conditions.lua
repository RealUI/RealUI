-- Raven is an addon to monitor auras and cooldowns, providing timer bars and icons plus helpful notifications.

-- Conditions.lua contains routines to test auras and status info to generate notifications.

-- Exported functions:
-- Raven:InitializeCondition(name, condition) adds a condition (or overwrites a default one) during initialization
-- Raven:CheckCondition(name) evaluates a condition and returns its current value
-- Raven:GetConditionSpell(name) returns the spell associated with a condition
-- Raven:GetConditionText(name) returns a string containing a detailed description of the condition

local MOD = Raven
local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local LSPELL = MOD.LocalSpellNames
MOD.status = {} -- global status info cached on every update
local range_initialized = false
local timeEvents = {} -- table of times at which to trigger a simulated event during update processing
local classificationList = { normal = L["Normal"], worldboss = L["Boss"], elite = L["Elite"], rare = L["Rare"], rlite = L["Rare Elite"] }
local classifications = { "normal", "worldboss", "elite", "rare", "rlite" }
local unitList = { player = "Player", pet = "Pet", target = "Target", focus = "Focus",
	mouseover = "Mouseover", pettarget = "Pet's Target", targettarget = "Target's Target", focustarget = "Focus's Target" }

-- Saved variables don't handle being set to nil properly so need to use alternate value to indicate an option has been turned off
local Off = 0 -- value used to designate an option is turned off
local function IsOff(value) return value == nil or value == Off end -- return true if option is turned off
local function IsOn(value) return value ~= nil and value ~= Off end -- return true if option is turned on

-- Initialization settings for each test type (note that nil values are placeholders for documentation purposes)
MOD.conditionTests = {
	["Player Status"] = { enable = false, inCombat = nil, isResting = nil, hasPet = nil, isStealthed = nil, isMounted = nil,
		inGroup = nil, inParty = nil, inRaid = nil, isPvP = nil, inInstance = nil, inArena = nil, inBattleground = nil,
		hasMainHand = nil, levelMainHand = 1, hasOffHand = nil, levelOffHand = 1, checkSpec = nil, spec = nil, checkSpell = nil, spell = nil,
		checkTalent = nil, talent = nil, checkLevel = nil, level = 85, checkStance = nil, stance = nil,
		checkHealth = nil, minHealth = 100, checkPower = nil, minPower = 100, checkHolyPower = nil, minHolyPower = 1,
		checkShards = nil, minShards = 1, checkChi = nil, minChi = 1, checkLunarPower = nil, minLunarPower = 1,
		checkInsanity = nil, minInsanity = 100, checkMaelstrom = nil, minMaelstrom = 150, checkArcane = nil, minArcane = 1,
		checkComboPoints = nil, minComboPoints = 5, checkRunes = nil, minRunes = 1, checkTotems = nil, totem = nil },
	["Pet Status"] = { enable = false, exists = nil, inCombat = nil, checkTarget = nil,
		checkHealth = nil, minHealth = 100, checkPower = nil, minPower = 100, checkFamily = nil, family = nil, checkSpec = nil, spec = nil },
	["Target Status"] = { enable = false, exists = nil, isPlayer = nil, isEnemy = nil, isFriend = nil, inRange = nil, isSteal = nil, isDead = nil,
		checkHealth = nil, minHealth = 100, checkMaxHealth = nil, maxHealth = nil, checkPower = nil, minPower = 100, classify = nil, classification = "normal" },
	["Target's Target Status"] = { enable = false, exists = nil, isPlayer = nil, isEnemy = nil, isFriend = nil, inRange = nil, isSteal = nil, isDead = nil,
		checkHealth = nil, minHealth = 100, checkMaxHealth = nil, maxHealth = nil, checkPower = nil, minPower = 100, classify = nil, classification = "normal" },
	["Focus Status"] = { enable = false, exists = nil, isPlayer = nil, isEnemy = nil, isFriend = nil, inRange = nil, isSteal = nil, isDead = nil,
		checkHealth = nil, minHealth = 100, checkPower = nil, minPower = 100, classify = nil, classification = "normal" },
	["Focus's Target Status"] = { enable = false, exists = nil, isPlayer = nil, isEnemy = nil, isFriend = nil, inRange = nil, isSteal = nil, isDead = nil,
		checkHealth = nil, minHealth = 100, checkPower = nil, minPower = 100, classify = nil, classification = "normal" },
	["All Buffs"] = { enable = false, unit = "player", auras = nil, isMine = nil, toggle = false },
	["Any Buffs"] = { enable = false, unit = "player", auras = nil, isMine = nil, toggle = false },
	["Buff Time Left"] = { enable = false, unit = "player", aura = nil, timeLeft = 10, isMine = nil, toggle = false },
	["Buff Count"] = { enable = false, unit = "player", aura = nil, count = 1, isMine = nil, toggle = false },
	["Buff Type"] = { enable = false, hasBuff = nil, toggle = false },
	["All Debuffs"] = { enable = false, unit = "target", auras = nil, isMine = nil, toggle = false },
	["Any Debuffs"] = { enable = false, unit = "target", auras = nil, isMine = nil, toggle = false },
	["Debuff Time Left"] = { enable = false, unit = "target", aura = nil, timeLeft = 10, isMine = nil, toggle = false },
	["Debuff Count"] = { enable = false, unit = "player", aura = nil, count = 1, isMine = nil, toggle = false },
	["Debuff Type"] = { enable = false, hasDebuff = nil, toggle = false },
	["All Cooldowns"] = { enable = false, notUsable = false, spells = nil, timeLeft = 10, toggle = Off },
	["Spell Ready"] = { enable = false, spell = nil, inRange = nil, notUsable = false, checkCharges = nil, charges = 1 },
	["Spell Casting"] = { enable = false, spell = nil, unit = "player" },
	["Item Ready"] = { enable = false, item = nil, toggle = nil, checkCount = nil, count = 1, checkCharges = nil, charges = 1 },
}

MOD.testOrder = { "Player Status", "Pet Status", "Target Status", "Target's Target Status", "Focus Status", "Focus's Target Status", "All Buffs", "Any Buffs", "Buff Time Left",
	"Buff Count", "Buff Type", "All Debuffs", "Any Debuffs", "Debuff Time Left", "Debuff Count", "Debuff Type",
	"All Cooldowns", "Spell Ready", "Spell Casting", "Item Ready"
}
	
local testNames = {
	["Player Status"]= L["Player Status"],
	["Pet Status"]= L["Pet Status"],
	["Target Status"] = L["Target Status"],
	["Target's Target Status"] = L["Target's Target Status"],
	["Focus Status"] = L["Focus Status"],
	["Focus's Target Status"] = L["Focus's Target Status"],
	["All Buffs"] = L["All Buffs"],
	["Any Buffs"] = L["Any Buffs"],
	["Buff Time Left"] = L["Buff Time Left"],
	["Buff Count"] = L["Buff Count"],
	["Buff Type"] = L["Buff Type"],
	["All Debuffs"] = L["All Debuffs"],
	["Any Debuffs"] = L["Any Debuffs"],
	["Debuff Time Left"] = L["Debuff Time Left"],
	["Debuff Count"] = L["Debuff Count"],
	["Debuff Type"] = L["Debuff Type"],
	["All Cooldowns"] = L["All Cooldowns"],
	["Spell Ready"] = L["Spell Ready"],
	["Spell Casting"] = L["Spell Casting"],
	["Item Ready"] = L["Item Ready"],
}

-- Initialize data used by this module, and restore any default test settings
function MOD:InitializeConditions()
	local conditions = MOD.db.profile.Conditions[MOD.myClass]
	if conditions then
		for _, c in pairs(conditions) do
			if IsOn(c) and c.tests then
				for ttype, test in pairs(c.tests) do
					local ct = MOD.conditionTests[ttype]
					if ct then for k, v in pairs(ct) do if test[k] == nil then test[k] = v end end end
					if test.classification == "rareelite" then test.classification = "rlite" end -- fix to support multiple classifications
				end
			end
		end
	else
		MOD.db.profile.Conditions[MOD.myClass] = {}
	end
	for _, c in pairs(MOD.db.global.SharedConditions) do
		if IsOn(c) and c.tests then
			for ttype, test in pairs(c.tests) do
				local ct = MOD.conditionTests[ttype]
				if ct then for k, v in pairs(ct) do if test[k] == nil then test[k] = v end end end
			end
		end
	end
end

-- Finalize conditions by stripping out unnecessary values, updating shared conditions, removing default test settings
function MOD:FinalizeConditions()
	local conditions = MOD.db.profile.Conditions[MOD.myClass]
	if conditions then
		for _, c in pairs(conditions) do
			if IsOn(c) then
				c.result = nil; c.testResult = nil -- these values are left over from evaluations
				if c.tests then
					for ttype, test in pairs(c.tests) do
						local ct = MOD.conditionTests[ttype]
						if ct then for k, v in pairs(ct) do if test[k] == v then test[k] = nil end end end
					end
				end
				if c.shared and c.name then
					local t = MOD.CopyTable(c)
					t.shared = false
					MOD.db.global.SharedConditions["[" .. MOD.myClass .. "] " .. c.name] = t
				end
			end
		end
	end
	for _, c in pairs(MOD.db.global.SharedConditions) do
		if IsOn(c) and c.tests then
			for ttype, test in pairs(c.tests) do
				local ct = MOD.conditionTests[ttype]
				if ct then for k, v in pairs(ct) do if test[k] == v then test[k] = nil end end end
			end
		end
	end
end

-- Add a time event for a condition that needs to be tested at a specific future time
local function AddTimeEvent(name, timeLeft) timeEvents[name] = GetTime() + timeLeft end

-- Check if any time events have been reached, remove expired time events
function MOD:CheckTimeEvents()
	local now = GetTime()
	for name, t in pairs(timeEvents) do if t < now then timeEvents[name] = nil; return true end end
	return false
end

-- Generate a localized string from a classification list
local function ClassificationList(cl)
	local s, d = "", ""
	for _, v in pairs(classifications) do if string.find(cl, v) ~= nil then s = s .. d .. classificationList[v]; d = " | " end end
	return s
end

-- Range checking spell tables and functions
local range_spells = {}
local range_tables = {
	enemy = { DEATHKNIGHT = { 49576, 127344 }, DRUID = { 8921, 339, 6795 }, HUNTER = { 193455, 19434, 193265 }, MAGE = { 133 }, PALADIN = { 62124, 20271 },
		PRIEST = { 589 }, ROGUE = { 1725 }, SHAMAN = { 403, 188196, 187837 }, WARLOCK = { 215279, 196657 }, WARRIOR = { 355 }, DEMONHUNTER = { 185123 } },
	friend = { DRUID = { 5185 }, MAGE = { 130 }, PALADIN = { 633, 1044 }, HUNTER = { 34477 },
		PRIEST = { 2061 }, ROGUE = { 57934 }, SHAMAN = { 546, 8004 }, WARLOCK = { 20707, 5697 }, WARRIOR = { 198304 } },
	pet = { HUNTER = { 136 }, WARLOCK = { 755 } },
	dead = { DEATHKNIGHT = { 61999 }, DRUID = { 50769, 20484 }, PALADIN = { 7328 }, PRIEST = { 2006 }, SHAMAN = { 2008 } },
}

-- Initialize the range spell tables with spell names
local function InitializeRangeSpells()
	local _, class = UnitClass("player")
	for k, v in pairs(range_tables) do
		if v[class] then
			local t = {}
			for _, sid in pairs(v[class]) do local name = GetSpellInfo(sid); if name and name ~= "" then table.insert(t, name) end end
			range_spells[k] = t
		end
	end
end

-- Check a table to see if a unit is in range of any of the spells it contains
local function InRangeSpells(unit, t) if t then for _, s in pairs(t) do if (IsSpellInRange(s, unit) == 1) then return true end end end return false end

-- Return true or false if the unit is in range based on whether it is enemy, friend or pet
local function UnitRangeCheck(unit)
	if not range_initialized then InitializeRangeSpells(); range_initialized = true end
	if CheckInteractDistance(unit, 1) then return true end
	if UnitCanAttack("player", unit) then -- enemy unit
		if InRangeSpells(unit, range_spells.enemy) then return true end
	else -- friendly unit
		if UnitIsDeadOrGhost(unit) then return InRangeSpells(unit, range_spells.dead) end
		if InRangeSpells(unit, range_spells.friend) then return true end
		if UnitIsUnit(unit, "pet") and InRangeSpells(unit, range_spells.pet) then return true end
	end
	return false
end

-- Check if a classification list contains a classification, return true if it does
local function CheckClassification(v, cl) if v == "rareelite" then v = "rlite" end; return string.find(cl or "", v) ~= nil end

-- Check if a spell is known in the spellbook
local function CheckSpellKnown(spell)
	local id = tonumber(spell)
	if not id then id = MOD:GetSpellID(spell) end
	if not id or not IsSpellKnown(id) then return false end
	return true
end

-- Check if a spell is ready to be cast by the player, if rangeCheck then make sure in range of unit too
local function CheckSpellReady(spell, unit, rangeCheck, usable, checkCharges, charges)
	if not spell or (spell == "") then return true end
	if string.find(spell, "^#%d+") then -- check if name is in special format for specific spell id (i.e., #12345)
		local id = tonumber(string.sub(spell, 2)) -- extract the spell id and get the name
		spell = GetSpellInfo(id)
		if not spell or (spell == "") then return false end
	end
	if usable and not IsUsableSpell(spell) then return false end -- checks player has learned the spell, has mana and/or reagents, and reactive conditions are met
	if IsOn(checkCharges) then -- optionally check for remaining spell charges (can't count on the value of cd if not on cooldown)
		local n = GetSpellCharges(spell) -- this has to be done separate from cooldown check in order to correctly handle the check for "less than"
		if not n then n = 0 end
		if not charges then charges = 1 end -- set to default value used in options panel
		if checkCharges == true then if n >= charges then return false end else if n < charges then return false end end
	else
		local cd = MOD:CheckCooldown(spell) -- checks if spell is on cooldown (note this should correctly ignore DK rune cooldowns)
		if cd and ((cd[4] ~= nil) and (not cd[9] or cd[9] == 0)) then return false end -- verify is on cooldown and has a valid duration and no charges remaining
	end
	if IsOn(rangeCheck) and IsOn(unit) and ((IsSpellInRange(spell, unit) == 1) ~= rangeCheck) then return false end
	return true
end

-- Check if a specified spell is currently being cast or channeled by the unit 
local function CheckSpellCast(spell, unit)
	if IsOff(unit) or not spell or (spell == "") then return true end
	local sp = UnitCastingInfo(unit)
	if (sp ~= nil) and (spell == sp) then return true end
	sp = UnitChannelInfo(unit)
	if (sp ~= nil) and (spell == sp) then return true end
	return false
end

-- Check if an item is ready to be used by the player, can be either itemID (number) or item name (string)
-- The item must be in the player's bag for this to work properly
local function CheckItemReady(item, ready, checkCount, count, checkCharges, charges)
	if not item or (item == "") then return true end
	local id, n = tonumber(item), 0
	if IsOn(ready) then
		local isReady = true
		if id then -- in 4.0.2 GetItemCooldown was changed to only work with item IDs
			local start, duration = GetItemCooldown(id); if (start > 0) and (duration > 0) then isReady = false end
		else -- so have to fallback to looking in internal cooldown tables
			local cd = MOD:CheckCooldown(item); if cd and (cd[1] ~= nil) then isReady = false end			
		end
		if isReady ~= ready then return false end
	end
	if id then item = id end
	if IsOn(checkCount) then
		n = GetItemCount(item, false, false)
		if not n then n = 0 end
		if not count then count = 1 end -- set to default value used in options panel
		if checkCount == true then if n >= count then return false end else if n < count then return false end end
	end
	if IsOn(checkCharges) then
		n = GetItemCount(item, false, true)
		if not n then n = 0 end
		if not charges then charges = 1 end -- set to default value used in options panel
		if checkCharges == true then if n >= charges then return false end else if n < charges then return false end end
	end
	return true
end

-- Check for either at least one active aura (hasAll is false) or all active auras (hasAll is true)
-- If isMine true then cast by the player, if false then cast by other, if nil cast by anyone
local function CheckAuras(unit, auras, hasAll, isMine, buff, toggle)
	if IsOff(unit) or not auras then return true end -- no test
	if (unit == "target") and MOD.status.noTarget then return not toggle end
	if (unit == "focus") and MOD.status.noFocus then return not toggle end
	local found = false
	for _, aname in pairs(auras) do -- look for each aura and check if buff/debuff and cast by player
		local foundThis = false
		local auraList = MOD:CheckAura(unit, aname, buff)
		if #auraList > 0 then
			for _, aura in pairs(auraList) do
				if IsOff(isMine) or (isMine == (aura[6] == "player")) then -- check cast by setting
					found = true -- found at least one of the auras
					foundThis = true -- found this particular aura
				end
			end
		end
		if hasAll and not foundThis then return toggle end -- not all are found
	end
	if toggle then return not found end -- flip result if necessary
	return found
end

-- Check an aura on the unit to see if active and either expiration time is less than or equal or count is greater
-- If isMine true then cast by the player, if false then cast by other, if nil cast by anyone
local function CheckAuraValue(unit, aname, timeLeft, count, isMine, buff, toggle)
	if IsOff(unit) or not aname or (aname == "") or (IsOff(timeLeft) and IsOff(count)) then return true end -- no test
	if (unit == "target") and MOD.status.noTarget then return not toggle end
	if (unit == "focus") and MOD.status.noFocus then return not toggle end
	local auraList = MOD:CheckAura(unit, aname, buff)
	for _, aura in pairs(auraList) do
		if IsOff(isMine) or (isMine == (aura[6] == "player")) then -- check if found one with right cast by setting
			if timeLeft then local when = aura[2] - timeLeft; if when >= 0 then AddTimeEvent(aname, when); return not toggle end end -- check expiration time
			if count and (aura[3] >= count) then return not toggle end -- check count is greater or equal
		end
	end
	return toggle
end

-- Return true only if all spells in the list are on cooldown and have at least the specified amount of time left.
-- If toggle is true then check if they all have less than the specified time left instead.
-- If ready is true then check player has mana and/or reagents, and reactive conditions are met and, if not, consider it on long cooldown
-- as long as it is in the spell book (always return false if the player does not know the spell).
-- If a spell is not ready for some other reason (e.g., too much target HP ala Kill Shot) then consider it on long cooldown.
local function CheckAllCooldowns(spells, ready, timeLeft, toggle)
	if not timeLeft then timeLeft = 10 end
	for _, spell in pairs(spells) do -- look for each spell and check if on cooldown
		local cdt = 0
		if ready and not IsUsableSpell(spell) then if not CheckSpellKnown(spell) then return false end cdt = 3600 end
		local cd = MOD:CheckCooldown(spell) -- look up in the active cooldowns table
		if cd and (cd[1] ~= nil) and ((cd[4] ~= nil) and (not cd[9] or cd[9] == 0)) then cdt = cd[1]; if timeLeft < cdt then AddTimeEvent(spell, cdt - timeLeft) end end
		if toggle == true then
			if cdt >= timeLeft then return false end
		else
			if cdt < timeLeft then return false end
		end
	end
	return true
end

-- Return the current stance or "none" if not in one
local function GetStance()
	local form, _ = "none", nil
	local index = GetShapeshiftForm(nil)
	if index > 0 then
		 _, form = GetShapeshiftFormInfo(index)
	end
	return form
end

-- Return whether the specified talent (either spell name or spell id) is active in current spec
function MOD.CheckTalent(talent)
	local id = tonumber(talent)
	if id then talent = GetSpellInfo(id); if talent == "" then talent = nil end end -- translate spell id
	if talent then
		local t = MOD.talents[talent]
		if t and t.active then return true end
	end
	return nil
end

-- Check if mounted, complicated by having to test for druid flight form
local function CheckMounted()
	local flying = false
	if MOD.myClass == "DRUID" then
		local form = GetShapeshiftForm(true)
		if form ~= 0 then
			local _, fname = GetShapeshiftFormInfo(form)
			flying = (fname == LSPELL["Flight Form"]) or (fname == LSPELL["Swift Flight Form"])
		end
	end
	return IsMounted() or flying
end

-- Check balance druid lunar power
local function CheckLunarPower(minPower)
	if (MOD.myClass == "DRUID") and IsSpellKnown(78674) and minPower then -- only Balance if know Starsurge spell
		local power = UnitPower("player", SPELL_POWER_LUNAR_POWER)
		local maxPower = UnitPowerMax("player", SPELL_POWER_LUNAR_POWER)
		if (maxPower <= 0) or (power > maxPower) then return false end -- avoid errors from the lunar power API
		local e = 100 * power / maxPower
		return e >= minPower
	end
	return false
end

-- Check all totem slots for a specific active totem
local function CheckTotem(totem)
	if MOD.myClass == "SHAMAN" then
		local now = GetTime()
		for i = 1, MAX_TOTEMS do
			local haveTotem, name, startTime, duration = GetTotemInfo(i)
			local exists = haveTotem and name and name ~= "" and now <= (startTime + duration) -- true only if a valid totem is in the slot
			if exists and (name == totem) then return true end
		end
	end
	return false
end

-- Check if target matches the specified type
local function CheckTarget(targetType, unit)
	local m = not UnitExists(unit)
	if targetType == "none" then m = not m end
	if targetType == "player" then m = m or not UnitIsUnit("target", unit) end
	return not m
end

-- Check if weapon equipped with at least the minimum specified item level
local function CheckWeapon(slot, level)
	local islot = GetInventorySlotInfo(slot)
	local id = GetInventoryItemLink("player", islot)
	if id and level then
		local iname, _, _, ilevel = GetItemInfo(id)
		if iname and (ilevel >= level) then return true end
	end
	return false
end

-- Check current specialization against the first argument (or the optional second argument, which is a table of specialization names or numbers)
function MOD.CheckSpec(spec, specList)
	local stat = MOD.status
	local currentSpec = stat.specialization
	local currentName = currentSpec and select(2, GetSpecializationInfo(currentSpec)) or "none"
	if specList then
		for _, name in pairs(specList) do
			local id = tonumber(name)
			if id then
				if currentSpec == id then return true end
			else
				if name == currentName then return true end
			end
		end
		return false
	end
	if not spec then spec = "none" end
	local id = tonumber(spec)
	if id then return currentSpec == id end 
	return spec == currentName
end

-- Check current pet talent tree, including workaround for API returning nil for hunter's ferocity pets
local function CheckPetSpec(spec)
	if not spec then spec = "none" end
	local currentName = "none"
	local ferocity = GetSpellInfo(4154) -- hack workaround to localize Ferocity, fingers crossed it works in all languages, spell id must be valid
	if UnitExists("pet") then currentName = GetPetTalentTree() or ((MOD.myClass == "HUNTER") and ferocity) or "none" end
	return spec == currentName
end

-- Check current pet creature family
local function CheckPetFamily(family)
	if not family then family = "none" end
	local currentName = "none"
	if UnitExists("pet") then currentName = UnitCreatureFamily("pet") or "none" end
	return family == currentName
end

-- Make sure the table contains at least one entry
local function HasTable(t)
	if IsOn(t) and (type(t) == "table") and (next(t) ~= nil) then return true end
	return false
end

-- Check the value of one test with logical AND between all enabled subtests
local function CheckTestAND(ttype, t)
	local toggle = (t.toggle == true)
	local stat = MOD.status
	if ttype == "Player Status" then
		if IsOn(t.inCombat) and (t.inCombat ~= stat.inCombat) then return false end
		if IsOn(t.inGroup) and (t.inGroup ~= stat.inGroup) then return false end
		if IsOn(t.inParty) and (t.inParty ~= stat.inParty) then return false end
		if IsOn(t.inRaid) and (t.inRaid ~= stat.inRaid) then return false end
		if IsOn(t.inInstance) and (t.inInstance ~= stat.inInstance) then return false end
		if IsOn(t.inArena) and (t.inArena ~= stat.inArena) then return false end
		if IsOn(t.inBattleground) and (t.inBattleground ~= stat.inBattleground) then return false end
		if IsOn(t.isResting) and (t.isResting ~= stat.isResting) then return false end
		if IsOn(t.isStealthed) and (t.isStealthed ~= stat.isStealthed) then return false end
		if IsOn(t.isMounted) and (t.isMounted ~= stat.isMounted) then return false end
		if IsOn(t.isPvP) and (t.isPvP ~= stat.isPvP) then return false end
		if IsOn(t.checkLevel) and IsOn(t.level) and (t.checkLevel ~= (stat.level >= t.level)) then return false end
		if IsOn(t.checkHealth) and IsOn(t.minHealth) and (t.checkHealth ~= (stat.health >= t.minHealth)) then return false end
		if IsOn(t.checkPower) and IsOn(t.minPower) and (t.checkPower ~= (stat.power >= t.minPower)) then return false end
		if IsOn(t.checkHolyPower) and IsOn(t.minHolyPower) and (t.checkHolyPower ~= (stat.holyPower >= t.minHolyPower)) then return false end
		if IsOn(t.checkInsanity) and IsOn(t.minInsanity) and (t.checkInsanity ~= (stat.insanity >= t.minInsanity)) then return false end
		if IsOn(t.checkMaelstrom) and IsOn(t.minMaelstrom) and (t.checkMaelstrom ~= (stat.maelstrom >= t.minMaelstrom)) then return false end
		if IsOn(t.checkChi) and IsOn(t.minChi) and (t.checkChi ~= (stat.chi >= t.minChi)) then return false end
		if IsOn(t.checkShards) and IsOn(t.minShards) and (t.checkShards ~= (stat.shards >= t.minShards)) then return false end
		if IsOn(t.checkLunarPower) and (t.checkLunarPower ~= CheckLunarPower(t.minLunarPower)) then return false end
		if IsOn(t.checkArcane) and IsOn(t.minArcane) and (t.checkArcane ~= (stat.arcane >= t.minArcane)) then return false end
		if IsOn(t.checkComboPoints) and IsOn(t.minComboPoints) and (t.checkComboPoints ~= (stat.combo >= t.minComboPoints)) then return false end
		if IsOn(t.hasPet) and (t.hasPet ~= HasPetUI()) then return false end
		if IsOn(t.checkStance) and IsOn(t.stance) and (t.stance ~= stat.stance) then return false end
		if IsOn(t.checkRunes) and IsOn(t.minRunes) and (t.checkRunes ~= (MOD.runeCount >= t.minRunes)) then return false end
		if IsOn(t.checkTotems) and IsOn(t.totem) and not CheckTotem(t.totem) then return false end
		if IsOn(t.checkTalent) and IsOn(t.talent) and not MOD.CheckTalent(t.talent) then return false end
		if IsOn(t.checkSpec) and IsOn(t.spec) and not MOD.CheckSpec(t.spec, t.specList) then return false end
		if IsOn(t.checkSpell) and IsOn(t.spell) and not CheckSpellKnown(t.spell) then return false end
		if IsOn(t.hasMainHand) and not CheckWeapon("MainHandSlot", t.levelMainHand) then return false end
		if IsOn(t.hasOffHand) and not CheckWeapon("SecondaryHandSlot", t.levelOffHand) then return false end
	elseif ttype == "Pet Status" then -- pet must exist for these tests to be true
		if IsOn(t.exists) and (t.exists == stat.noPet) then return false end
		if IsOn(t.inCombat) and (t.inCombat ~= stat.petCombat) then return false end
		if IsOn(t.checkTarget) and not CheckTarget(t.checkTarget, "pettarget") then return false end
		if IsOn(t.checkHealth) and IsOn(t.minHealth) and (stat.noPet or (t.checkHealth ~= (stat.petHealth >= t.minHealth))) then return false end
		if IsOn(t.checkPower) and IsOn(t.minPower) and (stat.noPet or (t.checkPower ~= (stat.petPower >= t.minPower))) then return false end
		if IsOn(t.checkFamily) and IsOn(t.family) and not CheckPetFamily(t.family) then return false end
		if IsOn(t.checkSpec) and IsOn(t.spec) and not CheckPetSpec(t.spec) then return false end
	elseif ttype == "Target Status" then -- target must exist for these tests to be true
		if IsOn(t.exists) and (t.exists == stat.noTarget) then return false end
		if IsOn(t.isPlayer) and (stat.noTarget or (t.isPlayer ~= stat.targetPlayer)) then return false end
		if IsOn(t.isEnemy) and (stat.noTarget or (t.isEnemy ~= stat.targetEnemy)) then return false end
		if IsOn(t.isFriend) and (stat.noTarget or (t.isFriend ~= stat.targetFriend)) then return false end
		if IsOn(t.isDead) and (stat.noTarget or (t.isDead ~= stat.targetDead)) then return false end
		if IsOn(t.isSteal) and (stat.noTarget or (t.isSteal ~= MOD:UnitHasBuff("target", "Steal"))) then return false end
		if t.classify and (not t.classification or t.classification == "" or stat.noTarget or
			(t.classify ~= CheckClassification(stat.targetClassification, t.classification))) then return false end
		if t.checkMaxHealth and (not t.maxHealth or stat.noTarget or (tonumber(t.maxHealth) or 0) > stat.targetMaxHealth) then return false end
		if IsOn(t.checkHealth) and IsOn(t.minHealth) and (stat.noTarget or (t.checkHealth ~= (stat.targetHealth >= t.minHealth))) then return false end
		if IsOn(t.checkPower) and IsOn(t.minPower) and (stat.noTarget or (t.checkPower ~= (stat.targetPower >= t.minPower))) then return false end
		if IsOn(t.inRange) and (stat.noTarget or (t.inRange ~= stat.targetInRange)) then return false end
	elseif ttype == "Target's Target Status" then -- target's target must exist for these tests to be true
		if IsOn(t.exists) and (t.exists == stat.noTargetTarget) then return false end
		if IsOn(t.isPlayer) and (stat.noTargetTarget or (t.isPlayer ~= stat.targetTargetPlayer)) then return false end
		if IsOn(t.isEnemy) and (stat.noTargetTarget or (t.isEnemy ~= stat.targetTargetEnemy)) then return false end
		if IsOn(t.isFriend) and (stat.noTargetTarget or (t.isFriend ~= stat.targetTargetFriend)) then return false end
		if IsOn(t.isDead) and (stat.noTargetTarget or (t.isDead ~= stat.targetTargetDead)) then return false end
		if IsOn(t.isSteal) and (stat.noTargetTarget or (t.isSteal ~= MOD:UnitHasBuff("targettarget", "Steal"))) then return false end
		if t.classify and (not t.classification or t.classification == "" or stat.noTargetTarget or
			(t.classify ~= CheckClassification(stat.targetTargetClassification, t.classification))) then return false end
		if t.checkMaxHealth and (not t.maxHealth or stat.noTargetTarget or (tonumber(t.maxHealth) or 0) > stat.targetTargetMaxHealth) then return false end
		if IsOn(t.checkHealth) and IsOn(t.minHealth) and (stat.noTargetTarget or (t.checkHealth ~= (stat.targetTargetHealth >= t.minHealth))) then return false end
		if IsOn(t.checkPower) and IsOn(t.minPower) and (stat.noTargetTarget or (t.checkPower ~= (stat.targetTargetPower >= t.minPower))) then return false end
		if IsOn(t.inRange) and (stat.noTargetTarget or (t.inRange ~= stat.targetTargetInRange)) then return false end
	elseif ttype == "Focus Status" then -- focus must exist for these tests to be true
		if IsOn(t.exists) and (t.exists == stat.noFocus) then return false end
		if IsOn(t.isPlayer) and (stat.noFocus or (t.isPlayer ~= stat.focusPlayer)) then return false end
		if IsOn(t.isEnemy) and (stat.noFocus or (t.isEnemy ~= stat.focusEnemy)) then return false end
		if IsOn(t.isFriend) and (stat.noFocus or (t.isFriend ~= stat.focusFriend)) then return false end
		if IsOn(t.isDead) and (stat.noFocus or (t.isDead ~= stat.focusDead)) then return false end
		if IsOn(t.isSteal) and (stat.noFocus or (t.isSteal ~= MOD:UnitHasBuff("focus", "Steal"))) then return false end
		if t.classify and (not t.classification or t.classification == "" or stat.noFocus or
			(t.classify ~= CheckClassification(stat.focusClassification, t.classification))) then return false end
		if IsOn(t.checkHealth) and IsOn(t.minHealth) and (stat.noFocus or (t.checkHealth ~= (stat.focusHealth >= t.minHealth))) then return false end
		if IsOn(t.checkPower) and IsOn(t.minPower) and (stat.noFocus or (t.checkPower ~= (stat.focusPower >= t.minPower))) then return false end
		if IsOn(t.inRange) and (stat.noFocus or (t.inRange ~= stat.focusInRange)) then return false end
	elseif ttype == "Focus's Target Status" then -- focus target must exist for these tests to be true
		if IsOn(t.exists) and (t.exists == stat.noFocusTarget) then return false end
		if IsOn(t.isPlayer) and (stat.noFocusTarget or (t.isPlayer ~= stat.focusTargetPlayer)) then return false end
		if IsOn(t.isEnemy) and (stat.noFocusTarget or (t.isEnemy ~= stat.focusTargetEnemy)) then return false end
		if IsOn(t.isFriend) and (stat.noFocusTarget or (t.isFriend ~= stat.focusTargetFriend)) then return false end
		if IsOn(t.isDead) and (stat.noFocusTarget or (t.isDead ~= stat.focusTargetDead)) then return false end
		if IsOn(t.isSteal) and (stat.noFocusTarget or (t.isSteal ~= MOD:UnitHasBuff("focustarget", "Steal"))) then return false end
		if t.classify and (not t.classification or t.classification == "" or stat.noFocusTarget or
			(t.classify ~= CheckClassification(stat.focusTargetClassification, t.classification))) then return false end
		if IsOn(t.checkHealth) and IsOn(t.minHealth) and (stat.noFocusTarget or (t.checkHealth ~= (stat.focusTargetHealth >= t.minHealth))) then return false end
		if IsOn(t.checkPower) and IsOn(t.minPower) and (stat.noFocusTarget or (t.checkPower ~= (stat.focusTargetPower >= t.minPower))) then return false end
		if IsOn(t.inRange) and (stat.noFocusTarget or (t.inRange ~= stat.focusTargetInRange)) then return false end
	elseif ttype == "All Buffs" then
		if HasTable(t.auras) and not CheckAuras(t.unit, t.auras, true, t.isMine, true, toggle) then return false end
	elseif ttype == "Any Buffs" then
		if HasTable(t.auras) and not CheckAuras(t.unit, t.auras, false, t.isMine, true, toggle) then return false end
	elseif ttype == "Buff Time Left" then
		if not CheckAuraValue(t.unit, t.aura, t.timeLeft, nil, t.isMine, true, toggle) then return false end
	elseif ttype == "Buff Count" then
		if not CheckAuraValue(t.unit, t.aura, nil, t.count, t.isMine, true, toggle) then return false end
	elseif ttype == "Buff Type" then
		if IsOn(t.hasBuff) and (MOD:UnitHasBuff("player", t.hasBuff) == toggle) then return false end
	elseif ttype == "All Debuffs" then
		if HasTable(t.auras) and not CheckAuras(t.unit, t.auras, true, t.isMine, false, toggle) then return false end
	elseif ttype == "Any Debuffs" then
		if HasTable(t.auras) and not CheckAuras(t.unit, t.auras, false, t.isMine, false, toggle) then return false end
	elseif ttype == "Debuff Time Left" then
		if not CheckAuraValue(t.unit, t.aura, t.timeLeft, nil, t.isMine, false, toggle) then return false end
	elseif ttype == "Debuff Count" then
		if not CheckAuraValue(t.unit, t.aura, nil, t.count, t.isMine, false, toggle) then return false end
	elseif ttype == "Debuff Type" then
		if IsOn(t.hasDebuff) and (MOD:UnitHasDebuff("player", t.hasDebuff) == toggle) then return false end
	elseif ttype == "All Cooldowns" then
		if HasTable(t.spells) and not CheckAllCooldowns(t.spells, not t.notUsable, t.timeLeft, toggle) then return false end
	elseif ttype == "Spell Ready" then
		if not CheckSpellReady(t.spell, "target", t.inRange, not t.notUsable, t.checkCharges, t.charges) then return false end
	elseif ttype == "Spell Casting" then
		if not CheckSpellCast(t.spell, t.unit) then return false end
	elseif ttype == "Item Ready" then
		if not CheckItemReady(t.item, t.toggle, t.checkCount, t.count, t.checkCharges, t.charges) then return false end
	else
		return false
	end
	return true
end

-- Check the value of one test with logical OR between all enabled subtests
local function CheckTestOR(ttype, t)
	local toggle = (t.toggle == true)
	local stat = MOD.status
	if ttype == "Player Status" then
		if IsOn(t.inCombat) and (t.inCombat == stat.inCombat) then return true end
		if IsOn(t.inGroup) and (t.inGroup == stat.inGroup) then return true end
		if IsOn(t.inParty) and (t.inParty == stat.inParty) then return true end
		if IsOn(t.inRaid) and (t.inRaid == stat.inRaid) then return true end
		if IsOn(t.inInstance) and (t.inInstance == stat.inInstance) then return true end
		if IsOn(t.inArena) and (t.inArena == stat.inArena) then return true end
		if IsOn(t.inBattleground) and (t.inBattleground == stat.inBattleground) then return true end
		if IsOn(t.isResting) and (t.isResting == stat.isResting) then return true end
		if IsOn(t.isStealthed) and (t.isStealthed == stat.isStealthed) then return true end
		if IsOn(t.isMounted) and (t.isMounted == stat.isMounted) then return true end
		if IsOn(t.isPvP) and (t.isPvP == stat.isPvP) then return true end
		if IsOn(t.checkLevel) and IsOn(t.level) and (t.checkLevel == (stat.level >= t.level)) then return true end
		if IsOn(t.checkHealth) and IsOn(t.minHealth) and (t.checkHealth == (stat.health >= t.minHealth)) then return true end
		if IsOn(t.checkPower) and IsOn(t.minPower) and (t.checkPower == (stat.power >= t.minPower)) then return true end
		if IsOn(t.checkHolyPower) and IsOn(t.minHolyPower) and (t.checkHolyPower == (stat.holyPower >= t.minHolyPower)) then return true end
		if IsOn(t.checkInsanity) and IsOn(t.minInsanity) and (t.checkInsanity == (stat.insanity >= t.minInsanity)) then return true end
		if IsOn(t.checkMaelstrom) and IsOn(t.minMaelstrom) and (t.checkMaelstrom == (stat.maelstrom >= t.minMaelstrom)) then return true end
		if IsOn(t.checkChi) and IsOn(t.minChi) and (t.checkChi == (stat.chi >= t.minChi)) then return true end
		if IsOn(t.checkShards) and IsOn(t.minShards) and (t.checkShards == (stat.shards >= t.minShards)) then return true end
		if IsOn(t.checkArcane) and IsOn(t.minArcane) and (t.checkArcane == (stat.arcane >= t.minArcane)) then return true end
		if IsOn(t.checkLunarPower) and (t.checkLunarPower == CheckLunarPower(t.minLunarPower)) then return true end
		if IsOn(t.checkComboPoints) and IsOn(t.minComboPoints) and (t.checkComboPoints == (stat.combo >= t.minComboPoints)) then return true end
		if IsOn(t.hasPet) and (t.hasPet == HasPetUI()) then return true end
		if IsOn(t.checkStance) and IsOn(t.stance) and (t.stance == stat.stance) then return true end
		if IsOn(t.checkRunes) and IsOn(t.minRunes) and (t.checkRunes == (MOD.runeCount >= t.minRunes)) then return true end
		if IsOn(t.checkTotems) and IsOn(t.totem) and CheckTotem(t.totem) then return true end
		if IsOn(t.checkTalent) and IsOn(t.talent) and MOD.CheckTalent(t.talent) then return true end
		if IsOn(t.checkSpec) and IsOn(t.spec) and MOD.CheckSpec(t.spec, t.specList) then return true end
		if IsOn(t.checkSpell) and IsOn(t.spell) and CheckSpellKnown(t.spell) then return true end
		if IsOn(t.hasMainHand) and CheckWeapon("MainHandSlot", t.levelMainHand) then return true end
		if IsOn(t.hasOffHand) and CheckWeapon("SecondaryHandSlot", t.levelOffHand) then return true end
	elseif ttype == "Pet Status" then -- pet must exist for these tests to be true
		if IsOn(t.exists) and (t.exists ~= stat.noPet) then return true end
		if IsOn(t.inCombat) and (t.inCombat == stat.petCombat) then return true end
		if IsOn(t.checkTarget) and CheckTarget(t.checkTarget, "pettarget") then return true end
		if IsOn(t.checkHealth) and IsOn(t.minHealth) and (not stat.noPet and (t.checkHealth == (stat.petHealth >= t.minHealth))) then return true end
		if IsOn(t.checkPower) and IsOn(t.minPower) and (not stat.noPet and (t.checkPower == (stat.petPower >= t.minPower))) then return true end
		if IsOn(t.checkFamily) and IsOn(t.family) and CheckPetFamily(t.family) then return true end
		if IsOn(t.checkSpec) and IsOn(t.spec) and CheckPetSpec(t.spec) then return true end
	elseif ttype == "Target Status" then -- target must exist for these tests to be true
		if IsOn(t.exists) and (t.exists ~= stat.noTarget) then return true end
		if not stat.noTarget then
			if IsOn(t.isPlayer) and (t.isPlayer == stat.targetPlayer) then return true end
			if IsOn(t.isEnemy) and (t.isEnemy == stat.targetEnemy) then return true end
			if IsOn(t.isFriend) and (t.isFriend == stat.targetFriend) then return true end
			if IsOn(t.isDead) and (t.isDead == stat.targetDead) then return true end
			if IsOn(t.isSteal) and (t.isSteal == MOD:UnitHasBuff("target", "Steal")) then return true end
			if t.classify and t.classification and (t.classification ~= "") and
				(t.classify == CheckClassification(stat.targetClassification, t.classification)) then return true end
			if t.checkMaxHealth and (t.maxHealth and not stat.noTarget and (tonumber(t.maxHealth) or 0) <= stat.targetMaxHealth) then return true end
			if IsOn(t.checkHealth) and IsOn(t.minHealth) and (t.checkHealth == (stat.targetHealth >= t.minHealth)) then return true end
			if IsOn(t.checkPower) and IsOn(t.minPower) and (t.checkPower == (stat.targetPower >= t.minPower)) then return true end
			if IsOn(t.inRange) and (t.inRange == stat.targetInRange) then return true end
		end
	elseif ttype == "Target's Target Status" then -- target's target must exist for these tests to be true
		if IsOn(t.exists) and (t.exists ~= stat.noTargetTarget) then return true end
		if not stat.noTargetTarget then
			if IsOn(t.isPlayer) and (t.isPlayer == stat.targetTargetPlayer) then return true end
			if IsOn(t.isEnemy) and (t.isEnemy == stat.targetTargetEnemy) then return true end
			if IsOn(t.isFriend) and (t.isFriend == stat.targetTargetFriend) then return true end
			if IsOn(t.isDead) and (t.isDead == stat.targetTargetDead) then return true end
			if IsOn(t.isSteal) and (t.isSteal == MOD:UnitHasBuff("targettarget", "Steal")) then return true end
			if t.classify and t.classification and (t.classification ~= "") and
				(t.classify == CheckClassification(stat.targetTargetClassification, t.classification)) then return true end
			if t.checkMaxHealth and (t.maxHealth and not stat.noTargetTarget and (tonumber(t.maxHealth) or 0) <= stat.targetTargetMaxHealth) then return true end
			if IsOn(t.checkHealth) and IsOn(t.minHealth) and (t.checkHealth == (stat.targetTargetHealth >= t.minHealth)) then return true end
			if IsOn(t.checkPower) and IsOn(t.minPower) and (t.checkPower == (stat.targetTargetPower >= t.minPower)) then return true end
			if IsOn(t.inRange) and (t.inRange == stat.targetTargetInRange) then return true end
		end
	elseif ttype == "Focus Status" then -- focus must exist for these tests to be true
		if IsOn(t.exists) and (t.exists ~= stat.noFocus) then return true end
		if not stat.noFocus then
			if IsOn(t.isPlayer) and (t.isPlayer == stat.focusPlayer) then return true end
			if IsOn(t.isEnemy) and (t.isEnemy == stat.focusEnemy) then return true end
			if IsOn(t.isFriend) and (t.isFriend == stat.focusFriend) then return true end
			if IsOn(t.isDead) and (t.isDead == stat.focusDead) then return true end
			if IsOn(t.isSteal) and (t.isSteal == MOD:UnitHasBuff("focus", "Steal")) then return true end
			if t.classify and t.classification and (t.classification ~= "") and
				(t.classify == CheckClassification(stat.focusClassification, t.classification)) then return true end
			if IsOn(t.checkHealth) and IsOn(t.minHealth) and (t.checkHealth == (stat.focusHealth >= t.minHealth)) then return true end
			if IsOn(t.checkPower) and IsOn(t.minPower) and (t.checkPower == (stat.focusPower >= t.minPower)) then return true end
			if IsOn(t.inRange) and (t.inRange == stat.focusInRange) then return true end
		end
	elseif ttype == "Focus's Target Status" then -- focus's target must exist for these tests to be true
		if IsOn(t.exists) and (t.exists ~= stat.noFocusTarget) then return true end
		if not stat.noFocusTarget then
			if IsOn(t.isPlayer) and (t.isPlayer == stat.focusTargetPlayer) then return true end
			if IsOn(t.isEnemy) and (t.isEnemy == stat.focusTargetEnemy) then return true end
			if IsOn(t.isFriend) and (t.isFriend == stat.focusTargetFriend) then return true end
			if IsOn(t.isDead) and (t.isDead == stat.focusTargetDead) then return true end
			if IsOn(t.isSteal) and (t.isSteal == MOD:UnitHasBuff("focustarget", "Steal")) then return true end
			if t.classify and t.classification and (t.classification ~= "") and
				(t.classify == CheckClassification(stat.focusTargetClassification, t.classification)) then return true end
			if IsOn(t.checkHealth) and IsOn(t.minHealth) and (t.checkHealth == (stat.focusTargetHealth >= t.minHealth)) then return true end
			if IsOn(t.checkPower) and IsOn(t.minPower) and (t.checkPower == (stat.focusTargetPower >= t.minPower)) then return true end
			if IsOn(t.inRange) and (t.inRange == stat.focusTargetInRange) then return true end
		end
	elseif ttype == "All Buffs" then
		if HasTable(t.auras) and CheckAuras(t.unit, t.auras, true, t.isMine, true, toggle) then return true end
	elseif ttype == "Any Buffs" then
		if HasTable(t.auras) and CheckAuras(t.unit, t.auras, false, t.isMine, true, toggle) then return true end
	elseif ttype == "Buff Time Left" then
		if CheckAuraValue(t.unit, t.aura, t.timeLeft, nil, t.isMine, true, toggle) then return true end
	elseif ttype == "Buff Count" then
		if CheckAuraValue(t.unit, t.aura, nil, t.count, t.isMine, true, toggle) then return true end
	elseif ttype == "Buff Type" then
		if IsOn(t.hasBuff) and (MOD:UnitHasBuff("player", t.hasBuff) ~= toggle) then return true end
	elseif ttype == "All Debuffs" then
		if HasTable(t.auras) and CheckAuras(t.unit, t.auras, true, t.isMine, false, toggle) then return true end
	elseif ttype == "Any Debuffs" then
		if HasTable(t.auras) and CheckAuras(t.unit, t.auras, false, t.isMine, false, toggle) then return true end
	elseif ttype == "Debuff Time Left" then
		if CheckAuraValue(t.unit, t.aura, t.timeLeft, nil, t.isMine, false, toggle) then return true end
	elseif ttype == "Debuff Count" then
		if CheckAuraValue(t.unit, t.aura, nil, t.count, t.isMine, false, toggle) then return true end
	elseif ttype == "Debuff Type" then
		if IsOn(t.hasDebuff) and (MOD:UnitHasDebuff("player", t.hasDebuff) ~= toggle) then return true end
	elseif ttype == "All Cooldowns" then
		if HasTable(t.spells) and CheckAllCooldowns(t.spells, not t.notUsable, t.timeLeft, toggle) then return true end
	elseif ttype == "Spell Ready" then
		if CheckSpellReady(t.spell, "target", t.inRange, not t.notUsable, t.checkCharges, t.charges) then return true end
	elseif ttype == "Spell Casting" then
		if CheckSpellCast(t.spell, t.unit) then return true end
	elseif ttype == "Item Ready" then
		if CheckItemReady(t.item, t.toggle, t.checkCount, t.count, t.checkCharges, t.charges) then return true end
	end
	return false
end

-- Check the value of all tests in one condition, combine with either logical OR or logical AND depending on condition's testLogic setting
local function CheckConditionTests(c)
	if not c.enabled then return false end -- if not enabled always return false
	if c.tests then
		if c.testLogic then
			local count = 0
			for ttype, test in pairs(c.tests) do if test.enable then if CheckTestOR(ttype, test) then return true end count = count + 1 end end
			if count > 0 then return false end -- if any test is enabled and none are true then return false
		else -- must be logical AND
			for ttype, test in pairs(c.tests) do if test.enable and not CheckTestAND(ttype, test) then return false end end
		end
	end
	return true -- return true if condition is enabled and either no tests are enabled or, for logical AND, no tests are false
end

-- Process table of conditions in current profile, checking status and auras.
function MOD:UpdateConditions()
	-- update globally useful conditions
	local stat = MOD.status
	stat.inCombat = UnitAffectingCombat("player")
	stat.inRaid = IsInRaid()
	stat.inGroup = GetNumGroupMembers() > 0
	stat.inParty = stat.inGroup and not stat.inRaid
	local instance, it = IsInInstance()
	if instance ~= nil then stat.inInstance = (it == "party") or (it == "raid"); stat.inArena = (it == "arena"); stat.inBattleground = (it == "pvp") else
		stat.inInstance = false; stat.inArena = false; stat.inBattleground = false end
	stat.isResting = IsResting()
	stat.isMounted = CheckMounted()
	stat.inVehicle = UnitHasVehicleUI("player")
	stat.isPvP = UnitIsPVP("player")
	stat.isStealthed = IsStealthed()
	stat.level = UnitLevel("player")
	local m = UnitHealthMax("player"); if m > 0 then stat.health = (100 * UnitHealth("player") / m) else stat.health = 0 end
	m = UnitPowerMax("player"); if m > 0 then stat.power = (100 * UnitPower("player") / m) else stat.power = 0 end
	if MOD.myClass == "PALADIN" then stat.holyPower = UnitPower("player", SPELL_POWER_HOLY_POWER) else stat.holyPower = 0 end
	if MOD.myClass == "WARLOCK" then stat.shards = UnitPower("player", SPELL_POWER_SOUL_SHARDS) else stat.shards = 0 end
	if MOD.myClass == "PRIEST" then stat.insanity = UnitPower("player", SPELL_POWER_INSANITY) else stat.insanity = 0 end
	if MOD.myClass == "MONK" then stat.chi = UnitPower("player", SPELL_POWER_CHI) else stat.chi = 0 end
	if MOD.myClass == "SHAMAN" then stat.maelstrom = UnitPower("player", SPELL_POWER_MAELSTROM) else stat.maelstrom = 0 end
	if MOD.myClass == "MAGE" then stat.arcane = UnitPower("player", SPELL_POWER_ARCANE_CHARGES) else stat.arcane = 0 end
	stat.combo = UnitPower("player", SPELL_POWER_COMBO_POINTS) or 0 -- replaces GetComboPoints call
	stat.stance = GetStance()
	stat.specialization = GetSpecialization()
	stat.noPet = not UnitExists("pet")
	if not stat.noPet then
		stat.petCombat = UnitAffectingCombat("pet")
		m = UnitHealthMax("pet"); if m > 0 then stat.petHealth = (100 * UnitHealth("pet") / m) else stat.petHealth = 0 end
		m = UnitPowerMax("pet"); if m > 0 then stat.petPower = (100 * UnitPower("pet") / m) else stat.petPower = 0 end
	end
	stat.noTarget = not UnitExists("target")
	if not stat.noTarget then
		stat.targetPlayer = UnitIsPlayer("target")
		stat.targetEnemy = UnitIsEnemy("player", "target")
		stat.targetFriend = UnitIsFriend("player", "target")
		stat.targetDead = UnitIsDead("target")
		local classification = UnitClassification("target")
		if MOD.LibBossIDs and MOD.CheckLibBossIDs(UnitGUID("target")) then classification = "worldboss" end
		stat.targetClassification = classification
		m = UnitHealthMax("target")
		if m > 0 then stat.targetMaxHealth = m; stat.targetHealth = (100 * UnitHealth("target") / m) else stat.targetMaxHealth = 0; stat.targetHealth = 0 end
		m = UnitPowerMax("target"); if m > 0 then stat.targetPower = (100 * UnitPower("target") / m) else stat.targetPower = 0 end
		stat.targetInRange = UnitRangeCheck("target")
	end
	stat.noTargetTarget = not UnitExists("targettarget")
	if not stat.noTargetTarget then
		stat.targetTargetPlayer = UnitIsPlayer("targettarget")
		stat.targetTargetEnemy = UnitIsEnemy("player", "targettarget")
		stat.targetTargetFriend = UnitIsFriend("player", "targettarget")
		stat.targetTargetDead = UnitIsDead("targettarget")
		local classification = UnitClassification("targettarget")
		if MOD.LibBossIDs and MOD.CheckLibBossIDs(UnitGUID("targettarget")) then classification = "worldboss" end
		stat.targetTargetClassification = classification
		m = UnitHealthMax("targettarget")
		if m > 0 then stat.targetTargetMaxHealth = m; stat.targetTargetHealth = (100 * UnitHealth("targettarget") / m) else stat.targetTargetMaxHealth = 0; stat.targetTargetHealth = 0 end
		m = UnitPowerMax("targettarget"); if m > 0 then stat.targetTargetPower = (100 * UnitPower("targettarget") / m) else stat.targetTargetPower = 0 end
		stat.targetTargetInRange = UnitRangeCheck("targettarget")
	end
	stat.noFocus = not UnitExists("focus")
	if not stat.noFocus then
		stat.focusPlayer = UnitIsPlayer("focus")
		stat.focusEnemy = UnitIsEnemy("player", "focus")
		stat.focusFriend = UnitIsFriend("player", "focus")
		stat.focusDead = UnitIsDead("focus")
		local classification = UnitClassification("focus")
		if MOD.LibBossIDs and MOD.CheckLibBossIDs(UnitGUID("focus")) then classification = "worldboss" end
		stat.focusClassification = classification
		m = UnitHealthMax("focus"); if m > 0 then stat.focusHealth = (100 * UnitHealth("focus") / m) else stat.focusHealth = 0 end
		m = UnitPowerMax("focus"); if m > 0 then stat.focusPower = (100 * UnitPower("focus") / m) else stat.focusPower = 0 end
		stat.focusInRange = UnitRangeCheck("focus")
	end
	stat.noFocusTarget = not UnitExists("focustarget")
	if not stat.noFocusTarget then
		stat.focusTargetPlayer = UnitIsPlayer("focustarget")
		stat.focusTargetEnemy = UnitIsEnemy("player", "focustarget")
		stat.focusTargetFriend = UnitIsFriend("player", "focustarget")
		stat.focusTargetDead = UnitIsDead("focustarget")
		local classification = UnitClassification("focustarget")
		if MOD.LibBossIDs and MOD.CheckLibBossIDs(UnitGUID("focustarget")) then classification = "worldboss" end
		stat.focusTargetClassification = classification
		m = UnitHealthMax("focustarget"); if m > 0 then stat.focusTargetHealth = (100 * UnitHealth("focustarget") / m) else stat.focusTargetHealth = 0 end
		m = UnitPowerMax("focustarget"); if m > 0 then stat.focusTargetPower = (100 * UnitPower("focustarget") / m) else stat.focusTargetPower = 0 end
		stat.focusTargetInRange = UnitRangeCheck("focustarget")
	end
	
	-- only check conditions for the player's class
	local ct = MOD.db.profile.Conditions[MOD.myClass]
	if ct then
		-- set all conditions to false first (quicker to clear it than to check IsOn)
		for _, c in pairs(ct) do if IsOn(c) then c.testResult = false; c.result = false end end
		-- don't check conditions if dead or in vehicle or on a taxi
		if UnitIsDeadOrGhost("player") then return end
		if UnitHasVehicleUI("player") then return end
		if UnitOnTaxi("player") then return end		
		-- run the tests in each condition to get intermediate testResult
		for _, c in pairs(ct) do
			if IsOn(c) and c.name then
				if IsOn(c.setResult) then c.testResult = c.setResult else c.testResult = CheckConditionTests(c) end
			end
		end
		-- then check dependencies and overrides to get final result
		for _, c in pairs(ct) do 
			if IsOn(c) and c.name then
				c.result = c.testResult -- start with intermediate result
				if c.result and c.dependencies then -- if starting true then check dependencies
					local ncount, nreqd = 0, false -- look for any non-required that evaluates to true
					for dname, result in pairs(c.dependencies) do -- check each dependency in the table
						local dep = ct[dname] -- dependency may be missing from the conditions table after a copy
						if c.dependencyType and c.dependencyType[dname] then -- check for at least one non-required dependency to be true
							if IsOn(dep) and (dep.testResult == result) then nreqd = true end
							ncount = ncount + 1
						else
							if IsOff(dep) or (dep.testResult ~= result) then c.result = false end -- all required must be true
						end
					end
					if (ncount > 0) and not nreqd then c.result = false end
				end
				if c.toggleResult and IsOff(c.setResult) then c.result = not c.result end
			end
		end
	end
end
	
-- Initialize conditions for the player's class from the preset files
function MOD:SetConditionDefaults()
	local nt = MOD.classConditions[MOD.myClass]
	if nt then for k, v in pairs(nt) do MOD:InitializeCondition(k, v) end end
	MOD.classConditions = nil -- not used again after initialization
end

-- Get localized spell name from a field in a condition definition (return nil if called with nil)
local function GetLocalizedSpellName(field)
	if not field then return nil end
	local id, name = tonumber(field), field
	if id then name = GetSpellInfo(id); if name == "" then name = nil end end
	return name
end
	
-- Add or overwrite a condition from another module. If class is not nil then restrict to designated class.
-- Must be called during OnInitialize to add to default conditions
-- Changes made using the configuration panel will be tracked in Raven's profile.
function MOD:InitializeCondition(name, c, class)
	if class then
		class = string.upper(class)
		if class == "DEATH KNIGHT" then class = "DEATHKNIGHT" end
		if class == "DEMON HUNTER" then class = "DEMONHUNTER" end
		if class ~= MOD.myClass then return end
	end
	local ct = MOD.DefaultProfile.profile.Conditions
	if ct and name and c then
		if not ct[MOD.myClass] then ct[MOD.myClass] = {} end
		if c.name == nil then c.name = name end -- set default values for uninitialized fields
		if c.enabled == nil then c.enabled = true end
		if c.notify == nil then c.notify = true end
		if c.tests then
			for ttype, test in pairs(c.tests) do
				test.spell = GetLocalizedSpellName(test.spell)
				test.aura = GetLocalizedSpellName(test.aura)
				test.talent = GetLocalizedSpellName(test.talent)
				test.stance = GetLocalizedSpellName(test.stance)
				if test.spells then for k, n in pairs(test.spells) do test.spells[k] = GetLocalizedSpellName(n) end end
				if test.auras then for k, n in pairs(test.auras) do test.auras[k] = GetLocalizedSpellName(n) end end
				-- don't convert test.item because itemID is much more useful currently
			end
		end
		c.associatedSpell = GetLocalizedSpellName(c.associatedSpell) -- localized associated spell for color and icon
		ct[MOD.myClass][name] = c -- add to the default profile, it is okay to overwrite any with same name
	end
end

-- Return the current value of a condition, nil if not found
function MOD:CheckCondition(name)
	local ct = MOD.db.profile.Conditions[MOD.myClass]
	if ct then
		local c = ct[name]
		if IsOn(c) and c.name then return c.result end
	end
	return nil
end

-- Return the associated spell for a condition, nil if not found
function MOD:GetConditionSpell(name)
	local ct = MOD.db.profile.Conditions[MOD.myClass]
	if ct then
		local c = ct[name]
		if IsOn(c) and c.associatedSpell and (c.associatedSpell ~= "") then return c.associatedSpell end
	end
	return nil
end

-- Return a text description of the current condition
function MOD:GetConditionText(name)
	local description, testString, depString, resultString, logicString, valueString = "", "", "", "", "", ""
	description = L["Condition Name"](name)
	local etext = ""
	local ct, c = MOD.db.profile.Conditions[MOD.myClass], nil
	if ct then c = ct[name] end
	if not c then return description .. " " .. L["(not found)"] end
	if not c.enabled then etext = L["Disable String"] end
	description = description .. etext
	if c.tests then
		for _, tt in pairs(MOD.testOrder) do -- loop through tests in right order
			local t = c.tests[tt]
			if t and t.enable then -- check if a test of this type is defined and enabled
				local a, d = "", " " -- a is string for current test conditions, d gets comma after first test clause added
				local at = string.format("\n|cFF7adbf2%s:|r", testNames[tt]) -- localized test name
				if tt == "Player Status" then
					if IsOn(t.inCombat) then if t.inCombat then a = a .. d .. L["In Combat"] else a = a .. d .. L["Out Of Combat"] end; d = ", " end
					if IsOn(t.isResting) then if t.isResting then a = a .. d .. L["Is Resting"] else a = a .. d .. L["Not Resting"] end; d = ", " end
					if IsOn(t.isStealthed) then if t.isStealthed then a = a .. d .. L["Is Stealthed"] else a = a .. d .. L["Not Stealthed"] end; d = ", " end
					if IsOn(t.isMounted) then if t.isMounted then a = a .. d .. L["Is Mounted"] else a = a .. d .. L["Not Mounted"] end; d = ", " end
					if IsOn(t.isPvP) then if t.isPvP then a = a .. d .. L["Is PvP"] else a = a .. d .. L["Not PvP"] end; d = ", " end
					if IsOn(t.inGroup) then if t.inGroup then a = a .. d .. L["In Group"] else a = a .. d .. L["Not In Group"] end; d = ", " end
					if IsOn(t.inParty) then if t.inParty then a = a .. d .. L["In Party"] else a = a .. d .. L["Not In Party"] end; d = ", " end
					if IsOn(t.inRaid) then if t.inRaid then a = a .. d .. L["In Raid"] else a = a .. d .. L["Not In Raid"] end; d = ", " end
					if IsOn(t.inInstance) then if t.inInstance then a = a .. d .. L["In Instance"] else a = a .. d .. L["Not In Instance"] end; d = ", " end
					if IsOn(t.inArena) then if t.inArena then a = a .. d .. L["In Arena"] else a = a .. d .. L["Not In Arena"] end; d = ", " end
					if IsOn(t.inBattleground) then if t.inBattleground then a = a .. d .. L["In Battleground"] else a = a .. d .. L["Not In Battleground"] end; d = ", " end
					if IsOn(t.hasPet) then if t.hasPet then a = a .. d .. L["Has Pet"] else a = a .. d .. L["No Pet"] end; d = ", " end
					if IsOn(t.checkLevel) and t.level then local x = "<"; if t.checkLevel then x = ">=" end;
						a = a .. d .. L["Level String"](x, t.level); d = ", " end
					if IsOn(t.checkHealth) and t.minHealth then local x = "<"; if t.checkHealth then x = ">=" end;
						a = a .. d .. L["Health String"](x, t.minHealth); d = ", " end
					if IsOn(t.checkPower) and t.minPower then local x = "<"; if t.checkPower then x = ">=" end;
						a = a .. d .. L["Power String"](x, t.minPower); d = ", " end
					if IsOn(t.checkHolyPower) and t.minHolyPower then local x = "<"; if t.checkHolyPower then x = ">=" end;
						a = a .. d .. L["Holy Power String"](x, t.minHolyPower); d = ", " end
					if IsOn(t.checkShards) and t.minShards then local x = "<"; if t.checkShards then x = ">=" end;
						a = a .. d .. L["Shards String"](x, t.minShards); d = ", " end
					if IsOn(t.checkArcane) and t.minArcane then local x = "<"; if t.checkArcane then x = ">=" end;
						a = a .. d .. L["Arcane Charges String"](x, t.minArcane); d = ", " end
					if IsOn(t.checkInsanity) and t.minInsanity then local x = "<"; if t.checkInsanity then x = ">=" end;
						a = a .. d .. L["Insanity String"](x, t.minInsanity); d = ", " end
					if IsOn(t.checkMaelstrom) and t.minMaelstrom then local x = "<"; if t.checkMaelstrom then x = ">=" end;
						a = a .. d .. L["Maelstrom String"](x, t.minMaelstrom); d = ", " end
					if IsOn(t.checkLunarPower) and t.minLunarPower then local x = "<"; if t.checkLunarPower then x = ">=" end;
						a = a .. d .. L["Lunar String"](x, t.minLunarPower); d = ", " end
					if IsOn(t.checkChi) and t.minChi then local x = "<"; if t.checkChi then x = ">=" end;
						a = a .. d .. L["Chi String"](x, t.minChi); d = ", " end
					if IsOn(t.checkComboPoints) and t.minComboPoints then local x = "<"; if t.checkComboPoints then x = ">=" end;
						a = a .. d .. L["Combo Pts String"](x, t.minComboPoints); d = ", " end
					if IsOn(t.checkStance) and t.stance then a = a .. d .. L["Stance String"](t.stance); d = ", " end
					if IsOn(t.checkTalent) and t.talent then a = a .. d .. L["Talent String"](t.talent); d = ", " end
					if IsOn(t.checkSpec) and t.spec then a = a .. d .. L["Spec String"](t.spec); d = ", " end
					if IsOn(t.checkSpell) and t.spell then a = a .. d .. L["Spell String"](t.spell); d = ", " end
					if IsOn(t.checkRunes) and t.minRunes then local x = "<"; if t.checkRunes then x = ">=" end;
						a = a .. d .. L["Runes String"](x, t.minRunes); d = ", " end
					if IsOn(t.checkTotems) and t.totem then a = a .. d .. L["Totem String"](t.totem); d = ", " end
					if IsOn(t.hasMainHand) and IsOn(t.levelMainHand) then a = a .. d .. L["Mainhand String"](t.levelMainHand); d = ", " end
					if IsOn(t.hasOffHand) and IsOn(t.levelOffHand) then a = a .. d .. L["Offhand String"](t.levelOffHand); d = ", " end
				elseif tt == "Pet Status" then
					if IsOn(t.exists) then if t.exists then a = a .. d .. L["Exists"] else a = a .. d .. L["Not Exists"] end; d = ", " end
					if IsOn(t.inCombat) then if t.inCombat then a = a .. d .. L["In Combat"] else a = a .. d .. L["Out Of Combat"] end; d = ", " end
					if IsOn(t.checkTarget) then if t.checkTarget == "none" then a = a .. d .. L["No Target"]
						elseif t.checkTarget == "player" then a = a .. d .. L["Player's Target"]
						elseif t.checkTarget == "any" then a = a .. d .. L["Any Target"] end; d = ", " end
					if IsOn(t.checkHealth) and t.minHealth then local x = "<"; if t.checkHealth then x = ">=" end;
						a = a .. d .. L["Health String"](x, t.minHealth); d = ", " end
					if IsOn(t.checkPower) and t.minPower then local x = "<"; if t.checkPower then x = ">=" end;
						a = a .. d .. L["Power String"](x, t.minPower); d = ", " end
					if IsOn(t.checkFamily) and t.family then a = a .. d .. L["Pet Family String"](t.family); d = ", " end
					if IsOn(t.checkSpec) and t.spec then a = a .. d .. L["Pet Spec String"](t.spec); d = ", " end
				elseif tt == "Target Status" or tt == "Target's Target Status" or tt == "Focus Status" or tt == "Focus's Target Status" then
					if IsOn(t.exists) then if t.exists then a = a .. d .. L["Exists"] else a = a .. d .. L["Not Exists"] end; d = ", " end
					if IsOn(t.isPlayer) then if t.isPlayer then a = a .. d .. L["Is Player"] else a = a .. d .. L["Not Player"] end; d = ", " end
					if IsOn(t.isEnemy) then if t.isEnemy then a = a .. d .. L["Is Enemy"] else a = a .. d .. L["Not Enemy"] end; d = ", " end
					if IsOn(t.isFriend) then if t.isFriend then a = a .. d .. L["Is Friendly"] else a = a .. d .. L["Not Friendly"] end; d = ", " end
					if IsOn(t.isDead) then if t.isDead then a = a .. d .. L["Is Dead"] else a = a .. d .. L["Not Dead"] end; d = ", " end
					if t.classify and t.classification and (t.classification ~= "") then
						local lc = ClassificationList(t.classification); if not lc then lc = "Unknown" end
						if t.classify then a = a .. d .. L["Is "] .. lc else a = a .. d .. L["Not "] .. lc end
						d = ", "
					end
					if IsOn(t.inRange) then if t.inRange then a = a .. d .. L["In Range"] else a = a .. d .. L["Out Of Range"] end; d = ", " end
					if IsOn(t.isSteal) then if t.isSteal then a = a .. d .. L["Spellsteal"] else a = a .. d .. L["Not Spellsteal"] end; d = ", " end
					if IsOn(t.checkMaxHealth) and t.maxHealth then a = a .. d .. L["Max Health String"](t.maxHealth); d = ", " end
					if IsOn(t.checkHealth) and t.minHealth then local x = "<"; if t.checkHealth then x = ">=" end;
						a = a .. d .. L["Health String"](x, t.minHealth); d = ", " end
					if IsOn(t.checkPower) and t.minPower then local x = "<"; if t.checkPower then x = ">=" end;
						a = a .. d .. L["Power String"](x, t.minPower); d = ", " end
				elseif tt == "All Buffs" or tt == "All Debuffs" then
					if IsOn(t.unit) and t.auras then
						for _, v in pairs(t.auras) do a = a .. d .. string.format("\"%s\"", v); d = ", " end
						if d == ", " then -- the list of auras contains at least one entry
							if t.toggle == true then a = a .. d .. L["Not All Active"] else a = a .. d .. L["All Active"] end
							a = a .. d .. L["On"] .. " " .. unitList[t.unit]
							if t.isMine == true then a = a .. d .. L["Cast By Player"] else if t.isMine == false then
								a = a .. d .. L["Cast By Other"] else a = a .. d .. L["Cast By Anyone"] end end
						end
					end
				elseif tt == "Any Buffs" or tt == "Any Debuffs" then
					if IsOn(t.unit) and t.auras then
						for _, v in pairs(t.auras) do a = a .. d .. string.format("\"%s\"", v); d = ", " end
						if d == ", " then -- the list of auras contains at least one entry
							if t.toggle == true then a = a .. d .. L["None Active"] else a = a .. d .. L["Any Active"] end
							a = a .. d .. L["On"] .. " " .. unitList[t.unit]
							if t.isMine == true then a = a .. d .. L["Cast By Player"] else if t.isMine == false then
								a = a .. d .. L["Cast By Other"] else a = a .. d .. L["Cast By Anyone"] end end
						end
					end
				elseif tt == "Buff Time Left" or tt == "Debuff Time Left" then
					if IsOn(t.unit) and IsOn(t.timeLeft) and t.aura and t.aura ~= "" then
						a = a .. string.format(" \"%s\"", t.aura); d = ", "
						a = a .. d .. L["On"] .. " " .. unitList[t.unit]
						local ds = string.format("%0d:%02d", math.floor(t.timeLeft / 60), t.timeLeft % 60)
						if t.toggle == true then a = a .. d .. L["Less Than"] .. " " .. ds else a = a .. d .. ds .. " " .. L["Or More"] end
						if t.isMine == true then a = a .. d .. L["Cast By Player"] else if t.isMine == false then
							a = a .. d .. L["Cast By Other"] else a = a .. d .. L["Cast By Anyone"] end end
					end
				elseif tt == "Buff Count" or tt == "Debuff Count" then
					if IsOn(t.unit) and t.aura and t.aura ~= "" then
						a = a .. string.format(" \"%s\"", t.aura); d = ", "
						a = a .. d .. "On" .. " " .. unitList[t.unit]
						local dcount = t.count
						if IsOff(dcount) then dcount = 1 end -- default count is 1
						if t.toggle == true then a = a .. d .. L["Less Than"] .. " " .. dcount else a = a .. d .. dcount .. " " .. L["Or More"] end
						if t.isMine == true then a = a .. d .. L["Cast By Player"] else if t.isMine == false then
							a = a .. d .. L["Cast By Other"] else a = a .. d .. L["Cast By Anyone"] end end
					end
				elseif tt == "Buff Type" then
					if IsOn(t.hasBuff) then
						a = a .. string.format(" \"%s\" ", t.hasBuff)
						if t.toggle == true then a = a .. L["Missing"] else a = a .. L["Present"] end
					end
				elseif tt == "Debuff Type" then
					if IsOn(t.hasDebuff) then
						a = a .. string.format(" \"%s\" ", t.hasDebuff)
						if t.toggle == true then a = a .. L["Missing"] else a = a .. L["Present"] end
					end
				elseif tt == "All Cooldowns" then
					if IsOn(t.timeLeft) and t.spells then
						for _, v in pairs(t.spells) do a = a .. d .. string.format("\"%s\"", v); d = ", " end
						if d == ", " then -- the list of spells contains at least one entry
							local ds = string.format("%0.1f ", t.timeLeft)
							if t.toggle == true then a = a .. d .. L["Less Than"] .. " " .. ds .. L["Seconds"] else a = a .. d .. ds .. L["Seconds Or More"] end
						end
						if t.notUsable == true then a = a .. d .. L["Ignore Spell Usable"] else a = a .. d .. L["Test Spell Usable"] end
					end
				elseif tt == "Spell Ready" then
					if t.spell and t.spell ~= "" then
						a = a .. string.format(" \"%s\"", t.spell); d = ", "
						if t.notUsable == true then a = a .. d .. L["Ignore Spell Usable"] else a = a .. d .. L["Test Spell Usable"] end
						if IsOn(t.inRange) then
							if t.inRange == true then a = a .. d .. L["Target In Range"] else a = a .. d .. L["Target Out Of Range"] end
						end
						local dcount = t.charges
						if IsOff(dcount) then dcount = 1 end -- default value is 1
						if t.checkCharges == true then a = a .. d .. L["Less Than"] .. " " .. dcount .. " " .. L["Charges"] elseif t.checkCharges == false then a = a .. d .. dcount .. " " .. L["Or More"] .. " " .. L["Charges"] end
					end
				elseif tt == "Spell Casting" then
					if t.spell and t.spell ~= "" and IsOn(t.unit) then
						a = a .. string.format(" \"%s\"", t.spell) .. ", " .. L["Cast By"] .. " " .. unitList[t.unit]							
					end
				elseif tt == "Item Ready" then
					if t.item and t.item ~= "" then
						a = a .. string.format(" \"%s\"", t.item); d = ", "
						if t.toggle == false then a = a .. d .. L["Item Is Not Ready"] elseif t.toggle == true then a = a .. d .. L["Item Is Ready"] end
						local dcount = t.count
						if IsOff(dcount) then dcount = 1 end -- default value is 1
						if t.checkCount == true then a = a .. d .. L["Less Than"] .. " " .. dcount .. " " .. L["Count"] elseif t.checkCount == false then a = a .. d .. dcount .. " " .. L["Or More"] .. " " .. L["Count"] end
						local dcount = t.charges
						if IsOff(dcount) then dcount = 1 end -- default value is 1
						if t.checkCharges == true then a = a .. d .. L["Less Than"] .. " " .. dcount .. " " .. L["Charges"] elseif t.checkCharges == false then a = a .. d .. dcount .. " " .. L["Or More"] .. " " .. L["Charges"] end
					end
				end
				testString = testString .. at .. a -- add caption and clauses for current test
			end
		end
	end
	if IsOn(c.dependencies) then -- have a dependencies list
		local at = string.format(L["Dependencies String"])
		local a, d = "", " " -- a is string for current test conditions, d gets comma after first test clause added
		local i, list = 0, {} -- build a sorted list of dependencies
		for dep in pairs(c.dependencies) do
			i = i + 1
			list[i] = dep
		end
		table.sort(list)
		for _, dep in pairs(list) do
			local value, ctype = c.dependencies[dep], false
			if c.dependencyType then ctype = c.dependencyType[dep] end
			a = a .. d .. string.format("[%s] = ", dep)
			if value then a = a .. L["True Color String"] else a = a .. L["False Color String"] end
			a = a .. " (" .. (ctype and L["Or"] or L["And"]) .. ")"
			d = ", "
		end
		if a ~= "" then depString = depString .. at .. a end -- add caption and dependencies
	end
	if c.testLogic then logicString = string.format(L["Logic OR String"]) else logicString = string.format(L["Logic AND String"]) end
	if c.toggleResult then resultString = string.format(L["Toggle String"]) else resultString = string.format(L["No Toggle String"]) end
	if IsOn(c.setResult) then logicString = "" if c.setResult then resultString = L["Set Result True"] else resultString = L["Set Result False"] end end
	local value = MOD:CheckCondition(name)
	if value ~= nil then valueString = L["Current Value String"] .. (value and L["True"] or L["False"]) end
	return description .. testString .. depString .. logicString .. resultString .. valueString
end
