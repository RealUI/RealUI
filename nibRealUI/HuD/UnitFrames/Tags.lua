local _, private = ...

-- Lua Globals --
-- luacheck: globals strlenutf8

-- Libs --
local oUF = private.oUF
local tags = oUF.Tags
local Color = _G.Aurora.Color

-- RealUI --
local RealUI = private.RealUI

local UnitFrames = RealUI:GetModule("UnitFrames")


local ES_PADDING = {
    ["||"] = -1,
    ["|c"] = 9,
    ["|C"] = 9,
    ["|r"] = 1,
    ["|R"] = 1,
}

local function utf8shorten(str, length)
    if strlenutf8(str) <= length then
        return str
    end

    local index, output, z, y = 1, "", "" -- y and z are next-to-last and last seen characters
    for char in str:gmatch(".[\128-\191]*") do
        if char == "|" then
            length = length + 1 -- we want to peak at the next character
        end

        y = z
        z = char
        length = length + (ES_PADDING[y .. z] or 0)

        if index <= length then
            output = output .. char
            index = index + 1
        end

        if index > length then
            break
        end
    end

    return output
end
local function AbbreviateName(name, maxLength)
    if not name then return "" end
    local maxNameLength = maxLength or 12
    local length = strlenutf8(name)
    local words, newName = {_G.strsplit(" ", name)}
    if #words > 2 and strlenutf8(name) > maxNameLength then
        local i = 2
        repeat
            length = length - (strlenutf8(words[i]) - 2)
            words[i] = utf8shorten(words[i], 1) .. "."
            i = i + 1
        until length <= maxNameLength or i > #words

        newName = _G.strjoin(" ", _G.unpack(words))
    else
        newName = name
    end

    if strlenutf8(newName) > maxNameLength then
        newName = utf8shorten(newName, (maxNameLength + 2))..".."
    end
    return newName
end

------------------
------ Tags ------
------------------
-- Name
tags.Methods["realui:name"] = function(unit, realUnit)
    local isDead = false
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not(_G.UnitIsConnected(unit)) then
        isDead = true
    end

    local unitTag = unit:match("^(%w-)%d") or unit

    --local enUS,  zhTW,  zhCN,  ruRU,  koKR = "Account Level Mount", "帳號等級坐騎", "战网通行证通用坐骑", "Средство передвижения для всех персонажей учетной записи", "계정 공유 탈것"
    local name = _G.UnitName(unit) or ""
    if not RealUI.isSecret(name) then
        name = AbbreviateName(name, UnitFrames[unitTag].nameLength)
    end
    local nameColor = "|cffffffff"
    if isDead then
        nameColor = "|cff3f3f3f"
    elseif UnitFrames.db.profile.overlay.classColorNames then
        --print("Class color names", unit)
        local raidcolor = tags.Methods.raidcolor(unit)
        if raidcolor then
            nameColor = raidcolor
        end
    end
    return ("%s%s|r"):format(nameColor, name)
end
tags.Events["realui:name"] = "UNIT_NAME_UPDATE"

-- Level
tags.Methods["realui:level"] = function(unit, realUnit)
    local level = tags.Methods.level(unit, realUnit)
    if level == "??" then
        return ("|c%s%s|r"):format(RealUI.GetColorString(_G.QuestDifficultyColors.impossible), level)
    else
        return ("|c%s%s|r"):format(RealUI.GetColorString(_G.GetQuestDifficultyColor(level)), level)
    end
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
tags.Events["realui:healthValue"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED"

-- Health %
tags.Methods["realui:healthPercent"] = function(unit)
    local percent
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not(_G.UnitIsConnected(unit)) then
        percent = 0
    else
        if _G.UnitHealthPercent and _G.CurveConstants and _G.CurveConstants.ScaleTo100 then
            percent = _G.UnitHealthPercent(unit, true, _G.CurveConstants.ScaleTo100)
            if RealUI.isSecret(percent) then
                percent = nil
            end
        end
        if not percent and _G.UnitHealthPercent then
            percent = _G.UnitHealthPercent(unit, true)
            if RealUI.isSecret(percent) then
                percent = nil
            end
        end
        if (not percent or percent == 0) and oUF and oUF.objects then
            for i = 1, #oUF.objects do
                local frame = oUF.objects[i]
                if frame and frame.unit == unit and frame.Health then
                    local cur = frame.Health.cur
                    local max = frame.Health.max
                    if cur and max and not RealUI.isSecret(cur) and not RealUI.isSecret(max) and max > 0 then
                        percent = cur / max
                    elseif frame.Health.GetVisualPercent then
                        local visPercent = frame.Health:GetVisualPercent()
                        if visPercent then
                            percent = visPercent
                        end
                    end
                    break
                end
            end
        end
        if not percent then
            percent = 0
        elseif percent <= 1 then
            percent = percent * 100
        end
    end
    UnitFrames:debug("realui:healthPercent", percent)
    return ("%d|c%s%%|r"):format(percent, RealUI.GetColorString(oUF.colors.health))
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
        local powerType = _G.UnitPowerType(unit)
        if _G.UnitPowerPercent and _G.CurveConstants and _G.CurveConstants.ScaleTo100 then
            percent = _G.UnitPowerPercent(unit, powerType, true, _G.CurveConstants.ScaleTo100)
            if RealUI.isSecret(percent) then
                percent = nil
            end
        end
        if not percent and _G.UnitPowerPercent then
            percent = _G.UnitPowerPercent(unit, powerType, true)
            if RealUI.isSecret(percent) then
                percent = nil
            end
        end
        if (not percent or percent == 0) and oUF and oUF.objects then
            for i = 1, #oUF.objects do
                local frame = oUF.objects[i]
                if frame and frame.unit == unit and frame.Power then
                    local cur = frame.Power.cur
                    local max = frame.Power.max
                    if cur and max and not RealUI.isSecret(cur) and not RealUI.isSecret(max) and max > 0 then
                        percent = cur / max
                    elseif frame.Power.GetVisualPercent then
                        local visPercent = frame.Power:GetVisualPercent()
                        if visPercent then
                            percent = visPercent
                        end
                    end
                    break
                end
            end
        end
        if not percent then
            percent = 0
        elseif percent <= 1 then
            percent = percent * 100
        end
    end
    local _, ptoken = _G.UnitPowerType(unit)
    return ("%d|c%s%%|r"):format(percent, RealUI.GetColorString(oUF.colors.power[ptoken]))
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
    local color = tags.Methods["threatcolor"](unit)
    local isTanking, _, _, percentage = _G.UnitDetailedThreatSituation("player", "target")

    if percentage and not _G.UnitIsDeadOrGhost(unit) then
        if isTanking then
            percentage = _G.UnitThreatPercentageOfLead("player", "target")
        end

        if percentage and percentage ~= 0 then
            UnitFrames:debug("threat", color, isTanking, percentage)
            -- if RealUI.isDev then
            --     _G.print(("Current threat: - %s%1.0f%%|r"):format(color, percentage))
            -- end
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

local rangeCheck = _G.LibStub("LibRangeCheck-3.0")
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
