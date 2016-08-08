--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
	https://github.com/Phanx/PhanxChat
----------------------------------------------------------------------]]

local _, PhanxChat = ...

local ChatTypeInfo = getmetatable(ChatTypeInfo).__index -- WTF Blizz?

local StickyChannels = {
	BN_WHISPER		= ChatTypeInfo.BN_WHISPER.sticky,		-- 1
	CHANNEL			= ChatTypeInfo.CHANNEL.sticky,			-- 1
	EMOTE 			= ChatTypeInfo.EMOTE.sticky,			-- 0
	GUILD 			= ChatTypeInfo.GUILD.sticky,			-- 1
	INSTANCE_CHAT	= ChatTypeInfo.INSTANCE_CHAT.sticky,	-- 1
	OFFICER 		= ChatTypeInfo.OFFICER.sticky,			-- 1
	PARTY 			= ChatTypeInfo.PARTY.sticky,			-- 1
	RAID 			= ChatTypeInfo.RAID.sticky,				-- 1
	SAY 			= ChatTypeInfo.SAY.sticky,				-- 1
	WHISPER 		= ChatTypeInfo.WHISPER.sticky,			-- 1
	YELL 			= ChatTypeInfo.YELL.sticky,				-- 0
}

function PhanxChat:SetEnableSticky(v)
	if self.debug then print("PhanxChat: SetEnableSticky", v) end
	if type(v) == "string" and v == "ALL" or v == "BLIZZARD" or v == "NONE" then
		self.db.EnableSticky = v
	end

	if self.db.EnableSticky == "ALL" then
		for chatType in pairs(StickyChannels) do
			ChatTypeInfo[chatType].sticky = 1
		end
		ChatTypeInfo.EMOTE.sticky = 0
		ChatTypeInfo.RAID_WARNING.sticky = 0
	elseif self.db.EnableSticky == "BLIZZARD" then
		for chatType, defaultValue in pairs(StickyChannels) do
			ChatTypeInfo[chatType].sticky = defaultValue
		end
	elseif self.db.EnableSticky == "NONE" then
		for chatType in pairs(StickyChannels) do
			ChatTypeInfo[chatType].sticky = 0
		end
	end

	for frame in pairs(PhanxChat.frames) do
		local editBox = _G[frame:GetName() .. "EditBox"]
		if editBox then
			local stickyType = editBox:GetAttribute("stickyType")
			if ChatTypeInfo[stickyType].sticky == 0 then
				editBox:SetAttribute("chatType", "SAY")
				editBox:SetAttribute("stickyType", "SAY")
			end
		end
	end
end

table.insert(PhanxChat.RunOnLoad, PhanxChat.SetEnableSticky)