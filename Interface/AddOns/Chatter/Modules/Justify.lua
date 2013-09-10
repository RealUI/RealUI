local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Justify Text")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Text Justification"]
mod.toggleLabel = L["Enable text justification"]

local defaults = {
	profile = {}
}

local VALID_JUSTIFICATIONS = {
	LEFT = L["Left"],
	RIGHT = L["Right"],
	CENTER = L["Center"]
}

local options = {}
function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace("JustifyText", defaults)
	for i = 1, NUM_CHAT_WINDOWS do
		local s = "FRAME_" .. i
		local f = _G["ChatFrame" .. i]
		options[s] = {
			type = "select",
			name = L["Chat Frame "] .. i,
			desc = L["Chat Frame "] .. i,
			values = VALID_JUSTIFICATIONS,
			get = function() return self.db.profile[s] or "LEFT" end,
			set = function(info, v)
				self.db.profile[s] = v
				f:SetJustifyH(v)
			end
		}
	end
end

function mod:OnEnable()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		cf:SetJustifyH(self.db.profile["FRAME_" .. i] or "LEFT")
	end
end

function mod:OnDisable()
	for i = 1, NUM_CHAT_WINDOWS do
		local cf = _G["ChatFrame" .. i]
		cf:SetJustifyH("LEFT")
	end
end

function mod:GetOptions()
	return options
end

function mod:Info()
	return L["Lets you set the justification of text in your chat frames."]
end
