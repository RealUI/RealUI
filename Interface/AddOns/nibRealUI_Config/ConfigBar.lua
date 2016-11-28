local _, private = ...
local options = private.options
local CloseHuDWindow = private.CloseHuDWindow
local debug = private.debug

-- Lua Globals --
local _G = _G
local next = _G.next
local tostring, tonumber = _G.tostring, _G.tonumber

-- Libs --
local ACD = _G.LibStub("AceConfigDialog-3.0")

-- RealUI --
local RealUI = _G.RealUI
local L = RealUI.L
local ndb = RealUI.db.profile
local ndbc = RealUI.db.char
local hudSize = ndb.settings.hudSize
local round = RealUI.Round

local uiWidth, uiHeight = _G.UIParent:GetSize()

local other do
    debug("HuD Other")
    local ActionBars = RealUI:GetModule("ActionBars")
    local dbActionBars = ActionBars.db.profile
    other = {
        name = _G.BINDING_HEADER_OTHER,
        icon = [[Interface\AddOns\nibRealUI\Media\Config\Other]],
        type = "group",
        childGroups = "tab",
        order = 1,
        args = {
            advanced = {
                name = _G.ADVANCED_OPTIONS,
                type = "execute",
                func = function(info, ...)
                    RealUI.Debug("Config", "Config Bar")
                    RealUI:LoadConfig("RealUI")
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
                        order = 30,
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
                        order = 30,
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
                name = _G.ACTIONBAR_LABEL,
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
                                    RealUI:UpdatePositioners()
                                    ActionBars:ApplyABSettings()
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
    local CombatFader = RealUI:GetModule("CombatFader")
    local UnitFrames = RealUI:GetModule("UnitFrames")
    local db = UnitFrames.db.profile
    unitframes = {
        name = _G.UNITFRAME_LABEL,
        icon = [[Interface\AddOns\nibRealUI\Media\Config\Grid]],
        type = "group",
        childGroups = "tab",
        order = 2,
        args = {
            enable = {
                name = L["General_Enabled"],
                desc = L["General_EnabledDesc"]:format("RealUI ".._G.UNITFRAME_LABEL),
                type = "toggle",
                get = function(info) return RealUI:GetModuleEnabled("UnitFrames") end,
                set = function(info, value)
                    RealUI:SetModuleEnabled("UnitFrames", value)
                    CloseHuDWindow()
                    RealUI:ReloadUIDialog()
                end,
            },
            general = {
                name = _G.GENERAL,
                type = "group",
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
                    headerFade = {
                        name = L["CombatFade"],
                        type = "header",
                        order = 45,
                    },
                    enableFade = {
                        name = L["General_Enabled"],
                        desc = L["General_EnabledDesc"]:format(L["CombatFade"]),
                        type = "toggle",
                        get = function(info) return db.misc.combatfade.enabled end,
                        set = function(info, value)
                            db.misc.combatfade.enabled = value
                        end,
                        order = 49,
                    },
                    combatFade = {
                        name = "",
                        type = "group",
                        inline = true,
                        disabled = function() return not db.misc.combatfade.enabled end,
                        order = 50,
                        args = {
                            incombat = {
                                name = L["CombatFade_InCombat"],
                                type = "range",
                                isPercent = true,
                                min = 0, max = 1, step = 0.05,
                                get = function(info) return db.misc.combatfade.opacity.incombat end,
                                set = function(info, value)
                                    db.misc.combatfade.opacity.incombat = value
                                    CombatFader:RefreshMod()
                                end,
                                order = 10,
                            },
                            harmtarget = {
                                name = L["CombatFade_HarmTarget"],
                                type = "range",
                                isPercent = true,
                                min = 0, max = 1, step = 0.05,
                                get = function(info) return db.misc.combatfade.opacity.harmtarget end,
                                set = function(info, value)
                                    db.misc.combatfade.opacity.harmtarget = value
                                    CombatFader:RefreshMod()
                                end,
                                order = 20,
                            },
                            target = {
                                name = L["CombatFade_Target"],
                                type = "range",
                                isPercent = true,
                                min = 0, max = 1, step = 0.05,
                                get = function(info) return db.misc.combatfade.opacity.target end,
                                set = function(info, value)
                                    db.misc.combatfade.opacity.target = value
                                    CombatFader:RefreshMod()
                                end,
                                order = 30,
                            },
                            hurt = {
                                name = L["CombatFade_Hurt"],
                                type = "range",
                                isPercent = true,
                                min = 0, max = 1, step = 0.05,
                                get = function(info) return db.misc.combatfade.opacity.hurt end,
                                set = function(info, value)
                                    db.misc.combatfade.opacity.hurt = value
                                    CombatFader:RefreshMod()
                                end,
                                order = 40,
                            },
                            outofcombat = {
                                name = L["CombatFade_NoCombat"],
                                type = "range",
                                isPercent = true,
                                min = 0, max = 1, step = 0.05,
                                get = function(info) return db.misc.combatfade.opacity.outofcombat end,
                                set = function(info, value)
                                    db.misc.combatfade.opacity.outofcombat = value
                                    CombatFader:RefreshMod()
                                end,
                                order = 50,
                            },
                        }
                    }
                }
            },
            units = {
                name = L["UnitFrames_Units"],
                type = "group",
                childGroups = "tab",
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
                            layout = {
                                name = L["Control_Layout"],
                                desc = L["Control_LayoutDesc"]:format("Grid2"),
                                type = "toggle",
                                disabled = not _G.Grid2,
                                get = function() return RealUI:GetModuleEnabled("GridLayout") end,
                                set = function(info, value)
                                    RealUI:SetModuleEnabled("GridLayout", value)
                                end,
                                order = 10,
                            },
                            position = {
                                name = L["Control_Position"],
                                desc = L["Control_PositionDesc"]:format("Grid2"),
                                type = "toggle",
                                disabled = not _G.Grid2,
                                get = function() return RealUI:DoesAddonMove("Grid2") end,
                                set = function(info, value)
                                    RealUI:ToggleAddonPositionControl("Grid2", value)
                                end,
                                order = 20,
                            },
                            dps = {
                                name = L["Layout_DPSTank"],
                                type = "group",
                                disabled = not _G.Grid2,
                                order = 30,
                                args = {}
                            },
                            healing = {
                                name = L["Layout_Healing"],
                                type = "group",
                                disabled = not _G.Grid2,
                                order = 40,
                                args = {}
                            },
                        }
                    },
                }
            },
        },
    }
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
        else
            local GridLayout = RealUI:GetModule("GridLayout")
            local glDB = GridLayout.db.profile
            for i, layout in next, {"dps", "healing"} do
                local args = group.args[layout].args
                local anchor = (layout == "dps") and "Bottom" or "Top"
                args.horizontal = {
                    name = L["HuD_Horizontal"],
                    disabled = function() return not RealUI:DoesAddonMove("Grid2") end,
                    type = "range",
                    width = "full",
                    min = -round(uiWidth * 0.4),
                    max = round(uiWidth * 0.4),
                    step = 1,
                    bigStep = 4,
                    get = function(info) return ndb.positions[RealUI.cLayout]["Grid"..anchor.."X"] end,
                    set = function(info, value)
                        ndb.positions[RealUI.cLayout]["Grid"..anchor.."X"] = value
                        RealUI:UpdatePositioners()
                    end,
                    order = 4,
                }
                args.vertical = {
                    name = L["HuD_Vertical"],
                    disabled = function() return not RealUI:DoesAddonMove("Grid2") end,
                    type = "range",
                    width = "full",
                    min = layout == "dps" and 0 or -round(uiWidth * 0.2),
                    max = round(uiHeight * 0.5),
                    step = 1,
                    bigStep = 2,
                    get = function(info) return ndb.positions[RealUI.cLayout]["Grid"..anchor.."Y"] end,
                    set = function(info, value)
                        ndb.positions[RealUI.cLayout]["Grid"..anchor.."Y"] = value
                        RealUI:UpdatePositioners()
                    end,
                    order = 6,
                }
                args.horizGroups = {
                    name = _G.COMPACT_UNIT_FRAME_PROFILE_HORIZONTALGROUPS,
                    disabled = function() return not RealUI:GetModuleEnabled("GridLayout") end,
                    type = "group",
                    inline = true,
                    order = 10,
                    args = {
                        smallGroups = {
                            name = L["Raid_SmallGroup"],
                            desc = L["Raid_SmallGroupDesc"],
                            type = "toggle",
                            get = function() return glDB[layout].hGroups.normal end,
                            set = function(info, value)
                                glDB[layout].hGroups.normal = value
                                GridLayout:SettingsUpdate()
                            end,
                            order = 10,
                        },
                        largeGroups = {
                            name = L["Raid_LargeGroup"],
                            desc = L["Raid_LargeGroupDesc"],
                            type = "toggle",
                            get = function() return glDB[layout].hGroups.raid end,
                            set = function(info, value)
                                glDB[layout].hGroups.raid = value
                                GridLayout:SettingsUpdate()
                            end,
                            order = 20,
                        },
                    },
                }
                args.showPets = {
                    name = _G.SHOW_PARTY_PETS_TEXT,
                    disabled = function() return not RealUI:GetModuleEnabled("GridLayout") end,
                    type = "toggle",
                    get = function() return glDB[layout].showPet end,
                    set = function(info, value)
                        glDB[layout].showPet = value
                        GridLayout:SettingsUpdate()
                    end,
                    order = 20,
                }
                args.showSolo = {
                    name = L["Raid_ShowSolo"],
                    disabled = function() return not RealUI:GetModuleEnabled("GridLayout") end,
                    type = "toggle",
                    get = function() return glDB[layout].showSolo end,
                    set = function(info, value)
                        glDB[layout].showSolo = value
                        GridLayout:SettingsUpdate()
                    end,
                    order = 30,
                }
                local prof = (layout == "dps") and "RealUI" or "RealUI-Healing"
                local Grid2DB = _G.Grid2DB and _G.Grid2DB["namespaces"]["Grid2Frame"]["profiles"][prof]
                args.height = {
                    name = _G.RAID_FRAMES_HEIGHT,
                    disabled = function() return not RealUI:GetModuleEnabled("GridLayout") end,
                    type = "range",
                    min = 20, max = 80, step = 1,
                    get = function(info)
                        debug("Get Grid Height", Grid2DB, Grid2DB and Grid2DB["frameHeight"])
                        return Grid2DB and Grid2DB["frameHeight"]
                    end,
                    set = function(info, value)
                        debug("Set Grid Height", Grid2DB, Grid2DB and Grid2DB["frameHeight"])
                        if Grid2DB and Grid2DB["frameHeight"] then
                            Grid2DB["frameHeight"] = value
                        end
                        GridLayout:SettingsUpdate()
                    end,
                    order = 40,
                }
                args.width = {
                    name = _G.RAID_FRAMES_WIDTH,
                    disabled = function() return not RealUI:GetModuleEnabled("GridLayout") end,
                    type = "range",
                    min = 40, max = 110, step = 1,
                    get = function(info) return glDB[layout].width.normal end,
                    set = function(info, value)
                        glDB[layout].width.normal = value
                        GridLayout:SettingsUpdate()
                    end,
                    order = 40,
                }
                args.width30 = {
                    name = L["Raid_30Width"],
                    disabled = function() return not RealUI:GetModuleEnabled("GridLayout") end,
                    type = "range",
                    min = 40, max = 110, step = 1,
                    get = function(info) return glDB[layout].width[30] end,
                    set = function(info, value)
                        glDB[layout].width[30] = value
                        GridLayout:SettingsUpdate()
                    end,
                    order = 40,
                }
                args.width40 = {
                    name = L["Raid_40Width"],
                    disabled = function() return not RealUI:GetModuleEnabled("GridLayout") end,
                    type = "range",
                    min = 40, max = 110, step = 1,
                    get = function(info) return glDB[layout].width[40] end,
                    set = function(info, value)
                        glDB[layout].width[40] = value
                        GridLayout:SettingsUpdate()
                    end,
                    order = 40,
                }
            end
        end
    end
end
local castbars do
    debug("HuD CastBars")
    local CastBars = RealUI:GetModule("CastBars")
    local db = CastBars.db.profile
    castbars = {
        name = L["CastBars"],
        icon = [[Interface\AddOns\nibRealUI\Media\Config\ActionBars]],
        type = "group",
        order = 3,
        args = {
            enable = {
                name = L["General_Enabled"],
                desc = L["General_EnabledDesc"]:format(L["CastBars"]),
                type = "toggle",
                get = function(info) return RealUI:GetModuleEnabled("CastBars") end,
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
    local CombatFader = RealUI:GetModule("CombatFader")
    local ClassResource = RealUI:GetModule("ClassResource")
    local db = ClassResource.db.class
    local pointDB, barDB = db.points, db.bar
    local power, bars = ClassResource:GetResources()
    debug("power and bars", power, bars)
    if power or bars then
        classresource = {
            name = L["Resource"],
            icon = [[Interface\AddOns\nibRealUI\Media\Config\Advanced]],
            type = "group",
            childGroups = "tab",
            order = 5,
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
                bars = {
                    name = bars or "",
                    type = "group",
                    hidden = bars == nil,
                    disabled = function()
                        return not RealUI:GetModuleEnabled("ClassResource")
                    end,
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
                        headerPos = {
                            name = L["General_Position"],
                            type = "header",
                            order = 25,
                        },
                        position = {
                            name = "",
                            type = "group",
                            inline = true,
                            order = 30,
                            args = {
                                lock = {
                                    name = L["General_Lock"],
                                    desc = L["General_LockDesc"],
                                    type = "toggle",
                                    get = function(info) return barDB.locked end,
                                    set = function(info, value)
                                        ClassResource[value and "Lock" or "Unlock"](ClassResource, "bar")
                                    end,
                                    order = 0,
                                },
                                x = {
                                    name = L["General_XOffset"],
                                    desc = L["General_XOffsetDesc"],
                                    type = "input",
                                    dialogControl = "NumberEditBox",
                                    get = function(info) return tostring(barDB.position.x) end,
                                    set = function(info, value)
                                        barDB.position.x = round(tonumber(value))
                                        ClassResource:SettingsUpdate("bar", "position")
                                    end,
                                    order = 10,
                                },
                                y = {
                                    name = L["General_YOffset"],
                                    desc = L["General_YOffsetDesc"],
                                    type = "input",
                                    dialogControl = "NumberEditBox",
                                    get = function(info) return tostring(barDB.position.y) end,
                                    set = function(info, value)
                                        barDB.position.y = round(tonumber(value))
                                        ClassResource:SettingsUpdate("bar", "position")
                                    end,
                                    order = 20,
                                },
                            },
                        },
                    },
                },
            }
        }
        local points = {
            name = power.name,
            type = "group",
            disabled = function() return not RealUI:GetModuleEnabled("ClassResource") end,
            order = 20,
            args = {
                hideempty = {
                    name = L["Resource_HideUnused"]:format(power.name),
                    desc = L["Resource_HideUnusedDesc"]:format(power.name),
                    type = "toggle",
                    hidden = RealUI.class == "DEATHKNIGHT",
                    get = function(info) return pointDB.hideempty end,
                    set = function(info, value)
                        pointDB.hideempty = value
                        ClassResource:ForceUpdate()
                    end,
                    order = 5,
                },
                reverse = {
                    name = L["Resource_Reverse"],
                    desc = L["Resource_ReverseDesc"]:format(power.name),
                    type = "toggle",
                    hidden = power.token ~= "COMBO_POINTS",
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
                    hidden = RealUI.class ~= "DEATHKNIGHT",
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
                    hidden = RealUI.class ~= "DEATHKNIGHT",
                    get = function(info) return tostring(pointDB.size.height) end,
                    set = function(info, value)
                        pointDB.size.height = value
                        ClassResource:SettingsUpdate("points", "size")
                    end,
                    order = 20,
                },
                gap = {
                    name = L["Resource_Gap"],
                    desc = L["Resource_GapDesc"]:format(power.name),
                    type = "input",
                    hidden = RealUI.class == "PALADIN",
                    get = function(info) return tostring(pointDB.size.gap) end,
                    set = function(info, value)
                        value = RealUI:ValidateOffset(value)
                        pointDB.size.gap = value
                        ClassResource:SettingsUpdate("points", "gap")
                    end,
                    order = 25,
                },
                headerPos = {
                    name = L["General_Position"],
                    type = "header",
                    order = 75,
                },
                position = {
                    name = "",
                    type = "group",
                    inline = true,
                    order = 80,
                    args = {
                        lock = {
                            name = L["General_Lock"],
                            desc = L["General_LockDesc"],
                            type = "toggle",
                            get = function(info) return pointDB.locked end,
                            set = function(info, value)
                                ClassResource[value and "Lock" or "Unlock"](ClassResource, "points")
                            end,
                            order = 0,
                        },
                        x = {
                            name = L["General_XOffset"],
                            desc = L["General_XOffsetDesc"],
                            type = "input",
                            dialogControl = "NumberEditBox",
                            get = function(info) return tostring(pointDB.position.x) end,
                            set = function(info, value)
                                pointDB.position.x = round(tonumber(value))
                                ClassResource:SettingsUpdate("points", "position")
                            end,
                            order = 10,
                        },
                        y = {
                            name = L["General_YOffset"],
                            desc = L["General_YOffsetDesc"],
                            type = "input",
                            dialogControl = "NumberEditBox",
                            get = function(info) return tostring(pointDB.position.y) end,
                            set = function(info, value)
                                pointDB.position.y = round(tonumber(value))
                                ClassResource:SettingsUpdate("points", "position")
                            end,
                            order = 20,
                        },
                    },
                },
            },
        }
        CombatFader:AddFadeConfig("ClassResource", points, 55)
        classresource.args.points = points
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
            icon = [[Interface\AddOns\nibRealUI\Media\Config\Close]],
            type = "group",
            order = -1,
            args = {
            },
        },
    }
}
