local ADDON_NAME, private = ...

-- Lua Globals --
-- luacheck: globals floor next type

local Aurora = private.Aurora
local RealUI = _G.RealUI

local debug = RealUI.GetDebug("Skins")
private.debug = debug

local defaults = {
    profile = {
        stripeAlpha = 0.5,
        frameAlpha = 0.7,
        uiModScale = 1,
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

local uiMod, pixelScale
local function UpdateUIScale()
    local pysWidth, pysHeight = _G.GetPhysicalScreenSize()

    pixelScale = 768 / pysHeight
    uiMod = (pysHeight / 768) * private.skinsDB.uiModScale

    debug("physical size", pysWidth, pysHeight)
    debug("uiMod", uiMod)
end

function RealUI.ModValue(value, getFloat)
    return RealUI.Round(value * uiMod, getFloat and 2 or 0)
end

local previewFrames = {}
function RealUI.RegisterModdedFrame(frame, updateFunc)
    -- Frames that are sized via ModValue become HUGE with retina scale.
    local customScale, isRetina = RealUI:GetUIScale()
    if isRetina then
        return frame:SetScale(customScale)
    elseif customScale > pixelScale then
        return frame:SetScale(pixelScale)
    end

    if updateFunc then
        previewFrames[frame] = updateFunc
    end
end
function RealUI.PreviewModScale()
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
        if profile and profile.media.font then
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
    else
        _G.ReloadUI()
    end

    private.disabled.bags = true
    private.disabled.mainmenubar = true

    private.UpdateUIScale = UpdateUIScale
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

    for name, enabled in next, private.skinsDB do
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
        end
        if not _G.IsAddOnLoaded("Ace3") then
            private.AddOns.Ace3()
        end
    end
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

