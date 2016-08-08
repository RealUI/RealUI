--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
	https://github.com/Phanx/PhanxChat
----------------------------------------------------------------------]]

local _, PhanxChat = ...
local noop = function() return end

function PhanxChat:HideFlash(frame)
	local flash = _G[frame:GetName() .. "TabFlash"]
	if self.db.HideFlash then
		flash:SetScript("OnShow", flash.Hide)
		flash:Hide()
	else
		flash:SetScript("OnShow", nil)
	end
end

function PhanxChat:SetHideFlash(v)
	if self.debug then print("PhanxChat: SetHideFlash", v) end
	if type(v) == "boolean" then
		self.db.HideFlash = v
	end

	for frame in pairs(self.frames) do
		self:HideFlash(frame)
	end

	if self.db.HideFlash then
		if not self.hooks.FCF_FlashTab then
			self.hooks.FCF_FlashTab = FCF_FlashTab
			FCF_FlashTab = noop
		end
		if not self.hooks.FCF_StartAlertFlash then
			self.hooks.FCF_StartAlertFlash = FCF_StartAlertFlash
			FCF_StartAlertFlash = noop
		end
		if not self.hooks.FCF_StopAlertFlash then
			self.hooks.FCF_StopAlertFlash = FCF_StopAlertFlash
			FCF_StopAlertFlash = noop
		end
	elseif not self.isLoading then
		if self.hooks.FCF_FlashTab then
			FCF_FlashTab = self.hooks.FCF_FlashTab
			self.hooks.FCF_FlashTab = nil
		end
		if self.hooks.FCF_StartAlertFlash then
			FCF_StartAlertFlash = self.hooks.FCF_StartAlertFlash
			self.hooks.FCF_StartAlertFlash = nil
		end
		if self.hooks.FCF_StopAlertFlash then
			FCF_StopAlertFlash = self.hooks.FCF_StopAlertFlash
			self.hooks.FCF_StopAlertFlash = nil
		end
	end
end

table.insert(PhanxChat.RunOnLoad, PhanxChat.SetHideFlash)
table.insert(PhanxChat.RunOnProcessFrame, PhanxChat.HideFlash)