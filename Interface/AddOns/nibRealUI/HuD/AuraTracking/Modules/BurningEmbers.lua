local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "AuraTracking_BurningEmbers"
local BurningEmbers = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local AuraTracking = nibRealUI:GetModule("AuraTracking")

local isDestLock
local BurningEmbersSpellID = 108647
local MinLevel = 42

local function AuraUpdate(self, event, unit)
	if self.inactive then return end

	local power = UnitPower("player", SPELL_POWER_BURNING_EMBERS, true)

	-- Set Icon Desaturated
	if power >= 10 then
		self.icon:SetDesaturated(nil)
	else
		if self.isStatic then
			self.icon:SetDesaturated(1)
		end
	end

	-- Update Frame
	if (power > 0) then
		-- Count
		self.count:SetText(power)

		-- Show frame
		self:Show()
		if not self.isStatic then
			AuraTracking:FreeIndicatorUpdate(self, true)
		end
	else
		-- Hide frame
		if not self.isStatic then
			self:Hide()
			AuraTracking:FreeIndicatorUpdate(self, false)
		end
		self.count:SetText()
	end

	if self.isStatic then
		AuraTracking:StaticIndicatorUpdate(self)
	end
end

local function TalentUpdate(self, event, unit, initializing)
	local oldInactive = self.inactive
	self.inactive = false

	local spec = GetSpecialization()
	if (nibRealUI.class == "WARLOCK") and (spec == 3) and (UnitLevel("player") >= MinLevel) then
		isDestLock = true
	else
		isDestLock = false
	end

	if not isDestLock then
		self:Hide()
		self.inactive = true
	else
		self.inactive = false
		if self.isStatic then
			self:Show()
		end
		if not(initializing) then
			AuraUpdate(self, nil, self.unit)
		end
	end

	-- Update Indicators
	if not(initializing) and (self.inactive ~= oldInactive) then
		AuraTracking:RefreshIndicatorAssignments()
	end
end

function BurningEmbers:TalentRefresh()
	TalentUpdate(self.frame, nil, nil, true)
end

function BurningEmbers:AuraRefresh()
	AuraUpdate(self.frame, nil, self.unit)

	if self.frame.isStatic then
		if self.frame.inactive then
			self.frame:Hide()
		else
			self.frame:Show()
		end
	end
end

function BurningEmbers:SetUpdates()
	self.frame:UnregisterAllEvents()
	self.frame:RegisterUnitEvent("UNIT_POWER", "player")
	self.frame:RegisterUnitEvent("UNIT_MAXPOWER", "player")

	self.frame:SetScript("OnEvent", function(self, event, ...)
		AuraUpdate(self, event, ...)
	end)
end

function BurningEmbers:SetIndicatorInfo(info)
	local f = self.frame

	local name,_,icon = GetSpellInfo(BurningEmbersSpellID)
	f.texture = icon
	f.icon:SetTexture(icon)

	f.side = "LEFT"
	f.unit = "player"
	
	f.isStatic = (info.order ~= nil)
	if f.isStatic then
		f.icon:SetDesaturated(1)
	else
		f:Hide()
	end

	-- TalentUpdate(f)
	-- AuraUpdate(f, nil, f.unit)
end

function BurningEmbers:CreateIndicator()
	self.frame = CreateFrame("Button", nil, UIParent)
	local f = self.frame

	f.icon = f:CreateTexture(nil, "BACKGROUND")
		f.icon:SetAllPoints(f)
		f.icon:SetTexCoord(.08, .92, .08, .92)
	f.count = f:CreateFontString()
		f.count:SetFont(unpack(nibRealUI.font.pixelCooldown))
		f.count:SetJustifyH("RIGHT")
		f.count:SetJustifyV("TOP")
		f.count:SetPoint("TOPRIGHT", f, "TOPRIGHT", 1.5, 2.5)
		AuraTracking:RegisterFont("cooldown", f.count)
	f.customCD = f:CreateTexture(nil, "ARTWORK")
		f.customCD:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT")
		f.customCD:SetPoint("BOTTOMRIGHT", f, "BOTTOMRIGHT")
		f.customCD:SetHeight(0)
		f.customCD:SetTexture(0, 0, 0, 0.75)
	f.customCDTime = f:CreateFontString()
		f.customCDTime:SetFont(unpack(nibRealUI.font.pixelCooldown))
		f.customCDTime:SetJustifyH("LEFT")
		f.customCDTime:SetJustifyV("BOTTOM")
		f.customCDTime:SetPoint("BOTTOMLEFT", f, "BOTTOMLEFT", 1.5, 0.5)
		AuraTracking:RegisterFont("cooldown", f.customCDTime)
	
	f.useCustomCD = AuraTracking:UseCustomCooldown()
	
	f.elapsed = 1
	f:SetScript("OnUpdate", CustomCooldownUpdate)

	nibRealUI:CreateBDFrame(f, 0)
end

function BurningEmbers:New(info)
	local Indicator = {}
	setmetatable(Indicator, {__index = self})

	Indicator:CreateIndicator()
	Indicator:SetIndicatorInfo(info)

	return Indicator
end

AuraTracking:RegisterModule(BurningEmbers, "BurningEmbers")