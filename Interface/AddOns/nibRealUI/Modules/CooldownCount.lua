-- Code based on tullaCooldownCount by Tuller
-- http://www.wowinterface.com/downloads/info17602-tullaCooldownCount.html

local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local _
local MODNAME = "CooldownCount"
local CooldownCount = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")
nibRealUI.CooldownCount = CooldownCount

local Timer = {}
CooldownCount.Timer = Timer

--local bindings!
local UIParent = _G["UIParent"]
local GetTime = _G["GetTime"]
local floor = math.floor
local min = math.min
local round = function(x) return floor(x + 0.5) end
local strform = string.format

-- Options
local table_Justify = {"LEFT", "CENTER", "RIGHT"}

local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Cooldown Count",
		desc = "Adds cooldown text to the Action Bars.",
		arg = MODNAME,
		-- order = 315,
		args = {
			header = {
				type = "header",
				name = "Cooldown Count",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Adds cooldown text to the Action Bars.",
				fontSize = "medium",
				order = 20,
			},
			desc2 = {
				type = "description",
				name = " ",
				order = 21,
			},
			desc3 = {
				type = "description",
				name = "Note: You will need to reload the UI (/rl) for changes to take effect.",
				order = 22,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Cooldown Count module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
					nibRealUI:ReloadUIDialog()
				end,
				order = 30,
			},
			gap1 = {
				name = " ",
				type = "description",
				order = 41,
			},
			minScale = {
				type = "range",
				name = "Min Scale",
				desc = "The minimum scale we want to show cooldown counts at, anything below this will be hidden.",
				min = 0, max = 1, step = 0.05,
				isPercent = true,
				get = function(info) return db.minScale end,
				set = function(info, value) 
					db.minScale = value
				end,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				order = 60,
			},
			minDuration = {
				type = "range",
				name = "Min Duration",
				desc = "The minimum number of seconds a cooldown's duration must be to display text.",
				min = 0, max = 30, step = 1,
				get = function(info) return db.minDuration end,
				set = function(info, value) 
					db.minDuration = value
				end,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				order = 70,
			},
			expiringDuration = {
				type = "range",
				name = "Expiring Duration",
				desc = "The minimum number of seconds a cooldown must be to display in the expiring format.",
				min = 0, max = 30, step = 1,
				get = function(info) return db.expiringDuration end,
				set = function(info, value) 
					db.expiringDuration = value
				end,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				order = 80,
			},
			gap2 = {
				name = " ",
				type = "description",
				order = 81,
			},
			colors = {
				name = "Colors",
				type = "group",
				inline = true,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				order = 90,
				args = {
					expiring = {
						type = "color",
						name = "Expiring",
						hasAlpha = false,
						get = function(info,r,g,b)
							return db.colors.expiring[1], db.colors.expiring[2], db.colors.expiring[3]
						end,
						set = function(info,r,g,b)
							db.colors.expiring[1] = r
							db.colors.expiring[2] = g
							db.colors.expiring[3] = b
						end,
						order = 10,
					},
					seconds = {
						type = "color",
						name = "Seconds",
						hasAlpha = false,
						get = function(info,r,g,b)
							return db.colors.seconds[1], db.colors.seconds[2], db.colors.seconds[3]
						end,
						set = function(info,r,g,b)
							db.colors.seconds[1] = r
							db.colors.seconds[2] = g
							db.colors.seconds[3] = b
						end,
						order = 20,
					},
					minutes = {
						type = "color",
						name = "Minutes",
						hasAlpha = false,
						get = function(info,r,g,b)
							return db.colors.minutes[1], db.colors.minutes[2], db.colors.minutes[3]
						end,
						set = function(info,r,g,b)
							db.colors.minutes[1] = r
							db.colors.minutes[2] = g
							db.colors.minutes[3] = b
						end,
						order = 30,
					},
					hours = {
						type = "color",
						name = "Hours",
						hasAlpha = false,
						get = function(info,r,g,b)
							return db.colors.hours[1], db.colors.hours[2], db.colors.hours[3]
						end,
						set = function(info,r,g,b)
							db.colors.hours[1] = r
							db.colors.hours[2] = g
							db.colors.hours[3] = b
						end,
						order = 40,
					},
					days = {
						type = "color",
						name = "days",
						hasAlpha = false,
						get = function(info,r,g,b)
							return db.colors.days[1], db.colors.days[2], db.colors.days[3]
						end,
						set = function(info,r,g,b)
							db.colors.days[1] = r
							db.colors.days[2] = g
							db.colors.days[3] = b
						end,
						order = 50,
					},
				},
			},
			gap3 = {
				name = " ",
				type = "description",
				order = 91,
			},
			position = {
				name = "Position",
				type = "group",
				inline = true,
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 100,
				args = {
					point = {
						type = "select",
						name = "Anchor",
						get = function(info) 
							for k,v in pairs(nibRealUI.globals.anchorPoints) do
								if v == db.position.point then return k end
							end
						end,
						set = function(info, value)
							db.position.point = nibRealUI.globals.anchorPoints[value]
						end,
						style = "dropdown",
						width = nil,
						values = nibRealUI.globals.anchorPoints,
						order = 10,
					},
					x = {
						type = "input",
						name = "X",
						width = "half",
						order = 20,
						get = function(info) return tostring(db.position.x) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.position.x = value
						end,
					},
					y = {
						type = "input",
						name = "Y",
						width = "half",
						order = 30,
						get = function(info) return tostring(db.position.y) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.position.y = value
						end,
					},
					justify = {
						type = "select",
						name = "Text Justification",
						get = function(info) 
							for k,v in pairs(table_Justify) do
								if v == db.position.justify then return k end
							end
						end,
						set = function(info, value)
							db.position.justify = table_Justify[value]
						end,
						style = "dropdown",
						width = nil,
						values = table_Justify,
						order = 40,
					},
				},
			},
		},
	}
	end
	
	return options
end

----------
--sexy constants!
local ICON_SIZE = 36 --the normal size for an icon (don't change this)
local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for formatting text at transition points
local HALFDAYISH, HALFHOURISH, HALFMINUTEISH = DAY/2 + 0.5, HOUR/2 + 0.5, MINUTE/2 + 0.5 --used for calculating next update times

local SECONDS_FORMAT, MINUTES_FORMAT, HOURS_FORMAT, DAYS_FORMAT, EXPIRING_FORMAT
local function ColorTableToStr(vals)
	return strform("%02x%02x%02x", vals[1] * 255, vals[2] * 255, vals[3] * 255)
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
	
	local start, duration, enable = GetActionCooldown(action)
	local charges, maxCharges, chargeStart, chargeDuration = GetActionCharges(action)
	
	if cooldown_ShouldUpdateTimer(self, start, duration, charges, maxCharges) then
		Timer.Start(self, start, duration, charges, maxCharges)
	end
end

function CooldownCount:ACTIONBAR_UPDATE_COOLDOWN()
	for cooldown in pairs(active) do
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
	local remain = self.duration - (GetTime() - self.start)
	if round(remain) > 0 then
		if (self.fontScale * self:GetEffectiveScale() / UIParent:GetScale()) < db.minScale then
			self.text:SetText("")
			Timer.SetNextUpdate(self, 1)
		else
			local formatStr, time, nextUpdate = getTimeText(remain)
			if (remain >= MINUTEISH * 10) and (nibRealUI.font.pixelCooldown[2] >= 16) then
				self.text:SetFont(nibRealUI.font.pixelCooldown[1], nibRealUI.font.pixelCooldown[2] / 2, nibRealUI.font.pixelCooldown[3])
			else
				self.text:SetFont(nibRealUI.font.pixelCooldown[1], nibRealUI.font.pixelCooldown[2], nibRealUI.font.pixelCooldown[3])
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
		self.text:SetFont(nibRealUI.font.pixelCooldown[1], nibRealUI.font.pixelCooldown[2], nibRealUI.font.pixelCooldown[3])
		if self.enabled then
			Timer.ForceUpdate(self)
		end
	end
end

--returns a new timer object
function Timer.Create(cd)
	--a frame to watch for OnSizeChanged events
	--needed since OnSizeChanged has funny triggering if the frame with the handler is not shown
	local scaler = CreateFrame('Frame', nil, cd)
	scaler:SetAllPoints(cd)

	local timer = CreateFrame('Frame', nil, scaler); timer:Hide()
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
		text:SetFont(nibRealUI.font.pixelCooldown[1], nibRealUI.font.pixelCooldown[2], nibRealUI.font.pixelCooldown[3])

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
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			minScale = 0.5,
			minDuration = 2,
			expiringDuration = 5,
			colors = {
				expiring =	{1,		0,		0},
				seconds =	{1,		1,		0},
				minutes =	{1,		1,		1},
				hours =		{0.25,	1,		1},
				days =		{0.25,	0.25,	1},
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
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
end

function CooldownCount:OnEnable()
	setTimeFormats()

	hooksecurefunc(getmetatable(_G["ActionButton1Cooldown"]).__index, "SetCooldown", Timer.Start)
	
	-- 4.3 compatibility
	-- In WoW 4.3 and later, action buttons can completely bypass lua for updating cooldown timers
	-- This set of code is there to check and force update timers on standard action buttons (henceforth defined as anything that reuses's blizzard's ActionButton.lua code)
	local ActionBarButtonEventsFrame = _G["ActionBarButtonEventsFrame"]
	if ActionBarButtonEventsFrame then
		if ActionBarButtonEventsFrame.frames then
			for i, frame in pairs(ActionBarButtonEventsFrame.frames) do
				actionButton_Register(frame)
			end
		end
		hooksecurefunc("ActionBarButtonEventsFrame_RegisterFrame", actionButton_Register)
		self:RegisterEvent("ACTIONBAR_UPDATE_COOLDOWN")
	end
end