local addonName, addon = ...
if not addon.healthCheck then return end
local L = addon.L

local wow_ver = select(4, GetBuildInfo())
local wow_500 = wow_ver >= 50000
local UIPanelButtonTemplate = wow_500 and "UIPanelButtonTemplate" or "UIPanelButtonTemplate2"

local frame = CreateFrame("Frame", nil, InterfaceOptionsFramePanelContainer)
frame.name = addonName
frame:Hide()

-- Credits to Ace3, Tekkub, cladhaire and Tuller for some of the widget stuff.

local function newCheckbox(label, description, onClick)
	local check = CreateFrame("CheckButton", "BugSackCheck" .. label, frame, "InterfaceOptionsCheckButtonTemplate")
	check:SetScript("OnClick", function(self)
		PlaySound(self:GetChecked() and "igMainMenuOptionCheckBoxOn" or "igMainMenuOptionCheckBoxOff")
		onClick(self, self:GetChecked() and true or false)
	end)
	check.label = _G[check:GetName() .. "Text"]
	check.label:SetText(label)
	check.tooltipText = label
	check.tooltipRequirement = description
	return check
end
--[[
local function colorCallback(self, r, g, b, a, isAlpha)
	if not ColorPickerFrame:IsVisible() and isAlpha then
		print(tostringall(r, g, b, a, isAlpha))
	end
end

local function ColorSwatch_OnClick(frame)
	HideUIPanel(ColorPickerFrame)
	ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")

	ColorPickerFrame.func = function()
		local r, g, b = ColorPickerFrame:GetColorRGB()
		colorCallback(self, r, g, b)
	end

	ColorPickerFrame.hasOpacity = false

	local r, g, b, a = self.r, self.g, self.b, self.a
	ColorPickerFrame:SetColorRGB(r, g, b)

	ColorPickerFrame.cancelFunc = function()
		colorCallback(self, r, g, b)
	end

	ShowUIPanel(ColorPickerFrame)
end]]

--[[
local function newColorbox(label, onColorChanged)
	local color = CreateFrame("Button", nil, frame)

	color:EnableMouse(true)
	color:SetScript("OnClick", ColorSwatch_OnClick)

	local colorSwatch = color:CreateTexture(nil, "OVERLAY")
	colorSwatch:SetWidth(19)
	colorSwatch:SetHeight(19)
	colorSwatch:SetTexture("Interface\\ChatFrame\\ChatFrameColorSwatch")
	colorSwatch:SetPoint("LEFT")

	local texture = color:CreateTexture(nil, "BACKGROUND")
	texture:SetWidth(16)
	texture:SetHeight(16)
	texture:SetTexture(1, 1, 1)
	texture:SetPoint("CENTER", colorSwatch)

	local checkers = color:CreateTexture(nil, "BACKGROUND")
	checkers:SetWidth(14)
	checkers:SetHeight(14)
	checkers:SetTexture("Tileset\\Generic\\Checkers")
	checkers:SetTexCoord(.25, 0, 0.5, .25)
	checkers:SetDesaturated(true)
	checkers:SetVertexColor(1, 1, 1, 0.75)
	checkers:SetPoint("CENTER", colorSwatch)

	local text = color:CreateFontString(nil,"OVERLAY","GameFontHighlight")
	text:SetHeight(24)
	text:SetJustifyH("LEFT")
	text:SetTextColor(1, 1, 1)
	text:SetPoint("LEFT", colorSwatch, "RIGHT", 2, 0)
	text:SetPoint("RIGHT")
	text:SetText(label)

	local highlight = color:CreateTexture(nil, "HIGHLIGHT")
	highlight:SetTexture("Interface\\QuestFrame\\UI-QuestTitleHighlight")
	highlight:SetBlendMode("ADD")
	highlight:SetAllPoints(color)

	color:SetWidth(200)
	color:SetHeight(24)
	color:Show()
	return color
end
]]
frame:SetScript("OnShow", function(frame)
	local title = frame:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
	title:SetPoint("TOPLEFT", 16, -16)
	title:SetText(addonName)

	local subTitleWrapper = CreateFrame("Frame", nil, frame)
	subTitleWrapper:SetPoint("TOPLEFT", title, "BOTTOMLEFT", 0, -8)
	subTitleWrapper:SetPoint("RIGHT", -16, 0)
	local subtitle = subTitleWrapper:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	subtitle:SetPoint("TOPLEFT", subTitleWrapper)
	subtitle:SetWidth(subTitleWrapper:GetRight() - subTitleWrapper:GetLeft())
	subtitle:SetJustifyH("LEFT")
	subtitle:SetNonSpaceWrap(false)
	subtitle:SetJustifyV("TOP")
	subtitle:SetText("BugSack is a sack to stuff all your bugs in, and NOTHING ELSE! Don't think I don't know what you're up to, little schoolboy. Daddy was a little schoolboy, too.")
	subTitleWrapper:SetHeight(subtitle:GetHeight())

	local autoPopup = newCheckbox(
		L["Auto popup"],
		L.autoDesc,
		function(self, value) addon.db.auto = value end)
	autoPopup:SetChecked(addon.db.auto)
	autoPopup:SetPoint("TOPLEFT", subTitleWrapper, "BOTTOMLEFT", -2, -16)

	local chatFrame = newCheckbox(
		L["Chatframe output"],
		L.chatFrameDesc,
		function(self, value) addon.db.chatframe = value end)
	chatFrame:SetChecked(addon.db.chatframe)
	chatFrame:SetPoint("TOPLEFT", autoPopup, "BOTTOMLEFT", 0, -8)

	local icon = LibStub("LibDBIcon-1.0", true)
	local minimap
	if icon then
		minimap = newCheckbox(
			L["Minimap icon"],
			L.minimapDesc,
			function(self, value)
				BugSackLDBIconDB.hide = not value
				if BugSackLDBIconDB.hide then
					icon:Hide(addonName)
				else
					icon:Show(addonName)
				end
			end)
		minimap:SetPoint("TOPLEFT", chatFrame, "BOTTOMLEFT", 0, -8)
		minimap:SetChecked(not BugSackLDBIconDB.hide)
	end

	local mute = newCheckbox(
		L["Mute"],
		L.muteDesc,
		function(self, value) addon.db.mute = value end)
	mute:SetChecked(addon.db.mute)
	mute:SetPoint("TOPLEFT", minimap or chatFrame, "BOTTOMLEFT", 0, -8)

	local media = addon:EnsureLSM3()
	-- Jeeeeesus christ dropdowns are funky!
	local sound = nil
	if media then
		sound = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
		sound:SetPoint("TOPLEFT", mute, "BOTTOMLEFT", 8, -24)
		sound:SetJustifyH("LEFT")
		sound:SetHeight(18)
		sound:SetWidth(70)
		sound:SetText(L["Sound"])
		local dropdown = CreateFrame("Frame", "BugSackSoundDropdown", frame, "UIDropDownMenuTemplate")
		dropdown:SetPoint("TOPLEFT", sound, "TOPRIGHT", 16, 3)
		local function itemOnClick(self)
			local selected = self.value
			addon.db.soundMedia = selected
			UIDropDownMenu_SetSelectedValue(dropdown, selected)
		end
		UIDropDownMenu_Initialize(dropdown, function()
			local info = UIDropDownMenu_CreateInfo()
			for idx, sound in next, media:List("sound") do
				info.text = sound
				info.value = sound
				info.func = itemOnClick
				info.checked = sound == addon.db.soundMedia
				UIDropDownMenu_AddButton(info)
			end
		end)
		UIDropDownMenu_SetSelectedValue(dropdown, addon.db.soundMedia)
		UIDropDownMenu_SetWidth(dropdown, 160)
		UIDropDownMenu_JustifyText(dropdown, "LEFT")
	end

	local size = frame:CreateFontString(nil, "OVERLAY", "GameFontNormal")
	size:SetPoint("TOPLEFT", sound, "BOTTOMLEFT", media and 0 or 6, -24)
	size:SetJustifyH("LEFT")
	size:SetHeight(18)
	size:SetWidth(70)
	size:SetText(L["Font size"])
	local dropdown = CreateFrame("Frame", "BugSackFontSize", frame, "UIDropDownMenuTemplate")
	dropdown:SetPoint("TOPLEFT", size, "TOPRIGHT", 16, 3)
	local function itemOnClick(self)
		local selected = self.value
		addon.db.fontSize = selected
		if _G.BugSackFrameScrollText then
			_G.BugSackFrameScrollText:SetFontObject(_G[selected])
		end
		UIDropDownMenu_SetSelectedValue(dropdown, selected)
	end
	UIDropDownMenu_Initialize(dropdown, function()
		local info = UIDropDownMenu_CreateInfo()
		local fonts = {"GameFontHighlightSmall", "GameFontHighlight", "GameFontHighlightMedium", "GameFontHighlightLarge"}
		local names = {L["Small"], L["Medium"], L["Large"], L["X-Large"]}
		for i, font in next, fonts do
			info.text = names[i]
			info.value = font
			info.func = itemOnClick
			info.checked = font == addon.db.fontSize
			UIDropDownMenu_AddButton(info)
		end
	end)
	UIDropDownMenu_SetSelectedValue(dropdown, addon.db.fontSize)
	UIDropDownMenu_SetWidth(dropdown, 160)
	UIDropDownMenu_JustifyText(dropdown, "LEFT")

	local clear = CreateFrame("Button", "BugSackSaveButton", frame, UIPanelButtonTemplate)
	clear:SetText(L["Wipe saved bugs"])
	clear:SetWidth(177)
	clear:SetHeight(24)
	clear:SetPoint("TOPLEFT", size, "BOTTOMLEFT", -6, -24)
	clear:SetScript("OnClick", function()
		addon:Reset()
	end)
	clear.tooltipText = L["Wipe saved bugs"]
	clear.newbieText = L.wipeDesc
--[[
	local f = newColorbox("Test 1!", function() end)
	f:SetPoint("TOPLEFT", clear, "BOTTOMLEFT", 8, -20)
]]
	frame:SetScript("OnShow", nil)
end)
InterfaceOptions_AddCategory(frame)

