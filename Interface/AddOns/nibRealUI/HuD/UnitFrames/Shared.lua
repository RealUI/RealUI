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
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Step]=],
                warn = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Health_Warning]=],
            },
            power = {
                width = 197,
                height = 8,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Step]=],
                warn = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Power_Warning]=],
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
            endBox = { -- Tapped, Hostile, Friendly
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_EndBox_Surround]=],
            },
        },
        F2 = { -- Focus / Target Target
            health = {
                width = 116,
                height = 9,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_Health_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_Health_Step]=],
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
            endBox = { -- Tapped, Hostile, Friendly
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F2_EndBox_Surround]=],
            },
        },
        F3 = { -- Focus Target / Pet
            health = {
                width = 105,
                height = 9,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_Health_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_Health_Step]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_HealthBox_Surround]=],
            },
            endBox = { -- Tapped, Hostile, Friendly
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F3_EndBox_Surround]=],
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
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Step]=],
                warn = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Health_Warning]=],
            },
            power = {
                width = 230,
                height = 10,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Step]=],
                warn = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Power_Warning]=],
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
            endBox = { -- Tapped, Hostile, Friendly
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_EndBox_Surround]=],
            },
        },
        F2 = { -- Focus / Target Target
            health = {
                width = 138,
                height = 10,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_Health_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_Health_Step]=],
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
            endBox = { -- Tapped, Hostile, Friendly
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F2_EndBox_Surround]=],
            },
        },
        F3 = { -- Focus Target / Pet
            health = {
                width = 126,
                height = 10,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_Health_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_Health_Surround]=],
                step = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_Health_Step]=],
            },
            healthBox = { -- PvP Status / Classification
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_HealthBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_HealthBox_Surround]=],
            },
            endBox = { -- Tapped, Hostile, Friendly
                width = 16,
                height = 16,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_EndBox_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F3_EndBox_Surround]=],
            },
        },
    },
}

local ReversePowers = {
    ["RAGE"] = true,
    ["RUNIC_POWER"] = true,
    ["POWER_TYPE_SUN_POWER"] = true,
}

local function updateSteps(unit, type, percent, frame)
    local stepPoints, texture = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
    if unit == "player" or unit == "target" then
        texture = UnitFrames.textures[UnitFrames.layoutSize].F1[type]
    elseif unit == "focus" or unit == "targettarget" then
        texture = UnitFrames.textures[UnitFrames.layoutSize].F2[type]
    elseif unit == "focustarget" or unit == "pet" then
        texture = UnitFrames.textures[UnitFrames.layoutSize].F3[type]
    end
    for i = 1, 2 do
        --print(percent, unit, type)
        if frame.bar.reverse then
            if percent > stepPoints[i] and (unit == "player" or unit == "target") then
                frame.steps[i]:SetTexture(texture.warn)
            else
                frame.steps[i]:SetTexture(texture.step)
            end
        else
            if percent < stepPoints[i] and (unit == "player" or unit == "target") then
                frame.steps[i]:SetTexture(texture.warn)
            else
                frame.steps[i]:SetTexture(texture.step)
            end
        end
    end
end

function UnitFrames:HealthOverride(event, unit)
    --print("Health Override", self, event, unit)
    local healthPer = nibRealUI:GetSafeVals(UnitHealth(unit), UnitHealthMax(unit))
    updateSteps(unit, "health", healthPer, self.Health)
    AngleStatusBar:SetBarColor(self.Health.bar, db.overlay.colors.health.normal)
    AngleStatusBar:SetValue(self.Health.bar, healthPer, majorUpdate)
end

function UnitFrames:PowerOverride(event, unit, powerType)
    --print("Power Override", self, event, unit, powerType)
    --if unit == "target" then return end
    local _, unitPower = UnitPowerType(unit)
    self.Power.bar.reverse = ReversePowers[unitPower] or false
    if powerType and (unitPower == powerType) then
        AngleStatusBar:SetBarColor(self.Power.bar, db.overlay.colors.power[powerType])
    else
        AngleStatusBar:SetBarColor(self.Power.bar, db.overlay.colors.power[unitPower])
    end
    local powerPer = nibRealUI:GetSafeVals(UnitPower(unit), UnitPowerMax(unit))
    updateSteps(unit, "power", powerPer, self.Power)
    AngleStatusBar:SetValue(self.Power.bar, powerPer, majorUpdate)
end

function UnitFrames:UpdateStatus(event, ...)
    --print("UpdateStatus", self, event, ...)
    local unit = self.unit
    if UnitIsAFK(unit) then
        --print("AFK", self, event, unit)
        self.Leader:Show()
        self.AFK:Show()
        self.Leader:SetVertexColor(db.overlay.colors.status.afk[1], db.overlay.colors.status.afk[2], db.overlay.colors.status.afk[3], db.overlay.colors.status.afk[4])
        self.Leader.status = "afk"
    elseif not(UnitIsConnected(unit)) then
        --print("Offline", self, event, unit)
        self.Leader:Show()
        self.AFK:Show()
        self.Leader:SetVertexColor(db.overlay.colors.status.offline[1], db.overlay.colors.status.offline[2], db.overlay.colors.status.offline[3], db.overlay.colors.status.offline[4])
        self.Leader.status = "offline"
    elseif true then--UnitIsGroupLeader(unit)
        --print("Leader", self, event, unit)
        self.Leader:Show()
        self.AFK:Show()
        self.Leader:SetVertexColor(db.overlay.colors.status.leader[1], db.overlay.colors.status.leader[2], db.overlay.colors.status.leader[3], db.overlay.colors.status.leader[4])
        self.Leader.status = "leader"
    else
        --print("Status2: None", self, event, unit)
        self.Leader:Hide()
        self.AFK:Hide()
        self.Leader:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
        self.Leader.status = false
    end

    if UnitAffectingCombat(unit) then
        --print("Combat", self, event, unit)
        self.Combat:Show()
        self.Resting:Show()
        self.Combat:SetVertexColor(db.overlay.colors.status.combat[1], db.overlay.colors.status.combat[2], db.overlay.colors.status.combat[3], db.overlay.colors.status.combat[4])
        self.Combat.status = "combat"
    elseif IsResting(unit) then
        --print("Resting", self, event, unit)
        self.Combat:Show()
        self.Resting:Show()
        self.Combat:SetVertexColor(db.overlay.colors.status.resting[1], db.overlay.colors.status.resting[2], db.overlay.colors.status.resting[3], db.overlay.colors.status.resting[4])
        self.Combat.status = "resting"
    else
        --print("Status1: None", self, event, unit)
        self.Combat:Hide()
        self.Resting:Hide()
        self.Combat:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
        self.Combat.status = false
    end
end

function UnitFrames:UpdateEndBox(self, ...)
    --print("UpdateEndBox", self and self.unit, ...)
    local unit, color = self.unit
    local _, class = UnitClass(unit)
    if UnitIsPlayer(unit) then
        color = nibRealUI:GetClassColor(class)
    else
        if ( not UnitPlayerControlled(unit) and UnitIsTapped(unit) and not UnitIsTappedByPlayer(unit) and not UnitIsTappedByAllThreatList(unit) ) then
            color = db.overlay.colors.status.tapped
        elseif UnitIsEnemy("player", unit) then
            color = db.overlay.colors.status.hostile
        elseif UnitCanAttack("player", unit) then
            color = db.overlay.colors.status.neutral
        else
            color = db.overlay.colors.status.friendly
        end
    end
    self.endBox:Show()
    self.endBox:SetVertexColor(color[1], color[2], color[3], 1)
end

-- Init
function UnitFrames:InitShared()
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char
end
