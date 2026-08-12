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

        -- Boss Debuffs (oUF 14: AuraContainer elements; boss anchors are
        -- fixed, so positioning stays a direct SetPoint here)
        local db = UnitFrames.db.profile

        local Debuffs = UnitFrames.CreateAuraElement(dialog, {
            filter = "HARMFUL",
            count = (db.boss and db.boss.debuffCount) or 16,
            size = (db.boss and db.boss.debuffSize) or 20,
            spacing = 2,
            growthX = "RIGHT",
            growthY = "UP",
        })
        Debuffs:SetPoint("BOTTOMLEFT", dialog, "TOPLEFT", 0, 2)
        dialog.Debuffs = Debuffs

        -- Boss Buffs
        local Buffs = UnitFrames.CreateAuraElement(dialog, {
            filter = "HELPFUL",
            count = (db.boss and db.boss.buffCount) or 16,
            size = (db.boss and db.boss.buffSize) or 20,
            spacing = 2,
            growthX = "RIGHT",
            growthY = "DOWN",
        })
        Buffs:SetPoint("TOPLEFT", dialog, "BOTTOMLEFT", 0, -2)
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
            FramePoint:PositionFrame(UnitFrames, boss, {"profile", "units", "boss", "framePoint"})
        else
            boss:SetPoint("TOP", _G["RealUIBossFrame" .. i - 1], "BOTTOM", 0, -db.boss.gap)
        end
    end
end)
