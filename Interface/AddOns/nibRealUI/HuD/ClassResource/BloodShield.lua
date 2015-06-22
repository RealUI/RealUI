local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "ClassResource_BloodShield"
local BloodShield = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local ClassResourceBar = nibRealUI:GetModule("ClassResourceBar")
local Resolve = nibRealUI:GetModule("ClassResource_Resolve")

local BloodShieldID = 77535
local BloodShieldName
local MinLevel = 10
local maxHealth

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
	self.bsBar:SetValue("left", bloodPer)
	self.bsBar:SetText("left", nibRealUI:ReadableNumber(self.curBloodAbsorb, 0))

	if bloodPer > 0 then
		self.bsBar:SetBoxColor("left", nibRealUI.media.colors.red)
	else
		self.bsBar:SetBoxColor("left", nibRealUI.media.background)
	end

	-- Resolve
	if event ~= "CLEU" then
		Resolve:UpdateCurrent()

		self.bsBar:SetValue("right", Resolve.percent)
		self.bsBar:SetText("right", nibRealUI:ReadableNumber(Resolve.current, 0))
		if Resolve.percent > 0 then
			self.bsBar:SetBoxColor("right", nibRealUI.media.colors.orange)
		else
			self.bsBar:SetBoxColor("right", nibRealUI.media.background)
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
function BloodShield:UpdateGlobalColors()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	self.bsBar:SetBarColor("left", nibRealUI.media.colors.red)
	self.bsBar:SetBarColor("right", nibRealUI.media.colors.orange)
	self:UpdateAuras()
end

------------
function BloodShield:ToggleConfigMode(val)
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
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
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME) and nibRealUI.class == "DEATHKNIGHT")
	nibRealUI:RegisterConfigModeModule(self)
end

function BloodShield:OnEnable()
	self.configMode = false

	BloodShieldName = GetSpellInfo(BloodShieldID)

	if not self.bsBar then 
		self.bsBar = ClassResourceBar:New("long", L["Resource_BloodShield"])
		self.bsBar:SetBoxColor("middle", nibRealUI.classColor)
	end
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
