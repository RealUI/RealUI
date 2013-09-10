local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Automatic Whisper Windows", "AceHook-3.0", "AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Automatic Whisper Windows"]

function mod:OnEnable()
	self:RegisterEvent("CHAT_MSG_WHISPER","ProcessWhisper")
	self:RegisterEvent("CHAT_MSG_WHISPER_INFORM","ProcessWhisper")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER_INFORM", "ProcessWhisper")
	self:RegisterEvent("CHAT_MSG_BN_WHISPER","ProcessWhisper")
end

function mod:OnDisable()
	self:UnregisterEvent("CHAT_MSG_WHISPER")
	self:UnregisterEvent("CHAT_MSG_WHISPER_INFORM")
	self:UnregisterEvent("CHAT_MSG_BNWHISPER")
	self:UnregisterEvent("CHAT_MSG_BNWHISPER_INFORM")
end

function mod:AlwaysDecorate(frame)
	if not self:IsEnabled() then
		local t = frame.chatType
		local a = frame.chatTarget
		local accessID = ChatHistory_GetAccessID(t, a)
		local chatFrame = nil
		for i= 1,NUM_CHAT_WINDOWS do
			local cf = _G["ChatFrame"..i]
			local i = cf:GetNumMessages(accessID)
			if i > 0 then
				chatFrame = cf
			end
		end
		if chatFrame then
			Chatter.loading = true
			for i = 1, chatFrame:GetNumMessages(accessID) do
				local text, accessID, lineID, extraData = chatFrame:GetMessageInfo(i, accessID);
				local cType, cTarget = ChatHistory_GetChatType(extraData);
				local info = ChatTypeInfo[cType];
				frame:AddMessage(text, info.r, info.g, info.b, lineID, false, accessID, extraData);
			end
			Chatter.loading = false
		end
	end
end


function mod:ProcessWhisper(event,message,sender,language,channelString,target,flags,arg7,arg8,...)
	-- Do we have a temp window already for this target
	local type = "WHISPER"
	if event == "CHAT_MSG_BN_WHISPER" or event == "CHAT_MSG_BN_WHISPER_INFORM" then
		type = "BN_WHISPER"
	end
	if FCFManager_GetNumDedicatedFrames(type, sender) == 0 then
		local chatFrame = nil
		local foundSrc = false
		local accessID = ChatHistory_GetAccessID(type, sender)
		for i= 1,NUM_CHAT_WINDOWS do
			local cf = _G["ChatFrame"..i]
			if not foundSrc then
				for i = 1, cf:GetNumMessages(accessID) do
					chatFrame = cf
					foundSrc = true
				end
			end
		end
		if not chatFrame then
			return true
		end
		Chatter.loading = true
		local t = FCF_OpenTemporaryWindow(type, sender, chatFrame, true)
		-- lets hand copy the shit over
		for i = 1, chatFrame:GetNumMessages(accessID) do
			local text, accessID, lineID, extraData = chatFrame:GetMessageInfo(i, accessID);
			local cType, cTarget = ChatHistory_GetChatType(extraData);
			local info = ChatTypeInfo[cType];
			t:AddMessage(text, info.r, info.g, info.b, lineID, false, accessID, extraData);
		end
		Chatter.loading = false
		-- was a fix for an issue in the editbox, no longer needed
		--for i=1,NUM_CHAT_WINDOWS do
		--	local cf = _G["ChatFrame"..i.."EditBox"]
		--	cf:Show()
		--end
	end
end
