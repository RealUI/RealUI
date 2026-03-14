local ADDON_NAME, ns = ... -- luacheck: ignore

-- Unit Tests: Specific option existence and label checks
-- Validates: Requirements 9.2, 17.3, 22.1
--
-- Check 1: Tooltip position controls (atCursor, x, y, point) exist
-- Check 2: No Skins section name field contains "Aurora"
-- Check 3: "Delves" label in Objectives collapse toggles
-- Check 4: Profile description text present
-- Check 5: Install Wizard annotation on isHighRes

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

--- Resolve a value that may be a string or a function returning a string.
local function resolveValue(val)
    if type(val) == "function" then
        local ok, result = pcall(val)
        if ok then return result end
        return nil
    end
    return val
end

--- Walk a dotted key path into an AceConfig options table.
local function walkPath(optTable, path)
    local current = optTable
    for segment in path:gmatch("[^%.]+") do
        if not current or not current.args then return nil end
        current = current.args[segment]
    end
    return current
end

--- Recursively check all name fields in an options subtree.
--- Returns true if any name contains the needle (case-insensitive).
--- Skips desc fields intentionally.
local function anyNameContains(optArgs, needle, path)
    if not optArgs or type(optArgs) ~= "table" then return nil end
    local lowerNeedle = needle:lower()
    for k, v in pairs(optArgs) do
        if type(v) == "table" then
            local entryPath = path and (path .. "." .. k) or k
            local nameVal = resolveValue(v.name)
            if type(nameVal) == "string" and nameVal:lower():find(lowerNeedle) then
                return entryPath, nameVal
            end
            -- Recurse into sub-groups
            if v.args then
                local found, foundName = anyNameContains(v.args, needle, entryPath)
                if found then return found, foundName end
            end
        end
    end
    return nil
end

---------------------------------------------------------------------------
-- Checks
---------------------------------------------------------------------------

local function Check1_TooltipPositionControls(rootOptions)
    local posArgs = walkPath(rootOptions, "tooltips.position")
    if not posArgs or not posArgs.args then
        return false, "tooltips.position group not found"
    end
    local required = { "atCursor", "x", "y", "point" }
    for _, key in ipairs(required) do
        if not posArgs.args[key] then
            return false, ("tooltips.position.args.%s not found"):format(key)
        end
    end
    return true
end

local function Check2_NoAuroraInSkinsNames(rootOptions)
    local skinsSection = rootOptions.args.skins
    if not skinsSection or not skinsSection.args then
        return false, "skins section not found"
    end
    local foundPath, foundName = anyNameContains(skinsSection.args, "Aurora")
    if foundPath then
        return false, ("Skins name contains 'Aurora' at %s: %s"):format(foundPath, foundName)
    end
    return true
end

local function Check3_DelvesLabel(rootOptions)
    local dvelve = walkPath(rootOptions, "uiTweaks.objectives.hidden.collapse.dvelve")
    if not dvelve then
        return false, "uiTweaks.objectives.hidden.collapse.dvelve not found"
    end
    local nameVal = resolveValue(dvelve.name)
    if nameVal ~= "Delves" then
        return false, ("Expected name 'Delves', got '%s'"):format(tostring(nameVal))
    end
    return true
end

local function Check4_ProfileDescription(rootOptions)
    local desc = walkPath(rootOptions, "profiles.profileScopesDesc")
    if not desc then
        return false, "profiles.profileScopesDesc not found"
    end
    local nameVal = resolveValue(desc.name)
    if type(nameVal) ~= "string" or nameVal == "" then
        return false, "profileScopesDesc has empty or missing name"
    end
    return true
end

local function Check5_InstallWizardAnnotation(rootOptions)
    local isHighRes = walkPath(rootOptions, "skins.isHighRes")
    if not isHighRes then
        return false, "skins.isHighRes not found"
    end
    local descVal = resolveValue(isHighRes.desc)
    if type(descVal) ~= "string" or not descVal:find("Install Wizard") then
        return false, ("isHighRes desc does not contain 'Install Wizard': %s"):format(tostring(descVal))
    end
    return true
end

---------------------------------------------------------------------------
-- Main runner
---------------------------------------------------------------------------

local CHECKS = {
    { name = "Tooltip position controls exist",         fn = Check1_TooltipPositionControls },
    { name = "No Skins label contains 'Aurora'",        fn = Check2_NoAuroraInSkinsNames },
    { name = "'Delves' label in Objectives",            fn = Check3_DelvesLabel },
    { name = "Profile description text present",        fn = Check4_ProfileDescription },
    { name = "Install Wizard annotation on isHighRes",  fn = Check5_InstallWizardAnnotation },
}

local function RunUnitChecks()
    -- Ensure RealUI_Config (LoadOnDemand) is loaded and options are registered
    if not _G.C_AddOns.IsAddOnLoaded("RealUI_Config") then
        _G.C_AddOns.LoadAddOn("RealUI_Config")
    end
    local ACR = _G.LibStub("AceConfigRegistry-3.0")
    if not ACR then
        return 0, #CHECKS, "AceConfigRegistry-3.0 not available"
    end
    if not ACR:GetOptionsTable("RealUI") then
        _G.RealUI.ToggleConfig("RealUI")
        _G.RealUI.ToggleConfig("RealUI")
    end

    local rootOptions = ACR:GetOptionsTable("RealUI", "dialog", "RealUI-1.0")
    if not rootOptions or not rootOptions.args then
        return 0, #CHECKS, "Could not retrieve RealUI options table"
    end

    local passed, failed = 0, 0
    local firstFailure = nil

    for _, check in ipairs(CHECKS) do
        local ok, err = check.fn(rootOptions)
        if ok then
            passed = passed + 1
            _G.print(("  |cff00ff00[PASS]|r %s"):format(check.name))
        else
            failed = failed + 1
            _G.print(("  |cffff0000[FAIL]|r %s — %s"):format(check.name, err or "unknown"))
            if not firstFailure then
                firstFailure = ("%s: %s"):format(check.name, err or "unknown")
            end
        end
    end

    return passed, failed, firstFailure
end

---------------------------------------------------------------------------
-- Slash command entry point: /realdev configunitchecks
---------------------------------------------------------------------------
function ns.commands:configunitchecks()
    _G.print("|cff00ccff[Config Unit Checks]|r Running " .. #CHECKS .. " checks...")

    local ok, passed, failed, firstFailure = pcall(RunUnitChecks)
    if not ok then
        _G.print("|cffff0000[ERROR]|r Test threw an error: " .. tostring(passed))
        return false
    end

    local total = passed + failed
    _G.print("---")
    _G.print(("  Total: %d, Passed: %d, Failed: %d"):format(total, passed, failed))

    if failed > 0 then
        _G.print("|cffff0000[FAIL]|r First failure: " .. (firstFailure or "unknown"))
        return false
    else
        _G.print("|cff00ff00[PASS]|r All config unit checks passed")
        return true
    end
end
