local _, private = ...

-- Libs --
local oUF = private.oUF
local tags = oUF.Tags
local Color = _G.Aurora.Color

-- RealUI --
local RealUI = private.RealUI

local UnitFrames = RealUI:GetModule("UnitFrames")


local utf8len, utf8sub = _G.string.utf8len, _G.string.utf8sub
local function AbbreviateName(name, maxLength)
    if not name then return "" end
    local maxNameLength = maxLength or 12

    local words, newName = {_G.strsplit(" ", name)}
    if #words > 2 and utf8len(name) > maxNameLength then
        local i = 1
        repeat
            words[i] = utf8sub(words[i], 1, 1) .. "."
            i = i + 1
        until i == #words

        newName = _G.strjoin(" ", _G.unpack(words))
    else
        newName = name
    end

    if utf8len(newName) > maxNameLength then
        newName = utf8sub(newName, 1, maxNameLength)..".."
    end
    return newName
end

------------------
------ Tags ------
------------------
-- Name
tags.Methods["realui:name"] = function(unit)
    local isDead = false
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not(_G.UnitIsConnected(unit)) then
        isDead = true
    end

    local unitTag = unit:match("^(%w-)%d") or unit

    --local enUS,  zhTW,  zhCN,  ruRU,  koKR = "Account Level Mount", "帳號等級坐騎", "战网通行证通用坐骑", "Средство передвижения для всех персонажей учетной записи", "계정 공유 탈것"
    local name = _G.UnitName(unit) or ""
    name = AbbreviateName(name, UnitFrames[unitTag].nameLength)

    local nameColor = "ffffffff"
    if isDead then
        nameColor = "ff3f3f3f"
    elseif UnitFrames.db.profile.overlay.classColorNames then
        --print("Class color names", unit)
        local _, class = _G.UnitClass(unit)
        nameColor = _G.CUSTOM_CLASS_COLORS[class or "PRIEST"].colorStr
    end
    return ("|c%s%s|r"):format(nameColor, name)
end
tags.Events["realui:name"] = "UNIT_NAME_UPDATE"

-- Level
tags.Methods["realui:level"] = function(unit)
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not(_G.UnitIsConnected(unit)) then return end

    local level, levelColor
    if (_G.UnitIsWildBattlePet(unit) or _G.UnitIsBattlePetCompanion(unit)) then
        level = _G.UnitBattlePetLevel(unit)
    else
        level = _G.UnitLevel(unit)
    end
    if level <= 0 then
        level = "??"
        levelColor = _G.QuestDifficultyColors.impossible
    else
        levelColor = _G.GetQuestDifficultyColor(level)
    end
    return ("|c%s%s|r"):format(RealUI.GetColorString(levelColor), level)
end
tags.Events["realui:level"] = "UNIT_NAME_UPDATE"

-- PvP Timer
tags.Methods["realui:pvptimer"] = function(unit)
    --print("Tag:pvptimer", unit)
    if not _G.IsPVPTimerRunning() then return "" end

    return _G.SecondsToClock(_G.floor(_G.GetPVPTimer() / 1000))
end
tags.Events["realui:pvptimer"] = "UNIT_FACTION PLAYER_FLAGS_CHANGED"



-- Health AbsValue
tags.Methods["realui:healthValue"] = function(unit)
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not(_G.UnitIsConnected(unit)) then return 0 end

    return RealUI.ReadableNumber(_G.UnitHealth(unit))
end
tags.Events["realui:healthValue"] = "UNIT_HEALTH_FREQUENT UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED"

-- Health %
tags.Methods["realui:healthPercent"] = function(unit)
    local percent
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not(_G.UnitIsConnected(unit)) then
        percent = 0
    else
        percent = _G.UnitHealth(unit) / _G.UnitHealthMax(unit) * 100
    end

    UnitFrames:debug("realui:healthPercent", percent)
    return ("%.1f|c%s%%|r"):format(percent, RealUI.GetColorString(oUF.colors.health))
end
tags.Events["realui:healthPercent"] = tags.Events["realui:healthValue"]

-- Health
tags.Methods["realui:health"] = function(unit)
    local statusText = UnitFrames.db.profile.misc.statusText
    if statusText == "both" then
        return tags.Methods["realui:healthPercent"](unit).." - "..tags.Methods["realui:healthValue"](unit)
    elseif statusText == "perc" then
        return tags.Methods["realui:healthPercent"](unit)
    else
        return tags.Methods["realui:healthValue"](unit)
    end
end
tags.Events["realui:health"] = tags.Events["realui:healthValue"]



-- Power AbsValue
tags.Methods["realui:powerValue"] = function(unit)
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not(_G.UnitIsConnected(unit)) then return 0 end

    return RealUI.ReadableNumber(_G.UnitPower(unit))
end
tags.Events["realui:powerValue"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER UNIT_TARGETABLE_CHANGED"

-- Power %
tags.Methods["realui:powerPercent"] = function(unit)
    local percent
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not(_G.UnitIsConnected(unit)) then
        percent = 0
    else
        percent = _G.UnitPower(unit) / _G.UnitPowerMax(unit) * 100
    end

    local _, ptoken = _G.UnitPowerType(unit)
    return ("%.1f|c%s%%|r"):format(percent, RealUI.GetColorString(oUF.colors.power[ptoken]))
end
tags.Events["realui:powerPercent"] = tags.Events["realui:powerValue"]

-- Power
tags.Methods["realui:power"] = function(unit)
    local _, ptoken = _G.UnitPowerType(unit)
    local statusText = UnitFrames.db.profile.misc.statusText
    if ptoken == "MANA" then
        if statusText == "both" then
            return tags.Methods["realui:powerPercent"](unit).." - "..tags.Methods["realui:powerValue"](unit)
        elseif statusText == "perc" then
            return tags.Methods["realui:powerPercent"](unit)
        else
            return tags.Methods["realui:powerValue"](unit)
        end
    else
        return tags.Methods["realui:powerValue"](unit)
    end
end
tags.Events["realui:power"] = tags.Events["realui:powerValue"]


-- Colored Threat Percent
tags.Methods["realui:threat"] = function(unit)
    local color = tags.Methods['threatcolor'](unit)
    local isTanking, _, _, percentage = _G.UnitDetailedThreatSituation("player", "target")

    if percentage and not _G.UnitIsDeadOrGhost(unit) then
        if isTanking then
            percentage = _G.UnitThreatPercentageOfLead("player", "target")
        end

        if percentage and percentage ~= 0 then
            UnitFrames:debug("threat", color, isTanking, percentage)
            return ("%s%1.0f%%|r"):format(color, percentage)
        end
    end
end
tags.Events["realui:threat"] = "UNIT_THREAT_SITUATION_UPDATE UNIT_THREAT_LIST_UPDATE"

-- Range
local rangeColors = {
    [5] = Color.green,
    [30] = Color.yellow,
    [35] = Color.yellow,
    [40] = Color.orange,
    [50] = Color.red,
    [100] = Color.red,
}
local rangeCheck = _G.LibStub("LibRangeCheck-2.0")
tags.Methods["realui:range"] = function(unit)
    local _, maxRange = rangeCheck:GetRange("target")
    if maxRange and not _G.UnitIsUnit("target", "player") then
        local section
        if maxRange <= 5 then
            section = 5
        elseif maxRange <= 30 then
            section = 30
        elseif maxRange <= 35 then
            section = 35
        elseif maxRange <= 40 then
            section = 40
        elseif maxRange <= 50 then
            section = 50
        else
            section = 100
        end
        return ("|c%s%d|r"):format(rangeColors[section].colorStr, maxRange)
    end
end
