local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local ndb, ndbc

local _
local ConfigBar = nibRealUI:GetModule("ConfigBar")
local cbGUI = nibRealUI:GetModule("ConfigBar_GUI")
local HuDConfig = nibRealUI:GetModule("HuDConfig")

local MODNAME = "ConfigBar_ActionBars"
local ConfigBar_ActionBars = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0")

local Element = {}

function RealUI_ToggleKeyBindings()
	LibStub('LibKeyBound-1.0'):Toggle()
	ConfigBar_ActionBars:Close()
end

local sideBarsLinked
local function UpdateSideBarLink()
	sideBarsLinked = not(ndb.actionBarSettings[nibRealUI.cLayout].sidePositions == 2)
	if sideBarsLinked then
		ConfigBar_ActionBars.sideBarLinkIcon:Show()
	else
		ConfigBar_ActionBars.sideBarLinkIcon:Hide()
	end
end

function ConfigBar_ActionBars:LinkSideBarSettings(index)
	if index == 4 then
		if ndb.actionBarSettings[nibRealUI.cLayout].bars[5].padding ~= ndb.actionBarSettings[nibRealUI.cLayout].bars[4].padding then
			ndb.actionBarSettings[nibRealUI.cLayout].bars[5].padding = ndb.actionBarSettings[nibRealUI.cLayout].bars[4].padding
			self.paddingSliders[5].slider:SetValue(ndb.actionBarSettings[nibRealUI.cLayout].bars[5].padding)
		end
		if ndb.actionBarSettings[nibRealUI.cLayout].bars[5].buttons ~= ndb.actionBarSettings[nibRealUI.cLayout].bars[4].buttons then
			ndb.actionBarSettings[nibRealUI.cLayout].bars[5].buttons = ndb.actionBarSettings[nibRealUI.cLayout].bars[4].buttons
			self.buttonsSliders[5].slider:SetValue(ndb.actionBarSettings[nibRealUI.cLayout].bars[5].buttons)
		end
	else
		if ndb.actionBarSettings[nibRealUI.cLayout].bars[4].padding ~= ndb.actionBarSettings[nibRealUI.cLayout].bars[5].padding then
			ndb.actionBarSettings[nibRealUI.cLayout].bars[4].padding = ndb.actionBarSettings[nibRealUI.cLayout].bars[5].padding
			self.paddingSliders[4].slider:SetValue(ndb.actionBarSettings[nibRealUI.cLayout].bars[4].padding)
		end
		if ndb.actionBarSettings[nibRealUI.cLayout].bars[4].buttons ~= ndb.actionBarSettings[nibRealUI.cLayout].bars[5].buttons then
			ndb.actionBarSettings[nibRealUI.cLayout].bars[4].buttons = ndb.actionBarSettings[nibRealUI.cLayout].bars[5].buttons
			self.buttonsSliders[4].slider:SetValue(ndb.actionBarSettings[nibRealUI.cLayout].bars[4].buttons)
		end
	end
end

function ConfigBar_ActionBars:SetPetBarPadding(value, refresh)
	if refresh then
		self.PBPaddingRefreshing = true
		self.buttonsSliders[6].slider:SetValue(value)
		self.PBPaddingRefreshing = false
		return
	end

	if self.PBPaddingRefreshing then return end

	ndb.actionBarSettings[nibRealUI.cLayout].petBar.padding = value
	HuDConfig:RegisterForUpdate("AB")
end

-- function ConfigBar_ActionBars:SetStanceBarPadding(value, refresh)
-- 	if refresh then
-- 		self.SBPaddingRefreshing = true
-- 		self.buttonsSliders[6].slider:SetValue(value)
-- 		self.SBPaddingRefreshing = false
-- 		return
-- 	end

-- 	if self.SBPaddingRefreshing then return end

-- 	ndb.actionBarSettings[nibRealUI.cLayout].stanceBar.padding = value
-- 	HuDConfig:RegisterForUpdate("AB")
-- end

function ConfigBar_ActionBars:SetActionBarSizePadding(value, index, refresh)
	if refresh then
		self.PaddingRefreshing = true
		self.paddingSliders[index].slider:SetValue(value)
		self.PaddingRefreshing = false
		return
	end

	if self.PaddingRefreshing then return end

	ndb.actionBarSettings[nibRealUI.cLayout].bars[index].padding = value
	HuDConfig:RegisterForUpdate("AB")

	if sideBarsLinked and index > 3 then
		self:LinkSideBarSettings(index)
	end
end

function ConfigBar_ActionBars:SetActionBarSizeButtons(value, index, refresh)
	if refresh then
		self.ButtonsRefreshing = true
		self.buttonsSliders[index].slider:SetValue(value)
		self.ButtonsRefreshing = false
		return
	end
	
	if self.ButtonsRefreshing then return end

	ndb.actionBarSettings[nibRealUI.cLayout].bars[index].buttons = value
	HuDConfig:RegisterForUpdate("AB")

	if sideBarsLinked and index > 3 then
		self:LinkSideBarSettings(index)
	end
end

-- function ConfigBar_ActionBars:SetStanceBarPosition(value, refresh)
-- 	if not refresh then
-- 		ndb.actionBarSettings[nibRealUI.cLayout].stanceBar.position = (value == 1) and "TOP" or "BOTTOM"
-- 		HuDConfig:RegisterForUpdate("AB")
-- 	end
-- 	self.stanceBarPositionOptions[1].check.highlight:SetAlpha(0)
-- 	self.stanceBarPositionOptions[2].check.highlight:SetAlpha(0)
-- 	self.stanceBarPositionOptions[value].check.highlight:SetAlpha(1)
-- end

function ConfigBar_ActionBars:SetActionBarSidePositions(value, refresh)
	if not refresh then
		ndb.actionBarSettings[nibRealUI.cLayout].sidePositions = value
		UpdateSideBarLink()
		self:LinkSideBarSettings(4)
		HuDConfig:RegisterForUpdate("AB")
	end
	self.sidePositionOptions[1].check.highlight:SetAlpha(0)
	self.sidePositionOptions[2].check.highlight:SetAlpha(0)
	self.sidePositionOptions[3].check.highlight:SetAlpha(0)
	self.sidePositionOptions[value].check.highlight:SetAlpha(1)
end

function ConfigBar_ActionBars:SetActionBarCenterPositions(value, refresh)
	if not refresh then
		ndb.actionBarSettings[nibRealUI.cLayout].centerPositions = value
		HuDConfig:RegisterForUpdate("AB")
	end
	self.centerPositionOptions[1].check.highlight:SetAlpha(0)
	self.centerPositionOptions[2].check.highlight:SetAlpha(0)
	self.centerPositionOptions[3].check.highlight:SetAlpha(0)
	self.centerPositionOptions[4].check.highlight:SetAlpha(0)
	self.centerPositionOptions[value].check.highlight:SetAlpha(1)
end

function ConfigBar_ActionBars:ToggleMoveBar(barID, refresh)
	local barIDtoCheck = {stance = 1, pet = 2, eab = 3}
	local checktoBarID = {"stance", "pet", "eab"}
	if refresh then
		for i = 1, 3 do
			self.moveBarOptions[i].check.highlight:SetAlpha(ndb.actionBarSettings[nibRealUI.cLayout].moveBars[checktoBarID[i]] and 1 or 0)
		end
		return
	end
	ndb.actionBarSettings[nibRealUI.cLayout].moveBars[barID] = not(ndb.actionBarSettings[nibRealUI.cLayout].moveBars[barID])

	local doesMove = ndb.actionBarSettings[nibRealUI.cLayout].moveBars[barID]
	self.moveBarOptions[barIDtoCheck[barID]].check.highlight:SetAlpha(doesMove and 1 or 0)

	if barID == "pet" then
		self.buttonsSliders[6]:SetShown(doesMove)
	end

	HuDConfig:RegisterForUpdate("AB")
end

function ConfigBar_ActionBars:ToggleRealUIControl(refresh)
	if not refresh then
		nibRealUI:ToggleAddonPositionControl("Bartender4", not(nibRealUI:DoesAddonMove("Bartender4")))
		HuDConfig:RegisterForUpdate("AB")
	end

	local inControl = nibRealUI:DoesAddonMove("Bartender4")
	self.realControl[1].check.highlight:SetAlpha(inControl and 1 or 0)

	if inControl then
		self.optionsPanel:Show()
		Element.window:SetHeight(569)
	else
		self.optionsPanel:Hide()
		Element.window:SetHeight(192)
	end

	self:SetUpChatCommands()
end

function ConfigBar_ActionBars:ToggleLinkSettings(refresh)
	if refresh then 
		if ndb.abSettingsLink then
			self.linkLayouts[1].check.highlight:SetAlpha(1)
		else
			self.linkLayouts[1].check.highlight:SetAlpha(0)
		end
		return
	end

	ndb.abSettingsLink = not(ndb.abSettingsLink)

	nibRealUI.cLayout = ndbc.layout.current
	nibRealUI.ncLayout = nibRealUI.cLayout == 1 and 2 or 1

	if ndb.abSettingsLink then
		ndb.actionBarSettings[nibRealUI.ncLayout] = nibRealUI:DeepCopy(ndb.actionBarSettings[nibRealUI.cLayout])
		self.linkLayouts[1].check.highlight:SetAlpha(1)
	else
		self.linkLayouts[1].check.highlight:SetAlpha(0)
	end

	self:UpdateHeader()
end

function ConfigBar_ActionBars:UpdateHeader()
	if ndb.abSettingsLink then
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

function ConfigBar_ActionBars:SetupWindow()
	-- Window
	Element.window = cbGUI:CreateWindow(Element, "ActionBars")
	Element.window:Hide()

	-- Header
	Element.headerDT = cbGUI:CreateHeader(Element, ACTIONBAR_LABEL.." » "..L["DPS/Tank"] , 0)
	Element.headerH = cbGUI:CreateHeader(Element, ACTIONBAR_LABEL.." » "..L["Healing"] , 0)
	Element.headerDTH = cbGUI:CreateHeader(Element, ACTIONBAR_LABEL.." » "..L["DPS/Tank"].." + "..L["Healing"] , 0)
	self:UpdateHeader()

	-- RealUI Control
	local options = {
		{
			label = L["RealUI Control"]..".",
			desc = L["Allow RealUI to control the action bars."],
			descGap = 120,
			func = function()
				self:ToggleRealUIControl()
			end,
			checked = nibRealUI:DoesAddonMove("Bartender4"),
			width = Element.info.window.width,
			height = 20,
			x = 0,
			y = -18,
		}
	}
	self.realControl = cbGUI:CreateOptionList(Element, "VERTICAL", options)

	-- Link Settings
	options = {
		{
			label = L["Link Layouts"]..".",
			desc = L["Use same settings between DPS/Tank and Healing layouts."],
			descGap = 120,
			func = function()
				self:ToggleLinkSettings()
			end,
			checked = ndb.abSettingsLink,
			width = Element.info.window.width,
			height = 20,
			x = 0,
			y = -38,
		}
	}
	self.linkLayouts = cbGUI:CreateOptionList(Element, "VERTICAL", options)

	---- Bartender Options ----
	local button = {
		label = LibStub("AceLocale-3.0"):GetLocale("Bartender4")["Key Bindings"],
		width = 150,
		height = 22,
		x = 14,
		y = -84,
		secure = true,
		macroText = "/tar "..UnitName("player").."\n/focus\n/run RealUI_ToggleKeyBindings()",
	}
	local kbButton = cbGUI:CreateButton(Element, button)
	nibRealUI:CreateBGSection(Element.window, kbButton, kbButton)

	button = {
		label = ADVANCED_LABEL.." "..CHAT_CONFIGURATION,
		width = 150,
		height = 22,
		x = 14,
		y = -113,
		func = function()
			LibStub("AceConfigDialog-3.0"):Open("Bartender4")
			self:Close()
		end,
	}
	local advButton = cbGUI:CreateButton(Element, button)
	nibRealUI:CreateBGSection(Element.window, advButton, advButton)

	-- Note
	local note = {
		text = L["Note: Bartender settings"],
		x = 12,
		y = -142,
		color = "green",
	}
	cbGUI:CreateString(Element, note)


	---- Options Panel ----
	self.optionsPanel = CreateFrame("Frame", nil, Element.window)
	local oP = self.optionsPanel
		oP:SetPoint("TOPLEFT", Element.window, "TOPLEFT", 0, -194)
		oP:SetPoint("BOTTOMRIGHT")

		
	---- Bar Positions ----
	local curY = 0
	cbGUI:CreateHeader(oP, L["Positions"], curY)

	-- Move misc bars
	options = {
		{
			label = L["Move Stance Bar"],
			tip = L["Check to allow RealUI to control the Stance Bar's position."],
			func = function()
				self:ToggleMoveBar("stance")
			end,
			checked = ndb.actionBarSettings[nibRealUI.cLayout].moveBars.stance,
			width = Element.info.window.width / 3,
			height = 20,
			x = 0,
			y = curY - 18,
		},
		{
			label = L["Move Pet Bar"],
			tip = L["Check to allow RealUI to control the Pet Bar's position."],
			func = function()
				self:ToggleMoveBar("pet")
			end,
			checked = ndb.actionBarSettings[nibRealUI.cLayout].moveBars.pet,
		},
		{
			label = L["Move Extra Button"],
			tip = L["Check to allow RealUI to control the Extra Action Button's position."],
			func = function()
				self:ToggleMoveBar("eab")
			end,
			checked = ndb.actionBarSettings[nibRealUI.cLayout].moveBars.eab,
		}
	}
	self.moveBarOptions = cbGUI:CreateOptionList(oP, "HORIZONTAL", options)

	-- Center Bars
	options = {
		{
			label = "0 "..L["Center"].." - 3 "..L["Bottom"],
			func = function()
				self:SetActionBarCenterPositions(1)
			end,
			checked = ndb.actionBarSettings[nibRealUI.cLayout].centerPositions == 1,
			width = Element.info.window.width / 3,
			height = 20,
			x = 0,
			y = curY - 44,
		},
		{
			label = "1 "..L["Center"].." - 2 "..L["Bottom"],
			func = function()
				self:SetActionBarCenterPositions(2)
			end,
			checked = ndb.actionBarSettings[nibRealUI.cLayout].centerPositions == 2,
		},
		{
			label = "2 "..L["Center"].." - 1 "..L["Bottom"],
			func = function()
				self:SetActionBarCenterPositions(3)
			end,
			checked = ndb.actionBarSettings[nibRealUI.cLayout].centerPositions == 3,
		},
		{
			label = "3 "..L["Center"].." - 0 "..L["Bottom"],
			func = function()
				self:SetActionBarCenterPositions(4)
			end,
			checked = ndb.actionBarSettings[nibRealUI.cLayout].centerPositions == 4,
		},
	}
	self.centerPositionOptions = cbGUI:CreateOptionList(oP, "VERTICAL", options)

	-- Side Bars
	options = {
		{
			label = "2 "..L["Right"].." - 0 "..L["Left"],
			func = function()
				self:SetActionBarSidePositions(1)
			end,
			checked = ndb.actionBarSettings[nibRealUI.cLayout].sidePositions == 1,
			width = Element.info.window.width / 3,
			height = 20,
			x = Element.info.window.width / 3,
			y = curY - 44,
		},
		{
			label = "1 "..L["Right"].." - 1 "..L["Left"],
			func = function()
				self:SetActionBarSidePositions(2)
			end,
			checked = ndb.actionBarSettings[nibRealUI.cLayout].sidePositions == 2,
		},
		{
			label = "0 "..L["Right"].." - 2 "..L["Left"],
			func = function()
				self:SetActionBarSidePositions(3)
			end,
			checked = ndb.actionBarSettings[nibRealUI.cLayout].sidePositions == 3,
		},
	}
	self.sidePositionOptions = cbGUI:CreateOptionList(oP, "VERTICAL", options)

	---- Other Bars
	-- options = {
	-- 	{
	-- 		label = L["Stance Bar"].." "..L["Center"],
	-- 		func = function()
	-- 			self:SetStanceBarPosition(1)
	-- 		end,
	-- 		checked = ndb.actionBarSettings[nibRealUI.cLayout].stanceBar.position == "TOP",
	-- 		width = Element.info.window.width / 3,
	-- 		height = 20,
	-- 		x = (Element.info.window.width / 3) * 2,
	-- 		y = -94,
	-- 	},
	-- 	{
	-- 		label = L["Stance Bar"].." "..L["Bottom"],
	-- 		func = function()
	-- 			self:SetStanceBarPosition(2)
	-- 		end,
	-- 		checked = ndb.actionBarSettings[nibRealUI.cLayout].stanceBar.position == "BOTTOM",
	-- 	},
	-- }
	-- self.stanceBarPositionOptions = cbGUI:CreateOptionList(oP, "VERTICAL", options)

	---- Bar Settings
	curY = curY - 151
	cbGUI:CreateHeader(oP, L["Sizes"], curY)

	-- Buttons
	local sliders = {
		{
			label = L["Buttons"],
			name = "ABSButtons",
			width = 180,
			height = 20,
			x = 94,
			y = curY - 19,
			sliderWidth = 80,
			min = 4,
			max = 12,
			func = function(value)
				self:SetActionBarSizeButtons(value, 1)
			end,
			value = ndb.actionBarSettings[nibRealUI.cLayout].bars[1].buttons,
		},
		{
			func = function(value)
				self:SetActionBarSizeButtons(value, 2)
			end,
			value = ndb.actionBarSettings[nibRealUI.cLayout].bars[2].buttons,
		},
		{
			func = function(value)
				self:SetActionBarSizeButtons(value, 3)
			end,
			value = ndb.actionBarSettings[nibRealUI.cLayout].bars[3].buttons,
		},
		{
			func = function(value)
				self:SetActionBarSizeButtons(value, 4)
			end,
			value = ndb.actionBarSettings[nibRealUI.cLayout].bars[4].buttons,
		},
		{
			func = function(value)
				self:SetActionBarSizeButtons(value, 5)
			end,
			value = ndb.actionBarSettings[nibRealUI.cLayout].bars[5].buttons,
		},
		-- {
		-- 	label = L["Padding"],
		-- 	min = 0,
		-- 	max = 10,
		-- 	func = function(value)
		-- 		self:SetStanceBarPadding(value)
		-- 	end,
		-- 	value = ndb.actionBarSettings[nibRealUI.cLayout].stanceBar.padding,
		-- },
		{
			label = L["Padding"],
			min = 0,
			max = 10,
			func = function(value)
				self:SetPetBarPadding(value)
			end,
			value = ndb.actionBarSettings[nibRealUI.cLayout].petBar.padding,
		},
	}
	self.buttonsSliders = cbGUI:CreateSliderList(oP, "VERTICAL", sliders)

	-- Bar # labels
	self.barLabels = {}
	for i = 1, 6 do
		local label = self.buttonsSliders[i]:CreateFontString()
		self.barLabels[i] = label
		
		label:SetPoint("RIGHT", self.buttonsSliders[i], "LEFT", 0, 0)
		label:SetJustifyH("LEFT")
		label:SetJustifyV("MIDDLE")
		label:SetSize(76, 20)
		label:SetFont(nibRealUI.font.standard, 10)
		label:SetTextColor(unpack(nibRealUI.media.colors.amber))
		if i <= 5 then
			label:SetText("Bar "..i)
		else
			if i == 6 then
				label:SetText(L["Pet Bar"])
			else
				-- label:SetText(L["Stance Bar"])
			end
		end
	end

	-- Side Bar Link icon
	self.sideBarLinkIcon = oP:CreateTexture(nil, "ARTWORK")
	self.sideBarLinkIcon:SetSize(16, 32)
	self.sideBarLinkIcon:SetPoint("TOPRIGHT", self.barLabels[4], "LEFT", 0, 0)
	self.sideBarLinkIcon:SetTexture([[Interface\AddOns\nibRealUI\Media\Config\BarLink]])
	self.sideBarLinkIcon:SetVertexColor(unpack(nibRealUI.media.colors.orange))

	-- Padding Sliders
	sliders = {
		{
			label = L["Padding"],
			name = "ABSPadding",
			width = 180,
			height = 20,
			x = 288,
			y = curY - 19,
			sliderWidth = 80,
			min = 0,
			max = 10,
			func = function(value)
				self:SetActionBarSizePadding(value, 1)
			end,
			value = ndb.actionBarSettings[nibRealUI.cLayout].bars[1].padding,
		},
		{
			func = function(value)
				self:SetActionBarSizePadding(value, 2)
			end,
			value = ndb.actionBarSettings[nibRealUI.cLayout].bars[2].padding,
		},
		{
			func = function(value)
				self:SetActionBarSizePadding(value, 3)
			end,
			value = ndb.actionBarSettings[nibRealUI.cLayout].bars[3].padding,
		},
		{
			func = function(value)
				self:SetActionBarSizePadding(value, 4)
			end,
			value = ndb.actionBarSettings[nibRealUI.cLayout].bars[4].padding,
		},
		{
			func = function(value)
				self:SetActionBarSizePadding(value, 5)
			end,
			value = ndb.actionBarSettings[nibRealUI.cLayout].bars[5].padding,
		},
	}
	self.paddingSliders = cbGUI:CreateSliderList(oP, "VERTICAL", sliders)

	UpdateSideBarLink()


	-- Hint: Hold down Ctrl
	local hint = {
		text = L["Hint: Hold down Ctrl to view action bars."],
		x = 12,
		y = curY - 172,
		color = "green",
	}
	cbGUI:CreateString(oP, hint)

	-- Hint: Positions
	note = {
		text = L["Note: After changing bar positions..."],
		x = 12,
		y = curY - 190,
		color = "green",
	}
	cbGUI:CreateString(oP, note)
end

function ConfigBar_ActionBars:RefreshDisplay()
	if not Element.window then return end
	self:UpdateHeader()
	self:ToggleRealUIControl(true)
	self:ToggleLinkSettings(true)
	UpdateSideBarLink()
	for i = 1, 5 do
		self:SetActionBarSizeButtons(ndb.actionBarSettings[nibRealUI.cLayout].bars[i].buttons, i, true)
		self:SetActionBarSizePadding(ndb.actionBarSettings[nibRealUI.cLayout].bars[i].padding, i, true)
	end
	self:SetActionBarCenterPositions(ndb.actionBarSettings[nibRealUI.cLayout].centerPositions, true)
	self:SetActionBarSidePositions(ndb.actionBarSettings[nibRealUI.cLayout].sidePositions, true)
	self:SetPetBarPadding(ndb.actionBarSettings[nibRealUI.cLayout].petBar.padding, true)
	self:ToggleMoveBar(nil, true)
	-- self:SetStanceBarPosition((ndb.actionBarSettings[nibRealUI.cLayout].stanceBar.position == "TOP") and 1 or 2, true)
	-- self:SetStanceBarPadding(ndb.actionBarSettings[nibRealUI.cLayout].stanceBar.padding, true)
end

function ConfigBar_ActionBars:PLAYER_REGEN_DISABLED()
	self:Close()
end

function ConfigBar_ActionBars:ShowWindow()
	-- Watch for combat so we can hide window
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	
	-- Refresh display
	self:RefreshDisplay()

	-- Show Window
	Element.window:Show()
end

function ConfigBar_ActionBars:Close()
	if not Element.window then return end

	self:UnregisterEvent("PLAYER_REGEN_DISABLED")

	if Element.window:IsVisible() then
		Element.active = false
		Element.window:Hide()
		if not Element.highlighted then
			Element.button.highlight:Hide()
		end
	end
end

function ConfigBar_ActionBars:Open()
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

function ConfigBar_ActionBars:Register()
	Element.info = {
		label = ACTIONBAR_LABEL,
		icon = [[Interface\AddOns\nibRealUI\Media\Config\ActionBars]],
		window = {
			width = 460,
			height = 535,
			xOfs = 0,
		},
		openFunc = function() return ConfigBar_ActionBars:Open() end,
		closeFunc = function() ConfigBar_ActionBars:Close() end,
		isDisabled = not(Bartender4)
	}
	ConfigBar:RegisterElement(Element, 5)
end

---- Chat Commands
function ConfigBar_ActionBars:BarChatCommand()
	if not(Element.window) or not Element.window:IsShown() then
		if not InCombatLockdown() then
			ConfigBar:Toggle(true, true)
			ConfigBar_Element_OnMouseDown(Element.button)
		end
	end
end

function ConfigBar_ActionBars:SetUpChatCommands()
	if not(Bartender4) then return end

	if nibRealUI:DoesAddonMove("Bartender4") then
		Bartender4:UnregisterChatCommand("bar")
		Bartender4:UnregisterChatCommand("bt")
		Bartender4:UnregisterChatCommand("bt4")
		Bartender4:UnregisterChatCommand("bartender")
		Bartender4:UnregisterChatCommand("bartender4")

		self:RegisterChatCommand("bar", "BarChatCommand")
		self:RegisterChatCommand("bt", "BarChatCommand")
		self:RegisterChatCommand("bt4", "BarChatCommand")
		self:RegisterChatCommand("bartender", "BarChatCommand")
		self:RegisterChatCommand("bartender4", "BarChatCommand")
	else
		self:UnregisterChatCommand("bar")
		self:UnregisterChatCommand("bt")
		self:UnregisterChatCommand("bt4")
		self:UnregisterChatCommand("bartender")
		self:UnregisterChatCommand("bartender4")

		Bartender4:RegisterChatCommand("bar", "ChatCommand")
		Bartender4:RegisterChatCommand("bt", "ChatCommand")
		Bartender4:RegisterChatCommand("bt4", "ChatCommand")
		Bartender4:RegisterChatCommand("bartender", "ChatCommand")
		Bartender4:RegisterChatCommand("bartender4", "ChatCommand")
	end
end

----------
function ConfigBar_ActionBars:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	self:Register()

	self:SetUpChatCommands()
end