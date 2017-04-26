local _, private = ...

-- Libs --
local oUF = _G.oUFembed

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")

local F2

local function CreatePowerStatus(parent) -- Combat, AFK, etc.
    local texture = F2.statusBox
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
    local texture = F2.endBox
    parent.endBox = parent.overlay:CreateTexture(nil, "BORDER")
    parent.endBox:SetTexture(texture.bar)
    parent.endBox:SetSize(texture.width, texture.height)
    parent.endBox:SetPoint("BOTTOMLEFT", parent, "BOTTOMRIGHT", -6 - UnitFrames.layoutSize, 0)

    local border = parent.overlay:CreateTexture(nil, "OVERLAY", nil, 3)
    border:SetTexture(texture.border)
    border:SetAllPoints(parent.endBox)

    parent.endBox.Update = UnitFrames.UpdateEndBox
end

UnitFrames.focus = {
    create = function(self)
        CreatePowerStatus(self)
        CreateEndBox(self)

        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 2 - UnitFrames.layoutSize)
        self.Name:SetFontObject(_G.RealUIFont_Pixel)
        self:Tag(self.Name, "[realui:name]")

        function self.PostUpdate(frame, event)
            frame.Health:PositionSteps("TOP", "RIGHT")
            frame.Classification.Update(frame, event)
            frame.Combat.Override(frame, event)
            frame.endBox.Update(frame, event)
        end
    end,
    health = {
        leftAngle = [[\]],
        rightAngle = [[/]],
        point = "RIGHT"
    },
    hasCastBars = true,
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    F2 = UnitFrames.textures[UnitFrames.layoutSize].F2

    local focus = oUF:Spawn("focus", "RealUIFocusFrame")
    focus:SetPoint("BOTTOMLEFT", "RealUIPlayerFrame", db.positions[UnitFrames.layoutSize].focus.x, db.positions[UnitFrames.layoutSize].focus.y)
end)
