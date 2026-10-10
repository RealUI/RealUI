local ADDON_NAME, private = ...
local RealUI_Tracker = LibStub("AceAddon-3.0"):GetAddon(ADDON_NAME)

---------------------------------------------------------
-- Context fades (Task 5)
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

     Now every hide is a fade: SetAlpha on the tracker, with CombatFader told
     to leave the tracker's alpha alone meanwhile (CombatFader:SetFrameHidden).
     A method call that runs no Blizzard layout. The blocks keep taking clicks
     where they sit. A real Hide() was tried and dropped (owner, 2026-10-05): it
     taints the tracker, and Blizzard's container Update calls Show() again
     whenever a module has content (Blizzard_ObjectiveTrackerContainer.lua:99-108),
     so it never stuck.

     The per-instance module collapse is dropped (D2): there is no version of
     SetCollapsed that does not lay the tracker out under RealUI taint. The
     player collapses with Blizzard's own header buttons.

     2026-10-10: two more reasons to fade, decided in one place (Desired):
       "hidden"  alpha 0: a chosen instance type, or a boss encounter
       "idle"    the mouseover alpha: out of combat, mouse not over the tracker
       nil       CombatFader owns the alpha (or full alpha if it is off) ]]

-- The state applied right now. Module state, never a field on a Blizzard frame.
local applied
local inEncounter, inCombat, hovered = false, false, false

-- Hover is held this long after the mouse leaves, so the tracker does not
-- flicker while the pointer crosses a gap between blocks.
local HOVER_GRACE = 0.5
local POLL_INTERVAL = 0.1

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

-- Whether the current instance asks for the fade.
local function InstanceWanted(ctx)
    if not ctx.enabled then return false end
    local _, instanceType = _G.GetInstanceInfo()
    if instanceType == "none" or not ctx.hide[instanceType] then return false end
    -- 4.7: Garrison maps always bypass the hide
    if _G.C_Garrison.IsOnGarrisonMap() then return false end
    return true
end

-- Whether a boss encounter asks for the fade. Not in a running keystone: the
-- Mythic+ timer is part of the tracker.
local function BossWanted(ctx)
    if not (ctx.bossFade and inEncounter) then return false end
    local challenge = _G.C_ChallengeMode
    if challenge and challenge.IsChallengeModeActive and challenge.IsChallengeModeActive() then
        return false
    end
    return true
end

local function Desired()
    local profile = RealUI_Tracker.db.profile
    if InstanceWanted(profile.context) or BossWanted(profile.context) then
        return "hidden"
    end
    if profile.mouseover.enabled and not inCombat and not hovered then
        return "idle"
    end
    return nil
end

-- 5.3: UpdateState — applies the wanted state. Only changes are applied, so a
-- zone change inside the same state does nothing to the tracker.
function RealUI_Tracker:UpdateState()
    local wanted = Desired()
    if wanted == applied then return end

    local tracker = _G.ObjectiveTrackerFrame
    if wanted then
        SetFaderHidden(true)
        tracker:SetAlpha(wanted == "hidden" and 0 or self.db.profile.mouseover.alpha)
    else
        -- Full alpha first: the final value when combat fade is off, and the
        -- starting point CombatFader tweens from when it is on.
        tracker:SetAlpha(1)
        SetFaderHidden(false)
    end
    applied = wanted
end

---------------------------------------------------------
-- Mouseover polling
---------------------------------------------------------

-- A RealUI-owned driver reads whether the mouse is over the tracker. Nothing
-- is hooked on the tracker itself (doctrine rules 1 and 6).
local driver = _G.CreateFrame("Frame")
local sinceLastPoll, lastOver = 0, 0

local function Driver_OnUpdate(_, elapsed)
    sinceLastPoll = sinceLastPoll + elapsed
    if sinceLastPoll < POLL_INTERVAL then return end
    sinceLastPoll = 0

    local now = _G.GetTime()
    local tracker = _G.ObjectiveTrackerFrame
    if tracker:IsShown() and tracker:IsMouseOver() then
        lastOver = now
    end
    local over = (now - lastOver) < HOVER_GRACE
    if over ~= hovered then
        hovered = over
        RealUI_Tracker:UpdateState()
    end
end

-- Start or stop polling to match the setting.
function RealUI_Tracker:UpdateMouseover()
    if self.db.profile.mouseover.enabled then
        driver:SetScript("OnUpdate", Driver_OnUpdate)
    else
        driver:SetScript("OnUpdate", nil)
        hovered = false
    end
    -- Re-apply even when the state name is unchanged, so a new idle alpha
    -- takes effect straight away.
    if applied == "idle" then applied = false end
    self:UpdateState()
end

---------------------------------------------------------
-- Events
---------------------------------------------------------

function RealUI_Tracker:PLAYER_ENTERING_WORLD()
    inEncounter = _G.IsEncounterInProgress() and true or false
    inCombat = _G.InCombatLockdown() and true or false
    self:UpdateState()
end

function RealUI_Tracker:ENCOUNTER_START()
    inEncounter = true
    self:UpdateState()
end

function RealUI_Tracker:ENCOUNTER_END()
    inEncounter = false
    self:UpdateState()
end

function RealUI_Tracker:PLAYER_REGEN_DISABLED()
    inCombat = true
    self:UpdateState()
end

function RealUI_Tracker:PLAYER_REGEN_ENABLED()
    inCombat = false
    self:UpdateState()
end

-- 5.4: SetupContext — registers the events that change the wanted state
function RealUI_Tracker:SetupContext()
    self:RegisterEvent("PLAYER_ENTERING_WORLD")
    self:RegisterEvent("ENCOUNTER_START")
    self:RegisterEvent("ENCOUNTER_END")
    self:RegisterEvent("PLAYER_REGEN_DISABLED")
    self:RegisterEvent("PLAYER_REGEN_ENABLED")
    self:UpdateMouseover()
    private.contextSetUp = true
end

-- Cleanup: unregister context events and give the tracker back
function RealUI_Tracker:CleanupContext()
    if not private.contextSetUp then return end
    self:UnregisterEvent("PLAYER_ENTERING_WORLD")
    self:UnregisterEvent("ENCOUNTER_START")
    self:UnregisterEvent("ENCOUNTER_END")
    self:UnregisterEvent("PLAYER_REGEN_DISABLED")
    self:UnregisterEvent("PLAYER_REGEN_ENABLED")
    driver:SetScript("OnUpdate", nil)
    if applied then
        _G.ObjectiveTrackerFrame:SetAlpha(1)
        SetFaderHidden(false)
        applied = nil
    end
    private.contextSetUp = false
end
