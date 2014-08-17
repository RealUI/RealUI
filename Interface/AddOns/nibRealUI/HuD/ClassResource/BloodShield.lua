local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "ClassResource_BloodShield"
local BloodShield = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")
local Resolve = nibRealUI:GetModule("ClassResource_Resolve")

local layoutSize

local Textures = {
	[1] = {
		bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Bar_Long]],
		endBox = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_End]],
		middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\1\Small_Middle]],
	},
	[2] = {
		bar = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Bar_Long]],
		endBox = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_End]],
		middle = [[Interface\AddOns\nibRealUI\Media\StatusBars\2\Small_Middle]],
	},
}

local BarWidth = {
	[1] = 118,
	[2] = 128,
}

local FontStringsRegular = {}
local BloodShieldID = 77535
local BloodShieldName
local MinLevel = 10
local maxHealth

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Blood Shield",
		desc = "Deathknight Blood Shield tracker (+ Resolve).",
		arg = MODNAME,
		childGroups = "tab",
		args = {
			header = {
				type = "header",
				name = "Blood Shield",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Deathknight Blood Shield tracker (+ Resolve).",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Blood Shield module.",
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

-----------------
---- Updates ----
-----------------
function BloodShield:UpdateAuras(event, units)
	if units and not(units.player) then return end

	-- Blood Shield
	local spellName,_,_,_,_,_,endTime,_,_,_,spellID,_,_,_, absorb = UnitAura("player", BloodShieldName)
	if ( spellID == BloodShieldID ) then 
		self.curBloodAbsorb = absorb
	else
		self.curBloodAbsorb = 0
	end

	local bloodPer = nibRealUI:Clamp(self.curBloodAbsorb / self.maxBlood, 0, 1)
	AngleStatusBar:SetValue(self.bsBar.bShield.bar, bloodPer)
	self.bsBar.bShield.value:SetText(nibRealUI:ReadableNumber(self.curBloodAbsorb, 0))

	if bloodPer > 0 then
		self.bsBar.bShield.endBox:SetVertexColor(unpack(nibRealUI.media.colors.red))
	else
		self.bsBar.bShield.endBox:SetVertexColor(unpack(nibRealUI.media.background))
	end

	-- Resolve
	if event ~= "CLEU" then
		Resolve:UpdateCurrent()

		AngleStatusBar:SetValue(self.bsBar.resolve.bar, Resolve.percent)
		self.bsBar.resolve.value:SetText(nibRealUI:ReadableNumber(Resolve.current, 0))
		if Resolve.percent > 0 then
			self.bsBar.resolve.endBox:SetVertexColor(unpack(nibRealUI.media.colors.orange))
		else
			self.bsBar.resolve.endBox:SetVertexColor(unpack(nibRealUI.media.background))
		end
	end

	-- Update visibility
	if (((self.curBloodAbsorb > 0) or (Resolve.current > Resolve.base)) and not(self.bsBar:IsShown())) or
		(((self.curBloodAbsorb <= 0) or (Resolve.current <= Resolve.base)) and self.bsBar:IsShown()) then
			self:UpdateShown()
	end
end

function BloodShield:CLEU(event, ...)
	local _, cEvent, _,_,_,_,_, destGUID, _,_,_, spellID = ...

	if ( (destGUID == self.guid) and (cEvent == "SPELL_AURA_REMOVED") and (spellID == BloodShieldID) ) then
		self:UpdateAuras("CLEU")
	end
end

function BloodShield:UpdateMax(event, unit)
	if (unit and (unit ~= "player")) then
		return
	end
	
	self.maxBlood = UnitHealthMax("player")
	Resolve:UpdateBase()
	self:UpdateAuras()
end

function BloodShield:UpdateShown(event, unit)
	if unit and unit ~= "player" then return end

	if self.configMode then
		self.bsBar:Show()
		return
	end

	if ( (GetSpecialization() == 1) and ((Resolve.current and (Resolve.current > Resolve.base)) or (self.curBloodAbsorb and (self.curBloodAbsorb > 0))) and not(UnitIsDeadOrGhost("player")) and (UnitLevel("player") >= MinLevel) ) then
		self.bsBar:Show()
	else
		self.bsBar:Hide()
	end
end

function BloodShield:PLAYER_ENTERING_WORLD()
	self.guid = UnitGUID("player")
	self:UpdateAuras()
	self:UpdateShown()
end

-----------------------
---- Frame Updates ----
-----------------------
function BloodShield:UpdateFonts()
	local font = nibRealUI:Font()
	for k, fontString in pairs(FontStringsRegular) do
		fontString:SetFont(unpack(font))
	end
end

function BloodShield:UpdateGlobalColors()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if nibRealUI.class ~= "DEATHKNIGHT" then return end
	AngleStatusBar:SetBarColor(self.bsBar.bShield.bar, nibRealUI.media.colors.red)
	AngleStatusBar:SetBarColor(self.bsBar.resolve.bar, nibRealUI.media.colors.orange)
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

function BloodShield:CreateFrames()
	self.bsBar = CreateFrame("Frame", "RealUI_BloodShield", RealUIPositionersClassResource)
	local bsBar = self.bsBar
		bsBar:SetSize((BarWidth[layoutSize] * 2) + 1, 6)
		bsBar:SetPoint("BOTTOM")
		-- bsBar:Hide()
	
	-- Blood Shield
	bsBar.bShield = CreateFrame("Frame", nil, bsBar)
		bsBar.bShield:SetPoint("BOTTOMRIGHT", bsBar, "BOTTOM", -1, 0)
		bsBar.bShield:SetSize(BarWidth[layoutSize], 6)

		bsBar.bShield.bg = bsBar.bShield:CreateTexture(nil, "ARTWORK")
			bsBar.bShield.bg:SetPoint("BOTTOMRIGHT")
			bsBar.bShield.bg:SetSize(128, 16)
			bsBar.bShield.bg:SetTexture(Textures[layoutSize].bar)
			bsBar.bShield.bg:SetVertexColor(unpack(nibRealUI.media.background))

		bsBar.bShield.endBox = bsBar.bShield:CreateTexture(nil, "ARTWORK")
			bsBar.bShield.endBox:SetPoint("BOTTOMRIGHT", bsBar.bShield, "BOTTOMLEFT", 4, 0)
			bsBar.bShield.endBox:SetSize(16, 16)
			bsBar.bShield.endBox:SetTexture(Textures[layoutSize].endBox)
			bsBar.bShield.endBox:SetVertexColor(unpack(nibRealUI.media.background))

		bsBar.bShield.bar = AngleStatusBar:NewBar(bsBar.bShield, -5, -1, BarWidth[layoutSize] - 7, 4, "RIGHT", "RIGHT", "LEFT")
			bsBar.bShield.bar.reverse = true

		bsBar.bShield.value = bsBar.bShield:CreateFontString()
			bsBar.bShield.value:SetPoint("BOTTOMLEFT", bsBar.bShield, "TOPLEFT", -6.5, 1.5)
			bsBar.bShield.value:SetJustifyH("LEFT")
			tinsert(FontStringsRegular, bsBar.bShield.value)
	
	-- Resolve
	bsBar.resolve = CreateFrame("Frame", nil, bsBar)
		bsBar.resolve:SetPoint("BOTTOMLEFT", bsBar, "BOTTOM", 0, 0)
		bsBar.resolve:SetSize(BarWidth[layoutSize], 6)

		bsBar.resolve.bg = bsBar.resolve:CreateTexture(nil, "ARTWORK")
			bsBar.resolve.bg:SetPoint("BOTTOMLEFT")
			bsBar.resolve.bg:SetSize(128, 16)
			bsBar.resolve.bg:SetTexture(Textures[layoutSize].bar)
			bsBar.resolve.bg:SetTexCoord(1, 0, 0, 1)
			bsBar.resolve.bg:SetVertexColor(unpack(nibRealUI.media.background))

		bsBar.resolve.endBox = bsBar.resolve:CreateTexture(nil, "ARTWORK")
			bsBar.resolve.endBox:SetPoint("BOTTOMLEFT", bsBar.resolve, "BOTTOMRIGHT", -4, 0)
			bsBar.resolve.endBox:SetSize(16, 16)
			bsBar.resolve.endBox:SetTexture(Textures[layoutSize].endBox)
			bsBar.resolve.endBox:SetTexCoord(1, 0, 0, 1)
			bsBar.resolve.endBox:SetVertexColor(unpack(nibRealUI.media.background))

		bsBar.resolve.bar = AngleStatusBar:NewBar(bsBar.resolve, 5, -1, BarWidth[layoutSize] - 7, 4, "LEFT", "LEFT", "RIGHT")
			bsBar.resolve.bar.reverse = true

		bsBar.resolve.value = bsBar.resolve:CreateFontString()
			bsBar.resolve.value:SetPoint("BOTTOMRIGHT", bsBar.resolve, "TOPRIGHT", 9.5, 1.5)
			bsBar.resolve.value:SetJustifyH("RIGHT")
			tinsert(FontStringsRegular, bsBar.resolve.value)

	-- Middle
	bsBar.middle = bsBar:CreateTexture(nil, "ARTWORK")
		bsBar.middle:SetPoint("BOTTOM")
		bsBar.middle:SetSize(16, 16)
		bsBar.middle:SetTexture(Textures[layoutSize].middle)
		bsBar.middle:SetVertexColor(unpack(nibRealUI.classColor))
end

------------
function BloodShield:ToggleConfigMode(val)
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if nibRealUI.class ~= "DEATHKNIGHT" then return end
	if self.configMode == val then return end

	self.configMode = val
	self:UpdateShown()
end

function BloodShield:OnInitialize()
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

function BloodShield:OnEnable()
	if nibRealUI.class ~= "DEATHKNIGHT" then return end

	self.configMode = false

	BloodShieldName = GetSpellInfo(BloodShieldID)

	if not self.bsBar then self:CreateFrames() end
	self:UpdateFonts()
	self:UpdateMax()
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
	self:RegisterEvent("PLAYER_UNGHOST", "UpdateShown")
	self:RegisterEvent("PLAYER_ALIVE", "UpdateShown")
	self:RegisterEvent("PLAYER_DEAD", "UpdateShown")
	self:RegisterEvent("PLAYER_LEVEL_UP", "UpdateShown")
	self:RegisterEvent("UNIT_MAXHEALTH", "UpdateMax")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED", "CLEU")
	self:RegisterBucketEvent({"UNIT_AURA", "UNIT_ABSORB_AMOUNT_CHANGED"}, updateSpeed, "UpdateAuras")
end

function BloodShield:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllBuckets()
end
