local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
UnitFrames.focustarget = {
    create = function(self)
        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 2 - UnitFrames.layoutSize)
        self.Name:SetFontObject("SystemFont_Shadow_Med1_Outline")
        self:Tag(self.Name, "[realui:name]")
    end,
    health = {
        leftVertex = 2,
        rightVertex = 3,
        point = "RIGHT"
    },
    isSmall = true
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile

    local focustarget = oUF:Spawn("focustarget", "RealUIFocusTargetFrame")
    focustarget:SetPoint("TOPLEFT", "RealUIFocusFrame", "BOTTOMLEFT", db.positions[UnitFrames.layoutSize].focustarget.x, db.positions[UnitFrames.layoutSize].focustarget.y)
end)
