local _, mods = ...

_G.tinsert(mods["nibRealUI"], function(F, C)
    if _G.RealUI.isAuroraUpdated then return end

    --print("HELLO WORLD!!!", F, C)
    local TimerTexture = [[Interface\AddOns\nibRealUI\Media\Skins\TimerTracker]]
    local function SkinBar(bar)
        bar:SetHeight(12)
        bar:SetWidth(195)

        for i = 1, bar:GetNumRegions() do
            local region = _G.select(i, bar:GetRegions())
            if region:GetObjectType() == "Texture" then
                region:SetTexture(nil)
            elseif region:GetObjectType() == "FontString" then
                region:SetFontObject(_G.RealUIFont_PixelSmall)
                region:SetShadowColor(0, 0, 0, 0)
            end
        end

        bar:SetStatusBarTexture(_G.RealUI.media.textures.plain)
        bar:SetStatusBarColor(0.35, 0, 0)

        local background = bar:CreateTexture(bar:GetName().."Background", "BACKGROUND")
        background:SetTexture(TimerTexture)
        background:SetPoint("CENTER", 0, 0)
        background:SetWidth(256)
        background:SetHeight(32)
    end

    local f = _G.CreateFrame("Frame")
    f:RegisterEvent("START_TIMER")
    f:SetScript("OnEvent", function()
        for _, timer in _G.ipairs(_G.TimerTracker.timerList) do
            if timer.bar and not timer.skinned then
                SkinBar(timer.bar)
                timer.skinned = true
            end
        end
    end)
end)
