local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local MODNAME = "GridLayout"
local GridLayout = nibRealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local NeedUpdate = false

local G2L, G2F

local CurMapID = 0

local SizeByMapID = {
    [401] = 40,     -- AV
    [443] = 10,     -- WSG
    [461] = 15,     -- AB
    [482] = 15,     -- EotS
    [501] = 40,     -- Wintergrasp
    [512] = 15,     -- SotA
    [540] = 40,     -- IoC
    [626] = 10,     -- TP
    [708] = 40,     -- Tol Barad
    [736] = 10,     -- BoG
    [856] = 10,     -- Temple of Kotmogu
    [860] = 10,     -- Silvershard Mines
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

local isStaticSize = {
    true,  -- 5 Normal
    true,  -- 5 Heroic
    true,  -- 10 Normal
    true,  -- 25 Normal
    true,  -- 10 Heroic
    true,  -- 25 Heroic
    false, -- LFR
    true,  -- 5 Challenge
    false, -- Classic raid
    false, -- nil
    true,  -- 3 Heroic Scen
    true,  -- 3 Normal Scen
    false, -- nil
    false, -- Flex Normal
    false, -- Flex Heroic
    true,  -- 20 Mythic
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
local function ReloadGridLayout(NewWidth)
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

                    -- ReloadGridLayout(NewWidth)
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
    
    local NewLayout, NewHoriz, LayoutKey
    
    -- Get Instance type
    local instanceName, instanceType, difficultyIndex, _, maxPlayers, _, _, _, currPlayers = GetInstanceInfo()

    -- Check for Garrison
    local isInGarrison = instanceName:find("Garrison")
    
    -- Get Map ID
    if not WorldMapFrame:IsShown() then
        CurMapID = GetCurrentMapAreaID()
    end
    
    -- In Tol Barad or Wintergrasp
    local InTB, InWG = false, false
    local _, _, WGActive = GetWorldPVPAreaInfo(1)
    if ( (CurMapID == 708) and UnitInRaid("player") ) then
        InTB = true
    elseif ( (CurMapID == 501) and WGActive and UnitInRaid("player") ) then
        InWG = true
    end
    
    -- Which RealUI Layout we're working on
    local LayoutDB = (nibRealUI.cLayout == 1) and db.dps or db.healing
    
    -- Find new Grid Layout
    -- Battleground
    if ( (instanceType == "pvp") or InTB or InWG ) then
        -- print("You are in a Battleground")
        NewHoriz = LayoutDB.hGroups.bg
        LayoutKey = Grid2Layout.partyType or "raid10"
        local RaidSize = SizeByMapID[CurMapID] or 40
        
        if RaidSize == 10 then
            NewLayout = "By Group 10"
        elseif RaidSize == 15 then
            NewLayout = "By Group 15"
        elseif RaidSize == 25 then
            NewLayout = "By Group 25"
        elseif RaidSize == 40 then
            NewLayout = "By Group 40"
        end
        -- print(NewLayout, RaidSize)
    -- 5 man group - Adjust w/pets
    elseif ( (instanceType == "arena") or ((instanceType == "party" and not isInGarrison) or nil) ) then
        --print("You are in a Dungeon, Scenario, or Arena")
        NewHoriz = LayoutDB.hGroups.normal
        LayoutKey = Grid2Layout.partyType or "party"

        local HasPet = UnitExists("pet") or UnitExists("partypet1") or UnitExists("partypet2") or UnitExists("partypet3") or UnitExists("partypet4")
        if HasPet and LayoutDB.showPet then 
            NewLayout = "By Group 5 w/Pets"
        else
            NewLayout = "By Group 5"
        end
    -- Raid
    elseif (instanceType == "raid") and isStaticSize[difficultyIndex] then
        NewHoriz = LayoutDB.hGroups.raid
        LayoutKey = Grid2Layout.partyType or "raid10"

        --print("You are in a Raid, size: "..currPlayers)
        if (maxPlayers == 10) then
            --print("You are in a 10 person raid")
            NewLayout = "By Group 10"
        elseif (maxPlayers == 20) then
            --print("You are in a 20 person raid")
            NewLayout = "By Group 20"
        elseif (maxPlayers == 25) then
            --print("You are in a 25 person raid")
            NewLayout = "By Group 25"
        end
    -- World group/Flex Raid
    else
        --print("You are not in an instance")
        LayoutKey = Grid2Layout.partyType or "party"

        local difficulty = GetRaidDifficultyID()
        local groupSize = GetNumGroupMembers()

        -- Solo
        if groupSize == 0 then
            NewHoriz = LayoutDB.hGroups.normal
            if LayoutDB.showSolo then
                if UnitExists("pet") and LayoutDB.showPet then 
                    NewLayout = "By Group 5 w/Pets"
                else
                    NewLayout = "By Group 5"
                end
            else
                NewLayout = "None"
            end

        -- Group
        else
            NewHoriz = LayoutDB.hGroups.raid

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
            
            if (raidGroupInUse.group8 or raidGroupInUse.group7) then
                --print("Group 7 & 8 in use")
                NewLayout = "By Group 40"
            elseif raidGroupInUse.group6 then
                --print("Group 6 in use")
                NewLayout = "By Group 30"
            elseif raidGroupInUse.group5 then
                --print("Group 5 in use")
                NewLayout = "By Group 25"
            elseif raidGroupInUse.group4 then
                --print("Group 4 in use")
                NewLayout = "By Group 20"
            elseif raidGroupInUse.group3 then
                --print("Group 3 in use")
                NewLayout = "By Group 15"
            elseif raidGroupInUse.group2 then
                --print("Group 2 in use")
                NewLayout = "By Group 10"
            else
                --print("Only group 1 in use")
                NewLayout = "By Group 5"
            end
        end
    end
    
    -- Change Grid Layout
    --print("Set group:", NewLayout, Grid2Layout.partyType)
    if ( NewLayout and ((NewLayout ~= Grid2Layout.db.profile.layouts[LayoutKey]) or (NewHoriz ~= Grid2Layout.db.profile.horizontal)) ) then
        --print("Apply group:", NewLayout)
        Grid2Layout.db.profile.layouts[LayoutKey] = NewLayout
        Grid2Layout.db.profile.horizontal = NewHoriz
        Grid2Layout:ReloadLayout()
    end

    -- Adjust Grid Frame Width
    local layoutSize = tonumber(NewLayout:match("%d+"))
    --print("layoutSize:", layoutSize)
    if (LayoutDB.width[layoutSize]) and not NewHoriz then
        SetGridFrameWidth(LayoutDB.width[layoutSize])
    else
        SetGridFrameWidth(LayoutDB.width["normal"])
    end

    -- FrameMover
    if nibRealUI:GetModuleEnabled("FrameMover") then
        local FM = nibRealUI:GetModule("FrameMover", true)
        if FM then FM:MoveAddons() end
    end
end

function nibRealUI:SetGridLayoutSettings(value, key1, key2, key3)
    --print("GetGridLayoutSettings", key1, key2, key3, type(db[key1][key2]))
    if key3 then
        db[key1][key2][key3] = value
    else
        db[key1][key2] = value
    end
    GridLayout:Update()
end

function nibRealUI:GetGridLayoutSettings(key1, key2, key3)
    -- print("GetGridLayoutSettings", key1, key2, key3, type(db[key1][key2]))
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
                width = {normal = 65, [30] = 54, [40] = 40},
                hGroups = {normal = true, raid = false, bg = false},
                showPet = true,
                showSolo = false,
            },
            healing = {
                width = {normal = 65, [30] = 54, [40] = 40},
                hGroups = {normal = false, raid = false, bg = false},
                showPet = true,
                showSolo = false,
            },
        },
    })
    db = self.db.profile

    -- Remove after some time.
    if type(db.dps.width) == "number" then
        db.dps.width = {
            normal = db.dps.width
        }
    end
    if db.dps.sWidth then
        db.dps.width[40] = db.dps.sWidth
        db.dps.sWidth = nil
    end
    if type(db.healing.width) == "number" then
        db.healing.width = {
            normal = db.healing.width
        }
    end
    if db.healing.sWidth then
        db.healing.width[40] = db.healing.sWidth
        db.healing.sWidth = nil
    end

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
