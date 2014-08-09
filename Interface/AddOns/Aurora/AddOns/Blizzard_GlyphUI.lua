local F, C = unpack(select(2, ...))

C.themes["Blizzard_GlyphUI"] = function()
	local r, g, b = C.r, C.g, C.b

	GlyphFrameBackground:Hide()
	GlyphFrameSideInset:DisableDrawLayer("BACKGROUND")
	GlyphFrameSideInset:DisableDrawLayer("BORDER")
	GlyphFrame.specRing:SetTexture("")
	F.CreateBG(GlyphFrameClearInfoFrame)
	GlyphFrameClearInfoFrameIcon:SetTexCoord(.08, .92, .08, .92)

	for i = 1, 2 do
		_G["GlyphFrameHeader"..i.."Left"]:Hide()
		_G["GlyphFrameHeader"..i.."Middle"]:Hide()
		_G["GlyphFrameHeader"..i.."Right"]:Hide()

	end

	F.CreateBDFrame(GlyphFrame.specIcon, 0)
	GlyphFrame.specIcon:SetTexCoord(.08, .92, .08, .92)

	local function onUpdate(self)
		local id = self:GetID()
		if GlyphMatchesSocket(id) then
			self.bg:SetBackdropBorderColor(r, g, b)
		else
			self.bg:SetBackdropBorderColor(0, 0, 0)
		end
	end

	for i = 1, NUM_GLYPH_SLOTS do
		local glyph = _G["GlyphFrameGlyph"..i]

		glyph.ring:SetAlpha(0)
		glyph.glyph:SetTexCoord(.08, .92, .08, .92)
		glyph.highlight:SetTexture("")

		glyph.bg = F.CreateBDFrame(glyph.glyph, .25)

		glyph:HookScript("OnUpdate", onUpdate)
	end

	hooksecurefunc("GlyphFrame_Update", function(self)
		local spec = GetSpecialization(false, false, PlayerTalentFrame.talentGroup)
		if spec then
			local _, _, _, icon = GetSpecializationInfo(spec, false, self.isPet)
			GlyphFrame.specIcon:SetTexture(icon)
		end
	end)

	hooksecurefunc("GlyphFrameGlyph_UpdateSlot", function(self)
		local id = self:GetID();
		local talentGroup = PlayerTalentFrame and PlayerTalentFrame.talentGroup
		local enabled, glyphType, glyphTooltipIndex, glyphSpell, iconFilename = GetGlyphSocketInfo(id, talentGroup)

		if not glyphType then return end

		if enabled and glyphSpell and iconFilename then
			self.glyph:SetTexture(iconFilename)
		end
	end)

	for i = 1, #GlyphFrame.scrollFrame.buttons do
		local bu = _G["GlyphFrameScrollFrameButton"..i]
		local ic = _G["GlyphFrameScrollFrameButton"..i.."Icon"]

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", 38, -2)
		bg:SetPoint("BOTTOMRIGHT", 0, 2)
		bg:SetFrameLevel(bu:GetFrameLevel()-1)
		F.CreateBD(bg, .25)

		_G["GlyphFrameScrollFrameButton"..i.."Name"]:SetParent(bg)
		_G["GlyphFrameScrollFrameButton"..i.."TypeName"]:SetParent(bg)
		bu:SetHighlightTexture("")
		bu.disabledBG:SetTexture("")
		select(4, bu:GetRegions()):SetAlpha(0)

		local check = select(2, bu:GetRegions())
		check:SetPoint("TOPLEFT", 39, -3)
		check:SetPoint("BOTTOMRIGHT", -1, 3)
		check:SetTexture(C.media.backdrop)
		check:SetVertexColor(r, g, b, .2)

		F.CreateBG(ic)

		ic:SetTexCoord(.08, .92, .08, .92)
	end

	F.ReskinInput(GlyphFrameSearchBox)
	F.ReskinScroll(GlyphFrameScrollFrameScrollBar)
	F.ReskinDropDown(GlyphFrameFilterDropDown)
end