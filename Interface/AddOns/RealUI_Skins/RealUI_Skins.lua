local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals floor next type tonumber max

local Aurora = private.Aurora
local RealUI = _G.RealUI

local debug = RealUI.GetDebug("Skins")
private.debug = debug

local defaults = {
    profile = {
        stripeAlpha = 0.5,
        frameAlpha = 0.7,
        uiModScale = 1,
        customScale = 1,
        isHighRes = false,
        isPixelScale = true,
        fonts = {
            normal = [[Interface\AddOns\nibRealUI\Fonts\Roboto\Roboto-Regular.ttf]],
            chat = [[Interface\AddOns\nibRealUI\Fonts\Roboto\RobotoCondensed-Regular.ttf]],
            crit = [[Interface\AddOns\nibRealUI\Fonts\Roboto\Roboto-BoldItalic.ttf]],
            header = [[Interface\AddOns\nibRealUI\Fonts\Roboto\RobotoSlab-Regular.ttf]],
        },
        addons = {
            ["**"] = true
        }
    }
}

RealUI.media = {
    colors = {
        red =       {0.85, 0.14, 0.14, 1},
        orange =    {1.00, 0.38, 0.08, 1},
        amber =     {1.00, 0.64, 0.00, 1},
        yellow =    {1.00, 1.00, 0.15, 1},
        green =     {0.13, 0.90, 0.13, 1},
        cyan =      {0.11, 0.92, 0.72, 1},
        blue =      {0.15, 0.61, 1.00, 1},
        purple =    {0.70, 0.28, 1.00, 1},
    },
    textures = {
        plain = [[Interface\Buttons\WHITE8x8]],
    },
}

local uiScaleChanging
local uiMod, pixelScale
function RealUI.UpdateUIScale(newScale)
    if uiScaleChanging then return end

    local _, pysHeight = _G.GetPhysicalScreenSize()
    uiMod = (pysHeight / 768) * (private.uiScale or 1)
    pixelScale = 768 / pysHeight

    -- Get Scale
    local oldScale = private.skinsDB.customScale
    if private.skinsDB.isPixelScale then
        newScale = pixelScale
    end

    local cvarScale, parentScale = tonumber(_G.GetCVar("uiscale")), RealUI.Round(_G.UIParent:GetScale(), 2)
    private.debug("scale", pixelScale, cvarScale, parentScale)

    if not newScale then
        newScale = _G.min(cvarScale, parentScale)
    end
    private.debug("newScale", newScale)

    local uiScale = newScale
    if private.skinsDB.isHighRes then
        uiScale = uiScale * 2
    end
    private.debug("uiScale", oldScale, uiScale)

    if oldScale ~= newScale or max(cvarScale, parentScale) ~= uiScale then
        uiScaleChanging = true
        -- Set Scale (WoW CVar can't go below .64)

        if cvarScale ~= uiScale then
            --[[ Setting the `uiScale` cvar will taint the ObjectiveTracker, and by extention the
                WorldMap and map action button. As such, we only use that if we absolutly have to.]]
            _G.SetCVar("uiScale", max(uiScale, 0.64))
        end
        if parentScale ~= uiScale then
            _G.UIParent:SetScale(uiScale)
        end
        private.skinsDB.customScale = newScale
        uiScaleChanging = false
    end
end

local Scale = {}
local previewFrames = {}
function RealUI.RegisterModdedFrame(frame, updateFunc)
    -- Frames that are sized via ModValue become HUGE with retina scale.
    if private.skinsDB.isHighRes then
        frame:SetScale(private.skinsDB.customScale)
    elseif private.skinsDB.customScale > pixelScale then
        frame:SetScale(pixelScale)
    end

    if updateFunc then
        previewFrames[frame] = updateFunc
    end
end
function RealUI.PreviewModScale()
    private.uiScale = private.skinsDB.uiModScale
    private.UpdateUIScale()
    for frame, func in next, previewFrames do
        func(frame)
    end
end

local skinnedFrames = {}
function RealUI:UpdateFrameStyle()
    local color = Aurora.frameColor
    for frame, stripes in next, skinnedFrames do
        if stripes.SetAlpha then
            frame:SetBackdropColor(color.r, color.g, color.b, private.skinsDB.frameAlpha)
            stripes:SetAlpha(private.skinsDB.stripeAlpha)
        end
    end
end

function private.OnLoad()
    --print("OnLoad Aurora", Aurora, private.Aurora)
    local skinsDB = _G.LibStub("AceDB-3.0"):New("RealUI_SkinsDB", defaults, true)
    private.skinsDB = skinsDB.profile

    -- Transfer settings
    if _G.RealUI_Storage.nibRealUI_Init then
        local RealUI_InitDB = _G.RealUI_Storage.nibRealUI_Init.RealUI_InitDB
        private.skinsDB.stripeAlpha = RealUI_InitDB.stripeOpacity
        private.skinsDB.uiModScale = RealUI_InitDB.uiModScale
        _G.RealUI_Storage.nibRealUI_Init = nil
    end

    if _G.RealUI_Storage.Aurora then
        local AuroraConfig = _G.RealUI_Storage.Aurora.AuroraConfig
        private.skinsDB.frameAlpha = AuroraConfig.alpha
        if type(AuroraConfig.customClassColors) == "table" then
            private.skinsDB.customClassColors = AuroraConfig.customClassColors
        end
        _G.RealUI_Storage.Aurora = nil
    end

    if _G.RealUI_Storage.nibRealUI then
        local profile = _G.RealUI_Storage.nibRealUI.nibRealUIDB.profiles.RealUI
        if profile and profile.media and profile.media.font then
            local font = profile.media.font
            if font.standard then
                private.skinsDB.fonts.normal = font.standard[4]
            end
            if font.chat then
                private.skinsDB.fonts.chat = font.chat[4]
            end
            if font.crit then
                private.skinsDB.fonts.crit = font.crit[4]
            end
            if font.header then
                private.skinsDB.fonts.header = font.header[4]
            end
            profile.media.font = nil
        end

        local global = _G.RealUI_Storage.nibRealUI.nibRealUIDB.global
        if global and global.retinaDisplay then
            private.skinsDB.isHighRes = global.retinaDisplay.set
            global.retinaDisplay = nil
        end

        local namespace = _G.RealUI_Storage.nibRealUI.nibRealUIDB.namespaces.UIScaler
        if namespace and namespace.profiles.RealUI then
            local customScale = _G.tonumber(namespace.profiles.RealUI.customScale)
            if customScale then
                private.skinsDB.customScale = customScale
            end
            private.skinsDB.isPixelScale = namespace.profiles.RealUI.pixelScale
            _G.RealUI_Storage.nibRealUI.nibRealUIDB.namespaces.UIScaler = nil
        end
    else
        _G.ReloadUI()
    end

    private.disabled.bags = true
    private.disabled.mainmenubar = true
    private.disabled.pixelScale = not private.skinsDB.isPixelScale

    private.uiScale = private.skinsDB.uiModScale
    private.UpdateUIScale = RealUI.UpdateUIScale
    if private.disabled.uiScale then
        RealUI.Scale = Scale
    else
        Aurora.Scale.Value = Scale.Value
        RealUI.Scale = Aurora.Scale
    end

    for fontType, fontPath in next, private.skinsDB.fonts do
        private.font[fontType] = fontPath
    end

    local Base, Hook = Aurora.Base, Aurora.Hook
    function Hook.GameTooltip_OnHide(gametooltip)
        local color = Aurora.frameColor
        Base.SetBackdropColor(gametooltip, color.r, color.g, color.b, private.skinsDB.frameAlpha)
    end

    function Base.Post.SetBackdrop(ret, frame, r, g, b, a)
        if not a then
            local color = Aurora.frameColor
            frame:SetBackdropColor(color.r, color.g, color.b, private.skinsDB.frameAlpha)

            local stripes = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
            stripes:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true, true)
            stripes:SetAlpha(private.skinsDB.stripeAlpha)
            stripes:SetAllPoints()
            stripes:SetHorizTile(true)
            stripes:SetVertTile(true)
            stripes:SetBlendMode("ADD")
            skinnedFrames[frame] = stripes
        end
    end

    for name, enabled in next, private.skinsDB.addons do
        if name ~= "nibRealUI" and not enabled then
            private.AddOns[name] = private.nop
        end
    end

    function private.AddOns.nibRealUI()
        RealUI:RegisterAddOnDB(ADDON_NAME, private.skinsDB)
        if _G.nibRealUIDB.profiles.RealUI then
            local profile = _G.nibRealUIDB.profiles.RealUI
            if profile.media.font then
                profile.media.font = nil
            end

            if _G.nibRealUIDB.global.retinaDisplay then
                _G.nibRealUIDB.global.retinaDisplay = nil
            end

            if _G.nibRealUIDB.namespaces.UIScaler then
                _G.nibRealUIDB.namespaces.UIScaler = nil
            end
        end
        if not _G.IsAddOnLoaded("Ace3") then
            private.AddOns.Ace3()
        end
    end
end

do -- Load LibSharedMedia
    local LSM = _G.LibStub("LibSharedMedia-3.0")

    --[[ Fonts
        SystemFont_Shadow_Med1
        SystemFont_Shadow_Med1_Outline
        NumberFont_Outline_Med
        Fancy16Font
    ]]

    -- Russian + Latin char languages
    local LOCALE_MASK = LSM.LOCALE_BIT_ruRU + LSM.LOCALE_BIT_western
    LSM:Register("font", "Roboto", [[Interface\AddOns\nibRealUI\Fonts\Roboto\Roboto-Regular.ttf]], LOCALE_MASK)
    LSM:Register("font", "Roboto Bold-Italic", [[Interface\AddOns\nibRealUI\Fonts\Roboto\Roboto-BoldItalic.ttf]], LOCALE_MASK)
    LSM:Register("font", "Roboto Condensed", [[Interface\AddOns\nibRealUI\Fonts\Roboto\RobotoCondensed-Regular.ttf]], LOCALE_MASK)
    LSM:Register("font", "Roboto Slab", [[Interface\AddOns\nibRealUI\Fonts\Roboto\RobotoSlab-Regular.ttf]], LOCALE_MASK)

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

    --[[ Backgrounds ]]--
    LSM:Register("background", "Plain", [[Interface\Buttons\WHITE8x8]])

    --[[ Statusbars ]]--
    LSM:Register("statusbar", "Plain", [[Interface\Buttons\WHITE8x8]])
end

--[[ Util functions ]]--
function RealUI.Round(value, places)
    local mult = 10 ^ (places or 0)
    return floor(value * mult + 0.5) / mult
end
function RealUI:GetSafeVals(min, max)
    if max == 0 then
        return 0
    else
        return min / max
    end
end
function RealUI:ColorTableToStr(vals)
    return _G.format("%02x%02x%02x", vals[1] * 255, vals[2] * 255, vals[3] * 255)
end
function RealUI.GetDurabilityColor(a, b)
    if a and b then
        debug("RGBColorGradient", a, b)
        return _G.oUFembed.RGBColorGradient(a, b, 0.9,0.1,0.1, 0.9,0.9,0.1, 0.1,0.9,0.1)
    else
        debug("GetDurabilityColor", a)
        if a < 0 then
            return 1, 0, 0
        elseif a <= 0.5 then
            return 1, a * 2, 0
        elseif a >= 1 then
            return 0, 1, 0
        else
            return 2 - a * 2, 1, 0
        end
    end
end


--[[ Copy Scale API from Aurora until the entire UI is upgraded. ]]--
function Scale.Value(value, getFloat)
    local mult = getFloat and 100 or 1
    return floor((value * uiMod) * mult + 0.5) / mult
end

function Scale.Size(self, width, height)
    if not (width and height) then
        width, height = self:GetSize()
    end
    return self:SetSize(Scale.Value(width), Scale.Value(height))
end

function Scale.Height(self, height)
    if not (height) then
        height = self:GetHeight()
    end
    return self:SetHeight(Scale.Value(height))
end

function Scale.Width(self, width)
    if not (width) then
        width = self:GetWidth()
    end
    return self:SetWidth(Scale.Value(width))
end

function Scale.Thickness(self, thickness)
    if not (thickness) then
        thickness = self:GetThickness()
    end
    return self:SetThickness(Scale.Value(thickness))
end

local ScaleArgs do
    local function pack(t, ...)
        for i = 1, _G.select("#", ...) do
            t[i] = _G.select(i, ...)
        end
    end

    local args = {}
    function ScaleArgs(self, method, ...)
        if self.debug then
            private.debug("raw args", method, ...)
        end
        _G.wipe(args)
        --[[ This function gets called A LOT, so we recycle this table
            to reduce needless garbage creation.]]
        if ... then
            pack(args, ...)
        else
            pack(args, self["Get"..method](self))
        end

        for i = 1, #args do
            if _G.type(args[i]) == "number" then
                args[i] = Scale.Value(args[i])
            end
        end
        if self.debug then
            private.debug("final args", method, _G.unpack(args))
        end
        return args
    end
end

function Scale.Point(self, ...)
    self:SetPoint(_G.unpack(ScaleArgs(self, "Point", ...)))
end

function Scale.EndPoint(self, ...)
    self:SetEndPoint(_G.unpack(ScaleArgs(self, "EndPoint", ...)))
end
function Scale.StartPoint(self, ...)
    self:SetStartPoint(_G.unpack(ScaleArgs(self, "StartPoint", ...)))
end
