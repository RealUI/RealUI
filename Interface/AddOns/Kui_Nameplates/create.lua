--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local kui = LibStub('Kui-1.0')

------------------------------------------------------------------ Background --
function addon:CreateBackground(frame, f)
	-- frame glow
	--f.bg:SetParent(f.parent)
	f.bg = f:CreateTexture(nil, 'ARTWORK')
	f.bg:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\FrameGlow')
	f.bg:SetTexCoord(0, .469, 0, .625)
	f.bg:SetVertexColor(0, 0, 0, .9)

	-- solid background
	f.bg.fill = f.parent:CreateTexture(nil, 'BACKGROUND')
	f.bg.fill:SetTexture(kui.m.t.solid)
	f.bg.fill:SetVertexColor(0, 0, 0, .8)
	f.bg.fill:SetDrawLayer('ARTWORK', 1) -- 1 sub-layer above .bg
end
function addon:UpdateBackground(f, trivial)
	f.bg:ClearAllPoints()
	f.bg.fill:ClearAllPoints()

	if trivial then
		-- switch to trivial sizes
		f.bg.fill:SetSize(self.sizes.frame.twidth, self.sizes.frame.theight)
		f.bg.fill:SetPoint('BOTTOMLEFT', f.x, f.y)
		
		f.bg:SetPoint('BOTTOMLEFT', f.bg.fill, 'BOTTOMLEFT',
			-self.sizes.frame.bgOffset/2,
			-self.sizes.frame.bgOffset/2)
		f.bg:SetPoint('TOPRIGHT', f.bg.fill, 'TOPRIGHT',
			self.sizes.frame.bgOffset/2,
			self.sizes.frame.bgOffset/2)
	elseif not trivial then
		-- switch back to normal sizes
		f.bg.fill:SetSize(self.sizes.frame.width, self.sizes.frame.height)		
		
		f.bg.fill:SetPoint('BOTTOMLEFT', f.x, f.y)

		f.bg:SetPoint('BOTTOMLEFT', f.bg.fill, 'BOTTOMLEFT',
			-self.sizes.frame.bgOffset,
			-self.sizes.frame.bgOffset)
		f.bg:SetPoint('TOPRIGHT', f.bg.fill, 'TOPRIGHT',
			self.sizes.frame.bgOffset,
			self.sizes.frame.bgOffset)
	end
end
------------------------------------------------------------------ Health bar --
function addon:CreateHealthBar(frame, f)
	f.health = CreateFrame('StatusBar', nil, f.parent)
	f.health:SetStatusBarTexture(kui.m.t.bar)

	if self.SetValueSmooth then
		-- smooth bar
		f.health.OrigSetValue = f.health.SetValue
		f.health.SetValue = self.SetValueSmooth
	end
end
function addon:UpdateHealthBar(f, trivial)
	f.health:ClearAllPoints()

	if trivial then
		f.health:SetSize(self.sizes.frame.twidth-2, self.sizes.frame.theight-2)
		f.health:SetPoint('BOTTOMLEFT', f.x+1, f.y+1)
	elseif not trivial then
		f.health:SetSize(self.sizes.frame.width - 2, self.sizes.frame.height - 2)
		f.health:SetPoint('BOTTOMLEFT', f.x+1, f.y+1)
	end
end
------------------------------------------------------------------- Highlight --
function addon:CreateHighlight(frame, f)
	if not self.db.profile.general.highlight then return end

	f.highlight = f.overlay:CreateTexture(nil, 'ARTWORK')
	f.highlight:SetTexture(kui.m.t.bar)
	f.highlight:SetAllPoints(f.health)

	f.highlight:SetVertexColor(1, 1, 1)
	f.highlight:SetBlendMode('ADD')
	f.highlight:SetAlpha(.4)
	f.highlight:Hide()
end
----------------------------------------------------------------- Health text --
function addon:CreateHealthText(frame, f)
	f.health.p = f:CreateFontString(f.overlay, {
		font = self.font, size = 'large', outline = "OUTLINE" })
	f.health.p:SetJustifyH('RIGHT')
	f.health.p:SetJustifyV('BOTTOM')
	f.health.p:SetHeight(10)
	f.health.p:SetPoint('BOTTOMRIGHT', f.health, 'TOPRIGHT',
		-2.5, self.uiscale and -(2.5/self.uiscale) or -2.5)
end
function addon:UpdateHealthText(f, trivial)
	if trivial then
		f.health.p:Hide()
	else
		f.health.p:Show()
	end
end
------------------------------------------------------------- Alt health text --
function addon:CreateAltHealthText(frame, f)
	f.health.mo = f:CreateFontString(f.overlay, {
		font = self.font, size = 'small', alpha = .6, outline = "OUTLINE" })
	f.health.mo:SetJustifyH('RIGHT')
	f.health.mo:SetJustifyV('TOP')
	f.health.mo:SetHeight(10)
	f.health.mo:SetPoint('TOPRIGHT', f.health, 'BOTTOMRIGHT',
		-2.5, self.uiscale and (3.5/self.uiscale) or 3.5)
end
function addon:UpdateAlthealthText(f, trivial)
	if not f.health.mo then return end
	if trivial then
		f.health.mo:Hide()
	else
		f.health.mo:Show()
	end
end
------------------------------------------------------------------ Level text --
function addon:CreateLevel(frame, f)
	if not f.level then return end

	f.level = f:CreateFontString(f.level, { reset = true,
		font = self.font, size = 'name', outline = 'OUTLINE' })
	f.level:SetParent(f.overlay)
	f.level:SetJustifyH('LEFT')
	f.level:SetJustifyV('BOTTOM')
	f.level:SetHeight(10)
	
	f.level:ClearAllPoints()
	f.level:SetPoint('BOTTOMLEFT', f.health, 'TOPLEFT',
		             2.5, self.uiscale and -(2.5/self.uiscale) or -2.5)
	f.level.enabled = true
end
function addon:UpdateLevel(f, trivial)
	if not f.level.enabled then
		f.level:Hide()
		return
	end

	if trivial then
		f.level:Hide()
	else
		f.level:Show()
	end
end
------------------------------------------------------------------- Name text --
function addon:CreateName(frame, f)	
	f.name = f:CreateFontString(f.overlay, {
		font = self.font, size = 'name', outline = 'OUTLINE' })
	f.name:SetJustifyV('BOTTOM')
	f.name:SetHeight(10)
end
function addon:UpdateName(f, trivial)
	f.name:ClearAllPoints()

	if trivial then
		f.name:SetJustifyH('CENTER')
		f.name:SetPoint('BOTTOM', f.health, 'TOP', 0, -3)
	else
		f.name:SetJustifyH('LEFT')
		f.name:SetPoint('RIGHT', f.health.p, 'LEFT')

		if f.level.enabled then
			f.name:SetPoint('LEFT', f.level, 'RIGHT', -2, 0)
		else
			f.name:SetPoint('BOTTOMLEFT', f.health, 'TOPLEFT',
			                2, self.uiscale and -(2/self.uiscale) or -2)
		end
	end
end
----------------------------------------------------------------- Target glow --
function addon:CreateTargetGlow(f)
	f.targetGlow = f.overlay:CreateTexture(nil, 'ARTWORK')
	f.targetGlow:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\target-glow')
	f.targetGlow:SetTexCoord(0, .593, 0, .875)
	f.targetGlow:SetPoint('TOP', f.overlay, 'BOTTOM', 0, 1)
	f.targetGlow:SetVertexColor(unpack(self.db.profile.general.targetglowcolour))
	f.targetGlow:Hide()
end
function addon:UpdateTargetGlow(f, trivial)
	if not f.targetGlow then return end
	if trivial then
		f.targetGlow:SetSize(self.sizes.tex.ttargetGlowW, self.sizes.tex.targetGlowH)
	else
		f.targetGlow:SetSize(self.sizes.tex.targetGlowW, self.sizes.tex.targetGlowH)
	end
end
