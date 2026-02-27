local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Power tag string composition
-- Feature: hud-rewrite, Property 5: Power tag string composition
-- Validates: Requirements 4.5
--
-- For any statusText in {"perc", "abs", "both"} and any power type,
-- mana follows health pattern, non-mana always returns [realui:powerValue.

local RealUI = _G.RealUI

local statusTextOptions = {"perc", "abs", "both", "smart"}
local nonManaPowerTypes = {"RAGE", "ENERGY", "FOCUS", "RUNIC_POWER", "FURY", "PAIN", "INSANITY", "MAELSTROM"}

local function RunTagsPowerCompositionTest()
    local UnitFrames = RealUI:GetModule("UnitFrames")
    if not UnitFrames then
        _G.print("|cffff0000[ERROR]|r UnitFrames module not available.")
        return false
    end

    local GetPowerTagString = UnitFrames.GetPowerTagString
    if not GetPowerTagString then
        _G.print("|cffff0000[ERROR]|r GetPowerTagString not available on UnitFrames module.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Power tag string composition — testing MANA and non-MANA power types")

    local failures = 0

    -- Test MANA power type: should follow health pattern
    for _, statusText in _G.ipairs(statusTextOptions) do
        local result = GetPowerTagString(statusText, "MANA")

        if type(result) ~= "string" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r MANA statusText=%q returned %s"):format(statusText, type(result)))
        else
            -- MANA should contain [powercolor]
            if not result:find("[powercolor]", 1, true) then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r MANA statusText=%q missing [powercolor]"):format(statusText))
            end

            if statusText == "perc" or statusText == "smart" then
                if not result:find("[realui:powerPercent", 1, true) then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r MANA statusText=%q missing [realui:powerPercent"):format(statusText))
                end
            elseif statusText == "abs" then
                if not result:find("[realui:powerValue", 1, true) then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r MANA statusText='abs' missing [realui:powerValue")
                end
            elseif statusText == "both" then
                if not result:find("[realui:powerPercent", 1, true) then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r MANA statusText='both' missing [realui:powerPercent")
                end
                if not result:find("[realui:powerValue", 1, true) then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r MANA statusText='both' missing [realui:powerValue")
                end
                if not result:find(" - ", 1, true) then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r MANA statusText='both' missing ' - ' separator")
                end
            end

            _G.print(("  MANA statusText=%q -> %q"):format(statusText, result))
        end
    end

    -- Test non-MANA power types: should always return [realui:powerValue regardless of statusText
    for _, powerType in _G.ipairs(nonManaPowerTypes) do
        for _, statusText in _G.ipairs(statusTextOptions) do
            local result = GetPowerTagString(statusText, powerType)

            if type(result) ~= "string" then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r %s statusText=%q returned %s"):format(powerType, statusText, type(result)))
            else
                if not result:find("[realui:powerValue", 1, true) then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r %s statusText=%q missing [realui:powerValue"):format(powerType, statusText))
                end
            end
        end
    end

    _G.print(("  Tested %d non-MANA power types x %d statusText options"):format(#nonManaPowerTypes, #statusTextOptions))

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r Property 5: Power tag string composition — all checks passed")
    else
        _G.print(("|cffff0000[FAIL]|r Property 5: Power tag string composition — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:tagpowercomp()
    return RunTagsPowerCompositionTest()
end
