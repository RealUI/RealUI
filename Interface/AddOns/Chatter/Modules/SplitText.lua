local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Message Splitting", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Message Split"]

function mod:Info()
	return L["Allows you to type messages longer than normal, and splits message that are too long."]
end

local function ChatEdit_SendText(editBox, addHistory, doParse)
	if doParse then
		ChatEdit_ParseText(editBox, 1);
	end

	local type = editBox:GetAttribute("chatType");
	local text = editBox:GetText();
	if ( strfind(text, "%s*[^%s]+") ) then
		if ( type == "WHISPER") then
			local target = editBox:GetAttribute("tellTarget");
			ChatEdit_SetLastToldTarget(target);
			SendChatMessage(text, type, editBox.language, target);
		elseif ( type == "CHANNEL") then
			SendChatMessage(text, type, editBox.language, editBox:GetAttribute("channelTarget"));
		else
			SendChatMessage(text, type, editBox.language);
		end
		if ( addHistory ) then
			ChatEdit_AddHistory(editBox);
		end
	end
end

local MAX = 256
local getChunk
do
	local buf = {}
	function getChunk(text, start)
		local stack = 0
		local first = nil
		buf = wipe(buf)
		if start > #text then return nil end
		for i = start, start + MAX - 1 do
			local byte = text:sub(i, i)
			local bit = text:sub(i, i+1)
			if bit == "|c" or bit == "|H" then
				first = first or i
				stack = stack + 1
			elseif (bit == "|r" or bit == "|h") and stack > 0 and first then
				stack = stack - 1
				if stack == 0 then
					tinsert(buf, text:sub(first, i))
					first = nil
				end
			elseif (byte == " " or byte == "") and stack == 0 and first then
				tinsert(buf, text:sub(first or 1, i))
				first = nil
			else
				first = first or i
			end
		end
		if #buf == 0 then return nil end
		local str = table.concat(buf, "")
		return start + #str, str
	end
end

function mod:OnEnterPressed(editBox)
	local text = editBox:GetText()
	if #text <= 255 then
		ChatEdit_OnEnterPressed(editBox)
		return
	end
	
	local first = true
	for start, chunk in getChunk, text, 1 do
		editBox:SetText(chunk)
		ChatEdit_SendText(editBox, true, first);
		first = false
	end

	local type = editBox:GetAttribute("chatType");
	if ( ChatTypeInfo[type].sticky == 1 ) then
		editBox:SetAttribute("stickyType", type);
	end
	
	ChatEdit_OnEscapePressed(editBox);
end

function mod:OnEnable()
	ChatFrameEditBox:SetMaxLetters(2048)
	ChatFrameEditBox:SetMaxBytes(2048)
	
	self:RawHookScript(ChatFrameEditBox, "OnEnterPressed")
end

function mod:OnDisable()
	ChatFrameEditBox:SetMaxLetters(256)
	ChatFrameEditBox:SetMaxBytes(256)
end
