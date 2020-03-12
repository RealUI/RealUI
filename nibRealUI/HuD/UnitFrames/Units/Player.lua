local _, private = ...

-- Libs --
local oUF = private.oUF

-- RealUI --
local RealUI = private.RealUI
local db

local UnitFrames = RealUI:GetModule("UnitFrames")

local function CreateTotems(parent)
    -- DestroyTotem is protected, so we hack the default
    local totemBar = _G["TotemFrame"]
    totemBar:SetParent(parent.overlay)
    _G.hooksecurefunc("TotemFrame_Update", function()
        totemBar:ClearAllPoints()
        totemBar:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 10, -4)
    end)
    for i = 1, 4 do
        local name = "TotemFrameTotem"..i
        local totem = _G[name]
        totem:SetSize(22, 22)
        totem:ClearAllPoints()
        totem:SetPoint("TOPLEFT", totemBar, i * (totem:GetWidth() + 3), 0)

        local bg = _G[name.."Background"]
        bg:SetPoint("TOPLEFT", -1, 1)
        bg:SetPoint("BOTTOMRIGHT", 1, -1)
        bg:SetColorTexture(0, 0, 0)

        local dur = _G[name.."Duration"]
        dur:Hide()
        dur.Show = function() end

        local icon = _G[name.."IconTexture"]
        icon:SetTexCoord(.08, .92, .08, .92)
        icon:ClearAllPoints()
        icon:SetAllPoints()

        local _, border = totem:GetChildren()
        border:DisableDrawLayer("OVERLAY")
    end
end

UnitFrames.player = {
    create = function(self)
        CreateTotems(self)

        --[[ Additional Power ]]--
        local AdditionalPower = _G.CreateFrame("StatusBar", nil, self.Power)
        AdditionalPower:SetStatusBarTexture(RealUI.textures.plain, "BORDER")
        AdditionalPower:SetStatusBarColor(0, 0, 0, 0.75)
        AdditionalPower:SetPoint("BOTTOMLEFT", self.Power, "TOPLEFT", 0, 0)
        AdditionalPower:SetPoint("BOTTOMRIGHT", self.Power, "TOPRIGHT", -self.Power:GetHeight(), 0)
        AdditionalPower:SetHeight(1)

        local bg = AdditionalPower:CreateTexture(nil, 'BACKGROUND')
        bg:SetAllPoints(AdditionalPower)
        bg:SetColorTexture(.2, .2, 1)

        function AdditionalPower.PostUpdate(this, unit, cur, max)
            if cur == max then
                if this:IsVisible() then
                    this:Hide()
                end
            else
                if not this:IsVisible() then
                    this:Show()
                end
            end
        end

        AdditionalPower.colorPower = true

        self.AdditionalPower = AdditionalPower
        self.AdditionalPower.bg = bg

        --[[ PvP Timer ]]--
        local pvp = self.PvP
        pvp.text = pvp:CreateFontString(nil, "OVERLAY")
        pvp.text:SetPoint("BOTTOMLEFT", self.Health, "TOPLEFT", 15, 2)
        pvp.text:SetFontObject("SystemFont_Shadow_Med1_Outline")
        pvp.text:SetJustifyH("LEFT")
        pvp.text.frequentUpdates = 1
        self:Tag(pvp.text, "[realui:pvptimer]")

        --[[ Raid Icon ]]--
        self.RaidTargetIndicator = self:CreateTexture(nil, "OVERLAY")
        self.RaidTargetIndicator:SetSize(20, 20)
        self.RaidTargetIndicator:SetPoint("BOTTOMLEFT", self, "TOPRIGHT", 10, 4)

        --[[ Class Resource ]]--
        local ClassResource = RealUI:GetModule("ClassResource")
        if ClassResource:IsEnabled() then
            ClassResource:Setup(self, self.unit)
        end
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
    },
    isBig = true,
    hasCastBars = true,
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile

    local player = oUF:Spawn("player", "RealUIPlayerFrame")
    player:SetPoint("RIGHT", "RealUIPositionersUnitFrames", "LEFT", db.positions[UnitFrames.layoutSize].player.x, db.positions[UnitFrames.layoutSize].player.y)
    player:RegisterEvent("PLAYER_FLAGS_CHANGED", player.AwayIndicator.Override)
    player:RegisterEvent("UPDATE_SHAPESHIFT_FORM", player.PostUpdate, true)
end)
