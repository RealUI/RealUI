local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Server Positioning", "AceHook-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Server Positioning"]
mod.toggleLabel = L["Disable Server Positioning"]

local defaults = {
	profile = {
		windowdata = {
			['*'] = {
				-- Blizzard defaults
				width = 430,
				height = 120,
			}
		}
	}
}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("Server Positioning", defaults)
	self.db.RegisterCallback(self, "OnProfileChanged", "UpdateWindowData")
	self.db.RegisterCallback(self, "OnProfileCopied", "UpdateWindowData")
	self.db.RegisterCallback(self, "OnProfileReset", "UpdateWindowData")
end

function mod:Info()
	return L["Disable server side storage of chat frame position and size."]
end

function mod:OnEnable()
	self:RawHook('SetChatWindowSavedPosition', true)
	self:RawHook('GetChatWindowSavedPosition', true)
	self:RawHook('SetChatWindowSavedDimensions', true)
	self:RawHook('GetChatWindowSavedDimensions', true)
	self:UpdateWindowData()
end

function mod:OnDisable()
	self:UnhookAll()
	self:UpdateWindowData()
end

function mod:SetChatWindowSavedPosition(id, point, xOffset, yOffset)
	local data = self.db.profile.windowdata[id]
	data.point, data.xOffset, data.yOffset = point, xOffset, yOffset
end

function mod:GetChatWindowSavedPosition(id)
	local data = self.db.profile.windowdata[id]
	if not data.point then
		data.point, data.xOffset, data.yOffset = self.hooks.GetChatWindowSavedPosition(id)
	end
	return data.point, data.xOffset, data.yOffset
end

function mod:SetChatWindowSavedDimensions(id, width, height)
	local data = self.db.profile.windowdata[id]
	data.width, data.height = width, height
end

function mod:GetChatWindowSavedDimensions(id)
	local data = self.db.profile.windowdata[id]
	if not data.width then
		data.width, data.height = self.hooks.GetChatWindowSavedDimensions(id)
	end
	return data.width, data.height
end

function mod:UpdateWindowData()
	for i = 1,NUM_CHAT_WINDOWS do
		local frame = _G["ChatFrame"..i]
		if frame and type(frame.GetID) == "function" then
			FloatingChatFrame_Update(frame:GetID())
		end
	end
end
