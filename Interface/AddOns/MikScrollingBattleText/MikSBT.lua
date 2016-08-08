-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create mod namespace and set its name.
local mod = {}
local modName = "MikSBT"
_G[modName] = mod


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various functions for faster access.
local string_find = string.find
local string_sub = string.sub
local string_gsub = string.gsub
local string_match = string.match
local math_floor = math.floor
local GetSpellInfo = GetSpellInfo


-------------------------------------------------------------------------------
-- Mod constants
-------------------------------------------------------------------------------

local TOC_VERSION = string_gsub(GetAddOnMetadata("MikScrollingBattleText", "Version"), "wowi:revision", 0)
mod.VERSION = tonumber(select(3, string_find(TOC_VERSION, "(%d+%.%d+)")))
mod.VERSION_STRING = "v" .. TOC_VERSION
mod.SVN_REVISION = tonumber(select(3, string_find(TOC_VERSION, "%d+%.%d+.(%d+)")))
mod.CLIENT_VERSION = tonumber((select(4, GetBuildInfo())))

mod.COMMAND = "/msbt"

-------------------------------------------------------------------------------
-- Localization.
-------------------------------------------------------------------------------

-- Holds localized strings.
local translations = {}


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various functions for faster access.
local string_format = string.format
local string_reverse = string.reverse


-------------------------------------------------------------------------------
-- Utility Constants.
-------------------------------------------------------------------------------

-- Use standard SI suffixes at the end of shortened numbers.
local SI_SUFFIXES = { "k", "M", "G", "T" }

-- Use Blizzard localized value to separate numbers if available.
local LARGE_NUMBER_SEPERATOR = LARGE_NUMBER_SEPERATOR

if not LARGE_NUMBER_SEPERATOR or LARGE_NUMBER_SEPERATOR == "" then
	LARGE_NUMBER_SEPERATOR = ","
end

local SEPARATOR_REPLACE_PATTERN = "%1"..(LARGE_NUMBER_SEPERATOR or ",").."%2"


-------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Copies the passed table and all its subtables.
-- ****************************************************************************
local function CopyTable(srcTable)
 -- Create a new table.
 local newTable = {}

 -- Loop through all of the entries in the table.
 for key, value in pairs(srcTable) do
  -- Recursively call the function to copy nested tables.
  if (type(value) == "table") then value = CopyTable(value) end

  -- Make a copy of the value into the new table.
  newTable[key] = value
 end

 -- Return the new table.
 return newTable
end


-- ****************************************************************************
-- Erases the passed table.  Subtables are NOT erased.
-- ****************************************************************************
local function EraseTable(t)
 -- Loop through all the keys in the table and clear it.
 for key in next, t do
  t[key] = nil
 end
end


-- ****************************************************************************
-- Splits a string into the passed table using the delimeter.
-- ****************************************************************************
local function SplitString(text, delimeter, splitTable)
 local start = 1
 local splitStart, splitEnd = string_find(text, delimeter, start)  
 while splitStart do
  splitTable[#splitTable+1] = string_sub(text, start, splitStart - 1)
  start = splitEnd + 1
  splitStart, splitEnd = string_find(text, delimeter, start)  
 end
 splitTable[#splitTable+1] = string_sub(text, start)
end


-- ****************************************************************************
-- Prints out the passed message to the default chat frame.
-- ****************************************************************************
local function Print(msg, r, g, b)
 -- Add the message to the default chat frame.
 DEFAULT_CHAT_FRAME:AddMessage("MSBT: " .. tostring(msg), r, g, b)
end


-- ****************************************************************************
-- Returns a skill name for the passed id or unknown if the id invalid.
-- ****************************************************************************
local function GetSkillName(skillID)
 local skillName = GetSpellInfo(skillID)
 if (not skillName) then 
  Print("Skill ID " .. tostring(skillID) .. " has been removed by Blizzard.")
 end
 return skillName or UNKNOWN
end


-- ****************************************************************************
-- Returns an SI formatted value given a number and a precision.
-- ****************************************************************************
local function ShortenNumber(number, precision)
 local precisionFormatter = string_format("%%.%df", precision or 0)
 if (type(number) ~= "number") then number = tonumber(number) end
 if (not number) then return 0 end
 if (number >= 1e12) then return string_format(precisionFormatter, number / 1e12) .. SI_SUFFIXES[4] end
 if (number >= 1e9) then return string_format(precisionFormatter, number / 1e9) .. SI_SUFFIXES[3] end
 if (number >= 1e6) then return string_format(precisionFormatter, number / 1e6) .. SI_SUFFIXES[2] end
 if (number >= 1000) then return string_format(precisionFormatter, number / 1000) .. SI_SUFFIXES[1] end
 return number
end


-- ****************************************************************************
-- Returns a number separated into groups of 3 according to the current
-- locale's separator.
-- ****************************************************************************

local function SeparateNumber(number)
 if (type(number) ~= "number") then number = tonumber(number) end
 if (not number) then return 0 end

 local formatted = number
 while true do
   local k
   formatted, k = string_gsub(formatted, "^(-?%d+)(%d%d%d)", SEPARATOR_REPLACE_PATTERN)
   if (k==0) then break end
 end
 return formatted
end





-------------------------------------------------------------------------------
-- Mod utility interface.
-------------------------------------------------------------------------------

-- Protected Variables.
mod.translations = translations

-- Protected Functions.
mod.CopyTable			= CopyTable
mod.EraseTable			= EraseTable
mod.SplitString			= SplitString
mod.Print				= Print
mod.GetSkillName		= GetSkillName
mod.ShortenNumber		= ShortenNumber
mod.SeparateNumber		= SeparateNumber