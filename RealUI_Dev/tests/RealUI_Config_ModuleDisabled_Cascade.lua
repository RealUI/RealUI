local ADDON_NAME, ns = ... -- luacheck: ignore

-- Feature: realui-config-overhaul, Property 7: Module-disabled cascades to sub-options
-- Validates: Requirements 7.2, 11.2
--
-- When a module's enabled state is false, all sub-option controls in that
-- section that have a `disabled` callback should return true.
-- Tests AltPowerBar, CooldownCount, EventNotifier, MirrorBar, MinimapAdv,
-- and ObjectivesAdv.

---------------------------------------------------------------------------
-- Module-to-section-key mapping in optArgs.uiTweaks.args
---------------------------------------------------------------------------
local MODULE_SECTIONS = {
    { modName = "AltPowerBar",      sectionKey = "altPowerBar" },
    { modName = "CooldownCount",    sectionKey = "cooldown" },
    { modName = "EventNotifier",    sectionKey = "eventNotify" },
    { modName = "MirrorBar",        sectionKey = "mirrorBar" },
    { modName = "MinimapAdv",       sectionKey = "minimap" },
    { modName = "Objectives Adv.",  sectionKey = "objectives" },
}

---------------------------------------------------------------------------
-- Helpers: recursively walk an AceConfig options table
---------------------------------------------------------------------------
-- Skips the top-level "enabled" toggle itself (that's the module on/off),
-- description entries, and header entries.
local SKIP_TYPES = { header = true, description = true }

local function isSkippable(key, opt)
    if SKIP_TYPES[opt.type] then return true end
    -- The top-level enabled toggle is the module on/off switch, not a sub-option
    if key == "enabled" and opt.type == "toggle" then return true end
    return false
end

--- Walk all args recursively. For each option that has a `disabled` callback,
--- call it and record whether it returns true.
--- @param args table  AceConfig args table
--- @param path string  dot-separated path for diagnostics
--- @param depth number  current recursion depth (to skip top-level enabled)
--- @param results table  { passed = n, failed = n, firstFailure = string|nil }
local function walkArgs(args, path, depth, results)
    if not args then return end
    for key, opt in next, args do
        if type(opt) == "table" and not isSkippable(key, opt) then
            local optPath = path .. "." .. key

            -- Check disabled callback on this node
            if type(opt.disabled) == "function" then
                -- Call with a minimal fake info table (some callbacks use info)
                local ok, ret = pcall(opt.disabled, { [1] = key, [#({key})] = key })
                if not ok then
                    results.failed = results.failed + 1
                    if not results.firstFailure then
                        results.firstFailure = ("'%s' disabled() errored: %s"):format(
                            optPath, tostring(ret))
                    end
                elseif not ret then
                    results.failed = results.failed + 1
                    if not results.firstFailure then
                        results.firstFailure = ("'%s' disabled() returned %s, expected true"):format(
                            optPath, tostring(ret))
                    end
                else
                    results.passed = results.passed + 1
                end
            elseif opt.disabled == true then
                -- Static disabled = true also counts as disabled
                results.passed = results.passed + 1
            end

            -- Recurse into child args
            if opt.args then
                walkArgs(opt.args, optPath, depth + 1, results)
            end
        end
    end
end


---------------------------------------------------------------------------
-- Main test runner
---------------------------------------------------------------------------
local function RunModuleDisabledCascadeTest()
    local RealUI = _G.RealUI
    if not RealUI then
        return 0, 1, "RealUI global not found"
    end

    -- Ensure RealUI_Config (LoadOnDemand) is loaded and options are registered
    if not _G.C_AddOns.IsAddOnLoaded("RealUI_Config") then
        _G.C_AddOns.LoadAddOn("RealUI_Config")
    end
    local ACR = _G.LibStub and _G.LibStub("AceConfigRegistry-3.0")
    if not ACR then
        return 0, 1, "AceConfigRegistry-3.0 not found"
    end
    if not ACR:GetOptionsTable("RealUI") then
        _G.RealUI.ToggleConfig("RealUI")
        _G.RealUI.ToggleConfig("RealUI")
    end

    local optTable = ACR:GetOptionsTable("RealUI", "dialog", "RealUI-1.0")
    if not optTable then
        return 0, 1, "RealUI options table not registered"
    end

    local uiTweaks = optTable.args and optTable.args.uiTweaks
    if not uiTweaks or not uiTweaks.args then
        return 0, 1, "uiTweaks section not found in options table"
    end

    local totalPassed, totalFailed = 0, 0
    local firstFailure = nil

    for _, entry in ipairs(MODULE_SECTIONS) do
        local modName = entry.modName
        local sectionKey = entry.sectionKey
        local section = uiTweaks.args[sectionKey]

        if not section then
            totalFailed = totalFailed + 1
            if not firstFailure then
                firstFailure = ("Section '%s' (module '%s') not found in uiTweaks.args"):format(
                    sectionKey, modName)
            end
        elseif not section.args then
            totalFailed = totalFailed + 1
            if not firstFailure then
                firstFailure = ("Section '%s' has no args"):format(sectionKey)
            end
        else
            -- Save original module enabled state
            local wasEnabled = RealUI:GetModuleEnabled(modName)

            -- Disable the module
            RealUI:SetModuleEnabled(modName, false)

            -- Walk all sub-options (skip the enabled toggle itself)
            local results = { passed = 0, failed = 0, firstFailure = nil }
            walkArgs(section.args, sectionKey, 0, results)

            -- Restore original state
            RealUI:SetModuleEnabled(modName, wasEnabled)

            totalPassed = totalPassed + results.passed
            totalFailed = totalFailed + results.failed

            if results.firstFailure and not firstFailure then
                firstFailure = ("[%s] %s"):format(modName, results.firstFailure)
            end

            -- If no disabled callbacks were found at all, that's worth noting
            -- but not a failure — some modules may not have sub-options with
            -- disabled callbacks (e.g., EventNotifier's events group).
        end
    end

    return totalPassed, totalFailed, firstFailure
end


---------------------------------------------------------------------------
-- Slash command entry point: /realdev moduledisabledcascade
---------------------------------------------------------------------------
function ns.commands:moduledisabledcascade()
    _G.print("|cff00ccff[Module-Disabled Cascade]|r Running property test...")

    local ok, passed, failed, firstFailure = pcall(RunModuleDisabledCascadeTest)
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
        _G.print("|cff00ff00[PASS]|r Module-disabled cascades to sub-options verified")
        return true
    end
end
