--[[--------------------------------------------------------------------
	PhanxChat
	Reduces chat frame clutter and enhances chat frame functionality.
	Copyright (c) 2006-2016 Phanx <addons@phanx.net>. All rights reserved.
	http://www.wowinterface.com/downloads/info6323-PhanxChat.html
	http://www.curse.com/addons/wow/phanxchat
	https://github.com/Phanx/PhanxChat
----------------------------------------------------------------------]]

local _, PhanxChat = ...
local hooks = PhanxChat.hooks
local noop = function() end

local SELECTED_TAB_COLOR = { r = 1, g = 1, b = 1 }

local function Tab_OnEnter(tab)
	hooks[tab].OnEnter(tab)
	if tab.frame.selected then return end
	tab.text:SetTextColor(1, 1, 1)
end

local function Tab_OnLeave(tab)
	hooks[tab].OnLeave(tab)
	GameTooltip_Hide()
	if tab.frame.selected then return end
	tab.text:SetTextColor(1, 0.8, 0)
end

local function Tab_OnClick(tab, button)
	hooks.FCF_Tab_OnClick(tab, button)

	local selected = SELECTED_CHAT_FRAME
	for frame in pairs(PhanxChat.frames) do
		frame.selected = frame == selected
		if frame.selected then
			frame.tab.text:SetTextColor(1, 1, 1)
			frame.tab.fullHighlightTexture:SetAlpha(0)
		else
			frame.tab.text:SetTextColor(1, 0.8, 0)
			frame.tab.fullHighlightTexture:SetAlpha(1)
		end
	end
end

local function Tab_UpdateColors(tab, selected)
	hooks.FCFTab_UpdateColors(tab, selected)

	local selected = SELECTED_CHAT_FRAME
	for frame in pairs(PhanxChat.frames) do
		frame.selected = frame == selected
		if frame.selected then
			frame.tab.text:SetTextColor(1, 1, 1)
			frame.tab.fullHighlightTexture:SetAlpha(0)
		else
			frame.tab.text:SetTextColor(1, 0.8, 0)
			frame.tab.fullHighlightTexture:SetAlpha(1)
		end
	end
end

local function Tab_Text_GetWidth(text)
	local tab = text:GetParent()
	if tab.conversationIcon then
		return text:GetStringWidth() + 18
	end
	return text:GetStringWidth()
end

function PhanxChat:HideTextures(frame)
	local selected = frame == SELECTED_CHAT_FRAME
	frame.selected = selected

	if not frame.tab then
		local name = frame:GetName()

		local tab =  _G[name .. "Tab"]
		tab.frame = frame
		tab.left  = _G[name .. "TabLeft"]
		tab.right = _G[name .. "TabRight"]
		tab.mid   = _G[name .. "TabMiddle"]
		tab.text  = _G[name .. "TabText"]
		frame.tab = tab

		local editBox = frame.editBox
		editBox.left  = _G[name .. "EditBoxLeft"]
		editBox.right = _G[name .. "EditBoxRight"]
		editBox.mid   = _G[name .. "EditBoxMid"]

		local highlight = tab:CreateTexture(nil, "HIGHLIGHT")
		highlight:SetTexture([[Interface\PaperDollInfoFrame\UI-Character-Tab-Highlight]])
		highlight:SetBlendMode("ADD")
		highlight:SetPoint("LEFT", 0, -7)
		highlight:SetPoint("RIGHT", 0, -7)
		tab.fullHighlightTexture = highlight

		hooks[tab] = { }
	end

	if self.db.HideTextures then
		frame.clickAnywhereButton:SetScript("OnShow", frame.clickAnywhereButton.Hide)
		frame.clickAnywhereButton:Hide()

		local editBox = frame.editBox

		if editBox then
			editBox.left:SetAlpha(0)
			editBox.right:SetAlpha(0)
			editBox.mid:SetAlpha(0)

			editBox.focusLeft:SetTexture([[Interface\ChatFrame\UI-ChatInputBorder-Left2]])
			editBox.focusRight:SetTexture([[Interface\ChatFrame\UI-ChatInputBorder-Right2]])
			editBox.focusMid:SetTexture([[Interface\ChatFrame\UI-ChatInputBorder-Mid2]])
		end

		local tab = frame.tab

		tab.noMouseAlpha = 0
		FCFTab_UpdateAlpha(frame)

		tab.leftSelectedTexture:SetAlpha(0)
		tab.middleSelectedTexture:SetAlpha(0)
		tab.rightSelectedTexture:SetAlpha(0)

		tab.leftHighlightTexture:SetAlpha(0)
		tab.middleHighlightTexture:SetAlpha(0)
		tab.rightHighlightTexture:SetAlpha(0)

		tab.fullHighlightTexture:SetAlpha(selected and 0 or 1)

		local tabText = tab.text
		local tabIcon = tab.conversationIcon

		if tabIcon then
			tabIcon:ClearAllPoints()
			tabIcon:SetPoint("LEFT", tab, 16, -7)
		end

		tabText:ClearAllPoints()
		if tabIcon then
			tabText:SetPoint("LEFT", tabIcon, "RIGHT", 2, 0)
		else
			tabText:SetPoint("LEFT", tab, 16, -7)
		end
		tabText:SetPoint("RIGHT", tab, -16, -7)
		tabText:SetJustifyH("LEFT")
		tabText.GetWidth = Tab_Text_GetWidth

		if selected then
			tabText:SetTextColor(1, 1, 1)
		else
			tabText:SetTextColor(1, 0.8, 1)
		end

		if not hooks.FCF_Tab_OnClick then
			hooks.FCF_Tab_OnClick = FCF_Tab_OnClick
			FCF_Tab_OnClick = Tab_OnClick
		end
		if not hooks.FCFTab_UpdateColors then
			hooks.FCFTab_UpdateColors = FCFTab_UpdateColors
			FCFTab_UpdateColors = Tab_UpdateColors
		end
		if not hooks[tab].OnEnter then
			hooks[tab].OnEnter = tab:GetScript("OnEnter")
			tab:SetScript("OnEnter", Tab_OnEnter)
		end
		if not hooks[tab].OnLeave then
			hooks[tab].OnLeave = tab:GetScript("OnLeave")
			tab:SetScript("OnLeave", Tab_OnLeave)
		end
	else
		frame.clickAnywhereButton:SetScript("OnShow", nil)
		frame.clickAnywhereButton:Show()

		local editBox = frame.editBox

		if editBox then
			editBox.left:SetAlpha(1)
			editBox.right:SetAlpha(1)
			editBox.mid:SetAlpha(1)

			editBox.focusLeft:SetTexture([[Interface\ChatFrame\UI-ChatInputBorderFocus-Left]])
			editBox.focusRight:SetTexture([[Interface\ChatFrame\UI-ChatInputBorderFocus-Right]])
			editBox.focusMid:SetTexture([[Interface\ChatFrame\UI-ChatInputBorderFocus-Mid]])
		end

		local tab = frame.tab

		tab.noMouseAlpha = 0.4
		FCFTab_UpdateAlpha(frame)

		tab.leftSelectedTexture:SetAlpha(1)
		tab.rightSelectedTexture:SetAlpha(1)
		tab.middleSelectedTexture:SetAlpha(1)

		tab.leftHighlightTexture:SetAlpha(1)
		tab.rightHighlightTexture:SetAlpha(1)
		tab.middleHighlightTexture:SetAlpha(1)

		tab.fullHighlightTexture:SetAlpha(0)

		local tabText = tab.text
		local tabIcon = tab.conversationIcon

		tabText.GetWidth = nil
		tabText:ClearAllPoints()
		if tabIcon then
			tabText:SetPoint("RIGHT", tab.leftTexture, "RIGHT", 10, -6)

			tabIcon:ClearAllPoints()
			tabIcon:SetPoint("RIGHT", tabText, "LEFT", 0, -2)
		else
			tabText:SetPoint("LEFT", tab.left, "RIGHT", 0, -5)
		end

		tabText:SetTextColor(1, 0.8, 0)

		if hooks.FCF_Tab_OnClick then
			FCF_Tab_OnClick = hooks.FCF_Tab_OnClick
			hooks.FCF_Tab_OnClick = nil
		end
		if hooks.FCFTab_UpdateColors then
			FCFTab_UpdateColors = hooks.FCFTab_UpdateColors
			hooks.FCFTab_UpdateColors = nil
			FCFTab_UpdateColors(tab, selected)
		end
		local enter = hooks[tab].OnEnter
		if enter then
			tab:SetScript("OnEnter", enter)
			hooks[tab].OnEnter = nil
		end
		local leave = hooks[tab].OnLeave
		if leave then
			tab:SetScript("OnLeave", leave)
			hooks[tab].OnLeave = nil
		end
	end

	PanelTemplates_TabResize(frame.tab, frame.tab.sizePadding or 0)
	frame.tab.textWidth = frame.tab.text:GetWidth()
end

hooksecurefunc("PanelTemplates_TabResize", function(tab, padding, dynTabSize)
	if dynTabSize and tab.conversationIcon and PhanxChat.db.HideTextures then
		PanelTemplates_TabResize(tab, tab.sizePadding or 0)
	end
end)

function PhanxChat:SetHideTextures(v)
	if self.debug then print("PhanxChat: SetHideTextures", v) end
	if type(v) == "boolean" then
		self.db.HideTextures = v
	end

	for frame in pairs(self.frames) do
		self:HideTextures(frame)
	end
end

table.insert(PhanxChat.RunOnLoad, PhanxChat.SetHideTextures)
table.insert(PhanxChat.RunOnProcessFrame, PhanxChat.HideTextures)