local _, private = ...

-- Lua Globals --
-- luacheck: globals

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("MiniPatch")

RealUI.minipatches = {
    [0] = function()
        debug("patch 0")
        local profile = _G.nibRealUIDB.profiles.RealUI
        if profile.media and profile.media.font then
            profile.media.font = nil
        end

        if _G.nibRealUIDB.global.retinaDisplay then
            _G.nibRealUIDB.global.retinaDisplay = nil
        end

        if _G.nibRealUIDB.namespaces.UIScaler then
            _G.nibRealUIDB.namespaces.UIScaler = nil
        end
    end,
    [99] = function() -- test patch
        debug("patch 99")
    end,
}
