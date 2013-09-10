local F, C = unpack(Aurora)

-- these variables are loaded on init and updated only on gui.okay. Calling gui.cancel resets the saved vars to these
local old = {}

local checkboxes = {}

-- function to copy table contents and inner table
local function copyTable(source, target)
	for key, value in pairs(source) do
		if type(value) == "table" then
			target[key] = {}
			for k, v in pairs(value) do
				target[key][k] = value[k]
			end
		else
			target[key] = value
		end
	end
end

local function toggle(f)
	if f:GetChecked() then
		AuroraConfig[f.value] = true
	else
		AuroraConfig[f.value] = false
	end
end

local function createToggleBox(parent, name, value, text)
	local f = CreateFrame("CheckButton", name, parent, "InterfaceOptionsCheckButtonTemplate")
	f.value = value

	f.Text:SetText(text)

	f:SetScript("OnClick", toggle)

	tinsert(checkboxes, f)

	return f
end

-- create frames/widgets

local gui = CreateFrame("Frame", "AuroraOptions", UIParent)
gui.name = "Aurora"
InterfaceOptions_AddCategory(gui)

local title = gui:CreateFontString(nil, "ARTWORK", "GameFontNormalLarge")
title:SetPoint("TOP", 0, -26)
title:SetText("Aurora v."..GetAddOnMetadata("Aurora", "Version"))

local credits = gui:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
credits:SetText("Aurora by Freethinker @ Steamwheedle Cartel - EU / Haleth on wowinterface.com")
credits:SetPoint("TOP", 0, -380)

local alphaSlider = CreateFrame("Slider", "AuroraOptionsAlpha", gui, "OptionsSliderTemplate")
alphaSlider:SetPoint("TOPLEFT", 16, -80)
BlizzardOptionsPanel_Slider_Enable(alphaSlider)
alphaSlider:SetMinMaxValues(0, 1)
alphaSlider:SetValueStep(0.1)
AuroraOptionsAlphaText:SetText("Backdrop opacity")

local line = gui:CreateTexture(nil, "ARTWORK")
line:SetSize(600, 1)
line:SetPoint("TOPLEFT", alphaSlider, "BOTTOMLEFT", 0, -30)
line:SetTexture(1, 1, 1, .2)

local fontBox = createToggleBox(gui, "AuroraOptionsEnableFont", "enableFont", "Replace default game fonts")
fontBox:SetPoint("TOPLEFT", 16, -140)

local colourBox = createToggleBox(gui, "AuroraOptionsUseClassColours", "useCustomColour", "Use custom colour rather than class as highlight")
colourBox:SetPoint("TOPLEFT", fontBox, "BOTTOMLEFT", 0, -8)

local colourButton = CreateFrame("Button", "AuroraOptionsCustomColour", gui, "UIPanelButtonTemplate")
colourButton:SetPoint("LEFT", colourBox.Text, "RIGHT", 20, 0)
colourButton:SetSize(128, 25)
colourButton:SetText("Change...")

local bagsBox = createToggleBox(gui, "AuroraOptionsBags", "bags", "Bags")
bagsBox:SetPoint("TOPLEFT", colourBox, "BOTTOMLEFT", 0, -16)

local lootBox = createToggleBox(gui, "AuroraOptionsLoot", "loot", "Loot")
lootBox:SetPoint("LEFT", bagsBox, "RIGHT", 90, 0)

local chatBubbleBox = createToggleBox(gui, "AuroraOptionsChatBubbles", "chatBubbles", "Chat bubbles")
chatBubbleBox:SetPoint("LEFT", lootBox, "RIGHT", 90, 0)

local mapBox = createToggleBox(gui, "AuroraOptionsMap", "map", "Map")
mapBox:SetPoint("TOPLEFT", bagsBox, "BOTTOMLEFT", 0, -8)

local tooltipsBox = createToggleBox(gui, "AuroraOptionsTooltips", "tooltips", "Tooltips")
tooltipsBox:SetPoint("LEFT", mapBox, "RIGHT", 90, 0)

local qualityColourBox = createToggleBox(gui, "AuroraOptionsQualityColour", "qualityColour", "Item quality colours")
qualityColourBox:SetPoint("LEFT", tooltipsBox, "RIGHT", 90, 0)

local reloadText = gui:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
reloadText:SetPoint("TOPLEFT", bagsBox, "BOTTOMLEFT", 0, -60)
reloadText:SetText("These settings require a UI reload.")

local reloadButton = CreateFrame("Button", "AuroraOptionsReloadUI", gui, "UIPanelButtonTemplate")
reloadButton:SetPoint("LEFT", reloadText, "RIGHT", 20, 0)
reloadButton:SetSize(128, 25)
reloadButton:SetText("Reload UI")

local line2 = gui:CreateTexture(nil, "ARTWORK")
line2:SetSize(600, 1)
line2:SetPoint("TOPLEFT", reloadText, "BOTTOMLEFT", 0, -30)
line2:SetTexture(1, 1, 1, .2)

-- add event handlers

gui.refresh = function()
	alphaSlider:SetValue(AuroraConfig.alpha)

	for i = 1, #checkboxes do
		checkboxes[i]:SetChecked(AuroraConfig[checkboxes[i].value] == true)
	end

	if not colourBox:GetChecked() then
		colourButton:Disable()
	end
end

gui:RegisterEvent("ADDON_LOADED")
gui:SetScript("OnEvent", function(self, _, addon)
	if addon ~= "Aurora" then return end

	-- fill 'old' table
	copyTable(AuroraConfig, old)

	F.Reskin(reloadButton)
	F.Reskin(colourButton)
	F.ReskinSlider(alphaSlider)

	for i = 1, #checkboxes do
		F.ReskinCheck(checkboxes[i])
	end

	self:UnregisterEvent("ADDON_LOADED")
end)

local function updateFrames()
	for i = 1, #C.frames do
		F.CreateBD(C.frames[i], AuroraConfig.alpha)
	end
end

gui.okay = function()
	copyTable(AuroraConfig, old)
end

gui.cancel = function()
	copyTable(old, AuroraConfig)

	updateFrames()
	gui.refresh()
end

gui.default = function()
	copyTable(C.defaults, AuroraConfig)

	updateFrames()
	gui.refresh()
end

reloadButton:SetScript("OnClick", ReloadUI)

alphaSlider:SetScript("OnValueChanged", function(_, value)
	AuroraConfig.alpha = value
	updateFrames()
end)

colourBox:SetScript("OnClick", function(self)
	if self:GetChecked() then
		AuroraConfig.useCustomColour = true
		colourButton:Enable()
	else
		AuroraConfig.useCustomColour = false
		colourButton:Disable()
	end
end)

local function setColour()
	local r, g, b = ColorPickerFrame:GetColorRGB()
	AuroraConfig.customColour.r, AuroraConfig.customColour.g, AuroraConfig.customColour.b = r, g, b
end

local function resetColour(restore)
	AuroraConfig.customColour.r, AuroraConfig.customColour.g, AuroraConfig.customColour.b = restore.r, restore.g, restore.b
end

colourButton:SetScript("OnClick", function()
	local r, g, b = AuroraConfig.customColour.r, AuroraConfig.customColour.g, AuroraConfig.customColour.b
	ColorPickerFrame:SetColorRGB(r, g, b)
	ColorPickerFrame.previousValues = {r = r, g = g, b = b}
	ColorPickerFrame.func = setColour
	ColorPickerFrame.cancelFunc = resetColour
	ColorPickerFrame:Hide()
	ColorPickerFrame:Show()
end)

-- easy slash command

SlashCmdList.AURORA = function()
	InterfaceOptionsFrame_OpenToCategory(gui)
end
SLASH_AURORA1 = "/aurora"