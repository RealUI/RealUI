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

local function CreateHealthBar(parent)
    local texture = F2.health
    local coords = texCoords[UnitFrames.layoutSize].health
    parent.Health = _G.CreateFrame("Frame", nil, parent.overlay)
    parent.Health:SetPoint("BOTTOMRIGHT", parent, 0, 0)
    parent.Health:SetAllPoints(parent)

    parent.Health.bar = AngleStatusBar:NewBar(parent.Health, 2, -1, texture.width - 5, texture.height - 2, "RIGHT", "LEFT", "RIGHT", true)
    if ndb.settings.reverseUnitFrameBars then
        AngleStatusBar:SetReverseFill(parent.Health.bar, true)
    end
    UnitFrames:SetHealthColor(parent)

    parent.Health.bg = parent.Health:CreateTexture(nil, "BACKGROUND")
    parent.Health.bg:SetTexture(texture.bar)
    parent.Health.bg:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    parent.Health.bg:SetVertexColor(RealUI.media.background[1], RealUI.media.background[2], RealUI.media.background[3], RealUI.media.background[4])
    parent.Health.bg:SetAllPoints(parent.Health)

    parent.Health.border = parent.Health:CreateTexture(nil, "BORDER")
    parent.Health.border:SetTexture(texture.border)
    parent.Health.border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    parent.Health.border:SetAllPoints(parent.Health)

    local stepPoints = db.misc.steppoints[RealUI.class] or db.misc.steppoints["default"]
    parent.Health.steps = {}
    for i = 1, 2 do
        parent.Health.steps[i] = parent.Health:CreateTexture(nil, "OVERLAY")
        parent.Health.steps[i]:SetTexCoord(1, 0, 0, 1)
        parent.Health.steps[i]:SetSize(16, 16)
        parent.Health.steps[i]:SetPoint("TOPRIGHT", parent.Health, -(_G.floor(stepPoints[i] * texture.width)), 0)
        if not parent.Health.bar.reverse then
        parent.Health.steps[i]:SetPoint("TOPRIGHT", parent.Health, -(_G.floor(stepPoints[i] * texture.width)), 0)
        else
            parent.Health.steps[i]:SetPoint("TOPLEFT", parent.Health, _G.floor(stepPoints[i] * texture.width), 0)
        end
    end

    parent.Health.Override = UnitFrames.HealthOverride
end

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

UnitFrames["targettarget"] = function(self)
    self:SetSize(F2.health.width, F2.health.height)
    CreateHealthBar(self)
    CreateHealthStatus(self)
    CreatePowerStatus(self)
    CreateEndBox(self)

    self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -5, 2 - UnitFrames.layoutSize)
    self.Name:SetFontObject(_G.RealUIFont_Pixel)
    self:Tag(self.Name, "[realui:name]")

    function self.PostUpdate(frame, event)
        frame.Class.Update(frame, event)
        frame.endBox.Update(frame, event)
        UnitFrames:SetHealthColor(frame)
    end
end

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = RealUI.db.profile
    F2 = UnitFrames.textures[UnitFrames.layoutSize].F2

    local targettarget = oUF:Spawn("targettarget", "RealUITargetTargetFrame")
    targettarget:SetPoint("BOTTOMRIGHT", "RealUITargetFrame", db.positions[UnitFrames.layoutSize].targettarget.x, db.positions[UnitFrames.layoutSize].targettarget.y)
    targettarget:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", targettarget.Class.Update)
end)
