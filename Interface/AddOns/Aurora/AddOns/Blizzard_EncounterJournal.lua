local F, C = unpack(select(2, ...))

C.themes["Blizzard_EncounterJournal"] = function()
	local r, g, b = C.r, C.g, C.b

	EncounterJournalEncounterFrameInfo:DisableDrawLayer("BACKGROUND")
	EncounterJournal:DisableDrawLayer("BORDER")
	EncounterJournalInset:DisableDrawLayer("BORDER")
	EncounterJournal:DisableDrawLayer("OVERLAY")
	EncounterJournalInstanceSelectDungeonTab:DisableDrawLayer("OVERLAY")
	EncounterJournalInstanceSelectRaidTab:DisableDrawLayer("OVERLAY")

	EncounterJournalPortrait:Hide()
	EncounterJournalInstanceSelectBG:Hide()
	EncounterJournalBg:Hide()
	EncounterJournalTitleBg:Hide()
	EncounterJournalInsetBg:Hide()
	EncounterJournalInstanceSelectDungeonTabMid:Hide()
	EncounterJournalInstanceSelectDungeonTabLeft:Hide()
	EncounterJournalInstanceSelectDungeonTabRight:Hide()
	EncounterJournalInstanceSelectRaidTabMid:Hide()
	EncounterJournalInstanceSelectRaidTabLeft:Hide()
	EncounterJournalInstanceSelectRaidTabRight:Hide()
	for i = 8, 10 do
		select(i, EncounterJournalInstanceSelectDungeonTab:GetRegions()):SetAlpha(0)
		select(i, EncounterJournalInstanceSelectRaidTab:GetRegions()):SetAlpha(0)
	end
	EncounterJournalEncounterFrameInfoModelFrameShadow:Hide()
	EncounterJournalEncounterFrameInfoModelFrame.dungeonBG:Hide()
	EncounterJournalEncounterFrameInfoDifficultyUpLeft:SetAlpha(0)
	EncounterJournalEncounterFrameInfoDifficultyUpRIGHT:SetAlpha(0)
	EncounterJournalEncounterFrameInfoDifficultyDownLeft:SetAlpha(0)
	EncounterJournalEncounterFrameInfoDifficultyDownRIGHT:SetAlpha(0)
	select(5, EncounterJournalEncounterFrameInfoDifficulty:GetRegions()):Hide()
	select(6, EncounterJournalEncounterFrameInfoDifficulty:GetRegions()):Hide()
	EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggleUpLeft:SetAlpha(0)
	EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggleUpRIGHT:SetAlpha(0)
	EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggleDownLeft:SetAlpha(0)
	EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggleDownRIGHT:SetAlpha(0)
	select(5, EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:GetRegions()):Hide()
	select(6, EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle:GetRegions()):Hide()

	F.SetBD(EncounterJournal)

	-- [[ Tabs ]]

	EncounterJournalEncounterFrameInfoOverviewTab:ClearAllPoints()
	EncounterJournalEncounterFrameInfoOverviewTab:SetPoint("TOPLEFT", EncounterJournalEncounterFrameInfo, "TOPRIGHT", 9, -35)
	EncounterJournalEncounterFrameInfoLootTab:ClearAllPoints()
	EncounterJournalEncounterFrameInfoLootTab:SetPoint("TOP", EncounterJournalEncounterFrameInfoOverviewTab, "BOTTOM", 0, 1)
	EncounterJournalEncounterFrameInfoBossTab:ClearAllPoints()
	EncounterJournalEncounterFrameInfoBossTab:SetPoint("TOP", EncounterJournalEncounterFrameInfoLootTab, "BOTTOM", 0, 1)

	local tabs = {EncounterJournalEncounterFrameInfoOverviewTab, EncounterJournalEncounterFrameInfoLootTab, EncounterJournalEncounterFrameInfoBossTab, EncounterJournalEncounterFrameInfoModelTab}
	for _, tab in pairs(tabs) do
		tab:SetScale(.75)

		tab:SetBackdrop({
			bgFile = C.media.backdrop,
			edgeFile = C.media.backdrop,
			edgeSize = 1 / .75,
		})

		tab:SetBackdropColor(0, 0, 0, .5)
		tab:SetBackdropBorderColor(0, 0, 0)

		tab:SetNormalTexture("")
		tab:SetPushedTexture("")
		tab:SetDisabledTexture("")
		tab:SetHighlightTexture("")
	end

	-- [[ Instance select ]]

	local index = 1

	local function listInstances()
		while true do
			local bu = EncounterJournal.instanceSelect.scroll.child["instance"..index]
			if not bu then return end

			bu:SetNormalTexture("")
			bu:SetHighlightTexture("")
			bu:SetPushedTexture("")

			bu.bgImage:SetDrawLayer("BACKGROUND", 1)

			local bg = F.CreateBG(bu.bgImage)
			bg:SetPoint("TOPLEFT", 3, -3)
			bg:SetPoint("BOTTOMRIGHT", -4, 2)

			index = index + 1
		end
	end

	hooksecurefunc("EncounterJournal_ListInstances", listInstances)
	listInstances()

	-- [[ Encounter frame ]]

	EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildHeader:Hide()
	EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetFontObject("GameFontNormalLarge")

	EncounterJournalEncounterFrameInfoEncounterTitle:SetTextColor(1, 1, 1)
	EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollChildLore:SetTextColor(1, 1, 1)
	EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollChildDescription:SetTextColor(1, 1, 1)
	EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildLoreDescription:SetTextColor(1, 1, 1)
	EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChildTitle:SetTextColor(1, 1, 1)
	EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollChild.overviewDescription.Text:SetTextColor(1, 1, 1)

	F.CreateBDFrame(EncounterJournalEncounterFrameInfoModelFrame, .25)

	hooksecurefunc("EncounterJournal_DisplayInstance", function()
		local bossIndex = 1;
		local name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex)
		while bossID do
			local bossButton = _G["EncounterJournalBossButton"..bossIndex]

			if not bossButton.reskinned then
				bossButton.reskinned = true

				F.Reskin(bossButton, true)
				bossButton.text:SetTextColor(1, 1, 1)
				bossButton.text.SetTextColor = F.dummy
			end

			bossIndex = bossIndex + 1
			name, description, bossID, _, link = EJ_GetEncounterInfoByIndex(bossIndex)
		end

		-- move last tab
		local _, point = EncounterJournalEncounterFrameInfoModelTab:GetPoint()
		EncounterJournalEncounterFrameInfoModelTab:SetPoint("TOP", point, "BOTTOM", 0, 1)
	end)

	hooksecurefunc("EncounterJournal_ToggleHeaders", function(self)
		local index = 1
		local header = _G["EncounterJournalInfoHeader"..index]
		while header do
			if not header.styled then
				header.flashAnim.Play = F.dummy

				header.descriptionBG:SetAlpha(0)
				header.descriptionBGBottom:SetAlpha(0)
				for i = 4, 18 do
					select(i, header.button:GetRegions()):SetTexture("")
				end

				header.description:SetTextColor(1, 1, 1)
				header.button.title:SetTextColor(1, 1, 1)
				header.button.title.SetTextColor = F.dummy
				header.button.expandedIcon:SetTextColor(1, 1, 1)
				header.button.expandedIcon.SetTextColor = F.dummy

				F.Reskin(header.button)

				-- workaround because blizz uses 'tex' as key and I use it in API
				if header.expanded then
					header.button.tex = header.button.textures.expanded
				else
					header.button.tex = header.button.textures.collapsed
				end

				header.button.abilityIcon:SetTexCoord(.08, .92, .08, .92)
				header.button.bg = F.CreateBG(header.button.abilityIcon)

				header.styled = true
			end

			if header.button.abilityIcon:IsShown() then
				header.button.bg:Show()
			else
				header.button.bg:Hide()
			end

			index = index + 1
			header = _G["EncounterJournalInfoHeader"..index]
		end
	end)

	hooksecurefunc("EncounterJournal_SetUpOverview", function(self, role, index)
		local header = self.overviews[index]
		if not header.styled then
			header.flashAnim.Play = F.dummy

			header.descriptionBG:SetAlpha(0)
			header.descriptionBGBottom:SetAlpha(0)
			for i = 4, 18 do
				select(i, header.button:GetRegions()):SetTexture("")
			end

			header.button.title:SetTextColor(1, 1, 1)
			header.button.title.SetTextColor = F.dummy
			header.button.expandedIcon:SetTextColor(1, 1, 1)
			header.button.expandedIcon.SetTextColor = F.dummy

			F.Reskin(header.button)

			header.styled = true
		end
	end)

	hooksecurefunc("EncounterJournal_SetBullets", function(object, description)
		local parent = object:GetParent()

		if parent.Bullets then
			for _, bullet in pairs(parent.Bullets) do
				if not bullet.styled then
					bullet.Text:SetTextColor(1, 1, 1)
					bullet.styled = true
				end
			end
		end
	end)

	local items = EncounterJournal.encounter.info.lootScroll.buttons

	for i = 1, #items do
		local item = items[i]

		item.boss:SetTextColor(1, 1, 1)
		item.slot:SetTextColor(1, 1, 1)
		item.armorType:SetTextColor(1, 1, 1)

		item.bossTexture:SetAlpha(0)
		item.bosslessTexture:SetAlpha(0)

		item.icon:SetPoint("TOPLEFT", 1, -1)
		item.icon:SetTexCoord(.08, .92, .08, .92)
		item.icon:SetDrawLayer("OVERLAY")
		F.CreateBG(item.icon)

		local bg = CreateFrame("Frame", nil, item)
		bg:SetPoint("TOPLEFT")
		bg:SetPoint("BOTTOMRIGHT", 0, 1)
		bg:SetFrameStrata("BACKGROUND")
		F.CreateBD(bg, 0)

		local tex = item:CreateTexture(nil, "BACKGROUND")
		tex:SetPoint("TOPLEFT")
		tex:SetPoint("BOTTOMRIGHT", -1, 2)
		tex:SetTexture(C.media.backdrop)
		tex:SetVertexColor(0, 0, 0, .25)
	end

	-- [[ Search results ]]

	EncounterJournalSearchResultsBg:Hide()
	for i = 3, 11 do
		select(i, EncounterJournalSearchResults:GetRegions()):Hide()
	end

	F.CreateBD(EncounterJournalSearchResults)
	EncounterJournalSearchResults:SetBackdropColor(.15, .15, .15, .9)

	EncounterJournalSearchBoxSearchButton1BotLeftCorner:Hide()
	EncounterJournalSearchBoxSearchButton1BotRightCorner:Hide()
	EncounterJournalSearchBoxSearchButton1BottomBorder:Hide()
	EncounterJournalSearchBoxSearchButton1LeftBorder:Hide()
	EncounterJournalSearchBoxSearchButton1RightBorder:Hide()

	local function resultOnEnter(self)
		self.hl:Show()
	end

	local function resultOnLeave(self)
		self.hl:Hide()
	end

	local function styleSearchButton(result, index)
		if index == 1 then
			result:SetPoint("TOPLEFT", EncounterJournalSearchBox, "BOTTOMLEFT", 0, 1)
			result:SetPoint("TOPRIGHT", EncounterJournalSearchBox, "BOTTOMRIGHT", -5, 1)
		else
			result:SetPoint("TOPLEFT", EncounterJournalSearchBox["sbutton"..index-1], "BOTTOMLEFT", 0, 1)
			result:SetPoint("TOPRIGHT", EncounterJournalSearchBox["sbutton"..index-1], "BOTTOMRIGHT", 0, 1)
		end

		result:SetNormalTexture("")
		result:SetPushedTexture("")
		result:SetHighlightTexture("")

		local hl = result:CreateTexture(nil, "BACKGROUND")
		hl:SetAllPoints()
		hl:SetTexture(C.media.backdrop)
		hl:SetVertexColor(r, g, b, .2)
		hl:Hide()
		result.hl = hl

		F.CreateBD(result)
		result:SetBackdropColor(.1, .1, .1, .9)

		if result.icon then
			result:GetRegions():Hide() -- icon frame

			result.icon:SetTexCoord(.08, .92, .08, .92)

			local bg = F.CreateBG(result.icon)
			bg:SetDrawLayer("BACKGROUND", 1)
		end

		result:HookScript("OnEnter", resultOnEnter)
		result:HookScript("OnLeave", resultOnLeave)
	end

	for i = 1, 5 do
		styleSearchButton(EncounterJournalSearchBox["sbutton"..i], i)
	end

	styleSearchButton(EncounterJournalSearchBox.showAllResults, 6)

	hooksecurefunc("EncounterJournal_SearchUpdate", function()
		local scrollFrame = EncounterJournal.searchResults.scrollFrame
		local offset = HybridScrollFrame_GetOffset(scrollFrame)
		local results = scrollFrame.buttons
		local result, index

		local numResults = EJ_GetNumSearchResults()

		for i = 1, #results do
			result = results[i]
			index = offset + i

			if index <= numResults then
				if not result.styled then
					result:SetNormalTexture("")
					result:SetPushedTexture("")
					result:GetRegions():Hide()

					result.resultType:SetTextColor(1, 1, 1)
					result.path:SetTextColor(1, 1, 1)

					F.CreateBG(result.icon)

					result.styled = true
				end

				if result.icon:GetTexCoord() == 0 then
					result.icon:SetTexCoord(.08, .92, .08, .92)
				end
			end
		end
	end)

	hooksecurefunc(EncounterJournal.searchResults.scrollFrame, "update", function(self)
		for i = 1, #self.buttons do
			local result = self.buttons[i]

			if result.icon:GetTexCoord() == 0 then
				result.icon:SetTexCoord(.08, .92, .08, .92)
			end
		end
	end)

	F.ReskinClose(EncounterJournalSearchResultsCloseButton)
	F.ReskinScroll(EncounterJournalSearchResultsScrollFrameScrollBar)

	-- [[ Various controls ]]

	F.Reskin(EncounterJournalInstanceSelectDungeonTab)
	F.Reskin(EncounterJournalInstanceSelectRaidTab)
	F.Reskin(EncounterJournalEncounterFrameInfoDifficulty)
	F.Reskin(EncounterJournalEncounterFrameInfoResetButton)
	F.Reskin(EncounterJournalEncounterFrameInfoLootScrollFrameFilterToggle)
	F.ReskinArrow(EncounterJournalInstanceSelectScrollDownButton, "down")
	F.ReskinClose(EncounterJournalCloseButton)
	F.ReskinInput(EncounterJournalSearchBox)
	F.ReskinScroll(EncounterJournalInstanceSelectScrollFrameScrollBar)
	F.ReskinScroll(EncounterJournalEncounterFrameInstanceFrameLoreScrollFrameScrollBar)
	F.ReskinScroll(EncounterJournalEncounterFrameInfoOverviewScrollFrameScrollBar)
	F.ReskinScroll(EncounterJournalEncounterFrameInfoBossesScrollFrameScrollBar)
	F.ReskinScroll(EncounterJournalEncounterFrameInfoDetailsScrollFrameScrollBar)
	F.ReskinScroll(EncounterJournalEncounterFrameInfoLootScrollFrameScrollBar)
end