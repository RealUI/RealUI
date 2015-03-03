--[[
	Copyright (c) 2009, CMTitan
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	Based on Nevcairiel's RepXPBar.lua
	All rights to be transferred to Nevcairiel upon inclusion into Bartender4.
	All rights reserved, otherwise.
]]
local _, Bartender4 = ...
-- fetch upvalues
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
local Bar = Bartender4.Bar.prototype

-- GLOBALS: GetNumShapeshiftForms

local PresetsMod = Bartender4:NewModule("Presets")

function PresetsMod:ToggleModule(info, val)
	-- We are always enabled. Period.
	if not self:IsEnabled() then
		self:Enabled()
	end
end

local function SetBarLocation(config, point, x, y)
	config.position.point = point
	config.position.x = x
	config.position.y = y
end

local function BuildSingleProfile()
	local dy, config
	dy = 0
	if not PresetsMod.showRepBar then
		dy = dy - 5
	end
	if not PresetsMod.showXPBar then
		dy = dy - 6
	end
	-- -8

	Bartender4.db.profile.blizzardVehicle = false
	Bartender4.db.profile.outofrange = "hotkey"
	Bartender4.db.profile.focuscastmodifier = false

	config = Bartender4.db:GetNamespace("ActionBars").profile
	config.actionbars[1].padding = 6
	SetBarLocation( config.actionbars[1], "BOTTOM", -256, 41.75 )
	config.actionbars[2].enabled = false
	config.actionbars[3].padding = 5
	config.actionbars[3].rows = 12
	SetBarLocation( config.actionbars[3], "BOTTOMRIGHT", -42, 610 )
	config.actionbars[4].padding = 5
	config.actionbars[4].rows = 12
	SetBarLocation( config.actionbars[4], "BOTTOMRIGHT", -82, 610 )
	SetBarLocation( config.actionbars[5], "BOTTOM", -232, 94 + dy )
	SetBarLocation( config.actionbars[6], "BOTTOM", -232, 132 + dy )

	config = Bartender4.db:GetNamespace("BagBar").profile
	config.enabled = false
	Bartender4:GetModule("BagBar"):Disable()
	config = Bartender4.db:GetNamespace("MicroMenu").profile
	config.enabled = false
	Bartender4:GetModule("MicroMenu"):Disable()
	config = Bartender4.db:GetNamespace("StanceBar").profile
	config.enabled = false
	Bartender4:GetModule("StanceBar"):Disable()

	if PresetsMod.showRepBar then
		config = Bartender4.db:GetNamespace("RepBar").profile
		config.enabled = true
		config.position.scale = 0.44 -- Note: actually not possible via interface!
		Bartender4:GetModule("RepBar"):Enable()
		SetBarLocation( config, "BOTTOM", -227, 57 + dy ) -- Note that dy is actually correct since it's only incorrect for the RepBar if the RepBar itself does not exist
	end

	if PresetsMod.showXPBar then
		config = Bartender4.db:GetNamespace("XPBar").profile
		config.enabled = true
		config.position.scale = 0.49 -- Note: actually not possible via interface!
		Bartender4:GetModule("XPBar"):Enable()
		SetBarLocation( config, "BOTTOM", -252.85, 52 )
	end

	config = Bartender4.db:GetNamespace("BlizzardArt").profile
	config.enabled = true
	config.artLayout = "ONEBAR"
	Bartender4:GetModule("BlizzardArt"):Enable()
	SetBarLocation( config, "BOTTOM", -256, 47 )

	config = Bartender4.db:GetNamespace("PetBar").profile
	SetBarLocation( config, "BOTTOM", -164, 164 + dy )
end

local function BuildDoubleProfile()
	local dy, config
	dy = 0
	if not PresetsMod.showRepBar then
		dy = dy - 8
	end
	if not PresetsMod.showXPBar then
		dy = dy - 11
	end

	Bartender4.db.profile.blizzardVehicle = true
	Bartender4.db.profile.outofrange = "hotkey"
	Bartender4.db.profile.focuscastmodifier = false

	config = Bartender4.db:GetNamespace("ActionBars").profile
	config.actionbars[1].padding = 6
	SetBarLocation( config.actionbars[1], "BOTTOM", -510, 41.75 )
	config.actionbars[2].padding = 6
	SetBarLocation( config.actionbars[2], "BOTTOM", 3, 41.75 )
	config.actionbars[3].padding = 5
	config.actionbars[3].rows = 12
	SetBarLocation( config.actionbars[3], "BOTTOMRIGHT", -42, 610 )
	config.actionbars[4].padding = 5
	config.actionbars[4].rows = 12
	SetBarLocation( config.actionbars[4], "BOTTOMRIGHT", -82, 610 )
	config.actionbars[5].padding = 6
	SetBarLocation( config.actionbars[5], "BOTTOM", 3, 102 + dy )
	config.actionbars[6].padding = 6
	SetBarLocation( config.actionbars[6], "BOTTOM", -510, 102 + dy )

	config = Bartender4.db:GetNamespace("BagBar").profile
	config.enabled = false
	Bartender4:GetModule("BagBar"):Disable()

	config = Bartender4.db:GetNamespace("MicroMenu").profile
	config.enabled = false
	Bartender4:GetModule("MicroMenu"):Disable()

	if PresetsMod.showRepBar then
		config = Bartender4.db:GetNamespace("RepBar").profile
		config.enabled = true
		Bartender4:GetModule("RepBar"):Enable()
		SetBarLocation( config, "BOTTOM", -516, 65 + dy ) -- Note that dy is actually correct since it's only incorrect for the RepBar if the RepBar itself does not exist
	end

	if PresetsMod.showXPBar then
		config = Bartender4.db:GetNamespace("XPBar").profile
		config.enabled = true
		Bartender4:GetModule("XPBar"):Enable()
		SetBarLocation( config, "BOTTOM", -516, 57 )
	end

	config = Bartender4.db:GetNamespace("BlizzardArt").profile
	config.enabled = true
	config.artLayout = "TWOBAR"
	Bartender4:GetModule("BlizzardArt"):Enable()
	SetBarLocation( config, "BOTTOM", -512, 47 )

	config = Bartender4.db:GetNamespace("PetBar").profile
	if GetNumShapeshiftForms() > 0 then
		SetBarLocation( config, "BOTTOM", -120, 135 + dy )
		config = Bartender4.db:GetNamespace("StanceBar").profile
		config.position.scale = 1.0
		SetBarLocation( config, "BOTTOM", -460, 135 + dy )
	else
		SetBarLocation( config, "BOTTOM", -460, 135 + dy )
	end
end

local function BuildBlizzardProfile()
	local dy, config
	dy = 0
	if not PresetsMod.showRepBar then
		dy = dy - 8
	end
	if not PresetsMod.showXPBar then
		dy = dy - 11
	end

	Bartender4.db.profile.blizzardVehicle = true
	Bartender4.db.profile.outofrange = "hotkey"
	Bartender4.db.profile.focuscastmodifier = false

	config = Bartender4.db:GetNamespace("ActionBars").profile
	config.actionbars[1].padding = 6
	SetBarLocation( config.actionbars[1], "BOTTOM", -510, 41.75 )
	config.actionbars[2].enabled = false
	config.actionbars[3].padding = 5
	config.actionbars[3].rows = 12
	SetBarLocation( config.actionbars[3], "BOTTOMRIGHT", -82, 610 )
	config.actionbars[4].padding = 5
	config.actionbars[4].rows = 12
	SetBarLocation( config.actionbars[4], "BOTTOMRIGHT", -42, 610 )
	config.actionbars[5].padding = 6
	SetBarLocation( config.actionbars[5], "BOTTOM", 3, 102 + dy )
	config.actionbars[6].padding = 6
	SetBarLocation( config.actionbars[6], "BOTTOM", -510, 102 + dy )

	config = Bartender4.db:GetNamespace("BagBar").profile
	config.onebag = false
	SetBarLocation( config, "BOTTOM", 345, 38.5 )

	config = Bartender4.db:GetNamespace("MicroMenu").profile
	config.position.scale = 1.0
	config.padding = -2
	SetBarLocation( config, "BOTTOM", 37.5, 41.75 )

	if PresetsMod.showRepBar then
		config = Bartender4.db:GetNamespace("RepBar").profile
		config.enabled = true
		Bartender4:GetModule("RepBar"):Enable()
		SetBarLocation( config, "BOTTOM", -516, 65 + dy ) -- Note that dy is actually correct since it's only incorrect for the RepBar if the RepBar itself does not exist
	end

	if PresetsMod.showXPBar then
		config = Bartender4.db:GetNamespace("XPBar").profile
		config.enabled = true
		Bartender4:GetModule("XPBar"):Enable()
		SetBarLocation( config, "BOTTOM", -516, 57 )
	end

	config = Bartender4.db:GetNamespace("BlizzardArt").profile
	config.enabled = true
	Bartender4:GetModule("BlizzardArt"):Enable()
	SetBarLocation( config, "BOTTOM", -512, 47 )

	config = Bartender4.db:GetNamespace("PetBar").profile
	if GetNumShapeshiftForms() > 0 then
		SetBarLocation( config, "BOTTOM", -120, 135 + dy )
		config = Bartender4.db:GetNamespace("StanceBar").profile
		config.position.scale = 1.0
		SetBarLocation( config, "BOTTOM", -460, 135 + dy )
	else
		SetBarLocation( config, "BOTTOM", -460, 135 + dy )
	end
end

function PresetsMod:ResetProfile(type)
	if not type then type = PresetsMod.defaultType end
	Bartender4.db:ResetProfile()
	if type == "BLIZZARD" then
		BuildBlizzardProfile()
	elseif type == "DOUBLE" then
		BuildDoubleProfile()
	elseif type == "SINGLE" then
		BuildSingleProfile()
	end
	Bartender4:UpdateModuleConfigs()
end

function PresetsMod:OnEnable()
	Bartender4.finishedLoading = true
	if self.applyBlizzardOnEnable then
		self:ResetProfile("BLIZZARD")
		self.applyBlizzardOnEnable = nil
	end
end

function PresetsMod:SetupOptions()
	if not self.options then
		PresetsMod.defaultType = "BLIZZARD"
		self.showXPBar = true
		self.showRepBar = true
		local otbl = {
			message1 = {
				order = 1,
				type = "description",
				name = L["You can use the preset defaults as a starting point for setting up your interface. Just choose your preferences here and click the button below to reset your profile to the preset default. Note that not all defaults show all bars."]
			},
			message2 = {
				order = 2,
				type = "description",
				name = L["|cffff0000WARNING|cffffffff: Pressing the button will reset your complete profile! If you're not sure about this, create a new profile and use that to experiment."],
			},
			preset = {
				order = 10,
				type = "select",
				name = L["Presets"],
				values = { BLIZZARD = L["Blizzard interface"], DOUBLE = L["Two bars wide"], SINGLE = L["Three bars stacked"], ZRESET = L["Full reset"] },
				get = function() return PresetsMod.defaultType end,
				set = function(info, val) PresetsMod.defaultType = val end
			},
			nl1 = {
				order = 11,
				type = "description",
				name = ""
			},
			xpbar = {
				order = 20,
				type = "toggle",
				name = L["Show XP Bar"],
				get = function() return PresetsMod.showXPBar end,
				set = function(info, val) PresetsMod.showXPBar = val end,
				disabled = function() return PresetsMod.defaultType == "RESET" end
			},
			nl2  = {
					order = 21,
					type = "description",
					name = ""
			},
			repbar = {
				order = 30,
				type = "toggle",
				name = L["Show Reputation Bar"],
				get = function() return PresetsMod.showRepBar end,
				set = function(info, val) PresetsMod.showRepBar = val end,
				disabled = function() return PresetsMod.defaultType == "RESET" end
			},
			nl3 = {
				order = 31,
				type = "description",
				name = ""
			},
			button = {
				order = 40,
				type = "execute",
				name = L["Apply Preset"],
				func = function() PresetsMod.ResetProfile() end,
			}
		}
		self.optionobject = Bartender4:NewOptionObject( otbl )
		self.options = {
			order = 99,
			type = "group",
			name = L["Presets"],
			desc = L["Configure all of Bartender to preset defaults"],
			childGroups = "tab",
		}
		Bartender4:RegisterModuleOptions("Presets", self.options)
	end
	self.options.args = self.optionobject.table
end
