local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local MODNAME = "GridLayout"
local GridLayout = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local NeedUpdate = false

local G2L, G2F

local CurMapID = 0

local SizeByMapID = {
	[401] = 40,		-- AV
	[443] = 10,		-- WSG
	[461] = 15,		-- AB
	[482] = 15,		-- EotS
	[501] = 40,		-- Wintergrasp
	[512] = 15,		-- SotA
	[540] = 40,		-- IoC
	[626] = 10,		-- TP
	[708] = 40,		-- Tol Barad
	[736] = 10,		-- BoG
	[856] = 10,		-- Temple of Kotmogu
	[860] = 10,		-- Silvershard Mines
}

local raidGroupInUse = {
	group1 = false,
	group2 = false,
	group3 = false,
	group4 = false,
	group5 = false,
	group6 = false,
	group7 = false,
	group8 = false,
}

-- Options
local table_GroupSizes = {
	"10",
	"15",
	"25",
	"40",
}

------------------------
---- Layout Updates ----
------------------------
-- Fired when Exiting combat
local LockdownTimer = CreateFrame("Frame")
LockdownTimer.Elapsed = 0
LockdownTimer:Hide()
LockdownTimer:SetScript("OnUpdate", function(self, elapsed)
	LockdownTimer.Elapsed = LockdownTimer.Elapsed + elapsed
	if LockdownTimer.Elapsed >= 1 then
		if not InCombatLockdown() then
			if NeedUpdate then GridLayout:Update() end
			LockdownTimer.Elapsed = 0
			LockdownTimer:Hide()
		else
			-- Repeat timer until combat restrictions are lifted
			LockdownTimer.Elapsed = 0
		end
	end
end);

function GridLayout:UpdateLockdown(...)
	LockdownTimer:Show()
end

-- Reload Grid Layout
local function ReloadGridLayout()
	local ReloadLayoutTimer = CreateFrame("Frame")
	ReloadLayoutTimer:Show()
	ReloadLayoutTimer.Elapsed = 0
	ReloadLayoutTimer:SetScript("OnUpdate", function(self, elapsed)
		ReloadLayoutTimer.Elapsed = ReloadLayoutTimer.Elapsed + elapsed
		if ReloadLayoutTimer.Elapsed >= 0.5 then
			if not InCombatLockdown() then
				if Grid2Frame.db.profile.frameWidth ~= NewWidth then
					Grid2Layout:SendMessage("Grid_ReloadLayout")
				end
				ReloadLayoutTimer.Elapsed = 0
				ReloadLayoutTimer:Hide()
			else
				-- Repeat timer until combat restrictions are lifted
				ReloadLayoutTimer.Elapsed = 0
			end
		end
	end);
end

-- Set Frame Width
local ResizeTimer = CreateFrame("Frame")
local function SetGridFrameWidth(NewWidth)
	ResizeTimer:Show()
	ResizeTimer.Elapsed = RealUIGridConfiguring and 0.5 or 0
	ResizeTimer:SetScript("OnUpdate", nil)
	ResizeTimer:SetScript("OnUpdate", function(self, elapsed)
		ResizeTimer.Elapsed = ResizeTimer.Elapsed + elapsed
		if ResizeTimer.Elapsed >= 0.5 then
			if not InCombatLockdown() then
				if Grid2Frame.db.profile.frameWidth ~= NewWidth then
					-- Code from Grid2Options\Modules\general\GridFrame
					Grid2Frame.db.profile.frameWidth = NewWidth
					Grid2Frame:LayoutFrames()
					Grid2Layout:UpdateSize()
					Grid2Layout:ReloadLayout()
				
					if Grid2Options and Grid2Options.LayoutTestRefresh then Grid2Options:LayoutTestRefresh() end

					-- Reposition Grid2
					if nibRealUI:GetModuleEnabled("FrameMover") then
						local FM = nibRealUI:GetModule("FrameMover", true)
						if FM then FM:MoveAddons() end
					end

					-- ReloadGridLayout()
				end
				
				ResizeTimer.Elapsed = 0
				ResizeTimer:Hide()
			else
				-- Repeat timer until combat restrictions are lifted
				ResizeTimer.Elapsed = 0
			end
		end
	end)
end

-- Update Grid Layout
function GridLayout:Update()
	if not(nibRealUI:GetModuleEnabled(MODNAME)) or not(Grid2 and Grid2Layout and Grid2Frame) then return end
	if not nibRealUI:DoesAddonStyle("Grid2") then return end

	-- Combat Lockdown checking
	if InCombatLockdown() then
		NeedUpdate = true
		return
	end
	NeedUpdate = false
	---
	
	local LayoutDB
	local NewLayout
	
	-- Get Instance type
	local _, instanceType, difficultyIndex = GetInstanceInfo()
	
	-- Get Map ID
	if not WorldMapFrame:IsShown() then
		CurMapID = GetCurrentMapAreaID()
	end
	
	-- In Tol Barad or Wintergrasp
	local InTB, InWG, In40 = false, false, false
	local _, _, WGActive = GetWorldPVPAreaInfo(1)
	if ( (CurMapID == 708) and UnitInRaid("player") ) then
		InTB = true
	elseif ( (CurMapID == 501) and WGActive and UnitInRaid("player") ) then
		InWG = true
	end
	
	-- Which RealUI Layout we're working on
	LayoutDB = (nibRealUI.cLayout == 1) and db.dps or db.healing
	
	-- Find new Grid Layout
	-- Battleground
	if ( (instanceType == "pvp") or InTB or InWG ) then
		-- print("You are in a Battleground")
		local RaidSize = SizeByMapID[CurMapID] or 40
		local LayoutKey
		local NewSize = RaidSize
		
		if NewSize == 10 then
			NewLayout = "By Group 10"
			LayoutKey = "raid10"
		elseif NewSize == 15 then
			NewLayout = "By Group 15"
			LayoutKey = "raid15"
		elseif NewSize == 25 then
			NewLayout = "By Group 25"
			LayoutKey = "raid25"
		elseif NewSize == 40 then
			NewLayout = "By Group 40"
			LayoutKey = "raid40"
		end
		-- print(NewLayout, NewSize)

		-- Change Grid Layout
		local NewHoriz = LayoutDB.hGroups.bg
		if ( NewLayout and ((NewLayout ~= Grid2Layout.db.profile.layouts[LayoutKey]) or (NewHoriz ~= Grid2Layout.db.profile.horizontal)) ) then
			Grid2Layout.db.profile.layouts[LayoutKey] = NewLayout
			Grid2Layout.db.profile.horizontal = NewHoriz
			Grid2Layout:ReloadLayout()
		end
		
		-- Adjust Grid Frame Width
		local NewWidth
		if (NewLayout == "By Group 40") and not(LayoutDB.hGroups.bg) then
			NewWidth = LayoutDB.sWidth
		else
			NewWidth = LayoutDB.width
		end
		SetGridFrameWidth(NewWidth)
		-- print(NewWidth)
		
	-- 5 man group - Adjust w/pets
	elseif ( (instanceType == "arena") or (instanceType == "party" or nil) ) then
		--print("You are in a Dungeon, Scenario, or Arena")
		local HasPet = UnitExists("pet") or UnitExists("partypet1") or UnitExists("partypet2") or UnitExists("partypet3") or UnitExists("partypet4")
		if HasPet and LayoutDB.showPet then 
			NewLayout = "By Group 5 w/Pets"
		else
			NewLayout = "By Group 5"
		end
		
		-- Change Grid Layout
		local NewHoriz = LayoutDB.hGroups.normal
		if ( (instanceType == "arena") and ((NewLayout ~= Grid2Layout.db.profile.layouts.arena) or (NewHoriz ~= Grid2Layout.db.profile.horizontal)) ) then
			Grid2Layout.db.profile.layouts.arena = NewLayout
			Grid2Layout.db.profile.horizontal = NewHoriz
			Grid2Layout:ReloadLayout()

		elseif ( (instanceType == "party" or nil) and ((NewLayout ~= Grid2Layout.db.profile.layouts.party) or (NewHoriz ~= Grid2Layout.db.profile.horizontal)) ) then
			Grid2Layout.db.profile.layouts.party = NewLayout
			Grid2Layout.db.profile.horizontal = NewHoriz
			Grid2Layout:ReloadLayout()
		end
		
		-- Adjust Grid Frame Width
		SetGridFrameWidth(LayoutDB.width)

	-- Raid
	elseif (instanceType == "raid") then
		--print("You are in a Raid, difficulty: "..difficultyIndex)
		if difficultyIndex == (3 or 5) then
			--print("You are in a 10 Man")
			NewLayout = "By Group 10"
		elseif difficultyIndex == (4 or 6) or 7 then
			--print("You are in a 25 Man")
			NewLayout = "By Group 25"
		end

		-- Change Grid Layout
		local NewHoriz = LayoutDB.hGroups.normal
		if difficultyIndex == (3 or 5) and ((NewLayout ~= Grid2Layout.db.profile.layouts.raid10) or (NewHoriz ~= Grid2Layout.db.profile.horizontal)) then
			Grid2Layout.db.profile.layouts.raid10 = NewLayout
			Grid2Layout.db.profile.horizontal = NewHoriz
			Grid2Layout:ReloadLayout()

		elseif difficultyIndex == (4 or 6) or 7 and ((NewLayout ~= Grid2Layout.db.profile.layouts.raid25) or (NewHoriz ~= Grid2Layout.db.profile.horizontal)) then
			Grid2Layout.db.profile.layouts.raid25 = NewLayout
			Grid2Layout.db.profile.horizontal = NewHoriz
			Grid2Layout:ReloadLayout()
		end
		
		-- Adjust Grid Frame Width
		SetGridFrameWidth(LayoutDB.width)

		-- If not BG, Arena, Raid or Dungeon, then set normal values
	else
		--print("You are not in an instance")
		local difficulty = GetRaidDifficultyID()
		local raidSize = GetNumGroupMembers()

		-- Solo
		if raidSize == 0 then
			SetGridFrameWidth(LayoutDB.width)
			Grid2Layout.db.profile.horizontal = LayoutDB.hGroups.normal
			if LayoutDB.showSolo then
				if UnitExists("pet") and LayoutDB.showPet then 
					NewLayout = "By Group 5 w/Pets"
				else
					NewLayout = "By Group 5"
				end
			else
				NewLayout = "None"
			end
			Grid2Layout.db.profile.layouts.solo = NewLayout
			Grid2Layout:ReloadLayout()

		-- Group
		else
			-- reset the table
			for k,v in pairs(raidGroupInUse) do
				raidGroupInUse[k] = false
			end
			
			-- find what groups are in use
			for i = 1, MAX_RAID_MEMBERS do
				local name, _, subGroup = GetRaidRosterInfo(i)
				--print(tostring(name)..", "..tostring(subGroup))
				if name and subGroup then
					raidGroupInUse["group"..subGroup] = true
				-- else
					-- break
				end
			end
			
			local NewHoriz = LayoutDB.hGroups.raid
			if (raidGroupInUse.group8 or raidGroupInUse.group7) or raidGroupInUse.group6 then --newSize > 25 then
				--print("You have more than 25 players in the raid")
				NewLayout = "By Group 40"
			elseif (raidGroupInUse.group5 or raidGroupInUse.group4) then --newSize > 15 then
				--print("You have more than 15 players in the raid")
				NewLayout = "By Group 25"
			elseif raidGroupInUse.group3 then --newSize > 10 then
				--print("You have more than 10 players in the raid")
				NewLayout = "By Group 15"
			elseif raidGroupInUse.group2 then --newSize > 5 then
				--print("You have more than 5 players in the raid")
				NewLayout = "By Group 10"
			else--if newSize <= 5 then
				--print("You have 5 or less players in the raid")
				NewLayout = "By Group 5"
			end

			-- Change Grid Layout
			if ( (difficulty == 1 or 3) and ((NewLayout ~= Grid2Layout.db.profile.layouts.raid10) or (NewHoriz ~= Grid2Layout.db.profile.horizontal)) ) then
				Grid2Layout.db.profile.layouts.raid10 = NewLayout
				Grid2Layout.db.profile.horizontal = NewHoriz
				Grid2Layout:ReloadLayout()
			elseif ( (difficulty == 2 or 4) and ((NewLayout ~= Grid2Layout.db.profile.layouts.raid25) or (NewHoriz ~= Grid2Layout.db.profile.horizontal)) ) then
				Grid2Layout.db.profile.layouts.raid25 = NewLayout
				Grid2Layout.db.profile.horizontal = NewHoriz
				Grid2Layout:ReloadLayout()
			end

			-- Adjust Grid Frame Width
			local NewWidth
			if (NewLayout == "By Group 40") and not(LayoutDB.hGroups.raid) then
				NewWidth = LayoutDB.sWidth
			else
				NewWidth = LayoutDB.width
			end
			SetGridFrameWidth(NewWidth)
		end
	end
	
	-- FrameMover
	if nibRealUI:GetModuleEnabled("FrameMover") then
		local FM = nibRealUI:GetModule("FrameMover", true)
		if FM then FM:MoveAddons() end
	end
end

function nibRealUI:SetGridLayoutSettings(value, key1, key2, key3)
	if key3 then
		db[key1][key2][key3] = value
	else
		db[key1][key2] = value
	end
	GridLayout:Update()
end

function nibRealUI:GetGridLayoutSettings(key1, key2, key3)
	if key3 then
		return db[key1][key2][key3]
	else
		return db[key1][key2]
	end
end

function GridLayout:OnInitialize()
	self.db = nibRealUI.db:RegisterNamespace(MODNAME)
	self.db:RegisterDefaults({
		profile = {
			dps = {
				width = 65,
				sWidth = 40,
				hGroups = {normal = true, raid = true, bg = false},
				showPet = true,
				showSolo = false,
			},
			healing = {
				width = 65,
				sWidth = 40,
				hGroups = {normal = false, raid = false, bg = false},
				showPet = true,
				showSolo = false,
			},
		},
	})
	db = self.db.profile
	
	self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
end

function GridLayout:OnEnable()
	if not(Grid2 and Grid2Layout and Grid2Frame) then return end
	
	self:RegisterBucketEvent({"PLAYER_ENTERING_WORLD", "ZONE_CHANGED_NEW_AREA", "GROUP_ROSTER_UPDATE", "UNIT_PET"}, 1.1, "Update")
	self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLockdown")
	
	WorldMapFrame:HookScript("OnHide", function() GridLayout:Update() end)
	GridLayout:Update()
end

function GridLayout:OnDisable()
	self:UnregisterAllBuckets()
	self:UnregisterEvent("PLAYER_REGEN_ENABLED")
	WorldMapFrame:HookScript("OnHide", function() end)
end