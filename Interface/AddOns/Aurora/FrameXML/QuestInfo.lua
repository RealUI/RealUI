local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local r, g, b = C.r, C.g, C.b

	QuestInfoTitleHeader:SetShadowColor(0, 0, 0)
	QuestInfoTitleHeader:SetTextColor(1, 1, 1)
	QuestInfoTitleHeader.SetTextColor = F.dummy
	QuestInfoDescriptionHeader:SetTextColor(1, 1, 1)
	QuestInfoDescriptionHeader.SetTextColor = F.dummy
	QuestInfoDescriptionHeader:SetShadowColor(0, 0, 0)
	QuestInfoObjectivesHeader:SetTextColor(1, 1, 1)
	QuestInfoObjectivesHeader.SetTextColor = F.dummy
	QuestInfoObjectivesHeader:SetShadowColor(0, 0, 0)
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

	QuestInfoItemHighlight:GetRegions():Hide()
	QuestInfoSpellObjectiveFrameNameFrame:Hide()

	QuestInfoSkillPointFrameIconTexture:SetSize(40, 40)
	QuestInfoSkillPointFrameIconTexture:SetTexCoord(.08, .92, .08, .92)

	local bg = CreateFrame("Frame", nil, QuestInfoSkillPointFrame)
	bg:SetPoint("TOPLEFT", -3, 0)
	bg:SetPoint("BOTTOMRIGHT", -3, 0)
	bg:Lower()
	F.CreateBD(bg, .25)

	QuestInfoSkillPointFrameNameFrame:Hide()
	QuestInfoSkillPointFrameName:SetParent(bg)
	QuestInfoSkillPointFrameIconTexture:SetParent(bg)

	local skillPointLine = QuestInfoSkillPointFrame:CreateTexture(nil, "BACKGROUND")
	skillPointLine:SetSize(1, 40)
	skillPointLine:SetPoint("RIGHT", QuestInfoSkillPointFrameIconTexture, 1, 0)
	skillPointLine:SetTexture(C.media.backdrop)
	skillPointLine:SetVertexColor(0, 0, 0)

	QuestInfoRewardSpellIconTexture:SetSize(40, 40)
	QuestInfoRewardSpellIconTexture:SetTexCoord(.08, .92, .08, .92)
	QuestInfoRewardSpellIconTexture:SetDrawLayer("OVERLAY")

	local bg = CreateFrame("Frame", nil, QuestInfoRewardSpell)
	bg:SetPoint("TOPLEFT", 9, -1)
	bg:SetPoint("BOTTOMRIGHT", -10, 13)
	bg:Lower()
	F.CreateBD(bg, .25)

	QuestInfoRewardSpellNameFrame:Hide()
	QuestInfoRewardSpellSpellBorder:Hide()
	QuestInfoRewardSpellName:SetParent(bg)
	QuestInfoRewardSpellIconTexture:SetParent(bg)

	local spellLine = QuestInfoRewardSpell:CreateTexture(nil, "BACKGROUND")
	spellLine:SetSize(1, 40)
	spellLine:SetPoint("RIGHT", QuestInfoRewardSpellIconTexture, 1, 0)
	spellLine:SetTexture(C.media.backdrop)
	spellLine:SetVertexColor(0, 0, 0)

	local function clearHighlight()
		for i = 1, MAX_NUM_ITEMS do
			--_G["QuestInfoItem"..i]:SetBackdropColor(0, 0, 0, .25)
		end
	end

	local function setHighlight(self)
		clearHighlight()

		local _, point = self:GetPoint()
		point:SetBackdropColor(r, g, b, .2)
	end

	hooksecurefunc(QuestInfoItemHighlight, "SetPoint", setHighlight)
	QuestInfoItemHighlight:HookScript("OnShow", setHighlight)
	QuestInfoItemHighlight:HookScript("OnHide", clearHighlight)

	hooksecurefunc(QuestInfoRequiredMoneyText, "SetTextColor", function(self, r, g, b)
		if r == 0 then
			self:SetTextColor(.8, .8, .8)
		elseif r == .2 then
			self:SetTextColor(1, 1, 1)
		end
	end)

	-- for i = 1, MAX_OBJECTIVES do
		-- local objective = _G["QuestInfoObjective"..i]
		-- objective:SetTextColor(1, 1, 1)
		-- objective.SetTextColor = F.dummy
	-- end

	-- hooksecurefunc("QuestInfo_ShowObjectives", function()
		-- print("wat")
		-- local objectivesTable = QuestInfoObjectivesFrame.Objectives
		-- local numVisibleObjectives = 0

		-- for i = 1, GetNumQuestLeaderBoards() do
			-- local text, type, finished = GetQuestLogLeaderBoard(i)

			-- if (type ~= "spell" and type ~= "log" and numVisibleObjectives < MAX_OBJECTIVES) then
				-- numVisibleObjectives = numVisibleObjectives + 1
				-- local objective = objectivesTable[numVisibleObjectives]

				-- if finished then
					-- objective:SetTextColor(.7, .7, .7)
				-- else
					-- objective:SetTextColor(1, 1, 1)
				-- end
			-- end
		-- end
	-- end)
end)
