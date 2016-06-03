local F, C = unpack(Aurora)

-- [[ Splash screen ]]

local splash = CreateFrame("Frame", "AuroraSplashScreen", UIParent)
splash:SetPoint("CENTER")
splash:SetSize(400, 300)
splash:Hide()

do
	local title = splash:CreateFontString(nil, "ARTWORK", "GameFont_Gigantic")
	title:SetTextColor(1, 1, 1)
	title:SetPoint("TOP", 0, -25)
	title:SetText("Aurora "..GetAddOnMetadata("Aurora", "Version"))

	local body = splash:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
	body:SetPoint("TOP", title, "BOTTOM", 0, -20)
	body:SetWidth(360)
	body:SetJustifyH("CENTER")
	body:SetText("Thank you for using Aurora!\n\n\nType |cff00a0ff/aurora|r at any time to access Aurora's options.\n\nThere, you can customize the addon's appearance.\n\nYou can also turn off optional features such as bags and tooltips if they are incompatible with your other addons.\n\n\n\nEnjoy!")

	local okayButton = CreateFrame("Button", nil, splash, "UIPanelButtonTemplate")
	okayButton:SetSize(128, 25)
	okayButton:SetPoint("BOTTOM", 0, 10)
	okayButton:SetText("Got it")
	okayButton:SetScript("OnClick", function()
		splash:Hide()
		AuroraConfig.acknowledgedSplashScreen = true
	end)

	splash.okayButton = okayButton
	splash.closeButton = CreateFrame("Button", nil, splash, "UIPanelCloseButton")
end

-- [[ Options UI ]]

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

local function addSubCategory(parent, name)
	local header = parent:CreateFontString(nil, "ARTWORK", "GameFontHighlightSmall")
	header:SetText(name)

	local line = parent:CreateTexture(nil, "ARTWORK")
	line:SetSize(450, 1)
	line:SetPoint("TOPLEFT", header, "BOTTOMLEFT", 0, -4)
    if C.isBetaClient then
		line:SetColorTexture(1, 1, 1, .2)
    else
		line:SetTexture(1, 1, 1, .2)
    end

	return header
end

local function toggle(f)
	AuroraConfig[f.value] = f:GetChecked()
end

local function createToggleBox(parent, value, text)
	local f = CreateFrame("CheckButton", nil, parent, "InterfaceOptionsCheckButtonTemplate")
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
title:SetText("Aurora "..GetAddOnMetadata("Aurora", "Version"))

local features = addSubCategory(gui, "Features")
features:SetPoint("TOPLEFT", 16, -80)

local bagsBox = createToggleBox(gui, "bags", "Bags")
bagsBox:SetPoint("TOPLEFT", features, "BOTTOMLEFT", 0, -20)

local chatBubbleBox = createToggleBox(gui, "chatBubbles", "Chat bubbles")
chatBubbleBox:SetPoint("LEFT", bagsBox, "RIGHT", 90, 0)

local lootBox = createToggleBox(gui, "loot", "Loot")
lootBox:SetPoint("TOPLEFT", bagsBox, "BOTTOMLEFT", 0, -8)

local tooltipsBox = createToggleBox(gui, "tooltips", "Tooltips")
tooltipsBox:SetPoint("LEFT", lootBox, "RIGHT", 90, 0)

local appearance = addSubCategory(gui, "Appearance")
appearance:SetPoint("TOPLEFT", lootBox, "BOTTOMLEFT", 0, -30)

local fontBox = createToggleBox(gui, "enableFont", "Replace default game fonts")
fontBox:SetPoint("TOPLEFT", appearance, "BOTTOMLEFT", 0, -20)

local colourBox = createToggleBox(gui, "useCustomColour", "Custom highlight colour")
colourBox:SetPoint("TOPLEFT", fontBox, "BOTTOMLEFT", 0, -8)

local colourButton = CreateFrame("Button", nil, gui, "UIPanelButtonTemplate")
colourButton:SetPoint("LEFT", colourBox.Text, "RIGHT", 20, 0)
colourButton:SetSize(128, 25)
colourButton:SetText("Change...")

local useButtonGradientColourBox = createToggleBox(gui, "useButtonGradientColour", "Gradient button style")
useButtonGradientColourBox:SetPoint("TOPLEFT", colourBox, "BOTTOMLEFT", 0, -8)

local alphaSlider = CreateFrame("Slider", "AuroraOptionsAlpha", gui, "OptionsSliderTemplate")
alphaSlider:SetPoint("TOPLEFT", useButtonGradientColourBox, "BOTTOMLEFT", 0, -40)
BlizzardOptionsPanel_Slider_Enable(alphaSlider)
alphaSlider:SetMinMaxValues(0, 1)
alphaSlider:SetValueStep(0.1)
AuroraOptionsAlphaText:SetText("Backdrop opacity *")

local line = gui:CreateTexture(nil, "ARTWORK")
line:SetSize(600, 1)
line:SetPoint("TOPLEFT", alphaSlider, "BOTTOMLEFT", 0, -30)
if C.isBetaClient then
	line:SetColorTexture(1, 1, 1, .2)
else
	line:SetTexture(1, 1, 1, .2)
end

local reloadText = gui:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
reloadText:SetPoint("TOPLEFT", line, "BOTTOMLEFT", 0, -40)
reloadText:SetText("Settings not marked with an asterisk (*) require a UI reload.")

local reloadButton = CreateFrame("Button", nil, gui, "UIPanelButtonTemplate")
reloadButton:SetPoint("LEFT", reloadText, "RIGHT", 20, 0)
reloadButton:SetSize(128, 25)
reloadButton:SetText("Reload UI")

local credits = gui:CreateFontString(nil, "ARTWORK", "GameFontHighlight")
credits:SetText("Aurora by Lightsword @ Argent Dawn - EU / Haleth on wowinterface.com")
credits:SetPoint("BOTTOM", 0, 40)

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

	F.CreateBD(splash)
	F.Reskin(splash.okayButton)
	F.ReskinClose(splash.closeButton)

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
	AuroraConfig.customColour.r, AuroraConfig.customColour.g, AuroraConfig.customColour.b = ColorPickerFrame:GetColorRGB()
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
