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
-- 12.1 appends RaidWarning=24, TotemActionBar=25, LossOfControl=26 (IDs 0-23
-- unchanged). Only RaidWarning gets an entry here — it replaces the old
-- FrameMover "Raid Alerts" SetPoint (which would fight EditMode layout
-- application). TotemActionBar/LossOfControl deliberately stay at Blizzard
-- defaults until a calibrated position exists (decision 2026-08-12).
local SYSTEM_RAID_WARNING       = 24

-- Action bar visibility setting: 3 = Always Hidden
local VISIBILITY_ALWAYS_HIDDEN = 3

-- Off-screen offset for replaced frames
local OFF_SCREEN_Y = -5000

---------------------------------------------------------------------------
-- Objective tracker position — the ONE source of truth (B116, 2026-08-24)
--
-- This used to be stated twice: here as an EditMode anchor, and again as an
-- AceDB default in RealUI_Tracker. They drifted (-25 here against -50 there)
-- and the EditMode value wins for every install past first run, so the
-- shipped tracker sat under the right-hand action bars. RealUI_Tracker now
-- seeds from `Templates.trackerDefaultPosition` below instead of restating
-- the numbers, which is what makes the two agree by construction rather than
-- by someone remembering to update both.
--
-- The X offset is derived, not eyeballed. RealUI_ActionBars/Defaults.lua
-- ships `buttonSize = 27` with a 1px border drawn OUTSIDE the frame, so a
-- side-bar column is 27 + 2 = 29px wide; Integration.lua anchors it
-- border-flush at `x = -border` (RIGHT). The column therefore occupies screen
-- x [-30, -1], and the tracker's right edge has to clear -30.
--
-- Note this tracks the SHIPPED button size. A user who enlarges their buttons
-- widens the column and can reintroduce the overlap; making the tracker
-- follow that live would mean recomputing an EditMode anchor from action bar
-- settings, which is a bigger change than this fix. Deliberately not done.
local SIDE_BAR_INSET     = 1                                    -- Integration.lua: x = -border
local SIDE_BAR_COLUMN    = 29                                   -- buttonSize 27 + 2 borders
local TRACKER_EDGE_GAP   = 6
local TRACKER_X = -(SIDE_BAR_INSET + SIDE_BAR_COLUMN + TRACKER_EDGE_GAP)  -- -36
local TRACKER_Y = -210

-- B126: the chat frame's left inset. Shared with CharacterInit:SetupChatFrames
-- and the `chat` new-defaults item, which both use 6. The matching y is not a
-- constant — see Templates.ApplyComputedAnchors.
local CHAT_X = 6

Templates.trackerDefaultPosition = {
    anchorFrom = "TOPRIGHT",
    anchorTo   = "TOPRIGHT",
    x          = TRACKER_X,
    y          = TRACKER_Y,
}

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
-- Base Template: All 50 system entries for RealUI's standard layout
-- Positions calibrated for a 1920x1080 "standard" display preset.
-- Last exported: 2026-05-09
---------------------------------------------------------------------------
Templates.base = {
    -- =====================================================================
    -- System 0: Action Bars (indices 1-8 = bars, 11 = stance, 12 = pet, 13 = possess)
    -- All hidden — RealUI_ActionBars replaces them
    -- =====================================================================
    Entry(SYSTEM_ACTION_BAR, 1,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = VISIBILITY_ALWAYS_HIDDEN },
            { setting = 1, value = 1 },
            { setting = 2, value = 12 },
            { setting = 3, value = 5 },
            { setting = 4, value = 2 },
            { setting = 6, value = 0 },
            { setting = 8, value = 0 },
            { setting = 9, value = 1 },
        }),
    Entry(SYSTEM_ACTION_BAR, 2,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = VISIBILITY_ALWAYS_HIDDEN },
            { setting = 1, value = 1 },
            { setting = 2, value = 12 },
            { setting = 3, value = 5 },
            { setting = 4, value = 2 },
            { setting = 5, value = 0 },
            { setting = 9, value = 1 },
        }),
    Entry(SYSTEM_ACTION_BAR, 3,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = VISIBILITY_ALWAYS_HIDDEN },
            { setting = 1, value = 1 },
            { setting = 2, value = 12 },
            { setting = 3, value = 5 },
            { setting = 4, value = 2 },
            { setting = 5, value = 0 },
            { setting = 9, value = 1 },
        }),
    Entry(SYSTEM_ACTION_BAR, 4,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = VISIBILITY_ALWAYS_HIDDEN },
            { setting = 1, value = 1 },
            { setting = 2, value = 12 },
            { setting = 3, value = 5 },
            { setting = 4, value = 2 },
            { setting = 5, value = 0 },
            { setting = 9, value = 1 },
        }),
    Entry(SYSTEM_ACTION_BAR, 5,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = VISIBILITY_ALWAYS_HIDDEN },
            { setting = 1, value = 1 },
            { setting = 2, value = 12 },
            { setting = 3, value = 5 },
            { setting = 4, value = 2 },
            { setting = 5, value = 0 },
            { setting = 9, value = 1 },
        }),
    Entry(SYSTEM_ACTION_BAR, 6,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = VISIBILITY_ALWAYS_HIDDEN },
            { setting = 1, value = 1 },
            { setting = 2, value = 12 },
            { setting = 3, value = 5 },
            { setting = 4, value = 2 },
            { setting = 5, value = 0 },
            { setting = 9, value = 1 },
        }),
    Entry(SYSTEM_ACTION_BAR, 7,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = VISIBILITY_ALWAYS_HIDDEN },
            { setting = 1, value = 1 },
            { setting = 2, value = 12 },
            { setting = 3, value = 5 },
            { setting = 4, value = 2 },
            { setting = 5, value = 0 },
            { setting = 9, value = 1 },
        }),
    Entry(SYSTEM_ACTION_BAR, 8,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = VISIBILITY_ALWAYS_HIDDEN },
            { setting = 1, value = 1 },
            { setting = 2, value = 12 },
            { setting = 3, value = 5 },
            { setting = 4, value = 2 },
            { setting = 5, value = 0 },
            { setting = 9, value = 1 },
        }),
    Entry(SYSTEM_ACTION_BAR, 11, -- Stance bar (WoW systemIndex = 11)
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = VISIBILITY_ALWAYS_HIDDEN },
            { setting = 1, value = 1 },
            { setting = 3, value = 5 },
            { setting = 4, value = 2 },
        }),
    Entry(SYSTEM_ACTION_BAR, 12, -- Pet bar (WoW systemIndex = 12)
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = VISIBILITY_ALWAYS_HIDDEN },
            { setting = 1, value = 1 },
            { setting = 3, value = 5 },
            { setting = 4, value = 2 },
            { setting = 9, value = 0 },
        }),
    Entry(SYSTEM_ACTION_BAR, 13, -- Possess bar (WoW systemIndex = 13)
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = VISIBILITY_ALWAYS_HIDDEN },
            { setting = 1, value = 1 },
            { setting = 3, value = 5 },
            { setting = 4, value = 2 },
        }),

    -- =====================================================================
    -- System 1: Cast Bar — positioned center-bottom (used by RealUI)
    -- =====================================================================
    Entry(SYSTEM_CAST_BAR, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 200),
        {
            { setting = 0, value = 0 },
            { setting = 1, value = 0 },
            { setting = 2, value = 0 },
        }),

    -- =====================================================================
    -- System 2: Minimap — top-right corner
    -- =====================================================================
    Entry(SYSTEM_MINIMAP, nil,
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -15, -15),
        {
            { setting = 0, value = 0 },
            { setting = 1, value = 0 },
            { setting = 2, value = 5 },
        }),

    -- =====================================================================
    -- System 3: Unit Frames
    -- Indices 1-3, 8 = off-screen (oUF replaces Player, Target, Focus, Pet)
    -- Indices 4-7 = positioned (Party, Raid, Boss, Arena)
    -- =====================================================================
    Entry(SYSTEM_UNIT_FRAME, 1, -- Player (oUF replaces)
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 1, value = 0 },
            { setting = 16, value = 0 },
        }),
    Entry(SYSTEM_UNIT_FRAME, 2, -- Target (oUF replaces)
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 2, value = 0 },
            { setting = 16, value = 0 },
        }),
    Entry(SYSTEM_UNIT_FRAME, 3, -- Focus (oUF replaces)
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 2, value = 0 },
            { setting = 3, value = 0 },
            { setting = 16, value = 0 },
        }),
    Entry(SYSTEM_UNIT_FRAME, 4, -- Party frames
        Anchor("TOPLEFT", "UIParent", "TOPLEFT", 680.70001220703, -1064.6999511719),
        {
            { setting = 4, value = 0 },
            { setting = 5, value = 0 },
            { setting = 6, value = 0 },
            { setting = 10, value = 26 },
            { setting = 11, value = 8 },
            { setting = 12, value = 0 },
            { setting = 14, value = 1 },
            { setting = 16, value = 0 },
            { setting = 18, value = 0 },
            -- 12.1: setting 19 renamed IconSize -> DebuffIconSize; raw stored
            -- scale unchanged (Blizzard's own presets store 5). 22 = new
            -- BuffIconSize, added at the same value.
            { setting = 19, value = 5 },
            { setting = 20, value = 100 },
            { setting = 21, value = 5 },
            { setting = 22, value = 5 },
        }),
    Entry(SYSTEM_UNIT_FRAME, 5, -- Raid frames
        Anchor("TOPLEFT", "UIParent", "TOPLEFT", 948.09997558594, -866.70001220703),
        {
            { setting = 9, value = 0 },
            { setting = 10, value = 26 },
            { setting = 11, value = 8 },
            { setting = 12, value = 0 },
            { setting = 13, value = 0 },
            { setting = 14, value = 0 },
            { setting = 15, value = 5 },
            { setting = 18, value = 0 },
            { setting = 19, value = 5 },  -- DebuffIconSize (12.1 rename)
            { setting = 20, value = 100 },
            { setting = 21, value = 5 },
            { setting = 22, value = 5 },  -- BuffIconSize (new in 12.1)
        }),
    Entry(SYSTEM_UNIT_FRAME, 6, -- Boss frames
        Anchor("RIGHT", "UIParent", "RIGHT", -32, 314),
        {
            { setting = 3, value = 0 },
            { setting = 7, value = 1 },
            { setting = 16, value = 0 },
        }),
    Entry(SYSTEM_UNIT_FRAME, 7, -- Arena frames
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -32, -304.79998779297),
        {
            { setting = 10, value = 26 },
            { setting = 11, value = 8 },
            { setting = 12, value = 0 },
            { setting = 17, value = 1 },
            { setting = 18, value = 0 },
            { setting = 19, value = 5 },  -- DebuffIconSize (12.1 rename)
            { setting = 20, value = 100 },
            { setting = 21, value = 5 },
            { setting = 22, value = 5 },  -- BuffIconSize (new in 12.1)
        }),
    Entry(SYSTEM_UNIT_FRAME, 8, -- Pet (oUF replaces)
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 16, value = 0 },
        }),

    -- =====================================================================
    -- System 4: Encounter Bar
    -- =====================================================================
    Entry(SYSTEM_ENCOUNTER_BAR, nil,
        Anchor("CENTER", "UIParent", "CENTER", -406.90771484375, -218.58201599121),
        {}),

    -- =====================================================================
    -- System 5: Extra Abilities
    -- =====================================================================
    Entry(SYSTEM_EXTRA_ABILITIES, nil,
        Anchor("LEFT", "UIParent", "LEFT", 171.29663085938, -177.7772064209),
        {}),

    -- =====================================================================
    -- System 6: Aura Frames (Buff = index 1, Debuff = index 2, External Defensives = index 3)
    -- Top-right, below minimap
    -- =====================================================================
    Entry(SYSTEM_AURA_FRAME, 1, -- Buff Frame
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -195, -15),
        {
            { setting = 0, value = 0 },
            { setting = 1, value = 0 },
            { setting = 2, value = 0 },
            { setting = 3, value = 11 },
            { setting = 5, value = 5 },
            { setting = 6, value = 5 },
        }),
    Entry(SYSTEM_AURA_FRAME, 2, -- Debuff Frame
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -195, -105),
        {
            { setting = 0, value = 0 },
            { setting = 1, value = 0 },
            { setting = 2, value = 0 },
            { setting = 4, value = 8 },
            { setting = 5, value = 5 },
            { setting = 6, value = 5 },
            { setting = 10, value = 1 },
        }),
    Entry(SYSTEM_AURA_FRAME, 3, -- External Defensives
        Anchor("TOPLEFT", "UIParent", "TOPLEFT", 664.12640380859, -696.42596435547),
        {
            { setting = 0, value = 1 },
            { setting = 1, value = 1 },
            { setting = 2, value = 0 },
            { setting = 3, value = 10 },
            { setting = 5, value = 4 },
            { setting = 6, value = 5 },
            { setting = 8, value = 0 },
            { setting = 9, value = 100 },
        }),

    -- =====================================================================
    -- System 7: Talking Head
    -- =====================================================================
    Entry(SYSTEM_TALKING_HEAD, nil,
        Anchor("TOPLEFT", "UIParent", "TOPLEFT", 662.14819335938, -95.521003723145),
        {}),

    -- =====================================================================
    -- System 8: Chat Frame — bottom-left
    -- =====================================================================
    -- B126: x comes from CHAT_X and y is COMPUTED at BuildLayout time by
    -- Templates.ApplyComputedAnchors — do not paste an exported number back in
    -- here. The exported pair used to be 36.2 / 52.3, captured from a hand-moved
    -- layout, and it silently won every argument: CharacterInit and the
    -- new-defaults item both place chat at (6, GetChatYOffset), then
    -- InstallWizard:Complete applies the EditMode layout afterwards and EditMode
    -- (which owns system 8) put it straight back. Measured on a 3.4.0 profile as
    -- exactly 36.2 / 52.3 — the template constant, not user drift.
    --
    -- y cannot be a constant: GetChatYOffset reads the live Infobar height and
    -- adds 20 for the healing layout, so the same number means different
    -- placements at different resolutions. The 0 below is a placeholder.
    Entry(SYSTEM_CHAT_FRAME, nil,
        Anchor("BOTTOMLEFT", "UIParent", "BOTTOMLEFT", CHAT_X, 0),
        {
            { setting = 0, value = 4 },
            { setting = 1, value = 30 },
            { setting = 2, value = 1 },
            { setting = 3, value = 70 },
        }),

    -- =====================================================================
    -- System 9: Vehicle Leave Button
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
    --
    -- Resolved Enum.EditModeObjectiveTrackerSetting names (verified against
    -- wow-ui-source/Interface/AddOns/Blizzard_APIDocumentationGenerated/
    -- EditModeManagerConstantsDocumentation.lua, lines 528-530):
    --   setting = 0 -> Enum.EditModeObjectiveTrackerSetting.Height
    --   setting = 1 -> Enum.EditModeObjectiveTrackerSetting.Opacity
    --   setting = 2 -> Enum.EditModeObjectiveTrackerSetting.TextSize
    --
    -- There is NO visibility setting in the ObjectiveTracker enum. The
    -- "always shown" hard-coded value of 0 mentioned in Requirement 7.5 is
    -- intentionally NOT applied here: per Requirement 7.11, since no enum
    -- member documents that semantic, criterion 7.5's hard-coded 0 is
    -- inapplicable. Bug B (periodic disappearance) is not addressed by an
    -- enum-write at this site; see the design's "Bug Root Cause Analysis"
    -- and the inverted-anchoring fix in RealUI_Tracker/Container.lua.
    --
    -- Anchor below uses relativeTo = "UIParent" and (implicit) relativeFrame
    -- = nil (Requirement 6.3) so the saved layout never references a frame
    -- name outside EditMode's standard target set.
    -- =====================================================================
    -- Offsets come from TRACKER_X / TRACKER_Y at the top of this file, which
    -- RealUI_Tracker's AceDB defaults also read. Do not inline numbers here.
    Entry(SYSTEM_OBJECTIVE_TRACKER, nil,
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", TRACKER_X, TRACKER_Y),
        {
            { setting = 0, value = 40 },  -- Height
            { setting = 1, value = 0 },   -- Opacity
            { setting = 2, value = 0 },   -- TextSize
        }),

    -- =====================================================================
    -- System 13: Micro Menu — bottom-right
    -- =====================================================================
    Entry(SYSTEM_MICRO_MENU, nil,
        Anchor("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -15, 35),
        {
            { setting = 0, value = 0 },
            { setting = 1, value = 0 },
            { setting = 2, value = 6 },
            { setting = 3, value = 10 },
        }),

    -- =====================================================================
    -- System 14: Bags — bottom-right above micro menu
    -- =====================================================================
    Entry(SYSTEM_BAGS, nil,
        Anchor("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -15, 60),
        {
            { setting = 0, value = 0 },
            { setting = 1, value = 0 },
            { setting = 2, value = 5 },
        }),

    -- =====================================================================
    -- System 15: Status Tracking Bars (XP/Rep/Honor) — bottom-center
    -- Index 1 = primary bar, Index 2 = secondary bar
    -- =====================================================================
    Entry(SYSTEM_STATUS_TRACKING, 1,
        Anchor("BOTTOM", "StatusTrackingBarManager", "BOTTOM", 0, 0),
        {
            { setting = 3, value = 10 },
        }),
    Entry(SYSTEM_STATUS_TRACKING, 2,
        Anchor("BOTTOM", "StatusTrackingBarManager", "BOTTOM", 0, 17),
        {
            { setting = 3, value = 10 },
        }),

    -- =====================================================================
    -- System 16: Durability Frame — top-right below minimap area
    -- =====================================================================
    Entry(SYSTEM_DURABILITY, nil,
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -100, -200),
        {
            { setting = 0, value = 5 },
        }),

    -- =====================================================================
    -- System 17: Timer Bars (Duration Bars) — top-center
    -- =====================================================================
    Entry(SYSTEM_TIMER_BARS, nil,
        Anchor("TOP", "UIParent", "TOP", 0, -100),
        {
            { setting = 0, value = 0 },
        }),

    -- =====================================================================
    -- System 18: Vehicle Seat Indicator — top-right
    -- =====================================================================
    Entry(SYSTEM_VEHICLE_SEAT, nil,
        Anchor("TOPRIGHT", "UIParent", "TOPRIGHT", -10, -180),
        {
            { setting = 0, value = 10 },
        }),

    -- =====================================================================
    -- System 19: Archaeology Bar — top-center
    -- =====================================================================
    Entry(SYSTEM_ARCHAEOLOGY, nil,
        Anchor("TOP", "UIParent", "TOP", 0, -50),
        {
            { setting = 0, value = 0 },
        }),

    -- =====================================================================
    -- System 20: Cooldown Viewer
    -- Index 1 = Essential Cooldowns, Index 2 = Utility Cooldowns
    -- Index 3 = Tracked Buffs (icons), Index 4 = Tracked Buff Bars
    -- =====================================================================
    Entry(SYSTEM_COOLDOWN_VIEWER, 1, -- Essential Cooldowns
        Anchor("TOPLEFT", "UIParent", "TOPLEFT", 794.43096923828, -692.32843017578),
        {
            { setting = 0, value = 0 },
            { setting = 1, value = 12 },
            { setting = 2, value = 1 },
            { setting = 3, value = 3 },
            -- IconPadding: effective grid gap is (value - 4); 7 gives the 3px
            -- gap Aurora used to add via a taint-unsafe RefreshLayout hook
            { setting = 4, value = 7 },
            { setting = 5, value = 100 },
            { setting = 6, value = 0 },
            { setting = 8, value = 1 },
            { setting = 9, value = 1 },
            { setting = 10, value = 1 },
        }),
    Entry(SYSTEM_COOLDOWN_VIEWER, 2, -- Utility Cooldowns
        Anchor("TOPLEFT", "UIParent", "TOPLEFT", 804.86645507812, -736.42578125),
        {
            { setting = 0, value = 0 },
            { setting = 1, value = 14 },
            { setting = 2, value = 1 },
            { setting = 3, value = 5 },
            { setting = 4, value = 7 },   -- IconPadding (see Essential entry)
            { setting = 5, value = 100 },
            { setting = 6, value = 0 },
            { setting = 8, value = 1 },
            { setting = 9, value = 1 },
            { setting = 10, value = 1 },
        }),
    Entry(SYSTEM_COOLDOWN_VIEWER, 3, -- Tracked Buffs (BuffIcon)
        Anchor("CENTER", "UIParent", "CENTER", -8.7646551132202, -250.50135803223),
        {
            { setting = 0, value = 0 },
            { setting = 1, value = 1 },
            { setting = 2, value = 1 },
            { setting = 3, value = 2 },
            { setting = 4, value = 7 },   -- IconPadding (see Essential entry)
            { setting = 5, value = 100 },
            { setting = 6, value = 0 },
            { setting = 8, value = 1 },
            { setting = 9, value = 1 },
            { setting = 10, value = 1 },
        }),
    Entry(SYSTEM_COOLDOWN_VIEWER, 4, -- Tracked Buff Bars
        Anchor("BOTTOM", "UIParent", "BOTTOM", 391.52154541016, 175.15902709961),
        {
            { setting = 0, value = 1 },
            { setting = 1, value = 1 },
            { setting = 2, value = 0 },
            { setting = 3, value = 5 },
            { setting = 4, value = 0 },
            { setting = 5, value = 100 },
            { setting = 6, value = 0 },
            { setting = 7, value = 0 },
            { setting = 8, value = 1 },
            { setting = 9, value = 1 },
            { setting = 10, value = 1 },
            { setting = 11, value = 100 },
        }),

    -- =====================================================================
    -- System 21: Personal Resource Display (12.0.0) — off-screen (oUF replaces)
    -- =====================================================================
    Entry(SYSTEM_PERSONAL_RESOURCE, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, OFF_SCREEN_Y),
        {
            { setting = 0, value = 0 },
            { setting = 1, value = 0 },
        }),

    -- =====================================================================
    -- System 22: Encounter Events (12.0.0) — multiple indices
    -- Index 1 = Critical Encounter Warnings (Boss Warnings)
    -- Index 2 = Medium Encounter Warnings
    -- Index 3 = Minor Encounter Warnings
    -- Index 4 = Encounter Events 4
    -- =====================================================================
    Entry(SYSTEM_ENCOUNTER_EVENTS, 1,
        Anchor("TOP", "UIParent", "TOP", 0, -40),
        {
            { setting = 0, value = 1 },
            { setting = 1, value = 1 },
            { setting = 2, value = 0 },
            { setting = 3, value = 5 },
            { setting = 4, value = 5 },
            { setting = 5, value = 0 },
            { setting = 6, value = 50 },
            { setting = 7, value = 1 },
            { setting = 8, value = 2 },
            { setting = 9, value = 1 },
            { setting = 10, value = 0 },
            { setting = 11, value = 0 },
            { setting = 12, value = 50 },
            { setting = 13, value = 2 },
        }),
    Entry(SYSTEM_ENCOUNTER_EVENTS, 2,
        Anchor("TOP", "UIParent", "TOP", 0, -90),
        {
            { setting = 3, value = 5 },
            { setting = 4, value = 5 },
            { setting = 6, value = 50 },
            { setting = 7, value = 0 },
            { setting = 8, value = 2 },
        }),
    Entry(SYSTEM_ENCOUNTER_EVENTS, 3,
        Anchor("TOP", "UIParent", "TOP", 0, -130),
        {
            { setting = 3, value = 5 },
            { setting = 4, value = 5 },
            { setting = 6, value = 50 },
            { setting = 7, value = 0 },
            { setting = 8, value = 2 },
        }),
    Entry(SYSTEM_ENCOUNTER_EVENTS, 4,
        Anchor("TOP", "UIParent", "TOP", 0, -170),
        {
            { setting = 3, value = 5 },
            { setting = 4, value = 5 },
            { setting = 6, value = 50 },
            { setting = 7, value = 0 },
            { setting = 8, value = 2 },
        }),

    -- =====================================================================
    -- System 23: Damage Meter (12.0.0) — bottom-right above chat
    -- =====================================================================
    Entry(SYSTEM_DAMAGE_METER, nil,
        Anchor("BOTTOMRIGHT", "UIParent", "BOTTOMRIGHT", -10, 250),
        {
            { setting = 0, value = 0 },
            { setting = 1, value = 0 },
            { setting = 2, value = 1 },
            { setting = 3, value = 100 },
            { setting = 4, value = 20 },
            { setting = 5, value = 2 },
            { setting = 6, value = 50 },
            { setting = 8, value = 1 },
            { setting = 9, value = 1 },
            { setting = 10, value = 1 },
            { setting = 11, value = 5 },
            { setting = 12, value = 50 },
        }),

    -- =====================================================================
    -- System 24: Raid Warning (12.1.0) — center, above the HuD
    -- Position migrated from FrameMover's "Raid Alerts" entry (CENTER 0,214);
    -- Enum.EditModeRaidWarningSetting has no members, so no settings.
    -- =====================================================================
    Entry(SYSTEM_RAID_WARNING, nil,
        Anchor("CENTER", "UIParent", "CENTER", 0, 214),
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

-- Healing overrides: encounter bar repositioned, talking head centered, CDV tuned for healer
-- Party/raid frames (3_4, 3_5) match base — no override needed
Templates.overrides.healing = {
    -- Encounter bar: bottom-center for healer layout
    ["4_nil"] = Entry(SYSTEM_ENCOUNTER_BAR, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", -337.72973632812, 137.04301452637),
        {}),
    -- Extra abilities: shifted up for healer layout
    ["5_nil"] = Entry(SYSTEM_EXTRA_ABILITIES, nil,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 0, 380),
        {}),
    -- External Defensives: repositioned for healer view, fewer rows (setting 5=3 vs base 4)
    ["6_3"] = Entry(SYSTEM_AURA_FRAME, 3,
        Anchor("TOPLEFT", "UIParent", "TOPLEFT", 658.40002441406, -618),
        {
            { setting = 0, value = 1 },
            { setting = 1, value = 1 },
            { setting = 2, value = 0 },
            { setting = 3, value = 10 },
            { setting = 5, value = 3 },
            { setting = 6, value = 5 },
            { setting = 8, value = 0 },
            { setting = 9, value = 100 },
        }),
    -- Talking Head: top-center for healer layout
    ["7_nil"] = Entry(SYSTEM_TALKING_HEAD, nil,
        Anchor("TOP", "UIParent", "TOP", 18.717330932617, -94.512390136719),
        {}),
    -- Cooldown Viewer (idx=1): center anchor, 20-icon limit for healer
    ["20_1"] = Entry(SYSTEM_COOLDOWN_VIEWER, 1,
        Anchor("CENTER", "UIParent", "CENTER", -21.464200973511, -142.56060791016),
        {
            { setting = 0, value = 0 },    -- Orientation = Horizontal
            { setting = 1, value = 20 },   -- IconLimit
            { setting = 2, value = 1 },    -- IconDirection = Right
            { setting = 3, value = 3 },    -- BarCount
            { setting = 4, value = 7 },    -- IconPadding (gap = value - 4; see Essential entry)
            { setting = 5, value = 100 },  -- Opacity
            { setting = 6, value = 0 },
            { setting = 8, value = 1 },    -- HideWhenInactive
            { setting = 9, value = 1 },    -- ShowTimer
            { setting = 10, value = 1 },   -- ShowTooltips
        }),
    -- Cooldown Viewer (idx=2): 20-icon limit, 4 bars for healer
    ["20_2"] = Entry(SYSTEM_COOLDOWN_VIEWER, 2,
        Anchor("TOPLEFT", "UIParent", "TOPLEFT", 779.38739013672, -697.49383544922),
        {
            { setting = 0, value = 0 },    -- Orientation = Horizontal
            { setting = 1, value = 20 },   -- IconLimit
            { setting = 2, value = 1 },    -- IconDirection = Right
            { setting = 3, value = 4 },    -- BarCount
            { setting = 4, value = 7 },    -- IconPadding (gap = value - 4; see Essential entry)
            { setting = 5, value = 100 },  -- Opacity
            { setting = 6, value = 0 },
            { setting = 8, value = 1 },    -- HideWhenInactive
            { setting = 9, value = 1 },    -- ShowTimer
            { setting = 10, value = 1 },   -- ShowTooltips
        }),
    -- Cooldown Viewer (idx=3): Tracked Buffs, repositioned for healer
    ["20_3"] = Entry(SYSTEM_COOLDOWN_VIEWER, 3,
        Anchor("TOPLEFT", "UIParent", "TOPLEFT", 817.06176757812, -728.20593261719),
        {
            { setting = 0, value = 0 },    -- Orientation = Horizontal
            { setting = 1, value = 1 },    -- IconLimit
            { setting = 2, value = 1 },    -- IconDirection = Right
            { setting = 3, value = 2 },    -- BarCount
            { setting = 4, value = 7 },    -- IconPadding (gap = value - 4; see Essential entry)
            { setting = 5, value = 100 },  -- Opacity
            { setting = 6, value = 0 },
            { setting = 8, value = 1 },    -- HideWhenInactive
            { setting = 9, value = 1 },    -- ShowTimer
            { setting = 10, value = 1 },   -- ShowTooltips
        }),
    -- Cooldown Viewer (idx=4): Tracked Buff Bars, 3 bars for healer
    ["20_4"] = Entry(SYSTEM_COOLDOWN_VIEWER, 4,
        Anchor("BOTTOM", "UIParent", "BOTTOM", 352.61993408203, 203.55081176758),
        {
            { setting = 0, value = 1 },    -- Mode = Bars
            { setting = 1, value = 1 },
            { setting = 2, value = 0 },
            { setting = 3, value = 3 },    -- BarCount
            { setting = 4, value = 0 },    -- Padding
            { setting = 5, value = 100 },  -- Opacity
            { setting = 6, value = 0 },
            { setting = 7, value = 0 },
            { setting = 8, value = 1 },    -- HideWhenInactive
            { setting = 9, value = 1 },    -- ShowTimer
            { setting = 10, value = 1 },   -- ShowTooltips
            { setting = 11, value = 100 }, -- BarWidthScale
        }),
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
        -- Objective tracker: vertical tightening only. offsetX was +5, which
        -- pulled it back to -31 against a side-bar column that ends at -30 —
        -- a 1px gap, and the overlap again on any enlarged button size. The
        -- bars are the same width on a laptop as anywhere else, so this axis
        -- has nothing to reclaim (B116, 2026-08-24).
        ["12_nil"] = { offsetX = 0, offsetY = 20 },
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
--- Removes every entry for one EditMode system from a built layout.
function Templates.StripSystem(layout, system)
    for i = #layout, 1, -1 do
        if layout[i].system == system then
            table.remove(layout, i)
        end
    end
end

--- Appends Blizzard's own Modern-preset entries for one system, read from
-- EDIT_MODE_MODERN_SYSTEM_MAP (Blizzard_EditMode; loaded on every
-- retail-family client including WoW Forever, with per-game constants).
-- A system merely *omitted* from a layout is not reset by EditMode: it keeps
-- whatever the previously active layout left it with (seen 2026-09-22 on
-- Forever, where the main bar stayed hidden after the entries were dropped),
-- so "leave it to Blizzard" has to be written out explicitly.
-- @return boolean  true if the map was available and entries were added
function Templates.AppendBlizzardDefaults(layout, system)
    local map = _G.EDIT_MODE_MODERN_SYSTEM_MAP
    local entries = map and map[system]
    if not entries then
        return false
    end
    for systemIndex, info in pairs(entries) do
        local settings = {}
        for setting, value in pairs(info.settings or {}) do
            settings[#settings + 1] = { setting = setting, value = value }
        end
        local a = info.anchorInfo or {}
        layout[#layout + 1] = Entry(system, systemIndex,
            Anchor(a.point, a.relativeTo, a.relativePoint, a.offsetX, a.offsetY),
            settings, true)
    end
    return true
end
Templates.SYSTEM_ACTION_BAR = SYSTEM_ACTION_BAR

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
-- Utility: ApplyComputedAnchors (B126)
--
-- Some anchors cannot be constants in `Templates.base` because they depend on
-- runtime state. They are written here instead, at BuildLayout time, so the
-- template stays the single definition and no exported number can quietly
-- disagree with the code that places the same frame.
--
-- Must run BEFORE ApplyDisplayAdjustments — those are deltas added on top, and
-- computing afterwards would discard them.
--
-- Chat (system 8): `RealUI.GetChatYOffset` reads the live Infobar height and
-- adds 20 for the healing layout, so a fixed y means different placements at
-- different resolutions and roles. Falls back to leaving the placeholder alone
-- if the helper is somehow unavailable, which is better than writing a 0 that
-- would put chat on the screen edge.
--
-- @param layout table  Array of system entries (modified in place)
-- @param role string  "dpstank" or "healing"
---------------------------------------------------------------------------
function Templates.ApplyComputedAnchors(layout, role)
    if not RealUI.GetChatYOffset then return layout end

    local chatY = RealUI.GetChatYOffset(role == "healing" and 2 or 1)
    if not chatY then return layout end

    for _, entry in ipairs(layout) do
        if entry.system == SYSTEM_CHAT_FRAME and entry.anchorInfo then
            entry.anchorInfo.offsetX = CHAT_X
            entry.anchorInfo.offsetY = chatY
            break
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
