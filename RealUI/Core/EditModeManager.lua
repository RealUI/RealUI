local _, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs table pcall CreateFrame InCombatLockdown C_EditMode C_AddOns C_Timer

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("EditModeManager")

---------------------------------------------------------------------------
-- EditMode Manager
-- Programmatically creates and applies Blizzard EditMode layouts via the
-- C_EditMode API. Integrates with LayoutManager, DisplayPresets, and
-- InstallWizard to keep Blizzard-managed frames positioned correctly.
---------------------------------------------------------------------------

local EditModeManager = {}
RealUI.EditModeManager = EditModeManager

---------------------------------------------------------------------------
-- State
---------------------------------------------------------------------------
local state = {
    initialized = false,
    layoutApplied = false,
    pendingLayout = nil,
    currentRole = nil,
    currentDisplayPreset = nil,
    layoutsCreated = false,
}

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------
local LAYOUT_NAMES = {
    dpstank = "RealUI",
    healing = "RealUI-Healing",
}

-- EditMode system enum value for ObjectiveTracker. Mirrors the local
-- constant in EditModeTemplates.lua, which is not exported. Any file that
-- needs this value must declare its own local copy (see also Container.lua).
local SYSTEM_OBJECTIVE_TRACKER = 12

---------------------------------------------------------------------------
-- CooldownViewer
-- Size, orientation, icon limit, etc. are configured via native EditMode
-- settings in EditModeTemplates.base (see "System 20" block there).
-- Blizzard's GridLayoutFrame:Layout() reads those settings from the active
-- layout and sizes both the viewer frame and its child icons correctly,
-- so no manual SetScale or child re-anchoring is needed.
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Internal Helpers
---------------------------------------------------------------------------

--- Number of built-in preset layouts (Modern, Classic). The
-- C_EditMode.SetActiveLayout(index) API uses an index into the combined
-- list [presets..., saved...], but C_EditMode.GetLayouts() returns the
-- saved layouts only (without presets). So to convert an index inside
-- data.layouts (saved) into the index SetActiveLayout expects, add this
-- offset.
local NUM_PRESET_LAYOUTS = 2

--- Finds the array index of a named layout within data.layouts
-- (saved-only array returned by C_EditMode.GetLayouts()).
-- @param data table  The data returned by C_EditMode.GetLayouts()
-- @param layoutName string  The layout name to search for
-- @param preferredType number|nil  Preferred layoutType (1=Account, 2=Character)
-- @return number|nil  Array index within data.layouts, or nil if not found
local function FindLayoutIndex(data, layoutName, preferredType)
    local fallbackIndex = nil
    for i, existing in ipairs(data.layouts) do
        if existing.layoutName == layoutName then
            if preferredType and existing.layoutType == preferredType then
                return i
            elseif not preferredType then
                return i
            else
                fallbackIndex = fallbackIndex or i
            end
        end
    end
    return fallbackIndex
end

--- Counts the number of keys in a table.
-- Used by the Step 5 defensive snapshot to verify that preserved-data
-- stores (`RealUI_TrackerDB.profile.position` and
-- `Bartender4DB.namespaces.ActionBars.profiles.<*>`) have not had their
-- key count change unexpectedly across the destructive Step 2 / Step 3
-- migration body.
--
-- We count keys (not memory addresses via `tostring(t)`) because Lua's
-- `tostring` on a table returns an opaque pointer string with no
-- relationship to content — a useless proxy for "did anything change".
-- A key-count delta is a cheap, content-aware diagnostic.
--
-- @param t any  Value to inspect
-- @return number  Key count (0 for non-tables and empty tables)
local function tableKeyCount(t)
    if type(t) ~= "table" then return 0 end
    local n = 0
    for _ in pairs(t) do n = n + 1 end
    return n
end

--- Snapshots key counts of every per-profile `position` table inside
-- `RealUI_TrackerDB`. Returns a map keyed by profile name with one
-- numeric entry per profile that has a `position` table. Profiles
-- without a `position` table contribute no entry.
--
-- Iterating all profiles (rather than identifying the active profile via
-- AceDB internals or `RealUI_TrackerDB.profileKeys[<charKey>]`) matches
-- the iteration model used by Step 2b's `maxHeightOffset` cleanup, so
-- the before/after snapshots cover exactly the same set of tables that
-- the destructive step touches.
--
-- @return table  { [profileName] = keyCount, ... }
local function snapshotTrackerPositionCounts()
    local counts = {}
    local trDB = _G.RealUI_TrackerDB
    if not (trDB and trDB.profiles) then return counts end
    for profileName, profile in pairs(trDB.profiles) do
        if type(profile) == "table" and type(profile.position) == "table" then
            counts[profileName] = tableKeyCount(profile.position)
        end
    end
    return counts
end

--- Snapshots key counts of every per-profile ActionBars table inside
-- `Bartender4DB.namespaces.ActionBars`. Returns a map keyed by profile
-- name with one numeric entry per profile.
--
-- The migration MUST NOT write to Bartender4DB (Req 8.5), so any
-- non-zero delta here is a real warning signal — unlike the Tracker
-- store, no expected change exists.
--
-- @return table  { [profileName] = keyCount, ... }
local function snapshotBartender4ProfileCounts()
    local counts = {}
    local btDB = _G.Bartender4DB
    if not (btDB and btDB.namespaces) then return counts end
    local ns = btDB.namespaces.ActionBars
    if not (ns and ns.profiles) then return counts end
    for profileName, profile in pairs(ns.profiles) do
        if type(profile) == "table" then
            counts[profileName] = tableKeyCount(profile)
        end
    end
    return counts
end

--- Processes a pending layout action from the queue.
-- @param pending table  The pending action descriptor
local function ProcessPending(pending)
    if not pending then return end

    if pending.action == "ensure" then
        EditModeManager:EnsureLayouts(pending.displayPresetId)
    elseif pending.action == "activate" then
        EditModeManager:ActivateLayout(pending.role)
    elseif pending.action == "apply" then
        EditModeManager:ApplyLayout(pending.role, pending.displayPresetId)
    elseif pending.action == "migrate" then
        EditModeManager:MigrateFromPreEditMode()
    elseif pending.action == "removePerChar" then
        EditModeManager:RemovePerCharacterLayouts()
    elseif pending.action == "trackerAnchor" then
        EditModeManager:SetTrackerAnchor(pending.point, pending.relativePoint, pending.x, pending.y)
    end
end

---------------------------------------------------------------------------
-- Layout Type Helpers
---------------------------------------------------------------------------

--- Returns the layoutType for the current character.
-- 2 = Character (per-character override), 1 = Account (default).
function EditModeManager:GetCurrentLayoutType()
    local dbc = RealUI.db and RealUI.db.char
    if dbc and dbc.editmode and dbc.editmode.perCharacter then
        return 2
    end
    return 1
end

--- Returns the saved-array index of the currently-active layout, but only
-- if it is one of the RealUI-managed layouts (LAYOUT_NAMES values).
-- Used by SetTrackerAnchor (and other future writers) to enforce the
-- sole-writer invariant: RealUI must never overwrite layout data while
-- the user is on a non-RealUI layout (preset or third-party custom).
--
-- data.activeLayout is an index into the combined [presets..., saved...]
-- list, while data.layouts contains saved layouts only. To map between
-- them, subtract NUM_PRESET_LAYOUTS.
--
-- @param data table  The data returned by C_EditMode.GetLayouts()
-- @return number|nil  Index into data.layouts of the active layout if it
--                     is a RealUI-managed layout, otherwise nil.
function EditModeManager:GetActiveRealUILayoutIndex(data)
    if not data or not data.layouts or not data.activeLayout then
        return nil
    end

    local savedIndex = data.activeLayout - NUM_PRESET_LAYOUTS
    if savedIndex < 1 then
        -- Active layout is a built-in preset, not a saved layout
        return nil
    end

    local active = data.layouts[savedIndex]
    if not active then
        return nil
    end

    for _, name in pairs(LAYOUT_NAMES) do
        if active.layoutName == name then
            return savedIndex
        end
    end

    return nil
end

--- Walks `layout.systems` and returns the matching `systemInfo` table.
-- Each entry in layout.systems is a systemInfo table whose identity is the
-- (system, systemIndex) pair (mirrors the structure produced by
-- EditModeTemplates and consumed by Blizzard's C_EditMode API).
--
-- @param layout table  A saved layout entry from C_EditMode.GetLayouts().layouts
-- @param system number  The EditMode system enum value (e.g. SYSTEM_OBJECTIVE_TRACKER)
-- @param systemIndex number  The system instance index (0 for singletons)
-- @return table|nil  The matching systemInfo table, or nil if not found
function EditModeManager:FindSystemInfo(layout, system, systemIndex)
    if not layout or not layout.systems then
        return nil
    end

    for _, sysInfo in ipairs(layout.systems) do
        if sysInfo.system == system and sysInfo.systemIndex == systemIndex then
            return sysInfo
        end
    end

    return nil
end

--- Convenience: returns the systemInfo entry for ObjectiveTracker
-- (system 12, systemIndex 0) within the currently-active RealUI layout.
-- Returns nil if the user is on a non-RealUI layout, if the layout data
-- can't be read, or if the system 12 entry is missing.
--
-- Used by RealUI_Tracker/Container.lua's UpdatePosition seeding gate
-- to inspect the live EditMode anchor and decide whether to seed the
-- user's stored position into the layout.
--
-- @return table|nil  The systemInfo table for system 12, or nil
function EditModeManager:GetActiveRealUITrackerSystemInfo()
    local ok, data = pcall(C_EditMode.GetLayouts)
    if not ok or not data then
        return nil
    end

    local layoutIdx = self:GetActiveRealUILayoutIndex(data)
    if not layoutIdx then
        return nil
    end

    return self:FindSystemInfo(data.layouts[layoutIdx], SYSTEM_OBJECTIVE_TRACKER, 0)
end

---------------------------------------------------------------------------
-- BuildLayout
---------------------------------------------------------------------------

--- Builds a complete EditMode layout structure for a given role and display.
-- Deep-copies the base template, applies role overrides, applies display
-- adjustments, and wraps in the EditMode layout structure.
-- @param role string  "dpstank" or "healing"
-- @param displayPresetId string  Display preset identifier (e.g. "standard")
-- @return table  A complete layout structure ready for C_EditMode.SaveLayouts()
function EditModeManager:BuildLayout(role, displayPresetId)
    local Templates = RealUI.EditModeTemplates
    if not Templates then
        debug("ERROR: EditModeTemplates not available")
        return nil
    end

    -- 1. Deep copy base template
    local layout = Templates.DeepCopy(Templates.base)

    -- 2. Apply role overrides
    local roleOverrides = Templates.overrides and Templates.overrides[role]
    if roleOverrides then
        Templates.MergeOverrides(layout, roleOverrides)
    end

    -- 3. Apply display adjustments
    local displayAdj = Templates.displayAdjustments and Templates.displayAdjustments[displayPresetId]
    if displayAdj then
        Templates.ApplyDisplayAdjustments(layout, displayAdj)
    end

    -- 4. Determine layout type
    local layoutType = self:GetCurrentLayoutType()

    -- 5. Wrap in EditMode layout structure
    return {
        layoutName = LAYOUT_NAMES[role],
        layoutType = layoutType,
        systems = layout,
    }
end

---------------------------------------------------------------------------
-- EnsureLayouts
---------------------------------------------------------------------------

--- Ensures both "RealUI" and "RealUI-Healing" layouts exist and are up-to-date.
-- If a layout already exists, its user-modified positions/settings are
-- preserved — the template is only used for initial creation.
-- Pass `forceRebuild = true` to overwrite existing layouts with the template
-- (used by InstallWizard to reset layouts to RealUI defaults).
-- @param displayPresetId string  Display preset identifier
-- @param forceRebuild boolean|nil  If true, overwrite existing layouts
-- @return boolean  true if layouts were saved, false if deferred
function EditModeManager:EnsureLayouts(displayPresetId, forceRebuild)
    if InCombatLockdown() then
        state.pendingLayout = { action = "ensure", displayPresetId = displayPresetId }
        debug("Combat lockdown — queued EnsureLayouts")
        return false
    end

    local ok, data = pcall(C_EditMode.GetLayouts)
    if not ok or not data then
        debug("ERROR: C_EditMode.GetLayouts() failed:", data)
        return false
    end

    local targetType = self:GetCurrentLayoutType()
    local changed = false

    for role, layoutName in pairs(LAYOUT_NAMES) do
        local existingIndex = FindLayoutIndex(data, layoutName, targetType)
        if existingIndex and not forceRebuild then
            -- Preserve user customizations; do nothing for existing layouts
            debug("Preserving existing layout:", layoutName, "at index", existingIndex)
        else
            local layout = self:BuildLayout(role, displayPresetId)
            if layout then
                if existingIndex then
                    data.layouts[existingIndex] = layout
                    debug("Rebuilt existing layout:", layoutName, "at index", existingIndex)
                else
                    table.insert(data.layouts, layout)
                    debug("Inserted new layout:", layoutName)
                end
                changed = true
            else
                debug("ERROR: BuildLayout returned nil for role:", role)
            end
        end
    end

    if changed then
        local saveOk, saveErr = pcall(C_EditMode.SaveLayouts, data)
        if not saveOk then
            debug("ERROR: C_EditMode.SaveLayouts() failed:", saveErr)
            return false
        end
    end

    state.layoutsCreated = true
    state.currentDisplayPreset = displayPresetId
    debug("EnsureLayouts completed for preset:", displayPresetId, "changed:", changed)
    return true
end

---------------------------------------------------------------------------
-- ActivateLayout
---------------------------------------------------------------------------

--- Activates the EditMode layout for the specified role.
-- Finds the layout by name and calls C_EditMode.SetActiveLayout() with the
-- correct absolute index (built-in count + custom index).
-- @param role string  "dpstank" or "healing"
-- @return boolean  true if activated, false if deferred or failed
function EditModeManager:ActivateLayout(role)
    if InCombatLockdown() then
        state.pendingLayout = { action = "activate", role = role }
        debug("Combat lockdown — queued ActivateLayout:", role)
        return false
    end

    local layoutName = LAYOUT_NAMES[role]
    if not layoutName then
        debug("ERROR: Unknown role:", role)
        return false
    end

    local ok, data = pcall(C_EditMode.GetLayouts)
    if not ok or not data then
        debug("ERROR: C_EditMode.GetLayouts() failed:", data)
        return false
    end

    local targetType = self:GetCurrentLayoutType()
    local idx = FindLayoutIndex(data, layoutName, targetType)

    if not idx then
        -- Layout doesn't exist yet — create both, then find again
        debug("Layout not found, calling EnsureLayouts first")
        local ensureOk = self:EnsureLayouts(state.currentDisplayPreset or "standard")
        if not ensureOk then return false end

        local retryOk, retryData = pcall(C_EditMode.GetLayouts)
        if not retryOk or not retryData then
            debug("ERROR: C_EditMode.GetLayouts() failed on retry:", retryData)
            return false
        end
        data = retryData
        idx = FindLayoutIndex(data, layoutName, targetType)
    end

    if not idx then
        debug("ERROR: Could not find or create layout:", layoutName)
        return false
    end

    local absoluteIndex = NUM_PRESET_LAYOUTS + idx
    local activateOk, activateErr = pcall(C_EditMode.SetActiveLayout, absoluteIndex)
    if not activateOk then
        debug("ERROR: C_EditMode.SetActiveLayout() failed:", activateErr)
        return false
    end

    state.currentRole = role
    debug("Activated layout:", layoutName, "at absolute index", absoluteIndex)

    return true
end

---------------------------------------------------------------------------
-- ApplyLayout
---------------------------------------------------------------------------

--- Full apply: rebuilds both layouts and activates the one for the given role.
-- Used by InstallWizard and DisplayPresets changes.
-- @param role string  "dpstank" or "healing"
-- @param displayPresetId string  Display preset identifier
-- @return boolean  true if both operations succeeded
function EditModeManager:ApplyLayout(role, displayPresetId)
    if InCombatLockdown() then
        state.pendingLayout = { action = "apply", role = role, displayPresetId = displayPresetId }
        debug("Combat lockdown — queued ApplyLayout:", role, displayPresetId)
        return false
    end

    local ensureOk = self:EnsureLayouts(displayPresetId)
    if not ensureOk then return false end

    return self:ActivateLayout(role)
end

---------------------------------------------------------------------------
-- Per-Character Support
---------------------------------------------------------------------------

--- Toggles per-character layout mode.
-- When enabled, creates character-specific layouts. When disabled, removes
-- them and reverts to account-wide layouts.
-- @param enabled boolean  Whether per-character mode should be active
function EditModeManager:SetPerCharacter(enabled)
    local dbc = RealUI.db and RealUI.db.char
    if not dbc then return end
    dbc.editmode = dbc.editmode or {}
    dbc.editmode.perCharacter = enabled

    if enabled then
        local role = state.currentRole or "dpstank"
        local presetId = state.currentDisplayPreset or "standard"
        self:ApplyLayout(role, presetId)
    else
        self:RemovePerCharacterLayouts()
        local role = state.currentRole or "dpstank"
        self:ActivateLayout(role)
    end
end

--- Removes per-character (type 2) RealUI layouts from the EditMode data.
function EditModeManager:RemovePerCharacterLayouts()
    if InCombatLockdown() then
        state.pendingLayout = { action = "removePerChar" }
        debug("Combat lockdown — queued RemovePerCharacterLayouts")
        return
    end

    local ok, data = pcall(C_EditMode.GetLayouts)
    if not ok or not data then
        debug("ERROR: C_EditMode.GetLayouts() failed:", data)
        return
    end

    -- Iterate backwards to safely remove entries
    for i = #data.layouts, 1, -1 do
        local layout = data.layouts[i]
        if layout.layoutType == 2 and (layout.layoutName == "RealUI" or layout.layoutName == "RealUI-Healing") then
            table.remove(data.layouts, i)
            debug("Removed per-character layout at index", i)
        end
    end

    local saveOk, saveErr = pcall(C_EditMode.SaveLayouts, data)
    if not saveOk then
        debug("ERROR: C_EditMode.SaveLayouts() failed:", saveErr)
    end
end

---------------------------------------------------------------------------
-- Migration
---------------------------------------------------------------------------

--- Migration schema versions:
--  1 = initial EditMode migration
--  2 = CDV orientation/size settings moved from manual hooks to native
--      EditMode settings; forces a template rebuild so existing
--      auto-generated layouts pick up the new CDV settings.
--  3 = FrameMover-managed frames (boss frames, vehicle seat indicator,
--      durability frame, archaeology bar, etc.) migrated to native EditMode
--      settings; forces a template rebuild so existing auto-generated
--      layouts pick up the new EditMode positions.
--  4 = Purge saved layouts that still contain relativeTo="RealUI_TrackerFrame"
--      on the ObjectiveTracker entry (system 12). Prior versions had two bugs:
--      (a) NeedsMigration short-circuited on existing pre-flag layouts without
--      fixing them; (b) forceRebuild was false when oldVersion was nil, so
--      EnsureLayouts preserved rather than rebuilt corrupted pre-flag layouts.
local MIGRATION_VERSION = 4

--- Checks whether migration from pre-EditMode RealUI is needed.
-- @return boolean  true if migration should run
function EditModeManager:NeedsMigration()
    local dbg = RealUI.db and RealUI.db.global
    if dbg and dbg.editmode and dbg.editmode.migrationVersion then
        return dbg.editmode.migrationVersion < MIGRATION_VERSION
    end
    -- No migration version recorded — always migrate so any pre-existing
    -- layout with a corrupted relativeTo anchor gets force-rebuilt.
    -- The old "layout exists → skip" short-circuit was Bug A: it called
    -- SetMigrationFlag without actually fixing the corrupted data.
    return true
end

--- Stores the migration version flag to prevent re-running.
function EditModeManager:SetMigrationFlag()
    local dbg = RealUI.db and RealUI.db.global
    if dbg then
        dbg.editmode = dbg.editmode or {}
        dbg.editmode.migrationVersion = MIGRATION_VERSION
        debug("Migration flag set to v" .. MIGRATION_VERSION)
    end
end

--- Performs one-time migration from pre-EditMode RealUI versions.
-- Creates both layouts and conditionally activates if user is on a built-in layout.
-- When upgrading between schema versions, forces a rebuild of the
-- auto-generated RealUI layouts so they pick up template changes.
function EditModeManager:MigrateFromPreEditMode()
    if InCombatLockdown() then
        state.pendingLayout = { action = "migrate" }
        debug("Combat lockdown — queued MigrateFromPreEditMode")
        return
    end

    local role = (RealUI.cLayout == 2) and "healing" or "dpstank"
    local display = RealUI.db and RealUI.db.global and RealUI.db.global.display
    local presetId = (display and display.presetId) or "standard"

    -- If an older schema version exists, force-rebuild so template
    -- changes propagate into the user's RealUI layout.
    local dbg = RealUI.db and RealUI.db.global
    local oldVersion = dbg and dbg.editmode and dbg.editmode.migrationVersion
    local forceRebuild = (oldVersion ~= nil) and (oldVersion < MIGRATION_VERSION)

    -- Step 5 — Defensive key-count snapshot (BEFORE).
    --
    -- Capture key counts of the two preserved-data stores before running
    -- the destructive body (Step 2 and Step 3). Step 5 is a diagnostic
    -- assertion that backs Req 8.4 (RealUI_TrackerDB.profile.position
    -- preserved) and Req 8.5 (Bartender4DB preserved): the migration
    -- body MUST NOT change the key count of these stores, with one
    -- documented exception — Step 2b intentionally removes the dead
    -- `maxHeightOffset` key from each tracker profile's `position`
    -- table, so a delta of exactly -1 per tracker profile is expected
    -- on a user's first run of v3 and is suppressed below.
    --
    -- We snapshot key COUNTS rather than `tostring(table)` on purpose:
    -- `tostring` on a table returns a memory-address string that has
    -- no relationship to content, so it can't detect mutations. A key
    -- count is cheap (O(n) once per migration) and content-aware.
    local trackerPositionCountsBefore = snapshotTrackerPositionCounts()
    local bartender4CountsBefore = snapshotBartender4ProfileCounts()

    -- Step 2 — Remove the orphan `playerpowerbaralt` key from every
    -- FrameMover profile's `uiframes` table. PlayerPowerBarAlt is owned by
    -- EditMode system 21 (Personal Resource Display) and is parked
    -- off-screen by the RealUI template; the FrameMover entry is redundant
    -- and would otherwise leave a dead key in saved variables forever.
    --
    -- This step is BLOCKING: on pcall failure, we log the error and bail
    -- out of the migration WITHOUT calling SetMigrationFlag, so the
    -- migration retries next session. See design "Migration Steps → Step 2"
    -- and "Migration ordering rationale" — BLOCKING steps must run before
    -- the NON-BLOCKING Step 2b so a Step 2b failure cannot prevent Step 2's
    -- protection from taking effect.
    local fm_ok, fm_err = pcall(function()
        local fmDB = _G.RealUIDB and _G.RealUIDB.namespaces and _G.RealUIDB.namespaces.FrameMover
        if fmDB and fmDB.profiles then
            for profileName, profile in pairs(fmDB.profiles) do
                if profile.uiframes then
                    profile.uiframes.playerpowerbaralt = nil
                end
            end
        end
    end)
    if not fm_ok then
        debug("ERROR: Step 2 FrameMover playerpowerbaralt cleanup failed (BLOCKING — bailing out, will retry next session):", fm_err)
        return
    end

    -- Step 2b — Clean dead `maxHeightOffset` key out of every RealUI_Tracker
    -- profile. Under inverted anchoring (Container.lua does
    -- `RealUI_TrackerFrame:SetAllPoints(OTF)`), the container's height tracks
    -- OTF's rect, so the old `maxHeightOffset` user-tunable does nothing.
    -- This cleanup is COSMETIC and NON-BLOCKING: any pcall failure here is
    -- logged as a warning and the migration continues to Step 3 / Step 7.
    -- The on-disk key would otherwise sit dormant forever, confusing future
    -- debugging — the bail-on-failure semantics of Step 2 / Step 3 are
    -- reserved for changes whose absence would leave the user in a broken
    -- state (orphan FrameMover key, stale layout anchor). See design
    -- "Migration Steps → Step 2b" and "Migration ordering rationale".
    local trClean_ok, trClean_err = pcall(function()
        local trDB = _G.RealUI_TrackerDB
        if trDB and trDB.profiles then
            for _, profile in pairs(trDB.profiles) do
                if profile.position then
                    profile.position.maxHeightOffset = nil
                end
            end
        end
    end)
    if not trClean_ok then
        debug("WARNING: Step 2b RealUI_TrackerDB maxHeightOffset cleanup failed (non-blocking):", trClean_err)
    end

    -- Step 4 — RealUI_ConfigDB cleanup: VERIFIED NO-OP (no code).
    --
    -- Req 5.5 mandates that any saved-variable key under
    -- `RealUI_ConfigDB.profiles[<active>]` corresponding to a removed
    -- Advanced-panel option be set to `nil` during migration. Verification
    -- shows there is nothing to clean up:
    --
    --   1. RealUI_Config declares NO SavedVariable. Verified by grep across
    --      `RealUI/RealUI_Config/**/*.toc` for `## SavedVariables` —
    --      zero matches. There is no `RealUI_ConfigDB` global to mutate.
    --
    --   2. Per-frame FrameMover data lives under
    --      `RealUIDB.namespaces.FrameMover.profiles.<*>.uiframes`
    --      (registered via `RealUI.db:RegisterNamespace("FrameMover")` in
    --      `RealUI/RealUI/Modules/FrameMover.lua`). Step 2 above already
    --      cleaned the only orphan key (`playerpowerbaralt`) from that
    --      namespace.
    --
    --   3. The Advanced panel's option list is built dynamically from
    --      `FrameMover.FrameList.uiframes` at
    --      `RealUI/RealUI_Config/Advanced.lua:2184`
    --      (`for uiSlug, ui in next, FrameList.uiframes do`). Removing the
    --      `playerpowerbaralt` key from the static FrameList (task 1.1) is
    --      sufficient to make its Ace3 option group disappear — no Advanced
    --      panel code change is needed and no migration write is possible.
    --
    -- See design "Migration Steps → Step 4" and "Removed Config Surface →
    -- Req 5.5 verification" / "RealUI_Config Advanced panel".

    -- Step 3 — Force-rebuild RealUI layouts so the corrected ObjectiveTracker
    -- entry (system 12 with `relativeTo = "UIParent"`) is written into the
    -- saved layout data. The `forceRebuild` flag computed above is true
    -- whenever the stored migrationVersion is less than MIGRATION_VERSION,
    -- so any user upgrading from v2 (or earlier) gets a fresh rebuild that
    -- overwrites any prior `relativeTo = "RealUI_TrackerFrame"` corruption
    -- on disk (resolves Req 6.13).
    --
    -- This step is BLOCKING: on failure (EnsureLayouts returns false, or the
    -- pcall traps a Lua error in the function body), we log and bail out
    -- WITHOUT calling SetMigrationFlag, so the migration retries next
    -- session. EnsureLayouts already wraps C_EditMode.SaveLayouts in pcall
    -- internally and returns false on save failure; the outer pcall here
    -- defends against any unexpected error in the function body itself
    -- (e.g. BuildLayout throwing) so the bail-out semantics are explicit
    -- regardless of where the failure originates. See design "Migration
    -- Steps → Step 3" and "Migration ordering rationale".
    local ensure_ok, ensure_result = pcall(self.EnsureLayouts, self, presetId, forceRebuild)
    if not ensure_ok then
        debug("ERROR: Step 3 EnsureLayouts pcall failed (BLOCKING — bailing out, will retry next session):", ensure_result)
        return
    end
    if ensure_result == false then
        debug("ERROR: Step 3 EnsureLayouts returned false (BLOCKING — bailing out, will retry next session)")
        return
    end

    -- Step 5 — Defensive key-count snapshot (AFTER) and delta check.
    --
    -- Re-snapshot the two preserved-data stores and compare to the
    -- BEFORE counts captured above. Any delta is logged as a warning
    -- with two exceptions:
    --
    --   1. RealUI_TrackerDB tracker-position delta of exactly -1 per
    --      profile is EXPECTED when Step 2b ran successfully, because
    --      Step 2b nils out `maxHeightOffset` (typically taking the
    --      count from 6 to 5). We suppress that specific signature.
    --
    --   2. A profile present in the BEFORE snapshot but absent from
    --      AFTER is treated as a real warning (the profile or its
    --      `position` table was destroyed). A profile present in
    --      AFTER but absent from BEFORE is also a real warning (the
    --      migration spuriously created a new entry).
    --
    -- Bartender4 has no expected delta — its store must be preserved
    -- byte-for-byte (Req 8.5), so any non-zero delta there is a true
    -- warning. Step 5 does NOT mutate either store; it is purely
    -- diagnostic.
    local trackerPositionCountsAfter = snapshotTrackerPositionCounts()
    local bartender4CountsAfter = snapshotBartender4ProfileCounts()

    for profileName, beforeCount in pairs(trackerPositionCountsBefore) do
        local afterCount = trackerPositionCountsAfter[profileName]
        if afterCount == nil then
            debug("WARNING: Step 5 RealUI_TrackerDB profile lost during migration:",
                profileName, "before=", beforeCount, "after=nil")
        elseif beforeCount ~= afterCount then
            local delta = beforeCount - afterCount
            local expectedFromStep2b = (trClean_ok and delta == 1)
            if not expectedFromStep2b then
                debug("WARNING: Step 5 RealUI_TrackerDB.profile.position key-count changed unexpectedly:",
                    "profile=", profileName, "before=", beforeCount, "after=", afterCount, "delta=", delta)
            end
        end
    end
    for profileName, afterCount in pairs(trackerPositionCountsAfter) do
        if trackerPositionCountsBefore[profileName] == nil then
            debug("WARNING: Step 5 RealUI_TrackerDB profile appeared during migration:",
                profileName, "before=nil after=", afterCount)
        end
    end

    for profileName, beforeCount in pairs(bartender4CountsBefore) do
        local afterCount = bartender4CountsAfter[profileName]
        if afterCount == nil then
            debug("WARNING: Step 5 Bartender4DB profile lost during migration:",
                profileName, "before=", beforeCount, "after=nil")
        elseif beforeCount ~= afterCount then
            debug("WARNING: Step 5 Bartender4DB.namespaces.ActionBars.profiles key-count changed (must be zero per Req 8.5):",
                "profile=", profileName, "before=", beforeCount, "after=", afterCount,
                "delta=", beforeCount - afterCount)
        end
    end
    for profileName, afterCount in pairs(bartender4CountsAfter) do
        if bartender4CountsBefore[profileName] == nil then
            debug("WARNING: Step 5 Bartender4DB profile appeared during migration:",
                profileName, "before=nil after=", afterCount)
        end
    end

    -- Only activate if user is on a built-in (Preset) layout —
    -- don't disrupt a user-selected custom layout.
    local ok, data = pcall(C_EditMode.GetLayouts)
    if ok and data then
        -- data.activeLayout is an index into the combined [presets, saved]
        -- list, so any value <= NUM_PRESET_LAYOUTS means a preset is active.
        -- Values > NUM_PRESET_LAYOUTS index into data.layouts (saved-only).
        local activeIdx = data.activeLayout
        local currentIsBuiltIn = activeIdx and activeIdx <= NUM_PRESET_LAYOUTS

        if currentIsBuiltIn then
            self:ActivateLayout(role)
            debug("Migration: activated layout for role:", role)
        else
            debug("Migration: user has custom layout active, skipping activation")
        end
    end

    self:SetMigrationFlag()
    debug("Migration from pre-EditMode completed")
end

---------------------------------------------------------------------------
-- SetTrackerAnchor
---------------------------------------------------------------------------

--- Writes the ObjectiveTracker (system 12) anchor into the active RealUI
-- EditMode layout. This is the sole writer for system 12 anchorInfo from
-- RealUI code paths and enforces three invariants:
--   1. relativeTo is hard-coded to "UIParent" — the function does not
--      accept a relativeTo parameter, preventing accidental references
--      to non-standard targets like "RealUI_TrackerFrame" (Req 6.10).
--   2. Writes are silently skipped when the user is on a non-RealUI
--      layout (preset or third-party custom), so the migration cannot
--      clobber user data outside the RealUI-managed layouts.
--   3. Combat lockdown is honored by queueing the action for replay on
--      PLAYER_REGEN_ENABLED (Req 6.6, 9.5).
--
-- @param point string         Anchor point on the tracker (e.g. "TOPRIGHT")
-- @param relativePoint string Anchor point on UIParent (e.g. "TOPRIGHT")
-- @param x number             X offset
-- @param y number             Y offset
function EditModeManager:SetTrackerAnchor(point, relativePoint, x, y)
    if InCombatLockdown() then
        state.pendingLayout = {
            action = "trackerAnchor",
            point = point,
            relativePoint = relativePoint,
            x = x,
            y = y,
        }
        debug("Combat lockdown — queued SetTrackerAnchor")
        return
    end

    local ok, data = pcall(C_EditMode.GetLayouts)
    if not ok or not data then
        debug("ERROR: C_EditMode.GetLayouts() failed:", data)
        return
    end

    local layoutIdx = self:GetActiveRealUILayoutIndex(data)
    if not layoutIdx then
        -- User is on a non-RealUI layout — refuse the write to preserve
        -- the sole-writer invariant on EditMode layout data (Req 10.1).
        debug("SetTrackerAnchor: active layout is not RealUI-managed, skipping")
        return
    end

    local sysInfo = self:FindSystemInfo(data.layouts[layoutIdx], SYSTEM_OBJECTIVE_TRACKER, 0)
    if not sysInfo or not sysInfo.anchorInfo then
        debug("SetTrackerAnchor: system 12 entry not found in active layout")
        return
    end

    sysInfo.anchorInfo.point         = point
    sysInfo.anchorInfo.relativeTo    = "UIParent"
    sysInfo.anchorInfo.relativePoint = relativePoint
    sysInfo.anchorInfo.offsetX       = x
    sysInfo.anchorInfo.offsetY       = y

    local saveOk, saveErr = pcall(C_EditMode.SaveLayouts, data)
    if not saveOk then
        debug("ERROR: C_EditMode.SaveLayouts() failed:", saveErr)
        return
    end

    debug("SetTrackerAnchor: wrote", point, "UIParent", relativePoint, x, y)
end

--- Resets the RealUI layouts to their template defaults.
-- Overwrites any user customizations. Used by the InstallWizard or when
-- the user explicitly asks to reset.
-- @param displayPresetId string|nil  Display preset (defaults to current)
function EditModeManager:ResetLayout(displayPresetId)
    local presetId = displayPresetId or state.currentDisplayPreset or "standard"
    self:EnsureLayouts(presetId, true)
end

---------------------------------------------------------------------------
-- Public Getters
---------------------------------------------------------------------------

--- Returns whether the EditModeManager has been initialized.
-- @return boolean
function EditModeManager:IsInitialized()
    return state.initialized
end

---------------------------------------------------------------------------
-- Event Frame
---------------------------------------------------------------------------

local function InitializeManager()
    state.initialized = true
    if EditModeManager:NeedsMigration() then
        EditModeManager:MigrateFromPreEditMode()
    end
    if state.pendingLayout then
        local pending = state.pendingLayout
        state.pendingLayout = nil
        ProcessPending(pending)
    end
end

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_LOGIN")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Blizzard_PlayerChoice" then
        debug("Initialized — Blizzard_PlayerChoice loaded")
        self:UnregisterEvent("ADDON_LOADED")
        self:UnregisterEvent("PLAYER_LOGIN")
        InitializeManager()

    elseif event == "PLAYER_LOGIN" then
        self:UnregisterEvent("PLAYER_LOGIN")
        self:UnregisterEvent("ADDON_LOADED")
        if not state.initialized then
            debug("Initialized — PLAYER_LOGIN fallback")
            InitializeManager()
        end

    elseif event == "PLAYER_REGEN_ENABLED" then
        -- Process combat-deferred action
        if state.pendingLayout then
            local pending = state.pendingLayout
            state.pendingLayout = nil
            debug("Processing pending layout action:", pending.action)
            ProcessPending(pending)
        end

    elseif event == "DISPLAY_SIZE_CHANGED" then
        if not state.initialized then return end

        -- Re-apply layout for the new display category
        local DisplayPresets = RealUI.DisplayPresets
        if not DisplayPresets or not DisplayPresets.Suggest then return end

        local newPresetId = DisplayPresets.Suggest()
        if newPresetId and newPresetId ~= state.currentDisplayPreset then
            local role = state.currentRole or "dpstank"
            debug("Display changed, re-applying layout for preset:", newPresetId)
            EditModeManager:ApplyLayout(role, newPresetId)
        end
    end
end)

-- Check if Blizzard_PlayerChoice is already loaded (it may load before us)
if C_AddOns.IsAddOnLoaded("Blizzard_PlayerChoice") then
    state.initialized = true
    debug("Initialized — Blizzard_PlayerChoice was already loaded")
    eventFrame:UnregisterEvent("ADDON_LOADED")

    -- Defer migration check to next frame to ensure RealUI.db is ready
    C_Timer.After(0, function()
        if EditModeManager:NeedsMigration() then
            EditModeManager:MigrateFromPreEditMode()
        end
    end)
end
