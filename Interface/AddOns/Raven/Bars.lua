-- Raven is an addon to monitor auras and cooldowns, providing timer bars, action bar highlights, and helpful notifications.

-- Bars.lua supports mapping auras to bars and grouping bars into multiple moveable frames.
-- It has special case code for tooltips, test bars, shaman totems, and death knight runes.
-- There are no exported functions at this time other than those called to initialize and update bars.

local MOD = Raven
local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local LSPELL = MOD.LocalSpellNames
local media = LibStub("LibSharedMedia-3.0")
local rc = { r = 1, g = 0, b = 0, a = 1 }
local vc = { r = 1, g = 0, b = 0, a = 0 }
local gc = { r = 0.5, g = 0.5, b = 0.5, a = 0.5 }
local fishSpell = GetSpellInfo(7620)
local hidden = false
local detectedBar = { enableBar = true, sorder = 0 }
local headerBar = { enableBar = true, sorder = 0 }
local groupIDs = {}
local settingsTemplate = {} -- settings are initialized from default bar group template
local defaultNotificationIcon = "Interface\\Icons\\Spell_Nature_WispSplode"
local prefixRaidTargetIcon = "|TInterface\\TargetingFrame\\UI-RaidTargetingIcon_"
local testColors = { "Blue1", "Cyan", "Green1", "Yellow1", "Orange1", "Red1", "Pink", "Purple1", "Brown1", "Gray" }

-- Saved variables don't handle being set to nil properly so need to use alternate value to indicate an option has been turned off
local Off = 0 -- value used to designate an option is turned off
local function IsOff(value) return value == nil or value == Off end -- return true if option is turned off
local function IsOn(value) return value ~= nil and value ~= Off end -- return true if option is turned on

local classNames = { DEATHKNIGHT = "Death Knight", DRUID = "Druid", HUNTER = "Hunter", MAGE = "Mage", PALADIN = "Paladin",
	PRIEST = "Priest", ROGUE = "Rogue", SHAMAN = "Shaman", WARLOCK = "Warlock", WARRIOR = "Warrior", MONK = "Monk" }
	
local colorTemplate = { timeColor = 0, iconColor = 0, labelColor = 0, colorMSBT = 0, }
local defaultWhite = { r = 1, g = 1, b = 1, a = 1 }
local function DefaultColor(c) return not c or not next(c) or ((c.r == 1) and (c.g == 1) and (c.b == 1) and (c.a == 1)) end
local defaultLabels = { 0, 1, 10, 30, "1m", "2m", "5m" }
function MOD:GetTimelineLabels() return defaultLabels end

MOD.BarGroupTemplate = { -- default bar group settings
	enabled = true, locked = true, merged = false, linkSettings = false, checkCondition = false, noMouse = false, iconMouse = true,
	barColors = "Spell", bgColors = "Normal", iconColors = "None", combatTips = true, casterTips = true, anchorTips = "DEFAULT", strata = "MEDIUM",
	useDefaultDimensions = true, useDefaultFontsAndTextures = true, useDefaultColors = true,
	sor = "A", reverseSort = false, timeSort = true, playerSort = false,
	configuration = 1, anchor = false, anchorX = 0, anchorY = 0, anchorLastBar = false, anchorRow = false, anchorColumn = true, anchorEmpty = false,
	growDirection = true, fillBars = false, wrap = 0, wrapDirection = false, snapCenter = false, maxBars = 0,
	pulseStart = false, pulseEnd = false, flashExpiring = false, flashTime = 5, hide = false, fade = false, ghost = false, delayTime = 5,
	bgNormalAlpha = 1, bgCombatAlpha = 1, mouseAlpha = 1, fadeAlpha = 1, testTimers = 10, testStatic = 0, testLoop = false,
	soundSpellStart = false, soundSpellEnd = false, soundSpellExpire = false, soundAltStart = "None", soundAltEnd = "None", soundAltExpire = "None",
	labelOffset = 0, labelInset = 0, labelWrap = false, labelCenter = false, labelAlign = "MIDDLE",
	timeOffset = 0, timeInset = 0, timeAlign = "normal", timeIcon = false, iconOffset = 0, iconInset = 0, iconHide = false, iconAlign = "CENTER",
	expireTime = 5, expireMinimum = 0, colorExpiring = false, expireMSBT = false, criticalMSBT = false, clockReverse = true, -- clockEdge = false,
	expireColor = false, expireLabelColor = false, expireTimeColor = false, desaturate = false, desaturateFriend = false,
	timelineWidth = 225, timelineHeight = 25, timelineDuration = 300, timelineExp = 3, timelineHide = false, timelineAlternate = true, timelineSwitch = 2,
	timelineTexture = "Blizzard", timelineAlpha = 1, timelineColor = false, timelineLabels = false, timelineSplash = true,
	showSolo = true, showParty = true, showRaid = true, showCombat = true, showOOC = true, showFishing = true, showFocusTarget = true,
	showInstance = true, showNotInstance = true, showArena = true, showBattleground = true, showPrimary = true, showSecondary = true,
	showResting = true, showMounted = true, showVehicle = true, showFriendly = true, showEnemy = true, showBlizz = true, showNotBlizz = true,
	detectBuffs = false, detectDebuffs = false, detectAllBuffs = false, detectAllDebuffs = false, detectDispellable = false, detectInflictable = false,
	detectNPCDebuffs = false, detectVehicleDebuffs = false, detectBoss = false,
	noHeaders = false, noTargets = false, noLabels = false, targetFirst = false, targetAlpha = 1, replay = false, replayTime = 5,
	detectCastable = false, detectStealable = false, detectMagicBuffs = false, detectEffectBuffs = false, detectWeaponBuffs = false,
	detectNPCBuffs = false, detectVehicleBuffs = false, detectOtherBuffs = false, detectBossBuffs = false, detectEnrageBuffs = false,
	detectCooldowns = false, detectBuffsMonitor = "player", detectBuffsCastBy = "player", detectDebuffsMonitor = "player",
	detectDebuffsCastBy = "player", detectCooldownsBy = "player", detectTracking = false, detectOnlyTracking = false,
	detectSpellCooldowns = true, detectTrinketCooldowns = true, detectInternalCooldowns = true, detectSpellEffectCooldowns = true,
	detectPotionCooldowns = true, detectOtherCooldowns = true, detectRuneCooldowns = false,
	detectSharedStances = true, detectSharedShouts = true,
	detectSharedFrostTraps = true, detectSharedFireTraps = true, detectSharedShocks = true, detectSharedCrusader = true,
	setDuration = false, uniformDuration = 120, checkDuration = false, minimumDuration = true, filterDuration = 120,
	checkTimeLeft = false, minimumTimeLeft = true, filterTimeLeft = 120, showNoDuration = false, showOnlyNoDuration = false,
	showNoDurationBackground = false, noDurationFirst = false, timeFormat = 6, timeSpaces = false, timeCase = false,
	filterBuff = true, filterBuffLink = true, filterBuffSpells = false, filterBuffTable = nil,
	filterDebuff = true, filterDebuffLink = true, filterDebuffSpells = false, filterDebuffTable = nil,
	filterCooldown = true, filterCooldownLink = true, filterCooldownSpells = false, filterCooldownTable = nil,
	showBuff = false, showDebuff = false, showCooldown = false, filterBuffBars = false, filterDebuffBars = false, filterCooldownBars = false,
}

MOD.BarGroupLayoutTemplate = { -- all the bar group settings involved in layout configuration
	barWidth = 0, barHeight = 0, iconSize = 0, scale = 0, spacingX = 0, spacingY = 0, iconOffsetX = 0, iconOffsetY = 0,
	useDefaultDimensions = 0, configuration = 0, growDirection = 0, wrap = 0, wrapDirection = 0, snapCenter = 0, fillBars = 0, maxBars = 0,
	labelOffset = 0, labelInset = 0, labelWrap = 0, labelCenter = 0, labelAlign = 0, timeOffset = 0, timeInset = 0, timeAlign = 0, timeIcon = 0,
	iconOffset = 0, iconInset = 0, iconHide = 0, iconAlign = 0,
	hideIcon = 0, hideClock = 0, hideBar = 0, hideSpark = 0, hideValue = 0, hideLabel = 0, hideCount = 0, showTooltips = 0
}

-- Initialize bar groups from those specified in the profile after, for example, a reloadUI or reset profile
function MOD:InitializeBars()
	local bgs = Nest_GetBarGroups()
	if bgs then for _, bg in pairs(bgs) do Nest_DeleteBarGroup(bg) end end -- first remove any bar groups represented in the graphics library
		
	for _, bg in pairs(MOD.db.profile.BarGroups) do -- then set up the ones specified in the profile
		if IsOn(bg) then
			for n, k in pairs(MOD.db.global.Defaults) do if bg[n] == nil then bg[n] = k end end -- add default settings for layout, fonts and textures
			for n, k in pairs(MOD.BarGroupTemplate) do if bg[n] == nil then bg[n] = k end end -- add defaults from the bar group template
			for n in pairs(colorTemplate) do if bg[n] == nil then bg[n] = Raven_CopyColor(defaultWhite) end end -- default basic colors
			MOD:InitializeBarGroup(bg, 0, 0)
			if not bg.auto then for _, bar in pairs(bg.bars) do bar.startReady = nil end end -- remove extra settings in custom bars
		end
	end
	MOD:UpdateAllBarGroups() -- this is done last to get all positions updated correctly
end

-- Finalize bar groups prior to logout, stripping out all values that match current defaults
function MOD:FinalizeBars()
	for bn, bg in pairs(MOD.db.profile.BarGroups) do
		if IsOn(bg) then
			bg.cache = nil -- delete bar group cache contents
			for n, k in pairs(MOD.db.global.Defaults) do if bg[n] == k then bg[n] = nil end end -- remove default settings for layout, fonts and textures
			for n, k in pairs(MOD.BarGroupTemplate) do if bg[n] == k then bg[n] = nil end end -- remove defaults from the bar group template
			for n in pairs(colorTemplate) do if DefaultColor(bg[n]) then bg[n] = nil end end -- detect basic colors set to defaults
		else
			MOD.db.profile.BarGroups[bn] = nil -- okay to delete these since no default bar groups
		end
	end
end

-- Remove default values from bar group settings
function MOD:FinalizeSettings()
	for _, settings in pairs(MOD.db.global.Settings) do
		for n, k in pairs(settingsTemplate) do if settings[n] == k then settings[n] = nil end end -- remove values still set to defaults
		for n in pairs(colorTemplate) do if DefaultColor(settings[n]) then settings[n] = nil end end -- detect basic colors set to defaults
	end
end

-- Raven is disabled so hide all features
function MOD:HideBars()
	if not hidden then
		for _, bp in pairs(MOD.db.profile.BarGroups) do
			if IsOn(bp) then MOD:ReleaseBarGroup(bp) end
		end
		hidden = true
	end
end

-- Initialize bar group settings by adding default values if necessary
function MOD:InitializeSettings()
	for n, k in pairs(MOD.BarGroupTemplate) do settingsTemplate[n] = k end -- initialize the settings template from bar group defaults
	for n, k in pairs(MOD.db.global.Defaults) do settingsTemplate[n] = k end -- add default settings for layout-fonts-textures
	settingsTemplate.enabled = nil; settingsTemplate.locked = nil; settingsTemplate.merged = nil; settingsTemplate.linkSettings = nil	
	for _, settings in pairs(MOD.db.global.Settings) do
		for n, k in pairs(settingsTemplate) do if settings[n] == nil then settings[n] = k end end -- add missing defaults from settings template
		for n in pairs(colorTemplate) do if settings[n] == nil then settings[n] = Raven_CopyColor(defaultWhite) end end -- default basic colors
	end
end

-- Fire off test bars for this bar group, remove if any already exist
function MOD:TestBarGroup(bp)
	local bg = Nest_GetBarGroup(bp.name)
	if bg then
		local found = false
		local icon = "Interface\\Icons\\INV_Drink_20"
		local timers = bp.testTimers or 0; if timers == 0 then timers = 10 end
		local static = bp.testStatic or 0
		for i = 1, timers do
			local bar = Nest_GetBar(bg, ">>Timer<<" .. string.format("%02d", i))
			if bar then found = true; Nest_DeleteBar(bg, bar) end
		end
		for i = 1, static do
			local bar = Nest_GetBar(bg, ">>Test<<" .. string.format("%02d", i))
			if bar then found = true; Nest_DeleteBar(bg, bar) end
		end
		if not found then
			for i = 1, timers do			
				local bar = Nest_CreateBar(bg, ">>Timer<<" .. string.format("%02d", i))
				if bar then
					local c = MOD.ColorPalette[testColors[(i % 10) + 1]]
					Nest_SetColors(bar, c.r, c.g, c.b, 1, c.r, c.g, c.b, 1, c.r, c.g, c.b, 1)
					Nest_SetLabel(bar, L["Timer Bar"] .. " " .. i); Nest_SetIcon(bar, icon); Nest_SetCount(bar, i)
					Nest_StartTimer(bar, i * 5, 60, 60); Nest_SetAttribute(bar, "updated", true)
				end
			end
			for i = 1, static do			
				local bar = Nest_CreateBar(bg, ">>Test<<" .. string.format("%02d", i))
				if bar then
					local c = MOD.ColorPalette[testColors[(i % 10) + 1]]
					Nest_SetColors(bar, c.r, c.g, c.b, 1, c.r, c.g, c.b, 1, c.r, c.g, c.b, 1)
					Nest_SetLabel(bar, L["Test Bar"] .. " " .. i); Nest_SetIcon(bar, icon); Nest_SetCount(bar, i)
					Nest_SetAttribute(bar, "updated", true)
				end
			end
		end
	end
end

-- Make sure not to delete any unexpired test bars
local function UpdateTestBars(bp, bg)
	local timers = bp.testTimers or 0; if timers == 0 then timers = 10 end
	local static = bp.testStatic or 0
	for i = 1, timers do
		local bar = Nest_GetBar(bg, ">>Timer<<" .. string.format("%02d", i))
		if bar then
			local timeLeft = Nest_GetTimes(bar)
			if timeLeft and (timeLeft > 0) then
				Nest_SetAttribute(bar, "updated", true)
			elseif bp.testLoop then
				Nest_StartTimer(bar, i * 5, 60, 60); Nest_SetAttribute(bar, "updated", true)
			end
		end
	end
	for i = 1, static do
		local bar = Nest_GetBar(bg, ">>Test<<" .. string.format("%02d", i))
		if bar then Nest_SetAttribute(bar, "updated", true) end
	end
end

-- Show tooltip when entering a bar group anchor
local function Anchor_OnEnter(anchor, bgName)
	if GetCVar("UberTooltips") == "1" then
		GameTooltip_SetDefaultAnchor(GameTooltip, anchor)
	else
		GameTooltip:SetOwner(anchor, "ANCHOR_BOTTOMLEFT")
	end
	local bg, bgType, attachment = Nest_GetBarGroup(bgName), L["Custom Bar Group"], nil
	if bg then
		if Nest_GetBarGroupAttribute(bg, "isAuto") then bgType = L["Auto Bar Group"] end
		attachment = Nest_GetBarGroupAttribute(bg, "attachment")
	end
	GameTooltip:AddDoubleLine("Raven", bgType)
	if attachment then
		GameTooltip:AddLine(L["Anchor attached"] .. attachment .. '"')
		GameTooltip:AddLine(L["Anchor left click 1"])
	else
		GameTooltip:AddLine(L["Anchor left click 2"])
	end
	GameTooltip:AddLine(L["Anchor right click"])
	GameTooltip:AddLine(L["Anchor shift left click"])
	GameTooltip:AddLine(L["Anchor shift right click"])
	GameTooltip:AddLine(L["Anchor alt left click"])
	GameTooltip:AddLine(L["Anchor alt right click"])
	GameTooltip:Show()
end

-- Hide tooltip when leaving a bar group anchor
local function Anchor_OnLeave(anchor, bgName)
	GameTooltip:Hide()
end

-- Callback function for tracking location of the bar group
local function Anchor_Moved(anchor, bgName)
	local bp = MOD.db.profile.BarGroups[bgName]
	if IsOn(bp) then
		local bg = Nest_GetBarGroup(bgName)
		if bg then
			bp.pointX, bp.pointXR, bp.pointY, bp.pointYT, bp.pointW, bp.pointH = Nest_GetAnchorPoint(bg) -- returns fractions from display edge
			if bp.anchor then bp.anchor = false end -- no longer anchored to other bar groups			
			if bp.linkSettings then
				local settings = MOD.db.global.Settings[bp.name] -- when updating a bar group with linked settings always overwrite position
				if settings then
					settings.pointX = bp.pointX; settings.pointXR = bp.pointXR; settings.pointY = bp.pointY; settings.pointYT = bp.pointYT
					settings.pointW = bp.pointW; settings.pointH = bp.pointH; settings.anchor = bp.anchor
				end
			end
			Anchor_OnLeave(anchor) -- turn off tooltip while moving the anchor
			MOD.updateOptions = true -- if options panel is open then update it in case viewing position info
		end
		return
	end
end

-- Callback function for when a bar group anchor is clicked with a modifier key down
-- Shift left click is test bars, right click is "toggle lock and hide",
local function Anchor_Clicked(anchor, bgName, button)
	local shiftLeftClick = (button == "LeftButton") and (IsShiftKeyDown() == 1)
	local shiftRightClick = (button == "RightButton") and (IsShiftKeyDown() == 1)
	local altLeftClick = (button == "LeftButton") and (IsAltKeyDown() == 1)
	local altRightClick = (button == "RightButton") and (IsAltKeyDown() == 1)
	local rightClick = (button == "RightButton")

	local bp = MOD.db.profile.BarGroups[bgName]
	if IsOn(bp) then
		if shiftLeftClick then -- test bars
			MOD:TestBarGroup(bp)
		elseif shiftRightClick then -- toggle grow up/down
			bp.growDirection = not bp.growDirection
		elseif altLeftClick then -- toggle options menu
			MOD:OptionsPanel()
		elseif altRightClick then -- cycle through configurations
			if bp.configuration > Nest_MaxBarConfiguration then -- special case order for cycling icon configurations
				local c, i = bp.configuration, Nest_MaxBarConfiguration + 1
				if c == i then c = i + 2 elseif c == (i + 1) then c = i + 3 elseif c == (i + 2) then c = i + 1 elseif c == (i + 3) then c = i
					elseif c == (i + 4) then c = i + 5 elseif c == (i + 5) then c = i + 4 end
				bp.configuration = c
			else
				bp.configuration = bp.configuration + 1
				if bp.configuration == (Nest_MaxBarConfiguration + 1) then bp.configuration = 1 end
			end
		elseif rightClick then -- lock and hide
			bp.locked = true
		end
		MOD:UpdateBarGroup(bp)
		MOD.updateOptions = true -- if options panel is open then update it in case viewing configuration info
		MOD:ForceUpdate()
		return
	end
end

-- Update linked settings. If dir is true then update the shared settings, otherwise update the bar group.
-- Also, if dir is true, create a linked settings table if one doesn't yet exist.
local function UpdateLinkedSettings(bp, dir)
	local settings = MOD.db.global.Settings[bp.name]
	if not settings then
		if not dir then return end
		settings = {}
		MOD.db.global.Settings[bp.name] = settings
	end

	local p, q = settings, bp
	if dir then p = bp; q = settings end

	for n in pairs(settingsTemplate) do q[n] = p[n] end -- copy every setting in the template
	q.pointX = p.pointX; q.pointXR = p.pointXR; q.pointY = p.pointY; q.pointYT = p.pointYT -- always copy the location
	q.pointW = p.pointW; q.pointH = p.pointH
end

-- Update a linked filter list. If dir is true then update the shared list, otherwise update the bar group's list.
-- Also, if dir is true, create a linked filter list if one doesn't yet exist.
local function UpdateLinkedFilter(bp, dir, filterType)
	local shared = MOD.db.global["Filter" .. filterType]
	local bgname = "filter" ..  filterType .. "List"

	if not shared[bp.name] then
		if not dir or not bp[bgname] or not next(bp[bgname], nil) then return end
		shared[bp.name] = {}
	end
	
	if not bp[bgname] then bp[bgname] = {} end

	local p, q = shared[bp.name], bp[bgname]
	if dir then p = bp[bgname]; q = shared[bp.name] end

	for _, v in pairs(q) do if not p[v] then q[v] = nil end end -- delete any keys in q not in p
	for _, v in pairs(p) do if not q[v] then q[v] = v end end -- copy everything from p to q
end

-- Initialize a bar group from a shared filter list, if any.
-- This function is called whenever filterLink is changed.
function MOD:InitializeFilterList(bp, filterType)
	if bp and bp["filter" .. filterType] and bp["filter" .. filterType .. "Link"] then
		UpdateLinkedFilter(bp, false, filterType) -- use the shared settings, if any, for a linked layout
	end
end

-- Get spell associated with a bar
function MOD:GetAssociatedSpellForBar(bar)
	if bar.barType == "Notification" then
		local sp = nil
		if bar.action then sp = MOD:GetConditionSpell(bar.action) end
		return sp
	end
	return bar.action
end

-- Get icon for the spell associated with a bar, returns nil if none found
function MOD:GetIconForBar(bar)
	local sp = MOD:GetAssociatedSpellForBar(bar)
	if sp then return MOD:GetIcon(sp) end
	return nil
end

-- Get color for the spell associated with a bar, returns nil if none found
function MOD:GetSpellColorForBar(bar)
	local c = bar.color -- get override if one is set
	if not c then
		local sp = MOD:GetAssociatedSpellForBar(bar)
		if sp then c = MOD:GetColor(sp, bar.spellID) end
	end
	return c
end

-- Set the bar's current spell color using an override if not linked (note bar.colorLink uses inverted value from expected)
function MOD:SetSpellColorForBar(bar, r, g, b, a)
	local c = bar.color -- check if using an override
	if c then c.r = r; c.g = g; c.b = b; c.a = a; return end
	if not bar.colorLink then -- set the shared color for bars with the same associated spell
		local sp = MOD:GetAssociatedSpellForBar(bar)
		if sp then c = MOD:GetColor(sp, bar.spellID) end
		if c then c.r = r; c.g = g; c.b = b; c.a = a; return end
		c = { r = r, g = g, b = b, a = a }
		if sp then MOD:SetColor(sp, c) else bar.color = c end
	else
		bar.color = { r = r, g = g, b = b, a = a } -- create an override
	end
end

-- Either link or decouple the bar's color from the color cache for it's associated spell
function MOD:LinkSpellColorForBar(bar)
	local c = MOD:GetSpellColorForBar(bar)
	if not bar.colorLink then -- link to the color cache, copying current setting, if any, to the color cache
		if c and bar.color then local d = bar.color; c.r = d.r; c.g = d.g; c.b = d.b; c.a = d.a end
		bar.color = nil -- delete override to revert back to color cache or default for bar type
	else -- decouple from the color cached, copying current setting, if any, to a new override
		if c then bar.color = { r = c.r, g = c.g, b = c.b, a = c.a } end
	end
end

-- Get the right color for the bar based on bar group settings
local function GetColorForBar(bg, bar, btype)
	local bt, ba, b, c = bar.barType, bar.action, nil, nil
	if bg.barColors == "Class" then
		if bt == "Buff" then b = MOD.BuffTable[ba] end
		if bt == "Debuff" then b = MOD.DebuffTable[ba] end
		if bt == "Cooldown" then b = MOD.CooldownTable[ba] end
		if b and b.class then
			if CUSTOM_CLASS_COLORS then c = CUSTOM_CLASS_COLORS[b.class] else c = RAID_CLASS_COLORS[b.class] end
		end
	elseif bg.barColors == "Spell" then
		if bar.color then c = bar.color else c = MOD:GetSpellColorForBar(bar) end
	elseif bg.barColors == "Custom" then
		c = bg.fgColor or defaultWhite
	end
	if not c then -- get the best default color for this bar type
		local cc = not bg.useDefaultColors -- indicates the bar group has overrides for standard colors
		c = cc and bg.buffColor or MOD.db.global.DefaultBuffColor -- use this as default in case unrecognized bar type
		if bt == "Debuff" then
			c = cc and bg.debuffColor or MOD.db.global.DefaultDebuffColor
			if btype then
				if btype == "Poison" then c = cc and bg.poisonColor or MOD.db.global.DefaultPoisonColor end
				if btype == "Curse" then c = cc and bg.curseColor or MOD.db.global.DefaultCurseColor end
				if btype == "Magic" then c = cc and bg.magicColor or MOD.db.global.DefaultMagicColor end
				if btype == "Disease" then c = cc and bg.diseaseColor or MOD.db.global.DefaultDiseaseColor end
			end
		end
		if bt == "Cooldown" then c = cc and bg.cooldownColor or MOD.db.global.DefaultCooldownColor end
		if bt == "Notification" then c = cc and bg.notificationColor or MOD.db.global.DefaultNotificationColor end
	end
	c.a = 1 -- always set alpha to 1 for bar colors
	return c
end

-- Get the standard debuff color for the bar, return nil if not a standard type of debuff
function MOD:GetDebuffColorForBar(bg, bar, btype)
	local cc = not bg.useDefaultColors -- indicates the bar group has overrides for standard colors
	local c = cc and bg.debuffColor or MOD.db.global.DefaultDebuffColor
	if bar.barType == "Debuff" then
		if btype then
			if btype == "Poison" then c = cc and bg.poisonColor or MOD.db.global.DefaultPoisonColor end
			if btype == "Curse" then c = cc and bg.curseColor or MOD.db.global.DefaultCurseColor end
			if btype == "Magic" then c = cc and bg.magicColor or MOD.db.global.DefaultMagicColor end
			if btype == "Disease" then c = cc and bg.diseaseColor or MOD.db.global.DefaultDiseaseColor end
		end
	end
	return c
end

-- Get the start, finish and expire sound files to play for a bar
local function GetSoundsForBar(bg, bar)
	local start, finish, expire, et, mt, replay, replayTime, sp = nil, nil, nil, nil, nil, nil, nil
	if bg.soundSpellStart or bar.soundSpellStart then sp = MOD:GetAssociatedSpellForBar(bar); if sp then start = MOD:GetSound(sp, bar.spellID) end end
	if not start and bar.soundAltStart ~= "None" then start = bar.soundAltStart end
	if not start and bg.soundAltStart ~= "None" then start = bg.soundAltStart end
	if bg.replay then replay = true; replayTime = bg.replayTime or 5 elseif bar.replay then replay = true; replayTime = bar.replayTime or 5 end
	if start then start = media:Fetch("sound", start) end
	if bg.soundSpellEnd or bar.soundSpellEnd then sp = MOD:GetAssociatedSpellForBar(bar); if sp then finish = MOD:GetSound(sp, bar.spellID) end end
	if not finish and bar.soundAltEnd ~= "None" then finish = bar.soundAltEnd end
	if not finish and bg.soundAltEnd ~= "None" then finish = bg.soundAltEnd end
	if finish then finish = media:Fetch("sound", finish) end
	if bar.soundSpellExpire then et = bar.expireTime or 5; mt = bar.expireMinimum or 0
		elseif bg.soundSpellExpire then et = bg.expireTime or 5; mt = bg.expireMinimum or 0 end
	if et then sp = MOD:GetAssociatedSpellForBar(bar); if sp then expire = MOD:GetSound(sp, bar.spellID) end end
	if not expire and bar.soundAltExpire ~= "None" then expire = bar.soundAltExpire; et = bar.expireTime or 5; mt = bar.expireMinimum or 0 end
	if not expire and bg.soundAltExpire ~= "None" then expire = bg.soundAltExpire; et = bg.expireTime or 5; mt = bg.expireMinimum or 0  end
	if expire then expire = media:Fetch("sound", expire) else et = nil; mt = nil end
	return start, finish, expire, et, mt, replay, replayTime
end

-- Initialize bar group in LibBars and set default values from those set in profile
function MOD:InitializeBarGroup(bp, offsetX, offsetY)
	local bg = Nest_GetBarGroup(bp.name)
	if not bg then bg = Nest_CreateBarGroup(bp.name) end
	if bp.linkSettings then UpdateLinkedSettings(bp, false) end
	if bp.auto then -- initialize the auto bar group filter lists
		if (bp.filterBuff or bp.showBuff) and bp.filterBuffLink then UpdateLinkedFilter(bp, false, "Buff") end -- shared settings for buffs
		if (bp.filterDebuff or bp.showDebuff) and bp.filterDebuffLink then UpdateLinkedFilter(bp, false, "Debuff") end -- shared settings for debuffs
		if (bp.filterCooldown or bp.showCooldown) and bp.filterCooldownLink then UpdateLinkedFilter(bp, false, "Cooldown") end -- shared settings for buffs
	end
	if not bp.pointX or not bp.pointY then bp.pointX = 0.5 + (offsetX / 600); bp.pointXR = nil; bp.pointY = 0.5 + (offsetY / 600); bp.pointYT = nil end
	if not bp.pointW or not bp.pointH then bp.pointW = MOD.db.global.Defaults.barWidth; bp.pointH = MOD.db.global.Defaults.barHeight end
	MOD:SetBarGroupPosition(bp)
	Nest_SetBarGroupCallbacks(bg, Anchor_Moved, Anchor_Clicked, Anchor_OnEnter, Anchor_OnLeave)
end

-- Initialize a bar group from linked settings, if any, and always update the bar group location.
-- This function is called whenever linkSettings is changed.
function MOD:InitializeBarGroupSettings(bp)
	if bp and bp.enabled then
		if bp.linkSettings then UpdateLinkedSettings(bp, false) end
		MOD:SetBarGroupPosition(bp)
	end
end

-- Save bar group settings into the linked settings.
function MOD:SaveBarGroupSettings(bp) UpdateLinkedSettings(bp, true) end

-- Validate and update a bar group's display position. If linked, also update the position in the linked settings.
function MOD:SetBarGroupPosition(bp)
	local scale = bp.useDefaultDimensions and MOD.db.global.Defaults.scale or bp.scale or 1
	local bg = Nest_GetBarGroup(bp.name)
	if bg then Nest_SetAnchorPoint(bg, bp.pointX, bp.pointXR, bp.pointY, bp.pointYT, scale, bp.pointW, bp.pointH) end
	if bp.linkSettings then
		local settings = MOD.db.global.Settings[bp.name] -- when updating a bar group with linked settings always overwrite position
		if settings then
			settings.pointX = bp.pointX; settings.pointXR = bp.pointXR; settings.pointY = bp.pointY; settings.pointYT = bp.pointYT
			settings.pointW = bp.pointW; settings.pointH = bp.pointH
		end
	end
end

-- Returns whether solo, party or raid
local function PartyInfo()
	if GetNumGroupMembers() == 0 then return "solo" end
	if IsInRaid() then return "raid" end
	return "party"
end

-- Set an entry in a bar group cache block
local function SetCache(bg, block, name, value)
	if not bg.cache then bg.cache = {} end
	if not bg.cache.block then bg.cache.block = {} end
	bg.cache.block[name] = value
end

-- Get a value from a bar group cache block
local function GetCache(bg, block, name)
	if not bg.cache or not bg.cache.block then return nil end
	return bg.cache.block[name]
end

-- Reset a bar group cache block
local function ResetCache(bg, block)
	if bg.cache and bg.cache.block then table.wipe(bg.cache.block) end
end

-- Bar sorting functions, assumes sort order was built into name
local function SortAlphaUp(a, b) return a.name > b.name end
local function SortAlphaDown(a, b) return a.name < b.name end
local function SortTimeLeftUp(a, b) if a.value ~= b.value then return a.value > b.value else return a.name > b.name end end
local function SortTimeLeftDown(a, b) if a.value ~= b.value then return a.value < b.value else return a.name < b.name end end
local function SortDurationUp(a, b) if a.maxValue ~= b.maxValue then return a.maxValue > b.maxValue else return a.name > b.name end end
local function SortDurationDown(a, b) if a.maxValue ~= b.maxValue then return a.maxValue < b.maxValue else return a.name < b.name end end

-- Update a bar group in LibBars with the current values in the profile
function MOD:UpdateBarGroup(bp)
	if bp.enabled then
		if bp.linkSettings then UpdateLinkedSettings(bp, true) end -- update shared settings in a linked bar group
		if bp.auto then -- update auto bar group filter lists
			if (bp.filterBuff or bp.showBuff) and bp.filterBuffLink then UpdateLinkedFilter(bp, true, "Buff") end -- shared settings for buffs
			if (bp.filterDebuff or bp.showDebuff) and bp.filterDebuffLink then UpdateLinkedFilter(bp, true, "Debuff") end -- shared settings for debuffs
			if (bp.filterCooldown or bp.showCooldown) and bp.filterCooldownLink then UpdateLinkedFilter(bp, true, "Cooldown") end -- shared settings for buffs
		end

		ResetCache(bp, "Buff"); ResetCache(bp, "Debuff"); ResetCache(bp, "Cooldown")
		if bp.bars then -- create caches for buff, debuff, cooldown actions
			for _, b in pairs(bp.bars) do
				local t = b.barType
				if (t == "Buff") or (t == "Debuff") then
					SetCache(bp, t, b.action, b.monitor)
				elseif t == "Cooldown" then
					SetCache(bp, t, b.action, true)
				end
			end
		end

		local bg = Nest_GetBarGroup(bp.name)
		if not bg then MOD:InitializeBarGroup(bp); bg = Nest_GetBarGroup(bp.name) end

		if bp.useDefaultDimensions then MOD:CopyDimensions(MOD.db.global.Defaults, bp) end
		if bp.useDefaultFontsAndTextures then MOD:CopyFontsAndTextures(MOD.db.global.Defaults, bp) end
		local panelTexture = bp.backdropEnable and media:Fetch("background", bp.backdropPanel) or nil
		local backdropTexture = (bp.backdropTexture ~= "None") and media:Fetch("border", bp.backdropTexture) or nil
		local borderTexture = (bp.borderTexture ~= "None") and media:Fetch("border", bp.borderTexture) or nil
		local fgtexture = media:Fetch("statusbar", bp.texture)
		local bgtexture = fgtexture
		if bp.bgtexture then bgtexture = media:Fetch("statusbar", bp.bgtexture) end
		Nest_SetBarGroupLock(bg, bp.locked)
		Nest_SetBarGroupAttribute(bg, "parentFrame", bp.parentFrame)
		Nest_SetBarGroupBarLayout(bg, bp.barWidth, bp.barHeight, bp.iconSize, bp.scale, bp.spacingX, bp.spacingY,
			bp.iconOffsetX, bp.iconOffsetY, bp.labelOffset, bp.labelInset, bp.labelWrap, bp.labelAlign, bp.labelCenter,
			bp.timeOffset, bp.timeInset, bp.timeAlign, bp.timeIcon, bp.iconOffset, bp.iconInset, bp.iconHide, bp.iconAlign,
			bp.configuration, bp.growDirection, bp.wrap, bp.wrapDirection, bp.snapCenter, bp.fillBars, bp.maxBars, bp.strata)
		Nest_SetBarGroupLabelFont(bg, media:Fetch("font", bp.labelFont), bp.labelFSize, bp.labelAlpha, bp.labelColor,
			bp.labelOutline, bp.labelShadow, bp.labelThick, bp.labelMono)
		Nest_SetBarGroupTimeFont(bg, media:Fetch("font", bp.timeFont), bp.timeFSize, bp.timeAlpha, bp.timeColor,
			bp.timeOutline, bp.timeShadow, bp.timeThick, bp.timeMono)
		Nest_SetBarGroupIconFont(bg, media:Fetch("font", bp.iconFont), bp.iconFSize, bp.iconAlpha, bp.iconColor,
			bp.iconOutline, bp.iconShadow, bp.iconThick, bp.iconMono)
		Nest_SetBarGroupBackdrop(bg, panelTexture, backdropTexture, bp.backdropWidth, bp.backdropInset, bp.backdropPadding, bp.backdropColor, bp.backdropFill,
			bp.backdropOffsetX, bp.backdropOffsetY, bp.backdropPadW, bp.backdropPadH)
		Nest_SetBarGroupBorder(bg, borderTexture, bp.borderWidth, bp.borderOffset, bp.borderColor)
		Nest_SetBarGroupTextures(bg, fgtexture, bp.fgAlpha, bgtexture, bp.bgAlpha, not bp.showNoDurationBackground,
			bp.fgSaturation, bp.fgBrightness, bp.bgSaturation, bp.bgBrightness)
		Nest_SetBarGroupVisibles(bg, not bp.hideIcon, not bp.hideClock, not bp.hideBar, not bp.hideSpark, not bp.hideLabel, not bp.hideValue)
		if bp.timelineTexture then bgtexture = media:Fetch("statusbar", bp.timelineTexture) else bgtexture = nil end
		Nest_SetBarGroupTimeline(bg, bp.timelineWidth, bp.timelineHeight, bp.timelineDuration, bp.timelineExp, bp.timelineHide, bp.timelineAlternate,
			bp.timelineSwitch, bp.timelineSplash, bgtexture, bp.timelineAlpha, bp.timelineColor or gc, bp.timelineLabels or defaultLabels)
		Nest_SetBarGroupAttribute(bg, "targetFirst", bp.targetFirst) -- for multi-target tracking, sort target first
		Nest_SetBarGroupAttribute(bg, "pulseStart", bp.pulseStart) -- pulse icon at start
		Nest_SetBarGroupAttribute(bg, "pulseEnd", bp.pulseEnd) -- pulse icon when expiring
		Nest_SetBarGroupAttribute(bg, "noMouse", bp.noMouse) -- disable interactivity
		Nest_SetBarGroupAttribute(bg, "iconMouse", bp.iconMouse) -- mouse-only interactivity
		Nest_SetBarGroupAttribute(bg, "anchorTips", bp.anchorTips) -- manual tooltip anchor
		Nest_SetBarGroupAttribute(bg, "isAuto", bp.auto) -- save for tooltip
		Nest_SetBarGroupAttribute(bg, "attachment", bp.anchor) -- save for tooltip
		Nest_SetBarGroupAttribute(bg, "clockReverse", bp.clockReverse) -- save for clock animations
--		Nest_SetBarGroupAttribute(bg, "clockEdge", bp.clockEdge) -- save for clock animations, removed in 5.0.4 release
		Nest_SetBarGroupTimeFormat(bg, bp.timeFormat, bp.timeSpaces, bp.timeCase)
		local sf = "alpha"
		if bp.sor == "T" then sf = "time" elseif bp.sor == "D" then sf = "duration" elseif bp.sor == "S" then sf = "start" elseif bp.sor == "C" then sf = "class" end
		Nest_BarGroupSortFunction(bg, sf, bp.reverseSort, bp.timeSort, bp.playerSort)
		Nest_SetBarGroupAttribute(bg, "noDurationFirst", bp.noDurationFirst) -- controls in no duration sorts first or last
	else
		MOD:ReleaseBarGroup(bp)
	end
end

-- Update the positions of all anchored bar groups plus make sure valid positions in all bar groups
function MOD:UpdatePositions()
	for _, bp in pairs(MOD.db.profile.BarGroups) do -- update bar group positions including relative ones if anchored
		if IsOn(bp) then
			local bg = Nest_GetBarGroup(bp.name)
			if bg and bg.configuration then -- make sure already configured
				if not bp.pointX or not bp.pointY then -- if not valid then move to center
					bp.pointX = 0.5; bp.pointXR = nil; bp.pointY = 0.5; bp.pointYT = nil
					Nest_SetAnchorPoint(bg, bp.pointX, bp.pointXR, bp.pointY, bp.pointYT, bp.scale or 1, nil, nil)
				end
				if bp.anchorFrame then
					Nest_SetRelativeAnchorPoint(bg, nil, bp.anchorFrame, bp.anchorPoint, bp.anchorX, bp.anchorY)
				elseif bp.anchor then
					local abp = MOD.db.profile.BarGroups[bp.anchor]
					if IsOn(abp) and abp.enabled then -- make sure the anchor is actually around to attach
						Nest_SetRelativeAnchorPoint(bg, bp.anchor, nil, nil, bp.anchorX, bp.anchorY, bp.anchorLastBar, bp.anchorEmpty, bp.anchorRow, bp.anchorColumn)
					end
				else
					Nest_SetRelativeAnchorPoint(bg, nil) -- reset the relative anchor point if none set
				end
				bp.pointX, bp.pointXR, bp.pointY, bp.pointYT, bp.pointW, bp.pointH = Nest_GetAnchorPoint(bg) -- returns fractions from display edge
			end
		end
	end
end

-- Update all the bar groups, this is necessary when changing stuff that can affect bars in multiple groups (e.g., buff colors and labels)
function MOD:UpdateAllBarGroups()
	for _, bp in pairs(MOD.db.profile.BarGroups) do -- update for changed bar group settings
		if IsOn(bp) then MOD:UpdateBarGroup(bp) end
	end
	MOD:ForceUpdate() -- this forces an immediate update of bar group display
end

-- Lock or unlock all bar groups
function MOD:LockBarGroups(lock)
	for _, bp in pairs(MOD.db.profile.BarGroups) do if IsOn(bp) then bp.locked = lock end end
	MOD:UpdateAllBarGroups()
end

-- Toggle test mode for all bar groups
function MOD:TestBarGroups(lock)
	for _, bp in pairs(MOD.db.profile.BarGroups) do if IsOn(bp) then MOD:TestBarGroup(bp) end end
	MOD:UpdateAllBarGroups()
end

-- Toggle locking of bar groups 
function MOD:ToggleBarGroupLocks()
	-- Look in the profile table to determine current state
	local anyLocked = false
	for _, bp in pairs(MOD.db.profile.BarGroups) do
		if IsOn(bp) and bp.locked then anyLocked = true break end
	end
	-- Now go back through and set all to same state (if any locked then unlock all)
	MOD:LockBarGroups(not anyLocked)
end

-- Release all the bars in the named bar group in LibBars
function MOD:ReleaseBarGroup(bp)
	if bp then 
		local bg = Nest_GetBarGroup(bp.name)
		if bg then Nest_DeleteBarGroup(bg) end
	end
end

-- Show tooltip when entering a bar
local function Bar_OnEnter(frame, bgName, barName, ttanchor)
	if (ttanchor == "DEFAULT") and (GetCVar("UberTooltips") == "1") then
		GameTooltip_SetDefaultAnchor(GameTooltip, frame)
	else
		if not ttanchor or (ttanchor == "DEFAULT") then ttanchor = "ANCHOR_BOTTOMLEFT" else ttanchor = "ANCHOR_" .. ttanchor end
		GameTooltip:SetOwner(frame, ttanchor)
	end
	local bg = Nest_GetBarGroup(bgName)
	if not bg then return end
	local bar = Nest_GetBar(bg, barName)
	if not bar then return end	
	local tt = Nest_GetAttribute(bar, "tooltipType")
	local id = Nest_GetAttribute(bar, "tooltipID")
	local unit = Nest_GetAttribute(bar, "tooltipUnit")	
	local caster = Nest_GetAttribute(bar, "caster")	
	if tt == "text" then
		GameTooltip:SetText(id)
	elseif (tt == "inventory") or (tt == "weapon") then
		local slot = GetInventorySlotInfo(id)
		if slot then
			GameTooltip:SetInventoryItem("player", slot)
		end
	elseif (tt == "spell link") or (tt == "item link") then
		GameTooltip:SetHyperlink(id)
	elseif (tt == "spell id") or (tt == "internal") then
		GameTooltip:SetSpellByID(id)
	elseif tt == "effect" then
		local ect = MOD.db.global.SpellEffects[id]
		if ect and ect.id then GameTooltip:SetSpellByID(ect.id) else GameTooltip:SetText(id) end
	elseif tt == "buff" then
		GameTooltip:SetUnitBuff(unit, id)
	elseif tt == "debuff" then
		GameTooltip:SetUnitDebuff(unit, id)
	elseif tt == "vehicle buff" then
		GameTooltip:SetUnitBuff("vehicle", id)
	elseif tt == "vehicle debuff" then
		GameTooltip:SetUnitDebuff("vehicle", id)
	elseif tt == "tracking" then
		GameTooltip:SetText(id) -- id is localized name of tracking type
	elseif tt == "spell" then
		GameTooltip:SetText(id)
	elseif tt == "totem" then
		GameTooltip:SetTotem(id)
	elseif tt == "notification" then
		GameTooltip:AddDoubleLine(id, "Notification")
		local ct = MOD.db.profile.Conditions[MOD.myClass]
		if ct then
			local c = ct[unit]
			if IsOn(c) and c.tooltip then GameTooltip:AddLine(MOD:GetConditionText(c.name), 1, 1, 1, true) end
		end
	elseif tt == "header" then
		GameTooltip:AddLine(id)
		GameTooltip:AddLine(L["Header click"], 1, 1, 1, true)
	end
	if caster and (caster ~= "") then GameTooltip:AddLine(L["<Applied by "] .. caster .. ">", 0, 0.8, 1, false) end
	GameTooltip:Show()
end

-- Hide tooltip when leaving a bar
local function Bar_OnLeave(frame, bgName, barName, ttanchor)
	GameTooltip:Hide()
end

-- Handle clicking on a bar for various purposes
local function Bar_OnClick(frame, bgName, barName, button)
	local bg = Nest_GetBarGroup(bgName)
	if not bg then return end
	local bar = Nest_GetBar(bg, barName)
	if not bar then return end	
	local tt = Nest_GetAttribute(bar, "tooltipType")
	local id = Nest_GetAttribute(bar, "tooltipID")
	local unit = Nest_GetAttribute(bar, "tooltipUnit")
	if (button == "LeftButton") and (unit == "player") and (tt == "tracking") then
		if GameTooltip:GetOwner() == frame then GameTooltip:Hide() end
		ToggleDropDownMenu(1, nil, MiniMapTrackingDropDown, frame, 0, 0)
	elseif (button == "RightButton") and (tt == "totem") then
--		DestroyTotem(id) -- destroy the selected totem (this call is now blocked in 5.1)
	elseif (button == "RightButton") and (tt == "header") then
		MOD:RemoveTrackers(unit)
	end
end

-- Return true if time and duration pass a bar group's filters
local function CheckTimeAndDuration(bp, timeLeft, duration)
	if (timeLeft == 0) and (duration == 0) then -- test for unlimited duration
		if not bp.showNoDuration then return false end
	else
		if bp.showNoDuration and bp.showOnlyNoDuration then return false end
		if bp.checkDuration and bp.filterDuration then
			if bp.minimumDuration then if duration < bp.filterDuration then return false end
			elseif duration >= bp.filterDuration then return false end
		end
		if bp.checkTimeLeft and bp.filterTimeLeft then
			if bp.minimumTimeLeft then if timeLeft < bp.filterTimeLeft then return false end
			elseif timeLeft >= bp.filterTimeLeft then return false end
		end
	end
	return true
end

-- Return the first number found in a tooltip, if any, for auras and cooldowns
local function GetTooltipNumber(ttType, ttID, ttUnit)
	local tt = nil
	if ttType == "buff" then
		tt = MOD:GetBuffTooltip(); tt:SetUnitBuff(ttUnit, ttID) -- fill in the tooltip for the buff
	elseif ttType == "debuff" then
		tt = MOD:GetBuffTooltip(); tt:SetUnitDebuff(ttUnit, ttID) -- fill in the tooltip for the debuff
	elseif (ttType == "spell link") or (ttType == "item link") then
		tt = MOD:GetBuffTooltip(); tt:SetHyperlink(ttID)
	elseif (ttType == "spell id") or (ttType == "internal") then
		tt = MOD:GetBuffTooltip(); tt:SetSpellByID(ttID)
	end
	if tt then
		for i = 1, 30 do
			local text = tt.tooltiplines[i]:GetText()
			if text then
				local num = text:match("(%d+)") -- extract first number in the line, if any
				if num then return tonumber(num) end
			else
				break
			end
		end
	end
	return nil
end

-- Manage a bar, creating one if not currently active, otherwise updating as necessary
-- Use originating bar group (bp) for filtering, display bar group (vbp) for appearance options
local function UpdateBar(bp, vbp, bg, b, icon, timeLeft, duration, count, btype, ttType, ttID, ttUnit, ttCaster, isMine)
	if duration > 0 then -- check if timer bar
		local elapsed = duration - timeLeft
		if (b.hide and (elapsed >= (b.delayTime or 5))) or (bp.hide and (elapsed >= (bp.delayTime or 5))) then return end
	end
	
	local bar, barname, label, src, classSort = nil, b.barLabel .. b.uniqueID, b.barLabel, b.barSource, nil
	if vbp.sor == "C" then -- prefixes are added to the barname to facilitate sorting
		if not src or (src == "Racial") or (src == "Spell") or (src == "Detected") then src = "zzzz" end -- non-class goes to end of list
		if src == MOD.myClass then src = "AAAA" end -- sort player's class to front of list
		classSort = "zzzz" .. string.upper(src)
	end
	if vbp.sor == "X" then barname = string.format("%05d ", b.sorder) .. barname end
	
	local maxTime = duration
	if vbp.setDuration then maxTime = vbp.uniformDuration end -- override with uniform duration for all bars in group

	if b.labelNumber then -- optionally get the first number found in the tooltip and append it to the label
		local num = GetTooltipNumber(ttType, ttID, ttUnit)
		if num then label = string.format("%s: %d", label, num) end
	end

	local c = GetColorForBar(vbp, b, btype)
	if b.colorBar then -- color may be overriden based on value of a condition
		local result = MOD:CheckCondition(b.colorCondition)
		if result then
			if b.colorTrue and b.colorTrue.a > 0 then c = b.colorTrue end
		else
			if b.colorFalse and b.colorFalse.a > 0 then c = b.colorFalse end
		end
	end
	
	local iconCount = nil
	if count then
		count = math.floor(count + 0.001)
		if b.barType == "Cooldown" or (count > 1) then
			if not vbp.hideCount then label = string.format("%s (%d)", label, count) end
			if not vbp.hideIcon then iconCount = count end
		end
	end
	
	bar = Nest_GetBar(bg, barname)
	if not (bp.showNoDuration and bp.showOnlyNoDuration) and not ((timeLeft == 0) and (duration == 0)) then -- bar with duration
		if bar and Nest_IsTimer(bar) then -- existing timer bar
			local oldTimeLeft, oldDuration, oldMaxTime = Nest_GetTimes(bar)
			if (duration ~= oldDuration) or maxTime ~= oldMaxTime or (math.abs(timeLeft - oldTimeLeft) > 0.5) then
				Nest_StartTimer(bar, timeLeft, duration, maxTime) -- update if the bar is out of sync
			end
		else
			if bar then Nest_DeleteBar(bg, bar); bar = nil end
			bar = Nest_CreateBar(bg, barname)
			if bar then Nest_StartTimer(bar, timeLeft, duration, maxTime); if b.ghost then Nest_SetAttribute(bar, "ghostDuration", b.delayTime or 5) end end
		end
	elseif bp.showNoDuration or (b.barType == "Notification") or b.enableReady then -- bars without duration
		if bar and Nest_IsTimer(bar) then Nest_DeleteBar(bg, bar); bar = nil end
		if not bar then
			bar = Nest_CreateBar(bg, barname)
			if bar and b.barType == "Notification" then Nest_SetFlash(bar, b.flash) end
		end	
	end
	if bar then
		Nest_SetAttribute(bar, "updated", true) -- for mark/sweep bar deletion
		Nest_SetAttribute(bar, "ghostTime", nil) -- delete in case was previously a ghost bar
		Nest_SetLabel(bar, label)
		local tex = nil
		if b.action and MOD.db.global.SpellIcons[b.action] then tex = MOD:GetIcon(b.action) end -- check for override of the icon
		if tex then Nest_SetIcon(bar, tex) else Nest_SetIcon(bar, icon) end
		local bc = (vbp.bgColors == "Custom") and vbp.bgColor or c
		local ibr, ibg, ibb, iba = 1, 1, 1, 1
		local ic = vbp.iconBorderColor
		if vbp.iconColors == "Normal" or (isMine and (vbp.iconColors == "Player")) then
			ibr, ibg, ibb, iba = c.r, c.g, c.b, c.a
		elseif not isMine and (vbp.iconColors == "Player") then
			ibr, ibg, ibb, iba = bc.r, bc.g, bc.b, bc.a
		elseif (vbp.iconColors == "Debuffs") and (b.barType == "Debuff") then
			local dc = MOD:GetDebuffColorForBar(vbp, b, btype)
			if dc then ibr, ibg, ibb, iba = dc.r, dc.g, dc.b, dc.a end
		elseif (vbp.iconColors == "Custom") and ic then
			ibr, ibg, ibb, iba = ic.r, ic.g, ic.b, ic.a
		elseif (vbp.iconColors == "None") then -- default border color only applies when not using Masque
			local dc = MOD.db.global.DefaultBorderColor
			if dc then ibr, ibg, ibb = dc.r, dc.g, dc.b end
		end
		ibr, ibg, ibb = Nest_AdjustColor(ibr, ibg, ibb, vbp.borderSaturation or 0, vbp.borderBrightness or 0)
		Nest_SetColors(bar, c.r, c.g, c.b, c.a, bc.r, bc.g, bc.b, bc.a, ibr, ibg, ibb, iba)
		Nest_SetCount(bar, iconCount) -- set the icon text to this count or blank if nil
		Nest_SetAttribute(bar, "iconColors", vbp.iconColors) -- required in order to do right thing with "None"
		Nest_SetAttribute(bar, "class", classSort) -- optional sort string for class sorting
		Nest_SetAttribute(bar, "isMine", isMine == true) -- optional indication that bar action was cast by player
		local desat = vbp.desaturate and (not vbp.desaturateFriend or (UnitExists("target") and UnitIsFriend("player", "target")))
		Nest_SetAttribute(bar, "desaturate", desat and not isMine) -- optionally desaturate if not player bar
		Nest_SetAttribute(bar, "group", b.group) -- optional group sorting parameter
		Nest_SetAttribute(bar, "groupName", b.groupName) -- optional group name
		Nest_SetAttribute(bar, "header", b.group and not b.groupName) -- special effect of hiding bar and icon
		Nest_SetAttribute(bar, "tooltipType", ttType) -- tooltip info
		Nest_SetAttribute(bar, "tooltipID", ttID)
		Nest_SetAttribute(bar, "tooltipUnit", ttUnit)
		if vbp.casterTips then Nest_SetAttribute(bar, "caster", ttCaster) else Nest_SetAttribute(bar, "caster", nil) end
		Nest_SetAttribute(bar, "saveBar", b) -- not valid in auto bar group since it then points to a local not a permanent table!
		Nest_SetAttribute(bar, "pulseStart", b.pulseStart) -- pulse icon at start
		Nest_SetAttribute(bar, "pulseEnd", b.pulseEnd) -- pulse icon when expiring
		
		if b.colorExpiring then -- set color to switch at expiration time, default is red
			Nest_SetAttribute(bar, "expireColor", b.expireColor or rc); Nest_SetAttribute(bar, "expireLabelColor", b.expireLabelColor or vc)
			Nest_SetAttribute(bar, "expireTimeColor", b.expireTimeColor or vc)
			Nest_SetAttribute(bar, "colorTime", b.expireTime or 5); Nest_SetAttribute(bar, "colorMinimum", b.expireMinimum or 0)
		elseif vbp.colorExpiring then
			Nest_SetAttribute(bar, "expireColor", vbp.expireColor or rc); Nest_SetAttribute(bar, "expireLabelColor", vbp.expireLabelColor or vc)
			Nest_SetAttribute(bar, "expireTimeColor", vbp.expireTimeColor or vc)
			Nest_SetAttribute(bar, "colorTime", vbp.expireTime or 5); Nest_SetAttribute(bar, "colorMinimum", vbp.expireMinimum or 0)
		else
			Nest_SetAttribute(bar, "expireColor", nil); Nest_SetAttribute(bar, "expireLabelColor", nil); Nest_SetAttribute(bar, "expireTimeColor", nil)
			Nest_SetAttribute(bar, "colorTime", nil); Nest_SetAttribute(bar, "colorMinimum", nil)
		end
		
		if b.expireMSBT then -- set color to switch at expiration time, default is red
			Nest_SetAttribute(bar, "colorMSBT", b.colorMSBT or rc); Nest_SetAttribute(bar, "criticalMSBT", b.criticalMSBT)
			Nest_SetAttribute(bar, "expireMSBT", b.expireTime or 5); Nest_SetAttribute(bar, "minimumMSBT", b.expireMinimum or 0)
		elseif vbp.expireMSBT then
			Nest_SetAttribute(bar, "colorMSBT", vbp.colorMSBT or rc); Nest_SetAttribute(bar, "criticalMSBT", vbp.criticalMSBT)
			Nest_SetAttribute(bar, "expireMSBT", vbp.expireTime or 5); Nest_SetAttribute(bar, "minimumMSBT", vbp.expireMinimum or 0)
		else
			Nest_SetAttribute(bar, "colorMSBT", nil); Nest_SetAttribute(bar, "criticalMSBT", nil)
			Nest_SetAttribute(bar, "expireMSBT", nil); Nest_SetAttribute(bar, "minimumMSBT", nil)
		end
		
		if MOD.db.profile.muteSFX or b.startReady then -- don't play sounds if muted or ready bar
			Nest_SetAttribute(bar, "soundStart", nil); Nest_SetAttribute(bar, "soundEnd", nil)
			Nest_SetAttribute(bar, "soundExpire", nil); Nest_SetAttribute(bar, "expireTime", nil)
		else
			local start, finish, expire, expireTime, expireMinimum, replay, replayTime = GetSoundsForBar(vbp, b)
			Nest_SetAttribute(bar, "soundStart", start) -- play sound at start
			Nest_SetAttribute(bar, "soundEnd", finish) -- play sound when finished
			Nest_SetAttribute(bar, "soundExpire", expire) -- play sound when expiring
			Nest_SetAttribute(bar, "expireTime", expireTime) -- time to play expire sound
			Nest_SetAttribute(bar, "expireMinimum", expireMinimum) -- minimum duration to enable expire sound
			Nest_SetAttribute(bar, "replay", replay) -- replay start sound as long as bar is active
			Nest_SetAttribute(bar, "replayTime", replayTime) -- how often to replay start sound
		end
		
		local sbg, sbt, sba = nil, nil, nil
		if b.barType ~= "Notification" then sbg = vbp; sbt = b.barType; sba = b.action end
		Nest_SetAttribute(bar, "saveBarGroup", sbg)
		Nest_SetAttribute(bar, "saveBarType", sbt)
		Nest_SetAttribute(bar, "saveBarAction", sba)
		
		local click, onEnter, onLeave = Bar_OnClick, nil, nil
		if vbp.showTooltips and (vbp.combatTips or not MOD.status.inCombat) then onEnter = Bar_OnEnter; onLeave = Bar_OnLeave end
		Nest_SetCallbacks(bar, click, onEnter, onLeave)
		
		local dft, gd = not vbp.useDefaultFontsAndTextures, MOD.db.global.Defaults -- indicates the bar group has overrides for fonts and textures		
		local faded, alpha = false, 1 -- set flash and adjust alpha for special effects
		if MOD.status.inCombat then alpha = (dft and vbp.combatAlpha or gd.combatAlpha) else alpha = (dft and vbp.alpha or gd.alpha) end
		if vbp.targetAlpha and ttUnit == "all" and b.group ~= UnitGUID("target") then alpha = alpha * vbp.targetAlpha end
		if (IsOn(b.flashBar) and (b.flashBar == MOD:CheckCondition(b.flashCondition))) or -- conditional flashing
				(Nest_IsTimer(bar) and ((vbp.flashExpiring and vbp.flashTime and (timeLeft < vbp.flashTime)) or -- bar group flash when expiring
				(b.flashExpiring and b.flashTime and (timeLeft < b.flashTime)))) then -- custom bar flash when expiring
			Nest_SetFlash(bar, true)
		elseif IsOn(b.fadeBar) then -- conditional fade for bars is higher priority than bar group setting for delayed fade
			if (b.fadeBar == MOD:CheckCondition(b.fadeCondition)) and b.fadeAlpha then alpha = alpha * b.fadeAlpha; faded = true end
		elseif b.fade and b.fadeAlpha and not b.startReady then
			local _, _, _, startTime = Nest_GetTimes(bar) -- get time bar was created
			if ((GetTime() - startTime) >= (b.delayTime or 5)) then alpha = alpha * b.fadeAlpha; faded = true end
		elseif vbp.fade and vbp.fadeAlpha and not b.startReady then
			local _, _, _, startTime = Nest_GetTimes(bar) -- get time bar was created
			if ((GetTime() - startTime) >= (vbp.delayTime or 5)) then alpha = alpha * vbp.fadeAlpha; faded = true end
		else
			Nest_SetFlash(bar, false)
		end
		if not faded then -- fading is highest priority
			if b.startReady then if b.readyAlpha then alpha = alpha * b.readyAlpha end -- this is a ready bar
			elseif b.normalAlpha then alpha = alpha * b.normalAlpha end -- normal bar
		end
		Nest_SetAlpha(bar, alpha)
	end
end

-- Compare caster to enforce "cast by" restrictions
function MOD:CheckCastBy(caster, cb)
	local isMine, isPet = (caster == "player"), (caster == "pet")
	local isOurs = isMine or isPet
	if not cb then cb = "player" else cb = string.lower(cb) end -- for backward compatibility
	return ((cb == "player") and isMine) or (cb == "anyone") or ((cb == "pet") and isPet) or ((cb == "other") and not isOurs) or ((cb == "ours") and isOurs) or
		((cb == "target") and (caster ~= "unknown") and UnitIsUnit("target", caster)) or
		((cb == "focus") and (caster ~= "unknown") and UnitIsUnit("focus", caster))
end

-- Return the source for a buff, debuff or cooldown
local function GetSpellSource(t)
	if not t then return "Unknown" end
	local s = classNames[t.class]
	if not s and t.race then s = "Racial" end
	if not s then s = "Detected" end
	return s
end

-- Check if an action is in the associated filter bar group
local function CheckFilterBarGroup(bgname, btype, action, value)
	if not bgname then return false end
	local bg = MOD.db.profile.BarGroups[bgname]
	if IsOn(bg) then
		if bg.auto then -- auto bar groups look in the filter list (doesn't matter if black list or white list)
			if btype == "Buff" then
				if (bg.filterBuff or bg.showBuff) and bg.filterBuffList and bg.filterBuffList[action] then return true end
			elseif btype == "Debuff" then
				if (bg.filterDebuff or bg.showDebuff) and bg.filterDebuffList and bg.filterDebuffList[action] then return true end
			elseif btype == "Cooldown" then
				if (bg.filterCooldown or bg.showCooldown) and bg.filterCooldownList and bg.filterCooldownList[action] then return true end
			end
		else -- custom bar groups look at the cached info generated from the custom bar list
			local v = GetCache(bg, btype, action)
			if v == value then return true end -- for auras this is which unit is being monitored
		end
	end
	return false
end

-- This table is used to allow multiple procs to show at the same time for Jade Spirit, River's Song, and Dancing Steel
local fixEnchants = { [104993] = true, [120032] = true, [118334] = true, [118335] = true, [116660] = true }
local fixDups = 0

-- Check for detected buffs and create bars for them in the specified bar group
-- Detected auras that don't match current bar group settings may need to be added later if the settings change 
local function DetectNewBuffs(unit, n, aura, isBuff, bp, vbp, bg)
	if bp.showBuff or bp.filterBuff then -- check black lists and white lists
		local spellList = nil; if bp.filterBuffSpells and bp.filterBuffTable then spellList = MOD.db.global.SpellLists[bp.filterBuffTable] end
		local listed = (bp.filterBuffList and bp.filterBuffList[n]) or (spellList and (spellList[n] or (aura[14] and spellList["#" .. tostring(aura[14])])))
		if (bp.filterBuff and listed) or (bp.showBuff and not listed) then return end
	end
	if bp.filterBuffBars and CheckFilterBarGroup(bp.filterBuffBarGroup, "Buff", n, bp.detectBuffsMonitor) then return end -- check if in filter bar group
	local bt = MOD.BuffTable
	if not bt[n] then bt[n] = { det = true } end -- newly detected aura goes into auras table
	local label = MOD:GetLabel(n, aura[14]) -- check if there is a cached label for this action or spellid
	local checkTracking = not (bp.detectTracking and bp.detectOnlyTracking)
	if (aura[4] == "Tracking") then checkTracking = bp.detectTracking end
	local tt, ta = aura[11], aura[12]
	local isStealable = (aura[7] == 1)
	local isNPC = aura[18]
	local isVehicle = aura[19]
	local isBoss = (aura[15] ~= nil)
	local isEnrage = (aura[4] == "")
	local isMagic = (aura[4] == "Magic") and not isStealable
	local isEffect = (tt == "effect")
	local isWeapon = (tt == "weapon")
	local isCastable = aura[17] and not isWeapon
	local isOther = not isStealable and not isCastable and not isNPC and not isVehicle and not isMagic and not isEffect and not isWeapon and not isBoss and not isEnrage
	local isMine = (aura[6] == "player")
	local id, gname = aura[20], aura[21] -- these fields are only valid if unit == "all
	local checkAll = (unit == "all")
	local checkTypes = not bp.filterBuffTypes or (bp.detectStealable and isStealable) or (bp.detectCastable and isCastable)
		or (bp.detectNPCBuffs and isNPC) or (bp.detectVehicleBuffs and isVehicle) or (bp.detectBossBuffs and isBoss) or (bp.detectEnrageBuffs and isEnrage)
		or (bp.detectMagicBuffs and isMagic) or (bp.detectEffectBuffs and isEffect) or (bp.detectWeaponBuffs and isWeapon) or (bp.detectOtherBuffs and isOther)
	if ((checkAll and not (bp.noPlayerBuffs and (id == UnitGUID("player"))) and not (bp.noPetBuffs and (id == UnitGUID("pet")))
			and not (bp.noTargetBuffs and (id == UnitGUID("target"))) and not (bp.noFocusBuffs and (id == UnitGUID("focus")))) or
			(not checkAll and not (bp.noPlayerBuffs and UnitIsUnit(unit, "player")) and not (bp.noPetBuffs and UnitIsUnit(unit, "pet"))
			and not (bp.noTargetBuffs and UnitIsUnit(unit, "target")) and not (bp.noFocusBuffs and UnitIsUnit(unit, "focus")) and
			MOD:CheckCastBy(aura[6], bp.detectBuffsCastBy))) and CheckTimeAndDuration(bp, aura[2], aura[5]) and checkTracking and checkTypes then
		local b, tag = detectedBar, "Buff"
		b.action = n; b.spellID = aura[14]; b.barType = "Buff"
		if aura[6] then tag = tag .. aura[6] elseif aura[10] and (aura[10] > 0) then tag = tag .. tostring(aura[10]) end
		if aura[14] then tag = tag .. tostring(aura[14]) elseif (tt == "weapon") or (tt == "tracking") then tag = tag .. ta end
		if tt == "buff" and aura[14] and fixEnchants[aura[14]] then tag = tag .. tostring(fixDups); fixDups = fixDups + 1 end -- allow duplicate enchants
		if unit == "all" then
			tag = tag .. id
			if bp.noHeaders then label = (bp.noLabels and "" or (label .. (bp.noTargets and "" or " - "))) .. (bp.noTargets and "" or gname) end
		end
		if tt == "effect" and ta then
			local ect = MOD.db.global.SpellEffects[ta]
			if ect and ect.label then label = label .. " |cFF7adbf2[" .. (aura[7] or aura[6]) .. "]|r" end
		end
		b.group = id -- if unit is "all" then this is GUID of unit with buff, otherwise it is nil
		b.groupName = gname -- if unit is "all" then this is the name of the unit with buff, otherwise it is nil
		b.uniqueID = tag
		b.barLabel = label
		b.barSource = GetSpellSource(bt[n])
		UpdateBar(bp, vbp, bg, b, aura[8], aura[2], aura[5], aura[3], aura[4], tt, ta, unit, aura[16], isMine)
	end
end

-- Check for detected debuffs and create bars for them in the specified bar group 
local function DetectNewDebuffs(unit, n, aura, isBuff, bp, vbp, bg)
	if bp.showDebuff or bp.filterDebuff then -- check black lists and white lists
		local spellList = nil; if bp.filterDebuffSpells and bp.filterDebuffTable then spellList = MOD.db.global.SpellLists[bp.filterDebuffTable] end
		local listed = (bp.filterDebuffList and bp.filterDebuffList[n]) or (spellList and (spellList[n] or (aura[14] and spellList["#" .. tostring(aura[14])])))
		if (bp.filterDebuff and listed) or (bp.showDebuff and not listed) then return end
	end
	if bp.filterDebuffBars and CheckFilterBarGroup(bp.filterDebuffBarGroup, "Debuff", n, bp.detectDebuffsMonitor) then return end -- check if in filter bar group
	local bt = MOD.DebuffTable
	if not bt[n] then bt[n] = { det = true } end -- newly detected aura goes into auras table
	local label = MOD:GetLabel(n, aura[14]) -- check if there is a cached label for this action or spellid
	local isDispel = MOD:IsDebuffDispellable(n, unit, aura[4])
	local isInflict = aura[17]
	local isNPC = aura[18]
	local isVehicle = aura[19]
	local tt, ta = aura[11], aura[12]
	local isBoss = (aura[15] ~= nil)
	local isEffect = (tt == "effect")
	local isPoison, isCurse, isMagic, isDisease = (aura[4] == "Poison"), (aura[4] == "Curse"), (aura[4] == "Magic"), (aura[4] == "Disease")
	local isOther = not isBoss and not isEffect and not isPoison and not isCurse and not isMagic and not isDisease
		and not isDispel and not isInflict and not isNPC and not isVehicle
	local isMine = (aura[6] == "player")
	local id, gname = aura[20], aura[21]
	local checkAll = (unit == "all")
	local checkTypes = not bp.filterDebuffTypes or (bp.detectDispellable and isDispel) or (bp.detectInflictable and isInflict) or
		(bp.detectNPCDebuffs and isNPC) or (bp.detectVehicleDebuffs and isVehicle) or
		(bp.detectBoss and isBoss) or (bp.detectEffectDebuffs and isEffect) or
		(bp.detectOtherDebuffs and isOther) or (bp.detectPoison and isPoison) or (bp.detectCurse and isCurse) or
		(bp.detectMagic and isMagic) or (bp.detectDisease and isDisease)
	if ((checkAll and not (bp.noPlayerDebuffs and (id == UnitGUID("player"))) and not (bp.noPetDebuffs and (id == UnitGUID("pet")))
			and not (bp.noTargetDebuffs and (id == UnitGUID("target"))) and not (bp.noFocusDebuffs and (id == UnitGUID("focus")))) or
			(not checkAll and not (bp.noPlayerDebuffs and UnitIsUnit(unit, "player")) and not (bp.noPetDebuffs and UnitIsUnit(unit, "pet"))
			and not (bp.noTargetDebuffs and UnitIsUnit(unit, "target")) and not (bp.noFocusDebuffs and UnitIsUnit(unit, "focus")) and
			MOD:CheckCastBy(aura[6], bp.detectDebuffsCastBy))) and CheckTimeAndDuration(bp, aura[2], aura[5]) and checkTypes then
		local b, tag = detectedBar, "Debuff"
		b.action = n; b.spellID = aura[14]; b.barType = "Debuff"
		if aura[6] then tag = tag .. aura[6] elseif aura[10] and (aura[10] > 0) then tag = tag .. tostring(aura[10]) end
		if aura[14] then tag = tag .. tostring(aura[14]) elseif (tt == "weapon") or (tt == "tracking") then tag = tag .. ta end
		if unit == "all" then
			tag = tag .. id
			if bp.noHeaders then label = (bp.noLabels and "" or (label .. (bp.noTargets and "" or " - "))) .. (bp.noTargets and "" or gname) end
		end
		if tt == "effect" and ta then
			local ect = MOD.db.global.SpellEffects[ta]
			if ect and ect.label then label = label .. " |cFF7adbf2[" .. (aura[7] or aura[6]) .. "]|r" end
		end
		b.group = id -- if unit is "all" then this is GUID of unit with debuff, otherwise it is nil
		b.groupName = gname -- if unit is "all" then this is the name of the unit with buff, otherwise it is nil
		b.uniqueID = tag
		b.barLabel = label
		b.barSource = GetSpellSource(bt[n])
		UpdateBar(bp, vbp, bg, b, aura[8], aura[2], aura[5], aura[3], aura[4], tt, ta, unit, aura[16], isMine)
	end
end

-- Check if a cooldown is of right type for the specified bar group
local function CheckCooldownType(cd, bp)
	local other, t, s = true, cd[5], cd[6]
	if (t == "spell link") or (t == "spell") or (t == "spell id") then
		other = false; if bp.detectSpellCooldowns then return true end
	elseif (t == "inventory") and ((s == "Trinket0Slot") or (s == "Trinket1Slot")) then
		other = false; if bp.detectTrinketCooldowns then return true end
	elseif t == "internal" then
		other = false; if bp.detectInternalCooldowns then return true end
	elseif t == "effect" then
		other = false; if bp.detectSpellEffectCooldowns then return true end
	elseif t == "text" then -- might be a potion or elixir
		if (s == "Shared Potion Cooldown") or (s == "Shared Elixir Cooldown") then
			other = false; if bp.detectPotionCooldowns then return true end
		end
	end
	if other and bp.detectOtherCooldowns then return true end
	return false
end

-- Return true if cooldown is not one of the special case shared ones
local function CheckSharedCooldowns(n, b, bp)
	if bp.detectSharedFrostTraps then
		if n == LSPELL["Freezing Trap"] then return false end
		if n == LSPELL["Ice Trap"] then b.barLabel = L["Frost Traps"] end
	end
	if bp.detectSharedFireTraps then
		if (n == LSPELL["Black Arrow"]) or (n == LSPELL["Immolation Trap"]) then return false end
		if n == LSPELL["Explosive Trap"] then b.barLabel = L["Fire Traps"] end
	end
	if bp.detectSharedShocks then
		if (n == LSPELL["Frost Shock"]) or (n == LSPELL["Flame Shock"]) then return false end
		if n == LSPELL["Earth Shock"] then b.barLabel = L["Shocks"] end
	end
	if bp.detectSharedStances then
		if (n == LSPELL["Defensive Stance"]) or (n == LSPELL["Berserker Stance"]) then return false end
		if n == LSPELL["Battle Stance"] then b.barLabel = L["Stances"] end
	end
	if bp.detectSharedShouts then
		if (n == LSPELL["Commanding Shout"]) then return false end
		if n == LSPELL["Battle Shout"] then b.barLabel = L["Shouts"] end
	end
	if bp.detectSharedCrusader then
		if n == LSPELL["Hammer of the Righteous"] then return false end
		if n == LSPELL["Crusader Strike"] then b.barLabel = L["Crusader/Hammer"] end
	end
	return true
end

-- Automatically generate rune cooldown bars for all six rune slots
local runeSlotPrefix = { "(1)  ", "(2)  ", "(5)  ", "(6)  ",  "(3)  ", "(4)  " }
local function AutoRuneBars(bp, vbp, bg)
	if MOD.myClass ~= "DEATHKNIGHT" then return end
	for i = 1, 6 do
		local rune = MOD.runeSlots[i]
		local icon = MOD.runeIcons[rune.rtype]
		local b = detectedBar
		b.action = MOD.runeTypes[rune.rtype]; b.spellID = nil; b.barLabel = runeSlotPrefix[i] .. b.action
		b.barType = "Cooldown"; b.uniqueID = "Cooldown"; b.group = nil; b.barSource = "Detected"
		if rune.ready then -- generate ready bar with no duration
			if CheckTimeAndDuration(bp, 0, 0) then
				UpdateBar(bp, vbp, bg, b, icon, 0, 0, nil, nil, "text", b.action, nil, nil, true)
			end
		else -- generate cooldown timer bar
			local timeLeft = rune.duration - (GetTime() - rune.start)
			if CheckTimeAndDuration(bp, timeLeft, rune.duration) then
				UpdateBar(bp, vbp, bg, b, icon, timeLeft, rune.duration, nil, nil, "text", b.action, nil, nil, true)
			end
		end
	end
end

local totemSlotName = { [1] = L["Fire Totem"], [2] = L["Earth Totem"], [3] = L["Water Totem"], [4] = L["Air Totem"] }
-- Automatically generate totem bars for the four totem slots
local function AutoTotemBars(bp, vbp, bg)
	if MOD.myClass ~= "SHAMAN" then return end
	for i = 1, 4 do
		local b = detectedBar
		b.barType = "Cooldown"; b.uniqueID = "Totem" .. i; b.group = nil; b.barSource = totemSlotName[i]
		local haveTotem, name, startTime, duration, icon = GetTotemInfo(i)
		if haveTotem and name and name ~= "" then -- generate timer bar for the totem in the slot
			local timeLeft = duration - (GetTime() - startTime)
			if CheckTimeAndDuration(bp, timeLeft, duration) then
				b.action = name; b.barLabel = name; b.spellID = nil
				UpdateBar(bp, vbp, bg, b, icon, timeLeft, duration, nil, nil, "totem", i, "player", nil, true)
			end
		else -- generate ready bar with no duration
			if CheckTimeAndDuration(bp, 0, 0) then
				b.action = totemSlotName[i]; b.barLabel = b.action; b.spellID = nil
				UpdateBar(bp, vbp, bg, b, nil, 0, 0, nil, nil, "text", b.action, nil, nil, true)
			end
		end
	end
end

-- Check if there are detected cooldowns and conditionally create bars for them in the specified bar group
local function DetectNewCooldowns(n, cd, bp, vbp, bg)
	if bp.showCooldown or bp.filterCooldown then -- check black lists and white lists
		local spellList = nil; if bp.filterCooldownSpells and bp.filterCooldownTable then spellList = MOD.db.global.SpellLists[bp.filterCooldownTable] end
		local listed = (bp.filterCooldownList and bp.filterCooldownList[n]) or (spellList and (spellList[n] or (cd[8] and spellList["#" .. tostring(cd[8])])))
		if (bp.filterCooldown and listed) or (bp.showCooldown and not listed) then return end
	end
	if bp.filterCooldownBars and CheckFilterBarGroup(bp.filterCooldownBarGroup, "Cooldown", n, true) then return end -- check if in filter bar group
	local cdt = MOD.CooldownTable	
	if not cdt[n] then cdt[n] = { det = true } end -- newly detected cooldown goes into cooldowns table
	local label = MOD:GetLabel(n, cd[8]) -- check if there is a cached label for this action or spellid
	if MOD:CheckCastBy(cd[7], bp.detectCooldownsBy) and CheckCooldownType(cd, bp) and CheckTimeAndDuration(bp, cd[1], cd[4]) then
		local b = detectedBar
		b.action = n; b.spellID = cd[8]; b.barType = "Cooldown"; b.barLabel = label; b.uniqueID = "Cooldown"; b.group = nil
		b.barSource = GetSpellSource(cdt[n])
		if CheckSharedCooldowns(n, b, bp) then
			UpdateBar(bp, vbp, bg, b, cd[2], cd[1], cd[4], cd[9], nil, cd[5], cd[6], nil, nil, true)
		end
	end
end

-- Update all bars in bar group (bp), causing them to appear in display bar group (bg) using appearance options (vbp)
-- The show/hide conditions are tested in this function so they are depending on the updating bar group
local function UpdateBarGroupBars(bp, vbp, bg)
	local pst, stat = PartyInfo(), MOD.status
	local show = (((pst == "solo") and bp.showSolo) or ((pst == "party") and bp.showParty) or ((pst == "raid") and bp.showRaid)) and
		((bp.showCombat and stat.inCombat) or (bp.showOOC and not stat.inCombat)) and (not stat.isResting or bp.showResting) and
		((bp.showBlizz and not MOD.db.profile.hideBlizz) or (bp.showNotBlizz and MOD.db.profile.hideBlizz)) and
		(bp.showFishing or not stat.isFishing) and (bp.showMounted or not stat.isMounted) and (bp.showVehicle or not stat.inVehicle) and 
		(bp.showEnemy or not stat.targetEnemy) and (bp.showFriendly or not stat.targetFriend) and 
		(not bp.checkCondition or IsOff(bp.condition) or MOD:CheckCondition(bp.condition)) and (bp.showBattleground or not stat.inBattleground) and
		((bp.showInstance and stat.inInstance) or (bp.showNotInstance and not stat.inInstance)) and (bp.showArena or not stat.inArena) and
		(bp.showPrimary or stat.talentGroup ~= 1) and (bp.showSecondary or stat.talentGroup ~= 2) and not InCinematic() and
		(not bp.showClasses or not bp.showClasses[MOD.myClass]) and (not UnitIsUnit("focus", "target") or bp.showFocusTarget) and not C_PetBattles.IsInBattle()
	if show then
		if bp.auto then -- if auto bar group then detect new auras and cooldowns
			fixDups = 0 -- workaround to support multiple instances of same spell id for certain weapon enchants
			if bp.detectBuffs then MOD:IterateAuras(bp.detectAllBuffs and "all" or bp.detectBuffsMonitor, DetectNewBuffs, true, bp, vbp, bg) end
			if bp.detectDebuffs then MOD:IterateAuras(bp.detectAllDebuffs and "all" or bp.detectDebuffsMonitor, DetectNewDebuffs, false, bp, vbp, bg) end
			if bp.detectCooldowns then MOD:IterateCooldowns(DetectNewCooldowns, bp, vbp, bg) end
			if bp.detectRuneCooldowns then AutoRuneBars(bp, vbp, bg) end
			if bp.detectTotems then AutoTotemBars(bp, vbp, bg) end

			if not bp.noHeaders and ((bp.detectBuffs and bp.detectAllBuffs) or (bp.detectDebuffs and bp.detectAllDebuffs)) then -- add group headers, if necessary
				table.wipe(groupIDs) -- cache for group ids
				for _, bar in pairs(Nest_GetBars(bg)) do
					local id = Nest_GetAttribute(bar, "group")
					local gname = Nest_GetAttribute(bar, "groupName")
					local updated = Nest_GetAttribute(bar, "updated")
					if id and gname and updated then groupIDs[id] = gname end
				end
				for id, name in pairs(groupIDs) do -- create the header bars
					local b, label = headerBar, name
					local rti = MOD:GetRaidTarget(id)
					if rti then label = prefixRaidTargetIcon .. rti .. ":0|t " .. name end
					b.action = ""; b.spellID = nil; b.barLabel = label; b.barType = "Notification"
					b.uniqueID = id; b.group = id; b.barSource = "header"
					UpdateBar(bp, vbp, bg, b, nil, 0, 0, nil, nil, "header", name, id, nil, nil)
				end
			end
		else
			for _, bar in pairs(bp.bars) do -- iterate over each bar in the bar group
				if bar.enableBar and (IsOff(bar.hideBar) or (bar.hideBar ~= MOD:CheckCondition(bar.hideCondition))) then
					local t = bar.barType
					local found = false
					if (t == "Buff")  or (t == "Debuff") then
						local aname, cb, saveLabel, count = bar.action, string.lower(bar.castBy), bar.barLabel, 0
						local auraList = MOD:CheckAura(bar.monitor, aname, t == "Buff")
						if #auraList > 0 then
							for _, aura in pairs(auraList) do
								local isMine, isPet = (aura[6] == "player"), (aura[6] == "pet") -- enforce optional castBy restrictions
								local mon = ((cb == "player") and isMine) or ((cb == "pet") and isPet) or ((cb == "other") and not isMine) or (cb == "anyone")
								if mon and CheckTimeAndDuration(bp, aura[2], aura[5]) then
									count = count + 1
									if count > 1 then bar.barLabel = bar.barLabel .. " " end -- add space at end to make unique
									bar.startReady = nil; bar.spellID = aura[14]
									UpdateBar(bp, vbp, bg, bar, aura[8], aura[2], aura[5], aura[3], aura[4], aura[11], aura[12], bar.monitor, aura[16], isMine)
									found = true
								end
							end
							bar.barLabel = saveLabel -- restore in case of multiple bar copies
						end
						if not found and bar.enableReady then -- see if need to create a ready bar for spell off cooldown
							if not bar.readyTime then bar.readyTime = 0 end
							if bar.readyTime == 0 then bar.startReady = nil end
							if not bar.startReady or ((GetTime() - bar.startReady) < bar.readyTime) then
								if not bar.startReady then bar.startReady = GetTime() end
								local bt = (t == "Buff") and MOD.BuffTable or MOD.DebuffTable
								local aura, ttype, link = bt[aname]
								if aura then link = GetSpellLink(aura.id or aname) end
								if link then ttype = "spell link" else ttype = "text"; link = aname end
								UpdateBar(bp, vbp, bg, bar, MOD:GetIcon(aname), 0, 0, nil, nil, ttype, link, nil, nil, nil)
							end
						end
					elseif t == "Cooldown" then
						local aname = bar.action
						local cd = MOD:CheckCooldown(aname) -- look up in the active cooldowns table
						if cd and (cd[1] ~= nil) then
							if CheckTimeAndDuration(bp, cd[1], cd[4]) then
								bar.startReady = nil; bar.spellID = cd[8]
								UpdateBar(bp, vbp, bg, bar, cd[2], cd[1], cd[4], cd[9], nil, cd[5], cd[6], nil, nil, true)
								found = true
							end
						end
						if not found and bar.enableReady and (bar.readyNotUsable or IsUsableSpell(aname) or IsUsableItem(aname)) then -- see if need to create a ready bar
							if not bar.readyTime then bar.readyTime = 0 end
							if bar.readyTime == 0 then bar.startReady = nil end
							if not bar.startReady or ((GetTime() - bar.startReady) < bar.readyTime) then
								if not bar.startReady then bar.startReady = GetTime() end
								local iname, link, _, _, _, _, _, _, _, icon = GetItemInfo(aname)
								local _, charges = GetSpellCharges(aname); if charges and charges <= 1 then charges = nil end -- show max charges on ready bar
								local ttype = "item link"
								if not iname then ttype = "spell link"; link = MOD:GetHyperlink(aname); icon = MOD:GetIcon(aname) end
								if not link then ttype = "text"; link = aname end
								UpdateBar(bp, vbp, bg, bar, icon, 0, 0, charges, nil, ttype, link, nil, nil, true)
							end
						end
					elseif t == "Notification" then
						if MOD:CheckCondition(bar.action) then
							bar.spellID = nil
							local icon = MOD:GetIconForBar(bar)
							if not icon then icon = defaultNotificationIcon end
							UpdateBar(bp, vbp, bg, bar, icon, 0, 0, nil, nil, "notification", bar.barLabel, bar.action, nil, true)
						end
					end
				end
			end
		end
	end
end

-- Look for expired timer bars and update them as ghost bars, if necessary
local function UpdateGhostBars(bp, bg)
	local now = GetTime()
	if not bp.auto then -- if custom bar group then check for individual bar ghost option (overrides bar group option)
		for _, bar in pairs(Nest_GetBars(bg)) do
			local ghostDuration = Nest_GetAttribute(bar, "ghostDuration")
			if ghostDuration and Nest_IsTimer(bar) and not Nest_GetAttribute(bar, "updated") then -- any non-updated timer bar is a candidate for becoming a ghost bar
				local ghostTime = Nest_GetAttribute(bar, "ghostTime")
				if not ghostTime then
					Nest_SetCount(bar, nil) -- looks better if count is cleared
					ghostTime = now + ghostDuration
					Nest_SetAttribute(bar, "ghostTime", ghostTime)
				end
				if ghostTime and ghostTime >= now then Nest_SetAttribute(bar, "updated", true) end
			end
		end
	end
	if bp.ghost then
		for _, bar in pairs(Nest_GetBars(bg)) do
			if Nest_IsTimer(bar) and not Nest_GetAttribute(bar, "updated") then -- find non-updated timer bars
				local ghostTime = Nest_GetAttribute(bar, "ghostTime")
				if not ghostTime then
					Nest_SetCount(bar, nil) -- looks better if count is cleared
					ghostTime = now + (bp.delayTime or 5)
					Nest_SetAttribute(bar, "ghostTime", ghostTime)
				end
				if ghostTime and ghostTime >= now then Nest_SetAttribute(bar, "updated", true) end
			end
		end
	end
end

-- Update bars in all bar groups, checking for bar group visibility and removing expired bars
function MOD:UpdateBars()
	if hidden then -- if was hidden then need to re-initialize all bar groups
		hidden = false
		MOD:UpdateAllBarGroups()
	end
	
	for _, bp in pairs(MOD.db.profile.BarGroups) do -- iterate through the all bar groups
		if IsOn(bp) then
			local bg = Nest_GetBarGroup(bp.name) -- match the profile bar group to the LibBars bar group
			if bg then	
				if bp.enabled then -- check all the conditions under which the bar group might be hidden are not true
					Nest_SetAllAttributes(bg, "updated", false) -- first, mark all the bars in the group as not updated...
					if not bp.merged then
						UpdateBarGroupBars(bp, bp, bg) -- then update all the bars for the bar group into the display bar group					
						for _, mbp in pairs(MOD.db.profile.BarGroups) do -- then look for bar groups merging into this bar group
							if IsOn(mbp) and mbp.enabled and mbp.merged and (mbp.mergeInto == bp.name) then
								UpdateBarGroupBars(mbp, bp, bg) -- update all bars for merged bar group into same display bar group
							end
						end
						Nest_SetBarGroupAlpha(bg, MOD.status.inCombat and bp.bgCombatAlpha or bp.bgNormalAlpha, bp.mouseAlpha)
					end				
					UpdateGhostBars(bp, bg) -- create and/or update ghost bars in this bar group
					UpdateTestBars(bp, bg) -- update any unexpired test bars in this bar group
					Nest_DeleteBarsWithAttribute(bg, "updated", false) -- then, remove any bars in the group that weren't updated
				else -- if not then hide any bars that might be around
					Nest_DeleteAllBars(bg)
				end
			end
		end
	end
	MOD:UpdatePositions()
end
