local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "ClassResource_DemonicFury"
local DemonicFury = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0", "AceBucket-3.0")

local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")

local layoutSize

local Textures = {
	[1] = {
		bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Bar]],
		middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Middle]],
	},
	[2] = {
		bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Bar]],
		middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Middle]],
	},
}

local BarWidth = {
	[1] = 84,
	[2] = 114,
}

local FontStringsRegular = {}

local MetamorphosisSpellID = 103958
local MetamorphosisSpellName

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Demonic Fury",
		desc = "Warlock Demonic Fury tracker.",
		arg = MODNAME,
		childGroups = "tab",
		args = {
			header = {
				type = "header",
				name = "Demonic Fury",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Warlock Demonic Fury tracker.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Demonic Fury module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)
				end,
				order = 30,
			},
		},
	}
	end
	return options
end

------------------------------
---- Demonic Fury Updates ----
------------------------------
function DemonicFury:OnUpdate()
	-- Power Text
	local power = UnitPower("player", SPELL_POWER_DEMONIC_FURY)
	local maxPower = UnitPowerMax("player", SPELL_POWER_DEMONIC_FURY)
	
	if maxPower <= 0 or power > maxPower then
		return
	end

	local powerPer = power / maxPower
	
	if powerPer < 0.5 then
		AngleStatusBar:SetValue(self.dfBar.left.bar, powerPer * 2)
		AngleStatusBar:SetValue(self.dfBar.right.bar, 0)
	else
		AngleStatusBar:SetValue(self.dfBar.right.bar, (powerPer - 0.5) * 2)
		AngleStatusBar:SetValue(self.dfBar.left.bar, 1)
	end

	self.dfBar.power.text:SetText(abs(power))
end

function DemonicFury:UpdateShown(event, unit)
	if unit and unit ~= "player" then return end

	if self.configMode then
		self.dfBar:Show()
		return
	end

	if ( (GetSpecialization() == 2) and UnitExists("target") and UnitCanAttack("player", "target") and not(UnitIsDeadOrGhost("player")) and not(UnitIsDeadOrGhost("target")) and not(UnitInVehicle("player")) ) then
		self.dfBar:Show()
	else
		self.dfBar:Hide()
	end
end

function DemonicFury:UpdateAuras(units)
	if units and not(units.player) then return end

	-- Middle Arrow colors
	if UnitBuff("player", MetamorphosisSpellName) then
		self.dfBar.middle:SetVertexColor(unpack(nibRealUI.media.colors.orange))
	else
		self.dfBar.middle:SetVertexColor(unpack(nibRealUI.classColor))
	end
end

function DemonicFury:PLAYER_ENTERING_WORLD()
	self:UpdateShown()
	self:UpdateAuras()
end

-----------------------
---- Frame Updates ----
-----------------------
function DemonicFury:UpdateFonts()
	local font = nibRealUI:Font()
	for k, fontString in pairs(FontStringsRegular) do
		fontString:SetFont(unpack(font))
	end
end

function DemonicFury:UpdateGlobalColors()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if nibRealUI.class ~= "WARLOCK" then return end
	AngleStatusBar:SetBarColor(self.dfBar.left.bar, nibRealUI.media.colors.purple)
	AngleStatusBar:SetBarColor(self.dfBar.right.bar, nibRealUI.media.colors.purple)
	self:UpdateAuras()
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

function DemonicFury:CreateFrames()
	self.dfBar = CreateFrame("Frame", "RealUI_DemonicFury", RealUIPositionersClassResource)
	local dfBar = self.dfBar
		dfBar:SetSize((BarWidth[layoutSize] * 2) + 1, 6)
		dfBar:SetPoint("BOTTOM")
		-- dfBar:Hide()
	
	-- Lunar
	dfBar.left = CreateFrame("Frame", nil, dfBar)
		dfBar.left:SetPoint("BOTTOMRIGHT", dfBar, "BOTTOM", -1, 0)
		dfBar.left:SetSize(BarWidth[layoutSize], 6)

		dfBar.left.bg = dfBar.left:CreateTexture(nil, "ARTWORK")
			dfBar.left.bg:SetPoint("BOTTOMRIGHT")
			dfBar.left.bg:SetSize(128, 16)
			dfBar.left.bg:SetTexture(Textures[layoutSize].bar)
			dfBar.left.bg:SetVertexColor(unpack(nibRealUI.media.background))

		dfBar.left.bar = AngleStatusBar:NewBar(dfBar.left, 2, -1, BarWidth[layoutSize] - 7, 4, "RIGHT", "RIGHT", "RIGHT")
			dfBar.left.bar.reverse = true
	
	-- Solar
	dfBar.right = CreateFrame("Frame", nil, dfBar)
		dfBar.right:SetPoint("BOTTOMLEFT", dfBar, "BOTTOM", 0, 0)
		dfBar.right:SetSize(BarWidth[layoutSize], 6)

		dfBar.right.bg = dfBar.right:CreateTexture(nil, "ARTWORK")
			dfBar.right.bg:SetPoint("BOTTOMLEFT")
			dfBar.right.bg:SetSize(128, 16)
			dfBar.right.bg:SetTexture(Textures[layoutSize].bar)
			dfBar.right.bg:SetTexCoord(1, 0, 0, 1)
			dfBar.right.bg:SetVertexColor(unpack(nibRealUI.media.background))

		dfBar.right.bar = AngleStatusBar:NewBar(dfBar.right, 5, -1, BarWidth[layoutSize] - 7, 4, "LEFT", "LEFT", "RIGHT")
			dfBar.right.bar.reverse = true

	-- Middle
	dfBar.middle = dfBar:CreateTexture(nil, "ARTWORK")
		dfBar.middle:SetPoint("BOTTOM")
		dfBar.middle:SetSize(16, 16)
		dfBar.middle:SetTexture(Textures[layoutSize].middle)

	-- Power text
	dfBar.power = CreateTextFrame(dfBar)
		dfBar.power:SetPoint("BOTTOM", dfBar, "TOP", 0, 3)
end

------------
function DemonicFury:ToggleConfigMode(val)
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if nibRealUI.class ~= "WARLOCK" then return end
	if self.configMode == val then return end

	self.configMode = val
	self:UpdateShown()
end

function DemonicFury:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {},
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile

	layoutSize = ndb.settings.hudSize
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterHuDOptions(MODNAME, GetOptions, "ClassResource")
	nibRealUI:RegisterConfigModeModule(self)
end

function DemonicFury:OnEnable()
	if nibRealUI.class ~= "WARLOCK" then return end

	self.configMode = false

	MetamorphosisSpellName = GetSpellInfo(MetamorphosisSpellID)

	if not self.dfBar then self:CreateFrames() end
	self:UpdateFonts()
	self:UpdateGlobalColors()

	local updateSpeed
	if nibRealUI.db.profile.settings.powerMode == 1 then
		updateSpeed = 1/6
	elseif nibRealUI.db.profile.settings.powerMode == 2 then
		updateSpeed = 1/4
	else
		updateSpeed = 1/8
	end

	-- Events
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("PLAYER_TALENT_UPDATE", "UpdateShown")
	self:RegisterEvent("PLAYER_TARGET_CHANGED", "UpdateShown")
	self:RegisterEvent("PLAYER_UNGHOST", "UpdateShown")
	self:RegisterEvent("PLAYER_ALIVE", "UpdateShown")
	self:RegisterEvent("PLAYER_DEAD", "UpdateShown")
	self:RegisterBucketEvent("UNIT_AURA", updateSpeed, "UpdateAuras")

	self.updateTimer = self:ScheduleRepeatingTimer("OnUpdate", updateSpeed)
end

function DemonicFury:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllBuckets()
	if self.updateTimer then self:CancelTimer(self.updateTimer) end
end