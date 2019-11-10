local _, private = ...

local CombatText = private.CombatText

local scrollAreas = {}
function private.CreateScrollArea(scrollType)
    local scrollSettings = CombatText.db.global[scrollType]

    local scrollArea = _G.CreateFrame("Frame", nil, _G.UIParent)
    scrollArea:SetSize(100, 200)

    local position = scrollSettings.position
    scrollArea:SetPoint(position.point, position.x, position.y)

    local bg = scrollArea:CreateTexture(nil, "BACKGROUND", nil, -7)
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 0.5)

    scrollAreas[scrollType] = scrollArea
    return scrollArea
end

function private.CreateScrollAreas()
    private.CreateScrollArea("incoming")
    private.CreateScrollArea("outgoing")
end

function private.AddEvent(scrollType, isSticky, text)
    local scrollArea = scrollAreas[scrollType]

    local scrollLines = private.scrollLines.normal
    if isSticky then
        scrollLines = private.scrollLines.sticky
    end

    local scrollLine = scrollLines:Acquire()
    if isSticky then
        scrollLine:SetPoint("CENTER", scrollArea)
    else
        scrollLine:SetPoint("BOTTOM", scrollArea)
    end

    scrollLine.scrollArea = scrollArea
    scrollLine:SetText(text)
    scrollLine:Show()
    scrollLine.scrollAnim:Play()
end
