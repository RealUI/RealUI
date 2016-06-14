local F, C = unpack(select(2, ...))

tinsert(C.themes["Aurora"], function()
	VideoOptionsFrameCategoryFrame:DisableDrawLayer("BACKGROUND")
	VideoOptionsFramePanelContainer:DisableDrawLayer("BORDER")

	VideoOptionsFrameHeader:SetTexture("")
	VideoOptionsFrameHeader:ClearAllPoints()
	VideoOptionsFrameHeader:SetPoint("TOP", VideoOptionsFrame, 0, 0)

	F.CreateBD(VideoOptionsFrame)
	F.Reskin(VideoOptionsFrameOkay)
	F.Reskin(VideoOptionsFrameCancel)
	F.Reskin(VideoOptionsFrameDefaults)
	F.Reskin(VideoOptionsFrameApply)

	VideoOptionsFrameOkay:SetPoint("BOTTOMRIGHT", VideoOptionsFrameCancel, "BOTTOMLEFT", -1, 0)

	local styledOptions = false
	VideoOptionsFrame:HookScript("OnShow", function()
		if styledOptions then return end

		local line = VideoOptionsFrame:CreateTexture(nil, "ARTWORK")
		line:SetSize(1, 512)
		line:SetPoint("LEFT", 205, 30)
		if C.isBetaClient then
			line:SetColorTexture(1, 1, 1, .2)
		else
			line:SetTexture(1, 1, 1, .2)
		end
		local groups, checkboxes, dropdowns, sliders

		--[[ Graphics ]]--

		-- Display
		Display_:SetBackdrop(nil)
		local hline = Display_:CreateTexture(nil, "ARTWORK")
		hline:SetSize(580, 1)
		hline:SetPoint("TOPLEFT", GraphicsButton, "BOTTOMLEFT", 14, -4)
		if C.isBetaClient then
			hline:SetColorTexture(1, 1, 1, .2)
		else
			hline:SetTexture(1, 1, 1, .2)
		end

		dropdowns = {"Display_DisplayModeDropDown", "Display_ResolutionDropDown", "Display_RefreshDropDown", "Display_PrimaryMonitorDropDown", "Display_AntiAliasingDropDown", "Display_VerticalSyncDropDown"}
		for i = 1, #dropdowns do
			F.ReskinDropDown(_G[dropdowns[i]])
		end

		GraphicsButton:DisableDrawLayer("BACKGROUND")
		RaidButton:DisableDrawLayer("BACKGROUND")
		F.ReskinCheck(Display_RaidSettingsEnabledCheckBox)

		if not C.isBetaClient then
			Graphics_RightQuality:SetBackdrop(nil)
			RaidGraphics_RightQuality:SetBackdrop(nil)
		end
		-- Base Settings
		Graphics_:SetBackdrop(nil)
		dropdowns = {"Graphics_TextureResolutionDropDown", "Graphics_FilteringDropDown", "Graphics_ProjectedTexturesDropDown",
					"Graphics_ShadowsDropDown", "Graphics_LiquidDetailDropDown", "Graphics_SunshaftsDropDown", "Graphics_ParticleDensityDropDown", "Graphics_SSAODropDown", "Graphics_DepthEffectsDropDown", "Graphics_LightingQualityDropDown", "Graphics_OutlineModeDropDown"}
		if not C.isBetaClient then
			tinsert(dropdowns, "Graphics_ViewDistanceDropDown")
			tinsert(dropdowns, "Graphics_EnvironmentalDetailDropDown")
			tinsert(dropdowns, "Graphics_GroundClutterDropDown")
		end
		for i = 1, #dropdowns do
			F.ReskinDropDown(_G[dropdowns[i]])
		end
		sliders = {"Graphics_Quality"}
		if C.isBetaClient then
			tinsert(sliders, "Graphics_ViewDistanceSlider")
			tinsert(sliders, "Graphics_EnvironmentalDetailSlider")
			tinsert(sliders, "Graphics_GroundClutterSlider")
		end
		for i = 1, #sliders do
			F.ReskinSlider(_G[sliders[i]])
		end

		-- Raid and Battleground
		RaidGraphics_:SetBackdrop(nil)
		dropdowns = {"RaidGraphics_TextureResolutionDropDown", "RaidGraphics_FilteringDropDown", "RaidGraphics_ProjectedTexturesDropDown",
					"RaidGraphics_ShadowsDropDown", "RaidGraphics_LiquidDetailDropDown", "RaidGraphics_SunshaftsDropDown", "RaidGraphics_ParticleDensityDropDown", "RaidGraphics_SSAODropDown", "RaidGraphics_DepthEffectsDropDown", "RaidGraphics_LightingQualityDropDown", "RaidGraphics_OutlineModeDropDown"}
		if not C.isBetaClient then
			tinsert(dropdowns, "RaidGraphics_ViewDistanceDropDown")
			tinsert(dropdowns, "RaidGraphics_EnvironmentalDetailDropDown")
			tinsert(dropdowns, "RaidGraphics_GroundClutterDropDown")
		end
		for i = 1, #dropdowns do
			F.ReskinDropDown(_G[dropdowns[i]])
		end
		sliders = {"RaidGraphics_Quality"}
		if C.isBetaClient then
			tinsert(sliders, "RaidGraphics_ViewDistanceSlider")
			tinsert(sliders, "RaidGraphics_EnvironmentalDetailSlider")
			tinsert(sliders, "RaidGraphics_GroundClutterSlider")
		end
		for i = 1, #sliders do
			F.ReskinSlider(_G[sliders[i]])
		end

		--[[ Advanced ]]--
		checkboxes = {"Advanced_UseUIScale", "Advanced_MaxFPSCheckBox", "Advanced_MaxFPSBKCheckBox", "Advanced_ShowHDModels", "Advanced_DesktopGamma"}
		for i = 1, #checkboxes do
			F.ReskinCheck(_G[checkboxes[i]])
		end
		dropdowns = {"Advanced_BufferingDropDown", "Advanced_LagDropDown", "Advanced_HardwareCursorDropDown", "Advanced_MultisampleAntiAliasingDropDown", "Advanced_MultisampleAlphaTest", "Advanced_PostProcessAntiAliasingDropDown", "Advanced_ResampleQualityDropDown", "Advanced_GraphicsAPIDropDown"}
		if C.isBetaClient then
			tinsert(dropdowns, "Advanced_PhysicsInteractionDropDown")
		end
		for i = 1, #dropdowns do
			F.ReskinDropDown(_G[dropdowns[i]])
		end
		sliders = {"Advanced_UIScaleSlider", "Advanced_MaxFPSSlider", "Advanced_MaxFPSBKSlider", "Advanced_RenderScaleSlider", "Advanced_GammaSlider"}
		for i = 1, #sliders do
			F.ReskinSlider(_G[sliders[i]])
		end

		--[[ Network ]]--
		checkboxes = {"NetworkOptionsPanelOptimizeSpeed", "NetworkOptionsPanelUseIPv6", "NetworkOptionsPanelAdvancedCombatLogging"}
		for i = 1, #checkboxes do
			F.ReskinCheck(_G[checkboxes[i]])
		end

		--[[ Languages ]]--
		F.ReskinDropDown(InterfaceOptionsLanguagesPanelLocaleDropDown)
		F.ReskinDropDown(InterfaceOptionsLanguagesPanelAudioLocaleDropDown)

		--[[ Sound ]]--
		groups = {"AudioOptionsSoundPanelPlayback", "AudioOptionsSoundPanelHardware", "AudioOptionsSoundPanelVolume"}
		for i = 1, #groups do
			local group = _G[groups[i]]
			F.CreateBD(group, .25)
			_G[groups[i].."Title"]:SetPoint("BOTTOMLEFT", group, "TOPLEFT", 5, 2)
		end
		checkboxes = {"AudioOptionsSoundPanelEnableSound", "AudioOptionsSoundPanelSoundEffects", "AudioOptionsSoundPanelErrorSpeech", "AudioOptionsSoundPanelEmoteSounds", "AudioOptionsSoundPanelPetSounds", "AudioOptionsSoundPanelMusic", "AudioOptionsSoundPanelLoopMusic", "AudioOptionsSoundPanelPetBattleMusic", "AudioOptionsSoundPanelAmbientSounds", "AudioOptionsSoundPanelDialogSounds", "AudioOptionsSoundPanelSoundInBG", "AudioOptionsSoundPanelReverb", "AudioOptionsSoundPanelHRTF", "AudioOptionsSoundPanelEnableDSPs"}
		for i = 1, #checkboxes do
			F.ReskinCheck(_G[checkboxes[i]])
		end
		dropdowns = {"AudioOptionsSoundPanelHardwareDropDown", "AudioOptionsSoundPanelSoundChannelsDropDown"}
		if C.isBetaClient then
			tinsert(dropdowns, "AudioOptionsSoundPanelSoundCacheSizeDropDown")
		end
		for i = 1, #dropdowns do
			F.ReskinDropDown(_G[dropdowns[i]])
		end
		sliders = {"AudioOptionsSoundPanelMasterVolume", "AudioOptionsSoundPanelSoundVolume", "AudioOptionsSoundPanelMusicVolume", "AudioOptionsSoundPanelAmbienceVolume", "AudioOptionsSoundPanelDialogVolume"}
		for i = 1, #sliders do
			F.ReskinSlider(_G[sliders[i]])
		end

		--[[ Voice ]]--
		groups = {"AudioOptionsVoicePanelTalking", "AudioOptionsVoicePanelBinding", "AudioOptionsVoicePanelListening"}
		for i = 1, #groups do
			local group = _G[groups[i]]
			F.CreateBD(group, .25)
			_G[groups[i].."Title"]:SetPoint("BOTTOMLEFT", group, "TOPLEFT", 5, 2)
		end
		checkboxes = {"AudioOptionsVoicePanelEnableVoice", "AudioOptionsVoicePanelEnableMicrophone", "AudioOptionsVoicePanelPushToTalkSound"}
		for i = 1, #checkboxes do
			F.ReskinCheck(_G[checkboxes[i]])
		end
		dropdowns = {"AudioOptionsVoicePanelInputDeviceDropDown", "AudioOptionsVoicePanelChatModeDropDown", "AudioOptionsVoicePanelOutputDeviceDropDown"}
		for i = 1, #dropdowns do
			F.ReskinDropDown(_G[dropdowns[i]])
		end
		sliders = {"AudioOptionsVoicePanelMicrophoneVolume", "AudioOptionsVoicePanelSpeakerVolume", "AudioOptionsVoicePanelSoundFade", "AudioOptionsVoicePanelMusicFade", "AudioOptionsVoicePanelAmbienceFade"}
		for i = 1, #sliders do
			F.ReskinSlider(_G[sliders[i]])
		end
		F.Reskin(RecordLoopbackSoundButton)
		F.Reskin(PlayLoopbackSoundButton)
		F.Reskin(AudioOptionsVoicePanelChatMode1KeyBindingButton)

		styledOptions = true
	end)
end)
