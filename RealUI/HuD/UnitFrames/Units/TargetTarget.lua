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
        -- B42, second pass: centred on the health bar (see Focus.lua);
        -- mirror of Focus, name sits to the LEFT of the bar
        dialog.Name:SetPoint("RIGHT", dialog.Health, "LEFT", -5, 0)
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
