local ADDON_NAME, ns = ... -- luacheck: ignore

-- Feature: realui-config-overhaul, Property 6: Addon skin list matches Aurora.Base.GetAddonSkins
-- Validates: Requirements 7.1
--
-- Every toggle in the Addons group corresponds to a name in
-- Aurora.Base.GetAddonSkins(). Conversely, every non-RealUI name from
-- GetAddonSkins() has a toggle in the Addons group.

---------------------------------------------------------------------------
-- Test 1: Every toggle key in the addons group is in GetAddonSkins()
---------------------------------------------------------------------------
local function TestToggleKeysInSkinList(addonsArgs, skinSet)
    local passed, failed = 0, 0
    local firstFailure = nil

    for key, entry in pairs(addonsArgs) do
        if entry.type == "toggle" then
            if skinSet[key] then
                passed = passed + 1
            else
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Toggle '%s' in Addons group has no match in GetAddonSkins()"):format(key)
                end
            end
        end
    end

    return passed, failed, firstFailure
end

---------------------------------------------------------------------------
-- Test 2: Every non-RealUI name from GetAddonSkins() has a toggle
---------------------------------------------------------------------------
local function TestSkinListHasToggles(addonsArgs, addonSkins)
    local passed, failed = 0, 0
    local firstFailure = nil

    for i = 1, #addonSkins do
        local name = addonSkins[i]
        -- Advanced.lua filters out names containing "RealUI"
        if not name:find("RealUI") then
            local entry = addonsArgs[name]
            if entry and entry.type == "toggle" then
                passed = passed + 1
            else
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("GetAddonSkins() name '%s' has no toggle in Addons group"):format(name)
                end
            end
        end
    end

    return passed, failed, firstFailure
end


---------------------------------------------------------------------------
-- Main runner
---------------------------------------------------------------------------
local function RunAddonSkinsMatchTest()
    -- Get the addon skins list from Aurora
    if not _G.Aurora or not _G.Aurora.Base or not _G.Aurora.Base.GetAddonSkins then
        return 0, 1, "Aurora.Base.GetAddonSkins is not available"
    end

    local addonSkins = _G.Aurora.Base.GetAddonSkins()
    if not addonSkins then
        return 0, 1, "Aurora.Base.GetAddonSkins() returned nil"
    end

    -- Build a set for fast lookup
    local skinSet = {}
    for i = 1, #addonSkins do
        skinSet[addonSkins[i]] = true
    end

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

    local addonsGroup = skinsSection.args.addons
    if not addonsGroup or not addonsGroup.args then
        return 0, 1, "Addons group not found in Skins options"
    end

    local addonsArgs = addonsGroup.args
    local totalPassed, totalFailed = 0, 0
    local firstFailure = nil

    -- Test 1: every toggle key is in GetAddonSkins()
    local p1, f1, ff1 = TestToggleKeysInSkinList(addonsArgs, skinSet)
    totalPassed = totalPassed + p1
    totalFailed = totalFailed + f1
    if not firstFailure and ff1 then firstFailure = ff1 end

    -- Test 2: every non-RealUI skin has a toggle
    local p2, f2, ff2 = TestSkinListHasToggles(addonsArgs, addonSkins)
    totalPassed = totalPassed + p2
    totalFailed = totalFailed + f2
    if not firstFailure and ff2 then firstFailure = ff2 end

    return totalPassed, totalFailed, firstFailure
end


---------------------------------------------------------------------------
-- Slash command entry point: /realdev addonskinscheck
---------------------------------------------------------------------------
function ns.commands:addonskinscheck()
    _G.print("|cff00ccff[Addon Skins Match]|r Running property test...")

    local ok, passed, failed, firstFailure = pcall(RunAddonSkinsMatchTest)
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
        _G.print("|cff00ff00[PASS]|r Addon skin list matches Aurora.Base.GetAddonSkins verified")
        return true
    end
end
