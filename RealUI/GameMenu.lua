local _, private = ...
local Aurora = _G.Aurora
local RealUI = private.RealUI

local realUINewMarkerDismissed = false

local function GetRealUIMenuLabel()
    local L = RealUI and RealUI.L
    if L and L["Start_Config"] then
        return L["Start_Config"]
    end
    return "RealUI"
end

local function AddRealUIButton(menu)
    if not menu or not menu.buttonPool or not menu.AddButton then return end

    local label = GetRealUIMenuLabel()

    -- Avoid duplicates in case another addon/hook runs too.
    for button in menu.buttonPool:EnumerateActive() do
        if button.GetText and button:GetText() == label then
            return
        end
    end

    local button = menu:AddButton(label, function()
        realUINewMarkerDismissed = true
        if menu.RealUINewFeatureLabel then
            menu.RealUINewFeatureLabel:Hide()
        end
        if _G.PlaySound and _G.SOUNDKIT then
            _G.PlaySound(_G.SOUNDKIT.IG_MAINMENU_OPTION)
        end
        _G.HideUIPanel(menu)
        if RealUI and RealUI.LoadConfig then
            RealUI.LoadConfig("HuD")
        end
    end)

    if button and not menu.RealUINewFeatureLabel then
        menu.RealUINewFeatureLabel = _G.CreateFrame("Frame", nil, button, "NewFeatureLabelTemplate")
        menu.RealUINewFeatureLabel:SetScale(0.8)
        if menu.RealUINewFeatureLabel.EnableMouse then
            menu.RealUINewFeatureLabel:EnableMouse(false)
        end
    end

    if button and menu.RealUINewFeatureLabel then
        menu.RealUINewFeatureLabel:SetParent(button)
        if button.GetFrameLevel and menu.RealUINewFeatureLabel.SetFrameLevel then
            menu.RealUINewFeatureLabel:SetFrameLevel((button:GetFrameLevel() or 0) + 10)
        end
        menu.RealUINewFeatureLabel:ClearAllPoints()
        local fs = button.GetFontString and button:GetFontString() or nil
        if fs then
            menu.RealUINewFeatureLabel:SetPoint("RIGHT", fs, "LEFT", -20, 10)
        else
            menu.RealUINewFeatureLabel:SetPoint("LEFT", button, "LEFT", 20, 10)
        end

        if realUINewMarkerDismissed then
            menu.RealUINewFeatureLabel:Hide()
        else
            menu.RealUINewFeatureLabel:Show()
        end
    end

    if Aurora and Aurora.Hook and Aurora.Hook.GameMenuInitButtons then
        Aurora.Hook.GameMenuInitButtons(menu)
    end
end

local function HookGameMenu()
    if not _G.GameMenuFrame then return end
    local frame = _G.GameMenuFrame

    if frame.InitButtons then
        _G.hooksecurefunc(frame, "InitButtons", function() AddRealUIButton(frame) end)
    end
end

if _G.GameMenuFrame then
    HookGameMenu()
else
    local init = _G.CreateFrame("Frame")
    init:RegisterEvent("ADDON_LOADED")
    init:SetScript("OnEvent", function(self, _, addonName)
        if addonName == "Blizzard_GameMenu" and _G.GameMenuFrame then
            HookGameMenu()
            self:UnregisterEvent("ADDON_LOADED")
        end
    end)
end
