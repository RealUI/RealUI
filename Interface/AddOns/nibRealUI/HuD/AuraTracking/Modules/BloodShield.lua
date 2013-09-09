local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "AuraTracking_BloodShield"
local BloodShield = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local AuraTracking = nibRealUI:GetModule("AuraTracking")

local BloodShieldID = 77535
local BloodShieldName
local MinLevel = 80
local maxBSDuration = 10

-- Custom Cooldown
local function CustomCooldownUpdate(self, elapsed)
	if not(self.startTime and self.auraDuration) then
		self.elapsed = 1
		self.customCDTime:SetText()
		return
	end

	self.elapsed = self.elapsed + elapsed
	if self.elapsed > 0.1 then
		local now = GetTime()
		local maxHeight = 30
		local curHeight = nibRealUI:Clamp(((now - self.startTime) / self.auraDuration) * maxHeight, 0, maxHeight)
		local remaining = self.auraDuration - (now - self.startTime)

		self.customCD:SetHeight(curHeight)

		local time, suffix = AuraTracking:GetTimeText(remaining)
		self.customCDTime:SetFormattedText("%d%s", time, suffix or "")

		local color
		if remaining >= 59.5 then
			color = nibRealUI.CooldownCount.db.profile.colors.minutes
		elseif remaining >= 5.5 then
			color = nibRealUI.CooldownCount.db.profile.colors.seconds
		else
			color = nibRealUI.CooldownCount.db.profile.colors.expiring
		end
		self.customCDTime:SetTextColor(color[1], color[2], color[3])

		self.elapsed = 0
	end
end

local function AuraUpdate(self, event, unit)
	if self.inactive then return end
	if unit ~= self.unit then return end

	local now = GetTime()

	local remaining
	local spellName,_,_,_,_,_,endTime,_,_,_,spellID,_,_,_, absorb = UnitAura("player", BloodShieldName)
	if ( spellID == BloodShieldID ) then 
		self.CurrentAbsorb = absorb
		remaining = endTime - now
	end

	-- Active Spell Name
	if spellName then
		self.activeSpellName = spellName
	else
		self.activeSpellName = nil
	end
	self.auraIndex = nil

	-- Update Frame
	if self.CurrentAbsorb and (self.CurrentAbsorb > 0) and remaining then
		-- Set Icon Texture / Desaturated
		self.icon:SetDesaturated(nil)
		self.isActive = true

		-- Absorb
		self.count:SetFormattedText("%d%%", self.CurrentAbsorb / UnitHealthMax(self.unit))

		-- Cooldown
		if remaining then
			self.startTime = now - (maxBSDuration - remaining)
			self.auraDuration = maxBSDuration
			if self.useCustomCD then
				self.customCD:Show()
				self.customCDTime:Show()
				self.count:SetParent(self)
			else
				self.cd:SetCooldown(self.startTime, self.auraDuration)
				self.cd:Show()
				self.count:SetParent(self.cd)
			end
		else
			self.cd:Hide()
			self.customCD:Hide()
			self.customCDTime:Hide()
			self.count:SetParent(self)
		end

		-- Show frame
		self:Show()
		if not self.isStatic then
			AuraTracking:FreeIndicatorUpdate(self, true)
		end
	else
		self.isActive = false
		if self.isStatic then
			self.icon:SetDesaturated(1)
		end

		self.cd:Hide()
		self.customCD:Hide()
		self.customCDTime:Hide()
		self.count:SetParent(self)
		self.count:SetText()

		-- Hide frame
		if not self.isStatic then
			self:Hide()
			AuraTracking:FreeIndicatorUpdate(self, false)
		end
	end

	if self.isStatic then
		AuraTracking:StaticIndicatorUpdate(self)
	end
end

local function CLEU(self, event, ...)
	local _, cEvent, _,_,_,_,_, destGUID, _,_,_, spellID = ...

	if ( (destGUID == self.guid) and (cEvent == "SPELL_AURA_REMOVED") and (spellID == BloodShieldID) ) then
		self.CurrentAbsorb = 0
		AuraUpdate(self, nil, self.unit)
	end
end

local function TalentUpdate(self, event, unit, initializing)
	local oldInactive = self.inactive
	self.inactive = false

	local isValid = true

	if nibRealUI.class ~= "DEATHKNIGHT" then
		isValid = false
	else
		local spec = GetSpecialization()
		isValid = spec == 1
	end

	if not isValid then
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

	-- Raven Spell Lists
	AuraTracking:ToggleRavenAura(false, "buff", "#"..BloodShieldID, not(self.inactive))
end

function BloodShield:TalentRefresh()
	TalentUpdate(self.frame, nil, nil, true)
end

function BloodShield:AuraRefresh()
	AuraUpdate(self.frame, nil, self.frame.unit)

	if self.frame.isStatic then
		if self.frame.inactive then
			self.frame:Hide()
		else
			self.frame:Show()
		end
	end
end

function BloodShield:SetUpdates()
	self.frame:UnregisterAllEvents()
	self.frame:RegisterUnitEvent("UNIT_ABSORB_AMOUNT_CHANGED", self.unit)
	self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	self.frame:SetScript("OnEvent", function(self, event, ...)
		if event == "UNIT_ABSORB_AMOUNT_CHANGED" then
			AuraUpdate(self, event, ...)
		elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
			CLEU(self, event, ...)
		end
	end)
end

function BloodShield:SetIndicatorInfo(info)
	local f = self.frame

	local name,_,icon = GetSpellInfo(BloodShieldID)
	BloodShieldName = name

	f.side = "LEFT"
	f.unit = "player"
	
	f.isStatic = (info.order ~= nil)
	if f.isStatic then
		f.texture = icon
		f.icon:SetTexture(icon)
		f.icon:SetDesaturated(1)
	else
		f:Hide()
	end

	-- TalentUpdate(f)
	-- AuraUpdate(f, nil, f.unit)
end

-- Tooltips
local function OnLeave(self)
	if self.auraIndex then
		GameTooltip:Hide()
	end
end

local function OnEnter(self)
	if not self.activeSpellName then return end
	local buffFilter = "HELPFUL|PLAYER"

	for i = 1, 40 do
		local name = UnitAura(self.unit, i, buffFilter)
		if name == self.activeSpellName then
			self.auraIndex = i
			break
		end
	end

	if self.auraIndex then
		GameTooltip_SetDefaultAnchor(GameTooltip, UIParent)
		GameTooltip:SetUnitAura(self.unit, self.auraIndex, buffFilter)
		GameTooltip:Show()
	end
end

function BloodShield:CreateIndicator()
	self.frame = CreateFrame("Button", nil, UIParent)
	local f = self.frame

	f.cd = CreateFrame("Cooldown", nil, f)
		f.cd:SetAllPoints(f)
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

	f:SetScript("OnEnter", OnEnter)
	f:SetScript("OnLeave", OnLeave)

	nibRealUI:CreateBDFrame(f, 0)
end

function BloodShield:New(info)
	local Indicator = {}
	setmetatable(Indicator, {__index = self})

	Indicator:CreateIndicator()
	Indicator:SetIndicatorInfo(info)

	return Indicator
end

AuraTracking:RegisterModule(BloodShield, "BloodShield")