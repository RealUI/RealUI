local _, private = ...

-- Lua Globals --
-- luacheck: globals select

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

-- RealUI --
local RealUI = _G.RealUI

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
local function GetSpellColor(school)
    if school then
        if SpellColors[school] then
            return SpellColors[school]
        else
            _G.print("Missing spell color", school)
        end
    end


    return SpellColors[_G.SCHOOL_MASK_NONE]
end

local eventPrefix = {}
private.eventPrefix = eventPrefix

function eventPrefix.SWING(eventInfo, ...)
    eventInfo.icon = 132223 -- Ability_MeleeDamage
    eventInfo.spellSchool = _G.SCHOOL_MASK_PHYSICAL
    if eventSuffix[eventInfo.eventType](eventInfo, ...) then
        private.AddEvent(eventInfo)
    end
end

function eventPrefix.RANGE(eventInfo, ...)
    eventInfo.spellID, eventInfo.spellName, eventInfo.spellSchool = ...

    local _, _, icon = _G.GetSpellInfo(eventInfo.spellID)
    eventInfo.icon = icon

    if eventSuffix[eventInfo.eventType](eventInfo, select(4, ...)) then
        private.AddEvent(eventInfo)
    end
end

function eventPrefix.SPELL(eventInfo, ...)
    eventInfo.spellID, eventInfo.spellName, eventInfo.spellSchool = ...

    local _, _, icon = _G.GetSpellInfo(eventInfo.spellID)
    eventInfo.icon = icon

    if eventSuffix[eventInfo.eventType](eventInfo, select(4, ...)) then
        private.AddEvent(eventInfo)
    end
end

function eventPrefix.SPELL_PERIODIC(eventInfo, ...)
    eventInfo.spellID, eventInfo.spellName, eventInfo.spellSchool = ...

    local _, _, icon = _G.GetSpellInfo(eventInfo.spellID)
    eventInfo.icon = icon

    if eventSuffix[eventInfo.eventType](eventInfo, select(4, ...)) then
        private.AddEvent(eventInfo)
    end
end

function eventPrefix.SPELL_BUILDING(eventInfo, ...)
    eventInfo.spellID, eventInfo.spellName, eventInfo.spellSchool = ...

    local _, _, icon = _G.GetSpellInfo(eventInfo.spellID)
    eventInfo.icon = icon

    if eventSuffix[eventInfo.eventType](eventInfo, select(4, ...)) then
        private.AddEvent(eventInfo)
    end
end

local partialEffects = {
    resist = _G.RESIST_TRAILER:gsub("%%d", "%%s"),
    block = _G.BLOCK_TRAILER:gsub("%%d", "%%s"),
    absorb = _G.ABSORB_TRAILER:gsub("%%d", "%%s"),
    glancing = _G.GLANCING_TRAILER,
    crushing = _G.CRUSHING_TRAILER,
    overheal = _G.TEXT_MODE_A_STRING_RESULT_OVERHEALING:lower(),
    overkill = _G.TEXT_MODE_A_STRING_RESULT_OVERKILLING :lower(),
    overenergize = _G.TEXT_MODE_A_STRING_RESULT_OVERENERGIZE:lower(),
}
local function GetResultString(resisted, blocked, absorbed, glancing, crushing, overhealing, overkill, overenergize)
    local resultStr
    if resisted then
        if resisted < 0 then    --Its really a vulnerability
            -- I don't think this is a thing anymore
            _G.print("Vulnerable!!!", resisted)
        else
            resultStr = partialEffects.resist:format(RealUI.ReadableNumber(resisted))
        end
    end

    if blocked then
        if resultStr then
            resultStr = resultStr.." "..partialEffects.block:format(RealUI.ReadableNumber(blocked))
        else
            resultStr = partialEffects.block:format(RealUI.ReadableNumber(blocked))
        end
    end

    if absorbed and absorbed > 0 then
        if resultStr then
            resultStr = resultStr.." "..partialEffects.absorb:format(RealUI.ReadableNumber(absorbed))
        else
            resultStr = partialEffects.absorb:format(RealUI.ReadableNumber(absorbed))
        end
    end

    if glancing then
        if resultStr then
            resultStr = resultStr.." "..partialEffects.glancing
        else
            resultStr = partialEffects.glancing
        end
    end

    if crushing then
        if resultStr then
            resultStr = resultStr.." "..partialEffects.crushing
        else
            resultStr = partialEffects.crushing
        end
    end

    if overhealing and overhealing > 0 then
        if resultStr then
            resultStr = resultStr.." "..partialEffects.overheal:format(RealUI.ReadableNumber(overhealing))
        else
            resultStr = partialEffects.overheal:format(RealUI.ReadableNumber(overhealing))
        end
    end

    if overkill and overkill > 0 then
        if resultStr then
            resultStr = resultStr.." "..partialEffects.overkill:format(RealUI.ReadableNumber(overkill))
        else
            resultStr = partialEffects.overkill:format(RealUI.ReadableNumber(overkill))
        end
    end

    if overenergize then
        if resultStr then
            resultStr = resultStr.." "..partialEffects.overenergize:format(RealUI.ReadableNumber(overenergize))
        else
            resultStr = partialEffects.overenergize:format(RealUI.ReadableNumber(overenergize))
        end
    end

    return resultStr
end

local event = {
    format = "%s %s %s",
    data = {
        "text",
        "amount",
        "resultStr"
    }
}
function eventSuffix.DAMAGE(eventInfo, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand)
    eventInfo.text = eventInfo.spellName or _G["ACTION_"..eventInfo.eventBase]

    local resultStr = GetResultString(resisted, blocked, absorbed, glancing, crushing, nil, overkill)
    eventInfo.resultStr = resultStr or ""

    if overkill > 0 then
        amount = amount - overkill
    end

    eventInfo.amount = RealUI.ReadableNumber(amount)
    eventInfo.isSticky = critical

    eventInfo.data = event.data
    eventInfo.eventFormat = GetSpellColor(school):WrapTextInColorCode(event.format)
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

    local resultStr = _G[missType]
    eventInfo.amount = RealUI.ReadableNumber(amountMissed or 0)
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

    local resultStr = GetResultString(nil, nil, absorbed, nil, nil, overhealing)
    eventInfo.resultStr = resultStr or ""

    eventInfo.amount = RealUI.ReadableNumber(amount)
    eventInfo.isSticky = critical

    eventInfo.data = event.data
    eventInfo.eventFormat = Color.green:WrapTextInColorCode(event.format)
    return true
end

function eventSuffix.ENERGIZE(eventInfo, amount, overEnergize, powerType, alternatePowerType)
    eventInfo.text = eventInfo.spellName or _G["ACTION_"..eventInfo.eventBase]

    local resultStr = GetResultString(nil, nil, nil, nil, nil, nil, nil, overEnergize)
    eventInfo.resultStr = resultStr or ""

    eventInfo.amount = RealUI.ReadableNumber(amount)

    eventInfo.data = event.data
    eventInfo.eventFormat = event.format
    return true
end
function eventSuffix.DRAIN(eventInfo, amount, powerType, extraAmount, alternatePowerType)
    eventInfo.text = eventInfo.spellName or _G["ACTION_"..eventInfo.eventBase]

    eventInfo.amount = RealUI.ReadableNumber(amount)

    eventInfo.data = event.data
    eventInfo.eventFormat = event.format
    return true
end




local eventSpecial = {}
private.eventSpecial = eventSpecial
local PARTY_KILL = "%s %s %s"
function eventSpecial.PARTY_KILL(eventInfo, ...)
    local _, unconsciousOnDeath = ...
    eventInfo.scrollType = "notification"

    local resultStr = _G.ACTION_PARTY_KILL
    if unconsciousOnDeath then
        resultStr = _G.ACTION_PARTY_KILL_UNCONSCIOUS
    end
    eventInfo.resultStr = resultStr

    eventInfo.canMerge = false
    eventInfo.isSticky = true
    eventInfo.string = PARTY_KILL:format(eventInfo.sourceName, resultStr, eventInfo.destName)
    private.AddEvent(eventInfo)
end

local SPELL_INSTAKILL = "%s %s %s"
function eventSpecial.SPELL_INSTAKILL(eventInfo, ...)
    local _, unconsciousOnDeath = ...
    eventInfo.scrollType = "notification"

    local resultStr = _G.ACTION_SPELL_INSTAKILL
    if unconsciousOnDeath then
        resultStr = _G.ACTION_SPELL_INSTAKILL_UNCONSCIOUS
    end
    eventInfo.resultStr = resultStr

    eventInfo.canMerge = false
    eventInfo.isSticky = true
    eventInfo.string = SPELL_INSTAKILL:format(eventInfo.sourceName, resultStr, eventInfo.destName)
    private.AddEvent(eventInfo)
end

local UNIT_DIED = "%s %s"
function eventSpecial.UNIT_DIED(eventInfo, ...)
    local _, unconsciousOnDeath = ...
    eventInfo.scrollType = "notification"

    local resultStr = _G.ACTION_UNIT_DIED
    if unconsciousOnDeath then
        resultStr = _G.ACTION_UNIT_BECCOMES_UNCONSCIOUS
    end
    eventInfo.resultStr = resultStr

    eventInfo.canMerge = false
    eventInfo.isSticky = true
    eventInfo.string = UNIT_DIED:format(eventInfo.destName, resultStr)
    private.AddEvent(eventInfo)
end

local ENVIRONMENTAL_DAMAGE = {
    format = "%s %s %s",
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
    eventInfo.eventFormat = GetSpellColor(school):WrapTextInColorCode(ENVIRONMENTAL_DAMAGE.format)
    private.AddEvent(eventInfo)
end
