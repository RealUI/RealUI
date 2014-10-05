local _, mods = ...

tinsert(mods["Aurora"], function()
--F.AddPlugin(function()
	local F, C = unpack(Aurora)
	--print("MiscSkins")
	--Travel Pass
    FriendsFrame:HookScript("OnShow", function()
        if not FriendsFrame.skinned then
            for i = 1, FRIENDS_TO_DISPLAY do
                local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]

                --local frame = CreateFrame("frame", nil, bu)
                --frame:SetSize(60, 32)

                F.Reskin(bu.travelPassButton)
                bu.travelPassButton:SetAlpha(1)
                bu.travelPassButton:EnableMouse(true)
                bu.travelPassButton:SetSize(20, 32)

                bu.bg:SetSize(bu.gameIcon:GetWidth()+2, bu.gameIcon:GetHight()+2)
                bu.bg:ClearAllPoints()
                bu.bg:SetPoint("TOPLEFT", bu.gameIcon, -1, 1)
                bu.gameIcon:SetParent(bu.bg)
                bu.gameIcon:SetPoint("TOPRIGHT", bu.travelPassButton, "TOPLEFT", -1, -5)
                bu.gameIcon.SetPoint = function() end

                bu.inv = bu.travelPassButton:CreateTexture(nil, "OVERLAY", nil, 7)
                bu.inv:SetTexture("Interface\\FriendsFrame\\PlusManz-PlusManz")
                bu.inv:SetPoint("TOPRIGHT", 1, -4)
                bu.inv:SetSize(22, 22)
            end
            FriendsFrame.skinned = true
        end
    end)

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
			else
				bu.bg:Hide()
			end
		end
	end
	hooksecurefunc("FriendsFrame_UpdateFriends", UpdateScroll)
	hooksecurefunc(FriendsFrameFriendsScrollFrame, "update", UpdateScroll)

    -- AddOn List
    F.ReskinScroll(AddonListScrollFrameScrollBar)

	-- Splash Frame
    F.CreateBD(SplashFrame, nil, true)
    hooksecurefunc("SplashFrame_Display", function(tag, showStartButton)
        --print("SplashFrame", tag, showStartButton)
        SplashFrame.LeftTexture:SetDrawLayer("BACKGROUND", 7)
        F.ReskinAtlas(SplashFrame.LeftTexture, SPLASH_SCREENS[tag].leftTex)

        SplashFrame.RightTexture:SetDrawLayer("BACKGROUND", 7)
        F.ReskinAtlas(SplashFrame.RightTexture, SPLASH_SCREENS[tag].rightTex)

        SplashFrame.BottomTexture:SetDrawLayer("BACKGROUND", 7)
        local left, right, top, bottom = F.ReskinAtlas(SplashFrame.BottomTexture, SPLASH_SCREENS[tag].bottomTex, true)
        SplashFrame.BottomTexture:SetTexCoord(right, top, left, top, right, bottom, left, bottom)

        SplashFrame.Label:SetTextColor(1, 1, 1)
    end)
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
]]
