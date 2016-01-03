local _, mods = ...
local _G = _G

-- This is for small modifications that are not yet worth having thier own file.
-- Or to make modifications to a frame that Aurora modified.
tinsert(mods["Aurora"], function(F, C)
    mods.debug("MiscSkins", F, C)
    local r, g, b = C.r, C.g, C.b

    -- Lua Globals --
    local next, floor, strsplit = _G.next, _G.floor, _G.strsplit

    -- WoW Globals --
    local CreateFrame, hooksecurefunc = _G.CreateFrame, _G.hooksecurefunc
    local FriendsFrame, SplashFrame, ObjectiveTrackerFrame = _G.FriendsFrame, _G.SplashFrame, _G.ObjectiveTrackerFrame
    local SPLASH_SCREENS = _G.SPLASH_SCREENS

    -- Re-add Travel Pass
    FriendsFrame:HookScript("OnShow", function()
        if not FriendsFrame.skinned then
            for i = 1, _G.FRIENDS_TO_DISPLAY do
                local bu = _G["FriendsFrameFriendsScrollFrameButton"..i]

                --local frame = CreateFrame("frame", nil, bu)
                --frame:SetSize(60, 32)

                F.Reskin(bu.travelPassButton)
                bu.travelPassButton:SetAlpha(1)
                bu.travelPassButton:EnableMouse(true)
                bu.travelPassButton:SetSize(20, 32)

                bu.bg:SetSize(bu.gameIcon:GetWidth()+2, bu.gameIcon:GetHeight()+2)
                bu.bg:ClearAllPoints()
                bu.bg:SetPoint("TOPLEFT", bu.gameIcon, -1, 1)
                bu.gameIcon:SetParent(bu.bg)
                bu.gameIcon:SetPoint("TOPRIGHT", bu.travelPassButton, "TOPLEFT", -2, -5)
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
        for i = 1, _G.FRIENDS_TO_DISPLAY do
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
    hooksecurefunc(_G.FriendsFrameFriendsScrollFrame, "update", UpdateScroll)

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

        SplashFrame.BottomLine:SetDrawLayer("BACKGROUND", 7)
        F.ReskinAtlas(SplashFrame.BottomLine, "splash-botleft")
    end)

    -- Objective Tracker
    F.ReskinExpandOrCollapse(ObjectiveTrackerFrame.HeaderMenu.MinimizeButton)
    for _, headerName in next, {"QuestHeader", "AchievementHeader", "ScenarioHeader"} do
        local header = ObjectiveTrackerFrame.BlocksFrame[headerName]
        header.Background:Hide()

        local bg = header:CreateTexture(nil, "ARTWORK")
        bg:SetTexture([[Interface\LFGFrame\UI-LFG-SEPARATOR]])
        bg:SetTexCoord(0, 0.6640625, 0, 0.3125)
        bg:SetVertexColor(r * 0.7, g * 0.7, b * 0.7)
        bg:SetPoint("BOTTOMLEFT", -30, -4)
        bg:SetSize(210, 30)
    end

    -- Scroll to bottom
    for i = 1, 10 do
        local chat = _G["ChatFrame" .. i]
        local btn = chat.buttonFrame.bottomButton
        btn:SetSize(20, 20)
        F.Reskin(btn, true)

        local arrow = btn:CreateTexture(nil, "ARTWORK")
        arrow:SetPoint("TOPLEFT", 6, -6)
        arrow:SetPoint("BOTTOMRIGHT", -6, 6)
        arrow:SetTexture(C.media.arrowDown)

        local flash = _G[btn:GetName() .. "Flash"]
        flash:ClearAllPoints()
        flash:SetAllPoints(arrow)
        flash:SetTexture(C.media.arrowDown)
        flash:SetVertexColor(r, g, b, .8)
    end

    -- World State Frame
    F.Reskin(_G.WorldStateScoreFrameQueueButton)
    for i = 1, _G.MAX_WORLDSTATE_SCORE_BUTTONS do
        local scoreBtn = _G["WorldStateScoreButton" .. i]
        scoreBtn.factionLeft:SetTexture(C.media.backdrop)
        scoreBtn.factionLeft:SetBlendMode("ADD")
        scoreBtn.factionRight:SetTexture(C.media.backdrop)
        scoreBtn.factionRight:SetBlendMode("ADD")
    end
    _G.WorldStateScoreWinnerFrameLeft:SetTexture(C.media.backdrop)
    _G.WorldStateScoreWinnerFrameLeft:SetBlendMode("ADD")
    _G.WorldStateScoreWinnerFrameRight:SetTexture(C.media.backdrop)
    _G.WorldStateScoreWinnerFrameRight:SetBlendMode("ADD")
end)

tinsert(mods["PLAYER_LOGIN"], function(F, C)
    mods.debug("PLAYER_LOGIN - Misc", F, C)
    -- These addons are loaded before !Aurora_RealUI.

    --mods["Blizzard_PetBattleUI"](F, C)
    if _G.IsAddOnLoaded("Blizzard_CompactRaidFrames") then
        mods["Blizzard_CompactRaidFrames"](F, C)
    end

end)

mods["Blizzard_AuctionUI"] = function(F, C)
    mods.debug("Blizzard_AuctionUI", F, C)

    -- Lua Globals --
    local next = _G.next

    -- WoW Globals --
    local tokenTutorial, StoreButton = _G.tokenTutorial, _G.StoreButton

    tokenTutorial.Tutorial:SetDrawLayer("BACKGROUND", 7)
    F.ReskinAtlas(tokenTutorial.Tutorial, "token-info-background")

    for _, side in next, {"LeftDisplay", "RightDisplay"} do
        tokenTutorial[side].Label:SetTextColor(1, 1, 1)
        tokenTutorial[side].Tutorial1:SetTextColor(.5, .5, .5)
    end

    StoreButton:SetSize(149, 26)
    StoreButton:SetPoint("TOPLEFT", tokenTutorial.RightDisplay.Tutorial2, "BOTTOMLEFT", 56, -12)
end
