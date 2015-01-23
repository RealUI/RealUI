--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
-- register module
local ExtraActionBarMod = Bartender4:NewModule("ExtraActionBar", "AceHook-3.0")

-- fetch upvalues
local Bar = Bartender4.Bar.prototype
local LBF = LibStub("LibButtonFacade", true)

local setmetatable, table_insert = setmetatable, table.insert

-- GLOBALS: ExtraActionBarFrame

-- create prototype information
local ExtraActionBar = setmetatable({}, {__index = Bar})

local defaults = { profile = Bartender4:Merge({
	enabled = true,
	visibility = {
		vehicleui = false,
		overridebar = false,
	},
}, Bartender4.Bar.defaults) }

function ExtraActionBarMod:OnInitialize()
	self.db = Bartender4.db:RegisterNamespace("ExtraActionBar", defaults)
	self:SetEnabledState(self.db.profile.enabled)
end

function ExtraActionBarMod:OnEnable()
	if not self.bar then
		self.bar = setmetatable(Bartender4.Bar:Create("ExtraActionBar", self.db.profile, L["Extra Action Bar"]), {__index = ExtraActionBar})
		self.bar.content = ExtraActionBarFrame
		
		self.bar.content.ignoreFramePositionManager = true
		self.bar.content:SetParent(self.bar)
		--self.bar.content:SetFrameLevel(self.bar:GetFrameLevel() + 1)
	end
	self.bar:Enable()
	self:ToggleOptions()
	self:ApplyConfig()
end

function ExtraActionBarMod:ApplyConfig()
	self.bar:ApplyConfig(self.db.profile)
end

function ExtraActionBar:ApplyConfig(config)
	Bar.ApplyConfig(self, config)

	if not self.config.position.x then
		self:ClearSetPoint("BOTTOM", 0, 160)
		self:SavePosition()
	end

	self:PerformLayout()
end

function ExtraActionBar:PerformLayout()
	self:SetSize(64, 64)
	local bar = self.content
	bar:ClearAllPoints()
	bar:SetPoint("TOPLEFT", 0, 0)
end
