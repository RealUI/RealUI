local F, C = unpack(select(2, ...))

tinsert(C.modules["Aurora"], function()
	local LootHistoryFrame = LootHistoryFrame

	for i = 1, 9 do
		select(i, LootHistoryFrame:GetRegions()):Hide()
	end
	LootHistoryFrame.LootIcon:Hide()
	LootHistoryFrame.Divider:SetAlpha(0)
	LootHistoryFrameScrollFrame:GetRegions():Hide()

	LootHistoryFrame.Label:ClearAllPoints()
	LootHistoryFrame.Label:SetPoint("TOP", LootHistoryFrame, "TOP", 0, -8)

	LootHistoryFrame.ResizeButton:SetPoint("TOP", LootHistoryFrame, "BOTTOM", 0, 1)
	LootHistoryFrame.ResizeButton:SetFrameStrata("LOW")

	F.ReskinArrow(LootHistoryFrame.ResizeButton, "down")
	LootHistoryFrame.ResizeButton:SetSize(32, 12)

	F.CreateBD(LootHistoryFrame)

	F.ReskinClose(LootHistoryFrame.CloseButton)
	F.ReskinScroll(LootHistoryFrameScrollFrameScrollBar)

	hooksecurefunc("LootHistoryFrame_UpdateItemFrame", function(self, frame)
		local rollID, _, _, isDone, winnerIdx = C_LootHistory.GetItem(frame.itemIdx)
		local expanded = self.expandedRolls[rollID]

		if not frame.styled then
			frame.Divider:Hide()
			frame.NameBorderLeft:Hide()
			frame.NameBorderRight:Hide()
			frame.NameBorderMid:Hide()
			frame.IconBorder:Hide()

			frame.WinnerRoll:SetTextColor(.9, .9, .9)

			frame.Icon:SetTexCoord(.08, .92, .08, .92)
			frame.Icon:SetDrawLayer("ARTWORK")
			frame.bg = F.CreateBG(frame.Icon)
			frame.bg:SetVertexColor(frame.IconBorder:GetVertexColor())

			F.ReskinExpandOrCollapse(frame.ToggleButton)
			frame.ToggleButton:GetNormalTexture():SetAlpha(0)
			frame.ToggleButton:GetPushedTexture():SetAlpha(0)
			frame.ToggleButton:GetDisabledTexture():SetAlpha(0)

			frame.styled = true
		end

		if isDone and not expanded and winnerIdx then
			local name, class = C_LootHistory.GetPlayerInfo(frame.itemIdx, winnerIdx)
			if name then
				local colour = C.classcolours[class]
				frame.WinnerName:SetVertexColor(colour.r, colour.g, colour.b)
			end
		end

		frame.bg:SetVertexColor(frame.IconBorder:GetVertexColor())
		frame.ToggleButton.plus:SetShown(not expanded)
	end)

	hooksecurefunc("LootHistoryFrame_UpdatePlayerFrame", function(_, playerFrame)
		if not playerFrame.styled then
			playerFrame.RollText:SetTextColor(.9, .9, .9)
			playerFrame.WinMark:SetDesaturated(true)

			playerFrame.styled = true
		end

		if playerFrame.playerIdx then
			local name, class, _, _, isWinner = C_LootHistory.GetPlayerInfo(playerFrame.itemIdx, playerFrame.playerIdx)

			if name then
				local colour = C.classcolours[class]
				playerFrame.PlayerName:SetTextColor(colour.r, colour.g, colour.b)

				if isWinner then
					playerFrame.WinMark:SetVertexColor(colour.r, colour.g, colour.b)
				end
			end
		end
	end)

	LootHistoryDropDown.initialize = function(self)
		local info = UIDropDownMenu_CreateInfo();
		info.isTitle = 1;
		info.text = MASTER_LOOTER;
		info.fontObject = GameFontNormalLeft;
		info.notCheckable = 1;
		UIDropDownMenu_AddButton(info);

		info = UIDropDownMenu_CreateInfo();
		info.notCheckable = 1;
		local name, class = C_LootHistory.GetPlayerInfo(self.itemIdx, self.playerIdx);
		local classColor = C.classcolours[class];
		local colorCode = string.format("|cFF%02x%02x%02x",  classColor.r*255,  classColor.g*255,  classColor.b*255);
		info.text = string.format(MASTER_LOOTER_GIVE_TO, colorCode..name.."|r");
		info.func = LootHistoryDropDown_OnClick;
		UIDropDownMenu_AddButton(info);
	end
end)