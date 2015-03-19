local LSM = LibStub("LibSharedMedia-3.0")

-- -----
-- BACKGROUND
-- -----
LSM:Register("background", "Plain", [[Interface\AddOns\nibRealUI\Media\Plain]])
LSM:Register("background", "Plain80", [[Interface\AddOns\nibRealUI\Media\Plain80]])
LSM:Register("background", "Plain90", [[Interface\AddOns\nibRealUI\Media\Plain90]])

-- -----
--  BORDER
-- ----
LSM:Register("border", "Black", [[Interface\AddOns\SharedMedia_MyMedia\border\Black]])
LSM:Register("border", "Seerah Solid", [[Interface\AddOns\SharedMedia_MyMedia\border\SeerahSolidBorder]])

-- -----
--   FONT
-- -----
local LOCALE_MASK = LSM.LOCALE_BIT_koKR + LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_zhCN + LSM.LOCALE_BIT_zhTW + LSM.LOCALE_BIT_western
LSM:Register("font", "pixel_small", [[Interface\AddOns\nibRealUI\Fonts\pixel_small.ttf]])
LSM:Register("font", "pixel_large", [[Interface\AddOns\nibRealUI\Fonts\pixel_large.ttf]])
LSM:Register("font", "pixel_numbers", [[Interface\AddOns\nibRealUI\Fonts\pixel_numbers.ttf]], LOCALE_MASK)
LSM:Register("font", "pixel_cooldown", [[Interface\AddOns\nibRealUI\Fonts\pixel_cooldown.ttf]], LOCALE_MASK)
LSM:Register("font", "pixel_crits", [[Interface\AddOns\nibRealUI\Fonts\pixel_crits.ttf]])

LOCALE_MASK = LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western
LSM:Register("font", "Roboto", [[Interface\AddOns\nibRealUI\Fonts\Roboto-Regular.ttf]], LOCALE_MASK)
LSM:Register("font", "Roboto Bold-Italic", [[Interface\AddOns\nibRealUI\Fonts\Roboto-BoldItalic.ttf]], LOCALE_MASK)
LSM:Register("font", "Roboto Condensed", [[Interface\AddOns\nibRealUI\Fonts\RobotoCondensed-Regular.ttf]], LOCALE_MASK)
LSM:Register("font", "Roboto Slab", [[Interface\AddOns\nibRealUI\Fonts\RobotoSlab-Regular.ttf]], LOCALE_MASK)

LSM:Register("font", "Standard", [[Interface\AddOns\nibRealUI\Fonts\standard.ttf]], LOCALE_MASK)
LSM:Register("font", "Standard Regular", [[Interface\AddOns\nibRealUI\Fonts\standard_regular.ttf]], LOCALE_MASK)
LSM:Register("font", "Standard Medium", [[Interface\AddOns\nibRealUI\Fonts\standard_medium.ttf]], LOCALE_MASK)

-- ruRU
LSM:Register("font", "Standard RU", [[Interface\AddOns\nibRealUI\Fonts\standard.ttf]], 2)
LSM:Register("font", "Standard Regular RU", [[Interface\AddOns\nibRealUI\Fonts\standard_regular.ttf]], 2)
LSM:Register("font", "Standard Medium RU", [[Interface\AddOns\nibRealUI\Fonts\standard_medium.ttf]], 2)

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
-- -----
--   SOUND
-- -----

-- -----
--   STATUSBAR
-- -----
LSM:Register("statusbar", "Plain", [[Interface\AddOns\nibRealUI\Media\Plain]])
LSM:Register("statusbar", "Plain80", [[Interface\AddOns\nibRealUI\Media\Plain80]])
LSM:Register("statusbar", "Plain90", [[Interface\AddOns\nibRealUI\Media\Plain90]])
LSM:Register("statusbar", "Plain_Dark", [[Interface\AddOns\nibRealUI\Media\Plain80]])
