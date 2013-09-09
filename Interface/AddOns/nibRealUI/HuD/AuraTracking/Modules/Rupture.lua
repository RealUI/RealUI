local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "AuraTracking_Rupture"
local Rupture = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local AuraTracking = nibRealUI:GetModule("AuraTracking")

local RuptureSpellID = 1943
local RuptureSpellName
local gapPerComboPoint = 4
local maxComboPoints = 5
local baseRuptureDuration = 8
local maxRuptureDuration = 24
local MinLevel = 46

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

local function GetBuffDuration(unitName, buffName)
	local name, _, _, _, _, duration, endTime = UnitAura(unitName, buffName, nil, "HARMFUL|PLAYER")
	if name then
		return name, duration, endTime - GetTime()
	end
	return nil, nil
end

local function AuraUpdate(self, event, unit)
	if self.inactive then return end

	local now = GetTime()

	local points = GetComboPoints("player", "target")

	local name, duration, remaining = GetBuffDuration("target", RuptureSpellName)
	local endTime

	if not remaining then
		endTime = 0
	else
		endTime = remaining + now
	end

	-- Set Icon Texture / Desaturated
	if endTime > 0 then
		self.icon:SetDesaturated(nil)
		self.isActive = true
	else
		self.isActive = false
		if self.isStatic then
			self.icon:SetDesaturated(1)
		end
	end

	-- Active Spell Name
	if name then
		self.activeSpellName = name
	else
		self.activeSpellName = nil
	end
	self.auraIndex = nil

	-- Potential
	if (points > 0) then
		local potentialRupture = baseRuptureDuration + ((points - 1) * gapPerComboPoint)
		self.count:SetText(potentialRupture)
		if potentialRupture == maxRuptureDuration then
			self.count:SetTextColor(0, 1, 0)
		else
			self.count:SetTextColor(1, 1, 1)
		end
	else
		self.count:SetText("")
	end

	-- Update Frame
	if ((endTime) and (endTime >= now)) then
		if not(remaining) and ((endTime) and (endTime >= now)) then
			remaining = endTime - now
		end

		-- Cooldown
		if remaining then
			self.startTime = now - (maxRuptureDuration - remaining)
			self.auraDuration = maxRuptureDuration
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
		-- Hide frame
		if not self.isStatic then
			self:Hide()
			AuraTracking:FreeIndicatorUpdate(self, false)
		end
		self.cd:Hide()
		self.customCD:Hide()
		self.customCDTime:Hide()
	end

	if self.isStatic then
		AuraTracking:StaticIndicatorUpdate(self)
	end
end

local function TalentUpdate(self, event, unit, initializing)
	local oldInactive = self.inactive
	self.inactive = false

	if (nibRealUI.class ~= "ROGUE") or (UnitLevel("player") < MinLevel) then
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
		self.icon:SetTexture(self.texture)
	end

	-- Update Indicators
	if not(initializing) and (self.inactive ~= oldInactive) then
		AuraTracking:RefreshIndicatorAssignments()
	end

	-- Raven Spell Lists
	AuraTracking:ToggleRavenAura(false, "buff", "#"..RuptureSpellID, not(self.inactive))
end

function Rupture:TalentRefresh()
	TalentUpdate(self.frame, nil, nil, true)
end

function Rupture:AuraRefresh()
	AuraUpdate(self.frame, nil, self.unit)

	if self.frame.isStatic then
		if self.frame.inactive then
			self.frame:Hide()
		else
			self.frame:Show()
		end
	end
end

function Rupture:SetUpdates()
	self.frame:UnregisterAllEvents()
	self.frame:RegisterUnitEvent("UNIT_AURA", "target")
	self.frame:RegisterUnitEvent("UNIT_COMBO_POINTS", "player")
	self.frame:RegisterEvent("PLAYER_TARGET_CHANGED")

	self.frame:SetScript("OnEvent", function(self, event, ...)
		AuraUpdate(self, event, ...)
	end)
end

function Rupture:SetIndicatorInfo(info)
	local f = self.frame

	local name,_,icon = GetSpellInfo(RuptureSpellID)
	f.texture = icon
	RuptureSpellName = name

	f.side = "RIGHT"
	f.unit = "target"
	
	f.isStatic = (info.order ~= nil)
	if f.isStatic then
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
	local buffFilter = "HARMFUL|PLAYER"

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

function Rupture:CreateIndicator()
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

function Rupture:New(info)
	local Indicator = {}
	setmetatable(Indicator, {__index = self})

	Indicator:CreateIndicator()
	Indicator:SetIndicatorInfo(info)

	return Indicator
end

AuraTracking:RegisterModule(Rupture, "Rupture")