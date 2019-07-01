-- Code from EventNotifier by the awesome Haleth
-- http://www.wowinterface.com/downloads/info21370-EventNotifier.html
local _, private = ...

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "EventNotifier"
local EventNotifier = RealUI:NewModule(MODNAME, "AceEvent-3.0")

-- For maps where we don't want notifications of vignettes
local excludedUIMapIDs = {
    [579] = true, -- Lunarfall: Alliance garrison
    [585] = true, -- Frostwall: Horde garrison
    [646] = true, -- Scenario: The Broken Shore
}
local SOUND_TIMEOUT = 20


-- Addon itself
local numInvites = 0 -- store amount of invites to compare later, and only show banner when invites differ; events fire multiple times

local function GetGuildInvites()
    local numGuildInvites = 0
    local date = _G.C_DateAndTime.GetCurrentCalendarTime()
    for index = 1, _G.C_Calendar.GetNumGuildEvents() do
        local info = _G.C_Calendar.GetGuildEventInfo(index)
        local monthOffset = info.month - date.month
        local numDayEvents = _G.C_Calendar.GetNumDayEvents(monthOffset, info.monthDay)

        for i = 1, numDayEvents do
            local event = _G.C_Calendar.GetDayEvent(monthOffset, info.monthDay, i)
            if event.inviteStatus == _G.CALENDAR_INVITESTATUS_NOT_SIGNEDUP then
                numGuildInvites = numGuildInvites + 1
            end
        end
    end

    return numGuildInvites
end

local function toggleCalendar()
    if not _G.CalendarFrame then _G.LoadAddOn("Blizzard_Calendar") end
    _G.Calendar_Toggle()
end

local function alertEvents()
    if _G.CalendarFrame and _G.CalendarFrame:IsShown() then return end
    local num = _G.C_Calendar.GetNumPendingInvites()
    if num ~= numInvites then
        if num > 0 then
            RealUI:Notification("Pending Invites", false, ("You have %s pending calendar |4invite:invites;."):format(num), toggleCalendar)
        end
        --[[if num > 1 then
            RealUI:Notification("Pending Invites", false, ("You have %s pending calendar invites."):format(num), toggleCalendar)
        elseif num > 0 then
            RealUI:Notification("Pending Invite", false, "You have 1 pending calendar invite.", toggleCalendar)
        end]]
        numInvites = num
    end
end

local function alertGuildEvents()
    if _G.CalendarFrame and _G.CalendarFrame:IsShown() then return end
    local num = GetGuildInvites()
    if num > 0 then
        RealUI:Notification("Pending Guild Events", false, ("You have %s pending guild |4event:events;."):format(num), toggleCalendar)
    end
    --[[if num > 1 then
        RealUI:Notification("Pending Guild Events", false, ("You have %s pending guild events."):format(num), toggleCalendar)
    elseif num > 0 then
        RealUI:Notification("Pending Guild Event", false, "You have 1 pending guild event.", toggleCalendar)
    end]]
end

function EventNotifier:CALENDAR_UPDATE_GUILD_EVENTS()
    if db.checkGuildEvents then
        alertGuildEvents()
    end
end

function EventNotifier:VIGNETTE_MINIMAP_UPDATED(event, vignetteGUID, onMinimap)
    self:debug("VIGNETTE_MINIMAP_UPDATED", vignetteGUID, onMinimap)
    if not (db.checkMinimapRares) or excludedUIMapIDs[_G.C_Map.GetBestMapForUnit("player")] then return end

    self:debug("time, id", self.lastMinimapRare.time, self.lastMinimapRare.id)
    if onMinimap then
        local vignetteInfo = _G.C_VignetteInfo.GetVignetteInfo(vignetteGUID)
        if vignetteInfo and vignetteGUID ~= self.lastMinimapRare.id then
            RealUI:Notification(vignetteInfo.name, true, "- has appeared on the MiniMap!", nil, vignetteInfo.atlasName)
            self.lastMinimapRare.id = vignetteGUID

            local time = _G.GetTime()
            if time > (self.lastMinimapRare.time + SOUND_TIMEOUT) then
                _G.PlaySound(_G.SOUNDKIT.RAID_WARNING)
                self.lastMinimapRare.time = time
            end
        end
    end
end

function EventNotifier:CALENDAR_UPDATE_PENDING_INVITES()
    if db.checkEvents then
        alertEvents()
    end
    if db.checkGuildEvents then
        alertGuildEvents()
    end
end

function EventNotifier:PLAYER_ENTERING_WORLD()
    if db.checkEvents or db.checkGuildEvents then
        _G.C_Calendar.OpenCalendar()
        self:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
    end

    if db.checkEvents then
        alertEvents()
    end
    if db.checkGuildEvents then
        alertGuildEvents()
    end
end

----------
function EventNotifier:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = { --TODO: convert to global
            checkEvents = true,
            checkGuildEvents = true,
            checkMinimapRares = true,
        },
    })
    db = self.db.profile

    self.lastMinimapRare = {time = 0, id = nil}
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function EventNotifier:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("CALENDAR_UPDATE_GUILD_EVENTS")
    self:RegisterEvent("VIGNETTE_MINIMAP_UPDATED")
end

function EventNotifier:OnDisable()
    self:UnregisterAllEvents()
end
