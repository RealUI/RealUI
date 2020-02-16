local _, private = ...

-- Lua Globals --
local next = _G.next

-- Libs --
local Aurora = _G.Aurora
local Skin = Aurora.Skin
local Color = Aurora.Color

-- RealUI --
local RealUI = private.RealUI

local CPF, OSF = _G.ColorPickerFrame, _G.OpacitySliderFrame

-- Enable move
local CPFMover = _G.CreateFrame("Frame", nil, CPF)
CPFMover:SetPoint("TOPLEFT", CPF, "TOP", -60, 0)
CPFMover:SetPoint("BOTTOMRIGHT", CPF, "TOP", 60, -15)
CPFMover:EnableMouse(true)
CPFMover:SetScript("OnMouseDown", function() CPF:StartMoving() end)
CPFMover:SetScript("OnMouseUp", function() CPF:StopMovingOrSizing() end)
CPF:SetUserPlaced(true)
CPF:EnableKeyboard(false)

CPF.swatchBG = CPF:CreateTexture(nil, "BORDER", nil, -8)
CPF.swatchBG:SetTexture([[Interface\InventoryItems\NOART]])
CPF.swatchBG:SetTexCoord(0, 0.03125, 0, 0.03125)
CPF.swatchBG:SetSize(48, 48)
CPF.swatchBG:SetPoint("TOPLEFT", _G.ColorPickerWheel, "TOPRIGHT", 87, 0)
CPF.swatchBG:SetHorizTile(true)
CPF.swatchBG:SetVertTile(true)
CPF.swatchBG:SetDesaturated(true)

CPF.prevSwatch = CPF:CreateTexture(nil, "ARTWORK", nil, -3)
CPF.prevSwatch:SetSize(32, 32)
CPF.prevSwatch:SetPoint("TOPRIGHT", CPF.swatchBG, "TOPRIGHT", 0, 0)

-- Copy
local red, green, blue, opacity
local CPFCopyButton = _G.CreateFrame("Button", nil, CPF, "UIPanelButtonTemplate")
Skin.UIPanelButtonTemplate(CPFCopyButton)
CPFCopyButton:SetPoint("TOP", CPF.swatchBG, "BOTTOM", 0, -5)
CPFCopyButton:SetSize(60, 22)
CPFCopyButton:SetText(_G.CALENDAR_COPY_EVENT)
CPFCopyButton:SetScript("OnClick", function()
    red, green, blue = CPF:GetColorRGB()
    opacity = OSF:GetValue()

    CPFCopyButton:SetFormattedText("|c%sCopy", RealUI.GetColorString(red, blue, green))
end)
RealUI:RegisterSkinnedFrame(CPFCopyButton, Color.button)

-- Paste
local CPFPasteButton = _G.CreateFrame("Button", nil, CPF, "UIPanelButtonTemplate")
Skin.UIPanelButtonTemplate(CPFPasteButton)
CPFPasteButton:SetPoint("TOP", CPFCopyButton, "BOTTOM", 0, -5)
CPFPasteButton:SetSize(60, 22)
CPFPasteButton:SetText(_G.CALENDAR_PASTE_EVENT)
CPFPasteButton:SetScript("OnClick", function()
    CPF:SetColorRGB(red, green, blue)
    OSF:SetValue(opacity)
end)
RealUI:RegisterSkinnedFrame(CPFPasteButton, Color.button)

-- Saturation slider.
-- /dump ColorPickerFrame:GetColorHSV()
-- /dump ColorPickerFrame:GetColorRGB()
local CPFSaturation = _G.CreateFrame("Slider", "CWA_SatSlider", CPF, "OptionsSliderTemplate")
Skin.OptionsSliderTemplate(CPFSaturation)
CPFSaturation:SetMinMaxValues(0, 1)
CPFSaturation:SetValueStep(.05)
CPFSaturation:SetOrientation("VERTICAL")
CPFSaturation:GetThumbTexture():SetSize(16, 8)
CPFSaturation:SetHeight(OSF:GetHeight())
CPFSaturation:SetWidth(OSF:GetWidth())
CPFSaturation:SetPoint("TOPRIGHT", CPF.swatchBG, "TOPLEFT", -12, 0)
_G["CWA_SatSliderLow"]:ClearAllPoints()
_G["CWA_SatSliderHigh"]:ClearAllPoints()
_G["CWA_SatSliderText"]:ClearAllPoints()
CPFSaturation:SetScript("OnValueChanged", function(self)
    local s = self:GetValue()
    local h, _, v = CPF:GetColorHSV()
    CPF:SetColorHSV(h % 360, s, v)
end)
local satThumb = CPFSaturation._auroraThumb
RealUI:RegisterSkinnedFrame(satThumb, Color.button)
RealUI:RegisterSkinnedFrame(satThumb:GetParent(), Color.frame)

RealUI:RegisterSkinnedFrame(_G.ColorPickerOkayButton, Color.button)
RealUI:RegisterSkinnedFrame(_G.ColorPickerCancelButton, Color.button)

local CPFEditBoxes = {
    Red = 0,
    Green = 1,
    Blue = 2,
    Hex = 3,
    Alpha = 4,
}

local updateRGB = false
local UpdateCPFRGB = function(editbox)
    updateRGB = true
    local r, g, b
    if #editbox:GetText() == 6 then
        local rgb = editbox:GetText()
        r, g, b = _G.tonumber("0x"..rgb:sub(0, 2)), _G.tonumber("0x"..rgb:sub(3, 4)), _G.tonumber("0x"..rgb:sub(5, 6))
    else
        r, g, b = _G.tonumber(CPFEditBoxes.Red:GetText()), _G.tonumber(CPFEditBoxes.Green:GetText()), _G.tonumber(CPFEditBoxes.Blue:GetText())
    end
    local a = _G.tonumber(CPFEditBoxes.Alpha:GetText())
    --print("UpdateCPFRGB", r, g, b, a)
    if r and g and b then
        if r <= 1 and g <= 1 and b <= 1 then
            CPF:SetColorRGB(r, g, b)
        else
            CPF:SetColorRGB(r / 255, g / 255, b / 255)
        end
    else
        _G.print("Error converting fields to numbers. Please check the values.")
    end

    OSF:SetValue(1 - (a / 100))
    updateRGB = false
end

local UpdateRGBA = function()
    local r, g, b = CPF:GetColorRGB()
    local a = OSF:GetValue()
    local _, s = CPF:GetColorHSV()
    CPFSaturation:SetValue(s)
    --print("UpdateRGBA", r, b, g, 1 - a)

    CPFEditBoxes.Red:SetText(r * 255)
    CPFEditBoxes.Green:SetText(g * 255)
    CPFEditBoxes.Blue:SetText(b * 255)
    CPFEditBoxes.Hex:SetFormattedText("%02x%02x%02x", r * 255, g * 255, b * 255)

    if CPF.hasOpacity then
        _G.ColorSwatch:SetColorTexture(r, g, b, 1 - OSF:GetValue())
        CPFEditBoxes.Alpha:SetText(("%d"):format((1 - a) * 100))
        CPFEditBoxes.Alpha:Show()
        CPF:SetWidth(350)
    else
        CPFEditBoxes.Alpha:Hide()
        CPF:SetWidth(280)
    end
end

for type, offsetFactor in next, CPFEditBoxes do
    local editbox = _G.CreateFrame("EditBox", nil, CPF, "InputBoxTemplate")
    Skin.InputBoxTemplate(editbox)
    editbox:SetSize(50, 15)
    editbox:SetPoint("BOTTOMLEFT", (70 * offsetFactor) + 13, 34)
    editbox:SetAutoFocus(false)

    editbox:SetScript("OnEnterPressed", function(self)
        UpdateCPFRGB(self)
        self:ClearFocus()
    end)

    local title = editbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("RIGHT", editbox, "LEFT", -5, 0)
    if type == "Hex" then
        editbox:SetMaxLetters(6)
        title:SetText("#")
    else
        editbox:SetMaxLetters(3)
        title:SetText(type:match("^%S"))
    end

    CPFEditBoxes[type] = editbox
end

-- Script Hooks --
local function UpdateColors(hasOpacity, r, g, b)
    if hasOpacity then
        CPF.prevSwatch:SetColorTexture(r, g, b, 1 - OSF:GetValue())
    else
        CPF.prevSwatch:SetColorTexture(r, g, b, 1)
    end
    UpdateRGBA()
end

_G.hooksecurefunc(CPF, "SetColorRGB", function(self, r, g, b)
    -- This hook is for updating the frame with out it being hidden first.
    -- eg. Clicking on multiple swatches in the chat config without closing closing the frame.
    if not updateRGB then
        UpdateColors(self.hasOpacity, self:GetColorRGB())
    end
end)
CPF:HookScript("OnShow", function(self)
    --print("CPF:OnShow")
    if not CPF.moved then
        _G.ColorSwatch:ClearAllPoints()
        _G.ColorSwatch:SetPoint("BOTTOMLEFT", CPF.swatchBG, "BOTTOMLEFT", 0, 0)
        CPF:SetHeight(210)

        CPF.moved = true
    end
    UpdateColors(self.hasOpacity, self:GetColorRGB())
end)
CPF:HookScript("OnColorSelect", UpdateRGBA)
OSF:HookScript("OnShow", UpdateRGBA)
OSF:HookScript("OnValueChanged", UpdateRGBA)
