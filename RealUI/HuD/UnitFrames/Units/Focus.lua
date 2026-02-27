local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
local FramePoint = RealUI:GetModule("FramePoint")
UnitFrames.focus = {
    create = function(dialog)
        dialog.Name = dialog.overlay:CreateFontString(nil, "OVERLAY")
        dialog.Name:SetPoint("BOTTOMLEFT", dialog, "BOTTOMRIGHT", 9, 2 - UnitFrames.layoutSize)
        dialog.Name:SetFontObject("SystemFont_Shadow_Med1_Outline")
        dialog:Tag(dialog.Name, "[realui:name]")
    end,
    health = {
        leftVertex = 2,
        rightVertex = 4,
        point = "RIGHT"
    },
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile

    local focus = oUF:Spawn("focus", "RealUIFocusFrame")
    focus:SetPoint("BOTTOMLEFT", "RealUIPlayerFrame", db.positions[UnitFrames.layoutSize].focus.x, db.positions[UnitFrames.layoutSize].focus.y)
    FramePoint:PositionFrame(UnitFrames, focus, {"profile", "units", "focus", "framePoint"})
end)
