-- Raven is an addon to monitor auras and cooldowns, providing timer bars and icons plus helpful notifications.

-- Cancel.lua supports right-click cancel of player buffs:

-- Buff cancelling (out of combat):
-- Dynamically create secure buttons, one per active player buff, programmed so that right-click
-- cancels aura or temp weapon enchant. Resize and overlay the buttons on icons for corresponding player buff bars.
-- Hide all the buttons when enter combat and show them when out of combat.

-- Buff cancelling (in combat):
-- Create a bar with a secure button for each pre-defined player buff or temp weapon enchant.
-- Overlay the bar with frames the same size as the buttons that show the buff's texture when the buff is active.
-- Also, use the overlaid frames to either capture mouse events or let them reach the secure buttons, as required.

local MOD = Raven
local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local inCombatBar = {} -- keep track of current settings for in-combat bar
local overlayPool = {} -- pool of overlays to use for clicking off buffs
local overlayCount = 0 -- number of allocated overlays
local gridLayout = {} -- layout info for overlay grid used for in-combat clicking off buffs
local weaponSlots = { ["MainHandSlot"] = 16, ["SecondaryHandSlot"] = 17 }
local displayWidth, displayHeight = UIParent:GetWidth(), UIParent:GetHeight()

local overlayDefaults = { -- backdrop initialization for overlay grid
	bgFile = "Interface\\Tooltips\\UI-Tooltip-Background", edgeFile = "Interface\\Tooltips\\UI-Tooltip-Border",
	tile = true, tileSize = 8, edgeSize = 8, insets = { left = 0, right = 0, top = 0, bottom = 0 }
}

local inCombatBarTemplate = {
	layout = 0, direction = 0, size = 0, spacing = 0, scale = 0, alpha = 0, offsetX = 0, offsetY = 0, anchorTips = 0,
	pulseStart = 0, pulseEnd = 0, flashExpiring = 0, flashTime = 0, mouseoverDetect = 0, mouseoverAlpha = 0, noBorder = 0,
	anchorFrame = 0, anchorPoint = 0, anchorX = 0, anchorY = 0
}

-- Set default values for the in-combat buffs bar
function MOD:SetInCombatBarDefaults()
	local p, g = MOD.DefaultProfile.profile.InCombatBar, MOD.DefaultProfile.global.InCombatBar
	p.enable = false; p.lock = false; p.link = true; p.ooc = true
	p.layout = true; p.direction = true; p.size = 13; p.spacing = 2; p.scale = 1; p.alpha = 1; p.offsetX = 0.5; p.offsetY = 0.98
	p.anchorTips = "DEFAULT"; p.pulseStart = true; p.pulseEnd = false; p.flashExpiring = false; p.flashTime = 5
	p.mouseoverDetect = false; p.mouseoverAlpha = 0.5; p.noBorder = false
	p.anchorFrame = ""; p.anchorPoint = "CENTER"; p.anchorX = 0; p.anchorY = 0
	for k in pairs(inCombatBarTemplate) do g[k] = p[k] end
end

-- Check for active tooltip for an overlay and update twice per second
local function OverlayTooltipUpdate()
	if MOD.tooltipOverlay and MOD.Overlay_OnEnter then MOD.Overlay_OnEnter(MOD.tooltipOverlay) end
end

-- Copy in-combat bar settings from the shared layout, if linked, and update the bar for the first time
function MOD:InitializeInCombatBar()
	local p, g = MOD.db.profile.InCombatBar, MOD.db.global.InCombatBar
	if p.link then for k in pairs(inCombatBarTemplate) do p[k] = g[k] end end
	MOD.tooltipOverlay = nil -- set when an overlay displays a tooltip
	C_Timer.NewTicker(0.5, OverlayTooltipUpdate) -- update tooltips for overlays when hovering over them
end

-- Copy in-combat bar settings back to the shared layout, if linked
function MOD:FinalizeInCombatBar()
	local p, g = MOD.db.profile.InCombatBar, MOD.db.global.InCombatBar
	if p.link then for k in pairs(inCombatBarTemplate) do g[k] = p[k] end end
end

-- Update the overlay grid for in-combat buffs when it is reconfigured
function MOD:UpdateInCombatBar()
	if C_PetBattles.IsInBattle() then MOD:HideInCombatBar() return end -- hide when entering pet battles
	if not InCombatLockdown() then -- only update settings when not in combat
		local g = MOD.db.profile.InCombatBar -- update the overlay grid in case it has been reconfigured
		local list = MOD.db.profile.InCombatBuffs -- list of combat buffs for this character
		local p = inCombatBar -- local cache for comparisons
		local update = p.hidden and g.enable -- force update if was hidden and now enabled
		for k, v in pairs(MOD.db.profile.InCombatBar) do if p[k] ~= v then update = true; p[k] = v end end
		if not p.list then p.list = {} end
		for k, v in pairs(list) do if p.list[k] ~= v then update = true; p.list[k] = v end end
		for k, v in pairs(p.list) do if list[k] ~= v then update = true; p.list[k] = list[k] end end
		local dw, dh = UIParent:GetWidth(), UIParent:GetHeight()
		if (displayWidth ~= dw) or (displayHeight ~= dh) then displayWidth = dw; displayHeight = dh; update = true end
		if update then
			p.hidden = not g.enable
			MOD:SetInCombatBar(g.enable, g.lock, list, g)
		end
	end
	MOD:UpdateInCombatBarOverlays() -- update the overlay grid
end

-- Hide the in-combat bar as soon as we are out of combat
function MOD:HideInCombatBar()
	local p = inCombatBar -- local cache for comparisons
	if not p.hidden then
		p.hidden = true
		local g = MOD.db.profile.InCombatBar -- update the overlay grid in case it has been reconfigured
		local list = MOD.db.profile.InCombatBuffs -- list of combat buffs for this character
		MOD:SetInCombatBar(false, g.lock, list, g)
		MOD:UpdateInCombatBarOverlays() -- requires one more update in order to clear the bar
	end
end

-- Show tooltip when entering an overlay
local function Overlay_OnEnter(b)
	if b.aura_id then
		local ttanchor = b.tooltipAnchor
		if (ttanchor == "DEFAULT") and (GetCVar("UberTooltips") == "1") then
			GameTooltip_SetDefaultAnchor(GameTooltip, b)
		else
			if not ttanchor or (ttanchor == "DEFAULT") then ttanchor = "ANCHOR_BOTTOMLEFT" else ttanchor = "ANCHOR_" .. ttanchor end
			GameTooltip:SetOwner(b, ttanchor)
		end
		GameTooltip:ClearLines() -- clear current tooltip contents
		if b.aura_tt == "weapon" then
			local slot = GetInventorySlotInfo(b.aura_id)
			if slot then GameTooltip:SetInventoryItem("player", slot) end
		elseif b.aura_tt == "buff" then
			if not UnitBuff("player", b.aura_id) then return end
			GameTooltip:SetUnitAura("player", b.aura_id, "HELPFUL")
		elseif b.aura_tt == "spell name" then
			local auraList = MOD:CheckAura("player", b.aura_id, true)
			if #auraList > 0 then local aura = auraList[1]; GameTooltip:SetUnitAura("player", aura[12], "HELPFUL") end
		end
		if IsAltKeyDown() and IsControlKeyDown() then
			if b.aura_spell then GameTooltip:AddLine("<Spell #" .. tonumber(b.aura_spell) .. ">", 0, 1, 0.2, false) end
			if b.aura_list then GameTooltip:AddLine("<List #" .. tonumber(b.aura_list) .. ">", 0, 1, 0.2, false) end
		end
		if b.aura_caster and (b.aura_caster ~= "") then GameTooltip:AddLine(L["<Applied by "] .. b.aura_caster .. ">", 0, 0.8, 1, false) end
		GameTooltip:Show()
		MOD.tooltipOverlay = b
	end
end
MOD.Overlay_OnEnter = Overlay_OnEnter -- save for tooltip update

-- Hide tooltip when leaving an overlay
local function Overlay_OnLeave(b) MOD.tooltipOverlay = nil; GameTooltip:Hide() end

-- Allocate an overlay and initialize the common secure attributes for cancelaura
local function AllocateOverlay()
	local b = next(overlayPool)
	if b then
		overlayPool[b] = nil
	else
		overlayCount = overlayCount + 1
		b = CreateFrame("Button", "RavenOverlay" .. overlayCount, UIParent, "SecureActionButtonTemplate")
		b:SetAttribute("unit", "player")
		b:SetAttribute("filter", "HELPFUL")
		b:SetScript("OnEnter", Overlay_OnEnter)
		b:SetScript("OnLeave", Overlay_OnLeave)
		b:EnableMouse(true)
		b:RegisterForClicks("RightButtonUp")
		-- b:SetNormalTexture("Interface\\AddOns\\Raven\\Borders\\IconDefault") -- for debugging only
	end
	return b
end

-- OnMouseDown with no modifier key starts moving if bar is unlocked and not in combat
local function InCombatBar_OnMouseDown(anchor, button)
	if InCombatLockdown() then return end
	local g = gridLayout
	if g and g.opt then
		local scale = g.opt.scale
		if scale and (button == "LeftButton") and not IsModifierKeyDown() and g.initialized and not g.lock then
			g.startX = g.frame:GetLeft() * scale; g.startY = g.frame:GetTop() * scale
			g.moving = true
			g.frame:SetFrameStrata("HIGH")
			g.frame:StartMoving()
		end
	end
end

-- OnMouseUp stops moving if frame is in motion
local function InCombatBar_OnMouseUp()
	local g = gridLayout
	if g and g.opt then
		local scale = g.opt.scale
		if scale and g.initialized and g.moving then
			g.frame:StopMovingOrSizing()
			g.frame:SetFrameStrata("MEDIUM")
			local x, y = g.frame:GetLeft() * scale, g.frame:GetTop() * scale
			if g.startX ~= x or g.startY ~= y then
				local fw, fh = g.frame:GetWidth() * scale, g.frame:GetHeight() * scale
				if g.anchor == "TOPRIGHT" then x = x + fw elseif g.anchor == "BOTTOMRIGHT" then x = x + fw; y = y - fh end
				g.opt.offsetX = x / displayWidth; g.opt.offsetY = y / displayHeight
				MOD.updateOptions = true
			end
			g.moving = false
		end
	end
end

-- Allocate a grid of overlays that can be used to cancel buffs in combat
-- Check layout parameters and recreate the grid when it changes, but only when out of combat
function MOD:SetInCombatBar(enable, lock, list, opt)
	if InCombatLockdown() then return end
	local g = gridLayout
	g.enable = enable; g.lock = lock
	if not enable then return end
	if not g.initialized then -- first time, create base frame for holding secure buttons and mask frame for overlays
		g.frame = CreateFrame("Frame", nil, UIParent) -- this is the reference frame for moving the grid overlays
		g.frame:SetBackdrop(overlayDefaults)
		g.frame:SetBackdropColor(0.3, 0.3, 0.3, 0.25)
		g.frame:SetBackdropBorderColor(0, 0, 0, 0.9)
		g.frame:SetMovable(true); g.frame:SetClampedToScreen(true)
		g.frame:SetScript("OnMouseDown", InCombatBar_OnMouseDown)
		g.frame:SetScript("OnMouseUp", InCombatBar_OnMouseUp)
		g.mask = CreateFrame("Frame", nil, UIParent) -- this is the mask frame for mouse events and showing in-combat highlights
		g.mask:SetClampedToScreen(true)
		g.secureButtons = {} -- set of allocated secure buttons
		g.overlays = {} -- set of allocated overlays for animating textures in combat
		g.allocated = 0 -- how many buttons and overlays have actually been allocated
		g.count = 0 -- how mnay buttons and overlays are currently in use
		g.initialized = true
	end
	while g.allocated < #list do -- allocate more slots if necessary
		local i = g.allocated + 1
		local v = {}
		v.container = CreateFrame("Frame", nil, g.mask)
		v.container:SetScript("OnMouseDown", InCombatBar_OnMouseDown)
		v.container:SetScript("OnMouseUp", InCombatBar_OnMouseUp)
		v.highlight = v.container:CreateTexture(nil, "ARTWORK")
		v.backdrop = v.container:CreateTexture(nil, "OVERLAY")
		v.backdrop:SetTexture("Interface\\AddOns\\Raven\\Borders\\IconDefault")			
		v.anim = v.container:CreateAnimationGroup()
		v.anim:SetLooping("NONE")
		local grow = v.anim:CreateAnimation("Scale")
		grow:SetScale(3, 3); grow:SetOrigin('CENTER', 0, 0); grow:SetDuration(0.25); grow:SetOrder(1)
		local shrink = v.anim:CreateAnimation("Scale")
		shrink:SetScale(-3, -3); shrink:SetOrigin('CENTER', 0, 0); shrink:SetDuration(0.25); shrink:SetOrder(2)
		g.overlays[i] = v
		g.secureButtons[i] = AllocateOverlay() -- secure button for cancelling the buff
		g.allocated = i
	end
	g.count = #list; g.anchor = "TOPRIGHT"; g.opt = opt
	if opt.layout then if opt.direction then g.anchor = "TOPLEFT" end else if opt.direction then g.anchor = "BOTTOMRIGHT" end end
	if g.count > 0 then
		local step = opt.size + opt.spacing
		local w, h = (step * g.count) + opt.spacing, step + opt.spacing
		if not opt.layout then local t = w; w = h; h = t end
		g.frame:SetFrameStrata("MEDIUM"); g.frame:SetAlpha(opt.alpha); g.frame:SetScale(opt.scale); g.frame:SetSize(w, h)
		if opt.anchorFrame and GetClickFrame(opt.anchorFrame) then -- use relative positioning
			g.frame:ClearAllPoints(); g.frame:SetPoint(opt.anchorPoint or "CENTER", opt.anchorFrame, opt.anchorPoint or "CENTER", opt.anchorX, opt.anchorY)
		else -- use manual positioning
			local scale = opt.scale; if not scale or (scale <= 0) then scale = 1 end
			local dx, dy = (opt.offsetX * displayWidth) / opt.scale, (opt.offsetY * displayHeight) / opt.scale
			g.frame:ClearAllPoints(); g.frame:SetPoint(g.anchor, UIParent, "BOTTOMLEFT", dx, dy)
		end
		if lock then g.frame:Hide() else g.frame:Show() end
		g.mask:SetFrameStrata("MEDIUM"); g.mask:SetAlpha(opt.alpha); g.mask:SetScale(opt.scale); g.mask:SetSize(w, h)
		g.mask:ClearAllPoints(); g.mask:SetAllPoints(g.frame); g.mask:SetFrameLevel(g.frame:GetFrameLevel() + 5)

		for i = 1, g.count do
			local id, tt = list[i], "buff"
			local b = g.secureButtons[i]
			b.aura_id = id; b.aura_tt = "spell name"; b.tooltipAnchor = opt.anchorTips
			b:SetAttribute("type2", "macro"); b:SetAttribute("macrotext2", "/cancelaura " .. id)
			b:SetSize(opt.size, opt.size); b:SetScale(opt.scale)
			local dist = i - 1
			if (opt.layout and not opt.direction) or (not opt.layout and opt.direction) then dist = g.count - i end
			local x, y = opt.spacing + (step * dist), opt.spacing
			if not opt.layout then local t = x; x = y; y = t end
			b:ClearAllPoints(); b:SetPoint("TOPLEFT", g.frame, "TOPLEFT", x, -y)
			b:SetFrameLevel(g.frame:GetFrameLevel() + 1)
			if lock then b:SetAlpha(0) else b:SetAlpha(opt.alpha) end
			b:Show()
			local v = g.overlays[i]
			v.buffName = id
			v.container:SetSize(opt.size, opt.size); v.container:SetPoint("TOPLEFT", g.mask, "TOPLEFT", x, -y)
			v.highlight:ClearAllPoints(); v.highlight:SetPoint("CENTER", v.container, "CENTER"); v.backdrop:SetAllPoints(v.container)
		end
	else -- nothing in the list
		g.frame:Hide()
	end
	if g.allocated > g.count then -- hide any extras
		for i = g.count + 1, g.allocated do
			g.secureButtons[i]:Hide()
			local v = g.overlays[i]
			v.highlight:Hide(); v.backdrop:Hide(); v.startTime = nil
		end
	end
end

-- Highlight an overlay in the grid when the associated buff is active
function MOD:UpdateInCombatBarOverlays()
	local g = gridLayout
	if g and g.opt and g.initialized then -- make sure have valid layout
		if not InCombatLockdown() then -- can change enable setting only if out of combat
			if not g.enable then
				if not g.hidden then g.frame:Hide(); g.hidden = true for i = 1, g.count do g.secureButtons[i]:Hide() end end
			else
				if g.hidden then g.hidden = false; for i = 1, g.count do g.secureButtons[i]:Show() end end
				if g.lock then g.frame:Hide() else g.frame:Show() end
			end
		end
		for i = 1, g.count do
			local v = g.overlays[i]
			local id, buff, icon, duration, expires, _ = v.buffName, nil, nil, 0, 0, nil
			if not g.hidden and (g.opt.ooc or InCombatLockdown()) then -- check if in combat or have out-of-combat enabled
				buff, _, icon, _, _, duration, expires = UnitBuff("player", id)
			end
			if buff then
				v.highlight:SetTexture(icon); v.highlight:Show(); v.container:EnableMouse(false)
				local w = g.opt.size
				if g.opt.noBorder then -- enable or hide optional default border
					v.backdrop:Hide(); v.highlight:SetTexCoord(0, 1, 0, 1)
				else
					v.backdrop:Show(); v.highlight:SetTexCoord(0.06, 0.94, 0.06, 0.94); w = w * 0.88
				end		
				v.highlight:SetSize(w, w)				
				if g.opt.pulseStart and not v.startTime then v.anim:Play(); v.startTime = GetTime() end
				local alpha = 1
				if duration and duration > 0 then
					local timeLeft = expires - GetTime()
					if g.opt.pulseEnd and (timeLeft < 0.45) and not v.anim:IsPlaying() then v.anim:Play() end
					local flashing = g.opt.flashExpiring and g.opt.flashTime and (timeLeft < g.opt.flashTime)
					if flashing then alpha = MOD.Nest_FlashAlpha(1, 1) end
				end
				if g.opt.mouseoverDetect and not g.mask:IsMouseOver(2, -2, -2, 2) then alpha = alpha * (g.opt.mouseoverAlpha or 0.5) end
				v.container:SetAlpha(alpha)
			else
				v.highlight:Hide(); v.backdrop:Hide(); v.anim:Stop(); v.startTime = nil; v.container:EnableMouse(not g.hidden)
			end
		end
	end
end

-- Refresh animations for the in combat bar
function MOD:RefreshInCombatBar()
	local g = gridLayout
	if g and g.opt and g.initialized then -- make sure have valid layout
		for i = 1, g.count do
			local v = g.overlays[i]
			local id, buff, icon, duration, expires, _ = v.buffName, nil, nil, 0, 0, nil
			if not g.hidden and (g.opt.ooc or InCombatLockdown()) then -- check if in combat or have out-of-combat enabled
				buff, _, icon, _, _, duration, expires = UnitBuff("player", id)
			end
			if buff then
				local alpha = 1
				if duration and duration > 0 then
					local timeLeft = expires - GetTime()
					if g.opt.pulseEnd and (timeLeft < 0.45) and not v.anim:IsPlaying() then v.anim:Play() end
					local flashing = g.opt.flashExpiring and g.opt.flashTime and (timeLeft < g.opt.flashTime)
					if flashing then alpha = MOD.Nest_FlashAlpha(1, 1) end
				end
				if g.opt.mouseoverDetect and not g.mask:IsMouseOver(2, -2, -2, 2) then alpha = alpha * (g.opt.mouseoverAlpha or 0.5) end
				v.container:SetAlpha(alpha)
			end
		end
	end
end

-- Return a macro to cancel a buff on a weapon with the specified icon
local function GetTempWeaponCancelMacro(id)
	TemporaryEnchantFrame_Update(GetWeaponEnchantInfo())
	local t1, t2 = TempEnchant1:GetID(), TempEnchant2:GetID()
	local macro, slot = nil, weaponSlots[id]
	if slot == t1 then
		macro = "/click TempEnchant1 RightButton"
	elseif slot == t2 then
		macro = "/click TempEnchant2 RightButton"
	end
	return macro
end

-- Activate an overlay for a bar by filling in secure attributes and placing it on top of a bar's icon
local function ActivateOverlay(bar, frame)
	if not InCombatLockdown() then
		local bat = bar.attributes
		local tt, id, unit = bat.tooltipType, bat.tooltipID, bat.tooltipUnit
		if ((tt == "buff") or (tt == "weapon")) and unit and UnitIsUnit(unit, "player") then
			local b = bar.overlay
			if not b then b = AllocateOverlay(); bar.overlay = b end -- allocate one if necessary
			if tt == "buff" then
				b:SetAttribute("type2", "cancelaura"); b:SetAttribute("index", id)
			elseif tt == "weapon" then
				local macro = GetTempWeaponCancelMacro(id)
				if macro then b:SetAttribute("type2", "macro"); b:SetAttribute("macrotext2", macro) end
			end
			b.aura_id = id
			b.aura_tt = tt
			b.aura_caster = bat.caster
			b.aura_spell = bat.tooltipSpell
			b.aura_list = bat.listID
			b.tooltipAnchor = bar.tooltipAnchor
			b:ClearAllPoints()
			b:SetSize(frame:GetWidth(), frame:GetHeight())
			b:SetAllPoints(frame)
			b:SetFrameLevel(frame:GetFrameLevel() + 5)
			b:EnableMouse(true); b:Show()
		end
	end
end

-- Deactivate an overlay by clearing anything that could cause taint and hiding it
local function DeactivateOverlay(b)
	if b then
		if MOD.tooltipOverlay == b then MOD.tooltipOverlay = nil; GameTooltip:Hide() end
		b:ClearAllPoints()
		b:EnableMouse(false); b:Hide()
	end
end

-- Release an overlay for a bar back to the available pool
local function ReleaseOverlay(bar)
	local b = bar.overlay
	if b then
		if not InCombatLockdown() then DeactivateOverlay(b) end -- already deactivated if in combat
		overlayPool[b] = true
		bar.overlay = nil
	end
end

-- When enter combat deactivate all bar overlays
local function Overlays_EnterCombat()
	InCombatBar_OnMouseUp()
	local bgs = MOD.Nest_GetBarGroups()
	for _, bg in pairs(bgs) do
		for _, bar in pairs(bg.bars) do if bar.overlay then DeactivateOverlay(bar.overlay) end end
	end
end

-- When leave combat, trigger update so overlays get reactivated
local function Overlays_LeaveCombat() MOD:UpdateInCombatBar(); MOD.Nest_TriggerUpdate() end

-- Initialize the overlays used to cancel player buffs
function MOD:InitializeOverlays()
	local cbs = { activate = ActivateOverlay, deactivate = DeactivateOverlay, release = ReleaseOverlay }
	self:RegisterEvent("PLAYER_REGEN_DISABLED", Overlays_EnterCombat)
	self:RegisterEvent("PLAYER_REGEN_ENABLED", Overlays_LeaveCombat)
	MOD.Nest_RegisterCallbacks(cbs)
end