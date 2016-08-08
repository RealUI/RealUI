--[[--------------------------------------------------------------------
	PhanxConfig-Checkbox
	Simple checkbox widget generator. Requires LibStub.
	https://github.com/Phanx/PhanxConfig-Checkbox
	Copyright (c) 2009-2015 Phanx <addons@phanx.net>. All rights reserved.
	Feel free to include copies of this file WITHOUT CHANGES inside World of
	Warcraft addons that make use of it as a library, and feel free to use code
	from this file in other projects as long as you DO NOT use my name or the
	original name of this file anywhere in your project outside of an optional
	credits line -- any modified versions must be renamed to avoid conflicts.
----------------------------------------------------------------------]]

local MINOR_VERSION = 20150112

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-Checkbox", MINOR_VERSION)
if not lib then return end

local scripts = {}

function scripts:OnDisable()
	self.labelText:SetFontObject(GameFontNormalLeftGrey)
end

function scripts:OnEnable()
	self.labelText:SetFontObject(GameFontHighlightLeft)
end

function scripts:OnClick(button)
	local checked = self:GetChecked()
	PlaySound(checked and "igMainMenuOptionCheckBoxOn" or "igMainmenuOptionCheckBoxOff")
	local callback = self.OnValueChanged or self.OnClick or self.Callback or self.callback
	if callback then
		return callback(self, checked)
	end
end

function lib:New(parent, text, tooltipText)
	assert(type(parent) == "table" and type(rawget(parent, 0) == "userdata"), "PhanxConfig-Checkbox: parent must be a frame")
	if type(name) ~= "string" then name = nil end
	if type(tooltipText) ~= "string" then tooltipText = nil end

	local check = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
	check:SetMotionScriptsWhileDisabled(true)
	check.labelText = check.Text

	for name, func in pairs(scripts) do
		check:SetScript(name, func)
	end
	check.GetValue = check.GetChecked
	check.SetValue = check.SetChecked

	check.labelText:SetText(text)
	check:SetHitRectInsets(0, -1 * max(100, check.labelText:GetStringWidth() + 4), 0, 0)
	check.tooltipText = tooltipText
--[[
	check.bg = check:CreateTexture(nil, "BACKGROUND")
	check.bg:SetPoint("TOPLEFT")
	check.bg:SetPoint("BOTTOMLEFT")
	check.bg:SetPoint("RIGHT", max(100, check.labelText:GetStringWidth() + 4), 0)
	check.bg:SetTexture(0, 0.5, 0, 0.5)
]]
	return check
end

function lib.CreateCheckbox(...) return lib:New(...) end
