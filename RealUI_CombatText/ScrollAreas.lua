local _, private = ...

-- Lua Globals --
-- luacheck: globals tremove tinsert wipe

local L = _G.RealUI.L
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
        local eventInfo = tremove(eventQueue, 1)
        if eventInfo.string then
            DisplayEvent(eventInfo.scrollType, eventInfo.isSticky, eventInfo.string)
        else
            local data = eventInfo.data
            local eventStr = eventInfo.eventFormat:format(eventInfo[data[1]], eventInfo[data[2]], eventInfo[data[3]])
            DisplayEvent(eventInfo.scrollType, eventInfo.isSticky, eventStr)
        end
    end
end)

local mergeQueue, wait = {}, {}
_G.C_Timer.NewTicker(0.6, function( ... )
    if #mergeQueue == 0 then return end
    wipe(wait)

    local numEvents = #mergeQueue
    local mergeEvent, queueEvent
    local doMerge = false

    for i = 1, numEvents do
        mergeEvent = mergeQueue[i]
        for j = 1, #wait do
            queueEvent = wait[j]
            if mergeEvent.event == queueEvent.event then
                if not mergeEvent.spellName then
                    if mergeEvent.destName == queueEvent.destName then
                        doMerge = true
                    end
                elseif mergeEvent.spellName == queueEvent.spellName then
                    doMerge = true
                end
            end

            if doMerge then
                mergeEvent.isMerged = true

                queueEvent.numMerged = (queueEvent.numMerged or 1) + 1
                queueEvent.amount = queueEvent.amount + mergeEvent.amount
                queueEvent.resultStr = L["CombatText_MergeHits"]:format(queueEvent.numMerged)

                break
            end
        end

        if not doMerge then
            tinsert(wait, mergeEvent)
        end

        doMerge = false
    end


    for i = 1, #wait do
        tinsert(eventQueue, wait[i])
    end

    for i = 1, numEvents do
        --if mergeQueue[1].isMerged then
        --    recycle(mergeQueue[1])
        --end

        tremove(mergeQueue, 1)
    end
end)

function private.AddEvent(eventInfo)
    if eventInfo.canMerge then
        tinsert(mergeQueue, eventInfo)
    else
        tinsert(eventQueue, eventInfo)
    end
end
