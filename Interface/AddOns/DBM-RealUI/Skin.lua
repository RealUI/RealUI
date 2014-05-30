local skin = DBT:RegisterSkin("RealUI")

skin.defaults = {
    Skin = "RealUI",
    Template = "RealUISkinTimerTemplate",
    Texture = "Interface\\AddOns\\DBM-RealUI\\media\\Plain.tga",
    FillUpBars = false,
    IconLocked = false,

    Font = "", --If this has any set font it will override the XML font template, so it needs to be blank.
    FontSize = 8,

    StartColorR = 1,
    StartColorG = 0.8,
    StartColorB = 0,
    EndColorR = 1,
    EndColorG = 0.1,
    EndColorB = 0,

    Width = 185,
    Height = 10,
    Scale = 1,
    TimerPoint = "TOP",
    TimerX = 281.5,
    TimerY = -135,
    BarYOffset = 9,

    HugeWidth = 185,
    HugeScale = 1,
    HugeTimerPoint = "TOP",
    HugeTimerX = -249,
    HugeTimerY = -134.5,
    HugeBarYOffset = 9,
}

local skins = DBM.Bars:GetSkins()
if skins[skin.defaults.Skin].loaded == nil then
    --only set the skin if it isn't loaded.
    DBM.Bars:SetSkin("RealUI")
end

---- DBM Defaults ----
--[[options = { 
    Skin = "DefaultSkin",
    Template = "DBTBarTemplate",
    Texture = "Interface\\AddOns\\DBM-DefaultSkin\\textures\\default.tga",
    IconLeft = true,
    IconRight = false,
    Style = "DBM",
    Flash = true,
    Spark = true,
    FillUpBars = true,
    ExpandUpwards = false,
    ClickThrough = false,
    IconLocked = true, --When true, the icon hieght will be locked to the hieght of the bar.

    Font = STANDARD_TEXT_FONT,
    FontSize = 10,
    TextColorR = 1,
    TextColorG = 1,
    TextColorB = 1,

    DynamicColor = true,
    StartColorR = 1,
    StartColorG = 0.7,
    StartColorB = 0,
    EndColorR = 1,
    EndColorG = 0,
    EndColorB = 0,

    Width = 183,
    Height = 20,
    Scale = 0.9,
    TimerPoint = "TOPRIGHT",
    TimerX = -223,
    TimerY = -260,
    BarXOffset = 0,
    BarYOffset = 0,

    HugeBarsEnabled = true,
    HugeWidth = 200,
    HugeScale = 1.03,
    HugeTimerPoint = "CENTER",
    HugeTimerX = 0,
    HugeTimerY = -120,
    HugeBarXOffset = 0,
    HugeBarYOffset = 0,
    EnlargeBarsTime = 8,
    EnlargeBarsPercent = 0.125,
}]]--
