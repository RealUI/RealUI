local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndb, ndbg

local MODNAME = "UIScaler"
local UIScaler = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Options
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "UI Scaler",
        desc = "Control the scale of the UI.",
        arg = MODNAME,
        order = 9107,
        args = {
            header = {
                type = "header",
                name = "UI Scaler",
                order = 10,
            },
            desc1 = {
                type = "description",
                name = "Control the scale of the UI.",
                fontSize = "medium",
                order = 20,
            },
            gap1 = {
                name = " ",
                type = "description",
                order = 21,
            },
            pixelPerfect = {
                type = "toggle",
                name = "Pixel Perfect",
                desc = "Recommended: Automatically sets the scale of the UI so that UI elements appear pixel-perfect.",
                get = function() return db.pixelPerfect end,
                set = function(info, value) 
                    db.pixelPerfect = value
                    UIScaler:UpdateUIScale()
                end,
                order = 30,
            },
            retinaDisplay = {
                type = "toggle",
                name = "Retina Display",
                desc = "Warning: Only activate if on a really high-resolution display (such as a Retina display).\n\nDouble UI scaling so that UI elements are easier to see.",
                get = function() return ndbg.tags.retinaDisplay.set end,
                set = function(info, value) 
                    ndbg.tags.retinaDisplay.set = value
                    nibRealUI:ReloadUIDialog()
                end,
                order = 40,
            },
            customScale = {
                type = "input",
                name = "Custom "..UI_SCALE,
                desc = "Set a custom UI scale (0.48 to 1.00). Note: UI elements may lose their sharp appearance.",
                order = 50,
                disabled = function() return db.pixelPerfect end,
                get = function() return tostring(db.customScale) end,
                set = function(info, value) 
                    db.customScale = nibRealUI:ValidateOffset(tonumber(value), 0.48, 1)
                    UIScaler:UpdateUIScale()
                end,
            },

        },
    };
    end
    return options
end

function PrintScreenSize()
    print("The current screen resolution is", ({GetScreenResolutions()})[GetCurrentResolution()])
    print("The current screen size is", floor(GetScreenWidth()), "x", floor(GetScreenHeight()))
end

-- UI Scaler
local ScaleOptionsHidden
function UIScaler:UpdateUIScale()
    if self.uiScaleChanging then return end
    self.uiScaleChanging = true

    -- Get Scale
    local scale
    if db.pixelPerfect then 
        scale = 768 / string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
        db.customScale = scale
    else
        scale = db.customScale
    end
    if ndbg.tags.retinaDisplay.set then scale = scale * 2 end

    -- Set Scale (WoW CVar can't go below .64)
    --print("UpdateUIScale", scale, GetCVar("uiScale"))
    if scale < .64 then
        UIParent:SetScale(scale)
    elseif scale ~= tonumber(GetCVar("uiScale")) then
        --print("SetCVar", scale)
        SetCVar("useUiScale", 1)
        SetCVar("uiScale", scale)
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
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            pixelPerfect = true,
            customScale = 1,
        }
    })
    db = self.db.profile
    ndb = nibRealUI.db.profile
    ndbg = nibRealUI.db.global

    nibRealUI:RegisterPlainOptions(MODNAME, GetOptions)
    
    -- Keep WoW UI Scale slider hidden and replace with RealUI button
    _G["Advanced_UseUIScale"]:Hide()
    _G["Advanced_UIScaleSlider"]:Hide()

    local scaleBtn = CreateFrame("Button", "RealUIScaleBtn", Advanced_, "UIPanelButtonTemplate") --nibRealUI:CreateTextButton("RealUI UI Scaler", _G["Advanced_UIScaleSlider"]:GetParent(), 200, 24)
    scaleBtn:SetSize(200, 24)
    scaleBtn:SetText("RealUI UI Scaler")
    scaleBtn:SetPoint("TOPLEFT", Advanced_UIScaleSlider, 20, 0)
    scaleBtn:SetScript("OnClick", function() nibRealUI:LoadConfig("nibRealUI", "UIScaler") end)

    -- CVar "uiScale" doesn't exist until late in the loading process
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
end
