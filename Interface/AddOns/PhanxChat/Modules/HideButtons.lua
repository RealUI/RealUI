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

local noop = function() end

------------------------------------------------------------------------

local function BottomButton_OnClick(self, button)
	PlaySound("igChatBottom")
	local frame = self:GetParent()
	if frame.ScrollToBottom then
		frame:ScrollToBottom()
	else
		frame:GetParent():ScrollToBottom()
	end
	_G[frame:GetName() .. "ButtonFrameBottomButton"]:Hide()
end

local function ChatFrame_OnShow(self)
	if not PhanxChat.db.HideButtons then return end
	if self:AtBottom() then
		_G[self:GetName() .. "ButtonFrameBottomButton"]:Hide()
	else
		_G[self:GetName() .. "ButtonFrameBottomButton"]:Show()
	end
end

function PhanxChat:HideButtons(frame)
	local name = frame:GetName()
	local buttonFrame = _G[name .. "ButtonFrame"]
	local upButton = _G[name .. "ButtonFrameUpButton"]
	local downButton = _G[name .. "ButtonFrameDownButton"]
	local bottomButton = _G[name .. "ButtonFrameBottomButton"]

	frame:HookScript("OnShow", ChatFrame_OnShow)

	if self.db.HideButtons then
		buttonFrame.Show = noop
		buttonFrame:Hide()

		upButton.Show = noop
		upButton:Hide()

		downButton.Show = noop
		downButton:Hide()

		bottomButton:ClearAllPoints()
		bottomButton:SetParent(frame)
		bottomButton:SetPoint("BOTTOMRIGHT", frame, "BOTTOMRIGHT", 0, -4)
		bottomButton:SetAlpha(0.75)
		bottomButton:Hide()

		if not self.hooks[bottomButton] then
			self.hooks[bottomButton] = { }
		end
		if not self.hooks[bottomButton].OnClick then
			self.hooks[bottomButton].OnClick = bottomButton:GetScript("OnClick")
			bottomButton:SetScript("OnClick", BottomButton_OnClick)
		end
	else
		buttonFrame.Show = nil
		buttonFrame:Show()

		upButton.Show = nil
		upButton:Show()

		downButton.Show = nil
		downButton:Show()

		bottomButton:ClearAllPoints()
		bottomButton:SetParent(buttonFrame)
		bottomButton:SetPoint("BOTTOM", buttonFrame, "BOTTOM", 0, -7)
		bottomButton:SetAlpha(1)
		bottomButton:Show()

		if self.hooks[bottomButton] and self.hooks[bottomButton].OnClick then
			bottomButton:SetScript("OnClick", self.hooks[bottomButton].OnClick)
			self.hooks[bottomButton].OnClick = nil
		end

		FCF_UpdateButtonSide(frame)
	end
end

------------------------------------------------------------------------

function PhanxChat:SetHideButtons(v)
	if self.debug then print("PhanxChat: SetHideButtons", v) end
	if type(v) == "boolean" then
		self.db.HideButtons = v
	end

	for frame in pairs(self.frames) do
		self:HideButtons(frame)
	end

	if self.db.HideButtons then
		ChatFrameMenuButton:SetScript("OnShow", ChatFrameMenuButton.Hide)
		ChatFrameMenuButton:Hide()

		QuickJoinToastButton:SetScript("OnShow", QuickJoinToastButton.Hide)
		QuickJoinToastButton:Hide()

		if not self.hooks.BN_TOAST_LEFT_OFFSET then
			self.hooks.BN_TOAST_LEFT_OFFSET = BN_TOAST_LEFT_OFFSET
			BN_TOAST_LEFT_OFFSET = BN_TOAST_LEFT_OFFSET + ChatFrame1ButtonFrame:GetWidth() + 5
		end
	elseif not self.isLoading then
		ChatFrameMenuButton:SetScript("OnShow", nil)
		ChatFrameMenuButton:Show()

		QuickJoinToastButton:SetScript("OnShow", nil)
		QuickJoinToastButton:Show()

		if self.hooks.BN_TOAST_LEFT_OFFSET then
			BN_TOAST_LEFT_OFFSET = self.hooks.BN_TOAST_LEFT_OFFSET
			self.hooks.BN_TOAST_LEFT_OFFSET = nil
		end
	end
end

BNToastFrame:SetClampedToScreen(true)

table.insert(PhanxChat.RunOnLoad, PhanxChat.SetHideButtons)
table.insert(PhanxChat.RunOnProcessFrame, PhanxChat.HideButtons)
