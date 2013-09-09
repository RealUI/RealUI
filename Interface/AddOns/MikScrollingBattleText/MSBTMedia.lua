-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Media
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Media"
MikSBT[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various modules for faster access.
local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations

-- Local references to various functions for faster access.
local string_sub = string.sub
local string_len = string.len


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

-- The default sound files to use.
local DEFAULT_SOUND_FILES = {
 ["MSBT Low Health"]	= "Interface\\Addons\\MikScrollingBattleText\\Sounds\\LowHealth.ogg",
 ["MSBT Low Mana"]		= "Interface\\Addons\\MikScrollingBattleText\\Sounds\\LowMana.ogg",
 ["MSBT Cooldown"]		= "Interface\\Addons\\MikScrollingBattleText\\Sounds\\Cooldown.ogg",
}

-- Set the default font files to use to the locale specific fonts.
local DEFAULT_FONT_FILES = L.FONT_FILES

-- LibSharedMedia support.
local SML = LibStub("LibSharedMedia-3.0")
local SML_LANG_MASK_ALL = 255


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

local fonts = {}
local sounds = {}


-------------------------------------------------------------------------------
-- Font functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Registers a font.
-- See the included API.html file for usage info.
-- ****************************************************************************
local function RegisterFont(fontName, fontPath)
 -- Don't do anything if the font name or font path is invalid.
 if (type(fontName) ~= "string" or type(fontPath) ~= "string") then return end
 if (fontName == "" or fontPath == "") then return end

 -- Register with MSBT and shared media.
 fonts[fontName] = fontPath
 SML:Register("font", fontName, fontPath, SML_LANG_MASK_ALL)
end


-- ****************************************************************************
-- Returns an iterator for the table containing the registered fonts.
-- See the included API.html file for usage info.
-- ****************************************************************************
local function IterateFonts()
 return pairs(fonts)
end


-------------------------------------------------------------------------------
-- Sound functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Registers a sound.
-- See the included API.html file for usage info.
-- ****************************************************************************
local function RegisterSound(soundName, soundPath)
 -- Don't do anything if the sound name or sound path is invalid.
 if (type(soundName) ~= "string" or type(soundPath) ~= "string") then return end
 if (soundName == "" or soundPath == "") then return end

 -- Register with MSBT.
 sounds[soundName] = soundPath

 -- Register with shared media.
 SML:Register("sound", soundName, soundPath)
end


-- ****************************************************************************
-- Returns an iterator for the table containing the registered sounds.
-- See the included API.html file for usage info.
-- ****************************************************************************
local function IterateSounds()
 return pairs(sounds)
end


-------------------------------------------------------------------------------
-- Event handlers.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called by shared media when media is registered.
-- ****************************************************************************
local function SMLRegistered(event, mediaType, name)
 if (mediaType == "font") then
  fonts[name] = SML:Fetch(mediaType, name)
 elseif (mediaType == "sound") then
  sounds[name] = SML:Fetch(mediaType, name)
 end
end


-- ****************************************************************************
-- Called when the mod variables are initialized.
-- ****************************************************************************
local function OnVariablesInitialized()
 -- Register custom fonts and sounds.
 for fontName, fontPath in pairs(MSBTProfiles.savedMedia.fonts) do RegisterFont(fontName, fontPath) end
 for soundName, soundPath in pairs(MSBTProfiles.savedMedia.sounds) do RegisterSound(soundName, soundPath) end
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

-- Register default fonts and sounds.
for fontName, fontPath in pairs(DEFAULT_FONT_FILES) do RegisterFont(fontName, fontPath) end
for soundName, soundPath in pairs(DEFAULT_SOUND_FILES) do RegisterSound(soundName, soundPath) end

-- Register the currently available fonts and sounds in shared media with MSBT.
for index, fontName in pairs(SML:List("font")) do fonts[fontName] = SML:Fetch("font", fontName) end
for index, soundName in pairs(SML:List("sound")) do sounds[soundName] = SML:Fetch("sound", soundName) end

-- Register a callback with shared media to keep MSBT synced.
SML.RegisterCallback("MSBTSharedMedia", "LibSharedMedia_Registered", SMLRegistered)




-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Variables.
module.fonts = fonts
module.sounds = sounds

-- Protected Functions.
module.RegisterFont				= RegisterFont
module.RegisterSound			= RegisterSound
module.IterateFonts				= IterateFonts
module.IterateSounds			= IterateSounds
module.OnVariablesInitialized	= OnVariablesInitialized