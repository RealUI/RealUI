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
    return _G.oUFembed.RGBColorGradient(curDura, maxDura or 1, 0.9,0.1,0.1, 0.9,0.9,0.1, 0.1,0.9,0.1)
end

local scanningTooltip = _G.CreateFrame("GameTooltip", "RealUIScanningTooltip", _G.UIParent, "GameTooltipTemplate")
scanningTooltip:SetOwner(_G.UIParent, "ANCHOR_NONE")

local itemLevelPattern = _G.ITEM_LEVEL:gsub("%%d", "(%%d+)")
function RealUI.GetItemLevel(itemLink)
    scanningTooltip:ClearLines()
    local success = _G.pcall(scanningTooltip.SetHyperlink, scanningTooltip, itemLink)
    if not success then
        return 0
    end

    local iLvl
    for i = 1, 5 do
        local l = _G["RealUIScanningTooltipTextLeft"..i]
        if l and l:GetText() then
            iLvl = _G.tonumber(l:GetText():match(itemLevelPattern))
            if iLvl then break end
        end
    end

    return iLvl or 0
end

--[[ Fonts
    SystemFont_Shadow_Med1
    SystemFont_Shadow_Med1_Outline
    NumberFont_Outline_Med
    Fancy16Font
]]

local LSM = _G.LibStub("LibSharedMedia-3.0")
LSM:Register("font", "Font Awesome", [[Interface\AddOns\RealUI_Skins\Media\fontawesome-webfont.ttf]])

-- Russian + Latin char languages
local LOCALE_MASK = LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western
LSM:Register("font", "Roboto", [[Interface\AddOns\RealUI_Skins\Media\Roboto-Regular.ttf]], LOCALE_MASK)
LSM:Register("font", "Roboto Bold-Italic", [[Interface\AddOns\RealUI_Skins\Media\Roboto-BoldItalic.ttf]], LOCALE_MASK)
LSM:Register("font", "Roboto Condensed", [[Interface\AddOns\RealUI_Skins\Media\RobotoCondensed-Regular.ttf]], LOCALE_MASK)
LSM:Register("font", "Roboto Slab", [[Interface\AddOns\RealUI_Skins\Media\RobotoSlab-Regular.ttf]], LOCALE_MASK)

-- Pixel fonts because some people like them
LOCALE_MASK = LSM.LOCALE_BIT_koKR + LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_zhCN + LSM.LOCALE_BIT_zhTW + LSM.LOCALE_BIT_western
LSM:Register("font", "pixel_small", [[Interface\AddOns\RealUI_Skins\Media\pixel_small.ttf]])
LSM:Register("font", "pixel_large", [[Interface\AddOns\RealUI_Skins\Media\pixel_large.ttf]])
LSM:Register("font", "pixel_numbers", [[Interface\AddOns\RealUI_Skins\Media\pixel_numbers.ttf]], LOCALE_MASK)
LSM:Register("font", "pixel_cooldown", [[Interface\AddOns\RealUI_Skins\Media\pixel_cooldown.ttf]], LOCALE_MASK)
LSM:Register("font", "pixel_crits", [[Interface\AddOns\RealUI_Skins\Media\pixel_crits.ttf]])

LSM.DefaultMedia.font = "Roboto"
private.fontNames = {
    normal = "Roboto",
    chat = "Roboto Condensed",
    crit = "Roboto Bold-Italic",
    header = "Roboto Slab",
}
if RealUI.InitAsianFonts then
    private.fontNames = RealUI:InitAsianFonts(LSM)
end


--[[ Backgrounds ]]--
LSM:Register("background", "Plain", [[Interface\Buttons\WHITE8x8]])

--[[ Statusbars ]]--
LSM:Register("statusbar", "Plain", [[Interface\Buttons\WHITE8x8]])

--[[ Borders ]]--
LSM:Register("border", "Plain", [[Interface\Buttons\WHITE8x8]])
