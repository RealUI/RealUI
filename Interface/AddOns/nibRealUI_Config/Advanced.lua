local _, private = ...
local options = private.options
local debug = private.debug

-- Lua Globals --
local _G = _G
local next, tostring = _G.next, _G.tostring

-- Libs --
--local ACD = _G.LibStub("AceConfigDialog-3.0")

-- RealUI --
local RealUI = _G.RealUI
local L = RealUI.L
local ndb = RealUI.db.profile
--local ndbc = RealUI.db.char
local ndbg = RealUI.db.global

local order = 0

--[[
local uiTweaks do
    order = order + 1
    local eventNotify do
        local MODNAME = "EventNotifier"
        local EventNotifier = RealUI:GetModule(MODNAME)
        local db = EventNotifier.db.profile
    end

    uiTweaks = {
        name = L["Tweaks_UITweaks"],
        desc = L["Tweaks_UITweaksDesc"],
        type = "group",
        order = order,
        args = {
        }
    }
end
]]
local function CreateToggleOption(slug, name)
    local modObj = RealUI:GetModule(slug)
    return {
        name = name,
        desc = L["General_EnabledDesc"]:format(name),
        type = "toggle",
        get = function() return RealUI:GetModuleEnabled(slug) end,
        set = function(info, value)
            RealUI:SetModuleEnabled(slug, value)
            if modObj.RefreshMod then
                modObj:RefreshMod()
            end
        end
    }
end

local core do
    debug("Adv Core")
    local infoLine do
        local blocks = {
            start =         {L["Start"]},
            mail =          {_G.MAIL_LABEL},
            guild =         {_G.ACHIEVEMENTS_GUILD_TAB},
            friends =       {_G.QUICKBUTTON_NAME_FRIENDS},
            durability =    {_G.DURABILITY},
            bag =           {_G.INVTYPE_BAG},
            currency =      {_G.BONUS_ROLL_REWARD_CURRENCY},
            xprep =         {L["Progress"]},
            clock =         {_G.TIMEMANAGER_TITLE},
            pc =            {L["Sys_SysInfo"]},
            specchanger =   {L["Spec_SpecChanger"]},
            layoutchanger = {L["Layout_LayoutChanger"]},
            metertoggle =   {L["Meters_Header"]},
        }

        local MODNAME = "InfoLine"
        local InfoLine = RealUI:GetModule(MODNAME)
        local db = InfoLine.db.profile
        infoLine = {
            name = L["InfoLine"],
            desc = "Information / Button display.",
            type = "group",
            childGroups = "tab",
            args = {
                header = {
                    name = L["InfoLine"],
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Information / Button display.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                position = {
                    name = "Position/Size",
                    type = "group",
                    order = 50,
                    args = {
                        parent = {
                            name = "Parent",
                            type = "group",
                            inline = true,
                            order = 10,
                            args = {
                                xleft = {
                                    name = "X Left",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(db.position.xleft) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.xleft = value
                                        InfoLine:UpdatePositions()
                                    end,
                                    order = 10,
                                },
                                xright = {
                                    name = "X Right",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(db.position.xright) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.xright = value
                                        InfoLine:UpdatePositions()
                                    end,
                                    order = 20,
                                },
                                y = {
                                    name = "Y",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(db.position.y) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.y = value
                                        InfoLine:UpdatePositions()
                                        InfoLine:SetBackground()
                                    end,
                                    order = 30,
                                },
                                xgap = {
                                    name = "Padding",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(db.position.xgap) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.xgap = value
                                        InfoLine:UpdatePositions()
                                    end,
                                    order = 40,
                                },
                            },
                        },
                        text = {
                            name = "Text",
                            type = "group",
                            inline = true,
                            order = 20,
                            args = {
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(db.text.yoffset) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.text.yoffset = value
                                        InfoLine:UpdatePositions()
                                    end,
                                    order = 10,
                                },
                                tablets = {
                                    name = "Tablet Font Sizes",
                                    type = "group",
                                    inline = true,
                                    order = 20,
                                    args = {
                                        headersize = {
                                            name = "Header",
                                            type = "input",
                                            width = "half",
                                            get = function(info) return tostring(db.text.tablets.headersize) end,
                                            set = function(info, value)
                                                value = RealUI:ValidateOffset(value)
                                                db.text.tablets.headersize = value
                                                InfoLine:Refresh()
                                            end,
                                            order = 10,
                                        },
                                        columnsize = {
                                            name = "Column Titles",
                                            type = "input",
                                            width = "half",
                                            get = function(info) return tostring(db.text.tablets.columnsize) end,
                                            set = function(info, value)
                                                value = RealUI:ValidateOffset(value)
                                                db.text.tablets.columnsize = value
                                                InfoLine:Refresh()
                                            end,
                                            order = 20,
                                        },
                                        normalsize = {
                                            name = "Normal",
                                            type = "input",
                                            width = "half",
                                            get = function(info) return tostring(db.text.tablets.normalsize) end,
                                            set = function(info, value)
                                                value = RealUI:ValidateOffset(value)
                                                db.text.tablets.normalsize = value
                                                InfoLine:Refresh()
                                            end,
                                            order = 30,
                                        },
                                        hintsize = {
                                            name = "Hint",
                                            type = "input",
                                            width = "half",
                                            get = function(info) return tostring(db.text.tablets.hintsize) end,
                                            set = function(info, value)
                                                value = RealUI:ValidateOffset(value)
                                                db.text.tablets.hintsize = value
                                                InfoLine:Refresh()
                                            end,
                                            order = 40,
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
                colors = {
                    name = "Colors",
                    type = "group",
                    order = 60,
                    args = {
                        normal = {
                            name = "Normal",
                            type = "color",
                            get = function(info,r,g,b)
                                return db.colors.normal[1], db.colors.normal[2], db.colors.normal[3]
                            end,
                            set = function(info,r,g,b)
                                db.colors.normal[1] = r
                                db.colors.normal[2] = g
                                db.colors.normal[3] = b
                                InfoLine:Refresh()
                            end,
                            order = 10,
                        },
                        sep1 = {
                            name = " ",
                            type = "description",
                            order = 20,
                        },
                        highlight = {
                            name = "Highlight",
                            type = "color",
                            disabled = function()
                                if db.colors.classcolorhighlight then return true else return false end
                            end,
                            get = function(info,r,g,b)
                                return db.colors.highlight[1], db.colors.highlight[2], db.colors.highlight[3]
                            end,
                            set = function(info,r,g,b)
                                db.colors.highlight[1] = r
                                db.colors.highlight[2] = g
                                db.colors.highlight[3] = b
                                InfoLine:Refresh()
                            end,
                            order = 30,
                        },
                        classcolorhighlight = {
                            name = "Class Color Highlight",
                            desc = "Use your Class Color for the highlight.",
                            type = "toggle",
                            get = function() return db.colors.classcolorhighlight end,
                            set = function(info, value)
                                db.colors.classcolorhighlight = value
                                InfoLine:Refresh()
                            end,
                            order = 40,
                        },
                        sep2 = {
                            name = " ",
                            type = "description",
                            order = 50,
                        },
                        disabled = {
                            name = "Disabled",
                            type = "color",
                            get = function(info,r,g,b)
                                return db.colors.disabled[1], db.colors.disabled[2], db.colors.disabled[3]
                            end,
                            set = function(info,r,g,b)
                                db.colors.disabled[1] = r
                                db.colors.disabled[2] = g
                                db.colors.disabled[3] = b
                                InfoLine:Refresh()
                            end,
                            order = 60,
                        },
                        ttheader = {
                            name = "Tooltip Header 1",
                            type = "color",
                            get = function(info,r,g,b)
                                return db.colors.ttheader[1], db.colors.ttheader[2], db.colors.ttheader[3]
                            end,
                            set = function(info,r,g,b)
                                db.colors.ttheader[1] = r
                                db.colors.ttheader[2] = g
                                db.colors.ttheader[3] = b
                                InfoLine:Refresh()
                            end,
                            order = 70,
                        },
                        orange1 = {
                            name = "Header 1",
                            type = "color",
                            get = function(info,r,g,b)
                                return RealUI.media.colors.orange[1], RealUI.media.colors.orange[2], RealUI.media.colors.orange[3]
                            end,
                            set = function(info,r,g,b)
                                RealUI.media.colors.orange[1] = r
                                RealUI.media.colors.orange[2] = g
                                RealUI.media.colors.orange[3] = b
                                InfoLine:Refresh()
                            end,
                            order = 80,
                        },
                        blue1 = {
                            name = "Header 2",
                            type = "color",
                            get = function(info,r,g,b)
                                return RealUI.media.colors.blue[1], RealUI.media.colors.blue[2], RealUI.media.colors.blue[3]
                            end,
                            set = function(info,r,g,b)
                                RealUI.media.colors.blue[1] = r
                                RealUI.media.colors.blue[2] = g
                                RealUI.media.colors.blue[3] = b
                                InfoLine:Refresh()
                            end,
                            order = 90,
                        },
                        blue2 = {
                            name = "Header 3",
                            type = "color",
                            get = function(info,r,g,b)
                                return RealUI.media.colors.blue[1], RealUI.media.colors.blue[2], RealUI.media.colors.blue[3]
                            end,
                            set = function(info,r,g,b)
                                RealUI.media.colors.blue[1] = r
                                RealUI.media.colors.blue[2] = g
                                RealUI.media.colors.blue[3] = b
                                InfoLine:Refresh()
                            end,
                            order = 100,
                        },
                    },
                },
                other = {
                    name = "Other",
                    type = "group",
                    order = 70,
                    args = {
                        icTips = {
                            name = "In Combat Tooltips",
                            desc = "Show the tooltips in combat.",
                            type = "toggle",
                            get = function() return db.other.icTips end,
                            set = function(info, value)
                                db.other.icTips = value
                                RealUI.InfoLineICTips = value        -- Tablet-2.0 use
                                InfoLine:Refresh()
                            end,
                            order = 10,
                        },
                        showBG = {
                            name = L["InfoLine_ShowBG"],
                            type = "toggle",
                            get = function() return ndb.settings.infoLineBackground end,
                            set = function(info, value)
                                ndb.settings.infoLineBackground = value
                                InfoLine:SetBackground()
                            end,
                            order = 10,
                        },
                        clock = {
                            name = "Clock",
                            type = "group",
                            inline = true,
                            order = 20,
                            args = {
                                clock24 = {
                                    name = "24 hour clock",
                                    desc = "Show the time in 24 hour format.",
                                    type = "toggle",
                                    get = function() return db.other.clock.hr24 end,
                                    set = function(info, value)
                                        db.other.clock.hr24 = value
                                        InfoLine:Refresh()
                                    end,
                                    order = 10,
                                },
                                clocklocal = {
                                    name = "Use local time",
                                    desc = "Show the time at your home.",
                                    type = "toggle",
                                    get = function() return db.other.clock.uselocal end,
                                    set = function(info, value)
                                        db.other.clock.uselocal = value
                                        InfoLine:Refresh()
                                    end,
                                    order = 20,
                                },
                            },
                        },
                        tablets = {
                            name = "Info Displays",
                            type = "group",
                            inline = true,
                            order = 30,
                            args = {
                                maxheight = {
                                    name = "Max Height",
                                    desc = "Maximum height of the Info Displays. May require a UI reload (/rl) to take effect.",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(db.other.tablets.maxheight) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.other.tablets.maxheight = value
                                    end,
                                    order = 10,
                                },
                            },
                        },
                    },
                },
            },
        }

        -- Create blocks options table
        local elementopts = {
            name = "Blocks",
            type = "group",
            order = 40,
            args = {},
        }
        local elementordercnt = 10
        for k_e, v_e in next, blocks do
            -- Create base options for blocks
            elementopts.args[k_e] = {
                name = blocks[k_e][1],
                desc = "Enable the "..blocks[k_e][1].." block.",
                type = "toggle",
                get = function() return db.elements[k_e] end,
                set = function(info, value)
                    db.elements[k_e] = value
                    InfoLine:Refresh()
                end,
                order = elementordercnt,
            }
            elementordercnt = elementordercnt + 10
        end
        infoLine.args.elements = elementopts
    end
    local pitch do
        local MODNAME = "Pitch"
        local Pitch = RealUI:GetModule(MODNAME)
        local db = Pitch.db.profile
        pitch = {
            name = "Pitch Display",
            desc = "Graphical display of Flight/Swimming pitch.",
            type = "group",
            childGroups = "tab",
            args = {
                header = {
                    name = "Pitch Display",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Graphical display of Flight/Swimming pitch.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the Pitch Display module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value) 
                        RealUI:SetModuleEnabled(MODNAME, value)
                    end,
                    order = 30,
                },
                gap1 = {
                    name = " ",
                    type = "description",
                    order = 31,
                },
                visibility = {
                    name = "Visibility",
                    type = "group",
                    inline = true,
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 40,
                    args = {
                        flying = {
                            name = "Flying",
                            desc = "Show the Pitch display while flying.",
                            type = "toggle",
                            get = function() return db.visibility.flying end,
                            set = function(info, value) 
                                db.visibility.flying = value
                            end,
                            order = 10,
                        },
                        swimming = {
                            name = "Swimming",
                            desc = "Show the Pitch display while swimming.",
                            type = "toggle",
                            get = function() return db.visibility.swimming end,
                            set = function(info, value) 
                                db.visibility.swimming = value
                            end,
                            order = 20,
                        },
                        combat = {
                            name = "Combat",
                            desc = "Show the Pitch display while in combat.",
                            type = "toggle",
                            get = function() return db.visibility.combat end,
                            set = function(info, value) 
                                db.visibility.combat = value
                            end,
                            order = 30,
                        },
                    },
                },
                gap2 = {
                    name = " ",
                    type = "description",
                    order = 41,
                },
                position = {
                    name = "Position",
                    type = "group",
                    inline = true,
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 50,
                    args = {
                        x = {
                            name = "X Offset",
                            type = "input",
                            width = "half",
                            get = function(info) return _G.tostring(db.position.x) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.position.x = value
                                Pitch:UpdatePosition()
                            end,
                            order = 10,
                        },
                        y = {
                            name = "Y Offset",
                            type = "input",
                            width = "half",
                            get = function(info) return _G.tostring(db.position.y) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.position.y = value
                                Pitch:UpdatePosition()
                            end,
                            order = 20,
                        },
                    },
                },
                gap3 = {
                    name = " ",
                    type = "description",
                    order = 51,
                },
                animation = {
                    name = "Animation",
                    type = "group",
                    inline = true,
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 60,
                    args = {
                        fadetime = {
                            name = "Fade-Out Time",
                            desc = "Time to wait until fading out the Pitch display.",
                            type = "range",
                            min = 0, max = 10, step = 0.25,
                            get = function(info) return db.animation.fadetime end,
                            set = function(info, value) 
                                db.animation.fadetime = value
                            end,
                            order = 10,
                        },
                    },
                },
                gap4 = {
                    name = " ",
                    type = "description",
                    order = 61,
                },
                appearance = {
                    name = "Appearance",
                    type = "group",
                    inline = true,
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 70,
                    args = {
                        oapcity = {
                            name = "Opacity",
                            type = "group",
                            inline = true,
                            order = 10,
                            args = {
                                surround = {
                                    name = "Surround",
                                    type = "range",
                                    isPercent = true,
                                    min = 0, max = 1, step = 0.05,
                                    get = function(info) return db.appearance.opacity.surround end,
                                    set = function(info, value) 
                                        db.appearance.opacity.surround = value
                                        Pitch:UpdateColors()
                                    end,
                                    order = 10,
                                },
                                background = {
                                    name = "Background",
                                    type = "range",
                                    isPercent = true,
                                    min = 0, max = 1, step = 0.05,
                                    get = function(info) return db.appearance.opacity.background end,
                                    set = function(info, value) 
                                        db.appearance.opacity.background = value
                                        Pitch:UpdateColors()
                                    end,
                                    order = 20,
                                },
                            },
                        },
                    },
                },
            },
        }
    end
    local playerShields do
        local MODNAME = "PlayerShields"
        local PlayerShields = RealUI:GetModule(MODNAME)
        local db = PlayerShields.db.profile
        playerShields = {
            name = "Player Shields",
            desc = "Tracks absorbs/shields on the player.",
            type = "group",
            childGroups = "tab",
            args = {
                header = {
                    name = "Player Shields",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Tracks absorbs/shields on the player.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the Player Shields module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled(MODNAME, value)
                    end,
                    order = 30,
                },
                gap1 = {
                    name = " ",
                    type = "description",
                    order = 31,
                },
                show = {
                    name = "Show",
                    type = "group",
                    inline = true,
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                    order = 40,
                    args = {
                        solo = {
                            name = "While Solo",
                            type = "toggle",
                            get = function(info) return db.show.solo end,
                            set = function(info, value)
                                db.show.solo = value
                                PlayerShields:UpdateVisibility()
                            end,
                            order = 10,
                        },
                        pve = {
                            name = "In PvE",
                            type = "toggle",
                            get = function(info) return db.show.pve end,
                            set = function(info, value)
                                db.show.pve = value
                                PlayerShields:UpdateVisibility()
                            end,
                            order = 20,
                        },
                        pvp = {
                            name = "In PvP",
                            type = "toggle",
                            get = function(info) return db.show.pvp end,
                            set = function(info, value)
                                db.show.pvp = value
                                PlayerShields:UpdateVisibility()
                            end,
                            order = 30,
                        },
                        onlyTank = {
                            name = "Only Role = Tank",
                            type = "toggle",
                            get = function(info) return db.show.onlyTank end,
                            set = function(info, value)
                                db.show.onlyTank = value
                                PlayerShields:UpdateVisibility()
                            end,
                            order = 40,
                        },
                        onlySpec = {
                            name = "Only Spec = Tank",
                            type = "toggle",
                            get = function(info) return db.show.onlySpec end,
                            set = function(info, value)
                                db.show.onlySpec = value
                                PlayerShields:UpdateVisibility()
                            end,
                            order = 50,
                        },
                    },
                },
                gap2 = {
                    name = " ",
                    type = "description",
                    order = 41,
                },
                sizeposition = {
                    name = "Size/Position",
                    type = "group",
                    inline = true,
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                    order = 50,
                    args = {
                        parent = {
                            name = "Parent",
                            desc = L["General_NoteParent"],
                            type = "input",
                            width = "double",
                            get = function(info) return _G.tostring(db.position.parent) end,
                            set = function(info, value)
                                db.position.parent = value
                            end,
                            order = 10,
                        },
                        gap1 = {
                            name = " ",
                            type = "description",
                            order = 11,
                        },
                        rPoint = {
                            name = "Anchor To",
                            type = "select",
                            style = "dropdown",
                            values = RealUI.globals.anchorPoints,
                            get = function(info)
                                for k,v in next, RealUI.globals.anchorPoints do
                                    if v == db.position.rPoint then return k end
                                end
                            end,
                            set = function(info, value)
                                db.position.rPoint = RealUI.globals.anchorPoints[value]
                            end,
                            order = 20,
                        },
                        point = {
                            name = "Anchor From",
                            type = "select",
                            style = "dropdown",
                            values = RealUI.globals.anchorPoints,
                            get = function(info)
                                for k,v in next, RealUI.globals.anchorPoints do
                                    if v == db.position.point then return k end
                                end
                            end,
                            set = function(info, value)
                                db.position.point = RealUI.globals.anchorPoints[value]
                            end,
                            order = 30,
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
                            order = 40,
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
                            order = 50,
                        },
                    },
                },
            },
        }
    end
    local screenSaver do
        local MODNAME = "ScreenSaver"
        local ScreenSaver = RealUI:GetModule(MODNAME)
        local db = ScreenSaver.db.profile
        screenSaver = {
            name = "Screen Saver",
            desc = "Dims the screen when you are AFK.",
            type = "group",
            childGroups = "tab",
            args = {
                header = {
                    name = "Screen Saver",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Dims the screen when you are AFK.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the Screen Saver module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled(MODNAME, value)
                    end,
                    order = 30,
                },
                gap1 = {
                    name = " ",
                    type = "description",
                    order = 31,
                },
                general = {
                    name = "General",
                    type = "group",
                    inline = true,
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 40,
                    args = {
                        opacity1 = {
                            name = "Initial Dim",
                            desc = "How dark to set the gameworld when you go AFK.",
                            type = "range",
                            isPercent = true,
                            min = 0, max = 1, step = 0.05,
                            get = function(info) return db.general.opacity1 end,
                            set = function(info, value) db.general.opacity1 = value end,
                            order = 10,
                        },
                        opacity2 = {
                            name = "5min+ Dim",
                            desc = "How dark to set the gameworld after 5 minutes of being AFK.",
                            type = "range",
                            isPercent = true,
                            min = 0, max = 1, step = 0.05,
                            get = function(info) return db.general.opacity2 end,
                            set = function(info, value) db.general.opacity2 = value end,
                            order = 20,
                        },
                        combatwarning = {
                            name = "Combat Warning",
                            desc = "Play a warning sound if you enter combat while AFK.",
                            type = "toggle",
                            get = function() return db.general.combatwarning end,
                            set = function(info, value)
                                db.general.combatwarning = value
                            end,
                            order = 30,
                        },
                    },
                },
                gap2 = {
                    name = " ",
                    type = "description",
                    order = 41,
                },
                panel = {
                    name = "Panel",
                    type = "group",
                    inline = true,
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 50,
                    args = {
                        automove = {
                            name = "Auto Move",
                            desc = "Reposition the Panel up and down the screen once every minute.",
                            type = "toggle",
                            get = function() return db.panel.automove end,
                            set = function(info, value)
                                db.panel.automove = value
                            end,
                            order = 20,
                        },
                    },
                },
            },
        }
    end
    local worldMarker do
        local MODNAME = "WorldMarker"
        local WorldMarker = RealUI:GetModule(MODNAME)
        local db = WorldMarker.db.profile
        worldMarker = {
            name = "World Marker",
            desc = "Quick access to World Markers.",
            type = "group",
            childGroups = "tab",
            args = {
                header = {
                    name = "World Marker",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Quick access to World Markers.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the WorldMarker module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value) 
                        if not _G.InCombatLockdown() then
                            RealUI:SetModuleEnabled(MODNAME, value)
                        else
                            _G.print("|cff0099ffRealUI: |r World Marker can't be enabled or disabled during combat.")
                        end
                    end,
                    order = 30,
                },
                gap1 = {
                    name = " ",
                    type = "description",
                    order = 31,
                },
                visibility = {
                    name = "Show the World Marker in..",
                    type = "group",
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 40,
                    args = {
                        arena = {
                            name = "Arenas",
                            type = "toggle",
                            get = function(info) return db.visibility.arena end,
                            set = function(info, value) 
                                db.visibility.arena = value
                                WorldMarker:UpdateVisibility()
                            end,
                            order = 10,
                        },
                        pvp = {
                            name = "Battlegrounds",
                            type = "toggle",
                            get = function(info) return db.visibility.pvp end,
                            set = function(info, value)
                                db.visibility.pvp = value
                                WorldMarker:UpdateVisibility()
                            end,
                            order = 20,
                        },
                        party = {
                            name = "5 Man Dungeons",
                            type = "toggle",
                            get = function(info) return db.visibility.party end,
                            set = function(info, value) 
                                db.visibility.party = value
                                WorldMarker:UpdateVisibility()
                            end,
                            order = 30,
                        },
                        raid = {
                            name = "Raid Dungeons",
                            type = "toggle",
                            get = function(info) return db.visibility.raid end,
                            set = function(info, value) 
                                db.visibility.raid = value 
                                WorldMarker:UpdateVisibility()
                            end,
                            order = 40,
                        },
                    },
                },
            },
        }
    end
    core = {
        name = "Core",
        desc = "Core RealUI modules.",
        type = "group",
        order = 0,
        args = {
            infoLine = infoLine,
            pitch = pitch,
            playerShields = playerShields,
            screenSaver = screenSaver,
            worldMarker = worldMarker,
        },
    }
end
local skins do
    debug("Adv Skins")
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
                            name = L["Fonts_NormalOffset"],
                            desc = L["Fonts_NormalOffsetDesc"],
                            type = "range",
                            min = -6, max = 6, step = 1,
                            get = function(info) return db.standard.sizeadjust end,
                            set = function(info, value)
                                db.standard.sizeadjust = value
                            end,
                            order = 10,
                        },
                        changeYellow = {
                            name = L["Fonts_ChangeYellow"],
                            desc = L["Fonts_ChangeYellowDesc"],
                            type = "toggle",
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
                            name = L["Fonts_Normal"],
                            desc = L["Fonts_NormalDesc"],
                            type = "select",
                            dialogControl = "LSM30_Font",
                            values = _G.AceGUIWidgetLSMlists.font,
                            get = function()
                                return font.standard[1]
                            end,
                            set = function(info, value)
                                font.standard[1] = value
                                font.standard[4] = LSM:Fetch("font", value)
                            end,
                            order = 30,
                        },
                        header = {
                            name = L["Fonts_Header"],
                            desc = L["Fonts_HeaderDesc"],
                            type = "select",
                            dialogControl = "LSM30_Font",
                            values = _G.AceGUIWidgetLSMlists.font,
                            get = function()
                                return font.header[1]
                            end,
                            set = function(info, value)
                                font.header[1] = value
                                font.header[4] = LSM:Fetch("font", value)
                            end,
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
                            dialogControl = "LSM30_Font",
                            values = _G.AceGUIWidgetLSMlists.font,
                            get = function()
                                return font.chat[1]
                            end,
                            set = function(info, value)
                                font.chat[1] = value
                                font.chat[4] = LSM:Fetch("font", value)
                            end,
                            order = 50,
                        },
                        outline = {
                            name = L["Fonts_Outline"],
                            type = "select",
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
                            name = L["Fonts_Font"],
                            type = "select",
                            dialogControl = "LSM30_Font",
                            values = _G.AceGUIWidgetLSMlists.font,
                            get = function()
                                return font.pixel.small[1]
                            end,
                            set = function(info, value)
                                font.pixel.small[1] = value
                                font.pixel.small[4] = LSM:Fetch("font", value)
                            end,
                            order = 10,
                        },
                        size = {
                            name = _G.FONT_SIZE,
                            type = "range",
                            min = 6, max = 28, step = 1,
                            get = function(info) return font.pixel.small[2] end,
                            set = function(info, value)
                                font.pixel.small[2] = value
                            end,
                            order = 20,
                        },
                        outline = {
                            name = L["Fonts_Outline"],
                            type = "select",
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
                            name = L["Fonts_Font"],
                            type = "select",
                            dialogControl = "LSM30_Font",
                            values = _G.AceGUIWidgetLSMlists.font,
                            get = function()
                                return font.pixel.large[1]
                            end,
                            set = function(info, value)
                                font.pixel.large[1] = value
                                font.pixel.large[4] = LSM:Fetch("font", value)
                            end,
                            order = 10,
                        },
                        size = {
                            name = _G.FONT_SIZE,
                            type = "range",
                            min = 6, max = 28, step = 1,
                            get = function(info) return font.pixel.large[2] end,
                            set = function(info, value)
                                font.pixel.large[2] = value
                            end,
                            order = 20,
                        },
                        outline = {
                            name = L["Fonts_Outline"],
                            type = "select",
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
                            name = L["Fonts_Font"],
                            type = "select",
                            dialogControl = "LSM30_Font",
                            values = _G.AceGUIWidgetLSMlists.font,
                            get = function()
                                return font.pixel.numbers[1]
                            end,
                            set = function(info, value)
                                font.pixel.numbers[1] = value
                                font.pixel.numbers[4] = LSM:Fetch("font", value)
                            end,
                            order = 10,
                        },
                        size = {
                            name = _G.FONT_SIZE,
                            type = "range",
                            min = 6, max = 28, step = 1,
                            get = function(info) return font.pixel.numbers[2] end,
                            set = function(info, value)
                                font.pixel.numbers[2] = value
                            end,
                            order = 20,
                        },
                        outline = {
                            name = L["Fonts_Outline"],
                            type = "select",
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
                            name = L["Fonts_Font"],
                            type = "select",
                            dialogControl = "LSM30_Font",
                            values = _G.AceGUIWidgetLSMlists.font,
                            get = function()
                                return font.pixel.cooldown[1]
                            end,
                            set = function(info, value)
                                font.pixel.cooldown[1] = value
                                font.pixel.cooldown[4] = LSM:Fetch("font", value)
                            end,
                            order = 10,
                        },
                        size = {
                            name = _G.FONT_SIZE,
                            type = "range",
                            min = 6, max = 28, step = 1,
                            get = function(info) return font.pixel.cooldown[2] end,
                            set = function(info, value)
                                font.pixel.cooldown[2] = value
                            end,
                            order = 20,
                        },
                        outline = {
                            name = L["Fonts_Outline"],
                            type = "select",
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
            get = function() return tostring(db.customScale) end,
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
    debug("Adv UITweaks")
    order = order + 1
    local altPowerBar do
        local MODNAME = "AltPowerBar"
        local AltPowerBar = RealUI:GetModule(MODNAME)
        local db = AltPowerBar.db.profile
        altPowerBar = {
            name = "Alt Power Bar",
            type = "group",
            childGroups = "tab",
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
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled(MODNAME, value)
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
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                    order = 50,
                    args = {
                        width = {
                            name = "Width",
                            type = "input",
                            width = "half",
                            get = function(info) return tostring(db.size.width) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.size.width = value
                                altPowerBar:UpdatePosition()
                            end,
                            order = 10,
                        },
                        height = {
                            name = "Height",
                            type = "input",
                            width = "half",
                            get = function(info) return tostring(db.size.height) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.size.height = value
                                altPowerBar:UpdatePosition()
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
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
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
                                    get = function(info) return tostring(db.position.x) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.x = value
                                        altPowerBar:UpdatePosition()
                                    end,
                                    order = 10,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(db.position.y) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.y = value
                                        altPowerBar:UpdatePosition()
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
                                        altPowerBar:UpdatePosition()
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
                                        altPowerBar:UpdatePosition()
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
    local chat do
        local MODNAME = "Chat"
        local Chat = RealUI:GetModule(MODNAME)
        local db = Chat.db.profile
        chat = {
            name = "Chat Extras",
            desc = "Extra modifications to the Chat window.",
            type = "group",
            args = {
                header = {
                    name = "Chat Extras",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Extra modifications to the Chat window.",
                    type = "description",
                    fontSize = "medium",
                    order = 11,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the Chat Extras module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value) 
                        RealUI:SetModuleEnabled(MODNAME, value)
                    end,
                    order = 20,
                },
                desc3 = {
                    name = "Note: You will need to reload the UI (/rl) for changes to take effect.",
                    type = "description",
                    order = 21,
                },
                gap1 = {
                    name = " ",
                    type = "description",
                    order = 22,
                },
                modules = {
                    name = "Modules",
                    type = "group",
                    inline = true,
                    disabled = function() return not(RealUI:GetModuleEnabled(MODNAME)) end,
                    order = 30,
                    args = {
                        tabs = {
                            name = "Chat Tabs",
                            desc = "Skins the Chat Tabs.",
                            type = "toggle",
                            get = function() return db.modules.tabs.enabled end,
                            set = function(info, value) 
                                db.modules.tabs.enabled = value
                            end,
                            order = 10,
                        },
                        opacity = {
                            name = "Opacity",
                            desc = "Adjusts the opacity of the Chat Frame, and controls how fast the frame and tabs fade in/out.",
                            type = "toggle",
                            get = function() return db.modules.opacity.enabled end,
                            set = function(info, value) 
                                db.modules.opacity.enabled = value
                            end,
                            order = 20,
                        },
                    },
                },
            },
        }
    end
    local cooldown do
        local MODNAME = "CooldownCount"
        local CooldownCount = RealUI:GetModule(MODNAME)
        local db = CooldownCount.db.profile
        local table_Justify = {"LEFT", "CENTER", "RIGHT"}
        cooldown = {
            name = L["Tweaks_CooldownCount"],
            desc = L["Tweaks_CooldownCountDesc"],
            type = "group",
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
                    get = function(info) return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled(MODNAME, value)
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
                    disabled = function(info) return not RealUI:GetModuleEnabled(MODNAME) end,
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
                    disabled = function(info) return not RealUI:GetModuleEnabled(MODNAME) end,
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
                    disabled = function(info) return not RealUI:GetModuleEnabled(MODNAME) end,
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
                    disabled = function(info) return not RealUI:GetModuleEnabled(MODNAME) end,
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
                    disabled = function(info) if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
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
                            get = function(info) return tostring(db.position.x) end,
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
                            get = function(info) return tostring(db.position.y) end,
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
    local errorHider do
        local MODNAME = "ErrorHider"
        local ErrorHider = RealUI:GetModule(MODNAME, true)
        if ErrorHider then
            local db = ErrorHider.db.profile
            errorHider = {
                name = "Error Hider",
                desc = "Hide specific error messages.",
                type = "group",
                args = {
                    header = {
                        name = "Error Hider",
                        type = "header",
                        order = 10,
                    },
                    desc = {
                        name = "Hide specific error messages.",
                        type = "description",
                        fontSize = "medium",
                        order = 20,
                    },
                    enabled = {
                        name = "Enabled",
                        desc = "Enable/Disable the Error Hider module.",
                        type = "toggle",
                        get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                        set = function(info, value) 
                            RealUI:SetModuleEnabled(MODNAME, value)
                        end,
                        order = 30,
                    },
                    gap1 = {
                        name = " ",
                        type = "description",
                        order = 31,
                    },
                },
            }
            -- Create Filter List options table
            local filteropts = {
                name = "Filter List",
                type = "group",
                inline = true,
                disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                order = 40,
                args = {
                    hideall = {
                        name = "Hide All",
                        desc = "Hide all error messages.",
                        type = "toggle",
                        get = function() return db.hideall end,
                        set = function(info, value) 
                            db.hideall = value
                        end,
                        order = 20,
                    },
                    sep = {
                        name = " ",
                        type = "description",
                        fontSize = "medium",
                        order = 30,
                    },
                },
            }
            for errorText, isHidden in next, db.filterlist do
                -- Create base options for Addons
                filteropts.args[errorText] = {
                    name = errorText,
                    type = "toggle",
                    disabled = function() return db.hideall or (not RealUI:GetModuleEnabled(MODNAME)) end,
                    width = "full",
                    get = function(info) return db.filterlist[errorText] end,
                    set = function(info, value)
                        db.filterlist[errorText] = value
                    end,
                    order = 40
                }
            end
            errorHider.args.filterlist = filteropts
        end
    end
    local eventNotify do
        local MODNAME = "EventNotifier"
        local EventNotifier = RealUI:GetModule(MODNAME)
        local db = EventNotifier.db.profile
        eventNotify = {
            name = "Event Notifier",
            desc = "Displays notifications of events (pending calendar events, rare mob spawns, etc)",
            type = "group",
            childGroups = "tab",
            args = {
                header = {
                    name = "Event Notifier",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Displays notifications of events (pending calendar events, rare mob spawns, etc)",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the Event Notifier module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value) 
                        RealUI:SetModuleEnabled(MODNAME, value)
                        RealUI:ReloadUIDialog()
                    end,
                    order = 30,
                },
                events = {
                    name = "Events",
                    type = "group",
                    inline = true,
                    order = 40,
                    args = {
                        checkEvents = {
                            name = "Calender Invites",
                            type = "toggle",
                            get = function() return db.checkEvents end,
                            set = function(info, value) 
                                db.checkEvents = value
                            end,
                            order = 10,
                        },
                        checkGuildEvents = {
                            name = "Guild Events",
                            type = "toggle",
                            get = function() return db.checkGuildEvents end,
                            set = function(info, value) 
                                db.checkGuildEvents = value
                            end,
                            order = 20,
                        },
                        checkMinimapRares = {
                            name = _G.MINIMAP_LABEL.." ".._G.ITEM_QUALITY3_DESC,
                            type = "toggle",
                            get = function() return db.checkMinimapRares end,
                            set = function(info, value) 
                                db.checkMinimapRares = value
                            end,
                            order = 30,
                        },
                    },
                },
            },
        }
    end
    local frameMover do
        local MODNAME = "FrameMover"
        local FrameMover = RealUI:GetModule(MODNAME)
        local db = FrameMover.db.profile

        local FrameList = FrameMover.FrameList
        local MoveFrameGroup = FrameMover.MoveFrameGroup
        local isAddonControl = FrameMover.isAddonControl
        
        local function GetEnabled(addonSlug, addonInfo)
            if isAddonControl[addonSlug] then
                return RealUI:DoesAddonMove(isAddonControl[addonSlug])
            else
                return addonInfo.move
            end
        end
        -- Create Addons options table
        local addonOpts do
            addonOpts = {
                name = "Addons",
                type = "group",
                childGroups = "tab",
                disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                order = 50,
                args = {},
            }
            local addonOrderCnt = 10
            for addonSlug, addon in next, FrameList.addons do
                local addonInfo = db.addons[addonSlug]
                -- Create base options for Addons
                addonOpts.args[addonSlug] = {
                    name = addon.name,
                    type = "group",
                    childGroups = "tab",
                    disabled = function() return not(_G.IsAddOnLoaded(addon.name) and RealUI:GetModuleEnabled(MODNAME)) end,
                    order = addonOrderCnt,
                    args = {
                        header = {
                            name = ("Frame Mover - Addons - %s"):format(addon.name),
                            type = "header",
                            order = 10,
                        },
                        enabled = {
                            name = ("Move %s"):format(addon.name),
                            type = "toggle",
                            get = function(info)
                                return GetEnabled(addonSlug, addonInfo)
                            end,
                            set = function(info, value) 
                                if isAddonControl[addonSlug] then
                                    RealUI:ToggleAddonPositionControl(isAddonControl[addonSlug], value)
                                    if RealUI:DoesAddonMove(isAddonControl[addonSlug]) then
                                        FrameMover:MoveAddons()
                                    end
                                else
                                    addonInfo.move = value
                                    if addonInfo.move then
                                        FrameMover:MoveAddons()
                                    end
                                end
                            end,
                            order = 20,
                        },
                    },
                }
                
                -- Create options table for Frames
                local normalFrameOpts = {
                    name = "Frames",
                    type = "group",
                    disabled = function() return not GetEnabled(addonSlug, addonInfo) end,
                    order = 10,
                    args = {},
                }
                local normalFrameOrderCnt = 10
                for i = 1, #addon.frames do
                    normalFrameOpts.args[tostring(i)] = {
                        name = addon.frames[i].name,
                        type = "group",
                        inline = true,
                        order = normalFrameOrderCnt,
                        args = {
                            x = {
                                type = "input",
                                name = "X Offset",
                                width = "half",
                                get = function(info) return tostring(addonInfo.frames[i].x) end,
                                set = function(info, value)
                                    value = RealUI:ValidateOffset(value)
                                    addonInfo.frames[i].x = value
                                    FrameMover:MoveAddons()
                                end,
                                order = 10,
                            },
                            yoffset = {
                                name = "Y Offset",
                                type = "input",
                                width = "half",
                                get = function(info) return tostring(addonInfo.frames[i].y) end,
                                set = function(info, value)
                                    value = RealUI:ValidateOffset(value)
                                    addonInfo.frames[i].y = value
                                    FrameMover:MoveAddons()
                                end,
                                order = 20,
                            },
                            anchorto = {
                                name = "Anchor To",
                                type = "select",
                                values = RealUI.globals.anchorPoints,
                                get = function(info) 
                                    for idx, point in next, RealUI.globals.anchorPoints do
                                        if point == addonInfo.frames[i].rpoint then return idx end
                                    end
                                end,
                                set = function(info, value)
                                    addonInfo.frames[i].rpoint = RealUI.globals.anchorPoints[value]
                                    FrameMover:MoveAddons()
                                end,
                                order = 30,
                            },
                            anchorfrom = {
                                name = "Anchor From",
                                type = "select",
                                values = RealUI.globals.anchorPoints,
                                get = function(info) 
                                    for idx, point in next, RealUI.globals.anchorPoints do
                                        if point == addonInfo.frames[i].point then return idx end
                                    end
                                end,
                                set = function(info, value)
                                    addonInfo.frames[i].point = RealUI.globals.anchorPoints[value]
                                    FrameMover:MoveAddons()
                                end,
                                order = 40,
                            },
                            parent = {
                                name = "Parent",
                                desc = L["General_NoteParent"],
                                type = "input",
                                width = "double",
                                get = function(info) return addonInfo.frames[i].parent end,
                                set = function(info, value)
                                    if not _G[value] then value = "UIParent" end
                                    addonInfo.frames[i].parent = value
                                    FrameMover:MoveAddons()
                                end,
                                order = 50,
                            },
                        },
                    }
                    normalFrameOrderCnt = normalFrameOrderCnt + 10
                end
                addonOpts.args[addonSlug].args.frames = normalFrameOpts
                
                if addon.hashealing then
                    -- Healing Enable option
                    addonOpts.args[addonSlug].args.healingenabled = {
                        name = "Enable Healing Layout",
                        type = "toggle",
                        get = function(info) return addonInfo.healing end,
                        set = function(info, value) 
                            addonInfo.healing = value 
                            if addonInfo.move then
                                FrameMover:MoveAddons()
                            end
                        end,
                        order = 30,
                    }

                    -- Create options table for Healing Frames
                    local normalHealingFrameOpts = {
                        name = "Healing Layout Frames",
                        type = "group",
                        disabled = function() return not ( GetEnabled(addonSlug, addonInfo) and addonInfo.healing ) end,
                        order = 50,
                        args = {},
                    }
                    local normalHealingFrameOrderCnt = 10       
                    for i = 1, #addon.frameshealing do
                        normalHealingFrameOpts.args[tostring(i)] = {
                            name = addon.frameshealing[i].name,
                            type = "group",
                            inline = true,
                            order = normalHealingFrameOrderCnt,
                            args = {
                                x = {
                                    name = "X Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(addonInfo.frameshealing[i].x) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        addonInfo.frameshealing[i].x = value
                                        FrameMover:MoveAddons()
                                    end,
                                    order = 10,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(addonInfo.frameshealing[i].y) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        addonInfo.frameshealing[i].y = value
                                        FrameMover:MoveAddons()
                                    end,
                                    order = 20,
                                },
                                anchorto = {
                                    name = "Anchor To",
                                    type = "select",
                                    values = RealUI.globals.anchorPoints,
                                    get = function(info) 
                                        for idx, point in next, RealUI.globals.anchorPoints do
                                            if point == addonInfo.frameshealing[i].rpoint then return idx end
                                        end
                                    end,
                                    set = function(info, value)
                                        addonInfo.frameshealing[i].rpoint = RealUI.globals.anchorPoints[value]
                                        FrameMover:MoveAddons()
                                    end,
                                    order = 30,
                                },
                                anchorfrom = {
                                    name = "Anchor From",
                                    type = "select",
                                    values = RealUI.globals.anchorPoints,
                                    get = function(info) 
                                        for idx, point in next, RealUI.globals.anchorPoints do
                                            if point == addonInfo.frameshealing[i].point then return idx end
                                        end
                                    end,
                                    set = function(info, value)
                                        addonInfo.frameshealing[i].point = RealUI.globals.anchorPoints[value]
                                        FrameMover:MoveAddons()
                                    end,
                                    order = 40,
                                },
                                parent = {
                                    name = "Parent",
                                    desc = L["General_NoteParent"],
                                    type = "input",
                                    width = "double",
                                    get = function(info) return addonInfo.frameshealing[i].parent end,
                                    set = function(info, value)
                                        if not _G[value] then value = "UIParent" end
                                        addonInfo.frameshealing[i].parent = value
                                        FrameMover:MoveAddons()
                                    end,
                                    order = 50,
                                },
                            },
                        }
                        normalHealingFrameOrderCnt = normalHealingFrameOrderCnt + 10
                    end
                    addonOpts.args[addonSlug].args.healingframes = normalHealingFrameOpts
                end
                
                addonOrderCnt = addonOrderCnt + 10  
            end
        end
        
        -- Create UIFrames options table
        local uiFramesOpts do
            uiFramesOpts = {
                name = "UI Frames",
                type = "group",
                disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                order = 60,
                args = {},
            }
            local uiFramesOrderCnt = 10 
            for uiSlug, ui in next, FrameList.uiframes do
                local uiInfo = db.uiframes[uiSlug]
                -- Create base options for UIFrames
                uiFramesOpts.args[uiSlug] = {
                    type = "group",
                    name = ui.name,
                    order = uiFramesOrderCnt,
                    args = {
                        header = {
                            type = "header",
                            name = ("Frame Mover - UI Frames - %s"):format(ui.name),
                            order = 10,
                        },
                        enabled = {
                            type = "toggle",
                            name = ("Move %s"):format(ui.name),
                            get = function(info) return uiInfo.move end,
                            set = function(info, value) 
                                uiInfo.move = value 
                                if uiInfo.move and ui.frames then MoveFrameGroup(ui.frames, uiInfo.frames) end
                            end,
                            order = 20,
                        },
                    },
                }
                
                -- Create options table for Frames
                if ui.frames then
                    local frameopts = {
                        name = "Frames",
                        type = "group",
                        inline = true,
                        disabled = function() if uiInfo.move then return false else return true end end,
                        order = 30,
                        args = {},
                    }
                    local FrameOrderCnt = 10
                    for i = 1, #ui.frames do
                        frameopts.args[tostring(i)] = {
                            type = "group",
                            name = ui.frames[i].name,
                            inline = true,
                            order = FrameOrderCnt,
                            args = {
                                x = {
                                    type = "input",
                                    name = "X Offset",
                                    width = "half",
                                    order = 10,
                                    get = function(info) return tostring(uiInfo.frames[i].x) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        uiInfo.frames[i].x = value
                                        MoveFrameGroup(ui.frames, uiInfo.frames)
                                    end,
                                },
                                yoffset = {
                                    type = "input",
                                    name = "Y Offset",
                                    width = "half",
                                    order = 20,
                                    get = function(info) return tostring(uiInfo.frames[i].y) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        uiInfo.frames[i].y = value
                                        MoveFrameGroup(ui.frames, uiInfo.frames)
                                    end,
                                },
                                anchorto = {
                                    type = "select",
                                    name = "Anchor To",
                                    get = function(info) 
                                        for idx, point in next, RealUI.globals.anchorPoints do
                                            if point == uiInfo.frames[i].rpoint then return idx end
                                        end
                                    end,
                                    set = function(info, value)
                                        uiInfo.frames[i].rpoint = RealUI.globals.anchorPoints[value]
                                        MoveFrameGroup(ui.frames, uiInfo.frames)
                                    end,
                                    style = "dropdown",
                                    values = RealUI.globals.anchorPoints,
                                    order = 30,
                                },
                                anchorfrom = {
                                    type = "select",
                                    name = "Anchor From",
                                    get = function(info) 
                                        for idx, point in next, RealUI.globals.anchorPoints do
                                            if point == uiInfo.frames[i].point then return idx end
                                        end
                                    end,
                                    set = function(info, value)
                                        uiInfo.frames[i].point = RealUI.globals.anchorPoints[value]
                                        MoveFrameGroup(ui.frames, uiInfo.frames)
                                    end,
                                    style = "dropdown",
                                    values = RealUI.globals.anchorPoints,
                                    order = 40,
                                },
                            },
                        }
                        FrameOrderCnt = FrameOrderCnt + 10
                    end
                    
                    -- Add Frames to UI Frames options
                    uiFramesOpts.args[uiSlug].args.frames = frameopts
                    uiFramesOrderCnt = uiFramesOrderCnt + 10
                end
            end
        end
        
        -- Create Hide options table
        local hideOpts do
            hideOpts = {
                name = "Hide Frames",
                type = "group",
                disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                order = 70,
                args = {
                    header = {
                        type = "header",
                        name = "Frame Mover - Hide Frames",
                        order = 10,
                    },
                    sep = {
                        type = "description",
                        name = " ",
                        order = 20,
                    },
                    note = {
                        type = "description",
                        name = "Note: To make a frame visible again after it has been hidden, you will need to reload the UI (type: /rl).",
                        order = 30,
                    },
                    hideframes = {
                        type = "group",
                        name = "Hide",
                        inline = true,
                        order = 40,
                        args = {},
                    },
                },
            }
            -- Add all frames to Hide Frames options
            local hideOrderCnt = 10 
            for hideSlug, hide in next, FrameList.hide do
                local hideInfo = db.hide [hideSlug]
                -- Create base options for Hide
                hideOpts.args.hideframes.args[hideSlug] = {
                    type = "toggle",
                    name = hide.name,
                    get = function(info) return hideInfo.hide end,
                    set = function(info, value) 
                        hideInfo.hide = value 
                        if hideInfo.hide then
                            FrameMover:HideFrames()
                        else
                            RealUI:ReloadUIDialog()
                        end
                    end,
                    order = hideOrderCnt,
                }

                hideOrderCnt = hideOrderCnt + 10        
            end
        end

        -- Add extra options to Options table
        frameMover = {
            name = "Frame Mover",
            desc = "Automatically Move/Hide certain AddOns/Frames.",
            type = "group",
            args = {
                header = {
                    type = "header",
                    name = "Frame Mover/Hider",
                    order = 10,
                },
                desc = {
                    type = "description",
                    name = "Automatically Move/Hide certain AddOns/Frames.",
                    fontSize = "medium",
                    order = 20,
                },
                addons = addonOpts,
                uiframes = uiFramesOpts,
                hide = hideOpts,
            },
        }
    end
    local loot do
        local MODNAME = "Loot"
        local Loot = RealUI:GetModule(MODNAME)
        local db = Loot.db.profile
        loot = {
            name = "Loot",
            desc = "Modifies the appearance of the Loot windows.",
            type = "group",
            childGroups = "tab",
            args = {
                header = {
                    name = "Loot",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Modifies the appearance of the Loot windows.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the Loot module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value) 
                        RealUI:SetModuleEnabled(MODNAME, value)
                        RealUI:ReloadUIDialog()
                    end,
                    order = 30,
                },
                gap1 = {
                    name = " ",
                    type = "description",
                    order = 31,
                },
                loot = {
                    name = "Loot Window",
                    type = "group",
                    inline = true,
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 40,
                    args = {
                        enabled = {
                            name = "Enabled",
                            desc = "Skins the Loot window.",
                            type = "toggle",
                            get = function() return db.loot.enabled end,
                            set = function(info, value) 
                                db.loot.enabled = value
                                RealUI:ReloadUIDialog()
                            end,
                            order = 10,
                        },
                        position = {
                            name = "Position",
                            type = "group",
                            inline = true,
                            order = 20,
                            args = {
                                cursor = {
                                    name = "Position at Cursor",
                                    type = "toggle",
                                    get = function() return db.loot.cursor end,
                                    set = function(info, value) 
                                        db.loot.cursor = value
                                        Loot:UpdateLootPosition()
                                    end,
                                    order = 10,
                                },
                                position = {
                                    name = "Custom Position",
                                    type = "group",
                                    inline = true,
                                    disabled = function() return db.loot.cursor end,
                                    order = 20,
                                    args = {
                                        x = {
                                            name = "Padding",
                                            type = "input",
                                            width = "half",
                                            get = function(info) return tostring(db.loot.static.x) end,
                                            set = function(info, value)
                                                value = RealUI:ValidateOffset(value)
                                                db.loot.static.x = value
                                                Loot:UpdateLootPosition()
                                            end,
                                            order = 10,
                                        },
                                        y = {
                                            name = "Y Offset",
                                            type = "input",
                                            width = "half",
                                            get = function(info) return tostring(db.loot.static.y) end,
                                            set = function(info, value)
                                                value = RealUI:ValidateOffset(value)
                                                db.loot.static.y = value
                                                Loot:UpdateLootPosition()
                                            end,
                                            order = 20,
                                        },
                                        anchor = {
                                            name = "Anchor From",
                                            type = "select",
                                            style = "dropdown",
                                            values = RealUI.globals.anchorPoints,
                                            get = function(info) 
                                                for k,v in next, RealUI.globals.anchorPoints do
                                                    if v == db.loot.static.anchor then return k end
                                                end
                                            end,
                                            set = function(info, value)
                                                db.loot.static.anchor = RealUI.globals.anchorPoints[value]
                                                Loot:UpdateLootPosition()
                                            end,
                                            order = 30,
                                        },
                                    },
                                },
                            },
                        },
                    },
                },
                gap2 = {
                    name = " ",
                    type = "description",
                    order = 41,
                },
                roll = {
                    name = "Group Loot",
                    type = "group",
                    inline = true,
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 50,
                    args = {
                        enabled = {
                            name = "Enabled",
                            desc = "Skins the Group Loot frames.",
                            type = "toggle",
                            width = "full",
                            get = function() return db.roll.enabled end,
                            set = function(info, value) 
                                db.roll.enabled = value
                                RealUI:ReloadUIDialog()
                            end,
                            order = 10,
                        },
                        vertical = {
                            name = "Y Offset",
                            type = "input",
                            width = "half",
                            get = function(info) return tostring(db.roll.vertical) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.roll.vertical = value
                                Loot:GroupLootPosition()
                            end,
                            order = 20,
                        },
                        horizontal = {
                            name = "X Offset",
                            type = "input",
                            width = "half",
                            get = function(info) return tostring(db.roll.horizontal) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.roll.horizontal = value
                                Loot:GroupLootPosition()
                            end,
                            order = 30,
                        },
                    },
                },
            },
        }
    end
    local minimap do
        local MODNAME = "MinimapAdv"
        local MinimapAdv = RealUI:GetModule(MODNAME)
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
            name = "Minimap",
            desc = "Advanced, minimalistic Minimap.",
            type = "group",
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
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled(MODNAME, value)
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
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
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
                                    get = function(info) return tostring(db.information.position.x) end,
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
                                    get = function(info) return tostring(db.information.position.y) end,
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
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
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
                                return not(db.hidden.enabled and RealUI:GetModuleEnabled(MODNAME))
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
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
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
                                    get = function(info) return tostring(db.position.x) end,
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
                                    get = function(info) return tostring(db.position.y) end,
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
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
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
                                    get = function(info) return tostring(db.expand.position.x) end,
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
                                    get = function(info) return tostring(db.expand.position.y) end,
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
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
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
                                return not(db.poi.enabled and RealUI:GetModuleEnabled(MODNAME))
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
                                return not(db.poi.enabled and RealUI:GetModuleEnabled(MODNAME))
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
    local mirrorBar do
        local MODNAME = "MirrorBar"
        local MirrorBar = RealUI:GetModule(MODNAME)
        local db = MirrorBar.db.profile
        mirrorBar = {
            name = "Mirror Bar",
            desc = "Display of Breath, Exhaustion and Feign Death.",
            type = "group",
            childGroups = "tab",
            args = {
                header = {
                    name = "Mirror Bar",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Display of Breath, Exhaustion and Feign Death.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the Mirror Bar module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled(MODNAME, value)
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
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
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
                                MirrorBar:UpdatePosition()
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
                                MirrorBar:UpdatePosition()
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
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
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
                                        MirrorBar:UpdatePosition()
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
                                        MirrorBar:UpdatePosition()
                                    end,
                                    order = 20,
                                },
                                anchorto = {
                                    name = "Anchor To",
                                    type = "select",
                                    style = "dropdown",
                                    values = RealUI.globals.anchorPoints,
                                    get = function(info)
                                        for k,v in next, RealUI.globals.anchorPoints do
                                            if v == db.position.anchorto then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        db.position.anchorto = RealUI.globals.anchorPoints[value]
                                        MirrorBar:UpdatePosition()
                                    end,
                                    order = 30,
                                },
                                anchorfrom = {
                                    name = "Anchor From",
                                    type = "select",
                                    style = "dropdown",
                                    values = RealUI.globals.anchorPoints,
                                    get = function(info)
                                        for k,v in next, RealUI.globals.anchorPoints do
                                            if v == db.position.anchorfrom then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        db.position.anchorfrom = RealUI.globals.anchorPoints[value]
                                        MirrorBar:UpdatePosition()
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
    local objectives do
        local MODNAME = "Objectives Adv."
        local ObjectivesAdv = RealUI:GetModule(MODNAME)
        local db = ObjectivesAdv.db.profile
        objectives = {
            name = "Objectives Adv.",
            desc = "Reposition the Objective Tracker.",
            type = "group",
            childGroups = "tab",
            args = {
                header = {
                    name = "Objectives Adv.",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Reposition the Objective Tracker.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the Objectives Adv. module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled(MODNAME, value)
                        ObjectivesAdv:RefreshMod()
                    end,
                    order = 30,
                },
                sizeposition = {
                    name = "Size/Position",
                    type = "group",
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 40,
                    args = {
                        header = {
                            name = "Adjust size and position.",
                            type = "description",
                            order = 10,
                        },
                        enabled = {
                            name = "Enabled",
                            type = "toggle",
                            get = function(info) return db.position.enabled end,
                            set = function(info, value)
                                db.position.enabled = value
                                ObjectivesAdv:UpdatePosition()
                                RealUI:ReloadUIDialog()
                            end,
                            order = 20,
                        },
                        note1 = {
                            name = "Note: Enabling/disabling the size/position adjustments will require a UI Reload to take full effect.",
                            type = "description",
                            order = 30,
                        },
                        gap1 = {
                            name = " ",
                            type = "description",
                            order = 31,
                        },
                        offsets = {
                            name = "Offsets",
                            type = "group",
                            inline = true,
                            disabled = function() return not(db.position.enabled) or not(RealUI:GetModuleEnabled(MODNAME)) end,
                            order = 40,
                            args = {
                                xoffset = {
                                    name = "X Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(db.position.x) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.x = value
                                        ObjectivesAdv:UpdatePosition()
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
                                        ObjectivesAdv:UpdatePosition()
                                    end,
                                    order = 20,
                                },
                                negheightoffset = {
                                    name = "Height Offset",
                                    desc = "How much shorter than screen height to make the Quest Watch Frame.",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(db.position.negheightofs) end,
                                    set = function(info, value)
                                        value = RealUI:ValidateOffset(value)
                                        db.position.negheightofs = value
                                        ObjectivesAdv:UpdatePosition()
                                    end,
                                    order = 30,
                                },
                            },
                        },
                        gap2 = {
                            name = " ",
                            type = "description",
                            order = 41,
                        },
                        anchor = {
                            name = "Position",
                            type = "group",
                            inline = true,
                            disabled = function() return not(db.position.enabled) or not(RealUI:GetModuleEnabled(MODNAME)) end,
                            order = 50,
                            args = {
                                anchorto = {
                                    name = "Anchor To",
                                    type = "select",
                                    style = "dropdown",
                                    values = RealUI.globals.anchorPoints,
                                    get = function(info)
                                        for k,v in next, RealUI.globals.anchorPoints do
                                            if v == db.position.anchorto then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        db.position.anchorto = RealUI.globals.anchorPoints[value]
                                        ObjectivesAdv:UpdatePosition()
                                    end,
                                    order = 10,
                                },
                                anchorfrom = {
                                    name = "Anchor From",
                                    type = "select",
                                    style = "dropdown",
                                    values = RealUI.globals.anchorPoints,
                                    get = function(info)
                                        for k,v in next, RealUI.globals.anchorPoints do
                                            if v == db.position.anchorfrom then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        db.position.anchorfrom = RealUI.globals.anchorPoints[value]
                                        ObjectivesAdv:UpdatePosition()
                                    end,
                                    order = 20,
                                },
                            },
                        },
                    },
                },
                hidden = {
                    name = "Automatic Collapse/Hide",
                    type = "group",
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 60,
                    args = {
                        header = {
                            name = "Automatically collapse the Quest Watch Frame in certain zones.",
                            type = "description",
                            order = 10,
                        },
                        enabled = {
                            name = "Enabled",
                            type = "toggle",
                            get = function(info) return db.hidden.enabled end,
                            set = function(info, value)
                                db.hidden.enabled = value
                                ObjectivesAdv:UpdateCollapseState()
                            end,
                            order = 20,
                        },
                        gap1 = {
                            name = " ",
                            type = "description",
                            order = 21,
                        },
                        collapse = {
                            name = "Collapse the Quest Watch Frame in..",
                            type = "group",
                            inline = true,
                            disabled = function() return not(RealUI:GetModuleEnabled(MODNAME) and db.hidden.enabled) end,
                            order = 30,
                            args = {
                                arena = {
                                    name = "Arenas",
                                    type = "toggle",
                                    get = function(info) return db.hidden.collapse.arena end,
                                    set = function(info, value)
                                        db.hidden.collapse.arena = value
                                        ObjectivesAdv:UpdateCollapseState()
                                    end,
                                    order = 10,
                                },
                                pvp = {
                                    name = "Battlegrounds",
                                    type = "toggle",
                                    get = function(info) return db.hidden.collapse.pvp end,
                                    set = function(info, value)
                                        db.hidden.collapse.pvp = value
                                        ObjectivesAdv:UpdateCollapseState()
                                    end,
                                    order = 20,
                                },
                                party = {
                                    name = "5 Man Dungeons",
                                    type = "toggle",
                                    get = function(info) return db.hidden.collapse.party end,
                                    set = function(info, value)
                                        db.hidden.collapse.party = value
                                        ObjectivesAdv:UpdateCollapseState()
                                    end,
                                    order = 30,
                                },
                                raid = {
                                    name = "Raid Dungeons",
                                    type = "toggle",
                                    get = function(info) return db.hidden.collapse.raid end,
                                    set = function(info, value)
                                        db.hidden.collapse.raid = value
                                        ObjectivesAdv:UpdateCollapseState()
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
                        hide = {
                            name = "Hide the Quest Watch Frame completely in..",
                            type = "group",
                            inline = true,
                            disabled = function() return not(db.hidden.enabled) or not(RealUI:GetModuleEnabled(MODNAME)) end,
                            order = 40,
                            args = {
                                arena = {
                                    name = "Arenas",
                                    type = "toggle",
                                    get = function(info) return db.hidden.hide.arena end,
                                    set = function(info, value)
                                        db.hidden.hide.arena = value
                                        ObjectivesAdv:UpdateHideState()
                                    end,
                                    order = 10,
                                },
                                pvp = {
                                    name = "Battlegrounds",
                                    type = "toggle",
                                    get = function(info) return db.hidden.hide.pvp end,
                                    set = function(info, value)
                                        db.hidden.hide.pvp = value
                                        ObjectivesAdv:UpdateHideState()
                                    end,
                                    order = 20,
                                },
                                party = {
                                    name = "5 Man Dungeons",
                                    type = "toggle",
                                    get = function(info) return db.hidden.hide.party end,
                                    set = function(info, value)
                                        db.hidden.hide.party = value
                                        ObjectivesAdv:UpdateHideState()
                                    end,
                                    order = 30,
                                },
                                raid = {
                                    name = "Raid Dungeons",
                                    type = "toggle",
                                    get = function(info) return db.hidden.hide.raid end,
                                    set = function(info, value)
                                        db.hidden.hide.raid = value
                                        ObjectivesAdv:UpdateHideState()
                                    end,
                                    order = 40,
                                },
                            },
                        },
                        --[[fade = {
                            type = "group",
                            name = L["General_CombatFade"],
                            inline = true,
                            order = 40,
                            args = {
                                incombat = {
                                    type = "range",
                                    name = "In-combat",
                                    min = 0, max = 1, step = 0.05,
                                    isPercent = true,
                                    get = function(info) return db.elements[ke].opacity.outofcombat end,
                                    set = function(info, value)
                                        db.elements[ke].opacity.outofcombat = value
                                        CombatFader:OptionsRefresh()
                                    end,
                                    order = 10,
                                },
                                harmtarget = {
                                    type = "range",
                                    name = "Attackable Target",
                                    min = 0, max = 1, step = 0.05,
                                    isPercent = true,
                                    get = function(info) return db.elements[ke].opacity.harmtarget end,
                                    set = function(info, value)
                                        db.elements[ke].opacity.harmtarget = value
                                        CombatFader:OptionsRefresh()
                                    end,
                                    order = 20,
                                },
                                outofcombat = {
                                    type = "range",
                                    name = "Out-of-combat",
                                    min = 0, max = 1, step = 0.05,
                                    isPercent = true,
                                    get = function(info) return db.elements[ke].opacity.incombat end,
                                    set = function(info, value)
                                        --print("OutCombat", ke)
                                        db.elements[ke].opacity.incombat = value
                                        CombatFader:OptionsRefresh()
                                    end,
                                    order = 30,
                                },
                            },
                        },]]
                    },
                },
            },
        }
    end
    local speechBubbles do
        local MODNAME = "SpeechBubbles"
        local SpeechBubbles = RealUI:GetModule(MODNAME)
        local db = SpeechBubbles.db.profile
        speechBubbles = {
            name = "Speech Bubbles",
            desc = "Skins the speech bubbles.",
            type = "group",
            args = {
                header = {
                    name = "Speech Bubbles",
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Skins the speech bubbles.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = "Enabled",
                    desc = "Enable/Disable the Speech Bubbles module.",
                    type = "toggle",
                    get = function() return RealUI:GetModuleEnabled(MODNAME) end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled(MODNAME, value)
                        RealUI:ReloadUIDialog()
                    end,
                    order = 30,
                },
                desc2 = {
                    name = " ",
                    type = "description",
                    order = 31,
                },
                desc3 = {
                    name = "Note: You will need to reload the UI (/rl) for changes to take effect.",
                    type = "description",
                    order = 32,
                },
                gap1 = {
                    name = " ",
                    type = "description",
                    order = 33,
                },
                general = {
                    name = "General",
                    type = "group",
                    inline = true,
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                    order = 40,
                    args = {
                        sendersize = {
                            name = "Sender Name Size",
                            type = "range",
                            min = 6, max = 32, step = 1,
                            get = function(info) return db.sendersize end,
                            set = function(info, value)
                                db.sendersize = value
                            end,
                            order = 10,
                        },
                        hideSender = {
                            name = "Hide Sender Name",
                            type = "toggle",
                            get = function() return db.hideSender end,
                            set = function(info, value)
                                db.hideSender = value
                            end,
                            order = 11,
                        },
                        messagesize = {
                            name = "Message Size",
                            type = "range",
                            min = 6, max = 32, step = 1,
                            get = function(info) return db.messagesize end,
                            set = function(info, value)
                                db.messagesize = value
                            end,
                            order = 20,
                        },
                        edgesize = {
                            name = "Edge Size",
                            type = "range",
                            min = 0, max = 20, step = 1,
                            get = function(info) return db.edgesize end,
                            set = function(info, value)
                                db.edgesize = value
                            end,
                            order = 30,
                        },
                    },
                },
                gap2 = {
                    name = " ",
                    type = "description",
                    order = 41,
                },
                colors = {
                    name = "Colors",
                    type = "group",
                    inline = true,
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                    order = 50,
                    args = {
                        background = {
                            name = "Background",
                            type = "color",
                            hasAlpha = true,
                            get = function(info,r,g,b,a)
                                return db.colors.bg[1], db.colors.bg[2], db.colors.bg[3], db.colors.bg[4]
                            end,
                            set = function(info,r,g,b,a)
                                db.colors.bg[1] = r
                                db.colors.bg[2] = g
                                db.colors.bg[3] = b
                                db.colors.bg[4] = a
                            end,
                            order = 10,
                        },
                        border = {
                            name = "Border",
                            type = "color",
                            hasAlpha = true,
                            get = function(info,r,g,b,a)
                                return db.colors.border[1], db.colors.border[2], db.colors.border[3], db.colors.border[4]
                            end,
                            set = function(info,r,g,b,a)
                                db.colors.border[1] = r
                                db.colors.border[2] = g
                                db.colors.border[3] = b
                                db.colors.border[4] = a
                            end,
                            order = 10,
                        },
                    },
                },
            },
        }
    end

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
            screenshot = CreateToggleOption("AchievementScreenshots", "Achievement Screenshots"),
            altPowerBar = altPowerBar,
            chat = chat,
            cooldown = cooldown,
            errorHider = errorHider,
            eventNotify = eventNotify,
            frameMover = frameMover,
            loot = loot,
            minimap = minimap,
            mirrorBar = mirrorBar,
            objectives = objectives,
            speechBubbles = speechBubbles,
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

debug("Adv Options")
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
