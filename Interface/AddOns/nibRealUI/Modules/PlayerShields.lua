local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndb, ndbc

local MODNAME = "PlayerShields"
local PlayerShields = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")
local SpiralBorder = nibRealUI:GetModule("SpiralBorder")

local buffs = {
	PWS = 17,
	IlluminatedHealing = 86273,
	DivineAegis = 47753,
	SpiritShell = 114908,
	Guard = 118604,
}
local spellInfo = {}

local icons = {
	[[Interface\ICONS\Spell_Holy_PowerWordShield]],
	[[Interface\ICONS\Spell_Holy_Absolution]],
	[[Interface\ICONS\Spell_Holy_DevineAegis]],
	[[Interface\ICONS\Ability_Shaman_AstralShift]],
	[[Interface\ICONS\Ability_Monk_Guard]],
}

local tankSpecs = {
	["DEATHKNIGHT"] = 1,
	["DRUID"] = 3,
	["MONK"] = 1,
	["PALADIN"] = 2,
	["WARRIOR"] = 3,
}

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Player Shields",
		desc = "Tracks absorbs/shields on the player.",
		childGroups = "tab",
		arg = MODNAME,
		args = {
			header = {
				type = "header",
				name = "Player Shields",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Tracks absorbs/shields on the player.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Player Shields module.",
				get = function() return nibRealUI:GetModuleEnabled(MODNAME) end,
				set = function(info, value) 
					nibRealUI:SetModuleEnabled(MODNAME, value)			
				end,
				order = 30,
			},
			gap1 = {
				name = " ",
				type = "description",
				order = 31,
			},
			show = {
				name = "Show",
				type = "group",
				inline = true,
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 40,
				args = {
					solo = {
						type = "toggle",
						name = "While Solo",
						get = function(info) return db.show.solo end,
						set = function(info, value) 
							db.show.solo = value
							PlayerShields:UpdateVisibility()
						end,
						order = 10,
					},
					pve = {
						type = "toggle",
						name = "In PvE",
						get = function(info) return db.show.pve end,
						set = function(info, value)
							db.show.pve = value
							PlayerShields:UpdateVisibility()
						end,
						order = 20,
					},
					pvp = {
						type = "toggle",
						name = "In PvP",
						get = function(info) return db.show.pvp end,
						set = function(info, value) 
							db.show.pvp = value
							PlayerShields:UpdateVisibility()
						end,
						order = 30,
					},
					onlyTank = {
						type = "toggle",
						name = "Only Role = Tank",
						get = function(info) return db.show.onlyTank end,
						set = function(info, value) 
							db.show.onlyTank = value
							PlayerShields:UpdateVisibility()
						end,
						order = 40,
					},
					onlySpec = {
						type = "toggle",
						name = "Only Spec = Tank",
						get = function(info) return db.show.onlySpec end,
						set = function(info, value) 
							db.show.onlySpec = value
							PlayerShields:UpdateVisibility()
						end,
						order = 50,
					},
				},
			},
			gap2 = {
				name = " ",
				type = "description",
				order = 41,
			},
			sizeposition = {
				name = "Size/Position",
				type = "group",
				inline = true,
				disabled = function() if nibRealUI:GetModuleEnabled(MODNAME) then return false else return true end end,
				order = 50,
				args = {
					parent = {
						type = "input",
						name = "Parent",
						width = "double",
						order = 10,
						get = function(info) return tostring(db.position.parent) end,
						set = function(info, value)
							db.position.parent = value
						end,
					},
					gap1 = {
						name = " ",
						type = "description",
						order = 11,
					},
					rPoint = {
						type = "select",
						name = "Anchor To",
						get = function(info) 
							for k,v in pairs(nibRealUI.globals.anchorPoints) do
								if v == db.position.rPoint then return k end
							end
						end,
						set = function(info, value)
							db.position.rPoint = nibRealUI.globals.anchorPoints[value]
						end,
						style = "dropdown",
						width = nil,
						values = nibRealUI.globals.anchorPoints,
						order = 20,
					},
					point = {
						type = "select",
						name = "Anchor From",
						get = function(info) 
							for k,v in pairs(nibRealUI.globals.anchorPoints) do
								if v == db.position.point then return k end
							end
						end,
						set = function(info, value)
							db.position.point = nibRealUI.globals.anchorPoints[value]
						end,
						style = "dropdown",
						width = nil,
						values = nibRealUI.globals.anchorPoints,
						order = 30,
					},
					x = {
						type = "input",
						name = "X",
						width = "half",
						order = 40,
						get = function(info) return tostring(db.position.x) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.position.x = value
						end,
					},
					y = {
						type = "input",
						name = "Y",
						width = "half",
						order = 50,
						get = function(info) return tostring(db.position.y) end,
						set = function(info, value)
							value = nibRealUI:ValidateOffset(value)
							db.position.y = value
						end,
					},
				},
			},
		},
	}
	end
	return options
end

local function TimeFormat(t)
	local h, m, hplus, mplus, s, ts, f

	h = math.floor(t / 3600)
	m = math.floor((t - (h * 3600)) / 60)
	s = math.floor(t - (h * 3600) - (m * 60))

	hplus = math.floor((t + 3599.99) / 3600)
	mplus = math.floor((t - (h * 3600) + 59.99) / 60) -- provides compatibility with tooltips

	if t >= 3600 then
		f = string.format("%.0fh", hplus)
	elseif t >= 60 then
		f = string.format("%.0fm", mplus)
	else
		f = string.format("%.0fs", s)
	end

	return f
end

function PlayerShields:CreateButton(i)
	local btn = CreateFrame("Frame", "RealUIPlayerShields"..i, self.psF)
		nibRealUI:CreateBDFrame(btn)
		btn:SetHeight(23)
		btn:SetWidth(23)
	
	btn.bg = btn:CreateTexture(nil, "BACKGROUND")
		btn.bg:SetAllPoints(btn)
		btn.bg:SetTexture(icons[i])
		btn.bg:SetTexCoord(.08, .92, .08, .92)

	btn.absorbBar = CreateFrame("StatusBar", nil, btn)
		btn.absorbBar:SetMinMaxValues(0, 1)
		btn.absorbBar:SetValue(0)
		btn.absorbBar:SetStatusBarTexture(nibRealUI.media.textures.plain)
		btn.absorbBar:SetStatusBarColor(0, 0, 0, 0.75)
		btn.absorbBar:SetReverseFill(true)
		btn.absorbBar:SetAllPoints(btn)
		btn.absorbBar:SetFrameLevel(btn:GetFrameLevel() + 1)

	btn.timeStr = btn:CreateFontString(nil, "OVERLAY")
		btn.timeStr:SetFont(unpack(nibRealUI.font.pixel1))
		btn.timeStr:SetJustifyH("LEFT")
		btn.timeStr:SetPoint("BOTTOMLEFT", btn, "BOTTOMLEFT", 0.5, 0.5)
		btn.timeStr:SetParent(btn.absorbBar)

	btn.elapsed = 0
	btn.interval = 1/4
	btn:SetScript("OnUpdate", function(self, elapsed)
		self.elapsed = self.elapsed + elapsed
		if self.elapsed >= self.interval then
			self.elapsed = 0
			if self.startTime and self.endTime then
				self.timeStr:SetText(TimeFormat(ceil(self.endTime - GetTime())))
			else
				self.timeStr:SetText()
			end
		end
	end)

	btn:Show()
	
	return btn
end	

function PlayerShields:CreateFrames()
	self.psF = CreateFrame("Frame", "RealUIPlayerShields", UIParent)

	self.psF:SetParent(db.position.parent)
	self.psF:SetPoint(db.position.point, db.position.parent, db.position.rPoint, db.position.x, db.position.y)
	self.psF:SetFrameStrata("MEDIUM")
	self.psF:SetFrameLevel(5)
	self.psF:SetSize(149, 1)

	self.psF.absorbTotal = 0

	for i = 1, 5 do
		self.psF[i] = self:CreateButton(i)
		self.psF[i]:Hide()
		self.psF[i].absorbAmount = 0
		self.psF[i].absorbMax = math.huge
		self.psF[i].needMaxUpdate = true

		if i == 1 then
			self.psF[i]:SetPoint("BOTTOMRIGHT", self.psF, "BOTTOMRIGHT", 0, 0)
		else
			self.psF[i]:SetPoint("BOTTOMRIGHT", self.psF[i-1], "BOTTOMLEFT", -7, 0)
		end

		SpiralBorder:AttachSpiral(self.psF[i], -3, false)
	end

	self.psF.strTotal = self.psF:CreateFontString(nil, "OVERLAY")
		self.psF.strTotal:SetFont(nibRealUI.font.pixel1[1], nibRealUI.font.pixel1[2] * 2, nibRealUI.font.pixel1[3])
		self.psF.strTotal:SetJustifyH("RIGHT")
		self.psF.strTotal:SetPoint("BOTTOMRIGHT", self.psF, "BOTTOMLEFT", 2.5, -2.5)

	self.psF.strTotalPer = self.psF:CreateFontString(nil, "OVERLAY")
		self.psF.strTotalPer:SetFont(unpack(nibRealUI.font.pixel1))
		self.psF.strTotalPer:SetJustifyH("RIGHT")
		self.psF.strTotalPer:SetPoint("TOPRIGHT", self.psF, "TOPLEFT", 2.5, -6.5)

	self.psF.visible = false

	if nibRealUI:GetModuleEnabled(MODNAME) then
		self:GroupUpdate()
	end
end

----

function PlayerShields:UpdateAbsorbDisplay()
	self.psF.absorbTotal = 0
	for i = 1, 5 do
		self.psF.absorbTotal = self.psF.absorbTotal + self.psF[i].absorbAmount
	end
	if self.psF.absorbTotal > 0 and self.psF.active then
		self.psF.strTotal:SetText(nibRealUI:ReadableNumber(self.psF.absorbTotal))
		self.psF.strTotalPer:SetText(string.format("%.0f%%", (self.psF.absorbTotal / UnitHealthMax("player")) * 100))
		if not(self.psF.visible) then self:UpdateVisibility() end
	else
		self.psF.strTotal:SetText()
		self.psF.strTotalPer:SetText()
		if self.psF.active and self.psF.visible then self:UpdateVisibility() end
	end
end

local buffIDs = {
	[buffs.PWS] = 1,
	[buffs.IlluminatedHealing] = 2,
	[buffs.DivineAegis] = 3,
	[buffs.SpiritShell] = 4,
	[buffs.Guard] = 5,
}
local shieldInfo = {}
local function GetShieldInfo()
	shieldInfo = {}
	for i = 1, 40 do
		local name,_,_,_,_, duration, expirationTime,_,_,_, spellID,_,_,_, absorb = UnitAura("player", i)
		if not name then break end
		if buffIDs[spellID] then
			shieldInfo[buffIDs[spellID]] = {name, duration, expirationTime, absorb}
		end
	end
end

function PlayerShields:AuraUpdate(units)
	if not self.psF.active then return end
	if not(units) or not(units.player) then return end

	GetShieldInfo()
	for i = 1, 5 do
		local name, duration, expirationTime, absorb
		if shieldInfo[i] then
			name, duration, expirationTime, absorb = shieldInfo[i][1], shieldInfo[i][2], shieldInfo[i][3], shieldInfo[i][4]
		end
		if name then
			-- Icon
			self.psF[i].bg:SetDesaturated(nil)
			self.psF[i].bg:SetVertexColor(1, 1, 1)

			-- Cooldown
			if expirationTime then
				self.psF[i].duration = duration
				self.psF[i].startTime = expirationTime - duration
				self.psF[i].offsetTime = 0
			else
				self.psF[i].duration = 0
				self.psF[i].startTime = 0
				self.psF[i].offsetTime = 0
				self.psF[i].endTime = nil
			end

			-- Absorb
			if absorb then
				if self.psF[i].needMaxUpdate then
					self.psF[i].needMaxUpdate = false
					self.psF[i].absorbMax = absorb
					self.psF[i].absorbBar:SetMinMaxValues(0, absorb)
				end
				self.psF[i].absorbAmount = absorb
				self.psF[i].absorbBar:SetValue(self.psF[i].absorbMax - absorb)
				self.psF[i].absorbBar:Show()
			end

		else
			-- Icon
			self.psF[i].bg:SetDesaturated(1)
			self.psF[i].bg:SetVertexColor(0.8, 0.8, 0.8)

			-- Reset Cooldown
			self.psF[i].duration = 0
			self.psF[i].startTime = 0
			self.psF[i].offsetTime = 0
			self.psF[i].endTime = nil
		end
	end

	self:UpdateAbsorbDisplay()
end

function PlayerShields:UNIT_ABSORB_AMOUNT_CHANGED(_, unit)
	if not self.psF.active then return end
	if unit ~= "player" then return end

	self:AuraUpdate({player = 1})
end

function PlayerShields:COMBAT_LOG_EVENT_UNFILTERED(_, timestamp, event, hideCaster, sourceGUID, sourceName, sourceFlags, sourceFlags2, destGUID, destName, destFlags, destFlags2, spellID, spellName, ...)
	if not self.psF.active then return end
	if destGUID ~= self.guid then return end

	if event == "SPELL_AURA_REMOVED" then
		if buffIDs[spellID] then
			self.psF[buffIDs[spellID]].absorbAmount = 0
			self.psF[buffIDs[spellID]].needMaxUpdate = true
			self.psF[buffIDs[spellID]].absorbBar:Hide()
			self:UpdateAbsorbDisplay()
		end

	elseif event == "SPELL_AURA_APPLIED" then
		if buffIDs[spellID] then
			self.psF[buffIDs[spellID]].needMaxUpdate = true
		end
	end
end

function PlayerShields:UpdateVisibility()
	local show
	if		(db.show.onlySpec) and not(tankSpecs[nibRealUI.class] == (self.psF.spec)) or
			(db.show.onlyRole) and not(self.psF.tankRole) then
				show = false

	elseif 	(db.show.solo) or
			(db.show.pve and self.psF.pve) or
			(db.show.pvp and self.psF.pvp) then
				show = true
	end
	self.psF.active = show

	if (self.psF.absorbTotal <= 0) then show = false end

	if not(show) then
		if self.psF.visible then
			self.psF.visible = false
			self.psF:SetHeight(1)
			for i = 1, 5 do
				self.psF[i]:Hide()
			end
			self.psF.strTotal:SetText()
			self.psF.strTotalPer:SetText()
		end
	else
		if not(self.psF.visible) then
			self.psF.visible = true
			self.psF:SetHeight(31)
			for i = 1, 5 do
				self.psF[i]:Show()
			end
			self:AuraUpdate({player = 1})
		end
	end

	self:ToggleRaven(self.psF.active)
end

function PlayerShields:RoleCheck()
	if	(UnitGroupRolesAssigned("player") == "TANK") or
		GetPartyAssignment("MAINTANK", "player") or 
		GetPartyAssignment("MAINASSIST", "player") then
			self.psF.tankRole = true
	else
			self.psF.tankRole = false
	end
end

function PlayerShields:GroupUpdate()
	self.psF.inGroup = GetNumGroupMembers() > 0
	self:RoleCheck()
	self:UpdateVisibility()
end

function PlayerShields:SpecUpdate()
	self.psF.spec = GetSpecialization() or 0
	self:UpdateVisibility()
end

function PlayerShields:PLAYER_ENTERING_WORLD()
	self.guid = UnitGUID("player")

	local Inst, InstType = IsInInstance()
	if (InstType == "pvp") or (InstType == "arena") then
		self.psF.pvp = true
	elseif (InstType == "party") or (InstType == "raid") then
		self.psF.pve = true
	else
		self.psF.pve = false
		self.psF.pvp = false
	end
	
	self:RoleCheck()
	self:UpdateVisibility()
end

function PlayerShields:PLAYER_LOGIN()
	self.guid = 0
	spellInfo[1] = GetSpellInfo(buffs.PWS)
	spellInfo[2] = GetSpellInfo(buffs.IlluminatedHealing)
	spellInfo[3] = GetSpellInfo(buffs.DivineAegis)
	spellInfo[4] = GetSpellInfo(buffs.SpiritShell)
	spellInfo[5] = GetSpellInfo(buffs.Guard)

	self:CreateFrames()

	if not nibRealUI:GetModuleEnabled(MODNAME) then return end

	local auraUpdateSpeed
	if ndb.settings.powerMode == 1 then
		auraUpdateSpeed = 0.5
	elseif ndb.settings.powerMode == 2 then
		auraUpdateSpeed = 1
	else
		auraUpdateSpeed = 0.25
	end
	self:RegisterBucketEvent("UNIT_AURA", auraUpdateSpeed, "AuraUpdate")
	self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 0.5, "GroupUpdate")
	self:RegisterEvent("COMBAT_LOG_EVENT_UNFILTERED")
	self:RegisterEvent("UNIT_ABSORB_AMOUNT_CHANGED")

	self:SpecUpdate()
end

function PlayerShields:ToggleRaven(val)
	if IsAddOnLoaded("Raven") and RavenDB then
		if RavenDB["global"]["SpellLists"]["PlayerExclusions"] then
			RavenDB["global"]["SpellLists"]["PlayerExclusions"]["#"..buffs.PWS] = val
			RavenDB["global"]["SpellLists"]["PlayerExclusions"]["#"..buffs.IlluminatedHealing] = val
			RavenDB["global"]["SpellLists"]["PlayerExclusions"]["#"..buffs.DivineAegis] = val
			RavenDB["global"]["SpellLists"]["PlayerExclusions"]["#"..buffs.SpiritShell] = val
			RavenDB["global"]["SpellLists"]["PlayerExclusions"]["#"..buffs.Guard] = val
		end
	end
end

----
function PlayerShields:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			show = {
				solo = false,
				pvp = true,
				pve = true,
				onlyRole = false,
				onlySpec = true,
			},
			position = {
				parent = "oUF_RealUIPlayer_Overlay",
				point = "BOTTOMRIGHT",
				rPoint = "LEFT",
				x = 19,
				y = 20,
			},
		},
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile
	ndbc = nibRealUI.db.char
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterModuleOptions(MODNAME, GetOptions)

	self:RegisterEvent("PLAYER_LOGIN")
end

function PlayerShields:OnEnable()
	self:RegisterEvent("PLAYER_ENTERING_WORLD")
	self:RegisterEvent("ACTIVE_TALENT_GROUP_CHANGED", "SpecUpdate")
end

function PlayerShields:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllBuckets()

	self:ToggleRaven(false)
end