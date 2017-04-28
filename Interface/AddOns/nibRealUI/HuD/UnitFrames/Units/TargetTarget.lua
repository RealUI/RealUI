local _, private = ...

-- Libs --
local oUF = _G.oUFembed

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
UnitFrames.targettarget = {
    create = function(self)
        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -5, 2 - UnitFrames.layoutSize)
        self.Name:SetFontObject(_G.RealUIFont_Pixel)
        self:Tag(self.Name, "[realui:name]")

        function self.PostUpdate(frame, event)
            frame.Health:PositionSteps("TOP")
            frame.Classification.Update(frame, event)
            frame.EndBox.Update(frame, event)
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

    local targettarget = oUF:Spawn("targettarget", "RealUITargetTargetFrame")
    targettarget:SetPoint("BOTTOMRIGHT", "RealUITargetFrame", db.positions[UnitFrames.layoutSize].targettarget.x, db.positions[UnitFrames.layoutSize].targettarget.y)
end)
