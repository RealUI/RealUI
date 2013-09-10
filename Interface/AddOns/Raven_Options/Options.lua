-- Raven is an addon to monitor auras and cooldowns, providing timer bars, action bar highlights, and helpful notifications.
-- Raven_Options is a load-on-demand module that only gets loaded and initialized when the user requests the GUI

-- Options.lua contains the tables used by the options panel as well as all the supporting functions for displaying
-- current settings, bar groups, conditions, etc.

local MOD = Raven
local acereg = LibStub("AceConfigRegistry-3.0")
local acedia = LibStub("AceConfigDialog-3.0")
local L = LibStub("AceLocale-3.0"):GetLocale("Raven")
local initialized = false -- set when options are first accessed

local standard = { -- standard bar groups for "getting started"
	PlayerBuffs = false, PlayerDebuffs = false, Cooldowns = false, Target = false, Focus = false, Totems = false,
	Runes = false, Notifications = false, ShortBuffs = false, LongBuffs = false, BuffTracker = false, DebuffTracker = false, Timeline = false,
}

local cooldowns = { -- settings used to enter internal cooldowns
	select = nil, disable = nil, duration = nil, cancel = nil, caster = nil, enter = false, toggle = false
}

local effects = { -- settings used to enter spell effects
	select = nil, disable = nil, duration = nil, kind = nil, renew = nil, spell = nil, caster = nil, label = nil,
	talent = nil, buff = nil, condition = nil, enter = false, toggle = false
}

local lists = { -- settings used to enter spell lists
	select = nil, enter = false, toggle = false, list = nil, spell = nil
}

local bars = { -- settings used to enter bars and bar groups
	enter = false, toggle = false, auto = false, mode = false, template = nil, save = nil, config = nil,
}

local conditions = { -- settings used to enter conditions
	select = nil, enter = false, toggle = false, dependency = nil, profiles = {}, name = nil, buff = nil
}

local weaponBuffs = { [L["Mainhand Weapon"]] = true, [L["Offhand Weapon"]] = true }

local anchorTips = { BOTTOMLEFT = "BOTTOMLEFT", CURSOR = "CURSOR", DEFAULT = "DEFAULT", LEFT = "LEFT", RIGHT = "RIGHT",
	TOPLEFT = "TOPLEFT", TOPRIGHT = "TOPRIGHT" }
	
local anchorPoints = { BOTTOM = "BOTTOM", BOTTOMLEFT = "BOTTOMLEFT", BOTTOMRIGHT = "BOTTOMRIGHT", CENTER = "CENTER", LEFT = "LEFT",
	RIGHT = "RIGHT", TOP = "TOP", TOPLEFT = "TOPLEFT", TOPRIGHT = "TOPRIGHT" }
	
local stratas = { BACKGROUND = "BACKGROUND", LOW = "LOW", MEDIUM = "MEDIUM", HIGH = "HIGH" }

-- Saved variables don't handle being set to nil properly so need to use alternate value to indicate an option has been turned off
local Off = 0 -- value used to designate an option is turned off
local function IsOff(value) return value == nil or value == Off end -- return true if option is turned off
local function IsOn(value) return value ~= nil and value ~= Off end -- return true if option is turned on

local function InMode(t) -- return true if locked into entry mode of specified type
	if t == "Bar" then return bars.mode end
	if t == "BG" then return bars.mode or bars.enter end
	if t == "Not" then return conditions.enter end
	return bars.mode or bars.enter or conditions.enter
end 

-- Check if spell name is valid and display a warning if it is not, convert ids and spell hyperlinks, return validated spell name or nil
-- Optionally support the #12345 spell id format for spell lists
local function ValidateSpellName(name, allowPlusIDs)
	if not name or (name == "") then return nil end
	if allowPlusIDs then
		if string.find(name, "^#%d+") then local id = tonumber(string.sub(name, 2)); if id and GetSpellInfo(id) then return name end return nil end
	end
	local t = tonumber(name)
	if t then
		name = GetSpellInfo(t) -- convert spell id
	else
		local found, _, idString = string.find(name, "^|c%x+|Hspell:(.+)|h%[.*%]")
		if found then local id = tonumber(idString); if id then name = GetSpellInfo(id) end end -- convert hyperlink
	end
	if not MOD:GetIcon(name) then
		print(L["Not valid string"](name))
		return nil
	end
	return name
end

-- Return a sorted list suitable for an input selection widget
local function GetSortedList(list) local i, t = 0, {}; if list then for n in pairs(list) do i = i + 1; t[i] = n end end; table.sort(t); return t end
local function GetSortedListEntry(list, n) for i, k in pairs(GetSortedList(list)) do if n == k then return i end end return nil end

-- Update the addon when the profile changes
local function OnProfileChanged()
	conditions.profiles = {} -- necessary since this is not cached in the profile itself
	MOD:InitializeBars() -- required because of the linkage between the profile and LibBars
end

-- Initialize options for the configuration GUI
-- Register the options table and link to the Blizz addons interface
local function InitializeOptions()
	initialized = true -- only do this once	
	local options = MOD.OptionsTable	
	options.args.profile = LibStub("AceDBOptions-3.0"):GetOptionsTable(MOD.db) -- fill in the profile section
	options.args.profile.disabled = function(info) return InMode() end,
	
	acereg:RegisterOptionsTable("Raven", options)
	acereg:RegisterOptionsTable("Raven: "..options.args.FrontPage.name, options.args.FrontPage)
	acereg:RegisterOptionsTable("Raven: "..options.args.BarGroups.name, options.args.BarGroups)
	acereg:RegisterOptionsTable("Raven: "..options.args.Conditions.name, options.args.Conditions)
	acereg:RegisterOptionsTable("Raven: "..options.args.Highlights.name, options.args.Highlights)
	acereg:RegisterOptionsTable("Raven: "..options.args.profile.name, options.args.profile)
	acereg:RegisterOptionsTable("Raven Options", MOD.TopOptionsTable)
	acedia:AddToBlizOptions("Raven Options", "Raven")

	local w, h = 890, 680 -- somewhat arbitrary numbers that seem to work for the configuration dialog layout
	acedia:SetDefaultSize("Raven", w, h)
	
	MOD.db.RegisterCallback(MOD, "OnProfileChanged", OnProfileChanged)
	MOD.db.RegisterCallback(MOD, "OnProfileCopied", OnProfileChanged)
	MOD.db.RegisterCallback(MOD, "OnProfileReset", OnProfileChanged)
end

-- Update options in case anything changes
function MOD:UpdateOptions()
	if initialized and acedia.OpenFrames["Raven"] then
		acereg:NotifyChange("Raven")
	end
	MOD:ForceUpdate()
end

-- Toggle display of the options panel
function MOD:ToggleOptions()
	if not initialized then InitializeOptions() end
	if acedia.OpenFrames["Raven"] then
		acedia:Close("Raven")
	else
		acedia:Open("Raven")
	end
	collectgarbage("collect")
end

-- Generic function to build and return a sorted list of names stored in a profile table
-- Assumes table entries are arrays with the names indexed by "name"
local function GetNameList(id, t)
	local i, list = 0, {} -- build the name list from the profile table
	
	if IsOff(t) then
		conditions.profiles[id] = nil -- no selection for empty list
		return list -- empty list if t is not defined
	end

	local selection = conditions.profiles[id] -- make sure still a valid selection
	local found = false
	for _, n in pairs(t) do
		if IsOn(n) and n.name then
			i = i + 1
			list[i] = n.name
			if n.name == selection then found = true end
		end
	end
	table.sort(list)
	
	if not found and (i > 0) then -- check that current selection, if any, was found in the table
		conditions.profiles[id] = list[1] -- default is first entry in the list
	end
	return list
end

-- Generic function to add a new entry to a profile table, assumes "name" is field in the entry
local function AddNameEntry(id, t, newEntry)
	t[newEntry.name] = newEntry -- add the new entry indexed by its name to facilitate reverse lookup
	GetNameList(id, t) -- initializes the cached settings, if necessary
	conditions.profiles[id] = newEntry.name
end

-- Generic function to delete a name entry from a profile table
local function DeleteNameEntry(id, t)
	-- Get the cached list of names and the selected name
	local list = GetNameList(id, t)
	local selection = conditions.profiles[id]
	if not selection then return end -- empty table
	
	-- Look in the profile table to find the matching entry
	for k, n in pairs(t) do
		if IsOn(n) and (n.name == selection) then
			t[k] = Off -- remove the table entry by setting it to Off so that it will not come back when reload profile
			conditions.profiles[id] = nil -- will be set on next call to GetNameList, if table not empty
			return
		end
	end
end

-- Generic function to return index into the sorted name list of current selection
local function GetNameSelection(id, t)
	-- Get the cached list of names and the selected name
	local list = GetNameList(id, t)
	local selection = conditions.profiles[id]
	if not selection then return nil end -- empty table
	
	-- Look in the cached list to find the index of the selection
	for pos, n in pairs(list) do
		if n == selection then return pos end
	end
	return nil -- should never get here, just in case return nil
end

-- Generic function to set the selection in a name list
local function SetNameSelection(id, t, value)
	local list = GetNameList(id, t)
	if value > 0 and value <= table.maxn(list) then
		conditions.profiles[id] = list[value]
	else
		conditions.profiles[id] = nil
	end
end

-- Generic function to return table position (nil if empty table) and pointer to the currently selection in the profile table
local function GetNameEntry(id, t)
	-- Get the cached list of names and the selected name
	local list = GetNameList(id, t)
	local selection = conditions.profiles[id]
	if not selection then return nil end -- empty table
	
	-- Look in the profile table to find the matching entry
	for _, n in pairs(t) do
		if IsOn(n) then
			if n.name == selection then return n end
		end
	end
	return nil -- should never get here, just in case return nil
end

-- Functions for accessing bar group lists
local function GetBarGroupList() return GetNameList("BarGroups", MOD.db.profile.BarGroups) end
local function GetBarGroupEntry() return GetNameEntry("BarGroups", MOD.db.profile.BarGroups) end
local function GetSelectedBarGroup() return GetNameSelection("BarGroups", MOD.db.profile.BarGroups) end
local function SetSelectedBarGroup(value) SetNameSelection("BarGroups", MOD.db.profile.BarGroups, value) end
local function NoBarGroup() return bars.enter or (GetSelectedBarGroup() == nil) end

-- Create new bar group in either bar or icon configuration style
local function CreateBarGroup(name, auto, link, style, offsetX, offsetY)
	local bp = {}
	for n, k in pairs(MOD.db.global.Defaults) do bp[n] = k end -- current default settings for layouts fonts textures
	for n, k in pairs(MOD.BarGroupTemplate) do bp[n] = k end -- add settings in the template
	bp.name = name
	bp.configuration = style and 1 or (Nest_MaxBarConfiguration + 1)
	bp.growDirection = style
	bp.auto = auto
	bp.linkSettings = link
	bp.locked = false
	bp.bars = {}

	AddNameEntry("BarGroups", MOD.db.profile.BarGroups, bp)
	MOD:InitializeBarGroup(bp, offsetX, offsetY)
	MOD:UpdateAllBarGroups()
	return bp
end

local function DeleteBarGroup()
	local bg = GetBarGroupEntry()
	local oldName = bg.name
	MOD:ReleaseBarGroup(bg)
	DeleteNameEntry("BarGroups", MOD.db.profile.BarGroups)
	for _, bp in pairs(MOD.db.profile.BarGroups) do if IsOn(bp) and (bp.anchor == oldName) then bp.anchor = false end end
	MOD:UpdateAllBarGroups()
end

-- Rename involves deleting current bar group and then adding it back renamed
local function RenameBarGroup(newName)
	local bg = GetBarGroupEntry()
	local oldName = bg.name
	MOD:ReleaseBarGroup(bg)
	DeleteNameEntry("BarGroups", MOD.db.profile.BarGroups)
	bg.name = newName
	AddNameEntry("BarGroups", MOD.db.profile.BarGroups, bg)
	MOD:InitializeBarGroup(bg, 0, 0)
	for _, bp in pairs(MOD.db.profile.BarGroups) do if IsOn(bp) and (bp.anchor == oldName) then bp.anchor = newName end end
	MOD:UpdateAllBarGroups()
end

-- Check if any bar groups currently exist...
local function CheckBarGroupsExist()
	local bgs = MOD.db.profile.BarGroups
	for n, bg in pairs(bgs) do
		if IsOn(bg) then
			if standard.PlayerBuffs and (n == L["Buffs"]) then return true end
			if standard.ShortBuffs and (n == L["Short Buffs"]) then return true end
			if standard.LongBuffs and (n == L["Long Buffs"]) then return true end
			if standard.PlayerDebuffs and (n == L["Debuffs"]) then return true end
			if standard.Cooldowns and (n == L["Cooldowns"]) then return true end
			if standard.Target and (n == L["Target"]) then return true end
			if standard.Focus and (n == L["Focus"]) then return true end
			if standard.Totems and (n == L["Totems"]) then return true end
			if standard.Runes and (n == L["Runes"]) then return true end
			if standard.Notifications and (n == L["Notifications"]) then return true end
			if standard.BuffTracker and (n == L["Buff Tracker"]) then return true end
			if standard.DebuffTracker and (n == L["Debuff Tracker"]) then return true end
			if standard.Timeline and (n == L["Timeline"]) then return true end
		end
	end
	return false
end

-- Return the bar group specific suffix for the description
local function BarGroupString(name)
	local suffix = ""
	local bg = MOD.db.profile.BarGroups[name]
	if IsOn(bg) then
		local f, style
		if bg.configuration and (bg.configuration > Nest_MaxBarConfiguration) then style = "Icons" else style = "Bars" end
		if bg.linkSettings then f = "\n|cFF7adbf2Exists (%s), Linked|r" else f = "\n|cFF7adbf2Exists (%s)|r" end
		suffix = string.format(f, style)
	end
	return suffix
end

-- Set link settings for existing and selected standard bar groups
local function LinkStandardBarGroups()
	local bgs = MOD.db.profile.BarGroups
	for n, bg in pairs(bgs) do
		if IsOn(bg) then
			if (standard.PlayerBuffs and (n == L["Buffs"])) or
			(standard.ShortBuffs and (n == L["Short Buffs"])) or (standard.LongBuffs and (n == L["Long Buffs"])) or
			(standard.PlayerDebuffs and (n == L["Debuffs"])) or (standard.Cooldowns and (n == L["Cooldowns"])) or
			(standard.Target and (n == L["Target"])) or (standard.Focus and (n == L["Focus"])) or
			(standard.BuffTracker and (n == L["Buff Tracker"])) or (standard.DebuffTracker and (n == L["Debuff Tracker"])) or
			(standard.Totems and (n == L["Totems"])) or (standard.Runes and (n == L["Runes"])) or (standard.Timeline and (n == L["Timeline"])) or
			(standard.Notifications and (n == L["Notifications"])) then
				bg.linkSettings = not bg.linkSettings
				MOD:InitializeBarGroupSettings(bg)
			end
		end
	end
	MOD:UpdateAllBarGroups()
end

-- Delete existing and selected standard bar groups
local function DeleteStandardBarGroups()
	local bgs = MOD.db.profile.BarGroups
	for n, bg in pairs(bgs) do
		if IsOn(bg) then
			if (standard.PlayerBuffs and (n == L["Buffs"])) or
			(standard.ShortBuffs and (n == L["Short Buffs"])) or (standard.LongBuffs and (n == L["Long Buffs"])) or
			(standard.PlayerDebuffs and (n == L["Debuffs"])) or (standard.Cooldowns and (n == L["Cooldowns"])) or
			(standard.Target and (n == L["Target"])) or (standard.Focus and (n == L["Focus"])) or
			(standard.BuffTracker and (n == L["Buff Tracker"])) or (standard.DebuffTracker and (n == L["Debuff Tracker"])) or
			(standard.Totems and (n == L["Totems"])) or (standard.Runes and (n == L["Runes"])) or (standard.Timeline and (n == L["Timeline"])) or
			(standard.Notifications and (n == L["Notifications"])) then
				MOD:ReleaseBarGroup(bg)
				MOD.db.profile.BarGroups[n] = Off
				for _, bp in pairs(MOD.db.profile.BarGroups) do if IsOn(bp) and (bp.anchor == n) then bp.anchor = false end end
			end
		end
	end
	MOD:UpdateAllBarGroups()
end

-- Check if any standard bar groups are selected
local function AnySelectedStandardBarGroups(exists)
	if not exists then return standard.PlayerBuffs or standard.ShortBuffs or standard.LongBuffs or standard.PlayerDebuffs or standard.Cooldowns or
		standard.Target or standard.Focus or standard.Totems or standard.Runes or standard.Notifications or
		standard.BuffTracker or standard.DebuffTracker or standard.Timeline end
	return CheckBarGroupsExist()
end

-- Reset all standard bar group selections
local function ResetSelectedStandardBarGroups()
	standard.PlayerBuffs = false; standard.ShortBuffs = false; standard.LongBuffs = false; standard.PlayerDebuffs = false;
	standard.Cooldowns = false; standard.Target = false; standard.Focus = false; standard.Totems = false; standard.Runes = false
	standard.Notifications = false; standard.BuffTracker = false; standard.DebuffTracker = false; standard.Timeline = false
end

-- Check if a bar group with the name already exists, return a confirmation string if it does, otherwise return false
local function ConfirmNewBarGroup(name)
	local bg = MOD.db.profile.BarGroups[name]
	if IsOn(bg) then return L["Dup bar group string"](name) end -- name already exists
	return false
end

-- Copy layout configuration settings from another bar group
local function CopyBarGroupConfiguration(name)
	local bg = GetBarGroupEntry()
	local abg = MOD.db.profile.BarGroups[name]
	if IsOn(abg) and (bg.name ~= name) then -- make sure not same bar groups
		for n in pairs(MOD.BarGroupLayoutTemplate) do bg[n] = abg[n] end
		MOD:UpdateAllBarGroups()
	end
end

-- Copy fonts and textures from another bar group
local function CopyBarGroupFontsAndTextures(name)
	local bg = GetBarGroupEntry()
	local abg = MOD.db.profile.BarGroups[name]
	if IsOn(abg) and (bg.name ~= name) then -- make sure not same bar groups
		MOD:CopyFontsAndTextures(abg, bg)
		MOD:UpdateAllBarGroups()
	end
end

-- Copy standard colors from another bar group
local function CopyBarGroupStandardColors(name)
	local bg = GetBarGroupEntry()
	local abg = MOD.db.profile.BarGroups[name]
	if IsOn(abg) and (bg.name ~= name) then -- make sure not same bar groups
		MOD:CopyStandardColors(abg, bg)
		MOD:UpdateAllBarGroups()
	end
end

-- Functions for accessing bars, special case since the group tree function to list bars
local function GetBarEntryWithLabel(bname)
	local bg = GetBarGroupEntry()
	if not bg then return nil end

	for k, n in pairs(bg.bars) do if n.barLabel == bname then return n, k end end
	return nil
end

local function GetBarEntry(info)
	local barlist = MOD.OptionsTable.args.BarGroups.args.BarTab.args
	local bname = barlist[info[#info-2]].name
	return GetBarEntryWithLabel(bname)
end

-- Return true if there is no bar (or we are in the middle of creating a new bar)
local function NoBar()
	local bg = GetBarGroupEntry()
	if not bg or InMode("Bar") then return true end
	return next(bg.bars) == nil
end

-- Functions for sorting bar lists
local function SortAlphaUp(a, b) return string.upper(a) < string.upper(b) end
local function SortCustomOrder(a, b) return GetBarEntryWithLabel(a).sorder < GetBarEntryWithLabel(b).sorder end

-- Populate the options table for all the bars in the currently selected bar group
local function UpdateBarList()
	local bg = GetBarGroupEntry()
	if not bg then return end

	local barlist = MOD.OptionsTable.args.BarGroups.args.BarTab.args
	for j in pairs(barlist) do -- first remove any old entries
		if string.find(j, "XXX") then barlist[j] = nil end
	end
	if bg.auto then return end -- no bars if auto bar group
	
	local i, bp = 0, {} -- build a list of bar names from the profile table
	for _, n in pairs(bg.bars) do
		i = i + 1
		bp[i] = n.barLabel
	end

	if bg.sor ~= "X" then table.sort(bp, SortAlphaUp) else table.sort(bp, SortCustomOrder) end -- sort names by appropriate sorting algorithm
	
	for k, bname in pairs(bp) do -- now populate the groups in the tree with bar options
		barlist["XXX"..k] = {
			type = "group", order = k + 10, name = bname,
			disabled = function(info) return InMode("Bar") end,
			args = MOD.barOptions,
		}
		local bar = GetBarEntryWithLabel(bname)
		bar.sorder = k -- normalizes the sorder values to ascending integers
	end
	
	local key = "EnterNewBar"
	if bars.mode then -- support entering new bar into the current bar group
		barlist[key] = { type = "group", order = 10, name = "-- New Bar --", args = MOD.barOptions }
		acedia:SelectGroup("Raven", "BarGroups", "BarTab", key)
	else
		barlist[key] = nil
	end
end

-- Select a particular bar
local function SelectBar(label)
	local barlist = MOD.OptionsTable.args.BarGroups.args.BarTab.args
	for k, b in pairs(barlist) do
		if string.find(k, "XXX") then -- only check special keys for bars
			if b.name == label then
				acedia:SelectGroup("Raven", "BarGroups", "BarTab", k)
				return
			end
		end
	end
end

-- Delete the current bar
local function DeleteBar()
	local bg = GetBarGroupEntry()
	if not bg then return end
	
	local statustable = acedia:GetStatusTable("Raven", { "BarGroups", "BarTab" })
	local selected = statustable.groups.selected

	if string.find(selected, "XXX") then -- only check special keys for bars
		local barlist = MOD.OptionsTable.args.BarGroups.args.BarTab.args
		local bname = barlist[selected].name
		local bar, key = GetBarEntryWithLabel(bname)
		if bar then -- remove the table entry, essential since recycling would require reset of special values
			bg.bars[key] = nil
			UpdateBarList()
		end
	end
	MOD:UpdateAllBarGroups()
end

-- Default bar information tables
local barSources = { "Death Knight", "Druid", "Hunter", "Mage", "Paladin", "Priest", "Rogue", "Shaman", "Warlock", "Warrior", "Monk", "Racial", "Spell" }
local classIndex = { DEATHKNIGHT = 1, DRUID = 2, HUNTER = 3, MAGE = 4, PALADIN = 5, PRIEST = 6, ROGUE = 7, SHAMAN = 8, WARLOCK = 9, WARRIOR = 10, MONK = 11 }
local classList = { "DEATHKNIGHT", "DRUID", "HUNTER", "MAGE", "PALADIN", "PRIEST", "ROGUE", "SHAMAN", "WARLOCK", "WARRIOR", "MONK" }
local petClassList = { true, false, true, false, false, false, false, false, true, false, false }
local unitList = { player = "Player", pet = "Pet", target = "Target", focus = "Focus",
	mouseover = "Mouseover", pettarget = "Pet's Target", targettarget = "Target's Target", focustarget = "Focus's Target" }
local castList = { player = "Player", pet = "Pet", other = "Other", anyone = "Anyone" }
local lastdatecheck = ""
local lastdatecount = 0

-- Add a new bar to a bar group, initializing the sort order value and adding a unique identifier
-- Verify that the bar is not a duplicate of one already in the bar group before adding
local function AddBarToGroup(bg, bar)
	for k, n in pairs(bg.bars) do -- scan current bars and see if this bar is a duplicate, only tricky part is the castBy setting
		local ok = true
		if (bar.action == n.action) and (bar.barType == n.barType) and (bar.monitor == n.monitor) then
			if bar.castBy == n.castBy then return false end -- everything matches so is a duplicate for sure
			if n.castBy == "anyone" then return false end -- if already have everything then duplicate
			if bar.castBy == "anyone" then bg.bars[k] = nil; ok = false end -- more inclusive that the original so need to delete the original
		end
		if ok and (bar.barLabel == n.barLabel) then -- found duplicate label, add a suffix 
			bar.barLabel = bar.barLabel .. "*"
			bar.labelLink = true -- make sure not linked (true means not linked)
		end
	end
	
	bar.sorder = 0
	local d = date("%m%d%y-%H%M%S-")
	if d == lastdatecheck then
		lastdatecount = lastdatecount + 1
	else
		lastdatecheck = d
		lastdatecount = 0
	end
	
	bar.uniqueID = d .. lastdatecount
	table.insert(bg.bars, bar)
	MOD:UpdateAllBarGroups()
	return true
end

-- Process entering a new bar, state = "start", "ok", "cancel" to move between stages of bar entry
local function EnterNewBar(state)
	local bg = GetBarGroupEntry()
	if not bg then return end

	if state == "start" then
		bars.mode = true
		if bars.save then -- cache of previous settings
			bars.template = { -- only preserve selected fields from saved bar description
				barType = bars.save.barType, barSource = bars.save.barSource, barClass = bars.save.barClass, barLabel = "",
				monitor = bars.save.monitor, castBy = bars.save.castBy
			}
			bars.save = nil
		else
			bars.template = { -- set defaults
				barType = "Notification", barSource = "Class", barClass = classIndex[MOD.myClass],
				barLabel = "", monitor = "player", castBy = "player"
			}
		end
		if not bars.template.monitor then bars.template.monitor = "player" else bars.template.monitor = string.lower(bars.template.monitor) end
		if not bars.template.castBy then bars.template.castBy = "player" else bars.template.castBy = string.lower(bars.template.castBy) end
	elseif state == "ok" then
		bars.mode = false		
		local source = barSources[bars.template.barClass]
		if bars.template.barSource == "Pet" then source = "Pet" end
		if (bars.template.barType ~= "Notification") and (bars.template.barSource == "Other") and ValidateSpellName(conditions.name) then
			if not bars.template.actionList then bars.template.actionList = {} end
			if not bars.template.selectList then bars.template.selectList = {} end
			bars.template.actionList[1] = conditions.name
			bars.template.selectList[1] = true
		end
		local sel = nil
		if (bars.template.barType == "Buff") or (bars.template.barType == "Debuff") then -- buff or debuff
			if bars.template.actionList then
				for k, n in pairs(bars.template.selectList) do
					if n then
						local bname = bars.template.actionList[k]
						local label = MOD:GetLabel(bname)
						local bar = {
							action = bname, enableBar = true, barLabel = label, barType = bars.template.barType,
							barSource = source, monitor = bars.template.monitor, castBy = bars.template.castBy
						}
						if AddBarToGroup(bg, bar) then if not sel then sel = bar.barLabel end end
					end
				end
			end
		elseif bars.template.barType == "Cooldown" then -- cooldown
			if bars.template.actionList then
				for k, n in pairs(bars.template.selectList) do
					if n then
						local bname = bars.template.actionList[k]
						local label = MOD:GetLabel(bname)
						local bar = {
							action = bname, enableBar = true, barLabel = label, barType = bars.template.barType,
							barSource = source, monitor = nil, castBy = nil, enableReady = nil, readyNotUsable = nil
						}
						if AddBarToGroup(bg, bar) then if not sel then sel = bar.barLabel end end
					end
				end
			end
		elseif bars.template.barType == "Notification" then -- notification
			if bars.template.conditionList and bars.template.selectCondition then
				for k, n in pairs(bars.template.selectCondition) do
					if n then
						local bname = bars.template.conditionList[k]
						local bar = {
							action = bname, enableBar = true, barLabel = bname, barType = bars.template.barType,
							barSource = nil, monitor = nil, castBy = nil
						}
						if AddBarToGroup(bg, bar) then if not sel then sel = bar.barLabel end end
					end
				end
			end
		end
		if sel then UpdateBarList(); SelectBar(sel) end
		bars.save = bars.template
		bars.template = nil
	elseif state == "cancel" then
		bars.mode = false
		bars.save = bars.template
		bars.template = nil
	end
end

-- Get a formatted text description of the current bar
local function GetBarDescription(info)
	local a = ""
	local n = GetBarEntry(info)
	if n then
		if n.barType == "Notification" then
			a = L["Type and condition string"](n.barType, n.action)
			local spell = MOD:GetAssociatedSpellForBar(n)
			if spell then a = a .. L["Associated spell string"](spell) end
		elseif n.barType == "Buff" or n.barType == "Debuff" or n.barType == "Cooldown" then
			if n.action then
				a = L["Action type source string"](n.action, n.barType, n.barSource)
			else
				a = L["Type source string"](n.barType, n.barSource)
			end
			if n.barType ~= "Cooldown" then
				if not n.monitor then n.monitor = "player" else n.monitor = string.lower(n.monitor) end
				if not n.castBy then n.castBy = "player" else n.castBy = string.lower(n.castBy) end
				local unit, cb = unitList[n.monitor], castList[n.castBy]
				if unit and cb then a = a .. L["Action on cast by string"](unit, cb) end
			end
		end
	end
	return a
end

-- Move a bar up or down in the list
local function MoveBarInList(info, direction)
	local bar = GetBarEntry(info)
	if bar then
		if direction == "up" then bar.sorder = bar.sorder - 1.5 else bar.sorder = bar.sorder + 1.5 end
		UpdateBarList()
		SelectBar(bar.barLabel)
	end
end

-- Return a list for selection of configuration of either bar or icon oriented bar groups
local function GetOrientationList(iconOnly)
	if iconOnly == nil then iconOnly = false end
	bars.config = {}
	for i, config in pairs(Nest_SupportedConfigurations) do if config.iconOnly == iconOnly then bars.config[i] = config.name end end
	return bars.config
end

-- Set a field in the current bar
local function SetBarField(info, fname, value)
	local n = GetBarEntry(info)
	if n then
		n[fname] = value
	end
end

-- Get a field in the current bar
local function GetBarField(info, fname)
	local n = GetBarEntry(info)
	if n then return n[fname] end
	return nil
end

-- Get the icon associated with the current bar
local function GetBarIcon(info)
	local b = GetBarEntry(info)
	return MOD:GetIconForBar(b)
end

-- Check for duplicate labels, including "other labels"
local function IsDuplicateLabel(bg, newLabel)
	for _, n in pairs(bg.bars) do if n.barLabel == newLabel then return true end end
	return false
end

-- Change a bar's label, have to redo the list afterwards, also do some validation and return false if not valid
local function SetBarLabel(info, newLabel, isLinked)
	local bg = GetBarGroupEntry()
	if not bg then return false end
	
	local bar = GetBarEntry(info)
	if not bar then return false end
	
	if bar.barLabel == newLabel then return true end  -- make sure new label is actually a change
	if newLabel == "" then return false end -- make sure not an empty string
	
	if IsDuplicateLabel(bg, newLabel) then -- make sure not a duplicate within this bar group
		print('"' .. newLabel .. '" ' .. L["is a duplicate of an existing bar label"])
		return false
	end

	local a, b = string.find(newLabel, "^%a[%a%d%b()%[%] %-%+%!%*_':]*") -- make sure new label has correct format and doesn't contain bad characters
	if a ~= 1 and b ~= string.len(newLabel) then
		print('"' .. newLabel .. '" ' .. L["does not begin with a letter or contains restricted characters"])
		return false
	end 

	DeleteBar()
	if isLinked and ((bar.barType == "Buff") or (bar.barType == "Debuff") or (bar.barType == "Cooldown")) then MOD:SetLabel(bar.action, newLabel) end
	bar.barLabel = newLabel
	table.insert(bg.bars, bar)
	UpdateBarList()
	SelectBar(newLabel)
	return true
end

-- Generate a list of auras that meet the criteria of type and source specified in the bars.template table
local function GenerateBarActionList()
	local i = 0
	bars.template.actionList = {}
	bars.template.selectList = {}
	conditions.name = nil -- for entered spell names

	local btype = bars.template.barType
	local c = classList[bars.template.barClass]
	if (btype == "Buff") or (btype == "Debuff") or (btype == "Cooldown") then
		local btable = MOD[btype .. "Table"]
		if bars.template.barSource == "Class" then
			for name, action in pairs(btable) do
				if (action.class == c) and not action.pet then i = i + 1; bars.template.actionList[i] = name; end
			end
		elseif bars.template.barSource == "Pet" then -- racial buffs
			for name, action in pairs(btable) do
				if (action.class == c) and action.pet then i = i + 1; bars.template.actionList[i] = name; end
			end
		elseif bars.template.barSource == "Racial" then -- racial buffs
			for name, action in pairs(btable) do
				if action.race then i = i + 1; bars.template.actionList[i] = name; end
			end
		end
	end

	table.sort(bars.template.actionList) -- alphabetical order to improve readability
	for k in pairs(bars.template.actionList) do bars.template.selectList[k] = false end -- default to all not selected
	bars.template.actionListCount = i
end

-- Functions for accessing bar type lists
local function SetSelectedBarType(value)
	if bars.template.barType ~= value then
		bars.template.barType = value
		GenerateBarActionList()
	end
end

-- Functions for accessing bar source lists
local function SetSelectedBarSource(value)
	if bars.template.barSource ~= value then 
		bars.template.barSource = value
		if (value == "Pet") and not petClassList[bars.template.barClass] then bars.template.barClass = 3 end
		GenerateBarActionList()
	end
end

-- Functions for accessing bar class lists
local function SetSelectedBarClass(value)
	if bars.template.barClass ~= value then 
		bars.template.barClass = value
		GenerateBarActionList()
	end
end

-- Generate a list of conditions to select from
local function GetSelectConditionList()
	local i, t = 0, {}
	for _, n in pairs(MOD.db.profile.Conditions[MOD.myClass]) do
		if IsOn(n) and n.name then
			i = i + 1
			t[i] = n.name
		end
	end
	table.sort(t)
	return t, i
end

-- Get the, potentially cached, list of conditions to select from
local function GetBarConditionList()
	if not bars.template.conditionList then
		bars.template.conditionList, bars.template.conditionListCount = GetSelectConditionList()
		bars.template.selectCondition = {}
		for k in pairs(bars.template.conditionList) do bars.template.selectCondition[k] = false end -- default to all not selected
	end
	return bars.template.conditionList
end

local function GetBarConditionListCount() GetBarConditionList(); return bars.template.conditionListCount end
local function GetSelectedBarCondition(key) return bars.template.selectCondition[key] end
local function SetSelectedBarCondition(key, value) bars.template.selectCondition[key] = value end
local function SetAllBarConditions(value) for k in pairs(bars.template.conditionList) do bars.template.selectCondition[k] = value end end

-- Generate a list of auras that meet the criteria of type and source specified in the bars.template table
local function GetBarActionList() if not bars.template.actionList then GenerateBarActionList() end; return bars.template.actionList end
local function GetBarActionListCount() if not bars.template.actionList then GenerateBarActionList() end; return bars.template.actionListCount end
local function GetSelectedBarAction(key) return bars.template.selectList[key] end
local function SetSelectedBarAction(key, value) bars.template.selectList[key] = value end
local function SetAllBarActions(value) for k in pairs(bars.template.actionList) do bars.template.selectList[k] = value end end

-- Functions for accessing condition lists
local function GetConditionList() return GetNameList("Conditions", MOD.db.profile.Conditions[MOD.myClass]) end
local function GetCondition() return GetNameEntry("Conditions", MOD.db.profile.Conditions[MOD.myClass]) end
local function GetSelectedCondition() return GetNameSelection("Conditions", MOD.db.profile.Conditions[MOD.myClass]) end
local function SetSelectedCondition(value) SetNameSelection("Conditions", MOD.db.profile.Conditions[MOD.myClass], value) end
local function DeleteCondition() DeleteNameEntry("Conditions", MOD.db.profile.Conditions[MOD.myClass]) end
local function NoCondition() return conditions.enter or (GetSelectedCondition() == nil) end

local function CreateCondition(name)
	local n = { enabled = true, name = name, notify = true, tooltip = true, tests = {}, testResult = false, dependencies = {}, result = false }
	AddNameEntry("Conditions", MOD.db.profile.Conditions[MOD.myClass], n)
end

-- Check if a condition with the name already exists, return a confirmation string if it does, otherwise return false
local function ConfirmNewCondition(name)
	local cs = MOD.db.profile.Conditions[MOD.myClass]
	local c = cs[name]
	if IsOn(c) and c.name then return L["Dup condition string"](name) end -- name already exists
	return false
end

-- Purge an existing condition, have to delete from bar groups, notifications, dependencies
local function PurgeCondition()
	local con = GetCondition()
	local oldName = con.name
	for _, bp in pairs(MOD.db.profile.BarGroups) do -- check bar group conditions
		if IsOn(bp) then
			if bp.checkCondition and (bp.condition == oldName) then bp.condition = nil; bp.checkCondition = false end
			for _, bar in pairs(bp.bars) do -- check for notifications
				if (bar.barType == "Notification") and (bar.action == oldName) then bar.enableBar = false end
			end
		end
	end
	for _, c in pairs(MOD.db.profile.Conditions[MOD.myClass]) do -- check dependencies
		if IsOn(c) and c.name and c.dependencies then
			local result = c.dependencies[oldName]
			if result ~= nil then
				c.dependencies[oldName] = nil
			end
		end
	end
end

-- Rename an existing condition, have to change for bar groups, bars, dependencies
local function RenameCondition(newName)
	local con = GetCondition()
	local oldName = con.name
	DeleteNameEntry("Conditions", MOD.db.profile.Conditions[MOD.myClass])
	con.name = newName
	AddNameEntry("Conditions", MOD.db.profile.Conditions[MOD.myClass], con)
	for _, bp in pairs(MOD.db.profile.BarGroups) do -- check bar group and bar conditions
		if IsOn(bp) then
			if bp.checkCondition and (bp.condition == oldName) then bp.condition = newName end
			if not bp.auto then -- have to scan bars in custom bar groups
				for _, bar in pairs(bp.bars) do
					if (bar.barType == "Notification") and (bar.action == oldName) then bar.action = newName end
					if bar.hideCondition == oldName then bar.hideCondition = newName end
					if bar.flashCondition == oldName then bar.flashCondition = newName end
					if bar.fadeCondition == oldName then bar.fadeCondition = newName end
				end
			end
		end
	end
	for _, c in pairs(MOD.db.profile.Conditions[MOD.myClass]) do -- check dependencies
		if IsOn(c) and c.name and c.dependencies then
			local result = c.dependencies[oldName]
			if result ~= nil then
				c.dependencies[oldName] = nil
				c.dependencies[newName] = result
			end
		end
	end
end

-- Return the selected condition associated with a bar group
local function GetBarGroupSelectedCondition(list)
	local bp = GetBarGroupEntry()
	if bp and bp.checkCondition and bp.condition then
		for j, c in pairs(list) do
			if c == bp.condition then return j end
		end
	end
	return nil
end

-- Return the index of the condition in the list
local function GetBarSelectedCondition(list, condition)
	for j, c in pairs(list) do
		if c == condition then return j end
	end
	return nil
end

-- Get a list of dependencies to select from
local function GetDependenciesList()
	local con = GetCondition()
	local i, t = 0, {}
	local nt = MOD.db.profile.Conditions[MOD.myClass]
	for _, n in pairs(nt) do
		if IsOn(n) and n.name and (n.name ~= con.name) then
			i = i + 1
			t[i] = n.name
		end
	end
	table.sort(t)
	return t
end

-- Set a dependency with the specified value in the current condition's dependencies list
local function SetDependency(dep, value)
	local con = GetCondition()
	if not con.dependencies then con.dependencies = {} end
	con.dependencies[dep] = value
end

-- Get a dependency type
local function GetDependencyType(dep)
	local con = GetCondition()
	if con.dependencyType then return con.dependencyType[dep] end
	return nil
end

-- Set a dependency type with the specified value
local function SetDependencyType(dep, value)
	local con = GetCondition()
	if not con.dependencyType then con.dependencyType = {} end
	con.dependencyType[dep] = value
end

-- Check if the dependency is included in the current condition's dependencies list
local function CheckDependency(dep)
	local con = GetCondition()
	if con.dependencies then
		for d in pairs(con.dependencies) do
			if dep == d then return true end
		end
	end
	return false
end

-- Return the selected dependency, clear it when switching conditions
local function GetSelectedDependency()
	local con = GetCondition()
	if con ~= conditions.select then
		conditions.select = con
		conditions.dependency = nil
	end
	return conditions.dependency
end

-- Set a field in the current bar group
local function SetBarGroupField(fname, value)
	local n = GetBarGroupEntry()
	if n then
		n[fname] = value
		if fname == "linkSettings" then MOD:InitializeBarGroupSettings(n) end -- special case for linked layouts
		if (fname == "pointX") or (fname == "pointY") then MOD:SetBarGroupPosition(n) end -- special case for display position
		if fname == "filterBuffLink" then MOD:InitializeFilterList(n, "Buff") end -- special case for linked buff filters
		if fname == "filterDebuffLink" then MOD:InitializeFilterList(n, "Debuff") end -- special case for linked debuff filters
		if fname == "filterCooldownLink" then MOD:InitializeFilterList(n, "Cooldown") end -- special case for linked cooldown filters
		MOD:UpdateAllBarGroups() -- any field changes need to be reflected in the actual bars on the display
	end
end

-- Get a field in the current bar group
local function GetBarGroupField(fname)
	local n = GetBarGroupEntry()
	if n then return n[fname] end
	return nil
end

-- Return the current merge bar group for the selected bar group
local function GetMergeBarGroup()
	local bg = GetBarGroupEntry()
	if bg then
		local bglist = GetBarGroupList()
		for i, bgname in pairs(bglist) do if bgname == bg.mergeInto then return i end end
	end
	return nil
end

-- Set the merge bar group for the selected bar group
local function SetMergeBarGroup(value)
	local bg = GetBarGroupEntry()
	if bg then
		local bglist = GetBarGroupList()
		local mergeInto = bglist[value]
		local mbg = MOD.db.profile.BarGroups[mergeInto]
		if IsOn(mbg) and mbg.enabled and not mbg.merged then
			bg.mergeInto = mergeInto		
			MOD:UpdateAllBarGroups() -- any changes need to be reflected in the actual bars on the display
		end
	end
end

-- Return the current anchor bar group for the selected bar group
local function GetBarGroupAnchor()
	local bg = GetBarGroupEntry()
	if bg then
		local anchor = bg.name
		if bg.anchor and (bg.anchor ~= bg.name) then anchor = bg.anchor end
		local bglist = GetBarGroupList()
		for i, bgname in pairs(bglist) do if bgname == anchor then return i end end
	end
	return nil
end

-- Set the current anchor bar group for the selected bar group
local function SetBarGroupAnchor(value)
	local bg = GetBarGroupEntry()
	if bg then
		if not value then
			bg.anchor = false; bg.anchorX = 0; bg.anchorY = 0; bg.anchorFrame = nil; bg.anchorPoint = nil; bg.anchorLastBar = false; bg.anchorEmpty = false
			MOD:UpdatePositions() -- center this bar group and adjust any dependent bar groups
		else
			local bglist = GetBarGroupList()
			local anchor = bglist[value]
			if anchor ~= bg.name then -- need to make sure no loops being set up
				local i, a = 0, anchor
				while i < 100 do -- safety net, should never get this high
					i = i + 1
					local bp = MOD.db.profile.BarGroups[a]
					if not bp.anchor then break end -- found end of chain without looping back
					a = bp.anchor
					if a == bg.name then -- found a loop so print a warning and return
						print(L["Circular string"](a, anchor))
						return
					end
				end
				bg.anchor = anchor
			else bg.anchor = false end
		end
		MOD:UpdateAllBarGroups() -- any changes need to be reflected in the actual bars on the display
	end
end

-- Return the filter list of a given type for a bar group
local function GetBarGroupFilter(actionType)
	local n = GetBarGroupEntry()
	if n then
		local listName, selectName = "filter" .. actionType .. "List", "filter" .. actionType .. "Selection"
		local filterList = n[listName]
		if filterList then 
			table.sort(filterList)
			if not n[selectName] then n[selectName] = next(filterList, nil) end
			return filterList
		end
		n[selectName] = nil
	end
	return {}
end

-- Return selection within the filter list of a given type for a bar group
local function GetBarGroupFilterSelection(actionType)
	local n = GetBarGroupEntry()
	if n then
		local listName, selectName = "filter" .. actionType .. "List", "filter" .. actionType .. "Selection"
		local filterList = n[listName]
		local filterSelect = n[selectName]
		if filterList then 
			table.sort(filterList)
			if not filterSelect or not filterList[filterSelect] then n[selectName] = next(filterList, nil) end
			return n[selectName]
		end
	end
	return nil
end

-- Reset the filter list of a given type for a bar group
local function ResetBarGroupFilter(actionType)
	local n = GetBarGroupEntry()
	if n then
		local listName, selectName = "filter" .. actionType .. "List", "filter" .. actionType .. "Selection"
		n[listName] = nil
		n[selectName] = nil
	end
end

-- Add an action to be filtered by a bar group
local function AddBarGroupFilter(actionType, actionName)
	local n = GetBarGroupEntry()
	if n and actionName and actionName ~= "" then
		local listName, selectName = "filter" .. actionType .. "List", "filter" .. actionType .. "Selection"
		local filterList = n[listName]
		if not filterList then filterList = {}; n[listName] = filterList end
		filterList[actionName] = actionName
		n[selectName] = actionName
		MOD:UpdateAllBarGroups() -- any field changes need to be reflected in the actual bars on the display
	end
end

-- Delete an action from a bar group filter list
local function DeleteBarGroupFilter(actionType, actionName)
	local n = GetBarGroupEntry()
	if n and actionName and actionName ~= "" then
		local listName, selectName = "filter" .. actionType .. "List", "filter" .. actionType .. "Selection"
		local filterList = n[listName]
		if filterList then
			filterList[actionName] = nil
			n[selectName] = nil
		end
		MOD:UpdateAllBarGroups() -- any field changes need to be reflected in the actual bars on the display
	end
end

-- Return nearest power of two greater than or equal to a number between 4 and 128
local twosTable = { 4, 8, 16, 32, 64, 128 }
local function NextPowerOfTwo(i) local p = 4; for _, t in pairs(twosTable) do if i == t then return t elseif i < t then return p else p = t end end end

-- Set a field in the current notification
local function SetConditionField(fname, value)
	local n = GetCondition()
	if n then n[fname] = value end
	MOD:UpdateAllBarGroups() -- any field changes need to be reflected in the actual bars on the display
end

-- Get a field in the current notification
local function GetConditionField(fname)
	local n = GetCondition()
	if n then return n[fname] end
	return nil
end

-- Return a text description of the current condition
local function GetConditionDescription()
	local c = GetCondition()
	if c then return MOD:GetConditionText(c.name) end
	return ""
end

-- Copy test settings from a shared condition
local function CopyConditionSettings(name)
	local s = MOD.db.global.SharedConditions[name]
	local d = GetCondition()
	d.tests = Raven_CopyTable(s.tests)
	d.dependencies = Raven_CopyTable(s.dependencies)
	d.associatedSpell = s.associatedSpell
end

-- Return a sorted list of shared conditions
local function GetSharedConditionList() return GetSortedList(MOD.db.global.SharedConditions) end
							
-- Get current setting for a test field in the currently selected condition
local function GetTestField(ttype, fname)
	local c = GetCondition()
	if c and c.tests then
		local t = c.tests[ttype] -- find the right test, if it exists
		if t then return t[fname] end -- found the field
	end
	return nil
end

-- Set value of a test field in the current condition, initializing fields as necessary
local function SetTestField(ttype, fname, value)
	local c = GetCondition()
	if c then
		if not c.tests then
			c.tests = {}
		else
			local t = c.tests[ttype] -- find the right test, if it has already been defined
			if t then -- found the field
				t[fname] = value
				MOD:UpdateAllBarGroups()
				return
			end
		end
		local newTest = {}
		for f, v in pairs(MOD.conditionTests[ttype]) do newTest[f] = v end -- initialize test parameters
		newTest[fname] = value -- after initializing the test can set the field
		c.tests[ttype] = newTest
		MOD:UpdateAllBarGroups()
	end
end

-- Check if an option field in the current test is turned on
local function IsTestFieldOn(ttype, fname)
	local value = GetTestField(ttype, fname)
	return (value ~= nil) and (value ~= Off)
end

-- Check if an option field in the current test is turned off
local function IsTestFieldOff(ttype, fname)
	local value = GetTestField(ttype, fname)
	return value == nil or value == Off
end

-- Set a field associated with a test, strip off white space at start and end of the string
local function SetTestFieldString(ttype, fname, s)
	local whiteStart, whiteEnd = string.find(s, "%s*", 1) -- skip white space
	if whiteStart == 1 then s = string.sub(s, whiteEnd + 1) end	
	s = string.reverse(s) -- reverse so can check for end white space
	whiteStart, whiteEnd = string.find(s, "%s*", 1) -- skip white space
	if whiteStart == 1 then s = string.sub(s, whiteEnd + 1) end
	local str = string.reverse(s) -- get the string after white space, reverse again to restore original order
	if str ~= "" then -- make sure not empty string
		if fname ~= "item" and fname ~= "spec" and fname ~= "glyph" and fname ~= "stance" and fname ~= "family" and fname ~= "maxHealth" then str = ValidateSpellName(str) end
		SetTestField(ttype, fname, str)
	else
		SetTestField(ttype, fname, nil)
	end
end

-- Get a comma-separated list of the comma-seperated strings associated with a test
local function GetTestFieldSpellList(ttype, fname)
	local a, d = "", ""
	local strs = GetTestField(ttype, fname)
	if strs then
		for _, str in pairs(strs) do
			a = a .. d .. str -- append each to the comma-seperated string being built
			d = ", "
		end
	end
	return a
end

-- Set the auras associated with a test from a string with comma-separated names
local function SetTestFieldSpellList(ttype, fname, st)
	local start, strlist, s = 1, {}, st .. ',' -- initialize array, add ending comma
	repeat
		local whiteStart, whiteEnd = string.find(s, "%s*", start) -- skip white space
		if whiteStart == start then start = whiteEnd + 1 end
		if start > string.len(s) then break end
		local comma, nexts = string.find(s, '%s*,', start) -- find next comma, skipping white space preceding it
		if (comma - start) > 1 then -- make sure there is a string left after stripping white space
			table.insert(strlist, string.sub(s, start, comma - 1)) -- store the string in the table of aura names
		end
		start = nexts + 1
	until start > string.len(s)
	for n, k in pairs(strlist) do strlist[n] = ValidateSpellName(k) end -- validates spell names
	SetTestField(ttype, fname, strlist)
end

-- Check if a classification list includes the specified value
local function IsClassification(fname, cs) return (string.find(GetTestField(fname, "classification") or "", cs) ~= nil) end

-- Add or remove a string to a classification list, separated by spaces due to "rareelite" conflict with "rare" and "elite"
local function SetClassification(fname, cs, v)
	local cl = GetTestField(fname, "classification") or ""
	if v and not string.find(cl, cs) then if cl == "" then cl = cs else cl = cl .. " " .. cs end end
	if not v and string.find(cl, cs) then cl = string.gsub(cl, cs, "") end
	cl = string.gsub(cl, "  ", " "); cl = string.gsub(cl, "^ ", ""); cl = string.gsub(cl, " $", "") -- strip extra spaces
	SetTestField(fname, "classification", cl)
end

-- Get a list of internal cooldowns from the profile
local function GetInternalCooldownList() return GetSortedList(MOD.db.global.InternalCooldowns) end

local function SetSelectedInternalCooldown(index)
	if index then
		local t = GetInternalCooldownList(); cooldowns.select = t[index]
		local ict = MOD.db.global.InternalCooldowns[cooldowns.select]
		cooldowns.disable = ict.disable; cooldowns.duration = ict.duration; cooldowns.cancel = ict.cancel; cooldowns.caster = ict.caster
	else
		cooldowns.disable = nil; cooldowns.duration = nil; cooldowns.cancel = nil; cooldowns.caster = nil; cooldowns.select = nil
	end
end

local function GetSelectedInternalCooldown()
	local t = GetInternalCooldownList()
	if not cooldowns.select and next(t) then SetSelectedInternalCooldown(1) end -- default to first in list
	if cooldowns.select then for k, v in pairs(t) do if v == cooldowns.select then return k end end end
	cooldowns.select = nil
	return nil
end

local function AddNewInternalCooldown(name)
	local id = tonumber(name)
	if not id then id = MOD:GetSpellID(name) end
	if id then
		local n, _, icon = GetSpellInfo(id)
		local ict = MOD.db.global.InternalCooldowns[n]
		if not ict then
			ict = { duration = 0; id = id; icon = icon }
			MOD.db.global.InternalCooldowns[n] = ict
		end
		cooldowns.disable = ict.disable; cooldowns.duration = ict.duration; cooldowns.cancel = ict.cancel; cooldowns.caster = ict.caster; cooldowns.select = n
	else
		cooldowns.disable = nil; cooldowns.duration = nil; cooldowns.cancel = nil; cooldowns.caster = nil; cooldowns.select = nil
	end
end

-- Return a comma-separated string of spells
local function GetListString(spells)
	local a, d = "", ""
	if spells and type(spells) == "table" then for _, str in pairs(spells) do a = a .. d .. str; d = ", " end end
	return a
end

-- Create a table of spells from a string with comma-separated spell names or ids
local function GetListTable(t, listType)
	local start, spells, s = 1, {}, t .. ',' -- initialize array, add ending comma
	repeat
		local whiteStart, whiteEnd = string.find(s, "%s*", start) -- skip white space
		if whiteStart == start then start = whiteEnd + 1 end
		if start > string.len(s) then break end
		local comma, nexts = string.find(s, '%s*,', start) -- find next comma, skipping white space preceding it
		if (comma - start) >= 1 then -- make sure there is a string left after stripping white space
			table.insert(spells, string.sub(s, start, comma - 1)) -- store the string in the table of aura names
		end
		start = nexts + 1
	until start > string.len(s)
	if listType == "spells" then
		for k, v in pairs(spells) do local n = tonumber(v); if n then v = GetSpellInfo(n); spells[k] = v end end -- translate ids
	elseif listType == "strings" then
		for k, v in pairs(spells) do spells[k] = v end
	end
	if not next(spells) then return nil end -- return nil if the list is empty
	return spells
end

local function SetInternalCooldownSettings()
	if cooldowns.select then
		local ict = MOD.db.global.InternalCooldowns[cooldowns.select]
		if ict then ict.disable = cooldowns.disable and true or nil; ict.duration = tonumber(cooldowns.duration)
			ict.cancel = cooldowns.cancel; ict.caster = cooldowns.caster end
	end
end

local function DeleteInternalCooldown() if cooldowns.select then MOD.db.global.InternalCooldowns[cooldowns.select] = nil end SetSelectedInternalCooldown(nil) end

-- Get spell lists from the profile
local function GetSpellList() return GetSortedList(MOD.db.global.SpellLists) end
local function GetSpellListEntry(n) return GetSortedListEntry(MOD.db.global.SpellLists, n) end

local function SetSelectedSpellList(index)
	if index then
		local t = GetSpellList(); lists.select = t[index]
		lists.list = MOD.db.global.SpellLists[lists.select]
		local s = GetSortedList(lists.list)
		lists.spell = next(s) and s[1] or nil -- default to first in list
	else
		lists.select = nil; lists.list = nil
	end
end

local function GetSelectedSpellList()
	local t = GetSpellList()
	if not lists.select and next(t) then SetSelectedSpellList(1) end -- default to first in list
	if lists.select then for k, v in pairs(t) do if v == lists.select then return k end end end
	lists.select = nil; lists.list = nil
	return nil
end

local function AddNewSpellList(name)
	if name and name ~= "" then
		local slt = MOD.db.global.SpellLists[name]
		if not slt then slt = {}; MOD.db.global.SpellLists[name] = slt end
		lists.select = name; lists.list = slt
	else
		lists.select = nil; lists.list = nil
	end
end

local function SetSpellListSettings()
	if lists.select then
		local slt = MOD.db.global.SpellLists[lists.select]
		if slt then
		end
	end
end

local function DeleteSpellList() if lists.select then MOD.db.global.SpellLists[lists.select] = nil end SetSelectedSpellList(nil) end

-- Get a list of spell effects from the profile
local function GetSpellEffectList() return GetSortedList(MOD.db.global.SpellEffects) end

local function SetSelectedSpellEffect(index)
	if index then
		local t = GetSpellEffectList(); effects.select = t[index]
		local ect = MOD.db.global.SpellEffects[effects.select]
		effects.disable = ect.disable; effects.duration = ect.duration; effects.kind = ect.kind; effects.renew = ect.renew; effects.caster = ect.caster
		effects.spell = ect.spell; effects.talent = ect.talent; effects.buff = ect.buff; effects.condition = ect.condition; effects.label = ect.label
		effects.optbuff = ect.optbuff; effects.optduration = ect.optduration
	else
		effects.disable = nil; effects.duration = nil; effects.spell = nil; effects.kind = nil; effects.renew = nil; effects.caster = nil
		effects.talent = nil; effects.buff = nil; effects.condition = nil; effects.label = nil; effects.select = nil
		effects.optbuff = nil; effects.optduration = nil
	end
end

local function GetSelectedSpellEffect()
	local t = GetSpellEffectList()
	if not effects.select and next(t) then SetSelectedSpellEffect(1) end -- default to first in list
	if not effects.select then effects.select = next(t) and t[1] or nil end -- default to first in list
	if effects.select then for k, v in pairs(t) do if v == effects.select then return k end end end
	effects.select = nil
	return nil
end

local function AddNewSpellEffect(name)
	local id = tonumber(name)
	if not id then id = MOD:GetSpellID(name) end
	if id then
		local n, _, icon = GetSpellInfo(id)
		local ect = MOD.db.global.SpellEffects[n]
		if not ect then
			ect = { duration = 0; id = id; icon = icon }
			MOD.db.global.SpellEffects[n] = ect
		end
		effects.disable = ect.disable; effects.duration = ect.duration; effects.kind = ect.kind; effects.renew = ect.renew; effects.caster = ect.caster
		effects.spell = ect.spell; effects.talent = ect.talent; effects.buff = ect.buff; effects.condition = ect.condition; effects.label = ect.label
		effects.optbuff = ect.optbuff; effects.optduration = ect.optduration; effects.select = n
	else
		effects.disable = nil; effects.duration = nil; effects.spell = nil; effects.kind = nil; effects.renew = nil; effects.caster = nil
		effects.talent = nil; effects.buff = nil; effects.condition = nil; effects.label = nil; effects.select = nil
		effects.optbuff = nil; effects.optduration = nil
	end
end

local function SetSpellEffectSettings()
	if effects.select then
		local ect = MOD.db.global.SpellEffects[effects.select]
		if ect then
			ect.disable = effects.disable and true or nil; ect.duration = tonumber(effects.duration); ect.kind = effects.kind; ect.renew = effects.renew
			ect.caster = effects.caster; ect.spell = effects.spell; ect.talent = effects.talent; ect.buff = effects.buff; ect.condition = effects.condition
			ect.id = MOD:GetSpellID(effects.spell or effects.select); ect.icon = MOD:GetIcon(effects.spell or effects.select); ect.label = effects.label
			ect.optbuff = effects.optbuff; ect.optduration = effects.optduration
		end
	end
end

local function DeleteSpellEffect() if effects.select then MOD.db.global.SpellEffects[effects.select] = nil end SetSelectedSpellEffect(nil) end

-- Set a standard color
local function SetStandardColor(i, r, g, b, a)
	local c = MOD.ColorPalette[i]
	if c then c.r = r; c.g = g; c.b = b; c.a = a end
end

-- Get a standard color
local function GetStandardColor(i)
	local c = MOD.ColorPalette[i]
	if c then return c.r, c.g, c.b, c.a end
	return 0, 0, 0, 0
end

-- Generate text array using the standard colors
local function GetStandardColorList()
	local t = { }
	for name, c in pairs(MOD.ColorPalette) do
		t[name] = string.format("|cFF%02x%02x%02x%s", c.r*255, c.g*255, c.b*255, name)
	end
	return t
end

-- Add class, group and racial buffs or debuffs from the known auras table to a bar group
local function AddAurasToBarGroup(bg, buff, monitor, castBy)
	if buff then
		bg.detectBuffs = true
		bg.detectBuffsMonitor = monitor
		bg.detectBuffsCastBy = castBy
	else
		bg.detectDebuffs = true
		bg.detectDebuffsMonitor = monitor
		bg.detectDebuffsCastBy = castBy
	end
end

-- Add cooldowns from the known cooldowns table to a bar group
local function AddCooldownsToBarGroup(bg)
	bg.detectCooldowns = true
end

-- Add notifications for conditions to a bar group
local function AddNotificationsToBarGroup(bg)
	-- only check conditions for the player's class
	local ct = MOD.db.profile.Conditions[MOD.myClass]
	if ct then
		for _, c in pairs(ct) do
			if IsOn(c) and c.name and c.notify then
				local bname = c.name
				local bar = { action = bname, enableBar = true, barLabel = bname, barType = "Notification", barSource = nil, monitor = nil, castBy = nil, }
				AddBarToGroup(bg, bar)
			end
		end
	end
end

-- Configure Raven with the selected standard bar groups
local function ConfigureBarGroups(style)
	local offsetY, delta = 0, style and 20 or 30
	if standard.Notifications then
		local bg = CreateBarGroup(L["Notifications"], false, false, style, 0, offsetY)
		AddNotificationsToBarGroup(bg)
		offsetY = offsetY + delta
	end
	if standard.Totems then
		local bg = CreateBarGroup(L["Totems"], true, false, style, 0, offsetY)
		bg.detectTotems = true; bg.showNoDuration = true; bg.sor = "C"; bg.showNoDurationBackground = false
		offsetY = offsetY + delta
	end
	if standard.Runes then
		local bg = CreateBarGroup(L["Runes"], true, false, style, 0, offsetY)
		bg.detectRuneCooldowns = true; bg.showNoDuration = true
		offsetY = offsetY + delta
	end
	if standard.Focus then
		local bg = CreateBarGroup(L["Focus"], true, false, style, 0, offsetY)
		AddAurasToBarGroup(bg, true, "focus", "player")
		AddAurasToBarGroup(bg, false, "focus", "player")
		bg.showNoDuration = false
		offsetY = offsetY + delta
	end
	if standard.Target then
		local bg = CreateBarGroup(L["Target"], true, false, style, 0, offsetY)
		AddAurasToBarGroup(bg, true, "target", "player")
		AddAurasToBarGroup(bg, false, "target", "player")
		bg.showNoDuration = false
		offsetY = offsetY + delta
	end
	if standard.Cooldowns then
		local bg = CreateBarGroup(L["Cooldowns"], true, false, style, 0, offsetY)
		bg.checkDuration = true; bg.minimumDuration = true; bg.filterDuration = 2
		AddCooldownsToBarGroup(bg)
		offsetY = offsetY + delta
	end
	if standard.PlayerDebuffs then
		local bg = CreateBarGroup(L["Debuffs"], true, false, style, 0, offsetY)
		AddAurasToBarGroup(bg, false, "player", "anyone")
		bg.showNoDuration = true; bg.iconColors = "Debuffs"
		offsetY = offsetY + delta
	end
	if standard.PlayerBuffs then
		local bg = CreateBarGroup(L["Buffs"], true, false, style, 0, offsetY)
		bg.showNoDuration = true; bg.sor = "T"
		AddAurasToBarGroup(bg, true, "player", "anyone")
		offsetY = offsetY + delta
	end
	if standard.ShortBuffs then
		local bg = CreateBarGroup(L["Short Buffs"], true, false, style, 0, offsetY)
		bg.checkDuration = true; bg.minimumDuration = false; bg.filterDuration = 120; bg.showNoDuration = false
		AddAurasToBarGroup(bg, true, "player", "anyone")
		offsetY = offsetY + delta
	end
	if standard.LongBuffs then -- minimum duration of two minutes
		local bg = CreateBarGroup(L["Long Buffs"], true, false, style, 0, offsetY)
		bg.checkDuration = true; bg.minimumDuration = true; bg.filterDuration = 120; bg.showNoDuration = true
		bg.barColors = "Class"; bg.sor = "C"
		AddAurasToBarGroup(bg, true, "player", "anyone")
		offsetY = offsetY + delta
	end
	if standard.BuffTracker then
		local bg = CreateBarGroup(L["Buff Tracker"], true, false, style, 0, offsetY)
		bg.detectBuffs = true; bg.detectAllBuffs = true; bg.showNoDuration = true; bg.sor = "T"
		offsetY = offsetY + delta
	end
	if standard.DebuffTracker then
		local bg = CreateBarGroup(L["Debuff Tracker"], true, false, style, 0, offsetY)
		bg.detectDebuffs = true; bg.detectAllDebuffs = true; bg.showNoDuration = true; bg.sor = "T"; bg.iconColors = "Debuffs"
		offsetY = offsetY + delta
	end
	if standard.Timeline then
		local bg = CreateBarGroup(L["Timeline"], true, false, false, 0, offsetY)
		bg.configuration = 13; bg.checkDuration = true; bg.minimumDuration = true; bg.filterDuration = 2; bg.showNoDuration = false
		bg.useDefaultDimensions = false; bg.iconSize = 25; bg.hideBar = true; bg.growDirection = true; bg.hideClock = true; bg.timeOffset = 9
		bg.useDefaultFontsAndTextures = false; bg.timeAlpha = 0.75; bg.labelAlpha = 0.5; bg.borderTexture = "Blizzard Tooltip"
		bg.borderColor = { r = 0.5, g = 0.5, b = 0.5, a = 1 }; bg.timelineAlpha = 0.65
		bg.detectInternalCooldowns = false; bg.detectSpellEffectCooldowns = false; bg.detectPotionCooldowns = false; bg.detectOtherCooldowns = false
		AddCooldownsToBarGroup(bg)
		offsetY = offsetY + delta
	end
	MOD:UpdateAllBarGroups()
end

-- Prepare a table of time format options showing examples to choose from with select dropdown menu
local function GetTimeFormatList(s, c)
	local i, menu = 1, {}
	while i <= #Nest_TimeFormatOptions do
		local f = Nest_FormatTime
		local t1, t2, t3, t4, t5 = f(8125.8, i, s, c), f(343.8, i, s, c), f(75.3, i, s, c), f(42.7, i, s, c), f(3.6, i, s, c)
		menu[i] = t1 .. ", " .. t2 .. ", " .. t3 .. ", " .. t4 .. ", " .. t5
		i = i + 1
	end
	return menu
end

-- Create a mini-options table to be inserted at top level in the Bliz interface
-- L["Top Options"] = "This addon lets you monitor buffs and debuffs for player, target and focus. Highlights and cooldown counts can be added to buttons to show status. Monitored buffs and debuffs can trigger helpful notifications."
-- For some reason cannot localize the strings in this table!
MOD.TopOptionsTable = {
	type = "group", order = 1,
	args = {
		Configure = {
			type = "execute", order = 90, name = L["Configure"],
			desc = L["Open Raven's standalone options panel."],
			func = function(info) MOD:OptionsPanel() end,
		},
	},
}

-- Create the options table to be used by the configuration GUI
MOD.OptionsTable = {
	type = "group", childGroups = "tab",
	args = {
		FrontPage = {
			type = "group", order = 10, name = L["Setup"],
			disabled = function(info) return InMode() end,
			args = {
				EnableGroup = {
					type = "group", order = 1, name = L["Enable"], inline = true,
					args = {
						EnableGroup = {
							type = "toggle", order = 10, name = L["Enable Raven"],
							desc = L["If checked, Raven is enabled, otherwise all features are disabled."],
							get = function(info) return MOD.db.profile.enabled end,
							set = function(info, value) MOD.db.profile.enabled = value end,
						},
						HideBlizzBuffsGroup = {
							type = "toggle", order = 20, name = L["Hide Blizzard Buffs"],
							desc = L["If checked, Raven will hide the default user interface for buffs."],
							get = function(info) return MOD.db.profile.hideBlizz end,
							set = function(info, value) MOD.db.profile.hideBlizz = value end,
						},
						HideConsolidatedBuffsGroup = {
							type = "toggle", order = 21, name = L["Hide Consolidated"],
							desc = L["If checked, Raven will hide the default consolidated buffs. Note that you enable/disable consolidated buffs in the game's Interface options under Buffs and Debuffs."],
							get = function(info) return MOD.db.profile.hideConsolidated end,
							set = function(info, value) MOD.db.profile.hideConsolidated = value end,
						},
						HideBlizzRunesGroup = {
							type = "toggle", order = 25, name = L["Hide Blizzard Runes"],
							desc = L["If checked, Raven will hide the default user interface for runes."],
							get = function(info) return MOD.db.profile.hideRunes end,
							set = function(info, value) MOD.db.profile.hideRunes = value end,
						},
						EnableSFX = {
							type = "toggle", order = 30, name = L["Mute Raven Sound"],
							desc = L["If checked, Raven will not play sound effects."],
							get = function(info) return MOD.db.profile.muteSFX end,
							set = function(info, value) MOD.db.profile.muteSFX = value end,
						},
						MinimapGroup = {
							type = "toggle", order = 35, name = L["Minimap Icon"],
							desc = L["If checked, Raven will add an icon to the minimap."],
							hidden = function(info) return MOD.ldbi == nil end,
							get = function(info) return not MOD.db.global.Minimap.hide end,
							set = function(info, value)
								MOD.db.global.Minimap.hide = not value
								if value then MOD.ldbi:Show("Raven") else MOD.ldbi:Hide("Raven") end
							end,
						},
					},
				},
				StandardGroups = {
					type = "group", order = 10, name = L["Standard Bar Groups"], inline = true,
					args = {
						Anchors = {
							type = "description", order = 1,
							name = L["Anchor description"]
						},
						Buffs = {
							type = "toggle", order = 5, name = L["Buffs"],
							get = function(info) return standard.PlayerBuffs end,
							set = function(info, value) standard.PlayerBuffs = value end,
						},
						spacer = { type = "description", order = 6, width = "double",
							name = function() return L["All buffs on you, sort by time left."] .. BarGroupString(L["Buffs"]) end,
						},
						spacerA = { type = "description", name = "", order = 7 },
						ShortBuffs = {
							type = "toggle", order = 10, name = L["Short Buffs"],
							get = function(info) return standard.ShortBuffs end,
							set = function(info, value) standard.ShortBuffs = value end,
						},
						spacer0 = { type = "description", order = 11, width = "double",
							name = function() return L["Buffs on you lasting less than 2 minutes."] .. BarGroupString(L["Short Buffs"]) end,
						},
						spacer0A = { type = "description", name = "", order = 12 },
						LongBuffs = {
							type = "toggle", order = 20, name = L["Long Buffs"],
							get = function(info) return standard.LongBuffs end,
							set = function(info, value) standard.LongBuffs = value end,
						},
						spacer1 = { type = "description", order = 21, width = "double",
							name = function() return L["Buffs on you lasting at least 2 minutes, sort and color by class."] .. BarGroupString(L["Long Buffs"]) end, 
						},
						spacer1A = { type = "description", name = "", order = 22 },
						Debuffs = {
							type = "toggle", order = 25, name = L["Debuffs"],
							get = function(info) return standard.PlayerDebuffs end,
							set = function(info, value) standard.PlayerDebuffs = value end,
						},
						spacer2 = { type = "description", order = 26, width = "double",
							name = function() return L["Debuffs on you."] .. BarGroupString(L["Debuffs"]) end,
						},
						spacer2A = { type = "description", name = "", order = 27 },
						Cooldowns = {
							type = "toggle", order = 30, name = L["Cooldowns"],
							get = function(info) return standard.Cooldowns end,
							set = function(info, value) standard.Cooldowns = value end,
						},
						spacer3 = { type = "description", order = 31, width = "double",
							name = function() return L["Cooldowns on your spells and trinkets lasting at least 2 seconds."] .. BarGroupString(L["Cooldowns"]) end, 
						},
						spacer3A = { type = "description", name = "", order = 32 },
						Target = {
							type = "toggle", order = 35, name = L["Target"],
							get = function(info) return standard.Target end,
							set = function(info, value) standard.Target = value end,
						},
						spacer4 = { type = "description", order = 36, width = "double",
							name = function() return L["Buffs and debuffs you cast on the target."] .. BarGroupString(L["Target"]) end, 
						},
						spacer4A = { type = "description", name = "", order = 37 },
						Focus = {
							type = "toggle", order = 40, name = L["Focus"],
							get = function(info) return standard.Focus end,
							set = function(info, value) standard.Focus = value end,
						},
						spacer5 = { type = "description", order = 41, width = "double",
							name = function() return L["Buffs and debuffs you cast on the focus."] .. BarGroupString(L["Focus"]) end, 
						},
						spacer5A = { type = "description", name = "", order = 42,
							hidden = function(info) return (MOD.myClass ~= "DEATHKNIGHT") and (MOD.myClass ~= "SHAMAN") end,
						},
						Totems = {
							type = "toggle", order = 45, name = L["Totems"],
							hidden = function(info) return MOD.myClass ~= "SHAMAN" end,
							get = function(info) return standard.Totems end,
							set = function(info, value) standard.Totems = value end,
						},
						Runes = {
							type = "toggle", order = 45, name = L["Runes"],
							hidden = function(info) return MOD.myClass ~= "DEATHKNIGHT" end,
							get = function(info) return standard.Runes end,
							set = function(info, value) standard.Runes = value end,
						},
						spacer6_DK = { type = "description", order = 46, width = "double",
							name = function() return L["Rune cooldown bars for Death Knight players."] .. BarGroupString(L["Runes"]) end, 
							hidden = function(info) return MOD.myClass ~= "DEATHKNIGHT" end,
						},
						spacer6_SHAMAN = { type = "description", order = 46, width = "double",
							name = function() return L["Totem tracker bars for Shaman players."] .. BarGroupString(L["Totems"]) end, 
							hidden = function(info) return MOD.myClass ~= "SHAMAN" end,
						},
						spacer6A = { type = "description", name = "", order = 47 },
						Notifications = {
							type = "toggle", order = 50, name = L["Notifications"],
							get = function(info) return standard.Notifications end,
							set = function(info, value) standard.Notifications = value end,
						},
						spacer7 = { type = "description", order = 51, width = "double",
							name = function() return L["Common class-specific notifications."] .. BarGroupString(L["Notifications"]) end, 
						},
						spacer7A = { type = "description", name = "", order = 52 },
						Hots = {
							type = "toggle", order = 60, name = L["Buff Tracker"],
							get = function(info) return standard.BuffTracker end,
							set = function(info, value) standard.BuffTracker = value end,
						},
						spacer8 = { type = "description", order = 61, width = "double",
							name = function() return L["Buff tracker string"] .. BarGroupString(L["Buff Tracker"]) end,
						},
						spacer8A = { type = "description", name = "", order = 62 },
						Dots = {
							type = "toggle", order = 65, name = L["Debuff Tracker"],
							get = function(info) return standard.DebuffTracker end,
							set = function(info, value) standard.DebuffTracker = value end,
						},
						spacer9 = { type = "description", order = 66, width = "double",
							name = function() return L["Debuff tracker string"] .. BarGroupString(L["Debuff Tracker"]) end,
						},
						spacer9A = { type = "description", name = "", order = 67 },
						Timeline = {
							type = "toggle", order = 70, name = L["Timeline"],
							get = function(info) return standard.Timeline end,
							set = function(info, value) standard.Timeline = value end,
						},
						spacer10 = { type = "description", order = 71, width = "double",
							name = function() return L["Timeline string"] .. BarGroupString(L["Timeline"]) end,
						},
						spacer10A = { type = "description", name = "", order = 72 },
						ConfigureBars = {
							type = "execute", order = 90, name = L["Create As Bars"],
							desc = L["Create bars string"],
							disabled = function(info) return not AnySelectedStandardBarGroups(false) end,
							func = function(info) ConfigureBarGroups(true) end,
							confirm = function(info) if CheckBarGroupsExist() then return L["Configure string"] end end,
						},
						ConfigureIcons = {
							type = "execute", order = 91, name = L["Create As Icons"],
							desc = L["Create icons string"],
							disabled = function(info) return not AnySelectedStandardBarGroups(false) end,
							func = function(info) ConfigureBarGroups(false) end,
							confirm = function(info) if CheckBarGroupsExist() then return L["Configure string"] end end,
						},
						spacer11 = { type = "description", name = "", order = 95, width = "half" },
						Reset = {
							type = "execute", order = 96, name = L["Reset"], width = "half",
							desc = L["Reset selections."],
							disabled = function(info) return not AnySelectedStandardBarGroups(false) end,
							func = function(info) ResetSelectedStandardBarGroups() end,
						},
						LinkSettings = {
							type = "execute", order = 97, name = L["Link"], width = "half",
							desc = L["Link settings string"],
							disabled = function(info) return not AnySelectedStandardBarGroups(true) end,
							func = function(info) LinkStandardBarGroups() end,
						},
						DeleteBars = {
							type = "execute", order = 98, name = L["Delete"], width = "half",
							desc = L["Delete the selected bar groups."],
							disabled = function(info) return not AnySelectedStandardBarGroups(true) end,
							func = function(info) DeleteStandardBarGroups() end,
							confirm = function(info) return L["Delete standard string"] end,
						},
					},
				},
				AnchorGroup = {
					type = "group", order = 50, name = L["Bar Group Anchors and Test Mode"], inline = true,
					args = {
						Anchors = {
							type = "description", order = 10,
							name = L["Bar group anchor string"],
						},
						LockBars = {
							type = "execute", order = 11, name = L["Lock All Anchors"], 
							desc = L["Lock and hide the anchors for all bar groups."],
							func = function(info) MOD:LockBarGroups(true) end,
						},
						UnlockBars = {
							type = "execute", order = 12, name = L["Unlock All Anchors"],
							desc = L["Unlock and show the anchors for all bar groups."],
							func = function(info) MOD:LockBarGroups(false) end,
						},
						TestBars = {
							type = "execute", order = 13, name = L["Toggle Test Mode"],
							desc = L["Toggle test mode for all bar groups."],
							func = function(info) MOD:TestBarGroups() end,
						},
					},
				},
			},
		},
		DefaultsPage = {
			type = "group", order = 15, name = L["Defaults"],
			disabled = function(info) return InMode() end,
			args = {
				Defaults = {
					type = "description", order = 10,
					name = L["Defaults string"],
				},
				DimensionGroup = {
					type = "group", order = 10, name = L["Format"], inline = true,
					args = {
						BarsGroup = {
							type = "group", order = 10, name = L["Bar Configurations"], inline = true,
							args = {
								BarWidth = {
									type = "range", order = 10, name = L["Bar Width"], min = 5, max = 500, step = 1,
									desc = L["Set width of bars."],
									get = function(info) return MOD.db.global.Defaults.barWidth end,
									set = function(info, value) MOD.db.global.Defaults.barWidth = value; MOD:UpdateAllBarGroups() end,
								},
								BarHeight = {
									type = "range", order = 15, name = L["Bar Height"], min = 5, max = 100, step = 1,
									desc = L["Set height of bars."],
									get = function(info) return MOD.db.global.Defaults.barHeight end,
									set = function(info, value) MOD.db.global.Defaults.barHeight = value; MOD:UpdateAllBarGroups() end,
								},
								IconSize = {
									type = "range", order = 20, name = L["Icon Size"], min = 5, max = 100, step = 1,
									desc = L["Set width/height for icons."],
									get = function(info) return MOD.db.global.Defaults.iconSize end,
									set = function(info, value) MOD.db.global.Defaults.iconSize = value; MOD:UpdateAllBarGroups() end,
								},
								BarScale = {
									type = "range", order = 25, name = L["Scale"], min = 0.1, max = 2, step = 0.05,
									desc = L["Set scale factor for bars and icons."],
									get = function(info) return MOD.db.global.Defaults.scale end,
									set = function(info, value) MOD.db.global.Defaults.scale = value; MOD:UpdateAllBarGroups() end,
								},
								Space1 = { type = "description", name = "", order = 40 },
								HorizontalSpacing = {
									type = "range", order = 60, name = L["Horizontal Spacing"], min = -100, max = 100, step = 1,
									desc = L["Adjust horizontal spacing between bars."],
									get = function(info) return MOD.db.global.Defaults.spacingX end,
									set = function(info, value) MOD.db.global.Defaults.spacingX = value; MOD:UpdateAllBarGroups() end,
								},
								VerticalSpacing = {
									type = "range", order = 65, name = L["Vertical Spacing"], min = -100, max = 100, step = 1,
									desc = L["Adjust vertical spacing between bars."],
									get = function(info) return MOD.db.global.Defaults.spacingY end,
									set = function(info, value) MOD.db.global.Defaults.spacingY = value; MOD:UpdateAllBarGroups() end,
								},
								IconOffsetX = {
									type = "range", order = 70, name = L["Icon Inset"], min = -200, max = 200, step = 1,
									desc = L["Set icon's horizontal inset from bar."],
									get = function(info) return MOD.db.global.Defaults.iconOffsetX end,
									set = function(info, value) MOD.db.global.Defaults.iconOffsetX = value; MOD:UpdateAllBarGroups() end,
								},
								IconOffsetY = {
									type = "range", order = 75, name = L["Icon Offset"], min = -200, max = 200, step = 1,
									desc = L["Set vertical offset between icon and bar."],
									get = function(info) return MOD.db.global.Defaults.iconOffsetY end,
									set = function(info, value) MOD.db.global.Defaults.iconOffsetY = value; MOD:UpdateAllBarGroups() end,
								},
								Space2 = { type = "description", name = "", order = 80 },
								BarFormatGroup = {
									type = "group", order = 90, name = "", inline = true,
									args = {
										HideIconGroup = {
											type = "toggle", order = 30, name = L["Icon"], width = "half",
											desc = L["Show icon string"],
											get = function(info) return not MOD.db.global.Defaults.hideIcon end,
											set = function(info, value) MOD.db.global.Defaults.hideIcon = not value; MOD:UpdateAllBarGroups() end,
										},
										HideClockGroup = {
											type = "toggle", order = 31, name = L["Clock"], width = "half",
											desc = L["Show clock animation on icons for timer bars."],
											get = function(info) return not MOD.db.global.Defaults.hideClock end,
											set = function(info, value) MOD.db.global.Defaults.hideClock = not value; MOD:UpdateAllBarGroups() end,
										},
										HideBarGroup = {
											type = "toggle", order = 32, name = L["Bar"], width = "half",
											desc = L["Show colored bar and background."],
											get = function(info) return not MOD.db.global.Defaults.hideBar end,
											set = function(info, value) MOD.db.global.Defaults.hideBar = not value; MOD:UpdateAllBarGroups() end,
										},
										HideSparkGroup = {
											type = "toggle", order = 33, name = L["Spark"], width = "half",
											desc = L["Show spark that moves across bars to indicate remaining time."],
											disabled = function(info) return MOD.db.global.Defaults.hideBar end,
											get = function(info) return not MOD.db.global.Defaults.hideSpark end,
											set = function(info, value) MOD.db.global.Defaults.hideSpark = not value; MOD:UpdateAllBarGroups() end,
										},
										HideLabelGroup = {
											type = "toggle", order = 34, name = L["Label"], width = "half",
											desc = L["Show label text on bars."],
											get = function(info) return not MOD.db.global.Defaults.hideLabel end,
											set = function(info, value) MOD.db.global.Defaults.hideLabel = not value; MOD:UpdateAllBarGroups() end,
										},
										HideCountGroup = {
											type = "toggle", order = 35, name = L["Count"], width = "half",
											desc = L["Show stack count in parentheses after label (it is also displayed as overlay on icon)."],
											get = function(info) return not MOD.db.global.Defaults.hideCount end,
											set = function(info, value) MOD.db.global.Defaults.hideCount = not value; MOD:UpdateAllBarGroups() end,
										},
										HideTimerGroup = {
											type = "toggle", order = 36, name = L["Time"], width = "half",
											desc = L["Show time left on bars that have a duration."],
											get = function(info) return not MOD.db.global.Defaults.hideValue end,
											set = function(info, value) MOD.db.global.Defaults.hideValue = not value; MOD:UpdateAllBarGroups() end,
										},
										TooltipsGroup = {
											type = "toggle", order = 37, name = L["Tooltips"], width = "half",
											desc = L["Show tooltips when the cursor is over a bar's icon."],
											get = function(info) return MOD.db.global.Defaults.showTooltips end,
											set = function(info, value) MOD.db.global.Defaults.showTooltips = value; MOD:UpdateAllBarGroups() end,
										},
									},
								},
							},
						},
						IconsGroup = {
							type = "group", order = 10, name = L["Icon Configurations"], inline = true,
							args = {
								BarWidth = {
									type = "range", order = 10, name = L["Bar Width"], min = 5, max = 500, step = 1,
									desc = L["Set width of bars."],
									get = function(info) return MOD.db.global.Defaults.i_barWidth end,
									set = function(info, value) MOD.db.global.Defaults.i_barWidth = value; MOD:UpdateAllBarGroups() end,
								},
								BarHeight = {
									type = "range", order = 15, name = L["Bar Height"], min = 5, max = 100, step = 1,
									desc = L["Set height of bars."],
									get = function(info) return MOD.db.global.Defaults.i_barHeight end,
									set = function(info, value) MOD.db.global.Defaults.i_barHeight = value; MOD:UpdateAllBarGroups() end,
								},
								IconSize = {
									type = "range", order = 20, name = L["Icon Size"], min = 5, max = 100, step = 1,
									desc = L["Set width/height for icons."],
									get = function(info) return MOD.db.global.Defaults.i_iconSize end,
									set = function(info, value) MOD.db.global.Defaults.i_iconSize = value; MOD:UpdateAllBarGroups() end,
								},
								BarScale = {
									type = "range", order = 25, name = L["Scale"], min = 0.1, max = 2, step = 0.05,
									desc = L["Set scale factor for bars and icons."],
									get = function(info) return MOD.db.global.Defaults.i_scale end,
									set = function(info, value) MOD.db.global.Defaults.i_scale = value; MOD:UpdateAllBarGroups() end,
								},
								Space1 = { type = "description", name = "", order = 40 },
								HorizontalSpacing = {
									type = "range", order = 60, name = L["Horizontal Spacing"], min = -100, max = 100, step = 1,
									desc = L["Adjust horizontal spacing between bars."],
									get = function(info) return MOD.db.global.Defaults.i_spacingX end,
									set = function(info, value) MOD.db.global.Defaults.i_spacingX = value; MOD:UpdateAllBarGroups() end,
								},
								VerticalSpacing = {
									type = "range", order = 65, name = L["Vertical Spacing"], min = -100, max = 100, step = 1,
									desc = L["Adjust vertical spacing between bars."],
									get = function(info) return MOD.db.global.Defaults.i_spacingY end,
									set = function(info, value) MOD.db.global.Defaults.i_spacingY = value; MOD:UpdateAllBarGroups() end,
								},
								IconOffsetX = {
									type = "range", order = 70, name = L["Icon Inset"], min = -200, max = 200, step = 1,
									desc = L["Set icon's horizontal inset from bar."],
									get = function(info) return MOD.db.global.Defaults.i_iconOffsetX end,
									set = function(info, value) MOD.db.global.Defaults.i_iconOffsetX = value; MOD:UpdateAllBarGroups() end,
								},
								IconOffsetY = {
									type = "range", order = 75, name = L["Icon Offset"], min = -200, max = 200, step = 1,
									desc = L["Set vertical offset between icon and bar."],
									get = function(info) return MOD.db.global.Defaults.i_iconOffsetY end,
									set = function(info, value) MOD.db.global.Defaults.i_iconOffsetY = value; MOD:UpdateAllBarGroups() end,
								},
								Space2 = { type = "description", name = "", order = 80 },
								BarFormatGroup = {
									type = "group", order = 90, name = "", inline = true,
									args = {
										HideIconGroup = {
											type = "toggle", order = 30, name = L["Icon"], width = "half",
											desc = L["Show icon string"],
											get = function(info) return not MOD.db.global.Defaults.i_hideIcon end,
											set = function(info, value) MOD.db.global.Defaults.i_hideIcon = not value; MOD:UpdateAllBarGroups() end,
										},
										HideClockGroup = {
											type = "toggle", order = 31, name = L["Clock"], width = "half",
											desc = L["Show clock animation on icons for timer bars."],
											get = function(info) return not MOD.db.global.Defaults.i_hideClock end,
											set = function(info, value) MOD.db.global.Defaults.i_hideClock = not value; MOD:UpdateAllBarGroups() end,
										},
										HideBarGroup = {
											type = "toggle", order = 32, name = L["Bar"], width = "half",
											desc = L["Show colored bar and background."],
											get = function(info) return not MOD.db.global.Defaults.i_hideBar end,
											set = function(info, value) MOD.db.global.Defaults.i_hideBar = not value; MOD:UpdateAllBarGroups() end,
										},
										HideSparkGroup = {
											type = "toggle", order = 33, name = L["Spark"], width = "half",
											desc = L["Show spark that moves across bars to indicate remaining time."],
											disabled = function(info) return MOD.db.global.Defaults.i_hideBar end,
											get = function(info) return not MOD.db.global.Defaults.i_hideSpark end,
											set = function(info, value) MOD.db.global.Defaults.i_hideSpark = not value; MOD:UpdateAllBarGroups() end,
										},
										HideLabelGroup = {
											type = "toggle", order = 34, name = L["Label"], width = "half",
											desc = L["Show label text on bars."],
											get = function(info) return not MOD.db.global.Defaults.i_hideLabel end,
											set = function(info, value) MOD.db.global.Defaults.i_hideLabel = not value; MOD:UpdateAllBarGroups() end,
										},
										HideCountGroup = {
											type = "toggle", order = 35, name = L["Count"], width = "half",
											desc = L["Show stack count in parentheses after label (it is also displayed as overlay on icon)."],
											get = function(info) return not MOD.db.global.Defaults.i_hideCount end,
											set = function(info, value) MOD.db.global.Defaults.i_hideCount = not value; MOD:UpdateAllBarGroups() end,
										},
										HideTimerGroup = {
											type = "toggle", order = 36, name = L["Time"], width = "half",
											desc = L["Show time left on bars that have a duration."],
											get = function(info) return not MOD.db.global.Defaults.i_hideValue end,
											set = function(info, value) MOD.db.global.Defaults.i_hideValue = not value; MOD:UpdateAllBarGroups() end,
										},
										TooltipsGroup = {
											type = "toggle", order = 37, name = L["Tooltips"], width = "half",
											desc = L["Show tooltips when the cursor is over a bar's icon."],
											get = function(info) return MOD.db.global.Defaults.i_showTooltips end,
											set = function(info, value) MOD.db.global.Defaults.i_showTooltips = value; MOD:UpdateAllBarGroups() end,
										},
									},
								},
							},
						},
						ResetDimensions = {
							type = "execute", order = 90, name = L["Reset Format"],
							desc = L["Reset format to default settings."],
							confirm = function(info) return L["RESET FORMAT\nAre you sure you want to reset the format options?"] end,
							func = function(info) MOD:SetDimensionDefaults(MOD.db.global.Defaults); MOD:UpdateAllBarGroups() end,
						},
					},
				},
				FontsGroup = {
					type = "group", order = 20, name = L["Fonts and Textures"], inline = true,
					args = {
						LabelText = {
							type = "group", order = 21, name = L["Label Text"], inline = true,
							args = {
								LabelFont = {
									type = "select", order = 10, name = L["Font"], 
									desc = L["Select font."],
									dialogControl = 'LSM30_Font',
									values = AceGUIWidgetLSMlists.font,
									get = function(info) return MOD.db.global.Defaults.labelFont end,
									set = function(info, value) MOD.db.global.Defaults.labelFont = value; MOD:UpdateAllBarGroups() end,
								},
								LabelFontSize = {
									type = "range", order = 15, name = L["Font Size"], min = 5, max = 50, step = 1,
									desc = L["Set font size."],
									get = function(info) return MOD.db.global.Defaults.labelFSize end,
									set = function(info, value) MOD.db.global.Defaults.labelFSize = value; MOD:UpdateAllBarGroups() end,
								},
								LabelAlpha = {
									type = "range", order = 20, name = L["Opacity"], min = 0, max = 1, step = 0.05,
									desc = L["Set text opacity."],
									get = function(info) return MOD.db.global.Defaults.labelAlpha end,
									set = function(info, value) MOD.db.global.Defaults.labelAlpha = value; MOD:UpdateAllBarGroups() end,
								},
								LabelColor = {
									type = "color", order = 25, name = L["Color"], hasAlpha = false, width = "half",
									get = function(info)
										local t = MOD.db.global.Defaults.labelColor
										if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
									end,
									set = function(info, r, g, b, a)
										local t = MOD.db.global.Defaults.labelColor
										if not t then MOD.db.global.Defaults.labelColor = { r = r, g = g, b = b, a = a }
											else t.r = r; t.g = g; t.b = b; t.a = a end
										MOD:UpdateAllBarGroups()
									end,
								},
								Space = { type = "description", name = "", order = 30 },
								LabelOutline = {
									type = "toggle", order = 35, name = L["Outline"], width = "half",
									desc = L["Add black outline."],
									get = function(info) return MOD.db.global.Defaults.labelOutline end,
									set = function(info, value) MOD.db.global.Defaults.labelOutline = value; MOD:UpdateAllBarGroups() end,
								},
								LabelThick = {
									type = "toggle", order = 40, name = L["Thick"], width = "half",
									desc = L["Add thick black outline."],
									get = function(info) return MOD.db.global.Defaults.labelThick end,
									set = function(info, value) MOD.db.global.Defaults.labelThick = value; MOD:UpdateAllBarGroups() end,
								},
								LabelMono = {
									type = "toggle", order = 45, name = L["Mono"], width = "half",
									desc = L["Render font without antialiasing."],
									get = function(info) return MOD.db.global.Defaults.labelMono end,
									set = function(info, value) MOD.db.global.Defaults.labelMono = value; MOD:UpdateAllBarGroups() end,
								},
								LabelShadow = {
									type = "toggle", order = 50, name = L["Shadow"], width = "half",
									desc = L["Show shadow with text."],
									get = function(info) return MOD.db.global.Defaults.labelShadow end,
									set = function(info, value) MOD.db.global.Defaults.labelShadow = value; MOD:UpdateAllBarGroups() end,
								},
							},
						},
						TimeText = {
							type = "group", order = 31, name = L["Time Text"], inline = true,
							args = {
								TimeFont = {
									type = "select", order = 10, name = L["Font"], 
									desc = L["Select font."],
									dialogControl = 'LSM30_Font',
									values = AceGUIWidgetLSMlists.font,
									get = function(info) return MOD.db.global.Defaults.timeFont end,
									set = function(info, value) MOD.db.global.Defaults.timeFont = value; MOD:UpdateAllBarGroups() end,
								},
								TimeFontSize = {
									type = "range", order = 15, name = L["Font Size"], min = 5, max = 50, step = 1,
									desc = L["Set font size."],
									get = function(info) return MOD.db.global.Defaults.timeFSize end,
									set = function(info, value) MOD.db.global.Defaults.timeFSize = value; MOD:UpdateAllBarGroups() end,
								},
								TimeAlpha = {
									type = "range", order = 20, name = L["Opacity"], min = 0, max = 1, step = 0.05,
									desc = L["Set text opacity."],
									get = function(info) return MOD.db.global.Defaults.timeAlpha end,
									set = function(info, value) MOD.db.global.Defaults.timeAlpha = value; MOD:UpdateAllBarGroups() end,
								},
								TimeColor = {
									type = "color", order = 25, name = L["Color"], hasAlpha = false, width = "half",
									get = function(info)
										local t = MOD.db.global.Defaults.timeColor
										if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
									end,
									set = function(info, r, g, b, a)
										local t = MOD.db.global.Defaults.timeColor
										if not t then MOD.db.global.Defaults.timeColor = { r = r, g = g, b = b, a = a }
											else t.r = r; t.g = g; t.b = b; t.a = a end
										MOD:UpdateAllBarGroups()
									end,
								},
								Space = { type = "description", name = "", order = 30 },
								TimeOutline = {
									type = "toggle", order = 35, name = L["Outline"], width = "half",
									desc = L["Add black outline."],
									get = function(info) return MOD.db.global.Defaults.timeOutline end,
									set = function(info, value) MOD.db.global.Defaults.timeOutline = value; MOD:UpdateAllBarGroups() end,
								},
								TimeThick = {
									type = "toggle", order = 40, name = L["Thick"], width = "half",
									desc = L["Add thick black outline."],
									get = function(info) return MOD.db.global.Defaults.timeThick end,
									set = function(info, value) MOD.db.global.Defaults.timeThick = value; MOD:UpdateAllBarGroups() end,
								},
								TimeMono = {
									type = "toggle", order = 45, name = L["Mono"], width = "half",
									desc = L["Render font without antialiasing."],
									get = function(info) return MOD.db.global.Defaults.timeMono end,
									set = function(info, value) MOD.db.global.Defaults.timeMono = value; MOD:UpdateAllBarGroups() end,
								},
								TimeShadow = {
									type = "toggle", order = 50, name = L["Shadow"], width = "half",
									desc = L["Show shadow with text."],
									get = function(info) return MOD.db.global.Defaults.timeShadow end,
									set = function(info, value) MOD.db.global.Defaults.timeShadow = value; MOD:UpdateAllBarGroups() end,
								},
							},
						},
						IconText = {
							type = "group", order = 41, name = L["Icon Text"], inline = true,
							args = {
								IconFont = {
									type = "select", order = 10, name = L["Font"], 
									desc = L["Select font."],
									dialogControl = 'LSM30_Font',
									values = AceGUIWidgetLSMlists.font,
									get = function(info) return MOD.db.global.Defaults.iconFont end,
									set = function(info, value) MOD.db.global.Defaults.iconFont = value; MOD:UpdateAllBarGroups() end,
								},
								IconFontSize = {
									type = "range", order = 15, name = L["Font Size"], min = 5, max = 50, step = 1,
									desc = L["Set font size."],
									get = function(info) return MOD.db.global.Defaults.iconFSize end,
									set = function(info, value) MOD.db.global.Defaults.iconFSize = value; MOD:UpdateAllBarGroups() end,
								},
								IconAlpha = {
									type = "range", order = 20, name = L["Opacity"], min = 0, max = 1, step = 0.05,
									desc = L["Set text opacity."],
									get = function(info) return MOD.db.global.Defaults.iconAlpha end,
									set = function(info, value) MOD.db.global.Defaults.iconAlpha = value; MOD:UpdateAllBarGroups() end,
								},
								IconColor = {
									type = "color", order = 25, name = L["Color"], hasAlpha = false, width = "half",
									get = function(info)
										local t = MOD.db.global.Defaults.iconColor
										if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
									end,
									set = function(info, r, g, b, a)
										local t = MOD.db.global.Defaults.iconColor
										if not t then MOD.db.global.Defaults.iconColor = { r = r, g = g, b = b, a = a }
											else t.r = r; t.g = g; t.b = b; t.a = a end
										MOD:UpdateAllBarGroups()
									end,
								},
								Space = { type = "description", name = "", order = 30 },
								IconOutline = {
									type = "toggle", order = 35, name = L["Outline"], width = "half",
									desc = L["Add black outline."],
									get = function(info) return MOD.db.global.Defaults.iconOutline end,
									set = function(info, value) MOD.db.global.Defaults.iconOutline = value; MOD:UpdateAllBarGroups() end,
								},
								IconThick = {
									type = "toggle", order = 40, name = L["Thick"], width = "half",
									desc = L["Add thick black outline."],
									get = function(info) return MOD.db.global.Defaults.iconThick end,
									set = function(info, value) MOD.db.global.Defaults.iconThick = value; MOD:UpdateAllBarGroups() end,
								},
								IconMono = {
									type = "toggle", order = 45, name = L["Mono"], width = "half",
									desc = L["Render font without antialiasing."],
									get = function(info) return MOD.db.global.Defaults.iconMono end,
									set = function(info, value) MOD.db.global.Defaults.iconMono = value; MOD:UpdateAllBarGroups() end,
								},
								IconShadow = {
									type = "toggle", order = 50, name = L["Shadow"], width = "half",
									desc = L["Show shadow with text."],
									get = function(info) return MOD.db.global.Defaults.iconShadow end,
									set = function(info, value) MOD.db.global.Defaults.iconShadow = value; MOD:UpdateAllBarGroups() end,
								},
							},
						},
						PanelsBorders = {
							type = "group", order = 51, name = L["Panels and Borders"], inline = true,
							args = {
								EnablePanel = {
									type = "toggle", order = 10, name = L["Background Panel"],
									desc = L["Enable display of a background panel behind bar group."],
									get = function(info) return MOD.db.global.Defaults.backdropEnable end,
									set = function(info, value) MOD.db.global.Defaults.backdropEnable = value; MOD:UpdateAllBarGroups() end,
								},
								PanelTexture = {
									type = "select", order = 15, name = L["Panel Texture"], 
									desc = L["Select texture to display in panel behind bar group."],
									dialogControl = 'LSM30_Background',
									values = AceGUIWidgetLSMlists.background,
									get = function(info) return MOD.db.global.Defaults.backdropPanel end,
									set = function(info, value) MOD.db.global.Defaults.backdropPanel = value; MOD:UpdateAllBarGroups() end,
								},
								PanelPadding = {
									type = "range", order = 20, name = L["Padding"], min = 0, max = 32, step = 0.1,
									desc = L["Adjust padding between bar group and the background panel and border."],
									get = function(info) return MOD.db.global.Defaults.backdropPadding end,
									set = function(info, value) MOD.db.global.Defaults.backdropPadding = value; MOD:UpdateAllBarGroups() end,
								},
								PanelColor = {
									type = "color", order = 25, name = L["Panel Color"], hasAlpha = true,
									desc = L["Set fill color for the panel."],
									get = function(info)
										local t = MOD.db.global.Defaults.backdropFill
										if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
									end,
									set = function(info, r, g, b, a)
										local t = MOD.db.global.Defaults.backdropFill
										if not t then MOD.db.global.Defaults.backdropFill = { r = r, g = g, b = b, a = a }
											else t.r = r; t.g = g; t.b = b; t.a = a end
										MOD:UpdateAllBarGroups()
									end,
								},
								Space1 = { type = "description", name = "", order = 30 },
								BackdropOffsetX = {
									type = "range", order = 31, name = L["Offset X"], min = -50, max = 50, step = 1,
									desc = L["Adjust horizontal position of the panel."],
									get = function(info) return MOD.db.global.Defaults.backdropOffsetX end,
									set = function(info, value) MOD.db.global.Defaults.backdropOffsetX = value; MOD:UpdateAllBarGroups() end,
								},
								BackdropOffsetY = {
									type = "range", order = 32, name = L["Offset Y"], min = -50, max = 50, step = 1,
									desc = L["Adjust vertical position of the panel."],
									get = function(info) return MOD.db.global.Defaults.backdropOffsetY end,
									set = function(info, value) MOD.db.global.Defaults.backdropOffsetY = value; MOD:UpdateAllBarGroups() end,
								},
								BackdropPadW = {
									type = "range", order = 33, name = L["Extra Width"], min = 0, max = 50, step = 1,
									desc = L["Adjust width of the panel."],
									get = function(info) return MOD.db.global.Defaults.backdropPadW end,
									set = function(info, value) MOD.db.global.Defaults.backdropPadW = value; MOD:UpdateAllBarGroups() end,
								},
								BackdropPadH = {
									type = "range", order = 34, name = L["Extra Height"], min = 0, max = 50, step = 1,
									desc = L["Adjust height of the panel."],
									get = function(info) return MOD.db.global.Defaults.backdropPadH end,
									set = function(info, value) MOD.db.global.Defaults.backdropPadH = value; MOD:UpdateAllBarGroups() end,
								},
								Space2 = { type = "description", name = "", order = 40 },
								BackdropTexture = {
									type = "select", order = 42, name = L["Background Border"], 
									desc = L["Select border to display behind bar group (select None to disable border)."],
									dialogControl = 'LSM30_Border',
									values = AceGUIWidgetLSMlists.border,
									get = function(info) return MOD.db.global.Defaults.backdropTexture end,
									set = function(info, value) MOD.db.global.Defaults.backdropTexture = value; MOD:UpdateAllBarGroups() end,
								},
								BackdropWidth = {
									type = "range", order = 44, name = L["Edge Size"], min = 0, max = 32, step = 0.1,
									desc = L["Adjust size of the border's edge."],
									get = function(info) return MOD.db.global.Defaults.backdropWidth end,
									set = function(info, value) MOD.db.global.Defaults.backdropWidth = value; MOD:UpdateAllBarGroups() end,
								},
								BackdropInset = {
									type = "range", order = 45, name = L["Inset"], min = -16, max = 16, step = 0.1,
									desc = L["Adjust inset from the border to background panel's fill color."],
									get = function(info) return MOD.db.global.Defaults.backdropInset end,
									set = function(info, value) MOD.db.global.Defaults.backdropInset = value; MOD:UpdateAllBarGroups() end,
								},
								BackdropColor = {
									type = "color", order = 50, name = L["Border Color"], hasAlpha = true,
									desc = L["Set color for the border."],
									get = function(info)
										local t = MOD.db.global.Defaults.backdropColor
										if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
									end,
									set = function(info, r, g, b, a)
										local t = MOD.db.global.Defaults.backdropColor
										if not t then MOD.db.global.Defaults.backdropColor = { r = r, g = g, b = b, a = a }
											else t.r = r; t.g = g; t.b = b; t.a = a end
										MOD:UpdateAllBarGroups()
									end,
								},
								Space3 = { type = "description", name = "", order = 55 },
								BorderTexture = {
									type = "select", order = 60, name = L["Bar Border"], 
									desc = L["Select border for bars in the bar group (select None to disable border)."],
									dialogControl = 'LSM30_Border',
									values = AceGUIWidgetLSMlists.border,
									get = function(info) return MOD.db.global.Defaults.borderTexture end,
									set = function(info, value) MOD.db.global.Defaults.borderTexture = value; MOD:UpdateAllBarGroups() end,
								},
								BorderWidth = {
									type = "range", order = 65, name = L["Edge Size"], min = 0, max = 32, step = 0.1,
									desc = L["Adjust size of the border's edge."],
									get = function(info) return MOD.db.global.Defaults.borderWidth end,
									set = function(info, value) MOD.db.global.Defaults.borderWidth = value; MOD:UpdateAllBarGroups() end,
								},
								BorderOffset = {
									type = "range", order = 70, name = L["Offset"], min = -16, max = 16, step = 0.1,
									desc = L["Adjust offset to the border from the bar."],
									get = function(info) return MOD.db.global.Defaults.borderOffset end,
									set = function(info, value) MOD.db.global.Defaults.borderOffset = value; MOD:UpdateAllBarGroups() end,
								},
								BorderColor = {
									type = "color", order = 75, name = L["Border Color"], hasAlpha = true,
									desc = L["Set color for the border."],
									get = function(info)
										local t = MOD.db.global.Defaults.borderColor
										if t then return t.r, t.g, t.b, t.a else return 0, 0, 0, 1 end
									end,
									set = function(info, r, g, b, a)
										local t = MOD.db.global.Defaults.borderColor
										if not t then MOD.db.global.Defaults.borderColor = { r = r, g = g, b = b, a = a }
											else t.r = r; t.g = g; t.b = b; t.a = a end
										MOD:UpdateAllBarGroups()
									end,
								},
							},
						},
						Bars = {
							type = "group", order = 61, name = L["Bars and Icons"], inline = true,
							args = {
								ForegroundTexture = {
									type = "select", order = 10, name = L["Bar Foreground Texture"], 
									desc = L["Select foreground texture for bars."],
									dialogControl = 'LSM30_Statusbar',
									values = AceGUIWidgetLSMlists.statusbar,
									get = function(info) return MOD.db.global.Defaults.texture end,
									set = function(info, value) MOD.db.global.Defaults.texture = value; MOD:UpdateAllBarGroups() end,
								},
								ForegroundAlpha = {
									type = "range", order = 15, name = L["Foreground Opacity"], min = 0, max = 1, step = 0.05,
									desc = L["Set foreground opacity for bars."],
									get = function(info) return MOD.db.global.Defaults.fgAlpha end,
									set = function(info, value) MOD.db.global.Defaults.fgAlpha = value; MOD:UpdateAllBarGroups() end,
								},
								ForegroundSaturation = {
									type = "range", order = 20, name = L["Foreground Saturation"], min = -1, max = 1, step = 0.05,
									desc = L["Set saturation for foreground colors."],
									get = function(info) return MOD.db.global.Defaults.fgSaturation end,
									set = function(info, value) MOD.db.global.Defaults.fgSaturation = value; MOD:UpdateAllBarGroups() end,
								},
								ForegroundBrightness = {
									type = "range", order = 25, name = L["Foreground Brightness"], min = -1, max = 1, step = 0.05,
									desc = L["Set brightness for foreground colors."],
									get = function(info) return MOD.db.global.Defaults.fgBrightness end,
									set = function(info, value) MOD.db.global.Defaults.fgBrightness = value; MOD:UpdateAllBarGroups() end,
								},
								Space1 = { type = "description", name = "", order = 30 },
								BackgroundTexture = {
									type = "select", order = 35, name = L["Bar Background Texture"], 
									desc = L["Select background texture for bars."],
									dialogControl = 'LSM30_Statusbar',
									values = AceGUIWidgetLSMlists.statusbar,
									get = function(info) return MOD.db.global.Defaults.bgtexture end,
									set = function(info, value) MOD.db.global.Defaults.bgtexture = value; MOD:UpdateAllBarGroups() end,
								},
								BackgroundAlpha = {
									type = "range", order = 40, name = L["Background Opacity"], min = 0, max = 1, step = 0.05,
									desc = L["Set background opacity for bars."],
									get = function(info) return MOD.db.global.Defaults.bgAlpha end,
									set = function(info, value) MOD.db.global.Defaults.bgAlpha = value; MOD:UpdateAllBarGroups() end,
								},
								BackgroundSaturation = {
									type = "range", order = 45, name = L["Background Saturation"], min = -1, max = 1, step = 0.05,
									desc = L["Set saturation for background colors."],
									get = function(info) return MOD.db.global.Defaults.bgSaturation end,
									set = function(info, value) MOD.db.global.Defaults.bgSaturation = value; MOD:UpdateAllBarGroups() end,
								},
								BackgroundBrightness = {
									type = "range", order = 50, name = L["Background Brightness"], min = -1, max = 1, step = 0.05,
									desc = L["Set brightness for background colors."],
									get = function(info) return MOD.db.global.Defaults.bgBrightness end,
									set = function(info, value) MOD.db.global.Defaults.bgBrightness = value; MOD:UpdateAllBarGroups() end,
								},
								Space2 = { type = "description", name = "", order = 55 },
								NormalAlpha = {
									type = "range", order = 60, name = L["Opacity (Not Combat)"], min = 0, max = 1, step = 0.05,
									desc = L["Set opacity for bars/icons when not in combat."],
									get = function(info) return MOD.db.global.Defaults.alpha end,
									set = function(info, value) MOD.db.global.Defaults.alpha = value; MOD:UpdateAllBarGroups() end,
								},
								CombatAlpha = {
									type = "range", order = 65, name = L["Opacity (In Combat)"], min = 0, max = 1, step = 0.05,
									desc = L["Set opacity for bars/icons when in combat."],
									get = function(info) return MOD.db.global.Defaults.combatAlpha end,
									set = function(info, value) MOD.db.global.Defaults.combatAlpha = value; MOD:UpdateAllBarGroups() end,
								},
								IconBorderSaturation = {
									type = "range", order = 70, name = L["Icon Border Saturation"], min = -1, max = 1, step = 0.05,
									desc = L["Set saturation for icon border colors."],
									get = function(info) return MOD.db.global.Defaults.borderSaturation end,
									set = function(info, value) MOD.db.global.Defaults.borderSaturation = value; MOD:UpdateAllBarGroups() end,
								},
								IconBorderBrightness = {
									type = "range", order = 75, name = L["Icon Border Brightness"], min = -1, max = 1, step = 0.05,
									desc = L["Set brightness for icon border colors."],
									get = function(info) return MOD.db.global.Defaults.borderBrightness end,
									set = function(info, value) MOD.db.global.Defaults.borderBrightness = value; MOD:UpdateAllBarGroups() end,
								},
							},
						},
						ResetFonts = {
							type = "execute", order = 109, name = L["Reset Fonts/Textures"],
							desc = L["Reset fonts and textures to default settings."],
							confirm = function(info) return L["RESET FONTS/TEXTURES\nAre you sure you want to reset the font and texture options?"] end,
							func = function(info) MOD:SetFontTextureDefaults(MOD.db.global.Defaults); MOD:UpdateAllBarGroups() end,
						},
					},
				},
				ColorsGroup = {
					type = "group", order = 30, name = L["Standard Colors"], inline = true,
					args = {
						ColorText = { type = "description", name = L["Bar Colors:"], order = 1, width = "half" },
						NotificationColor = {
							type = "color", order = 10, name = L["Notify"], hasAlpha = false, width = "half",
							get = function(info) local t = MOD.db.global.DefaultNotificationColor; return t.r, t.g, t.b, t.a end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.DefaultNotificationColor
								t.r = r; t.g = g; t.b = b; t.a = a
								MOD:UpdateAllBarGroups()
							end,
						},
						BuffColor = {
							type = "color", order = 11, name = L["Buff"], hasAlpha = false, width = "half",
							get = function(info) local t = MOD.db.global.DefaultBuffColor; return t.r, t.g, t.b, t.a end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.DefaultBuffColor
								t.r = r; t.g = g; t.b = b; t.a = a
								MOD:UpdateAllBarGroups()
							end,
						},
						DebuffColor = {
							type = "color", order = 12, name = L["Debuff"], hasAlpha = false, width = "half",
							get = function(info) local t = MOD.db.global.DefaultDebuffColor; return t.r, t.g, t.b, t.a end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.DefaultDebuffColor
								t.r = r; t.g = g; t.b = b; t.a = a
								MOD:UpdateAllBarGroups()
							end,
						},
						CooldownColor = {
							type = "color", order = 13, name = L["Cooldown"], hasAlpha = false,
							get = function(info) local t = MOD.db.global.DefaultCooldownColor; return t.r, t.g, t.b, t.a end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.DefaultCooldownColor
								t.r = r; t.g = g; t.b = b; t.a = a
								MOD:UpdateAllBarGroups()
							end,
						},
						Space0 = { type = "description", name = "", order = 14 },
						DebuffText = { type = "description", name = L["Debuff Colors:"], order = 15, width = "half" },
						PoisonColor = {
							type = "color", order = 15, name = L["Poison"], hasAlpha = false, width = "half",
							get = function(info) local t = MOD.db.global.DefaultPoisonColor; return t.r, t.g, t.b, t.a end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.DefaultPoisonColor
								t.r = r; t.g = g; t.b = b; t.a = a
								MOD:UpdateAllBarGroups()
							end,
						},
						CurseColor = {
							type = "color", order = 16, name = L["Curse"], hasAlpha = false, width = "half",
							get = function(info) local t = MOD.db.global.DefaultCurseColor; return t.r, t.g, t.b, t.a end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.DefaultCurseColor
								t.r = r; t.g = g; t.b = b; t.a = a
								MOD:UpdateAllBarGroups()
							end,
						},
						MagicColor = {
							type = "color", order = 17, name = L["Magic"], hasAlpha = false, width = "half",
							get = function(info) local t = MOD.db.global.DefaultMagicColor; return t.r, t.g, t.b, t.a end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.DefaultMagicColor
								t.r = r; t.g = g; t.b = b; t.a = a
								MOD:UpdateAllBarGroups()
							end,
						},
						DiseaseColor = {
							type = "color", order = 18, name = L["Disease"], hasAlpha = false, width = "half",
							get = function(info) local t = MOD.db.global.DefaultDiseaseColor; return t.r, t.g, t.b, t.a end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.DefaultDiseaseColor
								t.r = r; t.g = g; t.b = b; t.a = a
								MOD:UpdateAllBarGroups()
							end,
						},
						Space2 = { type = "description", name = "", order = 80 },
						ResetBarColors = {
							type = "execute", order = 85, name = L["Reset Bar Colors"],
							desc = L["Reset bar colors back to default."],
							confirm = function(info) return (L["RESET BAR COLORS\nAre you sure you want to reset bar colors back to default?"]) end,
							func = function(info)
								MOD.db.global.DefaultBuffColor = Raven_HexColor("8ae234") -- Green1
								MOD.db.global.DefaultDebuffColor = Raven_HexColor("fcaf3e") -- Orange1
								MOD.db.global.DefaultCooldownColor = Raven_HexColor("fce94f") -- Yellow1
								MOD.db.global.DefaultNotificationColor = Raven_HexColor("729fcf") -- Blue1								
							end,
						},
						ResetDebuffColors = {
							type = "execute", order = 86, name = L["Reset Debuff Colors"],
							desc = L["Reset debuff colors back to default."],
							confirm = function(info) return (L["RESET DEBUFF COLORS\nAre you sure you want to reset debuff colors back to default?"]) end,
							func = function(info)
								MOD.db.global.DefaultPoisonColor = Raven_CopyColor(DebuffTypeColor["Poison"])
								MOD.db.global.DefaultCurseColor = Raven_CopyColor(DebuffTypeColor["Curse"])
								MOD.db.global.DefaultMagicColor = Raven_CopyColor(DebuffTypeColor["Magic"])
								MOD.db.global.DefaultDiseaseColor = Raven_CopyColor(DebuffTypeColor["Disease"])						
							end,
						},
					},
				},
				OmniCCGroup = {
					type = "group", order = 40, name = L["OmniCC"], inline = true,
					hidden = function(info) return not OmniCC end,
					args = {
						Enable = {
							type = "toggle", order = 10, name = L["Hide OmniCC"],
							desc = L["If checked, OmniCC counts are hidden on icons in all bar groups (requires /reload)."],
							get = function(info) return MOD.db.global.HideOmniCC end,
							set = function(info, value) MOD.db.global.HideOmniCC = value; MOD:UpdateAllBarGroups() end,
						},
					},
				},
				TukuiGroup = {
					type = "group", order = 50, name = L["Tukui"], inline = true,
					hidden = function(info) return not Raven.frame.SetTemplate end, -- check if Tukui frame API installed
					args = {
						Enable = {
							type = "toggle", order = 10, name = L["Enable"],
							desc = L["If checked, icons and bars are skinned with Tukui borders (requires /reload)."],
							get = function(info) return MOD.db.global.TukuiSkin end,
							set = function(info, value) MOD.db.global.TukuiSkin = value; MOD:UpdateAllBarGroups() end,
						},
						Font = {
							type = "toggle", order = 20, name = L["Font"],
							disabled = function(info) return not MOD.db.global.TukuiSkin end,
							desc = L["If checked, fonts are replaced with Tukui's normal font (requires /reload)."],
							get = function(info) return MOD.db.global.TukuiFont end,
							set = function(info, value) MOD.db.global.TukuiFont = value; MOD:UpdateAllBarGroups() end,
						},
						Scale = {
							type = "toggle", order = 20, name = L["Pixel Perfect"],
							disabled = function(info) return not MOD.db.global.TukuiSkin end,
							desc = L["If checked, icons and bars will be adjusted for pixel perfect size and position (requires /reload)."],
							get = function(info) return MOD.db.global.TukuiScale end,
							set = function(info, value) MOD.db.global.TukuiScale = value; MOD:UpdateAllBarGroups() end,
						},
					},
				},
				ButtonFacadeGroup = {
					type = "group", order = 60, name = L["Masque"], inline = true,
					hidden = function(info) return not MOD.MSQ end,
					args = {
						Enable = {
							type = "toggle", order = 1, name = L["Enable"], width = "half",
							desc = L["If checked, custom borders are automatically hidden and icons are skinned with Masque (requires /reload)."],
							get = function(info) return MOD.db.global.ButtonFacadeIcons end,
							set = function(info, value) MOD.db.global.ButtonFacadeIcons = value; MOD:UpdateAllBarGroups() end,
						},
						NormalTexture = {
							type = "toggle", order = 10, name = L["Color Normal Texture"],
							disabled = function(info) return not MOD.db.global.ButtonFacadeIcons end,
							desc = L["If checked, icon border color is applied to the normal texture."],
							get = function(info) return MOD.db.global.ButtonFacadeNormal end,
							set = function(info, value) MOD.db.global.ButtonFacadeNormal = value; MOD:UpdateAllBarGroups() end,
						},
						BorderTexture = {
							type = "toggle", order = 20, name = L["Color Border Texture"],
							disabled = function(info) return not MOD.db.global.ButtonFacadeIcons end,
							desc = L["If checked, icon border color is applied to the border texture."],
							get = function(info) return MOD.db.global.ButtonFacadeBorder end,
							set = function(info, value) MOD.db.global.ButtonFacadeBorder = value; MOD:UpdateAllBarGroups() end,
						},
					},
				},
				CustomBorderGroup = {
					type = "group", order = 70, name = L["Skin Options"], inline = true,
					args = {
						Border = {
							type = "toggle", order = 10, name = L["Hide Custom Border"],
							disabled = function(info) return (MOD.MSQ and MOD.db.global.ButtonFacadeIcons) or (Raven.frame.SetTemplate and MOD.db.global.TukuiSkin) end,
							desc = L["By default, icons are displayed with a custom border and can be informatively colored using settings in the bar group Appearance tab. If this option is checked then custom borders are hidden."],
							get = function(info) return MOD.db.global.HideBorder end,
							set = function(info, value) MOD.db.global.HideBorder = value; MOD:UpdateAllBarGroups() end,
						},
						Trim = {
							type = "toggle", order = 20, name = L["Trim Icon Texture"],
							disabled = function(info) return (MOD.MSQ and MOD.db.global.ButtonFacadeIcons) or (Raven.frame.SetTemplate and MOD.db.global.TukuiSkin)
								or not MOD.db.global.HideBorder end,
							desc = L["When hiding custom borders, the full icon texture is displayed by default but when this option is enabled the texture is trimmed to remove the outer edge."],
							get = function(info) return MOD.db.global.TrimIcon end,
							set = function(info, value) MOD.db.global.TrimIcon = value; MOD:UpdateAllBarGroups() end,
						},
						Scale = {
							type = "toggle", order = 30, name = L["Pixel Perfect"],
							disabled = function(info) return (Raven.frame.SetTemplate and MOD.db.global.TukuiSkin) end,
							desc = L["If checked, icons and bars will be adjusted for pixel perfect size and position (requires /reload)."],
							get = function(info) return MOD.db.global.PixelPerfect end,
							set = function(info, value) MOD.db.global.PixelPerfect = value; MOD:UpdateAllBarGroups() end,
						},
						Rect = {
							type = "toggle", order = 40, name = L["Rectangular Icons"],
							desc = L["If checked, allow rectangular icons in icon-oriented configurations, using bar width to set icon's width (requires /reload)."],
							get = function(info) return MOD.db.global.RectIcons end,
							set = function(info, value) MOD.db.global.RectIcons = value; MOD:UpdateAllBarGroups() end,
						},
						DefaultBorderColor = {
							type = "color", order = 50, name = L["Default Border Color"], hasAlpha = false,
							disabled = function(info) return (Raven.frame.SetTemplate and MOD.db.global.TukuiSkin) end,
							desc = L["Set default color for icon borders."],
							get = function(info) local t = MOD.db.global.DefaultBorderColor; return t.r, t.g, t.b, t.a end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.DefaultBorderColor
								t.r = r; t.g = g; t.b = b; t.a = a
								MOD:UpdateAllBarGroups()
							end,
						},
					},
				},
				SoundGroup = {
					type = "group", order = 80, name = L["Sound Channel"], inline = true,
					args = {
						Master = {
							type = "toggle", order = 10, name = L["Master"], width = "half",
							desc = L["If checked, sound is played in Master channel."],
							get = function(info) return MOD.db.global.SoundChannel == "Master" end,
							set = function(info, value) MOD.db.global.SoundChannel = "Master" end,
						},
						SFX = {
							type = "toggle", order = 20, name = L["SFX"], width = "half",
							desc = L["If checked, sound is played in SFX channel."],
							get = function(info) return MOD.db.global.SoundChannel == "SFX" end,
							set = function(info, value) MOD.db.global.SoundChannel = "SFX" end,
						},
						Music = {
							type = "toggle", order = 30, name = L["Music"], width = "half",
							desc = L["If checked, sound is played in Music channel."],
							get = function(info) return MOD.db.global.SoundChannel == "Music" end,
							set = function(info, value) MOD.db.global.SoundChannel = "Music" end,
						},
						Ambience = {
							type = "toggle", order = 40, name = L["Ambience"],
							desc = L["If checked, sound is played in Ambience channel."],
							get = function(info) return MOD.db.global.SoundChannel == "Ambience" end,
							set = function(info, value) MOD.db.global.SoundChannel = "Ambience" end,
						},
					},
				},
			},
		},
		Spells = {
			type = "group", order = 20, name = L["Spells"], childGroups = "tab",
			disabled = function(info) return InMode() end,
			args = {
				Spells = {
					type = "description", order = 10,
					name = L["Spells string"],
				},
				ColorsGroup = {
					type = "group", order = 20, name = L["Colors and Labels"], inline = true,
					args = {
						SpellName = {
							type = "input", order = 30, name = L["Spell Name"],
							desc = L["Enter a spell name (or numeric identifier, optionally preceded by # for a specific spell id)."],
							get = function(info) return conditions.name end,
							set = function(info, n) n = ValidateSpellName(n); conditions.name = n end,
						},
						StandardColors = {
							type = "select", order = 40, name = L["Color"], width = "half",
							desc = L["Select a standard color or click to set a custom color."],
							disabled = function(info) return not conditions.name or (conditions.name == "") end,
							get = function(info) return nil end,
							set = function(info, value)
								if MOD:GetIcon(conditions.name) then -- make sure this is a valid spell before setting a color in save table
									local t = {}
									t.r, t.g, t.b, t.a = GetStandardColor(value)
									MOD:SetColor(conditions.name, t)
									MOD:UpdateAllBarGroups()
								end
							end,
							values = function(info) return GetStandardColorList() end,
							style = "dropdown",
						},
						SpellColor = {
							type = "color", order = 50, name = "", hasAlpha = false, width = "half",
							disabled = function(info) return not conditions.name or (conditions.name == "") end,
							get = function(info)
								local t = MOD:GetColor(conditions.name)
								if not t then return nil end
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								if MOD:GetIcon(conditions.name) then -- make sure this is a valid spell before setting a color in save table
									local t = {}
									t.r = r; t.g = g; t.b = b; t.a = a
									MOD:SetColor(conditions.name, t)
									MOD:UpdateAllBarGroups()
								end
							end,
						},
						SpellIcon = {
							type = "description", order = 51, name = "", width = "half", 
							disabled = function(info) return not conditions.name or (conditions.name == "") end,
							image = function(info) return MOD:GetIcon(conditions.name) end,
							imageWidth = 24, imageHeight = 24,
						},
						Space1 = { type = "description", name = "", order = 52 },
						SpellLabel = {
							type = "input", order = 55, name = L["Spell Label"],
							desc = L["Enter a label to be used by default with this spell."],
							get = function(info) return MOD:GetLabel(conditions.name) end,
							set = function(info, value) MOD:SetLabel(conditions.name, value) end,
						},
						SpellIconName = {
							type = "input", order = 56, name = L["Spell Icon"],
							desc = L["Enter a spell name (or numeric identifier, optionally preceded by # for a specific spell id) for an icon to be used by default with this spell."],
							get = function(info) return conditions.name and MOD.db.global.SpellIcons[conditions.name] or nil end,
							set = function(info, n) n = ValidateSpellName(n); MOD.db.global.SpellIcons[conditions.name] = n end,
						},
						SpellSound = {
							type = "select", order = 57, name = L["Spell Sound"], 
							desc = L["Select sound to associate with the spell."],
							dialogControl = 'LSM30_Sound',
							values = AceGUIWidgetLSMlists.sound,
							get = function(info) return MOD:GetSound(conditions.name) end,
							set = function(info, value) MOD:SetSound(conditions.name, value) end,
						},
						Space2 = { type = "description", name = "", order = 80 },
						ResetSpellColors = {
							type = "execute", order = 85, name = L["Reset Colors"],
							desc = L["Reset spell colors back to defaults."],
							confirm = function(info) return L["RESET SPELL COLORS\nAre you sure you want to reset all spell colors back to defaults?"] end,
							func = function(info) MOD:ResetColorDefaults(); MOD:UpdateAllBarGroups() end,
						},
						ResetSpellLabels = {
							type = "execute", order = 87, name = L["Reset Labels"],
							desc = L["Reset spell labels back to defaults."],
							confirm = function(info) return L["RESET SPELL LABELS\nAre you sure you want to reset all spell labels back to defaults?"] end,
							func = function(info) MOD:ResetLabelDefaults(); MOD:UpdateAllBarGroups() end,
						},
						ResetSpellIcons = {
							type = "execute", order = 88, name = L["Reset Icons"],
							desc = L["Reset spell icons back to defaults."],
							confirm = function(info) return L["RESET SPELL ICONS\nAre you sure you want to reset all spell icons back to defaults?"] end,
							func = function(info) MOD:ResetIconDefaults(); MOD:UpdateAllBarGroups() end,
						},
						ResetSpellSounds = {
							type = "execute", order = 89, name = L["Reset Sounds"],
							desc = L["Reset spell sounds back to defaults."],
							confirm = function(info) return L["RESET SPELL SOUNDS\nAre you sure you want to reset all spell sounds back to defaults?"] end,
							func = function(info) MOD:ResetSoundDefaults(); MOD:UpdateAllBarGroups() end,
						},
						Space3 = { type = "description", name = "", order = 90, width = "half" },
						ResetSpellColor = {
							type = "execute", order = 95, name = L["Reset"], width = "half",
							desc = function(info) return L["Reset color and label string"](conditions.name) end,
							hidden = function(info) return not conditions.name or (conditions.name == "") end,
							confirm = function(info) return L["Reset color and label confirm"](conditions.name) end,
							func = function(info)
								if MOD:GetIcon(conditions.name) then -- make sure this is a valid spell name before changing the color
									MOD:ResetColorDefault(conditions.name)
									MOD:SetLabel(conditions.name, conditions.name)
									MOD:SetSound(conditions.name, nil)
									MOD:UpdateAllBarGroups()
								end
							end,
						},
					},
				},
				SpellLists = {
					type = "group", order = 25, name = L["Spell Lists"], inline = true,
					args = {
						SelectList = {
							type = "select", order = 10, name = L["Spell List"],
							get = function(info) return GetSelectedSpellList() end,
							set = function(info, value) SetSelectedSpellList(value) end,
							disabled = function(info) return lists.enter end,
							values = function(info) return GetSpellList() end,
							style = "dropdown",
						},
						NewList = {
							type = "execute", order = 15, name = L["New Spell List"],
							desc = L["Create a new spell list."],
							hidden = function(info) return lists.enter end,
							func = function(info) lists.enter, lists.toggle = true, true end,
						},
						NewSpellList = {
							type = "input", order = 20, name = L["Enter Spell List Name"],
							desc = L["Enter name for a new spell list."],
							hidden = function(info) return not lists.enter end,
							get = function(info)
								lists.enter = lists.toggle
								if lists.toggle then lists.toggle = false end
								if not lists.enter then MOD:UpdateOptions() end
								return false
							end,
							set = function(info, value) lists.enter = false; AddNewSpellList(value) end,
						},
						CancelNewSpellList = {
							type = "execute", order = 21, name = L["Cancel"], width = "half",
							desc = L["Cancel creating a new spell list."],
							hidden = function(info) return not lists.enter end,
							func = function(info) lists.enter, lists.toggle = false, false end,
						},
						DeleteSpellList = {
							type = "execute", order = 25, name = L["Delete Spell List"],
							desc = L["Delete the selected spell list."],
							hidden = function(info) return lists.enter end,
							func = function(info) DeleteSpellList() end,
							confirm = function(info) return L["Delete spell list string"] end,
						},
						SpellListGroup = {
							type = "group", order = 30, name = L["Settings"], inline = true,
							disabled = function(info) return lists.enter or not lists.select or not lists.list end,
							args = {
								AddSpell = {
									type = "input", order = 10, name = L["Enter Spell"],
									desc = L["Enter a spell name (or numeric identifier, optionally preceded by # for a specific spell id) to be added to the list."],
									get = function(info) return nil end,
									set = function(info, n) n = ValidateSpellName(n, true)
										if n and lists.list then lists.list[n] = MOD:GetSpellID(n) or true; lists.spell = n end end,
								},
								SelectSpell = {
									type = "select", order = 20, name = L["Spell List"],
									get = function(info) return GetSortedListEntry(lists.list, lists.spell) end,
									set = function(info, value) lists.spell = GetSortedList(lists.list)[value] end,
									values = function(info) return GetSortedList(lists.list) end,
									style = "dropdown",
								},
								DeleteSpell = {
									type = "execute", order = 30, name = L["Delete"], width = "half",
									desc = L["Delete the selected spell from the list."],
									func = function(info) if lists.list and lists.spell then lists.list[lists.spell] = nil; lists.spell = nil end end,
								},
								ResetList = {
									type = "execute", order = 40, name = L["Reset"], width = "half",
									desc = L["Reset the spell list."],
									confirm = function(info) return L['RESET\nAre you sure you want to reset the spell list?'] end,
									func = function(info) if lists.list then table.wipe(lists.list); lists.spell = nil end end,
								},
								SpellIcon = {
									type = "description", order = 50, name = "", width = "half", 
									image = function(info) return MOD:GetIcon(lists.spell) end,
									imageWidth = 24, imageHeight = 24,
								},
							},
						},
					},
				},
				InternalCooldowns = {
					type = "group", order = 30, name = L["Internal Cooldowns Triggered By Buffs/Debuffs/Heals"], inline = true,
					args = {
						EnableCooldowns = {
							type = "toggle", order = 1, name = L["Enable"],
							desc = L["Enable detecting internal cooldowns."],
							get = function(info) return MOD.db.global.DetectInternalCooldowns end,
							set = function(info, value) MOD.db.global.DetectInternalCooldowns = value end,
						},
						Space = { type = "description", name = "", order = 5 },
						SelectCooldown = {
							type = "select", order = 10, name = L["Cooldown List"],
							get = function(info) return GetSelectedInternalCooldown() end,
							set = function(info, value) SetSelectedInternalCooldown(value) end,
							disabled = function(info) return cooldowns.enter end,
							values = function(info) return GetInternalCooldownList() end,
							style = "dropdown",
						},
						NewCooldown = {
							type = "execute", order = 15, name = L["New Cooldown"],
							desc = L["Enter a new internal cooldown triggered by a buff, debuff or heal spell."],
							hidden = function(info) return cooldowns.enter end,
							func = function(info) cooldowns.enter, cooldowns.toggle = true, true end,
						},
						NewCooldownSpell = {
							type = "input", order = 20, name = L["Enter Spell Name or ID"],
							desc = L["Enter spell name or numeric identifier for new internal cooldown."],
							hidden = function(info) return not cooldowns.enter end,
							validate = function(info, n) if not n or (n == "") or not (tonumber(n) or MOD:GetSpellID(n)) then return L["Invalid name."] else return true end end,
							get = function(info)
								cooldowns.enter = cooldowns.toggle
								if cooldowns.toggle then cooldowns.toggle = false end
								if not cooldowns.enter then MOD:UpdateOptions() end
								return false
							end,
							set = function(info, value) cooldowns.enter = false; AddNewInternalCooldown(value) end,
						},
						CancelNewCooldown = {
							type = "execute", order = 21, name = L["Cancel"], width = "half",
							desc = L["Cancel creating a new internal cooldown."],
							hidden = function(info) return not cooldowns.enter end,
							func = function(info) cooldowns.enter, cooldowns.toggle = false, false end,
						},
						DeleteCooldown = {
							type = "execute", order = 25, name = L["Delete Cooldown"],
							desc = L["Delete the selected internal cooldown."],
							hidden = function(info) return cooldowns.enter end,
							func = function(info) DeleteInternalCooldown() end,
							confirm = function(info) return L["Delete cooldown string"] end,
						},
						CooldownGroup = {
							type = "group", order = 30, name = L["Settings"], inline = true,
							disabled = function(info) return cooldowns.enter or not cooldowns.select end,
							args = {
								EnableCooldown = {
									type = "toggle", order = 1, name = L["Enable"], width = "half",
									desc = L["Enable detecting this internal cooldown."],
									get = function(info) return not cooldowns.disable end,
									set = function(info, value) cooldowns.disable = not value; SetInternalCooldownSettings() end,
								},
								Duration = {
									type = "input", order = 10, name = L["Duration"],
									desc = L["Enter duration in seconds."],
									get = function(info) return cooldowns.duration and tostring(cooldowns.duration) or "" end,
									set = function(info, value) cooldowns.duration = tonumber(value); SetInternalCooldownSettings() end,
								},
								SpellIcon = {
									type = "description", order = 20, name = "", width = "half", 
									image = function(info) return MOD:GetIcon(cooldowns.select) end,
									imageWidth = 24, imageHeight = 24,
								},
								SpellList = {
									type = "input", order = 40, name = L["Reset List"], width = "double",
									desc = L["Enter comma-separated list of buff, debuff or heal spell names (or numeric identifiers) that reset the internal cooldown."],
									get = function(info) return GetListString(cooldowns.cancel) end,
									set = function(info, v) cooldowns.cancel = GetListTable(v, "spells"); SetInternalCooldownSettings() end,
								},
								Space = { type = "description", name = "", order = 50 },
								DoPlayer = {
									type = "toggle", order = 55, name = L["Cast By Player"],
									desc = L["If checked, test if buff, debuff or heal spell was cast by the player."],
									get = function(info) return not cooldowns.caster end,
									set = function(info, value) cooldowns.caster = nil; SetInternalCooldownSettings() end,
								},
								DoOther = {
									type = "toggle", order = 60, name = L["Cast On Player"],
									desc = L["If checked, test if buff, debuff or heal spell is on player and cast by anyone other than the player."],
									get = function(info) return cooldowns.caster end,
									set = function(info, value) cooldowns.caster = true; SetInternalCooldownSettings() end,
								},
							},
						},
					},
				},
				SpellEffectTimers = {
					type = "group", order = 40, name = L["Effect Timers Triggered By Spell Casts"], inline = true,
					args = {
						EnableSpellEffects = {
							type = "toggle", order = 1, name = L["Enable"],
							desc = L["Enable detecting spell effects."],
							get = function(info) return MOD.db.global.DetectSpellEffects end,
							set = function(info, value) MOD.db.global.DetectSpellEffects = value end,
						},
						Space = { type = "description", name = "", order = 5 },
						SelectSpell = {
							type = "select", order = 10, name = L["Spell Effect List"],
							get = function(info) return GetSelectedSpellEffect() end,
							set = function(info, value) SetSelectedSpellEffect(value) end,
							disabled = function(info) return effects.enter end,
							values = function(info) return GetSpellEffectList() end,
							style = "dropdown",
						},
						NewSpellEffect = {
							type = "execute", order = 15, name = L["New Spell Effect"],
							desc = L["Enter a new spell effect triggered by a successful spell cast."],
							hidden = function(info) return effects.enter end,
							func = function(info) effects.enter, effects.toggle = true, true end,
						},
						NewSpell = {
							type = "input", order = 20, name = L["Enter Spell Name or ID"],
							desc = L["Enter spell name or numeric identifier that, when cast, will trigger a new spell effect."],
							hidden = function(info) return not effects.enter end,
							validate = function(info, n) if not n or (n == "") or not (tonumber(n) or MOD:GetSpellID(n)) then return L["Invalid name."] else return true end end,
							get = function(info)
								effects.enter = effects.toggle
								if effects.toggle then effects.toggle = false end
								if not effects.enter then MOD:UpdateOptions() end
								return false
							end,
							set = function(info, value) effects.enter = false; AddNewSpellEffect(value) end,
						},
						CancelNewSpell = {
							type = "execute", order = 21, name = L["Cancel"], width = "half",
							desc = L["Cancel creating a new spell effect."],
							hidden = function(info) return not effects.enter end,
							func = function(info) effects.enter, effects.toggle = false, false end,
						},
						DeleteSpell = {
							type = "execute", order = 25, name = L["Delete Spell Effect"],
							desc = L["Delete the selected spell effect."],
							hidden = function(info) return effects.enter end,
							func = function(info) DeleteSpellEffect() end,
							confirm = function(info) return L["Delete effect string"] end,
						},
						SpellEffectGroup = {
							type = "group", order = 30, name = L["Settings"], inline = true,
							disabled = function(info) return effects.enter or not effects.select end,
							args = {
								EnableEffect = {
									type = "toggle", order = 1, name = L["Enable"], width = "half",
									desc = L["Enable detecting this spell effect."],
									get = function(info) return not effects.disable end,
									set = function(info, value) effects.disable = not value; SetSpellEffectSettings() end,
								},
								Duration = {
									type = "input", order = 5, name = L["Duration"],
									desc = L["Enter duration in seconds."],
									get = function(info) return effects.duration and tostring(effects.duration) or "" end,
									set = function(info, value) effects.duration = tonumber(value); SetSpellEffectSettings() end,
								},
								RenewEffect = {
									type = "toggle", order = 10, name = L["Renew"], width = "half",
									desc = L["If checked, spell effect is renewed if spell is cast again while effect is active."],
									get = function(info) return effects.renew end,
									set = function(info, value) effects.renew = value; SetSpellEffectSettings() end,
								},
								LabelEffect = {
									type = "toggle", order = 11, name = L["Label"], width = "half", 
									desc = L["If checked, include name of caster in the label if spell effect is a buff or debuff."],
									get = function(info) return effects.label end,
									set = function(info, value) effects.label = value; SetSpellEffectSettings() end,
								},
								Space1 = { type = "description", name = "", order = 15 },
								AssociatedSpell = {
									type = "input", order = 20, name = L["Associated Spell"],
									desc = L["Enter spell name or numeric identifier for spell to be associated with this effect (default is to use spell that triggers the effect)."],
									get = function(info) return effects.spell end,
									set = function(info, n) n = ValidateSpellName(n); effects.spell = n; SetSpellEffectSettings() end,
								},
								SpellIcon = {
									type = "description", order = 25, name = "", width = "half", 
									image = function(info) return MOD:GetIcon(effects.spell or effects.select) end,
									imageWidth = 24, imageHeight = 24,
								},
								BuffEffect = {
									type = "toggle", order = 30, name = L["Buff"], width = "half",
									desc = L["If checked, spell effect is a buff."],
									get = function(info) return not effects.kind end,
									set = function(info, value) effects.kind = nil; SetSpellEffectSettings() end,
								},
								DebuffEffect = {
									type = "toggle", order = 35, name = L["Debuff"], width = "half",
									desc = L["If checked, spell effect is a debuff."],
									get = function(info) return effects.kind == "debuff" end,
									set = function(info, value) effects.kind = "debuff"; SetSpellEffectSettings() end,
								},
								CooldownEffect = {
									type = "toggle", order = 40, name = L["Cooldown"],
									desc = L["If checked, spell effect is a cooldown."],
									get = function(info) return effects.kind == "cooldown" end,
									set = function(info, value) effects.kind = "cooldown"; SetSpellEffectSettings() end,
								},
								Space2 = { type = "description", name = "", order = 45 },
								AssociatedBuff = {
									type = "input", order = 50, name = L["Required Buff"],
									desc = L["Enter name or numeric identifier for buff required to be active on player for effect to happen (leave blank if no buff required)."],
									get = function(info) return effects.buff end,
									set = function(info, n) n = ValidateSpellName(n); effects.buff = n; SetSpellEffectSettings() end,
								},
								AssociatedTalent = {
									type = "input", order = 55, name = L["Required Talent"],
									desc = L["Enter name or numeric identifier for talent required for effect to happen (leave blank if no talent required)."],
									get = function(info) return effects.talent end,
									set = function(info, n) n = ValidateSpellName(n); effects.talent = n; SetSpellEffectSettings() end,
								},
								AssociatedCondition = {
									type = "input", order = 60, name = L["Required Condition"],
									desc = L["Enter name of condition required to be true for effect to happen (leave blank if no condition required)."],
									get = function(info) return effects.condition end,
									set = function(info, value) local n = value; if n == "" then n = nil end; effects.condition = n; SetSpellEffectSettings() end,
								},
								Space3 = { type = "description", name = "", order = 61 },
								OptionalBuff = {
									type = "input", order = 62, name = L["Optional Buff"],
									desc = L["Enter name or numeric identifier for buff that changes the duration of the effect when active on player (leave blank if no buff required)."],
									get = function(info) return effects.optbuff end,
									set = function(info, n) n = ValidateSpellName(n); effects.optbuff = n; SetSpellEffectSettings() end,
								},
								OptionalDuration = {
									type = "input", order = 63, name = L["Optional Duration"],
									desc = L["Enter duration of spell effect when optional buff is active on player."],
									get = function(info) return effects.optduration and tostring(effects.optduration) or "" end,
									set = function(info, value) effects.optduration = tonumber(value); SetSpellEffectSettings() end,
								},
								CastUnitGroup = {
									type = "group", order = 65, name = L["Cast By"], inline = true, width = "full",
									args = {
										MyBuff = {
											type = "toggle", order = 10, name = L["Player"],
											desc = L["If checked, spell must be cast by the player to trigger the spell effect."],
											get = function(info) return not effects.caster end,
											set = function(info, value) effects.caster = nil; SetSpellEffectSettings() end,
										},
										PetBuff = {
											type = "toggle", order = 15, name = L["Pet"],
											desc = L["If checked, spell must be cast by the player's pet to trigger the spell effect."],
											get = function(info) return effects.caster == "pet" end,
											set = function(info, value) effects.caster = "pet"; SetSpellEffectSettings() end,
										},
										TargetBuff = {
											type = "toggle", order = 20, name = L["Target"],
											desc = L["If checked, spell must be cast by the target to trigger the spell effect."],
											get = function(info) return effects.caster == "target" end,
											set = function(info, value) effects.caster = "target"; SetSpellEffectSettings() end,
										},
										FocusBuff = {
											type = "toggle", order = 25, name = L["Focus"],
											desc = L["If checked, spell must be cast by the focus to trigger the spell effect."],
											get = function(info) return effects.caster == "focus" end,
											set = function(info, value) effects.caster = "focus"; SetSpellEffectSettings() end,
										},
										OurBuff = {
											type = "toggle", order = 27, name = L["Player Or Pet"],
											desc = L["If checked, spell must be cast by the player or pet to trigger the spell effect."],
											get = function(info) return effects.caster == "ours" end,
											set = function(info, value) effects.caster = "ours"; SetSpellEffectSettings() end,
										},
										YourBuff = {
											type = "toggle", order = 30, name = L["Other"],
											desc = L["If checked, spell must be cast by anyone other than the player or pet to trigger the spell effect."],
											get = function(info) return effects.caster == "other" end,
											set = function(info, value) effects.caster = "other"; SetSpellEffectSettings() end,
										},
										AnyBuff = {
											type = "toggle", order = 35, name = L["Anyone"],
											desc = L["If checked, trigger the spell effect if the spell is cast by anyone, including player."],
											get = function(info) return effects.caster == "anyone" end,
											set = function(info, value) effects.caster = "anyone"; SetSpellEffectSettings() end,
										},
									},
								},
							},
						},
					},
				},
			},
		},
		BarGroups = {
			type = "group", order = 25, name = L["Bar Groups"], childGroups = "tab",
			disabled = function(info) return InMode("Not") end,
			args = {
				SelectBarGroup = {
					type = "select", order = 1, name = L["Bar Group"],
					get = function(info) UpdateBarList(); return GetSelectedBarGroup() end,
					set = function(info, value) SetSelectedBarGroup(value) end,
					disabled = function(info) return NoBarGroup() or InMode("Bar") end,
					values = function(info) return GetBarGroupList() end,
					style = "dropdown",
				},
				Space1 = { type = "description", name = "", order = 2, width = "half" },
				NewBarGroupButton = {
					type = "execute", order = 3, name = L["New Custom Group"],
					desc = L["Create a new bar group with manually added bars."],
					disabled = function(info) return InMode("Bar") end,
					hidden = function(info) return bars.enter end,
					func = function(info) bars.enter, bars.toggle, bars.auto = true, true, false end,
				},
				NewAutoBarGroupButton = {
					type = "execute", order = 4, name = L["New Auto Group"],
					desc = L["Create a new bar group with automatically displayed bars."],
					disabled = function(info) return InMode("Bar") end,
					hidden = function(info) return bars.enter end,
					func = function(info) bars.enter, bars.toggle, bars.auto = true, true, true end,
				},
				NewCustomBarGroupName = {
					type = "input", order = 5, name = L["Enter Custom Group Name"],
					desc = L["Enter name of new custom bar group."],
					hidden = function(info) return not bars.enter or bars.auto end,
					validate = function(info, n) if not n or (n == "") then return L["Invalid name."] else return true end end,
					confirm = function(info, value) return ConfirmNewBarGroup(value) end,
					get = function(info)
						bars.enter = bars.toggle; enterNewBarGroupType = false
						if bars.toggle then bars.toggle = false end
						if not bars.enter then MOD:UpdateOptions() end
						return false
					end,
					set = function(info, value) bars.enter = false
						local bg = CreateBarGroup(value, false, false, true, 0, 0); bg.showNoDuration = true
					end,
				},
				NewAutoBarGroupName = {
					type = "input", order = 6, name = L["Enter Auto Group Name"],
					desc = L["Enter name of new auto bar group."],
					hidden = function(info) return not bars.enter or not bars.auto end,
					validate = function(info, n) if not n or (n == "") then return L["Invalid name."] else return true end end,
					confirm = function(info, value) return ConfirmNewBarGroup(value) end,
					get = function(info)
						bars.enter = bars.toggle; enterNewBarGroupType = false
						if bars.toggle then bars.toggle = false end
						if not bars.enter then MOD:UpdateOptions() end
						return false
					end,
					set = function(info, value)
						bars.enter = false
						local bg = CreateBarGroup(value, true, false, true, 0, 0); bg.showNoDuration = true
					end,
				},
				CancelNewBarGroup = {
					type = "execute", order = 7, name = L["Cancel"], width = "half",
					desc = L["Cancel creating a new bar group."],
					hidden = function(info) return not bars.enter end,
					func = function(info) bars.enter, bars.toggle = false, false end,
				},
				DeleteBarGroup = {
					type = "execute", order = 8, name = L["Delete Bar Group"],
					desc = L["Delete the selected bar group."],
					disabled = function(info) return NoBarGroup() or InMode("Bar") end,
					hidden = function(info) return bars.enter end,
					func = function(info) DeleteBarGroup() end,
					confirm = function(info) return L["Delete bar group string"](GetBarGroupField("name")) end,
				},
				GeneralTab = {
					type = "group", order = 10, name = L["General"],
					disabled = function(info) return InMode("Bar") end,
					hidden = function(info) return NoBarGroup() end,
					args = {
						SettingsGroup = {
							type = "group", order = 1, name = L["Settings"], inline = true,
							args = {
								EnableBarGroup = {
									type = "toggle", order = 10, name = L["Enable Bar Group"],
									desc = L["Enable bar group string"],
									get = function(info) return GetBarGroupField("enabled") end,
									set = function(info, value) SetBarGroupField("enabled", value) end,
								},
								LinkSettings = {
									type = "toggle", order = 30, name = L["Link Settings"],
									desc = L["Link settings string"],
									get = function(info) return GetBarGroupField("linkSettings") end,
									set = function(info, value) SetBarGroupField("linkSettings", value) end,
								},
								SaveSettings = {
									type = "execute", order = 40, name = L["Save Settings"],
									hidden = function(info) return GetBarGroupField("linkSettings") end,
									desc = L["Click to save current settings to linked settings."],
									func = function(info) MOD:SaveBarGroupSettings(GetBarGroupEntry()) end,
								},
								LockBars = {
									type = "execute", order = 50, name = L["Lock"], width = "half",
									desc = L["Lock and hide the anchor for the bar group."],
									func = function(info) SetBarGroupField("locked", true) end,
								},
								UnlockBars = {
									type = "execute", order = 55, name = L["Unlock"], width = "half",
									desc = L["Unlock and show the anchor for the bar group."],
									func = function(info) SetBarGroupField("locked", false) end,
								},
								Space1 = { type = "description", name = "", order = 60 },
								Rename = {
									type = "input", order = 65, name = L["Rename Bar Group"],
									validate = function(info, n) if not n or (n == "") then return L["Invalid name."] else return true end end,
									confirm = function(info, value) return ConfirmNewBarGroup(value) end,
									desc = L["Enter new name for the bar group."],
									get = function(info) return GetBarGroupField("name") end,
									set = function(info, value) RenameBarGroup(value) end,
								},
								FrameStrata = {
									type = "select", order = 66, name = L["Frame Strata"],
									desc = L["Frame strata string"],
									disabled = function(info) return GetBarGroupField("merged") end,
									get = function(info) return GetBarGroupField("strata") end,
									set = function(info, value) SetBarGroupField("strata", value) end,
									values = function(info) return stratas end,
									style = "dropdown",
								},
								EnableMerge = {
									type = "toggle", order = 75, name = L["Merge Bar Group"],
									desc = L["Merge bar group string"],
									get = function(info) return GetBarGroupField("merged") end,
									set = function(info, value) SetBarGroupField("merged", value) end,
								},
								MergeBarGroup = {
									type = "select", order = 76, name = L["Bar Group To Merge Into"],
									desc = L["Select a bar group to merge into."],
									disabled = function(info) return not GetBarGroupField("merged") end,
									get = function(info) return GetMergeBarGroup() end,
									set = function(info, value) SetMergeBarGroup(value) end,
									values = function(info) return GetBarGroupList() end,
									style = "dropdown",
								},
							},
						},
						SortingGroup = {
							type = "group", order = 10, name = L["Sort Order"], inline = true,
							hidden = function(info) return GetBarGroupField("merged") end,
							args = {
								AtoZOrder = {
									type = "toggle", order = 10, name = L["A to Z"], width = "half", 
									desc = L["If checked, sort in ascending alphabetical order starting at bar closest to the anchor."],
									get = function(info) return GetBarGroupField("sor") == "A" end,
									set = function(info, value) SetBarGroupField("sor", "A") end,
								},
								TimeLeftOrder = {
									type = "toggle", order = 20, name = L["Time Left"], width = "half", 
									desc = L["If checked, sort by time left in ascending order starting at bar closest to the anchor."],
									get = function(info) return GetBarGroupField("sor") == "T" end,
									set = function(info, value) SetBarGroupField("sor", "T") end,
								},
								DurationOrder = {
									type = "toggle", order = 30, name = L["Duration"], width = "half", 
									desc = L["If checked, sort by overall duration in ascending order starting at bar closest to the anchor."],
									get = function(info) return GetBarGroupField("sor") == "D" end,
									set = function(info, value) SetBarGroupField("sor", "D") end,
								},
								StartOrder = {
									type = "toggle", order = 35, name = L["Creation"], width = "half", 
									desc = L["If checked, show bars in order created with oldest bar closest to the anchor."],
									get = function(info) return GetBarGroupField("sor") == "S" end,
									set = function(info, value) SetBarGroupField("sor", "S") end,
								},
								ClassOrder = {
									type = "toggle", order = 40, name = L["Class"], width = "half", 
									desc = L["If checked, sort by associated class name, if any, in ascending alphabetical order starting at bar closest to the anchor."],
									get = function(info) return GetBarGroupField("sor") == "C" end,
									set = function(info, value) SetBarGroupField("sor", "C") end,
								},
								CustomOrder = {
									type = "toggle", order = 50, name = L["Custom"], width = "half",
									desc = L["If checked, allow manually setting the order of bars."],
									hidden = function(info) return GetBarGroupField("auto") end,
									get = function(info) return GetBarGroupField("sor") == "X" end,
									set = function(info, value) SetBarGroupField("sor", "X") end,
								},
								ReverseSortOrder = {
									type = "toggle", order = 60, name = L["Reverse Order"], 
									desc = L['If checked, reverse the sort order (e.g., "A to Z" becomes "Z to A").'],
									get = function(info) return GetBarGroupField("reverseSort") end,
									set = function(info, value) SetBarGroupField("reverseSort", value) end,
								},
								spacer = { type = "description", name = "", order = 70, },
								TimeSortOrder = {
									type = "toggle", order = 75, name = L["Also Time Left"], 
									desc = L['If checked, before applying selected sort order, first sort by time left.'],
									get = function(info) return GetBarGroupField("timeSort") end,
									set = function(info, value) SetBarGroupField("timeSort", value) end,
								},
								PlayerSortOrder = {
									type = "toggle", order = 80, name = L["Also Player First"], 
									desc = L['If checked, after applying selected sort order, sort bars with actions by player first.'],
									get = function(info) return GetBarGroupField("playerSort") end,
									set = function(info, value) SetBarGroupField("playerSort", value) end,
								},
							},
						},
						ShowWhenGroup = {
							type = "group", order = 20, name = L["Show When"], inline = true,
							args = {
								InCombatGroup = {
									type = "toggle", order = 10, name = L["In Combat"],
									desc = L["If checked, bar group is shown when the player is in combat."],
									get = function(info) return GetBarGroupField("showCombat") end,
									set = function(info, value) SetBarGroupField("showCombat", value) end,
								},
								OutOfCombatGroup = {
									type = "toggle", order = 11, name = L["Out Of Combat"],
									desc = L["If checked, bar group is shown when the player is out of combat."],
									get = function(info) return GetBarGroupField("showOOC") end,
									set = function(info, value) SetBarGroupField("showOOC", value) end,
								},
								RestingGroup = {
									type = "toggle", order = 12, name = L["Resting"],
									desc = L["If checked, bar group is shown when the player is resting."],
									get = function(info) return GetBarGroupField("showResting") end,
									set = function(info, value) SetBarGroupField("showResting", value) end,
								},
								FishingGroup = {
									type = "toggle", order = 13, name = L["Fishing"],
									desc = L["If checked, bar group is shown when the player is ready to fish (i.e., trained with fishing pole equipped)."],
									get = function(info) return GetBarGroupField("showFishing") end,
									set = function(info, value) SetBarGroupField("showFishing", value) end,
								},
								MountedGroup = {
									type = "toggle", order = 20, name = L["Mounted"],
									desc = L["If checked, bar group is shown when the player is mounted."],
									get = function(info) return GetBarGroupField("showMounted") end,
									set = function(info, value) SetBarGroupField("showMounted", value) end,
								},
								VehicleGroup = {
									type = "toggle", order = 21, name = L["Vehicle"],
									desc = L["If checked, bar group is shown when the player is in a vehicle."],
									get = function(info) return GetBarGroupField("showVehicle") end,
									set = function(info, value) SetBarGroupField("showVehicle", value) end,
								},
								EnemyGroup = {
									type = "toggle", order = 22, name = L["Enemy"],
									desc = L["If checked, bar group is shown when the target is an enemy."],
									get = function(info) return GetBarGroupField("showEnemy") end,
									set = function(info, value) SetBarGroupField("showEnemy", value) end,
								},
								FriendGroup = {
									type = "toggle", order = 23, name = L["Friendly"],
									desc = L["If checked, bar group is shown when the target is friendly."],
									get = function(info) return GetBarGroupField("showFriendly") end,
									set = function(info, value) SetBarGroupField("showFriendly", value) end,
								},
								SoloGroup = {
									type = "toggle", order = 30, name = L["Solo"],
									desc = L["If checked, bar group is shown when the player is not in a party or raid."],
									get = function(info) return GetBarGroupField("showSolo") end,
									set = function(info, value) SetBarGroupField("showSolo", value) end,
								},
								PartyGroup = {
									type = "toggle", order = 31, name = L["In Party"],
									desc = L["If checked, bar group is shown when the player is in a party."],
									get = function(info) return GetBarGroupField("showParty") end,
									set = function(info, value) SetBarGroupField("showParty", value) end,
								},
								RaidGroup = {
									type = "toggle", order = 32, name = L["In Raid"],
									desc = L["If checked, bar group is shown when the player is in a raid."],
									get = function(info) return GetBarGroupField("showRaid") end,
									set = function(info, value) SetBarGroupField("showRaid", value) end,
								},
								FocusTargetGroup = {
									type = "toggle", order = 33, name = L["Focus=Target"],
									desc = L["If checked, bar group is shown when focus is same as target."],
									get = function(info) return GetBarGroupField("showFocusTarget") end,
									set = function(info, value) SetBarGroupField("showFocusTarget", value) end,
								},
								InstanceGroup = {
									type = "toggle", order = 34, name = L["In Instance"],
									desc = L["If checked, bar group is shown when the player is in a 5-man or raid instance."],
									get = function(info) return GetBarGroupField("showInstance") end,
									set = function(info, value) SetBarGroupField("showInstance", value) end,
								},
								NotInstanceGroup = {
									type = "toggle", order = 35, name = L["Not In Instance"],
									desc = L["If checked, bar group is shown when the player is not in a 5-man or raid instance."],
									get = function(info) return GetBarGroupField("showNotInstance") end,
									set = function(info, value) SetBarGroupField("showNotInstance", value) end,
								},
								ArenaGroup = {
									type = "toggle", order = 36, name = L["In Arena"],
									desc = L["If checked, bar group is shown when the player is in an arena."],
									get = function(info) return GetBarGroupField("showArena") end,
									set = function(info, value) SetBarGroupField("showArena", value) end,
								},
								BattlegroundGroup = {
									type = "toggle", order = 37, name = L["In Battleground"],
									desc = L["If checked, bar group is shown when the player is in a battleground."],
									get = function(info) return GetBarGroupField("showBattleground") end,
									set = function(info, value) SetBarGroupField("showBattleground", value) end,
								},
								PrimarySpec = {
									type = "toggle", order = 38, name = L["Primary Specialization"],
									desc = L["If checked, bar group is shown when the player is in primary specialization."],
									get = function(info) return GetBarGroupField("showPrimary") end,
									set = function(info, value) SetBarGroupField("showPrimary", value) end,
								},
								SecondarySpec = {
									type = "toggle", order = 39, name = L["Secondary Specialization"],
									desc = L["If checked, bar group is shown when the player is in secondary specialization."],
									get = function(info) return GetBarGroupField("showSecondary") end,
									set = function(info, value) SetBarGroupField("showSecondary", value) end,
								},
								spacer0 = { type = "description", name = "", order = 40, },
								ShowIfBlizzard = {
									type = "toggle", order = 45, name = L["Blizzard Buffs Enabled"],
									desc = L["If checked, the bar group is shown if the default user interface for buffs is enabled."],
									get = function(info) return GetBarGroupField("showBlizz") end,
									set = function(info, value) SetBarGroupField("showBlizz", value) end,
								},
								ShowNotBlizzard = {
									type = "toggle", order = 46, name = L["Blizzard Buffs Disabled"],
									desc = L["If checked, the bar group is shown if the default user interface for buffs is disabled."],
									get = function(info) return GetBarGroupField("showNotBlizz") end,
									set = function(info, value) SetBarGroupField("showNotBlizz", value) end,
								},
								CheckCondition = {
									type = "toggle", order = 60, name = L["Condition Is True"],
									desc = L["If checked, bar group is shown only when the selected condition is true."],
									get = function(info) return GetBarGroupField("checkCondition") end,
									set = function(info, value) if not value then SetBarGroupField("condition", nil) end; SetBarGroupField("checkCondition", value) end,
								},
								SelectCondition = {
									type = "select", order = 65, name = L["Condition"],
									disabled = function(info) return not GetBarGroupField("checkCondition") end,
									get = function(info) return GetBarGroupSelectedCondition(GetSelectConditionList()) end,
									set = function(info, value) SetBarGroupField("condition", GetSelectConditionList()[value]) end,
									values = function(info) return GetSelectConditionList() end,
									style = "dropdown",
								},
								spacer1 = { type = "description", name = "", order = 70, },
								SelectClass = {
									type = "group", order = 75, name = L["Player Class"], inline = true,
									args = {
										Druid = {
											type = "toggle", order = 10, name = L["Druid"], width = "half",
											get = function(info) local t = GetBarGroupField("showClasses"); return not t or not t.DRUID end,
											set = function(info, value)
												local t = GetBarGroupField("showClasses")
												if not t then SetBarGroupField("showClasses", { DRUID = not value } ) else t.DRUID = not value end
											end
										},
										Hunter = {
											type = "toggle", order = 15, name = L["Hunter"], width = "half",
											get = function(info) local t = GetBarGroupField("showClasses"); return not t or not t.HUNTER end,
											set = function(info, value)
												local t = GetBarGroupField("showClasses")
												if not t then SetBarGroupField("showClasses", { HUNTER = not value } ) else t.HUNTER = not value end
											end
										},
										Mage = {
											type = "toggle", order = 20, name = L["Mage"], width = "half",
											get = function(info) local t = GetBarGroupField("showClasses"); return not t or not t.MAGE end,
											set = function(info, value)
												local t = GetBarGroupField("showClasses")
												if not t then SetBarGroupField("showClasses", { MAGE = not value } ) else t.MAGE = not value end
											end
										},
										Monk = {
											type = "toggle", order = 22, name = L["Monk"], width = "half",
											get = function(info) local t = GetBarGroupField("showClasses"); return not t or not t.MONK end,
											set = function(info, value)
												local t = GetBarGroupField("showClasses")
												if not t then SetBarGroupField("showClasses", { MONK = not value } ) else t.MONK = not value end
											end
										},
										Paladin = {
											type = "toggle", order = 25, name = L["Paladin"], width = "half",
											get = function(info) local t = GetBarGroupField("showClasses"); return not t or not t.PALADIN end,
											set = function(info, value)
												local t = GetBarGroupField("showClasses")
												if not t then SetBarGroupField("showClasses", { PALADIN = not value } ) else t.PALADIN = not value end
											end
										},
										Priest = {
											type = "toggle", order = 30, name = L["Priest"], width = "half",
											get = function(info) local t = GetBarGroupField("showClasses"); return not t or not t.PRIEST end,
											set = function(info, value)
												local t = GetBarGroupField("showClasses")
												if not t then SetBarGroupField("showClasses", { PRIEST = not value } ) else t.PRIEST = not value end
											end
										},
										Rogue = {
											type = "toggle", order = 35, name = L["Rogue"], width = "half",
											get = function(info) local t = GetBarGroupField("showClasses"); return not t or not t.ROGUE end,
											set = function(info, value)
												local t = GetBarGroupField("showClasses")
												if not t then SetBarGroupField("showClasses", { ROGUE = not value } ) else t.ROGUE = not value end
											end
										},
										Shaman = {
											type = "toggle", order = 40, name = L["Shaman"], width = "half",
											get = function(info) local t = GetBarGroupField("showClasses"); return not t or not t.SHAMAN end,
											set = function(info, value)
												local t = GetBarGroupField("showClasses")
												if not t then SetBarGroupField("showClasses", { SHAMAN = not value } ) else t.SHAMAN = not value end
											end
										},
										Warlock = {
											type = "toggle", order = 45, name = L["Warlock"], width = "half",
											get = function(info) local t = GetBarGroupField("showClasses"); return not t or not t.WARLOCK end,
											set = function(info, value)
												local t = GetBarGroupField("showClasses")
												if not t then SetBarGroupField("showClasses", { WARLOCK = not value } ) else t.WARLOCK = not value end
											end
										},
										Warrior = {
											type = "toggle", order = 50, name = L["Warrior"], width = "half",
											get = function(info) local t = GetBarGroupField("showClasses"); return not t or not t.WARRIOR end,
											set = function(info, value)
												local t = GetBarGroupField("showClasses")
												if not t then SetBarGroupField("showClasses", { WARRIOR = not value } ) else t.WARRIOR = not value end
											end
										},
										DeathKnight = {
											type = "toggle", order = 55, name = L["Death Knight"],
											get = function(info) local t = GetBarGroupField("showClasses"); return not t or not t.DEATHKNIGHT end,
											set = function(info, value)
												local t = GetBarGroupField("showClasses")
												if not t then SetBarGroupField("showClasses", { DEATHKNIGHT = not value } ) else t.DEATHKNIGHT = not value end
											end
										},
									},
								},
							},
						},
						OpacityGroup = {
							type = "group", order = 25, name = L["Opacity"],  inline = true,
							args = {
								InCombatlpha = {
									type = "range", order = 10, name = L["In Combat"], min = 0, max = 1, step = 0.05,
									desc = L["Set opacity for bar group when in combat."],
									get = function(info) return GetBarGroupField("bgCombatAlpha") end,
									set = function(info, value) SetBarGroupField("bgCombatAlpha", value) end,
								},
								OutOfCombatAlpha = {
									type = "range", order = 20, name = L["Out Of Combat"], min = 0, max = 1, step = 0.05,
									desc = L["Set opacity for bar group when out of combat."],
									get = function(info) return GetBarGroupField("bgNormalAlpha") end,
									set = function(info, value) SetBarGroupField("bgNormalAlpha", value) end,
								},
								MouseAlpha = {
									type = "range", order = 30, name = L["Mouseover"], min = 0, max = 1, step = 0.05,
									desc = L["Set opacity for bar group when mouse is over it (overrides in and out of combat opacities)."],
									get = function(info) return GetBarGroupField("mouseAlpha") end,
									set = function(info, value) SetBarGroupField("mouseAlpha", value) end,
								},
								FadeAlpha = {
									type = "range", order = 40, name = L["Fade Effects"], min = 0, max = 1, step = 0.05,
									desc = L["Set opacity for faded bars."],
									get = function(info) return GetBarGroupField("fadeAlpha") end,
									set = function(info, value) SetBarGroupField("fadeAlpha", value) end,
								},
							},
						},
						EffectsGroup = {
							type = "group", order = 30, name = L["Special Effects"],  inline = true,
							args = {
								PulseStart = {
									type = "toggle", order = 10, name = L["Pulse At Start"],
									desc = L["Enable icon pulse when bar is started."],
									get = function(info) return GetBarGroupField("pulseStart") end,
									set = function(info, value) SetBarGroupField("pulseStart", value) end,
								},
								PulseEnd = {
									type = "toggle", order = 15, name = L["Pulse When Expiring"],
									desc = L["Enable icon pulse when bar is expiring."],
									get = function(info) return GetBarGroupField("pulseEnd") end,
									set = function(info, value) SetBarGroupField("pulseEnd", value) end,
								},
								FlashExpiring = {
									type = "toggle", order = 20, name = L["Flash When Expiring"],
									desc = L["Enable flashing of expiring bars."],
									get = function(info) return GetBarGroupField("flashExpiring") end,
									set = function(info, value) SetBarGroupField("flashExpiring", value) end,
								},
								FlashTime = {
									type = "range", order = 25, name = L["Flash Time"], min = 1, max = 300, step = 1,
									desc = L["Set number of seconds before expiration that bar should start flashing."],
									disabled = function(info) return not GetBarGroupField("flashExpiring") end,
									get = function(info) return GetBarGroupField("flashTime") end,
									set = function(info, value) SetBarGroupField("flashTime", value) end,
								},
								space1 = { type = "description", name = "", order = 30 },
								HideEnable = {
									type = "toggle", order = 35, name = L["Hide After Start"],
									desc = L["Enable hide after start for timer bars (does not hide bars with unlimited duration)."],
									get = function(info) return GetBarGroupField("hide") end,
									set = function(info, value) SetBarGroupField("hide", value) end,
								},
								FadeEnable = {
									type = "toggle", order = 40, name = L["Fade After Start"],
									desc = L["Enable fade after start (i.e., switch to fade opacity after a delay)."],
									disabled = function(info) return GetBarGroupField("hide") end,
									get = function(info) return GetBarGroupField("fade") end,
									set = function(info, value) SetBarGroupField("fade", value) end,
								},
								GhostEnable = {
									type = "toggle", order = 41, name = L["Ghost When Expiring"],
									desc = L["Enable ghost bar/icon (i.e., continue to show for delay period after would normally disappear)."],
									disabled = function(info) return GetBarGroupField("hide") end,
									get = function(info) return GetBarGroupField("ghost") end,
									set = function(info, value) SetBarGroupField("ghost", value) end,
								},
								FadeDelay = {
									type = "range", order = 45, name = L["Delay"], min = 0, max = 300, step = 1,
									desc = L["Set number of seconds before bar (or ghost) will hide or fade."],
									disabled = function(info) return not GetBarGroupField("fade") and not GetBarGroupField("hide") and not GetBarGroupField("ghost") end,
									get = function(info) return GetBarGroupField("delayTime") or 5 end,
									set = function(info, value) SetBarGroupField("delayTime", value) end,
								},
								space2 = { type = "description", name = "", order = 60 },
								SpellStartSound = {
									type = "toggle", order = 70, name = L["Start Spell Sound"],
									desc = L["Play associated spell sound, if any, when bar starts (spell sounds are set up on Spells tab)."],
									get = function(info) return GetBarGroupField("soundSpellStart") end,
									set = function(info, value) SetBarGroupField("soundSpellStart", value) end,
								},
								AltStartSound = {
									type = "select", order = 75, name = L["Alternative Start Sound"], 
									desc = L["Select sound to play when bar starts and there is no associated spell sound (or start spell sounds are not enabled)."],
									dialogControl = 'LSM30_Sound',
									values = AceGUIWidgetLSMlists.sound,
									get = function(info) return GetBarGroupField("soundAltStart") end,
									set = function(info, value) SetBarGroupField("soundAltStart", value) end,
								},
								ReplayEnable = {
									type = "toggle", order = 76, name = L["Replay"], width = "half",
									desc = L["Enable replay of start sound (after a specified amount of time) while bar is active."],
									get = function(info) return GetBarGroupField("replay") end,
									set = function(info, value) SetBarGroupField("replay", value) end,
								},
								ReplayDelay = {
									type = "range", order = 77, name = L["Replay Time"], min = 1, max = 60, step = 1,
									desc = L["Set number of seconds between replays of start sound."],
									get = function(info) return GetBarGroupField("replayTime") or 5 end,
									set = function(info, value) SetBarGroupField("replayTime", value) end,
								},
								space3 = { type = "description", name = "", order = 79 },
								SpellEndSound = {
									type = "toggle", order = 80, name = L["Finish Spell Sound"],
									desc = L["Play associated spell sound, if any, when bar finishes (spell sounds are set up on Spells tab)."],
									get = function(info) return GetBarGroupField("soundSpellEnd") end,
									set = function(info, value) SetBarGroupField("soundSpellEnd", value) end,
								},
								AltEndSound = {
									type = "select", order = 85, name = L["Alternative Finish Sound"], 
									desc = L["Select sound to play when bar finishes and there is no associated spell sound (or finish spell sounds are not enabled)."],
									dialogControl = 'LSM30_Sound',
									values = AceGUIWidgetLSMlists.sound,
									get = function(info) return GetBarGroupField("soundAltEnd") end,
									set = function(info, value) SetBarGroupField("soundAltEnd", value) end,
								},
								space4 = { type = "description", name = "", order = 90 },
								SpellExpireSound = {
									type = "toggle", order = 91, name = L["Expire Spell Sound"],
									desc = L["Play associated spell sound, if any, when bar is about to expire (spell sounds are set up on Spells tab)."],
									get = function(info) return GetBarGroupField("soundSpellExpire") end,
									set = function(info, value) SetBarGroupField("soundSpellExpire", value) end,
								},
								AltExpireSound = {
									type = "select", order = 93, name = L["Alternative Expire Sound"], 
									desc = L["Select sound to play when bar is about to expire and there is no associated spell sound (or expire spell sounds are not enabled)."],
									dialogControl = 'LSM30_Sound',
									values = AceGUIWidgetLSMlists.sound,
									get = function(info) return GetBarGroupField("soundAltExpire") end,
									set = function(info, value) SetBarGroupField("soundAltExpire", value) end,
								},
								ExpireTime = {
									type = "range", order = 95, name = L["Expire Time"], min = 0, max = 300, step = 1,
									desc = L["Set number of seconds before expiration that bar should change color and/or play expire sound."],
									disabled = function(info) return not GetBarGroupField("colorExpiring")
										and not GetBarGroupField("expireMSBT") and not GetBarGroupField("soundSpellExpire")
										and not (GetBarGroupField("soundAltExpire") and GetBarGroupField("soundAltExpire") ~= "None") end,
									get = function(info) return GetBarGroupField("expireTime") end,
									set = function(info, value) SetBarGroupField("expireTime", value) end,
								},
								MinimumTime = {
									type = "range", order = 96, name = L["Minimum Duration"], min = 0, max = 60, step = 0.25,
									desc = L["Set minimum duration in minutes required to trigger expiration options."],
									disabled = function(info) return not GetBarGroupField("colorExpiring")
										and not GetBarGroupField("expireMSBT") and not GetBarGroupField("soundSpellExpire")
										and not (GetBarGroupField("soundAltExpire") and GetBarGroupField("soundAltExpire") ~= "None") end,
									get = function(info) return (GetBarGroupField("expireMinimum") or 0) / 60 end,
									set = function(info, value) if value == 0 then value = nil else value = value * 60 end
										SetBarGroupField("expireMinimum", value) end,
								},
								space5 = { type = "description", name = "", order = 100 },
								ColorExpiring = {
									type = "toggle", order = 105, name = L["Color When Expiring"],
									desc = L["Enable color changes for expiring bars (and, for icon configurations, make background visible if opacity is set to invisible to enable bar as highlight)."],
									get = function(info) return GetBarGroupField("colorExpiring") end,
									set = function(info, value) SetBarGroupField("colorExpiring", value) end,
								},
								ExpireColor = {
									type = "color", order = 106, name = L["Bar"], hasAlpha = true, width = "half",
									desc = L["Set bar color for when about to expire (set invisible opacity to disable color change)."],
									disabled = function(info) return not GetBarGroupField("colorExpiring") end,
									get = function(info)
										local t = GetBarGroupField("expireColor"); if t then return t.r, t.g, t.b, t.a else return 1, 0, 0, 1 end
									end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("expireColor"); if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("expireColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								LabelTextColor = {
									type = "color", order = 107, name = L["Label"], hasAlpha = true, width = "half",
									desc = L["Set label color for when bar is about to expire (set invisible opacity to disable color change)."],
									disabled = function(info) return not GetBarGroupField("colorExpiring") end,
									get = function(info)
										local t = GetBarGroupField("expireLabelColor"); if t then return t.r, t.g, t.b, t.a else return 1, 0, 0, 0 end
									end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("expireLabelColor"); if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("expireLabelColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								TimeTextColor = {
									type = "color", order = 108, name = L["Time"], hasAlpha = true, width = "half",
									desc = L["Set time color for when bar is about to expire (set invisible opacity to disable color change)."],
									disabled = function(info) return not GetBarGroupField("colorExpiring") end,
									get = function(info)
										local t = GetBarGroupField("expireTimeColor"); if t then return t.r, t.g, t.b, t.a else return 1, 0, 0, 0 end
									end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("expireTimeColor"); if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("expireTimeColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								MSBTWarning = {
									type = "toggle", order = 111, name = L["Combat Text"],
									desc = L["Enable warning in combat text for expiring bars."],
									get = function(info) return GetBarGroupField("expireMSBT") end,
									set = function(info, value) SetBarGroupField("expireMSBT", value) end,
								},
								ColorMSBT = {
									type = "color", order = 112, name = L["Color"], hasAlpha = true, width = "half",
									desc = L["Set color for combat text warning."],
									disabled = function(info) return not GetBarGroupField("expireMSBT") end,
									get = function(info)
										local t = GetBarGroupField("colorMSBT"); if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
									end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("colorMSBT"); if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("colorMSBT", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								MSBTCritical = {
									type = "toggle", order = 113, name = L["Critical"], width = "half",
									desc = L["Enable combat text warning as critical."],
									get = function(info) return GetBarGroupField("criticalMSBT") end,
									set = function(info, value) SetBarGroupField("criticalMSBT", value) end,
								},
							},
						},
						OptionsGroup = {
							type = "group", order = 40, name = L["Miscellaneous Options"], inline = true,
							hidden = function(info) return GetBarGroupField("merged") end,
							args = {
								TooltipAnchor = {
									type = "select", order = 15, name = L["Tooltip Anchor"],
									desc = L["Tooltip anchor string"],
									disabled = function(info) return GetBarGroupField("noMouse") or GetBarGroupField("autoTips") end,
									get = function(info) return GetBarGroupField("anchorTips") end,
									set = function(info, value) SetBarGroupField("anchorTips", value) end,
									values = function(info) return anchorTips end,
									style = "dropdown",
								},
								NoMouse = {
									type = "toggle", order = 35, name = L["Non-Interactive"],
									desc = L["If checked, the bar group is non-interactive and doesn't show tooltips or respond to clicks."],
									get = function(info) return GetBarGroupField("noMouse") end,
									set = function(info, value) SetBarGroupField("noMouse", value) end,
								},
								BarOrIcon = {
									type = "toggle", order = 40, name = L["Only Icons Interact"],
									desc = L["If checked, only icons show tooltips and respond to clicks, otherwise entire bar does."],
									disabled = function(info) return GetBarGroupField("noMouse") end,
									get = function(info) return GetBarGroupField("iconMouse") end,
									set = function(info, value) SetBarGroupField("iconMouse", value) end,
								},
								CombatTooltips = {
									type = "toggle", order = 45, name = L["Combat Tooltips"],
									desc = L["If checked, tooltips are shown during combat."],
									disabled = function(info) return GetBarGroupField("noMouse") end,
									get = function(info) return GetBarGroupField("combatTips") end,
									set = function(info, value) SetBarGroupField("combatTips", value) end,
								},
								ShowCaster = {
									type = "toggle", order = 46, name = L["Caster"], width = "half",
									desc = L["If checked, tooltips include caster for buffs and debuffs when known."],
									disabled = function(info) return GetBarGroupField("noMouse") end,
									get = function(info) return GetBarGroupField("casterTips") end,
									set = function(info, value) SetBarGroupField("casterTips", value) end,
								},
								Space3 = { type = "description", name = "", order = 48 },
								Headers = {
									type = "toggle", order = 50, name = L["Show Headers"],
									hidden = function(info) return not GetBarGroupField("auto") end,
									desc = L["When showing all buffs or debuffs cast by player, add headers for each affected target."],
									get = function(info) return not GetBarGroupField("noHeaders") end,
									set = function(info, value) SetBarGroupField("noHeaders", not value) end,
								},
								TargetFirst = {
									type = "toggle", order = 60, name = L["Sort Target First"],
									hidden = function(info) return not GetBarGroupField("auto") end,
									desc = L["When showing all buffs or debuffs cast by player, sort ones for target first."],
									get = function(info) return GetBarGroupField("targetFirst") end,
									set = function(info, value) SetBarGroupField("targetFirst", value) end,
								},
								TargetAlpha = {
									type = "range", order = 65, name = L["Non-Target Opacity"], min = 0, max = 1, step = 0.05,
									desc = L["When showing all buffs or debuffs cast by player, set opacity for ones not on target."],
									get = function(info) return GetBarGroupField("targetAlpha") end,
									set = function(info, value) SetBarGroupField("targetAlpha", value) end,
								},
								TargetNames = {
									type = "toggle", order = 70, name = L["Targets"], width = "half",
									hidden = function(info) return not GetBarGroupField("auto") end,
									disabled = function(info) return not GetBarGroupField("noHeaders") end,
									desc = L["When showing all buffs or debuffs cast by player without headers, show target names in labels."],
									get = function(info) return not GetBarGroupField("noTargets") end,
									set = function(info, value) SetBarGroupField("noTargets", not value) end,
								},
								SpellNames = {
									type = "toggle", order = 75, name = L["Spells"], width = "half",
									hidden = function(info) return not GetBarGroupField("auto") end,
									disabled = function(info) return not GetBarGroupField("noHeaders") end,
									desc = L["When showing all buffs or debuffs cast by player without headers, show spell names in labels."],
									get = function(info) return not GetBarGroupField("noLabels") end,
									set = function(info, value) SetBarGroupField("noLabels", not value) end,
								},
								space4 = { type = "description", name = "", order = 80 },
								ReverseDirection = {
									type = "toggle", order = 82, name = L["Clock Direction"],
									desc = L["Set empty/fill direction for clock animations on icons."],
									get = function(info) return GetBarGroupField("clockReverse") end,
									set = function(info, value) SetBarGroupField("clockReverse", value) end,
								},
								--[[ DrawEdge = { -- removed in 5.0.4 and apparently not coming back
									type = "toggle", order = 85, name = L["Clock Edge"],
									desc = L["If checked, show a bright line on the moving edge of clock animations."],
									get = function(info) return GetBarGroupField("clockEdge") end,
									set = function(info, value) SetBarGroupField("clockEdge", value) end,
								}, ]]--
							},
						},
					},
				},
				BarTab = {
					type = "group", order = 15, name = L["Custom Bars"],
					hidden = function(info) return NoBarGroup() or GetBarGroupField("auto") end,
					args = {
						NewBarButton = {
							type = "execute", order = 1, name = L["New"], width = "half",
							desc = L["Create a new bar."],
							disabled = function(info) return InMode("Bar") end,
							func = function(info) EnterNewBar("start") end,
						},
						DeleteBar = {
							type = "execute", order = 2, name = L["Delete"], width = "half",
							desc = L["Delete the selected bar."],
							disabled = function(info) return NoBar() end,
							func = function(info) DeleteBar() end,
							confirm = function(info) return L['DELETE BAR\nAre you sure you want to delete the selected bar?'] end,
						},
						-- Bars get plugged in here, with order starting at 10
					},
				},
				DetectBuffsTab = {
					type = "group", order = 20, name = L["Buffs"],
					disabled = function(info) return InMode("Bar") end,
					hidden = function(info) return NoBarGroup() or not GetBarGroupField("auto") end,
					args = {
						EnableGroup = {
							type = "group", order = 1, name = L["Enable"], inline = true,
							args = {
								DetectEnable = {
									type = "toggle", order = 1, name = L["Auto Buffs"],
									desc = L['Enable automatically displaying bars for buffs that match these settings.'],
									get = function(info) return GetBarGroupField("detectBuffs") end,
									set = function(info, value) SetBarGroupField("detectBuffs", value) end,
								},
								AnyCastByPlayer = {
									type = "toggle", order = 5, name = L["All Cast By Player"],
									disabled = function(info) return not GetBarGroupField("detectBuffs") end,
									desc = L['Include all buffs cast by player on others.'],
									get = function(info) return GetBarGroupField("detectAllBuffs") end,
									set = function(info, value) SetBarGroupField("detectAllBuffs", value) end,
								},
							},
						},
						MonitorUnitGroup = {
							type = "group", order = 10, name = L["Action On"], inline = true,
							hidden = function(info) return GetBarGroupField("detectAllBuffs") end,
							disabled = function(info) return not GetBarGroupField("detectBuffs") end,
							args = {
								PlayerBuff = {
									type = "toggle", order = 10, name = L["Player"],
									desc = L["If checked, only add bars for buffs if they are on the player."],
									get = function(info) return GetBarGroupField("detectBuffsMonitor") == "player" end,
									set = function(info, value) SetBarGroupField("detectBuffsMonitor", "player") end,
								},
								PetBuff = {
									type = "toggle", order = 15, name = L["Pet"],
									desc = L["If checked, only add bars for buffs if they are on the player's pet."],
									get = function(info) return GetBarGroupField("detectBuffsMonitor") == "pet" end,
									set = function(info, value) SetBarGroupField("detectBuffsMonitor", "pet") end,
								},
								TargetBuff = {
									type = "toggle", order = 20, name = L["Target"],
									desc = L["If checked, only add bars for buffs if they are on the target."],
									get = function(info) return GetBarGroupField("detectBuffsMonitor") == "target" end,
									set = function(info, value) SetBarGroupField("detectBuffsMonitor", "target") end,
								},
								FocusBuff = {
									type = "toggle", order = 30, name = L["Focus"],
									desc = L["If checked, only add bars for buffs if they are on the focus."],
									get = function(info) return GetBarGroupField("detectBuffsMonitor") == "focus" end,
									set = function(info, value) SetBarGroupField("detectBuffsMonitor", "focus") end,
								},
								Space1 = { type = "description", name = "", order = 35 },
								MouseoverBuff = {
									type = "toggle", order = 40, name = L["Mouseover"],
									desc = L["If checked, only add bars for buffs if they are on the mouseover unit."],
									get = function(info) return GetBarGroupField("detectBuffsMonitor") == "mouseover" end,
									set = function(info, value) SetBarGroupField("detectBuffsMonitor", "mouseover") end,
								},
								PetTargetBuff = {
									type = "toggle", order = 45, name = L["Pet's Target"],
									desc = L["If checked, only add bars for buffs if they are on the pet's target."],
									get = function(info) return GetBarGroupField("detectBuffsMonitor") == "pettarget" end,
									set = function(info, value) SetBarGroupField("detectBuffsMonitor", "pettarget") end,
								},
								TargetTargetBuff = {
									type = "toggle", order = 50, name = L["Target's Target"],
									desc = L["If checked, only add bars for buffs if they are on the target's target."],
									get = function(info) return GetBarGroupField("detectBuffsMonitor") == "targettarget" end,
									set = function(info, value) SetBarGroupField("detectBuffsMonitor", "targettarget") end,
								},
								FocusTargetBuff = {
									type = "toggle", order = 60, name = L["Focus's Target"],
									desc = L["If checked, only add bars for buffs if they are on the focus's target."],
									get = function(info) return GetBarGroupField("detectBuffsMonitor") == "focustarget" end,
									set = function(info, value) SetBarGroupField("detectBuffsMonitor", "focustarget") end,
								},
							},
						},
						ExcludeUnitGroup = {
							type = "group", order = 15, name = L["Exclude On"], inline = true,
							disabled = function(info) return not GetBarGroupField("detectBuffs") end,
							args = {
								PlayerBuff = {
									type = "toggle", order = 10, name = L["Player"],
									desc = L["If checked, exclude buffs if they are on the player."],
									get = function(info) return GetBarGroupField("noPlayerBuffs") end,
									set = function(info, value) SetBarGroupField("noPlayerBuffs", value) end,
								},
								PetBuff = {
									type = "toggle", order = 15, name = L["Pet"],
									desc = L["If checked, exclude buffs if they are on the player's pet."],
									get = function(info) return GetBarGroupField("noPetBuffs") end,
									set = function(info, value) SetBarGroupField("noPetBuffs", value) end,
								},
								TargetBuff = {
									type = "toggle", order = 20, name = L["Target"],
									desc = L["If checked, exclude buffs if they are on the target."],
									get = function(info) return GetBarGroupField("noTargetBuffs") end,
									set = function(info, value) SetBarGroupField("noTargetBuffs", value) end,
								},
								FocusBuff = {
									type = "toggle", order = 30, name = L["Focus"],
									desc = L["If checked, exclude buffs if they are on the focus."],
									get = function(info) return GetBarGroupField("noFocusBuffs") end,
									set = function(info, value) SetBarGroupField("noFocusBuffs", value) end,
								},
							},
						},
						CastUnitGroup = {
							type = "group", order = 20, name = L["Cast By"], inline = true, width = "full",
							hidden = function(info) return GetBarGroupField("detectAllBuffs") end,
							disabled = function(info) return not GetBarGroupField("detectBuffs") end,
							args = {
								MyBuff = {
									type = "toggle", order = 10, name = L["Player"],
									desc = L["If checked, only add bars for buffs if cast by the player."],
									get = function(info) return GetBarGroupField("detectBuffsCastBy") == "player" end,
									set = function(info, value) SetBarGroupField("detectBuffsCastBy", "player") end,
								},
								PetBuff = {
									type = "toggle", order = 15, name = L["Pet"],
									desc = L["If checked, only add bars for buffs if cast by the player's pet."],
									get = function(info) return GetBarGroupField("detectBuffsCastBy") == "pet" end,
									set = function(info, value) SetBarGroupField("detectBuffsCastBy", "pet") end,
								},
								TargetBuff = {
									type = "toggle", order = 20, name = L["Target"],
									desc = L["If checked, only add bars for buffs if cast by the target."],
									get = function(info) return GetBarGroupField("detectBuffsCastBy") == "target" end,
									set = function(info, value) SetBarGroupField("detectBuffsCastBy", "target") end,
								},
								FocusBuff = {
									type = "toggle", order = 25, name = L["Focus"],
									desc = L["If checked, only add bars for buffs if cast by the focus."],
									get = function(info) return GetBarGroupField("detectBuffsCastBy") == "focus" end,
									set = function(info, value) SetBarGroupField("detectBuffsCastBy", "focus") end,
								},
								OurBuff = {
									type = "toggle", order = 27, name = L["Player Or Pet"],
									desc = L["If checked, only add bars for buffs if cast by player or pet."],
									get = function(info) return GetBarGroupField("detectBuffsCastBy") == "ours" end,
									set = function(info, value) SetBarGroupField("detectBuffsCastBy", "ours") end,
								},
								YourBuff = {
									type = "toggle", order = 30, name = L["Other"],
									desc = L["If checked, only add bars for buffs if cast by anyone other than the player or pet."],
									get = function(info) return GetBarGroupField("detectBuffsCastBy") == "other" end,
									set = function(info, value) SetBarGroupField("detectBuffsCastBy", "other") end,
								},
								AnyBuff = {
									type = "toggle", order = 35, name = L["Anyone"],
									desc = L["If checked, add bars for buffs if cast by anyone, including player."],
									get = function(info) return GetBarGroupField("detectBuffsCastBy") == "anyone" end,
									set = function(info, value) SetBarGroupField("detectBuffsCastBy", "anyone") end,
								},
							},
						},
						TrackingFilter = {
							type = "group", order = 25, name = L["Tracking"], inline = true, width = "full",
							disabled = function(info) return not GetBarGroupField("detectBuffs") end,
							args = {
								Tracking = {
									type = "toggle", order = 10, name = L["Include Tracking"],
									disabled = function(info) return not GetBarGroupField("detectBuffs") end,
									desc = L['Include the active tracking types as buffs.'],
									get = function(info) return GetBarGroupField("detectTracking") end,
									set = function(info, value) SetBarGroupField("detectTracking", value) end,
								},
								OnlyTracking = {
									type = "toggle", order = 20, name = L["Show Only Tracking"],
									disabled = function(info) return not (GetBarGroupField("detectBuffs") and GetBarGroupField("detectTracking")) end,
									desc = L['Include only the active tracking types.'],
									get = function(info) return GetBarGroupField("detectOnlyTracking") end,
									set = function(info, value) SetBarGroupField("detectOnlyTracking", value) end,
								},
							},
						},
						FilterByType = {
							type = "group", order = 30, name = L["Filter By Type"], inline = true, width = "full",
							disabled = function(info) return not GetBarGroupField("detectBuffs") or
											(GetBarGroupField("detectTracking") and GetBarGroupField("detectOnlyTracking")) end,
							args = {
								Enable = {
									type = "toggle", order = 10, name = L["Enable"],
									desc = L["Filter buff types string"],
									get = function(info) return GetBarGroupField("filterBuffTypes") end,
									set = function(info, v) SetBarGroupField("filterBuffTypes", v) end,
								},
								Castable = {
									type = "toggle", order = 15, name = L["Castable"],
									disabled = function(info) return not GetBarGroupField("filterBuffTypes") or not GetBarGroupField("detectBuffs") or
											(GetBarGroupField("detectTracking") and GetBarGroupField("detectOnlyTracking")) end,
									desc = L['Include buffs that the player can cast.'],
									get = function(info) return GetBarGroupField("detectCastable") end,
									set = function(info, value) SetBarGroupField("detectCastable", value) end,
								},
								Stealable = {
									type = "toggle", order = 20, name = L["Stealable"],
									disabled = function(info) return not GetBarGroupField("filterBuffTypes") or not GetBarGroupField("detectBuffs") or
											(GetBarGroupField("detectTracking") and GetBarGroupField("detectOnlyTracking")) end,
									desc = L['Include buffs that mages can spellsteal (you must include both Stealable and Magic if you want all magic buffs).'],
									get = function(info) return GetBarGroupField("detectStealable") end,
									set = function(info, value) SetBarGroupField("detectStealable", value) end,
								},
								Magic = {
									type = "toggle", order = 30, name = L["Magic"],
									disabled = function(info) return not GetBarGroupField("filterBuffTypes") or not GetBarGroupField("detectBuffs") or
											(GetBarGroupField("detectTracking") and GetBarGroupField("detectOnlyTracking")) end,
									desc = L['Include magic buffs but not those considered stealable (magic buffs can usually be removed with abilities like Purge).'],
									get = function(info) return GetBarGroupField("detectMagicBuffs") end,
									set = function(info, value) SetBarGroupField("detectMagicBuffs", value) end,
								},
								CastByNPC = {
									type = "toggle", order = 35, name = L["NPC"],
									disabled = function(info) return not GetBarGroupField("filterBuffTypes") or not GetBarGroupField("detectBuffs") or
											(GetBarGroupField("detectTracking") and GetBarGroupField("detectOnlyTracking")) end,
									desc = L['Include buffs cast by an NPC (note: only valid while caster is selected, such as when checking target of target).'],
									get = function(info) return GetBarGroupField("detectNPCBuffs") end,
									set = function(info, value) SetBarGroupField("detectNPCBuffs", value) end,
								},
								CastByVehicle = {
									type = "toggle", order = 40, name = L["Vehicle"],
									disabled = function(info) return not GetBarGroupField("filterBuffTypes") or not GetBarGroupField("detectBuffs") or
											(GetBarGroupField("detectTracking") and GetBarGroupField("detectOnlyTracking")) end,
									desc = L['Include buffs cast by a vehicle (note: only valid while caster is selected, such as when checking target of target).'],
									get = function(info) return GetBarGroupField("detectVehicleBuffs") end,
									set = function(info, value) SetBarGroupField("detectVehicleBuffs", value) end,
								},
								Boss = {
									type = "toggle", order = 42, name = L["Boss"],
									disabled = function(info) return not GetBarGroupField("filterBuffTypes") end,
									desc = L['Include buffs cast by boss.'],
									get = function(info) return GetBarGroupField("detectBossBuffs") end,
									set = function(info, value) SetBarGroupField("detectBossBuffs", value) end,
								},
								Enrage = {
									type = "toggle", order = 43, name = L["Enrage"],
									disabled = function(info) return not GetBarGroupField("filterBuffTypes") end,
									desc = L['Include enrage buffs.'],
									get = function(info) return GetBarGroupField("detectEnrageBuffs") end,
									set = function(info, value) SetBarGroupField("detectEnrageBuffs", value) end,
								},
								Effects = {
									type = "toggle", order = 45, name = L["Effect Timers"],
									disabled = function(info) return not GetBarGroupField("filterBuffTypes") or not GetBarGroupField("detectBuffs") or
											(GetBarGroupField("detectTracking") and GetBarGroupField("detectOnlyTracking")) end,
									desc = L["If checked, include bars for effect timers triggered by a spell cast."],
									get = function(info) return GetBarGroupField("detectEffectBuffs") end,
									set = function(info, value) SetBarGroupField("detectEffectBuffs", value) end,
								},
								Weapons = {
									type = "toggle", order = 50, name = L["Weapon Buffs"],
									disabled = function(info) return not GetBarGroupField("filterBuffTypes") or not GetBarGroupField("detectBuffs") or
											(GetBarGroupField("detectTracking") and GetBarGroupField("detectOnlyTracking")) end,
									desc = L["If checked, include bars for weapon buffs."],
									get = function(info) return GetBarGroupField("detectWeaponBuffs") end,
									set = function(info, value) SetBarGroupField("detectWeaponBuffs", value) end,
								},
								Other = {
									type = "toggle", order = 60, name = L["Other"],
									disabled = function(info) return not GetBarGroupField("filterBuffTypes") or not GetBarGroupField("detectBuffs") or
											(GetBarGroupField("detectTracking") and GetBarGroupField("detectOnlyTracking")) end,
									desc = L['Include other buffs not selected with filter types.'],
									get = function(info) return GetBarGroupField("detectOtherBuffs") end,
									set = function(info, value) SetBarGroupField("detectOtherBuffs", value) end,
								},
							},
						},
						FilterGroup = {
							type = "group", order = 40, name = L["Filter List"], inline = true, width = "full",
							disabled = function(info) return not GetBarGroupField("detectBuffs") end,
							args = {
								BlackList = {
									type = "toggle", order = 10, name = L["Black List"],
									desc = L["If checked, don't display any buffs that are in the filter list."],
									get = function(info) return GetBarGroupField("filterBuff") end,
									set = function(info, v) SetBarGroupField("filterBuff", v); if v then SetBarGroupField("showBuff", false) end end,
								},
								WhiteList = {
									type = "toggle", order = 11, name = L["White List"],
									desc = L["If checked, only display buffs that are in the filter list."],
									get = function(info) return GetBarGroupField("showBuff") end,
									set = function(info, v) SetBarGroupField("showBuff", v); if v then SetBarGroupField("filterBuff", false) end  end,
								},
								SpellList = {
									type = "toggle", order = 16, name = L["Use Spell List"],
									desc = L["If checked, filter list includes spells in specified spell list (these are set up on the Spells tab)."],
									disabled = function(info) return not GetBarGroupField("detectBuffs") or not (GetBarGroupField("filterBuff") or GetBarGroupField("showBuff")) end,
									get = function(info) return GetBarGroupField("filterBuffSpells") end,
									set = function(info, value) SetBarGroupField("filterBuffSpells", value) end,
								},
								SelectSpellList = {
									type = "select", order = 18, name = L["Spell List"],
									disabled = function(info) return not GetBarGroupField("detectBuffs") or not (GetBarGroupField("filterBuff") or GetBarGroupField("showBuff")) or not GetBarGroupField("filterBuffSpells") end,
									get = function(info) local k, t = GetBarGroupField("filterBuffTable"), GetSpellList()
										if k and not MOD.db.global.SpellLists[k] then k = nil; SetBarGroupField("filterBuffTable", k) end
										if not k and next(t) then k = t[1]; SetBarGroupField("filterBuffTable", k) end
										return GetSpellListEntry(k) end,
									set = function(info, value) local k = GetSpellList()[value]; SetBarGroupField("filterBuffTable", k) end,
									values = function(info) return GetSpellList() end,
									style = "dropdown",
								},
								Space1 = { type = "description", name = "", order = 25 },
								AddFilter = {
									type = "input", order = 30, name = L["Enter Buff"],
									desc = L["Enter a buff to be added to the filter list."],
									disabled = function(info) return not GetBarGroupField("detectBuffs") or not (GetBarGroupField("filterBuff") or GetBarGroupField("showBuff")) end,
									get = function(info) return nil end,
									set = function(info, value) value = ValidateSpellName(value); AddBarGroupFilter("Buff", value) end,
								},
								SelectFilter = {
									type = "select", order = 40, name = L["Filter List"],
									disabled = function(info) return not GetBarGroupField("detectBuffs") or not (GetBarGroupField("filterBuff") or GetBarGroupField("showBuff")) end,
									get = function(info) return GetBarGroupFilterSelection("Buff") end,
									set = function(info, value) SetBarGroupField("filterBuffSelection", value) end,
									values = function(info) return GetBarGroupFilter("Buff") end,
									style = "dropdown",
								},
								DeleteFilter = {
									type = "execute", order = 50, name = L["Delete"], width = "half",
									disabled = function(info) return not GetBarGroupField("detectBuffs") or not (GetBarGroupField("filterBuff") or GetBarGroupField("showBuff")) end,
									desc = L["Delete the selected buff from the filter list."],
									func = function(info) DeleteBarGroupFilter("Buff", GetBarGroupField("filterBuffSelection")) end,
								},
								ResetFilter = {
									type = "execute", order = 60, name = L["Reset"], width = "half",
									desc = L["Reset the buff filter list."],
									disabled = function(info) return not GetBarGroupField("detectBuffs") or not (GetBarGroupField("filterBuff") or GetBarGroupField("showBuff")) end,
									confirm = function(info) return L['RESET\nAre you sure you want to reset the buff filter list?'] end,
									func = function(info) ResetBarGroupFilter("Buff") end,
								},
								LinkFilters = {
									type = "toggle", order = 65, name = L["Link"],
									desc = L["If checked, the filter list is shared with bar groups in other profiles with the same name."],
									disabled = function(info) return not GetBarGroupField("detectBuffs") or not (GetBarGroupField("filterBuff") or GetBarGroupField("showBuff")) end,
									get = function(info) return GetBarGroupField("filterBuffLink") end,
									set = function(info, value) SetBarGroupField("filterBuffLink", value) end,
								},
							},
						},
						FilterBarGroup = {
							type = "group", order = 50, name = L["Filter Bar Group"], inline = true, width = "full",
							disabled = function(info) return not GetBarGroupField("detectBuffs") end,
							args = {
								Enable = {
									type = "toggle", order = 10, name = L["Enable"],
									desc = L["Filter buff bar group string"],
									get = function(info) return GetBarGroupField("filterBuffBars") end,
									set = function(info, v) SetBarGroupField("filterBuffBars", v) end,
								},
								SelectBarGroup = {
									type = "select", order = 20, name = L["Bar Group"],
									desc = L["Select filter bar group."],
									disabled = function(info) return not GetBarGroupField("detectBuffs") or not GetBarGroupField("filterBuffBars") end,
									get = function(info) local t = GetBarGroupList(); for k, v in pairs(t) do if v == GetBarGroupField("filterBuffBarGroup") then return k end end end,
									set = function(info, value) SetBarGroupField("filterBuffBarGroup", GetBarGroupList()[value]) end,
									values = function(info) return GetBarGroupList() end,
									style = "dropdown",
								},
							},
						},
					},
				},
				DetectDebuffsTab = {
					type = "group", order = 25, name = L["Debuffs"],
					disabled = function(info) return InMode("Bar") end,
					hidden = function(info) return NoBarGroup() or not GetBarGroupField("auto") end,
					args = {
						EnableGroup = {
							type = "group", order = 1, name = L["Enable"], inline = true,
							args = {
								DetectEnable = {
									type = "toggle", order = 1, name = L["Auto Debuffs"],
									desc = L['Enable automatically displaying bars for debuffs that match these settings.'],
									get = function(info) return GetBarGroupField("detectDebuffs") end,
									set = function(info, value) SetBarGroupField("detectDebuffs", value) end,
								},
								AnyCastByPlayer = {
									type = "toggle", order = 5, name = L["All Cast By Player"],
									disabled = function(info) return not GetBarGroupField("detectDebuffs") end,
									desc = L['Include all debuffs cast by player on others.'],
									get = function(info) return GetBarGroupField("detectAllDebuffs") end,
									set = function(info, value) SetBarGroupField("detectAllDebuffs", value) end,
								},
							},
						},
						MonitorUnitGroup = {
							type = "group", order = 10, name = L["Action On"], inline = true,
							hidden = function(info) return GetBarGroupField("detectAllDebuffs") end,
							disabled = function(info) return not GetBarGroupField("detectDebuffs") end,
							args = {
								PlayerBuff = {
									type = "toggle", order = 10, name = L["Player"],
									desc = L["If checked, only add bars for debuffs if they are on the player."],
									get = function(info) return GetBarGroupField("detectDebuffsMonitor") == "player" end,
									set = function(info, value) SetBarGroupField("detectDebuffsMonitor", "player") end,
								},
								PetBuff = {
									type = "toggle", order = 15, name = L["Pet"],
									desc = L["If checked, only add bars for debuffs if they are on the player's pet."],
									get = function(info) return GetBarGroupField("detectDebuffsMonitor") == "pet" end,
									set = function(info, value) SetBarGroupField("detectDebuffsMonitor", "pet") end,
								},
								TargetBuff = {
									type = "toggle", order = 20, name = L["Target"],
									desc = L["If checked, only add bars for debuffs if they are on the target."],
									get = function(info) return GetBarGroupField("detectDebuffsMonitor") == "target" end,
									set = function(info, value) SetBarGroupField("detectDebuffsMonitor", "target") end,
								},
								FocusBuff = {
									type = "toggle", order = 30, name = L["Focus"],
									desc = L["If checked, only add bars for debuffs if they are on the focus."],
									get = function(info) return GetBarGroupField("detectDebuffsMonitor") == "focus" end,
									set = function(info, value) SetBarGroupField("detectDebuffsMonitor", "focus") end,
								},
								Space1 = { type = "description", name = "", order = 35 },
								MouseoverDebuff = {
									type = "toggle", order = 40, name = L["Mouseover"],
									desc = L["If checked, only add bars for debuffs if they are on the mouseover unit."],
									get = function(info) return GetBarGroupField("detectDebuffsMonitor") == "mouseover" end,
									set = function(info, value) SetBarGroupField("detectDebuffsMonitor", "mouseover") end,
								},
								PetTargetDebuff = {
									type = "toggle", order = 45, name = L["Pet's Target"],
									desc = L["If checked, only add bars for debuffs if they are on the pet's target."],
									get = function(info) return GetBarGroupField("detectDebuffsMonitor") == "pettarget" end,
									set = function(info, value) SetBarGroupField("detectDebuffsMonitor", "pettarget") end,
								},
								TargetTargetDebuff = {
									type = "toggle", order = 50, name = L["Target's Target"],
									desc = L["If checked, only add bars for debuffs if they are on the target's target."],
									get = function(info) return GetBarGroupField("detectDebuffsMonitor") == "targettarget" end,
									set = function(info, value) SetBarGroupField("detectDebuffsMonitor", "targettarget") end,
								},
								FocusTargetDebuff = {
									type = "toggle", order = 60, name = L["Focus's Target"],
									desc = L["If checked, only add bars for debuffs if they are on the focus's target."],
									get = function(info) return GetBarGroupField("detectDebuffsMonitor") == "focustarget" end,
									set = function(info, value) SetBarGroupField("detectDebuffsMonitor", "focustarget") end,
								},
							},
						},
						ExcludeUnitGroup = {
							type = "group", order = 15, name = L["Exclude On"], inline = true,
							disabled = function(info) return not GetBarGroupField("detectDebuffs") end,
							args = {
								PlayerBuff = {
									type = "toggle", order = 10, name = L["Player"],
									desc = L["If checked, exclude debuffs if they are on the player."],
									get = function(info) return GetBarGroupField("noPlayerDebuffs") end,
									set = function(info, value) SetBarGroupField("noPlayerDebuffs", value) end,
								},
								PetBuff = {
									type = "toggle", order = 15, name = L["Pet"],
									desc = L["If checked, exclude debuffs if they are on the player's pet."],
									get = function(info) return GetBarGroupField("noPetDebuffs") end,
									set = function(info, value) SetBarGroupField("noPetDebuffs", value) end,
								},
								TargetBuff = {
									type = "toggle", order = 20, name = L["Target"],
									desc = L["If checked, exclude debuffs if they are on the target."],
									get = function(info) return GetBarGroupField("noTargetDebuffs") end,
									set = function(info, value) SetBarGroupField("noTargetDebuffs", value) end,
								},
								FocusBuff = {
									type = "toggle", order = 30, name = L["Focus"],
									desc = L["If checked, exclude debuffs if they are on the focus."],
									get = function(info) return GetBarGroupField("noFocusDebuffs") end,
									set = function(info, value) SetBarGroupField("noFocusDebuffs", value) end,
								},
							},
						},
						CastUnitGroup = {
							type = "group", order = 20, name = L["Cast By"], inline = true,
							hidden = function(info) return GetBarGroupField("detectAllDebuffs") end,
							disabled = function(info) return not GetBarGroupField("detectDebuffs") end,
							args = {
								MyBuff = {
									type = "toggle", order = 10, name = L["Player"],
									desc = L["If checked, only add bars for debuffs if cast by the player."],
									get = function(info) return GetBarGroupField("detectDebuffsCastBy") == "player" end,
									set = function(info, value) SetBarGroupField("detectDebuffsCastBy", "player") end,
								},
								PetBuff = {
									type = "toggle", order = 15, name = L["Pet"],
									desc = L["If checked, only add bars for debuffs if cast by the player's pet."],
									get = function(info) return GetBarGroupField("detectDebuffsCastBy") == "pet" end,
									set = function(info, value) SetBarGroupField("detectDebuffsCastBy", "pet") end,
								},
								TargetBuff = {
									type = "toggle", order = 20, name = L["Target"],
									desc = L["If checked, only add bars for debuffs if cast by the target."],
									get = function(info) return GetBarGroupField("detectDebuffsCastBy") == "target" end,
									set = function(info, value) SetBarGroupField("detectDebuffsCastBy", "target") end,
								},
								FocusBuff = {
									type = "toggle", order = 25, name = L["Focus"],
									desc = L["If checked, only add bars for debuffs if cast by the focus."],
									get = function(info) return GetBarGroupField("detectDebuffsCastBy") == "focus" end,
									set = function(info, value) SetBarGroupField("detectDebuffsCastBy", "focus") end,
								},
								OurBuff = {
									type = "toggle", order = 27, name = L["Player Or Pet"],
									desc = L["If checked, only add bars for debuffs if cast by player or pet."],
									get = function(info) return GetBarGroupField("detectDebuffsCastBy") == "ours" end,
									set = function(info, value) SetBarGroupField("detectDebuffsCastBy", "ours") end,
								},
								YourBuff = {
									type = "toggle", order = 30, name = L["Other"],
									desc = L["If checked, only add bars for debuffs if cast by anyone other than the player or pet."],
									get = function(info) return GetBarGroupField("detectDebuffsCastBy") == "other" end,
									set = function(info, value) SetBarGroupField("detectDebuffsCastBy", "other") end,
								},
								AnyBuff = {
									type = "toggle", order = 35, name = L["Anyone"],
									desc = L["If checked, add bars for debuffs if cast by anyone, including player."],
									get = function(info) return GetBarGroupField("detectDebuffsCastBy") == "anyone" end,
									set = function(info, value) SetBarGroupField("detectDebuffsCastBy", "anyone") end,
								},
							},
						},
						FilterByType = {
							type = "group", order = 30, name = L["Filter By Type"], inline = true, width = "full",
							disabled = function(info) return not GetBarGroupField("detectDebuffs") end,
							args = {
								Enable = {
									type = "toggle", order = 10, name = L["Enable"],
									desc = L["Filter debuff types string"],
									get = function(info) return GetBarGroupField("filterDebuffTypes") end,
									set = function(info, v) SetBarGroupField("filterDebuffTypes", v) end,
								},
								Castable = {
									type = "toggle", order = 15, name = L["Castable"],
									disabled = function(info) return not GetBarGroupField("filterDebuffTypes") end,
									desc = L['Include debuffs that the player can cast.'],
									get = function(info) return GetBarGroupField("detectInflictable") end,
									set = function(info, value) SetBarGroupField("detectInflictable", value) end,
								},
								Dispellable = {
									type = "toggle", order = 20, name = L["Dispellable"],
									disabled = function(info) return not GetBarGroupField("filterDebuffTypes") end,
									desc = L['Include debuffs that the player can dispel.'],
									get = function(info) return GetBarGroupField("detectDispellable") end,
									set = function(info, value) SetBarGroupField("detectDispellable", value) end,
								},
								Effects = {
									type = "toggle", order = 25, name = L["Effect Timers"],
									disabled = function(info) return not GetBarGroupField("filterDebuffTypes") end,
									desc = L["If checked, include bars for effect timers triggered by a spell cast."],
									get = function(info) return GetBarGroupField("detectEffectDebuffs") end,
									set = function(info, value) SetBarGroupField("detectEffectDebuffs", value) end,
								},
								Space1 = { type = "description", name = "", order = 30 },
								Poison = {
									type = "toggle", order = 35, name = L["Poison"],
									disabled = function(info) return not GetBarGroupField("filterDebuffTypes") end,
									desc = L['Include poison debuffs.'],
									get = function(info) return GetBarGroupField("detectPoison") end,
									set = function(info, value) SetBarGroupField("detectPoison", value) end,
								},
								Curse = {
									type = "toggle", order = 40, name = L["Curse"],
									disabled = function(info) return not GetBarGroupField("filterDebuffTypes") end,
									desc = L['Include curse debuffs.'],
									get = function(info) return GetBarGroupField("detectCurse") end,
									set = function(info, value) SetBarGroupField("detectCurse", value) end,
								},
								Magic = {
									type = "toggle", order = 45, name = L["Magic"],
									disabled = function(info) return not GetBarGroupField("filterDebuffTypes") end,
									desc = L['Include magic debuffs.'],
									get = function(info) return GetBarGroupField("detectMagic") end,
									set = function(info, value) SetBarGroupField("detectMagic", value) end,
								},
								Disease = {
									type = "toggle", order = 50, name = L["Disease"],
									disabled = function(info) return not GetBarGroupField("filterDebuffTypes") end,
									desc = L['Include disease debuffs.'],
									get = function(info) return GetBarGroupField("detectDisease") end,
									set = function(info, value) SetBarGroupField("detectDisease", value) end,
								},
								Space2 = { type = "description", name = "", order = 55 },
								CastByNPC = {
									type = "toggle", order = 60, name = L["NPC"],
									disabled = function(info) return not GetBarGroupField("filterDebuffTypes") end,
									desc = L['Include debuffs cast by an NPC (note: only valid while caster is selected, such as when checking target of target).'],
									get = function(info) return GetBarGroupField("detectNPCDebuffs") end,
									set = function(info, value) SetBarGroupField("detectNPCDebuffs", value) end,
								},
								CastByVehicle = {
									type = "toggle", order = 65, name = L["Vehicle"],
									disabled = function(info) return not GetBarGroupField("filterDebuffTypes") end,
									desc = L['Include debuffs cast by a vehicle (note: only valid while caster is selected, such as when checking target of target).'],
									get = function(info) return GetBarGroupField("detectVehicleDebuffs") end,
									set = function(info, value) SetBarGroupField("detectVehicleDebuffs", value) end,
								},
								Boss = {
									type = "toggle", order = 70, name = L["Boss"],
									disabled = function(info) return not GetBarGroupField("filterDebuffTypes") end,
									desc = L['Include debuffs cast by boss.'],
									get = function(info) return GetBarGroupField("detectBoss") end,
									set = function(info, value) SetBarGroupField("detectBoss", value) end,
								},
								Other = {
									type = "toggle", order = 80, name = L["Other"], width = "half",
									disabled = function(info) return not GetBarGroupField("filterDebuffTypes") end,
									desc = L['Include other debuffs not selected with filter types.'],
									get = function(info) return GetBarGroupField("detectOtherDebuffs") end,
									set = function(info, value) SetBarGroupField("detectOtherDebuffs", value) end,
								},
							},
						},
						FilterGroup = {
							type = "group", order = 40, name = L["Filter List"], inline = true, width = "full",
							disabled = function(info) return not GetBarGroupField("detectDebuffs") end,
							args = {
								BlackList = {
									type = "toggle", order = 10, name = L["Black List"],
									desc = L["If checked, don't display any debuffs that are in the filter list."],
									get = function(info) return GetBarGroupField("filterDebuff") end,
									set = function(info, v) SetBarGroupField("filterDebuff", v); if v then SetBarGroupField("showDebuff", false) end end,
								},
								WhiteList = {
									type = "toggle", order = 11, name = L["White List"],
									desc = L["If checked, only display debuffs that are in the filter list."],
									get = function(info) return GetBarGroupField("showDebuff") end,
									set = function(info, v) SetBarGroupField("showDebuff", v); if v then SetBarGroupField("filterDebuff", false) end  end,
								},
								SpellList = {
									type = "toggle", order = 16, name = L["Use Spell List"],
									desc = L["If checked, filter list includes spells in specified spell list (these are set up on the Spells tab)."],
									disabled = function(info) return not GetBarGroupField("detectDebuffs") or not (GetBarGroupField("filterDebuff") or GetBarGroupField("showDebuff")) end,
									get = function(info) return GetBarGroupField("filterDebuffSpells") end,
									set = function(info, value) SetBarGroupField("filterDebuffSpells", value) end,
								},
								SelectSpellList = {
									type = "select", order = 18, name = L["Spell List"],
									disabled = function(info) return not GetBarGroupField("detectDebuffs") or not (GetBarGroupField("filterDebuff") or GetBarGroupField("showDebuff")) or not GetBarGroupField("filterDebuffSpells") end,
									get = function(info) local k, t = GetBarGroupField("filterDebuffTable"), GetSpellList()
										if k and not MOD.db.global.SpellLists[k] then k = nil; SetBarGroupField("filterDebuffTable", k) end
										if not k and next(t) then k = t[1]; SetBarGroupField("filterDebuffTable", k) end
										return GetSpellListEntry(k) end,
									set = function(info, value) SetBarGroupField("filterDebuffTable", GetSpellList()[value])end,
									values = function(info) return GetSpellList() end,
									style = "dropdown",
								},
								Space1 = { type = "description", name = "", order = 25 },
								AddFilter = {
									type = "input", order = 30, name = L["Enter Debuff"],
									desc = L["Enter a debuff to be added to the filter list."],
									disabled = function(info) return not GetBarGroupField("detectDebuffs") or not (GetBarGroupField("filterDebuff") or GetBarGroupField("showDebuff")) end,
									get = function(info) return nil end,
									set = function(info, value) value = ValidateSpellName(value); AddBarGroupFilter("Debuff", value) end,
								},
								SelectFilter = {
									type = "select", order = 40, name = L["Filter List"],
									disabled = function(info) return not GetBarGroupField("detectDebuffs") or not (GetBarGroupField("filterDebuff") or GetBarGroupField("showDebuff")) end,
									get = function(info) return GetBarGroupField("filterDebuffSelection") end,
									set = function(info, value) SetBarGroupField("filterDebuffSelection", value) end,
									values = function(info) return GetBarGroupFilter("Debuff") end,
									style = "dropdown",
								},
								DeleteFilter = {
									type = "execute", order = 50, name = L["Delete"], width = "half",
									disabled = function(info) return not GetBarGroupField("detectDebuffs") or not (GetBarGroupField("filterDebuff") or GetBarGroupField("showDebuff")) end,
									desc = L["Delete the selected debuff from the filter list."],
									func = function(info) DeleteBarGroupFilter("Debuff", GetBarGroupField("filterDebuffSelection")) end,
								},
								ResetFilter = {
									type = "execute", order = 60, name = L["Reset"], width = "half",
									desc = L["Reset the debuff filter list."],
									disabled = function(info) return not GetBarGroupField("detectDebuffs") or not (GetBarGroupField("filterDebuff") or GetBarGroupField("showDebuff")) end,
									confirm = function(info) return L['RESET\nAre you sure you want to reset the debuff filter list?'] end,
									func = function(info) ResetBarGroupFilter("Debuff") end,
								},
								LinkFilters = {
									type = "toggle", order = 65, name = L["Link"],
									desc = L["If checked, the filter list is shared with bar groups in other profiles with the same name."],
									disabled = function(info) return not GetBarGroupField("detectDebuffs") or not (GetBarGroupField("filterDebuff") or GetBarGroupField("showDebuff")) end,
									get = function(info) return GetBarGroupField("filterDebuffLink") end,
									set = function(info, value) SetBarGroupField("filterDebuffLink", value) end,
								},
							},
						},
						FilterBarGroup = {
							type = "group", order = 50, name = L["Filter Bar Group"], inline = true, width = "full",
							disabled = function(info) return not GetBarGroupField("detectDebuffs") end,
							args = {
								Enable = {
									type = "toggle", order = 10, name = L["Enable"],
									desc = L["Filter debuff bar group string"],
									get = function(info) return GetBarGroupField("filterDebuffBars") end,
									set = function(info, v) SetBarGroupField("filterDebuffBars", v) end,
								},
								SelectBarGroup = {
									type = "select", order = 20, name = L["Bar Group"],
									desc = L["Select filter bar group."],
									disabled = function(info) return not GetBarGroupField("detectDebuffs") or not GetBarGroupField("filterDebuffBars") end,
									get = function(info) local t = GetBarGroupList(); for k, v in pairs(t) do if v == GetBarGroupField("filterDebuffBarGroup") then return k end end end,
									set = function(info, value) SetBarGroupField("filterDebuffBarGroup", GetBarGroupList()[value]) end,
									values = function(info) return GetBarGroupList() end,
									style = "dropdown",
								},
							},
						},
					},
				},
				DetectCooldownsTab = {
					type = "group", order = 30, name = L["Cooldowns"],
					disabled = function(info) return InMode("Bar") end,
					hidden = function(info) return NoBarGroup() or not GetBarGroupField("auto") end,
					args = {
						EnableGroup = {
							type = "group", order = 1, name = L["Enable"], inline = true,
							args = {
								DetectEnable = {
									type = "toggle", order = 1, name = L["Auto Cooldowns"],
									desc = L['Enable automatically displaying bars for cooldowns that match these settings.'],
									get = function(info) return GetBarGroupField("detectCooldowns") end,
									set = function(info, value) SetBarGroupField("detectCooldowns", value) end,
								},
							},
						},
						ActionUnitGroup = {
							type = "group", order = 20, name = L["Action By"], inline = true,
							disabled = function(info) return not GetBarGroupField("detectCooldowns") end,
							args = {
								MyBuff = {
									type = "toggle", order = 10, name = L["Player"],
									desc = L["If checked, only add bars for cooldowns associated with the player."],
									get = function(info) return GetBarGroupField("detectCooldownsBy") == "player" end,
									set = function(info, value) SetBarGroupField("detectCooldownsBy", "player") end,
								},
								PetBuff = {
									type = "toggle", order = 20, name = L["Pet"],
									desc = L["If checked, only add bars for cooldowns associated with the player's pet."],
									get = function(info) return GetBarGroupField("detectCooldownsBy") == "pet" end,
									set = function(info, value) SetBarGroupField("detectCooldownsBy", "pet") end,
								},
								AnyBuff = {
									type = "toggle", order = 30, name = L["Anyone"],
									desc = L["If checked, add bars for cooldowns cast by either player or player's pet."],
									get = function(info) return GetBarGroupField("detectCooldownsBy") == "anyone" end,
									set = function(info, value) SetBarGroupField("detectCooldownsBy", "anyone") end,
								},
							},
						},
						CooldownTypeGroup = {
							type = "group", order = 30, name = L["Include"], inline = true,
							disabled = function(info) return not GetBarGroupField("detectCooldowns") end,
							args = {
								SpellCooldowns = {
									type = "toggle", order = 10, name = L["Spells"],
									desc = L["If checked, include bars for spell cooldowns."],
									get = function(info) return GetBarGroupField("detectSpellCooldowns") end,
									set = function(info, value) SetBarGroupField("detectSpellCooldowns", value) end,
								},
								TrinketCooldowns = {
									type = "toggle", order = 20, name = L["Trinkets"],
									desc = L["If checked, include bars for cooldowns on equipped trinkets."],
									get = function(info) return GetBarGroupField("detectTrinketCooldowns") end,
									set = function(info, value) SetBarGroupField("detectTrinketCooldowns", value) end,
								},
								InternalCooldowns = {
									type = "toggle", order = 25, name = L["Internal Cooldowns"],
									desc = L["If checked, include bars for internal cooldowns triggered by a buff or debuff."],
									get = function(info) return GetBarGroupField("detectInternalCooldowns") end,
									set = function(info, value) SetBarGroupField("detectInternalCooldowns", value) end,
								},
								SpellEffectCooldowns = {
									type = "toggle", order = 30, name = L["Effect Timers"],
									desc = L["If checked, include bars for effect timers triggered by a spell cast."],
									get = function(info) return GetBarGroupField("detectSpellEffectCooldowns") end,
									set = function(info, value) SetBarGroupField("detectSpellEffectCooldowns", value) end,
								},
								PotionCooldowns = {
									type = "toggle", order = 35, name = L["Potions/Elixirs"],
									desc = L["If checked, include bars for shared potion/elixir cooldowns (an item subject to the shared cooldown must be in your bags in order for the cooldown to be detected)."],
									get = function(info) return GetBarGroupField("detectPotionCooldowns") end,
									set = function(info, value) SetBarGroupField("detectPotionCooldowns", value) end,
								},
								OtherCooldowns = {
									type = "toggle", order = 40, name = L["Other"],
									desc = L["If checked, include bars for other cooldowns (for item cooldowns, an item subject to the cooldown must be in your bags in order for the cooldown to be detected)."],
									get = function(info) return GetBarGroupField("detectOtherCooldowns") end,
									set = function(info, value) SetBarGroupField("detectOtherCooldowns", value) end,
								},
							},
						},
						SharedCooldownGroup = {
							type = "group", order = 30, name = L["Shared Cooldowns"], inline = true,
							disabled = function(info) return not GetBarGroupField("detectCooldowns") end,
							args = {
								FrostTrapsCooldowns = {
									type = "toggle", order = 10, name = L["Frost Traps"],
									desc = L["If checked, only show one cooldown for hunter Frost Traps."],
									get = function(info) return GetBarGroupField("detectSharedFrostTraps") end,
									set = function(info, value) SetBarGroupField("detectSharedFrostTraps", value) end,
								},
								FireTrapsCooldowns = {
									type = "toggle", order = 15, name = L["Fire Traps"],
									desc = L["If checked, only show one cooldown for hunter Fire Traps."],
									get = function(info) return GetBarGroupField("detectSharedFireTraps") end,
									set = function(info, value) SetBarGroupField("detectSharedFireTraps", value) end,
								},
								ShockCooldowns = {
									type = "toggle", order = 20, name = L["Shocks"],
									desc = L["If checked, only show one cooldown for shaman Shocks."],
									get = function(info) return GetBarGroupField("detectSharedShocks") end,
									set = function(info, value) SetBarGroupField("detectSharedShocks", value) end,
								},
								StanceCooldowns = {
									type = "toggle", order = 20, name = L["Stances"],
									desc = L["If checked, only show one cooldown for warrior Stances."],
									get = function(info) return GetBarGroupField("detectSharedStances") end,
									set = function(info, value) SetBarGroupField("detectSharedStances", value) end,
								},
								ShoutCooldowns = {
									type = "toggle", order = 20, name = L["Shouts"],
									desc = L["If checked, only show one cooldown for warrior Shouts."],
									get = function(info) return GetBarGroupField("detectSharedShouts") end,
									set = function(info, value) SetBarGroupField("detectSharedShouts", value) end,
								},
								PallyCooldowns = {
									type = "toggle", order = 25, name = L["Crusader/Hammer"],
									desc = L["If checked, only show one cooldown for paladin Crusader Strike and Hammer of the Righteous."],
									get = function(info) return GetBarGroupField("detectSharedCrusader") end,
									set = function(info, value) SetBarGroupField("detectSharedCrusader", value) end,
								},
							},
						},
						FilterGroup = {
							type = "group", order = 40, name = L["Filter List"], inline = true, width = "full",
							disabled = function(info) return not GetBarGroupField("detectCooldowns") end,
							args = {
								BlackList = {
									type = "toggle", order = 10, name = L["Black List"],
									desc = L["If checked, don't display any cooldowns that are in the filter list."],
									get = function(info) return GetBarGroupField("filterCooldown") end,
									set = function(info, v) SetBarGroupField("filterCooldown", v); if v then SetBarGroupField("showCooldown", false) end end,
								},
								WhiteList = {
									type = "toggle", order = 11, name = L["White List"],
									desc = L["If checked, only display cooldowns that are in the filter list."],
									get = function(info) return GetBarGroupField("showCooldown") end,
									set = function(info, v) SetBarGroupField("showCooldown", v); if v then SetBarGroupField("filterCooldown", false) end  end,
								},
								SpellList = {
									type = "toggle", order = 16, name = L["Use Spell List"],
									desc = L["If checked, filter list includes spells in specified spell list (these are set up on the Spells tab)."],
									disabled = function(info) return not GetBarGroupField("detectCooldowns") or not (GetBarGroupField("filterCooldown") or GetBarGroupField("showCooldown")) end,
									get = function(info) return GetBarGroupField("filterCooldownSpells") end,
									set = function(info, value) SetBarGroupField("filterCooldownSpells", value) end,
								},
								SelectSpellList = {
									type = "select", order = 18, name = L["Spell List"],
									disabled = function(info) return not GetBarGroupField("detectCooldowns") or not (GetBarGroupField("filterCooldown") or GetBarGroupField("showCooldown")) or not GetBarGroupField("filterCooldownSpells") end,
									get = function(info) local k, t = GetBarGroupField("filterCooldownTable"), GetSpellList()
										if k and not MOD.db.global.SpellLists[k] then k = nil; SetBarGroupField("filterCooldownTable", k) end
										if not k and next(t) then k = t[1]; SetBarGroupField("filterCooldownTable", k) end
										return GetSpellListEntry(k) end,
									set = function(info, value) SetBarGroupField("filterCooldownTable", GetSpellList()[value])end,
									values = function(info) return GetSpellList() end,
									style = "dropdown",
								},
								Space1 = { type = "description", name = "", order = 25 },
								AddFilter = {
									type = "input", order = 30, name = L["Enter Cooldown"],
									desc = L["Enter a cooldown to be added to the filter list."],
									disabled = function(info) return not GetBarGroupField("detectCooldowns") or not (GetBarGroupField("filterCooldown") or GetBarGroupField("showCooldown"))end,
									get = function(info) return nil end,
									set = function(info, value) AddBarGroupFilter("Cooldown", value) end, -- don't validate spell names for cooldowns
								},
								SelectFilter = {
									type = "select", order = 40, name = L["Filter List"],
									disabled = function(info) return not GetBarGroupField("detectCooldowns") or not (GetBarGroupField("filterCooldown") or GetBarGroupField("showCooldown"))end,
									get = function(info) return GetBarGroupField("filterCooldownSelection") end,
									set = function(info, value) SetBarGroupField("filterCooldownSelection", value) end,
									values = function(info) return GetBarGroupFilter("Cooldown") end,
									style = "dropdown",
								},
								DeleteFilter = {
									type = "execute", order = 50, name = L["Delete"], width = "half",
									disabled = function(info) return not GetBarGroupField("detectCooldowns") or not (GetBarGroupField("filterCooldown") or GetBarGroupField("showCooldown"))end,
									desc = L["Delete the selected cooldown from the filter list."],
									func = function(info) DeleteBarGroupFilter("Cooldown", GetBarGroupField("filterCooldownSelection")) end,
								},
								ResetFilter = {
									type = "execute", order = 60, name = L["Reset"], width = "half",
									desc = L["Reset the cooldown filter list."],
									disabled = function(info) return not GetBarGroupField("detectCooldowns") or not (GetBarGroupField("filterCooldown") or GetBarGroupField("showCooldown"))end,
									confirm = function(info) return 'RESET\nAre you sure you want to reset the cooldown filter list?' end,
									func = function(info) ResetBarGroupFilter("Cooldown") end,
								},
								LinkFilters = {
									type = "toggle", order = 65, name = L["Link"],
									desc = L["If checked, the filter list is shared with bar groups in other profiles with the same name."],
									disabled = function(info) return not GetBarGroupField("detectCooldowns") or not (GetBarGroupField("filterCooldown") or GetBarGroupField("showCooldown"))end,
									get = function(info) return GetBarGroupField("filterCooldownLink") end,
									set = function(info, value) SetBarGroupField("filterCooldownLink", value) end,
								},
							},
						},
						FilterBarGroup = {
							type = "group", order = 50, name = L["Filter Bar Group"], inline = true, width = "full",
							disabled = function(info) return not GetBarGroupField("detectCooldowns") end,
							args = {
								Enable = {
									type = "toggle", order = 10, name = L["Enable"],
									desc = L["Filter cooldown bar group string"],
									get = function(info) return GetBarGroupField("filterCooldownBars") end,
									set = function(info, v) SetBarGroupField("filterCooldownBars", v) end,
								},
								SelectBarGroup = {
									type = "select", order = 20, name = L["Bar Group"],
									desc = L["Select filter bar group."],
									disabled = function(info) return not GetBarGroupField("detectCooldowns") or not GetBarGroupField("filterCooldownBars") end,
									get = function(info) local t = GetBarGroupList(); for k, v in pairs(t) do if v == GetBarGroupField("filterCooldownBarGroup") then return k end end end,
									set = function(info, value) SetBarGroupField("filterCooldownBarGroup", GetBarGroupList()[value]) end,
									values = function(info) return GetBarGroupList() end,
									style = "dropdown",
								},
							},
						},
					},
				},
				LayoutTab = {
					type = "group", order = 40, name = L["Layout"],
					disabled = function(info) return InMode("Bar") end,
					hidden = function(info) return NoBarGroup() or GetBarGroupField("merged") end,
					args = {
						ConfigurationGroup = {
							type = "group", order = 10, name = L["Configuration"], inline = true,
							args = {
								BarConfiguration = {
									type = "toggle", order = 10, name = L["Bars"], width = "half",
									desc = L["If checked, use a bar-oriented configuration."],
									get = function(info)
										local config = Nest_SupportedConfigurations[GetBarGroupField("configuration")]
										return not config.iconOnly
									end,
									set = function(info, value)
										local config = Nest_SupportedConfigurations[GetBarGroupField("configuration")]
										if config.iconOnly then SetBarGroupField("configuration", 1) end
									end,
								},
								IconConfiguration = {
									type = "toggle", order = 15, name = L["Icons"], width = "half",
									desc = L["If checked, use an icon-oriented configuration."],
									get = function(info)
										local config = Nest_SupportedConfigurations[GetBarGroupField("configuration")]
										return config.iconOnly
									end,
									set = function(info, value)
										local config = Nest_SupportedConfigurations[GetBarGroupField("configuration")]
										if not config.iconOnly then SetBarGroupField("configuration", 9) end
									end,
								},
								Configuration = {
									type = "select", order = 20, name = L["Options"], width = "double",
									desc = L["Select a configuration option for bars or icons."],
									get = function(info) return GetBarGroupField("configuration") end,
									set = function(info, value) SetBarGroupField("configuration", value) end,
									values = function(info)
										local config = Nest_SupportedConfigurations[GetBarGroupField("configuration")]
										return GetOrientationList(config.iconOnly)
									end,
									style = "dropdown",
								},
								ReverseGrowthGroup = {
									type = "toggle", order = 25, name = L["Direction"], width = "half",
									desc = L["If checked, grow up or to the right, otherwise grow down or to the left."],
									get = function(info) return GetBarGroupField("growDirection") end,
									set = function(info, value) SetBarGroupField("growDirection", value) end,
								},
								SnapCenter = {
									type = "toggle", order = 30, name = L["Center"], width = "half",
									desc = L["If checked and the icon configuration bar group is locked, snap to center at the anchor position."],
									disabled = function() local t = Nest_SupportedConfigurations[GetBarGroupField("configuration")]; return not t.iconOnly end,
									get = function(info) return GetBarGroupField("snapCenter") end,
									set = function(info, value) SetBarGroupField("snapCenter", value) end,
								},
								FillBars = {
									type = "toggle", order = 32, name = L["Fill"], width = "half",
									desc = L["If checked then timer bars fill up, otherwise they empty."],
									get = function(info) return GetBarGroupField("fillBars") end,
									set = function(info, value) SetBarGroupField("fillBars", value) end,
								},
								Space1 = { type = "description", name = "", order = 35 },
								MaxBars = {
									type = "range", order = 40, name = L["Bar/Icon Limit"], min = 0, max = 100, step = 1,
									desc = L["Set the maximum number of bars/icons to display (the ones that sort closest to the anchor have priority). If this is set to 0 then the number is not limited."],
									get = function(info) return GetBarGroupField("maxBars") end,
									set = function(info, value) SetBarGroupField("maxBars", value) end,
								},
								Wrap = {
									type = "range", order = 50, name = L["Wrap"], min = 0, max = 50, step = 1,
									desc = L["Set how many bars/icons to display before wrapping to next row or column. If this is set to 0 then wrapping is disabled."],
									get = function(info) return GetBarGroupField("wrap") end,
									set = function(info, value) SetBarGroupField("wrap", value) end,
								},
								WrapDirection = {
									type = "toggle", order = 55, name = L["Wrap Direction"],
									desc = L["If checked, wrap up when arranged in rows or to the right when arranged in columns, otherwise wrap down or to the left."],
									get = function(info) return GetBarGroupField("wrapDirection") end,
									set = function(info, value) SetBarGroupField("wrapDirection", value) end,
								},
								CopyLayoutGroup = {
									type = "select", order = 90, name = L["Copy Layout From"],
									desc = L["Select bar group to copy all layout settings from."],
									get = function(info) return nil end,
									set = function(info, value) CopyBarGroupConfiguration(GetBarGroupList()[value]) end,
									values = function(info) return GetBarGroupList() end,
									style = "dropdown",
								},
								TestGroup = {
									type = "group", order = 95, name = L["Test Mode"], inline = true,
									args = {
										StaticBars = {
											type = "range", order = 10, name = L["Unlimited Duration"], min = 0, max = 100, step = 1,
											desc = L["Set the number of unlimited duration bars/icons to generate in test mode."],
											get = function(info) return GetBarGroupField("testStatic") end,
											set = function(info, value) SetBarGroupField("testStatic", value) end,
										},
										TimerBars = {
											type = "range", order = 20, name = L["Timers"], min = 0, max = 100, step = 1,
											desc = L["Set the number of timer bars/icons to generate in test mode."],
											get = function(info) return GetBarGroupField("testTimers") end,
											set = function(info, value) SetBarGroupField("testTimers", value) end,
										},
										LoopTimers = {
											type = "toggle", order = 30, name = L["Refresh Timers"],
											desc = L["If checked, timers are refreshed when they expire, otherwise they disappear."],
											get = function(info) return GetBarGroupField("testLoop") end,
											set = function(info, value) SetBarGroupField("testLoop", value) end,
										},
										TestToggle = {
											type = "execute", order = 40, name = L["Toggle Test Mode"],
											desc = L["Toggle display of test bars/icons."],
											func = function(info) MOD:TestBarGroup(GetBarGroupEntry()); MOD:UpdateAllBarGroups() end,
										},
									},
								},
								TimelineGroup = {
									type = "group", order = 100, name = L["Timeline"], inline = true,
									hidden = function() local t = Nest_SupportedConfigurations[GetBarGroupField("configuration")]; return t.bars ~= "timeline" end,
									args = {
										BarWidth = {
											type = "range", order = 1, name = L["Width"], min = 5, max = 500, step = 1,
											desc = L["Set width of timeline."],
											get = function(info) return GetBarGroupField("timelineWidth") end,
											set = function(info, value) SetBarGroupField("timelineWidth", value) end,
										},
										BarHeight = {
											type = "range", order = 5, name = L["Height"], min = 5, max = 100, step = 1,
											desc = L["Set height of timeline."],
											get = function(info) return GetBarGroupField("timelineHeight") end,
											set = function(info, value) SetBarGroupField("timelineHeight", value) end,
										},
										MaxSeconds = {
											type = "range", order = 10, name = L["Duration"], min = 5, max = 600, step = 1,
											desc = L["Set maximum duration represented on the timeline in seconds."],
											get = function(info) return GetBarGroupField("timelineDuration") end,
											set = function(info, value) SetBarGroupField("timelineDuration", value) end,
										},
										Exponent = {
											type = "range", order = 15, name = L["Exponent"], min = 1, max = 10, step = 0.25,
											desc = L["Set exponent factor for timeline to adjust time scale."],
											get = function(info) return GetBarGroupField("timelineExp") end,
											set = function(info, value) SetBarGroupField("timelineExp", value) end,
										},
										Texture = {
											type = "select", order = 20, name = L["Texture"], 
											desc = L["Select texture for timeline."],
											dialogControl = 'LSM30_Statusbar',
											values = AceGUIWidgetLSMlists.statusbar,
											get = function(info) return GetBarGroupField("timelineTexture") end,
											set = function(info, value) SetBarGroupField("timelineTexture", value) end,
										},
										Alpha = {
											type = "range", order = 25, name = L["Opacity"], min = 0, max = 1, step = 0.05,
											desc = L["Set opacity for timeline."],
											get = function(info) return GetBarGroupField("timelineAlpha") end,
											set = function(info, value) SetBarGroupField("timelineAlpha", value) end,
										},
										Color = {
											type = "color", order = 27, name = L["Timeline Color"], hasAlpha = true,
											desc = L["Set color for timeline background."],
											get = function(info)
												local t = GetBarGroupField("timelineColor"); if t then return t.r, t.g, t.b, t.a else return 0.5, 0.5, 0.5, 0.5 end
											end,
											set = function(info, r, g, b, a)
												local t = GetBarGroupField("timelineColor"); if t then t.r = r; t.g = g; t.b = b; t.a = a else
													t = { r = r, g = g, b = b, a = a }; SetBarGroupField("timelineColor", t) end
												MOD:UpdateAllBarGroups()
											end,
										},
										Space1 = { type = "description", name = "", order = 30 },
										SplashEffect = {
											type = "toggle", order = 45, name = L["Splash Effect"],
											desc = L["If checked, show a splash effect when icons expire."],
											get = function(info) return GetBarGroupField("timelineSplash") end,
											set = function(info, value) SetBarGroupField("timelineSplash", value) end,
										},
										HideEmpty = {
											type = "toggle", order = 50, name = L["Hide Empty"],
											desc = L["If checked, hide the timeline background when there are no active icons."],
											get = function(info) return GetBarGroupField("timelineHide") end,
											set = function(info, value) SetBarGroupField("timelineHide", value) end,
										},
										Switcher = {
											type = "toggle", order = 55, name = L["Overlap Switch"],
											desc = L["If checked, when icons mostly overlap, switch which is shown on top (otherwise always show icon with shortest time remaining on top)."],
											get = function(info) return GetBarGroupField("timelineAlternate") end,
											set = function(info, value) SetBarGroupField("timelineAlternate", value) end,
										},
										SwitchTime = {
											type = "range", order = 60, name = L["Switch Time"], min = 0.5, max = 10, step = 0.5,
											desc = L["Set time between switching mostly overlapping icons."],
											disabled = function(info) return not GetBarGroupField("timelineAlternate") end,
											get = function(info) return GetBarGroupField("timelineSwitch") or 2 end,
											set = function(info, value) SetBarGroupField("timelineSwitch", value or 2) end,
										},
										Space2 = { type = "description", name = "", order = 70 },
										LabelList = {
											type = "input", order = 75, name = L["Label List"], width = "double",
											desc = L['Enter comma-separated list of times to show as labels on the timeline (times are in seconds unless you include "m", which is included in the label, or "M", which is hidden, for minutes).'],
											get = function(info) return GetListString(GetBarGroupField("timelineLabels") or MOD:GetTimelineLabels()) end,
											set = function(info, v) SetBarGroupField("timelineLabels", GetListTable(v, "strings")) end,
										},
									},
								},
							},
						},
						DimensionGroup = {
							type = "group", order = 20, name = L["Format"], inline = true,
							args = {
								UseDefaultsGroup = {
									type = "toggle", order = 1, name = L["Use Defaults"],
									desc = L["If checked, format options are set to default values."],
									get = function(info) return GetBarGroupField("useDefaultDimensions") end,
									set = function(info, value) SetBarGroupField("useDefaultDimensions", value) end,
								},
								RestoreDefaults = {
									type = "execute", order = 5, name = L["Restore Defaults"],
									desc = L["Reset format for this bar group back to the current defaults."],
									disabled = function(info) return GetBarGroupField("useDefaultDimensions") end,
									func = function(info) MOD:CopyDimensions(MOD.db.global.Defaults, GetBarGroupEntry()); MOD:UpdateAllBarGroups() end,
								},
								Space1 = { type = "description", name = "", order = 10 },
								BarWidth = {
									type = "range", order = 20, name = L["Bar Width"], min = 5, max = 500, step = 1,
									desc = L["Set width of bars."],
									disabled = function(info) return GetBarGroupField("useDefaultDimensions") end,
									get = function(info) return GetBarGroupField("barWidth") end,
									set = function(info, value) SetBarGroupField("barWidth", value) end,
								},
								BarHeight = {
									type = "range", order = 25, name = L["Bar Height"], min = 5, max = 100, step = 1,
									desc = L["Set height of bars."],
									disabled = function(info) return GetBarGroupField("useDefaultDimensions") end,
									get = function(info) return GetBarGroupField("barHeight") end,
									set = function(info, value) SetBarGroupField("barHeight", value) end,
								},
								IconSize = {
									type = "range", order = 30, name = L["Icon Size"], min = 5, max = 100, step = 1,
									desc = L["Set width/height for icons."],
									disabled = function(info) return GetBarGroupField("useDefaultDimensions") end,
									get = function(info) return GetBarGroupField("iconSize") end,
									set = function(info, value) SetBarGroupField("iconSize", value) end,
								},
								Scale = {
									type = "range", order = 35, name = L["Scale"], min = 0.1, max = 2, step = 0.05,
									desc = L["Set scale factor for bars and icons."],
									disabled = function(info) return GetBarGroupField("useDefaultDimensions") end,
									get = function(info) return GetBarGroupField("scale") end,
									set = function(info, value) SetBarGroupField("scale", value) end,
								},
								Space2 = { type = "description", name = "", order = 40 },
								HorizontalSpacing = {
									type = "range", order = 60, name = L["Horizontal Spacing"], min = -100, max = 100, step = 1,
									desc = L["Adjust horizontal spacing between bars."],
									disabled = function(info) return GetBarGroupField("useDefaultDimensions") end,
									get = function(info) return GetBarGroupField("spacingX") end,
									set = function(info, value) SetBarGroupField("spacingX", value) end,
								},
								VerticalSpacing = {
									type = "range", order = 65, name = L["Vertical Spacing"], min = -100, max = 100, step = 1,
									desc = L["Adjust vertical spacing between bars."],
									disabled = function(info) return GetBarGroupField("useDefaultDimensions") end,
									get = function(info) return GetBarGroupField("spacingY") end,
									set = function(info, value) SetBarGroupField("spacingY", value) end,
								},
								IconOffsetX = {
									type = "range", order = 70, name = L["Icon Inset"], min = -200, max = 200, step = 1,
									desc = L["Set icon's horizontal inset from bar."],
									disabled = function(info) return GetBarGroupField("useDefaultDimensions") end,
									get = function(info) return GetBarGroupField("iconOffsetX") end,
									set = function(info, value) SetBarGroupField("iconOffsetX", value) end,
								},
								IconOffsetY = {
									type = "range", order = 75, name = L["Icon Offset"], min = -200, max = 200, step = 1,
									desc = L["Set vertical offset between icon and bar."],
									disabled = function(info) return GetBarGroupField("useDefaultDimensions") end,
									get = function(info) return GetBarGroupField("iconOffsetY") end,
									set = function(info, value) SetBarGroupField("iconOffsetY", value) end,
								},
								Space2 = { type = "description", name = "", order = 80 },
								BarFormatGroup = {
									type = "group", order = 90, name = "", inline = true,
									disabled = function(info) return GetBarGroupField("useDefaultDimensions") end,
									args = {
										HideIconGroup = {
											type = "toggle", order = 30, name = L["Icon"], width = "half",
											desc = L["Show icon string"],
											get = function(info) return not GetBarGroupField("hideIcon") end,
											set = function(info, value) SetBarGroupField("hideIcon", not value) end,
										},
										HideClockGroup = {
											type = "toggle", order = 31, name = L["Clock"], width = "half",
											desc = L["Show clock animation on icons for timer bars."],
											disabled = function(info) local t = Nest_SupportedConfigurations[GetBarGroupField("configuration")];
												return GetBarGroupField("useDefaultDimensions") or t.bars == "timeline" end,
											get = function(info) return not GetBarGroupField("hideClock") end,
											set = function(info, value) SetBarGroupField("hideClock", not value) end,
										},
										HideBarGroup = {
											type = "toggle", order = 32, name = L["Bar"], width = "half",
											desc = L["Show colored bar and background."],
											get = function(info) return not GetBarGroupField("hideBar") end,
											set = function(info, value) SetBarGroupField("hideBar", not value) end,
										},
										HideSparkGroup = {
											type = "toggle", order = 33, name = L["Spark"], width = "half",
											desc = L["Show spark that moves across bars to indicate remaining time."],
											disabled = function(info) return GetBarGroupField("useDefaultDimensions") or GetBarGroupField("hideBar") end,
											get = function(info) return not GetBarGroupField("hideSpark") end,
											set = function(info, value) SetBarGroupField("hideSpark", not value) end,
										},
										HideLabelGroup = {
											type = "toggle", order = 34, name = L["Label"], width = "half",
											desc = L["Show label text on bars."],
											get = function(info) return not GetBarGroupField("hideLabel") end,
											set = function(info, value) SetBarGroupField("hideLabel", not value) end,
										},
										HideCountGroup = {
											type = "toggle", order = 35, name = L["Count"], width = "half",
											desc = L["Show stack count in parentheses after label (it is also displayed as overlay on icon)."],
											get = function(info) return not GetBarGroupField("hideCount") end,
											set = function(info, value) SetBarGroupField("hideCount", not value) end,
										},
										HideTimerGroup = {
											type = "toggle", order = 36, name = L["Time"], width = "half",
											desc = L["Show time left on bars that have a duration."],
											get = function(info) return not GetBarGroupField("hideValue") end,
											set = function(info, value) SetBarGroupField("hideValue", not value) end,
										},
										TooltipsGroup = {
											type = "toggle", order = 37, name = L["Tooltips"], width = "half",
											desc = L["Show tooltips when the cursor is over a bar's icon."],
											get = function(info) return GetBarGroupField("showTooltips") end,
											set = function(info, value) SetBarGroupField("showTooltips", value) end,
										},
									},
								},
							},
						},
						TextSettings = {
							type = "group", order = 30, name = L["Text Settings"], inline = true,
							args = {
								LabelInset = {
									type = "range", order = 10, name = L["Label Text Inset"], min = -200, max = 200, step = 1,
									desc = L["Set horizontal inset for label from edge of bar."],
									get = function(info) return GetBarGroupField("labelInset") end,
									set = function(info, value) SetBarGroupField("labelInset", value) end,
								},
								LabelOffset = {
									type = "range", order = 15, name = L["Label Text Offset"], min = -200, max = 200, step = 1,
									desc = L["Set vertical offset for label text from center of bar."],
									get = function(info) return GetBarGroupField("labelOffset") end,
									set = function(info, value) SetBarGroupField("labelOffset", value) end,
								},
								LabelWrapGroup = {
									type = "toggle", order = 20, name = L["Wrap"], width = "half",
									desc = L["If checked, wrap label text when it doesn't fit in the bar's width."],
									get = function(info) return GetBarGroupField("labelWrap") end,
									set = function(info, value) SetBarGroupField("labelWrap", value) end,
								},
								LabelTopGroup = {
									type = "toggle", order = 21, name = L["Top"], width = "half",
									desc = L["If checked, set \"Top\" vertical alignment for label text."],
									get = function(info) return GetBarGroupField("labelAlign") == "TOP" end,
									set = function(info, value) SetBarGroupField("labelAlign", "TOP") end,
								},
								LabelMiddleGroup = {
									type = "toggle", order = 22, name = L["Middle"], width = "half",
									desc = L["If checked, set \"Middle\" vertical alignment for label text."],
									get = function(info) return GetBarGroupField("labelAlign") == "MIDDLE" end,
									set = function(info, value) SetBarGroupField("labelAlign", "MIDDLE") end,
								},
								LabelBottomGroup = {
									type = "toggle", order = 23, name = L["Bottom"], width = "half",
									desc = L["If checked, set \"Bottom\" vertical alignment for label text."],
									get = function(info) return GetBarGroupField("labelAlign") == "BOTTOM" end,
									set = function(info, value) SetBarGroupField("labelAlign", "BOTTOM") end,
								},
								LabelCenterGroup = {
									type = "toggle", order = 24, name = L["Center"], width = "half",
									desc = L["If checked, set \"Center\" horizontal alignment for label text, otherwise align based on bar layout (only applies to bar configurations because icon configurations default to \"Center\" horizontal alignment for labels)."],
									get = function(info) return GetBarGroupField("labelCenter") end,
									set = function(info, value) SetBarGroupField("labelCenter", value) end,
								},
								Space1 = { type = "description", name = "", order = 30 },
								TimeTextInset = {
									type = "range", order = 40, name = L["Time Text Inset"], min = -200, max = 200, step = 1,
									desc = L["Set horizontal inset for time text from edge of bar."],
									get = function(info) return GetBarGroupField("timeInset") end,
									set = function(info, value) SetBarGroupField("timeInset", value) end,
								},
								TimeTextOffset = {
									type = "range", order = 45, name = L["Time Text Offset"], min = -200, max = 200, step = 1,
									desc = L["Set vertical offset for time text from center of bar."],
									get = function(info) return GetBarGroupField("timeOffset") end,
									set = function(info, value) SetBarGroupField("timeOffset", value) end,
								},
								TimeNormalGroup = {
									type = "toggle", order = 46, name = L["Normal"], width = "half",
									desc = L["If checked, use normal alignment with small inset for time and label texts."],
									get = function(info) return GetBarGroupField("timeAlign") == "normal" end,
									set = function(info, value) SetBarGroupField("timeAlign", "normal") end,
								},
								TimeLeftGroup = {
									type = "toggle", order = 47, name = L["Left"], width = "half",
									desc = L["If checked, set \"Left\" alignment for time text and normal alignment for label."],
									get = function(info) return GetBarGroupField("timeAlign") == "LEFT" end,
									set = function(info, value) SetBarGroupField("timeAlign", "LEFT") end,
								},
								TimeCenterGroup = {
									type = "toggle", order = 48, name = L["Center"], width = "half",
									desc = L["If checked, set \"Center\" alignment for time text and normal alignment for label."],
									get = function(info) return GetBarGroupField("timeAlign") == "CENTER" end,
									set = function(info, value) SetBarGroupField("timeAlign", "CENTER") end,
								},
								TimeRightGroup = {
									type = "toggle", order = 49, name = L["Right"], width = "half",
									desc = L["If checked, set \"Right\" alignment for time text and normal alignment for label."],
									get = function(info) return GetBarGroupField("timeAlign") == "RIGHT" end,
									set = function(info, value) SetBarGroupField("timeAlign", "RIGHT") end,
								},
								TimeIconGroup = {
									type = "toggle", order = 50, name = L["Icon"], width = "half",
									desc = L["If checked, time text is shown on the icon instead of the bar."],
									disabled = function(info)
										local config = GetBarGroupField("configuration")
										if config then return Nest_SupportedConfigurations[config].iconOnly else return true end
									end,
									get = function(info) return GetBarGroupField("timeIcon") end,
									set = function(info, value) SetBarGroupField("timeIcon", value) end,
								},
								Space2 = { type = "description", name = "", order = 55 },
								IconTextInset = {
									type = "range", order = 60, name = L["Icon Text Inset"], min = -200, max = 200, step = 1,
									desc = L["Set horizontal inset for icon text from middle of icon."],
									get = function(info) return GetBarGroupField("iconInset") end,
									set = function(info, value) SetBarGroupField("iconInset", value) end,
								},
								IconTextOffset = {
									type = "range", order = 65, name = L["Icon Text Offset"], min = -200, max = 200, step = 1,
									desc = L["Set vertical offset for icon text from center of icon."],
									get = function(info) return GetBarGroupField("iconOffset") end,
									set = function(info, value) SetBarGroupField("iconOffset", value) end,
								},
								IconTextHide = {
									type = "toggle", order = 66, name = L["Hide"], width = "half",
									desc = L["If checked, hide count overlay text on icon."],
									get = function(info) return GetBarGroupField("iconHide") end,
									set = function(info, value) SetBarGroupField("iconHide", value) end,
								},
								IconTextLeft = {
									type = "toggle", order = 67, name = L["Left"], width = "half",
									desc = L["If checked, set \"Left\" alignment for icon text."],
									get = function(info) return GetBarGroupField("iconAlign") == "LEFT" end,
									set = function(info, value) SetBarGroupField("iconAlign", "LEFT") end,
								},
								IconTextCenter = {
									type = "toggle", order = 68, name = L["Center"], width = "half",
									desc = L["If checked, set \"Center\" alignment for icon text."],
									get = function(info) return GetBarGroupField("iconAlign") == "CENTER" end,
									set = function(info, value) SetBarGroupField("iconAlign", "CENTER") end,
								},
								IconTextRight = {
									type = "toggle", order = 69, name = L["Right"], width = "half",
									desc = L["If checked, set \"Right\" alignment for icon text."],
									get = function(info) return GetBarGroupField("iconAlign") == "RIGHT" end,
									set = function(info, value) SetBarGroupField("iconAlign", "RIGHT") end,
								},
							},
						},
						AnchorGroup = {
							type = "group", order = 40, name = L["Attachment"], inline = true,
							args = {
								ParentFrame = {
									type = "input", order = 5, name = L["Parent Frame"],
									desc = L["Enter name of parent frame for this bar group (leave blank to use default)."],
									validate = function(info, n) if not n or (n == "") or GetClickFrame(n) then return true end end,
									get = function(info) return GetBarGroupField("parentFrame") end,
									set = function(info, value) if value == "" then value = nil end; SetBarGroupField("parentFrame", value) end,
								},
								AnchorFrame = {
									type = "input", order = 10, name = L["Anchor Frame"],
									desc = L["Enter name of anchor frame to attach to (leave blank to enable bar group attachment)."],
									validate = function(info, n) if not n or (n == "") or GetClickFrame(n) then return true end end,
									get = function(info) return GetBarGroupField("anchorFrame") end,
									set = function(info, value) if value == "" then value = nil end; SetBarGroupField("anchorFrame", value) end,
								},
								AnchorPoint = {
									type = "select", order = 20, name = L["Anchor Point"],
									desc = L["Select point on anchor frame to attach to."],
									disabled = function(info) return not GetBarGroupField("anchorFrame") end,
									get = function(info) return GetBarGroupField("anchorPoint") or "CENTER" end,
									set = function(info, value) SetBarGroupField("anchorPoint", value) end,
									values = function(info) return anchorPoints end,
									style = "dropdown",
								},
								FrameStack = {
									type = "execute", order = 22, name = L["Frame Stack"],
									desc = L["Toggle showing Blizzard's frame stack tooltips."],
									func = function(info) UIParentLoadAddOn("Blizzard_DebugTools"); FrameStackTooltip_Toggle() end,
								},
								Space1 = { type = "description", name = "", order = 25 },
								Anchor = {
									type = "select", order = 30, name = L["Bar Group"],
									desc = L["Select a bar group to attach to (for independent position, attach to self)."],
									disabled = function(info) return GetBarGroupField("anchorFrame") end,
									get = function(info) return GetBarGroupAnchor() end,
									set = function(info, value) SetBarGroupAnchor(value) end,
									values = function(info) return GetBarGroupList() end,
									style = "dropdown",
								},
								Empty = {
									type = "toggle", order = 40, name = L["Empty"], width = "half",
									desc = L["If checked, offsets are not applied if the selected bar group is empty."],
									disabled = function(info) return not GetBarGroupField("anchor") end,
									get = function(info) return GetBarGroupField("anchorEmpty") end,
									set = function(info, value) SetBarGroupField("anchorEmpty", value) end,
								},
								Relative = {
									type = "toggle", order = 42, name = L["Last Bar"], width = "half",
									desc = L["If checked, position is relative to last bar/icon in the selected bar group."],
									disabled = function() return not GetBarGroupField("anchor") end,
									get = function(info) return GetBarGroupField("anchorLastBar") end,
									set = function(info, value) SetBarGroupField("anchorLastBar", value) end,
								},
								WrapRow = {
									type = "toggle", order = 45, name = L["By Row"], width = "half",
									desc = L["When wrap is enabled in the selected bar group, position is relative to last bar/icon in row closest to the anchor."],
									disabled = function() return not GetBarGroupField("anchor") or not GetBarGroupField("anchorLastBar") end,
									get = function(info) return GetBarGroupField("anchorRow") end,
									set = function(info, value) SetBarGroupField("anchorRow", value); SetBarGroupField("anchorColumn", not value) end,
								},
								WrapColumn = {
									type = "toggle", order = 50, name = L["By Column"],
									desc = L["When wrap is enabled in the selected bar group, position is relative to last bar/icon in column closest to the anchor."],
									disabled = function() return not GetBarGroupField("anchor") or not GetBarGroupField("anchorLastBar") end,
									get = function(info) return GetBarGroupField("anchorColumn") end,
									set = function(info, value) SetBarGroupField("anchorColumn", value); SetBarGroupField("anchorRow", not value) end,
								},
								Space2 = { type = "description", name = "", order = 60 },
								OffsetX = {
									type = "range", order = 70, name = L["Offset X"], min = -500, max = 500, step = 0.01,
									desc = L["Set horizontal offset from the selected bar group."],
									disabled = function(info) return not GetBarGroupField("anchor") and not GetBarGroupField("anchorFrame") end,
									get = function(info) return GetBarGroupField("anchorX") end,
									set = function(info, value) SetBarGroupField("anchorX", value) end,
								},
								OffsetY = {
									type = "range", order = 80, name = L["Offset Y"], min = -500, max = 500, step = 0.01,
									desc = L["Set vertical offset from the selected bar group."],
									disabled = function(info) return not GetBarGroupField("anchor") and not GetBarGroupField("anchorFrame") end,
									get = function(info) return GetBarGroupField("anchorY") end,
									set = function(info, value) SetBarGroupField("anchorY", value) end,
								},
								ResetAnchor = {
									type = "execute", order = 90, name = L["Reset"], width = "half",
									desc = L["Reset attachment options."],
									func = function(info) SetBarGroupAnchor(nil) end,
								},
							},
						},
						PositionGroup = {
							type = "group", order = 50, name = L["Display Position"], inline = true,
							disabled = function(info) return GetBarGroupField("anchor") or GetBarGroupField("anchorFrame") end,
							args = {
								Horizontal = {
									type = "range", order = 10, name = L["Horizontal"], min = 0, max = 100, step = 0.01,
									desc = L["Set horizontal position as percentage of overall width (cannot move beyond edge of display)."],
									get = function(info) return GetBarGroupField("pointX") * 100 end,
									set = function(info, value) SetBarGroupField("pointX", value / 100); SetBarGroupField("pointXR", nil) end,
								},
								Vertical = {
									type = "range", order = 20, name = L["Vertical"], min = 0, max = 100, step = 0.01,
									desc = L["Set vertical position as percentage of overall height (cannot move beyond edge of display)."],
									get = function(info) return GetBarGroupField("pointY") * 100 end,
									set = function(info, value) SetBarGroupField("pointY", value / 100); SetBarGroupField("pointYT", nil) end,
								},
							},
						},
					},
				},
				AppearanceTab = {
					type = "group", order = 45, name = L["Appearance"],
					disabled = function(info) return InMode("Bar") end,
					hidden = function(info) return NoBarGroup() or GetBarGroupField("merged") end,
					args = {
						FontsGroup = {
							type = "group", order = 20, name = L["Fonts and Textures"], inline = true,
							args = {
								UseDefaultsGroup = {
									type = "toggle", order = 1, name = L["Use Defaults"],
									desc = L["If checked, fonts and textures use the default values."],
									get = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
									set = function(info, value) SetBarGroupField("useDefaultFontsAndTextures", value) end,
								},
								RestoreDefaults = {
									type = "execute", order = 3, name = L["Restore Defaults"],
									desc = L["Reset fonts and textures for this bar group back to the current defaults."],
									disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
									func = function(info) MOD:CopyFontsAndTextures(MOD.db.global.Defaults, GetBarGroupEntry()); MOD:UpdateAllBarGroups() end,
								},
								CopyFromGroup = {
									type = "select", order = 4, name = L["Copy From"],
									desc = L["Select bar group to copy font and texture settings from."],
									disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
									get = function(info) return nil end,
									set = function(info, value) CopyBarGroupFontsAndTextures(GetBarGroupList()[value]) end,
									values = function(info) return GetBarGroupList() end,
									style = "dropdown",
								},
								LabelText = {
									type = "group", order = 21, name = L["Label Text"], inline = true,
									args = {
										LabelFont = {
											type = "select", order = 10, name = L["Font"], 
											desc = L["Select font."],
											dialogControl = 'LSM30_Font',
											values = AceGUIWidgetLSMlists.font,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("labelFont") end,
											set = function(info, value) SetBarGroupField("labelFont", value) end,
										},
										LabelFontSize = {
											type = "range", order = 15, name = L["Font Size"], min = 5, max = 50, step = 1,
											desc = L["Set font size."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("labelFSize") end,
											set = function(info, value) SetBarGroupField("labelFSize", value) end,
										},
										LabelAlpha = {
											type = "range", order = 20, name = L["Opacity"], min = 0, max = 1, step = 0.05,
											desc = L["Set text opacity."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("labelAlpha") end,
											set = function(info, value) SetBarGroupField("labelAlpha", value) end,
										},
										LabelColor = {
											type = "color", order = 25, name = L["Color"], hasAlpha = false, width = "half",
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info)
												local t = GetBarGroupField("labelColor")
												if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
											end,
											set = function(info, r, g, b, a)
												local t = GetBarGroupField("labelColor")
												if t then t.r = r; t.g = g; t.b = b; t.a = a else
													t = { r = r, g = g, b = b, a = a }; SetBarGroupField("labelColor", t) end
												MOD:UpdateAllBarGroups()
											end,
										},
										Space = { type = "description", name = "", order = 30 },
										LabelOutline = {
											type = "toggle", order = 35, name = L["Outline"], width = "half",
											desc = L["Add black outline."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("labelOutline") end,
											set = function(info, value) SetBarGroupField("labelOutline", value) end,
										},
										LabelThick = {
											type = "toggle", order = 40, name = L["Thick"], width = "half",
											desc = L["Add thick black outline."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("labelThick") end,
											set = function(info, value) SetBarGroupField("labelThick", value) end,
										},
										LabelMono = {
											type = "toggle", order = 45, name = L["Mono"], width = "half",
											desc = L["Render font without antialiasing."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("labelMono") end,
											set = function(info, value) SetBarGroupField("labelMono", value) end,
										},
										LabelShadow = {
											type = "toggle", order = 50, name = L["Shadow"], width = "half",
											desc = L["Show shadow with text."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("labelShadow") end,
											set = function(info, value) SetBarGroupField("labelShadow", value) end,
										},
									},
								},
								TimeText = {
									type = "group", order = 31, name = L["Time Text"], inline = true,
									args = {
										TimeFont = {
											type = "select", order = 10, name = L["Font"], 
											desc = L["Select font."],
											dialogControl = 'LSM30_Font',
											values = AceGUIWidgetLSMlists.font,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("timeFont") end,
											set = function(info, value) SetBarGroupField("timeFont", value) end,
										},
										TimeFontSize = {
											type = "range", order = 15, name = L["Font Size"], min = 5, max = 50, step = 1,
											desc = L["Set font size."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("timeFSize") end,
											set = function(info, value) SetBarGroupField("timeFSize", value) end,
										},
										TimeAlpha = {
											type = "range", order = 20, name = L["Opacity"], min = 0, max = 1, step = 0.05,
											desc = L["Set text opacity."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("timeAlpha") end,
											set = function(info, value) SetBarGroupField("timeAlpha", value) end,
										},
										TimeColor = {
											type = "color", order = 25, name = L["Color"], hasAlpha = false, width = "half",
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info)
												local t = GetBarGroupField("timeColor")
												if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
											end,
											set = function(info, r, g, b, a)
												local t = GetBarGroupField("timeColor")
												if t then t.r = r; t.g = g; t.b = b; t.a = a else
													t = { r = r, g = g, b = b, a = a }; SetBarGroupField("timeColor", t) end
												MOD:UpdateAllBarGroups()
											end,
										},
										Space = { type = "description", name = "", order = 30 },
										TimeOutline = {
											type = "toggle", order = 35, name = L["Outline"], width = "half",
											desc = L["Add black outline."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("timeOutline") end,
											set = function(info, value) SetBarGroupField("timeOutline", value) end,
										},
										TimeThick = {
											type = "toggle", order = 40, name = L["Thick"], width = "half",
											desc = L["Add thick black outline."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("timeThick") end,
											set = function(info, value) SetBarGroupField("timeThick", value) end,
										},
										TimeMono = {
											type = "toggle", order = 45, name = L["Mono"], width = "half",
											desc = L["Render font without antialiasing."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("timeMono") end,
											set = function(info, value) SetBarGroupField("timeMono", value) end,
										},
										TimeShadow = {
											type = "toggle", order = 50, name = L["Shadow"], width = "half",
											desc = L["Show shadow with text."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("timeShadow") end,
											set = function(info, value) SetBarGroupField("timeShadow", value) end,
										},
									},
								},
								IconText = {
									type = "group", order = 41, name = L["Icon Text"], inline = true,
									args = {
										IconFont = {
											type = "select", order = 10, name = L["Font"], 
											desc = L["Select font."],
											dialogControl = 'LSM30_Font',
											values = AceGUIWidgetLSMlists.font,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("iconFont") end,
											set = function(info, value) SetBarGroupField("iconFont", value) end,
										},
										IconFontSize = {
											type = "range", order = 15, name = L["Font Size"], min = 5, max = 50, step = 1,
											desc = L["Set font size."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("iconFSize") end,
											set = function(info, value) SetBarGroupField("iconFSize", value) end,
										},
										IconAlpha = {
											type = "range", order = 20, name = L["Opacity"], min = 0, max = 1, step = 0.05,
											desc = L["Set text opacity."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("iconAlpha") end,
											set = function(info, value) SetBarGroupField("iconAlpha", value) end,
										},
										IconColor = {
											type = "color", order = 25, name = L["Color"], hasAlpha = false, width = "half",
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info)
												local t = GetBarGroupField("iconColor")
												if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
											end,
											set = function(info, r, g, b, a)
												local t = GetBarGroupField("iconColor")
												if t then t.r = r; t.g = g; t.b = b; t.a = a else
													t = { r = r, g = g, b = b, a = a }; SetBarGroupField("iconColor", t) end
												MOD:UpdateAllBarGroups()
											end,
										},
										Space = { type = "description", name = "", order = 30 },
										IconOutline = {
											type = "toggle", order = 35, name = L["Outline"], width = "half",
											desc = L["Add black outline."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("iconOutline") end,
											set = function(info, value) SetBarGroupField("iconOutline", value) end,
										},
										IconThick = {
											type = "toggle", order = 40, name = L["Thick"], width = "half",
											desc = L["Add thick black outline."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("iconThick") end,
											set = function(info, value) SetBarGroupField("iconThick", value) end,
										},
										IconMono = {
											type = "toggle", order = 45, name = L["Mono"], width = "half",
											desc = L["Render font without antialiasing."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("iconMono") end,
											set = function(info, value) SetBarGroupField("iconMono", value) end,
										},
										IconShadow = {
											type = "toggle", order = 50, name = L["Shadow"], width = "half",
											desc = L["Show shadow with text."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("iconShadow") end,
											set = function(info, value) SetBarGroupField("iconShadow", value) end,
										},
									},
								},
								PanelsBorders = {
									type = "group", order = 51, name = L["Panels and Borders"], inline = true,
									args = {
										EnablePanel = {
											type = "toggle", order = 10, name = L["Background Panel"],
											desc = L["Enable display of a background panel behind bar group."],
											get = function(info) return GetBarGroupField("backdropEnable") end,
											set = function(info, value) SetBarGroupField("backdropEnable", value) end,
										},
										PanelTexture = {
											type = "select", order = 15, name = L["Panel Texture"], 
											desc = L["Select texture to display in panel behind bar group."],
											dialogControl = 'LSM30_Background',
											values = AceGUIWidgetLSMlists.background,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("backdropPanel") end,
											set = function(info, value) SetBarGroupField("backdropPanel", value) end,
										},
										PanelPadding = {
											type = "range", order = 20, name = L["Padding"], min = 0, max = 32, step = 0.1,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											desc = L["Adjust padding between bar group and the background panel and border."],
											get = function(info) return GetBarGroupField("backdropPadding") end,
											set = function(info, value) SetBarGroupField("backdropPadding", value) end,
										},
										PanelColor = {
											type = "color", order = 25, name = L["Panel Color"], hasAlpha = true,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											desc = L["Set fill color for the panel."],
											get = function(info)
												local t = GetBarGroupField("backdropFill")
												if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
											end,
											set = function(info, r, g, b, a)
												local t = GetBarGroupField("backdropFill")
												if t then t.r = r; t.g = g; t.b = b; t.a = a else
													t = { r = r, g = g, b = b, a = a }; SetBarGroupField("backdropFill", t) end
												MOD:UpdateAllBarGroups()
											end,
										},
										Space1 = { type = "description", name = "", order = 30 },
										BackdropOffsetX = {
											type = "range", order = 31, name = L["Offset X"], min = -50, max = 50, step = 1,
											desc = L["Adjust horizontal position of the panel."],
											get = function(info) return GetBarGroupField("backdropOffsetX") end,
											set = function(info, value) SetBarGroupField("backdropOffsetX", value) end,
										},
										BackdropOffsetY = {
											type = "range", order = 32, name = L["Offset Y"], min = -50, max = 50, step = 1,
											desc = L["Adjust vertical position of the panel."],
											get = function(info) return GetBarGroupField("backdropOffsetY") end,
											set = function(info, value) SetBarGroupField("backdropOffsetY", value) end,
										},
										BackdropPadW = {
											type = "range", order = 33, name = L["Extra Width"], min = 0, max = 50, step = 1,
											desc = L["Adjust width of the panel."],
											get = function(info) return GetBarGroupField("backdropPadW") end,
											set = function(info, value) SetBarGroupField("backdropPadW", value) end,
										},
										BackdropPadH = {
											type = "range", order = 34, name = L["Extra Height"], min = 0, max = 50, step = 1,
											desc = L["Adjust height of the panel."],
											get = function(info) return GetBarGroupField("backdropPadH") end,
											set = function(info, value) SetBarGroupField("backdropPadH", value) end,
										},
										Space2 = { type = "description", name = "", order = 40 },
										BackdropTexture = {
											type = "select", order = 41, name = L["Background Border"], 
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											desc = L["Select border to display behind bar group (select None to disable border)."],
											dialogControl = 'LSM30_Border',
											values = AceGUIWidgetLSMlists.border,
											get = function(info) return GetBarGroupField("backdropTexture") end,
											set = function(info, value) SetBarGroupField("backdropTexture", value) end,
										},
										BackdropWidth = {
											type = "range", order = 42, name = L["Edge Size"], min = 0, max = 32, step = 0.1,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											desc = L["Adjust size of the border's edge."],
											get = function(info) return GetBarGroupField("backdropWidth") end,
											set = function(info, value) SetBarGroupField("backdropWidth", value) end,
										},
										BackdropInset = {
											type = "range", order = 45, name = L["Inset"], min = -16, max = 16, step = 0.1,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											desc = L["Adjust inset from the border to background panel's fill color."],
											get = function(info) return GetBarGroupField("backdropInset") end,
											set = function(info, value) SetBarGroupField("backdropInset", value) end,
										},
										BackdropColor = {
											type = "color", order = 50, name = L["Border Color"], hasAlpha = true,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											desc = L["Set color for the border."],
											get = function(info)
												local t = GetBarGroupField("backdropColor")
												if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
											end,
											set = function(info, r, g, b, a)
												local t = GetBarGroupField("backdropColor")
												if t then t.r = r; t.g = g; t.b = b; t.a = a else
													t = { r = r, g = g, b = b, a = a }; SetBarGroupField("backdropColor", t) end
												MOD:UpdateAllBarGroups()
											end,
										},
										Space2 = { type = "description", name = "", order = 55 },
										BorderTexture = {
											type = "select", order = 60, name = L["Bar Border"], 
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											desc = L["Select border for bars in the bar group (select None to disable border)."],
											dialogControl = 'LSM30_Border',
											values = AceGUIWidgetLSMlists.border,
											get = function(info) return GetBarGroupField("borderTexture") end,
											set = function(info, value) SetBarGroupField("borderTexture", value) end,
										},
										BorderWidth = {
											type = "range", order = 65, name = L["Edge Size"], min = 0, max = 32, step = 0.1,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											desc = L["Adjust size of the border's edge."],
											get = function(info) return GetBarGroupField("borderWidth") end,
											set = function(info, value) SetBarGroupField("borderWidth", value) end,
										},
										BorderOffset = {
											type = "range", order = 70, name = L["Offset"], min = -16, max = 16, step = 0.1,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											desc = L["Adjust offset to the border from the bar."],
											get = function(info) return GetBarGroupField("borderOffset") end,
											set = function(info, value) SetBarGroupField("borderOffset", value) end,
										},
										BorderColor = {
											type = "color", order = 75, name = L["Border Color"], hasAlpha = true,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											desc = L["Set color for the border."],
											get = function(info)
												local t = GetBarGroupField("borderColor")
												if t then return t.r, t.g, t.b, t.a else return 0, 0, 0, 1 end
											end,
											set = function(info, r, g, b, a)
												local t = GetBarGroupField("borderColor")
												if t then t.r = r; t.g = g; t.b = b; t.a = a else
													t = { r = r, g = g, b = b, a = a }; SetBarGroupField("borderColor", t) end
												MOD:UpdateAllBarGroups()
											end,
										},
									},
								},
								Bars = {
									type = "group", order = 61, name = L["Bars and Icons"], inline = true,
									args = {
										ForegroundTexture = {
											type = "select", order = 10, name = L["Bar Foreground Texture"], 
											desc = L["Select foreground texture for bars."],
											dialogControl = 'LSM30_Statusbar',
											values = AceGUIWidgetLSMlists.statusbar,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("texture") end,
											set = function(info, value) SetBarGroupField("texture", value) end,
										},
										ForegroundAlpha = {
											type = "range", order = 15, name = L["Foreground Opacity"], min = 0, max = 1, step = 0.05,
											desc = L["Set foreground opacity for bars."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("fgAlpha") end,
											set = function(info, value) SetBarGroupField("fgAlpha", value) end,
										},
										ForegroundSaturation = {
											type = "range", order = 20, name = L["Foreground Saturation"], min = -1, max = 1, step = 0.05,
											desc = L["Set saturation for foreground colors."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("fgSaturation") end,
											set = function(info, value) SetBarGroupField("fgSaturation", value) end,
										},
										ForegroundBrightness = {
											type = "range", order = 25, name = L["Foreground Brightness"], min = -1, max = 1, step = 0.05,
											desc = L["Set brightness for foreground colors."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("fgBrightness") end,
											set = function(info, value) SetBarGroupField("fgBrightness", value) end,
										},
										Space1 = { type = "description", name = "", order = 30 },
										BackgroundTexture = {
											type = "select", order = 35, name = L["Bar Background Texture"], 
											desc = L["Select background texture for bars."],
											dialogControl = 'LSM30_Statusbar',
											values = AceGUIWidgetLSMlists.statusbar,
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("bgtexture") end,
											set = function(info, value) SetBarGroupField("bgtexture", value) end,
										},
										Background = {
											type = "range", order = 40, name = L["Background Opacity"], min = 0, max = 1, step = 0.05,
											desc = L["Set background opacity for bars."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("bgAlpha") end,
											set = function(info, value) SetBarGroupField("bgAlpha", value) end,
										},
										BackgroundSaturation = {
											type = "range", order = 45, name = L["Background Saturation"], min = -1, max = 1, step = 0.05,
											desc = L["Set saturation for foreground colors."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("bgSaturation") end,
											set = function(info, value) SetBarGroupField("bgSaturation", value) end,
										},
										BackgroundBrightness = {
											type = "range", order = 50, name = L["Background Brightness"], min = -1, max = 1, step = 0.05,
											desc = L["Set brightness for foreground colors."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("bgBrightness") end,
											set = function(info, value) SetBarGroupField("bgBrightness", value) end,
										},
										Space2 = { type = "description", name = "", order = 55 },
										NormalAlpha = {
											type = "range", order = 60, name = L["Opacity (Not Combat)"], min = 0, max = 1, step = 0.05,
											desc = L["Set opacity for bars/icons when not in combat."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("alpha") end,
											set = function(info, value) SetBarGroupField("alpha", value) end,
										},
										CombatAlpha = {
											type = "range", order = 65, name = L["Opacity (In Combat)"], min = 0, max = 1, step = 0.05,
											desc = L["Set opacity for bars/icons when in combat."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("combatAlpha") end,
											set = function(info, value) SetBarGroupField("combatAlpha", value) end,
										},
										IconBorderSaturation = {
											type = "range", order = 70, name = L["Icon Border Saturation"], min = -1, max = 1, step = 0.05,
											desc = L["Set saturation for icon border colors."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("borderSaturation") end,
											set = function(info, value) SetBarGroupField("borderSaturation", value) end,
										},
										IconBorderBrightness = {
											type = "range", order = 75, name = L["Icon Border Brightness"], min = -1, max = 1, step = 0.05,
											desc = L["Set brightness for icon border colors."],
											disabled = function(info) return GetBarGroupField("useDefaultFontsAndTextures") end,
											get = function(info) return GetBarGroupField("borderBrightness") end,
											set = function(info, value) SetBarGroupField("borderBrightness", value) end,
										},
									},
								},
							},
						},
						ColorsGroup = {
							type = "group", order = 30, name = L["Standard Colors"], inline = true,
							args = {
								UseDefaultsGroup = {
									type = "toggle", order = 1, name = L["Use Defaults"],
									desc = L["If checked, colors use the default values."],
									get = function(info) return GetBarGroupField("useDefaultColors") end,
									set = function(info, value) SetBarGroupField("useDefaultColors", value) end,
								},
								RestoreDefaults = {
									type = "execute", order = 3, name = L["Restore Defaults"],
									desc = L["Reset standard colors for this bar group back to the current defaults."],
									disabled = function(info) return GetBarGroupField("useDefaultColors") end,
									func = function(info) local bg = GetBarGroupEntry()
										bg.buffColor = nil; bg.debuffColor = nil; bg.cooldownColor = nil; bg.notificationColor = nil
										bg.poisonColor = nil; bg.curseColor = nil; bg.magicColor = nil; bg.diseaseColor = nil
										MOD:UpdateAllBarGroups()
									end,
								},
								CopyFromGroup = {
									type = "select", order = 4, name = L["Copy From"],
									desc = L["Select bar group to copy standard colors from."],
									disabled = function(info) return GetBarGroupField("useDefaultColors") end,
									get = function(info) return nil end,
									set = function(info, value) CopyBarGroupStandardColors(GetBarGroupList()[value]) end,
									values = function(info) return GetBarGroupList() end,
									style = "dropdown",
								},
								Space0 = { type = "description", name = "", order = 5 },
								ColorText = { type = "description", name = L["Bar Colors:"], order = 7, width = "half" },
								NotificationColor = {
									type = "color", order = 10, name = L["Notify"], hasAlpha = false, width = "half",
									disabled = function(info) return GetBarGroupField("useDefaultColors") end,
									get = function(info) local t = GetBarGroupField("notificationColor") or MOD.db.global.DefaultNotificationColor
										return t.r, t.g, t.b, t.a end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("notificationColor")
										if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("notificationColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								BuffColor = {
									type = "color", order = 11, name = L["Buff"], hasAlpha = false, width = "half",
									disabled = function(info) return GetBarGroupField("useDefaultColors") end,
									get = function(info) local t = GetBarGroupField("buffColor") or MOD.db.global.DefaultBuffColor
										return t.r, t.g, t.b, t.a end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("buffColor")
										if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("buffColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								DebuffColor = {
									type = "color", order = 12, name = L["Debuff"], hasAlpha = false, width = "half",
									disabled = function(info) return GetBarGroupField("useDefaultColors") end,
									get = function(info) local t = GetBarGroupField("debuffColor") or MOD.db.global.DefaultDebuffColor
										return t.r, t.g, t.b, t.a end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("debuffColor")
										if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("debuffColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								CooldownColor = {
									type = "color", order = 13, name = L["Cooldown"], hasAlpha = false,
									disabled = function(info) return GetBarGroupField("useDefaultColors") end,
									get = function(info) local t = GetBarGroupField("cooldownColor") or MOD.db.global.DefaultCooldownColor
										return t.r, t.g, t.b, t.a end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("cooldownColor")
										if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("cooldownColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								Space1 = { type = "description", name = "", order = 14 },
								DebuffText = { type = "description", name = L["Debuff Colors:"], order = 15, width = "half" },
								PoisonColor = {
									type = "color", order = 15, name = L["Poison"], hasAlpha = false, width = "half",
									disabled = function(info) return GetBarGroupField("useDefaultColors") end,
									get = function(info) local t = GetBarGroupField("poisonColor") or MOD.db.global.DefaultPoisonColor
										return t.r, t.g, t.b, t.a end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("poisonColor")
										if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("poisonColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								CurseColor = {
									type = "color", order = 16, name = L["Curse"], hasAlpha = false, width = "half",
									disabled = function(info) return GetBarGroupField("useDefaultColors") end,
									get = function(info) local t = GetBarGroupField("curseColor") or MOD.db.global.DefaultCurseColor
										return t.r, t.g, t.b, t.a end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("curseColor")
										if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("curseColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								MagicColor = {
									type = "color", order = 17, name = L["Magic"], hasAlpha = false, width = "half",
									disabled = function(info) return GetBarGroupField("useDefaultColors") end,
									get = function(info) local t = GetBarGroupField("magicColor") or MOD.db.global.DefaultMagicColor
										return t.r, t.g, t.b, t.a end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("magicColor")
										if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("magicColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								DiseaseColor = {
									type = "color", order = 18, name = L["Disease"], hasAlpha = false, width = "half",
									disabled = function(info) return GetBarGroupField("useDefaultColors") end,
									get = function(info) local t = GetBarGroupField("diseaseColor") or MOD.db.global.DefaultDiseaseColor
										return t.r, t.g, t.b, t.a end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("diseaseColor")
										if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("diseaseColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
							},
						},
						BarColorGroup = {
							type = "group", order = 40, name = L["Bar Color Scheme"], inline = true,
							args = {
								ForegroundText = { type = "description", name = L["Foreground:"], order = 1, width = "half" },
								StandardColors = {
									type = "toggle", order = 10, name = "Standard Colors",
									desc = L["Show bars in default colors for their type, including special debuff colors when applicable."],
									get = function(info) return GetBarGroupField("barColors") == "Standard" end,
									set = function(info, value) SetBarGroupField("barColors", "Standard") end,
								},
								CustomForeground = {
									type = "toggle", order = 15, name = L["Custom"], width = "half",
									desc = L["Color the bars with a custom color."],
									get = function(info) return GetBarGroupField("barColors") == "Custom" end,
									set = function(info, value) SetBarGroupField("barColors", "Custom") end,
								},
								ForegroundColor = {
									type = "color", order = 16, name = L["Color"], hasAlpha = false, width = "half",
									disabled = function(info) return GetBarGroupField("barColors") ~= "Custom" end,
									get = function(info)
										local t = GetBarGroupField("fgColor")
										if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
									end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("fgColor")
										if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("fgColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								ClassColors = {
									type = "toggle", order = 20, name = L["Class"], width = "half",
									desc = L["Show bars in class colors of associated spells when possible, otherwise use default bar colors."],
									get = function(info) return GetBarGroupField("barColors") == "Class" end,
									set = function(info, value) SetBarGroupField("barColors", "Class") end,
								},
								SpellColors = {
									type = "toggle", order = 30, name = L["Spell"], width = "half",
									desc = L["Show bars using spell colors when possible, otherwise use default bar colors."],
									get = function(info) return GetBarGroupField("barColors") == "Spell" end,
									set = function(info, value) SetBarGroupField("barColors", "Spell") end,
								},
								spacer1 = { type = "description", name = "", order = 40 },
								BackgroundText = { type = "description", name = L["Background:"], order = 41, width = "half" },
								NormalBackground = {
									type = "toggle", order = 50, name = L["Same as Foreground"],
									desc = L["Color the background the same as the foreground."],
									get = function(info) return GetBarGroupField("bgColors") == "Normal" end,
									set = function(info, value) SetBarGroupField("bgColors", "Normal") end,
								},
								CustomBackground = {
									type = "toggle", order = 60, name = L["Custom"], width = "half",
									desc = L["Color the background with a custom color."],
									get = function(info) return GetBarGroupField("bgColors") == "Custom" end,
									set = function(info, value) SetBarGroupField("bgColors", "Custom") end,
								},
								BackgroundColor = {
									type = "color", order = 70, name = L["Color"], hasAlpha = false, width = "half",
									disabled = function(info) return GetBarGroupField("bgColors") ~= "Custom" end,
									get = function(info)
										local t = GetBarGroupField("bgColor")
										if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
									end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("bgColor")
										if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("bgColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								spacer2 = { type = "description", name = "", order = 80 },
								IconBorderText = { type = "description", name = L["Icon Border:"], order = 81, width = "half" },
								NormalIcon = {
									type = "toggle", order = 85, name = L["Same as Foreground"],
									desc = L["Color the icon border the same as the bar foreground."],
									get = function(info) return GetBarGroupField("iconColors") == "Normal" end,
									set = function(info, value) SetBarGroupField("iconColors", "Normal") end,
								},
								CustomIcon = {
									type = "toggle", order = 86, name = L["Custom"], width = "half",
									desc = L["Color the icon border with a custom color."],
									get = function(info) return GetBarGroupField("iconColors") == "Custom" end,
									set = function(info, value) SetBarGroupField("iconColors", "Custom") end,
								},
								IconBorderColor = {
									type = "color", order = 87, name = L["Color"], hasAlpha = true, width = "half",
									disabled = function(info) return GetBarGroupField("iconColors") ~= "Custom" end,
									get = function(info)
										local t = GetBarGroupField("iconBorderColor")
										if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
									end,
									set = function(info, r, g, b, a)
										local t = GetBarGroupField("iconBorderColor")
										if t then t.r = r; t.g = g; t.b = b; t.a = a else
											t = { r = r, g = g, b = b, a = a }; SetBarGroupField("iconBorderColor", t) end
										MOD:UpdateAllBarGroups()
									end,
								},
								DebuffIcon = {
									type = "toggle", order = 90, name = L["Debuffs"], width = "half",
									desc = L["Color the icon border string"],
									get = function(info) return GetBarGroupField("iconColors") == "Debuffs" end,
									set = function(info, value) SetBarGroupField("iconColors", "Debuffs") end,
								},
								PlayerIcon = {
									type = "toggle", order = 91, name = L["Player"], width = "half",
									desc = L["Color icon border same as bar foreground for spells cast by players, color same as bar background for non-player spells."],
									get = function(info) return GetBarGroupField("iconColors") == "Player" end,
									set = function(info, value) SetBarGroupField("iconColors", "Player") end,
								},
								NoneIcon = {
									type = "toggle", order = 95, name = L["None"], width = "half",
									desc = L["Do not color the icon border."],
									get = function(info) return GetBarGroupField("iconColors") == "None" end,
									set = function(info, value) SetBarGroupField("iconColors", "None") end,
								},
								spacer3 = { type = "description", name = "", order = 100 },
								IconColorText = { type = "description", name = L["Icon Color:"], order = 101, width = "half" },
								Desaturate = {
									type = "toggle", order = 105, name = L["Desaturate Non-Player"],
									desc = L["Desaturate if action not cast by player."],
									get = function(info) return GetBarGroupField("desaturate") end,
									set = function(info, value) SetBarGroupField("desaturate", value) end,
								},
								DesaturateFriend = {
									type = "toggle", order = 105, name = L["Only Friendly Target"],
									desc = L["Desaturate only if the current target is a friend."],
									disabled = function(info) return not GetBarGroupField("desaturate") end,
									get = function(info) return GetBarGroupField("desaturateFriend") end,
									set = function(info, value) SetBarGroupField("desaturateFriend", value) end,
								},
							},
						},
					},
				},
				TimerOptionsTab = {
					type = "group", order = 50, name = L["Timer Options"],
					disabled = function(info) return InMode("Bar") end,
					hidden = function(info) return NoBarGroup() end,
					args = {
						DurationMaxGroup = {
							type = "group", order = 10, name = L["Show With Uniform Duration"], inline = true,
							args = {
								DurationCheck = {
									type = "toggle", order = 3, name = L["Enable"], width = "half",
									desc = L["Show timer bars scaled with a uniform duration (text still shows actual time left)."],
									get = function(info) return GetBarGroupField("setDuration") end,
									set = function(info, value) SetBarGroupField("setDuration", value) end,
								},
								DurationMinutes = {
									type = "range", order = 5, name = L["Minutes"], min = 0, max = 120, step = 1,
									desc = L["Enter minutes in the uniform duration."],
									disabled = function(info) return NoBarGroup() or not GetBarGroupField("setDuration") end,
									get = function(info) local d = GetBarGroupField("uniformDuration"); return math.floor(d / 60) end,
									set = function(info, value) local d = GetBarGroupField("uniformDuration"); SetBarGroupField("uniformDuration", (value * 60) + (d % 60)) end,
								},
								DurationSeconds = {
									type = "range", order = 7, name = L["Seconds"], min = 0, max = 59, step = 1,
									desc = L["Enter seconds in the uniform duration."],
									disabled = function(info) return NoBarGroup() or not GetBarGroupField("setDuration") end,
									get = function(info) local d = GetBarGroupField("uniformDuration"); return d % 60 end,
									set = function(info, value) local d = GetBarGroupField("uniformDuration"); SetBarGroupField("uniformDuration", value + (60 * math.floor(d / 60))) end,
								},
								DurationRange = {
									type = "description", order = 9,
									disabled = function(info) return not GetBarGroupField("setDuration") end, width = "half",
									name = function(info) local d = GetBarGroupField("uniformDuration"); return string.format("      %0d:%02d", math.floor(d / 60), d % 60) end,
								},
							},
						},
						DurationLimitGroup = {
							type = "group", order = 20, name = L["Show If Unlimited Duration"], inline = true,
							args = {
								LongDurationCheck = {
									type = "toggle", order = 1, name = L["Enable"], width = "half",
									desc = L["Show bars for actions with unlimited duration (e.g., paladin auras)."],
									get = function(info) return GetBarGroupField("showNoDuration") end,
									set = function(info, value) SetBarGroupField("showNoDuration", value) end,
								},
								LongDurationLimit = {
									type = "toggle", order = 10, name = L["Only Show Unlimited"],
									desc = L["Show bars for actions only if they have unlimited duration."],
									disabled = function(info) return not GetBarGroupField("showNoDuration") end,
									get = function(info) return GetBarGroupField("showOnlyNoDuration") end,
									set = function(info, value) SetBarGroupField("showOnlyNoDuration", value) end,
								},
								NoDurationFirst = {
									type = "toggle", order = 15, name = L["Unlimited As Zero"],
									desc = L["If checked, bars with unlimited duration sort as zero duration, otherwise as very long duration."],
									get = function(info) return GetBarGroupField("noDurationFirst") end,
									set = function(info, value) SetBarGroupField("noDurationFirst", value) end,
								},
								ForegroundBackground = {
									type = "toggle", order = 20, name = L["Full Bars"],
									desc = L["If checked, bars with unlimited duration show as full bars, otherwise they show as empty bars."],
									get = function(info) return not GetBarGroupField("showNoDurationBackground") end,
									set = function(info, value) SetBarGroupField("showNoDurationBackground", not value) end,
								},
							},
						},
						DurationGroup = {
							type = "group", order = 30, name = L["Check Overall Duration"], inline = true,
							args = {
								DurationCheck = {
									type = "toggle", order = 3, name = L["Enable"], width = "half",
									desc = L["Only include timer bars with a specified minimum (or maximum) duration."],
									get = function(info) return GetBarGroupField("checkDuration") end,
									set = function(info, value) SetBarGroupField("checkDuration", value) end,
								},
								DurationMinutes = {
									type = "range", order = 4, name = L["Minutes"], min = 0, max = 120, step = 1,
									desc = L["Enter minutes for overall duration check."],
									disabled = function(info) return NoBarGroup() or not GetBarGroupField("checkDuration") end,
									get = function(info) local d = GetBarGroupField("filterDuration"); return math.floor(d / 60) end,
									set = function(info, value) local d = GetBarGroupField("filterDuration"); SetBarGroupField("filterDuration", (value * 60) + (d % 60)) end,
								},
								DurationSeconds = {
									type = "range", order = 5, name = L["Seconds"], min = 0, max = 59, step = 1,
									desc = L["Enter seconds for overall duration check."],
									disabled = function(info) return NoBarGroup() or not GetBarGroupField("checkDuration") end,
									get = function(info) local d = GetBarGroupField("filterDuration"); return d % 60 end,
									set = function(info, value) local d = GetBarGroupField("filterDuration"); SetBarGroupField("filterDuration", value + (60 * math.floor(d / 60))) end,
								},
								DurationMinMax = {
									type = "select", order = 6, name = L["Duration"],
									disabled = function(info) return NoBarGroup() or not GetBarGroupField("checkDuration") end,
									get = function(info) if GetBarGroupField("minimumDuration") then return 1 else return 2 end end,
									set = function(info, value) if value == 1 then SetBarGroupField("minimumDuration", true) else SetBarGroupField("minimumDuration", false) end end,
									values = function(info)
										local d = GetBarGroupField("filterDuration")
										local ds = string.format("%0d:%02d", math.floor(d / 60), d % 60)
										return { "Show if " .. ds .. " or more", "Show if less than " .. ds }
									end,
									style = "dropdown",
								},
							},
						},
						TimeLeftGroup = {
							type = "group", order = 40, name = L["Check Time Left"], inline = true,
							disabled = function(info) return GetBarGroupField("showOnlyNoDuration") end,
							args = {
								TimeLeftCheck = {
									type = "toggle", order = 3, name = L["Enable"], width = "half",
									desc = L["Only show timer bars with a specified minimum (or maximum) time left."],
									get = function(info) return GetBarGroupField("checkTimeLeft") end,
									set = function(info, value) SetBarGroupField("checkTimeLeft", value) end,
								},
								TimeLeftMinutes= {
									type = "range", order = 4, name = L["Minutes"], min = 0, max = 120, step = 1,
									desc = L["Enter minutes for time left check."],
									disabled = function(info) return NoBarGroup() or not GetBarGroupField("checkTimeLeft") end,
									get = function(info) local d = GetBarGroupField("filterTimeLeft"); return math.floor(d / 60) end,
									set = function(info, value) local d = GetBarGroupField("filterTimeLeft"); SetBarGroupField("filterTimeLeft", (value * 60) + (d % 60)) end,
								},
								TimeLeftSeconds = {
									type = "range", order = 5, name = L["Seconds"], min = 0, max = 59, step = 1,
									desc = L["Enter seconds for time left check."],
									disabled = function(info) return NoBarGroup() or not GetBarGroupField("checkTimeLeft") end,
									get = function(info) local d = GetBarGroupField("filterTimeLeft"); return d % 60 end,
									set = function(info, value) local d = GetBarGroupField("filterTimeLeft"); SetBarGroupField("filterTimeLeft", value + (60 * math.floor(d / 60))) end,
								},
								TimeLeftMinMax = {
									type = "select", order = 6, name = L["Time Left"],
									disabled = function(info) return NoBarGroup() or not GetBarGroupField("checkTimeLeft") end,
									get = function(info) if GetBarGroupField("minimumTimeLeft") then return 1 else return 2 end end,
									set = function(info, value) if value == 1 then SetBarGroupField("minimumTimeLeft", true) else SetBarGroupField("minimumTimeLeft", false) end end,
									values = function(info)
										local d = GetBarGroupField("filterTimeLeft")
										local ds = string.format("%0d:%02d", math.floor(d / 60), d % 60)
										return { "Show if " .. ds .. " or more", "Show if less than " .. ds }
									end,
									style = "dropdown",
								},
							},
						},
						TimeFormatGroup = {
							type = "group", order = 50, name = L["Time Format"],  inline = true,
							args = {
								TimeFormat = {
									type = "select", order = 10, name = L["Options"], width = "double",
									desc = L["Time format string"],
									get = function(info) return GetBarGroupField("timeFormat") end,
									set = function(info, value) SetBarGroupField("timeFormat", value) end,
									values = function(info)
										local bg = GetBarGroupEntry()
										local s, c = bg.timeSpaces, bg.timeCase
										return GetTimeFormatList(s, c)
									end,
									style = "dropdown",
								},
								Space1 = { type = "description", name = "", order = 15, width = "half" },
								Spaces = {
									type = "toggle", order = 20, name = L["Spaces"], width = "half",
									desc = L["Include spaces between values in time format."],
									get = function(info) return GetBarGroupField("timeSpaces") end,
									set = function(info, value) SetBarGroupField("timeSpaces", value) end,
								},
								Capitals = {
									type = "toggle", order = 30, name = L["Uppercase"],
									desc = L["If checked, use uppercase H, M and S in time format, otherwise use lowercase."],
									get = function(info) return GetBarGroupField("timeCase") end,
									set = function(info, value) SetBarGroupField("timeCase", value) end,
								},
							},
						},
					},
				},
			},
		},
		Conditions = {
			type = "group", order = 30, name = L["Conditions"], childGroups = "tab",
			disabled = function(info) return InMode("BG") end,
			args = {
				SelectCondition = {
					type = "select", order = 1, name = L["Condition"],
					get = function(info) return GetSelectedCondition() end,
					set = function(info, value) SetSelectedCondition(value) end,
					disabled = function(info) return NoCondition() end,
					values = function(info) return GetConditionList() end,
					style = "dropdown",
				},
				Space1 = { type = "description", name = "", order = 2, width = "half" },
				NewConditionButton = {
					type = "execute", order = 3, name = L["New Condition"],
					desc = L["Create a new condition."],
					hidden = function(info) return conditions.enter end,
					func = function(info) conditions.enter, conditions.toggle = true, true end,
				},
				NewConditionName = {
					type = "input", order = 4, name = L["Enter Condition Name"],
					desc = L["Enter name of new condition."],
					hidden = function(info) return not conditions.enter end,
					validate = function(info, n) if not n or (n == "") then return "Invalid name." else return true end end,
					confirm = function(info, value) return ConfirmNewCondition(value) end,
					get = function(info)
						conditions.enter = conditions.toggle
						if conditions.toggle then conditions.toggle = false end
						if not conditions.enter then MOD:UpdateOptions() end
						return false
					end,
					set = function(info, value) conditions.enter = false; CreateCondition(value) end,
				},
				CancelNewCondition = {
					type = "execute", order = 5, name = L["Cancel"], width = "half",
					desc = L["Cancel creating a new condition."],
					hidden = function(info) return not conditions.enter end,
					func = function(info) conditions.enter, conditions.toggle = false, false end,
				},
				DeleteCondition = {
					type = "execute", order = 8, name = L["Delete Condition"],
					desc = L["Delete the selected condition."],
					hidden = function(info) return conditions.enter end,
					func = function(info) PurgeCondition(); DeleteCondition() end,
					confirm = function(info) return L["Delete condition string"](GetConditionField("name")) end,
				},
				GeneralTab = {
					type = "group", order = 20, name = L["General"],
					hidden = function(info) return NoCondition() end,
					args = {
						EnableGroup = {
							type = "group", order = 1, name = L["Enable"], inline = true,
							args = {
								EnableCondition = {
									type = "toggle", order = 1, name = L["Enable Condition"],
									desc = L["If checked, the condition is enabled and its value is determined by evaluating the associated tests, otherwise the condition is disabled and its value is always false."],
									get = function(info) return GetConditionField("enabled") end,
									set = function(info, value) SetConditionField("enabled", value) end,
								},
								EnableNotification = {
									type = "toggle", order = 10, name = L["Notification"],
									desc = L["If checked, this condition is suitable for a notification and will show up as an option for new notify bars."],
									get = function(info) return GetConditionField("notify") end,
									set = function(info, value) SetConditionField("notify", value) end,
								},
								EnableTooltips = {
									type = "toggle", order = 20, name = L["Detailed Tooltip"],
									desc = L["If checked, tooltip for notifications based on this condition will include a detailed description."],
									get = function(info) return GetConditionField("tooltip") end,
									set = function(info, value) SetConditionField("tooltip", value) end,
								},
							},
						},
						SharingGroup = {
							type = "group", order = 5, name = L["Share Condition"], inline = true,
							args = {
								EnableSharing = {
									type = "toggle", order = 5, name = L["Enable"],
									desc = L["If checked, this condition's settings can be copied between characters."],
									get = function(info) return GetConditionField("shared") end,
									set = function(info, value) SetConditionField("shared", value) end,
								},
								CopyConditionGroup = {
									type = "select", order = 10, name = L["Copy Condition Settings From"], width = "double",
									desc = L["Select a shared condition to copy settings from, including tests, associated spells, and dependencies."],
									get = function(info) return nil end,
									set = function(info, value) CopyConditionSettings(GetSharedConditionList()[value]) end,
									values = function(info) return GetSharedConditionList() end,
									style = "dropdown",
								},
								DeleteSharedConditions = {
									type = "execute", order = 20, name = L["Reset"], width = "half",
									desc = L["Reset and delete all current shared condition settings."],
									func = function(info) MOD.db.global.SharedConditions = {} end, -- clear the table recklessly
									confirm = function(info) return 'RESET\nAre you sure you want to delete all shared condition settings?' end,
								},
							},
						},
						RenameGroup = {
							type = "group", order = 20, name = L["Rename Condition"], inline = true,
							args = {
								Rename = {
									type = "input", order = 10, name = L["New Name"],
									validate = function(info, n) if not n or (n == "") then return L["Invalid name."] else return true end end,
									confirm = function(info, value) return ConfirmNewCondition(value) end,
									desc = L["Enter new name for the condition."],
									get = function(info) return GetConditionField("name") end,
									set = function(info, value) RenameCondition(value) end,
								},
							},
						},
						SpellGroup = {
							type = "group", order = 30, name = L["Associated Spell"], inline = true,
							args = {
								SpellName = {
									type = "input", order = 10, name = L["Spell Name"],
									desc = L["Enter spell name (or numeric identifier) whose color and icon can be used by notification bars based on this condition."],
									get = function(info) return GetConditionField("associatedSpell") end,
									set = function(info, n) n = ValidateSpellName(n); SetConditionField("associatedSpell", n) end,
								},
							},
						},
					},
				},
				TestsTab = {
					type = "group", order = 40, name = L["Tests"],
					hidden = function(info) return NoCondition() end,
					args = {
						SummaryGroup = {
							type = "group", order = 10, name = L["Summary"], inline = true,
							args = {
								ConditionDescription = {
									type = "description", order = 1, name = function(info) return GetConditionDescription() end,
								},
							},
						},
						PlayerStatusGroup = {
							type = "group", order = 20, name = L["Player Status"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Player Status", "enable") end,
											set = function(info, value) SetTestField("Player Status", "enable", value) end,
										},
									},
								},
								CombatGroup = {
									type = "group", order = 10, name = L["Combat"], inline = true,
									args = {
										CheckCombat = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test combat status."],
											get = function(info) return IsTestFieldOn("Player Status", "inCombat") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "inCombat", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["In Combat"],
											desc = L["If checked, must be in combat."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inCombat") end,
											get = function(info) return GetTestField("Player Status", "inCombat") == true end,
											set = function(info, value) SetTestField("Player Status", "inCombat", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Out Of Combat"],
											desc = L["If checked, must be out of combat."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inCombat") end,
											get = function(info) return GetTestField("Player Status", "inCombat") == false end,
											set = function(info, value) SetTestField("Player Status", "inCombat", false) end,
										},
									},
								},
								RestingGroup = {
									type = "group", order = 20, name = L["Resting"], inline = true,
									args = {
										CheckResting = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the player is resting."],
											get = function(info) return IsTestFieldOn("Player Status", "isResting") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "isResting", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is Resting"],
											desc = L["If checked, player must be resting (e.g., in an inn)."],
											disabled = function(info) return IsTestFieldOff("Player Status", "isResting") end,
											get = function(info) return GetTestField("Player Status", "isResting") == true end,
											set = function(info, value) SetTestField("Player Status", "isResting", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Resting"],
											desc = L["If checked, player must not be resting."],
											disabled = function(info) return IsTestFieldOff("Player Status", "isResting") end,
											get = function(info) return GetTestField("Player Status", "isResting") == false end,
											set = function(info, value) SetTestField("Player Status", "isResting", false) end,
										},
									},
								},
								MountedGroup = {
									type = "group", order = 25, name = L["Mounted"], inline = true,
									args = {
										CheckMounted = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the player is mounted."],
											get = function(info) return IsTestFieldOn("Player Status", "isMounted") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "isMounted", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is Mounted"],
											desc = L["If checked, player must be mounted."],
											disabled = function(info) return IsTestFieldOff("Player Status", "isMounted") end,
											get = function(info) return GetTestField("Player Status", "isMounted") == true end,
											set = function(info, value) SetTestField("Player Status", "isMounted", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Mounted"],
											desc = L["If checked, player must not be mounted."],
											disabled = function(info) return IsTestFieldOff("Player Status", "isMounted") end,
											get = function(info) return GetTestField("Player Status", "isMounted") == false end,
											set = function(info, value) SetTestField("Player Status", "isMounted", false) end,
										},
									},
								},
								StealthedGroup = {
									type = "group", order = 30, name = L["Stealthed"], inline = true,
									args = {
										CheckStealthed = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the player is stealthed."],
											get = function(info) return IsTestFieldOn("Player Status", "isStealthed") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "isStealthed", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is Stealthed"],
											desc = L["If checked, player must be stealthed."],
											disabled = function(info) return IsTestFieldOff("Player Status", "isStealthed") end,
											get = function(info) return GetTestField("Player Status", "isStealthed") == true end,
											set = function(info, value) SetTestField("Player Status", "isStealthed", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Stealthed"],
											desc = L["If checked, player must not be stealthed."],
											disabled = function(info) return IsTestFieldOff("Player Status", "isStealthed") end,
											get = function(info) return GetTestField("Player Status", "isStealthed") == false end,
											set = function(info, value) SetTestField("Player Status", "isStealthed", false) end,
										},
									},
								},
								PvPGroup = {
									type = "group", order = 33, name = L["PvP"], inline = true,
									args = {
										CheckFishing = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the player has PvP enabled."],
											get = function(info) return IsTestFieldOn("Player Status", "isPvP") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "isPvP", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is PvP"],
											desc = L["If checked, player must have PvP enabled."],
											disabled = function(info) return IsTestFieldOff("Player Status", "isPvP") end,
											get = function(info) return GetTestField("Player Status", "isPvP") == true end,
											set = function(info, value) SetTestField("Player Status", "isPvP", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not PvP"],
											desc = L["If checked, player must not have PvP enabled."],
											disabled = function(info) return IsTestFieldOff("Player Status", "isPvP") end,
											get = function(info) return GetTestField("Player Status", "isPvP") == false end,
											set = function(info, value) SetTestField("Player Status", "isPvP", false) end,
										},
									},
								},
								InParty = {
									type = "group", order = 35, name = L["In Party"], inline = true,
									args = {
										CheckGroup = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if player is in a party."],
											get = function(info) return IsTestFieldOn("Player Status", "inParty") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "inParty", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["In Party"],
											desc = L["If checked, player must be in a party."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inParty") end,
											get = function(info) return GetTestField("Player Status", "inParty") == true end,
											set = function(info, value) SetTestField("Player Status", "inParty", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not In Party"],
											desc = L["If checked, player must not be in a party."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inParty") end,
											get = function(info) return GetTestField("Player Status", "inParty") == false end,
											set = function(info, value) SetTestField("Player Status", "inParty", false) end,
										},
									},
								},
								InRaid = {
									type = "group", order = 36, name = L["In Raid"], inline = true,
									args = {
										CheckGroup = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if player is in raid group."],
											get = function(info) return IsTestFieldOn("Player Status", "inRaid") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "inRaid", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["In Raid"],
											desc = L["If checked, player must be in a raid group."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inRaid") end,
											get = function(info) return GetTestField("Player Status", "inRaid") == true end,
											set = function(info, value) SetTestField("Player Status", "inRaid", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not In Raid"],
											desc = L["If checked, player must not be in a raid group."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inRaid") end,
											get = function(info) return GetTestField("Player Status", "inRaid") == false end,
											set = function(info, value) SetTestField("Player Status", "inRaid", false) end,
										},
									},
								},
								InGroup = {
									type = "group", order = 37, name = L["In Group"], inline = true,
									args = {
										CheckGroup = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if player is in either a party or raid with other players."],
											get = function(info) return IsTestFieldOn("Player Status", "inGroup") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "inGroup", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["In Group"],
											desc = L["If checked, player must be in either a party or raid with other players."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inGroup") end,
											get = function(info) return GetTestField("Player Status", "inGroup") == true end,
											set = function(info, value) SetTestField("Player Status", "inGroup", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not In Group"],
											desc = L["If checked, player must not be in either a party or raid with other players."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inGroup") end,
											get = function(info) return GetTestField("Player Status", "inGroup") == false end,
											set = function(info, value) SetTestField("Player Status", "inGroup", false) end,
										},
									},
								},
								InInstance = {
									type = "group", order = 40, name = L["In Instance"], inline = true,
									args = {
										CheckGroup = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if player is in a 5-man or raid instance."],
											get = function(info) return IsTestFieldOn("Player Status", "inInstance") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "inInstance", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["In Instance"],
											desc = L["If checked, player must be in a 5-man or raid instance."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inInstance") end,
											get = function(info) return GetTestField("Player Status", "inInstance") == true end,
											set = function(info, value) SetTestField("Player Status", "inInstance", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not In Instance"],
											desc = L["If checked, player must not be in a 5-man or raid instance."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inInstance") end,
											get = function(info) return GetTestField("Player Status", "inInstance") == false end,
											set = function(info, value) SetTestField("Player Status", "inInstance", false) end,
										},
									},
								},
								InArena = {
									type = "group", order = 41, name = L["In Arena"], inline = true,
									args = {
										CheckGroup = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if player is in an arena."],
											get = function(info) return IsTestFieldOn("Player Status", "inArena") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "inArena", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["In Arena"],
											desc = L["If checked, player must be in an arena."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inArena") end,
											get = function(info) return GetTestField("Player Status", "inArena") == true end,
											set = function(info, value) SetTestField("Player Status", "inArena", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not In Arena"],
											desc = L["If checked, player must not be in an arena."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inArena") end,
											get = function(info) return GetTestField("Player Status", "inArena") == false end,
											set = function(info, value) SetTestField("Player Status", "inArena", false) end,
										},
									},
								},
								InBattleground = {
									type = "group", order = 42, name = L["In Battleground"], inline = true,
									args = {
										CheckGroup = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if player is in a battleground."],
											get = function(info) return IsTestFieldOn("Player Status", "inBattleground") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "inBattleground", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["In Battleground"],
											desc = L["If checked, player must be in a battleground."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inBattleground") end,
											get = function(info) return GetTestField("Player Status", "inBattleground") == true end,
											set = function(info, value) SetTestField("Player Status", "inBattleground", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not In Battleground"],
											desc = L["If checked, player must not be in a battleground."],
											disabled = function(info) return IsTestFieldOff("Player Status", "inBattleground") end,
											get = function(info) return GetTestField("Player Status", "inBattleground") == false end,
											set = function(info, value) SetTestField("Player Status", "inBattleground", false) end,
										},
									},
								},
								PetGroup = {
									type = "group", order = 44, name = L["Pet"], inline = true,
									args = {
										CheckStealthed = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the player has a pet."],
											get = function(info) return IsTestFieldOn("Player Status", "hasPet") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "hasPet", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Has Pet"],
											desc = L["If checked, player must have a pet."],
											disabled = function(info) return IsTestFieldOff("Player Status", "hasPet") end,
											get = function(info) return GetTestField("Player Status", "hasPet") == true end,
											set = function(info, value) SetTestField("Player Status", "hasPet", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["No Pet"],
											desc = L["If checked, player must not have a pet"],
											disabled = function(info) return IsTestFieldOff("Player Status", "hasPet") end,
											get = function(info) return GetTestField("Player Status", "hasPet") == false end,
											set = function(info, value) SetTestField("Player Status", "hasPet", false) end,
										},
									},
								},
								CheckLevelGroup = {
									type = "group", order = 45, name = L["Level"], inline = true,
									args = {
										CheckLevelEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's level."],
											get = function(info) return IsTestFieldOn("Player Status", "checkLevel") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkLevel", v) end,
										},
										CheckLevel = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, player must be at least at this level, otherwise must be lower."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkLevel") end,
											get = function(info) return GetTestField("Player Status", "checkLevel") == true end,
											set = function(info, value) SetTestField("Player Status", "checkLevel", value) end,
										},
										LevelRange = {
											type = "range", order = 3, name = "", min = 1, max = 100, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkLevel") end,
											get = function(info) return GetTestField("Player Status", "level") end,
											set = function(info, value) SetTestField("Player Status", "level", value) end,
										},
									},
								},
								CheckHealthGroup = {
									type = "group", order = 50, name = L["Health"], inline = true, 
									args = {
										CheckHealthEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's health."],
											get = function(info) return IsTestFieldOn("Player Status", "checkHealth") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkHealth", v) end,
										},
										CheckHealth = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, player's health must be at least this percentage, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkHealth") end,
											get = function(info) return GetTestField("Player Status", "checkHealth") == true end,
											set = function(info, value) SetTestField("Player Status", "checkHealth", value) end,
										},
										HealthRange = {
											type = "range", order = 3, name = "", min = 1, max = 100, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkHealth") end,
											get = function(info) return GetTestField("Player Status", "minHealth") end,
											set = function(info, value) SetTestField("Player Status", "minHealth", value) end,
										},
									},
								},
								CheckPowerGroup = {
									type = "group", order = 70, name = L["Power"], inline = true, 
									args = {
										CheckPowerEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's power (i.e., mana, rage, energy, focus, runic power)."],
											get = function(info) return IsTestFieldOn("Player Status", "checkPower") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkPower", v) end,
										},
										CheckPower = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, player's power must be at least this percentage, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkPower") end,
											get = function(info) return GetTestField("Player Status", "checkPower") == true end,
											set = function(info, value) SetTestField("Player Status", "checkPower", value) end,
										},
										PowerRange = {
											type = "range", order = 3, name = "", min = 1, max = 100, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkPower") end,
											get = function(info) return GetTestField("Player Status", "minPower") end,
											set = function(info, value) SetTestField("Player Status", "minPower", value) end,
										},
									},
								},
								CheckHolyPowerGroup = {
									type = "group", order = 71, name = L["Holy Power"], inline = true, 
									args = {
										CheckPowerEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's holy power."],
											get = function(info) return IsTestFieldOn("Player Status", "checkHolyPower") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkHolyPower", v) end,
										},
										CheckPower = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, player's holy power must be at least this many charges, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkHolyPower") end,
											get = function(info) return GetTestField("Player Status", "checkHolyPower") == true end,
											set = function(info, value) SetTestField("Player Status", "checkHolyPower", value) end,
										},
										PowerRange = {
											type = "range", order = 3, name = "", min = 1, max = 5, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkHolyPower") end,
											get = function(info) return GetTestField("Player Status", "minHolyPower") end,
											set = function(info, value) SetTestField("Player Status", "minHolyPower", value) end,
										},
									},
								},
								CheckShadowOrbsGroup = {
									type = "group", order = 72, name = L["Shadow Orbs"], inline = true, 
									args = {
										CheckPowerEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's shadow orbs."],
											get = function(info) return IsTestFieldOn("Player Status", "checkShadowOrbs") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkShadowOrbs", v) end,
										},
										CheckPower = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, player must have at least this many shadow orbs, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkShadowOrbs") end,
											get = function(info) return GetTestField("Player Status", "checkShadowOrbs") == true end,
											set = function(info, value) SetTestField("Player Status", "checkShadowOrbs", value) end,
										},
										PowerRange = {
											type = "range", order = 3, name = "", min = 1, max = 3, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkShadowOrbs") end,
											get = function(info) return GetTestField("Player Status", "minShadowOrbs") end,
											set = function(info, value) SetTestField("Player Status", "minShadowOrbs", value) end,
										},
									},
								},
								CheckShardsGroup = {
									type = "group", order = 73, name = L["Soul Shards"], inline = true, 
									args = {
										CheckShardsEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's number of soul shards."],
											get = function(info) return IsTestFieldOn("Player Status", "checkShards") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkShards", v) end,
										},
										CheckShards = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, player must have at least this many soul shards, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkShards") end,
											get = function(info) return GetTestField("Player Status", "checkShards") == true end,
											set = function(info, value) SetTestField("Player Status", "checkShards", value) end,
										},
										ShardsRange = {
											type = "range", order = 3, name = "", min = 1, max = 4, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkShards") end,
											get = function(info) return GetTestField("Player Status", "minShards") end,
											set = function(info, value) SetTestField("Player Status", "minShards", value) end,
										},
									},
								},
								CheckBurningEmbersGroup = {
									type = "group", order = 74, name = L["Burning Embers"], inline = true, 
									args = {
										CheckPowerEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's burning embers segment count (there are 10 segments per ember)."],
											get = function(info) return IsTestFieldOn("Player Status", "checkEmbers") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkEmbers", v) end,
										},
										CheckPower = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, player must have at least this many burning embers, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkEmbers") end,
											get = function(info) return GetTestField("Player Status", "checkEmbers") == true end,
											set = function(info, value) SetTestField("Player Status", "checkEmbers", value) end,
										},
										PowerRange = {
											type = "range", order = 3, name = "", min = 1, max = 30, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkEmbers") end,
											get = function(info) return GetTestField("Player Status", "minEmbers") end,
											set = function(info, value) SetTestField("Player Status", "minEmbers", value) end,
										},
									},
								},
								CheckDemonicFuryGroup = {
									type = "group", order = 76, name = L["Demonic Fury"], inline = true, 
									args = {
										CheckPowerEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's demonic fury."],
											get = function(info) return IsTestFieldOn("Player Status", "checkFury") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkFury", v) end,
										},
										CheckPower = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, player must have at least this much demonic fury, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkFury") end,
											get = function(info) return GetTestField("Player Status", "checkFury") == true end,
											set = function(info, value) SetTestField("Player Status", "checkFury", value) end,
										},
										PowerRange = {
											type = "range", order = 3, name = "", min = 1, max = 1000, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkFury") end,
											get = function(info) return GetTestField("Player Status", "minFury") end,
											set = function(info, value) SetTestField("Player Status", "minFury", value) end,
										},
									},
								},
								CheckEclipsePower = {
									type = "group", order = 77, name = L["Eclipse Power"], inline = true, 
									args = {
										CheckEclipseEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's eclipse power. You can set power level (-100 to -1 for lunar power, 1 to 100 for solar power) and the comparison to use (either less or greater than the power level)."],
											get = function(info) return IsTestFieldOn("Player Status", "checkEclipsePower") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkEclipsePower", v) end,
										},
										CheckEclipse = {
											type = "toggle", order = 10, name = L["Minimum"],
											desc = L["If checked, player's eclipse power must be at least this level, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkEclipsePower") end,
											get = function(info) return GetTestField("Player Status", "checkEclipsePower") == true end,
											set = function(info, value) SetTestField("Player Status", "checkEclipsePower", value) end,
										},
										EclipseRange = {
											type = "range", order = 20, name = "", min = -100, max = 100, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkEclipsePower") end,
											get = function(info) return GetTestField("Player Status", "minEclipsePower") end,
											set = function(info, value) SetTestField("Player Status", "minEclipsePower", value) end,
										},
									},
								},
								CheckEclipseGroup = {
									type = "group", order = 78, name = L["Eclipse State"], inline = true, 
									args = {
										CheckEclipseEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's eclipse status. You can test current eclipse direction (toward sun or moon) and whether lunar or solar eclipse is active."],
											get = function(info) return IsTestFieldOn("Player Status", "checkEclipse") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkEclipse", v) end,
										},
										SolarEclipse = {
											type = "toggle", order = 40, name = L["Solar"], width = "half",
											desc = L["If checked, player must be in Solar Eclipse."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkEclipse") end,
											get = function(info) return GetTestField("Player Status", "checkSolar") end,
											set = function(info, value) SetTestField("Player Status", "checkSolar", value) end,
										},
										LunarEclipse = {
											type = "toggle", order = 50, name = L["Lunar"], width = "half",
											desc = L["If checked, player must be in Lunar Eclipse."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkEclipse") end,
											get = function(info) return GetTestField("Player Status", "checkLunar") end,
											set = function(info, value) SetTestField("Player Status", "checkLunar", value) end,
										},
										EclipseSun = {
											type = "toggle", order = 60, name = L[">> Sun"], width = "half",
											desc = L["If checked, eclipse direction must be going toward the sun."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkEclipse") end,
											get = function(info) return GetTestField("Player Status", "checkSun") end,
											set = function(info, value) SetTestField("Player Status", "checkSun", value) end,
										},
										EclipseMoon = {
											type = "toggle", order = 70, name = L[">> Moon"], width = "half",
											desc = L["If checked, eclipse direction must be going toward the moon."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkEclipse") end,
											get = function(info) return GetTestField("Player Status", "checkMoon") end,
											set = function(info, value) SetTestField("Player Status", "checkMoon", value) end,
										},
									},
								},
								CheckRunesGroup = {
									type = "group", order = 79, name = L["Runes"], inline = true,
									args = {
										CheckRunes = {
											type = "toggle", order = 10, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's rune status."],
											get = function(info) return IsTestFieldOn("Player Status", "checkRunes") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkRunes", v) end,
										},
										CheckAvailableGroup = {
											type = "group", order = 30, name = L["Available"], inline = true,
											args = {
												DoBlood = {
													type = "toggle", order = 20, name = L["Blood"], width = "half",
													desc = L["If checked, must have at least one blood rune available (or enough death runes)."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkRunes") end,
													get = function(info) return GetTestField("Player Status", "needBlood") == true end,
													set = function(info, value) SetTestField("Player Status", "needBlood", value) end,
												},
												DoFrost = {
													type = "toggle", order = 30, name = L["Frost"], width = "half",
													desc = L["If checked, must have at least one frost rune available (or enough death runes)."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkRunes") end,
													get = function(info) return GetTestField("Player Status", "needFrost") == true end,
													set = function(info, value) SetTestField("Player Status", "needFrost", value) end,
												},
												DoUnholy = {
													type = "toggle", order = 40, name = L["Unholy"], width = "half",
													desc = L["If checked, must have at least one unholy rune available (or enough death runes)."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkRunes") end,
													get = function(info) return GetTestField("Player Status", "needUnholy") == true end,
													set = function(info, value) SetTestField("Player Status", "needUnholy", value) end,
												},
												DoAny = {
													type = "toggle", order = 50, name = L["Any"], width = "half",
													desc = L["If checked, at least one rune of any type must be available."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkRunes") end,
													get = function(info) return GetTestField("Player Status", "checkAnyRune") == true end,
													set = function(info, value) SetTestField("Player Status", "checkAnyRune", value) end,
												},
												NoDeath = {
													type = "toggle", order = 60, name = L["Ignore Death"],
													desc = L["If checked, ignore death runes when checking rune availability."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkRunes") or
														not ((GetTestField("Player Status", "checkAnyRune") == true) or
														(GetTestField("Player Status", "needUnholy") == true) or
														(GetTestField("Player Status", "needFrost") == true) or
														(GetTestField("Player Status", "needBlood") == true))
													end,
													get = function(info) return GetTestField("Player Status", "checkDeath") == true end,
													set = function(info, value) SetTestField("Player Status", "checkDeath", value) end,
												},
											},
										},
										CheckRechargeGroup = {
											type = "group", order = 40, name = L["Recharging"], inline = true,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkRunes") end,
											args = {
												CheckBlood = {
													type = "toggle", order = 10, name = L["Blood"], width = "half",
													desc = L["If checked, test blood runes."],
													get = function(info) return GetTestField("Player Status", "checkBlood") end,
													set = function(info, v) SetTestField("Player Status", "checkBlood", v) end,
												},
												BloodRecharge = {
													type = "toggle", order = 15, name = L[">= 1"], width = "half",
													desc = L["If checked, at least one blood rune must be recharging, otherwise none."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkRunes") or not GetTestField("Player Status", "checkBlood") end,
													get = function(info) return GetTestField("Player Status", "chargeBlood") == true end,
													set = function(info, value) SetTestField("Player Status", "chargeBlood", value) end,
												},
												CheckFrost = {
													type = "toggle", order = 20, name = L["Frost"], width = "half",
													desc = L["If checked, test frost runes."],
													get = function(info) return GetTestField("Player Status", "checkFrost") end,
													set = function(info, v) SetTestField("Player Status", "checkFrost", v) end,
												},
												FrostRecharge = {
													type = "toggle", order = 25, name = L[">= 1"], width = "half",
													desc = L["If checked, at least one frost rune must be recharging, otherwise none."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkRunes") or not GetTestField("Player Status", "checkFrost") end,
													get = function(info) return GetTestField("Player Status", "chargeFrost") == true end,
													set = function(info, value) SetTestField("Player Status", "chargeFrost", value) end,
												},
												CheckUnholy = {
													type = "toggle", order = 30, name = L["Unholy"], width = "half",
													desc = L["If checked, test unholy runes."],
													get = function(info) return GetTestField("Player Status", "checkUnholy") end,
													set = function(info, v) SetTestField("Player Status", "checkUnholy", v) end,
												},
												UnholyRecharge = {
													type = "toggle", order = 35, name = L[">= 1"], width = "half",
													desc = L["If checked, at least one unholy rune must be recharging, otherwise none."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkRunes") or not GetTestField("Player Status", "checkUnholy") end,
													get = function(info) return GetTestField("Player Status", "chargeUnholy") == true end,
													set = function(info, value) SetTestField("Player Status", "chargeUnholy", value) end,
												},
											},
										},
									},
								},
								CheckTotemsGroup = {
									type = "group", order = 80, name = L["Totems"], inline = true,
									args = {
										CheckTotems = {
											type = "toggle", order = 10, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's totem status."],
											get = function(info) return IsTestFieldOn("Player Status", "checkTotems") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkTotems", v) end,
										},
										CheckAirGroup = {
											type = "group", order = 20, name = L["Air Totem"], inline = true,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkTotems") end,
											args = {
												Active = {
													type = "toggle", order = 10, name = L["True"], width = "half",
													desc = L["If checked, must have an active totem of this type (or specific totem if Totem Name is defined)."],
													get = function(info) return IsTestFieldOn("Player Status", "air") and GetTestField("Player Status", "air") end,
													set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "air", v) end,
												},
												NotActive = {
													type = "toggle", order = 15, name = L["False"], width = "half",
													desc = L["If checked, must not have an active totem of this type (or specific totem if Totem Name is defined)."],
													get = function(info) return IsTestFieldOn("Player Status", "air") and not GetTestField("Player Status", "air") end,
													set = function(info, value) local v = Off if value then v = false end SetTestField("Player Status", "air", v) end,
												},
												TotemName = {
													type = "input", order = 20, name = L["Totem Name"], width = "double",
													desc = L["Enter name of specific totem to check is active."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkTotems") or IsTestFieldOff("Player Status", "air") end,
													get = function(info) return GetTestField("Player Status", "airTotem") end,
													set = function(info, value) SetTestFieldString("Player Status", "airTotem", value) end,
												},
											},
										},
										CheckEarthGroup = {
											type = "group", order = 30, name = L["Earth Totem"], inline = true,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkTotems") end,
											args = {
												Active = {
													type = "toggle", order = 10, name = L["True"], width = "half",
													desc = L["If checked, must have an active totem of this type (or specific totem if Totem Name is defined)."],
													get = function(info) return IsTestFieldOn("Player Status", "earth") and GetTestField("Player Status", "earth") end,
													set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "earth", v) end,
												},
												NotActive = {
													type = "toggle", order = 15, name = L["False"], width = "half",
													desc = L["If checked, must not have an active totem of this type (or specific totem if Totem Name is defined)."],
													get = function(info) return IsTestFieldOn("Player Status", "earth") and not GetTestField("Player Status", "earth") end,
													set = function(info, value) local v = Off if value then v = false end SetTestField("Player Status", "earth", v) end,
												},
												TotemName = {
													type = "input", order = 20, name = L["Totem Name"], width = "double",
													desc = L["Enter name of specific totem to check is active."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkTotems") or IsTestFieldOff("Player Status", "earth") end,
													get = function(info) return GetTestField("Player Status", "earthTotem") end,
													set = function(info, value) SetTestFieldString("Player Status", "earthTotem", value) end,
												},
											},
										},
										CheckFireGroup = {
											type = "group", order = 40, name = L["Fire Totem"], inline = true,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkTotems") end,
											args = {
												Active = {
													type = "toggle", order = 10, name = L["True"], width = "half",
													desc = L["If checked, must have an active totem of this type (or specific totem if Totem Name is defined)."],
													get = function(info) return IsTestFieldOn("Player Status", "fire") and GetTestField("Player Status", "fire") end,
													set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "fire", v) end,
												},
												NotActive = {
													type = "toggle", order = 15, name = L["False"], width = "half",
													desc = L["If checked, must not have an active totem of this type (or specific totem if Totem Name is defined)."],
													get = function(info) return IsTestFieldOn("Player Status", "fire") and not GetTestField("Player Status", "fire") end,
													set = function(info, value) local v = Off if value then v = false end SetTestField("Player Status", "fire", v) end,
												},
												TotemName = {
													type = "input", order = 20, name = L["Totem Name"], width = "double",
													desc = L["Enter name of specific totem to check is active."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkTotems") or IsTestFieldOff("Player Status", "fire") end,
													get = function(info) return GetTestField("Player Status", "fireTotem") end,
													set = function(info, value) SetTestFieldString("Player Status", "fireTotem", value) end,
												},
											},
										},
										CheckWaterGroup = {
											type = "group", order = 50, name = L["Water Totem"], inline = true,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkTotems") end,
											args = {
												Active = {
													type = "toggle", order = 10, name = L["True"], width = "half",
													desc = L["If checked, must have an active totem of this type (or specific totem if Totem Name is defined)."],
													get = function(info) return IsTestFieldOn("Player Status", "water") and GetTestField("Player Status", "water") end,
													set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "water", v) end,
												},
												NotActive = {
													type = "toggle", order = 15, name = L["False"], width = "half",
													desc = L["If checked, must not have an active totem of this type (or specific totem if Totem Name is defined)."],
													get = function(info) return IsTestFieldOn("Player Status", "water") and not GetTestField("Player Status", "water") end,
													set = function(info, value) local v = Off if value then v = false end SetTestField("Player Status", "water", v) end,
												},
												TotemName = {
													type = "input", order = 20, name = L["Totem Name"], width = "double",
													desc = L["Enter name of specific totem to check is active."],
													disabled = function(info) return IsTestFieldOff("Player Status", "checkTotems") or IsTestFieldOff("Player Status", "water") end,
													get = function(info) return GetTestField("Player Status", "waterTotem") end,
													set = function(info, value) SetTestFieldString("Player Status", "waterTotem", value) end,
												},
											},
										},
									},
								},
								CheckChiGroup = {
									type = "group", order = 82, name = L["Chi"], inline = true, 
									args = {
										CheckPowerEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the player's chi."],
											get = function(info) return IsTestFieldOn("Player Status", "checkChi") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkChi", v) end,
										},
										CheckPower = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, player must have at least this much chi, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkChi") end,
											get = function(info) return GetTestField("Player Status", "checkChi") == true end,
											set = function(info, value) SetTestField("Player Status", "checkChi", value) end,
										},
										PowerRange = {
											type = "range", order = 3, name = "", min = 1, max = 5, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkChi") end,
											get = function(info) return GetTestField("Player Status", "minChi") end,
											set = function(info, value) SetTestField("Player Status", "minChi", value) end,
										},
									},
								},
								CheckComboPointsGroup = {
									type = "group", order = 83, name = L["Combo Points"], inline = true, 
									args = {
										CheckComboPointsEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test how many combo points the player has on the target."],
											get = function(info) return IsTestFieldOn("Player Status", "checkComboPoints") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkComboPoints", v) end,
										},
										CheckComboPoints = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, player must have at least this many combo points, otherwise must be fewer."],
											disabled = function(info) return IsTestFieldOff("Player Status", "checkComboPoints") end,
											get = function(info) return GetTestField("Player Status", "checkComboPoints") == true end,
											set = function(info, value) SetTestField("Player Status", "checkComboPoints", value) end,
										},
										ComboPointsRange = {
											type = "range", order = 3, name = "", min = 1, max = 5, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "checkComboPoints") end,
											get = function(info) return GetTestField("Player Status", "minComboPoints") end,
											set = function(info, value) SetTestField("Player Status", "minComboPoints", value) end,
										},
									},
								},
								CheckWeaponGroup = {
									type = "group", order = 85, name = L["Weapons"], inline = true, 
									args = {
										CheckMainHandEnable = {
											type = "toggle", order = 1, name = L["Mainhand"], width = "half",
											desc = L["If checked, test if the player has a mainhand weapon equipped with at least the specified item level."],
											get = function(info) return IsTestFieldOn("Player Status", "hasMainHand") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "hasMainHand", v) end,
										},
										MainHandLevel = {
											type = "range", order = 2, name = "", min = 1, max = 500, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "hasMainHand") end,
											get = function(info)
												local level = GetTestField("Player Status", "levelMainHand")
												if not level then level = 1; SetTestField("Player Status", "levelMainHand", level) end
												return level
											end,
											set = function(info, value) SetTestField("Player Status", "levelMainHand", value) end,
										},
										CheckOffHandEnable = {
											type = "toggle", order = 3, name = L["Offhand"], width = "half",
											desc = L["If checked, test if the player has an offhand weapon equipped with at least the specified item level."],
											get = function(info) return IsTestFieldOn("Player Status", "hasOffHand") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "hasOffHand", v) end,
										},
										OffHandLevel = {
											type = "range", order = 4, name = "", min = 1, max = 500, step = 1,
											disabled = function(info) return IsTestFieldOff("Player Status", "hasOffHand") end,
											get = function(info)
												local level = GetTestField("Player Status", "levelOffHand")
												if not level then level = 1; SetTestField("Player Status", "levelOffHand", level) end
												return level
											end,
											set = function(info, value) SetTestField("Player Status", "levelOffHand", value) end,
										},
									},
								},
								CheckStanceGroup = {
									type = "group", order = 90, name = L["Stance"], inline = true, 
									args = {
										CheckStanceEnable = {
											type = "toggle", order = 10, name = L["Enable"], width = "half",
											desc = L["If checked, test if the player is in a stance."],
											get = function(info) return IsTestFieldOn("Player Status", "checkStance") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkStance", v) end,
										},
										StanceEntry = {
											type = "input", order = 20, name = L["Stance"],
											desc = L['Enter the stance to check for (enter "none" to check for no stance).'],
											get = function(info) return GetTestField("Player Status", "stance") end,
											set = function(info, value) SetTestFieldString("Player Status", "stance", value) end,
										},
									},
								},
								CheckTalentGroup = {
									type = "group", order = 95, name = L["Talent"], inline = true, 
									args = {
										CheckTalentsEnable = {
											type = "toggle", order = 10, name = L["Enable"], width = "half",
											desc = L["If checked, test if player's talents include a specific talent."],
											get = function(info) return IsTestFieldOn("Player Status", "checkTalent") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkTalent", v) end,
										},
										SelectTalent = {
											type = "select", order = 20, name = L["Talent"],
											get = function(info) local v = GetTestField("Player Status", "talent"); if v then local t = MOD.talents[v]; if t then return t.select end end return nil end,
											set = function(info, value) SetTestField("Player Status", "talent", MOD.talentList[value]) end,
											values = function(info) return MOD.talentList end,
											style = "dropdown",
										},
									},
								},
								CheckSpecGroup = {
									type = "group", order = 100, name = L["Specialization"], inline = true, 
									args = {
										CheckSpecEnable = {
											type = "toggle", order = 10, name = L["Enable"], width = "half",
											desc = L["If checked, test player's specialization."],
											get = function(info) return IsTestFieldOn("Player Status", "checkSpec") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkSpec", v) end,
										},
										SpecEntry = {
											type = "input", order = 20, name = L["Specialization"],
											desc = L['Enter the specialization to check for (enter "none" to check for no specialization).'],
											get = function(info) return GetTestField("Player Status", "spec") end,
											set = function(info, value) SetTestFieldString("Player Status", "spec", value) end,
										},
									},
								},
								CheckSpellGroup = {
									type = "group", order = 105, name = L["Spellbook"], inline = true, 
									args = {
										CheckSpellEnable = {
											type = "toggle", order = 10, name = L["Enable"], width = "half",
											desc = L["If checked, test if a spell is in the player's spellbook."],
											get = function(info) return IsTestFieldOn("Player Status", "checkSpell") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkSpell", v) end,
										},
										SpellName = {
											type = "input", order = 20, name = L["Spell"],
											desc = L['Enter a spell name (or numeric identifier) to test is known in the spellbook.'],
											get = function(info) return GetTestField("Player Status", "spell") end,
											set = function(info, value) SetTestFieldString("Player Status", "spell", value) end,
										},
									},
								},
								CheckGlyphGroup = {
									type = "group", order = 110, name = L["Glyph"], inline = true, 
									args = {
										CheckGlyphEnable = {
											type = "toggle", order = 10, name = L["Enable"], width = "half",
											desc = L["If checked, test if a glyph is active."],
											get = function(info) return IsTestFieldOn("Player Status", "checkGlyph") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Player Status", "checkGlyph", v) end,
										},
										GlyphName = {
											type = "input", order = 20, name = L["Glyph"],
											desc = L['Enter short name for glyph (e.g., "Glyph of Overpower" is entered as "Overpower").'],
											get = function(info) return GetTestField("Player Status", "glyph") end,
											set = function(info, value) SetTestFieldString("Player Status", "glyph", value) end,
										},
									},
								},
							},
						},
						PetStatusGroup = {
							type = "group", order = 35, name = L["Pet Status"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Pet Status", "enable") end,
											set = function(info, value) SetTestField("Pet Status", "enable", value) end,
										},
									},
								},
								ExistsGroup = {
									type = "group", order = 10, name = L["Exists"], inline = true,
									args = {
										CheckExists = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if pet currently exists."],
											get = function(info) return IsTestFieldOn("Pet Status", "exists") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Pet Status", "exists", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Exists"],
											desc = L["If checked, pet must exist."],
											disabled = function(info) return IsTestFieldOff("Pet Status", "exists") end,
											get = function(info) return GetTestField("Pet Status", "exists") == true end,
											set = function(info, value) SetTestField("Pet Status", "exists", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Exists"],
											desc = L["If checked, pet must not exist."],
											disabled = function(info) return IsTestFieldOff("Pet Status", "exists") end,
											get = function(info) return GetTestField("Pet Status", "exists") == false end,
											set = function(info, value) SetTestField("Pet Status", "exists", false) end,
										},
									},
								},
								CombatGroup = {
									type = "group", order = 20, name = L["Combat"], inline = true,
									args = {
										CheckCombat = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test combat status."],
											get = function(info) return IsTestFieldOn("Pet Status", "inCombat") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Pet Status", "inCombat", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["In Combat"],
											desc = L["If checked, must be in combat."],
											disabled = function(info) return IsTestFieldOff("Pet Status", "inCombat") end,
											get = function(info) return GetTestField("Pet Status", "inCombat") == true end,
											set = function(info, value) SetTestField("Pet Status", "inCombat", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Out Of Combat"],
											desc = L["If checked, must be out of combat."],
											disabled = function(info) return IsTestFieldOff("Pet Status", "inCombat") end,
											get = function(info) return GetTestField("Pet Status", "inCombat") == false end,
											set = function(info, value) SetTestField("Pet Status", "inCombat", false) end,
										},
									},
								},
								TargetGroup = {
									type = "group", order = 30, name = L["Target"], inline = true,
									args = {
										CheckTarget = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test pet's target."],
											get = function(info) return IsTestFieldOn("Pet Status", "checkTarget") end,
											set = function(info, value) local v = Off if value then v = "none" end SetTestField("Pet Status", "checkTarget", v) end,
										},
										spacer1 = { type = "description", name = "", order = 10 },
										DoNone = {
											type = "toggle", order = 20, name = L["No Target"],
											desc = L["If checked, must not have a target."],
											disabled = function(info) return IsTestFieldOff("Pet Status", "checkTarget") end,
											get = function(info) return GetTestField("Pet Status", "checkTarget") == "none" end,
											set = function(info, value) SetTestField("Pet Status", "checkTarget", "none") end,
										},
										DoPlayers = {
											type = "toggle", order = 30, name = L["Player's Target"],
											desc = L["If checked, must be same as player's target."],
											disabled = function(info) return IsTestFieldOff("Pet Status", "checkTarget") end,
											get = function(info) return GetTestField("Pet Status", "checkTarget") == "player" end,
											set = function(info, value) SetTestField("Pet Status", "checkTarget", "player") end,
										},
										DoAny = {
											type = "toggle", order = 40, name = L["Any Target"],
											desc = L["If checked, must have a target."],
											disabled = function(info) return IsTestFieldOff("Pet Status", "checkTarget") end,
											get = function(info) return GetTestField("Pet Status", "checkTarget") == "any" end,
											set = function(info, value) SetTestField("Pet Status", "checkTarget", "any") end,
										},
									},
								},
								CheckHealthGroup = {
									type = "group", order = 50, name = L["Health"], inline = true, 
									args = {
										CheckHealthEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the pet's health."],
											get = function(info) return IsTestFieldOn("Pet Status", "checkHealth") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Pet Status", "checkHealth", v) end,
										},
										CheckHealth = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, pet's health must be at least this percentage, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Pet Status", "checkHealth") end,
											get = function(info) return GetTestField("Pet Status", "checkHealth") == true end,
											set = function(info, value) SetTestField("Pet Status", "checkHealth", value) end,
										},
										HealthRange = {
											type = "range", order = 3, name = "", min = 1, max = 100, step = 1,
											disabled = function(info) return IsTestFieldOff("Pet Status", "checkHealth") end,
											get = function(info) return GetTestField("Pet Status", "minHealth") end,
											set = function(info, value) SetTestField("Pet Status", "minHealth", value) end,
										},
									},
								},
								CheckPowerGroup = {
									type = "group", order = 70, name = L["Power"], inline = true, 
									args = {
										CheckPowerEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the pet's power (i.e., mana, rage, energy, focus)."],
											get = function(info) return IsTestFieldOn("Pet Status", "checkPower") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Pet Status", "checkPower", v) end,
										},
										CheckPower = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, pet's power must be at least this percentage, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Pet Status", "checkPower") end,
											get = function(info) return GetTestField("Pet Status", "checkPower") == true end,
											set = function(info, value) SetTestField("Pet Status", "checkPower", value) end,
										},
										PowerRange = {
											type = "range", order = 3, name = "", min = 1, max = 100, step = 1,
											disabled = function(info) return IsTestFieldOff("Pet Status", "checkPower") end,
											get = function(info) return GetTestField("Pet Status", "minPower") end,
											set = function(info, value) SetTestField("Pet Status", "minPower", value) end,
										},
									},
								},
								CheckFamily = {
									type = "group", order = 80, name = L["Family"], inline = true, 
									args = {
										CheckSpecEnable = {
											type = "toggle", order = 10, name = L["Enable"], width = "half",
											desc = L["If checked, test pet's creature family."],
											get = function(info) return IsTestFieldOn("Pet Status", "checkFamily") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Pet Status", "checkFamily", v) end,
										},
										SpecEntry = {
											type = "input", order = 20, name = L["Family"],
											desc = L['Enter the creature family to check for (enter "none" to check if not applicable).'],
											get = function(info) return GetTestField("Pet Status", "family") end,
											set = function(info, value) SetTestFieldString("Pet Status", "family", value) end,
										},
									},
								},
								CheckSpecGroup = {
									type = "group", order = 100, name = L["Talent Tree"], inline = true, 
									args = {
										CheckSpecEnable = {
											type = "toggle", order = 10, name = L["Enable"], width = "half",
											desc = L["If checked, test pet's talent tree."],
											get = function(info) return IsTestFieldOn("Pet Status", "checkSpec") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Pet Status", "checkSpec", v) end,
										},
										SpecEntry = {
											type = "input", order = 20, name = L["Talent Tree"],
											desc = L['Enter the talent tree to check for (enter "none" to check for no talents).'],
											get = function(info) return GetTestField("Pet Status", "spec") end,
											set = function(info, value) SetTestFieldString("Pet Status", "spec", value) end,
										},
									},
								},
							},
						},
						TargetStatusGroup = {
							type = "group", order = 35, name = L["Target Status"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Target Status", "enable") end,
											set = function(info, value) SetTestField("Target Status", "enable", value) end,
										},
									},
								},
								ExistsGroup = {
									type = "group", order = 3, name = L["Exists"], inline = true,
									args = {
										CheckExists = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if target currently exists."],
											get = function(info) return IsTestFieldOn("Target Status", "exists") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Target Status", "exists", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Exists"],
											desc = L["If checked, target must exist."],
											disabled = function(info) return IsTestFieldOff("Target Status", "exists") end,
											get = function(info) return GetTestField("Target Status", "exists") == true end,
											set = function(info, value) SetTestField("Target Status", "exists", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Exists"],
											desc = L["If checked, target must not exist."],
											disabled = function(info) return IsTestFieldOff("Target Status", "exists") end,
											get = function(info) return GetTestField("Target Status", "exists") == false end,
											set = function(info, value) SetTestField("Target Status", "exists", false) end,
										},
									},
								},
								PlayerGroup = {
									type = "group", order = 5, name = L["Player"], inline = true,
									args = {
										CheckPlayer = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the target is a player."],
											get = function(info) return IsTestFieldOn("Target Status", "isPlayer") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Target Status", "isPlayer", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is Player"],
											desc = L["If checked, target must be a player."],
											disabled = function(info) return IsTestFieldOff("Target Status", "isPlayer") end,
											get = function(info) return GetTestField("Target Status", "isPlayer") == true end,
											set = function(info, value) SetTestField("Target Status", "isPlayer", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Player"],
											desc = L["If checked, target must not be a player."],
											disabled = function(info) return IsTestFieldOff("Target Status", "isPlayer") end,
											get = function(info) return GetTestField("Target Status", "isPlayer") == false end,
											set = function(info, value) SetTestField("Target Status", "isPlayer", false) end,
										},
									},
								},
								EnemyGroup = {
									type = "group", order = 10, name = L["Enemy"], inline = true,
									args = {
										CheckEnemy = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the target is an enemy."],
											get = function(info) return IsTestFieldOn("Target Status", "isEnemy") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Target Status", "isEnemy", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is Enemy"],
											desc = L["If checked, target must be an enemy."],
											disabled = function(info) return IsTestFieldOff("Target Status", "isEnemy") end,
											get = function(info) return GetTestField("Target Status", "isEnemy") == true end,
											set = function(info, value) SetTestField("Target Status", "isEnemy", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Enemy"],
											desc = L["If checked, target must not be an enemy."],
											disabled = function(info) return IsTestFieldOff("Target Status", "isEnemy") end,
											get = function(info) return GetTestField("Target Status", "isEnemy") == false end,
											set = function(info, value) SetTestField("Target Status", "isEnemy", false) end,
										},
									},
								},
								FriendGroup = {
									type = "group", order = 20, name = L["Friendly"], inline = true,
									args = {
										CheckFriend = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the target is friendly."],
											get = function(info) return IsTestFieldOn("Target Status", "isFriend") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Target Status", "isFriend", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is Friendly"],
											desc = L["If checked, target must be friendly."],
											disabled = function(info) return IsTestFieldOff("Target Status", "isFriend") end,
											get = function(info) return GetTestField("Target Status", "isFriend") == true end,
											set = function(info, value) SetTestField("Target Status", "isFriend", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Friendly"],
											desc = L["If checked, target must not be friendly."],
											disabled = function(info) return IsTestFieldOff("Target Status", "isFriend") end,
											get = function(info) return GetTestField("Target Status", "isFriend") == false end,
											set = function(info, value) SetTestField("Target Status", "isFriend", false) end,
										},
									},
								},
								DeadGroup = {
									type = "group", order = 22, name = L["Dead"], inline = true,
									args = {
										CheckDead = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the target is dead."],
											get = function(info) return IsTestFieldOn("Target Status", "isDead") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Target Status", "isDead", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is Dead"],
											desc = L["If checked, target must be dead."],
											disabled = function(info) return IsTestFieldOff("Target Status", "isDead") end,
											get = function(info) return GetTestField("Target Status", "isDead") == true end,
											set = function(info, value) SetTestField("Target Status", "isDead", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Dead"],
											desc = L["If checked, target must not be dead."],
											disabled = function(info) return IsTestFieldOff("Target Status", "isDead") end,
											get = function(info) return GetTestField("Target Status", "isDead") == false end,
											set = function(info, value) SetTestField("Target Status", "isDead", false) end,
										},
									},
								},
								Classification = {
									type = "group", order = 25, name = L["Classification"], inline = true,
									args = {
										Enable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the target's classification (you can select multiple classifications)."],
											get = function(info) return GetTestField("Target Status", "classify") end,
											set = function(info, value) SetTestField("Target Status", "classify", value) end,
										},
										spacer1 = { type = "description", name = "", order = 10 },
										Normal = {
											type = "toggle", order = 20, name = L["Normal"], width = "half",
											desc = L["If checked, test for normal classification."],
											disabled = function(info) return not GetTestField("Target Status", "classify") end,
											get = function(info) return IsClassification("Target Status", "normal") end,
											set = function(info, value) SetClassification("Target Status", "normal", value) end,
										},
										Boss = {
											type = "toggle", order = 21, name = L["Boss"], width = "half",
											desc = L["If checked, test for boss classification."],
											disabled = function(info) return not GetTestField("Target Status", "classify") end,
											get = function(info) return IsClassification("Target Status", "worldboss") end,
											set = function(info, value) SetClassification("Target Status", "worldboss", value) end,
										},
										Elite = {
											type = "toggle", order = 22, name = L["Elite"], width = "half",
											desc = L["If checked, test for elite classification."],
											disabled = function(info) return not GetTestField("Target Status", "classify") end,
											get = function(info) return IsClassification("Target Status", "elite") end,
											set = function(info, value) SetClassification("Target Status", "elite", value) end,
										},
										Rare = {
											type = "toggle", order = 23, name = L["Rare"], width = "half",
											desc = L["If checked, test for rare classification."],
											disabled = function(info) return not GetTestField("Target Status", "classify") end,
											get = function(info) return IsClassification("Target Status", "rare") end,
											set = function(info, value) SetClassification("Target Status", "rare", value) end,
										},
										RareElite = {
											type = "toggle", order = 25, name = L["Rare Elite"],
											desc = L["If checked, test for rare elite classification."],
											disabled = function(info) return not GetTestField("Target Status", "classify") end,
											get = function(info) return IsClassification("Target Status", "rlite") end,
											set = function(info, value) SetClassification("Target Status", "rlite", value) end,
										},
									},
								},
								RangeGroup = {
									type = "group", order = 30, name = L["Range"], inline = true,
									args = {
										CheckRange = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the target is in range."],
											get = function(info) return IsTestFieldOn("Target Status", "inRange") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Target Status", "inRange", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["In Range"],
											desc = L["If checked, target must be in range."],
											disabled = function(info) return IsTestFieldOff("Target Status", "inRange") end,
											get = function(info) return GetTestField("Target Status", "inRange") == true end,
											set = function(info, value) SetTestField("Target Status", "inRange", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Out Of Range"],
											desc = L["If checked, target must not be in range."],
											disabled = function(info) return IsTestFieldOff("Target Status", "inRange") end,
											get = function(info) return GetTestField("Target Status", "inRange") == false end,
											set = function(info, value) SetTestField("Target Status", "inRange", false) end,
										},
									},
								},
								StealableGroup = {
									type = "group", order = 35, name = L["Spellsteal"], inline = true,
									args = {
										CheckSteal = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test for a buff that can be transferred to the player with Spellsteal."],
											get = function(info) return IsTestFieldOn("Target Status", "isSteal") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Target Status", "isSteal", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Spellsteal"],
											desc = L["If checked, there must be a spellstealable buff."],
											disabled = function(info) return IsTestFieldOff("Target Status", "isSteal") end,
											get = function(info) return GetTestField("Target Status", "isSteal") == true end,
											set = function(info, value) SetTestField("Target Status", "isSteal", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Spellsteal"],
											desc = L["If checked, there must not be a spellstealable buff."],
											disabled = function(info) return IsTestFieldOff("Target Status", "isSteal") end,
											get = function(info) return GetTestField("Target Status", "isSteal") == false end,
											set = function(info, value) SetTestField("Target Status", "isSteal", false) end,
										},
									},
								},
								CheckMaxHealth = {
									type = "group", order = 40, name = L["Maximum Health"], inline = true, 
									args = {
										CheckEnable = {
											type = "toggle", order = 10, name = L["Enable"], width = "half",
											desc = L["If checked, test the target's maximum health."],
											get = function(info) return IsTestFieldOn("Target Status", "checkMaxHealth") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Target Status", "checkMaxHealth", v) end,
										},
										MaxHealth = {
											type = "input", order = 20, name = L["Maximum Health"],
											desc = L["Enter minimum value for target's maximum health required for test to be true."],
											get = function(info) return GetTestField("Target Status", "maxHealth") end,
											set = function(info, value) SetTestFieldString("Target Status", "maxHealth", value) end,
										},
									},
								},
								CheckHealthGroup = {
									type = "group", order = 50, name = L["Health"], inline = true, 
									args = {
										CheckHealthEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the target's health."],
											get = function(info) return IsTestFieldOn("Target Status", "checkHealth") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Target Status", "checkHealth", v) end,
										},
										CheckHealth = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, target's health must be at least this percentage, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Target Status", "checkHealth") end,
											get = function(info) return GetTestField("Target Status", "checkHealth") == true end,
											set = function(info, value) SetTestField("Target Status", "checkHealth", value) end,
										},
										HealthRange = {
											type = "range", order = 3, name = "", min = 1, max = 100, step = 1,
											disabled = function(info) return IsTestFieldOff("Target Status", "checkHealth") end,
											get = function(info) return GetTestField("Target Status", "minHealth") end,
											set = function(info, value) SetTestField("Target Status", "minHealth", value) end,
										},
									},
								},
								CheckPowerGroup = {
									type = "group", order = 70, name = L["Power"], inline = true, 
									args = {
										CheckPowerEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the target's power (i.e., mana, rage, energy, focus, runic power)."],
											get = function(info) return IsTestFieldOn("Target Status", "checkPower") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Target Status", "checkPower", v) end,
										},
										CheckPower = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, target's power must be at least this percentage, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Target Status", "checkPower") end,
											get = function(info) return GetTestField("Target Status", "checkPower") == true end,
											set = function(info, value) SetTestField("Target Status", "checkPower", value) end,
										},
										PowerRange = {
											type = "range", order = 3, name = "", min = 1, max = 100, step = 1,
											disabled = function(info) return IsTestFieldOff("Target Status", "checkPower") end,
											get = function(info) return GetTestField("Target Status", "minPower") end,
											set = function(info, value) SetTestField("Target Status", "minPower", value) end,
										},
									},
								},
							},
						},
						FocusStatusGroup = {
							type = "group", order = 40, name = L["Focus Status"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Focus Status", "enable") end,
											set = function(info, value) SetTestField("Focus Status", "enable", value) end,
										},
									},
								},
								ExistsGroup = {
									type = "group", order = 3, name = L["Exists"], inline = true,
									args = {
										CheckExists = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if focus currently exists."],
											get = function(info) return IsTestFieldOn("Focus Status", "exists") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Focus Status", "exists", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Exists"],
											desc = L["If checked, focus must exist."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "exists") end,
											get = function(info) return GetTestField("Focus Status", "exists") == true end,
											set = function(info, value) SetTestField("Focus Status", "exists", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Exists"],
											desc = L["If checked, focus must not exist."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "exists") end,
											get = function(info) return GetTestField("Focus Status", "exists") == false end,
											set = function(info, value) SetTestField("Focus Status", "exists", false) end,
										},
									},
								},
								PlayerGroup = {
									type = "group", order = 5, name = L["Player"], inline = true,
									args = {
										CheckPlayer = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the focus is a player."],
											get = function(info) return IsTestFieldOn("Focus Status", "isPlayer") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Focus Status", "isPlayer", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is Player"],
											desc = L["If checked, focus must be a player."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "isPlayer") end,
											get = function(info) return GetTestField("Focus Status", "isPlayer") == true end,
											set = function(info, value) SetTestField("Focus Status", "isPlayer", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Player"],
											desc = L["If checked, focus must not be a player."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "isPlayer") end,
											get = function(info) return GetTestField("Focus Status", "isPlayer") == false end,
											set = function(info, value) SetTestField("Focus Status", "isPlayer", false) end,
										},
									},
								},
								EnemyGroup = {
									type = "group", order = 10, name = L["Enemy"], inline = true,
									args = {
										CheckEnemy = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the focus is an enemy."],
											get = function(info) return IsTestFieldOn("Focus Status", "isEnemy") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Focus Status", "isEnemy", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is Enemy"],
											desc = L["If checked, focus must be an enemy."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "isEnemy") end,
											get = function(info) return GetTestField("Focus Status", "isEnemy") == true end,
											set = function(info, value) SetTestField("Focus Status", "isEnemy", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Enemy"],
											desc = L["If checked, focus must not be an enemy."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "isEnemy") end,
											get = function(info) return GetTestField("Focus Status", "isEnemy") == false end,
											set = function(info, value) SetTestField("Focus Status", "isEnemy", false) end,
										},
									},
								},
								FriendGroup = {
									type = "group", order = 20, name = L["Friendly"], inline = true,
									args = {
										CheckFriend = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the focus is friendly."],
											get = function(info) return IsTestFieldOn("Focus Status", "isFriend") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Focus Status", "isFriend", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is Friendly"],
											desc = L["If checked, focus must be friendly."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "isFriend") end,
											get = function(info) return GetTestField("Focus Status", "isFriend") == true end,
											set = function(info, value) SetTestField("Focus Status", "isFriend", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Friendly"],
											desc = L["If checked, focus must not be friendly."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "isFriend") end,
											get = function(info) return GetTestField("Focus Status", "isFriend") == false end,
											set = function(info, value) SetTestField("Focus Status", "isFriend", false) end,
										},
									},
								},
								DeadGroup = {
									type = "group", order = 22, name = L["Dead"], inline = true,
									args = {
										CheckFriend = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the focus is dead."],
											get = function(info) return IsTestFieldOn("Focus Status", "isDead") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Focus Status", "isDead", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Is Dead"],
											desc = L["If checked, focus must be dead."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "isDead") end,
											get = function(info) return GetTestField("Focus Status", "isDead") == true end,
											set = function(info, value) SetTestField("Focus Status", "isDead", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Dead"],
											desc = L["If checked, focus must not be dead."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "isDead") end,
											get = function(info) return GetTestField("Focus Status", "isDead") == false end,
											set = function(info, value) SetTestField("Focus Status", "isDead", false) end,
										},
									},
								},
								Classification = {
									type = "group", order = 25, name = L["Classification"], inline = true,
									args = {
										Enable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the focus's classification (you can select multiple classifications)."],
											get = function(info) return GetTestField("Focus Status", "classify") end,
											set = function(info, value) SetTestField("Focus Status", "classify", value) end,
										},
										spacer1 = { type = "description", name = "", order = 10 },
										Normal = {
											type = "toggle", order = 20, name = L["Normal"], width = "half",
											desc = L["If checked, test for normal classification."],
											disabled = function(info) return not GetTestField("Focus Status", "classify") end,
											get = function(info) return IsClassification("Focus Status", "normal") end,
											set = function(info, value) SetClassification("Focus Status", "normal", value) end,
										},
										Boss = {
											type = "toggle", order = 21, name = L["Boss"], width = "half",
											desc = L["If checked, test for boss classification."],
											disabled = function(info) return not GetTestField("Focus Status", "classify") end,
											get = function(info) return IsClassification("Focus Status", "worldboss") end,
											set = function(info, value) SetClassification("Focus Status", "worldboss", value) end,
										},
										Elite = {
											type = "toggle", order = 22, name = L["Elite"], width = "half",
											desc = L["If checked, test for elite classification."],
											disabled = function(info) return not GetTestField("Focus Status", "classify") end,
											get = function(info) return IsClassification("Focus Status", "elite") end,
											set = function(info, value) SetClassification("Focus Status", "elite", value) end,
										},
										Rare = {
											type = "toggle", order = 23, name = L["Rare"], width = "half",
											desc = L["If checked, test for rare classification."],
											disabled = function(info) return not GetTestField("Focus Status", "classify") end,
											get = function(info) return IsClassification("Focus Status", "rare") end,
											set = function(info, value) SetClassification("Focus Status", "rare", value) end,
										},
										RareElite = {
											type = "toggle", order = 25, name = L["Rare Elite"],
											desc = L["If checked, test for rare elite classification."],
											disabled = function(info) return not GetTestField("Focus Status", "classify") end,
											get = function(info) return IsClassification("Focus Status", "rlite") end,
											set = function(info, value) SetClassification("Focus Status", "rlite", value) end,
										},
									},
								},
								RangeGroup = {
									type = "group", order = 30, name = L["Range"], inline = true,
									args = {
										CheckRange = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the focus is in range."],
											get = function(info) return IsTestFieldOn("Focus Status", "inRange") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Focus Status", "inRange", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["In Range"],
											desc = L["If checked, focus must be in range."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "inRange") end,
											get = function(info) return GetTestField("Focus Status", "inRange") == true end,
											set = function(info, value) SetTestField("Focus Status", "inRange", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Out Of Range"],
											desc = L["If checked, focus must not be in range."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "inRange") end,
											get = function(info) return GetTestField("Focus Status", "inRange") == false end,
											set = function(info, value) SetTestField("Focus Status", "inRange", false) end,
										},
									},
								},
								StealableGroup = {
									type = "group", order = 35, name = L["Spellsteal"], inline = true,
									args = {
										CheckSteal = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test for a buff that can be transferred to the player with Spellsteal."],
											get = function(info) return IsTestFieldOn("Focus Status", "isSteal") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Focus Status", "isSteal", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Spellsteal"],
											desc = L["If checked, there must be a spellstealable buff."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "isSteal") end,
											get = function(info) return GetTestField("Focus Status", "isSteal") == true end,
											set = function(info, value) SetTestField("Focus Status", "isSteal", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Not Spellsteal"],
											desc = L["If checked, there must not be a spellstealable buff."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "isSteal") end,
											get = function(info) return GetTestField("Focus Status", "isSteal") == false end,
											set = function(info, value) SetTestField("Focus Status", "isSteal", false) end,
										},
									},
								},
								CheckHealthGroup = {
									type = "group", order = 50, name = L["Health"], inline = true, 
									args = {
										CheckHealthEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the focus's health."],
											get = function(info) return IsTestFieldOn("Focus Status", "checkHealth") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Focus Status", "checkHealth", v) end,
										},
										CheckHealth = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, focus's health must be at least this percentage, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "checkHealth") end,
											get = function(info) return GetTestField("Focus Status", "checkHealth") == true end,
											set = function(info, value) SetTestField("Focus Status", "checkHealth", value) end,
										},
										HealthRange = {
											type = "range", order = 3, name = "", min = 1, max = 100, step = 1,
											disabled = function(info) return IsTestFieldOff("Focus Status", "checkHealth") end,
											get = function(info) return GetTestField("Focus Status", "minHealth") end,
											set = function(info, value) SetTestField("Focus Status", "minHealth", value) end,
										},
									},
								},
								CheckPowerGroup = {
									type = "group", order = 70, name = L["Power"], inline = true, 
									args = {
										CheckPowerEnable = {
											type = "toggle", order = 1, name = L["Enable"], width = "half",
											desc = L["If checked, test the focus's power (i.e., mana, rage, energy, focus, runic power)."],
											get = function(info) return IsTestFieldOn("Focus Status", "checkPower") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Focus Status", "checkPower", v) end,
										},
										CheckPower = {
											type = "toggle", order = 2, name = L["Minimum"],
											desc = L["If checked, focus's power must be at least this percentage, otherwise must be less."],
											disabled = function(info) return IsTestFieldOff("Focus Status", "checkPower") end,
											get = function(info) return GetTestField("Focus Status", "checkPower") == true end,
											set = function(info, value) SetTestField("Focus Status", "checkPower", value) end,
										},
										PowerRange = {
											type = "range", order = 3, name = "", min = 1, max = 100, step = 1,
											disabled = function(info) return IsTestFieldOff("Focus Status", "checkPower") end,
											get = function(info) return GetTestField("Focus Status", "minPower") end,
											set = function(info, value) SetTestField("Focus Status", "minPower", value) end,
										},
									},
								},
							},
						},
						AllBuffsGroup = {
							type = "group", order = 45, name = L["All Buffs"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("All Buffs", "enable") end,
											set = function(info, value) SetTestField("All Buffs", "enable", value) end,
										},
									},
								},
								AurasGroup = {
									type = "group", order = 2, name = L["Buff List Entry"], inline = true,
									args = {
										AuraList = {
											type = "input", order = 1, name = L["Buffs"], width = "full",
											desc = L["Enter comma-separated list of buffs."],
											get = function(info) return GetTestFieldSpellList("All Buffs", "auras") end,
											set = function(info, value) SetTestFieldSpellList("All Buffs", "auras", value) end,
										},
									},
								},
								ToggleGroup = {
									type = "group", order = 5, name = L["Test Buffs"], inline = true,
									args = {
										AllActive = {
											type = "toggle", order = 10, name = L["All Active"],
											desc = L["If checked, test if all the buffs are active."],
											get = function(info) return GetTestField("All Buffs", "toggle") ~= true end,
											set = function(info, value) SetTestField("All Buffs", "toggle", Off)  end,
										},
										NotAllActive = {
											type = "toggle", order = 20, name = L["Not All Active"],
											desc = L["If checked, test if any of the buffs are not active."],
											get = function(info) return GetTestField("All Buffs", "toggle") == true end,
											set = function(info, value) SetTestField("All Buffs", "toggle", true)  end,
										},
									},
								},
								UnitGroup = {
									type = "group", order = 10, name = L["Who Has Buff"], inline = true,
									args = {
										PlayerBuff = {
											type = "toggle", order = 10, name = L["Player"], width = "half",
											desc = L["If checked, test if buff is on player."],
											get = function(info) return GetTestField("All Buffs", "unit") == "player" end,
											set = function(info, value) SetTestField("All Buffs", "unit", "player")  end,
										},
										PetBuff = {
											type = "toggle", order = 20, name = L["Pet"], width = "half",
											desc = L["If checked, test if buff is on pet."],
											get = function(info) return GetTestField("All Buffs", "unit") == "pet" end,
											set = function(info, value) SetTestField("All Buffs", "unit", "pet")  end,
										},
										TargetBuff = {
											type = "toggle", order = 30, name = L["Target"], width = "half",
											desc = L["If checked, test if buff is on target."],
											get = function(info) return GetTestField("All Buffs", "unit") == "target" end,
											set = function(info, value) SetTestField("All Buffs", "unit", "target")  end,
										},
										FocusBuff = {
											type = "toggle", order = 40, name = L["Focus"], width = "half",
											desc = L["If checked, test if buff is on focus."],
											get = function(info) return GetTestField("All Buffs", "unit") == "focus" end,
											set = function(info, value) SetTestField("All Buffs", "unit", "focus")  end,
										},
									},
								},
								IsMineGroup = {
									type = "group", order = 15, name = L["Who Cast Buff"], inline = true,
									args = {
										DoPlayer = {
											type = "toggle", order = 1, name = L["Cast By Player"],
											desc = L["If checked, test if the buffs were cast by the player."],
											get = function(info) return GetTestField("All Buffs", "isMine") == true end,
											set = function(info, value) SetTestField("All Buffs", "isMine", true) end,
										},
										DoOther = {
											type = "toggle", order = 2, name = L["Cast By Other"],
											desc = L["If checked, test if the buffs were cast by anyone other than the player."],
											get = function(info) return GetTestField("All Buffs", "isMine") == false end,
											set = function(info, value) SetTestField("All Buffs", "isMine", false) end,
										},
										DoAnyone = {
											type = "toggle", order = 3, name = L["Cast By Anyone"],
											desc = L["If checked, buffs may be cast by anyone, including the player."],
											get = function(info) return IsOff(GetTestField("All Buffs", "isMine")) end,
											set = function(info, value) SetTestField("All Buffs", "isMine", Off) end,
										},
									},
								},
							},
						},
						AnyBuffsGroup = {
							type = "group", order = 46, name = L["Any Buffs"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Any Buffs", "enable") end,
											set = function(info, value) SetTestField("Any Buffs", "enable", value) end,
										},
									},
								},
								AurasGroup = {
									type = "group", order = 5, name = L["Buff List Entry"], inline = true,
									args = {
										AuraList = {
											type = "input", order = 1, name = L["Buffs"], width = "full",
											desc = L["Enter comma-separated list of buffs."],
											get = function(info) return GetTestFieldSpellList("Any Buffs", "auras") end,
											set = function(info, value) SetTestFieldSpellList("Any Buffs", "auras", value) end,
										},
									},
								},
								ToggleGroup = {
									type = "group", order = 5, name = L["Test Buffs"], inline = true,
									args = {
										AllActive = {
											type = "toggle", order = 10, name = L["Any Active"],
											desc = L["If checked, test if any of the buffs are active."],
											get = function(info) return GetTestField("Any Buffs", "toggle") ~= true end,
											set = function(info, value) SetTestField("Any Buffs", "toggle", Off)  end,
										},
										NotAllActive = {
											type = "toggle", order = 20, name = L["None Active"],
											desc = L["If checked, test if none of the buffs are active."],
											get = function(info) return GetTestField("Any Buffs", "toggle") == true end,
											set = function(info, value) SetTestField("Any Buffs", "toggle", true)  end,
										},
									},
								},
								UnitGroup = {
									type = "group", order = 10, name = L["Who Has Buff"], inline = true,
									args = {
										PlayerBuff = {
											type = "toggle", order = 10, name = L["Player"], width = "half",
											desc = L["If checked, test if buff is on player."],
											get = function(info) return GetTestField("Any Buffs", "unit") == "player" end,
											set = function(info, value) SetTestField("Any Buffs", "unit", "player")  end,
										},
										PetBuff = {
											type = "toggle", order = 20, name = L["Pet"], width = "half",
											desc = L["If checked, test if buff is on pet."],
											get = function(info) return GetTestField("Any Buffs", "unit") == "pet" end,
											set = function(info, value) SetTestField("Any Buffs", "unit", "pet")  end,
										},
										TargetBuff = {
											type = "toggle", order = 30, name = L["Target"], width = "half",
											desc = L["If checked, test if buff is on target."],
											get = function(info) return GetTestField("Any Buffs", "unit") == "target" end,
											set = function(info, value) SetTestField("Any Buffs", "unit", "target")  end,
										},
										FocusBuff = {
											type = "toggle", order = 40, name = L["Focus"], width = "half",
											desc = L["If checked, test if buff is on focus."],
											get = function(info) return GetTestField("Any Buffs", "unit") == "focus" end,
											set = function(info, value) SetTestField("Any Buffs", "unit", "focus")  end,
										},
									},
								},
								IsMineGroup = {
									type = "group", order = 15, name = L["Who Cast Buff"], inline = true,
									args = {
										DoPlayer = {
											type = "toggle", order = 1, name = L["Cast By Player"],
											desc = L["If checked, test if the buffs were cast by the player."],
											get = function(info) return GetTestField("Any Buffs", "isMine") == true end,
											set = function(info, value) SetTestField("Any Buffs", "isMine", true) end,
										},
										DoOther = {
											type = "toggle", order = 2, name = L["Cast By Other"],
											desc = L["If checked, test if the buffs were cast by anyone other than the player."],
											get = function(info) return GetTestField("Any Buffs", "isMine") == false end,
											set = function(info, value) SetTestField("Any Buffs", "isMine", false) end,
										},
										DoAnyone = {
											type = "toggle", order = 3, name = L["Cast By Anyone"],
											desc = L["If checked, buffs may be cast by anyone, including the player."],
											get = function(info) return IsOff(GetTestField("Any Buffs", "isMine")) end,
											set = function(info, value) SetTestField("Any Buffs", "isMine", Off) end,
										},
									},
								},
							},
						},
						BuffTimeLeftGroup = {
							type = "group", order = 47, name = L["Buff Time Left"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Buff Time Left", "enable") end,
											set = function(info, value) SetTestField("Buff Time Left", "enable", value) end,
										},
									},
								},
								AuraGroup = {
									type = "group", order = 5, name = L["Buff Entry"], inline = true,
									args = {
										AuraList = {
											type = "input", order = 1, name = L["Buff"], width = "full",
											desc = L["Enter the buff to be tested."],
											get = function(info) return GetTestField("Buff Time Left", "aura") end,
											set = function(info, value) SetTestFieldString("Buff Time Left", "aura", value) end,
										},
									},
								},
								ToggleGroup = {
									type = "group", order = 10, name = L["Time Left"], inline = true,
									args = {
										TimeLeftMinutes= {
											type = "range", order = 1, name = L["Minutes"], min = 0, max = 120, step = 1,
											desc = L["Enter minutes for time left check."],
											get = function(info) local d = GetTestField("Buff Time Left", "timeLeft"); if d then return math.floor(d / 60) else return 0 end end,
											set = function(info, value) local d = GetTestField("Buff Time Left", "timeLeft"); if not d then d = 0 end; SetTestField("Buff Time Left", "timeLeft", (value * 60) + (d % 60)) end,
										},
										TimeLeftSeconds = {
											type = "range", order = 5, name = L["Seconds"], min = 0, max = 59, step = 1,
											desc = L["Enter seconds for time left check."],
											get = function(info) local d = GetTestField("Buff Time Left", "timeLeft"); if d then return d % 60 else return 0 end end,
											set = function(info, value) local d = GetTestField("Buff Time Left", "timeLeft"); if not d then d = 0 end; SetTestField("Buff Time Left", "timeLeft", value + (60 * math.floor(d / 60))) end,
										},
										TimeLeftMinMax = {
											type = "select", order = 6, name = L["Time Left"],
											get = function(info) if GetTestField("Buff Time Left", "toggle") == true then return 1 else return 2 end end,
											set = function(info, value) if value == 1 then SetTestField("Buff Time Left", "toggle", true) else SetTestField("Buff Time Left", "toggle", Off) end end,
											values = function(info)
												local d = GetTestField("Buff Time Left", "timeLeft")
												if not d then d = 0 end
												local ds = string.format("%0d:%02d", math.floor(d / 60), d % 60)
												return { L["Less Than"] .. " " .. ds, ds .. " " .. L["Or More"] }
											end,
											style = "dropdown",
										},
									},
								},
								UnitGroup = {
									type = "group", order = 20, name = L["Who Has Buff"], inline = true,
									args = {
										PlayerBuff = {
											type = "toggle", order = 10, name = L["Player"], width = "half",
											desc = L["If checked, test if buff is on player."],
											get = function(info) return GetTestField("Buff Time Left", "unit") == "player" end,
											set = function(info, value) SetTestField("Buff Time Left", "unit", "player")  end,
										},
										PetBuff = {
											type = "toggle", order = 20, name = L["Pet"], width = "half",
											desc = L["If checked, test if buff is on pet."],
											get = function(info) return GetTestField("Buff Time Left", "unit") == "pet" end,
											set = function(info, value) SetTestField("Buff Time Left", "unit", "pet")  end,
										},
										TargetBuff = {
											type = "toggle", order = 30, name = L["Target"], width = "half",
											desc = L["If checked, test if buff is on target."],
											get = function(info) return GetTestField("Buff Time Left", "unit") == "target" end,
											set = function(info, value) SetTestField("Buff Time Left", "unit", "target")  end,
										},
										FocusBuff = {
											type = "toggle", order = 40, name = L["Focus"], width = "half",
											desc = L["If checked, test if buff is on focus."],
											get = function(info) return GetTestField("Buff Time Left", "unit") == "focus" end,
											set = function(info, value) SetTestField("Buff Time Left", "unit", "focus")  end,
										},
									},
								},
								IsMineGroup = {
									type = "group", order = 25, name = L["Who Cast Buff"], inline = true,
									args = {
										DoPlayer = {
											type = "toggle", order = 1, name = L["Cast By Player"],
											desc = L["If checked, test if the buff was cast by the player."],
											get = function(info) return GetTestField("Buff Time Left", "isMine") == true end,
											set = function(info, value) SetTestField("Buff Time Left", "isMine", true) end,
										},
										DoOther = {
											type = "toggle", order = 2, name = L["Cast By Other"],
											desc = L["If checked, test if the buff was cast by anyone other than the player."],
											get = function(info) return GetTestField("Buff Time Left", "isMine") == false end,
											set = function(info, value) SetTestField("Buff Time Left", "isMine", false) end,
										},
										DoAnyone = {
											type = "toggle", order = 3, name = L["Cast By Anyone"],
											desc = L["If checked, buff may be cast by anyone, including the player."],
											get = function(info) return IsOff(GetTestField("Buff Time Left", "isMine")) end,
											set = function(info, value) SetTestField("Buff Time Left", "isMine", Off) end,
										},
									},
								},
							},
						},
						BuffCountGroup = {
							type = "group", order = 48, name = L["Buff Count"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Buff Count", "enable") end,
											set = function(info, value) SetTestField("Buff Count", "enable", value) end,
										},
									},
								},
								AuraGroup = {
									type = "group", order = 5, name = L["Buff Entry"], inline = true,
									args = {
										AuraList = {
											type = "input", order = 1, name = L["Buff"], width = "full",
											desc = L["Enter buff to test for stack count (if buff doesn't stack then its count is 0)."],
											get = function(info) return GetTestField("Buff Count", "aura") end,
											set = function(info, value) SetTestFieldString("Buff Count", "aura", value) end,
										},
									},
								},
								ToggleGroup = {
									type = "group", order = 10, name = L["Stack Count"], inline = true,
									args = {
										CountValue = {
											type = "range", order = 1, name = L["Count"], min = 1, max = 100, step = 1,
											desc = L["Enter value to compare with the buff stack count."],
											get = function(info) local d = GetTestField("Buff Count", "count"); if d then return d else return 1 end end,
											set = function(info, value) local d = GetTestField("Buff Count", "count"); if not d then d = 1 end; SetTestField("Buff Count", "count", value) end,
										},
										CountMinMax = {
											type = "select", order = 6, name = L["Comparison"],
											get = function(info) if GetTestField("Buff Count", "toggle") == true then return 1 else return 2 end end,
											set = function(info, value) if value == 1 then SetTestField("Buff Count", "toggle", true) else SetTestField("Buff Count", "toggle", Off) end end,
											values = function(info)
												local d = GetTestField("Buff Count", "count")
												if not d then d = 1 end
												return { "Less Than " .. d, d .. " Or More" }
											end,
											style = "dropdown",
										},
									},
								},
								UnitGroup = {
									type = "group", order = 15, name = L["Who Has Buff"], inline = true,
									args = {
										PlayerBuff = {
											type = "toggle", order = 10, name = L["Player"], width = "half",
											desc = L["If checked, test if buff is on player."],
											get = function(info) return GetTestField("Buff Count", "unit") == "player" end,
											set = function(info, value) SetTestField("Buff Count", "unit", "player")  end,
										},
										PetBuff = {
											type = "toggle", order = 20, name = L["Pet"], width = "half",
											desc = L["If checked, test if buff is on pet."],
											get = function(info) return GetTestField("Buff Count", "unit") == "pet" end,
											set = function(info, value) SetTestField("Buff Count", "unit", "pet")  end,
										},
										TargetBuff = {
											type = "toggle", order = 30, name = L["Target"], width = "half",
											desc = L["If checked, test if buff is on target."],
											get = function(info) return GetTestField("Buff Count", "unit") == "target" end,
											set = function(info, value) SetTestField("Buff Count", "unit", "target")  end,
										},
										FocusBuff = {
											type = "toggle", order = 40, name = L["Focus"], width = "half",
											desc = L["If checked, test if buff is on focus."],
											get = function(info) return GetTestField("Buff Count", "unit") == "focus" end,
											set = function(info, value) SetTestField("Buff Count", "unit", "focus")  end,
										},
									},
								},
								IsMineGroup = {
									type = "group", order = 20, name = L["Who Cast Buff"], inline = true,
									args = {
										DoPlayer = {
											type = "toggle", order = 1, name = L["Cast By Player"],
											desc = L["If checked, test if the buff was cast by the player."],
											get = function(info) return GetTestField("Buff Count", "isMine") == true end,
											set = function(info, value) SetTestField("Buff Count", "isMine", true) end,
										},
										DoOther = {
											type = "toggle", order = 2, name = L["Cast By Other"],
											desc = L["If checked, test if the buff was cast by anyone other than the player."],
											get = function(info) return GetTestField("Buff Count", "isMine") == false end,
											set = function(info, value) SetTestField("Buff Count", "isMine", false) end,
										},
										DoAnyone = {
											type = "toggle", order = 3, name = L["Cast By Anyone"],
											desc = L["If checked, buff may be cast by anyone, including the player."],
											get = function(info) return IsOff(GetTestField("Buff Count", "isMine")) end,
											set = function(info, value) SetTestField("Buff Count", "isMine", Off) end,
										},
									},
								},
							},
						},
						BuffTypeGroup = {
							type = "group", order = 49, name = L["Buff Type"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Buff Type", "enable") end,
											set = function(info, value) SetTestField("Buff Type", "enable", value) end,
										},
									},
								},
								CheckBuffGroup = {
									type = "group", order = 10, name = L["Player Has Buff"], inline = true, args = {
										CheckMainhand = {
											type = "toggle", order = 2, name = L["Mainhand"],
											desc = L["If checked, player must have a mainhand buff."],
											disabled = function(info) return IsTestFieldOff("Buff Type", "hasBuff") end,
											get = function(info)
												if not GetTestField("Buff Type", "hasBuff") then SetTestField("Buff Type", "hasBuff", "Mainhand") end
												return GetTestField("Buff Type", "hasBuff") == "Mainhand"
											end,
											set = function(info, value) if value then SetTestField("Buff Type", "hasBuff", "Mainhand") end end,
										},
										CheckOffhand = {
											type = "toggle", order = 3, name = L["Offhand"],
											desc = L["If checked, player must have an offhand buff."],
											disabled = function(info) return IsTestFieldOff("Buff Type", "hasBuff") end,
											get = function(info) return GetTestField("Buff Type", "hasBuff") == "Offhand" end,
											set = function(info, value) if value then SetTestField("Buff Type", "hasBuff", "Offhand") end end,
										},
									},
								},
								ToggleGroup = {
									type = "group", order = 20, name = L["Result"], inline = true,
									args = {
										CheckPresent = {
											type = "toggle", order = 2, name = L["Present"],
											desc = L["If checked, true if player has a buff of the specified type."],
											get = function(info) return GetTestField("Buff Type", "toggle") ~= true end,
											set = function(info, value) SetTestField("Buff Type", "toggle", false) end,
										},
										CheckMissing = {
											type = "toggle", order = 3, name = L["Missing"],
											desc = L["If checked, true if player does not have a buff of the specified type."],
											get = function(info) return GetTestField("Buff Type", "toggle") == true end,
											set = function(info, value) SetTestField("Buff Type", "toggle", true) end,
										},
									},
								},
							},
						},
						AllDebuffsGroup = {
							type = "group", order = 50, name = L["All Debuffs"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("All Debuffs", "enable") end,
											set = function(info, value) SetTestField("All Debuffs", "enable", value) end,
										},
									},
								},
								AurasGroup = {
									type = "group", order = 2, name = L["Debuff List Entry"], inline = true,
									args = {
										AuraList = {
											type = "input", order = 1, name = L["Debuffs"], width = "full",
											desc = L["Enter comma-separated list of debuffs."],
											get = function(info) return GetTestFieldSpellList("All Debuffs", "auras") end,
											set = function(info, value) SetTestFieldSpellList("All Debuffs", "auras", value) end,
										},
									},
								},
								ToggleGroup = {
									type = "group", order = 5, name = L["Test Debuffs"], inline = true,
									args = {
										AllActive = {
											type = "toggle", order = 10, name = L["All Active"],
											desc = L["If checked, test if all the debuffs are active."],
											get = function(info) return GetTestField("All Debuffs", "toggle") ~= true end,
											set = function(info, value) SetTestField("All Debuffs", "toggle", Off)  end,
										},
										NotAllActive = {
											type = "toggle", order = 20, name = L["Not All Active"],
											desc = L["If checked, test if any of the debuffs are not active."],
											get = function(info) return GetTestField("All Debuffs", "toggle") == true end,
											set = function(info, value) SetTestField("All Debuffs", "toggle", true)  end,
										},
									},
								},
								UnitGroup = {
									type = "group", order = 10, name = L["Who Has Debuff"], inline = true,
									args = {
										PlayerBuff = {
											type = "toggle", order = 10, name = L["Player"], width = "half",
											desc = L["If checked, test if debuff is on player."],
											get = function(info) return GetTestField("All Debuffs", "unit") == "player" end,
											set = function(info, value) SetTestField("All Debuffs", "unit", "player")  end,
										},
										PetBuff = {
											type = "toggle", order = 20, name = L["Pet"], width = "half",
											desc = L["If checked, test if debuff is on pet."],
											get = function(info) return GetTestField("All Debuffs", "unit") == "pet" end,
											set = function(info, value) SetTestField("All Debuffs", "unit", "pet")  end,
										},
										TargetBuff = {
											type = "toggle", order = 30, name = L["Target"], width = "half",
											desc = L["If checked, test if debuff is on target."],
											get = function(info) return GetTestField("All Debuffs", "unit") == "target" end,
											set = function(info, value) SetTestField("All Debuffs", "unit", "target")  end,
										},
										FocusBuff = {
											type = "toggle", order = 40, name = L["Focus"], width = "half",
											desc = L["If checked, test if debuff is on focus."],
											get = function(info) return GetTestField("All Debuffs", "unit") == "focus" end,
											set = function(info, value) SetTestField("All Debuffs", "unit", "focus")  end,
										},
									},
								},
								IsMineGroup = {
									type = "group", order = 15, name = L["Who Cast Debuff"], inline = true,
									args = {
										DoPlayer = {
											type = "toggle", order = 1, name = L["Cast By Player"],
											desc = L["If checked, test if the debuffs were cast by the player."],
											get = function(info) return GetTestField("All Debuffs", "isMine") == true end,
											set = function(info, value) SetTestField("All Debuffs", "isMine", true) end,
										},
										DoOther = {
											type = "toggle", order = 2, name = L["Cast By Other"],
											desc = L["If checked, test if the debuffs were cast by anyone other than the player."],
											get = function(info) return GetTestField("All Debuffs", "isMine") == false end,
											set = function(info, value) SetTestField("All Debuffs", "isMine", false) end,
										},
										DoAnyone = {
											type = "toggle", order = 3, name = L["Cast By Anyone"],
											desc = L["If checked, debuffs may be cast by anyone, including the player."],
											get = function(info) return IsOff(GetTestField("All Debuffs", "isMine")) end,
											set = function(info, value) SetTestField("All Debuffs", "isMine", Off) end,
										},
									},
								},
							},
						},
						AnyDebuffsGroup = {
							type = "group", order = 51, name = L["Any Debuffs"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Any Debuffs", "enable") end,
											set = function(info, value) SetTestField("Any Debuffs", "enable", value) end,
										},
									},
								},
								AurasGroup = {
									type = "group", order = 2, name = L["Debuff List Entry"], inline = true,
									args = {
										AuraList = {
											type = "input", order = 1, name = L["Debuffs"], width = "full",
											desc = L["Enter comma-separated list of debuffs."],
											get = function(info) return GetTestFieldSpellList("Any Debuffs", "auras") end,
											set = function(info, value) SetTestFieldSpellList("Any Debuffs", "auras", value) end,
										},
									},
								},
								ToggleGroup = {
									type = "group", order = 5, name = L["Test Debuffs"], inline = true,
									args = {
										AllActive = {
											type = "toggle", order = 10, name = L["Any Active"],
											desc = L["If checked, test if any of the debuffs are active."],
											get = function(info) return GetTestField("Any Debuffs", "toggle") ~= true end,
											set = function(info, value) SetTestField("Any Debuffs", "toggle", Off)  end,
										},
										NotAllActive = {
											type = "toggle", order = 20, name = L["None Active"],
											desc = L["If checked, test if none of the debuffs are active."],
											get = function(info) return GetTestField("Any Debuffs", "toggle") == true end,
											set = function(info, value) SetTestField("Any Debuffs", "toggle", true)  end,
										},
									},
								},
								UnitGroup = {
									type = "group", order = 10, name = L["Who Has Debuff"], inline = true,
									args = {
										PlayerBuff = {
											type = "toggle", order = 10, name = L["Player"], width = "half",
											desc = L["If checked, test if debuff is on player."],
											get = function(info) return GetTestField("Any Debuffs", "unit") == "player" end,
											set = function(info, value) SetTestField("Any Debuffs", "unit", "player")  end,
										},
										PetBuff = {
											type = "toggle", order = 20, name = L["Pet"], width = "half",
											desc = L["If checked, test if debuff is on pet."],
											get = function(info) return GetTestField("Any Debuffs", "unit") == "pet" end,
											set = function(info, value) SetTestField("Any Debuffs", "unit", "pet")  end,
										},
										TargetBuff = {
											type = "toggle", order = 30, name = L["Target"], width = "half",
											desc = L["If checked, test if debuff is on target."],
											get = function(info) return GetTestField("Any Debuffs", "unit") == "target" end,
											set = function(info, value) SetTestField("Any Debuffs", "unit", "target")  end,
										},
										FocusBuff = {
											type = "toggle", order = 40, name = L["Focus"], width = "half",
											desc = L["If checked, test if debuff is on focus."],
											get = function(info) return GetTestField("Any Debuffs", "unit") == "focus" end,
											set = function(info, value) SetTestField("Any Debuffs", "unit", "focus")  end,
										},
									},
								},
								IsMineGroup = {
									type = "group", order = 15, name = L["Who Cast Debuff"], inline = true,
									args = {
										DoPlayer = {
											type = "toggle", order = 1, name = L["Cast By Player"],
											desc = L["If checked, test if the debuffs were cast by the player."],
											get = function(info) return GetTestField("Any Debuffs", "isMine") == true end,
											set = function(info, value) SetTestField("Any Debuffs", "isMine", true) end,
										},
										DoOther = {
											type = "toggle", order = 2, name = L["Cast By Other"],
											desc = L["If checked, test if the debuffs were cast by anyone other than the player."],
											get = function(info) return GetTestField("Any Debuffs", "isMine") == false end,
											set = function(info, value) SetTestField("Any Debuffs", "isMine", false) end,
										},
										DoAnyone = {
											type = "toggle", order = 3, name = L["Cast By Anyone"],
											desc = L["If checked, debuffs may be cast by anyone, including the player."],
											get = function(info) return IsOff(GetTestField("Any Debuffs", "isMine")) end,
											set = function(info, value) SetTestField("Any Debuffs", "isMine", Off) end,
										},
									},
								},
							},
						},
						DebuffTimeLeftGroup = {
							type = "group", order = 52, name = L["Debuff Time Left"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Debuff Time Left", "enable") end,
											set = function(info, value) SetTestField("Debuff Time Left", "enable", value) end,
										},
									},
								},
								AuraGroup = {
									type = "group", order = 2, name = L["Debuff Entry"], inline = true,
									args = {
										AuraList = {
											type = "input", order = 1, name = L["Debuff"], width = "full",
											desc = L["Enter the debuff to be tested."],
											get = function(info) return GetTestField("Debuff Time Left", "aura") end,
											set = function(info, value) SetTestFieldString("Debuff Time Left", "aura", value) end,
										},
									},
								},
								ToggleGroup = {
									type = "group", order = 5, name = L["Time Left"], inline = true,
									args = {
										TimeLeftMinutes= {
											type = "range", order = 1, name = L["Minutes"], min = 0, max = 120, step = 1,
											desc = L["Enter minutes for time left check."],
											get = function(info) local d = GetTestField("Debuff Time Left", "timeLeft"); if d then return math.floor(d / 60) else return 0 end end,
											set = function(info, value) local d = GetTestField("Debuff Time Left", "timeLeft"); if not d then d = 0 end; SetTestField("Debuff Time Left", "timeLeft", (value * 60) + (d % 60)) end,
										},
										TimeLeftSeconds = {
											type = "range", order = 5, name = L["Seconds"], min = 0, max = 59, step = 1,
											desc = L["Enter seconds for time left check."],
											get = function(info) local d = GetTestField("Debuff Time Left", "timeLeft"); if d then return d % 60 else return 0 end end,
											set = function(info, value) local d = GetTestField("Debuff Time Left", "timeLeft"); if not d then d = 0 end; SetTestField("Debuff Time Left", "timeLeft", value + (60 * math.floor(d / 60))) end,
										},
										TimeLeftMinMax = {
											type = "select", order = 6, name = L["Time Left"],
											get = function(info) if GetTestField("Debuff Time Left", "toggle") == true then return 1 else return 2 end end,
											set = function(info, value) if value == 1 then SetTestField("Debuff Time Left", "toggle", true) else SetTestField("Debuff Time Left", "toggle", Off) end end,
											values = function(info)
												local d = GetTestField("Debuff Time Left", "timeLeft")
												if not d then d = 0 end
												local ds = string.format("%0d:%02d", math.floor(d / 60), d % 60)
												return { "Less Than " .. ds, ds .. " Or More" }
											end,
											style = "dropdown",
										},
									},
								},
								UnitGroup = {
									type = "group", order = 10, name = L["Who Has Debuff"], inline = true,
									args = {
										PlayerBuff = {
											type = "toggle", order = 10, name = L["Player"], width = "half",
											desc = L["If checked, test if debuff is on player."],
											get = function(info) return GetTestField("Debuff Time Left", "unit") == "player" end,
											set = function(info, value) SetTestField("Debuff Time Left", "unit", "player")  end,
										},
										PetBuff = {
											type = "toggle", order = 20, name = L["Pet"], width = "half",
											desc = L["If checked, test if debuff is on pet."],
											get = function(info) return GetTestField("Debuff Time Left", "unit") == "pet" end,
											set = function(info, value) SetTestField("Debuff Time Left", "unit", "pet")  end,
										},
										TargetBuff = {
											type = "toggle", order = 30, name = L["Target"], width = "half",
											desc = L["If checked, test if debuff is on target."],
											get = function(info) return GetTestField("Debuff Time Left", "unit") == "target" end,
											set = function(info, value) SetTestField("Debuff Time Left", "unit", "target")  end,
										},
										FocusBuff = {
											type = "toggle", order = 40, name = L["Focus"], width = "half",
											desc = L["If checked, test if debuff is on focus."],
											get = function(info) return GetTestField("Debuff Time Left", "unit") == "focus" end,
											set = function(info, value) SetTestField("Debuff Time Left", "unit", "focus")  end,
										},
									},
								},
								IsMineGroup = {
									type = "group", order = 15, name = L["Who Cast Debuff"], inline = true,
									args = {
										DoPlayer = {
											type = "toggle", order = 1, name = L["Cast By Player"],
											desc = L["If checked, test if the debuff was cast by the player."],
											get = function(info) return GetTestField("Debuff Time Left", "isMine") == true end,
											set = function(info, value) SetTestField("Debuff Time Left", "isMine", true) end,
										},
										DoOther = {
											type = "toggle", order = 2, name = L["Cast By Other"],
											desc = L["If checked, test if the debuff was cast by anyone other than the player."],
											get = function(info) return GetTestField("Debuff Time Left", "isMine") == false end,
											set = function(info, value) SetTestField("Debuff Time Left", "isMine", false) end,
										},
										DoAnyone = {
											type = "toggle", order = 3, name = L["Cast By Anyone"],
											desc = L["If checked, debuff may be cast by anyone, including the player."],
											get = function(info) return IsOff(GetTestField("Debuff Time Left", "isMine")) end,
											set = function(info, value) SetTestField("Debuff Time Left", "isMine", Off) end,
										},
									},
								},
							},
						},
						DebuffCountGroup = {
							type = "group", order = 53, name = L["Debuff Count"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Debuff Count", "enable") end,
											set = function(info, value) SetTestField("Debuff Count", "enable", value) end,
										},
									},
								},
								AuraGroup = {
									type = "group", order = 2, name = L["Debuff Entry"], inline = true,
									args = {
										AuraList = {
											type = "input", order = 1, name = L["Debuff"], width = "full",
											desc = L["Enter debuff to test for stack count (if debuff doesn't stack then its count is 0)."],
											get = function(info) return GetTestField("Debuff Count", "aura") end,
											set = function(info, value) SetTestFieldString("Debuff Count", "aura", value) end,
										},
									},
								},
								ToggleGroup = {
									type = "group", order = 5, name = L["Stack Count"], inline = true,
									args = {
										CountValue = {
											type = "range", order = 1, name = L["Count"], min = 1, max = 100, step = 1,
											desc = L["Enter value to compare with the debuff stack count."],
											get = function(info) local d = GetTestField("Debuff Count", "count"); if d then return d else return 1 end end,
											set = function(info, value) local d = GetTestField("Debuff Count", "count"); if not d then d = 1 end; SetTestField("Debuff Count", "count", value) end,
										},
										CountMinMax = {
											type = "select", order = 6, name = L["Comparison"],
											get = function(info) if GetTestField("Debuff Count", "toggle") == true then return 1 else return 2 end end,
											set = function(info, value) if value == 1 then SetTestField("Debuff Count", "toggle", true) else SetTestField("Debuff Count", "toggle", Off) end end,
											values = function(info)
												local d = GetTestField("Debuff Count", "count")
												if not d then d = 1 end
												return { "Less Than " .. d, d .. " Or More" }
											end,
											style = "dropdown",
										},
									},
								},
								UnitGroup = {
									type = "group", order = 10, name = L["Who Has Debuff"], inline = true,
									args = {
										PlayerBuff = {
											type = "toggle", order = 10, name = L["Player"], width = "half",
											desc = L["If checked, test if debuff is on player."],
											get = function(info) return GetTestField("Debuff Count", "unit") == "player" end,
											set = function(info, value) SetTestField("Debuff Count", "unit", "player")  end,
										},
										PetBuff = {
											type = "toggle", order = 20, name = L["Pet"], width = "half",
											desc = L["If checked, test if debuff is on pet."],
											get = function(info) return GetTestField("Debuff Count", "unit") == "pet" end,
											set = function(info, value) SetTestField("Debuff Count", "unit", "pet")  end,
										},
										TargetBuff = {
											type = "toggle", order = 30, name = L["Target"], width = "half",
											desc = L["If checked, test if debuff is on target."],
											get = function(info) return GetTestField("Debuff Count", "unit") == "target" end,
											set = function(info, value) SetTestField("Debuff Count", "unit", "target")  end,
										},
										FocusBuff = {
											type = "toggle", order = 40, name = L["Focus"], width = "half",
											desc = L["If checked, test if debuff is on focus."],
											get = function(info) return GetTestField("Debuff Count", "unit") == "focus" end,
											set = function(info, value) SetTestField("Debuff Count", "unit", "focus")  end,
										},
									},
								},
								IsMineGroup = {
									type = "group", order = 15, name = L["Who Cast Debuff"], inline = true,
									args = {
										DoPlayer = {
											type = "toggle", order = 1, name = L["Cast By Player"],
											desc = L["If checked, test if the debuff was cast by the player."],
											get = function(info) return GetTestField("Debuff Count", "isMine") == true end,
											set = function(info, value) SetTestField("Debuff Count", "isMine", true) end,
										},
										DoOther = {
											type = "toggle", order = 2, name = L["Cast By Other"],
											desc = L["If checked, test if the debuff was cast by anyone other than the player."],
											get = function(info) return GetTestField("Debuff Count", "isMine") == false end,
											set = function(info, value) SetTestField("Debuff Count", "isMine", false) end,
										},
										DoAnyone = {
											type = "toggle", order = 3, name = L["Cast By Anyone"],
											desc = L["If checked, debuff may be cast by anyone, including the player."],
											get = function(info) return IsOff(GetTestField("Debuff Count", "isMine")) end,
											set = function(info, value) SetTestField("Debuff Count", "isMine", Off) end,
										},
									},
								},
							},
						},
						DebuffTypeGroup = {
							type = "group", order = 54, name = L["Debuff Type"],
							args = {
								EnableTestGroup = {
									type = "group", order = 10, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Debuff Type", "enable") end,
											set = function(info, value) SetTestField("Debuff Type", "enable", value) end,
										},
									},
								},
								CheckDebuffGroup = {
									type = "group", order = 20, name = L["Player Has Debuff"], inline = true, args = {
										CheckPoisonDebuff = {
											type = "toggle", order = 2, name = L["Poison"], width = "half",
											desc = L["If checked, player must have a poison debuff."],
											get = function(info)
												if not GetTestField("Debuff Type", "hasDebuff") then SetTestField("Debuff Type", "hasDebuff", "Poison") end
												return GetTestField("Debuff Type", "hasDebuff") == "Poison"
												end,
											set = function(info, value) if value then SetTestField("Debuff Type", "hasDebuff", "Poison") end end,
										},
										CheckDiseaseDebuff = {
											type = "toggle", order = 3, name = L["Disease"], width = "half",
											desc = L["If checked, player must have a disease debuff."],
											get = function(info) return GetTestField("Debuff Type", "hasDebuff") == "Disease" end,
											set = function(info, value) if value then SetTestField("Debuff Type", "hasDebuff", "Disease") end end,
										},
										CheckCurseDebuff = {
											type = "toggle", order = 4, name = L["Curse"], width = "half",
											desc = L["If checked, player must have a curse debuff."],
											get = function(info) return GetTestField("Debuff Type", "hasDebuff") == "Curse" end,
											set = function(info, value) if value then SetTestField("Debuff Type", "hasDebuff", "Curse") end end,
										},
										CheckMagicDebuff = {
											type = "toggle", order = 5, name = L["Magic"], width = "half",
											desc = L["If checked, player must have a magic debuff."],
											get = function(info) return GetTestField("Debuff Type", "hasDebuff") == "Magic" end,
											set = function(info, value) if value then SetTestField("Debuff Type", "hasDebuff", "Magic") end end,
										},
									},
								},
								ToggleGroup = {
									type = "group", order = 30, name = L["Result"], inline = true,
									args = {
										CheckPresent = {
											type = "toggle", order = 2, name = L["Present"], 
											desc = L["If checked, true if player has a debuff of the specified type."],
											get = function(info) return GetTestField("Debuff Type", "toggle") ~= true end,
											set = function(info, value) SetTestField("Debuff Type", "toggle", false) end,
										},
										CheckMissing = {
											type = "toggle", order = 3, name = L["Missing"], 
											desc = L["If checked, true if player does not have a debuff of the specified type."],
											get = function(info) return GetTestField("Debuff Type", "toggle") == true end,
											set = function(info, value) SetTestField("Debuff Type", "toggle", true) end,
										},
									},
								},
							},
						},
						AllCooldownsGroup = {
							type = "group", order = 56, name = L["All Cooldowns"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("All Cooldowns", "enable") end,
											set = function(info, value) SetTestField("All Cooldowns", "enable", value) end,
										},
										IsUsable = {
											type = "toggle", order = 2, name = L["Is Usable"],
											desc = L["If checked, test if spells are usable (i.e., enough mana, reagents, etc.)."],
											get = function(info) return not GetTestField("All Cooldowns", "notUsable") end,
											set = function(info, value) SetTestField("All Cooldowns", "notUsable", not value) end,
										},
									},
								},
								SpellsGroup = {
									type = "group", order = 2, name = L["Spell List Entry"], inline = true,
									args = {
										SpellList = {
											type = "input", order = 1, name = L["Spells"], width = "full",
											desc = L["Enter comma-separated list of spells."],
											get = function(info) return GetTestFieldSpellList("All Cooldowns", "spells") end,
											set = function(info, value) SetTestFieldSpellList("All Cooldowns", "spells", value) end,
										},
									},
								},
								ToggleGroup = {
									type = "group", order = 10, name = L["Time Left"], inline = true,
									args = {
										TimeLeftSeconds = {
											type = "range", order = 5, name = L["Seconds"], min = 0, max = 60, step = 0.1,
											desc = L["Enter seconds for cooldown time left check."],
											get = function(info) local d = GetTestField("All Cooldowns", "timeLeft"); if d then return d else return 0 end end,
											set = function(info, value) local d = GetTestField("All Cooldowns", "timeLeft"); if not d then d = 0 end; SetTestField("All Cooldowns", "timeLeft", value) end,
										},
										TimeLeftMinMax = {
											type = "select", order = 6, name = L["Time Left"],
											get = function(info) if GetTestField("All Cooldowns", "toggle") == true then return 1 else return 2 end end,
											set = function(info, value) if value == 1 then SetTestField("All Cooldowns", "toggle", true) else SetTestField("All Cooldowns", "toggle", Off) end end,
											values = function(info)
												local d = GetTestField("All Cooldowns", "timeLeft")
												if not d then d = 0 end
												local ds = string.format("%0.1f", d)
												return { "Less Than " .. ds .. " Seconds", ds .. " Seconds Or More" }
											end,
											style = "dropdown",
										},
									},
								},
							},
						},
						SpellReadyGroup = {
							type = "group", order = 60, name = L["Spell Ready"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Spell Ready", "enable") end,
											set = function(info, value) SetTestField("Spell Ready", "enable", value) end,
										},
										IsUsable = {
											type = "toggle", order = 2, name = L["Is Usable"],
											desc = L["If checked, test if spell is usable (i.e., enough mana, reagents, etc.)."],
											get = function(info) return not GetTestField("Spell Ready", "notUsable") end,
											set = function(info, value) SetTestField("Spell Ready", "notUsable", not value) end,
										},
									},
								},
								SpellGroup = {
									type = "group", order = 5, name = L["Spell Entry"], inline = true,
									args = {
										SpellName = {
											type = "input", order = 1, name = L["Spell"], width = "full",
											desc = L["Enter spell to test if ready to be cast."],
											get = function(info) return GetTestField("Spell Ready", "spell") end,
											set = function(info, value) SetTestFieldString("Spell Ready", "spell", value) end,
										},
									},
								},
								RangeGroup = {
									type = "group", order = 10, name = L["Range"], inline = true,
									args = {
										CheckRange = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, also test if the target is in range of the spell."],
											get = function(info) return IsTestFieldOn("Spell Ready", "inRange") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Spell Ready", "inRange", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["Target In Range"],
											desc = L["If checked, target must be in range."],
											disabled = function(info) return IsTestFieldOff("Spell Ready", "inRange") end,
											get = function(info) return GetTestField("Spell Ready", "inRange") == true end,
											set = function(info, value) SetTestField("Spell Ready", "inRange", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["Target Out Of Range"],
											desc = L["If checked, target must be out of range."],
											disabled = function(info) return IsTestFieldOff("Spell Ready", "inRange") end,
											get = function(info) return GetTestField("Spell Ready", "inRange") == false end,
											set = function(info, value) SetTestField("Spell Ready", "inRange", false) end,
										},
									},
								},
								ChargesGroup = {
									type = "group", order = 30, name = L["Charges"], inline = true,
									args = {
										CheckCharges = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test the number of charges on the spell."],
											get = function(info) return IsTestFieldOn("Spell Ready", "checkCharges") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Spell Ready", "checkCharges", v) end,
										},
										ChargesValue = {
											type = "range", order = 10, name = L["Charges"], min = 1, max = 10, step = 1,
											desc = L["Enter value to compare with the number of charges."],
											disabled = function(info) return IsTestFieldOff("Spell Ready", "checkCharges") end,
											get = function(info) local d = GetTestField("Spell Ready", "charges"); if d then return d else return 1 end end,
											set = function(info, value) local d = GetTestField("Spell Ready", "charges"); if not d then d = 1 end; SetTestField("Spell Ready", "charges", value) end,
										},
										CountMinMax = {
											type = "select", order = 20, name = L["Comparison"],
											get = function(info) if GetTestField("Spell Ready", "checkCharges") == true then return 1 else return 2 end end,
											set = function(info, value) if value == 1 then SetTestField("Spell Ready", "checkCharges", true) else SetTestField("Spell Ready", "checkCharges", false) end end,
											disabled = function(info) return IsTestFieldOff("Spell Ready", "checkCharges") end,
											values = function(info)
												local d = GetTestField("Spell Ready", "charges")
												if not d then d = 1 end
												return { "Less Than " .. d, d .. " Or More" }
											end,
											style = "dropdown",
										},
									},
								},
							},
						},
						SpellCastingGroup = {
							type = "group", order = 65, name = L["Spell Casting"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Spell Casting", "enable") end,
											set = function(info, value) SetTestField("Spell Casting", "enable", value) end,
										},
									},
								},
								SpellGroup = {
									type = "group", order = 5, name = L["Spell Entry"], inline = true,
									args = {
										SpellName = {
											type = "input", order = 1, name = L["Spell"], width = "full",
											desc = L["Enter spell to test if being cast or channeled."],
											get = function(info) return GetTestField("Spell Casting", "spell") end,
											set = function(info, value) SetTestFieldString("Spell Casting", "spell", value) end,
										},
									},
								},
								UnitGroup = {
									type = "group", order = 20, name = L["Who Is Casting"], inline = true,
									args = {
										PlayerBuff = {
											type = "toggle", order = 10, name = L["Cast By Player"],
											desc = L["If checked, test player casting."],
											get = function(info) return GetTestField("Spell Casting", "unit") == "player" end,
											set = function(info, value) SetTestField("Spell Casting", "unit", "player")  end,
										},
										TargetBuff = {
											type = "toggle", order = 20, name = L["Cast By Target"],
											desc = L["If checked, test target casting."],
											get = function(info) return GetTestField("Spell Casting", "unit") == "target" end,
											set = function(info, value) SetTestField("Spell Casting", "unit", "target")  end,
										},
										FocusBuff = {
											type = "toggle", order = 30, name = L["Cast By Focus"],
											desc = L["If checked, test focus casting."],
											get = function(info) return GetTestField("Spell Casting", "unit") == "focus" end,
											set = function(info, value) SetTestField("Spell Casting", "unit", "focus")  end,
										},
									},
								},
							},
						},
						ItemReadyGroup = {
							type = "group", order = 70, name = L["Item Ready"],
							args = {
								EnableTestGroup = {
									type = "group", order = 1, name = L["Enable Test"], inline = true,
									args = {
										EnableTest = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, enable this test."],
											get = function(info) return GetTestField("Item Ready", "enable") end,
											set = function(info, value) SetTestField("Item Ready", "enable", value) end,
										},
									},
								},
								ItemGroup = {
									type = "group", order = 2, name = L["Item Entry"], inline = true,
									args = {
										ItemName = {
											type = "input", order = 1, name = L["Item"], width = "full",
											desc = L["Enter name or itemID of item to test. Item must be in the player's bags. Use generic cooldown names for Potions and Elixirs."],
											get = function(info) return GetTestField("Item Ready", "item") end,
											set = function(info, value) SetTestFieldString("Item Ready", "item", value) end,
										},
									},
								},
								ReadyOrNot = {
									type = "group", order = 10, name = L["Ready"], inline = true,
									args = {
										CheckReady = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test if the item is ready to use."],
											get = function(info) return IsTestFieldOn("Item Ready", "toggle") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Item Ready", "toggle", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["True"],
											desc = L["If checked, item must be ready."],
											disabled = function(info) return IsTestFieldOff("Item Ready", "toggle") end,
											get = function(info) return GetTestField("Item Ready", "toggle") == true end,
											set = function(info, value) SetTestField("Item Ready", "toggle", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["False"],
											desc = L["If checked, item must not be ready."],
											disabled = function(info) return IsTestFieldOff("Item Ready", "toggle") end,
											get = function(info) return GetTestField("Item Ready", "toggle") == false end,
											set = function(info, value) SetTestField("Item Ready", "toggle", false) end,
										},
									},
								},
								CountGroup = {
									type = "group", order = 20, name = L["Count"], inline = true,
									args = {
										CheckCount = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test item count."],
											get = function(info) return IsTestFieldOn("Item Ready", "checkCount") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Item Ready", "checkCount", v) end,
										},
										CountValue = {
											type = "range", order = 10, name = L["Count"], min = 1, max = 100, step = 1,
											desc = L["Enter value to compare with item count."],
											disabled = function(info) return IsTestFieldOff("Item Ready", "checkCount") end,
											get = function(info) local d = GetTestField("Item Ready", "count"); if d then return d else return 1 end end,
											set = function(info, value) local d = GetTestField("Item Ready", "count"); if not d then d = 1 end; SetTestField("Item Ready", "count", value) end,
										},
										CountMinMax = {
											type = "select", order = 20, name = L["Comparison"],
											get = function(info) if GetTestField("Item Ready", "checkCount") == true then return 1 else return 2 end end,
											set = function(info, value) if value == 1 then SetTestField("Item Ready", "checkCount", true) else SetTestField("Item Ready", "checkCount", false) end end,
											disabled = function(info) return IsTestFieldOff("Item Ready", "checkCount") end,
											values = function(info)
												local d = GetTestField("Item Ready", "count")
												if not d then d = 1 end
												return { "Less Than " .. d, d .. " Or More" }
											end,
											style = "dropdown",
										},
									},
								},
								ChargesGroup = {
									type = "group", order = 30, name = L["Charges"], inline = true,
									args = {
										CheckCharges = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, test the number of charges on the item(s)."],
											get = function(info) return IsTestFieldOn("Item Ready", "checkCharges") end,
											set = function(info, value) local v = Off if value then v = true end SetTestField("Item Ready", "checkCharges", v) end,
										},
										ChargesValue = {
											type = "range", order = 10, name = L["Charges"], min = 1, max = 100, step = 1,
											desc = L["Enter value to compare with the number of charges."],
											disabled = function(info) return IsTestFieldOff("Item Ready", "checkCharges") end,
											get = function(info) local d = GetTestField("Item Ready", "charges"); if d then return d else return 1 end end,
											set = function(info, value) local d = GetTestField("Item Ready", "charges"); if not d then d = 1 end; SetTestField("Item Ready", "charges", value) end,
										},
										CountMinMax = {
											type = "select", order = 20, name = L["Comparison"],
											get = function(info) if GetTestField("Item Ready", "checkCharges") == true then return 1 else return 2 end end,
											set = function(info, value) if value == 1 then SetTestField("Item Ready", "checkCharges", true) else SetTestField("Item Ready", "checkCharges", false) end end,
											disabled = function(info) return IsTestFieldOff("Item Ready", "checkCharges") end,
											values = function(info)
												local d = GetTestField("Item Ready", "charges")
												if not d then d = 1 end
												return { "Less Than " .. d, d .. " Or More" }
											end,
											style = "dropdown",
										},
									},
								},
							},
						},
						DependenciesGroup = {
							type = "group", order = 95, name = L["Result"],
							args = {
								SelectDependencies = {
									type = "group", order = 10, name = L["Dependencies"], inline = true,
									args = {
										intro = {
											type = "description", order = 1,
											name = L["Dependencies string"],
										},
										SelectCondition = {
											type = "select", order = 10, name = L["Condition"],
											get = function(info) return GetSelectedDependency() end,
											set = function(info, value) conditions.dependency = value end,
											values = function(info) return GetDependenciesList() end,
											style = "dropdown",
										},
										TrueConditionButton = {
											type = "execute", order = 20, name = L["True"], width = "half",
											desc = L["Condition is true only if the selected condition evaluates to true."],
											func = function(info) SetDependency(GetDependenciesList()[conditions.dependency], true) end,
										},
										FalseConditionButton = {
											type = "execute", order = 30, name = L["False"], width = "half",
											desc = L["Condition is true only if the selected condition evaluates to false."],
											func = function(info) SetDependency(GetDependenciesList()[conditions.dependency], false) end,
										},
										RequiredConditionButton = {
											type = "execute", order = 35, name = L["And/Or"], width = "half",
											hidden = function(info) return not CheckDependency(GetDependenciesList()[conditions.dependency]) end,
											desc = L["Toggle between logical \"And\" and \"Or\" for this dependecy."],
											func = function(info)
												local dep = GetDependenciesList()[conditions.dependency]
												local ctype = GetDependencyType(dep)
												SetDependencyType(dep, not ctype)
											end,
										},
										NoConditionButton = {
											type = "execute", order = 40, name = L["Delete"], width = "half",
											hidden = function(info) return not CheckDependency(GetDependenciesList()[conditions.dependency]) end,
											desc = L["Delete this condition from the dependencies list."],
											func = function(info) SetDependency(GetDependenciesList()[conditions.dependency], nil) end,
										},
									},
								},
								TestLogic = {
									type = "group", order = 20, name = L["Test Evaluation"], inline = true,
									args = {
										LogicType = {
											type = "toggle", order = 10, name = L["And/Or"],
											desc = L["If checked, evaluate all enabled tests with logical \"And\" (i.e., all tests must be true), othewise use logical \"Or\" (i.e., only one test must be true)."],
											get = function(info) return not GetConditionField("testLogic") end,
											set = function(info, value) local v = nil; if not value then v = true end SetConditionField("testLogic", v) end,
										},
										ToggleResult = {
											type = "toggle", order = 20, name = L["Toggle Result"],
											desc = L["If checked, the result for this condition, after evaluating all tests and checking dependencies, is toggled."],
											get = function(info) return GetConditionField("toggleResult") end,
											set = function(info, value) SetConditionField("toggleResult", value) end,
										},
									},
								},
								SetResult = {
									type = "group", order = 30, name = L["Set Result"], inline = true,
									args = {
										EnableSet = {
											type = "toggle", order = 1, name = L["Enable"],
											desc = L["If checked, the result for this condition is set to true or false (this feature is provided to help debug conditions)."],
											get = function(info) return IsOn(GetConditionField("setResult")) end,
											set = function(info, value) local v = Off if value then v = true end SetConditionField("setResult", v) end,
										},
										DoTrue = {
											type = "toggle", order = 2, name = L["True"],
											desc = L["If checked, result is set to true."],
											disabled = function(info) return IsOff(GetConditionField("setResult")) end,
											get = function(info) return GetConditionField("setResult") == true end,
											set = function(info, value) SetConditionField("setResult", true) end,
										},
										DoFalse = {
											type = "toggle", order = 3, name = L["False"],
											desc = L["If checked, result is set to false."],
											disabled = function(info) return IsOff(GetConditionField("setResult")) end,
											get = function(info) return GetConditionField("setResult") == false end,
											set = function(info, value) SetConditionField("setResult", false) end,
										},
									},
								},
							},
						},
					},
				},
			},
		},
		InCombat = {
			type = "group", order = 40, name = L["In-Combat Bar"], 
			disabled = function(info) return InMode() end,
			args = {
				intro = {
					type = "description", order = 1,
					name = L["In-combat string"],
				},
				EnableGroup = {
					type = "group", order = 10, name = L["Enable"], inline = true,
					args = {
						EnableOverlay = {
							type = "toggle", order = 10, name = L["Enable In-Combat Bar"], 
							desc = L["Enable in-combat buffs string"],
							get = function(info) return MOD.db.profile.InCombatBar.enable end,
							set = function(info, value) MOD.db.profile.InCombatBar.enable = value; MOD:ForceUpdate() end,
						},
						LockOverlay = {
							type = "toggle", order = 20, name = L["Lock Bar Layout"],
							desc = L["Lock in-combat string"],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.lock end,
							set = function(info, value) MOD.db.profile.InCombatBar.lock = value; MOD:ForceUpdate() end,
						},
						OOCOverlay = {
							type = "toggle", order = 30, name = L["Out Of Combat"],
							desc = L["If checked, also display buffs on the bar when out of combat."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.ooc end,
							set = function(info, value) MOD.db.profile.InCombatBar.ooc = value; MOD:ForceUpdate() end,
						},
						LinkOverlay = {
							type = "toggle", order = 40, name = L["Link Bar Layout"],
							desc = L["Link in-combat settings string"],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.link end,
							set = function(info, value) MOD.db.profile.InCombatBar.link = value; MOD:ForceUpdate() end,
						},
					},
				},
				BuffsGroup = {
					type = "group", order = 20, name = L["Buffs"], inline = true,
					args = {
						AddBuff = {
							type = "input", order = 10, name = L["Enter Buff"],
							desc = L["Enter in-combat buff string"],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return nil end,
							set = function(info, value)
								if not weaponBuffs[value] then value = ValidateSpellName(value) end
								if value then
									local found = false
									for k, v in pairs(MOD.db.profile.InCombatBuffs) do if v == value then found = true end end
									if not found then
										table.insert(MOD.db.profile.InCombatBuffs, value)
										table.sort(MOD.db.profile.InCombatBuffs)
									end
									for k, v in pairs(MOD.db.profile.InCombatBuffs) do if v == value then conditions.buff = k end end
								end
							end,
						},
						SelectBuff = {
							type = "select", order = 20, name = L["Buff List"],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info)
								if not conditions.buff and (#MOD.db.profile.InCombatBuffs > 0) then conditions.buff = 1 end
								return conditions.buff
							end,
							set = function(info, value) conditions.buff = value end,
							values = function(info) return MOD.db.profile.InCombatBuffs end,
							style = "dropdown",
						},
						DeleteBuff = {
							type = "execute", order = 30, name = L["Delete"], width = "half",
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							desc = L["Delete the selected buff from the in-combat list."],
							func = function(info)
								if conditions.buff then
									table.remove(MOD.db.profile.InCombatBuffs, conditions.buff)
									table.sort(MOD.db.profile.InCombatBuffs)
									conditions.buff = next(MOD.db.profile.InCombatBuffs)
								end
							end,
						},
						ResetBuff = {
							type = "execute", order = 35, name = L["Reset"], width = "half",
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							desc = L["Reset the in-combat buff list."],
							func = function(info) MOD.db.profile.InCombatBuffs = {}; conditions.buff = nil end,
						},
					},
				},
				LayoutGroup = {
					type = "group", order = 30, name = L["Layout"], inline = true,
					args = {
						Row = {
							type = "toggle", order = 10, name = L["Horizontal Bar"],
							desc = L["Configure as a horizontal bar of buff icons."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.layout end,
							set = function(info, value) MOD.db.profile.InCombatBar.layout = true end,
						},
						Column = {
							type = "toggle", order = 20, name = L["Vertical Bar"],
							desc = L["Configure as a vertical bar of buff icons."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return not MOD.db.profile.InCombatBar.layout end,
							set = function(info, value) MOD.db.profile.InCombatBar.layout = false end,
						},
						Direction = {
							type = "toggle", order = 30, name = L["Direction"],
							desc = L["If checked, grow up or to the right, otherwise grow down or to the left."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.direction end,
							set = function(info, value) MOD.db.profile.InCombatBar.direction = value end,
						},
						TooltipAnchor = {
							type = "select", order = 40, name = L["Tooltip Anchor"],
							desc = L["Tooltip anchor string"],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.anchorTips end,
							set = function(info, value) MOD.db.profile.InCombatBar.anchorTips = value end,
							values = function(info) return anchorTips end,
							style = "dropdown",
						},
						spacer = { type = "description", name = "", order = 50 },
						GridSize = {
							type = "range", order = 60, name = L["Icon Size"], min = 5, max = 50, step = 1,
							desc = L["Set size for the buff icons."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.size end,
							set = function(info, value) MOD.db.profile.InCombatBar.size = value end,
						},
						GridSpacing = {
							type = "range", order = 70, name = L["Spacing"], min = 1, max = 10, step = 1,
							desc = L["Set spacing between the buff icons."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.spacing end,
							set = function(info, value) MOD.db.profile.InCombatBar.spacing = value end,
						},
						GridScale = {
							type = "range", order = 80, name = L["Scale"], min = 0.1, max = 2, step = 0.05,
							desc = L["Set scale factor for the bar."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.scale end,
							set = function(info, value) MOD.db.profile.InCombatBar.scale = value end,
						},
						GridAlpha = {
							type = "range", order = 90, name = L["Opacity"], min = 0, max = 1, step = 0.05,
							desc = L["Set normal opacity for the bar."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.alpha end,
							set = function(info, value) MOD.db.profile.InCombatBar.alpha = value end,
						},
					},
				},
				AnchorGroup = {
					type = "group", order = 40, name = L["Attachment"], inline = true,
					args = {
						AnchorFrame = {
							type = "input", order = 10, name = L["Anchor Frame"],
							desc = L["Enter name of anchor frame to attach to (leave blank to enable manual positioning)."],
							validate = function(info, n) if not n or (n == "") or GetClickFrame(n) then return true end end,
							get = function(info) return MOD.db.profile.InCombatBar.anchorFrame end,
							set = function(info, value) if not value then value = "" end; MOD.db.profile.InCombatBar.anchorFrame = value; MOD:ForceUpdate() end,
						},
						AnchorPoint = {
							type = "select", order = 20, name = L["Anchor Point"],
							desc = L["Select point on anchor frame to attach to."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.anchorFrame end,
							get = function(info) return MOD.db.profile.InCombatBar.anchorPoint or "CENTER" end,
							set = function(info, value) MOD.db.profile.InCombatBar.anchorPoint = value; MOD:ForceUpdate() end,
							values = function(info) return anchorPoints end,
							style = "dropdown",
						},
						OffsetX = {
							type = "range", order = 30, name = L["Offset X"], min = -500, max = 500, step = 0.01,
							desc = L["Set horizontal offset from the selected bar group."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.anchorFrame end,
							get = function(info) return MOD.db.profile.InCombatBar.anchorX end,
							set = function(info, value) MOD.db.profile.InCombatBar.anchorX = value; MOD:ForceUpdate() end,
						},
						OffsetY = {
							type = "range", order = 40, name = L["Offset Y"], min = -500, max = 500, step = 0.01,
							desc = L["Set vertical offset from the selected bar group."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.anchorFrame end,
							get = function(info) return MOD.db.profile.InCombatBar.anchorY end,
							set = function(info, value) MOD.db.profile.InCombatBar.anchorY = value; MOD:ForceUpdate() end,
						},
					},
				},
				PositionGroup = {
					type = "group", order = 50, name = L["Display Position"], inline = true,
					disabled = function(info) return not MOD.db.profile.InCombatBar.enable or (MOD.db.profile.InCombatBar.anchorFrame ~= "") end,
					args = {
						OffsetX = {
							type = "range", order = 10, name = L["Horizontal"], min = 0, max = 100, step = 0.01,
							desc = L["Set horizontal position as percentage of overall width (cannot move beyond edge of display)."],
							get = function(info) return MOD.db.profile.InCombatBar.offsetX * 100 end,
							set = function(info, value) MOD.db.profile.InCombatBar.offsetX = value / 100; MOD:ForceUpdate() end,
						},
						OffsetY = {
							type = "range", order = 20, name = L["Vertical"], min = 0, max = 100, step = 0.01,
							desc = L["Set vertical position as percentage of overall height (cannot move beyond edge of display)."],
							get = function(info) return MOD.db.profile.InCombatBar.offsetY * 100 end,
							set = function(info, value) MOD.db.profile.InCombatBar.offsetY = value / 100; MOD:ForceUpdate() end,
						},
					},
				},
				EffectsGroup = {
					type = "group", order = 60, name = L["Special Effects"],  inline = true,
					args = {
						PulseStart = {
							type = "toggle", order = 10, name = L["Pulse At Start"],
							desc = L["Enable icon pulse when buff icon is started."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.pulseStart end,
							set = function(info, value) MOD.db.profile.InCombatBar.pulseStart = value; MOD:ForceUpdate() end,
						},
						PulseEnd = {
							type = "toggle", order = 15, name = L["Pulse When Expiring"],
							desc = L["Enable icon pulse when buff icon is expiring."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.pulseEnd end,
							set = function(info, value) MOD.db.profile.InCombatBar.pulseEnd = value; MOD:ForceUpdate() end,
						},
						FlashExpiring = {
							type = "toggle", order = 20, name = L["Flash When Expiring"],
							desc = L["Enable flashing of expiring buff icons."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.flashExpiring end,
							set = function(info, value) MOD.db.profile.InCombatBar.flashExpiring = value; MOD:ForceUpdate() end,
						},
						FlashTime = {
							type = "range", order = 25, name = L["Flash Time"], min = 0, max = 300, step = 1,
							desc = L["Set number of seconds before expiration that buff icon should start flashing."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.flashExpiring or not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.flashTime end,
							set = function(info, value) MOD.db.profile.InCombatBar.flashTime = value; MOD:ForceUpdate() end,
						},
						Mouseover = {
							type = "toggle", order = 30, name = L["Fade Unless Mouseover"],
							desc = L["Enable fading of buff icons unless mouseover is detected."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.mouseoverDetect end,
							set = function(info, value) MOD.db.profile.InCombatBar.mouseoverDetect = value; MOD:ForceUpdate() end,
						},
						MouseoverAlpha = {
							type = "range", order = 35, name = L["Fade Opacity"], min = 0, max = 1, step = 0.05,
							desc = L["Set fade opacity for buff icon when mouseover is not detected."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.mouseoverDetect or not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.mouseoverAlpha or 0.5 end,
							set = function(info, value) MOD.db.profile.InCombatBar.mouseoverAlpha = value; MOD:ForceUpdate() end,
						},
						HideBorder = {
							type = "toggle", order = 40, name = L["Hide Custom Border"],
							desc = L["By default, buff icons are displayed with a custom border. If this option is checked then custom borders are hidden."],
							disabled = function(info) return not MOD.db.profile.InCombatBar.enable end,
							get = function(info) return MOD.db.profile.InCombatBar.noBorder end,
							set = function(info, value) MOD.db.profile.InCombatBar.noBorder = value; MOD:ForceUpdate() end,
						},
					},
				},
			},
		},
		Highlights = {
			type = "group", order = 50, name = L["Highlights"], 
			hidden = function(info) return not MOD.highlights end, -- must have compatible action bar mod
			disabled = function(info) return InMode() end, -- must have compatible action bar mod
			args = {
				intro = {
					type = "description", order = 1,
					name = L["Highlights string"],
				},
				EnableGroup = {
					type = "group", order = 10, name = L["Enable"], inline = true,
					args = {
						EnableGroup = {
							type = "toggle", order = 10, name = L["Enable Highlights"],
							desc = L["If checked, enable Raven's support for button highlights and cooldown counts."],
							get = function(info) return MOD.db.global.HighlightsEnabled end,
							set = function(info, value) MOD.db.global.HighlightsEnabled = value end,
						},
						ButtonFacade = {
							type = "toggle", order = 20, name = L["Use Masque"],
							desc = L["Enable setting highlights through Masque if it is loaded. This is not ideal for every skin which is why it can be disabled. Try both enabled and disabled settings and see which works best."],
							disabled = function(info) return not MOD.db.global.HighlightsEnabled or not MOD.MSQ end,
							get = function(info) return MOD.db.global.ButtonFacade end,
							set = function(info, value) MOD.db.global.ButtonFacade = value end,
						},
					},
				},
				PlayerGroup = {
					type = "group", order = 20, name = L["Player"], inline = true, 
					disabled = function(info) return not MOD.db.global.HighlightsEnabled end,
					args = {
						PlayerBuffHighlightsEnable = {
							type = "toggle", order = 4, name = L["Highlight Buffs"],
							desc = L["Enable player buff highlights on buttons."],
							get = function(info) return MOD.db.global.PlayerBuffHighlights end,
							set = function(info, value) MOD.db.global.PlayerBuffHighlights = value end,
						},
						PlayerBuffColor = {
							type = "color", order = 5, name = L["Buff Color"], hasAlpha = false,
							desc = L["Set player buff highlight color."],
							get = function(info)
								local t = MOD.db.global.PlayerBuffColor
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.PlayerBuffColor
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						PlayerDebuffHighlightsEnable = {
							type = "toggle", order = 23, name = L["Highlight Debuffs"],
							desc = L["Enable player debuff highlights on buttons."],
							get = function(info) return MOD.db.global.PlayerDebuffHighlights end,
							set = function(info, value) MOD.db.global.PlayerDebuffHighlights = value end,
						},
						PlayerDebuffColor = {
							type = "color", order = 24, name = L["Debuff Color"], hasAlpha = false,
							desc = L["Set player debuff highlight color."],
							get = function(info)
								local t = MOD.db.global.PlayerDebuffColor
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.PlayerDebuffColor
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
					},
				},
				TargetGroup = {
					type = "group", order = 30, name = L["Target"], inline = true,
					disabled = function(info) return not MOD.db.global.HighlightsEnabled end,
					args = {
						TargetBuffHighlightsEnable = {
							type = "toggle", order = 3, name = L["Highlight Buffs"],
							desc = L["Enable target buff highlights on buttons."],
							get = function(info) return MOD.db.global.TargetBuffHighlights end,
							set = function(info, value) MOD.db.global.TargetBuffHighlights = value end,
						},
						TargetBuffColor = {
							type = "color", order = 4, name = L["Buff Color"], hasAlpha = false,
							desc = L["Set target buff highlight color."],
							get = function(info)
								local t = MOD.db.global.TargetBuffColor
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.TargetBuffColor
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						TargetDebuffHighlightsEnable = {
							type = "toggle", order = 23, name = L["Highlight Debuffs"],
							desc = L["Enable target debuff highlights on buttons."],
							get = function(info) return MOD.db.global.TargetDebuffHighlights end,
							set = function(info, value) MOD.db.global.TargetDebuffHighlights = value end,
						},
						TargetDebuffColor = {
							type = "color", order = 24, name = L["Debuff Color"], hasAlpha = false,
							desc = L["Set target debuff highlight color."],
							get = function(info)
								local t = MOD.db.global.TargetDebuffColor
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.TargetDebuffColor
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
					},
				},
				FocusGroup = {
					type = "group", order = 40, name = L["Focus"], inline = true,
					disabled = function(info) return not MOD.db.global.HighlightsEnabled end,
					args = {
						FocusBuffHighlightsEnable = {
							type = "toggle", order = 3, name = L["Highlight Buffs"],
							desc = L["Enable focus buff highlights on buttons."],
							get = function(info) return MOD.db.global.FocusBuffHighlights end,
							set = function(info, value) MOD.db.global.FocusBuffHighlights = value end,
						},
						FocusBuffColor = {
							type = "color", order = 4, name = L["Buff Color"], hasAlpha = false,
							desc = L["Set focus buff highlight color."],
							get = function(info)
								local t = MOD.db.global.FocusBuffColor
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.FocusBuffColor
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
						FocusDebuffHighlightsEnable = {
							type = "toggle", order = 23, name = L["Highlight Debuffs"],
							desc = L["Enable focus debuff highlights on buttons."],
							get = function(info) return MOD.db.global.FocusDebuffHighlights end,
							set = function(info, value) MOD.db.global.FocusDebuffHighlights = value end,
						},
						FocusDebuffColor = {
							type = "color", order = 24, name = L["Debuff Color"], hasAlpha = false,
							desc = L["Set focus debuff highlight color."],
							get = function(info)
								local t = MOD.db.global.FocusDebuffColor
								return t.r, t.g, t.b, t.a
							end,
							set = function(info, r, g, b, a)
								local t = MOD.db.global.FocusDebuffColor
								t.r, t.g, t.b, t.a = r, g, b, a
							end,
						},
					},
				},
				Flashing = {
					type = "group", order = 80, name = L["Flashing"],  inline = true,
					disabled = function(info) return not MOD.db.global.HighlightsEnabled end,
					args = {
						FlashExpiring = {
							type = "toggle", order = 2, name = L["Flash When Expiring"],
							desc = L["Enable highlight flashing for expiring buffs and debuffs."],
							get = function(info) return MOD.db.global.FlashExpiring end,
							set = function(info, value) MOD.db.global.FlashExpiring = value end,
						},
						FlashTime = {
							type = "range", order = 3, name = L["Seconds"], min = 1, max = 30, step = 1,
							desc = L["Set number of seconds to flash before buffs and debuffs expire."],
							disabled = function(info) return not MOD.db.global.FlashExpiring end,
							get = function(info) return MOD.db.global.FlashTime end,
							set = function(info, value) MOD.db.global.FlashTime = value end,
						},
					},
				},
				Cooldowns = {
					type = "group", order = 90, name = L["Cooldowns"],  inline = true,
					disabled = function(info) return not MOD.db.global.HighlightsEnabled end,
					args = {
						CooldownText = {
							type = "toggle", order = 10, name = L["Cooldown Time"],
							desc = L["Show cooldown time remaining on buttons."],
							get = function(info) return MOD.db.global.CooldownText end,
							set = function(info, value) MOD.db.global.CooldownText = value end,
						},
						CooldownFontSize = {
							type = "range", order = 20, name = L["Font Size"], min = 5, max = 50, step = 1,
							desc = L["Set font size for cooldown time text overlay."],
							disabled = function(info) return not MOD.db.global.CooldownText end,
							get = function(info) return MOD.db.global.CooldownFsize end,
							set = function(info, value) MOD.db.global.CooldownFsize = value end,
						},
						CooldownFont = {
							type = "select", order = 30, name = L["Font"], 
							desc = L["Select font for cooldown time text overlay."],
							disabled = function(info) return not MOD.db.global.CooldownText end,
							dialogControl = 'LSM30_Font',
							values = AceGUIWidgetLSMlists.font,
							get = function(info) return MOD.db.global.CooldownFont end,
							set = function(info, value) MOD.db.global.CooldownFont = value end,
						},
						TimeFormatGroup = {
							type = "group", order = 35, name = L["Time Format"],  inline = true,
							args = {
								TimeFormat = {
									type = "select", order = 10, name = L["Options"], width = "double",
									desc = L["Cooldown format string"],
									get = function(info) return MOD.db.global.CooldownTimeFormat end,
									set = function(info, value) MOD.db.global.CooldownTimeFormat = value end,
									values = function(info)
										local s = MOD.db.global.CooldownTimeSpaces
										local c = MOD.db.global.CooldownTimeCase
										return GetTimeFormatList(s, c)
									end,
									style = "dropdown",
								},
								Space1 = { type = "description", name = "", order = 15, width = "half" },
								Spaces = {
									type = "toggle", order = 20, name = L["Spaces"], width = "half",
									desc = L["Include spaces between values in time format."],
									get = function(info) return MOD.db.global.CooldownTimeSpaces end,
									set = function(info, value) MOD.db.global.CooldownTimeSpaces = value end,
								},
								Capitals = {
									type = "toggle", order = 30, name = L["Uppercase"],
									desc = L["If checked, use uppercase H, M and S in time format, otherwise use lowercase."],
									get = function(info) return MOD.db.global.CooldownTimeCase end,
									set = function(info, value) MOD.db.global.CooldownTimeCase = value end,
								},
							},
						},
						CooldownAlignment = {
							type = "group", order = 40, name = L["Alignment"], inline = true,
							args = {
								VText = { type = "description", name = L["Vertical:"], order = 1, width = "half" },
								VLeftAlign = {
									type = "toggle", order = 10, name = L["Top"],
									desc = L["If checked, vertically align cooldown text to top."],
									get = function(info) return MOD.db.global.CooldownVertical == "Top" end,
									set = function(info, value) MOD.db.global.CooldownVertical = "Top" end,
								},
								VCenterAlign = {
									type = "toggle", order = 20, name = L["Middle"],
									desc = L["If checked, vertically align cooldown text in middle."],
									get = function(info) return not MOD.db.global.CooldownVertical end,
									set = function(info, value) MOD.db.global.CooldownVertical = false end,
								},
								VRightAlign = {
									type = "toggle", order = 30, name = L["Bottom"],
									desc = L["If checked, vertically align cooldown text to bottom."],
									get = function(info) return MOD.db.global.CooldownVertical == "Bottom" end,
									set = function(info, value) MOD.db.global.CooldownVertical = "Bottom" end,
								},
								spacer = { type = "description", name = "", order = 40 },
								HText = { type = "description", name = L["Horizontal:"], order = 41, width = "half" },
								HLeftAlign = {
									type = "toggle", order = 50, name = L["Left"],
									desc = L["If checked, horizontally align cooldown text to left."],
									get = function(info) return MOD.db.global.CooldownHorizontal == "Left" end,
									set = function(info, value) MOD.db.global.CooldownHorizontal = "Left" end,
								},
								HCenterAlign = {
									type = "toggle", order = 60, name = L["Center"],
									desc = L["If checked, horizontally align cooldown text in center."],
									get = function(info) return not MOD.db.global.CooldownHorizontal end,
									set = function(info, value) MOD.db.global.CooldownHorizontal = false end,
								},
								HRightAlign = {
									type = "toggle", order = 70, name = L["Right"],
									desc = L["If checked, horizontally align cooldown text to right."],
									get = function(info) return MOD.db.global.CooldownHorizontal == "Right" end,
									set = function(info, value) MOD.db.global.CooldownHorizontal = "Right" end,
								},
							},
						},
					},
				},
			},
		},
	},
}

-- This table gets inserted into the bar settings tab for each active bar as the args field for a group.
-- Bar fields: name, enableBar, barLabel, barType, barData, monitor, isMine, color
MOD.barOptions = {
	SummaryGroup = {
		type = "group", order = 1, name = L["Bar Information"], inline = true,
		hidden = function(info) return NoBar() end,
		args = {
			BarDescription = {
				type = "description", order = 1, name = function(info) return GetBarDescription(info) end,
			},
		},
	},
	SortingGroup = {
		type = "group", order = 5, name = L["Custom Sort Order"], inline = true,
		hidden = function(info) return NoBar() or GetBarGroupField("sor") ~= "X" end,
		args = {
			PromoteBar = {
				type = "execute", order = 60, name = L["Move Up"],
				desc = L["Move the bar up, overriding sort order."],
				func = function(info) MoveBarInList(info, "up") end,
			},
			DemoteBar = {
				type = "execute", order = 70, name = L["Move Down"],
				desc = L["Move the bar down, overriding sort order."],
				func = function(info) MoveBarInList(info, "down") end,
			},
		},
	},
	OptionsGroup = {
		type = "group", order = 10, name = L["Settings"], inline = true,
		hidden = function(info) return NoBar() end,
		args = {
			EnableBar = {
				type = "toggle", order = 10, name = L["Enable"], width = "half",
				desc = L["If checked, enable showing the bar."],
				get = function(info) return GetBarField(info, "enableBar") end,
				set = function(info, value) SetBarField(info, "enableBar", value); MOD:UpdateAllBarGroups() end,
			},
			BarLabel = {
				type = "input", order = 20, name = L["Label"],
				desc = L["Enter label text for the bar."],
				get = function(info) return GetBarField(info, "barLabel") end,
				set = function(info, value) SetBarLabel(info, value, not GetBarField(info, "labelLink")); MOD:UpdateAllBarGroups() end,
			},
			LabelLink = {
				type = "toggle", order = 30, name = L["Link"], width = "half",
				desc = L["If checked, label is linked to the associated spell and changing it here will change it for all bars linked to the same spell."],
				hidden = function(info) return GetBarField(info, "barType") == "Notification" end,
				get = function(info) return not GetBarField(info, "labelLink") end,
				set = function(info, value)
					if value then
						local bar = GetBarEntry(info)
						local label = MOD:GetLabel(bar.action)
						value = SetBarLabel(info, label, false) -- no need to update the cached label, also don't link if fails validation test
					end
					SetBarField(info, "labelLink", not value)
					MOD:UpdateAllBarGroups()
				end,
			},
			LabelNumber = {
				type = "toggle", order = 40, name = L["Add Tooltip Number"],
				desc = L["If checked, the first number found in the tooltip is added to the label."],
				hidden = function(info) return GetBarField(info, "barType") == "Notification" end,
				get = function(info) return GetBarField(info, "labelNumber") end,
				set = function(info, value) SetBarField(info, "labelNumber", value); MOD:UpdateAllBarGroups() end,
			},
			spacer = { type = "description", name = "", order = 50, hidden = function(info) return GetBarField(info, "barType") ~= "Cooldown" end, },
			EnableCooldownReadyBar = {
				type = "toggle", order = 60, name = L["Show When Ready"],
				desc = L["If checked, show ready bar when action is not on cooldown."],
				hidden = function(info) return GetBarField(info, "barType") ~= "Cooldown" end,
				get = function(info) return GetBarField(info, "enableReady") end,
				set = function(info, value) SetBarField(info, "enableReady", value); MOD:UpdateAllBarGroups() end,
			},
			EnableAuraReadyBar = {
				type = "toggle", order = 65, name = L["Show Not Active"],
				desc = L["If checked, show ready bar when action is not active."],
				hidden = function(info) local bt = GetBarField(info, "barType"); return (bt ~= "Buff") and (bt ~= "Debuff") end,
				get = function(info) return GetBarField(info, "enableReady") end,
				set = function(info, value) SetBarField(info, "enableReady", value); MOD:UpdateAllBarGroups() end,
			},
			EnableUsableTest = {
				type = "toggle", order = 70, name = L["Usable"], width = "half",
				desc = L["If checked, show ready bar only if spell is usable (i.e., enough mana, reagents, etc.)."],
				hidden = function(info) return GetBarField(info, "barType") ~= "Cooldown" end,
				disabled = function(info) return not GetBarField(info, "enableReady") end,
				get = function(info) return not GetBarField(info, "readyNotUsable") end,
				set = function(info, value) SetBarField(info, "readyNotUsable", not value); MOD:UpdateAllBarGroups() end,
			},
			ShowTime = {
				type = "range", order = 75, name = L["Show Time"], min = 0, max = 60, step = 1,
				desc = L["Set number of seconds to show the ready bar (0 for unlimited time)."],
				hidden = function(info) return GetBarField(info, "barType") == "Notification" end,
				disabled = function(info) return not GetBarField(info, "enableReady") end,
				get = function(info) return GetBarField(info, "readyTime") or 0 end,
				set = function(info, value) SetBarField(info, "readyTime", value) end,
			},
		},
	},
	ColorGroup = {
		type = "group", order = 20, name = L["Color and Icon"], inline = true,
		hidden = function(info) return NoBar() end,
		args = {
			UseColor = {
				type = "toggle", order = 10, name = L["Use Spell Color"], 
				desc = L["If checked, use color from associated spell."],
				hidden = function(info) return GetBarField(info, "barType") ~= "Notification" end,
				disabled = function(info)
					local bar = GetBarEntry(info)
					return bar.barType == "Notification" and not MOD:GetAssociatedSpellForBar(bar)
				end,
				get = function(info) return not GetBarField(info, "notColor") end,
				set = function(info, value)
					SetBarField(info, "notColor", not value)
					if value then SetBarField(info, "color", nil) end
					MOD:UpdateAllBarGroups()
				end,
			},
			UseIcon = {
				type = "toggle", order = 10, name = L["Use Spell Icon"], 
				desc = L["If checked, use icon from associated spell."],
				hidden = function(info) return GetBarField(info, "barType") ~= "Notification" end,
				disabled = function(info)
					local bar = GetBarEntry(info)
					return bar.barType == "Notification" and not MOD:GetAssociatedSpellForBar(bar)
				end,
				get = function(info) return not GetBarField(info, "notIcon") end,
				set = function(info, value) SetBarField(info, "notIcon", not value); MOD:UpdateAllBarGroups() end,
			},
			spacer = { type = "description", name = "", order = 20, hidden = function(info) return GetBarField(info, "barType") ~= "Notification" end, },
			StandardColors = {
				type = "select", order = 30, name = L["Color"], width = "half",
				desc = L["Select a standard color or click to set a custom color."],
				get = function(info) return nil end,
				set = function(info, value)
					local r, g, b, a = GetStandardColor(value)
					local bar = GetBarEntry(info)
					MOD:SetSpellColorForBar(bar, r, g, b, a)
					MOD:UpdateAllBarGroups()
				end,
				values = function(info) return GetStandardColorList() end,
				style = "dropdown",
			},
			BarColor = {
				type = "color", order = 40, name = "", hasAlpha = false, width = "half",
				get = function(info)
					local bar = GetBarEntry(info)
					local c = MOD:GetSpellColorForBar(bar)
					if not c then return 1, 1, 1, 1 end -- better than nothing
					return c.r, c.g, c.b, c.a
				end,
				set = function(info, r, g, b, a)
					local bar = GetBarEntry(info)
					MOD:SetSpellColorForBar(bar, r, g, b, a)
					MOD:UpdateAllBarGroups()
				end,
			},
			ColorLink = {
				type = "toggle", order = 50, name = L["Color Link"],
				desc = L["If checked, the color is linked to the associated spell and changing it here will change it for all bars linked to the same spell."],
				disabled = function(info)
					local bar = GetBarEntry(info)
					return bar.barType == "Notification" and not MOD:GetAssociatedSpellForBar(bar)
				end,
				get = function(info) return not GetBarField(info, "colorLink") end,
				set = function(info, value)
					local bar = GetBarEntry(info)
					bar.colorLink = not value
					MOD:LinkSpellColorForBar(bar)
					MOD:UpdateAllBarGroups()
				end,
			},
			BarIcon = {
				type = "description", order = 60, name = "", width = "half", 
				hidden = function(info) return not GetBarIcon(info) end,
				image = function(info) return GetBarIcon(info) end,
				imageWidth = 24, imageHeight = 24,
			},
		},
	},
	EffectsGroup = {
		type = "group", order = 30, name = L["Special Effects"],  inline = true,
		hidden = function(info) return NoBar() end,
		args = {
			PulseStart = {
				type = "toggle", order = 10, name = L["Pulse At Start"],
				desc = L["Enable icon pulse when bar is started."],
				get = function(info) return GetBarField(info, "pulseStart") end,
				set = function(info, value) SetBarField(info, "pulseStart", value) end,
			},
			PulseEnd = {
				type = "toggle", order = 15, name = L["Pulse When Expiring"],
				desc = L["Enable icon pulse when bar is expiring."],
				get = function(info) return GetBarField(info, "pulseEnd") end,
				set = function(info, value) SetBarField(info, "pulseEnd", value) end,
			},
			space1 = { type = "description", name = "", order = 20 },
			FlashExpiring = {
				type = "toggle", order = 25, name = L["Flash When Expiring"],
				desc = L["Enable flashing of expiring bars."],
				get = function(info) return GetBarField(info, "flashExpiring") end,
				set = function(info, value) SetBarField(info, "flashExpiring", value) end,
			},
			FlashTime = {
				type = "range", order = 30, name = L["Flash Time"], min = 1, max = 300, step = 1,
				desc = L["Set number of seconds before expiration that bar should start flashing."],
				disabled = function(info) return not GetBarField(info, "flashExpiring") end,
				get = function(info) return GetBarField(info, "flashTime") end,
				set = function(info, value) SetBarField(info, "flashTime", value) end,
			},
			space2 = { type = "description", name = "", order = 35 },
			HideEnable = {
				type = "toggle", order = 36, name = L["Hide After Start"],
				desc = L["Enable hide after start for timer bars (does not hide bars with unlimited duration)."],
				get = function(info) return GetBarField(info, "hide") end,
				set = function(info, value) SetBarField(info, "hide", value) end,
			},
			FadeEnable = {
				type = "toggle", order = 40, name = L["Fade After Start"],
				desc = L["Enable fade after start (i.e., switch to fade opacity after a delay)."],
				disabled = function(info) return GetBarField(info, "hide") end, -- preference to hide
				get = function(info) return GetBarField(info, "fade") end,
				set = function(info, value) SetBarField(info, "fade", value) end,
			},
			GhostEnable = {
				type = "toggle", order = 41, name = L["Ghost When Expiring"],
				desc = L["Enable ghost bar/icon (i.e., continue to show for delay period after would normally disappear)."],
				disabled = function(info) return GetBarGroupField("hide") end,
				get = function(info) return GetBarField(info, "ghost") end,
				set = function(info, value) SetBarField(info, "ghost", value) end,
			},
			spacer2a = { type = "description", name = "", order = 44 },
			FadeDelay = {
				type = "range", order = 45, name = L["Delay"], min = 0, max = 300, step = 1,
				desc = L["Set number of seconds before bar (or ghost) will hide or fade."],
				disabled = function(info) return not GetBarField(info, "fade") and not GetBarField(info, "hide") and not GetBarField(info, "ghost") end,
				get = function(info) return GetBarField(info, "delayTime") or 5 end,
				set = function(info, value) SetBarField(info, "delayTime", value) end,
			},
			spacer2b = { type = "description", name = "", order = 50 },
			NormalAlpha = {
				type = "range", order = 55, name = L["Normal Opacity"], min = 0, max = 1, step = 0.05,
				desc = L["Set normal opacity for this bar."],
				get = function(info) return GetBarField(info, "normalAlpha") or 1 end,
				set = function(info, value) SetBarField(info, "normalAlpha", value) end,
			},
			FadeAlpha = {
				type = "range", order = 58, name = L["Fade Opacity"], min = 0, max = 1, step = 0.05,
				desc = L["Set fade opacity for this bar."],
				disabled = function(info) return (GetBarField(info, "hide") or not GetBarField(info, "fade")) and IsOff(GetBarField(info, "fadeBar")) end,
				get = function(info) return GetBarField(info, "fadeAlpha") or 1 end,
				set = function(info, value) SetBarField(info, "fadeAlpha", value) end,
			},
			ReadyAlpha = {
				type = "range", order = 59, name = L["Ready Opacity"], min = 0, max = 1, step = 0.05,
				desc = L["Set opacity for ready bar."],
				disabled = function(info) return not GetBarField(info, "enableReady") end,
				get = function(info) return GetBarField(info, "readyAlpha") or 1 end,
				set = function(info, value) SetBarField(info, "readyAlpha", value) end,
			},
			space3 = { type = "description", name = "", order = 60 },
			SpellStartSound = {
				type = "toggle", order = 61, name = L["Start Spell Sound"],
				desc = L["Play associated spell sound, if any, when bar starts (spell sounds are set up on Spells tab)."],
				get = function(info) return GetBarField(info, "soundSpellStart") end,
				set = function(info, value) SetBarField(info, "soundSpellStart", value) end,
			},
			AltStartSound = {
				type = "select", order = 62, name = L["Alternative Start Sound"], 
				desc = L["Select sound to play when bar starts and there is no associated spell sound (or start spell sounds are not enabled)."],
				dialogControl = 'LSM30_Sound',
				values = AceGUIWidgetLSMlists.sound,
				get = function(info) return GetBarField(info, "soundAltStart") or "None" end,
				set = function(info, value) SetBarField(info, "soundAltStart", value) end,
			},
			space3a = { type = "description", name = "", order = 63 },
			ReplayEnable = {
				type = "toggle", order = 64, name = L["Replay Start Sound"],
				desc = L["Enable replay of start sound (after a specified amount of time) while bar is active."],
				get = function(info) return GetBarField(info, "replay") end,
				set = function(info, value) SetBarField(info, "replay", value) end,
			},
			ReplayDelay = {
				type = "range", order = 65, name = L["Replay Time"], min = 1, max = 60, step = 1,
				desc = L["Set number of seconds between replays of start sound."],
				get = function(info) return GetBarField(info, "replayTime") or 5 end,
				set = function(info, value) SetBarField(info, "replayTime", value) end,
			},
			space3b = { type = "description", name = "", order = 66 },
			SpellEndSound = {
				type = "toggle", order = 67, name = L["Finish Spell Sound"],
				desc = L["Play associated spell sound, if any, when bar finishes (spell sounds are set up on Spells tab)."],
				get = function(info) return GetBarField(info, "soundSpellEnd") end,
				set = function(info, value) SetBarField(info, "soundSpellEnd", value) end,
			},
			AltEndSound = {
				type = "select", order = 68, name = L["Alternative Finish Sound"], 
				desc = L["Select sound to play when bar finishes and there is no associated spell sound (or finish spell sounds are not enabled)."],
				dialogControl = 'LSM30_Sound',
				values = AceGUIWidgetLSMlists.sound,
				get = function(info) return GetBarField(info, "soundAltEnd") or "None" end,
				set = function(info, value) SetBarField(info, "soundAltEnd", value) end,
			},
			space3c = { type = "description", name = "", order = 70 },
			SpellExpireSound = {
				type = "toggle", order = 71, name = L["Expire Spell Sound"],
				desc = L["Play associated spell sound, if any, when bar is about to expire (spell sounds are set up on Spells tab)."],
				get = function(info) return GetBarField(info, "soundSpellExpire") end,
				set = function(info, value) SetBarField(info, "soundSpellExpire", value) end,
			},
			AltExpireSound = {
				type = "select", order = 73, name = L["Alternative Expire Sound"], 
				desc = L["Select sound to play when bar is about to expire and there is no associated spell sound (or expire spell sounds are not enabled)."],
				dialogControl = 'LSM30_Sound',
				values = AceGUIWidgetLSMlists.sound,
				get = function(info) return GetBarField(info, "soundAltExpire") or "None" end,
				set = function(info, value) SetBarField(info, "soundAltExpire", value) end,
			},
			space3d = { type = "description", name = "", order = 74 },
			ExpireTime = {
				type = "range", order = 75, name = L["Expire Time"], min = 0, max = 300, step = 1,
				desc = L["Set number of seconds before expiration that bar should change color and/or play expire sound."],
				disabled = function(info) return not GetBarField(info, "colorExpiring") and not GetBarField(info, "expireMSBT")
					and not GetBarField(info, "soundSpellExpire") and not (GetBarField(info, "soundAltExpire")
					and GetBarField(info, "soundAltExpire") ~= "None") end,
				get = function(info) return GetBarField(info, "expireTime") or 5 end,
				set = function(info, value) SetBarField(info, "expireTime", value) end,
			},
			MinimumTime = {
				type = "range", order = 76, name = L["Minimum Duration"], min = 0, max = 60, step = 1,
				desc = L["Set minimum duration in minutes required to trigger expiration options."],
				disabled = function(info) return not GetBarField(info, "colorExpiring") and not GetBarField(info, "expireMSBT")
					and not GetBarField(info, "soundSpellExpire") and not (GetBarField(info, "soundAltExpire")
					and GetBarField(info, "soundAltExpire") ~= "None") end,
				get = function(info) return GetBarField(info, "expireMinimum") or 0 end,
				set = function(info, value) if value == 0 then value = nil end SetBarField(info, "expireMinimum", value) end,
			},
			space3e = { type = "description", name = "", order = 77 },
			ColorExpiring = {
				type = "toggle", order = 78, name = L["Color When Expiring"],
				desc = L["Enable color changes for expiring bars (and, for icon configurations, make background visible if opacity is set to invisible to enable bar as highlight)."],
				get = function(info) return GetBarField(info, "colorExpiring") end,
				set = function(info, value) SetBarField(info, "colorExpiring", value) end,
			},
			BarExpireColor = {
				type = "color", order = 79, name = L["Bar"], hasAlpha = true, width = "half",
				desc = L["Set bar color for when about to expire (set invisible opacity to disable color change)."],
				disabled = function(info) return not GetBarField(info, "colorExpiring") end,
				get = function(info)
					local t = GetBarField(info, "expireColor")
					if t then return t.r, t.g, t.b, t.a else return 1, 0, 0, 1 end
				end,
				set = function(info, r, g, b, a)
					local t = GetBarField(info, "expireColor")
					if t then t.r = r; t.g = g; t.b = b; t.a = a else
						t = { r = r, g = g, b = b, a = a }; SetBarField(info, "expireColor", t) end
					MOD:UpdateAllBarGroups()
				end,
			},
			LabelTextColor = {
				type = "color", order = 80, name = L["Label"], hasAlpha = true, width = "half",
				desc = L["Set label color for when bar is about to expire (set invisible opacity to disable color change)."],
				disabled = function(info) return not GetBarField(info, "colorExpiring") end,
				get = function(info)
					local t = GetBarField(info, "expireLabelColor")
					if t then return t.r, t.g, t.b, t.a else return 1, 0, 0, 0 end
				end,
				set = function(info, r, g, b, a)
					local t = GetBarField(info, "expireLabelColor")
					if t then t.r = r; t.g = g; t.b = b; t.a = a else
						t = { r = r, g = g, b = b, a = a }; SetBarField(info, "expireLabelColor", t) end
					MOD:UpdateAllBarGroups()
				end,
			},
			TimeTextColor = {
				type = "color", order = 81, name = L["Time"], hasAlpha = true, width = "half",
				desc = L["Set time color for when bar is about to expire (set invisible opacity to disable color change)."],
				disabled = function(info) return not GetBarField(info, "colorExpiring") end,
				get = function(info)
					local t = GetBarField(info, "expireTimeColor")
					if t then return t.r, t.g, t.b, t.a else return 1, 0, 0, 0 end
				end,
				set = function(info, r, g, b, a)
					local t = GetBarField(info, "expireTimeColor")
					if t then t.r = r; t.g = g; t.b = b; t.a = a else
						t = { r = r, g = g, b = b, a = a }; SetBarField(info, "expireTimeColor", t) end
					MOD:UpdateAllBarGroups()
				end,
			},
			space3f = { type = "description", name = "", order = 90 },
			MSBTWarning = {
				type = "toggle", order = 91, name = L["Combat Text"],
				desc = L["Enable warning in combat text for expiring bars."],
				get = function(info) return GetBarField(info, "expireMSBT") end,
				set = function(info, value) SetBarField(info, "expireMSBT", value) end,
			},
			ColorMSBT = {
				type = "color", order = 93, name = L["Color"], hasAlpha = true, width = "half",
				desc = L["Set color for combat text warning."],
				disabled = function(info) return not GetBarField(info, "expireMSBT") end,
				get = function(info)
					local t = GetBarField(info, "colorMSBT")
					if t then return t.r, t.g, t.b, t.a else return 1, 1, 1, 1 end
				end,
				set = function(info, r, g, b, a)
					local t = GetBarField(info, "colorMSBT")
					if t then t.r = r; t.g = g; t.b = b; t.a = a else
						t = { r = r, g = g, b = b, a = a }; SetBarField(info, "colorMSBT", t) end
					MOD:UpdateAllBarGroups()
				end,
			},
			MSBTCritical = {
				type = "toggle", order = 94, name = L["Critical"],
				desc = L["Enable combat text warning as critical."],
				disabled = function(info) return not GetBarField(info, "expireMSBT") end,
				get = function(info) return GetBarField(info, "criticalMSBT") end,
				set = function(info, value) SetBarField(info, "criticalMSBT", value) end,
			},
			spacer4 = { type = "description", name = "", order = 100 },
			HideBar = {
				type = "toggle", order = 101, name = L["Hide"], width = "half",
				desc = L["If checked, bar is conditionally hidden."],
				get = function(info) return IsOn(GetBarField(info, "hideBar")) end,
				set = function(info, value)
					local v = GetBarField(info, "hideBar")
					SetBarField(info, "hideBar", IsOn(v) and Off or true)
					MOD:UpdateAllBarGroups()
				end,
			},
			HideBarTrue = {
				type = "toggle", order = 102, name = L["True"], width = "half",
				desc = L["If checked, bar is hidden if the condition is true."],
				disabled = function(info) return IsOff(GetBarField(info, "hideBar")) end,
				get = function(info) return GetBarField(info, "hideBar") == true end,
				set = function(info, v) SetBarField(info, "hideBar", true); MOD:UpdateAllBarGroups() end,
			},
			HideBarFalse = {
				type = "toggle", order = 103, name = L["False"], width = "half",
				desc = L["If checked, bar is hidden if the condition is false."],
				disabled = function(info) return IsOff(GetBarField(info, "hideBar")) end,
				get = function(info) return GetBarField(info, "hideBar") == false end,
				set = function(info, v) SetBarField(info, "hideBar", false); MOD:UpdateAllBarGroups() end,
			},
			SelectCondition1 = {
				type = "select", order = 104, name = L["Hide Condition"],
				disabled = function(info) return IsOff(GetBarField(info, "hideBar")) end,
				get = function(info) return GetBarSelectedCondition(GetSelectConditionList(), GetBarField(info, "hideCondition")) end,
				set = function(info, value) SetBarField(info, "hideCondition", GetSelectConditionList()[value]) end,
				values = function(info) return GetSelectConditionList() end,
				style = "dropdown",
			},
			spacer5 = { type = "description", name = "", order = 110 },
			FlashBar = {
				type = "toggle", order = 111, name = L["Flash"], width = "half",
				desc = L["If checked, bar will conditionally flash."],
				get = function(info) return IsOn(GetBarField(info, "flashBar")) end,
				set = function(info, value)
					local v = GetBarField(info, "flashBar")
					SetBarField(info, "flashBar", IsOn(v) and Off or true)
					MOD:UpdateAllBarGroups()
				end,
			},
			FlashBarTrue = {
				type = "toggle", order = 112, name = L["True"], width = "half",
				desc = L["If checked, bar will flash if the condition is true."],
				disabled = function(info) return IsOff(GetBarField(info, "flashBar")) end,
				get = function(info) return GetBarField(info, "flashBar") == true end,
				set = function(info, v) SetBarField(info, "flashBar", true); MOD:UpdateAllBarGroups() end,
			},
			FlashBarFalse = {
				type = "toggle", order = 113, name = L["False"], width = "half",
				desc = L["If checked, bar will flash if the condition is false."],
				disabled = function(info) return IsOff(GetBarField(info, "flashBar")) end,
				get = function(info) return GetBarField(info, "flashBar") == false end,
				set = function(info, v) SetBarField(info, "flashBar", false); MOD:UpdateAllBarGroups() end,
			},
			SelectCondition2 = {
				type = "select", order = 114, name = L["Flash Condition"],
				disabled = function(info) return IsOff(GetBarField(info, "flashBar")) end,
				get = function(info) return GetBarSelectedCondition(GetSelectConditionList(), GetBarField(info, "flashCondition")) end,
				set = function(info, value) SetBarField(info, "flashCondition", GetSelectConditionList()[value]) end,
				values = function(info) return GetSelectConditionList() end,
				style = "dropdown",
			},
			spacer6 = { type = "description", name = "", order = 120 },
			FadeBar = {
				type = "toggle", order = 121, name = L["Fade"], width = "half",
				desc = L["If checked, bar will conditionally change from normal opacity to fade opacity."],
				get = function(info) return IsOn(GetBarField(info, "fadeBar")) end,
				set = function(info, value)
					local v = GetBarField(info, "fadeBar")
					SetBarField(info, "fadeBar", IsOn(v) and Off or true)
					MOD:UpdateAllBarGroups()
				end,
			},
			FadeBarTrue = {
				type = "toggle", order = 125, name = L["True"], width = "half",
				desc = L["If checked, bar will fade if the condition is true."],
				disabled = function(info) return IsOff(GetBarField(info, "fadeBar")) end,
				get = function(info) return GetBarField(info, "fadeBar") == true end,
				set = function(info, v) SetBarField(info, "fadeBar", true); MOD:UpdateAllBarGroups() end,
			},
			FadeBarFalse = {
				type = "toggle", order = 126, name = L["False"], width = "half",
				desc = L["If checked, bar will fade if the condition is false."],
				disabled = function(info) return IsOff(GetBarField(info, "fadeBar")) end,
				get = function(info) return GetBarField(info, "fadeBar") == false end,
				set = function(info, v) SetBarField(info, "fadeBar", false); MOD:UpdateAllBarGroups() end,
			},
			SelectCondition3 = {
				type = "select", order = 127, name = L["Fade Condition"],
				disabled = function(info) return IsOff(GetBarField(info, "fadeBar")) end,
				get = function(info) return GetBarSelectedCondition(GetSelectConditionList(), GetBarField(info, "fadeCondition")) end,
				set = function(info, value) SetBarField(info, "fadeCondition", GetSelectConditionList()[value]) end,
				values = function(info) return GetSelectConditionList() end,
				style = "dropdown",
			},
			spacer7 = { type = "description", name = "", order = 130 },
			ColorCondition = {
				type = "toggle", order = 131, name = L["Color"], width = "half",
				desc = L["If checked, bar color is based on the value of the condition."],
				get = function(info) return GetBarField(info, "colorBar") end,
				set = function(info, value) SetBarField(info, "colorBar", value) end,
			},
			TrueConditionColor = {
				type = "color", order = 135, name = L["True"], hasAlpha = true, width = "half",
				desc = L["Set bar color for when condition is true (set invisible opacity to disable color change)."],
				disabled = function(info) return not GetBarField(info, "colorBar") end,
				get = function(info)
					local t = GetBarField(info, "colorTrue")
					if t then return t.r, t.g, t.b, t.a else return 0, 1, 0, 0 end
				end,
				set = function(info, r, g, b, a)
					local t = GetBarField(info, "colorTrue")
					if t then t.r = r; t.g = g; t.b = b; t.a = a else
						t = { r = r, g = g, b = b, a = a }; SetBarField(info, "colorTrue", t) end
					MOD:UpdateAllBarGroups()
				end,
			},
			FalseConditionColor = {
				type = "color", order = 136, name = L["False"], hasAlpha = true, width = "half",
				desc = L["Set bar color for when condition is false (set invisible opacity to disable color change)."],
				disabled = function(info) return not GetBarField(info, "colorBar") end,
				get = function(info)
					local t = GetBarField(info, "colorFalse")
					if t then return t.r, t.g, t.b, t.a else return 1, 0, 0, 0 end
				end,
				set = function(info, r, g, b, a)
					local t = GetBarField(info, "colorFalse")
					if t then t.r = r; t.g = g; t.b = b; t.a = a else
						t = { r = r, g = g, b = b, a = a }; SetBarField(info, "colorFalse", t) end
					MOD:UpdateAllBarGroups()
				end,
			},
			SelectCondition4 = {
				type = "select", order = 137, name = L["Color Condition"],
				disabled = function(info) return not GetBarField(info, "colorBar") end,
				get = function(info) return GetBarSelectedCondition(GetSelectConditionList(), GetBarField(info, "colorCondition")) end,
				set = function(info, value) SetBarField(info, "colorCondition", GetSelectConditionList()[value]) end,
				values = function(info) return GetSelectConditionList() end,
				style = "dropdown",
			},
		},
	},
	BarTypeGroup = {
		type = "group", order = 40, name = "", inline = true,
		hidden = function(info) return not InMode("Bar") end,
		args = {
			SelectBarType = {
				type = "group", order = 1, name = L["Type"], inline = true,
				args = {
					NotificationBar = {
						type = "toggle", order = 10, name = L["Notify"], width = "half",
						desc = L["If checked, this is a notify bar."],
						get = function(info) return bars.template.barType == "Notification" end,
						set = function(info, value) SetSelectedBarType("Notification") end,
					},
					BuffBar = {
						type = "toggle", order = 20, name = L["Buff"], width = "half",
						desc = L["If checked, this is a buff bar."],
						get = function(info) return bars.template.barType == "Buff" end,
						set = function(info, value) SetSelectedBarType("Buff") end,
					},
					DebuffBar = {
						type = "toggle", order = 30, name = L["Debuff"], width = "half",
						desc = L["If checked, this is a debuff bar."],
						get = function(info) return bars.template.barType == "Debuff" end,
						set = function(info, value) SetSelectedBarType("Debuff") end,
					},
					CooldownBar = {
						type = "toggle", order = 40, name = L["Cooldown"],
						desc = L["If checked, this is a cooldown bar."],
						get = function(info) return bars.template.barType == "Cooldown" end,
						set = function(info, value) SetSelectedBarType("Cooldown") end,
					},
				},
			},
			SelectBarSource = {
				type = "group", order = 10, name = L["Source"], inline = true,
				hidden = function(info) return (bars.template.barType == "Notification") end,
				args = {
					Class = {
						type = "toggle", order = 10, name = L["Class"], width = "half",
						desc = L["If checked, select actions associated with a class."],
						get = function(info) return bars.template.barSource == "Class" end,
						set = function(info, value) SetSelectedBarSource("Class") end,
					},
					Racial = {
						type = "toggle", order = 20, name = L["Race"], width = "half",
						desc = L["If checked, select actions associated with a race."],
						get = function(info) return bars.template.barSource == "Racial" end,
						set = function(info, value) SetSelectedBarSource("Racial") end,
					},
					Pet = {
						type = "toggle", order = 30, name = L["Pet"], width = "half",
						desc = L["If checked, select actions associated with a pet."],
						get = function(info) return bars.template.barSource == "Pet" end,
						set = function(info, value) SetSelectedBarSource("Pet") end,
					},
					Spell = {
						type = "toggle", order = 40, name = L["Other Spell"],
						desc = L["If checked, enter spell name for an associated action."],
						get = function(info) return bars.template.barSource == "Other" end,
						set = function(info, value) SetSelectedBarSource("Other") end,
					},
				},
			},
			SelectClass = {
				type = "group", order = 15, name = L["Class"], inline = true,
				hidden = function(info)
					return (bars.template.barType == "Notification") or ((bars.template.barSource ~= "Class") and (bars.template.barSource ~= "Pet"))
				end,
				args = {
					Druid = {
						type = "toggle", order = 10, name = L["Druid"], width = "half",
						desc = L["If checked, select druid actions."],
						hidden = function(info) return bars.template.barSource == "Pet" end,
						get = function(info) return bars.template.barClass == 2 end,
						set = function(info, value) SetSelectedBarClass(2) end,
					},
					Hunter = {
						type = "toggle", order = 15, name = L["Hunter"], width = "half",
						desc = L["If checked, select hunter actions."],
						get = function(info) return bars.template.barClass == 3 end,
						set = function(info, value) SetSelectedBarClass(3) end,
					},
					Mage = {
						type = "toggle", order = 20, name = L["Mage"], width = "half",
						desc = L["If checked, select mage actions."],
						hidden = function(info) return bars.template.barSource == "Pet" end,
						get = function(info) return bars.template.barClass == 4 end,
						set = function(info, value) SetSelectedBarClass(4) end,
					},
					Monk = {
						type = "toggle", order = 22, name = L["Monk"], width = "half",
						desc = L["If checked, select monk actions."],
						hidden = function(info) return bars.template.barSource == "Pet" end,
						get = function(info) return bars.template.barClass == 11 end,
						set = function(info, value) SetSelectedBarClass(11) end,
					},
					Paladin = {
						type = "toggle", order = 25, name = L["Paladin"], width = "half",
						desc = L["If checked, select paladin actions."],
						hidden = function(info) return bars.template.barSource == "Pet" end,
						get = function(info) return bars.template.barClass == 5 end,
						set = function(info, value) SetSelectedBarClass(5) end,
					},
					Priest = {
						type = "toggle", order = 30, name = L["Priest"], width = "half",
						desc = L["If checked, select priest actions."],
						hidden = function(info) return bars.template.barSource == "Pet" end,
						get = function(info) return bars.template.barClass == 6 end,
						set = function(info, value) SetSelectedBarClass(6) end,
					},
					Rogue = {
						type = "toggle", order = 35, name = L["Rogue"], width = "half",
						desc = L["If checked, select rogue actions."],
						hidden = function(info) return bars.template.barSource == "Pet" end,
						get = function(info) return bars.template.barClass == 7 end,
						set = function(info, value) SetSelectedBarClass(7) end,
					},
					Shaman = {
						type = "toggle", order = 40, name = L["Shaman"], width = "half",
						desc = L["If checked, select shaman actions."],
						hidden = function(info) return bars.template.barSource == "Pet" end,
						get = function(info) return bars.template.barClass == 8 end,
						set = function(info, value) SetSelectedBarClass(8) end,
					},
					Warlock = {
						type = "toggle", order = 45, name = L["Warlock"], width = "half",
						desc = L["If checked, select warlock actions."],
						get = function(info) return bars.template.barClass == 9 end,
						set = function(info, value) SetSelectedBarClass(9) end,
					},
					Warrior = {
						type = "toggle", order = 50, name = L["Warrior"], width = "half",
						desc = L["If checked, select warrior actions."],
						hidden = function(info) return bars.template.barSource == "Pet" end,
						get = function(info) return bars.template.barClass == 10 end,
						set = function(info, value) SetSelectedBarClass(10) end,
					},
					DeathKnight = {
						type = "toggle", order = 55, name = L["Death Knight"],
						desc = L["If checked, select death knight actions."],
						get = function(info) return bars.template.barClass == 1 end,
						set = function(info, value) SetSelectedBarClass(1) end,
					},
				},
			},
			SelectConditionGroup = {
				type = "group", order = 20, name = L["Conditions To Monitor"], inline = true,
				hidden = function(info) return (bars.template.barType ~= "Notification") or (GetBarConditionListCount() == 0) end,
				args = {
					AllOnBar = {
						type = "execute", order = 10, name = L["All On"], width = "half",
						desc = L["Select all the conditions."],
						func = function(info) SetAllBarConditions(true) end,
					},
					AllOffBar = {
						type = "execute", order = 20, name = L["All Off"], width = "half",
						desc = L["Deselect all the conditions."],
						func = function(info) SetAllBarConditions(false) end,
					},
					SelectCondition = {
						type = "multiselect", order = 30, name = "",
						get = function(info, key) return GetSelectedBarCondition(key) end,
						set = function(info, key, value) SetSelectedBarCondition(key, value) end,
						values = function(info) return GetBarConditionList() end,
					},
				},
			},
			EnterOtherSpellGroup = {
				type = "group", order = 40, name = L["Other Spell"], inline = true,
				hidden = function(info) return (bars.template.barType == "Notification") or (bars.template.barSource ~= "Other") end,
				args = {
					SpellName = {
						type = "input", order = 10, name = L["Spell Name"],
						desc = L["Enter spell name (or numeric identifier) to associate with a bar."],
						get = function(info) return conditions.name end,
						set = function(info, n) n = ValidateSpellName(n); conditions.name = n end,
					},
				},
			},
			BarActionGroup = {
				type = "group", order = 50, name = L["Actions To Monitor"], inline = true,
				hidden = function(info) return (bars.template.barSource == "Other") or (GetBarActionListCount() == 0) end,
				args = {
					AllOnBar = {
						type = "execute", order = 10, name = L["All On"], width = "half",
						desc = L["Select all the actions."],
						func = function(info) SetAllBarActions(true) end,
					},
					AllOffBar = {
						type = "execute", order = 20, name = L["All Off"], width = "half",
						desc = L["Deselect all the actions."],
						func = function(info) SetAllBarActions(false) end,
					},
					SelectBarAction = {
						type = "multiselect", order = 30, name = "",
						get = function(info, key) return GetSelectedBarAction(key) end,
						set = function(info, key, value) SetSelectedBarAction(key, value) end,
						values = function(info) return GetBarActionList() end,
					},
				},
			},
		},
	},
	MonitorUnitGroup = {
		type = "group", order = 50, name = L["Action On"], inline = true,
		hidden = function(info) return not InMode("Bar") or ((bars.template.barType ~= "Buff") and (bars.template.barType ~= "Debuff")) end,
		args = {
			PlayerBuff = {
				type = "toggle", order = 10, name = L["Player"],
				desc = L["If checked, must be on the player."],
				get = function(info) return bars.template.monitor == "player" end,
				set = function(info, value) bars.template.monitor = "player" end,
			},
			PetBuff = {
				type = "toggle", order = 15, name = L["Pet"],
				desc = L["If checked, must be on the player's pet."],
				get = function(info) return bars.template.monitor == "pet" end,
				set = function(info, value) bars.template.monitor = "pet" end,
			},
			TargetBuff = {
				type = "toggle", order = 20, name = L["Target"],
				desc = L["If checked, must be on the target."],
				get = function(info) return bars.template.monitor == "target" end,
				set = function(info, value) bars.template.monitor = "target" end,
			},
			FocusBuff = {
				type = "toggle", order = 25, name = L["Focus"],
				desc = L["If checked, must be on the focus."],
				get = function(info) return bars.template.monitor == "focus" end,
				set = function(info, value) bars.template.monitor = "focus" end,
			},
			MouseoverBuff = {
				type = "toggle", order = 30, name = L["Mouseover"],
				desc = L["If checked, must be on the mouseover unit."],
				get = function(info) return bars.template.monitor == "mouseover" end,
				set = function(info, value) bars.template.monitor = "mouseover" end,
			},
			PetTargetBuff = {
				type = "toggle", order = 35, name = L["Pet's Target"],
				desc = L["If checked, must be on the pet's target."],
				get = function(info) return bars.template.monitor == "pettarget" end,
				set = function(info, value) bars.template.monitor = "pettarget" end,
			},
			TargetTargetBuff = {
				type = "toggle", order = 40, name = L["Target's Target"],
				desc = L["If checked, must be on the target's target."],
				get = function(info) return bars.template.monitor == "targettarget" end,
				set = function(info, value) bars.template.monitor = "targettarget" end,
			},
			FocusTargetBuff = {
				type = "toggle", order = 45, name = L["Focus's Target"],
				desc = L["If checked, must be on the focus's target."],
				get = function(info) return bars.template.monitor == "focustarget" end,
				set = function(info, value) bars.template.monitor = "focustarget" end,
			},
		},
	},
	CastUnitGroup = {
		type = "group", order = 60, name = L["Cast By"], inline = true,
		hidden = function(info) return not InMode("Bar") or ((bars.template.barType ~= "Buff") and (bars.template.barType ~= "Debuff")) end,
		args = {
			PlayerBuff = {
				type = "toggle", order = 10, name = L["Player"], width = "half",
				desc = L["If checked, only track if cast by the player."],
				get = function(info) return bars.template.castBy == "player" end,
				set = function(info, value) bars.template.castBy = "player" end,
			},
			PetBuff = {
				type = "toggle", order = 20, name = L["Pet"], width = "half",
				desc = L["If checked, only track if cast by the player's pet."],
				get = function(info) return bars.template.castBy == "pet" end,
				set = function(info, value) bars.template.castBy = "pet" end,
			},
			OtherBuff = {
				type = "toggle", order = 30, name = L["Other"], width = "half",
				desc = L["If checked, only track if cast by anyone other than the player."],
				get = function(info) return bars.template.castBy == "other" end,
				set = function(info, value) bars.template.castBy = "other" end,
			},
			AnyoneBuff = {
				type = "toggle", order = 40, name = L["Anyone"], width = "half",
				desc = L["If checked, track if cast by anyone, including player and pet."],
				get = function(info) return bars.template.castBy == "anyone" end,
				set = function(info, value) bars.template.castBy = "anyone" end,
			},
		},
	},
	OKNewBar = {
		type = "execute", order = 93, name = L["OK"], width = "half",
		desc = L["Confirm creating new bars for the selected actions/conditions."],
		hidden = function(info) return not InMode("Bar") end,
		func = function(info) EnterNewBar("ok") end,
	},
	CancelNewBar = {
		type = "execute", order = 94, name = L["Cancel"], width = "half",
		desc = L["Cancel creating new bars."],
		hidden = function(info) return not InMode("Bar") end,
		func = function(info) EnterNewBar("cancel") end,
	},
}
