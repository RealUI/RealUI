local _, private = ...

-- Lua Globals --
local tonumber, tostring = _G.tonumber, _G.tostring

-- RealUI --
local RealUI = private.RealUI
local round = RealUI.Round
local db, ndbg

local MODNAME = "UIScaler"
local UIScaler = RealUI:NewModule(MODNAME, "AceEvent-3.0")

function RealUI:PrintScreenSize()
    _G.print(("The current screen resolution is %dx%d"):format(RealUI:GetResolutionVals(true)))
    _G.print(("The current screen size is %dx%d"):format(_G.floor(_G.GetScreenWidth()+0.5), _G.floor(_G.GetScreenHeight()+0.5)))
end
function RealUI:GetUIScale()
    return tonumber(db.customScale), ndbg.tags.retinaDisplay.set
end

-- UI Scaler
function UIScaler:UpdateUIScale(newScale)
    if self.uiScaleChanging then return end

    -- Get Scale
    local oldScale = tonumber(db.customScale)
    if db.pixelPerfect then
        local _, height = RealUI:GetResolutionVals(true)
        UIScaler:debug("raw size", _, height)
        newScale = 768 / height
    end

    local cvarScale, parentScale = tonumber(_G.GetCVar("uiscale")), round(_G.UIParent:GetScale(), 2)
    UIScaler:debug("Current scale", oldScale, cvarScale, parentScale)

    if not newScale then
        newScale = _G.min(cvarScale, parentScale)
    end
    UIScaler:debug("newScale", newScale)

    if oldScale ~= newScale then
        self.uiScaleChanging = true
        -- Set Scale (WoW CVar can't go below .64)
        local uiScale = newScale * (ndbg.tags.retinaDisplay.set and 2 or 1)
        if cvarScale ~= uiScale then
            --[[ Setting the `uiScale` cvar will taint the ObjectiveTracker, and by extention the
                WorldMap and map action button. As such, we only use that if we absolutly have to.]]
            _G.SetCVar("uiScale", _G.max(uiScale, 0.64))
        end
        if parentScale ~= uiScale then
            _G.UIParent:SetScale(uiScale)
        end
        db.customScale = tostring(newScale)
        self.uiScaleChanging = false
    end
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
            customScale = "1",
        }
    })
    db = self.db.profile
    ndbg = RealUI.db.global

    if _G.type(db.customScale) ~= "string" then
        db.customScale = tostring(round(db.customScale), 2)
    end

    -- Keep WoW UI Scale slider hidden and replace with RealUI button
    _G["Advanced_UseUIScale"]:Hide()
    _G["Advanced_UIScaleSlider"]:Hide()

    local scaleBtn = _G.CreateFrame("Button", "RealUIScaleBtn", _G.Advanced_, "UIPanelButtonTemplate")
    scaleBtn:SetSize(200, 24)
    scaleBtn:SetText("RealUI UI Scaler")
    scaleBtn:SetPoint("TOPLEFT", _G.Advanced_UIScaleSlider, 20, 0)
    scaleBtn:SetScript("OnClick", function()
        RealUI.Debug("Config", "UI Scale")
        RealUI:LoadConfig("RealUI", "skins")
    end)

    -- CVar "uiScale" doesn't exist until late in the loading process
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
