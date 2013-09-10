local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Link Hover", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Link Hover"]

local strmatch = _G.string.match
local linkTypes = {
	item = true,
	enchant = true,
	spell = true,
	quest = true,
	-- player = true
}

function mod:Decorate(frame)
	self:HookScript(frame, "OnHyperlinkEnter", OnHyperlinkEnter)
	self:HookScript(frame, "OnHyperlinkLeave", OnHyperlinkLeave)
end

function mod:OnEnable()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		self:HookScript(frame, "OnHyperlinkEnter", OnHyperlinkEnter)
		self:HookScript(frame, "OnHyperlinkLeave", OnHyperlinkLeave)
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			self:HookScript(cf, "OnHyperlinkEnter", OnHyperlinkEnter)
			self:HookScript(cf, "OnHyperlinkLeave", OnHyperlinkLeave)
		end
	end
end

function mod:OnDisable()
	for i = 1, NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		self:Unhook(frame, "OnHyperlinkEnter")
		self:Unhook(frame, "OnHyperlinkLeave")
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			self:Unhook(cf, "OnHyperlinkEnter")
			self:Unhook(cf, "OnHyperlinkLeave")
		end
	end
end

function mod:OnHyperlinkEnter(f, link)
	local t = strmatch(link, "^(.-):")
	if linkTypes[t] then
		ShowUIPanel(GameTooltip)
		GameTooltip:SetOwner(UIParent, "ANCHOR_CURSOR")
		GameTooltip:SetHyperlink(link)
		GameTooltip:Show()
	end			
end

function mod:OnHyperlinkLeave(f, link)
	local t = strmatch(link, "^(.-):")
	if linkTypes[t] then
		HideUIPanel(GameTooltip)
	end
end

function mod:Info()
	return L["Makes link tooltips show when you hover them in chat."]
end
