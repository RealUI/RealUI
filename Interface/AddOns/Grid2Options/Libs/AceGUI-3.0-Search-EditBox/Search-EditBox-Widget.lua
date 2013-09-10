local AceGUI = LibStub("AceGUI-3.0")

local Type = "SearchEditBox_Base"
local Version = 1
local PREDICTOR_ROWS = 15
local predictorBackdrop = {
  bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Border",
  edgeSize = 26,
  insets = {left = 9, right = 9, top = 9, bottom = 9},
}
local queryResult = {}

-- {{ AceGUI object
local function Fire(self, method, ...)
	local options = self.options
	local func = options[method]
	if func then
		local handler = options.handler or options
		if type(func)=="string" then func = handler[func] end
		return func(handler, ...)
	end	
end	

local function OnAcquire(self)
	self:SetWidth(200)
	self:SetHeight(26)
	self:SetDisabled(false)
	self:SetLabel()
	self.showButton = true
end

local function OnRelease(self)
	self.frame:ClearAllPoints()
	self.frame:Hide()
	self.predictor:Hide()
	self.spellFilter = nil
	self:SetDisabled(false)
end

local function SetDisabled(self, disabled)
	self.disabled = disabled
	if( disabled ) then
		self.editBox:EnableMouse(false)
		self.editBox:ClearFocus()
		self.editBox:SetTextColor(0.5, 0.5, 0.5)
		self.label:SetTextColor(0.5, 0.5, 0.5)
	else
		self.editBox:EnableMouse(true)
		self.editBox:SetTextColor(1, 1, 1)
		self.label:SetTextColor(1, 0.82, 0)
	end
end

local function ShowButton(self)
	local predictor = self.predictor
	if self.lastText ~= "" then
		predictor.selectedButton = nil
		predictor:Query(self)  -- Dont remove self param, its not a bug
	else
		predictor:Hide()
	end
	if self.showButton then
		self.button:Show()
		self.editBox:SetTextInsets(0, 20, 3, 3)
	end
end

local function HideButton(self)
	self.button:Hide()
	self.editBox:SetTextInsets(0, 0, 3, 3)
	self.predictor.selectedButton = nil
	self.predictor:Hide()
end

local function SetText(self, text)
	self.lastText = text or ""
	self.editBox:SetText(self.lastText)
	self.editBox:SetCursorPosition( string.len(self.lastText) )
	HideButton(self)
end

local function SetLabel(self, text)
	if( text and text ~= "" ) then
		self.label:SetText(text)
		self.label:Show()
		self.editBox:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 7, -18)
		self:SetHeight(44)
		self.alignoffset = 30
	else
		self.label:SetText("")
		self.label:Hide()
		self.editBox:SetPoint("TOPLEFT", self.frame, "TOPLEFT", 7, 0)
		self:SetHeight(26)
		self.alignoffset = 12
	end
end

local function ValidateValue(self, text, key)
	if self.options.GetValue then
		local value
		key, value = Fire(self, "GetValue", text, key)
		if key and value then text = value end	
	elseif not key then	
		key = text
	end	
	return key, text
end

local function Initialize(self)
	Fire( self, "Initialize" )
	self.initialized = true
end
-- }}

-- {{ Predictor widget
local function Predictor_OnShow(self)
	-- If the user is using an edit box in a configuration, they will live without arrow keys while the predictor
	-- is opened, this also is the only way of getting up/down arrow for browsing the predictor to work.
	self.obj.editBox:SetAltArrowKeyMode(true)
	
	local name = self:GetName()
	SetOverrideBindingClick(self, true, "DOWN", name, 1)
	SetOverrideBindingClick(self, true, "UP", name, -1)
	SetOverrideBindingClick(self, true, "LEFT", name, "LEFT")
	SetOverrideBindingClick(self, true, "RIGHT", name, "RIGHT")
end

local function Predictor_OnHide(self)
	if self.obj then
		-- Allow users to use arrows to go back and forth again without the fix
		self.obj.editBox:SetAltArrowKeyMode(false)
		-- Make sure the tooltip isn't kept open if one of the buttons was using it
		for _, button in pairs(self.buttons) do
			if( GameTooltip:IsOwned(button) ) then
				GameTooltip:Hide()
			end
		end
		-- Reset all bindings set on this predictor
		ClearOverrideBindings(self)
	end	
end

local function Predictor_OnMouseDown(self, direction)
	-- Fix the cursor positioning if left or right arrow key was used
	if( direction == "LEFT" or direction == "RIGHT" ) then
		-- When using SetAltArrowKeyMode the ability to move the cursor with left and right arrows is disabled
		-- this reenables that so the user doesn't notice anything wrong
		self.obj.editBox:SetCursorPosition(self.obj.editBox:GetCursorPosition() + (direction == "RIGHT" and 1 or -1))
		return
	end
	
	if self.selectedButton then
		local button = self.buttons[self.selectedButton]
		button:UnlockHighlight()
		if GameTooltip:IsOwned(button) then	GameTooltip:Hide() end
	end
	
	self.selectedButton = (self.selectedButton or 0) + direction
	if self.selectedButton > self.activeButtons then
		self.selectedButton = 1
	elseif self.selectedButton <= 0 then
		self.selectedButton = self.activeButtons
	end
	
	local button = self.buttons[self.selectedButton]
	button:LockHighlight()
	GameTooltip:SetOwner(button, "ANCHOR_BOTTOMRIGHT", 3)
	local hyperlink = Fire( self.obj, "GetHyperlink", button.key )
	if hyperlink then GameTooltip:SetHyperlink( hyperlink )	end	
end
		
local function PredictorButton_OnClick(self)
	local obj = self.parent.obj
	local value, text = ValidateValue(obj, obj.editBox:GetText(), self.key )
	if value then
		SetText(obj, text)
		self.parent.selectedButton = nil
		obj:Fire("OnEnterPressed", value ) 
	end	
end

local function PredictorButton_OnEnter(self)
	self:LockHighlight()
	GameTooltip:SetOwner(self, "ANCHOR_BOTTOMRIGHT", 3)
	local hyperlink = Fire( self.parent.obj, "GetHyperlink", self.key )
	if hyperlink then
		GameTooltip:SetHyperlink( hyperlink )
	end	
end

local function PredictorButton_OnLeave(self)
	local predictor = self.parent
	if not predictor.selectedButton or predictor.buttons[predictor.selectedButton] ~= self then
		self:UnlockHighlight()
		GameTooltip:Hide()
	end	
end

local function Predictor_Reset(self, object)
	-- reparent the predictor if necessary
	if self.obj~=object then
		self.obj = object
		self:SetPoint("TOPLEFT" , object.editBox, "BOTTOMLEFT", -6, 0)
		self:SetPoint("TOPRIGHT", object.editBox, "BOTTOMRIGHT", 0, 0)
	end
	-- hiding predictor buttons
	for _, button in pairs(self.buttons) do 
		button:UnlockHighlight()
		button:Hide() 
	end
	-- already done in EditBox FocusGained event, but some times its not fire there (i dont know why)
	if not object.initialized then 
		Initialize(object) 
	end	
	wipe(queryResult)
end

local function Predictor_Query(self, object)
	Predictor_Reset(self,object)
	local activeButtons = 0
	local result = Fire( self.obj, "GetValues", self.obj.editBox:GetText(), queryResult, PREDICTOR_ROWS ) or queryResult
	for key,text in pairs(result) do
		activeButtons = activeButtons + 1
		local button = self.buttons[activeButtons]
		button:SetText( text )
		button.key = key
		button:Show()
		if activeButtons >= PREDICTOR_ROWS then break end
	end
	if activeButtons > 0 then
		self:SetHeight(15 + activeButtons * 14)
		self:Show()
	else
		self:Hide()
	end
	self.activeButtons = activeButtons
end
-- }}

-- {{ Edit_Box widget
local function EditBox_OnEnter(this)
	this.obj:Fire("OnEnter")
end

local function EditBox_OnLeave(this)
	this.obj:Fire("OnLeave")
end

local function EditBox_OnEnterPressed(this)
	local obj = this.obj
	-- Something is selected in the predictor, use that value instead of whatever is in the input box
	if obj.predictor.selectedButton then
		obj.predictor.buttons[obj.predictor.selectedButton]:Click()
		return
	end
	-- validate
	local value, text = ValidateValue(obj, this:GetText() )
	if value then
		if text ~= obj.lastText then
			SetText(obj, text)
		end	
		-- Fire the event
		if not obj:Fire("OnEnterPressed", value) then 
			HideButton(obj)
			return
		end
	end	
	this:SetFocus()
end

local function EditBox_OnEscapePressed(this)
	this:ClearFocus()
end

local function EditBox_OnReceiveDrag(this)
	local obj = this.obj
	local value = Fire(obj, "OnReceiveDrag")
	if value then
		SetText(value)
		obj:Fire("OnEnterPressed", value)
		ClearCursor()
	end
	HideButton(obj)
	AceGUI:ClearFocus()
end

local function EditBox_OnTextChanged(this)
	local obj = this.obj
	local value = this:GetText()
	if value ~= obj.lastText then
		obj:Fire("OnTextChanged", value)
		obj.lastText = value
		ShowButton(obj)
	end
end

local function EditBox_OnEditFocusLost(self)
	local predictor = self.obj.predictor
	if predictor:IsVisible() then
		predictor:Hide()
	end	
end

local function EditBox_OnEditFocusGained(self)
	local obj = self.obj
	if not obj.initialized then
		Initialize(obj)
	end	
	if obj.predictor:IsVisible() then
		Predictor_OnShow(obj.predictor)
	elseif obj.lastText then
		ShowButton(obj)
	end
end
--}}

-- {{ EditBox right button widget
local function Button_OnClick(this)
	EditBox_OnEnterPressed(this.obj.editBox)
end
-- }}

-- This function is only executed once and them removed, because the same predictor frame is used for all widgets
local function CreatePredictorFrame(num)
	local predictor = CreateFrame("Frame", "AceGUI30SearchEditBox" .. num .. "Predictor", UIParent)
	predictor:SetBackdrop(predictorBackdrop)
	predictor:SetBackdropColor(0, 0, 0, 0.85)
	predictor:SetFrameStrata("TOOLTIP")
	predictor:Hide()
	predictor.Query = Predictor_Query
	predictor.buttons = {}
	for i=1, PREDICTOR_ROWS do
		local button = CreateFrame("Button", nil, predictor)
		button:SetSize(1,14)
		button:SetPushedTextOffset(1, 1)
		button:SetScript("OnClick", PredictorButton_OnClick)
		button:SetScript("OnEnter", PredictorButton_OnEnter)
		button:SetScript("OnLeave", PredictorButton_OnLeave)
		button.parent = predictor
		button:Hide()
		
		if( i > 1 ) then
			button:SetPoint("TOPLEFT", predictor.buttons[i - 1], "BOTTOMLEFT", 0, 0)
			button:SetPoint("TOPRIGHT", predictor.buttons[i - 1], "BOTTOMRIGHT", 0, 0)
		else
			button:SetPoint("TOPLEFT", predictor, 8, -8)
			button:SetPoint("TOPRIGHT", predictor, -7, 0)
		end

		-- Create the actual text
		local text = button:CreateFontString(nil, "ARTWORK", "GameFontNormal")
		text:SetAllPoints(button)
		text:SetJustifyH("LEFT")
		text:SetJustifyV("MIDDLE")
		button:SetFontString(text)
		
		-- Setup the highlighting
		local texture = button:CreateTexture(nil, "ARTWORK")
		texture:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
		texture:ClearAllPoints()
		texture:SetPoint("TOPLEFT", button, 0, -2)
		texture:SetPoint("BOTTOMRIGHT", button, 5, 2)
		texture:SetAlpha(0.70)

		button:SetHighlightTexture(texture)
		button:SetHighlightFontObject(GameFontHighlight)
		button:SetNormalFontObject(GameFontNormal)
		
		table.insert(predictor.buttons, button)
	end	
	-- EditBoxes override the OnKeyUp/OnKeyDown events so that they can function, meaning in order to make up and down
	-- arrow navigation of the menu work, I have to do some trickery with temporary bindings.
	predictor:SetScript("OnMouseDown", Predictor_OnMouseDown)
	predictor:SetScript("OnHide", Predictor_OnHide)
	predictor:SetScript("OnShow", Predictor_OnShow)
	-- Replacing with a new function that returns first created predictor
	CreatePredictorFrame = function() return predictor end
	return predictor
end

local function Constructor()
	local self = {}
	local num = AceGUI:GetNextWidgetNum(Type)
	local frame = CreateFrame("Frame", nil, UIParent)
	local editBox = CreateFrame("EditBox", "AceGUI30SearchEditBox" .. num, frame, "InputBoxTemplate")
	local button = CreateFrame("Button", nil, editBox, "UIPanelButtonTemplate")
	local label = frame:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	local predictor = CreatePredictorFrame(num)
	-- Parent frame for all widgets
	frame:SetSize(200,44)
	-- EditBox Label
	label:SetPoint("TOPLEFT", frame, "TOPLEFT", 0, -2)
	label:SetPoint("TOPRIGHT", frame, "TOPRIGHT", 0, -2)
	label:SetJustifyH("LEFT")
	label:SetHeight(18)
	-- EditBox
	editBox:SetAutoFocus(false)
	editBox:SetFontObject(ChatFontNormal)
	editBox:SetScript("OnEnter", EditBox_OnEnter)
	editBox:SetScript("OnLeave", EditBox_OnLeave)
	editBox:SetScript("OnEscapePressed", EditBox_OnEscapePressed)
	editBox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
	editBox:SetScript("OnTextChanged", EditBox_OnTextChanged)
	editBox:SetScript("OnReceiveDrag", EditBox_OnReceiveDrag)
	editBox:SetScript("OnMouseDown", EditBox_OnReceiveDrag)
	editBox:SetScript("OnEditFocusGained", EditBox_OnEditFocusGained)
	editBox:SetScript("OnEditFocusLost", EditBox_OnEditFocusLost)
	editBox:SetTextInsets(0, 0, 3, 3)
	editBox:SetMaxLetters(256)
	editBox:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 6, 0)
	editBox:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, 0)
	editBox:SetHeight(19)
	-- Button to the right of the editBox
	button:SetPoint("RIGHT", editBox, "RIGHT", -2, 0)
	button:SetScript("OnClick", Button_OnClick)
	button:SetSize(40,20)
	button:SetText(OKAY)
	button:Hide()
	-- AceGUI object 
	self.type = Type
	self.num = num
	self.alignoffset = 30
	self.frame = frame
	self.predictor = predictor
	self.editBox = editBox
	self.label = label
	self.button = button
	self.OnRelease = OnRelease
	self.OnAcquire = OnAcquire
	self.SetDisabled = SetDisabled
	self.SetText = SetText
	self.SetLabel = SetLabel
	-- References to the AceGUI object
	frame.obj = self
	button.obj = self
	editBox.obj = self
	-- Registering our new created widget
	AceGUI:RegisterAsWidget(self)
	return self
end

AceGUI:RegisterWidgetType(Type, Constructor, Version)
