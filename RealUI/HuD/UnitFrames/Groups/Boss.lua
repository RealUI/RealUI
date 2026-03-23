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
