local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db, ndb, ndbc

local MODNAME = "RaidDebuffs"
local RaidDebuffs = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")
local SpiralBorder = nibRealUI:GetModule("SpiralBorder")

-- http://www.wowinterface.com/forums/showthread.php?p=266301 w/ some additions
local debuffs = {
	armor = {
		113746,		-- global icon (weakened armor)
	},
	dmgTaken = {
		81326,		-- global icon (pysical vulnerability)
	},
	spellDmgTaken = {
		58410,		-- rogue (master poisoner)
		1490,		-- warlock (curse of elements)
		34889,		-- pet, dragonhawk
		24844,		-- pet, windserpent
	},
	physicalDmgDone = {
		115798,		-- global icon (weakened blows)
	},
	castingSpeed = {  
		73975,		-- deathknight (necrotic strike)
		31589,		-- mage (slow)
		5761,		-- rogue (mind numbing poison)
		109466,		-- warlock (curse of enfeeblement)
		50274,		-- pet, sporebat
		90314,		-- pet, fox
		126402,		-- pet, goat
		58604,		-- pet, core hound
	},
	healingReceived = {
		115804,		-- global icon (mortal wounds)
		8680,		-- rogue (wound poison)
		82654,		-- hunter (widow venom)
		54680,		-- hunter (devilsaur: monstrous bite)
		115625,		-- warlock (wrath guard: mortal cleave)
	},
}

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Raid Debuffs",
		desc = "Track applied and missing Raid Debuffs.",
		childGroups = "tab",
		arg = MODNAME,
		-- order = 1801,
		args = {
			header = {
				type = "header",
				name = "Raid Debuffs",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Track applied and missing Raid Debuffs.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Raid Debuffs module.",
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
							RaidDebuffs:UpdateVisibility()
						end,
						order = 10,
					},
					pve = {
						type = "toggle",
						name = "In PvE",
						get = function(info) return db.show.pve end,
						set = function(info, value)
							db.show.pve = value
							RaidDebuffs:UpdateVisibility()
						end,
						order = 20,
					},
					pvp = {
						type = "toggle",
						name = "In PvP",
						get = function(info) return db.show.pvp end,
						set = function(info, value) 
							db.show.pvp = value
							RaidDebuffs:UpdateVisibility()
						end,
						order = 30,
					},
					onlyBosses = {
						type = "toggle",
						name = "Only Bosses",
						desc = "Only show when Target unit is a Boss.",
						get = function(info) return db.show.onlyBosses end,
						set = function(info, value) 
							db.show.onlyBosses = value
							RaidDebuffs:UpdateVisibility()
						end,
						order = 40,
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

local numDebuffs = 6

local function cap(str)
	return (str:gsub("^%l", string.upper))
end

function RaidDebuffs:CreateButton(i)
	local locale = LibStub("LibBabble-TalentTree-3.0"):GetLookupTable()
	local classes = {}
	local numClasses = GetNumClasses()
	local classDisplayName, classTag
	for i = 1, numClasses do
		classDisplayName, classTag = GetClassInfo(i)
		classes[classTag] = "|cff"..nibRealUI:ColorTableToStr(nibRealUI:GetClassColor(classTag))..classDisplayName.."|r"
	end

	local STR_ANY = cap(SPELL_TARGET_TYPE1_DESC)
	local STR_PET = cap(PET)
	
	local strAny = "%s %s"							-- STR_ANY DRUID
	local strPet = "%s %s |cffffffff(%s: %s)|r"		-- STR_ANY WARLOCK (STR_PET: Imp)
	local strBeastMaster = classes["HUNTER"]..": |cffffffff"..locale["Beast Mastery"].." ("..STR_PET..": ".."%s)|r"
	local strSpec1 = "%s: |cffffffff%s|r"			-- Shaman: Enhancement
	local strSpec2 = "%s: |cffffffff%s, %s|r"		-- DK: frost, unholy

	local btn = CreateFrame("Frame", "RealUIRaidDebuff"..i, self.rdF)
	
	if i == 1 then
		btn.icon =  "Interface\\ICONS\\ability_warrior_sunder"
		btn.desc = ARMOR_TEMPLATE:format("-12%") --"-12% armor"
		btn.given = {
			strAny:format(STR_ANY, classes["DRUID"]),
			strAny:format(STR_ANY, classes["ROGUE"]),
			strAny:format(STR_ANY, classes["WARRIOR"]),
			strPet:format(STR_ANY, classes["HUNTER"], STR_PET, "Tallstrider, Raptor"),
		}
	elseif i == 2 then
		btn.icon = "Interface\\ICONS\\ability_warrior_colossussmash"
		btn.desc = "+4% "..DAMAGE.." ("..cap(SPELL_SCHOOL0_NAME)..")" --"+4% dmg taken"
		btn.given = {
			strSpec2:format(classes["DEATHKNIGHT"], locale["Frost"], locale["Unholy"]),
			strSpec1:format(classes["PALADIN"], locale["Retribution"]),
			strSpec2:format(classes["WARRIOR"], locale["Arms"], locale["Fury"]),
			strPet:format(STR_ANY, classes["HUNTER"], STR_PET, "Boar, Ravager"),
			strBeastMaster:format("Rhino, Worm"),
		}
	elseif i == 3 then
		btn.icon = "Interface\\ICONS\\warlock_curse_shadow"
		btn.desc = "+5% "..DAMAGE.." ("..cap(SPELL_SCHOOLMAGICAL)..")" --"+5% spell dmg taken"
		btn.given = {
			strAny:format(STR_ANY, classes["ROGUE"]),
			strAny:format(STR_ANY, classes["WARLOCK"]),
			strPet:format(STR_ANY, classes["HUNTER"], STR_PET, "Dragonhawk, Wind Serpent"),
			
		}
	elseif i == 4 then
		btn.icon = "Interface\\ICONS\\spell_nature_thunderclap"
		btn.desc = "-10% "..cap(string.lower(string.gsub(SCORE_DAMAGE_DONE, "\n", " "))).." ("..cap(SPELL_SCHOOL0_NAME)..")" --"-10% physical dmg done"
		btn.given = {
			strSpec1:format(classes["DEATHKNIGHT"], locale["Blood"]),
			strSpec2:format(classes["DRUID"], locale["Feral"], locale["Guardian"]),
			strSpec1:format(classes["MONK"], locale["Brewmaster"]),
			strSpec2:format(classes["PALADIN"], locale["Protection"], locale["Retribution"]),
			strAny:format(STR_ANY, classes["SHAMAN"]),
			strAny:format(STR_ANY, classes["WARLOCK"]),
			strAny:format(STR_ANY, classes["WARRIOR"]),
			strPet:format(STR_ANY, classes["HUNTER"], STR_PET, "Bear, Carrion Bird"),
		}	
	elseif i == 5 then
		btn.icon = "Interface\\ICONS\\spell_nature_nullifydisease"
		btn.desc = STAT_HASTE_SPELL_TOOLTIP.." (-30%)" --"-30% casting speed"
		btn.given = {
			strAny:format(STR_ANY, classes["DEATHKNIGHT"]),
			strSpec1:format(classes["MAGE"], locale["Arcane"]),
			strAny:format(STR_ANY, classes["ROGUE"]),
			strAny:format(STR_ANY, classes["WARLOCK"]),
			strPet:format(STR_ANY, classes["HUNTER"], STR_PET, "Sporebat, Fox, Goat"),
			strBeastMaster:format("Core Hound"),
		}
	elseif i == 6 then
		btn.icon = "Interface\\ICONS\\ability_warrior_savageblow"
		btn.desc = "-25% "..SHOW_COMBAT_HEALING--"-25% healing received"
		btn.given = {
			strSpec2:format(classes["WARRIOR"], locale["Arms"], locale["Fury"]),
			strAny:format(STR_ANY, classes["ROGUE"]),
			strAny:format(STR_ANY, classes["HUNTER"]),
			strSpec1:format(classes["MONK"], locale["Windwalker"]),
			strBeastMaster:format("Devilsaur"),
		}
	end
	
	if db.tooltip then
		btn:SetScript("OnEnter", function(self) 
			GameTooltip:SetOwner(self, "ANCHOR_TOPLEFT")
			GameTooltip:ClearLines()
			GameTooltip:AddLine(self.desc)
			if not InCombatLockdown() then
				for i = 1, #btn.given do
					GameTooltip:AddLine("|cffffffff"..btn.given[i].."|r")
				end
			end
			GameTooltip:Show()
		end)
			
		btn:SetScript("OnLeave", function(self) 
			GameTooltip:Hide()
		end)
	end
	
	btn:SetHeight(23)
	btn:SetWidth(23)
	btn.bg = btn:CreateTexture(nil, "BACKGROUND")
	btn.bg:SetAllPoints(btn)
	btn.bg:SetTexture(btn.icon)
	btn.bg:SetTexCoord(.08, .92, .08, .92)

	nibRealUI:CreateBDFrame(btn)

	btn:Show()
	
	return btn
end	

function RaidDebuffs:CreateFrames()
	self.rdF = CreateFrame("Frame", "RealUIRaidDebuffs", UIParent)

	local x = db.position.x
	
	self.rdF:SetParent(db.position.parent)
	self.rdF:SetPoint(db.position.point, db.position.parent, db.position.rPoint, x, db.position.y)
	self.rdF:SetFrameStrata("MEDIUM")
	self.rdF:SetFrameLevel(5)
	self.rdF:SetSize(179, 1)

	for i = 1, numDebuffs do
		self.rdF[i] = self:CreateButton(i)
		self.rdF[i]:Hide()
		SpiralBorder:AttachSpiral(self.rdF[i], -3, false)

		if i == 1 then
			self.rdF[i]:SetPoint("BOTTOMLEFT", self.rdF, "BOTTOMLEFT", 0, 0)
		else
			self.rdF[i]:SetPoint("BOTTOMLEFT", self.rdF[i-1], "BOTTOMRIGHT", 7, 0)
		end
	end

	self.rdF.visible = false

	if nibRealUI:GetModuleEnabled(MODNAME) then
		self:GroupUpdate()
		self:PLAYER_TARGET_CHANGED()
	end
end

----

local debuffReference = {
	[1] = debuffs.armor,
	[2] = debuffs.dmgTaken,
	[3] = debuffs.spellDmgTaken,
	[4] = debuffs.physicalDmgDone,
	[5] = debuffs.castingSpeed,
	[6] = debuffs.healingReceived,
}
local function GetRaidDebuff(i)
	if i > numDebuffs then
		return nil, nil, nil
	end

	local longestDebuff = {nil, 0, 0}
	local debuffTable = debuffReference[i]
	for x = 1, #debuffTable do
		local name, _, _, _, _, duration, expirationTime = UnitDebuff("Target", (GetSpellInfo(debuffTable[x])))
		if expirationTime and expirationTime > longestDebuff[2] then
			longestDebuff = {name, expirationTime, duration}
		end
	end

	if longestDebuff[1] then
		return longestDebuff[1], longestDebuff[2], longestDebuff[3]
	else
		return nil, nil, nil
	end
end

function RaidDebuffs:AuraUpdate(units)
	if not self.rdF.visible then return end
	if not(units) or not(units.target) then return end

	for i = 1, numDebuffs do
		local name, expirationTime, duration = GetRaidDebuff(i)
		if name then
			self.rdF[i].bg:SetDesaturated(nil)
			if expirationTime then
				self.rdF[i].duration = duration
				self.rdF[i].startTime = expirationTime - duration
				self.rdF[i].offsetTime = 0
			else
				self.rdF[i].duration = 0
				self.rdF[i].startTime = 0
				self.rdF[i].offsetTime = 0
				self.rdF[i].endTime = nil
			end
		else
			self.rdF[i].bg:SetDesaturated(1)
			self.rdF[i].duration = 0
			self.rdF[i].startTime = 0
			self.rdF[i].offsetTime = 0
			self.rdF[i].endTime = nil
		end
	end
end

local function SetRavenDebuffCount(shown)
	local prof = ndbc.resolution == 1 and "RealUI" or "RealUI-HR"

	if RavenDB["profiles"][prof]["BarGroups"]["TargetDebuffs"] then
		RavenDB["profiles"][prof]["BarGroups"]["TargetDebuffs"]["maxBars"] = shown and 8 or 10
	end
end

function RaidDebuffs:UpdateVisibility()
	local show
	if 		not(self.rdF.target) or
			(db.show.onlyBosses and not(self.rdF.targetBoss)) then
				show = false

	elseif 	(db.show.solo) or
			(db.show.pve and self.rdF.pve) or
			(db.show.pvp and self.rdF.pvp) then
				show = true
	end

	if not(show) then
		if self.rdF.visible then
			self.rdF.visible = false
			self.rdF:SetHeight(1)
			for i = 1, numDebuffs do
				self.rdF[i]:Hide()
			end
			-- SetRavenDebuffCount(false)
		end
	else
		if not(self.rdF.visible) then
			self.rdF.visible = true
			self.rdF:SetHeight(31)
			for i = 1, numDebuffs do
				self.rdF[i]:Show()
			end
			-- SetRavenDebuffCount(true)
			self:AuraUpdate({target = 1})
		end
	end
end

function RaidDebuffs:PLAYER_TARGET_CHANGED()
	if not(UnitExists("target")) or not(UnitCanAttack("player", "target")) or UnitIsDeadOrGhost("target") then
		self.rdF.target = false
		self.rdF.targetBoss = false
	else
		self.rdF.target = true
		self.rdF.targetBoss = UnitLevel("target") == -1
	end
	self:UpdateVisibility()
	self:AuraUpdate({target = 1})
end

function RaidDebuffs:GroupUpdate()
	self.rdF.inGroup = GetNumGroupMembers() > 0
	self:UpdateVisibility()
end

function RaidDebuffs:PLAYER_ENTERING_WORLD()
	local Inst, InstType = IsInInstance()
	if (InstType == "pvp") or (InstType == "arena") then
		self.rdF.pvp = true
	elseif (InstType == "party") or (InstType == "raid") then
		self.rdF.pve = true
	else
		self.rdF.pve = false
		self.rdF.pvp = false
	end
	self:UpdateVisibility()
end

function RaidDebuffs:PLAYER_LOGIN()
	self:CreateFrames()

	if not nibRealUI:GetModuleEnabled(MODNAME) then return end

	local auraUpdateSpeed
	if ndb.settings.powerMode == 1 then
		auraUpdateSpeed = 1
	elseif ndb.settings.powerMode == 2 then
		auraUpdateSpeed = 2
	else
		auraUpdateSpeed = 0.5
	end
	self:RegisterBucketEvent("UNIT_AURA", auraUpdateSpeed, "AuraUpdate")
	self:RegisterBucketEvent("GROUP_ROSTER_UPDATE", 0.5, "GroupUpdate")
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:UpdateVisibility()
end

----
function RaidDebuffs:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			tooltip = true,
			show = {
				solo = false,
				pvp = false,
				pve = true,
				onlyBosses = true,
			},
			position = {
				parent = "oUF_RealUITarget_Overlay",
				point = "BOTTOMLEFT",
				rPoint = "RIGHT",
				x = -19,
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

function RaidDebuffs:OnEnable()
	numDebuffs = (db.show.bosses and not(db.show.solo or db.show.pvp or db.show.pve)) and 4 or 6

	self:RegisterEvent("PLAYER_ENTERING_WORLD")
end

function RaidDebuffs:OnDisable()
	self:UnregisterAllEvents()
	self:UnregisterAllBuckets()
end