local _, private = ...

-- Libs --
local oUF = private.oUF
local Base = _G.Aurora.Base

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

        --[[ Private Auras ]]--
        local PrivateAuras = _G.CreateFrame("Frame", nil, dialog)
        PrivateAuras:SetPoint("TOPRIGHT", dialog, "BOTTOMRIGHT", -10, -30)
        PrivateAuras:SetSize(dialog:GetWidth(), 24)
        PrivateAuras.size = 22
        PrivateAuras.spacing = 2
        PrivateAuras.initialAnchor = "BOTTOMRIGHT"
        PrivateAuras.growthX = "LEFT"
        PrivateAuras.growthY = "DOWN"
        PrivateAuras.num = 6
        dialog._privateAurasFrame = PrivateAuras
        if db.misc.showPrivateAuras then
            dialog.PrivateAuras = PrivateAuras
        end

        -- Target Debuffs
        local debuffSize = (db.units.target and db.units.target.debuffSize) or 24
        local debuffSpacing = 2
        local debuffNum = (db.units.target and db.units.target.debuffCount) or 16
        local debuffLayout = (db.units.target and db.units.target.auraLayout and db.units.target.auraLayout.debuffs) or {}
        local debuffAnchor = debuffLayout.anchor or "TOPLEFT"
        local debuffGrowthX = debuffLayout.growthX or "RIGHT"
        local debuffGrowthY = debuffLayout.growthY or "UP"
        local debuffMaxWidth = debuffLayout.maxWidth or 0
        local debuffFrameWidth = (debuffMaxWidth > 0 and debuffMaxWidth) or dialog:GetWidth()
        local debuffCols = _G.math.floor((debuffFrameWidth + debuffSpacing) / (debuffSize + debuffSpacing))
        local debuffRows = _G.math.ceil(debuffNum / _G.math.max(debuffCols, 1))

        local Debuffs = _G.CreateFrame("Frame", nil, dialog)

        Debuffs:SetSize(debuffFrameWidth, debuffRows * (debuffSize + debuffSpacing))
        Debuffs.num = debuffNum
        Debuffs.size = debuffSize
        Debuffs.spacing = debuffSpacing
        Debuffs.initialAnchor = UnitFrames.GetInitialAnchor(debuffGrowthX, debuffGrowthY)
        UnitFrames.SetAuraPosition(Debuffs, dialog, debuffAnchor, Debuffs.initialAnchor)
        Debuffs.growthX = debuffGrowthX
        Debuffs.growthY = debuffGrowthY
        Debuffs.PostCreateButton = function(_, button)
            Base.CropIcon(button.Icon, button)
            button.Count:SetFontObject("NumberFont_Outline_Med")
        end
        dialog.Debuffs = Debuffs

        -- Target Buffs
        local buffSize = (db.units.target and db.units.target.buffSize) or 20
        local buffSpacing = 2
        local buffNum = (db.units.target and db.units.target.buffCount) or 16
        local buffLayout = (db.units.target and db.units.target.auraLayout and db.units.target.auraLayout.buffs) or {}
        local buffAnchor = buffLayout.anchor or "TOPRIGHT"
        local buffGrowthX = buffLayout.growthX or "LEFT"
        local buffGrowthY = buffLayout.growthY or "UP"
        local buffMaxWidth = buffLayout.maxWidth or 0
        local buffFrameWidth = (buffMaxWidth > 0 and buffMaxWidth) or dialog:GetWidth()
        local buffCols = _G.math.floor((buffFrameWidth + buffSpacing) / (buffSize + buffSpacing))
        local buffRows = _G.math.ceil(buffNum / _G.math.max(buffCols, 1))

        local Buffs = _G.CreateFrame("Frame", nil, dialog)

        Buffs:SetSize(buffFrameWidth, buffRows * (buffSize + buffSpacing))
        Buffs.num = buffNum
        Buffs.size = buffSize
        Buffs.spacing = buffSpacing
        Buffs.initialAnchor = UnitFrames.GetInitialAnchor(buffGrowthX, buffGrowthY)
        UnitFrames.SetAuraPosition(Buffs, dialog, buffAnchor, Buffs.initialAnchor)
        Buffs.growthX = buffGrowthX
        Buffs.growthY = buffGrowthY
        Buffs.PostCreateButton = function(_, button)
            Base.CropIcon(button.Icon, button)
            button.Count:SetFontObject("NumberFont_Outline_Med")
        end
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
