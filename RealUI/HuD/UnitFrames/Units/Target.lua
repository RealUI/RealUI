local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
local FramePoint = RealUI:GetModule("FramePoint")
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
        dialog:Tag(dialog.Range, "[realui:range]")

        -- No PrivateAuras element here: private aura anchors for external
        -- units ("target", "focus", "boss") crash Blizzard's aura code since
        -- the 2026-07-21 client patch — see known-wow-ui-bugs.md #5.

        -- Target Debuffs (oUF 14: AuraContainer elements via the shared helper)
        local debuffLayout = (db.units.target and db.units.target.auraLayout and db.units.target.auraLayout.debuffs) or {}
        local debuffGrowthX = debuffLayout.growthX or "RIGHT"
        local debuffGrowthY = debuffLayout.growthY or "UP"

        local Debuffs = UnitFrames.CreateAuraElement(dialog, {
            filter = "HARMFUL",
            count = (db.units.target and db.units.target.debuffCount) or 16,
            size = (db.units.target and db.units.target.debuffSize) or 20,
            spacing = 2,
            growthX = debuffGrowthX,
            growthY = debuffGrowthY,
            maxWidth = debuffLayout.maxWidth or 0,
        })
        UnitFrames.SetAuraPosition(Debuffs, dialog, debuffLayout.anchor or "TOPLEFT",
            UnitFrames.GetInitialAnchor(debuffGrowthX, debuffGrowthY))
        dialog.Debuffs = Debuffs

        -- Target Buffs
        local buffLayout = (db.units.target and db.units.target.auraLayout and db.units.target.auraLayout.buffs) or {}
        local buffGrowthX = buffLayout.growthX or "LEFT"
        local buffGrowthY = buffLayout.growthY or "UP"

        local Buffs = UnitFrames.CreateAuraElement(dialog, {
            filter = "HELPFUL",
            count = (db.units.target and db.units.target.buffCount) or 16,
            size = (db.units.target and db.units.target.buffSize) or 20,
            spacing = 2,
            growthX = buffGrowthX,
            growthY = buffGrowthY,
            maxWidth = buffLayout.maxWidth or 0,
        })
        UnitFrames.SetAuraPosition(Buffs, dialog, buffLayout.anchor or "TOPRIGHT",
            UnitFrames.GetInitialAnchor(buffGrowthX, buffGrowthY))
        dialog.Buffs = Buffs
    end,
    health = {
        leftVertex = 2,
        rightVertex = 3,
        point = "LEFT",
        text = true,
    },
    power = {
        leftVertex = 1,
        rightVertex = 4,
        point = "LEFT",
        text = true,
    },
    isBig = true,
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile

    local target = oUF:Spawn("target", "RealUITargetFrame")
    target:SetPoint("LEFT", "RealUIPositionersUnitFrames", "RIGHT", db.positions[UnitFrames.layoutSize].target.x, db.positions[UnitFrames.layoutSize].target.y)
    FramePoint:PositionFrame(UnitFrames, target, {"profile", "units", "target", "framePoint"})
end)
