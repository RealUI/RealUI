local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local ndb, ndbc

local _
local ConfigBar = nibRealUI:GetModule("ConfigBar")
local cbGUI = nibRealUI:GetModule("ConfigBar_GUI")

local MODNAME = "ConfigBar_Advanced"
local ConfigBar_Advanced = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local Element = {}
local buttonCount = 3
local buttonWidth = 120
local buttonHeight = 24

-- AddOn Control
-- Advanced Options
-- Reset RealUI

function ConfigBar_Advanced:SetupWindow()
	-- Window
	Element.window = cbGUI:CreateWindow(Element, "Advanced")

	-- Header
	Element.window.header = cbGUI:CreateHeader(Element, nil, 0)

	-- Buttons
	local buttons = {
		{
			label = L["AddOn Control"],
			func = function()
				nibRealUI:GetModule("AddonControl"):ShowOptionsWindow()
				self:Close()
			end,
			width = buttonWidth,
			height = buttonHeight,
			justifyH = "LEFT",
			x = 0,
			y = -1,
		},
		{
			label = ADVANCED_LABEL.." "..CHAT_CONFIGURATION,
			func = function()
				nibRealUI:OpenOptions()
				self:Close()
			end,
		},
		{
			label = RESET.." RealUI",
			func = function()
				nibRealUI:ReInstall()
				self:Close()
			end,
		},
	}
	Element.buttons, Element.maxButtonWidth = cbGUI:CreateButtonList(Element, "VERTICAL", buttons)
	Element.window:SetWidth(Element.maxButtonWidth)
	Element.window.header:SetWidth(Element.maxButtonWidth - 2)
end

function ConfigBar_Advanced:Close()
	if not Element.window then return end
	if Element.window:IsVisible() then
		Element.window:Hide()
		Element.active = false
		if not Element.highlighted then
			Element.button.highlight:Hide()
		end
	end
end

function ConfigBar_Advanced:Open()
	if not Element.window then self:SetupWindow() end
	if not Element.window:IsVisible() then
		Element.window:Show()
	end
	return true
end

function ConfigBar_Advanced:Register()
	Element.info = {
		label = ADVANCED_LABEL,
		icon = [[Interface\AddOns\nibRealUI\Media\Config\Advanced]],
		window = {
			width = 100,	-- place holder, will be set by max button width
			height = (buttonCount * buttonHeight) + 25,
			position = "BUTTONLEFT",
			xOfs = 0,
		},
		openFunc = function() return ConfigBar_Advanced:Open() end,
		closeFunc = function() ConfigBar_Advanced:Close() end,
	}
	ConfigBar:RegisterElement(Element, 1)
end

----------
function ConfigBar_Advanced:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	self:Register()
end