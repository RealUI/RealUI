local skin = DBT:RegisterSkin("RealUI")

skin.defaults = {
    Skin = "RealUI",
    Template = "RealUISkinTimerTemplate",
    Texture = "Interface\\AddOns\\DBM-RealUI\\media\\Plain.tga",
    FillUpBars = false,
    Font = "",
    FontSize = 8,
    IconLocked = false,

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

DBM.Bars:SetSkin("RealUI")

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
