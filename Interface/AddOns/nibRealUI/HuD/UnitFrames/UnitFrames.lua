local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0")
local db, ndb, ndbc

local oUF = oUFembed
UnitFrames.units = {}

local ModKeys = {
    "shift",
    "ctrl",
    "alt"
}
local trinkChat = {
    "GROUP",
    "SAY",
}
local options
local function GetOptions()
    if not options then options = {
        type = "group",
        name = "Unit Frames",
        arg = MODNAME,
        order = 2114,
        args = {
            header1 = {
                type = "header",
                name = "Unit Frames",
                order = 10,
            },
            desc3 = {
                type = "description",
                name = "Note: You will need to reload the UI (/rl) for changes to take effect.",
                order = 11,
            },
            enabled = {
                type = "toggle",
                name = "Enabled",
                desc = "Enable/Disable the Unit Frames module.",
                get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
                set = function(info, value)
                    nibRealUI:SetModuleEnabled(MODNAME, value)
                    nibRealUI:ReloadUIDialog()
                end,
                order = 20,
            },
            header2 = {
                type = "header",
                name = "General",
                order = 21,
            },
            focusclick = {
                type = "toggle",
                name = "Click Set Focus",
                desc = "Set focus by click+modifier on the Unit Frames.",
                get = function() return db.misc.focusclick end,
                set = function(info, value)
                    db.misc.focusclick = value
                end,
                order = 30,
            },
            focuskey = {
                type = "select",
                name = "Modifier Key",
                values = ModKeys,
                disabled = function() return not db.misc.focusclick end,
                get = function(info)
                    for i = 1, #ModKeys do
                        if ModKeys[i] == db.misc.focuskey then
                            return i
                        end
                    end
                end,
                set = function(info, value)
                    db.misc.focuskey = ModKeys[value]
                end,
                order = 40,
            },
            gap1 = {
                name = " ",
                type = "description",
                order = 41,
            },
            alwaysDisplayFullHealth = {
                type = "toggle",
                name = "Full Health on Target",
                desc = "Always display the full health value on the Target frame.",
                get = function() return db.misc.alwaysDisplayFullHealth end,
                set = function(info, value)
                    db.misc.alwaysDisplayFullHealth = value
                end,
                order = 50,
            },
            groups = {
                type = "group",
                name = "Groups",
                childGroups = "tab",
                disabled = function() return not(nibRealUI:GetModuleEnabled(MODNAME)) end,
                order = 60,
                args = {
                    rlnote = {
                        type = "description",
                        name = "Note: You will need to reload the UI (/rl) for changes to take effect.",
                        order = 1,
                    },
                    gap1 = {
                        name = " ",
                        type = "description",
                        order = 10,
                    },
                    gap = {
                        type = "range",
                        name = "Gap",
                        desc = "Vertical distance between each unit.",
                        min = 0, max = 10, step = 1,
                        get = function(info) return db.boss.gap end,
                        set = function(info, value) db.boss.gap = value end,
                        order = 20,
                    },
                    gap2 = {
                        name = " ",
                        type = "description",
                        order = 21,
                    },
                    boss = {
                        type = "group",
                        name = "Boss Frames",
                        disabled = function() return not(nibRealUI:GetModuleEnabled(MODNAME)) end,
                        order = 30,
                        args = {
                            showPlayerAuras = {
                                type = "toggle",
                                name = "Show Player Auras",
                                desc = "Show Buffs/Debuffs cast by you.",
                                get = function() return db.boss.showPlayerAuras end,
                                set = function(info, value)
                                    db.boss.showPlayerAuras = value
                                end,
                                order = 10,
                            },
                            showNPCAuras = {
                                type = "toggle",
                                name = "Show NPC Auras",
                                desc = "Show Buffs/Debuffs cast by NPCs.",
                                get = function() return db.boss.showNPCAuras end,
                                set = function(info, value)
                                    db.boss.showNPCAuras = value
                                end,
                                order = 20,
                            },
                            buffCount = {
                                type = "range",
                                name = "Buff Count",
                                min = 1, max = 8, step = 1,
                                get = function(info) return db.boss.buffCount end,
                                set = function(info, value) db.boss.buffCount = value end,
                                order = 30,
                            },
                            debuffCount = {
                                type = "range",
                                name = "Debuff Count",
                                min = 1, max = 8, step = 1,
                                get = function(info) return db.boss.debuffCount end,
                                set = function(info, value) db.boss.debuffCount = value end,
                                order = 40,
                            },
                        },
                    },
                    arena = {
                        type = "group",
                        name = "Arena Frames",
                        disabled = function() return not(nibRealUI:GetModuleEnabled(MODNAME)) end,
                        order = 40,
                        args = {
                            enabled = {
                                type = "toggle",
                                name = "Enabled",
                                desc = "Enable/Disable RealUI Arena Frames.",
                                get = function() return db.arena.enabled end,
                                set = function(info, value)
                                    db.arena.enabled = value
                                end,
                                order = 10,
                            },
                            options = {
                                type = "group",
                                name = "",
                                inline = true,
                                disabled = function() return not db.arena.enabled end,
                                order = 20,
                                args = {
                                    announceUse = {
                                        type = "toggle",
                                        name = "Announce trinkets",
                                        desc = "Announce opponent trinket use to chat.",
                                        get = function() return db.arena.announceUse end,
                                        set = function(info, value)
                                            db.arena.announceUse = value
                                        end,
                                        order = 10,
                                    },
                                    announceChat = {
                                        type = "select",
                                        name = CHAT,
                                        desc = "Chat channel used for trinket announcement.",
                                        values = trinkChat,
                                        disabled = function() return not db.arena.announceUse end,
                                        get = function(info)
                                            for i = 1, #trinkChat do
                                                if trinkChat[i] == db.arena.announceChat then
                                                    return i
                                                end
                                            end
                                        end,
                                        set = function(info, value)
                                            db.arena.announceChat = trinkChat[value]
                                        end,
                                        order = 20,
                                    },
                                    --[[showPets = {
                                        type = "toggle",
                                        name = SHOW_ARENA_ENEMY_PETS_TEXT,
                                        desc = OPTION_TOOLTIP_SHOW_ARENA_ENEMY_PETS,
                                        get = function() return db.arena.showPets end,
                                        set = function(info, value)
                                            db.arena.showPets = value
                                        end,
                                        order = 30,
                                    },
                                    showCast = {
                                        type = "toggle",
                                        name = SHOW_ARENA_ENEMY_CASTBAR_TEXT,
                                        desc = OPTION_TOOLTIP_SHOW_ARENA_ENEMY_CASTBAR,
                                        get = function() return db.arena.showCast end,
                                        set = function(info, value)
                                            db.arena.showCast = value
                                        end,
                                        order = 40,
                                    },]]
                                },
                            },
                        },
                    },
                },
            },
            positions = {
                type = "group",
                name = "Positions",
                disabled = function() return not(nibRealUI:GetModuleEnabled(MODNAME)) end,
                childGroups = "tab",
                order = 70,
                args = {
                    rlnote = {
                        type = "description",
                        name = "Note: You will need to reload the UI (/rl) for changes to take effect.",
                        order = 1,
                    },
                },
            },
            overlay = {
                type = "group",
                name = "Appearance",
                disabled = function() return not(nibRealUI:GetModuleEnabled(MODNAME)) end,
                childGroups = "tab",
                order = 80,
                args = {
                    rlnote = {
                        type = "description",
                        name = "Note: You will need to reload the UI (/rl) for changes to take effect.",
                        order = 1,
                    },
                    bar = {
                        type = "group",
                        name = "Bars",
                        order = 10,
                        args = {
                            opacity = {
                                type = "group",
                                inline = true,
                                name = "Opacity",
                                order = 10,
                                args = {
                                    absorb = {
                                        type = "range",
                                        name = "Absorb Bar",
                                        min = 0, max = 1, step = 0.05,
                                        isPercent = true,
                                        get = function(info) return db.overlay.bar.opacity.absorb end,
                                        set = function(info, value) db.overlay.bar.opacity.absorb = value end,
                                        order = 10,
                                    },
                                },
                            },
                        },
                    },
                    colors = {
                        type = "group",
                        name = "Colors",
                        order = 20,
                        args = {
                            classColor = {
                                type = "toggle",
                                name = "Color Bars by Class",
                                desc = "Color Health Bars based on the player's class.",
                                get = function() return db.overlay.classColor end,
                                set = function(info, value)
                                    db.overlay.classColor = value
                                end,
                                order = 10,
                            },
                            classColorNames = {
                                type = "toggle",
                                name = "Color Names by Class",
                                desc = "Color Player Names based on the player's class.",
                                get = function() return db.overlay.classColorNames end,
                                set = function(info, value)
                                    db.overlay.classColorNames = value
                                end,
                                order = 11,
                            },
                        },
                    },
                },
            },
        },
    }
    end

    ---------------
    -- Positions --
    ---------------
    local PositionLayoutOpts, PositionOpts = {}, {}
    local Opts_PositionOrderCnt = 10
    for size, units in next, db.positions do
        local layout = size == 1 and "Low Res" or "High Res"
        wipe(PositionOpts)
        for unit, position in next, units do
            local unitName = unit == "boss" and "boss/arena" or unit
            PositionOpts[unit] = {
                type = "group",
                inline = true,
                name = unitName,
                order = Opts_PositionOrderCnt,
                args = {
                    x = {
                        type = "input",
                        name = "X",
                        width = "half",
                        order = 10,
                        get = function(info) return tostring(position.x) end,
                        set = function(info, value)
                            value = nibRealUI:ValidateOffset(value)
                            position.x = value
                        end,
                    },
                    y = {
                        type = "input",
                        name = "Y",
                        width = "half",
                        order = 20,
                        get = function(info) return tostring(position.y) end,
                        set = function(info, value)
                            value = nibRealUI:ValidateOffset(value)
                            position.y = value
                        end,
                    },
                },
            };

            Opts_PositionOrderCnt = Opts_PositionOrderCnt + 10
        end

        PositionLayoutOpts["res"..size] = {
            type = "group",
            name = layout,
            order = size,
            args = {}
        }
        for key, val in next, PositionOpts do
            PositionLayoutOpts["res"..size].args[key] = (type(val) == "function") and val() or val
        end
    end
    for key, val in next, PositionLayoutOpts do
        options.args.positions.args[key] = (type(val) == "function") and val() or val
    end

    ------------
    -- Colors --
    ------------
    local ColorGroupOpts, ColorOpts = {}, {}
    local Opts_ColorGroupOrderCnt = 20
    for group, colors in next, db.overlay.colors do
        wipe(ColorOpts)
        for name, color in next, colors do
            ColorOpts[name] = {
                type = "color",
                name = name,
                get = function(info, r, g, b, a)
                    return color[1], color[2], color[3]
                end,
                set = function(info, r, g, b, a)
                    color[1] = r
                    color[2] = g
                    color[3] = b
                end,
                order = 10,
            };
        end

        ColorGroupOpts[group] = {
            type = "group",
            inline = true,
            name = group,
            order = Opts_ColorGroupOrderCnt,
            args = {}
        }
        for key, val in next, ColorOpts do
            ColorGroupOpts[group].args[key] = (type(val) == "function") and val() or val
        end
        Opts_ColorGroupOrderCnt = Opts_ColorGroupOrderCnt + 10
    end
    for key, val in next, ColorGroupOpts do
        options.args.overlay.args.colors.args[key] = (type(val) == "function") and val() or val
    end

    return options
end

-- Abbreviated Name
local NameLengths = {
    [1] = {
        ["target"] = 25,
        ["pet"] = 14,
    },
    [2] = {
        ["target"] = 22,
        ["pet"] = 14,
    },
}
function UnitFrames:AbrvName(name, unit)
    --print("AbrvName", name, string.match(name, "%w+"), unit)
    if not name then return "" end
    --if not string.match(name, "%w+") then
    --    return name
    --end

    if (unit == "target") and (db.misc.alwaysDisplayFullHealth) then
        return nibRealUI:AbbreviateName(name, NameLengths[self.layoutSize][unit] - 7)
    else
        return nibRealUI:AbbreviateName(name, NameLengths[self.layoutSize][unit] or 12)
    end
end

local units = {
    "Player",
    "Target",
    "Focus",
    "FocusTarget",
    "Pet",
    "TargetTarget",
}

function UnitFrames:RefreshUnits(event)
    for i = 1, #units do
        local unit = _G["RealUI" .. units[i] .. "Frame"]
        unit:UpdateAllElements(event)
    end
end

function UnitFrames:SetoUFColors()
    local colors = db.overlay.colors
    for power, color in next, colors.power do
        if (type(power) == "string") then
            oUF.colors.power[power] = color
        end
    end
    oUF.colors.health = colors.health.normal
    for eclass, _ in next, RAID_CLASS_COLORS do
        local color = nibRealUI:GetClassColor(eclass)
        color = nibRealUI:ColorDarken(color, 0.15)
        color = nibRealUI:ColorDesaturate(color, 0.2)
        oUF.colors.class[eclass] = color
    end
end

-- Color Retrieval for Config Bar
function UnitFrames:ToggleClassColoring(names)
	if names then
		db.overlay.classColorNames = not db.overlay.classColorNames
	else
		db.overlay.classColor = not db.overlay.classColor
	end
end

function UnitFrames:GetoUFColors()
    return oUF.colors
end

function UnitFrames:GetHealthColor()
	return oUF.colors.health
end

function UnitFrames:GetPowerColors()
	return oUF.colors.power
end

function UnitFrames:GetStatusColors()
	return db.overlay.colors.status
end

-- Squelch taint popup
hooksecurefunc("UnitPopup_OnClick",function(self)
    local button = self.value
    if button == "SET_FOCUS" or button == "CLEAR_FOCUS" then
        if StaticPopup1 then
            StaticPopup1:Hide()
        end
        if db.misc.focusclick then
            nibRealUI:Notification("RealUI", true, "Use "..db.misc.focuskey.."+click to set Focus.", nil, [[Interface\AddOns\nibRealUI\Media\Icons\Notification_Alert]])
        end
    elseif button == "PET_DISMISS" then
        if StaticPopup1 then
            StaticPopup1:Hide()
        end
    end
end)

----------------------------
------ Initialization ------
----------------------------
function UnitFrames:OnInitialize()
    ---[[
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            misc = {
                focusclick = true,
                focuskey = "shift",
                statusText = "smart",
                alwaysDisplayFullHealth = true,
                steppoints = {
                    ["default"] = {0.35, 0.25},
                    ["HUNTER"]  = {0.35, 0.2},
                    ["PALADIN"] = {0.35, 0.2},
                    ["WARLOCK"] = {0.35, 0.2},
                    ["WARRIOR"] = {0.35, 0.2},
                },
                combatfade = {
                    enabled = true,
                    opacity = {
                        incombat = 1,
                        hurt = 0.85,
                        target = 0.85,
                        harmtarget = 0.75,
                        outofcombat = 0.25,
                    },
                },
            },
            units = {
                -- Eventually, these settings will be used to adjust unit frame size.
                player = {
                    size = {x = 259, y = 28},
                    position = {x = 0, y = 0},
                    healthHieght = 0.6, --percentage of the unit hieght used by the healthbar
                },
                target = {
                    size = {x = 259, y = 28},
                    position = {x = 0, y = 0},
                    healthHieght = 0.6, --percentage of the unit hieght used by the healthbar
                },
            },
            arena = {
                enabled = true,
                announceUse = true,
                announceChat = "GROUP",
                showCast = true,
                showPets = true,
            },
            boss = {
                gap = 3,
                buffCount = 3,
                debuffCount = 5,
                showPlayerAuras = true,
                showNPCAuras = true,
            },
            positions = {
                [1] = {
                    player =       { x = 0,   y = 0},   -- Anchored to Positioner
                    pet =          { x = 51,  y = -84}, -- Anchored to Player
                    focus =        { x = 29,  y = -62}, -- Anchored to Player
                    focustarget =  { x = 11,  y = -2},  -- Anchored to Focus
                    target =       { x = 0,   y = 0},   -- Anchored to Positioner
                    targettarget = { x = -29, y = -62}, -- Anchored to Target
                    boss =         { x = 0,   y = 0},   -- Anchored to Positioner
                },
                [2] = {
                    player =       { x = 0,   y = 0},   -- Anchored to Positioner
                    pet =          { x = 60,  y = -91}, -- Anchored to Player
                    focus =        { x = 36,  y = -67}, -- Anchored to Player
                    focustarget =  { x = 12,  y = -2},  -- Anchored to Focus
                    target =       { x = 0,   y = 0},   -- Anchored to Positioner
                    targettarget = { x = -36, y = -67}, -- Anchored to Target
                    boss =         { x = 0,   y = 0},   -- Anchored to Positioner
                },
            },
            overlay = {
                bar = {
                    opacity = {
                        absorb = 0.25,          -- Absorb Bar
                    },
                },
                classColor = false,
                classColorNames = true,
                colors = {
                    health = {
                        normal = {0.66, 0.22, 0.22},
                    },
                    power = {
                        ["MANA"] =        {0.00, 0.50, 0.94},
                        ["RAGE"] =        {0.75, 0.12, 0.12},
                        ["FOCUS"] =       {0.95, 0.50, 0.20},
                        ["ENERGY"] =      {0.90, 0.80, 0.20},
                        ["CHI"] =         {0.35, 0.80, 0.70},
                        ["RUNES"] =       {0.50, 0.50, 0.50},
                        ["RUNIC_POWER"] = {0.00, 0.65, 0.85},
                        ["SOUL_SHARDS"] = {0.50, 0.32, 0.55},
                        ["HOLY_POWER"] =  {0.90, 0.80, 0.50},
                        ["AMMOSLOT"] =    {0.80, 0.60, 0.00},
                        ["FUEL"] =        {0.00, 0.55, 0.50},
                        ["ALTERNATE"] =   {0.00, 0.80, 0.80},
                    },
                    status = {
                        hostile =      {0.81, 0.20, 0.15},
                        neutral =      {0.90, 0.90, 0.20},
                        friendly =     {0.28, 0.85, 0.28},
                        damage =       {1, 0, 0},
                        incomingHeal = {1, 1, 0},
                        heal =         {0, 1, 0},
                        resting =      {0, 1, 0},
                        combat =       {1, 0, 0},
                        afk =          {1, 1, 0},
                        offline =      {0.6, 0.6, 0.6},
                        leader =       {0, 1, 1},
                        tapped =       {0.4, 0.4, 0.4},
                        pvpEnemy =     {1, 0, 0},
                        pvpFriendly =  {0, 1, 0},
                        dead =         {0.2, 0.2, 0.2},
                        rareelite =    {1, 0.5, 0},
                        elite =        {1, 1, 0},
                        rare =         {0.75, 0.75, 0.75},
                    },
                },
            },
        },
    })
    db = self.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char

    local otherFaction = nibRealUI:OtherFaction(nibRealUI.faction)

    self.layoutSize = ndb.settings.hudSize
    --print("Layout", self.layoutSize)


    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
    nibRealUI:RegisterHuDOptions(MODNAME, GetOptions)
    ---]]
end

function UnitFrames:OnEnable()
    self:SetoUFColors()
    self.colorStrings = {
        health = nibRealUI:ColorTableToStr(db.overlay.colors.health.normal),
        mana = nibRealUI:ColorTableToStr(db.overlay.colors.power["MANA"]),
    }

    nibRealUI:RegisterModForFade(MODNAME, db.misc.combatfade)
    self:InitializeLayout()
end
