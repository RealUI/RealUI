local F, C = unpack(select(2, ...))

C.modules["Blizzard_TalentUI"] = function()
	local r, g, b = C.r, C.g, C.b

	PlayerTalentFrameTalents:DisableDrawLayer("BORDER")
	PlayerTalentFrameTalentsBg:Hide()
	PlayerTalentFrameActiveSpecTabHighlight:SetTexture("")
	PlayerTalentFrameTitleGlowLeft:SetTexture("")
	PlayerTalentFrameTitleGlowRight:SetTexture("")
	PlayerTalentFrameTitleGlowCenter:SetTexture("")

	for i = 1, 6 do
		select(i, PlayerTalentFrameSpecialization:GetRegions()):Hide()
	end

	select(7, PlayerTalentFrameSpecialization:GetChildren()):DisableDrawLayer("OVERLAY")

	for i = 1, 5 do
		select(i, PlayerTalentFrameSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
	end

	F.CreateBG(PlayerTalentFrameTalentsClearInfoFrame)
	PlayerTalentFrameTalentsClearInfoFrameIcon:SetTexCoord(.08, .92, .08, .92)

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetTexture(1, 1, 1)
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(.2)

	if select(2, UnitClass("player")) == "HUNTER" then
		for i = 1, 6 do
			select(i, PlayerTalentFramePetSpecialization:GetRegions()):Hide()
		end
		select(7, PlayerTalentFramePetSpecialization:GetChildren()):DisableDrawLayer("OVERLAY")
		for i = 1, 5 do
			select(i, PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild:GetRegions()):Hide()
		end

		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetTexture(1, 1, 1)
		PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.Seperator:SetAlpha(.2)

		for i = 1, GetNumSpecializations(false, true) do
			local _, _, _, icon = GetSpecializationInfo(i, false, true)
			PlayerTalentFramePetSpecialization["specButton"..i].specIcon:SetTexture(icon)
		end
	end

	for i = 1, NUM_TALENT_FRAME_TABS do
		local tab = _G["PlayerTalentFrameTab"..i]
		F.ReskinTab(tab)
	end

	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.ring:Hide()
	PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.specIcon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBG(PlayerTalentFrameSpecializationSpellScrollFrameScrollChild.specIcon)
	PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.ring:Hide()
	PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.specIcon:SetTexCoord(.08, .92, .08, .92)
	F.CreateBG(PlayerTalentFramePetSpecializationSpellScrollFrameScrollChild.specIcon)

	hooksecurefunc("PlayerTalentFrame_UpdateSpecFrame", function(self, spec)
		local playerTalentSpec = GetSpecialization(nil, self.isPet, PlayerSpecTab2:GetChecked() and 2 or 1)
		local shownSpec = spec or playerTalentSpec or 1

		local id, _, _, icon = GetSpecializationInfo(shownSpec, nil, self.isPet)
		local scrollChild = self.spellsScroll.child

		scrollChild.specIcon:SetTexture(icon)

		local index = 1
		local bonuses
		if self.isPet then
			bonuses = {GetSpecializationSpells(shownSpec, nil, self.isPet)}
		else
			bonuses = SPEC_SPELLS_DISPLAY[id]
		end
		for i = 1, #bonuses, 2 do
			local frame = scrollChild["abilityButton"..index]
			local _, icon = GetSpellTexture(bonuses[i])
			frame.icon:SetTexture(icon)
			frame.subText:SetTextColor(.75, .75, .75)
			if not frame.reskinned then
				frame.reskinned = true
				frame.ring:Hide()
				frame.icon:SetTexCoord(.08, .92, .08, .92)
				F.CreateBG(frame.icon)
			end
			index = index + 1
		end

		for i = 1, GetNumSpecializations(nil, self.isPet) do
			local bu = self["specButton"..i]
			if bu.selected then
				bu.glowTex:Show()
			else
				bu.glowTex:Hide()
			end
		end
	end)

	for i = 1, GetNumSpecializations(false, nil) do
		local _, _, _, icon = GetSpecializationInfo(i, false, nil)
		PlayerTalentFrameSpecialization["specButton"..i].specIcon:SetTexture(icon)
	end

	PlayerTalentFrameSpecializationLearnButton.Flash:SetTexture("")
	PlayerTalentFrameTalentsLearnButton.Flash:SetTexture("")

	local buttons = {"PlayerTalentFrameSpecializationSpecButton", "PlayerTalentFramePetSpecializationSpecButton"}

	for _, name in pairs(buttons) do
		for i = 1, 4 do
			local bu = _G[name..i]

			bu.bg:SetAlpha(0)
			bu.ring:Hide()
			bu.learnedTex:SetPoint("TOPLEFT", 1, -1)
			bu.learnedTex:SetPoint("BOTTOMRIGHT", -1, 1)
			_G[name..i.."Glow"]:SetTexture("")

			F.Reskin(bu, true)

			bu.selectedTex:SetTexture("")
			bu.learnedTex:SetTexture(C.media.backdrop)
			bu.learnedTex:SetVertexColor(r, g, b, .2)
			bu.learnedTex:SetDrawLayer("BACKGROUND")

			bu.specIcon:SetTexCoord(.08, .92, .08, .92)
			bu.specIcon:SetSize(58, 58)
			bu.specIcon:SetPoint("LEFT", bu, "LEFT")
			bu.specIcon:SetDrawLayer("OVERLAY")
			local bg = F.CreateBG(bu.specIcon)
			bg:SetDrawLayer("BORDER")

			bu.glowTex = CreateFrame("Frame", nil, bu)
			bu.glowTex:SetBackdrop({
				edgeFile = C.media.glow,
				edgeSize = 5,
			})
			bu.glowTex:SetPoint("TOPLEFT", -6, 5)
			bu.glowTex:SetPoint("BOTTOMRIGHT", 5, -5)
			bu.glowTex:SetBackdropBorderColor(r, g, b)
			bu.glowTex:SetFrameLevel(bu:GetFrameLevel()-1)
			bu.glowTex:Hide()
		end
	end

	for i = 1, MAX_NUM_TALENT_TIERS do
		local row = _G["PlayerTalentFrameTalentsTalentRow"..i]
		_G["PlayerTalentFrameTalentsTalentRow"..i.."Bg"]:Hide()
		row:DisableDrawLayer("BORDER")

		row.TopLine:SetDesaturated(true)
		row.TopLine:SetVertexColor(r, g, b)
		row.BottomLine:SetDesaturated(true)
		row.BottomLine:SetVertexColor(r, g, b)

		for j = 1, NUM_TALENT_COLUMNS do
			local bu = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j]
			local ic = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j.."IconTexture"]

			bu:SetHighlightTexture("")
			bu.Slot:SetAlpha(0)
			bu.knownSelection:SetAlpha(0)
			bu.learnSelection:SetAlpha(0)

			ic:SetDrawLayer("ARTWORK")
			ic:SetTexCoord(.08, .92, .08, .92)
			F.CreateBG(ic)

			bu.bg = CreateFrame("Frame", nil, bu)
			bu.bg:SetPoint("TOPLEFT", 10, 0)
			bu.bg:SetPoint("BOTTOMRIGHT")
			bu.bg:SetFrameLevel(bu:GetFrameLevel()-1)
			F.CreateBD(bu.bg, .25)
		end
	end

	hooksecurefunc("TalentFrame_Update", function()
		for i = 1, MAX_NUM_TALENT_TIERS do
			for j = 1, NUM_TALENT_COLUMNS do
				local bu = _G["PlayerTalentFrameTalentsTalentRow"..i.."Talent"..j]
				if bu.knownSelection:IsShown() then
					bu.bg:SetBackdropColor(r, g, b, .2)
				else
					bu.bg:SetBackdropColor(0, 0, 0, .25)
				end
				if bu.learnSelection:IsShown() then
					bu.bg:SetBackdropBorderColor(r, g, b)
				else
					bu.bg:SetBackdropBorderColor(0, 0, 0)
				end
			end
		end
	end)

	for i = 1, 2 do
		local tab = _G["PlayerSpecTab"..i]
		_G["PlayerSpecTab"..i.."Background"]:Hide()

		tab:SetCheckedTexture(C.media.checked)

		local bg = CreateFrame("Frame", nil, tab)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(tab:GetFrameLevel()-1)
		F.CreateBD(bg)

		F.CreateSD(tab, 5, 0, 0, 0, 1, 1)

		select(2, tab:GetRegions()):SetTexCoord(.08, .92, .08, .92)
	end

	hooksecurefunc("PlayerTalentFrame_UpdateSpecs", function()
		PlayerSpecTab1:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPRIGHT", 11, -36)
		PlayerSpecTab2:SetPoint("TOP", PlayerSpecTab1, "BOTTOM")
	end)

	PlayerTalentFrameTalentsTutorialButton.Ring:Hide()
	PlayerTalentFrameTalentsTutorialButton:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPLEFT", -12, 12)
	PlayerTalentFrameSpecializationTutorialButton.Ring:Hide()
	PlayerTalentFrameSpecializationTutorialButton:SetPoint("TOPLEFT", PlayerTalentFrame, "TOPLEFT", -12, 12)

	F.ReskinPortraitFrame(PlayerTalentFrame, true)
	F.Reskin(PlayerTalentFrameSpecializationLearnButton)
	F.Reskin(PlayerTalentFrameTalentsLearnButton)
	F.Reskin(PlayerTalentFrameActivateButton)
	F.Reskin(PlayerTalentFramePetSpecializationLearnButton)
end