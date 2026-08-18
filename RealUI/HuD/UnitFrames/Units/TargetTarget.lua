local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
local FramePoint = RealUI:GetModule("FramePoint")
UnitFrames.targettarget = {
    create = function(dialog)
        dialog.Name = dialog.overlay:CreateFontString(nil, "OVERLAY")
        -- B42: y shifted down 5px so the name's baseline aligns with the bar
        -- (mirror of Focus: right-aligned variant, same y offset)
        dialog.Name:SetPoint("BOTTOMRIGHT", dialog, "BOTTOMLEFT", -5, -3 - UnitFrames.layoutSize)
        dialog.Name:SetFontObject("SystemFont_Shadow_Med1_Outline")
        dialog:Tag(dialog.Name, "[realui:name]")
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
    FramePoint:PositionFrame(UnitFrames, targettarget, {"profile", "units", "targettarget", "framePoint"})
end)
