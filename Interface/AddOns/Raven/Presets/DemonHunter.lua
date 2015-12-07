-- Demon Hunter

print("Set Raven DH presets")
Raven.classConditions.DEMONHUNTER = {
    ["Spectral Sight"] = {
        tests = {
            ["Any Buffs"] = { enable = true, toggle = true, unit = "player",
                auras = { 188501 }, }, --  "Spectral Sight"
        },
        associatedSpell = 188501, -- "Spectral Sight"
    },
}
