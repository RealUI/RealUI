local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local ndb, ndbc

local _
local ConfigBar = nibRealUI:GetModule("ConfigBar")
local cbGUI = nibRealUI:GetModule("ConfigBar_GUI")
local HuDConfig = nibRealUI:GetModule("HuDConfig")
local HuDConfig_Positions = nibRealUI:GetModule("HuDConfig_Positions")

local MODNAME = "ConfigBar_Positions"
local ConfigBar_Positions = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0")

local Element = {}

function ConfigBar_Positions:ToggleHuDSize()
	ndb.settings.hudSize = ndb.settings.hudSize == 1 and 2 or 1
	nibRealUI.db.global.messages.largeHuDOption = true

	if ndb.settings.hudSize == 1 then
		self.positionOptions[2].check.highlight:SetAlpha(0)
	else
		self.positionOptions[2].check.highlight:SetAlpha(1)
	end

	self:Close()

	-- Display Info Dialog
	StaticPopupDialogs["PUDRUIHUDSIZEINFO"] = {
		text = L["Changing HuD size will alter the size of several UI Elements, therefore it is recommended to check UI Element positions once the HuD Size changes have taken effect."],
		button1 = "Okay",
		OnAccept = function()
			nibRealUI:ReloadUIDialog()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		notClosableByLogout = false,
	}
	StaticPopup_Show("PUDRUIHUDSIZEINFO")
end

function ConfigBar_Positions:ToggleLinkSettings()
	ndb.positionsLink = not(ndb.positionsLink)

	nibRealUI.cLayout = ndbc.layout.current
	nibRealUI.ncLayout = nibRealUI.cLayout == 1 and 2 or 1

	if ndb.positionsLink then
		ndb.positions[nibRealUI.ncLayout] = nibRealUI:DeepCopy(ndb.positions[nibRealUI.cLayout])
		self.positionOptions[1].check.highlight:SetAlpha(1)
	else
		self.positionOptions[1].check.highlight:SetAlpha(0)
	end

	self:UpdateHeader()
end

function ConfigBar_Positions:UpdateHeader()
	if not Element.window then return end
	if ndb.positionsLink then
		Element.headerDT:Hide()
		Element.headerH:Hide()
		Element.headerDTH:Show()
	elseif ndbc.layout.current == 1 then
		Element.headerH:Hide()
		Element.headerDTH:Hide()
		Element.headerDT:Show()
	elseif ndbc.layout.current == 2 then
		Element.headerDT:Hide()
		Element.headerDTH:Hide()
		Element.headerH:Show()
	end
end

function ConfigBar_Positions:SetupWindow()
	-- Window
	Element.window = cbGUI:CreateWindow(Element, "Positions")
	Element.window:Hide()

	-- Header
	Element.headerDT = cbGUI:CreateHeader(Element, L["Positions"].." » "..L["DPS/Tank"] , 0)
	Element.headerH = cbGUI:CreateHeader(Element, L["Positions"].." » "..L["Healing"] , 0)
	Element.headerDTH = cbGUI:CreateHeader(Element, L["Positions"].." » "..L["DPS/Tank"].." + "..L["Healing"] , 0)
	self:UpdateHeader()

	-- Instructions
	cbGUI:CreateSecondHeader(Element, L["Instructions"], 12, -30, 100)
	local tip = {
		text = L["HuD Instructions"],
		justify = "LEFT",
		spacing = 3,
		x = 18,
		y = -50,
	}
	cbGUI:CreateString(Element, tip)

	-- Link Settings
	local options = {
		{
			label = L["Link Layouts"],
			desc = L["Use same settings between DPS/Tank and Healing layouts."],
			descGap = 116,
			func = function()
				self:ToggleLinkSettings()
			end,
			checked = ndb.positionsLink,
			width = Element.info.window.width,
			height = 20,
			x = 0,
			y = -90,
		},
		{
			label = L["Use Large HuD"],
			desc = L["Increases size of key HuD elements (Unit Frames, etc)."],
			descGap = 116,
			func = function()
				self:ToggleHuDSize()
			end,
			checked = ndb.settings.hudSize == 2,
		}
	}
	self.positionOptions = cbGUI:CreateOptionList(Element, "VERTICAL", options)

	local buttons = {}
	local button = {
		label = L["Show UI Elements"],
		secure = true,
		macroText = "/tar "..UnitName("player").."\n/focus\n/run RealUIHuDTestMode(true)",
		width = 146,
		height = 22,
		x = 14,
		y = -152,
	}
	buttons[1] = cbGUI:CreateButton(Element, button)

	button = {
		label = L["Hide UI Elements"],
		secure = true,
		macroText = "/clearfocus\n/cleartarget\n/run RealUIHuDTestMode(false)",
		width = 146,
		height = 22,
		x = 161,
		y = -152,
	}
	buttons[2] = cbGUI:CreateButton(Element, button)

	button = {
		label = L["Load Defaults"],
		width = 146,
		height = 22,
		x = 308,
		y = -152,
		func = function() HuDConfig:ResetDefaults() end,
	}
	buttons[3] = cbGUI:CreateButton(Element, button)

	nibRealUI:CreateBGSection(Element.window, buttons[1], buttons[3])
end

function ConfigBar_Positions:UI_SCALE_CHANGED()
	self:Close()
end

function ConfigBar_Positions:ShowWindow()
	self:RegisterEvent("UI_SCALE_CHANGED")
	
	-- Refresh display
	self:UpdateHeader()

	-- Show Window and initialize HuD Config
	Element.window:Show()
	HuDConfig:InitHuDConfig()
	
	local hcP = HuDConfig_Positions:Open()
	if not hcP.positionSet then
		hcP:SetPoint("TOP", Element.window, "BOTTOM", 0, 0)
		hcP.positionSet = true
	end
end

function ConfigBar_Positions:Close()
	if not Element.window then return end

	self:UnregisterEvent("UI_SCALE_CHANGED")

	if Element.window:IsVisible() then
		Element.active = false
		Element.window:Hide()
		HuDConfig_Positions:Close()
		RealUIHuDCloseConfig()
		if not Element.highlighted then
			Element.button.highlight:Hide()
		end
	end
end

function ConfigBar_Positions:Open()
	if Element.window and Element.window:IsVisible() then return end
	if InCombatLockdown() then
		return false
	end
	if not Element.window then self:SetupWindow() end
	if not Element.window:IsVisible() then
		self:ShowWindow()
	end

	return true
end

function ConfigBar_Positions:ChatCommand()
	if not(Element.window) or not Element.window:IsShown() then
		if not InCombatLockdown() then
			ConfigBar:Toggle(true, true)
			ConfigBar_Element_OnMouseDown(Element.button)
		end
	end
end

function ConfigBar_Positions:Register()
	Element.info = {
		label = L["Positions"],
		icon = [[Interface\AddOns\nibRealUI\Media\Config\Positions]],
		window = {
			width = 510,
			height = 189,
			xOfs = 0,
		},
		openFunc = function() return ConfigBar_Positions:Open() end,
		closeFunc = function() ConfigBar_Positions:Close() end,
	}
	ConfigBar:RegisterElement(Element, 4)
end

----------
function ConfigBar_Positions:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	self:Register()
	self:RegisterChatCommand("hud", "ChatCommand")
end