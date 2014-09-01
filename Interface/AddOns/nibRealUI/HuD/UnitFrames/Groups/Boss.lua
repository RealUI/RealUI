function RealUIUFBossConfig(toggle, unit)
    --[[for b = 1, MAX_BOSS_FRAMES do
        local f = _G["RealUIBoss" .. b .. "Frame"]
        if toggle then
            if not f.__realunit then
                f.__realunit = f:GetAttribute("unit") or f.unit
                f:SetAttribute("unit", unit)
                f.unit = unit
                f:Show()
            end
        else
            if f.__realunit then
                f:SetAttribute("unit", f.__realunit)
                f.unit = f.__realunit
                f.__realunit = nil
                f:Hide()
            end
        end
    end]]
end
