--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")

local Bar = Bartender4.Bar.prototype
local ButtonBar = Bartender4.ButtonBar.prototype

local tostring, assert = tostring, assert

-- GLOBALS: LibStub

--[[===================================================================================
	Bar Options
===================================================================================]]--

-- option utilty functions
local optGetter, optSetter
do
	local getBar, optionMap, callFunc
	local barregistry = Bartender4.Bar.barregistry
	-- maps option keys to function names
	optionMap = {
		rows = "Rows",
		padding = "Padding",
		zoom = "Zoom",
		macrotext = "HideMacroText",
		hotkey = "HideHotkey",
		equipped = "HideEquipped",
		vgrowth = "VGrowth",
		hgrowth = "HGrowth",
	}

	-- retrieves a valid bar object from the barregistry table
	function getBar(id)
		local bar = barregistry[tostring(id)]
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

function ButtonBar:GetOptionObject()
	local obj = Bar.GetOptionObject()
	local otbl_general = {
		padding = {
			order = 40,
			type = "range",
			name = L["Padding"],
			desc = L["Configure the padding of the buttons."],
			softMin = -10, softMax = 20, bigStep = 1,
			set = optSetter,
			get = optGetter,
		},
		zoom = {
			order = 59,
			name = L["Zoom"],
			type = "toggle",
			desc = L["Toggle Button Zoom\nFor more style options you need to install ButtonFacade"],
			get = optGetter,
			set = optSetter,
			hidden = function() return LibStub("LibButtonFacade", true) and true or false end,
		},
		rows = {
			order = 70,
			name = L["Rows"],
			desc = L["Number of rows."],
			type = "range",
			min = 1, max = 12, step = 1,
			set = optSetter,
			get = optGetter,
		},
		vgrowth = {
			order = 75,
			name = L["Vertical Growth"],
			desc = L["Vertical growth direction for this bar."],
			type = "select",
			values = {UP = L["Up"], DOWN = L["Down"]},
			set = optSetter,
			get = optGetter,
		},
		hgrowth = {
			order = 76,
			name = L["Horizontal Growth"],
			desc = L["Horizontal growth direction for this bar."],
			type = "select",
			values = {LEFT = L["Left"], RIGHT = L["Right"]},
			set = optSetter,
			get = optGetter,
		},
		hidedesc = {
			order = 80,
			name = L["Button Look"],
			type = "header",
		},
		macrotext = {
			order = 81,
			type = "toggle",
			name = L["Hide Macro Text"],
			desc = L["Hide the Macro Text on the buttons of this bar."],
			set = optSetter,
			get = optGetter,
		},
		hotkey = {
			order = 82,
			type = "toggle",
			name = L["Hide Hotkey"],
			desc = L["Hide the Hotkey on the buttons of this bar."],
			set = optSetter,
			get = optGetter,
		},
		equipped = {
			order = 82,
			type = "toggle",
			name = L["Hide Equipped Border"],
			desc = L["Hide the inner border indicating the equipped status on the buttons of this bar."],
			set = optSetter,
			get = optGetter,
		},
	}
	obj:AddElementGroup("general", otbl_general)
	return obj
end
