local _, private = ...

-- Lua Globals --
-- luacheck: globals ipairs next tremove tinsert
-- luacheck: globals tostring tonumber

-- Libs --
local ACR = _G.LibStub("AceConfigRegistry-3.0")
local LSM = _G.LibStub("LibSharedMedia-3.0")

-- RealUI --
local RealUI = _G.RealUI
local L = RealUI.L
local round = RealUI.Round

local CombatFader = RealUI:GetModule("CombatFader")
local FramePoint = RealUI:GetModule("FramePoint")
local order = 0

local ValidateOffset = private.ValidateOffset
local options = private.options
local debug = private.debug

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
options.RealUI = {
    name = "|cffffffffRealUI|r "..RealUI:GetVerString(true),
    type = "group",
    args = {
        profiles = _G.LibStub("AceDBOptions-3.0"):GetOptionsTable(RealUI.db),
    }
}

local optArgs = options.RealUI.args
_G.LibStub("LibDualSpec-1.0"):EnhanceOptions(optArgs.profiles, RealUI.db)



local nameFormat = _G.ENABLE .. " %s"
local function CreateAddonSection(name, args)
    debug("CreateAddonSection", name, args)

    local hide = false

    if not args then
        local addonName = "RealUI_" .. name
        local _, _, _, loadable, reason = _G.GetAddOnInfo(addonName)
        if loadable then
            args = {
                enable = {
                    name = nameFormat:format(L[name]),
                    type = "execute",
                    func = function(info, value)
                        _G.EnableAddOn(addonName)
                        _G.ReloadUI()
                    end,
                    order = 1,
                },
            }
        else
            hide = reason == "MISSING"
            args = {}
        end
    end

    return {
        name = L[name],
        type = "group",
        hidden = hide,
        order = order,
        args = args
    }
end

do -- RealUI
    debug("Adv Core")
    local infobar do
        local MODNAME = "Infobar"
        local Infobar = RealUI:GetModule(MODNAME)
        local allEnabled, allLabeled, allIcons
        local progress
        infobar = {
            name = L["Infobar"],
            desc = "Information / Button display.",
            type = "group",
            args = {
                header = {
                    name = L["Infobar"],
                    type = "header",
                    order = 10,
                },
                desc = {
                    name = "Information / Button display.",
                    type = "description",
                    fontSize = "medium",
                    order = 20,
                },
                enabled = {
                    name = L["General_Lock"],
                    desc = L["General_LockDesc"],
                    type = "toggle",
                    get = function() return Infobar.locked end,
                    set = function(info, value)
                        if value then
                            Infobar:Lock()
                        else
                            Infobar:Unlock()
                        end
                    end,
                    order = 30,
                },
                gap1 = {
                    name = " ",
                    type = "description",
                    order = 31,
                },
                bgAlpha = {
                    name = L["Appearance_FrameColor"],
                    type = "range",
                    isPercent = true,
                    min = 0, max = 1, step = 0.05,
                    get = function(info) return Infobar.db.profile.bgAlpha end,
                    set = function(info, value)
                        Infobar.db.profile.bgAlpha = value
                        Infobar:SettingsUpdate(info[#info])
                    end,
                    order = 34,
                },
                statusBar = {
                    name = L["Infobar_ShowStatusBar"],
                    desc = L["Infobar_ShowStatusBarDesc"],
                    type = "toggle",
                    disabled = function() return not Infobar.db.profile.blocks.realui.progress.enabled end,
                    get = function() return Infobar.db.profile.showBars end,
                    set = function(info, value)
                        Infobar.db.profile.showBars = value
                        Infobar:SettingsUpdate(info[#info], progress)
                    end,
                    order = 40,
                },
                gap2 = {
                    name = " ",
                    type = "description",
                    order = 41,
                },
                inCombat = {
                    name = L["Infobar_CombatTooltips"],
                    desc = L["Infobar_CombatTooltipsDesc"],
                    type = "toggle",
                    get = function() return Infobar.db.profile.combatTips end,
                    set = function(info, value)
                        Infobar.db.profile.combatTips = value
                    end,
                    order = 50,
                },
                blockGap = {
                    name = L["Infobar_BlockGap"],
                    desc = L["Infobar_BlockGapDesc"],
                    type = "input",
                    width = "half",
                    get = function(info) return _G.tostring(Infobar.db.profile.blockGap) end,
                    set = function(info, value)
                        value = ValidateOffset(value)
                        Infobar.db.profile.blockGap = value
                        Infobar:SettingsUpdate(info[#info])
                    end,
                    order = 52,
                },
                blocks = {
                    name = "Blocks",
                    type = "group",
                    inline = true,
                    order = 60,
                    args = {
                        enableAll = {
                            name = L["Infobar_AllBlocks"],
                            desc = L["General_EnabledDesc"]:format(L["Infobar_AllBlocks"]),
                            type = "toggle",
                            tristate = true,
                            get = function() return allEnabled end,
                            set = function(data, value)
                                for dataObj, block in Infobar:IterateBlocks() do
                                    local blockInfo = Infobar:GetBlockInfo(block.name, dataObj)
                                    if blockInfo.enabled ~= -1 then
                                        if value then
                                            Infobar:AddBlock(block.name, dataObj, blockInfo)
                                        elseif blockInfo.enabled then
                                            Infobar:RemoveBlock(block.name, dataObj, blockInfo)
                                        end
                                        blockInfo.enabled = not not value
                                    end
                                end
                                allEnabled = not not value
                            end,
                            order = 1,
                        },
                        showLabel = {
                            name = L["Infobar_ShowLabel"],
                            type = "toggle",
                            tristate = true,
                            get = function() return allLabeled end,
                            set = function(info, value)
                                for dataObj, block in Infobar:IterateBlocks() do
                                    local blockInfo = Infobar:GetBlockInfo(block.name, dataObj)
                                    if blockInfo.enabled ~= -1 then
                                        blockInfo.showLabel = not not value
                                        if blockInfo.enabled then
                                            block:AdjustElements(blockInfo)
                                        end
                                    end
                                end
                                allLabeled = not not value
                            end,
                            order = 2,
                        },
                        showIcon = {
                            name = L["Infobar_ShowIcon"],
                            type = "toggle",
                            tristate = true,
                            get = function() return allIcons end,
                            set = function(info, value)
                                for dataObj, block in Infobar:IterateBlocks() do
                                    local blockInfo = Infobar:GetBlockInfo(block.name, dataObj)
                                    if blockInfo.enabled ~= -1 then
                                        blockInfo.showIcon = not not value
                                        if blockInfo.enabled then
                                            block:AdjustElements(blockInfo)
                                        end
                                    end
                                end
                                allIcons = not not value
                            end,
                            order = 3,
                        },
                        realui = {
                            name = "RealUI Blocks",
                            type = "header",
                            order = 10,
                        },
                        other = {
                            name = "3rd Party Blocks",
                            type = "header",
                            order = 110,
                        },
                    }
                }
            },
        }

        local realuiOrder, otherOrder = 10, 110
        local numBlocks, numEnabled, numLabeled, numIcons = 0, 0, 0, 0
        for index, block in Infobar:IterateBlocks() do
            local name = block.name
            if name == "progress" then
                progress = block
            end
            local blockInfo = Infobar:GetBlockInfo(name, block.dataObj)
            if blockInfo.enabled ~= -1 then
                numBlocks = numBlocks + 1
                local displayName = block.dataObj.name or name
                local blockOrder = (block.dataObj.type == "RealUI" and realuiOrder or otherOrder) + index
                infobar.args.blocks.args[name.."Toggle"] = {
                    name = displayName,
                    desc = L["General_EnabledDesc"]:format(displayName),
                    type = "toggle",
                    get = function() return blockInfo.enabled end,
                    set = function(data, value)
                        if value then
                            block = Infobar:AddBlock(name, block.dataObj, blockInfo)
                        else
                            Infobar:RemoveBlock(name, block.dataObj, blockInfo)
                        end
                        allEnabled = nil
                        blockInfo.enabled = value
                    end,
                    order = blockOrder,
                }
                infobar.args.blocks.args[name.."Label"] = {
                    name = L["Infobar_ShowLabel"],
                    type = "toggle",
                    disabled = function() return not blockInfo.enabled end,
                    get = function() return blockInfo.showLabel end,
                    set = function(data, value)
                        allLabeled = nil
                        blockInfo.showLabel = value
                        block:AdjustElements(blockInfo)
                    end,
                    order = blockOrder + 1,
                }
                infobar.args.blocks.args[name.."Icon"] = {
                    name = L["Infobar_ShowIcon"],
                    type = "toggle",
                    disabled = function() return not blockInfo.enabled end,
                    get = function() return blockInfo.showIcon end,
                    set = function(data, value)
                        allIcons = nil
                        blockInfo.showIcon = value
                        block:AdjustElements(blockInfo)
                    end,
                    order = blockOrder + 2,
                }
                if block.dataObj.type == "RealUI" then
                    realuiOrder = realuiOrder + 5
                else
                    otherOrder = otherOrder + 5
                end

                if blockInfo.enabled then
                    numEnabled = numEnabled + 1
                end

                if  blockInfo.showLabel then
                    numLabeled = numLabeled + 1
                end

                if blockInfo.showIcon then
                    numIcons = numIcons + 1
                end
            end
        end
        if numEnabled == 0 then
            allEnabled = false
        elseif numEnabled == numBlocks then
            allEnabled = true
        else
            allEnabled = nil
        end

        if numLabeled == 0 then
            allLabeled = false
        elseif numLabeled == numBlocks then
            allLabeled = true
        else
            allLabeled = nil
        end

        if numIcons == 0 then
            allIcons = false
        elseif numIcons == numBlocks then
            allIcons = true
        else
            allIcons = nil
        end
    end
    local screenSaver do
        local MODNAME = "ScreenSaver"
        local ScreenSaver = RealUI:GetModule(MODNAME)
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
                        combatwarning = {
                            name = "Combat Warning",
                            desc = "Play a warning sound if you enter combat while AFK.",
                            type = "toggle",
                            get = function() return ScreenSaver.db.profile.combatwarning end,
                            set = function(info, value)
                                ScreenSaver.db.profile.combatwarning = value
                            end,
                            order = 30,
                        },
                    },
                },
            },
        }
    end
    optArgs.core = {
        name = "Core",
        desc = "Core RealUI modules.",
        type = "group",
        order = 0,
        args = {
            infobar = infobar,
            screenSaver = screenSaver,
        },
    }
end
do -- CombatText
    debug("CombatText")
    order = order + 1

    local args
    local CombatText = RealUI:GetModule("CombatText", true)
    local function appGet(info)
        return CombatText.db.global[info[#info]]
    end
    local function appSet(info, value)
        CombatText.db.global[info[#info]] = value
        CombatText:UpdateLineOptions()
    end

    local function fontGet(info)
        return CombatText.db.global.fonts[info[#info-1]][info[#info]]
    end
    local function fontSet(info, value)
        CombatText.db.global.fonts[info[#info-1]][info[#info]] = value
        CombatText:UpdateLineOptions()
    end

    debug("Module", CombatText)
    if CombatText then
        args = {
            lock = {
                name = L["General_Lock"],
                desc = L["General_LockDesc"],
                type = "toggle",
                get = function(info) return FramePoint:IsModLocked(CombatText) end,
                set = function(info, value)
                    if value then
                        FramePoint:LockMod(CombatText)
                    else
                        FramePoint:UnlockMod(CombatText)
                    end
                end,
                order = 0,
            },
            scrollDuration = {
                name = L.CombatText_ScrollDuration,
                desc = L.CombatText_ScrollDurationDesc,
                type = "range",
                min = 1, max = 5, step = 0.5,
                get = appGet,
                set = appSet,
                order = 1,
            },
            test = {
                name = _G.PREVIEW,
                type = "execute",
                func = function()
                    CombatText:ToggleTest()
                end,
                order = 2,
            },
            normal = {
                name = L.Fonts_Normal,
                type = "group",
                inline = true,
                order = 10,
                args = {
                    name = {
                        name = "",
                        type = "select",
                        dialogControl = "LSM30_Font",
                        values = _G.AceGUIWidgetLSMlists.font,
                        get = fontGet,
                        set = fontSet,
                        order = 1,
                    },
                    size = {
                        name = "",
                        type = "range",
                        min = 8, max = 24, step = 1,
                        get = fontGet,
                        set = fontSet,
                        order = 2,
                    },
                }
            },
            sticky = {
                name = L.Fonts_Crit,
                type = "group",
                inline = true,
                order = 20,
                args = {
                    name = {
                        name = "",
                        type = "select",
                        dialogControl = "LSM30_Font",
                        values = _G.AceGUIWidgetLSMlists.font,
                        get = fontGet,
                        set = fontSet,
                        order = 1,
                    },
                    size = {
                        name = "",
                        type = "range",
                        min = 8, max = 24, step = 1,
                        get = fontGet,
                        set = fontSet,
                        order = 2,
                    },
                }
            },
        }
    end


    debug("CombatText create")
    optArgs.combatText = CreateAddonSection("CombatText", args)
end
do -- Inventory
    debug("Inventory")
    order = order + 1

    local args
    local Inventory = RealUI:GetModule("Inventory", true)
    local function appGet(info)
        return Inventory.db.global[info[#info]]
    end
    local function appSet(info, value)
        Inventory.db.global[info[#info]] = value
        Inventory:Update()
    end

    local function AddFilter(filter)
        debug("AddFilter", filter.tag)
        local tag = filter.tag

        args.filters.args[tag.."Index"] = {
            name = filter.name,
            type = "input",
            width = "half",
            get = function() return tostring(filter:GetIndex()) end,
            set = function(_, value)
                filter:SetIndex(tonumber(value))
            end,
            order = function()
                return filter:GetIndex() * 10
            end,
        }
        args.filters.args[tag.."Up"] = {
            name = _G.TRACKER_SORT_MANUAL_UP,
            type = "execute",
            width = filter.isCustom and 1.05 or 1.3,
            func = function()
                filter:SetIndex(filter:GetIndex() - 1)
            end,
            order = function()
                return (filter:GetIndex() * 10) + 1
            end,
        }
        args.filters.args[tag.."Down"] = {
            name = _G.TRACKER_SORT_MANUAL_DOWN,
            type = "execute",
            width = filter.isCustom and 1.05 or 1.3,
            func = function()
                filter:SetIndex(filter:GetIndex() + 1)
            end,
            order = function()
                return (filter:GetIndex() * 10) + 2
            end,
        }
        args.filters.args[tag.."Delete"] = {
            name = _G.DELETE,
            type = "execute",
            hidden = not filter.isCustom,
            width = "half",
            func = function()
                filter:Delete()

                args.filters.args[tag.."Index"] = nil
                args.filters.args[tag.."Up"] = nil
                args.filters.args[tag.."Down"] = nil
                args.filters.args[tag.."Delete"] = nil

                ACR:NotifyChange("RealUI")
                Inventory.Update()
            end,
            order = function()
                return (filter:GetIndex() * 10) + 3
            end,
        }
    end

    debug("Module", Inventory)
    if Inventory then
        args = {
            maxHeight = {
                name = L.Inventory_MaxHeight,
                desc = L.Inventory_MaxHeightDesc,
                type = "range",
                isPercent = true,
                min = 0.3, max = 0.7, step = 0.05,
                get = appGet,
                set = appSet,
                order = 1,
            },
            sellJunk = {
                name = L.Inventory_SellJunk,
                type = "toggle",
                get = appGet,
                set = appSet,
                order = 2,
            },
            addFilter = {
                name = _G.ADD_FILTER,
                type = "input",
                get = function() return _G.FILTER_NAME end,
                set = function(_, value)
                    local tag = value:lower()

                    Inventory:CreateCustomFilter(tag, value)
                    AddFilter(tag)
                end,
                order = 3,
            },
            filters = {
                name = _G.FILTERS,
                type = "group",
                inline = true,
                order = 10,
                args = {
                }
            }
        }

        for i, filter in Inventory:IndexedFilters() do
            AddFilter(filter)
        end
    end


    debug("Inventory create")
    optArgs.inventory = CreateAddonSection("Inventory", args)
end
do -- Skins
    debug("Adv Skins")
    order = order + 1

    local SkinsDB = RealUI.GetOptions("Skins")
    local function appGet(info)
        return SkinsDB.profile[info[#info]]
    end
    local function appSet(info, value)
        SkinsDB.profile[info[#info]] = value
        RealUI:UpdateFrameStyle()
    end

    local function fontGet(info)
        return SkinsDB.profile.fonts[info[#info]].name
    end
    local function fontSet(info, value)
        --[[
            We have to save the path because Skins gets loaded before other
            addons have a chance to properly register thier fonts.
        ]]
        SkinsDB.profile.fonts[info[#info]].name = value
        SkinsDB.profile.fonts[info[#info]].path = LSM:Fetch("font", value)
    end

    local Color = _G.Aurora.Color
    local classColors do
        classColors = {
            name = _G.CLASS_COLORS,
            type = "group",
            args = {
            }
        }

        for classToken, color in next, _G.CUSTOM_CLASS_COLORS do
            classColors.args[classToken] = {
                name = _G.LOCALIZED_CLASS_NAMES_MALE[classToken],
                type = "color",
                get = function(info) return color:GetRGB() end,
                set = function(info, r, g, b)
                    color:SetRGB(r, g, b)
                    _G.CUSTOM_CLASS_COLORS:NotifyChanges()
                end,
            }
        end
    end
    local minScale, maxScale = 0.48, 1
    local addons do
        local addonSkins = _G.Aurora.Base.GetAddonSkins()
        addons = {
            name = _G.ADDONS,
            type = "group",
            hidden = #addonSkins == 0,
            args = {
            }
        }

        for i = 1, #addonSkins do
            local name = addonSkins[i]
            if not name:find("RealUI") then
                addons.args[name] = {
                    name = name,
                    type = "toggle",
                    get = function() return SkinsDB.profile.addons[name] end,
                    set = function(info, value)
                        SkinsDB.profile.addons[name] = value
                    end,
                }
            end
        end
    end
    optArgs.skins = {
        name = L.Appearance_Skins,
        type = "group",
        order = order,
        args = {
            note = {
                name = L.General_NoteReload,
                type = "description",
                order = -1,
            },
            headerAppear = {
                name = _G.APPEARANCE_LABEL,
                type = "header",
                order = 0,
            },
            frameColor = {
                name = L.Appearance_FrameColor,
                type = "color",
                hasAlpha = true,
                get = function(info)
                    return SkinsDB.profile.frameColor.r, SkinsDB.profile.frameColor.g, SkinsDB.profile.frameColor.b, SkinsDB.profile.frameColor.a
                end,
                set = function(info, r, g, b, a)
                    Color.frame:SetRGBA(r, g, b, Color.frame.a)
                    SkinsDB.profile.frameColor.r = r
                    SkinsDB.profile.frameColor.g = g
                    SkinsDB.profile.frameColor.b = b
                    SkinsDB.profile.frameColor.a = a
                    RealUI:UpdateFrameStyle()
                end,
                order = 1,
            },
            buttonColor = {
                name = L.Appearance_ButtonColor,
                type = "color",
                get = function(info)
                    return SkinsDB.profile.buttonColor.r, SkinsDB.profile.buttonColor.g, SkinsDB.profile.buttonColor.b
                end,
                set = function(info, r, g, b)
                    Color.button:SetRGBA(r, g, b)
                    SkinsDB.profile.buttonColor.r = r
                    SkinsDB.profile.buttonColor.g = g
                    SkinsDB.profile.buttonColor.b = b
                    RealUI:UpdateFrameStyle()
                end,
                order = 2,
            },
            stripeAlpha = {
                name = L.Appearance_StripeOpacity,
                type = "range",
                isPercent = true,
                min = 0, max = 1, step = 0.05,
                get = appGet,
                set = appSet,
                order = 3,
            },
            headerFonts = {
                name = L.Fonts,
                type = "header",
                order = 10,
            },
            normal = {
                name = L.Fonts_Normal,
                desc = L.Fonts_NormalDesc,
                type = "select",
                dialogControl = "LSM30_Font",
                values = _G.AceGUIWidgetLSMlists.font,
                get = fontGet,
                set = fontSet,
                order = 11,
            },
            chat = {
                name = L.Fonts_Chat,
                desc = L.Fonts_ChatDesc,
                type = "select",
                dialogControl = "LSM30_Font",
                values = _G.AceGUIWidgetLSMlists.font,
                get = fontGet,
                set = fontSet,
                order = 12,
            },
            header = {
                name = L.Fonts_Header,
                desc = L.Fonts_HeaderDesc,
                type = "select",
                dialogControl = "LSM30_Font",
                values = _G.AceGUIWidgetLSMlists.font,
                get = fontGet,
                set = fontSet,
                order = 13,
            },
            headerScale = {
                name = _G.UI_SCALE,
                type = "header",
                order = 20,
            },
            isHighRes = {
                name = L.Appearance_HighRes,
                desc = L.Appearance_HighResDesc,
                type = "toggle",
                get = function() return SkinsDB.profile.isHighRes end,
                set = function(info, value)
                    SkinsDB.profile.isHighRes = value
                    RealUI.UpdateUIScale(SkinsDB.profile.customScale)
                end,
                order = 21,
            },
            isPixelScale = {
                name = L.Appearance_Pixel,
                desc = L.Appearance_PixelDesc,
                type = "toggle",
                get = function() return SkinsDB.profile.isPixelScale end,
                set = function(info, value)
                    SkinsDB.profile.isPixelScale = value
                    RealUI.UpdateUIScale()
                end,
                order = 22
            },
            customScale = {
                name = L.Appearance_UIScale,
                desc = L.Appearance_UIScaleDesc:format(minScale, maxScale),
                type = "input",
                disabled = function() return SkinsDB.profile.isPixelScale end,
                validate = function(info, value)
                    value = _G.tonumber(value)
                    if value then
                        if value >= minScale and value <= maxScale then
                            return true
                        else
                            return ("Value must be between %.2f and %.2f"):format(minScale, maxScale)
                        end
                    else
                        return "Value must be a number"
                    end
                end,
                get = function() return _G.tostring(SkinsDB.profile.customScale) end,
                set = function(info, value)
                    RealUI.UpdateUIScale(_G.tonumber(value))
                end,
                order = 23,
            },
            uiModScale = {
                name = L.Appearance_ModScale,
                desc = L.Appearance_ModScaleDesc:format(L.Infobar.."\nHUD Config"),
                type = "range",
                isPercent = true,
                min = 0.5, max = 2, step = 0.05,
                get = function(info) return SkinsDB.profile.uiModScale end,
                set = function(info, value)
                    SkinsDB.profile.uiModScale = value
                    RealUI.UpdateUIScale()
                end,
                order = 24,
            },
            classColors = classColors,
            addons = addons,
            profiles = _G.LibStub("AceDBOptions-3.0"):GetOptionsTable(SkinsDB),
        }
    }
end
do -- Tooltips
    debug("Adv Tooltips")
    order = order + 1

    local args
    local Tooltips = RealUI:GetModule("Tooltips", true)
    local function appGet(info)
        return Tooltips.db.global[info[#info]]
    end
    local function appSet(info, value)
        Tooltips.db.global[info[#info]] = value
    end

    if Tooltips then
        args = {
            note = {
                name = L.General_NoteReload,
                type = "description",
                order = -1,
            },
            showTitles = {
                name = L.Tooltips_ShowTitles,
                type = "toggle",
                get = appGet,
                set = appSet,
                order = 1,
            },
            showRealm = {
                name = L.Tooltips_ShowRealm,
                type = "toggle",
                get = appGet,
                set = appSet,
                order = 2,
            },
            showIDs = {
                name = L.Tooltips_ShowIDs,
                type = "toggle",
                get = appGet,
                set = appSet,
                order = 3,
            },
            showTransmog = {
                name = L.Tooltips_ShowTransmog,
                type = "toggle",
                get = appGet,
                set = appSet,
                order = 4,
            },
            multiTip = {
                name = L.Tooltips_MultiTip,
                desc = L.Tooltips_MultiTipDesc,
                type = "toggle",
                get = appGet,
                set = appSet,
                order = 5,
            },
            position = {
                name = L["General_Position"],
                type = "group",
                inline = true,
                order = 10,
                args = {
                    lock = {
                        name = L["General_Lock"],
                        desc = L["General_LockDesc"],
                        type = "toggle",
                        width = "full",
                        get = function(info) return FramePoint:IsModLocked(Tooltips) end,
                        set = function(info, value)
                            if value then
                                FramePoint:LockMod(Tooltips)
                            else
                                FramePoint:UnlockMod(Tooltips)
                            end
                        end,
                        order = 0,
                    },
                    point = {
                        name = L["General_AnchorPoint"],
                        type = "select",
                        values = RealUI.globals.anchorPoints,
                        get = function(info)
                            for k,v in next, RealUI.globals.anchorPoints do
                                if v == Tooltips.db.global.position.point then return k end
                            end
                        end,
                        set = function(info, value)
                            Tooltips.db.global.position.point = RealUI.globals.anchorPoints[value]
                            FramePoint:RestorePosition(Tooltips)
                        end,
                        order = 10,
                    },
                    x = {
                        name = L["General_XOffset"],
                        desc = L["General_XOffsetDesc"],
                        type = "input",
                        dialogControl = "NumberEditBox",
                        get = function(info)
                            return _G.tostring(Tooltips.db.global.position.x)
                        end,
                        set = function(info, value)
                            Tooltips.db.global.position.x = round(_G.tonumber(value), 1)
                            FramePoint:RestorePosition(Tooltips)
                        end,
                        order = 11,
                    },
                    y = {
                        name = L["General_YOffset"],
                        desc = L["General_YOffsetDesc"],
                        type = "input",
                        dialogControl = "NumberEditBox",
                        get = function(info) return _G.tostring(Tooltips.db.global.position.y) end,
                        set = function(info, value)
                            Tooltips.db.global.position.y = round(_G.tonumber(value), 1)
                            FramePoint:RestorePosition(Tooltips)
                        end,
                        order = 12,
                    },
                }
            }
        }
    end

    optArgs.tooltips = CreateAddonSection("Tooltips", args)
end
do -- UI Tweaks
    debug("Adv UITweaks")
    order = order + 1
    local altPowerBar do
        local MODNAME = "AltPowerBar"
        local AltPowerBar = RealUI:GetModule(MODNAME)
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
                            get = function(info) return tostring(AltPowerBar.db.profile.size.width) end,
                            set = function(info, value)
                                value = ValidateOffset(value)
                                AltPowerBar.db.profile.size.width = value
                                altPowerBar:UpdatePosition()
                            end,
                            order = 10,
                        },
                        height = {
                            name = "Height",
                            type = "input",
                            width = "half",
                            get = function(info) return tostring(AltPowerBar.db.profile.size.height) end,
                            set = function(info, value)
                                value = ValidateOffset(value)
                                AltPowerBar.db.profile.size.height = value
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
                                    get = function(info) return tostring(AltPowerBar.db.profile.position.x) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        AltPowerBar.db.profile.position.x = value
                                        altPowerBar:UpdatePosition()
                                    end,
                                    order = 10,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(AltPowerBar.db.profile.position.y) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        AltPowerBar.db.profile.position.y = value
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
                                            if v == AltPowerBar.db.profile.position.anchorto then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        AltPowerBar.db.profile.position.anchorto = RealUI.globals.anchorPoints[value]
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
                                            if v == AltPowerBar.db.profile.position.anchorfrom then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        AltPowerBar.db.profile.position.anchorfrom = RealUI.globals.anchorPoints[value]
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
                            get = function() return Chat.db.profile.modules.tabs.enabled end,
                            set = function(info, value)
                                Chat.db.profile.modules.tabs.enabled = value
                            end,
                            order = 10,
                        },
                        opacity = {
                            name = "Opacity",
                            desc = "Adjusts the opacity of the Chat Frame, and controls how fast the frame and tabs fade in/out.",
                            type = "toggle",
                            get = function() return Chat.db.profile.modules.opacity.enabled end,
                            set = function(info, value)
                                Chat.db.profile.modules.opacity.enabled = value
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
        local anchors = {
            "TOPLEFT",
            "TOPRIGHT",
            "BOTTOMLEFT",
            "BOTTOMRIGHT",
        }
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
                minDuration = {
                    name = "Min Duration",
                    desc = "The minimum number of seconds a cooldown's duration must be to display text.",
                    type = "range",
                    min = 0, max = 30, step = 0.1, bigStep = 1,
                    disabled = function(info) return not RealUI:GetModuleEnabled(MODNAME) end,
                    get = function(info) return CooldownCount.db.profile.minDuration end,
                    set = function(info, value)
                        CooldownCount.db.profile.minDuration = value
                    end,
                    order = 70,
                },
                expiringDuration = {
                    name = "Expiring Duration",
                    desc = "The minimum number of seconds a cooldown must be to display in the expiring format.",
                    type = "range",
                    min = 0, max = 30, step = 1,
                    disabled = function(info) return not RealUI:GetModuleEnabled(MODNAME) end,
                    get = function(info) return CooldownCount.db.profile.expiringDuration end,
                    set = function(info, value)
                        CooldownCount.db.profile.expiringDuration = value
                    end,
                    order = 80,
                },
                point = {
                    name = "Anchor",
                    type = "select",
                    values = anchors,
                    get = function(info)
                        for k,v in next, anchors do
                            if v == CooldownCount.db.profile.point then return k end
                        end
                    end,
                    set = function(info, value)
                        CooldownCount.db.profile.point = anchors[value]
                    end,
                    order = 90,
                },
            },
        }
    end
    local eventNotify do
        local MODNAME = "EventNotifier"
        local EventNotifier = RealUI:GetModule(MODNAME)
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
                            get = function() return EventNotifier.db.profile.checkEvents end,
                            set = function(info, value)
                                EventNotifier.db.profile.checkEvents = value
                            end,
                            order = 10,
                        },
                        checkGuildEvents = {
                            name = "Guild Events",
                            type = "toggle",
                            get = function() return EventNotifier.db.profile.checkGuildEvents end,
                            set = function(info, value)
                                EventNotifier.db.profile.checkGuildEvents = value
                            end,
                            order = 20,
                        },
                        checkMinimapRares = {
                            name = _G.MINIMAP_LABEL.." ".._G.ITEM_QUALITY3_DESC,
                            type = "toggle",
                            get = function() return EventNotifier.db.profile.checkMinimapRares end,
                            set = function(info, value)
                                EventNotifier.db.profile.checkMinimapRares = value
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
                                return GetEnabled(addonSlug, FrameMover.db.profile.addons[addonSlug])
                            end,
                            set = function(info, value)
                                if isAddonControl[addonSlug] then
                                    RealUI:ToggleAddonPositionControl(isAddonControl[addonSlug], value)
                                    if RealUI:DoesAddonMove(isAddonControl[addonSlug]) then
                                        FrameMover:MoveAddons()
                                    end
                                else
                                    FrameMover.db.profile.addons[addonSlug].move = value
                                    if FrameMover.db.profile.addons[addonSlug].move then
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
                    disabled = function() return not GetEnabled(addonSlug, FrameMover.db.profile.addons[addonSlug]) end,
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
                                get = function(info) return tostring(FrameMover.db.profile.addons[addonSlug].frames[i].x) end,
                                set = function(info, value)
                                    value = ValidateOffset(value)
                                    FrameMover.db.profile.addons[addonSlug].frames[i].x = value
                                    FrameMover:MoveAddons()
                                end,
                                order = 10,
                            },
                            yoffset = {
                                name = "Y Offset",
                                type = "input",
                                width = "half",
                                get = function(info) return tostring(FrameMover.db.profile.addons[addonSlug].frames[i].y) end,
                                set = function(info, value)
                                    value = ValidateOffset(value)
                                    FrameMover.db.profile.addons[addonSlug].frames[i].y = value
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
                                        if point == FrameMover.db.profile.addons[addonSlug].frames[i].rpoint then return idx end
                                    end
                                end,
                                set = function(info, value)
                                    FrameMover.db.profile.addons[addonSlug].frames[i].rpoint = RealUI.globals.anchorPoints[value]
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
                                        if point == FrameMover.db.profile.addons[addonSlug].frames[i].point then return idx end
                                    end
                                end,
                                set = function(info, value)
                                    FrameMover.db.profile.addons[addonSlug].frames[i].point = RealUI.globals.anchorPoints[value]
                                    FrameMover:MoveAddons()
                                end,
                                order = 40,
                            },
                            parent = {
                                name = "Parent",
                                desc = L["General_NoteParent"],
                                type = "input",
                                width = "double",
                                get = function(info) return FrameMover.db.profile.addons[addonSlug].frames[i].parent end,
                                set = function(info, value)
                                    if not _G[value] then value = "UIParent" end
                                    FrameMover.db.profile.addons[addonSlug].frames[i].parent = value
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
                        get = function(info) return FrameMover.db.profile.addons[addonSlug].healing end,
                        set = function(info, value)
                            FrameMover.db.profile.addons[addonSlug].healing = value
                            if FrameMover.db.profile.addons[addonSlug].move then
                                FrameMover:MoveAddons()
                            end
                        end,
                        order = 30,
                    }

                    -- Create options table for Healing Frames
                    local normalHealingFrameOpts = {
                        name = "Healing Layout Frames",
                        type = "group",
                        disabled = function() return not ( GetEnabled(addonSlug, FrameMover.db.profile.addons[addonSlug]) and FrameMover.db.profile.addons[addonSlug].healing ) end,
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
                                    get = function(info) return tostring(FrameMover.db.profile.addons[addonSlug].frameshealing[i].x) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        FrameMover.db.profile.addons[addonSlug].frameshealing[i].x = value
                                        FrameMover:MoveAddons()
                                    end,
                                    order = 10,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(FrameMover.db.profile.addons[addonSlug].frameshealing[i].y) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        FrameMover.db.profile.addons[addonSlug].frameshealing[i].y = value
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
                                            if point == FrameMover.db.profile.addons[addonSlug].frameshealing[i].rpoint then return idx end
                                        end
                                    end,
                                    set = function(info, value)
                                        FrameMover.db.profile.addons[addonSlug].frameshealing[i].rpoint = RealUI.globals.anchorPoints[value]
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
                                            if point == FrameMover.db.profile.addons[addonSlug].frameshealing[i].point then return idx end
                                        end
                                    end,
                                    set = function(info, value)
                                        FrameMover.db.profile.addons[addonSlug].frameshealing[i].point = RealUI.globals.anchorPoints[value]
                                        FrameMover:MoveAddons()
                                    end,
                                    order = 40,
                                },
                                parent = {
                                    name = "Parent",
                                    desc = L["General_NoteParent"],
                                    type = "input",
                                    width = "double",
                                    get = function(info) return FrameMover.db.profile.addons[addonSlug].frameshealing[i].parent end,
                                    set = function(info, value)
                                        if not _G[value] then value = "UIParent" end
                                        FrameMover.db.profile.addons[addonSlug].frameshealing[i].parent = value
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
                            get = function(info) return FrameMover.db.profile.uiframes[uiSlug].move end,
                            set = function(info, value)
                                FrameMover.db.profile.uiframes[uiSlug].move = value
                                if FrameMover.db.profile.uiframes[uiSlug].move and ui.frames then MoveFrameGroup(ui.frames, FrameMover.db.profile.uiframes[uiSlug].frames) end
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
                        disabled = function() if FrameMover.db.profile.uiframes[uiSlug].move then return false else return true end end,
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
                                    get = function(info) return tostring(FrameMover.db.profile.uiframes[uiSlug].frames[i].x) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        FrameMover.db.profile.uiframes[uiSlug].frames[i].x = value
                                        MoveFrameGroup(ui.frames, FrameMover.db.profile.uiframes[uiSlug].frames)
                                    end,
                                },
                                yoffset = {
                                    type = "input",
                                    name = "Y Offset",
                                    width = "half",
                                    order = 20,
                                    get = function(info) return tostring(FrameMover.db.profile.uiframes[uiSlug].frames[i].y) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        FrameMover.db.profile.uiframes[uiSlug].frames[i].y = value
                                        MoveFrameGroup(ui.frames, FrameMover.db.profile.uiframes[uiSlug].frames)
                                    end,
                                },
                                anchorto = {
                                    type = "select",
                                    name = "Anchor To",
                                    get = function(info)
                                        for idx, point in next, RealUI.globals.anchorPoints do
                                            if point == FrameMover.db.profile.uiframes[uiSlug].frames[i].rpoint then return idx end
                                        end
                                    end,
                                    set = function(info, value)
                                        FrameMover.db.profile.uiframes[uiSlug].frames[i].rpoint = RealUI.globals.anchorPoints[value]
                                        MoveFrameGroup(ui.frames, FrameMover.db.profile.uiframes[uiSlug].frames)
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
                                            if point == FrameMover.db.profile.uiframes[uiSlug].frames[i].point then return idx end
                                        end
                                    end,
                                    set = function(info, value)
                                        FrameMover.db.profile.uiframes[uiSlug].frames[i].point = RealUI.globals.anchorPoints[value]
                                        MoveFrameGroup(ui.frames, FrameMover.db.profile.uiframes[uiSlug].frames)
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
                -- Create base options for Hide
                hideOpts.args.hideframes.args[hideSlug] = {
                    type = "toggle",
                    name = hide.name,
                    get = function(info) return FrameMover.db.profile.hide [hideSlug].hide end,
                    set = function(info, value)
                        FrameMover.db.profile.hide [hideSlug].hide = value
                        if FrameMover.db.profile.hide [hideSlug].hide then
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
                            get = function() return Loot.db.profile.loot.enabled end,
                            set = function(info, value)
                                Loot.db.profile.loot.enabled = value
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
                                    get = function() return Loot.db.profile.loot.cursor end,
                                    set = function(info, value)
                                        Loot.db.profile.loot.cursor = value
                                        Loot:UpdateLootPosition()
                                    end,
                                    order = 10,
                                },
                                position = {
                                    name = "Custom Position",
                                    type = "group",
                                    inline = true,
                                    disabled = function() return Loot.db.profile.loot.cursor end,
                                    order = 20,
                                    args = {
                                        x = {
                                            name = "Padding",
                                            type = "input",
                                            width = "half",
                                            get = function(info) return tostring(Loot.db.profile.loot.static.x) end,
                                            set = function(info, value)
                                                value = ValidateOffset(value)
                                                Loot.db.profile.loot.static.x = value
                                                Loot:UpdateLootPosition()
                                            end,
                                            order = 10,
                                        },
                                        y = {
                                            name = "Y Offset",
                                            type = "input",
                                            width = "half",
                                            get = function(info) return tostring(Loot.db.profile.loot.static.y) end,
                                            set = function(info, value)
                                                value = ValidateOffset(value)
                                                Loot.db.profile.loot.static.y = value
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
                                                    if v == Loot.db.profile.loot.static.anchor then return k end
                                                end
                                            end,
                                            set = function(info, value)
                                                Loot.db.profile.loot.static.anchor = RealUI.globals.anchorPoints[value]
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
                            get = function() return Loot.db.profile.roll.enabled end,
                            set = function(info, value)
                                Loot.db.profile.roll.enabled = value
                                RealUI:ReloadUIDialog()
                            end,
                            order = 10,
                        },
                        vertical = {
                            name = "Y Offset",
                            type = "input",
                            width = "half",
                            get = function(info) return tostring(Loot.db.profile.roll.vertical) end,
                            set = function(info, value)
                                value = ValidateOffset(value)
                                Loot.db.profile.roll.vertical = value
                                Loot:GroupLootPosition()
                            end,
                            order = 20,
                        },
                        horizontal = {
                            name = "X Offset",
                            type = "input",
                            width = "half",
                            get = function(info) return tostring(Loot.db.profile.roll.horizontal) end,
                            set = function(info, value)
                                value = ValidateOffset(value)
                                Loot.db.profile.roll.horizontal = value
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
                            get = function(info) return MinimapAdv.db.profile.information.coordDelayHide end,
                            set = function(info, value)
                                MinimapAdv.db.profile.information.coordDelayHide = value
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
                            get = function(info) return MinimapAdv.db.profile.information.minimapbuttons end,
                            set = function(info, value)
                                MinimapAdv.db.profile.information.minimapbuttons = value
                                RealUI:ReloadUIDialog()
                            end,
                            order = 20,
                        },
                        location = {
                            name = "Location Name",
                            desc = "Show the name of your current location underneath the Minimap.",
                            type = "toggle",
                            get = function(info) return MinimapAdv.db.profile.information.location end,
                            set = function(info, value)
                                MinimapAdv.db.profile.information.location = value
                                MinimapAdv:UpdateInfoPosition()
                            end,
                            order = 30,
                        },
                        gap = {
                            name = "Gap",
                            desc = "Amount of space between each information element.",
                            type = "range",
                            min = 1, max = 28, step = 1,
                            get = function(info) return MinimapAdv.db.profile.information.gap end,
                            set = function(info, value)
                                MinimapAdv.db.profile.information.gap = value
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
                                    get = function(info) return tostring(MinimapAdv.db.profile.information.position.x) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        MinimapAdv.db.profile.information.position.x = value
                                        MinimapAdv:UpdateInfoPosition()
                                    end,
                                    order = 10,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(MinimapAdv.db.profile.information.position.y) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        MinimapAdv.db.profile.information.position.y = value
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
                            get = function(info) return MinimapAdv.db.profile.hidden.enabled end,
                            set = function(info, value) MinimapAdv.db.profile.hidden.enabled = value end,
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
                                return not(MinimapAdv.db.profile.hidden.enabled and RealUI:GetModuleEnabled(MODNAME))
                            end,
                            order = 20,
                            args = {
                                arena = {
                                    name = "Arenas",
                                    type = "toggle",
                                    get = function(info) return MinimapAdv.db.profile.hidden.zones.arena end,
                                    set = function(info, value) MinimapAdv.db.profile.hidden.zones.arena = value end,
                                    order = 10,
                                },
                                pvp = {
                                    name = _G.BATTLEGROUNDS,
                                    type = "toggle",
                                    get = function(info) return MinimapAdv.db.profile.hidden.zones.pvp end,
                                    set = function(info, value) MinimapAdv.db.profile.hidden.zones.pvp = value end,
                                    order = 200,
                                },
                                party = {
                                    name = _G.DUNGEONS,
                                    type = "toggle",
                                    get = function(info) return MinimapAdv.db.profile.hidden.zones.party end,
                                    set = function(info, value) MinimapAdv.db.profile.hidden.zones.party = value end,
                                    order = 30,
                                },
                                raid = {
                                    name = _G.RAIDS,
                                    type = "toggle",
                                    get = function(info) return MinimapAdv.db.profile.hidden.zones.raid end,
                                    set = function(info, value) MinimapAdv.db.profile.hidden.zones.raid = value end,
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
                            get = function(info) return MinimapAdv.db.profile.position.size end,
                            set = function(info, value)
                                MinimapAdv.db.profile.position.size = value
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
                                    get = function(info) return MinimapAdv.db.profile.position.scale end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.position.scale = value
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 10,
                                },
                                xoffset = {
                                    name = "X Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(MinimapAdv.db.profile.position.x) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        MinimapAdv.db.profile.position.x = value
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 20,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(MinimapAdv.db.profile.position.y) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        MinimapAdv.db.profile.position.y = value
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
                                            if v == MinimapAdv.db.profile.position.anchorto then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        --print("Set Anchor", info.option, value)
                                        MinimapAdv.db.profile.position.anchorto = minimapAnchors[value]
                                        MinimapAdv.db.profile.position.x = minimapOffsets[value].x
                                        MinimapAdv.db.profile.position.y = minimapOffsets[value].y
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
                                    get = function(info) return MinimapAdv.db.profile.expand.appearance.scale end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.expand.appearance.scale = value
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 10,
                                },
                                opacity = {
                                    name = "Opacity",
                                    type = "range",
                                    isPercent = true,
                                    min = 0, max = 1, step = 0.05,
                                    get = function(info) return MinimapAdv.db.profile.expand.appearance.opacity end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.expand.appearance.opacity = value
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
                                    get = function(info) return tostring(MinimapAdv.db.profile.expand.position.x) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        MinimapAdv.db.profile.expand.position.x = value
                                        MinimapAdv:UpdateMinimapPosition()
                                    end,
                                    order = 10,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return tostring(MinimapAdv.db.profile.expand.position.y) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        MinimapAdv.db.profile.expand.position.y = value
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
                                            if v == MinimapAdv.db.profile.expand.position.anchorto then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.expand.position.anchorto = minimapAnchors[value]
                                        MinimapAdv.db.profile.expand.position.x = minimapOffsets[value].x
                                        MinimapAdv.db.profile.expand.position.y = minimapOffsets[value].y
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
                                    get = function(info) return MinimapAdv.db.profile.expand.extras.gatherertoggle end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.expand.extras.gatherertoggle = value
                                        MinimapAdv:ToggleGatherer()
                                    end,
                                    order = 10,
                                },
                                clickthrough = {
                                    name = "Clickthrough",
                                    desc = "Make the Minimap clickthrough (won't respond to mouse clicks) while in Farm Mode.",
                                    type = "toggle",
                                    get = function(info) return MinimapAdv.db.profile.expand.extras.clickthrough end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.expand.extras.clickthrough = value
                                        MinimapAdv:UpdateClickthrough()
                                    end,
                                    order = 20,
                                },
                                hidepoi = {
                                    name = "Hide POI icons",
                                    type = "toggle",
                                    get = function(info) return MinimapAdv.db.profile.expand.extras.hidepoi end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.expand.extras.hidepoi = value
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
                            get = function(info) return MinimapAdv.db.profile.poi.enabled end,
                            set = function(info, value)
                                MinimapAdv.db.profile.poi.enabled = value
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
                                return not(MinimapAdv.db.profile.poi.enabled and RealUI:GetModuleEnabled(MODNAME))
                            end,
                            order = 20,
                            args = {
                                watchedOnly = {
                                    name = "Watched Only",
                                    desc = "Only show POI icons for watched quests.",
                                    type = "toggle",
                                    get = function(info) return MinimapAdv.db.profile.poi.watchedOnly end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.poi.watchedOnly = value
                                        MinimapAdv:POIUpdate()
                                    end,
                                    order = 10,
                                },
                                fadeEdge = {
                                    name = "Fade at Edge",
                                    desc = "Fade icons when they go off the edge of the minimap.",
                                    type = "toggle",
                                    get = function(info) return MinimapAdv.db.profile.poi.fadeEdge end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.poi.fadeEdge = value
                                        MinimapAdv:UpdatePOIVisibility()
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
                                return not(MinimapAdv.db.profile.poi.enabled and RealUI:GetModuleEnabled(MODNAME))
                            end,
                            order = 30,
                            args = {
                                scale = {
                                    name = "Scale",
                                    type = "range",
                                    isPercent = true,
                                    min = 0.1, max = 1.5, step = 0.05,
                                    get = function(info) return MinimapAdv.db.profile.poi.icons.scale end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.poi.icons.scale = value
                                        MinimapAdv:UpdatePOIVisibility()
                                    end,
                                    order = 10,
                                },
                                opacity = {
                                    name = "Opacity",
                                    type = "range",
                                    isPercent = true,
                                    min = 0.5, max = 1, step = 0.01,
                                    get = function(info) return MinimapAdv.db.profile.poi.icons.opacity end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.poi.icons.opacity = value
                                        MinimapAdv:UpdatePOIVisibility()
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
                            get = function(info) return _G.tostring(MirrorBar.db.profile.size.width) end,
                            set = function(info, value)
                                value = ValidateOffset(value)
                                MirrorBar.db.profile.size.width = value
                                MirrorBar:UpdatePosition()
                            end,
                            order = 10,
                        },
                        height = {
                            name = "Height",
                            type = "input",
                            width = "half",
                            get = function(info) return _G.tostring(MirrorBar.db.profile.size.height) end,
                            set = function(info, value)
                                value = ValidateOffset(value)
                                MirrorBar.db.profile.size.height = value
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
                                    get = function(info) return _G.tostring(MirrorBar.db.profile.position.x) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        MirrorBar.db.profile.position.x = value
                                        MirrorBar:UpdatePosition()
                                    end,
                                    order = 10,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(MirrorBar.db.profile.position.y) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        MirrorBar.db.profile.position.y = value
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
                                            if v == MirrorBar.db.profile.position.anchorto then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        MirrorBar.db.profile.position.anchorto = RealUI.globals.anchorPoints[value]
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
                                            if v == MirrorBar.db.profile.position.anchorfrom then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        MirrorBar.db.profile.position.anchorfrom = RealUI.globals.anchorPoints[value]
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
        local function collapseGet(info)
            return ObjectivesAdv.db.profile.hidden.collapse[info[#info]]
        end
        local function collapseSet(info, value)
            ObjectivesAdv.db.profile.hidden.collapse[info[#info]] = value
            ObjectivesAdv:UpdateState()
        end

        local function hideGet(info)
            return ObjectivesAdv.db.profile.hidden.hide[info[#info]]
        end
        local function hideSet(info, value)
            ObjectivesAdv.db.profile.hidden.hide[info[#info]] = value
            ObjectivesAdv:UpdateState()
        end

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
                            get = function(info) return ObjectivesAdv.db.profile.position.enabled end,
                            set = function(info, value)
                                ObjectivesAdv.db.profile.position.enabled = value
                                ObjectivesAdv:RefreshMod()
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
                            disabled = function() return not(ObjectivesAdv.db.profile.position.enabled) or not(RealUI:GetModuleEnabled(MODNAME)) end,
                            order = 40,
                            args = {
                                xoffset = {
                                    name = "X Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(ObjectivesAdv.db.profile.position.x) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        ObjectivesAdv.db.profile.position.x = value
                                        ObjectivesAdv:RefreshMod()
                                    end,
                                    order = 10,
                                },
                                yoffset = {
                                    name = "Y Offset",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(ObjectivesAdv.db.profile.position.y) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        ObjectivesAdv.db.profile.position.y = value
                                        ObjectivesAdv:RefreshMod()
                                    end,
                                    order = 20,
                                },
                                negheightoffset = {
                                    name = "Height Offset",
                                    desc = "How much shorter than screen height to make the Quest Watch Frame.",
                                    type = "input",
                                    width = "half",
                                    get = function(info) return _G.tostring(ObjectivesAdv.db.profile.position.negheightofs) end,
                                    set = function(info, value)
                                        value = ValidateOffset(value)
                                        ObjectivesAdv.db.profile.position.negheightofs = value
                                        ObjectivesAdv:RefreshMod()
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
                            disabled = function() return not(ObjectivesAdv.db.profile.position.enabled) or not(RealUI:GetModuleEnabled(MODNAME)) end,
                            order = 50,
                            args = {
                                anchorto = {
                                    name = "Anchor To",
                                    type = "select",
                                    style = "dropdown",
                                    values = RealUI.globals.anchorPoints,
                                    get = function(info)
                                        for k,v in next, RealUI.globals.anchorPoints do
                                            if v == ObjectivesAdv.db.profile.position.anchorto then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        ObjectivesAdv.db.profile.position.anchorto = RealUI.globals.anchorPoints[value]
                                        ObjectivesAdv:RefreshMod()
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
                                            if v == ObjectivesAdv.db.profile.position.anchorfrom then return k end
                                        end
                                    end,
                                    set = function(info, value)
                                        ObjectivesAdv.db.profile.position.anchorfrom = RealUI.globals.anchorPoints[value]
                                        ObjectivesAdv:RefreshMod()
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
                            get = function(info) return ObjectivesAdv.db.profile.hidden.enabled end,
                            set = function(info, value)
                                ObjectivesAdv.db.profile.hidden.enabled = value
                                ObjectivesAdv:UpdateState()
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
                            disabled = function() return not(RealUI:GetModuleEnabled(MODNAME) and ObjectivesAdv.db.profile.hidden.enabled) end,
                            order = 30,
                            args = {
                                arena = {
                                    name = _G.ARENA_BATTLES,
                                    type = "toggle",
                                    get = collapseGet,
                                    set = collapseSet,
                                    order = 10,
                                },
                                pvp = {
                                    name = _G.BATTLEGROUNDS,
                                    type = "toggle",
                                    get = collapseGet,
                                    set = collapseSet,
                                    order = 20,
                                },
                                party = {
                                    name = _G.DUNGEONS,
                                    type = "toggle",
                                    get = collapseGet,
                                    set = collapseSet,
                                    order = 30,
                                },
                                scenario = {
                                    name = _G.SCENARIOS,
                                    type = "toggle",
                                    get = collapseGet,
                                    set = collapseSet,
                                    order = 40,
                                },
                                raid = {
                                    name = _G.RAIDS,
                                    type = "toggle",
                                    get = collapseGet,
                                    set = collapseSet,
                                    order = 50,
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
                            disabled = function() return not(ObjectivesAdv.db.profile.hidden.enabled) or not(RealUI:GetModuleEnabled(MODNAME)) end,
                            order = 40,
                            args = {
                                arena = {
                                    name = _G.ARENA_BATTLES,
                                    type = "toggle",
                                    get = hideGet,
                                    set = hideSet,
                                    order = 10,
                                },
                                pvp = {
                                    name = _G.BATTLEGROUNDS,
                                    type = "toggle",
                                    get = hideGet,
                                    set = hideSet,
                                    order = 20,
                                },
                                party = {
                                    name = _G.DUNGEONS,
                                    type = "toggle",
                                    get = hideGet,
                                    set = hideSet,
                                    order = 30,
                                },
                                scenario = {
                                    name = _G.SCENARIOS,
                                    type = "toggle",
                                    get = hideGet,
                                    set = hideSet,
                                    order = 40,
                                },
                                raid = {
                                    name = _G.RAIDS,
                                    type = "toggle",
                                    get = hideGet,
                                    set = hideSet,
                                    order = 50,
                                },
                            },
                        },
                    },
                },
            },
        }
        CombatFader:AddFadeConfig(MODNAME, objectives, 50)
    end

    optArgs.uiTweaks = {
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
            altPowerBar = altPowerBar,
            chat = chat,
            cooldown = cooldown,
            eventNotify = eventNotify,
            frameMover = frameMover,
            loot = loot,
            minimap = minimap,
            mirrorBar = mirrorBar,
            objectives = objectives,
        }
    }

    local InterfaceTweaks = RealUI:GetModule("InterfaceTweaks")
    local tweaks = InterfaceTweaks:GetTweaks()
    for tag, info in next, tweaks do
        optArgs.uiTweaks.args[tag] = {
            name = L[info.name],
            desc = L[info.name.."Desc"],
            type = "toggle",
            get = function() return InterfaceTweaks.db.global[tag] end,
            set = function(_, value)
                InterfaceTweaks.db.global[tag] = value
                if info.setEnabled then
                    info.setEnabled(value)
                end
            end
        }
    end
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
