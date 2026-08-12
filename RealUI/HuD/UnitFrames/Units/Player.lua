local _, private = ...

-- Libs --
local oUF = private.oUF


-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")
local CombatFader = RealUI:GetModule("CombatFader")
local FramePoint = RealUI:GetModule("FramePoint")

local PLAYER_CLASS = _G.UnitClassBase and _G.UnitClassBase('player')

local function CreateTotems(parent)
    local container = _G.CreateFrame("Frame", nil, parent)
    container:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 10, -4)
    container:SetSize(4 * 22 + 3 * 3, 22) -- 4 icons * size + 3 gaps
    CombatFader:RegisterFrameForFade("UnitFrames", container)

    local Totems = {}
    for index = 1, 4 do
        local totem = _G.CreateFrame("Button", nil, container)
        totem:SetSize(22, 22)
        totem:SetPoint("TOPLEFT", container, "TOPLEFT", (index - 1) * 25, 0)

        local bg = totem:CreateTexture(nil, "BACKGROUND")
        bg:SetPoint("TOPLEFT", -1, 1)
        bg:SetPoint("BOTTOMRIGHT", 1, -1)
        bg:SetColorTexture(0, 0, 0)

        local icon = totem:CreateTexture(nil, "BORDER")
        icon:SetTexCoord(.08, .92, .08, .92)
        icon:SetAllPoints()
        totem.Icon = icon

        local cooldown = _G.CreateFrame("Cooldown", nil, totem, "CooldownFrameTemplate")
        cooldown:SetAllPoints()
        cooldown:SetDrawEdge(false)
        cooldown:SetDrawSwipe(true)
        totem.Cooldown = cooldown

        Totems[index] = totem
    end

    parent.Totems = Totems
end

UnitFrames.player = {
    create = function(dialog)
        if PLAYER_CLASS == 'SHAMAN' then
            CreateTotems(dialog)
        end

        --[[ Additional Power ]]--
        local AdditionalPower = _G.CreateFrame("StatusBar", nil, dialog.Power)
        AdditionalPower:SetStatusBarTexture(RealUI.textures.plain, "BORDER")
        AdditionalPower:SetStatusBarColor(0, 0, 0, 0.75)
        AdditionalPower:SetPoint("BOTTOMLEFT", dialog.Power, "TOPLEFT", 0, 0)
        AdditionalPower:SetPoint("BOTTOMRIGHT", dialog.Power, "TOPRIGHT", -dialog.Power:GetHeight(), 0)
        AdditionalPower:SetHeight(1)

        -- local bg = AdditionalPower:CreateTexture(nil, 'BACKGROUND')
        -- bg:SetAllPoints(AdditionalPower)
        -- bg:SetColorTexture(.2, .2, 1)

        -- function AdditionalPower.PostUpdate(this, cur, max)
        --     if cur == max then
        --         if this:IsVisible() then
        --             this:Hide()
        --         end
        --     else
        --         if not this:IsVisible() then
        --             this:Show()
        --         end
        --     end
        -- end

        AdditionalPower.colorPower = true
        AdditionalPower.displayPairs = {
            DRUID = {
                [_G.Enum.PowerType.LunarPower] = true,
                [_G.Enum.PowerType.Rage] = true,
                [_G.Enum.PowerType.Energy] = true,
            },
            PRIEST = {
                [_G.Enum.PowerType.Insanity] = true,
            },
            SHAMAN = {
                [_G.Enum.PowerType.Maelstrom] = true,
            },
        }

        dialog.AdditionalPower = AdditionalPower
        -- dialog.AdditionalPower.bg = bg

        --[[ PvP Timer ]]--
        local pvp = dialog.PvPIndicator
        pvp.text = pvp:CreateFontString(nil, "OVERLAY")
        pvp.text:SetPoint("BOTTOMLEFT", dialog.Health, "TOPLEFT", 15, 2)
        pvp.text:SetFontObject("SystemFont_Shadow_Med1_Outline")
        pvp.text:SetJustifyH("LEFT")
        pvp.text.frequentUpdates = 1
        dialog:Tag(pvp.text, "[realui:pvptimer]")

        --[[ Raid Icon ]]--
        dialog.RaidTargetIndicator = dialog:CreateTexture(nil, "OVERLAY")
        dialog.RaidTargetIndicator:SetSize(20, 20)
        dialog.RaidTargetIndicator:SetPoint("BOTTOMLEFT", dialog, "TOPRIGHT", 10, 4)

        --[[ Private Auras ]]--
        local PrivateAuras = _G.CreateFrame("Frame", nil, dialog)
        PrivateAuras:SetPoint("TOPLEFT", dialog, "BOTTOMLEFT", 10, -30)
        PrivateAuras:SetSize(dialog:GetWidth(), 24)
        PrivateAuras.size = 22
        PrivateAuras.spacing = 2
        PrivateAuras.initialAnchor = "BOTTOMLEFT"
        PrivateAuras.growthX = "RIGHT"
        PrivateAuras.growthY = "DOWN"
        PrivateAuras.num = 6
        dialog._privateAurasFrame = PrivateAuras
        if db.misc.showPrivateAuras then
            dialog.PrivateAuras = PrivateAuras
        end

        --[[ Class Resource ]]--
        RealUI:GetModule("ClassResource"):Setup(dialog, "player")

        --[[ Player Buffs ]]--
        -- oUF 14: AuraContainer element via the shared helper
        local buffLayout = (db.units.player and db.units.player.auraLayout and db.units.player.auraLayout.buffs) or {}
        local buffGrowthX = buffLayout.growthX or "RIGHT"
        local buffGrowthY = buffLayout.growthY or "UP"

        local Buffs = UnitFrames.CreateAuraElement(dialog, {
            filter = "HELPFUL",
            count = (db.units.player and db.units.player.buffCount) or 16,
            size = (db.units.player and db.units.player.buffSize) or 20,
            spacing = 2,
            growthX = buffGrowthX,
            growthY = buffGrowthY,
            maxWidth = buffLayout.maxWidth or 0,
            -- combat-legal right-click cancel (oUF 14); a
            -- RegisterForClicks-style string, not a boolean
            cancelButton = "RightButtonUp",
        })
        UnitFrames.SetAuraPosition(Buffs, dialog, buffLayout.anchor or "TOPLEFT",
            UnitFrames.GetInitialAnchor(buffGrowthX, buffGrowthY))
        dialog.Buffs = Buffs
    end,
    health = {
        leftVertex = 1,
        rightVertex = 4,
        point = "RIGHT",
        text = true,
    },
    power = {
        leftVertex = 2,
        rightVertex = 3,
        point = "RIGHT",
        text = true,
    },
    isBig = true,
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile

    local player = oUF:Spawn("player", "RealUIPlayerFrame")
    player:SetPoint("RIGHT", "RealUIPositionersUnitFrames", "LEFT", db.positions[UnitFrames.layoutSize].player.x, db.positions[UnitFrames.layoutSize].player.y)
    player:RegisterEvent("PLAYER_FLAGS_CHANGED", player.AwayIndicator.Override)
    player:RegisterEvent("UPDATE_SHAPESHIFT_FORM", player.PostUpdate, true)
    FramePoint:PositionFrame(UnitFrames, player, {"profile", "units", "player", "framePoint"})
end)
