local addon, private = ...
local Chatter = LibStub("AceAddon-3.0"):GetAddon(addon)
local mod = Chatter:NewModule("Mousewheel Scroll", "AceHook-3.0","AceEvent-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale(addon)
mod.modName = L["Mousewheel Scroll"]

local IsShiftKeyDown = _G.IsShiftKeyDown
local IsControlKeyDown = _G.IsControlKeyDown

local defaults = { profile = { scrollLines = 1 } }
local options = {
	lines = {
		type = "range",
		name = L["Scroll lines"],
		desc = L["How many lines to scroll per mouse wheel click"],
		min = 1,
		max = 20,
		step = 1,
		bigStep = 1,
		get = function() return mod.db.profile.scrollLines end,
		set = function(info, v) mod.db.profile.scrollLines = v end
	}
}

function mod:OnInitialize()
	self.db = Chatter.db:RegisterNamespace(self:GetName(), defaults)
end

function mod:OnEnable()
	SetCVar("chatMouseScroll","1")

	hooksecurefunc("FloatingChatFrame_OnMouseScroll", function(frame, delta)
		if delta > 0 then
			if IsShiftKeyDown() then
				frame:ScrollToTop()
			elseif IsControlKeyDown() then
				frame:PageUp()
			else
				for i = 1, mod.db.profile.scrollLines do
					frame:ScrollUp()
				end
			end
		else
			if IsShiftKeyDown() then
				frame:ScrollToBottom()
			elseif IsControlKeyDown() then
				frame:PageDown()
			else
				for i = 1, mod.db.profile.scrollLines do
					frame:ScrollDown()
				end
			end
		end
	end)

	InterfaceOptionsSocialPanelChatMouseScroll_SetScrolling("0")
	InterfaceOptionsSocialPanelChatMouseScroll_SetScrolling("1")
end

function mod:Info()
	return L["Lets you use the mousewheel to page up and down chat."]
end

function mod:GetOptions()
	return options
end


