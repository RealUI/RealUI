local _, mods = ...

tinsert(mods["PLAYER_LOGIN"], function(F, C)
    --print("HELLO nibRealUI!!!", F, C)
    --VideoOptions
    F.Reskin(RealUIScaleBtn)

    --local coords = WorldMapFrame.coords
    --coords.player:SetFont(unpack(RealUI.font.pixel1))
    --coords.mouse:SetFont(unpack(RealUI.font.pixel1))
end)
