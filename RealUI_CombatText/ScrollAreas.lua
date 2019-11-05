local _, private = ...

function private.CreateScrollArea()
    local scrollArea = _G.CreateFrame("Frame", nil, _G.UIParent)
    scrollArea:SetSize(100, 200)
    scrollArea:SetPoint("CENTER")

    local bg = scrollArea:CreateTexture(nil, "BACKGROUND", nil, -7)
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 0.5)

    return scrollArea
end

