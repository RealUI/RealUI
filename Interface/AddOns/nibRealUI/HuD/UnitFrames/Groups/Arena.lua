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

local function UpdateTrinket(self, unitID, spell, rank, lineID, spellID)
    if spellID == 59752 or spellID == 42292 then
        local startTime, duration = GetSpellCooldown(spellID)
        self.Trinket.startTime = startTime
        self.Trinket.endTime = startTime + duration
        if db.arena.announceUse then
            SendChatMessage("Trinket used by: "..GetUnitName(unitID, true), "PARTY")
        end
    end
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

local function CreateTrinket(parent)
    parent.Trinket = CreateFrame("Frame", nil, parent)
    parent.Trinket:SetHeight(24)
    parent.Trinket:SetWidth(24)
    parent.Trinket:SetBackdrop({
        bgFile = nibRealUI.media.textures.plain,
        edgeFile = nibRealUI.media.textures.plain,
        edgeSize = 1,
        insets = {top = 1, bottom = -1, left = -1, right = 1}
    })
    parent.Trinket:SetBackdropColor(0, 0, 0, 0)
    parent.Trinket:SetBackdropBorderColor(0, 0, 0, 1)
    parent.Trinket:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -2, -1)
    parent.Trinket:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= self.interval then
            self.elapsed = 0
            if self.startTime and self.endTime then
                --print("UpdateIcon", self.startTime, self.endTime)
                if self.needsUpdate then
                    self.timer:Show()
                    self.timer:SetMinMaxValues(0, self.endTime - self.startTime)
                end

                local now = GetTime()
                self.timer:SetValue(self.endTime - now)
                self.text:SetText(TimeFormat(ceil(self.endTime - now)))

                local per = (self.endTime - now) / (self.endTime - self.startTime)
                if per > 0.5 then
                    self.timer:SetStatusBarColor(1 - ((per*2)-1), 1, 0)
                else
                    self.timer:SetStatusBarColor(1, (per*2), 0)
                end
            else
                --print("HideIcon", self.startTime, self.endTime)
                self.timer:Hide()
                self.text:SetText()
            end
        end
    end)
    parent.Trinket.elapsed = 0
    parent.Trinket.interval = 1/4

    parent.Trinket.icon = parent.Trinket:CreateTexture(nil, "BACKGROUND")
    parent.Trinket.icon:SetAllPoints()
    parent.Trinket.icon:SetTexture([[Interface\Icons\PVPCurrency-Conquest-Horde]])
    parent.Trinket.icon:SetTexCoord(.08, .92, .08, .92)

    parent.Trinket.timer = CreateFrame("StatusBar", nil, parent.Trinket)
    parent.Trinket.timer:SetMinMaxValues(0, 1)
    parent.Trinket.timer:SetStatusBarTexture(nibRealUI.media.textures.plain)
    parent.Trinket.timer:SetStatusBarColor(1,1,1,1)

    parent.Trinket.timer:SetPoint("BOTTOMLEFT", parent.Trinket, "BOTTOMLEFT", 1, 1)
    parent.Trinket.timer:SetPoint("TOPRIGHT", parent.Trinket, "BOTTOMRIGHT", -1, 3)
    parent.Trinket.timer:SetFrameLevel(parent.Trinket:GetFrameLevel() + 2)

    local sBarBG = CreateFrame("Frame", nil, parent.Trinket.timer)
    sBarBG:SetPoint("TOPLEFT", parent.Trinket.timer, -1, 1)
    sBarBG:SetPoint("BOTTOMRIGHT", parent.Trinket.timer, 1, -1)
    sBarBG:SetFrameLevel(parent.Trinket:GetFrameLevel() + 1)
    nibRealUI:CreateBD(sBarBG)

    parent.Trinket.text = parent.Trinket:CreateFontString(nil, "OVERLAY")
    parent.Trinket.text:SetFont(unpack(nibRealUI.font.pixel1))
    parent.Trinket.text:SetPoint("BOTTOMLEFT", parent.Trinket, "BOTTOMLEFT", 1.5, 4)
    parent.Trinket.text:SetJustifyH("LEFT")
end

local function CreateArena(self)
    self:SetSize(135, 22)
    CreateBD(self, 0.7)

    CreateHealthBar(self)
    CreateTags(self)
    CreatePowerBar(self)
    CreateTrinket(self)

    self.RaidIcon = self:CreateTexture(nil, 'OVERLAY')
    self.RaidIcon:SetSize(21, 21)
    self.RaidIcon:SetPoint("LEFT", self, "RIGHT", 1, 1)

    self:SetScript("OnEnter", UnitFrame_OnEnter)
    self:SetScript("OnLeave", UnitFrame_OnLeave)
    self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", UpdateTrinket)
end

-- Init
tinsert(UnitFrames.units, function(...)
    db = UnitFrames.db.profile
    ndb = nibRealUI.db.profile
    ndbc = nibRealUI.db.char

    oUF:RegisterStyle("RealUI:arena", CreateArena)
    oUF:SetActiveStyle("RealUI:arena")
    -- Bosses and arenas are mutually excusive, so we'll just use some boss stuff for both for now.
    for i = 1, MAX_BOSS_FRAMES do
        local arena = oUF:Spawn("arena" .. i, "RealUIArenaFrame" .. i)
        if (i == 1) then
            arena:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT", db.positions[UnitFrames.layoutSize].boss.x, db.positions[UnitFrames.layoutSize].boss.y)
        else
            arena:SetPoint("TOP", _G["RealUIArenaFrame" .. i - 1], "BOTTOM", 0, -db.boss.gap)
        end
    end
end)
