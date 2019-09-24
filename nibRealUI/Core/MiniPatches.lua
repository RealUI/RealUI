local _, private = ...

-- Lua Globals --
-- luacheck: globals next

-- RealUI --
local RealUI = private.RealUI
local debug = RealUI.GetDebug("MiniPatch")

RealUI.minipatches = {
    [99] = function() -- test patch
        debug("patch 99")
    end,
}
