local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Sticky Channels")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Sticky Channels"]

local pairs = _G.pairs

local channels = {
	SAY = L["Say"],
	EMOTE = L["Emote"],
	YELL = L["Yell"],
	OFFICER = L["Officer"],
	RAID_WARNING = L["Raid Warning"],
	WHISPER = L["Whisper"],
	BN_WHISPER = L["RealID Whisper"],
	CHANNEL = L["Custom channels"]
}
local options = {}
local defaults = {profile = {}}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("StickyChannels", defaults)
	for k, v in pairs(channels) do
		defaults.profile[k] = true
		options[k] = {
			type = "toggle",
			name = v,
			desc = (L["Make %s sticky"]):format(v),
			get = function() return mod.db.profile[k] end,
			set = function(info, v)
				mod.db.profile[k] = v
				ChatTypeInfo[k].sticky = v and 1 or 0
			end
		}
	end
end

function mod:OnEnable()
	for k, v in pairs(channels) do
		ChatTypeInfo[k].sticky = self.db.profile[k] and 1 or 0
	end
end

function mod:OnDisable()
	ChatTypeInfo.EMOTE.sticky = 0
	ChatTypeInfo.YELL.sticky = 0
	ChatTypeInfo.OFFICER.sticky = 0
	ChatTypeInfo.RAID_WARNING.sticky = 0
	ChatTypeInfo.WHISPER.sticky = 0
	ChatTypeInfo.CHANNEL.sticky = 0
	ChatTypeInfo.BN_WHISPER.sticky = 0
end

function mod:GetOptions()
	return options
end

function mod:Info()
	return L["Makes channels you select sticky."]
end
