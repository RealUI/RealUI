-- Code based on tullaCooldownCount by Tuller
-- http://www.wowinterface.com/downloads/info17602-tullaCooldownCount.html
local _, private = ...

-- Lua Globals --
local next = _G.next

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

-- RealUI --
local RealUI = private.RealUI
local round = RealUI.Round
local db

local MODNAME = "CooldownCount"
local CooldownCount = RealUI:NewModule(MODNAME, "AceTimer-3.0", "AceEvent-3.0")

local Timer = {}
CooldownCount.Timer = Timer

----------
--sexy constants!
local CD_FONT
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

local EXPIRING_FORMAT = Color.red:WrapTextInColorCode("%d")
local SECONDS_FORMAT = Color.yellow:WrapTextInColorCode("%d")
local MINUTES_FORMAT = Color.white:WrapTextInColorCode("%dm")
local HOURS_FORMAT = Color.cyan:WrapTextInColorCode("%dh")
local DAYS_FORMAT = Color.blue:WrapTextInColorCode("%dd")

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


---------------
---- Timer ----
---------------
function Timer:SetNextUpdate(nextUpdate)
    if self.updater and CooldownCount:TimeLeft(self.updater) > 0 then
        CooldownCount:CancelTimer(self.updater)
    end
    self.updater = CooldownCount:ScheduleTimer(self.UpdateText, nextUpdate, self)
end

--stops the timer
function Timer:Stop()
    self.enabled = nil
    self.start = nil
    self.duration = nil
    self.charges = nil
    self.maxCharges = nil
    CooldownCount:CancelTimer(self.updater)
    return self:Hide()
end


local sizeAdjust = {
    {time = 10, adj = 4},
    {time = MINUTE, adj = 2},
}
function Timer:UpdateText()
    local remain = self.enabled and (self.duration - (_G.GetTime() - self.start)) or 0
    if round(remain) > 0 then
        local text = self.text
        local formatStr, time, nextUpdate = getTimeText(remain)

        local size = CD_FONT.size
        for i = 1, #sizeAdjust do
            local info = sizeAdjust[i]
            if remain < info.time then
                size = size + info.adj
                break
            end
        end
        text:SetFont(CD_FONT.font, size, CD_FONT.flags)

        text:SetFormattedText(formatStr, time)
        text:Show()
        return self:SetNextUpdate(nextUpdate)
    else
        return self:Stop()
    end
end

function Timer:Start(start, duration, modRate)
    if start > 0 and duration > db.minDuration then
        self.start = start
        self.duration = duration
        self.enabled = true
        self.text:SetFont(CD_FONT.font, CD_FONT.size, CD_FONT.flags)
        self:UpdateText()
        self:Show()
    else
        self:Stop()
    end
end

local anchor = {
    TOPLEFT = {x = 1, y = -1},
    BOTTOMLEFT = {x = 1, y = 1},
    TOPRIGHT = {x = -1, y = -1},
    BOTTOMRIGHT = {x = -1, y = 1}
}
--returns a new timer object
local function CreateTimer(cd)
    local timer = _G.CreateFrame('Frame', nil, cd)
    timer:SetAllPoints()
    timer:Hide()

    local point = anchor[db.point]
    local text = timer:CreateFontString(nil, 'OVERLAY')
    text:SetFont(CD_FONT.font, CD_FONT.size, CD_FONT.flags)
    text:SetPoint(db.point, point.x, point.y)
    text:Hide()
    timer.text = text

    for key, func in next, Timer do
        timer[key] = func
    end
    return timer
end

----------
function CooldownCount:RefreshMod()
    db = self.db.profile
end

function CooldownCount:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            minDuration = 2,
            expiringDuration = 5,
            point = "BOTTOMLEFT",
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function CooldownCount:OnEnable()
    CD_FONT = {
        font = RealUI.GetOptions("Skins").profile.fonts.normal.path,
        size = 10,
        flags = "OUTLINE"
    }

    _G.hooksecurefunc(_G.getmetatable(_G["ActionButton1Cooldown"]).__index, "SetCooldown", function(cd, start, duration, modRate)
        if not cd:IsForbidden() and not cd.noCooldownCount then
            if not cd.timer then
                cd.timer = CreateTimer(cd)
            end
            cd.timer:Start(start, duration, modRate)
        end
    end)
    _G.SetCVar("countdownForCooldowns", 0)
end

function CooldownCount:OnDisable()
    self:UnregisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
    _G.SetCVar("countdownForCooldowns", 1)
end
