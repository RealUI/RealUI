local _, private = ...

-- Lua Globals --
-- luacheck: globals floor next type

local Aurora = private.Aurora
local RealUI = _G.RealUI
local RealUI_SkinsDB

local debug = RealUI.GetDebug("Skins")
private.debug = debug

local defaults = {
    stripeAlpha = 0.5,
    frameAlpha = 0.7,
    uiModScale = 1,
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

local uiMod, pixelScale
local function UpdateUIScale()
    local pysWidth, pysHeight = _G.GetPhysicalScreenSize()

    pixelScale = 768 / pysHeight
    uiMod = (pysHeight / 768) * _G.RealUI_SkinsDB.uiModScale

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
            frame:SetBackdropColor(color.r, color.g, color.b, _G.RealUI_SkinsDB.frameAlpha)
            stripes:SetAlpha(RealUI_SkinsDB.stripeAlpha)
        end
    end
end

function private.OnLoad()
    --print("OnLoad Aurora", Aurora, private.Aurora)
    _G.RealUI_SkinsDB = _G.RealUI_SkinsDB or {}
    RealUI_SkinsDB = _G.RealUI_SkinsDB

    if _G.RealUI_Storage.nibRealUI_Init then
        local RealUI_InitDB = _G.RealUI_Storage.nibRealUI_Init.RealUI_InitDB
        RealUI_SkinsDB.stripeAlpha = RealUI_InitDB.stripeOpacity
        RealUI_SkinsDB.uiModScale = RealUI_InitDB.uiModScale
        _G.RealUI_Storage.nibRealUI_Init = nil
    end

    if _G.RealUI_Storage.Aurora then
        local AuroraConfig = _G.RealUI_Storage.Aurora.AuroraConfig
        RealUI_SkinsDB.frameAlpha = AuroraConfig.alpha
        if type(AuroraConfig.customClassColors) == "table" then
            RealUI_SkinsDB.customClassColors = AuroraConfig.customClassColors
        end
        _G.RealUI_Storage.Aurora = nil
    end

    for key, value in next, defaults do
        if RealUI_SkinsDB[key] == nil then
            if _G.type(value) == "table" then
                RealUI_SkinsDB[key] = {}
                for k, v in next, value do
                    RealUI_SkinsDB[key][k] = value[k]
                end
            else
                RealUI_SkinsDB[key] = value
            end
        end
    end

    private.UpdateUIScale = UpdateUIScale

    local Base, Hook = Aurora.Base, Aurora.Hook
    Aurora.Scale.Value = RealUI.ModValue
    function Hook.GameTooltip_OnHide(gametooltip)
        local color = Aurora.frameColor
        Base.SetBackdropColor(gametooltip, color.r, color.g, color.b, _G.RealUI_SkinsDB.frameAlpha)
    end

    function Base.Post.SetBackdrop(frame, r, g, b, a)
        if not a then
            local color = Aurora.frameColor
            frame:SetBackdropColor(color.r, color.g, color.b, _G.RealUI_SkinsDB.frameAlpha)

            local stripes = frame:CreateTexture(nil, "BACKGROUND", nil, 1)
            stripes:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true, true)
            stripes:SetAlpha(_G.RealUI_SkinsDB.stripeAlpha)
            stripes:SetAllPoints()
            stripes:SetHorizTile(true)
            stripes:SetVertTile(true)
            stripes:SetBlendMode("ADD")
            skinnedFrames[frame] = stripes
        end
    end

    function private.AddOns.nibRealUI()
        if not _G.IsAddOnLoaded("Ace3") then
            private.AddOns.Ace3()
        end
    end
end
