local _, private = ...

-- Lua Globals --
-- luacheck: globals next

-- RealUI --
local RealUI = private.RealUI
--local debug = RealUI.GetDebug("MiniPatch")

RealUI.minipatches = {
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
}
