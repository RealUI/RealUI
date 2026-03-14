local ADDON_NAME, ns = ... -- luacheck: ignore

-- Feature: realui-config-overhaul, Property 5: Pixel Perfect disables custom scale input
-- Validates: Requirements 6.4
--
-- For any SkinsDB profile state where isPixelScale is true, the customScale
-- control's disabled callback should return true. When isPixelScale is false,
-- the disabled callback should return false (or falsy).

local ITERATIONS = 100

---------------------------------------------------------------------------
-- Helpers
---------------------------------------------------------------------------

-- Minimal PRNG (xorshift32) so we don't depend on math.random seed state
local rngState = (_G.GetTime and math.floor(_G.GetTime() * 1000) or 12345) + 99887
local function xorshift()
    local x = rngState
    x = bit.bxor(x, bit.lshift(x, 13))
    x = bit.bxor(x, bit.rshift(x, 17))
    x = bit.bxor(x, bit.lshift(x, 5))
    if x < 0 then x = x + 0x100000000 end
    rngState = x
    return x
end

local function randomBool()
    return xorshift() % 2 == 1
end

---------------------------------------------------------------------------
-- Property test runner
---------------------------------------------------------------------------
local function RunPixelPerfectScaleTest()
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

    local customScaleEntry = skinsSection.args.customScale
    if not customScaleEntry then
        return 0, 1, "customScale control not found in Skins options"
    end

    local disabledCb = customScaleEntry.disabled
    if not disabledCb or type(disabledCb) ~= "function" then
        return 0, 1, "customScale.disabled is not a function"
    end

    -- Get SkinsDB handle
    local RealUI = _G.RealUI
    local SkinsDB = RealUI and RealUI.GetOptions and RealUI.GetOptions("Skins")
    if not SkinsDB or not SkinsDB.profile then
        return 0, 1, "Could not access SkinsDB.profile"
    end

    -- Save original state
    local originalIsPixelScale = SkinsDB.profile.isPixelScale

    local passed, failed = 0, 0
    local firstFailure = nil

    for i = 1, ITERATIONS do
        rngState = rngState + i
        local testVal = randomBool()

        -- Set isPixelScale to the random boolean
        SkinsDB.profile.isPixelScale = testVal

        -- Exercise the disabled callback
        local ok, result = pcall(disabledCb)
        if not ok then
            failed = failed + 1
            if not firstFailure then
                firstFailure = ("Iter %d: disabled callback threw error: %s"):format(i, tostring(result))
            end
        else
            -- When isPixelScale is true, disabled should return truthy
            -- When isPixelScale is false, disabled should return falsy
            if testVal then
                if result then
                    passed = passed + 1
                else
                    failed = failed + 1
                    if not firstFailure then
                        firstFailure = ("Iter %d: isPixelScale=true but disabled returned %s (expected truthy)"):format(
                            i, tostring(result))
                    end
                end
            else
                if not result then
                    passed = passed + 1
                else
                    failed = failed + 1
                    if not firstFailure then
                        firstFailure = ("Iter %d: isPixelScale=false but disabled returned %s (expected falsy)"):format(
                            i, tostring(result))
                    end
                end
            end
        end
    end

    -- Restore original state
    SkinsDB.profile.isPixelScale = originalIsPixelScale

    return passed, failed, firstFailure
end


---------------------------------------------------------------------------
-- Slash command entry point: /realdev pixelperfectscale
---------------------------------------------------------------------------
function ns.commands:pixelperfectscale()
    _G.print("|cff00ccff[Pixel Perfect Scale]|r Running property test (" .. ITERATIONS .. " iterations)...")

    local ok, passed, failed, firstFailure = pcall(RunPixelPerfectScaleTest)
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
        _G.print("|cff00ff00[PASS]|r Pixel Perfect disables custom scale input verified")
        return true
    end
end
