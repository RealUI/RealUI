local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local RC = LibStub("LibRangeCheck-2.0")
local db, ndb, ndbc

local oUF = oUFembed

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
    parent.Health = CreateFrame("Frame", nil, parent.overlay)
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
    parent.Health.bg:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
    parent.Health.bg:SetAllPoints(parent.Health)

    parent.Health.border = parent.Health:CreateTexture(nil, "BORDER")
    parent.Health.border:SetTexture(texture.border)
    parent.Health.border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.Health.border:SetAllPoints(parent.Health)

    parent.Health.text = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.Health.text:SetPoint("BOTTOMLEFT", parent.Health, "TOPLEFT", 0, 2)
    parent.Health.text:SetFont(unpack(nibRealUI:Font()))
    parent.Health.text:SetJustifyH("LEFT")
    parent:Tag(parent.Health.text, "[realui:healthPercent< - ][realui:health]")

    local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
    parent.Health.steps = {}
    for i = 1, 2 do
        parent.Health.steps[i] = parent.Health:CreateTexture(nil, "OVERLAY")
        parent.Health.steps[i]:SetTexCoord(1, 0, 0, 1)
        parent.Health.steps[i]:SetSize(16, 16)
        if not parent.Health.bar.reverse then
        parent.Health.steps[i]:SetPoint("TOPRIGHT", parent.Health, -(floor(stepPoints[i] * texture.width) - 6), 0)
        else
            parent.Health.steps[i]:SetPoint("TOPLEFT", parent.Health, floor(stepPoints[i] * texture.width) - 6, 0)
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
    parent.Power = CreateFrame("Frame", nil, parent.overlay)
    parent.Power:SetPoint("BOTTOMLEFT", parent, 5, 0)
    parent.Power:SetSize(texture.width, texture.height)

    parent.Power.bar = AngleStatusBar:NewBar(parent.Power, pos.x, -1, texture.width - pos.widthOfs, texture.height - 2, "LEFT", "LEFT", "RIGHT", true)

    ---[[
    parent.Power.bg = parent.Power:CreateTexture(nil, "BACKGROUND")
    parent.Power.bg:SetTexture(texture.bar)
    parent.Power.bg:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.Power.bg:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
    parent.Power.bg:SetAllPoints(parent.Power)
    ---]]

    parent.Power.border = parent.Power:CreateTexture(nil, "BORDER")
    parent.Power.border:SetTexture(texture.border)
    parent.Power.border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    parent.Power.border:SetAllPoints(parent.Power)

    parent.Power.text = parent.Power:CreateFontString(nil, "OVERLAY")
    parent.Power.text:SetPoint("TOPLEFT", parent.Power, "BOTTOMLEFT", 0, -3)
    parent.Power.text:SetFont(unpack(nibRealUI:Font()))
    parent:Tag(parent.Power.text, "[realui:power]")

    local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
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
        [5] = nibRealUI.media.colors.green,
        [30] = nibRealUI.media.colors.yellow,
        [35] = nibRealUI.media.colors.amber,
        [40] = nibRealUI.media.colors.orange,
        [50] = nibRealUI.media.colors.red,
        [100] = nibRealUI.media.colors.red,
    }

    -- parent.Range = parent.Health:CreateTexture(nil, "OVERLAY")
    -- parent.Range:SetTexture(nibRealUI.media.icons.DoubleArrow)
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
    parent.Range.text:SetFont(unpack(nibRealUI:Font()))
    parent.Range.text:SetJustifyH("right")
    parent.Range.text:SetPoint("BOTTOMRIGHT", parent.Range, "BOTTOMLEFT", 20.5, 4.5)

    parent.Range.Override = function(self, status)
        --print("Range Override", self, status)
        local minRange, maxRange = RC:GetRange("target")

        if (UnitIsUnit("player", "target")) or (minRange and minRange > 80) then maxRange = nil end
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

    -- parent.Threat = parent.Power:CreateTexture(nil, "OVERLAY")
    -- parent.Threat:SetTexture(nibRealUI.media.icons.Lightning)
    -- parent.Threat:SetSize(16, 16)
    -- parent.Threat:SetPoint("TOPRIGHT", parent.Power, "TOPLEFT", -10, 0)

    -- parent.Threat.text = parent.Power:CreateFontString(nil, "OVERLAY")
    -- parent.Threat.text:SetFont(unpack(nibRealUI:Font()))
    -- parent.Threat.text:SetPoint("BOTTOMRIGHT", parent.Threat, "BOTTOMLEFT", 0, 0)

    parent.Threat = parent.overlay:CreateTexture(nil, "BORDER")
    parent.Threat:SetTexture(texture.bar)
    parent.Threat:SetSize(texture.width, texture.height)
    parent.Threat:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", pos.x, pos.y)

    parent.Threat.border = parent.overlay:CreateTexture(nil, "OVERLAY", nil, 3)
    parent.Threat.border:SetTexture(texture.border)
    parent.Threat.border:SetAllPoints(parent.Threat)

    parent.Threat.isActive = false

    parent.Threat.Override = function(self, event, unit)
        --print("Threat Override", self, event, unit)
        

        -- local tankLead
        -- if ( isTanking ) then
        --     tankLead = UnitThreatPercentageOfLead("player", "target")
        -- end
        -- local display = tankLead or rawPercentage

        local isTanking, status, _, rawPercentage = UnitDetailedThreatSituation("player", "target")
        if (rawPercentage and (rawPercentage >= 0.8)) and not(UnitIsDeadOrGhost(unit)) and (GetNumGroupMembers() > 0) then
            -- self.Threat.text:SetFormattedText("%d%%", display)
            -- self.Threat.text:SetTextColor(r, g, b)
            if (status and status > 0) then
                self.Threat:SetVertexColor(GetThreatStatusColor(status))
            elseif rawPercentage >= 0.9 then
                self.Threat:SetVertexColor(GetThreatStatusColor(0))
            else
                self.Threat:SetVertexColor(0, 1, 0, 1)
            end

            self.Threat:Show()
            self.Threat.border:Show()
            self.Range:Hide()
            self.Range.border:Hide()
            self.Threat.isActive = true
        else
            -- self.Threat.text:SetText("")
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
    self.Name:SetFont(unpack(nibRealUI:Font()))
    self:Tag(self.Name, "[realui:level] [realui:name]")

    self.RaidIcon = self:CreateTexture(nil, "OVERLAY")
    self.RaidIcon:SetSize(16, 16)
    self.RaidIcon:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", -10, 0)

    self:SetSize(self.Health:GetWidth(), self.Health:GetHeight() + self.Power:GetHeight() + 3)

    function self:PreUpdate(event)
        --self.Combat.Override(self, event)
        self.Class.Update(self, event)
        self.endBox.Update(self, event)
        self.Threat.Override(self, event, self.unit)
        self.Range.Override(self)
        UnitFrames:SetHealthColor(self)

        if UnitPowerMax(self.unit) > 0 then
            --print("Has power")
            if not self.Power.enabled then
                --print("Enable power")
                self.Power.enabled = true
                --self.Power.bar:Show()
                self.Power.text:Show()
                for i = 1, 2 do
                    self.Power.steps[i]:Show()
                end
            end
        else
            --print("Disable power")
            self.Power.enabled = false
            --self.Power.bar:Hide()
            self.Power.text:Hide()
            for i = 1, 2 do
                self.Power.steps[i]:Hide()
            end
            --return
        end
        local _, powerType = UnitPowerType(self.unit)

        AngleStatusBar:SetBarColor(self.Power.bar, db.overlay.colors.power[powerType])

        -- Reverse power
        local oldReverse = self.Power.bar.reverse
        local newReverse = UnitFrames.ReversePowers[powerType] or (ndb.settings.reverseUnitFrameBars)
        AngleStatusBar:SetReverseFill(self.Power.bar, newReverse)

        -- If reverse is different from old target to new target then do an instant SetValue on power bar
        -- (stops power bar appearing unneccesarily when changing from, for example, a DK at no power (no bar shown) to a Mage at full power (no bar shown))
        if oldReverse ~= newReverse then
            local powerPer = nibRealUI:GetSafeVals(UnitPower(self.unit), UnitPowerMax(self.unit))
            AngleStatusBar:SetValue(self.Power.bar, powerPer, true)
        end

        local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.power
        local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
        if self.Power.bar.reverse then
            for i = 1, 2 do
                self.Power.steps[i]:ClearAllPoints()
                self.Power.steps[i]:SetPoint("BOTTOMLEFT", self.Power, floor(stepPoints[i] * texture.width) - 6, 0)
            end
        else
            for i = 1, 2 do
                self.Power.steps[i]:ClearAllPoints()
                self.Power.steps[i]:SetPoint("BOTTOMRIGHT", self.Power, -(floor(stepPoints[i] * texture.width) - 6), 0)
            end
        end
    end
end

-- Init
tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char

    local target = oUF:Spawn("target", "RealUITargetFrame")
    target:SetPoint("LEFT", "RealUIPositionersUnitFrames", "RIGHT", db.positions[UnitFrames.layoutSize].target.x, db.positions[UnitFrames.layoutSize].target.y)
    target:RegisterEvent("UNIT_THREAT_LIST_UPDATE", target.Threat.Override)
    target:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", target.Class.Update)
end)

