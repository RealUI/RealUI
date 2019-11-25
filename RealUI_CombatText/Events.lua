local _, private = ...

-- Lua Globals --
-- luacheck: globals select

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

local function MissingEvent(baseInfo, ... )
    _G.print("Missing combat event", baseInfo.eventBase, baseInfo.eventType)
end

local eventSuffix = _G.setmetatable({}, {
    __index = function()
        return MissingEvent
    end
})
local SpellColors = {
    [_G.SCHOOL_MASK_NONE] = Color.Create(1, 1, 1),
    [_G.SCHOOL_MASK_PHYSICAL] = Color.Create(1, 1, 0),
    [_G.SCHOOL_MASK_HOLY] = Color.Create(1, 0.9, 0.5),
    [_G.SCHOOL_MASK_FIRE] = Color.Create(1, 0.5, 0),
    [_G.SCHOOL_MASK_NATURE] = Color.Create(0.3, 1, 0.3),
    [_G.SCHOOL_MASK_FROST] = Color.Create(0.5, 1, 1),
    [_G.SCHOOL_MASK_SHADOW] = Color.Create(0.5, 0.5, 1),
    [_G.SCHOOL_MASK_ARCANE] = Color.Create(1, 0.5, 1),
}

local eventPrefix = {}
private.eventPrefix = eventPrefix

function eventPrefix.SWING(scrollType, eventInfo, ...)
    local text, isSticky = eventSuffix[eventInfo.eventType](eventInfo, ...)

    private.AddEvent(scrollType, isSticky, text)
end

function eventPrefix.RANGE(scrollType, eventInfo, ...)
    eventInfo.spellId, eventInfo.spellName, eventInfo.spellSchool = ...

    local text, isSticky = eventSuffix[eventInfo.eventType](eventInfo, select(4, ...))

    private.AddEvent(scrollType, isSticky, text)
end

function eventPrefix.SPELL(scrollType, eventInfo, ...)
    eventInfo.spellId, eventInfo.spellName, eventInfo.spellSchool = ...

    local text, isSticky = eventSuffix[eventInfo.eventType](eventInfo, select(4, ...))

    private.AddEvent(scrollType, isSticky, text)
end

function eventPrefix.SPELL_PERIODIC(scrollType, eventInfo, ...)
    eventInfo.spellId, eventInfo.spellName, eventInfo.spellSchool = ...

    local text, isSticky = eventSuffix[eventInfo.eventType](eventInfo, select(4, ...))

    private.AddEvent(scrollType, isSticky, text)
end

function eventPrefix.SPELL_BUILDING(scrollType, eventInfo, ...)
    eventInfo.spellId, eventInfo.spellName, eventInfo.spellSchool = ...

    local text, isSticky = eventSuffix[eventInfo.eventType](eventInfo, select(4, ...))

    private.AddEvent(scrollType, isSticky, text)
end

function eventPrefix.ENVIRONMENTAL(scrollType, eventInfo, ...)
    eventInfo.environmentalType = ...

    local text, isSticky = eventSuffix[eventInfo.eventType](eventInfo, select(2, ...))

    private.AddEvent(scrollType, isSticky, text)
end


local eventFormat = "%s %d %s"
function eventSuffix.DAMAGE(eventInfo, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand)
    local text = eventInfo.spellName or _G["ACTION_"..eventInfo.eventBase]

    local resultStr = _G.CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, nil, nil, eventInfo.spellId, overkill)
    resultStr = resultStr or ""

    if overkill > 0 then
        amount = amount - overkill
    end

    text = eventFormat:format(text, amount, resultStr)

    return SpellColors[school]:WrapTextInColorCode(text), critical
end

function eventSuffix.MISSED(eventInfo, missType, isOffHand, amountMissed, critical)
    local text = eventInfo.spellName or _G["ACTION_"..eventInfo.eventBase]

    local resultStr
    if missType == "ABSORB" then
        _G.CombatLog_String_DamageResultString(nil, nil, amountMissed, critical, nil, nil, nil, nil, eventInfo.spellId)
    elseif missType == "RESIST" or missType == "BLOCK" then
        if amountMissed ~= 0 then
            resultStr = _G["TEXT_MODE_A_STRING_RESULT_"..missType]:format(amountMissed)
        end
    else
        resultStr = _G["ACTION_"..eventInfo.eventBase.."_MISSED_"..missType]
    end

    return eventFormat:format(text, amountMissed, resultStr), critical
end

function eventSuffix.HEAL(eventInfo, amount, overhealing, absorbed, critical)
    local text = eventInfo.spellName or _G["ACTION_"..eventInfo.eventBase]

    local resultStr = _G.CombatLog_String_DamageResultString(nil, nil, absorbed, critical, nil, nil, overhealing, nil, eventInfo.spellId)
    resultStr = resultStr or ""

    return eventFormat:format(text, amount, resultStr), critical
end

function eventSuffix.ENERGIZE(eventInfo, amount, overEnergize, powerType, alternatePowerType)
    local text = eventInfo.spellName or _G["ACTION_"..eventInfo.eventBase]

    local resultStr = _G.CombatLog_String_DamageResultString(nil, nil, nil, nil, nil, nil, nil, nil, eventInfo.spellId, nil, overEnergize)
    resultStr = resultStr or ""

    return eventFormat:format(text, amount, resultStr)
end



local eventSpecial = {}
private.eventSpecial = eventSpecial

local PARTY_KILL = "%s %s %s"
function eventSpecial.PARTY_KILL(scrollType, eventInfo, ...)
    local _, unconsciousOnDeath = ...

    local resultStr = _G.ACTION_PARTY_KILL
    if unconsciousOnDeath then
        resultStr = _G.ACTION_PARTY_KILL_UNCONSCIOUS
    end

    local isSticky = true
    private.AddEvent(scrollType, isSticky, PARTY_KILL:format(eventInfo.sourceName, resultStr, eventInfo.destName))
end
