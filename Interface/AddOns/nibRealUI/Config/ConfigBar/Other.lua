local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local ndb, ndbc

local _
local ConfigBar = nibRealUI:GetModule("ConfigBar")
local cbGUI = nibRealUI:GetModule("ConfigBar_GUI")

local MODNAME = "ConfigBar_Other"
local ConfigBar_Other = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local Element = {}
local buttonCount = 3
local buttonWidth = 120
local buttonHeight = 24

-- Buffs and Debuffs
-- Chat
-- Nameplates

function ConfigBar_Other:SetupWindow()
	-- Window
	Element.window = cbGUI:CreateWindow(Element, "Advanced")

	-- Header
	Element.window.header = cbGUI:CreateHeader(Element, nil, 0)

	-- Buttons
	local buttons = {
		{
			label = BUFFOPTIONS_LABEL,
			func = function()
				if Raven then Raven:OptionsPanel() end
				self:Close()
			end,
			isDisabled = not(Raven),
			width = buttonWidth,
			height = buttonHeight,
			justifyH = "LEFT",
			x = 0,
			y = -1,
		},
		{
			label = CHAT_OPTIONS_LABEL,
			func = function()
				local Chatter = LibStub("AceAddon-3.0"):GetAddon("Chatter", true)
				if Chatter then Chatter:OpenConfig() end
				self:Close()
			end,
			isDisabled = not(IsAddOnLoaded("Chatter")),
		},
		{
			label = UNIT_NAMEPLATES ,
			func = function()
				if SlashCmdList.KUINAMEPLATES then SlashCmdList.KUINAMEPLATES() end
				self:Close()
			end,
			isDisabled = not(IsAddOnLoaded("Kui_Nameplates")),
		},
	}
	Element.buttons, Element.maxButtonWidth = cbGUI:CreateButtonList(Element, "VERTICAL", buttons)
	Element.window:SetWidth(Element.maxButtonWidth)
	Element.window.header:SetWidth(Element.maxButtonWidth - 2)
end

function ConfigBar_Other:Close()
	if not Element.window then return end
	if Element.window:IsVisible() then
		Element.window:Hide()
		Element.active = false
		if not Element.highlighted then
			Element.button.highlight:Hide()
		end
	end
end

function ConfigBar_Other:Open()
	if not Element.window then self:SetupWindow() end
	if not Element.window:IsVisible() then
		Element.window:Show()
	end
	return true
end

function ConfigBar_Other:Register()
	Element.info = {
		label = CALENDAR_TYPE_OTHER,
		icon = [[Interface\AddOns\nibRealUI\Media\Config\Other]],
		window = {
			width = 100,	-- place holder, will be set by max button width
			height = (buttonCount * buttonHeight) + 25,
			position = "BUTTONLEFT",
			xOfs = 0,
		},
		openFunc = function() return ConfigBar_Other:Open() end,
		closeFunc = function() ConfigBar_Other:Close() end,
	}
	ConfigBar:RegisterElement(Element, 2)
end

----------
function ConfigBar_Other:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	self:Register()
end