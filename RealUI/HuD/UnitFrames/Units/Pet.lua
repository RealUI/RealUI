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
        -- B42, second pass: centred on the health bar, same as the rest of
        -- the small-frame family (see Focus.lua)
        dialog.Name:SetPoint("LEFT", dialog.Health, "RIGHT", 9, 0)
        dialog.Name:SetFontObject("SystemFont_Shadow_Med1_Outline")
        dialog:Tag(dialog.Name, "[realui:name]")

        -- oUF 14.1 Happiness: enables itself only for a Forever hunter's pet,
        -- so this texture stays hidden everywhere else.
        local Happiness = dialog.overlay:CreateTexture(nil, "OVERLAY")
        Happiness:SetSize(14, 14)
        Happiness:SetPoint("LEFT", dialog.Name, "RIGHT", 2, 0)
        dialog.Happiness = Happiness
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
