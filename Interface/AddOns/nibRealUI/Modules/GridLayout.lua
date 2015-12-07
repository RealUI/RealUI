local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")
local db

local MODNAME = "GridLayout"
local GridLayout = nibRealUI:CreateModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0")

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
local groupType, instType, instMaxPlayers
function GridLayout:Update(_, newGroupType, newInstType, maxPlayers)
    self:debug("Update", _, newGroupType, newInstType, maxPlayers)
    groupType, instType, instMaxPlayers = newGroupType, newInstType, maxPlayers
    -- Combat Lockdown checking
    if InCombatLockdown() then
        NeedUpdate = true
        return
    end
    NeedUpdate = false

    local NewLayout, isHoriz, layoutSize
    local Grid2DB = Grid2Layout.db.profile
    self:debug("groupType:", groupType, Grid2Layout)
    
   
    -- Which RealUI Layout we're working on
    local LayoutDB = (nibRealUI.cLayout == 1) and db.dps or db.healing
    
    -- Find new Grid Layout
    -- Solo - Adjust w/pets
    if groupType == "solo" then
        isHoriz = LayoutDB.hGroups.normal
        if LayoutDB.showSolo then
            self:debug("Show frames")
            if UnitExists("pet") and LayoutDB.showPet then 
                self:debug("with pets")
                NewLayout = "Solo w/Pets"
            else
                NewLayout = "Solo"
            end
        else
            self:debug("Don't show frames")
            NewLayout = "None"
        end
    -- Party / Arena - Adjust w/pets
    elseif (groupType == "arena") or (groupType == "party") then
        isHoriz = LayoutDB.hGroups.normal
        local HasPet = UnitExists("pet") or UnitExists("partypet1") or UnitExists("partypet2") or UnitExists("partypet3") or UnitExists("partypet4")
        if HasPet and LayoutDB.showPet then 
            self:debug("Show pets")
            NewLayout = "Party w/Pets"
        else
            self:debug("Don't show pets")
            NewLayout = "Party"
        end
    -- Raid
    elseif (groupType == "raid") then
        isHoriz = LayoutDB.hGroups.raid

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
    self:debug("Check horizontal:", isHoriz, Grid2DB.horizontal)
    if isHoriz ~= nil and (isHoriz ~= Grid2DB.horizontal) then
        Grid2DB.horizontal = isHoriz
    end
    self:debug("Check layout:", NewLayout, Grid2DB.layouts[groupType])
    if NewLayout and (NewLayout ~= Grid2DB.layouts[groupType]) then
        Grid2DB.layouts[groupType] = NewLayout
    end

    -- Adjust Grid Frame Width
    if (LayoutDB.width[layoutSize]) and not isHoriz then
        self:debug("layout: Vert", layoutSize) --small
        Grid2Frame.db.profile.frameWidth = LayoutDB.width[layoutSize]
    else
        self:debug("layout: Horiz") --normal
        Grid2Frame.db.profile.frameWidth = LayoutDB.width["normal"]
    end

    --Grid2Layout:ReloadLayout(true)
end

function GridLayout:SettingsUpdate(event)
    self:Update(event or "SettingsUpdate", groupType, instType, instMaxPlayers)
    Grid2Layout:ReloadLayout(true)
end

function GridLayout:Grid2ChatCommand()
    if not(Grid2 and Grid2Layout and Grid2Frame and Grid2DB) then return end
    if not InCombatLockdown() then
        nibRealUI:LoadConfig("HuD", "unitframes", "groups", "raid")
    end
end

function GridLayout:OnInitialize()
    self.db = nibRealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            dps = {
                width = {normal = 65, [30] = 54, [40] = 40},
                hGroups = {normal = true, raid = false},
                showPet = true,
                showSolo = false,
            },
            healing = {
                width = {normal = 65, [30] = 54, [40] = 40},
                hGroups = {normal = false, raid = false},
                showPet = true,
                showSolo = false,
            },
        },
    })
    db = self.db.profile


    self:SetEnabledState(nibRealUI:GetModuleEnabled(MODNAME))
end

function GridLayout:OnEnable()
    self:debug("OnEnable")
    if not (Grid2 and Grid2Layout and Grid2Frame) then return end

    local Grid2LayoutGroupChanged = Grid2Layout.Grid_GroupTypeChanged
    function Grid2Layout:Grid_GroupTypeChanged(...)
        GridLayout:debug("Grid_GroupTypeChanged", ...)
        GridLayout:Update(...)
        Grid2LayoutGroupChanged(self, ...)
    end
    
    Grid2:UnregisterChatCommand("grid2")
    self:RegisterChatCommand("grid", "Grid2ChatCommand")
    self:RegisterChatCommand("grid2", "Grid2ChatCommand")

    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLockdown")
end

function GridLayout:OnDisable()
    self:debug("OnDisable")

    self:UnregisterChatCommand("grid")
    self:UnregisterChatCommand("grid2")
    Grid2:RegisterChatCommand("grid2", "OnChatCommand")

    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end
