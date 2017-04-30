local _, private = ...

-- Libs --
local oUF = _G.oUFembed

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
UnitFrames.focus = {
    create = function(self)
        self.Name = self.overlay:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("BOTTOMLEFT", self, "BOTTOMRIGHT", 9, 2 - UnitFrames.layoutSize)
        self.Name:SetFontObject(_G.RealUIFont_Pixel)
        self:Tag(self.Name, "[realui:name]")
    end,
    health = {
        leftVertex = 2,
        rightVertex = 4,
        point = "RIGHT"
    },
    hasCastBars = true,
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile

    local focus = oUF:Spawn("focus", "RealUIFocusFrame")
    focus:SetPoint("BOTTOMLEFT", "RealUIPlayerFrame", db.positions[UnitFrames.layoutSize].focus.x, db.positions[UnitFrames.layoutSize].focus.y)
end)
