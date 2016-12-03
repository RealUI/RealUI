--[[
	Copyright (c) 2009-2016, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
-- register module
local ZoneAbilityBarMod = Bartender4:NewModule("ZoneAbilityBar", "AceHook-3.0")

-- fetch upvalues
local Bar = Bartender4.Bar.prototype

local setmetatable, table_insert = setmetatable, table.insert

-- GLOBALS: ZoneAbilityFrame

-- create prototype information
local ZoneAbilityBar = setmetatable({}, {__index = Bar})

local defaults = { profile = Bartender4:Merge({
	enabled = true,
	visibility = {
		vehicleui = false,
		overridebar = false,
	},
}, Bartender4.Bar.defaults) }

function ZoneAbilityBarMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("ZoneAbilityBar", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function ZoneAbilityBarMod:OnEnable()
	if not self.bar then
		self.bar = setmetatable(Bartender4.Bar:Create("ZoneAbilityBar", self.db.profile, L["Zone Ability Bar"]), {__index = ZoneAbilityBar})
		self.bar.content = ZoneAbilityFrame
		
		self.bar.content.ignoreFramePositionManager = true
		self.bar.content:SetParent(self.bar)
		--self.bar.content:SetFrameLevel(self.bar:GetFrameLevel() + 1)
	end
	self.bar:Enable()
	self:ToggleOptions()
	self:ApplyConfig()
end

function ZoneAbilityBarMod:ApplyConfig()
	self.bar:ApplyConfig(self.db.profile)
end

function ZoneAbilityBar:ApplyConfig(config)
	Bar.ApplyConfig(self, config)

	if not self.config.position.x then
		self:ClearSetPoint("BOTTOM", 0, 160)
		self:SavePosition()
	end

	self:PerformLayout()
end

function ZoneAbilityBar:PerformLayout()
	self:SetSize(64, 64)
	local bar = self.content
	bar:ClearAllPoints()
	bar:SetPoint("TOPLEFT", 0, 0)
end
