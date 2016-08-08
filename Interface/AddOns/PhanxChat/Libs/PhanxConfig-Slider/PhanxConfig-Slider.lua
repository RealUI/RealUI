--[[--------------------------------------------------------------------
	PhanxConfig-Slider
	Simple slider widget generator. Requires LibStub.
	https://github.com/Phanx/PhanxConfig-Slider
	Copyright (c) 2009-2015 Phanx <addons@phanx.net>. All rights reserved.
	Feel free to include copies of this file WITHOUT CHANGES inside World of
	Warcraft addons that make use of it as a library, and feel free to use code
	from this file in other projects as long as you DO NOT use my name or the
	original name of this file anywhere in your project outside of an optional
	credits line -- any modified versions must be renamed to avoid conflicts.
----------------------------------------------------------------------]]

local MINOR_VERSION = 20151003

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

function methods:Disable()
	self.slider:EnableMouse(false)
	self.slider:EnableMouseWheel(false)
	self.labelText:SetFontObject("GameFontDisable")
	self.minText:SetFontObject("GameFontDisableSmall")
	self.maxText:SetFontObject("GameFontDisableSmall")
	self.valueText:SetFontObject("GameFontDisableSmall")
	self.enabled = false
end

function methods:Enable()
	self.slider:EnableMouse(true)
	self.slider:EnableMouseWheel(true)
	self.labelText:SetFontObject("GameFontNormal")
	self.minText:SetFontObject("GameFontNormalSmall")
	self.maxText:SetFontObject("GameFontNormalSmall")
	self.valueText:SetFontObject("GameFontHighlightSmall")
	self.enabled = false
end

function methods:SetEnabled(enabled)
	if enabled then
		self:Enable()
	else
		self:Disable()
	end
end

function methods:GetEnabled()
	return self.enabled ~= false -- nil if it's never been explicitly disabled or enabled
end

------------------------------------------------------------------------

local scripts = {}

function scripts:OnEnter()
	local container = self:GetParent()
	local text = container.tooltipText
	if text then
		GameTooltip:SetOwner(container, "ANCHOR_RIGHT")
		GameTooltip:SetText(container.tooltipText, nil, nil, nil, nil, true)
	end
end

scripts.OnLeave = GameTooltip_Hide

function scripts:OnMouseWheel(delta)
	local minValue, maxValue = self:GetMinMaxValues()
	local step = self:GetValueStep() * delta
	if step > 0 then
		value = min(self:GetValue() + step, maxValue)
	else
		value = max(self:GetValue() + step, minValue)
	end
	self:SetValue(value)
end

function scripts:OnValueChanged(value, userInput)
	local container = self:GetParent()
	value = floor(value * 1000 + 0.05) / 1000 -- fucking floats
	if container.lastValue == value then return end

	if container.isPercent then
		container.valueText:SetFormattedText("%.0f%%", value * 100)
	else
		container.valueText:SetText(value)
	end

	local callback = container.OnValueChanged or container.Callback or container.callback
	if callback and container.lastValue then
		callback(container, value)
	end

	container.lastValue = value
end

------------------------------------------------------------------------

local editBoxScripts = {}

function editBoxScripts:OnEnter()
	local slider = self:GetParent()
	local container = slider:GetParent()
	return scripts.OnEnter(slider)
end

function editBoxScripts:OnLeave()
	local slider = self:GetParent()
	local container = slider:GetParent()
	return scripts.OnLeave(slider)
end

function editBoxScripts:OnMouseWheel(delta)
	local slider = self:GetParent()
	return scripts.OnMouseWheel(slider, delta)
end

function editBoxScripts:OnEnterPressed()
	local slider = self:GetParent()
	local container = slider:GetParent()
	local text = self:GetValue()
	self:ClearFocus()

	local value
	if container.isPercent then
		value = tonumber(strmatch(text, "%d+")) / 100
	else
		value = tonumber(text)
	end
	if value then
		container:SetValue(value)
	end
end

------------------------------------------------------------------------

local sliderBG = {
	bgFile = "Interface\\Buttons\\UI-SliderBar-Background",
	edgeFile = "Interface\\Buttons\\UI-SliderBar-Border",
	edgeSize = 8, tile = true, tileSize = 8,
	insets = { left = 3, right = 3, top = 6, bottom = 6 }
}

function lib:New(container, name, tooltipText, minValue, maxValue, valueStep, percent, noEditBox)
	assert(type(container) == "table" and type(rawget(container, 0)) == "userdata", "PhanxConfig-Slider: container must be a frame")
	if type(name) ~= "string" then name = nil end
	if type(tooltipText) ~= "string" then tooltipText = nil end
	if type(minValue) ~= "number" then minValue = 0 end
	if type(maxValue) ~= "number" then maxValue = 100 end
	if type(valueStep) ~= "number" then valueStep = 1 end

	local frame = CreateFrame("Frame", nil, container)
	frame:SetSize(200, 48)
--[[
	frame.bg = frame:CreateTexture(nil, "BACKGROUND")
	frame.bg:SetAllPoints(true)
	frame.bg:SetTexture(0, 0.5, 0, 0.5)
]]
	local slider = CreateFrame("Slider", nil, frame)
	slider:SetPoint("BOTTOMLEFT", 2, 14)
	slider:SetPoint("BOTTOMRIGHT", -2, 14)
	slider:SetHeight(17)
	slider:SetOrientation("HORIZONTAL")
	slider:SetThumbTexture("Interface\\Buttons\\UI-SliderBar-Button-Horizontal")
	slider:SetBackdrop(sliderBG)
	frame.slider = slider

	slider:EnableMouseWheel(true)
	slider:SetObeyStepOnDrag(true)
	for name, func in pairs(scripts) do
		slider:SetScript(name, func)
	end

	local label = slider:CreateFontString(nil, "ARTWORK", "GameFontNormal")
	label:SetPoint("TOPLEFT", frame, 6, 0)
	label:SetPoint("TOPRIGHT", frame, -6, 0)
	label:SetJustifyH("LEFT")
	frame.labelText = label

	local minText = slider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	minText:SetPoint("TOPLEFT", slider, "BOTTOMLEFT", 6, 1)
	frame.minText = minText

	local maxText = slider:CreateFontString(nil, "ARTWORK", "GameFontNormalSmall")
	maxText:SetPoint("TOPRIGHT", slider, "BOTTOMRIGHT", -6, 1)
	frame.maxText = maxText

	if not noEditBox and LibStub("PhanxConfig-EditBox", true) then
		local valueText = LibStub("PhanxConfig-EditBox"):New(slider, nil, tooltipText, 5)
		valueText:SetFrameLevel(slider:GetFrameLevel() - 1) -- don't let editbox top texture overlap slider
		valueText:SetPoint("TOP", slider, "BOTTOM", 0, 6)
		valueText:SetWidth(70)
		valueText:SetFontObject(GameFontHighlightSmall)
		valueText:SetJustifyH("CENTER")
		valueText:EnableMouseWheel(true)
		for name, func in pairs(editBoxScripts) do
			valueText:SetScript(name, func)
		end
		frame.valueText = valueText
		slider:SetHitRectInsets(0, 0, -10, 0)
	else
		local valueText = slider:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
		valueText:SetPoint("TOP", slider, "BOTTOM", 0, 1)
		frame.valueText = valueText
		slider:SetHitRectInsets(0, 0, -10, -10)
	end

	for name, func in pairs(methods) do
		frame[name] = func
	end

	slider:SetMinMaxValues(minValue, maxValue)
	slider:SetValueStep(valueStep)
	frame.isPercent = percent

	label:SetText(name)
	frame.tooltipText = tooltipText
	if percent then
		minText:SetFormattedText("%.0f%%", minValue * 100)
		maxText:SetFormattedText("%.0f%%", maxValue * 100)
	else
		minText:SetText(minValue)
		maxText:SetText(maxValue)
	end

	return frame
end

function lib.CreateSlider(...) return lib:New(...) end