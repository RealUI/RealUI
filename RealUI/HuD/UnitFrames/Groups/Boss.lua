local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local UnitFrames = RealUI:GetModule("UnitFrames")
local FramePoint = RealUI:GetModule("FramePoint")

UnitFrames.boss = {
    create = function(dialog)

        dialog.Health.text:SetPoint("LEFT", dialog.Health, 1, 0)
        dialog.Power.displayAltPower = true

        dialog.Name = dialog.Health:CreateFontString(nil, "OVERLAY")
        dialog.Name:SetPoint("RIGHT", dialog.Health, -1, 0)
        dialog.Name:SetFontObject("SystemFont_Shadow_Med1")
        dialog.Name:SetJustifyH("RIGHT")
        dialog:Tag(dialog.Name, "[realui:name]")

        dialog.RaidTargetIndicator = dialog:CreateTexture(nil, "OVERLAY")
        dialog.RaidTargetIndicator:SetSize(20, 20)
        dialog.RaidTargetIndicator:SetPoint("CENTER", dialog)

        -- Boss Debuffs
        local db = UnitFrames.db.profile
        local Base = _G.Aurora.Base
        local debuffSize = 20
        local debuffSpacing = 2
        local debuffNum = (db.boss and db.boss.debuffCount) or 16
        local debuffCols = _G.math.floor((dialog:GetWidth() + debuffSpacing) / (debuffSize + debuffSpacing))
        local debuffRows = _G.math.ceil(debuffNum / _G.math.max(debuffCols, 1))

        local Debuffs = _G.CreateFrame("Frame", nil, dialog)
        Debuffs:SetPoint("BOTTOMLEFT", dialog, "TOPLEFT", 0, 2)
        Debuffs:SetSize(dialog:GetWidth(), debuffRows * (debuffSize + debuffSpacing))
        Debuffs.num = debuffNum
        Debuffs.size = debuffSize
        Debuffs.spacing = debuffSpacing
        Debuffs.initialAnchor = "BOTTOMLEFT"
        Debuffs.growthX = "RIGHT"
        Debuffs.growthY = "UP"
        Debuffs.PostCreateButton = function(_, button)
            Base.CropIcon(button.Icon, button)
            button.Count:SetFontObject("NumberFont_Outline_Med")
        end
        dialog.Debuffs = Debuffs

        -- Boss Buffs
        local buffSize = 18
        local buffSpacing = 2
        local buffNum = (db.boss and db.boss.buffCount) or 16
        local buffCols = _G.math.floor((dialog:GetWidth() + buffSpacing) / (buffSize + buffSpacing))
        local buffRows = _G.math.ceil(buffNum / _G.math.max(buffCols, 1))

        local Buffs = _G.CreateFrame("Frame", nil, dialog)
        Buffs:SetPoint("TOPLEFT", dialog, "BOTTOMLEFT", 0, -2)
        Buffs:SetSize(dialog:GetWidth(), buffRows * (buffSize + buffSpacing))
        Buffs.num = buffNum
        Buffs.size = buffSize
        Buffs.spacing = buffSpacing
        Buffs.initialAnchor = "TOPLEFT"
        Buffs.growthX = "RIGHT"
        Buffs.growthY = "DOWN"
        Buffs.PostCreateButton = function(_, button)
            Base.CropIcon(button.Icon, button)
            button.Count:SetFontObject("NumberFont_Outline_Med")
        end
        dialog.Buffs = Buffs
    end,
    health = {
        text = true,
    },
    power = {
    },
}

-- Init
_G.tinsert(UnitFrames.units, function()
    local db = UnitFrames.db.profile

    for i = 1, 5 do
        local boss = oUF:Spawn("boss" .. i, "RealUIBossFrame" .. i)
        if i == 1 then
            boss:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT", db.positions[UnitFrames.layoutSize].boss.x, db.positions[UnitFrames.layoutSize].boss.y)
        else
            boss:SetPoint("TOP", _G["RealUIBossFrame" .. i - 1], "BOTTOM", 0, -db.boss.gap)
        end
        FramePoint:PositionFrame(UnitFrames, boss, {"profile", "units", "boss", "framePoint"})
    end
end)
