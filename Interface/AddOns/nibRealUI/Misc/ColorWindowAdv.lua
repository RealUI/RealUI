local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local CPF, OSF = ColorPickerFrame, OpacitySliderFrame

-- Enable move
local CPFMover = CreateFrame("Frame", nil, CPF)
CPFMover:SetPoint("TOPLEFT", CPF, "TOP", -60, 0)
CPFMover:SetPoint("BOTTOMRIGHT", CPF, "TOP", 60, -15)
CPFMover:EnableMouse(true)
CPFMover:SetScript("OnMouseDown", function() CPF:StartMoving() end)
CPFMover:SetScript("OnMouseUp", function() CPF:StopMovingOrSizing() end)
CPF:SetUserPlaced(true)
CPF:EnableKeyboard(false)

local CPFSwatchBG = CreateFrame("Frame", nil, CPF)
CPFSwatchBG:SetSize(48, 48)
CPFSwatchBG:SetPoint("TOPLEFT", ColorPickerWheel, "TOPRIGHT", 87, 0)
for i = 1, 4 do
	local tex = CPFSwatchBG:CreateTexture(nil, "BACKGROUND", nil, 7)
	tex:SetTexture("Tileset\\Generic\\Checkers")
	tex:SetTexCoord(0.03125, 0.21875, 0.28125, 0.46875)
	tex:SetSize(24, 24)
	if i == 1 then
		tex:SetPoint("TOPLEFT", 0, 0)
	elseif i == 2 then
		tex:SetPoint("TOPRIGHT", 0, 0)
	elseif i == 3 then
		tex:SetPoint("BOTTOMLEFT", 0, 0)
	elseif i == 4 then
		tex:SetPoint("BOTTOMRIGHT", 0, 0)
	end
end
local CPFPrevSwatch = CPFSwatchBG:CreateTexture(nil, "BORDER", nil, 7)
CPFPrevSwatch:SetSize(32, 32)
CPFPrevSwatch:SetPoint("TOPRIGHT", CPFSwatchBG, "TOPRIGHT", 0, 0)

-- Copy
local red, green, blue, opacity
local CPFCopyButton = nibRealUI:CreateTextButton("Copy", CPF, 60, 22)
CPFCopyButton:SetPoint("TOP", CPFSwatchBG, "BOTTOM", 0, -5)
CPFCopyButton:SetScript("OnClick", function()
	red, green, blue = CPF:GetColorRGB()
	opacity = OSF:GetValue()
	
	CPFCopyButton:SetText(format("|cff%02x%02x%02xCopy", red * 255, green * 255, blue * 255))
end)

-- Paste
local CPFPasteButton = nibRealUI:CreateTextButton("Paste", CPF, 60, 22)
CPFPasteButton:SetPoint("TOP", CPFCopyButton, "BOTTOM", 0, -5)
CPFPasteButton:SetScript("OnClick", function()
	CPF:SetColorRGB(red, green, blue)
	OSF:SetValue(opacity)
end)

-- Saturation slider.
local UpdateCPFHSV = function(self)
	local s = self:GetValue()
	local h, _, v = CPF:GetColorHSV()
	--print("UpdateCPFHSV", h, s, v)
	CPF:SetColorHSV(h, s, v)
end

local CPFSaturation = CreateFrame("Slider", "CWA_SatSlider", CPF, "OptionsSliderTemplate")
CPFSaturation:SetMinMaxValues(0, 1)
CPFSaturation:SetValueStep(.05)
CPFSaturation:SetOrientation("VERTICAL")
CPFSaturation:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Vertical]])
CPFSaturation:SetHeight(OSF:GetHeight())
CPFSaturation:SetWidth(OSF:GetWidth())
CPFSaturation:SetPoint("TOPRIGHT", CPFSwatchBG, "TOPLEFT", -12, 0)
_G["CWA_SatSliderLow"]:ClearAllPoints()
_G["CWA_SatSliderHigh"]:ClearAllPoints()
_G["CWA_SatSliderText"]:ClearAllPoints()
CPFSaturation:SetScript("OnValueChanged", UpdateCPFHSV)


local CPFEditBoxes = {
	Red = 0,
	Green = 1,
	Blue = 2,
	Hex = 3,
	Alpha = 4,
}

local UpdateCPFRGB = function(editbox)
	local r, g, b
	if #editbox:GetText() == 6 then 
		local rgb = editbox:GetText()
		r, g, b = tonumber("0x"..strsub(rgb, 0, 2)), tonumber("0x"..strsub(rgb, 3, 4)), tonumber("0x"..strsub(rgb, 5, 6))
	else
		r, g, b = tonumber(CPFEditBoxes.Red:GetText()), tonumber(CPFEditBoxes.Green:GetText()), tonumber(CPFEditBoxes.Blue:GetText())
	end
	local a = tonumber(CPFEditBoxes.Alpha:GetText())
	--print("UpdateCPFRGB", r, g, b, a)
	if r and g and b then
		if r <= 1 and g <= 1 and b <= 1 then
			CPF:SetColorRGB(r, g, b)
		else
			CPF:SetColorRGB(r / 255, g / 255, b / 255)
		end
	else
		print("Error converting fields to numbers. Please check the values.")
	end

	OSF:SetValue(1 - (a / 100))
end

local UpdateRGBA = function()
	local r, g, b = CPF:GetColorRGB()
	local a = OSF:GetValue()
	local _, s = CPF:GetColorHSV()
	CPFSaturation:SetValue(s)
	--print("UpdateRGBA", r, b, g, 1 - a)
	
	CPFEditBoxes.Red:SetText(r * 255)
	CPFEditBoxes.Green:SetText(g * 255)
	CPFEditBoxes.Blue:SetText(b * 255)
	CPFEditBoxes.Hex:SetText(format("%02x%02x%02x", r * 255, g * 255, b * 255))

	if CPF.hasOpacity then
		CPFEditBoxes.Alpha:SetText(format("%d", (1 - a) * 100))
		ColorSwatch:SetTexture(r, g, b, 1 - a)
	end
end

for type, offsetFactor in pairs(CPFEditBoxes) do
	local editbox = CreateFrame("EditBox", nil, CPF)
	editbox:SetHeight(15)
	editbox:SetWidth(50)
	editbox:SetPoint("BOTTOMLEFT", ColorPickerOkayButton, "TOPLEFT", ((70 * offsetFactor) + 10), 5)
	
	editbox:SetBackdrop({
		bgFile = [[Interface\ChatFrame\ChatFrameBackground]], 
	})
	editbox:SetBackdropColor(0, 0, 0, .5)
	
	editbox:SetFontObject(ChatFontNormal)
	editbox:SetAutoFocus(false)
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
	title:SetPoint("RIGHT", editbox, "LEFT", 0, 0)
	if type == "Hex" then
		editbox:SetMaxLetters(6)
		title:SetText("#")
	else
		editbox:SetMaxLetters(3)
		title:SetText(strmatch(type, "^%S"))
	end
	
	CPFEditBoxes[type] = editbox
end

-- Move widgets --

-- Script Hooks --
CPF:HookScript("OnShow", function(self)
	print("CPF:OnShow")
	if Aurora then
		local F = Aurora[1]
		F.Reskin(CPFCopyButton)
		F.Reskin(CPFPasteButton)
		--F.ReskinSlider(CPFSaturation)
	end
	if not CPF.moved then
		ColorPickerFrameHeader:ClearAllPoints()
		ColorPickerFrameHeader:SetPoint("TOP", CPF, "TOP", 0, 11)

		ColorPickerWheel:ClearAllPoints()
		ColorPickerWheel:SetPoint("TOPLEFT", CPF, "TOPLEFT", 5, -18)

		local ColorValue = select(6, CPF:GetRegions())
		ColorValue:ClearAllPoints()
		ColorValue:SetPoint("LEFT", ColorPickerWheel, "RIGHT", 13, 0)

		ColorSwatch:ClearAllPoints()
		ColorSwatch:SetPoint("BOTTOMLEFT", CPFSwatchBG, "BOTTOMLEFT", 0, 0)
		ColorSwatch:SetParent(CPFSwatchBG)

		OSF:ClearAllPoints()
		OSF:SetPoint("TOPRIGHT", CPF, "TOPRIGHT", -25, -18)

		ColorPickerOkayButton:ClearAllPoints()
		ColorPickerOkayButton:SetPoint("BOTTOMLEFT", CPF, "BOTTOMLEFT", 5, 5)
		ColorPickerOkayButton:SetWidth(100)
		ColorPickerCancelButton:ClearAllPoints()
		ColorPickerCancelButton:SetPoint("BOTTOMRIGHT", CPF, "BOTTOMRIGHT", -5, 5)
		ColorPickerCancelButton:SetWidth(100)
		CPF.moved = true
	end
	local r, g, b = self:GetColorRGB()
	if self.hasOpacity then
		CPFPrevSwatch:SetTexture(r, g, b, 1 - OSF:GetValue())
		CPFEditBoxes.Alpha:Show()
		self:SetSize(350, 200)
	else
		CPFPrevSwatch:SetTexture(r, g, b, 1)
		CPFEditBoxes.Alpha:Hide()
		self:SetSize(280, 200)
	end

	UpdateRGBA()
end)
CPF:HookScript("OnColorSelect", UpdateRGBA)
OSF:HookScript("OnShow", UpdateRGBA)
OSF:HookScript("OnValueChanged", UpdateRGBA)
