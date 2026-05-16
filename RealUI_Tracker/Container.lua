local ADDON_NAME, private = ...
local RealUI_Tracker = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)

-- Core RealUI addon. Captured at file load via the global because
-- RealUI_Tracker is a separate AceAddon — its `private` namespace is
-- distinct from RealUI core's `private`. Other tracker files use the
-- same `_G.RealUI` access pattern (see RealUI_Tracker.lua).
local RealUI = _G.RealUI

-- EditMode system enum value for ObjectiveTracker. The corresponding
-- constant in EditModeTemplates.lua / EditModeManager.lua is `local`
-- and not exported, so each consuming file declares its own copy.
local SYSTEM_OBJECTIVE_TRACKER = 12

---------------------------------------------------------
-- Competing addon detection (Task 3)
---------------------------------------------------------
local COMPETING_ADDONS = {
    { name = "!KalielsTracker",       display = "Kaliel's Tracker" },
    { name = "AscensionQuestTracker", display = "Ascension Quest Tracker" },
    { name = "EskaQuestTracker",      display = "Eska Quest Tracker" },
}

function RealUI_Tracker:CheckForConflicts()
    for _, entry in ipairs(COMPETING_ADDONS) do
        if C_AddOns.IsAddOnLoaded(entry.name) then
            print("|cffff6600RealUI Tracker:|r disabled — conflicts with "
                .. entry.display .. ". Uninstall it to use RealUI Tracker.")
            self:SetEnabledState(false)
            return true
        end
    end
    return false
end

---------------------------------------------------------
-- Container wrapper (Task 2)
---------------------------------------------------------
local container
local OTF

-- Session-local gate for the one-time seeding of the user's stored
-- tracker position into the EditMode layout. Set to true after the
-- first successful seed write so subsequent UpdatePosition calls
-- within the same session never re-seed (even if the user later
-- reverts the EditMode anchor to the template default).
private.trackerSeedingDone = false

-- Walks Templates.base (a sequential array, NOT keyed by system number)
-- and returns the anchorInfo for the ObjectiveTracker entry. Returns
-- nil if EditModeTemplates is not loaded or the entry is missing.
local function getDefaultObjectiveTrackerAnchor()
    local templates = RealUI and RealUI.EditModeTemplates and RealUI.EditModeTemplates.base
    if not templates then return nil end
    for _, entry in ipairs(templates) do
        if entry.system == SYSTEM_OBJECTIVE_TRACKER then
            return entry.anchorInfo
        end
    end
    return nil
end

-- Compares the live EditMode anchor for system 12 byte-for-byte against
-- the template default. Returns false if either side is nil.
local function isDefaultAnchor(currentAnchorInfo)
    if not currentAnchorInfo then return false end
    local defaults = getDefaultObjectiveTrackerAnchor()
    if not defaults then return false end
    return currentAnchorInfo.point         == defaults.point
       and currentAnchorInfo.relativeTo    == defaults.relativeTo
       and currentAnchorInfo.relativePoint == defaults.relativePoint
       and currentAnchorInfo.offsetX       == defaults.offsetX
       and currentAnchorInfo.offsetY       == defaults.offsetY
end

function RealUI_Tracker:SetupContainer()
    container = CreateFrame("Frame", "RealUI_TrackerFrame", UIParent)
    container:SetFrameStrata("MEDIUM")

    OTF = _G.ObjectiveTrackerFrame

    -- NOTE: We deliberately do NOT call OTF:ClearAllPoints() / OTF:SetPoint(...)
    -- here. OTF's anchor is owned by EditMode (system 12, anchored to UIParent).
    -- Inverted anchoring in UpdatePosition (RealUI_TrackerFrame:SetAllPoints(OTF))
    -- makes the container track OTF's rect rather than driving OTF's position.
    OTF:SetParent(container)

    private.origSetParent = OTF.SetParent
    OTF.SetParent = function() end

    -- 2.4: SetPoint hook removed in v3 migration.
    -- Previously a hooksecurefunc(OTF, "SetPoint", ...) re-anchored OTF to
    -- RealUI_TrackerFrame on every SetPoint call. That hook caused two bugs:
    --   * Bug A — `secureexecuterange` warning: EditMode read back the saved
    --     anchor `relativeTo = "RealUI_TrackerFrame"`, a name not in EditMode's
    --     standard target set, producing
    --     "ObjectiveTrackerFrame:SetPoint(): Couldn't find region named 'RealUI_TrackerFrame'".
    --   * Bug B — periodic disappearance: between EditMode clearing OTF's
    --     points and our hook re-anchoring, OTF was momentarily un-anchored,
    --     letting it drift off-screen and apparently "disappear".
    -- Inverted anchoring (RealUI_TrackerFrame:SetAllPoints(OTF) in
    -- UpdatePosition) eliminates the un-anchored intermediate state entirely:
    -- OTF stays anchored to UIParent (whatever EditMode last set), and the
    -- container passively follows OTF's rect.
    -- DO NOT reintroduce a SetPoint hook on OTF here — doing so will bring
    -- back BOTH Bug A and Bug B. If a future feature needs to influence OTF's
    -- position, route it through EditModeManager:SetTrackerAnchor instead so
    -- the change is recorded in the EditMode layout (relativeTo = "UIParent").

    -- 2.5 / 2.6: Apply initial position and register scale/display events
    self:UpdatePosition()
    self:RegisterEvent("UI_SCALE_CHANGED", "UpdatePosition")
    self:RegisterEvent("DISPLAY_SIZE_CHANGED", "UpdatePosition")
    -- Handler ordering with EditMode: EditMode registers
    -- EDIT_MODE_LAYOUTS_UPDATED at AddOn load (early); RealUI_Tracker
    -- registers it here at PLAYER_LOGIN (late). Frame event dispatch
    -- order matches registration order, so EditMode's UpdateSystems
    -- runs before our UpdatePosition and OTF's anchor is fresh by the
    -- time we call SetAllPoints(OTF).
    self:RegisterEvent("EDIT_MODE_LAYOUTS_UPDATED", "UpdatePosition")

    private.containerSetUp = true
end

-- 2.5: UpdatePosition — under inverted anchoring, the container's rect
-- tracks OTF's rect and OTF's position/size is owned by EditMode
-- (system 12). The user's stored db.profile.position values are no
-- longer applied to the container directly; instead they are used by
-- the seeding gate below to write the user's anchor into the active
-- RealUI EditMode layout exactly once per session, and only when the
-- live EditMode anchor still matches the template default (i.e. the
-- user has not customized the tracker position via EditMode UI).
function RealUI_Tracker:UpdatePosition()
    if not container then return end

    -- Inverted anchoring: container's rect tracks OTF's rect.
    -- OTF's position/size is owned by EditMode (system 12).
    _G.RealUI_TrackerFrame:ClearAllPoints()
    _G.RealUI_TrackerFrame:SetAllPoints(_G.ObjectiveTrackerFrame)

    -- One-time seeding of the user's stored position into the active
    -- RealUI EditMode layout. Local name `pos` (NOT `db`) avoids the
    -- historical `db.profile.position.enabled` shadow bug where a
    -- local named `db` aliased the AceDB root and made `db.enabled`
    -- silently nil-dereference instead of resolving to position.enabled.
    if not private.trackerSeedingDone then
        local pos = self.db.profile.position
        local EMM = RealUI and RealUI.EditModeManager
        local sysInfo = EMM and EMM:GetActiveRealUITrackerSystemInfo()
        if pos.enabled and sysInfo and isDefaultAnchor(sysInfo.anchorInfo) then
            private.trackerSeedingDone = true
            EMM:SetTrackerAnchor(pos.anchorFrom, pos.anchorTo, pos.x, pos.y)
        end
    end
end

-- 2.7: Cleanup on disable
function RealUI_Tracker:CleanupContainer()
    if not private.containerSetUp then return end

    -- Unregister scale/display events
    self:UnregisterEvent("UI_SCALE_CHANGED")
    self:UnregisterEvent("DISPLAY_SIZE_CHANGED")
    self:UnregisterEvent("EDIT_MODE_LAYOUTS_UPDATED")

    -- Restore SetParent and reparent back to UIParent
    if private.origSetParent then
        OTF.SetParent = private.origSetParent
        private.origSetParent = nil
    else
        OTF.SetParent = nil
    end

    OTF:SetParent(UIParent)
    OTF:ClearAllPoints()
    OTF:SetPoint("TOPRIGHT", UIParent, "TOPRIGHT", -14, -200)

    private.containerSetUp = false
end
