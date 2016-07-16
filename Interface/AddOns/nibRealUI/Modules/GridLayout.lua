local _, private = ...

-- Lua Globals --
local _G = _G
local next = _G.next

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "GridLayout"
local GridLayout = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceConsole-3.0")

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
    if _G.InCombatLockdown() then
        NeedUpdate = true
        return
    end
    NeedUpdate = false

    local NewLayout, isHoriz, layoutSize
    local Grid2DB = _G.Grid2Layout.db.profile
    self:debug("groupType:", groupType, _G.Grid2Layout)
    
   
    -- Which RealUI Layout we're working on
    local LayoutDB = (RealUI.cLayout == 1) and db.dps or db.healing
    
    -- Find new Grid Layout
    -- Solo - Adjust w/pets
    if groupType == "solo" then
        isHoriz = LayoutDB.hGroups.normal
        if LayoutDB.showSolo then
            self:debug("Show frames")
            if _G.UnitExists("pet") and LayoutDB.showPet then 
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
        local HasPet = _G.UnitExists("pet") or _G.UnitExists("partypet1") or _G.UnitExists("partypet2") or _G.UnitExists("partypet3") or _G.UnitExists("partypet4")
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
        for k,v in next, raidGroupInUse do
            raidGroupInUse[k] = false
        end
        
        -- find what groups are in use
        for i = 1, _G.MAX_RAID_MEMBERS do
            local name, _, subGroup = _G.GetRaidRosterInfo(i)
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
        _G.Grid2Frame.db.profile.frameWidth = LayoutDB.width[layoutSize]
    else
        self:debug("layout: Horiz") --normal
        _G.Grid2Frame.db.profile.frameWidth = LayoutDB.width["normal"]
    end

    --Grid2Layout:ReloadLayout(true)
end

function GridLayout:SettingsUpdate(event)
    self:Update(event or "SettingsUpdate", groupType, instType, instMaxPlayers)
    _G.Grid2Layout:ReloadLayout(true)
end

function GridLayout:Grid2ChatCommand()
    if not(_G.Grid2 and _G.Grid2Layout and _G.Grid2Frame and _G.Grid2DB) then return end
    if not _G.InCombatLockdown() then
        RealUI.Debug("Config", "/grid")
        RealUI:LoadConfig("HuD", "unitframes", "groups", "raid")
    end
end

function GridLayout:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
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


    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function GridLayout:OnEnable()
    self:debug("OnEnable")
    if not (_G.Grid2 and _G.Grid2Layout and _G.Grid2Frame) then return end

    local Grid2LayoutGroupChanged = _G.Grid2Layout.Grid_GroupTypeChanged
    function _G.Grid2Layout:Grid_GroupTypeChanged(...)
        GridLayout:debug("Grid_GroupTypeChanged", ...)
        GridLayout:Update(...)
        Grid2LayoutGroupChanged(self, ...)
    end
    
    _G.Grid2:UnregisterChatCommand("grid2")
    self:RegisterChatCommand("grid", "Grid2ChatCommand")
    self:RegisterChatCommand("grid2", "Grid2ChatCommand")

    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLockdown")
end

function GridLayout:OnDisable()
    self:debug("OnDisable")

    self:UnregisterChatCommand("grid")
    self:UnregisterChatCommand("grid2")
    _G.Grid2:RegisterChatCommand("grid2", "OnChatCommand")

    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
end
