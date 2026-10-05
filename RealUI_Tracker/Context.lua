local ADDON_NAME, private = ...
local RealUI_Tracker = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)

---------------------------------------------------------
-- Context hide (Task 5)
-- Migrated from ObjectivesAdv with key renames:
--   self.db.profile → RealUI_Tracker.db.profile.context
--   db.hidden.*     → db.context.*
---------------------------------------------------------

--[[ tracker-widget-taint-rewrite 5.2 (D1, D2), 2026-10-05.

     This used to write `realUIHidden` onto ObjectiveTrackerFrame and
     `userCollapsed` onto the tracker modules, and call Hide/Show and
     SetCollapsed on them from RealUI code. The fields were plants (tracker
     taint doctrine R1), and the calls ran Blizzard's tracker layout inside
     RealUI's execution (R3): OnHide/OnShow re-lay out the right-side
     managed-frame container, OnShow runs the container's UpdateHeight, and
     SetCollapsed writes `isCollapsed` and marks the tracker dirty.

     Now the per-instance hide is a fade: SetAlpha(0) on entering a chosen
     instance type, SetAlpha(1) on leaving, with CombatFader told to leave the
     tracker's alpha alone meanwhile (CombatFader:SetFrameHidden). A method
     call that runs no Blizzard layout. The blocks keep taking clicks where they
     sit. A real Hide() was tried and dropped (owner, 2026-10-05): it taints the
     tracker, and Blizzard's container Update calls Show() again whenever a
     module has content (Blizzard_ObjectiveTrackerContainer.lua:99-108), so it
     never stuck.

     The per-instance module collapse is dropped (D2): there is no version of
     SetCollapsed that does not lay the tracker out under RealUI taint. The
     player collapses with Blizzard's own header buttons. ]]

-- Whether the fade is applied right now. Module state, never a field on a
-- Blizzard frame.
local applied = false

local function GetCombatFader()
    local RealUI_Core = _G.RealUI
    return RealUI_Core and RealUI_Core:GetModule("CombatFader", true)
end

-- Stop (true) or resume (false) CombatFader on the tracker. Resuming makes
-- CombatFader re-evaluate the tracker's alpha straight away.
local function SetFaderHidden(hidden)
    local CombatFader = GetCombatFader()
    if CombatFader and CombatFader.SetFrameHidden then
        CombatFader:SetFrameHidden(_G.ObjectiveTrackerFrame, hidden)
    end
end

local function Apply()
    SetFaderHidden(true)
    _G.ObjectiveTrackerFrame:SetAlpha(0)
    applied = true
end

local function Release()
    -- Full alpha first: the final value when combat fade is off, and the
    -- starting point CombatFader tweens from when it is on.
    _G.ObjectiveTrackerFrame:SetAlpha(1)
    applied = false
    SetFaderHidden(false)
end

-- Whether the current instance asks for the fade.
local function Wanted(ctx)
    if not ctx.enabled then return false end
    local _, instanceType = GetInstanceInfo()
    if instanceType == "none" or not ctx.hide[instanceType] then return false end
    -- 4.7: Garrison maps always bypass the hide
    if C_Garrison.IsOnGarrisonMap() then return false end
    return true
end

-- 5.3: UpdateState — reads db.context, applies the fade per instance type.
-- Only changes are applied, so a zone change inside the same state does
-- nothing to the tracker.
function RealUI_Tracker:UpdateState()
    local wanted = Wanted(self.db.profile.context)
    if wanted == applied then return end
    if wanted then Apply() else Release() end
end

-- 5.4: SetupContext — registers PLAYER_ENTERING_WORLD to call UpdateState
function RealUI_Tracker:SetupContext()
    self:RegisterEvent("PLAYER_ENTERING_WORLD", "UpdateState")
    private.contextSetUp = true
end

-- Cleanup: unregister context events and give the tracker back
function RealUI_Tracker:CleanupContext()
    if not private.contextSetUp then return end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    if applied then Release() end
    private.contextSetUp = false
end
