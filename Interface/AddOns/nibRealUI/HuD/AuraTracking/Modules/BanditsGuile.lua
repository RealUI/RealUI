local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "AuraTracking_BanditsGuile"
local BanditsGuile = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local AuraTracking = nibRealUI:GetModule("AuraTracking")

local SinisterStrikeID = 1752
local RevealingStrikeID = 84617

local maxBGDuration = 15

local bgSpellIDs = {84745, 84746, 84747}
local bgNames = {}
local bgIcons = {}

local bgDuration, bgEndTime

local bgState = 0
local bgSwingCount = 0
local bgTimerActive = false
local lastTargetGUID = nil
local hasTargetChanged = false

local isCRogue

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
	local name, _, _, _, _, duration, endTime = UnitAura(unitName, buffName)
	if name then
		return name, duration, endTime - GetTime()
	end
	return nil, nil
end

local function AuraUpdate(self, event, unit)
	if self.inactive then return end

	local now = GetTime()
	local remaining = nil
	local name

	-- Get duration of any active BG buffs
	bgState = 0
	for i = 1, 3 do
		name, bgDuration, remaining = GetBuffDuration("player", bgNames[i])
		if name and remaining then
			bgState = i
			break
		end
	end
	if not remaining then
		bgEndTime = 0
	else
		bgEndTime = remaining + now
	end

	-- Set Icon Texture / Desaturated
	if bgState and bgState > 0 then
		self.icon:SetTexture(bgIcons[bgState])
		self.icon:SetDesaturated(nil)
		self.isActive = true
	else
		self.isActive = false
		if self.isStatic then
			self.icon:SetTexture(bgIcons[1])
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

	-- Update Frame
	if (((bgEndTime) and (bgEndTime >= now)) ) or (bgSwingCount > 0) then	--and (bgState and (bgState > 0))
		if not(remaining) and ((bgEndTime) and (bgEndTime >= now)) then
			remaining = bgEndTime - now
		end

		-- Cooldown
		if remaining then
			self.startTime = now - (maxBGDuration - remaining)
			self.auraDuration = maxBGDuration
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

		-- Swings
		if (bgSwingCount > 0) and (bgState < 3) then
			self.count:SetText(bgSwingCount)
		else
			self.count:SetText()
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

local function CLEU(self, event, ...)
	local _, cEvent, _,_, casterName, _,_,_,_,_,_, spellID = ...
	if (casterName ~= self.playerName) then return end
	
	if (cEvent == "SPELL_DAMAGE") and ((spellID == SinisterStrikeID) or (spellID == RevealingStrikeID)) then
		bgSwingCount = bgSwingCount + 1
		AuraUpdate(self, nil, self.unit)
		
	elseif ((cEvent == "SPELL_AURA_REMOVED") or (cEvent == "SPELL_AURA_APPLIED")) and ((spellID == bgSpellIDs[3]) or (spellID == bgSpellIDs[2]) or (spellID == bgSpellIDs[1])) then
		bgSwingCount = 0
		AuraUpdate(self, nil, self.unit)
	end
end

local function TalentUpdate(self, event, unit, initializing)
	local oldInactive = self.inactive
	self.inactive = false

	if nibRealUI.class ~= "ROGUE" then
		isCRogue = false
	else
		local spec = GetSpecialization()
		isCRogue = spec == 2
	end

	if not isCRogue then
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
	AuraTracking:ToggleRavenAura(false, "buff", "#"..bgSpellIDs[1], not(self.inactive))
	AuraTracking:ToggleRavenAura(false, "buff", "#"..bgSpellIDs[2], not(self.inactive))
	AuraTracking:ToggleRavenAura(false, "buff", "#"..bgSpellIDs[3], not(self.inactive))
end

function BanditsGuile:TalentRefresh()
	TalentUpdate(self.frame, nil, nil, true)
end

function BanditsGuile:AuraRefresh()
	AuraUpdate(self.frame, nil, self.frame.unit)

	if self.frame.isStatic then
		if self.frame.inactive then
			self.frame:Hide()
		else
			self.frame:Show()
		end
	end
end

function BanditsGuile:SetUpdates()
	self.frame:UnregisterAllEvents()
	self.frame:RegisterUnitEvent("UNIT_AURA", "player")
	self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")

	self.frame:SetScript("OnEvent", function(self, event, ...)
		if event == "UNIT_AURA" then
			AuraUpdate(self, event, ...)
		elseif event == "COMBAT_LOG_EVENT_UNFILTERED" then
			CLEU(self, event, ...)
		end
	end)
end

function BanditsGuile:SetIndicatorInfo(info)
	local f = self.frame

	for i = 1, 3 do
		local name,_,icon = GetSpellInfo(bgSpellIDs[i])
		bgNames[i] = name
		bgIcons[i] = icon
	end

	f.side = "LEFT"
	f.unit = "player"
	
	f.isStatic = (info.order ~= nil)
	if f.isStatic then
		f.texture = bgIcons[1]
		f.icon:SetTexture(bgIcons[1])
		f.icon:SetDesaturated(1)
	else
		f:Hide()
	end

	f.playerName = UnitName("player")

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

function BanditsGuile:CreateIndicator()
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

function BanditsGuile:New(info)
	local Indicator = {}
	setmetatable(Indicator, {__index = self})

	Indicator:CreateIndicator()
	Indicator:SetIndicatorInfo(info)

	return Indicator
end

AuraTracking:RegisterModule(BanditsGuile, "BanditsGuile")