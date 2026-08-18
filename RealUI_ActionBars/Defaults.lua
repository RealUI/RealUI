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
        -- 27px buttons with a 1px border drawn outside the frame. padding is
        -- the TRUE visible gap between neighbouring borders (Bar.lua box
        -- model, B28): the shipped look is a clean 2px gap.
        buttonSize = 27,
        padding = 2,
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
                -- Static geometry mirrors what Integration.lua computes for
                -- the default RealUI layout (12 buttons, 27px, 2px visible
                -- gap -> 368px frame extent): center bars at -width/2, side
                -- bars border-flush with the screen edge (B05), bar 4
                -- stacked above bar 5 with the same 2px visible gap.
                [1] = bar({ flyoutDirection = "DOWN",
                            position = { point = "CENTER", x = -184, y = -199.5 } }),
                [2] = bar({ position = { point = "BOTTOM", x = -184, y = 93 } }),
                [3] = bar({ position = { point = "BOTTOM", x = -184, y = 62 } }),
                [4] = bar({ rows = 12, flyoutDirection = "LEFT",
                            position = { point = "RIGHT", x = -1, y = 382.5 } }),
                [5] = bar({ rows = 12, flyoutDirection = "LEFT",
                            position = { point = "RIGHT", x = -1, y = 10.5 } }),
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
            -- Grow-corner semantics: right edge just left of the centered
            -- bars (which are 368px wide with the B28 box model — keep the
            -- same 13px clearance the old 324px-wide bars had).
            position = { point = "BOTTOM", x = -197, y = 49 },
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
        moveExtraButton = true,  -- anchor ExtraAction/ZoneAbility left of bar 1
    },
    global = {
        importedBT4 = false,
    },
}
