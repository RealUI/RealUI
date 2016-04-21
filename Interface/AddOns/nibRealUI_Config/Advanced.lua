local _, private = ...
local options = private.options
--local debug = private.debug

-- Lua Globals --
local _G = _G
local next = _G.next

-- Libs --
local ACD = _G.LibStub("AceConfigDialog-3.0")

-- RealUI --
local RealUI = _G.RealUI
local L = RealUI.L
local ndb = RealUI.db.profile
local ndbc = RealUI.db.char
local ndbg = RealUI.db.global

local order = 0

local core do
    local function ResetChar()
        -- Set all Char settings to default
        _G.nibRealUICharacter = nil
        ndbc.layout.current = 1

        -- Run Install Procedure
        ACD:Close("RealUI")
        RealUI:InstallProcedure()
    end
    core = {
        name = "Core",
        desc = "Core RealUI functions.",
        type = "group",
        order = 0,
        args = {
            header = {
                name = "RealUI Core",
                type = "header",
                order = 10,
            },
            corenote = {
                name = "Note: Only use these features if you need to. They may change or revert settings.",
                type = "description",
                fontSize = "medium",
                order = 20,
            },
            sep1 = {
                name = " ",
                type = "description",
                order = 30,
            },
            reinstall = {
                name = "Reset RealUI",
                type = "execute",
                func = function() RealUI:ReInstall() end,
                order = 40,
            },
            sep2 = {
                name = " ",
                type = "description",
                order = 41,
            },
            resetnote = {
                name = "This will erase all user changes and install a fresh copy of RealUI.",
                type = "description",
                fontSize = "medium",
                order = 42,
            },
            gap1 = {
                name = " ",
                type = "description",
                order = 43,
            },
            character = {
                name = "Character",
                type = "group",
                inline = true,
                order = 50,
                args = {
                    resetchar = {
                        name = "Re-initialize Character",
                        type = "execute",
                        func = ResetChar,
                        order = 10,
                    },
                    sep = {
                        name = " ",
                        type = "description",
                        order = 20,
                    },
                    resetnote = {
                        name = "This will flag the current Character as being new to RealUI, and RealUI will run through the initial installation procedure for this Character. Use only if you experienced a faulty installation for this character. Not guaranteed to actually fix anything.",
                        type = "description",
                        fontSize = "medium",
                        order = 30,
                    },
                },
            },
        },
    }
end
local skins do
    order = order + 1
    local fonts do
        local LSM = _G.LibStub("LibSharedMedia-3.0")
        local Fonts = RealUI:GetModule("Fonts")
        local db = Fonts.db.profile
        local font = ndb.media.font
        local outlines = {
            "NONE",
            "OUTLINE",
            "THICKOUTLINE",
            "OUTLINE, MONOCHROME",
        }
        fonts = {
            name = L["Fonts"],
            type = "group",
            childGroups = "select",
            order = 40,
            args = {
                stdFonts = {
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
                small = {
                    name = L["Fonts_PixelSmall"],
                    type = "group",
                    order = 10,
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
                large = {
                    name = L["Fonts_PixelLarge"],
                    type = "group",
                    order = 20,
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
                numbers = {
                    name = L["Fonts_PixelNumbers"],
                    type = "group",
                    order = 30,
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
                cooldown = {
                    name = L["Fonts_PixelCooldown"],
                    type = "group",
                    order = 40,
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
            }
        }
    end
    skins = {
        name = "Skins",
        desc = "Toggle skinning of UI frames.",
        type = "group",
        order = order,
        args = {
            header = {
                name = "Skins",
                type = "header",
                order = 0,
            },
            windowOpacity = {
                name = L["Appearance_WinOpacity"],
                type = "range",
                isPercent = true,
                min = 0, max = 1, step = 0.05,
                get = function(info) return RealUI.media.window[4] end,
                set = function(info, value)
                    RealUI.media.window[4] = value
                    RealUI:StyleSetWindowOpacity()
                end,
                order = 10,
            },
            stripeOpacity = {
                name = L["Appearance_StripeOpacity"],
                type = "range",
                isPercent = true,
                min = 0, max = 1, step = 0.05,
                get = function(info) return _G.RealUI_InitDB.stripeOpacity end,
                set = function(info, value)
                    _G.RealUI_InitDB.stripeOpacity = value
                    RealUI:StyleSetStripeOpacity()
                end,
                order = 20,
            },
            fonts = fonts,
            addons = {
                name = _G.ADDONS,
                type = "group",
                args = {
                }
            }
        }
    }
    do --[[ UI Scale ]]--
        local UIScaler = RealUI:GetModule("UIScaler")
        local db = UIScaler.db.profile
        skins.args.uiScale = {
            name = _G.UI_SCALE,
            type = "header",
            order = 29,
        }
        skins.args.retinaDisplay = {
            name = "Retina Display",
            desc = "Warning: Only activate if on a really high-resolution display (such as a Retina display).\n\nDouble UI scaling so that UI elements are easier to see.",
            type = "toggle",
            get = function() return ndbg.tags.retinaDisplay.set end,
            set = function(info, value) 
                ndbg.tags.retinaDisplay.set = value
                RealUI:ReloadUIDialog()
            end,
            order = 30,
        }
        skins.args.pixelPerfect = {
            name = "Pixel Perfect",
            desc = "Recommended: Automatically sets the scale of the UI so that UI elements appear pixel-perfect.",
            type = "toggle",
            get = function() return db.pixelPerfect end,
            set = function(info, value) 
                db.pixelPerfect = value
                UIScaler:UpdateUIScale()
            end,
            order = 40,
        }
        skins.args.customScale = {
            name = "Custom ".._G.UI_SCALE,
            desc = "Set a custom UI scale (0.48 to 1.00). Note: UI elements may lose their sharp appearance.",
            type = "input",
            disabled = function() return db.pixelPerfect end,
            get = function() return _G.tostring(db.customScale) end,
            set = function(info, value) 
                db.customScale = RealUI:ValidateOffset(_G.tonumber(value), 0.48, 1)
                UIScaler:UpdateUIScale()
            end,
            order = 50,
        }
    end
    local addonSkins = RealUI:GetAddOnSkins()
    for i = 1, #addonSkins do
        local name = addonSkins[i]
        skins.args.addons.args[name] = {
            name = name,
            type = "toggle",
            get = function() return RealUI:GetModuleEnabled(name) end,
            set = function(info, value)
                RealUI:SetModuleEnabled(name, value)
                RealUI:ReloadUIDialog()
            end,
        }
    end
end
local uiTweaks do
    order = order + 1
    local cooldown do
        local CooldownCount = RealUI:GetModule("CooldownCount")
        local db = CooldownCount.db.profile
        local table_Justify = {"LEFT", "CENTER", "RIGHT"}
        cooldown = {
            name = L["Tweaks_CooldownCount"],
            desc = L["Tweaks_CooldownCountDesc"],
            type = "group",
            arg = "CooldownCount",
            args = {
                header = {
                    name = L["Tweaks_CooldownCount"],
                    type = "header",
                    order = 10,
                },
                desc3 = {
                    name = L["General_NoteReload"],
                    type = "description",
                    order = 22,
                },
                enabled = {
                    name = L["General_Enabled"],
                    desc = L["General_EnabledDesc"]:format(L["Tweaks_CooldownCount"]),
                    type = "toggle",
                    get = function(info) return RealUI:GetModuleEnabled(cooldown.arg) end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled(cooldown.arg, value)
                        RealUI:ReloadUIDialog()
                    end,
                    order = 30,
                },
                gap1 = {
                    name = " ",
                    type = "description",
                    order = 41,
                },
                minScale = {
                    name = "Min Scale",
                    desc = "The minimum scale we want to show cooldown counts at, anything below this will be hidden.",
                    type = "range",
                    isPercent = true,
                    min = 0, max = 1, step = 0.05,
                    disabled = function(info) return not RealUI:GetModuleEnabled(cooldown.arg) end,
                    get = function(info) return db.minScale end,
                    set = function(info, value)
                        db.minScale = value
                    end,
                    order = 60,
                },
                minDuration = {
                    name = "Min Duration",
                    desc = "The minimum number of seconds a cooldown's duration must be to display text.",
                    type = "range",
                    min = 0, max = 30, step = 1,
                    disabled = function(info) return not RealUI:GetModuleEnabled(cooldown.arg) end,
                    get = function(info) return db.minDuration end,
                    set = function(info, value)
                        db.minDuration = value
                    end,
                    order = 70,
                },
                expiringDuration = {
                    name = "Expiring Duration",
                    desc = "The minimum number of seconds a cooldown must be to display in the expiring format.",
                    type = "range",
                    min = 0, max = 30, step = 1,
                    disabled = function(info) return not RealUI:GetModuleEnabled(cooldown.arg) end,
                    get = function(info) return db.expiringDuration end,
                    set = function(info, value)
                        db.expiringDuration = value
                    end,
                    order = 80,
                },
                gap2 = {
                    name = " ",
                    type = "description",
                    order = 81,
                },
                colors = {
                    name = "Colors",
                    type = "group",
                    inline = true,
                    disabled = function(info) return not RealUI:GetModuleEnabled(cooldown.arg) end,
                    order = 90,
                    args = {
                        expiring = {
                            name = "Expiring",
                            type = "color",
                            get = function(info,r,g,b)
                                return db.colors.expiring[1], db.colors.expiring[2], db.colors.expiring[3]
                            end,
                            set = function(info,r,g,b)
                                db.colors.expiring[1] = r
                                db.colors.expiring[2] = g
                                db.colors.expiring[3] = b
                            end,
                            order = 10,
                        },
                        seconds = {
                            name = "Seconds",
                            type = "color",
                            get = function(info,r,g,b)
                                return db.colors.seconds[1], db.colors.seconds[2], db.colors.seconds[3]
                            end,
                            set = function(info,r,g,b)
                                db.colors.seconds[1] = r
                                db.colors.seconds[2] = g
                                db.colors.seconds[3] = b
                            end,
                            order = 20,
                        },
                        minutes = {
                            name = "Minutes",
                            type = "color",
                            get = function(info,r,g,b)
                                return db.colors.minutes[1], db.colors.minutes[2], db.colors.minutes[3]
                            end,
                            set = function(info,r,g,b)
                                db.colors.minutes[1] = r
                                db.colors.minutes[2] = g
                                db.colors.minutes[3] = b
                            end,
                            order = 30,
                        },
                        hours = {
                            name = "Hours",
                            type = "color",
                            get = function(info,r,g,b)
                                return db.colors.hours[1], db.colors.hours[2], db.colors.hours[3]
                            end,
                            set = function(info,r,g,b)
                                db.colors.hours[1] = r
                                db.colors.hours[2] = g
                                db.colors.hours[3] = b
                            end,
                            order = 40,
                        },
                        days = {
                            name = "days",
                            type = "color",
                            get = function(info,r,g,b)
                                return db.colors.days[1], db.colors.days[2], db.colors.days[3]
                            end,
                            set = function(info,r,g,b)
                                db.colors.days[1] = r
                                db.colors.days[2] = g
                                db.colors.days[3] = b
                            end,
                            order = 50,
                        },
                    },
                },
                gap3 = {
                    name = " ",
                    type = "description",
                    order = 91,
                },
                position = {
                    name = "Position",
                    type = "group",
                    inline = true,
                    disabled = function(info) if RealUI:GetModuleEnabled(cooldown.arg) then return false else return true end end,
                    order = 100,
                    args = {
                        point = {
                            name = "Anchor",
                            type = "select",
                            values = RealUI.globals.anchorPoints,
                            get = function(info)
                                for k,v in next, RealUI.globals.anchorPoints do
                                    if v == db.position.point then return k end
                                end
                            end,
                            set = function(info, value)
                                db.position.point = RealUI.globals.anchorPoints[value]
                            end,
                            order = 10,
                        },
                        x = {
                            name = "X",
                            type = "input",
                            width = "half",
                            get = function(info) return _G.tostring(db.position.x) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.position.x = value
                            end,
                            order = 20,
                        },
                        y = {
                            name = "Y",
                            type = "input",
                            width = "half",
                            get = function(info) return _G.tostring(db.position.y) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.position.y = value
                            end,
                            order = 30,
                        },
                        justify = {
                            name = "Text Justification",
                            type = "select",
                            values = table_Justify,
                            get = function(info)
                                for k,v in next, table_Justify do
                                    if v == db.position.justify then return k end
                                end
                            end,
                            set = function(info, value)
                                db.position.justify = table_Justify[value]
                            end,
                            order = 40,
                        },
                    },
                },
            },
        }
    end
    local minimap do
        local MinimapAdv = RealUI:GetModule("MinimapAdv")
        local db = MinimapAdv.db.profile
        local minimapOffsets = {
            {x = 7, y = -7},
            {x = -7, y = -7},
            {x = 7, y = 28},
            {x = -7, y = 28},
        }
        local minimapAnchors = {
            "TOPLEFT",
            "TOPRIGHT",
            "BOTTOMLEFT",
            "BOTTOMRIGHT",
        }
        minimap = {
            type = "group",
            name = "Minimap",
            desc = "Advanced, minimalistic Minimap.",
            arg = "MinimapAdv",
            childGroups = "tab",
            args = {
                header = {
                    name = "Minimap",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Advanced, minimalistic Minimap.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the Minimap module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(minimap.arg) end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled(minimap.arg, value)
                        RealUI:ReloadUIDialog()
                    end,
                    order = 30,
                },
                gap1 = {
                    name = " ",
                    type = "description",
                    order = 31,
                },
                information = {
                    name = "Information",
                    type = "group",
                    disabled = function() if RealUI:GetModuleEnabled(minimap.arg) then return false else return true end end,
                    order = 40,
                    args = {
                        coordDelayHide = {
                            name = "Fade out Coords",
                            desc = "Hide the Coordinate display when you haven't moved for 10 seconds.",
                            type = "toggle",
                            get = function(info) return db.information.coordDelayHide end,
                            set = function(info, value)
                                db.information.coordDelayHide = value
                                MinimapAdv.StationaryTime = 0
                                MinimapAdv.LastX = 0
                                MinimapAdv.LastY = 0
                                MinimapAdv:CoordsUpdate()
                            end,
                            order = 10,
                        },
                        minimapbuttons = {
                            name = "Hide Minimap Buttons",
                            desc = "Moves buttons attached to the Minimap to underneath and shows them on mouse-over.",
                            type = "toggle",
                            get = function(info) return db.information.minimapbuttons end,
                            set = function(info, value)
                                db.information.minimapbuttons = value
                                RealUI:ReloadUIDialog()
                            end,
                            order = 20,
                        },
                        location = {
                            name = "Location Name",
                            desc = "Show the name of your current location underneath the Minimap.",
                            type = "toggle",
                            get = function(info) return db.information.location end,
                            set = function(info, value)
                                db.information.location = value
                                MinimapAdv:UpdateInfoPosition()
                            end,
                            order = 30,
                        },
                        gap = {
                            name = "Gap",
                            desc = "Amount of space between each information element.",
                            type = "range",
                            min = 1, max = 28, step = 1,
                            get = function(info) return db.information.gap end,
                            set = function(info, value)
                                db.information.gap = value
                                MinimapAdv:UpdateInfoPosition()
                            end,
                            order = 40,
                        },
                        gap1 = {
                            name = " ",
                            type = "description",
                            order = 51,
                        },
                        position = {
                            name = "Position",
                            type = "group",
                            inline = true,
                            order = 60,
                            args = {
                                xoffset = {
                                    name = "X Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(db.information.position.x) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.information.position.x = value
                                        MinimapAdv:UpdateInfoPosition()
                                    end,
                                    order = 10,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(db.information.position.y) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.information.position.y = value
                                        MinimapAdv:UpdateInfoPosition()
                                    end,
                                    order = 20,
                                },
                            },
                        },
                    },
                },
                hidden = {
                    name = "Automatic Hide/Show",
                    type = "group",
                    disabled = function() if RealUI:GetModuleEnabled(minimap.arg) then return false else return true end end,
                    order = 50,
                    args = {
                        enabled = {
                            name = "Enabled",
                            type = "toggle",
                            get = function(info) return db.hidden.enabled end,
                            set = function(info, value) db.hidden.enabled = value end,
                            order = 10,
                        },
                        gap1 = {
                            name = " ",
                            type = "description",
                            order = 11,
                        },
                        zones = {
                            name = "Hide in..",
                            type = "group",
                            inline = true,
                            disabled = function()
                                return not(db.hidden.enabled and RealUI:GetModuleEnabled(minimap.arg))
                            end,
                            order = 20,
                            args = {
                                arena = {
                                    name = "Arenas",
                                    type = "toggle",
                                    get = function(info) return db.hidden.zones.arena end,
                                    set = function(info, value) db.hidden.zones.arena = value end,
                                    order = 10,
                                },
                                pvp = {
                                    name = _G.BATTLEGROUNDS,
                                    type = "toggle",
                                    get = function(info) return db.hidden.zones.pvp end,
                                    set = function(info, value) db.hidden.zones.pvp = value end,
                                    order = 200,
                                },
                                party = {
                                    name = _G.DUNGEONS,
                                    type = "toggle",
                                    get = function(info) return db.hidden.zones.party end,
                                    set = function(info, value) db.hidden.zones.party = value end,
                                    order = 30,
                                },
                                raid = {
                                    name = _G.RAIDS,
                                    type = "toggle",
                                    get = function(info) return db.hidden.zones.raid end,
                                    set = function(info, value) db.hidden.zones.raid = value end,
                                    order = 40,
                                },
                            },
                        },
                    },
                },
                sizeposition = {
                    name = "Position",
                    type = "group",
                    disabled = function() if RealUI:GetModuleEnabled(minimap.arg) then return false else return true end end,
                    order = 60,
                    args = {
                        size = {
                            name = "Size",
                            desc = "Note: Minimap will refresh to fit the new size upon player movement.",
                            type = "range",
                            min = 134, max = 164, step = 1,
                            get = function(info) return db.position.size end,
                            set = function(info, value)
                                db.position.size = value
                                MinimapAdv:UpdateMinimapPosition()
                            end,
                            order = 10,
                        },
                        position = {
                            name = "Position",
                            type = "group",
                            inline = true,
                            order = 20,
                            args = {
                                scale = {
                                    name = "Scale",
                                    type = "range",
                                    isPercent = true,
                                    min = 0.5, max = 2, step = 0.05,
                                    get = function(info) return db.position.scale end,
                                    set = function(info, value)
                                        db.position.scale = value
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 10,
                                },
                                xoffset = {
                                    name = "X Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(db.position.x) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.x = value
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 20,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(db.position.y) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.y = value
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 30,
                                },
                                anchorto = {
                                    name = "Anchor To",
                                    type = "select",
                                    values = minimapAnchors,
                                    get = function(info)
                                        for k,v in next, minimapAnchors do
                                            if v == db.position.anchorto then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        --print("Set Anchor", info.option, value)
                                        db.position.anchorto = minimapAnchors[value]
                                        db.position.x = minimapOffsets[value].x
                                        db.position.y = minimapOffsets[value].y
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 40,
                                },
                            },
                        },
                    },
                },
                expand = {
                    name = "Farm Mode",
                    type = "group",
                    disabled = function() if RealUI:GetModuleEnabled(minimap.arg) then return false else return true end end,
                    order = 70,
                    args = {
                        appearance = {
                            name = _G.APPEARANCE_LABEL,
                            type = "group",
                            inline = true,
                            order = 10,
                            args = {
                                scale = {
                                    name = "Scale",
                                    type = "range",
                                    isPercent = true,
                                    min = 0.5, max = 2, step = 0.05,
                                    get = function(info) return db.expand.appearance.scale end,
                                    set = function(info, value)
                                        db.expand.appearance.scale = value
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 10,
                                },
                                opacity = {
                                    name = "Opacity",
                                    type = "range",
                                    isPercent = true,
                                    min = 0, max = 1, step = 0.05,
                                    get = function(info) return db.expand.appearance.opacity end,
                                    set = function(info, value)
                                        db.expand.appearance.opacity = value
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 20,
                                },
                            },
                        },
                        gap1 = {
                            name = " ",
                            type = "description",
                            order = 21,
                        },
                        position = {
                            name = "Position",
                            type = "group",
                            inline = true,
                            order = 30,
                            args = {
                                xoffset = {
                                    name = "X Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(db.expand.position.x) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.expand.position.x = value
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 10,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(db.expand.position.y) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.expand.position.y = value
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 20,
                                },
                                anchorto = {
                                    name = "Anchor To",
                                    type = "select",
                                    values = minimapAnchors,
                                    get = function(info)
                                        for k, v in next, minimapAnchors do
                                            if v == db.expand.position.anchorto then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        db.expand.position.anchorto = minimapAnchors[value]
                                        db.expand.position.x = minimapOffsets[value].x
                                        db.expand.position.y = minimapOffsets[value].y
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 30,
                                },
                            },
                        },
                        gap2 = {
                            name = " ",
                            type = "description",
                            order = 31,
                        },
                        extras = {
                            name = "Extras",
                            type = "group",
                            inline = true,
                            order = 40,
                            args = {
                                gatherertoggle = {
                                    name = "Gatherer toggle",
                                    desc = "If you have Gatherer installed, then MinimapAdv will automatically disable Gatherer's minimap icons and HUD while not in Farm Mode, and enable them while in Farm Mode.",
                                    type = "toggle",
                                    disabled = function() if not _G.Gatherer then return true else return false end end,
                                    get = function(info) return db.expand.extras.gatherertoggle end,
                                    set = function(info, value)
                                        db.expand.extras.gatherertoggle = value
                                        MinimapAdv:ToggleGatherer()
                                    end,
                                    order = 10,
                                },
                                clickthrough = {
                                    name = "Clickthrough",
                                    desc = "Make the Minimap clickthrough (won't respond to mouse clicks) while in Farm Mode.",
                                    type = "toggle",
                                    get = function(info) return db.expand.extras.clickthrough end,
                                    set = function(info, value)
                                        db.expand.extras.clickthrough = value
                                        MinimapAdv:UpdateClickthrough()
                                    end,
                                    order = 20,
                                },
                                hidepoi = {
                                    name = "Hide POI icons",
                                    type = "toggle",
                                    get = function(info) return db.expand.extras.hidepoi end,
                                    set = function(info, value)
                                        db.expand.extras.hidepoi = value
                                        MinimapAdv:UpdateFarmModePOI()
                                    end,
                                    order = 30,
                                },
                            },
                        },
                    },
                },
                poi = {
                    name = "POI",
                    type = "group",
                    disabled = function() if RealUI:GetModuleEnabled(minimap.arg) then return false else return true end end,
                    order = 80,
                    args = {
                        enabled = {
                            name = "Enabled",
                            desc = "Enable/Disable the displaying of POI icons on the minimap.",
                            type = "toggle",
                            get = function(info) return db.poi.enabled end,
                            set = function(info, value)
                                db.poi.enabled = value
                                MinimapAdv:UpdatePOIEnabled()
                            end,
                            order = 10,
                        },
                        gap1 = {
                            name = " ",
                            type = "description",
                            order = 11,
                        },
                        general = {
                            name = "General Settings",
                            type = "group",
                            inline = true,
                            disabled = function()
                                return not(db.poi.enabled and RealUI:GetModuleEnabled(minimap.arg))
                            end,
                            order = 20,
                            args = {
                                watchedOnly = {
                                    name = "Watched Only",
                                    desc = "Only show POI icons for watched quests.",
                                    type = "toggle",
                                    get = function(info) return db.poi.watchedOnly end,
                                    set = function(info, value)
                                        db.poi.watchedOnly = value
                                        MinimapAdv:POIUpdate()
                                    end,
                                    order = 10,
                                },
                                fadeEdge = {
                                    name = "Fade at Edge",
                                    desc = "Fade icons when they go off the edge of the minimap.",
                                    type = "toggle",
                                    get = function(info) return db.poi.fadeEdge end,
                                    set = function(info, value)
                                        db.poi.fadeEdge = value
                                        MinimapAdv:POIUpdate()
                                    end,
                                    order = 10,
                                },
                            },
                        },
                        gap2 = {
                            name = " ",
                            type = "description",
                            order = 21,
                        },
                        icons = {
                            name = "Icon Settings",
                            type = "group",
                            inline = true,
                            disabled = function()
                                return not(db.poi.enabled and RealUI:GetModuleEnabled(minimap.arg))
                            end,
                            order = 30,
                            args = {
                                scale = {
                                    name = "Scale",
                                    type = "range",
                                    isPercent = true,
                                    min = 0.1, max = 1.5, step = 0.05,
                                    get = function(info) return db.poi.icons.scale end,
                                    set = function(info, value)
                                        db.poi.icons.scale = value
                                        MinimapAdv:POIUpdate()
                                    end,
                                    order = 10,
                                },
                                opacity = {
                                    name = "Opacity",
                                    type = "range",
                                    isPercent = true,
                                    min = 0.1, max = 1, step = 0.05,
                                    get = function(info) return db.poi.icons.opacity end,
                                    set = function(info, value)
                                        db.poi.icons.opacity = value
                                        MinimapAdv:POIUpdate()
                                    end,
                                    order = 10,
                                },
                            },
                        },
                    },
                },
            },
        }
    end
    local powerBar do
        local AltPowerBar = RealUI:GetModule("AltPowerBar")
        local db = AltPowerBar.db.profile
        powerBar = {
            name = "Alt Power Bar",
            type = "group",
            childGroups = "tab",
            arg = "Alt Power Bar",
            args = {
                header = {
                    name = "Alt Power Bar",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Replacement of the default Alternate Power Bar.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the Alt Power Bar module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(powerBar.arg) end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled(powerBar.arg, value)
                    end,
                    order = 30,
                },
                gap1 = {
                    name = " ",
                    type = "description",
                    order = 31,
                },
                size = {
                    name = "Size",
                    type = "group",
                    inline = true,
                    disabled = function() if RealUI:GetModuleEnabled(powerBar.arg) then return false else return true end end,
                    order = 50,
                    args = {
                        width = {
                            name = "Width",
                            type = "input",
                            width = "half",
                            get = function(info) return _G.tostring(db.size.width) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.size.width = value
                                powerBar:UpdatePosition()
                            end,
                            order = 10,
                        },
                        height = {
                            name = "Height",
                            type = "input",
                            width = "half",
                            get = function(info) return _G.tostring(db.size.height) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.size.height = value
                                powerBar:UpdatePosition()
                            end,
                            order = 20,
                        },
                    },
                },
                gap2 = {
                    name = " ",
                    type = "description",
                    order = 51,
                },
                position = {
                    name = "Position",
                    type = "group",
                    inline = true,
                    disabled = function() if RealUI:GetModuleEnabled(powerBar.arg) then return false else return true end end,
                    order = 60,
                    args = {
                        position = {
                            name = "Position",
                            type = "group",
                            inline = true,
                            order = 10,
                            args = {
                                xoffset = {
                                    name = "X Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(db.position.x) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.x = value
                                        powerBar:UpdatePosition()
                                    end,
                                    order = 10,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(db.position.y) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.y = value
                                        powerBar:UpdatePosition()
                                    end,
                                    order = 20,
                                },
                                anchorto = {
                                    name = "Anchor To",
                                    type = "select",
                                    values = RealUI.globals.anchorPoints,
                                    get = function(info)
                                        for k,v in next, RealUI.globals.anchorPoints do
                                            if v == db.position.anchorto then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        db.position.anchorto = RealUI.globals.anchorPoints[value]
                                        powerBar:UpdatePosition()
                                    end,
                                    order = 30,
                                },
                                anchorfrom = {
                                    name = "Anchor From",
                                    type = "select",
                                    values = RealUI.globals.anchorPoints,
                                    get = function(info)
                                        for k,v in next, RealUI.globals.anchorPoints do
                                            if v == db.position.anchorfrom then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        db.position.anchorfrom = RealUI.globals.anchorPoints[value]
                                        powerBar:UpdatePosition()
                                    end,
                                    order = 40,
                                },
                            },
                        },
                    },
                },
            },
        }
    end
    --[[local function CreateToggleOption(mod)
        local modObj = RealUI:GetModule(mod)
        return {
            name = L["Tweaks_"..mod],
            desc = L["General_EnabledDesc"]:format(L["Tweaks_"..mod]),
            type = "toggle",
            get = function() return RealUI:GetModuleEnabled(mod) end,
            set = function(info, value)
                RealUI:SetModuleEnabled(mod, value)
                if modObj.RefreshMod then
                    modObj:RefreshMod()
                end
            end,
        }
    end]]
    uiTweaks = {
        name = L["Tweaks_UITweaks"],
        desc = L["Tweaks_UITweaksDesc"],
        type = "group",
        order = order,
        args = {
            header = {
                name = L["Tweaks_UITweaks"],
                type = "header",
                order = 0,
            },
            powerBar = powerBar,
            cooldown = cooldown,
            minimap = minimap,
        }
    }
end

--[[
local core do
    order = order + 1
    core = {
        name = "Skins",
        desc = "Toggle skinning of UI frames.",
        type = "group",
        order = order,
        args = {
        }
    }
end
]]

options.RealUI = {
    name = "|cffffffffRealUI|r "..RealUI:GetVerString(true),
    type = "group",
    args = {
        core = core,
        skins = skins,
        uiTweaks = uiTweaks,
        profiles = _G.LibStub("AceDBOptions-3.0"):GetOptionsTable(RealUI.db),
    }
}
