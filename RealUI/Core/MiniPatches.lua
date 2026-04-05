local _, private = ...

-- Lua Globals --
-- luacheck: globals next type

-- RealUI --
local RealUI = private.RealUI
--local debug = RealUI.GetDebug("MiniPatch")

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

    -- Minipatches [2] through [6]: reserved for incremental data migrations.
    [2] = function() end,
    [3] = function() end,
    [4] = function() end,
    [5] = function() end,
    [6] = function() end,

    -- 3.1.7 safety patch: force resource/performance monitoring off by default
    -- for all existing profiles. Users can still manually re-enable it.
    [7] = function()
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

    -- Minipatches [8] and [9]: reserved for future patch-level migrations.
    [8] = function() end,
    [9] = function() end,
}
