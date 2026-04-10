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
    elseif eventInfo.secretAmount then
        -- WoW 12: amount is a secret value, use string.format to concatenate
        -- (allowed per Secret Values spec) then pass to FontString:SetText
        local text = string.format("%d", eventInfo.secretAmount)
        if eventInfo.color then
            text = eventInfo.color:WrapTextInColorCode(text)
        end
        DisplayEvent(eventInfo, text)
    else
        local text = ""
        if eventInfo.amount and eventInfo.amount > 0 then
            text = RealUI.ReadableNumber(eventInfo.amount)
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
            if mergeEvent.messageType == queueEvent.messageType then
                doMerge = true
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

-- Summary categories: map messageType → broad category for flush summaries
local SUMMARY_CATEGORY = {
    DAMAGE = "damage", DAMAGE_CRIT = "damage",
    SPELL_DAMAGE = "damage", SPELL_DAMAGE_CRIT = "damage",
    DAMAGE_SHIELD = "damage", SPLIT_DAMAGE = "damage",

    HEAL = "healing", HEAL_CRIT = "healing",
    PERIODIC_HEAL = "healing", PERIODIC_HEAL_CRIT = "healing",
    HEAL_ABSORB = "healing", PERIODIC_HEAL_ABSORB = "healing",
    HEAL_CRIT_ABSORB = "healing", ABSORB_ADDED = "healing",

    MISS = "miss", DODGE = "miss", PARRY = "miss", EVADE = "miss",
    IMMUNE = "miss", DEFLECT = "miss", BLOCK = "miss",
    ABSORB = "miss", RESIST = "miss",
    SPELL_MISS = "miss", SPELL_DODGE = "miss", SPELL_PARRY = "miss",
    SPELL_EVADE = "miss", SPELL_IMMUNE = "miss", SPELL_DEFLECT = "miss",
    SPELL_REFLECT = "miss", SPELL_BLOCK = "miss",
    SPELL_ABSORB = "miss", SPELL_RESIST = "miss",
}

local CATEGORY_LABELS = {
    damage = "CombatText_SummaryCat_Damage",
    healing = "CombatText_SummaryCat_Healing",
    miss = "CombatText_SummaryCat_Miss",
}

local CATEGORY_SCROLL_TYPE = {
    damage = "outgoing",
    healing = "incoming",
    miss = "notification",
}

-- Per-category counters for flush summary (includes both queued and dropped events)
local summary = {}
local function trackEvent(eventInfo)
    local cat = eventInfo.messageType and SUMMARY_CATEGORY[eventInfo.messageType]
    if not cat then return end

    if not summary[cat] then
        summary[cat] = { hits = 0, crits = 0, color = nil }
    end
    local s = summary[cat]
    s.hits = s.hits + 1
    if eventInfo.isSticky then
        s.crits = s.crits + 1
    end
    if not s.color and eventInfo.color then
        s.color = eventInfo.color
    end
end

local MAX_QUEUE_SIZE = 30
local CATEGORY_ORDER = {"damage", "healing", "miss"}
local function emitSummary()
    for _, cat in _G.ipairs(CATEGORY_ORDER) do
        local s = summary[cat]
        if s and s.hits > 0 then
            local label = L[CATEGORY_LABELS[cat]]
            local text
            if s.crits > 0 then
                text = L["CombatText_Summary"]:format(label, s.hits, s.crits)
            else
                text = L["CombatText_SummaryNoCrit"]:format(label, s.hits)
            end
            if s.color then
                text = s.color:WrapTextInColorCode(text)
            end
            tinsert(eventQueue, {
                string = text,
                scrollType = CATEGORY_SCROLL_TYPE[cat],
            })
        end
    end
    wipe(summary)
end

function private.AddEvent(eventInfo)
    trackEvent(eventInfo)
    if eventInfo.canMerge then
        tinsert(mergeQueue, eventInfo)
    else
        if #eventQueue >= MAX_QUEUE_SIZE then
            wipe(eventQueue)
            wipe(mergeQueue)
            emitSummary()
        end
        tinsert(eventQueue, eventInfo)
    end
end

function private.FlushQueues()
    wipe(eventQueue)
    wipe(mergeQueue)
    emitSummary()
end
