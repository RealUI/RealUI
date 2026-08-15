local _, private = ...

-- Defaults are a 1:1 port of RealUI's shipped Bartender4 profile
-- (RealUI/Core/AddonData/Bartender4.lua, profile "RealUI"): bar 1 at screen
-- center below the HuD, bars 2/3 stacked bottom-left of center, two fading
-- vertical side bars at the right edge, bar 6 = Naga (off). BT4 buttons are
-- 36px base, padding -9 (borders overlap). Position note: BT4 stores
-- screen-space offsets and divides by scale at apply; scale is 1 everywhere
-- here except the vehicle button, so values port as-is.

-- The shipped BT4 profile carried fade strings with custom=false — BT4 never
-- activated them; classic RealUI showed all bars. Fade is opt-in via config.
local HIDE = "[petbattle][overridebar][vehicleui][possessbar,@vehicle,exists]hide;"
local VIS_SHOW = HIDE .. "show"

local function bar(overrides)
    local defaults = {
        enabled = true,
        buttons = 12,
        rows = 1,
        buttonSize = 36,
        padding = -9,
        scale = 1,
        alpha = 1,
        showgrid = true,
        hidemacrotext = true,
        flyoutDirection = "UP",
        growHorizontal = "RIGHT",
        growVertical = "DOWN",
        visibility = VIS_SHOW,
        fadeoutalpha = 0,
        position = { point = "BOTTOM", x = 0, y = 84 },
    }
    for k, v in _G.next, overrides do defaults[k] = v end
    return defaults
end

private.nsDefaults = {
    ActionBars = {
        profile = {
            actionbars = {
                [1] = bar({ flyoutDirection = "DOWN",
                            position = { point = "CENTER", x = -224.5, y = -199.5 } }),
                [2] = bar({ position = { point = "BOTTOM", x = -224.5, y = 89 } }),
                [3] = bar({ position = { point = "BOTTOM", x = -224.5, y = 62 } }),
                [4] = bar({ rows = 12, flyoutDirection = "LEFT",
                            position = { point = "RIGHT", x = -36, y = 334.5 } }),
                [5] = bar({ rows = 12, flyoutDirection = "LEFT",
                            position = { point = "RIGHT", x = -36, y = 10.5 } }),
                [6] = bar({ enabled = false, rows = 4,
                            position = { point = "CENTER", x = 210, y = -360 } }),
            },
        },
    },
    -- Adopted Blizzard buttons keep their own art (no inset skin), so no
    -- overlap padding here — positive gap keeps them square and separate.
    StanceBar = {
        profile = {
            enabled = true,
            buttonSize = 30,
            padding = 2,
            fadeoutalpha = 0,
            growHorizontal = "LEFT",
            visibility = VIS_SHOW,
            -- Grow-corner semantics: right edge just left of the centered bars.
            position = { point = "BOTTOM", x = -175, y = 49 },
        },
    },
    PetBar = {
        profile = {
            enabled = true,
            buttonSize = 26,
            padding = 2,
            fadeoutalpha = 0,
            visibility = "[nopet]hide;" .. VIS_SHOW,
            position = { point = "LEFT", x = 4, y = 124.5 },
        },
    },
    Vehicle = {
        profile = {
            enabled = true,
            scale = 0.84,
            position = { point = "TOPRIGHT", x = -36, y = -59.5 },
        },
    },
}

private.defaults = {
    profile = {
        bindings = {},  -- [buttonName] = key (custom, beyond the bar-1 ACTIONBUTTON mirror)
    },
    global = {
        importedBT4 = false,
    },
}
