local nibRealUI = LibStub("AceAddon-3.0"):GetAddon("nibRealUI")

local MODNAME = "UnitFrames"
local UnitFrames = nibRealUI:GetModule(MODNAME)

local oUF = oUFembed
local tags = oUF.Tags

------------------
------ Tags ------
------------------

-- Name
tags.Methods["realui:name"] = function(unit)
    if UnitIsDead(unit) or UnitIsGhost(unit) or not(UnitIsConnected(unit)) then return end
    local unitTag = unit:match("(boss)%d?$") or unit
    return UnitFrames:AbrvName(UnitName(unit), unitTag)
end
oUF.Tags.Events["realui:name"] = "UNIT_NAME_UPDATE"

-- Health
tags.Methods["realui:health"] = function(unit)
    if UnitIsDead(unit) or UnitIsGhost(unit) or not(UnitIsConnected(unit)) then return end

    return nibRealUI:ReadableNumber(UnitHealth(unit))
end
oUF.Tags.Events["realui:health"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED"

-- Health %
tags.Methods["realui:healthPercent"] = function(unit)
    if UnitIsDead(unit) or UnitIsGhost(unit) or not(UnitIsConnected(unit)) then return end

    return ("%d|cff%s%%|r"):format(UnitHealth(unit) / UnitHealthMax(unit) * 100, nibRealUI:ColorTableToStr(UnitFrames.db.profile.overlay.colors.health.normal))
end
oUF.Tags.Events["realui:healthPercent"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED"

-- Power
tags.Methods["realui:power"] = function(unit)
    if UnitIsDead(unit) or UnitIsGhost(unit) or not(UnitIsConnected(unit)) then return end

    return nibRealUI:ReadableNumber(UnitPower(unit))
end
oUF.Tags.Events["realui:power"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_TARGETABLE_CHANGED"

-- PvP Timer
tags.Methods["realui:pvptimer"] = function(unit)
    --print("Tag:pvptimer", unit)
    if not IsPVPTimerRunning() then return "" end

    return nibRealUI:ConvertSecondstoTime(floor(GetPVPTimer() / 1000))
end
oUF.Tags.Events["realui:pvptimer"] = "UNIT_FACTION PLAYER_FLAGS_CHANGED"

