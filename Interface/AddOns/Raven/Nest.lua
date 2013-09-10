-- Nest is a graphics package that is optimized to display Raven's bar groups.
-- Bar groups share layout and appearance options (dimensions, fonts, textures, configuration, special effects).
-- Each bar has a fixed set of graphical components (icon, iconText, foreground bar, background bar, labelText, timeText, spark).

local L = LibStub("AceLocale-3.0"):GetLocale("Raven")

Nest_SupportedConfigurations = { -- table of configurations can be used in dialogs to select appropriate options
	[1] = { name = L["Right-to-left bars, label left, icon left"], iconOnly = false, bars = "r2l", label = "left", icon = "left" },
	[2] = { name = L["Left-to-right bars, label left, icon left"], iconOnly = false, bars = "l2r", label = "left", icon = "left" },
	[3] = { name = L["Right-to-left bars, label right, icon left"], iconOnly = false, bars = "r2l", label = "right", icon = "left" },
	[4] = { name = L["Left-to-right bars, label right, icon left"], iconOnly = false, bars = "l2r", label = "right", icon = "left" },
	[5] = { name = L["Right-to-left bars, label left, icon right"], iconOnly = false, bars = "r2l", label = "left", icon = "right" },
	[6] = { name = L["Left-to-right bars, label left, icon right"], iconOnly = false, bars = "l2r", label = "left", icon = "right" },
	[7] = { name = L["Right-to-left bars, label right, icon right"], iconOnly = false, bars = "r2l", label = "right", icon = "right" },
	[8] = { name = L["Left-to-right bars, label right, icon right"], iconOnly = false, bars = "l2r", label = "right", icon = "right" },
	[9] = { name = L["Icons in rows, with right-to-left mini-bars"], iconOnly = true, bars = "r2l", orientation = "horizontal" },
	[10] = { name = L["Icons in rows, with left-to-right mini-bars"], iconOnly = true, bars = "l2r", orientation = "horizontal" },
	[11] = { name = L["Icons in columns, right-to-left mini-bars"], iconOnly = true, bars = "r2l", orientation = "vertical" },
	[12] = { name = L["Icons in columns, left-to-right mini-bars"], iconOnly = true, bars = "l2r", orientation = "vertical" },
	[13] = { name = L["Icons on horizontal timeline, no mini-bars"], iconOnly = true, bars = "timeline", orientation = "horizontal" },
	[14] = { name = L["Icons on vertical timeline, no mini-bars"], iconOnly = true, bars = "timeline", orientation = "vertical" },
}
Nest_MaxBarConfiguration = 8

local barGroups = {} -- current barGroups
local usedBarGroups = {} -- cache of recycled barGroups
local usedBars = {} -- cache of recycled bars
local update = false -- set whenever a global change has occured
local buttonName = 0 -- incremented for each button created
local callbacks = {} -- registered callback functions
local animationPool = {} -- pool of available animations
local animations = {} -- active animations
local displayWidth, displayHeight = UIParent:GetWidth(), UIParent:GetHeight()
local defaultBackdropColor = { r = 1, g = 1, b = 1, a = 1 }
local pixelScale = 1 -- adjusted by screen resolution and uiScale
local pixelPerfect -- global setting to enable pixel perfect size and position
local rectIcons = false -- allow rectangular icons
local inPetBattle = nil

local MSQ = nil -- Masque support
local MSQ_ButtonData = nil

local anchorDefaults = { -- backdrop initialization for bar group anchors
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 8, edgeSize = 8, insets = { left = 2, right = 2, top = 2, bottom = 2 }
}

local bgTemplate = { -- these fields are cleared when a bar group is deleted
	barWidth  = 0, barHeight = 0, iconSize = 0, scale = 0, spacingX = 0, spacingY = 0, iconOffsetX = 0, iconOffsetY = 0,
	labelOffset = 0, labelInset = 0, labelWrap = 0, labelAlign = 0, labelCenter = 0,
	timeOffset = 0, timeInset = 0, timeAlign = 0, timeIcon = 0, iconOffset = 0, iconInset = 0,
	configuration = 0, reverse = 0, wrap = 0, wrapDirection = 0, snapCenter = 0, maxBars = 0, width = 0, height = 0,
	labelFont = 0, labelFSize = 0, labelAlpha = 0, labelColor = 0, labelFlags = 0, labelShadow = 0,
	timeFont = 0, timeFSize = 0, timeAlpha = 0, timeColor = 0, timeFlags = 0, timeShadow = 0,
	iconFont = 0, iconFSize = 0, iconAlpha = 0, iconColor = 0, iconFlags = 0, iconShadow = 0,
	fgTexture = 0, bgTexture = 0, fgAlpha = 0, bgAlpha = 0, fgSaturation = 0, fgBrightness = 0, bgSaturation = 0, bgBrightness = 0,
	timeFormat = 0, timeSpaces = 0, timeCase = 0, fgNotTimer = 0,
	showIcon = 0, showCooldown = 0, showBar = 0, showSpark = 0, showLabelText = 0, showTimeText = 0,
	relativeTo = 0, relativeX = 0, relativeY = 0, relativeLastBar = 0, relativeEmpty = 0, relativeRow = 0, relativeColumn = 0,
	lastX = 0, lastY = 0, anchorPoint = 0, borderTexture = 0, borderWidth = 0, borderOffset = 0, borderColor = 0, backdropPanel = 0,
	backdropTexture = 0, backdropWidth = 0, backdropInset = 0, backdropPadding = 0, backdropColor = 0, backdropFill = 0,
	backdropOffsetX = 0, backdropOffsetY = 0, backdropPadW = 0, backdropPadH = 0,
	tlWidth = 0, tlHeight = 0, tlDuration = 0, tlScale = 0, tlHide = 0, tlAlternate = 0, tlSwitch = 0,
	tlTexture = 0, tlAlpha = 0, tlColor = 0, tlLabels = 0
}

local barTemplate = { -- these fields are cleared with a bar is deleted
	startTime = 0, offsetTime = 0, timeLeft = 0, duration = 0, maxTime = 0, alpha = 0, flash = 0, label = 0, iconCount = 0, tooltipAnchor = 0,
	soundDone = 0, expireDone = 0, cr = 0, cg = 0, cb = 0, ca = 0, br = 0, bg = 0, bb = 0, ba = 0, ibr = 0, ibg = 0, ibb = 0, iba = 0
}

-- Check if using Tukui skin for icon and bar borders (which may require a reloadui)
local function UseTukui() return Raven.frame.CreateBackdrop and Raven.frame.SetOutside and Raven.db.global.TukuiSkin end
local function GetTukuiFont(font) if Raven.db.global.TukuiFont and ChatFrame1 then return ChatFrame1:GetFont() else return font end end
local function PS(x) if pixelPerfect then return pixelScale * math.floor(x / pixelScale + 0.5) else return x end end

-- Calculate alpha for flashing bars, period is how long the total flash time should last
function Nest_FlashAlpha(maxAlpha, period)
	local frac = GetTime() / period
	frac = frac - math.floor(frac) -- get fractional part of current period
	if frac >= 0.5 then frac = 1 - frac end -- now goes from 0 to 0.5 then back to 0
	return (maxAlpha / 2) + (maxAlpha * frac) -- drops to half of maxAlpha
end

-- Set and confirm frame level, working around potential bug when raising frame level above internal limits
local function SetFrameLevel(frame, level)
	local i = 0
	repeat
		frame:SetFrameLevel(level); local a = frame:GetFrameLevel()
		i = i + 1; if i > 10 then print("Raven: warning SetFrameLevel failed"); return end
	until level == a
end

-- Initialize and return a splash animation based on a bar's icon image
local function BarAnimation(bar, anchor1, frame, anchor2, xoffset, yoffset)
	local tex = bar.iconTexture:GetTexture(); if not tex then return end
	local b = next(animationPool)
	if b then animationPool[b] = nil else
		b = {} -- initializae a new animation
		b.frame = CreateFrame("Frame", nil, UIParent)
		b.frame:SetFrameLevel(bar.frame:GetFrameLevel() + 10)
		b.texture = b.frame:CreateTexture(nil, "ARTWORK") -- texture for the texture to be animated	
		b.anim = b.frame:CreateAnimationGroup()
		b.anim:SetLooping("NONE")
		local scale = b.anim:CreateAnimation("Scale")
		scale:SetScale(3, 3); scale:SetOrigin('CENTER', 0, 0); scale:SetDuration(0.65); scale:SetOrder(1)
		local alpha = b.anim:CreateAnimation("Alpha")
		alpha:SetChange(-1); alpha:SetDuration(0.65); alpha:SetSmoothing("IN"); alpha:SetEndDelay(5); alpha:SetOrder(1)
		b.scale = scale; b.alpha = alpha
	end
	local w, h = bar.icon:GetSize()
	b.frame:ClearAllPoints(); b.frame:SetPoint(anchor1, frame, anchor2, xoffset, yoffset); b.frame:SetSize(w, h); b.frame:Show()
	b.texture:SetTexture(tex); b.texture:ClearAllPoints(); b.texture:SetAllPoints(b.frame); b.texture:Show()
	b.anim:Stop(); b.anim:Play()
	b.endTime = GetTime() + 1 -- stop after one second
	table.insert(animations, b)
end

-- Update active animations, recycling when they are complete
local function UpdateAnimations()
	local now = GetTime()
	for k, b in pairs(animations) do
		if now > b.endTime then
			b.anim:Pause(); animations[k] = nil; animationPool[b] = true
			b.frame:ClearAllPoints(); b.texture:ClearAllPoints(); b.frame:Hide(); b.texture:Hide()
		end
	end
end

-- Show the timeline specific frames for a bar group
local function ShowTimeline(bg)
	local back = bg.background
	if back then
		back:Show(); back.bar:ClearAllPoints(); back.bar:SetAllPoints(back); back.bar:Show()
		if bg.tlTexture then back.bar:SetTexture(bg.tlTexture) end
		local t = bg.tlColor; if t then back.bar:SetVertexColor(t.r, t.g, t.b, t.a) end
		if bg.borderTexture then
			back.backdrop:ClearAllPoints(); back.backdrop:SetPoint("CENTER", back, "CENTER", 0, 0); back.backdrop:Show()
		else
			back.backdrop:Hide()
		end
		for _, v in pairs(back.labels) do if v.hidden then v:Hide() else v:Show() end end
	end
end

-- Hide the timeline specific frames for a bar group
local function HideTimeline(bg)
	local back = bg.background
	if back then
		back:Hide(); back.bar:Hide(); back.backdrop:Hide()
		for _, v in pairs(back.labels) do v:Hide() end
	end
end

-- Calculate the offset for a time value on a timeline
local function Timeline_Offset(bg, t)
	if t >= bg.tlDuration then return bg.tlWidth end
	if t <= 0 then return 0 end
	return bg.tlWidth * ((t / bg.tlDuration) ^ (1 / bg.tlScale))
end

-- Animate bars that are ending on a timeline
local function BarGroup_TimelineAnimation(bg, bar, config)
	local dir = bg.reverse and 1 or -1 -- plus or minus depending on direction
	local isVertical = (config.orientation == "vertical")
	local w, h, edge
	if config.orientation == "horizontal" then
		w = bg.tlWidth; h = bg.tlHeight; edge = bg.reverse and "RIGHT" or "LEFT"
	else
		w = bg.tlHeight; h = bg.tlWidth; edge = bg.reverse and "TOP" or "BOTTOM"
	end
	local delta = Timeline_Offset(bg, 0)
	local x1 = isVertical and 0 or ((delta - w) * dir); local y1 = isVertical and ((delta - h) * dir) or 0
	BarAnimation(bar, edge, bg.background, edge, x1, y1)
end

-- Bar sorting functions: alphabetic, time left, duration, bar's start time
-- Values are assumed equal if difference less than 0.05 seconds
local function sortValues(a, b, f, up)
	if a.group ~= b.group then return a.group < b.group end
	if a.gname ~= b.gname then return a.gname < b.gname end
	if a.sortPlayer then if a.isMine ~= b.isMine then return a.isMine end end -- priority #1: optional isMine for cast by player detection
	if math.abs(a[f] - b[f]) >= 0.05 then if up then return a[f] < b[f] else return a[f] > b[f] end end -- priority #2: selected sort function
	if a.sortTime and (math.abs(a.timeLeft - b.timeLeft) >= 0.05) then return (a.timeLeft < b.timeLeft) end -- priority #3: optional increasing timeLeft
	return a.name < b.name -- priority #4: ascending alphabetic order
end

local function SortTimeDown(a, b) return sortValues(a, b, "timeLeft", false) end
local function SortTimeUp(a, b) return sortValues(a, b, "timeLeft", true) end
local function SortDurationDown(a, b) return sortValues(a, b, "duration", false) end
local function SortDurationUp(a, b) return sortValues(a, b, "duration", true) end
local function SortStartDown(a, b) return sortValues(a, b, "start", false) end
local function SortStartUp(a, b) return sortValues(a, b, "start", true) end

local function SortClassDown(a, b)
	if a.group ~= b.group then return a.group < b.group end
	if a.gname ~= b.gname then return a.gname < b.gname end	
	if a.sortPlayer then if a.isMine ~= b.isMine then return a.isMine end end -- priority #1: optional isMine for cast by player detection
	if a.class ~= b.class then return a.class > b.class end -- priority #2: selected sort function
	if a.sortTime and (math.abs(a.timeLeft - b.timeLeft) >= 0.05) then return (a.timeLeft < b.timeLeft) end -- priority #3: optional increasing timeLeft
	return a.name < b.name -- priority #4: ascending alphabetic order
end

local function SortClassUp(a, b)
	if a.group ~= b.group then return a.group < b.group end
	if a.gname ~= b.gname then return a.gname < b.gname end
	if a.sortPlayer then if a.isMine ~= b.isMine then return a.isMine end end -- priority #1: optional isMine for cast by player detection
	if a.class ~= b.class then return a.class < b.class end -- priority #2: selected sort function
	if a.sortTime and (math.abs(a.timeLeft - b.timeLeft) >= 0.05) then return (a.timeLeft < b.timeLeft) end -- priority #3: optional increasing timeLeft
	return a.name < b.name -- priority #4: ascending alphabetic order
end

local function SortAlphaDown(a, b)
	if a.group ~= b.group then return a.group < b.group end
	if a.gname ~= b.gname then return a.gname < b.gname end
	if a.sortPlayer then if a.isMine ~= b.isMine then return a.isMine end end -- priority #1: optional isMine for cast by player detection
	if a.name ~= b.name then return a.name > b.name end -- priority #2: selected sort function
	if a.sortTime and (math.abs(a.timeLeft - b.timeLeft) >= 0.05) then return (a.timeLeft < b.timeLeft) end -- priority #3: optional increasing timeLeft
	return false -- priority #4: ascending alphabetic order (for alphabetic must be equal at this point)
end

local function SortAlphaUp(a, b)
	if a.group ~= b.group then return a.group < b.group end
	if a.gname ~= b.gname then return a.gname < b.gname end
	if a.sortPlayer then if a.isMine ~= b.isMine then return a.isMine end end -- priority #1: optional isMine for cast by player detection
	if a.name ~= b.name then return a.name < b.name end -- priority #2: selected sort function
	if a.sortTime and (math.abs(a.timeLeft - b.timeLeft) >= 0.05) then return (a.timeLeft < b.timeLeft) end -- priority #3: optional increasing timeLeft
	return false -- priority #4: ascending alphabetic order (for alphabetic must be equal at this point)
end

-- Register callbacks that can be used by internal functions to communicate in special cases
function Nest_RegisterCallbacks(cbs) if cbs then for k, v in pairs(cbs) do callbacks[k] = v end end end

-- Event handling functions for bar group anchors, pass both anchor and bar group
local function BarGroup_OnEvent(anchor, callback)
	local bg, bgName = nil, anchor.bgName
	if bgName then bg = barGroups[bgName] end -- locate the bar group associated with the anchor
	if bg then
		local func = bg.callbacks[callback]
		if func then func(anchor, bgName) end
	end
end

local function BarGroup_OnEnter(anchor) BarGroup_OnEvent(anchor, "onEnter") end
local function BarGroup_OnLeave(anchor) BarGroup_OnEvent(anchor, "onLeave") end

-- OnClick does a callback (except for unmodified left click), passing bar group name and button
local function BarGroup_OnClick(anchor, button)
	local bg, bgName = nil, anchor.bgName
	if bgName then bg = barGroups[bgName] end -- locate the bar group associated with the anchor
	if ((button ~= "LeftButton") or IsModifierKeyDown()) and bg and not bg.locked then
		local func = bg.callbacks.onClick -- only pass left clicks if no modifier key is down
		if func then func(anchor, bgName, button) end
	end
end

-- OnMouseDown with no modifier key starts moving if frame unlocked and does callback, passing bar group name
local function BarGroup_OnMouseDown(anchor, button)
	local bg, bgName = nil, anchor.bgName
	if bgName then bg = barGroups[bgName] end -- locate the bar group associated with the anchor
	if (button == "LeftButton") and not IsModifierKeyDown() and bg and not bg.locked then
		bg.startX = bg.frame:GetLeft(); bg.startY = bg.frame:GetTop()
		bg.moving = true
		bg.frame:SetFrameStrata("HIGH")
		bg.frame:StartMoving()
		local func = bg.callbacks.onMove -- called to start movement as long as no modifier key is down
		if func then func(anchor, bgName) end
	end
end

-- OnMouseUp stops moving if frame is in motion and does a callback passing bar group name to indicate movement
local function BarGroup_OnMouseUp(anchor, button)
	local bg, bgName = nil, anchor.bgName
	if bgName then bg = barGroups[bgName] end -- locate the bar group associated with the anchor
	if bg and bg.moving then
		bg.frame:StopMovingOrSizing()
		bg.frame:SetFrameStrata(bg.strata or "MEDIUM")
		local func = bg.callbacks.onMove
		if func then
			local endX = bg.frame:GetLeft(); local endY = bg.frame:GetTop()
			if bg.startX ~= endX or bg.startY ~= endY then func(anchor, bgName) end -- only fires if actually moved
		end
		bg.moving = false
	end
end

-- Initialize and return a new bar group containing either timer bars or enhanced icons
function Nest_CreateBarGroup(name)
	if barGroups[name] then return nil end -- already have one with that name
	local n, bg = next(usedBarGroups) -- get any available recycled bar group
	if n then
		usedBarGroups[n] = nil
	else
		bg = {}
		local xname = string.gsub(name, " ", "_")
		bg.frame = CreateFrame("Frame", "RavenBarGroup" .. xname, UIParent) -- add name for reference from other addons
		bg.frame:SetFrameLevel(bg.frame:GetFrameLevel() + 20) -- higher than other addons
		bg.frame:SetMovable(true); bg.frame:SetClampedToScreen(true)
		bg.frame:ClearAllPoints(); bg.frame:SetPoint("CENTER", UIParent, "CENTER")	
		bg.backdrop = CreateFrame("Frame", "RavenBarGroupBackdrop" .. xname, bg.frame)
		bg.backdropTable = { tile = false, insets = { left = 2, right = 2, top = 2, bottom = 2 }}
		bg.borderTable = { tile = false, insets = { left = 2, right = 2, top = 2, bottom = 2 }}
		bg.anchor = CreateFrame("Button", nil, bg.frame)
		bg.anchor:SetBackdrop(anchorDefaults)
		bg.anchor:SetBackdropColor(0.3, 0.3, 0.3, 0.9)
		bg.anchor:SetBackdropBorderColor(0, 0, 0, 0.9)
		bg.anchor:SetNormalFontObject(ChatFontSmall)
		bg.anchor:SetFrameLevel(bg.frame:GetFrameLevel() + 20) -- higher than the bar group frame
		bg.bars = {}
		bg.sorter = {}
		bg.attributes = {}
		bg.callbacks = {}
		bg.position = {}
		bg.sortFunction = SortAlphaUp
		bg.locked = false; bg.moving = false
		bg.count = 0
	end
	bg.anchor.bgName = name
	bg.anchor:SetScript("OnMouseDown", BarGroup_OnMouseDown)
	bg.anchor:SetScript("OnMouseUp", BarGroup_OnMouseUp)
	bg.anchor:SetScript("OnClick", BarGroup_OnClick)
	bg.anchor:SetScript("OnEnter", BarGroup_OnEnter)
	bg.anchor:SetScript("OnLeave", BarGroup_OnLeave)
	bg.anchor:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	bg.anchor:EnableMouse(true)
	table.wipe(bg.position)
	bg.name = name
	if MSQ then bg.MSQ_Group = MSQ:Group("Raven", name) end
	bg.update = true
	barGroups[name] = bg
	update = true
	return bg
end

-- Return the bar group with the specified name
function Nest_GetBarGroup(name) return barGroups[name] end

-- Return the table of bar groups
function Nest_GetBarGroups() return barGroups end

-- Delete a bar group and move it to the recycled bar group table
function Nest_DeleteBarGroup(bg)
	for _, bar in pairs(bg.bars) do Nest_DeleteBar(bg, bar) end -- empty out bars table
	for n in pairs(bg.sorter) do bg.sorter[n] = nil end -- empty the sorting table
	for n in pairs(bg.attributes) do bg.attributes[n] = nil end
	for n in pairs(bg.callbacks) do bg.callbacks[n] = nil end
	for n in pairs(bgTemplate) do bg[n] = nil end -- reset current bar group settings
	bg.frame:ClearAllPoints(); bg.frame:SetPoint("CENTER", UIParent, "CENTER") -- return to neutral position
	bg.anchor:SetScript("OnMouseDown", nil)
	bg.anchor:SetScript("OnMouseUp", nil)
	bg.anchor:SetScript("OnClick", nil)
	bg.anchor:SetScript("OnEnter", nil)
	bg.anchor:SetScript("OnLeave", nil)
	bg.anchor:EnableMouse(false)
	bg.anchor.bgName = nil
	bg.sortFunction = SortAlphaUp; bg.sortTime = nil; bg.sortPlayer = nil
	bg.count = 0
	bg.locked = false; bg.moving = false
	if bg.MSQ_Group then bg.MSQ_Group:Delete() end
	bg.update = false
	bg.anchor:Hide(); bg.backdrop:Hide(); HideTimeline(bg)
	barGroups[bg.name] = nil
	bg.name = nil
	table.insert(usedBarGroups, bg)
	update = true
end

-- Set layout options for a bar group
function Nest_SetBarGroupBarLayout(bg, barWidth, barHeight, iconSize, scale, spacingX, spacingY, iconOffsetX, iconOffsetY,
			labelOffset, labelInset, labelWrap, labelAlign, labelCenter, timeOffset, timeInset, timeAlign, timeIcon, iconOffset, iconInset,
			iconHide, iconAlign, configuration, reverse, wrap, wrapDirection, snapCenter, fillBars, maxBars, strata)
	bg.barWidth = PS(barWidth); bg.barHeight = PS(barHeight); bg.iconSize = PS(iconSize); bg.scale = scale or 1
	bg.fillBars = fillBars; bg.maxBars = maxBars; bg.strata = strata
	bg.spacingX = PS(spacingX or 0); bg.spacingY = PS(spacingY or 0); bg.iconOffsetX = (iconOffsetX or 0); bg.iconOffsetY = PS(iconOffsetY or 0)
	bg.labelOffset = PS(labelOffset or 0); bg.labelInset = PS(labelInset or 0); bg.labelWrap = labelWrap;
	bg.labelCenter = labelCenter; bg.labelAlign = labelAlign or "MIDDLE"
	bg.timeOffset = PS(timeOffset or 0); bg.timeInset = PS(timeInset or 0); bg.timeAlign = timeAlign or "normal"; bg.timeIcon = timeIcon
	bg.iconOffset = PS(iconOffset or 0); bg.iconInset = PS(iconInset or 0); bg.iconHide = iconHide; bg.iconAlign = iconAlign or "CENTER"
	bg.configuration = configuration or 1; bg.reverse = reverse; bg.wrap = wrap or 0; bg.wrapDirection = wrapDirection; bg.snapCenter = snapCenter
	bg.update = true
end

local function TextFlags(outline, thick, mono)
	local t = nil
	if not outline and not thick then mono = false end -- XXXX workaround for blizzard bugs caused by use of monochrome text flag by itself
	if mono then
		if outline then if thick then t = "MONOCHROME,OUTLINE,THICKOUTLINE" else t = "MONOCHROME,OUTLINE" end
		else if thick then t = "MONOCHROME,THICKOUTLINE" else t = "MONOCHROME" end end
	else
		if outline then if thick then t = "OUTLINE,THICKOUTLINE" else t = "OUTLINE" end
		else if thick then t = "THICKOUTLINE" end end
	end
	return t
end

-- Set label font options for a bar group
function Nest_SetBarGroupLabelFont(bg, font, fsize, alpha, color, outline, shadow, thick, mono)
	if not color then color = { r = 1, g = 1, b = 1, a = 1 } end
	if UseTukui() then font = GetTukuiFont(font) end
	bg.labelFont = font; bg.labelFSize = fsize or 9; bg.labelAlpha = alpha or 1; bg.labelColor = color
	bg.labelFlags = TextFlags(outline, thick, mono); bg.labelShadow = shadow
	bg.update = true
end

-- Set time text font options for a bar group
function Nest_SetBarGroupTimeFont(bg, font, fsize, alpha, color, outline, shadow, thick, mono)
	if not color then color = { r = 1, g = 1, b = 1, a = 1 } end
	if UseTukui() then font = GetTukuiFont(font) end
	bg.timeFont = font; bg.timeFSize = fsize or 9; bg.timeAlpha = alpha or 1; bg.timeColor = color
	bg.timeFlags = TextFlags(outline, thick, mono); bg.timeShadow = shadow
	bg.update = true
end

-- Set icon text font options for a bar group
function Nest_SetBarGroupIconFont(bg, font, fsize, alpha, color, outline, shadow, thick, mono)
	if not color then color = defaultBackdropColor end; if not fill then fill = defaultBackdropColor end
	if UseTukui() then font = GetTukuiFont(font) end
	bg.iconFont = font; bg.iconFSize = fsize or 9; bg.iconAlpha = alpha or 1; bg.iconColor = color
	bg.iconFlags = TextFlags(outline, thick, mono); bg.iconShadow = shadow
	bg.update = true
end

-- Set bar border options for a bar group
function Nest_SetBarGroupBorder(bg, texture, width, offset, color)
	if not color then color = defaultBackdropColor end
	bg.borderTexture = texture; bg.borderWidth = PS(width); bg.borderOffset = PS(offset); bg.borderColor = color
	bg.update = true
end

-- Set backdrop options for a bar group
function Nest_SetBarGroupBackdrop(bg, panel, texture, width, inset, padding, color, fill, offsetX, offsetY, padW, padH)
	if not color then color = { r = 1, g = 1, b = 1, a = 1 } end
	if not fill then fill = { r = 1, g = 1, b = 1, a = 1 } end
	bg.backdropPanel = panel; bg.backdropTexture = texture; bg.backdropWidth = PS(width); bg.backdropInset = PS(inset or 0)
	bg.backdropPadding = PS(padding or 0); bg.backdropColor = color; bg.backdropFill = fill
	bg.backdropOffsetX = PS(offsetX or 0); bg.backdropOffsetY = PS(offsetY or 0); bg.backdropPadW = PS(padW or 0); bg.backdropPadH = PS(padH or 0)
	bg.update = true
end

-- Set texture options for a bar group
function Nest_SetBarGroupTextures(bg, fgTexture, fgAlpha, bgTexture, bgAlpha, fgNotTimer, fgSaturation, fgBrightness, bgSaturation, bgBrightness)
	bg.fgTexture = fgTexture; bg.fgAlpha = fgAlpha; bg.bgTexture = bgTexture; bg.bgAlpha = bgAlpha; bg.fgNotTimer = fgNotTimer
	bg.fgSaturation = fgSaturation or 0; bg.fgBrightness = fgBrightness or 0; bg.bgSaturation = bgSaturation or 0; bg.bgBrightness = bgBrightness or 0
	bg.update = true
end

-- Select visible components for a bar group
function Nest_SetBarGroupVisibles(bg, icon, cooldown, bar, spark, labelText, timeText)
	bg.showIcon = icon; bg.showCooldown = cooldown; bg.showBar = bar; bg.showSpark = spark
	bg.showLabelText = labelText; bg.showTimeText = timeText
	bg.update = true
end

-- Set parameters related to timeline configurations
function Nest_SetBarGroupTimeline(bg, w, h, duration, scale, hide, alternate, switch, splash, texture, alpha, color, labels)
	bg.tlWidth = PS(w); bg.tlHeight = PS(h); bg.tlDuration = duration; bg.tlScale = scale; bg.tlHide = hide; bg.tlAlternate = alternate
	bg.tlSwitch = switch; bg.tlSplash = splash; bg.tlTexture = texture; bg.tlAlpha = alpha; bg.tlColor = color; bg.tlLabels = labels
	bg.update = true
end

-- Sort the bars in a bar group using the designated sort method and direction (default is sort by name alphabetically)
function Nest_BarGroupSortFunction(bg, sortMethod, sortDirection, sortTime, sortPlayer)
	if sortMethod == "time" then -- sort by time left on the bar
		if sortDirection then bg.sortFunction = SortTimeDown else bg.sortFunction = SortTimeUp end
	elseif sortMethod == "duration" then -- sort by bar duration
		if sortDirection then bg.sortFunction = SortDurationDown else bg.sortFunction = SortDurationUp end
	elseif sortMethod == "start" then -- sort by bar start time
		if sortDirection then bg.sortFunction = SortStartDown else bg.sortFunction = SortStartUp end
	elseif sortMethod == "class" then -- sort by bar class
		if sortDirection then bg.sortFunction = SortClassDown else bg.sortFunction = SortClassUp end
	else -- default is sort alphabetically by bar name
		if sortDirection then bg.sortFunction = SortAlphaDown else bg.sortFunction = SortAlphaUp end
	end
	bg.sortTime = sortTime; bg.sortPlayer = sortPlayer
	bg.update = true
end

-- Set the time format function for the bar group, if not set will use default
function Nest_SetBarGroupTimeFormat(bg, timeFormat, timeSpaces, timeCase)
	bg.timeFormat = timeFormat; bg.timeSpaces = timeSpaces; bg.timeCase = timeCase
	bg.update = true
end

-- If locked is true then lock the bar group anchor, otherwise unlock it
function Nest_SetBarGroupLock(bg, locked)
	bg.locked = locked
	bg.update = true
end

-- Return a bar group's display position as percentages of actual display size to edges of the anchor frame
-- Return values are descaled to match UIParent and include left, right, bottom and top plus descaled width and height
function Nest_GetAnchorPoint(bg)
	local scale = bg.scale or 1
	local dw, dh = displayWidth, displayHeight
	local w, h = bg.frame:GetWidth() * scale, bg.frame:GetHeight() * scale
	local left, bottom = bg.frame:GetLeft(), bg.frame:GetBottom() -- get scaled coordinates for frame's anchor
	if left and bottom then left = (left * scale); bottom = (bottom * scale) else left = dw / 2; bottom = dh / 2 end -- default to center
	local right, top = dw - (left + w), dh - (bottom + h)
	local p = bg.position; p.left, p.right, p.bottom, p.top, p.width, p.height = left / dw, right / dw, bottom / dh, top / dh, w, h
	return p.left, p.right, p.bottom, p.top, p.width, p.height
end

-- Set a bar group's scaled display position from left, right, bottom, top where left and bottom should always be valid
-- Use right, top, width and height only if valid and closer to that edge to fix position shift when UIParent dimensions change
function Nest_SetAnchorPoint(bg, left, right, bottom, top, scale, width, height)
	if left and bottom and width and height then -- make sure valid settings
		bg.scale = scale -- make sure save scale since may not have been initialized yet
		local p = bg.position; p.left, p.right, p.bottom, p.top, p.width, p.height = left, right, bottom, top, width, height
		local dw, dh = displayWidth, displayHeight
		local xoffset = left * dw
		local yoffset = bottom * dh
		if right and top and width and height then -- optionally set from other edges if closer to them
			if left > 0.5 then xoffset = dw - (right * dw) - width end
			if bottom > 0.5 then yoffset = dh - (top * dh) - height end
		end
		bg.frame:SetScale(scale); bg.frame:SetSize(width, height)
		bg.frame:ClearAllPoints(); bg.frame:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", PS(xoffset / scale), PS(yoffset / scale))
	end
end

-- Set a bar group's display position as relative to another bar group
function Nest_SetRelativeAnchorPoint(bg, rTo, rFrame, rPoint, rX, rY, rLB, rEmpty, rRow, rColumn)
	if rFrame and GetClickFrame(rFrame) then -- set relative to a specific frame
		bg.frame:ClearAllPoints(); bg.frame:SetPoint(rPoint or "CENTER", rFrame, rPoint or "CENTER", PS(rX), PS(rY))
		bg.relativeTo = nil -- remove relative anchor point	
	elseif bg.relativeTo and not rTo then -- removing a relative anchor point
		local left, bottom = bg.frame:GetLeft(), bg.frame:GetBottom()
		bg.frame:ClearAllPoints(); bg.frame:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", PS(left), PS(bottom))
		bg.relativeTo = nil -- remove relative anchor point
	else
		bg.relativeTo = rTo -- if relativeTo is nil then relative anchor point is not set
		bg.relativeX = rX; bg.relativeY = rY; bg.relativeLastBar = rLB; bg.relativeEmpty = rEmpty; bg.relativeRow = rRow; bg.relativeColumn = rColumn
	end
end

-- Set callbacks for a bar group
function Nest_SetBarGroupCallbacks(bg, onMove, onClick, onEnter, onLeave)
	bg.callbacks.onMove = onMove; bg.callbacks.onClick = onClick; bg.callbacks.onEnter = onEnter; bg.callbacks.onLeave = onLeave	
end

-- Set opacity for a bar group, including mouseover override
function Nest_SetBarGroupAlpha(bg, alpha, mouseAlpha) bg.alpha = alpha or 1; bg.mouseAlpha = mouseAlpha or 1 end

-- Set a bar group attribute. This is the mechanism to associate application-specific data with bar groups.
function Nest_SetBarGroupAttribute(bg, name, value) bg.attributes[name] = value end

-- Get a bar group attribute. This is the mechanism to associate application-specific data with bar groups.
function Nest_GetBarGroupAttribute(bg, name) return bg.attributes[name] end

-- Set an attribute for all bars in the bar group
function Nest_SetAllAttributes(bg, name, value)
	for _, bar in pairs(bg.bars) do bar.attributes[name] = value end
end

-- Delete all bars in the bar group with the specifed attribute value (useful for mark/sweep garbage collection)
function Nest_DeleteBarsWithAttribute(bg, name, value)
	for barName, bar in pairs(bg.bars) do
		if bar.attributes[name] == value then Nest_DeleteBar(bg, bar) end
	end
end

-- Event handling functions for bars with callback
local function Bar_OnEvent(frame, callback, value)
	local bg, bgName, name = nil, frame.bgName, frame.name
	if bgName then bg = barGroups[bgName] end -- locate the bar group associated with the anchor
	if bg then
		local bar = bg.bars[name]
		if bar then
			if not value then value = bar.tooltipAnchor end
			local func = bar.callbacks[callback]
			if func then func(frame, bgName, name, value) end
		end
	end
end

local function Bar_OnEnter(frame) Bar_OnEvent(frame, "onEnter") end
local function Bar_OnLeave(frame) Bar_OnEvent(frame, "onLeave") end
local function Bar_OnClick(frame, button) Bar_OnEvent(frame, "onClick", button) end

local function GetButtonName() buttonName = buttonName + 1; return "RavenButton" .. tostring(buttonName) end -- unique button name

-- Initialize and return a new bar
function Nest_CreateBar(bg, name)
	if bg.bars[name] then return nil end -- already have one with that name
	local n, bar = next(usedBars) -- get any available recycled bar
	if n then
		usedBars[n] = nil
		bar.frame:SetParent(bg.frame)
	else
		local bname = GetButtonName()
		bar = {}
		bar.frame = CreateFrame("Frame", bname .. "Frame", bg.frame)
		bar.container = CreateFrame("Frame", bname .. "Container", bar.frame)
		bar.fgTexture = bar.container:CreateTexture(nil, "BACKGROUND", nil, 2)	
		bar.bgTexture = bar.container:CreateTexture(nil, "BACKGROUND", nil, 1)
		bar.backdrop = CreateFrame("Frame", bname .. "Backdrop", bar.container)
		bar.spark = bar.container:CreateTexture(nil, "OVERLAY")
		bar.spark:SetTexture([[Interface\CastingBar\UI-CastingBar-Spark]])
		bar.spark:SetSize(10, 10)
		bar.spark:SetBlendMode("ADD")
		bar.spark:SetTexCoord(0, 1, 0, 1)	
		bar.textFrame = CreateFrame("Frame", bname .. "TextFrame", bar.container)
		bar.labelText = bar.textFrame:CreateFontString(nil, "OVERLAY")		
		bar.timeText = bar.textFrame:CreateFontString(nil, "OVERLAY")
		bar.icon = CreateFrame("Button", bname, bar.frame)
		bar.iconTexture = bar.icon:CreateTexture(bname .. "IconTexture", "ARTWORK") -- texture for the bar's icon
		bar.cooldown = CreateFrame("Cooldown", bname .. "Cooldown", bar.frame) -- cooldown overlay to animate timer
		bar.cooldown.noCooldownCount = Raven.db.global.HideOmniCC
		bar.cooldown.noOCC = Raven.db.global.HideOmniCC -- added for Tukui
		bar.iconTextFrame = CreateFrame("Frame", bname .. "IconTextFrame", bar.frame)
		bar.iconText = bar.iconTextFrame:CreateFontString(nil, "OVERLAY", nil, 4)
		bar.iconBorder = bar.iconTextFrame:CreateTexture(nil, "BACKGROUND", nil, 3)		
		if UseTukui() then
			bar.frame:CreateBackdrop("Transparent"); bar.frame.backdrop:SetOutside(bar.frame)
			bar.tukcolor_r, bar.tukcolor_g, bar.tukcolor_b, bar.tukcolor_a = bar.frame.backdrop:GetBackdropBorderColor() -- save default border color
		end
		
		local anim = bar.icon:CreateAnimationGroup()
		anim:SetLooping("NONE")
		local grow = anim:CreateAnimation("Scale")
		grow:SetScale(3, 3); grow:SetOrigin('CENTER', 0, 0); grow:SetDuration(0.25); grow:SetOrder(1)
		local shrink = anim:CreateAnimation("Scale")
		shrink:SetScale(-3, -3); shrink:SetOrigin('CENTER', 0, 0); shrink:SetDuration(0.25); shrink:SetOrder(2)
		bar.icon.anim = anim
		
		if MSQ then -- if using ButtonFacade, create and initialize a button data table
			bar.buttonData = {} -- only initialize once so no garbage collection issues
			for k, v in pairs(MSQ_ButtonData) do bar.buttonData[k] = v end
		end

		bar.attributes = {}
		bar.callbacks = {}
	end
	bar.frame:SetFrameLevel(bg.frame:GetFrameLevel() + 5)
	bar.frame.name = name
	bar.frame.bgName = bg.name
	bar.frame:SetScript("OnMouseUp", Bar_OnClick)
	bar.frame:SetScript("OnEnter", Bar_OnEnter)
	bar.frame:SetScript("OnLeave", Bar_OnLeave)
	bar.icon.name = name
	bar.icon.bgName = bg.name
	bar.icon:SetScript("OnMouseUp", Bar_OnClick)
	bar.icon:SetScript("OnEnter", Bar_OnEnter)
	bar.icon:SetScript("OnLeave", Bar_OnLeave)
	bar.icon:RegisterForClicks("LeftButtonUp", "RightButtonUp")
	if UseTukui() then bar.frame:Show(); bar.container:Show() end
	bar.startTime = GetTime()
	bar.name = name
	bar.update = true
	bg.bars[name] = bar
	bg.count = bg.count + 1
	bg.sorter[bg.count] = { name = name }
	bg.update = true
	return bar
end

-- Return the bar with the specified name
function Nest_GetBar(bg, name) return bg.bars[name] end

-- Return the bars table for a bar group
function Nest_GetBars(bg) return bg.bars end

-- Delete a bar from a bar group, moving it to recycled bar table
function Nest_DeleteBar(bg, bar)
	local config = Nest_SupportedConfigurations[bg.configuration]
	if config.bars == "timeline" and bg.tlSplash then BarGroup_TimelineAnimation(bg, bar, config) end
	if bar.attributes.soundEnd then PlaySoundFile(bar.attributes.soundEnd, Raven.db.global.SoundChannel) end
	for n in pairs(bar.attributes) do bar.attributes[n] = nil end
	for n in pairs(bar.callbacks) do bar.callbacks[n] = nil end
	for n in pairs(barTemplate) do bar[n] = nil end -- reset current bar settings
	bar.icon:EnableMouse(false); bar.frame:EnableMouse(false)
	bar.frame:SetScript("OnMouseUp", nil)
	bar.frame:SetScript("OnEnter", nil)
	bar.frame:SetScript("OnLeave", nil)
	bar.frame.name = nil
	bar.frame.bgName = nil
	bar.icon:SetScript("OnMouseUp", nil)
	bar.icon:SetScript("OnEnter", nil)
	bar.icon:SetScript("OnLeave", nil)
	bar.icon.name = nil
	bar.icon.bgName = nil
	bar.icon.anim:Stop()
	bar.cooldown:SetCooldown(0, 0)
	bar.iconPath = nil
	bar.update = false
	bar.backdrop:Hide(); bar.fgTexture:Hide(); bar.bgTexture:Hide(); bar.spark:Hide(); bar.icon:Hide(); bar.cooldown:Hide()
	bar.iconText:Hide(); bar.labelText:Hide(); bar.timeText:Hide(); bar.iconBorder:Hide()
	bar.backdrop:ClearAllPoints(); bar.fgTexture:ClearAllPoints(); bar.bgTexture:ClearAllPoints(); bar.spark:ClearAllPoints()
	bar.icon:ClearAllPoints(); bar.cooldown:ClearAllPoints(); bar.iconText:ClearAllPoints()
	bar.labelText:ClearAllPoints(); bar.timeText:ClearAllPoints(); bar.iconBorder:ClearAllPoints()
	if callbacks.release then callbacks.release(bar) end
	
	if UseTukui() then bar.frame:Hide(); bar.container:Hide() end -- no need to reset default border colors since won't change once set
	
	local i = 1
	while i <= bg.count do -- find and remove the corresponding entry in the sorting table
		if bg.sorter[i].name == bar.name then
			if i ~= bg.count then bg.sorter[i] = bg.sorter[bg.count] end -- copy last one to fill the hole
			bg.sorter[bg.count] = nil
			bg.count = bg.count - 1
			break
		end
		i = i + 1
	end
	bg.bars[bar.name] = nil
	bar.name = nil
	table.insert(usedBars, bar)
	bg.update = true
end

-- Delete all bars in a bar group
function Nest_DeleteAllBars(bg)
	for barName, bar in pairs(bg.bars) do Nest_DeleteBar(bg, bar) end
end

-- Start (or restart) a timer bar, note that maxTime is the display maximum which may be less than duration
function Nest_StartTimer(bar, timeLeft, duration, maxTime)
	bar.startTime = GetTime() -- time the timer bar was started (or restarted, which counts as a new timer)
	bar.offsetTime = duration - timeLeft -- save offset since may be sent multiple times
	bar.timeLeft = timeLeft; bar.duration = duration; bar.maxTime = maxTime or duration
	bar.expireDone = nil; bar.warningDone = nil; bar.update = true
end

-- Return true if time parameters have been set for a bar
function Nest_IsTimer(bar) return bar.timeLeft ~= nil end

-- Get the time parameters for a bar, including adjusted timeLeft amount
function Nest_GetTimes(bar) return bar.timeLeft, bar.duration, bar.maxTime, bar.startTime, bar.offsetTime end

-- Set bar colors, includes foreground, background and icon border codes
function Nest_SetColors(bar, cr, cg, cb, ca, br, bg, bb, ba, ibr, ibg, ibb, iba)
	bar.cr = cr; bar.cg = cg; bar.cb = cb; bar.ca = ca
	bar.br = br; bar.bg = bg; bar.bb = bb; bar.ba = ba
	bar.ibr = ibr; bar.ibg = ibg; bar.ibb = ibb; bar.iba = iba
end

-- Set the overall alpha for a bar, this is last alpha adjustment made before bar is displayed
function Nest_SetAlpha(bar, alpha) bar.alpha = alpha end

-- Set whether the bar should flash or not
function Nest_SetFlash(bar, flash) bar.flash = flash end

-- Set the label text for a bar
function Nest_SetLabel(bar, label) bar.label = label end

-- Set the value and maximum value for a non-timer bar
function Nest_SetValue(bar, value, maxValue) bar.value = value; bar.maxValue = maxValue end

-- Set the icon texture for a bar
function Nest_SetIcon(bar, icon) bar.iconPath = icon end

-- Set the numeric value to display on the bar's icon
function Nest_SetCount(bar, iconCount) bar.iconCount = iconCount end

-- Set a bar attribute. This is the mechanism to associate application-specific data with bars.
function Nest_SetAttribute(bar, name, value) bar.attributes[name] = value end

-- Get a bar attribute. This is the mechanism to associate application-specific data with bars.
function Nest_GetAttribute(bar, name) return bar.attributes[name] end

-- Set callbacks for a bar
function Nest_SetCallbacks(bar, onClick, onEnter, onLeave)
	bar.callbacks.onClick = onClick; bar.callbacks.onEnter = onEnter; bar.callbacks.onLeave = onLeave	
end

-- Set saturation and brightness of RGB colors by converting into HSL, adjusting saturation, then converting back to RGB
-- Input color RGB components are values between 0 to 1.0, saturation and brightness are values between -1.0 and 1.0
local function LevelAdjust(v, a) -- apply adjustment in range -1..+1 to either saturation or brightness
	if a ~= 0 then if a >= -1 and a < 0 then return v * (a + 1) elseif a > 0 and a <= 1 then return v + ((1 - v) * a) end end
	return v
end

function Nest_AdjustColor(r, g, b, saturation, brightness)
	if not r or not g or not b then return 0.5, 0.5, 0.5 end -- avoid errors if passed in nil values
	if not saturation then saturation = 0 end; if not brightness then brightness = 0 end -- set to default values
	if (saturation == 0) and (brightness == 0) then return r, g, b end	
	local ch, cs, cl, v, m, sv, h, sextant, fract, mid1, mid2, r2, g2, b2, vsf
	local mincolor, maxcolor = math.min(r, g, b), math.max(r, g, b)
	if mincolor == maxcolor then
		ch, cs, cl = 0, 0, r
	else
		v = maxcolor - mincolor; cl = (mincolor + maxcolor) / 2	
		if cl < 0.5 then cs = v / (maxcolor + mincolor) else cs = v / (2 - maxcolor - mincolor) end	
		r2 = (maxcolor - r) / v; g2 = (maxcolor - g) / v; b2 = (maxcolor - b) / v	
		if r == maxcolor then
			if g == mincolor then ch = b2 + 5 else ch = 1 - g2 end
		elseif g == maxcolor then
			if b == mincolor then ch = r2 + 1 else ch = 3 - b2 end
		else
			if r == mincolor then ch = g2 + 3 else ch = 5 - r2 end
		end		
		ch = ch / 6
	end
	if saturation < -1 then saturation = -1 elseif saturation > 1 then saturation = 1 end
	cs = LevelAdjust(cs, saturation) -- adjust the saturation, using original -1 .. +1 scale
	if brightness < -1 then brightness = -1 elseif brightness > 1 then brightness = 1 end
	cl = LevelAdjust(cl, brightness / 2) -- adjust the brightness, restricting the range to -0.5 to +0.5
	r, g, b = cl, cl, cl
	if cl <= 0.5 then v = cl * (1 + cs) else v = (cl + cs) - (cl * cs) end
	if v > 0 then
		m = cl + cl - v; sv = (v - m) / v; h = ch * 6
		sextant = math.floor(h); fract = h - sextant; vsf = v * sv * fract
		mid1 = m + vsf; mid2 = v - vsf
		if sextant == 0 then
			r, g, b = v, mid1, m
		elseif sextant == 1 then
			r, g, b = mid2, v, m
		elseif sextant == 2 then
			r, g, b = m, v, mid1
		elseif sextant == 3 then
			r, g, b = m, mid2, v
		elseif sextant == 4 then
			r, g, b = mid1, m, v
		elseif sextant == 5 then
			r, g, b = v, m, mid2
		else
			r, g, b = v, mid1, m
		end
	end
	return r, g, b
end

-- Update a bar group's anchor, showing it only if the bar group is unlocked
local function BarGroup_UpdateAnchor(bg, config)
	local pFrame = bg.attributes.parentFrame
	if pFrame and GetClickFrame(pFrame) then bg.frame:SetParent(pFrame) else bg.frame:SetParent(UIParent) end
	bg.anchor:SetSize(bg.width, bg.height)
	bg.anchor:SetText(bg.name)
	local align = "BOTTOMLEFT" -- select corner to attach based on configuration
	if config.iconOnly then -- icons can grow in any direction
		if config.orientation == "horizontal" then
			if bg.reverse then align = "BOTTOMRIGHT" end -- align rights for going left (reverse=true), lefts for right (reverse=false)
		else -- must be "vertical"
			if not bg.reverse then align = "TOPLEFT" end -- align bottoms for going up (reverse=true), tops for down (reverse=false)
		end
	else -- bars can grow either up are down
		if not bg.reverse then align = "TOPLEFT" end -- align bottoms for going up (reverse=true), tops for down (reverse=false)
	end
	bg.anchor:ClearAllPoints(); bg.anchor:SetPoint(align, bg.frame, align)
	if not bg.locked and not inPetBattle then bg.anchor:Show() else bg.anchor:Hide() end
end

-- Update a bar group's background image, currently only required for timeline configuration
local function BarGroup_UpdateBackground(bg, config)
	if config.bars == "timeline" then
		local back, dir = bg.background, 1
		if not back then -- need to create the background frame
			back = CreateFrame("Frame", nil, bg.frame)
			back:SetFrameLevel(bg.frame:GetFrameLevel() + 2) -- higher than bar group's backdrop
			back.bar = back:CreateTexture(nil, "BACKGROUND")
			back.backdrop = CreateFrame("Frame", nil, back)
			back.labels = {}; back.labelCount = 0
			bg.background = back
		end
		back.anchorPoint = "BOTTOMLEFT"
		local w, h, edge, offX, offY, justH, justV
		if config.orientation == "horizontal" then
			w = bg.tlWidth + bg.iconSize; h = bg.tlHeight; edge = "RIGHT"; justH = "RIGHT"; justV = "MIDDLE"
			if not bg.reverse then back.anchorPoint = "BOTTOMRIGHT"; dir = -1; edge = "LEFT"; justH = "LEFT" end
			offX = -dir; offY = 0
		else
			w = bg.tlHeight; h = bg.tlWidth + bg.iconSize; edge = "TOP"; justH = "CENTER"; justV = "TOP"
			if not bg.reverse then back.anchorPoint = "TOPLEFT"; dir = -1; edge = "BOTTOM"; justV = "BOTTOM" end
			offX = 0; offY = -dir
		end
		back:SetSize(w, h); back:SetAlpha(bg.tlAlpha); back.bar:SetSize(w, h); 
		if bg.borderTexture then
			local offset, edgeSize = bg.borderOffset, bg.borderWidth; if (edgeSize < 0.1) then edgeSize = 0.1 end
			bg.borderTable.edgeFile = bg.borderTexture; bg.borderTable.edgeSize = edgeSize
			back.backdrop:SetBackdrop(bg.borderTable)
			t = bg.borderColor; back.backdrop:SetBackdropBorderColor(t.r, t.g, t.b, t.a)
			back.backdrop:SetSize(w + offset, h + offset)
		end
		if type(bg.tlLabels) == "table" then -- table of time values for labels
			local i = 1
			for _, v in pairs(bg.tlLabels) do
				local secs, hidem = tonumber(v), false
				if not secs then
					local start, m = string.find(v, "[%d%.]+m")
					if not start then start, m = string.find(v, "[%d%.]+M"); hidem = true end
					if start then
						local nv = string.sub(v, start, m - 1); secs = tonumber(nv); if secs then secs = secs * 60 end ; if hidem then v = nv end
					end
				end
				if secs and secs <= bg.tlDuration then
					if i > back.labelCount then back.labels[i] = back:CreateFontString(nil, "OVERLAY"); back.labelCount = back.labelCount + 1 end
					local fs = back.labels[i]
					fs:SetFontObject(ChatFontNormal); fs:SetFont(bg.labelFont, bg.labelFSize, bg.labelFlags)
					local t = bg.labelColor; fs:SetTextColor(t.r, t.g, t.b, bg.labelAlpha); fs:SetShadowColor(0, 0, 0, bg.labelShadow and 1 or 0)
					fs:SetText(v); fs:SetJustifyH(justH); fs:SetJustifyV(justV); fs:ClearAllPoints()
					local delta = Timeline_Offset(bg, secs) + ((bg.iconSize + bg.labelFSize) / 2)
					local offsetX = (offX == 0) and 0 or ((delta - w) * dir)
					local offsetY = (offY == 0) and 0 or ((delta - h) * dir)
					fs:SetPoint(edge, back, edge, PS(offsetX + bg.labelInset), PS(offsetY + bg.labelOffset)); fs.hidden = false; i = i + 1
				end
			end
			while i <= back.labelCount do back.labels[i].hidden = true; i = i + 1 end
		end		
	end
end

-- Set a bar's frame level, including that of all components it contains
local function SetBarFrameLevel(bar, level, isIcon)
	SetFrameLevel(bar.frame, level)
	if isIcon then
		SetFrameLevel(bar.container, level + 3)
		SetFrameLevel(bar.backdrop, level + 4)
		SetFrameLevel(bar.textFrame, level + 6)
		SetFrameLevel(bar.icon, level + 1)
		SetFrameLevel(bar.cooldown, level + 2)
		SetFrameLevel(bar.iconTextFrame, level + 5)
	else
		SetFrameLevel(bar.container, level + 1)
		SetFrameLevel(bar.backdrop, level + 2)
		SetFrameLevel(bar.textFrame, level + 6)
		SetFrameLevel(bar.icon, level + 3)
		SetFrameLevel(bar.cooldown, level + 4)
		SetFrameLevel(bar.iconTextFrame, level + 5)
	end
end

-- Update a bar's layout based on the bar group configuration and dimension settings
-- Layout includes relative position of components plus mouse click rectangle and tooltip position
local function Bar_UpdateLayout(bg, bar, config)
	bar.icon:ClearAllPoints(); bar.iconTexture:ClearAllPoints(); bar.spark:ClearAllPoints(); bar.labelText:ClearAllPoints(); bar.cooldown:ClearAllPoints()
	bar.timeText:ClearAllPoints(); bar.fgTexture:ClearAllPoints(); bar.bgTexture:ClearAllPoints(); bar.backdrop:ClearAllPoints()
	local iconWidth = (config.iconOnly and rectIcons) and bg.barWidth or bg.iconSize
	bar.icon:SetSize(iconWidth or bg.iconSize, bg.iconSize)
	local w, h = bg.width, bg.height
	if config.iconOnly then -- icon only layouts
		bar.icon:SetPoint("TOPLEFT", bar.frame, "TOPLEFT", 0, 0)
		if (bg.barHeight > 0) and (bg.barWidth > 0) and config.bars ~= "timeline" then
			local offset = (w - bg.barWidth) / 2 -- how far bars start from edge of frame
			if config.bars == "r2l" then 
				bar.fgTexture:SetPoint("TOPLEFT", bar.icon, "BOTTOMLEFT", bg.iconOffsetX + offset, -bg.iconOffsetY)
				bar.bgTexture:SetPoint("TOPRIGHT", bar.icon, "BOTTOMRIGHT", bg.iconOffsetX - offset, -bg.iconOffsetY)
			elseif config.bars == "l2r" then
				bar.fgTexture:SetPoint("TOPRIGHT", bar.icon, "BOTTOMRIGHT", bg.iconOffsetX - offset, -bg.iconOffsetY)
				bar.bgTexture:SetPoint("TOPLEFT", bar.icon, "BOTTOMLEFT", bg.iconOffsetX + offset, -bg.iconOffsetY)
			end
			bar.fgTexture:SetHeight(bg.barHeight); bar.bgTexture:SetHeight(bg.barHeight)
		end
		bar.timeText:SetPoint("TOP", bar.icon, "BOTTOM", bg.timeInset, bg.timeOffset)
		bar.timeText:SetPoint("LEFT", bar.icon, "LEFT", bg.timeInset - 10, bg.timeOffset)
		bar.timeText:SetPoint("RIGHT", bar.icon, "RIGHT", bg.timeInset + 12, bg.timeOffset) -- pad right to center time text better
		if bg.timeAlign == "normal" then bar.timeText:SetJustifyH("CENTER") else bar.timeText:SetJustifyH(bg.timeAlign) end
		bar.timeText:SetJustifyV("MIDDLE")
		bar.labelText:SetPoint("LEFT", bar.icon, "LEFT", bg.labelInset, bg.labelOffset)
		bar.labelText:SetPoint("RIGHT", bar.icon, "RIGHT", bg.labelInset + abs(bg.barWidth), bg.labelOffset)
		bar.labelText:SetJustifyH("CENTER"); bar.labelText:SetJustifyV(bg.labelAlign)
	else -- bar layouts
		local offsetLeft, offsetRight, fudge, ti = 0, 0, 0, bg.timeIcon and bg.showIcon
		if bg.timeAlign == "normal" then fudge = 4 end
		if bg.showIcon then
			if config.icon == "left" then
				bar.icon:SetPoint("LEFT", bar.frame, "LEFT", bg.iconOffsetX, bg.iconOffsetY)
				offsetLeft = bg.iconSize
			elseif config.icon == "right" then
				bar.icon:SetPoint("RIGHT", bar.frame, "RIGHT", bg.iconOffsetX, bg.iconOffsetY)
				offsetRight = bg.iconSize
			end
		end
		if ti then
			bar.timeText:SetPoint("LEFT", bar.icon, "LEFT", bg.timeInset - 10, bg.timeOffset)
			bar.timeText:SetPoint("RIGHT", bar.icon, "RIGHT", bg.timeInset + 12, bg.timeOffset) -- pad right to center time text better
		end
		if config.label == "right" then
			if not ti then bar.timeText:SetPoint("LEFT", bar.frame, "LEFT", bg.timeInset + offsetLeft + fudge, bg.timeOffset) end
			if bg.timeAlign == "normal" then bar.timeText:SetJustifyH(ti and "CENTER" or "LEFT") else bar.timeText:SetJustifyH(bg.timeAlign) end
			bar.labelText:SetPoint("RIGHT", bar.frame, "RIGHT", -bg.labelInset - offsetRight - fudge, bg.labelOffset)
			if (bg.labelOffset == bg.timeOffset) and (bg.timeAlign == "normal") then
				if ti then bar.labelText:SetPoint("LEFT", bar.frame, "LEFT", 0, 0) else bar.labelText:SetPoint("LEFT", bar.timeText, "RIGHT", 0, 0) end
			else
				bar.labelText:SetPoint("LEFT", bar.frame, "LEFT", 0, bg.labelOffset)
				if not ti then bar.timeText:SetPoint("RIGHT", bar.frame, "RIGHT", bg.timeInset - offsetRight, bg.timeOffset) end
			end
			bar.labelText:SetJustifyH(bg.labelCenter and "CENTER" or "RIGHT")
		elseif config.label == "left" then
			if not ti then bar.timeText:SetPoint("RIGHT", bar.frame, "RIGHT", bg.timeInset - offsetRight - fudge, bg.timeOffset) end
			if bg.timeAlign == "normal" then bar.timeText:SetJustifyH(ti and "CENTER" or "RIGHT") else bar.timeText:SetJustifyH(bg.timeAlign) end
			bar.labelText:SetPoint("LEFT", bar.frame, "LEFT", bg.labelInset + offsetLeft + fudge, bg.labelOffset)
			if (bg.labelOffset == bg.timeOffset) and (bg.timeAlign == "normal") then
				if ti then bar.labelText:SetPoint("RIGHT", bar.frame, "RIGHT", 0, 0) else bar.labelText:SetPoint("RIGHT", bar.timeText, "LEFT", 0, 0) end
			else
				bar.labelText:SetPoint("RIGHT", bar.frame, "RIGHT", 0, bg.labelOffset)
				if not ti then bar.timeText:SetPoint("LEFT", bar.frame, "LEFT", bg.timeInset + offsetLeft, bg.timeOffset) end
			end
			bar.labelText:SetJustifyH(bg.labelCenter and "CENTER" or "LEFT")
		end
		if config.bars == "r2l" then 
			bar.fgTexture:SetPoint("TOPLEFT", bar.frame, "TOPLEFT", offsetLeft, 0)
			bar.bgTexture:SetPoint("TOPRIGHT", bar.frame, "TOPRIGHT", -offsetRight, 0)
		elseif config.bars == "l2r" then
			bar.fgTexture:SetPoint("TOPRIGHT", bar.frame, "TOPRIGHT", -offsetRight, 0)
			bar.bgTexture:SetPoint("TOPLEFT", bar.frame, "TOPLEFT", offsetLeft, 0)
		end	
		bar.fgTexture:SetHeight(h); bar.bgTexture:SetHeight(h)
		bar.timeText:SetJustifyV("MIDDLE"); bar.labelText:SetJustifyV(bg.labelAlign)
	end

	if config.bars == "r2l" then bar.spark:SetPoint("TOP", bar.fgTexture, "TOPRIGHT", 0, 4); bar.spark:SetPoint("BOTTOM", bar.fgTexture, "BOTTOMRIGHT", 0, -4)
	elseif config.bars == "l2r" then bar.spark:SetPoint("TOP", bar.fgTexture, "TOPLEFT", 0, 4); bar.spark:SetPoint("BOTTOM", bar.fgTexture, "BOTTOMLEFT", 0, -4) end
		
	bar.tooltipAnchor = bg.attributes.anchorTips
	bar.labelText:SetWordWrap(bg.labelWrap)
	bar.labelText:SetHeight(h + bg.spacingY) -- limit label height to frame's height plus vertical spacing
	bar.labelText:SetFontObject(ChatFontNormal); bar.timeText:SetFontObject(ChatFontNormal); bar.iconText:SetFontObject(ChatFontNormal)
	bar.labelText:SetFont(bg.labelFont, bg.labelFSize, bg.labelFlags)
	bar.timeText:SetFont(bg.timeFont, bg.timeFSize, bg.timeFlags)
	bar.iconText:SetFont(bg.iconFont, bg.iconFSize, bg.iconFlags)
	local t = bg.labelColor; bar.labelText:SetTextColor(t.r, t.g, t.b, bg.labelAlpha); bar.labelText:SetShadowColor(0, 0, 0, bg.labelShadow and 1 or 0)
	t = bg.timeColor; bar.timeText:SetTextColor(t.r, t.g, t.b, bg.timeAlpha); bar.timeText:SetShadowColor(0, 0, 0, bg.timeShadow and 1 or 0)
	t = bg.iconColor; bar.iconText:SetTextColor(t.r, t.g, t.b, bg.iconAlpha); bar.iconText:SetShadowColor(0, 0, 0, bg.iconShadow and 1 or 0)

	if config.bars ~= "timeline" then SetBarFrameLevel(bar, bg.frame:GetFrameLevel() + 5, config.iconOnly) end
	if bg.showIcon then
		bar.iconText:SetPoint("LEFT", bar.icon, "LEFT", bg.iconInset - 10, bg.iconOffset)
		bar.iconText:SetPoint("RIGHT", bar.icon, "RIGHT", bg.iconInset + 12, bg.iconOffset) -- pad right to center time text better
		bar.iconText:SetJustifyH(bg.iconAlign); bar.iconText:SetJustifyV("MIDDLE")
		if MSQ and bg.MSQ_Group and Raven.db.global.ButtonFacadeIcons then -- if using Masque, set custom fields in button data table and add to skinnning group
			bar.cooldown:SetSize(iconWidth, bg.iconSize); bar.cooldown:SetPoint("CENTER", bar.icon, "CENTER")
			bar.iconTexture:SetTexCoord(0, 1, 0, 1)
			bar.iconTexture:SetSize(iconWidth, bg.iconSize); bar.iconTexture:SetPoint("CENTER", bar.icon, "CENTER")
			bg.MSQ_Group:RemoveButton(bar.icon, true) -- needed so size changes work when icon is reused
			local bdata = bar.buttonData
			bdata.Icon = bar.iconTexture
			bdata.Normal = bar.icon:GetNormalTexture()
			bdata.Cooldown = bar.cooldown
			bdata.Border = bar.iconBorder
			bg.MSQ_Group:AddButton(bar.icon, bdata)
		else -- if not then use a default button arrangment
			if bg.MSQ_Group then bg.MSQ_Group:RemoveButton(bar.icon) end -- remove skin, if any
			if not (UseTukui() or Raven.db.global.HideBorder) then
				local trim, crop, sliceWidth, sliceHeight = 0.06, 0.94, 0.88 * iconWidth, 0.88 * bg.iconSize
				bar.cooldown:SetSize(sliceWidth, sliceHeight); bar.cooldown:SetPoint("CENTER", bar.icon, "CENTER")
				bar.iconTexture:SetTexCoord(trim, crop, trim, crop)
				bar.iconTexture:SetSize(sliceWidth, sliceHeight); bar.iconTexture:SetPoint("CENTER", bar.icon, "CENTER")
				bar.iconBorder:SetTexture("Interface\\AddOns\\Raven\\Normal")
			else
				bar.cooldown:SetSize(iconWidth, bg.iconSize); bar.cooldown:SetPoint("CENTER", bar.icon, "CENTER")
				if UseTukui() or Raven.db.global.TrimIcon then
					local trim, crop = 0.06, 0.94
					bar.iconTexture:SetTexCoord(trim, crop, trim, crop)
				else
					bar.iconTexture:SetTexCoord(0, 1, 0, 1)
				end
				bar.iconTexture:SetSize(iconWidth, bg.iconSize); bar.iconTexture:SetPoint("CENTER", bar.icon, "CENTER")
				bar.iconBorder:SetTexture(0, 0, 0, 0)
			end
		end
	end	
	bar.frame:SetSize(w, h); bar.container:SetSize(w, h); bar.container:SetAllPoints()
	if bg.showBar and bg.borderTexture and not bar.attributes.header then
		local offset, edgeSize = bg.borderOffset, bg.borderWidth; if (edgeSize < 0.1) then edgeSize = 0.1 end
		bg.borderTable.edgeFile = bg.borderTexture; bg.borderTable.edgeSize = edgeSize
		bar.backdrop:SetBackdrop(bg.borderTable)
		t = bg.borderColor; bar.backdrop:SetBackdropBorderColor(t.r, t.g, t.b, t.a)
		bar.backdrop:SetSize(bg.barWidth + offset, bg.barHeight + offset)
		bar.backdrop:SetPoint("CENTER", bar.bgTexture, "CENTER", 0, 0)
		bar.backdrop:Show()
	else
		bar.backdrop:SetBackdrop(nil); bar.backdrop:Hide()
	end
end

-- Convert a time value into a compact text string
Nest_TimeFormatOptions = { { 1, 1, 1, 1, 1 }, { 1, 1, 1, 3, 5 }, { 1, 1, 1, 3, 4 },
						{ 2, 3, 1, 2, 3 }, { 2, 3, 1, 2, 2 }, { 2, 3, 1, 3, 4 }, { 2, 3, 1, 3, 5 },
						{ 2, 2, 2, 2, 3 }, { 2, 2, 2, 2, 2 }, { 2, 2, 2, 2, 4 }, { 2, 2, 2, 3, 4 }, { 2, 2, 2, 3, 5 },
						{ 2, 3, 2, 2, 3 }, { 2, 3, 2, 2, 2 }, { 2, 3, 2, 2, 4 }, { 2, 3, 2, 3, 4 }, { 2, 3, 2, 3, 5 },
						{ 2, 3, 3, 2, 3 }, { 2, 3, 3, 2, 2 }, { 2, 3, 3, 2, 4 }, { 2, 3, 3, 3, 4 }, { 2, 3, 3, 3, 5 },
						{ 3, 3, 3, 2, 3 }, { 3, 3, 3, 3, 5 },
						{ 4, 3, 1, 2, 3 }, { 4, 3, 1, 2, 2 }, { 4, 3, 1, 3, 4 }, { 4, 3, 1, 3, 5 },
						{ 5, 1, 1, 2, 3 }, { 5, 1, 1, 2, 2 }, { 5, 1, 1, 3, 4 }, { 5, 1, 1, 3, 5 },
}

function Nest_FormatTime(t, timeFormat, timeSpaces, timeCase)
	if not timeFormat or (timeFormat > #Nest_TimeFormatOptions) then timeFormat = 24 end -- default to most compact
	local opt = Nest_TimeFormatOptions[timeFormat]
	local func = opt.custom
	local h, m, hplus, mplus, s, ts, f
	if func then -- check for custom time formatting options
		f = func(t)
	else
		local o1, o2, o3, o4, o5 = opt[1], opt[2], opt[3], opt[4], opt[5]
		h = math.floor(t / 3600); m = math.floor((t - (h * 3600)) / 60); s = math.floor(t - (h * 3600) - (m * 60))
		hplus = math.floor((t + 3599.99) / 3600); mplus = math.floor((t - (h * 3600) + 59.99) / 60) -- provides compatibility with tooltips
		ts = math.floor(t * 10) / 10 -- truncated to a tenth second
		if t >= 3600 then
			if o1 == 1 then f = string.format("%.0f:%02.0f:%02.0f", h, m, s) elseif o1 == 2 then f = string.format("%.0fh %.0fm", h, m)
				elseif o1 == 3 then f = string.format("%.0fh", hplus) elseif o1 == 4 then f = string.format("%.0fh %.0f", h, m)
				else f = string.format("%.0f:%02.0f", h, m) end
		elseif t >= 120 then
			if o2 == 1 then f = string.format("%.0f:%02.0f", m, s) elseif o2 == 2 then f = string.format("%.0fm %.0fs", m, s)
				else f = string.format("%.0fm", mplus) end
		elseif t >= 60 then
			if o3 == 1 then f = string.format("%.0f:%02.0f", m, s) elseif o3 == 2 then f = string.format("%.0fm %.0fs", m, s)
				else f = string.format("%.0fm", mplus) end
		elseif t >= 10 then
			if o4 == 1 then f = string.format(":%02.0f", s) elseif o4 == 2 then f = string.format("%.0fs", s)
				else f = string.format("%.0f", s) end
		else
			if o5 == 1 then f = string.format(":%02.0f", s) elseif o5 == 2 then f = string.format("%.1fs", ts)
				elseif o5 == 3 then f = string.format("%.0fs", s) elseif o5 == 4 then f = string.format("%.1f", ts)
				else f = string.format("%.0f", s) end
		end
	end
	if not timeSpaces then f = string.gsub(f, " ", "") end
	if timeCase then f = string.upper(f) end
	return f
end

-- Add a formatting function to the table of time format options.
function Nest_RegisterTimeFormat(func)
	local index = #Nest_TimeFormatOptions
	index = index + 1
	Nest_TimeFormatOptions[index] = { custom = func }
	return index
end

-- Update labels and colors plus for timer bars adjust bar length and formatted time text
-- This function is called on every update and the settings in it do not need to invoke other updates
local function Bar_UpdateSettings(bg, bar, config)
	local fill, sparky, offsetX, showBorder = 1, false, 0, false -- fill is fraction of the bar to display, default to full bar
	local timeText, bt, bl, bi, bf, bb, ba, bx = "", bar.timeText, bar.labelText, bar.iconText, bar.fgTexture, bar.bgTexture, bar.icon.anim, bar.iconBorder
	local isHeader = bar.attributes.header
	if bar.timeLeft and bar.duration and bar.maxTime and bar.offsetTime then -- only update if key parameters are set
		local remaining = bar.duration - (GetTime() - bar.startTime + bar.offsetTime) -- remaining time in seconds
		if remaining < 0 then remaining = 0 end -- make sure no rounding funnies
		if remaining > bar.duration then remaining = bar.duration end -- and no inaccurate durations!
		bar.timeLeft = remaining -- update saved value
		if remaining < bar.maxTime then fill = remaining / bar.maxTime end -- calculate fraction of time remaining
		if bg.fillBars then fill = 1 - fill end -- optionally fill instead of empty bars
		timeText = Nest_FormatTime(remaining, bg.timeFormat, bg.timeSpaces, bg.timeCase) -- set timer text
	elseif bar.value and bar.maxValue then
		if bar.value < 0 then bar.value = 0 end -- no negative values
		if bar.value < bar.maxValue then fill = bar.value / bar.maxValue end -- adjust foreground bar width based on values
		if bg.fillBars then fill = 1 - fill end -- optionally fill instead of empty bars
		timeText = string.format("%d", bar.value) -- set time text to integer part of value
	end
	if bg.showIcon and not isHeader then
		offsetX = bg.iconSize
		if bar.iconPath then bar.icon:Show(); bar.iconTexture:SetTexture(bar.iconPath) else bar.icon:Hide() end
		bar.iconTexture:SetDesaturated(bar.attributes.desaturate) -- optionally desaturate the bar's icon
		local pulseStart, pulseEnd = (bg.attributes.pulseStart or bar.attributes.pulseStart), (bg.attributes.pulseEnd or bar.attributes.pulseEnd)
		if pulseStart and bar.timeLeft and ((bar.duration - bar.timeLeft) < 0.25) and not ba:IsPlaying() then ba:Play() end
		if pulseEnd and bar.timeLeft and (bar.timeLeft < 0.45) and (bar.timeLeft > 0.1) and not ba:IsPlaying() then ba:Play() end
		if MSQ and Raven.db.global.ButtonFacadeIcons then -- icon border coloring
			if Raven.db.global.ButtonFacadeIcons and Raven.db.global.ButtonFacadeBorder and bx and bx.SetVertexColor then
				bx:SetVertexColor(bar.ibr, bar.ibg, bar.ibb, bar.iba); showBorder = true
			end
			local nx = MSQ:GetNormal(bar.icon)
			if Raven.db.global.ButtonFacadeNormal and nx and nx.SetVertexColor then nx:SetVertexColor(bar.ibr, bar.ibg, bar.ibb, bar.iba) end
		else
			if UseTukui() then
				if bar.frame.backdrop then
					if bar.attributes.iconColors == "None" then
						bar.frame.backdrop:SetBackdropBorderColor(bar.tukcolor_r, bar.tukcolor_g, bar.tukcolor_b, bar.tukcolor_a)
					else
						bar.frame.backdrop:SetBackdropBorderColor(bar.ibr, bar.ibg, bar.ibb, bar.iba)
					end
				end
			elseif not Raven.db.global.HideBorder then
				bx:SetAllPoints(bar.icon); bx:SetVertexColor(bar.ibr, bar.ibg, bar.ibb, bar.iba); showBorder = true
			else showBorder = false end
		end
	else
		bar.icon:Hide()
	end
	if showBorder and bar.iconPath then bx:Show() else bx:Hide() end
	if bg.showIcon and not bg.iconHide and not isHeader and bar.iconCount then bi:SetText(tostring(bar.iconCount)); bi:Show() else bi:Hide() end
	if bg.showIcon and not isHeader and bg.showCooldown and config.bars ~= "timeline" and bar.timeLeft and (bar.timeLeft >= 0) and not ba:IsPlaying() then
--		bar.cooldown:SetDrawEdge(bg.attributes.clockEdge) -- Removed in 5.0.4 release and apparently not coming back
		bar.cooldown:SetReverse(bg.attributes.clockReverse)
		bar.cooldown:SetCooldown(bar.startTime - bar.offsetTime, bar.duration); bar.cooldown:Show()
	else
		bar.cooldown:Hide()
	end
	local ct, cm, expiring, ea, ec = bar.attributes.colorTime, bar.attributes.colorMinimum, false, bg.bgAlpha, nil
	if bar.timeLeft and ct and cm and ct >= bar.timeLeft and bar.duration >= cm then
		ec = bar.attributes.expireLabelColor; if ec and ec.a > 0 then bl:SetTextColor(ec.r, ec.g, ec.b, ec.a) end
		ec = bar.attributes.expireTimeColor; if ec and ec.a > 0 then bt:SetTextColor(ec.r, ec.g, ec.b, ec.a) end
		expiring = true
	end
	if expiring and config.iconOnly and ea == 0 then ea = 1 end -- make icon-only bar visible as expire reminder
	if bg.showTimeText then bt:SetText(timeText); bt:Show() else bt:Hide() end
	if (bg.showLabelText or isHeader) and bar.label then bl:SetText(bar.label); bl:Show() else bl:Hide() end
	local w, h = bg.width - offsetX, bg.height; if config.iconOnly then w = bg.barWidth; h = bg.barHeight end
	if bg.showBar and config.bars ~= "timeline" and (w > 0) and (h > 0) then -- non-zero dimensions to fix the zombie bar bug
		local ar, ag, ab = Nest_AdjustColor(bar.br, bar.bg, bar.bb, bg.bgSaturation or 0, bg.bgBrightness or 0)
		if expiring then ec = bar.attributes.expireColor; if ec and ec.a > 0 then ar = ec.r; ag = ec.g; ab = ec.b end end
		bb:SetVertexColor(ar, ag, ab, 1); bb:SetTexture(bg.bgTexture); bb:SetAlpha(bg.bgAlpha)
		bb:SetWidth(w); bb:SetTexCoord(0, 1, 0, 1); bb:Show()
		if (fill > 0) and (bg.fgNotTimer or bar.timeLeft) then
			if bg.showSpark and (fill < 1) then sparky = true end
			if not expiring then ar, ag, ab = Nest_AdjustColor(bar.cr, bar.cg, bar.cb, bg.fgSaturation or 0, bg.fgBrightness or 0) end
			bf:SetVertexColor(ar, ag, ab, 1); bf:SetTexture(bg.fgTexture); bf:SetAlpha(bg.fgAlpha); bf:SetWidth(w * fill)
			if config.bars == "r2l" then bf:SetTexCoord(0, 0, 0, 1, fill, 0, fill, 1) else bf:SetTexCoord(fill, 0, fill, 1, 0, 0, 0, 1) end
			bf:Show()
		else bf:Hide() end
	else bf:Hide(); bb:Hide() end
	if sparky then bar.spark:Show() else bar.spark:Hide() end
	local alpha = bar.alpha or 1 -- adjust by bar alpha
	if bar.flash then alpha = Nest_FlashAlpha(alpha, 1) end -- adjust alpha if flashing
	bar.frame:SetAlpha(alpha) -- final alpha adjustment
	if not isHeader and (bg.attributes.noMouse or (bg.attributes.iconMouse and not bg.showIcon)) then -- non-interactive or "only icon" but icon disabled
		bar.icon:EnableMouse(false); bar.frame:EnableMouse(false); if callbacks.deactivate then callbacks.deactivate(bar.overlay) end
	elseif not isHeader and bg.attributes.iconMouse then -- only icon is interactive
		bar.icon:EnableMouse(true); bar.frame:EnableMouse(false); if callbacks.activate then callbacks.activate(bar, bar.icon) end
	else -- entire bar is interactive
		bar.icon:EnableMouse(false); bar.frame:EnableMouse(true); if callbacks.activate then callbacks.activate(bar, bar.frame) end
	end
	if bar.attributes.header then
		bf:SetAlpha(0); bb:SetAlpha(0)
		local id, tag = bar.attributes.tooltipUnit, ""
		if id == UnitGUID("mouseover") then tag = "|cFF73d216@|r" end
		if id == UnitGUID("target") then tag = tag .. " |cFFedd400target|r" end
		if id == UnitGUID("focus") then tag = tag .. " |cFFf57900focus|r" end
		if tag ~= "" then bt:SetText(tag); bt:Show() end
	end
end

-- Update the lengths of timer bars, spark positions, and alphas of flashing bars
local function Bar_RefreshAnimations(bg, bar, config)
	local fill, sparky, offsetX, now = 1, false, 0, GetTime()
	if bar.timeLeft and bar.duration and bar.maxTime and bar.offsetTime then -- only update if key parameters are set
		local remaining = bar.duration - (now - bar.startTime + bar.offsetTime) -- remaining time in seconds
		if remaining < 0 then remaining = 0 end -- make sure no rounding funnies
		if remaining > bar.duration then remaining = bar.duration end -- and no inaccurate durations!
		bar.timeLeft = remaining -- update saved value
		if remaining < bar.maxTime then fill = remaining / bar.maxTime end -- calculate fraction of time remaining
		if bg.fillBars then fill = 1 - fill end -- optionally fill instead of empty bars
		timeText = Nest_FormatTime(remaining, bg.timeFormat, bg.timeSpaces, bg.timeCase) -- set timer text
		if bg.showTimeText then bar.timeText:SetText(timeText) end
		local expireTime, expireMinimum = bar.attributes.expireTime, bar.attributes.expireMinimum
		if expireTime and not bar.expireDone and expireTime >= remaining and (expireTime - remaining) < 1 then
			if expireMinimum and bar.duration >= bar.attributes.expireMinimum then
				PlaySoundFile(bar.attributes.soundExpire, Raven.db.global.SoundChannel); bar.expireDone = true
			end
		end
		local colorTime = bar.attributes.colorTime -- if need to change color then force update to re-color the bar
		if colorTime and colorTime >= remaining and (colorTime - remaining) < 0.25 then Raven:ForceUpdate() end
		if bar.attributes.expireMSBT and bar.attributes.minimumMSBT and not bar.warningDone and bar.duration >= bar.attributes.minimumMSBT
			and bar.attributes.expireMSBT >= remaining and (bar.attributes.expireMSBT - remaining) < 1 then
			local ec, crit, icon = bar.attributes.colorMSBT, bar.attributes.criticalMSBT, bar.iconTexture:GetTexture()
			local t = string.format("%s [%s] %s", bar.label, bg.name, L["expiring"])
			if MikSBT then
				MikSBT.DisplayMessage(t, MikSBT.DISPLAYTYPE_NOTIFICATION, crit, ec.r * 255, ec.g * 255, ec.b * 255, nil, nil, nil, icon)
			elseif SCT then
				local frame = SCT:Get("SHOWFADE", SCT.FRAMES_TABLE) or 1
				if frame == SCT.MSG then SCT:DisplayMessage(t, ec) else SCT:DisplayText(t, ec, crit, "event", frame) end
			elseif Parrot then
				Parrot:GetModule("Display"):CombatText_AddMessage(t, nil, ec.r, ec.g, ec.b, nil, nil, nil, icon)
			elseif _G.SHOW_COMBAT_TEXT == "1" then
				CombatText_AddMessage(t, COMBAT_TEXT_SCROLL_FUNCTION, ec.r, ec.g, ec.b, nil, nil)
			end
			bar.warningDone = true
		end
	end
	if bg.showIcon and not bar.attributes.header then
		offsetX = bg.iconSize
		local pulseEnd = (bg.attributes.pulseEnd or bar.attributes.pulseEnd)
		local ba = bar.icon.anim
		if ba:IsPlaying() then bar.cooldown:Hide() elseif pulseEnd and bar.timeLeft and (bar.timeLeft < 0.45) and (bar.timeLeft > 0.1) then ba:Play() end
	end
	if bg.showBar and config.bars ~= "timeline" and (fill > 0) and (bg.fgNotTimer or bar.timeLeft) then
		local bf, w, h = bar.fgTexture, bg.width - offsetX, bg.height; if config.iconOnly then w = bg.barWidth; h = bg.barHeight end
		if (w > 0) and (h > 0) then
			if bg.showSpark and (fill < 1) then sparky = true end
			bf:SetWidth(w * fill)
			if config.bars == "r2l" then bf:SetTexCoord(0, 0, 0, 1, fill, 0, fill, 1) else bf:SetTexCoord(fill, 0, fill, 1, 0, 0, 0, 1) end
			bf:Show()
		else bf:Hide() end
	end
	if sparky then bar.spark:Show() else bar.spark:Hide() end
	local alpha = bar.alpha or 1 -- adjust by bar alpha
	if bar.flash then alpha = Nest_FlashAlpha(alpha, 1) end -- adjust alpha if flashing
	bar.frame:SetAlpha(alpha) -- final alpha adjustment
	if bar.attributes.soundStart and (not bar.soundDone or (bar.attributes.replay and (now > (bar.soundDone + bar.attributes.replayTime)))) then
		PlaySoundFile(bar.attributes.soundStart, Raven.db.global.SoundChannel); bar.soundDone = now
	end
end

-- Update icon positions on timeline after animation refresh
local function BarGroup_RefreshTimeline(bg, config)
	local dir = bg.reverse and 1 or -1 -- plus or minus depending on direction
	local isVertical = (config.orientation == "vertical")
	local maxBars = bg.maxBars; if not maxBars or (maxBars == 0) then maxBars = bg.count end
	local back, level, t, lastBar = bg.background, bg.frame:GetFrameLevel() + 5, GetTime(), nil
	local w, h, edge, lastDelta, lastBar, lastLevel
	if config.orientation == "horizontal" then
		w = bg.tlWidth; h = bg.tlHeight; edge = bg.reverse and "RIGHT" or "LEFT"
	else
		w = bg.tlHeight; h = bg.tlWidth; edge = bg.reverse and "TOP" or "BOTTOM"
	end
	local overlapCount = 0
	for i = 1, bg.count do
		local bar = bg.bars[bg.sorter[i].name]
		if i <= maxBars and bar.timeLeft then
			local clevel = level + ((bg.count - i) * 10)
			local delta = Timeline_Offset(bg, bar.timeLeft)
			if bg.tlAlternate and i > 1 and lastBar and math.abs(delta - lastDelta) < (bg.iconSize / 2) then
				overlapCount = overlapCount + 1
				local phase = math.floor(t / (bg.tlSwitch or 2)) -- time between alternating overlapping icons
				if overlapCount == 1 then
					if (phase % 2) == 1 then SetBarFrameLevel(lastBar, clevel, true); clevel = lastLevel end
				else
					local seed = phase % (overlapCount + 1) -- 0, 1, ..., overLapCount
					for k = 1, overlapCount do
						local b = bg.bars[bg.sorter[i - k].name]
						SetBarFrameLevel(b, clevel + (((seed + k) % (overlapCount + 1)) * 10), true)
					end
					clevel = clevel + (seed * 10)
				end
			else
				overlapCount = 0
			end
			SetBarFrameLevel(bar, clevel, true)
			lastDelta = delta; lastBar = bar; lastLevel = clevel
			local x1 = isVertical and 0 or ((delta - w) * dir); local y1 = isVertical and ((delta - h) * dir) or 0
			bar.frame:ClearAllPoints(); bar.frame:SetPoint(edge, back, edge, PS(x1), PS(y1)); bar.frame:Show()
		else
			lastBar = nil; bar.frame:Hide()
		end
	end
end

-- Update bar order and calculate offsets within the bar stack plus overall width and height of the frame
local function BarGroup_SortBars(bg, config)
	local tid = UnitGUID("target")
	local unlimited = bg.attributes.noDurationFirst and 0 or 100000 -- really big number sorts like infinite time
	for i = 1, bg.count do -- fill data into the sorting table
		local s = bg.sorter[i]
		local bar = bg.bars[s.name]
		if not bar.startTime or not bar.offsetTime then s.start = 0 else s.start = bar.startTime - bar.offsetTime end
		if not bar.timeLeft or not bar.duration then
			s.timeLeft = unlimited; s.duration = unlimited
		else
			s.timeLeft = bar.timeLeft; s.duration = bar.duration
		end
		local id = bar.attributes.group; if bg.attributes.targetFirst and id and tid and id == tid then id = "" end -- sorts to front of the list
		s.group = id or ""; s.gname = bar.attributes.groupName or (bg.reverse and "zzzzzzzzzzzz" or "")
		s.isMine = bar.attributes.isMine; s.class = bar.attributes.class or ""; s.sortPlayer = bg.sortPlayer; s.sortTime = bg.sortTime
	end
	local isTimeline = false
	if config.bars == "timeline" then bg.sortFunction = SortTimeUp; isTimeline = true end
	table.sort(bg.sorter, bg.sortFunction)
	local wrap = 0 -- indicates default of not wrapping
	local dir = bg.reverse and 1 or -1 -- plus or minus depending on direction
	local x0, y0, x1, y1 = 0, 0, 0, 0 -- starting position must be offset by dimensions of anchor if unlocked
	local dx, dy = dir * (bg.width + bg.spacingX), dir * (bg.height + bg.spacingY) -- offsets for each new bar
	local wx, wy = 0, 0 -- offsets from starting point when need to wrap
	local bw, bh = 0, 0 -- number of bar widths and heights in size of backdrop
	local xoffset, yoffset, xdir, ydir, wadjust = 0, 0, 1, dir, 0 -- position adjustments for backdrop
	local count, maxBars, cdir = bg.count, bg.maxBars, 0
	if not maxBars or (maxBars == 0) then maxBars = count end
	if count > maxBars then count = maxBars end
	local ac = count -- actual count before wrap adjustment
	if bg.wrap and not isTimeline then wrap = bg.wrap; if (wrap > 0) and (count > wrap) then count = wrap end end
	local anchorPoint = "BOTTOMLEFT"
	if config.iconOnly then -- icons can go any direction from anchor
		if config.orientation == "vertical" then
			wx = -dx; dx = 0; bh = count; if count > 0 then bw = math.ceil(ac / count) else bw = 1 end
			if not bg.locked then y0 = dy; bh = bh + 1 end
			if not bg.reverse then anchorPoint = "TOPLEFT"; wx = -wx; cdir = -1 end
			if not bg.wrapDirection then xoffset = -(bw - 1) * (bg.width + bg.spacingX) end
			if bg.snapCenter and bg.locked then local z = (dy * (((count - dir) / 2) + cdir)); y0 = y0 - z; yoffset = yoffset - z end
			if bg.wrapDirection then wx = -wx end
			if wrap > 0 then -- attachment options differ when wrapping
				bg.lastRow = x0 + (wx * bw); bg.lastColumn = y0 + (dy * count); bg.lastX = nil; bg.lastY = nil
			else
				bg.lastX = x0; bg.lastY = y0 + (dy * count); bg.lastRow = nil; bg.lastColumn = nil
			end
		else -- horizontal
			wy = dy; dy = 0; bw = count; if count > 0 then bh = math.ceil(ac / count) else bh = 1 end
			if not bg.locked then x0 = dx; bw = bw + 1 end
			if bg.reverse then anchorPoint = "BOTTOMRIGHT"; wy = -wy; cdir = -1 end
			if not bg.wrapDirection then yoffset = -(bh - 1) * (bg.height + bg.spacingY) end			
			if dir < 0 then
				xoffset = dir * (bw - 1) * (bg.width + bg.spacingX); ydir = -ydir
			else
				xoffset = (bw - 1) * (bg.width + bg.spacingX); xdir = -1			
			end
			if bg.snapCenter and bg.locked then local z = (dx * (((count + dir) / 2) + cdir)); x0 = x0 - z; xoffset = xoffset - z end
			if bg.wrapDirection then wy = -wy end
			if wrap > 0 then -- attachment options differ when wrapping
				bg.lastRow = x0 + (dx * count); bg.lastColumn = y0 + (wy * bh); bg.lastX = nil; bg.lastY = nil
			else
				bg.lastX = x0 + (dx * count); bg.lastY = y0; bg.lastRow = nil; bg.lastColumn = nil
			end
		end
	else -- bars just go up or down with anchor set to top or bottom
		wx = -dx; dx = 0; if count > 0 then bw = math.ceil(ac / count) else bw = 1 end; bh = count; wadjust = bg.iconOffsetX
		if bg.wrapDirection then xoffset = bg.iconOffsetX else xoffset = bg.iconOffsetX - (bw - 1) * (bg.width + bg.spacingX) end
		if not bg.locked then y0 = y0 + dy; bh = bh + 1 end
		if not bg.reverse then anchorPoint = "TOPLEFT"; wx = -wx end
		if bg.wrapDirection then wx = -wx end
		if wrap > 0 then -- attachment options differ for wrapping bar groups
			bg.lastRow = x0 + (wx * bw); bg.lastColumn = y0 + (dy * count); bg.lastX = nil; bg.lastY = nil
		else
			bg.lastX = x0; bg.lastY = y0 + (dy * count); bg.lastRow = nil; bg.lastColumn = nil
		end
	end
	count = bg.count
	if isTimeline then
		BarGroup_RefreshTimeline(bg, config)
	else	
		for i = 1, count do
			local bar = bg.bars[bg.sorter[i].name]; bar.frame:ClearAllPoints()
			if i <= maxBars then
				local w, skip = i - 1, 0; if wrap > 0 then skip = math.floor(w / wrap); w = w % wrap end
				x1 = x0 + (dx * w) + (wx * skip); y1 = y0 + (dy * w) + (wy * skip)
				bar.frame:SetPoint(anchorPoint, bg.frame, anchorPoint, PS(x1), PS(y1)); bar.frame:Show()
			else
				bar.frame:Hide()
			end
		end
	end
	bg.frame:SetSize(bg.width, bg.height)
	bg.anchorPoint = anchorPoint -- reference position for attaching bar groups together
	local back = bg.background
	if back then
		if isTimeline and (not bg.tlHide or (count > 0)) and not inPetBattle then
			back:ClearAllPoints(); back:SetPoint(back.anchorPoint, bg.frame, back.anchorPoint, PS(x0), PS(y0)); ShowTimeline(bg)
			count = 1 -- trigger drawing backdrop
		else HideTimeline(bg) end
	end
	if count > 0 then
		local w, h
		if isTimeline then
			w, h = back:GetSize(); xoffset = 0; yoffset = 0
			if not bg.locked then if config.orientation == "horizontal" then w = w + bg.width + bg.spacingX else h = h + bg.height + bg.spacingY end end
			if config.orientation == "horizontal" then xdir = -xdir; if anchorPoint == "BOTTOMRIGHT" then anchorPoint = "BOTTOMLEFT" else anchorPoint = "BOTTOMRIGHT" end end
		else
			w = bw * bg.width; if bw > 1 then w = w + ((bw - 1) * bg.spacingX) end
			h = bh * bg.height; if bh > 1 then h = h + ((bh - 1) * bg.spacingY) end
		end
		local offset = 4
		if (bg.backdropTexture or bg.backdropPanel) then
			offset = bg.backdropPadding
			local edgeSize = bg.backdropWidth; if (edgeSize < 0.1) then edgeSize = 0.1 end
			local x, d = bg.backdropInset, bg.backdropTable.insets; d.left = x; d.right = x; d.top = x; d.bottom = x
			bg.backdropTable.bgFile = bg.backdropPanel; bg.backdropTable.edgeFile = bg.backdropTexture; bg.backdropTable.edgeSize = edgeSize
			bg.backdrop:SetBackdrop(bg.backdropTable)
			local t = bg.backdropColor; bg.backdrop:SetBackdropBorderColor(t.r, t.g, t.b, t.a)
			t = bg.backdropFill; bg.backdrop:SetBackdropColor(t.r, t.g, t.b, t.a)
		else
			bg.backdrop:SetBackdrop(nil)
		end
		bg.backdrop:ClearAllPoints()
		bg.backdrop:SetSize(w + offset - wadjust + bg.backdropPadW, h + offset + bg.backdropPadH)
		xoffset = xoffset + bg.backdropOffsetX; yoffset = yoffset + bg.backdropOffsetY
		bg.backdrop:SetPoint(anchorPoint, bg.frame, anchorPoint, (-xdir * offset / 2) + xoffset, (-ydir * offset / 2) + yoffset)
		bg.backdrop:SetFrameStrata("BACKGROUND")
		bg.backdrop:Show()
	else
		bg.backdrop:Hide()
	end
	local scale = bg.frame:GetScale()
	if math.abs(bg.scale - scale) > 0.001 then -- only adjust scale if it has changed by a detectable amount
		if bg.relativeTo then -- if anchored to another bar group then just change the scale
			bg.frame:SetScale(bg.scale)
		else -- if not anchored make sure the position doesn't get changed
			scale = scale / bg.scale -- compute scaling factor
			x0 = bg.frame:GetLeft() * scale; y0 = bg.frame:GetBottom() * scale -- normalize by scale factor
			bg.frame:SetScale(bg.scale)
			bg.frame:ClearAllPoints(); bg.frame:SetPoint("BOTTOMLEFT", nil, "BOTTOMLEFT", x0, y0)
		end
	end
end

-- Update relative positions between bar groups, has to be called on every update for the lastbar feature to work right
local function UpdateRelativePositions()
	for _, bg in pairs(barGroups) do
		if bg.configuration and bg.relativeTo then
			local rbg = barGroups[bg.relativeTo]
			if rbg then
				if rbg.count == 0 then
					local i = 0
					while (rbg.count == 0) and rbg.relativeEmpty and rbg.relativeTo do
						rbg = barGroups[rbg.relativeTo]
						i = i + 1; if i > 20 then break end -- safety check, never loop more than 20 deep
					end
				end
				local align, offsetX, offsetY = "BOTTOMLEFT", 0, 0
				if (rbg.count > 0) or not bg.relativeEmpty then
					offsetX, offsetY = bg.relativeX / bg.scale, bg.relativeY / bg.scale
					if bg.relativeLastBar then -- alternative is to attach to the last bar rendered back in the other bar group
						-- print(bg.name, rbg.name, rbg.lastX, rbg.lastY, rbg.lastRow, rbg.lastColumn, bg.relativeRow, bg.relativeColumn, offsetX, offsetY)
						align = rbg.anchorPoint
						if rbg.lastX and rbg.lastY then offsetX = offsetX + rbg.lastX; offsetY = offsetY + rbg.lastY
						elseif bg.relativeRow and rbg.lastRow then offsetX = offsetX + rbg.lastRow
						elseif bg.relativeColumn and rbg.lastColumn then offsetY = offsetY + rbg.lastColumn end
					end
				end
				bg.frame:ClearAllPoints(); bg.frame:SetPoint(align, rbg.frame, align, PS(offsetX), PS(offsetY))
			end
		end
	end
end

-- Check configuration and minimum values to determine frame width and height
local function SetBarGroupEffectiveDimensions(bg, config)
	local w, h, minimumWidth, minimumHeight = bg.barWidth or 10, bg.barHeight or 10, 5, 5
	if config.iconOnly then
		w = rectIcons and bg.barWidth or bg.iconSize; h = bg.iconSize -- icon configs start with icon size and add room for bar and time text, if they are displayed
		h = h + (bg.showBar and (bg.barHeight + math.max(0, bg.iconOffsetY)) or 0)
	else
		if bg.showIcon then w = w + bg.iconSize end -- bar config start with bar size and add room for icon if it is displayed
	end
	if h < minimumHeight then h = minimumHeight end -- enforce minimums for dimensions
	if w < minimumWidth then w = minimumWidth end
	bg.width = PS(w); bg.height = PS(h)
	if not bg.scale then bg.scale = 1 end
end

-- Check if display dimensions have changed and update bar group locations
function Nest_CheckDisplayDimensions()
	local dw, dh = UIParent:GetWidth(), UIParent:GetHeight()
	if (displayWidth ~= dw) or (displayHeight ~= dh) then
		displayWidth = dw; displayHeight = dh
		for _, bg in pairs(barGroups) do
			if bg.configuration then -- make sure configuration is valid
				local p = bg.position
				Nest_SetAnchorPoint(bg, p.left, p.right, p.bottom, p.top, bg.scale, p.width, p.height) -- restore cached position
			end
		end
	end
end

-- Force a global update.
function Nest_TriggerUpdate() update = true end

-- Initialize the module
function Nest_Initialize()
	if Raven.MSQ then
		MSQ = Raven.MSQ
		MSQ_ButtonData = { AutoCast = false, AutoCastable = false, Border = false, Checked = false, Cooldown = false, Count = false, Duration = false,
			Disabled = false, Flash = false, Highlight = false, HotKey = false, Icon = false, Name = false, Normal = false, Pushed = false }
	end
	pixelScale = 768 / string.match(GetCVar("gxResolution"), "%d+x(%d+)") / GetCVar("uiScale") -- used for pixel perfect size and position
	pixelPerfect = (not Raven.db.global.TukuiSkin and Raven.db.global.PixelPerfect) or (Raven.db.global.TukuiSkin and Raven.db.global.TukuiScale)
	rectIcons = (Raven.db.global.RectIcons == true)
end

-- Update routine does all the actual work of setting up and displaying bar groups.
function Nest_Update()
	for _, bg in pairs(barGroups) do
		if bg.configuration then -- make sure configuration is valid
			local config = Nest_SupportedConfigurations[bg.configuration]
			local alpha = (bg.backdrop:IsShown() and bg.backdrop:IsMouseOver(2, -2, -2, 2)) and bg.mouseAlpha or bg.alpha
			if not alpha or (alpha < 0) or (alpha > 1) then alpha = 1 end; bg.frame:SetAlpha(alpha)
			if not bg.moving then bg.frame:SetFrameStrata(bg.strata or "MEDIUM") end
			SetBarGroupEffectiveDimensions(bg, config) -- stored in bg.width and bg.height
			if C_PetBattles.IsInBattle() then -- force update when entering or leaving pet battles to hide anchor and timeline
				if not inPetBattle then inPetBattle = true; bg.update = true end
			else
				if inPetBattle then inPetBattle = false; bg.update = true end
			end
			if update or bg.update then BarGroup_UpdateAnchor(bg, config); BarGroup_UpdateBackground(bg, config) end
			for _, bar in pairs(bg.bars) do
				if update or bg.update or bar.update then -- see if any bar configurations need to be updated
					Bar_UpdateLayout(bg, bar, config) -- configure internal bar layout
				end
				Bar_UpdateSettings(bg, bar, config) -- update bar color, times, and texts plus activate buff buttons
				bar.update = false
			end
			BarGroup_SortBars(bg, config) -- update bar order and relative positions plus overall frame dimensions
			bg.update = false
		end
	end
	UpdateRelativePositions() -- has to be done every time to support relative positioning to last bar
	UpdateAnimations() -- check for completed animations
	update = false
end

-- Just refresh timers and flashing bars without checking settings.
function Nest_Refresh()
	for _, bg in pairs(barGroups) do
		if bg.configuration then -- make sure configuration is valid
			local config = Nest_SupportedConfigurations[bg.configuration]
			SetBarGroupEffectiveDimensions(bg, config) -- stored in bg.width and bg.height
			for _, bar in pairs(bg.bars) do if not bar.update then Bar_RefreshAnimations(bg, bar, config) end end
			if config.bars == "timeline" then BarGroup_RefreshTimeline(bg, config) end
			local alpha = (bg.backdrop:IsShown() and bg.backdrop:IsMouseOver(2, -2, -2, 2)) and bg.mouseAlpha or bg.alpha
			if not alpha or (alpha < 0) or (alpha > 1) then alpha = 1 end; bg.frame:SetAlpha(alpha)
		end
	end
	UpdateAnimations() -- check for completed animations
end
