local CPF, OSF = ColorPickerFrame, OpacitySliderFrame

----
local CPFMover = CreateFrame("Frame", nil, CPF)
CPFMover:SetPoint("TOPLEFT", CPF, "TOP", -60, 0)
CPFMover:SetPoint("BOTTOMRIGHT", CPF, "TOP", 60, -15)
CPFMover:EnableMouse(true)
CPFMover:SetScript("OnMouseDown", function() CPF:StartMoving() end)
CPFMover:SetScript("OnMouseUp", function() CPF:StopMovingOrSizing() end)
CPF:SetUserPlaced(true)
CPF:EnableKeyboard(false)

local CPFFauxHeader = CPF:CreateTexture(nil, "OVERLAY")
CPFFauxHeader:SetTexture([[Interface\DialogFrame\UI-DialogBox-Header]])
CPFFauxHeader:SetAllPoints(ColorPickerFrameHeader)

local CPFHexEdit = CreateFrame("EditBox", nil, CPF)
CPFHexEdit:SetAutoFocus(false)
CPFHexEdit:SetFontObject(ChatFontNormal)
CPFHexEdit:SetMaxLetters(6)
CPFHexEdit:SetJustifyH("CENTER")
CPFHexEdit:SetFrameLevel(10)
CPFHexEdit:SetPoint("TOPLEFT", CPF, "TOP", -30, 0)
CPFHexEdit:SetPoint("BOTTOMRIGHT", CPF, "TOP", 30, -15)
CPFHexEdit:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
CPFHexEdit:SetScript("OnEditFocusGained", function(self)
	self:HighlightText(0, self:GetNumLetters())
end)
CPFHexEdit:SetScript("OnEditFocusLost", function(self)
	self:HighlightText(self:GetNumLetters())
end)

-- Saturation slider.
local CPFSaturation = CreateFrame("Slider", "CWA_SatSlider", CPF, "OptionsSliderTemplate")
CPFSaturation:SetMinMaxValues(0, 1)
CPFSaturation:SetValueStep(.05)
CPFSaturation:SetOrientation("VERTICAL")
CPFSaturation:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Vertical]])
CPFSaturation:SetHeight(OSF:GetHeight())
CPFSaturation:SetWidth(OSF:GetWidth())
CPFSaturation:SetPoint("LEFT", OSF, "RIGHT", 5, 0)
_G["CWA_SatSliderLow"]:ClearAllPoints()
_G["CWA_SatSliderHigh"]:ClearAllPoints()
_G["CWA_SatSliderText"]:ClearAllPoints()

-- Copy
local red, green, blue, opacity
local CPFCopyButton = CreateFrame("Button", nil, CPF, "OptionsButtonTemplate")
CPFCopyButton:SetText("Copy")
CPFCopyButton:SetPoint("TOPLEFT", CPF, "TOPLEFT", 2, -2)
CPFCopyButton:SetScript("OnClick", function()
	red, green, blue = CPF:GetColorRGB()
	opacity = OSF:GetValue()
	
	CPFCopyButton:SetText(format("|cff%02x%02x%02xCopy", red * 255, green * 255, blue * 255))
end)

local CPFPasteButton = CreateFrame("Button", nil, CPF, "OptionsButtonTemplate")
CPFPasteButton:SetText("Paste")
CPFPasteButton:SetPoint("TOPRIGHT", CPF, "TOPRIGHT", -2, -2)
CPFPasteButton:SetScript("OnClick", function()
	CPF:SetColorRGB(red, green, blue)
	OSF:SetValue(opacity)
end)

if Aurora then
	local F = Aurora[1]
	F.Reskin(CPFCopyButton)
	F.Reskin(CPFPasteButton)
end

local CPFEditBoxes = {
	Red = 0,
	Green = 1,
	Blue = 2,
	Alpha = 3
}

local UpdateCPFHSV = function()
	local s = CPFSaturation:GetValue()
	local h, _, v = CPF:GetColorHSV()
	CPF:SetColorHSV(h, s, v)
end

local UpdateCPFRGB = function(editbox)
	local r, g, b
	if #editbox:GetText() == 6 then 
		local rgb = editbox:GetText()
		r, g, b = tonumber("0x"..strsub(rgb, 0, 2)), tonumber("0x"..strsub(rgb, 3, 4)), tonumber("0x"..strsub(rgb, 5, 6))
	else
		r, g, b = tonumber(CPFEditBoxes.Red:GetText()), tonumber(CPFEditBoxes.Green:GetText()), tonumber(CPFEditBoxes.Blue:GetText())
	end
	
	if r and g and b then
		if r <= 1 and g <= 1 and b <= 1 then
			CPF:SetColorRGB(r, g, b)
		else
			CPF:SetColorRGB(r / 255, g / 255, b / 255)
		end
	else
		print("Error converting fields to numbers. Please check the values.")
	end

	OSF:SetValue(tonumber(CPFEditBoxes.Alpha:GetText()) / 100)
end

local UpdateRGBFields = function()
	local _, s = CPF:GetColorHSV()
	CPFSaturation:SetValue(s)
	
	local r, g, b = CPF:GetColorRGB()
	CPFEditBoxes.Red:SetText(r * 255)
	CPFEditBoxes.Green:SetText(g * 255)
	CPFEditBoxes.Blue:SetText(b * 255)
	
	CPFHexEdit:SetText(format("%02x%02x%02x", r * 255, g * 255, b * 255))
end

local UpdateAlphaField = function()
	CPFEditBoxes.Alpha:SetText(OSF:GetValue() * 100)
end

CPFSaturation:SetScript("OnValueChanged", UpdateCPFHSV)
CPFHexEdit:SetScript("OnEnterPressed", function(self) 
	UpdateCPFRGB(self)
	self:ClearFocus() 
end)

for type, offsetFactor in pairs(CPFEditBoxes) do
	local editbox = CreateFrame("EditBox", nil, CPF)
	editbox:SetHeight(15)
	editbox:SetWidth(35)
	editbox:SetPoint("TOP", ColorSwatch, "BOTTOM", 0, -(25 * offsetFactor))
	
	editbox:SetBackdrop({
		bgFile = [[Interface\ChatFrame\ChatFrameBackground]], 
	})
	editbox:SetBackdropColor(0, 0, 0, .5)
	
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetAutoFocus(false)
	editbox:SetMaxLetters(3)
	editbox:SetJustifyH("CENTER")
	
	editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
	editbox:SetScript("OnEnterPressed", function(self) 
		UpdateCPFRGB(self)
		self:ClearFocus() 
	end)
	editbox:SetScript("OnEditFocusGained", function(self)
		self:HighlightText(0, self:GetNumLetters())
	end)
	editbox:SetScript("OnEditFocusLost", function(self)
		self:HighlightText(self:GetNumLetters())
	end)
	
	local title = editbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
	title:SetText(strmatch(type, "^%S"))
	title:SetPoint("RIGHT", editbox, "LEFT", -3, 0)
	
	CPFEditBoxes[type] = editbox
end

CPF:HookScript("OnShow", function()
	CPF:SetWidth(350)

	ColorPickerOkayButton:ClearAllPoints()
	ColorPickerOkayButton:SetPoint("BOTTOMLEFT", CPF, "BOTTOMLEFT", 10, 10)
	ColorPickerCancelButton:ClearAllPoints()
	ColorPickerCancelButton:SetPoint("BOTTOMRIGHT", CPF, "BOTTOMRIGHT", -10, 10)
		
	UpdateRGBFields()
end)
CPF:HookScript("OnColorSelect", UpdateRGBFields)
OSF:HookScript("OnShow", UpdateAlphaField)
OSF:HookScript("OnValueChanged", UpdateAlphaField)