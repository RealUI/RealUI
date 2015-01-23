--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")

local BagBarMod = Bartender4:GetModule("BagBar")

-- fetch upvalues
local ButtonBar = Bartender4.ButtonBar.prototype

function BagBarMod:SetupOptions()
	if not self.options then
		self.optionobject = ButtonBar:GetOptionObject()
		self.optionobject.table.general.args.rows.max = self.button_count
		local enabled = {
			type = "toggle",
			order = 1,
			name = L["Enabled"],
			desc = L["Enable the Bag Bar"],
			get = function() return self.db.profile.enabled end,
			set = "ToggleModule",
			handler = self,
		}
		self.optionobject:AddElement("general", "enabled", enabled)

		local onebag = {
			type = "toggle",
			order = 80,
			name = L["One Bag"],
			desc = L["Only show one Bag Button in the BagBar."],
			get = function() return self.db.profile.onebag end,
			set = function(info, state) self.db.profile.onebag = state; self.bar:FeedButtons(); self.bar:UpdateButtonLayout() end,
		}
		self.optionobject:AddElement("general", "onebag", onebag)

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
			name = L["Bag Bar"],
			desc = L["Configure the Bag Bar"],
			childGroups = "tab",
		}
		Bartender4:RegisterBarOptions("BagBar", self.options)
	end
	self.options.args = self:IsEnabled() and self.optionobject.table or self.disabledoptions
end
