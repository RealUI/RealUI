--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
local StateBar = Bartender4.StateBar.prototype
local ActionBar = Bartender4.ActionBar

local tonumber, tostring, assert = tonumber, tostring, assert

--[[===================================================================================
	ActionBar Options
===================================================================================]]--

local module = Bartender4:GetModule("ActionBars")

-- option utilty functions
local optGetter, optSetter
do
	local optionMap, getBar, callFunc
	-- maps option keys to function names
	optionMap = {
		buttons = "Buttons",
		enabled = "Enabled",
		grid = "Grid",
		flyoutDirection = "FlyoutDirection",
	}

	-- retrieves a valid bar object from the modules actionbars table
	function getBar(id)
		local bar = module.actionbars[tonumber(id)]
		assert(bar, ("Invalid bar id in options table. (%s)"):format(id))
		return bar
	end

	-- calls a function on the bar
	function callFunc(bar, type, option, ...)
		local func = type .. (optionMap[option] or option)
		assert(bar[func], ("Invalid get/set function %s in bar %s."):format(func, bar.id))
		return bar[func](bar, ...)
	end

	-- universal function to get a option
	function optGetter(info)
		local bar = getBar(info[2])
		local option = info[#info]
		return callFunc(bar, "Get", option)
	end

	-- universal function to set a option
	function optSetter(info, ...)
		local bar = getBar(info[2])
		local option = info[#info]
		return callFunc(bar, "Set", option, ...)
	end
end

-- returns the option table used for all action bars
-- creates it, if the first time called
-- the Universal Bar option table is merged into this, alot of stuff gets inherited.
function module:GetOptionsTable()
	return self:GetOptionsObject().table
end

function module:GetOptionsObject()
	if not self.baroptions then
		local obj = StateBar.GetOptionObject(self)

		local cat_general = {
			enabled ={
				order = 4,
				name = L["Enabled"],
				desc = L["Enable/Disable the bar."],
				type = "toggle",
				set = optSetter,
				get = optGetter,
			},
			grid = {
				order = 60,
				type = "toggle",
				name = L["Button Grid"],
				desc = L["Toggle the button grid."],
				set = optSetter,
				get = optGetter,
			},
			buttons = {
				order = 50,
				name = L["Buttons"],
				desc = L["Number of buttons."],
				type = "range",
				min = 1, max = 12, step = 1,
				set = optSetter,
				get = optGetter,
			},
			flyoutDirection = {
				order = 79,
				name = L["Flyout Direction"],
				desc = L["Direction of the button flyouts on this bar (eg. summon demon/pet)"],
				type = "select",
				values = {LEFT = L["Left"], RIGHT = L["Right"], UP = L["Up"], DOWN = L["Down"]},
				set = optSetter,
				get = optGetter,
			},
		}
		obj:AddElementGroup("general", cat_general)
		self.baroptions = obj
	end

	return self.baroptions
end

function module:CreateBarOption(id, options)
	if not self.options then return end

	if not options then
		options = self:GetOptionsTable()
	end

	id = tostring(id)
	if not self.options[id] then
		self.options[id] = {
			order = 10 + tonumber(id),
			type = "group",
			name = (L["Bar %s"]):format(id),
			desc = (L["Configure Bar %s"]):format(id),
			childGroups = "tab",
		}
	end
	self.options[id].args = options

	-- register options in the BT GUI
	Bartender4:RegisterBarOptions(id, self.options[id])
end
