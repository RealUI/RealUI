local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local db, ndbg

local MODNAME = "UIScaler"
local UIScaler = RealUI:NewModule(MODNAME, "AceEvent-3.0")

function RealUI:PrintScreenSize()
    _G.print("The current screen resolution is", ({_G.GetScreenResolutions()})[_G.GetCurrentResolution()])
    _G.print("The current screen size is", _G.floor(_G.GetScreenWidth()+0.5), "x", _G.floor(_G.GetScreenHeight()+0.5))
end

-- UI Scaler
function UIScaler:UpdateUIScale()
    if self.uiScaleChanging then return end
    self.uiScaleChanging = true

    -- Get Scale
    local scale
    if db.pixelPerfect then
        local _, height = RealUI:GetResolutionVals(true)
        scale = 768 / height
        db.customScale = scale
    else
        scale = db.customScale
    end
    if ndbg.tags.retinaDisplay.set then scale = scale * 2 end

    -- Set Scale (WoW CVar can't go below .64)
    UIScaler:debug("UpdateUIScale", scale, _G.GetCVar("uiScale"))
    if scale < .64 then
        _G.UIParent:SetScale(scale)
    elseif scale ~= _G.tonumber(_G.GetCVar("uiScale")) then
        UIScaler:debug("SetCVar", scale)
        _G.SetCVar("useUiScale", 1)
        _G.SetCVar("uiScale", scale)
    end
    self.uiScaleChanging = false
end

function UIScaler:PLAYER_ENTERING_WORLD()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")

    self:RegisterEvent("VARIABLES_LOADED", "UpdateUIScale")
    self:RegisterEvent("UI_SCALE_CHANGED", "UpdateUIScale")

    self:UpdateUIScale()
end

function UIScaler:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            pixelPerfect = true,
            customScale = 1,
        }
    })
    db = self.db.profile
    ndbg = RealUI.db.global
    
    -- Keep WoW UI Scale slider hidden and replace with RealUI button
    _G["Advanced_UseUIScale"]:Hide()
    _G["Advanced_UIScaleSlider"]:Hide()

    local scaleBtn = _G.CreateFrame("Button", "RealUIScaleBtn", _G.Advanced_, "UIPanelButtonTemplate") --RealUI:CreateTextButton("RealUI UI Scaler", _G["Advanced_UIScaleSlider"]:GetParent(), 200, 24)
    scaleBtn:SetSize(200, 24)
    scaleBtn:SetText("RealUI UI Scaler")
    scaleBtn:SetPoint("TOPLEFT", _G.Advanced_UIScaleSlider, 20, 0)
    scaleBtn:SetScript("OnClick", function() RealUI:LoadConfig("RealUI", "skins") end)

    -- CVar "uiScale" doesn't exist until late in the loading process
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
