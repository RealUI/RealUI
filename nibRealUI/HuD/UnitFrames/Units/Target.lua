local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
UnitFrames.target = {
    create = function(dialog)
        dialog.Name = dialog.overlay:CreateFontString(nil, "OVERLAY")
        dialog.Name:SetPoint("BOTTOMRIGHT", dialog.Health, "TOPRIGHT", -12, 2)
        dialog.Name:SetFontObject("SystemFont_Shadow_Med1_Outline")
        dialog:Tag(dialog.Name, "[realui:level] [realui:name]")

        dialog.RaidTargetIndicator = dialog:CreateTexture(nil, "OVERLAY")
        dialog.RaidTargetIndicator:SetSize(20, 20)
        dialog.RaidTargetIndicator:SetPoint("BOTTOMRIGHT", dialog, "TOPLEFT", -10, 4)

        dialog.Threat = dialog.overlay:CreateFontString(nil, "OVERLAY")
        dialog.Threat:SetPoint("TOPRIGHT", dialog, "TOPLEFT", -10, -18)
        dialog.Threat:SetFontObject("SystemFont_Shadow_Med1_Outline")
        dialog:Tag(dialog.Threat, "[realui:threat]")

        dialog.Range = dialog.overlay:CreateFontString(nil, "OVERLAY")
        dialog.Range:SetPoint("TOPRIGHT", dialog, "TOPLEFT", -10, -4)
        dialog.Range:SetFontObject("SystemFont_Shadow_Med1_Outline")
        dialog.Range.frequentUpdates = true
        -- FIXBETA
        -- dialog:Tag(dialog.Range, "[realui:range]")
    end,
    health = {
        leftVertex = 2,
        rightVertex = 3,
        point = "LEFT",
        text = "[realui:health]",
        predict = true,
    },
    power = {
        leftVertex = 1,
        rightVertex = 4,
        point = "LEFT",
        text = true,
    },
    isBig = true,
    hasCastBars = true,
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile

    local target = oUF:Spawn("target", "RealUITargetFrame")
    target:SetPoint("LEFT", "RealUIPositionersUnitFrames", "RIGHT", db.positions[UnitFrames.layoutSize].target.x, db.positions[UnitFrames.layoutSize].target.y)
end)
