--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
-- register module
local PetBarMod = Bartender4:NewModule("PetBar", "AceEvent-3.0")

-- fetch upvalues
local ActionBars = Bartender4:GetModule("ActionBars")
local ButtonBar = Bartender4.ButtonBar.prototype

local setmetatable, select = setmetatable, select

-- GLOBALS: InCombatLockdown, ClearOverrideBindings, GetBindingKey, SetOverrideBindingClick

-- create prototype information
local PetBar = setmetatable({}, {__index = ButtonBar})

local defaults = { profile = Bartender4:Merge({
	enabled = true,
	hidehotkey = true,
	showgrid = false,
	visibility = {
		nopet = true,
		vehicle = true,
	},
}, Bartender4.ButtonBar.defaults) }

function PetBarMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("PetBar", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function PetBarMod:OnEnable()
	if not self.bar then
		self.bar = setmetatable(Bartender4.ButtonBar:Create("PetBar", self.db.profile, L["Pet Bar"]), {__index = PetBar})

		local buttons = {}
		for i=1,10 do
			buttons[i] = Bartender4.PetButton:Create(i, self.bar)
		end
		self.bar.buttons = buttons

		self.bar:SetScript("OnEvent", PetBar.OnEvent)
	end
	self.bar:Enable()

	self.bar:RegisterEvent("PLAYER_CONTROL_LOST")
	self.bar:RegisterEvent("PLAYER_CONTROL_GAINED")
	self.bar:RegisterEvent("PLAYER_FARSIGHT_FOCUS_CHANGED")
	self.bar:RegisterEvent("UNIT_PET")
	self.bar:RegisterEvent("UNIT_FLAGS")
	self.bar:RegisterEvent("UNIT_AURA")
	self.bar:RegisterEvent("PET_BAR_UPDATE")
	self.bar:RegisterEvent("PET_BAR_UPDATE_COOLDOWN")
	self.bar:RegisterEvent("PET_BAR_SHOWGRID")
	self.bar:RegisterEvent("PET_BAR_HIDEGRID")

	self:ApplyConfig()
	self:ToggleOptions()

	self:RegisterEvent("UPDATE_BINDINGS", "ReassignBindings")
	self:ReassignBindings()
end

function PetBarMod:ReassignBindings()
	if InCombatLockdown() then return end
	if not self.bar or not self.bar.buttons then return end
	ClearOverrideBindings(self.bar)
	for i = 1, 10 do
		local button, real_button = ("BONUSACTIONBUTTON%d"):format(i), ("BT4PetButton%d"):format(i)
		for k=1, select('#', GetBindingKey(button)) do
			local key = select(k, GetBindingKey(button))
			SetOverrideBindingClick(self.bar, false, key, real_button)
		end
	end
end

function PetBarMod:GetGrid()
	return self.db.profile.showgrid
end

function PetBarMod:SetGrid(grid)
	self.db.profile.showgrid = grid
	self.bar:ForAll("ShowGrid")
	self.bar:ForAll("HideGrid")
end

function PetBarMod:ApplyConfig()
	if not self:IsEnabled() then return end
	self.bar:ApplyConfig(self.db.profile)
	self:ReassignBindings()
end

PetBar.button_width = 30
PetBar.button_height = 30
function PetBar:OnEvent(event, arg1)
	if event == "PET_BAR_UPDATE" or
		(event == "UNIT_PET" and arg1 == "player") or
		((event == "UNIT_FLAGS" or event == "UNIT_AURA") and arg1 == "pet") or
		event == "PLAYER_CONTROL_LOST" or event == "PLAYER_CONTROL_GAINED" or event == "PLAYER_FARSIGHT_FOCUS_CHANGED"
	then
		self:ForAll("Update")
	elseif event == "PET_BAR_UPDATE_COOLDOWN" then
		self:ForAll("UpdateCooldown")
	elseif event == "PET_BAR_SHOWGRID" then
		self:ForAll("ShowGrid")
	elseif event == "PET_BAR_HIDEGRID" then
		self:ForAll("HideGrid")
	end
end

function PetBar:ApplyConfig(config)
	ButtonBar.ApplyConfig(self, config)

	if not self.config.position.x then
		self:ClearSetPoint("CENTER", 0, 70)
		self:SavePosition()
	end

	self:UpdateButtonLayout()
	self:ForAll("Update")
	self:ForAll("ApplyStyle", self.config.style)
end
