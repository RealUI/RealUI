-------------------------------------------------------------------------------
-- Title: MSBT Options Controls
-- Author: Mikord
-------------------------------------------------------------------------------

-- Create module and set its name.
local module = {};
local moduleName = "Controls";
MSBTOptions[moduleName] = module;


-------------------------------------------------------------------------------
-- Private variables.
-------------------------------------------------------------------------------

-- Prevent tainting global _.
local _

-- Backdrop table to be reused for sliders.
local sliderBackdrop;

-- Emphasis shown when a listbox entry is moused over.
local emphasizeFrame;

-- Listbox used for dropdowns.
local dropdownListboxFrame;

-- Used for correctly calculating string widths.
local calcFontString;


-------------------------------------------------------------------------------
-- Listbox functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Shows the highlight frame over the passed line.
-- ****************************************************************************
local function Listbox_ShowHighlight(this, line)
 local highlight = this.highlightFrame;
 highlight:ClearAllPoints();
 highlight:SetParent(line);
 highlight:SetPoint("TOPLEFT");
 highlight:SetPoint("BOTTOMRIGHT");
 highlight:Show();

 if (emphasizeFrame:GetParent() == line) then emphasizeFrame:Hide(); end
end


-- ****************************************************************************
-- Shows or hides the scroll bar and resizes the display area as necessary.
-- ****************************************************************************
local function Listbox_HandleScrollbar(this)
 -- Show or hide the scroll bar if there are more items than will fit on the page.
 local display = this.displayFrame;
 local slider = this.sliderFrame;
 if (#this.items <= #this.lines) then
  slider:Hide();
  display:SetPoint("BOTTOMRIGHT");
 else
  display:SetPoint("BOTTOMRIGHT", display:GetParent(), "BOTTOMRIGHT", -16, 0); 
  slider:Show();
 end
end


-- ****************************************************************************
-- Returns whether the listbox is fully configured.
-- ****************************************************************************
local function Listbox_IsConfigured(this)
 return this.configured and this.lineHandler and this.displayHandler;
end


-- ****************************************************************************
-- Returns the current offset.
-- ****************************************************************************
local function Listbox_GetOffset(this)
 return this.sliderFrame:GetValue();
end


-- ****************************************************************************
-- Returns the current offset.
-- ****************************************************************************
local function Listbox_SetOffset(this, offset)
 this.sliderFrame:SetValue(offset);
end


-- ****************************************************************************
-- Called when the listbox needs to be refreshed.
-- ****************************************************************************
local function Listbox_Refresh(this)
 -- Don't do anything if the listbox isn't configured.
 if (not Listbox_IsConfigured(this)) then return; end
 
 -- Handle scroll bar showing / resizing.
 Listbox_HandleScrollbar(this);
 
 -- Hide the highlight.
 this.highlightFrame:Hide(); 

 -- Show or hide the correct lines depending on how many items there are and
 -- apply a highlight to the selected item.
 local selectedItem = this.selectedItem;
 local isSelected;
 for lineNum, line in ipairs(this.lines) do
  if (lineNum > #this.items) then
   line:Hide();
  else
   line.itemNumber = lineNum + Listbox_GetOffset(this);
   line:Show();

   -- Move the highlight to the selected line and show it.
   if (selectedItem == line.itemNumber) then
    Listbox_ShowHighlight(this, line);
 	isSelected = true
   else
    isSelected = false;
   end
   
   if (this.displayHandler) then this:displayHandler(line, this.items[line.itemNumber], isSelected); end
  end
 end
end


-- ****************************************************************************
-- Called when the listbox is scrolled up.
-- ****************************************************************************
local function Listbox_ScrollUp(this)
 local slider = this.sliderFrame;
 slider:SetValue(slider:GetValue() -  slider:GetValueStep());
end


-- ****************************************************************************
-- Called when the listbox is scrolled down.
-- ****************************************************************************
local function Listbox_ScrollDown(this)
 local slider = this.sliderFrame;
 slider:SetValue(slider:GetValue() + slider:GetValueStep());
end


-- ****************************************************************************
-- Called when one of the lines in the listbox is clicked.
-- ****************************************************************************
local function Listbox_OnClickLine(this)
 local listbox = this:GetParent():GetParent();
 listbox.selectedItem = this.lineNumber + Listbox_GetOffset(listbox);

 Listbox_ShowHighlight(listbox, this);
 
 if (listbox.clickHandler) then listbox:clickHandler(this, listbox.items[listbox.selectedItem]); end
end


-- ****************************************************************************
-- Called when the mouse enters a line.
-- ****************************************************************************
local function Listbox_OnEnterLine(this)
 local listbox = this:GetParent():GetParent();
 if (this.itemNumber ~= listbox.selectedItem) then
  emphasizeFrame:ClearAllPoints();
  emphasizeFrame:SetParent(this);
  emphasizeFrame:SetPoint("TOPLEFT");
  emphasizeFrame:SetPoint("BOTTOMRIGHT");
  emphasizeFrame:Show();
 end
 
 if (this.tooltip) then
  GameTooltip:SetOwner(this, this.tooltipAnchor or "ANCHOR_RIGHT");
  GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1);
 end 
end


-- ****************************************************************************
-- Called when the mouse leaves a line.
-- ****************************************************************************
local function Listbox_OnLeaveLine(this)
 emphasizeFrame:Hide();
 GameTooltip:Hide();
end


-- ****************************************************************************
-- Called when the scroll up button is pressed.
-- ****************************************************************************
local function Listbox_OnClickUp(this)
 local listbox = this:GetParent():GetParent();
 Listbox_ScrollUp(listbox);
 PlaySound("UChatScrollButton");
end


-- ****************************************************************************
-- Called when the scroll down button is pressed.
-- ****************************************************************************
local function Listbox_OnClickDown(this)
 local listbox = this:GetParent():GetParent();
 Listbox_ScrollDown(listbox);
 PlaySound("UChatScrollButton");
end


-- ****************************************************************************
-- Called when the mouse wheel is scrolled in the display frame.
-- ****************************************************************************
local function Listbox_OnMouseWheel(this, delta)
 local listbox = this:GetParent();
 if (delta < 0) then
  Listbox_ScrollDown(listbox);
 elseif (delta > 0) then
  Listbox_ScrollUp(listbox);
 end
end


-- ****************************************************************************
-- Called when the scroll bar slider is changed.
-- ****************************************************************************
local function Listbox_OnValueChanged(this, value)
 Listbox_Refresh(this:GetParent());
end


-- ****************************************************************************
-- Creates a new line using the register create line handler.
-- ****************************************************************************
local function Listbox_CreateLine(this)
 -- Get a line from cache if there are any otherwise call the registered line
 -- handler to create a new line.
 local lineCache = this.lineCache;
 local line = (#lineCache > 0) and table.remove(lineCache) or this:lineHandler(); 
 
 line:SetParent(this.displayFrame);
 line:SetHeight(this.lineHeight);
 line:ClearAllPoints();
 line:SetScript("OnClick", Listbox_OnClickLine);
 line:SetScript("OnEnter", Listbox_OnEnterLine);
 line:SetScript("OnLeave", Listbox_OnLeaveLine);

 local lines = this.lines;
 if (#lines == 0) then
  line:SetPoint("TOPLEFT");
  line:SetPoint("TOPRIGHT");
 else
  line:SetPoint("TOPLEFT", lines[#lines], "BOTTOMLEFT");
  line:SetPoint("TOPRIGHT", lines[#lines], "BOTTOMRIGHT");
 end

 lines[#lines+1] = line;
 line.lineNumber = #lines;
end


-- ****************************************************************************
-- Reconfigures the listbox if it was already configured.
-- ****************************************************************************
local function Listbox_Reconfigure(this, width, height, lineHeight)
 -- Don't allow negative widths.
 if (width < 0) then width = 0; end

 -- Setup container frame.
 this:SetWidth(width);
 this:SetHeight(height);
 
 -- Setup line calculations.
 this.lineHeight = lineHeight;
 this.linesPerPage = math.floor(height / lineHeight);

 -- Resize the line height of existing lines.
 for _, line in ipairs(this.lines) do
  line:SetHeight(this.lineHeight);
 end
 
 -- Add lines if more will fit on the page and they are needed.
 local lines = this.lines;
 if (#this.items > #lines) then
  while (#lines < this.linesPerPage and #this.items > #lines) do
   Listbox_CreateLine(this);
  end
 end

 -- Remove and cache lines that will no longer fit on the page.
 local lineCache = this.lineCache;
 for x = this.linesPerPage+1, #lines do
  lines[#lines]:Hide();
  lineCache[#lineCache+1] = table.remove(lines);
 end

 -- Setup slider frame.
 local slider = this.sliderFrame;
 slider:Hide();
 slider:SetMinMaxValues(0, math.max(#this.items - #this.lines, 0));
 slider:SetValue(0);

 Listbox_Refresh(this);
end


-- ****************************************************************************
-- Configures the listbox.
-- ****************************************************************************
local function Listbox_Configure(this, width, height, lineHeight)
 -- Don't do anything if required parameters are invalid.
 if (not width or not height or not lineHeight) then return; end
 
 if (Listbox_IsConfigured(this)) then Listbox_Reconfigure(this, width, height, lineHeight); return; end
 
 -- Don't allow negative widths.
 if (width < 0) then width = 0; end
 
 -- Setup container frame.
 this:SetWidth(width);
 this:SetHeight(height);
 
 -- Setup slider frame.
 local slider = this.sliderFrame;
 slider:SetMinMaxValues(0, 0);
 slider:SetValue(0);

 -- Setup line calculations.
 this.lineHeight = lineHeight;
 this.linesPerPage = math.floor(height / lineHeight);
 
 this.configured = true; 
end


-- ****************************************************************************
-- Set the function to be called when a new line needs to be created.  The 
-- called function must return a "Button" frame.
-- ****************************************************************************
local function Listbox_SetCreateLineHandler(this, handler)
 this.lineHandler = handler;
end


-- ****************************************************************************
-- Set the function to be called when a line is being displayed.
-- It is passed the line frame to be populated, and the value associated
-- with that line.
-- ****************************************************************************
local function Listbox_SetDisplayHandler(this, handler)
 this.displayHandler = handler;
end


-- ****************************************************************************
-- Set the function to be called when a line in the listbox is clicked.
-- It is passed the line frame, and the value associated with that line.
-- ****************************************************************************
local function Listbox_SetClickHandler(this, handler)
 this.clickHandler = handler;
end


-- ****************************************************************************
-- Returns the passed item number from the listbox.
-- ****************************************************************************
local function Listbox_GetItem(this, itemNumber)
 return this.items[itemNumber];
end


-- ****************************************************************************
-- Adds the passed item to the listbox.
-- ****************************************************************************
local function Listbox_AddItem(this, key, forceVisible)
 -- Don't do anything if the listbox isn't configured.
 if (not Listbox_IsConfigured(this)) then return; end
 
 -- Add the passed key to the items list. 
 local items = this.items;
 items[#items + 1] = key;

 --  Create a new line if the max number allowed per page hasn't been reached.
 local lines = this.lines; 
 if (#lines < this.linesPerPage) then
  Listbox_CreateLine(this);
 end

 -- Set the new max offset value.
 local maxOffset = math.max(#items - #lines, 0);
 this.sliderFrame:SetMinMaxValues(0, maxOffset);
 
 -- Make sure the newly added item is visible if the force flag is set.
 if (forceVisible) then Listbox_SetOffset(this, maxOffset); end

 Listbox_Refresh(this);
end


-- ****************************************************************************
-- Removes the passed item number from the listbox.
-- ****************************************************************************
local function Listbox_RemoveItem(this, itemNumber)
 -- Don't do anything if the listbox isn't configured.
 if (not Listbox_IsConfigured(this)) then return; end

 local items = this.items;
 table.remove(items, itemNumber);

 -- Set the new max offset value.
 this.sliderFrame:SetMinMaxValues(0, math.max(#items - #this.lines, 0));
 
 Listbox_Refresh(this);
end


-- ****************************************************************************
-- Returns the number of items in the listbox.
-- ****************************************************************************
local function Listbox_GetNumItems(this)
 return #this.items;
end


-- ****************************************************************************
-- Returns the selected item from the listbox.
-- ****************************************************************************
local function Listbox_GetSelectedItem(this)
 if (this.selectedItem ~= 0) then return this.items[this.selectedItem]; end
end


-- ****************************************************************************
-- Sets the selected item for the listbox.
-- ****************************************************************************
local function Listbox_SetSelectedItem(this, itemNumber)
 -- Don't do anything if the listbox isn't configured.
 if (not Listbox_IsConfigured(this)) then return; end

 this.selectedItem = itemNumber <= #this.items and itemNumber or 0;

 -- Highlight the selected line if it's visible.
 local line = this.lines[this.selectedItem - this.sliderFrame:GetValue()];
 if (line) then Listbox_ShowHighlight(this, line); end
end


-- ****************************************************************************
-- Returns the line object from the listbox.
-- ****************************************************************************
local function Listbox_GetLine(this, lineNumber)
 local lines = this.lines;
 if (lineNumber <= #lines) then return lines[lineNumber]; end
end


-- ****************************************************************************
-- Returns the number of lines in the listbox.
-- ****************************************************************************
local function Listbox_GetNumLines(this)
 return math.min(#this.lines, #this.items);
end


-- ****************************************************************************
-- Clears the listbox contents.
-- ****************************************************************************
local function Listbox_Clear(this)
 -- Don't do anything if the listbox isn't configured.
 if (not Listbox_IsConfigured(this)) then return; end

 local items = this.items;
 for k, v in ipairs(items) do
  items[k] = nil;
 end
 
 -- Set the new max offset value.
 this.sliderFrame:SetMinMaxValues(0, 0);
 
 this.selectedItem = 0;
 
 Listbox_Refresh(this);
end


-- ****************************************************************************
-- Disables the listbox.
-- ****************************************************************************
local function Listbox_Disable(this)
 this.displayFrame:EnableMouseWheel(false);
 this.sliderFrame:EnableMouse(false);
 this.upButton:Disable();
 this.downButton:Disable();
end


-- ****************************************************************************
-- Enables the listbox.
-- ****************************************************************************
local function Listbox_Enable(this)
 this.displayFrame:EnableMouseWheel(true);
 this.sliderFrame:EnableMouse(true);
 this.upButton:Enable();
 this.downButton:Enable();
end


-- ****************************************************************************
-- Creates and returns a listbox object ready to be configured.
-- ****************************************************************************
local function CreateListbox(parent)
 -- Create the frame used to emphasize the entry the mouse is over.
 if (not emphasizeFrame) then
  emphasizeFrame = CreateFrame("Frame");
  
  local texture = emphasizeFrame:CreateTexture(nil, "ARTWORK");
  texture:SetTexture("Interface\\QuestFrame\\UI-QuestLogTitleHighlight");
  texture:SetBlendMode("ADD");
  texture:SetPoint("TOPLEFT", emphasizeFrame, "TOPLEFT");
  texture:SetPoint("BOTTOMRIGHT", emphasizeFrame, "BOTTOMRIGHT");
 end

 -- Create container frame.
 local listbox = CreateFrame("Frame", nil, parent);
 
 -- Highlight frame.
 local highlight = CreateFrame("Frame");

 local texture = highlight:CreateTexture(nil, "ARTWORK");
 texture:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight");
 texture:SetBlendMode("ADD");
 texture:SetPoint("TOPLEFT", highlight, "TOPLEFT");
 texture:SetPoint("BOTTOMRIGHT", highlight, "BOTTOMRIGHT");

 -- Create display area.
 local display = CreateFrame("Frame", nil, listbox);
 display:SetPoint("TOPLEFT", listbox, "TOPLEFT");
 display:SetPoint("BOTTOMRIGHT", listbox, "BOTTOMRIGHT");

  
 -- Create slider to track the position.
 local slider = CreateFrame("Slider", nil, listbox);
 slider:Hide();
 slider:SetWidth(16);
 slider:SetPoint("TOPRIGHT", listbox, "TOPRIGHT", 0, -16);
 slider:SetPoint("BOTTOMRIGHT", listbox, "BOTTOMRIGHT", 0, 16);
 slider:SetThumbTexture("Interface\\Buttons\\UI-ScrollBar-Knob");
 slider:SetValueStep(1);
 slider:SetObeyStepOnDrag(true);
 slider:SetScript("OnValueChanged", Listbox_OnValueChanged);

 -- Up button.
 local upButton = CreateFrame("Button", nil, slider, "UIPanelScrollUpButtonTemplate");
 upButton:SetPoint("BOTTOM", slider, "TOP");
 upButton:SetScript("OnClick", Listbox_OnClickUp);
 
 -- Down button.
 local downButton = CreateFrame("Button", nil, slider, "UIPanelScrollDownButtonTemplate");
 downButton:SetPoint("TOP", slider, "BOTTOM");
 downButton:SetScript("OnClick", Listbox_OnClickDown);

 
 -- Make it work with the mouse wheel.
 display:EnableMouseWheel(true);
 display:SetScript("OnMouseWheel", Listbox_OnMouseWheel);
 

 -- Extension functions.
 listbox.Configure				= Listbox_Configure;
 listbox.SetCreateLineHandler	= Listbox_SetCreateLineHandler;
 listbox.SetDisplayHandler		= Listbox_SetDisplayHandler;
 listbox.SetClickHandler		= Listbox_SetClickHandler;
 listbox.GetOffset				= Listbox_GetOffset;
 listbox.SetOffset				= Listbox_SetOffset;
 listbox.GetItem				= Listbox_GetItem;
 listbox.AddItem				= Listbox_AddItem;
 listbox.RemoveItem				= Listbox_RemoveItem;
 listbox.GetNumItems			= Listbox_GetNumItems;
 listbox.GetSelectedItem		= Listbox_GetSelectedItem;
 listbox.SetSelectedItem		= Listbox_SetSelectedItem;
 listbox.GetLine				= Listbox_GetLine;
 listbox.GetNumLines			= Listbox_GetNumLines;
 listbox.Refresh				= Listbox_Refresh;
 listbox.Clear					= Listbox_Clear;
 listbox.Disable				= Listbox_Disable;
 listbox.Enable					= Listbox_Enable;

 -- Track internal values.
 listbox.displayFrame = display;
 listbox.sliderFrame = slider;
 listbox.upButton = upButton;
 listbox.downButton = downButton;
 listbox.highlightFrame = highlight;
 listbox.items = {};
 listbox.lines = {};
 listbox.lineCache = {};
 listbox.selectedItem = 0;
 return listbox;
end


-------------------------------------------------------------------------------
-- Checkbox functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when the internal checkbutton is clicked.
-- ****************************************************************************
local function Checkbox_OnClick(this)
 local isChecked = this:GetChecked() and true or false;
 if (isChecked) then PlaySound("igMainMenuOptionCheckBoxOn"); else PlaySound("igMainMenuOptionCheckBoxOff"); end

 local checkbox = this:GetParent();
 if (checkbox.clickHandler) then checkbox:clickHandler(isChecked); end
end


-- ****************************************************************************
-- Called when the mouse enters the internal checkbutton.
-- ****************************************************************************
local function Checkbox_OnEnter(this)
 if (this.tooltip) then
  GameTooltip:SetOwner(this, this.tooltipAnchor or "ANCHOR_RIGHT");
  GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1);
 end
end


-- ****************************************************************************
-- Called when the mouse leaves the internal checkbutton.
-- ****************************************************************************
local function Checkbox_OnLeave(this)
 GameTooltip:Hide();
end


-- ****************************************************************************
-- Sets the label for the checkbox.
-- ****************************************************************************
local function Checkbox_SetLabel(this, label)
 local fontString = this.fontString;
 fontString:SetText(label or "");
 calcFontString:SetText(label or "");
 local width = this.checkFrame:GetWidth() + calcFontString:GetStringWidth() + 2;
 this:SetWidth(math.ceil(width));
end


-- ****************************************************************************
-- Sets the tooltip for the checkbox.
-- ****************************************************************************
local function Checkbox_SetTooltip(this, tooltip)
 this.checkFrame.tooltip = tooltip;
end


-- ****************************************************************************
-- Configures the checkbox.
-- ****************************************************************************
local function Checkbox_Configure(this, size, label, tooltip)
 -- Don't do anything if required parameters are invalid.
 if (not size) then return; end

 -- Setup the container frame.
 this:SetHeight(size);
 
 -- Setup the checkbox dimensions.
 local check = this.checkFrame;
 check:SetWidth(size);
 check:SetHeight(size);

 -- Setup the label and tooltip.
 Checkbox_SetLabel(this, label);
 Checkbox_SetTooltip(this, tooltip);

 this.configured = true;
end


-- ****************************************************************************
-- Sets the function to be called when the checkbox is clicked.
-- It is passed the checkbox and whether or not it's checked.
-- ****************************************************************************
local function Checkbox_SetClickHandler(this, handler)
 this.clickHandler = handler;
end


-- ****************************************************************************
-- Returns whether or not the checkbox is checked.
-- ****************************************************************************
local function Checkbox_GetChecked(this)
 return this.checkFrame:GetChecked() and true or false;
end


-- ****************************************************************************
-- Sets the checked state.
-- ****************************************************************************
local function Checkbox_SetChecked(this, isChecked)
 this.checkFrame:SetChecked(isChecked);
end


-- ****************************************************************************
-- Disables the checkbox.
-- ****************************************************************************
local function Checkbox_Disable(this)
 this.checkFrame:Disable();
 this.fontString:SetTextColor(0.5, 0.5, 0.5);
end


-- ****************************************************************************
-- Enables the checkbox.
-- ****************************************************************************
local function Checkbox_Enable(this)
 this.checkFrame:Enable();
 this.fontString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
end


-- ****************************************************************************
-- Creates and returns a checkbox object ready to be configured.
-- ****************************************************************************
local function CreateCheckbox(parent)
 -- XXX Hack to work around apparent WoW API bug not returning correct string width.
 if (not calcFontString) then
  calcFontString = UIParent:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall");
 end
 
 -- Create container frame.
 local checkbox = CreateFrame("Frame", nil, parent);

 -- Create check button.
 local checkbutton = CreateFrame("CheckButton", nil, checkbox);
 checkbutton:SetPoint("TOPLEFT");
 checkbutton:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up");
 checkbutton:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down");
 checkbutton:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight");
 checkbutton:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled");
 checkbutton:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check");
 checkbutton:SetScript("OnClick", Checkbox_OnClick);
 checkbutton:SetScript("OnEnter", Checkbox_OnEnter);
 checkbutton:SetScript("OnLeave", Checkbox_OnLeave);

 -- Label.
 local fontString = checkbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("LEFT", checkbutton, "RIGHT", 2, 0)
 fontString:SetPoint("RIGHT", checkbox, "RIGHT", 0, 0);
 fontString:SetJustifyH("LEFT");


 -- Extension functions.
 checkbox.Configure			= Checkbox_Configure;
 checkbox.SetLabel			= Checkbox_SetLabel;
 checkbox.SetTooltip		= Checkbox_SetTooltip;
 checkbox.SetClickHandler	= Checkbox_SetClickHandler;
 checkbox.GetChecked		= Checkbox_GetChecked;
 checkbox.SetChecked		= Checkbox_SetChecked;
 checkbox.Disable			= Checkbox_Disable;
 checkbox.Enable			= Checkbox_Enable;
 
 -- Track internal values.
 checkbox.checkFrame = checkbutton;
 checkbox.fontString = fontString;
 return checkbox;
end



-------------------------------------------------------------------------------
-- Button functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when the button is clicked.
-- ****************************************************************************
local function Button_OnClick(this)
 PlaySound("igMainMenuOptionCheckBoxOn");
 if (this.clickHandler) then this:clickHandler(); end
end


-- ****************************************************************************
-- Called when the mouse enters the button.
-- ****************************************************************************
local function Button_OnEnter(this)
 if (this.tooltip) then
  GameTooltip:SetOwner(this, "ANCHOR_RIGHT");
  GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1);
 end
end


-- ****************************************************************************
-- Called when the mouse leaves the button.
-- ****************************************************************************
local function Button_OnLeave(this)
 GameTooltip:Hide();
end


-- ****************************************************************************
-- Sets the tooltip for the button.
-- ****************************************************************************
local function Button_SetTooltip(this, tooltip)
 this.tooltip = tooltip;
end


-- ****************************************************************************
-- Sets the function to be called when the button is clicked.
-- ****************************************************************************
local function Button_SetClickHandler(this, handler)
 this.clickHandler = handler;
end



-- ****************************************************************************
-- Creates and returns a generic button object.  Only used internally.
-- ****************************************************************************
local function CreateButton(parent)
 -- Create button frame.
 local button = CreateFrame("Button", nil, parent);
 button:SetScript("OnClick", Button_OnClick);
 button:SetScript("OnEnter", Button_OnEnter);
 button:SetScript("OnLeave", Button_OnLeave);

 -- Extension functions.
 button.SetClickHandler	= Button_SetClickHandler;
 button.SetTooltip	= Button_SetTooltip; 

 return button;
end


-------------------------------------------------------------------------------
-- OptionButton functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Set the label for the option button.
-- ****************************************************************************
local function OptionButton_SetLabel(this, label)
 this:SetText(label or "");
 this:SetWidth(this:GetFontString():GetStringWidth() + 50);
end


-- ****************************************************************************
-- Configures the option button.
-- ****************************************************************************
local function OptionButton_Configure(this, height, label, tooltip)
 this:SetHeight(height);
 OptionButton_SetLabel(this, label);
 Button_SetTooltip(this, tooltip);
end


-- ****************************************************************************
-- Creates and returns a push button object ready to be configured.
-- ****************************************************************************
local function CreateOptionButton(parent)
 -- Create generic button.
 local button = CreateButton(parent);
 local fontString = button:CreateFontString(nil, "OVERLAY");
 fontString:SetPoint("CENTER");
 button:SetFontString(fontString); 
 button:SetNormalFontObject(GameFontNormalSmall);
 button:SetHighlightFontObject(GameFontHighlightSmall);
 button:SetDisabledFontObject(GameFontDisableSmall); 
 button:SetNormalTexture("Interface\\Buttons\\UI-Panel-Button-Up");
 button:SetPushedTexture("Interface\\Buttons\\UI-Panel-Button-Down");
 button:SetDisabledTexture("Interface\\Buttons\\UI-Panel-Button-Disabled");
 button:SetHighlightTexture("Interface\\Buttons\\UI-Panel-Button-Highlight");
 button:GetNormalTexture():SetTexCoord(0, 0.625, 0, 0.6875);
 button:GetPushedTexture():SetTexCoord(0, 0.625, 0, 0.6875);
 button:GetDisabledTexture():SetTexCoord(0, 0.625, 0, 0.6875);
 button:GetHighlightTexture():SetTexCoord(0, 0.625, 0, 0.6875);


 -- Extension functions.
 button.SetLabel		= OptionButton_SetLabel;
 button.Configure		= OptionButton_Configure;

 return button;
end


-------------------------------------------------------------------------------
-- IconButton functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Creates and returns an icon button object ready to be configured.
-- ****************************************************************************
local function CreateIconButton(parent, buttonType)
 -- Create generic button.
 local button = CreateButton(parent);
 button:SetWidth(24);
 button:SetHeight(24);
 button:SetNormalTexture("Interface\\Addons\\MSBTOptions\\Artwork\\" .. buttonType .. "Icon");
 button:SetDisabledTexture("Interface\\Addons\\MSBTOptions\\Artwork\\" .. buttonType .. "IconDisable");
 button:SetHighlightTexture("Interface\\Addons\\MSBTOptions\\Artwork\\" .. buttonType .. "IconHighlight");

 return button;
end


-------------------------------------------------------------------------------
-- Slider functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when the value of the slider changes.
-- ****************************************************************************
local function Slider_OnValueChanged(this, value)
 local slider = this:GetParent();
 if (slider.labelText ~= "") then
  slider.labelFontString:SetText(slider.labelText .. ": " .. value);
 else
  slider.labelFontString:SetText(value);
 end
 if (slider.valueChangedHandler) then slider:valueChangedHandler(value); end
end


-- ****************************************************************************
-- Called when the mouse enters the slider.
-- ****************************************************************************
local function Slider_OnEnter(this)
 if (this.tooltip) then
  GameTooltip:SetOwner(this, this.tooltipAnchor or "ANCHOR_RIGHT");
  GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1);
 end
end


-- ****************************************************************************
-- Called when the mouse leaves the slider.
-- ****************************************************************************
local function Slider_OnLeave(this)
 GameTooltip:Hide();
end


-- ****************************************************************************
-- Sets the label for the slider.
-- ****************************************************************************
local function Slider_SetLabel(this, label)
 this.labelText = label or "";
 if (this.labelText ~= "") then 
  this.labelFontString:SetText(this.labelText .. ": " .. this:GetValue());
 else
  this.labelFontString:SetText(this:GetValue());
 end
end


-- ****************************************************************************
-- Sets the tooltip for the slider.
-- ****************************************************************************
local function Slider_SetTooltip(this, tooltip)
 this.sliderFrame.tooltip = tooltip;
end


-- ****************************************************************************
-- Configures the slider.
-- ****************************************************************************
local function Slider_Configure(this, width, label, tooltip)
 this:SetWidth(width);
 Slider_SetLabel(this, label);
 Slider_SetTooltip(this, tooltip);
end


-- ****************************************************************************
-- Sets the function to be called when the value of the slider is changed.
-- It is passed the slider and the new value.
-- ****************************************************************************
local function Slider_SetValueChangedHandler(this, handler)
 this.valueChangedHandler = handler;
end


-- ****************************************************************************
-- Sets the minimum and maximum values for the slider.
-- ****************************************************************************
local function Slider_SetMinMaxValues(this, minValue, maxValue)
 this.sliderFrame:SetMinMaxValues(minValue, maxValue);
end


-- ****************************************************************************
-- Sets how far the slider moves with each "tick."
-- ****************************************************************************
local function Slider_SetValueStep(this, value)
 this.sliderFrame:SetValueStep(value);
end


-- ****************************************************************************
-- Sets the current value of the slider.
-- ****************************************************************************
local function Slider_GetValue(this)
 return this.sliderFrame:GetValue();
end


-- ****************************************************************************
-- Sets the current value of the slider.
-- ****************************************************************************
local function Slider_SetValue(this, value)
 this.sliderFrame:SetValue(value);
end


-- ****************************************************************************
-- Disables the slider.
-- ****************************************************************************
local function Slider_Disable(this)
 this.sliderFrame:EnableMouse(false);
 this.labelFontString:SetTextColor(0.5, 0.5, 0.5);
end


-- ****************************************************************************
-- Enables the slider.
-- ****************************************************************************
local function Slider_Enable(this)
 this.sliderFrame:EnableMouse(true);
 this.labelFontString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
end


-- ****************************************************************************
-- Creates and returns a slider object ready to be configured.
-- ****************************************************************************
local function CreateSlider(parent)
 -- Create the backdrop table if it hasn't already been so it can be reused.
 if (not sliderBackdrop) then
  sliderBackdrop = {
   bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
   edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
   tile = true, tileSize = 8, edgeSize = 8,
   insets = {left=3, right=3, top=6, bottom=6},
  }
 end

 -- Create container frame.
 local slider = CreateFrame("Frame", nil, parent);
 slider:SetHeight(30); 

 -- Create slider.
 local sliderFrame = CreateFrame("Slider", nil, slider);
 sliderFrame:SetOrientation("HORIZONTAL");
 sliderFrame:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal");
 sliderFrame:SetPoint("LEFT");
 sliderFrame:SetPoint("RIGHT");
 sliderFrame:SetHeight(16);
 sliderFrame:SetBackdrop(sliderBackdrop);
 sliderFrame:SetObeyStepOnDrag(true)
 sliderFrame:SetScript("OnValueChanged", Slider_OnValueChanged);
 sliderFrame:SetScript("OnEnter", Slider_OnEnter);
 sliderFrame:SetScript("OnLeave", Slider_OnLeave);
 

 -- Label. 
 local label = slider:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 label:SetPoint("BOTTOM", sliderFrame, "TOP", 0, 0);

 -- Extension functions.
 slider.Configure				= Slider_Configure;
 slider.SetLabel				= Slider_SetLabel;
 slider.SetTooltip				= Slider_SetTooltip;
 slider.SetValueChangedHandler	= Slider_SetValueChangedHandler;
 slider.SetMinMaxValues			= Slider_SetMinMaxValues;
 slider.SetValueStep			= Slider_SetValueStep;
 slider.GetValue				= Slider_GetValue;
 slider.SetValue				= Slider_SetValue;
 slider.Enable					= Slider_Enable;
 slider.Disable					= Slider_Disable;

 
 -- Track internal values.
 slider.sliderFrame = sliderFrame;
 slider.labelFontString = label;
 slider.labelText = ""; 
 return slider;
end


-------------------------------------------------------------------------------
-- Dropdown functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Hides the dropdown listbox frame that holds the selections.
-- ****************************************************************************
local function Dropdown_HideSelections(this)
 if (dropdownListboxFrame:IsShown() and dropdownListboxFrame.dropdown == this) then
  dropdownListboxFrame:Hide();
 end
end

-- ****************************************************************************
-- Called when the mouse enters the dropdown.
-- ****************************************************************************
local function Dropdown_OnEnter(this)
 if (this.tooltip) then
  GameTooltip:SetOwner(this, this.tooltipAnchor or "ANCHOR_RIGHT");
  GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1);
 end 
end


-- ****************************************************************************
-- Called when the mouse leaves the dropdown.
-- ****************************************************************************
local function Dropdown_OnLeave(this)
 GameTooltip:Hide();
end


-- ****************************************************************************
-- Called when the dropdown is hidden.
-- ****************************************************************************
local function Dropdown_OnHide(this)
 Dropdown_HideSelections(this);
end


-- ****************************************************************************
-- Called when the button for the dropdown is pressed.
-- ****************************************************************************
local function Dropdown_OnClick(this)
 -- Close the listbox and exit if it's already open for the dropdown. 
 local dropdown = this:GetParent();
 if (dropdownListboxFrame:IsShown() and dropdownListboxFrame.dropdown == dropdown) then
  dropdownListboxFrame:Hide();
  return;
 end

 -- Resize and move the dropdown listbox frame for the clicked dropdown.
 local height = #dropdown.items * 20;
 local listboxHeight = dropdown.listboxHeight or 140;
 local listboxWidth = dropdown.listboxWidth or dropdown:GetWidth() + 20;
 height = math.max(math.min(height, listboxHeight), 20);
 dropdownListboxFrame:SetParent(dropdown:GetParent());
 dropdownListboxFrame:SetHeight(height + 24);
 dropdownListboxFrame:SetWidth(listboxWidth);
 dropdownListboxFrame:ClearAllPoints();
 dropdownListboxFrame:SetPoint("TOPLEFT", dropdown, "BOTTOMLEFT");
 dropdownListboxFrame.dropdown = dropdown;

 -- Setup the listbox.
 local listbox = dropdownListboxFrame.listbox;
 Listbox_Clear(listbox);
 listbox:SetPoint("TOPLEFT", dropdownListboxFrame, "TOPLEFT", 8, -12);
 listbox:SetPoint("BOTTOMRIGHT", dropdownListboxFrame, "BOTTOMRIGHT", -12, 12);
 Listbox_Configure(listbox, 0, height, 20);
 for itemNum in ipairs(dropdown.items) do
  Listbox_AddItem(listbox, itemNum);
 end
 Listbox_SetSelectedItem(listbox, dropdown.selectedItem);
 Listbox_SetOffset(listbox, dropdown.selectedItem - 1);

 dropdownListboxFrame:Show();
 dropdownListboxFrame:Raise();
end


-- ****************************************************************************
-- Called by listbox to create a line.
-- ****************************************************************************
local function Dropdown_CreateLine(this)
 local frame = CreateFrame("Button", nil, this);
 
 local fontString = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 fontString:SetPoint("LEFT", frame, "LEFT");
 fontString:SetPoint("RIGHT", frame, "RIGHT");
  
 frame.fontString = fontString;
 return frame;
end


-- ****************************************************************************
-- Called by listbox to display a line.
-- ****************************************************************************
local function Dropdown_DisplayLine(this, line, key, isSelected)
 line.fontString:SetText(dropdownListboxFrame.dropdown.items[key]);
 local color = isSelected and HIGHLIGHT_FONT_COLOR or NORMAL_FONT_COLOR;
 line.fontString:SetTextColor(color.r, color.g, color.b);
end


-- ****************************************************************************
-- Called when a line is clicked.
-- ****************************************************************************
local function Dropdown_OnClickLine(this, line, value)
 local dropdown = dropdownListboxFrame.dropdown;
 dropdown.selectedFontString:SetText(dropdown.items[value]);
 dropdown.selectedItem = value;
 dropdownListboxFrame:Hide();
 
 -- Call the registered change handler for the dropdown.
 if (dropdown.changeHandler) then dropdown:changeHandler(dropdown.itemIDs[value]); end
end


-- ****************************************************************************
-- Sets the label for the dropdown.
-- ****************************************************************************
local function Dropdown_SetLabel(this, label)
 this.labelFontString:SetText(label or ""); 
end


-- ****************************************************************************
-- Sets the tooltip for the dropdown.
-- ****************************************************************************
local function Dropdown_SetTooltip(this, tooltip)
 this.tooltip = tooltip; 
end


-- ****************************************************************************
-- Configures the dropdown.
-- ****************************************************************************
local function Dropdown_Configure(this, width, label, tooltip)
 -- Don't do anything if required parameters are invalid. 
 if (not width) then return; end

 -- Set the width of the dropdown and the max height of the listbox is shown. 
 this:SetWidth(width);

 Dropdown_SetLabel(this, label);
 Dropdown_SetTooltip(this, tooltip); 
end


-- ****************************************************************************
-- Sets the max height the listbox frame can be for the dropdown.
-- ****************************************************************************
local function Dropdown_SetListboxHeight(this, height)
 this.listboxHeight = height;
end

-- ****************************************************************************
-- Sets the width of the listbox frame for the dropdown.
-- ****************************************************************************
local function Dropdown_SetListboxWidth(this, width)
 this.listboxWidth = width;
end


-- ****************************************************************************
-- Sets the function to be called when one of the dropdown's options is
-- selected. It is passed the ID for the selected item.
-- ****************************************************************************
local function Dropdown_SetChangeHandler(this, handler)
 this.changeHandler = handler;
end


-- ****************************************************************************
-- Adds the passed text and id to the dropdown.
-- ****************************************************************************
local function Dropdown_AddItem(this, text, id)
 this.items[#this.items+1] = text;
 this.itemIDs[#this.items] = id;
end


-- ****************************************************************************
-- Remove the passed item id from the dropdown.
-- ****************************************************************************
local function Dropdown_RemoveItem(this, id)
 for itemNum, itemID in ipairs(this.itemIDs) do
  if (itemID == id) then
   -- Hide dropdown if it is shown.
   Dropdown_HideSelections(this);
   
   -- Clear the selected item if it's the item being removed.
   if (itemNum == this.selectedItem) then
    this.selectedItem = 0;
	this.selectedFontString:SetText("");
   end

   table.remove(this.items, itemNum);
   table.remove(this.itemIDs, itemNum);
   return;
  end
 end
end


-- ****************************************************************************
-- Clears the dropdown.
-- ****************************************************************************
local function Dropdown_Clear(this)
 local items = this.items;
 for k, v in ipairs(items) do
  items[k] = nil;
 end

 local itemIDs = this.itemIDs;
 for k, v in ipairs(itemIDs) do
  itemIDs[k] = nil;
 end
 
 this.selectedFontString:SetText(nil);
end


-- ****************************************************************************
-- Gets the selected text from the dropdown.
-- ****************************************************************************
local function Dropdown_GetSelectedText(this)
 return this.selectedFontString:GetText();
end


-- ****************************************************************************
-- Gets the selected id from the dropdown.
-- ****************************************************************************
local function Dropdown_GetSelectedID(this)
 if (this.selectedItem) then return this.itemIDs[this.selectedItem]; end
end


-- ****************************************************************************
-- Sets the selected item for the listbox.
-- ****************************************************************************
local function Dropdown_SetSelectedID(this, id)
 for itemNum, itemID in ipairs(this.itemIDs) do
  if (itemID == id) then
   this.selectedFontString:SetText(this.items[itemNum]);
   this.selectedItem = itemNum;
   return;
  end
 end
end


-- ****************************************************************************
-- Sorts the contents of the dropdown.
-- ****************************************************************************
local function Dropdown_Sort(this)
 local selectedID = Dropdown_GetSelectedID(this);

 -- Sort the dropdown items and associated IDs using an insertion sort.
 local items = this.items;
 local itemIDs = this.itemIDs;
 local tempItem, tempID, j;
 for i = 2, #items do
  tempItem = items[i];
  tempID = itemIDs[i];
  j = i - 1;
  while (j > 0 and items[j] > tempItem) do
   items[j + 1] = items[j];
   itemIDs[j + 1] = itemIDs[j];
   j = j - 1;
  end
  items[j + 1] = tempItem;
  itemIDs[j + 1] = tempID;
 end
 
 Dropdown_SetSelectedID(this, selectedID);
end


-- ****************************************************************************
-- Disables the dropdown.
-- ****************************************************************************
local function Dropdown_Disable(this)
 Dropdown_HideSelections(this);
 this.buttonFrame:Disable();
 this:EnableMouse(false);
 this.labelFontString:SetTextColor(0.5, 0.5, 0.5);
 this.selectedFontString:SetTextColor(0.5, 0.5, 0.5);
end


-- ****************************************************************************
-- Enables the dropdown.
-- ****************************************************************************
local function Dropdown_Enable(this)
 this:EnableMouse(true);
 this.buttonFrame:Enable();
 this.labelFontString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
 this.selectedFontString:SetTextColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end


-- ****************************************************************************
-- Creates the listbox frame that dropdowns use.
-- ****************************************************************************
local function Dropdown_CreateListboxFrame(parent)
 dropdownListboxFrame = CreateFrame("Frame", nil, parent);
 dropdownListboxFrame:EnableMouse(true);
 dropdownListboxFrame:SetToplevel(true);
 dropdownListboxFrame:SetFrameStrata("FULLSCREEN_DIALOG");
 dropdownListboxFrame:SetBackdrop{
  bgFile = "Interface\\Addons\\MSBTOptions\\Artwork\\PlainBackdrop",
  edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
  insets = {left = 6, right = 6, top = 6, bottom = 6},
 };
 dropdownListboxFrame:Hide();

 local listbox = CreateListbox(dropdownListboxFrame);
 listbox:SetToplevel(true);
 listbox:SetFrameStrata("FULLSCREEN_DIALOG");
 listbox:SetCreateLineHandler(Dropdown_CreateLine);
 listbox:SetDisplayHandler(Dropdown_DisplayLine);
 listbox:SetClickHandler(Dropdown_OnClickLine);

 dropdownListboxFrame.listbox = listbox;
end


-- ****************************************************************************
-- Creates and returns a dropdown object ready to be configured.
-- ****************************************************************************
local function CreateDropdown(parent)
 -- Create dropdown listbox if it hasn't already been.
 if (not dropdownListboxFrame) then Dropdown_CreateListboxFrame(parent); end
 

 -- Create container frame.
 local dropdown = CreateFrame("Frame", nil, parent);
 dropdown:SetHeight(38);
 dropdown:EnableMouse(true);
 dropdown:SetScript("OnEnter", Dropdown_OnEnter);
 dropdown:SetScript("OnLeave", Dropdown_OnLeave);
 dropdown:SetScript("OnHide", Dropdown_OnHide);

 
 -- Left border.
 local left = dropdown:CreateTexture(nil, "BACKGROUND");
 left:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame");
 left:SetWidth(9);
 left:SetHeight(25);
 left:SetPoint("BOTTOMLEFT");
 left:SetTexCoord(0.125, 0.1953125, 0.28125, 0.671875);

 -- Right border. 
 local right = dropdown:CreateTexture(nil, "BACKGROUND");
 right:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame");
 right:SetWidth(9);
 right:SetHeight(25);
 right:SetPoint("BOTTOMRIGHT");
 right:SetTexCoord(0.7890625, 0.859375, 0.28125, 0.671875);
 
 -- Middle border. 
 local middle = dropdown:CreateTexture(nil, "BACKGROUND");
 middle:SetTexture("Interface\\Glues\\CharacterCreate\\CharacterCreate-LabelFrame");
 middle:SetWidth(76);
 middle:SetHeight(25);
 middle:SetPoint("LEFT", left, "RIGHT", 0, 0);
 middle:SetPoint("RIGHT", right, "LEFT", 0, 0);
 middle:SetTexCoord(0.1953125, 0.7890625, 0.28125, 0.671875);

 -- Label.
 local label = dropdown:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 label:SetPoint("BOTTOMLEFT", left, "TOPLEFT", 2, 2);
 

 -- Dropdown button.
 local button = CreateFrame("Button", nil, dropdown);
 button:SetWidth(24);
 button:SetHeight(24);
 button:SetPoint("BOTTOMRIGHT");
 button:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Up");
 button:SetPushedTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Down");
 button:SetDisabledTexture("Interface\\ChatFrame\\UI-ChatIcon-ScrollDown-Disabled");
 button:SetHighlightTexture("Interface\\Buttons\\UI-Common-MouseHilight");
 button:GetHighlightTexture():SetBlendMode("ADD");
 button:SetScript("OnClick", Dropdown_OnClick);


  -- Selected text.
 local selected = dropdown:CreateFontString(nil, "OVERLAY", "GameFontHighlightSmall");
 selected:SetPoint("LEFT", left, "RIGHT");
 selected:SetPoint("RIGHT", button, "LEFT");
 selected:SetJustifyH("RIGHT");
 
 
 -- Extension functions.
 dropdown.Configure			= Dropdown_Configure;
 dropdown.SetListboxHeight	= Dropdown_SetListboxHeight;
 dropdown.SetListboxWidth	= Dropdown_SetListboxWidth;
 dropdown.SetLabel			= Dropdown_SetLabel;
 dropdown.SetTooltip		= Dropdown_SetTooltip;
 dropdown.SetChangeHandler	= Dropdown_SetChangeHandler;
 dropdown.HideSelections	= Dropdown_HideSelections;
 dropdown.AddItem			= Dropdown_AddItem;
 dropdown.RemoveItem		= Dropdown_RemoveItem;
 dropdown.Clear				= Dropdown_Clear;
 dropdown.GetSelectedText	= Dropdown_GetSelectedText;
 dropdown.GetSelectedID		= Dropdown_GetSelectedID;
 dropdown.SetSelectedID		= Dropdown_SetSelectedID;
 dropdown.Sort				= Dropdown_Sort;
 dropdown.Disable			= Dropdown_Disable;
 dropdown.Enable			= Dropdown_Enable;
 
 -- Track internal values.
 dropdown.selectedFontString = selected;
 dropdown.buttonFrame = button;
 dropdown.labelFontString = label;
 dropdown.items = {};
 dropdown.itemIDs = {};
 dropdown.selectedItem = 0;
 return dropdown;
end


-------------------------------------------------------------------------------
-- Editbox functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Called when the editbox has focus and escape is pressed.
-- ****************************************************************************
local function Editbox_OnEscape(this)
 this:ClearFocus();
 local editbox = this:GetParent();
 if (editbox.escapeHandler) then editbox:escapeHandler(); end
end


-- ****************************************************************************
-- Called when the editbox loses focus.
-- ****************************************************************************
local function Editbox_OnFocusLost(this)
 this:HighlightText(0, 0);
end


-- ****************************************************************************
-- Called when the editbox gains focus.
-- ****************************************************************************
local function Editbox_OnFocusGained(this)
 this:HighlightText();
end


-- ****************************************************************************
-- Called when the text in the editbox changes.
-- ****************************************************************************
local function Editbox_OnTextChanged(this)
 local editbox = this:GetParent();
 if (editbox.textChangedHandler) then editbox:textChangedHandler(); end
end


-- ****************************************************************************
-- Called when the mouse enters the editbox.
-- ****************************************************************************
local function Editbox_OnEnter(this)
 if (this.tooltip) then
  GameTooltip:SetOwner(this, this.tooltipAnchor or "ANCHOR_RIGHT");
  GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1);
 end
end


-- ****************************************************************************
-- Called when the mouse leaves the editbox.
-- ****************************************************************************
local function Editbox_OnLeave(this)
 GameTooltip:Hide();
end


-- ****************************************************************************
-- Sets the label for the editbox.
-- ****************************************************************************
local function Editbox_SetLabel(this, label)
 this.labelFontString:SetText(label);
end


-- ****************************************************************************
-- Sets the tooltip for the editbox.
-- ****************************************************************************
local function Editbox_SetTooltip(this, tooltip)
 this.editboxFrame.tooltip = tooltip;
end


-- ****************************************************************************
-- Configures the editbox.
-- ****************************************************************************
local function Editbox_Configure(this, width, label, tooltip)
 -- Don't do anything if required parameters are invalid.
 if (not width) then return; end
 
 this:SetWidth(width);
 Editbox_SetLabel(this, label);
 Editbox_SetTooltip(this, tooltip);
end


-- ****************************************************************************
-- Sets the handler to be called when the enter button is pressed.
-- ****************************************************************************
local function Editbox_SetEnterHandler(this, handler)
 this.editboxFrame:SetScript("OnEnterPressed", handler);
end


-- ****************************************************************************
-- Sets the handler to be called when the escape button is pressed.
-- ****************************************************************************
local function Editbox_SetEscapeHandler(this, handler)
 this.escapeHandler = handler;
end


-- ****************************************************************************
-- Sets the handler to be called when the text in the editbox changes.
-- ****************************************************************************
local function Editbox_SetTextChangedHandler(this, handler)
 this.textChangedHandler = handler;
end


-- ****************************************************************************
-- Sets the focus to the editbox.
-- ****************************************************************************
local function Editbox_SetFocus(this)
 this.editboxFrame:SetFocus();
end


-- ****************************************************************************
-- Gets the text entered in the editbox.
-- ****************************************************************************
local function Editbox_GetText(this)
 return this.editboxFrame:GetText();
end


-- ****************************************************************************
-- Sets the text entered in the editbox.
-- ****************************************************************************
local function Editbox_SetText(this, text)
 return this.editboxFrame:SetText(text or "");
end


-- ****************************************************************************
-- Disables the editbox.
-- ****************************************************************************
local function Editbox_Disable(this)
 this.editboxFrame:EnableMouse(false);
 this.labelFontString:SetTextColor(0.5, 0.5, 0.5);
end

-- ****************************************************************************
-- Enables the editbox.
-- ****************************************************************************
local function Editbox_Enable(this)
 this.editboxFrame:EnableMouse(true);
 this.labelFontString:SetTextColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b); 
end


-- ****************************************************************************
-- Creates and returns an editbox object ready to be configured.
-- ****************************************************************************
local function CreateEditbox(parent)
 -- Create container frame.
 local editbox = CreateFrame("Frame", nil, parent);
 editbox:SetHeight(32);
 
 -- Create editbox frame.
 local editboxFrame = CreateFrame("Editbox", nil, editbox);
 editboxFrame:SetHeight(20);
 editboxFrame:SetPoint("BOTTOMLEFT", editbox, "BOTTOMLEFT", 5, 0);
 editboxFrame:SetPoint("BOTTOMRIGHT");
 editboxFrame:SetAutoFocus(false);
 editboxFrame:SetFontObject(ChatFontNormal);
 editboxFrame:SetScript("OnEscapePressed", Editbox_OnEscape);
 editboxFrame:SetScript("OnEditFocusLost", Editbox_OnFocusLost);
 editboxFrame:SetScript("OnEditFocusGained", Editbox_OnFocusGained);
 editboxFrame:SetScript("OnTextChanged", Editbox_OnTextChanged);
 editboxFrame:SetScript("OnEnter", Editbox_OnEnter);
 editboxFrame:SetScript("OnLeave", Editbox_OnLeave);
  
 -- Left border.
 local left = editboxFrame:CreateTexture(nil, "BACKGROUND");
 left:SetTexture("Interface\\Common\\Common-Input-Border");
 left:SetWidth(8);
 left:SetHeight(20);
 left:SetPoint("LEFT", editboxFrame, "LEFT", -5, 0);
 left:SetTexCoord(0, 0.0625, 0, 0.625);

 -- Right border. 
 local right = editboxFrame:CreateTexture(nil, "BACKGROUND");
 right:SetTexture("Interface\\Common\\Common-Input-Border");
 right:SetWidth(8);
 right:SetHeight(20);
 right:SetPoint("RIGHT");
 right:SetTexCoord(0.9375, 1, 0, 0.625);
 
 -- Middle border. 
 local middle = editboxFrame:CreateTexture(nil, "BACKGROUND");
 middle:SetTexture("Interface\\Common\\Common-Input-Border");
 middle:SetWidth(10);
 middle:SetHeight(20);
 middle:SetPoint("LEFT", left, "RIGHT", 0, 0);
 middle:SetPoint("RIGHT", right, "LEFT", 0, 0);
 middle:SetTexCoord(0.0625, 0.9375, 0, 0.625);


 -- Label.
 local label = editbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall");
 label:SetPoint("TOPLEFT");
 label:SetPoint("TOPRIGHT");
 label:SetJustifyH("LEFT");


 -- Extension functions.
 editbox.Configure				= Editbox_Configure;
 editbox.SetLabel				= Editbox_SetLabel;
 editbox.SetTooltip				= Editbox_SetTooltip;
 editbox.SetEnterHandler		= Editbox_SetEnterHandler;
 editbox.SetEscapeHandler		= Editbox_SetEscapeHandler;
 editbox.SetTextChangedHandler	= Editbox_SetTextChangedHandler;
 editbox.SetFocus				= Editbox_SetFocus;
 editbox.GetText				= Editbox_GetText;
 editbox.SetText				= Editbox_SetText;
 editbox.Disable				= Editbox_Disable;
 editbox.Enable					= Editbox_Enable;

 
 -- Track internal values.
 editbox.editboxFrame = editboxFrame;
 editbox.labelFontString = label;
 return editbox;
end


-------------------------------------------------------------------------------
-- Colorswatch functions.
-------------------------------------------------------------------------------

-- ****************************************************************************
-- Sets the color of the colorswatch.
-- ****************************************************************************
local function Colorswatch_SetColor(this, r, g, b)
 this.r = r;
 this.g = g;
 this.b = b;
 this:GetNormalTexture():SetVertexColor(r, g, b);
end


-- ****************************************************************************
-- Called when the color picker values change.
-- ****************************************************************************
local function Colorswatch_ColorPickerOnChange(this)
 local colorswatch = ColorPickerFrame.associatedColorSwatch;
 if (not colorswatch) then return; end

 Colorswatch_SetColor(colorswatch, ColorPickerFrame:GetColorRGB());
 if (colorswatch.colorChangedHandler) then colorswatch:colorChangedHandler(); end
end


-- ****************************************************************************
-- Called when the color picker values change.
-- ****************************************************************************
local function Colorswatch_ColorPickerOnCancel(previousValues)
 local colorswatch = ColorPickerFrame.associatedColorSwatch;
 if (not colorswatch) then return; end

 Colorswatch_SetColor(colorswatch, previousValues.r, previousValues.g, previousValues.b);
 if (colorswatch.colorChangedHandler) then colorswatch:colorChangedHandler(); end 
end


-- ****************************************************************************
-- Called when the colorswatch is clicked.
-- ****************************************************************************
local function Colorswatch_OnClick(this)
 local tempR = this.r or 1;
 local tempG = this.g or 1;
 local tempB = this.b or 1;

 ColorPickerFrame.associatedColorSwatch = this;
 ColorPickerFrame.hasOpacity = false;
 ColorPickerFrame.opacity = 1;
 ColorPickerFrame.previousValues = {r = tempR, g = tempG, b = tempB};
 ColorPickerFrame.func = Colorswatch_ColorPickerOnChange;
 ColorPickerFrame.cancelFunc = Colorswatch_ColorPickerOnCancel;
 ColorPickerFrame:SetColorRGB(tempR, tempG, tempB);
 ColorPickerFrame:ClearAllPoints();
 ColorPickerFrame:SetPoint("CENTER", this, "CENTER");
 ColorPickerFrame:Show();
end


-- ****************************************************************************
-- Called when the mouse enters the colorswatch.
-- ****************************************************************************
local function Colorswatch_OnEnter(this)
 if (this.tooltip) then
  GameTooltip:SetOwner(this, this.tooltipAnchor or "ANCHOR_RIGHT");
  GameTooltip:SetText(this.tooltip, nil, nil, nil, nil, 1);
 end

 this.borderTexture:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b);
end


-- ****************************************************************************
-- Called when the mouse leaves the colorswatch.
-- ****************************************************************************
local function Colorswatch_OnLeave(this)
 GameTooltip:Hide();
 this.borderTexture:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);
end


-- ****************************************************************************
-- Sets the handler to be called when the color changes.
-- ****************************************************************************
local function Colorswatch_SetColorChangedHandler(this, handler)
 this.colorChangedHandler = handler;
end


-- ****************************************************************************
-- Sets the tooltip for the colorswatch.
-- ****************************************************************************
local function Colorswatch_SetTooltip(this, tooltip)
 this.tooltip = tooltip;
end


-- ****************************************************************************
-- Disables the colorswatch.
-- ****************************************************************************
local function Colorswatch_Disable(this)
 this:GetNormalTexture():SetVertexColor(0.5, 0.5, 0.5);
 this:oldDisableHandler();
end


-- ****************************************************************************
-- Enables the colorswatch.
-- ****************************************************************************
local function Colorswatch_Enable(this)
 this:oldEnableHandler();
 this:GetNormalTexture():SetVertexColor(this.r, this.g, this.b);
end


-- ****************************************************************************
-- Creates and returns a colorswatch object ready to be configured.
-- ****************************************************************************
local function CreateColorswatch(parent)
 -- Create button frame.
 local colorswatch = CreateFrame("Button", nil, parent);
 colorswatch:SetWidth(16);
 colorswatch:SetHeight(16);
 colorswatch:SetNormalTexture("Interface\\ChatFrame\\ChatFrameColorSwatch");
 colorswatch:SetScript("OnClick", Colorswatch_OnClick);
 colorswatch:SetScript("OnEnter", Colorswatch_OnEnter);
 colorswatch:SetScript("OnLeave", Colorswatch_OnLeave);
 

 -- Border texture.
 local texture = colorswatch:CreateTexture(nil, "BACKGROUND");
 texture:SetTexture("Interface\\ChatFrame\\ChatFrameBackground");
 texture:SetWidth(14);
 texture:SetHeight(14);
 texture:SetPoint("CENTER");
 texture:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b);

 -- Save old disable/enable handlers.
 colorswatch.oldDisableHandler = colorswatch.Disable;
 colorswatch.oldEnableHandler = colorswatch.Enable;

 -- Extension functions.
 colorswatch.SetColorChangedHandler	= Colorswatch_SetColorChangedHandler;
 colorswatch.SetTooltip				= Colorswatch_SetTooltip;
 colorswatch.SetColor				= Colorswatch_SetColor;
 colorswatch.Disable				= Colorswatch_Disable;
 colorswatch.Enable					= Colorswatch_Enable;
 
 -- Track internal values.
 colorswatch.borderTexture = texture;
 return colorswatch;
end




-------------------------------------------------------------------------------
-- Module interface.
-------------------------------------------------------------------------------

-- Protected Functions.
module.CreateListbox			= CreateListbox;
module.CreateCheckbox			= CreateCheckbox;
module.CreateOptionButton		= CreateOptionButton;
module.CreateIconButton			= CreateIconButton;
module.CreateSlider				= CreateSlider;
module.CreateDropdown			= CreateDropdown;
module.CreateEditbox			= CreateEditbox;
module.CreateColorswatch		= CreateColorswatch;