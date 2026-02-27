local _, private = ...

-- Libs --
local oUF = private.oUF
local Base = _G.Aurora.Base

-- RealUI --
local RealUI = private.RealUI
local UnitFrames = RealUI:GetModule("UnitFrames")
local FramePoint = RealUI:GetModule("FramePoint")

--[[ Aura Filter ]]--
local function FilterAura(_, _, data)
    local bossDB = UnitFrames.db.profile.boss

    -- Cast by Player
    if data.isPlayerAura and bossDB.showPlayerAuras then return true end

    -- Cast by NPC
    if bossDB.showNPCAuras then
        local sourceUnit = data.sourceUnit
        if sourceUnit then
            local guid = _G.UnitGUID(sourceUnit)
            if guid then
                local unitType = _G.strsplit("-", guid)
                if unitType == "Creature" then return true end
            end
        end
    end

    return false
end

--[[ Aura Display ]]--
local function CreateAuras(parent)
    local bossDB = UnitFrames.db.profile.boss
    local iconSize = parent:GetHeight()

    -- Debuffs
    local debuffNum = bossDB.debuffCount
    local debuffSpacing = 2
    local debuffCols = _G.math.floor((parent:GetWidth() + debuffSpacing) / (iconSize + debuffSpacing))
    local debuffRows = _G.math.ceil(debuffNum / _G.math.max(debuffCols, 1))

    local Debuffs = _G.CreateFrame("Frame", nil, parent)
    Debuffs:SetPoint("BOTTOMLEFT", parent, "TOPLEFT", 0, 4)
    Debuffs:SetSize(parent:GetWidth(), debuffRows * (iconSize + debuffSpacing))
    Debuffs.num = debuffNum
    Debuffs.size = iconSize
    Debuffs.spacing = debuffSpacing
    Debuffs.initialAnchor = "BOTTOMLEFT"
    Debuffs.growthX = "RIGHT"
    Debuffs.growthY = "UP"
    Debuffs.FilterAura = FilterAura
    Debuffs.PostCreateButton = function(_, button)
        Base.CropIcon(button.Icon, button)
        button.Count:SetFontObject("NumberFont_Outline_Med")
    end
    parent.Debuffs = Debuffs

    -- Buffs
    local buffNum = bossDB.buffCount
    local buffSpacing = 2
    local buffCols = _G.math.floor((parent:GetWidth() + buffSpacing) / (iconSize + buffSpacing))
    local buffRows = _G.math.ceil(buffNum / _G.math.max(buffCols, 1))

    local Buffs = _G.CreateFrame("Frame", nil, parent)
    Buffs:SetPoint("BOTTOMRIGHT", parent, "TOPRIGHT", 0, 4)
    Buffs:SetSize(parent:GetWidth(), buffRows * (iconSize + buffSpacing))
    Buffs.num = buffNum
    Buffs.size = iconSize
    Buffs.spacing = buffSpacing
    Buffs.initialAnchor = "BOTTOMRIGHT"
    Buffs.growthX = "LEFT"
    Buffs.growthY = "UP"
    Buffs.FilterAura = FilterAura
    Buffs.PostCreateButton = function(_, button)
        Base.CropIcon(button.Icon, button)
        button.Count:SetFontObject("NumberFont_Outline_Med")
    end
    parent.Buffs = Buffs
end

UnitFrames.boss = {
    create = function(dialog)
        CreateAuras(dialog)

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
