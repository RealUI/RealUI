--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2014 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
	https://github.com/Phanx/PhanxChat
----------------------------------------------------------------------]]

local _, PhanxChat = ...
local L = PhanxChat.L

local BNET_CLIENT_TEXT = {
	-- ["App"] = "Battle.net Desktop App",
	[BNET_CLIENT_D3]   = "Diablo III",
	[BNET_CLIENT_WTCG] = "Hearthstone",
	[BNET_CLIENT_SC2]  = "StarCraft II",
	[BNET_CLIENT_WOW]  = "World of Warcraft",
}

------------------------------------------------------------------------

local _, playerRealm = UnitFullName("player")

local classTokens = {}
for k, v in pairs(LOCALIZED_CLASS_NAMES_FEMALE) do classTokens[v] = k end
for k, v in pairs(LOCALIZED_CLASS_NAMES_MALE) do classTokens[v] = k end

local bnetNames = setmetatable({}, { __index = function(bnetNames, presenceID)
	-- presenceID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, lastOnline, isAFK, isDND, messageText, noteText, isRIDFriend, messageTime, canSoR, isReferAFriend, canSummonFriend
	local _, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, _, _, _, _, _, isRIDFriend = BNGetFriendInfoByID(presenceID)
	if not presenceName then return end -- not initialized yet
	-- print(presenceID, presenceName, isRIDFriend, battleTag, isBattleTagPresence, isOnline, client, toonID, toonName)

	local classColor
	if isOnline and toonID and client == BNET_CLIENT_WOW and PhanxChat.db.ShowClassColors then
		-- print("Online in WoW")
		local _, _, _, realmName, _, _, _, className = BNGetToonInfo(toonID)
		realmName = realmName and realmName ~= "" and realmName ~= playerRealm and gsub(realmName, "%s", "")
		toonName = realmName and format("%s-%s", toonName, realmName) or toonName

		local class = classTokens[className]
		classColor = class and (CUSTOM_CLASS_COLORS or RAID_CLASS_COLORS)[class]
	else
		toonName = nil
	end

	if toonName and PhanxChatDB.ReplaceRealNames then
		presenceName = toonName
	elseif isRIDFriend and PhanxChatDB.ShortenRealNames == "FIRSTNAME" then
		-- This works because the game ignores extra placeholders:
		presenceName = gsub(presenceName, "|Kf", "|Kg")
		-- print("Using first name:", presenceName)
	elseif PhanxChatDB.ShortenRealNames == "BATTLETAG" then
		presenceName = strsplit("#", battleTag, 2)
		-- print("Using BattleTag:", presenceName)
	else
		-- Fall back to full name
		-- print("Using full name:", presenceName)
	end

	if classColor then
		presenceName = format("|c%s%s|r", classColor.colorStr, presenceName)
	elseif PhanxChat.db.ShowClassColors then
		-- EXPERIMENTAL
		presenceName = format("%s%s|r", FRIENDS_BNET_NAME_COLOR_CODE, presenceName)
	end

	bnetNames[presenceID] = presenceName
	return presenceName
end })

function PhanxChat:ClearBNetNameCache()
	-- print("ClearBNetNameCache")
	wipe(bnetNames)
	-- print("Done.")
end

PhanxChat.BN_CONNECTED = PhanxChat.ClearBNetNameCache
PhanxChat.BN_FRIEND_ACCOUNT_ONLINE = PhanxChat.ClearBNetNameCache
PhanxChat.BN_FRIEND_TOON_ONLINE = PhanxChat.ClearBNetNameCache
PhanxChat.PLAYER_ENTERING_WORLD = PhanxChat.ClearBNetNameCache

PhanxChat.bnetNames = bnetNames

------------------------------------------------------------------------

function PhanxChat:SetReplaceRealNames(v)
	-- print("PhanxChat: SetReplaceRealNames", v)
	if type(v) == "boolean" then
		self.db.ReplaceRealNames = v
	elseif type(v) == "string" then
		self.db.ShortenRealNames = v
	end

	self:ClearBNetNameCache()
	if self.db.ReplaceRealNames or self.db.ShortenRealNames then
		self:RegisterEvent("BN_CONNECTED")
		self:RegisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
		self:RegisterEvent("BN_FRIEND_TOON_ONLINE")
		self:RegisterEvent("PLAYER_ENTERING_WORLD")
	else
		self:UnregisterEvent("BN_CONNECTED")
		self:UnregisterEvent("BN_FRIEND_ACCOUNT_ONLINE")
		self:UnregisterEvent("BN_FRIEND_TOON_ONLINE")
		self:UnregisterEvent("PLAYER_ENTERING_WORLD")
	end
end

table.insert(PhanxChat.RunOnLoad, PhanxChat.SetReplaceRealNames)

------------------------------------------------------------------------

local BN_WHO_LIST_FORMAT = gsub(WHO_LIST_FORMAT, "|Hplayer:", "|H")
local BN_WHO_LIST_GUILD_FORMAT = gsub(WHO_LIST_GUILD_FORMAT, "|Hplayer:", "|H")
local BN_WHO_LIST_REALM_FORMAT = BN_WHO_LIST_FORMAT .. " (%s)"
local BN_WHO_LIST_GUILD_REALM_FORMAT = BN_WHO_LIST_GUILD_FORMAT .. " (%s)"

local dialogs = {
	"ADD_FRIEND",
	"ADD_GUILDMEMBER",
	"ADD_IGNORE",
	"ADD_MUTE",
	"ADD_RAIDMEMBER",
	"ADD_TEAMMEMBER",
	"CHANNEL_INVITE",
}

hooksecurefunc("ChatFrame_OnHyperlinkShow", function(frame, link, text, button)
	if strsub(link, 1, 8) == "BNplayer" then
		local linkID = tonumber(strmatch(link, "|Kf(%d+)"))
		if not linkID or not IsModifiedClick("CHATLINK") or ChatEdit_GetActiveWindow() or HelpFrameOpenTicketEditBox:IsVisible() then
			return
		end
		for _, dialog in ipairs(dialogs) do
			if StaticPopup_Visible(dialog) then
				return
			end
		end
		for i = 1, BNGetNumFriends() do
			local pID, presenceName, battleTag, isBattleTagPresence, toonName, toonID, client, isOnline, _, _, _, _, note, isRIDFriend = BNGetFriendInfo(i)
			if pID == linkID then
				local color = ChatTypeInfo.SYSTEM
				if toonID then
					local hasFocus, toonName, _, realmName, _, faction, race, class, guild, zoneName, level, gameText = BNGetToonInfo(toonID)
					if client ~= BNET_CLIENT_WOW then
						gameText = BNET_CLIENT_TEXT[client]
						if gameText then
							return DEFAULT_CHAT_FRAME:AddMessage(format(L.WhoStatus_PlayingOtherGame, presenceName, gameText),
								color.r, color.g, color.b)
						else
							return DEFAULT_CHAT_FRAME:AddMessage(format(L.WhoStatus_Battlenet, presenceName),
								color.r, color.g, color.b)
						end
					elseif realm == GetRealmName() then -- #TODO: Check in the future if Blizz fixes zone being nil
						if guild and guild ~= "" then
							return DEFAULT_CHAT_FRAME:AddMessage(gsub(format(BN_WHO_LIST_GUILD_FORMAT,
								link, toonName, level, race, class, guild, zoneName or ""), "  ", " "),
								color.r, color.g, color.b)
						else
							return DEFAULT_CHAT_FRAME:AddMessage(gsub(format(BN_WHO_LIST_FORMAT,
								link, toonName, level, race, class, zoneName or ""), "  ", " "),
								color.r, color.g, color.b)
						end
					elseif guild and guild ~= "" then
						return DEFAULT_CHAT_FRAME:AddMessage(gsub(format(BN_WHO_LIST_GUILD_REALM_FORMAT,
							link, toonName, level, race, class, guild, zoneName or "", realmName), "  ", " "),
							color.r, color.g, color.b)
					else
						return DEFAULT_CHAT_FRAME:AddMessage(gsub(format(BN_WHO_LIST_REALM_FORMAT,
							link, toonName, level, race, class, zoneName or "", realmName), "  ", " "),
							color.r, color.g, color.b)
					end
				else
					return DEFAULT_CHAT_FRAME:AddMessage(format(L.WhoStatus_Offline,
						presenceName),
						color.r, color.g, color.b)
				end
			end
		end
	end
end)