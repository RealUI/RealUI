local defaults = {
	profile = {8,7,6,5,4,3,2,1,Enabled = true},
	--[===[@debug@
	global = {
		debug = {
		},
	},
	--@end-debug@]===]
}

-- WORKS: SetRaidTarget(unit,0); SetRaidTarget(unit,[1,8]) 
-- BROKEN: SetRaidTarget(unit,[1,8]); SetRaidTarget(unit,0) 

local addon = DXE
local L = addon.L

local wipe = table.wipe
local targetof = addon.targetof
local SetRaidTarget_Blizzard = SetRaidTarget
local GetRaidTargetIndex = GetRaidTargetIndex
local UnitGUID = UnitGUID
local ipairs,pairs = ipairs,pairs

local module = addon:NewModule("RaidIcons","AceTimer-3.0","AceEvent-3.0")
addon.RaidIcons = module

local db,pfl
local debug

-- Workaround the issue where in 4.0.1 SetRaidTarget now toggles
-- Just like SetRaidTargetIcon
local function SetRaidTarget(unit, icon)
	if not icon then return end
	if icon == 0 then 
		SetRaidTarget_Blizzard(unit,0)
		return
	end
	if GetRaidTargetIndex(unit) == nil then
	--if GetRaidTargetIndex(unit) ~= icon then
		SetRaidTarget_Blizzard(unit,icon)
	end
end

function module:RefreshProfile() pfl = db.profile end

function module:OnInitialize()
	self.db = addon.db:RegisterNamespace("RaidIcons", defaults)
	db = self.db
	pfl = db.profile

	db.RegisterCallback(self, "OnProfileChanged", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileCopied", "RefreshProfile")
	db.RegisterCallback(self, "OnProfileReset", "RefreshProfile")

	--[===[@debug@
	debug = addon:CreateDebugger("RaidIcons",db.global,db.global.debug)
	--@end-debug@]===]
end

function module:OnDisable()
	self:RemoveAll()
end

-------------------------------------------
-- FRIENDLY MARKING
-------------------------------------------

do
	local units = {}        -- unit -> handle
	local friendly_cnt = {} -- var  -> count
	local count_resets = {} -- var  -> handle

	local function ResetCount(var)
		friendly_cnt[var] = nil
		count_resets[var] = nil
	end

	---------------------------------
	-- API
	---------------------------------

	function module:RemoveIcon(unit)
		if not pfl.Enabled then return end

		module:CancelTimer(units[unit],true)
		SetRaidTarget(unit,0)
		units[unit] = nil
	end

	function module:MarkFriendly(unit,icon,persist)
		if not pfl.Enabled then return end

		-- Unschedule unit's icon removal. The schedule is effectively reset.
		if units[unit] then 
			self:CancelTimer(units[unit],true) 
			units[unit] = nil
		end

		SetRaidTarget(unit,pfl[icon])
		units[unit] = self:ScheduleTimer("RemoveIcon",persist,unit)
	end

	-- Actual icon is chosen by increasing icon parameter
	function module:MultiMarkFriendly(var,unit,icon,persist,reset,total)
		if not pfl.Enabled then return end

		local ix = friendly_cnt[var] or 0
		-- maxed out
		if ix >= total then return end
		icon = icon + ix -- calc icon
		self:MarkFriendly(unit,icon,persist)
		friendly_cnt[var] = ix + 1
		if not count_resets[var] then
			count_resets[var] = self:ScheduleTimer(ResetCount,reset,var)
		end
	end

	function module:RemoveAllFriendly()
		for unit in pairs(units) do self:RemoveIcon(unit) end
		wipe(friendly_cnt)
		wipe(count_resets)
	end
end

-------------------------------------------
-- ENEMY MARKING
-------------------------------------------

do
	local PAUSE_TIME = 0.5
	local unit_to_unittarget = addon.Roster.unit_to_unittarget
	local enemy_cnt = {}      -- var  -> count
	local count_resets = {}   -- var  -> handle
	local used_icons = {}     -- var  -> {icons}
	local removes = {}        -- var  -> handle

	local guids = {}          -- guid -> icon
	local teardown_handle
	local registered          -- whether or not we registered for events

	local function Teardown()
		if registered then
			module:UnregisterEvent("UNIT_TARGET")
			module:UnregisterEvent("UPDATE_MOUSEOVER_UNIT")
			registered = nil
		end
		if teardown_handle then
			module:CancelTimer(teardown_handle)
			teardown_handle = nil
		end
		wipe(guids)
	end

	local function MarkUnit(unit)
		--[===[@debug@
		assert(type(unit) == "string")
		--@end-debug@]===]

		local guid = UnitGUID(unit)
		if guid then
			local icon = guids[guid]
			if icon then
				SetRaidTarget(unit,pfl[icon])
				guids[guid] = nil
				-- teardown if guids is empty
				if not next(guids) then Teardown() end
				return true
			end
		end
	end

	local function MarkGUID(guid,icon)
		--[===[@debug@
		assert(type(guid) == "string")
		assert(type(icon) == "number")
		--@end-debug@]===]

		for _,unit in pairs(unit_to_unittarget) do
			if UnitGUID(unit) == guid then
				SetRaidTarget(unit,pfl[icon])
				return true
			end
		end
	end

	local function ResetCount(var)
		enemy_cnt[var]    = nil
		count_resets[var] = nil
	end

	-- Note: SetRaidTarget("player",[1-8]); SetRaidTarget("player",0) doesn't work
	-- so the second call has to be scheduled PAUSE_TIME later

	local function RemovePlayerIcon()
		SetRaidTarget("player",0)
	end

	local function RemoveSingleIcon(icon)
		SetRaidTarget("player",pfl[icon])
		module:ScheduleTimer(RemovePlayerIcon,PAUSE_TIME)
	end

	local function RemoveMultipleIcons(var)
		local t = used_icons[var]
		if t then
			for i,icon in ipairs(t) do
				SetRaidTarget("player",pfl[icon])
				t[i] = nil -- reuse table during attempt
			end
		end
		removes[var] = nil
		module:ScheduleTimer(RemovePlayerIcon,PAUSE_TIME)
	end

	---------------------------------
	-- EVENTS
	---------------------------------

	function module:UNIT_TARGET(_,unit)
		MarkUnit(targetof[unit])
	end

	function module:UPDATE_MOUSEOVER_UNIT()
		MarkUnit("mouseover")
	end

	---------------------------------
	-- API
	---------------------------------

	-- @param persist <number> number of seconds to attempt marking
	-- @param remove <boolean> whether or not to remove after persist
	function module:MarkEnemy(guid,icon,persist,remove)
		if not pfl.Enabled then return end

		local success = MarkGUID(guid,icon)
		if not success then
			guids[guid] = icon
			if not registered then
				self:RegisterEvent("UNIT_TARGET")
				self:RegisterEvent("UPDATE_MOUSEOVER_UNIT")
				registered = true
			end
			if teardown_handle then self:CancelTimer(teardown_handle) end
			teardown_handle = self:ScheduleTimer(Teardown,persist)
		end

		if remove then self:ScheduleTimer(RemoveSingleIcon,persist,icon) end
	end

	function module:MultiMarkEnemy(var,guid,icon,persist,remove,reset,total)
		if not pfl.Enabled then return end

		-- var keeps track of icon count
		local ix = enemy_cnt[var] or 0
		-- maxed out
		if ix >= total then return end
		icon = icon + ix -- calc icon
		self:MarkEnemy(guid,icon,persist) -- ignore single icon removing
		enemy_cnt[var] = ix + 1
		if not count_resets[var] then
			count_resets[var] = self:ScheduleTimer(ResetCount,reset,var)
		end

		-- multiple removes
		if remove then
			local t = used_icons[var]
			if not t then
				t = {}
				used_icons[var] = t
			end
			t[#t+1] = icon
			-- make sure we only schedule one
			if not removes[var] then
				removes[var] = self:ScheduleTimer(RemoveMultipleIcons,persist,var)
			end
		end
	end

	function module:RemoveAllEnemy()
		wipe(enemy_cnt)
		wipe(count_resets)
		wipe(used_icons)
		wipe(removes)
		Teardown()
	end
end

-------------------------------------------
-- CLEANUP
-------------------------------------------

function module:RemoveAll()
	if not pfl.Enabled then return end

	self:RemoveAllFriendly()
	self:RemoveAllEnemy()
	self:CancelAllTimers() -- goes last
end

-------------------------------------------
-- UTIL
-------------------------------------------

function module:HasIcon(unit,icon)
	icon = tonumber(icon)
	return icon and GetRaidTargetIndex(unit) == pfl[icon]
end
