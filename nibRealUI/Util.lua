local _, private = ...

-- Lua Globals --
-- luacheck: globals type pcall tonumber next
-- luacheck: globals tinsert tremove unpack
-- luacheck: globals floor min max math abs

local RealUI = _G.RealUI

if not private.oUF then
    private.oUF = _G.oUF
end


----====####$$$$%%%%%$$$$####====----
--          Compatibility          --
----====####$$$$%%%%%$$$$####====----
local Enum = {}
Enum.ItemQuality = {
    Poor = _G.LE_ITEM_QUALITY_POOR or _G.Enum.ItemQuality.Poor,
    Standard = _G.LE_ITEM_QUALITY_COMMON or _G.Enum.ItemQuality.Standard,
    Good = _G.LE_ITEM_QUALITY_UNCOMMON or _G.Enum.ItemQuality.Good,
    Superior = _G.LE_ITEM_QUALITY_RARE or _G.Enum.ItemQuality.Superior,
    Epic = _G.LE_ITEM_QUALITY_EPIC or _G.Enum.ItemQuality.Epic,
    Legendary = _G.LE_ITEM_QUALITY_LEGENDARY or _G.Enum.ItemQuality.Legendary,
    Artifact = _G.LE_ITEM_QUALITY_ARTIFACT or _G.Enum.ItemQuality.Artifact,
    Heirloom = _G.LE_ITEM_QUALITY_HEIRLOOM or _G.Enum.ItemQuality.Heirloom,
    WoWToken = _G.LE_ITEM_QUALITY_WOW_TOKEN or _G.Enum.ItemQuality.WoWToken,
}
RealUI.Enum = Enum


----====####$$$$%%%%%$$$$####====----
--             Numbers             --
----====####$$$$%%%%%$$$$####====----
function RealUI.Round(value, places)
    local mult = 10 ^ (places or 0)
    return floor(value * mult + 0.5) / mult
end
function RealUI.GetSafeVals(min, max)
    if max == 0 then
        return 0
    else
        return min / max
    end
end
function RealUI.ReadableNumber(value)
    local retString = _G.tostring(value)
    local strLen = retString:len()
    if strLen > 8 then
        retString = _G.BreakUpLargeNumbers(retString:sub(1, -7)).._G.SECOND_NUMBER_CAP
    elseif strLen > 6 then
        retString = ("%.2f"):format(value / 1000000).._G.SECOND_NUMBER_CAP
    elseif strLen > 5 then
        retString = retString:sub(1, -4).._G.FIRST_NUMBER_CAP
    elseif strLen > 4 then
        retString = ("%.1f"):format(value / 1000).._G.FIRST_NUMBER_CAP
    elseif strLen > 3 then
        retString = _G.BreakUpLargeNumbers(value)
    end
    return retString
end


----====####$$$$%%%%%$$$$####====----
--              Color              --
----====####$$$$%%%%%$$$$####====----
local hexColor = "ff%02x%02x%02x"
function RealUI.GetColorString(red, green, blue)
    if type(red) == "table" then
        if red.r and red.g and red.b then
            red, green, blue = red.r, red.g, red.b
        else
            red, green, blue = red[1], red[2], red[3]
        end
    end

    return hexColor:format(red * 255, green * 255, blue * 255)
end

function RealUI.ColorGradient(percent, colors)
    local num = #colors

    if percent >= 1 then
        return colors[num]
    elseif percent <= 0 then
        return colors[0]
    end

    local segment, relperc = math.modf(percent * num)

    local r1, g1, b1, r2, g2, b2
    r1, g1, b1 = colors[segment]:GetRGB()
    r2, g2, b2 = colors[segment+1]:GetRGB()

    if ( not r2 or not g2 or not b2 ) then
        return colors[0]
    else
        local r = r1 + (r2-r1) * relperc
        local g = g1 + (g2-g1) * relperc
        local b = b1 + (b2-b1) * relperc

        return _G.Aurora.Color.Create(r, g, b, 1)
    end
end

local durabilityColors = {
    [0] = _G.CreateColor(1, 0, 0),
    [1] = _G.CreateColor(1, 1, 0),
    [2] = _G.CreateColor(0, 1, 0),
}
function RealUI.GetDurabilityColor(curDura, maxDura)
    return RealUI.ColorGradient(curDura / (maxDura or 1), durabilityColors)
end

--[[
All color functions assume arguments are within the range 0.0 - 1.0

Conversion functions based on code from
https://github.com/EmmanuelOga/columns/blob/master/utils/color.lua
]]
local HSLToRGB, RGBToHSL do
    local function HueToRBG(p, q, t)
        if t < 0   then t = t + 1 end
        if t > 1   then t = t - 1 end
        if t < 1/6 then return p + (q - p) * 6 * t end
        if t < 1/2 then return q end
        if t < 2/3 then return p + (q - p) * (2/3 - t) * 6 end
        return p
    end
    function HSLToRGB(h, s, l, a)
        local r, g, b

        if s <= 0 then
            return l, l, l, a -- achromatic
        else
            local q
            q = l < 0.5 and l * (1 + s) or l + s - l * s
            local p = 2 * l - q

            r = HueToRBG(p, q, h + 1/3)
            g = HueToRBG(p, q, h)
            b = HueToRBG(p, q, h - 1/3)
        end

        return r, g, b, a
    end

    function RGBToHSL(r, g, b)
        if type(r) == "table" then
            r, g, b = r.r or r[1], r.g or r[2], r.b or r[3]
        end
        local minVal, maxVal = min(r, g, b), max(r, g, b)
        local h, s, l

        l = (maxVal + minVal) / 2
        if maxVal == minVal then
            h, s = 0, 0 -- achromatic
        else
            local d = maxVal - minVal
            s = l > 0.5 and d / (2 - maxVal - minVal) or d / (maxVal + minVal)
            if maxVal == r then
                h = (g - b) / d
                if g < b then h = h + 6 end
            elseif maxVal == g then
                h = (b - r) / d + 2
            else
                h = (r - g) / d + 4
            end
            h = h / 6
        end
        return h, s, l
    end
end

function RealUI.ColorShift(delta, r, g, b)
    local h, s, l = RGBToHSL(r, g, b)
    local r2, g2, b2 = HSLToRGB(h + delta, s, l)
    if type(r) == "table" then
        if r.r then
            r.r, r.g, r.b = r2, g2, b2
        else
            r[1], r[2], r[3] = r2, g2, b2
        end
        return r
    else
        return r2, g2, b2
    end
end
function RealUI.ColorLighten(delta, r, g, b)
    local h, s, l = RGBToHSL(r, g, b)
    local r2, g2, b2 = HSLToRGB(h, s, _G.Clamp(l + delta, 0, 1))
    if type(r) == "table" then
        if r.r then
            r.r, r.g, r.b = r2, g2, b2
        else
            r[1], r[2], r[3] = r2, g2, b2
        end
        return r
    else
        return r2, g2, b2
    end
end
function RealUI.ColorSaturate(delta, r, g, b)
    local h, s, l = RGBToHSL(r, g, b)
    local r2, g2, b2 = HSLToRGB(h, _G.Clamp(s + delta, 0, 1), l)
    if type(r) == "table" then
        if r.r then
            r.r, r.g, r.b = r2, g2, b2
        else
            r[1], r[2], r[3] = r2, g2, b2
        end
        return r
    else
        return r2, g2, b2
    end
end
function RealUI.ColorDarken(delta, r, g, b)
    return RealUI.ColorLighten(-delta, r, g, b)
end
function RealUI.ColorDesaturate(delta, r, g, b)
    return RealUI.ColorSaturate(-delta, r, g, b)
end


----====####$$$$%%%%$$$$####====----
--         Character Info         --
----====####$$$$%%%%$$$$####====----
local scanningTooltip = _G.CreateFrame("GameTooltip", "RealUIScanningTooltip", _G.UIParent, "GameTooltipTemplate")
scanningTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")

local cache = {}
local itemLevelPattern = _G.ITEM_LEVEL:gsub("%%d", "(%%d+)")
function RealUI.GetItemLevel(itemLink)
    local iLvl = _G.GetDetailedItemLevelInfo(itemLink)
    if iLvl and iLvl > 0 then
        return iLvl
    end

    if cache[itemLink] then
        return cache[itemLink]
    end

    scanningTooltip:ClearLines()
    local success = pcall(scanningTooltip.SetHyperlink, scanningTooltip, itemLink)
    if not success then
        return 0
    end

    for i = 1, 5 do
        local l = _G["RealUIScanningTooltipTextLeft"..i]
        if l and l:GetText() then
            iLvl = tonumber(l:GetText():match(itemLevelPattern))
            if iLvl then
                cache[itemLink] = iLvl
                break
            end
        end
    end

    return iLvl or 0
end

function RealUI.GetCurrentLootSpecName()
    local lootSpec = _G.GetLootSpecialization()
    if lootSpec and lootSpec > 0 then
        local _, specName = _G.GetSpecializationInfoByID(lootSpec)
        return specName
    else
        return RealUI.charInfo.specs.current.name
    end
end

local spellFinder, numRun = _G.CreateFrame("FRAME"), 0
local function SpellPredicate(spellName, arg2, arg3, ...)
    local name, _, _, _, _, _, _, _, _, spellID = ...

    if spellName == name then
        _G.print(("The spellID for %s is %d"):format(spellName, spellID))
        numRun = numRun + 1
    end

    if numRun > 3 then
        numRun = 0
        spellFinder:UnregisterEvent("UNIT_AURA")
        return true
    end
end

-- /run RealUI.FindSpellID("Lone Wolf")
-- /run RealUI.FindSpellID("Windrunning")
function RealUI:FindSpellID(spellName, affectedUnit, auraType)
    affectedUnit = affectedUnit or "player"
    auraType = auraType or "buff"

    _G.print(("RealUI is now looking for %s %s: %s."):format(affectedUnit, auraType, spellName))
    spellFinder:RegisterUnitEvent("UNIT_AURA", affectedUnit)
    spellFinder:SetScript("OnEvent", function(frame, event, unit)
        local filter = (auraType == "buff" and "HELPFUL PLAYER" or "HARMFUL PLAYER")
        _G.AuraUtil.FindAura(SpellPredicate, unit, filter, spellName)
    end)
end


----====####$$$$%%%%$$$$####====----
--          Widget Utils          --
----====####$$$$%%%%$$$$####====----
function RealUI.SetPixelPoint(frame)
    local point, anchor, relPoint, x, y = frame:GetPoint()

    local modx, modY = RealUI.Round(x), RealUI.Round(y)
    local newX, newY
    if point == "CENTER" or point == "TOP" or point == "BOTTOM" then
        newX = RealUI.Round(x * 2) / 2
        local diff = abs(newX - modx)
        if not (diff > 0.4 and diff < 0.6) then
            newX = newX + 0.5
        end
    else
        newX = modx
    end

    if point == "CENTER" or point == "LEFT" or point == "RIGHT" then
        newY = RealUI.Round(y * 2) / 2
        local diff = abs(newY - modY)
        if not (diff > 0.4 and diff < 0.6) then
            newY = newY + 0.5
        end
    else
        newY = modY
    end

    frame:SetPoint(point, anchor, relPoint, newX, newY)
end

local function OnDragStart(frame, button)
    frame:ClearAllPoints()
    frame:StartMoving()
end
local function OnDragStop(frame, button)
    frame:StopMovingOrSizing()
    RealUI.SetPixelPoint(frame)
end
function RealUI.MakeFrameDraggable(frame, noClamp)
    frame:SetMovable(true)
    frame:RegisterForDrag("LeftButton")
    frame:SetClampedToScreen(not noClamp)
    frame:SetScript("OnDragStart", OnDragStart)
    frame:SetScript("OnDragStop", OnDragStop)
end


----====####$$$$%%%%%$$$$####====----
--          Miscellaneous          --
----====####$$$$%%%%%$$$$####====----
function RealUI.ShallowCopy(oldTable)
    local newTable = {}
    for k, v in next, oldTable do
        newTable[k] = v
    end
    return newTable
end
function RealUI.DeepCopy(object, seen)
    -- Handle non-tables and previously-seen tables.
    if type(object) ~= "table" then
        return object
    elseif seen and seen[object] then
        return seen[object]
    end

    -- New table; mark it as having seen the copy, recursively.
    local s = seen or {}
    local copy = _G.setmetatable({}, _G.getmetatable(object))
    s[object] = copy
    for key, value in next, object do
        copy[RealUI.DeepCopy(key, s)] = RealUI.DeepCopy(value, s)
    end
    return copy
end

local queue, args, alertShown = {}, {}
function RealUI.TryInCombat(func, alert, ...)
    if _G.InCombatLockdown() then
        if not args[func] then
            tinsert(queue, 1, func)
        end

        args[func] = {...}

        if not alertShown then
            RealUI:Notification(RealUI.L["Alert_CombatLockdown"], true, alert or RealUI.L["Alert_WaitCombatLockdown"], nil, [[Interface\DialogFrame\UI-Dialog-Icon-AlertNew]])
            alertShown = true
        end
    else
        func(...)
    end
end
_G.C_Timer.NewTicker(0.5, function()
    if #queue > 0 and not _G.InCombatLockdown() then
        local func = tremove(queue)
        func(unpack(args[func]))
        args[func] = nil

        alertShown = false
    end
end)

function RealUI.GetOptions(modName, path)
    local options = RealUI:GetModule(modName).db
    if path then
        for i = 1, #path do
            options = options[path[i]]
        end
    end
    return options
end
