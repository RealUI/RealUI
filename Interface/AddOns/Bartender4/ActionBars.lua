--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
local BT4ActionBars = Bartender4:NewModule("ActionBars", "AceEvent-3.0")

local select, ipairs, pairs, tostring, tonumber, min, setmetatable = select, ipairs, pairs, tostring, tonumber, min, setmetatable

-- GLOBALS: UnitClass, InCombatLockdown, GetBindingKey, ClearOverrideBindings, SetOverrideBindingClick

local abdefaults = {
	['**'] = Bartender4:Merge({
		enabled = true,
		buttons = 12,
		hidemacrotext = false,
		showgrid = false,
		flyoutDirection = "UP",
	}, Bartender4.StateBar.defaults),
	[1] = {
		states = {
			enabled = true,
			possess = true,
			actionbar = false,
			stance = {
				DRUID = { bear = 9, cat = 7, prowl = 8 },
				ROGUE = { stealth = 7 },
				MONK = { tiger = 7, ox = 8, serpent = 9, crane = 7 },
				WARRIOR = { battle = 7, def = 8, gladiator = 9 },
			},
		},
		visibility = {
			vehicleui = false,
			overridebar = false,
		},
	},
	[7] = {
		enabled = false,
	},
	[8] = {
		enabled = false,
	},
	[9] = {
		enabled = false,
	},
	[10] = {
		enabled = false,
	},
}

local defaults = {
	profile = {
		actionbars = abdefaults,
	}
}

local ActionBar_MT = {__index = Bartender4.ActionBar}

-- export defaults for other modules
Bartender4.ActionBar.defaults = abdefaults['**']

function BT4ActionBars:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("ActionBars", defaults)
end

local LBF = LibStub("LibButtonFacade", true)

-- setup the 10 actionbars
local first = true
function BT4ActionBars:OnEnable()
	if first then
		self.playerclass = select(2, UnitClass("player"))
		self.actionbars = {}

		for i=1,10 do
			local config = self.db.profile.actionbars[i]
			if config.enabled then
				self.actionbars[i] = self:Create(i, config)
			else
				self:CreateBarOption(i, self.disabledoptions)
			end
		end

		first = nil
	end

	self:RegisterEvent("UPDATE_BINDINGS", "ReassignBindings")
	self:ReassignBindings()
end

function BT4ActionBars:SetupOptions()
	if not self.options then
		-- empty table to hold the bar options
		self.options = {}

		-- template for disabled bars
		self.disabledoptions = {
			general = {
				type = "group",
				name = L["General Settings"],
				cmdInline = true,
				order = 1,
				args = {
					enabled = {
						type = "toggle",
						name = L["Enabled"],
						desc = L["Enable/Disable the bar."],
						set = function(info, v) if v then BT4ActionBars:EnableBar(info[2]) end end,
						get = function() return false end,
					}
				}
			}
		}

		-- iterate over bars and create their option tables
		for i=1,10 do
			local config = self.db.profile.actionbars[i]
			if config.enabled then
				self:CreateBarOption(i)
			else
				self:CreateBarOption(i, self.disabledoptions)
			end
		end
	end
end

-- Applys the config in the current profile to all active Bars
function BT4ActionBars:ApplyConfig()
	for i=1,10 do
		local config = self.db.profile.actionbars[i]
		-- make sure the bar has its current config object if it exists already
		if self.actionbars[i] then
			self.actionbars[i].config = config
		end
		if config.enabled then
			self:EnableBar(i)
		else
			self:DisableBar(i)
		end
	end
end

-- we do not allow to disable the actionbars module
function BT4ActionBars:ToggleModule()
	return
end

function BT4ActionBars:UpdateButtons(force)
	for i,v in ipairs(self.actionbars) do
		for j,button in ipairs(v.buttons) do
			button:UpdateAction(force)
		end
	end
end

function BT4ActionBars:ReassignBindings()
	if InCombatLockdown() then return end
	if not self.actionbars or not self.actionbars[1] then return end
	local frame = self.actionbars[1]
	ClearOverrideBindings(frame)
	for i = 1,min(#frame.buttons, 12) do
		local button, real_button = ("ACTIONBUTTON%d"):format(i), ("BT4Button%d"):format(i)
		for k=1, select('#', GetBindingKey(button)) do
			local key = select(k, GetBindingKey(button))
			if key and key ~= "" then
				SetOverrideBindingClick(frame, false, key, real_button)
			end
		end
	end
end

-- Creates a new bar object based on the id and the specified config
function BT4ActionBars:Create(id, config)
	local id = tostring(id)
	local bar = setmetatable(Bartender4.StateBar:Create(id, config, (L["Bar %s"]):format(id)), ActionBar_MT)
	bar.module = self

	bar:SetScript("OnEvent", bar.OnEvent)
	bar:RegisterEvent("PLAYER_TALENT_UPDATE")
	bar:RegisterEvent("PLAYER_SPECIALIZATION_CHANGED")
	bar:RegisterEvent("LEARNED_SPELL_IN_TAB")
	bar:RegisterEvent("PLAYER_REGEN_ENABLED")

	self:CreateBarOption(id)

	bar:ApplyConfig()

	return bar
end

function BT4ActionBars:DisableBar(id)
	id = tonumber(id)
	local bar = self.actionbars[id]
	if not bar then return end

	bar.config.enabled = false
	bar:Disable()
	self:CreateBarOption(id, self.disabledoptions)
end

function BT4ActionBars:EnableBar(id)
	id = tonumber(id)
	local bar = self.actionbars[id]
	local config = self.db.profile.actionbars[id]
	config.enabled = true
	if not bar then
		bar = self:Create(id, config)
		self.actionbars[id] = bar
	else
		bar.disabled = nil
		self:CreateBarOption(id)
		bar:ApplyConfig(config)
	end
	if not Bartender4.Locked then
		bar:Unlock()
	end
end

function BT4ActionBars:GetAll()
	return pairs(self.actionbars)
end

function BT4ActionBars:ForAll(method, ...)
	for _, bar in self:GetAll() do
		local func = bar[method]
		if func then
			func(bar, ...)
		end
	end
end

function BT4ActionBars:ForAllButtons(...)
	self:ForAll("ForAll", ...)
end
