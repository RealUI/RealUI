--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
	https://github.com/Phanx/PhanxChat
----------------------------------------------------------------------]]

local _, PhanxChat = ...
local L = PhanxChat.L

function PhanxChat:SetShowClassColors(enable)
	if type(enable) == "boolean" then
		self.db.ShowClassColors = enable
	else
		enable = self.db.ShowClassColors
	end
	if self.debug then print("PhanxChat: SetShowClassColors", enable) end
	self:ClearBNetNameCache()

	for i = 1, #CHAT_CONFIG_CHAT_LEFT do
		ToggleChatColorNamesByClassGroup(enable, CHAT_CONFIG_CHAT_LEFT[i].type)
		local checkbox = _G["ChatConfigChatSettingsLeftCheckBox"..i.."ColorClasses"]
		if checkbox then
			checkbox:SetChecked(enable)
			checkbox:Disable()
			checkbox:SetMotionScriptsWhileDisabled(true)
			checkbox.tooltip = format(L.OptionLocked, L.ShowClassColors)
		end
	end

	for i = 1, 50 do
		ToggleChatColorNamesByClassGroup(enable, "CHANNEL"..i)
		local checkbox = _G["ChatConfigChannelSettingsLeftCheckBox"..i.."ColorClasses"]
		if checkbox then
			checkbox:SetChecked(enable)
			checkbox:Disable()
			checkbox:SetMotionScriptsWhileDisabled(true)
			checkbox.tooltip = format(L.OptionLocked, L.ShowClassColors)
		end
	end
end

tinsert(PhanxChat.RunOnLoad, PhanxChat.SetShowClassColors)

hooksecurefunc("ChatConfig_UpdateCheckboxes", function(frame)
	if frame == ChatConfigChatSettingsLeft or frame == ChatConfigChannelSettingsLeft then
		PhanxChat:SetShowClassColors()
	end
end)