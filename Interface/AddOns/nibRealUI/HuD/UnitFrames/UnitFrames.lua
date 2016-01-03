local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = nibRealUI.L

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0")
local CombatFader = nibRealUI:GetModule("CombatFader")
local db, ndb, ndbc

local oUF = oUFembed
UnitFrames.units = {}

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
        color = nibRealUI:ColorDarken(0.15, color)
        color = nibRealUI:ColorDesaturate(0.2, color)
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
            nibRealUI:Notification("RealUI", true, L["Alert_UseClickToSetFocus"]:format(db.misc.focusclick), nil, [[Interface\AddOns\nibRealUI\Media\Icons\Notification_Alert]])
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
                        harmtarget = 0.85,
                        target = 0.75,
                        hurt = 0.6,
                        outofcombat = 0.25,
                    },
                },
            },
            units = {
                -- Eventually, these settings will be used to adjust unit frame size.
                player = {
                    size = {x = 259, y = 28},
                    position = {x = 0, y = 0},
                    healthHeight = 0.6, --percentage of the unit height used by the healthbar
                },
                target = {
                    size = {x = 259, y = 28},
                    position = {x = 0, y = 0},
                    healthHeight = 0.6, --percentage of the unit height used by the healthbar
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
end

function UnitFrames:OnEnable()
    self:SetoUFColors()
    self.colorStrings = {
        health = nibRealUI:ColorTableToStr(db.overlay.colors.health.normal),
        mana = nibRealUI:ColorTableToStr(db.overlay.colors.power["MANA"]),
    }

    CombatFader:RegisterModForFade(MODNAME, db.misc.combatfade)
    self:InitializeLayout()
end
