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
        -- B42, second pass: centred on the health bar itself. The bar is the
        -- top 10px of a 13px frame, so any offset from the frame's BOTTOM put
        -- the text centre ~5px under the bar centre (the first pass moved it
        -- from too high to too low). Anchoring LEFT->RIGHT of Health makes
        -- the two centres coincide regardless of layoutSize or resizes.
        dialog.Name:SetPoint("LEFT", dialog.Health, "RIGHT", 9, 0)
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
