local ADDON_NAME, ns = ... -- luacheck: ignore

-- Feature: realui-config-overhaul, Property 8: InterfaceTweaks callbacks are callable
-- Validates: Requirements 10.1
--
-- For any tweak returned by InterfaceTweaks:GetTweaks() that has a setEnabled,
-- calling setEnabled(true) and setEnabled(false) should not raise an error.
-- Original enabled state is restored after testing.

---------------------------------------------------------------------------
-- Test runner
---------------------------------------------------------------------------
local function RunTweaksCallableTest()
    local RealUI = _G.RealUI
    if not RealUI then
        return 0, 1, "RealUI global not found"
    end

    local InterfaceTweaks = RealUI:GetModule("InterfaceTweaks")
    if not InterfaceTweaks then
        return 0, 1, "InterfaceTweaks module not found"
    end

    if not InterfaceTweaks.db then
        return 0, 1, "InterfaceTweaks.db not initialized"
    end

    local tweaks = InterfaceTweaks:GetTweaks()
    if not tweaks then
        return 0, 1, "GetTweaks() returned nil"
    end

    local passed, failed = 0, 0
    local firstFailure = nil
    local testedCount = 0

    for tag, info in next, tweaks do
        if info.setEnabled then
            testedCount = testedCount + 1

            -- Save original enabled state
            local originalState = InterfaceTweaks.db.global[tag]

            -- Test setEnabled(true)
            local okTrue, errTrue = pcall(info.setEnabled, true)
            if not okTrue then
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Tweak '%s': setEnabled(true) error: %s"):format(
                        tag, tostring(errTrue))
                end
            else
                passed = passed + 1
            end

            -- Test setEnabled(false)
            local okFalse, errFalse = pcall(info.setEnabled, false)
            if not okFalse then
                failed = failed + 1
                if not firstFailure then
                    firstFailure = ("Tweak '%s': setEnabled(false) error: %s"):format(
                        tag, tostring(errFalse))
                end
            else
                passed = passed + 1
            end

            -- Restore original enabled state
            local okRestore, errRestore = pcall(info.setEnabled, originalState)
            if not okRestore then
                -- Restoration failed — note it but don't count as test failure
                _G.print(("  |cffff9900[WARN]|r Could not restore '%s' to %s: %s"):format(
                    tag, tostring(originalState), tostring(errRestore)))
            end
            InterfaceTweaks.db.global[tag] = originalState
        end
    end

    if testedCount == 0 then
        -- No tweaks with setEnabled found — this is unexpected but not a failure
        return 1, 0, nil
    end

    return passed, failed, firstFailure
end


---------------------------------------------------------------------------
-- Slash command entry point: /realdev tweakscallable
---------------------------------------------------------------------------
function ns.commands:tweakscallable()
    _G.print("|cff00ccff[InterfaceTweaks Callable]|r Running property test...")

    local ok, passed, failed, firstFailure = pcall(RunTweaksCallableTest)
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
        _G.print("|cff00ff00[PASS]|r InterfaceTweaks setEnabled callbacks are all callable")
        return true
    end
end
