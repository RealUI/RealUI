local _, private = ...

-- Lua Globals --
local _G = _G

-- RealUI --
local RealUI = private.RealUI

RealUI.LoadAddOnData_Aurora = function()
    _G.AuroraConfig = {
        ["useButtonGradientColour"] = false,
        ["chatBubbles"] = false,
        ["bags"] = false,
        ["tooltips"] = false,
        ["loot"] = false,
        ["useCustomColour"] = false,
        ["enableFont"] = false,
        ["buttonSolidColour"] = {
            0.1, -- [1]
            0.1, -- [2]
            0.1, -- [3]
            1, -- [4]
        },
    }
end
