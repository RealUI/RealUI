local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local Tablet20 = LibStub("Tablet-2.0")
local db, ndb, ndbc

local MODNAME = "ScreenSaver"
local ScreenSaver = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn

local Tablets = {}

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Screen Saver",
		desc = "Dims the screen when you are AFK.",
		childGroups = "tab",
		arg = MODNAME,
		-- order = 1903,
		args = {
			header = {
				type = "header",
				name = "Screen Saver",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Dims the screen when you are AFK.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Screen Saver module.",
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
			general = {
				type = "group",
				name = "General",
				inline = true,
				order = 40,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				args = {
					opacity1 = {
						type = "range",
						name = "Initial Dim",
						desc = "How dark to set the gameworld when you go AFK.",
						min = 0, max = 1, step = 0.05,
						isPercent = true,
						get = function(info) return db.general.opacity1 end,
						set = function(info, value) db.general.opacity1 = value end,
						order = 10,
					},
					opacity2 = {
						type = "range",
						name = "5min+ Dim",
						desc = "How dark to set the gameworld after 5 minutes of being AFK.",
						min = 0, max = 1, step = 0.05,
						isPercent = true,
						get = function(info) return db.general.opacity2 end,
						set = function(info, value) db.general.opacity2 = value end,
						order = 20,
					},
					combatwarning = {
						type = "toggle",
						name = "Combat Warning",
						desc = "Play a warning sound if you enter combat while AFK.",
						get = function() return db.general.combatwarning end,
						set = function(info, value)
							db.general.combatwarning = value
						end,
						order = 30,
					},
				},
			},
			gap2 = {
				name = " ",
				type = "description",
				order = 41,
			},
			panel = {
				type = "group",
				name = "Panel",
				inline = true,
				order = 50,
				disabled = function() return not nibRealUI:GetModuleEnabled(MODNAME) end,
				args = {
					automove = {
						type = "toggle",
						name = "Auto Move",
						desc = "Reposition the Panel up and down the screen once every minute.",
						get = function() return db.panel.automove end,
						set = function(info, value)
							db.panel.automove = value
						end,
						order = 20,
					},
				},
			},
		},
	}
	end
	return options
end

local SecToMin = 1/60
local SecToHour = SecToMin * SecToMin

local IsDark = false
local IsWarning = false
local OpacityLevel = 0
local AFKLevel = 0

-- Timer
function ScreenSaver:UpdateAFKTime(elapsed)
	local Hour = min(floor(elapsed * SecToHour), 99)
	local Min = mod(elapsed * SecToMin, 60)
	local Sec = floor(mod(elapsed, 60))
	local timeStr = ""
	
	if Hour >= 1 then
		if Min >= 1 then
			timeStr = string.format("%dh %dm", Hour, Min)
		else
			timeStr = string.format("%dh", Hour)
		end
	elseif Min >= 10 then
		timeStr = string.format("%dm", Min)
	elseif Min >= 1 then
		timeStr = string.format("%d:%02d", Min, Sec)
	else
		timeStr = string.format("%ds", Sec)
	end
	
	self.time:SetText("|cffC0C0C0"..timeStr.."|r")
	
	if mod(Sec, 60) == 0 then
		self:RepositionPanel(true)
	end
end

local AFKTimer = CreateFrame("Frame")
AFKTimer:Hide()
AFKTimer:SetScript("OnUpdate", function(self, elapsed)
	AFKTimer.elapsed = AFKTimer.elapsed + elapsed
	
	if AFKTimer.elapsed > AFKTimer.lastElapsed + 1 then
		AFKTimer.lastElapsed = AFKTimer.elapsed
		
		-- Set BG opacity
		if AFKTimer.elapsed > 300 then
			OpacityLevel = db.general.opacity2
			AFKLevel = 2
		else
			OpacityLevel = db.general.opacity1
			AFKLevel = 1
		end
		if not( UnitAffectingCombat("player") and db.general.combatwarning ) and GetCVar("autoClearAFK") == "1" then
			if ScreenSaver.bg:GetAlpha() ~= OpacityLevel then 
				UIFrameFadeIn(ScreenSaver.bg, 0.2, ScreenSaver.bg:GetAlpha(), OpacityLevel)
				ScreenSaver:ToggleOverlay(true)
			end
		end
		
		-- Make sure Size is still good
		ScreenSaver.bg:SetWidth(UIParent:GetWidth() + 5000)
		ScreenSaver.bg:SetHeight(UIParent:GetHeight() + 2000)
		ScreenSaver.panel:SetWidth(UIParent:GetWidth())
		
		-- Update AFK Time
		ScreenSaver:UpdateAFKTime(AFKTimer.elapsed)
	
		-- Check Auto AFK status
		if GetCVar("autoClearAFK") ~= "1" then ScreenSaver:AFKEvent() end
	end
end)

-- Show/Hide Warning
function ScreenSaver:ToggleWarning(val)
	if val then
		if not IsWarning then
			IsWarning = true
			
			-- Play warning sound if Screen Saver is active and you get put into combat
			if UnitAffectingCombat("player") and db.general.combatwarning then
				PlaySoundFile([[Interface\AddOns\nibRealUI\Media\ScreenSaver\ZingAlarm.mp3]])
			end
		end
	else
		if IsWarning then
			IsWarning = false
		end
	end
end

-- Show/Hide Screen Saver
function ScreenSaver:ToggleOverlay(val)
	if val and GetCVar("autoClearAFK") == "1" then
		if not IsDark then
			IsDark = true
			
			-- Fade In Screen Saver
			self:RepositionPanel()
			UIFrameFadeIn(self.bg, 0.2, 0, db.general["opacity"..AFKLevel])
			UIFrameFadeIn(self.panel, 0.2, 0, 1)
			AFKTimer:Show()
		end
	else
		if IsDark then
			IsDark = false
			
			-- Fade Out Screen Saver
			local function bgHide()
				self.bg:Hide()
			end
			local bgFadeInfo = {
				mode = "OUT",
				timeToFade = 0.2,
				finishedFunc = bgHide,
				startAlpha = self.bg:GetAlpha(),
			}
			UIFrameFade(self.bg, bgFadeInfo)
			
			local function panelHide()
				self.panel:Hide()
				if not UnitIsAFK("player") then
					self.time:SetText("0s")
				end
			end
			local panelFadeInfo = {
				mode = "OUT",
				timeToFade = 0.2,
				finishedFunc = panelHide,
			}
			UIFrameFade(self.panel, panelFadeInfo)
			
			-- Hide Screen Saver if we're not AFK
			if not UnitIsAFK("player") then
				AFKTimer:Hide()
			end
		end
	end
end

-- Update AFK status
function ScreenSaver:AFKEvent()
	if GetCVar("autoClearAFK") ~= "1" then
		-- Disable ScreenSaver if Auto Clear AFK is disabled
		self:ToggleOverlay(false)
		self:ToggleWarning(false)
		AFKLevel = 0
	elseif UnitIsAFK("player") then
		-- AFK
		if not AFKTimer:IsShown() then
			AFKTimer.elapsed = 0
			AFKTimer.lastElapsed = 0
			if not( UnitAffectingCombat("player") and db.general.combatwarning ) then
				UIFrameFadeIn(self.bg, 0.2, self.bg:GetAlpha(), db.general.opacity1)
				UIFrameFadeIn(self.panel, 0.2, 0, 1)
			end
			AFKTimer:Show()
			AFKLevel = 1
		end
		
		if ( UnitAffectingCombat("player") and db.general.combatwarning ) then
			-- AFK and In Combat
			if IsDark then
				self:ToggleOverlay(false)	-- Hide Screen Saver
				self:ToggleWarning(true)		-- Activate Warning				
			end
		else
			-- AFK and not In Combat
			if not IsDark then
				self:ToggleOverlay(true)		-- Show Screen Saver
				self:ToggleWarning(false)	-- Deactivate Warning
				AFKLevel = 1
			end
		end
	else
		-- Not AFK
		AFKTimer.elapsed = 0
		AFKTimer.lastElapsed = 0
		AFKTimer:Hide()
		AFKLevel = 0
		
		self:ToggleOverlay(false)	-- Hide Screen Saver
		self:ToggleWarning(false)	-- Deactivate Warning
	end
end

function ScreenSaver:RepositionPanel(...)
	if ... and not db.panel.automove then return end
	self.panel:ClearAllPoints()
	self.panel:SetPoint("BOTTOM", UIParent, "CENTER", 0, math.random(
		ndb.positions[ndbc.layout.current]["HuDY"] + 100,
		(UIParent:GetHeight() / 2) - 180
	))
end

-- Frame Updates
function ScreenSaver:UpdateFrames()
	-- self.panel:SetBackdropColor(0.075, 0.075, 0.075, db.panel.opacity)
	
	-- Make sure Size is still good
	self.bg:SetWidth(UIParent:GetWidth() + 5000)
	self.bg:SetHeight(UIParent:GetHeight() + 2000)
	
	self.panel:SetSize(UIParent:GetWidth(), 21)
end

-- Initialize / Refresh
function ScreenSaver:RefreshMod()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	
	db = self.db.profile
	ndb = nibRealUI.db.profile

	self:UpdateFrames()
	self:AFKEvent()
end

function ScreenSaver:PLAYER_LOGIN()
	LoggedIn = true
	
	self:RefreshMod()
end

-- Frame Creation
function ScreenSaver:CreateFrames()
	-- Dark Background
	self.bg = CreateFrame("Frame", nil, UIParent)
		self.bg:SetAllPoints(UIParent)
		self.bg:SetFrameStrata("BACKGROUND")
		self.bg:SetFrameLevel(0)
		self.bg:SetBackdrop({
			bgFile = nibRealUI.media.textures.plain,
		})
		self.bg:SetBackdropColor(0, 0, 0, 1)
		self.bg:SetAlpha(0)
		self.bg:Hide()
	
	-- Panel
	self.panel = CreateFrame("Frame", "RealUIScreenSaver", UIParent)
		self.panel:SetFrameStrata("MEDIUM")
		self.panel:SetFrameLevel("1")
		self.panel:SetSize(UIParent:GetWidth(), 21)
		-- self.panel:SetBackdropColor(0.075, 0.075, 0.075, db.panel.opacity)
		nibRealUI:CreateBD(self.panel, nil, true)
		self.panel:SetBackdropColor(unpack(nibRealUI.media.window))
		self.panel:SetAlpha(0)
		self.panel:Hide()
		self:RepositionPanel()
	
	self.panel.left = self.panel:CreateTexture(nil, "ARTWORK")
		self.panel.left:SetTexture(unpack(nibRealUI.classColor))
		self.panel.left:SetPoint("LEFT", self.panel, "LEFT", 0, 0)
		self.panel.left:SetHeight(19)
		self.panel.left:SetWidth(4)
	
	self.panel.right = self.panel:CreateTexture(nil, "ARTWORK")
		self.panel.right:SetTexture(unpack(nibRealUI.classColor))
		self.panel.right:SetPoint("RIGHT", self.panel, "RIGHT", 0, 0)
		self.panel.right:SetHeight(19)
		self.panel.right:SetWidth(4)
	
	-- Timer
	self.timeLabel = nibRealUI:CreateFS(self.panel, "CENTER")
		self.timeLabel:SetPoint("RIGHT", self.panel, "CENTER", 15, 0)
		self.timeLabel:SetText("|cffffffffAFK |r|cff"..nibRealUI:ColorTableToStr(nibRealUI.classColor).."TIME:")
		self.timeLabel:SetFont(unpack(nibRealUI.font.pixel1))
	
	self.time = nibRealUI:CreateFS(self.panel, "LEFT")
		self.time:SetPoint("LEFT", self.panel, "CENTER", 17, 0)
		self.time:SetFont(unpack(nibRealUI.font.pixel1))
		self.time:SetText("0s")
end

----
function ScreenSaver:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			general = {
				opacity1 = 0.30,
				opacity2 = 0.50,
				combatwarning = true,
			},
			panel = {
				automove = true,
			},
		},
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)

	ScreenSaver:CreateFrames()
	
	self:RegisterEvent("PLAYER_LOGIN")
end

function ScreenSaver:OnEnable()
	self:RegisterEvent("PLAYER_FLAGS_CHANGED", "AFKEvent")
	self:RegisterEvent("WORLD_MAP_UPDATE", "AFKEvent")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "AFKEvent")
	self:RegisterEvent("PLAYER_REGEN_DISABLED", "AFKEvent")	
	
	if LoggedIn then 
		ScreenSaver:RefreshMod()
	end
end

function ScreenSaver:OnDisable()
	self:UnregisterEvent("PLAYER_FLAGS_CHANGED")
	self:UnregisterEvent("WORLD_MAP_UPDATE")
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	self:UnregisterEvent("PLAYER_REGEN_DISABLED")
	
	AFKTimer.elapsed = 0
	AFKTimer.lastElapsed = 0
	self.panel:Hide()
	AFKTimer:Hide()
	ScreenSaver:ToggleOverlay(false)
	ScreenSaver:ToggleWarning(false)
end