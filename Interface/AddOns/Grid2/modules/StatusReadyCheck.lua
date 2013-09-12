-- Original Grid Version: Greltok

local ReadyCheck = Grid2.statusPrototype:new("ready-check")

local L = LibStub:GetLibrary("AceLocale-3.0"):GetLocale("Grid2")

local readyChecking, timerClearStatus
local readyStatuses = {}

function ReadyCheck:READY_CHECK(event, originator)
	if timerClearStatus then
		Grid2:CancelTimer(timerClearStatus, true)
		timerClearStatus = nil
	end
	readyChecking = true

	for unit in Grid2:IterateRosterUnits() do
		readyStatuses[unit] = GetReadyCheckStatus(unit)
		if not Grid2:UnitIsPet(unit) then
			self:UpdateIndicators(unit)
		end
	end
end

function ReadyCheck:READY_CHECK_CONFIRM(event, unit)
	if readyChecking then
		self:UpdateIndicators(unit)
	end
end

function ReadyCheck:READY_CHECK_FINISHED()
	for unit in Grid2:IterateRosterUnits() do
		if not Grid2:UnitIsPet(unit) then
			self:UpdateIndicators(unit)
		end
	end
	timerClearStatus = Grid2:ScheduleTimer(self.ClearStatus, ReadyCheck.dbx.threshold or 0, self)
end

function ReadyCheck:GROUP_ROSTER_UPDATE()
  if readyChecking then
		for unit in Grid2:IterateRosterUnits() do
			if not Grid2:UnitIsPet(unit) then
				self:UpdateIndicators(unit)
			end
		end
  end
end

function ReadyCheck:CheckClearStatus()
	-- Unfortunately, GetReadyCheckTimeLeft() only returns integral values.
	if readyChecking and GetReadyCheckTimeLeft() <= 0 then
		self:ClearStatus()
	end
end

function ReadyCheck:ClearStatus()
	if readyChecking then
		readyChecking = nil
		for unit in Grid2:IterateRosterUnits() do
			self:UpdateIndicators(unit)
		end
		timerClearStatus = nil
	end
end

function ReadyCheck:OnEnable()
	self:RegisterEvent("READY_CHECK")
	self:RegisterEvent("READY_CHECK_CONFIRM")
	self:RegisterEvent("READY_CHECK_FINISHED")
	self:RegisterEvent("GROUP_ROSTER_UPDATE")
	self:RegisterMessage("Grid_GroupTypeChanged", "CheckClearStatus")
end

function ReadyCheck:OnDisable()
	self:ClearStatus()
	self:UnregisterEvent("READY_CHECK")
	self:UnregisterEvent("READY_CHECK_CONFIRM")
	self:UnregisterEvent("READY_CHECK_FINISHED")
	self:UnregisterEvent("GROUP_ROSTER_UPDATE")
	self:UnregisterMessage("Grid_GroupTypeChanged")
end

function ReadyCheck:IsActive(unit)
	return readyChecking
end

function ReadyCheck:GetReadyCheckStatus(unit)
	if not readyChecking then return nil end
	local state = GetReadyCheckStatus(unit)
	if not state then
		--we're in the window where we need to persist the readystate
		state = readyStatuses[unit]
		--with the blizz UI, if a player is AFK then they will display blank
		-- while everyone else is tick / cross. Emulate that here
		if state == "waiting" then state = "afk" end
	else
		readyStatuses[unit] = state
	end
	return state
end

local colors = {
	waiting =  "color1",
	ready = "color2",
	notready = "color3",
	afk = "color4",
}
function ReadyCheck:GetColor(unitid)
	local state = self:GetReadyCheckStatus(unitid)
	if state then
		local color = self.dbx[colors[state]]
		return color.r, color.g, color.b, color.a
	end
end

local icons = {
	waiting =  READY_CHECK_WAITING_TEXTURE,
	ready = READY_CHECK_READY_TEXTURE,
	notready = READY_CHECK_NOT_READY_TEXTURE,
	afk = READY_CHECK_AFK_TEXTURE,
}
function ReadyCheck:GetIcon(unitid)
	local state = self:GetReadyCheckStatus(unitid)
	if state then
		return icons[state]
	end
end

local texts = {
	waiting =  L["?"],
	ready = L["R"],
	notready = L["X"],
	afk = L["AFK"],
}
function ReadyCheck:GetText(unitid)
	local state = self:GetReadyCheckStatus(unitid)
	if state then
		return texts[state]
	end
end

local function Create(baseKey, dbx)
	Grid2:RegisterStatus(ReadyCheck, {"color", "icon", "text"}, baseKey, dbx)

	return ReadyCheck
end

Grid2.setupFunc["ready-check"] = Create

Grid2:DbSetStatusDefaultValue( "ready-check", {type = "ready-check", threshold = 10, colorCount = 4, color1 = {r=1,g=1,b=0,a=1}, color2 = {r=0,g=1,b=0,a=1}, color3 = {r=1,g=0,b=0,a=1}, color4 = {r=1,g=0,b=1,a=1}})
