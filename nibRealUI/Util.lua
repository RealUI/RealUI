local _, private = ...

-- Lua Globals --
-- luacheck: globals floor type pcall tonumber

local RealUI = _G.RealUI

local addonDB = {}
function RealUI:RegisterAddOnDB(addon, db)
    if not addonDB[addon] then
        addonDB[addon] = db
    end
end
function RealUI:GetAddOnDB(addon)
    return addonDB[addon]
end

if not private.oUF then
    private.oUF = _G.oUF
end


----====####$$$$%%%%$$$$####====----
--              Math              --
----====####$$$$%%%%$$$$####====----
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


----====####$$$$%%%%%$$$$####====----
--              Color              --
----====####$$$$%%%%%$$$$####====----
local hexColor = "%02x%02x%02x"
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

function RealUI.GetDurabilityColor(curDura, maxDura)
    local low, mid, high = _G.Aurora.Color.red, _G.Aurora.Color.yellow, _G.Aurora.Color.blue
    return private.oUF:RGBColorGradient(curDura, maxDura or 1, low.r,low.g,low.b, mid.r,mid.g,mid.b, high.r,high.g,high.b)
end


----====####$$$$%%%%%$$$$####====----
--          Miscellaneous          --
----====####$$$$%%%%%$$$$####====----
local scanningTooltip = _G.CreateFrame("GameTooltip", "RealUIScanningTooltip", _G.UIParent, "GameTooltipTemplate")
scanningTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")

local cache = {}
local itemLevelPattern = _G.ITEM_LEVEL:gsub("%%d", "(%%d+)")
function RealUI.GetItemLevel(itemLink)
    if cache[itemLink] then
        return cache[itemLink]
    end

    scanningTooltip:ClearLines()
    local success = pcall(scanningTooltip.SetHyperlink, scanningTooltip, itemLink)
    if not success then
        return 0
    end

    local iLvl
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

function RealUI.GetOptions(modName, path)
    local options = RealUI:GetModule(modName).db
    for i = 1, #path do
        options = options[path[i]]
    end
    return options
end
