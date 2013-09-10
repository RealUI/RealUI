local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local ndb, ndbc

local _
local ConfigBar = nibRealUI:GetModule("ConfigBar")

local MODNAME = "ConfigBar_GUI"
local ConfigBar_GUI = nibRealUI:NewModule(MODNAME)

local FontStringsOrange = {}
local FontStringsGreen = {}
local FontStringsBlue = {}
local TexturesOrange = {}

-- Tooltips
local function Element_OnEnter(self, tip)
	GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT", 0, 1)
	GameTooltip:AddLine(tip)
	GameTooltip:Show()
end

local function Element_OnLeave(self)
	GameTooltip:Hide()
end


-- Slider
local function ReskinSlider(f)
	f:SetBackdrop(nil)

	f:SetHitRectInsets(0, 0, 0, 0)
	
	local bd = CreateFrame("Frame", nil, f)
	bd:SetPoint("TOPLEFT", 0, 1)
	bd:SetPoint("BOTTOMRIGHT", 0, 0)
	nibRealUI:CreateBD(bd)
	bd:SetBackdropColor(0.2, 0.2, 0.2, 0.5)

	local sliderTex = select(4, f:GetRegions())
	sliderTex:SetVertexColor(unpack(nibRealUI.media.colors.orange))

	for i = 1, f:GetNumRegions() do
		local region = select(i, f:GetRegions())
		if region:GetObjectType() == "FontString" then
			if (region:GetText() == LOW) or (region:GetText() == HIGH) then
				region:SetText("")
			end
		end
	end
end

local function CreateSlider(parent, info, key)
	local f = CreateFrame("Slider", "RealUIConfigBar"..info[1].name..key, parent, "OptionsSliderTemplate")
	f.func = info[key].func

	f:SetSize(info[key].sliderWidth or info[1].sliderWidth, 12)
	f:SetMinMaxValues(info[key].min or info[1].min, info[key].max or info[1].max)
	f:SetValue(info[key].value or 0)

	local step = info[key].step or info[1].step or 1
	f:SetValueStep(step)

	f.label = f:CreateFontString()
		f.label:SetFont(nibRealUI.font.standard, 10)
		f.label:SetText(info[key].label or info[1].label)
		f.label:SetJustifyV("MIDDLE")
		f.label:SetJustifyH("LEFT")
		f.label:SetPoint("RIGHT", f, "LEFT", -6, 0)

	f.value = f:CreateFontString()
		f.value:SetFont(nibRealUI.font.standard, 10)
		f.value:SetText(floor(f:GetValue()))
		f.value:SetJustifyV("MIDDLE")
		f.value:SetJustifyH("LEFT")
		f.value:SetPoint("LEFT", f, "RIGHT", 6, 0)

	f:SetScript("OnValueChanged", function(self, value)
		self.value:SetText(floor(value))
		self.func(floor(value))
	end)
	f:EnableMouseWheel()
	f:SetScript("OnMouseWheel", function(self, direction)
		if direction > 0 then
			self:SetValue(self:GetValue() + self:GetValueStep())
		else
			self:SetValue(self:GetValue() - self:GetValueStep())
		end
	end)

	ReskinSlider(f)

	return f
end

function ConfigBar_GUI:CreateSliderList(element, direction, info)
	local sliderFrames = {}
	for k, sliderInfo in ipairs(info) do
		sliderFrames[k] = CreateFrame("Frame", nil, element.window or element)
		-- sliderFrames[k]:SetFrameLevel(8)

		-- Slider
		sliderFrames[k].slider = CreateSlider(sliderFrames[k], info, k)
		sliderFrames[k].slider:SetPoint("CENTER", sliderFrames[k])

		-- Size/Position
		sliderFrames[k]:SetSize(sliderInfo.width or info[1].width, sliderInfo.height or info[1].height)
		if k == 1 then
			if direction == "VERTICAL" then
				sliderFrames[k]:SetPoint("TOPLEFT", element.window or element, "TOPLEFT", info[1].x, info[1].y - 12)
			else
				sliderFrames[k]:SetPoint("TOPLEFT", element.window or element, "TOPLEFT", info[1].x, info[1].y)
			end
		else
			if direction == "VERTICAL" then
				sliderFrames[k]:SetPoint("TOPLEFT", sliderFrames[k-1], "BOTTOMLEFT")
			else
				sliderFrames[k]:SetPoint("TOPLEFT", sliderFrames[k-1], "TOPRIGHT")
			end
		end
	end

	return sliderFrames
end

-- Color Picker
local function ColorCallback(frame, r, g, b, a)
	frame.color:SetTexture(r, g, b, a)
	if ColorPickerFrame:IsVisible() then
		--colorpicker is still open
		frame.func(r, g, b, a)
	else
		--colorpicker is closed, color callback is first, ignore it,
		--alpha callback is the final call after it closes so confirm now
		frame.func(r, g, b, a)
	end
end

local function ColorSwatch_OnClick(frame)
	HideUIPanel(ColorPickerFrame)

	if not frame.disabled then
		ColorPickerFrame:SetFrameStrata("FULLSCREEN_DIALOG")

		ColorPickerFrame.func = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = 1 - OpacitySliderFrame:GetValue()
			ColorCallback(frame, r, g, b, a)
		end

		ColorPickerFrame.hasOpacity = true
		ColorPickerFrame.opacityFunc = function()
			local r, g, b = ColorPickerFrame:GetColorRGB()
			local a = 1 - OpacitySliderFrame:GetValue()
			ColorCallback(frame, r, g, b, a)
		end

		local r, g, b, a = frame.r, frame.g, frame.b, frame.a
		ColorPickerFrame.opacity = 1 - (a or 0)
		ColorPickerFrame:SetColorRGB(r, g, b)

		ColorPickerFrame.cancelFunc = function()
			ColorCallback(frame, r, g, b, a)
		end

		ShowUIPanel(ColorPickerFrame)
	end
end

function ConfigBar_GUI:CreateColorPicker(parent, info)
	local frame = CreateFrame("Button", nil, parent)
	frame.obj = self
	frame.r = info.color[1]
	frame.g = info.color[2]
	frame.b = info.color[3]
	frame.a = info.color[4] or 1
	frame.func = info.func
	frame:EnableMouse(true)

	local colorSwatch = CreateFrame("Frame", nil, frame)
		colorSwatch:SetPoint("LEFT", frame, "LEFT", 4, 0)
		colorSwatch:SetSize(14, 14)

	local bg = nibRealUI:CreateBDFrame(colorSwatch, 0)

	colorSwatch.color = colorSwatch:CreateTexture(nil, "OVERLAY")
		colorSwatch.color:SetAllPoints()
		colorSwatch.color:SetTexture(unpack(info.color))
		frame.color = colorSwatch.color

	local checkers = colorSwatch:CreateTexture(nil, "BACKGROUND")
		checkers:SetPoint("CENTER", colorSwatch)
		checkers:SetSize(14, 14)
		checkers:SetTexture([[Tileset\Generic\Checkers]])
		checkers:SetTexCoord(.25, 0, 0.5, .25)
		checkers:SetDesaturated(true)
		checkers:SetVertexColor(1, 1, 1, 0.75)

	frame.label = frame:CreateFontString()
		frame.label:SetFont(nibRealUI.font.standard, 10)
		frame.label:SetText(info.label)
		frame.label:SetJustifyV("MIDDLE")
		frame.label:SetJustifyH("LEFT")
		frame.label:SetPoint("LEFT", frame, "LEFT", 23, 0)

	-- Highlight
	frame.highlight = frame:CreateTexture(nil, "BACKGROUND")
		frame.highlight:SetPoint("BOTTOMLEFT", frame, "BOTTOMLEFT", 1, 0)
		frame.highlight:SetPoint("TOPRIGHT", frame, "TOPRIGHT", -1, 0)
		frame.highlight:SetTexture(nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3], 0.2)
		frame.highlight:Hide()

	-- Enter/Leave/MouseDown
	frame:SetScript("OnEnter", function(self) self.highlight:Show() end)
	frame:SetScript("OnLeave", function(self) self.highlight:Hide() end)
	frame:SetScript("OnMouseDown", ColorSwatch_OnClick)

	return frame
end

function ConfigBar_GUI:CreateColorPickerList(element, direction, colorPickers)
	local parent = element.window or element

	local cpFrames = {}
	local curWidth
	for k, info in ipairs(colorPickers) do
		cpFrames[k] = self:CreateColorPicker(parent, info)

		-- Size
		cpFrames[k]:SetSize(colorPickers[1].width, colorPickers[1].height)

		-- Position
		if k == 1 then
			cpFrames[k]:SetPoint("TOPLEFT", parent, "TOPLEFT", info.x, info.y)
		else
			if direction == "VERTICAL" then
				cpFrames[k]:SetPoint("TOPLEFT", cpFrames[k-1], "BOTTOMLEFT", 0, 0)
			else
				cpFrames[k]:SetPoint("TOPLEFT", cpFrames[k-1], "TOPRIGHT", 0, 0)
			end
		end
	end

	return cpFrames
end

-- Option List
function ConfigBar_GUI:CreateOptionList(element, direction, options)
	local optionFrames = {}
	for k, info in ipairs(options) do
		optionFrames[k] = CreateFrame("Frame", nil, element.window or element)
		optionFrames[k].info = info

		-- Tick Box
		optionFrames[k].check = CreateFrame("Frame", nil, optionFrames[k])
			optionFrames[k].check:SetPoint("LEFT", optionFrames[k], "LEFT", 12, 0)
			optionFrames[k].check:SetSize(7, 7)
		optionFrames[k].check.bg = nibRealUI:CreateBDFrame(optionFrames[k].check)
			optionFrames[k].check.bg:SetBackdropColor(0.2, 0.2, 0.2, 1)
		optionFrames[k].check.highlight = optionFrames[k].check:CreateTexture(nil, "OVERLAY")
		tinsert(TexturesOrange, optionFrames[k].check.highlight)
			optionFrames[k].check.highlight:SetAllPoints()
			optionFrames[k].check.highlight:SetTexture(unpack(nibRealUI.media.colors.orange))
			optionFrames[k].check.highlight:SetAlpha(info.checked and 1 or 0)

		-- Label
		optionFrames[k].label = optionFrames[k]:CreateFontString()
			optionFrames[k].label:SetFont(nibRealUI.font.standard, 10)
			optionFrames[k].label:SetText(info.label)
			optionFrames[k].label:SetJustifyV("MIDDLE")
			optionFrames[k].label:SetJustifyH("LEFT")
			optionFrames[k].label:SetPoint("LEFT", optionFrames[k], "LEFT", 27, 0)
			if optionFrames[k].info and optionFrames[k].info.isDisabled then optionFrames[k].label:SetTextColor(0.5, 0.5, 0.5) end

		-- Desc
		optionFrames[k].desc = optionFrames[k]:CreateFontString()
			optionFrames[k].desc:SetFont(nibRealUI.font.standard, 10)
			optionFrames[k].desc:SetText(info.desc)
			optionFrames[k].desc:SetJustifyV("MIDDLE")
			optionFrames[k].desc:SetJustifyH("LEFT")
			optionFrames[k].desc:SetPoint("LEFT", optionFrames[k], "LEFT", info.descGap or options[1].descGap or 92, 0)

		-- Highlight
		optionFrames[k].highlight = optionFrames[k]:CreateTexture(nil, "BACKGROUND")
			optionFrames[k].highlight:SetPoint("BOTTOMLEFT", optionFrames[k], "BOTTOMLEFT", 1, 0)
			optionFrames[k].highlight:SetPoint("TOPRIGHT", optionFrames[k], "TOPRIGHT", -1, 0)
			optionFrames[k].highlight:SetTexture(nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3], 0.2)
			optionFrames[k].highlight:Hide()

		-- Enter/Leave/MouseDown
		optionFrames[k]:SetScript("OnEnter", function(self)
			if self.info and self.info.isDisabled then return end
			self.highlight:Show()
			if info.tip then Element_OnEnter(self, info.tip) end
		end)
		optionFrames[k]:SetScript("OnLeave", function(self)
			self.highlight:Hide()
			if info.tip then Element_OnLeave(self) end
		end)
		optionFrames[k]:SetScript("OnMouseDown", function() 
			if self.info and self.info.isDisabled then return end
			info.func()
		end)

		-- Size/Position
		optionFrames[k]:SetSize(info.width or options[1].width, info.height or options[1].height)
		if k == 1 then
			if direction == "VERTICAL" then
				optionFrames[k]:SetPoint("TOPLEFT", element.window or element, "TOPLEFT", info.x, info.y - 12)
			else
				optionFrames[k]:SetPoint("TOPLEFT", element.window or element, "TOPLEFT", info.x, info.y - 12)
			end
		else
			if direction == "VERTICAL" then
				optionFrames[k]:SetPoint("TOPLEFT", optionFrames[k-1], "BOTTOMLEFT")
			else
				optionFrames[k]:SetPoint("TOPLEFT", optionFrames[k-1], "TOPRIGHT")
			end
		end
	end

	return optionFrames
end

-- Button List
function ConfigBar_GUI:CreateButtonList(element, direction, buttons)
	local buttonFrames = {}
	local maxButtonWidth = 0
	for k, info in ipairs(buttons) do
		buttonFrames[k] = CreateFrame("Frame", nil, element.window)

		-- Label
		buttonFrames[k].label = buttonFrames[k]:CreateFontString()
			buttonFrames[k].label:SetFont(nibRealUI.font.standard, 10)
			buttonFrames[k].label:SetText(info.label)
			buttonFrames[k].label:SetJustifyV("MIDDLE")
			local justifyH = info.justifyH or buttons[1].justifyH
			buttonFrames[k].label:SetJustifyH(justifyH)
			if justifyH == "LEFT" then
				buttonFrames[k].label:SetPoint("LEFT", buttonFrames[k], "LEFT", 12, 0)
			else
				buttonFrames[k].label:SetAllPoints()
			end

		-- Max Width
		local curWidth = buttonFrames[k].label:GetWidth() + 24
		if curWidth > maxButtonWidth then maxButtonWidth = curWidth end

		-- Highlight
		buttonFrames[k].highlight = buttonFrames[k]:CreateTexture(nil, "BACKGROUND")
			buttonFrames[k].highlight:SetPoint("BOTTOMLEFT", buttonFrames[k], "BOTTOMLEFT", 1, 0)
			buttonFrames[k].highlight:SetPoint("TOPRIGHT", buttonFrames[k], "TOPRIGHT", -1, 0)
			buttonFrames[k].highlight:SetTexture(nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3], 0.2)
			buttonFrames[k].highlight:Hide()

		-- Enter/Leave/MouseDown
		buttonFrames[k]:SetScript("OnEnter", function(self)
			self.highlight:Show()
		end)
		buttonFrames[k]:SetScript("OnLeave", function(self)
			self.highlight:Hide()
		end)
		buttonFrames[k]:SetScript("OnMouseDown", function()
			info.func()
		end)

		-- Size/Position
		-- buttonFrames[k]:SetSize(info.width or buttons[1].width, info.height or buttons[1].height)
		if k == 1 then
			if direction == "VERTICAL" then
				buttonFrames[k]:SetPoint("TOPLEFT", element.window, "TOPLEFT", info.x, info.y - 12)
			else
				buttonFrames[k]:SetPoint("TOPLEFT", element.window, "TOPLEFT", info.x, info.y)
			end
		else
			if direction == "VERTICAL" then
				buttonFrames[k]:SetPoint("TOPLEFT", buttonFrames[k-1], "BOTTOMLEFT")
			else
				buttonFrames[k]:SetPoint("TOPLEFT", buttonFrames[k-1], "TOPRIGHT")
			end
		end
	end

	for k, button in ipairs(buttonFrames) do
		button:SetSize(maxButtonWidth + 2, buttons[k].height or buttons[1].height)
	end

	return buttonFrames, maxButtonWidth + 2
end

-- Input
function ConfigBar_GUI:CreateInput(element, info)
	local parent = element.window or element

	local input = CreateFrame("Frame", nil, parent)
		input:SetSize(info.width, info.height or 24)
		input:SetPoint("TOPLEFT", parent, "TOPLEFT", info.x, info.y)

	input.label = input:CreateFontString()
	local label = input.label
		label:SetPoint("LEFT", input, "LEFT")
		label:SetFont(nibRealUI.font.standard, 10)
		label:SetText(info.label or "")
		label:SetJustifyH("LEFT")

	input.editBox = CreateFrame("EditBox", "RealUIConfigBar"..info.name, input, "InputBoxTemplate")
	local edit = input.editBox
		edit:SetPoint("TOPLEFT", input, "TOPLEFT", label:GetWidth() + 8, -2)
		edit:SetAutoFocus(false)
		edit:EnableMouse(true)
		edit:SetWidth(info.inputWidth or 100)
		edit:SetHeight(info.inputHeight or 20)
		edit:SetMaxLetters(info.maxLength or 60)
		edit:SetScript("OnEscapePressed", function(frame)
			frame:ClearFocus()
		end)
		edit:SetScript("OnEnterPressed", function(frame)
			info.func(frame:GetText())
			frame:ClearFocus()
		end)

	if info.tip then
		edit:SetScript("OnEnter", function(self)
			Element_OnEnter(self, info.tip)
		end)
		edit:SetScript("OnLeave", function(self)
			Element_OnLeave(self)
		end)
	end

	if Aurora then
		Aurora[1].ReskinInput(edit)
	end

	return edit
end

-- Button
function ConfigBar_GUI:CreateButton(element, info)
	local parent = element.window or element
	local button = nibRealUI:CreateTextButton(info.label, parent, info.width, info.height, info.secure, true)
	button:SetPoint("TOPLEFT", parent, "TOPLEFT", info.x, info.y)
	
	if info.macroText then
		button:SetAttribute("type", "macro")
		button:SetAttribute("macrotext", info.macroText)
	elseif info.func then
		button:SetScript("OnMouseDown", function() info.func() end)
	end

	if Aurora then Aurora[1].Reskin(button) end

	return button
end

-- Dropdown
function ConfigBar_GUI:CreateDropdown(element, info)
	local parent = element.window or element
	local dropdown = CreateFrame("Frame", "RealUIConfigBar"..info.name, parent, "UIDropDownMenuTemplate")
		UIDropDownMenu_SetWidth(dropdown, 184)
		dropdown:SetPoint("TOPLEFT", parent, "TOPLEFT", info.x, info.y)
		dropdown:SetFrameLevel(parent:GetFrameLevel() + 2)
		dropdown:SetSize(235, 18)
		_G["RealUIConfigBar"..info.name.."Text"]:SetFont(nibRealUI.font.standard, 10)
	
	nibRealUI:CreateBGSection(parent, dropdown, dropdown, 14, -2, -16, 6)
	if Aurora then Aurora[1].ReskinDropDown(dropdown) end

	UIDropDownMenu_Initialize(dropdown, info.initFunc)
    UIDropDownMenu_SetSelectedValue(dropdown, info.value)
    UIDropDownMenu_SetText(dropdown, info.text)

	return dropdown
end

-- String
function ConfigBar_GUI:CreateString(element, info)
	local parent = element.window or element

	local string = parent:CreateFontString()
		string:SetFont(nibRealUI.font.standard, 10)
		string:SetText(info.text)
		string:SetJustifyH(info.justify or "LEFT")
		string:SetSpacing(info.spacing or 1)
		local point = info.justify and "TOP"..info.justify or "TOPLEFT"
		string:SetPoint(point, parent, point, info.x, info.y)

		if info.color then
			string:SetTextColor(unpack(nibRealUI.media.colors[info.color]))
			if info.color == "green" then
				tinsert(FontStringsGreen, string)
			elseif info.color == "blue" then
				tinsert(FontStringsBlue, string)
			end
		end

	return string
end

-- Secondary Header
function ConfigBar_GUI:CreateSecondHeader(element, text, x, y, lineWidth)
	local parent = element.window or element

	local header = parent:CreateFontString()
	tinsert(FontStringsOrange, header)
		header:SetFont(nibRealUI.font.standard, 10)
		header:SetText(text)
		header:SetTextColor(unpack(nibRealUI.media.colors.orange))
		header:SetJustifyH("LEFT")
		header:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y)

	local headerTextWidth = header:GetWidth()

	if lineWidth then
		local headerLine = parent:CreateTexture(nil, "ARTWORK")
			headerLine:SetTexture(nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3], 0.2)
			headerLine:SetSize(lineWidth, 1)
			headerLine:SetPoint("TOPLEFT", parent, "TOPLEFT", x, y - 12)
	end

	return header
end

-- Header
function ConfigBar_GUI:CreateHeader(element, text, y)
	local parent = element.window or element
	if text then
		local header = CreateFrame("Frame", nil, parent)
			header:SetPoint("TOPLEFT", parent, "TOPLEFT", 0, y)
			header:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, y - 32)

		local headerString = header:CreateFontString()
			headerString:SetFont(nibRealUI.font.standard, 10)
			headerString:SetText(text)
			headerString:SetJustifyH("LEFT")
			headerString:SetPoint("TOPLEFT", header, "TOPLEFT", 12, -6)

		local headerTextWidth = headerString:GetWidth()

		local headerBG = header:CreateTexture(nil, "ARTWORK")
			headerBG:SetTexture(nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3], 0.2)
			headerBG:SetPoint("TOPLEFT", header, "TOPLEFT", 1, -1)
			headerBG:SetPoint("BOTTOMRIGHT", header, "TOPLEFT", headerTextWidth + 19, -21)

		local headerEnd = header:CreateTexture(nil, "ARTWORK")
			headerEnd:SetTexture([[Interface\AddOns\nibRealUI\Media\Config\HeaderEnd]])
			headerEnd:SetVertexColor(nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3], 0.2)
			headerEnd:SetPoint("TOPLEFT", headerBG, "TOPRIGHT")
			headerEnd:SetSize(32, 32)

		local headerLine = header:CreateTexture(nil, "ARTWORK")
			headerLine:SetTexture(nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3], 0.2)
			headerLine:SetHeight(1)
			headerLine:SetPoint("TOPLEFT", headerEnd, "TOPRIGHT", -19, 0)
			headerLine:SetWidth(parent:GetWidth() - (headerTextWidth + 33))
	
		return header

	else
		local headerLine = parent:CreateTexture(nil, "ARTWORK")
			headerLine:SetTexture(nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3], 0.2)
			headerLine:SetPoint("TOPLEFT", parent, "TOPLEFT", 1, y - 1)
			headerLine:SetSize(parent:GetWidth() - 2, 1)

		return headerLine
	end
end

-- Tabs
function ConfigBar_GUI:CreateTabList(element, tabs, direction, point, x, y)
	local tabFrames = {}
	for k, info in ipairs(tabs) do
		tabFrames[k] = CreateFrame("Frame", nil, element.window)
			tabFrames[k].EnableMouse = true
			tabFrames[k]:SetSize(32, 32)
			nibRealUI:CreateBD(tabFrames[k])

		-- Icon
		tabFrames[k].icon = tabFrames[k]:CreateTexture(nil, "ARTWORK")
			if info.texPosition then
				tabFrames[k].icon:SetPoint("TOP", tabFrames[k], "TOP", info.texPosition.x, info.texPosition.y)
			elseif info.texOffset then
				tabFrames[k].icon:SetPoint("BOTTOMLEFT", info.texOffset[1], info.texOffset[2])
				tabFrames[k].icon:SetPoint("TOPRIGHT", info.texOffset[3], info.texOffset[4])
			else
				tabFrames[k].icon:SetAllPoints(tabFrames[k])
			end
			if info.texCoord then
				tabFrames[k].icon:SetTexCoord(unpack(info.texCoord))
			end
			tabFrames[k].icon:SetTexture(info.texture)

		-- Background
		tabFrames[k].bg = tabFrames[k]:CreateTexture(nil, "BACKGROUND")
		if info.bg then
			if info.bg.texPosition then
				tabFrames[k].bg:SetPoint("TOP", tabFrames[k], "TOP", info.bg.texPosition.x, info.bg.texPosition.y)
			elseif info.bg.texOffset then
				tabFrames[k].bg:SetPoint("BOTTOMLEFT", info.bg.texOffset[1], info.bg.texOffset[2])
				tabFrames[k].bg:SetPoint("TOPRIGHT", info.bg.texOffset[3], info.bg.texOffset[4])
			else
				tabFrames[k].bg:SetAllPoints(tabFrames[k])
			end
			if info.texCoord then
				tabFrames[k].bg:SetTexCoord(unpack(info.bg.texCoord))
			end
			tabFrames[k].bg:SetTexture(info.bg.texture)
		end

		-- Highlight
		tabFrames[k].highlight = tabFrames[k]:CreateTexture(nil, "HIGHLIGHT")
			tabFrames[k].highlight:SetPoint("BOTTOMLEFT", tabFrames[k], "BOTTOMLEFT", 1, 1)
			tabFrames[k].highlight:SetPoint("TOPRIGHT", tabFrames[k], "TOPRIGHT", -1, -1)
			tabFrames[k].highlight:SetTexture(nibRealUI.classColor[1], nibRealUI.classColor[2], nibRealUI.classColor[3], 0.2)

		-- Click
		tabFrames[k]:SetScript("OnMouseDown", function()
			info.func()
		end)

		-- Position
		if k == 1 then
			tabFrames[k]:SetPoint(point, element.window, point, x, y)
		else
			if direction == "VERTICAL" then
				tabFrames[k]:SetPoint("TOPLEFT", tabFrames[k-1], "BOTTOMLEFT", 0, -1)
			else
				tabFrames[k]:SetPoint("TOPLEFT", tabFrames[k-1], "TOPRIGHT", 1, 0)
			end
		end
	end

	return tabFrames
end

-- Window
function ConfigBar_GUI:CreateWindow(element, name, draggable)
	local window = nibRealUI:CreateWindow("RealUIConfigWindow"..name, element.info.window.width, element.info.window.height, false, draggable)
	window:SetFrameStrata("DIALOG")
	return window
end

----------
function ConfigBar_GUI:UpdateGlobalColors()
	for k, fs in pairs(FontStringsOrange) do
		fs:SetTextColor(unpack(nibRealUI.media.colors.orange))
	end
	for k, fs in pairs(FontStringsGreen) do
		fs:SetTextColor(unpack(nibRealUI.media.colors.green))
	end
	for k, fs in pairs(FontStringsBlue) do
		fs:SetTextColor(unpack(nibRealUI.media.colors.blue))
	end
	for k, tex in pairs(TexturesOrange) do
		tex:SetTexture(unpack(nibRealUI.media.colors.orange))
		local alpha = tex:GetAlpha()
		tex:SetAlpha(alpha)
	end
end

function ConfigBar_GUI:OnInitialize()
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char
end