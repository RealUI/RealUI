local _, mods = ...
mods["Aurora"] = {}
mods["nibRealUI"] = {}
mods["PLAYER_LOGIN"] = {}

-- Lua Globals --
local _G = _G
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
style.apiVersion = "6.0"

style.skipSplashScreen = true

--style.highlightColor = {r = 0, g = 1, b = 0}
style.classcolors = {
    ["DEATHKNIGHT"] = { r = 0.77, g = 0.12, b = 0.23 },
    ["DEMONHUNTER"] = { r = 0.64, g = 0.19, b = 0.79 },
    ["DRUID"]       = { r = 1.00, g = 0.49, b = 0.04 },
    ["HUNTER"]      = { r = 0.67, g = 0.83, b = 0.45 },
    ["MAGE"]        = { r = 0.41, g = 0.80, b = 0.94 },
    ["MONK"]        = { r = 0.00, g = 1.00, b = 0.59 },
    ["PALADIN"]     = { r = 0.96, g = 0.55, b = 0.73 },
    ["PRIEST"]      = { r = 0.80, g = 0.80, b = 0.80 },
    ["ROGUE"]       = { r = 1.00, g = 0.96, b = 0.41 },
    ["SHAMAN"]      = { r = 0.00, g = 0.44, b = 0.87 },
    ["WARLOCK"]     = { r = 0.58, g = 0.51, b = 0.79 },
    ["WARRIOR"]     = { r = 0.78, g = 0.61, b = 0.43 },
}

-- Save these functions so we dont have to duplicate just to place a border around an icon.
style.copy = {
    CreateBD = true,
    CreateBG = true,
    CreateGradient = true,
    CreateBDFrame = true,
    ReskinIcon = true,
}

-- Reskin* functions (Icon excepted) should never be saved, and only used within !Aurora.
-- This is to ensure a consistent look if the user disables Aurora.
local functions = {}
functions.CreateBD = function(f, a)
    --print("Override CreateBD", f:GetName(), a)
    f:SetBackdrop({
        bgFile = RealUI.media.textures.plain,
        edgeFile = RealUI.media.textures.plain,
        edgeSize = 1,
    })
    f:SetBackdropBorderColor(0, 0, 0)
    if not a then
        --print("CreateSD")
        f:SetBackdropColor(RealUI.media.window[1], RealUI.media.window[2], RealUI.media.window[3], RealUI.media.window[4])
        f.tex = f.tex or f:CreateTexture(nil, "BACKGROUND", nil, 1)
        f.tex:SetTexture([[Interface\AddOns\nibRealUI\Media\StripesThin]], true)
        f.tex:SetAlpha(_G.RealUI_InitDB.stripeOpacity)
        f.tex:SetAllPoints()
        f.tex:SetHorizTile(true)
        f.tex:SetVertTile(true)
        f.tex:SetBlendMode("ADD")
        tinsert(_G.REALUI_WINDOW_FRAMES, f)
        tinsert(_G.REALUI_STRIPE_TEXTURES, f.tex)
    else
        --print("CreateBD: alpha", a)
        f:SetBackdropColor(0, 0, 0, a)
    end
end

functions.CreateBG = function(frame)
    local f = frame
    if frame:GetObjectType() == "Texture" then f = frame:GetParent() end

    local bg = f:CreateTexture(nil, "BACKGROUND", nil, -8)
    bg:SetPoint("TOPLEFT", frame, -1, 1)
    bg:SetPoint("BOTTOMRIGHT", frame, 1, -1)
    bg:SetTexture(RealUI.media.textures.plain)
    bg:SetVertexColor(0, 0, 0)

    return bg
end

local buttonR, buttonG, buttonB, buttonA
functions.CreateGradient = function(f)
    local tex = f:CreateTexture(nil, "BORDER")
    tex:SetPoint("TOPLEFT", 1, -1)
    tex:SetPoint("BOTTOMRIGHT", -1, 1)
    tex:SetTexture(RealUI.media.textures.plain)
    tex:SetVertexColor(buttonR, buttonG, buttonB, buttonA)

    return tex
end

local function colourButton(f)
    if not f:IsEnabled() then return end
    f.tex:SetVertexColor(r * 0.25, g * 0.25, b * 0.25)
    f:SetBackdropBorderColor(r, g, b)
end

local function clearButton(f)
    f.tex:SetVertexColor(buttonR, buttonG, buttonB, buttonA)
    f:SetBackdropBorderColor(0, 0, 0)
end

functions.Reskin = function(f, noHighlight)
    f:SetNormalTexture("")
    f:SetHighlightTexture("")
    f:SetPushedTexture("")
    f:SetDisabledTexture("")

    if f.Left then f.Left:SetAlpha(0) end
    if f.Middle then f.Middle:SetAlpha(0) end
    if f.Right then f.Right:SetAlpha(0) end
    if f.LeftSeparator then f.LeftSeparator:Hide() end
    if f.RightSeparator then f.RightSeparator:Hide() end

    F.CreateBD(f, .0)

    f.tex = F.CreateGradient(f)

    if not noHighlight then
        f:HookScript("OnEnter", colourButton)
         f:HookScript("OnLeave", clearButton)
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

functions.ReskinFilterButton = function(f, noArrow)
    f.TopLeft:Hide()
    f.TopRight:Hide()
    f.BottomLeft:Hide()
    f.BottomRight:Hide()
    f.TopMiddle:Hide()
    f.MiddleLeft:Hide()
    f.MiddleRight:Hide()
    f.BottomMiddle:Hide()
    f.MiddleMiddle:Hide()

    F.Reskin(f)
    if f.Icon and not noArrow then
        f.Icon:SetTexture(C.media.arrowRight)

        f.Text:SetPoint("CENTER")
        f.Icon:SetPoint("RIGHT", f, "RIGHT", -5, 0)
        f.Icon:SetSize(8, 8)
    end
end

functions.ReskinIcon = function(icon)
    debug("ReskinIcon", F, C, icon)
    icon:SetTexCoord(.08, .92, .08, .92)
    return F.CreateBG(icon)
end
style.functions = functions

style.initVars = function()
    debug("initVars", _G.Aurora, _G.Aurora[1], _G.Aurora[2])
    F, C = _G.Aurora[1], _G.Aurora[2]
    r, g, b = C.r, C.g, C.b
    buttonR, buttonG, buttonB, buttonA = .1, .1, .1, 1
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
                    local skin = RealUI:RegisterSkin(addonName)
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
                --debug("ReskinAtlas")
                if not atlas then atlas = f:GetAtlas() end
                local file, _, _, left, right, top, bottom = _G.GetAtlasInfo(atlas)
                file = file:sub(10) -- cut off "Interface"
                f:SetTexture([[Interface\AddOns\!Aurora_RealUI\Media]]..file)
                if is8Point then
                    return left, right, top, bottom
                else
                    f:SetTexCoord(left, right, top, bottom)
                end
            end

            for _, moduleFunc in next, addonModule do
                F.AddPlugin(function()
                    moduleFunc(F, C)
                end)
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
