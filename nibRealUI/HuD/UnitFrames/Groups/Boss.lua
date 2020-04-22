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
    sBar:SetValue(0)
    sBar:SetMinMaxValues(0, 1)
    sBar:SetStatusBarTexture(RealUI.textures.plain)
    sBar:SetStatusBarColor(1,1,1,1)

    sBar:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", 1, 1)
    sBar:SetPoint("TOPRIGHT", icon, "BOTTOMRIGHT", -1, 3)
    sBar:SetFrameLevel(icon:GetFrameLevel() + 2)

    local sBarBG = _G.CreateFrame("Frame", nil, sBar)
    sBarBG:SetPoint("TOPLEFT", sBar, -1, 1)
    sBarBG:SetPoint("BOTTOMRIGHT", sBar, 1, -1)
    sBarBG:SetFrameLevel(icon:GetFrameLevel() + 1)
    Base.SetBackdrop(sBarBG, Color.black, 0.7)

    local timeStr = icon:CreateFontString(nil, "OVERLAY")
    timeStr:SetFontObject("NumberFont_Outline_Med")
    timeStr:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", (unit == "pet") and 0.5 or 1.5, (unit == "pet") and 5 or 4)
    timeStr:SetJustifyH("LEFT")

    return sBar, timeStr
end

--[[ Parts ]]--
local function CreateHealthBar(parent)
    parent.Health = _G.CreateFrame("StatusBar", nil, parent)
    parent.Health:SetPoint("BOTTOMLEFT", 1, 4)
    parent.Health:SetPoint("TOPRIGHT", -1, -1)
    parent.Health:SetStatusBarTexture(RealUI.textures.plain)
    local color = parent.colors.health
    parent.Health:SetStatusBarColor(color[1], color[2], color[3], color[4])
    if not(RealUI.db.profile.settings.reverseUnitFrameBars) then
        parent.Health:SetReverseFill(true)
        parent.Health.PostUpdate = function(self, unit, cur, max)
            self:SetValue(max - self:GetValue())
        end
    end

end

local function CreateTags(parent)
    parent.HealthValue = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.HealthValue:SetPoint("LEFT", parent.Health, 1, 0)
    parent.HealthValue:SetFontObject("SystemFont_Shadow_Med1")
    parent.HealthValue:SetJustifyH("LEFT")
    parent:Tag(parent.HealthValue, "[realui:healthPercent]")

    parent.Name = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.Name:SetPoint("RIGHT", parent.Health, -1, 0)
    parent.Name:SetFontObject("SystemFont_Shadow_Med1")
    parent.Name:SetJustifyH("RIGHT")
    parent:Tag(parent.Name, "[realui:name]")
end

local function CreatePowerBar(parent)
    local power = _G.CreateFrame("StatusBar", nil, parent)
    power:SetFrameStrata("MEDIUM")
    power:SetFrameLevel(6)
    power:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -1, 1)
    power:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 1, 3)
    power:SetStatusBarTexture(RealUI.textures.plain)
    power.colorPower = true
    power.PostUpdate = function(bar, unit, cur, min, max)
        bar:SetShown(max > 0)
    end

    parent.Power = power
end

local function CreateAltPowerBar(parent)
    local altPowerBar = _G.CreateFrame("StatusBar", nil, parent)
    altPowerBar:SetFrameStrata("MEDIUM")
    altPowerBar:SetFrameLevel(6)
    altPowerBar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", -1, 4)
    altPowerBar:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 1, 6)
    altPowerBar:SetStatusBarTexture(RealUI.textures.plain)
    altPowerBar.colorPower = true
    -- altPowerBar.PostUpdate = function(bar, unit, cur, min, max)
    -- 	bar:SetShown(max > 0)
    -- end

    parent.AltPowerBar = altPowerBar
end

local function CreateAuras(parent)
    local bossDB = UnitFrames.db.profile.boss
    UnitFrames:debug("Boss:CreateAuras")
    local auras = _G.CreateFrame("Frame", nil, parent)
    auras:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", (22) * ((bossDB.buffCount + bossDB.debuffCount) - 1) + 4, 1)
    auras:SetWidth((23) * (bossDB.buffCount + bossDB.debuffCount))
    auras:SetHeight(22)
    auras.size = parent:GetHeight() - 2
    auras.spacing = 3
    auras.numBuffs = bossDB.buffCount
    auras.numDebuffs = bossDB.debuffCount
    auras["growth-x"] = "LEFT"
    auras.disableCooldown = true
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

local function CreateBoss(self)
    self:SetSize(135, 24)
    Base.SetBackdrop(self, Color.black, 0.7)

    CreateHealthBar(self)
    CreateTags(self)
    CreatePowerBar(self)
    CreateAltPowerBar(self)
    CreateAuras(self)

    self.RaidIcon = self:CreateTexture(nil, 'OVERLAY')
    self.RaidIcon:SetSize(21, 21)
    self.RaidIcon:SetPoint("LEFT", self, "RIGHT", 1, 1)

    self:SetScript("OnEnter", _G.UnitFrame_OnEnter)
    self:SetScript("OnLeave", _G.UnitFrame_OnLeave)
end

UnitFrames.boss = {
    nameLength = 135 / 10
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    oUF:RegisterStyle("RealUI:boss", CreateBoss)
    oUF:SetActiveStyle("RealUI:boss")
    for i = 1, _G.MAX_BOSS_FRAMES do
        local boss = oUF:Spawn("boss" .. i, "RealUIBossFrame" .. i)
        if (i == 1) then
            boss:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT", UnitFrames.db.profile.positions[UnitFrames.layoutSize].boss.x, UnitFrames.db.profile.positions[UnitFrames.layoutSize].boss.y)
        else
            boss:SetPoint("TOP", _G["RealUIBossFrame" .. i - 1], "BOTTOM", 0, -UnitFrames.db.profile.boss.gap)
        end
    end
end)

function RealUI:BossConfig(toggle)
    for i = 1, _G.MAX_BOSS_FRAMES do
        local f = _G["RealUIArenaFrame" .. i]
        if toggle then
            if not f.__realunit then
                f.__realunit = f:GetAttribute("unit") or f.unit
                f:SetAttribute("unit", "player")
                f.unit = "player"
                f:Show()
            end
        else
            if f.__realunit then
                f:SetAttribute("unit", f.__realunit)
                f.unit = f.__realunit
                f.__realunit = nil
                f:Hide()
            end
        end
    end
end
