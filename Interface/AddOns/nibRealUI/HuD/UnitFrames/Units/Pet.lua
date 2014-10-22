local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local db, ndb, ndbc

local oUF = oUFembed

local F3
local coords = {
    [1] = {
        health = {0.58984375, 1, 0.4375, 1},
    },
    [2] = {
        health = {0.5078125, 1, 0.375, 1},
    },
}

local function CreateHealthBar(parent)
    local texture = F3.health
    local coords = coords[UnitFrames.layoutSize].health
    parent.Health = CreateFrame("Frame", nil, parent.overlay)
    parent.Health:SetPoint("BOTTOMRIGHT", parent, 0, 0)
    parent.Health:SetAllPoints(parent)

    parent.Health.bar = AngleStatusBar:NewBar(parent.Health, -(7 + UnitFrames.layoutSize), -1, texture.width - (10 + UnitFrames.layoutSize), texture.height - 2, "RIGHT", "RIGHT", "LEFT", true)
    if ndb.settings.reverseUnitFrameBars then 
        AngleStatusBar:SetReverseFill(parent.Health.bar, true)
    end

    parent.Health.bg = parent.Health:CreateTexture(nil, "BACKGROUND")
    parent.Health.bg:SetTexture(texture.bar)
    parent.Health.bg:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    parent.Health.bg:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], nibRealUI.media.background[4])
    parent.Health.bg:SetAllPoints(parent.Health)

    parent.Health.border = parent.Health:CreateTexture(nil, "BORDER")
    parent.Health.border:SetTexture(texture.border)
    parent.Health.border:SetTexCoord(coords[1], coords[2], coords[3], coords[4])
    parent.Health.border:SetAllPoints(parent.Health)

    local stepPoints = db.misc.steppoints[nibRealUI.class] or db.misc.steppoints["default"]
    parent.Health.steps = {}
    for i = 1, 2 do
        parent.Health.steps[i] = parent.Health:CreateTexture(nil, "OVERLAY")
        parent.Health.steps[i]:SetSize(16, 16)
        if parent.Health.bar.reverse then
            parent.Health.steps[i]:SetPoint("BOTTOMRIGHT", parent.Health, -(floor(stepPoints[i] * texture.width)), 0)
        else
            parent.Health.steps[i]:SetPoint("BOTTOMLEFT", parent.Health, floor(stepPoints[i] * texture.width), 0)
        end
    end

    parent.Health.Override = UnitFrames.HealthOverride
end

local function CreatePvPStatus(parent)
    local texture = F3.healthBox
    parent.PvP = parent.Health:CreateTexture(nil, "OVERLAY", nil, 1)
    parent.PvP:SetTexture(texture.bar)
    parent.PvP:SetSize(texture.width, texture.height)
    parent.PvP:SetPoint("BOTTOMRIGHT", parent, -8, 0)

    local border = parent.Health:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetAllPoints(parent.PvP)

    parent.PvP.Override = UnitFrames.PvPOverride
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

UnitFrames["pet"] = function(self)
    self:SetSize(F3.health.width, F3.health.height)
    CreateHealthBar(self)
    CreatePvPStatus(self)
    CreatePowerStatus(self)
    CreateEndBox(self)

    self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
    self.Name:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 2 - UnitFrames.layoutSize)
    self.Name:SetFont(unpack(nibRealUI:Font()))
    self:Tag(self.Name, "[realui:name]")

    function self:PostUpdate(event)
        self.Combat.Override(self, event)
        self.endBox.Update(self, event)
        --print("unit", self.unit)
        if self.unit == "player" then
            UnitFrames.HealthOverride(self, "PostUpdate", "pet")
        end
    end
end

-- Init
tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char
    F3 = UnitFrames.textures[UnitFrames.layoutSize].F3

    local pet = oUF:Spawn("pet", "RealUIPetFrame")
    pet:SetPoint("BOTTOMLEFT", "RealUIPlayerFrame", db.positions[UnitFrames.layoutSize].pet.x, db.positions[UnitFrames.layoutSize].pet.y)
end)
