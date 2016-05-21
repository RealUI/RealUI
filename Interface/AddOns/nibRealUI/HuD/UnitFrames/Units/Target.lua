local _, private = ...

-- Lua Globals --
local _G = _G

-- Libs --
local oUF = _G.oUFembed
local RC = _G.LibStub("LibRangeCheck-2.0")

-- RealUI --
local RealUI = private.RealUI
local db, ndb

local UnitFrames = RealUI:GetModule("UnitFrames")
local AngleStatusBar = RealUI:GetModule("AngleStatusBar")

local positions = {
    [1] = {
        health = {
            x = 2,
            widthOfs = 13,
            coords = {1, 0.1328125, 0.1875, 1},
        },
        power = {
            x = 7,
            widthOfs = 10,
            coords = {1, 0.23046875, 0, 0.5},
        },
        healthBox = {1, 0, 0, 1},
        statusBox = {1, 0, 0, 1},
        endBox = {
            x = 10,
            y = -4,
            coords = {1, 0, 0, 1},
        },
        tanking = {
            x = 0,
            y = 1,
        },
        range = {
            x = 0,
            y = 2,
        }
    },
    [2] = {
        health = {
            x = 2,
            widthOfs = 15,
            coords = {1, 0.494140625, 0.0625, 1},
        },
        power = {
            x = 9,
            widthOfs = 12,
            coords = {1, 0.1015625, 0, 0.625},
        },
        healthBox = {1, 0, 0, 1},
        statusBox = {1, 0, 0, 1},
        endBox = {
            x = 11,
            y = -2,
            coords = {1, 0, 0, 1},
        },
        tanking = {
            x = 0,
            y = 2,
        },
        range = {
            x = 0,
            y = 3,
        }
    },
}

local function CreateHealthBar(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.health
    local pos = positions[UnitFrames.layoutSize].health
    parent.Health = _G.CreateFrame("Frame", nil, parent.overlay)
    parent.Health:SetPoint("TOPLEFT", parent, 0, 0)
    parent.Health:SetSize(texture.width, texture.height)

    parent.Health.bar = AngleStatusBar:NewBar(parent.Health, pos.x, -1, texture.width - pos.widthOfs - 2, texture.height - 2, "RIGHT", "RIGHT", "RIGHT", true)
    if ndb.settings.reverseUnitFrameBars then
        AngleStatusBar:SetReverseFill(parent.Health.bar, true)
    end
    UnitFrames:SetHealthColor(parent)

    parent.Health.bg = parent.Health:CreateTexture(nil, "BACKGROUND")
    parent.Health.bg:SetTexture(texture.bar)
    parent.Health.bg:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.Health.bg:SetVertexColor(RealUI.media.background[1], RealUI.media.background[2], RealUI.media.background[3], RealUI.media.background[4])
    parent.Health.bg:SetAllPoints(parent.Health)

    parent.Health.border = parent.Health:CreateTexture(nil, "BORDER")
    parent.Health.border:SetTexture(texture.border)
    parent.Health.border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.Health.border:SetAllPoints(parent.Health)

    parent.Health.text = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.Health.text:SetPoint("BOTTOMLEFT", parent.Health, "TOPLEFT", 0, 2)
    parent.Health.text:SetFontObject(_G.RealUIFont_Pixel)
    parent.Health.text:SetJustifyH("LEFT")
    parent:Tag(parent.Health.text, "[realui:health]")

    local stepPoints = db.misc.steppoints[RealUI.class] or db.misc.steppoints["default"]
    parent.Health.steps = {}
    for i = 1, 2 do
        parent.Health.steps[i] = parent.Health:CreateTexture(nil, "OVERLAY")
        parent.Health.steps[i]:SetTexCoord(1, 0, 0, 1)
        parent.Health.steps[i]:SetSize(16, 16)
        if not parent.Health.bar.reverse then
        parent.Health.steps[i]:SetPoint("TOPRIGHT", parent.Health, -(_G.floor(stepPoints[i] * texture.width) - 6), 0)
        else
            parent.Health.steps[i]:SetPoint("TOPLEFT", parent.Health, _G.floor(stepPoints[i] * texture.width) - 6, 0)
        end
    end

    parent.Health.frequentUpdates = true
    parent.Health.Override = UnitFrames.HealthOverride
end

local function CreatePredictBar(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.health
    local pos = positions[UnitFrames.layoutSize].health
    local absorbBar = AngleStatusBar:NewBar(parent.Health, pos.x, -1, texture.width - pos.widthOfs - 2, texture.height - 2, "RIGHT", "RIGHT", "RIGHT", true)
    AngleStatusBar:SetBarColor(absorbBar, 1, 1, 1, db.overlay.bar.opacity.absorb)

    parent.HealPrediction = {
        absorbBar = absorbBar,
        frequentUpdates = true,
        Override = UnitFrames.PredictOverride,
    }
end

local function CreateHealthStatus(parent) -- PvP/Classification
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.healthBox
    local coords = positions[UnitFrames.layoutSize].healthBox
    local status = {}
    for i = 1, 2 do
        status[i] = {}
        status[i].bg = parent.Health:CreateTexture(nil, "OVERLAY", nil, 1)
        status[i].bg:SetTexture(texture.bar)
        status[i].bg:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        status[i].bg:SetSize(texture.width, texture.height)

        status[i].border = parent.Health:CreateTexture(nil, "OVERLAY", nil, 3)
        status[i].border:SetTexture(texture.border)
        status[i].border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        status[i].border:SetAllPoints(status[i].bg)

        if i == 1 then
            status[i].bg:SetPoint("TOPLEFT", parent.Health, 8, -1)
            parent.PvP = status[i].bg
            parent.PvP.Override = UnitFrames.PvPOverride
        else
            status[i].bg:SetPoint("TOPLEFT", parent.Health, 16, -1)
            parent.Class = status[i].bg
            parent.Class.Update = UnitFrames.UpdateClassification
        end
    end
end

local function CreatePowerBar(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.power
    local pos = positions[UnitFrames.layoutSize].power
    parent.Power = _G.CreateFrame("Frame", nil, parent.overlay)
    parent.Power:SetPoint("BOTTOMLEFT", parent, 5, 0)
    parent.Power:SetSize(texture.width, texture.height)

    parent.Power.bar = AngleStatusBar:NewBar(parent.Power, pos.x, -1, texture.width - pos.widthOfs, texture.height - 2, "LEFT", "LEFT", "RIGHT", true)

    ---[[
    parent.Power.bg = parent.Power:CreateTexture(nil, "BACKGROUND")
    parent.Power.bg:SetTexture(texture.bar)
    parent.Power.bg:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.Power.bg:SetVertexColor(RealUI.media.background[1], RealUI.media.background[2], RealUI.media.background[3], RealUI.media.background[4])
    parent.Power.bg:SetAllPoints(parent.Power)
    ---]]

    parent.Power.border = parent.Power:CreateTexture(nil, "BORDER")
    parent.Power.border:SetTexture(texture.border)
    parent.Power.border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.Power.border:SetAllPoints(parent.Power)

    parent.Power.text = parent.Power:CreateFontString(nil, "OVERLAY")
    parent.Power.text:SetPoint("TOPLEFT", parent.Power, "BOTTOMLEFT", 0, -3)
    parent.Power.text:SetFontObject(_G.RealUIFont_Pixel)
    parent:Tag(parent.Power.text, "[realui:power]")

    parent.Power.steps = {}
    for i = 1, 2 do
        parent.Power.steps[i] = parent.Power:CreateTexture(nil, "OVERLAY")
        parent.Power.steps[i]:SetTexture(texture.warn)
        parent.Power.steps[i]:SetTexCoord(1, 0, 0, 1)
        parent.Power.steps[i]:SetSize(16, 16)
        --power.steps[i]:SetPoint("BOTTOMRIGHT", power, -(floor(stepPoints[i] * texture.width) - 6), 0)
    end

    parent.Power.frequentUpdates = true
    parent.Power.Override = UnitFrames.PowerOverride
end

local function CreatePowerStatus(parent) -- Combat, AFK, etc.
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.statusBox
    local coords = positions[UnitFrames.layoutSize].healthBox
    local status = {}
    for i = 1, 2 do
        status.bg = parent.Power:CreateTexture(nil, "BORDER")
        status.bg:SetTexture(texture.bar)
        status.bg:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        status.bg:SetSize(texture.width, texture.height)

        status.border = parent.Power:CreateTexture(nil, "OVERLAY", nil, 3)
        status.border:SetTexture(texture.border)
        status.border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        status.border:SetAllPoints(status.bg)

        status.bg.Override = UnitFrames.UpdateStatus
        status.border.Override = UnitFrames.UpdateStatus

        if i == 1 then
            status.bg:SetPoint("TOPLEFT", parent.Power, "TOPRIGHT", -8, 0)
            parent.Combat = status.bg
            parent.Resting = status.border
        else
            status.bg:SetPoint("TOPLEFT", parent.Power, "TOPRIGHT", -2, 0)
            parent.Leader = status.bg
            parent.AFK = status.border
        end
    end
end

local function CreateRange(parent)
    local RangeColors = {
        [5] = RealUI.media.colors.green,
        [30] = RealUI.media.colors.yellow,
        [35] = RealUI.media.colors.amber,
        [40] = RealUI.media.colors.orange,
        [50] = RealUI.media.colors.red,
        [100] = RealUI.media.colors.red,
    }

    -- parent.Range = parent.Health:CreateTexture(nil, "OVERLAY")
    -- parent.Range:SetTexture(RealUI.media.icons.DoubleArrow)
    -- parent.Range:SetSize(16, 16)
    -- parent.Range:SetPoint("BOTTOMRIGHT", parent.Health, "BOTTOMLEFT", -5, 0)

    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.range
    local pos = positions[UnitFrames.layoutSize].range

    parent.Range = parent.overlay:CreateTexture(nil, "BORDER")
    parent.Range:SetTexture(texture.bar)
    parent.Range:SetSize(texture.width, texture.height)
    parent.Range:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", pos.x, pos.y)
    parent.Range.insideAlpha = 1
    parent.Range.outsideAlpha = 0.5

    parent.Range.border = parent.overlay:CreateTexture(nil, "OVERLAY", nil, 3)
    parent.Range.border:SetTexture(texture.border)
    parent.Range.border:SetAllPoints(parent.Range)

    parent.Range.text = parent.overlay:CreateFontString(nil, "OVERLAY")
    parent.Range.text:SetFontObject(_G.RealUIFont_Pixel)
    parent.Range.text:SetJustifyH("right")
    parent.Range.text:SetPoint("BOTTOMRIGHT", parent.Range, "BOTTOMLEFT", 20.5, 4.5)

    parent.Range.Override = function(self, status)
        --print("Range Override", self, status)
        local minRange, maxRange = RC:GetRange("target")

        if (_G.UnitIsUnit("player", "target")) or (minRange and minRange > 80) then maxRange = nil end
        local section
        if maxRange and not(self.Threat.isActive) then
            if maxRange <= 5 then
                section = 5
            elseif maxRange <= 30 then
                section = 30
            elseif maxRange <= 35 then
                section = 35
            elseif maxRange <= 40 then
                section = 40
            elseif maxRange <= 50 then
                section = 50
            else
                section = 100
            end
            self.Range.text:SetFormattedText("%d", maxRange)
            self.Range.text:SetTextColor(RangeColors[section][1], RangeColors[section][2], RangeColors[section][3])
            self.Range:SetVertexColor(RangeColors[section][1], RangeColors[section][2], RangeColors[section][3])
            self.Range:Show()
            self.Range.border:Show()
        else
            self.Range.text:SetText("")
            self.Range:Hide()
            self.Range.border:Hide()
        end
    end
end

local function CreateThreat(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.tanking
    local pos = positions[UnitFrames.layoutSize].tanking

    parent.Threat = parent.overlay:CreateTexture(nil, "BORDER")
    parent.Threat:SetTexture(texture.bar)
    parent.Threat:SetSize(texture.width, texture.height)
    parent.Threat:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", pos.x, pos.y)

    parent.Threat.border = parent.overlay:CreateTexture(nil, "OVERLAY", nil, 3)
    parent.Threat.border:SetTexture(texture.border)
    parent.Threat.border:SetAllPoints(parent.Threat)

    parent.Threat.text = parent.overlay:CreateFontString(nil, "OVERLAY")
    parent.Threat.text:SetFontObject(_G.RealUIFont_Pixel)
    parent.Threat.text:SetJustifyH("right")
    parent.Threat.text:SetPoint("BOTTOMRIGHT", parent.Threat, "BOTTOMLEFT", 14.5, 4.5)

    parent.Threat.isActive = false

    parent.Threat.Override = function(self, event, unit)
        --print("Threat Override", self, event, unit)
        local isTanking, status, _, rawPercentage = _G.UnitDetailedThreatSituation("player", "target")

        if (rawPercentage and (rawPercentage >= 0.8)) and not(_G.UnitIsDeadOrGhost(unit)) and (_G.GetNumGroupMembers() > 0) then
            local r, g, b
            if (status and status > 0) then
                r, g, b = _G.GetThreatStatusColor(status)
            elseif rawPercentage >= 0.9 then
                r, g, b = _G.GetThreatStatusColor(0)
            else
                r, g, b = 0, 1, 0
            end
            self.Threat:SetVertexColor(r, g, b)
            self.Threat.text:SetTextColor(r, g, b)

            local tankLead
            if isTanking then
                tankLead = _G.UnitThreatPercentageOfLead("player", "target")
            end
            self.Threat.text:SetFormattedText("%d%%", tankLead or rawPercentage)

            self.Threat:Show()
            self.Threat.border:Show()
            self.Range:Hide()
            self.Range.border:Hide()
            self.Threat.isActive = true
        else
            self.Threat.text:SetText("")
            self.Threat:Hide()
            self.Threat.border:Hide()
            self.Threat.isActive = false
        end
    end
end

local function CreateEndBox(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.endBox
    local pos = positions[UnitFrames.layoutSize].endBox
    parent.endBox = parent.overlay:CreateTexture(nil, "BORDER")
    parent.endBox:SetTexture(texture.bar)
    parent.endBox:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.endBox:SetSize(texture.width, texture.height)
    parent.endBox:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", pos.x, pos.y)

    local border = parent.overlay:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    border:SetAllPoints(parent.endBox)

    parent.endBox.Update = UnitFrames.UpdateEndBox
end

UnitFrames["target"] = function(self)
    CreateHealthBar(self)
    CreatePredictBar(self)
    CreateHealthStatus(self)
    CreatePowerBar(self)
    CreateRange(self)
    CreateThreat(self)
    CreateEndBox(self)
    CreatePowerStatus(self)

    self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -12, 2)
    self.Name:SetFontObject(_G.RealUIFont_Pixel)
    self:Tag(self.Name, "[realui:level] [realui:name]")

    self.RaidIcon = self:CreateTexture(nil, "OVERLAY")
    self.RaidIcon:SetSize(20, 20)
    self.RaidIcon:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", -10, 4)

    self:SetSize(self.Health:GetWidth(), self.Health:GetHeight() + self.Power:GetHeight() + 3)

    function self.PreUpdate(frame, event)
        --frame.Combat.Override(frame, event)
        frame.Class.Update(frame, event)
        frame.endBox.Update(frame, event)
        frame.Threat.Override(frame, event, frame.unit)
        frame.Range.Override(frame)
        UnitFrames:SetHealthColor(frame)

        if _G.UnitPowerMax(frame.unit) > 0 then
            --print("Has power")
            if not frame.Power.enabled then
                --print("Enable power")
                frame.Power.enabled = true
                --frame.Power.bar:Show()
                frame.Power.text:Show()
                for i = 1, 2 do
                    frame.Power.steps[i]:Show()
                end
            end
        else
            --print("Disable power")
            frame.Power.enabled = false
            --frame.Power.bar:Hide()
            frame.Power.text:Hide()
            for i = 1, 2 do
                frame.Power.steps[i]:Hide()
            end
            --return
        end
        local _, powerType = _G.UnitPowerType(frame.unit)
        UnitFrames:debug("Target powerType", powerType)

        AngleStatusBar:SetBarColor(frame.Power.bar, frame.colors.power[powerType])

        -- Reverse power
        local oldReverse, newReverse = frame.Power.bar.reverse
        if ndb.settings.reverseUnitFrameBars then
            newReverse = not RealUI.ReversePowers[powerType]
        else
            newReverse = RealUI.ReversePowers[powerType]
        end
        AngleStatusBar:SetReverseFill(frame.Power.bar, newReverse)

        -- If reverse is different from old target to new target then do an instant SetValue on power bar
        -- (stops power bar appearing unneccesarily when changing from, for example, a DK at no power (no bar shown) to a Mage at full power (no bar shown))
        if oldReverse ~= newReverse then
            local powerPer = RealUI:GetSafeVals(_G.UnitPower(frame.unit), _G.UnitPowerMax(frame.unit))
            AngleStatusBar:SetValue(frame.Power.bar, powerPer, true)
        end

        local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.power
        local stepPoints = db.misc.steppoints[RealUI.class] or db.misc.steppoints["default"]
        if frame.Power.bar.reverse then
            for i = 1, 2 do
                frame.Power.steps[i]:ClearAllPoints()
                frame.Power.steps[i]:SetPoint("BOTTOMLEFT", frame.Power, _G.floor(stepPoints[i] * texture.width) - 6, 0)
            end
        else
            for i = 1, 2 do
                frame.Power.steps[i]:ClearAllPoints()
                frame.Power.steps[i]:SetPoint("BOTTOMRIGHT", frame.Power, -(_G.floor(stepPoints[i] * texture.width) - 6), 0)
            end
        end
    end
end

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = RealUI.db.profile

    local target = oUF:Spawn("target", "RealUITargetFrame")
    target:SetPoint("LEFT", "RealUIPositionersUnitFrames", "RIGHT", db.positions[UnitFrames.layoutSize].target.x, db.positions[UnitFrames.layoutSize].target.y)
    target:RegisterEvent("UNIT_THREAT_LIST_UPDATE", target.Threat.Override)
    target:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", target.Class.Update)
end)
