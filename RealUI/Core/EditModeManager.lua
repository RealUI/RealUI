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
    -- Set once any C_EditMode.SaveLayouts write succeeds this session. EditMode
    -- is tainted from that point until a reload; see the write gate below.
    layoutsWritten = false,
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

-- B126: same deal for the ChatFrame system, plus its left inset. CHAT_X must
-- match `CHAT_X` in EditModeTemplates.lua and the 6 used by
-- CharacterInit:SetupChatFrames and the `chat` new-defaults item — those four
-- disagreeing is the bug this constant exists to stop recurring.
local SYSTEM_CHAT_FRAME = 8
local CHAT_X = 6

---------------------------------------------------------------------------
-- CooldownViewer
-- Size, orientation, icon limit, etc. are configured via native EditMode
-- settings in EditModeTemplates.base (see "System 20" block there).
-- Blizzard's GridLayoutFrame:Layout() reads those settings from the active
-- layout and sizes both the viewer frame and its child icons correctly,
-- so no manual SetScale or child re-anchoring is needed.
---------------------------------------------------------------------------

---------------------------------------------------------------------------
-- Layout write gate (taint containment)
---------------------------------------------------------------------------
--
-- `C_EditMode.SaveLayouts(data)` called from addon code stores a table that
-- insecure code has written into. When EditMode reads it back through
-- `EditModeManagerFrameMixin:UpdateLayoutInfo`, `EditModeManagerFrame.layoutInfo`
-- becomes tainted for the rest of the session — and `UpdateSystems` runs
-- `secureexecuterange(self.registeredSystemFrames, callUpdateSystem)`, where
-- every `UpdateSystem` call reads that layoutInfo. So one addon write taints
-- the update pass for *every* registered system, not just ours.
--
-- Before 12.1 that was invisible. Since 12.1 Blizzard_CooldownViewer is full of
-- restricted tables and secret values (`hasTotem`, `charges`,
-- `allowAvailableAlert`), so a tainted UpdateSystems pass makes it throw on
-- every UNIT_AURA — hundreds of errors per session, none of them in our code.
--
-- Taint is per-session and does not survive a reload, so the containment rule
-- is: only write layouts from an explicitly user-initiated flow that ends in a
-- reload prompt (install wizard, display preset change, config toggle,
-- one-time migration). Automatic and event-driven writes are refused here
-- rather than left to taint the session silently.
--
-- Wrap legitimate writers in EditModeManager:BeginUserWrite() /
-- :EndUserWrite(). Anything outside that scope is logged and dropped.

local writeScope = 0

--- Opens a user-initiated layout write scope. Must be paired with EndUserWrite.
function EditModeManager:BeginUserWrite()
    writeScope = writeScope + 1
end

--- Closes a user-initiated layout write scope.
function EditModeManager:EndUserWrite()
    if writeScope > 0 then
        writeScope = writeScope - 1
    end
end

--- Whether layout writes are currently permitted.
function EditModeManager:IsUserWriteScopeOpen()
    return writeScope > 0
end

--- Sole gateway to C_EditMode.SaveLayouts. Refuses writes outside a
-- user-initiated scope so automatic paths cannot taint EditMode.
-- @param data table  Layout data from C_EditMode.GetLayouts()
-- @param reason string  Caller label, for debug output
-- @return boolean  true if the write was performed
local function SaveLayouts(data, reason)
    if writeScope == 0 then
        debug("REFUSED layout write outside user-initiated scope:", reason)
        return false
    end

    local ok, err = pcall(C_EditMode.SaveLayouts, data)
    if not ok then
        debug("ERROR: C_EditMode.SaveLayouts() failed:", err)
        return false
    end

    state.layoutsWritten = true
    debug("Wrote EditMode layouts:", reason)
    return true
end

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

--- B131: stores a copy of a layout about to be destroyed by a forced rebuild.
--
-- A `MIGRATION_VERSION` bump rebuilds every entry in the RealUI layouts from
-- the template, which is the only way to get a corrected default to someone
-- already installed — but it also discards whatever they had moved in EditMode,
-- silently and permanently. That reaches real upgrades, not just beta users:
-- 3.4.0 shipped MIGRATION_VERSION 5, so every 3.4.0 → 4.0 upgrade takes a
-- forced rebuild.
--
-- The copy makes the loss recoverable via `/realui editmode restore`. It is a
-- plain AceDB write — no C_EditMode call, so it is outside the taint gate
-- entirely and safe to run on any path.
--
-- Only one generation is kept. A second rebuild before the user restores would
-- otherwise overwrite the good copy with the already-rebuilt one, turning the
-- backup into a copy of the template; the version stamp is what detects that.
-- @param layoutName string  Layout being replaced
-- @param layout table       The live layout, before it is overwritten
local function BackupLayout(layoutName, layout)
    local dbg = RealUI.db and RealUI.db.global
    local Templates = RealUI.EditModeTemplates
    if not (dbg and Templates and layout) then return end

    dbg.editmode = dbg.editmode or {}
    local existing = dbg.editmode.backup and dbg.editmode.backup[layoutName]
    if existing and existing.fromVersion == (dbg.editmode.migrationVersion or 0) then
        -- Already backed up at this version — a repeat rebuild in the same
        -- upgrade. Keep the first copy; it is the one with the user's edits.
        debug("Backup for", layoutName, "already exists at this version, keeping it")
        return
    end

    dbg.editmode.backup = dbg.editmode.backup or {}
    dbg.editmode.backup[layoutName] = {
        fromVersion = dbg.editmode.migrationVersion or 0,
        layout = Templates.DeepCopy(layout),
    }
    debug("Backed up layout before rebuild:", layoutName)
end

--- Processes a pending layout action from the queue.
-- Queued actions are always the tail of a user-initiated flow that hit combat
-- lockdown, so the write scope is reopened for the replay. `EnsureLayouts` and
-- `RemovePerCharacterLayouts` are raw writers with no scope of their own —
-- their normal callers supply it, so the replay must too.
-- @param pending table  The pending action descriptor
local function ProcessPending(pending)
    if not pending then return end

    EditModeManager:BeginUserWrite()

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

    EditModeManager:EndUserWrite()
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

    -- B126: nil and 0 mean the same thing for a system that has no index, and
    -- both forms exist in the wild. `Templates.base` writes nil
    -- (`Entry(SYSTEM_CHAT_FRAME, nil, ...)`), and a live dump of saved layout
    -- data confirms nil survives the C_EditMode round-trip:
    --
    --     RealUI            nil  36.2  52.3
    --     RealUI-Healing    nil  36.2  52.3
    --
    -- Callers, however, were written to search for 0 — SetTrackerAnchor still
    -- does. An exact `==` therefore never matched, and both writers failed
    -- silently with "entry not found" rather than erroring. Treating the two as
    -- equivalent here fixes every caller at once instead of at each site.
    -- Systems that genuinely have indices use 1..n, so collapsing nil and 0
    -- cannot collide with a real index.
    local wanted = systemIndex or 0
    for _, sysInfo in ipairs(layout.systems) do
        if sysInfo.system == system and (sysInfo.systemIndex or 0) == wanted then
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

    -- 2b. B126: write the anchors that cannot be constants in the template.
    -- Before the display deltas, which are added on top of these.
    if Templates.ApplyComputedAnchors then
        Templates.ApplyComputedAnchors(layout, role)
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
-- @param backupExisting boolean|nil  B131: if true, copy each layout aside
--   before overwriting it. Set by the one-time migration, which destroys the
--   layout without being asked; NOT set by ResetLayout or the install wizard,
--   where wiping is what the user requested and where a backup would overwrite
--   the migration's copy with an already-rebuilt layout.
-- @return boolean  true if layouts were saved, false if deferred
function EditModeManager:EnsureLayouts(displayPresetId, forceRebuild, backupExisting)
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
                    -- B131: this is the destructive branch — the user's own
                    -- EditMode edits live in the table about to be replaced.
                    if backupExisting then
                        BackupLayout(layoutName, data.layouts[existingIndex])
                    end
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
        if not SaveLayouts(data, "EnsureLayouts") then
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

--- B60: the role→layout mapping is user-configurable. The RealUI-named
-- layouts stay the maintained defaults (creation, templates and the
-- sole-writer guard all keep using LAYOUT_NAMES), but *activation* honours a
-- per-character override so a user-made EditMode layout can be the one RealUI
-- re-asserts on reloads and spec swaps, instead of being stomped by it.
-- @param role string  "dpstank" or "healing"
-- @return string  The layout name activation should target
function EditModeManager:GetConfiguredLayoutName(role)
    local dbc = RealUI.db and RealUI.db.char
    local override = dbc and dbc.editmode and dbc.editmode.layouts
        and dbc.editmode.layouts[role]
    return override or LAYOUT_NAMES[role]
end

--- Sets (or clears) the layout a role activates. nil or the default name
-- clears the override.
-- @param role string  "dpstank" or "healing"
-- @param layoutName string|nil  Saved EditMode layout name
function EditModeManager:SetRoleLayout(role, layoutName)
    local dbc = RealUI.db and RealUI.db.char
    if not dbc or not LAYOUT_NAMES[role] then return end
    dbc.editmode = dbc.editmode or {}
    dbc.editmode.layouts = dbc.editmode.layouts or {}
    if layoutName == LAYOUT_NAMES[role] then layoutName = nil end
    dbc.editmode.layouts[role] = layoutName
    debug("SetRoleLayout:", role, layoutName or "(default)")
    if role == (state.currentRole or "dpstank") then
        -- Config-panel click = user-initiated; the scope covers the
        -- EnsureLayouts fallback inside ActivateLayout.
        self:BeginUserWrite()
        self:ActivateLayout(role)
        self:EndUserWrite()
    end
end

--- Lists saved EditMode layout names for the config dropdowns.
-- @return table  { [layoutName] = layoutName }
function EditModeManager:GetSavedLayoutNames()
    local values = {}
    local ok, data = pcall(C_EditMode.GetLayouts)
    if ok and data and data.layouts then
        for _, layout in ipairs(data.layouts) do
            values[layout.layoutName] = layout.layoutName
        end
    end
    -- The maintained defaults are always offered, even before first creation
    values[LAYOUT_NAMES.dpstank] = LAYOUT_NAMES.dpstank
    values[LAYOUT_NAMES.healing] = LAYOUT_NAMES.healing
    return values
end

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

    if not LAYOUT_NAMES[role] then
        debug("ERROR: Unknown role:", role)
        return false
    end
    local layoutName = self:GetConfiguredLayoutName(role)

    local ok, data = pcall(C_EditMode.GetLayouts)
    if not ok or not data then
        debug("ERROR: C_EditMode.GetLayouts() failed:", data)
        return false
    end

    local targetType = self:GetCurrentLayoutType()
    local idx = FindLayoutIndex(data, layoutName, targetType)

    -- B60: a configured user layout that no longer exists (deleted in
    -- EditMode) cannot be created by EnsureLayouts — fall back to the
    -- maintained default for the role rather than failing.
    if not idx and layoutName ~= LAYOUT_NAMES[role] then
        debug("Configured layout missing, falling back to default:", layoutName)
        layoutName = LAYOUT_NAMES[role]
        idx = FindLayoutIndex(data, layoutName, targetType)
    end

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

    -- ApplyLayout is only reached from user-initiated flows (install wizard,
    -- display preset change, config panel) — the DISPLAY_SIZE_CHANGED handler
    -- deliberately no longer calls it. Opening the write scope here is what
    -- lets EnsureLayouts persist; see the taint containment note at the top.
    --
    -- The scope must span ActivateLayout too: when the named layout is missing
    -- it calls EnsureLayouts itself, and that write would otherwise be refused.
    self:BeginUserWrite()

    local ensureOk = self:EnsureLayouts(displayPresetId)
    if not ensureOk then
        self:EndUserWrite()
        return false
    end

    local activated = self:ActivateLayout(role)

    self:EndUserWrite()
    return activated
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
        -- RemovePerCharacterLayouts is a raw writer, and ActivateLayout can
        -- fall back to EnsureLayouts; both need the scope.
        local role = state.currentRole or "dpstank"

        self:BeginUserWrite()
        self:RemovePerCharacterLayouts()
        self:ActivateLayout(role)
        self:EndUserWrite()
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

    SaveLayouts(data, "RemovePerCharacterLayouts")
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
--  5 = CooldownViewer IconPadding raised (2/5 → 7) in EditModeTemplates so the
--      icon gap comes from Blizzard's secure layout path. Replaces Aurora's
--      RefreshLayout childXPadding hook, which tainted the CooldownViewer
--      and caused mass secret-value errors at raid-end cinematics.
--  6 = Objective tracker X moved from -25 to -36 (B116). The shipped value
--      sat inside the right-hand action bar column, which ends at -30, so the
--      tracker overlapped the bars on every install. The number now comes from
--      TRACKER_X in EditModeTemplates.lua, which RealUI_Tracker's AceDB seed
--      also reads — previously the two disagreed (-25 vs -50) and only the
--      EditMode one took effect past first run. Forces a template rebuild so
--      existing auto-generated layouts pick the new position up; as with
--      versions 2/3/5 that discards hand edits made inside the auto-generated
--      RealUI layouts.
local MIGRATION_VERSION = 6

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

    -- Force-rebuild whenever migrating so any corrupted relativeTo=
    -- "RealUI_TrackerFrame" anchor is overwritten with "UIParent".
    -- nil oldVersion (pre-flag layout) was Bug B: the old expression
    -- `(oldVersion ~= nil) and (...)` evaluated to false, preserving
    -- the corrupted layout instead of rebuilding it.
    local dbg = RealUI.db and RealUI.db.global
    local oldVersion = dbg and dbg.editmode and dbg.editmode.migrationVersion
    local forceRebuild = (oldVersion == nil) or (oldVersion < MIGRATION_VERSION)

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
    -- saved layout data. `forceRebuild` is true whenever migrationVersion is
    -- less than MIGRATION_VERSION OR was never recorded (nil), covering both
    -- upgrade users and pre-flag users whose corrupted layout was previously
    -- preserved by Bug B (resolves Req 6.13).
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
    --
    -- The one-time migration is the only automatic path still permitted to
    -- write layouts — refusing it would strand upgrading users forever, since
    -- the flag is never set and it retries every session. The reload prompt at
    -- the end of this function clears the resulting session taint.
    self:BeginUserWrite()
    -- B131: back up only when this is actually a destructive rebuild. On a
    -- fresh install forceRebuild is true but no layout exists to copy, so the
    -- backup path is never reached and nothing is stored.
    local ensure_ok, ensure_result = pcall(self.EnsureLayouts, self, presetId, forceRebuild, forceRebuild)
    self:EndUserWrite()

    if not ensure_ok then
        debug("ERROR: Step 3 EnsureLayouts pcall failed (BLOCKING — bailing out, will retry next session):", ensure_result)
        return
    end
    if ensure_result == false then
        debug("ERROR: Step 3 EnsureLayouts returned false (BLOCKING — bailing out, will retry next session)")
        return
    end

    -- B131: the flag is set HERE, immediately after the destructive step, not
    -- at the end of the function. It records "the rebuild ran", and the rebuild
    -- has now run. Everything below is diagnostic (Step 5) or idempotent
    -- (ActivateLayout), and none of it is wrapped in pcall — so with the flag
    -- at the bottom, one error in the snapshot walk left the layout already
    -- overwritten and the flag unwritten, and the next login overwrote it
    -- again. That is an unbounded loss: the user can never keep an EditMode
    -- edit. Setting it here bounds the damage to exactly one rebuild.
    --
    -- Trade-off, deliberate: if ActivateLayout below fails, migration will not
    -- retry it. That is the cheaper failure — activation is recoverable from
    -- HuD config → General, a discarded layout is not recoverable at all.
    self:SetMigrationFlag()

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
            -- Scope spans this too: ActivateLayout falls back to EnsureLayouts
            -- if the named layout is somehow still missing.
            self:BeginUserWrite()
            self:ActivateLayout(role)
            self:EndUserWrite()
            debug("Migration: activated layout for role:", role)
        else
            debug("Migration: user has custom layout active, skipping activation")
        end
    end

    -- SetMigrationFlag is NOT called here — see B131 above, it runs directly
    -- after the Step 3 rebuild so a failure in between cannot cause a repeat.
    debug("Migration from pre-EditMode completed")

    -- Clear the session taint the layout write just introduced. Without a
    -- reload, EditModeManagerFrame.layoutInfo stays tainted and every later
    -- UpdateSystems pass runs tainted for all registered systems — which is
    -- what made Blizzard_CooldownViewer throw on every UNIT_AURA. The
    -- migration runs once per user, so this prompt is not recurring.
    if state.layoutsWritten and RealUI.ReloadUIDialog then
        RealUI:ReloadUIDialog()
    end
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

    if not SaveLayouts(data, "SetTrackerAnchor") then
        return
    end

    debug("SetTrackerAnchor: wrote", point, "UIParent", relativePoint, x, y)
end

---------------------------------------------------------------------------
-- SetChatAnchor (B126)
---------------------------------------------------------------------------

--- Writes the ChatFrame (system 8) anchor into the active RealUI layout.
--
-- Why this exists rather than a template fix alone: the corrected template only
-- reaches a layout that gets rebuilt, and `ApplyLayout` deliberately preserves
-- existing layouts. So a character that already has a RealUI layout — i.e.
-- everyone past first run — would keep the old chat anchor forever, including
-- across a wizard re-run.
--
-- The bug it fixes: `Templates.base` carried an exported `BOTTOMLEFT 36.2, 52.3`
-- for system 8, while `CharacterInit:SetupChatFrames` and the `chat` new-defaults
-- item both place chat at `(6, GetChatYOffset(layout))`. InstallWizard:Complete
-- ran the CharacterInit placement first and applied the EditMode layout second,
-- so EditMode — which owns system 8 — put chat straight back to the template
-- value, on the wizard and again on every login. Two sources of truth, and the
-- silent one won. Same shape as B116.
--
-- This is the targeted per-entry write proposed in B131 as the alternative to
-- blanket `forceRebuild`, used here for the first time: it corrects one entry
-- without discarding the other 49.
--
-- Combat and sole-writer guards match SetTrackerAnchor. Callers must be
-- user-initiated and end in a reload — InstallWizard:Complete is both.
-- @return boolean  true if the anchor was written
function EditModeManager:SetChatAnchor()
    if InCombatLockdown() then
        debug("Combat lockdown — skipping SetChatAnchor")
        return false
    end

    if not RealUI.GetChatYOffset then return false end
    local layoutId = (RealUI.cLayout == 2) and 2 or 1
    local y = RealUI.GetChatYOffset(layoutId)
    if not y then return false end

    local ok, data = pcall(C_EditMode.GetLayouts)
    if not ok or not data then
        debug("ERROR: C_EditMode.GetLayouts() failed:", data)
        return false
    end

    local layoutIdx = self:GetActiveRealUILayoutIndex(data)
    if not layoutIdx then
        debug("SetChatAnchor: active layout is not RealUI-managed, skipping")
        return false
    end

    -- systemIndex 0 and nil are equivalent here — FindSystemInfo collapses them
    -- (B126). Saved data uses nil; passing 0 matched nothing until that fix.
    local sysInfo = self:FindSystemInfo(data.layouts[layoutIdx], SYSTEM_CHAT_FRAME, 0)
    if not sysInfo or not sysInfo.anchorInfo then
        debug("SetChatAnchor: system 8 entry not found in active layout")
        return false
    end

    sysInfo.anchorInfo.point         = "BOTTOMLEFT"
    sysInfo.anchorInfo.relativeTo    = "UIParent"
    sysInfo.anchorInfo.relativePoint = "BOTTOMLEFT"
    sysInfo.anchorInfo.offsetX       = CHAT_X
    sysInfo.anchorInfo.offsetY       = y

    if not SaveLayouts(data, "SetChatAnchor") then
        return false
    end

    debug("SetChatAnchor: wrote BOTTOMLEFT UIParent BOTTOMLEFT", CHAT_X, y)
    return true
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
-- Layout backup / restore (B131)
---------------------------------------------------------------------------

--- Reports which layouts have a pre-rebuild backup stored.
-- @return table  { [layoutName] = fromVersion, ... }
function EditModeManager:GetLayoutBackups()
    local found = {}
    local dbg = RealUI.db and RealUI.db.global
    local backup = dbg and dbg.editmode and dbg.editmode.backup
    if not backup then return found end
    for layoutName, entry in pairs(backup) do
        if type(entry) == "table" and type(entry.layout) == "table" then
            found[layoutName] = entry.fromVersion or 0
        end
    end
    return found
end

--- Restores the RealUI EditMode layouts saved before the last forced rebuild.
--
-- User-initiated by definition (it is only reachable from a slash command), so
-- it opens its own write scope and prompts for the reload that clears the
-- resulting session taint — the same contract MigrateFromPreEditMode uses.
--
-- The backup is kept after a successful restore. Restoring is itself a
-- destructive act on the current layout, and a user who restores the wrong one
-- has nothing else to fall back on; the copy costs a few KB.
-- @return boolean, string  success, message
function EditModeManager:RestoreLayoutBackup()
    if InCombatLockdown() then
        return false, "Can't restore EditMode layouts in combat."
    end

    local dbg = RealUI.db and RealUI.db.global
    local backup = dbg and dbg.editmode and dbg.editmode.backup
    if not backup or not next(backup) then
        return false, "No layout backup stored — nothing has been rebuilt on this account."
    end

    local ok, data = pcall(C_EditMode.GetLayouts)
    if not ok or not data then
        return false, "Could not read EditMode layouts."
    end

    local Templates = RealUI.EditModeTemplates
    if not Templates then
        return false, "EditModeTemplates not available."
    end

    local restored, missing = {}, {}
    for _, layoutName in pairs(LAYOUT_NAMES) do
        local entry = backup[layoutName]
        if entry and type(entry.layout) == "table" then
            local index = FindLayoutIndex(data, layoutName, self:GetCurrentLayoutType())
            if index then
                local slot = data.layouts[index]
                local copy = Templates.DeepCopy(entry.layout)
                -- Keep the slot's own identity. The backup carries the name and
                -- type it had when captured, and the account/character setting
                -- can have changed since — restoring the stale pair would put a
                -- mismatched layoutType into a slot FindLayoutIndex matched on
                -- the current one.
                copy.layoutName = slot.layoutName
                copy.layoutType = slot.layoutType
                data.layouts[index] = copy
                restored[#restored + 1] = layoutName
            else
                missing[#missing + 1] = layoutName
            end
        end
    end

    if #restored == 0 then
        if #missing > 0 then
            return false, "Backup found, but the matching layouts no longer exist in EditMode."
        end
        return false, "No RealUI layout backup to restore."
    end

    self:BeginUserWrite()
    local wrote = SaveLayouts(data, "RestoreLayoutBackup")
    self:EndUserWrite()

    if not wrote then
        return false, "The layout write was refused — try again after a /reload."
    end

    if RealUI.ReloadUIDialog then
        RealUI:ReloadUIDialog()
    end

    if #missing > 0 then
        return true, ("Restored: %s (no longer in EditMode, skipped: %s)")
            :format(table.concat(restored, ", "), table.concat(missing, ", "))
    end
    return true, ("Restored: %s"):format(table.concat(restored, ", "))
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
            -- Do NOT write layouts here. This handler fires on resolution and
            -- UI-scale changes, including transient ones like a graphics driver
            -- reset, and an automatic C_EditMode.SaveLayouts would taint
            -- EditMode for the rest of the session (see the write gate note at
            -- the top of this file). DisplayPresets owns the user-facing
            -- prompt; when the user accepts it, DisplayPresets.Apply calls
            -- ApplyLayout inside a proper write scope and prompts for reload.
            -- DisplayStage's REALUI_DISPLAY_CHANGED popup ("Reconfigure") is
            -- the user path from here into DisplayPresets.Apply.
            debug("Display changed; suggested preset (no automatic layout write):", newPresetId)
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
