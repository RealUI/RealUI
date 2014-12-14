local _, mods = ...

mods["nibRealUI"] = function(F, C)
    --print("HELLO nibRealUI!!!", F, C)
    --VideoOptions
    F.Reskin(RealUIScaleBtn)

    -- PaperDollFrame
    F.ReskinCheck(RealUIHelm)
    F.ReskinCheck(RealUICloak)
end
