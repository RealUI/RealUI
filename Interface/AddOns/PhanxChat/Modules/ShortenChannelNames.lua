--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
	https://github.com/Phanx/PhanxChat
----------------------------------------------------------------------]]

local _, PhanxChat = ...
local S = PhanxChat.ShortStrings
local STRING_STYLE = PhanxChat.STRING_STYLE

local hooks = { }

local ChannelStrings = {
	CHAT_BN_WHISPER_GET           = format(STRING_STYLE, S.WhisperIncoming) .. "%s:\32",
	CHAT_BN_WHISPER_INFORM_GET    = format(STRING_STYLE, S.WhisperOutgoing) .. "%s:\32",
	CHAT_GUILD_GET                = "|Hchannel:guild|h" .. format(STRING_STYLE, S.Guild) .. "|h%s:\32",
	CHAT_INSTANCE_CHAT_GET        = "|Hchannel:battleground|h" .. format(STRING_STYLE, S.InstanceChat) .. "|h%s:\32",
	CHAT_INSTANCE_CHAT_LEADER_GET = "|Hchannel:battleground|h" .. format(STRING_STYLE, S.InstanceChatLeader) .. "|h%s:\32",
	CHAT_OFFICER_GET              = "|Hchannel:o|h" .. format(STRING_STYLE, S.Officer) .. "|h%s:\32",
	CHAT_PARTY_GET                = "|Hchannel:party|h" .. format(STRING_STYLE, S.Party) .. "|h%s:\32",
	CHAT_PARTY_GUIDE_GET          = "|Hchannel:party|h" .. format(STRING_STYLE, S.PartyGuide) .. "|h%s:\32",
	CHAT_PARTY_LEADER_GET         = "|Hchannel:party|h" .. format(STRING_STYLE, S.PartyLeader) .. "|h%s:\32",
	CHAT_RAID_GET                 = "|Hchannel:raid|h" .. format(STRING_STYLE, S.Raid) .. "|h%s:\32",
	CHAT_RAID_LEADER_GET          = "|Hchannel:raid|h" .. format(STRING_STYLE, S.RaidLeader) .. "|h%s:\32",
	CHAT_RAID_WARNING_GET         = format(STRING_STYLE, S.RaidWarning) .. "%s:\32",
	CHAT_SAY_GET                  = format(STRING_STYLE, S.Say) .. "%s:\32",
	CHAT_WHISPER_GET              = format(STRING_STYLE, S.WhisperIncoming) .. "%s:\32",
	CHAT_WHISPER_INFORM_GET       = format(STRING_STYLE, S.WhisperOutgoing) .. "%s:\32",
	CHAT_YELL_GET                 = format(STRING_STYLE, S.Yell) .. "%s:\32",
}

function PhanxChat:SetShortenChannelNames(v)
	if self.debug then print("PhanxChat: SetShortenChannelNames", v) end
	if type(v) == "boolean" then
		self.db.ShortenChannelNames = v
	end

	if self.db.ShortenChannelNames then
		if not hooks.CHAT_GUILD_GET then
			for k, v in pairs(ChannelStrings) do
				hooks[k] = _G[k]
				_G[k] = v
			end
		end
	else
		if hooks.CHAT_GUILD_GET then
			for k, v in pairs(hooks) do
				_G[k] = v
				hooks[k] = nil
			end
		end
	end
end

table.insert(PhanxChat.RunOnLoad, PhanxChat.SetShortenChannelNames)