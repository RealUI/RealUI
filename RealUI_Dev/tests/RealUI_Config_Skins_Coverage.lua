local ADDON_NAME, ns = ... -- luacheck: ignore

-- Feature: realui-config-overhaul, Property 2: Skins section covers all AuroraConfig feature and appearance keys with neutral labels
-- Validates: Requirements 7.4, 22.1, 22.4
--
-- For any key in AuroraConfig that is a user-facing feature toggle (bags, banks,
-- chat, loot, mainmenubar, fonts, tooltips, chatBubbles, chatBubbleNames) or
-- appearance setting (buttonsHaveGradient, customHighlight, alpha), the Skins
-- section options table should contain a corresponding control, and no user-facing
-- name or desc string in the Skins section should contain the substring "Aurora".

---------------------------------------------------------------------------
-- Expected AuroraConfig keys that must have controls in the Skins section
---------------------------------------------------------------------------
local EXPECTED_FEATURE_KEYS = {
    "bags", "banks", "chat", "loot", "mainmenubar",
    "fonts", "tooltips", "chatBubbles", "chatBubbleNames",
}

local EXPECTED_APPEARANCE_KEYS = {
    "buttonsHaveGradient",  -- toggle in skinStyle
    "customHighlight",      -- customHighlightEnabled + highlightColor in skinStyle
    "alpha",                -- range in skinStyle
}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

--- Recursively walk an AceConfig options table and collect all arg entries.
--- Returns a flat list of { key = argKey, entry = argTable, path = "dotted.path" }
local function CollectAllArgs(optTable, path, results)
    results = results or {}
    path = path or ""
    if not optTable or type(optTable) ~= "table" then return results end

    local args = optTable.args
    if args and type(args) == "table" then
        for k, v in pairs(args) do
            local entryPath = (path ~= "" and (path .. "." .. k)) or k
            results[#results + 1] = { key = k, entry = v, path = entryPath }
            -- Recurse into sub-groups
            if v.type == "group" and v.args then
                CollectAllArgs(v, entryPath, results)
            end
        end
    end

    return results
end

--- Check if a string contains "Aurora" (case-insensitive)
local function containsAurora(str)
    if type(str) ~= "string" then return false end
    return str:lower():find("aurora") ~= nil
end

---------------------------------------------------------------------------
-- Test 1: Coverage — all expected AuroraConfig keys have controls
---------------------------------------------------------------------------
local function TestCoverage(skinsArgs)
    local passed, failed = 0, 0
    local firstFailure = nil

    -- Collect all arg keys recursively from the Skins section
    local allEntries = CollectAllArgs({ args = skinsArgs })
    local argKeySet = {}
    for _, entry in ipairs(allEntries) do
        argKeySet[entry.key] = true
    end

    -- Check feature keys: each should appear as a direct arg key in skinFeatures
    for _, key in ipairs(EXPECTED_FEATURE_KEYS) do
        if argKeySet[key] then
            passed = passed + 1
        else
            failed = failed + 1
            if not firstFailure then
                firstFailure = ("Feature key '%s' has no corresponding control in Skins options"):format(key)
            end
        end
    end

    -- Check appearance keys:
    -- "buttonsHaveGradient" should be a direct arg key
    -- "customHighlight" maps to "customHighlightEnabled" and "highlightColor"
    -- "alpha" should be a direct arg key
    for _, key in ipairs(EXPECTED_APPEARANCE_KEYS) do
        if key == "customHighlight" then
            -- customHighlight is represented by two controls
            local hasEnabled = argKeySet["customHighlightEnabled"]
            local hasColor = argKeySet["highlightColor"]
            if hasEnabled and hasColor then
                passed = passed + 1
            else
                failed = failed + 1
                if not firstFailure then
                    local missing = {}
                    if not hasEnabled then missing[#missing + 1] = "customHighlightEnabled" end
                    if not hasColor then missing[#missing + 1] = "highlightColor" end
                    firstFailure = ("Appearance key 'customHighlight' missing controls: %s"):format(
                        table.concat(missing, ", "))
                end
            end
        else
            if argKeySet[key] then
                passed = passed + 1
            else
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Appearance key '%s' has no corresponding control in Skins options"):format(key)
                end
            end
        end
    end

    return passed, failed, firstFailure
end

---------------------------------------------------------------------------
-- Test 2: Neutral labels — no name/desc contains "Aurora"
---------------------------------------------------------------------------
local function TestNeutralLabels(skinsArgs)
    local passed, failed = 0, 0
    local firstFailure = nil

    local allEntries = CollectAllArgs({ args = skinsArgs })

    for _, entry in ipairs(allEntries) do
        local e = entry.entry
        -- Check name field
        local nameVal = e.name
        if type(nameVal) == "function" then
            local ok, result = pcall(nameVal)
            if ok then nameVal = result end
        end
        if containsAurora(nameVal) then
            failed = failed + 1
            if not firstFailure then
                firstFailure = ("Entry '%s' has name containing 'Aurora': %s"):format(
                    entry.path, tostring(nameVal))
            end
        else
            passed = passed + 1
        end

        -- Check desc field
        local descVal = e.desc
        if type(descVal) == "function" then
            local ok, result = pcall(descVal)
            if ok then descVal = result end
        end
        if containsAurora(descVal) then
            failed = failed + 1
            if not firstFailure then
                firstFailure = ("Entry '%s' has desc containing 'Aurora': %s"):format(
                    entry.path, tostring(descVal))
            end
        else
            passed = passed + 1
        end
    end

    return passed, failed, firstFailure
end


---------------------------------------------------------------------------
-- Main runner
---------------------------------------------------------------------------
local function RunSkinsCoverageTest()
    -- Ensure RealUI_Config (LoadOnDemand) is loaded and options are registered
    if not _G.C_AddOns.IsAddOnLoaded("RealUI_Config") then
        _G.C_AddOns.LoadAddOn("RealUI_Config")
    end
    local ACR = _G.LibStub("AceConfigRegistry-3.0")
    if not ACR:GetOptionsTable("RealUI") then
        _G.RealUI.ToggleConfig("RealUI")
        _G.RealUI.ToggleConfig("RealUI")
    end

    -- Get the Skins options table via AceConfigRegistry
    local rootOptions = ACR:GetOptionsTable("RealUI", "dialog", "RealUI-1.0")
    if not rootOptions or not rootOptions.args then
        return 0, 1, "Could not retrieve RealUI options table from AceConfigRegistry"
    end

    local skinsSection = rootOptions.args.skins
    if not skinsSection or not skinsSection.args then
        return 0, 1, "Skins section not found in RealUI options table"
    end

    local skinsArgs = skinsSection.args

    local totalPassed, totalFailed = 0, 0
    local firstFailure = nil

    -- Run coverage test
    local p1, f1, ff1 = TestCoverage(skinsArgs)
    totalPassed = totalPassed + p1
    totalFailed = totalFailed + f1
    if not firstFailure and ff1 then firstFailure = ff1 end

    -- Run neutral labels test
    local p2, f2, ff2 = TestNeutralLabels(skinsArgs)
    totalPassed = totalPassed + p2
    totalFailed = totalFailed + f2
    if not firstFailure and ff2 then firstFailure = ff2 end

    return totalPassed, totalFailed, firstFailure
end


---------------------------------------------------------------------------
-- Slash command entry point: /realdev skinscoverage
---------------------------------------------------------------------------
function ns.commands:skinscoverage()
    _G.print("|cff00ccff[Skins Coverage]|r Running property test...")

    local ok, passed, failed, firstFailure = pcall(RunSkinsCoverageTest)
    if not ok then
        _G.print("|cffff0000[ERROR]|r Test threw an error: " .. tostring(passed))
        return false
    end

    local total = passed + failed
    _G.print(("  Checks: %d total, %d passed, %d failed"):format(total, passed, failed))

    if failed > 0 then
        _G.print("|cffff0000[FAIL]|r First failure: " .. (firstFailure or "unknown"))
        return false
    else
        _G.print("|cff00ff00[PASS]|r Skins section AuroraConfig coverage and neutral labels verified")
        return true
    end
end
