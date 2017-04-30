local _, private = ...

-- Libs --
local oUF = _G.oUFembed
local RC = _G.LibStub("LibRangeCheck-2.0")

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
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

UnitFrames.target = {
    create = function(self)
        CreateRange(self)
        CreateThreat(self)

        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -12, 2)
        self.Name:SetFontObject(_G.RealUIFont_Pixel)
        self:Tag(self.Name, "[realui:level] [realui:name]")

        self.RaidIcon = self:CreateTexture(nil, "OVERLAY")
        self.RaidIcon:SetSize(20, 20)
        self.RaidIcon:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", -10, 4)
    end,
    health = {
        leftVertex = 2,
        rightVertex = 3,
        point = "LEFT",
        text = true,
    },
    power = {
        leftVertex = 1,
        rightVertex = 4,
        point = "LEFT",
    },
    isBig = true,
    hasCastBars = true,
    PostUpdate = function(self, event)
        self.Threat.Override(self, event, self.unit)
        self.Range.Override(self)
    end
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile

    local target = oUF:Spawn("target", "RealUITargetFrame")
    target:SetPoint("LEFT", "RealUIPositionersUnitFrames", "RIGHT", db.positions[UnitFrames.layoutSize].target.x, db.positions[UnitFrames.layoutSize].target.y)
    target:RegisterEvent("UNIT_THREAT_LIST_UPDATE", target.Threat.Override)
end)
