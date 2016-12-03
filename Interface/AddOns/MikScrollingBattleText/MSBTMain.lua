-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Main
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Main"
MikSBT[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various modules for faster access.
local MSBTAnimations = MikSBT.Animations
local MSBTMedia = MikSBT.Media
local MSBTParser = MikSBT.Parser
local MSBTTriggers = MikSBT.Triggers
local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations

-- Local references to various functions for faster access.
local table_remove = table.remove
local string_find = string.find
local string_gsub = string.gsub
local string_format = string.format
local math_abs = math.abs
local bit_bor = bit.bor
local GetTime = GetTime
local GetSpellInfo = GetSpellInfo
local EraseTable = MikSBT.EraseTable
local GetSkillName = MikSBT.GetSkillName
local ShortenNumber = MikSBT.ShortenNumber
local SeparateNumber = MikSBT.SeparateNumber
local DisplayEvent = MSBTAnimations.DisplayEvent
local IsScrollAreaActive = MSBTAnimations.IsScrollAreaActive
local IsScrollAreaIconShown = MSBTAnimations.IsScrollAreaIconShown
local TestFlagsAll = MSBTParser.TestFlagsAll

-- Local references to various variables for faster access.
local triggerSuppressions = MSBTTriggers.triggerSuppressions
local powerTypes = MSBTTriggers.powerTypes
local classMap = MSBTParser.classMap


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

-- How long to wait before showing events so that merges may happen.
local MERGE_DELAY_TIME = 0.3

-- How long to wait between throttle window checking.
local THROTTLE_UPDATE_TIME = 0.5

-- Amount of time to hold recent monster emotes and enemy buffs in cache.
local EMOTE_HOLD_TIME = 1
local ENEMY_BUFF_HOLD_TIME = 5

-- Damage types.
local DAMAGETYPE_PHYSICAL = 0x1
local DAMAGETYPE_HOLY = 0x2
local DAMAGETYPE_FIRE = 0x4
local DAMAGETYPE_NATURE = 0x8
local DAMAGETYPE_FROST = 0x10
local DAMAGETYPE_SHADOW = 0x20
local DAMAGETYPE_ARCANE = 0x40

-- Physical + Magic Damage types.
local DAMAGETYPE_HOLYSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_HOLY
local DAMAGETYPE_FLAMESTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_FIRE
local DAMAGETYPE_STORMSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_NATURE
local DAMAGETYPE_FROSTSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_FROST
local DAMAGETYPE_SHADOWSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_SHADOW
local DAMAGETYPE_SPELLSTRIKE = DAMAGETYPE_PHYSICAL + DAMAGETYPE_ARCANE

-- Two magic damage types.
local DAMAGETYPE_HOLYFIRE = DAMAGETYPE_HOLY + DAMAGETYPE_FIRE
local DAMAGETYPE_HOLYSTORM = DAMAGETYPE_HOLY + DAMAGETYPE_NATURE
local DAMAGETYPE_HOLYFROST = DAMAGETYPE_HOLY + DAMAGETYPE_FROST
local DAMAGETYPE_SHADOWLIGHT = DAMAGETYPE_HOLY + DAMAGETYPE_SHADOW
local DAMAGETYPE_DIVINE = DAMAGETYPE_HOLY + DAMAGETYPE_ARCANE
local DAMAGETYPE_FIRESTORM = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE
local DAMAGETYPE_FROSTFIRE = DAMAGETYPE_FIRE + DAMAGETYPE_FROST
local DAMAGETYPE_SHADOWFLAME = DAMAGETYPE_FIRE + DAMAGETYPE_SHADOW
local DAMAGETYPE_SPELLFIRE = DAMAGETYPE_FIRE + DAMAGETYPE_ARCANE
local DAMAGETYPE_FROSTSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_FROST
local DAMAGETYPE_SHADOWSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_SHADOW
local DAMAGETYPE_SPELLSTORM = DAMAGETYPE_NATURE + DAMAGETYPE_ARCANE
local DAMAGETYPE_SHADOWFROST = DAMAGETYPE_FROST + DAMAGETYPE_SHADOW
local DAMAGETYPE_SPELLFROST = DAMAGETYPE_FROST + DAMAGETYPE_ARCANE
local DAMAGETYPE_SPELLSHADOW = DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE

-- Three or more damage types.
local DAMAGETYPE_ELEMENTAL = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE + DAMAGETYPE_FROST
local DAMAGETYPE_CHROMATIC = DAMAGETYPE_FIRE + DAMAGETYPE_NATURE + DAMAGETYPE_FROST + DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE
local DAMAGETYPE_MAGIC = DAMAGETYPE_HOLY + DAMAGETYPE_FIRE + DAMAGETYPE_NATURE + DAMAGETYPE_FROST + DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE
local DAMAGETYPE_CHAOS = DAMAGETYPE_PHYSICAL + DAMAGETYPE_HOLY + DAMAGETYPE_FIRE + DAMAGETYPE_NATURE + DAMAGETYPE_FROST + DAMAGETYPE_SHADOW + DAMAGETYPE_ARCANE

-- Spell IDs.
local SPELLID_AUTOSHOT = 75

-- Spell names.
local SPELL_BLINK					= GetSkillName(1953)
--local SPELL_BLIZZARD				= GetSkillName(10)
local SPELL_BLOOD_STRIKE			= GetSkillName(60945)
--local SPELL_BLOOD_STRIKE_OFF_HAND	= GetSkillName(66215)
--local SPELL_HELLFIRE				= GetSkillName(1949)
--local SPELL_HURRICANE				= GetSkillName(16914)
local SPELL_RAIN_OF_FIRE			= GetSkillName(5740)


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Prevent tainting global _.
local _

-- Dynamically created frames for receiving events.
local eventFrame = CreateFrame("Frame")
local throttleFrame = CreateFrame("Frame")

-- Player's class.
local playerClass

-- Pool of dynamically created combat events that are reused.
local combatEventCache = {}

-- Lookup tables.
local eventHandlers = {}
local damageTypeMap = {}
local damageColorProfileEntries = {}
local powerTokens = {}
local uniquePowerTypes = {}

-- Throttled ability info.
local throttledAbilities = {}

-- Holds unmerged and merged combat events.
local unmergedEvents = {}
local mergedEvents = {}

-- Used for timing between updates.
local lastMergeUpdate = 0
local lastThrottleUpdate = 0

-- Spam control info.
local isEnglish
local lastPowerAmounts = {}
local finisherShown
local recentEmotes = {}
local recentEnemyBuffs = {}
local ignoreAuras = {}

-- Localized off-hand info to allow merging of off-hand strikes.
local offHandTrailer
local offHandPattern


-------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates damage type and damage color profile maps.
-- ****************************************************************************
local function CreateDamageMaps()
 -- Create the damage type lookup map.
 damageTypeMap[DAMAGETYPE_PHYSICAL] = STRING_SCHOOL_PHYSICAL
 damageTypeMap[DAMAGETYPE_HOLY] = STRING_SCHOOL_HOLY
 damageTypeMap[DAMAGETYPE_FIRE] = STRING_SCHOOL_FIRE
 damageTypeMap[DAMAGETYPE_NATURE] = STRING_SCHOOL_NATURE
 damageTypeMap[DAMAGETYPE_FROST] = STRING_SCHOOL_FROST
 damageTypeMap[DAMAGETYPE_SHADOW] = STRING_SCHOOL_SHADOW
 damageTypeMap[DAMAGETYPE_ARCANE] = STRING_SCHOOL_ARCANE
 damageTypeMap[DAMAGETYPE_HOLYSTRIKE] = STRING_SCHOOL_HOLYSTRIKE
 damageTypeMap[DAMAGETYPE_FLAMESTRIKE] = STRING_SCHOOL_FLAMESTRIKE
 damageTypeMap[DAMAGETYPE_STORMSTRIKE] = STRING_SCHOOL_STORMSTRIKE
 damageTypeMap[DAMAGETYPE_FLAMESTRIKE] = STRING_SCHOOL_FLAMESTRIKE
 damageTypeMap[DAMAGETYPE_SHADOWSTRIKE] = STRING_SCHOOL_SHADOWSTRIKE
 damageTypeMap[DAMAGETYPE_SPELLSTRIKE] = STRING_SCHOOL_SPELLSTRIKE
 damageTypeMap[DAMAGETYPE_HOLYFIRE] = STRING_SCHOOL_HOLYFIRE
 damageTypeMap[DAMAGETYPE_HOLYSTORM] = STRING_SCHOOL_HOLYSTORM
 damageTypeMap[DAMAGETYPE_HOLYFROST] = STRING_SCHOOL_HOLYFROST
 damageTypeMap[DAMAGETYPE_SHADOWLIGHT] = STRING_SCHOOL_SHADOWLIGHT
 damageTypeMap[DAMAGETYPE_DIVINE] = STRING_SCHOOL_DIVINE
 damageTypeMap[DAMAGETYPE_FIRESTORM] = STRING_SCHOOL_FIRESTORM
 damageTypeMap[DAMAGETYPE_FROSTFIRE] = STRING_SCHOOL_FROSTFIRE
 damageTypeMap[DAMAGETYPE_SHADOWFLAME] = STRING_SCHOOL_SHADOWFLAME
 damageTypeMap[DAMAGETYPE_SPELLFIRE] = STRING_SCHOOL_SPELLFIRE
 damageTypeMap[DAMAGETYPE_FROSTSTORM] = STRING_SCHOOL_FROSTSTORM
 damageTypeMap[DAMAGETYPE_SHADOWSTORM] = STRING_SCHOOL_SHADOWSTORM
 damageTypeMap[DAMAGETYPE_SPELLSTORM] = STRING_SCHOOL_SPELLSTORM
 damageTypeMap[DAMAGETYPE_SHADOWFROST] = STRING_SCHOOL_SHADOWFROST
 damageTypeMap[DAMAGETYPE_SPELLFROST] = STRING_SCHOOL_SPELLFROST
 damageTypeMap[DAMAGETYPE_SPELLSHADOW] = STRING_SCHOOL_SPELLSHADOW
 damageTypeMap[DAMAGETYPE_ELEMENTAL] = STRING_SCHOOL_ELEMENTAL
 damageTypeMap[DAMAGETYPE_CHROMATIC] = STRING_SCHOOL_CHROMATIC
 damageTypeMap[DAMAGETYPE_MAGIC] = STRING_SCHOOL_MAGIC
 damageTypeMap[DAMAGETYPE_CHAOS] = STRING_SCHOOL_CHAOS

 -- Create the damage color profile entries lookup map. 
 damageColorProfileEntries[DAMAGETYPE_PHYSICAL] = "physical"
 damageColorProfileEntries[DAMAGETYPE_HOLY] = "holy"
 damageColorProfileEntries[DAMAGETYPE_FIRE] = "fire"
 damageColorProfileEntries[DAMAGETYPE_NATURE] = "nature"
 damageColorProfileEntries[DAMAGETYPE_FROST] = "frost"
 damageColorProfileEntries[DAMAGETYPE_SHADOW] = "shadow"
 damageColorProfileEntries[DAMAGETYPE_ARCANE] = "arcane"
 damageColorProfileEntries[DAMAGETYPE_FROSTFIRE] = "frostfire"
 damageColorProfileEntries[DAMAGETYPE_SHADOWFLAME] = "shadowflame"
end


-- ****************************************************************************
-- Returns an abbreviated form of the passed skill name.
-- ****************************************************************************
local function AbbreviateSkillName(skillName)
  if (string_find(skillName, "[%s%-]")) then
   skillName = string_gsub(skillName, "(%a)[%l%p]*[%s%-]*", "%1")
  end

  return skillName
end


-- ****************************************************************************
-- Returns a formatted partial effects trailer using the passed parameters.
-- ****************************************************************************
local function FormatPartialEffects(absorbAmount, blockAmount, resistAmount, isGlancing, isCrushing)
 -- Get a local reference to the current profile.
 local currentProfile = MSBTProfiles.currentProfile

 local effectSettings, amount
 local partialEffectText = ""

 -- Partial Absorb
 if (absorbAmount) then
  effectSettings = currentProfile.absorb
  amount = absorbAmount

 -- Partial Block
 elseif (blockAmount) then
  effectSettings = currentProfile.block
  amount = blockAmount

 -- Partial Resist
 elseif (resistAmount) then
  effectSettings = currentProfile.resist
  amount = resistAmount
 end

 -- Set the partial effect text if there are settings for it, it's enabled, and it's valid.
 local trailer = effectSettings and effectSettings.trailer
 if (trailer and not effectSettings.disabled) then
  -- Shorten amount with SI suffixes or separate into digit groups depending on options.
  local formattedAmount = amount
  if (currentProfile.shortenNumbers) then
   formattedAmount = ShortenNumber(formattedAmount, currentProfile.shortenNumberPrecision)
  elseif (currentProfile.groupNumbers) then
   formattedAmount = SeparateNumber(formattedAmount)
  end

  -- Substitute the amount into the trailer.
  trailer = string_gsub(trailer, "%%a", formattedAmount)
  
  -- Color the text if coloring isn't disabled.
  if (not currentProfile.partialColoringDisabled) then
   partialEffectText = string_format("|cFF%02x%02x%02x%s|r", effectSettings.colorR * 255, effectSettings.colorG * 255, effectSettings.colorB * 255, trailer)
  else
   partialEffectText = trailer
  end
 end

 
 -- Clear the effect settings and trailer.
 effectSettings = nil
 trailer = nil
 
 -- Glancing hit
 if (isGlancing) then
  effectSettings = currentProfile.glancing

 -- Crushing blow
 elseif (isCrushing) then
  effectSettings = currentProfile.crushing
 end

 -- Append the crushing/glancing text if there are settings for it, it's enabled, and it's valid.
 trailer = effectSettings and effectSettings.trailer
 if (trailer and not effectSettings.disabled) then
  -- Color the text if coloring isn't disabled.
  if (not currentProfile.partialColoringDisabled) then
   partialEffectText = partialEffectText .. string_format("|cFF%02x%02x%02x%s|r", effectSettings.colorR * 255, effectSettings.colorG * 255, effectSettings.colorB * 255, trailer)
  else
   partialEffectText = partialEffectText .. trailer
  end
 end

 return partialEffectText 
end


-- ****************************************************************************
-- Formats an event with the parameters.
-- ****************************************************************************
local function FormatEvent(message, amount, damageType, overhealAmount, overkillAmount, powerType, name, class, effectName, partialEffects, mergeTrailer, ignoreDamageColoring, hideSkills, hideNames)
 -- Get a local reference to the current profile.
 local currentProfile = MSBTProfiles.currentProfile
 local checkParens
 
 -- Substitute amount.
 if (amount and string_find(message, "%a", 1, true)) then
  -- Check if there is overheal information and displaying it is enabled.
  local partialAmount = ""
  if (overhealAmount and overhealAmount > 0 and not currentProfile.overheal.disabled) then
   -- Deduct the overheal amount from the total amount healed.
   amount = amount - overhealAmount

   -- Shorten overheal amount with SI suffixes or separate into digit groups depending on options.
   partialAmount = overhealAmount
   if (currentProfile.shortenNumbers) then
    partialAmount = ShortenNumber(partialAmount, currentProfile.shortenNumberPrecision)
   elseif (currentProfile.groupNumbers) then
    partialAmount = SeparateNumber(partialAmount)
   end

   -- Color it with the correct color if coloring is enabled.
   local overhealSettings = currentProfile.overheal
   partialAmount = string_gsub(overhealSettings.trailer, "%%a", partialAmount)
   if (not currentProfile.partialColoringDisabled) then
    partialAmount = string_format("|cFF%02x%02x%02x%s|r", overhealSettings.colorR * 255, overhealSettings.colorG * 255, overhealSettings.colorB * 255, partialAmount)
   end

  -- No overheal so check if there is overkill information and displaying it is enabled.
  elseif (overkillAmount and overkillAmount > 0 and not currentProfile.overkill.disabled) then
   -- Deduct the overkill amount from the total amount of damage done.
   amount = amount - overkillAmount

   -- Shorten overkill amount with SI suffixes or separate into digit groups depending on options.
   partialAmount = overkillAmount
   if (currentProfile.shortenNumbers) then
    partialAmount = ShortenNumber(partialAmount, currentProfile.shortenNumberPrecision)
   elseif (currentProfile.groupNumbers) then
    partialAmount = SeparateNumber(partialAmount)
   end

   -- Color it with the correct color if coloring is enabled.
   local overkillSettings = currentProfile.overkill
   partialAmount = string_gsub(overkillSettings.trailer, "%%a", partialAmount)
   if (not currentProfile.partialColoringDisabled) then
    partialAmount = string_format("|cFF%02x%02x%02x%s|r", overkillSettings.colorR * 255, overkillSettings.colorG * 255, overkillSettings.colorB * 255, partialAmount)
   end
  end


  -- Make sure to show positive amounts for eclipse energy since it can be negative.
  local formattedAmount = amount
  if (powerType == powerTypes["ECLIPSE"]) then formattedAmount = math_abs(amount) end

  -- Shorten amount with SI suffixes or separate into digit groups depending on options.
  if (currentProfile.shortenNumbers) then
   formattedAmount = ShortenNumber(formattedAmount, currentProfile.shortenNumberPrecision)
  elseif (currentProfile.groupNumbers) then
   formattedAmount = SeparateNumber(formattedAmount)
  end

  -- Get the hex color for the damage type if there is one and coloring is enabled.
  if (damageType and not ignoreDamageColoring and not currentProfile.damageColoringDisabled) then
   -- Color the amount according to the damage type if there is one and it's enabled.
   local damageSettings = currentProfile[damageColorProfileEntries[damageType]]
   if (damageSettings and not damageSettings.disabled) then
    formattedAmount = string_format("|cFF%02x%02x%02x%s|r", damageSettings.colorR * 255, damageSettings.colorG * 255, damageSettings.colorB * 255, formattedAmount)
   end
  end -- Damage type and damage coloring is enabled.

  -- Substitute all %a event codes with the amount.
  message = string_gsub(message, "%%a", formattedAmount .. partialAmount)
 end -- Substitute amount.


 -- Substitute power type.
 if (powerType and string_find(message, "%p", 1, true)) then
  local powerString = _G[powerTokens[powerType] or "UNKNOWN"]
  if (powerType == powerTypes["ECLIPSE"]) then powerString = amount and (amount > 0 and BALANCE_POSITIVE_ENERGY or BALANCE_NEGATIVE_ENERGY) or UNKNOWN end
  message = string_gsub(message, "%%p", powerString or UNKNOWN)
 end
 

 -- Substitute names.
 if (name and string_find(message, "%n", 1, true)) then
  if (hideNames) then
   message = string_gsub(message, "%s?%-?%s?%%n", "")
   checkParens = true
  else
   -- Strip realm from names.
   if (string_find(name, "-", 1, true)) then name = string_gsub(name, "(.-)%-.*", "%1") end

   -- Color the name according to the class if there is one and it's enabled.
   if (class and not currentProfile.classColoringDisabled) then
    local classSettings = currentProfile[class]
    if (classSettings and not classSettings.disabled) then name = string_format("|cFF%02x%02x%02x%s|r", classSettings.colorR * 255, classSettings.colorG * 255, classSettings.colorB * 255, name) end
   end

   -- Substitute all %n event codes with the name.
   message = string_gsub(message, "%%n", name)
  end
 end


 -- Substitute effect names. 
 if (effectName and string_find(message, "%e", 1, true)) then message = string_gsub(message, "%%e", effectName) end


 -- Substitute skill names.
 if (effectName) then
  if (string_find(message, "%s", 1, true)) then
   -- Hide skill names if there is an icon for it and the option is set.
   if (hideSkills) then
    message = string_gsub(message, "%s?%-?%s?%%sl?%s?%-?%s?", "")
    checkParens = true
   else
    -- Use the user defined substitution for the ability if there is one.
    local isChanged
    if (currentProfile.abilitySubstitutions[effectName]) then
     effectName = currentProfile.abilitySubstitutions[effectName]
     isChanged = true
    end

    -- Do long substitutions.
    if (string_find(message, "%sl", 1, true)) then message = string_gsub(message, "%%sl", effectName) end

    -- Abbreviate skill for English if it wasn't user substituted and abbreviation is enabled.
    if (isEnglish and not isChanged and currentProfile.abbreviateAbilities) then
     effectName = AbbreviateSkillName(effectName)
    end

    -- Do remaining substitutions.
    message = string_gsub(message, "%%s", effectName)
   end
  end
 end


 -- Remove empty parenthesis left frame ignoring event codes.
 if (checkParens) then message = string_gsub(message, "%(%)", "") end


 -- Substitute damage types.
 if (damageType and string_find(message, "%t", 1, true)) then message = string_gsub(message, "%%t", damageTypeMap[damageType] or STRING_SCHOOL_UNKNOWN) end


 -- Append partial effects if there are any.
 if (partialEffects) then message = message .. partialEffects end


 -- Append the merge trailer if there is one.
 if (mergeTrailer) then message = message .. mergeTrailer end

 -- Return the formatted message.
 return message 
end


-- ****************************************************************************
-- Returns the event type prefix and affected unit name for events that
-- can be incoming or outgoing.
-- ****************************************************************************
local function GetInOutEventData(parserEvent)
 local eventTypeString, affectedUnitName, affectedUnitClass

 -- Get the information for whether the event is incoming or outgoing.
 if (parserEvent.recipientUnit == "player") then
  affectedUnitName = parserEvent.sourceName
  eventTypeString = "INCOMING"
  affectedUnitClass = classMap[parserEvent.sourceGUID]
 elseif (parserEvent.sourceUnit == "player") then
  affectedUnitName = parserEvent.recipientName
  eventTypeString = "OUTGOING"
  affectedUnitClass = classMap[parserEvent.recipientGUID]
 elseif (parserEvent.recipientUnit == "pet") then
  affectedUnitName = parserEvent.sourceName
  eventTypeString = "PET_INCOMING"
  affectedUnitClass = classMap[parserEvent.sourceGUID]
 elseif (parserEvent.sourceUnit == "pet") then
  affectedUnitName = parserEvent.recipientName
  eventTypeString = "PET_OUTGOING"
  affectedUnitClass = classMap[parserEvent.recipientGUID]
 end

 return eventTypeString, affectedUnitName, affectedUnitClass
end


-- ****************************************************************************
-- Detect all power gains.
-- ****************************************************************************
local function DetectPowerGain(powerAmount, powerType)
 -- Get the event settings.
 local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_POWER_GAIN

 -- Don't do anything if the event is disabled or the power type is invalid. 
 if (eventSettings.disabled or not powerType) then return end

 -- Display the power change if it is a gain.
 local lastPowerAmount = lastPowerAmounts[powerType] or 65535
 if (powerAmount > lastPowerAmount) then
  DisplayEvent(eventSettings, FormatEvent(eventSettings.message, powerAmount - lastPowerAmount, nil, nil, nil, powerType, nil, nil, UNKNOWN))
 end
end

-- ****************************************************************************
-- Handle combo point changes.
-- ****************************************************************************
local function HandleComboPoints(PowerAmount, powerType)
 -- Get the correct event settings.
 local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_CP_GAIN
 local maxCP = UnitPowerMax("player", powerType)
 if (PowerAmount == maxCP) then eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_CP_FULL end
 -- Don't do anything if the event is disabled.
 if (eventSettings.disabled) then return end 
 -- Don't do anything if 0 CP
 if (PowerAmount == 0) then return end
 -- Display the event.
 DisplayEvent(eventSettings, FormatEvent(eventSettings.message, PowerAmount))
end

-- ****************************************************************************
-- Handle light force changes.
-- ****************************************************************************
local function HandleChi(numChi, powerType)
 -- Get the correct event settings.
 local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_CHI_CHANGE
 local maxChi = UnitPowerMax("player", powerType)
 if (numChi == maxChi) then eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_CHI_FULL end

 -- Don't do anything if the event is disabled.
 if (eventSettings.disabled) then return end

 -- Display the event.
 DisplayEvent(eventSettings, FormatEvent(eventSettings.message, numChi))
end


-- ****************************************************************************
-- Handle holy power changes.
-- ****************************************************************************
local function HandleHolyPower(numHolyPower, powerType)
 -- Get the correct event settings.
 local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_HOLY_POWER_CHANGE
 local maxHolyPower = UnitPowerMax("player", powerType)
 if (numHolyPower == maxHolyPower) then eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_HOLY_POWER_FULL end
 -- Don't do anything if the event is disabled.
 if (eventSettings.disabled) then return end
 -- Don't do anything if 0 Holy Power
 if (numHolyPower == 0) then return end
 -- Display the event.
 DisplayEvent(eventSettings, FormatEvent(eventSettings.message, numHolyPower))
end

-- ****************************************************************************
-- Handle monster emotes.
-- ****************************************************************************
local function HandleMonsterEmotes(emoteString)
 -- Get the event settings.
 local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_MONSTER_EMOTE

 -- Don't do anything if the event is disabled.
 if (eventSettings.disabled) then return end

 -- Loop through all of the recent emotes and remove the old ones.
 local now = GetTime()
 for emote, cleanupTime in pairs(recentEmotes) do
  if (now >= cleanupTime) then recentEmotes[emote] = nil end
 end

 -- Don't do anything if the emote has already been shown within the specified time frame.
 if (recentEmotes[emoteString]) then return end

 -- Display the event and add it to the recent emotes list.
 DisplayEvent(eventSettings, FormatEvent(eventSettings.message, nil, nil, nil, nil, nil, nil, nil, emoteString))
 recentEmotes[emoteString] = now + EMOTE_HOLD_TIME 
end


-- ****************************************************************************
-- Merges like combat events.
-- ****************************************************************************
local function MergeEvents(numEvents, currentProfile)
 -- Holds an unmerged event and whether or not to merge it.
 local unmergedEvent
 local doMerge = false

 -- Don't attempt to merge any more events than were available when the function was called since
 -- more events may get added while the merge is taking place.
 for i = 1, numEvents do
  -- Get the unmerged event.
  unmergedEvent = unmergedEvents[i]

  -- Loop through all of the events in the merged events array.
  for _, mergedEvent in ipairs(mergedEvents) do
   -- Check if the event types match.
   if (unmergedEvent.eventType == mergedEvent.eventType) then
    -- Check if there is no skill name. 
    if (not unmergedEvent.effectName) then
     -- Set the merge flag if the affected unit name is the same.
     if ((unmergedEvent.name == mergedEvent.name) and unmergedEvent.name) then doMerge = true end

    -- The skill names match.
    elseif (unmergedEvent.effectName == mergedEvent.effectName) then
     -- Change the name to the multiple targets string if the names don't match.
     if (unmergedEvent.name ~= mergedEvent.name) then mergedEvent.name = L.MSG_MULTIPLE_TARGETS end
 
     -- Clear the class if they don't match.
     if (unmergedEvent.class ~= mergedEvent.class) then mergedEvent.class = nil end

     -- Set the merge flag.
     doMerge = true 
    end
   end -- Event types match.

   -- Check if the event should be merged.
   if (doMerge) then
    -- Clear partial effects.
    mergedEvent.partialEffects = nil

    -- Set the event merged flag for the event being merged.
    unmergedEvent.eventMerged = true

    -- Total the amount if there is one.
    if (unmergedEvent.amount) then mergedEvent.amount = (mergedEvent.amount or 0) + unmergedEvent.amount end

    -- Total the overheal amount if there is one.
    if (unmergedEvent.overhealAmount) then mergedEvent.overhealAmount = (mergedEvent.overhealAmount or 0) + unmergedEvent.overhealAmount end

    -- Increment the number of merged events.
    mergedEvent.numMerged = mergedEvent.numMerged + 1

    -- Increment the number of crits if the event being merged is a crit.  Clear the crit flag for the merged event if it isn't.
    if (unmergedEvent.isCrit) then mergedEvent.numCrits = mergedEvent.numCrits + 1 else mergedEvent.isCrit = false end

    -- Break out of the merged events loop since the event has been merged.
    break
   end -- Do Merge.
  end -- Loop through merged events.

  -- Add the event to the end of the merged events array if it wasn't merged.
  if (not doMerge) then
   unmergedEvent.numMerged = 0

   -- Set the number of crits depending on if the event is a crit or not.
   if (unmergedEvent.isCrit) then unmergedEvent.numCrits = 1 else unmergedEvent.numCrits = 0 end

   -- Add the event to the end of the merged events array.
   mergedEvents[#mergedEvents+1] = unmergedEvent
  end

  -- Reset the event merge flag.
  doMerge = false
 end -- Loop through unmerged events.

 
 -- Append merge trailer information to the merged events if enabled.
 if not (currentProfile.hideMergeTrailer) then
  for _, mergedEvent in ipairs(mergedEvents) do
   -- Check if there were any events merged.
   if (mergedEvent.numMerged > 0) then
    -- Create the crit trailer text if there were any crits.
    local critTrailer = ""
    if (mergedEvent.numCrits > 0) then
     critTrailer = string_format(", %d %s", mergedEvent.numCrits, mergedEvent.numCrits == 1 and L.MSG_CRIT or L.MSG_CRITS)
    end
   
    -- Set the event's merge trailer field.
    mergedEvent.mergeTrailer = string_format(" [%d %s%s]", mergedEvent.numMerged + 1, L.MSG_HITS, critTrailer)
   end -- Events were merged.
  end -- Loop through merged events.
 end
 
 -- Remove the processed events from unmerged events queue.
 for i = 1, numEvents do
  -- Recycle the unmerged event if it was merged.
  if (unmergedEvents[1].eventMerged) then 
   EraseTable(unmergedEvents[1])
   combatEventCache[#combatEventCache+1] = unmergedEvents[1]
  end
  
  -- Remove the event from the unmerged events array.
  table_remove(unmergedEvents, 1)
 end
end


-------------------------------------------------------------------------------
-- Event handlers.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Handles damage parser events.
-- ****************************************************************************
local function DamageHandler(parserEvent, currentProfile)
 -- Setup info for whether the event is incoming or outgoing.
 local eventTypeString, affectedUnitName, affectedUnitClass = GetInOutEventData(parserEvent)

 -- Ignore the event if it doesn't pertain to the player or their pet.
 if (not eventTypeString) then return end
 
 -- Ignore the event if the damage amount is under the damage threshold to be shown.
 if (parserEvent.amount and parserEvent.amount < currentProfile.damageThreshold) then return end

 -- Recharacterize hunter auto shots to melee damage.
 local skillID = parserEvent.skillID
 if (skillID == SPELLID_AUTOSHOT) then skillID = nil end

 -- Append the spell prefix if there is a skill.
 if (skillID) then eventTypeString = eventTypeString .. "_SPELL" end

 -- Append correct damage suffix.
 eventTypeString = eventTypeString .. (parserEvent.isDoT and "_DOT" or parserEvent.isDamageShield and "_DAMAGE_SHIELD" or "_DAMAGE")

 return eventTypeString, parserEvent.skillName, affectedUnitName, affectedUnitClass, true
end


-- ****************************************************************************
-- Handles miss parser events.
-- ****************************************************************************
local function MissHandler(parserEvent, currentProfile)
 -- Setup info for whether the event is incoming or outgoing.
 local eventTypeString, affectedUnitName, affectedUnitClass = GetInOutEventData(parserEvent)

 -- Ignore the event if it doesn't pertain to the player or their pet.
 if (not eventTypeString) then return end

 -- Recharacterize hunter auto shots to melee damage.
 local skillID = parserEvent.skillID
 if (skillID == SPELLID_AUTOSHOT) then skillID = nil end
 
 -- Append the spell prefix if there is a skill.
 if (skillID) then eventTypeString = eventTypeString .. "_SPELL" end

 -- Append the miss type.
 eventTypeString = eventTypeString .. "_" .. parserEvent.missType   

 return eventTypeString, parserEvent.skillName, affectedUnitName, affectedUnitClass, true
end


-- ****************************************************************************
-- Handles heal parser events.
-- ****************************************************************************
local function HealHandler(parserEvent, currentProfile)
 -- Setup info for whether the event is incoming or outgoing.
 local eventTypeString, affectedUnitName, affectedUnitClass = GetInOutEventData(parserEvent)

 -- Ignore the event if it doesn't pertain to the player or their pet.
 if (not eventTypeString) then return end
 
 local isHoT = parserEvent.isHoT
 local amount = parserEvent.amount
 if (amount) then
  -- Ignore the event if the heal amount is under the healing threshold to be shown.
  if (amount < currentProfile.healThreshold) then return end

  -- Calculate the effective heal amount.
  local overhealAmount = parserEvent.overhealAmount
  local effectiveHealAmount = overhealAmount and (amount - overhealAmount) or amount
  
  -- Ignore the event if the effective heal amount is zero and the appropriate
  -- hide full overheals option is set.
  if (effectiveHealAmount == 0) then
   if (not isHoT and currentProfile.hideFullOverheals) then return end
   if (isHoT and currentProfile.hideFullHoTOverheals) then return end
  end
 end

 -- Append hot suffix if it's a hot.
 eventTypeString = eventTypeString .. (isHoT and "_HOT" or "_HEAL")

 return eventTypeString, parserEvent.skillName, affectedUnitName, affectedUnitClass, true
end


-- ****************************************************************************
-- Handles interrupt parser events.
-- ****************************************************************************
local function InterruptHandler(parserEvent, currentProfile)
 -- Setup info for whether the event is incoming or outgoing.
 local eventTypeString, affectedUnitName, affectedUnitClass = GetInOutEventData(parserEvent)

 -- Ignore the event if it doesn't pertain to the player or their pet.
 if (not eventTypeString) then return end

 -- Append interrupt suffix. 
 eventTypeString = eventTypeString .. "_SPELL_INTERRUPT"
 
 return eventTypeString, parserEvent.extraSkillName, affectedUnitName, affectedUnitClass
end


-- ****************************************************************************
-- Handles environmental parser events.
-- ****************************************************************************
local function EnvironmentalHandler(parserEvent, currentProfile)
 -- Ignore the event if it isn't the player.
 if (parserEvent.recipientUnit ~= "player") then return end
 
 return "INCOMING_ENVIRONMENTAL", parserEvent.hazardType
end


-- ****************************************************************************
-- Handles aura parser events.
-- ****************************************************************************
local function AuraHandler(parserEvent, currentProfile)
 local eventTypeString, affectedUnitName, affectedUnitClass
 local effectName = parserEvent.skillName
  
 -- Aura is pertaining to the player.
 if (parserEvent.recipientUnit == "player") then
  -- Ignore auras that don't provide useful information.
  if (ignoreAuras[parserEvent.skillName] and parserEvent.sourceUnit == "player") then return end
  
  -- Ignore the event if it's suppressed due to a trigger.
  if (triggerSuppressions[effectName]) then return end

  -- Set notification buff/debuff.
  eventTypeString = "NOTIFICATION_" .. parserEvent.auraType
  
  -- Append stack or fade prefix if needed.
  if (not parserEvent.isFade) then
   if (parserEvent.isDose) then eventTypeString = eventTypeString .. "_STACK" end
  else
   eventTypeString = eventTypeString .. "_FADE"
  end

 -- Aura is pertaining to another unit.
 else
  -- Ignore the event if it's suppressed due to a trigger.
  if (triggerSuppressions[effectName]) then return end
  
  -- Ignore the event if it isn't for the current target.
  if (not TestFlagsAll(parserEvent.recipientFlags, MSBTParser.TARGET_TARGET)) then return end

  -- Ignore the event if it's a friendly unit.
  if (not UnitIsEnemy("player", "target")) then return end

  -- Ignore the event if it's not a buff gain.
  if (parserEvent.auraType ~= "BUFF" or parserEvent.isFade == true) then return end

  -- Loop through all of the recent enemy buff gains and remove the old ones.
  local now = GetTime()
  for buff, cleanupTime in pairs(recentEnemyBuffs) do
   if (now >= cleanupTime) then recentEnemyBuffs[buff] = nil end
  end

  -- Ignore the event if it has already been shown within the specified time frame.
  if (recentEnemyBuffs[effectName]) then return end

  -- Add the event to the recent enemy buffs list.
  recentEnemyBuffs[effectName] = now + ENEMY_BUFF_HOLD_TIME

  eventTypeString = "NOTIFICATION_ENEMY_BUFF"
  affectedUnitName = parserEvent.recipientName
  affectedUnitClass = classMap[parserEvent.recipientGUID]
 end -- Player or enemy check.

 return eventTypeString, effectName, affectedUnitName, affectedUnitClass
end


-- ****************************************************************************
-- Handles enchant parser events.
-- ****************************************************************************
local function EnchantHandler(parserEvent, currentProfile)
 -- Ignore the event if it isn't the player.
 if (parserEvent.recipientUnit ~= "player") then return end
 
 -- Set the item buff event type and append fade suffix if the enchant is fading.
 local eventTypeString = "NOTIFICATION_ITEM_BUFF"
 if (parserEvent.isFade) then eventTypeString = eventTypeString .. "_FADE" end
  
 return eventTypeString, parserEvent.skillName
end


-- ****************************************************************************
-- Handles dispel parser events.
-- ****************************************************************************
local function DispelHandler(parserEvent, currentProfile)
 -- Get the correct dispel event.
 local eventTypeString
 if (parserEvent.sourceUnit == "player") then
  eventTypeString = "OUTGOING_DISPEL"
 elseif (parserEvent.sourceUnit == "pet") then
  eventTypeString = "PET_OUTGOING_DISPEL"
 else
  -- Ignore the event if it isn't from the player or their pet.
  return
 end
 
 return eventTypeString, parserEvent.extraSkillName, parserEvent.recipientName, classMap[parserEvent.recipientGUID]
end


-- ****************************************************************************
-- Handles power parser events.
-- ****************************************************************************
local function PowerHandler(parserEvent, currentProfile)
 -- Handle certain power types such as holy power, shadow orbs, and chi uniquely.
 if (uniquePowerTypes[parserEvent.powerType] ~= nil) then return end

 -- Ignore the event if all power gains are being shown.
 if (currentProfile.showAllPowerGains) then return end

 -- Ignore the event it doesn't affect the player and set the correct amount.
 local amount
 if (parserEvent.isLeech) then
  if (parserEvent.sourceUnit ~= "player") then return end
  amount = parserEvent.extraAmount
 else
  if (parserEvent.recipientUnit ~= "player") then return end
  amount = parserEvent.amount
 end

 -- Ignore the event if the power change is under the threshold to be shown.
 -- Take the absolute value to ensure negative power amounts such as Lunar Energy are handled correctly.
 if (amount and math_abs(amount) < currentProfile.powerThreshold) then return end

 -- Use a different event for alternate power.
 local eventTypePrefix = "NOTIFICATION_POWER_"
 if (parserEvent.powerType == powerTypes["ALTERNATE_POWER"]) then eventTypePrefix = "NOTIFICATION_ALT_POWER_" end

 -- Append gain or loss suffix. 
 local eventTypeString = eventTypePrefix .. (parserEvent.isDrain and "LOSS" or "GAIN")
 
 return eventTypeString, parserEvent.skillName, nil, nil, true
end


-- ****************************************************************************
-- Handles kill parser events.
-- ****************************************************************************
local function KillHandler(parserEvent, currentProfile)
 -- Ignore the event if it isn't a kill from the player.
 if (parserEvent.sourceUnit ~= "player") then return end
 
 -- Ignore the event if it is a player guardian (Hunter snakes, etc).
 if (TestFlagsAll(parserEvent.recipientFlags, bit_bor(MSBTParser.UNITTYPE_GUARDIAN, MSBTParser.CONTROL_HUMAN))) then return end
 
 -- Ignore the event if it is the player's pet to prevent killing blow events due to sacrifices (Death Knight ghoul, etc).
 if (parserEvent.recipientUnit == "pet") then return end

 -- Figure out the event type depending on whether a player or the server
 -- controlled the unit that was killed.
 local eventTypeString = "NOTIFICATION_"
 eventTypeString = eventTypeString .. (TestFlagsAll(parserEvent.recipientFlags, MSBTParser.CONTROL_SERVER) and "NPC" or "PC")
 eventTypeString = eventTypeString .. "_KILLING_BLOW"

 return eventTypeString, nil, parserEvent.recipientName, classMap[parserEvent.recipientGUID]
end


-- ****************************************************************************
-- Handles honor parser events.
-- ****************************************************************************
local function HonorHandler(parserEvent, currentProfile)
 -- Ignore the event if it isn't for the player.
 if (parserEvent.recipientUnit ~= "player") then return end
 
 return "NOTIFICATION_HONOR_GAIN"
end


-- ****************************************************************************
-- Handles reputation parser events.
-- ****************************************************************************
local function ReputationHandler(parserEvent, currentProfile)
 -- Ignore the event if it isn't for the player.
 if (parserEvent.recipientUnit ~= "player") then return end

 -- Append loss or gain suffix.
 local eventTypeString = "NOTIFICATION_REP_" .. (parserEvent.isLoss and "LOSS" or "GAIN")
 return eventTypeString, parserEvent.factionName
end


-- ****************************************************************************
-- Handles proficiency parser events.
-- ****************************************************************************
local function ProficiencyHandler(parserEvent, currentProfile)
 -- Ignore the event if it isn't for the player.
 if (parserEvent.recipientUnit ~= "player") then return end

 return "NOTIFICATION_SKILL_GAIN", parserEvent.skillName
end


-- ****************************************************************************
-- Handles experience parser events.
-- ****************************************************************************
local function ExperienceHandler(parserEvent, currentProfile)
 -- Ignore the event if it isn't for the player.
 if (parserEvent.recipientUnit ~= "player") then return end

 return "NOTIFICATION_EXPERIENCE_GAIN"
end


-- ****************************************************************************
-- Handles extra attacks parser events.
-- ****************************************************************************
local function ExtraAttacksHandler(parserEvent, currentProfile)
 -- Ignore the event if it isn't for the player.
 if (parserEvent.sourceUnit ~= "player") then return end

 return "NOTIFICATION_EXTRA_ATTACK", parserEvent.skillName
end


-- ****************************************************************************
-- Parser events handler.
-- ****************************************************************************
local function ParserEventsHandler(parserEvent)
 -- Get a local reference to the current profile.
 local currentProfile = MSBTProfiles.currentProfile

 -- Information regarding how to display the event.
 local eventTypeString, effectName, affectedUnitName, affectedUnitClass, mergeEligible

 -- Local copy for faster access.
 local eventType = parserEvent.eventType

 -- Call the correct handler for the event type if there is one.
 local handler = eventHandlers[eventType]
 if (handler) then
  eventTypeString, effectName, affectedUnitName, affectedUnitClass, mergeEligible = handler(parserEvent, currentProfile)
 end

 -- Ignore the event if it is unrecognized.
 if (not eventTypeString) then return end
 
 -- Ignore the event if there is a skill name and it's suppressed.
 if (effectName and currentProfile.abilitySuppressions[effectName]) then return end
 
 -- Ignore the event if there is no profile data for it, it's disabled, or the scroll area it's using is not active.
 local isCrit = parserEvent.isCrit
 local eventSettings = currentProfile.events[isCrit and eventTypeString .. "_CRIT" or eventTypeString]
 if (not eventSettings or eventSettings.disabled or not IsScrollAreaActive(eventSettings.scrollArea)) then return end

 -- Local copies for faster access.
 local damageType = parserEvent.damageType
 local skillID = parserEvent.skillID
 
 -- Recharacterize hunter auto shots to melee damage.
 if (skillID == SPELLID_AUTOSHOT) then
  skillID = nil
  effectName = nil
 end

 -- Ignore damage coloring on outgoing physical skills so they are easier to tell apart from auto attacks.
 local ignoreDamageColoring
 if (eventType == "damage" and parserEvent.sourceUnit == "player" and damageType == DAMAGETYPE_PHYSICAL and skillID) then ignoreDamageColoring = true end

 -- Set the damage type to the school of the fully absorbed skills.
 if (eventType == "miss" and parserEvent.missType == "ABSORB") then damageType = parserEvent.skillSchool or DAMAGETYPE_PHYSICAL end

 -- Get the formatted partial effects if it's a damage or environmental event. 
 local partialEffects
 if (eventType == "damage" or eventType == "environmental") then
  partialEffects = FormatPartialEffects(parserEvent.absorbAmount, parserEvent.blockAmount, parserEvent.resistAmount, parserEvent.isGlancing, parserEvent.isCrushing)
 end

 -- Attempt to get the texture for the event if icons are not disabled.
 local effectTexture
 if (not currentProfile.skillIconsDisabled and IsScrollAreaIconShown(eventSettings.scrollArea)) then
  if (skillID) then _, _, effectTexture = GetSpellInfo(skillID) end
 
  -- Override texture for dispels and interrupts.
  if ((eventType == "dispel" or eventType == "interrupt" or (eventType == "miss" and parserEvent.missType == "RESIST")) and parserEvent.extraSkillID) then
   _, _, effectTexture = GetSpellInfo(parserEvent.extraSkillID)
  end
 end

 -- Event is not eligible to be merged so just display it now without processing the impossible fields.
 if (not mergeEligible) then
  local outputMessage = FormatEvent(eventSettings.message, parserEvent.amount, damageType, nil, nil, nil, affectedUnitName, affectedUnitClass, effectName)
  DisplayEvent(eventSettings, outputMessage, effectTexture)

 -- Event is eligible for merging, but is excluded so display it now with full processing.
 elseif (currentProfile.mergeExclusions[effectName] or (not effectName and currentProfile.mergeSwingsDisabled)) then
  -- Hide skill names according to the options if a texture is available.
  local hideSkills = effectTexture and not currentProfile.exclusiveSkillsDisabled or currentProfile.hideSkills
  local outputMessage = FormatEvent(eventSettings.message, parserEvent.amount, damageType, parserEvent.overhealAmount, parserEvent.overkillAmount, parserEvent.powerType, affectedUnitName, affectedUnitClass, effectName, partialEffects, nil, ignoreDamageColoring, hideSkills, currentProfile.hideNames)
  DisplayEvent(eventSettings, outputMessage, effectTexture)

 -- The event is eligible for merging. 
 else
  -- Acquire a recycled table from cache or create a new one if there aren't any available in cache.
  local combatEvent = table_remove(combatEventCache) or {}

  -- Strip off-hand trailers so they merge with main hand strikes of the same name.
  -- Use a plain text search since it is faster than doing a full regular expression search.
  if (effectName and offHandTrailer and string_find(effectName, offHandTrailer, 1, true)) then
   effectName = string_gsub(effectName, offHandPattern, "")
  end


  -- Setup the combat event.
  combatEvent.eventType = eventTypeString
  combatEvent.isCrit = isCrit
  combatEvent.amount = parserEvent.amount
  combatEvent.effectName = effectName
  combatEvent.effectTexture = effectTexture
  combatEvent.name = affectedUnitName
  combatEvent.class = affectedUnitClass
  combatEvent.damageType = damageType
  combatEvent.ignoreDamageColoring = ignoreDamageColoring
  combatEvent.partialEffects = partialEffects
  combatEvent.overhealAmount = parserEvent.overhealAmount
  combatEvent.overkillAmount = parserEvent.overkillAmount
  combatEvent.powerType = parserEvent.powerType

  
  -- Throttle events according to user settings.
  if (effectName) then
   -- Get the duration the ability should be throttled for, if any.
   local throttleDuration = currentProfile.throttleList[effectName]

   -- Set throttle duration for power changes or dots/hots if there isn't a specific one set for the ability.
   if (not throttleDuration) then
    -- Use the dot throttle duration.
    if (parserEvent.isDoT and currentProfile.dotThrottleDuration > 0) then
     throttleDuration = currentProfile.dotThrottleDuration

    -- Use the hot throttle duration.
    elseif (parserEvent.isHoT and currentProfile.hotThrottleDuration > 0) then
     throttleDuration = currentProfile.hotThrottleDuration

    -- Use the power change throttle duration.
    elseif (parserEvent.powerType and currentProfile.powerThrottleDuration > 0) then
     throttleDuration = currentProfile.powerThrottleDuration
    end
   end

   -- Check if there is a throttle duration for the ability.
   if (throttleDuration and throttleDuration > 0) then
    -- Get throttle info for the ability.  Create it if it hasn't already been.
    local throttledAbility = throttledAbilities[effectName]
    if (not throttledAbility) then
     throttledAbility = {}
     throttledAbility.throttleWindow = 0
     throttledAbility.lastEventTime = 0
     throttledAbilities[effectName] = throttledAbility
    end

    -- Throttle the event and exit if the throttle window for the ability hasn't elapsed.
    local now = GetTime()
    if (throttledAbility.throttleWindow > 0) then
      throttledAbility.lastEventTime = now
      throttledAbility[#throttledAbility+1] = combatEvent
      return

    -- The throttle window for the ability has elapsed.
    else
     -- Set the throttle window for the ability to its throttle duration.
     throttledAbility.throttleWindow = throttleDuration

     -- Check if the throttle frame is not visible and make it visible so the OnUpdate events start firing.
     -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
     if (not throttleFrame:IsVisible()) then throttleFrame:Show() end

     -- Throttle the event and exit if it has been seen within the throttle duration.
     if (now - throttledAbility.lastEventTime < throttleDuration) then
      throttledAbility.lastEventTime = now
      throttledAbility[#throttledAbility+1] = combatEvent 
      return
     end
    end
   end -- Has throttle duration.
  end -- Has effectName.
  
  -- Add event to the unmerged events for potential merging.
  unmergedEvents[#unmergedEvents+1] = combatEvent
  
  -- Check if the merge event frame is not visible and make it visible so the OnUpdate events start firing.
  -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
  if (not eventFrame:IsVisible()) then eventFrame:Show() end
 end -- Merge eligibility.
end


-- ****************************************************************************
-- Called when the event frame is updated.
-- ****************************************************************************
local function OnUpdateEventFrame(this, elapsed)
 -- Increment the amount of time passed since the last update. 
 lastMergeUpdate = lastMergeUpdate + elapsed

 -- If it's time for an update.
 if (lastMergeUpdate >= MERGE_DELAY_TIME) then
  -- Local references for faster access.
  local currentProfile = MSBTProfiles.currentProfile
  local hideNames = currentProfile.hideNames
  local exclusiveSkillsDisabled = currentProfile.exclusiveSkillsDisabled 

  -- Merge like events.
  MergeEvents(#unmergedEvents, currentProfile)

  -- Display and recycle the merged events.
  local eventSettings, hideSkills, outputMessage
  for i, combatEvent in ipairs(mergedEvents) do
   eventSettings = currentProfile.events[combatEvent.isCrit and combatEvent.eventType .. "_CRIT" or combatEvent.eventType]
   hideSkills = combatEvent.effectTexture and not exclusiveSkillsDisabled or currentProfile.hideSkills
   outputMessage = FormatEvent(eventSettings.message, combatEvent.amount, combatEvent.damageType, combatEvent.overhealAmount, combatEvent.overkillAmount, combatEvent.powerType, combatEvent.name, combatEvent.class, combatEvent.effectName, combatEvent.partialEffects, combatEvent.mergeTrailer, combatEvent.ignoreDamageColoring, hideSkills, hideNames)
   DisplayEvent(eventSettings, outputMessage, combatEvent.effectTexture)
   mergedEvents[i] = nil
   EraseTable(combatEvent)
   combatEventCache[#combatEventCache+1] = combatEvent
  end

  -- Hide the frame if there are no remaining unmerged events so the OnUpdate events stop firing.
  -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
  if (#unmergedEvents == 0) then this:Hide() end 
  
  -- Reset the time since last update.
  lastMergeUpdate = 0
 end
end


-- ****************************************************************************
-- Called when the throttle frame is updated.
-- ****************************************************************************
local function OnUpdateThrottleFrame(this, elapsed)
 -- Increment the amount of time passed since the last update. 
 lastThrottleUpdate = lastThrottleUpdate + elapsed

 -- If it's time for an update.
 if (lastThrottleUpdate >= THROTTLE_UPDATE_TIME) then
  -- Flag for whether there are any events currently throttled.
  local eventsThrottled

  -- Loop through all the throttled abilities.
  for _, throttledAbility in pairs(throttledAbilities) do
   -- Check if the ability is currently being throttled.
   if (throttledAbility.throttleWindow > 0) then
    -- Decrement the throttle window.
    throttledAbility.throttleWindow = throttledAbility.throttleWindow - lastThrottleUpdate

    -- Check if the throttle window has elapsed.
    if (throttledAbility.throttleWindow <= 0) then
     -- Add throttled events to the merging system if there are any.
     if (#throttledAbility > 0) then 
      for i = 1, #throttledAbility do
       unmergedEvents[#unmergedEvents+1] = throttledAbility[i]
       throttledAbility[i] = nil
      end

      -- Check if the merge event frame is not visible and make it visible so the OnUpdate events start firing.
      -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
      if (not eventFrame:IsVisible()) then eventFrame:Show() end
     end
    -- Ability is still throttled so set the flag.
	else
     eventsThrottled = true
    end
   end -- Ability is within its throttle window.
  end -- Loop through throttled abilities.


  -- Hide the frame if there are no remaining throttled events so the OnUpdate events stop firing.
  -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
  if (not eventsThrottled) then this:Hide() end
  
  -- Reset the time since last update.
  lastThrottleUpdate = 0
 end
end


-- ****************************************************************************
-- Called when a unit's power changes.
-- ****************************************************************************
function eventFrame:UNIT_POWER(unitID, powerToken)
 -- Ignore the event if it isn't for the player.
 if (unitID ~= "player") then return end
 
 -- Ignore the event if it isn't for a known power type.
 local powerType = powerTypes[powerToken]
 if (not powerType) then return end
 
 -- Get the current power amount for the power type that changed.
 local powerAmount = UnitPower("player", powerType)

 local doFullDetect = true
 local lastPowerAmount = lastPowerAmounts[powerType]

 -- Handle chi uniquely.
 if (powerToken == "CHI" and playerClass == "MONK") then
  if (powerAmount ~= lastPowerAmount) then HandleChi(powerAmount, powerType) end
  doFullDetect = false

 -- Handle holy power uniquely.
 elseif (powerToken == "HOLY_POWER" and playerClass == "PALADIN") then
  if (powerAmount ~= lastPowerAmount) then HandleHolyPower(powerAmount, powerType) end
  doFullDetect = false

 -- Handle Combo Points uniquely.
 elseif (powerToken == "COMBO_POINTS" and playerClass == "ROGUE") then
  if (powerAmount ~= lastPowerAmount) then HandleComboPoints(powerAmount, powerType) end
  doFullDetect = false
  
 elseif (powerToken == "COMBO_POINTS" and playerClass == "DRUID") then
  if (powerAmount ~= lastPowerAmount) then HandleComboPoints(powerAmount, powerType) end
  doFullDetect = false
  
 end

 -- Detect power gains if show all power gains is enabled.
 if (doFullDetect and MSBTProfiles.currentProfile.showAllPowerGains) then DetectPowerGain(powerAmount, powerType) end
 lastPowerAmounts[powerType] = powerAmount
end


-- ****************************************************************************
-- Called when the player leaves combat.
-- ****************************************************************************
function eventFrame:PLAYER_REGEN_ENABLED()
 -- Get the event settings for leaving combat and display it if it isn't disabled.
 local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_COMBAT_LEAVE
 if (not eventSettings.disabled) then DisplayEvent(eventSettings, eventSettings.message) end
end


-- ****************************************************************************
-- Called when the player enters combat.
-- ****************************************************************************
function eventFrame:PLAYER_REGEN_DISABLED()
 -- Get the event settings for entering combat and display it if it isn't disabled.
 local eventSettings = MSBTProfiles.currentProfile.events.NOTIFICATION_COMBAT_ENTER
 if (not eventSettings.disabled) then DisplayEvent(eventSettings, eventSettings.message) end
end


-- ****************************************************************************
-- Called when a unit's combo points change.
-- ****************************************************************************
function eventFrame:CHAT_MSG_MONSTER_EMOTE(message, sourceName)
 -- Ignore the event if it's not the current target.
 if (sourceName ~= UnitName("target")) then return end
 HandleMonsterEmotes(string_gsub(message, "%%s", sourceName))
end


-- ****************************************************************************
-- Enables the module.
-- ****************************************************************************
local function Enable()
 -- Register events to handle extra notifications.
 eventFrame:RegisterEvent("UNIT_POWER")
 eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
 eventFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
 eventFrame:RegisterEvent("CHAT_MSG_MONSTER_EMOTE")
 
 -- Register the parser events handler.
 MSBTParser.RegisterHandler(ParserEventsHandler)
end


-- ****************************************************************************
-- Disables the module.
-- ****************************************************************************
local function Disable()
 -- Stop receiving updates.
 eventFrame:Hide()
 eventFrame:UnregisterAllEvents()
 
 -- Unregister the parser events handler.
 MSBTParser.UnregisterHandler(ParserEventsHandler)
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

-- Setup event frame.
eventFrame:Hide()
eventFrame:SetScript("OnEvent", function (self, event, ...) if (self[event]) then self[event](self, ...) end end)
eventFrame:SetScript("OnUpdate", OnUpdateEventFrame)
 
-- Setup throttle frame.
throttleFrame:Hide()
throttleFrame:SetScript("OnUpdate", OnUpdateThrottleFrame)

-- Get the player's class.
_, playerClass = UnitClass("player")

-- Create the map of handlers to call for each event.
eventHandlers["damage"] = DamageHandler
eventHandlers["miss"] = MissHandler
eventHandlers["heal"] = HealHandler
eventHandlers["interrupt"] = InterruptHandler
eventHandlers["environmental"] = EnvironmentalHandler
eventHandlers["aura"] = AuraHandler
eventHandlers["enchant"] = EnchantHandler
eventHandlers["dispel"] = DispelHandler
eventHandlers["power"] = PowerHandler
eventHandlers["kill"] = KillHandler
eventHandlers["honor"] = HonorHandler
eventHandlers["reputation"] = ReputationHandler
eventHandlers["proficiency"] = ProficiencyHandler
eventHandlers["experience"] = ExperienceHandler
eventHandlers["extraattacks"] = ExtraAttacksHandler
 
-- Create the power tokens lookup map.
for powerToken, powerType in pairs(powerTypes) do
 powerTokens[powerType] = powerToken
end

-- Create map of power types that are handled uniquely.
uniquePowerTypes[powerTypes["HOLY_POWER"]] = true
uniquePowerTypes[powerTypes["CHI"]] = true
uniquePowerTypes[powerTypes["COMBO_POINTS"]] = true

-- Create damage type and damage color profile maps.
CreateDamageMaps()
 
-- Set the isEnglish flag correctly.
if (string_find(GetLocale(), "en..")) then isEnglish = true end
 
-- Add auras to always ignore.
ignoreAuras[SPELL_BLINK] = true
--ignoreAuras[SPELL_BLIZZARD] = true
--ignoreAuras[SPELL_HELLFIRE] = true
--ignoreAuras[SPELL_HURRICANE] = true
ignoreAuras[SPELL_RAIN_OF_FIRE] = true

-- Get localized off-hand trailer and convert to a lua search pattern.
if (SPELL_BLOOD_STRIKE ~= UNKNOWN) then
 --offHandTrailer = string_gsub(SPELL_BLOOD_STRIKE_OFF_HAND, SPELL_BLOOD_STRIKE, "")
 offHandPattern = string_gsub(SPELL_BLOOD_STRIKE, "([%^%(%)%.%[%]%*%+%-%?])", "%%%1")
end




-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Variables.
module.damageTypeMap				= damageTypeMap
module.damageColorProfileEntries	= damageColorProfileEntries

-- Protected Functions.
module.Enable				= Enable
module.Disable				= Disable


------------------------------------------------------------------------------------
-- API.
-------------------------------------------------------------------------------

-- Public Constants.
MikSBT.DISPLAYTYPE_INCOMING			= "Incoming"
MikSBT.DISPLAYTYPE_OUTGOING			= "Outgoing"
MikSBT.DISPLAYTYPE_NOTIFICATION		= "Notification"
MikSBT.DISPLAYTYPE_STATIC			= "Static"

-- Public Functions.
MikSBT.RegisterFont					= MSBTMedia.RegisterFont
MikSBT.RegisterAnimationStyle		= MSBTAnimations.RegisterAnimationStyle
MikSBT.RegisterStickyAnimationStyle	= MSBTAnimations.RegisterStickyAnimationStyle
MikSBT.RegisterSound				= MSBTMedia.RegisterSound
MikSBT.IterateFonts					= MSBTMedia.IterateFonts
MikSBT.IterateScrollAreas			= MSBTAnimations.IterateScrollAreas
MikSBT.IterateSounds				= MSBTMedia.IterateSounds
MikSBT.DisplayMessage				= MSBTAnimations.DisplayMessage
MikSBT.IsModDisabled				= MSBTProfiles.IsModDisabled
