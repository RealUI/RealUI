local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db, ndb

local CombatFader = RealUI:GetModule("CombatFader")

local MODNAME = "UnitFrames"
local UnitFrames = RealUI:NewModule(MODNAME, "AceEvent-3.0")

UnitFrames.units = {}

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
        unit.Health.colorClass = db.overlay.classColor

        unit.Health:SetReversePercent(not ndb.settings.reverseUnitFrameBars)

        if unit.Power then
            unit.Power:UpdateReverse(ndb.settings.reverseUnitFrameBars)
        end

        if unit.DruidMana then
            unit.DruidMana:SetReverseFill(ndb.settings.reverseUnitFrameBars)
        end

        unit:UpdateAllElements(event)
    end
end

UnitFrames.steppoints = {
    default = {0.35, 0.25},
    health = {
        HUNTER  = {0.8, 0.2},
        PALADIN = {0.4, 0.2},
        WARRIOR = {0.35, 0.2},
    },
    power = {
        MAGE    = {0.7, 0.25},
        WARLOCK = {0.6, 0.4},
    },
}

----------------------------
------ Initialization ------
----------------------------
function UnitFrames:RefreshMod()
    db = self.db.profile
    ndb = RealUI.db.profile
    self.layoutSize = ndb.settings.hudSize

    self:RefreshUnits("RefreshMod")
end

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
                targettarget = {
                    size = {x = 138, y = 10},
                    position = {x = 0, y = 0},
                },
                focus = {
                    size = {x = 138, y = 10},
                    position = {x = 0, y = 0},
                },
                focustarget = {
                    size = {x = 126, y = 10},
                    position = {x = 0, y = 0},
                },
                pet = {
                    size = {x = 126, y = 10},
                    position = {x = 0, y = 0},
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
            -- TODO: Convert to FramePoint
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
    CombatFader:RegisterModForFade(MODNAME, "profile", "misc", "combatfade")
end

function UnitFrames:OnEnable()
    -- Override the green that oUF uses
    oUF.colors.health = {0.66, 0.22, 0.22}
    oUF.colors.power.MANA = RealUI.ColorDesaturate(0.1, oUF.colors.power.MANA)
    oUF.colors.power.MANA = RealUI.ColorShift(-0.07, oUF.colors.power.MANA)

    self:InitializeLayout()
end
