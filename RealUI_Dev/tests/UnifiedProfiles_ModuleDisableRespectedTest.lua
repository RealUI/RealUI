local ADDON_NAME, ns = ... -- luacheck: ignore

-- Property Test: the profile cascade restores modules without overriding the user
-- Feature: B54 — cast bars could not be disabled (docs/4.0-Beta-Feedback.md)
--
-- RealUI:OnProfileUpdate snapshots db.profile.modules before pushing profiles to
-- third-party addons, then restores anything the cascade cleared.  The property
-- has two directions and both must hold for *every* module -- there are no
-- per-module special cases:
--
--   A. User-disabled stays disabled.  A module whose flag is already false
--      before the cascade must still be false afterwards.  A blanket
--      "always re-enable X" guard breaks this, which is what made CastBars
--      impossible to turn off.
--
--   B. Cascade-cleared gets restored.  A module whose flag was true before the
--      cascade but which the cascade set to false must be back to true.  This
--      is the CastBars-disabled-on-healer-login regression the guard was
--      originally added for.
--
-- The restore block only runs once the install wizard has finished
-- (installStage == -1), so the mock char data below uses that value.

local NUM_ITERATIONS = 100

-- Simple RNG (xorshift32)
local rngState = 20260819
local function nextRandom(max)
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 13))
    rngState = _G.bit.bxor(rngState, _G.bit.rshift(rngState, 17))
    rngState = _G.bit.bxor(rngState, _G.bit.lshift(rngState, 5))
    if rngState < 0 then rngState = rngState + 0x7FFFFFFF end
    return (rngState % max) + 1
end

-- OnProfileReset reassigns RealUI.db.char.init from an upvalue and prompts a
-- reload; it is covered by its own tests.  The restore block is identical for
-- the remaining three events, so exercise those.
local PROFILE_EVENTS = { "OnProfileChanged", "OnNewProfile", "OnProfileCopied" }

local PROFILE_NAMES = {
    "RealUI", "RealUI-Healing", "RealUI_PvP", "MyCustom", "Raid", "Solo",
}

-- CastBars is the module the bug was reported against; the others are here to
-- prove the property is general rather than special-cased.
local MODULE_NAMES = {
    "CastBars", "UnitFrames", "ActionBars", "Infobar", "MinimapAdv", "CombatText",
}

local function RunModuleDisableRespectedTest()
    _G.print("|cff00ccff[PBT]|r B54: profile cascade restores modules without overriding the user")
    _G.print("|cff00ccff[PBT]|r Running", NUM_ITERATIONS, "iterations")

    local RealUI = _G.RealUI

    if not RealUI or not RealUI.OnProfileUpdate then
        _G.print("|cffff0000[FAIL]|r RealUI or RealUI.OnProfileUpdate not available")
        return false
    end

    -- Save original state
    local origDB = RealUI.db
    local origCLayout = RealUI.cLayout
    local origNCLayout = RealUI.ncLayout
    local origIterateModules = RealUI.IterateModules
    local origLayoutManager = RealUI.LayoutManager
    local origProfileSystem = RealUI.ProfileSystem
    local origInCombatLockdown = _G.InCombatLockdown
    local origSetAddOnProfileToRealUI = RealUI.SetAddOnProfileToRealUI
    local origUpdateLayout = RealUI.UpdateLayout
    local origGetModule = RealUI.GetModule
    local origReloadUIDialog = RealUI.ReloadUIDialog

    local failures = 0

    for i = 1, NUM_ITERATIONS do
        local event = PROFILE_EVENTS[nextRandom(#PROFILE_EVENTS)]
        local profileName = PROFILE_NAMES[nextRandom(#PROFILE_NAMES)]

        -- Split the module pool: half are user-disabled going in (direction A),
        -- half are enabled and will be cleared by the cascade (direction B).
        local userDisabled, cascadeCleared = {}, {}
        local modules = { ["*"] = true }
        for idx, name in _G.ipairs(MODULE_NAMES) do
            -- Rotate which half each module lands in so CastBars is exercised
            -- in both directions across the run.
            if (idx + i) % 2 == 0 then
                modules[name] = false
                userDisabled[name] = true
            else
                modules[name] = true
                cascadeCleared[name] = true
            end
        end

        local charData = {
            init = { installStage = -1, initialized = true, needchatmoved = false },
            layout = { current = nextRandom(2), spec = {} },
        }
        local profileData = {
            modules = modules,
            positionsLink = false,
            positions = {},
            settings = { hudSize = 2, reverseUnitFrameBars = false, performanceMonitorEnabled = false },
        }
        local globalData = {
            tutorial = { stage = 0 },
            tags = { firsttime = false, lowResOptimized = false, slashRealUITyped = false },
            verinfo = {},
            patchedTOC = 0,
        }

        local mockDatabase = { profile = profileData, char = charData, global = globalData }
        RealUI.db = { profile = profileData, char = charData, global = globalData }

        -- Stand in for the real cascade: pushing the RealUI profile to a
        -- third-party addon is what could clear module flags as a side effect.
        local cascadeRan = false
        RealUI.SetAddOnProfileToRealUI = function()
            cascadeRan = true
            for name in _G.pairs(cascadeCleared) do
                profileData.modules[name] = false
            end
        end

        RealUI.IterateModules = function()
            return function() return nil end
        end
        RealUI.LayoutManager = nil
        RealUI.ProfileSystem = nil
        _G.InCombatLockdown = function() return false end
        RealUI.GetModule = function() return nil end
        RealUI.UpdateLayout = function() end
        RealUI.ReloadUIDialog = function() end

        RealUI:OnProfileUpdate(event, mockDatabase, profileName)

        -- private.Profiles drives the cascade loop.  If it is ever empty the
        -- stub never fires and direction B would pass vacuously, so say so
        -- rather than reporting a green run.
        if not cascadeRan then
            failures = failures + 1
            _G.print(("|cffff0000[FAIL]|r iter %d: cascade never ran (private.Profiles empty?) — direction B is untested"):format(i))
            break
        end

        -- Direction A: user-disabled modules must still be disabled
        for name in _G.pairs(userDisabled) do
            if profileData.modules[name] ~= false then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: '%s' was user-disabled but is %s after %s — a guard is overriding the user"):format(
                    i, name, _G.tostring(profileData.modules[name]), event))
                break
            end
        end

        -- Direction B: cascade-cleared modules must be restored
        for name in _G.pairs(cascadeCleared) do
            if profileData.modules[name] ~= true then
                failures = failures + 1
                _G.print(("|cffff0000[FAIL]|r iter %d: '%s' was enabled, cleared by the cascade, and not restored (is %s) after %s"):format(
                    i, name, _G.tostring(profileData.modules[name]), event))
                break
            end
        end

        if failures >= 5 then break end
    end

    -- Restore original state
    RealUI.IterateModules = origIterateModules
    RealUI.LayoutManager = origLayoutManager
    RealUI.ProfileSystem = origProfileSystem
    _G.InCombatLockdown = origInCombatLockdown
    RealUI.SetAddOnProfileToRealUI = origSetAddOnProfileToRealUI
    RealUI.UpdateLayout = origUpdateLayout
    RealUI.GetModule = origGetModule
    RealUI.ReloadUIDialog = origReloadUIDialog
    RealUI.db = origDB
    RealUI.cLayout = origCLayout
    RealUI.ncLayout = origNCLayout

    _G.print("---")
    if failures == 0 then
        _G.print(("|cff00ff00[PASS]|r B54: cascade restores without overriding the user — %d iterations passed"):format(NUM_ITERATIONS))
    else
        _G.print(("|cffff0000[FAIL]|r B54: cascade restores without overriding the user — %d failures"):format(failures))
    end

    return failures == 0
end

-- Register as /realdev command
function ns.commands:moduledisablerespected()
    return RunModuleDisableRespectedTest()
end
