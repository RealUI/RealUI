local _, private = ...

-- Lua Globals --
local next = _G.next
local tostring = _G.tostring

-- Libs --
local ACD = _G.LibStub("AceConfigDialog-3.0")

-- RealUI --
local RealUI = _G.RealUI
local L = RealUI.L
local round = RealUI.Round

local CombatFader = RealUI:GetModule("CombatFader")
local FramePoint = RealUI:GetModule("FramePoint")
local uiWidth, uiHeight = RealUI.GetInterfaceSize()

local ValidateOffset = private.ValidateOffset
local CloseHuDWindow = private.CloseHuDWindow
local options = private.options
local debug = private.debug


options.HuD = {
    type = "group",
    args = {
        toggle = { -- This is for button creation
            name = L["HuD_ShowElements"],
            type = "group",
            order = 0,
            args = {
            },
        },
        close = { -- This is for button creation
            name = _G.CLOSE,
            icon = "close",
            type = "group",
            order = -1,
            args = {
            },
        },
    }
}

local optArgs = options.HuD.args


do -- Other
    debug("HuD Other")
    local MODNAME = "ActionBars"
    local ActionBars = RealUI:GetModule(MODNAME)
    optArgs.other = {
        name = _G.BINDING_HEADER_OTHER,
        icon = "sliders",
        type = "group",
        childGroups = "tab",
        order = 1,
        args = {
            advanced = {
                name = _G.ADVANCED_OPTIONS,
                type = "execute",
                func = function(info, ...)
                    RealUI.Debug("Config", "Config Bar")
                    RealUI.LoadConfig("RealUI")
                end,
                order = 0,
            },
            addon = {
                name = L["Control_AddonControl"],
                type = "execute",
                func = function(info, ...)
                    RealUI:GetModule("AddonControl"):ShowOptionsWindow()
                end,
                order = 2,
            },
            general = {
                name = _G.GENERAL,
                type = "group",
                order = 10,
                args = {
                    layout = {
                        name = L["Layout_Layout"],
                        type = "select",
                        values = function()
                            return {
                                L["Layout_DPSTank"],
                                L["Layout_Healing"],
                            }
                        end,
                        get = function(info)
                            return RealUI.db.char.layout.current
                        end,
                        set = function(info, value)
                            RealUI.db.char.layout.spec[_G.GetSpecialization()] = value
                            RealUI:UpdateLayout(value)
                        end,
                        order = 10,
                    },
                    linkLayout = {
                        name = L["Layout_Link"],
                        desc = L["Layout_LinkDesc"],
                        type = "toggle",
                        get = function() return RealUI.db.profile.positionsLink end,
                        set = function(info, value)
                            RealUI.db.profile.positionsLink = value

                            RealUI.cLayout = RealUI.db.char.layout.current
                            RealUI.ncLayout = RealUI.cLayout == 1 and 2 or 1

                            if value then
                                RealUI.db.profile.positions[RealUI.ncLayout] = RealUI.DeepCopy(RealUI.db.profile.positions[RealUI.cLayout])
                            end
                        end,
                        order = 20,
                    },
                    useLarge = {
                        name = L["HuD_UseLarge"],
                        desc = L["HuD_UseLargeDesc"],
                        type = "toggle",
                        get = function() return RealUI.db.profile.settings.hudSize == 2 end,
                        set = function(info, value)
                            RealUI.db.profile.settings.hudSize = value and 2 or 1
                            _G.StaticPopup_Show("RUI_ChangeHuDSize")
                        end,
                        order = 30,
                    },
                    hudVert = {
                        name = L["HuD_Vertical"],
                        desc = L["HuD_VerticalDesc"],
                        type = "range",
                        width = "full",
                        min = -round(uiHeight * 0.3),
                        max = round(uiHeight * 0.3),
                        step = 1,
                        bigStep = 4,
                        order = 40,
                        get = function(info) return RealUI.db.profile.positions[RealUI.cLayout]["HuDY"] end,
                        set = function(info, value)
                            RealUI.db.profile.positions[RealUI.cLayout]["HuDY"] = value
                            RealUI:UpdatePositioners()
                        end,
                    }
                }
            },
            spellalert = {
                name = _G.COMBAT_TEXT_SHOW_REACTIVES_TEXT,
                desc = L["Misc_SpellAlertsDesc"],
                type = "group",
                args = {
                    enabled = {
                        name = L["General_Enabled"],
                        desc = L["General_EnabledDesc"]:format(_G.COMBAT_TEXT_SHOW_REACTIVES_TEXT),
                        type = "toggle",
                        get = function() return RealUI:GetModuleEnabled("SpellAlerts") end,
                        set = function(info, value)
                            RealUI:SetModuleEnabled("SpellAlerts", value)
                            RealUI:ReloadUIDialog()
                        end,
                        order = 30,
                    },
                    position = {
                        name = L["HuD_Width"],
                        desc = L["Misc_SpellAlertsWidthDesc"],
                        type = "range",
                        width = "full",
                        min = round(uiWidth * 0.1),
                        max = round(uiWidth * 0.5),
                        step = 1,
                        bigStep = 4,
                        order = 30,
                        get = function(info) return RealUI.db.profile.positions[RealUI.cLayout]["SpellAlertWidth"] end,
                        set = function(info, value)
                            RealUI.db.profile.positions[RealUI.cLayout]["SpellAlertWidth"] = value
                            RealUI:UpdatePositioners()
                        end,
                    }
                }
            },
            actionbars = {
                name = _G.ACTIONBARS_LABEL:sub(67), -- cut out the "new feature icon"
                desc = L["ActionBars_ActionBarsDesc"],
                type = "group",
                args = {
                    advanced = {
                        name = "Bartender 4",
                        type = "execute",
                        func = function(info, ...)
                            ACD:Open("Bartender4")
                        end,
                        order = 10,
                    },
                    showDoodads = {
                        name = L["ActionBars_ShowDoodads"],
                        desc = L["ActionBars_ShowDoodadsDesc"],
                        type = "toggle",
                        get = function() return ActionBars.db.profile.showDoodads end,
                        set = function(info, value)
                            ActionBars.db.profile.showDoodads = value
                            ActionBars:RefreshDoodads()
                        end,
                        order = 20,
                    },
                    header = {
                        name = L["General_Position"],
                        type = "header",
                        order = 39,
                    },
                    controlPosition = {
                        name = L["Control_Position"],
                        desc = L["Control_PositionDesc"]:format("Bartender4"),
                        type = "toggle",
                        get = function() return RealUI:DoesAddonMove("Bartender4") end,
                        set = function(info, value)
                            RealUI:ToggleAddonPositionControl("Bartender4", value)
                            ActionBars:SetEnabledState(RealUI:GetModuleEnabled("ActionBars") and RealUI:DoesAddonMove("Bartender4"))
                            if value then
                                ActionBars:ApplyABSettings()
                            end
                        end,
                        order = 40,
                    },
                    position = {
                        name = "",
                        type = "group",
                        disabled = function() return not RealUI:DoesAddonMove("Bartender4") end,
                        inline = true,
                        args = {
                            move = {
                                name = "",
                                type = "group",
                                inline = true,
                                order = 10,
                                args = {
                                    moveStance = {
                                        name = L["ActionBars_Move"]:format(L["ActionBars_Stance"]),
                                        desc = L["ActionBars_MoveDesc"]:format(L["ActionBars_Stance"]),
                                        type = "toggle",
                                        get = function() return ActionBars.db.profile[RealUI.cLayout].moveBars.stance end,
                                        set = function(info, value)
                                            ActionBars.db.profile[RealUI.cLayout].moveBars.stance = value
                                            ActionBars:ApplyABSettings()
                                        end,
                                        order = 10,
                                    },
                                    movePet = {
                                        name = L["ActionBars_Move"]:format(L["ActionBars_Pet"]),
                                        desc = L["ActionBars_MoveDesc"]:format(L["ActionBars_Pet"]),
                                        type = "toggle",
                                        get = function() return ActionBars.db.profile[RealUI.cLayout].moveBars.pet end,
                                        set = function(info, value)
                                            ActionBars.db.profile[RealUI.cLayout].moveBars.pet = value
                                            ActionBars:ApplyABSettings()
                                        end,
                                        order = 20,
                                    },
                                    moveEAB = {
                                        name = L["ActionBars_Move"]:format(L["ActionBars_EAB"]),
                                        desc = L["ActionBars_MoveDesc"]:format(L["ActionBars_EAB"]),
                                        type = "toggle",
                                        get = function() return ActionBars.db.profile[RealUI.cLayout].moveBars.eab end,
                                        set = function(info, value)
                                            ActionBars.db.profile[RealUI.cLayout].moveBars.eab = value
                                            ActionBars:ApplyABSettings()
                                        end,
                                        order = 30,
                                    },
                                }
                            },
                            center = {
                                name = L["ActionBars_Center"],
                                desc = L["ActionBars_CenterDesc"],
                                type = "select",
                                values = function()
                                    return {
                                        L["ActionBars_CenterOption"]:format(0, 3),
                                        L["ActionBars_CenterOption"]:format(1, 2),
                                        L["ActionBars_CenterOption"]:format(2, 1),
                                        L["ActionBars_CenterOption"]:format(3, 0),
                                    }
                                end,
                                get = function(info)
                                    return ActionBars.db.profile[RealUI.cLayout].centerPositions
                                end,
                                set = function(info, value)
                                    ActionBars.db.profile[RealUI.cLayout].centerPositions = value
                                    ActionBars:ApplyABSettings()
                                    RealUI:UpdatePositioners()
                                end,
                                order = 20,
                            },
                            side = {
                                name = L["ActionBars_Sides"],
                                desc = L["ActionBars_SidesDesc"],
                                type = "select",
                                values = function()
                                    return {
                                        L["ActionBars_SidesOption"]:format(0, 2),
                                        L["ActionBars_SidesOption"]:format(1, 1),
                                        L["ActionBars_SidesOption"]:format(2, 0),
                                    }
                                end,
                                get = function(info)
                                    return ActionBars.db.profile[RealUI.cLayout].sidePositions
                                end,
                                set = function(info, value)
                                    ActionBars.db.profile[RealUI.cLayout].sidePositions = value
                                    ActionBars:ApplyABSettings()
                                    RealUI:UpdatePositioners()
                                end,
                                order = 30,
                            },
                            vertical = {
                                name = L["HuD_Vertical"],
                                desc = L["HuD_VerticalDesc"],
                                type = "range",
                                width = "full",
                                min = -round(uiHeight * 0.3), max = round(uiHeight * 0.3),
                                step = 1, bigStep = 4,
                                order = -1,
                                get = function(info) return RealUI.db.profile.positions[RealUI.cLayout]["ActionBarsY"] end,
                                set = function(info, value)
                                    RealUI.db.profile.positions[RealUI.cLayout]["ActionBarsY"] = value - .5
                                    ActionBars:ApplyABSettings()
                                    RealUI:UpdatePositioners()
                                end,
                            }
                        }
                    }
                }
            }
        }
    }
end
do -- UnitFrames
    debug("HuD UnitFrames")
    local MODNAME = "UnitFrames"
    local UnitFrames = RealUI:GetModule(MODNAME)
    optArgs.unitframes = {
        name = _G.UNITFRAME_LABEL,
        icon = "th",
        type = "group",
        childGroups = "tab",
        order = 2,
        args = {
            enable = {
                name = L["General_Enabled"],
                desc = L["General_EnabledDesc"]:format("RealUI ".._G.UNITFRAME_LABEL),
                type = "toggle",
                get = function(info) return RealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value)
                    RealUI:SetModuleEnabled("UnitFrames", value)
                    CloseHuDWindow()
                    RealUI:ReloadUIDialog()
                end,
            },
            general = {
                name = _G.GENERAL,
                type = "group",
                disabled = function() return not(RealUI:GetModuleEnabled(MODNAME)) end,
                order = 10,
                args = {
                    classColor = {
                        name = L["Appearance_ClassColorHealth"],
                        type = "toggle",
                        get = function() return UnitFrames.db.profile.overlay.classColor end,
                        set = function(info, value)
                            UnitFrames.db.profile.overlay.classColor = value
                            UnitFrames:RefreshUnits("ClassColorBars")
                        end,
                        order = 10,
                    },
                    classColorNames = {
                        name = L["Appearance_ClassColorNames"],
                        type = "toggle",
                        get = function() return UnitFrames.db.profile.overlay.classColorNames end,
                        set = function(info, value)
                            UnitFrames.db.profile.overlay.classColorNames = value
                        end,
                        order = 15,
                    },
                    reverseBars = {
                        name = L["HuD_ReverseBars"],
                        type = "toggle",
                        get = function() return RealUI.db.profile.settings.reverseUnitFrameBars end,
                        set = function(info, value)
                            RealUI.db.profile.settings.reverseUnitFrameBars = value
                            UnitFrames:RefreshUnits("ReverseBars")
                        end,
                        order = 20,
                    },
                    statusText = {
                        name = _G.STATUS_TEXT,
                        desc = _G.OPTION_TOOLTIP_STATUS_TEXT_DISPLAY,
                        type = "select",
                        values = function()
                            return {
                                both = _G.STATUS_TEXT_BOTH,
                                perc = _G.STATUS_TEXT_PERCENT,
                                value = _G.STATUS_TEXT_VALUE,
                            }
                        end,
                        get = function(info)
                            return UnitFrames.db.profile.misc.statusText
                        end,
                        set = function(info, value)
                            UnitFrames.db.profile.misc.statusText = value
                            UnitFrames:RefreshUnits("StatusText")
                        end,
                        order = 30,
                    },
                    focusClick = {
                        name = L["UnitFrames_SetFocus"],
                        desc = L["UnitFrames_SetFocusDesc"],
                        type = "toggle",
                        get = function() return UnitFrames.db.profile.misc.focusclick end,
                        set = function(info, value)
                            UnitFrames.db.profile.misc.focusclick = value
                        end,
                        order = 40,
                    },
                    focusKey = {
                        name = L["UnitFrames_ModifierKey"],
                        type = "select",
                        values = function()
                            return {
                                shift = _G.SHIFT_KEY_TEXT,
                                ctrl = _G.CTRL_KEY_TEXT,
                                alt = _G.ALT_KEY_TEXT,
                            }
                        end,
                        disabled = function() return not UnitFrames.db.profile.misc.focusclick end,
                        get = function(info)
                            return UnitFrames.db.profile.misc.focuskey
                        end,
                        set = function(info, value)
                            UnitFrames.db.profile.misc.focuskey = value
                        end,
                        order = 41,
                    },
                }
            },
            units = {
                name = L["UnitFrames_Units"],
                type = "group",
                childGroups = "tab",
                disabled = function() return not(RealUI:GetModuleEnabled(MODNAME)) end,
                order = 20,
                args = {
                    player = {
                        name = _G.PLAYER,
                        type = "group",
                        order = 10,
                        args = {}
                    },
                    pet = {
                        name = _G.PET,
                        type = "group",
                        order = 20,
                        args = {}
                    },
                    target = {
                        name = _G.TARGET,
                        type = "group",
                        order = 30,
                        args = {}
                    },
                    targettarget = {
                        name = _G.SHOW_TARGET_OF_TARGET_TEXT,
                        type = "group",
                        order = 40,
                        args = {}
                    },
                    focus = {
                        name = _G.FOCUS,
                        type = "group",
                        order = 50,
                        args = {}
                    },
                    focustarget = {
                        name = _G.BINDING_NAME_FOCUSTARGET,
                        type = "group",
                        order = 60,
                        args = {}
                    },
                }
            },
            groups = {
                name = _G.GROUPS,
                type = "group",
                childGroups = "tab",
                disabled = function() return not(RealUI:GetModuleEnabled(MODNAME)) end,
                order = 30,
                args = {
                    boss = {
                        name = _G.BOSS,
                        type = "group",
                        order = 10,
                        args = {
                            showPlayerAuras = {
                                name = L["UnitFrames_PlayerAuras"],
                                desc = L["UnitFrames_PlayerAurasDesc"],
                                type = "toggle",
                                get = function() return UnitFrames.db.profile.boss.showPlayerAuras end,
                                set = function(info, value)
                                    UnitFrames.db.profile.boss.showPlayerAuras = value
                                end,
                                order = 10,
                            },
                            showNPCAuras = {
                                name = L["UnitFrames_NPCAuras"],
                                desc = L["UnitFrames_NPCAurasDesc"],
                                type = "toggle",
                                get = function() return UnitFrames.db.profile.boss.showNPCAuras end,
                                set = function(info, value)
                                    UnitFrames.db.profile.boss.showNPCAuras = value
                                end,
                                order = 20,
                            },
                            buffCount = {
                                name = L["UnitFrames_BuffCount"],
                                type = "range",
                                min = 1, max = 8, step = 1,
                                get = function(info) return UnitFrames.db.profile.boss.buffCount end,
                                set = function(info, value) UnitFrames.db.profile.boss.buffCount = value end,
                                order = 30,
                            },
                            debuffCount = {
                                name = L["UnitFrames_DebuffCount"],
                                type = "range",
                                min = 1, max = 8, step = 1,
                                get = function(info) return UnitFrames.db.profile.boss.debuffCount end,
                                set = function(info, value) UnitFrames.db.profile.boss.debuffCount = value end,
                                order = 40,
                            },

                        }
                    },
                    arena = {
                        name = _G.ARENA,
                        type = "group",
                        order = 20,
                        args = {
                            enabled = {
                                name = L["General_Enabled"],
                                desc = L["General_EnabledDesc"]:format("RealUI ".._G.SHOW_ARENA_ENEMY_FRAMES_TEXT),
                                type = "toggle",
                                get = function() return UnitFrames.db.profile.arena.enabled end,
                                set = function(info, value)
                                    UnitFrames.db.profile.arena.enabled = value
                                end,
                                order = 10,
                            },
                            options = {
                                name = "",
                                type = "group",
                                inline = true,
                                disabled = function() return not UnitFrames.db.profile.arena.enabled end,
                                order = 20,
                                args = {
                                    announceUse = {
                                        name = L["UnitFrames_AnnounceTrink"],
                                        desc = L["UnitFrames_AnnounceTrinkDesc"],
                                        type = "toggle",
                                        get = function() return UnitFrames.db.profile.arena.announceUse end,
                                        set = function(info, value)
                                            UnitFrames.db.profile.arena.announceUse = value
                                        end,
                                        order = 10,
                                    },
                                    announceChat = {
                                        name = _G.CHAT,
                                        desc = L["UnitFrames_AnnounceChatDesc"],
                                        type = "select",
                                        values = function()
                                            return {
                                                group = _G.INSTANCE_CHAT,
                                                say = _G.CHAT_MSG_SAY,
                                            }
                                        end,
                                        disabled = function() return not UnitFrames.db.profile.arena.announceUse end,
                                        get = function(info)
                                            return _G.strlower(UnitFrames.db.profile.arena.announceChat)
                                        end,
                                        set = function(info, value)
                                            UnitFrames.db.profile.arena.announceChat = value
                                        end,
                                        order = 20,
                                    },
                                    --[[showPets = {
                                        name = SHOW_ARENA_ENEMY_PETS_TEXT,
                                        desc = OPTION_TOOLTIP_SHOW_ARENA_ENEMY_PETS,
                                        type = "toggle",
                                        get = function() return db.arena.showPets end,
                                        set = function(info, value)
                                            db.arena.showPets = value
                                        end,
                                        order = 30,
                                    },
                                    showCast = {
                                        name = SHOW_ARENA_ENEMY_CASTBAR_TEXT,
                                        desc = OPTION_TOOLTIP_SHOW_ARENA_ENEMY_CASTBAR,
                                        type = "toggle",
                                        get = function() return db.arena.showCast end,
                                        set = function(info, value)
                                            db.arena.showCast = value
                                        end,
                                        order = 40,
                                    },]]
                                },
                            },
                        }
                    },
                    raid = {
                        name = _G.RAID,
                        type = "group",
                        childGroups = "tab",
                        order = 30,
                        args = {
                            advanced = {
                                name = "Grid 2",
                                type = "execute",
                                disabled = not _G.Grid2,
                                func = function(info, ...)
                                    _G.Grid2:OnChatCommand("")
                                end,
                                order = 0,
                            },
                        }
                    },
                }
            },
        },
    }

    local ufArgs = optArgs.unitframes.args
    CombatFader:AddFadeConfig("UnitFrames", ufArgs.general, 50, true)
    do -- import hideRaidFilters from minimap
        local MinimapAdv = RealUI:GetModule("MinimapAdv")
        ufArgs.groups.args.raid.args.hideRaidFilters = {
            type = "toggle",
            name = L["Raid_HideRaidFilter"],
            desc = L["Raid_HideRaidFilterDesc"],
            get = function(info) return MinimapAdv.db.profile.information.hideRaidFilters end,
            set = function(info, value)
                MinimapAdv.db.profile.information.hideRaidFilters = value
            end,
            order = 50,
        }
    end
    local units = ufArgs.units.args
    for unitSlug, unit in next, units do
        unit.args.x = {
            name = L["General_XOffset"],
            type = "input",
            order = 10,
            get = function(info) return tostring(UnitFrames.db.profile.positions[RealUI.db.profile.settings.hudSize][unitSlug].x) end,
            set = function(info, value)
                value = ValidateOffset(value)
                UnitFrames.db.profile.positions[RealUI.db.profile.settings.hudSize][unitSlug].x = value
            end,
        }
        unit.args.y = {
            name = L["General_YOffset"],
            type = "input",
            order = 20,
            get = function(info) return tostring(UnitFrames.db.profile.positions[RealUI.db.profile.settings.hudSize][unitSlug].y) end,
            set = function(info, value)
                value = ValidateOffset(value)
                UnitFrames.db.profile.positions[RealUI.db.profile.settings.hudSize][unitSlug].y = value
            end,
        }
        if unitSlug == "player" or unitSlug == "target" then
            unit.args.anchorWidth = {
                name = L["UnitFrames_AnchorWidth"],
                desc = L["UnitFrames_AnchorWidthDesc"],
                type = "range",
                width = "full",
                min = round(uiWidth * 0.1),
                max = round(uiWidth * 0.5),
                step = 1,
                bigStep = 4,
                order = 30,
                get = function(info) return RealUI.db.profile.positions[RealUI.cLayout]["UFHorizontal"] end,
                set = function(info, value)
                    RealUI.db.profile.positions[RealUI.cLayout]["UFHorizontal"] = value
                    RealUI:UpdatePositioners()
                end,
            }
        end
        --[[ future times
        local unitInfo = db.units[unitSlug]
        unit.args = {
            width = {
                name = L["HuD_Width"],
                type = "input",
                --width = "half",
                order = 10,
                get = function(info) return tostring(unitInfo.height.x) end,
                set = function(info, value)
                    unitInfo.height.x = value
                end,
                pattern = "^(%d+)$",
                usage = "You can only use whole numbers."
            },
            height = {
                name = L["HuD_Height"],
                type = "input",
                --width = "half",
                order = 20,
                get = function(info) return tostring(unitInfo.height.y) end,
                set = function(info, value)
                    unitInfo.height.y = value
                end,
                pattern = "^(%d+)$",
                usage = "You can only use whole numbers."
            },
            healthHeight = {
                name = "Health bar height",
                desc = "The height of the health bar as a percentage of the total unit height",
                type = "range",
                width = "double",
                min = 0,
                max = 1,
                step = .01,
                isPercent = true,
                order = 50,
                get = function(info) return unitInfo.healthHeight end,
                set = function(info, value)
                    unitInfo.healthHeight = value
                end,
            },
            x = {
                name = L["General_XOffset"],
                type = "range",
                min = -100,
                max = 50,
                step = 1,
                order = 30,
                get = function(info) return unitInfo.position.x end,
                set = function(info, value)
                    unitInfo.position.x = value
                end,
            },
            y = {
                name = "L["General_YOffset"],
                type = "range",
                min = -100,
                max = 100,
                step = 1,
                order = 40,
                get = function(info) return unitInfo.position.y end,
                set = function(info, value)
                    unitInfo.position.y = value
                end,
            },
        --]]
    end
    local groups = ufArgs.groups.args
    for groupSlug, group in next, groups do
        if groupSlug == "boss" or groupSlug == "arena" then
            local args = groupSlug == "boss" and group.args or group.args.options.args
            args.horizontal = {
                name = L["HuD_Horizontal"],
                type = "range",
                width = "full",
                min = -round(uiWidth * 0.85),
                max = -30,
                step = 1,
                bigStep = 4,
                get = function(info) return RealUI.db.profile.positions[RealUI.cLayout]["BossX"] end,
                set = function(info, value)
                    RealUI.db.profile.positions[RealUI.cLayout]["BossX"] = value
                    RealUI:UpdatePositioners()
                end,
                order = 2,
            }
            args.vertical = {
                name = L["HuD_Vertical"],
                type = "range",
                width = "full",
                min = -round(uiHeight * 0.4),
                max = round(uiHeight * 0.4),
                step = 1,
                bigStep = 2,
                get = function(info) return RealUI.db.profile.positions[RealUI.cLayout]["BossY"] end,
                set = function(info, value)
                    RealUI.db.profile.positions[RealUI.cLayout]["BossY"] = value
                    RealUI:UpdatePositioners()
                end,
                order = 4,
            }
            args.gap = {
                name = L["UnitFrames_Gap"],
                desc = L["UnitFrames_GapDesc"],
                type = "range",
                min = 0, max = 10, step = 1,
                get = function(info) return UnitFrames.db.profile.boss.gap end,
                set = function(info, value) UnitFrames.db.profile.boss.gap = value end,
                order = 6,
            }
        end
    end
end
do -- CastBars
    debug("HuD CastBars")
    local MODNAME = "CastBars"
    local CastBars = RealUI:GetModule(MODNAME)

    local function CreateFrameOptions(unit, order)
        return {
            name = _G[unit:upper()],
            type = "group",
            order = order,
            args = {
                reverse = {
                    name = L["HuD_ReverseBars"],
                    type = "toggle",
                    get = function() return CastBars.db.profile[unit].reverse end,
                    set = function(info, value)
                        CastBars.db.profile[unit].reverse = value
                        CastBars:UpdateSettings(unit)
                    end,
                    order = 1,
                },
                text = {
                    name = _G.LOCALE_TEXT_LABEL,
                    type = "select",
                    hidden = unit == "focus",
                    values = RealUI.globals.cornerPoints,
                    get = function(info)
                        for k,v in next, RealUI.globals.cornerPoints do
                            if v == CastBars.db.profile[unit].text then return k end
                        end
                    end,
                    set = function(info, value)
                        CastBars.db.profile[unit].text = RealUI.globals.cornerPoints[value]
                        CastBars:UpdateSettings(unit)
                    end,
                    order = 2,
                },
                position = {
                    name = L["General_Position"],
                    type = "group",
                    inline = true,
                    order = 3,
                    args = {
                        point = {
                            name = L["General_AnchorPoint"],
                            type = "select",
                            values = RealUI.globals.anchorPoints,
                            get = function(info)
                                for k,v in next, RealUI.globals.anchorPoints do
                                    if v == CastBars.db.profile[unit].position.point then return k end
                                end
                            end,
                            set = function(info, value)
                                CastBars.db.profile[unit].position.point = RealUI.globals.anchorPoints[value]
                                FramePoint:RestorePosition(CastBars)
                            end,
                            order = 10,
                        },
                        x = {
                            name = L["General_XOffset"],
                            desc = L["General_XOffsetDesc"],
                            type = "input",
                            dialogControl = "NumberEditBox",
                            get = function(info)
                                return _G.tostring(CastBars.db.profile[unit].position.x)
                            end,
                            set = function(info, value)
                                CastBars.db.profile[unit].position.x = round(_G.tonumber(value), 1)
                                FramePoint:RestorePosition(CastBars)
                            end,
                            order = 11,
                        },
                        y = {
                            name = L["General_YOffset"],
                            desc = L["General_YOffsetDesc"],
                            type = "input",
                            dialogControl = "NumberEditBox",
                            get = function(info) return _G.tostring(CastBars.db.profile[unit].position.y) end,
                            set = function(info, value)
                                CastBars.db.profile[unit].position.y = round(_G.tonumber(value), 1)
                                FramePoint:RestorePosition(CastBars)
                            end,
                            order = 12,
                        },
                    }
                }
            }
        }
    end

    optArgs.castbars = {
        name = L[MODNAME],
        icon = "bolt",
        type = "group",
        childGroups = "tab",
        order = 3,
        args = {
            enable = {
                name = L["General_Enabled"],
                desc = L["General_EnabledDesc"]:format(L[MODNAME]),
                type = "toggle",
                get = function(info) return RealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value)
                    RealUI:SetModuleEnabled("CastBars", value)
                    CloseHuDWindow()
                    RealUI:ReloadUIDialog()
                end,
                order = 1,
            },
            lock = {
                name = L["General_Lock"],
                desc = L["General_LockDesc"],
                type = "toggle",
                get = function(info) return FramePoint:IsModLocked(CastBars) end,
                set = function(info, value)
                    if value then
                        FramePoint:LockMod(CastBars)
                    else
                        FramePoint:UnlockMod(CastBars)
                    end
                end,
                order = 2,
            },
            player = CreateFrameOptions("player", 10),
            target = CreateFrameOptions("target", 20),
            focus = CreateFrameOptions("focus", 30),
        }
    }
end
do -- ClassResource
    debug("HuD ClassResource")
    local MODNAME = "ClassResource"
    local ClassResource = RealUI:GetModule(MODNAME)

    local points, bars = ClassResource:GetResources()
    debug("points and bars", points, bars)
    if points or bars then
        local barOptions, pointOptions
        if RealUI:GetModuleEnabled("ClassResource") then
            barOptions = {
                name = bars or "",
                type = "group",
                hidden = bars == nil,
                order = 20,
                args = {
                    width = {
                        name = L["HuD_Width"],
                        type = "input",
                        get = function(info) return tostring(ClassResource.db.class.bar.size.width) end,
                        set = function(info, value)
                            ClassResource.db.class.bar.size.width = value
                            ClassResource:SettingsUpdate("bar", "size")
                        end,
                        order = 1,
                    },
                    height = {
                        name = L["HuD_Height"],
                        type = "input",
                        get = function(info) return tostring(ClassResource.db.class.bar.size.height) end,
                        set = function(info, value)
                            ClassResource.db.class.bar.size.height = value
                            ClassResource:SettingsUpdate("bar", "size")
                        end,
                        order = 2,
                    },
                    position = {
                        name = L["General_Position"],
                        type = "group",
                        inline = true,
                        order = 3,
                        args = {
                            point = {
                                name = L["General_AnchorPoint"],
                                type = "select",
                                values = RealUI.globals.anchorPoints,
                                get = function(info)
                                    for k,v in next, RealUI.globals.anchorPoints do
                                        if v == ClassResource.db.class.bar.position.point then return k end
                                    end
                                end,
                                set = function(info, value)
                                    ClassResource.db.class.bar.position.point = RealUI.globals.anchorPoints[value]
                                    FramePoint:RestorePosition(ClassResource)
                                end,
                                order = 1,
                            },
                            x = {
                                name = L["General_XOffset"],
                                desc = L["General_XOffsetDesc"],
                                type = "input",
                                dialogControl = "NumberEditBox",
                                get = function(info)
                                    return _G.tostring(ClassResource.db.class.bar.position.x)
                                end,
                                set = function(info, value)
                                    ClassResource.db.class.bar.position.x = round(_G.tonumber(value), 1)
                                    FramePoint:RestorePosition(ClassResource)
                                end,
                                order = 2,
                            },
                            y = {
                                name = L["General_YOffset"],
                                desc = L["General_YOffsetDesc"],
                                type = "input",
                                dialogControl = "NumberEditBox",
                                get = function(info) return _G.tostring(ClassResource.db.class.bar.position.y) end,
                                set = function(info, value)
                                    ClassResource.db.class.bar.position.y = round(_G.tonumber(value), 1)
                                    FramePoint:RestorePosition(ClassResource)
                                end,
                                order = 3,
                            },
                        }
                    }
                }
            }

            pointOptions = {
                name = points.name,
                type = "group",
                order = 20,
                args = {
                    hideempty = {
                        name = L["Resource_HideUnused"]:format(points.name),
                        desc = L["Resource_HideUnusedDesc"]:format(points.name),
                        type = "toggle",
                        hidden = RealUI.charInfo.class.token == "DEATHKNIGHT",
                        get = function(info) return ClassResource.db.class.points.hideempty end,
                        set = function(info, value)
                            ClassResource.db.class.points.hideempty = value
                            ClassResource:ForceUpdate()
                        end,
                        order = 1,
                    },
                    reverse = {
                        name = L["Resource_Reverse"],
                        desc = L["Resource_ReverseDesc"]:format(points.name),
                        type = "toggle",
                        hidden = points.token ~= "COMBO_POINTS",
                        get = function(info) return ClassResource.db.class.points.reverse end,
                        set = function(info, value)
                            ClassResource.db.class.points.reverse = value
                            ClassResource:SettingsUpdate("points", "gap")
                        end,
                        order = 2,
                    },
                    width = {
                        name = L["HuD_Width"],
                        type = "input",
                        hidden = RealUI.charInfo.class.token ~= "DEATHKNIGHT",
                        get = function(info) return tostring(ClassResource.db.class.points.size.width) end,
                        set = function(info, value)
                            ClassResource.db.class.points.size.width = value
                            ClassResource:SettingsUpdate("points", "size")
                        end,
                        order = 10,
                    },
                    height = {
                        name = L["HuD_Height"],
                        type = "input",
                        hidden = RealUI.charInfo.class.token ~= "DEATHKNIGHT",
                        get = function(info) return tostring(ClassResource.db.class.points.size.height) end,
                        set = function(info, value)
                            ClassResource.db.class.points.size.height = value
                            ClassResource:SettingsUpdate("points", "size")
                        end,
                        order = 11,
                    },
                    gap = {
                        name = L["Resource_Gap"],
                        desc = L["Resource_GapDesc"]:format(points.name),
                        type = "input",
                        hidden = RealUI.charInfo.class.token == "PALADIN",
                        get = function(info) return tostring(ClassResource.db.class.points.size.gap) end,
                        set = function(info, value)
                            value = ValidateOffset(value)
                            ClassResource.db.class.points.size.gap = value
                            ClassResource:SettingsUpdate("points", "gap")
                        end,
                        order = 12,
                    },
                    position = {
                        name = L["General_Position"],
                        type = "group",
                        inline = true,
                        order = 20,
                        args = {
                            point = {
                                name = L["General_AnchorPoint"],
                                type = "select",
                                values = RealUI.globals.anchorPoints,
                                get = function(info)
                                    for k,v in next, RealUI.globals.anchorPoints do
                                        if v == ClassResource.db.class.points.position.point then return k end
                                    end
                                end,
                                set = function(info, value)
                                    ClassResource.db.class.points.position.point = RealUI.globals.anchorPoints[value]
                                    FramePoint:RestorePosition(ClassResource)
                                end,
                                order = 1,
                            },
                            x = {
                                name = L["General_XOffset"],
                                desc = L["General_XOffsetDesc"],
                                type = "input",
                                dialogControl = "NumberEditBox",
                                get = function(info)
                                    return _G.tostring(ClassResource.db.class.points.position.x)
                                end,
                                set = function(info, value)
                                    ClassResource.db.class.points.position.x = round(_G.tonumber(value), 1)
                                    FramePoint:RestorePosition(ClassResource)
                                end,
                                order = 2,
                            },
                            y = {
                                name = L["General_YOffset"],
                                desc = L["General_YOffsetDesc"],
                                type = "input",
                                dialogControl = "NumberEditBox",
                                get = function(info) return _G.tostring(ClassResource.db.class.points.position.y) end,
                                set = function(info, value)
                                    ClassResource.db.class.points.position.y = round(_G.tonumber(value), 1)
                                    FramePoint:RestorePosition(ClassResource)
                                end,
                                order = 3,
                            },
                        }
                    }
                }
            }
            CombatFader:AddFadeConfig("ClassResource", pointOptions, 50, true)
        end

        optArgs.classresource = {
            name = L["Resource"],
            icon = "cogs",
            type = "group",
            childGroups = "tab",
            order = 4,
            args = {
                enable = {
                    name = L["General_Enabled"],
                    desc = L["General_EnabledDesc"]:format(L["Resource"]),
                    type = "toggle",
                    get = function(info)
                        return RealUI:GetModuleEnabled("ClassResource")
                    end,
                    set = function(info, value)
                        RealUI:SetModuleEnabled("ClassResource", value)
                        CloseHuDWindow()
                        RealUI:ReloadUIDialog()
                    end,
                    order = 1,
                },
                lock = {
                    name = L["General_Lock"],
                    desc = L["General_LockDesc"],
                    type = "toggle",
                    get = function(info) return FramePoint:IsModLocked(ClassResource) end,
                    set = function(info, value)
                        if value then
                            FramePoint:LockMod(ClassResource)
                        else
                            FramePoint:UnlockMod(ClassResource)
                        end
                    end,
                    order = 2,
                },
                bars = barOptions,
                points = pointOptions,
            }
        }
    end
end

debug("HuD Options")
