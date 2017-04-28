local _, private = ...

-- Libs --
local oUF = _G.oUFembed

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
UnitFrames.focustarget = {
    create = function(self)
        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 2 - UnitFrames.layoutSize)
        self.Name:SetFontObject(_G.RealUIFont_Pixel)
        self:Tag(self.Name, "[realui:name]")

        function self.PostUpdate(frame, event)
            frame.Health:PositionSteps("BOTTOM")
            frame.Classification.Update(frame, event)
            frame.Combat.Override(frame, event)
            frame.EndBox.Update(frame, event)
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

    local focustarget = oUF:Spawn("focustarget", "RealUIFocusTargetFrame")
    focustarget:SetPoint("TOPLEFT", "RealUIFocusFrame", "BOTTOMLEFT", db.positions[UnitFrames.layoutSize].focustarget.x, db.positions[UnitFrames.layoutSize].focustarget.y)
end)
