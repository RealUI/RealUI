local F, C = unpack(select(2, ...))

C.themes["Blizzard_TradeSkillUI"] = function()
	if C.isBetaClient then
		F.ReskinPortraitFrame(TradeSkillFrame)

		local rankFrame = TradeSkillFrame.RankFrame
		rankFrame.BorderLeft:Hide()
		rankFrame.BorderRight:Hide()
		rankFrame.BorderMid:Hide()
		--rankFrame.Background:Hide()
		rankFrame:SetStatusBarTexture(C.media.backdrop)
		rankFrame.SetStatusBarColor = F.dummy
		rankFrame:GetStatusBarTexture():SetGradient("VERTICAL", .1, .3, .9, .2, .4, 1)
		F.CreateBDFrame(rankFrame)

		F.ReskinInput(TradeSkillFrame.SearchBox)
		F.ReskinFilterButton(TradeSkillFrame.FilterButton)
		TradeSkillFrame.FilterButton:SetPoint("TOPRIGHT", -7, -55)

		F.ReskinArrow(TradeSkillFrame.LinkToButton, "right")
		TradeSkillFrame.LinkToButton:SetPoint("BOTTOMRIGHT", TradeSkillFrame.FilterButton, "TOPRIGHT", 0, 6)

		--[[ Recipe List ]]--
		local recipeInset = TradeSkillFrame.RecipeInset
		recipeInset.Bg:Hide()
		recipeInset:DisableDrawLayer("BORDER")
		local recipeList = TradeSkillFrame.RecipeList
		F.ReskinScroll(recipeList.scrollBar, "TradeSkillFrame")
		for i = 1, #recipeList.Tabs do
			for j = 1, 6 do
				local region = select(j, recipeList.Tabs[i]:GetRegions())
				region:Hide()
				region.Show = F.dummy
			end
		end

		hooksecurefunc(recipeList, "RefreshDisplay", function(self)
			for i = 1, #self.buttons do
				local tradeSkillButton = self.buttons[i]
				if not tradeSkillButton._isSkinned then
					local bg = CreateFrame("Frame", nil, tradeSkillButton)
					F.CreateBD(bg, .0)
					F.CreateGradient(bg)
					bg:SetSize(15, 15)
					bg:SetPoint("TOPLEFT", tradeSkillButton:GetNormalTexture())
					tradeSkillButton:SetHighlightTexture("")
					tradeSkillButton:SetPushedTexture("")
					tradeSkillButton:SetNormalTexture("")
					tradeSkillButton.SetNormalTexture = function(self, texture)
						if texture == "" then
							bg:Hide()
						else
							bg:Show()
						end
					end

					tradeSkillButton.minus = bg:CreateTexture(nil, "ARTWORK")
					tradeSkillButton.minus:SetSize(7, 1)
					tradeSkillButton.minus:SetPoint("CENTER")
					tradeSkillButton.minus:SetTexture(C.media.backdrop)
					tradeSkillButton.minus:SetVertexColor(1, 1, 1)

					tradeSkillButton.plus = bg:CreateTexture(nil, "ARTWORK")
					tradeSkillButton.plus:SetSize(1, 7)
					tradeSkillButton.plus:SetPoint("CENTER")
					tradeSkillButton.plus:SetTexture(C.media.backdrop)
					tradeSkillButton.plus:SetVertexColor(1, 1, 1)

					tradeSkillButton:HookScript("OnEnter", F.colourExpandOrCollapse)
					tradeSkillButton:HookScript("OnLeave", F.clearExpandOrCollapse)

					tradeSkillButton._isSkinned = true
				end
			end
		end)

		--[[ Recipe Details ]]--
		local detailsInset = TradeSkillFrame.DetailsInset
		detailsInset.Bg:Hide()
		detailsInset:DisableDrawLayer("BORDER")
		local detailsFrame = TradeSkillFrame.DetailsFrame
		detailsFrame.Background:Hide()
		F.ReskinScroll(detailsFrame.ScrollBar, "TradeSkillFrame")
		F.Reskin(detailsFrame.CreateAllButton)
		F.Reskin(detailsFrame.ViewGuildCraftersButton)
		F.Reskin(detailsFrame.ExitButton)
		F.Reskin(detailsFrame.CreateButton)
		F.ReskinInput(detailsFrame.CreateMultipleInputBox)
		detailsFrame.CreateMultipleInputBox:DisableDrawLayer("BACKGROUND")
		F.ReskinArrow(detailsFrame.CreateMultipleInputBox.IncrementButton, "right")
		F.ReskinArrow(detailsFrame.CreateMultipleInputBox.DecrementButton, "left")

		local contents = detailsFrame.Contents
		contents.ResultIcon.Background:Hide()
		hooksecurefunc(contents.ResultIcon, "SetNormalTexture", function(self)
			if not self._isSkinned then
				F.ReskinIcon(self:GetNormalTexture())
				self._isSkinned = true
			end
		end)
		for i = 1, #contents.Reagents do
			local reagent = contents.Reagents[i]
			F.ReskinIcon(reagent.Icon)
			reagent.NameFrame:Hide()
			local bg = F.CreateBDFrame(reagent.NameFrame, .2)
			bg:SetPoint("TOPLEFT", reagent.Icon, "TOPRIGHT", 2, 0)
			bg:SetPoint("BOTTOMRIGHT", -4, 0)
		end
	else
		F.CreateBD(TradeSkillGuildFrame)
		F.CreateBD(TradeSkillGuildFrameContainer, .25)

		TradeSkillFramePortrait:Hide()
		TradeSkillFramePortrait.Show = F.dummy

		for i = 18, 20 do
			select(i, TradeSkillFrame:GetRegions()):Hide()
			select(i, TradeSkillFrame:GetRegions()).Show = F.dummy
		end
		TradeSkillHorizontalBarLeft:Hide()
		select(22, TradeSkillFrame:GetRegions()):Hide()
		for i = 1, 3 do
			select(i, TradeSkillExpandButtonFrame:GetRegions()):SetAlpha(0)
		end
		for i = 1, 9 do
			select(i, TradeSkillGuildFrame:GetRegions()):Hide()
		end
		TradeSkillListScrollFrame:GetRegions():Hide()
		select(2, TradeSkillListScrollFrame:GetRegions()):Hide()
		TradeSkillDetailHeaderLeft:Hide()
		select(6, TradeSkillDetailScrollChildFrame:GetRegions()):Hide()
		TradeSkillDetailScrollFrameTop:SetAlpha(0)
		TradeSkillDetailScrollFrameBottom:SetAlpha(0)
		TradeSkillGuildCraftersFrameTrack:Hide()
		TradeSkillRankFrameBorder:Hide()
		TradeSkillRankFrameBackground:Hide()

		TradeSkillDetailScrollFrame:SetHeight(176)

		local a1, p, a2, x, y = TradeSkillGuildFrame:GetPoint()
		TradeSkillGuildFrame:ClearAllPoints()
		TradeSkillGuildFrame:SetPoint(a1, p, a2, x + 16, y)

		TradeSkillLinkButton:SetPoint("LEFT", 0, -1)

		F.Reskin(TradeSkillCreateButton)
		F.Reskin(TradeSkillCreateAllButton)
		F.Reskin(TradeSkillCancelButton)
		F.Reskin(TradeSkillViewGuildCraftersButton)
		F.ReskinFilterButton(TradeSkillFilterButton)

		TradeSkillRankFrame:SetStatusBarTexture(C.media.backdrop)
		TradeSkillRankFrame.SetStatusBarColor = F.dummy
		TradeSkillRankFrame:GetStatusBarTexture():SetGradient("VERTICAL", .1, .3, .9, .2, .4, 1)

		local bg = CreateFrame("Frame", nil, TradeSkillRankFrame)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(TradeSkillRankFrame:GetFrameLevel()-1)
		F.CreateBD(bg, .25)

		for i = 1, MAX_TRADE_SKILL_REAGENTS do
			local bu = _G["TradeSkillReagent"..i]
			local ic = _G["TradeSkillReagent"..i.."IconTexture"]

			_G["TradeSkillReagent"..i.."NameFrame"]:SetAlpha(0)

			ic:SetTexCoord(.08, .92, .08, .92)
			ic:SetDrawLayer("ARTWORK")
			F.CreateBG(ic)

			local bd = CreateFrame("Frame", nil, bu)
			bd:SetPoint("TOPLEFT", 39, -1)
			bd:SetPoint("BOTTOMRIGHT", 0, 1)
			bd:SetFrameLevel(0)
			F.CreateBD(bd, .25)

			_G["TradeSkillReagent"..i.."Name"]:SetParent(bd)
		end

		hooksecurefunc("TradeSkillFrame_SetSelection", function()
			local ic = TradeSkillSkillIcon:GetNormalTexture()
			if ic then
				ic:SetTexCoord(.08, .92, .08, .92)
				ic:SetPoint("TOPLEFT", 1, -1)
				ic:SetPoint("BOTTOMRIGHT", -1, 1)
				F.CreateBD(TradeSkillSkillIcon)
			else
				TradeSkillSkillIcon:SetBackdrop(nil)
			end
		end)

		local colourExpandOrCollapse = F.colourExpandOrCollapse
		local clearExpandOrCollapse = F.clearExpandOrCollapse

		local function styleSkillButton(skillButton)
			skillButton:SetNormalTexture("")
			skillButton.SetNormalTexture = F.dummy
			skillButton:SetPushedTexture("")

			skillButton.bg = CreateFrame("Frame", nil, skillButton)
			skillButton.bg:SetSize(13, 13)
			skillButton.bg:SetPoint("LEFT", 4, 1)
			skillButton.bg:SetFrameLevel(skillButton:GetFrameLevel()-1)
			F.CreateBD(skillButton.bg, 0)

			skillButton.tex = F.CreateGradient(skillButton)
			skillButton.tex:SetPoint("TOPLEFT", skillButton.bg, 1, -1)
			skillButton.tex:SetPoint("BOTTOMRIGHT", skillButton.bg, -1, 1)

			skillButton.minus = skillButton:CreateTexture(nil, "OVERLAY")
			skillButton.minus:SetSize(7, 1)
			skillButton.minus:SetPoint("CENTER", skillButton.bg)
			skillButton.minus:SetTexture(C.media.backdrop)
			skillButton.minus:SetVertexColor(1, 1, 1)

			skillButton.plus = skillButton:CreateTexture(nil, "OVERLAY")
			skillButton.plus:SetSize(1, 7)
			skillButton.plus:SetPoint("CENTER", skillButton.bg)
			skillButton.plus:SetTexture(C.media.backdrop)
			skillButton.plus:SetVertexColor(1, 1, 1)

			skillButton:HookScript("OnEnter", colourExpandOrCollapse)
			skillButton:HookScript("OnLeave", clearExpandOrCollapse)
		end

		styleSkillButton(TradeSkillCollapseAllButton)
		TradeSkillCollapseAllButton:SetDisabledTexture("")
		TradeSkillCollapseAllButton:SetHighlightTexture("")

		hooksecurefunc("TradeSkillFrame_Update", function()
			local numTradeSkills = GetNumTradeSkills()
			local skillOffset = FauxScrollFrame_GetOffset(TradeSkillListScrollFrame)
			local _, skillIndex, skillType, isExpanded
			local diplayedSkills = TRADE_SKILLS_DISPLAYED
			local hasFilterBar = TradeSkillFilterBar:IsShown()
			if hasFilterBar then
				diplayedSkills = TRADE_SKILLS_DISPLAYED - 1
			end
			local buttonIndex = 0

			for i = 1, diplayedSkills do
				skillIndex = i + skillOffset
				_, skillType, _, isExpanded = GetTradeSkillInfo(skillIndex)
				if hasFilterBar then
					buttonIndex = i + 1
				else
					buttonIndex = i
				end

				local skillButton = _G["TradeSkillSkill"..buttonIndex]

				if not skillButton.styled then
					skillButton.styled = true

					local buttonHighlight = _G["TradeSkillSkill"..buttonIndex.."Highlight"]
					buttonHighlight:SetTexture("")
					buttonHighlight.SetTexture = F.dummy

					skillButton.SubSkillRankBar.BorderLeft:Hide()
					skillButton.SubSkillRankBar.BorderRight:Hide()
					skillButton.SubSkillRankBar.BorderMid:Hide()

					skillButton.SubSkillRankBar:SetHeight(12)
					skillButton.SubSkillRankBar:SetStatusBarTexture(C.media.backdrop)
					skillButton.SubSkillRankBar:GetStatusBarTexture():SetGradient("VERTICAL", .1, .3, .9, .2, .4, 1)
					F.CreateBDFrame(skillButton.SubSkillRankBar, .25)

					styleSkillButton(skillButton)
				end

				if skillIndex <= numTradeSkills then
					if skillType == "header" or skillType == "subheader" then
						if skillType == "subheader" then
							skillButton.bg:SetPoint("LEFT", 24, 1)
						else
							skillButton.bg:SetPoint("LEFT", 4, 1)
						end

						skillButton.bg:Show()
						skillButton.tex:Show()
						skillButton.minus:Show()
						if isExpanded then
							skillButton.plus:Hide()
						else
							skillButton.plus:Show()
						end
					else
						skillButton.bg:Hide()
						skillButton.tex:Hide()
						skillButton.minus:Hide()
						skillButton.plus:Hide()
					end
				end

				if TradeSkillCollapseAllButton.collapsed == 1 then
					TradeSkillCollapseAllButton.plus:Show()
				else
					TradeSkillCollapseAllButton.plus:Hide()
				end
			end
		end)

		TradeSkillIncrementButton:SetPoint("RIGHT", TradeSkillCreateButton, "LEFT", -9, 0)

		F.ReskinPortraitFrame(TradeSkillFrame, true)
		F.ReskinClose(TradeSkillGuildFrameCloseButton)
		F.ReskinScroll(TradeSkillDetailScrollFrameScrollBar)
		F.ReskinScroll(TradeSkillListScrollFrameScrollBar)
		F.ReskinScroll(TradeSkillGuildCraftersFrameScrollBar)
		F.ReskinInput(TradeSkillInputBox, nil, 33)
		F.ReskinInput(TradeSkillFrameSearchBox)
		F.ReskinArrow(TradeSkillDecrementButton, "left")
		F.ReskinArrow(TradeSkillIncrementButton, "right")
		F.ReskinArrow(TradeSkillLinkButton, "right")
	end
end
