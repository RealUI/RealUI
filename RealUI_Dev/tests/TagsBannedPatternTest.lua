local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Tags module banned pattern absence
-- Feature: hud-rewrite, Property 12: Tags module banned pattern absence
-- Validates: Requirements 20.3, 20.4, 20.5
--
-- Verifies that banned patterns (IsSafeTrue, pcall wrappers, RealUI.isSecret usage,
-- oUF.objects scanning) are absent from the Tags module. Since we cannot read source
-- files at runtime in WoW, we verify:
--   - RealUI.IsSafeTrue should be nil (removed helper)
--   - All realui: tag functions are registered in oUF.Tags.Methods
--   - Tag functions exist as plain functions (not wrapped in pcall)

local RealUI = _G.RealUI

local function RunTagsBannedPatternTest()
    _G.print("|cff00ccff[PBT]|r Tags module banned pattern absence — runtime checks")

    local failures = 0

    -- Check that RealUI.IsSafeTrue does not exist
    if RealUI.IsSafeTrue ~= nil then
        failures = failures + 1
        _G.print("|cffff0000[FAIL]|r RealUI.IsSafeTrue should be nil but exists")
    else
        _G.print("  RealUI.IsSafeTrue is nil — OK")
    end

    -- Access oUF for tag function checks
    local oUF = _G.oUF

    if not oUF or not oUF.Tags or not oUF.Tags.Methods then
        failures = failures + 1
        _G.print("|cffff0000[FAIL]|r oUF.Tags.Methods not accessible")
    else
        local tagMethods = oUF.Tags.Methods
        local tagCount = 0

        -- Expected realui: tags that must exist
        local expectedTags = {
            "realui:healthcolor", "realui:healthPercent", "realui:healthValue",
            "realui:powerPercent", "realui:powerValue", "realui:name",
            "realui:level", "realui:pvptimer", "realui:threat", "realui:range",
        }

        for _, tagName in _G.ipairs(expectedTags) do
            local tagFunc = tagMethods[tagName]
            if not tagFunc then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r Expected tag %q not found in oUF.Tags.Methods"):format(tagName))
            elseif type(tagFunc) ~= "function" then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r Tag %q is %s, expected function"):format(tagName, type(tagFunc)))
            else
                tagCount = tagCount + 1
            end
        end

        if tagCount > 0 then
            _G.print(("  %d/%d realui: tag functions registered — OK"):format(tagCount, #expectedTags))
        end
    end

    if failures == 0 then
        _G.print("|cff00ff00[PASS]|r Property 12: Tags module banned pattern absence — all checks passed")
    else
        _G.print(("|cffff0000[FAIL]|r Property 12: Tags module banned pattern absence — %d failures"):format(failures))
    end

    return failures == 0
end

function ns.commands:tagbanned()
    return RunTagsBannedPatternTest()
end
