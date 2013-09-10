local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Chat Autolog")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Chat Autolog"]

function mod:OnEnable()
	self.isLogging = LoggingChat()
	LoggingChat(true)
end

function mod:OnDisable()
	LoggingChat(self.isLogging)
end

function mod:Info()
	return L["Automatically turns on chat logging."]
end
