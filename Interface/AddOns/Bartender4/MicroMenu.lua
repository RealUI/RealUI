--[[
	Copyright (c) 2009-2012, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
-- register module
local MicroMenuMod = Bartender4:NewModule("MicroMenu", "AceHook-3.0", "AceEvent-3.0")

-- fetch upvalues
local ButtonBar = Bartender4.ButtonBar.prototype

local pairs, setmetatable, table_insert = pairs, setmetatable, table.insert

-- GLOBALS: CharacterMicroButton, SpellbookMicroButton, TalentMicroButton, AchievementMicroButton, QuestLogMicroButton, GuildMicroButton
-- GLOBALS: PVPMicroButton, LFDMicroButton, CompanionsMicroButton, EJMicroButton, MainMenuMicroButton, HelpMicroButton
-- GLOBALS: HasVehicleActionBar, UnitVehicleSkin, HasOverrideActionBar, GetOverrideBarSkin

-- create prototype information
local MicroMenuBar = setmetatable({}, {__index = ButtonBar})

local defaults = { profile = Bartender4:Merge({
	enabled = true,
	vertical = false,
	visibility = {
		possess = false,
	},
	padding = -3,
	position = {
		scale = 0.8,
	},
}, Bartender4.ButtonBar.defaults) }

function MicroMenuMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("MicroMenu", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function MicroMenuMod:OnEnable()
	if not self.bar then
		self.bar = setmetatable(Bartender4.ButtonBar:Create("MicroMenu", self.db.profile, L["Micro Menu"]), {__index = MicroMenuBar})
		local buttons = {}
		table_insert(buttons, CharacterMicroButton)
		table_insert(buttons, SpellbookMicroButton)
		table_insert(buttons, TalentMicroButton)
		table_insert(buttons, AchievementMicroButton)
		table_insert(buttons, QuestLogMicroButton)
		table_insert(buttons, GuildMicroButton)
		table_insert(buttons, PVPMicroButton)
		table_insert(buttons, LFDMicroButton)
		table_insert(buttons, CompanionsMicroButton)
		table_insert(buttons, EJMicroButton)
		table_insert(buttons, MainMenuMicroButton)
		table_insert(buttons, HelpMicroButton)
		self.bar.buttons = buttons

		MicroMenuMod.button_count = #buttons

		for i,v in pairs(buttons) do
			v:SetParent(self.bar)
			v:Show()
			v:SetFrameLevel(self.bar:GetFrameLevel() + 1)
			v.ClearSetPoint = self.bar.ClearSetPoint
		end
	end

	self:SecureHook("MoveMicroButtons")
	self:RegisterEvent("UNIT_EXITED_VEHICLE", "MoveMicroButtons")
	self:RestoreButtons()

	self.bar:Enable()
	self:ToggleOptions()
	self:ApplyConfig()
end

function MicroMenuMod:ApplyConfig()
	self.bar:ApplyConfig(self.db.profile)
end

function MicroMenuMod:RestoreButtons()
	if not self:IsEnabled() then return end
	for k,v in pairs(self.bar.buttons) do
		v:SetParent(self.bar)
		v:Show()
	end
	self.bar:UpdateButtonLayout()
end

function MicroMenuMod:MoveMicroButtons()
	if not ((HasVehicleActionBar() and UnitVehicleSkin("player") and UnitVehicleSkin("player") ~= "")
	or (HasOverrideActionBar() and GetOverrideBarSkin() and GetOverrideBarSkin() ~= "")) then
		self:RestoreButtons()
	end
end

MicroMenuBar.button_width = 28
MicroMenuBar.button_height = 58
MicroMenuBar.vpad_offset = -21
function MicroMenuBar:ApplyConfig(config)
	ButtonBar.ApplyConfig(self, config)

	if not self.config.position.x then
		self:ClearSetPoint("CENTER", -105, 30)
		self:SavePosition()
	end

	self:UpdateButtonLayout()
end
