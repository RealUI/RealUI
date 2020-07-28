local _, private = ...

-- Lua Globals --
-- luacheck: globals next

-- RealUI --
local RealUI = private.RealUI
--local debug = RealUI.GetDebug("MiniPatch")

RealUI.minipatches = {
    --[[
    [1] = function()
        debug("patch 1")
        for profileName, profile in next, _G.nibRealUIDB.profiles do
            local settings = profile.settings
            -- This setting was doing the opposite of what it should, so hopefully
            -- reversing it will make the change transparent to most users.
            if settings and settings.reverseUnitFrameBars == nil then
                settings.reverseUnitFrameBars = not settings.reverseUnitFrameBars
            end
        end
    end,
    [0] = function()
        debug("patch 0")
        for profileName, profile in next, _G.nibRealUIDB.profiles do
        end
    end,
    ]]
}
