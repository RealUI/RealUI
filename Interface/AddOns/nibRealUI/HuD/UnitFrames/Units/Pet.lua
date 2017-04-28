local _, private = ...

-- Libs --
local oUF = _G.oUFembed

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
UnitFrames.pet = {
    create = function(self)
        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 2 - UnitFrames.layoutSize)
        self.Name:SetFontObject(_G.RealUIFont_Pixel)
        self:Tag(self.Name, "[realui:name]")

        function self.PostUpdate(frame, event)
            frame.Health:PositionSteps("BOTTOM")
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

    local pet = oUF:Spawn("pet", "RealUIPetFrame")
    pet:SetPoint("BOTTOMLEFT", "RealUIPlayerFrame", db.positions[UnitFrames.layoutSize].pet.x, db.positions[UnitFrames.layoutSize].pet.y)
end)
