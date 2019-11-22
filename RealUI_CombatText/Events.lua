local _, private = ...

-- Lua Globals --
-- luacheck: globals select

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

local function MissingEvent(baseInfo, ... )
    _G.print("Missing combat event", baseInfo.eventBase, baseInfo.eventType)
end

local eventTypes = _G.setmetatable({}, {
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


local SWING = {
    format = "%s %d %s",
    eventBase = "SWING",
}
function private.SWING(scrollType, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    SWING.eventType = eventType

    local text, isSticky = eventTypes[eventType](SWING, ...)

    private.AddEvent(scrollType, isSticky, text)
end

local RANGE = {
    format = "%s %d %s",
    eventBase = "RANGE",
    spellId = 0,
    spellName = 0,
    spellSchool = 0,
}
function private.RANGE(scrollType, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    RANGE.spellId, RANGE.spellName, RANGE.spellSchool = ...
    RANGE.eventType = eventType

    local text, isSticky = eventTypes[eventType](RANGE, select(4, ...))

    private.AddEvent(scrollType, isSticky, text)
end

local SPELL = {
    format = "%s %d %s",
    eventBase = "SPELL",
    spellId = 0,
    spellName = 0,
    spellSchool = 0,
}
function private.SPELL(scrollType, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    SPELL.spellId, SPELL.spellName, SPELL.spellSchool = ...
    SPELL.eventType = eventType

    local text, isSticky = eventTypes[eventType](SPELL, select(4, ...))

    private.AddEvent(scrollType, isSticky, text)
end

local SPELL_PERIODIC = {
    format = "%s %d %s",
    eventBase = "SPELL_PERIODIC",
    spellId = 0,
    spellName = 0,
    spellSchool = 0,
}
function private.SPELL_PERIODIC(scrollType, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    SPELL_PERIODIC.spellId, SPELL_PERIODIC.spellName, SPELL_PERIODIC.spellSchool = ...
    SPELL_PERIODIC.eventType = eventType

    local text, isSticky = eventTypes[eventType](SPELL_PERIODIC, select(4, ...))

    private.AddEvent(scrollType, isSticky, text)
end

local SPELL_BUILDING = {
    format = "%s %d %s",
    eventBase = "SPELL_BUILDING",
    spellId = 0,
    spellName = 0,
    spellSchool = 0,
}
function private.SPELL_BUILDING(scrollType, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    SPELL_BUILDING.spellId, SPELL_BUILDING.spellName, SPELL_BUILDING.spellSchool = ...
    SPELL_BUILDING.eventType = eventType

    local text, isSticky = eventTypes[eventType](SPELL_BUILDING, select(4, ...))

    private.AddEvent(scrollType, isSticky, text)
end

local ENVIRONMENTAL = {
    format = "%s %d %s",
    eventBase = "ENVIRONMENTAL",
    environmentalType = 0,
}
function private.ENVIRONMENTAL(scrollType, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    ENVIRONMENTAL.environmentalType = ...
    ENVIRONMENTAL.eventType = eventType

    local text, isSticky = eventTypes[eventType](ENVIRONMENTAL, select(2, ...))

    private.AddEvent(scrollType, isSticky, text)
end






function eventTypes.DAMAGE(baseInfo, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand)
    local text = baseInfo.spellName or _G["ACTION_"..baseInfo.eventBase]

    local resultStr = _G.CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, nil, nil, baseInfo.spellId, overkill)
    resultStr = resultStr or ""

    if overkill > 0 then
        amount = amount - overkill
    end

    text = baseInfo.format:format(text, amount, resultStr)

    return SpellColors[school]:WrapTextInColorCode(text), critical
end

function eventTypes.MISSED(baseInfo, missType, isOffHand, amountMissed, critical)
    local text = baseInfo.spellName or _G["ACTION_"..baseInfo.eventBase]

    local resultStr
    if missType == "ABSORB" then
        _G.CombatLog_String_DamageResultString(nil, nil, amountMissed, critical, nil, nil, nil, nil, baseInfo.spellId)
    elseif missType == "RESIST" or missType == "BLOCK" then
        if amountMissed ~= 0 then
            resultStr = _G["TEXT_MODE_A_STRING_RESULT_"..missType]:format(amountMissed)
        end
    else
        resultStr = _G["ACTION_"..baseInfo.eventBase.."_MISSED_"..missType]
    end

    return baseInfo.format:format(text, amountMissed, resultStr), critical
end

function eventTypes.HEAL(baseInfo, amount, overhealing, absorbed, critical)
    local text = baseInfo.spellName or _G["ACTION_"..baseInfo.eventBase]

    local resultStr = _G.CombatLog_String_DamageResultString(nil, nil, absorbed, critical, nil, nil, overhealing, nil, baseInfo.spellId)
    resultStr = resultStr or ""

    return baseInfo.format:format(text, amount, resultStr), critical
end

function eventTypes.ENERGIZE(baseInfo, amount, overEnergize, powerType, alternatePowerType)
    local text = baseInfo.spellName or _G["ACTION_"..baseInfo.eventBase]

    local resultStr = _G.CombatLog_String_DamageResultString(nil, nil, nil, nil, nil, nil, nil, nil, baseInfo.spellId, nil, overEnergize)
    resultStr = resultStr or ""

    return baseInfo.format:format(text, amount, resultStr)
end
