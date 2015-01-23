--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")

local PetBarMod = Bartender4:GetModule("PetBar")

-- fetch upvalues
local ButtonBar = Bartender4.ButtonBar.prototype

function PetBarMod:SetupOptions()
	if not self.options then
		self.optionobject = ButtonBar:GetOptionObject()

		self.optionobject.table.general.args.rows.max = 10

		local enabled = {
			type = "toggle",
			order = 1,
			name = L["Enabled"],
			desc = L["Enable the PetBar"],
			get = function() return self.db.profile.enabled end,
			set = "ToggleModule",
			handler = self,
		}

		local cat_general = {
			enabled = enabled,
			grid = {
				order = 83,
				type = "toggle",
				name = L["Button Grid"],
				desc = L["Toggle the button grid."],
				set = function(info, ...) PetBarMod:SetGrid(...) end,
				get = function(info) return PetBarMod:GetGrid() end,
			},
		}
		self.optionobject:AddElementGroup("general", cat_general)

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
			name = L["Pet Bar"],
			desc = L["Configure the Pet Bar"],
			childGroups = "tab",
		}
		Bartender4:RegisterBarOptions("PetBar", self.options)
	end
	self.options.args = self:IsEnabled() and self.optionobject.table or self.disabledoptions
end
