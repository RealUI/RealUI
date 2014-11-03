--[[--------------------------------------------------------------------
	PhanxConfig-Slider
	Simple slider widget generator.
	Based on tekKonfig-Slider and AceGUI-3.0-Slider.
	Requires LibStub.
	https://github.com/phanx/PhanxConfigWidgets
	Copyright (c) 2009-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

local MINOR_VERSION = tonumber(strmatch("$Revision: 176 $", "%d+"))

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-Slider", MINOR_VERSION)
if not lib then return end

------------------------------------------------------------------------

local methods = {}

function methods:GetValue()
	return self.slider:GetValue()
end

function methods:SetValue(value)
	value = tonumber(value or nil)
	return value and self.slider:SetValue(value)
end

function methods:GetLabel()
	return self.labelText:GetText()
end

function methods:SetLabel(text)
	self.labelText:SetText(tostring(text or ""))
end

function methods:GetTooltip()
	return self.tooltipText
end

function methods:SetTooltip(text)
	self.tooltipText = text and tostring(text) or nil
end

------------------------------------------------------------------------

local function Slider_OnEnter(self)
	local container = self:GetParent()
	local text = container.tooltipText
	if text then
		GameTooltip:SetOwner(container, "ANCHOR_RIGHT")
		GameTooltip:SetText(container.tooltipText, nil, nil, nil, nil, true)
	end
end

local function Slider_OnLeave(self)
	GameTooltip:Hide()
end

local function Slider_OnMouseWheel(self, delta)
	local parent = self:GetParent()
	local minValue, maxValue = self:GetMinMaxValues()
	local step = self:GetValueStep() * delta

	if step > 0 then
		value = min(self:GetValue() + step, maxValue)
	else
		value = max(self:GetValue() + step, minValue)
	end

	self:SetValue(value)

	local callback = parent.OnValueChanged or parent.Callback
	if callback then
		callback(parent, value)
	end
end

local function Slider_OnValueChanged(self, value, userInput)
	local parent = self:GetParent()
	if parent.lastValue == value then return end

	if parent.isPercent then
		parent.valueText:SetFormattedText("%.0f%%", value * 100)
	else
		parent.valueText:SetText(value)
	end

	if parent.lastValue and parent.Callback then
		parent:Callback(value)
	end

	parent.lastValue = value
end

------------------------------------------------------------------------

local function EditBox_OnEnter(self)
	local parent = self:GetParent():GetParent()
	return Slider_OnEnter(parent.slider)
end

local function EditBox_OnLeave(self)
	local parent = self:GetParent():GetParent()
	return Slider_OnLeave(parent.slider)
end

local function EditBox_OnEnterPressed(self)
	local parent = self:GetParent():GetParent()
	local text = self:GetText()
	self:ClearFocus()

	local value
	if parent.isPercent then
		value = tonumber(strmatch(text, "%d+")) / 100
	else
		value = tonumber(text)
	end
	if value then
		parent:SetValue(value)
	end
end

------------------------------------------------------------------------

local sliderBG = {
	bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
	edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
	edgeSize = 8, tile = true, tileSize = 8,
	insets = { left = 3, right = 3, top = 6, bottom = 6 }
}

function lib:New(parent, name, tooltipText, minValue, maxValue, valueStep, percent, noEditBox)
	assert(type(parent) == "table" and type(rawget(parent, 0)) == "userdata", "PhanxConfig-Slider: parent must be a frame")
	if type(name) ~= "string" then name = nil end
	if type(tooltipText) ~= "string" then tooltipText = nil end
	if type(minValue) ~= "number" then minValue = 0 end
	if type(maxValue) ~= "number" then maxValue = 100 end
	if type(valueStep) ~= "number" then valueStep = 1 end

	local frame = CreateFrame("Frame", nil, parent)
	frame:SetWidth(186)
	frame:SetHeight(42)

	frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetAllPoints(true)
	frame.bg:SetTexture(0, 0, 0, 0)

	local slider = CreateFrame("Slider", nil, frame)
	slider:SetPoint("BOTTOMLEFT", 3, 10)
	slider:SetPoint("BOTTOMRIGHT", -3, 10)
	slider:SetHeight(17)
	slider:SetHitRectInsets(0, 0, -10, -10)
	slider:SetOrientation("HORIZONTAL")
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	slider:SetBackdrop(sliderBG)
	frame.slider = slider

	local label = slider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("TOPLEFT", frame, 5, 0)
	label:SetPoint("TOPRIGHT", frame, -5, 0)
	label:SetJustifyH("LEFT")
	frame.labelText = label

	local minText = slider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	minText:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 0, 3)
	frame.minText = minText

	if percent then
		minText:SetFormattedText("%.0f%%", minValue * 100)
	else
		minText:SetText(minValue)
	end

	local maxText = slider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	maxText:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", 0, 3)
	frame.maxText = high

	if percent then
		maxText:SetFormattedText("%.0f%%", maxValue * 100)
	else
		maxText:SetText(maxValue)
	end

	local valueText
	if not noEditBox and LibStub("PhanxConfig-EditBox", true) then
		valueText = LibStub("PhanxConfig-EditBox"):New(frame, nil, tooltipText, 5)
		valueText:SetPoint("TOP", slider, "BOTTOM", 0, 13)
		valueText:SetWidth(100)
		valueText.editbox:SetFontObject(GameFontHighlightSmall)
		valueText.editbox:SetJustifyH("CENTER")
		valueText.editbox:SetScript("OnEnter", EditBox_OnEnter)
		valueText.editbox:SetScript("OnLeave", EditBox_OnLeave)
		valueText.editbox:SetScript("OnEnterPressed", EditBox_OnEnterPressed)
		valueText.editbox:SetScript("OnTabPressed", EditBox_OnEnterPressed)
	else
		valueText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		valueText:SetPoint("TOP", slider, "BOTTOM", 0, 3)
	end
	frame.valueText = valueText

	slider:EnableMouseWheel(true)
	slider:SetObeyStepOnDrag(true)
	slider:SetScript("OnEnter", Slider_OnEnter)
	slider:SetScript("OnLeave", Slider_OnLeave)
	slider:SetScript("OnMouseWheel", Slider_OnMouseWheel)
	slider:SetScript("OnValueChanged", Slider_OnValueChanged)

	for name, func in pairs(methods) do
		frame[name] = func
	end

	label:SetText(name)
	slider:SetMinMaxValues(minValue, maxValue)
	slider:SetValueStep(valueStep)
	frame.tooltipText = tooltipText
	frame.isPercent = percent

	return frame
end

function lib.CreateSlider(...) return lib:New(...) end