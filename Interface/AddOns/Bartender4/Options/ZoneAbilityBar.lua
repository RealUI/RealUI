--[[
	Copyright (c) 2009-2016, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")

local ZoneAbilityBarMod = Bartender4:GetModule("ZoneAbilityBar")

-- fetch upvalues
local Bar = Bartender4.Bar.prototype

function ZoneAbilityBarMod:SetupOptions()
	if not self.options then
		self.optionobject = Bar:GetOptionObject()
		local enabled = {
			type = "toggle",
			order = 1,
			name = L["Enabled"],
			desc = L["Enable the Zone Ability Bar"],
			get = function() return self.db.profile.enabled end,
			set = "ToggleModule",
			handler = self,
		}
		self.optionobject:AddElement("general", "enabled", enabled)

		self.disabledoptions = {
			general = {
				type = "group",
				name = L["General Settings"],
				cmdInline = true,
				order = 1,
				args = {
					enabled = enabled,
				}
			}
		}
		self.options = {
			order = 30,
			type = "group",
			name = L["Zone Ability Bar"],
			desc = L["Configure the Zone Ability Bar"],
			childGroups = "tab",
		}
		Bartender4:RegisterBarOptions("ZoneAbilityBar", self.options)
	end
	self.options.args = self:IsEnabled() and self.optionobject.table or self.disabledoptions
end
