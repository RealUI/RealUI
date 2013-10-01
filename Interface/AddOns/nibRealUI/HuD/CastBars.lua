local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local L = LibStub("AceLocale-3.0"):GetLocale("nibRealUI")
local db, ndb

local _
local MODNAME = "CastBars"
local CastBars = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceTimer-3.0")

local AngleStatusBar = nibRealUI:GetModule("AngleStatusBar")

local layoutSize

local Textures = {
	[1] = {
		player = {
			surround = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Surround]],
			bar = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Bar]],
			tick = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Tick]],
		},
		target = {
			surround = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Surround]],
			bar = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Bar]],
		},
		focus = {
			surround = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Small_Surround]],
			bar = [[Interface\AddOns\nibRealUI\Media\CastBars\1\CastBar_Small_Bar]],
		},
	},
	[2] = {
		player = {
			surround = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Surround]],
			bar = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Bar]],
			tick = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Tick]],
		},
		target = {
			surround = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Surround]],
			bar = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Bar]],
		},
		focus = {
			surround = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Small_Surround]],
			bar = [[Interface\AddOns\nibRealUI\Media\CastBars\2\CastBar_Small_Bar]],
		},
	},
}

local CastBarXOffset = {
	[1] = 5,
	[2] = 6,
}

local MaxTicks = 10
local ChannelingTicks = {
	-- Druid
	[GetSpellInfo(16914)] = 10,	-- Hurricane
	[GetSpellInfo(106996)] = 10,-- Astral Storm
	[GetSpellInfo(740)] = 4,	-- Tranquility
	-- Mage
	[GetSpellInfo(5143)] = 5,	-- Arcane Missiles
	[GetSpellInfo(10)] = 8,		-- Blizzard
	[GetSpellInfo(12051)] = 3,	-- Evocation
	-- Priest
	[GetSpellInfo(64843)] = 4,	-- Divine Hymn
	[GetSpellInfo(64901)] = 4,	-- Hymn of Hope
	[GetSpellInfo(15407)] = 3,	-- Mind Flay
	[GetSpellInfo(129197)] = 3,	-- Mind Flay (Insanity)
	[GetSpellInfo(32000)] = 5,	-- Mind Sear
	[GetSpellInfo(47540)] = 2,	-- Penance
	-- Warlock
	[GetSpellInfo(1120)] = 6,	-- Drain Soul
	[GetSpellInfo(689)] = 6,	-- Drain Life
	[GetSpellInfo(755)] = 6,	-- Health Funnel
	[GetSpellInfo(4629)] = 6,	-- Rain of Fire
	[GetSpellInfo(103103)] = 6,	-- Malefic Grasp
	[GetSpellInfo(108371)] = 6,	-- Harvest Life
}

-- Options
local options
local function GetOptions()
	if not options then options = {
		type = "group",
		name = "Cast Bars",
		desc = "Player, Target and Focus casting bars.",
		arg = MODNAME,
		childGroups = "tab",
		args = {
			header = {
				type = "header",
				name = "Cast Bars",
				order = 10,
			},
			desc = {
				type = "description",
				name = "Player, Target and Focus casting bars.",
				fontSize = "medium",
				order = 20,
			},
			enabled = {
				type = "toggle",
				name = "Enabled",
				desc = "Enable/Disable the Cast Bars module.",
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
			reverse = {
				name = "Direction",
				type = "group",
				inline = true,
				order = 40,
				args = {
					player = {
						type = "toggle",
						name = "Reverse Player",
						desc = "Reverse direction of Player cast bar.",
						get = function() return db.reverse.player end,
						set = function(info, value) 
							db.reverse.player = value
							CastBars:UpdateAnchors()
						end,
						order = 10,
					},
					target = {
						type = "toggle",
						name = "Reverse Target",
						desc = "Reverse direction of Target cast bar.",
						get = function() return db.reverse.target end,
						set = function(info, value) 
							db.reverse.target = value
							CastBars:UpdateAnchors()
						end,
						order = 10,
					},
				},
			},
			gap2 = {
				name = " ",
				type = "description",
				order = 41,
			},
			text = {
				name = "Text",
				type = "group",
				inline = true,
				order = 50,
				args = {
					textInside = {
						type = "toggle",
						name = "Inside",
						desc = "Spell Name and Time text displayed on the inside.",
						get = function() return db.text.textInside end,
						set = function(info, value) 
							db.text.textInside = value
							CastBars:UpdateAnchors()
						end,
						order = 10,
					},
					textOnBottom = {
						type = "toggle",
						name = "On Bottom",
						desc = "Spell Name and Time text displayed below the cast bars.",
						get = function() return db.text.textOnBottom end,
						set = function(info, value) 
							db.text.textOnBottom = value
							CastBars:UpdateAnchors()
						end,
						order = 20,
					},
				},
			},
		},
	}
	end
	return options
end

local FontStringsSmall = {}
local FontStringsRegular = {}
local FontStringsNumbers = {}

local MaxNameLengths = {
	player = 26,
	vehicle = 26,
	target = 26,
	focus = 20,
}

local UpdateSpeed = 1/60

-- Chanelling Ticks
function CastBars:ClearTicks()
	for i = 1, MaxTicks do
		self.player.tick[i]:Hide()
	end
end

function CastBars:SetTick(index, per)
	self.player.tick[index]:SetPoint("TOPRIGHT", self.player, "TOPRIGHT", floor(-(db.size[layoutSize].width * per)), 0)
	self.player.tick[index]:Show()
end

function CastBars:SetBarTicks(ticks)
	self:ClearTicks()
	if ticks and ticks > 0 then
		for i = 1, ticks do
			self:SetTick(i, (i-1) / ticks)
		end
	end
end

-- Range Check
function CastBars:TargetInRange()
	local bCheckRange = true
	local inRange

	if not(self.player.current) or not(UnitExists("target")) then
		return true
	elseif not(UnitIsVisible("target")) then
		return false
	else
		inRange = IsSpellInRange(self.player.current, "target")
		if inRange == nil then
			return true
		end
		if inRange == 0 then
			return false
		else
			return true
		end
	end
end

----
-- Bar Updates
----
function CastBars:FlashBar(unit, alpha, text)
	self[unit]:SetAlpha(alpha)

	self[unit].color = "flash"
	AngleStatusBar:SetBarColor(self[unit].cast.bar, {1, 0, 0, 1})
	self[unit].name.text:SetTextColor(1, 0, 0, 1)

	AngleStatusBar:SetValue(self[unit].cast.bar, 0.01)
	self[unit].time.text:SetText("")
	self[unit].name.text:SetText(text)
end

function CastBars:OnUpdate(unit, elapsed)
	if self.configMode then return end

	-- safety catch
	if (self[unit].action == "NONE") then
		self:StopBar()
		return
	end

	-- Throttle updates
	if (unit == "focus") then elapsed = elapsed * 0.75 end
	self[unit].elapsed = self[unit].elapsed + elapsed
	if self[unit].elapsed < UpdateSpeed then
		return
	else
		self[unit].elapsed = 0
	end

	-- handle casting and channeling
	if (self[unit].action == "CAST" or self[unit].action == "CHANNEL") then
		local remainingTime = self[unit].actionStartTime + self[unit].actionDuration - GetTime()
		
		local perCast = (self[unit].actionDuration ~= 0 and remainingTime / self[unit].actionDuration or 0)
		-- Reverse channeling
		if (self[unit].action == "CHANNEL") then
			perCast = 1 - (self[unit].actionDuration ~= 0 and remainingTime / self[unit].actionDuration or 0)
		end
		perCast = nibRealUI:Clamp(perCast, 0, 1)

		-- Set Cast Bar
		AngleStatusBar:SetValue(self[unit].cast.bar, perCast)

		-- Reposition Latency if overlapping
		if (unit == self.player.unit) and (self[unit].action == "CHANNEL") then
			if perCast + self.player.cast.latencyRight.value > 1 then
				AngleStatusBar:SetValue(self[unit].cast.latencyRight, 1-perCast)
			end
		end

		-- Target in range
		if (unit == self.player.unit) then
			local color
			if self:TargetInRange() then
				-- if not self.player.targetInRange then
					self.player.targetInRange = true
					if db.colors.useGlobal then
						color = nibRealUI.media.colors.blue
					else
						color = db.colors.player
					end
				-- end
			else
				-- if self.player.targetInRange then
					self.player.targetInRange = false
					if db.colors.useGlobal then
						color = nibRealUI:ColorDarken(nibRealUI.media.colors.blue, 0.25)
					else
						color = db.colors.outOfRange
					end
				-- end
			end
			AngleStatusBar:SetBarColor(self.player.cast.bar, color)
		end

		-- Stop if time remaining <= 0
		if (remainingTime <= 0) then
			self:StopBar(unit)
		end

		-- Time text
		if remainingTime < 30 then
			self[unit].time.text:SetFormattedText("%.1f", remainingTime)
		elseif remainingTime < 300 then
			self[unit].time.text:SetFormattedText("%.0f", remainingTime)
		else
			self[unit].time.text:SetText(nibRealUI:ConvertSecondstoTime(remainingTime, true))
		end

		-- Name text
		self[unit].name.text:SetText(nibRealUI:AbbreviateName(self[unit].actionMessage, MaxNameLengths[unit]))

		return
	end

	-- stop bar if casting or channeling is done (in theory this should not be needed)
	if (self[unit].action == "CAST" or self[unit].action == "CHANNEL") then
		self:StopBar(unit)
		return
	end

	-- handle bar flashes
	if (self[unit].action == "FAILURE") then
		if not self[unit].flashStartTime then self[unit].flashStartTime = GetTime() end
		local flashTime = GetTime() - self[unit].flashStartTime

		if (flashTime > 0.5) then
			self:StopBar(unit)
			return
		end

		self:FlashBar(unit, 1-(flashTime*2), self[unit].actionMessage)
		return
	end

	-- something went wrong
	self:StopBar(unit)
end

function CastBars:Show(unit, shown)
	if shown or self.configMode then
		self[unit]:Show()
		self[unit]:SetAlpha(1)
	else
		self[unit]:Hide()
	end
end

function CastBars:StopBar(unit)
	if not(self[unit] and self[unit].unit == unit) then return end
	self[unit].action = "NONE"
	self[unit].actionStartTime = nil
	self[unit].actionDuration = nil

	self:Show(unit, false)
end

function CastBars:StartBar(unit, action, message)
	-- Config Mode
	if self.configMode then
		self[unit].icon.bg:SetTexture("Interface\\Icons\\Spell_Fire_Immolation")
		self[unit].name.text:SetTextColor(1, 1, 1, 1)
		self[unit].name.text:SetText("Pew Pew Laser Beams!")
		self[unit].time.text:SetText("2.5")

		AngleStatusBar:SetValue(self[unit].cast.bar, 0.35)
		if (unit == "player") then
			AngleStatusBar:SetValue(self[unit].cast.latencyLeft, 0.05)
			AngleStatusBar:SetValue(self[unit].cast.latencyRight, 0)
		end

		self:Show(unit, true)
		return
	end

	local spell, rank, displayName, icon, startTime, endTime, isTradeSkill, _, notInterruptibleCast = UnitCastingInfo(self[unit].unit)
	if not spell then
		spell, rank, displayName, icon, startTime, endTime, _, _, notInterruptibleCast = UnitChannelInfo(self[unit].unit)
	end
	if not spell then return end

	self[unit].notInterruptible = notInterruptibleCast

	self:Show(unit, true)
	self[unit].action = action
	
	if (icon ~= nil) then
		self[unit].icon.bg:SetTexture(icon)
		self[unit].icon:Show()
	else
		self[unit].icon:Hide()
	end
	
	self[unit].current = spell
	self[unit].actionStartTime = GetTime()
	self[unit].actionMessage = message
	self[unit].flashStartTime = nil

	if (startTime and endTime) then
		self[unit].actionDuration = (endTime - startTime) / 1000

		-- set start time here in case we start to monitor a cast that is underway already
		self[unit].actionStartTime = startTime / 1000
	else
		self[unit].actionDuration = 1 -- instants/failures
	end

	if not message then
		self[unit].actionMessage = spell
	end

	if not(self[unit].color == "normal") then
		if unit == "vehicle" then unit = "player" end
		if (unit == "player") or not(self[unit].notInterruptible) then
			local color
			if db.colors.useGlobal then
				if unit == "target" or unit == "focus" then
					color = nibRealUI.media.colors.orange
				else
					color = nibRealUI.media.colors.blue
				end
			else
				color = db.colors[unit]
			end
			AngleStatusBar:SetBarColor(self[unit].cast.bar, color)
		else
			self:UpdateInterruptibleColor(unit)
		end
		self[unit].name.text:SetTextColor(1, 1, 1, 1)
		self[unit].color = "normal"
	end
end

----
-- Casting
----
function CastBars:SpellCastSent(event, unit, spell, rank, target)
	if not(self[unit] and self[unit].unit == unit) then return end
	self[unit].spellCastSent = GetTime()
end

function CastBars:SpellCastStart(event, unit, spell, rank)
	if not(self[unit] and self[unit].unit == unit) then return end
	self[unit].current = spell
	self:StartBar(unit, "CAST")
	
	if not self[unit]:IsShown() or not self[unit].actionDuration then return end

	if unit == self.player.unit then self:SetBarTicks(0) end

	if ((unit == "player") or (unit == "vehicle")) then
		local lagScale
		if self[unit].unit == "vehicle" then
			lagScale = 0
		else
			local now = GetTime()
			local lag = now - (self[unit].spellCastSent or now)
			lagScale = nibRealUI:Clamp(lag / self[unit].actionDuration, 0, 1)
		end
		AngleStatusBar:SetValue(self[unit].cast.latencyLeft, lagScale)
		AngleStatusBar:SetValue(self[unit].cast.latencyRight, 0)
	end

	self[unit].spellCastSent = nil
end

function CastBars:SpellCastStop(event, unit, spell, rank)
	if not(self[unit] and self[unit].unit == unit) then return end

	-- ignore if not coming from current spell
	if (self[unit].current and spell and self[unit].current ~= spell) then return end

	if 	self[unit].action ~= "FAILURE" and
		self[unit].action ~= "CHANNEL"
	then
		self:StopBar(unit)
		self[unit].current = nil
	end
end

function CastBars:SpellCastFailed(event, unit, spell, rank)
	if not(self[unit] and self[unit].unit == unit) then return end
	
	if (self[unit].current and spell and self[unit].current ~= spell) then return end

	-- channeled spells will call ChannelStop, not cast failed
	if self[unit].action == "CHANNEL" then return end

	self[unit].current = nil

	if (UnitPowerType("player") ~= SPELL_POWER_MANA) then
		return
	end

	self:StartBar(unit, "FAILURE", "Failed")
end

function CastBars:SpellCastInterrupted(event, unit, spell, rank)
	if not(self[unit] and self[unit].unit == unit) then return end

	-- ignore if not coming from current spell
	if (self[unit].current and spell and self[unit].current ~= spell) then return end

	self[unit].current = nil

	self:StartBar(unit, "FAILURE", "Interrupted")
end

function CastBars:SpellCastDelayed(event, unit, delay)
	if not(self[unit] and self[unit].unit == unit) then return end

	local spell, rank, displayName, icon, startTime, endTime, isTradeSkill = UnitCastingInfo(self[unit].unit)

	if (endTime and self[unit].actionStartTime) then
		-- apparently this check is needed, got nils during a horrible lag spike
		self[unit].actionDuration = endTime/1000 - self[unit].actionStartTime
	end
end


function CastBars:SpellCastSucceeded(event, unit, spell, rank)
	if not(self[unit] and self[unit].unit == unit) then return end

	-- never show on channeled (why on earth does this event even fire when channeling starts?)
	if (self[unit].action == "CHANNEL") then return end

	-- ignore if not coming from current spell
	if (self[unit].current and self[unit].current ~= spell) then return end

	self[unit].current = nil
end

----
-- Channeling
----
function CastBars:SpellCastChannelStart(event, unit)
	if not(self[unit] and self[unit].unit == unit) then return end
	
	self:StartBar(unit, "CHANNEL")

	if not self[unit]:IsShown() or not self[unit].actionDuration then return end

	if (unit == "player") or (unit == "vehicle") then
		local lagScale
		if self[unit].unit == "vehicle" then
			lagScale = 0
		else
			local now = GetTime()
			local lag = now - (self[unit].spellCastSent or now)
			lagScale = nibRealUI:Clamp(lag / self[unit].actionDuration, 0, 1)
		end
		AngleStatusBar:SetValue(self[unit].cast.latencyLeft, 0)
		AngleStatusBar:SetValue(self[unit].cast.latencyRight, lagScale)

		self:SetBarTicks(ChannelingTicks[UnitChannelInfo(unit)])
	end

	self[unit].spellCastSent = nil
end

function CastBars:SpellCastChannelUpdate(event, unit)
	if not(self[unit] and self[unit].unit == unit) or not self[unit].actionStartTime then return end

	local spell, rank, displayName, icon, startTime, endTime = UnitChannelInfo(unit)
	if endTime then
		self[unit].actionDuration = endTime/1000 - self[unit].actionStartTime
	end
end

function CastBars:SpellCastChannelStop(event, unit)
	if not(self[unit] and self[unit].unit == unit) then return end

	self:StopBar(unit)
end

----
-- Vehicle check
----
function CastBars:EnteringVehicle(event, unit, arg2)
	if (unit == "player") and (self.player.unit == "player") and arg2 then
		self.player.unit = "vehicle"
		self:StopBar(self.player.unit)
		self:UnitUpdate(self.player.unit)
	end
end

function CastBars:ExitingVehicle(event, unit)
	if (unit == "player") then
		self.player.unit = "player"
		self:StopBar(self.player.unit)
		self:UnitUpdate(self.player.unit)
	end
end

function CastBars:CheckVehicle()
	self:ToggleConfigMode(false)
	self.player.unit = "player"
	self.target.unit = "target"
	self.focus.unit = "focus"
	if UnitHasVehicleUI("player") then
		self:EnteringVehicle(nil, "player", true)
	else
		self:ExitingVehicle(nil, "player")
	end
end


---- Target
function CastBars:UpdateInterruptibleColor(unit)
	if unit == "player" or unit == "vehicle" then return end
	local color
	if self[unit].notInterruptible then
		if db.colors.useGlobal then
			color = nibRealUI.media.colors.red
		else
			color = db.colors.uninterruptible
		end
	else
		if db.colors.useGlobal then
			color = nibRealUI.media.colors.orange
		else
			color = db.colors[unit]
		end
	end
	AngleStatusBar:SetBarColor(self[unit].cast.bar, color)
end

function CastBars:SpellCastInterruptible(event, unit)
	if not(self[unit] and self[unit].unit == unit) then return end

	self[unit].notInterruptible = false
	self:UpdateInterruptibleColor(unit)
end

function CastBars:SpellCastNotInterruptible(event, unit)
	if not(self[unit] and self[unit].unit == unit) then return end
	self[unit].notInterruptible = true
	self:UpdateInterruptibleColor(unit)
end

function CastBars:UnitUpdate(unit)
	if not UnitExists(self[unit].unit) then
		self:StopBar(self[unit].unit)
		return
	end

	local spell, _, _, _, _, _, _, _, notInterruptibleCast = UnitCastingInfo(self[unit].unit)
	if (spell) then
		self[unit].notInterruptible = notInterruptibleCast
		self:StartBar(self[unit].unit, "CAST")
		return
	end

	local channel, _, _, _, _, _, _, notInterruptibleChannel = UnitChannelInfo(self[unit].unit)
	if (channel) then
		self[unit].notInterruptible = notInterruptibleChannel
		self:StartBar(self[unit].unit, "CHANNEL")
		return
	end

	self:StopBar(self[unit].unit)
end

function CastBars:PLAYER_TARGET_CHANGED()
	self.target.unit = "target"
	self:UnitUpdate("target")
end

function CastBars:PLAYER_FOCUS_CHANGED()
	self.focus.unit = "focus"
	self:UnitUpdate("focus")
end

----
-- Frame Creation / Updates
----
local function SetTextPosition(frame, p1, p2)
	local cPos = (p1 ~= "CENTER") and p1..p2 or p1
	frame.text:ClearAllPoints()
	frame.text:SetPoint(cPos, frame, cPos, 0.5, 0.5)
	frame.text:SetJustifyH(p2)
	frame.text:SetJustifyV(p1)
end

function CastBars:UpdateAnchors()
	local textPointVert, textPointHoriz, textY, textX, xOfs, fontYOfs
	if db.text.textOnBottom then
		textPointVert = "TOP"
		xOfs = db.size[layoutSize].height + 1
	else
		textPointVert = "BOTTOM"
		xOfs = 0
	end

	-- Player
	if db.text.textInside then textPointHoriz = "RIGHT" else textPointHoriz = "LEFT" end

	if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 5) else textY = 2 end
	textX = textPointHoriz == "LEFT" and 25 or -35
	if (ndb.settings.fontStyle ~= 1) and db.text.textOnBottom then fontYOfs = -1 else fontYOfs = 0 end
	SetTextPosition(self.player.name, textPointVert, textPointHoriz)
	self.player.name:ClearAllPoints()
	self.player.name:SetPoint(textPointVert..textPointHoriz, self.player, "TOP"..textPointHoriz, textX + xOfs, textY + fontYOfs)

	if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 21) else textY = 13 end
	textX = textPointHoriz == "LEFT" and 25 or -35
	SetTextPosition(self.player.time, "BOTTOM", textPointHoriz)
	self.player.time:ClearAllPoints()
	self.player.time:SetPoint(textPointVert..textPointHoriz, self.player, "TOP"..textPointHoriz, textX + xOfs, textY)

	if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 4) else textY = 2 end
	textX = textPointHoriz == "LEFT" and -7 or -(db.size[layoutSize].height + 1)
	self.player.icon:ClearAllPoints()
	self.player.icon:SetPoint(textPointVert..textPointHoriz, self.player, "TOP"..textPointHoriz, textX + xOfs, textY)

	if db.reverse.player then
		AngleStatusBar:SetReverseDirection(self.player.cast.bar, db.reverse.player, (251 - db.size[layoutSize].width), -1)
		AngleStatusBar:SetReverseDirection(self.player.cast.latencyLeft, db.reverse.player, -5, -1)
		AngleStatusBar:SetReverseDirection(self.player.cast.latencyRight, db.reverse.player, (251 - db.size[layoutSize].width), -1)
	else
		AngleStatusBar:SetReverseDirection(self.player.cast.bar, db.reverse.player)
		AngleStatusBar:SetReverseDirection(self.player.cast.latencyLeft, db.reverse.player)
		AngleStatusBar:SetReverseDirection(self.player.cast.latencyRight, db.reverse.player)
	end

	-- Target
	if db.text.textInside then textPointHoriz = "LEFT" else textPointHoriz = "RIGHT" end
	
	if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 5) else textY = 2 end
	textX = textPointHoriz == "LEFT" and 37 or -23
	SetTextPosition(self.target.name, textPointVert, textPointHoriz)
	self.target.name:ClearAllPoints()
	self.target.name:SetPoint(textPointVert..textPointHoriz, self.target, "TOP"..textPointHoriz, textX - xOfs, textY + fontYOfs)

	if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 21) else textY = 13 end
	textX = textPointHoriz == "LEFT" and 37 or -23
	SetTextPosition(self.target.time, "BOTTOM", textPointHoriz)
	self.target.time:ClearAllPoints()
	self.target.time:SetPoint(textPointVert..textPointHoriz, self.target, "TOP"..textPointHoriz, textX - xOfs, textY)

	if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 4) else textY = 2 end
	textX = textPointHoriz == "LEFT" and 5 or (db.size[layoutSize].height + 2)
	self.target.icon:ClearAllPoints()
	self.target.icon:SetPoint(textPointVert..textPointHoriz, self.target, "TOP"..textPointHoriz, textX - xOfs, textY)

	if db.reverse.target then
		AngleStatusBar:SetReverseDirection(self.target.cast.bar, db.reverse.target, 5 + db.size[layoutSize].width - 256, -1)
	else
		AngleStatusBar:SetReverseDirection(self.target.cast.bar, db.reverse.target)
	end


	-- Focus
	self.focus:SetParent(oUF_RealUIFocus_Overlay)
	self.focus:ClearAllPoints()
	self.focus:SetPoint("TOPRIGHT", oUF_RealUIFocus_Overlay, "TOPRIGHT", db.size[layoutSize].focus.x + 3, db.size[layoutSize].focus.y)

	-- if textPointVert == "TOP" then textY = -(db.size[layoutSize].height + 5) else textY = 2 end
	-- textX = textPointHoriz == "LEFT" and 37 or -23
	if (ndb.settings.fontStyle == 3) then fontYOfs = -1 else fontYOfs = 0 end
	SetTextPosition(self.focus.name, "BOTTOM", "RIGHT")
	self.focus.name:ClearAllPoints()
	self.focus.name:SetPoint("BOTTOMRIGHT", self.focus, "TOPRIGHT", 2, 2 + fontYOfs)

	SetTextPosition(self.focus.time, "BOTTOM", "LEFT")
	self.focus.time:ClearAllPoints()
	self.focus.time:SetPoint("TOPRIGHT", self.focus, "TOPRIGHT", 32, 6)

	self.focus.icon:ClearAllPoints()
	self.focus.icon:SetPoint("TOPRIGHT", self.focus, "TOPRIGHT", 18, 11)
end

function CastBars:UpdateTextures()
	self.player.cast.bg:SetVertexColor(unpack(nibRealUI.media.background))
	if db.colors.useGlobal then
		AngleStatusBar:SetBarColor(self.player.cast.bar, nibRealUI.media.colors.blue)
		AngleStatusBar:SetBarColor(self.player.cast.latencyLeft, nibRealUI.media.colors.red)
		AngleStatusBar:SetBarColor(self.player.cast.latencyRight, nibRealUI.media.colors.red)
	else
		AngleStatusBar:SetBarColor(self.player.cast.bar, db.colors.player)
		AngleStatusBar:SetBarColor(self.player.cast.latencyLeft, db.colors.latency)
		AngleStatusBar:SetBarColor(self.player.cast.latencyRight, db.colors.latency)
	end

	self.target.cast.bg:SetVertexColor(unpack(nibRealUI.media.background))
	self:UpdateInterruptibleColor("target")

	self.focus.cast.bg:SetVertexColor(unpack(nibRealUI.media.background))
	self:UpdateInterruptibleColor("focus")
end

function CastBars:UpdateFonts()
	local font1 = nibRealUI:Font(false, "small")
	local font2 = nibRealUI:Font()
	local font3 = nibRealUI.font.pixelNumbers

	for k, fontString in pairs(FontStringsSmall) do
		fontString:SetFont(unpack(font1))
	end
	for k, fontString in pairs(FontStringsRegular) do
		fontString:SetFont(unpack(font2))
	end
	for k, fontString in pairs(FontStringsNumbers) do
		fontString:SetFont(unpack(font3))
	end

	self:UpdateAnchors()
end

function CastBars:UpdateGlobalColors()
	self:UpdateTextures()
end

local function CreateIconFrame(parent, size)
	local NewIconFrame = CreateFrame("Frame", nil, parent)
	NewIconFrame:SetSize(size, size)

	nibRealUI:CreateBD(NewIconFrame)
	NewIconFrame.bg = NewIconFrame:CreateTexture(nil, "ARTWORK")
	NewIconFrame.bg:SetPoint("TOPRIGHT", NewIconFrame, "TOPRIGHT", -1, -1)
	NewIconFrame.bg:SetPoint("BOTTOMLEFT", NewIconFrame, "BOTTOMLEFT", 1, 1)
	NewIconFrame.bg:SetTexCoord(0.08, 0.92, 0.08, 0.92)

	return NewIconFrame
end

local function CreateTextFrame(parent, size)
	local NewTextFrame = CreateFrame("Frame", nil, parent)
	NewTextFrame:SetSize(12, 12)

	NewTextFrame.text = NewTextFrame:CreateFontString(nil, "ARTWORK")
	if size == "numbers" then 
		tinsert(FontStringsNumbers, NewTextFrame.text)
	elseif size == "small" then
		tinsert(FontStringsSmall, NewTextFrame.text)
	else
		tinsert(FontStringsRegular, NewTextFrame.text)
	end
	
	return NewTextFrame
end

local function CreateCastBar(parent, unit, side)
	local NewCB = CreateFrame("Frame", nil, parent)
	NewCB:SetParent(parent)
	NewCB:SetSize(256, 16)
	if side == "RIGHT" then NewCB:SetPoint("TOPLEFT", parent) else NewCB:SetPoint("TOPRIGHT", parent) end

	NewCB.surround = NewCB:CreateTexture(nil, "ARTWORK")
	NewCB.surround:SetAllPoints()
	NewCB.surround:SetTexture(Textures[layoutSize][unit].surround)
	if side == "RIGHT" then NewCB.surround:SetTexCoord(1, 0, 0, 1) end

	NewCB.bg = NewCB:CreateTexture(nil, "ARTWORK")
	NewCB.bg:SetAllPoints()
	NewCB.bg:SetTexture(Textures[layoutSize][unit].bar)
	if side == "RIGHT" then NewCB.bg:SetTexCoord(1, 0, 0, 1) end

	return NewCB
end

function CastBars:CreateFrames()
	-- Player
	local cbPlayer = CreateFrame("Frame", "RealUI_CastBarsPlayer", RealUIPositionersCastBarPlayer)
	cbPlayer:Hide()
	self.player = cbPlayer
	self.vehicle = cbPlayer
		cbPlayer:SetHeight(32 + db.size[layoutSize].height)
		cbPlayer:SetWidth(db.size[layoutSize].width)
		cbPlayer:SetPoint("TOPRIGHT", RealUIPositionersCastBarPlayer, "TOPRIGHT", -1, 0)
		cbPlayer:SetScript("OnUpdate", function(self, elapsed)
			CastBars:OnUpdate("player", elapsed)
		end)

		-- Cast Bar
		cbPlayer.cast = CreateCastBar(cbPlayer, "player", "LEFT")
			cbPlayer.cast.bar = AngleStatusBar:NewBar(cbPlayer.cast, -CastBarXOffset[layoutSize], -1, db.size[layoutSize].width, db.size[layoutSize].height, "RIGHT", "RIGHT", "LEFT")
				cbPlayer.cast.bar:SetFrameLevel(5)
			cbPlayer.cast.latencyLeft = AngleStatusBar:NewBar(cbPlayer.cast, (256 - CastBarXOffset[layoutSize] - db.size[layoutSize].width), -1, db.size[layoutSize].width, db.size[layoutSize].height, "RIGHT", "RIGHT", "RIGHT")
				cbPlayer.cast.latencyLeft:SetFrameLevel(4)
				cbPlayer.cast.latencyLeft.reverse = true
			cbPlayer.cast.latencyRight = AngleStatusBar:NewBar(cbPlayer.cast, -CastBarXOffset[layoutSize], -1, db.size[layoutSize].width, db.size[layoutSize].height, "RIGHT", "RIGHT", "LEFT")
				cbPlayer.cast.latencyRight:SetFrameLevel(6)
				cbPlayer.cast.latencyRight.reverse = true

		-- Name / Time / Icon
		cbPlayer.name = CreateTextFrame(cbPlayer)
		cbPlayer.time = CreateTextFrame(cbPlayer, "numbers")
		cbPlayer.icon = CreateIconFrame(cbPlayer, 28)

		-- Chanelling Ticks
		cbPlayer.tick = {}
		for i = 1, MaxTicks do
			cbPlayer.tick[i] = CreateFrame("Frame", nil, cbPlayer)
			local tick = cbPlayer.tick[i]
				tick:SetFrameLevel(7)
				tick:SetSize(16, 16)

			tick.bg = tick:CreateTexture(nil, "OVERLAY")
				tick.bg:SetAllPoints()
				tick.bg:SetTexture(Textures[layoutSize].player.tick)
				tick.bg:SetVertexColor(nibRealUI.media.background[1], nibRealUI.media.background[2], nibRealUI.media.background[3], 0.4)

			tick:Hide()
		end

	-- Target
	local cbTarget = CreateFrame("Frame", "RealUI_CastBarsTarget", RealUIPositionersCastBarTarget)
	cbTarget:Hide()
	self.target = cbTarget
		cbTarget:SetHeight(32 + db.size[layoutSize].height)
		cbTarget:SetWidth(db.size[layoutSize].width)
		cbTarget:SetPoint("TOPLEFT", RealUIPositionersCastBarTarget, "TOPLEFT", 0, 0)
		cbTarget:SetScript("OnUpdate", function(self, elapsed)
			CastBars:OnUpdate("target", elapsed)
		end)

		-- Cast Bar
		cbTarget.cast = CreateCastBar(cbTarget, "target", "RIGHT")
			cbTarget.cast.bar = AngleStatusBar:NewBar(cbTarget.cast, CastBarXOffset[layoutSize], -1, db.size[layoutSize].width, db.size[layoutSize].height, "LEFT", "LEFT", "RIGHT")

		-- Name / Time / Icon
		cbTarget.name = CreateTextFrame(cbTarget)
		cbTarget.time = CreateTextFrame(cbTarget, "numbers")
		cbTarget.icon = CreateIconFrame(cbTarget, 28)


	-- Focus
	local cbFocus = CreateFrame("Frame", "RealUI_CastBarsFocus", UIParent)
	cbFocus:Hide()
	self.focus = cbFocus
		cbFocus:SetHeight(13 + db.size[layoutSize].focus.height)
		cbFocus:SetWidth(db.size[layoutSize].focus.width)
		cbFocus:SetScript("OnUpdate", function(self, elapsed)
			CastBars:OnUpdate("focus", elapsed)
		end)

		-- Cast Bar
		cbFocus.cast = CreateCastBar(cbFocus, "focus", "LEFT")
			cbFocus.cast.bar = AngleStatusBar:NewBar(cbFocus.cast, -2, -1, db.size[layoutSize].focus.width, db.size[layoutSize].focus.height, "LEFT", "RIGHT", "LEFT")

		-- Name / Time / Icon
		cbFocus.name = CreateTextFrame(cbFocus, "small")
		cbFocus.time = CreateTextFrame(cbFocus, "numbers")
		cbFocus.icon = CreateIconFrame(cbFocus, 16)
end

----------
function CastBars:SetUpdateSpeed()
	if ndb.settings.powerMode == 2 then	-- Economy
		UpdateSpeed = 1/40
	else
		UpdateSpeed = 1/60
	end
end

function CastBars:ToggleConfigMode(val)
	if self.configMode == val then return end
	if not nibRealUI:GetModuleEnabled(MODNAME) then return end
	self.configMode = val

	if self.configMode then
		self:UpdateFonts()
		self:UpdateAnchors()
		self:UpdateTextures()

		self:StartBar("player")
		self:StartBar("target")
		self:StartBar("focus")
	else
		self:StopBar("player")
		self:StopBar("vehicle")
		self:StopBar("target")
		self:StopBar("focus")
	end
end

function CastBars:PLAYER_LOGIN()
	self:UpdateAnchors()
end

-- Color Retrieval for Config Bar
function CastBars:GetColors()
	return db.colors
end

function CastBars:SetOption(key1, key2, value)
	db[key1][key2] = value
	self:UpdateAnchors()
	self:UpdateTextures()
end

function CastBars:GetOption(key1, key2)
	return db[key1][key2]
end

function CastBars:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			reverse = {
				player = false,
				target = false,
			},
			size = {
				[1] = {
					width = 200,
					height = 4,
					focus = {
						width = 126,
						height = 3,
						x = 0,
						y = 0,
					},
				},
				[2] = {
					width = 230,
					height = 5,
					focus = {
						width = 146,
						height = 4,
						x = 1,
						y = 1,
					},
				},
			},
			colors = {
				useGlobal = true,
				player =			{0.15, 0.61, 1.00, 1},
				focus =				{1.00, 0.38, 0.08, 1},
				target =			{1.00, 0.38, 0.08, 1},
				outOfRange =		{0.24, 0.48, 0.67, 1},
				uninterruptible =	{0.85, 0.14, 0.14, 1},
				latency =			{0.80, 0.13, 0.13, 1},
			},
			text = {
				textOnBottom = true,
				textInside = true,
			},
		},
	})
	db = self.db.profile
	ndb = nibRealUI.db.profile

	layoutSize = ndb.settings.hudSize
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
	nibRealUI:RegisterHuDOptions(MODNAME, GetOptions)
	nibRealUI:RegisterConfigModeModule(self)
end

function CastBars:OnEnable()
	self.configMode = false

	self:SetUpdateSpeed()

	if not self.player then self:CreateFrames() end
	self:UpdateFonts()
	self:UpdateAnchors()
	self:UpdateTextures()

	self.player.unit = "player"
	self.player.action = "NONE"
	self.player.targetInRange = true
	self.player.elapsed = 0

	self.target.unit = "target"
	self.target.action = "NONE"
	self.target.elapsed = 0

	self.focus.unit = "focus"
	self.focus.action = "NONE"
	self.focus.elapsed = 0

	-- Events
	self:RegisterEvent("PLAYER_LOGIN")

	-- Vehicle check
	self:RegisterEvent("UNIT_ENTERED_VEHICLE", "EnteringVehicle")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "ExitingVehicle")
	self:RegisterEvent("PLAYER_ENTERING_WORLD", "CheckVehicle")

	-- Cast
	self:RegisterEvent("PLAYER_TARGET_CHANGED")
	self:RegisterEvent("PLAYER_FOCUS_CHANGED")

	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTIBLE", "SpellCastInterruptible")
	self:RegisterEvent("UNIT_SPELLCAST_NOT_INTERRUPTIBLE", "SpellCastNotInterruptible")

	self:RegisterEvent("UNIT_SPELLCAST_SENT", "SpellCastSent") -- "player", spell, rank, target
	self:RegisterEvent("UNIT_SPELLCAST_START", "SpellCastStart") -- unit, spell, rank
	self:RegisterEvent("UNIT_SPELLCAST_STOP", "SpellCastStop") -- unit, spell, rank

	self:RegisterEvent("UNIT_SPELLCAST_FAILED", "SpellCastFailed") -- unit, spell, rank
	self:RegisterEvent("UNIT_SPELLCAST_INTERRUPTED", "SpellCastInterrupted") -- unit, spell, rank

	self:RegisterEvent("UNIT_SPELLCAST_DELAYED", "SpellCastDelayed") -- unit, spell, rank
	self:RegisterEvent("UNIT_SPELLCAST_SUCCEEDED", "SpellCastSucceeded") -- "player", spell, rank

	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_START", "SpellCastChannelStart") -- unit, spell, rank
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_UPDATE", "SpellCastChannelUpdate") -- unit, spell, rank
	self:RegisterEvent("UNIT_SPELLCAST_CHANNEL_STOP", "SpellCastChannelStop") -- unit, spell, rank

	-- Disable default Cast Bars
	CastingBarFrame:UnregisterAllEvents()
	PetCastingBarFrame:UnregisterAllEvents()
end

function CastBars:OnDisable()
	self:UnregisterAllEvents()

	-- Enable default Cast Bars
	CastingBarFrame:GetScript("OnLoad")(CastingBarFrame)
	PetCastingBarFrame:GetScript("OnLoad")(PetCastingBarFrame)
end