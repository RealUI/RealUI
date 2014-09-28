local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

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
    print("AttachStatusBar")
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
    nibRealUI:CreateBD(sBarBG)

    local timeStr = icon:CreateFontString(nil, "OVERLAY")
    timeStr:SetFont(unpack(nibRealUI.font.pixel1))
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
    if db.boss.reverseHealth then
        parent.Health:SetReverseFill(true)
        parent.Health.PostUpdate = function(self, unit, min, max)
            self:SetValue(max - self:GetValue())
        end
    end

    local healthBG = CreateBD(parent.Health, 0)
    healthBG:SetFrameStrata("LOW")
end

local function CreateTags(parent)
    parent.HealthValue = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.HealthValue:SetPoint("TOPLEFT", parent.Health, "TOPLEFT", 2.5, -6.5)
    parent.HealthValue:SetFont(unpack(nibRealUI:Font()))
    parent.HealthValue:SetJustifyH("LEFT")
    parent:Tag(parent.HealthValue, "[realui:healthPercent]")

    parent.Name = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.Name:SetPoint("TOPRIGHT", parent.Health, "TOPRIGHT", -0.5, -6.5)
    parent.Name:SetFont(unpack(nibRealUI:Font()))
    parent.Name:SetJustifyH("RIGHT")
    parent:Tag(parent.Name, "[realui:name]")
end

local function CreatePowerBar(parent)
    parent.Power = CreateFrame("StatusBar", nil, parent)
    parent.Power:SetFrameStrata("MEDIUM")
    parent.Power:SetFrameLevel(6)
    parent.Power:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 0)
    parent.Power:SetPoint("TOPLEFT", parent, "BOTTOMLEFT", 0, 2)
    parent.Power:SetStatusBarTexture(nibRealUI.media.textures.plain)
    parent.Power:SetStatusBarColor(db.overlay.colors.power["MANA"][1], db.overlay.colors.power["MANA"][2], db.overlay.colors.power["MANA"][3])
    parent.Power.colorPower = true
    parent.Power.PostUpdate = function(bar, unit, min, max)
        bar:SetShown(max > 0)
    end

    local powerBG = CreateBD(parent.Power, 0)
    powerBG:SetFrameStrata("LOW")
end

local function CreateAltPowerBar(parent)
    parent.AltPowerBar = CreateFrame("StatusBar", nil, parent)
    parent.AltPowerBar:SetFrameStrata("MEDIUM")
    parent.AltPowerBar:SetFrameLevel(6)
    parent.AltPowerBar:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 0, 3)
    parent.AltPowerBar:SetPoint("BOTTOMLEFT", parent, "BOTTOMLEFT", 0, 5)
    parent.AltPowerBar:SetStatusBarTexture(nibRealUI.media.textures.plain)
    -- AltPowerBar:SetStatusBarColor(db.overlay.colors.power["ALTERNATE"][1], db.overlay.colors.power["ALTERNATE"][2], db.overlay.colors.power["ALTERNATE"][3])
    parent.AltPowerBar.colorPower = true
    -- AltPowerBar.PostUpdate = function(bar, unit, min, max)
    -- 	bar:SetShown(max > 0)
    -- end

    local altpowerBG = CreateBD(parent.AltPowerBar, 0)
    altpowerBG:SetFrameStrata("LOW")
end

local function CreateAuras(parent)
    parent.Auras = CreateFrame("Frame", nil, parent)
    parent.Auras:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", (22) * ((db.boss.buffCount + db.boss.debuffCount) - 1) + 4, -1)
    parent.Auras:SetWidth((23) * (db.boss.buffCount + db.boss.debuffCount))
    parent.Auras:SetHeight(22)
    parent.Auras["size"] = 24
    parent.Auras["spacing"] = 1
    parent.Auras["numBuffs"] = db.boss.buffCount
    parent.Auras["numDebuffs"] = db.boss.debuffCount
    parent.Auras["growth-x"] = "LEFT"
    parent.Auras.disableCooldown = true
    parent.Auras.CustomFilter = function(self, ...)
        local _,icon,_,_,_,_,_,duration,timeLeft,caster,_,_,_,canApplyAura = ...
        if not caster then return false end
        print("CustomFilter", self, icon, duration, timeLeft, caster, canApplyAura)

        if (duration and duration > 0) then
            icon.startTime = timeLeft - duration
            icon.endTime = timeLeft
            icon.timeLeft = timeLeft
        else
            icon.endTime = nil
            icon.timeLeft = math.huge
        end
        icon.needsUpdate = true

        -- Cast by Player
        if ((caster == "player") or (caster == "vehicle")) and canApplyAura and UnitFrames.db.profile.boss.showPlayerAuras then return true end

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
    parent.Auras.PostCreateIcon = function(self, button)
        print("PostCreateIcon", self, button)
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

        button.count:SetFontObject(RealUIFontPixel)
        local countY = ndbc.resolution == 1 and -1.5 or -2.5
        button.count:SetPoint("TOPRIGHT", button, "TOPRIGHT", 1.5, countY)
    end
    parent.Auras.PostUpdateIcon = function(self, unit, icon, index)
        print("PostUpdateIcon", self, unit, icon, index)
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
    -- parent.Auras.showType = true
    -- parent.Auras.showStealableAuras = true
end

local function CreateBoss(self)
    self:SetSize(135, 22)
    CreateBD(self, 0.7)

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
