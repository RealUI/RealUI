--[[--------------------------------------------------------------------
	PhanxConfig-Checkbox
	Simple checkbox widget generator.
	Originally based on tekKonfig-Checkbox by Tekkub.
	Requires LibStub.
	https://github.com/phanx/PhanxConfigWidgets
	Copyright (c) 2009-2014 Phanx. All rights reserved.
	See the accompanying README and LICENSE files for more information.
----------------------------------------------------------------------]]

local MINOR_VERSION = tonumber(strmatch("$Revision: 176 $", "%d+"))

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-Checkbox", MINOR_VERSION)
if not lib then return end

------------------------------------------------------------------------

local scripts = {}

function scripts:OnClick()
	local checked = not not self:GetChecked() -- WOD: won't need typecasting
	PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
	self:GetScript("OnLeave")(self)

	local callback = self.Callback or self.OnValueChanged
	if callback then
		callback(self, checked)
	end
end

function scripts:OnEnter()
	if self.tooltipText then
		GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
		GameTooltip:SetText(self.tooltipText, nil, nil, nil, nil, true)
	end
end
function scripts:OnLeave()
	GameTooltip:Hide()
end

function scripts:OnEnable()
	if not self.disabled then return end
	local r, g, b = self.labelText:GetTextColor()
	self.labelText:SetTextColor(r * 2, g * 2, b * 2)
	self.disabled = nil
end
function scripts:OnDisable()
	if self.disabled then return end
	local r, g, b = self.labelText:GetTextColor()
	self.labelText:SetTextColor(r / 2, g / 2, b / 2)
	self.disabled = true
end

------------------------------------------------------------------------

local methods = {}

function methods:GetValue()
	return not not self:GetChecked() -- WOD: won't need typecasting
end
function methods:SetValue(value)
	self:SetChecked(value)
end

function methods:GetLabel()
	return self.labelText:GetText()
end
function methods:SetLabel(text)
	self.labelText:SetText(text)
end

function methods:GetTooltip()
	return self.tooltipText
end
function methods:SetTooltip(text)
	self.tooltipText = text
end

------------------------------------------------------------------------

function lib:New(parent, text, tooltipText)
	assert(type(parent) == "table" and type(rawget(parent, 0) == "userdata"), "PhanxConfig-Checkbox: parent must be a frame")
	if type(name) ~= "string" then name = nil end
	if type(tooltipText) ~= "string" then tooltipText = nil end

	local check = CreateFrame("CheckButton", nil, parent)
	check:SetSize(26, 26)

	check:SetNormalTexture("Interface\\Buttons\\UI-CheckBox-Up")
	check:SetPushedTexture("Interface\\Buttons\\UI-CheckBox-Down")
	check:SetHighlightTexture("Interface\\Buttons\\UI-CheckBox-Highlight")
	check:SetCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check")
	check:SetDisabledCheckedTexture("Interface\\Buttons\\UI-CheckBox-Check-Disabled")

	local label = check:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	label:SetPoint("LEFT", check, "RIGHT", 2, 1)
	label:SetText(text)
	check.labelText = label

	check.tooltipText = tooltipText
	check:SetHitRectInsets(0, -1 * min(186, max(label:GetStringWidth(), 100)), 0, 0)
	check:SetMotionScriptsWhileDisabled(true)

	for name, func in pairs(scripts) do
		check:SetScript(name, func)
		check[name] = func
	end
	for name, func in pairs(methods) do
		check[name] = func
	end

	return check
end

function lib.CreateCheckbox(...) return lib:New(...) end