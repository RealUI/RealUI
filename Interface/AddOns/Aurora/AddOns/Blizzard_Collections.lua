local F, C = unpack(select(2, ...))

C.themes["Blizzard_Collections"] = function()
	local r, g, b = C.r, C.g, C.b

	-- [[ General ]]

	for i = 1, 14 do
		if i ~= 8 then
			select(i, CollectionsJournal:GetRegions()):Hide()
		end
	end

	F.CreateBD(CollectionsJournal)
	F.ReskinTab(CollectionsJournalTab1)
	F.ReskinTab(CollectionsJournalTab2)
	F.ReskinTab(CollectionsJournalTab3)
	F.ReskinTab(CollectionsJournalTab4)
	F.ReskinClose(CollectionsJournalCloseButton)

	CollectionsJournalTab2:SetPoint("LEFT", CollectionsJournalTab1, "RIGHT", -15, 0)
	CollectionsJournalTab3:SetPoint("LEFT", CollectionsJournalTab2, "RIGHT", -15, 0)
	CollectionsJournalTab4:SetPoint("LEFT", CollectionsJournalTab3, "RIGHT", -15, 0)

	-- [[ Mounts and pets ]]

	local PetJournal = PetJournal
	local MountJournal = MountJournal

	for i = 1, 9 do
		select(i, MountJournal.MountCount:GetRegions()):Hide()
		select(i, PetJournal.PetCount:GetRegions()):Hide()
	end

	MountJournal.LeftInset:Hide()
	MountJournal.RightInset:Hide()
	PetJournal.LeftInset:Hide()
	PetJournal.RightInset:Hide()
	PetJournal.PetCardInset:Hide()
	PetJournal.loadoutBorder:Hide()
	MountJournal.MountDisplay.YesMountsTex:SetAlpha(0)
	MountJournal.MountDisplay.NoMountsTex:SetAlpha(0)
	MountJournal.MountDisplay.ShadowOverlay:Hide()
	PetJournalTutorialButton.Ring:Hide()

	F.CreateBD(MountJournal.MountCount, .25)
	F.CreateBD(PetJournal.PetCount, .25)
	F.CreateBD(MountJournal.MountDisplay.ModelFrame, .25)

	F.Reskin(MountJournalMountButton)
	F.Reskin(PetJournalSummonButton)
	F.Reskin(PetJournalFindBattle)
	F.ReskinScroll(MountJournalListScrollFrameScrollBar)
	F.ReskinScroll(PetJournalListScrollFrameScrollBar)
	F.ReskinInput(MountJournalSearchBox)
	F.ReskinInput(PetJournalSearchBox)
	F.ReskinArrow(MountJournal.MountDisplay.ModelFrame.RotateLeftButton, "left")
	F.ReskinArrow(MountJournal.MountDisplay.ModelFrame.RotateRightButton, "right")
	F.ReskinFilterButton(PetJournalFilterButton)
	F.ReskinFilterButton(MountJournalFilterButton)

	MountJournalFilterButton:SetPoint("TOPRIGHT", MountJournal.LeftInset, -5, -8)
	PetJournalFilterButton:SetPoint("TOPRIGHT", PetJournalLeftInset, -5, -8)

	PetJournalTutorialButton:SetPoint("TOPLEFT", PetJournal, "TOPLEFT", -14, 14)

	local scrollFrames = {MountJournal.ListScrollFrame.buttons, PetJournal.listScroll.buttons}
	for _, scrollFrame in pairs(scrollFrames) do
		for i = 1, #scrollFrame do
			local bu = scrollFrame[i]
			local ic = bu.icon

			bu:GetRegions():Hide()
			bu:SetHighlightTexture("")
			bu.iconBorder:SetTexture("")
			bu.selectedTexture:SetTexture("")

			local bg = CreateFrame("Frame", nil, bu)
			bg:SetPoint("TOPLEFT", 0, -1)
			bg:SetPoint("BOTTOMRIGHT", 0, 1)
			bg:SetFrameLevel(bu:GetFrameLevel()-1)
			F.CreateBD(bg, .25)
			bu.bg = bg

			ic:SetTexCoord(.08, .92, .08, .92)
			ic.bg = F.CreateBG(ic)

			bu.name:SetParent(bg)

			if bu.DragButton then
				bu.DragButton.ActiveTexture:SetTexture(C.media.checked)
			else
				bu.dragButton.ActiveTexture:SetTexture(C.media.checked)
				bu.dragButton.levelBG:SetAlpha(0)
				bu.dragButton.level:SetFontObject(GameFontNormal)
				bu.dragButton.level:SetTextColor(1, 1, 1)
			end
		end
	end

	local function updateMountScroll()
		local buttons = MountJournal.ListScrollFrame.buttons
		for i = 1, #buttons do
			local bu = buttons[i]
			if bu.index ~= nil then
				bu.bg:Show()
				bu.icon:Show()
				bu.icon.bg:Show()

				if bu.selectedTexture:IsShown() then
					bu.bg:SetBackdropColor(r, g, b, .25)
				else
					bu.bg:SetBackdropColor(0, 0, 0, .25)
				end
			else
				bu.bg:Hide()
				bu.icon:Hide()
				bu.icon.bg:Hide()
			end
		end
	end

	hooksecurefunc("MountJournal_UpdateMountList", updateMountScroll)
	hooksecurefunc(MountJournalListScrollFrame, "update", updateMountScroll)

	local function updatePetScroll()
		local petButtons = PetJournal.listScroll.buttons
		if petButtons then
			for i = 1, #petButtons do
				local bu = petButtons[i]

				local index = bu.index
				if index then
					local petID, _, isOwned = C_PetJournal.GetPetInfoByIndex(index)

					if petID and isOwned then
						local _, _, _, _, rarity = C_PetJournal.GetPetStats(petID)

						if rarity then
							local color = ITEM_QUALITY_COLORS[rarity-1]
							bu.name:SetTextColor(color.r, color.g, color.b)
						else
							bu.name:SetTextColor(1, 1, 1)
						end
					else
						bu.name:SetTextColor(.5, .5, .5)
					end

					if bu.selectedTexture:IsShown() then
						bu.bg:SetBackdropColor(r, g, b, .25)
					else
						bu.bg:SetBackdropColor(0, 0, 0, .25)
					end
				end
			end
		end
	end

	hooksecurefunc("PetJournal_UpdatePetList", updatePetScroll)
	hooksecurefunc(PetJournalListScrollFrame, "update", updatePetScroll)

	PetJournalHealPetButtonBorder:Hide()
	PetJournalHealPetButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	PetJournal.HealPetButton:SetPushedTexture("")
	F.CreateBG(PetJournal.HealPetButton)

	do
		local ic = MountJournal.MountDisplay.InfoButton.Icon
		ic:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(ic)
	end

	if AuroraConfig.tooltips then
		for _, f in pairs({PetJournalPrimaryAbilityTooltip, PetJournalSecondaryAbilityTooltip}) do
			f:DisableDrawLayer("BACKGROUND")
			local bg = CreateFrame("Frame", nil, f)
			bg:SetAllPoints()
			bg:SetFrameLevel(0)
			F.CreateBD(bg)
		end
	end

	PetJournalLoadoutBorderSlotHeaderText:SetParent(PetJournal)
	PetJournalLoadoutBorderSlotHeaderText:SetPoint("CENTER", PetJournalLoadoutBorderTop, "TOP", 0, 4)

	-- Favourite mount button

	MountJournalSummonRandomFavoriteButtonBorder:Hide()
	MountJournalSummonRandomFavoriteButtonIconTexture:SetTexCoord(.08, .92, .08, .92)
	MountJournalSummonRandomFavoriteButton:SetPushedTexture("")
	F.CreateBG(MountJournalSummonRandomFavoriteButton)

	do
		local movedButton = false
		MountJournal:HookScript("OnShow", function()
			if not InCombatLockdown() then
				MountJournalSummonRandomFavoriteButton:SetPoint("TOPRIGHT", -7, -32)
				movedButton = true
			end
		end)
	end

	-- Pet card

	local card = PetJournalPetCard

	PetJournalPetCardBG:Hide()
	card.PetInfo.levelBG:SetAlpha(0)
	card.PetInfo.qualityBorder:SetAlpha(0)
	card.AbilitiesBG1:SetAlpha(0)
	card.AbilitiesBG2:SetAlpha(0)
	card.AbilitiesBG3:SetAlpha(0)

	card.PetInfo.level:SetFontObject(GameFontNormal)
	card.PetInfo.level:SetTextColor(1, 1, 1)

	card.PetInfo.icon:SetTexCoord(.08, .92, .08, .92)
	card.PetInfo.icon.bg = F.CreateBG(card.PetInfo.icon)

	F.CreateBD(card, .25)

	for i = 2, 12 do
		select(i, card.xpBar:GetRegions()):Hide()
	end

	card.xpBar:SetStatusBarTexture(C.media.backdrop)
	F.CreateBDFrame(card.xpBar, .25)

	PetJournalPetCardHealthFramehealthStatusBarLeft:Hide()
	PetJournalPetCardHealthFramehealthStatusBarRight:Hide()
	PetJournalPetCardHealthFramehealthStatusBarMiddle:Hide()
	PetJournalPetCardHealthFramehealthStatusBarBGMiddle:Hide()

	card.HealthFrame.healthBar:SetStatusBarTexture(C.media.backdrop)
	F.CreateBDFrame(card.HealthFrame.healthBar, .25)

	for i = 1, 6 do
		local bu = card["spell"..i]

		bu.icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(bu.icon)
	end

	hooksecurefunc("PetJournal_UpdatePetCard", function(self)
		local border = self.PetInfo.qualityBorder
		local r, g, b

		if border:IsShown() then
			r, g, b = self.PetInfo.qualityBorder:GetVertexColor()
		else
			r, g, b = 0, 0, 0
		end

		self.PetInfo.icon.bg:SetVertexColor(r, g, b)
	end)

	-- Pet loadout

	for i = 1, 3 do
		local bu = PetJournal.Loadout["Pet"..i]

		_G["PetJournalLoadoutPet"..i.."BG"]:Hide()

		bu.iconBorder:SetAlpha(0)
		bu.qualityBorder:SetTexture("")
		bu.levelBG:SetAlpha(0)
		bu.helpFrame:GetRegions():Hide()

		bu.level:SetFontObject(GameFontNormal)
		bu.level:SetTextColor(1, 1, 1)

		bu.icon:SetTexCoord(.08, .92, .08, .92)
		bu.icon.bg = F.CreateBDFrame(bu.icon, .25)

		bu.setButton:GetRegions():SetPoint("TOPLEFT", bu.icon, -5, 5)
		bu.setButton:GetRegions():SetPoint("BOTTOMRIGHT", bu.icon, 5, -5)

		F.CreateBD(bu, .25)

		for i = 2, 12 do
			select(i, bu.xpBar:GetRegions()):Hide()
		end

		bu.xpBar:SetStatusBarTexture(C.media.backdrop)
		F.CreateBDFrame(bu.xpBar, .25)

		_G["PetJournalLoadoutPet"..i.."HealthFramehealthStatusBarLeft"]:Hide()
		_G["PetJournalLoadoutPet"..i.."HealthFramehealthStatusBarRight"]:Hide()
		_G["PetJournalLoadoutPet"..i.."HealthFramehealthStatusBarMiddle"]:Hide()
		_G["PetJournalLoadoutPet"..i.."HealthFramehealthStatusBarBGMiddle"]:Hide()

		bu.healthFrame.healthBar:SetStatusBarTexture(C.media.backdrop)
		F.CreateBDFrame(bu.healthFrame.healthBar, .25)

		for j = 1, 3 do
			local spell = bu["spell"..j]

			spell:SetPushedTexture("")

			spell.selected:SetTexture(C.media.checked)

			spell:GetRegions():Hide()

			spell.FlyoutArrow:SetTexture(C.media.arrowDown)
			spell.FlyoutArrow:SetSize(8, 8)
			spell.FlyoutArrow:SetTexCoord(0, 1, 0, 1)

			spell.icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBG(spell.icon)
		end
	end

	hooksecurefunc("PetJournal_UpdatePetLoadOut", function()
		for i = 1, 3 do
			local bu = PetJournal.Loadout["Pet"..i]

			bu.icon.bg:SetShown(not bu.helpFrame:IsShown())
			bu.icon.bg:SetBackdropBorderColor(bu.qualityBorder:GetVertexColor())

			bu.dragButton:SetEnabled(not bu.helpFrame:IsShown())
		end
	end)

	PetJournal.SpellSelect.BgEnd:Hide()
	PetJournal.SpellSelect.BgTiled:Hide()

	for i = 1, 2 do
		local bu = PetJournal.SpellSelect["Spell"..i]

		bu:SetCheckedTexture(C.media.checked)
		bu:SetPushedTexture("")

		bu.icon:SetDrawLayer("ARTWORK")
		bu.icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(bu.icon)
	end

	-- [[ Toy box ]]

	local ToyBox = ToyBox

	local icons = ToyBox.iconsFrame
	icons.Bg:Hide()
	icons.BackgroundTile:Hide()
	icons:DisableDrawLayer("BORDER")
	icons:DisableDrawLayer("ARTWORK")
	icons:DisableDrawLayer("OVERLAY")

	F.ReskinInput(ToyBox.searchBox)
	F.ReskinFilterButton(ToyBoxFilterButton)
	F.ReskinArrow(ToyBox.navigationFrame.prevPageButton, "left")
	F.ReskinArrow(ToyBox.navigationFrame.nextPageButton, "right")

	ToyBox.navigationFrame.prevPageButton:SetPoint("BOTTOMRIGHT", -320, 51)
	ToyBox.navigationFrame.nextPageButton:SetPoint("BOTTOMRIGHT", -285, 51)

	-- Progress bar

	local progressBar = ToyBox.progressBar
	progressBar.border:Hide()
	progressBar:DisableDrawLayer("BACKGROUND")

	progressBar.text:SetPoint("CENTER", 0, 1)
	progressBar:SetStatusBarTexture(C.media.backdrop)

	F.CreateBDFrame(progressBar, .25)

	-- Toys!

	local shouldChangeTextColor = true

	local changeTextColor = function(toyString)
		if shouldChangeTextColor then
			shouldChangeTextColor = false

			local self = toyString:GetParent()

			if PlayerHasToy(self.itemID) then
				local _, _, quality = GetItemInfo(self.itemID)
				if quality then
					toyString:SetTextColor(GetItemQualityColor(quality))
				else
					toyString:SetTextColor(1, 1, 1)
				end
			else
				toyString:SetTextColor(.5, .5, .5)
			end

			shouldChangeTextColor = true
		end
	end

	local buttons = ToyBox.iconsFrame
	for i = 1, 18 do
		local bu = buttons["spellButton"..i]
		local ic = bu.iconTexture

		bu:SetPushedTexture("")
		bu:SetHighlightTexture("")

		bu.cooldown:SetAllPoints(ic)

		bu.slotFrameCollected:SetTexture("")
		bu.slotFrameUncollected:SetTexture("")

		ic:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(ic)

		hooksecurefunc(bu.name, "SetTextColor", changeTextColor)
	end

	-- [[ Heirlooms ]]

	local HeirloomsJournal = HeirloomsJournal

	local icons = HeirloomsJournal.iconsFrame
	icons.Bg:Hide()
	icons.BackgroundTile:Hide()
	icons:DisableDrawLayer("BORDER")
	icons:DisableDrawLayer("ARTWORK")
	icons:DisableDrawLayer("OVERLAY")

	F.ReskinInput(HeirloomsJournalSearchBox)
	F.ReskinDropDown(HeirloomsJournalClassDropDown)
	F.ReskinFilterButton(HeirloomsJournalFilterButton)
	F.ReskinArrow(HeirloomsJournal.navigationFrame.prevPageButton, "left")
	F.ReskinArrow(HeirloomsJournal.navigationFrame.nextPageButton, "right")

	HeirloomsJournal.navigationFrame.prevPageButton:SetPoint("BOTTOMRIGHT", -320, 51)
	HeirloomsJournal.navigationFrame.nextPageButton:SetPoint("BOTTOMRIGHT", -285, 51)

	-- Progress bar

	local progressBar = HeirloomsJournal.progressBar
	progressBar.border:Hide()
	progressBar:DisableDrawLayer("BACKGROUND")

	progressBar.text:SetPoint("CENTER", 0, 1)
	progressBar:SetStatusBarTexture(C.media.backdrop)

	F.CreateBDFrame(progressBar, .25)

	-- Buttons

	hooksecurefunc("HeirloomsJournal_UpdateButton", function(button)
		if not button.styled then
			local ic = button.iconTexture

			button.slotFrameCollected:SetTexture("")
			button.slotFrameUncollected:SetTexture("")
			button.levelBackground:SetAlpha(0)

			button.iconTextureUncollected:SetTexCoord(.08, .92, .08, .92)
			button.bg = F.ReskinIcon(ic)

			button.level:ClearAllPoints()
			button.level:SetPoint("BOTTOM", 0, 1)

			local newLevelBg = button:CreateTexture(nil, "OVERLAY")
			if C.isBetaClient then
				newLevelBg:SetColorTexture(0, 0, 0, .5)
			else
				newLevelBg:SetTexture(0, 0, 0, .5)
			end
			newLevelBg:SetPoint("BOTTOMLEFT", button, "BOTTOMLEFT", 4, 5)
			newLevelBg:SetPoint("BOTTOMRIGHT", button, "BOTTOMRIGHT", -4, 5)
			newLevelBg:SetHeight(11)
			button.newLevelBg = newLevelBg

			button.styled = true
		end

		if button.iconTexture:IsShown() then
			button.name:SetTextColor(1, 1, 1)
			button.bg:SetVertexColor(.9, .8, .5)
			button.newLevelBg:Show()
		else
			button.name:SetTextColor(.5, .5, .5)
			button.bg:SetVertexColor(0, 0, 0)
			button.newLevelBg:Hide()
		end
	end)

	hooksecurefunc(HeirloomsJournal, "LayoutCurrentPage", function()
		for i = 1, #HeirloomsJournal.heirloomHeaderFrames do
			local header = HeirloomsJournal.heirloomHeaderFrames[i]
			if not header.styled then
				header.text:SetTextColor(1, 1, 1)
				header.text:SetFont(C.media.font, 16)

				header.styled = true
			end
		end

		for i = 1, #HeirloomsJournal.heirloomEntryFrames do
			local button = HeirloomsJournal.heirloomEntryFrames[i]

			if button.iconTexture:IsShown() then
				button.name:SetTextColor(1, 1, 1)
				button.bg:SetVertexColor(.9, .8, .5)
				button.newLevelBg:Show()
			else
				button.name:SetTextColor(.5, .5, .5)
				button.bg:SetVertexColor(0, 0, 0)
				button.newLevelBg:Hide()
			end
		end
	end)
end
