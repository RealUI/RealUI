local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local db, ndb, ndbc

local oUF = oUFembed

UnitFrames.textures = {
    [1] = {
        F1 = { -- Player / Target Frames
            health = {
                width = 222,
                height = 13,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Surround]=],
            },
            power = {
                width = 197,
                height = 8,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Surround]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_HealthBox_Surround]=],
            },
            statusBox = { -- Combat, Resting, Leader, AFK
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_StatusBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_StatusBox_Surround]=],
            },
        },
        F2 = { -- Focus / Target Target
            health = {
                width = 116,
                height = 9,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_Health_Surround]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_HealthBox_Surround]=],
            },
            statusBox = { -- Combat, Resting, Leader, AFK
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_StatusBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_StatusBox_Surround]=],
            },
        },
        F3 = { -- Focus Target / Pet
            health = {
                width = 222,
                height = 13,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_Health_Surround]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_HealthBox_Surround]=],
            },
        },
    },
    [2] = {
        F1 = { -- Player / Target Frames
            health = {
                width = 259,
                height = 15,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Surround]=],
            },
            power = {
                width = 230,
                height = 10,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Surround]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_HealthBox_Surround]=],
            },
            statusBox = { -- Combat, Resting, Leader, AFK
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_StatusBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_StatusBox_Surround]=],
            },
        },
        F2 = { -- Focus / Target Target
            health = {
                width = 138,
                height = 10,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_Health_Surround]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_HealthBox_Surround]=],
            },
            statusBox = { -- Combat, Resting, Leader, AFK
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_StatusBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_StatusBox_Surround]=],
            },
        },
        F3 = { -- Focus Target / Pet
            health = {
                width = 222,
                height = 13,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_Health_Surround]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_HealthBox_Surround]=],
            },
        },
    },
}

local ReversePowers = {
    ["RAGE"] = true,
    ["RUNIC_POWER"] = true,
    ["POWER_TYPE_SUN_POWER"] = true,
}

function UnitFrames:HealthOverride(event, unit)
    --self.Health.bar.reverse = true
    --print("Health Override", self, event, unit)
    local healthPer = nibRealUI:GetSafeVals(UnitHealth(unit), UnitHealthMax(unit))
    AngleStatusBar:SetBarColor(self.Health.bar, db.overlay.colors.health.normal)
    AngleStatusBar:SetValue(self.Health.bar, healthPer, majorUpdate)
end

function UnitFrames:PowerOverride(event, unit, powerType)
    --print("Power Override", self, event, unit, powerType)
    local _, unitPower = UnitPowerType(unit)
    if ReversePowers[unitPower] then
        --print("Reverse")
        self.Power.bar.reverse = true
        AngleStatusBar:SetReverseDirection(self.Power.bar, "LEFT", -2, -1)
    else
        --print("Not reverse")
        self.Power.bar.reverse = false
        AngleStatusBar:SetReverseDirection(self.Power.bar)
    end
    if powerType and (unitPower == powerType) then
        AngleStatusBar:SetBarColor(self.Power.bar, db.overlay.colors.power[powerType])
    else
        AngleStatusBar:SetBarColor(self.Power.bar, db.overlay.colors.power[unitPower])
    end
    local powerPer = nibRealUI:GetSafeVals(UnitPower(unit), UnitPowerMax(unit))
    AngleStatusBar:SetValue(self.Power.bar, powerPer, majorUpdate)
end

-- Init
function UnitFrames:InitShared()
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char
end
