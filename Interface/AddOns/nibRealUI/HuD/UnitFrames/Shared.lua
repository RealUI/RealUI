local _, private = ...

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

-- Power types where the default state is empty
RealUI.ReversePowers = {
    ["RAGE"] = true,
    ["RUNIC_POWER"] = true,
    ["POWER_TYPE_SUN_POWER"] = true,
    ["LUNAR_POWER"] = true,
    ["INSANITY"] = true,
    ["MAELSTROM"] = true,
    ["FURY"] = true,
    ["PAIN"] = true,
}

function UnitFrames:PositionSteps(vert, horiz)
    UnitFrames:debug("PositionSteps")
    local width, height = self:GetSize()
    local point, relPoint = vert..horiz, vert..(horiz == "LEFT" and "RIGHT" or "LEFT")
    local stepPoints = UnitFrames.steppoints[self.barType][RealUI.class] or UnitFrames.steppoints.default
    for i = 1, 2 do
        local xOfs = round(stepPoints[i] * (width - 10))
        if self:GetReversePercent() then
            xOfs = (xOfs + height) * (horiz == "RIGHT" and 1 or -1)
            self.step[i]:SetPoint(point, self, relPoint, xOfs, 0)
            self.warn[i]:SetPoint(point, self, relPoint, xOfs, 0)
        else
            self.step[i]:SetPoint(point, self, -xOfs, 0)
            self.warn[i]:SetPoint(point, self, -xOfs, 0)
        end
    end
end
function UnitFrames:UpdateSteps(unit, cur, max)
    UnitFrames:debug("UnitFrames:UpdateSteps", unit, cur, max)
    --cur = max * .25
    --self:SetValue(cur)
    local percent = RealUI:GetSafeVals(cur, max)
    local stepPoints = UnitFrames.steppoints[self.barType][RealUI.class] or UnitFrames.steppoints.default
    for i = 1, 2 do
        --print(percent, unit, cur, max, self.colorClass)
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

function UnitFrames:PvPOverride(event, unit)
    UnitFrames:debug("PvP Override", self, event, unit, _G.IsPVPTimerRunning())
    local pvp, color = self.PvP
    local setColor = pvp.lines and pvp.SetBackgroundColor or pvp.SetVertexColor
    if _G.UnitIsPVP(unit) then
        local reaction = _G.UnitReaction(unit, "player")
        if not reaction then
            -- Can be nil if the target is out of range
            reaction = _G.UnitIsFriend(unit,"player") and 5 or 2
        end
        color = self.colors.reaction[reaction]
        setColor(pvp, color[1], color[2], color[3], color[4])
    else
        color = RealUI.media.background
        setColor(pvp, color[1], color[2], color[3], color[4])
    end
end

do -- UnitFrames:UpdateClassification
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

do -- UnitFrames:UpdateStatus
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

function UnitFrames:UpdateEndBox(...)
    UnitFrames:debug("UpdateEndBox", self and self.unit, ...)
    local unit, color = self.unit
    local _, class = _G.UnitClass(unit)
    if _G.UnitIsPlayer(unit) then
        color = RealUI:GetClassColor(class)
    else
        if ( not _G.UnitPlayerControlled(unit) and _G.UnitIsTapDenied(unit) ) then
            color = self.colors.tapped
        else
            color = self.colors.reaction[_G.UnitReaction(unit, "player")]
        end
    end
    self.endBox:Show()
    self.endBox:SetVertexColor(color[1], color[2], color[3], 1)
end

local function CreateHealthBar(parent, unit, info)
    local width, height = parent:GetWidth(), parent:GetHeight()
    if db.units[unit].healthHeight then
        height = round((height - 3) * db.units[unit].healthHeight)
    end
    local health = parent:CreateAngleFrame("Status", width, height, parent.overlay, info)
    health:SetPoint("TOP"..info.point, parent, 0, 0)
    health:SetMinMaxValues(0, 1)
    health:SetReverseFill(info.point == "RIGHT")
    health:SetReversePercent(not ndb.settings.reverseUnitFrameBars)

    if info.text then
        health.text = health:CreateFontString(nil, "OVERLAY")
        health.text:SetPoint("BOTTOM"..info.point, health, "TOP"..info.point, 2, 2)
        health.text:SetFontObject(_G.RealUIFont_Pixel)
        parent:Tag(health.text, "[realui:health]")
    end

    local stepHeight = round(height / 2)
    health.step = {}
    health.warn = {}
    for i = 1, 2 do
        health.step[i] = parent:CreateAngleFrame("Frame", stepHeight + 2, stepHeight, health, info)
        health.step[i]:SetBackgroundColor(.5, .5, .5, RealUI.media.background[4])

        health.warn[i] = parent:CreateAngleFrame("Frame", height + 2, height, health, info)
        health.warn[i]:SetBackgroundColor(.5, .5, .5, RealUI.media.background[4])
    end

    health.barType = "health"
    health.colorClass = db.overlay.classColor
    health.colorHealth = true
    health.frequentUpdates = true

    health.PositionSteps = UnitFrames.PositionSteps
    health.PostUpdate = UnitFrames.UpdateSteps
    parent.Health = health
end

local function CreatePowerBar(parent, unit, info)
    local width, height = round(parent:GetWidth() * 0.9), round((parent:GetHeight() - 3) * (1 - db.units[unit].healthHeight))
    local power = parent:CreateAngleFrame("Status", width, height, parent.overlay, info)
    local _, powerType = _G.UnitPowerType(parent.unit)
    power:SetPoint("BOTTOM"..info.point, parent, info.point == "RIGHT" and -5 or 5, 0)
    power:SetMinMaxValues(0, 1)
    power:SetReverseFill(info.point == "RIGHT")
    if ndb.settings.reverseUnitFrameBars then
        power:SetReversePercent(RealUI.ReversePowers[powerType])
    else
        power:SetReversePercent(not RealUI.ReversePowers[powerType])
    end

    power.text = power:CreateFontString(nil, "OVERLAY")
    power.text:SetPoint("TOP"..info.point, power, "BOTTOM"..info.point, 2, -3)
    power.text:SetFontObject(_G.RealUIFont_Pixel)
    parent:Tag(power.text, "[realui:power]")

    local stepHeight = round(height * .6)
    power.step = {}
    power.warn = {}
    for i = 1, 2 do
        power.step[i] = parent:CreateAngleFrame("Frame", stepHeight + 2, stepHeight, power, info)
        power.step[i]:SetBackgroundColor(.5, .5, .5, RealUI.media.background[4])

        power.warn[i] = parent:CreateAngleFrame("Frame", height + 2, height, power, info)
        power.warn[i]:SetBackgroundColor(.5, .5, .5, RealUI.media.background[4])
    end

    power.barType = "power"
    power.colorPower = true
    power.frequentUpdates = true

    power.PositionSteps = UnitFrames.PositionSteps
    function power:PostUpdate(unitToken, cur, max, min)
        UnitFrames.UpdateSteps(self, unitToken, cur, max)
        local _, pType = _G.UnitPowerType(parent.unit)
        if pType ~= powerType then
            powerType = pType
            if ndb.settings.reverseUnitFrameBars then
                power:SetReversePercent(RealUI.ReversePowers[powerType])
            else
                power:SetReversePercent(not RealUI.ReversePowers[powerType])
            end
        end
    end
    parent.Power = power
end

-- Init
local function Shared(self, unit)
    UnitFrames:debug("Shared", self, self.unit, unit)

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

    local unitData = UnitFrames[unit]
    local unitDB = db.units[unit]
    self:SetSize(unitDB.size.x, unitDB.size.y)
    CreateHealthBar(self, unit, unitData.health)
    if unitData.power then
        CreatePowerBar(self, unit, unitData.power)
    end

    unitData.create(self)

    if unitData.hasCastBars and RealUI:GetModuleEnabled("CastBars") then
        RealUI:GetModule("CastBars"):CreateCastBars(self, unit)
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

