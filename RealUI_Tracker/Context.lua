local ADDON_NAME, private = ...
local RealUI_Tracker = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)

---------------------------------------------------------
-- Context hide/collapse (Task 5)
-- Migrated from ObjectivesAdv with key renames:
--   self.db.profile → RealUI_Tracker.db.profile.context
--   db.hidden.*     → db.context.*
--   collapseframe.proffesion → collapseModules.professions
---------------------------------------------------------

-- 5.1: MODULES table mapping key names to tracker module globals
local MODULES = {
    quest       = _G.QuestObjectiveTracker,
    campaign    = _G.CampaignQuestObjectiveTracker,
    adventure   = _G.AdventureObjectiveTracker,
    professions = _G.ProfessionsRecipeTracker,
    bonus       = _G.BonusObjectiveTracker,
    world       = _G.WorldQuestObjectiveTracker,
}

-- 5.2: ResetState — restores hidden flag, uncollapse modules, refresh CombatFader
local function ResetState()
    local OTF = _G.ObjectiveTrackerFrame
    if RealUI_Tracker.trackerHidden and OTF.realUIHidden then
        RealUI_Tracker.trackerHidden = false
        OTF.realUIHidden = false
        OTF:Show()
        -- Refresh CombatFader so it can resume fading the now-visible frame
        local RealUI_Core = _G.RealUI
        if RealUI_Core then
            local CombatFader = RealUI_Core:GetModule("CombatFader", true)
            if CombatFader then CombatFader:UpdateStatus(true) end
        end
    end
    if RealUI_Tracker.trackerCollapsed then
        RealUI_Tracker.trackerCollapsed = false
        for key, module in pairs(MODULES) do
            if module.userCollapsed then
                module.userCollapsed = false
                module:SetCollapsed(false)
            end
        end
    end
end

-- 5.3: UpdateState — reads db.context, applies hide or collapse per instance type
function RealUI_Tracker:UpdateState()
    ResetState()

    local _, instanceType = GetInstanceInfo()
    local ctx = self.db.profile.context
    if not ctx.enabled or instanceType == "none" then return end

    -- 4.7: Garrison maps always bypass hide/collapse
    if C_Garrison.IsOnGarrisonMap() then return end

    if ctx.hide[instanceType] then
        self.trackerHidden = true
        _G.ObjectiveTrackerFrame.realUIHidden = true
        _G.ObjectiveTrackerFrame:Hide()
    elseif ctx.collapse[instanceType] then
        self.trackerCollapsed = true
        for key, module in pairs(MODULES) do
            if ctx.collapseModules[key] then
                module.userCollapsed = true
                module:SetCollapsed(true)
            end
        end
    end
end

-- 5.4: SetupContext — registers PLAYER_ENTERING_WORLD to call UpdateState
function RealUI_Tracker:SetupContext()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateState")
    private.contextSetUp = true
end

-- Cleanup: unregister context event
function RealUI_Tracker:CleanupContext()
    if not private.contextSetUp then return end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    -- Restore any hidden/collapsed state before tearing down
    ResetState()
    private.contextSetUp = false
end
