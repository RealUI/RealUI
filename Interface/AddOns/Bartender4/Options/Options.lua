--[[
	Copyright (c) 2009-2015, Hendrik "Nevcairiel" Leppkes < h.leppkes at gmail dot com >
	All rights reserved.
]]
local _, Bartender4 = ...
local L = LibStub("AceLocale-3.0"):GetLocale("Bartender4")

local AceConfigDialog = LibStub("AceConfigDialog-3.0")

local error, select, pairs = error, select, pairs

-- GLOBALS: LibStub, UnitHasVehicleUI, GetModifiedClick, SetModifiedClick, SaveBindings, GetCurrentBindingSet, InCombatLockdown

local getFunc, setFunc
do
	function getFunc(info)
		return (info.arg and Bartender4.db.profile[info.arg] or Bartender4.db.profile[info[#info]])
	end

	function setFunc(info, value)
		local key = info.arg or info[#info]
		Bartender4.db.profile[key] = value
	end
end

local KB = LibStub("LibKeyBound-1.0")
local LDBIcon = LibStub("LibDBIcon-1.0", true)
local LibDualSpec = LibStub("LibDualSpec-1.0", true)

local function generateOptions()
	Bartender4.options = {
		type = "group",
		name = "Bartender4",
		icon = "Interface\\Icons\\INV_Drink_05",
		childGroups = "tree",
		plugins = {},
		args = {
			lock = {
				order = 1,
				type = "toggle",
				name = L["Lock"],
				desc = L["Lock all bars."],
				get = function() return Bartender4.Locked end,
				set = function(info, value) Bartender4[value and "Lock" or "Unlock"](Bartender4) end,
				width = "half",
			},
			buttonlock = {
				order = 2,
				type = "toggle",
				name = L["Button Lock"],
				desc = L["Lock the buttons."],
				get = function() return Bartender4.db.profile.buttonlock end,
				set = function(info, value)
					Bartender4.db.profile.buttonlock = value
					Bartender4.Bar:ForAll("ForAll", "SetAttribute", "buttonlock", value)
				end,
			},
			minimapIcon = {
				order = 3,
				type = "toggle",
				name = L["Minimap Icon"],
				desc = L["Show a Icon to open the config at the Minimap"],
				get = function() return not Bartender4.db.profile.minimapIcon.hide end,
				set = function(info, value) Bartender4.db.profile.minimapIcon.hide = not value; LDBIcon[value and "Show" or "Hide"](LDBIcon, "Bartender4") end,
				disabled = function() return not LDBIcon end,
			},
			kb = {
				order = 4,
				type = "execute",
				name = L["Key Bindings"],
				desc = L["Switch to key-binding mode"],
				func = function()
					KB:Toggle()
					AceConfigDialog:Close("Bartender4")
				end,
			},
			bars = {
				order = 20,
				type = "group",
				name = L["Bars"],
				args = {
					options = {
						type = "group",
						order = 0,
						name = function(info) if info.uiType == "dialog" then return "" else return L["Bar Options"] end end,
						guiInline = true,
						args = {
							blizzardVehicle = {
								order = 1,
								type = "toggle",
								name = L["Use Blizzard Vehicle UI"],
								desc = L["Enable the use of the Blizzard Vehicle UI, hiding any Bartender4 bars in the meantime."],
								width = "full",
								get = getFunc,
								set = function(info, value)
									if UnitHasVehicleUI("player") then
										Bartender4:Print(L["You have to exit the vehicle in order to be able to change the Vehicle UI settings."])
										return
									end
									Bartender4.db.profile.blizzardVehicle = value
									Bartender4:UpdateBlizzardVehicle()
								end,
							},
							onkeydown = {
								order = 2,
								type = "toggle",
								name = L["Toggle actions on key press instead of release"],
								desc = L["Toggles actions immediately when you press the key, and not only on release. Note that draging actions will cause them to be cast in this mode."],
								get = getFunc,
								set = function(info, value)
									Bartender4.db.profile.onkeydown = value
									Bartender4.Bar:ForAll("UpdateButtonConfig")
								end,
								width = "full",
							},
							selfcastmodifier = {
								order = 10,
								type = "toggle",
								name = L["Self-Cast by modifier"],
								desc = L["Toggle the use of the modifier-based self-cast functionality."],
								get = getFunc,
								set = function(info, value)
									Bartender4.db.profile.selfcastmodifier = value
									Bartender4.Bar:ForAll("UpdateSelfCast")
								end,
							},
							setselfcastmod = {
								order = 20,
								type = "select",
								name = L["Self-Cast Modifier"],
								desc = L["Select the Self-Cast Modifier"],
								get = function(info) return GetModifiedClick("SELFCAST") end,
								set = function(info, value) SetModifiedClick("SELFCAST", value); SaveBindings(GetCurrentBindingSet() or 1) end,
								values = { NONE = L["None"], ALT = L["ALT"], SHIFT = L["SHIFT"], CTRL = L["CTRL"] },
							},
							selfcast_nl = {
								order = 30,
								type = "description",
								name = "",
							},
							focuscastmodifier = {
								order = 50,
								type = "toggle",
								name = L["Focus-Cast by modifier"],
								desc = L["Toggle the use of the modifier-based focus-cast functionality."],
								get = getFunc,
								set = function(info, value)
									Bartender4.db.profile.focuscastmodifier = value
									Bartender4.Bar:ForAll("UpdateSelfCast")
								end,
							},
							setfocuscastmod = {
								order = 60,
								type = "select",
								name = L["Focus-Cast Modifier"],
								desc = L["Select the Focus-Cast Modifier"],
								get = function(info) return GetModifiedClick("FOCUSCAST") end,
								set = function(info, value) SetModifiedClick("FOCUSCAST", value); SaveBindings(GetCurrentBindingSet() or 1) end,
								values = { NONE = L["None"], ALT = L["ALT"], SHIFT = L["SHIFT"], CTRL = L["CTRL"] },
							},
							focuscast_nl = {
								order = 70,
								type = "description",
								name = "",
							},
							selfcastrightclick = {
								order = 80,
								type = "toggle",
								name = L["Right-click Self-Cast"],
								desc = L["Toggle the use of the right-click self-cast functionality."],
								get = getFunc,
								set = function(info, value)
									Bartender4.db.profile.selfcastrightclick = value
									Bartender4.Bar:ForAll("UpdateSelfCast")
								end,
							},
							rightclickselfcast_nl = {
								order = 90,
								type = "description",
								name = "",
							},
							range = {
								order = 100,
								name = L["Out of Range Indicator"],
								desc = L["Configure how the Out of Range Indicator should display on the buttons."],
								type = "select",
								style = "dropdown",
								get = function()
									return Bartender4.db.profile.outofrange
								end,
								set = function(info, value)
									Bartender4.db.profile.outofrange = value
									Bartender4.Bar:ForAll("UpdateButtonConfig")
								end,
								values = { none = L["No Display"], button = L["Full Button Mode"], hotkey = L["Hotkey Mode"] },
							},
							tooltip = {
								order = 110,
								name = L["Button Tooltip"],
								type = "select",
								desc = L["Configure the Button Tooltip."],
								values = { ["disabled"] = L["Disabled"], ["nocombat"] = L["Disabled in Combat"], ["enabled"] = L["Enabled"] },
								get = function() return Bartender4.db.profile.tooltip end,
								set = function(info, value)
									Bartender4.db.profile.tooltip = value
									Bartender4.Bar:ForAll("UpdateButtonConfig")
								end,
							},
							colors = {
								order = 130,
								type = "group",
								guiInline = true,
								name = L["Colors"],
								get = function(info)
									local color = Bartender4.db.profile.colors[info[#info]]
									return color.r, color.g, color.b
								end,
								set = function(info, r, g, b)
									local color = Bartender4.db.profile.colors[info[#info]]
									color.r, color.g, color.b = r, g, b
									Bartender4.Bar:ForAll("UpdateButtonConfig")
								end,
								args = {
									range = {
										order = 1,
										type = "color",
										name = L["Out of Range Indicator"],
										desc = L["Specify the Color of the Out of Range Indicator"],
									},
									mana = {
										order = 2,
										type = "color",
										name = L["Out of Mana Indicator"],
										desc = L["Specify the Color of the Out of Mana Indicator"],
									},
								},
							},
							header_target = {
								order = 300,
								type = "header",
								name = L["Mouse-Over Casting"],
							},
							mouseovermod = {
								order = 301,
								type = "select",
								name = L["Mouse-Over Casting Modifier"],
								desc = L["Select a modifier for Mouse-Over Casting"],
								get = function(info) return Bartender4.db.profile.mouseovermod end,
								set = function(info, value) Bartender4.db.profile.mouseovermod = value; Bartender4.Bar:ForAll("UpdateStates") end,
								values = { NONE = L["None"], ALT = L["ALT"], SHIFT = L["SHIFT"], CTRL = L["CTRL"] },
							},
							mouseovermod_desc = {
								order = 302,
								type = "description",
								name = "\n" .. L["\"None\" as modifier means its always active, and no modifier is required.\n\nRemember to enable Mouse-Over Casting for the individual bars, on the \"State Configuration\" tab, if you want it to be active for a specific bar."],
							},
						},
					},
				},
			},
			faq = {
				name = L["FAQ"],
				desc = L["Frequently Asked Questions"],
				type = "group",
				order = 1000,
				args = {
					line1 = {
						type = "description",
						name = "|cffffd200" .. L["I just installed Bartender4, but my keybindings do not show up on the buttons/do not work."] .. "|r",
						order = 1,
					},
					line2 = {
						type = "description",
						name = L["Bartender4 only converts the bindings of Bar1 to be directly usable, all other Bars will have to be re-bound to the Bartender4 keys. A direct indicator if your key-bindings are setup correctly is the hotkey display on the buttons. If the key-bindings shows correctly on your button, everything should work fine as well."],
						order = 2,
					},
					line3 = {
						type = "description",
						name = "|cffffd200" .. L["How do I change the Bartender4 Keybindings then?"] .. "|r",
						order = 3,
					},
					line4 = {
						type = "description",
						name = L["You can either click the KeyBound button in the options, or use the |cffffff78/kb|r chat command to open the keyBound control. Alternatively, you can also use the Blizzard Keybinding Interface."] .. "\n\n" .. L["Once open, simply hover the button you want to bind, and press the key you want to be bound to that button. The keyBound tooltip and on-screen status will inform you about already existing bindings to that button, and the success of your binding attempt."],
						order = 4,
					},
					line7 = {
						type = "description",
						name = "\n|cffffd200" .. L["I've found a bug! Where do I report it?"] .. "|r",
						order = 7,
					},
					line8 = {
						type = "description",
						name = L["You can report bugs or give suggestions at the discussion forums at |cffffff78http://forums.wowace.com/showthread.php?t=12513|r or check the project page at |cffffff78http://www.wowace.com/addons/bartender4/|r"],
						order = 8,
					},
					line9 = {
						type = "description",
						name = "\n" .. L["Alternatively, you can also find us on |cffffff78irc://irc.freenode.org/wowace|r"] .. "\n",
						order = 9,
					},
					line10 = {
						type = "description",
						name = L["When reporting a bug, make sure you include the |cffffff78steps on how to reproduce the bug|r, supply any |cffffff78error messages|r with stack traces if possible, give the |cffffff78revision number|r of Bartender4 the problem occured in and state whether you are using an |cffffff78English client or otherwise|r."],
						order = 10,
					},
					line11 = {
						type = "description",
						name = "\n|cffffd200" .. L["Who wrote this cool addon?"] .. "|r",
						order = 11,
					},
					line12= {
						type = "description",
						name = L["Bartender4 was written by Nevcairiel of EU-Antonidas. He will accept cookies as compensation for his hard work!"],
						order = 12,
					},
				},
			},
		},
	}
	Bartender4.options.plugins.profiles = { profiles = LibStub("AceDBOptions-3.0"):GetOptionsTable(Bartender4.db) }
	for k,v in Bartender4:IterateModules() do
		if v.SetupOptions then
			v:SetupOptions()
		end
	end
	if LibDualSpec then
		LibDualSpec:EnhanceOptions(Bartender4.options.plugins.profiles.profiles, Bartender4.db)
	end
end

local function getOptions()
	if not Bartender4.options then
		generateOptions()
		-- let the generation function be GCed
		generateOptions = nil
	end
	return Bartender4.options
end

function Bartender4:ChatCommand(input)
	if InCombatLockdown() then
		self:Print(L["Cannot access options during combat."])
		return
	end
	if not input or input:trim() == "" then
		LibStub("AceConfigDialog-3.0"):Open("Bartender4")
	else
		LibStub("AceConfigCmd-3.0").HandleCommand(Bartender4, "bt", "Bartender4", input)
	end
end

function Bartender4:SetupOptions()
	LibStub("AceConfig-3.0"):RegisterOptionsTable("Bartender4", getOptions)
	AceConfigDialog:SetDefaultSize("Bartender4", 680,525)
	self:RegisterChatCommand( "bt", "ChatCommand")
	self:RegisterChatCommand( "bt4", "ChatCommand")
	self:RegisterChatCommand( "bartender", "ChatCommand")
	self:RegisterChatCommand( "bartender4", "ChatCommand")
end

function Bartender4:RegisterModuleOptions(key, table)
	if not self.options then
		error("Options table has not been created yet, respond to the callback!", 2)
	end
	self.options.plugins[key] = { [key] = table }
end

function Bartender4:RegisterBarOptions(id, table)
	if not self.options then
		error("Options table has not been created yet, respond to the callback!", 2)
	end
	self.options.args.bars.args[id] = table
end

local optionParent = {}
function optionParent:NewCategory(category, data)
	self.table[category] = data
end

local ov = nil
function optionParent:AddElement(category, element, data, ...)
	local lvl = self.table[category]
	for i = 1, select('#', ...) do
		local key = select(i, ...)
		if not (lvl.args[key] and lvl.args[key].args) then
			error(("Sub-Level Key %s does not exist in options group or is no sub-group."):format(key), ov and 3 or 2)
		end
		lvl = lvl.args[key]
	end

	lvl.args[element] = data
end

function optionParent:AddElementGroup(category, data, ...)
	ov = true
	for k,v in pairs(data) do
		self:AddElement(category, k, v, ...)
	end
	ov = nil
end

function Bartender4:NewOptionObject(otbl)
	if not otbl then otbl = {} end
	local tbl = { table = otbl }
	for k, v in pairs(optionParent) do
		tbl[k] = v
	end

	return tbl
end
