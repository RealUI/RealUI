local _, mods = ...

tinsert(mods["PLAYER_LOGIN"], function(F, C)
    --print("HELLO nibRealUI!!!", F, C)
    --VideoOptions
    F.Reskin(RealUIScaleBtn)
end)
