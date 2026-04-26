local _, private = ...

-- Lua Globals --
-- luacheck: globals next type

-- RealUI --
local RealUI = private.RealUI
--local debug = RealUI.GetDebug("MiniPatch")

-- Version map for patch-level minipatches.
-- Each entry is {major, minor, patch} and is applied when:
--   oldVersion < patchVersion <= currentVersion
RealUI.minipatchVersions = {
    [1] = {3, 0, 1},
    [2] = {3, 1, 7},
    [3] = {3, 1, 17},
}

RealUI.minipatches = {
    -- Major version transition: 2.5.x → 3.0.0
    -- Handles nibRealUI → RealUI rename migration and deprecated 2.x data cleanup
    [0] = function()
        local dbg = RealUI.db.global

        -- Clean up deprecated 2.x data structures from nibRealUIDB
        if _G.nibRealUIDB then
            -- Remove old module settings that no longer exist in 3.x
            if _G.nibRealUIDB.namespaces then
                _G.nibRealUIDB.namespaces["FrameMover"] = nil
                _G.nibRealUIDB.namespaces["AchievementScreenshots"] = nil
                _G.nibRealUIDB.namespaces["CurrencyTip"] = nil
            end

            -- Migrate renamed profile keys (nibRealUI → RealUI)
            if _G.nibRealUIDB.profileKeys then
                for char, profile in next, _G.nibRealUIDB.profileKeys do
                    if type(profile) == "string" then
                        _G.nibRealUIDB.profileKeys[char] = profile:gsub("^nibRealUI", "RealUI")
                    end
                end
            end

            -- Clean up deprecated global settings from 2.x
            if _G.nibRealUIDB.global then
                _G.nibRealUIDB.global.screenSize = nil
                _G.nibRealUIDB.global.patch = nil
            end
        end

        -- If the account was already configured in 2.x, mark firsttime as false
        -- so the install wizard doesn't re-run global setup steps
        if dbg and dbg.tags then
            if _G.nibRealUIDB or (dbg.verinfo and dbg.verinfo[1]) then
                dbg.tags.firsttime = false
            end
        end

        -- Set patchedTOC to current value so TOC-based minipatches don't re-trigger
        if dbg and RealUI.TOC then
            dbg.patchedTOC = RealUI.TOC
        end
    end,

    [1] = function()
        if not (_G.nibRealUIDB and _G.nibRealUIDB.profiles) then
            return
        end
        for _, profile in next, _G.nibRealUIDB.profiles do
            local units = profile and profile.units
            if units then
                for _, unitInfo in next, units do
                    if type(unitInfo) == "table" and unitInfo.reverseMissing ~= nil then
                        unitInfo.reverseMissing = nil
                    end
                end
            end
        end
    end,

    -- 3.1.7 safety patch: force resource/performance monitoring off by default
    -- for all existing profiles. Users can still manually re-enable it.
    [2] = function()
        if not RealUI.db then
            return
        end

        local db = RealUI.db
        local dbg = db.global

        if type(db.profiles) == "table" then
            for _, profileData in next, db.profiles do
                if type(profileData) == "table" then
                    profileData.settings = profileData.settings or {}
                    profileData.settings.performanceMonitorEnabled = false
                end
            end
        end

        if db.profile then
            db.profile.settings = db.profile.settings or {}
            db.profile.settings.performanceMonitorEnabled = false
        end

        if dbg then
            dbg.resourceMonitor317DefaultApplied = true
        end
    end,

    -- 3.1.17 migration: disable Blizzard floating combat text by default
    -- for existing users so RealUI combat text does not duplicate Blizzard output.
    [3] = function()
        local combatTextDB = _G.RealUI_CombatTextDB
        if type(combatTextDB) ~= "table" then
            return
        end

        combatTextDB.global = combatTextDB.global or {}
        combatTextDB.global.blizzardFCT = combatTextDB.global.blizzardFCT or {}
        combatTextDB.global.blizzardFCT.enableFloatingCombatText = false

        -- Keep CVar aligned immediately; UI reload follows minipatch acceptance.
        _G.SetCVar("enableFloatingCombatText", "0")
    end,
}
