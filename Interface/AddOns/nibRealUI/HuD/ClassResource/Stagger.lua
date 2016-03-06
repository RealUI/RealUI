local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
if nibRealUI.isBeta then return end

local L = nibRealUI.L
local db, ndb

local _
local MODNAME = "ClassResource_Stagger"
local Stagger = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local ClassResourceBar = nibRealUI:GetModule("ClassResourceBar")
local Resolve = nibRealUI:GetModule("ClassResource_Resolve")

local MinLevel = 10
local maxHealth

-----------------
---- Updates ----
-----------------
function Stagger:UpdateAuras(units)
	--print("UpdateAuras", units)
	-- if units then
	-- 	for k, v in pairs(units) do
	-- 		--print(k, v)
	-- 	end
	-- end
	if units and not(units.player) then return end

	-- Stagger
	self.curStagger = UnitStagger("player")
	self.percent = self.curStagger / maxHealth
	self.staggerLevel = 1

	local staggerPer = nibRealUI:Clamp(self.percent, 0, 1/5) * 5
	self.sBar:SetValue("left", staggerPer)
	self.sBar:SetText("left", nibRealUI:ReadableNumber(self.curStagger, 0))

    if (self.percent > STAGGER_YELLOW_TRANSITION and self.percent < STAGGER_RED_TRANSITION) then
    	--Moderate
		self.sBar:SetBoxColor("left", nibRealUI.media.colors.yellow)
		self.sBar:SetBarColor("left", nibRealUI.media.colors.yellow)
    elseif (self.percent > STAGGER_RED_TRANSITION) then
    	--Heavy
		self.sBar:SetBoxColor("left", nibRealUI.media.colors.red)
		self.sBar:SetBarColor("left", nibRealUI.media.colors.red)
    else
    	--Light
		self.sBar:SetBoxColor("left", nibRealUI.media.colors.green)
		self.sBar:SetBarColor("left", nibRealUI.media.colors.green)
    end

	-- Resolve
	Resolve:UpdateCurrent()
	
	self.sBar:SetValue("right", Resolve.percent)
	self.sBar:SetText("right", nibRealUI:ReadableNumber(Resolve.current, 0))

	if Resolve.percent > 0 then
		self.sBar:SetBoxColor("right", nibRealUI.media.colors.orange)
	else
		self.sBar:SetBoxColor("right", nibRealUI.media.background)
	end

	-- Update visibility
	if (((self.curStagger > 0) or (Resolve.current > floor(Resolve.base))) and not(self.sBar:IsShown())) or
		(((self.curStagger <= 0) or (Resolve.current <= floor(Resolve.base))) and self.sBar:IsShown()) then
			self:UpdateShown()
	end
end

function Stagger:UpdateMax(event, unit)
	--print("UpdateMax", event, unit)
	if (unit and (unit ~= "player")) then
		return
	end
	
	maxHealth = UnitHealthMax("player")
	self:UpdateAuras()
end

function Stagger:UpdateShown(event, unit)
	--print("UpdateShown")
	if unit and unit ~= "player" then return end

	if self.configMode then
		self.sBar:Show()
		return
	end

	if ( (GetSpecialization() == 1) and ((Resolve.current and (Resolve.current > floor(Resolve.base))) or (self.curStagger and (self.curStagger > 0))) and not(UnitIsDeadOrGhost("player")) and (UnitLevel("player") >= MinLevel) ) then
		self.sBar:Show()
	else
		self.sBar:Hide()
	end
end

function Stagger:PLAYER_ENTERING_WORLD()
	self.guid = UnitGUID("player")
	self:UpdateAuras()
	self:UpdateShown()
end

function Stagger:UpdateGlobalColors()
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	self.sBar:SetBarColor("right", nibRealUI.media.colors.orange)
	self:UpdateAuras()
end

------------
function Stagger:ToggleConfigMode(val)
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	if self.configMode == val then return end

	self.configMode = val
	self:UpdateShown()
end

function Stagger:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {},
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled("PointTracking") and nibRealUI:GetModuleEnabled(MODNAME) and nibRealUI.class == "MONK")
	nibRealUI:RegisterConfigModeModule(self)
end

function Stagger:OnEnable()
	self.configMode = false

	if not self.sBar then 
		self.sBar = ClassResourceBar:New("long", L["Resource_Stagger"])
		self.sBar:SetBoxColor("middle", nibRealUI.classColor)
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
	self:RegisterBucketEvent({"UNIT_DISPLAYPOWER", "UNIT_AURA", "UNIT_ABSORB_AMOUNT_CHANGED"}, updateSpeed, "UpdateAuras")
end

function Stagger:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllBuckets()
end
