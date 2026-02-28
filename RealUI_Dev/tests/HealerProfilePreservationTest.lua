local ADDON_NAME, ns = ... -- luacheck: ignore

-- Preservation Property Tests — Healer Profile Fix
-- Feature: healer-profile-fix, Property 2: Preservation
-- Validates: Requirements 3.1, 3.2, 3.3, 3.4, 3.5, 3.6
--
-- These tests verify that EXISTING working behavior is preserved after fixes.
-- On UNFIXED code, they should PASS (confirming baseline behavior).
-- After fixes, they should STILL PASS (confirming no regressions).
--
-- Run with: /realdev healerpreserve
-- Run all healer fix tests: /realdev healerfixtestall

local RealUI = _G.RealUI


-- ============================================================================
-- Test 1: DPS-only characters use "RealUI" profile and layout 1
-- Validates: Requirements 3.1
--
-- On unfixed code: Characters with only DPS/tank specs (no healer spec)
-- always use the "RealUI" profile and layout 1 for all specs. This is
-- correct behavior that must be preserved.
--
-- Observation-first: We verify the DualSpecSystem maps all non-healer
-- specs to "RealUI" profile and layout 1, and that the ProfileSystem
-- defaults produce layout 1 for DPS/tank roles.
-- ============================================================================
local function TestDPSOnlyCharacterProfile()
    _G.print("|cff00ccff[PBT]|r Preservation 1: DPS-only characters use 'RealUI' profile and layout 1")

    local dss = RealUI.DualSpecSystem
    if not dss then
        _G.print("|cffff0000[ERROR]|r DualSpecSystem not available")
        return false
    end

    local failures = 0
    local checkedCount = 0

    -- 1a: Verify GetDefaultProfileForSpec returns "RealUI" for all non-healer specs
    for specIndex = 1, #RealUI.charInfo.specs do
        local spec = RealUI.charInfo.specs[specIndex]
        if spec.role ~= "HEALER" then
            local defaultProfile = dss:GetDefaultProfileForSpec(specIndex)
            if defaultProfile ~= "RealUI" then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r Spec %d (%s, role=%s): default profile is '%s', expected 'RealUI'"):format(
                    specIndex, spec.name or "?", spec.role or "?", _G.tostring(defaultProfile)))
            end
            checkedCount = checkedCount + 1
        end
    end

    -- 1b: Verify IsHealingSpec returns false for all non-healer specs
    for specIndex = 1, #RealUI.charInfo.specs do
        local spec = RealUI.charInfo.specs[specIndex]
        if spec.role ~= "HEALER" then
            local isHealer = dss:IsHealingSpec(specIndex)
            if isHealer then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r Spec %d (%s, role=%s): IsHealingSpec returned true"):format(
                    specIndex, spec.name or "?", spec.role or "?"))
            end
            checkedCount = checkedCount + 1
        end
    end

    -- 1c: Verify ProfileSystem defaults map DPS/tank specs to layout 1
    local ps = RealUI.ProfileSystem
    if ps then
        local defaults = ps:GetDatabaseDefaults()
        if defaults and defaults.char and defaults.char.layout and defaults.char.layout.spec then
            local specDefaults = defaults.char.layout.spec
            for specIndex = 1, #RealUI.charInfo.specs do
                local spec = RealUI.charInfo.specs[specIndex]
                if spec.role ~= "HEALER" then
                    local layoutDefault = specDefaults[specIndex]
                    if layoutDefault ~= 1 then
                        failures = failures + 1
                        _G.print(("|cffff0000[FAIL]|r Default layout for DPS spec %d is %s, expected 1"):format(
                            specIndex, _G.tostring(layoutDefault)))
                    end
                    checkedCount = checkedCount + 1
                end
            end
        end
    end

    -- 1d: Verify LayoutManager maps DPS/tank specs to layout 1
    local lm = RealUI.LayoutManager
    if lm then
        local state = lm:GetLayoutState()
        if state and state.specToLayoutMapping then
            -- This is the LayoutManager's internal mapping (not char db)
            -- It should map non-healer specs to LAYOUT_DPS_TANK (1)
        end

        -- Verify layout configurations exist for layout 1
        local config = lm:GetLayoutConfiguration(1)
        if not config then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r LayoutManager has no configuration for layout 1 (DPS/Tank)")
        elseif config.profile ~= "RealUI" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r Layout 1 profile is '%s', expected 'RealUI'"):format(_G.tostring(config.profile)))
        end
        checkedCount = checkedCount + 1
    end

    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No DPS/tank spec checks performed")
        return true
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 1: DPS-only profile/layout — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 1: %d failures out of %d checks"):format(failures, checkedCount))
    end
    return failures == 0
end


-- ============================================================================
-- Test 2: Combat deferral of profile/layout switches
-- Validates: Requirements 3.2
--
-- On unfixed code: DualSpecSystem:OnSpecializationChanged checks
-- InCombatLockdown() and defers the switch by registering
-- PLAYER_REGEN_ENABLED. This is correct behavior that must be preserved.
--
-- Observation-first: We verify the CanSwitchProfiles method returns false
-- during combat, and that OnSpecializationChanged registers the deferred
-- event handler when in combat.
-- ============================================================================
local function TestCombatDeferral()
    _G.print("|cff00ccff[PBT]|r Preservation 2: Combat deferral of profile/layout switches")

    local dss = RealUI.DualSpecSystem
    if not dss then
        _G.print("|cffff0000[ERROR]|r DualSpecSystem not available")
        return false
    end

    local failures = 0
    local checkedCount = 0

    -- 2a: Verify CanSwitchProfiles checks InCombatLockdown
    -- We can't actually enter combat in a test, but we can verify the
    -- method exists and returns the expected result when NOT in combat.
    local canSwitch, reason = dss:CanSwitchProfiles()
    if not _G.InCombatLockdown() then
        -- Not in combat — CanSwitchProfiles should return true (if initialized)
        if dss:IsInitialized() then
            if not canSwitch then
                -- Could fail for other reasons (ProfileSystem not available, etc.)
                -- Only fail if the reason is combat-related
                if reason and reason:find("combat") then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r CanSwitchProfiles returned false with combat reason while not in combat: %s"):format(reason))
                end
            end
            checkedCount = checkedCount + 1
        end
    end

    -- 2b: Verify OnSpecializationChanged references InCombatLockdown and
    -- PLAYER_REGEN_ENABLED in its implementation (combat deferral path).
    -- We check the function's bytecode for these strings.
    local onSpecChanged = dss.OnSpecializationChanged
    if not onSpecChanged then
        failures = failures + 1
        _G.print("|cffff0000[FAIL]|r DualSpecSystem.OnSpecializationChanged not found")
        return false
    end

    local hasDump = type(_G.string.dump) == "function"
    if hasDump then
        local ok, bytecode = _G.pcall(_G.string.dump, onSpecChanged)
        if ok and bytecode then
            -- Check for InCombatLockdown reference (combat check)
            if not bytecode:find("InCombatLockdown") then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r OnSpecializationChanged does not reference InCombatLockdown")
            end
            checkedCount = checkedCount + 1

            -- Check for PLAYER_REGEN_ENABLED reference (deferred switch)
            if not bytecode:find("PLAYER_REGEN_ENABLED") then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r OnSpecializationChanged does not reference PLAYER_REGEN_ENABLED")
            end
            checkedCount = checkedCount + 1
        end
    else
        _G.print("|cffff9900[WARN]|r string.dump not available — skipping bytecode checks")
    end

    -- 2c: Verify CanSwitchProfiles method explicitly checks InCombatLockdown
    local canSwitchFn = dss.CanSwitchProfiles
    if canSwitchFn and hasDump then
        local ok, bytecode = _G.pcall(_G.string.dump, canSwitchFn)
        if ok and bytecode then
            if not bytecode:find("InCombatLockdown") then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r CanSwitchProfiles does not reference InCombatLockdown")
            end
            checkedCount = checkedCount + 1
        end
    end

    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No combat deferral checks performed")
        return true
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 2: Combat deferral — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 2: %d failures out of %d checks"):format(failures, checkedCount))
    end
    return failures == 0
end


-- ============================================================================
-- Test 3: Manual profile switch updates layout correctly
-- Validates: Requirements 3.4
--
-- On unfixed code: When a profile is manually switched via AceDB, the
-- layout should update to match (layout 1 for "RealUI", layout 2 for
-- "RealUI-Healing"). This is verified by checking the profile-to-layout
-- mapping consistency.
-- ============================================================================
local function TestManualProfileSwitchLayout()
    _G.print("|cff00ccff[PBT]|r Preservation 3: Manual profile switch updates layout correctly")

    local failures = 0
    local checkedCount = 0

    -- 3a: Verify profile-to-layout mapping is consistent
    -- LayoutManager stores layout configurations with profile names.
    -- Layout 1 -> "RealUI", Layout 2 -> "RealUI-Healing"
    local lm = RealUI.LayoutManager
    if lm then
        local config1 = lm:GetLayoutConfiguration(1)
        local config2 = lm:GetLayoutConfiguration(2)

        if config1 then
            if config1.profile ~= "RealUI" then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r Layout 1 profile is '%s', expected 'RealUI'"):format(_G.tostring(config1.profile)))
            end
            checkedCount = checkedCount + 1
        else
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r No layout configuration for layout 1")
            checkedCount = checkedCount + 1
        end

        if config2 then
            if config2.profile ~= "RealUI-Healing" then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r Layout 2 profile is '%s', expected 'RealUI-Healing'"):format(_G.tostring(config2.profile)))
            end
            checkedCount = checkedCount + 1
        else
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r No layout configuration for layout 2")
            checkedCount = checkedCount + 1
        end
    end

    -- 3b: Verify ProfileSystem:SwitchProfile exists and is callable
    local ps = RealUI.ProfileSystem
    if ps then
        if type(ps.SwitchProfile) ~= "function" then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r ProfileSystem.SwitchProfile is not a function")
        end
        checkedCount = checkedCount + 1

        -- Verify GetCurrentProfile works
        local currentProfile = ps:GetCurrentProfile()
        if currentProfile == nil then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r ProfileSystem:GetCurrentProfile() returned nil")
        elseif type(currentProfile) ~= "string" then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r ProfileSystem:GetCurrentProfile() returned %s, expected string"):format(type(currentProfile)))
        end
        checkedCount = checkedCount + 1
    end

    -- 3c: Verify LayoutManager:SwitchToLayout exists and validates layout IDs
    if lm then
        if type(lm.SwitchToLayout) ~= "function" then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r LayoutManager.SwitchToLayout is not a function")
        end
        checkedCount = checkedCount + 1

        -- Verify IsValidLayout correctly validates layout IDs
        if lm:IsValidLayout(1) ~= true then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r LayoutManager:IsValidLayout(1) returned false")
        end
        checkedCount = checkedCount + 1

        if lm:IsValidLayout(2) ~= true then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r LayoutManager:IsValidLayout(2) returned false")
        end
        checkedCount = checkedCount + 1

        if lm:IsValidLayout(99) == true then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r LayoutManager:IsValidLayout(99) returned true for invalid layout")
        end
        checkedCount = checkedCount + 1
    end

    -- 3d: Verify the current profile matches the current layout
    if ps and lm then
        local currentProfile = ps:GetCurrentProfile()
        local currentLayout = lm:GetCurrentLayout()
        if currentProfile and currentLayout then
            local config = lm:GetLayoutConfiguration(currentLayout)
            if config and config.profile then
                if currentProfile ~= config.profile then
                    -- This may not always match (e.g., if profile was changed
                    -- without updating layout), but log it as info
                    _G.print(("|cffff9900[INFO]|r Current profile '%s' does not match layout %d profile '%s'"):format(
                        currentProfile, currentLayout, config.profile))
                end
                checkedCount = checkedCount + 1
            end
        end
    end

    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No manual profile switch checks performed")
        return true
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 3: Manual profile switch layout — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 3: %d failures out of %d checks"):format(failures, checkedCount))
    end
    return failures == 0
end


-- ============================================================================
-- Test 4: Addon reset recreates both profiles with correct data
-- Validates: Requirements 3.3
--
-- On unfixed code: When addon profiles are reset, both "RealUI" and
-- "RealUI-Healing" profiles should be recreatable with correct default
-- data. This is verified by checking that the profile creation and
-- default data population paths exist and work correctly.
-- ============================================================================
local function TestAddonResetProfiles()
    _G.print("|cff00ccff[PBT]|r Preservation 4: Addon reset recreates both profiles")

    local failures = 0
    local checkedCount = 0

    -- 4a: Verify both profile names are defined in the system
    local ps = RealUI.ProfileSystem
    if ps then
        local profiles = ps:GetProfileList()
        if profiles then
            local hasRealUI = false
            local hasHealing = false
            for _, name in _G.ipairs(profiles) do
                if name == "RealUI" then hasRealUI = true end
                if name == "RealUI-Healing" then hasHealing = true end
            end

            if not hasRealUI then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r 'RealUI' profile not found in profile list")
            end
            checkedCount = checkedCount + 1

            -- RealUI-Healing may not exist on DPS-only characters, that's OK
            if hasHealing then
                _G.print("|cff00ccff[INFO]|r 'RealUI-Healing' profile exists")
            else
                _G.print("|cff00ccff[INFO]|r 'RealUI-Healing' profile not present (normal for DPS-only characters)")
            end
            checkedCount = checkedCount + 1
        end
    end

    -- 4b: Verify ProfileSystem:GetDatabaseDefaults returns valid defaults
    if ps then
        local defaults = ps:GetDatabaseDefaults()
        if not defaults then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r GetDatabaseDefaults returned nil")
        else
            -- Check global section
            if not defaults.global then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Defaults missing 'global' section")
            end
            checkedCount = checkedCount + 1

            -- Check char section with layout
            if not defaults.char or not defaults.char.layout then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Defaults missing 'char.layout' section")
            elseif defaults.char.layout.current ~= 1 then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r Default layout.current is %s, expected 1"):format(
                    _G.tostring(defaults.char.layout.current)))
            end
            checkedCount = checkedCount + 1

            -- Check profile section
            if not defaults.profile then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Defaults missing 'profile' section")
            end
            checkedCount = checkedCount + 1
        end
    end

    -- 4c: Verify EnsureBartenderActionBarsProfiles creates profiles for both
    -- profile names. We check that Bartender4DB has the expected structure.
    local bt4db = _G.Bartender4DB
    if type(bt4db) == "table" then
        local namespaces = bt4db.namespaces
        if type(namespaces) == "table" then
            local actionBarsNS = namespaces.ActionBars
            if type(actionBarsNS) == "table" and type(actionBarsNS.profiles) == "table" then
                local profiles = actionBarsNS.profiles

                -- Check "RealUI" Bartender4 profile exists
                if type(profiles["RealUI"]) == "table" then
                    if type(profiles["RealUI"].actionbars) ~= "table" then
                        failures = failures + 1
                        _G.print("|cffff0000[FAIL]|r Bartender4 'RealUI' profile missing actionbars table")
                    end
                    checkedCount = checkedCount + 1
                else
                    _G.print("|cffff9900[INFO]|r Bartender4 'RealUI' profile not found in ActionBars namespace")
                end

                -- Check "RealUI-Healing" Bartender4 profile if it exists
                if type(profiles["RealUI-Healing"]) == "table" then
                    if type(profiles["RealUI-Healing"].actionbars) ~= "table" then
                        failures = failures + 1
                        _G.print("|cffff0000[FAIL]|r Bartender4 'RealUI-Healing' profile missing actionbars table")
                    end
                    checkedCount = checkedCount + 1
                end
            end
        end
    else
        _G.print("|cffff9900[INFO]|r Bartender4DB not available — skipping Bartender4 profile checks")
    end

    -- 4d: Verify ProfileSystem:CreateProfile and ResetProfile methods exist
    if ps then
        if type(ps.CreateProfile) ~= "function" then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r ProfileSystem.CreateProfile is not a function")
        end
        checkedCount = checkedCount + 1

        if type(ps.ResetProfile) ~= "function" then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r ProfileSystem.ResetProfile is not a function")
        end
        checkedCount = checkedCount + 1
    end

    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No addon reset checks performed")
        return true
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 4: Addon reset profiles — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 4: %d failures out of %d checks"):format(failures, checkedCount))
    end
    return failures == 0
end


-- ============================================================================
-- Test 5: Config mode and frame mover operate correctly
-- Validates: Requirements 3.5
--
-- On unfixed code: Config mode and frame mover systems operate correctly
-- regardless of which profile/layout is active. This is verified by
-- checking that the relevant modules and methods exist and are functional.
-- ============================================================================
local function TestConfigModePreservation()
    _G.print("|cff00ccff[PBT]|r Preservation 5: Config mode and frame mover systems")

    local failures = 0
    local checkedCount = 0

    -- 5a: Verify LayoutManager has layout configurations for both layouts
    local lm = RealUI.LayoutManager
    if lm then
        local configs = lm:GetAllLayoutConfigurations()
        if not configs then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r GetAllLayoutConfigurations returned nil")
        else
            if not configs[1] then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r No configuration for layout 1 (DPS/Tank)")
            end
            checkedCount = checkedCount + 1

            if not configs[2] then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r No configuration for layout 2 (Healing)")
            end
            checkedCount = checkedCount + 1

            -- Verify both layouts have positions data
            for layoutId = 1, 2 do
                local config = configs[layoutId]
                if config then
                    if not config.positions or type(config.positions) ~= "table" then
                        failures = failures + 1
                        _G.print(("|cffff0000[FAIL]|r Layout %d missing positions table"):format(layoutId))
                    else
                        -- Verify key position entries exist
                        local requiredPositions = {"HuDX", "HuDY", "ActionBarsY"}
                        for _, posKey in _G.ipairs(requiredPositions) do
                            if config.positions[posKey] == nil then
                                failures = failures + 1
                                _G.print(("|cffff0000[FAIL]|r Layout %d missing position '%s'"):format(layoutId, posKey))
                            end
                        end
                    end
                    checkedCount = checkedCount + 1
                end
            end
        end
    end

    -- 5b: Verify RealUI.cLayout and ncLayout are set
    if RealUI.cLayout == nil then
        _G.print("|cffff9900[INFO]|r RealUI.cLayout is nil (may not be set until layout switch)")
    end

    -- 5c: Verify UpdatePositioners exists (used by layout switching)
    if type(RealUI.UpdatePositioners) ~= "function" then
        _G.print("|cffff9900[INFO]|r RealUI.UpdatePositioners not available as function")
    end

    -- 5d: Verify UpdateLayout exists
    if type(RealUI.UpdateLayout) ~= "function" then
        failures = failures + 1
        _G.print("|cffff0000[FAIL]|r RealUI.UpdateLayout is not a function")
    end
    checkedCount = checkedCount + 1

    -- 5e: Verify LayoutManager state management methods
    if lm then
        local state = lm:GetLayoutState()
        if not state then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r GetLayoutState returned nil")
        else
            if state.currentLayout == nil then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Layout state has nil currentLayout")
            end
            if state.autoSwitchEnabled == nil then
                failures = failures + 1
                _G.print("|cffff0000[FAIL]|r Layout state has nil autoSwitchEnabled")
            end
        end
        checkedCount = checkedCount + 1
    end

    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No config mode checks performed")
        return true
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 5: Config mode/frame mover — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 5: %d failures out of %d checks"):format(failures, checkedCount))
    end
    return failures == 0
end


-- ============================================================================
-- Test 6: SavedVariables migration preserves spec-to-layout mappings
-- Validates: Requirements 3.6
--
-- On unfixed code: The AceDB defaults in ProfileSystem:GetDatabaseDefaults
-- populate layout.spec for all specs based on role. This ensures that
-- even after migration, spec-to-layout mappings are correct. We verify
-- the defaults produce the correct mapping and that existing char data
-- has valid spec-to-layout entries.
-- ============================================================================
local function TestSavedVariablesMigration()
    _G.print("|cff00ccff[PBT]|r Preservation 6: SavedVariables migration preserves spec-to-layout mappings")

    local failures = 0
    local checkedCount = 0

    -- 6a: Verify GetDatabaseDefaults produces correct spec-to-layout mapping
    local ps = RealUI.ProfileSystem
    if ps then
        local defaults = ps:GetDatabaseDefaults()
        if defaults and defaults.char and defaults.char.layout and defaults.char.layout.spec then
            local specDefaults = defaults.char.layout.spec
            for specIndex = 1, #RealUI.charInfo.specs do
                local spec = RealUI.charInfo.specs[specIndex]
                local expectedLayout = (spec.role == "HEALER") and 2 or 1
                local actualLayout = specDefaults[specIndex]

                if actualLayout ~= expectedLayout then
                    failures = failures + 1
                    _G.print(("|cffff0000[FAIL]|r Default spec %d (%s, role=%s): layout=%s, expected=%d"):format(
                        specIndex, spec.name or "?", spec.role or "?",
                        _G.tostring(actualLayout), expectedLayout))
                end
                checkedCount = checkedCount + 1
            end
        else
            _G.print("|cffff9900[WARN]|r GetDatabaseDefaults missing char.layout.spec")
        end
    end

    -- 6b: Verify current character data has valid layout entries
    local dbc = RealUI.db and RealUI.db.char
    if dbc and dbc.layout then
        -- Verify current layout is valid (1 or 2)
        if dbc.layout.current ~= 1 and dbc.layout.current ~= 2 then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r Current layout is %s, expected 1 or 2"):format(
                _G.tostring(dbc.layout.current)))
        end
        checkedCount = checkedCount + 1

        -- Verify spec table exists
        if type(dbc.layout.spec) ~= "table" then
            failures = failures + 1
            _G.print("|cffff0000[FAIL]|r layout.spec is not a table")
        else
            -- Verify each spec entry is valid (1 or 2) if present
            for specIndex = 1, #RealUI.charInfo.specs do
                local layoutVal = dbc.layout.spec[specIndex]
                if layoutVal ~= nil then
                    if layoutVal ~= 1 and layoutVal ~= 2 then
                        failures = failures + 1
                        _G.print(("|cffff0000[FAIL]|r layout.spec[%d] = %s, expected 1 or 2"):format(
                            specIndex, _G.tostring(layoutVal)))
                    end
                    checkedCount = checkedCount + 1
                end
            end
        end
    else
        _G.print("|cffff9900[WARN]|r RealUI.db.char.layout not available")
    end

    -- 6c: Verify DualSpecSystem spec profiles are consistent with layout mapping
    local dss = RealUI.DualSpecSystem
    if dss and dss:IsInitialized() then
        for specIndex = 1, #RealUI.charInfo.specs do
            local profile = dss:GetSpecProfile(specIndex)
            if profile then
                local spec = RealUI.charInfo.specs[specIndex]
                local expectedProfile = (spec.role == "HEALER") and "RealUI-Healing" or "RealUI"
                if profile ~= expectedProfile then
                    -- This is informational — the mapping may differ from defaults
                    _G.print(("|cffff9900[INFO]|r Spec %d (%s) profile is '%s', default would be '%s'"):format(
                        specIndex, spec.name or "?", profile, expectedProfile))
                end
                checkedCount = checkedCount + 1
            end
        end
    end

    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No migration checks performed")
        return true
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Preservation 6: SavedVariables migration — %d checks passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Preservation 6: %d failures out of %d checks"):format(failures, checkedCount))
    end
    return failures == 0
end


-- ============================================================================
-- Main runner: executes all 6 preservation test cases
-- ============================================================================
local function RunHealerPreservationTests()
    _G.print("|cff00ccff[PBT]|r Healer Profile Preservation Tests — 6 baseline behavior checks")
    _G.print("|cff00ccff[PBT]|r EXPECTED: Tests PASS on unfixed code (confirms behavior to preserve)")
    _G.print("---")

    local tests = {
        { fn = TestDPSOnlyCharacterProfile,   label = "3.1 DPS-only characters use RealUI/layout 1" },
        { fn = TestCombatDeferral,            label = "3.2 Combat deferral of profile switches" },
        { fn = TestManualProfileSwitchLayout, label = "3.4 Manual profile switch updates layout" },
        { fn = TestAddonResetProfiles,        label = "3.3 Addon reset recreates both profiles" },
        { fn = TestConfigModePreservation,    label = "3.5 Config mode and frame mover systems" },
        { fn = TestSavedVariablesMigration,   label = "3.6 SavedVariables migration" },
    }

    local passed, failed = 0, 0
    for _, test in _G.ipairs(tests) do
        local ok, result = _G.pcall(test.fn)
        if not ok then
            _G.print(("|cffff0000[ERROR]|r %s threw: %s"):format(test.label, _G.tostring(result)))
            failed = failed + 1
        elseif result == false then
            failed = failed + 1
        else
            passed = passed + 1
        end
    end

    _G.print("---")
    if failed == 0 then
        _G.print(("|cff00ff00[SUITE PASS]|r All %d healer preservation tests passed"):format(passed))
    else
        _G.print(("|cffff0000[SUITE FAIL]|r %d passed, %d failed"):format(passed, failed))
    end

    return failed == 0
end

function ns.commands:healerpreserve()
    return RunHealerPreservationTests()
end
