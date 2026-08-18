local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
local FramePoint = RealUI:GetModule("FramePoint")
UnitFrames.focustarget = {
    create = function(dialog)
        dialog.Name = dialog.overlay:CreateFontString(nil, "OVERLAY")
        -- B42: y shifted down 5px so the name's baseline aligns with the bar
        dialog.Name:SetPoint("BOTTOMLEFT", dialog, "BOTTOMRIGHT", 9, -3 - UnitFrames.layoutSize)
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

    local focustarget = oUF:Spawn("focustarget", "RealUIFocusTargetFrame")
    focustarget:SetPoint("TOPLEFT", "RealUIFocusFrame", "BOTTOMLEFT", db.positions[UnitFrames.layoutSize].focustarget.x, db.positions[UnitFrames.layoutSize].focustarget.y)
    FramePoint:PositionFrame(UnitFrames, focustarget, {"profile", "units", "focustarget", "framePoint"})
end)
