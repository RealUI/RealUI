-------------------------------------------------------------------------------
-- Title: MSBT Options Tab Frames
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Tabs"
MSBTOptions[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various modules for faster access.
local MSBTOptMain = MSBTOptions.Main
local MSBTControls = MSBTOptions.Controls
local MSBTPopups = MSBTOptions.Popups
local MSBTProfiles = MikSBT.Profiles
local MSBTAnimations = MikSBT.Animations
local MSBTTriggers = MikSBT.Triggers
local MSBTCooldowns = MikSBT.Cooldowns
local MSBTMedia = MikSBT.Media
local L = MikSBT.translations

-- Local references to various functions for faster access.
local EraseTable = MikSBT.EraseTable
local DisableControls = MSBTPopups.DisableControls

-- Local references to various variables for faster access.
local fonts = MSBTMedia.fonts


-------------------------------------------------------------------------------
-- Private constants.
-------------------------------------------------------------------------------

-- Prevent tainting global _.
local _

local DEFAULT_PROFILE_NAME = "Default"
local DEFAULT_FONT_NAME = L.DEFAULT_FONT_NAME
local DEFAULT_SCROLL_AREA = "Notification"
local DEFAULT_FONT_PATH = "Interface\\AddOns\\MikScrollingBattleText\\Fonts\\"
local DEFAULT_SOUND_PATH = "Interface\\AddOns\\MikScrollingBattleText\\Sounds\\"

local EVENT_CATEGORY_MAP = {
  "INCOMING_PLAYER_EVENTS", "INCOMING_PET_EVENTS",
  "OUTGOING_PLAYER_EVENTS", "OUTGOING_PET_EVENTS",
  "NOTIFICATION_EVENTS"
}

-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Various tab frames.
local tabFrames = {}

-- Reusable table to configure popup frames.
local configTable = {}

-- Reusable table for lists.
local listTable = {}

-- Holds categorized events in the order to display them.
local orderedEvents = {}


-------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Returns a list of keys for the passed table sorted according to their
-- associated value.
-- ****************************************************************************
local function SortKeysByValue(t)
 local sortedKeys = {}
 local sortedValues = {}

 for k, v in pairs(t) do
  sortedKeys[#sortedKeys+1] = k
  sortedValues[#sortedValues+1] = v
 end

 local tempKey, tempValue, j
 for i = 2, #sortedValues do
  tempValue = sortedValues[i]
  tempKey = sortedKeys[i]
  j = i - 1
  while (j > 0 and sortedValues[j] > tempValue) do
   sortedValues[j + 1] = sortedValues[j]
   sortedKeys[j + 1] = sortedKeys[j]
   j = j - 1
  end
  sortedValues[j + 1] = tempValue
  sortedKeys[j + 1] = tempKey
 end

 return sortedKeys
end


-- ****************************************************************************
-- Returns an iterator for the passed table sorted by its keys.
-- ****************************************************************************
local function PairsByKeys(t)
 local temp = {}
 for k in pairs(t) do temp[#temp+1] = k end
 table.sort(temp)

 local position = 0
 local iterator = function ()
  position = position + 1
  if temp[position] == nil then
   return nil
  else
   return temp[position], t[temp[position]]
  end
 end
 return iterator
end


-- ****************************************************************************
-- Populates the list table with the entries from the current/master profile.
-- ****************************************************************************
local function PopulateList(listName)
 EraseTable(listTable)
 local currentProfileList = rawget(MSBTProfiles.currentProfile, listName)
 if (currentProfileList) then
  for name, value in pairs(currentProfileList) do
   listTable[name] = value
  end
 end
 
 -- Get skills available in the master profile that aren't in the current profile. 
 for name, value in pairs(MSBTProfiles.masterProfile[listName]) do
  if (listTable[name] == nil) then listTable[name] = value end
 end
end


-- ****************************************************************************
-- Saves the modified list to the current profile.
-- ****************************************************************************
local function SaveList(listName)
 for skillName, value in pairs(listTable) do
  MSBTProfiles.SetOption(listName, skillName, value)
 end
end


-------------------------------------------------------------------------------
-- Media tab functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Enables the controls on the custom media tab.
-- ****************************************************************************
local function MediaTab_EnableControls()
 for name, frame in pairs(tabFrames.media.controls) do
  if (frame.Enable) then frame:Enable() end
 end
end


-- ****************************************************************************
-- Validates the passed custom font path.
-- ****************************************************************************
local function MediaTab_ValidateCustomFontPath(fontPath, _, callback)
 if (not fontPath or fontPath == "") then return L.MSG_INVALID_CUSTOM_FONT_PATH end
 local fontPathLower = string.lower(fontPath)
 if (not string.find(fontPathLower, ".ttf")) then return L.MSG_INVALID_CUSTOM_FONT_PATH end

 local validationFontString = tabFrames.media.fontPathValidationFontString
 local normalFontPath, normalFontSize = GameFontNormal:GetFont()
 if (fontPathLower == string.lower(normalFontPath)) then return end

 -- This section is a bit hacky.  First, it seems that in order for a new font
 -- instance to take effect the text must be changed after setting it.  This
 -- was not always case, but appears to be now.  Next, the SetFont function now
 -- returns before the font is actually set.  It appears to be loaded async now.
 -- So, when a failing ttf is provided, setup a callback to give the font a
 -- chance to load before checking it again.
 validationFontString:SetFont(normalFontPath, normalFontSize)
 validationFontString:SetText("")
 if (not string.find(fontPath, "\\", 1, true)) then fontPath = DEFAULT_FONT_PATH .. fontPath end
 validationFontString:SetFont(fontPath, normalFontSize, "")
 validationFontString:SetText("Test")
 if (validationFontString:GetFont() == normalFontPath) then
  -- Setup a callback which checks the font path again after half a second and
  -- in turn calls the validate callback which updates the input box's error
  -- label and OK button.
  MSBTOptions.Main.ScheduleCallback(0.5,
   function ()
    local message
    if (validationFontString:GetFont() == normalFontPath) then message = L.MSG_UNABLE_TO_SET_FONT end
    callback(message)
   end
  )
  return L.MSG_TESTING_FONT
 end
end


-- ****************************************************************************
-- Validates the passed custom font name and path.
-- ****************************************************************************
local function MediaTab_ValidateCustomFont(fontName, fontPath, callback)
 if (not fontName or fontName == "") then return L.MSG_INVALID_CUSTOM_FONT_NAME end

 for name in pairs(MSBTMedia.fonts) do
  if (name == fontName) then return L.MSG_FONT_NAME_ALREADY_EXISTS end
 end
 
 return MediaTab_ValidateCustomFontPath(fontPath, nil, callback)
end


-- ****************************************************************************
-- Adds a new custom font with the passed name and path.
-- ****************************************************************************
local function MediaTab_AddCustomFont(settings)
 local fontName = settings.inputText
 local fontPath = settings.secondInputText
 if (not string.find(fontPath, "\\", 1, true)) then fontPath = DEFAULT_FONT_PATH .. fontPath end

 MSBTProfiles.savedMedia.fonts[fontName] = fontPath
 MSBTMedia.RegisterFont(fontName, fontPath)
 tabFrames.media.controls.customFontsListbox:AddItem(fontName, true)
end


-- ****************************************************************************
-- Changes the custom font to the passed name and path.
-- ****************************************************************************
local function MediaTab_ChangeCustomFont(settings)
 local fontName = settings.saveArg1
 local fontPath = settings.inputText
 if (not string.find(fontPath, "\\", 1, true)) then fontPath = DEFAULT_FONT_PATH .. fontPath end

 MSBTProfiles.savedMedia.fonts[fontName] = fontPath
 MSBTMedia.fonts[fontName] = fontPath
  
 tabFrames.media.controls.customFontsListbox:Refresh()
end


-- ****************************************************************************
-- Deletes the custom font for the passed line and removes the line.
-- ****************************************************************************
local function MediaTab_DeleteCustomFont(line)
 MSBTProfiles.savedMedia.fonts[line.fontKey] = nil
 MSBTMedia.fonts[line.fontKey] = nil
 tabFrames.media.controls.customFontsListbox:RemoveItem(line.itemNumber)
end


-- ****************************************************************************
-- Called when one of the delete custom font buttons is clicked.
-- ****************************************************************************
local function MediaTab_DeleteCustomFontButtonOnClick(this)
 EraseTable(configTable)
 configTable.parentFrame = tabFrames.media
 configTable.anchorFrame = this
 configTable.acknowledgeHandler = MediaTab_DeleteCustomFont
 configTable.saveArg1 = this:GetParent()
 configTable.hideHandler = MediaTab_EnableControls
 DisableControls(tabFrames.media.controls)
 MSBTPopups.ShowAcknowledge(configTable)
end


-- ****************************************************************************
-- Called when one of the edit custom font buttons is clicked.
-- ****************************************************************************
local function MediaTab_EditCustomFontSettingsButtonOnClick(this)
  local fontKey = this:GetParent().fontKey
  local fontPath = MSBTProfiles.savedMedia.fonts[fontKey]
  fontPath = string.gsub(fontPath, DEFAULT_FONT_PATH, "")

  local objLocale = L.EDITBOXES["customFontPath"]
  EraseTable(configTable)
  configTable.defaultText = fontPath
  configTable.editboxLabel = objLocale.label
  configTable.editboxTooltip = objLocale.tooltip
  configTable.parentFrame = tabFrames.media
  configTable.anchorFrame = this
  configTable.validateHandler = MediaTab_ValidateCustomFontPath
  configTable.saveHandler = MediaTab_ChangeCustomFont
  configTable.saveArg1 = fontKey
  configTable.hideHandler = MediaTab_EnableControls
  DisableControls(tabFrames.media.controls)
  MSBTPopups.ShowInput(configTable)
end


-- ****************************************************************************
-- Called by listbox to create a line for custom fonts.
-- ****************************************************************************
local function MediaTab_CreateCustomFontLine(this)
 local controls = tabFrames.media.controls
 
 local frame = CreateFrame("Button", nil, this)
 frame:EnableMouse(false)
 
 -- Delete custom font button. 
 local button = MSBTControls.CreateIconButton(frame, "Delete")
 local objLocale = L.BUTTONS["deleteCustomFont"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
 button:SetClickHandler(MediaTab_DeleteCustomFontButtonOnClick)
 frame.deleteButton = button
 controls[#controls+1] = button

 -- Edit font setting button. 
 local button = MSBTControls.CreateIconButton(frame, "Configure")
 objLocale = L.BUTTONS["editCustomFont"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
 button:SetClickHandler(MediaTab_EditCustomFontSettingsButtonOnClick)
 controls[#controls+1] = button

 -- Font name font string.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
 fontString:SetPoint("LEFT", frame, "LEFT", 10, 0)
 fontString:SetJustifyH("LEFT")
 fontString:SetWidth(130)
 frame.fontNameFontString = fontString

 -- Font path label.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", frame.fontNameFontString, "RIGHT", 10, 0)
 fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 frame.fontPathFontString = fontString

 return frame
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function MediaTab_DisplayCustomFontLine(this, line, key, isSelected)
 local fonts = MSBTProfiles.savedMedia.fonts
 line.fontKey = key
 local fontPath = fonts[key]

 local normalFontPath, normalFontHeight, normalFontOutline = GameFontNormal:GetFont()
 line.fontNameFontString:SetFont(normalFontPath, normalFontHeight, normalFontOutline)

 local _, fontHeight, fontOutline = line.fontNameFontString:GetFont()
 line.fontNameFontString:SetFont(fontPath, fontHeight, fontOutline)
 line.fontNameFontString:SetText(key)

 fontPath = string.gsub(fontPath, DEFAULT_FONT_PATH, "")
 line.fontPathFontString:SetText(fontPath) 
end


-- ****************************************************************************
-- Validates the passed custom sound path.
-- ****************************************************************************
local function MediaTab_ValidateCustomSoundPath(soundPath)
 if (not soundPath or soundPath == "") then return L.MSG_INVALID_SOUND_FILE end
 local soundPathLower = string.lower(soundPath)
 if (not string.find(soundPathLower, ".mp3") and not string.find(soundPathLower, ".ogg")) then
  return L.MSG_INVALID_SOUND_FILE
 end
end


-- ****************************************************************************
-- Validates the passed custom sound name and path.
-- ****************************************************************************
local function MediaTab_ValidateCustomSound(soundName, soundPath)
 if (not soundName or soundName == "") then return L.MSG_INVALID_CUSTOM_SOUND_NAME end

 for name in pairs(MSBTMedia.sounds) do
  if (name == soundName) then return L.MSG_SOUND_NAME_ALREADY_EXISTS end
 end
 
 return MediaTab_ValidateCustomSoundPath(soundPath)
end


-- ****************************************************************************
-- Adds a new custom sound with the passed name and path.
-- ****************************************************************************
local function MediaTab_AddCustomSound(settings)
 local soundName = settings.inputText
 local soundPath = settings.secondInputText
 if (not string.find(soundPath, "\\", 1, true)) then soundPath = DEFAULT_SOUND_PATH .. soundPath end

 MSBTProfiles.savedMedia.sounds[soundName] = soundPath
 MSBTMedia.RegisterSound(soundName, soundPath)
 tabFrames.media.controls.customSoundsListbox:AddItem(soundName, true)
end


-- ****************************************************************************
-- Changes the custom sound to the passed name and path.
-- ****************************************************************************
local function MediaTab_ChangeCustomSound(settings)
 local soundName = settings.saveArg1
 local soundPath = settings.inputText
 if (not string.find(soundPath, "\\", 1, true)) then soundPath = DEFAULT_SOUND_PATH .. soundPath end

 MSBTProfiles.savedMedia.sounds[soundName] = soundPath
 MSBTMedia.sounds[soundName] = soundPath
  
 tabFrames.media.controls.customSoundsListbox:Refresh()
end


-- ****************************************************************************
-- Deletes the custom sound for the passed line and removes the line.
-- ****************************************************************************
local function MediaTab_DeleteCustomSound(line)
 MSBTProfiles.savedMedia.sounds[line.soundKey] = nil
 MSBTMedia.sounds[line.soundKey] = nil
 tabFrames.media.controls.customSoundsListbox:RemoveItem(line.itemNumber)
end


-- ****************************************************************************
-- Called when one of the delete custom sound buttons is clicked.
-- ****************************************************************************
local function MediaTab_DeleteCustomSoundButtonOnClick(this)
 EraseTable(configTable)
 configTable.parentFrame = tabFrames.media
 configTable.anchorFrame = this
 configTable.acknowledgeHandler = MediaTab_DeleteCustomSound
 configTable.saveArg1 = this:GetParent()
 configTable.hideHandler = MediaTab_EnableControls
 DisableControls(tabFrames.media.controls)
 MSBTPopups.ShowAcknowledge(configTable)
end


-- ****************************************************************************
-- Called when one of the edit custom sound buttons is clicked.
-- ****************************************************************************
local function MediaTab_EditCustomSoundSettingsButtonOnClick(this)
  local soundKey = this:GetParent().soundKey
  local soundPath = MSBTProfiles.savedMedia.sounds[soundKey]
  soundPath = string.gsub(soundPath, DEFAULT_SOUND_PATH, "")

  local objLocale = L.EDITBOXES["customSoundPath"]
  EraseTable(configTable)
  configTable.defaultText = soundPath
  configTable.editboxLabel = objLocale.label
  configTable.editboxTooltip = objLocale.tooltip
  configTable.parentFrame = tabFrames.media
  configTable.anchorFrame = this
  configTable.validateHandler = MediaTab_ValidateCustomSoundPath
  configTable.saveHandler = MediaTab_ChangeCustomSound
  configTable.saveArg1 = soundKey
  configTable.hideHandler = MediaTab_EnableControls
  DisableControls(tabFrames.media.controls)
  MSBTPopups.ShowInput(configTable)
end


-- ****************************************************************************
-- Called by listbox to create a line for custom sounds.
-- ****************************************************************************
local function MediaTab_CreateCustomSoundLine(this)
 local controls = tabFrames.media.controls
 
 local frame = CreateFrame("Button", nil, this)
 frame:EnableMouse(false)
 
 -- Delete custom sound button. 
 local button = MSBTControls.CreateIconButton(frame, "Delete")
 local objLocale = L.BUTTONS["deleteCustomSound"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
 button:SetClickHandler(MediaTab_DeleteCustomSoundButtonOnClick)
 frame.deleteButton = button
 controls[#controls+1] = button

 -- Edit sound setting button. 
 local button = MSBTControls.CreateIconButton(frame, "Configure")
 objLocale = L.BUTTONS["editCustomSound"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
 button:SetClickHandler(MediaTab_EditCustomSoundSettingsButtonOnClick)
 controls[#controls+1] = button
 
 -- Play sound button.
 button = MSBTControls.CreateOptionButton(frame)
 local objLocale = L.BUTTONS["playSound"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("RIGHT", controls[#controls], "LEFT", -10, 0)
 button:SetClickHandler(
  function (this)
   local soundName = this:GetParent().soundKey
   local soundFile = MSBTProfiles.savedMedia.sounds[soundName]
   PlaySoundFile(soundFile, "Master")
  end
 )
 controls[#controls+1] = button

 -- Sound name font string.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", frame, "LEFT", 10, 0)
 fontString:SetJustifyH("LEFT")
 fontString:SetWidth(100)
 frame.soundNameFontString = fontString
 

 -- Sound path label.
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", frame.soundNameFontString, "RIGHT", 10, 0)
 fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 frame.soundPathFontString = fontString

 return frame
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function MediaTab_DisplayCustomSoundLine(this, line, key, isSelected)
 local sounds = MSBTProfiles.savedMedia.sounds
 line.soundKey = key
 local soundPath = sounds[key]

 line.soundNameFontString:SetText(key)

 soundPath = string.gsub(soundPath, DEFAULT_SOUND_PATH, "")
 line.soundPathFontString:SetText(soundPath) 
end


-- ****************************************************************************
-- Creates the media tab frame contents.
-- ****************************************************************************
local function MediaTab_Create()
 local tabFrame = tabFrames.media
 tabFrame.controls = {}
 local controls = tabFrame.controls

 -- Custom fonts label.
 local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -10)
 fontString:SetText(L.MSG_CUSTOM_FONTS)

 -- Add custom font button
 local button = MSBTControls.CreateOptionButton(tabFrame)
 local objLocale = L.BUTTONS["addCustomFont"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("LEFT", fontString, "RIGHT", 10, 0)
 button:SetClickHandler(
  function (this)
   local objLocale = L.EDITBOXES["customFontName"]
   EraseTable(configTable)
   configTable.editboxLabel = objLocale.label
   configTable.editboxTooltip = objLocale.tooltip
   configTable.parentFrame = tabFrames.media
   configTable.anchorFrame = this
   objLocale = L.EDITBOXES["customFontPath"]
   configTable.showSecondEditbox = true
   configTable.secondEditboxLabel = objLocale.label
   configTable.secondEditboxTooltip = objLocale.tooltip
   configTable.validateHandler = MediaTab_ValidateCustomFont
   configTable.saveHandler = MediaTab_AddCustomFont
   configTable.hideHandler = MediaTab_EnableControls
   DisableControls(tabFrames.media.controls)
   MSBTPopups.ShowInput(configTable)
  end
 )
 controls.addCustomFontButton = button
 
 -- Custom fonts listbox. 
 local listbox = MSBTControls.CreateListbox(tabFrame)
 listbox:Configure(400, 150, 25)
 listbox:SetPoint("TOPLEFT", fontString, "BOTTOMLEFT", -5, -10)
 listbox:SetCreateLineHandler(MediaTab_CreateCustomFontLine)
 listbox:SetDisplayHandler(MediaTab_DisplayCustomFontLine)
 controls.customFontsListbox = listbox

 -- Custom sounds label.
 local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOPLEFT", controls.customFontsListbox, "BOTTOMLEFT", 5, -10)
 fontString:SetText(L.MSG_CUSTOM_SOUNDS)

 -- Add custom sound button
 local button = MSBTControls.CreateOptionButton(tabFrame)
 local objLocale = L.BUTTONS["addCustomSound"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("LEFT", fontString, "RIGHT", 10, 0)
 button:SetClickHandler(
  function (this)
   local objLocale = L.EDITBOXES["customSoundName"]
   EraseTable(configTable)
   configTable.editboxLabel = objLocale.label
   configTable.editboxTooltip = objLocale.tooltip
   configTable.parentFrame = tabFrames.media
   configTable.anchorFrame = this
   objLocale = L.EDITBOXES["customSoundPath"]
   configTable.showSecondEditbox = true
   configTable.secondEditboxLabel = objLocale.label
   configTable.secondEditboxTooltip = objLocale.tooltip
   configTable.validateHandler = MediaTab_ValidateCustomSound
   configTable.saveHandler = MediaTab_AddCustomSound
   configTable.hideHandler = MediaTab_EnableControls
   DisableControls(tabFrames.media.controls)
   MSBTPopups.ShowInput(configTable)
  end
 )
 controls.addCustomSoundButton = button

 -- Custom sounds listbox. 
 local listbox = MSBTControls.CreateListbox(tabFrame)
 listbox:Configure(400, 125, 25)
 listbox:SetPoint("TOPLEFT", fontString, "BOTTOMLEFT", -5, -10)
 listbox:SetCreateLineHandler(MediaTab_CreateCustomSoundLine)
 listbox:SetDisplayHandler(MediaTab_DisplayCustomSoundLine)
 controls.customSoundsListbox = listbox

 -- Font path validation font string.
 local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
 fontString:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", 0, 0)
 fontString:SetText("Test")
 fontString:SetAlpha(0)
 tabFrame.fontPathValidationFontString = fontString
 
 tabFrame.created = true
end


-- ****************************************************************************
-- Called when the tab frame is shown.
-- ****************************************************************************
local function MediaTab_OnShow()
 if (not tabFrames.media.created) then MediaTab_Create() end

 -- Set the frame up to populate the profile options when it is shown.
 local fontsListbox = tabFrames.media.controls.customFontsListbox
 local previousOffset = fontsListbox:GetOffset()
 fontsListbox:Clear()
 for key in PairsByKeys(MSBTProfiles.savedMedia.fonts) do
  fontsListbox:AddItem(key)
 end
 fontsListbox:SetOffset(previousOffset)
 
 local soundsListbox = tabFrames.media.controls.customSoundsListbox
 local previousOffset = soundsListbox:GetOffset()
 soundsListbox:Clear()
 for key in PairsByKeys(MSBTProfiles.savedMedia.sounds) do
  soundsListbox:AddItem(key)
 end
 soundsListbox:SetOffset(previousOffset)
end


-------------------------------------------------------------------------------
-- General tab functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Toggle the enable state of the profile buttons appropriately.
-- ****************************************************************************
local function GeneralTab_ToggleDeleteButton()
 local controls = tabFrames.general.controls
 
 if (controls.profileDropdown:GetSelectedID() == DEFAULT_PROFILE_NAME) then
  controls.deleteProfileButton:Disable()
 else
  controls.deleteProfileButton:Enable()
 end
end


-- ****************************************************************************
-- Enables the controls on the general tab.
-- ****************************************************************************
local function GeneralTab_EnableControls()
 for name, frame in pairs(tabFrames.general.controls) do
  if (frame.Enable) then frame:Enable() end
 end
 
 GeneralTab_ToggleDeleteButton()
end


-- ****************************************************************************
-- Populate the controls with the profile settings.
-- ****************************************************************************
local function GeneralTab_Populate()
 local currentProfile = MSBTProfiles.currentProfile
 local controls = tabFrames.general.controls
 
 controls.enableCheckbox:SetChecked(not MSBTProfiles.IsModDisabled())
 if GetCVar("floatingCombatTextCombatDamage") == "0" then
  controls.enableBlizzardDamage:SetChecked(false)
  currentProfile.enableBlizzardDamage = false
 else
  controls.enableBlizzardDamage:SetChecked(true)
  currentProfile.enableBlizzardDamage = true
 end
 if GetCVar("floatingCombatTextCombatHealing") == "0" then
  controls.enableBlizzardHealing:SetChecked(false)
  currentProfile.enableBlizzardHealing = false
 else
  controls.enableBlizzardHealing:SetChecked(true)
  currentProfile.enableBlizzardHealing = true
 end
 controls.stickyCritsCheckbox:SetChecked(not currentProfile.stickyCritsDisabled)
 controls.enableSoundsCheckbox:SetChecked(not currentProfile.soundsDisabled)
 controls.textShadowingCheckbox:SetChecked(not currentProfile.textShadowingDisabled)
 controls.animationSpeedSlider:SetValue(currentProfile.animationSpeed)
end


-- ****************************************************************************
-- Validates if the passed profile name does not already exist and is valid.
-- ****************************************************************************
local function GenerelTab_ValidateProfileName(profileName)
 if (not profileName or profileName == "") then
  return L.MSG_INVALID_PROFILE_NAME
 end

 if (MSBTProfiles.savedVariables.profiles[profileName]) then
  return L.MSG_PROFILE_ALREADY_EXISTS
 end
end


-- ****************************************************************************
-- Copies the selected profile to the name entered.
-- ****************************************************************************
local function GeneralTab_CopyProfile(settings)
 local profileName = settings.inputText
 local controls = tabFrames.general.controls

 local dropdown = controls.profileDropdown
 MSBTProfiles.CopyProfile(dropdown:GetSelectedID(), profileName)
 dropdown:AddItem(profileName, profileName)
 dropdown:Sort()

 dropdown:SetSelectedID(profileName)
 MSBTProfiles.SelectProfile(profileName)
 GeneralTab_Populate()
 GeneralTab_ToggleDeleteButton()
end


-- ****************************************************************************
-- Resets the selected profile.
-- ****************************************************************************
local function GeneralTab_ResetProfile()
 local controls = tabFrames.general.controls

 MSBTProfiles.ResetProfile(controls.profileDropdown:GetSelectedID())
 GeneralTab_Populate()
end


-- ****************************************************************************
-- Deletes the selected profile.
-- ****************************************************************************
local function GeneralTab_DeleteProfile()
 local controls = tabFrames.general.controls

 local dropdown = controls.profileDropdown
 local profileName = dropdown:GetSelectedID()
 MSBTProfiles.DeleteProfile(profileName)
 dropdown:RemoveItem(profileName)

 dropdown:SetSelectedID(DEFAULT_PROFILE_NAME)
 GeneralTab_Populate()
 GeneralTab_ToggleDeleteButton()
end


-- ****************************************************************************
-- Saves the font settings selected by the user.
-- ****************************************************************************
local function GeneralTab_SaveFontSettings(fontSettings)
 -- Normal font settings.
 MSBTProfiles.SetOption(nil, "normalFontName", fontSettings.normalFontName)
 MSBTProfiles.SetOption(nil, "normalOutlineIndex", fontSettings.normalOutlineIndex)
 MSBTProfiles.SetOption(nil, "normalFontSize", fontSettings.normalFontSize)
 MSBTProfiles.SetOption(nil, "normalFontAlpha", fontSettings.normalFontAlpha) 
 
 -- Crit font settings.
 MSBTProfiles.SetOption(nil, "critFontName", fontSettings.critFontName)
 MSBTProfiles.SetOption(nil, "critOutlineIndex", fontSettings.critOutlineIndex)
 MSBTProfiles.SetOption(nil, "critFontSize", fontSettings.critFontSize)
 MSBTProfiles.SetOption(nil, "critFontAlpha", fontSettings.critFontAlpha) 
end


-- ****************************************************************************
-- Creates the general tab frame contents.
-- ****************************************************************************
local function GeneralTab_Create()
 local tabFrame = tabFrames.general
 tabFrame.controls = {}
 local controls = tabFrame.controls
 
 -- Enable checkbox.
 local checkbox = MSBTControls.CreateCheckbox(tabFrame)
 local objLocale = L.CHECKBOXES["enableMSBT"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -5)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOptionUserDisabled(not isChecked)
   end
 )
 controls.enableCheckbox = checkbox

  -- Enable Blizzard Damage.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["enableBlizzardDamage"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("LEFT", controls.enableCheckbox, "RIGHT", 30, 0)
 checkbox:SetClickHandler(
   function (this, isChecked)
    if InCombatLockdown() then
      return
    end
    MSBTProfiles.SetOption(nil, "enableBlizzardDamage", not isChecked)
    if isChecked then
     SetCVar("floatingCombatTextCombatDamage", 1)
    else
      SetCVar("floatingCombatTextCombatDamage", 0)
    end
   end
 )
 controls.enableBlizzardDamage = checkbox

  -- Enable Blizzard healing.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["enableBlizzardHealing"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.enableBlizzardDamage, "BOTTOMLEFT", 0, 0)
 checkbox:SetClickHandler(
   function (this, isChecked)
    if InCombatLockdown() then
      return
    end
    MSBTProfiles.SetOption(nil, "enableBlizzardHealing", not isChecked)
    if isChecked then
     SetCVar("floatingCombatTextCombatHealing", 1)
    else
      SetCVar("floatingCombatTextCombatHealing", 0)
    end
   end
 )
 controls.enableBlizzardHealing = checkbox


 -- Profile dropdown.
 local dropdown =  MSBTControls.CreateDropdown(tabFrame)
 objLocale = L.DROPDOWNS["profile"]
 dropdown:Configure(180, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", controls.enableCheckbox, "BOTTOMLEFT", 0, -30)
 dropdown:SetChangeHandler(
  function (this, id)
   MSBTProfiles.SelectProfile(id)
   GeneralTab_Populate()
   GeneralTab_ToggleDeleteButton()
  end
 )
 controls.profileDropdown = dropdown

 
 -- Copy profile button.
 local button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["copyProfile"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -20)
 button:SetClickHandler(
   function (this)
    local objLocale = L.EDITBOXES["copyProfile"]
    EraseTable(configTable)
    configTable.defaultText = L.MSG_NEW_PROFILE
    configTable.editboxLabel = objLocale.label
    configTable.editboxTooltip = objLocale.tooltip
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = this
    configTable.validateHandler = GeneralTab_ValidateProfileName
    configTable.saveHandler = GeneralTab_CopyProfile
    configTable.hideHandler = GeneralTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowInput(configTable)
   end
 )
 controls.copyProfileButton = button

 -- Reset profile button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["resetProfile"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("LEFT", controls.copyProfileButton, "RIGHT", 10, 0)
 button:SetClickHandler(
   function (this)
    EraseTable(configTable)
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = this
    configTable.acknowledgeHandler = GeneralTab_ResetProfile
    configTable.hideHandler = GeneralTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowAcknowledge(configTable)
   end
 )
 controls.resetProfileButton = button
 
 -- Delete profile button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["deleteProfile"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("LEFT", controls.resetProfileButton, "RIGHT", 10, 0)
 button:SetClickHandler(
   function (this)
    EraseTable(configTable)
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = this
    configTable.anchorPoint = "TOPRIGHT"
    configTable.relativePoint = "BOTTOMRIGHT"
    configTable.acknowledgeHandler = GeneralTab_DeleteProfile
    configTable.hideHandler = GeneralTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowAcknowledge(configTable)
   end
 )
 controls.deleteProfileButton = button
 

 -- Animation speed slider.
 local slider = MSBTControls.CreateSlider(tabFrame)
 objLocale = L.SLIDERS["animationSpeed"] 
 slider:Configure(180, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", controls.copyProfileButton, "BOTTOMLEFT", 0, -35)
 slider:SetMinMaxValues(20, 250)
 slider:SetValueStep(10)
 slider:SetValueChangedHandler(
   function(this, value)
     MSBTProfiles.SetOption(nil, "animationSpeed", value)
   end
 )
 controls.animationSpeedSlider = slider

 
 -- Text shadowing checkbox.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["textShadowing"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", -30, 15)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "textShadowingDisabled", not isChecked)
   end
 )
 controls.textShadowingCheckbox = checkbox
 
 -- Enable sounds checkbox.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["enableSounds"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMLEFT", controls.textShadowingCheckbox, "TOPLEFT", 0, 0)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "soundsDisabled", not isChecked)
   end
 )
 controls.enableSoundsCheckbox = checkbox
 
 -- Sticky crits checkbox.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["stickyCrits"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMLEFT", controls.enableSoundsCheckbox, "TOPLEFT", 0, 0)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "stickyCritsDisabled", not isChecked)
   end
 )
 controls.stickyCritsCheckbox = checkbox
 


  -- Class colors button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["classColors"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", tabFrame, "BOTTOMLEFT", 5, 15)
 button:SetClickHandler(
   function (this)
    EraseTable(configTable)
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = this
    configTable.anchorPoint = "BOTTOMLEFT"
    configTable.relativePoint = "TOPLEFT"
    configTable.hideHandler = GeneralTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowClassColors(configTable)
   end
 )
 controls.classColorsButton = button

 -- Damage colors button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["damageColors"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", controls.classColorsButton, "TOPLEFT", 0, 10)
 button:SetClickHandler(
   function (this)
    EraseTable(configTable)
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = this
    configTable.anchorPoint = "BOTTOMLEFT"
    configTable.relativePoint = "TOPLEFT"
    configTable.hideHandler = GeneralTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowDamageColors(configTable)
   end
 )
 controls.damageColorsButton = button

 -- Partial effects button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["partialEffects"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", controls.damageColorsButton, "TOPLEFT", 0, 10)
 button:SetClickHandler(
   function (this)
    EraseTable(configTable)
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = this
    configTable.anchorPoint = "BOTTOMLEFT"
    configTable.relativePoint = "TOPLEFT"
    configTable.hideHandler = GeneralTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowPartialEffects(configTable)
   end
 )
 controls.partialEffectsButton = button

 -- Master font settings button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["masterFont"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", controls.partialEffectsButton, "TOPLEFT", 0, 10)
 button:SetClickHandler(
   function (this)
    EraseTable(configTable)
    configTable.title = objLocale.label

    local fontName = MSBTProfiles.currentProfile.normalFontName
    if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
    configTable.normalFontName = fontName
    configTable.normalOutlineIndex = MSBTProfiles.currentProfile.normalOutlineIndex
    configTable.normalFontSize = MSBTProfiles.currentProfile.normalFontSize
    configTable.normalFontAlpha = MSBTProfiles.currentProfile.normalFontAlpha

    fontName = MSBTProfiles.currentProfile.critFontName
    if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
    configTable.critFontName = fontName
    configTable.critOutlineIndex = MSBTProfiles.currentProfile.critOutlineIndex
    configTable.critFontSize = MSBTProfiles.currentProfile.critFontSize
    configTable.critFontAlpha = MSBTProfiles.currentProfile.critFontAlpha
    configTable.hideInherit = true
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = tabFrame
    configTable.anchorPoint = "BOTTOM"
    configTable.relativePoint = "BOTTOM"
    configTable.saveHandler = GeneralTab_SaveFontSettings
    configTable.hideHandler = GeneralTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowFont(configTable)
   end
 )
 controls.masterFontButton = button


 -- Populate the available profiles and select the current profile by default.
 local currentProfileName
 for profileName, profile in pairs(MSBTProfiles.savedVariables.profiles) do
  dropdown:AddItem(profileName, profileName)
  if (profile == MSBTProfiles.currentProfile) then currentProfileName = profileName end
 end
 dropdown:SetSelectedID(currentProfileName)
 dropdown:Sort()
 GeneralTab_ToggleDeleteButton()
 
 tabFrame.created = true
end


-- ****************************************************************************
-- Called when the tab frame is shown.
-- ****************************************************************************
local function GeneralTab_OnShow()
 if (not tabFrames.general.created) then GeneralTab_Create() end

  -- Set the frame up to populate the profile options when it is shown.
 GeneralTab_Populate()
end


-------------------------------------------------------------------------------
-- Scroll areas tab functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Enables the controls on the scroll areas tab.
-- ****************************************************************************
local function ScrollAreasTab_EnableControls()
 for name, frame in pairs(tabFrames.scrollAreas.controls) do
  if (frame.Enable) then frame:Enable() end
 end

 -- Refresh listbox so the default scroll area delete buttons are disabled.
 tabFrames.scrollAreas.controls.scrollAreasListbox:Refresh()
end


-- ****************************************************************************
-- Validates if the passed scroll area does not already exist and is valid.
-- ****************************************************************************
local function ScrollAreasTab_ValidateScrollAreaName(scrollAreaName)
 if (not scrollAreaName or scrollAreaName == "") then
  return L.MSG_INVALID_SCROLL_AREA_NAME
 end

 for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
  if (saSettings.name == scrollAreaName) then return L.MSG_SCROLL_AREA_ALREADY_EXISTS end
 end
end


-- ****************************************************************************
-- Adds a new scroll area with the passed scroll area name.
-- ****************************************************************************
local function ScrollAreasTab_AddScrollArea(settings)
 local nextAvailable = 1
 while (MSBTProfiles.currentProfile.scrollAreas["Custom" .. nextAvailable]) do
  nextAvailable = nextAvailable + 1
 end
 
 local newKey = "Custom" .. nextAvailable
 local saSettings = {}
 saSettings.name = settings.inputText
 MSBTProfiles.SetOption("scrollAreas", newKey, saSettings)
 MSBTAnimations.UpdateScrollAreas()
 tabFrames.scrollAreas.controls.scrollAreasListbox:AddItem(newKey, true)
end


-- ****************************************************************************
-- Called when one of the enable scroll area checkboxes is clicked.
-- ****************************************************************************
local function ScrollAreasTab_EnableOnClick(this, isChecked)
 local line = this:GetParent()
 MSBTProfiles.SetOption("scrollAreas." .. line.scrollAreaKey, "disabled", not isChecked)
 MSBTAnimations.UpdateScrollAreas()
end


-- ****************************************************************************
-- Changes the passed scroll area to the passed name.
-- ****************************************************************************
local function ScrollAreasTab_ChangeScrollAreaName(settings)
 MSBTProfiles.SetOption("scrollAreas." .. settings.saveArg1, "name", settings.inputText)
 MSBTAnimations.UpdateScrollAreas()
 tabFrames.scrollAreas.controls.scrollAreasListbox:Refresh()
end


-- ****************************************************************************
-- Called when one of the edit scroll area name buttons is clicked.
-- ****************************************************************************
local function ScrollAreasTab_EditNameButtonOnClick(this)
  local saKey = this:GetParent().scrollAreaKey
  local objLocale = L.EDITBOXES["scrollAreaName"]
  EraseTable(configTable)
  configTable.defaultText = MSBTProfiles.currentProfile.scrollAreas[saKey].name
  configTable.editboxLabel = objLocale.label
  configTable.editboxTooltip = objLocale.tooltip
  configTable.parentFrame = tabFrames.scrollAreas
  configTable.anchorFrame = this
  configTable.anchorPoint = this:GetParent().lineNumber > 5 and "BOTTOMRIGHT" or "TOPRIGHT"
  configTable.relativePoint = this:GetParent().lineNumber > 5 and "TOPRIGHT" or "BOTTOMRIGHT"
  configTable.validateHandler = ScrollAreasTab_ValidateScrollAreaName
  configTable.saveHandler = ScrollAreasTab_ChangeScrollAreaName
  configTable.saveArg1 = saKey
  configTable.hideHandler = ScrollAreasTab_EnableControls
  DisableControls(tabFrames.scrollAreas.controls)
  MSBTPopups.ShowInput(configTable)
end


-- ****************************************************************************
-- Deletes the scroll area for the passed line and removes the line.
-- ****************************************************************************
local function ScrollAreasTab_DeleteScrollArea(line)
 MSBTProfiles.SetOption("scrollAreas", line.scrollAreaKey, nil)
 tabFrames.scrollAreas.controls.scrollAreasListbox:RemoveItem(line.itemNumber)
 MSBTAnimations.UpdateScrollAreas()
end


-- ****************************************************************************
-- Called when one of the delete scroll area buttons is clicked.
-- ****************************************************************************
local function ScrollAreasTab_DeleteButtonOnClick(this)
 EraseTable(configTable)
 configTable.parentFrame = tabFrames.scrollAreas
 configTable.anchorFrame = this
 configTable.anchorPoint = this:GetParent().lineNumber > 5 and "BOTTOMRIGHT" or "TOPRIGHT"
 configTable.relativePoint = this:GetParent().lineNumber > 5 and "TOPRIGHT" or "BOTTOMRIGHT"
 configTable.acknowledgeHandler = ScrollAreasTab_DeleteScrollArea
 configTable.saveArg1 = this:GetParent()
 configTable.hideHandler = ScrollAreasTab_EnableControls
 DisableControls(tabFrames.scrollAreas.controls)
 MSBTPopups.ShowAcknowledge(configTable)
end


-- ****************************************************************************
-- Saves the font settings selected by the user.
-- ****************************************************************************
local function ScrollAreasTab_SaveFontSettings(fontSettings, scrollAreaKey)
 -- Normal font settings.
 MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "normalFontName", fontSettings.normalFontName)
 MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "normalOutlineIndex", fontSettings.normalOutlineIndex)
 MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "normalFontSize", fontSettings.normalFontSize)
 MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "normalFontAlpha", fontSettings.normalFontAlpha) 
 
 -- Crit font settings.
 MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "critFontName", fontSettings.critFontName)
 MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "critOutlineIndex", fontSettings.critOutlineIndex)
 MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "critFontSize", fontSettings.critFontSize)
 MSBTProfiles.SetOption("scrollAreas." .. scrollAreaKey, "critFontAlpha", fontSettings.critFontAlpha)
 
 MSBTAnimations.UpdateScrollAreas()
end


-- ****************************************************************************
-- Called when one of the font settings buttons is clicked.
-- ****************************************************************************
local function ScrollAreasTab_FontButtonOnClick(this)
 local saKey = this:GetParent().scrollAreaKey
 local saSettings = MSBTProfiles.currentProfile.scrollAreas[saKey]
 
 EraseTable(configTable)
 configTable.title = saSettings.name
 local fontName = MSBTProfiles.currentProfile.normalFontName
 if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
 configTable.inheritedNormalFontName = fontName
 configTable.inheritedNormalOutlineIndex = MSBTProfiles.currentProfile.normalOutlineIndex
 configTable.inheritedNormalFontSize = MSBTProfiles.currentProfile.normalFontSize
 configTable.inheritedNormalFontAlpha = MSBTProfiles.currentProfile.normalFontAlpha

 fontName = MSBTProfiles.currentProfile.critFontName
 if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
 configTable.inheritedCritFontName = fontName
 configTable.inheritedCritFontName = MSBTProfiles.currentProfile.critFontName
 configTable.inheritedCritOutlineIndex = MSBTProfiles.currentProfile.critOutlineIndex
 configTable.inheritedCritFontSize = MSBTProfiles.currentProfile.critFontSize
 configTable.inheritedCritFontAlpha = MSBTProfiles.currentProfile.critFontAlpha

 fontName = saSettings.normalFontName
 if (not fonts[fontName]) then fontName = nil end
 configTable.normalFontName = fontName
 configTable.normalOutlineIndex = saSettings.normalOutlineIndex
 configTable.normalFontSize = saSettings.normalFontSize
 configTable.normalFontAlpha = saSettings.normalFontAlpha

 fontName = saSettings.critFontName
 if (not fonts[fontName]) then fontName = nil end
 configTable.critFontName = fontName
 configTable.critOutlineIndex = saSettings.critOutlineIndex
 configTable.critFontSize = saSettings.critFontSize
 configTable.critFontAlpha = saSettings.critFontAlpha
 
 configTable.parentFrame = tabFrames.scrollAreas
 configTable.anchorFrame = tabFrames.scrollAreas
 configTable.anchorPoint = "BOTTOM"
 configTable.relativePoint = "BOTTOM"
 configTable.saveHandler = ScrollAreasTab_SaveFontSettings
 configTable.saveArg1 = saKey
 configTable.hideHandler = ScrollAreasTab_EnableControls
 DisableControls(tabFrames.scrollAreas.controls)
 MSBTPopups.ShowFont(configTable)
end


-- ****************************************************************************
-- Called by listbox to create a line for scroll areas.
-- ****************************************************************************
local function ScrollAreasTab_CreateLine(this)
 local controls = tabFrames.scrollAreas.controls
 
 local frame = CreateFrame("Button", nil, this)
 frame:EnableMouse(false)

 -- Enable checkbox.
 local checkbox = MSBTControls.CreateCheckbox(frame)
 local objLocale = L.CHECKBOXES["enableScrollArea"]
 checkbox:Configure(24, nil, objLocale.tooltip)
 checkbox:SetPoint("LEFT", frame, "LEFT", 5, 0)
 checkbox:SetClickHandler(ScrollAreasTab_EnableOnClick)
 frame.enableCheckbox = checkbox
 controls[#controls+1] = checkbox

 -- Delete scroll area button. 
 local button = MSBTControls.CreateIconButton(frame, "Delete")
 objLocale = L.BUTTONS["deleteScrollArea"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
 button:SetClickHandler(ScrollAreasTab_DeleteButtonOnClick)
 frame.deleteButton = button
 controls[#controls+1] = button

 -- Edit scroll area name button. 
 local button = MSBTControls.CreateIconButton(frame, "Configure")
 objLocale = L.BUTTONS["editScrollAreaName"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
 button:SetClickHandler(ScrollAreasTab_EditNameButtonOnClick)
 controls[#controls+1] = button

 
 -- Scroll area font settings button. 
 button = MSBTControls.CreateIconButton(frame, "FontSettings")
 objLocale = L.BUTTONS["scrollAreaFontSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
 button:SetClickHandler(ScrollAreasTab_FontButtonOnClick)
 controls[#controls+1] = button

 return frame
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function ScrollAreasTab_DisplayLine(this, line, key, isSelected)
 local saSettings = MSBTProfiles.currentProfile.scrollAreas[key]
 line.scrollAreaKey = key
 line.enableCheckbox:SetLabel(saSettings.name)
 line.enableCheckbox:SetChecked(not saSettings.disabled)
 
 -- Disable the delete button for the default scroll areas.
 if (MSBTProfiles.masterProfile.scrollAreas[key]) then
  line.deleteButton:Disable()
 else
  line.deleteButton:Enable()
 end
end


-- ****************************************************************************
-- Creates the scroll areas tab frame contents.
-- ****************************************************************************
local function ScrollAreasTab_Create()
 local tabFrame = tabFrames.scrollAreas
 tabFrame.controls = {}
 local controls = tabFrame.controls
 
 -- Horizontal bar.
 local texture = tabFrame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
 texture:SetHeight(4)
 texture:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -45)
 texture:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", 0, -45)
 texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)

 -- Add scroll area button.
 local button = MSBTControls.CreateOptionButton(tabFrame)
 local objLocale = L.BUTTONS["addScrollArea"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", texture, "TOPLEFT", 5, 15)
 button:SetClickHandler(
   function (this)
    objLocale = L.EDITBOXES["scrollAreaName"]
    EraseTable(configTable)
    configTable.defaultText = L.MSG_NEW_SCROLL_AREA
    configTable.editboxLabel = objLocale.label
    configTable.editboxTooltip = objLocale.tooltip
    configTable.parentFrame = tabFrames.scrollAreas
    configTable.anchorFrame = this
    configTable.validateHandler = ScrollAreasTab_ValidateScrollAreaName
    configTable.saveHandler = ScrollAreasTab_AddScrollArea
    configTable.hideHandler = ScrollAreasTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowInput(configTable)
   end
 )
 controls.addScrollAreaButton = button
 
 -- Configure scroll areas button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["configScrollAreas"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", texture, "TOPRIGHT", -5, 15)
 button:SetClickHandler(
   function (this)
	MSBTOptMain.HideMainFrame()
	MSBTPopups.ShowScrollAreaConfig()
   end
 )
 controls.configScrollAreasButton = button
 
 -- Scroll areas listbox. 
 local listbox = MSBTControls.CreateListbox(tabFrame)
 listbox:Configure(400, 300, 25)
 listbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -50)
 listbox:SetCreateLineHandler(ScrollAreasTab_CreateLine)
 listbox:SetDisplayHandler(ScrollAreasTab_DisplayLine)
 controls.scrollAreasListbox = listbox
 
 -- Reusable table for scroll areas.
 tabFrame.scrollAreasTable = {}

 tabFrame.created = true
end


-- ****************************************************************************
-- Called when the tab frame is shown.
-- ****************************************************************************
local function ScrollAreasTab_OnShow()
 if (not tabFrames.scrollAreas.created) then ScrollAreasTab_Create() end

 -- Set the frame up to populate the profile options when it is shown.
 local listbox = tabFrames.scrollAreas.controls.scrollAreasListbox

 local scrollAreasTable = tabFrames.scrollAreas.scrollAreasTable
 EraseTable(scrollAreasTable)
 for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
  scrollAreasTable[saKey] = saSettings.name
 end
 local sortedKeys = SortKeysByValue(scrollAreasTable)

 local previousOffset = listbox:GetOffset()
 listbox:Clear()
 for _, key in ipairs(sortedKeys) do
  listbox:AddItem(key)
 end
 listbox:SetOffset(previousOffset)
end


-------------------------------------------------------------------------------
-- Events tab functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Adds an event type to a category using the localized data and event codes.
-- ****************************************************************************
local function EventsTab_AddEvent(category, eventType, codes)
 -- Get the localized event data and ignore it if it isn't found.
 local event = L[category][eventType]
 if (not event) then return end
 
 -- Add the event to the ordered events table for the category and set it up
 -- with event codes.
 orderedEvents[category][#orderedEvents[category]+1] = event
 event.eventType = eventType
 event.codes = codes
end


-- ****************************************************************************
-- Sets up the event category entries with their associated event types and
-- codes.
-- ****************************************************************************
local function EventsTab_SetupEvents()
 -- Create tables to hold categorized events.
 for index, category in ipairs(EVENT_CATEGORY_MAP) do orderedEvents[category] = {} end

 local c = L.EVENT_CODES
 local category = "INCOMING_PLAYER_EVENTS"
 EventsTab_AddEvent(category, "INCOMING_DAMAGE", c.DAMAGE_TAKEN .. c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "INCOMING_DAMAGE_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "INCOMING_MISS", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "INCOMING_DODGE", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "INCOMING_PARRY", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "INCOMING_BLOCK", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "INCOMING_DEFLECT", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "INCOMING_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "INCOMING_IMMUNE", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "INCOMING_SPELL_DAMAGE", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "INCOMING_SPELL_DAMAGE_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "INCOMING_SPELL_DOT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "INCOMING_SPELL_DOT_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "INCOMING_SPELL_DAMAGE_SHIELD", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "INCOMING_SPELL_DAMAGE_SHIELD_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "INCOMING_SPELL_MISS", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_SPELL_DODGE", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_SPELL_PARRY", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_SPELL_BLOCK", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_SPELL_DEFLECT", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_SPELL_RESIST", c.ATTACKER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_SPELL_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_SPELL_IMMUNE", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_SPELL_REFLECT", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_SPELL_INTERRUPT", c.ATTACKER_NAME .. c.SPELL_NAME)
 EventsTab_AddEvent(category, "INCOMING_HEAL", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_HEAL_CRIT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_HOT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_HOT_CRIT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "INCOMING_ENVIRONMENTAL", c.DAMAGE_TAKEN .. c.ENVIRONMENTAL_DAMAGE)

 category = "INCOMING_PET_EVENTS"
 EventsTab_AddEvent(category, "PET_INCOMING_DAMAGE", c.DAMAGE_TAKEN .. c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "PET_INCOMING_DAMAGE_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "PET_INCOMING_MISS", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "PET_INCOMING_DODGE", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "PET_INCOMING_PARRY", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "PET_INCOMING_BLOCK", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "PET_INCOMING_DEFLECT", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "PET_INCOMING_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "PET_INCOMING_IMMUNE", c.ATTACKER_NAME)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DAMAGE", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DAMAGE_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DOT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DOT_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DAMAGE_SHIELD", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DAMAGE_SHIELD_CRIT", c.DAMAGE_TAKEN .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_TAKEN)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_MISS", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DODGE", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_PARRY", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_BLOCK", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_DEFLECT", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_RESIST", c.ATTACKER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_INCOMING_SPELL_IMMUNE", c.ATTACKER_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_INCOMING_HEAL", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_INCOMING_HEAL_CRIT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_INCOMING_HOT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_INCOMING_HOT_CRIT", c.HEALING_TAKEN .. c.HEALER_NAME .. c.SPELL_NAME .. c.SKILL_LONG)

 category = "OUTGOING_PLAYER_EVENTS"
 EventsTab_AddEvent(category, "OUTGOING_DAMAGE", c.DAMAGE_DONE .. c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "OUTGOING_DAMAGE_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "OUTGOING_MISS", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "OUTGOING_DODGE", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "OUTGOING_PARRY", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "OUTGOING_BLOCK", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "OUTGOING_DEFLECT", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "OUTGOING_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "OUTGOING_IMMUNE", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "OUTGOING_EVADE", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_DAMAGE", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_DAMAGE_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_DOT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_DOT_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_DAMAGE_SHIELD", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_DAMAGE_SHIELD_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_MISS", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_DODGE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_PARRY", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_BLOCK", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_DEFLECT", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_RESIST", c.ATTACKED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_IMMUNE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_REFLECT", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_INTERRUPT", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_SPELL_EVADE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_HEAL", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_HEAL_CRIT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_HOT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_HOT_CRIT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "OUTGOING_DISPEL", c.ATTACKED_NAME .. c.BUFF_NAME .. c.SKILL_LONG)
 
 category = "OUTGOING_PET_EVENTS"
 EventsTab_AddEvent(category, "PET_OUTGOING_DAMAGE", c.DAMAGE_DONE .. c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "PET_OUTGOING_DAMAGE_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "PET_OUTGOING_MISS", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "PET_OUTGOING_DODGE", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "PET_OUTGOING_PARRY", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "PET_OUTGOING_BLOCK", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "PET_OUTGOING_DEFLECT", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "PET_OUTGOING_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "PET_OUTGOING_IMMUNE", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "PET_OUTGOING_EVADE", c.ATTACKED_NAME)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DAMAGE", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DAMAGE_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DOT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DOT_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DAMAGE_SHIELD", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DAMAGE_SHIELD_CRIT", c.DAMAGE_DONE .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG .. c.DAMAGE_TYPE_DONE)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_MISS", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DODGE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_PARRY", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_BLOCK", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_DEFLECT", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_RESIST", c.ATTACKED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_ABSORB", c.ABSORBED_AMOUNT .. c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_IMMUNE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_SPELL_EVADE", c.ATTACKED_NAME .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_HEAL", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_HEAL_CRIT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_HOT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_HOT_CRIT", c.HEALING_DONE .. c.HEALED_NAME .. c.SPELL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "PET_OUTGOING_DISPEL", c.BUFF_NAME .. c.SKILL_LONG)
 
 category = "NOTIFICATION_EVENTS"
 EventsTab_AddEvent(category, "NOTIFICATION_DEBUFF", c.DEBUFF_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_DEBUFF_STACK", c.AURA_AMOUNT .. c.DEBUFF_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_BUFF", c.BUFF_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_BUFF_STACK", c.AURA_AMOUNT .. c.BUFF_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_ITEM_BUFF", c.ITEM_BUFF_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_DEBUFF_FADE", c.DEBUFF_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_BUFF_FADE", c.BUFF_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_ITEM_BUFF_FADE", c.ITEM_BUFF_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_COMBAT_ENTER", "")
 EventsTab_AddEvent(category, "NOTIFICATION_COMBAT_LEAVE", "")
 EventsTab_AddEvent(category, "NOTIFICATION_POWER_GAIN", c.ENERGY_AMOUNT .. c.POWER_TYPE .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_POWER_LOSS", c.ENERGY_AMOUNT .. c.POWER_TYPE .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_ALT_POWER_GAIN", c.ENERGY_AMOUNT .. c.POWER_TYPE .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_ALT_POWER_LOSS", c.ENERGY_AMOUNT .. c.POWER_TYPE .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_CHI_CHANGE", c.CHI_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_CHI_FULL", c.CHI_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_CP_GAIN", c.CP_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_CP_FULL", c.CP_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_HOLY_POWER_CHANGE", c.HOLY_POWER_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_HOLY_POWER_FULL", c.HOLY_POWER_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_SHADOW_ORBS_CHANGE", c.SHADOW_ORBS_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_SHADOW_ORBS_FULL", c.SHADOW_ORBS_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_HONOR_GAIN", c.HONOR_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_REP_GAIN", c.REP_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_REP_LOSS", c.REP_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_SKILL_GAIN", c.SKILL_AMOUNT .. c.SKILL_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_EXPERIENCE_GAIN", c.EXPERIENCE_AMOUNT)
 EventsTab_AddEvent(category, "NOTIFICATION_PC_KILLING_BLOW", c.UNIT_KILLED)
 EventsTab_AddEvent(category, "NOTIFICATION_NPC_KILLING_BLOW", c.UNIT_KILLED)
 EventsTab_AddEvent(category, "NOTIFICATION_EXTRA_ATTACK", c.EXTRA_ATTACKS .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_ENEMY_BUFF", c.BUFFED_NAME .. c.BUFF_NAME .. c.SKILL_LONG)
 EventsTab_AddEvent(category, "NOTIFICATION_MONSTER_EMOTE", c.EMOTE_TEXT)
end


-- ****************************************************************************
-- Changes the event category to the passed value.
-- ****************************************************************************
local function EventsTab_ChangeEventCategory(category)
 local controls = tabFrames.events.controls
 
 controls.eventsListbox:Clear()
 for index in ipairs(orderedEvents[category]) do
  controls.eventsListbox:AddItem(index)
 end
end


-- ****************************************************************************
-- Enables the controls on the events tab.
-- ****************************************************************************
local function EventsTab_EnableControls()
 for name, frame in pairs(tabFrames.events.controls) do
  if (frame.Enable) then frame:Enable() end
 end
end


-- ****************************************************************************
-- Moves all the events in the selected category to the passed scroll area.
-- ****************************************************************************
local function EventsTab_MoveAll(scrollArea)
 local events = orderedEvents[tabFrames.events.controls.eventCategoryDropdown:GetSelectedID()]
 for index, eventData in ipairs(events) do
  MSBTProfiles.SetOption("events." .. eventData.eventType, "scrollArea", scrollArea)
 end
end


-- ****************************************************************************
-- Called when one of the event color swatches is changed.
-- ****************************************************************************
local function EventsTab_ColorswatchOnChanged(this)
 local eventType = this:GetParent().eventType
 MSBTProfiles.SetOption("events." .. eventType, "colorR", this.r, 1)
 MSBTProfiles.SetOption("events." .. eventType, "colorG", this.g, 1)
 MSBTProfiles.SetOption("events." .. eventType, "colorB", this.b, 1)
end


-- ****************************************************************************
-- Called when one of the event enable checkboxes is clicked.
-- ****************************************************************************
local function EventsTab_EnableOnClick(this, isChecked)
 local eventType = this:GetParent().eventType
 MSBTProfiles.SetOption("events." .. eventType, "disabled", not isChecked) 
end


-- ****************************************************************************
-- Saves the additional event settings selected by the user.
-- ****************************************************************************
local function EventsTab_SaveEventSettings(settings, eventType)
 MSBTProfiles.SetOption("events." .. eventType, "scrollArea", settings.scrollArea, DEFAULT_SCROLL_AREA)
 MSBTProfiles.SetOption("events." .. eventType, "message", settings.message)
 MSBTProfiles.SetOption("events." .. eventType, "alwaysSticky", settings.alwaysSticky)
 MSBTProfiles.SetOption("events." .. eventType, "soundFile", settings.soundFile, "")
 
 tabFrames.events.controls.eventsListbox:Refresh()
end


-- ****************************************************************************
-- Called when one of the event settings buttons is clicked.
-- ****************************************************************************
local function EventsTab_SettingsButtonOnClick(this)
 local eventType = this:GetParent().eventType
 local eventSettings = MSBTProfiles.currentProfile.events[eventType]
 local categoryText = tabFrames.events.controls.eventCategoryDropdown:GetSelectedText()
 
 EraseTable(configTable)
 configTable.title =  categoryText .. " - " .. this:GetParent().enableCheckbox.fontString:GetText()
 configTable.message = eventSettings.message
 configTable.codes = this:GetParent().codes
 configTable.scrollArea = eventSettings.scrollArea or DEFAULT_SCROLL_AREA
 configTable.alwaysSticky = eventSettings.alwaysSticky
 configTable.soundFile = eventSettings.soundFile
 configTable.isCrit = eventSettings.isCrit
 configTable.parentFrame = tabFrames.events
 configTable.anchorFrame = tabFrames.events
 configTable.anchorPoint = "TOPRIGHT"
 configTable.relativePoint = "TOPRIGHT"
 configTable.saveHandler = EventsTab_SaveEventSettings
 configTable.saveArg1 = eventType
 configTable.hideHandler = EventsTab_EnableControls
 DisableControls(tabFrames.events.controls)
 MSBTPopups.ShowEvent(configTable)
end


-- ****************************************************************************
-- Saves the font settings selected by the user.
-- ****************************************************************************
local function EventsTab_SaveFontSettings(settings, eventType)
 local isCrit = MSBTProfiles.currentProfile.events[eventType].isCrit
 MSBTProfiles.SetOption("events." .. eventType, "fontName", isCrit and settings.critFontName or settings.normalFontName)
 MSBTProfiles.SetOption("events." .. eventType, "outlineIndex", isCrit and settings.critOutlineIndex or settings.normalOutlineIndex)
 MSBTProfiles.SetOption("events." .. eventType, "fontSize", isCrit and settings.critFontSize or settings.normalFontSize)
 MSBTProfiles.SetOption("events." .. eventType, "fontAlpha", isCrit and settings.critFontAlpha or settings.normalFontAlpha) 
end


-- ****************************************************************************
-- Called when one of the font settings buttons is clicked.
-- ****************************************************************************
local function EventsTab_FontButtonOnClick(this)
 local categoryText = tabFrames.events.controls.eventCategoryDropdown:GetSelectedText()
 local eventType = this:GetParent().eventType
 local eventSettings = MSBTProfiles.currentProfile.events[eventType]

 local saKey = eventSettings.scrollArea
 local saSettings = MSBTProfiles.currentProfile.scrollAreas[saKey]
 if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end
 
 EraseTable(configTable)
 configTable.title = categoryText .. " - " .. this:GetParent().enableCheckbox.fontString:GetText()
 
 local fontName
 if (not eventSettings.isCrit) then
  -- Inherit from the correct scroll area.
  fontName = saSettings.normalFontName
  if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
  if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
  configTable.inheritedNormalFontName = fontName
  configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
  configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
  configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

  fontName = eventSettings.fontName
  if (not fonts[fontName]) then fontName = nil end
  configTable.normalFontName = fontName
  configTable.normalOutlineIndex = eventSettings.outlineIndex
  configTable.normalFontSize = eventSettings.fontSize
  configTable.normalFontAlpha = eventSettings.fontAlpha

  configTable.hideCrit = true
 else
  -- Inherit from the correct scroll area.
  fontName = saSettings.critFontName
  if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.critFontName end
  if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
  configTable.inheritedCritFontName = fontName
  configTable.inheritedCritOutlineIndex = saSettings.critOutlineIndex or MSBTProfiles.currentProfile.critOutlineIndex
  configTable.inheritedCritFontSize = saSettings.critFontSize or MSBTProfiles.currentProfile.critFontSize
  configTable.inheritedCritFontAlpha = saSettings.critFontAlpha or MSBTProfiles.currentProfile.critFontAlpha

  fontName = eventSettings.fontName
  if (not fonts[fontName]) then fontName = nil end
  configTable.critFontName = fontName
  configTable.critOutlineIndex = eventSettings.outlineIndex
  configTable.critFontSize = eventSettings.fontSize
  configTable.critFontAlpha = eventSettings.fontAlpha

  configTable.hideNormal = true
 end

 configTable.parentFrame = tabFrames.events
 configTable.anchorFrame = tabFrames.events
 configTable.anchorPoint = "BOTTOM"
 configTable.relativePoint = "BOTTOM"
 configTable.saveHandler = EventsTab_SaveFontSettings
 configTable.saveArg1 = eventType
 configTable.hideHandler = EventsTab_EnableControls
 DisableControls(tabFrames.events.controls)
 MSBTPopups.ShowFont(configTable)
end


-- ****************************************************************************
-- Called by listbox to create a line for events.
-- ****************************************************************************
local function EventsTab_CreateLine(this)
 local controls = tabFrames.events.controls
 
 local frame = CreateFrame("Button", nil, this)
 frame:EnableMouse(false)
 
 -- Event colorswatch.
 local colorswatch = MSBTControls.CreateColorswatch(frame)
 colorswatch:SetPoint("LEFT", frame, "LEFT", 5, 0)
 colorswatch:SetColorChangedHandler(EventsTab_ColorswatchOnChanged)
 frame.colorSwatch = colorswatch
 controls[#controls+1] = colorswatch

 -- Enable checkbox.
 local checkbox = MSBTControls.CreateCheckbox(frame)
 checkbox:Configure(24, nil, nil)
 checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
 checkbox:SetPoint("RIGHT", frame, "LEFT", 190, 0)
 checkbox:SetClickHandler(EventsTab_EnableOnClick)
 frame.enableCheckbox = checkbox
 controls[#controls+1] = checkbox
 
 -- Event settings button. 
 local button = MSBTControls.CreateIconButton(frame, "Configure")
 local objLocale = L.BUTTONS["eventSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
 button:SetClickHandler(EventsTab_SettingsButtonOnClick)
 controls[#controls+1] = button

 -- Event font settings button. 
 button = MSBTControls.CreateIconButton(frame, "FontSettings")
 objLocale = L.BUTTONS["eventFontSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
 button:SetClickHandler(EventsTab_FontButtonOnClick)
 controls[#controls+1] = button

 -- Message font string.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
 fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 frame.messageFontString = fontString


 return frame
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function EventsTab_DisplayLine(this, line, key, isSelected)
 local events = orderedEvents[tabFrames.events.controls.eventCategoryDropdown:GetSelectedID()]
 local eventType = events[key].eventType
 local eventSettings = MSBTProfiles.currentProfile.events[eventType]
 local objLocale = events[key]
 line.eventType = eventType
 line.codes = events[key].codes

 line.colorSwatch:SetColor(eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1)
 line.enableCheckbox:SetLabel(objLocale.label)
 line.enableCheckbox:SetTooltip(objLocale.tooltip)
 line.enableCheckbox:SetChecked(not eventSettings.disabled)
 line.messageFontString:SetText(eventSettings.message)
end


-- ****************************************************************************
-- Creates the scroll areas tab frame contents.
-- ****************************************************************************
local function EventsTab_Create()
 local tabFrame = tabFrames.events
 tabFrame.controls = {}
 local controls = tabFrame.controls
 
 -- Horizontal bar.
 local texture = tabFrame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
 texture:SetHeight(4)
 texture:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -45)
 texture:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", 0, -45)
 texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)

 -- Move all button.
 local button = MSBTControls.CreateOptionButton(tabFrame)
 local objLocale = L.BUTTONS["moveAll"]
 button:Configure(15, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", texture, "TOPLEFT", 5, 5)
 button:SetClickHandler(
  function (this)
   EraseTable(configTable)
   configTable.title = this:GetText() .. " - " .. controls.eventCategoryDropdown:GetSelectedText()
   configTable.parentFrame = tabFrame
   configTable.anchorFrame = this
   configTable.saveHandler = EventsTab_MoveAll
   configTable.hideHandler = EventsTab_EnableControls
   DisableControls(controls)
   MSBTPopups.ShowScrollAreaSelection(configTable)
  end
 )
 controls.moveButton = button

 -- Toggle all button.
 local button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["toggleAll"]
 button:Configure(15, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", controls.moveButton, "TOPLEFT", 0, 10)
 button:SetClickHandler(
  function (this)
   local events = orderedEvents[controls.eventCategoryDropdown:GetSelectedID()]
   for index, eventData in ipairs(events) do
    MSBTProfiles.SetOption("events." .. eventData.eventType, "disabled", not MSBTProfiles.currentProfile.events[eventData.eventType].disabled)
    controls.eventsListbox:Refresh()
   end
  end
 )
 controls.toggleButton = button

 -- Event category dropdown.
 local dropdown = MSBTControls.CreateDropdown(tabFrame)
 objLocale = L.DROPDOWNS["eventCategory"]
 dropdown:Configure(180, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("BOTTOMRIGHT", texture, "TOPRIGHT", -5, 8)
 dropdown:SetChangeHandler(
   function (this, id)
    EventsTab_ChangeEventCategory(id)
   end
 )
 controls.eventCategoryDropdown = dropdown

 -- Events listbox. 
 local listbox = MSBTControls.CreateListbox(tabFrame)
 listbox:Configure(400, 300, 25)
 listbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -50)
 listbox:SetCreateLineHandler(EventsTab_CreateLine)
 listbox:SetDisplayHandler(EventsTab_DisplayLine)
 controls.eventsListbox = listbox


 -- Setup the events for all categories.
 EventsTab_SetupEvents()

 -- Populate the available event categories and select incoming player by default.
 for index, category in ipairs(L.EVENT_CATEGORIES) do
  dropdown:AddItem(category, EVENT_CATEGORY_MAP[index])
 end
 dropdown:SetSelectedID(EVENT_CATEGORY_MAP[1])
 EventsTab_ChangeEventCategory(EVENT_CATEGORY_MAP[1])
 
 tabFrame.created = true
end


-- ****************************************************************************
-- Called when the tab frame is shown.
-- ****************************************************************************
local function EventsTab_OnShow()
 if (not tabFrames.events.created) then EventsTab_Create() end

 -- Set the frame up to populate the profile options when it is shown.
 tabFrames.events.controls.eventsListbox:Refresh()
end


-------------------------------------------------------------------------------
-- Triggers tab functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Enables the controls on the triggers tab.
-- ****************************************************************************
local function TriggersTab_EnableControls()
 for name, frame in pairs(tabFrames.triggers.controls) do
  if (frame.Enable) then frame:Enable() end
 end
end


-- ****************************************************************************
-- Saves the trigger settings selected by the user.
-- ****************************************************************************
local function TriggersTab_SaveTriggerSettings(settings, triggerKey)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "classes", settings.classes)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "mainEvents", settings.mainEvents)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "exceptions", settings.exceptions)
 MSBTTriggers.UpdateTriggers()
end


-- ****************************************************************************
-- Adds a new trigger with the passed output message.
-- ****************************************************************************
local function TriggersTab_AddTrigger(settings)
 local nextAvailable = 1
 while (MSBTProfiles.currentProfile.triggers["Custom" .. nextAvailable]) do
  nextAvailable = nextAvailable + 1
 end
 
 local newKey = "Custom" .. nextAvailable
 local triggerSettings = {}
 triggerSettings.message = settings.inputText
 triggerSettings.alwaysSticky = true
 triggerSettings.fontSize = 26
 MSBTProfiles.SetOption("triggers", newKey, triggerSettings)
 MSBTTriggers.UpdateTriggers()
 tabFrames.triggers.controls.triggersListbox:AddItem(newKey, true)
 
 -- Launch the trigger settings dialog for the new trigger.
 EraseTable(configTable)
 configTable.title =  settings.inputText
 configTable.triggerKey = newKey
 configTable.parentFrame = tabFrames.triggers
 configTable.anchorFrame = tabFrames.triggers
 configTable.anchorPoint = "RIGHT"
 configTable.relativePoint = "RIGHT"
 configTable.saveHandler = TriggersTab_SaveTriggerSettings
 configTable.saveArg1 = newKey
 configTable.hideHandler = TriggersTab_EnableControls
 DisableControls(tabFrames.triggers.controls)
 MSBTPopups.ShowTrigger(configTable)
end


-- ****************************************************************************
-- Called when one of the trigger color swatches is changed.
-- ****************************************************************************
local function TriggersTab_ColorswatchOnChanged(this)
 local triggerKey = this:GetParent().triggerKey
 MSBTProfiles.SetOption("triggers." .. triggerKey, "colorR", this.r, 1)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "colorG", this.g, 1)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "colorB", this.b, 1)
 MSBTTriggers.UpdateTriggers()
end


-- ****************************************************************************
-- Called when one of the trigger enable checkboxes is clicked.
-- ****************************************************************************
local function TriggersTab_EnableOnClick(this, isChecked)
 local triggerKey = this:GetParent().triggerKey
 MSBTProfiles.SetOption("triggers." .. triggerKey, "disabled", not isChecked) 
 MSBTTriggers.UpdateTriggers()
end


-- ****************************************************************************
-- Called when one of the trigger settings buttons is clicked.
-- ****************************************************************************
local function TriggersTab_TriggerSettingsButtonOnClick(this)
 local triggerKey = this:GetParent().triggerKey
 local triggerSettings = MSBTProfiles.currentProfile.triggers[triggerKey]
 
 EraseTable(configTable)
 configTable.title =  this:GetParent().enableCheckbox.fontString:GetText()
 configTable.triggerKey = triggerKey
 configTable.parentFrame = tabFrames.triggers
 configTable.anchorFrame = tabFrames.triggers
 configTable.anchorPoint = "RIGHT"
 configTable.relativePoint = "RIGHT"
 configTable.saveHandler = TriggersTab_SaveTriggerSettings
 configTable.saveArg1 = triggerKey
 configTable.hideHandler = TriggersTab_EnableControls
 DisableControls(tabFrames.triggers.controls)
 MSBTPopups.ShowTrigger(configTable)
end


-- ****************************************************************************
-- Saves the font settings selected by the user.
-- ****************************************************************************
local function TriggersTab_SaveFontSettings(settings, triggerKey)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "fontName", settings.normalFontName)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "outlineIndex", settings.normalOutlineIndex)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "fontSize", settings.normalFontSize)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "fontAlpha", settings.normalFontAlpha) 
 MSBTTriggers.UpdateTriggers()
end


-- ****************************************************************************
-- Called when one of the font settings buttons is clicked.
-- ****************************************************************************
local function TriggersTab_FontButtonOnClick(this)
 local triggerKey = this:GetParent().triggerKey
 local triggerSettings = MSBTProfiles.currentProfile.triggers[triggerKey]

 local saKey = triggerSettings.scrollArea
 local saSettings = MSBTProfiles.currentProfile.scrollAreas[saKey]
 if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end
 
 EraseTable(configTable)
 configTable.title = this:GetParent().enableCheckbox.fontString:GetText()
 
 local fontName
 fontName = saSettings.normalFontName
 if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
 if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
 configTable.inheritedNormalFontName = fontName
 configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
 configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
 configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

 fontName = triggerSettings.fontName
 if (not fonts[fontName]) then fontName = nil end
 configTable.normalFontName = fontName
 configTable.normalOutlineIndex = triggerSettings.outlineIndex
 configTable.normalFontSize = triggerSettings.fontSize
 configTable.normalFontAlpha = triggerSettings.fontAlpha
 
 configTable.hideCrit = true

 
 configTable.parentFrame = tabFrames.triggers
 configTable.anchorFrame = tabFrames.triggers
 configTable.anchorPoint = "BOTTOM"
 configTable.relativePoint = "BOTTOM"
 configTable.saveHandler = TriggersTab_SaveFontSettings
 configTable.saveArg1 = triggerKey
 configTable.hideHandler = TriggersTab_EnableControls
 DisableControls(tabFrames.triggers.controls)
 MSBTPopups.ShowFont(configTable)
end


-- ****************************************************************************
-- Saves the additional event settings selected by the user.
-- ****************************************************************************
local function TriggersTab_SaveEventSettings(settings, triggerKey)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "scrollArea", settings.scrollArea, DEFAULT_SCROLL_AREA)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "message", settings.message)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "alwaysSticky", settings.alwaysSticky)
 MSBTProfiles.SetOption("triggers." .. triggerKey, "soundFile", settings.soundFile, "")
 MSBTProfiles.SetOption("triggers." .. triggerKey, "iconSkill", settings.iconSkill, "")
 MSBTTriggers.UpdateTriggers()

 tabFrames.triggers.controls.triggersListbox:Refresh()
end


-- ****************************************************************************
-- Called when one of the event settings buttons is clicked.
-- ****************************************************************************
local function TriggersTab_EventSettingsButtonOnClick(this)
 local triggerKey = this:GetParent().triggerKey
 local triggerSettings = MSBTProfiles.currentProfile.triggers[triggerKey]
 
 EraseTable(configTable)
 configTable.title =  this:GetParent().enableCheckbox.fontString:GetText()
 configTable.message = triggerSettings.message
 configTable.scrollArea = triggerSettings.scrollArea or DEFAULT_SCROLL_AREA
 configTable.alwaysSticky = triggerSettings.alwaysSticky
 configTable.soundFile = triggerSettings.soundFile
 configTable.showIconSkillEditbox = true
 configTable.iconSkill = triggerSettings.iconSkill
 configTable.parentFrame = tabFrames.triggers
 configTable.anchorFrame = tabFrames.triggers
 configTable.anchorPoint = "TOPRIGHT"
 configTable.relativePoint = "TOPRIGHT"
 configTable.saveHandler = TriggersTab_SaveEventSettings
 configTable.saveArg1 = triggerKey
 configTable.hideHandler = TriggersTab_EnableControls
 DisableControls(tabFrames.triggers.controls)
 MSBTPopups.ShowEvent(configTable)
end


-- ****************************************************************************
-- Deletes the trigger for the passed line and removes the line.
-- ****************************************************************************
local function TriggersTab_DeleteTrigger(line)
 MSBTProfiles.SetOption("triggers", line.triggerKey, false)
 tabFrames.triggers.controls.triggersListbox:RemoveItem(line.itemNumber)
 MSBTTriggers.UpdateTriggers()
end


-- ****************************************************************************
-- Called when one of the delete buttons is clicked.
-- ****************************************************************************
local function TriggersTab_DeleteButtonOnClick(this)
 EraseTable(configTable)
 configTable.parentFrame = tabFrames.triggers
 configTable.anchorFrame = this
 configTable.anchorPoint = this:GetParent().lineNumber > 5 and "BOTTOMRIGHT" or "TOPRIGHT"
 configTable.relativePoint = this:GetParent().lineNumber > 5 and "TOPRIGHT" or "BOTTOMRIGHT"
 configTable.acknowledgeHandler = TriggersTab_DeleteTrigger
 configTable.saveArg1 = this:GetParent()
 configTable.hideHandler = TriggersTab_EnableControls
 DisableControls(tabFrames.triggers.controls)
 MSBTPopups.ShowAcknowledge(configTable)
end


-- ****************************************************************************
-- Called by listbox to create a line for triggers.
-- ****************************************************************************
local function TriggersTab_CreateLine(this)
 local controls = tabFrames.triggers.controls
 
 local frame = CreateFrame("Button", nil, this)
 frame:EnableMouse(false)
 
 -- Event colorswatch.
 local colorswatch = MSBTControls.CreateColorswatch(frame)
 colorswatch:SetPoint("LEFT", frame, "LEFT", 5, 0)
 colorswatch:SetColorChangedHandler(TriggersTab_ColorswatchOnChanged)
 frame.colorSwatch = colorswatch
 controls[#controls+1] = colorswatch

 -- Enable checkbox.
 local checkbox = MSBTControls.CreateCheckbox(frame)
 local objLocale = L.CHECKBOXES["enableTrigger"]
 checkbox:Configure(24, nil, objLocale.tooltip)
 checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
 checkbox:SetPoint("RIGHT", frame, "LEFT", 190, 0)
 checkbox:SetClickHandler(TriggersTab_EnableOnClick)
 frame.enableCheckbox = checkbox
 controls[#controls+1] = checkbox
 
 -- Delete trigger button. 
 local button = MSBTControls.CreateIconButton(frame, "Delete")
 objLocale = L.BUTTONS["deleteTrigger"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
 button:SetClickHandler(TriggersTab_DeleteButtonOnClick)
 controls[#controls+1] = button

 -- Event settings button. 
 button = MSBTControls.CreateIconButton(frame, "Configure")
 objLocale = L.BUTTONS["eventSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
 button:SetClickHandler(TriggersTab_EventSettingsButtonOnClick)
 controls[#controls+1] = button

 -- Event font settings button. 
 button = MSBTControls.CreateIconButton(frame, "FontSettings")
 objLocale = L.BUTTONS["eventFontSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
 button:SetClickHandler(TriggersTab_FontButtonOnClick)
 controls[#controls+1] = button

 -- Trigger settings button. 
 button = MSBTControls.CreateIconButton(frame, "TriggerSettings")
 objLocale = L.BUTTONS["triggerSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
 button:SetClickHandler(TriggersTab_TriggerSettingsButtonOnClick)
 controls[#controls+1] = button

 return frame
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function TriggersTab_DisplayLine(this, line, key, isSelected)
 local triggerSettings = MSBTProfiles.currentProfile.triggers[key]
 line.triggerKey = key

 line.colorSwatch:SetColor(triggerSettings.colorR or 1, triggerSettings.colorG or 1, triggerSettings.colorB or 1)
 line.enableCheckbox:SetLabel(triggerSettings.message)
 line.enableCheckbox:SetChecked(not triggerSettings.disabled)
end


-- ****************************************************************************
-- Creates the triggers tab frame contents.
-- ****************************************************************************
local function TriggersTab_Create()
 local tabFrame = tabFrames.triggers
 tabFrame.controls = {}
 local controls = tabFrame.controls

 -- Horizontal bar.
 local texture = tabFrame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
 texture:SetHeight(4)
 texture:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -45)
 texture:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", 0, -45)
 texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)

 -- Add trigger button.
 local button = MSBTControls.CreateOptionButton(tabFrame)
 local objLocale = L.BUTTONS["addTrigger"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", texture, "TOPLEFT", 5, 15)
 button:SetClickHandler(
   function (this)
    objLocale = L.EDITBOXES["eventMessage"]
    EraseTable(configTable)
    configTable.defaultText = L.MSG_NEW_TRIGGER
    configTable.editboxLabel = objLocale.label
    configTable.editboxTooltip = objLocale.tooltip
    configTable.parentFrame = tabFrames.triggers
    configTable.anchorFrame = this
    configTable.saveHandler = TriggersTab_AddTrigger
    configTable.hideHandler = TriggersTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowInput(configTable)
   end
 )
 controls.addTriggerButton = button

 
 -- Triggers listbox. 
 local listbox = MSBTControls.CreateListbox(tabFrame)
 listbox:Configure(400, 300, 25)
 listbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 0, -50)
 listbox:SetCreateLineHandler(TriggersTab_CreateLine)
 listbox:SetDisplayHandler(TriggersTab_DisplayLine)
 controls.triggersListbox = listbox
 
 -- Reusable table for triggers.
 tabFrame.triggerTable = {}
  
 tabFrame.created = true
end


-- ****************************************************************************
-- Called when the tab frame is shown.
-- ****************************************************************************
local function TriggersTab_OnShow()
 if (not tabFrames.triggers.created) then TriggersTab_Create() end

 -- Set the frame up to populate the profile options when it is shown.
 local triggersListbox = tabFrames.triggers.controls.triggersListbox

 -- Get triggers from the current profile.
 local triggerTable = tabFrames.triggers.triggerTable
 EraseTable(triggerTable)
 local currentProfileTriggers = rawget(MSBTProfiles.currentProfile, "triggers")
 if (currentProfileTriggers) then
  for triggerKey, triggerSettings in pairs(currentProfileTriggers) do
   if (triggerSettings) then triggerTable[triggerKey] = triggerSettings.message end
  end
 end
 
 -- Get triggers available in the master profile that aren't in the current profile. 
 for triggerKey, triggerSettings in pairs(MSBTProfiles.masterProfile.triggers) do
  if (not currentProfileTriggers or rawget(currentProfileTriggers, triggerKey) == nil) then
   triggerTable[triggerKey] = triggerSettings.message
  end
 end
 
 -- Set the frame up to populate the profile options when it is shown.
 local listbox = tabFrames.triggers.controls.triggersListbox
 local sortedKeys = SortKeysByValue(triggerTable)
 
 local previousOffset = listbox:GetOffset()
 listbox:Clear()
 for _, key in ipairs(sortedKeys) do
  listbox:AddItem(key)
 end
 listbox:SetOffset(previousOffset)
end


-------------------------------------------------------------------------------
-- Spam tab functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Enables the controls on the spam tab.
-- ****************************************************************************
local function SpamTab_EnableControls()
 local controls = tabFrames.spam.controls
 for name, frame in pairs(controls) do
  if (frame.Enable) then frame:Enable() end
 end
end


-- ****************************************************************************
-- Creates the spam tab frame contents.
-- ****************************************************************************
local function SpamTab_Create()
 local tabFrame = tabFrames.spam
 tabFrame.controls = {}
 local controls = tabFrame.controls

 -- Heal threshold slider.
 local slider = MSBTControls.CreateSlider(tabFrame)
 local objLocale = L.SLIDERS["healThreshold"]
 slider:Configure(150, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -10)
 slider:SetMinMaxValues(0, 100000)
 slider:SetValueStep(100)
 slider:SetValueChangedHandler(
   function(this, value)
    MSBTProfiles.SetOption(nil, "healThreshold", value)
   end
 )
 controls.healSlider = slider

 -- Damage threshold slider.
 slider = MSBTControls.CreateSlider(tabFrame)
 objLocale = L.SLIDERS["damageThreshold"]
 slider:Configure(150, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", controls.healSlider, "BOTTOMLEFT", 0, -10)
 slider:SetMinMaxValues(0, 100000)
 slider:SetValueStep(100)
 slider:SetValueChangedHandler(
   function(this, value)
    MSBTProfiles.SetOption(nil, "damageThreshold", value)
   end
 )
 controls.damageSlider = slider

 -- Power threshold slider.
 slider = MSBTControls.CreateSlider(tabFrame)
 objLocale = L.SLIDERS["powerThreshold"]
 slider:Configure(150, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", controls.damageSlider, "BOTTOMLEFT", 0, -10)
 slider:SetMinMaxValues(0, 2000)
 slider:SetValueStep(40)
 slider:SetValueChangedHandler(
   function(this, value)
    MSBTProfiles.SetOption(nil, "powerThreshold", value)
   end
 )
 controls.powerSlider = slider

 -- HoT throttling time slider.
 slider = MSBTControls.CreateSlider(tabFrame)
 objLocale = L.SLIDERS["hotThrottleTime"]
 slider:Configure(150, objLocale.label, objLocale.tooltip)
 slider:SetPoint("LEFT", controls.healSlider, "RIGHT", 40, 0)
 slider:SetMinMaxValues(0, 5)
 slider:SetValueStep(1)
 slider:SetValueChangedHandler(
   function(this, value)
    MSBTProfiles.SetOption(nil, "hotThrottleDuration", value)
   end
 )
 controls.hotThrottlingSlider = slider

 -- DoT throttling time slider.
 slider = MSBTControls.CreateSlider(tabFrame)
 objLocale = L.SLIDERS["dotThrottleTime"]
 slider:Configure(150, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", controls.hotThrottlingSlider, "BOTTOMLEFT", 0, -10)
 slider:SetMinMaxValues(0, 5)
 slider:SetValueStep(1)
 slider:SetValueChangedHandler(
   function(this, value)
    MSBTProfiles.SetOption(nil, "dotThrottleDuration", value)
   end
 )
 controls.dotThrottlingSlider = slider

 -- Power throttling time slider.
 slider = MSBTControls.CreateSlider(tabFrame)
 objLocale = L.SLIDERS["powerThrottleTime"]
 slider:Configure(150, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", controls.dotThrottlingSlider, "BOTTOMLEFT", 0, -10)
 slider:SetMinMaxValues(0, 5)
 slider:SetValueStep(1)
 slider:SetValueChangedHandler(
   function(this, value)
    MSBTProfiles.SetOption(nil, "powerThrottleDuration", value)
   end
 )
 controls.powerThrottlingSlider = slider
 
 -- Hide skills checkbox.
 local checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["hideSkills"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -130)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "hideSkills", isChecked)
   end
 )
 controls.hideSkillsCheckbox = checkbox

 -- Hide names checkbox.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["hideNames"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.hideSkillsCheckbox, "BOTTOMLEFT")
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "hideNames", isChecked)
   end
 )
 controls.hideNamesCheckbox = checkbox
 
 -- Hide full overheals checkbox.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["hideFullOverheals"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.hideNamesCheckbox, "BOTTOMLEFT")
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "hideFullOverheals", isChecked)
   end
 )
 controls.hideFullOverhealsCheckbox = checkbox
 
 -- Hide full HoT overheals checkbox.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["hideFullHoTOverheals"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.hideFullOverhealsCheckbox, "BOTTOMLEFT")
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "hideFullHoTOverheals", isChecked)
   end
 )
 controls.hideFullHoTOverhealsCheckbox = checkbox

 -- Hide merge trailer checkbox.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["hideMergeTrailer"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.hideFullHoTOverhealsCheckbox, "BOTTOMLEFT")
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "hideMergeTrailer", isChecked)
   end
 )
 controls.hideMergeTrailerCheckbox = checkbox

 -- All power gains checkbox.
 local checkbox = MSBTControls.CreateCheckbox(tabFrame)
 local objLocale = L.CHECKBOXES["allPowerGains"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("LEFT", controls.powerThrottlingSlider, "LEFT", 0, 0)
 checkbox:SetPoint("TOP", controls.hideSkillsCheckbox, "TOP", 0, 0)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "showAllPowerGains", isChecked)
   end
 )
 controls.allPowerCheckbox = checkbox

 -- Abbreviate skills checkbox.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["abbreviateSkills"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.allPowerCheckbox, "BOTTOMLEFT", 0, 0)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "abbreviateAbilities", isChecked)
   end
 )
 controls.abbreviateCheckbox = checkbox

 -- Merge swings checkbox.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["mergeSwings"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.abbreviateCheckbox, "BOTTOMLEFT", 0, 0)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "mergeSwingsDisabled", not isChecked)
   end
 )
 controls.mergeSwingsCheckbox = checkbox

 -- Shorten numbers checkbox
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["shortenNumbers"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.mergeSwingsCheckbox, "BOTTOMLEFT", 0, 0)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "shortenNumbers", isChecked)
   end
 )
 controls.shortenNumbersCheckbox = checkbox

 -- Group numbers by thousands checkbox
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 objLocale = L.CHECKBOXES["groupNumbers"]
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.shortenNumbersCheckbox, "BOTTOMLEFT", 0, 0)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "groupNumbers", isChecked)
   end
 )
 controls.groupNumbersCheckbox = checkbox

 -- Merge exclusions button.
 local button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["mergeExclusions"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", tabFrame, "BOTTOMLEFT", 5, 15)
 button:SetClickHandler(
   function (this)
    local listName = "mergeExclusions"
    PopulateList(listName)
    EraseTable(configTable)
    configTable.title = this:GetText()
    configTable.skills = listTable
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = this
    configTable.anchorPoint = "BOTTOMLEFT"
    configTable.relativePoint = "TOPLEFT"
    configTable.saveHandler = SaveList
    configTable.saveArg1 = listName
    configTable.hideHandler = SpamTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowSkillList(configTable)
   end
 )
 controls.mergeExclusionsButton = button

 -- Throttle list button.
 local button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["throttleList"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", controls.mergeExclusionsButton, "TOPLEFT", 0, 10)
 button:SetClickHandler(
   function (this)
    local listName = "throttleList"
    PopulateList(listName)
    EraseTable(configTable)
    configTable.title = this:GetText()
    configTable.skills = listTable
    configTable.listType = "throttle"
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = this
    configTable.anchorPoint = "BOTTOMLEFT"
    configTable.relativePoint = "TOPLEFT"
    configTable.saveHandler = SaveList
    configTable.saveArg1 = listName
    configTable.hideHandler = SpamTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowSkillList(configTable)
   end
 )
 controls.throttleListButton = button

 -- Skill substitutions button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["skillSubstitutions"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", -10, 15)
 button:SetClickHandler(
   function (this)
    local listName = "abilitySubstitutions"
    PopulateList(listName)
    EraseTable(configTable)
    configTable.title = this:GetText()
    configTable.skills = listTable
    configTable.listType = "substitution"
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = this
    configTable.anchorPoint = "BOTTOMRIGHT"
    configTable.relativePoint = "TOPRIGHT"
    configTable.saveHandler = SaveList
    configTable.saveArg1 = listName
    configTable.hideHandler = SpamTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowSkillList(configTable)
   end
 )
 controls.skillSubstitutionsButton = button

 -- Skill suppressions button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["skillSuppressions"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", controls.skillSubstitutionsButton, "TOPLEFT", 0, 10)
 button:SetClickHandler(
   function (this)
    local listName = "abilitySuppressions"
    PopulateList(listName)
    EraseTable(configTable)
    configTable.title = this:GetText()
    configTable.skills = listTable
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = this
    configTable.anchorPoint = "BOTTOMRIGHT"
    configTable.relativePoint = "TOPRIGHT"
    configTable.saveHandler = SaveList
    configTable.saveArg1 = listName
    configTable.hideHandler = SpamTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowSkillList(configTable)
   end
 )
 controls.skillSuppressionsButton = button
 
 tabFrame.created = true
end


-- ****************************************************************************
-- Called when the tab frame is shown.
-- ****************************************************************************
local function SpamTab_OnShow()
 if (not tabFrames.spam.created) then SpamTab_Create() end

 local currentProfile = MSBTProfiles.currentProfile
 local controls = tabFrames.spam.controls

 controls.healSlider:SetValue(currentProfile.healThreshold)
 controls.damageSlider:SetValue(currentProfile.damageThreshold)
 controls.powerSlider:SetValue(currentProfile.powerThreshold)
 controls.dotThrottlingSlider:SetValue(currentProfile.dotThrottleDuration)
 controls.hotThrottlingSlider:SetValue(currentProfile.hotThrottleDuration)
 controls.powerThrottlingSlider:SetValue(currentProfile.powerThrottleDuration)
 controls.allPowerCheckbox:SetChecked(currentProfile.showAllPowerGains)
 controls.abbreviateCheckbox:SetChecked(currentProfile.abbreviateAbilities)
 controls.mergeSwingsCheckbox:SetChecked(not currentProfile.mergeSwingsDisabled)
 controls.shortenNumbersCheckbox:SetChecked(currentProfile.shortenNumbers)
 controls.groupNumbersCheckbox:SetChecked(currentProfile.groupNumbers)
 controls.hideSkillsCheckbox:SetChecked(currentProfile.hideSkills)
 controls.hideNamesCheckbox:SetChecked(currentProfile.hideNames)
 controls.hideFullOverhealsCheckbox:SetChecked(currentProfile.hideFullOverheals)
 controls.hideFullHoTOverhealsCheckbox:SetChecked(currentProfile.hideFullHoTOverheals)
 controls.hideMergeTrailerCheckbox:SetChecked(currentProfile.hideMergeTrailer)
end


-------------------------------------------------------------------------------
-- Cooldowns tab functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Enables the controls on the cooldowns tab.
-- ****************************************************************************
local function CooldownsTab_EnableControls()
 for name, frame in pairs(tabFrames.cooldowns.controls) do
  if (frame.Enable) then frame:Enable() end
 end
end


-- ****************************************************************************
-- Saves the event settings selected by the user.
-- ****************************************************************************
local function CooldownsTab_SaveEventSettings(settings, eventType)
 MSBTProfiles.SetOption("events." .. eventType, "scrollArea", settings.scrollArea, DEFAULT_SCROLL_AREA)
 MSBTProfiles.SetOption("events." .. eventType, "message", settings.message)
 MSBTProfiles.SetOption("events." .. eventType, "alwaysSticky", settings.alwaysSticky)
 MSBTProfiles.SetOption("events." .. eventType, "soundFile", settings.soundFile, "")

 local fontString = tabFrames.cooldowns.playerMessageFontString
 if (eventType == "NOTIFICATION_PET_COOLDOWN") then
  fontString = tabFrames.cooldowns.petMessageFontString
 elseif (eventType == "NOTIFICATION_ITEM_COOLDOWN") then
  fontString = tabFrames.cooldowns.itemMessageFontString
 end
 
 fontString:SetText(settings.message) 
end


-- ****************************************************************************
-- Saves the font settings selected by the user.
-- ****************************************************************************
local function CooldownsTab_SaveFontSettings(settings, eventType)
 MSBTProfiles.SetOption("events." .. eventType, "fontName", settings.normalFontName)
 MSBTProfiles.SetOption("events." .. eventType, "outlineIndex", settings.normalOutlineIndex)
 MSBTProfiles.SetOption("events." .. eventType, "fontSize", settings.normalFontSize)
 MSBTProfiles.SetOption("events." .. eventType, "fontAlpha", settings.normalFontAlpha) 
end


-- ****************************************************************************
-- Creates the cooldowns tab frame contents.
-- ****************************************************************************
local function CooldownsTab_Create()
 local tabFrame = tabFrames.cooldowns
 tabFrame.controls = {}
 local controls = tabFrame.controls

 -- Player cooldown colorswatch.
 local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
 colorswatch:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -10)
 colorswatch:SetColorChangedHandler(
   function (this)
    local eventType = "NOTIFICATION_COOLDOWN"
    MSBTProfiles.SetOption("events." .. eventType, "colorR", this.r, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorG", this.g, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorB", this.b, 1)
   end
 )
 controls.playerColorSwatch = colorswatch

 -- Player skill colorswatch.
 local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
 colorswatch:SetPoint("LEFT", controls.playerColorSwatch, "RIGHT", 5, 0)
 colorswatch:SetColorChangedHandler(
   function (this)
    local eventType = "NOTIFICATION_COOLDOWN"
    MSBTProfiles.SetOption("events." .. eventType, "skillColorR", this.r, 1)
    MSBTProfiles.SetOption("events." .. eventType, "skillColorG", this.g, 1)
    MSBTProfiles.SetOption("events." .. eventType, "skillColorB", this.b, 1)
   end
 )
 controls.playerSkillColorSwatch = colorswatch

 -- Player enable cooldown checkbox.
 local checkbox = MSBTControls.CreateCheckbox(tabFrame)
 local objLocale = L.CHECKBOXES["enablePlayerCooldowns"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
 checkbox:SetPoint("RIGHT", tabFrame, "TOPLEFT", 190, -10)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption("events.NOTIFICATION_COOLDOWN", "disabled", not isChecked)
    MSBTCooldowns.UpdateRegisteredEvents()
   end
 )
 controls.playerEnableCheckbox = checkbox
 
 -- Player cooldown event settings button. 
 local button = MSBTControls.CreateIconButton(tabFrame, "Configure")
 objLocale = L.BUTTONS["eventSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", -10, -5)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_COOLDOWN"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]
 
    EraseTable(configTable)
    configTable.title = L.CHECKBOXES["enablePlayerCooldowns"].label
    configTable.message = eventSettings.message
    configTable.codes = L.EVENT_CODES["COOLDOWN_NAME"]
    configTable.scrollArea = eventSettings.scrollArea or DEFAULT_SCROLL_AREA
    configTable.alwaysSticky = eventSettings.alwaysSticky
    configTable.soundFile = eventSettings.soundFile
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = tabFrame
    configTable.anchorPoint = "TOPRIGHT"
    configTable.relativePoint = "TOPRIGHT"
    configTable.saveArg1 = eventType
    configTable.saveHandler = CooldownsTab_SaveEventSettings
    configTable.hideHandler = CooldownsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowEvent(configTable)
   end
 )
 controls.playerEventSettingsButton = button

 -- Player cooldown font settings button. 
 local button = MSBTControls.CreateIconButton(tabFrame, "FontSettings")
 objLocale = L.BUTTONS["eventFontSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls.playerEventSettingsButton, "LEFT", 0, 0)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_COOLDOWN"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]
    local saSettings = MSBTProfiles.currentProfile.scrollAreas[eventSettings.scrollArea]
    if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end
 
    EraseTable(configTable)
    configTable.title = L.CHECKBOXES["enablePlayerCooldowns"].label
 
    -- Inherit from the correct scroll area.
    local fontName = saSettings.normalFontName
    if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
    if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
    configTable.inheritedNormalFontName = fontName
    configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
    configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
    configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

    fontName = eventSettings.fontName
    if (not fonts[fontName]) then fontName = nil end
    configTable.normalFontName = fontName
    configTable.normalOutlineIndex = eventSettings.outlineIndex
    configTable.normalFontSize = eventSettings.fontSize
    configTable.normalFontAlpha = eventSettings.fontAlpha

    configTable.hideCrit = true
    configTable.parentFrame = tabFrames.cooldowns
    configTable.anchorFrame = tabFrames.cooldowns
    configTable.anchorPoint = "BOTTOM"
    configTable.relativePoint = "BOTTOM"
    configTable.saveArg1 = eventType
    configTable.saveHandler = CooldownsTab_SaveFontSettings
    configTable.hideHandler = CooldownsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowFont(configTable)
   end
 )
 controls[#controls+1] = button

 -- Player message font string.
 local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
 fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 tabFrame.playerMessageFontString = fontString


 -- Pet cooldown Colorswatch.
 local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
 colorswatch:SetPoint("TOPLEFT", controls.playerColorSwatch, "BOTTOMLEFT", 0, -10)
 colorswatch:SetColorChangedHandler(
   function (this)
    local eventType = "NOTIFICATION_PET_COOLDOWN"
    MSBTProfiles.SetOption("events." .. eventType, "colorR", this.r, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorG", this.g, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorB", this.b, 1)
   end
 )
 controls.petColorSwatch = colorswatch

 -- Pet skill colorswatch.
 local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
 colorswatch:SetPoint("LEFT", controls.petColorSwatch, "RIGHT", 5, 0)
 colorswatch:SetColorChangedHandler(
   function (this)
    local eventType = "NOTIFICATION_PET_COOLDOWN"
    MSBTProfiles.SetOption("events." .. eventType, "skillColorR", this.r, 1)
    MSBTProfiles.SetOption("events." .. eventType, "skillColorG", this.g, 1)
    MSBTProfiles.SetOption("events." .. eventType, "skillColorB", this.b, 1)
   end
 )
 controls.petSkillColorSwatch = colorswatch

 -- Pet enable cooldown checkbox.
 local checkbox = MSBTControls.CreateCheckbox(tabFrame)
 local objLocale = L.CHECKBOXES["enablePetCooldowns"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
 checkbox:SetPoint("RIGHT", tabFrame, "TOPLEFT", 190, -10)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption("events.NOTIFICATION_PET_COOLDOWN", "disabled", not isChecked)
    MSBTCooldowns.UpdateRegisteredEvents()
   end
 )
 controls.petEnableCheckbox = checkbox

 -- Pet cooldown event settings button. 
 local button = MSBTControls.CreateIconButton(tabFrame, "Configure")
 objLocale = L.BUTTONS["eventSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("TOPRIGHT", controls.playerEventSettingsButton, "BOTTOMRIGHT", 0, -5)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_PET_COOLDOWN"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]
 
    EraseTable(configTable)
    configTable.title = L.CHECKBOXES["enablePetCooldowns"].label
    configTable.message = eventSettings.message
    configTable.codes = L.EVENT_CODES["COOLDOWN_NAME"]
    configTable.scrollArea = eventSettings.scrollArea or DEFAULT_SCROLL_AREA
    configTable.alwaysSticky = eventSettings.alwaysSticky
    configTable.soundFile = eventSettings.soundFile
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = tabFrame
    configTable.anchorPoint = "TOPRIGHT"
    configTable.relativePoint = "TOPRIGHT"
	configTable.saveArg1 = eventType
    configTable.saveHandler = CooldownsTab_SaveEventSettings
    configTable.hideHandler = CooldownsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowEvent(configTable)
   end
 )
 controls.petEventSettingsButton = button

 -- Pet cooldown font settings button. 
 local button = MSBTControls.CreateIconButton(tabFrame, "FontSettings")
 objLocale = L.BUTTONS["eventFontSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls.petEventSettingsButton, "LEFT", 0, 0)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_PET_COOLDOWN"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]
    local saSettings = MSBTProfiles.currentProfile.scrollAreas[eventSettings.scrollArea]
    if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end
 
    EraseTable(configTable)
    configTable.title = L.CHECKBOXES["enablePetCooldowns"].label
 
    -- Inherit from the correct scroll area.
    local fontName = saSettings.normalFontName
    if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
    if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
    configTable.inheritedNormalFontName = fontName
    configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
    configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
    configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

    fontName = eventSettings.fontName
    if (not fonts[fontName]) then fontName = nil end
    configTable.normalFontName = fontName
    configTable.normalOutlineIndex = eventSettings.outlineIndex
    configTable.normalFontSize = eventSettings.fontSize
    configTable.normalFontAlpha = eventSettings.fontAlpha

    configTable.hideCrit = true
    configTable.parentFrame = tabFrames.cooldowns
    configTable.anchorFrame = tabFrames.cooldowns
    configTable.anchorPoint = "BOTTOM"
    configTable.relativePoint = "BOTTOM"
	configTable.saveArg1 = eventType
    configTable.saveHandler = CooldownsTab_SaveFontSettings
    configTable.hideHandler = CooldownsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowFont(configTable)
   end
 )
 controls[#controls+1] = button

 -- Pet message font string.
 local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
 fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 tabFrame.petMessageFontString = fontString

 
 -- Item cooldown Colorswatch.
 local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
 colorswatch:SetPoint("TOPLEFT", controls.petColorSwatch, "BOTTOMLEFT", 0, -10)
 colorswatch:SetColorChangedHandler(
   function (this)
    local eventType = "NOTIFICATION_ITEM_COOLDOWN"
    MSBTProfiles.SetOption("events." .. eventType, "colorR", this.r, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorG", this.g, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorB", this.b, 1)
   end
 )
 controls.itemColorSwatch = colorswatch

 -- Item skill colorswatch.
 local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
 colorswatch:SetPoint("LEFT", controls.itemColorSwatch, "RIGHT", 5, 0)
 colorswatch:SetColorChangedHandler(
   function (this)
    local eventType = "NOTIFICATION_ITEM_COOLDOWN"
    MSBTProfiles.SetOption("events." .. eventType, "skillColorR", this.r, 1)
    MSBTProfiles.SetOption("events." .. eventType, "skillColorG", this.g, 1)
    MSBTProfiles.SetOption("events." .. eventType, "skillColorB", this.b, 1)
   end
 )
 controls.itemSkillColorSwatch = colorswatch

 -- Item enable cooldown checkbox.
 local checkbox = MSBTControls.CreateCheckbox(tabFrame)
 local objLocale = L.CHECKBOXES["enableItemCooldowns"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
 checkbox:SetPoint("RIGHT", tabFrame, "TOPLEFT", 190, -10)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption("events.NOTIFICATION_ITEM_COOLDOWN", "disabled", not isChecked)
    MSBTCooldowns.UpdateRegisteredEvents()
   end
 )
 controls.itemEnableCheckbox = checkbox

 -- Item cooldown event settings button. 
 local button = MSBTControls.CreateIconButton(tabFrame, "Configure")
 objLocale = L.BUTTONS["eventSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("TOPRIGHT", controls.petEventSettingsButton, "BOTTOMRIGHT", 0, -5)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_ITEM_COOLDOWN"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]
 
    EraseTable(configTable)
    configTable.title = L.CHECKBOXES["enableItemCooldowns"].label
    configTable.message = eventSettings.message
    configTable.codes = L.EVENT_CODES["ITEM_COOLDOWN_NAME"]
    configTable.scrollArea = eventSettings.scrollArea or DEFAULT_SCROLL_AREA
    configTable.alwaysSticky = eventSettings.alwaysSticky
    configTable.soundFile = eventSettings.soundFile
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = tabFrame
    configTable.anchorPoint = "TOPRIGHT"
    configTable.relativePoint = "TOPRIGHT"
	configTable.saveArg1 = eventType
    configTable.saveHandler = CooldownsTab_SaveEventSettings
    configTable.hideHandler = CooldownsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowEvent(configTable)
   end
 )
 controls[#controls+1] = button

 -- Item cooldown font settings button. 
 local button = MSBTControls.CreateIconButton(tabFrame, "FontSettings")
 objLocale = L.BUTTONS["eventFontSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls[#controls], "LEFT", 0, 0)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_ITEM_COOLDOWN"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]
    local saSettings = MSBTProfiles.currentProfile.scrollAreas[eventSettings.scrollArea]
    if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end
 
    EraseTable(configTable)
    configTable.title = L.CHECKBOXES["enableItemCooldowns"].label
 
    -- Inherit from the correct scroll area.
    local fontName = saSettings.normalFontName
    if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
    if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
    configTable.inheritedNormalFontName = fontName
    configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
    configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
    configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

    fontName = eventSettings.fontName
    if (not fonts[fontName]) then fontName = nil end
    configTable.normalFontName = fontName
    configTable.normalOutlineIndex = eventSettings.outlineIndex
    configTable.normalFontSize = eventSettings.fontSize
    configTable.normalFontAlpha = eventSettings.fontAlpha

    configTable.hideCrit = true
    configTable.parentFrame = tabFrames.cooldowns
    configTable.anchorFrame = tabFrames.cooldowns
    configTable.anchorPoint = "BOTTOM"
    configTable.relativePoint = "BOTTOM"
	configTable.saveArg1 = eventType
    configTable.saveHandler = CooldownsTab_SaveFontSettings
    configTable.hideHandler = CooldownsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowFont(configTable)
   end
 )
 controls[#controls+1] = button

 -- Item message font string.
 local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
 fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 tabFrame.itemMessageFontString = fontString

 
 -- Cooldown threshold slider.
 local slider = MSBTControls.CreateSlider(tabFrame)
 objLocale = L.SLIDERS["cooldownThreshold"] 
 slider:Configure(180, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", controls.itemColorSwatch, "BOTTOMLEFT", 0, -40)
 slider:SetMinMaxValues(3, 300)
 slider:SetValueStep(1)
 slider:SetValueChangedHandler(
   function(this, value)
     MSBTProfiles.SetOption(nil, "cooldownThreshold", value)
   end
 )
 controls.cooldownSlider = slider

 -- Cooldown exclusions button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["cooldownExclusions"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("TOPLEFT", controls.cooldownSlider, "BOTTOMLEFT", 0, -40)
 button:SetClickHandler(
   function (this)
    local listName = "cooldownExclusions"
    PopulateList(listName)
    EraseTable(configTable)
    configTable.title = this:GetText()
    configTable.skills = listTable
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = tabFrame
    configTable.anchorPoint = "TOPRIGHT"
    configTable.relativePoint = "TOPRIGHT"
    configTable.saveHandler = SaveList
    configTable.saveArg1 = listName
    configTable.hideHandler = CooldownsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowSkillList(configTable)
   end
 )
 controls.cooldownExclusions = button

 tabFrame.created = true
end


-- ****************************************************************************
-- Called when the tab frame is shown.
-- ****************************************************************************
local function CooldownsTab_OnShow()
 if (not tabFrames.cooldowns.created) then CooldownsTab_Create() end

 local tabFrame = tabFrames.cooldowns
 local controls = tabFrame.controls
 local currentProfile = MSBTProfiles.currentProfile

 local eventSettings = currentProfile.events["NOTIFICATION_COOLDOWN"]
 controls.playerColorSwatch:SetColor(eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1)
 controls.playerSkillColorSwatch:SetColor(eventSettings.skillColorR or 1, eventSettings.skillColorG or 1, eventSettings.skillColorB or 1)
 controls.playerEnableCheckbox:SetChecked(not eventSettings.disabled)
 tabFrame.playerMessageFontString:SetText(eventSettings.message)

 local eventSettings = currentProfile.events["NOTIFICATION_PET_COOLDOWN"]
 controls.petColorSwatch:SetColor(eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1)
 controls.petSkillColorSwatch:SetColor(eventSettings.skillColorR or 1, eventSettings.skillColorG or 1, eventSettings.skillColorB or 1)
 controls.petEnableCheckbox:SetChecked(not eventSettings.disabled)
 tabFrame.petMessageFontString:SetText(eventSettings.message)
 
 local eventSettings = currentProfile.events["NOTIFICATION_ITEM_COOLDOWN"]
 controls.itemColorSwatch:SetColor(eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1)
 controls.itemSkillColorSwatch:SetColor(eventSettings.skillColorR or 1, eventSettings.skillColorG or 1, eventSettings.skillColorB or 1)
 controls.itemEnableCheckbox:SetChecked(not eventSettings.disabled)
 tabFrame.itemMessageFontString:SetText(eventSettings.message)

 controls.cooldownSlider:SetValue(currentProfile.cooldownThreshold)
end


-------------------------------------------------------------------------------
-- Loot alerts tab functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Enables the controls on the loot alerts tab.
-- ****************************************************************************
local function LootAlertsTab_EnableControls()
 for name, frame in pairs(tabFrames.lootAlerts.controls) do
  if (frame.Enable) then frame:Enable() end
 end
end


-- ****************************************************************************
-- Saves the event settings selected by the user.
-- ****************************************************************************
local function LootAlertsTab_SaveEventSettings(settings, eventType)
 MSBTProfiles.SetOption("events." .. eventType, "scrollArea", settings.scrollArea, DEFAULT_SCROLL_AREA)
 MSBTProfiles.SetOption("events." .. eventType, "message", settings.message)
 MSBTProfiles.SetOption("events." .. eventType, "alwaysSticky", settings.alwaysSticky)
 MSBTProfiles.SetOption("events." .. eventType, "soundFile", settings.soundFile, "")

 local fontString = tabFrames.lootAlerts.lootedItemsFontString
 if (eventType == "NOTIFICATION_MONEY") then fontString = tabFrames.lootAlerts.moneyGainsFontString end
 if (eventType == "NOTIFICATION_CURRENCY") then fontString = tabFrames.lootAlerts.currencyGainsFontString end
 fontString:SetText(settings.message) 
end


-- ****************************************************************************
-- Saves the font settings selected by the user.
-- ****************************************************************************
local function LootAlertsTab_SaveFontSettings(settings, eventType)
 MSBTProfiles.SetOption("events." .. eventType, "fontName", settings.normalFontName)
 MSBTProfiles.SetOption("events." .. eventType, "outlineIndex", settings.normalOutlineIndex)
 MSBTProfiles.SetOption("events." .. eventType, "fontSize", settings.normalFontSize)
 MSBTProfiles.SetOption("events." .. eventType, "fontAlpha", settings.normalFontAlpha) 
end


-- ****************************************************************************
-- Creates the loot alerts tab frame contents.
-- ****************************************************************************
local function LootAlertsTab_Create()
 local tabFrame = tabFrames.lootAlerts
 tabFrame.controls = {}
 local controls = tabFrame.controls

 -- Loot colorswatch.
 local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
 colorswatch:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -10)
 colorswatch:SetColorChangedHandler(
   function (this)
    local eventType = "NOTIFICATION_LOOT"
    MSBTProfiles.SetOption("events." .. eventType, "colorR", this.r, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorG", this.g, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorB", this.b, 1)
   end
 )
 controls.lootAlertsColorSwatch = colorswatch

 -- Looted items enable checkbox.
 local checkbox = MSBTControls.CreateCheckbox(tabFrame)
 local objLocale = L.CHECKBOXES["lootedItems"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
 checkbox:SetPoint("RIGHT", tabFrame, "TOPLEFT", 190, -10)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption("events.NOTIFICATION_LOOT", "disabled", not isChecked)
   end
 )
 controls.lootedItemsEnableCheckbox = checkbox
 
 -- Loot alerts event settings button. 
 local button = MSBTControls.CreateIconButton(tabFrame, "Configure")
 objLocale = L.BUTTONS["eventSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("TOPRIGHT", tabFrame, "TOPRIGHT", -10, -5)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_LOOT"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]
 
    EraseTable(configTable)
    configTable.title = L.CHECKBOXES.lootedItems.label
    configTable.message = eventSettings.message
    configTable.codes = L.EVENT_CODES["ITEM_AMOUNT"] .. L.EVENT_CODES["ITEM_NAME"] .. L.EVENT_CODES["TOTAL_ITEMS"]
    configTable.scrollArea = eventSettings.scrollArea or DEFAULT_SCROLL_AREA
    configTable.alwaysSticky = eventSettings.alwaysSticky
    configTable.soundFile = eventSettings.soundFile
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = tabFrame
    configTable.anchorPoint = "TOPRIGHT"
    configTable.relativePoint = "TOPRIGHT"
	configTable.saveArg1 = eventType
    configTable.saveHandler = LootAlertsTab_SaveEventSettings
    configTable.hideHandler = LootAlertsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowEvent(configTable)
   end
 )
 controls.lootAlertsEventSettingButton = button

 -- Loot alerts font settings button. 
 button = MSBTControls.CreateIconButton(tabFrame, "FontSettings")
 objLocale = L.BUTTONS["eventFontSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls.lootAlertsEventSettingButton, "LEFT", 0, 0)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_LOOT"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]
    local saSettings = MSBTProfiles.currentProfile.scrollAreas[eventSettings.scrollArea]
    if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end
 
    EraseTable(configTable)
    configTable.title = L.CHECKBOXES.lootedItems.label
 
    -- Inherit from the correct scroll area.
    local fontName = saSettings.normalFontName
    if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
    if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
    configTable.inheritedNormalFontName = fontName
    configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
    configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
    configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

    fontName = eventSettings.fontName
    if (not fonts[fontName]) then fontName = nil end
    configTable.normalFontName = fontName
    configTable.normalOutlineIndex = eventSettings.outlineIndex
    configTable.normalFontSize = eventSettings.fontSize
    configTable.normalFontAlpha = eventSettings.fontAlpha

    configTable.hideCrit = true
    configTable.parentFrame = tabFrames.lootAlerts
    configTable.anchorFrame = tabFrames.lootAlerts
    configTable.anchorPoint = "BOTTOM"
    configTable.relativePoint = "BOTTOM"
	configTable.saveArg1 = eventType
    configTable.saveHandler = LootAlertsTab_SaveFontSettings
    configTable.hideHandler = LootAlertsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowFont(configTable)
   end
 )
 controls[#controls+1] = button

 -- Loot alerts message font string.
 local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
 fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 tabFrame.lootedItemsFontString = fontString


 -- Money gains colorswatch.
 local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
 colorswatch:SetPoint("TOPLEFT", controls.lootAlertsColorSwatch, "BOTTOMLEFT", 0, -10)
 colorswatch:SetColorChangedHandler(
   function (this)
    local eventType = "NOTIFICATION_MONEY"
    MSBTProfiles.SetOption("events." .. eventType, "colorR", this.r, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorG", this.g, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorB", this.b, 1)
   end
 )
 controls.moneyGainsColorSwatch = colorswatch

 -- Money gains enable checkbox.
 local checkbox = MSBTControls.CreateCheckbox(tabFrame)
 local objLocale = L.CHECKBOXES["moneyGains"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
 checkbox:SetPoint("RIGHT", tabFrame, "TOPLEFT", 190, -10)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption("events.NOTIFICATION_MONEY", "disabled", not isChecked)
   end
 )
 controls.moneyGainsEnableCheckbox = checkbox
 
 -- Money gains event settings button. 
 local button = MSBTControls.CreateIconButton(tabFrame, "Configure")
 objLocale = L.BUTTONS["eventSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("TOPRIGHT", controls.lootAlertsEventSettingButton, "BOTTOMRIGHT", 0, -5)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_MONEY"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]
 
    EraseTable(configTable)
    configTable.title = L.CHECKBOXES.moneyGains.label
    configTable.message = eventSettings.message
    configTable.codes = L.EVENT_CODES["MONEY_TEXT"]
    configTable.scrollArea = eventSettings.scrollArea or DEFAULT_SCROLL_AREA
    configTable.alwaysSticky = eventSettings.alwaysSticky
    configTable.soundFile = eventSettings.soundFile
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = tabFrame
    configTable.anchorPoint = "TOPRIGHT"
    configTable.relativePoint = "TOPRIGHT"
	configTable.saveArg1 = eventType
    configTable.saveHandler = LootAlertsTab_SaveEventSettings
    configTable.hideHandler = LootAlertsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowEvent(configTable)
   end
 )
 controls.moneyGainsEventSettingButton = button

 -- Money gains font settings button. 
 button = MSBTControls.CreateIconButton(tabFrame, "FontSettings")
 objLocale = L.BUTTONS["eventFontSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls.moneyGainsEventSettingButton, "LEFT", 0, 0)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_MONEY"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]
    local saSettings = MSBTProfiles.currentProfile.scrollAreas[eventSettings.scrollArea]
    if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end
 
    EraseTable(configTable)
    configTable.title = L.CHECKBOXES.moneyGains.label
 
    -- Inherit from the correct scroll area.
    local fontName = saSettings.normalFontName
    if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
    if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
    configTable.inheritedNormalFontName = fontName
    configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
    configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
    configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

    fontName = eventSettings.fontName
    if (not fonts[fontName]) then fontName = nil end
    configTable.normalFontName = fontName
    configTable.normalOutlineIndex = eventSettings.outlineIndex
    configTable.normalFontSize = eventSettings.fontSize
    configTable.normalFontAlpha = eventSettings.fontAlpha

    configTable.hideCrit = true
    configTable.parentFrame = tabFrames.lootAlerts
    configTable.anchorFrame = tabFrames.lootAlerts
    configTable.anchorPoint = "BOTTOM"
    configTable.relativePoint = "BOTTOM"
	configTable.saveArg1 = eventType
    configTable.saveHandler = LootAlertsTab_SaveFontSettings
    configTable.hideHandler = LootAlertsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowFont(configTable)
   end
 )
 controls[#controls+1] = button

 -- Money gains message font string.
 local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
 fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 tabFrame.moneyGainsFontString = fontString


 -- Currency colorswatch.
 local colorswatch = MSBTControls.CreateColorswatch(tabFrame)
 colorswatch:SetPoint("TOPLEFT", controls.moneyGainsColorSwatch, "BOTTOMLEFT", 0, -10)
 colorswatch:SetColorChangedHandler(
   function (this)
    local eventType = "NOTIFICATION_CURRENCY"
    MSBTProfiles.SetOption("events." .. eventType, "colorR", this.r, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorG", this.g, 1)
    MSBTProfiles.SetOption("events." .. eventType, "colorB", this.b, 1)
   end
 )
 controls.currencyGainsColorSwatch = colorswatch

 -- Currency gained enable checkbox.
 local checkbox = MSBTControls.CreateCheckbox(tabFrame)
 local objLocale = L.CHECKBOXES["currencyGains"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
 checkbox:SetPoint("RIGHT", tabFrame, "TOPLEFT", 190, -10)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption("events.NOTIFICATION_CURRENCY", "disabled", not isChecked)
   end
 )
 controls.currencyGainsEnableCheckbox = checkbox

 -- Currency alerts event settings button.
 local button = MSBTControls.CreateIconButton(tabFrame, "Configure")
 objLocale = L.BUTTONS["eventSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("TOPRIGHT", controls.moneyGainsEventSettingButton, "BOTTOMRIGHT", 0, -5)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_CURRENCY"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]

    EraseTable(configTable)
    configTable.title = L.CHECKBOXES.currencyGains.label
    configTable.message = eventSettings.message
    configTable.codes = L.EVENT_CODES["ITEM_AMOUNT"] .. L.EVENT_CODES["ITEM_NAME"] .. L.EVENT_CODES["TOTAL_ITEMS"]
    configTable.scrollArea = eventSettings.scrollArea or DEFAULT_SCROLL_AREA
    configTable.alwaysSticky = eventSettings.alwaysSticky
    configTable.soundFile = eventSettings.soundFile
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = tabFrame
    configTable.anchorPoint = "TOPRIGHT"
    configTable.relativePoint = "TOPRIGHT"
    configTable.saveArg1 = eventType
    configTable.saveHandler = LootAlertsTab_SaveEventSettings
    configTable.hideHandler = LootAlertsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowEvent(configTable)
   end
 )
 controls.currencyGainsEventSettingButton = button

 -- Currency alerts font settings button.
 button = MSBTControls.CreateIconButton(tabFrame, "FontSettings")
 objLocale = L.BUTTONS["eventFontSettings"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", controls.currencyGainsEventSettingButton, "LEFT", 0, 0)
 button:SetClickHandler(
   function (this)
    local eventType = "NOTIFICATION_CURRENCY"
    local eventSettings = MSBTProfiles.currentProfile.events[eventType]
    local saSettings = MSBTProfiles.currentProfile.scrollAreas[eventSettings.scrollArea]
    if (not saSettings) then saSettings = MSBTProfiles.currentProfile.scrollAreas[DEFAULT_SCROLL_AREA] end

    EraseTable(configTable)
    configTable.title = L.CHECKBOXES.currencyGains.label

    -- Inherit from the correct scroll area.
    local fontName = saSettings.normalFontName
    if (not fonts[fontName]) then fontName = MSBTProfiles.currentProfile.normalFontName end
    if (not fonts[fontName]) then fontName = DEFAULT_FONT_NAME end
    configTable.inheritedNormalFontName = fontName
    configTable.inheritedNormalOutlineIndex = saSettings.normalOutlineIndex or MSBTProfiles.currentProfile.normalOutlineIndex
    configTable.inheritedNormalFontSize = saSettings.normalFontSize or MSBTProfiles.currentProfile.normalFontSize
    configTable.inheritedNormalFontAlpha = saSettings.normalFontAlpha or MSBTProfiles.currentProfile.normalFontAlpha

    fontName = eventSettings.fontName
    if (not fonts[fontName]) then fontName = nil end
    configTable.normalFontName = fontName
    configTable.normalOutlineIndex = eventSettings.outlineIndex
    configTable.normalFontSize = eventSettings.fontSize
    configTable.normalFontAlpha = eventSettings.fontAlpha

    configTable.hideCrit = true
    configTable.parentFrame = tabFrames.lootAlerts
    configTable.anchorFrame = tabFrames.lootAlerts
    configTable.anchorPoint = "BOTTOM"
    configTable.relativePoint = "BOTTOM"
	configTable.saveArg1 = eventType
    configTable.saveHandler = LootAlertsTab_SaveFontSettings
    configTable.hideHandler = LootAlertsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowFont(configTable)
   end
 )
 controls[#controls+1] = button

 -- Currency alerts message font string.
 local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", checkbox, "RIGHT", 10, 0)
 fontString:SetPoint("RIGHT", button, "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 tabFrame.currencyGainsFontString = fontString

 -- Item qualities font string.
 local fontString = tabFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOPLEFT", controls.currencyGainsColorSwatch, "BOTTOMLEFT", 0, -30)
 fontString:SetJustifyH("LEFT")
 fontString:SetText(L.MSG_ITEM_QUALITIES .. ":")

 -- Item quality checkboxes.
 local anchor = fontString
 for quality = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_EPIC do
  local checkbox = MSBTControls.CreateCheckbox(tabFrame)
  local label = _G["ITEM_QUALITY" .. quality .. "_DESC"]
  local color = ITEM_QUALITY_COLORS[quality]
  if color then label = string.format("|cFF%02x%02x%02x%s|r", color.r * 255, color.g * 255, color.b * 255, label) end
  checkbox:Configure(24, label, L.MSG_DISPLAY_QUALITY)
  checkbox:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == fontString and 5 or 0, anchor == fontString and -10 or 0)
  checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption("qualityExclusions", quality, not isChecked)
   end
  )
  controls["quality" .. quality .. "Checkbox"] = checkbox
  anchor = checkbox
 end

 -- Always show quest items checkbox.
 local checkbox = MSBTControls.CreateCheckbox(tabFrame)
 local objLocale = L.CHECKBOXES["alwaysShowQuestItems"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.quality0Checkbox, "TOPRIGHT", 100, 0)
  checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "alwaysShowQuestItems", isChecked)
   end
  )
 controls.alwaysShowQuestItemsCheckbox = checkbox

 -- Items allowed button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["itemsAllowed"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", tabFrame, "BOTTOMLEFT", 5, 40)
 button:SetClickHandler(
   function (this)
    local listName = "itemsAllowed"
    PopulateList(listName)
    EraseTable(configTable)
    configTable.title = this:GetText()
    configTable.items = listTable
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = tabFrame
    configTable.anchorPoint = "TOPRIGHT"
    configTable.relativePoint = "TOPRIGHT"
    configTable.saveHandler = SaveList
    configTable.saveArg1 = listName
    configTable.hideHandler = LootAlertsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowItemList(configTable)
   end
 )
 controls.itemsAllowedButton = button

 -- Item exclusions button.
 button = MSBTControls.CreateOptionButton(tabFrame)
 objLocale = L.BUTTONS["itemExclusions"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", tabFrame, "BOTTOMRIGHT", -10, 40)
 button:SetClickHandler(
   function (this)
    local listName = "itemExclusions"
    PopulateList(listName)
    EraseTable(configTable)
    configTable.title = this:GetText()
    configTable.items = listTable
    configTable.parentFrame = tabFrame
    configTable.anchorFrame = tabFrame
    configTable.anchorPoint = "TOPRIGHT"
    configTable.relativePoint = "TOPRIGHT"
    configTable.saveHandler = SaveList
    configTable.saveArg1 = listName
    configTable.hideHandler = LootAlertsTab_EnableControls
    DisableControls(controls)
    MSBTPopups.ShowItemList(configTable)
   end
 )
 controls.itemExclusionsButton = button

 tabFrame.created = true
end


-- ****************************************************************************
-- Called when the tab frame is shown.
-- ****************************************************************************
local function LootAlertsTab_OnShow()
 if (not tabFrames.lootAlerts.created) then LootAlertsTab_Create() end

 local tabFrame = tabFrames.lootAlerts
 local controls = tabFrame.controls
 local currentProfile = MSBTProfiles.currentProfile

 -- Looted items.
 local eventSettings = currentProfile.events["NOTIFICATION_LOOT"]
 controls.lootAlertsColorSwatch:SetColor(eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1)
 controls.lootedItemsEnableCheckbox:SetChecked(not eventSettings.disabled)
 tabFrame.lootedItemsFontString:SetText(eventSettings.message)

 -- Money gains.
 local eventSettings = currentProfile.events["NOTIFICATION_MONEY"]
 controls.moneyGainsColorSwatch:SetColor(eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1)
 controls.moneyGainsEnableCheckbox:SetChecked(not eventSettings.disabled)
 tabFrame.moneyGainsFontString:SetText(eventSettings.message)

 -- Currency gains.
 local eventSettings = currentProfile.events["NOTIFICATION_CURRENCY"]
 controls.currencyGainsColorSwatch:SetColor(eventSettings.colorR or 1, eventSettings.colorG or 1, eventSettings.colorB or 1)
 controls.currencyGainsEnableCheckbox:SetChecked(not eventSettings.disabled)
 tabFrame.currencyGainsFontString:SetText(eventSettings.message)


 -- Item qualities.
 for quality = LE_ITEM_QUALITY_POOR, LE_ITEM_QUALITY_EPIC do
  controls["quality" .. quality .. "Checkbox"]:SetChecked(not currentProfile.qualityExclusions[quality])
 end
 
 -- Quest items.
 controls.alwaysShowQuestItemsCheckbox:SetChecked(currentProfile.alwaysShowQuestItems)
end


-------------------------------------------------------------------------------
-- Skill icons tab functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the skill icons tab frame contents.
-- ****************************************************************************
local function SkillIconsTab_Create()
 local tabFrame = tabFrames.skillIcons
 tabFrame.controls = {}
 local controls = tabFrame.controls
 
 -- Enable checkbox.
 local checkbox = MSBTControls.CreateCheckbox(tabFrame)
 local objLocale = L.CHECKBOXES["enableIcons"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", tabFrame, "TOPLEFT", 5, -10)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "skillIconsDisabled", not isChecked)
    if (isChecked) then controls.exclusiveCheckbox:Enable() else controls.exclusiveCheckbox:Disable() end
   end
 )
 controls.enableCheckbox = checkbox

 -- Exclusive skills checkbox.
 checkbox = MSBTControls.CreateCheckbox(tabFrame)
 local objLocale = L.CHECKBOXES["exclusiveSkills"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.enableCheckbox, "BOTTOMLEFT", 20, -10)
 checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(nil, "exclusiveSkillsDisabled", not isChecked)
   end
 )
 controls.exclusiveCheckbox = checkbox


 tabFrame.created = true
end


-- ****************************************************************************
-- Called when the tab frame is shown.
-- ****************************************************************************
local function SkillIconsTab_OnShow()
 if (not tabFrames.skillIcons.created) then SkillIconsTab_Create() end

 local tabFrame = tabFrames.skillIcons
 local controls = tabFrame.controls
 local currentProfile = MSBTProfiles.currentProfile

 controls.enableCheckbox:SetChecked(not currentProfile.skillIconsDisabled)
 controls.exclusiveCheckbox:SetChecked(not currentProfile.exclusiveSkillsDisabled)
 
 if (controls.enableCheckbox:GetChecked()) then
  controls.exclusiveCheckbox:Enable()
 else
  controls.exclusiveCheckbox:Disable()
 end
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

-- Create an empty frame for the media tab that will be dynamically created when shown.
local objLocale = L.TABS["customMedia"]
local tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", MediaTab_OnShow)
tabFrames.media = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the general tab that will be dynamically created when shown.
objLocale = L.TABS.general
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", GeneralTab_OnShow)
tabFrames.general = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the scroll areas tab that will be dynamically created when shown.
objLocale = L.TABS.scrollAreas
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", ScrollAreasTab_OnShow)
tabFrames.scrollAreas = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the events tab that will be dynamically created when shown.
objLocale = L.TABS.events
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", EventsTab_OnShow)
tabFrames.events = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the triggers tab that will be dynamically created when shown.
objLocale = L.TABS.triggers
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", TriggersTab_OnShow)
tabFrames.triggers = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the spam tab that will be dynamically created when shown.
objLocale = L.TABS.spamControl
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", SpamTab_OnShow)
tabFrames.spam = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the cooldowns tab that will be dynamically created when shown.
objLocale = L.TABS.cooldowns
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", CooldownsTab_OnShow)
tabFrames.cooldowns = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the loot alerts tab that will be dynamically created when shown.
objLocale = L.TABS.lootAlerts
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", LootAlertsTab_OnShow)
tabFrames.lootAlerts = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)

-- Create an empty frame for the icons tab that will be dynamically created when shown.
objLocale = L.TABS.skillIcons
tabFrame = CreateFrame("Frame")
tabFrame:Hide()
tabFrame:SetScript("OnShow", SkillIconsTab_OnShow)
tabFrames.skillIcons = tabFrame
MSBTOptMain.AddTab(tabFrame, objLocale.label, objLocale.tooltip)