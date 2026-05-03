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
        db.position.maxHeightOffset = op.position.negheightofs or db.position.maxHeightOffset
    end

    -- Context hide/collapse
    if op.hidden then
        for k, v in pairs(op.hidden.hide     or {}) do db.context.hide[k]     = v end
        for k, v in pairs(op.hidden.collapse or {}) do db.context.collapse[k] = v end

        if op.hidden.collapseframe then
            local cf = op.hidden.collapseframe
            db.context.collapseModules.quest       = cf.quest
            db.context.collapseModules.campaign    = cf.campaign
            db.context.collapseModules.adventure   = cf.adventure
            -- 8.2: Fix the "proffesion" → "professions" typo during migration
            db.context.collapseModules.professions = cf.proffesion
            db.context.collapseModules.bonus       = cf.bonus
            db.context.collapseModules.world       = cf.world
        end

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

---------------------------------------------------------
-- Config panel (Task 14)
---------------------------------------------------------

local ACR = LibStub("AceConfigRegistry-3.0", true)

-- Fallback anchor points table in case RealUI is not loaded
local ANCHOR_POINTS = {
    "TOPLEFT",    "TOP",    "TOPRIGHT",
    "LEFT",       "CENTER", "RIGHT",
    "BOTTOMLEFT", "BOTTOM", "BOTTOMRIGHT",
}

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

local function GetAnchorPoints()
    local RealUI_Core = _G.RealUI
    if RealUI_Core and RealUI_Core.globals and RealUI_Core.globals.anchorPoints then
        return RealUI_Core.globals.anchorPoints
    end
    return ANCHOR_POINTS
end

local function BuildTrackerOptions()
    local db = RealUI_Tracker.db.profile

    -- Helper: get CombatFader module (may be nil)
    local function GetCombatFader()
        local RealUI_Core = _G.RealUI
        return RealUI_Core and RealUI_Core:GetModule("CombatFader", true)
    end

    ---------------------------------------------------------------------------
    -- Position section
    ---------------------------------------------------------------------------
    local positionArgs = {
        enabled = {
            name = "Custom Position",
            desc = "Enable custom positioning. When disabled, the tracker uses the Blizzard default position.",
            type = "toggle",
            width = "full",
            get = function() return db.position.enabled end,
            set = function(_, value)
                db.position.enabled = value
                RealUI_Tracker:UpdatePosition()
            end,
            order = 1,
        },
        anchorTo = {
            name = "Anchor To",
            desc = "The point on the screen to anchor to.",
            type = "select",
            values = GetAnchorPoints,
            get = function()
                local points = GetAnchorPoints()
                for k, v in next, points do
                    if v == db.position.anchorTo then return k end
                end
            end,
            set = function(_, value)
                db.position.anchorTo = GetAnchorPoints()[value]
                RealUI_Tracker:UpdatePosition()
            end,
            disabled = function() return not db.position.enabled end,
            order = 10,
        },
        anchorFrom = {
            name = "Anchor From",
            desc = "The point on the tracker frame to anchor from.",
            type = "select",
            values = GetAnchorPoints,
            get = function()
                local points = GetAnchorPoints()
                for k, v in next, points do
                    if v == db.position.anchorFrom then return k end
                end
            end,
            set = function(_, value)
                db.position.anchorFrom = GetAnchorPoints()[value]
                RealUI_Tracker:UpdatePosition()
            end,
            disabled = function() return not db.position.enabled end,
            order = 20,
        },
        x = {
            name = "X Offset",
            type = "input",
            width = "half",
            get = function() return tostring(db.position.x) end,
            set = function(_, value)
                db.position.x = tonumber(value) or db.position.x
                RealUI_Tracker:UpdatePosition()
            end,
            disabled = function() return not db.position.enabled end,
            order = 30,
        },
        y = {
            name = "Y Offset",
            type = "input",
            width = "half",
            get = function() return tostring(db.position.y) end,
            set = function(_, value)
                db.position.y = tonumber(value) or db.position.y
                RealUI_Tracker:UpdatePosition()
            end,
            disabled = function() return not db.position.enabled end,
            order = 40,
        },
        maxHeightOffset = {
            name = "Height Offset",
            desc = "How much shorter than screen height to make the tracker frame.",
            type = "input",
            width = "half",
            get = function() return tostring(db.position.maxHeightOffset) end,
            set = function(_, value)
                db.position.maxHeightOffset = tonumber(value) or db.position.maxHeightOffset
                RealUI_Tracker:UpdatePosition()
            end,
            disabled = function() return not db.position.enabled end,
            order = 50,
        },
    }

    ---------------------------------------------------------------------------
    -- Context section
    ---------------------------------------------------------------------------
    local contextArgs = {
        enabled = {
            name = "Enabled",
            desc = "Enable automatic hide/collapse based on instance type.",
            type = "toggle",
            width = "full",
            get = function() return db.context.enabled end,
            set = function(_, value)
                db.context.enabled = value
                RealUI_Tracker:UpdateState()
            end,
            order = 1,
        },
        hideHeader = {
            name = "Hide tracker completely in:",
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
        collapseGap = {
            name = " ",
            type = "description",
            order = 19,
        },
        collapseHeader = {
            name = "Collapse tracker modules in:",
            type = "description",
            order = 20,
        },
        collapseArena = {
            name = "Arena",
            type = "toggle",
            get = function() return db.context.collapse.arena end,
            set = function(_, value) db.context.collapse.arena = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 21,
        },
        collapseRaid = {
            name = "Raids",
            type = "toggle",
            get = function() return db.context.collapse.raid end,
            set = function(_, value) db.context.collapse.raid = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 22,
        },
        collapsePvp = {
            name = "Battlegrounds",
            type = "toggle",
            get = function() return db.context.collapse.pvp end,
            set = function(_, value) db.context.collapse.pvp = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 23,
        },
        collapseParty = {
            name = "Dungeons",
            type = "toggle",
            get = function() return db.context.collapse.party end,
            set = function(_, value) db.context.collapse.party = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 24,
        },
        collapseScenario = {
            name = "Scenarios",
            type = "toggle",
            get = function() return db.context.collapse.scenario end,
            set = function(_, value) db.context.collapse.scenario = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 25,
        },
        modulesGap = {
            name = " ",
            type = "description",
            order = 29,
        },
        modulesHeader = {
            name = "Modules to collapse:",
            type = "description",
            order = 30,
        },
        collapseQuest = {
            name = "Quests",
            type = "toggle",
            get = function() return db.context.collapseModules.quest end,
            set = function(_, value) db.context.collapseModules.quest = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 31,
        },
        collapseCampaign = {
            name = "Campaign",
            type = "toggle",
            get = function() return db.context.collapseModules.campaign end,
            set = function(_, value) db.context.collapseModules.campaign = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 32,
        },
        collapseAdventure = {
            name = "Adventures",
            type = "toggle",
            get = function() return db.context.collapseModules.adventure end,
            set = function(_, value) db.context.collapseModules.adventure = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 33,
        },
        collapseProfessions = {
            name = "Professions",
            type = "toggle",
            get = function() return db.context.collapseModules.professions end,
            set = function(_, value) db.context.collapseModules.professions = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 34,
        },
        collapseBonus = {
            name = "Bonus Objectives",
            type = "toggle",
            get = function() return db.context.collapseModules.bonus end,
            set = function(_, value) db.context.collapseModules.bonus = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 35,
        },
        collapseWorld = {
            name = "World Quests",
            type = "toggle",
            get = function() return db.context.collapseModules.world end,
            set = function(_, value) db.context.collapseModules.world = value; RealUI_Tracker:UpdateState() end,
            disabled = function() return not db.context.enabled end,
            order = 36,
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
        difficultyColor = {
            name = "Difficulty Color",
            desc = "Color quest headers by quest difficulty level.",
            type = "toggle",
            get = function() return db.display.difficultyColor end,
            set = function(_, value) db.display.difficultyColor = value end,
            order = 2,
        },
        wrapText = {
            name = "Wrap Text",
            desc = "Allow objective text to wrap to multiple lines.",
            type = "toggle",
            get = function() return db.display.wrapText end,
            set = function(_, value) db.display.wrapText = value end,
            order = 3,
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
                name = "Enhanced objective tracker with context-aware hide/collapse, combat fading, and display improvements.",
                type = "description",
                fontSize = "medium",
                order = 1,
            },
            position = {
                name = "Position",
                type = "group",
                order = 10,
                args = positionArgs,
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
    if not ACR then return end
    local rootOptions = ACR:GetOptionsTable("RealUI", "dialog", "RealUI-1.0")
    if rootOptions and rootOptions.args then
        rootOptions.args.tracker = BuildTrackerOptions()
        ACR:NotifyChange("RealUI")
    end
end

function RealUI_Tracker:SetupConfig()
    local RealUI_Core = _G.RealUI
    if not RealUI_Core then return end
    if not ACR then return end

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
