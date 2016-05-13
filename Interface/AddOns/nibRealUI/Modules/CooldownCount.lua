-- Code based on tullaCooldownCount by Tuller
-- http://www.wowinterface.com/downloads/info17602-tullaCooldownCount.html
local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local round = RealUI.Round
local db, ndb

local MODNAME = "CooldownCount"
local CooldownCount = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local Timer = {}
CooldownCount.Timer = Timer

----------
--sexy constants!
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

local SECONDS_FORMAT, MINUTES_FORMAT, HOURS_FORMAT, DAYS_FORMAT, EXPIRING_FORMAT
local function ColorTableToStr(vals)
    return ("%02x%02x%02x"):format(vals[1] * 255, vals[2] * 255, vals[3] * 255)
end

--returns both what text to display, and how long until the next update
local function getTimeText(s)
    --format text as seconds when at 90 seconds or below
    if s < MINUTEISH then
        local seconds = round(s)
        local formatString = seconds > db.expiringDuration and SECONDS_FORMAT or EXPIRING_FORMAT
        return formatString, seconds, s - (seconds - 0.51)
    --format text as minutes when below an hour
    elseif s < HOURISH then
        local minutes = round(s/MINUTE)
        return MINUTES_FORMAT, minutes, minutes > 1 and (s - (minutes * MINUTE - HALFMINUTEISH)) or (s - MINUTEISH)
    --format text as hours when below a day
    elseif s < DAYISH then
        local hours = round(s/HOUR)
        return HOURS_FORMAT, hours, hours > 1 and (s - (hours * HOUR - HALFHOURISH)) or (s - HOURISH)
    --format text as days
    else
        local days = round(s/DAY)
        return DAYS_FORMAT, days, days > 1 and (s - (days * DAY - HALFDAYISH)) or (s - DAYISH)
    end
end

local function setTimeFormats()
    EXPIRING_FORMAT = "|cff"..ColorTableToStr(db.colors.expiring).."%d|r"
    SECONDS_FORMAT = "|cff"..ColorTableToStr(db.colors.seconds).."%d|r"
    MINUTES_FORMAT = "|cff"..ColorTableToStr(db.colors.minutes).."%dm|r"
    HOURS_FORMAT = "|cff"..ColorTableToStr(db.colors.hours).."%dh|r"
    DAYS_FORMAT = "|cff"..ColorTableToStr(db.colors.days).."%dh|r"
end

---------------------------
---- 4.3 Compatibility ----
---------------------------
local active = {}

local function cooldown_OnShow(self)
    active[self] = true
end

local function cooldown_OnHide(self)
    active[self] = nil
end

--returns true if the cooldown timer should be updated and false otherwise
local function cooldown_ShouldUpdateTimer(self, start, duration, charges, maxCharges)
    local timer = self.timer
    if not timer then
        return true
    end
    return not(timer.start == start or timer.charges == charges or timer.maxCharges == maxCharges)
end

local function cooldown_Update(self)
    local button = self:GetParent()
    local action = button.action

    local start, duration = _G.GetActionCooldown(action)
    local charges, maxCharges = _G.GetActionCharges(action)

    if cooldown_ShouldUpdateTimer(self, start, duration, charges, maxCharges) then
        Timer.Start(self, start, duration, charges, maxCharges)
    end
end

function CooldownCount:ACTIONBAR_UPDATE_COOLDOWN()
    for cooldown in next, active do
        cooldown_Update(cooldown)
    end
end

local hooked = {}
local function actionButton_Register(frame)
    local cooldown = frame.cooldown
    if not hooked[cooldown] then
        cooldown:HookScript('OnShow', cooldown_OnShow)
        cooldown:HookScript('OnHide', cooldown_OnHide)
        hooked[cooldown] = true
    end
end

---------------
---- Timer ----
---------------
function Timer.SetNextUpdate(self, nextUpdate)
    self.updater:GetAnimations():SetDuration(nextUpdate)
    if self.updater:IsPlaying() then
        self.updater:Stop()
    end
    self.updater:Play()
end

--stops the timer
function Timer.Stop(self)
    self.enabled = nil
    if self.updater:IsPlaying() then
        self.updater:Stop()
    end
    self:Hide()
end

function Timer.UpdateText(self)
    local remain = self.duration - (_G.GetTime() - self.start)
    if round(remain) > 0 then
        if (self.fontScale * self:GetEffectiveScale() / _G.UIParent:GetScale()) < db.minScale then
            self.text:SetText("")
            Timer.SetNextUpdate(self, 1)
        else
            local formatStr, time, nextUpdate = getTimeText(remain)
            if (remain >= MINUTEISH * 10) and (ndb.media.font.pixel.cooldown[2] >= 16) then
                local font, size, outline = _G.RealUIFont_PixelCooldown:GetFont()
                self.text:SetFont(font, size / 2, outline)
            else
                self.text:SetFontObject(_G.RealUIFont_PixelCooldown)
            end
            self.text:SetFormattedText(formatStr, time)
            Timer.SetNextUpdate(self, nextUpdate)
        end
    else
        Timer.Stop(self)
    end
end

--forces the given timer to update on the next frame
function Timer.ForceUpdate(self)
    Timer.UpdateText(self)
    self:Show()
end

--adjust font size whenever the timer's parent size changes
--hide if it gets too tiny
function Timer.OnSizeChanged(self, width, height)
    local fontScale = round(width) / ICON_SIZE
    if fontScale == self.fontScale then
        return
    end

    self.fontScale = fontScale
    if fontScale < db.minScale then
        self:Hide()
    else
        self.text:SetFontObject(_G.RealUIFont_PixelCooldown)
        if self.enabled then
            Timer.ForceUpdate(self)
        end
    end
end

--returns a new timer object
function Timer.Create(cd)
    --a frame to watch for OnSizeChanged events
    --needed since OnSizeChanged has funny triggering if the frame with the handler is not shown
    local scaler = _G.CreateFrame('Frame', nil, cd)
    scaler:SetAllPoints(cd)

    local timer = _G.CreateFrame('Frame', nil, scaler); timer:Hide()
    timer:SetAllPoints(scaler)

    local updater = timer:CreateAnimationGroup()
    updater:SetLooping('NONE')
    updater:SetScript('OnFinished', function(self) Timer.UpdateText(timer) end)

    local a = updater:CreateAnimation('Animation'); a:SetOrder(1)
    timer.updater = updater

    local text = timer:CreateFontString(nil, 'OVERLAY')
    timer.text = text
        text:SetPoint(db.position.point, db.position.x, db.position.y)
        text:SetJustifyH(db.position.justify)
        text:SetFontObject(_G.RealUIFont_PixelCooldown)

    Timer.OnSizeChanged(timer, scaler:GetSize())
    scaler:SetScript('OnSizeChanged', function(self, ...) Timer.OnSizeChanged(timer, ...) end)

    cd.timer = timer
    return timer
end

function Timer.Start(cd, start, duration, charges, maxCharges)
    local remainingCharges = charges or 0

    --start timer
    if start > 0 and duration > db.minDuration and remainingCharges == 0 and (not cd.noCooldownCount) then
        local timer = cd.timer or Timer.Create(cd)
        timer.start = start
        timer.duration = duration
        timer.enabled = true
        Timer.UpdateText(timer)
        if timer.fontScale >= db.minScale then timer:Show() end
    --stop timer
    else
        local timer = cd.timer
        if timer then
            Timer.Stop(timer)
        end
    end
end

----------
function CooldownCount:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            minScale = 0.5,
            minDuration = 2,
            expiringDuration = 5,
            colors = {
                expiring =  {1,     0,      0},
                seconds =   {1,     1,      0},
                minutes =   {1,     1,      1},
                hours =     {0.25,  1,      1},
                days =      {0.25,  0.25,   1},
            },
            position = {
                point = "BOTTOMLEFT",
                x = 1.5,
                y = 0.5,
                justify = "LEFT"
            },
        },
    })
    db = self.db.profile
    ndb = RealUI.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function CooldownCount:OnEnable()
    setTimeFormats()

    _G.hooksecurefunc(_G.getmetatable(_G["ActionButton1Cooldown"]).__index, "SetCooldown", Timer.Start)

    -- 4.3 compatibility
    -- In WoW 4.3 and later, action buttons can completely bypass lua for updating cooldown timers
    -- This set of code is there to check and force update timers on standard action buttons (henceforth defined as anything that reuses's blizzard's ActionButton.lua code)
    local ActionBarButtonEventsFrame = _G["ActionBarButtonEventsFrame"]
    if ActionBarButtonEventsFrame then
        if ActionBarButtonEventsFrame.frames then
            for i, frame in next, ActionBarButtonEventsFrame.frames do
                actionButton_Register(frame)
            end
        end
        _G.hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", actionButton_Register)
        self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    end
    _G.SetCVar("countdownForCooldowns", 0)
end

function CooldownCount:OnDisable()
    self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    _G.SetCVar("countdownForCooldowns", 1)
end
