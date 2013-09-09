local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local LSM = LibStub("LibSharedMedia-3.0")
local db, ndbc

local MODNAME = "MirrorBar"
local MirrorBar = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false

local MBFrames = {}

local UpdateInterval = 0

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Mirror Bar",
		desc = "Display of Breath, Exhaustion and Feign Death.",
		arg = MODNAME,
		childGroups = "tab",
		args = {
			header = {
				type = "header",
				name = "Mirror Bar",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Display of Breath, Exhaustion and Feign Death.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Mirror Bar module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
				end,
				order = 30,
			},
			gap1 = {
				name = " ",
				type = "description",
				order = 31,
			},
			size = {
				name = "Size",
				type = "group",
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				inline = true,
				order = 50,
				args = {
					width = {
						type = "input",
						name = "Width",
						width = "half",
						order = 10,
						get = function(info) return tostring(db.size.width) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.size.width = value
							MirrorBar:UpdatePosition()
						end,
					},
					height = {
						type = "input",
						name = "Height",
						width = "half",
						order = 20,
						get = function(info) return tostring(db.size.height) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.size.height = value
							MirrorBar:UpdatePosition()
						end,
					},
				},							
			},
			gap2 = {
				name = " ",
				type = "description",
				order = 51,
			},
			position = {
				name = "Position",
				type = "group",
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				inline = true,
				order = 60,
				args = {
					position = {
						name = "Position",
						type = "group",
						inline = true,
						order = 10,
						args = {
							xoffset = {
								type = "input",
								name = "X Offset",
								width = "half",
								order = 10,
								get = function(info) return tostring(db.position.x) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.position.x = value
									MirrorBar:UpdatePosition()
								end,
							},
							yoffset = {
								type = "input",
								name = "Y Offset",
								width = "half",
								order = 20,
								get = function(info) return tostring(db.position.y) end,
								set = function(info, value)
									value = nibRealUI:ValidateOffset(value)
									db.position.y = value
									MirrorBar:UpdatePosition()
								end,
							},
							anchorto = {
								type = "select",
								name = "Anchor To",
								get = function(info) 
									for k,v in pairs(nibRealUI.globals.anchorPoints) do
										if v == db.position.anchorto then return k end
									end
								end,
								set = function(info, value)
									db.position.anchorto = nibRealUI.globals.anchorPoints[value]
									MirrorBar:UpdatePosition()
								end,
								style = "dropdown",
								width = nil,
								values = nibRealUI.globals.anchorPoints,
								order = 30,
							},
							anchorfrom = {
								type = "select",
								name = "Anchor From",
								get = function(info) 
									for k,v in pairs(nibRealUI.globals.anchorPoints) do
										if v == db.position.anchorfrom then return k end
									end
								end,
								set = function(info, value)
									db.position.anchorfrom = nibRealUI.globals.anchorPoints[value]
									MirrorBar:UpdatePosition()
								end,
								style = "dropdown",
								width = nil,
								values = nibRealUI.globals.anchorPoints,
								order = 40,
							},
						},
					},
				},
			},
		},
	}
	end
	return options
end

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
	if not(UnitIsDead("player") or UnitIsGhost("player") or UnitInVehicle("player")) then
		for k,v in pairs(self.timers) do
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
			self.timers[v].value = self.timers[v].value + (self.timers[v].scale * ((GetTime() - self.timers[v].lastTime) * 1000))
			self.timers[v].lastTime = GetTime()
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
	curTimer.timeRemaining = floor(curTimer.value / 1000)
	curTimer.timeRemaining = nibRealUI:Clamp(curTimer.timeRemaining, 0, curTimer.max / 1000)
	
	-- Scale
	scale = (curTimer.max ~= 0) and (curTimer.value / curTimer.max) or 0
	scale = nibRealUI:Clamp(scale, 0, 1)
	
	-- Update bar
	local _,_,_,_,_, label = GetMirrorTimerInfo(self.currentTimer)
	self:UpdateBar(scale, curTimer.timeRemaining or 0, label or "")
end

function MirrorBar:MIRROR_TIMER_PAUSE(event, paused)
	for k,v in pairs(self.timers) do
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
	self.timers[timer].lastTime = GetTime()
	
	self:UpdateShown()
end

-- Colors
function MirrorBar:UpdateColors()
	-- BG + Border
	MBFrames.bg:SetBackdropColor(unpack(nibRealUI.media.background))
	MBFrames.bg:SetBackdropBorderColor(0, 0, 0, 1)
end

-- Font
function MirrorBar:UpdateFonts()
	-- Text
	MBFrames.text:SetFont(unpack(nibRealUI:Font()))
end

-- Position
function MirrorBar:UpdatePosition()
	-- BG + Border
	MBFrames.bg:SetPoint(db.position.anchorfrom, UIParent, db.position.anchorto, db.position.x, db.position.y)
	
	MBFrames.bg:SetFrameStrata("MEDIUM")
	MBFrames.bg:SetFrameLevel(1)
	
	MBFrames.bg:SetHeight(db.size.height)
	MBFrames.bg:SetWidth(db.size.width)
end

-- Refresh
function MirrorBar:RefreshMod()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end

	db = self.db.profile
	
	MirrorBar:UpdatePosition()
	MirrorBar:UpdateFonts()
	MirrorBar:UpdateColors()
end

function MirrorBar:PLAYER_LOGIN()
	LoggedIn = true
	MirrorBar:RefreshMod()
end

-- Create Frames
function MirrorBar:CreateFrames()
	-- BG + Border
	MBFrames.bg = CreateFrame("Frame", "RealUI_MirrorBar", UIParent)
	MBFrames.bg:SetPoint(db.position.anchorfrom, UIParent, db.position.anchorto, db.position.x, db.position.y)	
	
	MBFrames.bg:SetBackdrop({
		bgFile = nibRealUI.media.textures.plain, 
		edgeFile = nibRealUI.media.textures.plain, 
		tile = false, tileSize = 0, edgeSize = 1, 
		insets = { left = 0, right = 0, top = 0, bottom = 0}
	})

	-- Bar + Text
	MBFrames.bar = CreateFrame("StatusBar", nil, MBFrames.bg)
	MBFrames.bar:SetStatusBarTexture(nibRealUI.media.textures.plain)
	MBFrames.bar:SetMinMaxValues(0, 1)
	MBFrames.bar:SetPoint("TOPLEFT", MBFrames.bg, "TOPLEFT", 1, -1)
	MBFrames.bar:SetPoint("BOTTOMRIGHT", MBFrames.bg, "BOTTOMRIGHT", -1, 1)

	MBFrames.text = MBFrames.bar:CreateFontString(nil, "OVERLAY")
	MBFrames.text:SetPoint("CENTER", MBFrames.bar, "CENTER", 1.5, -0.5)
	MBFrames.text:SetFont(unpack(nibRealUI.font.pixel1))
	MBFrames.text:SetTextColor(1, 1, 1, 1)

	-- Update Power
	MBFrames.bar.elapsed = 0
	MBFrames.bar:SetScript("OnUpdate", function(self, elapsed)
		MirrorBar:OnUpdate(self, elapsed)
	end)
	
	MBFrames.bg:Hide()
end

function MirrorBar:UpdateGlobalColors()
	self.timerColors = {
		["EXHAUSTION"] =	nibRealUI.media.colors.orange,
		["BREATH"] =		nibRealUI.media.colors.blue,
		["FEIGNDEATH"] =	nibRealUI.media.colors.red,
		["DEATH"] =			nibRealUI.media.colors.red,
	}
	self.loopElapsed = 1
end

-- Initialize
function MirrorBar:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
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
	ndbc = nibRealUI.db.char
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)
	
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
		["EXHAUSTION"] =	{},
		["BREATH"] =		{},
		["FEIGNDEATH"] =	{},
		["DEATH"] =			{},
	}
	self:UpdateGlobalColors()
	self.loopElapsed = 1
	self.elapsed = 1

	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("MIRROR_TIMER_START")
	self:RegisterEvent("MIRROR_TIMER_STOP")
	self:RegisterEvent("MIRROR_TIMER_PAUSE")
	
	-- Hide Default
	UIParent:UnregisterEvent("MIRROR_TIMER_START")
	
	if LoggedIn then
		MirrorBar:RefreshMod()
	end
end

function MirrorBar:OnDisable()
	self:UnregisterAllEvents()
	
	MBFrames.bg:Hide()
	UIParent:RegisterEvent("MIRROR_TIMER_START")
end