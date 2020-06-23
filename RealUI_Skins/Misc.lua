local _, private = ...

local RealUI = _G.RealUI

--[[ Fonts
    SystemFont_Shadow_Med1
    SystemFont_Shadow_Med1_Outline
    NumberFont_Outline_Med
    Fancy16Font
]]

local LSM = _G.LibStub("LibSharedMedia-3.0")

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

-- Misc Fonts
LSM:Register("font", "Font Awesome", [[Interface\AddOns\RealUI_Skins\Media\fontawesome-webfont.ttf]], LOCALE_MASK)
LSM:Register("font", "DejaVu Sans", [[Interface\AddOns\RealUI_Skins\Media\DejaVuSans.ttf]], LOCALE_MASK)

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
LSM:Register("background", "Plain", private.textures.plain)

--[[ Statusbars ]]--
LSM:Register("statusbar", "Plain", private.textures.plain)

--[[ Borders ]]--
LSM:Register("border", "Plain", private.textures.plain)
