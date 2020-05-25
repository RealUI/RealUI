local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db, ndb

local UnitFrames = RealUI:GetModule("UnitFrames")
local CombatFader = RealUI:GetModule("CombatFader")
local round = RealUI.Round

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
local function GetVertices(info, useOther)
    local side = info.point
    if useOther then
        side = side == "RIGHT" and "LEFT" or "RIGHT"
    end

    if side == "RIGHT" then
        return (info.rightVertex % 2) + 1, info.rightVertex
    else
        return info.leftVertex, (info.leftVertex % 2) + 3
    end
end

local function CreateSteps(parent, height, info)
    local stepHeight = round(height / 2)
    local step, warn = {}, {}

    for i = 1, 2 do
        local leftVertex, rightVertex = GetVertices(info)
        local s = parent:CreateAngle("Frame", nil, parent.overlay)
        s:SetSize(2, stepHeight)
        s:SetAngleVertex(leftVertex, rightVertex)
        s:SetBackgroundColor(.5, .5, .5)
        step[i] = s

        local w = parent:CreateAngle("Frame", nil, parent.overlay)
        w:SetSize(2, height)
        w:SetAngleVertex(leftVertex, rightVertex)
        w:SetBackgroundColor(.5, .5, .5)
        warn[i] = w
    end
    return step, warn
end
local function PositionSteps(self, vert)
    local width, height = self:GetSize()
    local isRight = self:GetReverseFill()
    local point, relPoint = vert..(isRight and "RIGHT" or "LEFT"), vert..(isRight and "LEFT" or "RIGHT")
    local stepPoints = UnitFrames.steppoints[self.barType][RealUI.charInfo.class.token] or UnitFrames.steppoints.default
    for i = 1, 2 do
        local xOfs = round(stepPoints[i] * (width - 10))
        if self:GetReversePercent() then
            xOfs = (xOfs + height) * (isRight and 1 or -1)
            self.step[i]:SetPoint(point, self, relPoint, xOfs, 0)
            self.warn[i]:SetPoint(point, self, relPoint, xOfs, 0)
        else
            xOfs = xOfs * (isRight and -1 or 1)
            self.step[i]:SetPoint(point, self, xOfs, 0)
            self.warn[i]:SetPoint(point, self, xOfs, 0)
        end
    end
end
local function UpdateSteps(self, unit, cur, max)
    UnitFrames:debug("UnitFrames:UpdateSteps", unit, cur, max)
    --cur = max * .25
    --self:SetValue(cur)
    local percent = RealUI.GetSafeVals(cur, max)
    local stepPoints = UnitFrames.steppoints[self.barType][RealUI.charInfo.class.token] or UnitFrames.steppoints.default
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

local function CreateHealthBar(parent, info)
    local width, height = parent:GetWidth(), parent:GetHeight()
    if db.units[parent.unit].healthHeight then
        height = round((height - 3) * db.units[parent.unit].healthHeight)
    end
    local Health = parent:CreateAngle("StatusBar", nil, parent.overlay)
    Health:SetSize(width, height)
    Health:SetPoint("TOP"..info.point, parent)
    Health:SetReverseFill(info.point == "RIGHT")
    Health:SetReversePercent(not ndb.settings.reverseUnitFrameBars)
    Health:SetAngleVertex(info.leftVertex, info.rightVertex)

    if info.text then
        Health.text = Health:CreateFontString(nil, "OVERLAY")
        Health.text:SetPoint("BOTTOM"..info.point, Health, "TOP"..info.point, 2, 2)
        Health.text:SetFontObject("SystemFont_Shadow_Med1_Outline")
        parent:Tag(Health.text, "[realui:health]")
    end

    Health.step, Health.warn = CreateSteps(parent, height, info)
    Health.barType = "health"
    Health.colorClass = db.overlay.classColor
    Health.colorTapping = true
    Health.colorDisconnected = true
    Health.colorHealth = true

    Health.PositionSteps = PositionSteps
    Health.PostUpdate = UpdateSteps
    parent.Health = Health
end
local CreateHealthStatus do
    local classification = {
        rareelite = {r=1, g=0.5, b=0},
        elite = {r=1, g=1, b=0},
        rare = {r=0.75, g=0.75, b=0.75},
    }

    local function UpdatePvP(self, event, unit)
        local PvPIndicator, color = self.PvPIndicator
        if _G.UnitIsPVP(unit) then
            local reaction = _G.UnitReaction(unit, "player")
            if not reaction then
                -- Can be nil if the target is out of range
                reaction = _G.UnitIsFriend(unit,"player") and 5 or 2
            end
            color = self.colors.reaction[reaction]
            PvPIndicator:SetBackgroundColor(color[1], color[2], color[3], color[4])
        else
            PvPIndicator:SetBackgroundColor(_G.Aurora.Color.frame:GetRGBA())
        end
    end
    local function UpdateClassification(self, event)
        local color = classification[_G.UnitClassification(self.unit)] or _G.Aurora.Color.frame
        self.Classification:SetBackgroundColor(color.r, color.g, color.b, color.a)
    end

    function CreateHealthStatus(parent, info)
        local leftVertex, rightVertex = GetVertices(info)
        local width, height = 4, _G.ceil(parent.Health:GetHeight() * 0.65)
        local PvPIndicator = parent:CreateAngle("Frame", nil, parent.Health)
        PvPIndicator:SetSize(width, height)
        PvPIndicator:SetPoint("TOP"..info.point, parent.Health, info.point == "RIGHT" and -8 or 8, 0)
        PvPIndicator:SetAngleVertex(leftVertex, rightVertex)

        PvPIndicator.Override = UpdatePvP
        parent.PvP = PvPIndicator

        if not (parent.unit == "player" or parent.unit == "pet") then
            local class = parent:CreateAngle("Frame", nil, parent.Health)
            class:SetSize(width, height)
            class:SetPoint("TOP"..info.point, parent.Health, info.point == "RIGHT" and -16 or 16, 0)
            class:SetAngleVertex(leftVertex, rightVertex)

            class.Update = UpdateClassification
            parent.Classification = class
            parent:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", UpdateClassification)
        end
    end
end

local CreateHealthPredictBar do
    local function PredictOverride(self, event, unit)
        if(self.unit ~= unit) then return end

        local hp = self.HealthPrediction
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

        local overAbsorb, atMax
        if healthBar:GetReversePercent() then
            if (totalAbsorb >= health) then
                overAbsorb = true

                if (allIncomingHeal > myCurrentHealAbsorb) then
                    totalAbsorb = _G.max(0, health - myCurrentHealAbsorb + allIncomingHeal)
                else
                    totalAbsorb = _G.max(0, health)
                end
            end
            atMax = health == maxHealth
        else
            if (health - myCurrentHealAbsorb + allIncomingHeal + totalAbsorb >= maxHealth or health + totalAbsorb >= maxHealth) then
                if (totalAbsorb > 0) then
                    overAbsorb = true
                end

                if (allIncomingHeal > myCurrentHealAbsorb) then
                    totalAbsorb = _G.max(0, maxHealth - (health - myCurrentHealAbsorb + allIncomingHeal))
                else
                    totalAbsorb = _G.max(0, maxHealth - health)
                end
            end
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
            hp.absorbBar:SetMinMaxValues(0, maxHealth)
            hp.absorbBar:SetValue(totalAbsorb)
            hp.absorbBar:ClearAllPoints()
            local fill = healthBar:GetStatusBarTexture()
            if healthBar:GetReverseFill() then
                if atMax then
                    hp.absorbBar:SetPoint("TOPRIGHT", healthBar)
                else
                    hp.absorbBar:SetPoint("TOPRIGHT", fill, "TOPLEFT", fill:GetHeight(), 0)
                end
                if overAbsorb then
                    hp.absorbBar:SetPoint("TOPLEFT", healthBar)
                end
            else
                if atMax then
                    hp.absorbBar:SetPoint("TOPLEFT", healthBar)
                else
                    hp.absorbBar:SetPoint("TOPLEFT", fill, "TOPRIGHT", -fill:GetHeight(), 0)
                end
                if overAbsorb then
                    hp.absorbBar:SetPoint("TOPRIGHT", healthBar)
                end
            end
        end

        if (hp.healAbsorbBar) then
            hp.healAbsorbBar:SetMinMaxValues(0, maxHealth)
            hp.healAbsorbBar:SetValue(myCurrentHealAbsorb)
        end
    end
    function CreateHealthPredictBar(parent, info)
        local width, height = parent.Health:GetSize()
        local absorbBar = parent:CreateAngle("StatusBar", nil, parent.Health)
        absorbBar:SetSize(width, height)
        absorbBar:SetBackgroundColor(0, 0, 0, 0)
        absorbBar:SetBackgroundBorderColor(0, 0, 0, 0)
        absorbBar:SetStatusBarColor(1, 1, 1, db.overlay.bar.opacity.absorb)
        absorbBar:SetAngleVertex(info.leftVertex, info.rightVertex)
        absorbBar:SetReverseFill(parent.Health:GetReverseFill())
        absorbBar:SetFrameLevel(parent.Health:GetFrameLevel())

        parent.HealthPrediction = {
            absorbBar = absorbBar,
            Override = PredictOverride,
        }
    end
end

local function CreatePowerBar(parent, info)
    local width, height = round(parent:GetWidth() * 0.9), round((parent:GetHeight() - 3) * (1 - db.units[parent.unit].healthHeight))
    local xOffset = parent.Health:GetHeight() - height

    local Power = parent:CreateAngle("StatusBar", nil, parent.overlay)
    Power:SetSize(width, height)
    Power:SetPoint("BOTTOM"..info.point, parent, info.point == "RIGHT" and -xOffset or xOffset, 0)
    Power:SetAngleVertex(info.leftVertex, info.rightVertex)
    Power:SetReverseFill(info.point == "RIGHT")

    Power.text = Power:CreateFontString(nil, "OVERLAY")
    Power.text:SetPoint("TOP"..info.point, Power, "BOTTOM"..info.point, 2, -3)
    Power.text:SetFontObject("SystemFont_Shadow_Med1_Outline")
    parent:Tag(Power.text, "[realui:power]")

    Power.step, Power.warn = CreateSteps(parent, height, info)
    Power.barType = "power"
    Power.colorPower = true
    Power.frequentUpdates = true

    local powerType
    function Power:UpdateReverse(setReverse)
        if setReverse then
            Power:SetReversePercent(RealUI.ReversePowers[powerType])
        else
            Power:SetReversePercent(not RealUI.ReversePowers[powerType])
        end
    end
    Power.PositionSteps = PositionSteps
    function Power:PostUpdate(unit, cur, min, max)
        UpdateSteps(self, unit, cur, max)
        local _, pType = _G.UnitPowerType(parent.unit)
        if pType ~= powerType then
            powerType = pType
            Power:UpdateReverse()
        end
    end
    parent.Power = Power
end
local CreatePowerStatus do
    local status = {
        afk = {1, 1, 0},
        offline = oUF.colors.disconnected,
        leader = {0, 1, 1},
        combat = {1, 0, 0},
        resting = {0, 1, 0},
    }
    local function UpdateStatus(self, event)
        local unit, color = self.unit

        if _G.UnitIsAFK(unit) then
            self.LeaderIndicator.status = "afk"
        elseif not(_G.UnitIsConnected(unit)) then
            self.LeaderIndicator.status = "offline"
        elseif _G.UnitIsGroupLeader(unit) then
            self.LeaderIndicator.status = "leader"
        else
            self.LeaderIndicator.status = false
        end

        if self.LeaderIndicator.status then
            color = status[self.LeaderIndicator.status]
            self.LeaderIndicator:SetBackgroundColor(color[1], color[2], color[3], color[4])
            self.LeaderIndicator:Show()
        else
            self.LeaderIndicator:Hide()
        end

        if _G.UnitAffectingCombat(unit) then
            self.CombatIndicator.status = "combat"
        elseif _G.IsResting(unit) then
            self.CombatIndicator.status = "resting"
        else
            self.CombatIndicator.status = false
        end

        if self.LeaderIndicator.status and not self.CombatIndicator.status then
            self.CombatIndicator:SetBackgroundColor(_G.Aurora.Color.frame:GetRGBA())
            self.CombatIndicator:Show()
        elseif self.CombatIndicator.status then
            color = status[self.CombatIndicator.status]
            self.CombatIndicator:SetBackgroundColor(color[1], color[2], color[3], color[4])
            self.CombatIndicator:Show()
        else
            self.CombatIndicator:Hide()
        end
    end

    function CreatePowerStatus(parent, data)
        local point, anchor, relPoint, x, info
        if data.power then
            info, anchor = data.power, parent.Power
        else
            info, anchor = data.health, parent.Health
        end
        if info.point == "LEFT" then
            point, relPoint, x = "TOPLEFT", "TOPRIGHT", -8
        else
            point, relPoint, x = "TOPRIGHT", "TOPLEFT", 8
        end
        local leftVertex, rightVertex = GetVertices(info, not data.isBig)
        local width, height = 4, anchor:GetHeight()


        local CombatRest = parent:CreateAngle("Frame", nil, anchor)
        CombatRest:SetSize(width, height)
        CombatRest:SetPoint(point, anchor, relPoint, x, 0)
        CombatRest:SetAngleVertex(leftVertex, rightVertex)
        CombatRest.Override = UpdateStatus
        parent.CombatIndicator = CombatRest
        parent.RestingIndicator = CombatRest

        local LeaderAFK = parent:CreateAngle("Frame", nil, anchor)
        LeaderAFK:SetSize(width, height)
        LeaderAFK:SetPoint(point, CombatRest, relPoint, x, 0)
        LeaderAFK:SetAngleVertex(leftVertex, rightVertex)
        LeaderAFK.Override = UpdateStatus
        parent.LeaderIndicator = LeaderAFK
        parent.AwayIndicator = LeaderAFK
    end
end

local CreateEndBox do
    local function UpdateEndBox(self, ...)
        local unit = self.unit

        local color
        if _G.UnitIsPlayer(unit) or _G.UnitPlayerControlled(unit) and not _G.UnitIsPlayer(unit) then
            local _, classToken = _G.UnitClass(unit)
            color = self.colors.class[classToken]
        elseif not _G.UnitPlayerControlled(unit) and _G.UnitIsTapDenied(unit) then
            color = self.colors.tapped
        elseif _G.UnitReaction(unit, "player") then
            color = self.colors.reaction[_G.UnitReaction(unit, "player")]
        else
            color = self.colors.selection[_G.UnitSelectionType(unit, true)]
        end

        for i = 1, #self.EndBox do
            self.EndBox[i]:SetBackgroundColor(color[1], color[2], color[3], 1)
        end
    end
    function CreateEndBox(parent, data)
        local height = parent.Health:GetHeight()
        local boxHeight = height + (data.isBig and 2 or 0)
        local boxWidth = data.isBig and 6 or 4
        local point, relPoint, x
        if data.health.point == "RIGHT" then
            point, relPoint, x = "TOPLEFT", "TOPRIGHT", -(height - 2)
        else
            point, relPoint, x = "TOPRIGHT", "TOPLEFT", (height - 2)
        end
        parent.EndBox = {
            Update = UpdateEndBox
        }

        local healthBox = parent:CreateAngle("Frame", nil, parent.Health)
        healthBox:SetSize(boxWidth, boxHeight)
        healthBox:SetPoint(point, parent.Health, relPoint, x, 0)
        healthBox:SetAngleVertex(GetVertices(data.health))
        parent.EndBox[1] = healthBox

        if data.isBig then
            height = parent.Power:GetHeight()
            boxHeight = height + 2
            boxWidth = data.isBig and 6 or 4
            if data.power.point == "RIGHT" then
                point, relPoint, x = "BOTTOMLEFT", "BOTTOMRIGHT", -(height - 2)
            else
                point, relPoint, x = "BOTTOMRIGHT", "BOTTOMLEFT", (height - 2)
            end
            local powerBox = parent:CreateAngle("Frame", nil, parent.Power)
            powerBox:SetSize(boxWidth, boxHeight)
            powerBox:SetPoint(point, parent.Power, relPoint, x, 0)
            powerBox:SetAngleVertex(GetVertices(data.power))
            parent.EndBox[2] = powerBox

            -- hide the line between the two boxes
            healthBox.bottom:Hide()
            powerBox.top:Hide()
        end
    end
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
    local sizeMod = UnitFrames.layoutSize == 1 and 0.85 or 1

    local width, height = round(unitDB.size.x * sizeMod), round(unitDB.size.y * sizeMod)
    unitData.nameLength = width / 10

    self:SetSize(width, height)
    CreateHealthBar(self, unitData.health)
    CreateHealthStatus(self, unitData.health)
    if unitData.isBig then
        CreateHealthPredictBar(self, unitData.health)
        CreatePowerBar(self, unitData.power)
    end
    CreatePowerStatus(self, unitData)
    CreateEndBox(self, unitData)

    unitData.create(self)

    if unitData.hasCastBars and RealUI:GetModuleEnabled("CastBars") then
        RealUI:GetModule("CastBars"):CreateCastBars(self, unit, unitData)
    end


    function self.PreUpdate(frame, event)
        frame.Health:SetSmooth(false)
        if frame.Power then
            frame.Power:SetSmooth(false)
        end
        if unitData.PreUpdate then
            unitData.PreUpdate(frame, event)
        end
    end

    function self.PostUpdate(frame, event)
        frame.Health:SetSmooth(true)
        frame.Health:PositionSteps(unitData.issmall and "BOTTOM" or "TOP")
        if frame.Power then
            frame.Power:SetSmooth(true)
            frame.Power:PositionSteps("BOTTOM")
        end
        if frame.Classification then
            frame.Classification.Update(frame, event)
        end
        frame.EndBox.Update(frame, event)
        if unitData.PostUpdate then
            unitData.PostUpdate(frame, event)
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

