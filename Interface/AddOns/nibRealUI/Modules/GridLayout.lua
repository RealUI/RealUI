local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local MODNAME = "GridLayout"
local GridLayout = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0")

local NeedUpdate = false
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

------------------------
---- Layout Updates ----
------------------------
function GridLayout:UpdateLockdown(...)
    if NeedUpdate then
        GridLayout:Update()
    end
end

-- Update Grid Layout
function GridLayout:Update()
    -- Combat Lockdown checking
    if InCombatLockdown() then
        NeedUpdate = true
        return
    end
    NeedUpdate = false
    
    local NewLayout, NewHoriz, layoutSize
    local partyType = Grid2Layout.partyType
    local Grid2DB = Grid2Layout.db.profile
    self:debug("partyType:", partyType)
    
   
    -- Which RealUI Layout we're working on
    local LayoutDB = (nibRealUI.cLayout == 1) and db.dps or db.healing
    
    -- Find new Grid Layout
    -- Solo - Adjust w/pets
    if partyType == "solo" then
        self:debug("You are Solo")
        NewHoriz = LayoutDB.hGroups.normal
        if LayoutDB.showSolo then
            if UnitExists("pet") and LayoutDB.showPet then 
                NewLayout = "Solo w/Pets"
            else
                NewLayout = "Solo"
            end
        else
            NewLayout = "None"
        end
    -- Party / Arena - Adjust w/pets
    elseif (partyType == "arena") or (partyType == "party") then
        self:debug("You are in a Party or Arena")
        NewHoriz = LayoutDB.hGroups.normal
        local HasPet = UnitExists("pet") or UnitExists("partypet1") or UnitExists("partypet2") or UnitExists("partypet3") or UnitExists("partypet4")
        if HasPet and LayoutDB.showPet then 
            NewLayout = "Party w/Pets"
        else
            NewLayout = "Party"
        end
    -- Raid
    elseif (partyType == "raid") then
        self:debug("You are in a Raid")
        NewHoriz = LayoutDB.hGroups.raid

        -- reset the table
        for k,v in pairs(raidGroupInUse) do
            raidGroupInUse[k] = false
        end
        
        -- find what groups are in use
        for i = 1, MAX_RAID_MEMBERS do
            local name, _, subGroup = GetRaidRosterInfo(i)
            if name and subGroup then
                raidGroupInUse["group"..subGroup] = true
            end
        end

        if (raidGroupInUse.group7 or raidGroupInUse.group8) then
            self:debug("Group 7 and/or 8 in use")
            layoutSize = 40
        elseif raidGroupInUse.group6 then
            self:debug("Group 6 in use")
            layoutSize = 30
        else
            self:debug("Group 1 - 5 in use")
            layoutSize = "normal"
        end
    end
    
    -- Change Grid Layout
    if (NewHoriz ~= Grid2DB.horizontal) then
        self:debug("Apply horizontal:", NewHoriz)
        Grid2DB.horizontal = NewHoriz
    end

    -- Adjust Grid Frame Width
    if (LayoutDB.width[layoutSize]) and not NewHoriz then
        self:debug("layout: Vert", layoutSize) --small
        Grid2Frame.db.profile.frameWidth = LayoutDB.width[layoutSize]
    else
        self:debug("layout: Horiz") --normal
        Grid2Frame.db.profile.frameWidth = LayoutDB.width["normal"]
    end

    Grid2Frame:LayoutFrames()

    --[[ FrameMover
    if nibRealUI:GetModuleEnabled("FrameMover") then
        local FM = nibRealUI:GetModule("FrameMover", true)
        if FM then FM:MoveAddons() end
    end]]
end

function nibRealUI:SetGridLayoutSettings(value, key1, key2, key3)
    GridLayout:debug("GetGridLayoutSettings", key1, key2, key3, type(db[key1][key2]))
    if key3 then
        db[key1][key2][key3] = value
    else
        db[key1][key2] = value
    end
    GridLayout:Update()
end

function nibRealUI:GetGridLayoutSettings(key1, key2, key3)
    GridLayout:debug("GetGridLayoutSettings", key1, key2, key3, type(db[key1][key2]))
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
    self:debug("OnEnable")
    if not(Grid2 and Grid2Layout and Grid2Frame) then return end
    local Grid2GroupChanged = Grid2.GroupChanged
    function Grid2:GroupChanged(...)
        GridLayout:Update()
        Grid2GroupChanged(self, ...)
    end
    
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLockdown")
end

function GridLayout:OnDisable()
    self:debug("OnDisable")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end
