local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: Class color config propagation
-- Feature: hud-rewrite, Property 3: Class color config propagation
-- Validates: Requirements 3.2, 3.3, 3.5
--
-- For any boolean classColor config value, after RefreshUnits, every unit
-- frame's Health.colorClass equals the config value and Health.colorHealth
-- equals the inverse.

local RealUI = _G.RealUI

local units = {
    "Player",
    "Target",
    "Focus",
    "FocusTarget",
    "Pet",
    "TargetTarget",
}

local function RunClassColorConfigTest()
    local UnitFrames = RealUI:GetModule("UnitFrames")
    if not UnitFrames then
        _G.print("|cffff0000[ERROR]|r UnitFrames module not available.")
        return false
    end

    if not UnitFrames.db then
        _G.print("|cffff0000[ERROR]|r UnitFrames.db not available.")
        return false
    end

    _G.print("|cff00ccff[PBT]|r Class color config propagation — testing both true and false")

    -- Diagnostic: check which frames exist
    for _, unitName in _G.ipairs(units) do
        local frameName = "RealUI" .. unitName .. "Frame"
        local frame = _G[frameName]
        if frame then
            _G.print(("  %s exists, Health=%s"):format(frameName, _G.tostring(frame.Health)))
        else
            _G.print(("  %s = nil"):format(frameName))
        end
    end

    -- Check if UnitFrames module is enabled
    _G.print(("  UnitFrames enabled: %s"):format(_G.tostring(UnitFrames:IsEnabled())))

    local failures = 0

    for _, classColor in _G.ipairs({true, false}) do
        -- Set the config value
        UnitFrames.db.profile.overlay.classColor = classColor

        -- Call RefreshUnits to propagate
        UnitFrames:RefreshUnits("test")

        -- Check every spawned unit frame
        for _, unitName in _G.ipairs(units) do
            local frame = _G["RealUI" .. unitName .. "Frame"]
            if frame and frame.Health then
                -- Verify Health.colorClass equals the config value
                if frame.Health.colorClass ~= classColor then
                    failures = failures + 1
                    _G.print(
                        ("|cffff0000[FAIL]|r classColor=%s unit=%s Health.colorClass expected=%s got=%s"):format(
                            _G.tostring(classColor), unitName,
                            _G.tostring(classColor), _G.tostring(frame.Health.colorClass)
                        )
                    )
                end

                -- Verify Health.colorHealth equals the inverse
                local expectedColorHealth = not classColor
                if frame.Health.colorHealth ~= expectedColorHealth then
                    failures = failures + 1
                    _G.print(
                        ("|cffff0000[FAIL]|r classColor=%s unit=%s Health.colorHealth expected=%s got=%s"):format(
                            _G.tostring(classColor), unitName,
                            _G.tostring(expectedColorHealth), _G.tostring(frame.Health.colorHealth)
                        )
                    )
                end
            end
            -- Skip nil frames gracefully (e.g., pet frame when no pet is active)
        end
    end

    -- Count how many frames were actually checked
    local checkedCount = 0
    for _, unitName in _G.ipairs(units) do
        local frame = _G["RealUI" .. unitName .. "Frame"]
        if frame and frame.Health then
            checkedCount = checkedCount + 1
        end
    end

    if checkedCount == 0 then
        _G.print("|cffff9900[WARN]|r No unit frames with Health element found — test inconclusive")
        return false
    end

    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r Property 3: Class color config propagation — %d frames checked, both true/false passed"):format(checkedCount))
    else
        _G.print(("|cffff0000[FAIL]|r Property 3: Class color config propagation — %d failures across %d frames"):format(failures, checkedCount))
    end

    return failures == 0
end

function ns.commands:classcolor()
    return RunClassColorConfigTest()
end
