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

local function UpdateCC(self, event, unit)
    local spellID, startTime, duration = _G.C_PvP.GetArenaCrowdControlInfo(unit)
    if spellID then
        UnitFrames:debug("UpdateCC", startTime, duration)
        if startTime ~= 0 and duration ~= 0 then
            self.Trinket:SetCooldown(startTime / 1000.0, duration / 1000.0)
            if not self.hasAnnounced then
                if UnitFrames.db.profile.arena.announceUse then
                    local chat = UnitFrames.db.profile.arena.announceChat
                    if chat == "GROUP" then
                        chat = "INSTANCE_CHAT"
                    end
                    _G.SendChatMessage("Trinket used by: ".._G.GetUnitName(unit, true), chat)
                elseif RealUI.isDev then
                    _G.print("Trinket used by: ".._G.GetUnitName(unit, true))
                end
                self.hasAnnounced = true
            end
        else
            self.Trinket:Clear();
            self.hasAnnounced = false
        end
    end
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

    function parent.Health:PostUpdateArenaPreparation(event, specID)
        local _, _, _, specIcon = _G.GetSpecializationInfoByID(specID)
        parent.Trinket.icon:SetTexture(specIcon)
    end
end

local function CreateTags(parent)
    parent.HealthValue = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.HealthValue:SetPoint("TOPLEFT", 2.5, -6.5)
    parent.HealthValue:SetFontObject("SystemFont_Shadow_Med1")
    parent.HealthValue:SetJustifyH("LEFT")
    parent:Tag(parent.HealthValue, "[realui:healthPercent]")

    parent.Name = parent.Health:CreateFontString(nil, "OVERLAY")
    parent.Name:SetPoint("TOPRIGHT", -0.5, -6.5)
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

local function CreateTrinket(parent)
    local trinket = _G.CreateFrame("Frame", nil, parent)
    trinket:SetSize(22, 22)
    trinket:SetPoint("BOTTOMRIGHT", parent, "BOTTOMLEFT", -3, 0)
    trinket:SetScript("OnUpdate", function(self, elapsed)
        self.elapsed = self.elapsed + elapsed
        if self.elapsed >= self.interval then
            self.elapsed = 0
            if self.startTime and self.endTime then
                local now = _G.GetTime()
                self.timer:SetValue(self.endTime - now)
                self.text:SetText(TimeFormat(_G.ceil(self.endTime - now)))

                local per = (self.endTime - now) / (self.endTime - self.startTime)
                if per > 0.5 then
                    self.timer:SetStatusBarColor(1 - ((per*2)-1), 1, 0)
                else
                    self.timer:SetStatusBarColor(1, (per*2), 0)
                end
            else
                self.timer:Hide()
                self.text:SetText()
            end
        end
    end)
    trinket.elapsed = 0
    trinket.interval = 1/4

    trinket.icon = trinket:CreateTexture(nil, "BACKGROUND")
    trinket.icon:SetAllPoints()
    trinket.icon:SetTexture([[Interface\Icons\PVPCurrency-Conquest-Horde]])
    Base.CropIcon(trinket.icon, trinket)

    trinket.timer = _G.CreateFrame("StatusBar", nil, trinket)
    trinket.timer:SetMinMaxValues(0, 1)
    trinket.timer:SetStatusBarTexture(RealUI.textures.plain)
    trinket.timer:SetStatusBarColor(1,1,1,1)

    trinket.timer:SetPoint("BOTTOMLEFT", trinket, "BOTTOMLEFT", 1, 1)
    trinket.timer:SetPoint("TOPRIGHT", trinket, "BOTTOMRIGHT", -1, 3)
    trinket.timer:SetFrameLevel(trinket:GetFrameLevel() + 2)
    Base.SetBackdrop(trinket.timer, Color.frame)

    trinket.text = trinket:CreateFontString(nil, "OVERLAY")
    trinket.text:SetFontObject("NumberFont_Outline_Med")
    trinket.text:SetPoint("BOTTOMLEFT", trinket, "BOTTOMLEFT", 1.5, 4)
    trinket.text:SetJustifyH("LEFT")

    function trinket:SetCooldown(startTime, duration)
        self.startTime = startTime
        self.endTime = startTime + duration

        self.timer:Show()
        self.timer:SetMinMaxValues(0, self.endTime - self.startTime)
    end
    function trinket:Clear()
        self.startTime = nil
        self.endTime = nil
    end
    parent.Trinket = trinket
end

local function CreateArena(self)
    --print("CreateArena", self.unit)
    self:SetSize(135, 22)
    Base.SetBackdrop(self, Color.frame, 0.7)

    CreateHealthBar(self)
    CreateTags(self)
    CreatePowerBar(self)
    CreateTrinket(self)

    self.RaidIcon = self:CreateTexture(nil, 'OVERLAY')
    self.RaidIcon:SetSize(21, 21)
    self.RaidIcon:SetPoint("CENTER", self)

    self:SetScript("OnEnter", _G.UnitFrame_OnEnter)
    self:SetScript("OnLeave", _G.UnitFrame_OnLeave)
    self:RegisterEvent("ARENA_COOLDOWNS_UPDATE", UpdateCC)
end

UnitFrames.arena = {
    nameLength = 135 / 10
}

-- Init
_G.tinsert(UnitFrames.units, function(...)
    if not UnitFrames.db.profile.arena.enabled then return end

    oUF:RegisterStyle("RealUI:arena", CreateArena)
    oUF:SetActiveStyle("RealUI:arena")
    -- Bosses and arenas are mutually excusive, so we'll just use some boss stuff for both for now.
    for i = 1, _G.MAX_BOSS_FRAMES do
        local arena = oUF:Spawn("arena" .. i, "RealUIArenaFrame" .. i)
        if i == 1 then
            arena:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT", UnitFrames.db.profile.positions[UnitFrames.layoutSize].boss.x, UnitFrames.db.profile.positions[UnitFrames.layoutSize].boss.y)
        else
            arena:SetPoint("TOP", "RealUIArenaFrame"..(i-1), "BOTTOM", 0, -UnitFrames.db.profile.boss.gap)
        end
    end
end)
