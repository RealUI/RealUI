local _, private = ...

-- Lua Globals --
-- luacheck: globals select

local function MissingEvent(baseInfo, ... )
    _G.print("Missing combat event", baseInfo.eventBase, baseInfo.eventType)
end

local eventTypes = _G.setmetatable({}, {
    __index = function()
        return MissingEvent
    end
})

local SWING = {
    eventBase = "SWING",
}
function private.SWING(scrollType, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    SWING.eventType = eventType

    local text, isSticky = eventTypes[eventType](SWING, ...)

    private.AddEvent(scrollType, isSticky, text)
end

local RANGE = {
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
    eventBase = "SPELL",
    spellId = 0,
    spellName = 0,
    spellSchool = 0,
}
function private.SPELL(scrollType, eventType, hideCaster, sourceGUID, sourceName, sourceFlags, sourceRaidFlags, destGUID, destName, destFlags, destRaidFlags, ...)
    SPELL.spellId, SPELL.spellName, SPELL.spellSchool = ...

    local eventMod
    if eventType:find("PERIODIC") or eventType:find("BUILDING") then
        eventMod = eventType -- retain this so we still have the full event name
        eventType = eventType:match("%w+_([%w_]+)")
    end
    SPELL.eventType = eventMod or eventType

    local text, isSticky = eventTypes[eventType](SPELL, select(4, ...))

    private.AddEvent(scrollType, isSticky, text)
end

local ENVIRONMENTAL = {
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
    local resultStr = _G.CombatLog_String_DamageResultString(resisted, blocked, absorbed, critical, glancing, crushing, nil, nil, baseInfo.spellId, overkill)

    if overkill > 0 then
        amount = amount - overkill
    end

    return amount .. resultStr, critical
end
