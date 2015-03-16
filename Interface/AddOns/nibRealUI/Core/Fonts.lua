local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndb, ndbc

local MODNAME = "Fonts"
local Fonts = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0")
local LSM = LibStub("LibSharedMedia-3.0")

local font
local outlines = {
	"NONE",
	"OUTLINE",
	"THICKOUTLINE",
	"MONOCHROMEOUTLINE"
}

-- Options
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Fonts",
        desc = "Adjust the fonts used in RealUI.",
        arg = MODNAME,
        order = 9106,
        args = {
            header = {
                type = "header",
                name = "Fonts",
                order = 10,
            },
            desc1 = {
                type = "description",
                name = "Adjust the fonts used in RealUI.",
                fontSize = "medium",
                order = 20,
            },
            desc2 = {
                type = "description",
                name = " ",
                order = 21,
            },
            desc3 = {
                type = "description",
                name = "Note: Some 3rd party addons (such as MSBT) will need fonts adjusted through their own configuration window.",
                order = 22,
            },
            desc4 = {
                type = "description",
                name = "Note2: You will need to reload the UI (/rl) for changes to take effect.",
                order = 23,
            },
            gap1 = {
                name = " ",
                type = "description",
                order = 24,
            },
            standard = {
                name = "Standard",
                type = "group",
                inline = true,
                order = 30,
                args = {
                    font = {
                        type = "select",
                        name = "Font",
                        values = AceGUIWidgetLSMlists.font,
                        get = function()
                            return font.standard[1]
                        end,
                        set = function(info, value)
                            font.standard[1] = value
                            font.standard[4] = LSM:Fetch("font", value)
                        end,
                        dialogControl = "LSM30_Font",
                        order = 10,
                    },
                    sizeadjust = {
                        type = "range",
                        name = "Adjust Size",
                        desc = "Increase/Decrease all UI Standard font sizes by this value.",
                        min = -6, max = 6, step = 1,
                        get = function(info) return db.standard.sizeadjust end,
                        set = function(info, value)
                            db.standard.sizeadjust = value
                        end,
                        order = 20,
                    },
                    changeYellow = {
                        type = "toggle",
                        name = "Adjust Yellow Fonts",
                        desc = "Change the color of WoW's 'yellow' fonts.",
                        get = function() return db.standard.changeYellow end,
                        set = function(info, value)
                            db.standard.changeYellow = value
                            InfoLine:Refresh()
                        end,
                        order = 30,
                    },
                    yellowColor = {
                        type = "color",
                        name = "Yellow Font Color",
                        hasAlpha = false,
                        get = function(info,r,g,b)
                            return db.standard.yellowColor[1], db.standard.yellowColor[2], db.standard.yellowColor[3]
                        end,
                        set = function(info,r,g,b)
                            db.standard.yellowColor[1] = r
                            db.standard.yellowColor[2] = g
                            db.standard.yellowColor[3] = b
                        end,
                        order = 40,
                    },
                },
            },
            gap2 = {
                name = " ",
                type = "description",
                order = 31,
            },
            chat = {
                name = "Chat Font",
                type = "group",
                inline = true,
                order = 35,
                args = {
                    font = {
                        type = "select",
                        name = "Font",
                        values = AceGUIWidgetLSMlists.font,
                        get = function()
                            return font.chat[1]
                        end,
                        set = function(info, value)
                            font.chat[1] = value
                            font.chat[4] = LSM:Fetch("font", value)
                        end,
                        dialogControl = "LSM30_Font",
                        order = 20,
                    },
                    outline = {
                        type = "select",
                        name = "Outline",
                        values = outlines,
                        get = function()
                            for k,v in pairs(outlines) do
                                if v == font.chat[3] then return k end
                            end
                        end,
                        set = function(info, value)
                            font.chat[3] = outlines[value]
                        end,
                        order = 30,
                    },
                },
            },
            gap3 = {
                name = " ",
                type = "description",
                order = 36,
            },
            pixel_small = {
                name = "Pixel (Small)",
                type = "group",
                inline = true,
                order = 40,
                args = {
                    font = {
                        type = "select",
                        name = "Font",
                        values = AceGUIWidgetLSMlists.font,
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
                        name = "Size",
                        min = 6, max = 28, step = 1,
                        get = function(info) return font.pixel.small[2] end,
                        set = function(info, value)
                            font.pixel.small[2] = value
                        end,
                        order = 20,
                    },
                    outline = {
                        type = "select",
                        name = "Outline",
                        values = outlines,
                        get = function()
                            for k,v in pairs(outlines) do
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
                name = "Pixel (Large)",
                type = "group",
                inline = true,
                order = 50,
                args = {
                    font = {
                        type = "select",
                        name = "Font",
                        values = AceGUIWidgetLSMlists.font,
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
                        name = "Size",
                        min = 6, max = 28, step = 1,
                        get = function(info) return font.pixel.large[2] end,
                        set = function(info, value)
                            font.pixel.large[2] = value
                        end,
                        order = 20,
                    },
                    outline = {
                        type = "select",
                        name = "Outline",
                        values = outlines,
                        get = function()
                            for k,v in pairs(outlines) do
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
                name = "Pixel (Numbers)",
                type = "group",
                inline = true,
                order = 60,
                args = {
                    font = {
                        type = "select",
                        name = "Font",
                        values = AceGUIWidgetLSMlists.font,
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
                        name = "Size",
                        min = 6, max = 28, step = 1,
                        get = function(info) return font.pixel.numbers[2] end,
                        set = function(info, value)
                            font.pixel.numbers[2] = value
                        end,
                        order = 20,
                    },
                    outline = {
                        type = "select",
                        name = "Outline",
                        values = outlines,
                        get = function()
                            for k,v in pairs(outlines) do
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
                name = "Pixel (Cooldown)",
                type = "group",
                inline = true,
                order = 80,
                args = {
                    font = {
                        type = "select",
                        name = "Font",
                        values = AceGUIWidgetLSMlists.font,
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
                        name = "Size",
                        min = 6, max = 28, step = 1,
                        get = function(info) return font.pixel.cooldown[2] end,
                        set = function(info, value)
                            font.pixel.cooldown[2] = value
                        end,
                        order = 20,
                    },
                    outline = {
                        type = "select",
                        name = "Outline",
                        values = outlines,
                        get = function()
                            for k,v in pairs(outlines) do
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
            gap7 = {
                name = " ",
                type = "description",
                order = 81,
            },
            changeFCT = {
                type = "toggle",
                name = "Change Floating Combat Text",
                desc = "Change the font of the default Floating Combat Text.",
                get = function() return db.changeFCT end,
                set = function(info, value)
                    db.changeFCT = value
                end,
                order = 90,
            },
        },
    };
    end
    return options
end

local function SetFont(obj, font, size, style, color, shadow, x, y)
    Fonts:debug("SetFont", font, size, style)
    if not obj then return end
    obj:SetFont(font, size + db.standard.sizeadjust, style)
    if shadow then obj:SetShadowColor(shadow[1], shadow[2], shadow[3], shadow[4]) end
    if x and y then obj:SetShadowOffset(x, y) end
    if type(color) == "table" then obj:SetTextColor(color[1], color[2], color[3], color[4])
    elseif color then obj:SetAlpha(color) end
end

function Fonts:UpdateUIFonts()
    -- Regular text: replaces FRIZQT__.TTF
    local NORMAL = font.standard[4]
    --local NORMAL = font.normal

    -- Chat Font: replaces ARIALN.TTF
    local CHAT   = font.chat[4]

    -- Crit Font: replaces skurri.ttf
    local CRIT   = NORMAL --font.crit[4]

    -- Header Font: replaces MORPHEUS.ttf
    local HEADER = NORMAL --font.header[4]

    STANDARD_TEXT_FONT = NORMAL
    UNIT_NAME_FONT     = NORMAL
    -- NAMEPLATE_FONT will be changed indirectly through its defined font object.
    if db.changeFCT then
        DAMAGE_TEXT_FONT = NORMAL
    end

    -- RealUI Fonts
    SetFont(RealUIFont_Normal, font.standard[4], font.standard[2], font.standard[3])
    SetFont(RealUIFont_Chat, font.chat[4], font.chat[2], font.chat[3])
    if ndb.settings.fontStyle == 1 then
        RealUIFont_Pixel:SetFont(font.pixel.small[4], font.pixel.small[2], font.pixel.small[3])
        RealUIFont_PixelSmall:SetFont(font.pixel.small[4], font.pixel.small[2], font.pixel.small[3])
        RealUIFont_PixelLarge:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
    elseif ndb.settings.fontStyle == 2 then
        RealUIFont_Pixel:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
        RealUIFont_PixelSmall:SetFont(font.pixel.small[4], font.pixel.small[2], font.pixel.small[3])
        RealUIFont_PixelLarge:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
    elseif ndb.settings.fontStyle == 3 then
        RealUIFont_Pixel:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
        RealUIFont_PixelSmall:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
        RealUIFont_PixelLarge:SetFont(font.pixel.large[4], font.pixel.large[2], font.pixel.large[3])
    end
    RealUIFont_PixelNumbers:SetFont( font.pixel.numbers[4], font.pixel.numbers[2], font.pixel.numbers[3])
    RealUIFont_PixelCooldown:SetFont(font.pixel.cooldown[4], font.pixel.cooldown[2], font.pixel.cooldown[3])


    -- Base fonts, everything inhierits from these fonts.
    -- FrameXML\Fonts.xml
    SetFont(SystemFont_Small,               NORMAL, 10)
    SetFont(SystemFont_Outline_Small,       NORMAL, 10, "OUTLINE")
    SetFont(SystemFont_Outline,             NORMAL, 13, "OUTLINE")
    SetFont(SystemFont_InverseShadow_Small, NORMAL, 10, nil, nil, {0.4, 0.4, 0.4, 0.75}, 1, -1)
    SetFont(SystemFont_Med2,                NORMAL, 13)
    SetFont(SystemFont_Med3,                NORMAL, 14)
    SetFont(SystemFont_Shadow_Med3,         NORMAL, 14, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(SystemFont_Huge1,               NORMAL, 20)
    SetFont(SystemFont_Huge1_Outline,       NORMAL, 20, "OUTLINE")
    SetFont(SystemFont_OutlineThick_Huge2,  NORMAL, 22, "THICKOUTLINE")
    SetFont(SystemFont_OutlineThick_Huge4,  NORMAL, 26, "THICKOUTLINE")
    SetFont(SystemFont_OutlineThick_WTF,    NORMAL, 32, "THICKOUTLINE")

    SetFont(NumberFont_GameNormal,            NORMAL, 10, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(NumberFont_Shadow_Small,            CHAT, 12, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(NumberFont_OutlineThick_Mono_Small, CHAT, 12, "THICKOUTLINE, MONOCHROME")
    SetFont(NumberFont_Shadow_Med,              CHAT, 14, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(NumberFont_Normal_Med,              CHAT, 14)
    SetFont(NumberFont_Outline_Med,             CHAT, 14, "OUTLINE")
    SetFont(NumberFont_Outline_Large,           CHAT, 16, "OUTLINE")
    SetFont(NumberFont_Outline_Huge,            CRIT, 30, "OUTLINE")

    SetFont(QuestFont_Huge,               HEADER, 18)
    SetFont(QuestFont_Outline_Huge,       HEADER, 18, "OUTLINE")
    SetFont(QuestFont_Super_Huge,         HEADER, 24, nil, {1, 0.82, 0})
    SetFont(QuestFont_Super_Huge_Outline, HEADER, 24, "OUTLINE", {1, 0.82, 0})
    SetFont(SplashHeaderFont,             HEADER, 24, nil, {1, 0.82, 0}, {0, 0, 0}, 1, -2)

    SetFont(Game18Font, NORMAL, 18)
    SetFont(Game24Font, NORMAL, 24)
    SetFont(Game27Font, NORMAL, 27)
    SetFont(Game30Font, NORMAL, 30)
    SetFont(Game32Font, NORMAL, 32)
    SetFont(Game36Font, NORMAL, 36)
    SetFont(Game48Font, NORMAL, 48)
    SetFont(Game60Font, NORMAL, 60)
    SetFont(Game72Font, NORMAL, 72)

    SetFont(QuestFont_Enormous,     HEADER, 30, nil, {1, 0.82, 0})
    SetFont(DestinyFontLarge,       HEADER, 18, nil, {0.1, 0.1, 0.1})
    SetFont(CoreAbilityFont,        HEADER, 32, nil, {0.1, 0.1, 0.1})
    SetFont(DestinyFontHuge,        HEADER, 32, nil, {0.1, 0.1, 0.1})
    SetFont(QuestFont_Shadow_Small, HEADER, 14, nil, nil, {0.49, 0.35, 0.05}, 1, -1)

    SetFont(MailFont_Large,    HEADER, 15)
    SetFont(SpellFont_Small,   NORMAL, 10)
    SetFont(InvoiceFont_Med,   NORMAL, 12)
    SetFont(InvoiceFont_Small, NORMAL, 10)
    SetFont(Tooltip_Med,       NORMAL, 12)
    SetFont(Tooltip_Small,     NORMAL, 10)

    SetFont(AchievementFont_Small, NORMAL, 12)
    SetFont(ReputationDetailFont,  NORMAL, 10, nil, {1, 1, 1}, {0, 0, 0}, 1, -1)
    SetFont(FriendsFont_Normal,    NORMAL, 12, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(FriendsFont_Small,     NORMAL, 10, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(FriendsFont_Large,     NORMAL, 14, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(FriendsFont_UserText,  NORMAL, 11, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(GameFont_Gigantic,     NORMAL, 32, nil, {1, 0.82, 0}, {0, 0, 0}, 1, -1)

    SetFont(ChatBubbleFont, NORMAL, 13)
    SetFont(Fancy16Font,    HEADER, 16)


    -- SharedXML\SharedFonts.xml
    SetFont(SystemFont_Tiny,                 NORMAL, 9)
    SetFont(SystemFont_Shadow_Small,         NORMAL, 10, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(SystemFont_Small2,               NORMAL, 11)
    SetFont(SystemFont_Shadow_Small2,        NORMAL, 11, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(SystemFont_Shadow_Med1_Outline,  NORMAL, 12, "OUTLINE", nil, {0, 0, 0}, 1, -1)
    SetFont(SystemFont_Shadow_Med1,          NORMAL, 12, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(QuestFont_Large,                 HEADER, 15)
    SetFont(SystemFont_Large,                NORMAL, 16)
    SetFont(SystemFont_Shadow_Large_Outline, NORMAL, 16, "OUTLINE", nil, {0, 0, 0}, 1, -1)
    SetFont(SystemFont_Shadow_Med2,          NORMAL, 14, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(SystemFont_Shadow_Large,         NORMAL, 16, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(SystemFont_Shadow_Large2,        NORMAL, 18, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(SystemFont_Shadow_Huge1,         NORMAL, 20, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(SystemFont_Shadow_Huge2,         NORMAL, 24, "OUTLINE", nil, {0, 0, 0}, 1, -1)
    SetFont(SystemFont_Shadow_Huge3,         NORMAL, 25, nil, nil, {0, 0, 0}, 1, -1)
    SetFont(SystemFont_Shadow_Outline_Huge2, NORMAL, 22, "OUTLINE", nil, {0, 0, 0}, 2, -2)
    SetFont(SystemFont_Med1,                 NORMAL, 12)
    SetFont(SystemFont_OutlineThick_WTF2,    NORMAL, 36)
    SetFont(GameTooltipHeader,               NORMAL, 14)

    if db.standard.changeYellow then
        local yellowFonts = {
            GameFontNormal,
            GameFontNormalSmall,
            GameFontNormalMed3,
            GameFontNormalLarge,
            GameFontNormalHuge,
            BossEmoteNormalHuge,
            NumberFontNormalRightYellow,
            NumberFontNormalYellow,
            NumberFontNormalLargeRightYellow,
            NumberFontNormalLargeYellow,
            QuestTitleFontBlackShadow,
            DialogButtonNormalText,
            AchievementPointsFont,
            AchievementPointsFontSmall,
            AchievementDateFont,
            FocusFontSmall
        }
        for k, font in pairs(yellowFonts) do
            font:SetTextColor(db.standard.yellowColor[1], db.standard.yellowColor[2], db.standard.yellowColor[3])
        end
    end
end

function nibRealUI:Font(isLSM, size)
    size = size or "default"
    if size == "default" then
        if ndb.settings.fontStyle == 1 then
            if isLSM then
                return font.pixel.small[1]
            else
                return font.pixel.small[4]
            end
        else
            if isLSM then
                return font.pixel.large[1]
            else
                return font.pixel.large[4]
            end
        end

    elseif size == "small" then
        if ndb.settings.fontStyle == 1 then
            if isLSM then
                return font.pixel.small[1]
            else
                return font.pixel.small[4]
            end
        elseif ndb.settings.fontStyle == 2 then
            if isLSM then
                return font.pixel.small[1]
            else
                return font.pixel.small[4]
            end
        elseif ndb.settings.fontStyle == 3 then
            if isLSM then
                return font.pixel.large[1]
            else
                return font.pixel.large[4]
            end
        end

    elseif size == "large" then
        if isLSM then
            return font.pixel.large[1]
        else
            return font.pixel.large[4]
        end

    elseif size == "tiny" then
        if isLSM then
            return font.pixel.small[1]
        else
            return font.pixel.small[4]
        end
    end
end

function Fonts:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            changeFCT = true,
            standard = {
                sizeadjust = 0,
                changeYellow = true,
                yellowColor = {1, 0.55, 0}
            },
        }
    })
    db = self.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char

    font = ndb.media.font
    font.sizeAdjust = db.standard.sizeadjust

    self:SetEnabledState(true)
    nibRealUI:RegisterPlainOptions(MODNAME, GetOptions)

    if ndb.settings.chatFontCustom then
        local chat = font.chat
        chat[1] = ndb.settings.chatFontCustom.font or chat[1]
        chat[2] = ndb.settings.chatFontSize or chat[2]
        chat[3] = ndb.settings.chatFontOutline and "OUTLINE" or chat[3]

        ndb.settings.chatFontCustom = nil
        ndb.settings.chatFontSize = nil
        ndb.settings.chatFontOutline = nil
    end

    for fontName, fontInfo in next, font do
        local path
        if type(fontInfo) == "table" then
            if fontName == "pixel" then
                for subName, subInfo in next, fontInfo do
                    path = LSM:Fetch("font", subInfo[1], true)
                    Fonts:debug(subInfo[1], path,  subInfo[4])
                    if path and path ~= subInfo[4] then
                        subInfo[4] = path
                    end
                end
            else
                path = LSM:Fetch("font", fontInfo[1], true)
                Fonts:debug(fontInfo[1], path,  fontInfo[4])
                if path and path ~= fontInfo[4] then
                    fontInfo[4] = path
                end
            end
        end
    end

    self:UpdateUIFonts()
end
