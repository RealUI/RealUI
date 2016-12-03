-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Profiles
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Profiles"
MikSBT[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various modules for faster access.
local L = MikSBT.translations

-- Local references to various functions for faster access.
local string_find = string.find
local string_gsub = string.gsub
local string_format = string.format
local CopyTable = MikSBT.CopyTable
local EraseTable = MikSBT.EraseTable
local SplitString = MikSBT.SplitString
local Print = MikSBT.Print
local GetSkillName = MikSBT.GetSkillName


-------------------------------------------------------------------------------
-- Private constants.
-------------------------------------------------------------------------------

local DEFAULT_PROFILE_NAME = "Default"

-- The .toc entries for saved variables.
local SAVED_VARS_NAME			= "MSBTProfiles_SavedVars"
local SAVED_VARS_PER_CHAR_NAME	= "MSBTProfiles_SavedVarsPerChar"
local SAVED_MEDIA_NAME			= "MSBT_SavedMedia"

-- Localized pet name followed by a space.
local PET_SPACE = PET .. " "

-- Flags used by the combat log.
local FLAG_YOU 			= 0xF0000000
local TARGET_TARGET		= 0x00010000
local REACTION_HOSTILE		= 0x00000040


-- Spell IDs.
--local SPELLID_BERSERK			= 93622
local SPELLID_ELUSIVE_BREW		= 126453 -- Activated ability
local SPELLID_EXECUTE			= 5308
local SPELLID_FIRST_AID		= 3273
local SPELLID_HAMMER_OF_WRATH	= 24275
--local SPELLID_KILL_SHOT		= 53351
local SPELLID_LAVA_SURGE		= 77762
local SPELLID_REVENGE			= 6572
local SPELLID_VICTORY_RUSH		= 34428
--local SPELLID_SHADOW_ORB		= 77487

-- Trigger spell names.
--local SPELL_BERSERK				= GetSkillName(SPELLID_BERSERK)
--local SPELL_BLINDSIDE				= GetSkillName(121153)
--local SPELL_BLOODSURGE				= GetSkillName(46916)
--local SPELL_BRAIN_FREEZE			= GetSkillName(44549)
--local SPELL_BF_FIREBALL			= GetSkillName(57761)
local SPELL_CLEARCASTING			= GetSkillName(16870)
--local SPELL_DECIMATION				= GetSkillName(108869)
local SPELL_ELUSIVE_BREW			= GetSkillName(128939)
local SPELL_EXECUTE				= GetSkillName(SPELLID_EXECUTE)
local SPELL_FINGERS_OF_FROST		= GetSkillName(112965)
local SPELL_FREEZING_FOG			= GetSkillName(59052)
local SPELL_HAMMER_OF_WRATH		= GetSkillName(SPELLID_HAMMER_OF_WRATH)
--local SPELL_KILL_SHOT				= GetSkillName(SPELLID_KILL_SHOT)
local SPELL_KILLING_MACHINE		= GetSkillName(51124)
local SPELL_LAVA_SURGE				= GetSkillName(SPELLID_LAVA_SURGE)
--local SPELL_LOCK_AND_LOAD			= GetSkillName(168980)
--local SPELL_MAELSTROM_WEAPON		= GetSkillName(53817)
--local SPELL_MANA_TEA				= GetSkillName(115867)
local SPELL_MISSILE_BARRAGE		= GetSkillName(62401)
--local SPELL_MOLTEN_CORE			= GetSkillName(122351)
--local SPELL_NIGHTFALL				= GetSkillName(108558)
local SPELL_PREDATORS_SWIFTNESS	= GetSkillName(69369)
local SPELL_PVP_TRINKET			= GetSkillName(42292)
local SPELL_REVENGE				= GetSkillName(SPELLID_REVENGE)
local SPELL_RIME 					= GetSkillName(59057)
local SPELL_SHADOW_TRANCE			= GetSkillName(17941)
local SPELL_SHIELD_SLAM			= GetSkillName(23922)
--local SPELL_SHADOW_INFUSION		= GetSkillName(91342)
--local SPELL_SHADOW_ORB				= GetSkillName(SPELLID_SHADOW_ORB)
--local SPELL_SHOOTING_STARS			= GetSkillName(93400)
local SPELL_SUDDEN_DEATH			= GetSkillName(52437)
local SPELL_SUDDEN_DOOM			= GetSkillName(81340)	-- XXX: No trigger atm - DK
--local SPELL_SWORD_AND_BOARD		= GetSkillName(50227)
--local SPELL_TASTE_FOR_BLOOD		= GetSkillName(56636)
--local SPELL_THE_ART_OF_WAR			= GetSkillName(59578)
local SPELL_TIDAL_WAVES			= GetSkillName(53390)
local SPELL_ULTIMATUM			= GetSkillName(122510)
local SPELL_VICTORY_RUSH			= GetSkillName(SPELLID_VICTORY_RUSH)  -- XXX: Update for buff
--local SPELL_VITAL_MISTS			= GetSkillName(122107)

-- Throttle, suppression, and other spell names.
--local SPELL_BLOOD_PRESENCE			= GetSkillName(48266)
local SPELL_DRAIN_LIFE				= GetSkillName(689)
local SPELL_SHADOWMEND				= GetSkillName(39373)
--local SPELL_REFLECTIVE_SHIELD		= GetSkillName(58252)
local SPELL_UNDYING_RESOLVE		= GetSkillName(51915)
local SPELL_VAMPIRIC_EMBRACE		= GetSkillName(15286)
local SPELL_VAMPIRIC_TOUCH			= GetSkillName(34914)



-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

--- Prevent tainting global _.
local _

-- Dynamically created frame for receiving events.
local eventFrame

-- Meta table for the differential profile tables.
local differentialMap = {}
local differential_mt = { __index = function(t,k) return differentialMap[t][k] end }
local differentialCache = {}

-- Holds variables to be saved between sessions.
local savedVariables
local savedVariablesPerChar
local savedMedia

-- Currently selected profile.
local currentProfile

-- Path information for setting differential options.
local pathTable = {}

-- Flag to hold whether or not this is the first load.
local isFirstLoad


-------------------------------------------------------------------------------
-- Master profile utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Returns a table to be used for the settings of the passed class using color
-- information from the default class colors table.
-- ****************************************************************************
local function CreateClassSettingsTable(class)
 -- Return disabled settings if the class doesn't exist in the default class colors table for some reason.
 if (not RAID_CLASS_COLORS[class]) then return { disabled = true, colorR = 1, colorG = 1, colorB = 1 } end

 -- Return a table using the default class color. 
 return { colorR = RAID_CLASS_COLORS[class].r, colorG = RAID_CLASS_COLORS[class].g, colorB = RAID_CLASS_COLORS[class].b }
end



-------------------------------------------------------------------------------
-- Master profile.
-------------------------------------------------------------------------------

local masterProfile = {
 -- Scroll area settings.
 scrollAreas = {
  Incoming = {
   name					= L.MSG_INCOMING,
   offsetX				= -140,
   offsetY				= -160,
   animationStyle		= "Parabola",
   direction			= "Down",
   behavior				= "CurvedLeft",
   stickyBehavior		= "Jiggle",
   textAlignIndex		= 3,
   stickyTextAlignIndex	= 3,
  },
  Outgoing = {
   name					= L.MSG_OUTGOING,
   offsetX				= 100,
   offsetY				= -160,
   animationStyle		= "Parabola",
   direction			= "Down",
   behavior				= "CurvedRight",
   stickyBehavior		= "Jiggle",
   textAlignIndex		= 1,
   stickyTextAlignIndex	= 1,
   iconAlign			= "Right",
  },
  Notification = {
   name					= L.MSG_NOTIFICATION,
   offsetX				= -175,
   offsetY				= 120,
   scrollHeight			= 200,
   scrollWidth			= 350,
  },
  Static = {
   name					= L.MSG_STATIC,
   offsetX				= -20,
   offsetY				= -300,
   scrollHeight			= 125,
   animationStyle		= "Static",
   direction			= "Down",
  },
 },

 
 -- Built-in event settings.
 events = {
  INCOMING_DAMAGE = {
   colorG		= 0,
   colorB		= 0,
   message		= "(%n) -%a",
   scrollArea	= "Incoming",
  },
  INCOMING_DAMAGE_CRIT = {
   colorG		= 0,
   colorB		= 0,
   message		= "(%n) -%a",
   scrollArea	= "Incoming",
   isCrit		= true,
  },
  INCOMING_MISS = {
   colorR		= 0,
   colorG		= 0,
   message		= MISS .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_DODGE = {
   colorR		= 0,
   colorG		= 0,
   message		= DODGE .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_PARRY = {
   colorR		= 0,
   colorG		= 0,
   message		= PARRY .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_BLOCK = {
   colorR		= 0,
   colorG		= 0,
   message		= BLOCK .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_DEFLECT = {
   colorR		= 0,
   colorG		= 0,
   message		= DEFLECT .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_ABSORB = {
   colorB		= 0,
   message		= ABSORB .. "! <%a>",
   scrollArea	= "Incoming",
  },
  INCOMING_IMMUNE = {
   colorB		= 0,
   message		= IMMUNE .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_DAMAGE = {
   colorG		= 0,
   colorB		= 0,
   message		= "(%s) -%a",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_DAMAGE_CRIT = {
   colorG		= 0,
   colorB		= 0,
   message		= "(%s) -%a",
   scrollArea	= "Incoming",
   isCrit		= true,
  },
  INCOMING_SPELL_DAMAGE_SHIELD = {
   colorG		= 0,
   colorB		= 0,
   message		= "(%s) -%a",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_DAMAGE_SHIELD_CRIT = {
   colorG		= 0,
   colorB		= 0,
   message		= "(%s) -%a",
   scrollArea	= "Incoming",
   isCrit		= true,
  },
  INCOMING_SPELL_DOT = {
   colorG		= 0,
   colorB		= 0,
   message		= "(%s) -%a",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_DOT_CRIT = {
   colorG		= 0,
   colorB		= 0,
   message		= "(%s) -%a",
   scrollArea	= "Incoming",
   isCrit		= true,
  },
  INCOMING_SPELL_MISS = {
   colorR		= 0,
   colorG		= 0,
   message		= "(%s) " .. MISS .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_DODGE = {
   colorR		= 0,
   colorG		= 0,
   message		= "(%s) " .. DODGE .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_PARRY = {
   colorR		= 0,
   colorG		= 0,
   message		= "(%s) " .. PARRY .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_BLOCK = {
   colorR		= 0,
   colorG		= 0,
   message		= "(%s) " .. BLOCK  .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_DEFLECT = {
   colorR		= 0,
   colorG		= 0,
   message		= "(%s) " .. DEFLECT .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_RESIST = {
   colorR		= 0.5,
   colorG		= 0,
   colorB		= 0.5,
   message		= "(%s) " .. RESIST .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_ABSORB = {
   colorB		= 0,
   message		= "(%s) " .. ABSORB .. "! <%a>",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_IMMUNE = {
   colorB		= 0,
   message		= "(%s) " .. IMMUNE .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_REFLECT = {
   colorR		= 0.5,
   colorG		= 0,
   colorB		= 0.5,
   message		= "(%s) " .. REFLECT .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_SPELL_INTERRUPT = {
   colorB		= 0,
   message		= "(%s) " .. INTERRUPT .. "!",
   scrollArea	= "Incoming",
  },
  INCOMING_HEAL = {
   colorR		= 0,
   colorB		= 0,
   message		= "(%s - %n) +%a",
   scrollArea	= "Incoming",
  },
  INCOMING_HEAL_CRIT = {
   colorR		= 0,
   colorB		= 0,
   message		= "(%s - %n) +%a",
   fontSize		= 22,
   scrollArea	= "Incoming",
   isCrit		= true,
  },
  INCOMING_HOT = {
   colorR		= 0,
   colorB		= 0,
   message		= "(%s - %n) +%a",
   scrollArea	= "Incoming",
  },
  INCOMING_HOT_CRIT = {
   colorR		= 0,
   colorB		= 0,
   message		= "(%s - %n) +%a",
   scrollArea	= "Incoming",
   isCrit		= true,
  },
  INCOMING_ENVIRONMENTAL = {
   colorG		= 0,
   colorB		= 0,
   message		= "-%a %e",
   scrollArea	= "Incoming",
  },


  OUTGOING_DAMAGE = {
   message		= "%a",
   scrollArea	= "Outgoing",
  },
  OUTGOING_DAMAGE_CRIT = {
   message		= "%a",
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  OUTGOING_MISS = {
   message		= MISS .. "!",
   scrollArea	= "Outgoing",
  },
  OUTGOING_DODGE = {
   message		= DODGE .. "!",
   scrollArea	= "Outgoing",
  },
  OUTGOING_PARRY = {
   message		= PARRY .. "!",
   scrollArea	= "Outgoing",
  },
  OUTGOING_BLOCK = {
   message		= BLOCK .. "!",
   scrollArea	= "Outgoing",
  },
  OUTGOING_DEFLECT = {
   message		= DEFLECT.. "!",
   scrollArea	= "Outgoing",
  },
  OUTGOING_ABSORB = {
   colorB		= 0,
   message		= "<%a> " .. ABSORB .. "!",
   scrollArea	= "Outgoing",
  },
  OUTGOING_IMMUNE = {
   colorB		= 0,
   message		= IMMUNE .. "!",
   scrollArea	= "Outgoing",
  },
  OUTGOING_EVADE = {
   colorG		= 0.5,
   colorB		= 0,
   message		= EVADE .. "!",
   fontSize		= 22,
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_DAMAGE = {
   colorB		= 0,
   message		= "%a (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_DAMAGE_CRIT = {
   colorB		= 0,
   message		= "%a (%s)",
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  OUTGOING_SPELL_DAMAGE_SHIELD = {
   colorB		= 0,
   message		= "%a (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_DAMAGE_SHIELD_CRIT = {
   colorB		= 0,
   message		= "%a (%s)",
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  OUTGOING_SPELL_DOT = {
   colorB		= 0,
   message		= "%a (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_DOT_CRIT = {
   colorB		= 0,
   message		= "%a (%s)",
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  OUTGOING_SPELL_MISS = {
   message		= MISS .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_DODGE = {
   message		= DODGE .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_PARRY = {
   message		= PARRY .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_BLOCK = {
   message		= BLOCK .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_DEFLECT = {
   message		= DEFLECT .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_RESIST = {
   colorR		= 0.5,
   colorG		= 0.5,
   colorB		= 0.698,
   message		= RESIST .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_ABSORB = {
   colorB		= 0,
   message		= "<%a> " .. ABSORB .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_IMMUNE = {
   colorB		= 0,
   message		= IMMUNE .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_REFLECT = {
   colorB		= 0,
   message		= REFLECT .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_INTERRUPT = {
   colorB		= 0,
   message		= INTERRUPT .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_SPELL_EVADE = {
   colorG		= 0.5,
   colorB		= 0,
   message		= EVADE .. "! (%s)",
   fontSize		= 22,
   scrollArea	= "Outgoing",
  },
  OUTGOING_HEAL = {
   colorR		= 0,
   colorB		= 0,
   message		= "+%a (%s - %n)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_HEAL_CRIT = {
   colorR		= 0,
   colorB		= 0,
   message		= "+%a (%s - %n)",
   fontSize		= 22,
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  OUTGOING_HOT = {
   colorR		= 0,
   colorB		= 0,
   message		= "+%a (%s - %n)",
   scrollArea	= "Outgoing",
  },
  OUTGOING_HOT_CRIT = {
   colorR		= 0,
   colorB		= 0,
   message		= "+%a (%s - %n)",
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  OUTGOING_DISPEL = {
   colorB		= 0.5,
   message		= L.MSG_DISPEL .. "! (%s)",
   scrollArea	= "Outgoing",
  },


  PET_INCOMING_DAMAGE = {
   colorG		= 0.41,
   colorB		= 0.41,
   message		= "(%n) " .. PET .. " -%a",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_DAMAGE_CRIT = {
   colorG		= 0.41,
   colorB		= 0.41,
   message		= "(%n) " .. PET .. " -%a",
   scrollArea	= "Incoming",
   isCrit		= true,
  },
  PET_INCOMING_MISS = {
   colorR		= 0.57,
   colorG		= 0.58,
   message		= PET .. " " .. MISS .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_DODGE = {
   colorR		= 0.57,
   colorG		= 0.58,
   message		= PET .. " " .. DODGE .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_PARRY = {
   colorR		= 0.57,
   colorG		= 0.58,
   message		= PET .. " " .. PARRY .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_BLOCK = {
   colorR		= 0.57,
   colorG		= 0.58,
   message		= PET .. " " .. BLOCK .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_DEFLECT = {
   colorR		= 0.57,
   colorG		= 0.58,
   message		= PET .. " " .. DEFLECT .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_ABSORB = {
   colorB		= 0.57,
   message		= PET .. " " .. ABSORB .. "!  <%a>",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_IMMUNE = {
   colorB		= 0.57,
   message		= PET .. " " .. IMMUNE .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_SPELL_DAMAGE = {
   colorG		= 0.41,
   colorB		= 0.41,
   message		= "(%s) " .. PET .. " -%a",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_SPELL_DAMAGE_CRIT = {
   colorG		= 0.41,
   colorB		= 0.41,
   message		= "(%s) " .. PET .. " -%a",
   scrollArea	= "Incoming",
   isCrit		= true,
  },
  PET_INCOMING_SPELL_DAMAGE_SHIELD = {
   colorG		= 0.41,
   colorB		= 0.41,
   message		= "(%s) " .. PET .. " -%a",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT = {
   colorG		= 0.41,
   colorB		= 0.41,
   message		= "(%s) " .. PET .. " -%a",
   scrollArea	= "Incoming",
   isCrit		= true,
  },
  PET_INCOMING_SPELL_DOT = {
   colorG		= 0.41,
   colorB		= 0.41,
   message		= "(%s) " .. PET .. " -%a",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_SPELL_DOT_CRIT = {
   colorG		= 0.41,
   colorB		= 0.41,
   message		= "(%s) " .. PET .. " -%a",
   scrollArea	= "Incoming",
   isCrit		= true,
  },
  PET_INCOMING_SPELL_MISS = {
   colorR		= 0.57,
   colorG		= 0.58,
   message		= "(%s) " .. PET .. " " .. MISS .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_SPELL_DODGE = {
   colorR		= 0.57,
   colorG		= 0.58,
   message		= "(%s) " .. PET .. " " .. DODGE .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_SPELL_PARRY = {
   colorR		= 0.57,
   colorG		= 0.58,
   message		= "(%s) " .. PET .. " " .. PARRY .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_SPELL_BLOCK = {
   colorR		= 0.57,
   colorG		= 0.58,
   message		= "(%s) " .. PET .. " " .. BLOCK  .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_SPELL_DEFLECT = {
   colorR		= 0.57,
   colorG		= 0.58,
   message		= "(%s) " .. PET .. " " .. DEFLECT  .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_SPELL_RESIST = {
   colorR		= 0.94,
   colorG		= 0,
   colorB		= 0.94,
   message		= "(%s) " .. PET .. " " .. RESIST .. "!",
   scrollArea		= "Incoming",
  },
  PET_INCOMING_SPELL_ABSORB = {
   colorB		= 0.57,
   message		= "(%s) " .. PET .. " " .. ABSORB .. "!  <%a>",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_SPELL_IMMUNE = {
   colorB		= 0.57,
   message		= "(%s) " .. PET .. " " .. IMMUNE .. "!",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_HEAL = {
   colorR		= 0.57,
   colorB		= 0.57,
   message		= "(%s - %n) " .. PET .. " +%a",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_HEAL_CRIT = {
   colorR		= 0.57,
   colorB		= 0.57,
   message		= "(%s - %n) " .. PET .. " +%a",
   scrollArea	= "Incoming",
   isCrit		= true,
  },
  PET_INCOMING_HOT = {
   colorR		= 0.57,
   colorB		= 0.57,
   message		= "(%s - %n) " .. PET .. " +%a",
   scrollArea	= "Incoming",
  },
  PET_INCOMING_HOT_CRIT = {
   colorR		= 0.57,
   colorB		= 0.57,
   message		= "(%s - %n) " .. PET .. " +%a",
   scrollArea	= "Incoming",
   isCrit		= true,
  },


  PET_OUTGOING_DAMAGE = {
   colorG		= 0.5,
   colorB		= 0,
   message		= PET .. " %a",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_DAMAGE_CRIT = {
   colorG		= 0.5,
   colorB		= 0,
   message		= PET .. " %a",
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  PET_OUTGOING_MISS = {
   colorG		= 0.5,
   colorB		= 0,
   message		= PET .. " " .. MISS,
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_DODGE = {
   colorG		= 0.5,
   colorB		= 0,
   message		= PET .. " " .. DODGE,
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_PARRY = {
   colorG		= 0.5,
   colorB		= 0,
   message		= PET .. " " .. PARRY,
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_BLOCK = {
   colorG		= 0.5,
   colorB		= 0,
   message		= PET .. " " .. BLOCK,
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_DEFLECT = {
   colorG		= 0.5,
   colorB		= 0,
   message		= PET .. " " .. DEFLECT,
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_ABSORB = {
   colorR		= 0.5,
   colorG		= 0.5,
   message		= PET .. " <%a> " .. ABSORB,
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_IMMUNE = {
   colorR		= 0.5,
   colorG		= 0.5,
   message		= PET .. " " .. IMMUNE,
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_EVADE = {
   colorG		= 0.77,
   colorB		= 0.57,
   message		= PET .. " " .. EVADE,
   fontSize		= 22,
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_DAMAGE = {
   colorR		= 0.33,
   colorG		= 0.33,
   message		= PET .. " %a (%s)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_DAMAGE_CRIT = {
   colorR		= 0.33,
   colorG		= 0.33,
   message		= PET .. " %a (%s)",
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  PET_OUTGOING_SPELL_DAMAGE_SHIELD = {
   colorR		= 0.33,
   colorG		= 0.33,
   message		= PET .. " %a (%s)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT = {
   colorR		= 0.33,
   colorG		= 0.33,
   message		= PET .. " %a (%s)",
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  PET_OUTGOING_SPELL_DOT = {
   colorR		= 0.33,
   colorG		= 0.33,
   message		= PET .. " %a (%s)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_DOT_CRIT = {
   colorR		= 0.33,
   colorG		= 0.33,
   message		= PET .. " %a (%s)",
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  PET_OUTGOING_SPELL_MISS = {
   colorR		= 0.33,
   colorG		= 0.33,
   message		= PET .. " " .. MISS .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_DODGE = {
   colorR		= 0.33,
   colorG		= 0.33,
   message		= PET .. " " .. DODGE .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_PARRY = {
   colorR		= 0.33,
   colorG		= 0.33,
   message		= PET .. " " .. PARRY .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_BLOCK = {
   colorR		= 0.33,
   colorG		= 0.33,
   message		= PET .. " " .. BLOCK .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_DEFLECT = {
   colorR		= 0.33,
   colorG		= 0.33,
   message		= PET .. " " .. DEFLECT .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_RESIST = {
   colorR		= 0.73,
   colorG		= 0.73,
   colorB		= 0.84,
   message		= PET .. " " .. RESIST .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_ABSORB = {
   colorR		= 0.5,
   colorG		= 0.5,
   message		= PET .. " <%a> " .. ABSORB .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_IMMUNE = {
   colorR		= 0.5,
   colorG		= 0.5,
   message		= PET .. " " .. IMMUNE .. "! (%s)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_SPELL_EVADE = {
   colorG		= 0.77,
   colorB		= 0.57,
   message		= PET .. " " .. EVADE .. "! (%s)",
   scrollArea	= "Outgoing",
  }, 
  PET_OUTGOING_HEAL = {
   colorR		= 0.57,
   colorB		= 0.57,
   message		= PET .. " " .. "+%a (%s - %n)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_HEAL_CRIT = {
   colorR		= 0.57,
   colorB		= 0.57,
   message		= PET .. " " .. "+%a (%s - %n)",
   fontSize		= 22,
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  PET_OUTGOING_HOT = {
   colorR		= 0.57,
   colorB		= 0.57,
   message		= PET .. " " .. "+%a (%s - %n)",
   scrollArea	= "Outgoing",
  },
  PET_OUTGOING_HOT_CRIT = {
   colorR		= 0.57,
   colorB		= 0.57,
   message		= PET .. " " .. "+%a (%s - %n)",
   scrollArea	= "Outgoing",
   isCrit		= true,
  },
  PET_OUTGOING_DISPEL = {
   colorB		= 0.73,
   message		= PET .. " " .. L.MSG_DISPEL .. "! (%s)",
   scrollArea	= "Outgoing",
  },


  NOTIFICATION_DEBUFF = {
   colorR		= 0,
   colorG		= 0.5,
   colorB		= 0.5,
   message		= "[%sl]",
  },
  NOTIFICATION_DEBUFF_STACK = {
   colorR		= 0,
   colorG		= 0.5,
   colorB		= 0.5,
   message		= "[%sl %a]",
  },
  NOTIFICATION_BUFF = {
   colorR		= 0.698,
   colorG		= 0.698,
   colorB		= 0,
   message		= "[%sl]",
  },
  NOTIFICATION_BUFF_STACK = {
   colorR		= 0.698,
   colorG		= 0.698,
   colorB		= 0,
   message		= "[%sl %a]",
  },
  NOTIFICATION_ITEM_BUFF = {
   colorR		= 0.698,
   colorG		= 0.698,
   colorB		= 0.698,
   message		= "[%sl]",
  },
  NOTIFICATION_DEBUFF_FADE = {
   colorR		= 0,
   colorG		= 0.835,
   colorB		= 0.835,
   message		= "-[%sl]",
  },
  NOTIFICATION_BUFF_FADE = {
   colorR		= 0.918,
   colorG		= 0.918,
   colorB		= 0,
   message		= "-[%sl]",
  },
  NOTIFICATION_ITEM_BUFF_FADE = {
   colorR		= 0.831,
   colorG		= 0.831,
   colorB		= 0.831,
   message		= "-[%sl]",
  },
  NOTIFICATION_COMBAT_ENTER = {
   message		= "+" .. L.MSG_COMBAT,
  },
  NOTIFICATION_COMBAT_LEAVE = {
   message		= "-" .. L.MSG_COMBAT,
  },
  NOTIFICATION_POWER_GAIN = {
   colorB		= 0,
   message		= "+%a %p",
  },
  NOTIFICATION_POWER_LOSS = {
   colorB		= 0,
   message		= "-%a %p",
  },
  NOTIFICATION_ALT_POWER_GAIN = {
   colorR		= 0,
   colorG		= 0.5,
   colorB		= 0.5,
   message		= "+%a %p",
  },
  NOTIFICATION_ALT_POWER_LOSS = {
   colorR		= 0,
   colorG		= 0.5,
   colorB		= 0.5,
   message		= "-%a %p",
  },
  NOTIFICATION_CHI_CHANGE = {
   colorG		= 0.5,
   colorB		= 0,
   message		= "%a " .. CHI,
  },
  NOTIFICATION_CHI_FULL = {
   colorG		= 0.5,
   colorB		= 0,
   message		= L.MSG_CHI_FULL .. "!",
   alwaysSticky	= true,
   fontSize		= 26,
  },
  NOTIFICATION_CP_GAIN = {
   colorG		= 0.5,
   colorB		= 0,
   message		= "%a " .. L.MSG_CP,
  },
  NOTIFICATION_CP_FULL = {
   colorG		= 0.5,
   colorB		= 0,
   message		= L.MSG_CP_FULL .. "!",
   alwaysSticky	= true,
   fontSize		= 26,
  },
  NOTIFICATION_HOLY_POWER_CHANGE = {
   colorG		= 0.5,
   colorB		= 0,
   message		= "%a " .. HOLY_POWER,
  },
  NOTIFICATION_HOLY_POWER_FULL = {
   colorG		= 0.5,
   colorB		= 0,
   message		= L.MSG_HOLY_POWER_FULL .. "!",
   alwaysSticky	= true,
   fontSize		= 26,
  },
  --[[NOTIFICATION_SHADOW_ORBS_CHANGE = {
   colorR		= 0.756,
   colorG		= 0.270,
   colorB		= 0.823,
   message		= "%a " .. "|4" .. SPELL_SHADOW_ORB .. ":" .. SHADOW_ORBS,
  },]]
  NOTIFICATION_SHADOW_ORBS_FULL = {
   colorR		= 0.756,
   colorG		= 0.270,
   colorB		= 0.823,
   message		= L.MSG_SHADOW_ORBS_FULL .. "!",
   alwaysSticky	= true,
   fontSize		= 26,
  },
  NOTIFICATION_HONOR_GAIN = {
   colorR		= 0.5,
   colorG		= 0.5,
   colorB		= 0.698,
   message		= "+%a " .. HONOR,
  },
  NOTIFICATION_REP_GAIN = {
   colorR		= 0.5,
   colorG		= 0.5,
   colorB		= 0.698,
   message		= "+%a " .. REPUTATION .. " (%e)",
  },
  NOTIFICATION_REP_LOSS = {
   colorR		= 0.5,
   colorG		= 0.5,
   colorB		= 0.698,
   message		= "-%a " .. REPUTATION .. " (%e)",
  },
  NOTIFICATION_SKILL_GAIN = {
   colorR		= 0.333,
   colorG		= 0.333,
   message		= "%sl: %a",
  },
  NOTIFICATION_EXPERIENCE_GAIN = {
   disabled		= true,
   colorR		= 0.756,
   colorG		= 0.270,
   colorB		= 0.823,
   message		= "%a " .. XP,
   alwaysSticky	= true,
   fontSize		= 26,
  },
  NOTIFICATION_PC_KILLING_BLOW = {
   colorR		= 0.333,
   colorG		= 0.333,
   message		= L.MSG_KILLING_BLOW .. "! (%n)",
   alwaysSticky	= true,
   fontSize		= 26,
  },
  NOTIFICATION_NPC_KILLING_BLOW = {
   disabled		= true,
   colorR		= 0.333,
   colorG		= 0.333,
   message		= L.MSG_KILLING_BLOW .. "! (%n)",
   alwaysSticky	= true,
   fontSize		= 26,
  },
  NOTIFICATION_EXTRA_ATTACK = {
   colorB		= 0,
   message		= "%sl!",
   alwaysSticky	= true,
   fontSize		= 26,
  },
  NOTIFICATION_ENEMY_BUFF = {
   colorB		= 0.5,
   message		= "%n: [%sl]",
   scrollArea	= "Static",
  },
  NOTIFICATION_MONSTER_EMOTE = {
   colorG		= 0.5,
   colorB		= 0,
   message		= "%e",
   scrollArea	= "Static",
  },
  NOTIFICATION_MONEY = {
   message		= "+%e",
   scrollArea	= "Static",
  },
  NOTIFICATION_COOLDOWN = {
   message		= "%e " .. L.MSG_READY_NOW .. "!",
   scrollArea	= "Static",
   fontSize		= 22,
   soundFile	= "MSBT Cooldown",
   skillColorR	= 1,
   skillColorG	= 0,
   skillColorB	= 0,
  },
  NOTIFICATION_PET_COOLDOWN = {
   colorR		= 0.57,
   colorG		= 0.58,
   message		= PET .. " %e " .. L.MSG_READY_NOW .. "!",
   scrollArea	= "Static",
   fontSize		= 22,
   soundFile	= "MSBT Cooldown",
   skillColorR	= 1,
   skillColorG	= 0.41,
   skillColorB	= 0.41,
  },
  NOTIFICATION_ITEM_COOLDOWN = {
   colorR		= 0.784,
   colorG		= 0.784,
   colorB		= 0,
   message		= " %e " .. L.MSG_READY_NOW .. "!",
   scrollArea	= "Static",
   fontSize		= 22,
   soundFile	= "MSBT Cooldown",
   skillColorR	= 1,
   skillColorG	= 0.588,
   skillColorB	= 0.588,
  },
  NOTIFICATION_LOOT = {
   colorB		= 0,
   message		= "+%a %e (%t)",
   scrollArea	= "Static",
  },
  NOTIFICATION_CURRENCY = {
   colorB		= 0,
   message		= "+%a %e (%t)",
   scrollArea	= "Static",
  },
 }, -- End events

 
 -- Default trigger settings.
 triggers = {
  --[[MSBT_TRIGGER_BERSERK = {
   colorG			= 0.25,
   colorB			= 0.25,
   message			= SPELL_BERSERK,
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "DRUID",
   mainEvents		= "SPELL_AURA_APPLIED{skillID;;eq;;" .. SPELLID_BERSERK .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },]]
  --[[MSBT_TRIGGER_BLINDSIDE = {
   colorR			= 0.709,
   colorG			= 0,
   colorB			= 0.709,
   message			= SPELL_BLINDSIDE .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "ROGUE",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_BLINDSIDE .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}"
  },]]
  --[[MSBT_TRIGGER_BLOODSURGE = {
   colorR			= 0.8,
   colorG			= 0.5,
   colorB			= 0.5,
   message			= SPELL_BLOODSURGE .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "WARRIOR",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_BLOODSURGE .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}"
  },]]
  --[[MSBT_TRIGGER_BRAIN_FREEZE = {
   colorG			= 0.627,
   colorB			= 0.627,
   message			= SPELL_BRAIN_FREEZE .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "MAGE",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_BF_FIREBALL .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },]]
  MSBT_TRIGGER_CLEARCASTING = {
   colorB			= 0,
   message			= SPELL_CLEARCASTING .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "DRUID,MAGE,PRIEST,SHAMAN",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_CLEARCASTING .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },
  --[[MSBT_TRIGGER_DECIMATION = {
   colorG			= 0.627,
   colorB			= 0.627,
   message			= SPELL_DECIMATION .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "WARLOCK",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_DECIMATION .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },]]
  MSBT_TRIGGER_ELUSIVE_BREW = {
   colorB			= 0,
   message			= SPELL_ELUSIVE_BREW .. " x%a!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "MONK",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_ELUSIVE_BREW .. ";;amount;;eq;;5;;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}&&" ..
					  "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_ELUSIVE_BREW .. ";;amount;;eq;;10;;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}&&" ..
					  "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_ELUSIVE_BREW .. ";;amount;;eq;;15;;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },
  MSBT_TRIGGER_EXECUTE = {
   colorB			= 0,
   message			= SPELL_EXECUTE .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "WARRIOR",
   mainEvents		= "UNIT_HEALTH{unitID;;eq;;target;;threshold;;lt;;20;;unitReaction;;eq;;" .. REACTION_HOSTILE .. "}",
   exceptions		= "unavailableSkill;;eq;;" .. SPELL_EXECUTE,
   iconSkill		= SPELLID_EXECUTE,
  },
  MSBT_TRIGGER_FINGERS_OF_FROST = {
   colorR			= 0.118,
   colorG			= 0.882,
   message			= SPELL_FINGERS_OF_FROST .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "MAGE",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_FINGERS_OF_FROST .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
   exceptions		= "recentlyFired;;lt;;2",
  },
  MSBT_TRIGGER_HAMMER_OF_WRATH = {
   colorB			= 0,
   message			= SPELL_HAMMER_OF_WRATH .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "PALADIN",
   mainEvents		= "UNIT_HEALTH{unitID;;eq;;target;;threshold;;lt;;20;;unitReaction;;eq;;" .. REACTION_HOSTILE .. "}",
   exceptions		= "unavailableSkill;;eq;;" .. SPELL_HAMMER_OF_WRATH,
   iconSkill		= SPELLID_HAMMER_OF_WRATH,
  },
  --[[MSBT_TRIGGER_KILL_SHOT = {
   colorG			= 0.25,
   colorB			= 0.25,
   message			= SPELL_KILL_SHOT .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "HUNTER",
   mainEvents		= "UNIT_HEALTH{unitID;;eq;;target;;threshold;;lt;;20;;unitReaction;;eq;;" .. REACTION_HOSTILE .. "}",
   exceptions		= "unavailableSkill;;eq;;" .. SPELL_KILL_SHOT,
   iconSkill		= SPELLID_KILL_SHOT,
  },]]
  MSBT_TRIGGER_KILLING_MACHINE = {
   colorR			= 0.118,
   colorG			= 0.882,
   message			= SPELL_KILLING_MACHINE .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "DEATHKNIGHT",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_KILLING_MACHINE .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },
  MSBT_TRIGGER_LAVA_SURGE = {
   colorG			= 0.341,
   colorB			= 0.129,
   message			= SPELL_LAVA_SURGE,
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "SHAMAN",
   mainEvents		= "SPELL_CAST_SUCCESS{sourceAffiliation;;eq;;" .. FLAG_YOU .. ";;skillID;;eq;;" .. SPELLID_LAVA_SURGE .. "}",
  },
  --[[MSBT_TRIGGER_LOCK_AND_LOAD = {
   colorR			= 0.627,
   colorG			= 0.5,
   colorB			= 0,
   message			= SPELL_LOCK_AND_LOAD .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "HUNTER",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_LOCK_AND_LOAD .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },]]
  MSBT_TRIGGER_LOW_HEALTH = {
   colorG			= 0.5,
   colorB			= 0.5,
   message			= L.MSG_TRIGGER_LOW_HEALTH .. "! (%a)",
   alwaysSticky		= true,
   fontSize			= 26,
   soundFile		= "MSBT Low Health",
   mainEvents		= "UNIT_HEALTH{unitID;;eq;;player;;threshold;;lt;;35}",
   exceptions		= "recentlyFired;;lt;;5",
   iconSkill		= SPELLID_FIRST_AID,
  },
  MSBT_TRIGGER_LOW_MANA = {
   colorR			= 0.5,
   colorG			= 0.5,
   message			= L.MSG_TRIGGER_LOW_MANA .. "! (%a)",
   alwaysSticky		= true,
   fontSize			= 26,
   soundFile		= "MSBT Low Mana",
   classes			= "DRUID,MAGE,PALADIN,PRIEST,SHAMAN,WARLOCK",
   mainEvents		= "UNIT_POWER{powerType;;eq;;0;;unitID;;eq;;player;;threshold;;lt;;35}",
   exceptions		= "recentlyFired;;lt;;5",
  },
  MSBT_TRIGGER_LOW_PET_HEALTH = {
   colorG			= 0.5,
   colorB			= 0.5,
   message			= L.MSG_TRIGGER_LOW_PET_HEALTH .. "! (%a)",
   fontSize			= 26,
   classes			= "HUNTER,MAGE,WARLOCK",
   mainEvents		= "UNIT_HEALTH{unitID;;eq;;pet;;threshold;;lt;;40}",
   exceptions		= "recentlyFired;;lt;;5",
  },
  --[[MSBT_TRIGGER_MAELSTROM_WEAPON = {
   colorR			= 0.5,
   colorB			= 0.5,
   message			= SPELL_MAELSTROM_WEAPON .. " x5!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "SHAMAN",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_MAELSTROM_WEAPON .. ";;amount;;eq;;5;;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },]]
  --[[MSBT_TRIGGER_MANA_TEA = {
   colorR			= 0,
   colorG			= 0.5,
   message			= SPELL_MANA_TEA .. " x%a!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "MONK",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_MANA_TEA .. ";;amount;;eq;;20;;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}"
  },]]
  MSBT_TRIGGER_MISSILE_BARRAGE = {
   colorG			= 0.725,
   message			= SPELL_MISSILE_BARRAGE .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "MAGE",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_MISSILE_BARRAGE .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },
  --[[MSBT_TRIGGER_MOLTEN_CORE = {
   colorG			= 0.25,
   colorB			= 0.25,
   message			= SPELL_MOLTEN_CORE .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "WARLOCK",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_MOLTEN_CORE .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },]]
  --[[MSBT_TRIGGER_NIGHTFALL = {
   colorR			= 0.709,
   colorG			= 0,
   colorB			= 0.709,
   message			= SPELL_NIGHTFALL .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "WARLOCK",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_SHADOW_TRANCE .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },]]
  MSBT_TRIGGER_PVP_TRINKET = {
   colorB			= 0,
   message			= SPELL_PVP_TRINKET .. "! (%r)",
   alwaysSticky		= true,
   fontSize			= 26,
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_PVP_TRINKET .. ";;recipientReaction;;eq;;" .. REACTION_HOSTILE .. "}",
   exceptions		= "zoneType;;ne;;arena",
  },
  MSBT_TRIGGER_PREDATORS_SWIFTNESS = {
   colorR			= 0.5,
   colorB			= 0.5,
   message			= SPELL_PREDATORS_SWIFTNESS .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "DRUID",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_PREDATORS_SWIFTNESS .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },
  MSBT_TRIGGER_REVENGE = {
   colorB			= 0,
   message			= SPELL_REVENGE .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "WARRIOR",
   mainEvents		= "GENERIC_MISSED{recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;missType;;eq;;BLOCK}&&GENERIC_MISSED{recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;missType;;eq;;DODGE}&&GENERIC_MISSED{recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;missType;;eq;;PARRY}",
   exceptions		= "warriorStance;;ne;;2;;unavailableSkill;;eq;;" .. SPELL_REVENGE .. ";;recentlyFired;;lt;;2",
   iconSkill		= SPELLID_REVENGE,
  },
  MSBT_TRIGGER_RIME = {
   colorR			= 0,
   colorG			= 0.5,
   message			= SPELL_RIME .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "DEATHKNIGHT",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_FREEZING_FOG .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },
  --[[MSBT_TRIGGER_SHADOW_INFUSION = {
   colorR			= 0.709,
   colorG			= 0,
   colorB			= 0.709,
   message			= SPELL_SHADOW_INFUSION .. " x5!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "DEATHKNIGHT",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_SHADOW_INFUSION .. ";;amount;;eq;;5;;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },]]
  --[[MSBT_TRIGGER_SHOOTING_STARS = {
   colorG			= 0.725,
   message			= SPELL_SHOOTING_STARS .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "DRUID",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_SHOOTING_STARS .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },]]
  MSBT_TRIGGER_SUDDEN_DEATH = {
   colorG			= 0,
   colorB			= 0,
   message			= SPELL_SUDDEN_DEATH .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "WARRIOR",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_SUDDEN_DEATH .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },
  --[[MSBT_TRIGGER_SWORD_AND_BOARD = {
   colorR			= 0,
   colorG			= 0.5,
   message			= SPELL_SWORD_AND_BOARD .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "WARRIOR",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_SWORD_AND_BOARD .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
   exceptions		= "unavailableSkill;;eq;;" .. SPELL_SHIELD_SLAM,
  },]]
  --[[MSBT_TRIGGER_TASTE_FOR_BLOOD = {
   colorR			= 0.627,
   colorG			= 0.5,
   colorB			= 0,
   message			= SPELL_TASTE_FOR_BLOOD .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "WARRIOR",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_TASTE_FOR_BLOOD .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },]]
  --[[MSBT_TRIGGER_THE_ART_OF_WAR = {
   colorR			= 0.5,
   colorB			= 0.5,
   message			= SPELL_THE_ART_OF_WAR .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "PALADIN",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_THE_ART_OF_WAR .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },]]
  MSBT_TRIGGER_TIDAL_WAVES = {
   colorR			= 0,
   colorG			= 0.5,
   message			= SPELL_TIDAL_WAVES .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "SHAMAN",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_TIDAL_WAVES .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },
  MSBT_TRIGGER_ULTIMATUM = {
   colorR			= 0,
   colorG			= 0.5,
   message			= SPELL_ULTIMATUM .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "WARRIOR",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_ULTIMATUM .. ";;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}",
  },
  MSBT_TRIGGER_VICTORY_RUSH = {
   colorG			= 0.25,
   colorB			= 0.25,
   message			= SPELL_VICTORY_RUSH .. "!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "WARRIOR",
   mainEvents		= "PARTY_KILL{sourceAffiliation;;eq;;" .. FLAG_YOU .. "}",
   exceptions		= "unavailableSkill;;eq;;" .. SPELL_VICTORY_RUSH .. ";;trivialTarget;;eq;;true;;recentlyFired;;lt;;2",
   iconSkill		= SPELLID_VICTORY_RUSH,
  },
  --[[MSBT_TRIGGER_VITAL_MISTS = {
   colorR			= 0.5,
   colorB			= 0.5,
   message			= SPELL_VITAL_MISTS .. " x%a!",
   alwaysSticky		= true,
   fontSize			= 26,
   classes			= "MONK",
   mainEvents		= "SPELL_AURA_APPLIED{skillName;;eq;;" .. SPELL_VITAL_MISTS .. ";;amount;;eq;;5;;recipientAffiliation;;eq;;" .. FLAG_YOU .. "}"
  },]]
 }, -- End triggers


 -- Master font settings.
 normalFontName		= L.DEFAULT_FONT_NAME,
 normalOutlineIndex	= 1,
 normalFontSize		= 18,
 normalFontAlpha	= 100,
 critFontName		= L.DEFAULT_FONT_NAME,
 critOutlineIndex	= 1,
 critFontSize		= 26,
 critFontAlpha		= 100,


 -- Animation speed. 
 animationSpeed		= 100,
 
  
 -- Partial effect settings. 
 crushing		= { colorR = 0.5, colorG = 0, colorB = 0, trailer = string_gsub(CRUSHING_TRAILER, "%((.+)%)", "<%1>") },
 glancing		= { colorR = 1, colorG = 0, colorB = 0, trailer = string_gsub(GLANCING_TRAILER, "%((.+)%)", "<%1>") },
 absorb			= { colorR = 1, colorG = 1, colorB = 0, trailer = string_gsub(string_gsub(ABSORB_TRAILER, "%((.+)%)", "<%1>"), "%%d", "%%a") },
 block			= { colorR = 0.5, colorG = 0, colorB = 1, trailer = string_gsub(string_gsub(BLOCK_TRAILER, "%((.+)%)", "<%1>"), "%%d", "%%a") },
 resist			= { colorR = 0.5, colorG = 0, colorB = 0.5, trailer = string_gsub(string_gsub(RESIST_TRAILER, "%((.+)%)", "<%1>"), "%%d", "%%a") },
 overheal		= { colorR = 0, colorG = 0.705, colorB = 0.5, trailer = " <%a>" },
 overkill		= { disabled = true, colorR = 0.83, colorG = 0, colorB = 0.13, trailer = " <%a>" },
 
 
 -- Damage color settings.
 physical		= { colorR = 1, colorG = 1, colorB = 1 },
 holy			= { colorR = 1, colorG = 1, colorB = 0.627 },
 fire			= { colorR = 1, colorG = 0.5, colorB = 0.5 },
 nature			= { colorR = 0.5, colorG = 1, colorB = 0.5 },
 frost			= { colorR = 0.5, colorG = 0.5, colorB = 1 },
 shadow			= { colorR = 0.628, colorG = 0, colorB = 0.628 },
 arcane			= { colorR = 1, colorG = 0.725, colorB = 1 },
 frostfire		= { colorR = 0.824, colorG = 0.314, colorB = 0.471 },
 shadowflame	= { colorR = 0.824, colorG = 0.5, colorB = 0.628 },


 -- Class color settings.
 DEATHKNIGHT	= CreateClassSettingsTable("DEATHKNIGHT"),
 DRUID			= CreateClassSettingsTable("DRUID"),
 HUNTER			= CreateClassSettingsTable("HUNTER"),
 MAGE			= CreateClassSettingsTable("MAGE"),
 MONK			= CreateClassSettingsTable("MONK"),
 PALADIN		= CreateClassSettingsTable("PALADIN"),
 PRIEST			= CreateClassSettingsTable("PRIEST"),
 ROGUE			= CreateClassSettingsTable("ROGUE"),
 SHAMAN			= CreateClassSettingsTable("SHAMAN"),
 WARLOCK		= CreateClassSettingsTable("WARLOCK"),
 WARRIOR		= CreateClassSettingsTable("WARRIOR"),
 DEMONHUNTER	= CreateClassSettingsTable("DEMONHUNTER"),


 -- Throttle settings.
 dotThrottleDuration	= 3,
 hotThrottleDuration	= 3,
 powerThrottleDuration	= 3,
 throttleList = {
  --[SPELL_BLOOD_PRESENCE]	= 5,
  [SPELL_DRAIN_LIFE]		= 3,
  [SPELL_SHADOWMEND]		= 5,
  --[SPELL_REFLECTIVE_SHIELD]	= 5,
  [SPELL_VAMPIRIC_EMBRACE]	= 5,
  [SPELL_VAMPIRIC_TOUCH]	= 5,
 },

 
 -- Spam control settings.
 mergeExclusions		= {},
 abilitySubstitutions	= {},
 abilitySuppressions	= {
  [SPELL_UNDYING_RESOLVE]		= true,
 },
 damageThreshold		= 0,
 healThreshold			= 0,
 powerThreshold			= 0,
 hideFullHoTOverheals	= true,
 shortenNumbers			= false,
 shortenNumberPrecision	= 0,
 groupNumbers			= false,


 -- Cooldown settings.
 cooldownExclusions		= {},
 cooldownThreshold		= 5,


 -- Loot settings.
 qualityExclusions		= {
  [LE_ITEM_QUALITY_POOR] = true,
 },
 alwaysShowQuestItems	= true,
 itemsAllowed			= {},
 itemExclusions			= {},
}



-------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Dynamically loads the and displays the options.
-- ****************************************************************************
local function ShowOptions()
 -- Load the options module if it's not already loaded.
 local optionsName = "MSBTOptions"
 if (not IsAddOnLoaded(optionsName)) then
  local loaded, failureReason = LoadAddOn(optionsName)
  
  -- Display an error message indicating why the module wasn't loaded if it
  -- didn't load properly.
  if (not loaded) then
   local failureMessage = _G["ADDON_" .. failureReason] or failureReason or ""
   Print(string_format(ADDON_LOAD_FAILED, optionsName, failureMessage))
  end
 end

 -- Display the main frame if the options module is loaded.
 if (IsAddOnLoaded(optionsName)) then MSBTOptions.Main.ShowMainFrame() end
end


-- ****************************************************************************
-- Recursively removes empty tables and their differential map entries.
-- ****************************************************************************
local function RemoveEmptyDifferentials(currentTable)
 -- Find nested tables in the current table.
 for fieldName, fieldValue in pairs(currentTable) do
  if (type(fieldValue) == "table") then
   -- Recursively clear empty tables in the nested table.
   RemoveEmptyDifferentials(fieldValue)

   -- Remove the table from the differential map and current table if it's
   -- empty.
   if (not next(fieldValue)) then
    differentialMap[fieldValue] = nil
	differentialCache[#differentialCache+1] = fieldValue
    currentTable[fieldName] = nil
   end
  end
 end
end


-- ****************************************************************************
-- Recursively associates the tables in the passed saved table to corresponding
-- entries in the passed master table.
-- ****************************************************************************
local function AssociateDifferentialTables(savedTable, masterTable)
 -- Associate the saved table with the corresponding master entry.
 differentialMap[savedTable] = masterTable
 setmetatable(savedTable, differential_mt)
 
 -- Look for nested tables that have a corresponding master entry.
 for fieldName, fieldValue in pairs(savedTable) do
  if (type(fieldValue) == "table" and type(masterTable[fieldName]) == "table") then
   -- Recursively call the function to associate nested tables.
   AssociateDifferentialTables(fieldValue, masterTable[fieldName])
  end
 end 
end


-- ****************************************************************************
-- Set the passed option to the current profile while handling differential
-- profile mechanics.
-- ****************************************************************************
local function SetOption(optionPath, optionName, optionValue, optionDefault)
 -- Clear the path table.
 EraseTable(pathTable)
 
 -- Split the passed option path into the path table.
 if (optionPath) then SplitString(optionPath, "%.", pathTable) end

 -- Attempt to go to the option path in the master profile.
 local masterOption = masterProfile
 for _, fieldName in ipairs(pathTable) do
  masterOption = masterOption[fieldName]
  if (not masterOption) then break end
 end
 
 -- Get the option name from the master profile.
 masterOption = masterOption and masterOption[optionName]

 -- Check if the option being set needs to be overridden.
 local needsOverride = false
 if (optionValue ~= masterOption) then needsOverride = true end

 -- Treat a nil master option the same as false. 
 if ((optionValue == false or optionValue == optionDefault) and not masterOption) then
  needsOverride = false
 end

 -- Make the option value false if the option being set is nil and the master option set. 
 if (optionValue == nil and masterOption) then optionValue = false end
  
 -- Start at the root of the current profile and master profile.
 local currentTable = currentProfile
 local masterTable = masterProfile

 -- Override needed.
 if (needsOverride and optionValue ~= nil) then
  -- Loop through all of the fields in path table.
  for _, fieldName in ipairs(pathTable) do
   -- Check if the field doesn't exist in the current profile.
   if (not rawget(currentTable, fieldName)) then
    -- Create a table for the field and setup the associated inheritance table.
    currentTable[fieldName] = table.remove(differentialCache) or {}
    if (masterTable and masterTable[fieldName]) then
     differentialMap[currentTable[fieldName]] = masterTable[fieldName]
     setmetatable(currentTable[fieldName], differential_mt)
    end
   end
  
   -- Move to the next field in the option path.
   currentTable = currentTable[fieldName]
   masterTable = masterTable and masterTable[fieldName]
  end

  -- Set the option's value.
  currentTable[optionName] = optionValue
  
 -- Override NOT needed.
 else
 -- Attempt to go to the option path in the current profile.
  for _, fieldName in ipairs(pathTable) do
   currentTable = rawget(currentTable, fieldName)
   if (not currentTable) then return end
  end

  -- Clear the option from the path and remove any empty differential tables.
  if (currentTable) then
   currentTable[optionName] = nil
   RemoveEmptyDifferentials(currentProfile)
  end
 end
end


-- ****************************************************************************
-- Sets up a button to access MSBT's options from the Blizzard interface
-- options AddOns tab.
-- ****************************************************************************
local function SetupBlizzardOptions()
 -- Create a container frame for the Blizzard options area.
 local frame = CreateFrame("Frame")
 frame.name = "MikScrollingBattleText"
 
 -- Create an option button in the center of the frame to launch MSBT's options.
 local button = CreateFrame("Button", nil, frame, "OptionsButtonTemplate")
 button:SetPoint("CENTER")
 button:SetText(MikSBT.COMMAND)
 button:SetScript("OnClick",
  function (this)
   InterfaceOptionsFrameCancel_OnClick()
   HideUIPanel(GameMenuFrame)
   ShowOptions()
  end
 )

 -- Add the frame as a new category to Blizzard's interface options.
 InterfaceOptions_AddCategory(frame)
end


-- ****************************************************************************
-- Disable Blizzard's combat text.
-- ****************************************************************************
local function DisableBlizzardCombatText()
 -- Turn off Blizzard's default combat text.
 SetCVar("enableFloatingCombatText", 0)
 SetCVar("floatingCombatTextCombatHealing", 0)
 SetCVar("floatingCombatTextCombatDamage", 0)
 SHOW_COMBAT_TEXT = "0"
 if (CombatText_UpdateDisplayedMessages) then CombatText_UpdateDisplayedMessages() end
end


-- ****************************************************************************
-- Set the user disabled option
-- ****************************************************************************
local function SetOptionUserDisabled(isDisabled)
 savedVariables.userDisabled = isDisabled or nil

 -- Check if the mod is being set to disabled.
 if (isDisabled) then
  -- Disable the cooldowns, triggers, event parser, and main modules.
  MikSBT.Cooldowns.Disable()
  MikSBT.Triggers.Disable()
  MikSBT.Parser.Disable()
  MikSBT.Main.Disable()

 else 
  -- Enable the main, event parser, triggers, and cooldowns modules.
  MikSBT.Main.Enable()
  MikSBT.Parser.Enable() 
  MikSBT.Triggers.Enable()
  MikSBT.Cooldowns.Enable()
 end
end


-- ****************************************************************************
-- Returns whether or not the mod is disabled.
-- ****************************************************************************
local function IsModDisabled()
 return savedVariables and savedVariables.userDisabled
end


-- ****************************************************************************
-- Updates the class colors in the master profile with the colors defined in
-- the CUSTOM_CLASS_COLORS table.
-- ****************************************************************************
local function UpdateCustomClassColors()
 for class, colors in pairs(CUSTOM_CLASS_COLORS) do  
  if (masterProfile[class]) then
   masterProfile[class].colorR = colors.r or masterProfile[class].colorR
   masterProfile[class].colorG = colors.g or masterProfile[class].colorG
   masterProfile[class].colorB = colors.b or masterProfile[class].colorB
  end
 end
end

-- ****************************************************************************
-- Searches through current profile for all used fonts and uses the animation
-- module to preload each font so they're available for use.
-- ****************************************************************************
local function LoadUsedFonts()
  -- Add the normal and crit master font.
  local usedFonts = {}
  if currentProfile.normalFontName then usedFonts[currentProfile.normalFontName] = true end
  if currentProfile.critFontName then usedFonts[currentProfile.critFontName] = true end

  -- Add any unique fonts used in the scroll areas.
  if currentProfile.scrollAreas then
   for saKey, saSettings in pairs(currentProfile.scrollAreas) do
    if saSettings.normalFontName then usedFonts[saSettings.normalFontName] = true end
    if saSettings.critFontName then usedFonts[saSettings.critFontName] = true end
   end
  end

  -- Add any unique fonts used in the events.
  if currentProfile.events then
   for eventName, eventSettings in pairs(currentProfile.events) do
    if eventSettings.fontName then usedFonts[eventSettings.fontName] = true end
   end
  end

  -- Add any unique fonts used in the triggers.
  if currentProfile.triggers then
   for triggerName, triggerSettings in pairs(currentProfile.triggers) do
    if type(triggerSettings) == "table" then
     if triggerSettings.fontName then usedFonts[triggerSettings.fontName] = true end
    end
   end
  end
 
  -- Let the animation system preload the fonts.
  for fontName in pairs(usedFonts) do MikSBT.Animations.LoadFont(fontName) end
end




-------------------------------------------------------------------------------
-- Profile functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Updates profiles created with older versions.
-- ****************************************************************************
local function UpdateProfiles()
 -- Loop through all the profiles.
 for profileName, profile in pairs(savedVariables.profiles) do
  -- Get numeric creation version.
  local creationVersion = tonumber(select(3, string_find(tostring(profile.creationVersion), "(%d+%.%d+)")))

  -- Delete triggers if upgrading from a version prior to 5.2.
  if (creationVersion < 5.2) then
   profile.triggers = nil
   profile.creationVersion = MikSBT.VERSION .. "." .. MikSBT.SVN_REVISION
  end
 end
end


-- ****************************************************************************
-- Selects the passed profile.
-- ****************************************************************************
local function SelectProfile(profileName)
 -- Make sure the profile exists.
 if (savedVariables.profiles[profileName]) then
  -- Set the current profile name for the character to the one being selected.
  savedVariablesPerChar.currentProfileName = profileName

  -- Set the current profile pointer.
  currentProfile = savedVariables.profiles[profileName]
  module.currentProfile = currentProfile

  -- Clear the differential table map.
  EraseTable(differentialMap)

  -- Associate the current profile tables with the corresponding master profile entries.
  AssociateDifferentialTables(currentProfile, masterProfile)

  -- Load the fonts used by the profile now so they are available by the time
  -- the first text is shown.
  LoadUsedFonts()

  -- Update the scroll areas and triggers with the current profile settings. 
  MikSBT.Animations.UpdateScrollAreas()
  MikSBT.Triggers.UpdateTriggers()
 end
end


-- ****************************************************************************
-- Copies the passed profile to a new profile with the passed name.
-- ****************************************************************************
local function CopyProfile(srcProfileName, destProfileName)
 -- Leave the function if the the destination profile name is invalid.
 if (not destProfileName or destProfileName == "") then return end

 -- Make sure the source profile exists and the destination profile doesn't.
 if (savedVariables.profiles[srcProfileName] and not savedVariables.profiles[destProfileName]) then
  -- Copy the profile.
  savedVariables.profiles[destProfileName] = CopyTable(savedVariables.profiles[srcProfileName])
 end
end


-- ****************************************************************************
-- Deletes the passed profile.
-- ****************************************************************************
local function DeleteProfile(profileName)
 -- Ignore the delete if the passed profile is the default one.
 if (profileName == DEFAULT_PROFILE_NAME) then return end

 -- Make sure the profile exists.
 if (savedVariables.profiles[profileName]) then
  -- Check if the profile being deleted is the current one.
  if (profileName == savedVariablesPerChar.currentProfileName) then
   -- Select the default profile.
   SelectProfile(DEFAULT_PROFILE_NAME)
  end

  -- Delete the profile.
  savedVariables.profiles[profileName] = nil
 end
end


-- ****************************************************************************
-- Resets the passed profile to its defaults.
-- ****************************************************************************
local function ResetProfile(profileName, showOutput)
 -- Set the profile name to the current profile is one wasn't passed.
 if (not profileName) then profileName = savedVariablesPerChar.currentProfileName end
 
 -- Make sure the profile exists.
 if (savedVariables.profiles[profileName]) then
  -- Reset the profile.
  EraseTable(savedVariables.profiles[profileName])

  -- Reset the profile's creation version.
  savedVariables.profiles[profileName].creationVersion = MikSBT.VERSION .. "." .. MikSBT.SVN_REVISION
  
  
  -- Check if it's the current profile being reset.
  if (profileName == savedVariablesPerChar.currentProfileName) then
   -- Reselect the profile to update everything.
   SelectProfile(profileName)
  end

  -- Check if the output text is to be shown.
  if (showOutput) then
   -- Print the profile reset string.
   Print(profileName .. " " .. L.MSG_PROFILE_RESET, 0, 1, 0)
  end
 end 
end


-- ****************************************************************************
-- This function initializes the saved variables. 
-- ****************************************************************************
local function InitSavedVariables()
 -- Set the saved variables per character to the value specified in the .toc file.
 savedVariablesPerChar = _G[SAVED_VARS_PER_CHAR_NAME]

 -- Check if there are no saved variables per character.
 if (not savedVariablesPerChar) then
  -- Create a new table to hold the saved variables per character, and set the .toc entry to it.
  savedVariablesPerChar = {}
  _G[SAVED_VARS_PER_CHAR_NAME] = savedVariablesPerChar

  -- Set the current profile for the character to the default profile.
  savedVariablesPerChar.currentProfileName = DEFAULT_PROFILE_NAME
 end


 -- Set the saved variables to the value specified in the .toc file.
 savedVariables = _G[SAVED_VARS_NAME]

 -- Check if there are no saved variables.
 if (not savedVariables) then
  -- Create a new table to hold the saved variables, and set the .toc entry to it.
  savedVariables = {}
  _G[SAVED_VARS_NAME] = savedVariables

  -- Create the profiles table and default profile.
  savedVariablesPerChar.currentProfileName = DEFAULT_PROFILE_NAME
  savedVariables.profiles = {}
  savedVariables.profiles[DEFAULT_PROFILE_NAME] = {}

  savedVariables.profiles[DEFAULT_PROFILE_NAME].creationVersion = MikSBT.VERSION .. "." .. MikSBT.SVN_REVISION
  
  -- Set the first time loaded flag.
  isFirstLoad = true
  
 -- There are saved variables.
 else
  -- Updates profiles created by older versions.
  UpdateProfiles()
 end

 -- Select the current profile for the character if it exists, otherwise select the default profile.
 if (savedVariables.profiles[savedVariablesPerChar.currentProfileName]) then
  SelectProfile(savedVariablesPerChar.currentProfileName)
 else
  SelectProfile(DEFAULT_PROFILE_NAME)
 end
 

 -- Set the saved media to the value specified in the .toc file.
 savedMedia = _G[SAVED_MEDIA_NAME]

 -- Check if there is no saved media.
 if (not savedMedia) then
  -- Create a new table to hold the saved media, and set the .toc entry to it.
  savedMedia = {}
  _G[SAVED_MEDIA_NAME] = savedMedia

  -- Create custom font and sounds tables.
  savedMedia.fonts = {}
  savedMedia.sounds = {}
 end
 
 -- Allow public access to saved variables.
 module.savedVariables = savedVariables
 module.savedMedia = savedMedia
end


-------------------------------------------------------------------------------
-- Command handler functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Returns the current and remaining parameters from the passed string.
-- ****************************************************************************
local function GetNextParameter(paramString)
 local remainingParams
 local currentParam = paramString

 -- Look for a space.
 local index = string_find(paramString, " ", 1, true)
 if (index) then
  -- Get the current and remaing parameters.
  currentParam = string.sub(paramString, 1, index-1)
  remainingParams = string.sub(paramString, index+1)
 end

 -- Return the current parameter and the remaining ones.
 return currentParam, remainingParams
end


-- ****************************************************************************
-- Called to handle commands.
-- ****************************************************************************
local function CommandHandler(params)
 -- Get the parameter.
 local currentParam, remainingParams
 currentParam, remainingParams = GetNextParameter(params)

 -- Flag for whether or not to show usage info.
 local showUsage = true

 -- Make sure there is a current parameter and lower case it.
 if (currentParam) then currentParam = string.lower(currentParam) end

 -- Look for the recognized parameters.
 if (currentParam == "") then
  -- Load the on demand options.
  ShowOptions()

  -- Don't show the usage info.
  showUsage = false

  -- Reset.
  elseif (currentParam == L.COMMAND_RESET) then
  -- Reset the current profile.
  ResetProfile(nil, true)

  -- Don't show the usage info.
  showUsage = false
  
 -- Disable.
 elseif (currentParam == L.COMMAND_DISABLE) then
  -- Set the user disabled option.
  SetOptionUserDisabled(true)

  -- Output an informative message.
  Print(L.MSG_DISABLE, 1, 1, 1)

  -- Don't show the usage info.
  showUsage = false

 -- Enable.
 elseif (currentParam == L.COMMAND_ENABLE) then
  -- Unset the user disabled option.
  SetOptionUserDisabled(false)

  -- Output an informative message.
  Print(L.MSG_ENABLE, 1, 1, 1)

  -- Don't show the usage info.
  showUsage = false

 -- Version.
 elseif (currentParam == L.COMMAND_SHOWVER) then
  -- Output the current version number.
  Print(MikSBT.VERSION_STRING, 1, 1, 1)

  -- Don't show the usage info.
  showUsage = false

 end 

 -- Check if the usage information should be shown.
 if (showUsage) then
  -- Loop through all of the entries in the command usage list.
  for _, msg in ipairs(L.COMMAND_USAGE) do
   Print(msg, 1, 1, 1)
  end
 end -- Show usage.
end


-------------------------------------------------------------------------------
-- Event handlers.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when the registered events occur.
-- ****************************************************************************
local function OnEvent(this, event, arg1)
 -- When an addon is loaded.
 if (event == "ADDON_LOADED") then
  -- Ignore the event if it isn't this addon.
  if (arg1 ~= "MikScrollingBattleText") then return end

  -- Don't get notification for other addons being loaded.
  this:UnregisterEvent("ADDON_LOADED")

  -- Register slash commands
  SLASH_MSBT1 = MikSBT.COMMAND
  SlashCmdList["MSBT"] = CommandHandler

  -- Initialize the saved variables to make sure there is a profile to work with.
  InitSavedVariables()

  -- Add a button to launch MSBT's options from the Blizzard interface options.
  SetupBlizzardOptions()

  -- Let the media module know the variables are initialized.
  MikSBT.Media.OnVariablesInitialized()

 -- Variables for all addons loaded.
 elseif (event == "VARIABLES_LOADED") then
  -- Disable or enable the mod depending on the saved setting.
  SetOptionUserDisabled(IsModDisabled())
  
  -- Disable Blizzard's combat text if it's the first load.
  if (isFirstLoad) then DisableBlizzardCombatText() end

  -- Support CUSTOM_CLASS_COLORS.
  if (CUSTOM_CLASS_COLORS) then
   UpdateCustomClassColors()
   if (CUSTOM_CLASS_COLORS.RegisterCallback) then CUSTOM_CLASS_COLORS:RegisterCallback(UpdateCustomClassColors) end
  end
  collectgarbage("collect")
 end
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

-- Create a frame to receive events.
eventFrame = CreateFrame("Frame", "MSBTProfileFrame", UIParent)
eventFrame:SetPoint("BOTTOM")
eventFrame:SetWidth(0.0001)
eventFrame:SetHeight(0.0001)
eventFrame:Hide()
eventFrame:SetScript("OnEvent", OnEvent)

-- Register events for when the mod is loaded and variables are loaded.
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("VARIABLES_LOADED")




-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Variables. 
module.masterProfile = masterProfile

-- Protected Functions.
module.CopyProfile					= CopyProfile
module.DeleteProfile				= DeleteProfile
module.ResetProfile					= ResetProfile
module.SelectProfile				= SelectProfile
module.SetOption					= SetOption
module.SetOptionUserDisabled		= SetOptionUserDisabled
module.IsModDisabled				= IsModDisabled
