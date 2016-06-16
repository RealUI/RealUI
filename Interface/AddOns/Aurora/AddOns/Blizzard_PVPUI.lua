local F, C = unpack(select(2, ...))

C.themes["Blizzard_PVPUI"] = function()
	local r, g, b = C.r, C.g, C.b

	local PVPUIFrame = PVPUIFrame
	local PVPQueueFrame = PVPQueueFrame
	local HonorFrame = HonorFrame
	local ConquestFrame = ConquestFrame
	local WarGamesFrame = WarGamesFrame
	local PVPArenaTeamsFrame = PVPArenaTeamsFrame

	-- Category buttons

	for i = 1, 4 do
		local bu = PVPQueueFrame["CategoryButton"..i]
		local icon = bu.Icon
		local cu = bu.CurrencyDisplay

		bu.Ring:Hide()

		F.Reskin(bu, true)

		bu.Background:SetAllPoints()
		if C.isBetaClient then
			bu.Background:SetColorTexture(r, g, b, .2)
		else
			bu.Background:SetTexture(r, g, b, .2)
		end
		bu.Background:Hide()

		icon:SetTexCoord(.08, .92, .08, .92)
		icon:SetPoint("LEFT", bu, "LEFT")
		icon:SetDrawLayer("OVERLAY")
		icon.bg = F.CreateBG(icon)
		icon.bg:SetDrawLayer("ARTWORK")

		if cu then
			local ic = cu.Icon

			ic:SetSize(16, 16)
			ic:SetPoint("TOPLEFT", bu.Name, "BOTTOMLEFT", 0, -8)
			cu.Amount:SetPoint("LEFT", ic, "RIGHT", 4, 0)

			ic:SetTexCoord(.08, .92, .08, .92)
			ic.bg = F.CreateBG(ic)
			ic.bg:SetDrawLayer("BACKGROUND", 1)
		end
	end

	PVPQueueFrame.CategoryButton1.Icon:SetTexture("Interface\\Icons\\achievement_bg_winwsg")
	PVPQueueFrame.CategoryButton2.Icon:SetTexture("Interface\\Icons\\achievement_bg_killxenemies_generalsroom")
	PVPQueueFrame.CategoryButton3.Icon:SetTexture("Interface\\Icons\\ability_warrior_offensivestance")

	local englishFaction = UnitFactionGroup("player")
	if not C.isBetaClient then
		PVPQueueFrame.CategoryButton1.CurrencyDisplay.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Honor-"..englishFaction)
		PVPQueueFrame.CategoryButton2.CurrencyDisplay.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..englishFaction)
	end

	hooksecurefunc("PVPQueueFrame_SelectButton", function(index)
		local self = PVPQueueFrame
		for i = 1, 4 do
			local bu = self["CategoryButton"..i]
			if i == index then
				bu.Background:Show()
			else
				bu.Background:Hide()
			end
		end
	end)

	PVPQueueFrame.CategoryButton1.Background:Show()

	-- Honor frame

	local Inset = HonorFrame.Inset
	local BonusFrame = HonorFrame.BonusFrame

	for i = 1, 9 do
		select(i, Inset:GetRegions()):Hide()
	end
	if not C.isBetaClient then
		BonusFrame.BattlegroundTexture:Hide()
		BonusFrame.BattlegroundHeader:Hide()
		BonusFrame.WorldPVPHeader:Hide()
	end
	BonusFrame.WorldBattlesTexture:Hide()
	BonusFrame.ShadowOverlay:Hide()

	F.Reskin(BonusFrame.DiceButton)

	for _, bonusButton in pairs({"RandomBGButton", "Arena1Button", (C.isBetaClient and "AshranButton" or "Arena2Button")}) do
		local bu = BonusFrame[bonusButton]

		F.Reskin(bu, true)

		bu.SelectedTexture:SetDrawLayer("BACKGROUND")
		if C.isBetaClient then
			bu.SelectedTexture:SetColorTexture(r, g, b, .2)
		else
			bu.SelectedTexture:SetTexture(r, g, b, .2)
		end
		bu.SelectedTexture:SetAllPoints()

		if C.isBetaClient then
			bu.Reward.Border:Hide()
			bu.Reward.Icon:SetTexCoord(.08, .92, .08, .92)
			bu.Reward.Icon:SetSize(24, 24)
			F.CreateBG(bu.Reward.Icon)
		end
	end

	if not C.isBetaClient then
		BonusFrame.BattlegroundReward1.Amount:SetPoint("RIGHT", BonusFrame.BattlegroundReward1.Icon, "LEFT", -2, 0)
		BonusFrame.BattlegroundReward1.Icon:SetTexCoord(.08, .92, .08, .92)
		BonusFrame.BattlegroundReward1.Icon:SetSize(16, 16)
		F.CreateBG(BonusFrame.BattlegroundReward1.Icon)
		BonusFrame.BattlegroundReward2.Amount:SetPoint("RIGHT", BonusFrame.BattlegroundReward2.Icon, "LEFT", -2, 0)
		BonusFrame.BattlegroundReward2.Icon:SetTexCoord(.08, .92, .08, .92)
		BonusFrame.BattlegroundReward2.Icon:SetSize(16, 16)
		F.CreateBG(BonusFrame.BattlegroundReward2.Icon)
	end

	hooksecurefunc("HonorFrameBonusFrame_Update", function()
		local hasData, canQueue, bgName, battleGroundID, hasWon, winHonorAmount, winConquestAmount = GetHolidayBGInfo()
		local rewardIndex = 0
		if winConquestAmount and winConquestAmount > 0 then
			rewardIndex = rewardIndex + 1
			local frame = HonorFrame.BonusFrame["BattlegroundReward"..rewardIndex]
			frame.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..englishFaction)
		end
		if winHonorAmount and winHonorAmount > 0 then
			rewardIndex = rewardIndex + 1
			local frame = HonorFrame.BonusFrame["BattlegroundReward"..rewardIndex]
			frame.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Honor-"..englishFaction)
		end
	end)

	IncludedBattlegroundsDropDown:SetPoint("TOPRIGHT", BonusFrame.DiceButton, 40, 26)

	-- Role buttons

	local RoleInset = HonorFrame.RoleInset

	RoleInset:DisableDrawLayer("BACKGROUND")
	RoleInset:DisableDrawLayer("BORDER")

	for _, roleButton in pairs({RoleInset.HealerIcon, RoleInset.TankIcon, RoleInset.DPSIcon}) do
		roleButton.cover:SetTexture(C.media.roleIcons)
		roleButton:SetNormalTexture(C.media.roleIcons)

		roleButton.checkButton:SetFrameLevel(roleButton:GetFrameLevel() + 2)

		for i = 1, 2 do
			local left = roleButton:CreateTexture()
			left:SetDrawLayer("OVERLAY", i)
			left:SetWidth(1)
			left:SetTexture(C.media.backdrop)
			left:SetVertexColor(0, 0, 0)
			left:SetPoint("TOPLEFT", roleButton, 6, -4)
			left:SetPoint("BOTTOMLEFT", roleButton, 6, 7)
			roleButton["leftLine"..i] = left

			local right = roleButton:CreateTexture()
			right:SetDrawLayer("OVERLAY", i)
			right:SetWidth(1)
			right:SetTexture(C.media.backdrop)
			right:SetVertexColor(0, 0, 0)
			right:SetPoint("TOPRIGHT", roleButton, -6, -4)
			right:SetPoint("BOTTOMRIGHT", roleButton, -6, 7)
			roleButton["rightLine"..i] = right

			local top = roleButton:CreateTexture()
			top:SetDrawLayer("OVERLAY", i)
			top:SetHeight(1)
			top:SetTexture(C.media.backdrop)
			top:SetVertexColor(0, 0, 0)
			top:SetPoint("TOPLEFT", roleButton, 6, -4)
			top:SetPoint("TOPRIGHT", roleButton, -6, -4)
			roleButton["topLine"..i] = top

			local bottom = roleButton:CreateTexture()
			bottom:SetDrawLayer("OVERLAY", i)
			bottom:SetHeight(1)
			bottom:SetTexture(C.media.backdrop)
			bottom:SetVertexColor(0, 0, 0)
			bottom:SetPoint("BOTTOMLEFT", roleButton, 6, 7)
			bottom:SetPoint("BOTTOMRIGHT", roleButton, -6, 7)
			roleButton["bottomLine"..i] = bottom
		end

		roleButton.leftLine2:Hide()
		roleButton.rightLine2:Hide()
		roleButton.topLine2:Hide()
		roleButton.bottomLine2:Hide()

		F.ReskinCheck(roleButton.checkButton)
	end

	-- Honor frame specific

	for _, bu in pairs(HonorFrame.SpecificFrame.buttons) do
		bu.Bg:Hide()
		bu.Border:Hide()

		bu:SetNormalTexture("")
		bu:SetHighlightTexture("")

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", -1, 2)
		F.CreateBD(bg, 0)
		bg:SetFrameLevel(bu:GetFrameLevel()-1)

		bu.tex = F.CreateGradient(bu)
		bu.tex:SetDrawLayer("BACKGROUND")
		bu.tex:SetPoint("TOPLEFT", bg, 1, -1)
		bu.tex:SetPoint("BOTTOMRIGHT", bg, -1, 1)

		bu.SelectedTexture:SetDrawLayer("BACKGROUND")
		if C.isBetaClient then
			bu.SelectedTexture:SetColorTexture(r, g, b, .2)
		else
			bu.SelectedTexture:SetTexture(r, g, b, .2)
		end
		bu.SelectedTexture:SetAllPoints(bu.tex)

		bu.Icon:SetTexCoord(.08, .92, .08, .92)
		bu.Icon.bg = F.CreateBG(bu.Icon)
		bu.Icon.bg:SetDrawLayer("BACKGROUND", 1)
		bu.Icon:SetPoint("TOPLEFT", 5, -3)
	end

	-- Conquest Frame

	local Inset = ConquestFrame.Inset
	local ConquestBar = ConquestFrame.ConquestBar

	for i = 1, 9 do
		select(i, Inset:GetRegions()):Hide()
	end
	ConquestFrame.ArenaTexture:Hide()
	ConquestFrame.RatedBGTexture:Hide()
	ConquestFrame.ArenaHeader:Hide()
	ConquestFrame.RatedBGHeader:Hide()
	ConquestFrame.ShadowOverlay:Hide()

	F.CreateBD(ConquestTooltip)

	local ConquestFrameButton_OnEnter = function(self)
		ConquestTooltip:SetPoint("TOPLEFT", self, "TOPRIGHT", 1, 0)
	end

	ConquestFrame.Arena2v2:HookScript("OnEnter", ConquestFrameButton_OnEnter)
	ConquestFrame.Arena3v3:HookScript("OnEnter", ConquestFrameButton_OnEnter)
	if not C.isBetaClient then
		ConquestFrame.Arena5v5:HookScript("OnEnter", ConquestFrameButton_OnEnter)
	end
	ConquestFrame.RatedBG:HookScript("OnEnter", ConquestFrameButton_OnEnter)

	local ratedButtons = {ConquestFrame.Arena2v2, ConquestFrame.Arena3v3, ConquestFrame.RatedBG}
	if not C.isBetaClient then
		tinsert(ratedButtons, 3, ConquestFrame.Arena5v5)
	end
	for _, bu in pairs(ratedButtons) do
		F.Reskin(bu, true)

		bu.SelectedTexture:SetDrawLayer("BACKGROUND")
		if C.isBetaClient then
			bu.SelectedTexture:SetColorTexture(r, g, b, .2)
		else
			bu.SelectedTexture:SetTexture(r, g, b, .2)
		end
		bu.SelectedTexture:SetAllPoints()

		if C.isBetaClient then
			bu.Reward.Border:Hide()
			bu.Reward.Icon:SetTexCoord(.08, .92, .08, .92)
			bu.Reward.Icon:SetSize(24, 24)
			F.CreateBG(bu.Reward.Icon)
		end
	end

	ConquestFrame.Arena3v3:SetPoint("TOP", ConquestFrame.Arena2v2, "BOTTOM", 0, -1)
	if not C.isBetaClient then
		ConquestFrame.Arena5v5:SetPoint("TOP", ConquestFrame.Arena3v3, "BOTTOM", 0, -1)

		ConquestFrame.ArenaReward.Amount:SetPoint("RIGHT", ConquestFrame.ArenaReward.Icon, "LEFT", -2, 0)
		ConquestFrame.ArenaReward.Icon:SetTexCoord(.08, .92, .08, .92)
		ConquestFrame.ArenaReward.Icon:SetSize(16, 16)
		F.CreateBG(ConquestFrame.ArenaReward.Icon)
		ConquestFrame.RatedBGReward.Amount:SetPoint("RIGHT", ConquestFrame.RatedBGReward.Icon, "LEFT", -2, 0)
		ConquestFrame.RatedBGReward.Icon:SetTexCoord(.08, .92, .08, .92)
		ConquestFrame.RatedBGReward.Icon:SetSize(16, 16)
		F.CreateBG(ConquestFrame.RatedBGReward.Icon)

		ConquestFrame.ArenaReward.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..englishFaction)
		ConquestFrame.RatedBGReward.Icon:SetTexture("Interface\\Icons\\PVPCurrency-Conquest-"..englishFaction)

		for i = 1, 4 do
			select(i, ConquestBar:GetRegions()):Hide()
			_G["ConquestPointsBarDivider"..i]:Hide()
		end

		ConquestBar.shadow:Hide()

		ConquestBar.progress:SetTexture(C.media.backdrop)
		ConquestBar.progress:SetGradient("VERTICAL", .8, 0, 0, 1, 0, 0)

		local bg = F.CreateBDFrame(ConquestBar, .25)
		bg:SetPoint("TOPLEFT", -1, -2)
		bg:SetPoint("BOTTOMRIGHT", 1, 2)
	end

	-- War games

	local Inset = WarGamesFrame.RightInset

	for i = 1, 9 do
		select(i, Inset:GetRegions()):Hide()
	end
	WarGamesFrame.InfoBG:Hide()
	WarGamesFrame.HorizontalBar:Hide()
	WarGamesFrameInfoScrollFrame.scrollBarBackground:Hide()
	WarGamesFrameInfoScrollFrame.scrollBarArtTop:Hide()
	WarGamesFrameInfoScrollFrame.scrollBarArtBottom:Hide()

	WarGamesFrameDescription:SetTextColor(.9, .9, .9)

	local function onSetNormalTexture(self, texture)
		if texture:find("Plus") then
			self.plus:Show()
		else
			self.plus:Hide()
		end
	end

	for _, button in pairs(WarGamesFrame.scrollFrame.buttons) do
		local bu = button.Entry
		local SelectedTexture = bu.SelectedTexture

		bu.Bg:Hide()
		bu.Border:Hide()

		bu:SetNormalTexture("")
		bu:SetHighlightTexture("")

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", 2, 0)
		bg:SetPoint("BOTTOMRIGHT", -1, 2)
		F.CreateBD(bg, 0)
		bg:SetFrameLevel(bu:GetFrameLevel()-1)

		local tex = F.CreateGradient(bu)
		tex:SetDrawLayer("BACKGROUND")
		tex:SetPoint("TOPLEFT", 3, -1)
		tex:SetPoint("BOTTOMRIGHT", -2, 3)

		SelectedTexture:SetDrawLayer("BACKGROUND")
		if C.isBetaClient then
			SelectedTexture:SetColorTexture(r, g, b, .2)
		else
			SelectedTexture:SetTexture(r, g, b, .2)
		end
		SelectedTexture:SetPoint("TOPLEFT", 2, 0)
		SelectedTexture:SetPoint("BOTTOMRIGHT", -1, 2)

		bu.Icon:SetTexCoord(.08, .92, .08, .92)
		bu.Icon.bg = F.CreateBG(bu.Icon)
		bu.Icon.bg:SetDrawLayer("BACKGROUND", 1)
		bu.Icon:SetPoint("TOPLEFT", 5, -3)

		local header = button.Header

		header:GetNormalTexture():SetAlpha(0)
		header:SetHighlightTexture("")
		header:SetPushedTexture("")

		local headerBg = CreateFrame("Frame", nil, header)
		headerBg:SetSize(13, 13)
		headerBg:SetPoint("LEFT", 4, 0)
		headerBg:SetFrameLevel(header:GetFrameLevel()-1)
		F.CreateBD(headerBg, 0)

		local headerTex = F.CreateGradient(header)
		headerTex:SetAllPoints(headerBg)

		local minus = header:CreateTexture(nil, "OVERLAY")
		minus:SetSize(7, 1)
		minus:SetPoint("CENTER", headerBg)
		minus:SetTexture(C.media.backdrop)
		minus:SetVertexColor(1, 1, 1)

		local plus = header:CreateTexture(nil, "OVERLAY")
		plus:SetSize(1, 7)
		plus:SetPoint("CENTER", headerBg)
		plus:SetTexture(C.media.backdrop)
		plus:SetVertexColor(1, 1, 1)
		header.plus = plus

		hooksecurefunc(header, "SetNormalTexture", onSetNormalTexture)
	end

	F.ReskinCheck(WarGameTournamentModeCheckButton)

	-- Main style

	if C.isBetaClient then
		F.Reskin(HonorFrame.QueueButton)
	else
		F.Reskin(HonorFrame.SoloQueueButton)
		F.Reskin(HonorFrame.GroupQueueButton)
	end
	F.Reskin(ConquestFrame.JoinButton)
	F.Reskin(WarGameStartButton)
	F.ReskinDropDown(HonorFrameTypeDropDown)
	F.ReskinScroll(HonorFrameSpecificFrameScrollBar)
	F.ReskinScroll(WarGamesFrameScrollFrameScrollBar)
	F.ReskinScroll(WarGamesFrameInfoScrollFrameScrollBar)
end
