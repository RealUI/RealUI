local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)
local Auras = UnitFrames.Auras
local db, ndb, ndbc

local oUF = oUFembed

local _
local min = math.min
local max = math.max
local floor = _G.floor
local ceil = _G.ceil
local format = _G.format
local strform = _G.string.format
local tonumber = _G.tonumber
local tostring = _G.tostring
local strlen = _G.strlen
local strsub = _G.strsub

--------------------
------ Layout ------
--------------------
local layoutSize

-- Unit Frames Sizes
local unit_sizes = {
	[1] = {
		player = 		{width = 226, height = 24},
		pet = 			{width = 118, height = 10},
		focus = 		{width = 128, height = 10},
		focustarget = 	{width = 118, height = 10},
		target = 		{width = 226, height = 24},
		targettarget = 	{width = 128, height = 10},
		tank = 			{width = 158, height = 10},
		boss = 			{width = 135, height = 22},
	},
	[2] = {
		player = 		{width = 261, height = 26},
		pet = 			{width = 138, height = 10},
		focus = 		{width = 148, height = 10},
		focustarget = 	{width = 138, height = 10},
		target = 		{width = 261, height = 26},
		targettarget = 	{width = 148, height = 10},
		tank = 			{width = 158, height = 10},
		boss = 			{width = 135, height = 22},
	},
}

-- Mouse Event
local OnEnter = function(self)
	UnitFrame_OnEnter(self)
end

local OnLeave = function(self)
	UnitFrame_OnLeave(self)
end

-- Dropdown Menu
local dropdown = CreateFrame("Frame", "RealUIUnitFramesDropDown", UIParent, "UIDropDownMenuTemplate")

hooksecurefunc("UnitPopup_OnClick",function(self)
	local button = self.value
	if button == "SET_FOCUS" or button == "CLEAR_FOCUS" then
		if StaticPopup1 then
			StaticPopup1:Hide()
		end
		if db.misc.focusclick then
			nibRealUI:Notification("RealUI", true, "Use "..db.misc.focuskey.."+click to set Focus.", nil, [[Interface\AddOns\nibRealUI\Media\Icons\Notification_Alert]])
		end
	elseif button == "PET_DISMISS" then
		if StaticPopup1 then
			StaticPopup1:Hide()
		end
	end
end)

local function menu(self)
	dropdown:SetParent(self)
	return ToggleDropDownMenu(1, nil, dropdown, "cursor", 0, 0)
end

local init = function(self)
	local unit = self:GetParent().unit
	local menu, name, id
	
	if (not unit) then
		return
	end
	
	if (UnitIsUnit(unit, "player")) then
		menu = "SELF"
	elseif (UnitIsUnit(unit, "vehicle")) then
		menu = "VEHICLE"
	elseif (UnitIsUnit(unit, "pet")) then
		menu = "PET"
	elseif (UnitIsPlayer(unit)) then
		id = UnitInRaid(unit)
		if(id) then
			menu = "RAID_PLAYER"
			name = GetRaidRosterInfo(id)
		elseif(UnitInParty(unit)) then
			menu = "PARTY"
		else
			menu = "PLAYER"
		end
	else
		menu = "TARGET"
		name = RAID_TARGET_ICON
	end
	
	if (menu) then
		UnitPopup_ShowMenu(self, menu, unit, name, id)
	end
end

UIDropDownMenu_Initialize(dropdown, init, "MENU")
-- Frames
local function CreateBD(parent, alpha)
	local bg = CreateFrame("Frame", nil, parent)
		bg:SetFrameStrata("LOW")
		bg:SetFrameLevel(parent:GetFrameLevel() - 1)
		bg:SetPoint("BOTTOMRIGHT", parent, "BOTTOMRIGHT", 1, -1)
		bg:SetPoint("TOPLEFT", parent, "TOPLEFT", -1, 1)
		bg:SetBackdrop({bgFile = nibRealUI.media.textures.plain, edgeFile = nibRealUI.media.textures.plain, edgeSize = 1, insets = {top = 0, bottom = 0, left = 0, right = 0}})
		bg:SetBackdropColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], alpha or nibRealUI.media.background[4])
		bg:SetBackdropBorderColor(0, 0, 0, 1)
	return bg
end

local function Shared(self, unit)
	unit = unit:match("(boss)%d?$") or unit
	
	self.menu = menu
	
	self:SetScript("OnEnter", OnEnter)
	self:SetScript("OnLeave", OnLeave)
	self:RegisterForClicks"AnyUp"
	
  	if db.misc.focusclick then
		local ModKey = db.misc.focuskey
		local MouseButton = 1
		local key = ModKey .. "-type" .. (MouseButton or "")
		if(self.unit == "focus") then
			self:SetAttribute(key, "macro")
			self:SetAttribute("macrotext", "/clearfocus")
		else
			self:SetAttribute(key, "focus")
		end
	end
	
	-- Boss Frames
	if (unit == "boss") then
		local font = nibRealUI:Font()

		CreateBD(self, 0.7)

		local Health = CreateFrame("StatusBar", nil, self)
		self.Health = Health
			Health:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 3)
			Health:SetPoint("TOPRIGHT", self, "TOPRIGHT", 0, 0)
			Health:SetStatusBarTexture(nibRealUI.media.textures.plain)
			Health:SetStatusBarColor(unpack(db.overlay.colors.health.normal))
			Health.frequentUpdates = true
			if db.boss.reverseHealth then
				Health:SetReverseFill(true)
				Health.PostUpdate = function(Health, unit, min, max)
					Health:SetValue(max - Health:GetValue())
				end
			end
		
		local healthBG = CreateBD(Health, 0)
			healthBG:SetFrameStrata("LOW")
			
		local HealthValue = Health:CreateFontString(nil, "OVERLAY")
		self.HealthValue = HealthValue
			HealthValue:SetPoint("TOPLEFT", Health, "TOPLEFT", 2.5, -6.5)
			HealthValue:SetFont(unpack(font))
			HealthValue:SetJustifyH("LEFT")
		self:Tag(self.HealthValue, "[realui:healthPercent]")
		
		local Name = Health:CreateFontString(nil, "OVERLAY")
		self.Name = Name
			Name:SetPoint("TOPRIGHT", Health, "TOPRIGHT", -0.5, -6.5)
			Name:SetFont(unpack(font))
			Name:SetJustifyH("RIGHT")
		self:Tag(self.Name, "[realui:name]")
			
		local Power = CreateFrame("StatusBar", nil, self)
			self.Power = Power
			Power:SetFrameStrata("MEDIUM")
			Power:SetFrameLevel(6)
			Power:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 0)
			Power:SetPoint("TOPLEFT", self, "BOTTOMLEFT", 0, 2)
			Power:SetStatusBarTexture(nibRealUI.media.textures.plain)
			Power:SetStatusBarColor(db.overlay.colors.power["MANA"][1], db.overlay.colors.power["MANA"][2], db.overlay.colors.power["MANA"][3])
			Power.colorPower = true
			Power.PostUpdate = function(bar, unit, min, max)
				bar:SetShown(max > 0)
			end
		
		local powerBG = CreateBD(Power, 0)
			powerBG:SetFrameStrata("LOW")
			
		local AltPowerBar = CreateFrame("StatusBar", nil, self)
		self.AltPowerBar = AltPowerBar
			AltPowerBar:SetFrameStrata("MEDIUM")
			AltPowerBar:SetFrameLevel(6)
			AltPowerBar:SetPoint("BOTTOMRIGHT", self, "BOTTOMRIGHT", 0, 3)
			AltPowerBar:SetPoint("BOTTOMLEFT", self, "BOTTOMLEFT", 0, 5)
			AltPowerBar:SetStatusBarTexture(nibRealUI.media.textures.plain)
			-- AltPowerBar:SetStatusBarColor(db.overlay.colors.power["ALTERNATE"][1], db.overlay.colors.power["ALTERNATE"][2], db.overlay.colors.power["ALTERNATE"][3])
			AltPowerBar.colorPower = true
			-- AltPowerBar.PostUpdate = function(bar, unit, min, max)
			-- 	bar:SetShown(max > 0)
			-- end

		local altpowerBG = CreateBD(AltPowerBar, 0)
			altpowerBG:SetFrameStrata("LOW")
		
		local BossAuras = CreateFrame("Frame", nil, self)
		self.Auras = BossAuras
			BossAuras:SetPoint("BOTTOMRIGHT", self, "BOTTOMLEFT", (unit_sizes[layoutSize].boss.height) * ((db.boss.buffCount + db.boss.debuffCount) - 1) + 4, -1)
			BossAuras:SetWidth((unit_sizes[layoutSize].boss.height + 1) * (db.boss.buffCount + db.boss.debuffCount))
			BossAuras:SetHeight(unit_sizes[layoutSize].boss.height)
			BossAuras["size"] = unit_sizes[layoutSize].boss.height + 2
			BossAuras["spacing"] = 1
			BossAuras["numBuffs"] = db.boss.buffCount
			BossAuras["numDebuffs"] = db.boss.debuffCount
			BossAuras["growth-x"] = "LEFT"
			BossAuras.disableCooldown = true
			BossAuras.CustomFilter = Auras.FilterBossAuras
			BossAuras.PostUpdateIcon = Auras.PostUpdateIcon
			-- BossAuras.showType = true
			-- BossAuras.showStealableAuras = true

		local RaidIcon = self:CreateTexture(nil, 'OVERLAY')
		self.RaidIcon = RaidIcon
			RaidIcon:SetSize(unit_sizes[layoutSize].boss.height - 1, unit_sizes[layoutSize].boss.height - 1)
			RaidIcon:SetPoint("LEFT", self, "RIGHT", 1, 1)
	end
end

function UnitFrames:InitializeLayout()
	db = self.db.profile
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char

	layoutSize = ndb.settings.hudSize

	oUF:RegisterStyle("RealUI", Shared)
	
	local UnitSpecific = {
		player = function(self, ...)
			Shared(self, ...)
			self:SetSize(unit_sizes[layoutSize].player.width, unit_sizes[layoutSize].player.height)
		end,
		
		focus = function(self, ...)
			Shared(self, ...)
			self:SetSize(unit_sizes[layoutSize].focus.width, unit_sizes[layoutSize].focus.height)
		end,
		
		focustarget = function(self, ...)
			Shared(self, ...)
			self:SetSize(unit_sizes[layoutSize].focustarget.width, unit_sizes[layoutSize].focustarget.height)
		end,
		
		pet = function(self, ...)
			Shared(self, ...)
			self:SetSize(unit_sizes[layoutSize].pet.width, unit_sizes[layoutSize].pet.height)
		end,

		target = function(self, ...)
			Shared(self, ...)
			self:SetSize(unit_sizes[layoutSize].target.width, unit_sizes[layoutSize].target.height)
		end,
		
		targettarget = function(self, ...)
			Shared(self, ...)
			self:SetSize(unit_sizes[layoutSize].targettarget.width, unit_sizes[layoutSize].targettarget.height)
		end,
		
		boss = function(self, ...)
			Shared(self, ...)
			self:SetSize(unit_sizes[layoutSize].boss.width, unit_sizes[layoutSize].boss.height)
		end
	}

	for unit,layout in next, UnitSpecific do
		oUF:RegisterStyle("RealUI - " .. unit:gsub("^%l", string.upper), layout)
	end

	local function spawnHelper(self, unit, ...)
		if (UnitSpecific[unit]) then
			self:SetActiveStyle("RealUI - " .. unit:gsub("^%l", string.upper))
		elseif(UnitSpecific[unit:match("[^%d]+")]) then 
			self:SetActiveStyle("RealUI - " .. unit:match("[^%d]+"):gsub("^%l", string.upper))
		else
			self:SetActiveStyle("RealUI")
		end
		
		local object = self:Spawn(unit)
		object:SetPoint(...)
		return object
	end

	oUF:Factory(function(self)
		spawnHelper(self, "player", 		"RIGHT", 	"RealUIPositionersUnitFrames",	"LEFT",		db.positions[layoutSize].player.x, 			db.positions[layoutSize].player.y)
		spawnHelper(self, "focus", 			"RIGHT", 	"oUF_RealUIPlayer", 						db.positions[layoutSize].focus.x, 			db.positions[layoutSize].focus.y)
		spawnHelper(self, "focustarget", 	"RIGHT", 	"oUF_RealUIFocus", 							db.positions[layoutSize].focustarget.x, 	db.positions[layoutSize].focustarget.y)
		spawnHelper(self, "target", 		"LEFT", 	"RealUIPositionersUnitFrames",	"RIGHT",	db.positions[layoutSize].target.x, 			db.positions[layoutSize].target.y)
		spawnHelper(self, "targettarget", 	"LEFT", 	"oUF_RealUITarget", 						db.positions[layoutSize].targettarget.x, 	db.positions[layoutSize].targettarget.y)
		spawnHelper(self, "pet", 			"RIGHT", 	"oUF_RealUIPlayer", 						db.positions[layoutSize].pet.x, 			db.positions[layoutSize].pet.y)

		for b = 1, MAX_BOSS_FRAMES do
			local boss = spawnHelper(self, "boss"..b, "TOPRIGHT", "RealUIPositionersBossFrames", "TOPRIGHT", db.positions[layoutSize].boss.x, db.positions[layoutSize].boss.y)
			if (b ~= 1) then
				boss:SetPoint("TOP", _G["oUF_RealUIBoss" .. b - 1], "BOTTOM", 0, -db.boss.gap)
			end

			local blizzBF = _G["Boss" .. b .. "TargetFrame"]
			blizzBF:UnregisterAllEvents()
			blizzBF:Hide()
		end
	end)

	self:InitializeOverlay()
end

function RealUIUFBossConfig(toggle, unit)
	for b = 1, MAX_BOSS_FRAMES do
		local f = _G["oUF_RealUIBoss" .. b]
		if toggle then
			if not f.__realunit then
				f.__realunit = f:GetAttribute("unit") or f.unit
				f:SetAttribute("unit", unit)
				f.unit = unit
				f:Show()
			end
		else
			if f.__realunit then
				f:SetAttribute("unit", f.__realunit)
				f.unit = f.__realunit
				f.__realunit = nil
				f:Hide()
			end
		end
	end
end