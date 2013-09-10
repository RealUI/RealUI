local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Disable Fading")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Disable Fading"]
mod.toggleLabel = L["Disable Fading"]

function mod:Decorate(cf)
	cf:SetFading(nil)
end

function mod:OnEnable()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		cf:SetFading(nil)
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			cf:SetFading(nil)
		end
	end
end

function mod:OnDisable()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		cf:SetFading(true)
	end
	for index,name in ipairs(self.TempChatFrames) do
		local cf = _G[name]
		if cf then
			cf:SetFading(true)
		end
	end
end

function mod:Info()
	return L["Makes old text disappear rather than fade out"]
end
