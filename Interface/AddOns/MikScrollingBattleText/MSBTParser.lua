-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Parser
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Parser"
MikSBT[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various functions for faster access.
local string_find = string.find
local string_gmatch = string.gmatch
local string_gsub = string.gsub
local string_len = string.len
local bit_band = bit.band
local bit_bor = bit.bor
local GetTime = GetTime
local UnitClass = UnitClass
local UnitGUID = UnitGUID
local Print = MikSBT.Print
local EraseTable = MikSBT.EraseTable


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

-- Bit flags.
local AFFILIATION_MINE		= 0x00000001
local AFFILIATION_PARTY		= 0x00000002
local AFFILIATION_RAID		= 0x00000004
local AFFILIATION_OUTSIDER	= 0x00000008
local REACTION_FRIENDLY		= 0x00000010
local REACTION_NEUTRAL		= 0x00000020
local REACTION_HOSTILE		= 0x00000040
local CONTROL_HUMAN			= 0x00000100
local CONTROL_SERVER		= 0x00000200
local UNITTYPE_PLAYER		= 0x00000400
local UNITTYPE_NPC			= 0x00000800
local UNITTYPE_PET			= 0x00001000
local UNITTYPE_GUARDIAN		= 0x00002000
local UNITTYPE_OBJECT		= 0x00004000
local TARGET_TARGET			= 0x00010000
local TARGET_FOCUS			= 0x00020000
local OBJECT_NONE			= 0x80000000

-- Value when there is no GUID.
local GUID_NONE				= "0x0000000000000000"

-- The maximum number of buffs and debuffs that can be on a unit.
local MAX_BUFFS = 16
local MAX_DEBUFFS = 40

-- Aura types.
local AURA_TYPE_BUFF = "BUFF"
local AURA_TYPE_DEBUFF = "DEBUFF"

-- Update timings.
local UNIT_MAP_UPDATE_DELAY = 0.2
local PET_UPDATE_DELAY = 1
local REFLECT_HOLD_TIME = 3
local CLASS_HOLD_TIME = 300

-- Commonly used flag combinations.
local FLAGS_ME			= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN, UNITTYPE_PLAYER)
local FLAGS_MINE		= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN)
local FLAGS_MY_GUARDIAN	= bit_bor(AFFILIATION_MINE, REACTION_FRIENDLY, CONTROL_HUMAN, UNITTYPE_GUARDIAN)


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Prevent tainting global _.
local _

-- Dynamically created frames for receiving events and tooltip info.
local eventFrame

-- Name and GUID of the player.
local playerName
local playerGUID

-- Used for timing between updates.
local lastUnitMapUpdate = 0
local lastPetMapUpdate = 0

-- Whether or not values that need to be updated after a delay are stale.
local isUnitMapStale
local isPetMapStale

-- Map of guids to unit ids.
local unitMap = {}
local petMap = {}

-- Map of functions to call for supported combat log events.
local captureFuncs

-- Events to parse even if the source or recipient is not the player or pet.
local fullParseEvents

-- Information about global strings for CHAT_MSG_X events.
local searchMap
local searchCaptureFuncs
local rareWords = {}
local searchPatterns = {}
local captureOrders = {}

-- Captured and parsed event data.
local captureTable = {}
local parserEvent = {}

-- List of functions to call when an event occurs.
local handlers = {}

-- Holds information about reflected skills to track how much was reflected.
local reflectedSkills = {}
local reflectedTimes = {}

-- Holds information about guid to class mappings for known units.
local classMapCleanupTime = 0
local classMap = {}
local classTimes = {}
local arenaUnits = {}


-------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Registers a function to be called when an event occurs.
-- ****************************************************************************
local function RegisterHandler(handler)
 handlers[handler] = true
end

-- ****************************************************************************
-- Unregisters a previously registered function.
-- ****************************************************************************
local function UnregisterHandler(handler)
 handlers[handler] = nil
end


-- ****************************************************************************
-- Tests if any of the bits in the passed testFlags are set in the unit flags.
-- ****************************************************************************
local function TestFlagsAny(unitFlags, testFlags)
 if (bit_band(unitFlags, testFlags) > 0) then return true end 
end


-- ****************************************************************************
-- Tests if all of the passed testFlags are set in the unit flags.
-- ****************************************************************************
local function TestFlagsAll(unitFlags, testFlags)
 if (bit_band(unitFlags, testFlags) == testFlags) then return true end
end


-- ****************************************************************************
-- Sends the parser event to the registered handlers.
-- ****************************************************************************
local function SendParserEvent()
 for handler in pairs(handlers) do
  local success, ret = pcall(handler, parserEvent)
  if (not success) then geterrorhandler()(ret) end
 end
end


-- ****************************************************************************
-- Compares two global strings so the most specific one comes first.  This
-- prevents incorrectly capturing information for certain events.
-- ****************************************************************************
local function GlobalStringCompareFunc(globalStringNameOne, globalStringNameTwo)
 -- Get the global string for the passed names.
 local globalStringOne = _G[globalStringNameOne]
 local globalStringTwo = _G[globalStringNameTwo]

 local gsOneStripped = string_gsub(globalStringOne, "%%%d?%$?[sd]", "")
 local gsTwoStripped = string_gsub(globalStringTwo, "%%%d?%$?[sd]", "")

 -- Check if the stripped global strings are the same length.
 if (string_len(gsOneStripped) == string_len(gsTwoStripped)) then
  -- Count the number of captures in each string.
  local numCapturesOne = 0
  for _ in string_gmatch(globalStringOne, "%%%d?%$?[sd]") do
   numCapturesOne = numCapturesOne + 1
  end

  local numCapturesTwo = 0
  for _ in string_gmatch(globalStringTwo, "%%%d?%$?[sd]") do
   numCapturesTwo = numCapturesTwo + 1
  end
  
  -- Return the global string with the least captures.
  return numCapturesOne < numCapturesTwo

 else
  -- Return the longest global string.
  return string_len(gsOneStripped) > string_len(gsTwoStripped)
 end
end


-- ****************************************************************************
-- Converts the passed global string into a lua search pattern with a capture
-- order table and stores the results so any requests to convert the same
-- global string will just return the cached one.
-- ****************************************************************************
local function ConvertGlobalString(globalStringName)
 -- Don't do anything if the passed global string does not exist.
 local globalString = _G[globalStringName]
 if (globalString == nil) then return end

 -- Return the cached conversion if it has already been converted.
 if (searchPatterns[globalStringName]) then
  return searchPatterns[globalStringName], captureOrders[globalStringName]
 end

 -- Hold the capture order.
 local captureOrder
 local numCaptures = 0

 -- Escape lua magic chars.
 local searchPattern = string.gsub(globalString, "([%^%(%)%.%[%]%*%+%-%?])", "%%%1")

 -- Loop through each capture and setup the capture order.
 for captureIndex in string_gmatch(searchPattern, "%%(%d)%$[sd]") do
  if (not captureOrder) then captureOrder = {} end
  numCaptures = numCaptures + 1
  captureOrder[tonumber(captureIndex)] = numCaptures
 end
 
 -- Convert %1$s / %s to (.+) and %1$d / %d to (%d+).
 searchPattern = string.gsub(searchPattern, "%%%d?%$?s", "(.+)")
 searchPattern = string.gsub(searchPattern, "%%%d?%$?d", "(%%d+)")

 -- Escape any remaining $ chars.
 searchPattern = string.gsub(searchPattern, "%$", "%%$")
 
 -- Cache the converted pattern and capture order.
 searchPatterns[globalStringName] = searchPattern
 captureOrders[globalStringName] = captureOrder

 -- Return the converted global string.
 return searchPattern, captureOrder
end


-- ****************************************************************************
-- Fills in the capture table with the captured data if a match is found.
-- ****************************************************************************
local function CaptureData(matchStart, matchEnd, c1, c2, c3, c4, c5, c6, c7, c8, c9)
 -- Check if a match was found.
 if (matchStart) then
  captureTable[1] = c1
  captureTable[2] = c2
  captureTable[3] = c3
  captureTable[4] = c4
  captureTable[5] = c5
  captureTable[6] = c6
  captureTable[7] = c7
  captureTable[8] = c8
  captureTable[9] = c9

  -- Return the last position of the match.
  return matchEnd
 end

 -- Don't return anything since no match was found.
 return nil
end


-- ****************************************************************************
-- Reorders the capture table according to the passed capture order.
-- ****************************************************************************
local function ReorderCaptures(capOrder)
 local t, o = captureTable, capOrder
 
 t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8], t[9] = 
 t[o[1] or 1], t[o[2] or 2], t[o[3] or 3], t[o[4] or 4], t[o[5] or 5],
 t[o[6] or 6], t[o[7] or 7], t[o[8] or 8], t[o[9] or 9]
end


-- ****************************************************************************
-- Parses the CHAT_MSG_X search style events.
-- ****************************************************************************
local function ParseSearchMessage(event, combatMessage)
 -- Leave if there is no map of global strings to search for the event.
 if (not searchMap[event]) then return end

 -- Loop through all of the global strings to search for the event.
 for _, globalStringName in pairs(searchMap[event]) do
  -- Make sure the capture func for the global string exists.
  local captureFunc = searchCaptureFuncs[globalStringName]
  if (captureFunc) then
   -- First, check if there is a rare word for the global string and it is in the combat
   -- message since a plain text search is faster than doing a full regular expression search.
   if (not rareWords[globalStringName] or string_find(combatMessage, rareWords[globalStringName], 1, true)) then
    -- Get capture data.
    local matchEnd = CaptureData(string_find(combatMessage, searchPatterns[globalStringName]))
  

    -- Check if a match was found. 
    if (matchEnd) then
     -- Check if there is a capture order for the global string and reorder the data accordingly.
     if (captureOrders[globalStringName]) then ReorderCaptures(captureOrders[globalStringName]) end

     -- Erase the parser event table..
     for key in pairs(parserEvent) do parserEvent[key] = nil end

     -- Populate fields that exist for all events.
     parserEvent.sourceGUID = GUID_NONE
     parserEvent.sourceFlags = OBJECT_NONE
     parserEvent.recipientGUID = playerGUID
     parserEvent.recipientName = playerName
     parserEvent.recipientFlags = FLAGS_ME
     parserEvent.recipientUnit = "player"
	 
     -- Map the captured arguments into the parser event table.
     captureFunc(parserEvent, captureTable)

     -- Send the event.
     SendParserEvent()
     return
    end -- Match found.
   end -- Fast plain search.
  end -- Capture func is valid.
 end -- Loop through global strings to search. 
end


-- ****************************************************************************
-- Parses the parameter style events going to the combat log.
-- ****************************************************************************
local function ParseLogMessage(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, recipientGUID, recipientName, recipientFlags, recipientRaidFlags, ...)
 -- Make sure the capture function for the event exists.
 local captureFunc = captureFuncs[event]
 if (not captureFunc) then return end

 -- Look for spells the player reflected and make the damage belong to the player.
 if (sourceGUID == recipientGUID and reflectedTimes[recipientGUID] and event == "SPELL_DAMAGE") then
  local skillID = ...
  if (skillID == reflectedSkills[recipientGUID]) then
   -- Clear the reflected skill entries.
   reflectedTimes[recipientGUID] = nil
   reflectedSkills[recipientGUID] = nil

   -- Change the source to the player.
   sourceGUID = playerGUID
   sourceName = playerName
   sourceFlags = FLAGS_ME
  end
 end

 -- Attempt to figure out the source and recipient unitIDs.
 local sourceUnit = unitMap[sourceGUID] or petMap[sourceGUID]
 local recipientUnit = unitMap[recipientGUID] or petMap[recipientGUID]

 -- Treat guardians that are flagged as belonging to the player as their pet and vehicles and other objects as the player.
 if (not sourceUnit and TestFlagsAll(sourceFlags, FLAGS_MINE)) then sourceUnit = TestFlagsAll(sourceFlags, FLAGS_MY_GUARDIAN) and "pet" or "player" end
 if (not recipientUnit and TestFlagsAll(recipientFlags, FLAGS_MINE)) then recipientUnit = TestFlagsAll(recipientFlags, FLAGS_MY_GUARDIAN) and "pet" or "player" end
 
  -- Ignore the event if it is not one that should be fully parsed and it doesn't pertain to the player
 -- or pet.  This is done to avoid wasting time parsing events that won't be used like damage that other
 -- players are doing.
 if (not fullParseEvents[event] and sourceUnit ~= "player" and sourceUnit ~= "pet" and
     recipientUnit ~= "player" and recipientUnit ~= "pet") then
  return
 end

 -- Erase the parser event table.
 for k in pairs(parserEvent) do parserEvent[k] = nil end

 -- Populate fields that exist for all events.
 parserEvent.sourceGUID = sourceGUID
 parserEvent.sourceName = sourceName
 parserEvent.sourceFlags = sourceFlags
 parserEvent.sourceUnit = sourceUnit
 parserEvent.recipientGUID = recipientGUID
 parserEvent.recipientName = recipientName
 parserEvent.recipientFlags = recipientFlags 
 parserEvent.recipientUnit = recipientUnit
 
 -- Map the local arguments into the parser event table.
 captureFunc(parserEvent, ...)

 -- Track reflected skills.
 if (parserEvent.eventType == "miss" and parserEvent.missType == "REFLECT" and recipientUnit == "player") then
  -- Clean up old entries.
  for guid, reflectTime in pairs(reflectedTimes) do
   if (timestamp - reflectTime > REFLECT_HOLD_TIME) then
    reflectedTimes[guid] = nil
    reflectedSkills[guid] = nil
   end
  end

  -- Save the time of the reflect and the reflected skillID.
  reflectedTimes[sourceGUID] = timestamp
  reflectedSkills[sourceGUID] = parserEvent.skillID
 end
 
 -- Send the event.
 SendParserEvent()
end


-------------------------------------------------------------------------------
-- Startup utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates a list of events that will be fully parsed even if they event
-- doesn't pertain to the player or player's pet.
-- ****************************************************************************
local function CreateFullParseList()
 fullParseEvents = {
  SPELL_AURA_APPLIED = true,
  SPELL_AURA_REMOVED = true,
  SPELL_AURA_APPLIED_DOSE = true,
  SPELL_AURA_REMOVED_DOSE = true,
  SPELL_CAST_START = true,
 }
end


-- ****************************************************************************
-- Creates a map of global strings to search for CHAT_MSG_X events.
-- ****************************************************************************
local function CreateSearchMap()
 searchMap = {
  -- Honor Gains.
  CHAT_MSG_COMBAT_HONOR_GAIN = {"COMBATLOG_HONORGAIN", "COMBATLOG_HONORAWARD"},

  -- Reputation Gains/Losses.
  CHAT_MSG_COMBAT_FACTION_CHANGE = {"FACTION_STANDING_INCREASED", "FACTION_STANDING_DECREASED"},

  -- Skill Gains.
  CHAT_MSG_SKILL = {"SKILL_RANK_UP"},

  -- Experience Gains.
  CHAT_MSG_COMBAT_XP_GAIN = {"COMBATLOG_XPGAIN_FIRSTPERSON", "COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED"},

  -- Looted Items.
  CHAT_MSG_LOOT = {
   "LOOT_ITEM_CREATED_SELF_MULTIPLE", "LOOT_ITEM_CREATED_SELF", "LOOT_ITEM_PUSHED_SELF_MULTIPLE",
   "LOOT_ITEM_PUSHED_SELF", "LOOT_ITEM_SELF_MULTIPLE", "LOOT_ITEM_SELF"
  },
  
  -- Money.
  CHAT_MSG_MONEY = {"YOU_LOOT_MONEY", "LOOT_MONEY_SPLIT"},

  -- Currency.
  CHAT_MSG_CURRENCY = { "CURRENCY_GAINED", "CURRENCY_GAINED_MULTIPLE", "CURRENCY_GAINED_MULTIPLE_BONUS" },
 }


 -- Loop through each of the events.
 for event, map in pairs(searchMap) do
  -- Remove invalid global strings.
  for i = #map, 1, -1 do
   if (not _G[map[i]]) then table.remove(map, i) end
  end

  -- Sort the global strings from most to least specific.
  table.sort(map, GlobalStringCompareFunc)
 end
end


-- ****************************************************************************
-- Creates a map of capture functions for supported global strings.
-- ****************************************************************************
local function CreateSearchCaptureFuncs()
 searchCaptureFuncs = {
  -- Honor events.
  COMBATLOG_HONORAWARD = function (p, c) p.eventType, p.amount = "honor", c[1] end,
  COMBATLOG_HONORGAIN = function (p, c) p.eventType, p.sourceName, p.sourceRank, p.amount = "honor", c[1], c[2], c[3] end,

  -- Experience events.
  COMBATLOG_XPGAIN_FIRSTPERSON = function (p, c) p.eventType, p.sourceName, p.amount = "experience", c[1], c[2] end,
  COMBATLOG_XPGAIN_FIRSTPERSON_UNNAMED = function (p, c) p.eventType, p.amount = "experience", c[1] end,

  -- Reputation events.
  FACTION_STANDING_DECREASED = function (p, c) p.eventType, p.isLoss, p.factionName, p.amount = "reputation", true, c[1], c[2] end,
  FACTION_STANDING_INCREASED = function (p, c) p.eventType, p.factionName, p.amount = "reputation", c[1], c[2] end,

  -- Proficiency events.
  SKILL_RANK_UP = function (p, c) p.eventType, p.skillName, p.amount = "proficiency", c[1], c[2] end,

  -- Loot events.
  LOOT_ITEM_SELF = function (p, c) p.eventType, p.itemLink, p.amount = "loot", c[1], c[2] end,
  LOOT_ITEM_CREATED_SELF = function (p, c) p.eventType, p.isCreate, p.itemLink, p.amount = "loot", true, c[1], c[2] end,
  LOOT_MONEY_SPLIT = function (p, c) p.eventType, p.isMoney, p.moneyString = "loot", true, c[1] end,
  CURRENCY_GAINED = function (p, c) p.eventType, p.isCurrency, p.itemLink, p.amount = "loot", true, c[1], c[2] end,
 }

 searchCaptureFuncs["LOOT_ITEM_SELF_MULTIPLE"] = searchCaptureFuncs["LOOT_ITEM_SELF"]
 searchCaptureFuncs["LOOT_ITEM_CREATED_SELF_MULTIPLE"] = searchCaptureFuncs["LOOT_ITEM_CREATED_SELF"]
 searchCaptureFuncs["LOOT_ITEM_PUSHED_SELF"] = searchCaptureFuncs["LOOT_ITEM_CREATED_SELF"]
 searchCaptureFuncs["LOOT_ITEM_PUSHED_SELF_MULTIPLE"] = searchCaptureFuncs["LOOT_ITEM_CREATED_SELF"]
 searchCaptureFuncs["YOU_LOOT_MONEY"] = searchCaptureFuncs["LOOT_MONEY_SPLIT"]
 searchCaptureFuncs["CURRENCY_GAINED_MULTIPLE"] = searchCaptureFuncs["CURRENCY_GAINED"]
 searchCaptureFuncs["CURRENCY_GAINED_MULTIPLE_BONUS"] = searchCaptureFuncs["CURRENCY_GAINED"]

 -- Print an error message for each global string that isn't found and remove it from the map.
 for globalStringName in pairs(searchCaptureFuncs) do
  if (not _G[globalStringName]) then
   Print("Unable to find global string: " .. globalStringName, 1, 0, 0)
   searchCaptureFuncs[globalStringName] = nil
  end
 end
end


-- ****************************************************************************
-- Finds the rarest word for each global string.
-- ****************************************************************************
local function FindRareWords()
 -- Hold the number of times each word appears in all the global strings.
 local wordCounts = {}

 -- Loop through all of the supported global strings.
 for globalStringName in pairs(searchCaptureFuncs) do
  -- Strip out all of the formatting codes.
  local strippedGS = string.gsub(_G[globalStringName], "%%%d?%$?[sd]", "")

  -- Count how many times each word appears in the global string.
  for word in string_gmatch(strippedGS, "%w+") do
   wordCounts[word] = (wordCounts[word] or 0) + 1
  end
 end


 -- Loop through all of the supported global strings.
 for globalStringName in pairs(searchCaptureFuncs) do
  local leastSeen, rarestWord

  -- Strip out all of the formatting codes.
  local strippedGS = string.gsub(_G[globalStringName], "%%%d?%$?[sd]", "")

  -- Find the rarest word in the global string.
  for word in string_gmatch(strippedGS, "%w+") do
   if (not leastSeen or wordCounts[word] < leastSeen) then
    leastSeen = wordCounts[word]
    rarestWord = word
   end
  end

  -- Set the rarest word.
  rareWords[globalStringName] = rarestWord
 end
end


-- ****************************************************************************
-- Validates rare words to make sure there are no oddities caused by various
-- languages. 
-- ****************************************************************************
local function ValidateRareWords()
 -- Loop through all of the global strings there is a rare word entry for.
 for globalStringName, rareWord in pairs(rareWords) do
  -- Remove the entry if the rare word isn't found in the associated global string.
  if (not string_find(_G[globalStringName], rareWord, 1, true)) then
   rareWords[globalStringName] = nil
  end
 end
end


-- ****************************************************************************
-- Converts all of the supported global strings.
-- ****************************************************************************
local function ConvertGlobalStrings()
 -- Loop through all of the supported global strings.
 for globalStringName in pairs(searchCaptureFuncs) do
  -- Get the global string converted to a lua search pattern and prepend an anchor to
  -- speed up searching.
  searchPatterns[globalStringName] = "^" .. ConvertGlobalString(globalStringName)
 end
end


-- ****************************************************************************
-- Creates a map of capture functions for each supported combat log event.
-- ****************************************************************************
local function CreateCaptureFuncs()
 captureFuncs = {
  -- Damage events.
  SWING_DAMAGE = function (p, ...) p.eventType, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing = "damage", ... end,
  RANGE_DAMAGE = function (p, ...) p.eventType, p.isRange, p.skillID, p.skillName, p.skillSchool, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing, p.isOffHand = "damage", true, ... end,
  SPELL_DAMAGE = function (p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing, p.isOffHand = "damage", ... end,
  SPELL_PERIODIC_DAMAGE = function (p, ...) p.eventType, p.isDoT, p.skillID, p.skillName, p.skillSchool, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing, p.isOffHand = "damage", true, ... end,
  SPELL_BUILDING_DAMAGE = function (p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing = "damage", ... end,
  DAMAGE_SHIELD = function (p, ...) p.eventType, p.isDamageShield, p.skillID, p.skillName, p.skillSchool, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing = "damage", true, ... end,
  --SPELL_ABSORBED = function (p, ...) p.eventType, p.amount, p.skillID, p.skillName, p.skillSchool, p.absorbAmount = "damage", 0, ... end,
  --[[SPELL_ABSORBED = function (p, ...)
   --[dmgSpellID, dmgSpellName, dmgSpellSchool,] absorberGUID, absorberName, absorberFlags, absorberRaidFlags, absorbSkillID, absorbSkillName, absorbSkillSchool, absorbAmount
   local offset = 5
   if type(...) == "number" then offset = 8 end -- 1st param is spellID and not a GUID
    p.eventType, p.amount, p.skillID, p.skillName, p.skillSchool, p.absorbAmount = "damage", 0, select(offset, ...)
   end,]]

  -- Miss events.
  SWING_MISSED = function (p, ...) p.eventType, p.missType, p.isOffHand, p.amount = "miss", ... end,
  RANGE_MISSED = function (p, ...) p.eventType, p.isRange, p.skillID, p.skillName, p.skillSchool, p.missType, p.isOffHand, p.amount = "miss", true, ... end,
  SPELL_MISSED = function (p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.missType, p.isOffHand, p.amount = "miss", ... end,
  SPELL_PERIODIC_MISSED = function (p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.missType, p.isOffHand, p.amount = "miss", ... end,
  DAMAGE_SHIELD_MISSED = function (p, ...) p.eventType, p.isDamageShield, p.skillID, p.skillName, p.skillSchool, p.missType, p.isOffHand, p.amount = "miss", true, ... end,
  SPELL_DISPEL_FAILED = function (p, ...) p.eventType, p.missType, p.skillID, p.skillName, p.skillSchool, p.extraSkillID, p.extraSkillName, p.extraSkillSchool = "miss", "RESIST", ... end,

  -- Heal events.
  SPELL_HEAL = function (p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.amount, p.overhealAmount, p.absorbAmount, p.isCrit = "heal", ... end,
  SPELL_PERIODIC_HEAL = function (p, ...) p.eventType, p.isHoT, p.skillID, p.skillName, p.skillSchool, p.amount, p.overhealAmount, p.absorbAmount, p.isCrit = "heal", true, ... end,
  
  -- Environmental events.
  ENVIRONMENTAL_DAMAGE = function (p, ...) p.eventType, p.hazardType, p.amount, p.overkillAmount, p.damageType, p.resistAmount, p.blockAmount, p.absorbAmount, p.isCrit, p.isGlancing, p.isCrushing = "environmental", ... end,

  -- Power events.
  SPELL_ENERGIZE = function (p, ...) p.eventType, p.isGain, p.skillID, p.skillName, p.skillSchool, p.amount, p.powerType = "power", true, ... end,
  SPELL_DRAIN = function (p, ...) p.eventType, p.isDrain, p.skillID, p.skillName, p.skillSchool, p.amount, p.powerType, p.extraAmount = "power", true, ... end,
  SPELL_LEECH = function (p, ...) p.eventType, p.isLeech, p.skillID, p.skillName, p.skillSchool, p.amount, p.powerType, p.extraAmount = "power", true, ... end,

  -- Interrupt events.
  SPELL_INTERRUPT = function (p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.extraSkillID, p.extraSkillName, p.extraSkillSchool = "interrupt", ... end,
  
  -- Aura events.
  SPELL_AURA_APPLIED = function (p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.auraType, p.amount = "aura", ... end,
  SPELL_AURA_APPLIED_DOSE = function (p, ...) p.eventType, p.isDose, p.skillID, p.skillName, p.skillSchool, p.auraType, p.amount = "aura", true, ... end,
  SPELL_AURA_REMOVED = function (p, ...) p.eventType, p.isFade, p.skillID, p.skillName, p.skillSchool, p.auraType, p.amount = "aura", true, ... end,
  SPELL_AURA_REMOVED_DOSE = function (p, ...) p.eventType, p.isFade, p.isDose, p.skillID, p.skillName, p.skillSchool, p.auraType, p.amount = "aura", true, true, ... end,

  -- Enchant events.
  ENCHANT_APPLIED = function (p, ...) p.eventType, p.skillName, p.itemID, p.itemName = "enchant", ... end,
  ENCHANT_REMOVED = function (p, ...) p.eventType, p.isFade, p.skillName, p.itemID, p.itemName = "enchant", true, ... end,
  
  -- Dispel events.
  SPELL_DISPEL = function (p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.extraSkillID, p.extraSkillName, p.extraSkillSchool, p.auraType = "dispel", ... end,

  -- Cast events.
  SPELL_CAST_START = function (p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool = "cast", ... end,

  -- Kill events.
  PARTY_KILL = function (p, ...) p.eventType = "kill" end,
  
  -- Extra Attack events.
  SPELL_EXTRA_ATTACKS = function (p, ...) p.eventType, p.skillID, p.skillName, p.skillSchool, p.amount = "extraattacks", ... end,
 }

 captureFuncs["DAMAGE_SPLIT"] = captureFuncs["SPELL_DAMAGE"]
 captureFuncs["SPELL_PERIODIC_MISSED"] = captureFuncs["SPELL_MISSED"]
 captureFuncs["SPELL_PERIODIC_ENERGIZE"] = captureFuncs["SPELL_ENERGIZE"]
 captureFuncs["SPELL_PERIODIC_DRAIN"] = captureFuncs["SPELL_DRAIN"]
 captureFuncs["SPELL_PERIODIC_LEECH"] = captureFuncs["SPELL_LEECH"]
 captureFuncs["SPELL_STOLEN"] = captureFuncs["SPELL_DISPEL"]

 -- Expose the capture functions.
 module.captureFuncs = captureFuncs
end


-------------------------------------------------------------------------------
-- Event handlers.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when there is information that needs to be obtained after a delay.
-- ****************************************************************************
local function OnUpdateDelayedInfo(this, elapsed)
 -- Check if the unit map needs to be updated after a delay.
 if (isUnitMapStale) then
  -- Increment the amount of time passed since the last update.
  lastUnitMapUpdate = lastUnitMapUpdate + elapsed

  -- Check if it's time for an update.
  if (lastUnitMapUpdate >= UNIT_MAP_UPDATE_DELAY) then
   -- Update the player GUID if it isn't known yet and verify it's now known.
   if (not playerGUID) then playerGUID = UnitGUID("player") end
   if (playerGUID) then
    -- Erase the unit map table and mark all old units for cleanup from the class map.
    local now = GetTime()
    for guid in pairs(unitMap) do
     unitMap[guid] = nil
     classTimes[guid] = now + CLASS_HOLD_TIME
    end

    -- Loop through all of the group members and add them and their class to the maps.
    local unitPrefix = IsInRaid() and "raid" or "party"
    local numGroupMembers = GetNumGroupMembers()
    for i = 1, numGroupMembers do
     local unitID = unitPrefix .. i
     -- XXX: This call is returning nil for party members in certain circumstances - need to debug further.
     local guid = UnitGUID(unitID)
     if (guid ~= nil) then
      unitMap[guid] = unitID
      if (not classMap[guid]) then _, classMap[guid] = UnitClass(unitID) end
      classTimes[guid] = nil
     end
    end -- Loop through group members

    -- Add the player and player's class to the maps.
    unitMap[playerGUID] = "player"
    if (not classMap[playerGUID]) then _, classMap[playerGUID] = UnitClass("player") end
    classTimes[playerGUID] = nil
   
    -- Clear the unit map stale flag.
    isUnitMapStale = false
   end

   -- Reset the time since last update.
   lastUnitMapUpdate = 0
  end
 end -- Unit map is stale.

 -- Check if the pet map needs to be updated after a delay.
 if (isPetMapStale) then
  -- Increment the amount of time passed since the last update.
  lastPetMapUpdate = lastPetMapUpdate + elapsed
  
  -- Check if it's time for an update.
  if (lastPetMapUpdate >= PET_UPDATE_DELAY) then
   -- Verify the player's pet is not in an unknown state if there is one.
   local petName = UnitName("pet")
   if (not petName or petName ~= UNKNOWN) then
    -- Erase the pet map table and mark all old units for cleanup from the class map.
    local now = GetTime()
    for guid in pairs(petMap) do
     petMap[guid] = nil
     classTimes[guid] = now + CLASS_HOLD_TIME
    end

     -- Loop through all of the group members and add their pets and pet's class to the maps.
    local unitPrefix = IsInRaid() and "raidpet" or "partypet"
    local numGroupMembers = GetNumGroupMembers()
    for i = 1, numGroupMembers do
     local unitID = unitPrefix .. i
     if (UnitExists(unitID)) then
      -- XXX: This call is returning nil for party members in certain circumstances - need to debug further.
      local guid = UnitGUID(unitID)
      if (guid ~= nil) then
       petMap[guid] = unitID
       if (not classMap[guid]) then _, classMap[guid] = UnitClass(unitID) end
       classTimes[guid] = nil
      end
     end
    end -- Loop through group members

    -- Add the player's pet and its class if there is one.  Treat vehicles as the player instead of a pet.
    if (petName) then
     local unitID = "pet"
     local guid = UnitGUID(unitID)
     if (guid == UnitGUID("vehicle")) then unitID = "player" end
     petMap[guid] = unitID
     if (not classMap[guid]) then _, classMap[guid] = UnitClass(unitID) end
     classTimes[guid] = nil
    end

    -- Clear the pet map stale flag.
    isPetMapStale = false
   end -- Pet in known state.

   -- Reset the time since last update.
   lastPetMapUpdate = 0
  end
 end -- Pet map is stale.

 -- Stop receiving updates if no more data needs to be updated.
 if (not isUnitMapStale and not isPetMapStale) then this:Hide() end
end


-- ****************************************************************************
-- Called when the events the parser registered for occur.
-- ****************************************************************************
local function OnEvent(this, event, arg1, arg2, ...)
 -- Combat log events.
 if (event == "COMBAT_LOG_EVENT_UNFILTERED") then
  ParseLogMessage(arg1, arg2, ...)

 -- Mouseover changes.
 elseif (event == "UPDATE_MOUSEOVER_UNIT") then
  -- Map the GUID for the moused over unit to a class.
  local mouseoverGUID = UnitGUID("mouseover")
  if (not mouseoverGUID) then return end

  -- Ignore the GUID if its class is already known and there is no cleanup time for it.
  if (classMap[mouseoverGUID] and not classTimes[mouseoverGUID]) then return end

  -- Update the cleanup time for the GUID and map it to a class if it's not already known.
  classTimes[mouseoverGUID] = GetTime() + CLASS_HOLD_TIME
  if (not classMap[mouseoverGUID]) then _, classMap[mouseoverGUID] = UnitClass("mouseover") end

 -- Target changes.
 elseif (event == "PLAYER_TARGET_CHANGED") then
  -- Map the GUID for the target unit to a class.
  local targetGUID = UnitGUID("target")
  if (not targetGUID) then return end

  -- Ignore the GUID if its class is already known and there is no cleanup time for it.
  if (classMap[targetGUID] and not classTimes[targetGUID]) then return end

  -- Update the cleanup time for the GUID and map it to a class if it's not already known.
  local now = GetTime()
  classTimes[targetGUID] = now + CLASS_HOLD_TIME
  if (not classMap[targetGUID]) then _, classMap[targetGUID] = UnitClass("target") end

  -- Loop through all of the recent guid to class mappings and remove the old ones if enough time has passed.
  if (now >= classMapCleanupTime) then
   for guid, cleanupTime in pairs(classTimes) do
    if (now >= cleanupTime) then classMap[guid] = nil classTimes[guid] = nil end
   end

   classMapCleanupTime = now + CLASS_HOLD_TIME
  end -- Time to clean up class map.

 -- Party/Raid changes.
 elseif (event == "GROUP_ROSTER_UPDATE") then
  -- Set the unit map stale flag and schedule the unit map to be updated after a short delay.
  isUnitMapStale = true
  eventFrame:Show()

 -- Pet changes.
 elseif (event == "UNIT_PET") then
  isPetMapStale = true
  eventFrame:Show()

 -- Arena opponent changes.
 elseif (event == "ARENA_OPPONENT_UPDATE") then
  -- Map the unit id and GUID for an arena unit to a class when it's seen.
  if (arg2 == "seen") then
   local arenaGUID = UnitGUID(arg1)
   if (not arenaGUID) then return end
   arenaUnits[arg1] = arenaGUID
   _, classMap[arenaGUID] = UnitClass(arg1)

  -- Remove the mappings for an arena unit when it's cleared.
  elseif (arg2 == "cleared") then
   local arenaGUID = arenaUnits[arg1]
   if (not arenaGUID) then return end
   arenaUnits[arg1] = nil
   classMap[arenaGUID] = nil
  end

 -- Chat message combat events.
 else
  ParseSearchMessage(event, arg1)
 end
end


-- ****************************************************************************
-- Enables parsing.
-- ****************************************************************************
local function Enable()
 -- Register for parameter style events going to the combat log.
 eventFrame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
 
 -- Register CHAT_MSG_X search style events.
 for event in pairs(searchMap) do
  eventFrame:RegisterEvent(event)
 end

 -- Register additional events for unit and class map processing.
 eventFrame:RegisterEvent("GROUP_ROSTER_UPDATE")
 eventFrame:RegisterEvent("UNIT_PET") 
 eventFrame:RegisterEvent("ARENA_OPPONENT_UPDATE")
 eventFrame:RegisterEvent("PLAYER_TARGET_CHANGED")
 eventFrame:RegisterEvent("UPDATE_MOUSEOVER_UNIT")

 -- Update the unit map and current pet information.
 isUnitMapStale = true
 isPetMapStale = true

 -- Start receiving updates.
 eventFrame:Show()
end


-- ****************************************************************************
-- Disables the parsing.
-- ****************************************************************************
local function Disable()
 -- Stop receiving updates.
 eventFrame:Hide()
 eventFrame:UnregisterAllEvents()
 
 -- Erase the reflected skill tables.
 EraseTable(reflectedTimes)
 EraseTable(reflectedSkills)
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

-- Create a frame to receive events.
eventFrame = CreateFrame("Frame")
eventFrame:Hide()
eventFrame:SetScript("OnEvent", OnEvent)
eventFrame:SetScript("OnUpdate", OnUpdateDelayedInfo)

-- Get the name, GUID, and class of the player.
playerName = UnitName("player")
playerGUID = UnitGUID("player")
 
-- Create various maps.
CreateSearchMap()
CreateSearchCaptureFuncs()
CreateCaptureFuncs()
 
-- Create the list of events that should be fully parsed.
CreateFullParseList()

-- Find the rarest word for each supported global string.
FindRareWords()
ValidateRareWords()

-- Convert the supported global strings into lua search patterns.
ConvertGlobalStrings()




-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Constants.
module.AFFILIATION_MINE		= AFFILIATION_MINE
module.AFFILIATION_PARTY	= AFFILIATION_PARTY
module.AFFILIATION_RAID		= AFFILIATION_RAID
module.AFFILIATION_OUTSIDER	= AFFILIATION_OUTSIDER
module.REACTION_FRIENDLY	= REACTION_FRIENDLY
module.REACTION_NEUTRAL		= REACTION_NEUTRAL
module.REACTION_HOSTILE		= REACTION_HOSTILE
module.CONTROL_HUMAN		= CONTROL_HUMAN
module.CONTROL_SERVER		= CONTROL_SERVER
module.UNITTYPE_PLAYER		= UNITTYPE_PLAYER
module.UNITTYPE_NPC			= UNITTYPE_NPC
module.UNITTYPE_PET			= UNITTYPE_PET
module.UNITTYPE_GUARDIAN	= UNITTYPE_GUARDIAN
module.UNITTYPE_OBJECT		= UNITTYPE_OBJECT
module.TARGET_TARGET		= TARGET_TARGET
module.TARGET_FOCUS			= TARGET_FOCUS
module.OBJECT_NONE			= OBJECT_NONE

-- Protected Variables.
module.unitMap = unitMap
module.classMap = classMap

-- Protected Functions.
module.RegisterHandler				= RegisterHandler
module.UnregisterHandler			= UnregisterHandler
module.TestFlagsAny					= TestFlagsAny
module.TestFlagsAll					= TestFlagsAll
module.Enable						= Enable
module.Disable						= Disable