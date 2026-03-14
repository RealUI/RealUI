local ADDON_NAME, ns = ... -- luacheck: ignore

-- Feature: realui-config-overhaul, Property 10: Locked options have explanatory descriptions
-- Validates: Requirements 20.1, 20.2
--
-- For any option in the Advanced Options table that has a `disabled` callback
-- which can return true, the option should also have a `desc` field that
-- explains the lock condition, or the parent group should contain a description
-- explaining the lock.

---------------------------------------------------------------------------
-- Types to skip (non-interactive entries that don't need lock explanations)
---------------------------------------------------------------------------
local SKIP_TYPES = {
    header = true,
    description = true,
}

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

--- Check whether an option has a `disabled` field that is (or can return) true.
--- Returns true if the option is lockable.
local function isLockable(opt)
    if opt.disabled == true then
        return true
    end
    if type(opt.disabled) == "function" then
        -- We don't need to actually invoke it to prove it *can* return true;
        -- the mere existence of a disabled callback means the option can be
        -- locked under some condition.
        return true
    end
    return false
end

--- Check whether an option (or its parent group) has a desc explaining the lock.
local function hasExplanatoryDesc(opt, parentOpt)
    -- Check the option itself
    local desc = resolveValue(opt.desc)
    if type(desc) == "string" and #desc > 0 then
        return true
    end

    -- Check the parent group's desc
    if parentOpt then
        local parentDesc = resolveValue(parentOpt.desc)
        if type(parentDesc) == "string" and #parentDesc > 0 then
            return true
        end
    end

    return false
end

---------------------------------------------------------------------------
-- Recursive walker
---------------------------------------------------------------------------

--- Walk all args recursively. For each interactive option that has a `disabled`
--- field, verify it (or its parent) has a desc.
--- @param args table   AceConfig args table
--- @param path string  dot-separated path for diagnostics
--- @param parentOpt table|nil  the parent group option table
--- @param results table  { passed=n, failed=n, failures={string,...} }
local function walkArgs(args, path, parentOpt, results)
    if not args then return end
    for key, opt in next, args do
        if type(opt) == "table" and not SKIP_TYPES[opt.type] then
            local optPath = path .. "." .. key

            -- Check if this option is lockable
            if isLockable(opt) then
                if hasExplanatoryDesc(opt, parentOpt) then
                    results.passed = results.passed + 1
                else
                    results.failed = results.failed + 1
                    if #results.failures < 10 then
                        results.failures[#results.failures + 1] =
                            ("'%s' (type=%s) has disabled but no desc on self or parent"):format(
                                optPath, tostring(opt.type))
                    end
                end
            end

            -- Recurse into child args (pass current opt as parent)
            if opt.args then
                walkArgs(opt.args, optPath, opt, results)
            end
        end
    end
end

---------------------------------------------------------------------------
-- Main test runner
---------------------------------------------------------------------------
local function RunLockedOptionsDescTest()
    -- Ensure RealUI_Config (LoadOnDemand) is loaded and options are registered
    if not _G.C_AddOns.IsAddOnLoaded("RealUI_Config") then
        _G.C_AddOns.LoadAddOn("RealUI_Config")
    end
    local ACR = _G.LibStub("AceConfigRegistry-3.0")
    if not ACR then
        return 0, 1, { "AceConfigRegistry-3.0 not available" }
    end
    if not ACR:GetOptionsTable("RealUI") then
        _G.RealUI.ToggleConfig("RealUI")
        _G.RealUI.ToggleConfig("RealUI")
    end

    local rootOptions = ACR:GetOptionsTable("RealUI", "dialog", "RealUI-1.0")
    if not rootOptions or not rootOptions.args then
        return 0, 1, { "Could not retrieve RealUI options table" }
    end

    local results = { passed = 0, failed = 0, failures = {} }

    -- Walk the entire Advanced Options tree
    walkArgs(rootOptions.args, "RealUI", nil, results)

    return results.passed, results.failed, results.failures
end

---------------------------------------------------------------------------
-- Slash command entry point: /realdev lockedoptionsdesc
---------------------------------------------------------------------------
function ns.commands:lockedoptionsdesc()
    _G.print("|cff00ccff[Locked Options Desc]|r Running property test...")

    local ok, passed, failed, failures = pcall(RunLockedOptionsDescTest)
    if not ok then
        _G.print("|cffff0000[ERROR]|r Test threw an error: " .. tostring(passed))
        return false
    end

    local total = passed + failed
    _G.print(("  Checks: %d total, %d passed, %d failed"):format(total, passed, failed))

    if failed > 0 then
        for _, msg in ipairs(failures) do
            _G.print("  |cffff6666" .. msg .. "|r")
        end
        _G.print("|cffff0000[FAIL]|r Locked options missing explanatory descriptions")
        return false
    else
        _G.print("|cff00ff00[PASS]|r All locked options have explanatory descriptions")
        return true
    end
end
