-- Lua Globals --
-- luacheck: globals floor type

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

-- Asian fonts: These are specific to each language
-- zhTW
LSM:Register("font", "Noto Sans Bold", [[Interface\AddOns\nibRealUI\Fonts\NotoSansCJKtc-Bold.otf]], LSM.LOCALE_BIT_zhTW)
LSM:Register("font", "Noto Sans Light", [[Interface\AddOns\nibRealUI\Fonts\NotoSansCJKtc-Light.otf]], LSM.LOCALE_BIT_zhTW)
LSM:Register("font", "Noto Sans Regular", [[Interface\AddOns\nibRealUI\Fonts\NotoSansCJKtc-Regular.otf]], LSM.LOCALE_BIT_zhTW)
-- zhCN
LSM:Register("font", "Noto Sans Bold", [[Interface\AddOns\nibRealUI\Fonts\NotoSansCJKsc-Bold.otf]], LSM.LOCALE_BIT_zhCN)
LSM:Register("font", "Noto Sans Light", [[Interface\AddOns\nibRealUI\Fonts\NotoSansCJKsc-Light.otf]], LSM.LOCALE_BIT_zhCN)
LSM:Register("font", "Noto Sans Regular", [[Interface\AddOns\nibRealUI\Fonts\NotoSansCJKsc-Regular.otf]], LSM.LOCALE_BIT_zhCN)
-- koKR
LSM:Register("font", "Noto Sans Bold", [[Interface\AddOns\nibRealUI\Fonts\NotoSansCJKkr-Bold.otf]], LSM.LOCALE_BIT_koKR)
LSM:Register("font", "Noto Sans Light", [[Interface\AddOns\nibRealUI\Fonts\NotoSansCJKkr-Light.otf]], LSM.LOCALE_BIT_koKR)
LSM:Register("font", "Noto Sans Regular", [[Interface\AddOns\nibRealUI\Fonts\NotoSansCJKkr-Regular.otf]], LSM.LOCALE_BIT_koKR)

if _G.LOCALE_enUS or _G.LOCALE_ruRU then
    LSM.DefaultMedia.font = "Roboto"
else
    LSM.DefaultMedia.font = "Noto Sans Regular"
end

-- Legacy fonts for anyone that has them stuck in saved vars
LSM:Register("font", "Standard", [[Interface\AddOns\RealUI_Skins\Media\Roboto-Regular.ttf]], LOCALE_MASK)
LSM:Register("font", "Standard Regular", [[Interface\AddOns\RealUI_Skins\Media\Roboto-Regular.ttf]], LOCALE_MASK)
LSM:Register("font", "Standard Medium", [[Interface\AddOns\RealUI_Skins\Media\Roboto-Regular.ttf]], LOCALE_MASK)

LOCALE_MASK = LSM.LOCALE_BIT_koKR + LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_zhCN + LSM.LOCALE_BIT_zhTW + LSM.LOCALE_BIT_western
LSM:Register("font", "pixel_small", [[Interface\AddOns\RealUI_Skins\Media\pixel_small.ttf]])
LSM:Register("font", "pixel_large", [[Interface\AddOns\RealUI_Skins\Media\pixel_large.ttf]])
LSM:Register("font", "pixel_numbers", [[Interface\AddOns\RealUI_Skins\Media\pixel_numbers.ttf]], LOCALE_MASK)
LSM:Register("font", "pixel_cooldown", [[Interface\AddOns\RealUI_Skins\Media\pixel_cooldown.ttf]], LOCALE_MASK)
LSM:Register("font", "pixel_crits", [[Interface\AddOns\RealUI_Skins\Media\pixel_crits.ttf]])


--[[ Backgrounds ]]--
LSM:Register("background", "Plain", [[Interface\Buttons\WHITE8x8]])

--[[ Statusbars ]]--
LSM:Register("statusbar", "Plain", [[Interface\Buttons\WHITE8x8]])

--[[ Borders ]]--
LSM:Register("border", "Plain", [[Interface\Buttons\WHITE8x8]])
