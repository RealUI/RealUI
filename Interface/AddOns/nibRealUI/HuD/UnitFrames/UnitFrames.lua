local _, private = ...

-- Lua Globals --
local _G = _G

-- Libs --
local oUF = _G.oUFembed

-- RealUI --
local RealUI = private.RealUI
local L = RealUI.L
local db, ndb

local CombatFader = RealUI:GetModule("CombatFader")

local MODNAME = "UnitFrames"
local UnitFrames = RealUI:NewModule(MODNAME, "AceEvent-3.0")

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
        return RealUI:AbbreviateName(name, NameLengths[self.layoutSize][unit] - 7)
    else
        return RealUI:AbbreviateName(name, NameLengths[self.layoutSize][unit] or 12)
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

-- Squelch taint popup
_G.hooksecurefunc("UnitPopup_OnClick",function(self)
    local button = self.value
    if button == "SET_FOCUS" or button == "CLEAR_FOCUS" then
        if _G.StaticPopup1 then
            _G.StaticPopup1:Hide()
        end
        if db.misc.focusclick then
            RealUI:Notification("RealUI", true, L["Alert_UseClickToSetFocus"]:format(db.misc.focusclick), nil, [[Interface\AddOns\nibRealUI\Media\Icons\Notification_Alert]])
        end
    elseif button == "PET_DISMISS" then
        if _G.StaticPopup1 then
            _G.StaticPopup1:Hide()
        end
    end
end)

----------------------------
------ Initialization ------
----------------------------
function UnitFrames:OnInitialize()
    ---[[
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            misc = {
                focusclick = true,
                focuskey = "shift",
                statusText = "smart",
                alwaysDisplayFullHealth = true,
                steppoints = {
                    ["default"] = {0.35, 0.25},
                    ["MAGE"]    = {0.9, 0.5},
                    ["HUNTER"]  = {0.8, 0.2},
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
            },
        },
    })
    db = self.db.profile
    ndb = RealUI.db.profile

    self.layoutSize = ndb.settings.hudSize
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function UnitFrames:OnEnable()
    -- Override the green that oUF uses
    oUF.colors.health = {0.66, 0.22, 0.22}
    oUF.colors.power.MANA = RealUI:ColorDesaturate(0.1, oUF.colors.power.MANA)
    oUF.colors.power.MANA = RealUI:ColorShift(-0.07, oUF.colors.power.MANA)

    CombatFader:RegisterModForFade(MODNAME, db.misc.combatfade)
    self:InitializeLayout()
end
