local _, private = ...

-- Parity source: the RealUI-authored Platynator profile (Core\AddonData\Platynator.lua,
-- designs "Kui - Enemy" / "Kui - Friendly"). Values here are data parity, not code.

local function c(hex, a)
    return {
        r = _G.tonumber(hex:sub(1, 2), 16) / 255,
        g = _G.tonumber(hex:sub(3, 4), 16) / 255,
        b = _G.tonumber(hex:sub(5, 6), 16) / 255,
        a = a or 1,
    }
end
private.hexColor = c

private.defaults = {
    profile = {
        enemy = {
            health = {
                width = 125, height = 11,
                background = c("161616", 0.9),
                absorb = true,
            },
            colors = {
                execute        = c("D1D1D1"),
                executeCombat  = c("FF0000"),
                cast           = c("FF8000"),
                tapped         = c("6E6E6E"),
                threat = {
                    enabled    = true,
                    warning    = c("B3351B"),
                    transition = c("E68000"),
                    safe       = c("00FF00"),
                    offtank    = c("9900FF"),
                },
                reaction = {
                    hostile    = c("B3351B"),
                    neutral    = c("FFCC00"),
                    unfriendly = c("FF8100"),
                    friendly   = c("33994A"),
                },
            },
            execute = { enabled = true, threshold = 0.20 },
            castbar = {
                enabled = true, height = 7, icon = true,
                colors = {
                    interruptReady = c("BFBFE6"),
                    interruptNotReady = c("FF0000"),
                    uninterruptible = c("CC4D4D"),
                    interrupted = c("CC4D4D"),
                    empowered = c("05C666"),
                },
            },
            power = { enabled = false, height = 4 },
            auras = {
                size = 20,
                myDebuffs    = { enabled = true, max = 8, position = "aboveLeft",  offset = { x = 0, y = 16 } },
                crowdControl = { enabled = true, max = 4, position = "right",      offset = { x = 6, y = 0 } },
                buffs        = { enabled = true, max = 4, position = "aboveRight", offset = { x = 0, y = 16 } },
            },
            texts = {
                healthPercent = true,
                name = { enabled = true, size = 11, maxWidth = 160 },
                spellName = true,
            },
            markers = {
                quest = true, raidIcon = true, rare = true,
            },
        },
        friendly = {
            name = {
                size = 11,
                roleColors = {
                    TANK    = c("1F6FE8"),
                    HEALER  = c("00C64A"),
                    DAMAGER = c("E85555"),
                },
            },
            showInInstances = false,
            targetGlow = true,
        },
        alpha = {
            outOfRange  = 0.6,
            noCombat    = 0.5,
            notTarget   = 0.7,
            casting     = 1.0,
        },
        target = { highlight = c("3EB1ED") },
        font = { name = "Roboto Condensed", outline = "OUTLINE", shadow = true },
    },
}
