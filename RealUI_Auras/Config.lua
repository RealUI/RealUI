-- Config.lua: AceConfig options table for RealUI_Auras
-- Injects an "Auras" group into the shared RealUI options tree
-- after RealUI_Config loads.

local AurasAddon = LibStub("AceAddon-3.0"):GetAddon("RealUI_Auras")
local ACR = LibStub("AceConfigRegistry-3.0")

local Groups -- resolved lazily from AurasAddon.Groups

---------------------------------------------------------------------------
-- Group iteration order (matches Groups.lua GROUP_ORDER)
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
-- Forward declarations
---------------------------------------------------------------------------
local BuildAurasOptions, BuildGroupOptions, BuildSpellListOptions, BuildColourOptions, BuildCooldownMgrOptions

---------------------------------------------------------------------------
-- Injection helper — inserts the auras options into the RealUI tree
---------------------------------------------------------------------------
local function InjectAurasOptions()
    local rootOptions = ACR:GetOptionsTable("RealUI", "dialog", "RealUI-1.0")
    if rootOptions and rootOptions.args then
        rootOptions.args.auras = BuildAurasOptions()
        ACR:NotifyChange("RealUI")
    end
end

---------------------------------------------------------------------------
-- Hook: inject options after RealUI_Config registers its table
---------------------------------------------------------------------------
local frame = CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:SetScript("OnEvent", function(self, _, addonName)
    if addonName == "RealUI_Config" then
        self:UnregisterEvent("ADDON_LOADED")
        -- Defer to ensure RealUI_Config has finished InitializeOptions
        C_Timer.After(0, InjectAurasOptions)
    end
end)

---------------------------------------------------------------------------
-- Fallback: if RealUI_Config is already loaded when this file runs,
-- ADDON_LOADED won't fire. Check and inject on next frame.
---------------------------------------------------------------------------
if C_AddOns.IsAddOnLoaded("RealUI_Config") then
    frame:UnregisterEvent("ADDON_LOADED")
    C_Timer.After(0, InjectAurasOptions)
end

---------------------------------------------------------------------------
-- BuildAurasOptions — top-level "Auras" group
---------------------------------------------------------------------------
function BuildAurasOptions()
    Groups = AurasAddon.Groups

    -- Guard: if RealUI_Auras is not enabled, show a message
    if not AurasAddon:IsEnabled() then
        return {
            name = "Auras",
            type = "group",
            order = 6,
            args = {
                notLoaded = {
                    name = "RealUI_Auras is not enabled. Enable it in the addon list and reload.",
                    type = "description",
                    fontSize = "medium",
                    order = 1,
                },
            },
        }
    end

    local args = {}

    -- Per-group options (one child group per aura group)
    for i, name in ipairs(GROUP_ORDER) do
        args[name] = BuildGroupOptions(name, i * 10)
    end

    -- Global sections
    args.cooldownMgr = BuildCooldownMgrOptions(100)
    args.spellLists  = BuildSpellListOptions(200)
    args.colours     = BuildColourOptions(300)

    return {
        name = "Auras",
        type = "group",
        childGroups = "tab",
        order = 6,
        args = args,
    }
end

---------------------------------------------------------------------------
-- GetSpellListValues — shared helper for spell list select controls
---------------------------------------------------------------------------
local function GetSpellListValues()
    local values = { [""] = "None" }
    for listName in pairs(AurasAddon.db.global.SpellLists) do
        values[listName] = listName
    end
    return values
end

---------------------------------------------------------------------------
-- BuildGroupOptions — per-group controls (enable, layout, direction,
-- filters, sort, desaturation, anchors, spell lists, cast-by)
---------------------------------------------------------------------------
function BuildGroupOptions(groupName, order)
    local Icons = AurasAddon.Icons

    -- Helper: standard setter that writes to db and redraws the group
    local function SetAndRedraw(key)
        return function(_, value)
            AurasAddon.db.profile.groups[groupName][key] = value
            Groups.Redraw(Groups.Get(groupName))
            ACR:NotifyChange("RealUI")
        end
    end

    -- Helper: standard getter that reads from db
    local function GetFromDB(key)
        return function()
            return AurasAddon.db.profile.groups[groupName][key]
        end
    end

    -- Helper: disabled when group is disabled
    local function IsGroupDisabled()
        return AurasAddon.db.profile.groups[groupName].disabled
    end

    return {
        name = groupName,
        type = "group",
        order = order,
        args = {
            ---------------------------------------------------------
            -- 4.1  Enable/disable toggle
            ---------------------------------------------------------
            enabled = {
                name = "Enable",
                desc = "Enable or disable this aura group.",
                type = "toggle",
                order = 1,
                width = "full",
                get = function()
                    return not AurasAddon.db.profile.groups[groupName].disabled
                end,
                set = function(_, value)
                    local group = AurasAddon.db.profile.groups[groupName]
                    group.disabled = not value
                    if group.disabled then
                        -- Disabling: release icons and hide container
                        Icons.ReleaseAll(group)
                        local state = Groups.GetState(groupName)
                        if state.container then
                            state.container:Hide()
                        end
                    else
                        -- Enabling: redraw the group
                        Groups.Redraw(group)
                    end
                    ACR:NotifyChange("RealUI")
                end,
            },

            ---------------------------------------------------------
            -- 4.2  Layout controls
            ---------------------------------------------------------
            iconSize = {
                name = "Icon Size",
                desc = "Size of each aura icon in pixels.",
                type = "range",
                order = 10,
                min = 12,
                max = 64,
                step = 1,
                get = GetFromDB("iconSize"),
                set = SetAndRedraw("iconSize"),
                disabled = IsGroupDisabled,
            },
            spacingX = {
                name = "Horizontal Spacing",
                desc = "Horizontal spacing between icons.",
                type = "range",
                order = 11,
                min = -20,
                max = 20,
                step = 1,
                get = GetFromDB("spacingX"),
                set = SetAndRedraw("spacingX"),
                disabled = IsGroupDisabled,
            },
            spacingY = {
                name = "Vertical Spacing",
                desc = "Vertical spacing between icon rows.",
                type = "range",
                order = 12,
                min = -20,
                max = 20,
                step = 1,
                get = GetFromDB("spacingY"),
                set = SetAndRedraw("spacingY"),
                disabled = IsGroupDisabled,
            },
            wrap = {
                name = "Icons Per Row",
                desc = "Number of icons before wrapping to the next row.",
                type = "range",
                order = 13,
                min = 1,
                max = 40,
                step = 1,
                get = GetFromDB("wrap"),
                set = SetAndRedraw("wrap"),
                disabled = IsGroupDisabled,
            },
            maxBars = {
                name = "Max Icons",
                desc = "Maximum number of icons to display.",
                type = "range",
                order = 14,
                min = 1,
                max = 40,
                step = 1,
                get = GetFromDB("maxBars"),
                set = SetAndRedraw("maxBars"),
                disabled = IsGroupDisabled,
            },

            ---------------------------------------------------------
            -- 4.3  Direction controls
            ---------------------------------------------------------
            iconAlign = {
                name = "Icon Alignment",
                desc = "Align icons to the left or right edge of the group.",
                type = "select",
                order = 20,
                values = { LEFT = "Left", RIGHT = "Right" },
                get = GetFromDB("iconAlign"),
                set = SetAndRedraw("iconAlign"),
                disabled = IsGroupDisabled,
            },

            ---------------------------------------------------------
            -- 5.1  Filter controls
            ---------------------------------------------------------
            filterHeader = {
                name = "Filters",
                type = "header",
                order = 29,
            },
            checkDuration = {
                name = "Check Duration",
                desc = "Enable filtering auras by their total duration.",
                type = "toggle",
                order = 30,
                get = GetFromDB("checkDuration"),
                set = SetAndRedraw("checkDuration"),
                disabled = IsGroupDisabled,
            },
            filterDuration = {
                name = "Max Duration",
                desc = "Only show auras with a total duration up to this many seconds.",
                type = "range",
                order = 31,
                min = 0,
                max = 3600,
                step = 1,
                get = GetFromDB("filterDuration"),
                set = SetAndRedraw("filterDuration"),
                disabled = function()
                    return IsGroupDisabled() or not AurasAddon.db.profile.groups[groupName].checkDuration
                end,
            },
            checkTimeLeft = {
                name = "Check Time Left",
                desc = "Enable filtering auras by their remaining time.",
                type = "toggle",
                order = 32,
                get = GetFromDB("checkTimeLeft"),
                set = SetAndRedraw("checkTimeLeft"),
                disabled = IsGroupDisabled,
            },
            filterTimeLeft = {
                name = "Max Time Left",
                desc = "Only show auras with time remaining up to this many seconds.",
                type = "range",
                order = 33,
                min = 0,
                max = 3600,
                step = 1,
                get = GetFromDB("filterTimeLeft"),
                set = SetAndRedraw("filterTimeLeft"),
                disabled = function()
                    return IsGroupDisabled() or not AurasAddon.db.profile.groups[groupName].checkTimeLeft
                end,
            },
            showNoDuration = {
                name = "Show No Duration",
                desc = "Show auras that have no duration (permanent auras).",
                type = "toggle",
                order = 34,
                get = GetFromDB("showNoDuration"),
                set = SetAndRedraw("showNoDuration"),
                disabled = IsGroupDisabled,
            },

            ---------------------------------------------------------
            -- 5.2  Sort controls
            ---------------------------------------------------------
            sortHeader = {
                name = "Sorting",
                type = "header",
                order = 39,
            },
            timeSort = {
                name = "Sort by Time",
                desc = "Sort auras by their remaining time.",
                type = "toggle",
                order = 40,
                get = GetFromDB("timeSort"),
                set = SetAndRedraw("timeSort"),
                disabled = IsGroupDisabled,
            },
            reverseSort = {
                name = "Reverse Sort",
                desc = "Reverse the sort order.",
                type = "toggle",
                order = 41,
                get = GetFromDB("reverseSort"),
                set = SetAndRedraw("reverseSort"),
                disabled = function()
                    return IsGroupDisabled() or not AurasAddon.db.profile.groups[groupName].timeSort
                end,
            },

            ---------------------------------------------------------
            -- 5.3  Desaturation controls
            ---------------------------------------------------------
            desatHeader = {
                name = "Desaturation",
                type = "header",
                order = 49,
            },
            desaturate = {
                name = "Desaturate",
                desc = "Desaturate icons for auras not cast by you.",
                type = "toggle",
                order = 50,
                get = GetFromDB("desaturate"),
                set = SetAndRedraw("desaturate"),
                disabled = IsGroupDisabled,
            },
            desaturateFriend = {
                name = "Desaturate Friendly",
                desc = "Also desaturate friendly auras not cast by you.",
                type = "toggle",
                order = 51,
                get = GetFromDB("desaturateFriend"),
                set = SetAndRedraw("desaturateFriend"),
                disabled = function()
                    return IsGroupDisabled() or not AurasAddon.db.profile.groups[groupName].desaturate
                end,
            },

            ---------------------------------------------------------
            -- 5.4  Anchor offset controls
            ---------------------------------------------------------
            anchorHeader = {
                name = "Anchor Offsets",
                type = "header",
                order = 59,
            },
            anchorX = {
                name = "X Offset",
                desc = "Horizontal offset from the anchor point.",
                type = "range",
                order = 60,
                min = -200,
                max = 200,
                step = 1,
                get = GetFromDB("anchorX"),
                set = function(_, value)
                    local group = AurasAddon.db.profile.groups[groupName]
                    group.anchorX = value
                    -- Re-anchor the container frame
                    local state = Groups.GetState(groupName)
                    if state.container then
                        local parentName = group.anchorFrame or group.parentFrame
                        local parent = parentName and _G[parentName]
                        if parent then
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
                            state.container:ClearAllPoints()
                            state.container:SetPoint(myPoint, parent, parentPoint, group.anchorX or 0, group.anchorY or 0)
                        end
                    end
                    Groups.Redraw(Groups.Get(groupName))
                    ACR:NotifyChange("RealUI")
                end,
                disabled = IsGroupDisabled,
            },
            anchorY = {
                name = "Y Offset",
                desc = "Vertical offset from the anchor point.",
                type = "range",
                order = 61,
                min = -200,
                max = 200,
                step = 1,
                get = GetFromDB("anchorY"),
                set = function(_, value)
                    local group = AurasAddon.db.profile.groups[groupName]
                    group.anchorY = value
                    -- Re-anchor the container frame
                    local state = Groups.GetState(groupName)
                    if state.container then
                        local parentName = group.anchorFrame or group.parentFrame
                        local parent = parentName and _G[parentName]
                        if parent then
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
                            state.container:ClearAllPoints()
                            state.container:SetPoint(myPoint, parent, parentPoint, group.anchorX or 0, group.anchorY or 0)
                        end
                    end
                    Groups.Redraw(Groups.Get(groupName))
                    ACR:NotifyChange("RealUI")
                end,
                disabled = IsGroupDisabled,
            },

            ---------------------------------------------------------
            -- 5.5  Spell list assignment selects
            ---------------------------------------------------------
            spellListHeader = {
                name = "Spell List Assignment",
                type = "header",
                order = 69,
            },
            filterBuffTable = {
                name = "Buff Filter List",
                desc = "Spell list used to filter buffs for this group.",
                type = "select",
                order = 70,
                values = GetSpellListValues,
                get = GetFromDB("filterBuffTable"),
                set = SetAndRedraw("filterBuffTable"),
                disabled = IsGroupDisabled,
            },
            filterDebuffTable = {
                name = "Debuff Filter List",
                desc = "Spell list used to filter debuffs for this group.",
                type = "select",
                order = 71,
                values = GetSpellListValues,
                get = GetFromDB("filterDebuffTable"),
                set = SetAndRedraw("filterDebuffTable"),
                disabled = IsGroupDisabled,
            },

            ---------------------------------------------------------
            -- 5.6  Cast-by filter selects
            ---------------------------------------------------------
            castByHeader = {
                name = "Cast-By Filters",
                type = "header",
                order = 79,
            },
            detectBuffsCastBy = {
                name = "Buff Cast By",
                desc = "Only show buffs cast by the selected source.",
                type = "select",
                order = 80,
                values = { player = "Player Only", anyone = "Anyone" },
                get = GetFromDB("detectBuffsCastBy"),
                set = SetAndRedraw("detectBuffsCastBy"),
                disabled = IsGroupDisabled,
                hidden = function()
                    return not AurasAddon.db.profile.groups[groupName].detectBuffs
                end,
            },
            detectDebuffsCastBy = {
                name = "Debuff Cast By",
                desc = "Only show debuffs cast by the selected source.",
                type = "select",
                order = 81,
                values = { player = "Player Only", anyone = "Anyone" },
                get = GetFromDB("detectDebuffsCastBy"),
                set = SetAndRedraw("detectDebuffsCastBy"),
                disabled = IsGroupDisabled,
                hidden = function()
                    return not AurasAddon.db.profile.groups[groupName].detectDebuffs
                end,
            },
        },
    }
end

---------------------------------------------------------------------------
-- BuildSpellListOptions — global spell list management (tasks 7.1 + 7.2)
---------------------------------------------------------------------------
function BuildSpellListOptions(order)
    local listNames = {
        "PlayerInclusions",
        "ClassBuffs",
        "PlayerDebuffExclusions",
        "PlayerExclusions",
        "TargetExclusions",
    }

    local args = {}

    for i, listName in ipairs(listNames) do
        -- Build the args table for this spell list group, including
        -- the addInput control and one toggle per existing entry.
        local listArgs = {}

        -- 7.1: Input control for adding spells (name or numeric ID)
        listArgs.addInput = {
            name = "Add Spell (name or ID)",
            type = "input",
            order = 1,
            width = "double",
            get = function() return "" end,
            set = function(_, value)
                if not value or value == "" then return end
                local list = AurasAddon.db.global.SpellLists[listName]
                local numVal = tonumber(value)
                if numVal then
                    list[numVal] = true
                else
                    list[value] = true
                end
                Groups.RefreshAll()
                -- Rebuild the entire options table so the new entry appears
                InjectAurasOptions()
            end,
        }

        -- 7.2: Dynamic toggle entries for each existing spell in the list
        local entryOrder = 10
        for key, _ in pairs(AurasAddon.db.global.SpellLists[listName]) do
            local displayName
            if type(key) == "number" then
                local spellName = C_Spell.GetSpellName(key)
                displayName = spellName and ("%s (%d)"):format(spellName, key) or tostring(key)
            else
                displayName = key
            end

            -- Use a stable string key for the args table
            local argKey = "entry_" .. tostring(key)
            local capturedKey = key  -- capture for closure

            listArgs[argKey] = {
                name = displayName,
                desc = "Uncheck to remove this spell from the list.",
                type = "toggle",
                order = entryOrder,
                width = "double",
                get = function() return true end,
                set = function()
                    AurasAddon.db.global.SpellLists[listName][capturedKey] = nil
                    Groups.RefreshAll()
                    -- Rebuild the entire options table so the entry disappears
                    InjectAurasOptions()
                end,
            }
            entryOrder = entryOrder + 1
        end

        args[listName] = {
            name = listName,
            type = "group",
            order = i,
            args = listArgs,
        }
    end

    return {
        name = "Spell Lists",
        type = "group",
        childGroups = "tab",
        order = order,
        args = args,
    }
end

---------------------------------------------------------------------------
-- BuildColourOptions — global debuff type colour pickers (task 8.1)
---------------------------------------------------------------------------
local COLOUR_KEYS = {
    { key = "DefaultBuffColor",     name = "Buff" },
    { key = "DefaultDebuffColor",   name = "Debuff" },
    { key = "DefaultMagicColor",    name = "Magic" },
    { key = "DefaultCurseColor",    name = "Curse" },
    { key = "DefaultDiseaseColor",  name = "Disease" },
    { key = "DefaultPoisonColor",   name = "Poison" },
    { key = "DefaultCooldownColor", name = "Cooldown" },
}

function BuildCooldownMgrOptions(order)
    local function GetCDV(key)
        return function()
            local cdv = AurasAddon.db.profile.cooldownViewer
            return cdv and cdv[key]
        end
    end
    local function SetCDV(key)
        return function(_, value)
            local db = AurasAddon.db.profile
            db.cooldownViewer[key] = value
            AurasAddon.CooldownViewer.ApplyBuffIconCountdown(db.cooldownViewer.buffIconCountdown)
            ACR:NotifyChange("RealUI")
        end
    end

    return {
        name = "Cooldown Manager",
        type = "group",
        order = order,
        args = {
            buffIconCountdown = {
                name = "Buff Icon Countdown",
                desc = "Show countdown numbers on the buff tracker (BuffIconCooldownViewer)."
                    .. " Blizzard omits these by default.",
                type = "toggle",
                order = 1,
                width = "full",
                get = GetCDV("buffIconCountdown"),
                set = SetCDV("buffIconCountdown"),
            },
        },
    }
end

function BuildColourOptions(order)
    local args = {}

    for i, entry in ipairs(COLOUR_KEYS) do
        local key = entry.key
        args[key] = {
            name = entry.name,
            type = "color",
            order = i,
            hasAlpha = true,
            get = function()
                local c = AurasAddon.db.global[key]
                return c.r, c.g, c.b, c.a
            end,
            set = function(_, r, g, b, a)
                local c = AurasAddon.db.global[key]
                c.r, c.g, c.b, c.a = r, g, b, a
                Groups.RefreshAll()
                ACR:NotifyChange("RealUI")
            end,
        }
    end

    return {
        name = "Colours",
        type = "group",
        order = order,
        args = args,
    }
end
