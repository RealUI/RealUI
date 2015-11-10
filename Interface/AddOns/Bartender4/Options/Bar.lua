--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")
local Bar = Bartender4.Bar.prototype

local tonumber, tostring, assert, select, floor = tonumber, tostring, assert, select, floor

-- GLOBALS: GetNumShapeshiftForms, GetShapeshiftFormInfo, GetSpellInfo

--[[===================================================================================
	Bar Options
===================================================================================]]--

local barregistry = Bartender4.Bar.barregistry

local function round(num, idp)
  local mult = 10^(idp or 0)
  return floor(num * mult + 0.5) / mult
end

-- option utilty functions
local optGetter, optSetter, visibilityGetter, visibilitySetter, customEnabled, customDisabled, customCopy, clickThroughVis, posGet, posSet, centerHorz, centerVert, resetPos
do
	local getBar, optionMap, callFunc
	-- maps option keys to function names
	optionMap = {
		alpha = "ConfigAlpha",
		scale = "ConfigScale",
		fadeout = "FadeOut",
		fadeoutalpha = "FadeOutAlpha",
		fadeoutdelay = "FadeOutDelay",
		clickthrough = "ClickThrough",
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

	function visibilityGetter(info, ...)
		local bar = getBar(info[2])
		local option = info[#info]
		return bar:GetVisibilityOption(option, ...)
	end

	function visibilitySetter(info, ...)
		local bar = getBar(info[2])
		local option = info[#info]
		bar:SetVisibilityOption(option, ...)
	end

	function customEnabled(info)
		local bar = getBar(info[2])
		return bar:GetVisibilityOption("custom")
	end

	function customDisabled(info)
		local bar = getBar(info[2])
		return not bar:GetVisibilityOption("custom")
	end

	function customCopy(info)
		local bar = getBar(info[2])
		bar:CopyCustomConditionals()
	end

	function clickThroughVis(info)
		local bar = getBar(info[2])
		return (not bar.ClickThroughSupport)
	end

	function posGet(info)
		local bar = getBar(info[2])
		local opt = info.arg or info[#info]
		if opt == "x" or opt == "y" then
			local v = bar.config.position[opt]
			return tostring(round(v, 5))
		end
		return bar.config.position[opt]
	end

	function posSet(info, value)
		local bar = getBar(info[2])
		local opt = info.arg or info[#info]
		if opt == "x" or opt == "y" then
			value = tonumber(value)
		end
		bar.config.position[opt] = value
		bar:LoadPosition()
	end

	function centerHorz(info)
		local bar = getBar(info[2])
		local pos = bar.config.position
		local x_mod = (pos.growHorizontal == "RIGHT") and -1 or 1
		pos.x = (bar.overlay:GetWidth() / 2) * pos.scale * x_mod
		if pos.point == "CENTER" or pos.point == "LEFT" or pos.point == "RIGHT" then -- no special handling
			pos.point = "CENTER"
		else
			pos.point = pos.point:gsub("LEFT", ""):gsub("RIGHT", "")
		end
		bar:LoadPosition()
	end

	function centerVert(info)
		local bar = getBar(info[2])
		local pos = bar.config.position
		local y_mod = (pos.growVertical == "DOWN") and 1 or -1
		pos.y = (bar.overlay:GetHeight() / 2) * pos.scale * y_mod
		if pos.point == "CENTER" or pos.point == "TOP" or pos.point == "BOTTOM" then -- no special handling
			pos.point = "CENTER"
		else
			pos.point = pos.point:gsub("TOP", ""):gsub("BOTTOM", "")
		end
		bar:LoadPosition()
	end

	function resetPos(info)
		local bar = getBar(info[2])
		local pos = bar.config.position
		local x_mod = (pos.growHorizontal == "RIGHT") and -1 or 1
		local y_mod = (pos.growVertical == "DOWN") and 1 or -1
		pos.x = (bar.overlay:GetWidth() / 2) * pos.scale * x_mod
		pos.y = (bar.overlay:GetHeight() / 2) * pos.scale * y_mod
		pos.point = "CENTER"
		bar:LoadPosition()
	end
end

local _, class = UnitClass("player")
local function getStanceTable()
	local tbl = {}

	if class ~= "WARRIOR" then
		tbl[0] = L["No Stance/Form"]
	end

	local num = GetNumShapeshiftForms()
	for i = 1, num do
		tbl[i] = select(2, GetShapeshiftFormInfo(i))
	end
	-- HACK: Metamorphosis work around, it is on slot 1 in GetShapeshiftFormInfo() but stance:2 is active..
	if class == "WARLOCK" and tbl[1] == GetSpellInfo(59672) then
		tbl[2], tbl[1] = tbl[1], nil
	end

	if class == "ROGUE" and tbl[1] == GetSpellInfo(51713) then -- shadow dance hack
		tbl[3], tbl[1] = tbl[1], nil
	end
	return tbl
end

local validAnchors = {
	CENTER = "CENTER",
	LEFT = "LEFT",
	RIGHT = "RIGHT",
	TOP = "TOP",
	TOPLEFT = "TOPLEFT",
	TOPRIGHT = "TOPRIGHT",
	BOTTOM = "BOTTOM",
	BOTTOMLEFT = "BOTTOMLEFT",
	BOTTOMRIGHT = "BOTTOMRIGHT",
}

local options
function Bar:GetOptionObject()
	local otbl = {
		general = {
			type = "group",
			cmdInline = true,
			name = L["General Settings"],
			order = 10,
			args = {
				styleheader = {
					order = 10,
					type = "header",
					name = L["Bar Style & Layout"],
				},
				alpha = {
					order = 20,
					name = L["Alpha"],
					desc = L["Configure the alpha of the bar."],
					type = "range",
					min = 0, max = 1, bigStep = 0.05,
					isPercent  = true,
					get = optGetter,
					set = optSetter,
				},
				scale = {
					order = 30,
					name = L["Scale"],
					desc = L["Configure the scale of the bar."],
					type = "range",
					min = 0, softMin = .1, softMax = 2, bigStep = 0.05,
					get = optGetter,
					set = optSetter,
				},
				clickthrough = {
					order = 200,
					name = L["Click-Through"],
					desc = L["Disable any reaction to mouse events on this bar, making the bar click-through."],
					type = "toggle",
					get = optGetter,
					set = optSetter,
					hidden = clickThroughVis,
					width = "full",
				},
			},
		},
		visibility = {
			type = "group",
			name = L["Visibility"],
			order = 20,
			get = visibilityGetter,
			set = visibilitySetter,
			args = {
				info = {
					order = 1,
					type = "description",
					name = L["The bar default is to be visible all the time, you can configure conditions here to control when the bar should be hidden."] .. "\n",
				},
				fadeout = {
					order = 5,
					name = L["Fade Out"],
					desc = L["Enable the FadeOut mode"],
					type = "toggle",
					get = optGetter,
					set = optSetter,
					width = "full",
				},
				fadeoutalpha = {
					order = 6,
					name = L["Fade Out Alpha"],
					desc = L["Configure the Fade Out Alpha"],
					type = "range",
					min = 0, max = 1, bigStep = 0.05,
					isPercent  = true,
					get = optGetter,
					set = optSetter,
				},
				fadeoutdelay = {
					order = 7,
					name = L["Fade Out Delay"],
					desc = L["Configure the Fade Out Delay"],
					type = "range",
					min = 0, softMax = 1, bigStep = 0.01,
					get = optGetter,
					set = optSetter,
				},
				fadeNl = {
					order = 8,
					type = "description",
					name = "",
				},
				always = {
					order = 10,
					type = "toggle",
					name = L["Always Hide"],
					desc = L["You can set the bar to be always hidden, if you only wish to access it using key-bindings."],
					disabled = customEnabled,
				},
				possess = {
					order = 15,
					type = "toggle",
					name = L["Hide when Possessing"],
					desc = L["Hide this bar when you are possessing a NPC."],
					disabled = customEnabled,
				},
				vehicle = {
					order = 16,
					type = "toggle",
					name = L["Hide on Vehicle"],
					desc = L["Hide this bar when you are riding on a vehicle."],
					disabled = customEnabled,
				},
				vehicleui = {
					order = 17,
					type = "toggle",
					name = L["Hide with Vehicle UI"],
					desc = L["Hide this bar when the game wants to show a vehicle UI."],
					disabled = customEnabled,
				},
				overridebar = {
					order = 18,
					type = "toggle",
					name = L["Hide with Override Bar"],
					desc = L["Hide this bar when a override bar is active."],
					disabled = customEnabled,
				},
				combat = {
					order = 20,
					type = "toggle",
					name = L["Hide in Combat"],
					desc = L["This bar will be hidden once you enter combat."],
					disabled = customEnabled,
				},
				nocombat = {
					order = 21,
					type = "toggle",
					name = L["Hide out of Combat"],
					desc = L["This bar will be hidden whenever you are not in combat."],
					disabled = customEnabled,
				},
				pet = {
					order = 30,
					type = "toggle",
					name = L["Hide with pet"],
					desc = L["Hide this bar when you have a pet."],
					disabled = customEnabled,
				},
				nopet = {
					order = 31,
					type = "toggle",
					name = L["Hide without pet"],
					desc = L["Hide this bar when you have no pet."],
					disabled = customEnabled,
				},
				stance = {
					order = 50,
					type = "multiselect",
					name = L["Hide in Stance/Form"],
					desc = L["Hide this bar in a specific Stance or Form."],
					values = getStanceTable,
					disabled = customEnabled,
				},
				customNl = {
					order = 98,
					type = "description",
					name = "\n",
				},
				customHeader = {
					order = 99,
					type = "header",
					name = L["Custom Conditionals"],
				},
				custom = {
					order = 100,
					type = "toggle",
					name = L["Use Custom Condition"],
					desc = L["Enable the use of a custom condition, disabling all of the above."],
				},
				customCopy = {
					order = 101,
					type = "execute",
					name = L["Copy Conditionals"],
					desc = L["Create a copy of the auto-generated conditionals in the custom configuration as a base template."],
					func = customCopy,
				},
				customDesc = {
					order = 102,
					type = "description",
					name = L["Note: Enabling Custom Conditionals will disable all of the above settings!"],
				},
				customdata = {
					order = 103,
					type = "input",
					name = L["Custom Conditionals"],
					desc = L["You can use any macro conditionals in the custom string, using \"show\" and \"hide\" as values.\n\nExample: [combat]hide;show"],
					width = "full",
					multiline = true,
					disabled = customDisabled,
				},
			},
		},
		position = {
			type = "group",
			name = L["Positioning"],
			order = 30,
			args = {
				info = {
					order = 1,
					type = "description",
					name = L["The Positioning options here will allow you to position the bar to your liking and with an absolute precision."],
				},
				point = {
					order = 10,
					type = "select",
					name = L["Anchor"],
					desc = L["Change the current anchor point of the bar."],
					values = validAnchors,
					get = posGet,
					set = posSet,
				},
				scale = {
					order = 11,
					name = L["Scale"],
					desc = L["Configure the scale of the bar."],
					type = "range",
					min = 0, softMin = .1, softMax = 2, bigStep = 0.05,
					get = optGetter,
					set = optSetter,
				},
				nl1 = {
					order = 12,
					type = "description",
					name = "",
				},
				x = {
					order = 20,
					type = "input",
					name = L["X Offset"],
					desc = L["Offset in X direction (horizontal) from the given anchor point."],
					get = posGet,
					set = posSet,
					dialogControl = "NumberEditBox",
				},
				y = {
					order = 21,
					type = "input",
					name = L["Y Offset"],
					desc = L["Offset in Y direction (vertical) from the given anchor point."],
					get = posGet,
					set = posSet,
					dialogControl = "NumberEditBox",
				},
				nl2 = {
					order = 25,
					type = "description",
					name = "",
				},
				centerhorz = {
					order = 31,
					type = "execute",
					name = L["Center Horizontally"],
					desc = L["Centers the bar horizontally on screen."],
					func = centerHorz,
				},
				centervert = {
					order = 31,
					type = "execute",
					name = L["Center Vertically"],
					desc = L["Centers the bar vertically on screen."],
					func = centerVert,
				},
				nl3 = {
					order = 35,
					type = "description",
					name = " ",
				},
				reset = {
					order = 40,
					type = "execute",
					name = L["Reset Position"],
					desc = L["Reset the position of this bar completly if it ended up off-screen and you cannot reach it anymore."],
					func = resetPos,
				},
			},
		}
	}
	return Bartender4:NewOptionObject(otbl)
end
