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

---------------------------------------------------------------------------
-- Internal Helpers
---------------------------------------------------------------------------

--- Returns the number of built-in layouts (Modern, Classic).
-- Custom layouts start at index (builtIn + 1) in absolute numbering.
local function GetBuiltInLayoutCount()
    return 2
end

--- Finds the array index of a named layout within data.layouts.
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
-- Builds layouts for both roles, finds or inserts them in the EditMode data,
-- and persists via C_EditMode.SaveLayouts().
-- @param displayPresetId string  Display preset identifier
-- @return boolean  true if layouts were saved, false if deferred
function EditModeManager:EnsureLayouts(displayPresetId)
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

    for role, layoutName in pairs(LAYOUT_NAMES) do
        local layout = self:BuildLayout(role, displayPresetId)
        if layout then
            local existingIndex = FindLayoutIndex(data, layoutName, targetType)
            if existingIndex then
                data.layouts[existingIndex] = layout
                debug("Updated existing layout:", layoutName, "at index", existingIndex)
            else
                table.insert(data.layouts, layout)
                debug("Inserted new layout:", layoutName)
            end
        else
            debug("ERROR: BuildLayout returned nil for role:", role)
        end
    end

    local saveOk, saveErr = pcall(C_EditMode.SaveLayouts, data)
    if not saveOk then
        debug("ERROR: C_EditMode.SaveLayouts() failed:", saveErr)
        return false
    end

    state.layoutsCreated = true
    state.currentDisplayPreset = displayPresetId
    debug("EnsureLayouts completed for preset:", displayPresetId)
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

    local absoluteIndex = GetBuiltInLayoutCount() + idx
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

--- Checks whether migration from pre-EditMode RealUI is needed.
-- @return boolean  true if migration should run
function EditModeManager:NeedsMigration()
    local dbg = RealUI.db and RealUI.db.global
    if dbg and dbg.editmode and dbg.editmode.migrationVersion then
        return false
    end

    if state.initialized then
        local ok, data = pcall(C_EditMode.GetLayouts)
        if ok and data then
            if FindLayoutIndex(data, "RealUI") then
                -- Layout already exists — mark as migrated and skip
                self:SetMigrationFlag()
                return false
            end
        end
    end

    return true
end

--- Stores the migration version flag to prevent re-running.
function EditModeManager:SetMigrationFlag()
    local dbg = RealUI.db and RealUI.db.global
    if dbg then
        dbg.editmode = dbg.editmode or {}
        dbg.editmode.migrationVersion = 1
        debug("Migration flag set")
    end
end

--- Performs one-time migration from pre-EditMode RealUI versions.
-- Creates both layouts and conditionally activates if user is on a built-in layout.
function EditModeManager:MigrateFromPreEditMode()
    if InCombatLockdown() then
        state.pendingLayout = { action = "migrate" }
        debug("Combat lockdown — queued MigrateFromPreEditMode")
        return
    end

    local role = (RealUI.cLayout == 2) and "healing" or "dpstank"
    local display = RealUI.db and RealUI.db.global and RealUI.db.global.display
    local presetId = (display and display.presetId) or "standard"

    -- Create both layouts
    self:EnsureLayouts(presetId)

    -- Only activate if user is on a built-in layout (don't disrupt custom layouts)
    local ok, data = pcall(C_EditMode.GetLayouts)
    if ok and data then
        local numBuiltIn = GetBuiltInLayoutCount()
        local currentIsBuiltIn = data.activeLayout <= numBuiltIn

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

local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("ADDON_LOADED")
eventFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
eventFrame:RegisterEvent("DISPLAY_SIZE_CHANGED")

eventFrame:SetScript("OnEvent", function(self, event, arg1)
    if event == "ADDON_LOADED" and arg1 == "Blizzard_PlayerChoice" then
        state.initialized = true
        self:UnregisterEvent("ADDON_LOADED")
        debug("Initialized — Blizzard_PlayerChoice loaded")

        -- Check for migration on first init
        if EditModeManager:NeedsMigration() then
            EditModeManager:MigrateFromPreEditMode()
        end

        -- Process any pending action queued before initialization
        if state.pendingLayout then
            local pending = state.pendingLayout
            state.pendingLayout = nil
            ProcessPending(pending)
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
    eventFrame:UnregisterEvent("ADDON_LOADED")
    debug("Initialized — Blizzard_PlayerChoice was already loaded")

    -- Defer migration check to next frame to ensure RealUI.db is ready
    C_Timer.After(0, function()
        if EditModeManager:NeedsMigration() then
            EditModeManager:MigrateFromPreEditMode()
        end
    end)
end
