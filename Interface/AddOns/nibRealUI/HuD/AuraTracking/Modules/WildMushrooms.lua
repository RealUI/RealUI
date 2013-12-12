local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "AuraTracking_WildMushrooms"
local WildMushrooms = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local AuraTracking = nibRealUI:GetModule("AuraTracking")

-- local ShroomID = 88747	-- Wild Mushrooms
local ShroomDuration = 300
local ShroomID = 145205	-- Wild Mushrooms
local ShroomName = ""
local BloomID = 102791	-- Wild Mushrooms: Bloom
local RejuvID = 774		-- Rejuvenation
local MaxHealthPercent = 2
local OverHealPercent = 1
local MinLevel = 84

local function GetMushroomTime()
	local time = 0
	local currentTime = GetTotemTimeLeft(1)
	if ( currentTime > 0 ) then
		time = currentTime
	else
		time = nil
	end
	return time
end

local function AuraUpdate(self)
	if self.inactive then return end

	-- Update Info
	if not(ShroomName) or not(self.texture) then
		local name,_,icon = GetSpellInfo(ShroomID)
		ShroomName = name
		self.activeSpellName = name
		self.texture = icon
		self.icon:SetTexture(icon)
	end

	-- Update Frame
	local shroomTime = GetMushroomTime()
	if shroomTime and self.AreShroomsDown then
		self.isActive = true
		
		-- Set Icon Desaturated
		self.icon:SetDesaturated(nil)

		-- Cooldown
		-- self.cd:SetCooldown(GetTime() - (300 - shroomTime), 300)
		-- self.cd:Show()
		-- self.count:SetParent(self.cd)

		-- Absorb
		if self.CurrentOverheal and (self.CurrentOverheal > 0) then
			if self.MaxOverheal > 0 then
				local per = self.CurrentOverheal / self.MaxOverheal
				-- local per = nibRealUI:Clamp(self.CurrentOverheal / self.MaxOverheal, 0, 1)
				self.count:SetFormattedText("%d.", per * 100)
				self.count:SetTextColor(nibRealUI:GetDurabilityColor(per))
			else
				self.count:SetText("100.")
				self.count:SetTextColor(nibRealUI:GetDurabilityColor(per))
			end
		else
			self.count:SetText("")
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

		-- self.cd:Hide()
		-- self.count:SetParent(self)
		self.count:SetText("")

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

-- Totem update
-- Reset
local function TotemUpdate(self)
	local shroomTime = GetMushroomTime()
	if not shroomTime then
		self.CurrentOverheal = 0
		self.AreShroomsDown = false
	else
		self.AreShroomsDown = true
	end	
	AuraUpdate(self)
end

local function SpellCastSucceeded(self, event, unitID, spellName, spellRank, lineID, spellID)
	if ( spellID == ShroomID ) then -- Wild Mushroom
		self.MaxOverheal = UnitHealthMax("player") * MaxHealthPercent
		self.AreShroomsDown = true
		AuraUpdate(self)
	
	elseif ( spellID == BloomID) then --Wild Mushroom: Bloom
		self.AreShroomsDown = false
		self.CurrentOverheal = 0
		AuraUpdate(self)
	end
end

local function CLEU(self, event, ...)
	local _, cEvent, _, sourceGUID, _,_,_,_,_,_,_, spellID,_,_,_, overhealing = ...
	if (sourceGUID ~= AuraTracking.playerGUID) or (cEvent ~= "SPELL_PERIODIC_HEAL") then return end

	if ( spellID == RejuvID and self.AreShroomsDown) then -- Rejuvenation
		if ( self.CurrentOverheal < self.MaxOverheal ) then
			self.CurrentOverheal = self.CurrentOverheal + (overhealing * OverHealPercent)
			if ( self.CurrentOverheal >= self.MaxOverheal ) then 
				self.CurrentOverheal = self.MaxOverheal
			end
			self.BloomPercent = (self.CurrentOverheal / self.MaxOverheal) * 100
			AuraUpdate(self)
		end
	end
end

local function Reset(self)
	self.MaxOverheal = UnitHealthMax("player") * MaxHealthPercent
	TotemUpdate(self)
end

local function TalentUpdate(self, event, unit, initializing)
	local oldInactive = self.inactive
	self.inactive = false

	local isValid = true

	if nibRealUI.class ~= "DRUID" then
		isValid = false
	else
		isValid = not(GetShapeshiftFormID()) and (GetSpecialization() == 4) and (UnitLevel("player") >= MinLevel)
	end

	if not isValid then
		self:Hide()
		self.inactive = true
	else
		self.inactive = false

		local name,_,icon = GetSpellInfo(ShroomID)
		ShroomName = name
		self.activeSpellName = name
		self.texture = icon
		self.icon:SetTexture(icon)

		if self.isStatic then
			self:Show()
		end
		if not(initializing) then
			Reset(self)
		end
	end

	-- Update Indicators
	if not(initializing) and (self.inactive ~= oldInactive) then
		AuraTracking:RefreshIndicatorAssignments()
	end

	-- Raven Spell Lists
	AuraTracking:ToggleRavenAura(false, "buff", "#"..ShroomID, not(self.inactive))
end

function WildMushrooms:TalentRefresh()
	TalentUpdate(self.frame, nil, nil, true)
end

function WildMushrooms:AuraRefresh()
	AuraUpdate(self.frame)

	if self.frame.isStatic then
		if self.frame.inactive then
			self.frame:Hide()
		else
			self.frame:Show()
		end
	end
end

function WildMushrooms:SetUpdates()
	self.frame:UnregisterAllEvents()
	self.frame:RegisterUnitEvent("UNIT_SPELLCAST_SUCCEEDED", "player")
	self.frame:RegisterEvent("PLAYER_TOTEM_UPDATE")
	self.frame:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self.frame:RegisterEvent("PLAYER_ENTERING_WORLD")

	self.frame:SetScript("OnEvent", function(self, event, ...)
		if event == "COMBAT_LOG_EVENT_UNFILTERED" then
			CLEU(self, event, ...)
		elseif event == "UNIT_SPELLCAST_SUCCEEDED" then
			SpellCastSucceeded(self, event, ...)
		elseif event == "PLAYER_TOTEM_UPDATE" then
			TotemUpdate(self)
		elseif event == "PLAYER_ENTERING_WORLD" then
			Reset(self)
		end
	end)
end

function WildMushrooms:SetIndicatorInfo(info)
	local f = self.frame

	f.side = "LEFT"
	f.unit = "player"
	
	f.isStatic = (info.order ~= nil)
	if f.isStatic then
		f.icon:SetDesaturated(1)
	else
		f:Hide()
	end

	f.CurrentOverheal = 0
	f.MaxOverheal = UnitHealthMax("player") * MaxHealthPercent
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

function WildMushrooms:CreateIndicator()
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

function WildMushrooms:New(info)
	local Indicator = {}
	setmetatable(Indicator, {__index = self})

	Indicator:CreateIndicator()
	Indicator:SetIndicatorInfo(info)

	return Indicator
end

AuraTracking:RegisterModule(WildMushrooms, "WildMushrooms")