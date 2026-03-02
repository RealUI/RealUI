local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Health tag string composition
-- Feature: hud-rewrite, Property 4: Health tag string composition
-- Validates: Requirements 4.4
--
-- For any statusText in {"perc", "abs", "both"}, GetHealthTagString returns
-- a tag string containing the correct tag references and separator.

local RealUI = _G.RealUI

local statusTextOptions = {"perc", "abs", "both", "smart"}

local function RunTagsHealthCompositionTest()
    local UnitFrames = RealUI:GetModule("UnitFrames")
    if not UnitFrames then
        _G.print("|cffff0000[ERROR]|r UnitFrames module not available.")
        return false
    end

    local GetHealthTagString = UnitFrames.GetHealthTagString
    if not GetHealthTagString then
        _G.print("|cffff0000[ERROR]|r GetHealthTagString not available on UnitFrames module.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Health tag string composition — testing all statusText options")

    local failures = 0

    for _, statusText in _G.ipairs(statusTextOptions) do
        local result = GetHealthTagString(statusText)

        if type(result) ~= "string" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r statusText=%q returned %s (expected string)"):format(statusText, type(result)))
        else
            -- All modes must contain [realui:healthcolor]
            if not result:find("[realui:healthcolor]", 1, true) then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r statusText=%q missing [realui:healthcolor]"):format(statusText))
            end

            if statusText == "perc" or statusText == "smart" then
                if not result:find("[realui:healthPercent", 1, true) then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r statusText=%q missing [realui:healthPercent"):format(statusText))
                end
                if not result:find("%", 1, true) then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r statusText=%q missing %% suffix"):format(statusText))
                end

            elseif statusText == "abs" then
                if not result:find("[realui:healthValue", 1, true) then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r statusText='abs' missing [realui:healthValue")
                end

            elseif statusText == "both" then
                if not result:find("[realui:healthPercent", 1, true) then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r statusText='both' missing [realui:healthPercent")
                end
                if not result:find("[realui:healthValue", 1, true) then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r statusText='both' missing [realui:healthValue")
                end
                if not result:find(" - ", 1, true) then
                    failures = failures + 1
                    _G.print("|cffff0000[FAIL]|r statusText='both' missing ' - ' separator")
                end
            end

            _G.print(("  statusText=%q -> %q"):format(statusText, result))
        end
    end

    -- Verify fallback return for unknown input (should return a valid string, not nil)
    local fallbackResult = GetHealthTagString("unknown_value")
    if type(fallbackResult) ~= "string" then
        failures = failures + 1
        _G.print(("|cffff0000[FAIL]|r statusText='unknown_value' expected fallback string, got %s"):format(_G.tostring(fallbackResult)))
    end

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r Property 4: Health tag string composition — all checks passed")
    else
        _G.print(("|cffff0000[FAIL]|r Property 4: Health tag string composition — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:taghealthcomp()
    return RunTagsHealthCompositionTest()
end
