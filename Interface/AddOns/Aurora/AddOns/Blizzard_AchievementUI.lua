local F, C = unpack(select(2, ...))

C.themes["Blizzard_AchievementUI"] = function()
	local r, g, b = C.r, C.g, C.b

	F.CreateBD(AchievementFrame)
	AchievementFrameCategories:SetBackdrop(nil)
	AchievementFrameSummary:SetBackdrop(nil)
	for i = 1, 17 do
		select(i, AchievementFrame:GetRegions()):Hide()
	end
	AchievementFrameSummaryBackground:Hide()
	AchievementFrameSummary:GetChildren():Hide()
	AchievementFrameCategoriesContainerScrollBarBG:SetAlpha(0)
	for i = 1, 4 do
		select(i, AchievementFrameHeader:GetRegions()):Hide()
	end
	if C.isBetaClient then
		AchievementFrameHeaderLeftDDLInset:SetAlpha(0)
	end
	AchievementFrameHeaderRightDDLInset:SetAlpha(0)
	select(2, AchievementFrameAchievements:GetChildren()):Hide()
	AchievementFrameAchievementsBackground:Hide()
	select(3, AchievementFrameAchievements:GetRegions()):Hide()
	AchievementFrameStatsBG:Hide()
	AchievementFrameSummaryAchievementsHeaderHeader:Hide()
	AchievementFrameSummaryCategoriesHeaderTexture:Hide()
	select(3, AchievementFrameStats:GetChildren()):Hide()
	select(5, AchievementFrameComparison:GetChildren()):Hide()
	AchievementFrameComparisonHeaderBG:Hide()
	AchievementFrameComparisonHeaderPortrait:Hide()
	AchievementFrameComparisonHeaderPortraitBg:Hide()
	AchievementFrameComparisonBackground:Hide()
	AchievementFrameComparisonDark:SetAlpha(0)
	AchievementFrameComparisonSummaryPlayerBackground:Hide()
	AchievementFrameComparisonSummaryFriendBackground:Hide()

	do
		local first = true
		hooksecurefunc("AchievementFrameCategories_Update", function()
			if first then
				for i = 1, 19 do
					local bu = _G["AchievementFrameCategoriesContainerButton"..i]

					bu.background:Hide()

					local bg = F.CreateBDFrame(bu, .25)
					bg:SetPoint("TOPLEFT", 0, -1)
					bg:SetPoint("BOTTOMRIGHT")

					bu:SetHighlightTexture(C.media.backdrop)
					local hl = bu:GetHighlightTexture()
					hl:SetVertexColor(r, g, b, .2)
					hl:SetPoint("TOPLEFT", 1, -2)
					hl:SetPoint("BOTTOMRIGHT", -1, 1)
				end
				first = false
			end
		end)
	end

	AchievementFrameHeaderPoints:SetPoint("TOP", AchievementFrame, "TOP", 0, -6)
	if C.isBetaClient then
		AchievementFrameFilterDropDown:SetPoint("TOPLEFT", 148, 1)
		AchievementFrameFilterDropDown:SetPoint("TOPLEFT", 148, 1)
		AchievementFrame.searchBox:ClearAllPoints()
		AchievementFrame.searchBox:SetPoint("TOPRIGHT", -98, -3)
		F.ReskinInput(AchievementFrame.searchBox, 20)

		local function SkinSearchPreview(btn)
			btn:SetNormalTexture(C.media.backdrop)
			btn:GetNormalTexture():SetVertexColor(0.1, 0.1, 0.1, .9)
			btn:SetPushedTexture(C.media.backdrop)
			btn:GetPushedTexture():SetVertexColor(0.1, 0.1, 0.1, .9)
		end
		for i = 1, 5 do
			local btn = AchievementFrame["searchPreview"..i]
			SkinSearchPreview(btn)
			btn.iconFrame:SetAlpha(0)
			F.ReskinIcon(btn.icon)
		end
		SkinSearchPreview(AchievementFrame.showAllSearchResults)

		local prevContainer = AchievementFrame.searchPreviewContainer
		prevContainer:DisableDrawLayer("OVERLAY")
		local bg = _G.CreateFrame("Frame", nil, prevContainer)
		bg:SetPoint("TOPRIGHT", 1, 1)
		bg:SetPoint("BOTTOMLEFT", prevContainer.borderAnchor, 6, 4)
		bg:SetFrameLevel(prevContainer:GetFrameLevel() - 1)
		F.CreateBD(bg)
	else
		AchievementFrameFilterDropDown:SetPoint("TOPRIGHT", -98, 1)
	end
	AchievementFrameFilterDropDownText:ClearAllPoints()
	AchievementFrameFilterDropDownText:SetPoint("CENTER", -10, 1)
	F.ReskinDropDown(AchievementFrameFilterDropDown)

	AchievementFrameSummaryCategoriesStatusBar:SetStatusBarTexture(C.media.backdrop)
	AchievementFrameSummaryCategoriesStatusBar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
	AchievementFrameSummaryCategoriesStatusBarLeft:Hide()
	AchievementFrameSummaryCategoriesStatusBarMiddle:Hide()
	AchievementFrameSummaryCategoriesStatusBarRight:Hide()
	AchievementFrameSummaryCategoriesStatusBarFillBar:Hide()
	AchievementFrameSummaryCategoriesStatusBarTitle:SetTextColor(1, 1, 1)
	AchievementFrameSummaryCategoriesStatusBarTitle:SetPoint("LEFT", AchievementFrameSummaryCategoriesStatusBar, "LEFT", 6, 0)
	AchievementFrameSummaryCategoriesStatusBarText:SetPoint("RIGHT", AchievementFrameSummaryCategoriesStatusBar, "RIGHT", -5, 0)

	local bg = CreateFrame("Frame", nil, AchievementFrameSummaryCategoriesStatusBar)
	bg:SetPoint("TOPLEFT", -1, 1)
	bg:SetPoint("BOTTOMRIGHT", 1, -1)
	bg:SetFrameLevel(AchievementFrameSummaryCategoriesStatusBar:GetFrameLevel()-1)
	F.CreateBD(bg, .25)

	for i = 1, 3 do
		local tab = _G["AchievementFrameTab"..i]
		if tab then
			F.ReskinTab(tab)
		end
	end

	for i = 1, 7 do
		local bu = _G["AchievementFrameAchievementsContainerButton"..i]
		bu:DisableDrawLayer("BORDER")
		bu.background:Hide()

		_G["AchievementFrameAchievementsContainerButton"..i.."TitleBackground"]:Hide()
		_G["AchievementFrameAchievementsContainerButton"..i.."Glow"]:Hide()
		_G["AchievementFrameAchievementsContainerButton"..i.."RewardBackground"]:SetAlpha(0)
		_G["AchievementFrameAchievementsContainerButton"..i.."PlusMinus"]:SetAlpha(0)
		_G["AchievementFrameAchievementsContainerButton"..i.."Highlight"]:SetAlpha(0)
		_G["AchievementFrameAchievementsContainerButton"..i.."IconOverlay"]:Hide()
		_G["AchievementFrameAchievementsContainerButton"..i.."GuildCornerL"]:SetAlpha(0)
		_G["AchievementFrameAchievementsContainerButton"..i.."GuildCornerR"]:SetAlpha(0)

		bu.description:SetTextColor(.9, .9, .9)
		bu.description.SetTextColor = F.dummy
		bu.description:SetShadowOffset(1, -1)
		bu.description.SetShadowOffset = F.dummy

		local bg = F.CreateBDFrame(bu, .25)
		bg:SetPoint("TOPLEFT", 1, -1)
		bg:SetPoint("BOTTOMRIGHT", 0, 2)

		bu.icon.texture:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(bu.icon.texture)

		-- can't get a backdrop frame to appear behind the checked texture for some reason

		local ch = bu.tracked

		ch:SetNormalTexture("")
		ch:SetPushedTexture("")
		ch:SetHighlightTexture(C.media.backdrop)

		local hl = ch:GetHighlightTexture()
		hl:SetPoint("TOPLEFT", 4, -4)
		hl:SetPoint("BOTTOMRIGHT", -4, 4)
		hl:SetVertexColor(r, g, b, .2)

		local check = ch:GetCheckedTexture()
		check:SetDesaturated(true)
		check:SetVertexColor(r, g, b)

		local tex = F.CreateGradient(ch)
		tex:SetPoint("TOPLEFT", 4, -4)
		tex:SetPoint("BOTTOMRIGHT", -4, 4)

		local left = ch:CreateTexture(nil, "BACKGROUND")
		left:SetWidth(1)
		if C.isBetaClient then
			left:SetColorTexture(0, 0, 0)
		else
			left:SetTexture(0, 0, 0)
		end
		left:SetPoint("TOPLEFT", tex, -1, 1)
		left:SetPoint("BOTTOMLEFT", tex, -1, -1)

		local right = ch:CreateTexture(nil, "BACKGROUND")
		right:SetWidth(1)
		if C.isBetaClient then
			right:SetColorTexture(0, 0, 0)
		else
			right:SetTexture(0, 0, 0)
		end
		right:SetPoint("TOPRIGHT", tex, 1, 1)
		right:SetPoint("BOTTOMRIGHT", tex, 1, -1)

		local top = ch:CreateTexture(nil, "BACKGROUND")
		top:SetHeight(1)
		if C.isBetaClient then
			top:SetColorTexture(0, 0, 0)
		else
			top:SetTexture(0, 0, 0)
		end
		top:SetPoint("TOPLEFT", tex, -1, 1)
		top:SetPoint("TOPRIGHT", tex, 1, -1)

		local bottom = ch:CreateTexture(nil, "BACKGROUND")
		bottom:SetHeight(1)
		if C.isBetaClient then
			bottom:SetColorTexture(0, 0, 0)
		else
			bottom:SetTexture(0, 0, 0)
		end
		bottom:SetPoint("BOTTOMLEFT", tex, -1, -1)
		bottom:SetPoint("BOTTOMRIGHT", tex, 1, -1)
	end

	AchievementFrameAchievementsContainerButton1.background:SetPoint("TOPLEFT", AchievementFrameAchievementsContainerButton1, "TOPLEFT", 2, -3)

	hooksecurefunc("AchievementButton_DisplayAchievement", function(button, category, achievement)
		local _, _, _, completed = GetAchievementInfo(category, achievement)
		if completed then
			if button.accountWide then
				button.label:SetTextColor(0, .6, 1)
			else
				button.label:SetTextColor(.9, .9, .9)
			end
		else
			if button.accountWide then
				button.label:SetTextColor(0, .3, .5)
			else
				button.label:SetTextColor(.65, .65, .65)
			end
		end
	end)

	hooksecurefunc("AchievementObjectives_DisplayCriteria", function(objectivesFrame, id)
		for i = 1, GetAchievementNumCriteria(id) do
			local name = _G["AchievementFrameCriteria"..i.."Name"]
			if name and select(2, name:GetTextColor()) == 0 then
				name:SetTextColor(1, 1, 1)
			end

			local bu = _G["AchievementFrameMeta"..i]
			if bu and select(2, bu.label:GetTextColor()) == 0 then
				bu.label:SetTextColor(1, 1, 1)
			end
		end
	end)

	hooksecurefunc("AchievementButton_GetProgressBar", function(index)
		local bar = _G["AchievementFrameProgressBar"..index]
		if not bar.reskinned then
			bar:SetStatusBarTexture(C.media.backdrop)

			if C.isBetaClient then
				_G["AchievementFrameProgressBar"..index.."BG"]:SetColorTexture(0, 0, 0, .25)
			else
				_G["AchievementFrameProgressBar"..index.."BG"]:SetTexture(0, 0, 0, .25)
			end
			_G["AchievementFrameProgressBar"..index.."BorderLeft"]:Hide()
			_G["AchievementFrameProgressBar"..index.."BorderCenter"]:Hide()
			_G["AchievementFrameProgressBar"..index.."BorderRight"]:Hide()

			local bg = CreateFrame("Frame", nil, bar)
			bg:SetPoint("TOPLEFT", -1, 1)
			bg:SetPoint("BOTTOMRIGHT", 1, -1)
			F.CreateBD(bg, 0)

			bar.reskinned = true
		end
	end)

	-- this is hidden behind other stuff in default UI
	AchievementFrameSummaryAchievementsEmptyText:SetText("")

	hooksecurefunc("AchievementFrameSummary_UpdateAchievements", function()
		for i = 1, ACHIEVEMENTUI_MAX_SUMMARY_ACHIEVEMENTS do
			local bu = _G["AchievementFrameSummaryAchievement"..i]

			if bu.accountWide then
				bu.label:SetTextColor(0, .6, 1)
			else
				bu.label:SetTextColor(.9, .9, .9)
			end

			if not bu.reskinned then
				bu:DisableDrawLayer("BORDER")

				local bd = _G["AchievementFrameSummaryAchievement"..i.."Background"]

				bd:SetTexture(C.media.backdrop)
				bd:SetVertexColor(0, 0, 0, .25)

				_G["AchievementFrameSummaryAchievement"..i.."TitleBackground"]:Hide()
				_G["AchievementFrameSummaryAchievement"..i.."Glow"]:Hide()
				_G["AchievementFrameSummaryAchievement"..i.."Highlight"]:SetAlpha(0)
				_G["AchievementFrameSummaryAchievement"..i.."IconOverlay"]:Hide()

				local text = _G["AchievementFrameSummaryAchievement"..i.."Description"]
				text:SetTextColor(.9, .9, .9)
				text.SetTextColor = F.dummy
				text:SetShadowOffset(1, -1)
				text.SetShadowOffset = F.dummy

				local bg = CreateFrame("Frame", nil, bu)
				bg:SetPoint("TOPLEFT", 2, -2)
				bg:SetPoint("BOTTOMRIGHT", -2, 2)
				F.CreateBD(bg, 0)

				local ic = _G["AchievementFrameSummaryAchievement"..i.."IconTexture"]
				ic:SetTexCoord(.08, .92, .08, .92)
				F.CreateBG(ic)

				bu.reskinned = true
			end
		end
	end)

	for i = 1, 12 do
		local bu = _G["AchievementFrameSummaryCategoriesCategory"..i]
		local bar = bu:GetStatusBarTexture()
		local label = _G["AchievementFrameSummaryCategoriesCategory"..i.."Label"]

		_G["AchievementFrameSummaryCategoriesCategory"..i.."Left"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."Middle"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."Right"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."FillBar"]:Hide()
		_G["AchievementFrameSummaryCategoriesCategory"..i.."ButtonHighlight"]:SetAlpha(0)

		bu:SetStatusBarTexture(C.media.backdrop)
		bu:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
		label:SetTextColor(1, 1, 1)
		label:SetPoint("LEFT", bu, "LEFT", 6, 0)

		bu.text:SetPoint("RIGHT", bu, "RIGHT", -5, 0)

		F.CreateBDFrame(bu, .25)
	end

	for i = 1, 20 do
		_G["AchievementFrameStatsContainerButton"..i.."BG"]:Hide()
		_G["AchievementFrameStatsContainerButton"..i.."BG"].Show = F.dummy
		_G["AchievementFrameStatsContainerButton"..i.."HeaderLeft"]:SetAlpha(0)
		_G["AchievementFrameStatsContainerButton"..i.."HeaderMiddle"]:SetAlpha(0)
		_G["AchievementFrameStatsContainerButton"..i.."HeaderRight"]:SetAlpha(0)
	end

	AchievementFrameComparisonHeader:SetPoint("BOTTOMRIGHT", AchievementFrameComparison, "TOPRIGHT", 39, 25)

	local headerbg = CreateFrame("Frame", nil, AchievementFrameComparisonHeader)
	headerbg:SetPoint("TOPLEFT", 20, -20)
	headerbg:SetPoint("BOTTOMRIGHT", -28, -5)
	headerbg:SetFrameLevel(AchievementFrameComparisonHeader:GetFrameLevel()-1)
	F.CreateBD(headerbg, .25)

	local summaries = {AchievementFrameComparisonSummaryPlayer, AchievementFrameComparisonSummaryFriend}

	for _, frame in pairs(summaries) do
		frame:SetBackdrop(nil)
		local bg = CreateFrame("Frame", nil, frame)
		bg:SetPoint("TOPLEFT", 2, -2)
		bg:SetPoint("BOTTOMRIGHT", -2, 0)
		bg:SetFrameLevel(frame:GetFrameLevel()-1)
		F.CreateBD(bg, .25)
	end

	local bars = {AchievementFrameComparisonSummaryPlayerStatusBar, AchievementFrameComparisonSummaryFriendStatusBar}

	for _, bar in pairs(bars) do
		local name = bar:GetName()
		bar:SetStatusBarTexture(C.media.backdrop)
		bar:GetStatusBarTexture():SetGradient("VERTICAL", 0, .4, 0, 0, .6, 0)
		_G[name.."Left"]:Hide()
		_G[name.."Middle"]:Hide()
		_G[name.."Right"]:Hide()
		_G[name.."FillBar"]:Hide()
		_G[name.."Title"]:SetTextColor(1, 1, 1)
		_G[name.."Title"]:SetPoint("LEFT", bar, "LEFT", 6, 0)
		_G[name.."Text"]:SetPoint("RIGHT", bar, "RIGHT", -5, 0)

		local bg = CreateFrame("Frame", nil, bar)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(bar:GetFrameLevel()-1)
		F.CreateBD(bg, .25)
	end

	for i = 1, 9 do
		local buttons = {_G["AchievementFrameComparisonContainerButton"..i.."Player"], _G["AchievementFrameComparisonContainerButton"..i.."Friend"]}

		for _, button in pairs(buttons) do
			button:DisableDrawLayer("BORDER")
			local bg = CreateFrame("Frame", nil, button)
			bg:SetPoint("TOPLEFT", 2, -3)
			bg:SetPoint("BOTTOMRIGHT", -2, 2)
			F.CreateBD(bg, 0)
		end

		local bd = _G["AchievementFrameComparisonContainerButton"..i.."PlayerBackground"]
		bd:SetTexture(C.media.backdrop)
		bd:SetVertexColor(0, 0, 0, .25)

		local bd = _G["AchievementFrameComparisonContainerButton"..i.."FriendBackground"]
		bd:SetTexture(C.media.backdrop)
		bd:SetVertexColor(0, 0, 0, .25)

		local text = _G["AchievementFrameComparisonContainerButton"..i.."PlayerDescription"]
		text:SetTextColor(.9, .9, .9)
		text.SetTextColor = F.dummy
		text:SetShadowOffset(1, -1)
		text.SetShadowOffset = F.dummy

		_G["AchievementFrameComparisonContainerButton"..i.."PlayerTitleBackground"]:Hide()
		_G["AchievementFrameComparisonContainerButton"..i.."PlayerGlow"]:Hide()
		_G["AchievementFrameComparisonContainerButton"..i.."PlayerIconOverlay"]:Hide()
		_G["AchievementFrameComparisonContainerButton"..i.."FriendTitleBackground"]:Hide()
		_G["AchievementFrameComparisonContainerButton"..i.."FriendGlow"]:Hide()
		_G["AchievementFrameComparisonContainerButton"..i.."FriendIconOverlay"]:Hide()

		local ic = _G["AchievementFrameComparisonContainerButton"..i.."PlayerIconTexture"]
		ic:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(ic)

		local ic = _G["AchievementFrameComparisonContainerButton"..i.."FriendIconTexture"]
		ic:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(ic)
	end

	F.ReskinClose(AchievementFrameCloseButton)
	F.ReskinScroll(AchievementFrameAchievementsContainerScrollBar)
	F.ReskinScroll(AchievementFrameStatsContainerScrollBar)
	F.ReskinScroll(AchievementFrameCategoriesContainerScrollBar)
	F.ReskinScroll(AchievementFrameComparisonContainerScrollBar)
end
