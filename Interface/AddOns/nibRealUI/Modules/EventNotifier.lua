-- Code from EventNotifier by the awesome Haleth
-- http://www.wowinterface.com/downloads/info21370-EventNotifier.html
local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "EventNotifier"
local EventNotifier = RealUI:NewModule(MODNAME, "AceEvent-3.0")

-- For maps where we don't want notifications of vignettes
local VignetteExclusionMapIDs = {
    [971] = true, -- Lunarfall: Alliance garrison
    [976] = true, -- Frostwall: Horde garrison
    [1021] = true -- Scenario: The Broken Shore
}
local SOUND_TIMEOUT = 20


-- Addon itself
local numInvites = 0 -- store amount of invites to compare later, and only show banner when invites differ; events fire multiple times

local function GetGuildInvites()
    local numGuildInvites = 0
    local _, currentMonth = _G.CalendarGetDate()

    for idx = 1, _G.CalendarGetNumGuildEvents() do
        local month, day = _G.CalendarGetGuildEventInfo(idx)
        local monthOffset = month - currentMonth
        local numDayEvents = _G.CalendarGetNumDayEvents(monthOffset, day)

        for i = 1, numDayEvents do
            local _, _, _, _, _, _, _, _, inviteStatus = _G.CalendarGetDayEvent(monthOffset, day, i)
            if inviteStatus == 8 then
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
    local num = _G.CalendarGetNumPendingInvites()
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

function EventNotifier:VIGNETTE_ADDED(event, vigID)
    self:debug("VIGNETTE_ADDED", vigID)
    if not(db.checkMinimapRares) or VignetteExclusionMapIDs[_G.GetCurrentMapAreaID()] then return end

    if (vigID ~= self.lastMinimapRare.id) then
        -- Vignette Info C_Vignettes.GetVignetteInfoFromInstanceID(C_Vignettes.GetVignetteGUID(1))
        local _, _, name, objectIcon = _G.C_Vignettes.GetVignetteInfoFromInstanceID(vigID)
        self:debug("info", name, objectIcon)
        local left, right, top, bottom = _G.GetObjectIconTextureCoords(objectIcon)
        self:debug("points", left, right, top, bottom)

        -- Notify
        if (_G.GetTime() > self.lastMinimapRare.time + SOUND_TIMEOUT) then
            _G.PlaySoundFile([[Sound\Interface\RaidWarning.wav]])
        end
        if RealUI.isBeta then
            RealUI:Notification(name, true, "- has appeared on the MiniMap!", nil, [[Interface\MINIMAP\ObjectIconsAtlas]], left, right, top, bottom)
        else
            RealUI:Notification(name, true, "- has appeared on the MiniMap!", nil, [[Interface\MINIMAP\OBJECTICONS]], left, right, top, bottom)
        end
    end

    -- Set last Vignette data
    self.lastMinimapRare.time = _G.GetTime()
    self.lastMinimapRare.id = vigID
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
        _G.OpenCalendar()
        self:RegisterEvent("CALENDAR_UPDATE_PENDING_INVITES")
    end

    if db.checkEvents then
        alertEvents()
    end
    if db.checkGuildEvents then
        alertGuildEvents()
    end
end

----
function EventNotifier:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
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
    self:RegisterEvent("VIGNETTE_ADDED")
end

function EventNotifier:OnDisable()
    self:UnregisterAllEvents()
end
