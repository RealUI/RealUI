-- Code from EventNotifier by the awesome Haleth
-- http://www.wowinterface.com/downloads/info21370-EventNotifier.html

local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local MODNAME = "EventNotifier"
local EventNotifier = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

-- Addon itself
local numInvites = 0 -- store amount of invites to compare later, and only show banner when invites differ; events fire multiple times

local function GetGuildInvites()
	local numGuildInvites = 0
	local _, currentMonth = CalendarGetDate()

	for i = 1, CalendarGetNumGuildEvents() do
		local month, day = CalendarGetGuildEventInfo(i)
		local monthOffset = month - currentMonth
		local numDayEvents = CalendarGetNumDayEvents(monthOffset, day)

		for i = 1, numDayEvents do
			local _, _, _, _, _, _, _, _, inviteStatus = CalendarGetDayEvent(monthOffset, day, i)
			if inviteStatus == 8 then
				numGuildInvites = numGuildInvites + 1
			end
		end
	end

	return numGuildInvites
end

local function toggleCalendar()
	if not CalendarFrame then LoadAddOn("Blizzard_Calendar") end
	Calendar_Toggle()
end

local function alertEvents()
	if CalendarFrame and CalendarFrame:IsShown() then return end
	local num = CalendarGetNumPendingInvites()
	if num ~= numInvites then
		if num > 1 then
			nibRealUI:Notification("Pending Invites", false, format("You have %s pending calendar invites.", num), toggleCalendar)
		elseif num > 0 then
			nibRealUI:Notification("Pending Invite", false, "You have 1 pending calendar invite.", toggleCalendar)
		end
		numInvites = num
	end
end

local function alertGuildEvents()
	if CalendarFrame and CalendarFrame:IsShown() then return end
	local num = GetGuildInvites()
	if num > 1 then
		nibRealUI:Notification("Pending Guild Events", false, (format("You have %s pending guild events.", num)), toggleCalendar)
	elseif num > 0 then
		nibRealUI:Notification("Pending Guild Event", false, "You have 1 pending guild event.", toggleCalendar)
	end
end

function EventNotifier:CALENDAR_UPDATE_GUILD_EVENTS()
	alertGuildEvents()
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
		OpenCalendar()
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
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			checkEvents = true,
			checkGuildEvents = true,
		},
	})
	db = self.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function EventNotifier:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("CALENDAR_UPDATE_GUILD_EVENTS")
end

function EventNotifier:OnDisable()
	self:UnregisterAllEvents()
end