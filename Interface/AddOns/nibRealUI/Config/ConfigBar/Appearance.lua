local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local ndb, ndbc

local _
local ConfigBar = nibRealUI:GetModule("ConfigBar")
local cbGUI = nibRealUI:GetModule("ConfigBar_GUI")

local UnitFrames = nibRealUI:GetModule("UnitFrames")
local CastBars = nibRealUI:GetModule("CastBars")

local MODNAME = "ConfigBar_Appearance"
local ConfigBar_Appearance = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local Element = {}

function ConfigBar_Appearance:UpdateCastBarColorVisibility()
	if CastBars.db.profile.colors.useGlobal then
		for k,frame in pairs(self.colors.castBars) do
			frame:Hide()
		end
		self.colors.castBarsGeneralTip:Show()
	else
		for k,frame in pairs(self.colors.castBars) do
			frame:Show()
		end
		self.colors.castBarsGeneralTip:Hide()
	end
end

function ConfigBar_Appearance:UpdateCastBarColor(index, key, r, g, b)
	CastBars.db.profile.colors[key] = {r, g, b, 1}
	CastBars:UpdateTextures()
	self.colors.castBars[index].r = r
    self.colors.castBars[index].g = g
    self.colors.castBars[index].b = b
    self.colors.castBars[index].a = 1
end

function ConfigBar_Appearance:UpdateUnitFramesStatusColor(index, key, r, g, b)
	UnitFrames.db.profile.overlay.colors.status[key] = {r, g, b}
	UnitFrames:RefreshUnits()
	self.colors.unitFrames[index].r = r
	self.colors.unitFrames[index].g = g
	self.colors.unitFrames[index].b = b
	self.colors.unitFrames[index].a = 1
end

function ConfigBar_Appearance:UpdateUnitFramesPowerColor(index, key, r, g, b)
	UnitFrames.db.profile.overlay.colors.power[key] = {r, g, b}
	UnitFrames:SetPowerColors()
	UnitFrames:RefreshUnits()
	self.colors.unitFrames[index].r = r
	self.colors.unitFrames[index].g = g
	self.colors.unitFrames[index].b = b
	self.colors.unitFrames[index].a = 1
end

function ConfigBar_Appearance:UpdateGeneralColor(index, key, r, g, b, a)
	nibRealUI.media.colors[key] = {r, g, b, 1}
	nibRealUI:StyleUpdateColors()
	self.colors.general[index].r = r
	self.colors.general[index].g = g
	self.colors.general[index].b = b
	self.colors.general[index].a = 1
end

function ConfigBar_Appearance:UpdateFontStyleOptions()
	if not self.fontOptions then return end
	self.fontOptions[1].check.highlight:SetAlpha(0)
	self.fontOptions[2].check.highlight:SetAlpha(0)
	self.fontOptions[3].check.highlight:SetAlpha(0)
	self.fontOptions[ndb.settings.fontStyle].check.highlight:SetAlpha(1)
	self.fontOptions[4].check.highlight:SetAlpha(ndb.settings.chatFontOutline and 1 or 0)
end

-- Tab Change
function ConfigBar_Appearance:ChangeTab(tabID, isInit)
	if isInit then
		self.currentTab = 3
	end
	if self.currentTab == tabID then
		return
	end

	for k,v in pairs(self.tabs) do
		if k ~= tabID then
			self.tabPanels[k]:Hide()
			self.tabs[k].icon:SetVertexColor(0.5, 0.5, 0.5)
		end
	end

	self.tabPanels[tabID]:Show()
	self.tabs[tabID].icon:SetVertexColor(1, 1, 1)
	
	self.currentTab = tabID

	if tabID == 1 then
		Element.window:SetHeight(128)
	elseif tabID == 2 then
		Element.window:SetHeight(182)
	else
		Element.window:SetHeight(245)
	end
end

function ConfigBar_Appearance:SetupWindow()
	-- Window
	Element.window = cbGUI:CreateWindow(Element, "Appearance")

	-- Tabs
	local tabs = {
		{
			texture = [[Interface\AddOns\nibRealUI\Media\Config\Advanced]],
			texPosition = {x = 0, y = -4},
			func = function() self:ChangeTab(1) end,
		},
		{
			texture = [[Interface\AddOns\nibRealUI\Media\Config\Fonts]],
			texPosition = {x = 0, y = -4},
			func = function() self:ChangeTab(2) end,
		},
		{
			texture = [[Interface\AddOns\nibRealUI\Media\Config\Colors]],
			texPosition = {x = 0, y = -4},
			func = function() self:ChangeTab(3) end,
		},
	}
	self.tabs = cbGUI:CreateTabList(Element, tabs, "VERTICAL", "TOPLEFT", -33, -28)

	self.tabPanels = {}
	for k,v in pairs(tabs) do
		self.tabPanels[k] = CreateFrame("Frame", nil, Element.window)	
			self.tabPanels[k]:SetAllPoints(Element.window)
	end

	local tabPanel1 = self.tabPanels[1]
	local tabPanel2 = self.tabPanels[2]
	local tabPanel3 = self.tabPanels[3]

	self:ChangeTab(1, true)

	----------------------
	------ Settings ------
	----------------------
	self.settings = {}
	cbGUI:CreateHeader(tabPanel1, CHAT_CONFIGURATION, 0)

	local slider = {
		{
			label = L["Window Opacity"],
			name = "AppearanceWindowOpacity",
			width = 260,
			height = 20,
			x = 47,
			y = -18,
			step = 1,
			sliderWidth = 120,
			min = 50,
			max = 100,
			func = function(value)
				nibRealUI.media.window[4] = value / 100
				nibRealUI:StyleSetWindowOpacity()
			end,
			value = nibRealUI.media.window[4] * 100,
		},
		{
			label = L["Stripe Opacity"],
			name = "AppearanceStripeOpacity",
			step = 5,
			min = 0,
			max = 100,
			func = function(value)
				ndb.settings.stripeOpacity = value / 100
				nibRealUI:StyleSetStripeOpacity()
			end,
			value = ndb.settings.stripeOpacity * 100,
		},
	}
	self.settings[1] = cbGUI:CreateSliderList(tabPanel1, "VERTICAL", slider)

	local check = {
		{
			label = L["Info Line"].." "..BACKGROUND,
			func = function()
				nibRealUI:StyleSetInfoLineBackground(not(ndb.settings.infoLineBackground))
				self.settings[2][1].check.highlight:SetAlpha(ndb.settings.infoLineBackground and 1 or 0)
			end,
			checked = ndb.settings.infoLineBackground,
			width = Element.info.window.width / 2,
			height = 20,
			x = 0,
			y = -66
		},
	}
	self.settings[2] = cbGUI:CreateOptionList(tabPanel1, "VERTICAL", check)

	if UnitFrames and nibRealUI:GetModuleEnabled("UnitFrames") then
		check = {
			{
				label = CLASS.." "..COLOR.." "..HEALTH.." "..L["Bars"],
				func = function()
					UnitFrames:ToggleClassColoring(false)
					self.settings[3][1].check.highlight:SetAlpha(UnitFrames.db.profile.overlay.classColor and 1 or 0)
				end,
				checked = UnitFrames.db.profile.overlay.classColor,
				width = Element.info.window.width / 2,
				height = 20,
				x = Element.info.window.width / 2,
				y = -66
			},
			{
				label = CLASS.." "..COLOR.." "..UNIT_NAMES,
				func = function()
					UnitFrames:ToggleClassColoring(true)
					self.settings[3][2].check.highlight:SetAlpha(UnitFrames.db.profile.overlay.classColorNames and 1 or 0)
				end,
				checked = UnitFrames.db.profile.overlay.classColorNames,
			},
		}
		self.settings[3] = cbGUI:CreateOptionList(tabPanel1, "VERTICAL", check)
	end

	------------------------
	------ Font Style ------
	------------------------
	cbGUI:CreateHeader(tabPanel2, L["Fonts"], 0)

	local options = {
		{
			label = SMALL,
			desc = L["Use small fonts"],
			func = function()
				nibRealUI:StyleSetFont(1)
				self:UpdateFontStyleOptions()
			end,
			checked = ndb.settings.fontStyle == 1,
			width = Element.info.window.width,
			height = 20,
			x = 0,
			y = -18,
		},
		{
			label = L["FS:Hybrid"],
			desc = L["Use a mix of small and large fonts"],
			func = function()
				nibRealUI:StyleSetFont(2)
				self:UpdateFontStyleOptions()
			end,
			checked = ndb.settings.fontStyle == 2,
		},
		{
			label = LARGE,
			desc = L["Use large fonts"],
			func = function()
				nibRealUI:StyleSetFont(3)
				self:UpdateFontStyleOptions()
			end,
			checked = ndb.settings.fontStyle == 3,
		},
		{
			label = L["Chat Font Outline"],
			func = function()
				ndb.settings.chatFontOutline = not(ndb.settings.chatFontOutline)
				nibRealUI:StyleSetChatFont()
				self:UpdateFontStyleOptions()
			end,
			checked = ndb.settings.chatFontOutline,
		},
	}
	self.fontOptions = cbGUI:CreateOptionList(tabPanel2, "VERTICAL", options)

	slider = {
		{
			label = CHAT.." "..FONT_SIZE,
			name = "AppearanceChatFontSize",
			width = 260,
			height = 20,
			x = 36,
			y = -98,
			sliderWidth = 120,
			min = 8,
			max = 16,
			func = function(value)
				ndb.settings.chatFontSize = value
				nibRealUI:StyleSetChatFont()
			end,
			value = ndb.settings.chatFontSize,
		},
	}
	self.chatFont = cbGUI:CreateSliderList(tabPanel2, "VERTICAL", slider)[1]

	local button = {
		label = ADVANCED_LABEL.." "..CHAT_CONFIGURATION,
		width = 136,
		height = 22,
		x = 14,
		y = -145,
		func = function() nibRealUI:OpenOptions("Fonts") end,
	}
	local advButton = cbGUI:CreateButton(tabPanel2, button)
	nibRealUI:CreateBGSection(tabPanel2, advButton, advButton)
	
	--------------------
	------ Colors ------
	--------------------
	self.colors = {}
	cbGUI:CreateHeader(tabPanel3, COLORS, 0)

	-- General
	cbGUI:CreateSecondHeader(tabPanel3, GENERAL, 12, -32, (Element.info.window.width - 72) / 3)
	local colorPickers = {
		{
			label = "Purple",
			func = function(r, g, b, a)
				ConfigBar_Appearance:UpdateGeneralColor(1, "purple", r, g, b, a)
			end,
			color = nibRealUI.media.colors.purple,
			width = (Element.info.window.width - 72) / 3,
			height = 20,
			x = 12,
			y = -52,
		},
		{
			label = "Blue",
			func = function(r, g, b, a)
				ConfigBar_Appearance:UpdateGeneralColor(2, "blue", r, g, b, a)
			end,
			color = nibRealUI.media.colors.blue,
		},
		{
			label = "Cyan",
			func = function(r, g, b, a)
				ConfigBar_Appearance:UpdateGeneralColor(3, "cyan", r, g, b, a)
			end,
			color = nibRealUI.media.colors.cyan,
		},
		{
			label = "Green",
			func = function(r, g, b, a)
				ConfigBar_Appearance:UpdateGeneralColor(4, "green", r, g, b, a)
			end,
			color = nibRealUI.media.colors.green,
		},
		{
			label = "Yellow",
			func = function(r, g, b, a)
				ConfigBar_Appearance:UpdateGeneralColor(5, "yellow", r, g, b, a)
			end,
			color = nibRealUI.media.colors.yellow,
		},
		{
			label = "Amber",
			func = function(r, g, b, a)
				ConfigBar_Appearance:UpdateGeneralColor(6, "amber", r, g, b, a)
			end,
			color = nibRealUI.media.colors.amber,
		},
		{
			label = "Orange",
			func = function(r, g, b, a)
				ConfigBar_Appearance:UpdateGeneralColor(7, "orange", r, g, b, a)
			end,
			color = nibRealUI.media.colors.orange,
		},
		{
			label = "Red",
			func = function(r, g, b, a)
				ConfigBar_Appearance:UpdateGeneralColor(8, "red", r, g, b, a)
			end,
			color = nibRealUI.media.colors.red,
		}
	}
	self.colors.general = cbGUI:CreateColorPickerList(tabPanel3, "VERTICAL", colorPickers)

	-- Unit Frames
	if nibRealUI:GetModuleEnabled("UnitFrames") then
		if UnitFrames then
			local x = (Element.info.window.width - 72) / 3 + 36
			cbGUI:CreateSecondHeader(tabPanel3, UNITFRAME_LABEL, x, -32, (Element.info.window.width - 72) / 3)
			colorPickers = {
				{
					label = HEALTH,
					func = function(r, g, b, a)
						a = 1
						UnitFrames.db.profile.overlay.colors.health.normal = {r, g, b}
						UnitFrames:RefreshUnits()
						self.colors.unitFrames[1].r = r self.colors.unitFrames[1].g = g self.colors.unitFrames[1].b = b self.colors.unitFrames[1].a = a
					end,
					color = UnitFrames:GetHealthColor(),
					width = (Element.info.window.width - 72) / 3,
					height = 20,
					x = x,
					y = -52,
				},
				{
					label = MANA,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateUnitFramesPowerColor(2, "MANA", r, g, b)
					end,
					color = UnitFrames:GetPowerColors()["MANA"],
				},
				{
					label = RUNIC_POWER,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateUnitFramesPowerColor(3, "RUNIC_POWER", r, g, b)
					end,
					color = UnitFrames:GetPowerColors()["RUNIC_POWER"],
				},
				{
					label = POWER_TYPE_ENERGY,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateUnitFramesPowerColor(4, "ENERGY", r, g, b)
					end,
					color = UnitFrames:GetPowerColors()["ENERGY"],
				},
				{
					label = FOCUS,
					func = function(r, g, b, a)
						a = 1
						ConfigBar_Appearance:UpdateUnitFramesPowerColor(5, "FOCUS", r, g, b)
					end,
					color = UnitFrames:GetPowerColors()["FOCUS"],
				},
				{
					label = RAGE,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateUnitFramesPowerColor(6, "RAGE", r, g, b)
					end,
					color = UnitFrames:GetPowerColors()["RAGE"],
				},
				{
					label = FACTION_STANDING_LABEL5,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateUnitFramesStatusColor(7, "friendly", r, g, b)
					end,
					color = UnitFrames:GetStatusColors()["friendly"],
				},
				{
					label = FACTION_STANDING_LABEL4,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateUnitFramesStatusColor(8, "neutral", r, g, b)
					end,
					color = UnitFrames:GetStatusColors()["neutral"],
				},
				{
					label = FACTION_STANDING_LABEL2,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateUnitFramesStatusColor(9, "hostile", r, g, b)
					end,
					color = UnitFrames:GetStatusColors()["hostile"],
				},
			}
			self.colors.unitFrames = cbGUI:CreateColorPickerList(tabPanel3, "VERTICAL", colorPickers)

			-- button = {
			-- 	label = ADVANCED_LABEL.." "..COLORS,
			-- 	width = (Element.info.window.width - 72) / 3,
			-- 	height = 24,
			-- 	x = 12,
			-- 	y = -464,
			-- 	func = function() nibRealUI:OpenOptions("hud", "UnitFrames", "overlay", "colors") end,
			-- }
			-- cbGUI:CreateButton(Element, button)
		end
	end

	-- Cast Bars
	if nibRealUI:GetModuleEnabled("CastBars") then
		if CastBars then
			local x
			local width = (Element.info.window.width - 72) / 3
			if UnitFrames and nibRealUI:GetModuleEnabled("UnitFrames") then
				x = ((Element.info.window.width - 72) / 3) * 2 + 60
			else
				x = (Element.info.window.width - 72) / 3 + 36
			end

			check = {
				{
					label = L["Use"].." "..GENERAL,
					func = function()
						CastBars.db.profile.colors.useGlobal = not(CastBars.db.profile.colors.useGlobal)
						CastBars:UpdateTextures()
						ConfigBar_Appearance:UpdateCastBarColorVisibility()
						self.colors.castBarsGeneral[1].check.highlight:SetAlpha(CastBars.db.profile.colors.useGlobal and 1 or 0)
					end,
					checked = CastBars.db.profile.colors.useGlobal,
					width = width,
					height = 20,
					x = x,
					y = -40
				}
			}
			self.colors.castBarsGeneral = cbGUI:CreateOptionList(tabPanel3, "VERTICAL", check)

			local tip = {
				text = L["Untick"].." |cffffa300"..L["Use"].."\n"..GENERAL.."|r "..L["to set"].." \n"..L["custom colors"]..".",
				justify = "LEFT",
				x = x,
				y = -76,
			}
			self.colors.castBarsGeneralTip = cbGUI:CreateString(tabPanel3, tip)

			cbGUI:CreateSecondHeader(tabPanel3, SHOW_ENEMY_CAST, x, -32, width)
			colorPickers = {
				{
					label = PLAYER,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateCastBarColor(1, "player", r, g, b)
					end,
					color = CastBars:GetColors()["player"],
					width = (Element.info.window.width - 72) / 3,
					height = 20,
					x = x,
					y = -72,
				},
				{
					label = SPELL_FAILED_OUT_OF_RANGE,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateCastBarColor(2, "outOfRange", r, g, b)
					end,
					color = CastBars:GetColors()["outOfRange"],
				},
				{
					label = TARGET,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateCastBarColor(3, "target", r, g, b)
					end,
					color = CastBars:GetColors()["target"],
				},
				{
					label = FOCUS,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateCastBarColor(4, "focus", r, g, b)
					end,
					color = CastBars:GetColors()["focus"],
				},
				{
					label = "Not "..ENCOUNTER_JOURNAL_SECTION_FLAG6,
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateCastBarColor(5, "uninterruptible", r, g, b)
					end,
					color = CastBars:GetColors()["uninterruptible"],
				},
				{
					label = L["Latency"],
					func = function(r, g, b, a)
						ConfigBar_Appearance:UpdateCastBarColor(6, "latency", r, g, b)
					end,
					color = CastBars:GetColors()["latency"],
				},
			}
			self.colors.castBars = cbGUI:CreateColorPickerList(tabPanel3, "VERTICAL", colorPickers)

			ConfigBar_Appearance:UpdateCastBarColorVisibility()
		end
	end
end

function ConfigBar_Appearance:Close()
	if not Element.window then return end
	if Element.window:IsVisible() then
		Element.window:Hide()
		Element.active = false
		if not Element.highlighted then
			Element.button.highlight:Hide()
		end
	end
end

function ConfigBar_Appearance:Open()
	if not Element.window then self:SetupWindow() end
	if not Element.window:IsVisible() then
		Element.window:Show()
	end
	return true
end

function ConfigBar_Appearance:Register()
	Element.info = {
		label = APPEARANCE_LABEL,
		icon = [[Interface\AddOns\nibRealUI\Media\Config\Appearance]],
		window = {
			width = 396,
			height = 400,
			xOfs = 0,
		},
		openFunc = function() return ConfigBar_Appearance:Open() end,
		closeFunc = function() ConfigBar_Appearance:Close() end,
	}
	ConfigBar:RegisterElement(Element, 3)
end

----------
function ConfigBar_Appearance:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	self:Register()
	-- self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function ConfigBar_Appearance:PLAYER_ENTERING_WORLD()
	if not InCombatLockdown() then
		ConfigBar:Toggle(true, true)
		ConfigBar_Element_OnMouseDown(Element.button)
	end
end