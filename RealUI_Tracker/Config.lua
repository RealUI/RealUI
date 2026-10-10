local RealUI_Tracker = LibStub("AceAddon-3.0"):GetAddon("RealUI_Tracker")

---------------------------------------------------------
-- ObjectivesAdv config migration (Task 8)
---------------------------------------------------------

-- 8.1–8.3: Migrate settings from the old ObjectivesAdv namespace in RealUI.db
-- into RealUI_Tracker.db.profile. Fixes the "proffesion" → "professions" typo.
-- Gated on db.global.migratedFromObjectivesAdv so it only runs once per account.
function RealUI_Tracker:MigrateFromObjectivesAdv()
    -- 8.3: Gate — skip if already migrated
    if self.db.global.migratedFromObjectivesAdv then return end

    local RealUI_Core = _G.RealUI
    local old = RealUI_Core and RealUI_Core.db and RealUI_Core.db:GetNamespace("Objectives Adv.", true)
    if not old then return end
    local op = old.profile
    if not op then return end

    local db = self.db.profile

    -- Position
    if op.position then
        db.position.anchorTo        = op.position.anchorto   or db.position.anchorTo
        db.position.anchorFrom      = op.position.anchorfrom or db.position.anchorFrom
        db.position.x               = op.position.x          or db.position.x
        db.position.y               = op.position.y          or db.position.y
    end

    -- Context hide. The old collapse / collapseframe settings are not carried
    -- over: the per-instance collapse was dropped (tracker-widget-taint-rewrite D2).
    if op.hidden then
        for k, v in pairs(op.hidden.hide     or {}) do db.context.hide[k]     = v end

        -- Combat fade
        if op.hidden.combatfade then
            db.combatFade.enabled = op.hidden.combatfade.enabled
            if op.hidden.combatfade.opacity then
                local o = op.hidden.combatfade.opacity
                db.combatFade.opacity.incombat    = o.incombat
                db.combatFade.opacity.hurt        = o.hurt
                db.combatFade.opacity.target      = o.target
                db.combatFade.opacity.harmtarget  = o.harmtarget
                db.combatFade.opacity.outofcombat = o.outofcombat
            end
        end
    end

    -- 8.3: Mark migration done so it only runs once
    self.db.global.migratedFromObjectivesAdv = true
end

-- Remove saved settings whose features are gone, from every profile (the
-- defaults no longer carry them).
--  * tracker-widget-taint-rewrite D2, 2026-10-05: the per-instance module
--    collapse. It called SetCollapsed on the tracker modules from RealUI
--    code, which writes Blizzard's `isCollapsed` and schedules the tracker's
--    layout under RealUI taint; there is no clean version of it. The
--    per-instance hide settings stay and run as a fade.
--  * 2026-10-10: difficulty colour (retail scales most quests to the
--    player's level, and Forever colours titles natively) and Wrap Text,
--    which nothing ever read.
function RealUI_Tracker:DropRemovedSettings()
    local profiles = self.db.sv and self.db.sv.profiles
    if not profiles then return end
    for _, profile in pairs(profiles) do
        local ctx = profile.context
        if ctx then
            ctx.collapse = nil
            ctx.collapseModules = nil
            -- The opt-in Hidden mode was dropped the next day (D1).
            ctx.hideMode = nil
        end
        local display = profile.display
        if display then
            display.difficultyColor = nil
            display.wrapText = nil
        end
    end
end

---------------------------------------------------------
-- Config panel (Task 14)
---------------------------------------------------------

-- AceConfigRegistry-3.0 ships inside RealUI_Config, which is LoadOnDemand, so it
-- does not exist when this file runs. Resolve it lazily instead.
local ACR
local function GetACR()
    ACR = ACR or LibStub("AceConfigRegistry-3.0", true)
    return ACR
end

-- Combat fade opacity key order and labels (matches CombatFader.lua keyOrder)
local FADE_KEY_ORDER = {
    "incombat",
    "harmtarget",
    "target",
    "hurt",
    "outofcombat",
}
local FADE_KEY_LABELS = {
    incombat    = "In Combat",
    hurt        = "Hurt / Low Power",
    harmtarget  = "Hostile Target",
    target      = "Friendly Target",
    outofcombat = "Out of Combat",
}

local function BuildTrackerOptions()
    local db = RealUI_Tracker.db.profile

    -- Helper: get CombatFader module (may be nil)
    local function GetCombatFader()
        local RealUI_Core = _G.RealUI
        return RealUI_Core and RealUI_Core:GetModule("CombatFader", true)
    end

    ---------------------------------------------------------------------------
    -- Context section
    ---------------------------------------------------------------------------
    local contextArgs = {
        enabled = {
            name = "Enabled",
            desc = "Hide the tracker automatically in the instance types chosen below.",
            type = "toggle",
            width = "full",
            get = function() return db.context.enabled end,
            set = function(_, value)
                db.context.enabled = value
                RealUI_Tracker:UpdateState()
            end,
            order = 1,
        },
        hideNote = {
            name = "The tracker fades out completely in these instance types and comes back when you "
                .. "leave. It stays clickable where it sits, quest item buttons included.",
            type = "description",
            order = 5,
        },
        hideHeader = {
            name = "Hide tracker in:",
            type = "description",
            order = 9,
        },
        hideArena = {
            name = "Arena",
            type = "toggle",
            get = function() return db.context.hide.arena end,
            set = function(_, value) db.context.hide.arena = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 10,
        },
        hideRaid = {
            name = "Raids",
            type = "toggle",
            get = function() return db.context.hide.raid end,
            set = function(_, value) db.context.hide.raid = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 11,
        },
        hidePvp = {
            name = "Battlegrounds",
            type = "toggle",
            get = function() return db.context.hide.pvp end,
            set = function(_, value) db.context.hide.pvp = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 12,
        },
        hideParty = {
            name = "Dungeons",
            type = "toggle",
            get = function() return db.context.hide.party end,
            set = function(_, value) db.context.hide.party = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 13,
        },
        hideScenario = {
            name = "Scenarios",
            type = "toggle",
            get = function() return db.context.hide.scenario end,
            set = function(_, value) db.context.hide.scenario = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 14,
        },
    }

    ---------------------------------------------------------------------------
    -- Combat Fade section (14.4: read/write db.profile.combatFade directly,
    -- call CombatFader:RefreshMod() on changes — do NOT use AddFadeConfig)
    ---------------------------------------------------------------------------
    local fadeOpacityArgs = {}
    for i, key in ipairs(FADE_KEY_ORDER) do
        fadeOpacityArgs[key] = {
            name = FADE_KEY_LABELS[key],
            type = "range",
            isPercent = true,
            min = 0, max = 1, step = 0.05,
            get = function() return db.combatFade.opacity[key] end,
            set = function(_, value)
                db.combatFade.opacity[key] = value
                local cf = GetCombatFader()
                if cf then cf:RefreshMod() end
            end,
            disabled = function() return not db.combatFade.enabled end,
            order = i,
        }
    end

    local combatFadeArgs = {
        enabled = {
            name = "Enabled",
            desc = "Enable combat-based opacity fading for the tracker.",
            type = "toggle",
            width = "full",
            get = function() return db.combatFade.enabled end,
            set = function(_, value)
                db.combatFade.enabled = value
                local cf = GetCombatFader()
                if cf then cf:RefreshMod() end
            end,
            order = 1,
        },
        opacity = {
            name = "Opacity",
            type = "group",
            inline = true,
            disabled = function() return not db.combatFade.enabled end,
            order = 10,
            args = fadeOpacityArgs,
        },
    }

    ---------------------------------------------------------------------------
    -- Display section
    ---------------------------------------------------------------------------
    local displayArgs = {
        questCount = {
            name = "Quest Count",
            desc = "Show the number of tracked items in each module header.",
            type = "toggle",
            get = function() return db.display.questCount end,
            set = function(_, value) db.display.questCount = value end,
            order = 1,
        },
    }

    ---------------------------------------------------------------------------
    -- Top-level Tracker group
    ---------------------------------------------------------------------------
    return {
        name = "Tracker",
        type = "group",
        childGroups = "tab",
        order = 7,
        args = {
            header = {
                name = "RealUI Tracker",
                type = "header",
                order = 0,
            },
            desc = {
                name = "Fades Blizzard's objective tracker in combat and in chosen instance types, and counts what each section tracks.",
                type = "description",
                fontSize = "medium",
                order = 1,
            },
            context = {
                name = "Context",
                type = "group",
                order = 20,
                args = contextArgs,
            },
            combatFade = {
                name = "Combat Fade",
                type = "group",
                order = 30,
                args = combatFadeArgs,
            },
            display = {
                name = "Display",
                type = "group",
                order = 40,
                args = displayArgs,
            },
        },
    }
end

---------------------------------------------------------
-- 14.2: Inject options into the RealUI config tree
---------------------------------------------------------

local function InjectTrackerOptions()
    local acr = GetACR()
    if not acr then return end

    local rootOptions = acr:GetOptionsTable("RealUI", "dialog", "RealUI-1.0")
    if rootOptions and rootOptions.args then
        rootOptions.args.tracker = BuildTrackerOptions()
        acr:NotifyChange("RealUI")
    end
end

function RealUI_Tracker:SetupConfig()
    local RealUI_Core = _G.RealUI
    if not RealUI_Core then return end

    -- If RealUI_Config is already loaded, inject on next frame
    if C_AddOns.IsAddOnLoaded("RealUI_Config") then
        C_Timer.After(0, InjectTrackerOptions)
        return
    end

    -- Otherwise wait for RealUI_Config to load
    local frame = CreateFrame("Frame")
    frame:RegisterEvent("ADDON_LOADED")
    frame:SetScript("OnEvent", function(f, _, addonName)
        if addonName == "RealUI_Config" then
            f:UnregisterEvent("ADDON_LOADED")
            C_Timer.After(0, InjectTrackerOptions)
        end
    end)
end
