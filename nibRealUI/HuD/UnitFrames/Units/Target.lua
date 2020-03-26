local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
UnitFrames.target = {
    create = function(self)
        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMRIGHT", self.Health, "TOPRIGHT", -12, 2)
        self.Name:SetFontObject("SystemFont_Shadow_Med1_Outline")
        self:Tag(self.Name, "[realui:level] [realui:name]")

        self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
        self.RaidTargetIndicator:SetSize(20, 20)
        self.RaidTargetIndicator:SetPoint("BOTTOMRIGHT", self, "TOPLEFT", -10, 4)

        self.Threat = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Threat:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, -18)
        self.Threat:SetFontObject("SystemFont_Shadow_Med1_Outline")
        self:Tag(self.Threat, "[realui:threat]")

        self.Range = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Range:SetPoint("TOPRIGHT", self, "TOPLEFT", -10, -4)
        self.Range:SetFontObject("SystemFont_Shadow_Med1_Outline")
        self.Range.frequentUpdates = true
        self:Tag(self.Range, "[realui:range]")
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
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile

    local target = oUF:Spawn("target", "RealUITargetFrame")
    target:SetPoint("LEFT", "RealUIPositionersUnitFrames", "RIGHT", db.positions[UnitFrames.layoutSize].target.x, db.positions[UnitFrames.layoutSize].target.y)
end)
