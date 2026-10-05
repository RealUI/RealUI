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
-- Position (Task 2)
---------------------------------------------------------
--[[ tracker-widget-taint-rewrite 5.1, 2026-10-05: the container wrapper is
     gone. SetupContainer used to reparent ObjectiveTrackerFrame into a
     RealUI_TrackerFrame and replace OTF.SetParent with a no-op so nothing
     could move it back. That field was an addon-owned plant on a secure
     frame (tracker taint doctrine R1): every later SetParent call Blizzard
     made on the tracker (the right-side managed-frame container does) read a
     RealUI value and ran tainted. Nothing anchored to RealUI_TrackerFrame;
     it only followed OTF's rect (SetAllPoints), so it went too.
     Edit Mode (system 12) owns the tracker's position and parent. The only
     position code left is the user-initiated seed below. ]]

-- Session-local gate for the one-time seeding of the user's stored
-- tracker position into the EditMode layout. Set to true after the
-- first successful seed write so later calls within the same session
-- never re-seed (even if the user later reverts the EditMode anchor to
-- the template default).
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

-- 2.5b: One-time seeding of the user's stored tracker position into the active
-- RealUI EditMode layout. Must only be called from an explicitly user-initiated
-- flow (install wizard / config action), never from an event handler: a layout
-- write from UI_SCALE_CHANGED / DISPLAY_SIZE_CHANGED / EDIT_MODE_LAYOUTS_UPDATED
-- fires C_EditMode.SaveLayouts at login and taints EditModeManagerFrame.layoutInfo
-- for the session (CooldownViewer then threw on every UNIT_AURA, attributed to
-- RealUI_Tracker). The wizard opens a write scope and ends with a reload.
--
-- Local name `pos` (NOT `db`) avoids the historical
-- `db.profile.position.enabled` shadow bug where a local named `db` aliased the
-- AceDB root and made `db.enabled` silently nil-dereference instead of
-- resolving to position.enabled.
-- @return boolean  true if an anchor was written
function RealUI_Tracker:SeedPositionIntoEditMode()
    if private.trackerSeedingDone then return false end

    local pos = self.db.profile.position
    local EMM = RealUI and RealUI.EditModeManager
    local sysInfo = EMM and EMM:GetActiveRealUITrackerSystemInfo()

    if not (pos.enabled and sysInfo and isDefaultAnchor(sysInfo.anchorInfo)) then
        return false
    end

    private.trackerSeedingDone = true

    EMM:BeginUserWrite()
    EMM:SetTrackerAnchor(pos.anchorFrom, pos.anchorTo, pos.x, pos.y)
    EMM:EndUserWrite()

    return true
end
