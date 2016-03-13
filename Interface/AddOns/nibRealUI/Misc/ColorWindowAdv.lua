local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

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

local CPFSwatchBG = _G.CreateFrame("Frame", nil, CPF)
CPFSwatchBG:SetSize(48, 48)
CPFSwatchBG:SetPoint("TOPLEFT", _G.ColorPickerWheel, "TOPRIGHT", 87, 0)
for i = 1, 4 do
    local tex = CPFSwatchBG:CreateTexture(nil, "BACKGROUND", nil, 7)
    tex:SetTexture([[Tileset\Generic\Checkers]])
    tex:SetTexCoord(0.03125, 0.21875, 0.28125, 0.46875)
    tex:SetSize(24, 24)
    if i == 1 then
        tex:SetPoint("TOPLEFT", 0, 0)
    elseif i == 2 then
        tex:SetPoint("TOPRIGHT", 0, 0)
    elseif i == 3 then
        tex:SetPoint("BOTTOMLEFT", 0, 0)
    elseif i == 4 then
        tex:SetPoint("BOTTOMRIGHT", 0, 0)
    end
end
local CPFPrevSwatch = CPFSwatchBG:CreateTexture(nil, "BORDER", nil, 7)
CPFPrevSwatch:SetSize(32, 32)
CPFPrevSwatch:SetPoint("TOPRIGHT", CPFSwatchBG, "TOPRIGHT", 0, 0)

-- Copy
local red, green, blue, opacity
local CPFCopyButton = RealUI:CreateTextButton("Copy", CPF, 60, 22)
CPFCopyButton:SetPoint("TOP", CPFSwatchBG, "BOTTOM", 0, -5)
CPFCopyButton:SetScript("OnClick", function()
    red, green, blue = CPF:GetColorRGB()
    opacity = OSF:GetValue()
    
    CPFCopyButton:SetText(("|cff%02x%02x%02xCopy"):format(red * 255, green * 255, blue * 255))
end)

-- Paste
local CPFPasteButton = RealUI:CreateTextButton("Paste", CPF, 60, 22)
CPFPasteButton:SetPoint("TOP", CPFCopyButton, "BOTTOM", 0, -5)
CPFPasteButton:SetScript("OnClick", function()
    CPF:SetColorRGB(red, green, blue)
    OSF:SetValue(opacity)
end)

-- Saturation slider.
local UpdateCPFHSV = function(self)
    local s = self:GetValue()
    local h, _, v = CPF:GetColorHSV()
    --print("UpdateCPFHSV", h, s, v)
    CPF:SetColorHSV(h, s, v)
end

local CPFSaturation = _G.CreateFrame("Slider", "CWA_SatSlider", CPF, "OptionsSliderTemplate")
CPFSaturation:SetMinMaxValues(0, 1)
CPFSaturation:SetValueStep(.05)
CPFSaturation:SetOrientation("VERTICAL")
CPFSaturation:SetThumbTexture([[Interface\Buttons\UI-SliderBar-Button-Vertical]])
CPFSaturation:SetHeight(OSF:GetHeight())
CPFSaturation:SetWidth(OSF:GetWidth())
CPFSaturation:SetPoint("TOPRIGHT", CPFSwatchBG, "TOPLEFT", -12, 0)
_G["CWA_SatSliderLow"]:ClearAllPoints()
_G["CWA_SatSliderHigh"]:ClearAllPoints()
_G["CWA_SatSliderText"]:ClearAllPoints()
CPFSaturation:SetScript("OnValueChanged", UpdateCPFHSV)


local CPFEditBoxes = {
    Red = 0,
    Green = 1,
    Blue = 2,
    Hex = 3,
    Alpha = 4,
}

local UpdateCPFRGB = function(editbox)
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
    CPFEditBoxes.Hex:SetText(("%02x%02x%02x"):format(r * 255, g * 255, b * 255))

    if CPF.hasOpacity then
        CPFEditBoxes.Alpha:SetText(("%d"):format((1 - a) * 100))
        _G.ColorSwatch:SetTexture(r, g, b, 1 - a)
    end
end

for type, offsetFactor in next, CPFEditBoxes do
    local editbox = _G.CreateFrame("EditBox", nil, CPF)
    editbox:SetHeight(15)
    editbox:SetWidth(50)
    editbox:SetPoint("BOTTOMLEFT", _G.ColorPickerOkayButton, "TOPLEFT", ((70 * offsetFactor) + 10), 5)
    
    editbox:SetBackdrop({
        bgFile = [[Interface\ChatFrame\ChatFrameBackground]], 
    })
    editbox:SetBackdropColor(0, 0, 0, .5)
    
    editbox:SetFontObject(_G.ChatFontNormal)
    editbox:SetAutoFocus(false)
    editbox:SetJustifyH("CENTER")
    
    editbox:SetScript("OnEscapePressed", function(self) self:ClearFocus() end)
    editbox:SetScript("OnEnterPressed", function(self) 
        UpdateCPFRGB(self)
        self:ClearFocus() 
    end)
    editbox:SetScript("OnEditFocusGained", function(self)
        self:HighlightText(0, self:GetNumLetters())
    end)
    editbox:SetScript("OnEditFocusLost", function(self)
        self:HighlightText(self:GetNumLetters())
    end)
    
    local title = editbox:CreateFontString(nil, "OVERLAY", "GameFontNormalSmall")
    title:SetPoint("RIGHT", editbox, "LEFT", 0, 0)
    if type == "Hex" then
        editbox:SetMaxLetters(6)
        title:SetText("#")
    else
        editbox:SetMaxLetters(3)
        title:SetText(type:match("^%S"))
    end
    
    CPFEditBoxes[type] = editbox
end

-- Move widgets --

-- Script Hooks --
CPF:HookScript("OnShow", function(self)
    --print("CPF:OnShow")
    if _G.Aurora then
        local F = _G.Aurora[1]
        F.Reskin(CPFCopyButton)
        F.Reskin(CPFPasteButton)
        --F.ReskinSlider(CPFSaturation)
    end
    if not CPF.moved then
        _G.ColorPickerFrameHeader:ClearAllPoints()
        _G.ColorPickerFrameHeader:SetPoint("TOP", CPF, "TOP", 0, 11)

        _G.ColorPickerWheel:ClearAllPoints()
        _G.ColorPickerWheel:SetPoint("TOPLEFT", CPF, "TOPLEFT", 5, -18)

        local ColorValue = _G.select(6, CPF:GetRegions())
        ColorValue:ClearAllPoints()
        ColorValue:SetPoint("LEFT", _G.ColorPickerWheel, "RIGHT", 13, 0)

        _G.ColorSwatch:ClearAllPoints()
        _G.ColorSwatch:SetPoint("BOTTOMLEFT", CPFSwatchBG, "BOTTOMLEFT", 0, 0)
        _G.ColorSwatch:SetParent(CPFSwatchBG)

        OSF:ClearAllPoints()
        OSF:SetPoint("TOPRIGHT", CPF, "TOPRIGHT", -25, -18)

        _G.ColorPickerOkayButton:ClearAllPoints()
        _G.ColorPickerOkayButton:SetPoint("BOTTOMLEFT", CPF, "BOTTOMLEFT", 5, 5)
        _G.ColorPickerOkayButton:SetWidth(100)
        _G.ColorPickerCancelButton:ClearAllPoints()
        _G.ColorPickerCancelButton:SetPoint("BOTTOMRIGHT", CPF, "BOTTOMRIGHT", -5, 5)
        _G.ColorPickerCancelButton:SetWidth(100)
        CPF.moved = true
    end
    local r, g, b = self:GetColorRGB()
    if self.hasOpacity then
        CPFPrevSwatch:SetTexture(r, g, b, 1 - OSF:GetValue())
        CPFEditBoxes.Alpha:Show()
        self:SetSize(350, 200)
    else
        CPFPrevSwatch:SetTexture(r, g, b, 1)
        CPFEditBoxes.Alpha:Hide()
        self:SetSize(280, 200)
    end

    UpdateRGBA()
end)
CPF:HookScript("OnColorSelect", UpdateRGBA)
OSF:HookScript("OnShow", UpdateRGBA)
OSF:HookScript("OnValueChanged", UpdateRGBA)
