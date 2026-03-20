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

    -- Minipatches [2] through [9]: reserved for 3.0.0 → 3.0.9 incremental data migrations.
    -- Each entry corresponds to a patch version (3.0.2 through 3.0.9).
    -- Populate with migration logic as needed when a patch version introduces data changes.
    [2] = function() end,
    [3] = function() end,
    [4] = function() end,
    [5] = function() end,
    [6] = function() end,
    [7] = function() end,
    [8] = function() end,
    [9] = function() end,
}
