--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
	https://github.com/Phanx/PhanxChat
----------------------------------------------------------------------]]

local STRING_STYLE  = "%s|| "
	-- %s = chat string (eg. "Guild", "2. Trade") (required)
	-- Pipe characters must be escaped by doubling them: | -> ||

local CHANNEL_STYLE = "%d"
	-- %2$d = channel number (optional)
	-- %3$s = channel name (optional)
	-- Will be used with STRING_STYLE for numbered channels.

local PLAYER_STYLE  = "%s"
	-- %s = player name (required)

local NUM_LINES_TO_SCROLL = 3
	-- Lines scrolled per turn of mouse wheel

local CUSTOM_CHANNELS = {
	-- Not case-sensitive. Must be in the format:
	-- ["mychannel"] = "MC",
}

------------------------------------------------------------------------

DEFAULT_CHATFRAME_ALPHA = 0.25
	-- Opacity of chat frames when the mouse is over them.
	-- Default is 0.25.

CHAT_FRAME_TAB_SELECTED_MOUSEOVER_ALPHA = 1
CHAT_FRAME_TAB_SELECTED_NOMOUSE_ALPHA = 0
	-- Opacity of the currently selected chat tab.
	-- Defaults are 1 and 0.4.

CHAT_FRAME_TAB_ALERTING_MOUSEOVER_ALPHA = 1
CHAT_FRAME_TAB_ALERTING_NOMOUSE_ALPHA = 0
	-- Opacity of currently alerting chat tabs.
	-- Defaults are 1 and 1.

CHAT_FRAME_TAB_NORMAL_MOUSEOVER_ALPHA = 1
CHAT_FRAME_TAB_NORMAL_NOMOUSE_ALPHA = 0
	-- Opacity of non-selected, non-alerting chat tabs.
	-- Defaults are 0.6 and 0.2.

CHAT_FRAME_FADE_OUT_TIME = 0
	-- Seconds before fading out chat frames the mouse moves out of.
	-- Default is 2.

CHAT_TAB_HIDE_DELAY = 0
	-- Seconds before fading out chat tabs the mouse moves out of.
	-- Default is 1.

------------------------------------------------------------------------
--	Beyond here lies nothin'.
------------------------------------------------------------------------

local PHANXCHAT, PhanxChat = ...
local L, C, S = PhanxChat.L, PhanxChat.ChannelNames, PhanxChat.ShortStrings

PhanxChat.name = PHANXCHAT
PhanxChat.debug = false

PhanxChat.RunOnLoad = {}
PhanxChat.RunOnProcessFrame = {}

PhanxChat.STRING_STYLE = STRING_STYLE

local frames = {}
PhanxChat.frames = frames

local hooks = {}
PhanxChat.hooks = hooks

local noop = function() return end

local db

local format, gsub, strlower, strmatch, strsub, tonumber, type
    = format, gsub, strlower, strmatch, strsub, tonumber, type

------------------------------------------------------------------------

local CHANNEL_LINK   = "|Hchannel:%1$s|h" .. format(STRING_STYLE, CHANNEL_STYLE) .. "|h"

local PLAYER_LINK    = "|Hplayer:%s|h" .. PLAYER_STYLE .. "|h"
local PLAYER_BN_LINK = "|HBNplayer:%s|h" .. PLAYER_STYLE .. "%s|h"

-- |Hchannel:channel:2|h[2. Trade]|h |Hplayer:Konquered:1281:CHANNEL:2|h|cffbf8cffKonquered|r|h: lf 2s partner
local CHANNEL_PATTERN      = "|Hchannel:(.-)|h%[(%d+)%.%s?([^:%-%]]+)%s?[:%-]?%s?[^|%]]*%]|h%s?"
local CHANNEL_PATTERN_PLUS = CHANNEL_PATTERN .. ".+"

local PLAYER_PATTERN = "|Hplayer:(.-)|h%[(.-)%]|h"
local BNPLAYER_PATTERN = "|HBNplayer:(.-)|h%[(|Kb(%d+).-)%](.*)|h"

local ChannelNames = {
	[C.Conversation]    = S.Conversation,
	[C.General]         = S.General,
	[C.LocalDefense]    = S.LocalDefense,
	[C.LookingForGroup] = S.LookingForGroup,
	[C.Trade]           = S.Trade,
	[C.WorldDefense]    = S.WorldDefense,
}

for name, abbr in pairs(CUSTOM_CHANNELS) do
	ChannelNames[strlower(name)] = abbr
end

_G.PhanxChat_ChannelNames = ChannelNames

local function escape(str)
	return gsub(str, "([%%%+%-%.%[%]%*%?])", "%%%1")
end

local function unescape(str)
	return gsub(str, "%%([%%%+%-%.%[%]%*%?])", "%1")
end

local AddMessage = function(frame, message, ...)
	if type(message) == "string" then
		local channelData, channelID, channelName = strmatch(message, CHANNEL_PATTERN_PLUS)
		if channelData and db.ShortenChannelNames then
			local shortName = ChannelNames[channelName] or ChannelNames[strlower(channelName)] or strsub(channelName, 1, 2)
			message = gsub(message, CHANNEL_PATTERN, format(CHANNEL_LINK, channelData, channelID, shortName))
		end

		local playerData, playerName = strmatch(message, PLAYER_PATTERN)
		if playerData then
			if db.RemoveRealmNames then
				if strmatch(playerName, "|cff") then
					playerName = gsub(playerName, "%-[^|]+", "")
				else
					playerName = strmatch(playerName, "[^%-]+")
				end
			end
			message = gsub(message, PLAYER_PATTERN, format(PLAYER_LINK, playerData, playerName))
		elseif channelID then
			-- WorldDefense messages don't have a sender; remove the extra colon and space.
			message = gsub(message, "(|Hchannel:.-|h): ", "%1", 1)
		end

		local bnData, bnName, bnID, bnExtra = strmatch(message, BNPLAYER_PATTERN)
		if bnData then
			if db.ReplaceRealNames or db.ShortenRealNames ~= "FULLNAME" then
				bnName = PhanxChat.bnetNames[tonumber(bnID) or ""] or bnName
				local toastIcon = strmatch(message, "|TInterface\\FriendsFrame\\UI%-Toast%-ToastIcons.-|t")
				-- [BN] John Doe ([WoW] Charguy) has come online. -> [WoW] Charguy has come online.
				-- |TInterface\\FriendsFrame\\UI-Toast-ToastIcons.tga:16:16:0:0:128:64:2:29:34:61|t|HBNplayer:|Kf5|k000000000000|k:5:1880:BN_INLINE_TOAST_ALERT:0|h[|Kf5|k000000000000|k] (|TInterface\\ChatFrame\\UI-ChatIcon-WOW:14:14:0:0|tCharname)|h has come online.
				if toastIcon then
					local gameIcon = strmatch(message, "|TInterface\\ChatFrame\\UI%-ChatIcon.-|t")
					if gameIcon then
						message = gsub(message, escape(toastIcon), gameIcon, 1)
						bnExtra = gsub(bnExtra, "%s?%(.-%)", "")
					end
				end
			end
			message = gsub(message, BNPLAYER_PATTERN, format(PLAYER_BN_LINK, bnData, bnName, bnExtra or ""))
		end
	end
	hooks[frame].AddMessage(frame, message, ...)
end

------------------------------------------------------------------------

local CHANNEL_HEADER = format(STRING_STYLE, CHANNEL_STYLE) .. "%s"
local CHANNEL_HEADER_PATTERN = "%[(%d+)%. ?([^%s:%-%]]+)[^%]]*%](.*)" -- see also CHAT_CHANNEL_SEND

hooksecurefunc("ChatEdit_UpdateHeader", function(editBox)
	local header = editBox.header -- _G[editBox:GetName() .. "Header"]
	if header and db.ShortenChannelNames and editBox:GetAttribute("chatType") == "CHANNEL" then
		local text = header:GetText()
		local channelID, channelName, headerSuffix = strmatch(text, CHANNEL_HEADER_PATTERN)
		if channelID then
			header:SetWidth(0)

			local shortName = ChannelNames[channelName] or ChannelNames[strlower(channelName)] or strsub(channelName, 1, 2)
			--print("UpdateHeader", text, "=>", channelID, '"'..channelName..'"', "=>", ChannelNames[channelName], "/", shortName)
			header:SetFormattedText(CHANNEL_HEADER, channelID, shortName, headerSuffix or "")

			local headerSuffix = editBox.headerSuffix -- _G[editBox:GetName() .. "HeaderSuffix"]
			local headerWidth = (header:GetRight() or 0) - (header:GetLeft() or 0)
			local editBoxWidth = editBox:GetRight() - editBox:GetLeft()
			if headerWidth * 2 > editBoxWidth then
				header:SetWidth(editBoxWidth / 2)
				headerSuffix:Show()
				editBox:SetTextInsets(21 + header:GetWidth() + headerSuffix:GetWidth(), 13, 0, 0)
			else
				headerSuffix:Hide()
				editBox:SetTextInsets(21 + header:GetWidth(), 13, 0, 0)
			end
		end
	end
end)

------------------------------------------------------------------------

local IsControlKeyDown, IsShiftKeyDown = IsControlKeyDown, IsShiftKeyDown

local bottomButton = setmetatable({}, { __index = function(t, self)
	local button = _G[self:GetName() .. "ButtonFrameBottomButton"]
	t[self] = button
	return button
end })

function FloatingChatFrame_OnMouseScroll(self, delta)
	if delta > 0 then
		if IsShiftKeyDown() then
			self:ScrollToTop()
		elseif IsControlKeyDown() then
			self:PageUp()
		else
			for i = 1, NUM_LINES_TO_SCROLL do
				self:ScrollUp()
			end
		end
	elseif delta < 0 then
		if IsShiftKeyDown() then
			self:ScrollToBottom()
		elseif IsControlKeyDown() then
			self:PageDown()
		else
			for i = 1, NUM_LINES_TO_SCROLL do
				self:ScrollDown()
			end
		end
	end

	if db.HideButtons then
		if self:AtBottom() then
			bottomButton[self]:Hide()
		else
			bottomButton[self]:Show()
		end
	end
end

------------------------------------------------------------------------

hooksecurefunc("ChatEdit_OnSpacePressed", function(editBox)
	if editBox.autoCompleteParams then
		return -- print("autoCompleteParams")
	end
	local command, message = strmatch(editBox:GetText(), "^/[tw]t (.*)")
	if command and UnitIsPlayer("target") and (UnitIsUnit("player", "target") or UnitCanCooperate("player", "target")) then
		editBox:SetAttribute("chatType", "WHISPER")
		editBox:SetAttribute("tellTarget", GetUnitName("target", true))
		editBox:SetText(message or "")
		ChatEdit_UpdateHeader(editBox)
	end
end)

SLASH_TELLTARGET1 = "/tt"
SLASH_TELLTARGET2 = "/wt"

SlashCmdList.TELLTARGET = function(message)
	if UnitIsPlayer("target") and (UnitIsUnit("player", "target") or UnitCanCooperate("player", "target")) then
		SendChatMessage(message, "WHISPER", nil, GetUnitName("target", true))
	elseif UnitExists("target") then
		DEFAULT_CHAT_FRAME:AddMessage(format("|cffffff00%s:|r %s", PHANXCHAT, L.Whisper_BadTarget))
	else
		DEFAULT_CHAT_FRAME:AddMessage(format("|cffffff00%s:|r %s", PHANXCHAT, L.Whisper_NoTarget))
	end
end

------------------------------------------------------------------------


SLASH_CLEARCHAT1 = "/clear"
SLASH_CLEARCHAT2 = "/clearchat"

SlashCmdList.CLEARCHAT = function(cmd)
	cmd = cmd and strtrim(strlower(cmd))
	for i = 1, NUM_CHAT_WINDOWS do
		local f = _G["ChatFrame"..i]
		if f:IsVisible() or cmd == "all" then
			f:Clear()
		end
	end
end

------------------------------------------------------------------------

function PhanxChat:ProcessFrame(frame)
	if frames[frame] then return end

	local history = {}
	for i = 1, frame:GetNumMessages() do
		local text, accessID, lineID, extraData = frame:GetMessageInfo(i)
		history[i] = text
	end
	frame:SetMaxLines(512)
	for i = 1, #history do
		frame:AddMessage(history[i])
	end

	frame:SetClampRectInsets(0, 0, 0, 0)
	frame:SetMaxResize(UIParent:GetWidth(), UIParent:GetHeight())
	frame:SetMinResize(200, 40)

	if self.debug then print("PhanxChat: ProcessFrame", frame:GetName()) end

	if frame ~= COMBATLOG then
		if not hooks[frame] then
			hooks[frame] = {}
		end
		if not hooks[frame].AddMessage then
			hooks[frame].AddMessage = frame.AddMessage
			frame.AddMessage = AddMessage
		end
	end

	-- #TODO: Move this to a separate module?
	if db.FontSize then
		FCF_SetChatWindowFontSize(nil, frame, db.FontSize)
	end

	if not self.isLoading then
		for _, func in ipairs(self.RunOnProcessFrame) do
			func(self, frame)
		end
	end

	frames[frame] = true
end

for i = 1, NUM_CHAT_WINDOWS do
	_G["ChatFrame" .. i]:SetClampRectInsets(0, 0, 0, 0)
end

FCF_ValidateChatFramePosition = noop

------------------------------------------------------------------------

function PhanxChat:ADDON_LOADED(addon)
	if addon ~= PHANXCHAT then return end
	if self.debug then print("PhanxChat: ADDON_LOADED") end

	self.defaults = {
		EnableArrows        = true,
		EnableResizeEdges   = true,
		EnableSticky        = "ALL", -- ALL, BLIZZARD, NONE
		FadeTime            = 1, -- minutes; 0 disables fading
		HideButtons         = true,
		HideFlash           = false,
		HideNotices         = false,
		HidePetCombatLog    = true,
		HideRepeats         = true,
		HideTextures        = true,
		LinkURLs            = true,
		LockTabs            = true,
		MoveEditBox         = true,
		RemoveRealmNames    = true,
		ReplaceRealNames    = true,
		ShortenChannelNames = true,
		ShortenRealNames    = "FIRSTNAME", -- BATTLETAG, FIRSTNAME, FULLNAME
	}

	if not PhanxChatDB then
		PhanxChatDB = {}
	end
	self.db = PhanxChatDB
	db = PhanxChatDB -- faster access for AddMessage

	for k, v in pairs(self.defaults) do
		if type(db[k]) ~= type(v) then
			db[k] = v
		end
	end

	self.isLoading = true

	for i = 1, NUM_CHAT_WINDOWS do
		self:ProcessFrame(_G["ChatFrame" .. i])
	end

	hooks.FCF_OpenTemporaryWindow = FCF_OpenTemporaryWindow
	FCF_OpenTemporaryWindow = function(chatType, ...)
		if chatType == "PET_BATTLE_COMBAT_LOG" and db.HidePetCombatLog then
			return
		end
		local frame = hooks.FCF_OpenTemporaryWindow(chatType, ...)
		self:ProcessFrame(frame)
		return frame
	end

	for i = 1, #self.RunOnLoad do
		self.RunOnLoad[i](self)
	end

	self.isLoading = nil

	self:UnregisterEvent("ADDON_LOADED")
	self.ADDON_LOADED = nil
end

------------------------------------------------------------------------

PhanxChat.frame = CreateFrame("Frame")
PhanxChat.frame:RegisterEvent("ADDON_LOADED")
PhanxChat.frame:SetScript("OnEvent", function(self, event, ...)
	-- print("PhanxChat: " .. event)
	return PhanxChat[event] and PhanxChat[event](PhanxChat, ...)
end)

function PhanxChat:RegisterEvent(event) return self.frame:RegisterEvent(event) end
function PhanxChat:UnregisterEvent(event) return self.frame:UnregisterEvent(event) end

------------------------------------------------------------------------

_G.PhanxChat = PhanxChat

SLASH_RELOADUI1 = "/rl"
SlashCmdList.RELOADUI = ReloadUI
