local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "ClassResource_EclipseBar"
local EclipseBar = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")

local layoutSize

local Textures = {
	[1] = {
		bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Bar]],
		endBox = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_End]],
		middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Middle]],
	},
	[2] = {
		bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Bar]],
		endBox = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_End]],
		middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Middle]],
	},
}

local BarWidth = {
	[1] = 84,
	[2] = 114,
}

local FontStringsRegular = {}

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Eclipse Bar",
		desc = "Balance (Druid) Eclipse tracker.",
		arg = MODNAME,
		childGroups = "tab",
		args = {
			header = {
				type = "header",
				name = "Eclipse Bar",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Balance (Druid) Eclipse tracker.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Eclipse Bar module.",
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
			visibility = {
				name = "Visibility",
				type = "group",
				inline = true,
				order = 40,
				args = {
					showCombat = {
						type = "toggle",
						name = "Only In combat",
						desc = "Only show the Eclipse Bar when you are in combat.",
						get = function() return db.visibility.showCombat end,
						set = function(info, value) 
							db.visibility.showCombat = value
							EclipseBar:UpdateVisibility()
						end,
						order = 10,
					},
					showHostile = {
						type = "toggle",
						name = "Attackable target",
						desc = "Show the Eclipse Bar when you have a target selected that you can attack.",
						get = function() return db.visibility.showHostile end,
						set = function(info, value) 
							db.visibility.showHostile = value
							EclipseBar:UpdateVisibility()
						end,
						order = 20,
					},
					showPvP = {
						type = "toggle",
						name = "In PvP",
						desc = "Always show the Eclipse Bar when you are in an Arena or Battleground.",
						get = function() return db.visibility.showPvP end,
						set = function(info, value) 
							db.visibility.showPvP = value
							EclipseBar:UpdateVisibility()
						end,
						order = 30,
					},
					showPvE = {
						type = "toggle",
						name = "In PvE",
						desc = "Always show the Eclipse Bar when you are in a Scenario, Dungeon or Raid.",
						get = function() return db.visibility.showPvE end,
						set = function(info, value) 
							db.visibility.showPvE = value
							EclipseBar:UpdateVisibility()
						end,
						order = 40,
					},
				},
			},
		},
	}
	end
	return options
end

-------------------------
---- Eclipse Updates ----
-------------------------
local retval = {}
local spellIDs = {
	[ECLIPSE_BAR_SOLAR_BUFF_ID] = 1,
	[ECLIPSE_BAR_LUNAR_BUFF_ID] = 2,
}
local function HasEclipseBuffs()
	retval[1] = false
	retval[2] = false

	local i = 1
	local name, _, texture, applications, _, _, _, _, _, _, auraID = UnitAura("player", i)
	while name do
		if spellIDs[auraID] then
			retval[spellIDs[auraID]] = applications == 0 and true or applications
			break
		end

		i = i + 1
		name, _, texture, applications, _, _, _, _, _, _, auraID = UnitAura("player", i)
	end

	return retval
end

function EclipseBar:OnUpdate()
	-- Power Text
	local power = UnitPower("player", SPELL_POWER_ECLIPSE)
	local maxPower = UnitPowerMax("player", SPELL_POWER_ECLIPSE)
	
	if maxPower <= 0 or power > maxPower then
		return
	end

	local powerPer = 0
	if self.direction == "sun" then
		powerPer = (power + 100) / (maxPower + 100)
		powerPer = nibRealUI:Clamp(powerPer, 0, 1)

		if powerPer <= 0.5 then
			-- Lunar side
			AngleStatusBar:SetValue(self.eBar.lunar.bar, powerPer * 2)
			AngleStatusBar:SetValue(self.eBar.solar.bar, 0)
		else
			-- Solar side
			AngleStatusBar:SetValue(self.eBar.solar.bar, (powerPer - 0.5) * 2)
			AngleStatusBar:SetValue(self.eBar.lunar.bar, 1)
		end

	elseif self.direction == "moon" then
		powerPer = 1 - ((power + 100) / (maxPower + 100))
		powerPer = nibRealUI:Clamp(powerPer, 0, 1)

		if powerPer > 0.5 then
			-- Lunar side
			AngleStatusBar:SetValue(self.eBar.lunar.bar, (powerPer - 0.5) * 2)
			AngleStatusBar:SetValue(self.eBar.solar.bar, 1)
		else
			-- Solar side
			AngleStatusBar:SetValue(self.eBar.solar.bar, powerPer * 2)
			AngleStatusBar:SetValue(self.eBar.lunar.bar, 0)
		end

	else
		powerPer = ((power + 100) / (maxPower + 100))

		if powerPer <= 0.5 then
			-- Lunar side
			AngleStatusBar:SetValue(self.eBar.lunar.bar, 1- (powerPer * 2))
			AngleStatusBar:SetValue(self.eBar.solar.bar, 0)
		else
			-- Solar side
			AngleStatusBar:SetValue(self.eBar.solar.bar, (powerPer - 0.5) * 2)
			AngleStatusBar:SetValue(self.eBar.lunar.bar, 0)
		end
	end

	self.eBar.power.text:SetText(abs(power))
end

function EclipseBar:UpdateAuras(units)
	if units and not(units.player) then return end

	local buffStatus = HasEclipseBuffs()
	local hasSolar = buffStatus[1]
	local hasLunar = buffStatus[2]

	-- Middle Arrow colors
	if hasSolar then
		self.eBar.middle:SetVertexColor(unpack(nibRealUI.media.colors.orange))

	elseif hasLunar then
		self.eBar.middle:SetVertexColor(unpack(nibRealUI.media.colors.blue))

	else
		self.eBar.middle:SetVertexColor(0.2, 0.2, 0.2, 1)
	end
end

function EclipseBar:ECLIPSE_DIRECTION_CHANGE()
	self.direction = GetEclipseDirection()

	-- End Box colors and Bar colors
	if self.direction == "sun" then
		self.eBar.solar.endBox:SetVertexColor(unpack(nibRealUI.media.colors.orange))
		self.eBar.lunar.endBox:SetVertexColor(unpack(nibRealUI.media.background))
		AngleStatusBar:SetBarColor(self.eBar.lunar.bar, nibRealUI.media.colors.blue)
		AngleStatusBar:SetBarColor(self.eBar.solar.bar, nibRealUI.media.colors.blue)
		self:ReverseBar("lunar", true)
		self:ReverseBar("solar", false)

	elseif self.direction == "moon" then
		self.eBar.solar.endBox:SetVertexColor(unpack(nibRealUI.media.background))
		self.eBar.lunar.endBox:SetVertexColor(unpack(nibRealUI.media.colors.blue))
		AngleStatusBar:SetBarColor(self.eBar.lunar.bar, nibRealUI.media.colors.orange)
		AngleStatusBar:SetBarColor(self.eBar.solar.bar, nibRealUI.media.colors.orange)
		self:ReverseBar("lunar", false)
		self:ReverseBar("solar", true)

	else
		self.eBar.solar.endBox:SetVertexColor(unpack(nibRealUI.media.colors.orange))
		self.eBar.lunar.endBox:SetVertexColor(unpack(nibRealUI.media.colors.blue))
		AngleStatusBar:SetBarColor(self.eBar.lunar.bar, {0.75, 0.75, 0.75, 1})
		AngleStatusBar:SetBarColor(self.eBar.solar.bar, {0.75, 0.75, 0.75, 1})
		self:ReverseBar("lunar", false)
		self:ReverseBar("solar", false)

	end
end

function EclipseBar:ReverseBar(side, reverse)
	if side == "lunar" then
		if reverse then
			AngleStatusBar:SetReverseDirection(self.eBar.lunar.bar, true, 2, -1)
		else
			AngleStatusBar:SetReverseDirection(self.eBar.lunar.bar, false, 5, -1)
		end
	else
		if reverse then
			AngleStatusBar:SetReverseDirection(self.eBar.solar.bar, true, -2, -1)
		else
			AngleStatusBar:SetReverseDirection(self.eBar.solar.bar, false, 5, -1)
		end
	end
end

--------------------
---- Visibility ----
--------------------
function EclipseBar:UpdateVisibility(event, unit)
	if unit and unit ~= "player" then return end

	if self.configMode then
		self.eBar:Show()
		return
	end

	local targetCondition = (UnitExists("target") and not(UnitIsDeadOrGhost("target"))) and (db.visibility.showHostile and (UnitIsEnemy("player", "target") or UnitCanAttack("player", "target")))
	local pvpCondition = db.visibility.showPvP and self.inPvP
	local pveCondition = db.visibility.showPvE and self.inPvE
	local combatCondition = (db.visibility.showCombat and self.inCombat) or not(db.visibility.showCombat)

	local form = GetShapeshiftFormID()
	if ((not(form) or (form and (form == MOONKIN_FORM))) and (GetSpecialization() == 1) and not(UnitInVehicle("player")) and not(UnitIsDeadOrGhost("player"))) and 
		(targetCondition or combatCondition or pvpCondition or pveCondition) then
			self.eBar:Show()
	else
		self.eBar:Hide()
	end
end

function EclipseBar:PLAYER_REGEN_DISABLED()
	self.inCombat = true
	self:UpdateVisibility()
end

function EclipseBar:PLAYER_REGEN_ENABLED()
	self.inCombat = false
	self:UpdateVisibility()
end

function EclipseBar:UpdatePlayerLocation()
	local Inst, InstType = IsInInstance()
	if not(Inst and InstType) then
		self.inPvP = false
		self.inPvE = false
	elseif (InstType == "pvp") or (InstType == "arena") then
		self.inPvP = true
		self.inPvE = false
	elseif (InstType == "party") or (InstType == "raid") then
		self.inPvE = true
		self.inPvP = false
	end
end

function EclipseBar:PLAYER_ENTERING_WORLD()
	self:UpdatePlayerLocation()
	self:UpdateVisibility()
	self:UpdateAuras()
	self:ECLIPSE_DIRECTION_CHANGE()
end

-----------------------
---- Frame Updates ----
-----------------------
function EclipseBar:UpdateFonts()
	local font = nibRealUI:Font()
	for k, fontString in pairs(FontStringsRegular) do
		fontString:SetFont(unpack(font))
	end
end

function EclipseBar:UpdateGlobalColors()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if nibRealUI.class ~= "DRUID" then return end
	self:ECLIPSE_DIRECTION_CHANGE()
end

local function CreateTextFrame(parent, size)
	local NewTextFrame = CreateFrame("Frame", nil, parent)
	NewTextFrame:SetSize(12, 12)

	NewTextFrame.text = NewTextFrame:CreateFontString(nil, "ARTWORK")
	NewTextFrame.text:SetFont(unpack(nibRealUI:Font()))
	NewTextFrame.text:SetPoint("BOTTOM", NewTextFrame, "BOTTOM", 0.5, 0.5)
	tinsert(FontStringsRegular, NewTextFrame.text)
	
	return NewTextFrame
end

function EclipseBar:CreateFrames()
	self.eBar = CreateFrame("Frame", "RealUI_EclipseBar", RealUIPositionersClassResource)
	local eBar = self.eBar
		eBar:SetSize((BarWidth[layoutSize] * 2) + 1, 6)
		eBar:SetPoint("BOTTOM")
		-- eBar:Hide()
	
	-- Lunar
	eBar.lunar = CreateFrame("Frame", nil, eBar)
		eBar.lunar:SetPoint("BOTTOMRIGHT", eBar, "BOTTOM", -1, 0)
		eBar.lunar:SetSize(BarWidth[layoutSize], 6)

		eBar.lunar.bg = eBar.lunar:CreateTexture(nil, "ARTWORK")
			eBar.lunar.bg:SetPoint("BOTTOMRIGHT")
			eBar.lunar.bg:SetSize(128, 16)
			eBar.lunar.bg:SetTexture(Textures[layoutSize].bar)
			eBar.lunar.bg:SetVertexColor(unpack(nibRealUI.media.background))

		eBar.lunar.endBox = eBar.lunar:CreateTexture(nil, "ARTWORK")
			eBar.lunar.endBox:SetPoint("BOTTOMRIGHT", eBar.lunar, "BOTTOMLEFT", 4, 0)
			eBar.lunar.endBox:SetSize(16, 16)
			eBar.lunar.endBox:SetTexture(Textures[layoutSize].endBox)
			eBar.lunar.endBox:SetVertexColor(unpack(nibRealUI.media.colors.blue))

		eBar.lunar.bar = AngleStatusBar:NewBar(eBar.lunar, -5, -1, BarWidth[layoutSize] - 7, 4, "RIGHT", "RIGHT", "LEFT")
			eBar.lunar.bar.reverse = true
	
	-- Solar
	eBar.solar = CreateFrame("Frame", nil, eBar)
		eBar.solar:SetPoint("BOTTOMLEFT", eBar, "BOTTOM", 0, 0)
		eBar.solar:SetSize(BarWidth[layoutSize], 6)

		eBar.solar.bg = eBar.solar:CreateTexture(nil, "ARTWORK")
			eBar.solar.bg:SetPoint("BOTTOMLEFT")
			eBar.solar.bg:SetSize(128, 16)
			eBar.solar.bg:SetTexture(Textures[layoutSize].bar)
			eBar.solar.bg:SetTexCoord(1, 0, 0, 1)
			eBar.solar.bg:SetVertexColor(unpack(nibRealUI.media.background))

		eBar.solar.endBox = eBar.solar:CreateTexture(nil, "ARTWORK")
			eBar.solar.endBox:SetPoint("BOTTOMLEFT", eBar.solar, "BOTTOMRIGHT", -4, 0)
			eBar.solar.endBox:SetSize(16, 16)
			eBar.solar.endBox:SetTexture(Textures[layoutSize].endBox)
			eBar.solar.endBox:SetTexCoord(1, 0, 0, 1)
			eBar.solar.endBox:SetVertexColor(unpack(nibRealUI.media.colors.orange))

		eBar.solar.bar = AngleStatusBar:NewBar(eBar.solar, 5, -1, BarWidth[layoutSize] - 7, 4, "LEFT", "LEFT", "RIGHT")
			eBar.solar.bar.reverse = true

	-- Middle
	eBar.middle = eBar:CreateTexture(nil, "ARTWORK")
		eBar.middle:SetPoint("BOTTOM")
		eBar.middle:SetSize(16, 16)
		eBar.middle:SetTexture(Textures[layoutSize].middle)

	-- Power text
	eBar.power = CreateTextFrame(eBar)
		eBar.power:SetPoint("BOTTOM", eBar, "TOP", 0, 3)
end

------------
function EclipseBar:ToggleConfigMode(val)
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if nibRealUI.class ~= "DRUID" then return end
	if self.configMode == val then return end

	self.configMode = val
	self:UpdateVisibility()
end

function EclipseBar:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			visibility = {
				showCombat = true,
				showHostile = true,
				showPvP = true,
				showPvE = false,
			},
		},
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile

	layoutSize = ndb.settings.hudSize
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterHuDOptions(MODNAME, GetOptions, "ClassResource")
	nibRealUI:RegisterConfigModeModule(self)
end

function EclipseBar:OnEnable()
	if nibRealUI.class ~= "DRUID" then return end

	self.configMode = false

	if not self.eBar then self:CreateFrames() end
	self:UpdateFonts()

	local updateSpeed
	if nibRealUI.db.profile.settings.powerMode == 1 then
		updateSpeed = 1/8
	elseif nibRealUI.db.profile.settings.powerMode == 2 then
		updateSpeed = 1/5
	else
		updateSpeed = 1/10
	end

	-- Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("UPDATE_SHAPESHIFT_FORM", "UpdateVisibility")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateVisibility")
	self:RegisterEvent("MASTERY_UPDATE", "UpdateVisibility")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateVisibility")
	self:RegisterEvent("PLAYER_UNGHOST", "UpdateVisibility")
	self:RegisterEvent("PLAYER_ALIVE", "UpdateVisibility")
	self:RegisterEvent("PLAYER_DEAD", "UpdateVisibility")
	self:RegisterEvent("PLAYER_REGEN_DISABLED")
	self:RegisterEvent("PLAYER_REGEN_ENABLED")
	self:RegisterBucketEvent("UNIT_AURA", updateSpeed, "UpdateAuras")
	self:RegisterEvent("ECLIPSE_DIRECTION_CHANGE")

	self.updateTimer = self:ScheduleRepeatingTimer("OnUpdate", updateSpeed)
end

function EclipseBar:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllBuckets()
	if self.updateTimer then self:CancelTimer(self.updateTimer) end
end