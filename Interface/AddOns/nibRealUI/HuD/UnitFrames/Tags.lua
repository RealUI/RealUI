local _, private = ...

-- Lua Globals --
local _G = _G

-- Libs --
local oUF = _G.oUFembed
local tags = oUF.Tags

-- RealUI --
local RealUI = private.RealUI

local UnitFrames = RealUI:GetModule("UnitFrames")

------------------
------ Tags ------
------------------
-- Name
tags.Methods["realui:name"] = function(unit)
    local isDead = false
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not(_G.UnitIsConnected(unit)) then
        isDead = true
    end

    local unitTag = unit:match("(boss)%d?$") or unit
                            -- enUS,    zhTW,   zhCN,   ruRU, koKR
    --local test1, test2, test3, test4, test5 = "Account Level Mount", "帳號等級坐騎", "战网通行证通用坐骑", "Средство передвижения для всех персонажей учетной записи", "계정 공유 탈것"
    --local test = test3
    local name = UnitFrames:AbrvName(_G.UnitName(unit)--[[test]], unitTag) --

    local nameColor = "ffffff"
    if isDead then
        nameColor = "3f3f3f"
    elseif UnitFrames.db.profile.overlay.classColorNames then 
        --print("Class color names", unit)
        local _, class = _G.UnitClass(unit)
        nameColor = RealUI:ColorTableToStr(RealUI:GetClassColor(class))
    end
    return ("|cff%s%s|r"):format(nameColor, name)
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
        levelColor = _G.GetQuestDifficultyColor(105)
    else
        levelColor = _G.GetQuestDifficultyColor(level)
    end
    return ("|cff%02x%02x%02x%s|r"):format(levelColor.r * 255, levelColor.g * 255, levelColor.b * 255, level)
end
tags.Events["realui:level"] = "UNIT_NAME_UPDATE"

-- PvP Timer
tags.Methods["realui:pvptimer"] = function(unit)
    --print("Tag:pvptimer", unit)
    if not _G.IsPVPTimerRunning() then return "" end

    return RealUI:ConvertSecondstoTime(_G.floor(_G.GetPVPTimer() / 1000))
end
tags.Events["realui:pvptimer"] = "UNIT_FACTION PLAYER_FLAGS_CHANGED"



-- Health AbsValue
tags.Methods["realui:healthValue"] = function(unit)
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not(_G.UnitIsConnected(unit)) then return 0 end

    return RealUI:ReadableNumber(_G.UnitHealth(unit))
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
    return ("%.1f|cff%s%%|r"):format(percent, RealUI:ColorTableToStr(oUF.colors.health))
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

    return RealUI:ReadableNumber(_G.UnitPower(unit))
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
    return ("%.1f|cff%s%%|r"):format(percent, RealUI:ColorTableToStr(oUF.colors.power[ptoken]))
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
