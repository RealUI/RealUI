-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Triggers
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Triggers"
MikSBT[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various modules for faster access.
local MSBTProfiles = MikSBT.Profiles
local MSBTParser = MikSBT.Parser

-- Get local references to various functions for faster access.
local string_find = string.find
local string_gsub = string.gsub
local string_format = string.format
local string_gmatch = string.gmatch
local GetSpellInfo = GetSpellInfo
local Print = MikSBT.Print
local EraseTable = MikSBT.EraseTable
local DisplayEvent = MikSBT.Animations.DisplayEvent
local TestFlagsAny = MSBTParser.TestFlagsAny
local ShortenNumber = MikSBT.ShortenNumber
local SeparateNumber = MikSBT.SeparateNumber

-- Local reference to various variables for faster access.
local REACTION_HOSTILE = MSBTParser.REACTION_HOSTILE
local unitMap = MSBTParser.unitMap
local classMap = MSBTParser.classMap



-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

-- Special flag to indicate the player.
local FLAG_YOU = 0xF0000000

-- Max group sizes.
local MAX_PARTY_MEMBERS = 5
local MAX_RAID_MEMBERS = 40


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Prevent tainting global _.
local _

-- Holds dynamically created frame for receiving events.
local eventFrame

-- Holds the player's name, GUID, and class.
local playerName, playerGUID, playerClass

-- Events the triggers use.
local listenEvents = {}

-- Functions to handle combat log events and conditions.
local captureFuncs
local testFuncs
local eventConditionFuncs
local exceptionConditionFuncs

-- Holds triggers in a format optimized for searching.
local categorizedTriggers = {}
local triggerExceptions = {}
local parserEvent = {}
local lookupTable = {}

-- Information about triggers used for condition checking.
local lastPercentages = {}
local lastPowerTypes = {}
local firedTimes = {}
local triggersToFire = {}

-- Hold buffs and debuffs that should be suppressed since there is a trigger for them.
local triggerSuppressions = {}
 
-- Supported power types given a power token.
local powerTypes = {}


-------------------------------------------------------------------------------
-- Trigger utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Returns whether or not the passed spell name is unavailable.
-- ****************************************************************************
local function IsSkillUnavailable(skillName)
 -- Pass if there is no skill to check.
 if (not skillName or skillName == "") then return true end

 -- Pass if the skill isn't known.
 if (not GetSpellInfo(skillName)) then return true end

 -- Pass check if the skillName is cooling down (but ignore the global cooldown).
 local start, duration = GetSpellCooldown(skillName)
 if (start > 0 and duration > 1.5) then return true end
end


-- ****************************************************************************
-- Creates a map of test functions for supported test types.
-- ****************************************************************************
local function CreateTestFuncs()
 testFuncs = {
  eq = function(l, r) return l == r end,
  ne = function(l, r) return l ~= r end,
  like = function(l, r) return type(l)=="string" and type(r)=="string" and string_find(l, r) end,
  unlike = function(l, r) return type(l)=="string" and type(r)=="string" and not string_find(l, r) end,
  lt = function(l, r) return type(l)=="number" and type(r)=="number" and l < r end,
  gt = function(l, r) return type(l)=="number" and type(r)=="number" and l > r end,
}
end


-- ****************************************************************************
-- Creates a map of capture functions for supported combat log events.
-- Also makes use of the ones already defined in the parser module.
-- ****************************************************************************
local function CreateCaptureFuncs()
 captureFuncs = {
  -- Leave out eventType because we really don't care about it for triggers.
  SPELL_AURA_BROKEN_SPELL = function (p, ...) p.skillID, p.skillName, p.skillSchool, p.extraSkillID, p.extraSkillName, p.extraSkillSchool, p.auraType = ... end,
  SPELL_AURA_REFRESH = function (p, ...) p.skillID, p.skillName, p.skillSchool, p.auraType = ... end,
  SPELL_CAST_SUCCESS = function (p, ...) p.skillID, p.skillName, p.skillSchool = ... end,
  SPELL_CAST_FAILED = function (p, ...) p.skillID, p.skillName, p.skillSchool, p.missType = ... end,
  SPELL_SUMMON = function (p, ...) p.skillID, p.skillName, p.skillSchool = ... end,
  SPELL_CREATE = function (p, ...) p.skillID, p.skillName, p.skillSchool = ... end,
  UNIT_DIED = function (p, ...) end,
  UNIT_DESTROYED = function (p, ...) end,
 }

 -- Make use of the parser module capture functions instead of redefining them.
 captureFuncs.__index = MSBTParser.captureFuncs
 setmetatable(captureFuncs, captureFuncs)
end


-- ****************************************************************************
-- Creates maps of functions for supported conditions.
-- ****************************************************************************
local function CreateConditionFuncs()
 -- Event conditions.
 eventConditionFuncs = {
  -- Source unit.
  sourceName = function (f, t, v) return f(t.sourceName, v) end,
  sourceAffiliation = function (f, t, v) if (v == FLAG_YOU) then return f(t.sourceUnit, "player") else return f(TestFlagsAny(t.sourceFlags, v), true) end end,
  sourceReaction = function (f, t, v) return f(TestFlagsAny(t.sourceFlags, v), true) end,
  sourceControl = function (f, t, v) return f(TestFlagsAny(t.sourceFlags, v), true) end,
  sourceUnitType = function (f, t, v) return f(TestFlagsAny(t.sourceFlags, v), true) end,	-- player, NPC, pet, guardian, object

  -- Recipient unit.
  recipientName = function (f, t, v) return f(t.recipientName, v) end,
  recipientAffiliation = function (f, t, v) if (v == FLAG_YOU) then return f(t.recipientUnit, "player") else return f(TestFlagsAny(t.recipientFlags, v), true) end end,
  recipientReaction = function (f, t, v) return f(TestFlagsAny(t.recipientFlags, v), true) end,
  recipientControl = function (f, t, v) return f(TestFlagsAny(t.recipientFlags, v), true) end,
  recipientUnitType = function (f, t, v) return f(TestFlagsAny(t.recipientFlags, v), true) end,

  -- Skill.
  skillID = function (f, t, v) return f(t.skillID, v) end,
  skillName = function (f, t, v) return f(t.skillName, v) end,
  skillSchool = function (f, t, v) return f(t.skillSchool, v) end,
  
  -- Extra skill.
  extraSkillID = function (f, t, v) return f(t.extraSkillID, v) end,
  extraSkillName = function (f, t, v) return f(t.extraSkillName, v) end,
  extraSkillSchool = function (f, t, v) return f(t.extraSkillSchool, v) end,

  -- Damage/heal.
  amount = function (f, t, v) return f(t.amount, v) end,
  overkillAmount = function (f, t, v) return f(t.overkillAmount, v) end,
  damageType = function (f, t, v) return f(t.damageType, v) end,
  resistAmount = function (f, t, v) return f(t.resistAmount, v) end,
  blockAmount = function (f, t, v) return f(t.blockAmount, v) end,
  absorbAmount = function (f, t, v) return f(t.absorbAmount, v) end,
  isCrit = function (f, t, v) return f(t.isCrit and true or false, v) end,
  isGlancing = function (f, t, v) return f(t.isGlancing and true or false, v) end,
  isCrushing = function (f, t, v) return f(t.isCrushing and true or false, v) end,

  -- Miss.
  missType = function (f, t, v) return f(t.missType, v) end,
  
  -- Environmental.
  hazardType = function (f, t, v) return f(t.hazardType, v) end,

  -- Power.
  powerType = function (f, t, v) return f(t.powerType, v) end,
  extraAmount = function (f, t, v) return f(t.extraAmount, v) end,
  
  -- Aura.
  auraType = function (f, t, v) return f(t.auraType, v) end,

  -- Health/power changes.
  threshold = function (f, t, v) if (type(v)=="number") then return f(t.currentPercentage, v/100) and not f(t.lastPercentage, v/100) end end,
  unitID = function (f, t, v) if ((v == "party" and string_find(t.unitID, "party%d+")) or (v == "raid" and (string_find(t.unitID, "raid%d+") or string_find(t.unitID, "party%d+")))) then v = t.unitID end return f(t.unitID, v) end,
  unitReaction = function (f, t, v) if (v == REACTION_HOSTILE) then return f(UnitIsFriend(t.unitID, "player"), false) else return f(UnitIsFriend(t.unitID, "player"), true) end end,
 }


 -- Exception conditions.
 exceptionConditionFuncs = {
  activeTalents = function (f, t, v) return f(GetActiveSpecGroup(), v) end,
  buffActive = function (f, t, v) return UnitBuff("player", v) and true or false end,
  buffInactive = function (f, t, v) return not UnitBuff("player", v) and true or false end,
  currentCP = function (f, t, v) return f(GetComboPoints("player"), v) end,
  currentPower = function (f, t, v) return f(UnitMana("player"), v) end,
  inCombat = function (f, t, v) return f(UnitAffectingCombat("player") == true and true or false, v) end,
  recentlyFired = function (f, t, v) return f(GetTime() - firedTimes[t], v) end,
  trivialTarget = function (f, t, v) return f(UnitIsTrivial("target") == true and true or false, v) end,
  unavailableSkill = function (f, t, v) return IsSkillUnavailable(v) and true or false end,
  warriorStance = function (f, t, v) if (playerClass == "WARRIOR") then return f(GetShapeshiftForm(true), v) end end,
  zoneName = function (f, t, v) return f(GetZoneText(), v) end,
  zoneType = function (f, t, v) local _, zoneType = IsInInstance() return f(zoneType, v) end,
 }
end


-- ****************************************************************************
-- Converts a string representation of a number, boolean, or nil to its
-- corresponding type.
-- ****************************************************************************
local function ConvertType(value)
 if (type(value) == "string") then
  if (value == "true") then return true end
  if (value == "false") then return false end
  if (tonumber(value)) then return tonumber(value) end
  if (value == "nil") then return nil end
 end
 
 return value
end


-- ****************************************************************************
-- Categorizes the passed trigger if it is not disabled and it applies to the 
-- current player's class.  Also tracks the events the trigger uses so the 
-- only events that are received are those needed by the active triggers.
-- ****************************************************************************
local function CategorizeTrigger(triggerSettings)
 -- Don't register the trigger if it is disabled, not for the current class,
 -- or there aren't any main events. 
 if (triggerSettings.disabled) then return end
 if (triggerSettings.classes and not string_find(triggerSettings.classes, playerClass, nil, 1)) then return end 
 if (not triggerSettings.mainEvents) then return end

 -- Loop through the main events for the trigger. 
 local eventConditions, conditions
 for mainEvent, conditionsString in string_gmatch(triggerSettings.mainEvents .. "&&", "(.-)%{(.-)%}&&") do
  -- Loop through the conditions for the event and populate the settings into a conditions table.
  conditions = {triggerSettings = triggerSettings}
  if (conditionsString and conditionsString ~= "") then
   for conditionEntry in string_gmatch(conditionsString .. ";;", "(.-);;") do
    conditions[#conditions+1] = ConvertType(conditionEntry)
   end
  end

  -- Check for special consolidated miss events.  
  if (mainEvent == "GENERIC_MISSED") then
   listenEvents["COMBAT_LOG_EVENT_UNFILTERED"] = true

   -- Create a table to hold an array of the triggers for the main events if there isn't already one for it. 
   if (not categorizedTriggers["SWING_MISSED"]) then categorizedTriggers["SWING_MISSED"] = {} end
   if (not categorizedTriggers["RANGE_MISSED"]) then categorizedTriggers["RANGE_MISSED"] = {} end
   if (not categorizedTriggers["SPELL_MISSED"]) then categorizedTriggers["SPELL_MISSED"] = {} end

   -- Add the conditions table categorized by main events.
   categorizedTriggers["SWING_MISSED"][#categorizedTriggers["SWING_MISSED"]+1] = conditions
   categorizedTriggers["RANGE_MISSED"][#categorizedTriggers["RANGE_MISSED"]+1] = conditions
   categorizedTriggers["SPELL_MISSED"][#categorizedTriggers["SPELL_MISSED"]+1] = conditions

  -- Consolidated damage.  
  elseif (mainEvent == "GENERIC_DAMAGE") then
   listenEvents["COMBAT_LOG_EVENT_UNFILTERED"] = true

   -- Create a table to hold an array of the triggers for the main events if there isn't already one for it. 
   if (not categorizedTriggers["SWING_DAMAGE"]) then categorizedTriggers["SWING_DAMAGE"] = {} end
   if (not categorizedTriggers["RANGE_DAMAGE"]) then categorizedTriggers["RANGE_DAMAGE"] = {} end
   if (not categorizedTriggers["SPELL_DAMAGE"]) then categorizedTriggers["SPELL_DAMAGE"] = {} end

   -- Add the conditions table categorized by main events.
   categorizedTriggers["SWING_DAMAGE"][#categorizedTriggers["SWING_DAMAGE"]+1] = conditions
   categorizedTriggers["RANGE_DAMAGE"][#categorizedTriggers["RANGE_DAMAGE"]+1] = conditions
   categorizedTriggers["SPELL_DAMAGE"][#categorizedTriggers["SPELL_DAMAGE"]+1] = conditions

  -- Consolidated aura application.
  elseif (mainEvent == "SPELL_AURA_APPLIED") then
   listenEvents["COMBAT_LOG_EVENT_UNFILTERED"] = true

   -- Create a table to hold an array of the triggers for the main events if there isn't already one for it. 
   if (not categorizedTriggers["SPELL_AURA_APPLIED"]) then categorizedTriggers["SPELL_AURA_APPLIED"] = {} end
   if (not categorizedTriggers["SPELL_AURA_APPLIED_DOSE"]) then categorizedTriggers["SPELL_AURA_APPLIED_DOSE"] = {} end

   -- Add the conditions table categorized by main events.
   categorizedTriggers["SPELL_AURA_APPLIED"][#categorizedTriggers["SPELL_AURA_APPLIED"]+1] = conditions
   categorizedTriggers["SPELL_AURA_APPLIED_DOSE"][#categorizedTriggers["SPELL_AURA_APPLIED_DOSE"]+1] = conditions

   -- Add aura gains to the trigger suppression so the normal buff gain/fade events are ignored.
   local skillName, recipientAffiliation
   for x = 1, #conditions, 3 do
    if (conditions[x] == "skillName" and conditions[x+1] == "eq" and conditions[x+2]) then skillName = conditions[x+2] end
    if (conditions[x] == "recipientAffiliation" and conditions[x+1] == "eq" and conditions[x+2] == FLAG_YOU) then recipientAffiliation = FLAG_YOU end
    if (conditions[x] == "skillID" and conditions[x+1] == "eq" and conditions[x+2]) then skillName = GetSpellInfo(conditions[x+2]) or UNKNOWN end
   end
	
    if (skillName and recipientAffiliation) then triggerSuppressions[skillName] = true end

  -- Consolidated aura removal.
  elseif (mainEvent == "SPELL_AURA_REMOVED") then
   listenEvents["COMBAT_LOG_EVENT_UNFILTERED"] = true

   -- Create a table to hold an array of the triggers for the main events if there isn't already one for it. 
   if (not categorizedTriggers["SPELL_AURA_REMOVED"]) then categorizedTriggers["SPELL_AURA_REMOVED"] = {} end
   if (not categorizedTriggers["SPELL_AURA_REMOVED_DOSE"]) then categorizedTriggers["SPELL_AURA_REMOVED_DOSE"] = {} end

   -- Add the conditions table categorized by main events.
   categorizedTriggers["SPELL_AURA_REMOVED"][#categorizedTriggers["SPELL_AURA_REMOVED"]+1] = conditions
   categorizedTriggers["SPELL_AURA_REMOVED_DOSE"][#categorizedTriggers["SPELL_AURA_REMOVED_DOSE"]+1] = conditions

  -- Other events.
  else
   -- Create a table to hold an array of the triggers for the main event if there isn't already one for it. 
   if (not categorizedTriggers[mainEvent]) then categorizedTriggers[mainEvent] = {} end
   eventConditions = categorizedTriggers[mainEvent]

   -- Health events.
   if (mainEvent == "UNIT_HEALTH") then
    listenEvents[mainEvent] = true
    lastPercentages[mainEvent] = {}

    -- Categorize the change by used units for better performance.  The unitID condition is required for
    -- health triggers.
    for x = 1, #conditions, 3 do
     if (conditions[x] == "unitID") then
      -- Expand the consolidated party unit id to individual ones.
      local conditionValue = conditions[x+2]
      if (conditionValue == "party") then
       for partyMember = 1, MAX_PARTY_MEMBERS do
        local unitID = "party" .. partyMember
        if (not eventConditions[unitID]) then eventConditions[unitID] = {} end
        eventConditions[unitID][#eventConditions[unitID]+1] = conditions
       end

      elseif (conditionValue == "raid") then
       for raidMember = 1, MAX_RAID_MEMBERS do
        local unitID = "raid" .. raidMember
        if (not eventConditions[unitID]) then eventConditions[unitID] = {} end
        eventConditions[unitID][#eventConditions[unitID]+1] = conditions
       end
      
      -- Specific unit.
      else
       if (not eventConditions[conditionValue]) then eventConditions[conditionValue] = {} end
       eventConditions[conditionValue][#eventConditions[conditionValue]+1] = conditions
      end
     end -- unitID?
    end -- Loop through conditions.

   -- Power events.
   elseif (mainEvent == "UNIT_POWER") then
    listenEvents[mainEvent] = true

    -- Detect power type.  The powerType and unitID conditions are required for power triggers.
    local powerType
    for x = 1, #conditions, 3 do
     if (conditions[x] == "powerType") then powerType = conditions[x+2] break end
    end

    -- Ensure the power type is defined.
    if (powerType) then
     lastPercentages[powerType] = {}

     -- Categorize the change by used power types and units for better performance.
     -- The powerType and unitID conditions are required for power triggers.
     for x = 1, #conditions, 3 do
      if (conditions[x] == "unitID") then
       if (not eventConditions[powerType]) then eventConditions[powerType] = {} end
       local powerConditions = eventConditions[powerType]

       -- Expand the consolidated party unit id to individual ones.
       local conditionValue = conditions[x+2]
       if (conditionValue == "party") then
        for partyMember = 1, MAX_PARTY_MEMBERS do
         local unitID = "party" .. partyMember
         if (not powerConditions[unitID]) then powerConditions[unitID] = {} end
         powerConditions[unitID][#powerConditions[unitID]+1] = conditions
        end

       elseif (conditionValue == "raid") then
        for raidMember = 1, MAX_RAID_MEMBERS do
         local unitID = "raid" .. raidMember
         if (not powerConditions[unitID]) then powerConditions[unitID] = {} end
         powerConditions[unitID][#powerConditions[unitID]+1] = conditions
        end
      
       -- Specific unit.
       else
       
        if (not powerConditions[conditionValue]) then powerConditions[conditionValue] = {} end
        powerConditions[conditionValue][#powerConditions[conditionValue]+1] = conditions
       end
      end -- unitID?
     end -- Loop through conditions.
    end -- Power type?

   -- Skill cooldown events.
   elseif (mainEvent == "SKILL_COOLDOWN") then
    eventConditions[#eventConditions+1] = conditions
    MikSBT.Cooldowns.UpdateRegisteredEvents()

   -- Pet cooldown events.
   elseif (mainEvent == "PET_COOLDOWN") then
    eventConditions[#eventConditions+1] = conditions
    MikSBT.Cooldowns.UpdateRegisteredEvents()

   -- Item cooldown events.
   elseif (mainEvent == "ITEM_COOLDOWN") then
    eventConditions[#eventConditions+1] = conditions
    MikSBT.Cooldowns.UpdateRegisteredEvents()

   -- Combat log event.
   elseif (captureFuncs[mainEvent]) then
    listenEvents["COMBAT_LOG_EVENT_UNFILTERED"] = true
    eventConditions[#eventConditions+1] = conditions
   end
  end -- Specific events check.
 end -- Loop through conditions.


 -- Leave the function if there are no exceptions for the trigger. 
 if (not triggerSettings.exceptions or triggerSettings.exceptions == "") then return end

 -- Loop through the conditions for the exceptions for the trigger.
 local exceptionConditions = {}
 for exceptionValue in string_gmatch(triggerSettings.exceptions .. ";;", "(.-);;") do
  exceptionConditions[#exceptionConditions+1] = ConvertType(exceptionValue)
 end

 -- Create an entry to track fired times for the trigger.
 for x = 1, #exceptionConditions, 3 do
  if (exceptionConditions[x] == "recentlyFired") then firedTimes[triggerSettings] = 0 end
 end

 -- Set the exceptions for the trigger.
 triggerExceptions[triggerSettings] = exceptionConditions
end


-- ****************************************************************************
-- Update the categorized triggers table that is used for optimized searching.
-- ****************************************************************************
local function UpdateTriggers() 
 -- Unregister all of the events from the event frame.
 eventFrame:UnregisterAllEvents()

 -- Erase the listen events table.
 EraseTable(listenEvents)

 -- Loop through all of the categorized trigger arrays and erase them.
 for mainEvent in pairs(categorizedTriggers) do
  EraseTable(categorizedTriggers[mainEvent])
 end
 
 -- Update the registered cooldown event.
 MikSBT.Cooldowns.UpdateRegisteredEvents()

 -- Erase the trigger exceptions array.
 EraseTable(triggerExceptions)

 -- Categorize triggers from the current profile.
 local currentProfileTriggers = rawget(MSBTProfiles.currentProfile, "triggers")
 if (currentProfileTriggers) then
  for triggerKey, triggerSettings in pairs(currentProfileTriggers) do
   if (triggerSettings) then CategorizeTrigger(triggerSettings) end
  end
 end
 
 -- Categorize triggers available in the master profile that aren't in the current profile. 
 for triggerKey, triggerSettings in pairs(MSBTProfiles.masterProfile.triggers) do
  if (not currentProfileTriggers or rawget(currentProfileTriggers, triggerKey) == nil) then
   CategorizeTrigger(triggerSettings)
  end
 end
 
 -- Register all of the events the triggers use.
 for event in pairs(listenEvents) do
  eventFrame:RegisterEvent(event)
 end
end


-- ****************************************************************************
-- Displays the passed trigger settings.
-- ****************************************************************************
local function DisplayTrigger(triggerSettings, sourceName, sourceClass, recipientName, recipientClass, skillName, extraSkillName, amount, effectTexture)
 -- Get a local reference to the current profile.
 local currentProfile = MSBTProfiles.currentProfile

 -- Get the trigger message and icon skill.
 local message = triggerSettings.message
 local iconSkill = triggerSettings.iconSkill

 -- Substitute source name.
 if (sourceName and string_find(message, "%n", 1, true)) then
  -- Strip realm from names.
  if (string_find(sourceName, "-", 1, true)) then sourceName = string_gsub(sourceName, "(.-)%-.*", "%1") end

  -- Color the name according to the class if there is one and it's enabled.
  if (sourceClass and not currentProfile.classColoringDisabled) then
   local classSettings = currentProfile[sourceClass]
   if (classSettings and not classSettings.disabled) then sourceName = string_format("|cFF%02x%02x%02x%s|r", classSettings.colorR * 255, classSettings.colorG * 255, classSettings.colorB * 255, sourceName) end
  end

  -- Substitute all %n event codes with the source name.
  message = string_gsub(message, "%%n", sourceName)
 end

 -- Substitute recipient name.
 if (recipientName and string_find(message, "%r", 1, true)) then
  -- Strip realm from names.
  if (string_find(recipientName, "-", 1, true)) then recipientName = string_gsub(recipientName, "(.-)%-.*", "%1") end

  -- Color the name according to the class if there is one and it's enabled.
  if (recipientClass and not currentProfile.classColoringDisabled) then
   local classSettings = currentProfile[recipientClass]
   if (classSettings and not classSettings.disabled) then recipientName = string_format("|cFF%02x%02x%02x%s|r", classSettings.colorR * 255, classSettings.colorG * 255, classSettings.colorB * 255, recipientName) end
  end

  -- Substitute all %r event codes with the recipient name.
  message = string_gsub(message, "%%r", recipientName)
 end
 
 -- Substitute skill name.
 if (skillName and string_find(message, "%s", 1, true)) then message = string_gsub(message, "%%s", skillName) end

 -- Substitute extra skill name.
 if (extraSkillName and string_find(message, "%e", 1, true)) then message = string_gsub(message, "%%e", extraSkillName) end 

 -- Substitute amount.
 if (amount and string_find(message, "%a", 1, true)) then
  -- Shorten amount with SI suffixes or separate into digit groups depending on options.
  local formattedAmount = amount
  if (currentProfile.shortenNumbers) then
   formattedAmount = ShortenNumber(formattedAmount, currentProfile.shortenNumberPrecision)
  elseif (currentProfile.groupNumbers) then
   formattedAmount = SeparateNumber(formattedAmount)
  end
  message = string_gsub(message, "%%a", formattedAmount)
 end

 -- Override the texture if there is an icon skill for the trigger.
 if (iconSkill) then
  if (skillName and string_find(iconSkill, "%s", 1, true)) then iconSkill = string_gsub(iconSkill, "%%s", skillName) end
  if (extraSkillName and string_find(iconSkill, "%e", 1, true)) then iconSkill = string_gsub(iconSkill, "%%e", extraSkillName) end
  _, _, effectTexture = GetSpellInfo(iconSkill)
 end

 -- Display the trigger event.
 DisplayEvent(triggerSettings, message, effectTexture)
end


-------------------------------------------------------------------------------
-- Trigger handler functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Tests if any of the exceptions for the passed trigger settings are true.
-- ****************************************************************************
local function TestExceptions(triggerSettings)
 -- Trigger is not excluded if there are no exceptions.
 if (not triggerExceptions[triggerSettings]) then return end
 
 -- Loop through each exception triplet.
 local exceptionConditions = triggerExceptions[triggerSettings]
 for position = 1, #exceptionConditions, 3 do
  -- Test the exception and if it passes, don't waste time checking others.
  local conditionFunc = exceptionConditionFuncs[exceptionConditions[position]]
  local testFunc = testFuncs[exceptionConditions[position+1]]
  if (conditionFunc and testFunc and conditionFunc(testFunc, triggerSettings, exceptionConditions[position+2])) then return true end
 end -- Exceptions loop.

 -- Set the current time as the last time the trigger was fired if the the trigger
 -- has a recently fired exception.
 if (firedTimes[triggerSettings]) then firedTimes[triggerSettings] = GetTime() end
end


-- ****************************************************************************
-- Handles triggers for health and power events.
-- ****************************************************************************
local function HandleHealthAndPowerTriggers(unit, event, currentAmount, maxAmount, powerType)
 -- Ignore the event if there are no triggers to search for it.
 local eventTriggers = categorizedTriggers[event]
 if (powerType and eventTriggers) then eventTriggers = eventTriggers[powerType] end
 if (not eventTriggers or not eventTriggers[unit]) then return end

 -- Calculate current last percentages.
 local currentPercentage = currentAmount / maxAmount
 local lastEventPercentages = lastPercentages[powerType or event]
 local lastPercentage = lastEventPercentages[unit]

 -- Ignore thresholds on death. 
 if (not lastPercentage) then lastEventPercentages[unit] = currentPercentage return end
 if (UnitIsDeadOrGhost(unit)) then lastEventPercentages[unit] = nil return end
 
 -- Populate the lookup table for conditions checking.
 lookupTable.amount = currentAmount
 lookupTable.currentPercentage = currentPercentage
 lookupTable.lastPercentage = lastPercentage
 lookupTable.unitID = unit
 lookupTable.powerType = powerType


 -- Erase the list of triggers to fire.
 for k in pairs(triggersToFire) do triggersToFire[k] = nil end

 -- Loop through the conditions list for the main event.
 for _, eventConditions in ipairs(eventTriggers[unit]) do
  -- Trigger fires by default.
  local doFire = true
  
  -- Don't bother checking conditions for a trigger that has already been fired.
  if (not triggersToFire[eventConditions.triggerSettings]) then
   -- Loop through each condition triplet.
   for position = 1, #eventConditions, 3 do
    -- Test the condition and if it fails, don't waste time checking other conditions.
    local conditionFunc = eventConditionFuncs[eventConditions[position]]
    local testFunc = testFuncs[eventConditions[position+1]]
    if (conditionFunc and testFunc and not conditionFunc(testFunc, lookupTable, eventConditions[position+2])) then doFire = false break end
   end -- Conditions loop.

   -- Set the trigger to be fired if none of the conditions failed.
   if (doFire) then triggersToFire[eventConditions.triggerSettings] = true end
  end
 end

 -- Get the texture for the event and display triggers that aren't excepted.
 if (next(triggersToFire)) then
  -- Display the fired triggers if none of the exceptions are true.
  local recipientName = UnitName(unit)
  local _, recipientClass = UnitClass(unit)
  local amount = currentAmount
  for triggerSettings in pairs(triggersToFire) do
   if (not TestExceptions(triggerSettings)) then DisplayTrigger(triggerSettings, nil, nil, recipientName, recipientClass, nil, nil, amount) end
  end
 end -- Triggers to fire?

 -- Update the last percentage for the unit.
 lastEventPercentages[unit] = currentPercentage
end


-- ****************************************************************************
-- Handles triggers for skill cooldowns.
-- ****************************************************************************
local function HandleCooldowns(cooldownType, cooldownID, cooldownName, effectTexture)
 -- Choose the correct cooldown event based on the cooldown type.
 local event = "SKILL_COOLDOWN"
 if (cooldownType == "pet") then
  event = "PET_COOLDOWN"
 elseif (cooldownType == "item") then
  event = "ITEM_COOLDOWN"
 end

 -- Ignore the event if there are no triggers to search for it.
 local eventTriggers = categorizedTriggers[event]
 if (not eventTriggers) then return end
 
 -- Populate the lookup table for conditions checking.
 if (cooldownType == "item") then
  lookupTable.itemID = cooldownID
  lookupTable.itemName = cooldownName
 else
  lookupTable.skillID = cooldownID
  lookupTable.skillName = cooldownName
 end

 -- Erase the list of triggers to fire.
 for k in pairs(triggersToFire) do triggersToFire[k] = nil end

 -- Loop through the conditions list for the main event.
 for _, eventConditions in ipairs(eventTriggers) do
  -- Trigger fires by default.
  local doFire = true

  -- Don't bother checking conditions for a trigger that has already been fired.
  if (not triggersToFire[eventConditions.triggerSettings]) then
   -- Loop through each condition triplet.
   for position = 1, #eventConditions, 3 do
    -- Test the condition and if it fails, don't waste time checking other conditions.
    local conditionFunc = eventConditionFuncs[eventConditions[position]]
    local testFunc = testFuncs[eventConditions[position+1]]
    if (conditionFunc and testFunc and not conditionFunc(testFunc, lookupTable, eventConditions[position+2])) then doFire = false break end
   end -- Conditions loop.

   -- Set the trigger to be fired if none of the conditions failed.
   if (doFire) then triggersToFire[eventConditions.triggerSettings] = true end
  end
 end

 -- Get the texture for the event and display triggers that aren't excepted.
 if (next(triggersToFire)) then
  -- Display the fired triggers if none of the exceptions are true.
  local recipientName = playerName
  for triggerSettings in pairs(triggersToFire) do
   if (not TestExceptions(triggerSettings)) then DisplayTrigger(triggerSettings, nil, nil, recipientName, playerClass, cooldownName, nil, nil, effectTexture) end
  end
 end -- Triggers to fire?
end


-- ****************************************************************************
-- Handles triggers for combat log events.
-- ****************************************************************************
local function HandleCombatLogTriggers(timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, recipientGUID, recipientName, recipientFlags, recipientRaidFlags, ...)
 -- Ignore the event if there are no triggers to search for it.
 if (not categorizedTriggers[event]) then return end
 
 -- Make sure the capture function for the event exists.
 local captureFunc = captureFuncs[event]
 if (not captureFunc) then return end

 
 -- Erase the parser event table.
 for k in pairs(parserEvent) do parserEvent[k] = nil end

 -- Populate fields that exist for all events.
 parserEvent.sourceGUID = sourceGUID
 parserEvent.sourceName = sourceName
 parserEvent.sourceFlags = sourceFlags
 parserEvent.recipientGUID = recipientGUID
 parserEvent.recipientName = recipientName
 parserEvent.recipientFlags = recipientFlags 
 parserEvent.sourceUnit = unitMap[sourceGUID]
 parserEvent.recipientUnit = unitMap[recipientGUID]

  
 -- Map the local arguments into the parser event table.
 captureFunc(parserEvent, ...)


 -- Erase the list of triggers to fire.
 for k in pairs(triggersToFire) do triggersToFire[k] = nil end

 -- Loop through the conditions list for the main event.
 for _, eventConditions in ipairs(categorizedTriggers[event]) do
  -- Trigger fires by default.
  local doFire = true
  
  -- Don't bother checking conditions for a trigger that has already been fired.
  if (not triggersToFire[eventConditions.triggerSettings]) then
   -- Loop through each condition triplet.
   for position = 1, #eventConditions, 3 do
    -- Test the condition and if it fails, don't waste time checking other conditions.
    local conditionFunc = eventConditionFuncs[eventConditions[position]]
	local testFunc = testFuncs[eventConditions[position+1]]
    if (conditionFunc and testFunc and not conditionFunc(testFunc, parserEvent, eventConditions[position+2])) then doFire = false break end
   end -- Conditions loop.

   -- Set the trigger to be fired if none of the conditions failed.
   if (doFire) then triggersToFire[eventConditions.triggerSettings] = true end
  end
 end

 -- Get the texture for the event and display triggers that aren't excepted.
 if (next(triggersToFire)) then
  local effectTexture
  if (parserEvent.skillID or parserEvent.extraSkillID) then _, _, effectTexture = GetSpellInfo(parserEvent.extraSkillID or parserEvent.skillID) end

  -- Display the fired triggers if none of the exceptions are true.
  local sourceName = parserEvent.sourceName
  local recipientName = parserEvent.recipientName
  local sourceClass = classMap[sourceGUID]
  local recipientClass = classMap[recipientGUID]
  local skillName = parserEvent.skillName
  local extraSkillName = parserEvent.extraSkillName
  local amount = parserEvent.amount
  for triggerSettings in pairs(triggersToFire) do
   if (not TestExceptions(triggerSettings)) then DisplayTrigger(triggerSettings, sourceName, sourceClass, recipientName, recipientClass, skillName, extraSkillName, amount, effectTexture) end
  end
 end -- Triggers to fire?
end


-------------------------------------------------------------------------------
-- Initialization and event handlers.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when the registered events occur.
-- ****************************************************************************
local function OnEvent(this, event, arg1, arg2, ...)
 -- Health.
 if (event == "UNIT_HEALTH") then
  -- Ignore the event if there are no triggers to search for it.
  if (not categorizedTriggers[event] or not categorizedTriggers[event][arg1]) then return end
  HandleHealthAndPowerTriggers(arg1, event, UnitHealth(arg1), UnitHealthMax(arg1))

 -- Power.
 elseif (event == "UNIT_POWER") then
  -- Ignore the event if there are no triggers to search for it.
  if (not categorizedTriggers[event]) then return end
  local powerType = powerTypes[arg2]
  if (not powerType) then return end
  if (not categorizedTriggers[event][powerType] or not categorizedTriggers[event][powerType][arg1]) then return end
  HandleHealthAndPowerTriggers(arg1, event, UnitPower(arg1, powerType), UnitPowerMax(arg1, powerType), powerType)
 
 -- Combat log event.
 elseif (event == "COMBAT_LOG_EVENT_UNFILTERED") then
  HandleCombatLogTriggers(arg1, arg2, ...)

 end -- Event types.
end


-- ****************************************************************************
-- Enables the trigger parsing.
-- ****************************************************************************
local function Enable()
 -- Register events the triggers use.
 for event in pairs(listenEvents) do
  eventFrame:RegisterEvent(event)
 end
end


-- ****************************************************************************
-- Disables the trigger parsing.
-- ****************************************************************************
local function Disable()
 -- Unregister all of the events from the event frame.
 eventFrame:UnregisterAllEvents()
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

-- Get the player's name and class.
playerName = UnitName("player")
playerGUID = UnitGUID("player")
_, playerClass = UnitClass("player")

-- Create a frame to receive events.
eventFrame = CreateFrame("Frame")
eventFrame:Hide()
eventFrame:SetScript("OnEvent", OnEvent)
 
-- Create function maps.
CreateCaptureFuncs()
CreateTestFuncs()
CreateConditionFuncs()

-- Create the power types lookup map. 
powerTypes["MANA"] = SPELL_POWER_MANA
powerTypes["RAGE"] = SPELL_POWER_RAGE
powerTypes["FOCUS"] = SPELL_POWER_FOCUS
powerTypes["ENERGY"] = SPELL_POWER_ENERGY
powerTypes["RUNES"] = SPELL_POWER_RUNES
powerTypes["RUNIC_POWER"] = SPELL_POWER_RUNIC_POWER
powerTypes["SOUL_SHARDS"] = SPELL_POWER_SOUL_SHARDS
powerTypes["ECLIPSE"] = SPELL_POWER_ECLIPSE
powerTypes["HOLY_POWER"] = SPELL_POWER_HOLY_POWER
powerTypes["ALTERNATE_POWER"] = SPELL_POWER_ALTERNATE_POWER
powerTypes["CHI"] = SPELL_POWER_CHI
powerTypes["BURNING_EMBERS"] = SPELL_POWER_BURNING_EMBERS
powerTypes["DEMONIC_FURY"] = SPELL_POWER_DEMONIC_FURY
powerTypes["PAIN"] = SPELL_POWER_PAIN
powerTypes["FURY"] = SPELL_POWER_FURY
powerTypes["COMBO_POINTS"] = SPELL_POWER_COMBO_POINTS
powerTypes["LUNAR_POWER"] = SPELL_POWER_LUNAR_POWER
powerTypes["MAELSTROM"] = SPELL_POWER_MAELSTROM
powerTypes["INSANITY"] = SPELL_POWER_INSANITY
powerTypes["OBSOLETE"] = SPELL_POWER_OBSOLETE
powerTypes["ARCANE_CHARGES"] = SPELL_POWER_ARCANE_CHARGES

-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Variables.
module.triggerSuppressions	= triggerSuppressions
module.categorizedTriggers	= categorizedTriggers
module.powerTypes			= powerTypes

-- Protected Functions.
module.HandleCooldowns			= HandleCooldowns
module.HandleCombatLogTriggers	= HandleCombatLogTriggers
module.ConvertType				= ConvertType
module.UpdateTriggers			= UpdateTriggers
module.Enable					= Enable
module.Disable					= Disable
