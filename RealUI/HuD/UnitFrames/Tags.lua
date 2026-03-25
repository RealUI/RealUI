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

-- Abbreviation config: use CreateAbbreviateConfig for cached performance
-- AbbreviateNumbers accepts secret values natively (no string conversion needed)
local abbrevBreakpoints = {
    { breakpoint = 1e12, abbreviation = "B", significandDivisor = 1e10, fractionDivisor = 100, abbreviationIsGlobal = false },
    { breakpoint = 1e11, abbreviation = "B", significandDivisor = 1e9,  fractionDivisor = 1,   abbreviationIsGlobal = false },
    { breakpoint = 1e10, abbreviation = "B", significandDivisor = 1e8,  fractionDivisor = 10,  abbreviationIsGlobal = false },
    { breakpoint = 1e9,  abbreviation = "B", significandDivisor = 1e7,  fractionDivisor = 100, abbreviationIsGlobal = false },
    { breakpoint = 1e8,  abbreviation = "M", significandDivisor = 1e6,  fractionDivisor = 1,   abbreviationIsGlobal = false },
    { breakpoint = 1e7,  abbreviation = "M", significandDivisor = 1e5,  fractionDivisor = 10,  abbreviationIsGlobal = false },
    { breakpoint = 1e6,  abbreviation = "M", significandDivisor = 1e4,  fractionDivisor = 100, abbreviationIsGlobal = false },
    { breakpoint = 1e5,  abbreviation = "K", significandDivisor = 1000, fractionDivisor = 1,   abbreviationIsGlobal = false },
    { breakpoint = 1e4,  abbreviation = "K", significandDivisor = 100,  fractionDivisor = 10,  abbreviationIsGlobal = false },
}
local abbrevConfig = _G.CreateAbbreviateConfig and _G.CreateAbbreviateConfig(abbrevBreakpoints)
local abbrevData = { breakpointData = abbrevBreakpoints, config = abbrevConfig }

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
    local tc = UnitFrames.db and UnitFrames.db.profile.misc.textColors
    local colorTag = (tc and tc.power) and "[realui:customPowerColor]" or "[powercolor]"
    if powerType ~= "MANA" then
        return colorTag .. "[realui:powerValue]"
    end
    if statusText == "perc" or statusText == "smart" then
        return colorTag .. "[realui:powerPercent<$%]"
    elseif statusText == "value" or statusText == "abs" then
        return colorTag .. "[realui:powerValue]"
    elseif statusText == "both" then
        return colorTag .. "[realui:powerPercent<$%] - " .. colorTag .. "[realui:powerValue]"
    end
    -- Fallback to percentage if unknown statusText
    return colorTag .. "[realui:powerPercent<$%]"
end

------------------
------ Tags ------
------------------

-- Health Color
tags.Methods["realui:healthcolor"] = function(unit)
    if _G.UnitIsDead(unit) or _G.UnitIsGhost(unit) or not _G.UnitIsConnected(unit) then
        return "|cff3f3f3f"
    end
    local c = UnitFrames.db.profile.misc.textColors and UnitFrames.db.profile.misc.textColors.health
    if c then
        return ("|cff%02x%02x%02x"):format(c[1] * 255, c[2] * 255, c[3] * 255)
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
    return _G.AbbreviateNumbers(_G.UnitHealth(unit), abbrevData)
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
    return _G.AbbreviateNumbers(_G.UnitPower(unit), abbrevData)
end
tags.Events["realui:powerValue"] = "UNIT_POWER_FREQUENT UNIT_MAXPOWER UNIT_DISPLAYPOWER UNIT_TARGETABLE_CHANGED"

-- Custom Power Color (uses custom textColors.power if set, otherwise delegates to powercolor)
tags.Methods["realui:customPowerColor"] = function(unit)
    local c = UnitFrames.db.profile.misc.textColors and UnitFrames.db.profile.misc.textColors.power
    if c then
        return ("|cff%02x%02x%02x"):format(c[1] * 255, c[2] * 255, c[3] * 255)
    end
    return tags.Methods["powercolor"](unit)
end
tags.Events["realui:customPowerColor"] = "UNIT_POWER_FREQUENT UNIT_DISPLAYPOWER"

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
    else
        local nameColorSetting = UnitFrames.db.profile.misc.textColors and UnitFrames.db.profile.misc.textColors.name
        if nameColorSetting then
            nameColor = ("|cff%02x%02x%02x"):format(nameColorSetting[1] * 255, nameColorSetting[2] * 255, nameColorSetting[3] * 255)
        elseif UnitFrames.db.profile.overlay.classColorNames then
            nameColor = tags.Methods.raidcolor(unit) or nameColor
        end
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
