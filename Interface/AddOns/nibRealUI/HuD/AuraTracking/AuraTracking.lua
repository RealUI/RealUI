local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "AuraTracking"
local AuraTracking = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0", "AceTimer-3.0")

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Aura Tracking",
		desc = "Graphical display of important Buffs/Debuffs.",
		arg = MODNAME,
		childGroups = "tab",
		args = {
			header = {
				type = "header",
				name = "Aura Tracking",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Graphical display of important Buffs/Debuffs.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Aura Tracking module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
					nibRealUI:ReloadUIDialog()
				end,
				order = 30,
			},
		},
	}
	end
	return options
end

--------------------------
local modules = {}

local FontStringsCooldown = {}

local Indicators = {}
local numIndicators

local numStaticIndicators
local numFreeIndicators
local ActiveFreeIndicatorKeys = {}
local ActiveFreeIndicatorTimes = {}

local IndicatorParents = {}
local IndicatorSlots = {}

local SideActiveFree = {}
local StaticIndicatorsLeft = {}

local maxSlots = 24

-------------------
---- Functions ----
-------------------
local round = function(x) return floor(x + 0.5) end

local DAY, HOUR, MINUTE = 86400, 3600, 60 --used for formatting text
local DAYISH, HOURISH, MINUTEISH = 3600 * 23.5, 60 * 59.5, 59.5 --used for formatting text at transition points
function AuraTracking:GetTimeText(s)
	--format text as seconds when at 90 seconds or below
	if s < MINUTEISH then
		return round(s)
	--format text as minutes when below an hour
	elseif s < HOURISH then
		return round(s/MINUTE), "m"
	--format text as hours when below a day
	else
		return round(s/HOUR), "h"
	end
end

---------------------------
---- Raven Spell Lists ----
---------------------------
local RavenBuffSpellList = "PlayerExclusions"
local RavenDebuffSpellList = "TargetExclusions"
function AuraTracking:ResetRavenSpellLists()
	if IsAddOnLoaded("Raven") and RavenDB then
		if RavenDB["global"]["SpellLists"] then
			RavenDB["global"]["SpellLists"][RavenBuffSpellList] = {}
			RavenDB["global"]["SpellLists"][RavenDebuffSpellList] = {}
		end
	end
end

function AuraTracking:ToggleRavenAura(ignoreRaven, auraType, aura, val)
	local RavenSpellList = auraType == "buff" and RavenBuffSpellList or RavenDebuffSpellList
	if IsAddOnLoaded("Raven") and RavenDB then
		if RavenDB["global"]["SpellLists"][RavenSpellList] then
			RavenDB["global"]["SpellLists"][RavenSpellList][aura] = ignoreRaven and false or val
		end
	end
end


---------------------------
---- Indicator Updates ----
---------------------------
function AuraTracking:RemoveIndicatorFromSlot(frame, side, index)
	IndicatorSlots[side][index].key = nil
	frame:SetParent(nil)
	frame:ClearAllPoints()
	frame.slotSide = nil
	frame.slotIndex = nil
	frame:Hide()
end

function AuraTracking:AssignIndicatorToSlot(frame, key, side, index)
	IndicatorSlots[side][index].key = key
	frame:SetParent(IndicatorSlots[side][index])
	frame:ClearAllPoints()
	frame:SetAllPoints()
	frame.slotSide = side
	frame.slotIndex = index
end

function AuraTracking:StaticIndicatorUpdate(frame)
	-- Fade inactive
	if db.indicators.fadeInactive then
		if not(frame.isActive) then
			IndicatorSlots[frame.slotSide][frame.slotIndex]:SetAlpha(db.indicators.fadeOpacity)
		else
			IndicatorSlots[frame.slotSide][frame.slotIndex]:SetAlpha(1)
		end
	end
	
	-- Update Left indicator panel visibility
	self.SideActiveStatic.LEFT = false
	for k, indicator in pairs(StaticIndicatorsLeft) do
		if indicator.frame.isActive then
			self.SideActiveStatic.LEFT = true
		end
	end
	self:UpdateVisibility()
end

local SortIndicators = function(a, b)
	if a.endTime and b.endTime then
		return a.endTime < b.endTime
	elseif a then
		return true
	end
end

function AuraTracking:RegisterFreeIndicatorUpdate()
	if not self.freeIndicatorUpdateTimer then
		self.freeIndicatorUpdateTimer = self:ScheduleTimer("AssignFreeIndicators", 1/60)
	end
end

function AuraTracking:FreeIndicatorUpdate(frame, visible)
	if visible then
		if not ActiveFreeIndicatorKeys[frame.key] then
			-- Assign to Active Free Indicators
			ActiveFreeIndicatorKeys[frame.key] = true

			-- Set End Time
			tinsert(ActiveFreeIndicatorTimes, {key = frame.key, endTime = frame.auraEndTime})
		else
			-- Update End Time
			for i = 1, #ActiveFreeIndicatorTimes do
				if ActiveFreeIndicatorTimes[i].key == frame.key then
					ActiveFreeIndicatorTimes[i].endTime = frame.auraEndTime
				end
			end
		end
	else
		-- Remove from Active Free Indicators
		if ActiveFreeIndicatorKeys[frame.key] then
			ActiveFreeIndicatorKeys[frame.key] = nil
		end
		for k,v in pairs(ActiveFreeIndicatorTimes) do
			if not(ActiveFreeIndicatorKeys[v.key]) then
				tremove(ActiveFreeIndicatorTimes, k)
			end
		end
	end

	-- Sort by time left
	table.sort(ActiveFreeIndicatorTimes, SortIndicators)

	-- Refresh Slot assignments
	self:RegisterFreeIndicatorUpdate()
end

-- Assign Free Indicators to slots
function AuraTracking:AssignFreeIndicators()
	-- Un-assign inactive free indicators
	for k, indicator in pairs(Indicators) do
		if indicator.frame.slotIndex and not(indicator.frame.isStatic) and not(ActiveFreeIndicatorKeys[indicator.frame.key]) then
			self:RemoveIndicatorFromSlot(indicator.frame, indicator.frame.slotSide, indicator.frame.slotIndex)
		end
	end
	
	-- Re-assign any active free indicators that have moved position
	SideActiveFree = {LEFT = false, RIGHT = false}
	local key, info, side, curSlotIndex, newSlotIndex
	local curIndex = {LEFT = 0, RIGHT = 0}
	for k, v in ipairs(ActiveFreeIndicatorTimes) do
		key = v.key
		info = Indicators[key].info
		side = info.side or Indicators[key].frame.side
		curIndex[side] = curIndex[side] + 1
		newSlotIndex = curIndex[side] + numStaticIndicators[side]

		if not SideActiveFree[side] then
			SideActiveFree[side] = not(info.hideOOC) and true or false
		end

		if ActiveFreeIndicatorKeys[key] and (Indicators[key].frame.slotIndex ~= newSlotIndex) then
			self:AssignIndicatorToSlot(Indicators[key].frame, key, side, newSlotIndex)
		end
	end

	self:UpdateVisibility()
	self.freeIndicatorUpdateTimer = nil
end

-- Assign Static Indicators to slots and register into StaticIndicator tables
local SortStatic = function(a, b)
	if a.order ~= b.order then
		return a.order < b.order
	else
		return a.key < b.key
	end
end

function AuraTracking:AssignStaticIndicators()
	numStaticIndicators = {LEFT = 0, RIGHT = 0}
	wipe(StaticIndicatorsLeft)

	-- Create Static side tables
	local Static = {LEFT = {}, RIGHT = {}}
	for k, indicator in pairs(Indicators) do
		local info = indicator.info
		if info.order and (info.order > 0) and not(indicator.frame.inactive) then
			local side = info.side or indicator.frame.side

			tinsert(Static[side], {order = info.order, key = k})
		end
	end

	-- Sort Static side tables by order
	table.sort(Static.LEFT, SortStatic)
	table.sort(Static.RIGHT, SortStatic)

	-- Assign Static indicators to slots
	for side, _ in pairs(Static) do
		for k, v in ipairs(Static[side]) do
			local indicator = Indicators[v.key]
			numStaticIndicators[side] = numStaticIndicators[side] + 1
			self:AssignIndicatorToSlot(indicator.frame, v.key, side, numStaticIndicators[side])--info.order)
			if side == "LEFT" then
				tinsert(StaticIndicatorsLeft, indicator)
			end
		end
	end
end

-- Refresh all Indicator aura status
function AuraTracking:RefreshIndicatorStatus()
	for k, indicator in pairs(Indicators) do
		if indicator.AuraRefresh then
			indicator:AuraRefresh()
		end
	end
end

-- Un-assign then Re-assign all Indicators
function AuraTracking:RefreshIndicatorAssignments()
	for sI = 1, maxSlots do
		for side, _ in pairs(IndicatorSlots) do
			IndicatorSlots[side][sI]:SetAlpha(1)
		end
	end
	
	for k, indicator in pairs(Indicators) do
		local f = indicator.frame
		if f.slotIndex then
			self:RemoveIndicatorFromSlot(f, f.slotSide, f.slotIndex)
		end
	end
	self:AssignStaticIndicators()
	self:AssignFreeIndicators()
end


--------------------
---- Visibility ----
--------------------
function AuraTracking:UpdateVisibility()
	local targetCondition = db.visibility.showHostile and self.targetHostile
	local pvpCondition = db.visibility.showPvP and self.inPvP
	local pveCondition = db.visibility.showPvE and self.inPvE
	local combatCondition = (db.visibility.showCombat and self.inCombat) or not(db.visibility.showCombat)

	if self.configMode or targetCondition or pvpCondition or pveCondition or combatCondition then
		IndicatorParents.LEFT:Show()
		IndicatorParents.RIGHT:Show()
	else
		IndicatorParents.LEFT:SetShown(SideActiveFree.LEFT or self.SideActiveStatic.LEFT)
		IndicatorParents.RIGHT:Hide()
	end
end

function AuraTracking:UpdatePlayerLocation()
	local _, instanceType = GetInstanceInfo()
	if instanceType ~= "none" then
		self.inPvP = false
		self.inPvE = false
	elseif (instanceType == "pvp") or (instanceType == "arena") then
		self.inPvP = true
		self.inPvE = false
	elseif (instanceType == "party") or (instanceType == "raid") or (instanceType == "scenario") then
		self.inPvE = true
		self.inPvP = false
	end
	self:UpdateVisibility()
end

function AuraTracking:PLAYER_TARGET_CHANGED(skipUpdate)
	self.oldTargetHostile = self.targetHostile
	self.targetHostile = UnitExists("target") and (UnitIsEnemy("player", "target") or UnitCanAttack("player", "target")) and not(UnitIsDeadOrGhost("target"))
	if not(skipUpdate) and (self.oldTargetHostile ~= self.targetHostile) then
		self:UpdateVisibility()
	end
end

function AuraTracking:PLAYER_REGEN_DISABLED()
	self.inCombat = true
	self:UpdateVisibility()
end

function AuraTracking:PLAYER_REGEN_ENABLED()
	self.inCombat = false
	self:UpdateVisibility()
end

function AuraTracking:PLAYER_ENTERING_WORLD()
	self.playerGUID = UnitGUID("player")
	self:RefreshIndicatorStatus()
	self:PLAYER_TARGET_CHANGED(true)
	if UnitAffectingCombat("player") then
		self.inCombat = true
	else
		self.inCombat = false
	end
	self:ScheduleTimer("UpdatePlayerLocation", 1)
end


-----------------
---- Refresh ----
-----------------
-- Cooldown style changed
function AuraTracking:RefreshCooldownStyle()
	for k, indicator in pairs(Indicators) do
		indicator.frame.useCustomCD = db.indicators.useCustomCD
	end
end

-- Player Level or Spec changed
function AuraTracking:CharacterUpdate()
	-- Update Talent/Level information on Indicators
	for k, indicator in pairs(Indicators) do
		if indicator.TalentRefresh and indicator.frame.isStatic then
			indicator:TalentRefresh()
		end
		indicator:SetUpdates()
	end
	-- Re-assign all indicators
	self:RefreshIndicatorAssignments()
	-- Refresh Aura status of Indicators
	self:RefreshIndicatorStatus()
end

-- Create Indicators and register into Indicators table
function AuraTracking:CreateIndicator(index, info)
	Indicators[index] = modules[info.type or "Aura"]:New(info)
	Indicators[index]:SetUpdates()
	Indicators[index]:TalentRefresh()

	Indicators[index].info = info
	Indicators[index].key = index
	Indicators[index].frame.key = index

	numIndicators = numIndicators + 1
end

function AuraTracking:SetupIndicators()
	local curSpec = GetSpecialization()

	wipe(Indicators)
	numIndicators = 0
	if not db.tracking[nibRealUI.class] then return end
	for k, info in ipairs(db.tracking[nibRealUI.class]) do
		if not info.isDisabled then
			self:CreateIndicator(k, info)
		end
	end
end

function AuraTracking:UpdateStyle()
	for sI = 1, maxSlots do
		for side, _ in pairs(IndicatorSlots) do
			local slot = IndicatorSlots[side][sI]

			slot:SetSize(db.style.slotSize - 2, db.style.slotSize - 2)

			local point = side == "LEFT" and "BOTTOMRIGHT" or "BOTTOMLEFT"
			local rPoint = side == "LEFT" and "BOTTOMLEFT" or "BOTTOMRIGHT"
			local xMod = side == "LEFT" and -1 or 1

			slot:ClearAllPoints()
			if sI == 1 then
				slot:SetPoint(point, IndicatorParents[side], side, xMod, 0)
			else
				slot:SetPoint(point, IndicatorSlots[side][sI - 1], rPoint, (db.style.padding + 2) * xMod, 0)
			end
		end
	end
end

function AuraTracking:UpdateFonts()
	local fontCD = nibRealUI.font.pixelCooldown
	for k,fs in pairs(FontStringsCooldown) do
		fs:SetFont(unpack(fontCD))
	end
end

function AuraTracking:RegisterFont(type, fs)
	if tpye == "cooldown" then
		tinsert(FontStringsCooldown, fs)
	end
end

function AuraTracking:RefreshMod()
	self:SetupIndicators()
	self:RefreshIndicatorAssignments()
	self:RefreshIndicatorStatus()
	self:RefreshCooldownStyle()
	self:UpdateVisibility()
end

function AuraTracking:PLAYER_LOGIN()
	self:RefreshMod()
	self.loggedIn = true
end


----------------
---- Set Up ----
-----------------
-- Create slots that Indicators can be assigned to
function AuraTracking:CreateIndicatorSlots()
	IndicatorSlots = {LEFT = {}, RIGHT = {}}
	for sI = 1, maxSlots do
		for side, _ in pairs(IndicatorSlots) do
			local slot = CreateFrame("Frame", nil, IndicatorParents[side])
			IndicatorSlots[side][sI] = slot

			if sI <= 6 then
				slot.bg = nibRealUI:CreateBDFrame(slot)
				slot.bg:Hide()
			end
		end
	end

	self:UpdateStyle()
end

-- Create frames to anchor Slots to
function AuraTracking:CreateIndicatorParents()
	-- Parent Frames to anchor Slots from
	IndicatorParents.LEFT = CreateFrame("Frame", nil, UIParent)
	local ipLeft = IndicatorParents.LEFT
		ipLeft:SetPoint("BOTTOMRIGHT", RealUIPositionersCTAurasLeft, "BOTTOMLEFT", 0, 0)
		ipLeft:SetSize(2, 2)
		ipLeft:SetFrameStrata("MEDIUM")
		ipLeft:SetFrameLevel(1)

	IndicatorParents.RIGHT = CreateFrame("Frame", nil, UIParent)
	local ipRight = IndicatorParents.RIGHT
		ipRight:SetPoint("BOTTOMLEFT", RealUIPositionersCTAurasRight, "BOTTOMRIGHT", 0, 0)
		ipRight:SetSize(2, 2)
		ipRight:SetFrameStrata("MEDIUM")
		ipRight:SetFrameLevel(1)
end

function AuraTracking:UseCustomCooldown()
	return db.indicators.useCustomCD
end

--------------------------------
---- Config Panel Functions ----
--------------------------------
function AuraTracking:LoadDefaults()
	local defaults = nibRealUI.auraTrackingDefaults
	self.db:ResetProfile("RealUI")
end

function AuraTracking:CreateNewTracker()
	-- Insert new basic tracker
	local newTracker = {
		spell = "- Enter Spell Here -",
		minLevel = 90,
	}
	local newIndex = #db.tracking[nibRealUI.class] + 1
	tinsert(db.tracking[nibRealUI.class], newTracker)

	-- Create Indicator
	self:CreateIndicator(newIndex, newTracker)

	-- Refresh Indicators
	self:CharacterUpdate()

	-- Let Config know of new tracker's index
	return newIndex
end

function AuraTracking:EnableTracker(key)
	db.tracking[nibRealUI.class][key].isDisabled = false
end

function AuraTracking:DisableTracker(key)
	db.tracking[nibRealUI.class][key].isDisabled = true
end

function AuraTracking:ChangeTrackerSetting(index, key, value)
	db.tracking[nibRealUI.class][index][key] = value
	if Indicators[index].SetIndicatorInfo then
		Indicators[index]:SetIndicatorInfo(db.tracking[nibRealUI.class][index])
	end

	-- Refresh Indicators
	self:CharacterUpdate()
end

local SortTypes = function(a, b)
	if a == "Aura" then 
		return true
	elseif a and b then
		return a < b
	elseif a then
		return true
	end
end
function AuraTracking:GetTrackerTypes()
	local trackerTypes = {}
	for k,v in pairs(modules) do
		tinsert(trackerTypes, k)
	end
	table.sort(trackerTypes, SortTypes)
	return trackerTypes
end

function AuraTracking:GetTrackingData(index)
	if index then
		return db.tracking[nibRealUI.class][index]
	else
		return db.tracking[nibRealUI.class]
	end
end

function AuraTracking:GetSettings()
	return db
end

function AuraTracking:SetSetting(key1, key2, value)
	db[key1][key2] = value

	self:UpdateStyle()
	self:UpdateVisibility()
	self:RefreshIndicatorStatus()
	if (key1 == "indicators") and (key2 == "useCustomCD") then
		self:RefreshCooldownStyle()
	end
end

------------------------
---- Initialization ----
------------------------
function AuraTracking:ToggleConfigMode(val)
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if self.configMode == val then return end
	self.configMode = val

	for sI = 1, 6 do
		IndicatorSlots.LEFT[sI].bg:SetShown(val)
		IndicatorSlots.RIGHT[sI].bg:SetShown(val)
	end
	self:UpdateVisibility()
end

function AuraTracking:RegisterModule(module, type)
	modules[type] = module
end

function AuraTracking:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			style = {
				slotSize = 32,
				padding = 1,
			},
			visibility = {
				showCombat = true,
				showHostile = true,
				showPvE = false,
				showPvP = false,
			},
			indicators = {
				fadeInactive = true,
				fadeOpacity = 0.75,
				useCustomCD = true,
			},
			tracking = nibRealUI.auraTrackingDefaults,
		},
	})

	db = self.db.profile
	ndb = nibRealUI.db.profile

	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterHuDOptions(MODNAME, GetOptions)
	nibRealUI:RegisterConfigModeModule(self)

	self.SideActiveStatic = {LEFT = false, RIGHT = false}
	self:ResetRavenSpellLists()
end

function AuraTracking:OnEnable()
	self:RegisterEvent("PLAYER_LOGIN")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_ENTERING_WORLD")

	local CharUpdateEvents = {
		"ACTIVE_TALENT_GROUP_CHANGED",
		"PLAYER_SPECIALIZATION_CHANGED",
		"PLAYER_TALENT_UPDATE",
		"PLAYER_LEVEL_UP",

	}
	self:RegisterBucketEvent(CharUpdateEvents, 0.1, "CharacterUpdate")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "CharacterUpdate")
	
	if not IndicatorParents.LEFT then
		self:CreateIndicatorParents()
		self:CreateIndicatorSlots()
	end

	if self.loggedIn then self:RefreshMod() end

	self.configMode = false
end

function AuraTracking:OnDisable()
	
end