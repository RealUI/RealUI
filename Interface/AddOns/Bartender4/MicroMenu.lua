--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
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
-- GLOBALS: LFDMicroButton, CollectionsMicroButton, EJMicroButton, MainMenuMicroButton
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
		table_insert(buttons, LFDMicroButton)
		table_insert(buttons, CollectionsMicroButton)
		table_insert(buttons, EJMicroButton)
		table_insert(buttons, StoreMicroButton)
		table_insert(buttons, MainMenuMicroButton)
		self.bar.buttons = buttons

		MicroMenuMod.button_count = #buttons

		self.bar.anchors = {}
		for i,v in pairs(buttons) do
			self.bar.anchors[i] = { v:GetPoint() }	-- Save orig button anchors.
			v:SetFrameLevel(self.bar:GetFrameLevel() + 1)
			v.ClearSetPoint = self.bar.ClearSetPoint
		end
	end

	self:SecureHook("UpdateMicroButtons", "MicroMenuBarShow")
	self:SecureHookScript(OverrideActionBar, "OnShow", "BlizzardBarShow")
	self:SecureHookScript(OverrideActionBar, "OnHide", "MicroMenuBarShow")
	self:SecureHookScript(PetBattleFrame.BottomFrame.MicroButtonFrame, "OnShow", "BlizzardBarShow")
	self:SecureHookScript(PetBattleFrame.BottomFrame.MicroButtonFrame, "OnHide", "MicroMenuBarShow")

	self.bar:Enable()
	self:ToggleOptions()
	self:ApplyConfig()

	self:MicroMenuBarShow()
end

function MicroMenuMod:ApplyConfig()
	self.bar:ApplyConfig(self.db.profile)
end

function MicroMenuMod:MicroMenuBarShow()
	-- Only "fix" button anchors if another frame that uses the MicroButtonBar isn't active.
	if not (OverrideActionBar:IsShown() or PetBattleFrame:IsShown()) then
		UpdateMicroButtonsParent(self.bar)
		self.bar:UpdateButtonLayout()
	end
end

function MicroMenuMod:BlizzardBarShow()
	-- Only reset button positions not set in MoveMicroButtons()
	for i,v in pairs(self.bar.buttons) do
		if (((i-1)%6) > 0) then
			v:ClearSetPoint(unpack(self.bar.anchors[i]))
		end
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

function MicroMenuBar:UpdateButtonLayout()
	ButtonBar.UpdateButtonLayout(self)
	-- If the StoreButton is hidden we want to replace it with the Help button
	if not StoreMicroButton:IsShown() then
		HelpMicroButton:Show()
		HelpMicroButton:ClearAllPoints()
		HelpMicroButton:SetAllPoints(StoreMicroButton)
	else
		HelpMicroButton:Hide()
		HelpMicroButton:ClearAllPoints()
	end
end
