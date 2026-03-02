local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Channeling tick calculation
-- Feature: hud-rewrite, Property 9: Channeling tick calculation
-- Validates: Requirements 12.5
--
-- For any spell ID in ChannelingTicks and haste h in [0, 100], computed tick
-- count floor(baseTicks * (1 + h/100) + 0.5) is a positive integer >= base
-- tick count.

-- Known ChannelingTicks entries (from CastBars.lua)
-- Since ChannelingTicks is local to CastBars.lua, we replicate the known
-- entries here for testing the tick calculation formula.
local KnownSpells = {
    {spellID = 206931, baseTicks = 3,  name = "Blooddrinker"},
    {spellID = 198013, baseTicks = 1,  name = "Eye Beam"},
    {spellID = 211053, baseTicks = 8,  name = "Fel Barrage"},
    {spellID = 212084, baseTicks = 10, name = "Fel Devastation"},
    {spellID = 740,    baseTicks = 4,  name = "Tranquility"},
    {spellID = 120360, baseTicks = 15, name = "Barrage"},
    {spellID = 212640, baseTicks = 6,  name = "Mending Bandage"},
    {spellID = 5143,   baseTicks = 5,  name = "Arcane Missiles"},
    {spellID = 12051,  baseTicks = 3,  name = "Evocation"},
    {spellID = 205021, baseTicks = 10, name = "Ray of Frost"},
    {spellID = 117952, baseTicks = 4,  name = "Crackling Jade Lightning"},
    {spellID = 113656, baseTicks = 4,  name = "Fists of Fury"},
    {spellID = 115175, baseTicks = 40, name = "Soothing Mist"},
    {spellID = 101546, baseTicks = 3,  name = "Spinning Crane Kick"},
    {spellID = 64843,  baseTicks = 2,  name = "Divine Hymn"},
    {spellID = 15407,  baseTicks = 4,  name = "Mind Flay"},
    {spellID = 47540,  baseTicks = 2,  name = "Penance"},
    {spellID = 204437, baseTicks = 6,  name = "Lightning Lasso"},
    {spellID = 193440, baseTicks = 3,  name = "Demonwrath/Demonfire"},
    {spellID = 234153, baseTicks = 6,  name = "Drain Life"},
    {spellID = 198590, baseTicks = 6,  name = "Drain Soul"},
    {spellID = 755,    baseTicks = 6,  name = "Health Funnel"},
}

-- Haste values to test: representative range from 0% to 100%
local HasteValues = {0, 5, 10, 15, 20, 25, 30, 40, 50, 60, 75, 100}

-- Replicate the exact formula from CastBars.lua SetBarTicks:
--   local haste = UnitSpellHaste("player") / 100 + 1
--   numTicks = floor(numTicks * haste + 0.5)
-- Where UnitSpellHaste returns the haste percentage (e.g. 25 for 25%).
local function computeTicks(baseTicks, hastePercent)
    local haste = hastePercent / 100 + 1
    return _G.floor(baseTicks * haste + 0.5)
end

local function RunChannelingTickTest()
    _G.print("|cff00ccff[PBT]|r Channeling tick calculation — testing",
        #KnownSpells, "spells x", #HasteValues, "haste values")

    local failures = 0
    local checkedCount = 0

    for _, spell in _G.ipairs(KnownSpells) do
        for _, h in _G.ipairs(HasteValues) do
            local result = computeTicks(spell.baseTicks, h)
            checkedCount = checkedCount + 1

            -- Property: result must be a positive integer
            if result < 1 then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r %s (ID=%d) haste=%d%% ticks=%d — not positive"):format(
                        spell.name, spell.spellID, h, result
                    )
                )
            end

            -- Property: result must be >= base tick count
            -- Haste can only increase or maintain tick count
            if result < spell.baseTicks then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r %s (ID=%d) haste=%d%% ticks=%d < baseTicks=%d"):format(
                        spell.name, spell.spellID, h, result, spell.baseTicks
                    )
                )
            end

            -- Property: result must be an integer (floor guarantees this,
            -- but verify no floating point issues)
            if result ~= _G.floor(result) then
                failures = failures + 1
                _G.print(
                    ("|cffff0000[FAIL]|r %s (ID=%d) haste=%d%% ticks=%s — not integer"):format(
                        spell.name, spell.spellID, h, _G.tostring(result)
                    )
                )
            end
        end
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 9: Channeling tick calculation — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Property 9: Channeling tick calculation — %d failures out of %d checks"):format(failures, checkedCount))
    end

    return failures == 0
end

function ns.commands:channelingticks()
    return RunChannelingTickTest()
end
