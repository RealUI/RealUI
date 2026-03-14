local ADDON_NAME, ns = ... -- luacheck: ignore

-- Feature: realui-config-overhaul, Property 3: Systems_Menu contains no duplicates of other Advanced_Options subgroups
-- Validates: Requirements 1.1
--
-- For any key in the Systems_Menu options table args, that key should not also
-- appear as a direct child key in any other Advanced_Options subgroup
-- (Core, CombatText, Inventory, Skins, Tooltips, UI Tweaks).

---------------------------------------------------------------------------
-- The other Advanced_Options subgroup keys in the root options table
---------------------------------------------------------------------------
local OTHER_SUBGROUPS = {
    "core",
    "combatText",
    "inventory",
    "skins",
    "tooltips",
    "uiTweaks",
}

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

--- Collect all direct child arg keys from a section's args table.
--- Skips structural entries (header, desc) that are just decoration.
local STRUCTURAL_KEYS = { header = true, desc = true, note = true, description = true, profiles = true }
local function CollectDirectArgKeys(argsTable)
    local keys = {}
    if not argsTable or type(argsTable) ~= "table" then return keys end
    for k, v in pairs(argsTable) do
        -- Skip structural/decoration keys that commonly repeat across sections
        if not STRUCTURAL_KEYS[k] then
            keys[k] = true
        end
    end
    return keys
end

---------------------------------------------------------------------------
-- Main test
---------------------------------------------------------------------------
local function RunNoDuplicatesTest()
    -- Ensure RealUI_Config (LoadOnDemand) is loaded and options are registered
    if not _G.C_AddOns.IsAddOnLoaded("RealUI_Config") then
        _G.C_AddOns.LoadAddOn("RealUI_Config")
    end
    local ACR = _G.LibStub("AceConfigRegistry-3.0")
    if not ACR:GetOptionsTable("RealUI") then
        _G.RealUI.ToggleConfig("RealUI")
        _G.RealUI.ToggleConfig("RealUI")
    end

    -- Get the RealUI options table via AceConfigRegistry
    local rootOptions = ACR:GetOptionsTable("RealUI", "dialog", "RealUI-1.0")
    if not rootOptions or not rootOptions.args then
        return 0, 1, "Could not retrieve RealUI options table from AceConfigRegistry"
    end

    -- Find the Systems section
    local systemsSection = rootOptions.args.systems
    if not systemsSection or not systemsSection.args then
        return 0, 1, "Systems section not found in RealUI options table"
    end

    -- Collect all direct child arg keys from Systems
    local systemsKeys = CollectDirectArgKeys(systemsSection.args)

    local passed, failed = 0, 0
    local firstFailure = nil

    -- For each other subgroup, collect its direct child arg keys and check for overlap
    for _, subgroupKey in ipairs(OTHER_SUBGROUPS) do
        local subgroup = rootOptions.args[subgroupKey]
        if subgroup and subgroup.args then
            local subgroupArgKeys = CollectDirectArgKeys(subgroup.args)

            for sysKey in pairs(systemsKeys) do
                if subgroupArgKeys[sysKey] then
                    failed = failed + 1
                    if not firstFailure then
                        firstFailure = ("Systems key '%s' also appears in '%s' subgroup"):format(
                            sysKey, subgroupKey)
                    end
                else
                    passed = passed + 1
                end
            end
        else
            -- Subgroup not present or has no args — all systems keys pass for this subgroup
            for _ in pairs(systemsKeys) do
                passed = passed + 1
            end
        end
    end

    -- Edge case: if Systems has no keys at all, that's a trivial pass
    if passed == 0 and failed == 0 then
        passed = 1  -- vacuously true
    end

    return passed, failed, firstFailure
end

---------------------------------------------------------------------------
-- Slash command entry point: /realdev systemsnodupes
---------------------------------------------------------------------------
function ns.commands:systemsnodupes()
    _G.print("|cff00ccff[Systems No-Duplicate Keys]|r Running property test...")

    local ok, passed, failed, firstFailure = pcall(RunNoDuplicatesTest)
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
        _G.print("|cff00ff00[PASS]|r Systems_Menu contains no duplicates of other Advanced_Options subgroups")
        return true
    end
end
