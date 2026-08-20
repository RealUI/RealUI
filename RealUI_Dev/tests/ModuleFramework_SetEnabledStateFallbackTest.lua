local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: SetEnabledState honours unregistered modules
-- Feature: B54 — cast bars could not be kept disabled (docs/Beta3-Feedback.md)
--
-- RealUI installs a default module prototype (Core/ModuleFramework.lua) whose
-- SetEnabledState replaces AceAddon's for EVERY module. Its ModuleFramework
-- route only acts on modules that called RegisterRealUIModule, and most never
-- do -- so for them the call used to fall through and return false without
-- touching anything. The module then kept AceAddon's default enabled state
-- regardless of the saved profile, and ConfigPersistence:PersistModuleStates
-- wrote that stale runtime state back over the user's setting.
--
-- Property: for a module NOT registered with ModuleFramework,
-- SetEnabledState(v) followed by IsEnabled() returns v. AceAddon's own
-- SetEnabledState is `self.enabledState = state` and does not run
-- OnEnable/OnDisable, so flipping the flag here has no side effects.

-- CastBars is the module the bug was reported against and is not registered.
local UNREGISTERED_MODULE = "CastBars"

local function RunSetEnabledStateFallbackTest()
    _G.print("|cff00ccff[PBT]|r B54: SetEnabledState honours unregistered modules")

    local RealUI = _G.RealUI

    if not RealUI or not RealUI.ModuleFramework then
        _G.print("|cffff0000[FAIL]|r RealUI or RealUI.ModuleFramework not available")
        return false
    end

    local module = RealUI:GetModule(UNREGISTERED_MODULE, true)
    if not module then
        _G.print(("|cffff0000[FAIL]|r module '%s' not found"):format(UNREGISTERED_MODULE))
        return false
    end

    -- If this module ever gets registered with ModuleFramework the test is
    -- exercising the wrong branch, so say so instead of passing quietly.
    if RealUI.ModuleFramework:IsModuleRegistered(UNREGISTERED_MODULE) then
        _G.print(("|cffff0000[FAIL]|r '%s' is now ModuleFramework-registered — this test no longer covers the fallback branch; point it at another unregistered module"):format(UNREGISTERED_MODULE))
        return false
    end

    -- IsEnabled() can report nil rather than false, so normalise to a real
    -- boolean everywhere before comparing.
    local original = module:IsEnabled() and true or false
    local failures = 0

    -- Both directions, starting from whichever state the module is in, so the
    -- test does not depend on the player's current setting.
    for _, target in _G.ipairs({false, true, false, true}) do
        module:SetEnabledState(target)
        local actual = module:IsEnabled() and true or false
        if actual ~= target then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r SetEnabledState(%s) then IsEnabled()=%s"):format(
                _G.tostring(target), _G.tostring(actual)))
        end
    end

    -- Restore whatever the player had.
    module:SetEnabledState(original)
    if (module:IsEnabled() and true or false) ~= original then
        failures = failures + 1
        _G.print(("|cffff0000[FAIL]|r could not restore original state (%s)"):format(_G.tostring(original)))
    end

    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r B54: '%s' honours SetEnabledState in both directions"):format(UNREGISTERED_MODULE))
    else
        _G.print(("|cffff0000[FAIL]|r B54: SetEnabledState fallback — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:setenabledstatefallback()
    return RunSetEnabledStateFallbackTest()
end
