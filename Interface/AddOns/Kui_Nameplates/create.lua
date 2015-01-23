--[[
-- Kui_Nameplates
-- By Kesava at curse.com
-- All rights reserved
--
-- This file essentially creates "my" core layout. The eventual idea is to split
-- this into a seperate addon. That will come after a few necessary things are
-- ported to support that capability, such as the ability to theme cast bars.
]]
local addon = LibStub('AceAddon-3.0'):GetAddon('KuiNameplates')
local kui = LibStub('Kui-1.0')

------------------------------------------------------------------ Background --
function addon:CreateBackground(frame, f)
    -- frame glow
    --f.bg:SetParent(f)
    f.bg = f:CreateTexture(nil, 'ARTWORK')
    f.bg:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\FrameGlow')
    f.bg:SetTexCoord(0, .469, 0, .625)
    f.bg:SetVertexColor(0, 0, 0, .9)

    -- solid background
    f.bg.fill = f:CreateTexture(nil, 'BACKGROUND')
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
    f.health = CreateFrame('StatusBar', nil, f)
    f.health:SetStatusBarTexture(addon.bartexture)
	f.health.percent = 100

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
    f.highlight:SetTexture(addon.bartexture)
    f.highlight:SetAllPoints(f.health)

    f.highlight:SetVertexColor(1, 1, 1)
    f.highlight:SetBlendMode('ADD')
    f.highlight:SetAlpha(.4)
    f.highlight:Hide()
end
----------------------------------------------------------------- Health text --
function addon:CreateHealthText(frame, f)
    f.health.p = f:CreateFontString(f.overlay, {
        font = self.font,
        size = self.db.profile.general.leftie and 'large' or 'name',
        alpha = 1,
        outline = "OUTLINE" })

    f.health.p:SetHeight(10)
    f.health.p:SetJustifyH('RIGHT')
    f.health.p:SetJustifyV('BOTTOM')

    if self.db.profile.hp.mouseover then
        f.health.p:Hide()
    end
end
function addon:UpdateHealthText(f, trivial)
    if trivial then
        f.health.p:Hide()
    else
        if not self.db.profile.hp.mouseover then
            f.health.p:Show()
        end

        if self.db.profile.general.leftie then
            f.health.p:SetPoint('BOTTOMRIGHT', f.health, 'TOPRIGHT',
                                -2.5, -self.db.profile.text.healthoffset)
        else
            f.health.p:SetPoint('TOPRIGHT', f.health, 'BOTTOMRIGHT',
                                -2.5, self.db.profile.text.healthoffset + 4)
        end
    end
end
------------------------------------------------------------- Alt health text --
function addon:CreateAltHealthText(frame, f)
    f.health.mo = f:CreateFontString(f.overlay, {
        font = self.font, size = 'small', alpha = .6, outline = "OUTLINE" })

    f.health.mo:SetHeight(10)
    f.health.mo:SetJustifyH('RIGHT')
    f.health.mo:SetJustifyV('BOTTOM')

    if self.db.profile.hp.mouseover then
        f.health.mo:Hide()
    end
end
function addon:UpdateAltHealthText(f, trivial)
    if not f.health.mo then return end
    if trivial then
        f.health.mo:Hide()
    else
        if not self.db.profile.hp.mouseover then
            f.health.mo:Show()
        end

        if self.db.profile.general.leftie then
            f.health.mo:SetPoint('TOPRIGHT', f.health, 'BOTTOMRIGHT',
                                 -2.5, self.db.profile.text.healthoffset + 3)
        else
            f.health.mo:SetPoint('BOTTOMRIGHT', f.health.p, 'BOTTOMLEFT',0, 0)
        end
    end
end
------------------------------------------------------------------ Level text --
function addon:CreateLevel(frame, f)
    if not f.level then return end

    f.level = f:CreateFontString(f.level, { reset = true,
        font = self.font,
        size = 'name',
        alpha = 1,
        outline = 'OUTLINE'
    })
    f.level:SetParent(f.overlay)
    f.level:SetJustifyH('LEFT')
    f.level:SetJustifyV('BOTTOM')
    f.level:SetHeight(10)
    f.level:ClearAllPoints()

    f.level.enabled = true
end
function addon:UpdateLevel(f, trivial)
    if not f.level.enabled then
        f.level:Hide()
        f.level:SetWidth(.1)
        return
    end

    if trivial then
        f.level:Hide()
    else
        f.level:Show()
        f.level:SetPoint('TOPLEFT', f.health, 'BOTTOMLEFT',
                         2.5, self.db.profile.text.healthoffset + 4)
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

	-- silly hacky way of fixing horizontal jitter with center aligned texts
	local offset
	if trivial or not self.db.profile.general.leftie then
		local swidth = f.name:GetStringWidth()
		swidth = swidth - abs(swidth)
		offset = (swidth > .7 or swidth < .2) and .5 or 0
	end

    if trivial then
        f.name:SetPoint('BOTTOM', f.health, 'TOP', offset, -self.db.profile.text.healthoffset)
		f.name:SetWidth(addon.sizes.frame.twidth * 2)
		f.name:SetJustifyH('CENTER')
    else
        if self.db.profile.general.leftie then
            f.name:SetPoint('BOTTOMLEFT', f.health, 'TOPLEFT',
                            2.5, -self.db.profile.text.healthoffset)

            f.name:SetPoint('RIGHT', f.health.p, 'LEFT')
            f.name:SetJustifyH('LEFT')
        else
            -- move to top center
            f.name:SetPoint('BOTTOM', f.health, 'TOP',
                            offset, -self.db.profile.text.healthoffset)
			f.name:SetWidth(addon.sizes.frame.width * 2)
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
---------------------------------------------------------------- Target arrow --
function addon:CreateTargetArrows(f)
    local arrowSize = floor(self.sizes.tex.targetArrow)
    local ta = CreateFrame('Frame',nil,f.overlay)

    ta.left = ta:CreateTexture(nil,'ARTWORK')
    ta.left:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\target-arrow')
    ta.left:SetPoint('RIGHT',f.overlay,'LEFT',14,-1)
    ta.left:SetSize(arrowSize,arrowSize)

    ta.right = ta:CreateTexture(nil,'ARTWORK')
    ta.right:SetTexture('Interface\\AddOns\\Kui_Nameplates\\media\\target-arrow')
    ta.right:SetTexCoord(1,0,0,1)
    ta.right:SetPoint('LEFT',f.overlay,'RIGHT',-14,-1)
    ta.right:SetSize(arrowSize,arrowSize)

    ta.left:SetVertexColor(unpack(self.db.profile.general.targetglowcolour))
    ta.right:SetVertexColor(unpack(self.db.profile.general.targetglowcolour))

    ta:Hide()
    f.targetArrows = ta
end
