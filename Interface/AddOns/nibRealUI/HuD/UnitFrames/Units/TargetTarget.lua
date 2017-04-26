local _, private = ...

-- Libs --
local oUF = _G.oUFembed

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")

local F2
local texCoords = {
    [1] = {
        health = {1, 0.546875, 0.4375, 1},
        status = {1, 0, 0, 1},
    },
    [2] = {
        health = {1, 0.4609375, 0.375, 1},
        status = {1, 0, 0, 1},
    },
}

local function CreateHealthStatus(parent) -- PvP/Classification
    local texture = F2.healthBox
    local coords = texCoords[UnitFrames.layoutSize].status
    local status = {}
    for i = 1, 2 do
        status.bg = parent.Health:CreateTexture(nil, "OVERLAY", nil, 1)
        status.bg:SetTexture(texture.bar)
        status.bg:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        status.bg:SetSize(texture.width, texture.height)

        status.border = parent.Health:CreateTexture(nil, "OVERLAY", nil, 3)
        status.border:SetTexture(texture.border)
        status.border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        status.border:SetAllPoints(status.bg)

        if i == 1 then
            status.bg:SetPoint("TOPLEFT", parent.Health, 8, -1)
            parent.PvP = status.bg
            parent.PvP.Override = UnitFrames.PvPOverride
        else
            status.bg:SetPoint("TOPLEFT", parent.Health, 16, -1)
            parent.Class = status.bg
            parent.Class.Update = UnitFrames.UpdateClassification
        end
    end
end

local function CreatePowerStatus(parent) -- Combat, AFK, etc.
    local texture = F2.statusBox
    local coords = texCoords[UnitFrames.layoutSize].status
    local status = {}
    for i = 1, 2 do
        status.bg = parent.Health:CreateTexture(nil, "BORDER")
        status.bg:SetTexture(texture.bar)
        status.bg:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        status.bg:SetSize(texture.width, texture.height)

        status.border = parent.Health:CreateTexture(nil, "OVERLAY", nil, 3)
        status.border:SetTexture(texture.border)
        status.border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
        status.border:SetAllPoints(status.bg)

        status.bg.Override = UnitFrames.UpdateStatus
        status.border.Override = UnitFrames.UpdateStatus

        if i == 1 then
            status.bg:SetPoint("TOPLEFT", parent.Health, "TOPRIGHT", -6 - UnitFrames.layoutSize, 0)
            parent.Combat = status.bg
            parent.Resting = status.border
        else
            status.bg:SetPoint("TOPLEFT", parent.Health, "TOPRIGHT", -UnitFrames.layoutSize, 0)
            parent.Leader = status.bg
            parent.AFK = status.border
        end
    end
end

local function CreateEndBox(parent)
    local texture = F2.endBox
    local coords = texCoords[UnitFrames.layoutSize].status
    parent.endBox = parent.overlay:CreateTexture(nil, "BORDER")
    parent.endBox:SetTexture(texture.bar)
    parent.endBox:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    parent.endBox:SetSize(texture.width, texture.height)
    parent.endBox:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", 6 + UnitFrames.layoutSize, 0)

    local border = parent.overlay:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    border:SetAllPoints(parent.endBox)

    parent.endBox.Update = UnitFrames.UpdateEndBox
end

UnitFrames.targettarget = {
    create = function(self)
        CreateHealthStatus(self)
        CreatePowerStatus(self)
        CreateEndBox(self)

        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -5, 2 - UnitFrames.layoutSize)
        self.Name:SetFontObject(_G.RealUIFont_Pixel)
        self:Tag(self.Name, "[realui:name]")

        function self.PostUpdate(frame, event)
            frame.Health:PositionSteps("TOP", "LEFT")
            frame.Class.Update(frame, event)
            frame.endBox.Update(frame, event)
        end
    end,
    health = {
        leftAngle = [[\]],
        rightAngle = [[/]],
        point = "LEFT"
    },
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    F2 = UnitFrames.textures[UnitFrames.layoutSize].F2

    local targettarget = oUF:Spawn("targettarget", "RealUITargetTargetFrame")
    targettarget:SetPoint("BOTTOMRIGHT", "RealUITargetFrame", db.positions[UnitFrames.layoutSize].targettarget.x, db.positions[UnitFrames.layoutSize].targettarget.y)
    targettarget:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", targettarget.Class.Update)
end)
