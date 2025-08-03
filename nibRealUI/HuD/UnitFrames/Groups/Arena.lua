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
                    _G.C_ChatInfo.SendChatMessage("Trinket used by: ".._G.GetUnitName(unit, true), chat)
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
local function CreateTrinket(parent)
    local iconSize = parent:GetHeight()

    local trinket = _G.CreateFrame("Frame", nil, parent)
    trinket:SetSize(iconSize, iconSize)
    trinket:SetPoint("TOPRIGHT", parent, "TOPLEFT", -3, 0)
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

    local timer = _G.CreateFrame("StatusBar", nil, trinket)
    timer:SetMinMaxValues(0, 1)
    timer:SetStatusBarTexture(RealUI.textures.plain)
    timer:SetStatusBarColor(1,1,1,1)
    trinket.timer = timer

    timer:SetPoint("TOPLEFT", trinket, "BOTTOMLEFT", 0, 2)
    timer:SetPoint("BOTTOMRIGHT", trinket)
    timer:SetFrameLevel(trinket:GetFrameLevel() + 2)

    Base.SetBackdrop(timer, Color.black, 0.7)
    timer:SetBackdropOption("offsets", {
        left = -1,
        right = -1,
        top = -1,
        bottom = -1,
    })

    trinket.text = trinket:CreateFontString(nil, "OVERLAY")
    trinket.text:SetFontObject("NumberFont_Outline_Med")
    trinket.text:SetPoint("CENTER", trinket, 0, 0)
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

UnitFrames.arena = {
    create = function(self)
        --print("CreateArena", self.unit)
        CreateTrinket(self)

        local color = self.colors.health
        self.Health.text:SetPoint("LEFT", self.Health, 1, 0)
        self.Health:SetStatusBarColor(color[1], color[2], color[3], color[4])
        function self.Health.PostUpdateArenaPreparation(this, event, specID)
            local _, _, _, specIcon = _G.GetSpecializationInfoByID(specID)
            this.Trinket.icon:SetTexture(specIcon)
        end

        self.Name = self.Health:CreateFontString(nil, "OVERLAY")
        self.Name:SetPoint("RIGHT", self.Health, -1, 0)
        self.Name:SetFontObject("SystemFont_Shadow_Med1")
        self.Name:SetJustifyH("RIGHT")
        self:Tag(self.Name, "[realui:name]")

        self.RaidTargetIndicator = self:CreateTexture(nil, 'OVERLAY')
        self.RaidTargetIndicator:SetSize(20, 20)
        self.RaidTargetIndicator:SetPoint("CENTER", self)

        self:RegisterEvent("ARENA_COOLDOWNS_UPDATE", UpdateCC)
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
    if not db.arena.enabled then return end

    -- Bosses and arenas are mutually excusive, so we'll just use some boss stuff for both for now.
    for i = 1, _G.MAX_BOSS_FRAMES do
        local arena = oUF:Spawn("arena" .. i, "RealUIArenaFrame" .. i)
        if i == 1 then
            arena:SetPoint("RIGHT", "RealUIPositionersBossFrames", "LEFT", db.positions[UnitFrames.layoutSize].boss.x, db.positions[UnitFrames.layoutSize].boss.y)
        else
            arena:SetPoint("TOP", "RealUIArenaFrame"..(i-1), "BOTTOM", 0, -db.boss.gap)
        end
    end
end)
