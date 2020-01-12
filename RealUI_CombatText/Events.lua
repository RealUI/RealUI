local _, private = ...

-- Lua Globals --
-- luacheck: globals select

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

local function MissingEvent(eventInfo, ...)
    _G.print("Missing combat event", eventInfo.eventBase, eventInfo.eventType)
end

local eventSuffix = _G.setmetatable({}, {
    __index = function(...)
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
local SPELL_SCHOOL_DEFAULT = _G.SCHOOL_MASK_NONE

local eventPrefix = {}
private.eventPrefix = eventPrefix

function eventPrefix.SWING(eventInfo, ...)
    if eventSuffix[eventInfo.eventType](eventInfo, ...) then
        private.AddEvent(eventInfo)
    end
end

function eventPrefix.RANGE(eventInfo, ...)
    eventInfo.spellId, eventInfo.spellName, eventInfo.spellSchool = ...
    if eventSuffix[eventInfo.eventType](eventInfo, select(4, ...)) then
        private.AddEvent(eventInfo)
    end
end

function eventPrefix.SPELL(eventInfo, ...)
    eventInfo.spellId, eventInfo.spellName, eventInfo.spellSchool = ...
    if eventSuffix[eventInfo.eventType](eventInfo, select(4, ...)) then
        private.AddEvent(eventInfo)
    end
end

function eventPrefix.SPELL_PERIODIC(eventInfo, ...)
    eventInfo.spellId, eventInfo.spellName, eventInfo.spellSchool = ...
    if eventSuffix[eventInfo.eventType](eventInfo, select(4, ...)) then
        private.AddEvent(eventInfo)
    end
end

function eventPrefix.SPELL_BUILDING(eventInfo, ...)
    eventInfo.spellId, eventInfo.spellName, eventInfo.spellSchool = ...
    if eventSuffix[eventInfo.eventType](eventInfo, select(4, ...)) then
        private.AddEvent(eventInfo)
    end
end


local event = {
    format = "%s %d %s",
    data = {
        "text",
        "amount",
        "resultStr"
    }
}
function eventSuffix.DAMAGE(eventInfo, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand)
    eventInfo.text = eventInfo.spellName or _G["ACTION_"..eventInfo.eventBase]

    local resultStr = _G.CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, nil, nil, eventInfo.spellId, overkill)
    eventInfo.resultStr = resultStr or ""

    if overkill > 0 then
        amount = amount - overkill
    end

    eventInfo.amount = amount
    eventInfo.isSticky = critical

    eventInfo.data = event.data
    eventInfo.eventFormat = SpellColors[school or SPELL_SCHOOL_DEFAULT]:WrapTextInColorCode(event.format)
    return true
end

local MISSED = {
    format = "%s %s",
    data = {
        "text",
        "resultStr"
    }
}
function eventSuffix.MISSED(eventInfo, missType, isOffHand, amountMissed, critical)
    eventInfo.text = eventInfo.spellName or _G["ACTION_"..eventInfo.eventBase]

    local resultStr
    if missType == "ABSORB" then
        resultStr = _G.CombatLog_String_DamageResultString(nil, nil, amountMissed, critical, nil, nil, nil, nil, eventInfo.spellId)
    elseif missType == "RESIST" or missType == "BLOCK" then
        if amountMissed ~= 0 then
            resultStr = _G["TEXT_MODE_A_STRING_RESULT_"..missType]:format(amountMissed)
        end
    else
        resultStr = _G["ACTION_"..eventInfo.eventBase.."_MISSED_"..missType]
    end

    eventInfo.amount = amountMissed or 0
    eventInfo.resultStr = resultStr
    eventInfo.isSticky = critical

    if amountMissed then
        eventInfo.data = event.data
        eventInfo.eventFormat = event.format
    else
        eventInfo.eventFormat = MISSED.format
        eventInfo.data = MISSED.data
    end
    return true
end

function eventSuffix.HEAL(eventInfo, amount, overhealing, absorbed, critical)
    eventInfo.text = eventInfo.spellName or _G["ACTION_"..eventInfo.eventBase]

    local resultStr = _G.CombatLog_String_DamageResultString(nil, nil, absorbed, critical, nil, nil, overhealing, nil, eventInfo.spellId)
    eventInfo.resultStr = resultStr or ""

    eventInfo.amount = amount
    eventInfo.isSticky = critical

    eventInfo.data = event.data
    eventInfo.eventFormat = event.format
    return true
end

function eventSuffix.ENERGIZE(eventInfo, amount, overEnergize, powerType, alternatePowerType)
    eventInfo.text = eventInfo.spellName or _G["ACTION_"..eventInfo.eventBase]

    local resultStr = _G.CombatLog_String_DamageResultString(nil, nil, nil, nil, nil, nil, nil, nil, eventInfo.spellId, nil, overEnergize)
    eventInfo.resultStr = resultStr or ""

    eventInfo.amount = amount

    eventInfo.data = event.data
    eventInfo.eventFormat = event.format
    return true
end



local eventSpecial = {}
private.eventSpecial = eventSpecial

local PARTY_KILL = "%s %s %s"
function eventSpecial.PARTY_KILL(eventInfo, ...)
    local _, unconsciousOnDeath = ...

    local resultStr = _G.ACTION_PARTY_KILL
    if unconsciousOnDeath then
        resultStr = _G.ACTION_PARTY_KILL_UNCONSCIOUS
    end
    eventInfo.resultStr = resultStr

    eventInfo.isSticky = true
    eventInfo.string = PARTY_KILL:format(eventInfo.sourceName, resultStr, eventInfo.destName)
    private.AddEvent(eventInfo)
end

local ENVIRONMENTAL_DAMAGE = {
    format = "%d %s %s",
    data = {
        "amount",
        "text",
        "resultStr"
    }
}
function eventSpecial.ENVIRONMENTAL_DAMAGE(eventInfo, ...)
    local environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
    eventInfo.eventBase = "ENVIRONMENTAL_DAMAGE_"..environmentalType:upper()

    eventSuffix.DAMAGE(eventInfo, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing)

    eventInfo.data = ENVIRONMENTAL_DAMAGE.data
    eventInfo.eventFormat = SpellColors[school]:WrapTextInColorCode(ENVIRONMENTAL_DAMAGE.format)
    private.AddEvent(eventInfo)
end
