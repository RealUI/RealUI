local _, private = ...

-- Lua Globals --
-- luacheck: globals

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("MiniPatch")

RealUI.minipatches = {
    [0] = function(ver)
        debug("patch"..ver)
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
    [99] = function(ver) -- test patch
        debug("patch"..ver)
    end,
}
