local _, private = ...
local AB = private.AB

--[[ AceConfig panel, lazily registered (same model as RealUI_Nameplates:
     AceConfig is provided by RealUI_Config or any Ace3 config addon). ]]--

local GROW_H = { RIGHT = "Right", LEFT = "Left" }
local GROW_V = { DOWN = "Down", UP = "Up" }
local POINTS = {
    BOTTOM = "Bottom", BOTTOMLEFT = "Bottom Left", BOTTOMRIGHT = "Bottom Right",
    TOP = "Top", TOPLEFT = "Top Left", TOPRIGHT = "Top Right",
    LEFT = "Left", RIGHT = "Right", CENTER = "Center",
}

local function BarOptions(id)
    local function db()
        return AB.dbActionBars.profile.actionbars[id]
    end
    local function refresh()
        private.RefreshBar(id)
    end

    -- B59: the HuD layout engine owns geometry on bars 1-5 — Integration.lua's
    -- ApplyRealUILayout rewrites rows, grow direction and position on every
    -- recompute (layout swap, spec change, HuD size change, reload). Offering
    -- those controls here meant a user could set them and silently lose the
    -- change on the next recompute. Hide them on the managed bars and say who
    -- owns them; bar 6 is not touched by the engine, so it keeps the full set.
    -- Same boundary the buttonSize/padding/scale carve-out established.
    local layoutOwned = id <= 5

    return {
        type = "group", name = (id == 6) and "Bar 6 (Naga)" or ("Bar " .. id), order = id,
        args = {
            enabled = {
                type = "toggle", name = "Enabled", order = 1,
                get = function() return db().enabled end,
                set = function(_, v) db().enabled = v; refresh() end,
            },
            buttons = {
                type = "range", name = "Buttons", min = 1, max = 12, step = 1, order = 2,
                get = function() return db().buttons end,
                set = function(_, v) db().buttons = v; refresh() end,
            },
            layoutNote = {
                type = "description", order = 3, hidden = not layoutOwned,
                name = "|cffffcc00Rows, grow direction and position|r on this bar are set by the HuD layout — they follow layout swaps, spec changes and HuD size. Button size, padding, scale and everything below are yours.",
            },
            rows = {
                type = "range", name = "Rows", min = 1, max = 12, step = 1, order = 3,
                hidden = layoutOwned,
                get = function() return db().rows end,
                set = function(_, v) db().rows = v; refresh() end,
            },
            buttonSize = {
                type = "range", name = "Button size", min = 16, max = 48, step = 1, order = 4,
                get = function() return db().buttonSize end,
                set = function(_, v) db().buttonSize = v; refresh() end,
            },
            padding = {
                type = "range", name = "Padding", min = -9, max = 12, step = 1, order = 5,
                desc = "Visible gap between buttons, borders included: 0 = borders touching, 2 = a true 2px gap (default).",
                get = function() return db().padding end,
                set = function(_, v) db().padding = v; refresh() end,
            },
            scale = {
                type = "range", name = "Scale", min = 0.5, max = 2, step = 0.05, order = 6,
                get = function() return db().scale end,
                set = function(_, v) db().scale = v; refresh() end,
            },
            alpha = {
                type = "range", name = "Alpha", min = 0.1, max = 1, step = 0.05, order = 7,
                get = function() return db().alpha end,
                set = function(_, v) db().alpha = v; refresh() end,
            },
            growHorizontal = {
                type = "select", name = "Grow (horizontal)", values = GROW_H, order = 8,
                hidden = layoutOwned,
                get = function() return db().growHorizontal end,
                set = function(_, v) db().growHorizontal = v; refresh() end,
            },
            growVertical = {
                type = "select", name = "Grow (vertical)", values = GROW_V, order = 9,
                hidden = layoutOwned,
                get = function() return db().growVertical end,
                set = function(_, v) db().growVertical = v; refresh() end,
            },
            position = {
                type = "group", name = "Position", inline = true, order = 10,
                hidden = layoutOwned,
                args = {
                    point = {
                        type = "select", name = "Anchor", values = POINTS, order = 1,
                        get = function() return db().position.point end,
                        set = function(_, v) db().position.point = v; refresh() end,
                    },
                    x = {
                        type = "range", name = "X", min = -2000, max = 2000, step = 1, order = 2,
                        get = function() return db().position.x end,
                        set = function(_, v) db().position.x = v; refresh() end,
                    },
                    y = {
                        type = "range", name = "Y", min = -2000, max = 2000, step = 1, order = 3,
                        get = function() return db().position.y end,
                        set = function(_, v) db().position.y = v; refresh() end,
                    },
                },
            },
            visibility = {
                type = "input", name = "Visibility conditional", width = "full", order = 11,
                desc = "Macro conditional ending in show, hide, or fade — e.g. [petbattle]hide;[mod:ctrl]show;fade",
                get = function() return db().visibility end,
                set = function(_, v) db().visibility = v; refresh() end,
            },
            fadeoutalpha = {
                type = "range", name = "Faded alpha", min = 0, max = 1, step = 0.05, order = 12,
                get = function() return db().fadeoutalpha end,
                set = function(_, v) db().fadeoutalpha = v; refresh() end,
            },
            showgrid = {
                type = "toggle", name = "Show empty slots", order = 13,
                get = function() return db().showgrid end,
                set = function(_, v) db().showgrid = v; refresh() end,
            },
            hidemacrotext = {
                type = "toggle", name = "Hide macro text", order = 14,
                get = function() return db().hidemacrotext end,
                set = function(_, v) db().hidemacrotext = v; refresh() end,
            },
        },
    }
end

local function AuxBarOptions(displayName, order, getDB)
    local function refresh()
        private.QueueSecure(private.BuildStancePetBars)
    end
    return {
        type = "group", name = displayName, order = order,
        args = {
            enabled = {
                type = "toggle", name = "Enabled", order = 1,
                get = function() return getDB().enabled end,
                set = function(_, v) getDB().enabled = v; refresh() end,
            },
            buttonSize = {
                type = "range", name = "Button size", min = 16, max = 48, step = 1, order = 2,
                get = function() return getDB().buttonSize end,
                set = function(_, v) getDB().buttonSize = v; refresh() end,
            },
            padding = {
                type = "range", name = "Padding", min = -9, max = 12, step = 1, order = 3,
                get = function() return getDB().padding end,
                set = function(_, v) getDB().padding = v; refresh() end,
            },
            position = {
                type = "group", name = "Position", inline = true, order = 4,
                args = {
                    point = {
                        type = "select", name = "Anchor", values = POINTS, order = 1,
                        get = function() return getDB().position.point end,
                        set = function(_, v) getDB().position.point = v; refresh() end,
                    },
                    x = {
                        type = "range", name = "X", min = -2000, max = 2000, step = 1, order = 2,
                        get = function() return getDB().position.x end,
                        set = function(_, v) getDB().position.x = v; refresh() end,
                    },
                    y = {
                        type = "range", name = "Y", min = -2000, max = 2000, step = 1, order = 3,
                        get = function() return getDB().position.y end,
                        set = function(_, v) getDB().position.y = v; refresh() end,
                    },
                },
            },
            visibility = {
                type = "input", name = "Visibility conditional", width = "full", order = 5,
                desc = "Macro conditional ending in show, hide, or fade.",
                get = function() return getDB().visibility end,
                set = function(_, v) getDB().visibility = v; refresh() end,
            },
            fadeoutalpha = {
                type = "range", name = "Faded alpha", min = 0, max = 1, step = 0.05, order = 6,
                get = function() return getDB().fadeoutalpha end,
                set = function(_, v) getDB().fadeoutalpha = v; refresh() end,
            },
        },
    }
end

local function BuildOptions()
    local options = {
        type = "group", name = "RealUI ActionBars", childGroups = "tab",
        args = {
            bindMode = {
                type = "execute", name = "Keybind mode", order = 0,
                desc = "Hover a button and press a key to bind it (ESC clears). Also /rab bind.",
                func = function() private.ToggleBindMode() end,
            },
            moveExtraButton = {
                type = "toggle", name = "Anchor Extra/Zone ability to bar 1", order = 0.5,
                desc = "Places the Extra Action Button and Zone Ability left of bar 1. Off = wherever EditMode puts the container.",
                get = function() return AB.db.profile.moveExtraButton end,
                set = function(_, v)
                    AB.db.profile.moveExtraButton = v
                    if v then private.QueueSecure(private.ApplyExtraButtons) end
                end,
            },
            stance = AuxBarOptions("Stance Bar", 7, function() return AB.dbStanceBar.profile end),
            pet = AuxBarOptions("Pet Bar", 8, function() return AB.dbPetBar.profile end),
        },
    }
    for id = 1, 6 do
        options.args["bar" .. id] = BarOptions(id)
    end
    return options
end

-- Public: RealUI_Config embeds this into the RealUI options tree.
function AB:GetConfigOptions()
    return BuildOptions()
end

-- Public: RealUI_Config's "Action Bars" passthrough button.
function AB:OpenConfig()
    private.OpenConfig()
end

local registered = false
local function EnsureRegistered()
    local registry = _G.LibStub("AceConfigRegistry-3.0", true)
    local dialog = _G.LibStub("AceConfigDialog-3.0", true)
    if not (registry and dialog) then return false end
    if not registered then
        registered = true
        registry:RegisterOptionsTable("RealUI_ActionBars", BuildOptions)
        dialog:AddToBlizOptions("RealUI_ActionBars", "RealUI ActionBars")
    end
    return true
end

function private.OpenConfig()
    if EnsureRegistered() then
        _G.LibStub("AceConfigDialog-3.0"):Open("RealUI_ActionBars")
    else
        _G.print("|cff30d0ffRealUI ActionBars|r: config requires AceConfig (load RealUI_Config or any Ace3 config addon).")
    end
end
