local _, private = ...

-- Libs --
local oUF = private.oUF
if not oUF then
    _G.print("|cffff0000[RealUI Tags] ERROR: private.oUF is nil — tags will not register|r")
    return
end
local tags = oUF.Tags
if not tags then
    _G.print("|cffff0000[RealUI Tags] ERROR: oUF.Tags is nil — tags will not register|r")
    return
end
local Color = _G.Aurora.Color

-- RealUI --
local RealUI = private.RealUI

local UnitFrames = RealUI:GetModule("UnitFrames")

----------------------------------
------ Tag String Composers ------
----------------------------------
function UnitFrames.GetHealthTagString(statusText)
    if statusText == "perc" or statusText == "smart" then
        return "[realui:healthcolor][realui:healthPercent<$%]"
    elseif statusText == "value" or statusText == "abs" then
        return "[realui:healthcolor][realui:healthValue]"
    elseif statusText == "both" then
        return "[realui:healthcolor][realui:healthPercent<$%] - [realui:healthcolor][realui:healthValue]"
    end
    -- Fallback to percentage if unknown statusText
    return "[realui:healthcolor][realui:healthPercent<$%]"
end

function UnitFrames.GetPowerTagString(statusText, powerType)
    if powerType ~= "MANA" then
        return "[powercolor][realui:powerValue]"
    end
    if statusText == "perc" or statusText == "smart" then
        return "[powercolor][realui:powerPercent<$%]"
    elseif statusText == "value" or statusText == "abs" then
        return "[powercolor][realui:powerValue]"
    elseif statusText == "both" then
        return "[powercolor][realui:powerPercent<$%] - [powercolor][realui:powerValue]"
    end
    -- Fallback to percentage if unknown statusText
    return "[powercolor][realui:powerPercent<$%]"
end

------------------
------ Tags ------
------------------

-- Health Color
tags.Methods["realui:healthcolor"] = function(unit)
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not _G.UnitIsConnected(unit) then
        return "|cff3f3f3f"
    end
    return ("|c%s"):format(RealUI.GetColorString(oUF.colors.health))
end
tags.Events["realui:healthcolor"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_CONNECTION"

-- Health Percent
tags.Methods["realui:healthPercent"] = function(unit)
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not _G.UnitIsConnected(unit) then
        return "0"
    end
    return _G.string.format('%d', _G.UnitHealthPercent(unit, true, _G.CurveConstants.ScaleTo100))
end
tags.Events["realui:healthPercent"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED"

-- Health Absolute Value
tags.Methods["realui:healthValue"] = function(unit)
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not _G.UnitIsConnected(unit) then
        return "0"
    end
    local health = _G.UnitHealth(unit)
    if not _G.issecretvalue(health) then
        return RealUI.ReadableNumber(health)
    end
    return _G.string.format('%d', health)
end
tags.Events["realui:healthValue"] = "UNIT_HEALTH UNIT_MAXHEALTH UNIT_TARGETABLE_CHANGED"

-- Power Percent
tags.Methods["realui:powerPercent"] = function(unit)
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not _G.UnitIsConnected(unit) then
        return "0"
    end
    local powerType = _G.UnitPowerType(unit)
    return _G.string.format('%d', _G.UnitPowerPercent(unit, powerType, true, _G.CurveConstants.ScaleTo100))
end
tags.Events["realui:powerPercent"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER UNIT_TARGETABLE_CHANGED"

-- Power Absolute Value
tags.Methods["realui:powerValue"] = function(unit)
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not _G.UnitIsConnected(unit) then
        return "0"
    end
    local power = _G.UnitPower(unit)
    if not _G.issecretvalue(power) then
        return RealUI.ReadableNumber(power)
    end
    return _G.string.format('%d', power)
end
tags.Events["realui:powerValue"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER UNIT_TARGETABLE_CHANGED"

-- Name
tags.Methods["realui:name"] = function(unit)
    local name = _G.UnitName(unit) or ""
    local unitTag = unit:match("^(%w-)%d") or unit
    if not _G.issecretvalue(name) then
        local maxLen = UnitFrames[unitTag] and UnitFrames[unitTag].nameLength
        if maxLen and #name > maxLen then
            name = name:sub(1, maxLen) .. "..."
        end
    end
    local nameColor = "|cffffffff"
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not _G.UnitIsConnected(unit) then
        nameColor = "|cff3f3f3f"
    elseif UnitFrames.db.profile.overlay.classColorNames then
        nameColor = tags.Methods.raidcolor(unit) or nameColor
    end
    return ("%s%s|r"):format(nameColor, name)
end
tags.Events["realui:name"] = "UNIT_NAME_UPDATE"

-- Level
tags.Methods["realui:level"] = function(unit, realUnit)
    local level = tags.Methods.level(unit, realUnit)
    if level == "??" then
        return ("|cff%02x%02x%02x%s|r"):format(255, 0, 0, level)
    end
    local color = _G.GetCreatureDifficultyColor(level)
    return ("|cff%02x%02x%02x%s|r"):format(color.r * 255, color.g * 255, color.b * 255, level)
end
tags.Events["realui:level"] = "UNIT_LEVEL PLAYER_LEVEL_UP"

-- PvP Timer
tags.Methods["realui:pvptimer"] = function()
    if not _G.IsPVPTimerRunning() then return "" end
    return _G.SecondsToClock(_G.math.floor(_G.GetPVPTimer() / 1000))
end
tags.Events["realui:pvptimer"] = "UNIT_FACTION PLAYER_FLAGS_CHANGED"

-- Colored Threat Percent
tags.Methods["realui:threat"] = function(unit)
    local color = tags.Methods["threatcolor"](unit)
    local isTanking, _, _, percentage = _G.UnitDetailedThreatSituation("player", "target")
    if percentage and not _G.UnitIsDeadOrGhost(unit) then
        if isTanking then
            percentage = _G.UnitThreatPercentageOfLead("player", "target")
        end
        if percentage and percentage ~= 0 then
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

local rangeCheck
do
    local ok, lib = _G.pcall(_G.LibStub, "LibRangeCheck-3.0")
    if ok then rangeCheck = lib end
end
tags.Methods["realui:range"] = function()
    if not rangeCheck then return end
    local _, maxRange = rangeCheck:GetRange("target")
    if maxRange and not _G.UnitIsUnit("target", "player") then
        local section
        if maxRange <= 5 then section = 5
        elseif maxRange <= 30 then section = 30
        elseif maxRange <= 35 then section = 35
        elseif maxRange <= 40 then section = 40
        elseif maxRange <= 50 then section = 50
        else section = 100
        end
        local color = rangeColors[section]
        if color and color.colorStr then
            return ("|c%s%d|r"):format(color.colorStr, maxRange)
        end
    end
end

-- Diagnostic: confirm tags registered
if tags.Methods["realui:healthValue"] then
    _G.print("|cff00ff00[RealUI Tags] All tags registered successfully|r")
else
    _G.print("|cffff0000[RealUI Tags] ERROR: tags.Methods['realui:healthValue'] is nil after registration|r")
end
