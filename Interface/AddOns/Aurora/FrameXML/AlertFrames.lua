local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	if C.isBetaClient then return end
	-- Achievement alert
	local function fixBg(f)
		if f:GetObjectType() == "AnimationGroup" then
			f = f:GetParent()
		end
		f.bg:SetBackdropColor(0, 0, 0, AuroraConfig.alpha)
	end

	hooksecurefunc("AlertFrame_FixAnchors", function()
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["AchievementAlertFrame"..i]

			if frame then
				frame:SetAlpha(1)
				frame.SetAlpha = F.dummy

				local ic = _G["AchievementAlertFrame"..i.."Icon"]
				local texture = _G["AchievementAlertFrame"..i.."IconTexture"]
				local guildName = _G["AchievementAlertFrame"..i.."GuildName"]

				ic:ClearAllPoints()
				ic:SetPoint("LEFT", frame, "LEFT", -26, 0)

				if not frame.bg then
					frame.bg = CreateFrame("Frame", nil, frame)
					frame.bg:SetPoint("TOPLEFT", texture, -10, 12)
					frame.bg:SetPoint("BOTTOMRIGHT", texture, "BOTTOMRIGHT", 240, -12)
					frame.bg:SetFrameLevel(frame:GetFrameLevel()-1)
					F.CreateBD(frame.bg)

					frame:HookScript("OnEnter", fixBg)
					frame:HookScript("OnShow", fixBg)
					frame.animIn:HookScript("OnFinished", fixBg)
					F.CreateBD(frame.bg)

					F.CreateBG(texture)

					_G["AchievementAlertFrame"..i.."Background"]:Hide()
					_G["AchievementAlertFrame"..i.."IconOverlay"]:Hide()
					_G["AchievementAlertFrame"..i.."GuildBanner"]:SetTexture("")
					_G["AchievementAlertFrame"..i.."GuildBorder"]:SetTexture("")
					_G["AchievementAlertFrame"..i.."OldAchievement"]:SetTexture("")

					guildName:ClearAllPoints()
					guildName:SetPoint("TOPLEFT", 50, -14)
					guildName:SetPoint("TOPRIGHT", -50, -14)

					_G["AchievementAlertFrame"..i.."Unlocked"]:SetTextColor(1, 1, 1)
					_G["AchievementAlertFrame"..i.."Unlocked"]:SetShadowOffset(1, -1)
				end

				frame.glow:Hide()
				frame.shine:Hide()
				frame.glow.Show = F.dummy
				frame.shine.Show = F.dummy

				texture:SetTexCoord(.08, .92, .08, .92)

				if guildName:IsShown() then
					_G["AchievementAlertFrame"..i.."Shield"]:SetPoint("TOPRIGHT", -10, -22)
				end
			end
		end
	end)

	-- Guild challenges

	local challenge = CreateFrame("Frame", nil, GuildChallengeAlertFrame)
	challenge:SetPoint("TOPLEFT", 8, -12)
	challenge:SetPoint("BOTTOMRIGHT", -8, 13)
	challenge:SetFrameLevel(GuildChallengeAlertFrame:GetFrameLevel()-1)
	F.CreateBD(challenge)
	F.CreateBG(GuildChallengeAlertFrameEmblemBackground)

	GuildChallengeAlertFrameGlow:SetTexture("")
	GuildChallengeAlertFrameShine:SetTexture("")
	GuildChallengeAlertFrameEmblemBorder:SetTexture("")

	-- Dungeon completion rewards

	local bg = CreateFrame("Frame", nil, DungeonCompletionAlertFrame1)
	bg:SetPoint("TOPLEFT", 6, -14)
	bg:SetPoint("BOTTOMRIGHT", -6, 6)
	bg:SetFrameLevel(DungeonCompletionAlertFrame1:GetFrameLevel()-1)
	F.CreateBD(bg)

	DungeonCompletionAlertFrame1DungeonTexture:SetDrawLayer("ARTWORK")
	DungeonCompletionAlertFrame1DungeonTexture:SetTexCoord(.02, .98, .02, .98)
	F.CreateBG(DungeonCompletionAlertFrame1DungeonTexture)

	DungeonCompletionAlertFrame1.dungeonArt1:SetAlpha(0)
	DungeonCompletionAlertFrame1.dungeonArt2:SetAlpha(0)
	DungeonCompletionAlertFrame1.dungeonArt3:SetAlpha(0)
	DungeonCompletionAlertFrame1.dungeonArt4:SetAlpha(0)
	DungeonCompletionAlertFrame1.raidArt:SetAlpha(0)

	DungeonCompletionAlertFrame1.dungeonTexture:SetPoint("BOTTOMLEFT", DungeonCompletionAlertFrame1, "BOTTOMLEFT", 13, 13)
	DungeonCompletionAlertFrame1.dungeonTexture.SetPoint = F.dummy

	DungeonCompletionAlertFrame1.shine:Hide()
	DungeonCompletionAlertFrame1.shine.Show = F.dummy
	DungeonCompletionAlertFrame1.glow:Hide()
	DungeonCompletionAlertFrame1.glow.Show = F.dummy

	hooksecurefunc("DungeonCompletionAlertFrame_ShowAlert", function()
		local bu = DungeonCompletionAlertFrame1Reward1
		local index = 1

		while bu do
			if not bu.styled then
				_G["DungeonCompletionAlertFrame1Reward"..index.."Border"]:Hide()

				bu.texture:SetTexCoord(.08, .92, .08, .92)
				F.CreateBG(bu.texture)

				bu.styled = true
			end

			index = index + 1
			bu = _G["DungeonCompletionAlertFrame1Reward"..index]
		end
	end)

	-- Challenge popup

	hooksecurefunc("AlertFrame_SetChallengeModeAnchors", function()
		local frame = ChallengeModeAlertFrame1

		if frame then
			frame:SetAlpha(1)
			frame.SetAlpha = F.dummy

			if not frame.bg then
				frame.bg = CreateFrame("Frame", nil, frame)
				frame.bg:SetPoint("TOPLEFT", ChallengeModeAlertFrame1DungeonTexture, -12, 12)
				frame.bg:SetPoint("BOTTOMRIGHT", ChallengeModeAlertFrame1DungeonTexture, 243, -12)
				frame.bg:SetFrameLevel(frame:GetFrameLevel()-1)
				F.CreateBD(frame.bg)

				frame:HookScript("OnEnter", fixBg)
				frame:HookScript("OnShow", fixBg)
				frame.animIn:HookScript("OnFinished", fixBg)

				F.CreateBG(ChallengeModeAlertFrame1DungeonTexture)
			end

			frame:GetRegions():Hide()

			ChallengeModeAlertFrame1Shine:Hide()
			ChallengeModeAlertFrame1Shine.Show = F.dummy
			ChallengeModeAlertFrame1GlowFrame:Hide()
			ChallengeModeAlertFrame1GlowFrame.Show = F.dummy
			ChallengeModeAlertFrame1Border:Hide()
			ChallengeModeAlertFrame1Border.Show = F.dummy

			ChallengeModeAlertFrame1DungeonTexture:SetTexCoord(.08, .92, .08, .92)
		end
	end)

	-- Scenario alert

	hooksecurefunc("AlertFrame_SetScenarioAnchors", function()
		local frame = ScenarioAlertFrame1

		if frame then
			frame:SetAlpha(1)
			frame.SetAlpha = F.dummy

			if not frame.bg then
				frame.bg = CreateFrame("Frame", nil, frame)
				frame.bg:SetPoint("TOPLEFT", ScenarioAlertFrame1DungeonTexture, -12, 12)
				frame.bg:SetPoint("BOTTOMRIGHT", ScenarioAlertFrame1DungeonTexture, 244, -12)
				frame.bg:SetFrameLevel(frame:GetFrameLevel()-1)
				F.CreateBD(frame.bg)

				frame:HookScript("OnEnter", fixBg)
				frame:HookScript("OnShow", fixBg)
				frame.animIn:HookScript("OnFinished", fixBg)

				F.CreateBG(ScenarioAlertFrame1DungeonTexture)
				ScenarioAlertFrame1DungeonTexture:SetDrawLayer("OVERLAY")
			end

			frame:GetRegions():Hide()
			select(3, frame:GetRegions()):Hide()

			ScenarioAlertFrame1Shine:Hide()
			ScenarioAlertFrame1Shine.Show = F.dummy
			ScenarioAlertFrame1GlowFrame:Hide()
			ScenarioAlertFrame1GlowFrame.Show = F.dummy

			ScenarioAlertFrame1DungeonTexture:SetTexCoord(.08, .92, .08, .92)
		end
	end)

	hooksecurefunc("ScenarioAlertFrame_ShowAlert", function()
		local bu = ScenarioAlertFrame1Reward1
		local index = 1

		while bu do
			if not bu.styled then
				_G["ScenarioAlertFrame1Reward"..index.."Border"]:Hide()

				bu.texture:SetTexCoord(.08, .92, .08, .92)
				F.CreateBG(bu.texture)

				bu.styled = true
			end

			index = index + 1
			bu = _G["ScenarioAlertFrame1Reward"..index]
		end
	end)

	-- Loot won alert

	-- I still don't know why I can't parent bg to frame
	local function showHideBg(self)
		self.bg:SetShown(self:IsShown())
	end

	local function onUpdate(self)
		self.bg:SetAlpha(self:GetAlpha())
	end

	hooksecurefunc("LootWonAlertFrame_SetUp", function(frame)
		if not frame.bg then
			frame.bg = CreateFrame("Frame", nil, UIParent)
			frame.bg:SetPoint("TOPLEFT", frame, 10, -10)
			frame.bg:SetPoint("BOTTOMRIGHT", frame, -10, 10)
			frame.bg:SetFrameStrata("DIALOG")
			frame.bg:SetFrameLevel(frame:GetFrameLevel()-1)
			frame.bg:SetShown(frame:IsShown())
			F.CreateBD(frame.bg)

			frame:HookScript("OnShow", showHideBg)
			frame:HookScript("OnHide", showHideBg)
			frame:HookScript("OnUpdate", onUpdate)

			frame.shine:SetTexture("")
			frame.SpecRing:SetTexture("")

			frame.Icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBG(frame.Icon)

			frame.SpecIcon:SetTexCoord(.08, .92, .08, .92)
			frame.SpecIcon.bg = F.CreateBG(frame.SpecIcon)
			frame.SpecIcon.bg:SetDrawLayer("BORDER", 2)
		end

		frame.Background:Hide()
		frame.IconBorder:Hide()
		frame.glow:SetTexture("")
		frame.PvPBackground:Hide()
		frame.BGAtlas:Hide()

		frame.Icon:SetDrawLayer("BORDER")
		frame.SpecIcon.bg:SetShown(frame.SpecIcon:IsShown() and frame.SpecIcon:GetTexture() ~= nil) -- sometimes appears when it shouldn't
	end)

	-- Money won alert

	hooksecurefunc("MoneyWonAlertFrame_SetUp", function(frame)
		if not frame.bg then
			frame.bg = CreateFrame("Frame", nil, UIParent)
			frame.bg:SetPoint("TOPLEFT", frame, 10, -10)
			frame.bg:SetPoint("BOTTOMRIGHT", frame, -10, 10)
			frame.bg:SetFrameStrata("DIALOG")
			frame.bg:SetFrameLevel(frame:GetFrameLevel()-1)
			frame.bg:SetShown(frame:IsShown())
			F.CreateBD(frame.bg)

			frame:HookScript("OnShow", showHideBg)
			frame:HookScript("OnHide", showHideBg)
			frame:HookScript("OnUpdate", onUpdate)

			frame.Background:Hide()
			frame.IconBorder:Hide()

			frame.Icon:SetTexCoord(.08, .92, .08, .92)
			F.CreateBG(frame.Icon)
		end
	end)

	-- Criteria alert

	hooksecurefunc("CriteriaAlertFrame_ShowAlert", function()
		for i = 1, MAX_ACHIEVEMENT_ALERTS do
			local frame = _G["CriteriaAlertFrame"..i]
			if frame and not frame.bg then
				local icon = _G["CriteriaAlertFrame"..i.."IconTexture"]

				frame.bg = CreateFrame("Frame", nil, UIParent)
				frame.bg:SetPoint("TOPLEFT", icon, -6, 5)
				frame.bg:SetPoint("BOTTOMRIGHT", icon, 236, -5)
				frame.bg:SetFrameStrata("DIALOG")
				frame.bg:SetFrameLevel(frame:GetFrameLevel()-1)
				frame.bg:SetShown(frame:IsShown())
				F.CreateBD(frame.bg)

				frame:SetScript("OnShow", showHideBg)
				frame:SetScript("OnHide", showHideBg)
				frame:HookScript("OnUpdate", onUpdate)

				_G["CriteriaAlertFrame"..i.."Background"]:Hide()
				_G["CriteriaAlertFrame"..i.."IconOverlay"]:Hide()
				frame.glow:Hide()
				frame.glow.Show = F.dummy
				frame.shine:Hide()
				frame.shine.Show = F.dummy

				_G["CriteriaAlertFrame"..i.."Unlocked"]:SetTextColor(.9, .9, .9)

				icon:SetTexCoord(.08, .92, .08, .92)
				F.CreateBG(icon)
			end
		end
	end)

	-- Digsite completion alert

	do
		local frame = DigsiteCompleteToastFrame
		local icon = frame.DigsiteTypeTexture

		F.CreateBD(frame)

		frame:GetRegions():Hide()

		frame.glow:Hide()
		frame.glow.Show = F.dummy
		frame.shine:Hide()
		frame.shine.Show = F.dummy
	end

	-- Garrison building alert

	do
		local frame = GarrisonBuildingAlertFrame
		local icon = frame.Icon

		frame:GetRegions():Hide()
		frame.glow:SetTexture("")
		frame.shine:SetTexture("")

		local bg = CreateFrame("Frame", nil, frame)
		bg:SetPoint("TOPLEFT", 8, -8)
		bg:SetPoint("BOTTOMRIGHT", -8, 10)
		bg:SetFrameLevel(frame:GetFrameLevel()-1)
		F.CreateBD(bg)

		icon:SetTexCoord(.08, .92, .08, .92)
		icon:SetDrawLayer("ARTWORK")
		F.CreateBG(icon)
	end

	-- Garrison mission alert

	do
		local frame = GarrisonMissionAlertFrame

		frame.Background:Hide()
		frame.IconBG:Hide()
		frame.glow:SetTexture("")
		frame.shine:SetTexture("")

		local bg = CreateFrame("Frame", nil, frame)
		bg:SetPoint("TOPLEFT", 8, -8)
		bg:SetPoint("BOTTOMRIGHT", -8, 10)
		bg:SetFrameLevel(frame:GetFrameLevel()-1)
		F.CreateBD(bg)
	end

	-- Garrison shipyard mission alert

	do
		local frame = GarrisonShipMissionAlertFrame

		frame.Background:Hide()
		frame.glow:SetTexture("")
		frame.shine:SetTexture("")

		local bg = CreateFrame("Frame", nil, frame)
		bg:SetPoint("TOPLEFT", 8, -8)
		bg:SetPoint("BOTTOMRIGHT", -8, 10)
		bg:SetFrameLevel(frame:GetFrameLevel()-1)
		F.CreateBD(bg)
	end

	-- Garrison follower alert

	do
		local frame = GarrisonFollowerAlertFrame

		frame:GetRegions():Hide()
		frame.FollowerBG:SetAlpha(0)
		frame.glow:SetTexture("")
		frame.shine:SetTexture("")

		local bg = CreateFrame("Frame", nil, frame)
		bg:SetPoint("TOPLEFT", 16, -3)
		bg:SetPoint("BOTTOMRIGHT", -16, 16)
		bg:SetFrameLevel(frame:GetFrameLevel()-1)
		F.CreateBD(bg)

		F.ReskinGarrisonPortrait(frame.PortraitFrame)
	end

	hooksecurefunc("GarrisonFollowerAlertFrame_ShowAlert", function(_, _, _, _, quality)
		local color = BAG_ITEM_QUALITY_COLORS[quality]
		if color then
			GarrisonFollowerAlertFrame.PortraitFrame.squareBG:SetBackdropBorderColor(color.r, color.g, color.b)
		else
			GarrisonFollowerAlertFrame.PortraitFrame.squareBG:SetBackdropBorderColor(0, 0, 0)
		end
	end)

	-- Loot upgrade alert

	hooksecurefunc("LootUpgradeFrame_SetUp", function(frame)
		if not frame.bg then
			local bg = CreateFrame("Frame", nil, frame)
			bg:SetPoint("TOPLEFT", 10, -10)
			bg:SetPoint("BOTTOMRIGHT", -10, 10)
			bg:SetFrameLevel(frame:GetFrameLevel()-1)
			F.CreateBD(bg)
			frame.bg = bg

			frame.Background:Hide()

			F.ReskinIcon(frame.Icon)
			frame.Icon:SetDrawLayer("BORDER", 5)
			frame.Icon:ClearAllPoints()
			frame.Icon:SetPoint("CENTER", frame.BaseQualityBorder)
		end

		frame.BaseQualityBorder:SetTexture(C.media.backdrop)
		frame.UpgradeQualityBorder:SetTexture(C.media.backdrop)
		frame.BaseQualityBorder:SetSize(52, 52)
		frame.UpgradeQualityBorder:SetSize(52, 52)
		frame.BaseQualityBorder:SetVertexColor(frame.BaseQualityItemName:GetTextColor())
		frame.UpgradeQualityBorder:SetVertexColor(frame.UpgradeQualityItemName:GetTextColor())
	end)
end)
