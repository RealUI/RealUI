local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local _
local MODNAME = "AuraTracking_Aura"
local Aura = nibRealUI:NewModule(MODNAME, "AceEvent-3.0")

local AuraTracking = nibRealUI:GetModule("AuraTracking")

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

-- Aura update
local function GetAuraInfo(self, index)
	local remaining
	local spellName = index and self.spellNames[index] or self.spellName
	local spellID = index and self.spellIDs[index] or self.spellID
	local buffFilter = (self.isBuff and "HELPFUL" or "HARMFUL") .. (self.anyone and "" or "|PLAYER")
	
	local name, rank, texture, count, type, duration, endTime, unitCaster, _, _, curSpellID = UnitAura(self.unit, spellName, nil, buffFilter)

	if (spellID and (curSpellID == spellID)) or (name == spellName) then
		if endTime then
			remaining = endTime - GetTime()
		end
		return name, duration, remaining, count, texture, endTime
	end
end

local function AuraUpdate(self, event, unit)
	if self.inactive and not self.isStatic then
		self:Hide()
		AuraTracking:FreeIndicatorUpdate(self, false)
		return
	end
	if self.inactive then return end

	local name, duration, remaining, count, texture, endTime
	if not self.trackMultiple then
		name, duration, remaining, count, texture, endTime = GetAuraInfo(self)
	else
		for k,v in ipairs(self.spellIDs) do
			name, duration, remaining, count, texture, endTime = GetAuraInfo(self, k)
			if name then break end
		end
	end

	-- Set Icon Texture / Desaturated
	if not(self.isStatic) then
		-- Update Free aura icon
		if texture then self.icon:SetTexture(texture) end
	else
		self.isActive = false
		-- Update Static aura icon and active status
		if name and texture then
			self.texture = texture
			self.icon:SetTexture(texture)
		end
		if not name then
			self.icon:SetDesaturated(1)
			self.isActive = false
		else
			self.icon:SetDesaturated(nil)
			if not self.hideOOC then
				self.isActive = true
			end
		end
	end

	-- Active Spell Name
	if name then
		self.activeSpellName = name
	else
		self.activeSpellName = nil
	end
	self.auraIndex = nil

	-- Calculate Aura info
	if name then
		if endTime == 0 then
			self.bIsAura = true
			self.auraDuration = 1
			self.auraEndTime = 0
			self.startTime = 0
			remaining = 1
		elseif not remaining then
			self.bIsAura = false
			self.auraEndTime = -1
			self.auraDuration = duration
			self.startTime = GetTime() - duration
		else
			self.bIsAura = false
			self.auraEndTime = remaining + GetTime()
			self.auraDuration = duration
			self.startTime = self.auraEndTime - duration
		end
	else
		self.auraEndTime = nil
		self.count:SetText()
	end

	-- Update Frame
	if self.auraEndTime ~= nil and (self.auraEndTime == 0 or self.auraEndTime >= GetTime()) then
		-- Cooldown
		if not(self.bIsAura) and (self.auraEndTime > 0) and not(self.hideTime) then
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

		-- Count
		if count and (count > 0) and not(self.hideStacks) then
			self.count:SetText(count)
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
		if not(self.isStatic) and self:IsShown() then
			self:Hide()
			AuraTracking:FreeIndicatorUpdate(self, false)
		else
			self.cd:Hide()
			self.customCD:Hide()
			self.customCDTime:Hide()
		end
	end

	if self.isStatic then
		AuraTracking:StaticIndicatorUpdate(self)
	end
end

-- Retrieve Spell Info
local function UpdateSpellInfo(self)
	if tonumber(self.info.spell) then
		self.spellID = self.info.spell
		self.spellName = (GetSpellInfo(self.info.spell))
	elseif type(self.info.spell) == "table" then
		self.trackMultiple = true
		self.spellIDs = {}
		self.spellNames = {}
		for k,v in ipairs(self.info.spell) do
			self.spellIDs[k] = v
			self.spellNames[k] = (GetSpellInfo(v))
		end
	else
		self.spellName = self.info.spell
	end
end

-- Spell validity check
local function CheckSpellValidity(self)
	if self.isDisabled then return end
	local isValid
	if self.isStatic and (self.minLevel == 0) then
		-- No Min Level specified, check if spell exists
		if self.isTrinket then
			isValid = true
		elseif self.trackMultiple then
			for k,spellID in pairs(self.spellIDs) do
				if GetSpellInfo(spellID) then
					if self.checkKnown then
						isValid = IsPlayerSpell(spellID)
					else
						isValid = true
					end
				else
					print("|cffff0000Spell |cffffffff["..spellID.."]|r|cffff0000 not valid.|r")
				end
				if isValid then break end
			end
		else
			isValid = self.spellName or GetSpellInfo(self.spellID)
			if not isValid and self.spellID then
				print("|cffff0000Spell |cffffffff["..self.spellID.."]|r|cffff0000 not valid.|r")
			end
			if self.checkKnown and isValid and self.spellID then
				isValid = IsPlayerSpell(self.spellID)
			end
		end
		
	elseif (self.minLevel > 0) then
		-- Min Level specified, are we high enough level?
		if UnitLevel("player") >= self.minLevel then
			isValid = true
		end

	else
		-- Fallback
		isValid = true
	end
	return isValid
end

-- Show/Hide based on Talent spec
local formIDs = {[CAT_FORM] = 1, [BEAR_FORM] = 2, [MOONKIN_FORM] = 3}	-- Cat, Bear, Moonkin
local function TalentUpdate(self, event, unit, initializing)
	local oldInactive = self.inactive
	
	-- Check specs
	if not self.ignoreSpec then
		local spec = GetSpecialization()
		self.inactive = not(self.specs[spec])
	end

	-- Check shapeshift forms
	if not(self.inactive) and self.forms and (nibRealUI.class == "DRUID") then
		local form = GetShapeshiftFormID()
		
		if not(self.forms[1] or self.forms[2] or self.forms[3]) then
			-- No forms, test for Human mode
			if form ~= nil then self.inactive = true end
		else
			-- Check for current form
			if not self.forms[formIDs[form]] then self.inactive = true end
		end
	end

	-- Check Spell validity
	if not(self.inactive) and self.isStatic then
		local isValid = CheckSpellValidity(self)
		self.inactive = not(isValid)
	end

	-- Update
	if not(initializing) then
		UpdateSpellInfo(self)
		if self.inactive ~= oldInactive then
			if self.isStatic then
				if not self.inactive then
					AuraUpdate(self, nil, self.unit)
				end
				AuraTracking:RefreshIndicatorAssignments()
			else
				AuraUpdate(self, nil, self.unit)
			end
		end
	end

	-- Raven Spell Lists
	if self.trackMultiple then
		for k,spellID in pairs(self.spellIDs) do
			AuraTracking:ToggleRavenAura(self.ignoreRaven, self.auraType, "#"..spellID, not(self.inactive))		
		end
	else
		AuraTracking:ToggleRavenAura(self.ignoreRaven, self.auraType, self.spellID and "#"..self.spellID or self.spellName, not(self.inactive))
	end
end

-- Target Change
local function TargetChanged(self)
	if self.unit == "target" then
		AuraUpdate(self, nil, self.unit)
	end
end

-- Pet Update
local function PetUpdate(self)
	if self.unit == "pet" then
		AuraUpdate(self, nil, self.unit)
	end
end

-- Refresh Functions
function Aura:TalentRefresh()
	TalentUpdate(self.frame, nil, nil, true)
end

function Aura:AuraRefresh()
	AuraUpdate(self.frame, nil, self.unit)

	if self.frame.isStatic then
		if self.frame.inactive then
			self.frame:Hide()
		else
			self.frame:Show()
		end
	end
end

-- Register updates
function Aura:SetUpdates()
	local f = self.frame
	f:UnregisterAllEvents()

	local hasExistingSpell = CheckSpellValidity(f)
	if not hasExistingSpell then
		if f.isStatic then f.inactive = true end
		return
	end

	-- Register Events
	f:RegisterUnitEvent("UNIT_AURA", f.unit)
	if f.unit == "target" then
		f:RegisterEvent("PLAYER_TARGET_CHANGED")
	elseif f.unit == "pet" then
		f:RegisterEvent("UNIT_PET")
	end
	
	f:SetScript("OnEvent", function(self, event, unit)
		if (event == "UNIT_AURA") then
			AuraUpdate(self, event, unit)
		elseif (event == "PLAYER_TARGET_CHANGED") then
			TargetChanged(self)
		elseif (event == "UNIT_PET") then
			PetUpdate(self)
		end
	end)
end

-- Set Indicator info
function Aura:SetIndicatorInfo(info)
	local f = self.frame
	f.info = info

	f.auraType = info.auraType or "buff"
	f.isBuff = (f.auraType == "buff")
	f.isTrinket = info.unit and info.unit == "trinket"

	if f.isBuff then
		f.unit = info.unit or "player"
	else
		f.unit = info.unit or "target"
	end
	if f.unit == "trinket" then f.unit = "player" end

	f.side = info.side
	if not f.side then
		if f.unit == "player" or f.unit == "pet" or f.unit == "trinket" then
			f.side = "LEFT" 
		else
			f.side = "RIGHT"
		end
	end

	f.specs = info.specs or {true, true, true, true}
	f.forms = info.forms
	f.minLevel = info.minLevel or 0

	f.anyone = info.anyone
	if f.isTrinket then f.anyone = true end

	UpdateSpellInfo(f)

	if not info.order then
		f.isStatic = false
	elseif info.order < 1 then
		f.isStatic = false
	else
		f.isStatic = true
	end

	f.texture = ""
	if f.isStatic then
		if f.trackMultiple then
			f.texture = select(3, GetSpellInfo(f.spellIDs[1]))
		else
			f.texture = select(3, GetSpellInfo(f.spellID or f.spellName))
		end
		f.icon:SetTexture(f.texture)
		f.icon:SetDesaturated(1)
	else
		f:Hide()
	end
	
	if info.checkKnown then
		f.checkKnown = info.checkKnown
	else
		f.checkKnown = (f.isStatic and not(f.isTrinket)) and true or false
	end

	f.hideOOC = info.hideOOC
	f.hideStacks = info.hideStacks
	f.hideTime = info.hideTime

	f.ignoreRaven = info.ignoreRaven

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
	local buffFilter = (self.isBuff and "HELPFUL" or "HARMFUL") .. (self.anyone and "" or "|PLAYER")

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

-- Create Indicator frame
function Aura:CreateIndicator()
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

-- Create new instance
function Aura:New(info)
	local Indicator = {}
	setmetatable(Indicator, {__index = self})

	Indicator:CreateIndicator()
	Indicator:SetIndicatorInfo(info)

	return Indicator
end

AuraTracking:RegisterModule(Aura, "Aura")