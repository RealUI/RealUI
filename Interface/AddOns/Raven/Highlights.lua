-- Raven is an addon to monitor auras and cooldowns, providing timer bars, action bar highlights, and helpful notifications.

-- Highlights.lua contains routines for adding colored overlays to action bar buttons when associated spells are active.
-- It also adds text overlays showing remaining cooldown time. Currently works with Bartender4, Dominos and Macaroon buttons.
-- There are no exported functions other than those called to initialize and update highlights.

local MOD = Raven
MOD.highlights = false -- set to true if bar mods are loaded that support Raven's highlighting

local media = LibStub("LibSharedMedia-3.0")
local hidden = false
local buttons = {}
local highlightOverlays = {}
local buttonFacadeCache = {}
local textOverlays = {}
local textFont = nil
local textFsize = 10
local flashing = false
local getActionFunc = nil
local updateButtonThrottle = 0
local defaultBars = { "ActionButton", "MultiBarBottomLeftButton", "MultiBarBottomRightButton", "MultiBarRightButton", "MultiBarLeftButton", "BonusActionButton" }

-- Initialization routine checks if required addons are loaded before enabling highlights and cooldown counts
function MOD:InitializeHighlights()
	if IsAddOnLoaded("Bartender4") or IsAddOnLoaded("Dominos") or IsAddOnLoaded("Macaroon") then
		MOD.highlights = true
	end
end

-- Set highlight-related defaults in the profile
function MOD:SetHighlightDefaults()
	if OmniCC then -- disable counters by default if using OmniCC
		MOD.DefaultProfile.global.CooldownText = false
	end
end

-- Check if a button is active and, if so, cache info about associated spell or macro or item
local function CheckButtonAction(b, action)
	local bType, bID = GetActionInfo(action)
	bID = tonumber(bID) -- make sure this is a valid number since can return a string in some cases
	if bID and (bID > 0) then -- make sure it is a valid index
		local sID = nil
		if bType == "macro" then
			sID = GetMacroSpell(bID)
		elseif bType == "spell"  then
			sID = GetSpellInfo(bID) -- Cataclysm changed return value from GetActionInfo to spell id
		elseif bType == "item" then
			sID = GetItemInfo(bID)
		end
		if sID then
			if not buttons[b] then
				buttons[b] = { sID, bType, bID }
			else
				local t = buttons[b]
				t[1], t[2], t[3] = sID, bType, bID
			end
		end
	end
end

-- Check for visible buttons and cache information that doesn't change often
local function UpdateActiveButtons()
	for _, t in pairs(buttons) do t[1] = nil end -- clear current button descriptors
	
	if IsAddOnLoaded("Bartender4") then -- Bartender4
		for id = 1, 120 do -- iterate through all of Bartender4's buttons
			local b = _G["BT4Button"..id]
			if b and b:IsVisible() and b.GetAction then -- only want buttons that are visible and if current version of BT4
				local state, bAction = b:GetAction()
				if (state == "action") and bAction then CheckButtonAction(b, bAction) end
			end
		end
	end
	if IsAddOnLoaded("Dominos") then -- Dominos
		for id = 1, 72 do -- iterate through Dominos special buttons
			local b = _G["DominosActionButton"..(id - 12)] -- required until Dominos fixes button numbering
			if b and b:IsVisible() then -- only want buttons that are visible
				local bAction = ActionButton_GetPagedID(b)
				if bAction then CheckButtonAction(b, bAction) end
			end
		end
		for _, bSet in pairs(defaultBars) do
			for id = 1, 12 do -- iterate through buttons on the default bars
				local b = _G[bSet..id]
				if b and b:IsVisible() then -- only want buttons that are visible
					local bAction = ActionButton_GetPagedID(b)
					if bAction then CheckButtonAction(b, bAction) end
				end
			end
		end
	end
	if IsAddOnLoaded("Macaroon") then
		for _, button in pairs(Macaroon.Buttons) do
			local b = _G[button[1]:GetName()] -- look up the actual button from the name in the Macaroon table
			if b then
				if b.config and b.config.type == "action" then
					local bAction = SecureButton_GetModifiedAttribute(b, "action", SecureButton_GetEffectiveButton(b))
					if bAction then CheckButtonAction(b, bAction) end
				else
					local sID = nil
					if b.macroshow then
						sID = string.match(b.macroshow,"[^%(]+")
					elseif b.macrospell then
						sID = string.match(b.macrospell,"[^%(]+")
					end
					if sID then
						if not buttons[b] then
							buttons[b] = { sID, "macro", nil }
						else
							local t = buttons[b]
							t[1], t[2], t[3] = sID, "macro", nil
						end
					end
				end
			end
		end
	end
end

-- Hide all the overlays in the overlays table or, if using Masque, restore saved vertex colors
local function HideOverlays()
	-- Overlays are created on demand to minimize performance impact when hiding the overlays at the start of each update
	if not hidden then
		hidden = true
		for _, ol in pairs(highlightOverlays) do ol:Hide() end-- hide highlight overlays, if any
		for _, ol in pairs(textOverlays) do ol:Hide() end -- hide text overlays, if any
		
		if MOD.MSQ then
			for b, c in pairs(buttonFacadeCache) do -- restore the saved color
				local ntex = MOD.MSQ:GetNormal(b)
				ntex:SetVertexColor(c.r, c.g, c.b, c.a)
			end
			for b, t in pairs(buttons) do if not t[1] then buttonFacadeCache[b] = nil end end -- purge inactive buttons
			if not MOD.db.global.ButtonFacade then -- purge the button facade cache when switching modes
				for b in pairs(buttonFacadeCache) do buttonFacadeCache[b] = nil end
			end
		end		
	end
end

-- Set color and alpha for a button overlay
-- If using button facade then save current color for the button and set to new color
local function SetOverlayColor(b, alpha, vr, vg, vb, va)
	if MOD.MSQ and MOD.db.global.ButtonFacade then
		local ntex = MOD.MSQ:GetNormal(b)
		local cr, cg, cb, ca = ntex:GetVertexColor()
		local c = buttonFacadeCache[b]
		if c then
			c.r = cr; c.g = cg; c.b = cb; c.a = ca
		else
			buttonFacadeCache[b] = { r = cr, g = cg, b = cb, a = ca }
		end
		ntex:SetVertexColor(vr, vg, vb, va)
	else
		local olName = b:GetName() .. "RavenHighlight"
		local ol = _G[olName]
		if not ol then -- Create an overlay if one has not yet been made for this button
			ol = MOD.frame:CreateTexture(olName, "OVERLAY")
			ol:SetTexture("Interface\\Buttons\\CheckButtonHilight"); ol:SetAllPoints(b); ol:SetBlendMode("ADD")
			table.insert(highlightOverlays, ol)
		end
		if ol then -- Setting the vertex color will create the desired outer glow
			ol:SetVertexColor(vr, vg, vb, va); ol:SetAlpha(alpha); ol:Show()
		end
	end
end

-- Check for an active aura cast by player
local function CheckUnitAura(unit, aname, isBuff)
	local auraList = MOD:CheckAura(unit, aname, isBuff)
	for _, aura in pairs(auraList) do -- isBuff, timeLeft, count, btype, duration, caster, isStealable, icon, rank, expire, slot
		if aura[6] == "player" then return aura end -- check if aura is cast by player
	end
	return nil
end

-- Test if button spell is active (and cast by player) and enable appropriate color overlay
local function UpdateButtonHighlight(button, sID, alpha)
	if sID then
		local aura, timeLeft, t, duration
		local buffed = nil
		local p = MOD.db.global
		-- First check target buff or debuff depending on whether it is friendly or not
		if (UnitExists("target") ~= nil) then
			if (UnitIsFriend("player", "target") ~= nil) then
				if p.TargetBuffHighlights then
					aura = CheckUnitAura("target", sID, true)
					if aura then buffed = true; timeLeft = aura[2]; duration = aura[5] end
					t = p.TargetBuffColor
				end
			else
				if p.TargetDebuffHighlights then 
					aura = CheckUnitAura("target", sID, false)
					if aura then buffed = true; timeLeft = aura[2]; duration = aura[5] end
					t = p.TargetDebuffColor
				end
			end
		end
		-- Second check focus buff or debuff depending on whether it is friendly or not
		if (buffed == nil) and (UnitExists("focus") ~= nil) then
			if (UnitIsFriend("player", "focus") ~= nil) then
				if p.FocusBuffHighlights then
					aura = CheckUnitAura("focus", sID, true)
					if aura then buffed = true; timeLeft = aura[2]; duration = aura[5] end
					t = p.FocusBuffColor
				end
			else
				if p.FocusDebuffHighlights then 
					aura = CheckUnitAura("focus", sID, false)
					if aura then buffed = true; timeLeft = aura[2]; duration = aura[5] end
					t = p.FocusDebuffColor
				end
			end
		end
		-- Then check player debuffs if no target or focus buff or debuff highlight set yet
		if (buffed == nil) and p.PlayerDebuffHighlights then
			aura = CheckUnitAura("player", sID, false)
			if aura then buffed = true; timeLeft = aura[2]; duration = aura[5] end
			t = p.PlayerDebuffColor
		end
		-- Check player buffs if still no highlight set
		if (buffed == nil) and p.PlayerBuffHighlights then
			aura = CheckUnitAura("player", sID, true)
			if aura then buffed = true; timeLeft = aura[2]; duration = aura[5] end
			t = p.PlayerBuffColor
		end

		-- Show overlay if buff active and not currently flashing
		if (buffed ~= nil) then
			if (not flashing) or (timeLeft > p.FlashTime) or (duration == 0) then
				SetOverlayColor(button, alpha, t.r, t.g, t.b, t.a)
			end
		end
	end
end

-- Create a text overlay for a button and add it to overlays table
local function CreateTextOverlay(b)
	local olName = b:GetName() .. "RavenText"
	local newol = MOD.frame:CreateFontString(olName, "OVERLAY")

	newol:SetAllPoints(b)
	table.insert(textOverlays, newol)
	return newol
end

-- Set the text string in an overlay
local function SetOverlayText(b, alpha, text)
	local olName = b:GetName() .. "RavenText"
	local ol = _G[olName]
	-- Create a text overlay if one has not yet been made for this button
	if not ol then
		ol = CreateTextOverlay(b)
	end
	-- Set the font, font size, and text
	if ol then
		local halign, valign = "Center", "Center"
		if MOD.db.global.CooldownHorizontal then halign = MOD.db.global.CooldownHorizontal end
		if MOD.db.global.CooldownVertical then valign = MOD.db.global.CooldownVertical end
		ol:SetJustifyH(halign)	
		ol:SetJustifyV(valign)
		
		ol:SetFont(textFont, textFsize, "OUTLINE")
		ol:SetText(text)
		ol:SetAlpha(alpha)
		ol:Show()
	end
end

-- Add cooldown remaining time text to a button, if it is on cooldown
local function UpdateButtonCooldown(button, name, alpha)
	if MOD.db.global.CooldownText and name then
		local cd = MOD:CheckCooldown(name)
		if cd then
			local f = MOD.db.global.CooldownTimeFormat
			local s = MOD.db.global.CooldownTimeSpaces
			local c = MOD.db.global.CooldownTimeCase
			local t = Nest_FormatTime(cd[1], f, s, c)
			SetOverlayText(button, alpha, t)
		end
	end
end

-- Update highlights/cooldowns for all the buttons, creating and showing overlays as needed
function MOD:UpdateHighlights()
	HideOverlays() -- hide previous overlays, they are regenerated each time

	local p = MOD.db.global
	if not MOD.highlights or not MOD.db.global.HighlightsEnabled or not (p.TargetBuffHighlights or p.TargetDebuffHighlights or p.FocusBuffHighlights or
			p.FocusDebuffHighlights or p.PlayerBuffHighlights or p.PlayerDebuffHighlights or p.CooldownText) then return end
			
	hidden = false -- flag that shows there may be some overlays visible
	
	local now = GetTime() -- only update button cache when get actionbar change event plus every second or so just in case
	if MOD.updateActions or (now > updateButtonThrottle) then
		UpdateActiveButtons()
		MOD.updateActions = false
		updateButtonThrottle = now + 1.5 -- next update time
	end
	
	if p.FlashExpiring then -- check whether flashing buttons should show at this time
		flashing = (math.floor(GetTime() * 3) % 3) == 2
	else
		flashing = false
	end

	textFont =  media:Fetch("font", MOD.db.global.CooldownFont) -- cache current text font and font size
	if not textFont then textFont = GameFontNormal:GetFont() end -- default font
	textFsize = MOD.db.global.CooldownFsize - 3 -- oddly, the font size is rendering larger than it should
	
	for b, t in pairs(buttons) do -- update overlays for all buttons
		local sID, bType, bID = t[1], t[2], t[3]
		if sID and b:IsVisible() then -- make sure valid button table entry
			if (bType == "macro") and bID then -- update sID if it is a macro since it may change over time
				sID = GetMacroSpell(bID)
			end
			local alpha = b:GetEffectiveAlpha()
			UpdateButtonHighlight(b, sID, alpha)
			UpdateButtonCooldown(b, sID, alpha)
		end
	end
end

-- Raven is disabled so hide all features
function MOD:HideHighlights()
	HideOverlays() -- hide any overlays that may be visible
end
