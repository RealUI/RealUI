local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	local restyled = false

	InterfaceOptionsFrame:HookScript("OnShow", function()
		if restyled then return end

		InterfaceOptionsFrameCategories:DisableDrawLayer("BACKGROUND")
		InterfaceOptionsFrameAddOns:DisableDrawLayer("BACKGROUND")
		InterfaceOptionsFramePanelContainer:DisableDrawLayer("BORDER")
		InterfaceOptionsFrameTab1TabSpacer:SetAlpha(0)
		for i = 1, 2 do
			_G["InterfaceOptionsFrameTab"..i.."Left"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab"..i.."Middle"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab"..i.."Right"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab"..i.."LeftDisabled"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab"..i.."MiddleDisabled"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab"..i.."RightDisabled"]:SetAlpha(0)
			_G["InterfaceOptionsFrameTab2TabSpacer"..i]:SetAlpha(0)
		end

		F.CreateBD(InterfaceOptionsFrame)
		F.Reskin(InterfaceOptionsFrameDefaults)
		F.Reskin(InterfaceOptionsFrameOkay)
		F.Reskin(InterfaceOptionsFrameCancel)

		InterfaceOptionsFrameOkay:SetPoint("BOTTOMRIGHT", InterfaceOptionsFrameCancel, "BOTTOMLEFT", -1, 0)

		InterfaceOptionsFrameHeader:SetTexture("")
		InterfaceOptionsFrameHeader:ClearAllPoints()
		InterfaceOptionsFrameHeader:SetPoint("TOP", InterfaceOptionsFrame, 0, 0)

		local line = InterfaceOptionsFrame:CreateTexture(nil, "ARTWORK")
		line:SetSize(1, 546)
		line:SetPoint("LEFT", 205, 10)
		if C.isBetaClient then
			line:SetColorTexture(1, 1, 1, .2)
		else
			line:SetTexture(1, 1, 1, .2)
		end

		local checkboxes, dropdowns, sliders
		if C.isBetaClient then
			-- Controls
			checkboxes = {"InterfaceOptionsControlsPanelStickyTargeting", "InterfaceOptionsControlsPanelAutoDismount", "InterfaceOptionsControlsPanelAutoClearAFK", "InterfaceOptionsControlsPanelAutoLootCorpse", "InterfaceOptionsControlsPanelInteractOnLeftClick", "InterfaceOptionsControlsPanelLootAtMouse"}
			for i = 1, #checkboxes do
				F.ReskinCheck(_G[checkboxes[i]])
			end
			F.ReskinDropDown(InterfaceOptionsControlsPanelAutoLootKeyDropDown)

			-- Combat
			checkboxes = {"InterfaceOptionsCombatPanelTargetOfTarget", "InterfaceOptionsCombatPanelFlashLowHealthWarning", "InterfaceOptionsCombatPanelLossOfControl", "InterfaceOptionsCombatPanelAutoSelfCast", "InterfaceOptionsCombatPanelEnableFloatingCombatText"}
			for i = 1, #checkboxes do
				F.ReskinCheck(_G[checkboxes[i]])
			end
			F.ReskinDropDown(InterfaceOptionsCombatPanelFocusCastKeyDropDown)
			F.ReskinDropDown(InterfaceOptionsCombatPanelSelfCastKeyDropDown)
			F.ReskinSlider(InterfaceOptionsCombatPanelSpellAlertOpacitySlider)

			-- Display
			checkboxes = {"InterfaceOptionsDisplayPanelRotateMinimap", "InterfaceOptionsDisplayPanelAJAlerts", "InterfaceOptionsDisplayPanelShowTutorials"}
			for i = 1, #checkboxes do
				F.ReskinCheck(_G[checkboxes[i]])
			end
			dropdowns = {"InterfaceOptionsDisplayPanelOutlineDropDown", "InterfaceOptionsDisplayPanelSelfHighlightDropDown", "InterfaceOptionsDisplayPanelDisplayDropDown", "InterfaceOptionsDisplayPanelChatBubblesDropDown"}
			for i = 1, #dropdowns do
				F.ReskinDropDown(_G[dropdowns[i]])
			end
			F.Reskin(InterfaceOptionsDisplayPanelResetTutorials)

			-- Social
			checkboxes = {"InterfaceOptionsSocialPanelProfanityFilter", "InterfaceOptionsSocialPanelSpamFilter", "InterfaceOptionsSocialPanelGuildMemberAlert", "InterfaceOptionsSocialPanelBlockTrades", "InterfaceOptionsSocialPanelBlockGuildInvites", "InterfaceOptionsSocialPanelBlockChatChannelInvites", "InterfaceOptionsSocialPanelShowAccountAchievments",
						"InterfaceOptionsSocialPanelOnlineFriends", "InterfaceOptionsSocialPanelOfflineFriends", "InterfaceOptionsSocialPanelBroadcasts", "InterfaceOptionsSocialPanelFriendRequests", "InterfaceOptionsSocialPanelShowToastWindow", "InterfaceOptionsSocialPanelEnableTwitter"}
			for i = 1, #checkboxes do
				F.ReskinCheck(_G[checkboxes[i]])
			end
			F.ReskinDropDown(InterfaceOptionsSocialPanelTimestamps)
			F.ReskinDropDown(InterfaceOptionsSocialPanelWhisperMode)
			F.Reskin(InterfaceOptionsSocialPanelTwitterLoginButton)
			F.Reskin(InterfaceOptionsSocialPanelRedockChat)

			-- ActionBars
			checkboxes = {"InterfaceOptionsActionBarsPanelBottomLeft", "InterfaceOptionsActionBarsPanelBottomRight", "InterfaceOptionsActionBarsPanelRight", "InterfaceOptionsActionBarsPanelRightTwo", "InterfaceOptionsActionBarsPanelLockActionBars", "InterfaceOptionsActionBarsPanelAlwaysShowActionBars", "InterfaceOptionsActionBarsPanelCountdownCooldowns"}
			for i = 1, #checkboxes do
				F.ReskinCheck(_G[checkboxes[i]])
			end
			F.ReskinDropDown(InterfaceOptionsActionBarsPanelPickupActionKeyDropDown)

			-- Names
			checkboxes = {"InterfaceOptionsNamesPanelMyName", "InterfaceOptionsNamesPanelNonCombatCreature", "InterfaceOptionsNamesPanelFriendlyPlayerNames", "InterfaceOptionsNamesPanelFriendlyMinions", "InterfaceOptionsNamesPanelEnemyPlayerNames", "InterfaceOptionsNamesPanelEnemyMinions",
						"InterfaceOptionsNamesPanelUnitNameplatesPersonalResource", "InterfaceOptionsNamesPanelUnitNameplatesPersonalResourceOnEnemy", "InterfaceOptionsNamesPanelUnitNameplatesMakeLarger", "InterfaceOptionsNamesPanelUnitNameplatesShowAll", "InterfaceOptionsNamesPanelUnitNameplatesAggroFlash",
						"InterfaceOptionsNamesPanelUnitNameplatesFriendlyMinions", "InterfaceOptionsNamesPanelUnitNameplatesEnemyMinions", "InterfaceOptionsNamesPanelUnitNameplatesEnemyMinus"}
			for i = 1, #checkboxes do
				F.ReskinCheck(_G[checkboxes[i]])
			end
			F.ReskinDropDown(InterfaceOptionsNamesPanelNPCNamesDropDown)
			F.ReskinDropDown(InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown)

			-- Camera
			F.ReskinCheck(InterfaceOptionsCameraPanelWaterCollision)
			F.ReskinDropDown(InterfaceOptionsCameraPanelStyleDropDown)
			F.ReskinSlider(InterfaceOptionsCameraPanelMaxDistanceSlider)
			F.ReskinSlider(InterfaceOptionsCameraPanelFollowSpeedSlider)

			-- Mouse
			checkboxes = {"InterfaceOptionsMousePanelInvertMouse", "InterfaceOptionsMousePanelEnableMouseSpeed", "InterfaceOptionsMousePanelClickToMove"}
			for i = 1, #checkboxes do
				F.ReskinCheck(_G[checkboxes[i]])
			end
			F.ReskinDropDown(InterfaceOptionsMousePanelClickMoveStyleDropDown)
			F.ReskinSlider(InterfaceOptionsMousePanelMouseLookSpeedSlider)
			F.ReskinSlider(InterfaceOptionsMousePanelMouseSensitivitySlider)

			-- Accessibility
			checkboxes = {"InterfaceOptionsAccessibilityPanelMovePad", "InterfaceOptionsAccessibilityPanelCinematicSubtitles", "InterfaceOptionsAccessibilityPanelColorblindMode"}
			for i = 1, #checkboxes do
				F.ReskinCheck(_G[checkboxes[i]])
			end
			F.ReskinDropDown(InterfaceOptionsAccessibilityPanelColorFilterDropDown)
			F.ReskinSlider(InterfaceOptionsAccessibilityPanelColorblindStrengthSlider)
		else
			checkboxes = {"InterfaceOptionsControlsPanelStickyTargeting", "InterfaceOptionsControlsPanelAutoDismount", "InterfaceOptionsControlsPanelAutoClearAFK", "InterfaceOptionsControlsPanelBlockTrades", "InterfaceOptionsControlsPanelBlockGuildInvites", "InterfaceOptionsControlsPanelBlockChatChannelInvites", "InterfaceOptionsControlsPanelLootAtMouse", "InterfaceOptionsControlsPanelAutoLootCorpse", "InterfaceOptionsControlsPanelAutoOpenLootHistory", "InterfaceOptionsControlsPanelInteractOnLeftClick", "InterfaceOptionsControlsPanelReverseCleanUpBags", "InterfaceOptionsControlsPanelReverseNewLoot", "InterfaceOptionsCombatPanelAttackOnAssist", "InterfaceOptionsCombatPanelStopAutoAttack", "InterfaceOptionsNamesPanelUnitNameplatesNameplateClassColors", "InterfaceOptionsCombatPanelTargetOfTarget", "InterfaceOptionsCombatPanelShowSpellAlerts", "InterfaceOptionsCombatPanelReducedLagTolerance", "InterfaceOptionsCombatPanelActionButtonUseKeyDown", "InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait", "InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates", "InterfaceOptionsCombatPanelEnemyCastBarsOnOnlyTargetNameplates", "InterfaceOptionsCombatPanelEnemyCastBarsNameplateSpellNames", "InterfaceOptionsCombatPanelAutoSelfCast", "InterfaceOptionsCombatPanelLossOfControl", "InterfaceOptionsDisplayPanelShowCloak", "InterfaceOptionsDisplayPanelShowHelm", "InterfaceOptionsDisplayPanelShowAggroPercentage", "InterfaceOptionsDisplayPanelPlayAggroSounds", "InterfaceOptionsDisplayPanelShowSpellPointsAvg", "InterfaceOptionsDisplayPanelShowFreeBagSpace", "InterfaceOptionsDisplayPanelCinematicSubtitles", "InterfaceOptionsDisplayPanelRotateMinimap", "InterfaceOptionsDisplayPanelShowAccountAchievments", "InterfaceOptionsObjectivesPanelAutoQuestTracking", "InterfaceOptionsObjectivesPanelMapFade", "InterfaceOptionsSocialPanelProfanityFilter", "InterfaceOptionsSocialPanelSpamFilter", "InterfaceOptionsSocialPanelChatBubbles", "InterfaceOptionsSocialPanelPartyChat", "InterfaceOptionsSocialPanelChatHoverDelay", "InterfaceOptionsSocialPanelGuildMemberAlert", "InterfaceOptionsSocialPanelChatMouseScroll", "InterfaceOptionsSocialPanelEnableTwitter", "InterfaceOptionsSocialPanelWholeChatWindowClickable", "InterfaceOptionsActionBarsPanelBottomLeft", "InterfaceOptionsActionBarsPanelBottomRight", "InterfaceOptionsActionBarsPanelRight", "InterfaceOptionsActionBarsPanelRightTwo", "InterfaceOptionsActionBarsPanelLockActionBars", "InterfaceOptionsActionBarsPanelAlwaysShowActionBars", "InterfaceOptionsActionBarsPanelSecureAbilityToggle", "InterfaceOptionsActionBarsPanelCountdownCooldowns", "InterfaceOptionsNamesPanelMyName", "InterfaceOptionsNamesPanelMinus", "InterfaceOptionsNamesPanelFriendlyPlayerNames", "InterfaceOptionsNamesPanelFriendlyPets", "InterfaceOptionsNamesPanelFriendlyGuardians", "InterfaceOptionsNamesPanelFriendlyTotems", "InterfaceOptionsNamesPanelUnitNameplatesFriends", "InterfaceOptionsNamesPanelUnitNameplatesFriendlyPets", "InterfaceOptionsNamesPanelUnitNameplatesFriendlyGuardians", "InterfaceOptionsNamesPanelUnitNameplatesFriendlyTotems", "InterfaceOptionsNamesPanelGuilds", "InterfaceOptionsNamesPanelGuildTitles", "InterfaceOptionsNamesPanelTitles", "InterfaceOptionsNamesPanelNonCombatCreature", "InterfaceOptionsNamesPanelEnemyPlayerNames", "InterfaceOptionsNamesPanelEnemyPets", "InterfaceOptionsNamesPanelEnemyGuardians", "InterfaceOptionsNamesPanelEnemyTotems", "InterfaceOptionsNamesPanelUnitNameplatesEnemies", "InterfaceOptionsNamesPanelUnitNameplatesEnemyPets", "InterfaceOptionsNamesPanelUnitNameplatesEnemyGuardians", "InterfaceOptionsNamesPanelUnitNameplatesEnemyTotems", "InterfaceOptionsNamesPanelUnitNameplatesEnemyMinus", "InterfaceOptionsCombatTextPanelTargetDamage", "InterfaceOptionsCombatTextPanelPeriodicDamage", "InterfaceOptionsCombatTextPanelPetDamage", "InterfaceOptionsCombatTextPanelHealing", "InterfaceOptionsCombatTextPanelHealingAbsorbTarget", "InterfaceOptionsCombatTextPanelTargetEffects", "InterfaceOptionsCombatTextPanelOtherTargetEffects", "InterfaceOptionsCombatTextPanelEnableFCT", "InterfaceOptionsCombatTextPanelDodgeParryMiss", "InterfaceOptionsCombatTextPanelDamageReduction", "InterfaceOptionsCombatTextPanelRepChanges", "InterfaceOptionsCombatTextPanelReactiveAbilities", "InterfaceOptionsCombatTextPanelFriendlyHealerNames", "InterfaceOptionsCombatTextPanelCombatState", "InterfaceOptionsCombatTextPanelHealingAbsorbSelf", "InterfaceOptionsCombatTextPanelComboPoints", "InterfaceOptionsCombatTextPanelLowManaHealth", "InterfaceOptionsCombatTextPanelEnergyGains", "InterfaceOptionsCombatTextPanelPeriodicEnergyGains", "InterfaceOptionsCombatTextPanelHonorGains", "InterfaceOptionsCombatTextPanelAuras", "InterfaceOptionsCombatTextPanelPetBattle", "InterfaceOptionsStatusTextPanelPlayer", "InterfaceOptionsStatusTextPanelPet", "InterfaceOptionsStatusTextPanelParty", "InterfaceOptionsStatusTextPanelTarget", "InterfaceOptionsStatusTextPanelAlternateResource", "InterfaceOptionsStatusTextPanelXP", "InterfaceOptionsUnitFramePanelPartyPets", "InterfaceOptionsUnitFramePanelArenaEnemyFrames", "InterfaceOptionsUnitFramePanelArenaEnemyCastBar", "InterfaceOptionsUnitFramePanelArenaEnemyPets", "InterfaceOptionsUnitFramePanelFullSizeFocusFrame", "InterfaceOptionsBuffsPanelDispellableDebuffs", "InterfaceOptionsBuffsPanelCastableBuffs", "InterfaceOptionsBuffsPanelConsolidateBuffs", "InterfaceOptionsBuffsPanelShowAllEnemyDebuffs", "InterfaceOptionsBattlenetPanelOnlineFriends", "InterfaceOptionsBattlenetPanelOfflineFriends", "InterfaceOptionsBattlenetPanelBroadcasts", "InterfaceOptionsBattlenetPanelFriendRequests", "InterfaceOptionsBattlenetPanelShowToastWindow", "InterfaceOptionsCameraPanelFollowTerrain", "InterfaceOptionsCameraPanelHeadBob", "InterfaceOptionsCameraPanelWaterCollision", "InterfaceOptionsCameraPanelSmartPivot", "InterfaceOptionsMousePanelInvertMouse", "InterfaceOptionsMousePanelEnableMouseSpeed", "InterfaceOptionsMousePanelClickToMove", "InterfaceOptionsMousePanelWoWMouse", "InterfaceOptionsHelpPanelShowTutorials", "InterfaceOptionsHelpPanelEnhancedTooltips", "InterfaceOptionsHelpPanelShowLuaErrors", "InterfaceOptionsAccessibilityPanelMovePad", "InterfaceOptionsAccessibilityPanelColorblindMode"}
			for i = 1, #checkboxes do
				F.ReskinCheck(_G[checkboxes[i]])
			end

			dropdowns = {"InterfaceOptionsControlsPanelAutoLootKeyDropDown", "InterfaceOptionsCombatPanelFocusCastKeyDropDown", "InterfaceOptionsCombatPanelSelfCastKeyDropDown", "InterfaceOptionsCombatPanelLossOfControlFullDropDown", "InterfaceOptionsCombatPanelLossOfControlSilenceDropDown", "InterfaceOptionsCombatPanelLossOfControlInterruptDropDown", "InterfaceOptionsCombatPanelLossOfControlDisarmDropDown", "InterfaceOptionsCombatPanelLossOfControlRootDropDown", "InterfaceOptionsDisplayPanelOutlineDropDown", "InterfaceOptionsObjectivesPanelQuestSorting", "InterfaceOptionsSocialPanelChatStyle", "InterfaceOptionsSocialPanelTimestamps", "InterfaceOptionsSocialPanelWhisperMode", "InterfaceOptionsSocialPanelBnWhisperMode", "InterfaceOptionsActionBarsPanelPickupActionKeyDropDown", "InterfaceOptionsNamesPanelNPCNamesDropDown", "InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown", "InterfaceOptionsCombatTextPanelTargetModeDropDown", "InterfaceOptionsCombatTextPanelFCTDropDown", "InterfaceOptionsStatusTextPanelDisplayDropDown", "InterfaceOptionsCameraPanelStyleDropDown", "InterfaceOptionsMousePanelClickMoveStyleDropDown", "InterfaceOptionsAccessibilityPanelColorFilterDropDown"}
			for i = 1, #dropdowns do
				F.ReskinDropDown(_G[dropdowns[i]])
			end

			sliders = {"InterfaceOptionsCombatPanelSpellAlertOpacitySlider", "InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset", "InterfaceOptionsBattlenetPanelToastDurationSlider", "InterfaceOptionsCameraPanelMaxDistanceSlider", "InterfaceOptionsCameraPanelFollowSpeedSlider", "InterfaceOptionsMousePanelMouseSensitivitySlider", "InterfaceOptionsMousePanelMouseLookSpeedSlider"}
			for i = 1, #sliders do
				F.ReskinSlider(_G[sliders[i]])
			end

			F.Reskin(InterfaceOptionsHelpPanelResetTutorials)
			F.Reskin(InterfaceOptionsSocialPanelTwitterLoginButton)
		end

		if IsAddOnLoaded("Blizzard_CompactRaidFrames") then
			CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateBG:Hide()

			local boxes = {CompactUnitFrameProfilesRaidStylePartyFrames, CompactUnitFrameProfilesGeneralOptionsFrameKeepGroupsTogether, CompactUnitFrameProfilesGeneralOptionsFrameHorizontalGroups, CompactUnitFrameProfilesGeneralOptionsFrameDisplayIncomingHeals, CompactUnitFrameProfilesGeneralOptionsFrameDisplayPowerBar, CompactUnitFrameProfilesGeneralOptionsFrameDisplayAggroHighlight, CompactUnitFrameProfilesGeneralOptionsFrameUseClassColors, CompactUnitFrameProfilesGeneralOptionsFrameDisplayPets, CompactUnitFrameProfilesGeneralOptionsFrameDisplayMainTankAndAssist, CompactUnitFrameProfilesGeneralOptionsFrameDisplayBorder, CompactUnitFrameProfilesGeneralOptionsFrameShowDebuffs, CompactUnitFrameProfilesGeneralOptionsFrameDisplayOnlyDispellableDebuffs, CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate2Players, CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate3Players, CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate5Players, CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate10Players, CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate15Players, CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate25Players, CompactUnitFrameProfilesGeneralOptionsFrameAutoActivate40Players, CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec1, CompactUnitFrameProfilesGeneralOptionsFrameAutoActivateSpec2, CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvP, CompactUnitFrameProfilesGeneralOptionsFrameAutoActivatePvE}

			for _, box in next, boxes do
				F.ReskinCheck(box)
			end

			F.Reskin(CompactUnitFrameProfilesSaveButton)
			F.Reskin(CompactUnitFrameProfilesDeleteButton)
			F.Reskin(CompactUnitFrameProfilesGeneralOptionsFrameResetPositionButton)
			F.ReskinDropDown(CompactUnitFrameProfilesProfileSelector)
			F.ReskinDropDown(CompactUnitFrameProfilesGeneralOptionsFrameSortByDropdown)
			F.ReskinDropDown(CompactUnitFrameProfilesGeneralOptionsFrameHealthTextDropdown)
			F.ReskinSlider(CompactUnitFrameProfilesGeneralOptionsFrameHeightSlider)
			F.ReskinSlider(CompactUnitFrameProfilesGeneralOptionsFrameWidthSlider)
		end

		restyled = true
	end)

	hooksecurefunc("InterfaceOptions_AddCategory", function()
		local num = #INTERFACEOPTIONS_ADDONCATEGORIES
		for i = 1, num do
			local bu = _G["InterfaceOptionsFrameAddOnsButton"..i.."Toggle"]
			if bu and not bu.reskinned then
				F.ReskinExpandOrCollapse(bu)
				bu:SetPushedTexture("")
				bu.SetPushedTexture = F.dummy
				bu.reskinned = true
			end
		end
	end)

	hooksecurefunc("OptionsListButtonToggle_OnClick", function(self)
		if self:GetParent().element.collapsed then
			self.plus:Show()
		else
			self.plus:Hide()
		end
	end)
end)
