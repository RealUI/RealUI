local _, private = ...

-- [[ Lua Globals ]]
-- luacheck: globals next tonumber

-- [[ Core ]]
local Aurora = private.Aurora
local Hook, Skin = Aurora.Hook, Aurora.Skin
local Color = Aurora.Color

local storedColor = Color.Create(1, 1, 1, 1)
local pickedColor = Color.Create(1, 1, 1, 1)

local UpdateColor, UpdateEditBoxes do
    function UpdateEditBoxes(red, green, blue, alpha)
        if red and green and blue then
            -- Set from color
            for index = 1, #_G.ColorPickerFrame.editBoxes do
                local editbox = _G.ColorPickerFrame.editBoxes[index]
                if editbox.type == "hex" then
                    editbox:SetText(("%02x%02x%02x"):format(red * 255, green * 255, blue * 255))
                elseif editbox.type == "red" then
                    editbox:SetText(red * 255)
                elseif editbox.type == "green" then
                    editbox:SetText(green * 255)
                elseif editbox.type == "blue" then
                    editbox:SetText(blue * 255)
                end

                if editbox.type == "alpha" then
                    if alpha then
                        editbox:SetText(("%d"):format(alpha * 100))
                        editbox:Show()
                    else
                        editbox:Hide()
                    end
                end
            end
        else
            -- Set color to
            for index = 1, #_G.ColorPickerFrame.editBoxes do
                local editbox = _G.ColorPickerFrame.editBoxes[index]
                if editbox.type == "hex" then
                    local rgb = editbox:GetText()
                    red, green, blue = tonumber("0x"..rgb:sub(0, 2)), tonumber("0x"..rgb:sub(3, 4)), tonumber("0x"..rgb:sub(5, 6))
                elseif editbox.type == "red" then
                    red = tonumber(editbox:GetText())
                elseif editbox.type == "green" then
                    green = tonumber(editbox:GetText())
                elseif editbox.type == "blue" then
                    blue = tonumber(editbox:GetText())
                end

                if editbox.type == "alpha" then
                    if alpha then
                        local a = tonumber(editbox:GetText())
                        alpha = a and a / 100
                        editbox:Show()
                    else
                        alpha = nil
                        editbox:Hide()
                    end
                end
            end

            UpdateColor(red, green, blue, alpha)
        end
    end

    local settingColor
    function UpdateColor(red, green, blue, alpha)
        if red and green and blue then
            if settingColor then return end
            settingColor = true
            -- Set to color
            _G.ColorPickerFrame:SetColorRGB(red, green, blue)

            if alpha then
                _G.OpacitySliderFrame:SetValue(1 - alpha)
            end
            settingColor = false
        else
            red, green, blue = _G.ColorPickerFrame:GetColorRGB()

            if _G.ColorPickerFrame.hasOpacity then
                alpha = 1 - _G.OpacitySliderFrame:GetValue()
            else
                alpha = nil
            end

            local _, saturation = _G.ColorPickerFrame:GetColorHSV()
            _G.ColorPickerFrame.saturation:SetValue(1 - saturation)

            UpdateEditBoxes(red, green, blue, alpha)
        end

        pickedColor:SetRGBA(red, green, blue, alpha or 1)
        _G.ColorSwatch:SetColorTexture(red, green, blue, alpha or 1)
    end
end

do --[[ FrameXML\ColorPickerFrame.lua ]]
    function Hook.UpdateColor(self)
        UpdateColor()
    end
    function Hook.ColorPickerFrame_UpdateDisplay(self)
        if self.hasOpacity then
            _G.OpacitySliderFrame:Show();
            _G.OpacitySliderFrame:SetValue(self.opacity);
            self:SetWidth(365)
            --CPF:SetWidth(350)
        else
            _G.OpacitySliderFrame:Hide();
            self:SetWidth(309)
            --CPF:SetWidth(280)
        end

        UpdateColor()
        self.prevSwatch:SetColorTexture(pickedColor:GetRGBA())
    end
    Hook.ColorPickerFrame_OnColorSelect = Hook.UpdateColor
    Hook.OpacitySliderFrame_OnShow = Hook.UpdateColor
    Hook.OpacitySliderFrame_OnValueChanged = Hook.UpdateColor
end

-- do --[[ FrameXML\ColorPickerFrame.xml ]]
-- end

_G.hooksecurefunc(private.FrameXML, "ColorPickerFrame", function()
    local ColorPickerFrame = _G.ColorPickerFrame
    ColorPickerFrame:SetHeight(230)
    ColorPickerFrame:HookScript("OnColorSelect", Hook.ColorPickerFrame_OnColorSelect)
    local bg = ColorPickerFrame.Border:GetBackdropTexture("bg")

    local Header = ColorPickerFrame.Header
    Header:ClearAllPoints()
    Header:SetPoint("TOPLEFT", bg)
    Header:SetPoint("BOTTOMRIGHT", bg, "TOPRIGHT", 0, -private.FRAME_TITLE_HEIGHT)
    Header.Text:SetAllPoints()

    _G.ColorPickerWheel:SetPoint("TOPLEFT", bg, 16, -(private.FRAME_TITLE_HEIGHT + 5))

    local ColorValue = ColorPickerFrame:GetColorValueTexture()
    ColorValue:SetPoint("LEFT", _G.ColorPickerWheel, "RIGHT", 13, 0)

    local OpacitySliderFrame = _G.OpacitySliderFrame
    OpacitySliderFrame:ClearAllPoints()
    OpacitySliderFrame:SetPoint("TOPRIGHT", bg, -30, -30)
    OpacitySliderFrame:HookScript("OnShow", Hook.OpacitySliderFrame_OnShow)
    OpacitySliderFrame:HookScript("OnValueChanged", Hook.OpacitySliderFrame_OnValueChanged)

    local swatchBG = ColorPickerFrame:CreateTexture(nil, "BORDER", nil, -8)
    swatchBG:SetTexture([[Interface\InventoryItems\NOART]])
    swatchBG:SetTexCoord(0, 0.03125, 0, 0.03125)
    swatchBG:SetSize(48, 48)
    swatchBG:SetPoint("TOPLEFT", _G.ColorPickerWheel, "TOPRIGHT", 87, 0)
    swatchBG:SetHorizTile(true)
    swatchBG:SetVertTile(true)
    swatchBG:SetDesaturated(true)

    _G.ColorSwatch:ClearAllPoints()
    _G.ColorSwatch:SetPoint("BOTTOMLEFT", swatchBG, "BOTTOMLEFT", 0, 0)

    local prevSwatch = ColorPickerFrame:CreateTexture(nil, "ARTWORK", nil, -3)
    prevSwatch:SetSize(32, 32)
    prevSwatch:SetPoint("TOPRIGHT", swatchBG, "TOPRIGHT", 0, 0)
    ColorPickerFrame.prevSwatch = prevSwatch

    do -- Saturation
        local saturation = _G.CreateFrame("Slider", nil, ColorPickerFrame, "OptionsSliderTemplate")
        Skin.OpacitySlider(saturation)
        saturation:SetMinMaxValues(0, 1)
        saturation:SetValueStep(.01)
        saturation:SetOrientation("VERTICAL")
        saturation:SetSize(OpacitySliderFrame:GetSize())
        saturation:SetPoint("TOP", OpacitySliderFrame)
        saturation:SetPoint("BOTTOM", OpacitySliderFrame)
        saturation:SetPoint("RIGHT", swatchBG, "LEFT", -12, 0)
        saturation.Text:ClearAllPoints()
        saturation.Low:ClearAllPoints()
        saturation.High:ClearAllPoints()
        saturation:SetScript("OnValueChanged", function(self)
            local s = self:GetValue()
            local h, _, v = ColorPickerFrame:GetColorHSV()
            ColorPickerFrame:SetColorHSV(h % 360, 1 - s, v)
        end)
        ColorPickerFrame.saturation = saturation
    end

    do -- Copy / Paste
        local copy = _G.CreateFrame("Button", nil, ColorPickerFrame, "UIPanelButtonTemplate")
        Skin.UIPanelButtonTemplate(copy)
        copy:SetPoint("TOP", swatchBG, "BOTTOM", 0, -5)
        copy:SetSize(60, 22)
        copy:SetText(_G.CALENDAR_COPY_EVENT)
        copy:SetScript("OnClick", function(self)
            storedColor:SetRGBA(pickedColor:GetRGBA())
        end)
        copy:SetScript("OnEnter", function(self)
            _G.GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            _G.GameTooltip_SetTitle(_G.GameTooltip, _G.COLOR)
            _G.GameTooltip_AddColoredLine(_G.GameTooltip, pickedColor.colorStr, pickedColor)
            _G.GameTooltip:Show()
        end)
        copy:SetScript("OnLeave", _G.GameTooltip_Hide)

        local paste = _G.CreateFrame("Button", nil, ColorPickerFrame, "UIPanelButtonTemplate")
        Skin.UIPanelButtonTemplate(paste)
        paste:SetPoint("TOP", copy, "BOTTOM", 0, -5)
        paste:SetSize(60, 22)
        paste:SetText(_G.CALENDAR_PASTE_EVENT)
        paste:SetScript("OnClick", function(self)
            UpdateColor(storedColor:GetRGBA())
        end)
        paste:SetScript("OnEnter", function(self)
            _G.GameTooltip:SetOwner(self, "ANCHOR_LEFT")
            _G.GameTooltip_SetTitle(_G.GameTooltip, _G.COLOR)
            _G.GameTooltip_AddColoredLine(_G.GameTooltip, storedColor.colorStr, storedColor)
            _G.GameTooltip:Show()
        end)
        paste:SetScript("OnLeave", _G.GameTooltip_Hide)
    end

    local editBoxes = {
        "red",
        "green",
        "blue",
        "hex",
        "alpha",
    }
    for index = 1, #editBoxes do
        local editbox = _G.CreateFrame("EditBox", nil, ColorPickerFrame, "InputBoxTemplate")
        editbox:SetAutoFocus(false)
        editbox:SetScript("OnEnterPressed", function(self)
            UpdateEditBoxes()
            self:ClearFocus()
        end)

        local title = editbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
        title:SetPoint("RIGHT", editbox, "LEFT", -5, 0)
        if index == 1 then
            editbox:SetPoint("BOTTOMLEFT", 30, 40)
        else
            editbox:SetPoint("BOTTOMLEFT", editBoxes[index - 1], "BOTTOMRIGHT", 35, 0)
        end

        editbox.type = editBoxes[index]
        if editbox.type == "hex" then
            editbox:SetSize(50, 15)
            editbox:SetMaxLetters(6)
            title:SetText("#")
        else
            editbox:SetSize(30, 15)
            editbox:SetMaxLetters(3)
            title:SetText(editbox.type:match("^%S"))
        end

        Skin.InputBoxTemplate(editbox)
        editBoxes[index] = editbox
    end
    ColorPickerFrame.editBoxes = editBoxes
end)
