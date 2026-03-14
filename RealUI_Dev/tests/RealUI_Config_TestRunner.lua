local ADDON_NAME, ns = ... -- luacheck: ignore

-- Config Overhaul Test Suite Runner
-- Runs all 10 property tests from the realui-config-overhaul spec in sequence,
-- collects results, and prints a summary.
--
-- Usage: /realdev configtests

local configTests = {
    { name = "auroraconfigrt",      label = "Property 1: AuroraConfig round-trip consistency" },
    { name = "skinscoverage",       label = "Property 2: Skins coverage (AuroraConfig keys + neutral labels)" },
    { name = "pixelperfectscale",   label = "Property 5: Pixel Perfect disables custom scale" },
    { name = "addonskinscheck",     label = "Property 6: Addon skin list matches Aurora.Base.GetAddonSkins" },
    { name = "systemsnodupes",      label = "Property 3: Systems_Menu no duplicate keys" },
    { name = "tweakscallable",      label = "Property 8: InterfaceTweaks callbacks callable" },
    { name = "moduledisabledcascade", label = "Property 7: Module-disabled cascades to sub-options" },
    { name = "wizardannotations",   label = "Property 9: Install Wizard annotations present" },
    { name = "lockedoptionsdesc",   label = "Property 10: Locked options have explanatory descriptions" },
    { name = "blocktoggles",        label = "Property 4: Block toggles complete" },
    { name = "configunitchecks",    label = "Unit: Option existence and label checks" },
}

function ns.commands:configtests()
    _G.print("|cff00ccff[Config Overhaul Test Suite]|r Running all " .. #configTests .. " tests...")

    -- Ensure RealUI_Config (LoadOnDemand) is loaded and options are registered
    if not _G.C_AddOns.IsAddOnLoaded("RealUI_Config") then
        _G.C_AddOns.LoadAddOn("RealUI_Config")
    end
    local ACR = _G.LibStub("AceConfigRegistry-3.0")
    if not ACR:GetOptionsTable("RealUI") then
        _G.RealUI.ToggleConfig("RealUI")
        _G.RealUI.ToggleConfig("RealUI")
    end

    _G.print("---")

    local passed, failed, skipped = 0, 0, 0
    local failures = {}

    for _, test in _G.ipairs(configTests) do
        local cmd = ns.commands[test.name]
        if cmd then
            local ok, result = _G.pcall(cmd, ns.commands)
            if not ok then
                -- pcall caught an error thrown by the test itself
                failed = failed + 1
                failures[#failures + 1] = test.label .. " (error: " .. tostring(result) .. ")"
            elseif result == false then
                failed = failed + 1
                failures[#failures + 1] = test.label
            elseif result == nil then
                skipped = skipped + 1
            else
                passed = passed + 1
            end
        else
            _G.print(("|cffff9900[SKIP]|r %s — command '%s' not found"):format(test.label, test.name))
            skipped = skipped + 1
        end
    end

    _G.print("---")

    if #failures > 0 then
        _G.print("|cffff0000Failing tests:|r")
        for _, name in _G.ipairs(failures) do
            _G.print("  - " .. name)
        end
    end

    local skipMsg = skipped > 0 and (", " .. skipped .. " skipped") or ""
    if failed == 0 then
        _G.print(("|cff00ff00[SUITE PASS]|r All %d config overhaul tests passed%s"):format(passed, skipMsg))
    else
        _G.print(("|cffff0000[SUITE FAIL]|r %d passed, %d failed%s"):format(passed, failed, skipMsg))
    end
end
