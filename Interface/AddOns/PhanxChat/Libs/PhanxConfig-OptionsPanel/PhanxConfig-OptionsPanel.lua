--[[--------------------------------------------------------------------
	PhanxConfig-OptionsPanel
	Simple options panel frame generator. Requires LibStub.
	https://github.com/Phanx/PhanxConfig-OptionsPanel
	Copyright (c) 2009-2015 Phanx <addons@phanx.net>. All rights reserved.
	Feel free to include copies of this file WITHOUT CHANGES inside World of
	Warcraft addons that make use of it as a library, and feel free to use code
	from this file in other projects as long as you DO NOT use my name or the
	original name of this file anywhere in your project outside of an optional
	credits line -- any modified versions must be renamed to avoid conflicts.
----------------------------------------------------------------------]]

local MINOR_VERSION = 20150112

local lib, oldminor = LibStub:NewLibrary("PhanxConfig-OptionsPanel", MINOR_VERSION)
if not lib then return end

lib.objects = lib.objects or {}

local function OptionsPanel_OnShow(self)
	if InCombatLockdown() then return end
	local i, target = 1, self.parent or self.name
	while true do
		local button = _G["InterfaceOptionsFrameAddOnsButton"..i]
		if not button then break end
		local element = button.element
		if element and element.name == target then
			if element.hasChildren and element.collapsed then
				_G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]:Click()
			end
			return
		end
		i = i + 1
	end
end

local function OptionsPanel_OnFirstShow(self)
	if type(self.runOnce) == "function" then
		local success, err = pcall(self.runOnce, self)
		self.runOnce = nil
		if not success then error(err) end
	end

	if type(self.refresh) == "function" then
		self.refresh(self)
	end

	self:SetScript("OnShow", OptionsPanel_OnShow)
	if self:IsShown() then
		OptionsPanel_OnShow(self)
	end
end

local function OptionsPanel_OnClose(self)
	if InCombatLockdown() then return end
	local i, target = 1, self.parent or self.name
	while true do
		local button = _G["InterfaceOptionsFrameAddOnsButton"..i]
		if not button then break end
		local element = button.element
		if element.name == target then
			if element.hasChildren and not element.collapsed then
				local selection = InterfaceOptionsFrameAddOns.selection
				if not selection or selection.parent ~= target then
					_G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]:Click()
				end
			end
			return
		end
		i = i + 1
	end
end

local widgetTypes = {
	"Button",
	"Checkbox",
	"ColorPicker",
	"Dropdown",
	"EditBox",
	"Header",
	"KeyBinding",
	"MediaDropdown",
	"Panel",
	"Slider",
}

function lib:New(name, parent, construct, refresh)
	local frame
	if type(name) == "table" and name.IsObjectType and name:IsObjectType("Frame") then
		frame = name
	else
		assert(type(name) == "string", "PhanxConfig-OptionsPanel: Name is not a string!")
		if type(parent) ~= "string" then parent = nil end
		frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
		frame:Hide()
		frame.name = name
		frame.parent = parent
		InterfaceOptions_AddCategory(frame, parent)
	end

	if type(construct) ~= "function" then construct = nil end
	if type(refresh) ~= "function" then refresh = nil end

	for _, widget in pairs(widgetTypes) do
		local lib = LibStub("PhanxConfig-"..widget, true)
		if lib then
			local method = "Create"..widget
			frame[method] = lib[method]
		end
	end

	frame.refresh = refresh
	frame.okay = OptionsPanel_OnClose
	frame.cancel = OptionsPanel_OnClose

	frame.runOnce = construct

	if frame:IsShown() then
		OptionsPanel_OnFirstShow(frame)
	else
		frame:SetScript("OnShow", OptionsPanel_OnFirstShow)
	end

	if InterfaceOptionsFrame:IsShown() and not InCombatLockdown() then
		InterfaceAddOnsList_Update()
		if parent then
			local parentFrame = self:GetOptionsPanel(parent)
			if parentFrame then
				OptionsPanel_OnShow(parentFrame)
			end
		end
	end

	tinsert(self.objects, frame)
	return frame
end

function lib:GetOptionsPanel(name, parent)
	local panels = self.objects
	for i = 1, #panels do
		if panels[i].name == name and panels[i].parent == parent then
			return panels[i]
		end
	end
end

function lib.CreateOptionsPanel(...) return lib:New(...) end
