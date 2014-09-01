local _, mods = ...

tinsert(mods["Aurora"], function()
	local F, C = unpack(Aurora)
	--print("MiscSkins")
	--Travel Pass
	for i = 1, FRIENDS_TO_DISPLAY do
		local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]

		F.Reskin(bu.travelPassButton)
		bu.travelPassButton:SetAlpha(1)
		bu.travelPassButton:EnableMouse(true)
		bu.travelPassButton:SetSize(20, 32)
		bu.inv = bu.travelPassButton:CreateTexture(nil, "OVERLAY", nil, 7)
		bu.inv:SetTexture("Interface\\FriendsFrame\\PlusManz-PlusManz")
		bu.inv:SetPoint("TOPRIGHT", 1, -4)
		bu.inv:SetSize(22, 22)
	end

	local function UpdateScroll()
		for i = 1, FRIENDS_TO_DISPLAY do
			local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]
			local en = bu.travelPassButton:IsEnabled()
			--print("UpdateScroll", i, en)

			if en then
				bu.inv:SetAlpha(0.7)
			else
				bu.inv:SetAlpha(0.3)
			end

			if bu.gameIcon:IsShown() then
				bu.bg:Show()
				bu.gameIcon:SetPoint("TOPRIGHT", bu.travelPassButton, "TOPLEFT", -1, -5)
			else
				bu.bg:Hide()
			end
		end
	end
	hooksecurefunc("FriendsFrame_UpdateFriends", UpdateScroll)
	hooksecurefunc(FriendsFrameFriendsScrollFrame, "update", UpdateScroll)

	-- Splash Frame
	F.CreateBD(SplashFrame, nil, true)
	SplashFrame.LeftTexture:SetDrawLayer("BACKGROUND", 7)
	SplashFrame.RightTexture:SetDrawLayer("BACKGROUND", 7)
	SplashFrame.BottomTexture:SetDrawLayer("BACKGROUND", 7)
	SplashFrame.Label:SetTextColor(1, 1, 1)
end)

--[[function MiscSkins:Skin()
	F, C = unpack(Aurora)

	-- Clique
	if CliqueSpellTab then
		local tab = CliqueSpellTab
		F.ReskinTab(tab)

		tab:SetCheckedTexture(C.media.checked)

		local bg = CreateFrame("Frame", nil, tab)
		bg:SetPoint("TOPLEFT", -1, 1)
		bg:SetPoint("BOTTOMRIGHT", 1, -1)
		bg:SetFrameLevel(tab:GetFrameLevel()-1)
		F.CreateBD(bg)

		select(6, tab:GetRegions()):SetTexCoord(.08, .92, .08, .92)
	end


	-- Time Manager unnecessary buttons
	if TimeManagerMilitaryTimeCheck then TimeManagerMilitaryTimeCheck:Hide() end
	if TimeManagerLocalTimeCheck then TimeManagerLocalTimeCheck:Hide() end
	if TimeManagerFrame then
		TimeManagerFrame:SetHeight(TimeManagerFrame:GetHeight() - 60)
		TimeManagerAlarmEnabledButton:ClearAllPoints()
		TimeManagerAlarmEnabledButton:SetPoint("TOPLEFT", TimeManagerAlarmMessageEditBox, "BOTTOMLEFT", -6, -4)
	end
end

function MiscSkins:ADDON_LOADED(event, addon)
	--print("MiscSkins:", event, addon)
	if addon =="Blizzard_DebugTools" then
		-- EventTrace
		if Aurora then 
			F, C = unpack(Aurora)

			for i = 1, EventTraceFrame:GetNumRegions() do
				local region = select(i, EventTraceFrame:GetRegions())
				if region:GetObjectType() == "Texture" then
					region:SetTexture(nil)
				end
			end
			EventTraceFrame:SetHeight(600)
			--EventTraceFrameScroll:Hide()
			F.CreateBD(EventTraceFrame)

			EventTraceFrameScrollBG:Hide()
			local thumb = EventTraceFrameScroll.thumb
			thumb:SetAlpha(0)
			thumb:SetWidth(17)
			thumb.bg = CreateFrame("Frame", nil, EventTraceFrameScroll)
			thumb.bg:SetPoint("TOPLEFT", thumb, 0, 0)
			thumb.bg:SetPoint("BOTTOMRIGHT", thumb, 0, 0)
			F.CreateBD(thumb.bg, 0)
			thumb.tex = F.CreateGradient(thumb.bg)
			thumb.tex:SetPoint("TOPLEFT", thumb.bg, 1, -1)
			thumb.tex:SetPoint("BOTTOMRIGHT", thumb.bg, -1, 1)

			F.ReskinClose(EventTraceFrameCloseButton)
		end
	elseif addon == "Aurora" then
		self:Skin()
	end
end]]
