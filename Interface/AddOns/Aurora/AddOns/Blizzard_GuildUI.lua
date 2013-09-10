local F, C = unpack(select(2, ...))

C.modules["Blizzard_GuildUI"] = function()
	local r, g, b = C.r, C.g, C.b

	F.ReskinPortraitFrame(GuildFrame, true)
	F.CreateBD(GuildMemberDetailFrame)
	F.CreateBD(GuildMemberNoteBackground, .25)
	F.CreateBD(GuildMemberOfficerNoteBackground, .25)
	F.CreateBD(GuildLogFrame)
	F.CreateBD(GuildLogContainer, .25)
	F.CreateBD(GuildNewsFiltersFrame)
	F.CreateBD(GuildTextEditFrame)
	F.CreateBD(GuildTextEditContainer, .25)
	F.CreateBD(GuildRecruitmentInterestFrame, .25)
	F.CreateBD(GuildRecruitmentAvailabilityFrame, .25)
	F.CreateBD(GuildRecruitmentRolesFrame, .25)
	F.CreateBD(GuildRecruitmentLevelFrame, .25)
	for i = 1, 5 do
		F.ReskinTab(_G["GuildFrameTab"..i])
	end
	GuildFrameTabardBackground:Hide()
	GuildFrameTabardEmblem:Hide()
	GuildFrameTabardBorder:Hide()
	select(5, GuildInfoFrameInfo:GetRegions()):Hide()
	select(11, GuildMemberDetailFrame:GetRegions()):Hide()
	GuildMemberDetailCorner:Hide()
	for i = 1, 9 do
		select(i, GuildLogFrame:GetRegions()):Hide()
		select(i, GuildNewsFiltersFrame:GetRegions()):Hide()
		select(i, GuildTextEditFrame:GetRegions()):Hide()
	end
	select(2, GuildNewPerksFrame:GetRegions()):Hide()
	select(3, GuildNewPerksFrame:GetRegions()):Hide()
	GuildAllPerksFrame:GetRegions():Hide()
	GuildNewsFrame:GetRegions():Hide()
	GuildRewardsFrame:GetRegions():Hide()
	GuildNewsBossModelShadowOverlay:Hide()
	GuildPerksToggleButtonLeft:Hide()
	GuildPerksToggleButtonMiddle:Hide()
	GuildPerksToggleButtonRight:Hide()
	GuildPerksToggleButtonHighlightLeft:Hide()
	GuildPerksToggleButtonHighlightMiddle:Hide()
	GuildPerksToggleButtonHighlightRight:Hide()
	GuildNewPerksFrameHeader1:SetAlpha(0)
	GuildInfoFrameInfoHeader1:SetAlpha(0)
	GuildInfoFrameInfoHeader2:SetAlpha(0)
	GuildInfoFrameInfoHeader3:SetAlpha(0)
	select(9, GuildInfoFrameInfo:GetRegions()):Hide()
	GuildRecruitmentCommentInputFrameTop:Hide()
	GuildRecruitmentCommentInputFrameTopLeft:Hide()
	GuildRecruitmentCommentInputFrameTopRight:Hide()
	GuildRecruitmentCommentInputFrameBottom:Hide()
	GuildRecruitmentCommentInputFrameBottomLeft:Hide()
	GuildRecruitmentCommentInputFrameBottomRight:Hide()
	GuildRecruitmentInterestFrameBg:Hide()
	GuildRecruitmentAvailabilityFrameBg:Hide()
	GuildRecruitmentRolesFrameBg:Hide()
	GuildRecruitmentLevelFrameBg:Hide()
	GuildRecruitmentCommentFrameBg:Hide()
	GuildNewsFrameHeader:SetAlpha(0)

	GuildFrameBottomInset:DisableDrawLayer("BACKGROUND")
	GuildFrameBottomInset:DisableDrawLayer("BORDER")
	GuildInfoFrameInfoBar1Left:SetAlpha(0)
	GuildInfoFrameInfoBar2Left:SetAlpha(0)
	select(2, GuildInfoFrameInfo:GetRegions()):SetAlpha(0)
	select(4, GuildInfoFrameInfo:GetRegions()):SetAlpha(0)
	GuildRosterColumnButton1:DisableDrawLayer("BACKGROUND")
	GuildRosterColumnButton2:DisableDrawLayer("BACKGROUND")
	GuildRosterColumnButton3:DisableDrawLayer("BACKGROUND")
	GuildRosterColumnButton4:DisableDrawLayer("BACKGROUND")
	GuildNewsBossModel:DisableDrawLayer("BACKGROUND")
	GuildNewsBossModel:DisableDrawLayer("OVERLAY")
	GuildNewsBossNameText:SetDrawLayer("ARTWORK")
	GuildNewsBossModelTextFrame:DisableDrawLayer("BACKGROUND")
	for i = 2, 6 do
		select(i, GuildNewsBossModelTextFrame:GetRegions()):Hide()
	end

	GuildMemberRankDropdown:HookScript("OnShow", function()
		GuildMemberDetailRankText:Hide()
	end)
	GuildMemberRankDropdown:HookScript("OnHide", function()
		GuildMemberDetailRankText:Show()
	end)

	hooksecurefunc("GuildNews_Update", function()
		local buttons = GuildNewsContainer.buttons
		for i = 1, #buttons do
			buttons[i].header:SetAlpha(0)
		end
	end)

	F.ReskinClose(GuildNewsFiltersFrameCloseButton)
	F.ReskinClose(GuildLogFrameCloseButton)
	F.ReskinClose(GuildMemberDetailCloseButton)
	F.ReskinClose(GuildTextEditFrameCloseButton)
	F.ReskinScroll(GuildPerksContainerScrollBar)
	F.ReskinScroll(GuildRosterContainerScrollBar)
	F.ReskinScroll(GuildNewsContainerScrollBar)
	F.ReskinScroll(GuildRewardsContainerScrollBar)
	F.ReskinScroll(GuildInfoDetailsFrameScrollBar)
	F.ReskinScroll(GuildLogScrollFrameScrollBar)
	F.ReskinScroll(GuildTextEditScrollFrameScrollBar)
	F.ReskinScroll(GuildInfoFrameApplicantsContainerScrollBar)
	F.ReskinDropDown(GuildRosterViewDropdown)
	F.ReskinDropDown(GuildMemberRankDropdown)
	F.ReskinInput(GuildRecruitmentCommentInputFrame)
	GuildRecruitmentCommentInputFrame:SetWidth(312)
	GuildRecruitmentCommentEditBox:SetWidth(284)
	GuildRecruitmentCommentFrame:ClearAllPoints()
	GuildRecruitmentCommentFrame:SetPoint("TOPLEFT", GuildRecruitmentLevelFrame, "BOTTOMLEFT", 0, 1)
	F.ReskinCheck(GuildRosterShowOfflineButton)
	for i = 1, 7 do
		F.ReskinCheck(_G["GuildNewsFilterButton"..i])
	end

	local a1, p, a2, x, y = GuildNewsBossModel:GetPoint()
	GuildNewsBossModel:ClearAllPoints()
	GuildNewsBossModel:SetPoint(a1, p, a2, x+5, y)

	local f = CreateFrame("Frame", nil, GuildNewsBossModel)
	f:SetPoint("TOPLEFT", 0, 1)
	f:SetPoint("BOTTOMRIGHT", 1, -52)
	f:SetFrameLevel(GuildNewsBossModel:GetFrameLevel()-1)
	F.CreateBD(f)

	local line = CreateFrame("Frame", nil, GuildNewsBossModel)
	line:SetPoint("BOTTOMLEFT", 0, -1)
	line:SetPoint("BOTTOMRIGHT", 0, -1)
	line:SetHeight(1)
	line:SetFrameLevel(GuildNewsBossModel:GetFrameLevel()-1)
	F.CreateBD(line, 0)

	GuildNewsFiltersFrame:SetWidth(224)
	GuildNewsFiltersFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 1, -20)
	GuildMemberDetailFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 1, -28)
	GuildLogFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 1, 0)
	GuildTextEditFrame:SetPoint("TOPLEFT", GuildFrame, "TOPRIGHT", 1, 0)

	for i = 1, 5 do
		local bu = _G["GuildInfoFrameApplicantsContainerButton"..i]
		F.CreateBD(bu, .25)
		bu:SetHighlightTexture("")
		bu:GetRegions():SetTexture(C.media.backdrop)
		bu:GetRegions():SetVertexColor(r, g, b, .2)
	end

	GuildFactionBarProgress:SetTexture(C.media.backdrop)
	GuildFactionBarLeft:Hide()
	GuildFactionBarMiddle:Hide()
	GuildFactionBarRight:Hide()
	GuildFactionBarShadow:SetAlpha(0)
	GuildFactionBarBG:Hide()
	GuildFactionBarCap:SetAlpha(0)
	GuildFactionBar.bg = CreateFrame("Frame", nil, GuildFactionFrame)
	GuildFactionBar.bg:SetPoint("TOPLEFT", GuildFactionFrame, -1, -1)
	GuildFactionBar.bg:SetPoint("BOTTOMRIGHT", GuildFactionFrame, -3, 0)
	GuildFactionBar.bg:SetFrameLevel(0)
	F.CreateBD(GuildFactionBar.bg, .25)

	GuildXPFrame:ClearAllPoints()
	GuildXPFrame:SetPoint("TOP", GuildFrame, "TOP", 0, -40)
	GuildXPBarProgress:SetTexture(C.media.backdrop)
	GuildXPBarLeft:SetAlpha(0)
	GuildXPBarRight:SetAlpha(0)
	GuildXPBarMiddle:SetAlpha(0)
	GuildXPBarBG:SetAlpha(0)
	GuildXPBarShadow:SetAlpha(0)
	GuildXPBarShadow:SetAlpha(0)
	GuildXPBarCap:SetAlpha(0)
	GuildXPBarDivider1:Hide()
	GuildXPBarDivider2:Hide()
	GuildXPBarDivider3:Hide()
	GuildXPBarDivider4:Hide()
	GuildXPBar.bg = CreateFrame("Frame", nil, GuildXPBar)
	GuildXPBar.bg:SetPoint("TOPLEFT", GuildXPBar, 0, -3)
	GuildXPBar.bg:SetPoint("BOTTOMRIGHT", GuildXPBar, 0, 1)
	GuildXPBar.bg:SetFrameLevel(0)
	F.CreateBD(GuildXPBar.bg, .25)

	local perkbuttons = {"GuildLatestPerkButton", "GuildNextPerkButton"}
	for _, button in pairs(perkbuttons) do
		local bu = _G[button]
		local ic = _G[button.."IconTexture"]
		local na = _G[button.."NameFrame"]

		na:SetAlpha(0)
		ic:SetTexCoord(.08, .92, .08, .92)
		ic:SetDrawLayer("OVERLAY")
		F.CreateBG(ic)

		bu.bg = CreateFrame("Frame", nil, bu)
		bu.bg:SetPoint("TOPLEFT", 0, -1)
		bu.bg:SetPoint("BOTTOMRIGHT", 0, 2)
		bu.bg:SetFrameLevel(0)
		F.CreateBD(bu.bg, .25)
	end

	select(5, GuildLatestPerkButton:GetRegions()):Hide()
	select(6, GuildLatestPerkButton:GetRegions()):Hide()

	for _, bu in pairs(GuildPerksContainer.buttons) do
		bu.DisableDrawLayer = F.dummy

		for i = 1, 6 do
			select(i, bu:GetRegions()):SetAlpha(0)
		end

		bu.icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(bu.icon)
	end

	GuildPerksContainerButton1:SetPoint("LEFT", -1, 0)

	for _, bu in pairs(GuildRewardsContainer.buttons) do
		local nt = bu:GetNormalTexture()

		bu:SetHighlightTexture("")
		bu.disabledBG:SetTexture("")

		local bg = CreateFrame("Frame", nil, bu)
		bg:SetPoint("TOPLEFT", 0, -1)
		bg:SetPoint("BOTTOMRIGHT")
		F.CreateBD(bg, 0)

		nt:SetTexture(C.media.backdrop)
		nt:SetVertexColor(0, 0, 0, .25)
		nt:SetPoint("TOPLEFT", 0, -1)
		nt:SetPoint("BOTTOMRIGHT", 0, 1)

		bu.icon:SetTexCoord(.08, .92, .08, .92)
		F.CreateBG(bu.icon)
	end

	local tcoords = {
		["WARRIOR"]     = {0.02, 0.23, 0.02, 0.23},
		["MAGE"]        = {0.27, 0.47609375, 0.02, 0.23},
		["ROGUE"]       = {0.51609375, 0.7221875, 0.02, 0.23},
		["DRUID"]       = {0.7621875, 0.96828125, 0.02, 0.23},
		["HUNTER"]      = {0.02, 0.23, 0.27, 0.48},
		["SHAMAN"]      = {0.27, 0.47609375, 0.27, 0.48},
		["PRIEST"]      = {0.51609375, 0.7221875, 0.27, 0.48},
		["WARLOCK"]     = {0.7621875, 0.96828125, 0.27, 0.48},
		["PALADIN"]     = {0.02, 0.23, 0.52, 0.73},
		["DEATHKNIGHT"] = {0.27, .48, 0.52, .73},
		["MONK"]		= {0.52, 0.71828125, 0.52, .73},
	}

	local UpdateIcons = function()
		local index
		local offset = HybridScrollFrame_GetOffset(GuildRosterContainer)
		local totalMembers, onlineMembers, onlineAndMobileMembers = GetNumGuildMembers()
		local visibleMembers = onlineAndMobileMembers
		local numbuttons = #GuildRosterContainer.buttons
		if GetGuildRosterShowOffline() then
			visibleMembers = totalMembers
		end

		for i = 1, numbuttons do
			local bu = GuildRosterContainer.buttons[i]

			if not bu.bg then
				bu:SetHighlightTexture(C.media.backdrop)
				bu:GetHighlightTexture():SetVertexColor(r, g, b, .2)

				bu.bg = F.CreateBG(bu.icon)
			end

			index = offset + i
			local name, _, _, _, _, _, _, _, _, _, classFileName  = GetGuildRosterInfo(index)
			if name and index <= visibleMembers and bu.icon:IsShown() then
				bu.icon:SetTexCoord(unpack(tcoords[classFileName]))
				bu.bg:Show()
			else
				bu.bg:Hide()
			end
		end
	end

	hooksecurefunc("GuildRoster_Update", UpdateIcons)
	hooksecurefunc(GuildRosterContainer, "update", UpdateIcons)

	GuildLevelFrame:SetAlpha(0)
	local closebutton = select(4, GuildTextEditFrame:GetChildren())
	F.Reskin(closebutton)
	local logbutton = select(3, GuildLogFrame:GetChildren())
	F.Reskin(logbutton)
	local gbuttons = {"GuildAddMemberButton", "GuildViewLogButton", "GuildControlButton", "GuildTextEditFrameAcceptButton", "GuildMemberGroupInviteButton", "GuildMemberRemoveButton", "GuildRecruitmentInviteButton", "GuildRecruitmentMessageButton", "GuildRecruitmentDeclineButton", "GuildPerksToggleButton", "GuildRecruitmentListGuildButton"}
	for i = 1, #gbuttons do
		F.Reskin(_G[gbuttons[i]])
	end

	local checkboxes = {"GuildRecruitmentQuestButton", "GuildRecruitmentDungeonButton", "GuildRecruitmentRaidButton", "GuildRecruitmentPvPButton", "GuildRecruitmentRPButton", "GuildRecruitmentWeekdaysButton", "GuildRecruitmentWeekendsButton"}
	for i = 1, #checkboxes do
		F.ReskinCheck(_G[checkboxes[i]])
	end

	F.ReskinCheck(GuildRecruitmentTankButton:GetChildren())
	F.ReskinCheck(GuildRecruitmentHealerButton:GetChildren())
	F.ReskinCheck(GuildRecruitmentDamagerButton:GetChildren())

	F.ReskinRadio(GuildRecruitmentLevelAnyButton)
	F.ReskinRadio(GuildRecruitmentLevelMaxButton)

	for i = 1, 3 do
		for j = 1, 6 do
			select(j, _G["GuildInfoFrameTab"..i]:GetRegions()):Hide()
			select(j, _G["GuildInfoFrameTab"..i]:GetRegions()).Show = F.dummy
		end
	end
end