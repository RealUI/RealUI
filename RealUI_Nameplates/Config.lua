local _, private = ...
local NP = private.NP

--[[ AceConfig panel. AceConfig is not bundled (kept out of the minimal lib set);
     the options register lazily when a config-capable environment is present —
     RealUI_Config or any addon embedding AceConfig-3.0 provides it. ]]--

local function RefreshAll()
    -- B163: aura containers re-apply their filters when they fall behind this.
    private.auraConfigGeneration = (private.auraConfigGeneration or 0) + 1
    local health = NP.db.profile.enemy.health
    for _, plate in _G.next, private.activeByUnit do
        -- Live dimensions first (beta feedback: sizes shouldn't need a reload),
        -- then let each element re-read its config.
        plate:SetSize(health.width, health.height)
        for _, element in _G.next, private.elements do
            if element.OnDimensionsChanged then element.OnDimensionsChanged(plate) end
        end
        for _, element in _G.next, private.elements do
            if element.Attach then element.Attach(plate, plate.unit) end
        end
        NP:UpdatePlateAlpha(plate)
    end
end

-- Path resolution starts at the first known profile root so the same options
-- table works standalone AND embedded deeper in RealUI's config tree (where
-- info[] carries extra parent keys like "nameplates").
local PROFILE_ROOTS = { enemy = true, friendly = true, alpha = true, target = true, font = true }
local function GetPath(info)
    local db = NP.db.profile
    local start = 1
    while info[start] and not PROFILE_ROOTS[info[start]] do
        start = start + 1
    end
    for i = start, #info - 1 do
        db = db[info[i]]
    end
    return db, info[#info]
end

local function Get(info)
    local db, key = GetPath(info)
    return db[key]
end

local function Set(info, value)
    local db, key = GetPath(info)
    db[key] = value
    RefreshAll()
end

local function GetColor(info)
    local db, key = GetPath(info)
    return db[key].r, db[key].g, db[key].b
end

local function SetColor(info, r, g, b)
    local db, key = GetPath(info)
    db[key].r, db[key].g, db[key].b = r, g, b
    RefreshAll()
end

local function AuraGroupOptions(displayName, order, maxCap)
    return {
        type = "group", name = displayName, inline = true, order = order,
        args = {
            enabled = { type = "toggle", name = "Enabled", order = 1 },
            max = { type = "range", name = "Max shown", min = 1, max = maxCap, step = 1, order = 2 },
            position = {
                type = "select", name = "Anchor", order = 3,
                values = private.auraPositionNames,
            },
            offset = {
                type = "group", name = "Offset", inline = true, order = 4,
                args = {
                    x = { type = "range", name = "X", min = -80, max = 80, step = 1, order = 1 },
                    y = { type = "range", name = "Y", min = -80, max = 80, step = 1, order = 2 },
                },
            },
        },
    }
end

--[[ B163: always-show / never-show spell lists for My debuffs.
     Spells are added by ID, or by name for anything in the player's spellbook
     (C_Spell.GetSpellInfo resolves names only for known spells). ]]
local function SpellLabel(spellID)
    local name = _G.C_Spell.GetSpellName(spellID) or _G.UNKNOWN
    local icon = _G.C_Spell.GetSpellTexture(spellID)
    return (icon and ("|T%s:16:16:0:0:64:64:4:60:4:60|t "):format(icon) or "") .. name .. " (" .. spellID .. ")"
end

local function ResolveSpellInput(text)
    text = text and _G.strtrim(text) or ""
    if text == "" then return end
    local info = _G.C_Spell.GetSpellInfo(_G.tonumber(text) or text)
    return info and info.spellID
end

local function SpellListOptions(listKey, displayName, desc, order)
    local selected
    local function List()
        return NP.db.profile.enemy.auras.myDebuffs[listKey]
    end
    return {
        type = "group", name = displayName, inline = true, order = order,
        args = {
            desc = { type = "description", name = desc, order = 0 },
            add = {
                type = "input", name = "Add spell", order = 1,
                desc = "Spell ID, or the name of a spell in your spellbook.",
                get = function() return "" end,
                set = function(_, text)
                    local spellID = ResolveSpellInput(text)
                    if spellID then
                        List()[spellID] = true
                        RefreshAll()
                    else
                        _G.print("|cff30d0ffRealUI Nameplates|r: no spell found for \"" .. _G.tostring(text) .. "\".")
                    end
                end,
            },
            spells = {
                type = "select", name = "Spells", order = 2,
                values = function()
                    local values = {}
                    for spellID, enabled in _G.next, List() do
                        if enabled then values[spellID] = SpellLabel(spellID) end
                    end
                    return values
                end,
                get = function() return selected end,
                set = function(_, spellID) selected = spellID end,
            },
            remove = {
                type = "execute", name = "Remove", order = 3,
                disabled = function() return not (selected and List()[selected]) end,
                func = function()
                    List()[selected] = nil
                    selected = nil
                    RefreshAll()
                end,
            },
        },
    }
end

local function MyDebuffOptions(order)
    local options = AuraGroupOptions("My debuffs", order, 12)
    local args = options.args
    args.show = {
        type = "select", name = "Show", order = 1.5,
        desc = "Important: the debuffs Blizzard marks as worth tracking for your class, the same list"
            .. " Blizzard's own nameplates use. Minor procs and secondary effects stay off the plate."
            .. "\n\nAll mine: every debuff you or your pet cast.",
        values = { important = "Important to my class", all = "All mine" },
        sorting = { "important", "all" },
    }
    args.sort = {
        type = "select", name = "Sort by", order = 1.6,
        desc = "Time remaining puts the debuff closest to running out first.",
        values = private.auraSortNames,
    }
    args.alwaysShow = SpellListOptions("alwaysShow", "Always show",
        "Shown even when Blizzard does not mark them as important. Only used with Show: Important.", 5)
    args.neverShow = SpellListOptions("neverShow", "Never show",
        "Hidden from this row whatever the Show setting. Wins over Always show.", 6)
    return options
end

local function BuildOptions()
    return {
        type = "group",
        name = "RealUI Nameplates",
        get = Get, set = Set,
        childGroups = "tab",
        args = {
            enemy = {
                type = "group", name = "Enemy", order = 10,
                args = {
                    health = {
                        type = "group", name = "Health bar", inline = true, order = 10,
                        args = {
                            width  = { type = "range", name = "Width",  min = 60, max = 220, step = 1, order = 1 },
                            height = { type = "range", name = "Height", min = 4,  max = 30,  step = 1, order = 2 },
                            absorb = { type = "toggle", name = "Absorb overlay", order = 3 },
                        },
                    },
                    execute = {
                        type = "group", name = "Execute range", inline = true, order = 20,
                        args = {
                            enabled   = { type = "toggle", name = "Enabled", order = 1 },
                            threshold = { type = "range", name = "Threshold", min = 0.1, max = 0.5, step = 0.05, isPercent = true, order = 2 },
                        },
                    },
                    classPower = {
                        type = "group", name = "Combo points / class power", inline = true, order = 25,
                        args = {
                            enabled = {
                                type = "toggle", name = "Enabled", order = 1,
                                desc = "Your combo points or class resource (holy power, chi, arcane charges, soul shards, essence) as pips along the bottom of your target's health bar.",
                            },
                            height = { type = "range", name = "Height", min = 2, max = 8, step = 1, order = 2 },
                        },
                    },
                    castbar = {
                        type = "group", name = "Castbar", inline = true, order = 30,
                        args = {
                            enabled = { type = "toggle", name = "Enabled", order = 1 },
                            icon    = { type = "toggle", name = "Cast icon", order = 2 },
                        },
                    },
                    auras = {
                        type = "group", name = "Auras", inline = true, order = 40,
                        args = {
                            size = {
                                type = "range", name = "Icon size", min = 12, max = 32, step = 1,
                                desc = "Requires a UI reload (button size is fixed at creation).",
                                order = 1,
                            },
                            myDebuffs    = MyDebuffOptions(2),
                            crowdControl = AuraGroupOptions("Crowd control", 3, 8),
                            buffs        = AuraGroupOptions("Dispellable/enrage buffs", 4, 8),
                        },
                    },
                    texts = {
                        type = "group", name = "Texts", inline = true, order = 50,
                        args = {
                            healthPercent = {
                                type = "toggle", name = "Health percent", order = 1,
                                desc = "Health percent right of the bar. Works in dungeons and raids too: it is read through the game's secret-safe percent API.",
                            },
                            healthValues  = {
                                type = "toggle", name = "Health values", order = 1.5,
                                desc = "Current and maximum health plus the percent (\"15.2K - 45.5K - 33%\"), inside the health bar.",
                            },
                            spellName     = { type = "toggle", name = "Cast spell name", order = 2 },
                            castTarget    = {
                                type = "toggle", name = "Cast target name", order = 3,
                                desc = "Shows who the cast is aimed at, in their class colour, on the right under the cast bar.",
                            },
                        },
                    },
                    markers = {
                        type = "group", name = "Markers", inline = true, order = 60,
                        args = {
                            quest    = { type = "toggle", name = "Quest objective", order = 1 },
                            raidIcon = { type = "toggle", name = "Raid target icon", order = 2 },
                            rare     = { type = "toggle", name = "Rare/elite", order = 3 },
                        },
                    },
                    colors = {
                        type = "group", name = "Colors", inline = true, order = 70,
                        get = GetColor, set = SetColor,
                        args = {
                            execute = { type = "color", name = "Execute", order = 1 },
                            cast    = { type = "color", name = "Casting", order = 2 },
                            tapped  = { type = "color", name = "Tapped", order = 3 },
                            threat = {
                                type = "group", name = "Threat", inline = true, order = 4,
                                args = {
                                    enabled    = { type = "toggle", name = "Threat coloring", get = Get, set = Set, order = 1 },
                                    warning    = { type = "color", name = "Warning", order = 2 },
                                    transition = { type = "color", name = "Transition", order = 3 },
                                    safe       = { type = "color", name = "Safe (tank)", order = 4 },
                                    offtank    = { type = "color", name = "Off-tank", order = 5 },
                                },
                            },
                        },
                    },
                },
            },
            friendly = {
                type = "group", name = "Friendly", order = 20,
                args = {
                    desc = { type = "description", name = "Friendly plates are name-only by design.", order = 0 },
                    showInInstances = {
                        type = "toggle", name = "Show in instances", order = 1,
                        desc = "Takes effect for newly shown plates.",
                    },
                    targetGlow = { type = "toggle", name = "Target glow", order = 2 },
                },
            },
            alpha = {
                type = "group", name = "Alpha", order = 30,
                args = {
                    outOfRange = { type = "range", name = "Out of range", min = 0.1, max = 1, step = 0.05, order = 1 },
                    noCombat   = { type = "range", name = "Not in combat", min = 0.1, max = 1, step = 0.05, order = 2 },
                    notTarget  = { type = "range", name = "Not target", min = 0.1, max = 1, step = 0.05, order = 3 },
                    casting    = { type = "range", name = "Casting (floor)", min = 0.1, max = 1, step = 0.05, order = 4 },
                },
            },
            target = {
                type = "group", name = "Target", order = 40,
                get = GetColor, set = SetColor,
                args = {
                    highlight = { type = "color", name = "Highlight color", order = 1 },
                },
            },
        },
    }
end

-- Public: RealUI_Config embeds this into the RealUI options tree.
function NP:GetConfigOptions()
    return BuildOptions()
end

local registered = false
local function EnsureRegistered()
    local registry = _G.LibStub("AceConfigRegistry-3.0", true)
    local dialog = _G.LibStub("AceConfigDialog-3.0", true)
    if not (registry and dialog) then return false end
    if not registered then
        registered = true
        registry:RegisterOptionsTable("RealUI_Nameplates", BuildOptions)
        dialog:AddToBlizOptions("RealUI_Nameplates", "RealUI Nameplates")
    end
    return true
end

function private.OpenConfig()
    if EnsureRegistered() then
        _G.LibStub("AceConfigDialog-3.0"):Open("RealUI_Nameplates")
    else
        _G.print("|cff30d0ffRealUI Nameplates|r: config requires AceConfig (load RealUI_Config or any Ace3 config addon).")
    end
end
