--[[
	Copyright (c) 2009, CMTitan
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	Based on Nevcairiel's RepXPBar.lua
	All rights to be transferred to Nevcairiel upon inclusion into Bartender4.
	All rights reserved, otherwise.
]]
-- fetch upvalues
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
local Bar = Bartender4.Bar.prototype

local BlizzardArtMod = Bartender4:GetModule("BlizzardArt")

function BlizzardArtMod:SetupOptions()
	if not self.options then
		self.optionobject = Bar:GetOptionObject()
		local enabled = {
			type = "toggle",
			order = 1,
			name = L["Enabled"],
			desc = L["Enable the Blizzard Art Bar"],
			get = function() return self.db.profile.enabled end,
			set = "ToggleModule",
			handler = self,
		}
		self.optionobject:AddElement("general", "enabled", enabled)
		local endcapleft = {
			type = "select",
			order = 40,
			name = L["Left ending"],
			desc = L["Choose the ending to the left"],
			values = {NONE=L["None"], DWARF=L["Griffin"], HUMAN=L["Lion"]},
			get = function() return self.db.profile.leftCap end,
			set = function(info, val) self.db.profile.leftCap = val; BlizzardArtMod:ApplyConfig() end,
		}
		self.optionobject:AddElement("general", "endcapleft", endcapleft)
		local endcapright = {
			type = "select",
			order = 41,
			name = L["Right ending"],
			desc = L["Choose the ending to the right"],
			values = {NONE=L["None"], DWARF=L["Griffin"], HUMAN=L["Lion"]},
			get = function() return self.db.profile.rightCap end,
			set = function(info, val) self.db.profile.rightCap = val; BlizzardArtMod:ApplyConfig() end,
		}
		self.optionobject:AddElement("general", "endcapright", endcapright)
		local layout = {
			type = "select",
			order = 42,
			name = L["Layout"],
			desc = L["Choose between the classic WoW layout and two variations"],
			values = {CLASSIC=L["Classic"], ONEBAR=L["One action bar only"], TWOBAR=L["Two action bars"]},
			get = function() return self.db.profile.artLayout end,
			set = function(info, val) self.db.profile.artLayout = val; BlizzardArtMod:ApplyConfig() end,
		}
		self.optionobject:AddElement("general", "artlayout", layout)
		local background = {
			type = "select",
			order = 43,
			name = L["Empty button background"],
			desc = L["The background of button places where no buttons are placed"],
			values = {DWARF=L["Griffin"], HUMAN=L["Lion"]},
			get = function() return self.db.profile.artSkin end,
			set = function(info, val) self.db.profile.artSkin = val; BlizzardArtMod:ApplyConfig() end,
		}
		self.optionobject:AddElement("general", "artskin", background)

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
			order = 101,
			type = "group",
			name = L["Blizzard Art Bar"],
			desc = L["Configure the Blizzard Art Bar"],
			childGroups = "tab",
		}
		Bartender4:RegisterBarOptions("BlizzardArt", self.options)
	end
	self.options.args = self:IsEnabled() and self.optionobject.table or self.disabledoptions
end
