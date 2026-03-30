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
-- local round = RealUI.Round

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
        profiles = private.unifiedProfilePage or _G.LibStub("AceDBOptions-3.0"):GetOptionsTable(RealUI.db),
    }
}

local optArgs = options.RealUI.args
-- Only enhance with LibDualSpec if we fell back to the old table
if not private.unifiedProfilePage then
    _G.LibStub("LibDualSpec-1.0"):EnhanceOptions(optArgs.profiles, RealUI.db)
end

-- Profile Unification Evaluation comment block removed — superseded by Unified Profile Page (UPP).
-- The UPP (private.unifiedProfilePage) now provides all profile scope descriptions and controls.



local nameFormat = _G.ENABLE .. " %s"
local function CreateAddonSection(name, args)
    debug("CreateAddonSection", name, args)

    local hide = false

    if not args then
        local addonName = "RealUI_" .. name
        local _, _, _, loadable, reason = _G.C_AddOns.GetAddOnInfo(addonName)
        if loadable then
            args = {
                enable = {
                    name = nameFormat:format(L[name]),
                    type = "execute",
                    func = function(info, value)
                        _G.C_AddOns.EnableAddOn(addonName)
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
                    desc = L["Infobar_ShowStatusBarDesc"]
                        .. "\n\n|cff888888Disabled when the Progress block is not enabled.|r",
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
                HideStatusBarMaxLevel = {
                    name = L["Infobar_HideStatusBarMaxLevel"],
                    desc = L["Infobar_HideStatusBarMaxLevelDesc"]
                        .. "\n\n|cff888888Disabled when the Progress block is not enabled.|r",
                    type = "toggle",
                    disabled = function() return not Infobar.db.profile.blocks.realui.progress.enabled end,
                    get = function() return Infobar.db.profile.HideStatusBarMaxLevel end,
                    set = function(info, value)
                        Infobar.db.profile.HideStatusBarMaxLevel = value
                        Infobar:SettingsUpdate(info[#info], progress)
                    end,
                    order = 42,
                },
                gap3 = {
                    name = " ",
                    type = "description",
                    order = 43,
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
                    desc = "|cff888888Disabled when this block is not enabled.|r",
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
                    desc = "|cff888888Disabled when this block is not enabled.|r",
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

        -- Hearthstone Block Settings
        infobar.args.hearthstoneSettings = {
            name = "Hearthstone Settings",
            type = "group",
            inline = true,
            order = 70,
            args = {
                header = {
                    name = "Hearthstone",
                    type = "header",
                    order = 1,
                },
                primaryHS = {
                    name = "Primary Hearthstone",
                    desc = "Select which hearthstone to use on left-click",
                    type = "select",
                    values = function()
                        return {
                            -- Standard Hearthstones
                            [6948] = "Hearthstone",
                            [110560] = "Garrison Hearthstone",
                            [140192] = "Dalaran Hearthstone",
                            [141605] = "Flight Master's Whistle",

                            -- Class/Racial Teleports
                            [556] = "Astral Recall (Shaman)",

                            -- Alternate Hearthstones
                            [54452] = "Ethereal Portal",
                            [64488] = "The Innkeeper's Daughter",
                            [93672] = "Dark Portal",
                            [142542] = "Tome of Town Portal",
                            [162973] = "Greatfather Winter's Hearthstone",
                            [163045] = "Headless Horseman's Hearthstone",
                            [165669] = "Lunar Elder's Hearthstone",
                            [165670] = "Peddlefeet's Lovely Hearthstone",
                            [165802] = "Noble Gardener's Hearthstone",
                            [166746] = "Fire Eater's Hearthstone",
                            [166747] = "Brewfest Reveler's Hearthstone",
                            [168907] = "Holographic Digitalization Hearthstone",
                            [172179] = "Eternal Traveler's Hearthstone",
                            [180817] = "Cypher of Relocation",
                            [246565] = "Cosmic Hearthstone",

                            -- Covenant Hearthstones
                            [180290] = "Night Fae Hearthstone",
                            [182773] = "Necrolord Hearthstone",
                            [183716] = "Venthyr Sinstone",
                            [184353] = "Kyrian Hearthstone",

                            -- Shadowlands+
                            [188952] = "Dominated Hearthstone",
                            [190196] = "Enlightened Hearthstone",
                            [190237] = "Broker Translocation Matrix",
                            [193588] = "Timewalker's Hearthstone",

                            -- Dragonflight
                            [200630] = "Ohn'ir Windsage's Hearthstone",
                            [206195] = "Path of the Naaru",
                            [208704] = "Deepdweller's Earthen Hearthstone",
                            [209035] = "Hearthstone of the Flame",
                            [212337] = "Stone of the Hearth",

                            -- The War Within
                            [228940] = "Notorious Thread's Hearthstone",
                        }
                    end,
                    get = function()
                        if not RealUI.db.profile.infobar then
                            RealUI.db.profile.infobar = {}
                        end
                        if not RealUI.db.profile.infobar.hearthstone then
                            RealUI.db.profile.infobar.hearthstone = {
                                primary = 6948,
                                secondary = 140192,
                            }
                        end
                        return RealUI.db.profile.infobar.hearthstone.primary or 6948
                    end,
                    set = function(info, value)
                        if not RealUI.db.profile.infobar then
                            RealUI.db.profile.infobar = {}
                        end
                        if not RealUI.db.profile.infobar.hearthstone then
                            RealUI.db.profile.infobar.hearthstone = {}
                        end
                        RealUI.db.profile.infobar.hearthstone.primary = value
                    end,
                    order = 10,
                },
                secondaryHS = {
                    name = "Secondary Hearthstone",
                    desc = "Select which hearthstone to use on right-click",
                    type = "select",
                    values = function()
                        return {
                            -- Standard Hearthstones
                            [6948] = "Hearthstone",
                            [110560] = "Garrison Hearthstone",
                            [140192] = "Dalaran Hearthstone",
                            [141605] = "Flight Master's Whistle",

                            -- Class/Racial Teleports
                            [556] = "Astral Recall (Shaman)",

                            -- Alternate Hearthstones
                            [54452] = "Ethereal Portal",
                            [64488] = "The Innkeeper's Daughter",
                            [93672] = "Dark Portal",
                            [142542] = "Tome of Town Portal",
                            [162973] = "Greatfather Winter's Hearthstone",
                            [163045] = "Headless Horseman's Hearthstone",
                            [165669] = "Lunar Elder's Hearthstone",
                            [165670] = "Peddlefeet's Lovely Hearthstone",
                            [165802] = "Noble Gardener's Hearthstone",
                            [166746] = "Fire Eater's Hearthstone",
                            [166747] = "Brewfest Reveler's Hearthstone",
                            [168907] = "Holographic Digitalization Hearthstone",
                            [172179] = "Eternal Traveler's Hearthstone",
                            [180817] = "Cypher of Relocation",
                            [246565] = "Cosmic Hearthstone",

                            -- Covenant Hearthstones
                            [180290] = "Night Fae Hearthstone",
                            [182773] = "Necrolord Hearthstone",
                            [183716] = "Venthyr Sinstone",
                            [184353] = "Kyrian Hearthstone",

                            -- Shadowlands+
                            [188952] = "Dominated Hearthstone",
                            [190196] = "Enlightened Hearthstone",
                            [190237] = "Broker Translocation Matrix",
                            [193588] = "Timewalker's Hearthstone",

                            -- Dragonflight
                            [200630] = "Ohn'ir Windsage's Hearthstone",
                            [206195] = "Path of the Naaru",
                            [208704] = "Deepdweller's Earthen Hearthstone",
                            [209035] = "Hearthstone of the Flame",
                            [212337] = "Stone of the Hearth",

                            -- The War Within
                            [228940] = "Notorious Thread's Hearthstone",
                        }
                    end,
                    get = function()
                        if not RealUI.db.profile.infobar then
                            RealUI.db.profile.infobar = {}
                        end
                        if not RealUI.db.profile.infobar.hearthstone then
                            RealUI.db.profile.infobar.hearthstone = {
                                primary = 6948,
                                secondary = 140192,
                            }
                        end
                        return RealUI.db.profile.infobar.hearthstone.secondary or 140192
                    end,
                    set = function(info, value)
                        if not RealUI.db.profile.infobar then
                            RealUI.db.profile.infobar = {}
                        end
                        if not RealUI.db.profile.infobar.hearthstone then
                            RealUI.db.profile.infobar.hearthstone = {}
                        end
                        RealUI.db.profile.infobar.hearthstone.secondary = value
                    end,
                    order = 20,
                },
            }
        }

        -- Durability Block Settings
        infobar.args.durabilitySettings = {
            name = "Durability Settings",
            type = "group",
            inline = true,
            order = 80,
            args = {
                header = {
                    name = "Repair Mount",
                    type = "header",
                    order = 1,
                },
                repairMount = {
                    name = "Repair Mount",
                    desc = "Select which repair mount to summon on right-click of the Durability block",
                    type = "select",
                    values = function()
                        local mounts = {}
                        local repairMountIDs = {280, 284, 460, 2237, 1039}
                        for _, mountID in ipairs(repairMountIDs) do
                            if _G.C_MountJournal and _G.C_MountJournal.GetMountInfoByID then
                                local name, _, _, _, isUsable = _G.C_MountJournal.GetMountInfoByID(mountID)
                                if name and isUsable then
                                    mounts[mountID] = name
                                end
                            end
                        end
                        if next(mounts) == nil then
                            mounts[280] = "Traveler's Tundra Mammoth (Horde)"
                            mounts[284] = "Traveler's Tundra Mammoth (Alliance)"
                        end
                        return mounts
                    end,
                    get = function()
                        if not RealUI.db.profile.infobar then
                            RealUI.db.profile.infobar = {}
                        end
                        if not RealUI.db.profile.infobar.repairMount then
                            local faction = _G.UnitFactionGroup("player")
                            RealUI.db.profile.infobar.repairMount = (faction == "Alliance") and 284 or 280
                        end
                        return RealUI.db.profile.infobar.repairMount
                    end,
                    set = function(info, value)
                        if not RealUI.db.profile.infobar then
                            RealUI.db.profile.infobar = {}
                        end
                        RealUI.db.profile.infobar.repairMount = value
                    end,
                    order = 10,
                },
            }
        }
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
                    desc = "|cff888888Disabled when the Screen Saver module is not enabled.|r",
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
            overview = {
                name = "|cffffcc00Core Modules|r\n\n"
                    .. "|cff88ccffInfobar|r: The information and button bar at the top or bottom of the screen. Configure block visibility, labels, icons, background opacity, and per-block settings.\n\n"
                    .. "|cff88ccffScreen Saver|r: Dims the screen when you go AFK, with an optional combat warning sound.\n\n"
                    .. "|cffffcc00Configuration Layout|r\n\n"
                    .. "|cff88ccffAdvanced Options|r (this window): Detailed configuration for all RealUI modules \226\128\148 Core, Skins, Tooltips, Inventory, CombatText, UI Tweaks, and Systems.\n\n"
                    .. "|cff88ccffHuD Config|r (the slide-down bar at the top of the screen): HuD-related settings including UnitFrames, CastBars, and ClassResource.",
                type = "description",
                fontSize = "medium",
                order = 0,
            },
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
            blizzardFCT = {
                name = "Blizzard Floating Combat Text",
                type = "group",
                inline = true,
                order = 30,
                args = {
                    desc = {
                        name = "Control Blizzard's built-in floating combat text. Disable these to only see RealUI's combat text.",
                        type = "description",
                        order = 0,
                    },
                    enableFloatingCombatText = {
                        name = "Incoming Combat Text",
                        desc = "Show Blizzard's floating combat text above your character (damage taken, heals received).",
                        type = "toggle",
                        get = function() return CombatText.db.global.blizzardFCT.enableFloatingCombatText end,
                        set = function(_, value)
                            CombatText.db.global.blizzardFCT.enableFloatingCombatText = value
                            _G.SetCVar("enableFloatingCombatText", value and "1" or "0")
                        end,
                        order = 1,
                    },
                    floatingCombatTextCombatDamage = {
                        name = "Outgoing Damage Numbers",
                        desc = "Show Blizzard's damage numbers above your character.",
                        type = "toggle",
                        get = function() return CombatText.db.global.blizzardFCT.floatingCombatTextCombatDamage end,
                        set = function(_, value)
                            CombatText.db.global.blizzardFCT.floatingCombatTextCombatDamage = value
                            _G.SetCVar("floatingCombatTextCombatDamage", value and "1" or "0")
                        end,
                        order = 2,
                    },
                    floatingCombatTextCombatHealing = {
                        name = "Outgoing Healing Numbers",
                        desc = "Show Blizzard's healing numbers above your character.",
                        type = "toggle",
                        get = function() return CombatText.db.global.blizzardFCT.floatingCombatTextCombatHealing end,
                        set = function(_, value)
                            CombatText.db.global.blizzardFCT.floatingCombatTextCombatHealing = value
                            _G.SetCVar("floatingCombatTextCombatHealing", value and "1" or "0")
                        end,
                        order = 3,
                    },
                    nameplateShowDamage = {
                        name = "Nameplate Damage Numbers",
                        desc = "Show damage numbers on enemy nameplates. This is the large number that appears over mobs.",
                        type = "toggle",
                        get = function() return CombatText.db.global.blizzardFCT.nameplateShowDamage end,
                        set = function(_, value)
                            CombatText.db.global.blizzardFCT.nameplateShowDamage = value
                            _G.SetCVar("nameplateShowDamage", value and "1" or "0")
                        end,
                        order = 4,
                    },
                },
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
            desc = "|cff888888Disabled when this filter is not enabled.|r",
            type = "input",
            disabled = function()
                return not filter:IsEnabled()
            end,
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
            desc = "|cff888888Disabled when this filter is not enabled.|r",
            disabled = function()
                --print("Up:disabled", tag, filter:IsEnabled())
                return not filter:IsEnabled()
            end,
            width = 0.8,
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
            desc = "|cff888888Disabled when this filter is not enabled.|r",
            disabled = function()
                return not filter:IsEnabled()
            end,
            width = 0.8,
            func = function()
                filter:SetIndex(filter:GetIndex() + 1)
            end,
            order = function()
                return (filter:GetIndex() * 10) + 2
            end,
        }

        if filter.isCustom then
            args.filters.args[tag.."Delete"] = {
                name = _G.DELETE,
                type = "execute",
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
        else
            args.filters.args[tag.."Disable"] = {
                name = _G.DISABLE,
                type = "execute",
                hidden = function()
                    return not filter:IsEnabled()
                end,
                width = "half",
                func = function()
                    filter:SetEnabled(false)
                    ACR:NotifyChange("RealUI")
                    Inventory.Update()
                end,
                order = function()
                    return (filter:GetIndex() * 10) + 3
                end,
            }
            args.filters.args[tag.."Enable"] = {
                name = _G.ENABLE,
                type = "execute",
                hidden = function()
                    return filter:IsEnabled()
                end,
                width = "half",
                func = function()
                    filter:SetEnabled(true)
                    ACR:NotifyChange("RealUI")
                    Inventory.Update()
                end,
                order = function()
                    return (filter:GetIndex() * 10) + 3
                end,
            }
        end
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
                name = L.Inventory_AddFilter,
                desc = L.Inventory_AddFilterDesc,
                type = "input",
                set = function(_, value)
                    local tag = value:lower()
                    AddFilter(Inventory:CreateCustomFilter(tag, value, true))
                end,
                validate = function(_, value)
                    local tag = value:lower()
                    for i, filter in Inventory:IndexedFilters() do
                        if filter.tag == tag or filter.name == value then
                            return L.Inventory_Duplicate
                        end
                    end
                    return true
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
            },
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

    local function auroraGetValue(key, fallbackValue)
        return RealUI.GetAuroraConfigValue(key, fallbackValue)
    end

    local function auroraSetValue(key, value)
        RealUI.SetAuroraConfigValue(key, value)
    end

    local function auroraGetTable(key)
        local profileTable, runtimeTable = RealUI.GetAuroraConfigTable(key)
        return profileTable or runtimeTable
    end

    local function auroraSetTable(key, value)
        RealUI.SetAuroraConfigTable(key, value)
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
    local Util = _G.Aurora.Util
    -- [Duplication Resolution] Class Colors: The set callback writes to both
    -- CUSTOM_CLASS_COLORS (SkinsDB runtime) and AuroraConfig.customClassColors
    -- (Aurora standalone sync). This dual-write ensures class color changes made
    -- in RealUI carry over if the user later runs Aurora standalone.
    -- See design: Duplication Resolution Matrix — Class Colors.
    local classColors do
        classColors = {
            name = _G.CLASS_COLORS,
            type = "group",
            args = {
            }
        }

        for classToken, color in next, _G.CUSTOM_CLASS_COLORS do
            if (classToken == "ADVENTURER") then
               classToken = "Adventurer"
            end
            classColors.args[classToken] = {
                name = _G.LOCALIZED_CLASS_NAMES_MALE[classToken],
                type = "color",
                get = function(info) return color:GetRGB() end,
                set = function(info, r, g, b)
                    color:SetRGB(r, g, b)
                    _G.CUSTOM_CLASS_COLORS:NotifyChanges()
                    local customClassColors = auroraGetTable("customClassColors")
                    customClassColors[classToken] = {r = r, g = g, b = b}
                    auroraSetTable("customClassColors", customClassColors)
                end,
            }
        end
    end
    local minScale, maxScale = 0.25, 1
    -- =========================================================================
    -- Addon Skin Coverage Evaluation (Requirements 23.1, 23.2, 23.3)
    -- =========================================================================
    --
    -- Addons skinned by default in a standard RealUI installation:
    --   - Grid2           (raid/party frames, included in RealUI suite)
    --   - Bartender4      (action bars, included in RealUI workspace)
    --   - Masque          (button skinning, optional companion)
    --
    -- The addon skin list below is dynamically generated from
    -- Aurora.Base.GetAddonSkins(). Adding new skins requires writing skin
    -- code in Aurora or RealUI_Skins — changes to this config file alone
    -- will NOT add a new skin.
    --
    -- Candidate addons evaluated for future skin coverage:
    --
    --   Platynator (nameplate addon, included in RealUI workspace as reference)
    --     - Aurora does NOT provide a skin via GetAddonSkins().
    --     - A new skin would need to be written in RealUI_Skins.
    --     - Platynator manages its own nameplate frames; skinning would
    --       require hooking into its frame creation pipeline.
    --
    --   Details! Damage Meter (popular companion addon)
    --     - Aurora does NOT provide a skin via GetAddonSkins().
    --     - A new skin would need to be written in RealUI_Skins.
    --     - Details has its own extensive theming/skin system which may
    --       conflict with external skinning attempts.
    --
    --   WeakAuras (popular companion addon)
    --     - Aurora does NOT provide a skin via GetAddonSkins().
    --     - A new skin would need to be written in RealUI_Skins.
    --     - WeakAuras frames are user-created and highly dynamic; skinning
    --       the options UI is feasible but individual displays are not.
    --
    --   BigWigs / DBM (raid boss mods)
    --     - Aurora does NOT provide skins for either via GetAddonSkins().
    --     - New skins would need to be written in RealUI_Skins.
    --     - Both addons have their own bar/alert styling systems.
    --     - BigWigs has a plugin API that may be more appropriate than
    --       external frame skinning.
    --
    -- Recommendation: Details and BigWigs/DBM have mature internal theming
    -- systems, so external skins offer limited value. Platynator and
    -- WeakAuras options UI are the strongest candidates if skin coverage
    -- is expanded in the future.
    -- =========================================================================
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
                local isInstalled = _G.C_AddOns.GetAddOnInfo(name) ~= nil
                addons.args[name] = {
                    name = name,
                    desc = not isInstalled and (name .. " is not installed. Install the addon to enable this skin.") or nil,
                    type = "toggle",
                    disabled = not isInstalled and function() return true end or nil,
                    get = function() return SkinsDB.profile.addons[name] end,
                    set = function(info, value)
                        SkinsDB.profile.addons[name] = value
                    end,
                }
            end
        end
    end
    local blizzardSkins do
        blizzardSkins = {
            name = L["Appearance_Skins"] .. " - Blizzard",
            type = "group",
            args = {
                note = {
                    name = L.General_NoteReload,
                    type = "description",
                    order = 0,
                },
                Blizzard_WorldMap = {
                    name = L["Appearance_SkipWorldMapSkin"],
                    desc = L["Appearance_SkipWorldMapSkinDesc"],
                    type = "toggle",
                    width = "double",
                    get = function() return not SkinsDB.profile.addons["Blizzard_WorldMap"] end,
                    set = function(info, value)
                        SkinsDB.profile.addons["Blizzard_WorldMap"] = not value
                    end,
                    order = 1,
                },
            }
        }
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
            -- [Duplication Resolution] Frame Alpha: This is SkinsDB.frameColor.a —
            -- RealUI's frame backdrop alpha. Distinct from AuroraConfig.alpha (Skin
            -- Style → Frame Opacity), which controls Aurora's skinned element opacity.
            -- Both are intentionally exposed as separate controls.
            -- See design: Duplication Resolution Matrix — Frame Alpha.
            frameColor = {
                name = L.Appearance_FrameColor,
                desc = "RealUI's frame backdrop color and alpha. The alpha channel here controls the backdrop opacity of RealUI frames."
                    .. "\n\n|cffffcc00Note:|r This is separate from the Skin Style \226\134\146 Frame Opacity setting, which controls the opacity of skinned UI elements.",
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
                    Util.SetFrameAlpha(a)
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
            -- [Duplication Resolution] Font Replacement: These font selectors
            -- (normal/chat/header) control which fonts to use via SkinsDB. They are
            -- distinct from AuroraConfig.fonts (Skin Features → Replace Fonts), which
            -- is a master toggle controlling whether font replacement happens at all.
            -- Both are intentionally exposed as separate controls.
            -- See design: Duplication Resolution Matrix — Font Replacement.
            normal = {
                name = L.Fonts_Normal,
                desc = (L.Fonts_NormalDesc or "")
                    .. "\n\n|cffffcc00Note:|r This selects which font to use. The Skin Features \226\134\146 Replace Fonts toggle must be enabled for font replacement to take effect.",
                type = "select",
                dialogControl = "LSM30_Font",
                values = _G.AceGUIWidgetLSMlists.font,
                get = fontGet,
                set = fontSet,
                order = 11,
            },
            chat = {
                name = L.Fonts_Chat,
                desc = (L.Fonts_ChatDesc or "")
                    .. "\n\n|cffffcc00Note:|r This selects which font to use. The Skin Features \226\134\146 Replace Fonts toggle must be enabled for font replacement to take effect.",
                type = "select",
                dialogControl = "LSM30_Font",
                values = _G.AceGUIWidgetLSMlists.font,
                get = fontGet,
                set = fontSet,
                order = 12,
            },
            header = {
                name = L.Fonts_Header,
                desc = (L.Fonts_HeaderDesc or "")
                    .. "\n\n|cffffcc00Note:|r This selects which font to use. The Skin Features \226\134\146 Replace Fonts toggle must be enabled for font replacement to take effect.",
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
            scaleDesc = {
                name = "Scale settings are applied in the following order of precedence:\n"
                    .. "1. |cff00ff00Resolution Optimizer|r — When active, automatically sets High Resolution and may override Custom Scale.\n"
                    .. "2. |cff00ff00Pixel Perfect|r — When enabled, calculates the optimal scale automatically and disables Custom Scale.\n"
                    .. "3. |cff00ff00Custom Scale|r — Manual scale value, used when Pixel Perfect is off.\n"
                    .. "4. |cff00ff00UI Mod Scale|r — Scales only the Infobar and HuD Config bar, independent of the above settings.",
                type = "description",
                fontSize = "medium",
                order = 20.5,
            },
            -- ============================================================
            -- Install Wizard Affected Settings — Developer Reference
            -- (Requirement 18.3)
            --
            -- The Install Wizard (InstallWizard.lua) may reset or set
            -- the following settings during first-time setup or upgrade:
            --
            -- 1. isHighRes (Skins → High Resolution) — Advanced.lua
            -- 2. layout (HuD Config → Other → Layout) — ConfigBar.lua
            -- 3. useLarge / hudSize (HuD Config → Other → Use Large) — ConfigBar.lua
            -- 4. Resolution Optimizer re-optimization — triggered by wizard, not a direct config control
            -- 5. Chat settings (RealUI_Chat) — not in RealUI_Config
            -- 6. CVars (nameplateShowFriendlyNPCs, etc.) — set directly by wizard, not config controls
            -- 7. Naga bar visibility — set by wizard based on mouse type selection
            -- 8. Repair mount — set by wizard based on mount selection
            --
            -- Settings 1–3 that have config controls are annotated with
            -- a ⚠ warning in their desc field. Settings 4–8 are managed
            -- outside RealUI_Config and have no corresponding controls.
            -- ============================================================
            -- ============================================================
            -- Dead/Unused Options Audit — Developer Reference
            -- (Requirement 19.1, 19.3 — Task 10.1)
            --
            -- Audit performed across all get/set callbacks in Advanced.lua.
            -- Each db field was searched in the corresponding module code
            -- to verify it is read at runtime.
            --
            -- DEAD OPTIONS FOUND:
            --
            -- 1. coordDelayHide (Minimap → Information → Fade out Coords)
            --    DB field: MinimapAdv.db.profile.information.coordDelayHide
            --    Issue: The set callback referenced MinimapAdv:CoordsUpdate()
            --    which does not exist in the module. The db field is defined
            --    in defaults but never read by any module code.
            --    Resolution: Disabled with explanatory desc.
            --
            -- 2. multiTip (Tooltips → Multi-Tip)
            --    DB field: Tooltips.db.global.multiTip
            --    Issue: MultiTip.xml is commented out in the TOC file
            --    (# MultiTip.xml). The feature is not loaded and the db
            --    field is never read by any module code.
            --    Resolution: Disabled with explanatory desc.
            --
            -- 3. Tooltip position controls (atCursor, x, y, point)
            --    DB fields: Tooltips.db.global.position.*
            --    Issue: Position fields are defined in defaults but the
            --    RealUI_Tooltips module never reads them to position
            --    tooltips. The controls write to db but nothing uses
            --    the values.
            --    Resolution: Disabled with explanatory desc and group note.
            --
            -- 4. dvelve (Objectives → Collapse zones → Delves)
            --    DB field: ObjectivesAdv.db.profile.hidden.collapse.dvelve
            --    Issue: The db key is "dvelve" but WoW's GetInstanceInfo()
            --    returns "delve" for Delves. The collapse check uses
            --    db.hidden.collapse[instanceType] so the misspelled key
            --    never matches. Effectively dead.
            --    Resolution: Added explanatory desc noting the mismatch.
            --
            -- ALL OTHER OPTIONS VERIFIED ACTIVE:
            -- Every other get/set callback in Advanced.lua writes to db
            -- fields that are confirmed read by their respective module
            -- code at runtime.
            -- ============================================================
            isHighRes = {
                name = L.Appearance_HighRes,
                desc = L.Appearance_HighResDesc
                    .. "\n\n|cffffcc00Note:|r The Resolution Optimizer may manage this setting automatically based on your screen resolution."
                    .. "\n\n|cffffcc00⚠|r This setting may be reset by the Install Wizard during first-time setup or upgrade.",
                type = "toggle",
                get = function() return SkinsDB.profile.isHighRes end,
                set = function(info, value)
                    SkinsDB.profile.isHighRes = value
                    RealUI.UpdateUIScale(SkinsDB.profile.customScale, true)
                end,
                order = 21,
            },
            isPixelScale = {
                name = L.Appearance_Pixel,
                desc = L.Appearance_PixelDesc
                    .. "\n\n|cffffcc00Note:|r When enabled, the Custom Scale input is locked and its value is calculated automatically.",
                type = "toggle",
                get = function() return SkinsDB.profile.isPixelScale end,
                set = function(info, value)
                    SkinsDB.profile.isPixelScale = value
                    RealUI.UpdateUIScale(nil, true)
                end,
                order = 22
            },
            customScale = {
                name = L.Appearance_UIScale,
                desc = L.Appearance_UIScaleDesc:format(minScale, maxScale)
                    .. "\n\n|cffffcc00Note:|r This value is overridden when Pixel Perfect is enabled (scale is calculated automatically). "
                    .. "The Resolution Optimizer may also override this value based on your screen resolution.",
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
                    RealUI.UpdateUIScale(_G.tonumber(value), true)
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
            blizzardSkins = blizzardSkins,
            skinFeatures = {
                name = "Skin Features",
                type = "group",
                inline = true,
                order = 30,
                args = {
                    desc = {
                        name = "Toggle skinning for individual UI elements. Changes require a UI reload to take effect.",
                        type = "description",
                        order = 0,
                    },
                    bags = {
                        name = "Skin Bags",
                        desc = "Skin bag frames",
                        type = "toggle",
                        get = function() return auroraGetValue("bags", true) end,
                        set = function(info, value) auroraSetValue("bags", value) end,
                        order = 1,
                    },
                    banks = {
                        name = "Skin Banks",
                        desc = "Skin bank frames",
                        type = "toggle",
                        get = function() return auroraGetValue("banks", true) end,
                        set = function(info, value) auroraSetValue("banks", value) end,
                        order = 2,
                    },
                    chat = {
                        name = "Skin Chat",
                        desc = "Skin chat frames",
                        type = "toggle",
                        get = function() return auroraGetValue("chat", true) end,
                        set = function(info, value) auroraSetValue("chat", value) end,
                        order = 3,
                    },
                    loot = {
                        name = "Skin Loot",
                        desc = "Skin loot frames",
                        type = "toggle",
                        get = function() return auroraGetValue("loot", true) end,
                        set = function(info, value) auroraSetValue("loot", value) end,
                        order = 4,
                    },
                    mainmenubar = {
                        name = "Skin Main Menu Bar",
                        desc = "Skin main menu bar",
                        type = "toggle",
                        get = function() return auroraGetValue("mainmenubar", false) end,
                        set = function(info, value) auroraSetValue("mainmenubar", value) end,
                        order = 5,
                    },
                    -- [Duplication Resolution] Font Replacement: This is AuroraConfig.fonts —
                    -- a master toggle for whether font replacement happens at all. Distinct
                    -- from the SkinsDB font selectors (normal/chat/header) above, which
                    -- control which fonts are used when replacement is active.
                    -- See design: Duplication Resolution Matrix — Font Replacement.
                    fonts = {
                        name = "Replace Fonts",
                        desc = "Controls whether the skin engine replaces default UI fonts."
                            .. "\n\n|cffffcc00Note:|r This is separate from the font selectors under Fonts above, which choose which fonts to use. This toggle must be enabled for those font selections to take effect.",
                        type = "toggle",
                        get = function() return auroraGetValue("fonts", true) end,
                        set = function(info, value) auroraSetValue("fonts", value) end,
                        order = 6,
                    },
                    tooltips = {
                        name = "Skin Tooltips",
                        desc = "Skin tooltip frames",
                        type = "toggle",
                        get = function() return auroraGetValue("tooltips", true) end,
                        set = function(info, value) auroraSetValue("tooltips", value) end,
                        order = 7,
                    },
                    chatBubbles = {
                        name = "Skin Chat Bubbles",
                        desc = "Skin chat bubbles",
                        type = "toggle",
                        get = function() return auroraGetValue("chatBubbles", true) end,
                        set = function(info, value) auroraSetValue("chatBubbles", value) end,
                        order = 8,
                    },
                    chatBubbleNames = {
                        name = "Show Chat Bubble Names",
                        desc = "Show names on chat bubbles",
                        type = "toggle",
                        get = function() return auroraGetValue("chatBubbleNames", true) end,
                        set = function(info, value) auroraSetValue("chatBubbleNames", value) end,
                        order = 9,
                    },
                    characterSheet = {
                        name = "Skin Character Sheet",
                        desc = "Skin the character sheet frame."
                            .. "\n\n|cff888888Disable when using addons like ChonkyCharacterSheet that replace the character sheet.|r",
                        type = "toggle",
                        get = function() return auroraGetValue("characterSheet", true) end,
                        set = function(info, value) auroraSetValue("characterSheet", value) end,
                        order = 10,
                    },
                    objectiveTracker = {
                        name = "Skin Objective Tracker",
                        desc = "Skin the objective/quest tracker frame."
                            .. "\n\n|cff888888Disabling restores Blizzard's default tracker appearance.|r",
                        type = "toggle",
                        get = function() return auroraGetValue("objectiveTracker", true) end,
                        set = function(info, value) auroraSetValue("objectiveTracker", value) end,
                        order = 11,
                    },
                },
            },
            skinStyle = {
                name = "Skin Style",
                type = "group",
                inline = true,
                order = 31,
                args = {
                    desc = {
                        name = "Adjust the visual style of skinned UI elements.",
                        type = "description",
                        order = 0,
                    },
                    buttonsHaveGradient = {
                        name = "Button Gradient",
                        desc = "Use gradient on buttons",
                        type = "toggle",
                        get = function() return auroraGetValue("buttonsHaveGradient", true) end,
                        set = function(info, value) auroraSetValue("buttonsHaveGradient", value) end,
                        order = 1,
                    },
                    talentArtBackground = {
                        name = "Talent Artistic Background",
                        desc = "Show Blizzard's class-specific artwork behind the talent tree."
                            .. "\n\n|cff888888Disabling hides the artwork and shows Aurora's flat dark background.|r",
                        type = "toggle",
                        get = function() return auroraGetValue("talentArtBackground", true) end,
                        set = function(info, value) auroraSetValue("talentArtBackground", value) end,
                        order = 2,
                    },
                    customHighlightEnabled = {
                        name = "Custom Highlight",
                        desc = "Use custom highlight color",
                        type = "toggle",
                        get = function()
                            return auroraGetTable("customHighlight").enabled
                        end,
                        set = function(info, value)
                            local customHighlight = auroraGetTable("customHighlight")
                            customHighlight.enabled = value
                            auroraSetTable("customHighlight", customHighlight)
                        end,
                        order = 3,
                    },
                    highlightColor = {
                        name = "Highlight Color",
                        desc = "Custom highlight color."
                            .. "\n\n|cff888888Disabled when Custom Highlight is not enabled.|r",
                        type = "color",
                        hasAlpha = false,
                        disabled = function()
                            return not auroraGetTable("customHighlight").enabled
                        end,
                        get = function()
                            local ch = auroraGetTable("customHighlight")
                            return ch.r or 0, ch.g or 0, ch.b or 0
                        end,
                        set = function(info, r, g, b)
                            local customHighlight = auroraGetTable("customHighlight")
                            customHighlight.r = r
                            customHighlight.g = g
                            customHighlight.b = b
                            auroraSetTable("customHighlight", customHighlight)
                        end,
                        order = 4,
                    },
                    -- [Duplication Resolution] Frame Alpha: This is AuroraConfig.alpha —
                    -- Aurora's skinned element opacity. Distinct from SkinsDB.frameColor.a
                    -- (Appearance → Frame Color alpha), which controls RealUI's frame
                    -- backdrop opacity. Both are intentionally exposed as separate controls.
                    -- See design: Duplication Resolution Matrix — Frame Alpha.
                    alpha = {
                        name = "Frame Opacity",
                        desc = "Opacity of skinned UI element frames."
                            .. "\n\n|cffffcc00Note:|r This is separate from the Appearance \226\134\146 Frame Color alpha, which controls the backdrop opacity of RealUI frames.",
                        type = "range",
                        min = 0, max = 1, step = 0.05,
                        isPercent = true,
                        get = function() return auroraGetValue("alpha", 1) end,
                        set = function(info, value) auroraSetValue("alpha", value) end,
                        order = 4,
                    },
                },
            },
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
                desc = "|cffff4444Note:|r This setting currently has no effect and may be removed in a future version."
                    .. "\n\nThe MultiTip feature is disabled (not loaded in the current build).",
                type = "toggle",
                disabled = function() return true end,
                get = appGet,
                set = appSet,
                order = 5,
            },
            position = {
                name = "Position",
                type = "group",
                inline = true,
                order = 10,
                args = {
                    deadNote = {
                        name = "|cffff4444Note:|r These position settings currently have no effect. "
                            .. "The RealUI_Tooltips module does not yet read these values to reposition tooltips. "
                            .. "They may be wired up in a future version or removed.",
                        type = "description",
                        order = 0,
                    },
                    atCursor = {
                        name = "Anchor to Cursor",
                        desc = "|cffff4444Note:|r This setting currently has no effect and may be removed in a future version.",
                        type = "toggle",
                        disabled = function() return true end,
                        get = function() return Tooltips.db.global.position.atCursor end,
                        set = function(info, value)
                            Tooltips.db.global.position.atCursor = value
                        end,
                        order = 1,
                    },
                    point = {
                        name = "Anchor Point",
                        desc = "|cffff4444Note:|r This setting currently has no effect and may be removed in a future version.",
                        type = "select",
                        disabled = function() return true end,
                        values = {
                            TOPLEFT = "TOPLEFT",
                            TOP = "TOP",
                            TOPRIGHT = "TOPRIGHT",
                            LEFT = "LEFT",
                            CENTER = "CENTER",
                            RIGHT = "RIGHT",
                            BOTTOMLEFT = "BOTTOMLEFT",
                            BOTTOM = "BOTTOM",
                            BOTTOMRIGHT = "BOTTOMRIGHT",
                        },
                        get = function() return Tooltips.db.global.position.point end,
                        set = function(info, value)
                            Tooltips.db.global.position.point = value
                        end,
                        order = 2,
                    },
                    x = {
                        name = "X Offset",
                        desc = "|cffff4444Note:|r This setting currently has no effect and may be removed in a future version.",
                        type = "input",
                        width = "half",
                        disabled = function() return true end,
                        get = function() return tostring(Tooltips.db.global.position.x) end,
                        set = function(info, value)
                            Tooltips.db.global.position.x = ValidateOffset(value)
                        end,
                        order = 3,
                    },
                    y = {
                        name = "Y Offset",
                        desc = "|cffff4444Note:|r This setting currently has no effect and may be removed in a future version.",
                        type = "input",
                        width = "half",
                        disabled = function() return true end,
                        get = function() return tostring(Tooltips.db.global.position.y) end,
                        set = function(info, value)
                            Tooltips.db.global.position.y = ValidateOffset(value)
                        end,
                        order = 4,
                    },
                },
            },
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
                    desc = "|cff888888Disabled when the Alt Power Bar module is not enabled.|r",
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
                    desc = "|cff888888Disabled when the Alt Power Bar module is not enabled.|r",
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
                    desc = "The minimum number of seconds a cooldown's duration must be to display text."
                        .. "\n\n|cff888888Disabled when the CooldownCount module is not enabled.|r",
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
                    desc = "The minimum number of seconds a cooldown must be to display in the expiring format."
                        .. "\n\n|cff888888Disabled when the CooldownCount module is not enabled.|r",
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
                desc = "|cff888888Disabled when the FrameMover module is not enabled.|r",
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
                    desc = "|cff888888Disabled when " .. addon.name .. " is not loaded or FrameMover is not enabled.|r",
                    disabled = function() return not(_G.C_AddOns.IsAddOnLoaded(addon.name) and RealUI:GetModuleEnabled(MODNAME)) end,
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
                    desc = "|cff888888Disabled when frame moving is not enabled for this addon.|r",
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
                        desc = "|cff888888Disabled when frame moving or healing layout is not enabled for this addon.|r",
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
                desc = "|cff888888Disabled when the FrameMover module is not enabled.|r",
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
                        desc = "|cff888888Disabled when frame moving is not enabled for this UI frame.|r",
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
                desc = "|cff888888Disabled when the FrameMover module is not enabled.|r",
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
                docPanel = {
                    type = "description",
                    name = "|cffffcc00Frame Positioning Systems|r\n\n"
                        .. "|cff88ccffFrameMover|r: Repositions addon frames and UI frames to predefined positions. Positions are stored in the FrameMover profile and applied on login or reload.\n\n"
                        .. "|cff88ccffDragEmAll|r: Allows dragging Blizzard frames to custom positions. Positions persist across sessions via LibWindow.\n\n"
                        .. "|cff88ccffEditMode|r: WoW's built-in frame layout editor. Manages certain Blizzard frames that FrameMover may also target.\n\n"
                        .. "|cffff4444\226\154\160 Conflict:|r If FrameMover and EditMode both manage the same frame, EditMode may override FrameMover's position on reload. Disable FrameMover for any frames you manage in EditMode.",
                    fontSize = "medium",
                    order = 25,
                },
                addons = addonOpts,
                uiframes = uiFramesOpts,
                hide = hideOpts,
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
                    desc = "|cff888888Disabled when the Minimap module is not enabled.|r",
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                    order = 40,
                    args = {
                        coordDelayHide = {
                            name = "Fade out Coords",
                            desc = "|cffff4444Note:|r This setting currently has no effect and may be removed in a future version."
                                .. "\n\nThe coordinate fade-out feature is not implemented in the current MinimapAdv module.",
                            type = "toggle",
                            disabled = function() return true end,
                            get = function(info) return MinimapAdv.db.profile.information.coordDelayHide end,
                            set = function(info, value)
                                MinimapAdv.db.profile.information.coordDelayHide = value
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
                    desc = "|cff888888Disabled when the Minimap module is not enabled.|r",
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
                            desc = "|cff888888Disabled when Automatic Hide/Show is not enabled.|r",
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
                    desc = "|cff888888Disabled when the Minimap module is not enabled.|r",
                    disabled = function() if RealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
                    order = 60,
                    args = {
                        size = {
                            name = "Size",
                            desc = "Note: Minimap will refresh to fit the new size upon player movement.",
                            type = "range",
                            min = 134, max = 250, step = 1,
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
                    desc = "|cff888888Disabled when the Minimap module is not enabled.|r",
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
                                    desc = "If you have Gatherer installed, then MinimapAdv will automatically disable Gatherer's minimap icons and HUD while not in Farm Mode, and enable them while in Farm Mode."
                                        .. "\n\n|cff888888Disabled when Gatherer is not installed.|r",
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
                                showtracking = {
                                    name = "Show Tracking in Farm Mode",
                                    type = "toggle",
                                    get = function(info) return MinimapAdv.db.profile.expand.extras.showtracking end,
                                    set = function(info, value)
                                        MinimapAdv.db.profile.expand.extras.showtracking = value
                                        MinimapAdv:UpdateFarmModeShowTracking()
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
                    desc = "|cff888888Disabled when the Minimap module is not enabled.|r",
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
                            desc = "|cff888888Disabled when POI display is not enabled.|r",
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
                            desc = "|cff888888Disabled when POI display is not enabled.|r",
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
                    desc = "|cff888888Disabled when the Mirror Bar module is not enabled.|r",
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
                    desc = "|cff888888Disabled when the Mirror Bar module is not enabled.|r",
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
        local function collapseFrameGet(info)
            return ObjectivesAdv.db.profile.hidden.collapseframe[info[#info]]
        end
        local function collapseFrameSet(info, value)
            ObjectivesAdv.db.profile.hidden.collapseframe[info[#info]] = value
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
                    desc = "|cff888888Disabled when the Objectives Adv. module is not enabled.|r",
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
                            desc = "|cff888888Disabled when Size/Position adjustments are not enabled.|r",
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
                            desc = "|cff888888Disabled when Size/Position adjustments are not enabled.|r",
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
                    desc = "|cff888888Disabled when the Objectives Adv. module is not enabled.|r",
                    disabled = function() return not RealUI:GetModuleEnabled(MODNAME) end,
                    order = 60,
                    args = {
                        header = {
                            name = "Automatically collapse the Object Tracker Frames in certain zones.",
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
                        collapse_frames = {
                            name = "Collapse the follwoing tracking frames..",
                            type = "group",
                            inline = true,
                            desc = "|cff888888Disabled when Automatic Collapse/Hide is not enabled.|r",
                            disabled = function() return not(RealUI:GetModuleEnabled(MODNAME) and ObjectivesAdv.db.profile.hidden.enabled) end,
                            order = 25,
                            args = {
                                quest = {
                                    name = _G.QUESTS_LABEL,
                                    type = "toggle",
                                    get = collapseFrameGet,
                                    set = collapseFrameSet,
                                    order = 10,
                                },
                                campaign = {
                                    name = _G.CONTAINER_CAMPAIGN_PROGRESS,
                                    type = "toggle",
                                    get = collapseFrameGet,
                                    set = collapseFrameSet,
                                    order = 20,
                                },
                                adventure = {
                                    name = _G.COVENANT_MISSIONS_TITLE,
                                    type = "toggle",
                                    get = collapseFrameGet,
                                    set = collapseFrameSet,
                                    order = 30,
                                },
                                proffesion = {
                                    name = _G.PROFESSIONS_TRACKER_HEADER_PROFESSION,
                                    type = "toggle",
                                    get = collapseFrameGet,
                                    set = collapseFrameSet,
                                    order = 40,
                                },
                                bonus = {
                                    name = _G.BONUS_OBJECTIVE_BANNER,
                                    type = "toggle",
                                    get = collapseFrameGet,
                                    set = collapseFrameSet,
                                    order = 50,
                                },
                                world = {
                                    name = _G.WORLD_QUEST_BANNER,
                                    type = "toggle",
                                    get = collapseFrameGet,
                                    set = collapseFrameSet,
                                    order = 60,
                                },
                            },
                        },
                        collapse = {
                            name = "in..",
                            type = "group",
                            inline = true,
                            desc = "|cff888888Disabled when Automatic Collapse/Hide is not enabled.|r",
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
                                dvelve = {
                                    name = "Delves",
                                    desc = "|cffff4444Note:|r This setting currently has no effect due to a db key mismatch. "
                                        .. "The internal key is \"dvelve\" but WoW returns \"delve\" as the instance type. "
                                        .. "This will be fixed in a future update.",
                                    type = "toggle",
                                    get = collapseGet,
                                    set = collapseSet,
                                    order = 60,
                                },
                            },
                        },
                        gap2 = {
                            name = " ",
                            type = "description",
                            order = 31,
                        },
                        hide = {
                            name = "Hide the Objectives Tracker Frame completely in..",
                            type = "group",
                            inline = true,
                            desc = "|cff888888Disabled when Automatic Collapse/Hide is not enabled.|r",
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
            cooldown = cooldown,
            eventNotify = eventNotify,
            frameMover = frameMover,
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
