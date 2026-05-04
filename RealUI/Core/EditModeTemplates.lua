local _, private = ...

-- Lua Globals --
-- luacheck: globals next type pairs ipairs table

-- RealUI --
local RealUI = private.RealUI

---------------------------------------------------------------------------
-- EditMode Layout Templates
-- Defines base positions and settings for all EditMode-managed systems.
-- Used by EditModeManager to build complete EditMode layouts.
---------------------------------------------------------------------------

local Templates = {}
RealUI.EditModeTemplates = Templates

---------------------------------------------------------------------------
-- Constants
---------------------------------------------------------------------------
-- EditMode system enums
local SYSTEM_ACTION_BAR         = 0
local SYSTEM_CAST_BAR           = 1
local SYSTEM_MINIMAP            = 2
local SYSTEM_UNIT_FRAME         = 3
local SYSTEM_ENCOUNTER_BAR      = 4
local SYSTEM_EXTRA_ABILITIES    = 5
local SYSTEM_AURA_FRAME         = 6
local SYSTEM_TALKING_HEAD       = 7
local SYSTEM_CHAT_FRAME         = 8
local SYSTEM_VEHICLE_LEAVE      = 9
local SYSTEM_LOOT_FRAME         = 10
local SYSTEM_HUD_TOOLTIP        = 11
local SYSTEM_OBJECTIVE_TRACKER  = 12
local SYSTEM_MICRO_MENU         = 13
local SYSTEM_BAGS               = 14
local SYSTEM_STATUS_TRACKING    = 15
local SYSTEM_DURABILITY         = 16
local SYSTEM_TIMER_BARS         = 17
local SYSTEM_VEHICLE_SEAT       = 18
local SYSTEM_ARCHAEOLOGY        = 19
local SYSTEM_COOLDOWN_VIEWER    = 20
local SYSTEM_PERSONAL_RESOURCE  = 21
local SYSTEM_ENCOUNTER_EVENTS   = 22
local SYSTEM_DAMAGE_METER       = 23

-- Action bar visibility setting: 3 = Always Hidden
local VISIBILITY_ALWAYS_HIDDEN = 3

-- Off-screen offset for replaced frames
local OFF_SCREEN_Y = -5000

---------------------------------------------------------------------------
-- Helper: create a system entry
---------------------------------------------------------------------------
local function Entry(system, systemIndex, anchorInfo, settings, isInDefaultPosition)
    return {
        system = system,
        systemIndex = systemIndex,
        settings = settings or {},
        anchorInfo = anchorInfo,
        isInDefaultPosition = isInDefaultPosition or false,
    }
end

local function Anchor(point, relativeTo, relativePoint, offsetX, offsetY)
    return {
        point = point,
        relativeTo = relativeTo or "UIParent",
        relativePoint = relativePoint,
        offsetX = offsetX or 0,
        offsetY = offsetY or 0,
    }
end

---------------------------------------------------------------------------
-- Base Template: All 39 system entries for RealUI's standard layout
-- Positions calibrated for a 1920x1080 "standard" display preset.
---------------------------------------------------------------------------
Templates.base = {
    -- =====================================================================
    -- System 0: Action Bars (indices 1-8 = bars, 9 = stance, 10 = pet, 11 = possess)
    -- All hidden — Bartender4 replaces them
    -- =====================================================================
    Entry(SYSTEM_ACTION_BAR, 1,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {{ setting = 0, value = VISIBILITY_ALWAYS_HIDDEN }}),
    Entry(SYSTEM_ACTION_BAR, 2,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {{ setting = 0, value = VISIBILITY_ALWAYS_HIDDEN }}),
    Entry(SYSTEM_ACTION_BAR, 3,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {{ setting = 0, value = VISIBILITY_ALWAYS_HIDDEN }}),
    Entry(SYSTEM_ACTION_BAR, 4,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {{ setting = 0, value = VISIBILITY_ALWAYS_HIDDEN }}),
    Entry(SYSTEM_ACTION_BAR, 5,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {{ setting = 0, value = VISIBILITY_ALWAYS_HIDDEN }}),
    Entry(SYSTEM_ACTION_BAR, 6,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {{ setting = 0, value = VISIBILITY_ALWAYS_HIDDEN }}),
    Entry(SYSTEM_ACTION_BAR, 7,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {{ setting = 0, value = VISIBILITY_ALWAYS_HIDDEN }}),
    Entry(SYSTEM_ACTION_BAR, 8,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {{ setting = 0, value = VISIBILITY_ALWAYS_HIDDEN }}),
    Entry(SYSTEM_ACTION_BAR, 9,  -- Stance bar
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {{ setting = 0, value = VISIBILITY_ALWAYS_HIDDEN }}),
    Entry(SYSTEM_ACTION_BAR, 10, -- Pet bar
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {{ setting = 0, value = VISIBILITY_ALWAYS_HIDDEN }}),
    Entry(SYSTEM_ACTION_BAR, 11, -- Possess bar
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {{ setting = 0, value = VISIBILITY_ALWAYS_HIDDEN }}),

    -- =====================================================================
    -- System 1: Cast Bar — positioned center-bottom (used by RealUI)
    -- =====================================================================
    Entry(SYSTEM_CAST_BAR, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 200),
        {{ setting = 0, value = 0 }}), -- Lock to Player Frame = false

    -- =====================================================================
    -- System 2: Minimap — top-right corner
    -- =====================================================================
    Entry(SYSTEM_MINIMAP, nil,
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -10, -10),
        {}),

    -- =====================================================================
    -- System 3: Unit Frames
    -- Indices 1-3, 8 = off-screen (oUF replaces Player, Target, Focus, Pet)
    -- Indices 4-7 = positioned (Party, Raid, Boss, Arena)
    -- =====================================================================
    Entry(SYSTEM_UNIT_FRAME, 1, -- Player (oUF replaces)
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {}),
    Entry(SYSTEM_UNIT_FRAME, 2, -- Target (oUF replaces)
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {}),
    Entry(SYSTEM_UNIT_FRAME, 3, -- Focus (oUF replaces)
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {}),
    Entry(SYSTEM_UNIT_FRAME, 4, -- Party frames
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 220),
        {}),
    Entry(SYSTEM_UNIT_FRAME, 5, -- Raid frames
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 200),
        {}),
    Entry(SYSTEM_UNIT_FRAME, 6, -- Boss frames
        Anchor("RIGHT", "UIParent", "RIGHT", -32, 314),
        {}),
    Entry(SYSTEM_UNIT_FRAME, 7, -- Arena frames
        Anchor("RIGHT", "UIParent", "RIGHT", -32, 200),
        {}),
    Entry(SYSTEM_UNIT_FRAME, 8, -- Pet (oUF replaces)
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {}),

    -- =====================================================================
    -- System 4: Encounter Bar — bottom-center above action area
    -- =====================================================================
    Entry(SYSTEM_ENCOUNTER_BAR, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 160),
        {}),

    -- =====================================================================
    -- System 5: Extra Abilities — bottom-center
    -- =====================================================================
    Entry(SYSTEM_EXTRA_ABILITIES, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 300),
        {}),

    -- =====================================================================
    -- System 6: Aura Frames (Buff = index 1, Debuff = index 2)
    -- Top-right, below minimap
    -- =====================================================================
    Entry(SYSTEM_AURA_FRAME, 1, -- Buff Frame
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -180, -10),
        {}),
    Entry(SYSTEM_AURA_FRAME, 2, -- Debuff Frame
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -180, -100),
        {}),

    -- =====================================================================
    -- System 7: Talking Head — bottom-center
    -- =====================================================================
    Entry(SYSTEM_TALKING_HEAD, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 350),
        {}),

    -- =====================================================================
    -- System 8: Chat Frame — bottom-left
    -- =====================================================================
    Entry(SYSTEM_CHAT_FRAME, nil,
        Anchor("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", 10, 30),
        {}),

    -- =====================================================================
    -- System 9: Vehicle Leave Button — bottom-center-right
    -- =====================================================================
    Entry(SYSTEM_VEHICLE_LEAVE, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 300, 100),
        {}),

    -- =====================================================================
    -- System 10: Loot Frame — center-left
    -- =====================================================================
    Entry(SYSTEM_LOOT_FRAME, nil,
        Anchor("LEFT", "UIParent", "LEFT", 50, 0),
        {}),

    -- =====================================================================
    -- System 11: HUD Tooltip — bottom-right
    -- =====================================================================
    Entry(SYSTEM_HUD_TOOLTIP, nil,
        Anchor("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -200, 100),
        {}),

    -- =====================================================================
    -- System 12: Objective Tracker — right side
    -- =====================================================================
    Entry(SYSTEM_OBJECTIVE_TRACKER, nil,
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -10, -200),
        {}),

    -- =====================================================================
    -- System 13: Micro Menu — bottom-right
    -- =====================================================================
    Entry(SYSTEM_MICRO_MENU, nil,
        Anchor("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -10, 30),
        {}),

    -- =====================================================================
    -- System 14: Bags — bottom-right above micro menu
    -- =====================================================================
    Entry(SYSTEM_BAGS, nil,
        Anchor("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -10, 55),
        {}),

    -- =====================================================================
    -- System 15: Status Tracking Bars (XP/Rep/Honor) — bottom-center
    -- =====================================================================
    Entry(SYSTEM_STATUS_TRACKING, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 0),
        {}),

    -- =====================================================================
    -- System 16: Durability Frame — top-right below minimap area
    -- =====================================================================
    Entry(SYSTEM_DURABILITY, nil,
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -100, -200),
        {}),

    -- =====================================================================
    -- System 17: Timer Bars (Duration Bars) — top-center
    -- =====================================================================
    Entry(SYSTEM_TIMER_BARS, nil,
        Anchor("TOP", "UIParent", "TOP", 0, -100),
        {}),

    -- =====================================================================
    -- System 18: Vehicle Seat Indicator — top-right
    -- =====================================================================
    Entry(SYSTEM_VEHICLE_SEAT, nil,
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -10, -180),
        {}),

    -- =====================================================================
    -- System 19: Archaeology Bar — top-center
    -- =====================================================================
    Entry(SYSTEM_ARCHAEOLOGY, nil,
        Anchor("TOP", "UIParent", "TOP", 0, -50),
        {}),

    -- =====================================================================
    -- System 20: Cooldown Viewer (11.1.5) — bottom-center above action area
    -- =====================================================================
    Entry(SYSTEM_COOLDOWN_VIEWER, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 130),
        {}),

    -- =====================================================================
    -- System 21: Personal Resource Display (12.0.0) — off-screen (oUF replaces)
    -- =====================================================================
    Entry(SYSTEM_PERSONAL_RESOURCE, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {}),

    -- =====================================================================
    -- System 22: Encounter Events (12.0.0) — top-center
    -- =====================================================================
    Entry(SYSTEM_ENCOUNTER_EVENTS, nil,
        Anchor("TOP", "UIParent", "TOP", 0, -150),
        {}),

    -- =====================================================================
    -- System 23: Damage Meter (12.0.0) — bottom-right above chat
    -- =====================================================================
    Entry(SYSTEM_DAMAGE_METER, nil,
        Anchor("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -10, 250),
        {}),
}

---------------------------------------------------------------------------
-- Role Overrides
-- Keyed by composite key: "system_systemIndex" (systemIndex = "nil" if nil)
-- Each override is a COMPLETE system entry that replaces the base entry.
---------------------------------------------------------------------------
Templates.overrides = {}

-- DPS/Tank overrides: party frames compact horizontal at bottom, raid compact
Templates.overrides.dpstank = {
    -- Party frames: compact, horizontal, bottom of screen
    ["3_4"] = Entry(SYSTEM_UNIT_FRAME, 4,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 220),
        {}),
    -- Raid frames: compact, bottom-center
    ["3_5"] = Entry(SYSTEM_UNIT_FRAME, 5,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 200),
        {}),
}

-- Healing overrides: party/raid frames larger and more central, encounter bar shifted
Templates.overrides.healing = {
    -- Party frames: larger, more central (higher on screen)
    ["3_4"] = Entry(SYSTEM_UNIT_FRAME, 4,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 320),
        {}),
    -- Raid frames: wider, more visible, higher position
    ["3_5"] = Entry(SYSTEM_UNIT_FRAME, 5,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 300),
        {}),
    -- Encounter bar: shifted up to make room for party/raid frames
    ["4_nil"] = Entry(SYSTEM_ENCOUNTER_BAR, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 220),
        {}),
    -- Extra abilities: shifted up
    ["5_nil"] = Entry(SYSTEM_EXTRA_ABILITIES, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 380),
        {}),
    -- Cooldown viewer: shifted up
    ["20_nil"] = Entry(SYSTEM_COOLDOWN_VIEWER, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 190),
        {}),
}

---------------------------------------------------------------------------
-- Display Adjustments
-- Per-display-preset offset DELTAS applied to anchorInfo.offsetX/offsetY.
-- Keyed by composite key: "system_systemIndex"
-- Values: { offsetX = delta, offsetY = delta }
---------------------------------------------------------------------------
Templates.displayAdjustments = {
    -- Standard: no adjustments (reference baseline)
    standard = {},

    -- Laptop: tighter spacing, elements pulled inward
    laptop = {
        -- Minimap slightly smaller offset
        ["2_nil"]  = { offsetX = 5, offsetY = 5 },
        -- Objective tracker closer to edge
        ["12_nil"] = { offsetX = 5, offsetY = 20 },
        -- Chat frame tighter to corner
        ["8_nil"]  = { offsetX = -5, offsetY = -5 },
        -- Buffs tighter
        ["6_1"]    = { offsetX = 10, offsetY = 5 },
        ["6_2"]    = { offsetX = 10, offsetY = 5 },
        -- Micro menu tighter
        ["13_nil"] = { offsetX = 5, offsetY = 0 },
    },

    -- High-res: slightly wider spacing
    highres = {
        -- Objective tracker slightly more inward
        ["12_nil"] = { offsetX = -10, offsetY = 0 },
        -- Buffs slightly more inward
        ["6_1"]    = { offsetX = -10, offsetY = 0 },
        ["6_2"]    = { offsetX = -10, offsetY = 0 },
    },

    -- 4K Desk: scaled positions for high pixel density
    ["4k_desk"] = {
        -- Minimap offset scaled
        ["2_nil"]  = { offsetX = -5, offsetY = -5 },
        -- Objective tracker offset
        ["12_nil"] = { offsetX = -15, offsetY = -10 },
        -- Chat frame offset
        ["8_nil"]  = { offsetX = 5, offsetY = 5 },
        -- Buffs offset
        ["6_1"]    = { offsetX = -15, offsetY = -5 },
        ["6_2"]    = { offsetX = -15, offsetY = -5 },
        -- Micro menu offset
        ["13_nil"] = { offsetX = -5, offsetY = 5 },
        -- Bags offset
        ["14_nil"] = { offsetX = -5, offsetY = 5 },
    },

    -- 4K Theater: similar to 4K desk with additional scaling
    ["4k_theater"] = {
        ["2_nil"]  = { offsetX = -5, offsetY = -5 },
        ["12_nil"] = { offsetX = -15, offsetY = -10 },
        ["8_nil"]  = { offsetX = 5, offsetY = 5 },
        ["6_1"]    = { offsetX = -15, offsetY = -5 },
        ["6_2"]    = { offsetX = -15, offsetY = -5 },
        ["13_nil"] = { offsetX = -5, offsetY = 5 },
        ["14_nil"] = { offsetX = -5, offsetY = 5 },
    },

    -- Ultrawide: wider chat, objective tracker offset, minimap adjusted
    ultrawide = {
        -- Chat frame: wider offset from left edge (more room on ultrawide)
        ["8_nil"]  = { offsetX = 20, offsetY = 0 },
        -- Objective tracker: pushed further right for aspect ratio
        ["12_nil"] = { offsetX = -30, offsetY = 0 },
        -- Minimap: adjusted for wider aspect ratio
        ["2_nil"]  = { offsetX = -20, offsetY = 0 },
        -- Buffs: adjusted for wider aspect ratio
        ["6_1"]    = { offsetX = -30, offsetY = 0 },
        ["6_2"]    = { offsetX = -30, offsetY = 0 },
        -- Damage meter: more room on right side
        ["23_nil"] = { offsetX = -30, offsetY = 0 },
    },
}

---------------------------------------------------------------------------
-- Utility: Composite Key
---------------------------------------------------------------------------
local function CompositeKey(system, systemIndex)
    return system .. "_" .. tostring(systemIndex or "nil")
end

---------------------------------------------------------------------------
-- Utility: DeepCopy
-- Recursively clones a table. Handles nested tables.
---------------------------------------------------------------------------
function Templates.DeepCopy(orig)
    if type(orig) ~= "table" then
        return orig
    end
    local copy = {}
    for k, v in pairs(orig) do
        if type(v) == "table" then
            copy[k] = Templates.DeepCopy(v)
        else
            copy[k] = v
        end
    end
    return copy
end

---------------------------------------------------------------------------
-- Utility: MergeOverrides
-- Overrides are keyed by composite key (system_systemIndex).
-- Each override performs a WHOLE-ENTRY replacement of the matching system
-- entry in the layout array.
-- @param layout table  Array of system entries (modified in place)
-- @param overrides table  Keyed by composite key, values are complete entries
---------------------------------------------------------------------------
function Templates.MergeOverrides(layout, overrides)
    if not overrides then return layout end

    for i, entry in ipairs(layout) do
        local key = CompositeKey(entry.system, entry.systemIndex)
        if overrides[key] then
            -- Whole-entry replacement: deep copy the override into the layout
            layout[i] = Templates.DeepCopy(overrides[key])
        end
    end

    return layout
end

---------------------------------------------------------------------------
-- Utility: ApplyDisplayAdjustments
-- Adjustments are offset DELTAS keyed by composite key.
-- Adds delta values to existing anchorInfo.offsetX and anchorInfo.offsetY.
-- @param layout table  Array of system entries (modified in place)
-- @param adjustments table  Keyed by composite key, values are {offsetX, offsetY}
---------------------------------------------------------------------------
function Templates.ApplyDisplayAdjustments(layout, adjustments)
    if not adjustments then return layout end

    for _, entry in ipairs(layout) do
        local key = CompositeKey(entry.system, entry.systemIndex)
        local adj = adjustments[key]
        if adj and entry.anchorInfo then
            if adj.offsetX then
                entry.anchorInfo.offsetX = (entry.anchorInfo.offsetX or 0) + adj.offsetX
            end
            if adj.offsetY then
                entry.anchorInfo.offsetY = (entry.anchorInfo.offsetY or 0) + adj.offsetY
            end
        end
    end

    return layout
end
