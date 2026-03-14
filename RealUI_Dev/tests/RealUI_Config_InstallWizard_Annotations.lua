local ADDON_NAME, ns = ... -- luacheck: ignore

-- Feature: realui-config-overhaul, Property 9: Install Wizard affected settings are annotated
-- Validates: Requirements 18.2
--
-- For each setting in the documented Install Wizard affected list, the option's
-- desc field contains a warning substring indicating the Install Wizard may
-- reset the value.

local WIZARD_WARNING = "Install Wizard"

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
--- e.g. walkPath(opts, "other.general.layout") returns opts.args.other.args.general.args.layout
local function walkPath(optTable, path)
    local current = optTable
    for segment in path:gmatch("[^%.]+") do
        if not current or not current.args then return nil end
        current = current.args[segment]
    end
    return current
end

---------------------------------------------------------------------------
-- Settings to check
---------------------------------------------------------------------------
-- Each entry: { appName, dotted path within the options table, label }
local WIZARD_SETTINGS = {
    {
        appName = "RealUI",
        path    = "skins.isHighRes",
        label   = "isHighRes (Skins → High Resolution)",
    },
    {
        appName = "HuD",
        path    = "other.general.layout",
        label   = "layout (HuD Config → Other → Layout)",
    },
    {
        appName = "HuD",
        path    = "other.general.useLarge",
        label   = "useLarge (HuD Config → Other → Use Large)",
    },
}


---------------------------------------------------------------------------
-- Main test runner
---------------------------------------------------------------------------
local function RunWizardAnnotationTest()
    -- Ensure RealUI_Config (LoadOnDemand) is loaded and options are registered
    if not _G.C_AddOns.IsAddOnLoaded("RealUI_Config") then
        _G.C_AddOns.LoadAddOn("RealUI_Config")
    end
    local ACR = _G.LibStub("AceConfigRegistry-3.0")
    if not ACR then
        return 0, 1, "AceConfigRegistry-3.0 not available"
    end
    if not ACR:GetOptionsTable("RealUI") then
        _G.RealUI.ToggleConfig("RealUI")
        _G.RealUI.ToggleConfig("RealUI")
    end

    local passed, failed = 0, 0
    local firstFailure = nil

    -- Cache fetched option tables by appName
    local optionsCache = {}

    for _, setting in ipairs(WIZARD_SETTINGS) do
        -- Fetch the root options table for this appName
        if not optionsCache[setting.appName] then
            local rootOpts = ACR:GetOptionsTable(setting.appName, "dialog", "RealUI-1.0")
            optionsCache[setting.appName] = rootOpts
        end

        local rootOpts = optionsCache[setting.appName]
        if not rootOpts or not rootOpts.args then
            failed = failed + 1
            if not firstFailure then
                firstFailure = ("Could not retrieve '%s' options table for setting: %s"):format(
                    setting.appName, setting.label)
            end
        else
            local entry = walkPath(rootOpts, setting.path)
            if not entry then
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Option not found at path '%s' in '%s' for setting: %s"):format(
                        setting.path, setting.appName, setting.label)
                end
            else
                local desc = resolveValue(entry.desc)
                if type(desc) == "string" and desc:find(WIZARD_WARNING) then
                    passed = passed + 1
                else
                    failed = failed + 1
                    if not firstFailure then
                        firstFailure = ("Setting '%s' desc does not contain '%s'. desc = %s"):format(
                            setting.label, WIZARD_WARNING, tostring(desc))
                    end
                end
            end
        end
    end

    return passed, failed, firstFailure
end

---------------------------------------------------------------------------
-- Slash command entry point: /realdev wizardannotations
---------------------------------------------------------------------------
function ns.commands:wizardannotations()
    _G.print("|cff00ccff[Wizard Annotations]|r Running property test...")

    local ok, passed, failed, firstFailure = pcall(RunWizardAnnotationTest)
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
        _G.print("|cff00ff00[PASS]|r Install Wizard affected settings are annotated")
        return true
    end
end
