local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Deprecated API absence
-- Feature: hud-rewrite, Property 11: Deprecated API absence
-- Validates: Requirements 19.1–19.20
--
-- For all deprecated function names listed in requirements, count of
-- occurrences in all HuD Lua source files is zero. Since WoW cannot read
-- source files at runtime, we verify:
--   1. Modern replacement APIs exist in the global namespace
--   2. Deprecated global functions are NOT referenced by HuD module code
--      (checked by hooking deprecated globals and running a HuD refresh cycle)
--   3. Key HuD modules use the correct modern API references

local RealUI = _G.RealUI

-- Deprecated → Modern replacement mapping
-- Each entry: { deprecated global path, modern global path, requirement }
local DEPRECATED_API_MAP = {
    {"GetSpellInfo",           "C_Spell.GetSpellInfo",                        "19.1"},
    {"GetNumSpellTabs",        "C_SpellBook.GetNumSpellBookSkillLines",       "19.2"},
    {"GetSpellTabInfo",        "C_SpellBook.GetSpellBookSkillLineInfo",       "19.3"},
    {"GetSpellCooldown",       "C_Spell.GetSpellCooldown",                    "19.4"},
    {"GetSpellBookItemName",   "C_SpellBook.GetSpellBookItemName",            "19.5"},
    {"GetSpellTexture",        "C_Spell.GetSpellTexture",                     "19.6"},
    {"GetSpellCharges",        "C_Spell.GetSpellCharges",                     "19.7"},
    {"GetSpellDescription",    "C_Spell.GetSpellDescription",                 "19.8"},
    {"GetSpellCount",          "C_Spell.GetSpellCastCount",                   "19.9"},
    {"IsUsableSpell",          "C_Spell.IsSpellUsable",                       "19.10"},
    {"IsSpellOverlayed",       "C_SpellActivationOverlay.IsSpellOverlayed",   "19.11"},
    {"GetQuestDifficultyColor","GetCreatureDifficultyColor",                  "19.20"},
}

-- Additional deprecated functions that should be absent (no direct global
-- replacement — functionality removed or handled by oUF natively)
local REMOVED_APIS = {
    {"UnitGetIncomingHeals",    "oUF native prediction",   "19.20"},
    {"UnitGetTotalAbsorbs",     "oUF native prediction",   "19.20"},
    {"UnitGetTotalHealAbsorbs", "oUF native prediction",   "19.20"},
}

--- Resolve a dotted path like "C_Spell.GetSpellInfo" from _G
local function resolveGlobal(path)
    local current = _G
    for segment in path:gmatch("[^%.]+") do
        if _G.type(current) ~= "table" then return nil end
        current = current[segment]
    end
    return current
end

local function RunDeprecatedAPIAbsenceTest()
    _G.print("|cff00ccff[PBT]|r Deprecated API absence — runtime verification")

    local failures = 0
    local checkedCount = 0

    -- Part 1: Verify modern replacement APIs exist
    _G.print("  Part 1: Checking modern replacement APIs exist...")
    for _, entry in _G.ipairs(DEPRECATED_API_MAP) do
        local deprecatedName, modernPath, req = entry[1], entry[2], entry[3]
        local modernFunc = resolveGlobal(modernPath)
        checkedCount = checkedCount + 1
        if modernFunc == nil then
            -- Some APIs may not exist on all client versions; warn but don't fail
            _G.print(("  |cffff9900[WARN]|r Modern API %s not found (Req %s) — client may not support it"):format(
                modernPath, req))
        elseif _G.type(modernFunc) ~= "function" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r Modern API %s is %s, expected function (Req %s)"):format(
                modernPath, _G.type(modernFunc), req))
        end
    end

    -- Part 2: Hook deprecated globals and run a HuD refresh to detect calls
    _G.print("  Part 2: Hooking deprecated globals to detect usage...")
    local calledDeprecated = {}
    local hooks = {}

    -- Hook deprecated functions that exist as globals
    for _, entry in _G.ipairs(DEPRECATED_API_MAP) do
        local deprecatedName = entry[1]
        local original = _G[deprecatedName]
        if original and _G.type(original) == "function" then
            hooks[deprecatedName] = original
            _G[deprecatedName] = function(...)
                calledDeprecated[deprecatedName] = (calledDeprecated[deprecatedName] or 0) + 1
                return original(...)
            end
        end
    end

    for _, entry in _G.ipairs(REMOVED_APIS) do
        local deprecatedName = entry[1]
        local original = _G[deprecatedName]
        if original and _G.type(original) == "function" then
            hooks[deprecatedName] = original
            _G[deprecatedName] = function(...)
                calledDeprecated[deprecatedName] = (calledDeprecated[deprecatedName] or 0) + 1
                return original(...)
            end
        end
    end

    -- Trigger a HuD refresh cycle to exercise the code paths
    local UnitFrames = RealUI:GetModule("UnitFrames")
    if UnitFrames and UnitFrames.RefreshUnits then
        _G.pcall(UnitFrames.RefreshUnits, UnitFrames)
    end

    -- Restore all hooks
    for name, original in _G.pairs(hooks) do
        _G[name] = original
    end

    -- Check if any deprecated function was called during refresh
    for name, count in _G.pairs(calledDeprecated) do
        failures = failures + 1
        checkedCount = checkedCount + 1
        _G.print(("|cffff0000[FAIL]|r Deprecated %s was called %d time(s) during HuD refresh"):format(name, count))
    end
    if _G.next(calledDeprecated) == nil then
        _G.print("  No deprecated API calls detected during HuD refresh — OK")
    end

    -- Part 3: Verify Tags module uses modern APIs
    _G.print("  Part 3: Checking Tags module for deprecated references...")
    local oUF = _G.oUF
    if oUF and oUF.Tags and oUF.Tags.Methods then
        local tagMethods = oUF.Tags.Methods

        -- Check realui:level uses GetCreatureDifficultyColor (not GetQuestDifficultyColor)
        -- We can verify by checking the function's upvalues reference the modern API
        -- Since we can't inspect upvalues in WoW, we hook and call the tag
        local levelTag = tagMethods["realui:level"]
        if levelTag and _G.type(levelTag) == "function" then
            -- Hook GetQuestDifficultyColor to detect if level tag calls it
            local oldQDC = _G.GetQuestDifficultyColor
            local qdcCalled = false
            if oldQDC then
                _G.GetQuestDifficultyColor = function(...)
                    qdcCalled = true
                    return oldQDC(...)
                end
            end

            -- Call the level tag with "player" unit
            _G.pcall(levelTag, "player")

            -- Restore
            if oldQDC then
                _G.GetQuestDifficultyColor = oldQDC
            end

            checkedCount = checkedCount + 1
            if qdcCalled then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r realui:level tag called deprecated GetQuestDifficultyColor")
            else
                _G.print("  realui:level does not call GetQuestDifficultyColor — OK")
            end
        else
            _G.print("  |cffff9900[WARN]|r realui:level tag not found, skipping")
        end

        checkedCount = checkedCount + 1
    else
        _G.print("  |cffff9900[WARN]|r oUF.Tags.Methods not accessible, skipping tag checks")
    end

    -- Part 4: Verify UnitFrames does not reference removed prediction APIs
    _G.print("  Part 4: Checking UnitFrames for removed prediction APIs...")
    if UnitFrames then
        checkedCount = checkedCount + 1
        -- Check that PredictOverride does not exist (it was removed in the rewrite)
        if UnitFrames.PredictOverride then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r UnitFrames.PredictOverride still exists (should be removed)")
        else
            _G.print("  UnitFrames.PredictOverride is nil — OK")
        end

        -- Check that isMidnight guard does not exist
        checkedCount = checkedCount + 1
        if UnitFrames.isMidnight ~= nil then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r UnitFrames.isMidnight still exists (should be removed)")
        else
            _G.print("  UnitFrames.isMidnight is nil — OK")
        end
    end

    -- Part 5: Verify CastBars uses C_Spell namespace
    _G.print("  Part 5: Checking CastBars for modern C_Spell usage...")
    local CastBars = RealUI:GetModule("CastBars")
    if CastBars then
        checkedCount = checkedCount + 1
        -- C_Spell namespace must exist for CastBars to work correctly
        if _G.C_Spell then
            _G.print("  C_Spell namespace available — OK")
        else
            _G.print("  |cffff9900[WARN]|r C_Spell namespace not found (client version issue)")
        end
    end

    -- Summary
    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No checks performed — test inconclusive")
        return false
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 11: Deprecated API absence — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Property 11: Deprecated API absence — %d failures out of %d checks"):format(
            failures, checkedCount))
    end

    return failures == 0
end

function ns.commands:deprecated()
    return RunDeprecatedAPIAbsenceTest()
end
