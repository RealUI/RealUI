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
        }
    },
}

local function CreateHealthBar(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.health
    local pos = positions[UnitFrames.layoutSize].health
    local health = CreateFrame("Frame", nil, parent)
    health:SetPoint("TOPLEFT", parent, 0, 0)
    health:SetSize(texture.width, texture.height)

    health.bar = AngleStatusBar:NewBar(health, pos.x, -1, texture.width - pos.widthOfs, texture.height - 2, "RIGHT", "RIGHT", "RIGHT", true)

    health.bg = health:CreateTexture(nil, "BACKGROUND")
    health.bg:SetTexture(texture.bar)
    health.bg:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    health.bg:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
    health.bg:SetAllPoints(health)

    health.border = health:CreateTexture(nil, "BORDER")
    health.border:SetTexture(texture.border)
    health.border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    health.border:SetAllPoints(health)

    health.text = health:CreateFontString(nil, "OVERLAY")
    health.text:SetPoint("BOTTOMLEFT", health, "TOPLEFT", 0, 2)
    health.text:SetFont(unpack(nibRealUI:Font()))
    health.text:SetJustifyH("LEFT")
    parent:Tag(health.text, "[realui:healthPercent][realui:health]")

    local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
    health.steps = {}
    for i = 1, 2 do
        health.steps[i] = health:CreateTexture(nil, "OVERLAY")
        health.steps[i]:SetTexCoord(1, 0, 0, 1)
        health.steps[i]:SetSize(16, 16)
        health.steps[i]:SetPoint("TOPRIGHT", health, -(floor(stepPoints[i] * texture.width) - 6), 0)
    end

    health.frequentUpdates = true
    health.Override = UnitFrames.HealthOverride
    return health
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
    local power = CreateFrame("Frame", nil, parent)
    power:SetPoint("BOTTOMLEFT", parent, 5, 0)
    power:SetSize(texture.width, texture.height)

    power.bar = AngleStatusBar:NewBar(power, pos.x, -1, texture.width - pos.widthOfs, texture.height - 2, "LEFT", "LEFT", "RIGHT", true)

    ---[[
    power.bg = power:CreateTexture(nil, "BACKGROUND")
    power.bg:SetTexture(texture.bar)
    power.bg:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    power.bg:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
    power.bg:SetAllPoints(power)
    ---]]

    power.border = power:CreateTexture(nil, "BORDER")
    power.border:SetTexture(texture.border)
    power.border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    power.border:SetAllPoints(power)

    power.text = power:CreateFontString(nil, "OVERLAY")
    power.text:SetPoint("TOPLEFT", power, "BOTTOMLEFT", 0, -3)
    power.text:SetFont(unpack(nibRealUI:Font()))
    parent:Tag(power.text, "[realui:power]")

    local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
    power.steps = {}
    for i = 1, 2 do
        power.steps[i] = power:CreateTexture(nil, "OVERLAY")
        power.steps[i]:SetTexture(texture.warn)
        power.steps[i]:SetTexCoord(1, 0, 0, 1)
        power.steps[i]:SetSize(16, 16)
        --power.steps[i]:SetPoint("BOTTOMRIGHT", power, -(floor(stepPoints[i] * texture.width) - 6), 0)
    end

    power.frequentUpdates = true
    power.Override = UnitFrames.PowerOverride
    return power
end

local function CreatePowerStatus(parent) -- Combat, AFK, etc.
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.statusBox
    local coords = positions[UnitFrames.layoutSize].healthBox
    local status = {}
    for i = 1, 2 do
        status[i] = {}
        status[i].bg = parent.Power:CreateTexture(nil, "BORDER")
        status[i].bg:SetTexture(texture.bar)
        status[i].bg:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        status[i].bg:SetSize(texture.width, texture.height)

        status[i].border = parent.Power:CreateTexture(nil, "OVERLAY", nil, 3)
        status[i].border:SetTexture(texture.border)
        status[i].border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        status[i].border:SetAllPoints(status[i].bg)

        status[i].bg.Override = UnitFrames.UpdateStatus
        status[i].border.Override = UnitFrames.UpdateStatus

        if i == 1 then
            status[i].bg:SetPoint("TOPLEFT", parent.Power, "TOPRIGHT", -8, 0)
            parent.Combat = status[i].bg
            parent.Resting = status[i].border
        else
            status[i].bg:SetPoint("TOPLEFT", parent.Power, "TOPRIGHT", -2, 0)
            parent.Leader = status[i].bg
            parent.AFK = status[i].border
        end
    end
end

local function CreateRange(parent)
    local RangeColors = {
        [5] = nibRealUI.media.colors.green,
        [30] = nibRealUI.media.colors.yellow,
        [40] = nibRealUI.media.colors.amber,
        [50] = nibRealUI.media.colors.orange,
        [100] = nibRealUI.media.colors.red,
    }

    local range = parent:CreateTexture(nil, "OVERLAY")
    range:SetTexture(nibRealUI.media.icons.DoubleArrow)
    range:SetSize(16, 16)
    range:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -5, 0)
    range.insideAlpha = 1
    range.outsideAlpha = 0.5

    range.text = parent:CreateFontString(nil, "OVERLAY")
    range.text:SetFont(unpack(nibRealUI:Font()))
    range.text:SetPoint("BOTTOMRIGHT", range, "BOTTOMLEFT", 0, 0)

    range.Override = function(self, status)
        --print("Range Override", self, status)
        local minRange, maxRange = RC:GetRange("target")

        if (UnitIsUnit("player", "target")) or (minRange and minRange > 80) then maxRange = nil end
        local section
        if maxRange then
            if maxRange <= 5 then
                section = 5
            elseif maxRange <= 30 then
                section = 30
            elseif maxRange <= 40 then
                section = 40
            elseif maxRange <= 50 then
                section = 50
            else
                section = 100
            end
            self.Range.text:SetFormattedText("%d", maxRange)
            self.Range.text:SetTextColor(RangeColors[section][1], RangeColors[section][2], RangeColors[section][3])
            self.Range:Show()
        else
            self.Range.text:SetText("")
            self.Range:Hide()
        end
    end

    return range
end

local function CreateThreat(parent)
    local threat = parent:CreateTexture(nil, "OVERLAY")
    threat:SetTexture(nibRealUI.media.icons.Lightning)
    threat:SetSize(16, 16)
    threat:SetPoint("TOPRIGHT", parent, "TOPLEFT", -10, 0)

    threat.text = parent:CreateFontString(nil, "OVERLAY")
    threat.text:SetFont(unpack(nibRealUI:Font()))
    threat.text:SetPoint("BOTTOMRIGHT", threat, "BOTTOMLEFT", 0, 0)

    threat.Override = function(self, event, unit)
        --print("Threat Override", self, event, unit)
        local isTanking, status, _, rawPercentage = UnitDetailedThreatSituation("player", "target")

        local tankLead
        if ( isTanking ) then
            tankLead = UnitThreatPercentageOfLead("player", "target")
        end
        local display = tankLead or rawPercentage
        if not (UnitIsDeadOrGhost("target")) and (display and (display ~= 0)) then
            self.Threat.text:SetFormattedText("%d%%", display)
            local r, g, b = GetThreatStatusColor(status)
            self.Threat.text:SetTextColor(r, g, b)
            self.Threat:Show()
        else
            self.Threat.text:SetText("")
            self.Threat:Hide()
        end
    end

    return threat
end

local function CreateEndBox(parent)
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F1.endBox
    local pos = positions[UnitFrames.layoutSize].endBox
    local endBox = parent:CreateTexture(nil, "BORDER")
    endBox:SetTexture(texture.bar)
    endBox:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    endBox:SetSize(texture.width, texture.height)
    endBox:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", pos.x, pos.y)

    local border = parent:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetTexCoord(pos.coords[1], pos.coords[2], pos.coords[3], pos.coords[4])
    border:SetAllPoints(endBox)

    endBox.Update = UnitFrames.UpdateEndBox
   
    return endBox
end

local function CreateTarget(self)
    self.Health = CreateHealthBar(self)
    self.Power = CreatePowerBar(self)
    CreateHealthStatus(self)
    self.Range = CreateRange(self.Health)
    self.Threat = CreateThreat(self.Power)
    self.endBox = CreateEndBox(self)
    CreatePowerStatus(self)
    
    self.Name = self:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -12, 2)
    self.Name:SetFont(unpack(nibRealUI:Font()))
    self:Tag(self.Name, "[realui:level] [realui:name]")

    self:SetSize(self.Health:GetWidth(), self.Health:GetHeight() + self.Power:GetHeight() + 3)

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)

    function self:PreUpdate(event)
        --self.Combat.Override(self, event)
        self.Class.Update(self, event)
        self.endBox.Update(self, event)

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
        self.Power.bar.reverse = UnitFrames.ReversePowers[powerType] or false

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

    oUF:RegisterStyle("RealUI:target", CreateTarget)
    oUF:SetActiveStyle("RealUI:target")
    local target = oUF:Spawn("target", "RealUITargetFrame")
    target:SetPoint("LEFT", "RealUIPositionersUnitFrames", "RIGHT", db.positions[UnitFrames.layoutSize].target.x, db.positions[UnitFrames.layoutSize].target.y)
    target:RegisterEvent("UNIT_THREAT_LIST_UPDATE", target.Threat.Override)
    target:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", target.Class.Update)
end)

