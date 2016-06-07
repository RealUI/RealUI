local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local r, g, b = C.r, C.g, C.b

	-- [[ Item reward highlight ]]

	QuestInfoItemHighlight:GetRegions():Hide()

	local function clearHighlight()
		for _, button in pairs(QuestInfoRewardsFrame.RewardButtons) do
			button.bg:SetBackdropColor(0, 0, 0, .25)
		end
	end

	local function setHighlight(self)
		clearHighlight()

		local _, point = self:GetPoint()
		if point then
			point.bg:SetBackdropColor(r, g, b, .2)
		end
	end

	hooksecurefunc(QuestInfoItemHighlight, "SetPoint", setHighlight)
	QuestInfoItemHighlight:HookScript("OnShow", setHighlight)
	QuestInfoItemHighlight:HookScript("OnHide", clearHighlight)

	-- [[ Shared ]]

	local function restyleSpellButton(bu)
		local name = bu:GetName()
		local icon = bu.Icon

		_G[name.."NameFrame"]:Hide()
		_G[name.."SpellBorder"]:Hide()

		icon:SetPoint("TOPLEFT", 3, -2)
		icon:SetDrawLayer("ARTWORK")
		icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(icon)

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", 2, -1)
		bg:SetPoint("BOTTOMRIGHT", 0, 14)
		bg:SetFrameLevel(0)
		F.CreateBD(bg, .25)
	end

	-- [[ Objectives ]]

	restyleSpellButton(QuestInfoSpellObjectiveFrame)

	local function colourObjectivesText()
		if not QuestInfoFrame.questLog then return end

		local objectivesTable = QuestInfoObjectivesFrame.Objectives
		local numVisibleObjectives = 0

		for i = 1, GetNumQuestLeaderBoards() do
			local text, type, finished = GetQuestLogLeaderBoard(i)

			if (type ~= "spell" and type ~= "log" and numVisibleObjectives < MAX_OBJECTIVES) then
				numVisibleObjectives = numVisibleObjectives + 1
				local objective = objectivesTable[numVisibleObjectives]

				if finished then
					objective:SetTextColor(.9, .9, .9)
				else
					objective:SetTextColor(1, 1, 1)
				end
			end
		end
	end

	hooksecurefunc("QuestMapFrame_ShowQuestDetails", colourObjectivesText)
	hooksecurefunc("QuestInfo_Display", colourObjectivesText)

	-- [[ Quest rewards ]]

	if not C.isBetaClient then
		restyleSpellButton(QuestInfoRewardSpell)
	end

	local function restyleRewardButton(bu, isMapQuestInfo)
		bu.NameFrame:Hide()

		bu.Icon:SetTexCoord(.08, .92, .08, .92)
		bu.Icon:SetDrawLayer("BACKGROUND", 1)
		F.CreateBG(bu.Icon, 1)

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", bu, 1, 1)

		if isMapQuestInfo then
			bg:SetPoint("BOTTOMRIGHT", bu, -3, 0)
			bu.Icon:SetSize(29, 29)
		else
			bg:SetPoint("BOTTOMRIGHT", bu, -3, 1)
		end

		bg:SetFrameLevel(0)
		F.CreateBD(bg, .25)

		bu.bg = bg
	end

	hooksecurefunc("QuestInfo_GetRewardButton", function(rewardsFrame, index)
		local bu = rewardsFrame.RewardButtons[index]

		if not bu.restyled then
			restyleRewardButton(bu, rewardsFrame == MapQuestInfoRewardsFrame)

			bu.restyled = true
		end
	end)

	restyleRewardButton(QuestInfoSkillPointFrame)
	if not C.isBetaClient then
		restyleRewardButton(MapQuestInfoRewardsFrame.SpellFrame, true)
	end
	restyleRewardButton(MapQuestInfoRewardsFrame.XPFrame, true)
	restyleRewardButton(MapQuestInfoRewardsFrame.MoneyFrame, true)
	restyleRewardButton(MapQuestInfoRewardsFrame.SkillPointFrame, true)

	MapQuestInfoRewardsFrame.XPFrame.Name:SetShadowOffset(0, 0)

	-- [[ Change text colours ]]

	hooksecurefunc(QuestInfoRequiredMoneyText, "SetTextColor", function(self, r, g, b)
		if r == 0 then
			self:SetTextColor(.8, .8, .8)
		elseif r == .2 then
			self:SetTextColor(1, 1, 1)
		end
	end)

	QuestInfoTitleHeader:SetTextColor(1, 1, 1)
	QuestInfoTitleHeader.SetTextColor = F.dummy
	QuestInfoTitleHeader:SetShadowColor(0, 0, 0)

	QuestInfoDescriptionHeader:SetTextColor(1, 1, 1)
	QuestInfoDescriptionHeader.SetTextColor = F.dummy
	QuestInfoDescriptionHeader:SetShadowColor(0, 0, 0)

	QuestInfoObjectivesHeader:SetTextColor(1, 1, 1)
	QuestInfoObjectivesHeader.SetTextColor = F.dummy
	QuestInfoObjectivesHeader:SetShadowColor(0, 0, 0)

	QuestInfoRewardsFrame.Header:SetTextColor(1, 1, 1)
	QuestInfoRewardsFrame.Header.SetTextColor = F.dummy
	QuestInfoRewardsFrame.Header:SetShadowColor(0, 0, 0)

	QuestInfoDescriptionText:SetTextColor(1, 1, 1)
	QuestInfoDescriptionText.SetTextColor = F.dummy

	QuestInfoObjectivesText:SetTextColor(1, 1, 1)
	QuestInfoObjectivesText.SetTextColor = F.dummy

	QuestInfoGroupSize:SetTextColor(1, 1, 1)
	QuestInfoGroupSize.SetTextColor = F.dummy

	QuestInfoRewardText:SetTextColor(1, 1, 1)
	QuestInfoRewardText.SetTextColor = F.dummy

	QuestInfoSpellObjectiveLearnLabel:SetTextColor(1, 1, 1)
	QuestInfoSpellObjectiveLearnLabel.SetTextColor = F.dummy

	QuestInfoRewardsFrame.ItemChooseText:SetTextColor(1, 1, 1)
	QuestInfoRewardsFrame.ItemChooseText.SetTextColor = F.dummy

	QuestInfoRewardsFrame.ItemReceiveText:SetTextColor(1, 1, 1)
	QuestInfoRewardsFrame.ItemReceiveText.SetTextColor = F.dummy

	if not C.isBetaClient then
		QuestInfoRewardsFrame.SpellLearnText:SetTextColor(1, 1, 1)
		QuestInfoRewardsFrame.SpellLearnText.SetTextColor = F.dummy
	end

	QuestInfoRewardsFrame.PlayerTitleText:SetTextColor(1, 1, 1)
	QuestInfoRewardsFrame.PlayerTitleText.SetTextColor = F.dummy

	QuestInfoRewardsFrame.XPFrame.ReceiveText:SetTextColor(1, 1, 1)
	QuestInfoRewardsFrame.XPFrame.ReceiveText.SetTextColor = F.dummy
end)
