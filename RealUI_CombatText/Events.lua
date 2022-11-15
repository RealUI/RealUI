local _, private = ...

-- Lua Globals --
-- luacheck: globals select

-- Libs --
local Aurora = _G.Aurora
local Color = Aurora.Color

-- RealUI --
local RealUI = _G.RealUI

local function MissingEvent(eventInfo, ...)
    _G.print("Missing combat event", eventInfo.eventBase, eventInfo.eventType, eventInfo.spellName, eventInfo.spellID, ...)
end

local eventSuffix = _G.setmetatable({}, {
    __index = function(...)
        return MissingEvent
    end
})


local Damageclass = _G.Enum.Damageclass
local defaultSchool = Damageclass.MaskNone
local SpellColors = {
    [Damageclass.MaskNone] = Color.Create(1, 1, 1),
    [Damageclass.MaskPhysical] = Color.Create(1, 1, 0),
    [Damageclass.MaskHoly] = Color.Create(1, 0.9, 0.5),
    [Damageclass.MaskFire] = Color.Create(1, 0.5, 0),
    [Damageclass.MaskNature] = Color.Create(0.3, 1, 0.3),
    [Damageclass.MaskFrost] = Color.Create(0.5, 1, 1),
    [Damageclass.MaskShadow] = Color.Create(0.5, 0.5, 1),
    [Damageclass.MaskArcane] = Color.Create(1, 0.5, 1),
}
local function GetSpellColor(school)
    if school then
        if SpellColors[school] then
            return SpellColors[school]
        --else
            --_G.print("Missing spell color", school)
        end
    end


    return SpellColors[defaultSchool]
end

--local defaultPower = _G.Enum.PowerType.Mana
local alternatePower = _G.Enum.PowerType.Alternate
local PowerColors = {
    [_G.Enum.PowerType.Mana] = {Color.Create(0, 0, 1), _G.MANA},
    [_G.Enum.PowerType.Rage] = {Color.Create(1, 0, 0), _G.RAGE},
    [_G.Enum.PowerType.Focus] = {Color.Create(1, 0.5, 0.25), _G.FOCUS},
    [_G.Enum.PowerType.Energy] = {Color.Create(1, 1, 0), _G.ENERGY},
    [_G.Enum.PowerType.ComboPoints] = {Color.Create(1, 0.96, 0.41), _G.COMBO_POINTS},
    [_G.Enum.PowerType.Runes] = {Color.Create(0.5, 0.5, 0.5), _G.RUNES},
    [_G.Enum.PowerType.RunicPower] = {Color.Create(0, 0.82, 1), _G.RUNIC_POWER},
    [_G.Enum.PowerType.SoulShards] = {Color.Create(0.5, 0.32, 0.55), _G.SOUL_SHARDS},
    [_G.Enum.PowerType.LunarPower] = {Color.Create(0.3, 0.52, 0.9), _G.LUNAR_POWER},
    [_G.Enum.PowerType.HolyPower] = {Color.Create(0.95, 0.9, 0.6), _G.HOLY_POWER},
    [_G.Enum.PowerType.Maelstrom] = {Color.Create(0, 0.5, 1), _G.MAELSTROM_POWER},
    [_G.Enum.PowerType.Chi] = {Color.Create(0.71, 1, 0.92), _G.CHI_POWER},
    [_G.Enum.PowerType.Insanity] = {Color.Create(0.4, 0, 0.8), _G.INSANITY_POWER},
    [_G.Enum.PowerType.ArcaneCharges] = {Color.Create(0.1, 0.1, 0.98), _G.ARCANE_CHARGES_POWER},
    [_G.Enum.PowerType.Fury] = {Color.Create(0.788, 0.259, 0.992), _G.FURY},
    [_G.Enum.PowerType.Pain] = {Color.Create(1, 0.612, 0), _G.PAIN},
}
local function GetPower(powerType, alternatePowerType)
    local power = PowerColors[powerType]
    if powerType == alternatePower and alternatePowerType then
        power = PowerColors[alternatePowerType]
    end

    if power then
        return power[1], power[2]
    else
        return Color.white, _G.GetUnitPowerBarStringsByID(alternatePowerType)
    end
end

local eventPrefix = {}
private.eventPrefix = eventPrefix

function eventPrefix.SWING(eventInfo, ...)
    eventInfo.icon = 132223 -- Ability_MeleeDamage
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

function eventPrefix.SPELL_EMPOWER(eventInfo, ...)
    eventInfo.spellID, eventInfo.spellName = ...

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
    if resisted and resisted ~= 0 then
        if resisted < 0 then    --Its really a vulnerability
            -- I don't think this is a thing anymore
            _G.print("Vulnerable!!!", resisted)
        else
            resultStr = partialEffects.resist:format(RealUI.ReadableNumber(resisted))
        end
    end

    if blocked and blocked > 0 then
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

    if overenergize and overenergize > 0 then
        if resultStr then
            resultStr = resultStr.." "..partialEffects.overenergize:format(RealUI.ReadableNumber(overenergize))
        else
            resultStr = partialEffects.overenergize:format(RealUI.ReadableNumber(overenergize))
        end
    end

    return resultStr
end

function eventSuffix.DAMAGE(eventInfo, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing, isOffHand)
    local resultStr = GetResultString(resisted, blocked, absorbed, glancing, crushing, nil, overkill)
    eventInfo.resultStr = resultStr or ""

    if overkill > 0 then
        amount = amount - overkill
    end

    eventInfo.amount = amount
    eventInfo.isSticky = critical
    eventInfo.color = GetSpellColor(school)
    return true
end
function eventSuffix.MISSED(eventInfo, missType, isOffHand, amountMissed, critical)
    eventInfo.amount = amountMissed or 0
    eventInfo.resultStr = _G[missType]
    eventInfo.isSticky = critical

    return true
end
function eventSuffix.HEAL(eventInfo, amount, overhealing, absorbed, critical)
    local resultStr = GetResultString(nil, nil, absorbed, nil, nil, overhealing)
    eventInfo.resultStr = resultStr or ""

    if overhealing > 0 then
        amount = amount - overhealing
    end

    eventInfo.amount = amount
    eventInfo.isSticky = critical
    eventInfo.color = Color.green
    return true
end

function eventSuffix.HEAL_ABSORBED(eventInfo, extraGUID, extraName, extraFlags, extraRaidFlags, extraSpellID, extraSpellName, extraSchool, amount)
    return eventSuffix.HEAL(eventInfo, 0, 0, amount, false)
end

function eventSuffix.ENERGIZE(eventInfo, amount, overEnergize, powerType, alternatePowerType)
    eventInfo.color, eventInfo.text = GetPower(powerType, alternatePowerType)

    local resultStr = GetResultString(nil, nil, nil, nil, nil, nil, nil, overEnergize)
    eventInfo.resultStr = resultStr or ""

    eventInfo.amount = amount

    return true
end
function eventSuffix.DRAIN(eventInfo, amount, powerType, extraAmount, alternatePowerType)
    eventInfo.color, eventInfo.text = GetPower(powerType, alternatePowerType)
    eventInfo.amount = amount

    if extraAmount then
        _G.print("DRAIN extraAmount", eventInfo.text, extraAmount)
    end

    return true
end
function eventSuffix.LEECH(eventInfo, amount, powerType, extraAmount, alternatePowerType)
    eventInfo.color, eventInfo.text = GetPower(powerType, alternatePowerType)
    eventInfo.amount = amount

    if extraAmount then
        _G.print("LEECH extraAmount", eventInfo.text, extraAmount)
    end

    return true
end

function eventSuffix.INTERRUPT(eventInfo, extraSpellId, extraSpellName, extraSpellSchool)
    eventInfo.string = _G.ACTION_SPELL_INTERRUPT .. extraSpellName

    eventInfo.canMerge = false
    eventInfo.isSticky = true
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
    local _, unconsciousOnDeath
    eventInfo.spellID, eventInfo.spellName, eventInfo.spellSchool, _, unconsciousOnDeath = ...
    eventInfo.scrollType = "notification"

    local resultStr = _G.ACTION_SPELL_INSTAKILL
    if unconsciousOnDeath then
        resultStr = _G.ACTION_SPELL_INSTAKILL_UNCONSCIOUS
    end
    eventInfo.resultStr = resultStr

    eventInfo.canMerge = false
    eventInfo.isSticky = true
    eventInfo.string = SPELL_INSTAKILL:format(eventInfo.spellName, resultStr, eventInfo.destName)
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

function eventSpecial.ENVIRONMENTAL_DAMAGE(eventInfo, ...)
    local environmentalType, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing = ...
    eventInfo.eventBase = "ENVIRONMENTAL_DAMAGE_"..environmentalType:upper()

    eventSuffix.DAMAGE(eventInfo, amount, overkill, school, resisted, blocked, absorbed, critical, glancing, crushing)

    eventInfo.color = GetSpellColor(school)
    private.AddEvent(eventInfo)
end

function eventSpecial.DAMAGE_SPLIT(eventInfo, ...)
    eventInfo.eventType = "DAMAGE"
    return eventPrefix.SPELL(eventInfo, ...)
end
