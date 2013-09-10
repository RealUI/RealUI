--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved

   Things to do when I get the time
   ===
   * customisation for sizes/positions of auras & width of container frame, etc
   * customisation for raid target icons
   * probably don't need to adjust for uiscale since the frame is parented to WorldFrame now, test
   * feature: whitelist to hide/colour nameplates based on name
   * feature: un-fade units which are casting
   * fix spell icon is 1 pixel too large/small depending on uiscale
]]

local kui = LibStub('Kui-1.0')
local LSM = LibStub('LibSharedMedia-3.0')
local kn = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local slowUpdateTime, critUpdateTime = 1, .1

-- TODO this is temporary for compatibility etc etc
local addon = kn

--[===[@debug@
--KuiNameplatesDebug=true
--@end-debug@]===]

local targetExists

--------------------------------------------------------------------- globals --
local select, strfind, strsplit, pairs, ipairs, unpack, tinsert, type, floor
    = select, strfind, strsplit, pairs, ipairs, unpack, tinsert, type, floor

------------------------------------------------------------- Frame functions --
local function SetFrameCentre(f)
	-- using CENTER breaks pixel-perfectness with oddly sized frames
	-- .. so we have to align frames manually.
	local w,h = f:GetSize()

	if f.trivial then
		f.x = floor((w / 2) - (addon.sizes.frame.twidth / 2))
		f.y = floor((h / 2) - (addon.sizes.frame.theight / 2))
	else
		f.x = floor((w / 2) - (addon.sizes.frame.width / 2))
		f.y = floor((h / 2) - (addon.sizes.frame.height / 2))
	end
end
-- set colour of health bar according to reaction/threat
local function SetHealthColour(self)
	if self.hasThreat then
		self.health.reset = true
		self.health:SetStatusBarColor(unpack(addon.db.profile.tank.barcolour))
		return
	end

	local r, g, b = self.oldHealth:GetStatusBarColor()
	if self.health.reset  or
	   r ~= self.health.r or
	   g ~= self.health.g or
	   b ~= self.health.b
	then
		-- store the default colour
		self.health.r, self.health.g, self.health.b = r, g, b
		self.health.reset, self.friend, self.player = nil, nil, nil

		if g > .9 and r == 0 and b == 0 then
			-- friendly NPC
			self.friend = true
			r, g, b = unpack(kn.r[3])
		elseif b > .9 and r == 0 and g == 0 then
			-- friendly player
			self.friend = true
			self.player = true
			r, g, b = unpack(kn.r[5])
		elseif r > .9 and g == 0 and b == 0 then
			-- enemy NPC
			r, g, b = unpack(kn.r[1])
		elseif (r + g) > 1.8 and b == 0 then
			-- neutral NPC
			r, g, b = unpack(kn.r[2])
		elseif r < .6 and (r+g) == (r+b) then
			-- tapped NPC
			r, g, b = unpack(kn.r[4])
		else
			-- enemy player, use default UI colour
			self.player = true
		end

		self.health:SetStatusBarColor(r, g, b)
	end
end

local function SetNameColour(self)
	if self.friend then
		self.name:SetTextColor(unpack(addon.db.profile.text.friendlyname))
	else
		self.name:SetTextColor(unpack(addon.db.profile.text.enemyname))
	end
end

local function SetGlowColour(self, r, g, b, a)
	if not r then
		-- set default colour
		r, g, b = 0, 0, 0
	end

	if not a then
		a = .85
	end

    self.bg:SetVertexColor(r, g, b, a)
end
---------------------------------------------------- Update health bar & text --
local function OnHealthValueChanged(oldBar, curr)
	local frame	= oldBar:GetParent():GetParent().kui
	local min, max	= oldBar:GetMinMaxValues()
	local deficit,    big, sml, condition, display, pattern, rules
	    = max - curr, '',  ''

	frame.health:SetMinMaxValues(min, max)
	frame.health:SetValue(curr)
	
	-- select correct health display pattern
	if frame.friend then
		pattern = addon.db.profile.hp.friendly
	else
		pattern = addon.db.profile.hp.hostile
	end

	-- parse pattern into big/sml
	rules = { strsplit(';', pattern) }

	for k, rule in ipairs(rules) do
		condition, display = strsplit(':', rule)

		if condition == '<' then
			condition = curr < max
		elseif condition == '=' then
			condition = curr == max
		elseif condition == '<=' or condition == '=<' then
			condition = curr <= max
		else
			condition = nil
		end

		if condition then
			if display == 'd' then
				big = '-'..kui.num(deficit)
				sml = kui.num(curr)
			elseif display == 'm' then
				big = kui.num(max)
			elseif display == 'c' then
				big = kui.num(curr)
				sml = curr ~= max and kui.num(max)
			elseif display == 'p' then
				big = floor(curr / max * 100)
				sml = kui.num(curr)
			end

			break
		end
	end

	frame.health.p:SetText(big)

	if frame.health.mo then
		frame.health.mo:SetText(sml)
	end
end

------------------------------------------------------- Frame script handlers --
local function OnFrameShow(self)
	local f = self.kui

	-- reset name
	f.name.text = f.oldName:GetText()
	f.name:SetText(f.name.text)

	if addon.db.profile.hp.mouseover then
		-- force un-highlight
		f.highlighted = true
	end
	
	-- classifications
	if f.level.enabled then
		if f.boss:IsVisible() then
			f.level:SetText('??b')
			f.level:SetTextColor(1, 0, 0)
			f.level:Show()
		elseif f.state:IsVisible() then
			if f.state:GetTexture() == "Interface\\Tooltips\\EliteNameplateIcon"
			then
				f.level:SetText(f.level:GetText()..'+')
			else
				f.level:SetText(f.level:GetText()..'r')
			end
		end
	else
		f.level:Hide()
	end
	
	if f.state:IsVisible() then
		-- hide the elite/rare dragon
		f.state:Hide()
	end

	addon:StoreName(f)
	
	---------------------------------------------- Trivial sizing/positioning --
	local trivial = f.firstChild:GetScale() < 1
	
	if kn.uiscale then
		-- change our parent frame size if we're using fixaa..
		f:SetSize(self:GetWidth()/kn.uiscale, self:GetHeight()/kn.uiscale)
	end
	-- otherwise, size is changed automatically thanks to using SetAllPoints

	if trivial and not f.trivial or
	   not trivial and f.trivial or
	   not f.doneFirstShow
	then
		f.trivial = trivial
		f:SetCentre()

		addon:UpdateBackground(f, trivial)
		addon:UpdateHealthBar(f, trivial)
		addon:UpdateHealthText(f, trivial)
		addon:UpdateAlthealthText(f, trivial)
		addon:UpdateLevel(f, trivial)
		addon:UpdateName(f, trivial)
		addon:UpdateTargetGlow(f, trivial)

		f.doneFirstShow = true
	end
	
	-- force health update
	f:SetHealthColour()
	f:SetGlowColour()
	OnHealthValueChanged(f.oldHealth, f.oldHealth:GetValue())

	if f.fixaa then
		
		f.DoShow = true
	else
		f:Show()
	end

	kn:SendMessage('KuiNameplates_PostShow', f)
end

local function OnFrameHide(self)
	local f = self.kui
	f:Hide()

	f:SetFrameLevel(0)
	
	if f.targetGlow then
		f.targetGlow:Hide()
	end

	addon:ClearGUID(f)

	-- remove name from store
	-- if there are name duplicates, this will be recreated in an onupdate
	addon:ClearName(f)

	f.lastAlpha	= 0
	f.fadingTo	= nil
	f.hasThreat	= nil
	f.target	= nil

	-- unset stored health bar colours
	f.health.r, f.health.g, f.health.b, f.health.reset
		= nil, nil, nil, nil
	
	kn:SendMessage('KuiNameplates_PostHide', f)	
end

local function OnFrameEnter(self)
	addon:StoreGUID(self, UnitGUID('mouseover'))

	if self.highlight then
		self.highlight:Show()
	end

	if addon.db.profile.hp.mouseover then
		self.health.p:Show()
		if self.health.mo then self.health.mo:Show() end
	end
end

local function OnFrameLeave(self)
	if self.highlight then
		self.highlight:Hide()
	end

	if not self.target and addon.db.profile.hp.mouseover then
		self.health.p:Hide()
		if self.health.mo then self.health.mo:Hide() end
	end
end

-- stuff that needs to be updated every frame
local function OnFrameUpdate(self, e)
	local f = self.kui

	f.elapsed	= f.elapsed - e
	f.critElap	= f.critElap - e

	if f.fixaa then
		------------------------------------------------------------ Position --
		local scale = f.firstChild:GetScale()
		local x, y = select(4, f.firstChild:GetPoint())
		x = (x / kn.uiscale) * scale
		y = (y / kn.uiscale) * scale
	
		f:SetPoint('BOTTOMLEFT', WorldFrame, 'BOTTOMLEFT',
			floor(x - (f:GetWidth() / 2)),
			floor(y))
		
		-- show the frame after it's been moved so it doesn't flash
		-- .DoShow is set OnFrameShow
		if f.DoShow then
			f:Show()
			f.DoShow = nil
		end
	end
	
	f.defaultAlpha = self:GetAlpha()

	------------------------------------------------------------------- Alpha --
	if (f.defaultAlpha == 1 and
	    targetExists)          or
	   (addon.db.profile.fade.fademouse and
	    f.highlighted)
	then
		f.currentAlpha = 1
	elseif	targetExists or addon.db.profile.fade.fadeall then
		f.currentAlpha = addon.db.profile.fade.fadedalpha or .3
	else
		f.currentAlpha = 1
	end
	------------------------------------------------------------------ Fading --
	if addon.db.profile.fade.smooth then
		-- track changes in the alpha level and intercept them
		if f.currentAlpha ~= f.lastAlpha then
			if not f.fadingTo or f.fadingTo ~= f.currentAlpha then
				if kui.frameIsFading(f) then
					kui.frameFadeRemoveFrame(f)
				end

				-- fade to the new value
				f.fadingTo 	  = f.currentAlpha
				local alphaChange = (f.fadingTo - (f.lastAlpha or 0))

				kui.frameFade(f, {
					mode		= alphaChange < 0 and 'OUT' or 'IN',
					timeToFade	= abs(alphaChange) * (addon.db.profile.fade.fadespeed or .5),
					startAlpha	= f.lastAlpha or 0,
					endAlpha	= f.fadingTo,
					finishedFunc = function()
						f.fadingTo = nil
					end,
				})
			end

			f.lastAlpha = f.currentAlpha
		end
	else
		f:SetAlpha(f.currentAlpha)
	end

	-- call delayed updates
	if f.elapsed <= 0 then
		f.elapsed = slowUpdateTime
		f:UpdateFrame()
	end

	if f.critElap <= 0 then
		f.critElap = critUpdateTime
		f:UpdateFrameCritical()
	end
end

-- stuff that can be updated less often
local function UpdateFrame(self)
	-- ensure a frame is still stored for this name, as name conflicts cause
	-- it to be erased when another might still exist
	addon:StoreName(self)

	-- Health bar colour
	self:SetHealthColour()
	
	-- Name text colour
	self:SetNameColour()
end

-- stuff that needs to be updated often
local function UpdateFrameCritical(self)
	------------------------------------------------------------------ Threat --
	if self.glow:IsVisible() then
		self.glow.wasVisible = true

		-- set glow to the current default ui's colour
		self.glow.r, self.glow.g, self.glow.b = self.glow:GetVertexColor()
		self:SetGlowColour(self.glow.r, self.glow.g, self.glow.b)

		if not self.friend and addon.db.profile.tank.enabled then
			-- in tank mode; is the default glow red (are we tanking)?
			self.hasThreat = (self.glow.g + self.glow.b) < .1

			if self.hasThreat then
				-- tanking; recolour bar & glow
				local r, g, b, a = unpack(addon.db.profile.tank.glowcolour)
				self:SetGlowColour(r, g, b, a)
				self:SetHealthColour()
			end
		end
	elseif self.glow.wasVisible then
		self.glow.wasVisible = nil

		-- restore shadow glow colour
		self:SetGlowColour()

		if self.hasThreat then
			-- lost threat
			self.hasThreat = nil
			self:SetHealthColour()
		end
	end
	------------------------------------------------------------ Target stuff --
	if targetExists and
	   self.defaultAlpha == 1 and
	   self.name.text == UnitName('target')
	then
		if not self.target then
			-- this frame just became targeted
			self.target = true
			addon:StoreGUID(self, UnitGUID('target'))

			-- move this frame above others
			self:SetFrameLevel(10)

			if addon.db.profile.hp.mouseover then
				self.health.p:Show()
				if self.health.mo then self.health.mo:Show() end
			end
		
			if self.targetGlow then
				self.targetGlow:Show()
			end

			kn:SendMessage('KuiNameplates_PostTarget', self)
		end
	elseif self.target then
		self.target = nil

		self:SetFrameLevel(0)
		
		if self.targetGlow then
			self.targetGlow:Hide()
		end
		
		if not self.highlighted and addon.db.profile.hp.mouseover then
			self.health.p:Hide()
			if self.health.mo then self.health.mo:Hide() end
		end
	end

	--------------------------------------------------------------- Mouseover --
	if self.oldHighlight:IsShown() then
		if not self.highlighted then
			self.highlighted = true
			OnFrameEnter(self)
		end
	elseif self.highlighted then
		self.highlighted = false
		OnFrameLeave(self)
	end
	
	--[===[@debug@
	if _G['KuiNameplatesDebug'] then
		if self.guid then
			self.guidtext:SetText(self.guid)

			if addon:FrameHasGUID(self) then
				self.guidtext:SetTextColor(1,1,1)
			else
				self.guidtext:SetTextColor(1,0,0)
			end
		else
			self.guidtext:SetText(nil)
		end

		if addon:FrameHasName(self) then
			self.nametext:SetText('Has name')
		else
			self.nametext:SetText(nil)
		end
		
		if self.friend then
			self.isfriend:SetText('friendly')
		else
			self.isfriend:SetText('not friendly')
		end
	end
	--@end-debug@]===]
end

--------------------------------------------------------------- KNP functions --
function kn:IsNameplate(frame)
	if frame:GetName() and strfind(frame:GetName(), '^NamePlate%d') then
		local nameTextChild = select(2, frame:GetChildren())
		if nameTextChild then
			local nameTextRegion = nameTextChild:GetRegions()
			return (nameTextRegion and nameTextRegion:GetObjectType() == 'FontString')
		end
	end
end

function kn:InitFrame(frame)
	-- container for kui objects!
	frame.kui = CreateFrame('Frame', nil, WorldFrame) 
	frame.kui:SetFrameLevel(0)
	local f = frame.kui

	f.fontObjects = {}
	
	-- fetch default ui's objects
	local overlayChild, nameTextChild = frame:GetChildren()
	local healthBar, castBar = overlayChild:GetChildren()
	
	local _, castbarOverlay, shieldedRegion, spellIconRegion,
		  spellNameRegion, spellNameShadow
		= castBar:GetRegions()

	local nameTextRegion = nameTextChild:GetRegions()
    local glowRegion, overlayRegion, highlightRegion, levelTextRegion,
          bossIconRegion, raidIconRegion, stateIconRegion
		= overlayChild:GetRegions()

	overlayRegion:SetTexture(nil)
	highlightRegion:SetTexture(nil)
	bossIconRegion:SetTexture(nil)
	shieldedRegion:SetTexture(nil)
	castbarOverlay:SetTexture(nil)
	glowRegion:SetTexture(nil)
	spellIconRegion:SetSize(.01,.01)
	spellNameShadow:SetTexture(nil)
	spellNameRegion:Hide()

	-- make default healthbar & castbar transparent
	healthBar:SetStatusBarTexture(kui.m.t.empty)
	castBar:SetStatusBarTexture(kui.m.t.empty)

	f.firstChild = overlayChild

	--f.bg       = overlayRegion
	f.glow       = glowRegion
	f.boss       = bossIconRegion
	f.state      = stateIconRegion
	f.level      = levelTextRegion
	f.icon       = raidIconRegion
	f.spell      = spellIconRegion
	f.spellName  = spellNameRegion
	f.shield     = shieldedRegion
	f.oldHealth  = healthBar
	f.oldCastbar = castBar

	f.oldName = nameTextRegion
	f.oldName:Hide()
	
	f.oldHighlight = highlightRegion

    --------------------------------------------------------- Frame functions --
    f.CreateFontString    = addon.CreateFontString -- TODO remove
    f.UpdateFrame         = UpdateFrame
    f.UpdateFrameCritical = UpdateFrameCritical
    f.SetHealthColour     = SetHealthColour
    f.SetNameColour       = SetNameColour
    f.SetGlowColour       = SetGlowColour
	f.SetCentre           = SetFrameCentre

    ------------------------------------------------------------------ Layout --
	local parent
	if self.db.profile.general.fixaa and kn.uiscale then
		f:SetFrameStrata('BACKGROUND')
		f:SetSize(frame:GetWidth()/kn.uiscale, frame:GetHeight()/kn.uiscale)
		f:SetScale(kn.uiscale)
		
		f:SetPoint('BOTTOMLEFT', UIParent)
		f:Hide()
		
		--[===[@debug@
		if _G['KuiNameplatesDebug'] then
			f:SetBackdrop({ bgFile = kui.m.t.solid })
			f:SetBackdropColor(0,0,0,.5)
		end
		--@end-debug@]===]
		
		f.fixaa = true
	else
		f:SetAllPoints(frame)
	end

	parent = f
	f.parent = parent
	
	f:SetCentre()

	self:CreateBackground(frame, f)
	self:CreateHealthBar(frame, f)

	-- overlay (text is parented to this) --------------------------------------
	f.overlay = CreateFrame('Frame', nil, f)
	f.overlay:SetAllPoints(f.health)
	f.overlay:SetFrameLevel(f.health:GetFrameLevel()+1)

	self:CreateHighlight(frame, f)
	self:CreateHealthText(frame, f)
	
	if self.db.profile.hp.showalt then
		self:CreateAltHealthText(frame, f)
	end

	if self.db.profile.text.level then
		self:CreateLevel(frame, f)
	else
		f.level:Hide()
	end

	self:CreateName(frame, f)
	
	-- target highlight --------------------------------------------------------
	if self.db.profile.general.targetglow then
		self:CreateTargetGlow(f)
	end

	-- raid icon ---------------------------------------------------------------
	f.icon:SetParent(f.overlay)
	f.icon:SetSize(kn.sizes.tex.raidicon, kn.sizes.tex.raidicon)

	f.icon:ClearAllPoints()
	f.icon:SetPoint('LEFT', f.health, 'RIGHT', 5, 1)
    ----------------------------------------------------------------- Scripts --
	frame:HookScript('OnShow', OnFrameShow)
	frame:HookScript('OnHide', OnFrameHide)
	frame:HookScript('OnUpdate', OnFrameUpdate)

	f.oldHealth:HookScript('OnValueChanged', OnHealthValueChanged)

	--[===[@debug@
	if _G['KuiNameplatesDebug'] then
		frame:SetBackdrop({bgFile=kui.m.t.solid})
		frame:SetBackdropColor(1, 1, 1, .5)

		f.isfriend = f:CreateFontString(f.overlay)
		f.isfriend:SetPoint('BOTTOM', frame, 'TOP')
		
		f.guidtext = f:CreateFontString(f.overlay)
		f.guidtext:SetPoint('TOP', frame, 'BOTTOM')

		f.nametext = f:CreateFontString(f.overlay)
		f.nametext:SetPoint('TOP', f.guidtext, 'BOTTOM')
	end
	--@end-debug@]===]

	------------------------------------------------------------ Finishing up --
    f.elapsed  = slowUpdateTime
	f.critElap = critUpdateTime

	kn:SendMessage('KuiNameplates_PostCreate', f)
	
	if frame:IsShown() then
		-- force OnShow
		OnFrameShow(frame)
	else
		f:Hide()
	end
end

---------------------------------------------------------------------- Events --
function kn:PLAYER_TARGET_CHANGED()
	targetExists = UnitExists('target')
end

-- automatic toggling of enemy frames
function kn:PLAYER_REGEN_ENABLED()
	SetCVar('nameplateShowEnemies', 0)
end
function kn:PLAYER_REGEN_DISABLED()
	SetCVar('nameplateShowEnemies', 1)
end

------------------------------------------------------------- Script handlers --
do
	local WorldFrame = WorldFrame

	function kn:OnUpdate()
		local frames = select('#', WorldFrame:GetChildren())

		if frames ~= self.numFrames then
			local i, f

			for i = 1, frames do
				f = select(i, WorldFrame:GetChildren())
				if self:IsNameplate(f) and not f.kui then
					self:InitFrame(f)
					tinsert(self.frameList, f)
				end
			end

			self.numFrames = frames
		end
	end
end

function kn:ToggleCombatEvents(io)
	if io then
		self:RegisterEvent('PLAYER_REGEN_ENABLED')
		self:RegisterEvent('PLAYER_REGEN_DISABLED')
	else
		self:UnregisterEvent('PLAYER_REGEN_ENABLED')
		self:UnregisterEvent('PLAYER_REGEN_DISABLED')
	end
end
