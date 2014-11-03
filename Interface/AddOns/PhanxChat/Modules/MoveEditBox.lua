--[[--------------------------------------------------------------------
PhanxChat
Reduces chat frame clutter and enhances chat frame functionality.
Copyright (c) 2006-2014 Phanx <addons@phanx.net>. All rights reserved.
See the accompanying README and LICENSE files for more information.
http://www.wowinterface.com/downloads/info6323-PhanxChat.html
http://www.curse.com/addons/wow/phanxchat
----------------------------------------------------------------------]]

local _, PhanxChat = ...
local L = PhanxChat.L
local F, C = unpack(Aurora)
local alpha
local RealUIStripeOpacity = 0.5

InterfaceOptionsSocialPanelChatStyle:HookScript("OnEnter", function(this)
	if PhanxChat.db.MoveEditBox then
		GameTooltip:AddLine(format(L.OptionLockedConditional, L.MoveEditBox), 1, 1, 1, true)
		GameTooltip:Show()
	end
end)

function PhanxChat:MoveEditBox(frame)
	local editBox = frame.editBox or _G[frame:GetName() .. "EditBox"]
	if not editBox then return end
	
	if self.db.MoveEditBox then
		editBox:ClearAllPoints()
		editBox:SetPoint("BOTTOMLEFT", frame, "TOPLEFT", 2, 22)
		editBox:SetPoint("BOTTOMRIGHT", frame, "TOPRIGHT", -2, 22)
		
		--------------------------------------------------------
		-- Modify the editbox
		
		for k = 6, 11 do
			select(k, editBox:GetRegions()):SetTexture(nil)
		end		
		F.CreateBD(editBox)
		
		-- xRUI
		editBox:SetBackdropColor(RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3], RealUI.media.window[4])
		
		-- Stripes xRUI
		if not editBox.stripeTex then
			editBox.stripeTex = editBox:CreateTexture(nil, "BACKGROUND", nil, 1)
			editBox.stripeTex:SetAllPoints()
			editBox.stripeTex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true)
			editBox.stripeTex:SetHorizTile(true)
			editBox.stripeTex:SetVertTile(true)
			editBox.stripeTex:SetBlendMode("ADD")
			editBox.stripeTex:SetAlpha(RealUI.db.profile.settings.stripeOpacity)
			tinsert(REALUI_STRIPE_TEXTURES, editBox.stripeTex)
		end
		
		hooksecurefunc('ChatEdit_UpdateHeader', function(editBox)
			local type = editBox:GetAttribute('chatType')
			if (not type) then
				return
			end
			
			local info = ChatTypeInfo[type]
			editBox:SetBackdropBorderColor(info.r, info.g, info.b)
		end)
		--------------------------------------------------------
		
		SetCVar("chatStyle", "classic")
		InterfaceOptionsSocialPanelChatStyle_SetChatStyle("classic")
		
		InterfaceOptionsSocialPanelChatStyleButton:Disable()
		InterfaceOptionsSocialPanelChatStyleLabel:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
		InterfaceOptionsSocialPanelChatStyleText:SetVertexColor(GRAY_FONT_COLOR.r, GRAY_FONT_COLOR.g, GRAY_FONT_COLOR.b)
	else
		editBox:ClearAllPoints()
		editBox:SetPoint("TOPLEFT", frame, "BOTTOMLEFT", -5, -2)
		editBox:SetPoint("TOPRIGHT", frame, "BOTTOMRIGHT", 5, -2)
		
		InterfaceOptionsSocialPanelChatStyleButton:Enable()
		InterfaceOptionsSocialPanelChatStyleLabel:SetVertexColor(NORMAL_FONT_COLOR.r, NORMAL_FONT_COLOR.g, NORMAL_FONT_COLOR.b)
		InterfaceOptionsSocialPanelChatStyleText:SetVertexColor(HIGHLIGHT_FONT_COLOR.r, HIGHLIGHT_FONT_COLOR.g, HIGHLIGHT_FONT_COLOR.b)
	end
end

function PhanxChat:SetMoveEditBox(v)
	if self.debug then print("PhanxChat: SetMoveEditBox", v) end
	if type(v) == "boolean" then
		self.db.MoveEditBox = v
	end
	
	for frame in pairs(self.frames) do
		self:MoveEditBox(frame)
	end
end

table.insert(PhanxChat.RunOnLoad, PhanxChat.SetMoveEditBox)
table.insert(PhanxChat.RunOnProcessFrame, PhanxChat.MoveEditBox)