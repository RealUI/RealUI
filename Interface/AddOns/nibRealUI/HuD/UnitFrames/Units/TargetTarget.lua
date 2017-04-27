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
        CreateEndBox(self)

        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -5, 2 - UnitFrames.layoutSize)
        self.Name:SetFontObject(_G.RealUIFont_Pixel)
        self:Tag(self.Name, "[realui:name]")

        function self.PostUpdate(frame, event)
            frame.Health:PositionSteps("TOP", "LEFT")
            frame.Classification.Update(frame, event)
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
end)
