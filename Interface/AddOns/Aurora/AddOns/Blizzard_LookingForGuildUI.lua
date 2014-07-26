local F, C = unpack(select(2, ...))

C.modules["Blizzard_LookingForGuildUI"] = function()
	local r, g, b = C.r, C.g, C.b

	F.SetBD(LookingForGuildFrame)
	F.CreateBD(LookingForGuildInterestFrame, .25)
	LookingForGuildInterestFrameBg:Hide()
	F.CreateBD(LookingForGuildAvailabilityFrame, .25)
	LookingForGuildAvailabilityFrameBg:Hide()
	F.CreateBD(LookingForGuildRolesFrame, .25)
	LookingForGuildRolesFrameBg:Hide()
	F.CreateBD(LookingForGuildCommentFrame, .25)
	LookingForGuildCommentFrameBg:Hide()
	F.CreateBD(LookingForGuildCommentInputFrame, .12)
	LookingForGuildFrame:DisableDrawLayer("BACKGROUND")
	LookingForGuildFrame:DisableDrawLayer("BORDER")
	LookingForGuildFrameInset:DisableDrawLayer("BACKGROUND")
	LookingForGuildFrameInset:DisableDrawLayer("BORDER")
	F.CreateBD(GuildFinderRequestMembershipFrame)
	for i = 1, 5 do
		local bu = _G["LookingForGuildBrowseFrameContainerButton"..i]
		F.CreateBD(bu, .25)
		bu:SetHighlightTexture("")
		bu:GetRegions():SetTexture(C.media.backdrop)
		bu:GetRegions():SetVertexColor(r, g, b, .2)
	end
	for i = 1, 9 do
		select(i, LookingForGuildCommentInputFrame:GetRegions()):Hide()
	end
	for i = 1, 3 do
		for j = 1, 6 do
			select(j, _G["LookingForGuildFrameTab"..i]:GetRegions()):Hide()
			select(j, _G["LookingForGuildFrameTab"..i]:GetRegions()).Show = F.dummy
		end
	end
	for i = 1, 6 do
		select(i, GuildFinderRequestMembershipFrameInputFrame:GetRegions()):Hide()
	end
	LookingForGuildFrameTabardBackground:Hide()
	LookingForGuildFrameTabardEmblem:Hide()
	LookingForGuildFrameTabardBorder:Hide()
	LookingForGuildFramePortraitFrame:Hide()
	LookingForGuildFrameTopBorder:Hide()
	LookingForGuildFrameTopRightCorner:Hide()

	for _, roleButton in pairs({LookingForGuildTankButton, LookingForGuildHealerButton, LookingForGuildDamagerButton}) do
		roleButton.cover:SetTexture(C.media.roleIcons)
		roleButton:SetNormalTexture(C.media.roleIcons)

		roleButton.checkButton:SetFrameLevel(roleButton:GetFrameLevel() + 2)

		local left = roleButton:CreateTexture()
		left:SetDrawLayer("OVERLAY", 1)
		left:SetWidth(1)
		left:SetTexture(C.media.backdrop)
		left:SetVertexColor(0, 0, 0)
		left:SetPoint("TOPLEFT", 5, -4)
		left:SetPoint("BOTTOMLEFT", 5, 6)

		local right = roleButton:CreateTexture()
		right:SetDrawLayer("OVERLAY", 1)
		right:SetWidth(1)
		right:SetTexture(C.media.backdrop)
		right:SetVertexColor(0, 0, 0)
		right:SetPoint("TOPRIGHT", -5, -4)
		right:SetPoint("BOTTOMRIGHT", -5, 6)

		local top = roleButton:CreateTexture()
		top:SetDrawLayer("OVERLAY", 1)
		top:SetHeight(1)
		top:SetTexture(C.media.backdrop)
		top:SetVertexColor(0, 0, 0)
		top:SetPoint("TOPLEFT", 5, -4)
		top:SetPoint("TOPRIGHT", -5, -4)

		local bottom = roleButton:CreateTexture()
		bottom:SetDrawLayer("OVERLAY", 1)
		bottom:SetHeight(1)
		bottom:SetTexture(C.media.backdrop)
		bottom:SetVertexColor(0, 0, 0)
		bottom:SetPoint("BOTTOMLEFT", 5, 6)
		bottom:SetPoint("BOTTOMRIGHT", -5, 6)

		F.ReskinCheck(roleButton.checkButton)
	end

	F.Reskin(LookingForGuildBrowseButton)
	F.Reskin(LookingForGuildRequestButton)
	F.Reskin(GuildFinderRequestMembershipFrameAcceptButton)
	F.Reskin(GuildFinderRequestMembershipFrameCancelButton)

	F.ReskinScroll(LookingForGuildBrowseFrameContainerScrollBar)
	F.ReskinClose(LookingForGuildFrameCloseButton)
	F.ReskinCheck(LookingForGuildQuestButton)
	F.ReskinCheck(LookingForGuildDungeonButton)
	F.ReskinCheck(LookingForGuildRaidButton)
	F.ReskinCheck(LookingForGuildPvPButton)
	F.ReskinCheck(LookingForGuildRPButton)
	F.ReskinCheck(LookingForGuildWeekdaysButton)
	F.ReskinCheck(LookingForGuildWeekendsButton)
	F.ReskinInput(GuildFinderRequestMembershipFrameInputFrame)
end