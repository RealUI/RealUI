local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
local FramePoint = RealUI:GetModule("FramePoint")
UnitFrames.pet = {
    create = function(dialog)
        dialog.Name = dialog.overlay:CreateFontString(nil, "OVERLAY")
        dialog.Name:SetPoint("BOTTOMLEFT", dialog, "BOTTOMRIGHT", 9, 2 - UnitFrames.layoutSize)
        dialog.Name:SetFontObject("SystemFont_Shadow_Med1_Outline")
        dialog:Tag(dialog.Name, "[realui:name]")
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

    local pet = oUF:Spawn("pet", "RealUIPetFrame")
    pet:SetPoint("BOTTOMLEFT", "RealUIPlayerFrame", db.positions[UnitFrames.layoutSize].pet.x, db.positions[UnitFrames.layoutSize].pet.y)
    FramePoint:PositionFrame(UnitFrames, pet, {"profile", "units", "pet", "framePoint"})
end)
