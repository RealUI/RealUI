local nibRealUI = LibStub("AceAddon-3.0"):NewAddon("nibRealUI", "AceConsole-3.0", "AceEvent-3.0", "AceTimer-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, dbc, dbg
_G.RealUI = nibRealUI

nibRealUI.verinfo = {
	[1] = 8,
	[2] = 0,
	[3] = 31,
}

if not REALUI_STRIPE_TEXTURES then REALUI_STRIPE_TEXTURES = {} end
if not REALUI_WINDOW_FRAMES then REALUI_WINDOW_FRAMES = {} end

nibRealUI.oocFunctions = {}
nibRealUI.configModeModules = {}

-- Localized Fonts
do
	nibRealUI.locale = GetLocale()
	local StandardLanguageSupport = {
		enUS = true,
		enGB = true,
		itIT = true,
		frFR = true,
		deDE = true,
		esES = true,
		esMX = true,
		ptBR = true,
		ruRU = true,
	}

	if not(nibRealUI.locale) or StandardLanguageSupport[nibRealUI.locale] then
		nibRealUI.defaultFonts = {
			standard = {"Standard"},
			pixel = {
				small =		{"pixel_small",		8,	"MONOCHROMEOUTLINE"},
				large =		{"pixel_large",		8,	"MONOCHROMEOUTLINE"},
				numbers =	{"pixel_numbers",	16,	"MONOCHROMEOUTLINE"},
				cooldown =	{"pixel_cooldown",	16,	"MONOCHROMEOUTLINE"},
			}
		}
	else
		nibRealUI.defaultFonts = {
			standard = {"Arial Narrow"},
			pixel = {
				small =		{"Arial Narrow",	10,	"OUTLINE"},
				large =		{"Arial Narrow",	10,	"OUTLINE"},
				numbers =	{"pixel_numbers",	16,	"MONOCHROMEOUTLINE"},
				cooldown =	{"pixel_cooldown",	16,	"MONOCHROMEOUTLINE"},
			}
		}
	end
end

nibRealUI.fontStringsTiny = {}
nibRealUI.fontStringsSmall = {}
nibRealUI.fontStringsRegular = {}
nibRealUI.fontStringsLarge = {}

nibRealUI.defaultPositions = {
	[1] = {		-- DPS/Tank
		["Nothing"] = 0,
		["HuDX"] = 0,
		["HuDY"] = -38,
		["UFHorizontal"] = 316,
		["ActionBarsY"] = -161.5,
		["GridTopX"] = 0,
		["GridTopY"] = -197.5,
		["GridBottomX"] = 0,
		["GridBottomY"] = 58,
		["CTAurasLeftX"] = 0,
		["CTAurasLeftY"] = 0,
		["CTAurasRightX"] = 0,
		["CTAurasRightY"] = 0,
		["CTPointsWidth"] = 184,
		["CTPointsHeight"] = 148,
		["CastBarPlayerX"] = 0,
		["CastBarPlayerY"] = 0,
		["CastBarTargetX"] = 0,
		["CastBarTargetY"] = 0,
		["SpellAlertWidth"] = 200,
		["ClassAuraWidth"] = 80,
		["ClassResourceX"] = 0,
		["ClassResourceY"] = 0,
		["RunesX"] = 0,
		["RunesY"] = 0,
		["BossX"] = -32,		-- Boss anchored to RIGHT
		["BossY"] = 314,
	},
	[2] = {		-- Healing
		["Nothing"] = 0,
		["HuDX"] = 0,
		["HuDY"] = -38,
		["UFHorizontal"] = 316,
		["ActionBarsY"] = -161.5,
		["GridTopX"] = 0,
		["GridTopY"] = -197.5,
		["GridBottomX"] = 0,
		["GridBottomY"] = 58,
		["CTAurasLeftX"] = 0,
		["CTAurasLeftY"] = 0,
		["CTAurasRightX"] = 0,
		["CTAurasRightY"] = 0,
		["CTPointsWidth"] = 184,
		["CTPointsHeight"] = 148,
		["CastBarPlayerX"] = 0,
		["CastBarPlayerY"] = 0,
		["CastBarTargetX"] = 0,
		["CastBarTargetY"] = 0,
		["SpellAlertWidth"] = 200,
		["ClassAuraWidth"] = 80,
		["ClassResourceX"] = 0,
		["ClassResourceY"] = 0,
		["RunesX"] = 0,
		["RunesY"] = 0,
		["BossX"] = -32,		-- Boss anchored to RIGHT
		["BossY"] = 314,
	},
}

-- Offset some UI Elements for Large/Small HuD size settings
nibRealUI.hudSizeOffsets = {
	[1] = {
		["UFHorizontal"] = 0,
		["SpellAlertWidth"] = 0,
		["ActionBarsY"] = 0,
		["GridTopY"] = 0,
		["CastBarPlayerY"] = 0,
		["CastBarTargetY"] = 0,
		["ClassResourceY"] = 0,
		["CTPointsHeight"] = 0,
		["CTAurasLeftX"] = 0,
		["CTAurasLeftY"] = 0,
		["CTAurasRightX"] = 0,
		["CTAurasRightY"] = 0,
		["RunesY"] = 0,
	},
	[2] = {
		["UFHorizontal"] = 50,
		["SpellAlertWidth"] = 50,
		["ActionBarsY"] = -20,
		["GridTopY"] = -20,
		["CastBarPlayerY"] = -20,
		["CastBarTargetY"] = -20,
		["ClassResourceY"] = -20,
		["CTPointsHeight"] = 40,
		["CTAurasLeftX"] = -1,
		["CTAurasLeftY"] = -20,
		["CTAurasRightX"] = 1,
		["CTAurasRightY"] = -20,
		["RunesY"] = -20,
	},
}

nibRealUI.defaultActionBarSettings = {
	[1] = {		-- DPS/Tank
		centerPositions = 2,	-- 1 top, 2 bottom
		sidePositions = 1,		-- 2 Right, 0 Left
		-- stanceBar = {position = "BOTTOM", padding = 1},
		petBar = {padding = 1},
		bars = {
			[1] = {buttons = 10, padding = 1},
			[2] = {buttons = 12, padding = 1},
			[3] = {buttons = 12, padding = 1},
			[4] = {buttons = 10, padding = 1},
			[5] = {buttons = 10, padding = 1}
		},
		moveBars = {
			stance = true,
			pet = true,
			eab = true,
		},
	},
	[2] = {		-- Healing
		centerPositions = 2,	-- 1 top, 2 bottom
		sidePositions = 1,		-- 2 Right, 0 Left
		-- stanceBar = {position = "BOTTOM", padding = 1},
		petBar = {padding = 1},
		bars = {
			[1] = {buttons = 10, padding = 1},
			[2] = {buttons = 12, padding = 1},
			[3] = {buttons = 12, padding = 1},
			[4] = {buttons = 10, padding = 1},
			[5] = {buttons = 10, padding = 1},
		},
		moveBars = {
			stance = true,
			pet = true,
			eab = true,
		},
	},
}

-- Default Options
local defaults = {
	global = {
		tutorial = {
			stage = -1,
		},
		tags = {
			firsttime = true,
			retinaDisplay = {
				checked = false,
				set = false,
			},
			lowResOptimized = false,
			slashRealUITyped = false,	-- To disable "Type /realui" message
		},
		messages = {
			resetNew = false,
			largeHuDOption = false,
		},
		minipatches = {},
	},
	char = {
		layout = {
			current = 1,	-- 1 = DPS/Tank, 2 = Healing
			needchanged = false,
			spec = {1, 1},	-- Save layout for each spec
		},
		addonProfiles = {
			needSet = {
				DXE = true,
			},
		},
	},
	profile = {
		modules = {
			['*'] = true,
		},
		registeredChars = {},
		-- HuD positions
		positionsLink = true,
		positions = nibRealUI.defaultPositions,
		-- Action Bar settings
		abSettingsLink = false,
		actionBarSettings = nibRealUI.defaultActionBarSettings,
		-- Dynamic UI settings
		settings = {
			powerMode = 1,	-- 1 = Normal, 2 = Economy, 3 = Turbo
			fontStyle = 1,
			chatFontSize = 12,
			chatFontOutline = true,
			chatFontCustom = {
				enabled = false,
				font = "Arial Narrow",
			},
			infoLineBackground = true,
			stripeOpacity = 0.5,
			hudSize = 1,
		},
		-- Media
		media = {
			window = 		{0.03, 0.03, 0.03, 0.9},
			background = 	{0.085, 0.085, 0.085, 0.9},
			colors = {
				red = 		{0.85, 0.14, 0.14, 1},
				orange = 	{1.00, 0.38, 0.08, 1},
				amber =		{1.00, 0.64, 0.00, 1},
				yellow =	{1.00, 1.00, 0.15, 1},
				green = 	{0.13, 0.90, 0.13, 1},
				cyan = 		{0.11, 0.92, 0.72, 1},
				blue = 		{0.15, 0.61, 1.00, 1},
				purple = 	{0.70, 0.28, 1.00, 1},
			},
			textures = {
				plain =		[[Interface\AddOns\nibRealUI\Media\Plain.tga]],
				plain80 =	[[Interface\AddOns\nibRealUI\Media\Plain80.tga]],
				plain90 =	[[Interface\AddOns\nibRealUI\Media\Plain90.tga]],
				border =	[[Interface\AddOns\nibRealUI\Media\Plain.tga]],
			},
			font = nibRealUI.defaultFonts,
			icons = {
				DoubleArrow =	[[Interface\AddOns\nibRealUI\Media\Icons\DoubleArrow]],
				DoubleArrow2 =	[[Interface\AddOns\nibRealUI\Media\Icons\DoubleArrow2]],
				Lightning =		[[Interface\AddOns\nibRealUI\Media\Icons\Lightning]],
				Cross =			[[Interface\AddOns\nibRealUI\Media\Icons\Cross]],
				Flame =			[[Interface\AddOns\nibRealUI\Media\Icons\Flame]],
				Heart =			[[Interface\AddOns\nibRealUI\Media\Icons\Heart]],
				PersonPlus =	[[Interface\AddOns\nibRealUI\Media\Icons\PersonPlus]],
				Shield =		[[Interface\AddOns\nibRealUI\Media\Icons\Shield]],
				Sword =			[[Interface\AddOns\nibRealUI\Media\Icons\Sword]],
			},
		},
		-- Other
		other = {
			uiscaler = true,
		},
	},
}
--------------------------------------------------------

-- Toggle Grid2's "Test Layout"
function nibRealUI:ToggleGridTestMode(show)
	if show then
		if RealUIGridConfiguring then return end
		if not Grid2Options then Grid2:LoadGrid2Options() end
		Grid2Options.LayoutTestEnable(Grid2Options, "By Group 25")
		RealUIGridConfiguring = true
	else
		RealUIGridConfiguring = false
		if Grid2Options then
			Grid2Options.LayoutTestEnable(Grid2Options)
		end
	end
end

-- Move HuD Up if using a Low Resolution display
function nibRealUI:SetLowResOptimizations(...)
	local dbp, dp = db.positions, self.defaultPositions
	if (dbp[nibRealUI.cLayout]["HuDY"] == dp[nibRealUI.cLayout]["HuDY"]) then
		dbp[nibRealUI.cLayout]["HuDY"] = -5
	end
	if (dbp[nibRealUI.ncLayout]["HuDY"] == dp[nibRealUI.ncLayout]["HuDY"]) then
		dbp[nibRealUI.ncLayout]["HuDY"] = -5
	end

	nibRealUI:UpdateLayout()

	dbg.tags.lowResOptimized = true
end

function nibRealUI:LowResOptimizationCheck(...)
	local resWidth, resHeight = nibRealUI:GetResolutionVals()
	if (resHeight < 900) and not(dbg.tags.lowResOptimized) then
		nibRealUI:SetLowResOptimizations(...)
	end
end

-- Check if user is using a Retina Display
function nibRealUI:RetinaDisplayCheck()
	local resWidth, resHeight = nibRealUI:GetResolutionVals()
	if (resWidth > 2560) and (resHeight > 1600) then
		return true
	else
		dbg.tags.retinaDisplay.checked = true
		dbg.tags.retinaDisplay.set = false
		return false
	end
end

-- UI Scaler
local ScaleOptionsHidden
function nibRealUI:UpdateUIScale()
	if db.other.uiscaler and not nibRealUI.uiscalechanging then
		nibRealUI.uiscalechanging = true
		local scale = 768 / string.match(({GetScreenResolutions()})[GetCurrentResolution()], "%d+x(%d+)")
		if dbg.tags.retinaDisplay.set then scale = scale * 2 end
		if scale < .64 then
			UIParent:SetScale(scale)
		else
			SetCVar("uiScale", scale)
		end
		if not ScaleOptionsHidden then
			_G["Advanced_UseUIScale"]:Hide()
			_G["Advanced_UIScaleSlider"]:Hide()
			ScaleOptionsHidden = true
		end
		nibRealUI.uiscalechanging = false
	end
end

-- Power Mode
function nibRealUI:SetPowerMode(val)
	-- Core\SpiralBorder, HuD\UnitFrames, Modules\PlayerShields, Modules\RaidDebuffs, Modules\Pitch
	db.settings.powerMode = val
	for k, mod in self:IterateModules() do
		if self:GetModuleEnabled(k) and mod.SetUpdateSpeed and type(mod.SetUpdateSpeed) == "function" then
			mod:SetUpdateSpeed()
		end
	end	
end

---- Style Updates ----
function nibRealUI:StyleSetWindowOpacity()
	for k, frame in pairs(REALUI_WINDOW_FRAMES) do
		if frame.SetBackdropColor then
			frame:SetBackdropColor(unpack(nibRealUI.media.window))
		end
	end
end

function nibRealUI:StyleSetStripeOpacity()
	for k, tex in pairs(REALUI_STRIPE_TEXTURES) do
		if tex.SetAlpha then
			tex:SetAlpha(db.settings.stripeOpacity)
		end
	end
end

function nibRealUI:StyleSetInfoLineBackground(val)
	db.settings.infoLineBackground = val
	local InfoLine = nibRealUI:GetModule("InfoLine", true)
	if InfoLine then InfoLine:SetBackground() end
end

-- Style - Chat Font
function nibRealUI:StyleSetChatFont()
	local cfFont = not(db.settings.chatFontCustom.enabled) and nibRealUI.font.standard or nibRealUI:RetrieveFont(db.settings.chatFontCustom.font)

	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		local cfEditBox = _G["ChatFrame" .. i .. "EditBox"]

		cf:SetFont(						cfFont, db.settings.chatFontSize, db.settings.chatFontOutline and "OUTLINE")
		cfEditBox:SetFont(				cfFont, db.settings.chatFontSize, db.settings.chatFontOutline and "OUTLINE")
		cfEditBox.header:SetFont(		cfFont, db.settings.chatFontSize, db.settings.chatFontOutline and "OUTLINE")
		cfEditBox.headerSuffix:SetFont(	cfFont, db.settings.chatFontSize, db.settings.chatFontOutline and "OUTLINE")
	end
end

-- Style - UI Font
function nibRealUI:StyleSetFont(style)
	db.settings.fontStyle = style

	-- Update Fonts throughout nibRealUI modules
	for k, mod in self:IterateModules() do
		if self:GetModuleEnabled(k) and mod.UpdateFonts and type(mod.UpdateFonts) == "function" then
			mod:UpdateFonts()
		end
	end	

	-- Update Fonts that have been stored in global font arrays
	local fontTiny = 	nibRealUI:Font(false, "tiny")
	local fontSmall = 	nibRealUI:Font(false, "small")
	local fontRegular = nibRealUI:Font()
	local fontLarge = 	nibRealUI:Font(false, "large")

	for k, fontString in pairs(nibRealUI.fontStringsTiny) do
		fontString:SetFont(unpack(fontTiny))
	end
	for k, fontString in pairs(nibRealUI.fontStringsSmall) do
		fontString:SetFont(unpack(fontSmall))
	end
	for k, fontString in pairs(nibRealUI.fontStringsRegular) do
		fontString:SetFont(unpack(fontRegular))
	end
	for k, fontString in pairs(nibRealUI.fontStringsLarge) do
		fontString:SetFont(unpack(fontLarge))
	end

	-- Stance Bar position
	nibRealUI:GetModule("HuDConfig"):RegisterForUpdate("AB", "stance")

	-- Refresh Watch Frame
	if not WatchFrame.collapsed then
		WatchFrame_Collapse(WatchFrame)
		WatchFrame_Expand(WatchFrame)
	end
end

-- Style - Global Colors
function nibRealUI:StyleUpdateColors()
	for k, mod in self:IterateModules() do
		if self:GetModuleEnabled(k) and mod.UpdateGlobalColors and type(mod.UpdateGlobalColors) == "function" then
			mod:UpdateGlobalColors()
		end
	end	
end

-- Layout Updates
function nibRealUI:SetLayout()
	-- Set Current and Not-Current layout variables
	self.cLayout = dbc.layout.current
	self.ncLayout = self.cLayout == 1 and 2 or 1

	-- Set AddOn profiles
	self:SetProfileLayout()

	-- Set Positioners
	self:UpdatePositioners()

	-- HuD Config
	self:GetModule("ConfigBar_Positions"):UpdateHeader()
	self:GetModule("ConfigBar_ActionBars"):RefreshDisplay()
	self:GetModule("HuDConfig"):RegisterForUpdate("AB")
	self:GetModule("HuDConfig"):RegisterForUpdate("MSBT")
	self:GetModule("HuDConfig_Positions"):Refresh()

	if RealUIGridConfiguring then
		self:ScheduleTimer(function()
			self:ToggleGridTestMode(false)
			self:ToggleGridTestMode(true)
		end, 0.5)
	end
	
	-- ActionBarExtras
	if self:GetModuleEnabled("ActionBarExtras") then
		local ABE = self:GetModule("ActionBarExtras", true)
		if ABE then ABE:RefreshMod() end
	end
	
	-- Grid Layout changer
	if self:GetModuleEnabled("GridLayout") then
		local GL = self:GetModule("GridLayout", true)
		if GL then GL:Update() end
	end
	
	-- Layout Button (For Installation)
	if self:GetModuleEnabled("InfoLine") then
		local IL = self:GetModule("InfoLine", true)
		if IL then IL:Refresh() end
	end

	-- FrameMover
	if self:GetModuleEnabled("FrameMover") then
		local FM = self:GetModule("FrameMover", true)
		if FM then FM:MoveAddons() end
	end

	dbc.layout.needchanged = false
end
function nibRealUI:UpdateLayout()
	if InCombatLockdown() then
		-- Register to update once combat ends
		if not self.oocFunctions["SetLayout"] then
			self:RegisterLockdownUpdate("SetLayout", function() nibRealUI:SetLayout() end)
			dbc.layout.needchanged = true
		end
		self:Notification("RealUI", true, L["Layout will change after you leave combat."])
	else
		-- Set layout in 0.5 seconds
		self.oocFunctions["SetLayout"] = nil
		self:ScheduleTimer("SetLayout", 0.5)
	end
end

-- Lockdown check, out-of-combat updates
function nibRealUI:LockdownUpdates()
	if not InCombatLockdown() then
		local stillProcessing
		for k, fun in pairs(self.oocFunctions) do
			self.oocFunctions[k] = nil
			if type(fun) == "function" then
				fun()
				stillProcessing = true
				break
			end
		end
		if not stillProcessing then
			self:CancelTimer(self.lockdownTimer)
			self.lockdownTimer = nil
		end
	end
end
function nibRealUI:UpdateLockdown(...)
	if not self.lockdownTimer then self.lockdownTimer = self:ScheduleRepeatingTimer("LockdownUpdates", 0.5) end
end
function nibRealUI:RegisterLockdownUpdate(id, fun, ...)
	local retVal = ...
	if not InCombatLockdown() then
		self.oocFunctions[id] = nil
		fun(retVal)
	else
		self.oocFunctions[id] = function() fun(retVal) end
	end
end

-- Version info retrieval
function nibRealUI:GetVerString(returnLong)
	if returnLong then
		return string.format("|cFF"..nibRealUI:ColorTableToStr(nibRealUI.media.colors.orange).."%s|r.|cFF"..nibRealUI:ColorTableToStr(nibRealUI.media.colors.blue).."%s|r |cff"..nibRealUI:ColorTableToStr(nibRealUI.media.colors.green).."r%s|r", nibRealUI.verinfo[1], nibRealUI.verinfo[2], nibRealUI.verinfo[3])
	else
		return string.format("%s.%s", nibRealUI.verinfo[1], nibRealUI.verinfo[2])
	end
end
function nibRealUI:MajorVerChange(OldVer, CurVer)
	return ( (CurVer[1] > OldVer[1]) or (CurVer[2] > OldVer[2]) )
end

-- Events
function nibRealUI:VARIABLES_LOADED()
	self:UpdateUIScale()

	---- Blizzard Bug Fixes
	-- No Map emote
	hooksecurefunc("DoEmote", function(emote)
		if emote == "READ" and WorldMapFrame:IsShown() then
			CancelEmote()
		end
	end)

	-- -- Temp solution for Blizzard's 5.4.1 craziness
	-- UIParent:HookScript("OnEvent", function(self, event, a1, a2)
	-- 	if event:find("ACTION_FORBIDDEN") and ((a1 or "")..(a2 or "")):find("IsDisabledByParentalControls") then 
	-- 		StaticPopup_Hide(event)
	-- 	end
	-- end)

	-- Fix Regeant shift+clicking in TradeSkill window
	LoadAddOn("Blizzard_TradeSkillUI")
	local function TradeSkillReagent_OnClick(self)
		local link, name = GetTradeSkillReagentItemLink(TradeSkillFrame.selectedSkill, self:GetID())
		if not link then
			name, link = GameTooltip:GetItem()
			if name ~= self.name:GetText() then
				return
			end
		end
		HandleModifiedItemClick(link)
	end
	for i = 1, 8 do
		_G["TradeSkillReagent"..i]:SetScript("OnClick", TradeSkillReagent_OnClick)
	end
end

-- Delayed updates
function nibRealUI:UPDATE_PENDING_MAIL()
	self:UnregisterEvent("UPDATE_PENDING_MAIL")

	CancelEmote()	-- Cancel Map Holding animation
	
	-- Refresh WatchFrame lines and positioning
	if not WatchFrame.collapsed then
		WatchFrame_Collapse(WatchFrame)
		WatchFrame_Expand(WatchFrame)
	end

	-- Update chat font after Chatter sets it (PLAYER_ENTERING_WORLD)
	self:StyleSetChatFont()
end

local lastGarbageCollection = 0
function nibRealUI:PLAYER_ENTERING_WORLD()
	self:LockdownUpdates()

	-- >= 10 minute garbage collection
	self:ScheduleTimer(function() 
		local now = GetTime()
		if now >= lastGarbageCollection + 600 then
			collectgarbage("collect")
			lastGarbageCollection = now
		end
	end, 1)

	-- Position Chat Frame
	if nibRealUICharacter.needchatmoved then
		ChatFrame1:ClearAllPoints()
		ChatFrame1:SetPoint("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 6, 32)
		ChatFrame1:SetFrameLevel(15)
		ChatFrame1:SetHeight(145)
		ChatFrame1:SetWidth(400)
		ChatFrame1:SetUserPlaced(true)
		FCF_SavePositionAndDimensions(ChatFrame1)
		nibRealUICharacter.needchatmoved = false
	end
end

function nibRealUI:UI_SCALE_CHANGED()
	self:UpdateUIScale()
end

function nibRealUI:PLAYER_LOGIN()
	-- Retina Display check
	if not(dbg.tags.retinaDisplay.checked) and self:RetinaDisplayCheck() then
		self:InitRetinaDisplayOptions()
		return
	end
	
	-- Low Res optimization check
	if (nibRealUICharacter and nibRealUICharacter.installStage == -1) then
		self:LowResOptimizationCheck()
	end

	-- Tutorial
	if (nibRealUICharacter and nibRealUICharacter.installStage == -1) then
		if (dbg.tutorial.stage == 0) then
			self:InitTutorial()
		end
	end

	-- Check if Installation/Patch is necessary
	self:InstallProcedure()

	-- Do we need a Layout change?
	if dbc.layout.needchanged then
		nibRealUI:UpdateLayout()
	end

	-- Set AddOn Profiles for new DBs
	if (nibRealUICharacter.installStage == -1) and (dbg.tutorial.stage == -1) then
		-- DXE
		if dbc.addonProfiles.needSet.DXE then
			if IsAddOnLoaded("DXE_Loader") and not IsAddOnLoaded("DXE") then
				SlashCmdList.DXE()
			end
			if IsAddOnLoaded("DXE") and DXE then
				DXE.db:SetProfile("RealUI")
			end
			dbc.addonProfiles.needSet.DXE = false
		end
	end

	-- Helpful messages
	if (nibRealUICharacter.installStage == -1) and (dbg.tutorial.stage == -1) then
		if not(dbg.messages.resetNew) then
			if IsAddOnLoaded("cargBags_Nivaya") then
				hooksecurefunc(Nivaya, "OnShow", function()
					if RealUI.db.global.messages.resetNew then return end
					nibRealUI:Notification("Inventory", true, "Categorize New Items with the Reset New button.", nil, [[Interface\AddOns\cargBags_Nivaya\media\ResetNew_Large]], 0, 1, 0, 1)
					RealUI.db.global.messages.resetNew = true
				end)
			end
		end
		if not(dbg.messages.largeHuDOption) then
			local blue = nibRealUI:ColorTableToStr(nibRealUI.media.colors.blue)
			print("Using a hi-res display? Check out the new |cff"..blue.."Large HuD|r option found in the Positions config panel (|cFFFF8000/realui|r > Positions)")
		end
	end

	-- Update styling
	self:StyleSetStripeOpacity()
	self:StyleSetWindowOpacity()
	self:StyleSetChatFont()
end

-- To help position UI elements
function RealUI_TestRaidWarnings()
	self:ScheduleRepeatingTimer(function()
		RaidNotice_AddMessage(RaidWarningFrame, "This is a raid warning message!", { r = 0, g = 1, b = 0 })
		RaidNotice_AddMessage(RaidBossEmoteFrame, "This is a boss emote message!", { r = 0, g = 1, b = 0 })
	end, 5)
end

function nibRealUI:ADDON_LOADED(event, addon)
	if addon ~= "nibRealUI" then return end
	
	-- Open before login to stop taint
	ToggleFrame(SpellBookFrame)
	PetJournal_LoadUI()
end

function nibRealUI:ChatCommand_Config()
	dbg.tags.slashRealUITyped = true
	self:ShowConfigBar()
end

function nibRealUI:OnInitialize()
	-- Initialize settings, options, slash commands
	self.db = LibStub("AceDB-3.0"):New("nibRealUIDB", defaults, "RealUI")
	db = self.db.profile
	dbc = self.db.char
	dbg = self.db.global
	self.media = db.media
	
	-- Vars
	self.realm = GetRealmName()
	self.faction = UnitFactionGroup("player")
	self.class = select(2, UnitClass("player"))
	self.classColor = nibRealUI:GetClassColor(self.class)
	self.name = UnitName("player")
	self.key = string.format("%s - %s", self.name, self.realm)
	self.cLayout = dbc.layout.current
	self.ncLayout = self.cLayout == 1 and 2 or 1
	
	-- Profile change
	self.db.RegisterCallback(self, "OnProfileChanged", "Refresh")
	self.db.RegisterCallback(self, "OnProfileCopied", "Refresh")
	self.db.RegisterCallback(self, "OnProfileReset", "Refresh")
	
	-- Initial Options setup
	nibRealUI:SetUpInitialOptions()
	
	-- Register events
	self:RegisterEvent("ADDON_LOADED")
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("UI_SCALE_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLockdown")
	self:RegisterEvent("VARIABLES_LOADED")
	self:RegisterEvent("UPDATE_PENDING_MAIL")
	
	-- Chat Commands
	self:RegisterChatCommand("real", "ChatCommand_Config")
	self:RegisterChatCommand("realui", "ChatCommand_Config")
	self:RegisterChatCommand("realadv", function() nibRealUI:OpenOptions() end)
	self:RegisterChatCommand("memory", "MemoryDisplay")
	self:RegisterChatCommand("rl", function() ReloadUI() end)

	-- Synch user's settings
	if dbg.tags.firsttime then
		SetCVar("synchronizeSettings", 1)
		SetCVar("synchronizeConfig", 1)
		SetCVar("synchronizeBindings", 1)
		SetCVar("synchronizeMacros", 1)
	end

	-- Remove Interface Options cancel button because it = taint
	InterfaceOptionsFrameCancel:Hide()
	InterfaceOptionsFrameOkay:SetAllPoints(InterfaceOptionsFrameCancel)

	-- Make clicking cancel the same as clicking okay
	InterfaceOptionsFrameCancel:SetScript("OnClick", function()
		InterfaceOptionsFrameOkay:Click()
	end)
	
	-- Done
	print(format("RealUI %s loaded.", nibRealUI:GetVerString(true)))
	if not(dbg.tags.slashRealUITyped) and nibRealUICharacter and (nibRealUICharacter.installStage == -1) then
		print(string.format(L["Type /realui"], "|cFFFF8000/realui|r"))
	end
end

function nibRealUI:RegisterConfigModeModule(module)
	if module and module.ToggleConfigMode and type(module.ToggleConfigMode) == "function" then
		tinsert(self.configModeModules, module)
	end
end

function nibRealUI:GetModuleEnabled(module)
	return db.modules[module]
end

function nibRealUI:SetModuleEnabled(module, value)
	local old = db.modules[module]
	db.modules[module] = value
	if old ~= value then
		if value then
			self:EnableModule(module)
		else
			self:DisableModule(module)
		end
	end
end

function nibRealUI:Refresh()	
	-- db = self.db.profile
	-- dbc = self.db.char
	-- dbg = self.db.global
	-- self.media = db.media
	
	-- for key, val in self:IterateModules() do
	-- 	if self:GetModuleEnabled(key) and not val:IsEnabled() then
	-- 		self:EnableModule(key)
	-- 	elseif not self:GetModuleEnabled(key) and val:IsEnabled() then
	-- 		self:DisableModule(key)
	-- 	end
	-- 	if val.RefreshMod then
	-- 		if type(val.RefreshMod) == "function" and val:IsEnabled() then
	-- 			val:RefreshMod()
	-- 		end
	-- 	end
	-- end	
	-- nibRealUI:ConfigRefresh()
	nibRealUI:ReloadUIDialog()
end
