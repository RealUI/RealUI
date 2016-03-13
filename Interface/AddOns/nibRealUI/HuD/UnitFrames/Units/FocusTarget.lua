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

local F3
local texCoords = {
    [1] = {
        health = {0.58984375, 1, 0.4375, 1},
    },
    [2] = {
        health = {0.5078125, 1, 0.375, 1},
    },
}

local function CreateHealthBar(parent)
    local texture = F3.health
    local coords = texCoords[UnitFrames.layoutSize].health
    parent.Health = _G.CreateFrame("Frame", nil, parent.overlay)
    parent.Health:SetPoint("BOTTOMRIGHT", parent, 0, 0)
    parent.Health:SetAllPoints(parent)

    parent.Health.bar = AngleStatusBar:NewBar(parent.Health, -(7 + UnitFrames.layoutSize), -1, texture.width - (8 + UnitFrames.layoutSize), texture.height - 2, "RIGHT", "RIGHT", "LEFT", true)
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
        parent.Health.steps[i]:SetSize(16, 16)
        parent.Health.steps[i]:SetPoint("BOTTOMLEFT", parent.Health, _G.floor(stepPoints[i] * texture.width), 0)
    end

    parent.Health.Override = UnitFrames.HealthOverride
end

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

UnitFrames["focustarget"] = function(self)
    self:SetSize(F3.health.width, F3.health.height)
    CreateHealthBar(self)
    CreateHealthStatus(self)
    CreatePowerStatus(self)
    CreateEndBox(self)

    self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 2 - UnitFrames.layoutSize)
    self.Name:SetFontObject(_G.RealUIFont_Pixel)
    self:Tag(self.Name, "[realui:name]")

    function self.PostUpdate(frame, event)
        frame.Combat.Override(frame, event)
        frame.Class.Update(frame, event)
        frame.endBox.Update(frame, event)
        UnitFrames:SetHealthColor(frame)
    end
end

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = RealUI.db.profile
    F3 = UnitFrames.textures[UnitFrames.layoutSize].F3

    local focustarget = oUF:Spawn("focustarget", "RealUIFocusTargetFrame")
    focustarget:SetPoint("TOPLEFT", "RealUIFocusFrame", "BOTTOMLEFT", db.positions[UnitFrames.layoutSize].focustarget.x, db.positions[UnitFrames.layoutSize].focustarget.y)
    focustarget:RegisterEvent("UNIT_CLASSIFICATION_CHANGED", focustarget.Class.Update)
end)
