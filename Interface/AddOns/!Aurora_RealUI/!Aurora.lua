local ADDON_NAME, mods = ...
mods["Aurora"] = {}
mods["nibRealUI"] = {}
mods["PLAYER_LOGIN"] = {}

-- Lua Globals --
local next = _G.next
local tinsert = _G.table.insert

-- RealUI --
local RealUI = _G.RealUI

-- RealUI skin hook
_G.REALUI_STRIPE_TEXTURES = _G.REALUI_STRIPE_TEXTURES or {}
_G.REALUI_WINDOW_FRAMES = _G.REALUI_WINDOW_FRAMES or {}
local debug = RealUI.GetDebug("!Aurora")
mods.debug = debug

-- Aurora API
local F, C
local r, g, b
local style = {}
style.apiVersion = "7.0"

style.defaults = {
    acknowledgedSplashScreen = true,
    buttonSolidColour = {.1, .1, .1, 1},
    useButtonGradientColour = false,
    chatBubbles = true,
    enableFont = false,
    useCustomColour = false,
    tooltips = false,
}

local skinnedAtlas = {
    ["token-info-background"] = [[Interface\AddOns\!Aurora_RealUI\Media\AuctionFrame\Token]],
    ["splash-botleft"] = [[Interface\AddOns\!Aurora_RealUI\Media\Splash\Splash]],
    ["splash-705-right"] = [[Interface\AddOns\!Aurora_RealUI\Media\Splash\Splash705]],
    ["splash-705-botleft"] = [[Interface\AddOns\!Aurora_RealUI\Media\Splash\Splash705]],
}

-- Save these functions so we dont have to duplicate just to place a border around an icon.
style.copy = {
    CreateBD = true,
    CreateBG = true,
    CreateGradient = true,
    CreateBDFrame = true,
    ReskinIcon = true,
}

local Base

-- Reskin* functions (Icon excepted) should never be saved, and only used within !Aurora.
-- This is to ensure a consistent look if the user disables Aurora.
local functions = {}
functions.CreateBD = function(f, alpha)
    --print("Override CreateBD", f:GetName(), a)
    if Base then
        local red, green, blue, a = RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3], RealUI.media.window[4]
        if alpha then
            a = alpha
        else
            f.tex = f.tex or f:CreateTexture(nil, "BACKGROUND", nil, 1)
            f.tex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true, true)
            f.tex:SetAlpha(_G.RealUI_InitDB.stripeOpacity)
            f.tex:SetAllPoints()
            f.tex:SetHorizTile(true)
            f.tex:SetVertTile(true)
            f.tex:SetBlendMode("ADD")
            tinsert(_G.REALUI_WINDOW_FRAMES, f)
            tinsert(_G.REALUI_STRIPE_TEXTURES, f.tex)
        end
        Base.SetBackdrop(f, red, green, blue, a)
    else
        f:SetBackdrop({
            bgFile = RealUI.media.textures.plain,
            edgeFile = RealUI.media.textures.plain,
            edgeSize = 1,
        })
        f:SetBackdropBorderColor(0, 0, 0)
        if not alpha then
            --print("CreateSD")
            f:SetBackdropColor(RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3], RealUI.media.window[4])
            f.tex = f.tex or f:CreateTexture(nil, "BACKGROUND", nil, 1)
            f.tex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true, true)
            f.tex:SetAlpha(_G.RealUI_InitDB.stripeOpacity)
            f.tex:SetAllPoints()
            f.tex:SetHorizTile(true)
            f.tex:SetVertTile(true)
            f.tex:SetBlendMode("ADD")
            tinsert(_G.REALUI_WINDOW_FRAMES, f)
            tinsert(_G.REALUI_STRIPE_TEXTURES, f.tex)
        else
            --print("CreateBD: alpha", alpha)
            f:SetBackdropColor(0, 0, 0, alpha)
        end
    end
end

functions.CreateBDFrame = function(f, a)
    local frame
    if f:GetObjectType() == "Texture" then
        frame = f:GetParent()
    else
        frame = f
    end

    local lvl = frame:GetFrameLevel()

    local bg = _G.CreateFrame("Frame", nil, frame)
    bg:SetPoint("TOPLEFT", f, -1, 1)
    bg:SetPoint("BOTTOMRIGHT", f, 1, -1)
    bg:SetFrameLevel(lvl == 0 and 1 or lvl - 1)

    F.CreateBD(bg, a)

    return bg
end

style.functions = functions

style.initVars = function()
    debug("initVars", _G.Aurora, _G.Aurora[1], _G.Aurora[2])
    F, C = _G.Aurora[1], _G.Aurora[2]
    r, g, b = C.r, C.g, C.b
end

_G.AURORA_CUSTOM_STYLE = style

local frame = _G.CreateFrame("Frame")
frame:RegisterEvent("ADDON_LOADED")
frame:RegisterEvent("PLAYER_LOGIN")
frame:SetScript("OnEvent", function(self, event, addon)
    if event == "PLAYER_LOGIN" and _G.IsAddOnLoaded("Aurora") then
        F, C = _G.Aurora[1], _G.Aurora[2]
        -- some skins need to be deferred till after all other addons.
        for addonName, func in next, mods[event] do
            if _G.type(addonName) == "string" then
                if _G.IsAddOnLoaded(addonName) then
                    -- Create skin modules for addon so they can be individually disabled.
                    local skin = RealUI:RegisterAddOnSkin(addonName)
                    if RealUI:GetModuleEnabled(addonName) then
                        func(skin, F, C)
                    end
                end
            else
                -- Some mods are indexed
                func(F, C)
            end
        end
        frame:UnregisterEvent("PLAYER_LOGIN")
    elseif event == "ADDON_LOADED" then
        local addonModule = mods[addon]
        debug("Load Addon", addon, addonModule)
        if addon == "Aurora" then
            F, C = _G.Aurora[1], _G.Aurora[2]
            if Aurora.Base then
                Base, Hook, Skin = _G.Aurora.Base, _G.Aurora.Hook, _G.Aurora.Skin
            end

            F.colorTex = function(f)
                if f:IsEnabled() then
                    for _, tex in next, f.tex do
                        tex:SetVertexColor(r, g, b)
                    end
                end
            end

            F.clearTex = function(f)
                for _, tex in next, f.tex do
                    tex:SetVertexColor(1, 1, 1)
                end
            end

            F.ReskinAtlas = function(f, atlas, is8Point)
                debug("ReskinAtlas", atlas, is8Point)
                local _, _, _, left, right, top, bottom = _G.GetAtlasInfo(atlas)
                -- file is an ID instead of a path now
                f:SetTexture(skinnedAtlas[atlas])
                if is8Point then
                    return left, right, top, bottom
                else
                    f:SetTexCoord(left, right, top, bottom)
                end
            end

            F.AddPlugin(function()
                mods["RealUI_Bugs"](F, C)
            end)
            for _, moduleFunc in next, addonModule do
                F.AddPlugin(function()
                    moduleFunc(F, C)
                end)
            end
        elseif addon == ADDON_NAME then
            -- These addons are loaded before !Aurora_RealUI.
            local addons = {
                Blizzard_CompactRaidFrames = true,
                Masque = true
            }

            for preload in next, addons do
                if _G.IsAddOnLoaded(preload) then
                    mods.debug(preload, F, C)
                    mods[preload](F, C)
                end
            end
        elseif addon == "nibRealUI" then
            for _, moduleFunc in next, addonModule do
                moduleFunc(F, C)
            end
        else
            if addonModule and _G.type(addonModule) == "function" then
                addonModule(F, C)
            end
        end
    end
end)
