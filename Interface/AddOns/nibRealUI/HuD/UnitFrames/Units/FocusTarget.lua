local _, private = ...

-- Libs --
local oUF = _G.oUFembed

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")

local F3

local function CreateHealthStatus(parent) -- PvP/Classification
    local texture = F3.healthBox
    local status = {}
    for i = 1, 2 do
        status.bg = parent.Health:CreateTexture(nil, "OVERLAY", nil, 1)
        status.bg:SetTexture(texture.bar)
        status.bg:SetSize(texture.width, texture.height)

        status.border = parent.Health:CreateTexture(nil, "OVERLAY", nil, 3)
        status.border:SetTexture(texture.border)
        status.border:SetAllPoints(status.bg)

        if i == 1 then
            status.bg:SetPoint("BOTTOMRIGHT", parent.Health, -8, 0)
            parent.PvP = status.bg
            parent.PvP.Override = UnitFrames.PvPOverride
        else
            status.bg:SetPoint("BOTTOMRIGHT", parent.Health, -16, 0)
            parent.Class = status.bg
            parent.Class.Update = UnitFrames.UpdateClassification
        end
    end
end

local function CreatePowerStatus(parent) -- Combat, AFK, etc.
    local texture = UnitFrames.textures[UnitFrames.layoutSize].F2.statusBox
    local status = {}
    for i = 1, 2 do
        status.bg = parent.Health:CreateTexture(nil, "BORDER")
        status.bg:SetTexture(texture.bar)
        status.bg:SetSize(texture.width, texture.height)

        status.border = parent.Health:CreateTexture(nil, "OVERLAY", nil, 3)
        status.border:SetTexture(texture.border)
        status.border:SetAllPoints(status.bg)

        status.bg.Override = UnitFrames.UpdateStatus
        status.border.Override = UnitFrames.UpdateStatus

        if i == 1 then
            status.bg:SetPoint("TOPRIGHT", parent.Health, "TOPLEFT", 6 + UnitFrames.layoutSize, 0)
            parent.Combat = status.bg
            parent.Resting = status.border
        else
            status.bg:SetPoint("TOPRIGHT", parent.Health, "TOPLEFT", UnitFrames.layoutSize, 0)
            parent.Leader = status.bg
            parent.AFK = status.border
        end
    end
end

local function CreateEndBox(parent)
    local texture = F3.endBox
    parent.endBox = parent.overlay:CreateTexture(nil, "BORDER")
    parent.endBox:SetTexture(texture.bar)
    parent.endBox:SetSize(texture.width, texture.height)
    parent.endBox:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -6 - UnitFrames.layoutSize, 0)

    local border = parent.overlay:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetAllPoints(parent.endBox)

    parent.endBox.Update = UnitFrames.UpdateEndBox
end

UnitFrames.focustarget = {
    create = function(self)
        CreateHealthStatus(self)
        CreatePowerStatus(self)
        CreateEndBox(self)

        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 2 - UnitFrames.layoutSize)
        self.Name:SetFontObject(_G.RealUIFont_Pixel)
        self:Tag(self.Name, "[realui:name]")

        function self.PostUpdate(frame, event)
            frame.Health:PositionSteps("BOTTOM", "RIGHT")
            frame.Combat.Override(frame, event)
            frame.Class.Update(frame, event)
            frame.endBox.Update(frame, event)
        end
    end,
    health = {
        leftAngle = [[\]],
        rightAngle = [[\]],
        point = "RIGHT"
    },
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    F3 = UnitFrames.textures[UnitFrames.layoutSize].F3

    local focustarget = oUF:Spawn("focustarget", "RealUIFocusTargetFrame")
    focustarget:SetPoint("TOPLEFT", "RealUIFocusFrame", "BOTTOMLEFT", db.positions[UnitFrames.layoutSize].focustarget.x, db.positions[UnitFrames.layoutSize].focustarget.y)
    focustarget:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", focustarget.Class.Update)
end)
