-- Groups.lua: Group definitions, container management, and iteration helpers
-- Runtime state (container frames, icon pools) is stored in a separate local
-- table to avoid polluting AceDB saved variables.

local AurasAddon = LibStub("AceAddon-3.0"):GetAddon("RealUI_Auras")
local Groups = {}
AurasAddon.Groups = Groups

---------------------------------------------------------------------------
-- Fixed iteration order for the six groups (deterministic)
---------------------------------------------------------------------------
local GROUP_ORDER = {
    "Buffs",
    "TargetBuffs",
    "TargetDebuffs",
    "FocusBuffs",
    "FocusDebuffs",
    "ToTDebuffs",
}

---------------------------------------------------------------------------
-- Runtime state — kept separate from AceDB profile data
-- groupState[name] = { container = Frame, icons = {}, pool = {}, auras = {} }
---------------------------------------------------------------------------
local groupState = {}

---------------------------------------------------------------------------
-- 3.1  Groups.All()
-- Returns an ordered array of group config tables from the db profile.
-- Each table is the AceDB-merged config (defaults + user overrides).
---------------------------------------------------------------------------
function Groups.All()
    local db = AurasAddon.db
    if not db then return {} end

    local result = {}
    for _, name in ipairs(GROUP_ORDER) do
        local cfg = db.profile.groups[name]
        if cfg then
            result[#result + 1] = cfg
        end
    end
    return result
end

---------------------------------------------------------------------------
-- 3.2  Groups.Get(name)
-- Returns a single group config table by name from the db profile.
---------------------------------------------------------------------------
function Groups.Get(name)
    local db = AurasAddon.db
    if not db then return nil end
    return db.profile.groups[name]
end

---------------------------------------------------------------------------
-- Runtime state accessors
-- These let other modules (Icons, Query, Redraw) read/write runtime state
-- without touching the AceDB tables directly.
---------------------------------------------------------------------------
function Groups.GetState(name)
    if not groupState[name] then
        groupState[name] = { container = nil, icons = {}, pool = {}, auras = {} }
    end
    return groupState[name]
end

---------------------------------------------------------------------------
-- 3.3  Groups.CreateContainer(group)
-- Creates the container Frame for a group, anchored to its parent frame.
-- Runtime state (container, icons, pool) is stored in groupState, not on
-- the AceDB config table.
---------------------------------------------------------------------------
function Groups.CreateContainer(group)
    local parentName = group.anchorFrame or group.parentFrame
    local parent = parentName and _G[parentName]
    if not parent then
        -- Parent frame doesn't exist yet; will retry on PLAYER_ENTERING_WORLD
        return
    end

    local state = Groups.GetState(group.name)

    -- Don't recreate if container already exists and is valid
    if state.container then return end

    local container = CreateFrame("Frame", nil, parent)
    container:SetSize(group.iconSize * group.wrap, group.iconSize)

    -- Anchor point depends on two factors:
    --   1. iconAlign: RIGHT-aligned groups anchor from the right edge,
    --      LEFT-aligned groups anchor from the left edge.
    --   2. Positioner vs unit-frame parent: positioner groups (anchorFrame set)
    --      anchor at the same edge of the parent (icons overlay the anchor point).
    --      Unit-frame groups anchor below the parent (icons go under the frame).
    local isPositioner = (group.anchorFrame ~= nil)
    local isRight = (group.iconAlign == "RIGHT")

    local myPoint, parentPoint
    if isRight then
        myPoint = "TOPRIGHT"
        parentPoint = isPositioner and "TOPRIGHT" or "BOTTOMRIGHT"
    else
        myPoint = "TOPLEFT"
        parentPoint = isPositioner and "TOPLEFT" or "BOTTOMLEFT"
    end

    container:SetPoint(myPoint, parent, parentPoint, group.anchorX or 0, group.anchorY or 0)

    state.container = container
    state.icons     = {}
    state.pool      = {}
    state.auras     = {}
end

---------------------------------------------------------------------------
-- 3.4  Groups.InitAll()
-- Iterates all groups and creates containers for each.  Groups whose
-- parent frame does not yet exist are silently skipped (deferred).
---------------------------------------------------------------------------
function Groups.InitAll()
    for _, group in ipairs(Groups.All()) do
        Groups.CreateContainer(group)
    end
end

---------------------------------------------------------------------------
-- 3.5  Groups.MonitorsUnit(group, unit)
-- Returns true if the group monitors the given unit token via any of:
--   • group.detectBuffsMonitor
--   • group.detectDebuffsMonitor
--   • group.unit  (base unit)
---------------------------------------------------------------------------
function Groups.MonitorsUnit(group, unit)
    if group.unit == unit then
        return true
    end
    if group.detectBuffsMonitor and group.detectBuffsMonitor == unit then
        return true
    end
    if group.detectDebuffsMonitor and group.detectDebuffsMonitor == unit then
        return true
    end
    return false
end

---------------------------------------------------------------------------
-- 3.6  Groups.RefreshAll()
-- Re-hides Blizzard buff frames, then redraws every group that has a
-- container.
---------------------------------------------------------------------------
function Groups.RefreshAll()
    BuffFrame:Hide()
    DebuffFrame:Hide()

    -- Retry container creation for any groups that were deferred
    Groups.InitAll()

    for _, group in ipairs(Groups.All()) do
        Groups.Redraw(group)
    end
end

---------------------------------------------------------------------------
-- 6.1  Groups.Redraw(group)
-- Full redraw cycle:
--   1. Icons.ReleaseAll(group)          — recycle all icons back to pool
--   2. Query.GetAllForGroup(group)      — filtered + sorted aura list
--   3. For each aura: Icons.Acquire + Icons.Update
--   4. Icons.Layout(group)              — position icons in the grid
--   5. Show/hide container based on icon count
--
-- Icons and Query are referenced lazily via AurasAddon since they are
-- defined in files that load after Groups.lua.
---------------------------------------------------------------------------
function Groups.Redraw(group)
    local Icons = AurasAddon.Icons
    local Query = AurasAddon.Query
    local state = Groups.GetState(group.name)

    -- Skip if container doesn't exist yet (deferred creation)
    if not state.container then return end

    -- Skip redraw for disabled groups — release icons and hide container
    if group.disabled then
        Icons.ReleaseAll(group)
        state.container:Hide()
        return
    end

    -- Skip redraw when the monitored unit does not exist.
    -- Positioner groups (Buffs) monitor "player" which always exists, so
    -- they are never skipped. Unit-frame groups for target, focus, and
    -- targettarget are skipped when those units are absent.
    if group.unit and group.unit ~= "player" and not UnitExists(group.unit) then
        Icons.ReleaseAll(group)
        state.container:Hide()
        return
    end

    -- Step 1: Release all existing icons back to the pool
    Icons.ReleaseAll(group)

    -- Step 2: Query filtered + sorted auras for this group
    local auras = Query.GetAllForGroup(group)

    -- Step 3: Acquire an icon for each aura and apply its data
    for _, aura in ipairs(auras) do
        local btn = Icons.Acquire(group)
        Icons.Update(btn, aura, group)
    end

    -- Step 4: Position icons in the wrapping grid
    Icons.Layout(group)

    -- Step 5: Show container if there are icons, hide if empty
    if #state.icons > 0 then
        state.container:Show()
    else
        state.container:Hide()
    end
end
