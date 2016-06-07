local _, private = ...

-- Lua Globals --
local _G = _G
local next, ipairs = _G.next, _G.ipairs

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "MirrorBar"
local MirrorBar = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false
local MBFrames = {}

-- Next Timer
function MirrorBar:SetNextTimer()
    local nextTimer = 1
    for i = (self.currentTimer + 1), 5 do
        -- Try to find an active timer higher on the list than current timer
        if not(i > 4) then
            if self.timers[self.timerList[i]].active then
                nextTimer = i
                break
            end
        -- Else, find first active timer
        else
            for k,v in ipairs(self.timerList) do
                if self.timers[v].active then
                    nextTimer = k
                    break
                end
            end
            break
        end
    end
    self.currentTimer = nextTimer
end

-- Update Visibility
function MirrorBar:UpdateShown()
    local show = false
    if not(_G.UnitIsDead("player") or _G.UnitIsGhost("player") or _G.UnitInVehicle("player")) then
        for k,v in next, self.timers do
            if self.timers[k].active then
                show = true
                break
            end
        end
    end
    MBFrames.bg:SetShown(show)
    MBFrames.bar:SetShown(show)
    if not show then
        self.loopElapsed = 1
        self.currentTimer = 1
    end
end

function MirrorBar:UpdateBar(scale, remaining, label)
    MBFrames.bar:SetValue(scale)
    MBFrames.text:SetFormattedText("%s %ds", label, remaining)
end

-- Update Bar
function MirrorBar:OnUpdate(bar, elapsed)
    self.loopElapsed = self.loopElapsed + elapsed
    self.elapsed = self.elapsed + elapsed

    if self.elapsed < (1 / 30) then return end
    self.elapsed = 0

    -- Update Timer values
    for k,v in ipairs(self.timerList) do
        if self.timers[v].active then
            self.timers[v].value = self.timers[v].value + (self.timers[v].scale * ((_G.GetTime() - self.timers[v].lastTime) * 1000))
            self.timers[v].lastTime = _G.GetTime()
        end
    end

    -- Cycle through Timers
    if self.loopElapsed >= 1 then
        self.loopElapsed = 0
        self:SetNextTimer()
        local color = self.timerColors[self.timerList[self.currentTimer]]
        MBFrames.bar:SetStatusBarColor(color[1], color[2], color[3], 0.85)
    end

    local curTimer = self.timers[self.timerList[self.currentTimer]]

    -- Active Timer?
    if curTimer.paused then return end
    if not curTimer.active then return end

    -- Time remaining
    curTimer.timeRemaining = _G.floor(curTimer.value / 1000)
    curTimer.timeRemaining = RealUI.Clamp(curTimer.timeRemaining, 0, curTimer.max / 1000)

    -- Scale
    local scale = (curTimer.max ~= 0) and (curTimer.value / curTimer.max) or 0
    scale = RealUI.Clamp(scale, 0, 1)

    -- Update bar
    local _,_,_,_,_, label = _G.GetMirrorTimerInfo(self.currentTimer)
    self:UpdateBar(scale, curTimer.timeRemaining or 0, label or "")
end

function MirrorBar:MIRROR_TIMER_PAUSE(event, paused)
    for k,v in next, self.timers do
        self.timers[k].paused = (paused > 0)
    end
end

function MirrorBar:MIRROR_TIMER_STOP(event, timer)
    self.timers[timer].active = false
    self.timers[timer].current = 0
    self.timers[timer].max = 1

    self:UpdateShown()
end

function MirrorBar:MIRROR_TIMER_START(event, timer, value, maxValue, scale, paused, label)
    self.timers[timer].active = true
    self.timers[timer].value = value
    self.timers[timer].max = maxValue
    self.timers[timer].scale = scale
    self.timers[timer].paused = (paused > 0)
    self.timers[timer].label = label
    self.timers[timer].lastTime = _G.GetTime()

    self:UpdateShown()
end

-- Colors
function MirrorBar:UpdateColors()
    -- BG + Border
    local color = RealUI.media.background
    MBFrames.bg:SetBackdropColor(color[1], color[2], color[3], color[4])
    MBFrames.bg:SetBackdropBorderColor(0, 0, 0, 1)
end

-- Position
function MirrorBar:UpdatePosition()
    -- BG + Border
    MBFrames.bg:SetPoint(db.position.anchorfrom, _G.UIParent, db.position.anchorto, db.position.x, db.position.y)

    MBFrames.bg:SetFrameStrata("MEDIUM")
    MBFrames.bg:SetFrameLevel(1)

    MBFrames.bg:SetHeight(db.size.height)
    MBFrames.bg:SetWidth(db.size.width)
end

-- Refresh
function MirrorBar:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    db = self.db.profile

    MirrorBar:UpdatePosition()
    MirrorBar:UpdateColors()
end

function MirrorBar:PLAYER_LOGIN()
    LoggedIn = true
    MirrorBar:RefreshMod()
end

-- Create Frames
function MirrorBar:CreateFrames()
    -- BG + Border
    MBFrames.bg = _G.CreateFrame("Frame", "RealUI_MirrorBar", _G.UIParent)
    MBFrames.bg:SetPoint(db.position.anchorfrom, _G.UIParent, db.position.anchorto, db.position.x, db.position.y)

    MBFrames.bg:SetBackdrop({
        bgFile = RealUI.media.textures.plain,
        edgeFile = RealUI.media.textures.plain,
        tile = false, tileSize = 0, edgeSize = 1,
        insets = { left = 0, right = 0, top = 0, bottom = 0}
    })

    -- Bar + Text
    MBFrames.bar = _G.CreateFrame("StatusBar", nil, MBFrames.bg)
    MBFrames.bar:SetStatusBarTexture(RealUI.media.textures.plain)
    MBFrames.bar:SetMinMaxValues(0, 1)
    MBFrames.bar:SetPoint("TOPLEFT", MBFrames.bg, "TOPLEFT", 1, -1)
    MBFrames.bar:SetPoint("BOTTOMRIGHT", MBFrames.bg, "BOTTOMRIGHT", -1, 1)

    MBFrames.text = MBFrames.bar:CreateFontString(nil, "OVERLAY")
    MBFrames.text:SetPoint("CENTER", MBFrames.bar, "CENTER", 1.5, -0.5)
    MBFrames.text:SetFontObject(_G.RealUIFont_Pixel)
    MBFrames.text:SetTextColor(1, 1, 1, 1)

    -- Update Power
    MBFrames.bar.elapsed = 0
    MBFrames.bar:SetScript("OnUpdate", function(bar, elapsed)
        MirrorBar:OnUpdate(bar, elapsed)
    end)

    MBFrames.bg:Hide()
end

function MirrorBar:UpdateGlobalColors()
    self.timerColors = {
        ["EXHAUSTION"] =    RealUI.media.colors.orange,
        ["BREATH"] =        RealUI.media.colors.blue,
        ["FEIGNDEATH"] =    RealUI.media.colors.red,
        ["DEATH"] =         RealUI.media.colors.red,
    }
    self.loopElapsed = 1
end

-- Initialize
function MirrorBar:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            size = {width = 160, height = 16},
            position = {
                anchorto = "TOP",
                anchorfrom = "TOP",
                x = 0,
                y = -220,
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
    self:CreateFrames()
end

function MirrorBar:OnEnable()
    self.currentTimer = 1
    self.timerList = {
        [1] = "EXHAUSTION",
        [2] = "BREATH",
        [3] = "FEIGNDEATH",
        [4] = "DEATH",
    }
    self.timers = {
        ["EXHAUSTION"] =    {},
        ["BREATH"] =        {},
        ["FEIGNDEATH"] =    {},
        ["DEATH"] =         {},
    }
    self:UpdateGlobalColors()
    self.loopElapsed = 1
    self.elapsed = 1

    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("MIRROR_TIMER_START")
    self:RegisterEvent("MIRROR_TIMER_STOP")
    self:RegisterEvent("MIRROR_TIMER_PAUSE")

    -- Hide Default
    _G.UIParent:UnregisterEvent("MIRROR_TIMER_START")

    if LoggedIn then
        MirrorBar:RefreshMod()
    end
end

function MirrorBar:OnDisable()
    self:UnregisterAllEvents()

    MBFrames.bg:Hide()
    _G.UIParent:RegisterEvent("MIRROR_TIMER_START")
end
