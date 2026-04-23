local ADDON_NAME, ns = ... -- luacheck: ignore

-- Regression Test: Cast bar tick setup survives secret haste values
-- Validates that SetBarTicks falls back to a neutral haste multiplier when
-- UnitSpellHaste() returns a secret-like value in a tainted execution path.

local RealUI = _G.RealUI

local function RunCastBarSecretHasteTicksTest()
    local CastBars = RealUI:GetModule("CastBars")
    if not CastBars then
        _G.print("|cffff0000[ERROR]|r CastBars module not available.")
        return false
    end

    local castbar = CastBars.player
    if not castbar or not castbar.SetBarTicks or not castbar.tickPool then
        _G.print("|cffff9900[WARN]|r Player castbar not ready — test inconclusive")
        return false
    end

    _G.print("|cff00ccff[TEST]|r Cast bar tick setup with secret-like haste value")

    local secretSentinel = {}
    local originalUnitSpellHaste = _G.UnitSpellHaste
    local originalIsSecretValue = _G.issecretvalue

    _G.UnitSpellHaste = function(unit)
        if unit == "player" then
            return secretSentinel
        end
        return originalUnitSpellHaste(unit)
    end

    _G.issecretvalue = function(value)
        if value == secretSentinel then
            return true
        end
        if originalIsSecretValue then
            return originalIsSecretValue(value)
        end
        return false
    end

    castbar.tickPool:ReleaseAll()
    local ok, err = _G.pcall(function()
        castbar:SetBarTicks({ticks = 1, isInstant = true})
    end)

    _G.UnitSpellHaste = originalUnitSpellHaste
    _G.issecretvalue = originalIsSecretValue

    castbar.tickPool:ReleaseAll()

    if not ok then
        _G.print(("|cffff0000[FAIL]|r SetBarTicks errored with secret-like haste: %s"):format(tostring(err)))
        return false
    end

    _G.print("|cff00ff00[PASS]|r Cast bar tick setup ignores secret-like haste values")
    return true
end

function ns.commands:castbarsecrethaste()
    return RunCastBarSecretHasteTicksTest()
end
