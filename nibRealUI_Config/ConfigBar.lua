local _, private = ...
local options = private.options
local CloseHuDWindow = private.CloseHuDWindow
local debug = private.debug

-- Lua Globals --
local next = _G.next
local tostring = _G.tostring

-- Libs --
local ACD = _G.LibStub("AceConfigDialog-3.0")

-- RealUI --
local RealUI = _G.RealUI
local L = RealUI.L
local ndb = RealUI.db.profile
local ndbc = RealUI.db.char
local hudSize = ndb.settings.hudSize
local round = RealUI.Round

local CombatFader = RealUI:GetModule("CombatFader")
local uiWidth, uiHeight = RealUI.GetInterfaceSize()

local other do
    debug("HuD Other")
    local ActionBars = RealUI:GetModule("ActionBars")
    local dbActionBars = ActionBars.db.profile
    other = {
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
                            return ndbc.layout.current
                        end,
                        set = function(info, value)
                            ndbc.layout.current = value
                            ndbc.layout.spec[_G.GetSpecialization()] = value
                            RealUI:UpdateLayout()
                        end,
                        order = 10,
                    },
                    linkLayout = {
                        name = L["Layout_Link"],
                        desc = L["Layout_LinkDesc"],
                        type = "toggle",
                        get = function() return ndb.positionsLink end,
                        set = function(info, value)
                            ndb.positionsLink = value

                            RealUI.cLayout = ndbc.layout.current
                            RealUI.ncLayout = RealUI.cLayout == 1 and 2 or 1

                            if value then
                                ndb.positions[RealUI.ncLayout] = RealUI:DeepCopy(ndb.positions[RealUI.cLayout])
                            end
                        end,
                        order = 20,
                    },
                    useLarge = {
                        name = L["HuD_UseLarge"],
                        desc = L["HuD_UseLargeDesc"],
                        type = "toggle",
                        get = function() return ndb.settings.hudSize == 2 end,
                        set = function(info, value)
                            ndb.settings.hudSize = value and 2 or 1
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
                        get = function(info) return ndb.positions[RealUI.cLayout]["HuDY"] end,
                        set = function(info, value)
                            ndb.positions[RealUI.cLayout]["HuDY"] = value
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
                        get = function(info) return ndb.positions[RealUI.cLayout]["SpellAlertWidth"] end,
                        set = function(info, value)
                            ndb.positions[RealUI.cLayout]["SpellAlertWidth"] = value
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
                        get = function() return dbActionBars.showDoodads end,
                        set = function(info, value)
                            dbActionBars.showDoodads = value
                            ActionBars:RefreshDoodads()
                        end,
                        order = 20,
                    },
                    controlLayout = {
                        name = L["Control_Layout"],
                        desc = L["Control_LayoutDesc"]:format("Bartender4"),
                        type = "toggle",
                        get = function() return RealUI:DoesAddonLayout("Bartender4") end,
                        set = function(info, value)
                            RealUI:ToggleAddonLayoutControl("Bartender4", value)
                            ActionBars:SetEnabledState(RealUI:GetModuleEnabled("ActionBars") and RealUI:DoesAddonLayout("Bartender4"))
                        end,
                        order = 30,
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
                                        get = function() return dbActionBars[RealUI.cLayout].moveBars.stance end,
                                        set = function(info, value)
                                            dbActionBars[RealUI.cLayout].moveBars.stance = value
                                            ActionBars:ApplyABSettings()
                                        end,
                                        order = 10,
                                    },
                                    movePet = {
                                        name = L["ActionBars_Move"]:format(L["ActionBars_Pet"]),
                                        desc = L["ActionBars_MoveDesc"]:format(L["ActionBars_Pet"]),
                                        type = "toggle",
                                        get = function() return dbActionBars[RealUI.cLayout].moveBars.pet end,
                                        set = function(info, value)
                                            dbActionBars[RealUI.cLayout].moveBars.pet = value
                                            ActionBars:ApplyABSettings()
                                        end,
                                        order = 20,
                                    },
                                    moveEAB = {
                                        name = L["ActionBars_Move"]:format(L["ActionBars_EAB"]),
                                        desc = L["ActionBars_MoveDesc"]:format(L["ActionBars_EAB"]),
                                        type = "toggle",
                                        get = function() return dbActionBars[RealUI.cLayout].moveBars.eab end,
                                        set = function(info, value)
                                            dbActionBars[RealUI.cLayout].moveBars.eab = value
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
                                    return dbActionBars[RealUI.cLayout].centerPositions
                                end,
                                set = function(info, value)
                                    dbActionBars[RealUI.cLayout].centerPositions = value
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
                                    return dbActionBars[RealUI.cLayout].sidePositions
                                end,
                                set = function(info, value)
                                    dbActionBars[RealUI.cLayout].sidePositions = value
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
                                get = function(info) return ndb.positions[RealUI.cLayout]["ActionBarsY"] end,
                                set = function(info, value)
                                    ndb.positions[RealUI.cLayout]["ActionBarsY"] = value - .5
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
local unitframes do
    debug("HuD UnitFrames")
    local MODNAME = "UnitFrames"
    local UnitFrames = RealUI:GetModule(MODNAME)
    local db = UnitFrames.db.profile
    unitframes = {
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
                        get = function() return db.overlay.classColor end,
                        set = function(info, value)
                            db.overlay.classColor = value
                            UnitFrames:RefreshUnits("ClassColorBars")
                        end,
                        order = 10,
                    },
                    classColorNames = {
                        name = L["Appearance_ClassColorNames"],
                        type = "toggle",
                        get = function() return db.overlay.classColorNames end,
                        set = function(info, value)
                            db.overlay.classColorNames = value
                        end,
                        order = 15,
                    },
                    reverseBars = {
                        name = L["HuD_ReverseBars"],
                        type = "toggle",
                        get = function() return ndb.settings.reverseUnitFrameBars end,
                        set = function(info, value)
                            ndb.settings.reverseUnitFrameBars = value
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
                            return db.misc.statusText
                        end,
                        set = function(info, value)
                            db.misc.statusText = value
                            UnitFrames:RefreshUnits("StatusText")
                        end,
                        order = 30,
                    },
                    focusClick = {
                        name = L["UnitFrames_SetFocus"],
                        desc = L["UnitFrames_SetFocusDesc"],
                        type = "toggle",
                        get = function() return db.misc.focusclick end,
                        set = function(info, value)
                            db.misc.focusclick = value
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
                        disabled = function() return not db.misc.focusclick end,
                        get = function(info)
                            return db.misc.focuskey
                        end,
                        set = function(info, value)
                            db.misc.focuskey = value
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
                                get = function() return db.boss.showPlayerAuras end,
                                set = function(info, value)
                                    db.boss.showPlayerAuras = value
                                end,
                                order = 10,
                            },
                            showNPCAuras = {
                                name = L["UnitFrames_NPCAuras"],
                                desc = L["UnitFrames_NPCAurasDesc"],
                                type = "toggle",
                                get = function() return db.boss.showNPCAuras end,
                                set = function(info, value)
                                    db.boss.showNPCAuras = value
                                end,
                                order = 20,
                            },
                            buffCount = {
                                name = L["UnitFrames_BuffCount"],
                                type = "range",
                                min = 1, max = 8, step = 1,
                                get = function(info) return db.boss.buffCount end,
                                set = function(info, value) db.boss.buffCount = value end,
                                order = 30,
                            },
                            debuffCount = {
                                name = L["UnitFrames_DebuffCount"],
                                type = "range",
                                min = 1, max = 8, step = 1,
                                get = function(info) return db.boss.debuffCount end,
                                set = function(info, value) db.boss.debuffCount = value end,
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
                                get = function() return db.arena.enabled end,
                                set = function(info, value)
                                    db.arena.enabled = value
                                end,
                                order = 10,
                            },
                            options = {
                                name = "",
                                type = "group",
                                inline = true,
                                disabled = function() return not db.arena.enabled end,
                                order = 20,
                                args = {
                                    announceUse = {
                                        name = L["UnitFrames_AnnounceTrink"],
                                        desc = L["UnitFrames_AnnounceTrinkDesc"],
                                        type = "toggle",
                                        get = function() return db.arena.announceUse end,
                                        set = function(info, value)
                                            db.arena.announceUse = value
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
                                        disabled = function() return not db.arena.announceUse end,
                                        get = function(info)
                                            return _G.strlower(db.arena.announceChat)
                                        end,
                                        set = function(info, value)
                                            db.arena.announceChat = value
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
    CombatFader:AddFadeConfig("UnitFrames", unitframes.args.general, 50)
    do -- import hideRaidFilters from minimap
        local MinimapAdv = RealUI:GetModule("MinimapAdv")
        local mmDB = MinimapAdv.db.profile
        unitframes.args.groups.args.raid.args.hideRaidFilters = {
            type = "toggle",
            name = L["Raid_HideRaidFilter"],
            desc = L["Raid_HideRaidFilterDesc"],
            get = function(info) return mmDB.information.hideRaidFilters end,
            set = function(info, value)
                mmDB.information.hideRaidFilters = value
            end,
            order = 50,
        }
    end
    local units = unitframes.args.units.args
    for unitSlug, unit in next, units do
        local position = db.positions[hudSize][unitSlug]
        unit.args.x = {
            name = L["General_XOffset"],
            type = "input",
            order = 10,
            get = function(info) return tostring(position.x) end,
            set = function(info, value)
                value = RealUI:ValidateOffset(value)
                position.x = value
            end,
        }
        unit.args.y = {
            name = L["General_YOffset"],
            type = "input",
            order = 20,
            get = function(info) return tostring(position.y) end,
            set = function(info, value)
                value = RealUI:ValidateOffset(value)
                position.y = value
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
                get = function(info) return ndb.positions[RealUI.cLayout]["UFHorizontal"] end,
                set = function(info, value)
                    ndb.positions[RealUI.cLayout]["UFHorizontal"] = value
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
    local groups = unitframes.args.groups.args
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
                get = function(info) return ndb.positions[RealUI.cLayout]["BossX"] end,
                set = function(info, value)
                    ndb.positions[RealUI.cLayout]["BossX"] = value
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
                get = function(info) return ndb.positions[RealUI.cLayout]["BossY"] end,
                set = function(info, value)
                    ndb.positions[RealUI.cLayout]["BossY"] = value
                    RealUI:UpdatePositioners()
                end,
                order = 4,
            }
            args.gap = {
                name = L["UnitFrames_Gap"],
                desc = L["UnitFrames_GapDesc"],
                type = "range",
                min = 0, max = 10, step = 1,
                get = function(info) return db.boss.gap end,
                set = function(info, value) db.boss.gap = value end,
                order = 6,
            }
        end
    end
end
local castbars do
    debug("HuD CastBars")
    local MODNAME = "CastBars"
    local CastBars = RealUI:GetModule(MODNAME)
    local db = CastBars.db.profile
    castbars = {
        name = L[MODNAME],
        icon = "bolt",
        type = "group",
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
                order = 10,
            },
            reverse = {
                name = L["HuD_ReverseBars"],
                type = "group",
                inline = true,
                disabled = function() return not(RealUI:GetModuleEnabled(MODNAME)) end,
                order = 20,
                args = {
                    player = {
                        name = _G.PLAYER,
                        type = "toggle",
                        get = function() return db.reverse.player end,
                        set = function(info, value)
                            db.reverse.player = value
                            CastBars["player"]:SetReverseFill(value)
                        end,
                        order = 10,
                    },
                    target = {
                        name = _G.TARGET,
                        type = "toggle",
                        get = function() return db.reverse.target end,
                        set = function(info, value)
                            db.reverse.target = value
                            CastBars["target"]:SetReverseFill(value)
                        end,
                        order = 10,
                    },
                },
            },
            text = {
                name = _G.LOCALE_TEXT_LABEL,
                type = "group",
                inline = true,
                disabled = function() return not(RealUI:GetModuleEnabled(MODNAME)) end,
                order = 50,
                args = {
                    horizontal = {
                        name = L["CastBars_Inside"],
                        desc = L["CastBars_InsideDesc"],
                        type = "toggle",
                        get = function() return db.text.textInside end,
                        set = function(info, value)
                            db.text.textInside = value
                            CastBars:UpdateAnchors()
                        end,
                        order = 10,
                    },
                    vertical = {
                        name = L["CastBars_Bottom"],
                        desc = L["CastBars_BottomDesc"],
                        type = "toggle",
                        get = function() return db.text.textOnBottom end,
                        set = function(info, value)
                            db.text.textOnBottom = value
                            CastBars:UpdateAnchors()
                        end,
                        order = 20,
                    },
                },
            },
            header = {
                name = L["General_Position"],
                type = "header",
                order = 59,
            },
            position = {
                name = "",
                type = "group",
                inline = true,
                disabled = function() return not(RealUI:GetModuleEnabled(MODNAME)) end,
                order = 60,
                args = {
                    player = {
                        name = _G.PLAYER,
                        type = "group",
                        args = {
                            horizontal = {
                                name = L["HuD_Horizontal"],
                                type = "range",
                                width = "full",
                                min = -round(uiWidth * 0.2),
                                max = round(uiWidth * 0.2),
                                step = 1,
                                bigStep = 4,
                                get = function(info) return ndb.positions[RealUI.cLayout]["CastBarPlayerX"] end,
                                set = function(info, value)
                                    ndb.positions[RealUI.cLayout]["CastBarPlayerX"] = value
                                    RealUI:UpdatePositioners()
                                end,
                                order = 10,
                            },
                            vertical = {
                                name = L["HuD_Vertical"],
                                type = "range",
                                width = "full",
                                min = -round(uiHeight * 0.2),
                                max = round(uiHeight * 0.2),
                                step = 1,
                                bigStep = 2,
                                get = function(info) return ndb.positions[RealUI.cLayout]["CastBarPlayerY"] end,
                                set = function(info, value)
                                    ndb.positions[RealUI.cLayout]["CastBarPlayerY"] = value
                                    RealUI:UpdatePositioners()
                                end,
                                order = 20,
                            }
                        }
                    },
                    target = {
                        name = _G.TARGET,
                        type = "group",
                        args = {
                            horizontal = {
                                name = L["HuD_Horizontal"],
                                type = "range",
                                width = "full",
                                min = -round(uiWidth * 0.2),
                                max = round(uiWidth * 0.2),
                                step = 1,
                                bigStep = 4,
                                get = function(info) return ndb.positions[RealUI.cLayout]["CastBarTargetX"] end,
                                set = function(info, value)
                                    ndb.positions[RealUI.cLayout]["CastBarTargetX"] = value
                                    RealUI:UpdatePositioners()
                                end,
                                order = 10,
                            },
                            vertical = {
                                name = L["HuD_Vertical"],
                                type = "range",
                                width = "full",
                                min = -round(uiHeight * 0.2),
                                max = round(uiHeight * 0.2),
                                step = 1,
                                bigStep = 2,
                                get = function(info) return ndb.positions[RealUI.cLayout]["CastBarTargetY"] end,
                                set = function(info, value)
                                    ndb.positions[RealUI.cLayout]["CastBarTargetY"] = value
                                    RealUI:UpdatePositioners()
                                end,
                                order = 20,
                            }
                        }
                    }
                }
            }
        }
    }
end
local classresource do
    debug("HuD ClassResource")
    local ClassResource = RealUI:GetModule("ClassResource")
    local db = ClassResource.db.class
    local pointDB, barDB = db.points, db.bar
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
                        get = function(info) return tostring(barDB.size.width) end,
                        set = function(info, value)
                            barDB.size.width = value
                            ClassResource:SettingsUpdate("bar", "size")
                        end,
                        order = 10,
                    },
                    height = {
                        name = L["HuD_Height"],
                        type = "input",
                        get = function(info) return tostring(barDB.size.height) end,
                        set = function(info, value)
                            barDB.size.height = value
                            ClassResource:SettingsUpdate("bar", "size")
                        end,
                        order = 20,
                    },
                },
            }
            ClassResource:AddPositionConfig(barOptions, barDB.position, 50)

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
                        get = function(info) return pointDB.hideempty end,
                        set = function(info, value)
                            pointDB.hideempty = value
                            ClassResource:ForceUpdate()
                        end,
                        order = 5,
                    },
                    reverse = {
                        name = L["Resource_Reverse"],
                        desc = L["Resource_ReverseDesc"]:format(points.name),
                        type = "toggle",
                        hidden = points.token ~= "COMBO_POINTS",
                        get = function(info) return pointDB.reverse end,
                        set = function(info, value)
                            pointDB.reverse = value
                            ClassResource:SettingsUpdate("points", "gap")
                        end,
                        order = 10,
                    },
                    width = {
                        name = L["HuD_Width"],
                        type = "input",
                        hidden = RealUI.charInfo.class.token ~= "DEATHKNIGHT",
                        get = function(info) return tostring(pointDB.size.width) end,
                        set = function(info, value)
                            pointDB.size.width = value
                            ClassResource:SettingsUpdate("points", "size")
                        end,
                        order = 15,
                    },
                    height = {
                        name = L["HuD_Height"],
                        type = "input",
                        hidden = RealUI.charInfo.class.token ~= "DEATHKNIGHT",
                        get = function(info) return tostring(pointDB.size.height) end,
                        set = function(info, value)
                            pointDB.size.height = value
                            ClassResource:SettingsUpdate("points", "size")
                        end,
                        order = 20,
                    },
                    gap = {
                        name = L["Resource_Gap"],
                        desc = L["Resource_GapDesc"]:format(points.name),
                        type = "input",
                        hidden = RealUI.charInfo.class.token == "PALADIN",
                        get = function(info) return tostring(pointDB.size.gap) end,
                        set = function(info, value)
                            value = RealUI:ValidateOffset(value)
                            pointDB.size.gap = value
                            ClassResource:SettingsUpdate("points", "gap")
                        end,
                        order = 25,
                    },
                },
            }
            CombatFader:AddFadeConfig("ClassResource", pointOptions, 50)
            ClassResource:AddPositionConfig(pointOptions, pointDB.position, 75)
        end

        classresource = {
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
                    order = 10,
                },
                bars = barOptions,
                points = pointOptions,
            }
        }
    end
end

debug("HuD Options")
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
        other = other,
        unitframes = unitframes,
        castbars = castbars,
        classresource = classresource,
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
