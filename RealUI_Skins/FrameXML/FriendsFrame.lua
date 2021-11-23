local _, private = ...

-- [[ Lua Globals ]]
-- luacheck: globals

-- [[ Core ]]
local Aurora = private.Aurora
local Hook = Aurora.Hook

do --[[ FrameXML\FriendsFrame.lua ]]
    local wowFormat = "%s, ".. _G.LEVEL_ABBR .. " %d"
    local bnetFriendColor = _G.FRIENDS_BNET_NAME_COLOR:GenerateHexColor()
    local bnetFormat = "|c"..bnetFriendColor.."%s|r (".. wowFormat .. ")"
    local function GetBNetAccountNameAndStatus(accountInfo, noCharacterName)
        if not accountInfo then
            return
        end

        local nameText, nameColor
        nameText = _G.BNet_GetBNetAccountName(accountInfo)

        local characterName = _G.BNet_GetValidatedCharacterName(accountInfo.gameAccountInfo.characterName, nil, accountInfo.gameAccountInfo.clientProgram)
        if characterName ~= "" then
            if accountInfo.gameAccountInfo.clientProgram == _G.BNET_CLIENT_WOW and _G.CanCooperateWithGameAccount(accountInfo) then
                local classToken = _G.CUSTOM_CLASS_COLORS:GetClassToken(accountInfo.gameAccountInfo.className)
                nameColor = _G.CUSTOM_CLASS_COLORS[classToken]
            else
                if _G.ENABLE_COLORBLIND_MODE == "1" then
                    characterName = accountInfo.gameAccountInfo.characterName.._G.CANNOT_COOPERATE_LABEL
                end
                nameColor = _G.FRIENDS_GRAY_COLOR
            end

            nameText = bnetFormat:format(nameText, characterName, accountInfo.gameAccountInfo.characterLevel)
        end

        return nameText, nameColor
    end

    _G.hooksecurefunc(Hook, "FriendsFrame_UpdateFriendButton", function(button)
        local nameText, nameColor, isFavoriteFriend
        if button.buttonType == _G.FRIENDS_BUTTON_TYPE_WOW then
            local info = _G.C_FriendList.GetFriendInfoByIndex(button.id)
            if info.connected then
                local classToken = _G.CUSTOM_CLASS_COLORS:GetClassToken(info.className)
                nameText = wowFormat:format(info.name, info.level)
                nameColor = _G.CUSTOM_CLASS_COLORS[classToken]
            end
        elseif button.buttonType == _G.FRIENDS_BUTTON_TYPE_BNET then
            local accountInfo = _G.C_BattleNet.GetFriendAccountInfo(button.id)
            local gameAccountInfo = accountInfo.gameAccountInfo
            if accountInfo and gameAccountInfo.isOnline then
                if gameAccountInfo.characterName then
                    nameText, nameColor = GetBNetAccountNameAndStatus(accountInfo)
                    isFavoriteFriend = accountInfo.isFavorite
                end
            end
        end

        if nameText then
            button.name:SetText(nameText)
            button.name:SetTextColor(nameColor:GetRGB())

            if isFavoriteFriend then
                button.Favorite:SetPoint("TOPLEFT", button.name, "TOPLEFT", button.name:GetStringWidth(), 0)
            end
        end
    end)
end

-- do --[[ FrameXML\FriendsFrame.xml ]]
-- end

--_G.hooksecurefunc(private.FrameXML, "FriendsFrame", function()
--end)
