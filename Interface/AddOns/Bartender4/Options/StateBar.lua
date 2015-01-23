--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")

local Bar = Bartender4.Bar.prototype
local ButtonBar = Bartender4.ButtonBar.prototype
local StateBar = Bartender4.StateBar.prototype

local tostring, assert, pairs = tostring, assert, pairs

local optGetter, optSetter, getBar
do
	local optionMap, callFunc
	local barregistry = Bartender4.Bar.barregistry

	optionMap = {
		stance = "StanceStateOption",
		enabled = "StateOption",
		def_state = "DefaultState",
		states = "StateOption",
		actionbar = "StateOption",
		possess = "StateOption",
		autoassist = "ConfigAutoAssist",
		mouseover = "ConfigMouseOver",
		customEnabled = "StateOption",
		custom = "StateOption",
		customCopy = "CopyCustomConditionals",
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
		local option = info.arg or info[#info]
		return callFunc(bar, "Get", option, info[#info])
	end

	-- universal function to set a option
	function optSetter(info, ...)
		local bar = getBar(info[2])
		local option = info.arg or info[#info]
		return callFunc(bar, "Set", option, info[#info], ...)
	end
end


local hasStances

local validStanceTable = {
	[0] = L["Don't Page"],
	(L["Page %2d"]):format(1),
	(L["Page %2d"]):format(2),
	(L["Page %2d"]):format(3),
	(L["Page %2d"]):format(4),
	(L["Page %2d"]):format(5),
	(L["Page %2d"]):format(6),
	(L["Page %2d"]):format(7),
	(L["Page %2d"]):format(8),
	(L["Page %2d"]):format(9),
	(L["Page %2d"]):format(10)
}


local _, playerclass = UnitClass("player")

local function createOptionGroup(k, id)
	local tbl = {
		order = 10 * k,
		type = "select",
		arg = "stance",
		values = validStanceTable,
		name = Bartender4.StanceMap[playerclass][k].name,
	}
	return tbl
end

local disabledFunc = function(info)
	local bar = getBar(info[2])
	return not bar:GetStateOption("enabled")
end

local stateOffOrCustomOn = function(info)
	local bar = getBar(info[2])
	return (not bar:GetStateOption("enabled")) or (bar:GetStateOption("customEnabled"))
end

local stateOffOrCustomOff = function(info)
	local bar = getBar(info[2])
	return (not bar:GetStateOption("enabled")) or (not bar:GetStateOption("customEnabled"))
end

function StateBar:GetOptionObject()
	local obj = ButtonBar.GetOptionObject()
	local options = {
		enabled = {
			order = 1,
			type = "toggle",
			name = L["Enabled"],
			desc = L["Enable State-based Button Swaping"],
			get = optGetter,
			set = optSetter,
		},
		header_target = {
			order = 2,
			type = "header",
			name = L["Smart Target selection"],
		},
		target = {
			order = 3,
			type = "group",
			inline = true,
			name = "",
			get = optGetter,
			set = optSetter,
			args = {
				autoassist = {
					order = 2,
					type = "toggle",
					name = L["Auto-Assist Casting"],
					desc = L["Enable Auto-Assist for this bar.\nAuto-Assist will automatically try to cast on your target's target if your target is no valid target for the selected spell."],
					get = optGetter,
					set = optSetter,
				},
				mouseover = {
					order = 3,
					type = "toggle",
					name = L["Mouse-Over Casting"],
					desc = L["Enable Mouse-Over Casting for this bar.\nMouse-Over Casting will automatically cast onto the unit under your mouse without targeting it, if possible."],
					get = optGetter,
					set = optSetter,
				},
				target_desc = {
					order = 10,
					type = "description",
					name = L["These options can automatically select a different target for your spell, based on macro conditions. Note however that they will overrule any target changes from normal macros."],
				},
				mouseover_desc = {
					order = 11,
					type = "description",
					name = L["Mouse-Over casting can be limited to be only active when a modifier key is being held down. You can configure the modifier in the global \"Bar\" Options."],
				},
			}
		},
		header_paging = {
			order = 4,
			type = "header",
			name = L["Bar Paging"],
		},
		possess = {
			order = 5,
			type = "toggle",
			name = L["Possess Bar"],
			desc = L["Switch this bar to the Possess Bar when possessing a npc (eg. Mind Control)"],
			get = optGetter,
			set = optSetter,
			disabled = stateOffOrCustomOn,
		},
		actionbar = {
			order = 6,
			type = "toggle",
			name = L["ActionBar Paging"],
			desc = L["Enable Bar Switching based on the actionbar controls provided by the game. \nSee Blizzard Key Bindings for assignments - Usually Shift-Mouse Wheel and Shift+1 - Shift+6."],
			get = optGetter,
			set = optSetter,
			disabled = stateOffOrCustomOn,
		},
		def_desc = {
			order = 10,
			type = "description",
			name = L["The default behaviour of this bar when no state-based paging option affects it."],
		},
		def_state = {
			order = 11,
			type = "select",
			name = L["Default Bar State"],
			values = validStanceTable,
			get = optGetter,
			set = optSetter,
			disabled = stateOffOrCustomOn,
		},
		modifiers = {
			order = 30,
			type = "group",
			inline = true,
			name = "",
			get = optGetter,
			set = optSetter,
			disabled = stateOffOrCustomOn,
			args = {
				header = {
					order = 1,
					type = "header",
					name = L["Modifier Based Switching"],
				},
				ctrl = {
					order = 10,
					type = "select",
					name = L["CTRL"],
					arg = "states",
					values = validStanceTable,
					desc = (L["Configure actionbar paging when the %s key is down."]):format(L["CTRL"]),
					--width = "half",
				},
				alt = {
					order = 15,
					type = "select",
					name = L["ALT"],
					arg = "states",
					values = validStanceTable,
					desc = (L["Configure actionbar paging when the %s key is down."]):format(L["ALT"]),
					--width = "half",
				},
				shift = {
					order = 20,
					type = "select",
					name = L["SHIFT"],
					arg = "states",
					values = validStanceTable,
					desc = (L["Configure actionbar paging when the %s key is down."]):format(L["SHIFT"]),
					--width = "half",
				},
			},
		},
		stances = {
			order = 20,
			type = "group",
			inline = true,
			name = "",
			hidden = function() return not (Bartender4.StanceMap[playerclass]) end,
			get = optGetter,
			set = optSetter,
			disabled = stateOffOrCustomOn,
			args = {
				stance_header = {
					order = 1,
					type = "header",
					name = L["Stance Configuration"],
				},
			},
		},
		customNl = {
			order = 48,
			type = "description",
			name = "\n",
		},
		customHeader = {
			order = 49,
			type = "header",
			name = L["Custom Conditionals"],
		},
		customEnabled = {
			order = 50,
			type = "toggle",
			name = L["Use Custom Condition"],
			desc = L["Enable the use of a custom condition, disabling all of the above."],
			get = optGetter,
			set = optSetter,
			disabled = disabledFunc,
			--width = "double",
		},
		customCopy = {
			order = 51,
			type = "execute",
			name = L["Copy Conditionals"],
			desc = L["Create a copy of the auto-generated conditionals in the custom configuration as a base template."],
			func = optSetter,
			disabled = disabledFunc,
		},
		customDesc = {
			order = 52,
			type = "description",
			name = L["Note: Enabling Custom Conditionals will disable all of the above settings!"],
		},
		custom = {
			order = 55,
			type = "input",
			name = L["Custom Conditionals"],
			desc = L["You can use any macro conditionals in the custom string, using the number of the bar as target value.\nExample: [form:1]9;0"],
			width = "full",
			get = optGetter,
			set = optSetter,
			disabled = stateOffOrCustomOff,
			multiline = true,
		},
	}

	do
		local defstancemap = Bartender4.StanceMap[playerclass]
		if defstancemap then
			for k,v in pairs(defstancemap) do
				if not options.stances.args[v.id] then
					options.stances.args[v.id] = createOptionGroup(k, v.id)
				end
			end
		end
	end

	local states = {
		type = "group",
		name = L["State Configuration"],
		order = 25,
		args = options,
	}
	obj:NewCategory("state", states)

	return obj
end
