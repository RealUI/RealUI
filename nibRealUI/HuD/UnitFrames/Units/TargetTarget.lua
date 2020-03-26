local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
UnitFrames.targettarget = {
    create = function(self)
        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", -5, 2 - UnitFrames.layoutSize)
        self.Name:SetFontObject("SystemFont_Shadow_Med1_Outline")
        self:Tag(self.Name, "[realui:name]")
    end,
    health = {
        leftVertex = 2,
        rightVertex = 4,
        point = "LEFT"
    },
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile

    local targettarget = oUF:Spawn("targettarget", "RealUITargetTargetFrame")
    targettarget:SetPoint("BOTTOMRIGHT", "RealUITargetFrame", db.positions[UnitFrames.layoutSize].targettarget.x, db.positions[UnitFrames.layoutSize].targettarget.y)
end)
