local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI
local db

local CombatFader = RealUI:GetModule("CombatFader")

local MODNAME = "Objectives Adv."
local ObjectivesAdv = RealUI:NewModule(MODNAME, "AceEvent-3.0")

local LoggedIn = false

---------------------
-- Collapse / Hide --
---------------------
-- Hide Quest Tracker based on zone
function ObjectivesAdv:UpdateHideState()
    local Hide = false
    local _, instanceType = _G.GetInstanceInfo()

    if db.hidden.enabled and (instanceType ~= "none") and RealUI:GetModuleEnabled(MODNAME) then
        if (instanceType == "pvp" and db.hidden.hide.pvp) then          -- Battlegrounds
            Hide = true
        elseif (instanceType == "arena" and db.hidden.hide.arena) then  -- Arena
            Hide = true
        elseif (((instanceType == "party") or (instanceType == "scenario")) and db.hidden.hide.party) then  -- 5 Man Dungeons
            Hide = true
        elseif (instanceType == "raid" and db.hidden.hide.raid) then    -- Raid Dungeons
            Hide = true
        end
    end
    if Hide then
        self.hidden = true
        _G.ObjectiveTrackerFrame.realUIHidden = true
        _G.ObjectiveTrackerFrame:Hide()
    else
        local oldHidden = self.hidden
        self.hidden = false
        _G.ObjectiveTrackerFrame.realUIHidden = false
        _G.ObjectiveTrackerFrame:Show()

        -- Refresh fade, since fade won't update while hidden
        local CF = RealUI:GetModule("CombatFader", 1)
        if oldHidden and RealUI:GetModuleEnabled("CombatFader") and CF then
            CF:UpdateStatus(true)
        end
    end
end

-- Collapse Quest Tracker based on zone
function ObjectivesAdv:UpdateCollapseState()
    local Collapsed = false
    local instanceName, instanceType = _G.GetInstanceInfo()
    local isInGarrison = instanceName:find("Garrison")

    if db.hidden.enabled and (instanceType ~= "none") and RealUI:GetModuleEnabled(MODNAME) then
        if (instanceType == "pvp" and db.hidden.collapse.pvp) then          -- Battlegrounds
            Collapsed = true
        elseif (instanceType == "arena" and db.hidden.collapse.arena) then  -- Arena
            Collapsed = true
        elseif (((instanceType == "party" and not isInGarrison) or (instanceType == "scenario")) and db.hidden.collapse.party) then -- 5 Man Dungeons
            Collapsed = true
        elseif (instanceType == "raid" and db.hidden.collapse.raid) then    -- Raid Dungeons
            Collapsed = true
        end
    end

    if Collapsed then
        self.collapsed = true
        _G.ObjectiveTrackerFrame.userCollapsed = true
        _G.ObjectiveTracker_Collapse()
    else
        self.collapsed = false
        _G.ObjectiveTrackerFrame.userCollapsed = false
        _G.ObjectiveTracker_Expand()
    end
end

function ObjectivesAdv:UpdatePlayerLocation()
    self:UpdateCollapseState()
    self:UpdateHideState()
end

------------------
---- Position ----
------------------
-- Position
function ObjectivesAdv:UpdatePosition()
    if not (db.position.enabled and RealUI:GetModuleEnabled(MODNAME)) then return end

    if not self.origSet then
        self.origSet = _G.ObjectiveTrackerFrame.SetPoint
        self.origClear = _G.ObjectiveTrackerFrame.ClearAllPoints

        _G.ObjectiveTrackerFrame.SetPoint = function() end
        _G.ObjectiveTrackerFrame.ClearAllPoints = function() end
    end

    self.origClear(_G.ObjectiveTrackerFrame)
    self.origSet(_G.ObjectiveTrackerFrame, db.position.anchorfrom, "UIParent", db.position.anchorto, db.position.x, db.position.y)

    _G.ObjectiveTrackerFrame:SetHeight(_G.UIParent:GetHeight() - db.position.negheightofs)

    --ObjectiveTrackerFrame.HeaderMenu.MinimizeButton:SetPoint("TOPRIGHT", ObjectiveTrackerFrame, "TOPRIGHT", -12, -1)
end


-----------------------
function ObjectivesAdv:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end

    self:UpdatePosition()
end

function ObjectivesAdv:UI_SCALE_CHANGED()
    self:UpdatePosition()
end

function ObjectivesAdv:PLAYER_ENTERING_WORLD()
    ObjectivesAdv:UpdatePlayerLocation()
end

function ObjectivesAdv:PLAYER_LOGIN()
    LoggedIn = true
    self:RefreshMod()
    --self:Skin()
end

function ObjectivesAdv:OnInitialize()
    self.db = RealUI.db:RegisterNamespace(MODNAME)
    self.db:RegisterDefaults({
        profile = {
            position = {
                enabled = true,
                anchorto = "TOPRIGHT",
                anchorfrom = "TOPRIGHT",
                x = -32,
                y = -200,
                negheightofs = 300,
            },
            hidden = {
                enabled = true,
                collapse = {
                    pvp = true,
                    arena = false,
                    party = true,
                    raid = false,
                },
                hide = {
                    pvp = false,
                    arena = true,
                    party = false,
                    raid = true,
                },
                combatfade = {
                    enabled = true,
                    opacity = {
                        incombat = 0.25,
                        hurt = .75,
                        target = .75,
                        harmtarget = 0.85,
                        outofcombat = 1,
                    },
                },
            },
        },
    })
    db = self.db.profile

    self:SetEnabledState(RealUI:GetModuleEnabled(MODNAME))

    CombatFader:RegisterModForFade(MODNAME, db.hidden.combatfade)
    CombatFader:RegisterFrameForFade(MODNAME, _G.ObjectiveTrackerFrame)

    self:RegisterEvent("PLAYER_LOGIN")
end

function ObjectivesAdv:OnEnable()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("UI_SCALE_CHANGED")

    if LoggedIn then self:RefreshMod() end
end

function ObjectivesAdv:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("UI_SCALE_CHANGED")
end
