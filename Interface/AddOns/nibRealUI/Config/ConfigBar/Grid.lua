local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local ndb, ndbc

local _
local ConfigBar = nibRealUI:GetModule("ConfigBar")
local cbGUI = nibRealUI:GetModule("ConfigBar_GUI")

local rGridLayout = nibRealUI:GetModule("GridLayout")

local MODNAME = "ConfigBar_Grid"
local ConfigBar_Grid = nibRealUI:NewModule(MODNAME, "AceTimer-3.0", "AceConsole-3.0")

local Element = {}

local function RefreshTestMode()
	nibRealUI:ToggleGridTestMode(false)
	nibRealUI:ToggleGridTestMode(true)
end

function ConfigBar_Grid:GetUnitHeight(layout)
	local prof = (layout == "dps") and "RealUI" or "RealUI-Healing"
	if Grid2DB["namespaces"]["Grid2Frame"]["profiles"][prof]["frameHeight"] then
		return Grid2DB["namespaces"]["Grid2Frame"]["profiles"][prof]["frameHeight"]
	end
end

function ConfigBar_Grid:SetUnitHeight(layout, value)
	local prof = (layout == "dps") and "RealUI" or "RealUI-Healing"
	if Grid2DB["namespaces"]["Grid2Frame"]["profiles"][prof]["frameHeight"] then
		Grid2DB["namespaces"]["Grid2Frame"]["profiles"][prof]["frameHeight"] = value
	end
	if Grid2Layout then
		-- Grid2Frame:LayoutFrames()
		Grid2Layout:UpdateSize()
		Grid2Layout:ReloadLayout()
		RefreshTestMode()
	end
end

function ConfigBar_Grid:SetUnitWidth(layout, value, key)
	local type = (key == 1) and "width" or "sWidth"
	nibRealUI:SetGridLayoutSettings(value, layout, type)
end

function ConfigBar_Grid:ToggleShowSolo(layout, key)
	local val = nibRealUI:GetGridLayoutSettings(layout, "showSolo")
	nibRealUI:SetGridLayoutSettings(not(val), layout, "showSolo")

	local optionGroup = (layout == "dps") and self.dtHGroups or self.hHGroups
	optionGroup[key].check.highlight:SetAlpha(not(val) and 1 or 0)

	RefreshTestMode()
end

function ConfigBar_Grid:TogglePetFrames(layout, key)
	local val = nibRealUI:GetGridLayoutSettings(layout, "showPet")
	nibRealUI:SetGridLayoutSettings(not(val), layout, "showPet")

	local optionGroup = (layout == "dps") and self.dtHGroups or self.hHGroups
	optionGroup[key].check.highlight:SetAlpha(not(val) and 1 or 0)

	RefreshTestMode()
end

function ConfigBar_Grid:ToggleHGroups(layout, key)
	local type = (key == 1) and "normal" or (key == 2) and "raid" or "bg"
	local val = nibRealUI:GetGridLayoutSettings(layout, "hGroups", type)
	nibRealUI:SetGridLayoutSettings(not(val), layout, "hGroups", type)

	local optionGroup = (layout == "dps") and self.dtHGroups or self.hHGroups
	optionGroup[key].check.highlight:SetAlpha(not(val) and 1 or 0)

	RefreshTestMode()
end

function ConfigBar_Grid:ToggleRealUIControl(key)
	-- Positions
	if key == 1 then
		local pos = nibRealUI:GetAddonControlSettings("Grid2")["position"]
		nibRealUI:ToggleAddonPositionControl("Grid2", not(pos))
		self.realControl[1].check.highlight:SetAlpha(pos and 0 or 1)

	-- Layout (style)
	elseif key == 2 then
		local style = nibRealUI:GetAddonControlSettings("Grid2")["style"]
		nibRealUI:ToggleAddonStyleControl("Grid2", not(style))
		self.realControl[2].check.highlight:SetAlpha(style and 0 or 1)
		self:ChangeTab(self.currentTab)

	-- Style (skin)
	elseif key == 3 then
		local skin = nibRealUI:GetModuleEnabled("SkinGrid2")
		nibRealUI:SetModuleEnabled("SkinGrid2", not(skin))
		self.realControl[3].check.highlight:SetAlpha(skin and 0 or 1)
	end
end

-- Tab Change
function ConfigBar_Grid:ChangeTab(tabID, isInit)
	if not nibRealUI:DoesAddonStyle("Grid2") then
		tabID = 1
		self.tabs[2]:Hide()
		self.tabs[3]:Hide()
	else
		self.tabs[2]:Show()
		self.tabs[3]:Show()
	end

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
		Element.window:SetHeight(197)
	elseif tabID == 2 then
		Element.window:SetHeight(212)
	else
		Element.window:SetHeight(212)
	end
end

-- Setup Window
function ConfigBar_Grid:SetupWindow()
	if not(Grid2 and Grid2Layout and Grid2Frame and Grid2DB) then return end
	local labelGrid2 = LibStub("AceLocale-3.0"):GetLocale("Grid2")["Grid2"]

	-- Window
	Element.window = cbGUI:CreateWindow(Element, "ActionBars")
	Element.window:Hide()

	-- Tabs
	local tabs = {
		{
			texture = [[Interface\AddOns\nibRealUI\Media\Config\Advanced]],
			texPosition = {x = 0, y = -4},
			func = function() self:ChangeTab(1) end,
		},
		{
			texture = [[Interface\LFGFrame\UI-LFG-ICON-ROLES]],
			texCoord = {GetTexCoordsForRole("DAMAGER")},
			texOffset = {-3, -4, 3, 2},	-- BLx, BLy, TRx, TRy
			func = function() self:ChangeTab(2) end,
		},
		{
			texture = [[Interface\LFGFrame\UI-LFG-ICON-ROLES]],
			texCoord = {GetTexCoordsForRole("HEALER")},
			texOffset = {-2, -3, 2, 1},	-- BLx, BLy, TRx, TRy
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

	---- Settings ----
	-- Header
	cbGUI:CreateHeader(tabPanel1, L["RealUI Control"], 0)

	-- RealUI Control
	local options = {
		{
			label = L["Positions"]..".",
			desc = string.format(L["Allow RealUI to control STR position settings."], labelGrid2),
			descGap = 104,
			func = function()
				self:ToggleRealUIControl(1)
			end,
			checked = nibRealUI:DoesAddonMove("Grid2"),
			width = Element.info.window.width,
			height = 20,
			x = 0,
			y = -18,
		},
		{
			label = L["Layout"]..".",
			desc = string.format(L["Allow RealUI to control STR layout settings."], labelGrid2),
			descGap = 104,
			func = function()
				self:ToggleRealUIControl(2)
			end,
			checked = nibRealUI:DoesAddonStyle("Grid2"),
		},
		{
			label = L["Style"]..".",
			desc = string.format(L["Allow RealUI to style STR."], labelGrid2),
			descGap = 104,
			func = function()
				self:ToggleRealUIControl(3)
			end,
			checked = nibRealUI:GetModuleEnabled("SkinGrid2"),
		}
	}
	self.realControl = cbGUI:CreateOptionList(tabPanel1, "VERTICAL", options)

	-- Advanced Settings
	cbGUI:CreateHeader(tabPanel1, nil, -100)
	local button = {
		label = ADVANCED_LABEL.." "..CHAT_CONFIGURATION,
		width = 136,
		height = 22,
		x = 14,
		y = -116,
		func = function()
			Grid2:OnChatCommand("")
		end,
	}
	local advButton = cbGUI:CreateButton(tabPanel1, button)
	nibRealUI:CreateBGSection(tabPanel1, advButton, advButton)

	-- Note
	local note = {
		text = L["Note: Grid2 settings"],
		x = 12,
		y = -152,
		color = "green",
	}
	cbGUI:CreateString(tabPanel1, note)


	---- Layout - DPS/Tank ----
	local lY = 0
	cbGUI:CreateHeader(tabPanel2, L["Layout"].." » "..L["DPS/Tank"], lY)

	-- Horizontal Groups / Pet Frames
	options = {
		{
			label = L["Horizontal Groups"].." - "..SOLO.." / "..DUNGEONS.." / "..SCENARIOS.." / "..ARENA,
			func = function()
				self:ToggleHGroups("dps", 1)
			end,
			checked = nibRealUI:GetGridLayoutSettings("dps", "hGroups", "normal"),
			width = Element.info.window.width,
			height = 20,
			x = 0,
			y = lY - 19,
		},
		{
			label = L["Horizontal Groups"].." - "..RAIDS,
			func = function()
				self:ToggleHGroups("dps", 2)
			end,
			checked = nibRealUI:GetGridLayoutSettings("dps", "hGroups", "raid"),
		},
		{
			label = L["Horizontal Groups"].." - "..BATTLEFIELDS,
			func = function()
				self:ToggleHGroups("dps", 3)
			end,
			checked = nibRealUI:GetGridLayoutSettings("dps", "hGroups", "bg"),
		},
		{
			label = L["Show Pet Frames"].." - "..SOLO.." / "..DUNGEONS.." / "..SCENARIOS.." / "..ARENA,
			func = function()
				self:TogglePetFrames("dps", 4)
			end,
			checked = nibRealUI:GetGridLayoutSettings("dps", "showPet"),
		},
		{
			label = L["Show While Solo"],
			func = function()
				self:ToggleShowSolo("dps", 5)
			end,
			checked = nibRealUI:GetGridLayoutSettings("dps", "showSolo"),
		},
	}
	self.dtHGroups = cbGUI:CreateOptionList(tabPanel2, "VERTICAL", options)

	-- Unit Width
	local sliders = {
		{
			label = "Unit Height",
			name = "GLDUnitHeight",
			width = 318,
			height = 20,
			x = 30,
			y = lY - 130,
			sliderWidth = 120,
			min = 20,
			max = 80,
			func = function(value)
				self:SetUnitHeight("dps", value)
			end,
			value = self:GetUnitHeight("dps"),
		},
		{
			label = "Unit Width",
			name = "GLDUnitWidth",
			min = 40,
			max = 110,
			func = function(value)
				self:SetUnitWidth("dps", value, 1)
			end,
			value = nibRealUI:GetGridLayoutSettings("dps", "width"),
		},
		{
			label = "40-man Unit Width",
			name = "GLD40MUnitWidth",
			min = 30,
			max = 90,
			func = function(value)
				self:SetUnitWidth("dps", value, 2)
			end,
			value = nibRealUI:GetGridLayoutSettings("dps", "sWidth"),
		}
	}
	self.dtUnitWidth = cbGUI:CreateSliderList(tabPanel2, "VERTICAL", sliders)


	---- Layout - Healing ----
	lY = 0
	cbGUI:CreateHeader(tabPanel3, L["Layout"].." » "..L["Healing"], lY)

	-- Horizontal Groups
	options = {
		{
			label = L["Horizontal Groups"].." - "..SOLO.." / "..DUNGEONS.." / "..SCENARIOS.." / "..ARENA,
			func = function()
				self:ToggleHGroups("healing", 1)
			end,
			checked = nibRealUI:GetGridLayoutSettings("healing", "hGroups", "normal"),
			width = Element.info.window.width,
			height = 20,
			x = 0,
			y = lY - 19,
		},
		{
			label = L["Horizontal Groups"].." - "..RAIDS,
			func = function()
				self:ToggleHGroups("healing", 2)
			end,
			checked = nibRealUI:GetGridLayoutSettings("healing", "hGroups", "raid"),
		},
		{
			label = L["Horizontal Groups"].." - "..BATTLEFIELDS,
			func = function()
				self:ToggleHGroups("healing", 3)
			end,
			checked = nibRealUI:GetGridLayoutSettings("healing", "hGroups", "bg"),
		},
		{
			label = L["Show Pet Frames"].." - "..SOLO.." / "..DUNGEONS.." / "..ARENA,
			func = function()
				self:TogglePetFrames("healing", 4)
			end,
			checked = nibRealUI:GetGridLayoutSettings("healing", "showPet"),
		},
		{
			label = L["Show While Solo"],
			func = function()
				self:ToggleShowSolo("healing", 5)
			end,
			checked = nibRealUI:GetGridLayoutSettings("healing", "showSolo"),
		},
	}
	self.hHGroups = cbGUI:CreateOptionList(tabPanel3, "VERTICAL", options)

	-- Unit Width
	sliders = {
		{
			label = "Unit Height",
			name = "GLHUnitHeight",
			width = 318,
			height = 20,
			x = 30,
			y = lY - 130,
			sliderWidth = 120,
			min = 20,
			max = 80,
			func = function(value)
				self:SetUnitHeight("healing", value)
			end,
			value = self:GetUnitHeight("healing"),
		},
		{
			label = "Unit Width",
			name = "GLHUnitWidth",
			width = 318,
			height = 20,
			x = 12,
			y = lY - 90,
			sliderWidth = 120,
			min = 40,
			max = 110,
			func = function(value)
				self:SetUnitWidth("healing", value, 1)
			end,
			value = nibRealUI:GetGridLayoutSettings("healing", "width"),
		},
		{
			label = "40-man Unit Width",
			name = "GLH40MUnitWidth",
			min = 30,
			max = 90,
			func = function(value)
				self:SetUnitWidth("healing", value, 2)
			end,
			value = nibRealUI:GetGridLayoutSettings("healing", "sWidth"),
		}
	}
	self.hUnitWidth = cbGUI:CreateSliderList(tabPanel3, "VERTICAL", sliders)
end

function ConfigBar_Grid:PLAYER_REGEN_DISABLED()
	self:Close()
end

function ConfigBar_Grid:ShowWindow()
	Element.window:Show()
end

function ConfigBar_Grid:Close()
	if not Element.window then return end

	if Element.window:IsVisible() then
		Element.active = false
		Element.window:Hide()
		if not Element.highlighted then
			Element.button.highlight:Hide()
		end
	end

	nibRealUI:ToggleGridTestMode(false)
end

function ConfigBar_Grid:Open()
	if Element.window and Element.window:IsVisible() then return end
	if not(Grid2 and Grid2Layout and Grid2Frame and Grid2DB) then return end
	if not Element.window then self:SetupWindow() end
	if not Element.window:IsVisible() then
		self:ShowWindow()
	end

	nibRealUI:ToggleGridTestMode(true)

	return true
end

function ConfigBar_Grid:Register()
	Element.info = {
		label = RAID_FRAMES_LABEL ,
		icon = [[Interface\AddOns\nibRealUI\Media\Config\Grid]],
		iconXoffset = -1,
		window = {
			width = 400,
			height = 547,
			xOfs = 0,
		},
		openFunc = function() return ConfigBar_Grid:Open() end,
		closeFunc = function() ConfigBar_Grid:Close() end,
		isDisabled = not(Grid2 and Grid2Layout and Grid2Frame and Grid2DB)
	}
	ConfigBar:RegisterElement(Element, 6)
end

----------

---- Chat Commands
function ConfigBar_Grid:Grid2ChatCommand()
	if not(Grid2 and Grid2Layout and Grid2Frame and Grid2DB) then return end
	if not(Element.window) or not Element.window:IsShown() and not(InCombatLockdown()) then
		ConfigBar:Toggle(true, true)
		ConfigBar_Element_OnMouseDown(Element.button)
	end
end

function ConfigBar_Grid:SetUpChatCommands()
	if not(Grid2 and Grid2Layout and Grid2Frame and Grid2DB) then return end

	if nibRealUI:DoesAddonMove("Bartender4") then
		Grid2:UnregisterChatCommand("grid2")

		self:RegisterChatCommand("grid", "Grid2ChatCommand")
		self:RegisterChatCommand("grid2", "Grid2ChatCommand")
	else
		self:UnregisterChatCommand("grid")
		self:UnregisterChatCommand("grid2")

		Grid2:RegisterChatCommand("grid2", "OnChatCommand")
	end
end

----------
function ConfigBar_Grid:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	self:Register()

	self:SetUpChatCommands()
end
