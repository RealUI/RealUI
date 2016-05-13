local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "WorldMarker"
local WorldMarker = RealUI:NewModule(MODNAME, "AceEvent-3.0", "AceBucket-3.0")

local LoggedIn = false

local WMF = {}

local ButtonWidthExpanded = 18
local ButtonWidthCollapsed = 3

local NeedRefreshed, FramesCreated

local MarkerColors = {
    {0.98, 0.98, 0.98, 0.8}, --White  RaidTargetingIcon_8
    {1.0,  0.24, 0.17, 0.8}, --Red    RaidTargetingIcon_7
    {0.0,  0.71, 1.0,  0.8}, --Blue   RaidTargetingIcon_6
    {0.7,  0.82, 0.87, 0.8}, --Silver RaidTargetingIcon_5
    {0.04, 0.95, 0.0,  0.8}, --Green  RaidTargetingIcon_4
    {0.83, 0.22, 0.9,  0.8}, --Purple RaidTargetingIcon_3
    {0.98, 0.57, 0.0,  0.8}, --Orange RaidTargetingIcon_2
    {1.0,  0.92, 0.0,  0.8}, --Yellow RaidTargetingIcon_1
    {0.3,  0.3,  0.3,  0.8}, --Clear all
}

-- OnLeave
local function ButtonOnLeave(index)
    WMF.Buttons[index].mouseover = false
    WorldMarker:HighlightUpdate(WMF.Buttons[index])
end

-- OnEnter
local function ButtonOnEnter(index)
    WMF.Buttons[index].mouseover = true
    WorldMarker:HighlightUpdate(WMF.Buttons[index])
end

-- Toggle visibility of World Marker frame
function WorldMarker:UpdateVisibility()
    -- Refresh
    if ( (NeedRefreshed or not FramesCreated) and (not _G.InCombatLockdown()) ) then
        -- Mod needs refreshing
        WorldMarker:RefreshMod()
        return
    elseif _G.InCombatLockdown() then
        NeedRefreshed = true
        return
    end

    -- Should we hide the WM?
    local Hide = false
    if not RealUI:GetModuleEnabled(MODNAME) then Hide = true end
    local Inst, InstType = _G.IsInInstance()
    if Inst and not(Hide) then
        if (InstType == "pvp" and not(db.visibility.pvp)) then          -- Battlegrounds
            Hide = true
        elseif (InstType == "arena" and not(db.visibility.arena)) then  -- Arena
            Hide = true
        elseif (InstType == "party" and not(db.visibility.party)) then  -- 5 Man Dungeons
            Hide = true
        elseif (InstType == "raid" and not(db.visibility.raid)) then    -- Raid Dungeons
            Hide = true
        end
    end
    if not(Hide) and not( (_G.GetNumGroupMembers() > 0) and (_G.UnitIsGroupLeader("player") or _G.UnitIsGroupAssistant("player")) ) then
        Hide = true
    end

    -- Update visibility
    if not(Hide) then
        -- Viable to use World Markers
        if not WMF.Parent:IsShown() then
            WMF.Parent:Show()
        end
    else
        -- Not viable to use World Markers
        if WMF.Parent:IsShown() then
            WMF.Parent:Hide()
        end
    end
end

local function WorldMarker_oocUpdate()
    if NeedRefreshed then
        WorldMarker:RefreshMod()
    else
        WorldMarker:UpdateVisibility()
    end
end
function WorldMarker:UpdateLockdown(...)
    RealUI:RegisterLockdownUpdate("WorldMarker_oocUpdate", function()
        WorldMarker_oocUpdate()
    end)
end

function WorldMarker:HighlightUpdate(btn)
    btn.bg:SetWidth(btn.mouseover and ButtonWidthExpanded or ButtonWidthCollapsed)
end

-- Set World Marker Position
function WorldMarker:UpdatePosition()
    if not FramesCreated then return end

    local MMHeight = _G.Minimap:GetHeight()
    
    -- Parent
    WMF.Parent:ClearAllPoints()
    WMF.Parent:SetPoint("TOPLEFT", _G["Minimap"], "TOPRIGHT", 0, 0)
    WMF.Parent:SetFrameStrata("BACKGROUND")
    WMF.Parent:SetFrameLevel(5)
    
    WMF.Parent:SetWidth(ButtonWidthExpanded)
    WMF.Parent:SetHeight(MMHeight)
    
    local numBtns = #MarkerColors
    local totHeight, btnHeight = 0, _G.floor(MMHeight / numBtns) + 2
    for i = 1, numBtns do
        WMF.Buttons[i]:ClearAllPoints()
        if i == numBtns then
            WMF.Buttons[i]:SetPoint("TOPLEFT", WMF.Parent, "TOPLEFT", 0, -totHeight + 1)
            WMF.Buttons[i]:SetHeight(MMHeight - totHeight + 2)
            WMF.Buttons[i].bg:SetHeight(MMHeight - totHeight + 2)
        else
            WMF.Buttons[i]:SetPoint("TOPLEFT", WMF.Parent, "TOPLEFT", 0, -totHeight + 1)
            WMF.Buttons[i]:SetHeight(btnHeight)
            WMF.Buttons[i].bg:SetHeight(btnHeight)
        end
        WMF.Buttons[i]:SetWidth(ButtonWidthExpanded)
        totHeight = totHeight + btnHeight - 1
    end
end

-----------------
local function CreateButton(id)
    local frame = _G.CreateFrame("Button", "RealUI_WorldMarker_Button".._G.tostring(id), WMF.Parent, "SecureActionButtonTemplate")
    
    frame:SetAttribute("type", "macro")
    frame:SetScript("OnEnter", function(self) ButtonOnEnter(id) end)
    frame:SetScript("OnLeave", function(self) ButtonOnLeave(id) end)
    
    frame.bg = _G.CreateFrame("Frame", nil, frame)
    frame.bg:SetPoint("LEFT", frame, "LEFT", 0, 0)
    frame.bg:SetWidth(ButtonWidthCollapsed)
    RealUI:CreateBD(frame.bg, 0.8)
    local color = MarkerColors[id]
    frame.bg:SetBackdropColor(color[1], color[2], color[3], color[4])

    return frame
end

local function CreateFrames()
    if _G.InCombatLockdown() or FramesCreated then return end
    
    -- Parent Frame
    WMF.Parent = _G.CreateFrame("Frame", "RealUI_WorldMarker", _G["Minimap"])
    
    -- Buttons
    local numBtns = #MarkerColors
    WMF.Buttons = {}
    for i = 1, numBtns do
        if i == numBtns then
            --clear markers
            WMF.Buttons[i] = CreateButton(i)
            WMF.Buttons[i]:SetAttribute("macrotext", "/cwm all")
        else
            WMF.Buttons[i] = CreateButton(i)
            WMF.Buttons[i]:SetAttribute("macrotext", "/wm ".._G.WORLD_RAID_MARKER_ORDER[i])
        end
    end
    
    FramesCreated = true
end

---------------
function WorldMarker:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) or not _G.IsAddOnLoaded("Blizzard_CompactRaidFrames") then return end
    
    db = self.db.profile
    
    -- Create Frames if it has been delayed
    if not _G.InCombatLockdown() and not FramesCreated then
        CreateFrames()
    end
    
    -- Refresh Mod
    if _G.InCombatLockdown() or not FramesCreated then
        -- In combat or have no frames, set flag so we can refresh once combat ends
        NeedRefreshed = true
    else
        -- Ready to refresh
        NeedRefreshed = false
        
        WorldMarker:UpdatePosition()
        WorldMarker:UpdateVisibility()
    end
end

function WorldMarker:PLAYER_LOGIN()
    LoggedIn = true
    
    WorldMarker:RefreshMod()
    _G.hooksecurefunc(_G.Minimap, "SetSize", function() 
        if not(_G.InCombatLockdown()) then
            WorldMarker:UpdatePosition()
        end
    end)
end

function WorldMarker:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            visibility = {
                pvp = false,
                arena = false,
                party = true,
                raid = true,
            },
        },
    })
    db = self.db.profile
    
    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))
end

function WorldMarker:OnEnable()
    self:RegisterEvent("PLAYER_LOGIN")
    self:RegisterEvent("PLAYER_REGEN_ENABLED", "UpdateLockdown")
    self:RegisterBucketEvent({"PLAYER_ENTERING_WORLD", "UNIT_FLAGS", "PARTY_LEADER_CHANGED", "GROUP_ROSTER_UPDATE"}, 1, "UpdateVisibility")
    -- self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateVisibility")
    -- self:RegisterEvent("UNIT_FLAGS", "UpdateVisibility")
    -- self:RegisterEvent("PARTY_LEADER_CHANGED", "UpdateVisibility")
    -- self:RegisterEvent("GROUP_ROSTER_UPDATE", "UpdateVisibility")

    if LoggedIn then WorldMarker:RefreshMod() end
end

function WorldMarker:OnDisable()
    self:UnregisterEvent("PLAYER_LOGIN")
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    self:UnregisterEvent("UNIT_FLAGS")
    self:UnregisterEvent("PARTY_LEADER_CHANGED")
    self:UnregisterEvent("GROUP_ROSTER_UPDATE")

    NeedRefreshed = false
    
    if _G.InCombatLockdown() then
        -- Trying to disable while in combat. Display message and block mouse input to World Markers.
        _G.print("|cff00ffffRealUI: |r World Marker can't fully disable during combat. Please wait until you leave combat, then reload the UI (type: /rl)")
    else    
        WorldMarker:UpdateVisibility()
    end
end
