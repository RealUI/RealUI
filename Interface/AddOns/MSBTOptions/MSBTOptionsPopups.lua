-------------------------------------------------------------------------------
-- Title: MSBT Options Popups
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Popups"
MSBTOptions[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various modules for faster access.
local MSBTControls = MSBTOptions.Controls
local MSBTProfiles = MikSBT.Profiles
local MSBTAnimations = MikSBT.Animations
local MSBTTriggers = MikSBT.Triggers
local MSBTParser = MikSBT.Parser
local MSBTMain = MikSBT.Main
local MSBTMedia = MikSBT.Media
local L = MikSBT.translations

-- Local references to various functions for faster access.
local EraseTable = MikSBT.EraseTable
local GetSkillName = MikSBT.GetSkillName
local ConvertType = MSBTTriggers.ConvertType

-- Local references to various variables for faster access.
local fonts = MSBTMedia.fonts
local sounds = MSBTMedia.sounds


-------------------------------------------------------------------------------
-- Private constants.
-------------------------------------------------------------------------------

local OUTLINE_MAP = {"", "OUTLINE", "THICKOUTLINE", "MONOCHROME", "MONOCHROME,OUTLINE", "MONOCHROME,THICKOUTLINE"}
local DEFAULT_TEXT_ALIGN_INDEX = 2
local DEFAULT_SCROLL_HEIGHT = 260
local DEFAULT_SCROLL_WIDTH = 40
local DEFAULT_ANIMATION_STYLE = "Straight"
local DEFAULT_STICKY_ANIMATION_STYLE = "Pow"
local DEFAULT_ICON_ALIGN = "Left"
local DEFAULT_SOUND_PATH = "Interface\\AddOns\\MikScrollingBattleText\\Sounds\\"
local PREVIEW_ICON_PATH = "Interface\\Icons\\INV_Misc_AhnQirajTrinket_03"

local FLAG_YOU = 0xF0000000
local CLASS_NAMES = {}

-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Prevent tainting global _.
local _

local popupFrames = {}

-- Backdrop to reuse for the popup frames.
local popupBackdrop = {
  bgFile = "Interface\\Addons\\MSBTOptions\\Artwork\\PlainBackdrop",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  insets = {left = 6, right = 6, top = 6, bottom = 6},
}

-- Backdrop to reuse for the scroll area mover frame.
local moverBackdrop = {
  bgFile = "Interface\\Tooltips\\UI-Tooltip-Background",
}

-- Reusable table for return settings.
local returnSettings = {}

-- Reusable table to configure popup frames.
local tempConfig = {}


-------------------------------------------------------------------------------
-- Utility functions.
-------------------------------------------------------------------------------

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
-- Called when a popup is hidden.
-- ****************************************************************************
local function OnHidePopup(this)
 PlaySound("gsTitleOptionExit")
 if (this.hideHandler) then this.hideHandler() end
end


-- ****************************************************************************
-- Creates a new generic popup.
-- ****************************************************************************
local function CreatePopup()
 local frame = CreateFrame("Frame", nil, UIParent)
 frame:Hide()
 frame:EnableMouse(true)
 frame:SetMovable(true)
 frame:RegisterForDrag("LeftButton")
 frame:SetFrameStrata("HIGH")
 --frame:SetToplevel(true)
 frame:SetClampedToScreen(true)
 frame:SetBackdrop(popupBackdrop)
 frame:SetScript("OnHide", OnHidePopup)

 frame:SetScript("OnShow", function(self)
  PlaySound("igMainMenuOption")
 end)
 frame:SetScript("OnDragStart", function(self)
  self:StartMoving()
 end)
 frame:SetScript("OnDragStop", function(self)
  self:StopMovingOrSizing()
 end)

 -- Title region.
 --local titleRegion = frame:CreateTitleRegion()
 --titleRegion:SetAllPoints(frame)

 -- Register the frame with the main module.
 MSBTOptions.Main.RegisterPopupFrame(frame)
 return frame
end


-- ****************************************************************************
-- Changes the passed popup frame's parent.
-- ****************************************************************************
local function ChangePopupParent(frame, parent)
 -- Changing the parent can cause the frame to be hidden, so ensure the hide
 -- handler isn't called.
 local oldHandler = frame.hideHandler
 frame.hideHandler = nil
 frame:SetParent(parent or UIParent)
 frame:SetFrameStrata("HIGH")
 frame.hideHandler = oldHandler
end


-- ****************************************************************************
-- Disables the controls in the passed table.
-- ****************************************************************************
local function DisableControls(controlsTable)
 for _, frame in pairs(controlsTable) do
  if (frame.Disable) then frame:Disable() end
 end
end


-- ****************************************************************************
-- Toggles the state of a font dropdown control when an inherit checkbox is
-- changed.
-- ****************************************************************************
local function ToggleDropdownInheritState(dropdown, isInherited, inheritedValue)
 if (isInherited) then
  dropdown:SetSelectedID(inheritedValue)
  dropdown:Disable()
  dropdown:SetAlpha(0.3)
 else
  dropdown:SetAlpha(1)
  dropdown:Enable()
 end
end


-- ****************************************************************************
-- Toggles the state of a font slider control when an inherit checkbox is
-- changed.
-- ****************************************************************************
local function ToggleSliderInheritState(slider, isInherited, inheritedValue)
 if (isInherited) then
  slider:SetValue(inheritedValue)
  slider:Disable()
  slider:SetAlpha(0.3)
 else
  slider:SetAlpha(1)
  slider:Enable()
 end
end




-------------------------------------------------------------------------------
-- Input frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when the text in the input frame editbox changes to allow validation.
-- ****************************************************************************
local function ValidateInputCallback(message)
 local frame = popupFrames.inputFrame
 
 -- Clear validation message and enable okay button.
 frame.validateFontString:SetText("")
 frame.okayButton:Enable()

  -- Disable the save button and display the validation message if validation failed.
  if (message) then
   frame.validateFontString:SetText(message)
   frame.okayButton:Disable()
  end
end

-- ****************************************************************************
-- Called when the text in the input frame editbox changes to allow validation.
-- ****************************************************************************
local function ValidateInput(this)
 local frame = popupFrames.inputFrame

 -- Clear validation message and enable okay button.
 frame.validateFontString:SetText("")
 frame.okayButton:Enable()

 if (frame.validateHandler) then
  local firstText = frame.inputEditbox:GetText()
  local secondText = frame.secondInputEditbox:GetText()
  local message = frame.validateHandler(firstText, frame.showSecondEditbox and secondText, ValidateInputCallback)

  -- Disable the save button and display the validation message if validation failed.
  if (message) then
   frame.validateFontString:SetText(message)
   frame.okayButton:Disable()
  end
 end 
end


-- ****************************************************************************
-- Calls the save handler with the entered input.
-- ****************************************************************************
local function SaveInput()
 local frame = popupFrames.inputFrame
 if (frame.saveHandler and frame.okayButton:IsEnabled() ~= 0) then
  EraseTable(returnSettings)
  returnSettings.inputText = frame.inputEditbox:GetText()
  returnSettings.secondInputText = frame.secondInputEditbox:GetText()
  returnSettings.saveArg1 = frame.saveArg1
  frame:Hide()
  frame.saveHandler(returnSettings)
 end
end


-- ****************************************************************************
-- Creates the popup input frame.
-- ****************************************************************************
local function CreateInput()
 local frame = CreatePopup()
 frame:SetWidth(350)
 frame:SetHeight(130)

 -- Input editbox.
 local editbox = MSBTControls.CreateEditbox(frame)
 editbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -25)
 editbox:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -25)
 editbox:SetEscapeHandler(
  function (this)
   frame:Hide()
  end
 )
 editbox:SetEnterHandler(SaveInput)
 editbox:SetTextChangedHandler(ValidateInput)
 frame.inputEditbox = editbox
 
 -- Second input editbox.
 editbox = MSBTControls.CreateEditbox(frame)
 editbox:SetPoint("TOPLEFT", frame.inputEditbox, "BOTTOMLEFT", 0, -10)
 editbox:SetPoint("TOPRIGHT", frame.inputEditbox, "BOTTOMRIGHT", 0, -10)
 editbox:SetEscapeHandler(
  function (this)
   frame:Hide()
  end
 )
 editbox:SetEnterHandler(SaveInput)
 editbox:SetTextChangedHandler(ValidateInput)
 frame.secondInputEditbox = editbox
 
 
 -- Okay button.
 local button = MSBTControls.CreateOptionButton(frame)
 local objLocale = L.BUTTONS["inputOkay"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 40)
 button:SetClickHandler(SaveInput)
 frame.okayButton = button

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["inputCancel"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 40)
 button:SetClickHandler(
  function (this)
   frame:Hide()
  end
 )
 
 -- Validation text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 30, 20)
 fontString:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -30, 20)
 frame.validateFontString = fontString

 return frame
end


-- ****************************************************************************
-- Shows the popup input frame using the passed config.
-- ****************************************************************************
local function ShowInput(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end
 
 -- Create the frame if it hasn't already been.
 if (not popupFrames.inputFrame) then popupFrames.inputFrame = CreateInput() end

 -- Set parent.
 local frame = popupFrames.inputFrame
 ChangePopupParent(frame, configTable.parentFrame)
 
 -- Populate.
 local editbox = frame.inputEditbox
 editbox:SetLabel(configTable.editboxLabel)
 editbox:SetTooltip(configTable.editboxTooltip)
 editbox:SetText("")
 editbox:SetText(configTable.defaultText)

 editbox = frame.secondInputEditbox
 if (configTable.showSecondEditbox) then
  editbox:Show()
  editbox:SetLabel(configTable.secondEditboxLabel)
  editbox:SetTooltip(configTable.secondEditboxTooltip)
  editbox:SetText(configTable.secondDefaultText)
  frame:SetHeight(170)
 else
  editbox:SetText(nil)
  editbox:Hide()
  frame:SetHeight(130)
 end
 

 -- Configure the frame. 
 frame.showSecondEditbox = configTable.showSecondEditbox
 frame.validateHandler = configTable.validateHandler
 frame.saveHandler = configTable.saveHandler
 frame.saveArg1 = configTable.saveArg1
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
 frame.inputEditbox:SetFocus()
end


-------------------------------------------------------------------------------
-- Acknowledge frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the popup acknowledge frame.
-- ****************************************************************************
local function CreateAcknowledge()
 local frame = CreatePopup()
 frame:SetWidth(350)
 frame:SetHeight(90)
 
 -- Acknowledge text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 30, -20)
 fontString:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -30, -20)
 fontString:SetText(L.MSG_ACKNOWLEDGE_TEXT)

 -- Yes button.
 local button = MSBTControls.CreateOptionButton(frame)
 button:Configure(20, YES, nil)
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 15)
 button:SetClickHandler(
  function (this)
   if (frame.acknowledgeHandler) then
    frame.acknowledgeHandler(frame.saveArg1)
    frame:Hide()
   end
  end
 )

 -- No button.
 button = MSBTControls.CreateOptionButton(frame)
 button:Configure(20, NO, nil)
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 15)
 button:SetClickHandler(
  function (this)
   frame:Hide()
  end
 )
 
 return frame
end


-- ****************************************************************************
-- Shows the popup acknowledge frame using the passed config.
-- ****************************************************************************
local function ShowAcknowledge(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end
 
 -- Create the frame if it hasn't already been.
 if (not popupFrames.acknowledgeFrame) then popupFrames.acknowledgeFrame = CreateAcknowledge() end


 -- Set parent. 
 local frame = popupFrames.acknowledgeFrame
 ChangePopupParent(frame, configTable.parentFrame)
 
 -- Configure the frame.
 frame.acknowledgeHandler = configTable.acknowledgeHandler
 frame.saveArg1 = configTable.saveArg1
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Font frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Updates the return settings table with the selected font values.
-- ****************************************************************************
local function UpdateFontSettings()
 local frame = popupFrames.fontFrame

 EraseTable(returnSettings)
 
 if (not frame.hideNormal) then
  returnSettings.normalFontName = not frame.normalFontCheckbox:GetChecked() and frame.normalFontDropdown:GetSelectedID() or nil
  returnSettings.normalOutlineIndex = not frame.normalOutlineCheckbox:GetChecked() and frame.normalOutlineDropdown:GetSelectedID() or nil
  returnSettings.normalFontSize = not frame.normalFontSizeCheckbox:GetChecked() and frame.normalFontSizeSlider:GetValue() or nil
  returnSettings.normalFontAlpha = not frame.normalFontOpacityCheckbox:GetChecked() and frame.normalFontOpacitySlider:GetValue() or nil
 end
 
 if (not frame.hideCrit) then
  returnSettings.critFontName = not frame.critFontCheckbox:GetChecked() and frame.critFontDropdown:GetSelectedID() or nil
  returnSettings.critOutlineIndex = not frame.critOutlineCheckbox:GetChecked() and frame.critOutlineDropdown:GetSelectedID() or nil
  returnSettings.critFontSize = not frame.critFontSizeCheckbox:GetChecked() and frame.critFontSizeSlider:GetValue() or nil
  returnSettings.critFontAlpha = not frame.critFontOpacityCheckbox:GetChecked() and frame.critFontOpacitySlider:GetValue() or nil
 end
end


-- ****************************************************************************
-- Updates the normal and crit font previews.
-- ****************************************************************************
local function UpdateFontPreviews()
 local frame = popupFrames.fontFrame

 local fontPath, fontSize, outline

 if (not frame.hideNormal) then 
  fontPath = fonts[frame.normalFontDropdown:GetSelectedID()]
  fontSize = frame.normalFontSizeSlider:GetValue()
  outline = OUTLINE_MAP[frame.normalOutlineDropdown:GetSelectedID()]
  frame.normalPreviewFontString:SetFont(fontPath, fontSize, outline)
  frame.normalPreviewFontString:SetText("")
  frame.normalPreviewFontString:SetText(L.MSG_NORMAL_PREVIEW_TEXT)
  frame.normalPreviewFontString:SetAlpha(frame.normalFontOpacitySlider:GetValue() / 100)
 end
 
 if (not frame.hideCrit) then
  fontPath = fonts[frame.critFontDropdown:GetSelectedID()]
  fontSize = frame.critFontSizeSlider:GetValue()
  outline = OUTLINE_MAP[frame.critOutlineDropdown:GetSelectedID()]
  if (fontPath and outline) then
   frame.critPreviewFontString:SetFont(fontPath, fontSize, outline)
   frame.critPreviewFontString:SetText("")
   frame.critPreviewFontString:SetText(L.MSG_CRIT)
  end
  frame.critPreviewFontString:SetAlpha(frame.critFontOpacitySlider:GetValue() / 100)
 end
end


-- ****************************************************************************
-- Creates the popup font frame.
-- ****************************************************************************
local function CreateFontPopup()
 local frame = CreatePopup()
 frame:SetWidth(450)
 frame:SetHeight(380)

 -- Title text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOP", frame, "TOP", 0, -20)
 frame.titleFontString = fontString

 
 -- Normal container frame.
 local normalFrame = CreateFrame("Frame", nil, frame)
 normalFrame:SetWidth(195)
 normalFrame:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -60)
 normalFrame:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 20, 40)
 frame.normalFrame = normalFrame


 -- Normal controls container frame.
 local normalControlsFrame = CreateFrame("Frame", nil, normalFrame)
 normalControlsFrame:SetWidth(155)
 normalControlsFrame:SetPoint("TOPLEFT")
 normalControlsFrame:SetPoint("BOTTOMLEFT")
 frame.normalControlsFrame = normalControlsFrame

 -- Normal font dropdown.
 local dropdown =  MSBTControls.CreateDropdown(normalControlsFrame)
 local objLocale = L.DROPDOWNS["normalFont"]
 dropdown:Configure(150, objLocale.label, objLocale.tooltip)
 dropdown:SetListboxHeight(200)
 dropdown:SetPoint("TOPLEFT")
 dropdown:SetChangeHandler(
  function (this, id)
     UpdateFontPreviews()
  end
 )
 frame.normalFontDropdown = dropdown

 -- Normal outline dropdown.
 dropdown =  MSBTControls.CreateDropdown(normalControlsFrame)
 objLocale = L.DROPDOWNS["normalOutline"]
 dropdown:Configure(150, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", frame.normalFontDropdown, "BOTTOMLEFT", 0, -20)
 dropdown:SetChangeHandler(
  function (this, id)
     UpdateFontPreviews()
  end
 )
 for outlineIndex, outlineName in ipairs(L.OUTLINES) do
  dropdown:AddItem(outlineName, outlineIndex)
 end
 frame.normalOutlineDropdown = dropdown

 -- Normal font size slider.
 local slider = MSBTControls.CreateSlider(normalControlsFrame)
 objLocale = L.SLIDERS["normalFontSize"] 
 slider:Configure(150, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", frame.normalOutlineDropdown, "BOTTOMLEFT", 0, -30)
 slider:SetMinMaxValues(4, 38)
 slider:SetValueStep(1)
 slider:SetValueChangedHandler(
  function(this, value)
    UpdateFontPreviews()
  end
 )
 frame.normalFontSizeSlider = slider

 -- Normal font opacity slider.
 slider = MSBTControls.CreateSlider(normalControlsFrame)
 objLocale = L.SLIDERS["normalFontOpacity"] 
 slider:Configure(150, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", frame.normalFontSizeSlider, "BOTTOMLEFT", 0, -10)
 slider:SetMinMaxValues(1, 100)
 slider:SetValueStep(1)
 slider:SetValueChangedHandler(
  function(this, value)
    UpdateFontPreviews()
  end
 )
 frame.normalFontOpacitySlider = slider

 -- Normal preview.
 fontString = normalControlsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("BOTTOM", normalControlsFrame, "BOTTOM", 0, 10)
 fontString:SetText(L.MSG_NORMAL_PREVIEW_TEXT)
 frame.normalPreviewFontString = fontString



 -- Normal inherit container frame. 
 local normalInheritFrame = CreateFrame("Frame", nil, normalFrame)
 normalInheritFrame:SetWidth(40)
 normalInheritFrame:SetPoint("TOPLEFT", normalControlsFrame, "TOPRIGHT")
 normalInheritFrame:SetPoint("BOTTOMLEFT", normalControlsFrame, "BOTTOMRIGHT")
 frame.normalInheritFrame = normalInheritFrame
 
 -- Inherit normal font name checkbox.
 local checkbox = MSBTControls.CreateCheckbox(normalInheritFrame)
 objLocale = L.CHECKBOXES["inheritField"] 
 checkbox:Configure(20, nil, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMLEFT", frame.normalFontDropdown, "BOTTOMRIGHT", 10, 0)
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleDropdownInheritState(frame.normalFontDropdown, isChecked, frame.inheritedNormalFontName)
   UpdateFontPreviews() 
  end
 )
 frame.normalFontCheckbox = checkbox 

 -- Inherit normal outline index checkbox.
 checkbox = MSBTControls.CreateCheckbox(normalInheritFrame)
 checkbox:Configure(20, nil, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMLEFT", frame.normalOutlineDropdown, "BOTTOMRIGHT", 10, 0)
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleDropdownInheritState(frame.normalOutlineDropdown, isChecked, frame.inheritedNormalOutlineIndex)
   UpdateFontPreviews() 
  end
 )
 frame.normalOutlineCheckbox = checkbox 

 -- Inherit normal font size checkbox.
 checkbox = MSBTControls.CreateCheckbox(normalInheritFrame)
 checkbox:Configure(20, nil, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMLEFT", frame.normalFontSizeSlider, "BOTTOMRIGHT", 10, 5)
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleSliderInheritState(frame.normalFontSizeSlider, isChecked, frame.inheritedNormalFontSize)
   UpdateFontPreviews() 
  end
 )
 frame.normalFontSizeCheckbox = checkbox 

 -- Inherit normal font opacity checkbox.
 checkbox = MSBTControls.CreateCheckbox(normalInheritFrame)
 checkbox:Configure(20, nil, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMLEFT", frame.normalFontOpacitySlider, "BOTTOMRIGHT", 10, 5)
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleSliderInheritState(frame.normalFontOpacitySlider, isChecked, frame.inheritedNormalFontAlpha)
   UpdateFontPreviews() 
  end
 )
 frame.normalFontOpacityCheckbox = checkbox 

 -- Inherit normal column label.
 fontString = normalInheritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("BOTTOM", frame.normalFontCheckbox, "TOP", 0, 7)
 fontString:SetText(L.CHECKBOXES["inheritField"].label)

 
 

 -- Crit container frame.
 local critFrame = CreateFrame("Frame", nil, frame)
 critFrame:SetWidth(195)
 critFrame:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -20, -60)
 critFrame:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -20, 40)
 frame.critFrame = critFrame

 
 -- Crit controls container frame.
 local critControlsFrame = CreateFrame("Frame", nil, critFrame)
 critControlsFrame:SetWidth(155)
 critControlsFrame:SetPoint("TOPLEFT")
 critControlsFrame:SetPoint("BOTTOMLEFT")
 frame.critControlsFrame = critControlsFrame

 -- Crit font dropdown.
 dropdown =  MSBTControls.CreateDropdown(critControlsFrame)
 objLocale = L.DROPDOWNS["critFont"]
 dropdown:Configure(150, objLocale.label, objLocale.tooltip)
 dropdown:SetListboxHeight(200)
 dropdown:SetPoint("TOPLEFT")
 dropdown:SetChangeHandler(
  function (this, id)
     UpdateFontPreviews()
  end
 )
 frame.critFontDropdown = dropdown
 
 -- Crit outline dropdown.
 dropdown =  MSBTControls.CreateDropdown(critControlsFrame)
 objLocale = L.DROPDOWNS["critOutline"]
 dropdown:Configure(150, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", frame.critFontDropdown, "BOTTOMLEFT", 0, -20)
 dropdown:SetChangeHandler(
  function (this, id)
     UpdateFontPreviews()
  end
 )
 for outlineIndex, outlineName in ipairs(L.OUTLINES) do
  dropdown:AddItem(outlineName, outlineIndex)
 end
 frame.critOutlineDropdown = dropdown

 -- Crit font size slider.
 slider = MSBTControls.CreateSlider(critControlsFrame)
 objLocale = L.SLIDERS["critFontSize"] 
 slider:Configure(150, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", frame.critOutlineDropdown, "BOTTOMLEFT", 0, -30)
 slider:SetMinMaxValues(4, 38)
 slider:SetValueStep(1)
 slider:SetValueChangedHandler(
  function(this, value)
    UpdateFontPreviews()
  end
 )
 frame.critFontSizeSlider = slider

 -- Crit font opacity slider.
 slider = MSBTControls.CreateSlider(critControlsFrame)
 objLocale = L.SLIDERS["critFontOpacity"] 
 slider:Configure(150, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", frame.critFontSizeSlider, "BOTTOMLEFT", 0, -10)
 slider:SetMinMaxValues(1, 100)
 slider:SetValueStep(1)
 slider:SetValueChangedHandler(
  function(this, value)
   UpdateFontPreviews()
  end
 )
 frame.critFontOpacitySlider = slider

 -- Crit Preview. 
 fontString = critControlsFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("BOTTOM", critControlsFrame, "BOTTOM", 0, 10)
 fontString:SetText(L.MSG_CRIT)
 frame.critPreviewFontString = fontString



 -- Crit inherit container frame. 
 local critInheritFrame = CreateFrame("Frame", nil, critFrame)
 critInheritFrame:SetWidth(40)
 critInheritFrame:SetPoint("TOPLEFT", critControlsFrame, "TOPRIGHT")
 critInheritFrame:SetPoint("BOTTOMLEFT", critControlsFrame, "BOTTOMRIGHT")
 frame.critInheritFrame = critInheritFrame


 -- Inherit crit font name checkbox.
 local checkbox = MSBTControls.CreateCheckbox(critInheritFrame)
 objLocale = L.CHECKBOXES["inheritField"] 
 checkbox:Configure(20, nil, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMLEFT", frame.critFontDropdown, "BOTTOMRIGHT", 10, 0)
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleDropdownInheritState(frame.critFontDropdown, isChecked, frame.inheritedCritFontName)
   UpdateFontPreviews() 
  end
 )
 frame.critFontCheckbox = checkbox 

 -- Inherit crit outline index checkbox.
 checkbox = MSBTControls.CreateCheckbox(critInheritFrame)
 checkbox:Configure(20, nil, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMLEFT", frame.critOutlineDropdown, "BOTTOMRIGHT", 10, 0)
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleDropdownInheritState(frame.critOutlineDropdown, isChecked, frame.inheritedCritOutlineIndex)
   UpdateFontPreviews() 
  end
 )
 frame.critOutlineCheckbox = checkbox 

 -- Inherit crit font size checkbox.
 checkbox = MSBTControls.CreateCheckbox(critInheritFrame)
 checkbox:Configure(20, nil, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMLEFT", frame.critFontSizeSlider, "BOTTOMRIGHT", 10, 5)
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleSliderInheritState(frame.critFontSizeSlider, isChecked, frame.inheritedCritFontSize)
   UpdateFontPreviews() 
  end
 )
 frame.critFontSizeCheckbox = checkbox 

 -- Inherit crit font opacity checkbox.
 checkbox = MSBTControls.CreateCheckbox(critInheritFrame)
 checkbox:Configure(20, nil, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMLEFT", frame.critFontOpacitySlider, "BOTTOMRIGHT", 10, 5)
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleSliderInheritState(frame.critFontOpacitySlider, isChecked, frame.inheritedCritFontAlpha)
   UpdateFontPreviews() 
  end
 )
 frame.critFontOpacityCheckbox = checkbox 

 -- Inherit normal column label.
 fontString = critInheritFrame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("BOTTOM", frame.critFontCheckbox, "TOP", 0, 7)
 fontString:SetText(L.CHECKBOXES["inheritField"].label)

 -- Save button.
 local button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericSave"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20)
 button:SetClickHandler(
  function (this)
   UpdateFontSettings()
   frame:Hide()
   if (frame.saveHandler) then frame.saveHandler(returnSettings, frame.saveArg1) end
  end
 )

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericCancel"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20)
 button:SetClickHandler(
  function (this)
   frame:Hide()
  end
 )
 

 -- Register the frame with the main module.
 MSBTOptions.Main.RegisterPopupFrame(frame)
 return frame
end


-- ****************************************************************************
-- Shows the popup font frame using the passed config.
-- ****************************************************************************
local function ShowFont(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end
 
 -- Create the frame if it hasn't already been.
 if (not popupFrames.fontFrame) then popupFrames.fontFrame = CreateFontPopup() end

 -- Set parent.
 local frame = popupFrames.fontFrame 
 ChangePopupParent(frame, configTable.parentFrame)
 
 -- Show / Hide appropriate controls.
 if (configTable.hideNormal) then frame.normalFrame:Hide() else frame.normalFrame:Show() end
 if (configTable.hideCrit) then frame.critFrame:Hide() else frame.critFrame:Show() end
 if (configTable.hideInherit) then frame.normalInheritFrame:Hide() else frame.normalInheritFrame:Show() end
 if (configTable.hideInherit) then frame.critInheritFrame:Hide() else frame.critInheritFrame:Show() end
 frame.hideNormal = configTable.hideNormal
 frame.hideCrit = configTable.hideCrit


 -- Populate data.
 local dropdown, checkbox, slider
 frame.titleFontString:SetText(configTable.title) 

 if (not configTable.hideNormal) then 
  -- Normal font name.
  dropdown = frame.normalFontDropdown
  dropdown:Clear()
  for fontName in pairs(fonts) do
   dropdown:AddItem(fontName, fontName)
  end
  dropdown:Sort()
  checkbox = frame.normalFontCheckbox
  checkbox:SetChecked(not configTable.normalFontName or false)
  if (configTable.normalFontName) then dropdown:SetSelectedID(configTable.normalFontName) end
  ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedNormalFontName)

  -- Normal outline index.
  dropdown = frame.normalOutlineDropdown
  checkbox = frame.normalOutlineCheckbox
  checkbox:SetChecked(not configTable.normalOutlineIndex or false)
  if (configTable.normalOutlineIndex) then dropdown:SetSelectedID(configTable.normalOutlineIndex) end
  ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedNormalOutlineIndex)

  -- Normal font size. 
  slider = frame.normalFontSizeSlider
  checkbox = frame.normalFontSizeCheckbox
  checkbox:SetChecked(not configTable.normalFontSize or false)
  if (configTable.normalFontSize) then slider:SetValue(configTable.normalFontSize) end
  ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedNormalFontSize)

  -- Normal font opacity. 
  slider = frame.normalFontOpacitySlider
  checkbox = frame.normalFontOpacityCheckbox
  checkbox:SetChecked(not configTable.normalFontAlpha or false)
  if (configTable.normalFontAlpha) then slider:SetValue(configTable.normalFontAlpha) end
  ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedNormalFontAlpha)
 end


 if (not configTable.hideCrit) then
  -- Crit font name.
  dropdown = frame.critFontDropdown
  dropdown:Clear()
  for fontName in pairs(fonts) do
   dropdown:AddItem(fontName, fontName)
  end
  dropdown:Sort()
  checkbox = frame.critFontCheckbox
  checkbox:SetChecked(not configTable.critFontName or false)
  if (configTable.critFontName) then dropdown:SetSelectedID(configTable.critFontName) end
  ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedCritFontName)

  -- Crit outline index.
  dropdown = frame.critOutlineDropdown
  checkbox = frame.critOutlineCheckbox
  checkbox:SetChecked(not configTable.critOutlineIndex or false)
  if (configTable.critOutlineIndex) then dropdown:SetSelectedID(configTable.critOutlineIndex) end
  ToggleDropdownInheritState(dropdown, checkbox:GetChecked(), configTable.inheritedCritOutlineIndex)

  -- Crit font size. 
  slider = frame.critFontSizeSlider
  checkbox = frame.critFontSizeCheckbox
  checkbox:SetChecked(not configTable.critFontSize or false)
  if (configTable.critFontSize) then slider:SetValue(configTable.critFontSize) end
  ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedCritFontSize)

   -- Crit font opacity. 
  slider = frame.critFontOpacitySlider
  checkbox = frame.critFontOpacityCheckbox
  checkbox:SetChecked(not configTable.critFontAlpha or false)
  if (configTable.critFontAlpha) then slider:SetValue(configTable.critFontAlpha) end
  ToggleSliderInheritState(slider, checkbox:GetChecked(), configTable.inheritedCritFontAlpha)
 end 


 -- Store inherited settings. 
 frame.inheritedNormalFontName = configTable.inheritedNormalFontName
 frame.inheritedNormalOutlineIndex = configTable.inheritedNormalOutlineIndex
 frame.inheritedNormalFontSize = configTable.inheritedNormalFontSize
 frame.inheritedNormalFontAlpha = configTable.inheritedNormalFontAlpha
 frame.inheritedCritFontName = configTable.inheritedCritFontName
 frame.inheritedCritOutlineIndex = configTable.inheritedCritOutlineIndex
 frame.inheritedCritFontSize = configTable.inheritedCritFontSize
 frame.inheritedCritFontAlpha = configTable.inheritedCritFontAlpha
 
 
 -- Configure the frame. 
 frame.saveHandler = configTable.saveHandler
 frame.saveArg1 = configTable.saveArg1
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise() 

 UpdateFontPreviews() 
end


-------------------------------------------------------------------------------
-- Partial effects frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the popup partial effects frame.
-- ****************************************************************************
local function CreatePartialEffects()
 local frame = CreatePopup()

 -- Close button.
 local button = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
 button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)

 -- Color partial effects.
 local checkbox = MSBTControls.CreateCheckbox(frame)
 local objLocale = L.CHECKBOXES["colorPartialEffects"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -20)
 checkbox:SetClickHandler(
  function (this, isChecked)
   MSBTProfiles.SetOption(nil, "partialColoringDisabled", not isChecked)
  end
 )
 frame.colorCheckbox = checkbox


 -- Partial effects.
 local anchor = checkbox
 local colorswatch, editbox
 local maxWidth = 0
 for effectType in string.gmatch("crushing glancing absorb block resist overheal overkill", "[^%s]+") do
  colorswatch = MSBTControls.CreateColorswatch(frame)
  colorswatch:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == checkbox and 20 or 0, -10)
  colorswatch:SetColorChangedHandler(
   function (this)
    MSBTProfiles.SetOption(effectType, "colorR", this.r)
    MSBTProfiles.SetOption(effectType, "colorG", this.g)
    MSBTProfiles.SetOption(effectType, "colorB", this.b)
   end
  )

  checkbox = MSBTControls.CreateCheckbox(frame)
  objLocale = L.CHECKBOXES[effectType]
  checkbox:Configure(24, objLocale.label, objLocale.tooltip)
  checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
  checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(effectType, "disabled", not isChecked)
   end
  )
  
  if (checkbox:GetWidth() > maxWidth) then maxWidth = checkbox:GetWidth() end

  local tooltip = L.EDITBOXES["partialEffect"].tooltip
  if (effectType ~= "crushing" and effectType ~= "glancing") then tooltip = tooltip .. "\n\n" .. L.EVENT_CODES["PARTIAL_AMOUNT"] end
  editbox = MSBTControls.CreateEditbox(frame)
  editbox:Configure(130, nil, tooltip)
  editbox:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
  editbox:SetPoint("TOP", checkbox, "TOP", 0, 10)
  editbox:SetTextChangedHandler(
   function (this)
    MSBTProfiles.SetOption(effectType, "trailer", this:GetText())
   end
  )
  frame[effectType .. "Colorswatch"] = colorswatch
  frame[effectType .. "Checkbox"] = checkbox 
  frame[effectType .. "Editbox"] = editbox

  anchor = colorswatch
 end

 frame:SetWidth(maxWidth + 230)
 frame:SetHeight(260)

 return frame
end


-- ****************************************************************************
-- Shows the popup damage partial effects frame using the passed config.
-- ****************************************************************************
local function ShowPartialEffects(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end
 
 -- Create the frame if it hasn't already been.
 if (not popupFrames.partialEffectsFrame) then popupFrames.partialEffectsFrame = CreatePartialEffects() end

 -- Set parent.
 local frame = popupFrames.partialEffectsFrame
 ChangePopupParent(frame, configTable.parentFrame)
 
 -- Populate data.
 frame.colorCheckbox:SetChecked(not MSBTProfiles.currentProfile.partialColoringDisabled)
 
 local profileEntry
 for effectType in string.gmatch("crushing glancing absorb block resist overheal overkill", "[^%s]+") do
  profileEntry = MSBTProfiles.currentProfile[effectType]
  frame[effectType .. "Colorswatch"]:SetColor(profileEntry.colorR, profileEntry.colorG, profileEntry.colorB)
  frame[effectType .. "Checkbox"]:SetChecked(not profileEntry.disabled)
  frame[effectType .. "Editbox"]:SetText(profileEntry.trailer)
 end
 
 -- Configure the frame.
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Damage color frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the popup damage colors frame.
-- ****************************************************************************
local function CreateDamageColors()
 local frame = CreatePopup()
 frame:SetWidth(260)
 frame:SetHeight(260)

 -- Close button.
 local button = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
 button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)

 -- Color damage amounts.
 local checkbox = MSBTControls.CreateCheckbox(frame)
 local objLocale = L.CHECKBOXES["colorDamageAmounts"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -20)
 checkbox:SetClickHandler(
  function (this, isChecked)
   MSBTProfiles.SetOption(nil, "damageColoringDisabled", not isChecked)
  end
 )
 frame.colorCheckbox = checkbox


 -- Damage types.
 local anchor = checkbox
 local globalStringSchoolIndex = 0
 local colorswatch, fontString
 for damageType, profileKey in pairs(MSBTMain.damageColorProfileEntries) do
  colorswatch = MSBTControls.CreateColorswatch(frame)
  colorswatch:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == checkbox and 20 or 0, anchor == checkbox and -10 or -5)
  colorswatch:SetColorChangedHandler(
   function (this)
    MSBTProfiles.SetOption(profileKey, "colorR", this.r)
    MSBTProfiles.SetOption(profileKey, "colorG", this.g)
    MSBTProfiles.SetOption(profileKey, "colorB", this.b)
   end
  )
  checkbox = MSBTControls.CreateCheckbox(frame)
  objLocale = L.CHECKBOXES["colorDamageEntry"]
  checkbox:Configure(24, MSBTMain.damageTypeMap[damageType], objLocale.tooltip)
  checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
  checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(profileKey, "disabled", not isChecked)
   end
  )
  frame[profileKey .. "Colorswatch"] = colorswatch
  frame[profileKey .. "Checkbox"] = checkbox 
  
  anchor = colorswatch 
  globalStringSchoolIndex = globalStringSchoolIndex + 1
 end

 return frame
end


-- ****************************************************************************
-- Shows the popup damage type colors frame using the passed config.
-- ****************************************************************************
local function ShowDamageColors(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.damageColorsFrame) then popupFrames.damageColorsFrame = CreateDamageColors() end

 -- Set parent.
 local frame = popupFrames.damageColorsFrame
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate data.
 frame.colorCheckbox:SetChecked(not MSBTProfiles.currentProfile.damageColoringDisabled)

 local profileEntry
 for damageType, profileKey in pairs(MSBTMain.damageColorProfileEntries) do
  profileEntry = MSBTProfiles.currentProfile[profileKey]
  frame[profileKey .. "Colorswatch"]:SetColor(profileEntry.colorR, profileEntry.colorG, profileEntry.colorB)
  frame[profileKey .. "Checkbox"]:SetChecked(not profileEntry.disabled)
 end
 
 -- Configure the frame.
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Class color frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the popup class colors frame.
-- ****************************************************************************
local function CreateClassColors()
 local frame = CreatePopup()
 frame:SetWidth(260)
 frame:SetHeight(300)

 -- Close button.
 local button = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
 button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)

 -- Color class amounts.
 local checkbox = MSBTControls.CreateCheckbox(frame)
 local objLocale = L.CHECKBOXES["colorUnitNames"]
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -20)
 checkbox:SetClickHandler(
  function (this, isChecked)
   MSBTProfiles.SetOption(nil, "classColoringDisabled", not isChecked)
  end
 )
 frame.colorCheckbox = checkbox


 -- Classes.
 local anchor = checkbox
 local globalStringSchoolIndex = 0
 local colorswatch, fontString
 for class in string.gmatch("DEATHKNIGHT DRUID HUNTER MAGE MONK PALADIN PRIEST ROGUE SHAMAN WARLOCK WARRIOR DEMONHUNTER", "[^%s]+") do
  colorswatch = MSBTControls.CreateColorswatch(frame)
  colorswatch:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == checkbox and 20 or 0, anchor == checkbox and -10 or -5)
  colorswatch:SetColorChangedHandler(
   function (this)
    MSBTProfiles.SetOption(class, "colorR", this.r)
    MSBTProfiles.SetOption(class, "colorG", this.g)
    MSBTProfiles.SetOption(class, "colorB", this.b)
   end
  )
  checkbox = MSBTControls.CreateCheckbox(frame)
  objLocale = L.CHECKBOXES["colorClassEntry"]
  checkbox:Configure(24, CLASS_NAMES[class], objLocale.tooltip)
  checkbox:SetPoint("LEFT", colorswatch, "RIGHT", 5, 0)
  checkbox:SetClickHandler(
   function (this, isChecked)
    MSBTProfiles.SetOption(class, "disabled", not isChecked)
   end
  )
  frame[class .. "Colorswatch"] = colorswatch
  frame[class .. "Checkbox"] = checkbox 
  
  anchor = colorswatch 
 end

 return frame
end


-- ****************************************************************************
-- Shows the popup damage type colors frame using the passed config.
-- ****************************************************************************
local function ShowClassColors(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.classColorsFrame) then popupFrames.classColorsFrame = CreateClassColors() end

 -- Set parent.
 local frame = popupFrames.classColorsFrame
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate data.
 frame.colorCheckbox:SetChecked(not MSBTProfiles.currentProfile.classColoringDisabled)

 local profileEntry
 for class in string.gmatch("DEATHKNIGHT DRUID HUNTER MAGE MONK PALADIN PRIEST ROGUE SHAMAN WARLOCK WARRIOR DEMONHUNTER", "[^%s]+") do
  profileEntry = MSBTProfiles.currentProfile[class]
  frame[class .. "Colorswatch"]:SetColor(profileEntry.colorR, profileEntry.colorG, profileEntry.colorB)
  frame[class .. "Checkbox"]:SetChecked(not profileEntry.disabled)
 end
 
 -- Configure the frame.
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Scroll area config frame functions.
-------------------------------------------------------------------------------

-- **********************************************************************************
-- This function copies the current scroll area settings into the passed table key.
-- **********************************************************************************
local function CopyTempScrollAreaSettings(settingsTable)
 local frame = popupFrames.scrollAreaConfigFrame
 EraseTable(settingsTable)

 -- Get the original settings.
 local tempSettings
 for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
  settingsTable[saKey] = {}
  tempSettings = settingsTable[saKey]

  -- Normal.
  tempSettings.animationStyle = saSettings.animationStyle or DEFAULT_ANIMATION_STYLE
  tempSettings.direction = saSettings.direction
  tempSettings.behavior = saSettings.behavior
  tempSettings.textAlignIndex = saSettings.textAlignIndex or DEFAULT_TEXT_ALIGN_INDEX

  -- Sticky.
  tempSettings.stickyAnimationStyle = saSettings.stickyAnimationStyle or DEFAULT_STICKY_ANIMATION_STYLE
  tempSettings.stickyDirection = saSettings.stickyDirection
  tempSettings.stickyBehavior = saSettings.stickyBehavior
  tempSettings.stickyTextAlignIndex = saSettings.stickyTextAlignIndex or DEFAULT_TEXT_ALIGN_INDEX

  -- Positioning.
  tempSettings.scrollHeight = saSettings.scrollHeight or DEFAULT_SCROLL_HEIGHT
  tempSettings.scrollWidth = saSettings.scrollWidth or DEFAULT_SCROLL_WIDTH
  tempSettings.offsetX = saSettings.offsetX or 0
  tempSettings.offsetY = saSettings.offsetY or 0

  -- Speed.
  tempSettings.inheritedAnimationSpeed = MSBTProfiles.currentProfile.animationSpeed
  tempSettings.animationSpeed = saSettings.animationSpeed
  
  -- Icon.
  tempSettings.iconAlign = saSettings.iconAlign or DEFAULT_ICON_ALIGN
  tempSettings.skillIconsDisabled = saSettings.skillIconsDisabled
 end
end


-- ****************************************************************************
-- Changes the normal animation style to the passed value.
-- ****************************************************************************
local function ChangeAnimationStyle(styleKey)
 local frame = popupFrames.scrollAreaConfigFrame
 local styleSettings = MSBTAnimations.animationStyles[styleKey]
 local firstEntry, name, objLocale

 -- Normal direction.
 frame.directionDropdown:Clear()
 if (styleSettings.availableDirections) then
  for direction in string.gmatch(styleSettings.availableDirections, "[^;]+") do
   if (not firstEntry) then firstEntry = direction end
   objLocale = styleSettings.localizationTable
   name = objLocale and objLocale[direction] or L.ANIMATION_STYLE_DATA[direction] or direction
   frame.directionDropdown:AddItem(name, direction)
  end
  frame.directionDropdown:SetSelectedID(firstEntry)  
 else
  -- No available directions, so just add a normal entry.
  frame.directionDropdown:AddItem(L.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL")
  frame.directionDropdown:SetSelectedID("MSBT_NORMAL")
 end
 
 -- Normal behavior.
 firstEntry = nil
 frame.behaviorDropdown:Clear()
 if (styleSettings.availableBehaviors) then
  for behavior in string.gmatch(styleSettings.availableBehaviors, "[^;]+") do
   if (not firstEntry) then firstEntry = behavior end
   objLocale = styleSettings.localizationTable
   name = objLocale and objLocale[behavior] or L.ANIMATION_STYLE_DATA[behavior] or behavior
   frame.behaviorDropdown:AddItem(name, behavior)
  end
  frame.behaviorDropdown:SetSelectedID(firstEntry)  
 else
  -- No available behaviors, so just add a normal entry.
  frame.behaviorDropdown:AddItem(L.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL")
  frame.behaviorDropdown:SetSelectedID("MSBT_NORMAL")
 end
end


-- ****************************************************************************
-- Changes the sticky animation style to the passed value.
-- ****************************************************************************
local function ChangeStickyAnimationStyle(styleKey)
 local frame = popupFrames.scrollAreaConfigFrame
 local styleSettings = MSBTAnimations.stickyAnimationStyles[styleKey]
 local firstEntry, name, objLocale

 -- Sticky direction.
 frame.stickyDirectionDropdown:Clear()
 if (styleSettings.availableDirections) then
  for direction in string.gmatch(styleSettings.availableDirections, "[^;]+") do
   if (not firstEntry) then firstEntry = direction end
   objLocale = styleSettings.localizationTable
   name = objLocale and objLocale[direction] or L.ANIMATION_STYLE_DATA[direction] or direction
   frame.stickyDirectionDropdown:AddItem(name, direction)
  end
  frame.stickyDirectionDropdown:SetSelectedID(firstEntry)  
 else
  -- No available directions, so just add a normal entry.
  frame.stickyDirectionDropdown:AddItem(L.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL")
  frame.stickyDirectionDropdown:SetSelectedID("MSBT_NORMAL")
 end
 
 -- Sticky behavior.
 firstEntry = nil
 frame.stickyBehaviorDropdown:Clear()
 if (styleSettings.availableBehaviors) then
  for behavior in string.gmatch(styleSettings.availableBehaviors, "[^;]+") do
   if (not firstEntry) then firstEntry = behavior end
   objLocale = styleSettings.localizationTable
   name = objLocale and objLocale[behavior] or L.ANIMATION_STYLE_DATA[behavior] or behavior
   frame.stickyBehaviorDropdown:AddItem(name, behavior)
  end
  frame.stickyBehaviorDropdown:SetSelectedID(firstEntry)  
 else
  -- No available behaviors, so just add a normal entry.
  frame.stickyBehaviorDropdown:AddItem(L.ANIMATION_STYLE_DATA["Normal"], "MSBT_NORMAL")
  frame.stickyBehaviorDropdown:SetSelectedID("MSBT_NORMAL")
 end
end


-- ****************************************************************************
-- Changes the scroll area to configure to the passed value.
-- ****************************************************************************
local function ChangeConfigScrollArea(scrollArea)
 local frame = popupFrames.scrollAreaConfigFrame
 frame.currentScrollArea = scrollArea
 local saSettings = frame.previewSettings[scrollArea]
 local name, objLocale

 -- Normal animation style.
 frame.animationStyleDropdown:Clear()
 for styleKey, settings in pairs(MSBTAnimations.animationStyles) do 
  objLocale = settings.localizationTable
  name = objLocale and objLocale[styleKey] or L.ANIMATION_STYLE_DATA[styleKey] or styleKey
  frame.animationStyleDropdown:AddItem(name, styleKey)
 end
 frame.animationStyleDropdown:SetSelectedID(saSettings.animationStyle)
 ChangeAnimationStyle(saSettings.animationStyle)

 -- Normal direction, behavior, and text align.
 if (saSettings.direction) then frame.directionDropdown:SetSelectedID(saSettings.direction) end
 if (saSettings.behavior) then frame.behaviorDropdown:SetSelectedID(saSettings.behavior) end
 frame.textAlignDropdown:SetSelectedID(saSettings.textAlignIndex)


 -- Sticky animation style.
 frame.stickyAnimationStyleDropdown:Clear()
 for styleKey, settings in pairs(MSBTAnimations.stickyAnimationStyles) do 
  objLocale = settings.localizationTable
  name = objLocale and objLocale[styleKey] or L.ANIMATION_STYLE_DATA[styleKey] or styleKey
  frame.stickyAnimationStyleDropdown:AddItem(name, styleKey)
 end
 frame.stickyAnimationStyleDropdown:SetSelectedID(saSettings.stickyAnimationStyle)
 ChangeStickyAnimationStyle(saSettings.stickyAnimationStyle)

 -- Sticky direction, behavior, and text align.
 if (saSettings.stickyDirection) then frame.stickyDirectionDropdown:SetSelectedID(saSettings.stickyDirection) end
 if (saSettings.stickyBehavior) then frame.stickyBehaviorDropdown:SetSelectedID(saSettings.stickyBehavior) end
 frame.stickyTextAlignDropdown:SetSelectedID(saSettings.stickyTextAlignIndex)

 -- Scroll height and width.
 frame.scrollHeightSlider:SetValue(saSettings.scrollHeight)
 frame.scrollWidthSlider:SetValue(saSettings.scrollWidth)

 -- Animation speed
 local isSpeedInherited = not saSettings.animationSpeed or saSettings.animationSpeed == saSettings.inheritedAnimationSpeed
 frame.animationSpeedCheckbox:SetChecked(isSpeedInherited)
 if (saSettings.animationSpeed) then frame.animationSpeedSlider:SetValue(saSettings.animationSpeed) end
 ToggleSliderInheritState(frame.animationSpeedSlider, isSpeedInherited , saSettings.inheritedAnimationSpeed)
 
 -- X and Y offset.
 frame.xOffsetEditbox:SetText(saSettings.offsetX)
 frame.yOffsetEditbox:SetText(saSettings.offsetY)
 
 -- Icon.
 frame.iconAlignDropdown:SetSelectedID(saSettings.iconAlign)
 frame.iconsDisabledCheckbox:SetChecked(saSettings.skillIconsDisabled)
 
 -- Reset the backdrop color of all the scroll area mover frames to grey.
 for _, moverFrame in pairs(frame.moverFrames) do
  moverFrame:SetBackdropColor(0.8, 0.8, 0.8, 1.0)
 end
 
 -- Set the selected scroll area mover frame to red and raise it.
 frame.moverFrames[scrollArea]:SetBackdropColor(0.5, 0.05, 0.05, 1.0)
 frame.moverFrames[scrollArea]:Raise()
end


-- **********************************************************************************
-- This function repositions the mover frame for the passed scroll area.
-- **********************************************************************************
local function RepositionScrollAreaMoverFrame(scrollArea)
 local configFrame = popupFrames.scrollAreaConfigFrame
 local frame = configFrame.moverFrames[scrollArea]
 local saSettings = configFrame.previewSettings[scrollArea]

 frame:ClearAllPoints()
 frame:SetPoint("BOTTOMLEFT", UIParent, "CENTER", saSettings.offsetX, saSettings.offsetY)
 frame:SetHeight(saSettings.scrollHeight)
 frame:SetWidth(saSettings.scrollWidth)
 frame.fontString:SetText(MSBTAnimations.scrollAreas[scrollArea].name .. " (" .. saSettings.offsetX .. ", " .. saSettings.offsetY .. ")")
 frame:Show()
end


-- **********************************************************************************
-- Save the coordinates of a scroll area mover.
-- **********************************************************************************
local function SaveScrollAreaMoverCoordinates(frame)
 -- Get the UIParent center x and y coords.
 local uiParentX, uiParentY = UIParent:GetCenter()
 local xOffset = math.ceil(frame:GetLeft() - uiParentX)
 local yOffset = math.ceil(frame:GetBottom() - uiParentY)
 
 -- Save the x and y offsets.
 local configFrame = popupFrames.scrollAreaConfigFrame
 configFrame.previewSettings[frame.scrollArea].offsetX = xOffset
 configFrame.previewSettings[frame.scrollArea].offsetY = yOffset

 -- Populate the x and y offset editboxes if the moved frame is the selected one.
 if (frame.scrollArea == configFrame.scrollAreaDropdown:GetSelectedID()) then
  configFrame.xOffsetEditbox:SetText(xOffset)
  configFrame.yOffsetEditbox:SetText(yOffset)
 end

 -- Reposition the scroll area mover frames to update the coordinates.
 RepositionScrollAreaMoverFrame(frame.scrollArea)
end


-- **********************************************************************************
-- Called when a mouse button is pressed on a mover frame.
-- **********************************************************************************
local function MoverFrameOnMouseDown(this, button)
 if (button == "LeftButton") then this:StartMoving() end 
end


-- **********************************************************************************
-- Called when a mouse button is released on a mover frame.
-- **********************************************************************************
local function MoverFrameOnMouseUp(this)
 this:StopMovingOrSizing()
 SaveScrollAreaMoverCoordinates(this)

 local configFrame = popupFrames.scrollAreaConfigFrame
 if (this.scrollArea ~= configFrame.scrollAreaDropdown:GetSelectedID()) then
  configFrame.scrollAreaDropdown:SetSelectedID(this.scrollArea)
  ChangeConfigScrollArea(this.scrollArea)
 end
end


-- **********************************************************************************
-- This function creates a scroll area mover frame for the passed scroll area if
-- it hasn't already been
-- **********************************************************************************
local function CreateScrollAreaMoverFrame(scrollArea)
 local moverFrames = popupFrames.scrollAreaConfigFrame.moverFrames
 
 if (not moverFrames[scrollArea]) then
  local frame = CreateFrame("FRAME", nil, UIParent)
  frame:Hide()
  frame:SetMovable(true)
  frame:EnableMouse(true)
  frame:SetFrameStrata("HIGH")
  --frame:SetToplevel(true)
  frame:SetClampedToScreen(true)
  frame:SetBackdrop(moverBackdrop)
  frame:SetScript("OnMouseDown", MoverFrameOnMouseDown)
  frame:SetScript("OnMouseUp", MoverFrameOnMouseUp)
  
  local fontString = frame:CreateFontString(nil, "OVERLAY")
  local fontPath = "Fonts\\ARIALN.TTF"
  if (GetLocale() == "koKR") then fontPath = "Fonts\\2002.TTF" end
  fontString:SetFont(fontPath, 12)
  fontString:SetPoint("CENTER")
  frame.fontString = fontString

  frame.scrollArea = scrollArea
  moverFrames[scrollArea] = frame
 end
end


-- **********************************************************************************
-- Save the passed table to the scroll area settings.
-- **********************************************************************************
local function SaveScrollAreaSettings(settingsTable)
 local frame = popupFrames.scrollAreaConfigFrame
 
 -- Save the settings in the passed table to the current profile.
 for saKey, saSettings in pairs(settingsTable) do
  -- Normal.
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "animationStyle", saSettings.animationStyle, DEFAULT_ANIMATION_STYLE)
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "direction", saSettings.direction, "MSBT_NORMAL")
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "behavior", saSettings.behavior, "MSBT_NORMAL")  
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "textAlignIndex", saSettings.textAlignIndex, DEFAULT_TEXT_ALIGN_INDEX)
  
  -- Sticky.
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyAnimationStyle", saSettings.stickyAnimationStyle, DEFAULT_STICKY_ANIMATION_STYLE)
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyDirection", saSettings.stickyDirection, "MSBT_NORMAL")
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyBehavior", saSettings.stickyBehavior, "MSBT_NORMAL")
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "stickyTextAlignIndex", saSettings.stickyTextAlignIndex, DEFAULT_TEXT_ALIGN_INDEX)
  
  -- Position.  
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "scrollHeight", saSettings.scrollHeight, DEFAULT_SCROLL_HEIGHT)
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "scrollWidth", saSettings.scrollWidth, DEFAULT_SCROLL_WIDTH)
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "offsetX", saSettings.offsetX)
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "offsetY", saSettings.offsetY)
  
  -- Animation speed.
  local animationSpeed = saSettings.animationSpeed
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "animationSpeed", animationSpeed, saSettings.inheritedAnimationSpeed)
  
  -- Icon.
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "iconAlign", saSettings.iconAlign, DEFAULT_ICON_ALIGN)
  MSBTProfiles.SetOption("scrollAreas." .. saKey, "skillIconsDisabled", saSettings.skillIconsDisabled)
 end
 MSBTAnimations.UpdateScrollAreas()
end


-- ****************************************************************************
-- Creates the popup scroll areas config frames.
-- ****************************************************************************
local function CreateScrollAreaConfig()
 local frame = CreatePopup()
 frame:SetWidth(320)
 frame:SetHeight(575)
 frame:SetPoint("RIGHT")
 frame:SetScript("OnHide",
  function (this)
   for _, moverFrame in pairs(this.moverFrames) do
    moverFrame:Hide()
   end
   MSBTOptions.Main.ShowMainFrame()
  end
 )
 
 -- Scroll area dropdown.
 local dropdown =  MSBTControls.CreateDropdown(frame)
 local objLocale = L.DROPDOWNS["scrollArea"]
 dropdown:Configure(200, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOP", frame, "TOP", 0, -20)
 dropdown:SetChangeHandler(
  function (this, id)
   ChangeConfigScrollArea(id)
  end
 )
 frame.scrollAreaDropdown = dropdown

 
 -- Top horizontal bar.
 local texture = frame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
 texture:SetHeight(4)
 texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -70)
 texture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -70)
 texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)

 
 -- Normal animation style dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame)
 objLocale = L.DROPDOWNS["animationStyle"]
 dropdown:Configure(135, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", texture, "BOTTOMLEFT", 5, -15)
 dropdown:SetChangeHandler(
  function (this, id)
   ChangeAnimationStyle(id)
   frame.previewSettings[frame.currentScrollArea].animationStyle = id
   frame.previewSettings[frame.currentScrollArea].direction = frame.directionDropdown:GetSelectedID()
   frame.previewSettings[frame.currentScrollArea].behavior = frame.behaviorDropdown:GetSelectedID()
  end
 )
 frame.animationStyleDropdown = dropdown

 -- Sticky animation style dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame)
 objLocale = L.DROPDOWNS["stickyAnimationStyle"]
 dropdown:Configure(135, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("LEFT", frame.animationStyleDropdown, "RIGHT", 15, 0)
 dropdown:SetChangeHandler(
  function (this, id)
   ChangeStickyAnimationStyle(id)
   frame.previewSettings[frame.currentScrollArea].stickyAnimationStyle = id
   frame.previewSettings[frame.currentScrollArea].stickyDirection = frame.stickyDirectionDropdown:GetSelectedID()
   frame.previewSettings[frame.currentScrollArea].stickyBehavior = frame.stickyBehaviorDropdown:GetSelectedID()
  end
 )
 frame.stickyAnimationStyleDropdown = dropdown

 -- Normal direction dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame)
 objLocale = L.DROPDOWNS["direction"]
 dropdown:Configure(135,objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", frame.animationStyleDropdown, "BOTTOMLEFT", 0, -10)
 dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.currentScrollArea].direction = id
  end
 )
 frame.directionDropdown = dropdown

 -- Sticky direction dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame)
 objLocale = L.DROPDOWNS["direction"]
 dropdown:Configure(135, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", frame.stickyAnimationStyleDropdown, "BOTTOMLEFT", 0, -10)
 dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.scrollAreaDropdown:GetSelectedID()].stickyDirection = id
  end
 )
 frame.stickyDirectionDropdown = dropdown

 -- Normal behavior dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame)
 objLocale = L.DROPDOWNS["behavior"]
 dropdown:Configure(135, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", frame.directionDropdown, "BOTTOMLEFT", 0, -10)
  dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.currentScrollArea].behavior = id
  end
 )
 frame.behaviorDropdown = dropdown

 -- Sticky behavior dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame)
 objLocale = L.DROPDOWNS["behavior"]
 dropdown:Configure(135, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", frame.stickyDirectionDropdown, "BOTTOMLEFT", 0, -10)
 dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.currentScrollArea].stickyBehavior = id
  end
 )
 frame.stickyBehaviorDropdown = dropdown

 -- Normal text align dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame)
 objLocale = L.DROPDOWNS["textAlign"]
 dropdown:Configure(135, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", frame.behaviorDropdown, "BOTTOMLEFT", 0, -10)
 dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.currentScrollArea].textAlignIndex = id
  end
 )
 for index, anchorPoint in ipairs(L.TEXT_ALIGNS) do
  dropdown:AddItem(anchorPoint, index)
 end
 frame.textAlignDropdown = dropdown

 -- Sticky text align dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame)
 objLocale = L.DROPDOWNS["textAlign"]
 dropdown:Configure(135, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", frame.stickyBehaviorDropdown, "BOTTOMLEFT", 0, -10)
 dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.currentScrollArea].stickyTextAlignIndex = id
  end
 )
 for index, anchorPoint in ipairs(L.TEXT_ALIGNS) do
  dropdown:AddItem(anchorPoint, index)
 end
 frame.stickyTextAlignDropdown = dropdown

 
 -- Middle horizontal bar.
 texture = frame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
 texture:SetHeight(4)
 texture:SetPoint("TOPLEFT", frame, "TOPLEFT", 10, -295)
 texture:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -10, -295)
 texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)

 
 -- Scroll height slider.
 local slider = MSBTControls.CreateSlider(frame)
 objLocale = L.SLIDERS["scrollHeight"] 
 slider:Configure(135, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", texture, "BOTTOMLEFT", 5, -15)
 slider:SetMinMaxValues(50, 600)
 slider:SetValueStep(5)
 slider:SetValueChangedHandler(
  function(this, value)
   frame.previewSettings[frame.currentScrollArea].scrollHeight = value
   RepositionScrollAreaMoverFrame(frame.currentScrollArea)
  end
 )
 frame.scrollHeightSlider = slider

 -- Scroll width slider.
 slider = MSBTControls.CreateSlider(frame)
 objLocale = L.SLIDERS["scrollWidth"] 
 slider:Configure(135, objLocale.label, objLocale.tooltip)
 slider:SetPoint("LEFT", frame.scrollHeightSlider, "RIGHT", 15, 0)
 slider:SetMinMaxValues(10, 800)
 slider:SetValueStep(10)
 slider:SetValueChangedHandler(
  function(this, value)
   frame.previewSettings[frame.currentScrollArea].scrollWidth = value
   RepositionScrollAreaMoverFrame(frame.currentScrollArea)
  end
 )
 frame.scrollWidthSlider = slider

 -- Animation speed slider.
 slider = MSBTControls.CreateSlider(frame)
 objLocale = L.SLIDERS["scrollAnimationSpeed"] 
 slider:Configure(135, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", frame.scrollHeightSlider, "BOTTOMLEFT", 0, -10)
 slider:SetMinMaxValues(20, 250)
 slider:SetValueStep(10)
 slider:SetValueChangedHandler(
  function(this, value)
   frame.previewSettings[frame.currentScrollArea].animationSpeed = value
  end
 )
 frame.animationSpeedSlider = slider
 
 -- Inherit animation speed checkbox.
 local checkbox = MSBTControls.CreateCheckbox(frame)
 objLocale = L.CHECKBOXES["inheritField"] 
 checkbox:Configure(20, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("BOTTOMLEFT", frame.animationSpeedSlider, "BOTTOMRIGHT", 10, 5)
 checkbox:SetClickHandler(
  function (this, isChecked)
   ToggleSliderInheritState(frame.animationSpeedSlider, isChecked, frame.previewSettings[frame.currentScrollArea].inheritedAnimationSpeed)
  end
 )
 frame.animationSpeedCheckbox = checkbox 


 -- X offset editbox.
 local editbox = MSBTControls.CreateEditbox(frame)
 objLocale = L.EDITBOXES["xOffset"] 
 editbox:Configure(135, objLocale.label, objLocale.tooltip)
 editbox:SetPoint("TOPLEFT", frame.animationSpeedSlider, "BOTTOMLEFT", 0, -10)
 editbox:SetTextChangedHandler(
  function (this)
   local newOffset = tonumber(this:GetText())
   if (newOffset) then
    frame.previewSettings[frame.currentScrollArea].offsetX = newOffset
    RepositionScrollAreaMoverFrame(frame.currentScrollArea)
   end
  end
 )
 frame.xOffsetEditbox = editbox


 -- Y offset editbox.
 editbox = MSBTControls.CreateEditbox(frame)
 objLocale = L.EDITBOXES["yOffset"] 
 editbox:Configure(135, objLocale.label, objLocale.tooltip)
 editbox:SetPoint("LEFT", frame.xOffsetEditbox, "RIGHT", 15, 0)
 editbox:SetTextChangedHandler(
  function (this)
   local newOffset = tonumber(this:GetText())
   if (newOffset) then
    frame.previewSettings[frame.currentScrollArea].offsetY = newOffset
    RepositionScrollAreaMoverFrame(frame.currentScrollArea)
   end
  end
 )
 frame.yOffsetEditbox = editbox


 -- Icon align dropdown.
 dropdown =  MSBTControls.CreateDropdown(frame)
 objLocale = L.DROPDOWNS["iconAlign"]
 dropdown:Configure(135, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", frame.xOffsetEditbox, "BOTTOMLEFT", 0, -10)
 dropdown:SetChangeHandler(
  function (this, id)
   frame.previewSettings[frame.currentScrollArea].iconAlign = id
  end
 )
 dropdown:AddItem(L.TEXT_ALIGNS[1], "Left")
 dropdown:AddItem(L.TEXT_ALIGNS[3], "Right")
 frame.iconAlignDropdown = dropdown

 -- Icons disabled checkbox.
 checkbox = MSBTControls.CreateCheckbox(frame)
 objLocale = L.CHECKBOXES["hideSkillIcons"]
 checkbox:Configure(20, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("LEFT", frame.iconAlignDropdown, "RIGHT", 10, -5)
 checkbox:SetClickHandler(
  function (this, isChecked)
   frame.previewSettings[frame.currentScrollArea].skillIconsDisabled = isChecked
  end
 )
 frame.iconsDisabledCheckbox = checkbox 
 
 -- Bottom horizontal bar.
 texture = frame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\SkillFrame-BotLeft")
 texture:SetHeight(4)
 texture:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 10, 80)
 texture:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", -10, 80)
 texture:SetTexCoord(0.078125, 1, 0.59765625, 0.61328125)


 -- Preview button.
 local button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["scrollAreasPreview"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOM", frame, "BOTTOM", 0, 50)
 button:SetClickHandler(
  function (this)
   SaveScrollAreaSettings(frame.previewSettings)
   local name
   for saKey in pairs(frame.previewSettings) do
    name = MSBTAnimations.scrollAreas[saKey].name
    MikSBT.DisplayMessage(name, saKey, nil, 255, 0, 0, nil, nil, nil, PREVIEW_ICON_PATH)
    MikSBT.DisplayMessage(name, saKey, nil, 255, 255, 255, nil, nil, nil, PREVIEW_ICON_PATH)
    MikSBT.DisplayMessage(name, saKey, true, 0, 0, 255, 28, nil, nil, PREVIEW_ICON_PATH)
   end
  end
 )
 
 -- Save button.
 local button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericSave"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20)
 button:SetClickHandler(
  function (this)
   SaveScrollAreaSettings(frame.previewSettings)
   frame:Hide()
  end
 )

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericCancel"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20)
 button:SetClickHandler(
  function (this)
   SaveScrollAreaSettings(frame.originalSettings)
   frame:Hide()
  end
 )
 
 -- Track internal values.
 frame.moverFrames = {}
 frame.originalSettings = {}
 frame.previewSettings = {}
 
 -- Give the frame a global name.
 _G["MSBTScrollAreasConfigFrame"] = frame
 return frame
end


-- ****************************************************************************
-- Shows the popup scroll area config screen.
-- ****************************************************************************
local function ShowScrollAreaConfig()
 -- Create the frame if it hasn't already been.
 if (not popupFrames.scrollAreaConfigFrame) then popupFrames.scrollAreaConfigFrame = CreateScrollAreaConfig() end
 
 local frame = popupFrames.scrollAreaConfigFrame

 -- Backup the original settings for previewing and cancelling.
 CopyTempScrollAreaSettings(frame.originalSettings)
 CopyTempScrollAreaSettings(frame.previewSettings)
 
 -- Populate the scroll areas and setup the mover frames. 
 frame.scrollAreaDropdown:Clear()
 for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
  frame.scrollAreaDropdown:AddItem(saSettings.name, saKey)
  
  -- Create and reposition the scroll area mover frames.
  CreateScrollAreaMoverFrame(saKey)
  RepositionScrollAreaMoverFrame(saKey)
 end
 frame.scrollAreaDropdown:Sort()
 frame.currentScrollArea = "Incoming"
 frame.scrollAreaDropdown:SetSelectedID(frame.currentScrollArea)
 ChangeConfigScrollArea(frame.currentScrollArea)
 
 frame:Show()
end


-------------------------------------------------------------------------------
-- Scroll area selection frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the popup scroll area selection frame.
-- ****************************************************************************
local function CreateScrollAreaSelection()
 local frame = CreatePopup()
 frame:SetWidth(350)
 frame:SetHeight(150)
 
 -- Title text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOP", frame, "TOP", 0, -20)
 frame.titleFontString = fontString

 
 -- Scroll area dropdown.
 local dropdown =  MSBTControls.CreateDropdown(frame)
 local objLocale = L.DROPDOWNS["outputScrollArea"]
 dropdown:Configure(150, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -45)
 frame.scrollAreaDropdown = dropdown
 
 
 -- Okay button.
 local button = MSBTControls.CreateOptionButton(frame)
 local objLocale = L.BUTTONS["inputOkay"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20)
 button:SetClickHandler(
  function (this)
   frame:Hide()   
   if (frame.saveHandler) then frame.saveHandler(frame.scrollAreaDropdown:GetSelectedID(), frame.saveArg1) end
  end
 )
 frame.okayButton = button

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["inputCancel"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20)
 button:SetClickHandler(
  function (this)
   frame:Hide()
  end
 )
 
 return frame
end


-- ****************************************************************************
-- Shows the popup scroll area selection frame using the passed config.
-- ****************************************************************************
local function ShowScrollAreaSelection(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.scrollAreaSelectionFrame) then popupFrames.scrollAreaSelectionFrame = CreateScrollAreaSelection() end
 
 -- Set parent.
 local frame = popupFrames.scrollAreaSelectionFrame
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate data.
 frame.titleFontString:SetText(configTable.title)
 
 -- Scroll areas. 
 frame.scrollAreaDropdown:Clear()
 for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
  frame.scrollAreaDropdown:AddItem(saSettings.name, saKey)
 end
 frame.scrollAreaDropdown:Sort()
 frame.scrollAreaDropdown:SetSelectedID("Incoming")


 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler
 frame.saveArg1 = configTable.saveArg1
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Event frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Populates the available sounds for the event along with the passed custom
-- sound file.
-- ****************************************************************************
local function PopulateEventSounds(selectedSound)
 local controls = popupFrames.eventFrame.controls
 
 local isCustomSound = selectedSound and true
 controls.soundDropdown:Clear()
 for soundName in pairs(sounds) do
  if (soundName ~= NONE) then controls.soundDropdown:AddItem(L.SOUNDS[soundName] or soundName, soundName) end
  if (soundName == selectedSound) then isCustomSound = nil end
 end
 controls.soundDropdown:AddItem(NONE, "")
 controls.soundDropdown:Sort()
 if (isCustomSound) then controls.soundDropdown:AddItem(selectedSound, selectedSound) end
 controls.soundDropdown:SetSelectedID(selectedSound or "")
end


-- ****************************************************************************
-- Enables the controls on the event popup.
-- ****************************************************************************
local function EnableEventControls()
 for name, frame in pairs(popupFrames.eventFrame.controls) do
  if (frame.Enable) then frame:Enable() end
 end
end


-- ****************************************************************************
-- Validates if the passed skill name does not already exist and is valid.
-- ****************************************************************************
local function ValidateSoundFileName(fileName)
 if (not string.find(fileName, ".mp3") and not string.find(fileName, ".ogg")) then
  return L.MSG_INVALID_SOUND_FILE
 end
end


-- ****************************************************************************
-- Adds a custom sound file to for the event.
-- ****************************************************************************
local function AddCustomSoundFile(settings)
 PopulateEventSounds(settings.inputText)
end


-- ****************************************************************************
-- Creates the popup event settings frame.
-- ****************************************************************************
local function CreateEvent()
 local frame = CreatePopup()
 frame:SetWidth(320)
 frame:SetHeight(370)
 frame.controls = {}
 local controls = frame.controls

 -- Title text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOP", frame, "TOP", 0, -20)
 frame.titleFontString = fontString

 -- Scroll area dropdown.
 local dropdown =  MSBTControls.CreateDropdown(frame)
 local objLocale = L.DROPDOWNS["outputScrollArea"]
 dropdown:Configure(150, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -60)
 controls.scrollAreaDropdown = dropdown

 -- Output message editbox.
 local editbox = MSBTControls.CreateEditbox(frame)
 local objLocale = L.EDITBOXES["eventMessage"]
 editbox:Configure(250, objLocale.label, nil)
 editbox:SetPoint("TOPLEFT", controls.scrollAreaDropdown, "BOTTOMLEFT", 0, -20)
 controls.messageEditbox = editbox

 -- Sound dropdown. 
 local dropdown =  MSBTControls.CreateDropdown(frame)
 objLocale = L.DROPDOWNS["sound"]
 dropdown:Configure(150, objLocale.label, objLocale.tooltip)
 dropdown:SetPoint("TOPLEFT", controls.messageEditbox, "BOTTOMLEFT", 0, -20)
 controls.soundDropdown = dropdown

 -- Custom sound file button.
 local button = MSBTControls.CreateIconButton(frame, "Configure")
 local objLocale = L.BUTTONS["customSound"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("LEFT", controls.soundDropdown, "RIGHT", 10, -5)
 button:SetClickHandler(
  function (this)
   local objLocale = L.EDITBOXES["soundFile"]
   EraseTable(tempConfig)
   tempConfig.editboxLabel = objLocale.label
   tempConfig.editboxTooltip = objLocale.tooltip
   tempConfig.parentFrame = frame
   tempConfig.anchorFrame = this
   tempConfig.anchorPoint = "BOTTOMRIGHT"
   tempConfig.relativePoint = "TOPRIGHT"
   tempConfig.validateHandler = ValidateSoundFileName
   tempConfig.saveHandler = AddCustomSoundFile
   tempConfig.hideHandler = EnableEventControls
   DisableControls(controls)
   ShowInput(tempConfig)
  end
 )
 controls[#controls+1] = button

 -- Play sound button.
 local button = MSBTControls.CreateOptionButton(frame)
 local objLocale = L.BUTTONS["playSound"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("LEFT", controls[#controls], "RIGHT", 10, 0)
 button:SetClickHandler(
  function (this)
   local soundFile = controls.soundDropdown:GetSelectedID()
   for soundName, soundPath in MikSBT.IterateSounds() do
    if (soundName == soundFile) then soundFile = soundPath end
   end
   soundFile = string.find(soundFile, "\\", nil, 1) and soundFile or DEFAULT_SOUND_PATH .. soundFile
   PlaySoundFile(soundFile, "Master")
  end
 )
 controls[#controls+1] = button

 -- Always sticky checkbox.
 local checkbox = MSBTControls.CreateCheckbox(frame)
 objLocale = L.CHECKBOXES["stickyEvent"] 
 checkbox:Configure(28, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", controls.soundDropdown, "BOTTOMLEFT", 0, -20)
 controls.stickyCheckbox = checkbox 

 
 -- Icon skill editbox.
 editbox = MSBTControls.CreateEditbox(frame)
 local objLocale = L.EDITBOXES["iconSkill"]
 editbox:Configure(250, objLocale.label, objLocale.tooltip)
 editbox:SetPoint("TOPLEFT", controls.stickyCheckbox, "BOTTOMLEFT", 0, -20)
 controls.iconSkillEditbox = editbox



 -- Save button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericSave"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20)
 button:SetClickHandler(
  function (this)
   EraseTable(returnSettings)
   returnSettings.scrollArea = controls.scrollAreaDropdown:GetSelectedID()
   returnSettings.message = controls.messageEditbox:GetText()
   returnSettings.soundFile = controls.soundDropdown:GetSelectedID()
   returnSettings.alwaysSticky = controls.stickyCheckbox:GetChecked()
   returnSettings.iconSkill = controls.iconSkillEditbox:GetText()
   frame:Hide()
   if (frame.saveHandler) then frame.saveHandler(returnSettings, frame.saveArg1) end
  end
 )
 controls[#controls+1] = button

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericCancel"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20)
 button:SetClickHandler(
  function (this)
   frame:Hide()
  end
 )
 controls[#controls+1] = button

 return frame
end


-- ****************************************************************************
-- Shows the popup event settings frame using the passed config.
-- ****************************************************************************
local function ShowEvent(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.eventFrame) then popupFrames.eventFrame = CreateEvent() end
 
 -- Set parent.
 local frame = popupFrames.eventFrame
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate data.
 frame.titleFontString:SetText(configTable.title)

 local controls = frame.controls
 controls.scrollAreaDropdown:Clear()
 for saKey, saSettings in pairs(MSBTAnimations.scrollAreas) do
  controls.scrollAreaDropdown:AddItem(saSettings.name, saKey)
 end
 controls.scrollAreaDropdown:Sort()
 controls.scrollAreaDropdown:SetSelectedID(configTable.scrollArea)

 local objLocale = L.EDITBOXES["eventMessage"]
 controls.messageEditbox:SetText(configTable.message)
 controls.messageEditbox:SetTooltip(objLocale.tooltip .. "\n\n" .. (configTable.codes or ""))
 PopulateEventSounds(configTable.soundFile)
 controls.stickyCheckbox:SetChecked(configTable.alwaysSticky)
 controls.iconSkillEditbox:SetText(configTable.iconSkill)


 -- Show / hide always sticky checkbox depending on if the event is a crit or not.
 if (configTable.isCrit) then controls.stickyCheckbox:Hide() else controls.stickyCheckbox:Show() end

 -- Show / hide icon skill editbox.
 if (configTable.showIconSkillEditbox) then
  frame:SetHeight(370)
  controls.iconSkillEditbox:Show()
 else
  controls.iconSkillEditbox:Hide()
  frame:SetHeight(310)
 end
 
 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler
 frame.saveArg1 = configTable.saveArg1
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Trigger classes frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates the popup classes frame.
-- ****************************************************************************
local function CreateClasses()
 local frame = CreatePopup()
 frame:SetWidth(270)
 frame:SetHeight(340)
 frame.classCheckboxes = {}
 local classCheckboxes = frame.classCheckboxes

 -- Close button.
 local button = CreateFrame("Button", nil, frame, "UIPanelCloseButton")
 button:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -2, -2)
 
 -- All classes checkbox.
 local checkbox = MSBTControls.CreateCheckbox(frame)
 local objLocale = L.CHECKBOXES["allClasses"] 
 checkbox:Configure(24, objLocale.label, objLocale.tooltip)
 checkbox:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -40)
 checkbox:SetClickHandler(
  function (this, isChecked)
   frame.classes["ALL"] = isChecked and true or nil
   if (isChecked) then
    for name, checkFrame in pairs(frame.classCheckboxes) do
     checkFrame:SetChecked(true)
     checkFrame:Disable()
    end
   else
    for name, checkFrame in pairs(classCheckboxes) do
     checkFrame:Enable()
     checkFrame:SetChecked(frame.classes[checkFrame.associatedClass])
    end
   end
   if (frame.updateHandler) then frame.updateHandler() end
  end
 )
 frame.allClassesCheckbox = checkbox 

 local anchor = checkbox
 for class in string.gmatch("DEATHKNIGHT DRUID HUNTER MAGE MONK PALADIN PRIEST ROGUE SHAMAN WARLOCK WARRIOR", "[^ ]+") do
  checkbox = MSBTControls.CreateCheckbox(frame)
  checkbox:Configure(24, CLASS_NAMES[class], nil)
  checkbox:SetPoint("TOPLEFT", anchor, "BOTTOMLEFT", anchor == frame.allClassesCheckbox and 20 or 0, anchor == frame.allClassesCheckbox and -10 or 0)
  checkbox:SetClickHandler(
   function (this, isChecked)
    frame.classes[this.associatedClass] = isChecked and true or nil
    if (frame.updateHandler) then frame.updateHandler() end
   end
  )
  checkbox.associatedClass = class
  anchor = checkbox
  classCheckboxes[class .. "Checkbox"] = checkbox
 end 

 return frame
end


-- ****************************************************************************
-- Shows the popup classes frame.
-- ****************************************************************************
local function ShowClasses(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame or not configTable.classes) then return end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.classesFrame) then popupFrames.classesFrame = CreateClasses() end
 
 -- Set parent.
 local frame = popupFrames.classesFrame
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate data.
 if (configTable.classes["ALL"]) then
  frame.allClassesCheckbox:SetChecked(true)
  for name, checkFrame in pairs(frame.classCheckboxes) do
   checkFrame:SetChecked(true)
   checkFrame:Disable()
  end  
 else
  frame.allClassesCheckbox:SetChecked(false)
  for name, checkFrame in pairs(frame.classCheckboxes) do
   checkFrame:Enable()
   checkFrame:SetChecked(configTable.classes[checkFrame.associatedClass])
  end
 end
 

 -- Configure the frame.
 frame.classes = configTable.classes
 frame.updateHandler = configTable.updateHandler
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Trigger condition frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when one of the condition dropdowns are changed.
-- ****************************************************************************
local function ConditionDropdownOnChange(this, id)
 local frame = popupFrames.triggerConditionFrame
 local conditionData = popupFrames.triggerFrame.conditionData[id]
 
 frame.parameterEditbox:Hide()
 frame.parameterSlider:Hide()
 frame.parameterDropdown:Hide()
 
 frame.relationDropdown:Clear()
 if (conditionData) then
  if (conditionData.relations) then
   for relationType, relationName in pairs(conditionData.relations) do
    frame.relationDropdown:AddItem(relationName, relationType)
   end
   frame.relationDropdown:SetSelectedID(conditionData.defaultRelation or "eq")
  end

  local control
  if (conditionData.controlType == "editbox") then
   control = frame.parameterEditbox
   control:Show()
   control:SetText(conditionData.default or "")
  elseif (conditionData.controlType == "slider") then
   control = frame.parameterSlider
   control:Show()
   control:SetMinMaxValues(conditionData.minValue, conditionData.maxValue)
   control:SetValueStep(conditionData.step)
   control:SetValue(conditionData.default or conditionData.minValue)
  elseif (conditionData.controlType == "dropdown") then
   control = frame.parameterDropdown
   control:Show()
   control:Clear()
   for itemValue, itemName in pairs(conditionData.items) do
    control:AddItem(itemName, itemValue)
   end
   control:Sort()
   control:SetSelectedID(conditionData.default)
   
  end
 end
end


-- ****************************************************************************
-- Creates the trigger condition frame.
-- ****************************************************************************
local function CreateTriggerCondition()
 local frame = CreatePopup()
 frame:SetWidth(350)
 frame:SetHeight(240)

 -- Condition dropdown.
 local dropdown = MSBTControls.CreateDropdown(frame)
 local objLocale = L.DROPDOWNS["triggerCondition"]
 dropdown:Configure(200, objLocale.label, objLocale.tooltip)
 dropdown:SetListboxHeight(200)
 dropdown:SetListboxWidth(200)
 dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -20)
 dropdown:SetChangeHandler(ConditionDropdownOnChange)
 frame.conditionDropdown = dropdown

 -- Relation dropdown.
 local dropdown = MSBTControls.CreateDropdown(frame)
 local objLocale = L.DROPDOWNS["triggerRelation"]
 dropdown:Configure(120, objLocale.label, objLocale.tooltip)
 dropdown:SetListboxHeight(200)
 dropdown:SetPoint("TOPLEFT", frame.conditionDropdown, "BOTTOMLEFT", 0, -20)
 frame.relationDropdown = dropdown
  
 -- Parameter editbox.
 local editbox = MSBTControls.CreateEditbox(frame)
 local objLocale = L.DROPDOWNS["triggerParameter"]
 editbox:Configure(0, objLocale.label, objLocale.tooltip)
 editbox:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -20)
 editbox:SetPoint("RIGHT", frame, "RIGHT", -35, 0)
 frame.parameterEditbox = editbox
 
 -- Parameter slider.
 local slider = MSBTControls.CreateSlider(frame)
 local objLocale = L.DROPDOWNS["triggerParameter"]
 slider:Configure(180, objLocale.label, objLocale.tooltip)
 slider:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT", 0, -30)
 frame.parameterSlider = slider

 -- Parameter dropdown.
 local dropdown = MSBTControls.CreateDropdown(frame)
 local objLocale = L.DROPDOWNS["triggerParameter"]
 dropdown:Configure(150, objLocale.label, objLocale.tooltip)
 dropdown:SetListboxHeight(120)
 dropdown:SetPoint("TOPLEFT", frame.relationDropdown, "BOTTOMLEFT", 0, -20)
 frame.parameterDropdown = dropdown

 -- Save button.
 local button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericSave"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20)
 button:SetClickHandler(
  function (this)
   EraseTable(returnSettings)
   returnSettings.conditionType = frame.conditionDropdown:GetSelectedID()
   returnSettings.conditionRelation = frame.relationDropdown:GetSelectedID()
   if (frame.parameterEditbox:IsShown()) then
    returnSettings.conditionValue = frame.parameterEditbox:GetText()
   elseif (frame.parameterSlider:IsShown()) then
    returnSettings.conditionValue = frame.parameterSlider:GetValue()
   elseif (frame.parameterDropdown:IsShown()) then
    returnSettings.conditionValue = frame.parameterDropdown:GetSelectedID()
   end
   frame:Hide()
   if (frame.saveHandler) then frame.saveHandler(returnSettings, frame.saveArg1) end
  end
 )

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericCancel"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20)
 button:SetClickHandler(
  function (this)
   frame:Hide()
  end
 )

 return frame
end


-- ****************************************************************************
-- Shows the popup trigger condition frame.
-- ****************************************************************************
local function ShowTriggerCondition(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.triggerConditionFrame) then popupFrames.triggerConditionFrame = CreateTriggerCondition() end

 -- Set parent.
 local frame = popupFrames.triggerConditionFrame
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate condition type.
 frame.conditionDropdown:Clear()
 for conditionType in string.gmatch(configTable.availableConditions, "[^%s]+") do
  frame.conditionDropdown:AddItem(L.TRIGGER_DATA[conditionType] or conditionType, conditionType)
 end 
 frame.conditionDropdown:Sort()
 frame.conditionDropdown:SetSelectedID(configTable.conditionType)
 ConditionDropdownOnChange(frame.conditionDropdown, configTable.conditionType)
 
 -- Populate the condition relation.
 frame.relationDropdown:SetSelectedID(configTable.conditionRelation)

 -- Populate the condition value.
 local conditionData = popupFrames.triggerFrame.conditionData[configTable.conditionType]
 local conditionValue = configTable.conditionValue
 if (type(conditionValue) == "boolean") then conditionValue = tostring(conditionValue) end
 if (conditionData.controlType == "editbox") then
  frame.parameterEditbox:SetText(conditionValue)
 elseif (conditionData.controlType == "slider") then
  frame.parameterSlider:SetValue(conditionValue)
 elseif (conditionData.controlType == "dropdown") then
  frame.parameterDropdown:SetSelectedID(conditionValue)
 end


 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler
 frame.saveArg1 = configTable.saveArg1
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Trigger main event frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Enables the controls on the trigger popup.
-- ****************************************************************************
local function EnableMainEventControls()
 for name, frame in pairs(popupFrames.mainEventFrame.controls) do
  if (frame.Enable) then frame:Enable() end
 end
end


-- ****************************************************************************
-- Updates the main event conditions listbox.
-- ****************************************************************************
local function UpdateMainEventConditions()
 local frame = popupFrames.mainEventFrame
 frame.conditionsListbox:Clear()
 for x = 1, #frame.eventConditions, 3 do
  frame.conditionsListbox:AddItem(x)
 end
end


-- ****************************************************************************
-- Saves the condition the user entered.
-- ****************************************************************************
local function SaveMainEventCondition(settings, conditionNum)
 local frame = popupFrames.mainEventFrame
 frame.eventConditions[conditionNum] = settings.conditionType
 frame.eventConditions[conditionNum+1] = settings.conditionRelation
 frame.eventConditions[conditionNum+2] = settings.conditionValue
 UpdateMainEventConditions()
end


-- ****************************************************************************
-- Called when one of the exception delete buttons is clicked.
-- ****************************************************************************
local function DeleteConditionButtonOnClick(this)
 local frame = popupFrames.mainEventFrame
 local line = this:GetParent()
 table.remove(frame.eventConditions, line.conditionNum)
 table.remove(frame.eventConditions, line.conditionNum)
 table.remove(frame.eventConditions, line.conditionNum)
 UpdateMainEventConditions()
end


-- ****************************************************************************
-- Called when one of the main event edit buttons is clicked.
-- ****************************************************************************
local function EditConditionButtonOnClick(this)
 local frame = popupFrames.mainEventFrame
 local line = this:GetParent()
 local eventType = frame.mainEventDropdown:GetSelectedID()
 local conditionData = popupFrames.triggerFrame.eventConditionData[eventType]

 EraseTable(tempConfig)
 tempConfig.conditionType = frame.eventConditions[line.conditionNum]
 tempConfig.conditionRelation = frame.eventConditions[line.conditionNum+1]
 tempConfig.conditionValue = frame.eventConditions[line.conditionNum+2]
 tempConfig.availableConditions = conditionData and conditionData.availableConditions
 tempConfig.saveHandler = SaveMainEventCondition
 tempConfig.saveArg1 = line.conditionNum
 tempConfig.parentFrame = frame
 tempConfig.anchorFrame = this
 tempConfig.anchorPoint = "BOTTOMLEFT"
 tempConfig.relativePoint = "TOPLEFT"
 tempConfig.hideHandler = EnableMainEventControls
 DisableControls(frame.controls)
 ShowTriggerCondition(tempConfig)
end


-- ****************************************************************************
-- Called by listbox to create a line for main event conditions.
-- ****************************************************************************
local function CreateMainEventConditionsLine(this)
 local controls = popupFrames.mainEventFrame.controls
 local frame = CreateFrame("Button", nil, this)
 frame:EnableMouse(false)

 -- Edit condition button.
 local button = MSBTControls.CreateIconButton(frame, "Configure")
 local objLocale = L.BUTTONS["editCondition"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("LEFT", frame, "LEFT", 0, 0)
 button:SetClickHandler(EditConditionButtonOnClick)
 frame.editConditionButton = button
 controls[#controls+1] = button 
 
 -- Delete condition button.
 button = MSBTControls.CreateIconButton(frame, "Delete")
 objLocale = L.BUTTONS["deleteCondition"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", frame, "RIGHT", -10, -5)
 button:SetClickHandler(DeleteConditionButtonOnClick)
 controls[#controls+1] = button
 
 -- Condition text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", frame.editConditionButton, "RIGHT", 5, 0)
 fontString:SetPoint("RIGHT", controls[#controls], "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 fontString:SetTextColor(1, 1, 1)
 frame.conditionFontString = fontString
 
 return frame
end


-- ****************************************************************************
-- Called by listbox to display an exception line.
-- ****************************************************************************
local function DisplayMainEventConditionsLine(this, line, key, isSelected)
 line.conditionNum = key

 local frame = popupFrames.mainEventFrame
 local conditionType = frame.eventConditions[key]
 local conditionData = popupFrames.triggerFrame.conditionData[conditionType]
 local relation = conditionData and conditionData.relations[frame.eventConditions[key+1]]

 -- Get the localized parameter.
 local parameter = frame.eventConditions[key+2]
 if (type(parameter) == "boolean") then parameter = tostring(parameter) end
 if (conditionData and conditionData.controlType == "dropdown") then parameter = conditionData.items[parameter] end

 local conditionText = L.TRIGGER_DATA[conditionType] or conditionType
 if (relation) then conditionText = conditionText .. " - " .. relation end
 if (parameter) then conditionText = conditionText .. " - " .. parameter end
 
 line.conditionFontString:SetText(conditionText)
end



-- ****************************************************************************
-- Creates the popup main event frame.
-- ****************************************************************************
local function CreateMainEvent()
 local frame = CreatePopup()
 frame:SetWidth(450)
 frame:SetHeight(325)
 frame.controls = {}
 local controls = frame.controls


 -- Main event dropdown.
 local dropdown =  MSBTControls.CreateDropdown(frame)
 local objLocale = L.DROPDOWNS["mainEvent"]
 dropdown:Configure(200, objLocale.label, nil)
 dropdown:SetListboxHeight(200)
 dropdown:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -40)
 dropdown:SetChangeHandler(
  function (this, id)
   EraseTable(frame.eventConditions)
   local conditionData = popupFrames.triggerFrame.eventConditionData[id]
   if (conditionData and conditionData.defaultConditions and conditionData.defaultConditions ~= "") then
    for conditionEntry in string.gmatch(conditionData.defaultConditions .. ";;", "(.-);;") do
     frame.eventConditions[#frame.eventConditions+1] = ConvertType(conditionEntry)
    end
   end
   UpdateMainEventConditions()
  end
 )
 for eventType in pairs(popupFrames.triggerFrame.eventConditionData) do
  dropdown:AddItem(L.TRIGGER_DATA[eventType] or eventType, eventType)
 end
 dropdown:Sort()
 frame.mainEventDropdown = dropdown
 controls[#controls+1] = dropdown


 -- Trigger conditions label.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOPLEFT", frame.mainEventDropdown, "BOTTOMLEFT", 0, -30)
 fontString:SetText(L.MSG_EVENT_CONDITIONS .. ":")
 frame.triggerConditionsLabel = fontString
 
 -- Add event condition button.
 local button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["addEventCondition"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("LEFT", frame.triggerConditionsLabel, "RIGHT", 10, 0)
 button:SetClickHandler(
  function (this)
   local eventType = frame.mainEventDropdown:GetSelectedID()
   local conditionData = popupFrames.triggerFrame.eventConditionData[eventType]
   local conditionType, conditionRelation, conditionValue
   if (conditionData and conditionData.defaultConditions ~= "") then
    _, _, conditionType, conditionRelation, conditionValue = string.find(conditionData.defaultConditions, "(.-);;(.-);;(.-)")
	conditionValue = conditionValue and ConvertType(conditionValue)
	if (type(conditionValue == "boolean")) then conditionValue = tostring(conditionValue) end
   end
   EraseTable(tempConfig)
   tempConfig.conditionType = conditionType or "skillName"
   tempConfig.conditionRelation = conditionRelation or "eq"
   tempConfig.conditionValue = conditionValue or ""
   tempConfig.availableConditions = conditionData and conditionData.availableConditions
   tempConfig.saveHandler = SaveMainEventCondition
   tempConfig.saveArg1 = #frame.eventConditions+1
   tempConfig.parentFrame = frame
   tempConfig.anchorFrame = this
   tempConfig.anchorPoint = "BOTTOMLEFT"
   tempConfig.relativePoint = "TOPLEFT"
   tempConfig.hideHandler = EnableMainEventControls
   DisableControls(frame.controls)
   ShowTriggerCondition(tempConfig)
  end
 )
 controls[#controls+1] = button

 -- Main event conditions listbox.
 local listbox = MSBTControls.CreateListbox(frame)
 listbox:Configure(400, 100, 25)
 listbox:SetPoint("TOPLEFT", frame.triggerConditionsLabel, "BOTTOMLEFT", 10, -10)
 listbox:SetCreateLineHandler(CreateMainEventConditionsLine)
 listbox:SetDisplayHandler(DisplayMainEventConditionsLine)
 frame.conditionsListbox = listbox
 controls[#controls+1] = listbox

 

 -- Save button.
 local button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericSave"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20)
 button:SetClickHandler(
  function (this)
   EraseTable(returnSettings)
   returnSettings.eventType = frame.mainEventDropdown:GetSelectedID()
   returnSettings.eventConditions = {}
   for _, conditionEntry in ipairs(frame.eventConditions) do
    returnSettings.eventConditions[#returnSettings.eventConditions+1] = conditionEntry
   end
   frame:Hide()
   if (frame.saveHandler) then frame.saveHandler(returnSettings, frame.saveArg1) end
  end
 )
 controls[#controls+1] = button

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericCancel"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20)
 button:SetClickHandler(
  function (this)
   frame:Hide()
  end
 )
 controls[#controls+1] = button

 frame.eventConditions = {}
 
 return frame
end


-- ****************************************************************************
-- Shows the popup main event frame.
-- ****************************************************************************
local function ShowMainEvent(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.mainEventFrame) then popupFrames.mainEventFrame = CreateMainEvent() end

 -- Set parent.
 local frame = popupFrames.mainEventFrame
 ChangePopupParent(frame, configTable.parentFrame)

 -- Populate data.
 frame.mainEventDropdown:SetSelectedID(configTable.eventType)
 
 EraseTable(frame.eventConditions)
 for _, conditionEntry in ipairs(configTable.eventConditions) do
  frame.eventConditions[#frame.eventConditions+1] = conditionEntry
 end
 UpdateMainEventConditions()

 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler
 frame.saveArg1 = configTable.saveArg1
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Trigger frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Updates the classes font string based on what classes are selected.
-- ****************************************************************************
local function UpdateClassesText()
 local frame = popupFrames.triggerFrame
 
 -- Get localized list of seleced classes.
 local selectedClasses = ""
 if (frame.classes["ALL"]) then
  selectedClasses = L.CHECKBOXES["allClasses"].label
 else
  for className in pairs(frame.classes) do
   selectedClasses = selectedClasses .. CLASS_NAMES[className] .. ", "
  end

  -- Strip off the extra comma and space.
  selectedClasses = string.sub(selectedClasses, 1, -3)
 end

 frame.classesFontString:SetText(selectedClasses)
end


-- ****************************************************************************
-- Updates the main events listbox.
-- ****************************************************************************
local function UpdateMainEvents()
 local frame = popupFrames.triggerFrame
 frame.mainEventsListbox:Clear()
 for index, mainEvent in pairs(frame.mainEvents) do
  frame.mainEventsListbox:AddItem(index)
 end
end


-- ****************************************************************************
-- Updates the exceptions listbox.
-- ****************************************************************************
local function UpdateExceptions()
 local frame = popupFrames.triggerFrame
 frame.exceptionsListbox:Clear()
 for x = 1, #frame.exceptions, 3 do
  frame.exceptionsListbox:AddItem(x)
 end
end


-- ****************************************************************************
-- Enables the controls on the trigger popup.
-- ****************************************************************************
local function EnableTriggerControls()
 for name, frame in pairs(popupFrames.triggerFrame.controls) do
  if (frame.Enable) then frame:Enable() end
 end
end


-- ****************************************************************************
-- Saves the main event the user entered to the trigger main event frame.
-- ****************************************************************************
local function SaveMainEvent(settings, eventNum)
 local frame = popupFrames.triggerFrame
 frame.mainEvents[eventNum] = settings.eventType
 frame.eventConditions[eventNum] = settings.eventConditions
 UpdateMainEvents()
end


-- ****************************************************************************
-- Saves the exception the user entered to the trigger exception frame.
-- ****************************************************************************
local function SaveException(settings, exceptionNum)
 local frame = popupFrames.triggerFrame
 frame.exceptions[exceptionNum] = settings.conditionType
 frame.exceptions[exceptionNum+1] = settings.conditionRelation
 frame.exceptions[exceptionNum+2] = settings.conditionValue
 UpdateExceptions()
end


-- ****************************************************************************
-- Called when one of the main event edit buttons is clicked.
-- ****************************************************************************
local function EditMainEventButtonOnClick(this)
 local frame = popupFrames.triggerFrame
 local line = this:GetParent()

 EraseTable(tempConfig)
 tempConfig.eventType = frame.mainEvents[line.eventNum]
 tempConfig.eventConditions = frame.eventConditions[line.eventNum]
 tempConfig.saveHandler = SaveMainEvent
 tempConfig.saveArg1 = line.eventNum
 tempConfig.parentFrame = frame
 tempConfig.anchorFrame = this
 tempConfig.hideHandler = EnableTriggerControls
 DisableControls(frame.controls)
 ShowMainEvent(tempConfig)
end


-- ****************************************************************************
-- Called when one of the main event edit buttons is clicked.
-- ****************************************************************************
local function EditExceptionButtonOnClick(this)
 local frame = popupFrames.triggerFrame
 local line = this:GetParent()

 EraseTable(tempConfig)
 tempConfig.conditionType = frame.exceptions[line.exceptionNum]
 tempConfig.conditionRelation = frame.exceptions[line.exceptionNum+1]
 tempConfig.conditionValue = frame.exceptions[line.exceptionNum+2]
 tempConfig.availableConditions = frame.availableExceptions
 tempConfig.saveHandler = SaveException
 tempConfig.saveArg1 = line.exceptionNum
 tempConfig.parentFrame = frame
 tempConfig.anchorFrame = this
 tempConfig.anchorPoint = "BOTTOMLEFT"
 tempConfig.relativePoint = "TOPLEFT"
 tempConfig.hideHandler = EnableTriggerControls
 DisableControls(frame.controls)
 ShowTriggerCondition(tempConfig)
end


-- ****************************************************************************
-- Called when one of the main event delete buttons is clicked.
-- ****************************************************************************
local function DeleteMainEventButtonOnClick(this)
 local frame = popupFrames.triggerFrame
 local line = this:GetParent()
 table.remove(frame.mainEvents, line.eventNum)
 table.remove(frame.eventConditions, line.eventNum)
 UpdateMainEvents()
end


-- ****************************************************************************
-- Called when one of the exception delete buttons is clicked.
-- ****************************************************************************
local function DeleteExceptionButtonOnClick(this)
 local frame = popupFrames.triggerFrame
 local line = this:GetParent()
 table.remove(frame.exceptions, line.exceptionNum)
 table.remove(frame.exceptions, line.exceptionNum)
 table.remove(frame.exceptions, line.exceptionNum)
 UpdateExceptions()
end


-- ****************************************************************************
-- Called by listbox to create a line for main events.
-- ****************************************************************************
local function CreateMainEventsLine(this)
 local controls = popupFrames.triggerFrame.controls
 local frame = CreateFrame("Button", nil, this)
 frame:EnableMouse(false)

 -- Edit event button.
 local button = MSBTControls.CreateIconButton(frame, "Configure")
 local objLocale = L.BUTTONS["editEventConditions"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("LEFT", frame, "LEFT", 0, 0)
 button:SetClickHandler(EditMainEventButtonOnClick)
 frame.editEventButton = button
 controls[#controls+1] = button
 
 
 -- Delete event button.
 button = MSBTControls.CreateIconButton(frame, "Delete")
 objLocale = L.BUTTONS["deleteMainEvent"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
 button:SetClickHandler(DeleteMainEventButtonOnClick)
 controls[#controls+1] = button
 
 -- Event text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", frame.editEventButton, "RIGHT", 5, 0)
 fontString:SetPoint("RIGHT", controls[#controls], "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 fontString:SetTextColor(1, 1, 1)
 frame.eventFontString = fontString

 return frame
end


-- ****************************************************************************
-- Called by listbox to create a line for main events.
-- ****************************************************************************
local function CreateExceptionsLine(this)
 local controls = popupFrames.triggerFrame.controls
 local frame = CreateFrame("Button", nil, this)
 frame:EnableMouse(false)

 -- Edit exception button.
 local button = MSBTControls.CreateIconButton(frame, "Configure")
 local objLocale = L.BUTTONS["editCondition"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("LEFT", frame, "LEFT", 0, 0)
 button:SetClickHandler(EditExceptionButtonOnClick)
 frame.editExceptionButton = button
 controls[#controls+1] = button 
 
 -- Delete exception button.
 button = MSBTControls.CreateIconButton(frame, "Delete")
 objLocale = L.BUTTONS["deleteCondition"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", frame, "RIGHT", -10, -5)
 button:SetClickHandler(DeleteExceptionButtonOnClick)
 controls[#controls+1] = button
 
 -- Exception text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", frame.editExceptionButton, "RIGHT", 5, 0)
 fontString:SetPoint("RIGHT", controls[#controls], "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 fontString:SetTextColor(1, 1, 1)
 frame.exceptionFontString = fontString
 
 return frame
end


-- ****************************************************************************
-- Called by listbox to display a main event line.
-- ****************************************************************************
local function DisplayMainEventsLine(this, line, key, isSelected)
 line.eventNum = key

 local frame = popupFrames.triggerFrame
 local eventType = frame.mainEvents[key]
 local eventText = L.TRIGGER_DATA[eventType] or UNKNOWN
 local eventConditions = frame.eventConditions[key]
 
 local numConditions = #eventConditions / 3
 eventText = eventText .. " - " .. numConditions .. " " .. (numConditions == 1 and L.MSG_CONDITION or L.MSG_CONDITIONS)

 line.eventFontString:SetText(eventText)
end


-- ****************************************************************************
-- Called by listbox to display an exception line.
-- ****************************************************************************
local function DisplayExceptionsLine(this, line, key, isSelected)
 line.exceptionNum = key

 local frame = popupFrames.triggerFrame
 local exceptionType = frame.exceptions[key]
 local conditionData = frame.conditionData[exceptionType]
 local relation = conditionData.relations[frame.exceptions[key+1]]

 -- Get the localized parameter.
 local parameter = frame.exceptions[key+2]
 if (type(parameter) == "boolean") then parameter = tostring(parameter) end
 if (conditionData.controlType == "dropdown") then parameter = conditionData.items[parameter] end

 local exceptionText = L.TRIGGER_DATA[exceptionType] or exceptionType
 if (relation) then exceptionText = exceptionText .. " - " .. relation end
 if (parameter) then exceptionText = exceptionText .. " - " .. parameter end
 
 line.exceptionFontString:SetText(exceptionText)
end


-- ****************************************************************************
-- Creates the popup trigger settings frame.
-- ****************************************************************************
local function CreateTriggerPopup()
 local frame = CreatePopup()
 frame:SetWidth(500)
 frame:SetHeight(460)
 frame.controls = {}
 local controls = frame.controls

 -- Title text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOP", frame, "TOP", 0, -20)
 frame.titleFontString = fontString

 -- Trigger classes label.
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -50)
 fontString:SetText(L.MSG_TRIGGER_CLASSES .. ":")
 frame.classesLabel = fontString

 -- Edit trigger classes button.
 local button = MSBTControls.CreateIconButton(frame, "Configure")
 local objLocale = L.BUTTONS["editTriggerClasses"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("TOPLEFT", frame.classesLabel, "BOTTOMLEFT", 10, -5)
 button:SetClickHandler(
  function (this)
   EraseTable(tempConfig)
   tempConfig.parentFrame = frame
   tempConfig.anchorFrame = this
   tempConfig.classes = frame.classes
   tempConfig.updateHandler = UpdateClassesText
   tempConfig.hideHandler = EnableTriggerControls
   DisableControls(controls)
   ShowClasses(tempConfig)
  end
 )
 controls[#controls+1] = button

 -- Classes text.
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", controls[#controls], "RIGHT", 10, -5)
 fontString:SetPoint("RIGHT", frame, "RIGHT", -20, 0)
 fontString:SetHeight(30)
 fontString:SetJustifyH("LEFT")
 fontString:SetJustifyV("TOP")
 fontString:SetTextColor(1, 1, 1)
 frame.classesFontString = fontString

 -- Main events label.
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOPLEFT", controls[#controls], "BOTTOMLEFT", -10, -15)
 fontString:SetText(L.MSG_MAIN_EVENTS .. ":")
 frame.mainEventsLabel = fontString
 
 -- Add main events button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["addMainEvent"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("LEFT", frame.mainEventsLabel, "RIGHT", 10, 0)
 button:SetClickHandler(
  function (this)
   EraseTable(tempConfig)
   tempConfig.eventType = "SPELL_AURA_APPLIED"
   tempConfig.eventConditions = {"recipientAffiliation", "eq", FLAG_YOU, "skillName", "eq", UNKNOWN }
   tempConfig.saveHandler = SaveMainEvent
   tempConfig.saveArg1 = #frame.mainEvents + 1
   tempConfig.parentFrame = frame
   tempConfig.anchorFrame = this
   tempConfig.hideHandler = EnableTriggerControls
   DisableControls(frame.controls)
   ShowMainEvent(tempConfig)
  end
 )
 controls[#controls+1] = button

 -- Main events listbox.
 local listbox = MSBTControls.CreateListbox(frame)
 listbox:Configure(450, 100, 25)
 listbox:SetPoint("TOPLEFT", frame.mainEventsLabel, "BOTTOMLEFT", 10, -10)
 listbox:SetCreateLineHandler(CreateMainEventsLine)
 listbox:SetDisplayHandler(DisplayMainEventsLine)
 frame.mainEventsListbox = listbox
 controls[#controls+1] = listbox


 -- Trigger exceptions label.
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOPLEFT", frame.mainEventsListbox, "BOTTOMLEFT", -10, -15)
 fontString:SetText(L.MSG_TRIGGER_EXCEPTIONS .. ":")
 frame.triggerExceptionsLabel = fontString
 
 -- Add trigger exceptions button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["addTriggerException"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("LEFT", frame.triggerExceptionsLabel, "RIGHT", 10, 0)
 button:SetClickHandler(
  function (this)
   EraseTable(tempConfig)
   tempConfig.conditionType = "recentlyFired"
   tempConfig.conditionRelation = "lt"
   tempConfig.conditionValue = 5
   tempConfig.availableConditions = frame.availableExceptions
   tempConfig.saveHandler = SaveException
   tempConfig.saveArg1 = #frame.exceptions+1
   tempConfig.parentFrame = frame
   tempConfig.anchorFrame = this
   tempConfig.anchorPoint = "BOTTOMLEFT"
   tempConfig.relativePoint = "TOPLEFT"
   tempConfig.hideHandler = EnableTriggerControls
   DisableControls(frame.controls)
   ShowTriggerCondition(tempConfig)
  end
 )
 controls[#controls+1] = button

 -- Trigger exceptions listbox.
 listbox = MSBTControls.CreateListbox(frame)
 listbox:Configure(450, 100, 25)
 listbox:SetPoint("TOPLEFT", frame.triggerExceptionsLabel, "BOTTOMLEFT", 10, -10)
 listbox:SetCreateLineHandler(CreateExceptionsLine)
 listbox:SetDisplayHandler(DisplayExceptionsLine)
 frame.exceptionsListbox = listbox
 controls[#controls+1] = listbox

 -- Save button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericSave"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20)
 button:SetClickHandler(
  function (this)
   EraseTable(returnSettings)
   -- Make the classes string.
   if (not frame.classes["ALL"]) then
    local sortedClasses = frame.sortedClasses
    EraseTable(sortedClasses)
    for class in pairs(frame.classes) do
     sortedClasses[#sortedClasses+1] = class
    end
    table.sort(sortedClasses)
    returnSettings.classes = table.concat(sortedClasses, ",")
   end

   -- Make the main events string.
   if (next(frame.mainEvents)) then
    local events = ""
    for eventNum, eventType in ipairs(frame.mainEvents) do
     events = events .. eventType .. "{"
     if (next(frame.eventConditions[eventNum])) then
      for _, conditionEntry in ipairs(frame.eventConditions[eventNum]) do
       events = events .. tostring(conditionEntry) .. ";;"
      end
      events = string.sub(events, 1, -3)
     end
     events = events .. "}&&"
    end
    returnSettings.mainEvents = string.sub(events, 1, -3)
   end

   -- Make the exceptions string.
   if (next(frame.exceptions)) then
    local exceptions = ""
    for x = 1, #frame.exceptions, 3 do
     exceptions = exceptions .. string.format("%s;;%s;;%s;;", tostring(frame.exceptions[x]), tostring(frame.exceptions[x+1]), tostring(frame.exceptions[x+2]))
    end
    returnSettings.exceptions = string.sub(exceptions, 1, -3)
   end

   frame:Hide()
   if (frame.saveHandler) then frame.saveHandler(returnSettings, frame.saveArg1) end
  end
 )
 controls[#controls+1] = button

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericCancel"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20)
 button:SetClickHandler(
  function (this)
   frame:Hide()
  end
 )
 controls[#controls+1] = button

 frame.classes = {}
 frame.sortedClasses = {}
 frame.mainEvents = {}
 frame.eventConditions = {}
 frame.exceptions = {}
 frame.sortedKeys = {}

 -- Relations.
 local objLocale = L.TRIGGER_DATA
 local equalityRelations = {eq = objLocale["eq"]}
 local stringRelations = {eq = objLocale["eq"], ne = objLocale["ne"], like = objLocale["like"], unlike = objLocale["unlike"]}
 local numberRelations = {eq = objLocale["eq"], ne = objLocale["ne"], lt = objLocale["lt"], gt = objLocale["gt"]}
 local booleanRelations = {eq = objLocale["eq"], ne = objLocale["ne"]}
 local lessThanRelations = {lt = objLocale["lt"]}
 
 -- Localized affiliations.
 local affiliationTypes = {
  [MSBTParser.AFFILIATION_MINE] = objLocale["affiliationMine"],
  [MSBTParser.AFFILIATION_PARTY] = objLocale["affiliationParty"],
  [MSBTParser.AFFILIATION_RAID] = objLocale["affiliationRaid"],
  [MSBTParser.AFFILIATION_OUTSIDER] = objLocale["affiliationOutsider"],
  [MSBTParser.TARGET_TARGET] = objLocale["affiliationTarget"],
  [MSBTParser.TARGET_FOCUS] = objLocale["affiliationFocus"],
  [FLAG_YOU] = objLocale["affiliationYou"],
 }

 -- Localized reactions.
 local reactionTypes = {
  [MSBTParser.REACTION_FRIENDLY] = objLocale["reactionFriendly"],
  [MSBTParser.REACTION_NEUTRAL] = objLocale["reactionNeutral"],
  [MSBTParser.REACTION_HOSTILE] = objLocale["reactionHostile"],
 }

 -- Localized control types.
 local controlTypes = {
  [MSBTParser.CONTROL_HUMAN] = objLocale["controlHuman"],
  [MSBTParser.CONTROL_SERVER] = objLocale["controlServer"],
 }

 -- Localized unit types.
 local unitTypes = {
  [MSBTParser.UNITTYPE_PLAYER] = objLocale["unitTypePlayer"],
  [MSBTParser.UNITTYPE_NPC] = objLocale["unitTypeNPC"],
  [MSBTParser.UNITTYPE_PET] = objLocale["unitTypePet"],
  [MSBTParser.UNITTYPE_GUARDIAN] = objLocale["unitTypeGuardian"],
  [MSBTParser.UNITTYPE_OBJECT] = objLocale["unitTypeObject"],
 }
 
 -- Miss types.
 local missTypes = {
  ["MISS"] = MISS,
  ["DODGE"] = DODGE,
  ["PARRY"] = PARRY,
  ["BLOCK"] = BLOCK,
  ["DEFLECT"] = DEFLECT,
  ["RESIST"] = RESIST,
  ["ABSORB"] = ABSORB,
  ["IMMUNE"] = IMMUNE,
  ["EVADE"] = EVADE,
  ["REFLECT"] = REFLECT,
 }
 
 -- Hazard type.
 local hazardTypes = {
  ["DROWNING"] = STRING_ENVIRONMENTAL_DAMAGE_DROWNING,
  ["FALLING"] = STRING_ENVIRONMENTAL_DAMAGE_FALLING,
  ["FATIGUE "] = STRING_ENVIRONMENTAL_DAMAGE_FATIGUE,
  ["FIRE"] = STRING_ENVIRONMENTAL_DAMAGE_FIRE,
  ["LAVA"] = STRING_ENVIRONMENTAL_DAMAGE_LAVA,
  ["SLIME"] = STRING_ENVIRONMENTAL_DAMAGE_SLIME,
 }
 
 local auraTypes = {
  BUFF = objLocale["auraTypeBuff"],
  DEBUFF = objLocale["auraTypeDebuff"],
 }
 
 local unitIDs = {
  player = YOU,
  target = TARGET,
  focus = FOCUS,
  pet = PET,
  party = objLocale["affiliationParty"],
  party1 = objLocale["affiliationParty"] .. " 1",
  party2 = objLocale["affiliationParty"] .. " 2",
  party3 = objLocale["affiliationParty"] .. " 3",
  party4 = objLocale["affiliationParty"] .. " 4",
  party5 = objLocale["affiliationParty"] .. " 5",
  raid = objLocale["affiliationRaid"],
 }
 
 -- Localized booleans.
 local booleanItems = {["true"] = objLocale["booleanTrue"], ["false"] = objLocale["booleanFalse"]}
 
 -- Localized power types.
 local powerTypes = {}
 for powerToken, powerType in pairs(MSBTTriggers.powerTypes) do
  local localizedName = _G[powerToken]
  if localizedName then powerTypes[powerType] = localizedName end
 end

 -- Localized talent specs.
 local talentSpecs = {
  [1] = TALENT_SPEC_PRIMARY,
  [2] = TALENT_SPEC_SECONDARY,
 }

 -- Localized warrior stances.
 local warriorStances = {
  [1] = GetSkillName(2457),
  [2] = GetSkillName(71),
 }

 -- Localized zone types.
 local zoneTypes = {arena = objLocale["zoneTypeArena"], pvp = objLocale["zoneTypePvP"], party = objLocale["zoneTypeParty"], raid = objLocale["zoneTypeRaid"]}
 
 

 -- Condition data.
 frame.conditionData = {
  -- Main event conditions.
  -- Source unit.
  sourceName = {controlType = "editbox", relations = stringRelations},
  sourceAffiliation = {controlType = "dropdown", items = affiliationTypes, default = FLAG_YOU, relations = booleanRelations},
  sourceReaction = {controlType = "dropdown", items = reactionTypes, default = MSBTParser.REACTION_HOSTILE, relations = booleanRelations},
  sourceControl = {controlType = "dropdown", items = controlTypes, default = MSBTParser.CONTROL_HUMAN, relations = booleanRelations},
  sourceUnitType = {controlType = "dropdown", items = unitTypes, default = MSBTParser.UNITTYPE_PLAYER, relations = booleanRelations},

  -- Recipient unit.
  recipientName = {controlType = "editbox", relations = stringRelations},
  recipientAffiliation = {controlType = "dropdown", items = affiliationTypes, default = FLAG_YOU, relations = booleanRelations},
  recipientReaction = {controlType = "dropdown", items = reactionTypes, default = MSBTParser.REACTION_HOSTILE, relations = booleanRelations},
  recipientControl = {controlType = "dropdown", items = controlTypes, default = MSBTParser.CONTROL_HUMAN, relations = booleanRelations},
  recipientUnitType = {controlType = "dropdown", items = unitTypes, default = MSBTParser.UNITTYPE_PLAYER, relations = booleanRelations},

  -- Skill.
  skillID = {controlType = "editbox", relations = booleanRelations},
  skillName = {controlType = "editbox", relations = stringRelations},
  skillSchool = {controlType = "dropdown", items = MSBTMain.damageTypeMap, default = 0x1, relations = booleanRelations},
  
  -- Extra skill.
  extraSkillID = {controlType = "editbox", relations = booleanRelations},
  extraSkillName = {controlType = "editbox", relations = stringRelations},
  extraSkillSchool = {controlType = "dropdown", items = MSBTMain.damageTypeMap, default = 0x1, relations = booleanRelations},

  -- Damage/heal.
  amount = {controlType = "editbox", relations = numberRelations},
  overkillAmount = {controlType = "editbox", relations = numberRelations},
  damageType = {controlType = "dropdown", items = MSBTMain.damageTypeMap, default = 0x1, relations = booleanRelations},
  resistAmount = {controlType = "editbox", relations = numberRelations},
  blockAmount = {controlType = "editbox", relations = numberRelations},
  absorbAmount = {controlType = "editbox", relations = numberRelations},
  isCrit = {controlType = "dropdown", items = booleanItems, default = "true", relations = booleanRelations},
  isGlancing = {controlType = "dropdown", items = booleanItems, default = "true", relations = booleanRelations},
  isCrushing = {controlType = "dropdown", items = booleanItems, default = "true", relations = booleanRelations},

  -- Miss/environmental/power.
  missType = {controlType = "dropdown", items = missTypes, default = "MISS", relations = booleanRelations},
  hazardType = {controlType = "dropdown", items = hazardTypes, default = "FALLING", relations = booleanRelations},
  powerType = {controlType = "dropdown", items = powerTypes, default = 0, relations = booleanRelations},
  extraAmount = {controlType = "editbox", relations = numberRelations},
  
  -- Aura.
  auraType = {controlType = "dropdown", items = auraTypes, default = "BUFF", relations = booleanRelations},

  -- Health/power changes.
  threshold = {controlType = "slider", minValue=1, maxValue=100, step=1, default = 40, relations=numberRelations, defaultRelation = "lt"},
  unitID = {controlType = "dropdown", items = unitIDs, default = "player", relations = booleanRelations},
  unitReaction = {controlType = "dropdown", items = reactionTypes, default = MSBTParser.REACTION_HOSTILE, relations = booleanRelations},

  -- Items.
  itemID = {controlType = "editbox", relations = booleanRelations},
  itemName = {controlType = "editbox", relations = stringRelations},

  -- Exception conditions.
  activeTalents = {controlType = "dropdown", items = talentSpecs, default = 1, relations = booleanRelations},
  buffActive = {controlType = "editbox", relations = equalityRelations},
  buffInactive = {controlType = "editbox", relations = equalityRelations},
  currentCP = {controlType = "slider", minValue = 1, maxValue = 5, step = 1, default = 5, relations = numberRelations, defaultRelation = "lt"},
  currentPower = {controlType = "slider", minValue = 1, maxValue = 100, step = 1, default = 20, relations = numberRelations, defaultRelation = "lt"},
  inCombat = {controlType = "dropdown", items = booleanItems, default = "false", relations = booleanRelations},
  recentlyFired = {controlType = "slider", minValue = 1, maxValue = 30, step = 1, default = 5, relations = lessThanRelations, defaultRelation = "lt"},
  trivialTarget = {controlType = "dropdown", items = booleanItems, default = "false", relations = booleanRelations},
  unavailableSkill = {controlType = "editbox", relations = equalityRelations},
  warriorStance = {controlType = "dropdown", items = warriorStances, default = 1, relations = booleanRelations},
  zoneName = {controlType = "editbox", relations = stringRelations},
  zoneType = {controlType = "dropdown", items = zoneTypes, default = "arena", relations = booleanRelations},
 }

 -- Event condition data.
 local commonSourceFields = "sourceName sourceAffiliation sourceReaction sourceControl sourceUnitType "
 local commonRecipientFields = "recipientName recipientAffiliation recipientReaction recipientControl recipientUnitType "
 local commonLogFields = commonSourceFields .. commonRecipientFields
 local commonSkillFields = "skillID skillName skillSchool "
 local commonDamageFields = "amount overkillAmount damageType resistAmount blockAmount absorbAmount isCrit isGlancing isCrushing"
 local commonExtraSkillFields = "extraSkillID extraSkillName extraSkillSchool "
 local commonHealFields = "amount absorbAmount isCrit"
 local commonPowerFields = "amount powerType"
 local commonHealthPowerFields = "unitID unitReaction amount threshold"
 local eventConditionData = {
  -- Damage events.
  SWING_DAMAGE = {availableConditions = commonLogFields .. commonDamageFields, defaultConditions="sourceAffiliation;;eq;;" .. FLAG_YOU .. ";;isCrit;;eq;;true"},
  SPELL_DAMAGE = {availableConditions = commonLogFields .. commonSkillFields .. commonDamageFields, defaultConditions="sourceAffiliation;;eq;;" .. FLAG_YOU .. ";;isCrit;;eq;;true;;skillName;;eq;;" .. UNKNOWN},
  
  -- Miss events.
  SWING_MISSED = {availableConditions = commonLogFields .. "missType", defaultConditions="recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;missType;;eq;;BLOCK"},
  SPELL_MISSED = {availableConditions = commonLogFields .. commonSkillFields .. "missType", defaultConditions="recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;missType;;eq;;RESIST;;skillName;;eq;;" .. UNKNOWN},
  SPELL_DISPEL_FAILED = {availableConditions = commonLogFields .. commonSkillFields .. commonExtraSkillFields .. "missType", defaultConditions="sourceAffiliation;;eq;;" .. FLAG_YOU .. ";;skillName;;eq;;" .. UNKNOWN},

  -- Heal events.
  SPELL_HEAL = {availableConditions = commonLogFields .. commonSkillFields .. commonHealFields, defaultConditions="recipientReaction;;eq;;" .. MSBTParser.REACTION_HOSTILE .. ";;isCrit;;eq;;true"},

  -- Environmental events.
  ENVIRONMENTAL_DAMAGE = {availableConditions = commonLogFields .. commonDamageFields .. " hazardType", defaultConditions="recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;hazardType;;eq;;DROWNING"},

  -- Power events.
  SPELL_ENERGIZE = {availableConditions = commonLogFields .. commonSkillFields .. commonPowerFields, defaultConditions="recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;powerType;;eq;;0"},
  SPELL_DRAIN = {availableConditions = commonLogFields .. commonSkillFields .. commonPowerFields .. " extraAmount", defaultConditions="recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;powerType;;eq;;0"},

  -- Interrupt events.
  SPELL_INTERRUPT = {availableConditions = commonLogFields .. commonSkillFields .. commonExtraSkillFields, defaultConditions="recipientAffiliation;;eq;;" .. FLAG_YOU},

  -- Aura events.
  SPELL_AURA_APPLIED = {availableConditions = commonLogFields .. commonSkillFields .. "auraType amount", defaultConditions="recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;skillName;;eq;;" .. UNKNOWN},
  SPELL_AURA_BROKEN_SPELL = {availableConditions = commonLogFields .. commonSkillFields .. commonExtraSkillFields .. "auraType", defaultConditions="sourceAffiliation;;eq;;" .. FLAG_YOU .. ";;skillName;;eq;;" .. UNKNOWN},
  SPELL_AURA_REFRESH = {availableConditions = commonLogFields .. commonSkillFields .. "auraType", defaultConditions="sourceAffiliation;;eq;;" .. FLAG_YOU .. ";;skillName;;eq;;" .. UNKNOWN},

  -- Enchant events.
  ENCHANT_APPLIED = {availableConditions = commonLogFields .. "skillName itemID itemName", defaultConditions="skillName;;eq;;" .. UNKNOWN},
  
  -- Dispel events.
  SPELL_DISPEL = {availableConditions = commonLogFields .. commonSkillFields .. commonExtraSkillFields .. " auraType", defaultConditions="recipientAffiliation;;eq;;" .. FLAG_YOU .. ";;skillName;;eq;;" .. UNKNOWN},

  -- Cast events.
  SPELL_CAST_START = {availableConditions = commonSourceFields .. commonSkillFields, defaultConditions="sourceReaction;;eq;;" .. MSBTParser.REACTION_HOSTILE .. ";;skillName;;eq;;" .. UNKNOWN},
  SPELL_CAST_SUCCESS  = {availableConditions = commonLogFields .. commonSkillFields, defaultConditions="sourceReaction;;eq;;" .. MSBTParser.REACTION_HOSTILE .. ";;skillName;;eq;;" .. UNKNOWN},

  -- Kill events.
  PARTY_KILL = {availableConditions = commonLogFields, defaultConditions="recipientName;;eq;;" .. UNKNOWN},

  -- Extra Attack events.
  SPELL_EXTRA_ATTACKS = {availableConditions = commonLogFields .. commonSkillFields .. "amount", defaultConditions="sourceAffiliation;;eq;;" .. FLAG_YOU .. ";;skillName;;eq;;" .. UNKNOWN},
  
  -- Threshold events.
  UNIT_HEALTH = {availableConditions = commonHealthPowerFields, defaultConditions="unitID;;eq;;player;;threshold;;lt;;20"},
  UNIT_POWER = {availableConditions = commonHealthPowerFields .. " powerType", defaultConditions="powerType;;eq;;0;;unitID;;eq;;player;;threshold;;lt;;20"},

  -- Cooldowns.
  SKILL_COOLDOWN = {availableConditions = "skillID skillName", defaultConditions="skillName;;eq;;" .. UNKNOWN},
  ITEM_COOLDOWN = {availableConditions = "itemID itemName", defaultConditions="itemName;;eq;;" .. UNKNOWN},
 }
 eventConditionData["RANGE_DAMAGE"] = eventConditionData["SPELL_DAMAGE"]
 eventConditionData["GENERIC_DAMAGE"] = eventConditionData["SPELL_DAMAGE"]
 eventConditionData["SPELL_PERIODIC_DAMAGE"] = eventConditionData["SPELL_DAMAGE"]
 eventConditionData["DAMAGE_SHIELD"] = eventConditionData["SPELL_DAMAGE"]
 eventConditionData["DAMAGE_SPLIT"] = eventConditionData["SPELL_DAMAGE"]
 eventConditionData["RANGE_MISSED"] = eventConditionData["SPELL_MISSED"]
 eventConditionData["GENERIC_MISSED"] = eventConditionData["SPELL_MISSED"]
 eventConditionData["SPELL_PERIODIC_MISSED"] = eventConditionData["SPELL_MISSED"]
 eventConditionData["DAMAGE_SHIELD_MISSED"] = eventConditionData["SPELL_MISSED"]
 eventConditionData["SPELL_PERIODIC_HEAL"] = eventConditionData["SPELL_HEAL"]
 eventConditionData["SPELL_PERIODIC_ENERGIZE"] = eventConditionData["SPELL_ENERGIZE"]
 eventConditionData["SPELL_PERIODIC_DRAIN"] = eventConditionData["SPELL_DRAIN"]
 eventConditionData["SPELL_LEECH"] = eventConditionData["SPELL_DRAIN"]
 eventConditionData["SPELL_PERIODIC_LEECH"] = eventConditionData["SPELL_DRAIN"]
 eventConditionData["SPELL_AURA_REMOVED"] = eventConditionData["SPELL_AURA_APPLIED"]
 eventConditionData["SPELL_STOLEN"] = eventConditionData["SPELL_DISPEL"]
 eventConditionData["ENCHANT_REMOVED"] = eventConditionData["ENCHANT_APPLIED"]
 eventConditionData["SPELL_CAST_FAILED"] = eventConditionData["SPELL_CAST_START"] -- Ignore failure reason.
 eventConditionData["SPELL_SUMMON"] = eventConditionData["SPELL_CAST_SUCCESS"]
 eventConditionData["SPELL_CREATE"] = eventConditionData["SPELL_CAST_START"]
 eventConditionData["UNIT_DIED"] = eventConditionData["PARTY_KILL"]
 eventConditionData["UNIT_DESTROYED"] = eventConditionData["PARTY_KILL"]
 eventConditionData["PET_COOLDOWN"] = eventConditionData["SKILL_COOLDOWN"]

 frame.eventConditionData = eventConditionData

 -- Available exceptions.
 frame.availableExceptions = "activeTalents buffActive buffInactive currentCP currentPower inCombat recentlyFired trivialTarget unavailableSkill warriorStance zoneName zoneType"

 return frame
end


-- ****************************************************************************
-- Shows the popup trigger settings frame using the passed config.
-- ****************************************************************************
local function ShowTrigger(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame) then return end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.triggerFrame) then popupFrames.triggerFrame = CreateTriggerPopup() end
 
 -- Set parent.
 local frame = popupFrames.triggerFrame
 ChangePopupParent(frame, configTable.parentFrame)

 
 -- Populate data.
 local triggerKey = configTable.triggerKey
 local settings = MSBTProfiles.currentProfile.triggers[triggerKey]
 frame.titleFontString:SetText(configTable.title) 

 -- Classes.
 EraseTable(frame.classes)
 if (settings.classes) then
  for className in string.gmatch(settings.classes, "[^,]+") do
   frame.classes[className] = true
  end
 else
  frame.classes["ALL"] = true
 end
 UpdateClassesText()

 -- Main events.
 local conditions
 EraseTable(frame.mainEvents)
 EraseTable(frame.eventConditions)
 if (settings.mainEvents) then
  for eventType, eventConditions in string.gmatch(settings.mainEvents .. "&&", "(.-)%{(.-)%}&&") do
   frame.mainEvents[#frame.mainEvents+1] = eventType
   conditions = {}
   if (eventConditions ~= "") then
    for conditionEntry in string.gmatch(eventConditions .. ";;", "(.-);;") do
     conditions[#conditions+1] = ConvertType(conditionEntry)
    end
   end
   frame.eventConditions[#frame.eventConditions+1] = conditions
  end
 end
 UpdateMainEvents()
 
 -- Exceptions.
 EraseTable(frame.exceptions)
 if (settings.exceptions and settings.exceptions ~= "") then
  for exceptionCondition in string.gmatch(settings.exceptions .. ";;", "(.-);;") do
   frame.exceptions[#frame.exceptions+1] = ConvertType(exceptionCondition)
  end
 end
 UpdateExceptions()

 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler
 frame.saveArg1 = configTable.saveArg1
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Item list frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Enables the controls on the item list popup.
-- ****************************************************************************
local function EnableItemListControls()
 for name, frame in pairs(popupFrames.itemListFrame.controls) do
  if (frame.Enable) then frame:Enable() end
 end
end


-- ****************************************************************************
-- Validates if the passed item name does not already exist and is valid.
-- ****************************************************************************
local function ValidateItemListName(itemName)
 if (not itemName or itemName == "") then
  return L.MSG_INVALID_ITEM_NAME
 end

 if (popupFrames.itemListFrame.items[itemName]) then
  return L.MSG_ITEM_ALREADY_EXISTS
 end
end


-- ****************************************************************************
-- Adds the passed item name to the list of items.
-- ****************************************************************************
local function SaveItemListName(settings)
 local itemName = settings.inputText
 local frame = popupFrames.itemListFrame
 frame.items[itemName] = true

 frame.itemsListbox:AddItem(itemName, true)
end


-- ****************************************************************************
-- Called when one of the delete item buttons is pressed.
-- ****************************************************************************
local function DeleteItemButtonOnClick(this)
 local line = this:GetParent()
 popupFrames.itemListFrame.items[line.itemName] = false
 popupFrames.itemListFrame.itemsListbox:RemoveItem(line.itemNumber)
end


-- ****************************************************************************
-- Called by listbox to create a line for item list popup.
-- ****************************************************************************
local function CreateItemListLine(this)
 local controls = popupFrames.itemListFrame.controls
 local frame = CreateFrame("Button", nil, this)
 frame:EnableMouse(false)

 -- Delete item button.
 local button = MSBTControls.CreateIconButton(frame, "Delete")
 local objLocale = L.BUTTONS["deleteItem"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
 button:SetClickHandler(DeleteItemButtonOnClick)
 frame.deleteButton = button
 controls[#controls+1] = button

 -- Item name text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", frame, "LEFT", 5, 0)
 fontString:SetPoint("RIGHT", frame.deleteButton, "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 fontString:SetTextColor(1, 1, 1)
 frame.itemFontString = fontString

 return frame
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function DisplayItemListLine(this, line, key, isSelected)
 local frame = popupFrames.itemListFrame
 line.itemName = key
 line.itemFontString:SetText(key)
end



-- ****************************************************************************
-- Creates the popup item list frame.
-- ****************************************************************************
local function CreateItemList()
 local frame = CreatePopup()
 frame:SetWidth(400)
 frame:SetHeight(300)
 frame.controls = {}
 local controls = frame.controls

 -- Title text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOP", frame, "TOP", 0, -20)
 frame.titleFontString = fontString
 
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -50)
 fontString:SetText(L.MSG_ITEMS .. ":")
 frame.itemsFontString = fontString
 
 -- Add item button.
 local button = MSBTControls.CreateOptionButton(frame)
 local objLocale = L.BUTTONS["addItem"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("LEFT", frame.itemsFontString, "RIGHT", 10, 0)
 button:SetClickHandler(
  function (this)
   local objLocale = L.EDITBOXES["itemName"]
   EraseTable(tempConfig)
   tempConfig.editboxLabel = objLocale.label
   tempConfig.editboxTooltip = objLocale.tooltip
   tempConfig.parentFrame = frame
   tempConfig.anchorFrame = this
   tempConfig.validateHandler = ValidateItemListName
   tempConfig.saveHandler = SaveItemListName
   tempConfig.hideHandler = EnableItemListControls
   DisableControls(controls)
   ShowInput(tempConfig)
  end
 )
 frame.addItemButton = button
 controls[#controls+1] = button
 
 -- Items listbox.
 local listbox = MSBTControls.CreateListbox(frame)
 listbox:Configure(355, 180, 30)
 listbox:SetPoint("TOPLEFT", frame.itemsFontString, "BOTTOMLEFT", 10, -10)
 listbox:SetCreateLineHandler(CreateItemListLine)
 listbox:SetDisplayHandler(DisplayItemListLine)
 frame.itemsListbox = listbox
 controls[#controls+1] = listbox
 
 -- Save button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericSave"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20)
 button:SetClickHandler(
  function (this)
   frame:Hide()
   if (frame.saveHandler) then frame.saveHandler(frame.saveArg1) end
  end
 )
 controls[#controls+1] = button

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericCancel"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20)
 button:SetClickHandler(
  function (this)
   frame:Hide()
  end
 )
 controls[#controls+1] = button
 
 return frame 
end


-- ****************************************************************************
-- Shows the popup skill list frame using the passed config.
-- ****************************************************************************
local function ShowItemList(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame or not configTable.items) then return end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.itemListFrame) then popupFrames.itemListFrame = CreateItemList() end

 -- Set parent.
 local frame = popupFrames.itemListFrame
 ChangePopupParent(frame, configTable.parentFrame)

 
 -- Populate data.
 frame.titleFontString:SetText(configTable.title) 
 
 -- Items.
 frame.items = configTable.items
 frame.itemsListbox:Clear()
 for itemName, value in pairs(configTable.items) do
  if (value) then frame.itemsListbox:AddItem(itemName) end
 end

 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler
 frame.saveArg1 = configTable.saveArg1
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Skill list frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Enables the controls on the skill list popup.
-- ****************************************************************************
local function EnableSkillListControls()
 for name, frame in pairs(popupFrames.skillListFrame.controls) do
  if (frame.Enable) then frame:Enable() end
 end
end


-- ****************************************************************************
-- Validates if the passed skill name does not already exist and is valid.
-- ****************************************************************************
local function ValidateSkillListName(skillName)
 if (not skillName or skillName == "") then
  return L.MSG_INVALID_SKILL_NAME
 end

 if (popupFrames.skillListFrame.skills[skillName]) then
  return L.MSG_SKILL_ALREADY_EXISTS
 end
end


-- ****************************************************************************
-- Adds the passed skill name to the list of skills.
-- ****************************************************************************
local function SaveSkillListName(settings)
 local skillName = settings.inputText
 local frame = popupFrames.skillListFrame
 if (frame.listType == "throttle") then
  frame.skills[skillName] = 3
 elseif (frame.listType == "substitution") then
  frame.skills[skillName] = settings.secondInputText
 else
  frame.skills[skillName] = true
 end

 frame.skillsListbox:AddItem(skillName, true)
end


-- ****************************************************************************
-- Called when one of the delete skill buttons is pressed.
-- ****************************************************************************
local function DeleteSkillButtonOnClick(this)
 local line = this:GetParent()
 popupFrames.skillListFrame.skills[line.skillName] = false
 popupFrames.skillListFrame.skillsListbox:RemoveItem(line.itemNumber)
end


-- ****************************************************************************
-- Called when one of the time slider changes.
-- ****************************************************************************
local function TimeSliderOnValueChanged(this, value)
 local line = this:GetParent()
 popupFrames.skillListFrame.skills[line.skillName] = value
end


-- ****************************************************************************
-- Called by listbox to create a line for skill list popup.
-- ****************************************************************************
local function CreateSkillListLine(this)
 local controls = popupFrames.skillListFrame.controls
 local frame = CreateFrame("Button", nil, this)
 frame:EnableMouse(false)

 -- Delete skill button.
 local button = MSBTControls.CreateIconButton(frame, "Delete")
 local objLocale = L.BUTTONS["deleteSkill"]
 button:SetTooltip(objLocale.tooltip)
 button:SetPoint("RIGHT", frame, "RIGHT", -10, 0)
 button:SetClickHandler(DeleteSkillButtonOnClick)
 frame.deleteButton = button
 controls[#controls+1] = button

 -- Time slider.
 local slider = MSBTControls.CreateSlider(frame)
 objLocale = L.SLIDERS["skillThrottleTime"] 
 slider:Configure(120, objLocale.label, objLocale.tooltip)
 slider:SetPoint("RIGHT", frame.deleteButton, "LEFT", -10, -5)
 slider:SetMinMaxValues(1, 5)
 slider:SetValueStep(1)
 slider:SetValueChangedHandler(TimeSliderOnValueChanged)
 frame.timeSlider = slider
 controls[#controls+1] = slider

 -- Skill name text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", frame, "LEFT", 5, 0)
 fontString:SetPoint("RIGHT", frame.timeSlider, "LEFT", -10, 0)
 fontString:SetJustifyH("LEFT")
 fontString:SetTextColor(1, 1, 1)
 frame.skillFontString = fontString

 return frame
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function DisplaySkillListLine(this, line, key, isSelected)
 local frame = popupFrames.skillListFrame
 line.skillName = key
 if (frame.listType == "throttle") then
  line.skillFontString:SetText(key)
  line.skillFontString:SetPoint("RIGHT", line.timeSlider, "LEFT", -10, 0)
  line.timeSlider:Show()
  line.timeSlider:SetValue(frame.skills[key] or 3)
 elseif (frame.listType == "substitution") then
  line.skillFontString:SetText(key .. " - " .. tostring(frame.skills[key]))
  line.skillFontString:SetPoint("RIGHT", line.deleteButton, "LEFT", -10, 0)
  line.timeSlider:Hide()
 else
  line.skillFontString:SetText(key)
  line.skillFontString:SetPoint("RIGHT", line.deleteButton, "LEFT", -10, 0)
  line.timeSlider:Hide()
 end
end


-- ****************************************************************************
-- Creates the popup skill list frame.
-- ****************************************************************************
local function CreateSkillList()
 local frame = CreatePopup()
 frame:SetWidth(400)
 frame:SetHeight(300)
 frame.controls = {}
 local controls = frame.controls

 -- Title text.
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOP", frame, "TOP", 0, -20)
 frame.titleFontString = fontString
 
 fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("TOPLEFT", frame, "TOPLEFT", 20, -50)
 fontString:SetText(L.MSG_SKILLS .. ":")
 frame.skillsFontString = fontString
 
 -- Add skill button.
 local button = MSBTControls.CreateOptionButton(frame)
 local objLocale = L.BUTTONS["addSkill"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("LEFT", frame.skillsFontString, "RIGHT", 10, 0)
 button:SetClickHandler(
  function (this)
   local objLocale = L.EDITBOXES["skillName"]
   EraseTable(tempConfig)
   tempConfig.editboxLabel = objLocale.label
   tempConfig.editboxTooltip = objLocale.tooltip
   tempConfig.parentFrame = frame
   tempConfig.anchorFrame = this
   tempConfig.validateHandler = ValidateSkillListName
   tempConfig.saveHandler = SaveSkillListName
   tempConfig.hideHandler = EnableSkillListControls
   if (frame.listType == "substitution") then
    objLocale = L.EDITBOXES["substitutionText"]
    tempConfig.showSecondEditbox = true
    tempConfig.secondEditboxLabel = objLocale.label
    tempConfig.secondEditboxTooltip = objLocale.tooltip
   end
   DisableControls(controls)
   ShowInput(tempConfig)
  end
 )
 frame.addSkillButton = button
 controls[#controls+1] = button
 
 -- Skills listbox.
 local listbox = MSBTControls.CreateListbox(frame)
 listbox:Configure(355, 180, 30)
 listbox:SetPoint("TOPLEFT", frame.skillsFontString, "BOTTOMLEFT", 10, -10)
 listbox:SetCreateLineHandler(CreateSkillListLine)
 listbox:SetDisplayHandler(DisplaySkillListLine)
 frame.skillsListbox = listbox
 controls[#controls+1] = listbox
 
 -- Save button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericSave"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMRIGHT", frame, "BOTTOM", -10, 20)
 button:SetClickHandler(
  function (this)
   frame:Hide()
   if (frame.saveHandler) then frame.saveHandler(frame.saveArg1) end
  end
 )
 controls[#controls+1] = button

 -- Cancel button.
 button = MSBTControls.CreateOptionButton(frame)
 objLocale = L.BUTTONS["genericCancel"]
 button:Configure(20, objLocale.label, objLocale.tooltip)
 button:SetPoint("BOTTOMLEFT", frame, "BOTTOM", 10, 20)
 button:SetClickHandler(
  function (this)
   frame:Hide()
  end
 )
 controls[#controls+1] = button
 
 return frame 
end


-- ****************************************************************************
-- Shows the popup skill list frame using the passed config.
-- ****************************************************************************
local function ShowSkillList(configTable)
 -- Don't do anything if required parameters weren't passed.
 if (not configTable or not configTable.anchorFrame or not configTable.parentFrame or not configTable.skills) then return end

 -- Create the frame if it hasn't already been.
 if (not popupFrames.skillListFrame) then popupFrames.skillListFrame = CreateSkillList() end
 
 -- Set parent.
 local frame = popupFrames.skillListFrame
 ChangePopupParent(frame, configTable.parentFrame)

 
 -- Populate data.
 frame.titleFontString:SetText(configTable.title) 
 
 -- Skills.
 frame.listType = configTable.listType
 frame.skills = configTable.skills
 frame.skillsListbox:Clear()
 for skillName, value in pairs(configTable.skills) do
  if (value) then frame.skillsListbox:AddItem(skillName) end
 end

 -- Configure the frame.
 frame.saveHandler = configTable.saveHandler
 frame.saveArg1 = configTable.saveArg1
 frame.hideHandler = configTable.hideHandler
 frame:ClearAllPoints()
 frame:SetPoint(configTable.anchorPoint or "TOPLEFT", configTable.anchorFrame, configTable.relativePoint or "BOTTOMLEFT")
 frame:Show()
 frame:Raise()
end


-------------------------------------------------------------------------------
-- Initialization.
-------------------------------------------------------------------------------

FillLocalizedClassList(CLASS_NAMES);




-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Functions.
module.DisableControls				= DisableControls
module.ShowInput					= ShowInput
module.ShowAcknowledge				= ShowAcknowledge
module.ShowFont						= ShowFont
module.ShowPartialEffects			= ShowPartialEffects
module.ShowDamageColors				= ShowDamageColors
module.ShowClassColors				= ShowClassColors
module.ShowScrollAreaConfig			= ShowScrollAreaConfig
module.ShowScrollAreaSelection		= ShowScrollAreaSelection
module.ShowEvent					= ShowEvent
module.ShowTrigger					= ShowTrigger
module.ShowItemList					= ShowItemList
module.ShowSkillList				= ShowSkillList