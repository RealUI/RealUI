local _, private = ...

-- Lua Globals --
local _G = _G

-- Libs --
local oUF = _G.oUFembed

-- RealUI --
local RealUI = private.RealUI
local db, ndb

local UnitFrames = RealUI:GetModule("UnitFrames")
local AngleStatusBar = RealUI:GetModule("AngleStatusBar")
local CombatFader = RealUI:GetModule("CombatFader")


local round = RealUI.Round
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
            tanking = {
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Tanking_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Tanking_Surround]=],
            },
            range = {
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Range_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\1\F1_Range_Surround]=],
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
            tanking = {
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Tanking_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Tanking_Surround]=],
            },
            range = {
                width = 32,
                height = 32,
                bar = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Range_Bar]=],
                border = [=[Interface\AddOns\nibRealUI\HuD\UnitFrames\Media\2\F1_Range_Surround]=],
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

RealUI.ReversePowers = {
    ["RAGE"] = true,
    ["RUNIC_POWER"] = true,
    ["POWER_TYPE_SUN_POWER"] = true,
    ["LUNAR_POWER"] = true,
    ["INSANITY"] = true,
    ["MAELSTROM"] = true,
    --["FURY"] = true,
    ["PAIN"] = true,
}

function UnitFrames:PositionSteps(vert)
    UnitFrames:debug("PositionSteps")
    local width, height = self:GetSize()
    local point, relPoint = vert.."RIGHT", vert.."LEFT"
    local stepPoints = db.misc.steppoints[RealUI.class] or db.misc.steppoints["default"]
    for i = 1, 2 do
        local xOfs = round(stepPoints[i] * (width - 10))
        if self:GetReversePercent() then
            xOfs = xOfs + height
            self.step[i]:SetPoint(point, self, relPoint, xOfs, 0)
            self.warn[i]:SetPoint(point, self, relPoint, xOfs, 0)
        else
            self.step[i]:SetPoint(point, self, -xOfs, 0)
            self.warn[i]:SetPoint(point, self, -xOfs, 0)
        end
    end
end
function UnitFrames:UpdateSteps(unit, min, max)
    --min = max * .25
    --self:SetValue(min)
    local percent = RealUI:GetSafeVals(min, max)
    local stepPoints = db.misc.steppoints[RealUI.class] or db.misc.steppoints["default"]
    for i = 1, 2 do
        --print(percent, unit, min, max, self.colorClass)
        if self:GetReversePercent() then
            --print("step reverse")
            if percent > stepPoints[i] then
                self.step[i]:SetAlpha(1)
                self.warn[i]:SetAlpha(0)
            else
                self.step[i]:SetAlpha(0)
                self.warn[i]:SetAlpha(1)
            end
        else
            --print("step normal")
            if percent < stepPoints[i] then
                self.step[i]:SetAlpha(0)
                self.warn[i]:SetAlpha(1)
            else
                self.step[i]:SetAlpha(1)
                self.warn[i]:SetAlpha(0)
            end
        end
    end
end

local function updateSteps(unit, type, percent, frame)
    local stepPoints, texture = db.misc.steppoints[RealUI.class] or db.misc.steppoints["default"], nil
    local isLargeFrame = false
    if _G.UnitInVehicle("player") then
        if unit == "player" and type == "power" then
            return
        end
        if unit == "vehicle" or unit == "target" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F1[type]
            isLargeFrame = true
        elseif unit == "focus" or unit == "targettarget" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F2[type]
        elseif unit == "focustarget" or unit == "pet" or unit == "player" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F3[type]
        end
    else
        if unit == "player" or unit == "target" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F1[type]
            isLargeFrame = true
        elseif unit == "focus" or unit == "targettarget" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F2[type]
        elseif unit == "focustarget" or unit == "pet" then
            texture = UnitFrames.textures[UnitFrames.layoutSize].F3[type]
        end
    end
    for i = 1, 2 do
        if frame.step then
            --print(percent, unit, type, frame:GetParent().unit)
            if frame.bar.reverse then
                --print("step reverse")
                if percent > stepPoints[i] and isLargeFrame then
                    frame.step[i]:SetAlpha(type == "power" and 0 or 1)
                    frame.warn[i]:SetAlpha(type == "power" and 1 or 0)
                else
                    frame.step[i]:SetAlpha(type == "power" and 1 or 0)
                    frame.warn[i]:SetAlpha(type == "power" and 0 or 1)
                end
            else
                --print("step normal")
                if percent < stepPoints[i] and isLargeFrame then
                    frame.step[i]:SetAlpha(0)
                    frame.warn[i]:SetAlpha(1)
                else
                    frame.step[i]:SetAlpha(1)
                    frame.warn[i]:SetAlpha(0)
                end
            end
        else
            --print(percent, unit, type, frame:GetParent().unit)
            if frame.bar.reverse then
                --print("step reverse")
                if percent > stepPoints[i] and isLargeFrame then
                    frame.steps[i]:SetTexture(type == "power" and texture.warn or texture.step)
                else
                    frame.steps[i]:SetTexture(type == "power" and texture.step or texture.warn)
                end
            else
                --print("step normal")
                if percent < stepPoints[i] and isLargeFrame then
                    frame.steps[i]:SetTexture(texture.warn)
                else
                    frame.steps[i]:SetTexture(texture.step)
                end
            end
        end
    end
end

function UnitFrames:HealthOverride(event, unit)
    UnitFrames:debug("Health Override", self, event, unit)
    local health = self.Health
    if event == "ClassColorBars" then
        UnitFrames:SetHealthColor(self)
    elseif event == "ReverseBars" then
        AngleStatusBar:SetReverseFill(health.bar, ndb.settings.reverseUnitFrameBars)
    end
    local healthPer, healthCurr, healthMax = RealUI:GetSafeVals(_G.UnitHealth(unit), _G.UnitHealthMax(unit))
    updateSteps(unit, "health", healthPer, health)
    if health.SetValue then
        health:SetMinMaxValues(0, healthMax)
        health:SetValue(healthCurr)
    else
        AngleStatusBar:SetValue(health.bar, healthPer)
    end
end

function UnitFrames:PredictOverride(event, unit)
    if(self.unit ~= unit) then return end
    UnitFrames:debug("PredictOverride", self, event, unit)
    
    local reverseUnitFrameBars = ndb.settings.reverseUnitFrameBars
    local hp = self.HealPrediction
    local healthBar = self.Health

    local myIncomingHeal = _G.UnitGetIncomingHeals(unit, 'player') or 0
    local allIncomingHeal = _G.UnitGetIncomingHeals(unit) or 0
    local totalAbsorb = _G.UnitGetTotalAbsorbs(unit) or 0
    local myCurrentHealAbsorb = _G.UnitGetTotalHealAbsorbs(unit) or 0
    local health, maxHealth = _G.UnitHealth(unit), _G.UnitHealthMax(unit)

    --local overHealAbsorb = false
    if (health < myCurrentHealAbsorb) then
        --overHealAbsorb = true
        myCurrentHealAbsorb = health
    end

    if (health - myCurrentHealAbsorb + allIncomingHeal > maxHealth * hp.maxOverflow) then
        allIncomingHeal = maxHealth * hp.maxOverflow - health + myCurrentHealAbsorb
    end

    local otherIncomingHeal = 0
    if (allIncomingHeal < myIncomingHeal) then
        myIncomingHeal = allIncomingHeal
    else
        otherIncomingHeal = allIncomingHeal - myIncomingHeal
    end

    local overAbsorb, atMax = false
    if reverseUnitFrameBars then
        UnitFrames:debug("reverseUnitFrameBars")
        if (health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth) then
            UnitFrames:debug("Check over absorb", totalAbsorb)
            if (totalAbsorb > 0) then
                overAbsorb = true
            end

            if (allIncomingHeal > myCurrentHealAbsorb) then
                totalAbsorb = _G.max(0, maxHealth - (health - myCurrentHealAbsorb + allIncomingHeal))
            else
                totalAbsorb = _G.max(0, maxHealth - health)
            end
        end
    else
        UnitFrames:debug("not reverseUnitFrameBars")
        if (totalAbsorb >= health) then
            UnitFrames:debug("Check over absorb", totalAbsorb)
            overAbsorb = true

            if (allIncomingHeal > myCurrentHealAbsorb) then
                totalAbsorb = _G.max(0, health - myCurrentHealAbsorb + allIncomingHeal)
            else
                totalAbsorb = _G.max(0, health)
            end
        end
        atMax = health == maxHealth
    end

    if (myCurrentHealAbsorb > allIncomingHeal) then
        myCurrentHealAbsorb = myCurrentHealAbsorb - allIncomingHeal
    else
        myCurrentHealAbsorb = 0
    end

    if (hp.myBar) then
        hp.myBar:SetMinMaxValues(0, maxHealth)
        hp.myBar:SetValue(myIncomingHeal)
    end

    if (hp.otherBar) then
        hp.otherBar:SetMinMaxValues(0, maxHealth)
        hp.otherBar:SetValue(otherIncomingHeal)
    end

    if (hp.absorbBar) then
        UnitFrames:debug("Update absorbBar", maxHealth, totalAbsorb, overAbsorb, atMax)
        if hp.absorbBar.SetValue then
            hp.absorbBar:SetMinMaxValues(0, maxHealth)
            hp.absorbBar:SetValue(totalAbsorb)
        else
            AngleStatusBar:SetValue(hp.absorbBar, 1 - (_G.min(totalAbsorb, health) / maxHealth), true)
        end
        hp.absorbBar:ClearAllPoints()
        if unit == "player" then
            if atMax then
                hp.absorbBar:SetPoint("TOPRIGHT", healthBar, -2, 0)
            else
                hp.absorbBar:SetPoint("TOPRIGHT", healthBar.bar, "TOPLEFT", healthBar.bar:GetHeight() - 2, 0)
            end
            if overAbsorb then
                hp.absorbBar:SetPoint("TOPLEFT", healthBar, 2, 0)
            end
        else
            if atMax then
                hp.absorbBar:SetPoint("TOPLEFT", healthBar, 2, -1)
            else
                hp.absorbBar:SetPoint("TOPLEFT", healthBar.bar, "TOPRIGHT", 0, 0)
            end
            if overAbsorb then
                hp.absorbBar:SetPoint("TOPRIGHT", healthBar, 2, -1)
            end
        end
    end

    if (hp.healAbsorbBar) then
        hp.healAbsorbBar:SetMinMaxValues(0, maxHealth)
        hp.healAbsorbBar:SetValue(myCurrentHealAbsorb)
    end
end


function UnitFrames:PowerOverride(event, unit, powerType)
    UnitFrames:debug("Power Override", self, event, unit, powerType)
    --if not self.Power.enabled then return end

    local powerPer, powerCurr, powerMax = RealUI:GetSafeVals(_G.UnitPower(unit), _G.UnitPowerMax(unit))
    updateSteps(unit, "power", powerPer, self.Power)
    if self.Power.SetValue then
        self.Power:SetMinMaxValues(0, powerMax)
        self.Power:SetValue(powerCurr)
    else
        AngleStatusBar:SetValue(self.Power.bar, powerPer)
    end
end

function UnitFrames:PvPOverride(event, unit)
    UnitFrames:debug("PvP Override", self, event, unit, _G.IsPVPTimerRunning())
    local pvp, color = self.PvP
    local setColor = pvp.lines and pvp.SetBackgroundColor or pvp.SetVertexColor
    if _G.UnitIsPVP(unit) then
        color = self.colors.reaction[_G.UnitReaction(unit, "player")]
        setColor(pvp, color[1], color[2], color[3], color[4])
    else
        color = RealUI.media.background
        setColor(pvp, color[1], color[2], color[3], color[4])
    end
end

do
    local classification = {
        rareelite = {1, 0.5, 0},
        elite = {1, 1, 0},
        rare = {0.75, 0.75, 0.75},
    }
    function UnitFrames:UpdateClassification(event)
        UnitFrames:debug("Classification", self.unit, event, _G.UnitClassification(self.unit))
        local color = classification[_G.UnitClassification(self.unit)] or RealUI.media.background
        self.Class:SetVertexColor(color[1], color[2], color[3], color[4])
    end
end

do
    local status = {
        afk = {1, 1, 0},
        offline = oUF.colors.disconnected,
        leader = {0, 1, 1},
        combat = {1, 0, 0},
        resting = {0, 1, 0},
    }
    function UnitFrames:UpdateStatus(event, ...)
        UnitFrames:debug("UpdateStatus", self.unit, event, ...)
        local unit, color = self.unit
        
        if _G.UnitIsAFK(unit) then
            self.Leader.status = "afk"
        elseif not(_G.UnitIsConnected(unit)) then
            self.Leader.status = "offline"
        elseif _G.UnitIsGroupLeader(unit) then
            self.Leader.status = "leader"
        else
            self.Leader.status = false
        end
        UnitFrames:debug("Status2:", self.Leader.status)

        if self.Leader.status then
            color = status[self.Leader.status]
            self.Leader:SetVertexColor(color[1], color[2], color[3], color[4])
            self.Leader:Show()
            self.AFK:Show()
        else
            self.Leader:Hide()
            self.AFK:Hide()
        end

        if _G.UnitAffectingCombat(unit) then
            self.Combat.status = "combat"
        elseif _G.IsResting(unit) then
            self.Combat.status = "resting"
        else
            self.Combat.status = false
        end
        UnitFrames:debug("Status1:", self.Combat.status)

        if self.Leader.status and not self.Combat.status then
            color = RealUI.media.background
            self.Combat:SetVertexColor(color[1], color[2], color[3], color[4])
            self.Combat:Show()
            self.Resting:Show()
        elseif self.Combat.status then
            color = status[self.Combat.status]
            self.Combat:SetVertexColor(color[1], color[2], color[3], color[4])
            self.Combat:Show()
            self.Resting:Show()
        else
            self.Combat:Hide()
            self.Resting:Hide()
        end
    end
end

local UnitIsTapDenied
if RealUI.isBeta then
    UnitIsTapDenied = _G.UnitIsTapDenied
else
    UnitIsTapDenied = function(unit)
        return _G.UnitIsTapped(unit) and not _G.UnitIsTappedByPlayer(unit) and not _G.UnitIsTappedByAllThreatList(unit)
    end
end

function UnitFrames:UpdateEndBox(...)
    UnitFrames:debug("UpdateEndBox", self and self.unit, ...)
    local unit, color = self.unit
    local _, class = _G.UnitClass(unit)
    if _G.UnitIsPlayer(unit) then
        color = RealUI:GetClassColor(class)
    else
        if ( not _G.UnitPlayerControlled(unit) and UnitIsTapDenied(unit) ) then
            color = self.colors.tapped
        else
            color = self.colors.reaction[_G.UnitReaction(unit, "player")]
        end
    end
    self.endBox:Show()
    self.endBox:SetVertexColor(color[1], color[2], color[3], 1)
end

function UnitFrames:SetHealthColor(unitFrame)
    local healthColor
    if db.overlay.classColor and (unitFrame.unit ~= "player") and _G.UnitIsPlayer(unitFrame.unit) then
        local _, class = _G.UnitClass(unitFrame.unit)
        healthColor = RealUI:GetClassColor(class)
        healthColor = RealUI:ColorDarken(0.15, healthColor)
        healthColor = RealUI:ColorDesaturate(0.2, healthColor)
    else
        healthColor = unitFrame.colors.health
    end
    AngleStatusBar:SetBarColor(unitFrame.Health.bar, healthColor)
end

-- Dropdown Menu
local dropdown = _G.CreateFrame("Frame", "RealUIUnitFramesDropDown", _G.UIParent, "UIDropDownMenuTemplate")

_G.hooksecurefunc("UnitPopup_OnClick",function(self)
    local button = self.value
    if button == "SET_FOCUS" or button == "CLEAR_FOCUS" then
        if _G.StaticPopup1 then
            _G.StaticPopup1:Hide()
        end
        if db.misc.focusclick then
            RealUI:Notification("RealUI", true, "Use "..db.misc.focuskey.."+click to set Focus.", nil, [[Interface\AddOns\nibRealUI\Media\Icons\Notification_Alert]])
        end
    elseif button == "PET_DISMISS" then
        if _G.StaticPopup1 then
            _G.StaticPopup1:Hide()
        end
    end
end)
local function menu(self)
    dropdown:SetParent(self)
    return _G.ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
end
local init = function(self)
    local unit = self:GetParent().unit
    local menuType, name, id

    if (not unit) then
        return
    end

    if (_G.UnitIsUnit(unit, "player")) then
        menuType = "SELF"
    elseif (_G.UnitIsUnit(unit, "vehicle")) then
        menuType = "VEHICLE"
    elseif (_G.UnitIsUnit(unit, "pet")) then
        menuType = "PET"
    elseif (_G.UnitIsPlayer(unit)) then
        id = _G.UnitInRaid(unit)
        if(id) then
            menuType = "RAID_PLAYER"
            name = _G.GetRaidRosterInfo(id)
        elseif(_G.UnitInParty(unit)) then
            menuType = "PARTY"
        else
            menuType = "PLAYER"
        end
    else
        menuType = "TARGET"
        name = _G.RAID_TARGET_ICON
    end

    if (menuType) then
        _G.UnitPopup_ShowMenu(self, menuType, unit, name, id)
    end
end
_G.UIDropDownMenu_Initialize(dropdown, init, "MENU")

-- Init
local function Shared(self, unit)
    UnitFrames:debug("Shared", self, self.unit, unit)
    self.menu = menu

    self:SetScript("OnEnter", _G.UnitFrame_OnEnter)
    self:SetScript("OnLeave", _G.UnitFrame_OnLeave)
    self:RegisterForClicks("AnyUp")

    if db.misc.focusclick then
        local ModKey = db.misc.focuskey
        local MouseButton = 1
        local key = ModKey .. "-type" .. (MouseButton or "")
        if(self.unit == "focus") then
            self:SetAttribute(key, "macro")
            self:SetAttribute("macrotext", "/clearfocus")
        else
            self:SetAttribute(key, "focus")
        end
    end

    -- Create a proxy frame for the CombatFader to avoid taint city.
    self.overlay = _G.CreateFrame("Frame", nil, self)
    self.overlay:SetFrameStrata("BACKGROUND")
    CombatFader:RegisterFrameForFade("UnitFrames", self.overlay)

    -- TODO: combine duplicate frame creation. eg healthbar, endbox, etc.
    --[[ Idea:
        local info = info[unit]
        CreateHealthBar(self, info.health)
        CreatePvPStatus(self, info.health)
        if info.predict then
            CreatePredictBar(self, info.health)
        end
        if info.power then
            CreatePowerBar(self, info.power)
        end
        CreatePowerStatus(self, info.power or info.health)
        CreateEndBox(self, info.health)
    ]]

    -- This would be all unit specific stuff, eg. Totems, stats, threat
    UnitFrames[unit](self)

    if RealUI:GetModuleEnabled("CastBars") and (unit == "player" or unit == "target" or unit == "focus") then
        RealUI:GetModule("CastBars"):CreateCastBars(self, unit)
    end
    local PointTracking = RealUI:GetModule("PointTracking")
    if PointTracking:IsEnabled() and unit == "player" then
        if RealUI.class == "DEATHKNIGHT" then
            PointTracking:CreateRunes(self, unit)
        else
            PointTracking:CreateClassIcons(self, unit)
            if not RealUI.isBeta and RealUI.class == "WARLOCK" then
                PointTracking:CreateBurningEmbers(self, unit)
            end
        end
    end
end

function UnitFrames:InitializeLayout()
    db = UnitFrames.db.profile
    ndb = RealUI.db.profile

    oUF:RegisterStyle("RealUI", Shared)
    oUF:SetActiveStyle("RealUI")

    for i = 1, #UnitFrames.units do
        UnitFrames.units[i]()
    end
end

