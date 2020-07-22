local _, private = ...

-- RealUI --
local RealUI = private.RealUI
local db

local MODNAME = "Objectives Adv."
local ObjectivesAdv = RealUI:NewModule(MODNAME, "AceEvent-3.0")
local CombatFader = RealUI:GetModule("CombatFader")

---------------------
-- Collapse / Hide --
---------------------
local function ResetState()
    if ObjectivesAdv.hidden and _G.ObjectiveTrackerFrame.realUIHidden then
        ObjectivesAdv.hidden = false
        _G.ObjectiveTrackerFrame.realUIHidden = false
        _G.ObjectiveTrackerFrame:Show()

        -- Refresh fade, since fade won't update while hidden
        if RealUI:GetModuleEnabled("CombatFader") then
            CombatFader:UpdateStatus(true)
        end
    end

    if ObjectivesAdv.collapsed and _G.ObjectiveTrackerFrame.userCollapsed then
        ObjectivesAdv.collapsed = false
        _G.ObjectiveTracker_Expand()
    end
end
function ObjectivesAdv:UpdateState()
    ResetState()

    local _, instanceType = _G.GetInstanceInfo()
    if not db.hidden.enabled or instanceType == "none" then return end
    if _G.C_Garrison.IsOnGarrisonMap() then return end

    local hide = db.hidden.hide[instanceType] or false
    local collapse = db.hidden.collapse[instanceType] or false
    if hide then
        self.hidden = true
        _G.ObjectiveTrackerFrame.realUIHidden = true
        _G.ObjectiveTrackerFrame:Hide()
    elseif collapse then
        self.collapsed = true
        _G.ObjectiveTrackerFrame.userCollapsed = true
        _G.ObjectiveTracker_Collapse()
    end
end

------------------
---- Position ----
------------------
-- Position
local movingTracker = false
local function UpdatePosition()
    if movingTracker then return end

    movingTracker = true
    _G.ObjectiveTrackerFrame:ClearAllPoints()
    _G.ObjectiveTrackerFrame:SetPoint(db.position.anchorfrom, "UIParent", db.position.anchorto, db.position.x, db.position.y)
    _G.ObjectiveTrackerFrame:SetHeight(_G.UIParent:GetHeight() - db.position.negheightofs)
    movingTracker = false
end


-----------------------
function ObjectivesAdv:UI_SCALE_CHANGED()
    UpdatePosition()
end

function ObjectivesAdv:PLAYER_ENTERING_WORLD()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    self:UpdateState()
end

function ObjectivesAdv:ADDON_LOADED()
    if _G.ObjectiveTrackerFrame then
        self:RegisterEvent("PLAYER_ENTERING_WORLD")
        self:RegisterEvent("UI_SCALE_CHANGED")
        self:UnregisterEvent("ADDON_LOADED")

        _G.hooksecurefunc(_G.ObjectiveTrackerFrame, "SetPoint", UpdatePosition)
        CombatFader:RegisterFrameForFade(MODNAME, _G.ObjectiveTrackerFrame)

        self:RefreshMod()
    end
end

function ObjectivesAdv:RefreshMod()
    if not RealUI:GetModuleEnabled(MODNAME) then return end
    db = self.db.profile
    UpdatePosition()
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
                    scenario = false,
                    party = true,
                    raid = false,
                },
                hide = {
                    pvp = false,
                    arena = true,
                    scenario = false,
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
end

function ObjectivesAdv:OnEnable()
    CombatFader:RegisterModForFade(MODNAME, "profile", "hidden", "combatfade")

    if not _G.ObjectiveTrackerFrame then
        self:RegisterEvent("ADDON_LOADED")
    else
        self:ADDON_LOADED()
    end
end

function ObjectivesAdv:OnDisable()
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("UI_SCALE_CHANGED")
end
