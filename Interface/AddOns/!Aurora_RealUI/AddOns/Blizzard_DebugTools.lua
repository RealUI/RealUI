local _, mods = ...

mods["Blizzard_DebugTools"] = function(F, C)
    --print("HELLO Blizzard_DebugTools!!!", F, C)
    -- EventTrace
    for i = 1, EventTraceFrame:GetNumRegions() do
        local region = select(i, EventTraceFrame:GetRegions())
        if region:GetObjectType() == "Texture" then
            region:SetTexture(nil)
        end
    end
    EventTraceFrame:SetHeight(600)
    F.CreateBD(EventTraceFrame)

    EventTraceFrameScrollBG:Hide()
    local thumb = EventTraceFrameScroll.thumb
    thumb:SetAlpha(0)
    thumb:SetWidth(17)
    thumb.bg = CreateFrame("Frame", nil, EventTraceFrameScroll)
    thumb.bg:SetPoint("TOPLEFT", thumb, 0, 0)
    thumb.bg:SetPoint("BOTTOMRIGHT", thumb, 0, 0)
    F.CreateBD(thumb.bg, 0)
    thumb.tex = F.CreateGradient(thumb.bg)
    thumb.tex:SetPoint("TOPLEFT", thumb.bg, 1, -1)
    thumb.tex:SetPoint("BOTTOMRIGHT", thumb.bg, -1, 1)

    F.ReskinClose(EventTraceFrameCloseButton)
end
