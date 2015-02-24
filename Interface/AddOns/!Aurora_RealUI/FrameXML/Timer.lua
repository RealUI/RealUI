local _, mods = ...

tinsert(mods["nibRealUI"], function(F, C)
    --print("HELLO WORLD!!!", F, C)
    local TimerTexture = [[Interface\AddOns\nibRealUI\Media\Skins\TimerTracker]]
    local function SkinBar(bar)
        local barName = bar:GetName()
        bar:SetHeight(12)
        bar:SetWidth(195)
        
        for i = 1, bar:GetNumRegions() do
            local region = select(i, bar:GetRegions())
            if region:GetObjectType() == "Texture" then
                region:SetTexture(nil)
            elseif region:GetObjectType() == "FontString" then
                region:SetFont(unpack(RealUI:Font(false, "small")))
                region:SetShadowColor(0, 0, 0, 0)
            end
        end
        
        bar:SetStatusBarTexture(RealUI.media.textures.plain)
        bar:SetStatusBarColor(0.35, 0, 0)
        
        local background = bar:CreateTexture(bar:GetName().."Background", "BACKGROUND")
        background:SetTexture(TimerTexture)
        background:SetPoint("CENTER", 0, 0)
        background:SetWidth(256)
        background:SetHeight(32)
    end

    local f = CreateFrame("Frame")
    f:RegisterEvent("START_TIMER")
    f:SetScript("OnEvent", function()
        for _, timer in ipairs(TimerTracker.timerList) do
            if timer.bar and not timer.skinned then
                SkinBar(timer.bar)
                timer.skinned = true
            end
        end
    end)
end)
