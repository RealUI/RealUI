local _, private = ...

-- Lua Globals --
local floor = _G.math.floor

-- Libs --
local oUF = private.oUF
local Base = _G.Aurora.Base
local Color = _G.Aurora.Color

-- RealUI --
local RealUI = private.RealUI
local UnitFrames = RealUI:GetModule("UnitFrames")

--[[ Utils ]]--
local function TimeFormat(t)
    local h, m, hplus, mplus, s, f

    h = floor(t / 3600)
    m = floor((t - (h * 3600)) / 60)
    s = floor(t - (h * 3600) - (m * 60))

    hplus = floor((t + 3599.99) / 3600)
    mplus = floor((t - (h * 3600) + 59.99) / 60) -- provides compatibility with tooltips

    if t >= 3600 then
        f = ("%.0fh"):format(hplus)
    elseif t >= 60 then
        f = ("%.0fm"):format(mplus)
    else
        f = ("%.0fs"):format(s)
    end

    return f
end

local function AttachStatusBar(icon, unit)
    --print("AttachStatusBar")
    local sBar = _G.CreateFrame("StatusBar", nil, icon)
    sBar:SetMinMaxValues(0, 1)
    sBar:SetStatusBarTexture(RealUI.textures.plain)
    sBar:SetStatusBarColor(1,1,1,1)

    sBar:SetPoint("TOPLEFT", icon, "BOTTOMLEFT", 0, 2)
    sBar:SetPoint("BOTTOMRIGHT", icon)
    sBar:SetFrameLevel(icon:GetFrameLevel() + 2)

    Base.SetBackdrop(sBar, Color.black, 0.7)
    sBar:SetBackdropOption("offsets", {
        left = -1,
        right = -1,
        top = -1,
        bottom = -1,
    })

    local timeStr = icon:CreateFontString(nil, "OVERLAY")
    timeStr:SetFontObject("NumberFont_Outline_Med")
    timeStr:SetPoint("CENTER", icon, 0, 0)
    timeStr:SetJustifyH("LEFT")

    return sBar, timeStr
end

--[[ Parts ]]--
local function CreateAuras(parent)
    local bossDB = UnitFrames.db.profile.boss
    local iconSize = parent:GetHeight()
    local frameWidth = iconSize * (bossDB.buffCount + bossDB.debuffCount)

    UnitFrames:debug("Boss:CreateAuras")
    local auras = _G.CreateFrame("Frame", nil, parent)
    auras:SetPoint("TOPRIGHT", parent, "TOPLEFT", -3, 0)
    auras:SetSize(frameWidth, iconSize)

    auras.disableCooldown = true
    auras.size = iconSize
    auras.spacing = 3
    auras["growth-x"] = "LEFT"
    auras.initialAnchor = "TOPRIGHT"

    auras.numBuffs = bossDB.buffCount
    auras.numDebuffs = bossDB.debuffCount

    auras.CustomFilter = function(self, unit, button, ...)
        --    name, texture, count, debuffType, duration, expiration, caster
        local _, _, _, _, duration, expiration, caster = ...
        if not caster then return false end
        UnitFrames:debug("Boss:CustomFilter", self, button, duration, expiration, caster)

        if duration and duration > 0 then
            button.startTime = expiration - duration
            button.endTime = expiration
        else
            button.endTime = nil
        end
        button.needsUpdate = true

        -- Cast by Player
        if button.isPlayer and UnitFrames.db.profile.boss.showPlayerAuras then return true end

        -- Cast by NPC
        if UnitFrames.db.profile.boss.showNPCAuras then
            local guid, isNPC = _G.UnitGUID(caster), false
            if guid then
                local unitType = _G.strsplit("-", guid)
                isNPC = (unitType == "Creature")
            end
            return isNPC
        end
    end
    auras.PostCreateIcon = function(self, button)
        UnitFrames:debug("Boss:PostCreateIcon", self, button)
        Base.CropIcon(button.icon, button)
        button.count:SetFontObject("NumberFont_Outline_Med")
    end
    auras.PostUpdateIcon = function(self, unit, icon, index)
        UnitFrames:debug("Boss:PostUpdateIcon", self, unit, icon, index)
        if not icon.sCooldown then
            icon.sCooldown, icon.timeStr = AttachStatusBar(icon, unit)

            icon.elapsed = 0
            icon.interval = 1/4
            icon:SetScript("OnUpdate", function(ico, elapsed)
                ico.elapsed = ico.elapsed + elapsed
                if ico.elapsed >= ico.interval then
                    ico.elapsed = 0
                    if ico.startTime and ico.endTime then
                        --print("UpdateIcon", ico.startTime, ico.endTime)
                        if ico.needsUpdate then
                            ico.sCooldown:Show()
                            ico.sCooldown:SetMinMaxValues(0, ico.endTime - ico.startTime)
                        end

                        local now = _G.GetTime()
                        ico.sCooldown:SetValue(ico.endTime - now)
                        ico.timeStr:SetText(TimeFormat(_G.ceil(ico.endTime - now)))

                        local per = (ico.endTime - now) / (ico.endTime - ico.startTime)
                        if per > 0.5 then
                            ico.sCooldown:SetStatusBarColor(1 - ((per*2)-1), 1, 0)
                        else
                            ico.sCooldown:SetStatusBarColor(1, (per*2), 0)
                        end
                    else
                        --print("HideIcon", ico.startTime, ico.endTime)
                        ico.sCooldown:Hide()
                        ico.timeStr:SetText()
                    end
                end
            end)
        end
    end
    -- auras.showType = true
    -- auras.showStealableAuras = true

    parent.Auras = auras
end

UnitFrames.boss = {
    create = function(self)
        CreateAuras(self)
        self.Health.text:SetPoint("LEFT", self.Health, 1, 0)
        self.Power.displayAltPower = true

        self.Name = self.Health:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("RIGHT", self.Health, -1, 0)
        self.Name:SetFontObject("SystemFont_Shadow_Med1")
        self.Name:SetJustifyH("RIGHT")
        self:Tag(self.Name, "[realui:name]")

        self.RaidTargetIndicator = self:CreateTexture(nil, 'OVERLAY')
        self.RaidTargetIndicator:SetSize(20, 20)
        self.RaidTargetIndicator:SetPoint("CENTER", self)
    end,
    health = {
        text = "[realui:healthPercent]",
    },
    power = {
    },
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    local db = UnitFrames.db.profile

    for i = 1, _G.MAX_BOSS_FRAMES do
        local boss = oUF:Spawn("boss" .. i, "RealUIBossFrame" .. i)
        if (i == 1) then
            boss:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT", db.positions[UnitFrames.layoutSize].boss.x, db.positions[UnitFrames.layoutSize].boss.y)
        else
            boss:SetPoint("TOP", _G["RealUIBossFrame" .. i - 1], "BOTTOM", 0, -db.boss.gap)
        end
    end
end)
