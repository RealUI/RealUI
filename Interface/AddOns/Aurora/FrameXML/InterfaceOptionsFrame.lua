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
		F.Reskin(InterfaceOptionsHelpPanelResetTutorials)

		InterfaceOptionsFrameOkay:SetPoint("BOTTOMRIGHT", InterfaceOptionsFrameCancel, "BOTTOMLEFT", -1, 0)

		InterfaceOptionsFrameHeader:SetTexture("")
		InterfaceOptionsFrameHeader:ClearAllPoints()
		InterfaceOptionsFrameHeader:SetPoint("TOP", InterfaceOptionsFrame, 0, 0)

		local line = InterfaceOptionsFrame:CreateTexture(nil, "ARTWORK")
		line:SetSize(1, 546)
		line:SetPoint("LEFT", 205, 10)
		line:SetTexture(1, 1, 1, .2)

		local checkboxes = {"InterfaceOptionsControlsPanelStickyTargeting", "InterfaceOptionsControlsPanelAutoDismount", "InterfaceOptionsControlsPanelAutoClearAFK", "InterfaceOptionsControlsPanelBlockTrades", "InterfaceOptionsControlsPanelBlockGuildInvites", "InterfaceOptionsControlsPanelBlockChatChannelInvites", "InterfaceOptionsControlsPanelLootAtMouse", "InterfaceOptionsControlsPanelAutoLootCorpse", "InterfaceOptionsControlsPanelAutoOpenLootHistory", "InterfaceOptionsControlsPanelInteractOnLeftClick", "InterfaceOptionsControlsPanelReverseCleanUpBags", "InterfaceOptionsControlsPanelReverseNewLoot", "InterfaceOptionsCombatPanelAttackOnAssist", "InterfaceOptionsCombatPanelStopAutoAttack", "InterfaceOptionsNamesPanelUnitNameplatesNameplateClassColors", "InterfaceOptionsCombatPanelTargetOfTarget", "InterfaceOptionsCombatPanelShowSpellAlerts", "InterfaceOptionsCombatPanelReducedLagTolerance", "InterfaceOptionsCombatPanelActionButtonUseKeyDown", "InterfaceOptionsCombatPanelEnemyCastBarsOnPortrait", "InterfaceOptionsCombatPanelEnemyCastBarsOnNameplates", "InterfaceOptionsCombatPanelEnemyCastBarsOnOnlyTargetNameplates", "InterfaceOptionsCombatPanelEnemyCastBarsNameplateSpellNames", "InterfaceOptionsCombatPanelAutoSelfCast", "InterfaceOptionsCombatPanelLossOfControl", "InterfaceOptionsDisplayPanelShowCloak", "InterfaceOptionsDisplayPanelShowHelm", "InterfaceOptionsDisplayPanelShowAggroPercentage", "InterfaceOptionsDisplayPanelPlayAggroSounds", "InterfaceOptionsDisplayPanelShowSpellPointsAvg", "InterfaceOptionsDisplayPanelShowFreeBagSpace", "InterfaceOptionsDisplayPanelCinematicSubtitles", "InterfaceOptionsDisplayPanelRotateMinimap", "InterfaceOptionsDisplayPanelShowAccountAchievments", "InterfaceOptionsObjectivesPanelAutoQuestTracking", "InterfaceOptionsObjectivesPanelMapFade", "InterfaceOptionsSocialPanelProfanityFilter", "InterfaceOptionsSocialPanelSpamFilter", "InterfaceOptionsSocialPanelChatBubbles", "InterfaceOptionsSocialPanelPartyChat", "InterfaceOptionsSocialPanelChatHoverDelay", "InterfaceOptionsSocialPanelGuildMemberAlert", "InterfaceOptionsSocialPanelChatMouseScroll", "InterfaceOptionsSocialPanelWholeChatWindowClickable", "InterfaceOptionsActionBarsPanelBottomLeft", "InterfaceOptionsActionBarsPanelBottomRight", "InterfaceOptionsActionBarsPanelRight", "InterfaceOptionsActionBarsPanelRightTwo", "InterfaceOptionsActionBarsPanelLockActionBars", "InterfaceOptionsActionBarsPanelAlwaysShowActionBars", "InterfaceOptionsActionBarsPanelSecureAbilityToggle", "InterfaceOptionsActionBarsPanelCountdownCooldowns", "InterfaceOptionsNamesPanelMyName", "InterfaceOptionsNamesPanelMinus", "InterfaceOptionsNamesPanelFriendlyPlayerNames", "InterfaceOptionsNamesPanelFriendlyPets", "InterfaceOptionsNamesPanelFriendlyGuardians", "InterfaceOptionsNamesPanelFriendlyTotems", "InterfaceOptionsNamesPanelUnitNameplatesFriends", "InterfaceOptionsNamesPanelUnitNameplatesFriendlyPets", "InterfaceOptionsNamesPanelUnitNameplatesFriendlyGuardians", "InterfaceOptionsNamesPanelUnitNameplatesFriendlyTotems", "InterfaceOptionsNamesPanelGuilds", "InterfaceOptionsNamesPanelGuildTitles", "InterfaceOptionsNamesPanelTitles", "InterfaceOptionsNamesPanelNonCombatCreature", "InterfaceOptionsNamesPanelEnemyPlayerNames", "InterfaceOptionsNamesPanelEnemyPets", "InterfaceOptionsNamesPanelEnemyGuardians", "InterfaceOptionsNamesPanelEnemyTotems", "InterfaceOptionsNamesPanelUnitNameplatesEnemies", "InterfaceOptionsNamesPanelUnitNameplatesEnemyPets", "InterfaceOptionsNamesPanelUnitNameplatesEnemyGuardians", "InterfaceOptionsNamesPanelUnitNameplatesEnemyTotems", "InterfaceOptionsNamesPanelUnitNameplatesEnemyMinus", "InterfaceOptionsCombatTextPanelTargetDamage", "InterfaceOptionsCombatTextPanelPeriodicDamage", "InterfaceOptionsCombatTextPanelPetDamage", "InterfaceOptionsCombatTextPanelHealing", "InterfaceOptionsCombatTextPanelHealingAbsorbTarget", "InterfaceOptionsCombatTextPanelTargetEffects", "InterfaceOptionsCombatTextPanelOtherTargetEffects", "InterfaceOptionsCombatTextPanelEnableFCT", "InterfaceOptionsCombatTextPanelDodgeParryMiss", "InterfaceOptionsCombatTextPanelDamageReduction", "InterfaceOptionsCombatTextPanelRepChanges", "InterfaceOptionsCombatTextPanelReactiveAbilities", "InterfaceOptionsCombatTextPanelFriendlyHealerNames", "InterfaceOptionsCombatTextPanelCombatState", "InterfaceOptionsCombatTextPanelHealingAbsorbSelf", "InterfaceOptionsCombatTextPanelComboPoints", "InterfaceOptionsCombatTextPanelLowManaHealth", "InterfaceOptionsCombatTextPanelEnergyGains", "InterfaceOptionsCombatTextPanelPeriodicEnergyGains", "InterfaceOptionsCombatTextPanelHonorGains", "InterfaceOptionsCombatTextPanelAuras", "InterfaceOptionsCombatTextPanelPetBattle", "InterfaceOptionsStatusTextPanelPlayer", "InterfaceOptionsStatusTextPanelPet", "InterfaceOptionsStatusTextPanelParty", "InterfaceOptionsStatusTextPanelTarget", "InterfaceOptionsStatusTextPanelAlternateResource", "InterfaceOptionsStatusTextPanelXP", "InterfaceOptionsUnitFramePanelPartyPets", "InterfaceOptionsUnitFramePanelArenaEnemyFrames", "InterfaceOptionsUnitFramePanelArenaEnemyCastBar", "InterfaceOptionsUnitFramePanelArenaEnemyPets", "InterfaceOptionsUnitFramePanelFullSizeFocusFrame", "InterfaceOptionsBuffsPanelDispellableDebuffs", "InterfaceOptionsBuffsPanelCastableBuffs", "InterfaceOptionsBuffsPanelConsolidateBuffs", "InterfaceOptionsBuffsPanelShowAllEnemyDebuffs", "InterfaceOptionsBattlenetPanelOnlineFriends", "InterfaceOptionsBattlenetPanelOfflineFriends", "InterfaceOptionsBattlenetPanelBroadcasts", "InterfaceOptionsBattlenetPanelFriendRequests", "InterfaceOptionsBattlenetPanelConversations", "InterfaceOptionsBattlenetPanelShowToastWindow", "InterfaceOptionsCameraPanelFollowTerrain", "InterfaceOptionsCameraPanelHeadBob", "InterfaceOptionsCameraPanelWaterCollision", "InterfaceOptionsCameraPanelSmartPivot", "InterfaceOptionsMousePanelInvertMouse", "InterfaceOptionsMousePanelEnableMouseSpeed", "InterfaceOptionsMousePanelClickToMove", "InterfaceOptionsMousePanelWoWMouse", "InterfaceOptionsHelpPanelShowTutorials", "InterfaceOptionsHelpPanelEnhancedTooltips", "InterfaceOptionsHelpPanelShowLuaErrors", "InterfaceOptionsHelpPanelColorblindMode", "InterfaceOptionsHelpPanelMovePad"}
		for i = 1, #checkboxes do
			F.ReskinCheck(_G[checkboxes[i]])
		end

		local dropdowns = {"InterfaceOptionsControlsPanelAutoLootKeyDropDown", "InterfaceOptionsCombatPanelFocusCastKeyDropDown", "InterfaceOptionsCombatPanelSelfCastKeyDropDown", "InterfaceOptionsCombatPanelLossOfControlFullDropDown", "InterfaceOptionsCombatPanelLossOfControlSilenceDropDown", "InterfaceOptionsCombatPanelLossOfControlInterruptDropDown", "InterfaceOptionsCombatPanelLossOfControlDisarmDropDown", "InterfaceOptionsCombatPanelLossOfControlRootDropDown", "InterfaceOptionsDisplayPanelOutlineDropDown", "InterfaceOptionsObjectivesPanelQuestSorting", "InterfaceOptionsSocialPanelChatStyle", "InterfaceOptionsSocialPanelTimestamps", "InterfaceOptionsSocialPanelWhisperMode", "InterfaceOptionsSocialPanelBnWhisperMode", "InterfaceOptionsSocialPanelConversationMode", "InterfaceOptionsActionBarsPanelPickupActionKeyDropDown", "InterfaceOptionsNamesPanelNPCNamesDropDown", "InterfaceOptionsNamesPanelUnitNameplatesMotionDropDown", "InterfaceOptionsCombatTextPanelTargetModeDropDown", "InterfaceOptionsCombatTextPanelFCTDropDown", "InterfaceOptionsStatusTextPanelDisplayDropDown", "InterfaceOptionsCameraPanelStyleDropDown", "InterfaceOptionsMousePanelClickMoveStyleDropDown"}
		for i = 1, #dropdowns do
			F.ReskinDropDown(_G[dropdowns[i]])
		end

		local sliders = {"InterfaceOptionsCombatPanelSpellAlertOpacitySlider", "InterfaceOptionsCombatPanelMaxSpellStartRecoveryOffset", "InterfaceOptionsBattlenetPanelToastDurationSlider", "InterfaceOptionsCameraPanelMaxDistanceSlider", "InterfaceOptionsCameraPanelFollowSpeedSlider", "InterfaceOptionsMousePanelMouseSensitivitySlider", "InterfaceOptionsMousePanelMouseLookSpeedSlider"}
		for i = 1, #sliders do
			F.ReskinSlider(_G[sliders[i]])
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