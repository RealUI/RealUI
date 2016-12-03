-------------------------------------------------------------------------------
-- Title: MSBT Options Main
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {}
local moduleName = "Main"
MSBTOptions[moduleName] = module


-------------------------------------------------------------------------------
-- Imports.
-------------------------------------------------------------------------------

-- Local references to various modules for faster access.
local MSBTControls = MSBTOptions.Controls
local L = MikSBT.translations


-------------------------------------------------------------------------------
-- Constants.
-------------------------------------------------------------------------------

local WINDOW_TITLE = "Mik's Scrolling Battle Text " .. MikSBT.VERSION_STRING


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Prevent tainting global _.
local _

-- The main options frame.
local mainFrame

-- Holds all registered popup frames.
local popupFrames = {}

-- Tab info.
local tabData = {}
local tabListbox

-- Scheduling variables.
local waitTable = {}
local waitFrame = nil


-------------------------------------------------------------------------------
-- Tab functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Initializes the frame that is shown when the tab is clicked.
-- ****************************************************************************
local function InitTab(tabInfo)
  local frame = tabInfo.frame
  frame:SetParent(mainFrame)
  frame:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 190, -78)
  frame:SetWidth(400)
  frame:SetHeight(350)
 end


-- ****************************************************************************
-- Adds a new tab to the main options frame that will show the passed frame
-- when selected.
-- ****************************************************************************
local function AddTab(frame, text, tooltip)
 local tabInfo = {}
 tabInfo.text = text
 tabInfo.frame = frame
 tabInfo.tooltip = tooltip

 tabData[#tabData+1] = tabInfo
 
 if (tabListbox) then
  InitTab(tabInfo)
  tabListbox:AddItem(#tabData)
 end
end


-- ****************************************************************************
-- Called by listbox to create a line for the tabs on the left.
-- ****************************************************************************
local function CreateTabLine(this)
 local frame = CreateFrame("Button", nil, this)
 
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
 fontString:SetPoint("LEFT", frame, "LEFT")
 fontString:SetPoint("RIGHT", frame, "RIGHT")
  
 frame.fontString = fontString
 frame.tooltipAnchor = "ANCHOR_LEFT" 
 return frame
end


-- ****************************************************************************
-- Called by listbox to display a line for the tabs on the left.
-- ****************************************************************************
local function DisplayTabLine(this, line, key, isSelected)
 line.fontString:SetText(tabData[key].text)
 line.tooltip = tabData[key].tooltip
 local color = isSelected and HIGHLIGHT_FONT_COLOR or NORMAL_FONT_COLOR
 line.fontString:SetTextColor(color.r, color.g, color.b)
end


-- ****************************************************************************
-- Called when a tab line is clicked.
-- ****************************************************************************
local function OnClickTabLine(this, line, value)
 -- Hide all the tab frames.
 for _, info in ipairs(tabData) do
  info.frame:Hide()
 end

 -- Hide the registered popup frames.
 for frame in pairs(popupFrames) do
  frame:Hide()
 end

 -- Show the tab's associated frame.
 local frame = tabData[value].frame
 if (frame) then frame:Show() end

 -- Force a refresh to the listbox to update the highlight font color.
 tabListbox:Refresh()
end


-------------------------------------------------------------------------------
-- Main options frame functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when the main options frame is hidden.
-- ****************************************************************************
local function OnHideMainFrame(this)
 PlaySound("gsTitleOptionExit")
 -- Hide the registered popup frames.
 for frame in pairs(popupFrames) do
  frame:Hide()
 end
end


-- ****************************************************************************
-- Creates the main options frame.
-- ****************************************************************************
local function CreateMainFrame()
 -- Main frame.
 mainFrame = CreateFrame("Frame", "MSBTMainOptionsFrame", UIParent)
 mainFrame:EnableMouse(true)
 mainFrame:SetMovable(true)
 mainFrame:RegisterForDrag("LeftButton")
 --mainFrame:SetToplevel(true)
 mainFrame:SetClampedToScreen(true)
 mainFrame:SetWidth(608)
 mainFrame:SetHeight(440)
 mainFrame:SetPoint("CENTER")
 mainFrame:SetHitRectInsets(0, 0, 0, 0)
 mainFrame:SetScript("OnHide", OnHideMainFrame)

 mainFrame:SetScript("OnShow", function(self)
   PlaySound("igMainMenuOption")
 end)
 mainFrame:SetScript("OnDragStart", function(self)
   self:StartMoving()
 end)
 mainFrame:SetScript("OnDragStop", function(self)
   self:StopMovingOrSizing()
 end)

 -- Title region.
 --[[local titleRegion = mainFrame:CreateTitleRegion()
 titleRegion:SetWidth(525)
 titleRegion:SetHeight(20)
 titleRegion:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 50, -10)]]

 -- Scroll Icon.
 local texture = mainFrame:CreateTexture(nil, "BACKGROUND")
 texture:SetTexture("Interface\\FriendsFrame\\FriendsFrameScrollIcon")
 texture:SetWidth(64)
 texture:SetHeight(64) 
 texture:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 8, 1)
 
 -- Top left.
 texture = mainFrame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
 texture:SetWidth(256)
 texture:SetHeight(256)
 texture:SetPoint("TOPLEFT")

 -- Top center left.
 texture = mainFrame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
 texture:SetWidth(128)
 texture:SetHeight(256)
 texture:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 256, 0)
 texture:SetTexCoord(0.38, 0.88, 0, 1)

 -- Top center right.
 texture = mainFrame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopLeft")
 texture:SetWidth(128)
 texture:SetHeight(256)
 texture:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 384, 0)
 texture:SetTexCoord(0.45, 0.95, 0, 1)

 -- Top right.
 texture = mainFrame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
 texture:SetWidth(100)
 texture:SetHeight(256)
 texture:SetPoint("TOPRIGHT")
 texture:SetTexCoord(0, 0.78125, 0, 1)

 -- Bottom left.
 texture = mainFrame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
 texture:SetWidth(256)
 texture:SetHeight(184)
 texture:SetPoint("BOTTOMLEFT")
 texture:SetTexCoord(0, 1, 0, 0.71875)

 -- Bottom center left.
 texture = mainFrame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
 texture:SetWidth(128)
 texture:SetHeight(184)
 texture:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 256, 0)
 texture:SetTexCoord(0.5, 1, 0, 0.71875)

 -- Bottom center right.
 texture = mainFrame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomLeft")
 texture:SetWidth(128)
 texture:SetHeight(184)
 texture:SetPoint("BOTTOMLEFT", mainFrame, "BOTTOMLEFT", 384, 0)
 texture:SetTexCoord(0.5, 1, 0, 0.71875)
 
 -- Bottom right.
 texture = mainFrame:CreateTexture(nil, "ARTWORK")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-BottomRight")
 texture:SetWidth(100)
 texture:SetHeight(184)
 texture:SetPoint("BOTTOMRIGHT")
 texture:SetTexCoord(0, 0.78125, 0, 0.71875)

 -- Top vertical. 
 texture = mainFrame:CreateTexture(nil, "OVERLAY")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
 texture:SetWidth(8)
 texture:SetHeight(184)
 texture:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 180, -72)
 texture:SetTexCoord(0.648437, 0.7109375, 0.28125, 1.0)
 
 -- Bottom vertical. 
 texture = mainFrame:CreateTexture(nil, "OVERLAY")
 texture:SetTexture("Interface\\PaperDollInfoFrame\\UI-Character-General-TopRight")
 texture:SetWidth(8)
 texture:SetHeight(174)
 texture:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 180, -256)
 texture:SetTexCoord(0.648437, 0.7109375, 0.3203125, 1.0)
 
 -- Window title.
 local fontString = mainFrame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
 fontString:SetText(WINDOW_TITLE)
 fontString:SetPoint("TOP", mainFrame, "TOP", 0, -18)
 
 -- Close Button.
 local frame = CreateFrame("Button", nil, mainFrame, "UIPanelCloseButton")
 frame:SetPoint("TOPRIGHT", mainFrame, "TOPRIGHT", -3, -8)

 
 -- Setup the tabs listbox. 
 tabListbox = MSBTControls.CreateListbox(mainFrame)
 tabListbox:Configure(150, 350, 20)
 tabListbox:SetPoint("TOPLEFT", mainFrame, "TOPLEFT", 30, -78)
 tabListbox:SetCreateLineHandler(CreateTabLine)
 tabListbox:SetDisplayHandler(DisplayTabLine)
 tabListbox:SetClickHandler(OnClickTabLine)
 
 -- Add registered tabs.
 for k, tabInfo in ipairs(tabData) do
  InitTab(tabInfo)
  tabListbox:AddItem(k)
 end

 -- Select the general tab.
 tabListbox:SetSelectedItem(2)
 tabListbox:Refresh()
 tabData[2].frame:Show()
 
 -- Insert the frame name into the UISpecialFrames array so it closes when
 -- the escape key is pressed.
 table.insert(UISpecialFrames, mainFrame:GetName())
end


-- ****************************************************************************
-- Shows the main options frame after creating it (if it hasn't already been).
-- ****************************************************************************
local function ShowMainFrame()
 if (not mainFrame) then CreateMainFrame() end
 if (not MSBTScrollAreasConfigFrame or not MSBTScrollAreasConfigFrame:IsShown()) then 
  mainFrame:Show()
 end
end


-- ****************************************************************************
-- Hides the main options frame.
-- ****************************************************************************
local function HideMainFrame()
 mainFrame:Hide()
end


-- ****************************************************************************
-- Registers frames that float above the main options window.
-- These frames will be hidden when a tab is selected or the main options
-- window is hidden.
-- ****************************************************************************
local function RegisterPopupFrame(frame)
 if (not popupFrames[frame]) then popupFrames[frame] = true end
end


-------------------------------------------------------------------------------
-- Scheduling functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Registers frames that float above the main options window.
-- These frames will be hidden when a tab is selected or the main options
-- window is hidden.
-- ****************************************************************************
local function ScheduleCallback(delay, func, ...)
 if (waitFrame == nil) then
  waitFrame = CreateFrame("Frame", nil, UIParent)
  waitFrame:SetScript("OnUpdate",function (self, elapsed)
   local count = #waitTable
   local i = 1
   while (i <= count) do
    local waitRecord = tremove(waitTable, i)
    local duration = tremove(waitRecord, 1)
    local func = tremove(waitRecord, 1)
    local params = tremove(waitRecord, 1)
    if (duration > elapsed) then
     tinsert(waitTable, i, {duration - elapsed, func, params})
     i = i + 1
    else
     count = count - 1
     func(unpack(params))
    end
   end
  end)
 end
 tinsert(waitTable, {delay, func, {...}})
 return true
end



-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Functions.
module.ShowMainFrame       = ShowMainFrame
module.HideMainFrame	   = HideMainFrame
module.RegisterPopupFrame  = RegisterPopupFrame
module.AddTab              = AddTab
module.ScheduleCallback    = ScheduleCallback