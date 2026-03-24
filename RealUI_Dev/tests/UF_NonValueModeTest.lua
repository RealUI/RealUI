local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Non-value status text modes exclude abbreviation (Property 3)
-- Feature: hud-unitframe-enhancements
-- Validates: Requirements 1.6
--
-- For any statusText mode in {"perc", "smart"}, the tag string returned by
-- GetHealthTagString should not contain "healthValue", and the tag string
-- returned by GetPowerTagString (with MANA power type) should not contain
-- "powerValue".

local function RunNonValueModeTest()
    _G.print("|cff00ccff[PBT]|r Non-value modes exclude abbreviation — running")

    local RealUI = _G.RealUI
    local UnitFrames = RealUI:GetModule("UnitFrames")
    if not UnitFrames or not UnitFrames.GetHealthTagString then
        _G.print("|cffff0000[SKIP]|r UnitFrames module or GetHealthTagString not available")
        return false
    end

    local failures = 0
    local modes = {"perc", "smart"}

    for _, mode in _G.ipairs(modes) do
        local healthTag = UnitFrames.GetHealthTagString(mode)
        if healthTag:find("healthValue", 1, true) then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r GetHealthTagString(%q) contains 'healthValue': %s"):format(mode, healthTag))
        end

        -- Test with MANA power type (the type that respects statusText modes)
        local powerTag = UnitFrames.GetPowerTagString(mode, "MANA")
        if powerTag:find("powerValue", 1, true) then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r GetPowerTagString(%q, 'MANA') contains 'powerValue': %s"):format(mode, powerTag))
        end
    end

    -- Also verify that "value" and "both" DO contain the value tags (sanity check)
    local valueModes = {"value", "both"}
    for _, mode in _G.ipairs(valueModes) do
        local healthTag = UnitFrames.GetHealthTagString(mode)
        if not healthTag:find("healthValue", 1, true) then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r GetHealthTagString(%q) should contain 'healthValue': %s"):format(mode, healthTag))
        end

        local powerTag = UnitFrames.GetPowerTagString(mode, "MANA")
        if not powerTag:find("powerValue", 1, true) then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r GetPowerTagString(%q, 'MANA') should contain 'powerValue': %s"):format(mode, powerTag))
        end
    end

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r Property 3: Non-value status text modes exclude abbreviation")
    else
        _G.print(("|cffff0000[FAIL]|r Property 3: Non-value modes — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:ufnonvaluemode()
    return RunNonValueModeTest()
end
