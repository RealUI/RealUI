local _, private = ...

-- Lua Globals --
-- luacheck: globals tremove tinsert wipe

-- RealUI --
local RealUI = _G.RealUI
local FramePoint = RealUI:GetModule("FramePoint")

local L = RealUI.L
local CombatText = private.CombatText

local scrollAreas = {}
local function CreateScrollArea(scrollType, scrollDirection)
    local scrollSettings = CombatText.db.global[scrollType]

    local scrollArea = _G.CreateFrame("Frame", "CombatText_"..scrollType, _G.UIParent)
    scrollArea:SetSize(scrollSettings.size.x, scrollSettings.size.y)
    FramePoint:PositionFrame(CombatText, scrollArea, {"global", scrollType, "position"})
    scrollArea.scrollType = scrollType
    scrollArea.direction = scrollDirection
    if scrollDirection == "alt" then
        scrollArea.state = true
    end

    scrollAreas[scrollType] = scrollArea
    return scrollArea
end

function private.CreateScrollAreas()
    CreateScrollArea("incoming", "down")
    CreateScrollArea("outgoing", "up")
    CreateScrollArea("notification", "alt")
end

local function DisplayEvent(eventInfo, text)
    local scrollArea = scrollAreas[eventInfo.scrollType]
    local scrollDirection = scrollArea.direction
    if scrollDirection == "alt" then
        scrollDirection = scrollArea.state and "up" or "down"
        scrollArea.state = not scrollArea.state
    end

    local scrollLine = private.GetScrollLine(eventInfo.scrollType, eventInfo.isSticky)
    scrollLine:AddToScrollArea(scrollArea, scrollDirection)
    scrollLine:DisplayText(text, eventInfo.icon)
end

local eventQueue, eventFormat = {}, "%s %s"
_G.C_Timer.NewTicker(0.1, function( ... )
    if #eventQueue == 0 then return end

    local eventInfo = tremove(eventQueue, 1)
    if eventInfo.string then
        DisplayEvent(eventInfo, eventInfo.string)
    else
        local text = ""
        if eventInfo.amount > 0 then
            text = RealUI.ReadableNumber(eventInfo.amount)
        end
        if eventInfo.sourceUnit == "pet" and not eventInfo.text then
            eventInfo.text = _G.PET
        end

        if eventInfo.text then
            text = eventFormat:format(eventInfo.text, text)
        end
        if eventInfo.resultStr then
            text = eventFormat:format(text, eventInfo.resultStr)
        end
        if eventInfo.color then
            text = eventInfo.color:WrapTextInColorCode(text)
        end

        DisplayEvent(eventInfo, text)
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
