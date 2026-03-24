local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Power tag string composition reflects textColors.power (Property 7)
-- Feature: hud-unitframe-enhancements
-- Validates: Requirements 4.4, 4.5
--
-- For any statusText mode and for any textColors.power setting,
-- GetPowerTagString should produce a tag string containing
-- "[realui:customPowerColor]" when textColors.power is non-nil, and
-- containing "[powercolor]" when textColors.power is nil.

local function RunPowerTagCompositionTest()
    _G.print("|cff00ccff[PBT]|r Power tag string composition — running")

    local RealUI = _G.RealUI
    local UnitFrames = RealUI:GetModule("UnitFrames")
    if not UnitFrames or not UnitFrames.GetPowerTagString then
        _G.print("|cffff0000[SKIP]|r UnitFrames module or GetPowerTagString not available")
        return false
    end

    local db = UnitFrames.db.profile
    local savedPower = db.misc.textColors and db.misc.textColors.power

    local failures = 0
    local modes = {"perc", "value", "both", "smart", "abs"}
    local powerTypes = {"MANA", "RAGE", "ENERGY", "FOCUS", "RUNIC_POWER"}

    -- Test with custom power color set
    db.misc.textColors.power = {0.5, 0.5, 0.5}
    for _, mode in _G.ipairs(modes) do
        for _, pt in _G.ipairs(powerTypes) do
            local result = UnitFrames.GetPowerTagString(mode, pt)
            if not result:find("realui:customPowerColor", 1, true) then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r custom color: mode=%q pt=%q missing customPowerColor: %s"):format(mode, pt, result))
            end
            if result:find("[powercolor]", 1, true) then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r custom color: mode=%q pt=%q still has [powercolor]: %s"):format(mode, pt, result))
            end
        end
    end

    -- Test with nil power color (default)
    db.misc.textColors.power = nil
    for _, mode in _G.ipairs(modes) do
        for _, pt in _G.ipairs(powerTypes) do
            local result = UnitFrames.GetPowerTagString(mode, pt)
            if result:find("realui:customPowerColor", 1, true) then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r nil color: mode=%q pt=%q has customPowerColor: %s"):format(mode, pt, result))
            end
            if not result:find("[powercolor]", 1, true) then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r nil color: mode=%q pt=%q missing [powercolor]: %s"):format(mode, pt, result))
            end
        end
    end

    -- Restore
    db.misc.textColors.power = savedPower

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r Property 7: Power tag string composition — all modes/types passed")
    else
        _G.print(("|cffff0000[FAIL]|r Property 7: Power tag composition — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:ufpowertagcomp()
    return RunPowerTagCompositionTest()
end
