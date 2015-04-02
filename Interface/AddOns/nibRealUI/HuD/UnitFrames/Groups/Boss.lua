local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local F, C = Aurora[1], Aurora[2]

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local db, ndb, ndbc

local oUF = oUFembed

--[[ Utils ]]--
local function TimeFormat(t)
    local h, m, hplus, mplus, s, ts, f

    h = math.floor(t / 3600)
    m = math.floor((t - (h * 3600)) / 60)
    s = math.floor(t - (h * 3600) - (m * 60))

    hplus = math.floor((t + 3599.99) / 3600)
    mplus = math.floor((t - (h * 3600) + 59.99) / 60) -- provides compatibility with tooltips

    if t >= 3600 then
        f = string.format("%.0fh", hplus)
    elseif t >= 60 then
        f = string.format("%.0fm", mplus)
    else
        f = string.format("%.0fs", s)
    end

    return f
end

local function CreateBD(parent, alpha)
    local bg = CreateFrame("Frame", nil, parent)
    bg:SetFrameStrata("LOW")
    bg:SetFrameLevel(parent:GetFrameLevel() - 1)
    bg:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 1, -1)
    bg:SetPoint("TOPLEFT", parent, "TOPLEFT", -1, 1)
    bg:SetBackdrop({bgFile = nibRealUI.media.textures.plain, edgeFile = nibRealUI.media.textures.plain, edgeSize = 1, insets = {top = 0, bottom = 0, left = 0, right = 0}})
    bg:SetBackdropColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], alpha or nibRealUI.media.background[4])
    bg:SetBackdropBorderColor(0, 0, 0, 1)
    return bg
end

local function AttachStatusBar(icon, unit)
    --print("AttachStatusBar")
    local sBar = CreateFrame("StatusBar", nil, icon)
    sBar:SetValue(0)
    sBar:SetMinMaxValues(0, 1)
    sBar:SetStatusBarTexture(nibRealUI.media.textures.plain)
    sBar:SetStatusBarColor(1,1,1,1)

    sBar:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", 1, 1)
    sBar:SetPoint("TOPRIGHT", icon, "BOTTOMRIGHT", -1, 3)
    sBar:SetFrameLevel(icon:GetFrameLevel() + 2)

    local sBarBG = CreateFrame("Frame", nil, sBar)
    sBarBG:SetPoint("TOPLEFT", sBar, -1, 1)
    sBarBG:SetPoint("BOTTOMRIGHT", sBar, 1, -1)
    sBarBG:SetFrameLevel(icon:GetFrameLevel() + 1)
    F.CreateBD(sBarBG)

    local timeStr = icon:CreateFontString(nil, "OVERLAY")
    timeStr:SetFontObject(RealUIFont_PixelSmall)
    timeStr:SetPoint("BOTTOMLEFT", icon, "BOTTOMLEFT", (unit == "pet") and 0.5 or 1.5, (unit == "pet") and 5 or 4)
    timeStr:SetJustifyH("LEFT")

    return sBar, timeStr
end

--[[ Parts ]]--
local function CreateHealthBar(parent)
    parent.Health = CreateFrame("StatusBar", nil, parent)
    parent.Health:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 3)
    parent.Health:SetPoint("TOPRIGHT", parent, "TOPRIGHT", 0, 0)
    parent.Health:SetStatusBarTexture(nibRealUI.media.textures.plain)
    parent.Health:SetStatusBarColor(unpack(db.overlay.colors.health.normal))
    parent.Health.frequentUpdates = true
    if not(ndb.settings.reverseUnitFrameBars) then
        parent.Health:SetReverseFill(true)
        parent.Health.PostUpdate = function(self, unit, min, max)
            self:SetValue(max - self:GetValue())
        end
    end

    local healthBG = F.CreateBD(parent.Health, 0)
    healthBG:SetFrameStrata("LOW")
end

local function CreateTags(parent)
    parent.HealthValue = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.HealthValue:SetPoint("TOPLEFT", parent.Health, "TOPLEFT", 2.5, -6.5)
    parent.HealthValue:SetFontObject(RealUIFont_Pixel)
    parent.HealthValue:SetJustifyH("LEFT")
    parent:Tag(parent.HealthValue, "[realui:healthPercent]")

    parent.Name = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.Name:SetPoint("TOPRIGHT", parent.Health, "TOPRIGHT", -0.5, -6.5)
    parent.Name:SetFontObject(RealUIFont_Pixel)
    parent.Name:SetJustifyH("RIGHT")
    parent:Tag(parent.Name, "[realui:name]")
end

local function CreatePowerBar(parent)
    local power = CreateFrame("StatusBar", nil, parent)
    power:SetFrameStrata("MEDIUM")
    power:SetFrameLevel(6)
    power:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    power:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 2)
    power:SetStatusBarTexture(nibRealUI.media.textures.plain)
    power:SetStatusBarColor(db.overlay.colors.power["MANA"][1], db.overlay.colors.power["MANA"][2], db.overlay.colors.power["MANA"][3])
    power.colorPower = true
    power.PostUpdate = function(bar, unit, min, max)
        bar:SetShown(max > 0)
    end

    local powerBG = F.CreateBD(power, 0)
    powerBG:SetFrameStrata("LOW")

    parent.Power = power
end

local function CreateAltPowerBar(parent)
    local altPowerBar = CreateFrame("StatusBar", nil, parent)
    altPowerBar:SetFrameStrata("MEDIUM")
    altPowerBar:SetFrameLevel(6)
    altPowerBar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 3)
    altPowerBar:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 5)
    altPowerBar:SetStatusBarTexture(nibRealUI.media.textures.plain)
    -- altPowerBar:SetStatusBarColor(db.overlay.colors.power["ALTERNATE"][1], db.overlay.colors.power["ALTERNATE"][2], db.overlay.colors.power["ALTERNATE"][3])
    altPowerBar.colorPower = true
    -- altPowerBar.PostUpdate = function(bar, unit, min, max)
    -- 	bar:SetShown(max > 0)
    -- end

    local altpowerBG = F.CreateBD(altPowerBar, 0)
    altpowerBG:SetFrameStrata("LOW")

    parent.AltPowerBar = altPowerBar
end

local function CreateAuras(parent)
    UnitFrames:debug("Boss:CreateAuras")
    local auras = CreateFrame("Frame", nil, parent)
    auras:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", (22) * ((db.boss.buffCount + db.boss.debuffCount) - 1) + 4, -1)
    auras:SetWidth((23) * (db.boss.buffCount + db.boss.debuffCount))
    auras:SetHeight(22)
    auras.size = 24
    auras.spacing = 1
    auras.numBuffs = db.boss.buffCount
    auras.numDebuffs = db.boss.debuffCount
    auras["growth-x"] = "LEFT"
    auras.disableCooldown = true
    auras.CustomFilter = function(self, ...)
        --    unit, icon, name, rank, texture, count, dtype, duration, timeLeft, caster, isStealable, shouldConsolidate, spellID, canApplyAura, isBossDebuff
        local _, icon, _, _, _, _, _, duration, timeLeft, caster = ...
        if not caster then return false end
        UnitFrames:debug("Boss:CustomFilter", self, icon, duration, timeLeft, caster)

        if (duration and duration > 0) then
            icon.startTime = timeLeft - duration
            icon.endTime = timeLeft
        else
            icon.endTime = nil
        end
        icon.needsUpdate = true

        -- Cast by Player
        if icon.isPlayer and UnitFrames.db.profile.boss.showPlayerAuras then return true end

        -- Cast by NPC
        if UnitFrames.db.profile.boss.showNPCAuras then
            local guid, isNPC = UnitGUID(caster), false
            if guid then
                local unitType = strsplit("-", guid)
                isNPC = (unitType == "Creature")
            end
            return isNPC
        end
    end
    auras.PostCreateIcon = function(self, button)
        UnitFrames:debug("Boss:PostCreateIcon", self, button)
        button.icon:SetTexCoord(.08, .92, .08, .92)
        button.border = CreateFrame("Frame", nil, button)
        button.border:SetAllPoints(button)
        button.border:SetBackdrop({
            bgFile = nibRealUI.media.textures.plain,
            edgeFile = nibRealUI.media.textures.plain,
            edgeSize = 1,
            insets = {top = 1, bottom = -1, left = -1, right = 1}
        })
        button.border:SetBackdropColor(0, 0, 0, 0)
        button.border:SetBackdropBorderColor(0, 0, 0, 1)

        button.count:SetFontObject(RealUIFont_PixelSmall)
        local countY = ndbc.resolution == 1 and -1.5 or -2.5
        button.count:SetPoint("TOPRIGHT", button, "TOPRIGHT", 1.5, countY)
    end
    auras.PostUpdateIcon = function(self, unit, icon, index)
        UnitFrames:debug("Boss:PostUpdateIcon", self, unit, icon, index)
        if not icon.sCooldown then
            icon.sCooldown, icon.timeStr = AttachStatusBar(icon, unit)

            icon.elapsed = 0
            icon.interval = 1/4
            icon:SetScript("OnUpdate", function(self, elapsed)
                self.elapsed = self.elapsed + elapsed
                if self.elapsed >= self.interval then
                    self.elapsed = 0
                    if self.startTime and self.endTime then
                        --print("UpdateIcon", self.startTime, self.endTime)
                        if self.needsUpdate then
                            self.sCooldown:Show()
                            self.sCooldown:SetMinMaxValues(0, self.endTime - self.startTime)
                        end

                        local now = GetTime()
                        self.sCooldown:SetValue(self.endTime - now)
                        self.timeStr:SetText(TimeFormat(ceil(self.endTime - now)))

                        local per = (self.endTime - now) / (self.endTime - self.startTime)
                        if per > 0.5 then
                            self.sCooldown:SetStatusBarColor(1 - ((per*2)-1), 1, 0)
                        else
                            self.sCooldown:SetStatusBarColor(1, (per*2), 0)
                        end
                    else
                        --print("HideIcon", self.startTime, self.endTime)
                        self.sCooldown:Hide()
                        self.timeStr:SetText()
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
    self:SetSize(135, 22)
    F.CreateBD(self, 0.7)

    CreateHealthBar(self)
    CreateTags(self)
    CreatePowerBar(self)
    CreateAltPowerBar(self)
    CreateAuras(self)

    self.RaidIcon = self:CreateTexture(nil, 'OVERLAY')
    self.RaidIcon:SetSize(21, 21)
    self.RaidIcon:SetPoint("LEFT", self, "RIGHT", 1, 1)

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
end

-- Init
tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char

    oUF:RegisterStyle("RealUI:boss", CreateBoss)
    oUF:SetActiveStyle("RealUI:boss")
    for i = 1, MAX_BOSS_FRAMES do
        local boss = oUF:Spawn("boss" .. i, "RealUIBossFrame" .. i)
        if (i == 1) then
            boss:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT", db.positions[UnitFrames.layoutSize].boss.x, db.positions[UnitFrames.layoutSize].boss.y)
        else
            boss:SetPoint("TOP", _G["RealUIBossFrame" .. i - 1], "BOTTOM", 0, -db.boss.gap)
        end
    end
end)

function RealUIUFBossConfig(toggle)
    for i = 1, MAX_BOSS_FRAMES do
        local f = _G["RealUIBossFrame" .. i]
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
