local _, private = ...
local options = private.options
local CloseHuDWindow = private.CloseHuDWindow
local debug = private.debug

-- Lua Globals --
local _G = _G
local next, type = _G.next, _G.type
local tostring, tonumber = _G.tostring, _G.tonumber
local tinsert = _G.table.insert

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
                        disabled = not _G.Grid2,
                        order = 30,
                        args = {
                            advanced = {
                                name = "Grid 2",
                                type = "execute",
                                func = function(info, ...)
                                    _G.Grid2:OnChatCommand("")
                                end,
                                order = 0,
                            },
                            layout = {
                                name = L["Control_Layout"],
                                desc = L["Control_LayoutDesc"]:format("Grid2"),
                                type = "toggle",
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
                                get = function() return RealUI:DoesAddonMove("Grid2") end,
                                set = function(info, value)
                                    RealUI:ToggleAddonPositionControl("Grid2", value)
                                end,
                                order = 20,
                            },
                            dps = {
                                name = L["Layout_DPSTank"],
                                type = "group",
                                order = 30,
                                args = {}
                            },
                            healing = {
                                name = L["Layout_Healing"],
                                type = "group",
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
local auratracker do
    debug("HuD AuraTracking")
    local AuraTracking = RealUI:GetModule("AuraTracking")
    local db = AuraTracking.db.profile
    local trackingData = AuraTracking.db.class
    local function SwapParentGroup(tracker, info)
        AuraTracking:CharacterUpdate({}, true)
        local parent, key = info[#info-2], info[#info-1]
        local spellOptions = auratracker.args[parent].args[key]
        auratracker.args[parent].args[key] = nil
        if tracker.shouldTrack then
            debug("Set to active")
            auratracker.args.active.args[key] = spellOptions
        else
            debug("Set to inactive")
            auratracker.args.inactive.args[key] = spellOptions
        end
    end
    local function GetNameOrder(spellData)
        local order, pos, name, color = 1, "", ""

        if spellData.customName then
            name = spellData.customName
        elseif type(spellData.spell) == "table" then
            for i = 1, #spellData.spell do
                debug("iter spell table", i)
                local spellName, nextSpell = _G.GetSpellInfo(spellData.spell[i]), _G.GetSpellInfo(spellData.spell[i+1])
                if not spellName then spellName = _G.UNKNOWN end
                if spellName ~= nextSpell then
                    debug("These two are different", i, spellName)
                    -- Only add a spell if nextSpell is different.
                    name = name..spellName..(nextSpell and ", " or "")
                end
            end
        else
            name = _G.GetSpellInfo(spellData.spell) or L["AuraTrack_SpellNameID"]
        end
        debug("Name:", name, spellData.spell)

        if spellData.unit == "target" then
            order = order + 1
            color = "ff0000"
        else
            color = "00ff00"
        end
        if spellData.order and spellData.order > 0 then
            order = order * 10 + spellData.order
            pos = spellData.order.." "
        else
            order = 69 + order
        end

        name = (pos.."|cff%s%s|r"):format(color, name)
        return name, order
    end
    local function CreateTrackerSettings(tracker, spellData)
        local name, order = GetNameOrder(spellData)
        local specCache, useSpec = {}
        do
            local numSpecs = 0
            for i = 1, #spellData.specs do
                specCache[i] = spellData.specs[i]
                if spellData.specs[i] then
                    numSpecs = numSpecs + 1
                end
            end
            if numSpecs == #spellData.specs then
                useSpec = false
            elseif numSpecs == 1 then
                useSpec = true
            end
        end

        return {
            name = name,
            type = "group",
            order = order,
            args = {
                name = {
                    name = L["AuraTrack_SpellNameID"],
                    desc = L["AuraTrack_NoteSpellID"],
                    type = "input",
                    validate = function(info, value) --,158300
                        debug("Validate Spellname", info[#info-1], value)
                        local isSpell
                        if value:find(",") then
                            debug("Multi-spell")
                            value = {_G.strsplit(",", value)}
                            for i = 1, #value do
                                local spell = _G.strtrim(value[i])
                                isSpell = _G.GetSpellInfo(spell) and true or false
                                debug("Value "..i, spell, isSpell)
                                if not isSpell then
                                    return L["AuraTrack_InvalidName"]:format(spell)
                                end
                            end
                        else
                            isSpell = _G.GetSpellInfo(value) and true or false
                            debug("One spell", isSpell)
                        end
                        return isSpell or L["AuraTrack_InvalidName"]:format(value)
                    end,
                    get = function(info)
                        local value = ""
                        if type(spellData.spell) == "table" then
                            for i = 1, #spellData.spell do
                                value = value..(i==1 and "" or ",")..spellData.spell[i]
                            end
                        else
                            value = tostring(spellData.spell)
                        end
                        return value
                    end,
                    set = function(info, value)
                        debug("Set Spellname", info[#info-2], info[#info-1], value)
                        if value:find(",") then
                            debug("Multi-spell")
                            if type(spellData.spell) ~= "table" then
                                spellData.spell = {}
                            end
                            _G.wipe(spellData.spell)
                            value = { _G.strsplit(",", value) } 
                            for i = 1, #value do
                                local spell = _G.strtrim(value[i])
                                tinsert(spellData.spell, tonumber(spell) or spell)
                            end
                        else
                            spellData.spell = tonumber(value) or value
                        end

                        local spellOptions = auratracker.args[info[#info-2]].args[info[#info-1]]
                        spellOptions.name, spellOptions.order = GetNameOrder(spellData)
                    end,
                    order = 10,
                },
                enable = {
                    name = L["General_Enabled"],
                    desc = L["General_EnabledDesc"]:format(L["AuraTrack_Selected"]),
                    type = "toggle",
                    get = function(info)
                        return spellData.shouldLoad
                    end,
                    set = function(info, value)
                        debug("Set Enable", info[#info-2], info[#info-1], value)
                        if value then
                            tracker:Enable()
                        else
                            tracker:Disable()
                        end
                        spellData.shouldLoad = value

                        SwapParentGroup(tracker, info)
                    end,
                    order = 20,
                },
                type = {
                    name = L["AuraTrack_Type"],
                    desc = L["AuraTrack_TypeDesc"],
                    type = "select",
                    style = "radio",
                    values = function()
                        return {
                            buff = L["AuraTrack_Buff"],
                            debuff = L["AuraTrack_Debuff"],
                        }
                    end,
                    get = function(info)
                        return spellData.auraType or "buff"
                    end,
                    set = function(info, value)
                        spellData.auraType = value

                        local spellOptions = auratracker.args[info[#info-2]].args[info[#info-1]]
                        spellOptions.name, spellOptions.order = GetNameOrder(spellData)
                    end,
                    order = 30,
                },
                position = {
                    name = L["General_Position"],
                    desc = L["AuraTrack_StaticDesc"],
                    type = "range",
                    min = 0, max = 6, step = 1,
                    get = function(info) return spellData.order or 0 end,
                    set = function(info, value)
                        spellData.order = value

                        local spellOptions = auratracker.args[info[#info-2]].args[info[#info-1]]
                        spellOptions.name, spellOptions.order = GetNameOrder(spellData)
                    end,
                    order = 40,
                },
                unit = {
                    name = L["AuraTrack_Unit"],
                    type = "select",
                    values = function()
                        return {
                            player = _G.PLAYER,
                            target = _G.TARGET,
                            pet = _G.PET,
                        }
                    end,
                    get = function(info) return spellData.unit end,
                    set = function(info, value)
                        spellData.unit = value
                    end,
                    order = 50,
                },
                useSpec = {
                    name = _G.SPECIALIZATION,
                    desc = L["General_Tristate"..tostring(useSpec)].."\n"..
                        L["AuraTrack_TristateSpec"..tostring(useSpec)],
                    type = "toggle",
                    tristate = true,
                    get = function(info) return useSpec end,
                    set = function(info, value)
                        debug("useSpec set", value)
                        local spellOptions = auratracker.args[info[#info-2]].args[info[#info-1]].args
                        if value == false then
                            spellOptions.spec.type = "select"
                            spellOptions.spec.disabled = true
                            for i = 1, #spellData.specs do
                                spellData.specs[i] = true
                            end
                        elseif value == true then
                            spellOptions.spec.disabled = false
                            for i = 1, #spellData.specs do
                                spellData.specs[i] = specCache[i]
                            end
                        else
                            spellOptions.spec.type = "multiselect"
                        end
                        spellOptions.useSpec.desc = L["General_Tristate"..tostring(value)].."\n"..
                            L["AuraTrack_TristateSpec"..tostring(value)]
                        useSpec = value
                    end,
                    order = 60,
                },
                spec = {
                    name = "",
                    type = (useSpec == nil) and "multiselect" or "select",
                    disabled = function() return useSpec == false end,
                    values = function()
                        local table = {}
                        for i = 1, _G.GetNumSpecializations() do
                            local _, specName, _, specIcon = _G.GetSpecializationInfo(i)
                            table[i] = "|T"..specIcon..":0:0:0:0:64:64:4:60:4:60|t "..specName
                        end
                        return table
                    end,
                    get = function(info, key)
                        debug("Spec get", key)
                        if key then
                            return spellData.specs[key]
                        else
                            for i = 1, #spellData.specs do
                                debug("Check", i, spellData.specs[i])
                                if spellData.specs[i] then
                                    return i
                                end
                            end
                        end
                    end,
                    set = function(info, key, value)
                        local specs = spellData.specs
                        debug("Spec set", key, value, specs[key])
                        if value == nil then
                            for i = 1, #specs do
                                debug("Apply", i, i == key)
                                specs[i] = (i == key)
                                specCache[i] = specs[i]
                            end
                        else
                            specs[key] = value
                            specCache[key] = value
                        end
                        SwapParentGroup(tracker, info)
                    end,
                    order = 70,
                },
                minLvl = {
                    name = L["AuraTrack_MinLevel"],
                    desc = L["AuraTrack_MinLevelDesc"],
                    type = "input",
                    validate = function(info, value)
                        debug("Validate minLvl", info[#info-1], value)
                        value = _G.tonumber(value)
                        return value >= 0 and value <= _G.MAX_PLAYER_LEVEL
                    end,
                    get = function(info) return _G.tostring(spellData.minLevel or 0) end,
                    set = function(info, value)
                        spellData.minLevel = _G.tonumber(value)
                    end,
                    order = 80,
                },
                visibility = {
                    name = L["AuraTrack_Visibility"],
                    type = "group",
                    inline = true,
                    order = 90,
                    args = {
                        hideStacks = {
                            name = L["AuraTrack_HideStack"],
                            desc = L["AuraTrack_HideStackDesc"],
                            type = "toggle",
                            get = function(info) return spellData.hideStacks end,
                            set = function(info, value)
                                spellData.hideStacks = value
                            end,
                            order = 10,
                        },
                        noExclude = {
                            name = L["AuraTrack_NoExclude"],
                            desc = L["AuraTrack_NoExcludeDesc"],
                            type = "toggle",
                            hidden = not _G.Raven,
                            get = function(info) return spellData.noExclude end,
                            set = function(info, value)
                                spellData.noExclude = value
                            end,
                            order = 20,
                        },
                    }
                },
                debug = {
                    name = L["General_Debug"],
                    desc = L["General_DebugDesc"],
                    type = "toggle",
                    get = function(info)
                        return spellData.debug
                    end,
                    set = function(info, value)
                        if value then
                            spellData.debug = auratracker.args[info[#info-2]].args[info[#info-1]].name
                        else
                            spellData.debug = false
                        end
                    end,
                    order = 100,
                },
                remove = {
                    name = L["AuraTrack_Remove"],
                    type = "execute",
                    disabled = tracker.isDefault,
                    confirm = true,
                    confirmText = L["AuraTrack_RemoveConfirm"],
                    func = function(info, ...)
                        debug("Remove", info[#info-2], info[#info-1], ...)
                        debug("Removed ID", tracker.id, spellData.spell)
                        trackingData[tracker.classID.."-"..tracker.id] = nil
                        auratracker.args[info[#info-2]].args[info[#info-1]] = nil
                    end,
                    order = -1,
                },
            }
        }
    end
    auratracker = {
        name = L["AuraTrack"],
        icon = [[Interface\AddOns\nibRealUI\Media\Config\Auras]],
        type = "group",
        order = 4,
        args = {
            new = {
                name = L["AuraTrack_Create"],
                type = "execute",
                disabled = function() return not RealUI:GetModuleEnabled("AuraTracking") end,
                func = function(info, ...)
                    debug("Create New", info[#info], info[#info-1], ...)
                    local tracker, spellData = AuraTracking:CreateNewTracker()
                    debug("New trackerID:", tracker.id)
                    auratracker.args.active.args[tracker.id] = CreateTrackerSettings(tracker, spellData)
                end,
                order = 10,
            },
            enable = {
                name = L["General_Enabled"],
                desc = L["General_EnabledDesc"]:format(L["AuraTrack"]),
                type = "toggle",
                get = function(info) return RealUI:GetModuleEnabled("AuraTracking") end,
                set = function(info, value)
                    RealUI:SetModuleEnabled("AuraTracking", value)
                    CloseHuDWindow()
                    RealUI:ReloadUIDialog()
                end,
                order = 20,
            },
            lock = {
                name = L["General_Lock"],
                desc = L["General_LockDesc"],
                type = "toggle",
                disabled = function() return not RealUI:GetModuleEnabled("AuraTracking") end,
                get = function(info) return db.locked end,
                set = function(info, value)
                    AuraTracking[value and "Lock" or "Unlock"](AuraTracking)
                end,
                order = 30,
            },
            options = {
                name = L["AuraTrack_TrackerOptions"],
                type = "group",
                disabled = function() return not RealUI:GetModuleEnabled("AuraTracking") end,
                childGroups = "tab",
                order = 40,
                args = {
                    size = {
                        name = L["AuraTrack_Size"],
                        type = "range",
                        min = 24, max = 64, step = 1,
                        get = function(info) return db.style.slotSize end,
                        set = function(info, value)
                            db.style.slotSize = value
                            AuraTracking:SettingsUpdate("slotSize")
                        end,
                        order = 10,
                    },
                    padding = {
                        name = L["AuraTrack_Padding"],
                        type = "range",
                        min = 0, max = 32, step = 1,
                        get = function(info) return db.style.padding end,
                        set = function(info, value)
                            db.style.padding = value
                            AuraTracking:SettingsUpdate("padding")
                        end,
                        order = 20,
                    },
                    inactiveOpacity = {
                        name = L["AuraTrack_InactiveOpacity"],
                        type = "range",
                        isPercent = true,
                        min = 0, max = 1, step = 0.05,
                        get = function(info) return db.indicators.fadeOpacity end,
                        set = function(info, value)
                            db.indicators.fadeOpacity = value
                            AuraTracking:SettingsUpdate("fadeOpacity")
                        end,
                        order = 30,
                    },
                    visibility = {
                        name = L["AuraTrack_Visibility"],
                        type = "group",
                        inline = true,
                        order = 40,
                        args = {
                            showCombat = {
                                name = L["AuraTrack_ShowInCombat"],
                                desc = L["AuraTrack_ShowInCombatDesc"],
                                type = "toggle",
                                get = function(info) return db.visibility.showCombat end,
                                set = function(info, value)
                                    db.visibility.showCombat = value
                                end,
                                order = 10,
                            },
                            showHostile = {
                                name = L["AuraTrack_ShowHostile"],
                                desc = L["AuraTrack_ShowHostileDesc"],
                                type = "toggle",
                                get = function(info) return db.visibility.showHostile end,
                                set = function(info, value)
                                    db.visibility.showHostile = value
                                end,
                                order = 20,
                            },
                            showPvE = {
                                name = L["AuraTrack_ShowInPvE"],
                                desc = L["AuraTrack_ShowInPvEDesc"],
                                type = "toggle",
                                get = function(info) return db.visibility.showPvE end,
                                set = function(info, value)
                                    db.visibility.showPvE = value
                                end,
                                order = 30,
                            },
                            showPvP = {
                                name = L["AuraTrack_ShowInPvP"],
                                desc = L["AuraTrack_ShowInPvPDesc"],
                                type = "toggle",
                                get = function(info) return db.visibility.showPvP end,
                                set = function(info, value)
                                    db.visibility.showPvP = value
                                end,
                                order = 40,
                            },
                        }
                    },
                    reset = {
                        name = L["AuraTrack_ResetTrackers"],
                        desc = L["AuraTrack_ResetTrackersDesc"]:format(RealUI.classLocale),
                        type = "execute",
                        confirmText = L["AuraTrack_ResetConfirm"]:format(RealUI.classLocale),
                        func = function(info, ...)
                            _G.nibRealUIDB.namespaces.AuraTracking.class[RealUI.class] = nil
                            CloseHuDWindow()
                            RealUI:ReloadUIDialog()
                        end,
                        order = 45,
                    },
                    position = {
                        name = L["General_Position"],
                        type = "header",
                        order = 49,
                    },
                    left = {
                        name = _G.PLAYER,
                        type = "group",
                        order = 50,
                        args = {}
                    },
                    right = {
                        name = _G.TARGET,
                        type = "group",
                        order = 55,
                        args = {}
                    },
                }
            },
            active = {
                name = L["AuraTrack_ActiveTrackers"],
                type = "group",
                disabled = function() return not RealUI:GetModuleEnabled("AuraTracking") end,
                order = 50,
                args = {
                }
            },
            inactive = {
                name = L["AuraTrack_InactiveTrackers"],
                type = "group",
                disabled = function() return not RealUI:GetModuleEnabled("AuraTracking") end,
                order = 50,
                args = {
                }
            }
        }
    }
    for _, side in next, {"left", "right"} do
        local settings = auratracker.args.options.args[side]
        local position = db.position[side]
        --[[
        settings.args.point = {
            order = 10,
            type = "select",
            name = L["Anchor"],
            desc = L["Change the current anchor point of the bar."],
            values = validAnchors,
            get = function(info) return position.point end,
            set = function(info, value)
                position.point = value
                AuraTracking:SettingsUpdate("position")
            end,
        }
        ]]
        settings.args.x = {
            name = L["General_XOffset"],
            desc = L["General_XOffsetDesc"],
            type = "input",
            dialogControl = "NumberEditBox",
            get = function(info) return tostring(position.x) end,
            set = function(info, value)
                position.x = round(tonumber(value))
                AuraTracking:SettingsUpdate("position")
            end,
            order = 20,
        }
        settings.args.y = {
            name = L["General_YOffset"],
            desc = L["General_YOffsetDesc"],
            type = "input",
            dialogControl = "NumberEditBox",
            get = function(info) return tostring(position.y) end,
            set = function(info, value)
                position.y = round(tonumber(value))
                AuraTracking:SettingsUpdate("position")
            end,
            order = 30,
        }
    end
    for tracker, spellData in AuraTracking:IterateTrackers() do
        local settings = CreateTrackerSettings(tracker, spellData)
        if tracker.shouldTrack then
            auratracker.args.active.args[tracker.id] = settings
        else
            auratracker.args.inactive.args[tracker.id] = settings
        end
    end
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
        auratracker = auratracker,
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
