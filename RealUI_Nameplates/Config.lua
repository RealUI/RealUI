local _, private = ...
local NP = private.NP

--[[ AceConfig panel. AceConfig is not bundled (kept out of the minimal lib set);
     the options register lazily when a config-capable environment is present —
     RealUI_Config or any addon embedding AceConfig-3.0 provides it. ]]--

local function RefreshAll()
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
                            myDebuffs    = AuraGroupOptions("My debuffs", 2, 12),
                            crowdControl = AuraGroupOptions("Crowd control", 3, 8),
                            buffs        = AuraGroupOptions("Dispellable/enrage buffs", 4, 8),
                        },
                    },
                    texts = {
                        type = "group", name = "Texts", inline = true, order = 50,
                        args = {
                            healthPercent = {
                                type = "toggle", name = "Health percent", order = 1,
                                desc = "Shown whenever the game exposes health values to addons. In instanced combat WoW 12 withholds them (secret values), so the text hides and returns when combat ends — this is a game restriction, not a bug.",
                            },
                            spellName     = { type = "toggle", name = "Cast spell name", order = 2 },
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
