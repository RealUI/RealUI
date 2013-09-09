local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local ndb, ndbc

local _
local ConfigBar
local cbGUI
local HuDConfig
local HuDConfig_ActionBars = nibRealUI:GetModule("HuDConfig_ActionBars")
local HuDConfig_MSBT = nibRealUI:GetModule("HuDConfig_MSBT")

local MODNAME = "HuDConfig_Positions"
local HuDConfig_Positions = nibRealUI:NewModule(MODNAME)

local Element = {}

local UIElements
local SelectedUIElement

local PositionSliders = {}

local isRefreshing
function HuDConfig_Positions:Refresh()
	if isRefreshing then return end
	isRefreshing = true

	for k, tbl in pairs(PositionSliders) do
		local slider, key = tbl[1], tbl[2]
		slider.slider:SetValue(ndb.positions[nibRealUI.cLayout][key])
	end

	isRefreshing = false
end

function HuDConfig_Positions:ShowElementPanel(id)
	for k,panel in pairs(self.elementPanels) do
		panel:Hide()
	end
	self.elementPanels[id]:Show()
	Element.window:SetHeight(78 + 14 + self.elementPanels[id].height)
end

-- Position Val slider
function HuDConfig_Positions:PositionSliderUpdate(key, value)
	if isRefreshing then return end

	ndb.positions[nibRealUI.cLayout][key] = value
	nibRealUI:UpdatePositioners()
	-- nibRealUI:GetModule("FrameMover"):MoveAddons()

	if key == "HuDY" then
		if nibRealUI:DoesAddonMove("mikScrollingBattleText") then HuDConfig:RegisterForUpdate("MSBT") end
		if nibRealUI:DoesAddonMove("Bartender4") then HuDConfig:RegisterForUpdate("AB") end
	elseif key == "ActionBarsY" then
		if nibRealUI:DoesAddonMove("Bartender4") then HuDConfig:RegisterForUpdate("AB") end
	end

	nibRealUI:ToggleGridTestMode(false)
	nibRealUI:ToggleGridTestMode(true)
end

-- Choose UI Element dropdown
local function InitElementDropdown(dropdown, level)
	if not level or level == 1 then
		for idx, entry in ipairs(UIElements) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = entry
			info.value = entry
			info.func = function(frame, ...)
				UIDropDownMenu_SetSelectedValue(dropdown, entry)
				for k,v in pairs(UIElements) do
					if v == entry then
						SelectedUIElement = UIElements[k]
						HuDConfig_Positions:ShowElementPanel(SelectedUIElement)
					end
				end
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

-- Create Position slider
local function CreatePositionSlider(cnt, info)
	local sliders = {}
	for i = 1, cnt do
		local posID = info[i][1]
		local label = info[i][2]
		local min = info[i][3]
		local max = info[i][4]
		local step = info[i][5] or 1
		local offset = info[i][6] or 0

		local newSlider = {
			label = label,
			name = "HCP"..posID.."Slider",
			width = (i == 1) and Element.info.window.width - 72 or nil,
			height = (i == 1) and 20 or nil,
			x = (i == 1) and 36 or nil,
			y = (i == 1) and 8 or nil,
			sliderWidth = (i == 1) and Element.info.window.width - 140 or nil,
			min = min,
			max = max,
			step = step,
			func = function(value)
				HuDConfig_Positions:PositionSliderUpdate(posID, value + offset)
			end,
			value = ndb.positions[nibRealUI.cLayout][posID] - offset,
		}
		tinsert(sliders, newSlider)
	end
	return sliders
end

function HuDConfig_Positions:SetupWindow()
	local uiW, uiH = UIParent:GetSize()
	uiW = uiW / 2
	uiH = uiH / 2

	-- Window
	Element.window = cbGUI:CreateWindow(Element, "PositionsSettings", true)
	Element.window:Hide()

	-- Draggable icon
	local dragTex = Element.window:CreateTexture(nil, "ARTWORK")
		dragTex:SetPoint("BOTTOMRIGHT", -2, 2)
		dragTex:SetSize(16, 16)
		dragTex:SetTexture([[Interface\AddOns\nibRealUI\Media\Config\Draggable]])
		dragTex:SetVertexColor(0.9, 0.9, 0.9)

	-- Header
	cbGUI:CreateHeader(Element, L["Element Settings"], 0)

	-- Element Dropdown
	local dropdown = {
		name = "PositionSettingsElement",
		x = -2,
		y = -30,
		initFunc = InitElementDropdown,
		value = SelectedUIElement,
		text = SelectedUIElement,
	}
	self.ddElement = cbGUI:CreateDropdown(Element, dropdown)
	cbGUI:CreateString(Element, {text = "« "..L["Choose UI element to configure."], x = 226, y = -38})
	local str = cbGUI:CreateString(Element, {text = L["(use mouse-wheel for precision adjustment of sliders)"], x = 81, y = -72, color = "blue"})
	str:SetFont(nibRealUI.font.standard, 9)

	-- Element Panels
	self.elementPanels = {}
	for k, id in pairs(UIElements) do
		self.elementPanels[id] = CreateFrame("Frame", nil, Element.window)
			self.elementPanels[id]:SetPoint("TOPLEFT", Element.window, "TOPLEFT", 12, -78)
			self.elementPanels[id]:SetPoint("BOTTOMRIGHT", Element.window, "BOTTOMRIGHT", -12, 12)

		self.elementPanels[id]:Hide()
	end

	-- HuD Vertical
	local panel = self.elementPanels["HuD Vertical"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(1, {
		{"HuDY", L["Position"], -uiH, uiH, 1}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "HuDY"})
	panel.height = 20

	-- Unit Frames
	panel = self.elementPanels["Unit Frames"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(1, {
		{"UFHorizontal", L["Position"], 100, uiW*2, 2}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "UFHorizontal"})
	panel.height = 20

	-- Boss Frames
	panel = self.elementPanels["Boss Frames"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(2, {
		{"BossX", L["Horizontal"], -(uiW*2), 0, 1},
		{"BossY", L["Vertical"], -uiH, uiH, 1}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "BossX"})
	tinsert(PositionSliders, {panel.sliders[2], "BossY"})
	panel.height = 40

	-- Action Bars (Center)
	panel = self.elementPanels["Action Bars (Center)"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(1, {
		{"ActionBarsY", L["Vertical"], -uiH, uiH, 1, 0.5}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "ActionBarsY"})
	panel.height = 20

	-- Grid (Healing)
	panel = self.elementPanels["Grid (Healing)"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(2, {
		{"GridTopX", L["Horizontal"], -uiW, uiW, 1},
		{"GridTopY", L["Vertical"], -uiH + 100, uiH + 100, 1}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "GridTopX"})
	tinsert(PositionSliders, {panel.sliders[2], "GridTopY"})
	panel.height = 40

	-- Grid (DPS/Tank)
	panel = self.elementPanels["Grid (DPS/Tank)"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(2, {
		{"GridBottomX", L["Horizontal"], -uiW, uiW, 1},
		{"GridBottomY", L["Vertical"], 0, uiH*2, 1}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "GridBottomX"})
	tinsert(PositionSliders, {panel.sliders[2], "GridBottomY"})
	panel.height = 40

	-- Cast Bar (Player)
	panel = self.elementPanels["Cast Bar (Player)"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(2, {
		{"CastBarPlayerX", L["Horizontal"], -uiW, uiW, 1},
		{"CastBarPlayerY", L["Vertical"], -uiH + 150, uiH + 150, 1}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "CastBarPlayerX"})
	tinsert(PositionSliders, {panel.sliders[2], "CastBarPlayerY"})
	panel.height = 40

	-- Cast Bar (Target)
	panel = self.elementPanels["Cast Bar (Target)"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(2, {
		{"CastBarTargetX", L["Horizontal"], -uiW, uiW, 1},
		{"CastBarTargetY", L["Vertical"], -uiH + 150, uiH + 150, 1}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "CastBarTargetX"})
	tinsert(PositionSliders, {panel.sliders[2], "CastBarTargetY"})
	panel.height = 40

	-- Spell Alerts
	panel = self.elementPanels["Spell Alerts"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(1, {
		{"SpellAlertWidth", L["Width"], 20, uiW, 1}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "SpellAlertWidth"})
	panel.height = 20

	-- Aura Tracking (Player)
	panel = self.elementPanels["Aura Tracking (Player)"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(2, {
		{"CTAurasLeftX", L["Horizontal"], -uiW, uiW, 1},
		{"CTAurasLeftY", L["Vertical"], -uiH + 150, uiH + 150, 1}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "CTAurasLeftX"})
	tinsert(PositionSliders, {panel.sliders[2], "CTAurasLeftY"})
	panel.height = 40

	-- Aura Tracking (Target)
	panel = self.elementPanels["Aura Tracking (Target)"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(2, {
		{"CTAurasRightX", L["Horizontal"], -uiW, uiW, 1},
		{"CTAurasRightY", L["Vertical"], -uiH + 150, uiH + 150, 1}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "CTAurasRightX"})
	tinsert(PositionSliders, {panel.sliders[2], "CTAurasRightY"})
	panel.height = 40

	-- Point Tracking
	panel = self.elementPanels["Class Points"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(2, {
		{"CTPointsWidth", L["Width"], 50, uiW, 2},
		{"CTPointsHeight", L["Height"], 20, uiH, 2}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "CTPointsWidth"})
	tinsert(PositionSliders, {panel.sliders[2], "CTPointsHeight"})
	panel.height = 40

	-- Class Power
	panel = self.elementPanels["Class Resource"]
	panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(2, {
		{"ClassResourceX", L["Horizontal"], -uiW, uiW, 1},
		{"ClassResourceY", L["Vertical"], -uiH, uiH, 1}
	}))
	tinsert(PositionSliders, {panel.sliders[1], "ClassResourceX"})
	tinsert(PositionSliders, {panel.sliders[2], "ClassResourceY"})
	panel.height = 40

	-- Runes (Deathknight)
	if nibRealUI.class == "DEATHKNIGHT" then
		panel = self.elementPanels["Runes (Deathknight)"]
		panel.sliders = cbGUI:CreateSliderList(panel, "VERTICAL", CreatePositionSlider(2, {
			{"RunesX", L["Horizontal"], -uiW, uiW, 1},
			{"RunesY", L["Vertical"], -uiH, uiH, 1}
		}))
		tinsert(PositionSliders, {panel.sliders[1], "RunesX"})
		tinsert(PositionSliders, {panel.sliders[2], "RunesY"})
		panel.height = 40
	end


	self:ShowElementPanel("HuD Vertical")
end

function HuDConfig_Positions:ShowWindow()
	-- Show Window
	Element.window:Show()
end

function HuDConfig_Positions:Close()
	if not Element.window then return end
	if Element.window:IsVisible() then
		Element.window:Hide()
	end
end

function HuDConfig_Positions:Open()
	if Element.window and Element.window:IsVisible() then return end
	if not Element.window then self:SetupWindow() end
	if not Element.window:IsVisible() then
		self:ShowWindow()
	end

	return Element.window
end

----------
function HuDConfig_Positions:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	Element.info = {
		window = {
			width = 510,
			height = 150,
			xOfs = 0
		}
	}

	UIElements = {
		"HuD Vertical",
		"Unit Frames",
		"Boss Frames",
		"Action Bars (Center)",
		"Grid (Healing)",
		"Grid (DPS/Tank)",
		"Cast Bar (Player)",
		"Cast Bar (Target)",
		"Spell Alerts",
		"Aura Tracking (Player)",
		"Aura Tracking (Target)",
		"Class Points",
		"Class Resource",
	}
	if nibRealUI.class == "DEATHKNIGHT" then tinsert(UIElements, "Runes (Deathknight)") end
	SelectedUIElement = UIElements[1]

	ConfigBar = nibRealUI:GetModule("ConfigBar")
	cbGUI = nibRealUI:GetModule("ConfigBar_GUI")
	HuDConfig = nibRealUI:GetModule("HuDConfig")
end