local _, private = ...
local options = private.options
local debug = private.debug

-- Lua Globals --
local _G = _G
local next = _G.next

-- Libs --
local ACD = _G.LibStub("AceConfigDialog-3.0")

-- RealUI --
local RealUI = _G.RealUI
local L = RealUI.L
--local ndb = RealUI.db.profile
local ndbc = RealUI.db.char

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
                type = "header",
                name = "RealUI Core",
                order = 10,
            },
            corenote = {
                type = "description",
                name = "Note: Only use these features if you need to. They may change or revert settings.",
                fontSize = "medium",
                order = 20,
            },
            sep1 = {
                type = "description",
                name = " ",
                order = 30,
            },
            reinstall = {
                type = "execute",
                name = "Reset RealUI",
                func = function() RealUI:ReInstall() end,
                order = 40,
            },
            sep2 = {
                type = "description",
                name = " ",
                order = 41,
            },
            resetnote = {
                type = "description",
                name = "This will erase all user changes and install a fresh copy of RealUI.",
                fontSize = "medium",
                order = 42,
            },
            gap1 = {
                name = " ",
                type = "description",
                order = 43,
            },
            character = {
                type = "group",
                name = "Character",
                inline = true,
                order = 50,
                args = {
                    resetchar = {
                        type = "execute",
                        name = "Re-initialize Character",
                        func = ResetChar,
                        order = 10,
                    },
                    sep = {
                        type = "description",
                        name = " ",
                        order = 20,
                    },
                    resetnote = {
                        type = "description",
                        name = "This will flag the current Character as being new to RealUI, and RealUI will run through the initial installation procedure for this Character. Use only if you experienced a faulty installation for this character. Not guaranteed to actually fix anything.",
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
    skins = {
        name = "Skins",
        desc = "Toggle skinning of UI frames.",
        type = "group",
        order = order,
        args = {
            windowOpacity = {
                name = L["Appearance_WinOpacity"],
                type = "range",
                isPercent = true,
                min = 0, max = 1, step = 0.05,
                get = function(info) return RealUI.media.window[4] end,
                set = function(info, value)
                    RealUI.media.window[4] = value
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
                end,
                order = 20,
            },
            header = {
                type = "header",
                name = "Skins",
                order = 30,
            },
        }
    }
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
            arg = "CooldownCount",
            type = "group",
            args = {
                header = {
                    name = "Cooldown Count",
                    type = "header",
                    order = 10,
                },
                desc3 = {
                    name = "Note: You will need to reload the UI (/rl) for changes to take effect.",
                    type = "description",
                    order = 22,
                },
                enabled = {
                    name = L["General_Enabled"],
                    desc = L["General_EnabledDesc"]:format(L["Tweaks_CooldownCount"]),
                    type = "toggle",
                    get = function(info)
                        for key, value in next, info do
                            debug("CD enabled", key, value)
                            if _G.type(value) == "table" then
                                for k, v in next, value do
                                    debug(key, k, v)
                                end
                            end
                        end
                        return RealUI:GetModuleEnabled(cooldown.arg)
                    end,
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
                    min = 0, max = 1, step = 0.05,
                    isPercent = true,
                    get = function(info) return db.minScale end,
                    set = function(info, value)
                        db.minScale = value
                    end,
                    disabled = function(info) return not RealUI:GetModuleEnabled(cooldown.arg) end,
                    order = 60,
                },
                minDuration = {
                    name = "Min Duration",
                    desc = "The minimum number of seconds a cooldown's duration must be to display text.",
                    type = "range",
                    min = 0, max = 30, step = 1,
                    get = function(info) return db.minDuration end,
                    set = function(info, value)
                        db.minDuration = value
                    end,
                    disabled = function(info) return not RealUI:GetModuleEnabled(cooldown.arg) end,
                    order = 70,
                },
                expiringDuration = {
                    name = "Expiring Duration",
                    desc = "The minimum number of seconds a cooldown must be to display in the expiring format.",
                    type = "range",
                    min = 0, max = 30, step = 1,
                    get = function(info) return db.expiringDuration end,
                    set = function(info, value)
                        db.expiringDuration = value
                    end,
                    disabled = function(info) return not RealUI:GetModuleEnabled(cooldown.arg) end,
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
                            type = "color",
                            name = "Expiring",
                            hasAlpha = false,
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
                            type = "color",
                            name = "Seconds",
                            hasAlpha = false,
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
                            type = "color",
                            name = "Minutes",
                            hasAlpha = false,
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
                            type = "color",
                            name = "Hours",
                            hasAlpha = false,
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
                            type = "color",
                            name = "days",
                            hasAlpha = false,
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
                            type = "select",
                            name = "Anchor",
                            get = function(info)
                                for k,v in next, RealUI.globals.anchorPoints do
                                    if v == db.position.point then return k end
                                end
                            end,
                            set = function(info, value)
                                db.position.point = RealUI.globals.anchorPoints[value]
                            end,
                            style = "dropdown",
                            width = nil,
                            values = RealUI.globals.anchorPoints,
                            order = 10,
                        },
                        x = {
                            type = "input",
                            name = "X",
                            width = "half",
                            order = 20,
                            get = function(info) return _G.tostring(db.position.x) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.position.x = value
                            end,
                        },
                        y = {
                            type = "input",
                            name = "Y",
                            width = "half",
                            order = 30,
                            get = function(info) return _G.tostring(db.position.y) end,
                            set = function(info, value)
                                value = RealUI:ValidateOffset(value)
                                db.position.y = value
                            end,
                        },
                        justify = {
                            type = "select",
                            name = "Text Justification",
                            get = function(info)
                                for k,v in next, table_Justify do
                                    if v == db.position.justify then return k end
                                end
                            end,
                            set = function(info, value)
                                db.position.justify = table_Justify[value]
                            end,
                            style = "dropdown",
                            width = nil,
                            values = table_Justify,
                            order = 40,
                        },
                    },
                },
            },
        }
    end
    uiTweaks = {
        name = "UI Tweaks",
        desc = "Minor functional tweaks for the default UI",
        type = "group",
        order = order,
        args = {
            addonList = {
                name = L["Tweaks_AddonList"],
                desc = L["General_EnabledDesc"]:format(L["Tweaks_AddonList"]),
                type = "toggle",
                get = function() return RealUI:GetModuleEnabled("AddonListAdv") end,
                set = function(info, value)
                    RealUI:SetModuleEnabled("AddonListAdv", value)
                    RealUI:GetModule("AddonListAdv"):RefreshMod()
                end,
            },
            cooldown = cooldown
        }
    }
end
local profiles do
    profiles = _G.LibStub("AceDBOptions-3.0"):GetOptionsTable(RealUI.db)
    profiles.order = -1
end

--[[
local core do
    core = {
        name = "Skins",
        desc = "Toggle skinning of UI frames.",
        type = "group",
        order = order,
        args = {
        }
    }
    order = order + 1
end
]]

options.RealUI = {
    type = "group",
    args = {
        core = core,
        skins = skins,
        uiTweaks = uiTweaks,
        profiles = profiles,
    }
}
