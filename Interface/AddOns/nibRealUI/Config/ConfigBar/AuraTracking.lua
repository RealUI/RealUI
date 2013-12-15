local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local ndb, ndbc

local _
local ConfigBar = nibRealUI:GetModule("ConfigBar")
local cbGUI = nibRealUI:GetModule("ConfigBar_GUI")
local ScrollingTable = LibStub("ScrollingTable")

local MODNAME = "ConfigBar_AuraTracking"
local ConfigBar_AuraTracking = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local AuraTracking = nibRealUI:GetModule("AuraTracking", true)

local Element = {}

local TrackerTypes
local SelectedTrackerType

-- Choose Tracker Type dropdown
local function InitTypeDropdown(dropdown, level)
	if not level or level == 1 then
		for idx, entry in ipairs(TrackerTypes) do
			local info = UIDropDownMenu_CreateInfo()
			info.text = entry
			info.value = entry
			info.func = function(frame, ...)
				UIDropDownMenu_SetSelectedValue(dropdown, entry)
				for k,v in pairs(TrackerTypes) do
					if v == entry then
						SelectedTrackerType = TrackerTypes[k]
					end
				end
			end
			UIDropDownMenu_AddButton(info, level)
		end
	end
end

-- Defaults
function ConfigBar_AuraTracking:LoadDefaults()
	-- Confirmation dialog
	StaticPopupDialogs["PUDRUILOADDEFAULTS"] = {
		text = L["Are you sure you wish to reset Tracking information to defaults?"],
		button1 = "Yes",
		button2 = "No",
		OnAccept = function()
			AuraTracking:LoadDefaults()
			nibRealUI:ReloadUIDialog()
		end,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		notClosableByLogout = false,
	}
	StaticPopup_Show("PUDRUILOADDEFAULTS")
end

-- Disable/Enable Selected Tracker
function ConfigBar_AuraTracking:ToggleTrackerEnabled()
	local selTracker = self.TrackingTable:GetSelection()
	if not selTracker then
		print("No tracker selected.") 
		return
	end

	local info = AuraTracking:GetTrackingData(selTracker)

	if info.isDisabled then
		AuraTracking:EnableTracker(selTracker)
		self.buttons.toggleTracker:SetText(L["Disable Selected Tracker"])
	else
		AuraTracking:DisableTracker(selTracker)
		self.buttons.toggleTracker:SetText(L["Enable Selected Tracker"])
	end

	self:RefreshTrackingTable()
	self:UpdateTrackerConfig()

	print(format("|cffff0000You must reload the UI |r|cffffffff(/rl)|r |cffff0000for changes to take effect."))
end

-- Create New Tracker
function ConfigBar_AuraTracking:CreateTracker()
	local newTrackerIndex = AuraTracking:CreateNewTracker()
	self:RefreshTrackingTable()
	self.TrackingTable:SetSelection(newTrackerIndex)
end

-- Create New PopUp
function ConfigBar_AuraTracking:CreateNewPopUp()
	if not self.createNewPopUp then
		-- Window
		self.createNewPopUp = nibRealUI:CreateWindow("RealUIConfigWindowAuraTrackingCreateNew", 350, 160, true, true)
		local window = self.createNewPopUp
			window:SetFrameStrata("DIALOG")
			window:SetPoint("CENTER", UIParent, "CENTER")

		-- Header
		local header = nibRealUI:CreateFS(window, "CENTER", "small")
			header:SetFont(nibRealUI.font.standard, 10)
			header:SetText(L["New Tracker Type"])
			header:SetPoint("TOP", window, "TOP", 0, -9)

		-- Choose Type Dropdown
		local dropdown = {
			name = "AuraTrackingType",
			x = -14,
			y = -30,
			initFunc = InitTypeDropdown,
			value = SelectedTrackerType,
			text = SelectedTrackerType,
		}
		self.ddType = cbGUI:CreateDropdown(window, dropdown)

		-- Okay
		window.okay = nibRealUI:CreateTextButton(OKAY, window, 100, 24)
			window.okay:SetPoint("BOTTOM", window, "BOTTOM", -51, 5)
			window.okay:SetScript("OnClick", function()
				UIDropDownMenu_SetSelectedValue(dropdown, entry)
				ConfigBar_AuraTracking:CreateTracker()
				window:Hide()
			end)

		-- Cancel
		window.cancel = nibRealUI:CreateTextButton(CANCEL, window, 100, 24)
			window.cancel:SetPoint("BOTTOM", window, "BOTTOM", 51, 5)
			window.cancel:SetScript("OnClick", function() window:Hide() end)
		
		nibRealUI:CreateBGSection(window, window.okay, window.cancel)

	end
	self.createNewPopUp:Show()
	UIDropDownMenu_SetSelectedValue(self.ddType, 1)
end

-- Change Tracker setting
function ConfigBar_AuraTracking:ChangeTrackerSetting(key, value)
	local selTracker = self.TrackingTable:GetSelection()
	if not selTracker or not key then return end
	if AuraTracking:GetTrackingData(selTracker).isDisabled then return end

	if key == "isStatic" then
		local order = AuraTracking:GetTrackingData(selTracker).order
		if order and order > 0 then
			AuraTracking:ChangeTrackerSetting(selTracker, "order", 0)
		else
			AuraTracking:ChangeTrackerSetting(selTracker, "order", 1)
		end
	
	elseif key == "order" then
		local order = tonumber(value)
		AuraTracking:ChangeTrackerSetting(selTracker, "order", order)

	elseif key == "spell" then
		local spell = value
		if not(spell) or (spell and spell == "") then
			spell = "- Enter Spell Here -"
		elseif tonumber(spell) then
			spell = tonumber(spell)
		elseif string.find(spell, ",") then
			spell = { strsplit(",", spell) }
		end
		AuraTracking:ChangeTrackerSetting(selTracker, "spell", spell)

	elseif key == "minLevel" then
		local minLevel = (value > 0) and value or nil
		AuraTracking:ChangeTrackerSetting(selTracker, "minLevel", minLevel)

	elseif key == "ignoreSpec" then
		local ignoreSpec = AuraTracking:GetTrackingData(selTracker).ignoreSpec
		AuraTracking:ChangeTrackerSetting(selTracker, key, not ignoreSpec)

	elseif key == "specs" then
		if AuraTracking:GetTrackingData(selTracker).ignoreSpec then return end

		local defSpecTable = (nibRealUI.class == "DRUID") and {true, true, true, true} or {true, true, true}
		local specs = AuraTracking:GetTrackingData(selTracker).specs or defSpecTable
		specs[value] = not(specs[value])
		AuraTracking:ChangeTrackerSetting(selTracker, "specs", specs)

	elseif key == "forms" then
		local defFormTable = {false, false, false, false}
		local forms = AuraTracking:GetTrackingData(selTracker).forms or defFormTable
		forms[value] = not(forms[value])
		AuraTracking:ChangeTrackerSetting(selTracker, "forms", forms)

	elseif (key == "hideOOC") or (key == "hideStacks") or (key == "hideTime") then
		local val = AuraTracking:GetTrackingData(selTracker)[key]
		if val then
			AuraTracking:ChangeTrackerSetting(selTracker, key, nil)
		else
			AuraTracking:ChangeTrackerSetting(selTracker, key, true)
		end

	else
		AuraTracking:ChangeTrackerSetting(selTracker, key, value)

	end


	self:RefreshTrackingTable()
	self.TrackingTable:SetSelection(selTracker)
end

-- Update Tracker config display
function ConfigBar_AuraTracking:UpdateTrackerConfig()
	if self.currentTab ~= 1 then return end

	local tableHeight = 247
	local staticHeight = 86
	local auraHeight = 314

	if nibRealUI.class == "DRUID" then auraHeight = auraHeight + 20 end

	local oP = self.indicatorOptionsPanel

	-- Get Selected Tracker info
	local selTracker = self.TrackingTable:GetSelection()

	local info = selTracker and AuraTracking:GetTrackingData(selTracker) or nil

	-- No tracker selected or disabled tracker, then hide
	if not(selTracker) or (info and info.isDisabled) then
		oP:Hide()
		Element.window:SetHeight(tableHeight)
		self.trackerSettings.header:Hide()

		if info then
			self.buttons.toggleTracker:SetText(L["Enable Selected Tracker"])
		end

		return

	elseif AuraTracking:GetTrackingData(selTracker).isDisabled then
		-- Disable/Enable button text
		if info.isDisabled then
			self.buttons.toggleTracker:SetText(L["Enable Selected Tracker"])
		else
			self.buttons.toggleTracker:SetText(L["Disable Selected Tracker"])
		end

	else
		oP:Show()
		self.trackerSettings.header:Show()
		self.buttons.toggleTracker:SetText(L["Disable Selected Tracker"])
	end

	
	-- Get tracker info
	-- Type
	local indType = info.type or "Aura"

	-- UIDropDownMenu_SetSelectedValue(self.ddType, indType)

	-- Is Static
	local isStatic = true
	if not info.order then
		isStatic = false
	elseif info.order < 1 then
		isStatic = false
	end
	self.trackerSettings.isStatic.check.highlight:SetAlpha(isStatic and 1 or 0)

	-- Order slider
	if isStatic then
		self.trackerSettings.order:Show()
		self.trackerSettings.order.slider:SetValue(info.order)
	else
		self.trackerSettings.order:Hide()
	end

	-- Aura options
	if (indType == "Aura") then
		oP.aura:Show()
		Element.window:SetHeight(tableHeight + auraHeight)

		-- Spell
		local spell = info.spell or ""
		if type(info.spell) == "table" then
			local spellString = ""
			for i = 1, #spell do
				if (i > 1) and (spellString ~= "") then
					spellString = spellString .. ","
				end
				spellString = spellString .. spell[i]
			end
			spell = spellString
		end
		self.trackerSettings.spell:SetText(tostring(spell))

		-- Aura Type
		local auraType = info.auraType or "buff"
		self.trackerSettings.auraType[1].check.highlight:SetAlpha(auraType == "buff" and 1 or 0)
		self.trackerSettings.auraType[2].check.highlight:SetAlpha(auraType == "buff" and 0 or 1)

		-- Unit
		local unitCheckIndex = {["player"] = 1, ["target"] = 2, ["focus"] = 3, ["pet"] = 4, ["trinket"] = 5}
		local unit = info.unit or (auraType == "debuff") and "target" or "player"
		for i = 1, 5 do
			self.trackerSettings.unit[i].check.highlight:SetAlpha(0)
		end
		self.trackerSettings.unit[unitCheckIndex[unit]].check.highlight:SetAlpha(1)

		-- Min Level
		local minLevel = info.minLevel or 0
		self.trackerSettings.minLevel.slider:SetValue(minLevel)

		-- Ignore Spec
		local ignoreSpec = AuraTracking:GetTrackingData(selTracker).ignoreSpec
		self.trackerSettings.ignoreSpec.check.highlight:SetAlpha(ignoreSpec and 1 or 0)

		-- Specs
		local defSpecTable = (nibRealUI.class == "DRUID") and {true, true, true, true} or {true, true, true}
		local specs = info.specs or defSpecTable
		for i = 1, self.numSpecs do
			if info.ignoreSpec then
				self.trackerSettings.specs[i].check.highlight:SetAlpha(1)
				self.trackerSettings.specs[i].check.highlight:SetTexture(unpack(nibRealUI.media.colors.blue))
			else
				self.trackerSettings.specs[i].check.highlight:SetAlpha(specs[i] and 1 or 0)
				self.trackerSettings.specs[i].check.highlight:SetTexture(unpack(nibRealUI.media.colors.orange))
			end
		end

		-- Forms
		if nibRealUI.class == "DRUID" then
			local forms = info.forms or {true, true, true, true}
			for i = 1, 4 do
				self.trackerSettings.forms[i].check.highlight:SetAlpha(forms[i] and 1 or 0)
			end
		end

		-- HideOOC
		local hideOOC = info.hideOOC ~= nil
		self.trackerSettings.hideOOC.check.highlight:SetAlpha(hideOOC and 1 or 0)

		-- HideStacks
		local hideStacks = info.hideStacks ~= nil
		self.trackerSettings.hideStacks.check.highlight:SetAlpha(hideStacks and 1 or 0)

		-- Hide Time
		local hideTime = info.hideTime ~= nil
		self.trackerSettings.hideTime.check.highlight:SetAlpha(hideTime and 1 or 0)

	else
		oP.aura:Hide()
		Element.window:SetHeight(tableHeight + staticHeight)
	end
end

-- Tracking Table Data
function ConfigBar_AuraTracking:RefreshTrackingTable()
	self.TrackingTable:SetData(self:GetTrackingDataSet())
	self.TrackingTable:SortData()
end

function ConfigBar_AuraTracking:GetTrackingDataSet()
	local data = {}
	local trackingData = AuraTracking:GetTrackingData()
	for k, info in ipairs(trackingData) do
		local indOrder
		if not info.order then
			indOrder = "~"
		elseif info.order < 1 then
			indOrder = "~"
		else
			indOrder = info.order
		end
		local indType = info.type or "Aura"

		local indSpell = indType == "Aura" and info.spell or ""
		local indSpellName = indSpell
		if type(indSpell) == "table" then
			indSpellName = GetSpellInfo(indSpell[1])
		elseif type(indSpell) == "number" then
			indSpellName = GetSpellInfo(indSpell)
		end

		local indTypeString = indType
		if indType == "Aura" then
			local indAuraType = info.auraType or "buff"
			indTypeString = string.format("%s |cff%s(%s)|r", indType, indAuraType == "buff" and "30ff30" or "ff3030", indAuraType)
		end

		-- Specs / Forms
		local indSpecString, indFormString
		if indType == "Aura" then
			if nibRealUI.class ~= "DRUID" then
				-- Specs
				local ignoreSpec = info.ignoreSpec
				local indSpecs = info.specs
				
				indSpecString = ""
				if ignoreSpec or not(indSpecs) then
					indSpecString = "All"
				elseif indSpecs then
					local allSpecs = true
					for spec = 1, self.numSpecs do
						if indSpecs[spec] then
							if (spec > 1) and (indSpecString ~= "") then
								indSpecString = indSpecString .. ", "
							end
							indSpecString = indSpecString .. self.specNames[spec]
						else
							allSpecs = false
						end
					end
					if allSpecs then indSpecString = "All" end
				end
			else
				-- Forms
				local FormNames = {"Cat", "Bear", "Moonkin", "Human"}
				local indForms = info.forms
				indFormString = ""
				if indForms and not(indForms[1] and indForms[2] and indForms[3] and indForms[4]) then
					for form = 1, 4 do
						if indForms[form] then
							if (form > 1) and (indFormString ~= "") then
								indFormString = indFormString .. ", "
							end
							indFormString = indFormString .. FormNames[form]
						end
					end
				else
					indFormString = "All"
				end
			end
		end

		local rowColor = info.isDisabled and {r = 0.5, g = 0.5, b = 0.5} or {r = 1, g = 1, b = 1}

		-- Row Data
		local row = {
			cols = {
				{
					value = indOrder,
					color = rowColor
				},
				{
					value = indTypeString,
					color = rowColor
				},
				{
					value = indSpellName,
					color = rowColor
				},
				{
					value = indSpecString or indFormString or "",
					color = rowColor
				},
			},

		}
		tinsert(data, row)
	end
	return data
end

function ConfigBar_AuraTracking:ChangeAdvancedSetting(key1, key2, value)
	local atDB = AuraTracking:GetSettings()
	if key1 and key2 and (value ~= nil) then
		AuraTracking:SetSetting(key1, key2, value)
	else
		AuraTracking:SetSetting(key1, key2, not(atDB[key1][key2]))
	end
	self:UpdateAdvancedConfig()
end

-- Advanced Settings update
function ConfigBar_AuraTracking:UpdateAdvancedConfig()
	if self.currentTab ~= 2 then return end

	Element.window:SetHeight(214)

	local atDB = AuraTracking:GetSettings()

	self.advancedSettingsSliders[1].slider:SetValue(atDB.style.slotSize)
	self.advancedSettingsSliders[2].slider:SetValue(atDB.style.padding)
	self.advancedSettingsSliders[3].slider:SetValue(atDB.indicators.fadeOpacity * 100)

	self.advancedSettingsChecks[1].check.highlight:SetAlpha(atDB.visibility.showCombat and 1 or 0)
	self.advancedSettingsChecks[2].check.highlight:SetAlpha(atDB.visibility.showHostile and 1 or 0)
	self.advancedSettingsChecks[3].check.highlight:SetAlpha(atDB.visibility.showPvE and 1 or 0)
	self.advancedSettingsChecks[4].check.highlight:SetAlpha(atDB.visibility.showPvP and 1 or 0)
	self.advancedSettingsChecks[5].check.highlight:SetAlpha(atDB.indicators.useCustomCD and 1 or 0)
end

-- Tab Change
function ConfigBar_AuraTracking:ChangeTab(tabID, isInit)
	if isInit then
		self.currentTab = 2
	end
	if self.currentTab == tabID then
		return
	end

	self.tabPanels[self.currentTab]:Hide()
	self.tabs[self.currentTab].icon:SetVertexColor(0.5, 0.5, 0.5)

	self.tabPanels[tabID]:Show()
	self.tabs[tabID].icon:SetVertexColor(1, 1, 1)
	
	self.currentTab = tabID

	if isInit then return end

	if tabID == 1 then
		self:UpdateTrackerConfig()
	else
		self:UpdateAdvancedConfig()
	end
end

-- Window Creation
function ConfigBar_AuraTracking:SetupWindow()
	-- Window
	Element.window = cbGUI:CreateWindow(Element, "Auras")
	Element.window:Hide()
	self.trackerSettings = {}

	-- Tabs
	local tabs = {
		{
			texture = [[Interface\Glues\CharacterCreate\UI-CharacterCreate-Classes]],
			texCoord = CLASS_ICON_TCOORDS[strupper(nibRealUI.class)],
			func = function() self:ChangeTab(1) end,
		},
		{
			texture = [[Interface\AddOns\nibRealUI\Media\Config\Advanced]],
			texPosition = {x = 0, y = -4},
			func = function() self:ChangeTab(2) end,
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

	self:ChangeTab(1, true)

	--------------------
	---- Indicators ----
	--------------------
	-- Header
	cbGUI:CreateHeader(tabPanel1, AURAS.." » "..UnitClass("player") , 0)

	-- Tracking table
	local highlightColor = {r = nibRealUI.classColor[1], g = nibRealUI.classColor[2], b = nibRealUI.classColor[3], a = 0.2}
	local maxWidth = Element.info.window.width - 24
	-- {
	--     ["name"] = "Test 1",
	--     ["width"] = 50,
	--     ["align"] = "RIGHT",
	--     ["color"] = { 
	--         ["r"] = 0.5, 
	--         ["g"] = 0.5, 
	--         ["b"] = 1.0, 
	--         ["a"] = 1.0 
	--     },
	--     ["colorargs"] = nil,
	--     ["bgcolor"] = {
	--         ["r"] = 1.0, 
	--         ["g"] = 0.0, 
	--         ["b"] = 0.0, 
	--         ["a"] = 1.0 
	--     }, -- red backgrounds, eww!
	--     ["defaultsort"] = "dsc",
	--     ["sortnext"]= 4,
	--     ["comparesort"] = function (cella, cellb, column)
	--         return cella.value < cellb.value;
	--     end,
	--     ["DoCellUpdate"] = nil,
	-- }
	local cols = {
		{
			name = "Pos.",
			width = 36,
			sort = "dsc",
			sortnext = 2,
		},
		{
			name = "Type",
			width = 100,
			sortnext = 3,
			defaultsort = "dsc",
		},
		{
			name = "Spell",
			width = 160,
			defaultsort = "dsc",
		},
		{
			name = "Specs",
			width = maxWidth - 300 - 33,
		},
	}
	local TrackingTable = ScrollingTable:CreateST(cols, 10, 15, highlightColor, tabPanel1)
	self.TrackingTable = TrackingTable
		TrackingTable.frame:ClearAllPoints()
		TrackingTable.frame:SetPoint("TOPLEFT", tabPanel1, "TOPLEFT", 14, -44)
		TrackingTable.frame:SetBackdrop(nil)

		-- Skin Table
		nibRealUI:CreateBD(TrackingTable.frame)
		nibRealUI:CreateBGSection(tabPanel1, TrackingTable.frame, TrackingTable.frame)
		_G[TrackingTable.frame:GetName().."ScrollFrame"]:SetPoint("TOPLEFT", TrackingTable.frame, "TOPLEFT", 1, -1);
		_G[TrackingTable.frame:GetName().."ScrollFrame"]:SetPoint("BOTTOMRIGHT", TrackingTable.frame, "BOTTOMRIGHT", -21.5, 1);
		_G[TrackingTable.frame:GetName().."ScrollTrough"]:SetWidth(15)
		_G[TrackingTable.frame:GetName().."ScrollTrough"]:SetPoint("TOPRIGHT", TrackingTable.frame, "TOPRIGHT", -1, -1);
		_G[TrackingTable.frame:GetName().."ScrollTrough"]:SetPoint("BOTTOMRIGHT", TrackingTable.frame, "BOTTOMRIGHT", -1, 1);
		_G[TrackingTable.frame:GetName().."ScrollTroughBorder"].background:SetTexture(0,0,0,0)

	local data = self:GetTrackingDataSet()
		TrackingTable:EnableSelection(true)
		TrackingTable:SetData(data)
		TrackingTable:SortData()

	hooksecurefunc(TrackingTable, "SetSelection", function()
		ConfigBar_AuraTracking:UpdateTrackerConfig()
	end)


	-- Create New
	self.buttons = {}
	local button = {
		label = L["Create New Tracker"],
		width = 170,
		height = 22,
		x = 14,
		y = -210,
		func = function() self:CreateTracker() end,
	}
	self.buttons.createNewTracker = cbGUI:CreateButton(tabPanel1, button)

	-- Disable/Enable
	button = {
		label = L["Disable Selected Tracker"],
		width = 170,
		height = 22,
		x = 185,
		y = -210,
		func = function() self:ToggleTrackerEnabled() end,
	}
	self.buttons.toggleTracker = cbGUI:CreateButton(tabPanel1, button)

	-- Load Defaults
	button = {
		label = L["Load Defaults"],
		width = 170,
		height = 22,
		x = 356,
		y = -210,
		func = function() self:LoadDefaults() end,
	}
	self.buttons.loadDefaults = cbGUI:CreateButton(tabPanel1, button)

	nibRealUI:CreateBGSection(tabPanel1, self.buttons.createNewTracker, self.buttons.loadDefaults)


	----
	-- Tracker options panel
	----
	-- Header
	self.trackerSettings.header = cbGUI:CreateHeader(tabPanel1, L["Tracker Options"], -248)

	self.indicatorOptionsPanel = CreateFrame("Frame", nil, tabPanel1)	
	local oP = self.indicatorOptionsPanel
		oP:SetPoint("TOPLEFT", tabPanel1, "TOPLEFT", 12, -270)
		oP:SetPoint("BOTTOMRIGHT", tabPanel1, "BOTTOMRIGHT", -12, 12)

	-- Is Static
	check = {
		{
			label = L["Static"],
			desc = L["Static Trackers remain visible and in the same location."],
			func = function()
				self:ChangeTrackerSetting("isStatic")
			end,
			width = (Element.info.window.width - 24),
			height = 20,
			x = 0,
			y = 0
		},
	}
	self.trackerSettings.isStatic = cbGUI:CreateOptionList(oP, "VERTICAL", check)[1]

	-- Order
	local slider = {
		{
			label = L["Position"],
			name = "AuraTrackingOrder",
			width = 180,
			height = 20,
			x = 18,
			y = -20,
			sliderWidth = 80,
			min = 1,
			max = 12,
			func = function(value)
				self:ChangeTrackerSetting("order", value)
			end,
			value = 1,
		}
	}
	self.trackerSettings.order = cbGUI:CreateSliderList(oP, "VERTICAL", slider)[1]

	----
	-- Aura panel
	----
	oP.aura = CreateFrame("Frame", nil, oP)	
	local aP = oP.aura
		aP:SetPoint("TOPLEFT", oP, "TOPLEFT", 0, -46)
		aP:SetPoint("BOTTOMRIGHT", oP, "BOTTOMRIGHT", 0, 0)

	-- Spell
	local input = {
		label = L["Spell Name or ID"],
		name = "AuraTrackingSpell",
		tip = L["Note: Spell Name or ID must match the spell you wish to track exactly. Capitalization and spaces matter."],
		func = function(value)
			self:ChangeTrackerSetting("spell", value)
		end,
		inputWidth = 200,
		width = Element.info.window.width - 24,
		x = 1,
		y = -16
	}
	self.trackerSettings.spell = cbGUI:CreateInput(aP, input)

	-- Is Buff
	local check = {
		{
			label = L["Buff"],
			func = function()
				self:ChangeTrackerSetting("auraType", "buff")
			end,
			width = (Element.info.window.width - 24) / 5,
			height = 20,
			x = 0,
			y = -34
		},
		{
			label = L["Debuff"],
			func = function()
				self:ChangeTrackerSetting("auraType", "debuff")
			end,
		},
	}
	self.trackerSettings.auraType = cbGUI:CreateOptionList(aP, "HORIZONTAL", check)

	-- Unit
	check = {
		{
			label = PLAYER,
			func = function()
				self:ChangeTrackerSetting("unit", "player")
			end,
			width = (Element.info.window.width - 24) / 5,
			height = 20,
			x = 0,
			y = -54
		},
		{
			label = TARGET,
			func = function()
				self:ChangeTrackerSetting("unit", "target")
			end,
		},
		{
			label = FOCUS,
			func = function()
				self:ChangeTrackerSetting("unit", "focus")
			end,
		},
		{
			label = PET,
			func = function()
				self:ChangeTrackerSetting("unit", "pet")
			end,
		},
		{
			label = ENCOUNTER_JOURNAL_ITEM,
			func = function()
				self:ChangeTrackerSetting("unit", "trinket")
			end,
		},
	}
	self.trackerSettings.unit = cbGUI:CreateOptionList(aP, "HORIZONTAL", check)

	-- Min Level
	slider = {
		{
			label = L["Min Level (0 = ignore)"],
			name = "AuraTrackingMinLevel",
			width = 240,
			height = 20,
			x = 50,
			y = -86,
			sliderWidth = 90,
			min = 0,
			max = 90,
			func = function(value)
				self:ChangeTrackerSetting("minLevel", value)
			end,
			value = 0,
		}
	}
	self.trackerSettings.minLevel = cbGUI:CreateSliderList(aP, "VERTICAL", slider)[1]

	-- Ignore Spec
	check = {
		{
			label = L["Ignore Spec"],
			desc = L["Show tracker regardless of current specialization"],
			descGap = 120,
			func = function()
				self:ChangeTrackerSetting("ignoreSpec")
			end,
			width = (Element.info.window.width - 24),
			height = 20,
			x = 0,
			y = -112
		},
	}
	self.trackerSettings.ignoreSpec = cbGUI:CreateOptionList(aP, "VERTICAL", check)[1]

	-- Specs
	check = {
		{
			label = self.specNames[1],
			func = function()
				self:ChangeTrackerSetting("specs", 1)
			end,
			width = (Element.info.window.width - 24) / 4,
			height = 20,
			x = 0,
			y = -132
		},
		{
			label = self.specNames[2],
			func = function()
				self:ChangeTrackerSetting("specs", 2)
			end,
		},
		{
			label = self.specNames[3],
			func = function()
				self:ChangeTrackerSetting("specs", 3)
			end,
		},
	}
	if self.numSpecs == 4 then
		local fourthSpec = {
			label = self.specNames[4],
			func = function()
				self:ChangeTrackerSetting("specs", 4)
			end,
		}
		tinsert(check, fourthSpec)
	end
	self.trackerSettings.specs = cbGUI:CreateOptionList(aP, "HORIZONTAL", check)

	-- Forms
	local nextY = -152
	if nibRealUI.class == "DRUID" then
		check = {
			{
				label = L["Cat"],
				func = function()
					self:ChangeTrackerSetting("forms", 1)
				end,
				width = (Element.info.window.width - 24) / 4,
				height = 20,
				x = 0,
				y = nextY
			},
			{
				label = L["Bear"],
				func = function()
					self:ChangeTrackerSetting("forms", 2)
				end,
			},
			{
				label = L["Moonkin"],
				func = function()
					self:ChangeTrackerSetting("forms", 3)
				end,
			},
			{
				label = L["Human"],
				func = function()
					self:ChangeTrackerSetting("forms", 4)
				end,
			},
		}
		self.trackerSettings.forms = cbGUI:CreateOptionList(aP, "HORIZONTAL", check)

		nextY = -172
	end

	-- Hide OOC
	check = {
		{
			label = L["Hide Out-Of-Combat"],
			desc = L["Force this Tracker to hide OOC, even if it's active."],
			descGap = 170,
			func = function()
				self:ChangeTrackerSetting("hideOOC")
			end,
			width = (Element.info.window.width - 24),
			height = 20,
			x = 0,
			y = nextY - 12,
		},
	}
	self.trackerSettings.hideOOC = cbGUI:CreateOptionList(aP, "VERTICAL", check)[1]

	-- Hide Stacks
	check = {
		{
			label = L["Hide Stack Count"],
			desc = L["Don't show Buff/Debuff stack count on this tracker."],
			descGap = 170,
			func = function()
				self:ChangeTrackerSetting("hideStacks")
			end,
			width = (Element.info.window.width - 24),
			height = 20,
			x = 0,
			y = nextY - 32,
		},
	}
	self.trackerSettings.hideStacks = cbGUI:CreateOptionList(aP, "VERTICAL", check)[1]

	-- Hide Time
	check = {
		{
			label = "Hide Time",
			desc = "Don't show Buff/Debuff time remaining on this tracker.",
			descGap = 170,
			func = function()
				self:ChangeTrackerSetting("hideTime")
			end,
			width = (Element.info.window.width - 24),
			height = 20,
			x = 0,
			y = nextY - 52,
		},
	}
	self.trackerSettings.hideTime = cbGUI:CreateOptionList(aP, "VERTICAL", check)[1]


	---------------------------
	---- Advanced Settings ----
	---------------------------
	self.advancedSettings = {}

	-- Header
	cbGUI:CreateHeader(tabPanel2, ADVANCED_LABEL.." "..CHAT_CONFIGURATION, 0)

	slider = {
		{
			label = L["Indicator size"],
			name = "AuraTrackingIndicatorSize",
			width = 300,
			height = 20,
			x = 56,
			y = -18,
			step = 1,
			sliderWidth = 90,
			min = 24,
			max = 64,
			func = function(value)
				self:ChangeAdvancedSetting("style", "slotSize", value)
			end,
			value = 0,
		},
		{
			label = L["Indicator padding"],
			name = "AuraTrackingIndicatorPadding",
			step = 1,
			min = 0,
			max = 32,
			func = function(value)
				self:ChangeAdvancedSetting("style", "padding", value)
			end,
			value = 0,
		},
		{
			label = L["Inactive indicator opacity"],
			name = "AuraTrackingInactiveOpacity",
			step = 5,
			min = 0,
			max = 100,
			func = function(value)
				self:ChangeAdvancedSetting("indicators", "fadeOpacity", value / 100)
			end,
			value = 0,
		},
	}
	self.advancedSettingsSliders = cbGUI:CreateSliderList(tabPanel2, "VERTICAL", slider)

	nextY = -90

	check = {
		{
			label = L["Show in combat"],
			desc = L["Show Indicators when you are in combat"],
			descGap = 150,
			func = function()
				self:ChangeAdvancedSetting("visibility", "showCombat")
			end,
			width = Element.info.window.width,
			height = 20,
			x = 0,
			y = nextY,
		},
		{
			label = L["Show w/ hostile"],
			desc = L["Show Indicators when you have an attackable target"],
			func = function()
				self:ChangeAdvancedSetting("visibility", "showHostile")
			end,
		},
		{
			label = L["Show in PvE"],
			desc = L["Show Indicators when you are in a PvE instance"],
			func = function()
				self:ChangeAdvancedSetting("visibility", "showPvE")
			end,
		},
		{
			label = L["Show in PvP"],
			desc = L["Show Indicators when you are in a PvP instance"],
			func = function()
				self:ChangeAdvancedSetting("visibility", "showPvP")
			end,
		},
		{
			label = L["Vertical Cooldown"],
			desc = L["Use vertical cooldown indicator instead of spiral"],
			func = function()
				self:ChangeAdvancedSetting("indicators", "useCustomCD")
			end,
		},
	}
	self.advancedSettingsChecks = cbGUI:CreateOptionList(tabPanel2, "VERTICAL", check)


	self:UpdateTrackerConfig()
end

function ConfigBar_AuraTracking:UI_SCALE_CHANGED()
	self:Close()
end

function ConfigBar_AuraTracking:ShowWindow()
	Element.window:Show()

	AuraTracking:ToggleConfigMode(true)
end

function ConfigBar_AuraTracking:Close()
	if not Element.window then return end

	if Element.window:IsVisible() then
		Element.active = false
		Element.window:Hide()
		if not Element.highlighted then
			Element.button.highlight:Hide()
		end
	end

	AuraTracking:ToggleConfigMode(false)
end

function ConfigBar_AuraTracking:Open()
	if Element.window and Element.window:IsVisible() then return end
	if not(nibRealUI:GetModuleEnabled("AuraTracking")) then return end

	-- Tracker types
	TrackerTypes = AuraTracking:GetTrackerTypes()
	SelectedTrackerType = TrackerTypes[1]

	-- Spec info
	self.specNames = {}
	self.numSpecs = GetNumSpecializations()
	for i = 1, self.numSpecs do
		local _, name = GetSpecializationInfo(i)
		self.specNames[i] = name
	end

	if not Element.window then self:SetupWindow() end
	if not Element.window:IsVisible() then
		self:ShowWindow()
	end

	return true
end

function ConfigBar_AuraTracking:Register()
	Element.info = {
		label = AURAS,
		icon = [[Interface\AddOns\nibRealUI\Media\Config\Auras]],
		window = {
			width = 540,
			height = 560,
			xOfs = 0,
		},
		openFunc = function() return ConfigBar_AuraTracking:Open() end,
		closeFunc = function() ConfigBar_AuraTracking:Close() end,
		-- isDisabled = function() return not(nibRealUI:GetModuleEnabled("AuraTracking")) end,
	}
	ConfigBar:RegisterElement(Element, 7)
end

----------
function ConfigBar_AuraTracking:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	self:Register()

	-- self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function ConfigBar_AuraTracking:PLAYER_ENTERING_WORLD()
	if not InCombatLockdown() then
		ConfigBar:Toggle(true, true)
		ConfigBar_Element_OnMouseDown(Element.button)
	end
end