local _, mods = ...
local _G = _G

_G.tinsert(mods["PLAYER_LOGIN"], function(F, C)
    --print("HELLO RealUI!!!", F, C)
    --VideoOptions
    F.Reskin(_G.RealUIScaleBtn)
end)
