local _, private = ...

-- Lua Globals --
-- luacheck: globals tremove tinsert

local CombatText = private.CombatText

local scrollAreas = {}
local function CreateScrollArea(scrollType)
    local scrollSettings = CombatText.db.global[scrollType]

    local scrollArea = _G.CreateFrame("Frame", nil, _G.UIParent)
    scrollArea:SetSize(scrollSettings.size.x, scrollSettings.size.y)

    local position = scrollSettings.position
    scrollArea:SetPoint(position.point, position.x, position.y)

    scrollAreas[scrollType] = scrollArea
    return scrollArea
end

function private.CreateScrollAreas()
    CreateScrollArea("incoming")
    CreateScrollArea("outgoing")
end

local function DisplayEvent(scrollType, isSticky, text)
    local scrollArea = scrollAreas[scrollType]

    local scrollLines = private.scrollLines.normal
    if isSticky then
        scrollLines = private.scrollLines.sticky
    end

    local scrollLine = scrollLines:Acquire()
    scrollLine:AddToScrollArea(scrollArea)
    scrollLine:DisplayText(text)
end

local eventQueue = {}
_G.C_Timer.NewTicker(0.1, function( ... )
    if #eventQueue > 0 then
        local event = tremove(eventQueue, 1)
        DisplayEvent(event[1], event[2], event[3])
    end
end)

function private.AddEvent(scrollType, isSticky, text)
    tinsert(eventQueue, {scrollType, isSticky, text})
end
