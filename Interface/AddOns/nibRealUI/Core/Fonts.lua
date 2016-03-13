local _, private = ...

-- Lua Globals --
local _G = _G
local next, type = _G.next, _G.type

-- Libs --
local LSM = _G.LibStub("LibSharedMedia-3.0")

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, ndb

local MODNAME = "Fonts"
local Fonts = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local font
local outlines = {
    "NONE",
    "OUTLINE",
    "THICKOUTLINE",
    "OUTLINE, MONOCHROME",
}

-- Options
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = L["Fonts"],
        desc = L["Fonts_Desc"],
        arg = MODNAME,
        order = 9106,
        args = {
            title = {
                type = "header",
                name = L["Fonts"],
                order = 10,
            },
            desc = {
                type = "description",
                name = L["Fonts_Desc"],
                fontSize = "medium",
                order = 20,
            },
            gap1 = {
                type = "description",
                name = " ",
                order = 21,
            },
            note = {
                type = "description",
                name = L["General_NoteReload"],
                order = 22,
            },
            gap2 = {
                name = " ",
                type = "description",
                order = 23,
            },
            general = {
                name = L["Fonts_Standard"],
                type = "group",
                inline = true,
                order = 30,
                args = {
                    sizeadjust = {
                        type = "range",
                        name = L["Fonts_NormalOffset"],
                        desc = L["Fonts_NormalOffsetDesc"],
                        min = -6, max = 6, step = 1,
                        get = function(info) return db.standard.sizeadjust end,
                        set = function(info, value)
                            db.standard.sizeadjust = value
                        end,
                        order = 10,
                    },
                    changeYellow = {
                        type = "toggle",
                        name = L["Fonts_ChangeYellow"],
                        desc = L["Fonts_ChangeYellowDesc"],
                        get = function() return db.standard.changeYellow end,
                        set = function(info, value)
                            db.standard.changeYellow = value
                            --InfoLine:Refresh()
                        end,
                        order = 20,
                    },
                    yellowColor = {
                        name = L["Fonts_YellowFont"],
                        type = "color",
                        hasAlpha = false,
                        disabled = function() return not db.standard.changeYellow end,
                        get = function(info,r,g,b)
                            return db.standard.yellowColor[1], db.standard.yellowColor[2], db.standard.yellowColor[3]
                        end,
                        set = function(info,r,g,b)
                            db.standard.yellowColor[1] = r
                            db.standard.yellowColor[2] = g
                            db.standard.yellowColor[3] = b
                        end,
                        order = 21,
                    },
                    normal = {
                        type = "select",
                        name = L["Fonts_Normal"],
                        desc = L["Fonts_NormalDesc"],
                        values = _G.AceGUIWidgetLSMlists.font,
                        get = function()
                            return font.standard[1]
                        end,
                        set = function(info, value)
                            font.standard[1] = value
                            font.standard[4] = LSM:Fetch("font", value)
                        end,
                        dialogControl = "LSM30_Font",
                        order = 30,
                    },
                    header = {
                        name = L["Fonts_Header"],
                        desc = L["Fonts_HeaderDesc"],
                        type = "select",
                        values = _G.AceGUIWidgetLSMlists.font,
                        get = function()
                            return font.header[1]
                        end,
                        set = function(info, value)
                            font.header[1] = value
                            font.header[4] = LSM:Fetch("font", value)
                        end,
                        dialogControl = "LSM30_Font",
                        order = 40,
                    },
                    gap = {
                        name = "",
                        type = "header",
                        order = 41,
                    },
                    font = {
                        name = L["Fonts_Chat"],
                        desc = L["Fonts_ChatDesc"],
                        type = "select",
                        values = _G.AceGUIWidgetLSMlists.font,
                        get = function()
                            return font.chat[1]
                        end,
                        set = function(info, value)
                            font.chat[1] = value
                            font.chat[4] = LSM:Fetch("font", value)
                        end,
                        dialogControl = "LSM30_Font",
                        order = 50,
                    },
                    outline = {
                        type = "select",
                        name = L["Fonts_Outline"],
                        values = outlines,
                        get = function()
                            for k,v in next, outlines do
                                if v == font.chat[3] then return k end
                            end
                        end,
                        set = function(info, value)
                            font.chat[3] = outlines[value]
                        end,
                        order = 51,
                    },
                },
            },
            gap3 = {
                name = " ",
                type = "description",
                order = 31,
            },
            pixel_small = {
                name = L["Fonts_PixelSmall"],
                type = "group",
                inline = true,
                order = 40,
                args = {
                    font = {
                        type = "select",
                        name = L["Fonts_Font"],
                        values = _G.AceGUIWidgetLSMlists.font,
                        get = function()
                            return font.pixel.small[1]
                        end,
                        set = function(info, value)
                            font.pixel.small[1] = value
                            font.pixel.small[4] = LSM:Fetch("font", value)
                        end,
                        dialogControl = "LSM30_Font",
                        order = 10,
                    },
                    size = {
                        type = "range",
                        name = _G.FONT_SIZE,
                        min = 6, max = 28, step = 1,
                        get = function(info) return font.pixel.small[2] end,
                        set = function(info, value)
                            font.pixel.small[2] = value
                        end,
                        order = 20,
                    },
                    outline = {
                        type = "select",
                        name = L["Fonts_Outline"],
                        values = outlines,
                        get = function()
                            for k,v in next, outlines do
                                if v == font.pixel.small[3] then return k end
                            end
                        end,
                        set = function(info, value)
                            font.pixel.small[3] = outlines[value]
                        end,
                        order = 30,
                    },
                },
            },
            gap4 = {
                name = " ",
                type = "description",
                order = 41,
            },
            pixel_large = {
                name = L["Fonts_PixelLarge"],
                type = "group",
                inline = true,
                order = 50,
                args = {
                    font = {
                        type = "select",
                        name = L["Fonts_Font"],
                        values = _G.AceGUIWidgetLSMlists.font,
                        get = function()
                            return font.pixel.large[1]
                        end,
                        set = function(info, value)
                            font.pixel.large[1] = value
                            font.pixel.large[4] = LSM:Fetch("font", value)
                        end,
                        dialogControl = "LSM30_Font",
                        order = 10,
                    },
                    size = {
                        type = "range",
                        name = _G.FONT_SIZE,
                        min = 6, max = 28, step = 1,
                        get = function(info) return font.pixel.large[2] end,
                        set = function(info, value)
                            font.pixel.large[2] = value
                        end,
                        order = 20,
                    },
                    outline = {
                        type = "select",
                        name = L["Fonts_Outline"],
                        values = outlines,
                        get = function()
                            for k,v in next, outlines do
                                if v == font.pixel.large[3] then return k end
                            end
                        end,
                        set = function(info, value)
                            font.pixel.large[3] = outlines[value]
                        end,
                        order = 30,
                    },
                },
            },
            gap5 = {
                name = " ",
                type = "description",
                order = 51,
            },
            pixel_numbers = {
                name = L["Fonts_PixelNumbers"],
                type = "group",
                inline = true,
                order = 60,
                args = {
                    font = {
                        type = "select",
                        name = L["Fonts_Font"],
                        values = _G.AceGUIWidgetLSMlists.font,
                        get = function()
                            return font.pixel.numbers[1]
                        end,
                        set = function(info, value)
                            font.pixel.numbers[1] = value
                            font.pixel.numbers[4] = LSM:Fetch("font", value)
                        end,
                        dialogControl = "LSM30_Font",
                        order = 10,
                    },
                    size = {
                        type = "range",
                        name = _G.FONT_SIZE,
                        min = 6, max = 28, step = 1,
                        get = function(info) return font.pixel.numbers[2] end,
                        set = function(info, value)
                            font.pixel.numbers[2] = value
                        end,
                        order = 20,
                    },
                    outline = {
                        type = "select",
                        name = L["Fonts_Outline"],
                        values = outlines,
                        get = function()
                            for k,v in next, outlines do
                                if v == font.pixel.numbers[3] then return k end
                            end
                        end,
                        set = function(info, value)
                            font.pixel.numbers[3] = outlines[value]
                        end,
                        order = 30,
                    },
                },
            },
            gap6 = {
                name = " ",
                type = "description",
                order = 61,
            },
            pixel_cooldown = {
                name = L["Fonts_PixelCooldown"],
                type = "group",
                inline = true,
                order = 70,
                args = {
                    font = {
                        type = "select",
                        name = L["Fonts_Font"],
                        values = _G.AceGUIWidgetLSMlists.font,
                        get = function()
                            return font.pixel.cooldown[1]
                        end,
                        set = function(info, value)
                            font.pixel.cooldown[1] = value
                            font.pixel.cooldown[4] = LSM:Fetch("font", value)
                        end,
                        dialogControl = "LSM30_Font",
                        order = 10,
                    },
                    size = {
                        type = "range",
                        name = _G.FONT_SIZE,
                        min = 6, max = 28, step = 1,
                        get = function(info) return font.pixel.cooldown[2] end,
                        set = function(info, value)
                            font.pixel.cooldown[2] = value
                        end,
                        order = 20,
                    },
                    outline = {
                        type = "select",
                        name = L["Fonts_Outline"],
                        values = outlines,
                        get = function()
                            for k,v in next, outlines do
                                if v == font.pixel.cooldown[3] then return k end
                            end
                        end,
                        set = function(info, value)
                            font.pixel.cooldown[3] = outlines[value]
                        end,
                        order = 30,
                    },
                },
            },
        },
    };
    end
    return options
end

local function SetFont(fontObj, fontPath, fontSize, fontStyle, fontColor, shadowColor, shadowX, shadowY)
    Fonts:debug("SetFont", fontPath, fontSize, fontStyle)
    if type(fontObj) == "string" then fontObj = _G[fontObj] end
    if not fontObj then return end
    fontObj:SetFont(fontPath, fontSize + db.standard.sizeadjust, fontStyle)
    if shadowColor then fontObj:SetShadowColor(shadowColor[1], shadowColor[2], shadowColor[3], shadowColor[4]) end
    if shadowX and shadowY then fontObj:SetShadowOffset(shadowX, shadowY) end
    if type(fontColor) == "table" then fontObj:SetTextColor(fontColor[1], fontColor[2], fontColor[3], fontColor[4])
    elseif fontColor then fontObj:SetAlpha(fontColor) end
end

function Fonts:UpdateUIFonts()
    -- Regular text: replaces FRIZQT__.TTF
    local NORMAL = font.standard[4]
    --local NORMAL = font.normal

    -- Chat Font: replaces ARIALN.TTF
    local CHAT   = font.chat[4]

    -- Crit Font: replaces skurri.ttf
    local CRIT   = font.crit[4]

    -- Header Font: replaces MORPHEUS.ttf
    local HEADER = font.header[4]

    _G.STANDARD_TEXT_FONT = NORMAL
    _G.UNIT_NAME_FONT = NORMAL
    _G.NAMEPLATE_FONT = "RealUIFont_Normal"
    _G.DAMAGE_TEXT_FONT = NORMAL

    -- RealUI Fonts
    SetFont("RealUIFont_Normal", font.standard[4], font.standard[2], font.standard[3])
    SetFont("RealUIFont_Chat", font.chat[4], font.chat[2], font.chat[3])
    if ndb.settings.fontStyle == 1 then
        _G.RealUIFont_Pixel:SetFont(font.pixel.small[4], font.pixel.small[2], font.pixel.small[3])
        _G.RealUIFont_PixelSmall:SetFont(font.pixel.small[4], font.pixel.small[2], font.pixel.small[3])
        _G.RealUIFont_PixelLarge:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
    elseif ndb.settings.fontStyle == 2 then
        _G.RealUIFont_Pixel:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
        _G.RealUIFont_PixelSmall:SetFont(font.pixel.small[4], font.pixel.small[2], font.pixel.small[3])
        _G.RealUIFont_PixelLarge:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
    elseif ndb.settings.fontStyle == 3 then
        _G.RealUIFont_Pixel:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
        _G.RealUIFont_PixelSmall:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
        _G.RealUIFont_PixelLarge:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
    end
    _G.RealUIFont_PixelNumbers:SetFont( font.pixel.numbers[4], font.pixel.numbers[2], font.pixel.numbers[3])
    _G.RealUIFont_PixelCooldown:SetFont(font.pixel.cooldown[4], font.pixel.cooldown[2], font.pixel.cooldown[3])


    -- Base fonts, everything inhierits from these fonts.
    -- FrameXML\Fonts.xml
    SetFont("SystemFont_Small",               NORMAL, 10)
    SetFont("SystemFont_Outline_Small",       NORMAL, 10, "OUTLINE")
    SetFont("SystemFont_Outline",             NORMAL, 13, "OUTLINE")
    SetFont("SystemFont_InverseShadow_Small", NORMAL, 10, nil, nil, {0.4, 0.4, 0.4, 0.75}, 1, -1)
    SetFont("SystemFont_Med2",                NORMAL, 13)
    SetFont("SystemFont_Med3",                NORMAL, 14)
    SetFont("SystemFont_Shadow_Med3",         NORMAL, 14, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("SystemFont_Huge1",               NORMAL, 20)
    SetFont("SystemFont_Huge1_Outline",       NORMAL, 20, "OUTLINE")
    SetFont("SystemFont_OutlineThick_Huge2",  NORMAL, 22, "THICKOUTLINE")
    SetFont("SystemFont_OutlineThick_Huge4",  NORMAL, 26, "THICKOUTLINE")
    SetFont("SystemFont_OutlineThick_WTF",    NORMAL, 32, "THICKOUTLINE")

    SetFont("NumberFont_GameNormal",            NORMAL, 10, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("NumberFont_Shadow_Small",            CHAT, 12, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("NumberFont_OutlineThick_Mono_Small", CHAT, 12, "THICKOUTLINE, MONOCHROME")
    SetFont("NumberFont_Shadow_Med",              CHAT, 14, font.chat[3], nil, {0, 0, 0}, 1, -1)
    SetFont("NumberFont_Normal_Med",              CHAT, 14)
    SetFont("NumberFont_Outline_Med",             CHAT, 14, "OUTLINE")
    SetFont("NumberFont_Outline_Large",           CHAT, 16, "OUTLINE")
    SetFont("NumberFont_Outline_Huge",            CRIT, 30, "OUTLINE")

    SetFont("QuestFont_Huge",               HEADER, 18)
    SetFont("QuestFont_Outline_Huge",       HEADER, 18, "OUTLINE")
    SetFont("QuestFont_Super_Huge",         HEADER, 24, nil, {1, 0.82, 0})
    SetFont("QuestFont_Super_Huge_Outline", HEADER, 24, "OUTLINE", {1, 0.82, 0})
    SetFont("SplashHeaderFont",             HEADER, 24, nil, {1, 0.82, 0}, {0, 0, 0}, 1, -2)

    SetFont("Game18Font", NORMAL, 18)
    SetFont("Game24Font", NORMAL, 24)
    SetFont("Game27Font", NORMAL, 27)
    SetFont("Game30Font", NORMAL, 30)
    SetFont("Game32Font", NORMAL, 32)
    SetFont("Game36Font", NORMAL, 36)
    SetFont("Game48Font", NORMAL, 48)
    SetFont("Game60Font", NORMAL, 60)
    SetFont("Game72Font", NORMAL, 72)

    SetFont("QuestFont_Enormous",     HEADER, 30, nil, {1, 0.82, 0})
    SetFont("DestinyFontLarge",       HEADER, 18, nil, {0.1, 0.1, 0.1})
    SetFont("CoreAbilityFont",        HEADER, 32, nil, {0.1, 0.1, 0.1})
    SetFont("DestinyFontHuge",        HEADER, 32, nil, {0.1, 0.1, 0.1})
    SetFont("QuestFont_Shadow_Small", HEADER, 14, nil, nil, {0.49, 0.35, 0.05}, 1, -1)

    SetFont("MailFont_Large",    HEADER, 15)
    SetFont("SpellFont_Small",   NORMAL, 10)
    SetFont("InvoiceFont_Med",   NORMAL, 12)
    SetFont("InvoiceFont_Small", NORMAL, 10)
    SetFont("Tooltip_Med",       NORMAL, 12)
    SetFont("Tooltip_Small",     NORMAL, 10)

    SetFont("AchievementFont_Small", NORMAL, 12)
    SetFont("ReputationDetailFont",  NORMAL, 10, nil, {1, 1, 1}, {0, 0, 0}, 1, -1)
    SetFont("FriendsFont_Normal",    NORMAL, 12, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("FriendsFont_Small",     NORMAL, 10, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("FriendsFont_Large",     NORMAL, 14, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("FriendsFont_UserText",  NORMAL, 11, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("GameFont_Gigantic",     NORMAL, 32, nil, {1, 0.82, 0}, {0, 0, 0}, 1, -1)

    SetFont("ChatBubbleFont", NORMAL, 13)
    SetFont("Fancy16Font",    HEADER, 16)


    -- SharedXML\SharedFonts.xml
    SetFont("SystemFont_Tiny",                 NORMAL, 9)
    SetFont("SystemFont_Shadow_Small",         NORMAL, 10, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("SystemFont_Small2",               NORMAL, 11)
    SetFont("SystemFont_Shadow_Small2",        NORMAL, 11, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("SystemFont_Shadow_Med1_Outline",  NORMAL, 12, "OUTLINE", nil, {0, 0, 0}, 1, -1)
    SetFont("SystemFont_Shadow_Med1",          NORMAL, 12, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("QuestFont_Large",                 HEADER, 15)
    SetFont("SystemFont_Large",                NORMAL, 16)
    SetFont("SystemFont_Shadow_Large_Outline", NORMAL, 16, "OUTLINE", nil, {0, 0, 0}, 1, -1)
    SetFont("SystemFont_Shadow_Med2",          NORMAL, 14, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("SystemFont_Shadow_Large",         NORMAL, 16, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("SystemFont_Shadow_Large2",        NORMAL, 18, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("SystemFont_Shadow_Huge1",         NORMAL, 20, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("SystemFont_Shadow_Huge2",         NORMAL, 24, "OUTLINE", nil, {0, 0, 0}, 1, -1)
    SetFont("SystemFont_Shadow_Huge3",         NORMAL, 25, nil, nil, {0, 0, 0}, 1, -1)
    SetFont("SystemFont_Shadow_Outline_Huge2", NORMAL, 22, "OUTLINE", nil, {0, 0, 0}, 2, -2)
    SetFont("SystemFont_Med1",                 NORMAL, 12)
    SetFont("SystemFont_OutlineThick_WTF2",    NORMAL, 36)
    SetFont("GameTooltipHeader",               NORMAL, 14)

    if db.standard.changeYellow then
        local yellowFonts = {
            "GameFontNormal",
            "GameFontNormalSmall",
            "GameFontNormalMed3",
            "GameFontNormalLarge",
            "GameFontNormalHuge",
            "BossEmoteNormalHuge",
            "NumberFontNormalRightYellow",
            "NumberFontNormalYellow",
            "NumberFontNormalLargeRightYellow",
            "NumberFontNormalLargeYellow",
            "QuestTitleFontBlackShadow",
            "DialogButtonNormalText",
            "AchievementPointsFont",
            "AchievementPointsFontSmall",
            "AchievementDateFont",
            "FocusFontSmall"
        }
        for k, yellowFont in next, yellowFonts do
            _G[yellowFont]:SetTextColor(db.standard.yellowColor[1], db.standard.yellowColor[2], db.standard.yellowColor[3])
        end
    end
end

function Fonts:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            standard = {
                sizeadjust = 0,
                changeYellow = true,
                yellowColor = {1, 0.55, 0}
            },
        }
    })
    db = self.db.profile
    ndb = RealUI.db.profile

    font = ndb.media.font
    font.sizeAdjust = db.standard.sizeadjust

    self:SetEnabledState(true)
    RealUI:RegisterPlainOptions(MODNAME, GetOptions)

    if ndb.settings.fontStyle ~= 2 then
        ndb.settings.fontStyle = 2
    end
    if ndb.settings.chatFontCustom then
        local chat = font.chat
        chat[1] = ndb.settings.chatFontCustom.font or chat[1]
        chat[2] = ndb.settings.chatFontSize or chat[2]
        chat[3] = ndb.settings.chatFontOutline and "OUTLINE" or chat[3]

        ndb.settings.chatFontCustom = nil
        ndb.settings.chatFontSize = nil
        ndb.settings.chatFontOutline = nil
    end

    local function validateFont(fontInfo)
        if fontInfo[1] then
            local name, path = fontInfo[1], fontInfo[4]
            if name:find("%sRU") then
                name = name:sub(1, name:find("%sRU")-1)
            end
            local pathLSM = LSM:Fetch("font", name, true)
            Fonts:debug("SetInfo", name, pathLSM,  path)
            -- if pathLSM is nil, the chosen font is from another addon and hasn't been loaded yet.
            if pathLSM and pathLSM ~= path then
                fontInfo[4] = pathLSM
            end
        else
            for subName, subInfo in next, fontInfo do
                validateFont(subInfo)
            end
        end
    end
    for fontName, fontInfo in next, font do
        if type(fontInfo) == "table" then
            validateFont(fontInfo)
        end
    end

    self:UpdateUIFonts()
end
