-------------------------------------------------------------------------------
-- Title: Mik's Scrolling Battle Text Animations
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Animations"
MikSBT[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various modules for faster access.
local MSBTMedia = MikSBT.Media
local MSBTProfiles = MikSBT.Profiles
local L = MikSBT.translations

-- Local references to various functions for faster access.
local table_remove = table.remove
local string_find = string.find
local string_lower = string.lower
local IsModDisabled = MSBTProfiles.IsModDisabled
local EraseTable = MikSBT.EraseTable

-- Local references to various variables for faster access.
local fonts = MSBTMedia.fonts
local sounds = MSBTMedia.sounds


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

-- Max number of animations to show in a scroll area and animation defaults.
local MAX_ANIMATIONS_PER_AREA = 15
local DEFAULT_SCROLL_TIME = 3
local DEFAULT_FADE_PERCENT = 0.8
 
-- The amount of time to delay between updating an animating object.
local ANIMATION_DELAY = 0.015

-- Left, Center, Right Text Aligns.
local TEXT_ALIGN_MAP = {"BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT"}

-- Outline styles.
local OUTLINE_MAP = {"", "OUTLINE", "THICKOUTLINE", "MONOCHROME", "MONOCHROME,OUTLINE", "MONOCHROME,THICKOUTLINE"}

-- Defaults for certain parameters.
local DEFAULT_FONT_SIZE = 18
local DEFAULT_FONT_PATH = L.FONT_FILES[L.DEFAULT_FONT_NAME]
local DEFAULT_TEXT_ALIGN = TEXT_ALIGN_MAP[2]
local DEFAULT_OUTLINE = OUTLINE_MAP[1]
local DEFAULT_SCROLL_AREA = "Notification"
local DEFAULT_SCROLL_HEIGHT = 260
local DEFAULT_SCROLL_WIDTH = 40
local DEFAULT_ANIMATION_STYLE = "Straight"
local DEFAULT_STICKY_ANIMATION_STYLE = "Pow"

-- Path to look for sound files.
local DEFAULT_SOUND_PATH = "Interface\\AddOns\\MikScrollingBattleText\\Sounds\\"

-- Path to the temporary texture Blizzard uses when a skill texture is not known.
local TEMP_TEXTURE_PATH = "Interface\\Icons\\Temp"


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Dynamically created frame for animation updates.
local animationFrame

-- Memoizing font path validation.
local testFontString
local testedFonts = {}

-- Pools of dynamically created display events and textures that are reused.
local displayEventCache = {}
local textureCache = {}

-- Animating display events.
local animationData = {normal = {}, sticky = {}}

-- Animation style and scroll area information.
local animationStyles = {}
local stickyAnimationStyles = {}
local scrollAreas = {}

-- Scroll area table to be returned for external use.
local externalScrollAreas = {}


-------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Tests a font path and memoizes the result into the passed table so the font
-- path is only tested once.  This is the target of a metatable __index field.
-- ****************************************************************************
local function TestFontPath(tbl, fontPath)
 -- Mark the font path invalid if the font string was not actually set to it.
 local isValid = true
 testFontString:SetFont(fontPath, DEFAULT_FONT_SIZE, DEFAULT_OUTLINE)
 if (string_lower(fontPath) ~= string_lower(testFontString:GetFont() or "")) then isValid = false end

 -- Memoize result.
 tbl[fontPath] = isValid
 return isValid
end


-- ****************************************************************************
-- Returns whether or not the passed scroll area is valid and enabled.
-- ****************************************************************************
local function IsScrollAreaActive(scrollArea)
 local saSettings = scrollAreas[scrollArea] or scrollAreas[DEFAULT_SCROLL_AREA]
 
 -- Return false if the scroll area is invalid or disabled.
 if (not saSettings or saSettings.disabled) then return false end

 -- Return true to indicate the scroll area is active.
 return true
end


-- ****************************************************************************
-- Returns whether or not the passed scroll area is set to display icons.
-- ****************************************************************************
local function IsScrollAreaIconShown(scrollArea)
 local saSettings = scrollAreas[scrollArea] or scrollAreas[DEFAULT_SCROLL_AREA]

 -- Return true if the scroll area valid and the icons are not disabled.
 return saSettings and not saSettings.skillIconsDisabled or false
end


-- ****************************************************************************
-- Updates the available scroll areas.
-- ****************************************************************************
local function UpdateScrollAreas()
 -- Erase the current scroll areas.
 EraseTable(scrollAreas)
 EraseTable(externalScrollAreas)
 
 -- Add scroll areas from the current profile.
 if (rawget(MSBTProfiles.currentProfile, "scrollAreas")) then
  for saKey, saSettings in pairs(MSBTProfiles.currentProfile.scrollAreas) do
   scrollAreas[saKey] = saSettings
   externalScrollAreas[saKey] = saSettings.name
  end
 end

 -- Add scroll areas available in the master profile that aren't in the current profile. 
 for saKey, saSettings in pairs(MSBTProfiles.masterProfile.scrollAreas) do
  if (not scrollAreas[saKey]) then
   scrollAreas[saKey] = saSettings
   externalScrollAreas[saKey] = saSettings.name
  end
 end
end


-- ****************************************************************************
-- Registers an animation style for non sticky events.
-- See the included API.html file for usage info.
-- ****************************************************************************
local function RegisterAnimationStyle(styleID, initHandler, availableDirections, availableBehaviors, localizationTable)
 -- Make sure there isn't already an animation style with the same name and the passed init function is valid.
 if (not animationStyles[styleID] and initHandler) then
  -- Create new animation style.
  local animStyleSettings = {}
  animStyleSettings.initHandler = initHandler
  animStyleSettings.availableDirections = availableDirections
  animStyleSettings.availableBehaviors = availableBehaviors
  animStyleSettings.localizationTable = localizationTable

  -- Add the new style to the animation styles table.
  animationStyles[styleID] = animStyleSettings
 end 
end


-- ****************************************************************************
-- Registers an animation style for sticky events.
-- See the included API.html file for usage info.
-- ****************************************************************************
local function RegisterStickyAnimationStyle(styleID, initHandler, availableDirections, availableBehaviors, localizationTable)
 -- Make sure there isn't already an animation style with the same name and the passed init function is valid.
 if (not stickyAnimationStyles[styleID] and initHandler) then
  -- Create new animation style.
  local animStyleSettings = {}
  animStyleSettings.initHandler = initHandler
  animStyleSettings.availableDirections = availableDirections
  animStyleSettings.availableBehaviors = availableBehaviors
  animStyleSettings.localizationTable = localizationTable

  -- Add the new style to the sticky animation styles table.
  stickyAnimationStyles[styleID] = animStyleSettings
 end
end


-- ****************************************************************************
-- Returns an iterator for the table containing the available scroll areas.
-- See the included API.html file for usage info.
-- ****************************************************************************
local function IterateScrollAreas()
 return pairs(externalScrollAreas)
end


-------------------------------------------------------------------------------
-- Display functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates a display event using the passed settings.  If the max number of
-- allowed animations for a scroll area are already active, the oldest one is
-- reused.
-- ****************************************************************************
local function Display(message, saSettings, isSticky, colorR, colorG, colorB, fontSize, fontPath, outlineIndex, fontAlpha, texturePath)
 -- Get the correct animation style settings.
 local animStyleSettings, direction, behavior, textAlignIndex
 if (isSticky) then
  animStyleSettings = stickyAnimationStyles[saSettings.stickyAnimationStyle] or stickyAnimationStyles[DEFAULT_STICKY_ANIMATION_STYLE]
  direction = saSettings.stickyDirection
  behavior = saSettings.stickyBehavior
  textAlignIndex = saSettings.stickyTextAlignIndex
 else
  animStyleSettings = animationStyles[saSettings.animationStyle] or animationStyles[DEFAULT_ANIMATION_STYLE]
  direction = saSettings.direction
  behavior = saSettings.behavior
  textAlignIndex = saSettings.textAlignIndex
 end
 
 -- Leave the function if the animation style is invalid.
 if (not animStyleSettings) then return end

 -- Create arrays to track the active display events for the scroll area if they haven't already been created.
 if (not animationData.normal[saSettings]) then animationData.normal[saSettings] = {} end
 if (isSticky and not animationData.sticky[saSettings]) then animationData.sticky[saSettings] = {} end

 -- Get the correct animation array.
 local animationArray = isSticky and animationData.sticky[saSettings] or animationData.normal[saSettings]

 -- Reuse the oldest display event if the max number of allowed animations for the scroll
 -- area has been reached.  Otherwise acquire one from cache or create a new one if there
 -- aren't any available in cache.
 local displayEvent
 if (#animationArray >= MAX_ANIMATIONS_PER_AREA) then
  displayEvent = table_remove(animationArray, 1)
  displayEvent.fontString:SetAlpha(0)
  if (displayEvent.texture) then displayEvent.texture:SetAlpha(0) end
 else
  displayEvent = table_remove(displayEventCache) or { fontString = animationFrame:CreateFontString(nil, "ARTWORK", MasterFont) }
 end

 -- Get a local reference to the current profile.
 local currentProfile = MSBTProfiles.currentProfile

 -- Set scroll area related fields.
 displayEvent.offsetX = saSettings.offsetX or 0
 displayEvent.offsetY = saSettings.offsetY or 0
 displayEvent.anchorPoint = TEXT_ALIGN_MAP[textAlignIndex] or DEFAULT_TEXT_ALIGN
 displayEvent.scrollHeight = saSettings.scrollHeight or DEFAULT_SCROLL_HEIGHT
 displayEvent.scrollWidth = saSettings.scrollWidth or DEFAULT_SCROLL_WIDTH
 displayEvent.animationSpeed = (saSettings.animationSpeed or currentProfile.animationSpeed) / 100
 displayEvent.masterAlpha = fontAlpha / 100

 -- Default starting alpha and x/y positions.
 displayEvent.alpha = 1
 displayEvent.positionX = 0
 displayEvent.positionY = 0
 displayEvent.fontSize = fontSize
 
 -- Set font string properties.
 local fontString = displayEvent.fontString
 local fontOutline = OUTLINE_MAP[outlineIndex] or DEFAULT_OUTLINE
 if (not fontPath) then fontPath = DEFAULT_FONT_PATH else fontPath = testedFonts[fontPath] and fontPath or DEFAULT_FONT_PATH end
 fontString:ClearAllPoints()
 fontString:SetFont(fontPath, fontSize, fontOutline)
 fontString:SetTextColor(colorR, colorG, colorB)
 fontString:SetDrawLayer(isSticky and "OVERLAY" or "ARTWORK")
 if (not currentProfile.textShadowingDisabled) then
  fontString:SetShadowColor(0, 0, 0, 1)
  fontString:SetShadowOffset(1, -1)
 else
  fontString:SetShadowColor(0, 0, 0, 0)
  fontString:SetShadowOffset(0, 0)
 end
 fontString:SetAlpha(0)
 fontString:SetText(message)

 -- Set texture properties if there is a texture path that isn't the temp texture and icons are enabled.
 if (texturePath and texturePath ~= TEMP_TEXTURE_PATH and not saSettings.skillIconsDisabled and not currentProfile.skillIconsDisabled) then
  -- Reuse the texture for the current display event if there is one.
  local texture = displayEvent.texture
  
  -- No texture so acquire one from cache or create a new one if there aren't any available in cache.
  if (not texture) then texture = table_remove(textureCache) or animationFrame:CreateTexture(nil, "ARTWORK") end

  -- Set texture properties.
  texture:ClearAllPoints()
  texture:SetTexture(texturePath)
  texture:SetWidth(fontSize)
  texture:SetHeight(fontSize)
  texture:SetTexCoord(0.125, 0.875, 0.125, 0.875)
  if (saSettings.iconAlign == "Right") then texture:SetPoint("LEFT", fontString, "RIGHT", 4, 0) else texture:SetPoint("RIGHT", fontString, "LEFT", -4, 0) end
  texture:SetDrawLayer(isSticky and "OVERLAY" or "ARTWORK")
  texture:SetAlpha(0)
  displayEvent.texture = texture
 end

 -- Initialize timing properties.
 displayEvent.elapsedTime = 0
 displayEvent.timeSinceLastUpdate = 0
 displayEvent.scrollTime = DEFAULT_SCROLL_TIME
 displayEvent.fadePercent = DEFAULT_FADE_PERCENT

 -- Call the initialize function, set the text position accordingly, and scale the scroll time
 -- by the animation speed.
 animStyleSettings.initHandler(displayEvent, animationArray, direction, behavior)
 fontString:SetPoint(displayEvent.anchorPoint, displayEvent.offsetX + displayEvent.positionX, displayEvent.offsetY + displayEvent.positionY)
 displayEvent.scrollTime = displayEvent.scrollTime / displayEvent.animationSpeed

 -- Add the display event to the appropriate scroll area array.
 animationArray[#animationArray+1] = displayEvent

 -- Check if the animation frame is not visible and make it visible so the OnUpdate events start firing.
 -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
 if (not animationFrame:IsVisible()) then animationFrame:Show() end
end


-- ****************************************************************************
-- Displays the passed message using the passed event settings.
-- ****************************************************************************
local function DisplayEvent(eventSettings, message, texturePath)
 -- Get a local reference to the current profile.
 local currentProfile = MSBTProfiles.currentProfile

 -- Get the scroll area settings for the event. 
 local saSettings = scrollAreas[eventSettings.scrollArea] or scrollAreas[DEFAULT_SCROLL_AREA]

 -- Leave the function if the scroll area is invalid or disabled. 
 if (not saSettings or saSettings.disabled) then return end

 
 -- Get the inherited font values.
 local fontSize, fontName, outlineIndex, fontAlpha, isSticky
 if (eventSettings.isCrit) then
  fontSize = eventSettings.fontSize or saSettings.critFontSize or currentProfile.critFontSize
  fontName = eventSettings.fontName or saSettings.critFontName or currentProfile.critFontName
  outlineIndex = eventSettings.outlineIndex or saSettings.critOutlineIndex or currentProfile.critOutlineIndex
  fontAlpha = eventSettings.fontAlpha or saSettings.critFontAlpha or currentProfile.critFontAlpha

  if (not currentProfile.stickyCritsDisabled) then isSticky = true end

 else
  fontSize = eventSettings.fontSize or saSettings.normalFontSize or currentProfile.normalFontSize
  fontName = eventSettings.fontName or saSettings.normalFontName or currentProfile.normalFontName
  outlineIndex = eventSettings.outlineIndex or saSettings.normalOutlineIndex or currentProfile.normalOutlineIndex
  fontAlpha = eventSettings.fontAlpha or saSettings.normalFontAlpha or currentProfile.normalFontAlpha
 end

 isSticky = isSticky or eventSettings.alwaysSticky
 
 -- Play the event's sound file if there is one and sounds are enabled.
 local soundFile = eventSettings.soundFile
 if (soundFile and not currentProfile.soundsDisabled) then
  soundFile = sounds[soundFile] or (string_find(soundFile, "\\", 1, true) and soundFile) or DEFAULT_SOUND_PATH .. soundFile
  PlaySoundFile(soundFile, "Master")
 end

 Display(message, saSettings, isSticky, eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1, fontSize, fonts[fontName], outlineIndex, fontAlpha, texturePath)
end


-- ****************************************************************************
-- Displays the passed message using the passed parameters.  This function is
-- for easy displaying of messages from external sources.  See the included
-- API.html file for usage info.
-- ****************************************************************************
local function DisplayMessage(message, scrollArea, isSticky, colorR, colorG, colorB, fontSize, fontName, outlineIndex, texturePath)
 -- Do nothing if no message was passed or the mod is disabled.
 if (not message or IsModDisabled()) then return end

 -- Attempt to get the scroll area settings for the passed scroll area.
 local saSettings = scrollAreas[scrollArea]
 if (not saSettings) then
  -- Loop through all of the scroll areas to see if the passed scroll area matches one of the names.
  for _, settings in pairs(scrollAreas) do
   if (scrollArea == settings.name) then saSettings = settings end
  end
 end

 -- Use the default scroll area settings if a valid one could not be found.
 saSettings = saSettings or scrollAreas[DEFAULT_SCROLL_AREA] 

 -- Leave the function if the scroll area is invalid or disabled.
 if (not saSettings or saSettings.disabled) then return end


 -- Set the red, green, and blue color values to default if they are invalid.
 if (colorR == nil or colorR < 0 or colorR > 255) then colorR = 255 end
 if (colorG == nil or colorG < 0 or colorG > 255) then colorG = 255 end
 if (colorB == nil or colorB < 0 or colorB > 255) then colorB = 255 end


 -- Get a local reference to the current profile.
 local currentProfile = MSBTProfiles.currentProfile

 -- Inherit the font size if the passed value is invalid.
 if (fontSize == nil or fontSize < 4 or fontSize > 38) then
  fontSize = saSettings.normalFontSize or currentProfile.normalFontSize
 end

 -- Inherit the font if the passed value is invalid.
 local fontPath = fonts[fontName] or fonts[saSettings.normalFontName or currentProfile.normalFontName]

 -- Inherit the font outline if the passed value is invalid.
 if (not OUTLINE_MAP[outlineIndex]) then
  outlineIndex = saSettings.normalOutlineIndex or currentProfile.normalOutlineIndex
 end
 
 -- Inherit the font alpha.
 local fontAlpha = saSettings.normalFontAlpha or currentProfile.normalFontAlpha
 
 Display(message, saSettings, isSticky, colorR / 255, colorG / 255, colorB / 255, fontSize, fontPath, outlineIndex, fontAlpha, texturePath)
end


-- ****************************************************************************
-- Animates the passed display event.
-- ****************************************************************************
local function AnimateEvent(displayEvent)
 local fontString = displayEvent.fontString
 local texture = displayEvent.texture
 local percentDone = displayEvent.elapsedTime / displayEvent.scrollTime

 if (percentDone <= 1) then
  -- Call the correct animation function for the display event.
  displayEvent.animationHandler(displayEvent, percentDone)
     
  -- Smoothly fade the text out as the animation completes.
  local fadePercent = displayEvent.fadePercent
  if (percentDone >= fadePercent) then displayEvent.alpha = (1 - percentDone) / (1 - fadePercent) end

  -- Move the text and set its alpha.
  fontString:SetPoint(displayEvent.anchorPoint, displayEvent.offsetX + displayEvent.positionX, displayEvent.offsetY + displayEvent.positionY)
  fontString:SetAlpha(displayEvent.masterAlpha * displayEvent.alpha)
  if (texture) then texture:SetAlpha(displayEvent.masterAlpha * displayEvent.alpha) end
 else
  -- Hide the text and set the animation complete flag.
  fontString:SetAlpha(0)
  if (texture) then texture:SetAlpha(0) end
  displayEvent.animationComplete = true
 end
end


-- ****************************************************************************
-- Called when the animation frame is updated.
-- ****************************************************************************
local function OnUpdateAnimationFrame(this, elapsed)
 -- Flag for whether or not all the animations are inactive.
 local allInactive = true

 -- Local variables to hold display event info.
 local numEvents, displayEvent, texture

 -- Loop through all of the animation arrays.
 for _, animationArray in pairs(animationData) do
  -- Loop through all of the display event arrays in the animation array.
  for _, displayEvents in pairs(animationArray) do
   numEvents = #displayEvents

   -- Loop through all the display events for the scroll area.
   for i = 1, numEvents do
    displayEvent = displayEvents[i]
    displayEvent.timeSinceLastUpdate = displayEvent.timeSinceLastUpdate + elapsed
    
    -- Animate the event if enough time has passed and reset the last updated time.
    if (displayEvent.timeSinceLastUpdate >= ANIMATION_DELAY) then
     displayEvent.elapsedTime = displayEvent.elapsedTime + displayEvent.timeSinceLastUpdate
     AnimateEvent(displayEvent)
     displayEvent.timeSinceLastUpdate = 0
    end


    -- Clear the all inactive flag
    allInactive = false
   end

   -- Loop backwards through all the display events for the animation array and remove the ones
   -- that are complete.
   for i = numEvents, 1, -1 do
    displayEvent = displayEvents[i]
    if (displayEvent.animationComplete) then
     table_remove(displayEvents, i)

     -- Reclaim the texture to cache and clear it so it can be reused if there is one.
     texture = displayEvent.texture
     if (texture) then
      textureCache[#textureCache+1] = texture
      texture:SetTexture(nil)
      displayEvent.texture = nil
     end

     -- Reclaim the display event to cache so it can be reused.
     displayEventCache[#displayEventCache+1] = displayEvent
     displayEvent.animationComplete = false
    end
   end
  end -- Loop through display event arrays.
 end -- Loop through animation arrays.


 -- Hide the animation frame if there are no active animations so the OnUpdate events stop firing.
 -- This is done to keep the number of OnUpdate events down to a minimum for better performance.
 if (allInactive) then this:Hide() end
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

-- Create a frame for receiving animation updates.
animationFrame = CreateFrame("Frame", "MSBTAnimationFrame", UIParent)
animationFrame:SetFrameStrata("HIGH")
animationFrame:SetPoint("BOTTOM", UIParent, "CENTER")
animationFrame:SetWidth(0.0001)
animationFrame:SetHeight(0.0001)
animationFrame:Hide()
animationFrame:SetScript("OnUpdate", OnUpdateAnimationFrame)

-- Memoize tested font paths so they only have to be tested once.
testFontString = animationFrame:CreateFontString(nil, "ARTWORK", MasterFont)
testedFonts.__index = TestFontPath
setmetatable(testedFonts, testedFonts)




-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Variables.
module.scrollAreas				= scrollAreas
module.animationStyles			= animationStyles
module.stickyAnimationStyles	= stickyAnimationStyles

-- Protected Functions.
module.IsScrollAreaActive			= IsScrollAreaActive
module.IsScrollAreaIconShown		= IsScrollAreaIconShown
module.UpdateScrollAreas			= UpdateScrollAreas
module.RegisterAnimationStyle		= RegisterAnimationStyle
module.RegisterStickyAnimationStyle	= RegisterStickyAnimationStyle
module.IterateScrollAreas			= IterateScrollAreas
module.DisplayMessage				= DisplayMessage
module.DisplayEvent					= DisplayEvent